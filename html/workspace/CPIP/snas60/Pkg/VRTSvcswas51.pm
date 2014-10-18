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

package Pkg::VRTSvcswas51::Common;
@Pkg::VRTSvcswas51::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcswas';
    $pkg->{name}=Msg::new("High Availability Agent 5.1 for WebSphere Application Server")->{msg};
    return;
}
package Pkg::VRTSvcswas51::AIX;
@Pkg::VRTSvcswas51::AIX::ISA = qw(Pkg::VRTSvcswas51::Common);

package Pkg::VRTSvcswas51::HPUX;
@Pkg::VRTSvcswas51::HPUX::ISA = qw(Pkg::VRTSvcswas51::Common);

package Pkg::VRTSvcswas51::Linux;
@Pkg::VRTSvcswas51::Linux::ISA = qw(Pkg::VRTSvcswas51::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{gavers}='5.1.12.0';
    return;
}

package Pkg::VRTSvcswas51::SunOS;
@Pkg::VRTSvcswas51::SunOS::ISA = qw(Pkg::VRTSvcswas51::Common);

1;
