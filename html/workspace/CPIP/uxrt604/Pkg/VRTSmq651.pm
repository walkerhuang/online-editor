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

package Pkg::VRTSmq651::Common;
@Pkg::VRTSmq651::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSmq6';
    $pkg->{name}=Msg::new("Veritas High Availability Agent 5.1 for WebSphereMQ and WebSphereMQFTE by Symantec")->{msg};
    $pkg->{mpok} = 1;
    return;
}
package Pkg::VRTSmq651::AIX;
@Pkg::VRTSmq651::AIX::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::HPUX;
@Pkg::VRTSmq651::HPUX::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::Linux;
@Pkg::VRTSmq651::Linux::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::SunOS;
@Pkg::VRTSmq651::SunOS::ISA = qw(Pkg::VRTSmq651::Common);

1;
