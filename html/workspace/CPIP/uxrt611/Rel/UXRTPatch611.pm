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

######################## Patch VRTSvxvm definitions ########################

package Patch::VRTSvxvm::Common;
@Patch::VRTSvxvm::Common::ISA = qw(Patch);

sub init_common {
    my $patch=shift;
    $patch->{vminstall}="/tmp/.cpivminstall";
    return;
}

# touch this file to inform VM native scripts that it is a CPI installation
# VM native scripts will skip the checks for encapsulated and mirrored bootdisk
# if it is a CPI installation
sub preinstall_sys {
    my ($patch,$sys)=@_;
    $sys->cmd("_cmd_rmr $patch->{vminstall} 2>/dev/null");
    $sys->cmd("_cmd_touch $patch->{vminstall} 2>/dev/null") if ($sys->{encap});

    my $vm=$sys->prod("VM61");
    if ((Cfg::opt("nostart")) && (!$sys->exists($vm->{mkdbfile}))) {
        $sys->createfile($vm->{mkdbfile});
        $sys->{cpi_mkdbfile}=1;
        $sys->set_value('cpi_mkdbfile',1);
    }

    return;
}

sub postinstall_sys {
    my ($patch,$sys)=@_;
    $sys->cmd("_cmd_rmr $patch->{vminstall} 2>/dev/null");

    my $vm=$sys->prod("VM61");
    if ((Cfg::opt("nostart")) && ($sys->{cpi_mkdbfile}) && $sys->exists($vm->{mkdbfile})) {
        $sys->rm($vm->{mkdbfile});
    }
    return;
}

package Patch::VRTSvxvm_6_1_1_0::Linux;
@Patch::VRTSvxvm_6_1_1_0::Linux::ISA = qw(Patch::VRTSvxvm::Common);

package Patch::150717_05::SolSparc;
@Patch::150717_05::SolSparc::ISA = qw(Patch::VRTSvxvm::Common);

#e3379438:reload driver in patch install
package Patch::VRTSvxvm_6_1_1_0::Sol11sparc;
@Patch::VRTSvxvm_6_1_1_0::Sol11sparc::ISA = qw(Patch::VRTSvxvm::Common);

sub preinstall_sys {
    my ($patch, $sys)=@_;
    my $proc;
    $patch->SUPER::preinstall_sys($sys);
    return 0 if (Cfg::opt('rootpath'));
    for my $proci (qw/vxspec61 vxio61 vxdmp61/) {
        $proc = $sys->proc($proci);
        $proc->stop_sys($sys);
    }
    return;
}

sub postinstall_sys {
    my ($patch,$sys)=@_;
    my ($proc,$rootpath);
    $patch->SUPER::postinstall_sys($sys);
    if (Cfg::opt('rootpath')) {
        $rootpath = Cfg::opt('rootpath');
        $sys->cmd("_cmd_rmr $rootpath/etc/vx/reconfig.d/state.d/.vxvm-configured 2>/dev/null");
        $sys->cmd("_cmd_touch $rootpath/var/svc/profile/upgrade.cpibak;_cmd_echo 'svcadm enable vxvm-configure'>> $rootpath/var/svc/profile/upgrade.cpibak; _cmd_echo 'cp -f /etc/system.cpibak /etc/system' >> $rootpath/var/svc/profile/upgrade.cpibak; _cmd_cat /var/svc/profile/upgrade >>/var/svc/profile/upgrade.cpibak 2>/dev/null;_cmd_mv $rootpath/var/svc/profile/upgrade.cpibak $rootpath/var/svc/profile/upgrade 2>/dev/null");
    } else {
        for my $proci (qw/vxdmp61 vxio61 vxspec61/) {
            $proc = $sys->proc($proci);
            $proc->start_sys($sys);
        }
    }
    return;
}

package Patch::VRTSvxvm_6_1_1_0::AIX;
@Patch::VRTSvxvm_6_1_1_0::AIX::ISA = qw(Patch::VRTSvxvm::Common);

sub init_plat {
    my $patch=shift;
    # e3528526:export vxvm_dmp_vscsi_enable for vxvm patch
    $patch->{has_install_export_cmd} = 1;
    return;
}

sub postremove_sys {
    my ($patch,$sys)=@_;
    my ($bootdisk,$bos_out,$edr, $root_major_number, $dmp_major, $root_major,$msg);
    $edr=Obj::edr();
    Msg::log("Reloading VRTSvxvm drivers ");
    $sys->cmd('/usr/lib/methods/cfgvxdmp 2>/dev/null');
    $sys->cmd('/usr/lib/methods/cfgvxio 2>/dev/null');
    $sys->cmd('/usr/lib/methods/cfgvxspec 2>/dev/null');

    Msg::log("Checking Patch Reboot Support");
    $bootdisk=$sys->cmd('/usr/sbin/bootinfo -b');
    $root_major_number=$sys->cmd("/usr/bin/ls -l /dev/$bootdisk | _cmd_awk '{print \$5}' | _cmd_sed 's/,//g'");
    $dmp_major=$sys->cmd("/usr/bin/odmget -q 'resource = ddins and value1 like vxdmp' CuDvDr | _cmd_grep value2 | _cmd_awk -F= '{print \$2}'");
    Msg::log("Bootdisk is $bootdisk; Root major number is $root_major_number; And DMP major number is $dmp_major");
    $dmp_major=~s/\"//g;
    if($root_major_number == $dmp_major) {
        $bos_out=$sys->cmd("bosboot -ad /dev/$bootdisk 2>&1");
        if($edr->{cmdexit} == 0){
            Msg::log("Setting $sys->{sys} require reboot");
            $sys->set_value("requirerebootpkgs", "push", $patch->{patchname});
        } else {
            $msg=Msg::new("The command bosboot is failed on $sys->{sys}. It is recommended to run bosboot -ad /dev/$bootdisk manually");
            $sys->push_error($msg);
        }
    }
    return 1;
}


######################## Patch VRTSglm definitions ########################

package Patch::VRTSglm_6_1_1_0::Sol11sparc;
@Patch::VRTSglm_6_1_1_0::Sol11sparc::ISA = qw(Patch);

sub preinstall_sys {
    my ($patch, $sys)=@_;
    my ($proc,$rootpath,$osupdatelevel,$sru_level);
    $rootpath = Cfg::opt('rootpath');
    if ($rootpath) {
        $osupdatelevel=$sys->padv->osupdatelevel_sys($sys);
        $sru_level=$sys->padv->sru_version_sys($sys);
        if ($osupdatelevel==1 && $sru_level >= 11) {
            $sys->cmd("_cmd_rmdrv -b $rootpath vxglm 2> /dev/null");
        }
    } else {
        $proc = $sys->proc('vxglm61');
        $proc->stop_sys($sys);
    }
    return;
}

sub postinstall_sys {
    my ($patch,$sys)=@_;
    my ($rootpath,$osupdatelevel,$sru_level);
    $rootpath = Cfg::opt('rootpath');
    if ($rootpath) {
        $osupdatelevel=$sys->padv->osupdatelevel_sys($sys);
        $sru_level=$sys->padv->sru_version_sys($sys);
        if ($osupdatelevel==1 && $sru_level >= 11) {
            $sys->cmd("_cmd_adddrv -b $rootpath -f -m '* 0640 root sys' vxglm 2> /dev/null");
        }
    } else {
        $sys->cmd("_cmd_adddrv -f -m '* 0640 root sys' vxglm 2>/dev/null;_cmd_modload -p drv/vxglm 2>/dev/null");    
    }
    return;
}

######################## Patch VRTSgms definitions ########################

package Patch::VRTSgms_6_1_1_0::Sol11sparc;
@Patch::VRTSgms_6_1_1_0::Sol11sparc::ISA = qw(Patch);

sub preinstall_sys {
    my ($patch, $sys)=@_;
    my ($proc,$rootpath,$osupdatelevel,$sru_level);
    $rootpath = (Cfg::opt('rootpath'));
    if ($rootpath) {
        $osupdatelevel=$sys->padv->osupdatelevel_sys($sys);
        $sru_level=$sys->padv->sru_version_sys($sys);
        if ($osupdatelevel==1 && $sru_level >= 11) {
            $sys->cmd("_cmd_rmdrv -b $rootpath vxgms 2> /dev/null");
        }
    } else {
        $proc = $sys->proc('vxgms61');
        $proc->stop_sys($sys);
    }
    return;
}

sub postinstall_sys {
    my ($patch,$sys)=@_;
    my ($rootpath,$osupdatelevel,$sru_level);
    $rootpath = (Cfg::opt('rootpath'));
    if ($rootpath) {
        $osupdatelevel=$sys->padv->osupdatelevel_sys($sys);
        $sru_level=$sys->padv->sru_version_sys($sys);
        if ($osupdatelevel==1 && $sru_level >= 11) {
            $sys->cmd("_cmd_adddrv -b $rootpath -f -m '* 0640 root sys' vxgms 2> /dev/null");
        }
    } else {
        $sys->cmd("_cmd_adddrv -f -m '* 0640 root sys' vxgms 2>/dev/null;_cmd_modload -p drv/vxgms 2>/dev/null");
    }
    return;
}


######################## Patch VRTSvxfs definitions ########################

#e3379438:reload driver in patch install
package Patch::VRTSvxfs_6_1_1_0::Sol11sparc;
@Patch::VRTSvxfs_6_1_1_0::Sol11sparc::ISA = qw(Patch);

sub preinstall_sys {
    my ($patch, $sys)=@_;
    my $proc;
    return 0 if (Cfg::opt('rootpath'));
    for my $proci (qw/fdd61 vxportal61 vxfs61/) {
        $proc = $sys->proc($proci);
        $proc->stop_sys($sys);
    }
    return;
}

sub postinstall_sys {
    my ($patch,$sys)=@_;
    my $proc;
    return 0 if (Cfg::opt('rootpath'));
    for my $proci (qw/vxportal61 fdd61/) {
        $proc = $sys->proc($proci);
        $proc->start_sys($sys);
    }
    return;
}

package Patch::VRTSdbed_6_1_1_0::Linux;
@Patch::VRTSdbed_6_1_1_0::Linux::ISA = qw(Patch);

sub init_plat {
    my $patch=shift;
    # e2986137:do not run preuninstall script on upgrade
    $patch->{nopreun} = 1;
    return;
}

######################## Patch VRTSvxfen definitions ########################

package Patch::VRTSvxfen_6_1_1_0::AIX;
@Patch::VRTSvxfen_6_1_1_0::AIX::ISA = qw(Patch);

# vxfend driver is not loaded after patch remove.
# Hence make this workaround to start vxfend after VRTSvxfen patch get removed on AIX
sub postremove_sys {
    my ($patch,$sys)=@_;
    Msg::log("Loading vxfend driver.");
    $sys->cmd("/etc/methods/vxfenext -start -dvxfend 2> /dev/null");
    return;
}

1;
