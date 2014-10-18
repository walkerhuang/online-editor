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

package Pkg::VRTSaslapm61::Common;
@Pkg::VRTSaslapm61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSaslapm';
    $pkg->{name}=Msg::new("Volume Manager - ASL/APM")->{msg};
    return;
}

package Pkg::VRTSaslapm61::AIX;
@Pkg::VRTSaslapm61::AIX::ISA = qw(Pkg::VRTSaslapm61::Common);

package Pkg::VRTSaslapm61::HPUX;
@Pkg::VRTSaslapm61::HPUX::ISA = qw(Pkg::VRTSaslapm61::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSaslapm61::Linux;
@Pkg::VRTSaslapm61::Linux::ISA = qw(Pkg::VRTSaslapm61::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSaslapm61::SunOS;
@Pkg::VRTSaslapm61::SunOS::ISA = qw(Pkg::VRTSaslapm61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{ospkgs}{all}=[ 'SUNWcsu' ];
    return;
}

package Pkg::VRTSaslapm61::Sol11sparc;
@Pkg::VRTSaslapm61::Sol11sparc::ISA = qw(Pkg::VRTSaslapm61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    $pkg->{ospkgs}{all}=[];
    return;
}

package Pkg::VRTSaslapm61::Sol11x64;
@Pkg::VRTSaslapm61::Sol11x64::ISA = qw(Pkg::VRTSaslapm61::Sol11sparc);

1;
