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

package Pkg::VRTSodm61::Common;
@Pkg::VRTSodm61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSodm';
    $pkg->{name}=Msg::new("Oracle Disk Manager")->{msg};

    $pkg->{startprocs}=[ qw(odm61) ];
    $pkg->{stopprocs}=[ qw(odm61) ];
    return;
}

package Pkg::VRTSodm61::AIX;
@Pkg::VRTSodm61::AIX::ISA = qw(Pkg::VRTSodm61::Common);

package Pkg::VRTSodm61::HPUX;
@Pkg::VRTSodm61::HPUX::ISA = qw(Pkg::VRTSodm61::Common);

package Pkg::VRTSodm61::Linux;
@Pkg::VRTSodm61::Linux::ISA = qw(Pkg::VRTSodm61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{mpok} = 1;
    return;
}

package Pkg::VRTSodm61::RHEL5x8664;
@Pkg::VRTSodm61::RHEL5x8664::ISA = qw(Pkg::VRTSodm61::Linux);

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

package Pkg::VRTSodm61::RHEL6x8664;
@Pkg::VRTSodm61::RHEL6x8664::ISA = qw(Pkg::VRTSodm61::Linux);

sub init_padv {
    my $pkg=shift;
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
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.i686",
    };
    return;
}

package Pkg::VRTSodm61::SLES10x8664;
@Pkg::VRTSodm61::SLES10x8664::ISA = qw(Pkg::VRTSodm61::Linux);

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

package Pkg::VRTSodm61::SLES11x8664;
@Pkg::VRTSodm61::SLES11x8664::ISA = qw(Pkg::VRTSodm61::Linux);

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

package Pkg::VRTSodm61::RHEL5ppc64;
@Pkg::VRTSodm61::RHEL5ppc64::ISA = qw(Pkg::VRTSodm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-5.97-14.el5.ppc',
        'ed'  =>  'ed-0.2-38.2.2.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libm.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libnsl.so.1()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'modutils'  =>  'module-init-tools-3.3-0.pre3.1.37.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSodm61::SLES10ppc64;
@Pkg::VRTSodm61::SLES10ppc64::ISA = qw(Pkg::VRTSodm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-5.93-22.14.ppc',
        'ed'  =>  'ed-0.2-881.2.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libm.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libnsl.so.1()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'modutils'  =>  'module-init-tools-3.2.2-32.27.ppc',
    };
    return;
}

package Pkg::VRTSodm61::SLES11ppc64;
@Pkg::VRTSodm61::SLES11ppc64::ISA = qw(Pkg::VRTSodm61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-6.12-32.17.ppc64',
        'libc.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libm.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libnsl.so.1()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'modutils'  =>  'module-init-tools-3.4-70.5.ppc64',
    };
    return;
}

package Pkg::VRTSodm61::SunOS;
@Pkg::VRTSodm61::SunOS::ISA = qw(Pkg::VRTSodm61::Common);

package Pkg::VRTSodm61::Sol11sparc;
@Pkg::VRTSodm61::Sol11sparc::ISA = qw(Pkg::VRTSodm61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    return;
}

package Pkg::VRTSodm61::Sol11x64;
@Pkg::VRTSodm61::Sol11x64::ISA = qw(Pkg::VRTSodm61::Sol11sparc);

1;
