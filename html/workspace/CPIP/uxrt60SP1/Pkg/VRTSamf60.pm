use strict;

package Pkg::VRTSamf60::Common;
@Pkg::VRTSamf60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSamf';
    $pkg->{name}=Msg::new("Veritas Asynchronous Monitoring Framework by Symantec")->{msg};
    $pkg->{installonpatchupgrade}=1;
    $pkg->{stopprocs}= [ qw(amf60) ];
    $pkg->{startprocs}= [ qw(amf60) ];
    return;
}

package Pkg::VRTSamf60::AIX;
@Pkg::VRTSamf60::AIX::ISA = qw(Pkg::VRTSamf60::Common);

package Pkg::VRTSamf60::HPUX;
@Pkg::VRTSamf60::HPUX::ISA = qw(Pkg::VRTSamf60::Common);

package Pkg::VRTSamf60::Linux;
@Pkg::VRTSamf60::Linux::ISA = qw(Pkg::VRTSamf60::Common);

package Pkg::VRTSamf60::RHEL5x8664;
@Pkg::VRTSamf60::RHEL5x8664::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTSamf60::RHEL6x8664;
@Pkg::VRTSamf60::RHEL6x8664::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
    };
    return;
}

package Pkg::VRTSamf60::SLES10x8664;
@Pkg::VRTSamf60::SLES10x8664::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
    };
    return;
}

package Pkg::VRTSamf60::SLES11x8664;
@Pkg::VRTSamf60::SLES11x8664::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
    };
    return;
}

package Pkg::VRTSamf60::RHEL5ppc64;
@Pkg::VRTSamf60::RHEL5ppc64::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSamf60::SLES10ppc64;
@Pkg::VRTSamf60::SLES10ppc64::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
    };
    return;
}

package Pkg::VRTSamf60::SLES11ppc64;
@Pkg::VRTSamf60::SLES11ppc64::ISA = qw(Pkg::VRTSamf60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
    };
    return;
}

package Pkg::VRTSamf60::SunOS;
@Pkg::VRTSamf60::SunOS::ISA = qw(Pkg::VRTSamf60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{smf}=['/var/svc/manifest/system/amf.xml', '/lib/svc/method/amf'];
    return;
}

sub preremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS60');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS60');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

1;
