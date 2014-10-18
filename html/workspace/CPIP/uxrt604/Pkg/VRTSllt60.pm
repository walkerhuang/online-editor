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

package Pkg::VRTSllt60::Common;
@Pkg::VRTSllt60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSllt';
    $pkg->{name}=Msg::new("Veritas Low Latency Transport")->{msg};
    # some HPUX deviance
    $pkg->{startprocs}=[ qw(llt60) ];
    $pkg->{stopprocs}=[ qw(llt60) ];
    return;
}

package Pkg::VRTSllt60::AIX;
@Pkg::VRTSllt60::AIX::ISA = qw(Pkg::VRTSllt60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSllt.rte) ];
    return;
}
sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    $pkg->{donotrmonupgrade}=1 if(Cfg::opt("upgrade_kernelpkgs"));
    return;
}

package Pkg::VRTSllt60::HPUX;
@Pkg::VRTSllt60::HPUX::ISA = qw(Pkg::VRTSllt60::Common);

package Pkg::VRTSllt60::Linux;
@Pkg::VRTSllt60::Linux::ISA = qw(Pkg::VRTSllt60::Common);

package Pkg::VRTSllt60::RHEL5x8664;
@Pkg::VRTSllt60::RHEL5x8664::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTSllt60::RHEL6x8664;
@Pkg::VRTSllt60::RHEL6x8664::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6_4.2.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6_4.2.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.107.el6_4.2.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6_4.2.i686 glibc-2.12-1.107.el6_4.2.x86_64",
    };
    return;
}

package Pkg::VRTSllt60::SLES10x8664;
@Pkg::VRTSllt60::SLES10x8664::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
    };
    return;
}

package Pkg::VRTSllt60::SLES11x8664;
@Pkg::VRTSllt60::SLES11x8664::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
    };
    return;
}

package Pkg::VRTSllt60::RHEL5ppc64;
@Pkg::VRTSllt60::RHEL5ppc64::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSllt60::SLES10ppc64;
@Pkg::VRTSllt60::SLES10ppc64::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
    };
    return;
}

package Pkg::VRTSllt60::SLES11ppc64;
@Pkg::VRTSllt60::SLES11ppc64::ISA = qw(Pkg::VRTSllt60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
    };
    return;
}

package Pkg::VRTSllt60::SunOS;
@Pkg::VRTSllt60::SunOS::ISA = qw(Pkg::VRTSllt60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{smf}=['/var/svc/manifest/system/llt.xml', '/lib/svc/method/llt'];
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
