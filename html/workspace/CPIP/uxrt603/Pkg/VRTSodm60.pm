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

package Pkg::VRTSodm60::Common;
@Pkg::VRTSodm60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSodm';
    $pkg->{name}=Msg::new("Veritas Oracle Disk Manager")->{msg};

    $pkg->{startprocs}=[ qw(odm60) ];
    $pkg->{stopprocs}=[ qw(odm60) ];
    return;
}

package Pkg::VRTSodm60::AIX;
@Pkg::VRTSodm60::AIX::ISA = qw(Pkg::VRTSodm60::Common);

package Pkg::VRTSodm60::HPUX;
@Pkg::VRTSodm60::HPUX::ISA = qw(Pkg::VRTSodm60::Common);

package Pkg::VRTSodm60::Linux;
@Pkg::VRTSodm60::Linux::ISA = qw(Pkg::VRTSodm60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSodm-platform VRTSodm-common) ];

    return;
}

package Pkg::VRTSodm60::RHEL5x8664;
@Pkg::VRTSodm60::RHEL5x8664::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "coreutils"  =>  "coreutils-5.97-23.el5_4.2.x86_64",
        "ed"  =>  "ed-0.2-39.el5_2.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "modutils"  =>  "module-init-tools-3.3-0.pre3.1.60.el5_5.1.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTSodm60::RHEL6x8664;
@Pkg::VRTSodm60::RHEL6x8664::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "coreutils"  =>  "coreutils-8.4-13.el6.x86_64",
        "ed"  =>  "ed-1.1-3.3.el6.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.25.el6.x86_64",
        "modutils"  =>  "module-init-tools-3.9-17.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
    };
    return;
}

package Pkg::VRTSodm60::SLES10x8664;
@Pkg::VRTSodm60::SLES10x8664::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "coreutils"  =>  "coreutils-5.93-22.21.17.x86_64",
        "ed"  =>  "ed-0.2-881.9.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "modutils"  =>  "module-init-tools-3.2.2-32.38.1.x86_64",
    };
    return;
}

package Pkg::VRTSodm60::SLES11x8664;
@Pkg::VRTSodm60::SLES11x8664::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "coreutils"  =>  "coreutils-6.12-32.17.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libm.so.6()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libnsl.so.1()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.1-0.17.4.x86_64",
        "modutils"  =>  "module-init-tools-3.11.1-1.3.5.x86_64",
    };
    return;
}

package Pkg::VRTSodm60::RHEL5ppc64;
@Pkg::VRTSodm60::RHEL5ppc64::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-5.97-14.el5.ppc',
        'ed'  =>  'ed-0.2-38.2.2.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libm.so.6()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libnsl.so.1()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0()(64bit)'  =>  'glibc-2.5-24.ppc64',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-2.5-24.ppc64',
        'modutils'  =>  'module-init-tools-3.3-0.pre3.1.37.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSodm60::SLES10ppc64;
@Pkg::VRTSodm60::SLES10ppc64::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-5.93-22.14.ppc',
        'ed'  =>  'ed-0.2-881.2.ppc',
        'libc.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libm.so.6()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libnsl.so.1()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0()(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-64bit-2.4-31.54.ppc',
        'modutils'  =>  'module-init-tools-3.2.2-32.27.ppc',
    };
    return;
}

package Pkg::VRTSodm60::SLES11ppc64;
@Pkg::VRTSodm60::SLES11ppc64::ISA = qw(Pkg::VRTSodm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'coreutils'  =>  'coreutils-6.12-32.17.ppc64',
        'libc.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libm.so.6()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libnsl.so.1()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0()(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3)(64bit)'  =>  'glibc-2.9-13.2.ppc64',
        'modutils'  =>  'module-init-tools-3.4-70.5.ppc64',
    };
    return;
}

package Pkg::VRTSodm60::SunOS;
@Pkg::VRTSodm60::SunOS::ISA = qw(Pkg::VRTSodm60::Common);

package Pkg::VRTSodm60::Sol11sparc;
@Pkg::VRTSodm60::Sol11sparc::ISA = qw(Pkg::VRTSodm60::SunOS);
 
sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    return;
}
 
package Pkg::VRTSodm60::Sol11x64;
@Pkg::VRTSodm60::Sol11x64::ISA = qw(Pkg::VRTSodm60::Sol11sparc);

1;
