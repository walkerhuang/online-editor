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

package Pkg::VRTSaslapm62::Common;
@Pkg::VRTSaslapm62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSaslapm';
    $pkg->{name}=Msg::new("Volume Manager - ASL/APM")->{msg};
    return;
}

package Pkg::VRTSaslapm62::AIX;
@Pkg::VRTSaslapm62::AIX::ISA = qw(Pkg::VRTSaslapm62::Common);

package Pkg::VRTSaslapm62::HPUX;
@Pkg::VRTSaslapm62::HPUX::ISA = qw(Pkg::VRTSaslapm62::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSaslapm62::Linux;
@Pkg::VRTSaslapm62::Linux::ISA = qw(Pkg::VRTSaslapm62::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSaslapm62::SunOS;
@Pkg::VRTSaslapm62::SunOS::ISA = qw(Pkg::VRTSaslapm62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{ospkgs}{all}=[ 'SUNWcsu' ];
    return;
}

package Pkg::VRTSaslapm62::Sol11sparc;
@Pkg::VRTSaslapm62::Sol11sparc::ISA = qw(Pkg::VRTSaslapm62::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    $pkg->{ospkgs}{all}=[];
    return;
}

package Pkg::VRTSaslapm62::Sol11x64;
@Pkg::VRTSaslapm62::Sol11x64::ISA = qw(Pkg::VRTSaslapm62::Sol11sparc);

1;
