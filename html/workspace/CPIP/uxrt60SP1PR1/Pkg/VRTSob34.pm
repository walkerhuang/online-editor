use strict;

package Pkg::VRTSob34::Common;
@Pkg::VRTSob34::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSob';
    $pkg->{name}=Msg::new("Veritas Enterprise Administrator Service by Symantec")->{msg};
    $pkg->{stopprocs}=[ qw(vxsvc34) ];
    $pkg->{startprocs}=[ qw(vxsvc34) ];
    $pkg->{gavers}='3.4.525.0';
    return;
}

package Pkg::VRTSob34::AIX;
@Pkg::VRTSob34::AIX::ISA = qw(Pkg::VRTSob34::Common);

package Pkg::VRTSob34::HPUX;
@Pkg::VRTSob34::HPUX::ISA = qw(Pkg::VRTSob34::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{donotrmonupgrade}=1;
    $pkg->{ospatches}{'11.31IA'}=['PHSS_39898'];
    return;
}

package Pkg::VRTSob34::Linux;
@Pkg::VRTSob34::Linux::ISA = qw(Pkg::VRTSob34::Common);

package Pkg::VRTSob34::RHEL5x8664;
@Pkg::VRTSob34::RHEL5x8664::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GCC_3.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3.4)"  =>  "glibc-2.5-58.i686",
        "libcrypt.so.1"  =>  "glibc-2.5-58.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libpam.so.0"  =>  "pam-0.99.6.2-6.el5_5.2.i386",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "libresolv.so.2"  =>  "glibc-2.5-58.i686",
        "librt.so.1"  =>  "glibc-2.5-58.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-50.el5.i386",
    };
    return;
}

package Pkg::VRTSob34::RHEL6x8664;
@Pkg::VRTSob34::RHEL6x8664::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GCC_3.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.3.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.3.4)"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.5-6.el6.i686",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.4.5-6.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.25.el6.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libpam.so.0"  =>  "pam-1.1.1-8.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libresolv.so.2"  =>  "glibc-2.12-1.25.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.5-6.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.5-6.el6.i686",
    };
    return;
}

package Pkg::VRTSob34::SLES10x8664;
@Pkg::VRTSob34::SLES10x8664::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GCC_3.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3.4)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpam.so.0"  =>  "pam-32bit-0.99.6.3-28.23.15.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTSob34::SLES11x8664;
@Pkg::VRTSob34::SLES11x8664::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GCC_3.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3.4)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpam.so.0"  =>  "pam-32bit-1.0.4-0.5.12.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
    };
    return;
}

package Pkg::VRTSob34::RHEL5ppc64;
@Pkg::VRTSob34::RHEL5ppc64::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libcrypt.so.1'  =>  'glibc-2.5-24.ppc',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3.4)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.3)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libm.so.6'  =>  'glibc-2.5-24.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'libpam.so.0'  =>  'pam-0.99.6.2-3.27.el5.ppc',
        'libpthread.so.0'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libresolv.so.2'  =>  'glibc-2.5-24.ppc',
        'librt.so.1'  =>  'glibc-2.5-24.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2-42.el5.ppc',
    };
    return;
}

package Pkg::VRTSob34::SLES10ppc64;
@Pkg::VRTSob34::SLES10ppc64::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.4)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_3.3)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libm.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libpam.so.0'  =>  'pam-0.99.6.3-28.13.ppc',
        'libpthread.so.0'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libresolv.so.2'  =>  'glibc-2.4-31.54.ppc',
        'librt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
    };
    return;
}

package Pkg::VRTSob34::SLES11ppc64;
@Pkg::VRTSob34::SLES11ppc64::ISA = qw(Pkg::VRTSob34::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libgcc_s.so.1'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_3.3)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libm.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpam.so.0'  =>  'pam-32bit-1.0.2-20.1.ppc64',
        'libpthread.so.0'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libresolv.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'librt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libstdc++.so.6'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
    };
    return;
}

package Pkg::VRTSob34::SunOS;
@Pkg::VRTSob34::SunOS::ISA = qw(Pkg::VRTSob34::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{responsefile}="SECURITYADMINPASSWORD=\nROOTAGENTPASSWORD=\nCONFIGURESECURITY=n\n";
    $pkg->{languagepkgs}{mu}=[qw(VRTSmuob)];
    return;
}

1;
