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

package Pkg::VRTSacclib52::Common;
@Pkg::VRTSacclib52::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSacclib';
    $pkg->{name}=Msg::new("Cluster Server ACC Library")->{msg};
    $pkg->{gavers}='5.2.4.0';
    return;
}

package Pkg::VRTSacclib52::AIX;
@Pkg::VRTSacclib52::AIX::ISA = qw(Pkg::VRTSacclib52::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSacclib.rte) ];
    return;
}

package Pkg::VRTSacclib52::HPUX;
@Pkg::VRTSacclib52::HPUX::ISA = qw(Pkg::VRTSacclib52::Common);

package Pkg::VRTSacclib52::Linux;
@Pkg::VRTSacclib52::Linux::ISA = qw(Pkg::VRTSacclib52::Common);

package Pkg::VRTSacclib52::SunOS;
@Pkg::VRTSacclib52::SunOS::ISA = qw(Pkg::VRTSacclib52::Common);

1;
