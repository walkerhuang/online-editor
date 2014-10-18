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

package Proc::llt62::Common;
@Proc::llt62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='llt';
    $proc->{name}='Symantec Low Latency Transport';
    $proc->{desc}='llt description';
    $proc->{start_period}=60;
    $proc->{stop_period}=10;
    $proc->{fatal}=1;
    $proc->{abort_procs}=[ qw(gab vxfen had CmdServer vxglm vxgms odm vxodm vcsmm lmx) ];
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("llt not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("llt loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_lltconfig 2> /dev/null|_cmd_grep 'LLT is running'");
    if ($rtn=~ /LLT is running/m) {
        Msg::log("LLT configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("LLT loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    # starting, need to configure
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
    $conf =~ s/LLT_START\s*=\s*0/LLT_START=1/mx;
    $conf =~ s/LLT_STOP\s*=\s*0/LLT_STOP=1/mx;
    $conf .= "\n";
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    if($proc->{driver_config}=~ /\S/){
        $sys->cmd_script($proc->{driver_config});
    }
    return 1;
}

sub disable_sys {
    my ($proc,$sys,$postinstall) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    $conf =~ s/LLT_START\s*=\s*1/LLT_START=0/mx;
    $conf =~ s/LLT_STOP\s*=\s*1/LLT_STOP=0/mx;
    $conf .= "\n";
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }

    # skip this action at postinstall phase
    if(!$postinstall && $proc->{driver_unconfig}=~ /\S/){
        $sys->cmd_script($proc->{driver_unconfig});
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
    $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading LLT driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::llt62::AIX;
@Proc::llt62::AIX::ISA = qw(Proc::llt62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S70llt';
    $proc->{driverfile}='/usr/lib/drivers/pse/llt';
    $proc->{initconf}='/etc/default/llt';
    $proc->{driver_config} = <<'AIX_LLT_CONFIG';
odmadd <<_HERE
Config_Rules:
    phase = 2
    seq = 21
    rule = "/etc/methods/loadllt"
_HERE
/etc/methods/loadllt
exit 0
AIX_LLT_CONFIG
    $proc->{driver_unconfig} = <<'AIX_LLT_UNCONFIG';
/usr/sbin/strload -q -d /usr/lib/drivers/pse/llt > /dev/null
odmdelete -q"rule='/etc/methods/loadllt'" -o Config_Rules > /dev/null
exit 0
AIX_LLT_UNCONFIG
    return;
}

sub check_sys {
    my ($proc,$sys,$state)= @_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{driverfile});
    if ($mod eq '') {
        Msg::log("llt not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("llt loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_lltconfig 2> /dev/null|_cmd_grep 'LLT is running'");
    if ($rtn=~ /LLT is running/m) {
        Msg::log("LLT configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("LLT loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    # starting, need to configure
    return 0;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
    if ($sys->padv->driver_sys($sys,$proc->{driverfile})) {
        Msg::log('Unloading LLT driver');
        $sys->padv->unload_driver_sys($sys,$proc->{driverfile});
    }
    return 1;
}

package Proc::llt62::HPUX;
@Proc::llt62::HPUX::ISA = qw(Proc::llt62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/llt';
    $proc->{initconf}='/etc/rc.config.d/lltconf';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("llt not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("llt loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_lltconfig 2> /dev/null|_cmd_grep 'LLT is running'");
    if ($rtn=~ /LLT is running/m) {
        Msg::log("LLT configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("LLT loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    return 0;
}

sub dump_llt_parameters_sys {
    my ($proc,$sys,$msg)=@_;
    my ($kcmodule_llt,$kcmodule_v_llt,$lltconfig,$logmsg);

    $lltconfig=$sys->cmd('_cmd_lltconfig 2>&1');
    $kcmodule_llt=$sys->cmd('_cmd_kcmodule llt 2>&1 ');
    $kcmodule_v_llt=$sys->cmd('_cmd_kcmodule -v llt 2>&1 ');
    $logmsg="LLT $msg on system $sys->{sys}, dumping debug information:\n";
    $logmsg.="\nlltconfig \n $lltconfig\n";
    $logmsg.="\nkcmodule llt\n$kcmodule_llt\n";
    $logmsg.="\nkcmodule -v llt\n$kcmodule_v_llt\n";
    Msg::log($logmsg);
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;
    return $proc->dump_llt_parameters_sys($sys,'start failed');
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;
    return $proc->dump_llt_parameters_sys($sys,'stop failed');
}

package Proc::llt62::Linux;
@Proc::llt62::Linux::ISA = qw(Proc::llt62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/llt';
    $proc->{initconf}='/etc/sysconfig/llt';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $rtn;
    if ($sys->exists($proc->{controlfile})) {
        $rtn=$sys->cmd("$proc->{controlfile} status");
        if ($rtn=~ /configured/m) {
            Msg::log("LLT configured on $sys->{sys}");
            return 1;
        } elsif ($rtn =~ /not/m) {
            Msg::log("LLT not loaded on $sys->{sys}");
            return 0;
        } else {
            Msg::log("LLT loaded but not configured on $sys->{sys}");
            return 1 if ($state =~ /stop/m);
        }
    }
    return 0;
}

package Proc::llt62::SunOS;
@Proc::llt62::SunOS::ISA = qw(Proc::llt62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc2.d/S70llt';
    $proc->{smf_manifest}='/var/svc/manifest/system/llt.xml';
    $proc->{initconf}='/etc/default/llt';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("llt not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("llt loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_lltconfig 2> /dev/null|_cmd_grep 'LLT is running'");
    if ($rtn=~ /LLT is running/m) {
        Msg::log("LLT configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("LLT loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 0 if ($state =~ /stop/m);
    }
    # starting, need to configure
    return 0;
}

sub start_sys {
    my ($proc,$sys)=@_;
    my $cmdoutput;
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/llt');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/llt');
        }
        $sys->cmd('_cmd_svcadm enable system/llt');
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
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/llt');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/llt');
            $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
        }
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
    }
    return 0 if (EDR::cmdexit());
    return 1;
}

package Proc::llt62::Sol10sparc;
@Proc::llt62::Sol10sparc::ISA = qw(Proc::llt62::SunOS);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc2.d/S70llt';
    $proc->{smf_manifest}='/var/svc/manifest/system/llt.xml';
    $proc->{initconf}='/etc/default/llt';
    $proc->{driver_config} = <<'SOL10_LLT_CONFIG';
/usr/sbin/add_drv -v -f -m '* 0600 root sys' llt
svccfg import /var/svc/manifest/system/llt.xml
SOL10_LLT_CONFIG
    $proc->{driver_unconfig} = <<'SOL10_LLT_UNCONFIG';
svcadm disable -s system/llt
svccfg delete -f system/llt
rem_drv llt
SOL10_LLT_UNCONFIG
    return;
}

package Proc::llt62::Sol11sparc;
@Proc::llt62::Sol11sparc::ISA = qw(Proc::llt62::SunOS);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc2.d/S70llt';
    $proc->{smf_manifest}='/var/svc/manifest/system/llt.xml';
    $proc->{initconf}='/etc/default/llt';
    $proc->{driver_config} = <<'SOL11_LLT_CONFIG';
/usr/sbin/add_drv -v -f -m '* 0600 root sys' llt
svccfg -s system/llt delcust
svcadm disable system/llt
svcadm enable system/llt
SOL11_LLT_CONFIG
    $proc->{driver_unconfig} = <<'SOL11_LLT_CONFIG';
svcadm disable -s system/llt
svccfg delete -f system/llt
rem_drv llt
modinfo | grep -w llt | awk '{print $1}' |xargs -i modunload -i {}
SOL11_LLT_CONFIG
    return;
}

1;
