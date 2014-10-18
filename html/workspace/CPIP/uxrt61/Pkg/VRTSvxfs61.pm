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

package Pkg::VRTSvxfs61::Common;
@Pkg::VRTSvxfs61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvxfs';
    $pkg->{name}=Msg::new("File System")->{msg};
    $pkg->{softdeps} = [ qw(VRTSdbed VRTSodm) ];
    return;
}

package Pkg::VRTSvxfs61::AIX;
@Pkg::VRTSvxfs61::AIX::ISA = qw(Pkg::VRTSvxfs61::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxfs61 vxportal61 qio61) ];
    $pkg->{stopprocs}=[ qw(qio61 vxportal61 vxfs61) ];
    return;
}
sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    $pkg->{donotrmonupgrade}=1 if(Cfg::opt("upgrade_kernelpkgs") && $sys->{pkgvers}{VRTScavf});
    return;
}

package Pkg::VRTSvxfs61::HPUX;
@Pkg::VRTSvxfs61::HPUX::ISA = qw(Pkg::VRTSvxfs61::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{donotrmonupgrade}=1;
    $pkg->{ospatches}{'11.31IA'}=['PHKL_38651','PHKL_38952','PHKL_40944','PHKL_41086'];
    $pkg->{ospatches}{'11.31PA'}=['PHKL_38651','PHKL_38952','PHKL_40944','PHKL_41086'];
    return;
}

package Pkg::VRTSvxfs61::Linux;
@Pkg::VRTSvxfs61::Linux::ISA = qw(Pkg::VRTSvxfs61::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxportal61 fdd61 vxcafs61) ];
    $pkg->{stopprocs}=[ qw(vxcafs61 fdd61 vxportal61 vxfs61) ];
    $pkg->{previouspkgnames} = [ qw(VRTSvxfs-platform VRTSvxfs-common)];
    return;
}

package Pkg::VRTSvxfs61::RHEL5x8664;
@Pkg::VRTSvxfs61::RHEL5x8664::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "coreutils"  =>  "coreutils-5.97-23.el5_4.2.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "findutils"  =>  "findutils-4.2.27-6.el5.x86_64",
        "libacl.so.1"  =>  "libacl-2.2.39-6.el5.i386",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-2.2.39-6.el5.i386",
        "libc.so.6"  =>  "glibc-2.5-49.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libm.so.6"  =>  "glibc-2.5-49.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-5.5-24.20060715.x86_64",
        "libnsl.so.1"  =>  "glibc-2.5-49.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libreadline.so.5()(64bit)"  =>  "readline-5.1-3.el5.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5.x86_64",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "coreutils"  =>  "coreutils-5.97-23.el5_4.2.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "findutils"  =>  "findutils-4.2.27-6.el5.x86_64",
        "libacl.so.1"  =>  "libacl-2.2.39-6.el5.i386",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-2.2.39-6.el5.i386",
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-5.5-24.20060715.x86_64",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libreadline.so.5()(64bit)"  =>  "readline-5.1-3.el5.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "perl(constant)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(Getopt::Std)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(strict)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "coreutils"  =>  "coreutils-5.97-34.el5.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "findutils"  =>  "findutils-4.2.27-6.el5.x86_64",
        "libacl.so.1"  =>  "libacl-2.2.39-6.el5.i386",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-2.2.39-6.el5.i386",
        "libc.so.6"  =>  "glibc-2.5-65.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libm.so.6"  =>  "glibc-2.5-65.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-5.5-24.20060715.x86_64",
        "libnsl.so.1"  =>  "glibc-2.5-65.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libreadline.so.5()(64bit)"  =>  "readline-5.1-3.el5.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "coreutils"  =>  "coreutils-5.97-34.el5.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "findutils"  =>  "findutils-4.2.27-6.el5.x86_64",
        "libacl.so.1"  =>  "libacl-2.2.39-8.el5.i386",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-2.2.39-8.el5.i386",
        "libc.so.6"  =>  "glibc-2.5-81.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libm.so.6"  =>  "glibc-2.5-81.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-5.5-24.20060715.x86_64",
        "libnsl.so.1"  =>  "glibc-2.5-81.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libreadline.so.5()(64bit)"  =>  "readline-5.1-3.el5.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "coreutils"  =>  "coreutils-5.97-34.el5_8.1.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "findutils"  =>  "findutils-4.2.27-6.el5.x86_64",
        "libacl.so.1"  =>  "libacl-2.2.39-8.el5.i386",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-2.2.39-8.el5.i386",
        "libc.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libm.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-5.5-24.20060715.x86_64",
        "libnsl.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libreadline.so.5()(64bit)"  =>  "readline-5.1-3.el5.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5_9.x86_64",
    };
    return;
}

package Pkg::VRTSvxfs61::RHEL6x8664;
@Pkg::VRTSvxfs61::RHEL6x8664::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "coreutils"  =>  "coreutils-8.4-19.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "findutils"  =>  "findutils-4.4.2-6.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libm.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-libs-5.7-3.20090208.el6.x86_64",
        "libnsl.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libreadline.so.6()(64bit)"  =>  "readline-6.0-4.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-20.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.24.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "coreutils"  =>  "coreutils-8.4-19.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "findutils"  =>  "findutils-4.4.2-6.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libm.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-libs-5.7-3.20090208.el6.x86_64",
        "libnsl.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libreadline.so.6()(64bit)"  =>  "readline-6.0-4.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-21.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.30.el6.x86_64",
    };
    return;
}

package Pkg::VRTSvxfs61::SLES10x8664;
@Pkg::VRTSvxfs61::SLES10x8664::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "coreutils"  =>  "coreutils-5.93-22.21.17.x86_64",
        "ed"  =>  "ed-0.2-881.9.1.x86_64",
        "findutils"  =>  "findutils-4.2.27-14.22.18.x86_64",
        "libacl.so.1"  =>  "libacl-32bit-2.2.41-0.15.x86_64",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-32bit-2.2.41-0.15.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-5.5-18.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "modutils"  =>  "module-init-tools-3.2.2-32.38.1.x86_64",
    };
    return;
}

package Pkg::VRTSvxfs61::SLES11x8664;
@Pkg::VRTSvxfs61::SLES11x8664::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "coreutils"  =>  "coreutils-8.12-6.19.1.x86_64",
        "ed"  =>  "ed-0.2-1001.30.1.x86_64",
        "findutils"  =>  "findutils-4.4.0-38.26.1.x86_64",
        "libacl.so.1"  =>  "libacl-32bit-2.2.47-30.34.29.x86_64",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-32bit-2.2.47-30.34.29.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libncurses.so.5()(64bit)"  =>  "libncurses5-5.6-90.55.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "modutils"  =>  "module-init-tools-3.11.1-1.21.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "coreutils"  =>  "coreutils-8.12-6.25.27.1.x86_64",
        "ed"  =>  "ed-0.2-1001.30.1.x86_64",
        "findutils"  =>  "findutils-4.4.0-38.26.1.x86_64",
        "libacl.so.1"  =>  "libacl-32bit-2.2.47-30.34.29.x86_64",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-32bit-2.2.47-30.34.29.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libncurses.so.5()(64bit)"  =>  "libncurses5-5.6-90.55.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "modutils"  =>  "module-init-tools-3.11.1-1.28.5.x86_64",
    };
    return;
}

package Pkg::VRTSvxfs61::RHEL5ppc64;
@Pkg::VRTSvxfs61::RHEL5ppc64::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-5.97-14.el5.ppc',
        'ed'  =>  'ed-0.2-38.2.2.ppc',
        'findutils'  =>  'findutils-4.2.27-4.1.ppc',
        'libacl.so.1'  =>  'libacl-2.2.39-3.el5.ppc',
        'libacl.so.1(ACL_1.0)'  =>  'libacl-2.2.39-3.el5.ppc',
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.3.4)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libdl.so.2()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libdl.so.2(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libm.so.6'  =>  'glibc-2.5-24.ppc',
        'libm.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'libnsl.so.1()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.3.2)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'modutils'  =>  'module-init-tools-3.3-0.pre3.1.37.el5.ppc',
        'policycoreutils'  =>  'policycoreutils-1.33.12-14.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSvxfs61::SLES10ppc64;
@Pkg::VRTSvxfs61::SLES10ppc64::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-5.93-22.14.ppc',
        'ed'  =>  'ed-0.2-881.2.ppc',
        'findutils'  =>  'findutils-4.2.27-14.10.ppc',
        'libacl.so.1'  =>  'libacl-2.2.41-0.12.ppc',
        'libacl.so.1(ACL_1.0)'  =>  'libacl-2.2.41-0.12.ppc',
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.4)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libdl.so.2()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libm.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libm.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libnsl.so.1()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3.2)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'modutils'  =>  'module-init-tools-3.2.2-32.27.ppc',
    };
    return;
}

package Pkg::VRTSvxfs61::SLES11ppc64;
@Pkg::VRTSvxfs61::SLES11ppc64::ISA = qw(Pkg::VRTSvxfs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-6.12-32.17.ppc64',
        'ed'  =>  'ed-0.2-1001.22.ppc64',
        'findutils'  =>  'findutils-4.4.0-38.22.ppc64',
        'libacl.so.1'  =>  'libacl-32bit-2.2.47-30.3.ppc64',
        'libacl.so.1(ACL_1.0)'  =>  'libacl-32bit-2.2.47-30.3.ppc64',
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.4)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libdl.so.2()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libm.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libm.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libnsl.so.1()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3.2)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'modutils'  =>  'module-init-tools-3.4-70.5.ppc64',
    };
    return;
}

package Pkg::VRTSvxfs61::SunOS;
@Pkg::VRTSvxfs61::SunOS::ISA = qw(Pkg::VRTSvxfs61::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxportal61 fdd61) ];
    $pkg->{stopprocs}=[ qw(fdd61 vxportal61 qlog61 vxfs61) ];
    return;
}

package Pkg::VRTSvxfs61::Solx64;
@Pkg::VRTSvxfs61::Solx64::ISA = qw(Pkg::VRTSvxfs61::SunOS);
sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['118844-19', '127112-01'];
    return;
}

package Pkg::VRTSvxfs61::SolSparc;
@Pkg::VRTSvxfs61::SolSparc::ISA = qw(Pkg::VRTSvxfs61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['127111-01'];
    $pkg->{ospatches}{'5.9'}=['122300-10'];
    return;
}

package Pkg::VRTSvxfs61::Sol11sparc;
@Pkg::VRTSvxfs61::Sol11sparc::ISA = qw(Pkg::VRTSvxfs61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    return;
}

package Pkg::VRTSvxfs61::Sol11x64;
@Pkg::VRTSvxfs61::Sol11x64::ISA = qw(Pkg::VRTSvxfs61::Sol11sparc);

1;
