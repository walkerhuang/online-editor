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

package Pkg::VRTSvxfs62::Common;
@Pkg::VRTSvxfs62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvxfs';
    $pkg->{name}=Msg::new("File System")->{msg};
    $pkg->{softdeps} = [ qw(VRTSdbed VRTSodm) ];
    return;
}

package Pkg::VRTSvxfs62::AIX;
@Pkg::VRTSvxfs62::AIX::ISA = qw(Pkg::VRTSvxfs62::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxfs62 vxportal62 qio62 vxcafs62) ];
    $pkg->{stopprocs}=[ qw(vxcafs62 qio62 vxportal62 vxfs62) ];
    return;
}
sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    $pkg->{donotrmonupgrade}=1 if(Cfg::opt("upgrade_kernelpkgs") && $sys->{pkgvers}{VRTScavf});
    return;
}

package Pkg::VRTSvxfs62::HPUX;
@Pkg::VRTSvxfs62::HPUX::ISA = qw(Pkg::VRTSvxfs62::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{donotrmonupgrade}=1;
    $pkg->{ospatches}{'11.31IA'}=['PHKL_38651','PHKL_38952','PHKL_40944','PHKL_41086'];
    $pkg->{ospatches}{'11.31PA'}=['PHKL_38651','PHKL_38952','PHKL_40944','PHKL_41086'];
    return;
}

package Pkg::VRTSvxfs62::Linux;
@Pkg::VRTSvxfs62::Linux::ISA = qw(Pkg::VRTSvxfs62::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxportal62 fdd62 vxcafs62) ];
    $pkg->{stopprocs}=[ qw(vxcafs62 fdd62 vxportal62 vxfs62) ];
    $pkg->{previouspkgnames} = [ qw(VRTSvxfs-platform VRTSvxfs-common)];
    return;
}

package Pkg::VRTSvxfs62::RHEL5x8664;
@Pkg::VRTSvxfs62::RHEL5x8664::ISA = qw(Pkg::VRTSvxfs62::Linux);

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

package Pkg::VRTSvxfs62::RHEL6x8664;
@Pkg::VRTSvxfs62::RHEL6x8664::ISA = qw(Pkg::VRTSvxfs62::Linux);

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
    $pkg->{oslibs}{'RHEL6.5'}={
        "coreutils"  =>  "coreutils-8.4-31.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "findutils"  =>  "findutils-4.4.2-6.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libm.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-libs-5.7-3.20090208.el6.x86_64",
        "libnsl.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libreadline.so.6()(64bit)"  =>  "readline-6.0-4.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-21.el6_4.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.39.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.6'}={
        "coreutils"  =>  "coreutils-8.4-37.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "findutils"  =>  "findutils-4.4.2-6.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libm.so.6"  =>  "glibc-2.12-1.149.el6.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.149.el6.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-libs-5.7-3.20090208.el6.x86_64",
        "libnsl.so.1"  =>  "glibc-2.12-1.149.el6.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libreadline.so.6()(64bit)"  =>  "readline-6.0-4.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-24.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.47.el6.x86_64",
    };
    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }

    $pkg->{oslibs}{'OL6.3'}{"modutils"} = "module-init-tools-3.9-20.0.1.el6.x86_64";
    $pkg->{oslibs}{'OL6.3'}{"policycoreutils"} = "policycoreutils-2.0.83-19.24.0.1.el6.x86_64";

    $pkg->{oslibs}{'OL6.4'}{"coreutils"} = "coreutils-8.4-19.0.1.el6.x86_64";
    $pkg->{oslibs}{'OL6.4'}{"modutils"} = "module-init-tools-3.9-21.0.1.el6.x86_64";
    $pkg->{oslibs}{'OL6.4'}{"policycoreutils"} = "policycoreutils-2.0.83-19.30.0.1.el6.x86_64";

    $pkg->{oslibs}{'OL6.5'}{"coreutils"} = "coreutils-8.4-31.0.1.el6.x86_64";
    $pkg->{oslibs}{'OL6.5'}{"modutils"} = "module-init-tools-3.9-21.0.1.el6_4.x86_64";
    $pkg->{oslibs}{'OL6.5'}{"policycoreutils"} = "policycoreutils-2.0.83-19.39.0.1.el6.x86_64";

    return;
}

package Pkg::VRTSvxfs62::RHEL7x8664;
@Pkg::VRTSvxfs62::RHEL7x8664::ISA = qw(Pkg::VRTSvxfs62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL7.0'}={
        "coreutils"  =>  "coreutils-8.22-11.el7.x86_64",
        "ed"  =>  "ed-1.9-4.el7.x86_64",
        "findutils"  =>  "findutils-4.5.11-3.el7.x86_64",
        "libacl.so.1"  =>  "libacl-2.2.51-12.el7.i686",
        "libacl.so.1(ACL_1.0)"  =>  "libacl-2.2.51-12.el7.i686",
        "libc.so.6"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.14)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.8.2-16.el7.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.8.2-16.el7.x86_64",
        "libgcc_s.so.1(GCC_3.3.1)(64bit)"  =>  "libgcc-4.8.2-16.el7.x86_64",
        "libm.so.6"  =>  "glibc-2.17-55.el7.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libncurses.so.5()(64bit)"  =>  "ncurses-libs-5.9-13.20130511.el7.x86_64",
        "libnsl.so.1"  =>  "glibc-2.17-55.el7.i686",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libpthread.so.0"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libtinfo.so.5()(64bit)"  =>  "ncurses-libs-5.9-13.20130511.el7.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.2.5-11.el7.x86_64",
    };

    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSvxfs62::OL6x8664;
@Pkg::VRTSvxfs62::OL6x8664::ISA = qw(Pkg::VRTSvxfs62::RHEL6x8664);

package Pkg::VRTSvxfs62::OL7x8664;
@Pkg::VRTSvxfs62::OL7x8664::ISA = qw(Pkg::VRTSvxfs62::RHEL7x8664);

package Pkg::VRTSvxfs62::SLES10x8664;
@Pkg::VRTSvxfs62::SLES10x8664::ISA = qw(Pkg::VRTSvxfs62::Linux);

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

package Pkg::VRTSvxfs62::SLES11x8664;
@Pkg::VRTSvxfs62::SLES11x8664::ISA = qw(Pkg::VRTSvxfs62::Linux);

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

package Pkg::VRTSvxfs62::SunOS;
@Pkg::VRTSvxfs62::SunOS::ISA = qw(Pkg::VRTSvxfs62::Common);

sub init_plat {
    my $pkg=shift;

    #$pkg->{startprocs}=[ qw(vxportal62 fdd62 vxcafs62) ];
    $pkg->{startprocs}=[ qw(fdd62 vxcafs62 vxportal62) ];
    $pkg->{stopprocs}=[ qw(vxportal62 vxcafs62 fdd62 qlog62 vxfs62) ];
    return;
}

package Pkg::VRTSvxfs62::Solx64;
@Pkg::VRTSvxfs62::Solx64::ISA = qw(Pkg::VRTSvxfs62::SunOS);
sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['118844-19', '127112-01'];
    return;
}

package Pkg::VRTSvxfs62::SolSparc;
@Pkg::VRTSvxfs62::SolSparc::ISA = qw(Pkg::VRTSvxfs62::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['127111-01'];
    $pkg->{ospatches}{'5.9'}=['122300-10'];
    return;
}

package Pkg::VRTSvxfs62::Sol11sparc;
@Pkg::VRTSvxfs62::Sol11sparc::ISA = qw(Pkg::VRTSvxfs62::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    return;
}

package Pkg::VRTSvxfs62::Sol11x64;
@Pkg::VRTSvxfs62::Sol11x64::ISA = qw(Pkg::VRTSvxfs62::Sol11sparc);

1;
