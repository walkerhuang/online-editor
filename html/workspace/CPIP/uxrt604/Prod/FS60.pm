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

package Prod::FS60::Common;
@Prod::FS60::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{prod}='FS';
    $prod->{abbr}='FS';
    $prod->{vers}='6.0.400.000';
    $prod->{name}=Msg::new("Veritas File System")->{msg};
    $prod->{proddir}='file_system';
    $prod->{eula}='EULA_SF_Ux_6.0.1.pdf';
    $prod->{mainpkg}='VRTSvxfs60';

    $prod->{responsefileupgradeok}=1;
    $prod->{supported_vxfs_version_msg}=Msg::new("7")->{msg};
    $prod->{deprecated_vxfs_version}=6;
    $prod->{eol_vxfs_version}=5;
    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv) ];
    $prod->{lic_names}=['Veritas File System'];
    return;
}

sub description {
    my $msg;

    $msg=Msg::new("Veritas File System is a powerful, quick-recovery, journaling file system that provides the high performance, and easy management required by mission critical applications. It delivers scalable performance, and provides continuous availability, increased I/O, and up-to-date structural integrity.");
    $msg->print;
    return;
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);
    $cpic = Obj::cpic();
    $rel = $cpic->rel;
    return $rel->prod_licensed_sys($sys);
}

sub check_config {
    return 1;
}

sub rollback_precheck_sys {
    my ($prod,$sys)=(@_);
    my ($msg,$mps_ref,$mps,$mnt);
    if (Cfg::opt('upgrade_kernelpkgs')) {
        $mps_ref=$prod->mounted_vxfs_notvcs_sys($sys);
        if(@$mps_ref) {
            $mps = join ', ', @$mps_ref;
            $msg=Msg::new("Some VxFS file systems NOT under VCS control are mounted on mount points $mps on node $sys->{sys} and need to be unmounted before rolling upgrade.");
            $sys->push_error($msg);
        }
    } else {
        $prod->check_vxfs_sys($sys,'rollback') unless(Cfg::opt('upgrade_nonkernelpkgs'));
    }
    return '';

}

# Function: mounted_vxfs_blockdevice_sys()
# Determines if any VxFS File System is currently mounted on a host.
# Return a reference to an array to contain vxfs mount points

sub mounted_vxfs_blockdevice_sys {
    my ($prod,$sys) = @_;
    my (@block_devices,$item,$rtn);

    $rtn = $sys->cmd("_cmd_mount -v | _cmd_grep 'type vxfs'");
    for my $item (split(/\n/, $rtn)) {
        if ($item=~/^$prod->{mount_pattern}/mx) {
            push (@block_devices, $1);
        }
    }

    return \@block_devices;
}

#
# Function: fstab_vxfs_blockdevice_sys()
# Determines if any VxFS File System is configured in fstab.
# Return a reference to an array to contain vxfs block devices.

sub fstab_vxfs_blockdevice_sys {
    my ($prod,$sys) = @_;
    my (@block_devices,$item,$rtn,$vxfs,$bd,$mp);

    $rtn = $sys->cmd("_cmd_grep vxfs $prod->{fstab}");
    for my $item (split(/\n/, $rtn)) {
        next if ($item =~ /^#/m);
        if ($item=~/^$prod->{fstab_pattern}/mx) {
            push (@block_devices, $1);
        }
    }

    return \@block_devices;
}

sub fstab_all_blockdevice_sys {
    my ($prod,$sys) = @_;
    my (@block_devices,$item,$rtn,$vxfs,$bd,$mp);

    $rtn = $sys->cmd("_cmd_cat $prod->{fstab}");
    for my $item (split(/\n/, $rtn)) {
        next if ($item =~ /^#/m);
        if ($item=~/^$prod->{fstab_pattern}/mx) {
            push (@block_devices, $1);
        }
    }

    return \@block_devices;
}

#
# Function: eol_disk_layout_sys()
# Determines if host has any VxFS FileSystem with EOLed Disk Layouts 1-5.
# Returns a hash for all the EOLed VxFS.
# The key is the Block Device and the value is the Disk Layout version.
#
sub eol_disk_layout_sys {
    my ($prod,$sys) = @_;
    my ($fstype,$msg,$block_devices,%eolfs,%depfs,$version,$bd);
    my $vcs = $prod->prod('VCS60');

    my $mounted_bds = $prod->mounted_vxfs_blockdevice_sys($sys);
    my $fstab_bds = $prod->fstab_vxfs_blockdevice_sys($sys);
    my $res_bds = $vcs->mount_res_sys($sys);

    $block_devices = EDRu::arruniq(@{$mounted_bds},@{$fstab_bds},@{$res_bds});

    for my $bd (@{$block_devices}) {
        if ($sys->exists($bd)) {
            $fstype = $sys->cmd("_cmd_fstyp -v $bd 2>/dev/null | _cmd_grep version ");
            #if ($fstype =~ /^\s*\S+\s*\S+\s*version\s*(\d+)/) {
            if ($fstype =~ /^$prod->{fstyp_pattern}/mx) {
                $version = $1;
                if ($version <= $prod->{eol_vxfs_version}) {
                    $eolfs{$bd}=$version;
                } elsif (($version == $prod->{deprecated_vxfs_version}) && !($sys->hpux())) {
                    $depfs{$bd}=$version;
                }
            }
        }
    }
    if (keys %eolfs) {
        my ($block_device_version_map, @block_device_version_map);
        my $format = '%-30s - %-11s';
        my $msg_bd = Msg::new("Block Device")->{msg};
        my $msg_vv = Msg::new("VxFS Version")->{msg};
        push(@block_device_version_map, Msg::string_sprintf($format, $msg_bd, $msg_vv));
        for my $block_device (keys %eolfs) {
            push(@block_device_version_map, Msg::string_sprintf($format, $block_device, $eolfs{$block_device}));
        }
        $block_device_version_map = join("\n", @block_device_version_map);
        $msg=Msg::new("Warning: The following VxFS file systems with unsupported disk layout version are present on the system '$sys->{sys}'.\n$block_device_version_map");
        $sys->push_warning($msg);
    }
    if (keys %depfs) {
        my ($block_device_version_map, @block_device_version_map);
        my $format = '%-30s - %-11s';
        my $msg_bd = Msg::new("Block Device")->{msg};
        my $msg_vv = Msg::new("VxFS Version")->{msg};
        push(@block_device_version_map, Msg::string_sprintf($format, $msg_bd, $msg_vv));
        for my $block_device (keys %depfs) {
            push(@block_device_version_map, Msg::string_sprintf($format, $block_device, $depfs{$block_device}));
        }
        $block_device_version_map = join("\n", @block_device_version_map);
        $msg=Msg::new("Warning: The following VxFS file systems with deprecated disk layout version are present on the system '$sys->{sys}'.\n$block_device_version_map");
        $sys->push_warning($msg);
    }
    if (keys %eolfs || keys %depfs) {
        $msg=Msg::new("Use the vxupgrade command to upgrade mounted file systems, or the vxfsconvert command to upgrade unmounted file systems. See the Veritas Storage Foundation Installation Guide for more information on upgrading VxFS disk layout versions.");
        $sys->push_warning($msg);
        $msg=Msg::new("If you decide to continue without upgrading your disk layout to version $prod->{supported_vxfs_version_msg} or above, for files systems with unsupported disk layout version, you will be unable to mount them after upgrade and you will have to perform an offline upgrade using vxfsconvert command before you can use them. For file systems with deprecated disk layout version, you can only mount them locally after upgrade and you can use vxupgrade command to upgrade the disk layout version.");
        $sys->push_warning($msg);
    } elsif ($prod->{fstab}) {
        $msg=Msg::new("Notice: This version of VxFS supports only disk layout version $prod->{supported_vxfs_version_msg} and above. Disk layout version $prod->{deprecated_vxfs_version} is deprecated and you can only mount it locally after upgrade. Only the VxFS file systems in the $prod->{fstab} file and mounted VxFS file systems were checked. If you have any VxFS file systems that are using unsupported or deprecated disk layout version, upgrade them to disk layout Version $prod->{supported_vxfs_version_msg} or above and restart the VxFS installation.");
        $sys->push_note($msg);
        $msg=Msg::new("Use the vxupgrade(1M) command to upgrade mounted file systems, or the vxfsconvert(1M) command to upgrade unmounted file systems. Use the fstyp -v command to determine the VxFS file system version. See the Veritas Storage Foundation Installation Guide for more information on upgrading VxFS disk layout versions.");
        $sys->push_note($msg);
    }
    return;
}

sub stop_precheck_sys {
    my ($prod,$sys) = @_;
    my ($msg,$mps,$mps_ref);
    $mps_ref = $prod->mounted_vxfs_sys($sys);
    if (@$mps_ref) {
        $mps = join ', ', @$mps_ref;
        $msg=Msg::new("Some VxFS file systems are mounted on mount points $mps on node $sys->{sys} and need to be unmounted before stop.");
        $sys->push_error($msg);
    }
    return '';
}

# For rolling upgrade, give warnning message that if some VxFS file system are mounted
sub patchupgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($msg,$mnt,$mps,$mps_ref);
    if (Cfg::opt('upgrade_kernelpkgs')) {
        $mps_ref=$prod->mounted_vxfs_notvcs_sys($sys);
        if(@$mps_ref) {
            $mps = join ', ', @$mps_ref;
            $msg=Msg::new("Some VxFS file systems NOT under VCS control are mounted on mount points $mps on node $sys->{sys} and need to be unmounted before rolling upgrade.");
            $sys->push_error($msg);
        }
    } else {
        $prod->check_vxfs_sys($sys,'upgrade') unless(Cfg::opt('upgrade_nonkernelpkgs'));
    }
    return '';
}

# For rolling upgrade, check mounted file system Not under VCS control
# Before rolling upgrade phase-1, the file system must be unmounted manually
sub mounted_vxfs_notvcs_sys {
    my ($prod,$sys) = @_;
    my ($cprod,$rel,$msg,$vcs,$mnt,@mnts,$mps,$ret,$mps_ref);
    $rel=$prod->rel();

    $cprod=CPIC::get('prod');
    $mps_ref = $prod->mounted_vxfs_sys($sys);
    return $mps_ref unless(EDRu::inarr($cprod,@{$rel->{ru_prod}}));
    $vcs=$prod->prod('VCS60');
    $ret=$sys->cmd("_cmd_cat $vcs->{maincf} 2>/dev/null");
    for my $mnt (@$mps_ref) {
        $mnt=~s/\s//mg;
        push(@mnts,$mnt) unless($ret=~/\"$mnt\/?\"/m);
    }
    return \@mnts;
}

# For patchupgrade_precheck,upgrade_precheck and uninstall_precheck need to check mounted vxfs filesystem
sub check_vxfs_sys {
    my ($prod,$sys,$action) = @_;
    my ($msg,$mps,$cpic,$ret,$mps_ref,$pkg,$rc);

    $mps_ref = $prod->mounted_vxfs_sys($sys);
    if (@$mps_ref) {
        # if any mounted VxFS file system, check whether any zones mounted on these VxFS file systems.
        if ($sys->sunos()) {
            $rc = $prod->vxfs_vxvm_zone_check_sys($sys);
            if ($rc == 2 || $rc == 3) {
                if (!$sys->{vxfs_vxvm_zone_check_done}) {
                    $pkg=$sys->pkg('VRTSvxvm60');
                    $pkg->set_value('stopprocs',undef);
                    $pkg=$sys->pkg('VRTSvxfs60');
                    $pkg->set_value('stopprocs',undef);
                    $sys->set_value('reboot', 1);
                    $prod->show_warning_zones_on_vxfs_sys($sys, $action) if ($rc==2);
                    $prod->show_warning_zones_on_vxvm_sys($sys, $action) if ($rc==3);
                }
                # do not show errors for mounted file systems.
                @$mps_ref = ();
            } elsif ($rc == 1) {
                if (!$sys->{vxfs_vxvm_zone_check_done}) {
                    # exit if zones on CFS/CVM.
                    $prod->show_error_zones_on_cfs_sys($sys, $action);
                }
                # do not show errors for mounted file systems.
                @$mps_ref = ();
            }
            $sys->set_value('vxfs_vxvm_zone_check_done',1);
        }
    }
    if (@$mps_ref) {
        $mps = join ', ', @$mps_ref;
        $action=Msg::get("task_$action");
        $msg=Msg::new("Some VxFS file systems are mounted on mount points $mps on node $sys->{sys} and need to be unmounted before $action.");
        $sys->push_error($msg);
        return 1;
    }
    return 0;
}

#
# Function: upgrade_precheck_sys()
# Display preinstallation messages and confirmations for upgrade
# before installation. Also take care of -precheck option.
# It takes care of mounted filesystems and EOLed disk layouts.
#
sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($msg,$instpv,$mps,$cvret,$ret,$mps_ref,$pkg,$rc);

    $pkg=$sys->pkg($prod->{mainpkg});
    $instpv=$pkg->version_sys($sys);
    return unless ($instpv);

    # when precheck, $pkg->{vers} is null
    if ($pkg->{vers}) {
        $cvret = EDRu::compvers($instpv, $pkg->{vers});
        return if ($cvret <= 1);
    }

    $prod->kernel_parameter_sys($sys) if ($sys->sunos());

    if (Cfg::opt('upgrade_kernelpkgs')) {
        $mps_ref=$prod->mounted_vxfs_notvcs_sys($sys);
        if(@$mps_ref) {
            $mps = join ', ', @$mps_ref;
            $msg=Msg::new("Some VxFS file systems NOT under VCS control are mounted on mount points $mps on node $sys->{sys} and need to be unmounted before rolling upgrade.");
            $sys->push_error($msg);
        }
    } else {
        $prod->check_vxfs_sys($sys,'upgrade') unless(Cfg::opt('upgrade_nonkernelpkgs'));
    }

    $prod->eol_disk_layout_sys($sys);
    return;
}

#
# Function: prestop_sys()
# Called before installing VxFS to check for upgrades.
# Also before uninstalling, it checks for mounted filesystems.
#
sub uninstall_precheck_sys {
    my ($prod,$sys) = @_;
    my ($msg,$mps,$ret,$mps_ref,$pkg,$rc);
    $prod->check_vxfs_sys($sys,'uninstall');
    return '';
}

sub stopprocs {
    my $prod=shift;
    my $ref_procs;
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $prod->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my $ref_procs;
    $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my $ref_procs;
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'start');
    return $ref_procs;
}

sub verify_procs_list {
    my ($prod,$procs,$state)=@_;
    if ((defined $state && $state eq 'stop') && (EDRu::inarr('vxsvc34', @{$procs}))) {
        $procs=EDRu::arrdel($procs, 'vxsvc34');
        unshift(@{$procs}, 'vxsvc34');
    }
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure'))) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    return $procs;
}

sub verify_procs_list_sys {
    my ($prod,$sys,$procs,$state)=@_;
    my $vm = $sys->prod('VM60');
    # adjust vxsvc process
    $procs = $vm->adjust_vxsvc_for_procs_sys($sys,$procs,$state);
    # adjust sfmh-discovery process
    $procs = $vm->adjust_sfmh_for_procs_sys($sys,$procs,$state);
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure'))) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    return $procs;
}

sub is_tunefs_tunable{
    my ($prod,$tunable) =@_;
    if ( EDRu::inarr($tunable, qw /read_ahead max_diskq read_pref_io read_nstream write_pref_io write_nstream/)) {
        return 1;
    }
    return 0;
}

sub get_tunefs_tunable_value_sys{
    my ($prod,$sys,$tunable) =@_;
    my ($origval);
    $origval = $sys->cmd("_cmd_grep '^system_default $tunable=' /etc/vx/tunefstab 2>/dev/null |_cmd_tail -1");
    if ( $origval ) {
        chomp $origval;
        $origval =~ s/^system_default $tunable=//;
    }
    return $origval;
}

sub set_tunefs_tunable_value_sys{
    my ($prod,$sys,$tunable,$value) =@_;
    my ($cpic, $file, @lines, @newlines, $tunable_info);
    $cpic= Obj::cpic();
    if ($sys->exists('/etc/vx/tunefstab')) {
        $file = $sys->readfile('/etc/vx/tunefstab');
        @lines = split (/\n/,$file);
        @newlines = ();
        for my $line (@lines) {
            if ($line !~ /^system_default $tunable=/ ) {
                push @newlines, $line;
            }
        }
        $file = join("\n", @newlines);
    } else {
        $file = '';
    }
    $sys->writefile($file, '/etc/vx/tunefstab');

    $tunable_info=$cpic->get_tunable_info($tunable);
    if ($value != 0 || !$tunable_info->{zero_to_reset}) {
        $sys->appendfile("\nsystem_default $tunable=$value\n", '/etc/vx/tunefstab');
    }
    $file = $sys->readfile('/etc/vx/tunefstab');
    return (0,$file);
}

sub postcheck_fs_mounted_sys {
    my ($prod,$sys) = @_;
    my ($bd_fstab,$bd_mounted,$msg,$notmountedmsg,$notexistmsg);
    $bd_fstab = $prod->fstab_vxfs_blockdevice_sys($sys);
    $bd_mounted = $prod->mounted_vxfs_blockdevice_sys($sys);
    $notmountedmsg = '';
    $notexistmsg = '';
    for my $bd (@$bd_fstab) {
        if (!$sys->exists($bd)) {
            $notexistmsg .= "\n\t$bd";
        } elsif (!EDRu::inarr($bd, @$bd_mounted)) {
            $notmountedmsg .= "\n\t$bd";
        }
    }
    if ($notexistmsg) {
        $msg=Msg::new("The following VxFS file systems defined in $prod->{fstab} are not available on $sys->{sys}:$notexistmsg");
        $sys->push_warning($msg);
    }
    if ($notmountedmsg) {
        $msg=Msg::new("The following VxFS file systems defined in $prod->{fstab} are not mounted on $sys->{sys}:$notmountedmsg");
        $sys->push_warning($msg);
    }
    if ($notmountedmsg || $notexistmsg) {
        return 0;
    } else {
        return 1;
    }
}

sub postcheck_fs_disk_layout_sys{
    my ($prod,$sys) = @_;
    my ($bd_fstab,$bd_mounted,@bds,$msg,$disklayoutmsg,$fstype,$fsvers,$depmsg);
    $bd_fstab = $prod->fstab_vxfs_blockdevice_sys($sys);
    $bd_mounted = $prod->mounted_vxfs_blockdevice_sys($sys);
    @bds = @{EDRu::arruniq(@{$bd_fstab},@{$bd_mounted})};
    $disklayoutmsg = '';
    for my $bd (sort @bds) {
        if ($sys->exists($bd)) {
            $fstype = $sys->cmd("_cmd_fstyp -v $bd 2>/dev/null | _cmd_grep version ");
            if ($fstype =~ /^$prod->{fstyp_pattern}/mx) {
                $fsvers = $1;
                if ($fsvers <= $prod->{eol_vxfs_version}) {
                    $disklayoutmsg .= "\n\t$bd version $fsvers";
                } elsif (($fsvers == $prod->{deprecated_vxfs_version}) && !($sys->hpux())) {
                    $depmsg .= "\n\t$bd version $fsvers";
                }
            }
        }
    }
    if ($disklayoutmsg) {
        $msg=Msg::new("The following VxFS file systems with unsupported disk layout version are present on $sys->{sys}:$disklayoutmsg");
        $sys->push_warning($msg);
    }
    if ($depmsg) {
        $msg=Msg::new("The following VxFS file systems with deprecated disk layout version are present on $sys->{sys}:$depmsg");
        $sys->push_warning($msg);
    }
    if ($disklayoutmsg || $depmsg) {
        return 0;
    } else {
        return 1;
    }
}

sub register_postchecks_per_system {
    my ($prod,$sequence_id,$name,$desc,$handler);
    $prod=shift;

    $sequence_id=450;
    $name='vxfs_fstab_mounted';
    $desc=Msg::new("VxFS file systems status");
    $handler=\&postcheck_fs_mounted_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=451;
    $name='vxfs_disk_layout';
    $desc=Msg::new("VxFS file systems disk layout");
    $handler=\&postcheck_fs_disk_layout_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    return;
}

# SunOS/HPUX
sub make_vxfs_sys {
    my ($prod,$sys,$dgname,$volname) = @_;
    my ($ret,$vxloc);
    $vxloc = '/dev/vx';
    $sys->cmd("_cmd_mkfs -F vxfs -o largefiles ${vxloc}/rdsk/${dgname}/${volname}");
    $ret = EDR::cmdexit();
    return $ret;
}

package Prod::FS60::AIX;
@Prod::FS60::AIX::ISA = qw(Prod::FS60::Common);

sub init_plat {
    my $prod=shift;
    my $padv=$prod->padv();
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSveki60 VRTSvxfs60 VRTSfsadv60 VRTSfssdk60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSveki60 VRTSvxfs60 VRTSfsadv60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSveki60 VRTSvxfs60 VRTSfsadv60 VRTSsfmh41) ];
    $prod->{proddir}='storage_foundation';
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0)];
    $padv->{cmd}{vxkextadm}='/etc/methods/vxkextadm';
    $padv->{cmd}{vxcfg}='/etc/methods/vxcfg';

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSfppm VRTSap VRTStep VRTSsfmh41 VRTSfsmnd VRTSfssdk60
        VRTSfsadv60 VRTSfsdoc VRTSfsman VRTScpi.rte VRTSvsvc SYMClma VRTSspt60
        VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSob34
        VRTSobc33 VRTSat50 VRTSat.server VRTSat.client VRTSsmf
        VRTSpbx VRTSicsco VRTSvxfs60 VRTSveki60 VRTSsfcpi604 VRTSperl514
        VRTSperl.rte VRTSvlic32
    ) ];
    $prod->{fstab}='/etc/filesystems';
    $padv->{cmd}{fstyp}='/opt/VRTS/bin/fstyp';
    #$prod->{fstab_pattern}='\s*(\S+)\s+\S+\s+\S+\s+vxfs';
    $prod->{mount_pattern}='\s*(\S+)\s+\S+\s+vxfs';
    $prod->{fstyp_pattern}='\s*\S+\s+\S+\s+version\s+(\d+)';

    $prod->{tunables} = [
        {
            "name" => "vxfs_ninode",
            "desc" => Msg::new("Number of entries in the VxFS inode table")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [150, undef, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "vx_bc_bufhwm",
            "desc" => Msg::new("VxFS metadata buffer cache high water mark")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [ 6144, undef, undef ],
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "read_ahead",
            "desc" => Msg::new("Value 0 disables read ahead functionality; value 1 (default) retains traditional sequential read ahead behavior; value 2 enables enhanced read ahead for all reads. The installer can only set the system default value of read_ahead. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "enum",
            "values" => ["0", "1", "2"],
            "when_to_set" => 2,
        },
        {
            "name" => "read_pref_io",
            "desc" => Msg::new("The preferred read request size. The installer can only set the system default value of read_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "read_nstream",
            "desc" => Msg::new("The number of parallel read requests of size read_pref_io that can be outstanding at one time. The installer can only set the system default value of read_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_pref_io",
            "desc" => Msg::new("The preferred write request size. The installer can only set the system default value of write_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_nstream",
            "desc" => Msg::new("The number of parallel write requests of size write_pref_io that can be outstanding at one time. The installer can only set the system default value of write_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "max_diskq",
            "desc" => Msg::new("Specifies the maximum disk queue generated by a single file. The installer can only set the system default value of max_diskq. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [8192, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
    ];

    return;
}

#
# Function: mounted_vxfs_sys()
# Determines if any VxFS File System is currently mounted on a host.
# Return a reference to an array to contain vxfs mount points

sub mounted_vxfs_sys {
    my ($prod,$sys) = @_;
    my (@mps,$ret);

    $ret = $sys->cmd("_cmd_mount | _cmd_grep '^vxfs\$' | _cmd_awk '{print \$2}'");
    @mps = split /\s+/m, $ret;
    return \@mps;
}

#
# Function: mounted_vxfs_blockdevice_sys()
# Determines if any VxFS File System is currently mounted on a host.
# Return a reference to an array to contain vxfs mount points

sub mounted_vxfs_blockdevice_sys {
    my ($prod,$sys) = @_;
    my (@block_devices,$item,$rtn);

    $rtn = $sys->cmd("_cmd_mount | _cmd_grep 'vxfs'");
    for my $item (split(/\n/, $rtn)) {
        if ($item=~/^$prod->{mount_pattern}/mx) {
            push (@block_devices, $1);
        }
    }
    return \@block_devices;
}

#
# Function: fstab_vxfs_blockdevice_sys()
# Determines if any VxFS File System is configured in fstab.
# Return a reference to an array to contain vxfs block devices.

sub fstab_vxfs_blockdevice_sys {
    my ($prod,$sys) = @_;
    my (@block_devices,$item,$rtn,$vxfs,$bd,$mp);

    $rtn = $sys->readfile($prod->{fstab});
    for my $item (split(/\n+/,$rtn)) {
        next if ($item =~ /^\*/m);
        if ($item =~ /(\S+):/m) {
            $mp = $1;
            $vxfs = 0;
            $bd = '';
        } elsif ($item =~ /\s*vfs\s*\=\s*vxfs/mx) {
            $vxfs = 1;
            push (@block_devices, $bd) if ($mp && $bd);
        } elsif ($item =~ /\s*dev\s*\=\s*(\S+)/mx) {
            $bd = $1;
            push (@block_devices, $bd) if ($mp && $vxfs);
        }
    }
    return \@block_devices;
}

sub fstab_all_blockdevice_sys {
    my ($prod,$sys) = @_;
    my (@block_devices,$item,$rtn,$vxfs,$bd,$mp);

    $rtn = $sys->readfile($prod->{fstab});
    for my $item (split(/\n+/,$rtn)) {
        next if ($item =~ /^\*/m);
        if ($item =~ /(\S+):/m) {
            $mp = $1;
            $vxfs = 0;
            $bd = '';
        } elsif ($item =~ /\s*vfs\s*\=\s*/mx) {
            $vxfs = 1;
            push (@block_devices, $bd) if ($mp && $bd);
        } elsif ($item =~ /\s*dev\s*\=\s*(\S+)/mx) {
            $bd = $1;
            push (@block_devices, $bd) if ($mp && $vxfs);
        }
    }
    return \@block_devices;
}

sub get_tunable_value_sys{
    my ($prod,$sys,$tunable) =@_;
    my ($origval);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->get_tunefs_tunable_value_sys($sys, $tunable);
    }
    $origval = $sys->cmd("_cmd_grep '^$tunable ' /etc/vx/vxfssystem 2>/dev/null | _cmd_tail -1 | _cmd_awk '{print \$2}'");
    chomp $origval;
    return $origval;
}

sub set_tunable_value_sys{
    my ($prod,$sys,$tunable,$value) =@_;
    my ($cpic, $file, @lines, @newlines, $tunable_info, $ret);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->set_tunefs_tunable_value_sys($sys, $tunable, $value);
    }
    $cpic= Obj::cpic();
    if ($sys->exists('/etc/vx/vxfssystem')) {
        $file = $sys->readfile('/etc/vx/vxfssystem');
        @lines = split (/\n/,$file);
        @newlines = ();
        for my $line (@lines) {
            if ($line !~ /^$tunable / ) {
                push @newlines, $line;
            }
        }
        $file = join("\n", @newlines);
    } else {
        $file = '';
    }
    $sys->writefile($file, '/etc/vx/vxfssystem');

    $tunable_info=$cpic->get_tunable_info($tunable);
    if ($value != 0 || !$tunable_info->{zero_to_reset}) {
        $sys->appendfile("\n$tunable $value\n", '/etc/vx/vxfssystem');
    }
    $file = $sys->readfile('/etc/vx/vxfssystem');
    return (0,$file);
}

# AIX
sub make_vxfs_sys {
    my ($prod,$sys,$dgname,$volname) = @_;
    my ($ret,$vxloc);
    $vxloc = '/dev/vx';
    $sys->cmd("_cmd_mkfs -V vxfs -o largefiles ${vxloc}/rdsk/${dgname}/${volname}");
    $ret = EDR::cmdexit();
    return $ret;
}

package Prod::FS60::HPUX;
@Prod::FS60::HPUX::ISA = qw(Prod::FS60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfssdk60 VRTSsfmh41)];
    $prod->{minpkgs}=[ qw(VRTSvxfs60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSsfmh41) ];
    $prod->{proddir}='storage_foundation';
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1 6.0)];
    $prod->{zru_releases}=[qw()];
    $prod->{supported_vxfs_version_msg}=Msg::new("5, 7")->{msg};
    $prod->{deprecated_vxfs_version}=6;
    $prod->{eol_vxfs_version}=4;

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTStep VRTSap VRTSsfmh41 VRTSfsmnd VRTSdcli VRTSfssdk60
        VRTSfsadv60 VRTSfsdoc VRTSfsman VRTScpi VRTSvsvc SYMClma VRTSspt60
        VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSob34
        VRTSobc33 VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60
        VRTSsfcpi604 VRTSperl514 VRTSvlic32 VRTSwl
    ) ];
    my $padv=$prod->padv();
    $prod->{fstab}='/etc/fstab';
    $padv->{cmd}{fstyp}='/usr/sbin/fstyp';
    $prod->{fstab_pattern}='\s*(\S+)\s+\S+\s+vxfs';
    $prod->{mount_pattern}='\s*(\S+)\s+\S+\s+(\S+)\s+type\s+vxfs';
    $prod->{fstyp_pattern}='\s*version:\s*(\d+)';
    $prod->{tunables} = [
        {
            "name" => "vx_ninode",
            "desc" => Msg::new("Number of entries in the VxFS inode table")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [150, undef, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "vx_era_nthreads",
            "desc" => Msg::new("Maximum number of threads VxFS will detect read_ahead patterns on")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "vxfs_bc_bufhwm",
            "desc" => Msg::new("VxFS metadata buffer cache high water mark")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [ 6144, undef, undef ],
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "read_ahead",
            "desc" => Msg::new("Value 0 disables read ahead functionality; value 1 (default) retains traditional sequential read ahead behavior; value 2 enables enhanced read ahead for all reads. The installer can only set the system default value of read_ahead. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "enum",
            "values" => ["0", "1", "2"],
            "when_to_set" => 2,
        },
        {
            "name" => "read_pref_io",
            "desc" => Msg::new("The preferred read request size. The installer can only set the system default value of read_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "read_nstream",
            "desc" => Msg::new("The number of parallel read requests of size read_pref_io that can be outstanding at one time. The installer can only set the system default value of read_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_pref_io",
            "desc" => Msg::new("The preferred write request size. The installer can only set the system default value of write_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_nstream",
            "desc" => Msg::new("The number of parallel write requests of size write_pref_io that can be outstanding at one time. The installer can only set the system default value of write_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "max_diskq",
            "desc" => Msg::new("Specifies the maximum disk queue generated by a single file. The installer can only set the system default value of max_diskq. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [8192, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
    ];
    return;
}

package Prod::FS60::HPUX1131ia64;
@Prod::FS60::HPUX1131ia64::ISA = qw(Prod::FS60::HPUX);

sub init_padv {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfsadv60 VRTSfssdk60 VRTSsfmh41)];
    $prod->{minpkgs}=[ qw(VRTSvxfs60 VRTSfsadv60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfsadv60 VRTSsfmh41) ];
    return;
}

#
# Function: mounted_vxfs_sys()
# Displays a warning message to unmount all user VxFS File Systems that are currently mounted.
# Returns a reference to an empty array always.
# on HPUX, because vxfs is the default OS file system, skip checking, return always empty ref
sub mounted_vxfs_sys {
   my (@mps);
   @mps=();
   return \@mps;
}

sub get_tunable_value_sys{
    my ($prod,$sys,$tunable) =@_;
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->get_tunefs_tunable_value_sys($sys, $tunable);
    }
    my $origval = $sys->cmd("_cmd_kctune -v $tunable 2>/dev/null | _cmd_grep '^Current Value' | _cmd_awk '{print \$3}'");
    chomp $origval;
    return $origval;
}

sub set_tunable_value_sys{
    my ($prod,$sys,$tunable,$value) =@_;
    my ($out,$tunable_info,$cpic);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->set_tunefs_tunable_value_sys($sys, $tunable, $value);
    }
    $cpic=Obj::cpic();
    $tunable_info = $cpic->get_tunable_info($tunable);
    $out = $sys->cmd("_cmd_kctune $tunable=$value");
    if ( EDR::cmdexit() == 1 && $tunable_info->{reboot}) {
        return (0, $out);
    } else {
        return (EDR::cmdexit(), $out);
    }
}


package Prod::FS60::Linux;
@Prod::FS60::Linux::ISA = qw(Prod::FS60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfsadv60 VRTSfssdk60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxfs60 VRTSfsadv60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfsadv60 VRTSsfmh41) ];
    $prod->{proddir}='storage_foundation';
    $prod->{upgradevers}=[qw(5.0.30 5.1 6.0 6.0.1 6.0.3)];
    $prod->{zru_releases}=[qw(4.1.40 5.0 5.1 6.0)];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSsfmh41 VRTSdcli
        VRTSfsmnd VRTSfssdk60 VRTSfsadv60 VRTSfsdoc VRTSfsman VRTScpi VRTSvsvc
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSob34 VRTSobc33 VRTSat50 VRTSatClient50
        VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxfs-platform
        VRTSvxfs-common VRTSsfcpi604 VRTSperl514 VRTSvlic32
    ) ];
    my $padv=$prod->padv();
    $prod->{fstab}='/etc/fstab';
    $padv->{cmd}{fstyp}='/opt/VRTS/bin/fstyp';
    $prod->{fstab_pattern}='\s*(\S+)\s+\S+\s+vxfs';
    $prod->{mount_pattern}='\s*(\S+)\s+\S+\s+\S+\s+type\s+vxfs';
    $prod->{fstyp_pattern}='\s*\S+\s+\S+\s+version\s+(\d+)';

    $prod->{tunables} = [
        {
            "name" => "vxfs_ninode",
            "desc" => Msg::new("Number of entries in the VxFS inode table")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [150, 2147483647, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "vxfs_mbuf",
            "desc" => Msg::new("Maximum memory used for vxfs buffer cache")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "read_ahead",
            "desc" => Msg::new("Value 0 disables read ahead functionality; value 1 (default) retains traditional sequential read ahead behavior; value 2 enables enhanced read ahead for all reads. The installer can only set the system default value of read_ahead. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "enum",
            "values" => ["0", "1", "2"],
            "when_to_set" => 2,
        },
        {
            "name" => "read_pref_io",
            "desc" => Msg::new("The preferred read request size. The installer can only set the system default value of read_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "read_nstream",
            "desc" => Msg::new("The number of parallel read requests of size read_pref_io that can be outstanding at one time. The installer can only set the system default value of read_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_pref_io",
            "desc" => Msg::new("The preferred write request size. The installer can only set the system default value of write_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_nstream",
            "desc" => Msg::new("The number of parallel write requests of size write_pref_io that can be outstanding at one time. The installer can only set the system default value of write_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "max_diskq",
            "desc" => Msg::new("Specifies the maximum disk queue generated by a single file. The installer can only set the system default value of max_diskq. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [8192, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
    ];

    return;
}

#
# Function: mounted_vxfs_sys()
# Determines if any VxFS File System is currently mounted on a host.
# Return a reference to an array to contain vxfs mount points
#
sub mounted_vxfs_sys {
    my ($prod,$sys) = @_;
    my (@mps,$ret);

    $ret = $sys->cmd("_cmd_mount -v | _cmd_grep 'type vxfs' | _cmd_awk '{print \$3}' ");
    @mps = split /\s+/m, $ret;
    return \@mps;
}

sub get_tunable_value_sys{
    my ($prod,$sys,$tunable) =@_;
    my ($origval);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->get_tunefs_tunable_value_sys($sys, $tunable);
    }
    $origval = $sys->cmd("_cmd_grep '^options vxfs $tunable=' /etc/modprobe.conf 2>/dev/null |_cmd_tail -1");
    if ( $origval ) {
        chomp $origval;
        $origval =~ s/^options vxfs $tunable=//;
    }
    return $origval;
}

sub set_tunable_value_sys{
    my ($prod,$sys,$tunable,$value) =@_;
    my ($cpic, $file, @lines, @newlines, $tunable_info);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->set_tunefs_tunable_value_sys($sys, $tunable, $value);
    }
    $cpic= Obj::cpic();
    if ($sys->exists('/etc/modprobe.conf')) {
        $file = $sys->readfile('/etc/modprobe.conf');
        @lines = split (/\n/,$file);
        @newlines = ();
        for my $line (@lines) {
            if ($line !~ /^options vxfs $tunable=/ ) {
                push @newlines, $line;
            }
        }
        $file = join("\n", @newlines);
    } else {
        $file = '';
    }
    $sys->writefile($file, '/etc/modprobe.conf');

    $tunable_info=$cpic->get_tunable_info($tunable);
    if ($value != 0 || !$tunable_info->{zero_to_reset}) {
        $sys->appendfile("\noptions vxfs $tunable=$value\n", '/etc/modprobe.conf');
    }
    $file = $sys->readfile('/etc/modprobe.conf');
    return (0,$file);
}

# Linux
sub make_vxfs_sys {
    my ($prod,$sys,$dgname,$volname) = @_;
    my ($ret,$vxloc);
    $vxloc = '/dev/vx';
    $sys->cmd("_cmd_mkfs -t vxfs -o largefiles ${vxloc}/rdsk/${dgname}/${volname}");
    $ret = EDR::cmdexit();
    return $ret;
}

package Prod::FS60::SunOS;
@Prod::FS60::SunOS::ISA = qw(Prod::FS60::Common);

sub init_plat {
    my $prod=shift;
    my $padv=$prod->padv();
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfssdk60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxfs60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSsfmh41) ];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSsfmh41 VRTSdcli
        VRTSfsmnd VRTSfssdk60 VRTSfsadv60 VRTSfsdoc VRTSfsman VRTScpi VRTSvsvc
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSob34 VRTSobc33 VRTSat50 VRTSsmf VRTSpbx
        VRTSicsco VRTSvxfs60 VRTSsfcpi604 VRTSperl514 VRTSvlic32
    ) ];

    # The file system defaults file
    $prod->{fstab}='/etc/vfstab';
    $padv->{cmd}{fstyp}='/usr/sbin/fstyp';
    $prod->{fstab_pattern}='\s*(\S+)\s+\S+\s+\S+\s+vxfs';
    $prod->{mount_pattern}='\s*(\S+)\s+\S+\s+\S+\s+type\s+vxfs';
    $prod->{fstyp_pattern}='\s*\S+\s+\S+\s+version\s+(\d+)';

    $prod->{tunables} = [
        {
            "name" => "vxfs_ninode",
            "desc" => Msg::new("Number of entries in the VxFS inode table")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [150, undef, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "vx_era_nthreads",
            "desc" => Msg::new("Maximum number of threads VxFS will detect read_ahead patterns on")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "vx_bc_bufhwm",
            "desc" => Msg::new("VxFS metadata buffer cache high water mark")->{msg},
            "define_object" => $prod,
            "reboot" => 1,
            "type" => "range",
            "values" => [ 6144, undef, undef ],
            "when_to_set" => 2,
            "zero_to_reset" => 1,
        },
        {
            "name" => "read_ahead",
            "desc" => Msg::new("Value 0 disables read ahead functionality; value 1 (default) retains traditional sequential read ahead behavior; value 2 enables enhanced read ahead for all reads. The installer can only set the system default value of read_ahead. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "enum",
            "values" => ["0", "1", "2"],
            "when_to_set" => 2,
        },
        {
            "name" => "read_pref_io",
            "desc" => Msg::new("The preferred read request size. The installer can only set the system default value of read_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "read_nstream",
            "desc" => Msg::new("The number of parallel read requests of size read_pref_io that can be outstanding at one time. The installer can only set the system default value of read_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_pref_io",
            "desc" => Msg::new("The preferred write request size. The installer can only set the system default value of write_pref_io. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [16384, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "write_nstream",
            "desc" => Msg::new("The number of parallel write requests of size write_pref_io that can be outstanding at one time. The installer can only set the system default value of write_nstream. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [1, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
        {
            "name" => "max_diskq",
            "desc" => Msg::new("Specifies the maximum disk queue generated by a single file. The installer can only set the system default value of max_diskq. Refer to tunefstab(4) manual page for setting this tunable for specified block device")->{msg},
            "define_object" => $prod,
            "reboot" => 0,
            "type" => "range",
            "values" => [8192, undef, undef], # min, max, divisor
            "when_to_set" => 2,
        },
    ];
    return;
}

sub kernel_parameter_sys {
    my ($prod,$sys) = @_;
    my ($msg,$param,$rtn_lwp,$rtn_svc,$min_lwp,$min_svc);

    if(Cfg::opt(qw(precheck install))) {
        $param='lwp_default_stksize';
        $rtn_lwp = $sys->padv->kernelparam_sys($sys,$param);
        $min_lwp=$prod->{lwp_default_stksize} || 6000;

        $param='svc_default_stksize';
        $rtn_svc = $sys->padv->kernelparam_sys($sys,$param);
        $min_svc=$prod->{svc_default_stksize} || 6000;

        $rtn_svc=$rtn_lwp if ($rtn_svc==0);
        if ($rtn_lwp < $min_lwp || $rtn_svc < $min_svc) {
            $msg=Msg::new("To avoid a potential reboot after installation, you should modify the /etc/system file on $sys->{sys} with the appropriate values, and reboot prior to package installation.\n\nAppropriate /etc/system file entries are shown below:\n\tset lwp_default_stksize=0x${min_lwp}\n\tset rpcmod:svc_default_stksize=0x${min_svc}");
            $sys->push_warning($msg);
        }
    }
    return 1;
}

sub install_precheck_sys {
    my ($prod,$sys)= @_;
    $prod->kernel_parameter_sys($sys);
    return;
}

# Function: mounted_vxfs_sys()
# Determines if any VxFS File System is currently mounted on a host.
# Return a reference to an array to contain vxfs mount points
#
sub mounted_vxfs_sys {
    my ($prod,$sys)= @_;
    my ($ret,@mps);

    # skip mounted vxfs checking if alt root disk upgrade
    if (Cfg::opt('rootpath')) {
        Msg::log("Checking $sys->{sys} for mounted vxfs file systems is skipped for Solaris alternate root disk installation");
        return \@mps;
    }

    $ret = $sys->cmd("_cmd_mount -v | _cmd_grep 'type vxfs' | _cmd_awk '{print \$3}'");
    @mps = split /\s+/m, $ret;
    return \@mps;
}

sub show_error_zones_on_cfs_sys {
    my ($prod,$sys,$action) = @_;
    my ($msg);

    $action=Msg::get("task_$action");
    $msg=Msg::new("Cannot proceed with the $action because there are shared volumes on the system $sys->{sys}, and there are zones with root path mounted on these shared volumes. You need to first run '/opt/VRTS/bin/cfsumount <mount point>' to unmount the mount point, and re-run the $action.");
    $sys->push_error($msg);
    return '';
}

sub show_warning_zones_on_vxfs_sys {
    my ($prod,$sys,$action) = @_;
    my ($msg);

    $action=Msg::get("task_$action");
    if (!$sys->{show_warning_zones_on_vxfs}) {
        $sys->{show_warning_zones_on_vxfs}=1;
        $sys->set_value('show_warning_zones_on_vxfs',1);
        $msg=Msg::new("There are some zones mounted on VxFS file systems on $sys->{sys}. The $action can continue, but the processes and drivers for VRTSvxvm and VRTSvxfs packages will not be stopped or unloaded.");
        $sys->push_warning($msg);
    }
    return;
}

sub show_warning_zones_on_vxvm_sys {
    my ($prod,$sys,$action) = @_;
    my ($msg);

    $action=Msg::get("task_$action");
    if (!$sys->{show_warning_zones_on_vxvm}) {
        $sys->{show_warning_zones_on_vxvm}=1;
        $sys->set_value('show_warning_zones_on_vxvm',1);
        $msg=Msg::new("There are some zones mounted on VxVM open volume on $sys->{sys}. The $action can continue, but the processes and drivers for VRTSvxvm and VRTSvxfs packages will not be stopped or unloaded.");
        $sys->push_warning($msg);
    }
    return;
}


#
# Function: vxfs_vxvm_zone_check_sys()
# Purpose:
#   This implements a VRTSvxvm request script task.
#   It validates that the root path of zones are mounted on vxfs file system,
#   if applicable.
# Input Parameters:
#   $sys
# Output Parameters:
#   3   if any zones are mounted on vxvm open volume, and not CFS/CVM.     can continue upgrade.
#   2   if any zones are mounted on vxfs file system, and not CFS/CVM.     can continue upgrade.
#   1   if any zones are mounted on vxfs file system, but also as CFS/CVM. need exit upgrade.
#   0   if all zones are not mounted on vxfs file system.                  need exit upgrade.
#
sub vxfs_vxvm_zone_check_sys {
    my ($prod,$sys) = @_;
    my ($msg,$ret);

    if (defined $sys->{zones_mounted_on_vxfs_vxvm}) {
        return $sys->{zones_mounted_on_vxfs_vxvm};
    }

    return 0 if (Cfg::opt('rootpath'));

    Msg::log("Checking $sys->{sys} for any zones mounted on VxFS file system, or on VxVM open volume");
    $ret = $prod->zones_with_vxfs_vxvm_sys($sys);
    $sys->{zones_mounted_on_vxfs_vxvm}= $ret;
    $sys->set_value('zones_mounted_on_vxfs_vxvm',$ret);
    if ($ret) {
        Msg::log('Discovered');
    } else {
        Msg::log('None');
    }
    return $ret;
}

#
# Function: zones_with_vxfs_vxvm_sys()
# Purpose:
#    check whether any zones with root path mounted on shared volumes if applicable.
# Input Parameters:
#    $sys
# Output Parameters:
#    3    if any zones are mounted on vxvm open volume, and not CFS/CVM.     continue upgrade
#    2    if any zones are mounted on vxfs file system, and not CFS/CVM.     continue upgrade
#    1    if any zones are mounted on vxfs file system, but also as CFS/CVM. exit upgrade since CFS not support
#    0    if all zones are not mounted on vxfs file system.                  exit upgrade since open volume
#
sub zones_with_vxfs_vxvm_sys {
    my ($prod,$sys) = @_;
    my ($mntlist,$zonelist,$mount,@mounts,$zone,$zname,$zpath,$mntdevice,$mntpath,$mntfstype,$mntoption);
    my ($zones_on_vxvm,$zones_on_vxfs,$zones_on_cfs);

    return 0 unless ($sys->{zone});

    # Get the list of mounted vxfs file systems.
    $mntlist=$sys->cmd('_cmd_mount -v');
    return 0 if ($mntlist eq '');

    # Get the list of zone paths.
    $zonelist=$sys->cmd('_cmd_zoneadm list -iv 2>/dev/null');
    return 0 if ($zonelist eq '');

    # Check if a zone path or directory corresponds directly to a vxfs mount point.
    # and use "mount -v | grep vxfs | grep cluster" to check whether a shared CFS/CVM.
    @mounts=split(/\n/,$mntlist);
    for my $zone (split(/\n/, $zonelist)) {
        if ($zone =~ /^\s*\S+\s+(\S+)\s+\S+\s+(\S+)/mx) {
            $zname=$1;
            $zpath=$2;
            next if ($zname eq 'NAME' || $zname eq 'global');

            for my $mount (@mounts) {
                if ($mount =~ /^(\S+)\s+on\s+(\S+)\s+type\s+(\S+)\s+(\S+)/mx) {
                    $mntdevice = $1;
                    $mntpath = $2;
                    $mntfstype = $3;
                    $mntoption = $4;
                    if ("$zpath" eq "$mntpath" || $zpath =~ /^$mntpath\//mx) {
                        if ($mntfstype eq 'vxfs') {
                            if ($mntoption =~ /cluster/m) {
                                $zones_on_cfs=1;
                            } else {
                                $zones_on_vxfs=1;
                            }
                        } elsif ($mntdevice =~ /^\/dev\/vx\/dsk\//mx) {
                            $zones_on_vxvm = 1;
                        }
                    }
                }
            }
        }
    }

    return 1 if ($zones_on_cfs);
    return 2 if ($zones_on_vxfs);
    return 3 if ($zones_on_vxvm);
    return 0;
}

sub get_tunable_value_sys{
    my ($prod,$sys,$tunable) =@_;
    my ($origval);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->get_tunefs_tunable_value_sys($sys, $tunable);
    }
    $origval = $sys->cmd("_cmd_grep '^set vxfs:$tunable=' /etc/system 2>/dev/null |_cmd_tail -1");
    if ( $origval ) {
        chomp $origval;
        $origval =~ s/^set vxfs:$tunable=//;
    }
    return $origval;
}

sub set_tunable_value_sys{
    my ($prod,$sys,$tunable,$value) =@_;
    my ($cpic, $file, @lines, @newlines, $tunable_info);
    if ( $prod->is_tunefs_tunable($tunable)) {
        return $prod->set_tunefs_tunable_value_sys($sys, $tunable, $value);
    }
    $cpic= Obj::cpic();
    if ($sys->exists('/etc/system')) {
        $file = $sys->readfile('/etc/system');
        @lines = split (/\n/,$file);
        @newlines = ();
        for my $line (@lines) {
            if ($line !~ /^set vxfs:$tunable=/ ) {
                push @newlines, $line;
            }
        }
        $file = join("\n", @newlines);
    } else {
        $file = '';
    }
    $sys->writefile($file, '/etc/system');

    $tunable_info=$cpic->get_tunable_info($tunable);
    if ($value != 0 || !$tunable_info->{zero_to_reset}) {
        $sys->appendfile("\nset vxfs:$tunable=$value\n", '/etc/system');
    }
    $file = $sys->readfile('/etc/system');
    return (0,$file);
}

package Prod::FS60::SolSparc;
@Prod::FS60::SolSparc::ISA = qw(Prod::FS60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(4.1.2 5.0 5.1 6.0)];
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfsadv60 VRTSfssdk60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxfs60 VRTSfsadv60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSvxfs60 VRTSfsadv60 VRTSsfmh41) ];
    return;
}

package Prod::FS60::Sol11sparc;
@Prod::FS60::Sol11sparc::ISA = qw(Prod::FS60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    $prod->{allpkgs}=[ qw(VRTSvxfs60 VRTSfsadv60 VRTSfssdk60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxfs60 VRTSfsadv60) ];
    $prod->{recpkgs}=[ qw(VRTSvxfs60 VRTSfsadv60 VRTSsfmh41) ];

    $prod->{lwp_default_stksize} = 8000;
    $prod->{svc_default_stksize} = 8000;
    return;
}

package Prod::FS60::Solx64;
@Prod::FS60::Solx64::ISA = qw(Prod::FS60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0 5.1 6.0)];
    return;
}

package Prod::FS60::Sol11x64;
@Prod::FS60::Sol11x64::ISA = qw(Prod::FS60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    $prod->{allpkgs}=[ qw(VRTSvxfs60 VRTSfssdk60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxfs60) ];
    $prod->{recpkgs}=[ qw(VRTSvxfs60 VRTSsfmh41) ];

    $prod->{lwp_default_stksize} = 8000;
    $prod->{svc_default_stksize} = 8000;
    return;
}

1;
