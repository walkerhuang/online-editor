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

package Pkg::VRTSatClient50::Common;
@Pkg::VRTSatClient50::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSatClient';
    $pkg->{gavers}='5.0.32.0';
    $pkg->{osuuid}='/etc/vx/uuid/bin/osuuid';
    $pkg->{name}=Msg::new("Product Authentication Service Client")->{msg};
    $pkg->{softdeps}=[ qw(VRTScmcm VRTSvcs) ];
    return;
}

package Pkg::VRTSatClient50::AIX;
@Pkg::VRTSatClient50::AIX::ISA = qw(Pkg::VRTSatClient50::Common);

package Pkg::VRTSatClient50::HPUX;
@Pkg::VRTSatClient50::HPUX::ISA = qw(Pkg::VRTSatClient50::Common);

package Pkg::VRTSatClient50::Linux;
@Pkg::VRTSatClient50::Linux::ISA = qw(Pkg::VRTSatClient50::Common);

package Pkg::VRTSatClient50::SunOS;
@Pkg::VRTSatClient50::SunOS::ISA = qw(Pkg::VRTSatClient50::Common);

1;
