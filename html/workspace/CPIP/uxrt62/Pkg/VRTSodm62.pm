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

package Pkg::VRTSodm62::Common;
@Pkg::VRTSodm62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSodm';
    $pkg->{name}=Msg::new("Oracle Disk Manager")->{msg};

    $pkg->{startprocs}=[ qw(odm62) ];
    $pkg->{stopprocs}=[ qw(odm62) ];
    return;
}

package Pkg::VRTSodm62::AIX;
@Pkg::VRTSodm62::AIX::ISA = qw(Pkg::VRTSodm62::Common);

package Pkg::VRTSodm62::HPUX;
@Pkg::VRTSodm62::HPUX::ISA = qw(Pkg::VRTSodm62::Common);

package Pkg::VRTSodm62::Linux;
@Pkg::VRTSodm62::Linux::ISA = qw(Pkg::VRTSodm62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSodm-platform VRTSodm-common) ];

    return;
}

package Pkg::VRTSodm62::RHEL5x8664;
@Pkg::VRTSodm62::RHEL5x8664::ISA = qw(Pkg::VRTSodm62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "coreutils"  =>  "coreutils-5.97-23.el5_4.2.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "coreutils"  =>  "coreutils-5.97-23.el5_4.2.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "coreutils"  =>  "coreutils-5.97-34.el5.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "coreutils"  =>  "coreutils-5.97-34.el5.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "coreutils"  =>  "coreutils-5.97-34.el5_8.1.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTSodm62::RHEL6x8664;
@Pkg::VRTSodm62::RHEL6x8664::ISA = qw(Pkg::VRTSodm62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "coreutils"  =>  "coreutils-8.4-19.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-20.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "coreutils"  =>  "coreutils-8.4-19.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-21.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "coreutils"  =>  "coreutils-8.4-31.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-21.el6_4.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.6'}={
        "coreutils"  =>  "coreutils-8.4-37.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-24.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.149.el6.i686 glibc-2.12-1.149.el6.x86_64",
    };
    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }

    $pkg->{oslibs}{'OL6.3'}{"modutils"} = "module-init-tools-3.9-20.0.1.el6.x86_64";

    $pkg->{oslibs}{'OL6.4'}{"coreutils"} = "coreutils-8.4-19.0.1.el6.x86_64";
    $pkg->{oslibs}{'OL6.4'}{"modutils"} = "module-init-tools-3.9-21.0.1.el6.x86_64";

    $pkg->{oslibs}{'OL6.5'}{"coreutils"} = "coreutils-8.4-31.0.1.el6.x86_64";
    $pkg->{oslibs}{'OL6.5'}{"modutils"} = "module-init-tools-3.9-21.0.1.el6_4.x86_64";

    return;
}

package Pkg::VRTSodm62::RHEL7x8664;
@Pkg::VRTSodm62::RHEL7x8664::ISA = qw(Pkg::VRTSodm62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL7.0'}={
        "coreutils"  =>  "coreutils-8.22-11.el7.x86_64",
        "ed"  =>  "ed-1.9-4.el7.x86_64",
        "kmod"  =>  "kmod-14-9.el7.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.14)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.17-55.el7.i686 glibc-2.17-55.el7.x86_64",
    };

    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSodm62::OL6x8664;
@Pkg::VRTSodm62::OL6x8664::ISA = qw(Pkg::VRTSodm62::RHEL6x8664);

package Pkg::VRTSodm62::OL7x8664;
@Pkg::VRTSodm62::OL7x8664::ISA = qw(Pkg::VRTSodm62::RHEL7x8664);

package Pkg::VRTSodm62::SLES10x8664;
@Pkg::VRTSodm62::SLES10x8664::ISA = qw(Pkg::VRTSodm62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "coreutils"  =>  "coreutils-5.93-22.21.17.x86_64",
        "ed"  =>  "ed-0.2-881.9.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "modutils"  =>  "module-init-tools-3.2.2-32.38.1.x86_64",
    };
    return;
}

package Pkg::VRTSodm62::SLES11x8664;
@Pkg::VRTSodm62::SLES11x8664::ISA = qw(Pkg::VRTSodm62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "coreutils"  =>  "coreutils-8.12-6.19.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "modutils"  =>  "module-init-tools-3.11.1-1.21.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "coreutils"  =>  "coreutils-8.12-6.25.27.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "modutils"  =>  "module-init-tools-3.11.1-1.28.5.x86_64",
    };
    return;
}

package Pkg::VRTSodm62::SunOS;
@Pkg::VRTSodm62::SunOS::ISA = qw(Pkg::VRTSodm62::Common);

package Pkg::VRTSodm62::Sol11sparc;
@Pkg::VRTSodm62::Sol11sparc::ISA = qw(Pkg::VRTSodm62::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    return;
}

package Pkg::VRTSodm62::Sol11x64;
@Pkg::VRTSodm62::Sol11x64::ISA = qw(Pkg::VRTSodm62::Sol11sparc);

1;
