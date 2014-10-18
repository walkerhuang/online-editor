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

package Pkg::VRTSvxvm61::Common;
@Pkg::VRTSvxvm61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvxvm';
    $pkg->{name}=Msg::new("Volume Manager Binaries")->{msg};
    $pkg->{vminstall}='/tmp/.cpivminstall';
    $pkg->{softdeps} = [ qw(VRTSdbed VRTSodm) ];
    return;
}

# touch this file to inform VM native scripts that it is a CPI installation
# VM native scripts will skip the checks for encapsulated and mirrored bootdisk
# if it is a CPI installation
sub preinstall_sys {
    my ($pkg,$sys)=@_;
    $sys->cmd("_cmd_rmr $pkg->{vminstall} 2>/dev/null");
    $sys->cmd("_cmd_touch $pkg->{vminstall} 2>/dev/null") if ($sys->{encap});

    my $vm=$sys->prod("VM61");
    if ((Cfg::opt("nostart")) && (!$sys->exists($vm->{mkdbfile}))) {
        $sys->createfile($vm->{mkdbfile});
        $sys->{cpi_mkdbfile}=1;
        $sys->set_value('cpi_mkdbfile',1);
    }

    return;
}

sub postinstall_sys {
    my ($pkg,$sys)=@_;
    $sys->cmd("_cmd_rmr $pkg->{vminstall} 2>/dev/null");

    my $vm=$sys->prod("VM61");
    if ((Cfg::opt("nostart")) && ($sys->{cpi_mkdbfile}) && $sys->exists($vm->{mkdbfile})) {
        $sys->rm($vm->{mkdbfile});
    }

    return;
}

package Pkg::VRTSvxvm61::AIX;
@Pkg::VRTSvxvm61::AIX::ISA = qw(Pkg::VRTSvxvm61::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxconfigd61 vxesd61 vxrelocd61 vxcached61 vxconfigbackupd61 vxattachd61 vvr61) ];
    $pkg->{stopprocs}=[ qw(vvr61 vxconfigbackupd61 vxsited61 vxcached61
                           vxrelocd61 vxnotify61 vxattachd61 vxesd61 vxconfigd61) ];
    $pkg->{ospkgs}{'5.3'}=['xlC.aix50.rte 6.0.0.7', 'devices.fcp.disk.rte 5.2.0.41', 'devices.scsi.disk.rte 5.2.0.41', 'devices.common.IBM.fc.hba-api'];
    $pkg->{ospkgs}{'6.1'}=['xlC.aix61.rte 9.0.0.0', 'devices.common.IBM.fc.hba-api' ];
    $pkg->{ospkgs}{'7.1'}=['xlC.aix61.rte 11.1.0.1', 'devices.common.IBM.fc.hba-api' ];
    $pkg->{has_install_export_cmd} = 1;
    return;
}
sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    $pkg->{donotrmonupgrade}=1 if(Cfg::opt("upgrade_kernelpkgs") && $sys->{pkgvers}{VRTScavf});
    return;
}

package Pkg::VRTSvxvm61::HPUX;
@Pkg::VRTSvxvm61::HPUX::ISA = qw(Pkg::VRTSvxvm61::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxconfigd61 vxesd61 vxrelocd61 vxcached61 vxconfigbackupd61 vxattachd61 vvr61) ];
    $pkg->{stopprocs}=[ qw(vvr61 vxconfigbackupd61 vxsited61 vxcached61
                           vxrelocd61 vxnotify61 vxattachd61 vxesd61 vxconfigd61) ];
    $pkg->{reinstall}=1;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSvxvm61::Linux;
@Pkg::VRTSvxvm61::Linux::ISA = qw(Pkg::VRTSvxvm61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{startprocs}=[ qw(vxdmp61 vxio61 vxspec61 vxconfigd61 vxesd61 vxrelocd61 vxcached61 vxconfigbackupd61 vxattachd61 vvr61) ];
    $pkg->{stopprocs}=[ qw(vvr61 vxconfigbackupd61 vxsited61 vxattachd61 vxcached61 vxrelocd61 vxnotify61 vxesd61 vxconfigd61 vxspec61 vxio61 vxdmp61) ];
    $pkg->{previouspkgnames} = [ qw(VRTSvxvm-platform VRTSvxvm-common) ];
    return;
}

package Pkg::VRTSvxvm61::RHEL5x8664;
@Pkg::VRTSvxvm61::RHEL5x8664::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "parted"  =>  "parted-1.8.1-27.el5.x86_64 parted-1.8.1-27.el5.i386",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "parted"  =>  "parted-1.8.1-27.el5.x86_64 parted-1.8.1-27.el5.i386",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "parted"  =>  "parted-1.8.1-28.el5.x86_64 parted-1.8.1-28.el5.i386",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "parted"  =>  "parted-1.8.1-29.el5.x86_64 parted-1.8.1-29.el5.i386",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "parted"  =>  "parted-1.8.1-30.el5.x86_64 parted-1.8.1-30.el5.i386",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5_9.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm61::RHEL6x8664;
@Pkg::VRTSvxvm61::RHEL6x8664::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "glibc"  =>  "glibc-2.12-1.80.el6.i686 glibc-2.12-1.80.el6.x86_64",
        "libgcc"  =>  "libgcc-4.4.6-4.el6.i686 libgcc-4.4.6-4.el6.x86_64",
        "libstdc++"  =>  "libstdc++-4.4.6-4.el6.i686 libstdc++-4.4.6-4.el6.x86_64",
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.12.9-11.el6.i686",
        "parted"  =>  "parted-2.1-18.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.24.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "glibc"  =>  "glibc-2.12-1.107.el6.i686 glibc-2.12-1.107.el6.x86_64",
        "libgcc"  =>  "libgcc-4.4.7-3.el6.i686 libgcc-4.4.7-3.el6.x86_64",
        "libstdc++"  =>  "libstdc++-4.4.7-3.el6.i686 libstdc++-4.4.7-3.el6.x86_64",
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.12.9-11.el6.i686",
        "parted"  =>  "parted-2.1-19.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.30.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "glibc"  =>  "glibc-2.12-1.132.el6.i686 glibc-2.12-1.132.el6.x86_64",
        "libgcc"  =>  "libgcc-4.4.7-4.el6.i686 libgcc-4.4.7-4.el6.x86_64",
        "libstdc++"  =>  "libstdc++-4.4.7-4.el6.i686 libstdc++-4.4.7-4.el6.x86_64",
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.14.3-9.el6.i686",
        "parted"  =>  "parted-2.1-21.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.39.el6.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm61::SLES10x8664;
@Pkg::VRTSvxvm61::SLES10x8664::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "parted"  =>  "parted-1.6.25.1-15.35.15.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm61::SLES11x8664;
@Pkg::VRTSvxvm61::SLES11x8664::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "parted"  =>  "parted-2.3-10.21.18.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "parted"  =>  "parted-2.3-10.38.16.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm61::RHEL5ppc64;
@Pkg::VRTSvxvm61::RHEL5ppc64::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'parted'  =>  'parted-1.8.1-17.el5.ppc parted-1.8.1-17.el5.ppc64',
        'policycoreutils'  =>  'policycoreutils-1.33.12-14.el5.ppc',
    };
    return;
}

package Pkg::VRTSvxvm61::SLES10ppc64;
@Pkg::VRTSvxvm61::SLES10ppc64::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'parted'  =>  'parted-1.6.25.1-15.19.ppc',
    };
    return;
}

package Pkg::VRTSvxvm61::SLES11ppc64;
@Pkg::VRTSvxvm61::SLES11ppc64::ISA = qw(Pkg::VRTSvxvm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'parted'  =>  'parted-1.8.8-102.4.ppc64',
    };
    return;
}

package Pkg::VRTSvxvm61::SunOS;
@Pkg::VRTSvxvm61::SunOS::ISA = qw(Pkg::VRTSvxvm61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{responsefile}=' ';
    $pkg->{startprocs}=[qw(vxdmp61 vxio61 vxspec61 vxconfigd61 vxesd61
                           vxrelocd61 vxcached61 vxconfigbackupd61 vxattachd61 vvr61) ];
    $pkg->{stopprocs}=[ qw(vvr61 vxconfigbackupd61 vxsited61 vxattachd61 vxcached61
                           vxrelocd61 vxnotify61 vxesd61 vxconfigd61
                           vxspec61 vxio61 vxdmp61) ];
    $pkg->{ospkgs}{all}=[ 'SUNWcsu' ];
    return;
}

sub define_ospatches {
    my ($pkg,$padv,$sys) = @_;
    my ($sunwcfcl_pkg);

    # we need to check for 114477-04 only if SUNWcfcl present
    $sunwcfcl_pkg=Pkg::new_pkg('Pkg','SUNWcfcl',$sys->{padv});
    push(@{$pkg->{ospatches}{'5.9'}},'114477-04') if ($sunwcfcl_pkg->version_sys($sys));

    return;
}

package Pkg::VRTSvxvm61::Solx64;
@Pkg::VRTSvxvm61::Solx64::ISA = qw(Pkg::VRTSvxvm61::SunOS);
sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['118844-26', '119131-09', '119375-03', '119043-02', '125732-02', '128307-05'];
    return;
}

package Pkg::VRTSvxvm61::SolSparc;
@Pkg::VRTSvxvm61::SolSparc::ISA = qw(Pkg::VRTSvxvm61::SunOS);
sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['119254-06', '119042-02', '125731-02', '128306-05'];
    return;
}

package Pkg::VRTSvxvm61::Sol11sparc;
@Pkg::VRTSvxvm61::Sol11sparc::ISA = qw(Pkg::VRTSvxvm61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    $pkg->{softdeps} = [];
    $pkg->{ospkgs}{all}=[];
    return;
}

package Pkg::VRTSvxvm61::Sol11x64;
@Pkg::VRTSvxvm61::Sol11x64::ISA = qw(Pkg::VRTSvxvm61::Sol11sparc);

1;
