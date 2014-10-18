use strict;

package Pkg::VRTSgms60::Common;
@Pkg::VRTSgms60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSgms';
    $pkg->{name}=Msg::new("Veritas Group Messaging Services")->{msg};

    $pkg->{startprocs}=[ qw(vxgms60) ];
    $pkg->{stopprocs}=[ qw(vxgms60) ];
    return;
}

package Pkg::VRTSgms60::AIX;
@Pkg::VRTSgms60::AIX::ISA = qw(Pkg::VRTSgms60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotcheckinstalllog}=1;
    return;
}

package Pkg::VRTSgms60::HPUX;
@Pkg::VRTSgms60::HPUX::ISA = qw(Pkg::VRTSgms60::Common);

package Pkg::VRTSgms60::Linux;
@Pkg::VRTSgms60::Linux::ISA = qw(Pkg::VRTSgms60::Common);

package Pkg::VRTSgms60::RHEL5x8664;
@Pkg::VRTSgms60::RHEL5x8664::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTSgms60::RHEL6x8664;
@Pkg::VRTSgms60::RHEL6x8664::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
    };
    return;
}

package Pkg::VRTSgms60::SLES10x8664;
@Pkg::VRTSgms60::SLES10x8664::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
    };
    return;
}

package Pkg::VRTSgms60::SLES11x8664;
@Pkg::VRTSgms60::SLES11x8664::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
    };
    return;
}

package Pkg::VRTSgms60::SLES10ppc64;
@Pkg::VRTSgms60::SLES10ppc64::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
    };
    return;
}

package Pkg::VRTSgms60::SLES11ppc64;
@Pkg::VRTSgms60::SLES11ppc64::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
    };
    return;
}

package Pkg::VRTSgms60::RHEL5ppc64;
@Pkg::VRTSgms60::RHEL5ppc64::ISA = qw(Pkg::VRTSgms60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}


package Pkg::VRTSgms60::SunOS;
@Pkg::VRTSgms60::SunOS::ISA = qw(Pkg::VRTSgms60::Common);

1;
