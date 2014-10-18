use strict;

package Pkg::VRTScavf60::Common;
@Pkg::VRTScavf60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTScavf';
    $pkg->{name}=Msg::new("Veritas Cluster Server Agents for Cluster File System")->{msg};
    #$pkg->{startprocs}=[ qw(cavf51) ];
    #$pkg->{stopprocs}=[ qw(cavf51) ];
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTScavf60::AIX;
@Pkg::VRTScavf60::AIX::ISA = qw(Pkg::VRTScavf60::Common);

package Pkg::VRTScavf60::HPUX;
@Pkg::VRTScavf60::HPUX::ISA = qw(Pkg::VRTScavf60::Common);

package Pkg::VRTScavf60::Linux;
@Pkg::VRTScavf60::Linux::ISA = qw(Pkg::VRTScavf60::Common);

package Pkg::VRTScavf60::RHEL5x8664;
@Pkg::VRTScavf60::RHEL5x8664::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "/bin/ksh"  =>  "ksh-20100202-1.el5_5.1.x86_64",
        "libcrypt.so.1"  =>  "glibc-2.5-58.i686",
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "perl(Exporter)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(Fcntl)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(POSIX)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(Socket)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(strict)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "perl(warnings)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTScavf60::RHEL6x8664;
@Pkg::VRTScavf60::RHEL6x8664::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "/bin/ksh"  =>  "ksh-20100621-6.el6.x86_64 mksh-39-5.el6.x86_64",
        "libcrypt.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.5-6.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.5-6.el6.i686",
        "perl(Exporter)"  =>  "perl-5.10.1-119.el6.x86_64",
        "perl(Fcntl)"  =>  "perl-5.10.1-119.el6.x86_64",
        "perl(POSIX)"  =>  "perl-5.10.1-119.el6.x86_64",
        "perl(Socket)"  =>  "perl-5.10.1-119.el6.x86_64",
        "perl(strict)"  =>  "perl-5.10.1-119.el6.x86_64",
        "perl(warnings)"  =>  "perl-5.10.1-119.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
    };
    return;
}

package Pkg::VRTScavf60::SLES10x8664;
@Pkg::VRTScavf60::SLES10x8664::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "/bin/ksh"  =>  "ksh-93t-13.17.19.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTScavf60::SLES11x8664;
@Pkg::VRTScavf60::SLES11x8664::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "/bin/ksh"  =>  "ksh-93t-9.9.8.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libstdc++.so.6"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
    };
    return;
}

package Pkg::VRTScavf60::RHEL5ppc64;
@Pkg::VRTScavf60::RHEL5ppc64::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libcrypt.so.1'  =>  'glibc-2.5-24.ppc',
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTScavf60::SLES10ppc64;
@Pkg::VRTScavf60::SLES10ppc64::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
    };
    return;
}

package Pkg::VRTScavf60::SLES11ppc64;
@Pkg::VRTScavf60::SLES11ppc64::ISA = qw(Pkg::VRTScavf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libstdc++.so.6'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
    };
    return;
}

package Pkg::VRTScavf60::SunOS;
@Pkg::VRTScavf60::SunOS::ISA = qw(Pkg::VRTScavf60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{ospkgs}{all}=[ 'SUNWbtool' ];
    return;
}

package Pkg::VRTScavf60::Sol11sparc;
@Pkg::VRTScavf60::Sol11sparc::ISA = qw(Pkg::VRTScavf60::SunOS);
 
sub init_padv {
    my $pkg=shift;
    $pkg->{ospkgs}{all}=[];
    return;
}
 
package Pkg::VRTScavf60::Sol11x64;
@Pkg::VRTScavf60::Sol11x64::ISA = qw(Pkg::VRTScavf60::Sol11sparc);

1;
