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

package Pkg::VRTSgms61::Common;
@Pkg::VRTSgms61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSgms';
    $pkg->{name}=Msg::new("Group Messaging Services")->{msg};

    $pkg->{startprocs}=[ qw(vxgms61) ];
    $pkg->{stopprocs}=[ qw(vxgms61) ];
    return;
}

package Pkg::VRTSgms61::AIX;
@Pkg::VRTSgms61::AIX::ISA = qw(Pkg::VRTSgms61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotcheckinstalllog}=1;
    return;
}

package Pkg::VRTSgms61::HPUX;
@Pkg::VRTSgms61::HPUX::ISA = qw(Pkg::VRTSgms61::Common);

package Pkg::VRTSgms61::Linux;
@Pkg::VRTSgms61::Linux::ISA = qw(Pkg::VRTSgms61::Common);

package Pkg::VRTSgms61::RHEL5x8664;
@Pkg::VRTSgms61::RHEL5x8664::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",    
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTSgms61::RHEL6x8664;
@Pkg::VRTSgms61::RHEL6x8664::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",    
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.x86_64",
    };
    return;
}

package Pkg::VRTSgms61::SLES10x8664;
@Pkg::VRTSgms61::SLES10x8664::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
    };
    return;
}

package Pkg::VRTSgms61::SLES11x8664;
@Pkg::VRTSgms61::SLES11x8664::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
    };
    return;
}

package Pkg::VRTSgms61::SLES10ppc64;
@Pkg::VRTSgms61::SLES10ppc64::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
    };
    return;
}

package Pkg::VRTSgms61::SLES11ppc64;
@Pkg::VRTSgms61::SLES11ppc64::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
    };
    return;
}

package Pkg::VRTSgms61::RHEL5ppc64;
@Pkg::VRTSgms61::RHEL5ppc64::ISA = qw(Pkg::VRTSgms61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}


package Pkg::VRTSgms61::SunOS;
@Pkg::VRTSgms61::SunOS::ISA = qw(Pkg::VRTSgms61::Common);

package Pkg::VRTSgms61::Sol11sparc;
@Pkg::VRTSgms61::Sol11sparc::ISA = qw(Pkg::VRTSgms61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    return;
}

package Pkg::VRTSgms61::Sol11x64;
@Pkg::VRTSgms61::Sol11x64::ISA = qw(Pkg::VRTSgms61::Sol11sparc);

1;
