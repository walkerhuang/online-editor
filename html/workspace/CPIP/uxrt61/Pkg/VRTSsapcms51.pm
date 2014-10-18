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

package Pkg::VRTSsapcms51::Common;
@Pkg::VRTSsapcms51::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsapcms';
    $pkg->{name}=Msg::new("High Availability Agent for SAP Components")->{msg};
    return;
}
package Pkg::VRTSsapcms51::AIX;
@Pkg::VRTSsapcms51::AIX::ISA = qw(Pkg::VRTSsapcms51::Common);

package Pkg::VRTSsapcms51::HPUX;
@Pkg::VRTSsapcms51::HPUX::ISA = qw(Pkg::VRTSsapcms51::Common);

package Pkg::VRTSsapcms51::Linux;
@Pkg::VRTSsapcms51::Linux::ISA = qw(Pkg::VRTSsapcms51::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{gavers}='5.1.5.0';
    return;
}

package Pkg::VRTSsapcms51::SunOS;
@Pkg::VRTSsapcms51::SunOS::ISA = qw(Pkg::VRTSsapcms51::Common);

1;
