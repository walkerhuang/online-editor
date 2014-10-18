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

package Pkg::VRTSsapwebas7150::Common;
@Pkg::VRTSsapwebas7150::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsapwebas71';
    $pkg->{name}=Msg::new("High Availability Agent for SAP WebAS")->{msg};
    $pkg->{gavers}='5.0.9.0';
    return;
}

package Pkg::VRTSsapwebas7150::AIX;
@Pkg::VRTSsapwebas7150::AIX::ISA = qw(Pkg::VRTSsapwebas7150::Common);

package Pkg::VRTSsapwebas7150::HPUX;
@Pkg::VRTSsapwebas7150::HPUX::ISA = qw(Pkg::VRTSsapwebas7150::Common);

package Pkg::VRTSsapwebas7150::Linux;
@Pkg::VRTSsapwebas7150::Linux::ISA = qw(Pkg::VRTSsapwebas7150::Common);

package Pkg::VRTSsapwebas7150::SunOS;
@Pkg::VRTSsapwebas7150::SunOS::ISA = qw(Pkg::VRTSsapwebas7150::Common);
1;
