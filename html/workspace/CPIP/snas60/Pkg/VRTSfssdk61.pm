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

package Pkg::VRTSfssdk61::Common;
@Pkg::VRTSfssdk61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSfssdk';
    $pkg->{name}=Msg::new("File System Software Developer Kit")->{msg};
    return;
}

package Pkg::VRTSfssdk61::AIX;
@Pkg::VRTSfssdk61::AIX::ISA = qw(Pkg::VRTSfssdk61::Common);

package Pkg::VRTSfssdk61::HPUX;
@Pkg::VRTSfssdk61::HPUX::ISA = qw(Pkg::VRTSfssdk61::Common);

package Pkg::VRTSfssdk61::Linux;
@Pkg::VRTSfssdk61::Linux::ISA = qw(Pkg::VRTSfssdk61::Common);

package Pkg::VRTSfssdk61::RHEL5x8664;
@Pkg::VRTSfssdk61::RHEL5x8664::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "libc.so.6"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libdl.so.2"  =>  "glibc-2.5-49.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "libc.so.6"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libdl.so.2"  =>  "glibc-2.5-65.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "libc.so.6"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libdl.so.2"  =>  "glibc-2.5-81.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "libc.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTSfssdk61::RHEL6x8664;
@Pkg::VRTSfssdk61::RHEL6x8664::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.5'}={
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.x86_64",
    };
    return;
}

package Pkg::VRTSfssdk61::SLES10x8664;
@Pkg::VRTSfssdk61::SLES10x8664::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
    };
    return;
}

package Pkg::VRTSfssdk61::SLES11x8664;
@Pkg::VRTSfssdk61::SLES11x8664::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
    };
    return;
}

package Pkg::VRTSfssdk61::RHEL5ppc64;
@Pkg::VRTSfssdk61::RHEL5ppc64::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSfssdk61::SLES10ppc64;
@Pkg::VRTSfssdk61::SLES10ppc64::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
    };
    return;
}

package Pkg::VRTSfssdk61::SLES11ppc64;
@Pkg::VRTSfssdk61::SLES11ppc64::ISA = qw(Pkg::VRTSfssdk61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
    };
    return;
}

package Pkg::VRTSfssdk61::SunOS;
@Pkg::VRTSfssdk61::SunOS::ISA = qw(Pkg::VRTSfssdk61::Common);

1;
