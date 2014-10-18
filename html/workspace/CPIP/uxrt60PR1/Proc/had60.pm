use strict;

package Proc::had60::Common;
@Proc::had60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='had';
    $proc->{name}='Veritas Cluster Server';
    $proc->{desc}='Veritas Cluster Server';
    $proc->{start_period}=120;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub enable_sys {
    my ($proc,$sys) = @_;
    my ($file,$conf,$rootpath,$stat);
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    $conf =~ s/VCS_START\s*=\s*0/VCS_START=1/mx;
    $conf =~ s/VCS_STOP\s*=\s*0/VCS_STOP=1/mx;
    $conf .= "\n";
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    return 1;
}

sub disable_sys {
    my ($proc,$sys) = @_;
    my ($file,$conf,$rootpath,$stat);
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    $conf =~ s/VCS_START\s*=\s*1/VCS_START=0/mx;
    $conf =~ s/VCS_STOP\s*=\s*1/VCS_STOP=0/mx;
    $conf .= "\n";
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my $vcs=$proc->prod('VCS60');

    # need to force stop had in case of frozen service groups.
    $sys->cmd("$vcs->{bindir}/hastop -local -force");
    sleep 2;
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($clusterrunning,$had_pids,$hashadow_pids,$sysname);

    $state||='poststart';

    $had_pids=$sys->proc_pids('bin/had');
    $hashadow_pids=$sys->proc_pids('hashadow');
    if ($state=~/start/m) {
        # When in startup phase,
        # regard had not running if had not running or hashadow not running
        if (($#{$had_pids}==-1) || ($#{$hashadow_pids}==-1)) {
            Msg::log("had not running on $sys->{sys}") if ($#{$had_pids}==-1);
            Msg::log("hashadow not running on $sys->{sys}") if ($#{$hashadow_pids}==-1);
            return 0;
        }
    } elsif ($state=~/stop/m) {
        # When in stop phase,
        # regard had running if had running or hashadow running
        # regard had not running if both had and hashadow not running
        if (($#{$had_pids}==-1) && ($#{$hashadow_pids}==-1)) {
            Msg::log("both had and hashadow not running on $sys->{sys}");
            return 0;
        } else {
            return 1;
        }
    }

    Msg::log("both had and hashadow running on $sys->{sys}, checking VCS state further");

    $sysname = $sys->{vcs_sysname};
    my $vcs = $proc->prod('VCS60');
    $sysname ||= $vcs->get_vcs_sysname_sys($sys);
    $sys->cmd("/opt/VRTSvcs/bin/hasys -wait $sysname SysState RUNNING -time 60");
    if (EDR::cmdexit() eq '0') {
        Msg::log("State of $sys->{sys} is RUNNING");
        return 1;
    }

    $clusterrunning=$sys->cmd("/opt/VRTSvcs/bin/hasys -state $sysname");
    Msg::log("$sys->{sys} not in RUNNING state, State is $clusterrunning");
    return 0 if ($clusterrunning=~/ERROR/m);
    if ($clusterrunning=~/STALE/m) {
        Msg::log("State is $clusterrunning, means that had failed to start up because of main.cf error");
        $proc->{start_period} = 0;
        return 0;
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids,@pids);

    @pids=();
    $pids=$sys->proc_pids('bin/had');
    push @pids, @{$pids} if (@{$pids});
    $pids=$sys->proc_pids('hashadow');
    push @pids, @{$pids} if (@{$pids});
    $sys->kill_pids(@pids);
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check start failures in engine_A.log:\n");
    $sys->cmd("_cmd_date '+%Y/%m/%d %H:%M:%S' 2>/dev/null") unless ($sys->{islocal});
    $sys->cmd('_cmd_tail -10 /var/VRTSvcs/log/engine_A.log 2>/dev/null');
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check stop failures in engine_A.log:\n");
    $sys->cmd("_cmd_date '+%Y/%m/%d %H:%M:%S' 2>/dev/null") unless ($sys->{islocal});
    $sys->cmd('_cmd_tail -10 /var/VRTSvcs/log/engine_A.log 2>/dev/null');
    return 1;
}

sub is_enabled_sys {
    my ($proc,$sys)=@_;
    my ($conf,$rootpath,$initconf);
    $rootpath = Cfg::opt('rootpath') || '';
    $initconf = $rootpath . $proc->{initconf};
    if ( !$initconf ) {
        return 0;
    }
    $conf = $sys->cmd("unset VCS_START 2>/dev/null >/dev/null ; . $initconf 2>/dev/null >/dev/null ; echo \$VCS_START");
    chomp $conf;
    if ($conf eq '0'){
        return 0;
    } else {
        return 1;
    }
}

package Proc::had60::AIX;
@Proc::had60::AIX::ISA = qw(Proc::had60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S99vcs';
    $proc->{initconf}='/etc/default/vcs';
    return;
}

package Proc::had60::HPUX;
@Proc::had60::HPUX::ISA = qw(Proc::had60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/vcs';
    $proc->{initconf}='/etc/rc.config.d/vcsconf';
    return;
}

package Proc::had60::Linux;
@Proc::had60::Linux::ISA = qw(Proc::had60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/vcs';
    $proc->{initconf}='/etc/sysconfig/vcs';
    return;
}

package Proc::had60::SunOS;
@Proc::had60::SunOS::ISA = qw(Proc::had60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc3.d/S99vcs';
    $proc->{smf_manifest}='/var/svc/manifest/system/vcs.xml';
    $proc->{smf_manifest_onenode}='/var/svc/manifest/system/vcs-onenode.xml';
    $proc->{initconf}='/etc/default/vcs';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($running,$cfg,$rtn);

    $state||='poststart';

    # Run basic check
    $running=$proc->SUPER::check_sys($sys,$state);
    if ($state=~/stop/m && !$running) {
        # if stopping, and if both had and hashadow not running, check SMF service state further
        $cfg = Obj::cfg();
        if ($sys->exists($proc->{smf_manifest_onenode}) && !$cfg->{vcs_allowcomms}) {
            Msg::log("checking SMF service 'vcs-onenode' state further");
            $rtn=$sys->cmd("_cmd_svcs -v -p /system/vcs-onenode 2>/dev/null | _cmd_awk '{print \$1}'");
        } elsif ($sys->exists($proc->{smf_manifest})) {
            Msg::log("checking SMF service 'vcs' state further");
            $rtn=$sys->cmd("_cmd_svcs -v -p /system/vcs | _cmd_awk '{print \$1}'");
        }
        if ($rtn) {
            if ($rtn =~ /online/m) {
                Msg::log("SMF service is in online state");
                return 1;
            } else {
                Msg::log("SMF service is not in online state");
            }
        }
    }
    return $running;
}

sub start_sys {
    my ($proc,$sys)=@_;
    my  ($cfg,$rtn,$vcs);
    $cfg = Obj::cfg();

    if ($sys->exists($proc->{smf_manifest_onenode}) && !$cfg->{vcs_allowcomms}) {
        $rtn=$sys->cmd('_cmd_svcadm disable -st system/vcs-onenode');
        if ($rtn =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/vcs-onenode');
        }
        $sys->cmd('_cmd_svcadm enable system/vcs-onenode');
    } elsif ($sys->exists($proc->{smf_manifest})) {
        $rtn=$sys->cmd('_cmd_svcadm disable -st system/vcs');
        if ($rtn =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/vcs');
        }
        $sys->cmd('_cmd_svcadm enable system/vcs');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} start");
    } else {
        return 0;
    }

    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($rtn,$vcs);

    # need to force stop had in case of frozen service groups.
    $vcs=$proc->prod('VCS60');
    $sys->cmd("$vcs->{bindir}/hastop -local -force");

    if ($sys->exists($proc->{smf_manifest_onenode})) {
        $rtn=$sys->cmd('_cmd_svcadm disable -st system/vcs-onenode 2>/dev/null');
        if ($rtn =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/vcs-onenode');
        }
    } 
    if ($sys->exists($proc->{smf_manifest})) {
        $rtn=$sys->cmd('_cmd_svcadm disable -st system/vcs');
        if ($rtn =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/vcs');
        }
    }

    sleep 2;
    return 1;
}

1;
