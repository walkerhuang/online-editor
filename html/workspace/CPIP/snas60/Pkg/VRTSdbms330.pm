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

package Pkg::VRTSdbms330::Common;
@Pkg::VRTSdbms330::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbms3';
    $pkg->{name}=Msg::new("Symantec Shared DBMS")->{msg};
    $pkg->{gavers} = '3.0.230.0';

    return;
}

package Pkg::VRTSdbms330::AIX;
@Pkg::VRTSdbms330::AIX::ISA = qw(Pkg::VRTSdbms330::Common);

package Pkg::VRTSdbms330::HPUX;
@Pkg::VRTSdbms330::HPUX::ISA = qw(Pkg::VRTSdbms330::Common);

package Pkg::VRTSdbms330::Linux;
@Pkg::VRTSdbms330::Linux::ISA = qw(Pkg::VRTSdbms330::Common);

package Pkg::VRTSdbms330::RHEL6x8664;
@Pkg::VRTSdbms330::RHEL6x8664::ISA = qw(Pkg::VRTSdbms330::Linux);

sub init_plat {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.5'}={
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.3)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libdl.so.2"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libm.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libncurses.so.5"  =>  "ncurses-libs-5.7-3.20090208.el6.i686",
        "libncurses.so.5()(64bit)"  =>  "ncurses-libs-5.7-3.20090208.el6.x86_64",
        "libpthread.so.0"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libX11.so.6()(64bit)"  =>  "libX11-1.5.0-4.el6.x86_64",
        "libXm.so.3()(64bit)"  =>  "openmotif22-2.2.3-19.el6.x86_64",
    };

    return;
}

package Pkg::VRTSdbms330::SunOS;
@Pkg::VRTSdbms330::SunOS::ISA = qw(Pkg::VRTSdbms330::Common);

1;
