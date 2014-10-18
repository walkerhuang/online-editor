#
# $Copyright: Copyright (c) 2014 Symantec Corporation.
# All rights reserved.
#
# THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
# SYMANTEC CORPORATION.  USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
# WITHOUT THE PRIOR EXPRESS WRITTEN PERMISSION OF SYMANTEC CORPORATION.
#
# The Licensed Software and Documentation are deemed to be commercial
# computer software as defined in FAR 12.212 and subject to restricted
# rights as defined in FAR Section 52.227-19 "Commercial Computer
# Software - Restricted Rights" and DFARS 227.7202, "Rights in
# Commercial Computer Software or Commercial Computer Software
# Documentation", as applicable, and any successor regulations. Any use,
# modification, reproduction release, performance, display or disclosure
# of the Licensed Software and Documentation by the U.S. Government
# shall be solely in accordance with the terms of this Agreement.  $
#
use strict;

package Proc::gab60::Common;
@Proc::gab60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='gab';
    $proc->{name}='Veritas Group Membership and Atomic Broadcast';
    $proc->{desc}='Veritas Group Membership and Atomic Broadcast';
    $proc->{start_period}=20;
    $proc->{stop_period}=10;
    $proc->{retry_stop}=1;
    $proc->{fatal}=1;
    $proc->{abort_procs}=[ qw(vxfen had CmdServer vxglm vxgms odm vxodm vcsmm lmx) ];
    return;
}

sub prestop_sys {
    my ($proc,$sys) = @_;
    my ($gabversion,$output,$gabcmd,$gabtxt);
    return 1 unless (Cfg::opt('upgrade_kernelpkgs'));
    $output=$sys->cmd("_cmd_gabconfig -W | _cmd_grep 'Current Protocol Version'");
    $gabversion= $1 if ($output =~/Current Protocol Version\s+:\s+(\d+)/m);
    return '' unless (EDRu::isint($gabversion));
    #backup /etc/gabtab
    $gabcmd=$sys->cmd('_cmd_cat /etc/gabtab');
    $gabtxt=$gabcmd;
    $gabtxt=~s/-V\d+//mg if($gabtxt =~/V/m);
    Msg::log("Backup RU gabtab-old:\n$gabtxt");
    $sys->writefile($gabtxt,'/etc/gabtab.rubak');
    $gabcmd.=" -V$gabversion"  unless($gabcmd =~/V/m);
    Msg::log("Creating new gabtab-new:\n$gabcmd");
    $sys->writefile($gabcmd,'/etc/gabtab');
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("gab not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("gab loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_gabconfig -l 2> /dev/null| _cmd_grep 'Driver state' | _cmd_awk '{ print \$4;}'");
    Msg::log("Gab Driver state is '$rtn' on $sys->{sys}");
    if (($rtn eq 'Configured') || ($rtn eq 'ConfiguredPartition')) {
        return 1;
    } else {
        # loaded not configured
        return 1 if ($state =~ /stop/m);
    }
    return 0;
}

sub enable_sys {
    my ($proc,$sys) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    $conf =~ s/GAB_START\s*=\s*0/GAB_START=1/mx;
    $conf =~ s/GAB_STOP\s*=\s*0/GAB_STOP=1/mx;
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
    my ($cfg,$file,$conf,$rootpath,$stat);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    $conf =~ s/GAB_START\s*=\s*1/GAB_START=0/mx;
    $conf =~ s/GAB_STOP\s*=\s*1/GAB_STOP=0/mx;
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
    $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading  driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## gabconfig -a output:\n\n");
    $sys->cmd('_cmd_gabconfig -a 2> /dev/null');
    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::gab60::AIX;
@Proc::gab60::AIX::ISA = qw(Proc::gab60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S92gab';
    $proc->{kernelfile}='/etc/methods/gabkext';
    $proc->{driverfile}='/usr/lib/drivers/gab';
    $proc->{initconf}='/etc/default/gab';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->cmd("$proc->{kernelfile} -status");
    if ($mod !~ /gab: loaded/m) {
        Msg::log("gab not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("gab loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_gabconfig -l 2> /dev/null| _cmd_grep 'Driver state' | _cmd_awk '{ print \$4;}'");
    Msg::log("Gab Driver is $rtn on $sys->{sys}");
    if (($rtn eq 'Configured') || ($rtn eq 'ConfiguredPartition')) {
        return 1;
    } else {
        # loaded not configured
        return 1 if ($state =~ /stop/m);
    }
    return 0;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{kernelfile} -start 2> /dev/null");
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
    Msg::log('Unloading gab driver');
    $sys->cmd("$proc->{kernelfile} -stop 2> /dev/null");
    return 1;
}

package Proc::gab60::HPUX;
@Proc::gab60::HPUX::ISA = qw(Proc::gab60::Common);
sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/gab';
    $proc->{initconf}='/etc/rc.config.d/gabconf';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("gab not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("gab loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_gabconfig -l 2> /dev/null| _cmd_grep 'Driver state' | _cmd_awk '{ print \$4;}'");
    Msg::log("Gab Driver is $rtn on $sys->{sys}");
    if (($rtn eq 'Configured') || ($rtn eq 'ConfiguredPartition')) {
        return 1;
    } else {
        # loaded not configured
        return 1 if ($state =~ /stop/m);
    }
    return 0;
}

sub  dump_gab_parameters_sys {
    my ($proc,$sys,$msg)=@_;
    my ($gabconfig_l,$gabconfig_a,$kcmodule_gab,$kcmodule_v_gab,$logmsg);

    $gabconfig_l=$sys->cmd('_cmd_gabconfig -l 2>&1 ');
    $gabconfig_a=$sys->cmd('_cmd_gabconfig -a 2>&1 ');
    $kcmodule_gab=$sys->cmd('_cmd_kcmodule gab 2>&1 ');
    $kcmodule_v_gab=$sys->cmd('_cmd_kcmodule -v gab 2>&1 ');
    $logmsg="GAB $msg on system $sys->{sys}, dumping debug information:\n";
    $logmsg.="\ngabconfig -l\n$gabconfig_l\n";
    $logmsg.="\ngabconfig -a\n$gabconfig_a\n";
    $logmsg.="\nkcmodule gab\n$kcmodule_gab\n";
    $logmsg.="\nkcmodule -v gab\n$kcmodule_v_gab\n";
    Msg::log($logmsg);
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;
    return $proc->dump_gab_parameters_sys($sys,'start failed');
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;
    return $proc->dump_gab_parameters_sys($sys,'stop failed');
}

package Proc::gab60::Linux;
@Proc::gab60::Linux::ISA = qw(Proc::gab60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/gab';
    $proc->{initconf}='/etc/sysconfig/gab';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn);
    if ($sys->exists($proc->{controlfile})) {
        $rtn=$sys->cmd("$proc->{controlfile} status 2>/dev/null");
        if ($rtn=~ /configured/m) {
            Msg::log("gab configured on $sys->{sys}");
            return 1;
        } elsif ($rtn =~ /not/m) {
            Msg::log("gab not loaded on $sys->{sys}");
            return 0;
        } else {
            Msg::log("gab loaded but not configured on $sys->{sys}");
            return 1 if ($state =~ /stop/m);
        }
    }
    return 0;
}

package Proc::gab60::SunOS;
@Proc::gab60::SunOS::ISA = qw(Proc::gab60::Common);

sub init_plat {
    my $proc = shift;
    $proc->{controlfile}='/etc/rc2.d/S92gab';
    $proc->{smf_manifest}='/var/svc/manifest/system/gab.xml';
    $proc->{initconf}='/etc/default/gab';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    my $cmdoutput;
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/gab');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/gab');
        }
        $sys->cmd('_cmd_svcadm enable system/gab');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} start");
    } else {
        return 0;
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($cmdoutput);
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/gab');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/gab');
            $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
        }
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
    }
    sleep 5;
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading gab driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

1;
