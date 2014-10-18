use strict;

package Pkg::VRTSfsadv60::Common;
@Pkg::VRTSfsadv60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSfsadv';
    $pkg->{name}=Msg::new("Veritas File System Advanced Solutions by Symantec")->{msg};
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

package Pkg::VRTSfsadv60::AIX;
@Pkg::VRTSfsadv60::AIX::ISA = qw(Pkg::VRTSfsadv60::Common);

package Pkg::VRTSfsadv60::HPUX;
@Pkg::VRTSfsadv60::HPUX::ISA = qw(Pkg::VRTSfsadv60::Common);

package Pkg::VRTSfsadv60::HPUX1131par;
@Pkg::VRTSfsadv60::HPUX1131par::ISA = qw(Pkg::VRTSfsadv60::HPUX);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotinstall} = 1;
    $pkg->{donotuninstall} = 1;
    $pkg->{donotupgrade} = 1;
    return;
}

package Pkg::VRTSfsadv60::Linux;
@Pkg::VRTSfsadv60::Linux::ISA = qw(Pkg::VRTSfsadv60::Common);

package Pkg::VRTSfsadv60::SunOS;
@Pkg::VRTSfsadv60::SunOS::ISA = qw(Pkg::VRTSfsadv60::Common);

package Pkg::VRTSfsadv60::RHEL5x8664;
@Pkg::VRTSfsadv60::RHEL5x8664::ISA = qw(Pkg::VRTSfsadv60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
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
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTSfsadv60::RHEL6x8664;
@Pkg::VRTSfsadv60::RHEL6x8664::ISA = qw(Pkg::VRTSfsadv60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.49-4.el6.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.49-4.el6.x86_64",
        "libcrypto.so.10()(64bit)"  =>  "openssl-1.0.0-10.el6.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc-4.4.5-6.el6.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc-4.4.5-6.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libssl.so.10()(64bit)"  =>  "openssl-1.0.0-10.el6.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++-4.4.5-6.el6.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++-4.4.5-6.el6.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++-4.4.5-6.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
    };
    return;
}

package Pkg::VRTSfsadv60::SLES10x8664;
@Pkg::VRTSfsadv60::SLES10x8664::ISA = qw(Pkg::VRTSfsadv60::Linux);

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

package Pkg::VRTSfsadv60::SLES11x8664;
@Pkg::VRTSfsadv60::SLES11x8664::ISA = qw(Pkg::VRTSfsadv60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libacl.so.1()(64bit)"  =>  "libacl-2.2.47-30.34.29.x86_64",
        "libacl.so.1(ACL_1.0)(64bit)"  =>  "libacl-2.2.47-30.34.29.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3.4)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libdl.so.2()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libgcc_s.so.1()(64bit)"  =>  "libgcc43-4.3.4_20091019-0.7.35.x86_64",
        "libgcc_s.so.1(GCC_3.0)(64bit)"  =>  "libgcc43-4.3.4_20091019-0.7.35.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.3)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "librt.so.1()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "librt.so.1(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libstdc++.so.6()(64bit)"  =>  "libstdc++43-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(CXXABI_1.3)(64bit)"  =>  "libstdc++43-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)(64bit)"  =>  "libstdc++43-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.5)(64bit)"  =>  "libstdc++43-4.3.4_20091019-0.7.35.x86_64",
    };
    return;
}

1;
