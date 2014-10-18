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
    return;
}

sub postinstall_sys {
    my ($patch,$sys)=@_;
    $sys->cmd("_cmd_rmr $patch->{vminstall} 2>/dev/null");
    return;
}

package Patch::147854_02::Solx64;
@Patch::147854_02::Solx64::ISA = qw(Patch::VRTSvxvm::Common);

package Patch::147853_02::SolSparc;
@Patch::147853_02::SolSparc::ISA = qw(Patch::VRTSvxvm::Common);

######################## Patch VRTSvxvm definitions ########################

package Patch::VRTSvxvm_6_0_001_0::AIX;
@Patch::VRTSvxvm_6_0_001_0::AIX::ISA = qw(Patch);

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

1;
