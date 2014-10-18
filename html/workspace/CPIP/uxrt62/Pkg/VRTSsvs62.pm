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

package Pkg::VRTSsvs62::Common;
@Pkg::VRTSsvs62::Common::ISA = qw(Pkg);

sub donotinstall_sys {
    my ($pkg,$sys) = @_;
    my ($pkgsys);

    $pkgsys = Obj::pkg($pkg->{pkgi},$sys->{padv},1);
    if (!$pkgsys) {
        $pkgsys = $pkg;
    }
    return $pkgsys->{donotinstall} || EDRu::inarr($pkgsys->{pkgi},@{$sys->{donotinstallpkgs}});
}

sub douninstall_sys {
    my ($pkg,$sys) = @_;
    my ($pkgsys);

    $pkgsys = Obj::pkg($pkg->{pkgi},$sys->{padv},1);
    if (!$pkgsys) {
        $pkgsys = $pkg;
    }
    return $pkgsys->{douninstall} || EDRu::inarr($pkgsys->{pkgi},@{$sys->{donotuninstallpkgs}});
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

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsvs';
    $pkg->{donotinstall}=1;
    $pkg->{douninstall}=1;
    $pkg->{donotupgrade}=1;
    $pkg->{name}=Msg::new("VirtualStore")->{msg};
    $pkg->{startprocs}=[ qw() ];
    $pkg->{stopprocs}=[ qw(svsweb62) ];
    return;
}

package Pkg::VRTSsvs62::AIX;
@Pkg::VRTSsvs62::AIX::ISA = qw(Pkg::VRTSsvs62::Common);

package Pkg::VRTSsvs62::HPUX;
@Pkg::VRTSsvs62::HPUX::ISA = qw(Pkg::VRTSsvs62::Common);

package Pkg::VRTSsvs62::Linux;
@Pkg::VRTSsvs62::Linux::ISA = qw(Pkg::VRTSsvs62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{nodeps}=1;
    return;
}

package Pkg::VRTSsvs62::SunOS;
@Pkg::VRTSsvs62::SunOS::ISA = qw(Pkg::VRTSsvs62::Common);

1;
