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

package Pkg::VRTSfsadv61::Common;
@Pkg::VRTSfsadv61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSfsadv';
    $pkg->{name}=Msg::new("File System Advanced Solutions")->{msg};
    return;
}

sub donotinstall_sys {
    my ($pkg,$sys) = @_;
    my ($pkgsys);

    $pkgsys = Obj::pkg($pkg->{pkgi},$sys->{padv},1);
    if (!$pkgsys) {
        $pkgsys = $pkg;
    }
    return $pkgsys->{donotinstall} || EDRu::inarr($pkgsys->{pkgi},@{$sys->{donotinstallpkgs}});
}

sub donotuninstall_sys {
    my ($pkg,$sys) = @_;
    my ($pkgsys);

    $pkgsys = Obj::pkg($pkg->{pkgi},$sys->{padv},1);
    if (!$pkgsys) {
        $pkgsys = $pkg;
    }
    return $pkgsys->{donotuninstall} || EDRu::inarr($pkgsys->{pkgi},@{$sys->{donotuninstallpkgs}});
}

sub donotupgrade_sys {
    my ($pkg,$sys) = @_;
    my ($pkgsys);

    $pkgsys = Obj::pkg($pkg->{pkgi},$sys->{padv},1);
    if (!$pkgsys) {
        $pkgsys = $pkg;
    }
    return $pkgsys->{donotupgrade} || EDRu::inarr($pkgsys->{pkgi},@{$sys->{donotupgradepkgs}});
}

package Pkg::VRTSfsadv61::AIX;
@Pkg::VRTSfsadv61::AIX::ISA = qw(Pkg::VRTSfsadv61::Common);

package Pkg::VRTSfsadv61::HPUX;
@Pkg::VRTSfsadv61::HPUX::ISA = qw(Pkg::VRTSfsadv61::Common);

package Pkg::VRTSfsadv61::HPUX1131par;
@Pkg::VRTSfsadv61::HPUX1131par::ISA = qw(Pkg::VRTSfsadv61::HPUX);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotinstall} = 1;
    $pkg->{donotuninstall} = 1;
    $pkg->{donotupgrade} = 1;
    return;
}

package Pkg::VRTSfsadv61::Linux;
@Pkg::VRTSfsadv61::Linux::ISA = qw(Pkg::VRTSfsadv61::Common);

package Pkg::VRTSfsadv61::SunOS;
@Pkg::VRTSfsadv61::SunOS::ISA = qw(Pkg::VRTSfsadv61::Common);

package Pkg::VRTSfsadv61::RHEL5x8664;
@Pkg::VRTSfsadv61::RHEL5x8664::ISA = qw(Pkg::VRTSfsadv61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.39-6.el5.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.39-6.el5.x86_64",
        "libcrypto.so.6()(64bit)"  =>  "openssl-0.9.8e-12.el5_4.6.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.1.2-48.el5.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.1.2-48.el5.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libssl.so.6()(64bit)"  =>  "openssl-0.9.8e-12.el5_4.6.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.1.2-48.el5.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.1.2-48.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.1.2-48.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.1.2-48.el5.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-3.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.39-6.el5.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.39-6.el5.x86_64",
        "libcrypto.so.6()(64bit)"  =>  "openssl-0.9.8e-12.el5_5.7.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.1.2-50.el5.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.1.2-50.el5.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libssl.so.6()(64bit)"  =>  "openssl-0.9.8e-12.el5_5.7.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.1.2-50.el5.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.1.2-50.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.1.2-50.el5.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.39-6.el5.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.39-6.el5.x86_64",
        "libcrypto.so.6()(64bit)"  =>  "openssl-0.9.8e-20.el5.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.1.2-51.el5.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.1.2-51.el5.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libssl.so.6()(64bit)"  =>  "openssl-0.9.8e-20.el5.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.1.2-51.el5.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.1.2-51.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.1.2-51.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.1.2-51.el5.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-4.el5.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.39-8.el5.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.39-8.el5.x86_64",
        "libcrypto.so.6()(64bit)"  =>  "openssl-0.9.8e-22.el5.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.1.2-52.el5.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.1.2-52.el5.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libssl.so.6()(64bit)"  =>  "openssl-0.9.8e-22.el5.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.1.2-52.el5.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.1.2-52.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.1.2-52.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.1.2-52.el5.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-4.el5.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.39-8.el5.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.39-8.el5.x86_64",
        "libcrypto.so.6()(64bit)"  =>  "openssl-0.9.8e-26.el5_9.1.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.1.2-54.el5.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.1.2-54.el5.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libssl.so.6()(64bit)"  =>  "openssl-0.9.8e-26.el5_9.1.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.1.2-54.el5.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.1.2-54.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.1.2-54.el5.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.1.2-54.el5.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-7.el5.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTSfsadv61::RHEL6x8664;
@Pkg::VRTSfsadv61::RHEL6x8664::ISA = qw(Pkg::VRTSfsadv61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.49-6.el6.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.49-6.el6.x86_64",
        "libcrypto.so.10()(64bit)"  =>  "openssl-1.0.0-20.el6_2.5.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.4.6-4.el6.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.4.6-4.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libssl.so.10()(64bit)"  =>  "openssl-1.0.0-20.el6_2.5.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.4.6-4.el6.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.4.6-4.el6.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.4.6-4.el6.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.4.6-4.el6.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-27.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",    
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.49-6.el6.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.49-6.el6.x86_64",
        "libcrypto.so.10()(64bit)"  =>  "openssl-1.0.0-27.el6.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.4.7-3.el6.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.4.7-3.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libssl.so.10()(64bit)"  =>  "openssl-1.0.0-27.el6.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.4.7-3.el6.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.4.7-3.el6.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.4.7-3.el6.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.4.7-3.el6.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-29.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    return;
}

package Pkg::VRTSfsadv61::SLES10x8664;
@Pkg::VRTSfsadv61::SLES10x8664::ISA = qw(Pkg::VRTSfsadv61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.41-0.15.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.41-0.15.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTSfsadv61::SLES11x8664;
@Pkg::VRTSfsadv61::SLES11x8664::ISA = qw(Pkg::VRTSfsadv61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.47-30.34.29.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.47-30.34.29.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc46-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc46-4.6.1_20110701-0.13.9.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++46-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++46-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++46-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++46-4.6.1_20110701-0.13.9.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.3-106.34.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.47-30.34.29.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.47-30.34.29.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc_s1-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc_s1-4.7.2_20130108-0.15.45.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++6-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++6-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++6-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++6-4.7.2_20130108-0.15.45.x86_64",
        "libz.so.1()(64bit)"  =>  "zlib-1.2.7-0.10.128.x86_64",    
    };
    return;
}

1;
