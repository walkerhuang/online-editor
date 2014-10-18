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

package Pkg::VRTSsapwebas7160::Common;
@Pkg::VRTSsapwebas7160::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsapwebas71';
    $pkg->{name}=Msg::new("Veritas High Availability Agent for SAP WebAS by Symantec")->{msg};
    $pkg->{gavers}='5.0';
    $pkg->{mpok}=1;
    return;
}

package Pkg::VRTSsapwebas7160::AIX;
@Pkg::VRTSsapwebas7160::AIX::ISA = qw(Pkg::VRTSsapwebas7160::Common);

package Pkg::VRTSsapwebas7160::HPUX;
@Pkg::VRTSsapwebas7160::HPUX::ISA = qw(Pkg::VRTSsapwebas7160::Common);

package Pkg::VRTSsapwebas7160::Linux;
@Pkg::VRTSsapwebas7160::Linux::ISA = qw(Pkg::VRTSsapwebas7160::Common);

package Pkg::VRTSsapwebas7160::SunOS;
@Pkg::VRTSsapwebas7160::SunOS::ISA = qw(Pkg::VRTSsapwebas7160::Common);
1;
