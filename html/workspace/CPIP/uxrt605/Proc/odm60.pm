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

package Proc::odm60::Common;
@Proc::odm60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='odm';
    $proc->{name}='odm name';
    $proc->{desc}='odm description';
    $proc->{fatal}=1;
    $proc->{start_period}=20;
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($mod,$prod,$rtn,$vxodmd,$cprod);
    $cprod=CPIC::get('prod');
    $prod=$proc->prod($cprod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("odm not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("odm loaded on sys $sys->{sys}");
    }
    if (($state =~ /start/m) && ($prod->{prod} =~ /^(SFRAC|SVS|SFCFS|SFCFSHA)$/mx)) {
        $vxodmd=$sys->cmd('_cmd_gabconfig -a 2>/dev/null');
        return ($vxodmd !~ /Port d/m) ? 0 : 1;
    }
    $rtn=$sys->cmd("_cmd_mount 2> /dev/null | _cmd_grep -w '/dev/odm'");
    if ($rtn ne '') {
        Msg::log("odm configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("odm loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    # starting, need to configure
    return 0;
}


sub start_failed_sys {
    my ($proc,$sys) = @_;
    my ($lic,$prod);

    $prod=CPIC::get('prod');
    $prod=~s/\d+$//m;
    if ($prod =~ /^(SFCFS|SFCFSHA)$/mx) {
        # Check 'CFSODM' for SFCFS/SFCFSHA
        $lic='CFSODM';
        Msg::log("## Check license bit '$lic' needed for odm starting for $prod:");
        $sys->cmd("/opt/VRTSvlic/bin/vxlicrep -i | _cmd_grep '$lic' 2>&1");
        if (EDR::cmdexit()) {
            Msg::log("license bit '$lic' is not enabled, odm failed to start.");
        }
    } elsif ($prod =~ /^(SFRAC|SVS)$/mx) {
        # Check 'VXCFS#VERITAS File System' for SFRAC/SVS
        $lic='VXCFS#VERITAS File System';
        Msg::log("## Check license bit '$lic' needed for odm starting for $prod:");
        $sys->cmd("/opt/VRTSvlic/bin/vxlicrep -i | _cmd_grep '$lic' 2>&1");
        if (EDR::cmdexit()) {
            Msg::log("license bit '$lic' is not enabled, odm failed to start.");
        }
    }

    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef 2>/dev/null');
    return;
}

package Proc::odm60::AIX;
@Proc::odm60::AIX::ISA = qw(Proc::odm60::Common);

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($prod,$odmconf1,$odmconf2,$rtn);
    $prod=CPIC::get('prod');
    $prod=~s/\d+$//m;
    $rtn=$sys->cmd("/etc/methods/vxkextadm vxodm status 2>/dev/null | _cmd_grep 'is not loaded'");
    if ($rtn) {
        Msg::log("odm not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("odm loaded on sys $sys->{sys}");
    }
    if (($state =~ /start/m) && ($prod =~ /^(SFRAC|SVS|SFCFS|SFCFSHA)$/mx)) {
        $odmconf1=$sys->cmd('_cmd_gabconfig -a 2> /dev/null');
        $odmconf2=$sys->cmd("_cmd_mount 2>/dev/null | _cmd_grep -w '/dev/odm'");
        return (($odmconf1 !~ /Port d/m) || ($odmconf2 eq '')) ? 0 : 1;
    }
    $rtn=$sys->cmd("_cmd_mount 2>/dev/null | _cmd_grep -w '/dev/odm'");
    if ($rtn ne '') {
        Msg::log("odm configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("odm loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    # starting, need to configure
    return 0;
}

sub start_sys {
    my ($proc,$sys)=@_;
    # if /dev/odm is already mounted, unmount it first.
    if ($sys->cmd("_cmd_mount 2>/dev/null | _cmd_grep -w '/dev/odm'")) {
        $sys->cmd('/etc/rc.d/rc2.d/S99odm stop 2>/dev/null');
        $sys->cmd('_cmd_umount /dev/odm') if (EDR::cmdexit());
        $sys->cmd('/etc/methods/vxkextadm vxodm unload 2> /dev/null');
    }
    $sys->cmd('/etc/methods/vxkextadm vxodm load 2> /dev/null');
    $sys->cmd('/etc/rc.d/rc2.d/S99odm start 2>/dev/null');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/rc.d/rc2.d/S99odm stop 2>/dev/null');
    $sys->cmd('_cmd_umount /dev/odm') if (EDR::cmdexit());
    $sys->cmd('/etc/methods/vxkextadm vxodm unload 2> /dev/null');
    return 1;
}

package Proc::odm60::HPUX;
@Proc::odm60::HPUX::ISA = qw(Proc::odm60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/odm start 2>/dev/null');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/odm stop 2>/dev/null');
    return 1;
}

package Proc::odm60::Linux;
@Proc::odm60::Linux::ISA = qw(Proc::odm60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{proc}='vxodm';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxodm restart 2>/dev/null');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxodm stop 2>/dev/null');
    if (!EDR::cmdexit()) {
        if ($sys->padv->driver_sys($sys, $proc->{proc})) {
            Msg::log('Unloading vxodm');
            $sys->padv->unload_driver_sys($sys, $proc->{proc});
        } else {
            Msg::log('vxodm already unloaded');
        }
    } else {
            Msg::log('Failed to stop ODM');
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($odmconf,$prod,$mod,$modid);
    $prod=CPIC::get('prod');
    $prod=~s/\d+$//m;

    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("odm not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("odm loaded on sys $sys->{sys}");
    }
    # For SFRAC, port 'd' is the indication
    # that ODM has started successfully.
    if ($prod =~ /^(SFRAC|SVS|SFCFS|SFCFSHA)$/mx) {
    if ($state =~ /start/m) {
            $odmconf=$sys->cmd('_cmd_gabconfig -a 2> /dev/null');
            Msg::log("## gabconfig -a output: \n $odmconf \n");
            $odmconf = $sys->cmd("_cmd_gabconfig -a 2> /dev/null | _cmd_grep 'Port d'");
            return ($odmconf eq '') ? 0 : 1;
    } elsif ($state =~ /stop/m) {
            $modid = $sys->cmd("_cmd_lsmod 2>/dev/null | _cmd_grep 'vxodm'");
        return 1 if ($modid);
    }
    }
    # For DBED, there is no port 'd' (Standalone mode).
    # Check if /dev/odm is mounted or not.
    $odmconf = $sys->cmd("/etc/init.d/vxodm status 2>/dev/null | _cmd_grep 'is stopped'");
    if ($odmconf eq '') {
        Msg::log("odm started on $sys->{sys}");
        return 1;
    } else {
        Msg::log("odm loaded not started on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    return 0;
}

package Proc::odm60::SunOS;
@Proc::odm60::SunOS::ISA = qw(Proc::odm60::Common);

sub init_plat {
    my ($proc,$sys)=@_;
    $proc->{controlfile}='/etc/rc2.d/S92odm';
    $proc->{smf_manifest}='/var/svc/manifest/system/vxodm/odm.xml';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -s system/vxodm 2>/dev/null');
        $sys->cmd('_cmd_svcadm enable system/vxodm 2>/dev/null');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} restart 2>/dev/null");
    } else {
        return 0;
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vxodm 2>/dev/null');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop 2>/dev/null");
    }

    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

1;
