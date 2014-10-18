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

package Pkg::VRTSamf62::Common;
@Pkg::VRTSamf62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSamf';
    $pkg->{name}=Msg::new("Asynchronous Monitoring Framework")->{msg};
    $pkg->{installonpatchupgrade}=1;
    $pkg->{stopprocs}= [ qw(amf62) ];
    $pkg->{startprocs}= [ qw(amf62) ];
    return;
}

package Pkg::VRTSamf62::AIX;
@Pkg::VRTSamf62::AIX::ISA = qw(Pkg::VRTSamf62::Common);

package Pkg::VRTSamf62::HPUX;
@Pkg::VRTSamf62::HPUX::ISA = qw(Pkg::VRTSamf62::Common);

package Pkg::VRTSamf62::Linux;
@Pkg::VRTSamf62::Linux::ISA = qw(Pkg::VRTSamf62::Common);

package Pkg::VRTSamf62::RHEL5x8664;
@Pkg::VRTSamf62::RHEL5x8664::ISA = qw(Pkg::VRTSamf62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "libcrypt.so.1"  =>  "glibc-2.5-49.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-49.i686",
        "libdl.so.2"  =>  "glibc-2.5-49.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-48.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-48.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-48.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-49.i686",
        "libnsl.so.1"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-49.i686",
        "librt.so.1"  =>  "glibc-2.5-49.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-48.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-48.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "libcrypt.so.1"  =>  "glibc-2.5-58.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "librt.so.1"  =>  "glibc-2.5-58.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "libcrypt.so.1"  =>  "glibc-2.5-65.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-65.i686",
        "libdl.so.2"  =>  "glibc-2.5-65.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-51.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-51.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-51.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-65.i686",
        "libnsl.so.1"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-65.i686",
        "librt.so.1"  =>  "glibc-2.5-65.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-51.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-51.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "libcrypt.so.1"  =>  "glibc-2.5-81.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-81.i686",
        "libdl.so.2"  =>  "glibc-2.5-81.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-52.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-52.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-52.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-81.i686",
        "libnsl.so.1"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-81.i686",
        "librt.so.1"  =>  "glibc-2.5-81.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-52.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-52.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",    
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "libcrypt.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-54.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-54.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-54.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libnsl.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "librt.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-54.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-54.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTSamf62::RHEL6x8664;
@Pkg::VRTSamf62::RHEL6x8664::ISA = qw(Pkg::VRTSamf62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.6-4.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.6-4.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.6-4.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.7-3.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.7-3.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.7-3.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.7-4.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.7-4.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.7-4.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "rtld(GNU_HASH)"  =>  "libstdc++-4.4.7-4.el6.i686",
    };
    $pkg->{oslibs}{'RHEL6.6'}={
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.4.7-11.el6.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.4.7-11.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.12-1.149.el6.i686",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.4.7-11.el6.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.4.7-11.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.149.el6.i686 glibc-2.12-1.149.el6.x86_64",
    };
    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSamf62::RHEL7x8664;
@Pkg::VRTSamf62::RHEL7x8664::ISA = qw(Pkg::VRTSamf62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL7.0'}={
        "libcrypt.so.1"  =>  "glibc-2.17-55.el7.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.17-55.el7.i686",
        "libdl.so.2"  =>  "glibc-2.17-55.el7.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.17-55.el7.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.8.2-16.el7.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.8.2-16.el7.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.8.2-16.el7.i686",
        "libm.so.6"  =>  "glibc-2.17-55.el7.i686",
        "libnsl.so.1"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.17-55.el7.i686",
        "libpthread.so.0(GLIBC_2.3.3)"  =>  "glibc-2.17-55.el7.i686",
        "librt.so.1"  =>  "glibc-2.17-55.el7.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.17-55.el7.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.8.2-16.el7.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.8.2-16.el7.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.17-55.el7.i686 glibc-2.17-55.el7.x86_64",
    };

    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSamf62::OL6x8664;
@Pkg::VRTSamf62::OL6x8664::ISA = qw(Pkg::VRTSamf62::RHEL6x8664);

package Pkg::VRTSamf62::OL7x8664;
@Pkg::VRTSamf62::OL7x8664::ISA = qw(Pkg::VRTSamf62::RHEL7x8664);

package Pkg::VRTSamf62::SLES10x8664;
@Pkg::VRTSamf62::SLES10x8664::ISA = qw(Pkg::VRTSamf62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTSamf62::SLES11x8664;
@Pkg::VRTSamf62::SLES11x8664::ISA = qw(Pkg::VRTSamf62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libgcc_s.so.1"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libstdc++.so.6"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libgcc_s.so.1"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libstdc++.so.6"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
    };
    return;
}

package Pkg::VRTSamf62::SunOS;
@Pkg::VRTSamf62::SunOS::ISA = qw(Pkg::VRTSamf62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{smf}=['/var/svc/manifest/system/amf.xml', '/lib/svc/method/amf'];
    return;
}

sub preremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS62');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS62');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

1;
