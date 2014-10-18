use strict;

package Proc::vxconfigd60::Common;
@Proc::vxconfigd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxconfigd';
    $proc->{name}='vxconfigd name';
    $proc->{desc}='vxconfigd description';
    $proc->{multisystemserialstart}=1;
    $proc->{fatal}=1;
    $proc->{abort_procs}=[ qw(vxesd vxrelocd vxcached vxconfigbackupd vxattachd vvr) ];
    return;
}

sub start_sys {
    my ($proc,$sys) = @_;
    my ($voldmode,$rtn,$prod);
    $prod=$proc->prod('VM60');
    # Need to handle situation where VM was previously configured
    if( (! $sys->exists($prod->{mkdbfile})) && ($sys->exists($prod->{volbootfile}))) {
        Msg::log("$prod->{name} was previously started on system $sys->{sys}");
        $voldmode=$sys->cmd('_cmd_vxdctl mode 2>/dev/null');
        if ( $voldmode =~ /mode: not-running/m ) {
            Msg::log("vxconfigd is not running on $sys->{sys}; restarting");
            $sys->cmd('_cmd_vxconfigd -k -r reset -x syslog 2>/dev/null');
            $voldmode=$sys->cmd('_cmd_vxdctl mode 2>/dev/null');
            if ( ! $voldmode =~ /mode: enabled/m ){
                $sys->{vxconfigd_status}='disabled';
                Msg::log('vxconfigd failed');
            } else {
                $sys->{vxconfigd_status}='enabled';
                Msg::log('vxconfigd started');
            }
        } elsif($voldmode !~ /mode: enabled/m) {
            # the mode could be could be disabled or booted
            Msg::log("vxconfigd is in $voldmode on $sys->{sys}; re-enabling");
            $sys->cmd('_cmd_vxdctl enable >/dev/null 2>&1');
            $voldmode=$sys->cmd('_cmd_vxdctl mode 2>/dev/null');
            if ($voldmode !~ /mode: enabled/m ){
                $sys->{vxconfigd_status}='disabled';
                Msg::log('vxconfigd failed');
            } else {
                $sys->{vxconfigd_status}='enabled';
                Msg::log('vxconfigd started');
            }
        }
        return 1;
    }

    # Skip if we had previously detected an error
    return 0 if ($sys->{vm_install} =~ /error/m);

    # Do processing for enclosure based naming.
    $proc->process_ebn_sys($sys);

    # Mount tmpfs on DMP device directories
    $proc->mount_dmp_sys($sys);

    # Start up vxconfigd
    Msg::log("Starting vxconfigd for $prod->{name} on $sys->{sys}");
    $sys->cmd('_cmd_vxconfigd -k -m disable -x syslog 2>/dev/null');

    # check vxdctl
    $rtn = $proc->check_vxdctl_sys($sys);
    return 0 if (! $rtn);

    $sys->cmd('_cmd_vxdctl init > /dev/null 2>&1');
    $sys->cmd('_cmd_vxdctl enable > /dev/null 2>&1');

    $voldmode=$sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    if ($voldmode !~ /mode: enabled/m ){
        $sys->{vxconfigd_status}='disabled';
        Msg::log('vxconfigd failed');
        return 0;
    } else {
        $sys->{vxconfigd_status}='enabled';
        Msg::log('vxconfigd started');
        $sys->cmd("_cmd_rmr $prod->{mkdbfile}");
    }

    return 1;
}

# Do this for AIX only.
sub check_vxdctl_sys {
    return 1;
}

# Do this for SunOS only.
sub mount_dmp_sys {
    return 1;
}

sub stop_sys {
    my ($proc,$sys) = @_;
    my ($pids);

    $sys->cmd('_cmd_vxdctl stop 2>/dev/null');
    $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids >= 0) {
        $sys->cmd('_cmd_vxdctl -k stop 2>/dev/null');
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0 if ($state =~ /start/m);
    } else {
        return 1 if ($state =~ /stop/m);
    }
    my $voldmode=$sys->cmd('_cmd_vxdctl mode 2>/dev/null');
    if ($voldmode =~ /mode: enabled/m) {
        $sys->cmd('_cmd_vxdctl license init 2>/dev/null')
            if ($state =~ /prestart/m);
        return 1;
    }
    return 0;
}

package Proc::vxconfigd60::AIX;
@Proc::vxconfigd60::AIX::ISA = qw(Proc::vxconfigd60::Common);

sub process_ebn_sys {
    my ($proc,$sys)=@_;
    return;
}

sub check_vxdctl_sys {
    my ($proc,$sys)=@_;
    my ($voldmode, $counter, $started);
    $counter = 0;
    $started = 0;
    while($counter < 15) {
        $voldmode=$sys->cmd('_cmd_vxdctl mode 2>/dev/null');
        if(($voldmode)&&($voldmode !~ /mode: not-running/m)) {
            $started = 1;
            last;
        }
        $counter++;
        sleep 5;
        Msg::log("waiting vxconfigd to start: $counter");
    }
    if($started) {
        Msg::log('vxconfigd started');
    } else {
        Msg::log('vxconfigd failed to start');
    }
    return $started;
}

package Proc::vxconfigd60::HPUX;
@Proc::vxconfigd60::HPUX::ISA = qw(Proc::vxconfigd60::Common);

sub process_ebn_sys {
    my ($proc,$sys) = @_;
    my ($prod);
    $prod=$proc->prod('VM60');
    $sys->cmd('_cmd_rmr /dev/vx/dmp/*');
    $sys->cmd('_cmd_rmr /dev/vx/rdmp/*');
    if($sys->{vm_newnames_file}) {
        $sys->cmd("_cmd_touch $prod->{newnames_file}");
        Msg::log("Enabling enclosure-based naming on $sys->{sys}\nDone");
    } else {
        $sys->cmd("_cmd_rmr $prod->{newnames_file}");
        Msg::log("Disabling enclosure-based naming on $sys->{sys}\nDone");
    }
    return;
}

package Proc::vxconfigd60::Linux;
@Proc::vxconfigd60::Linux::ISA = qw(Proc::vxconfigd60::Common);

sub process_ebn_sys {
    my ($proc,$sys) = @_;
    my ($prod);
    $prod=$proc->prod('VM60');
    $sys->cmd('_cmd_rmr /dev/vx/dmp');
    $sys->cmd('_cmd_rmr /dev/vx/rdmp');
    $sys->cmd('_cmd_mkdir -m 0755 /dev/vx/dmp ');
    $sys->cmd('_cmd_ln -s /dev/vx/dmp /dev/vx/rdmp ');
    return;
}

package Proc::vxconfigd60::SunOS;
@Proc::vxconfigd60::SunOS::ISA = qw(Proc::vxconfigd60::Common);

sub process_ebn_sys {
    my ($proc,$sys) = @_;
    my ($prod);
    $prod=$proc->prod('VM60');
    $sys->cmd('_cmd_rmr /dev/vx/dmp/*');
    $sys->cmd('_cmd_rmr /dev/vx/rdmp/*');
    return;
}

sub mount_dmp_sys {
    my ($proc,$sys)=@_;
    if ($sys->is_dir('/dev/vx/dmp')) {
        $sys->cmd('_cmd_mount -f tmpfs dmpfs /dev/vx/dmp');
    }

    if ($sys->is_dir('/dev/vx/rdmp')) {
        $sys->cmd('_cmd_mount -f tmpfs dmpfs /dev/vx/rdmp');
    }
    return 1;
}

1;
