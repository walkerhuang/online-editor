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

package Pkg::VRTSvcswiz61::Common;
@Pkg::VRTSvcswiz61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}="VRTSvcswiz";
    $pkg->{name}=Msg::new("Cluster Server Wizards")->{msg};
    $pkg->{installpkgslast}=1;
    $pkg->{previouspkgnames}=[ qw(VRTSvcsvmw61) ];
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcswiz61::AIX;
@Pkg::VRTSvcswiz61::AIX::ISA = qw(Pkg::VRTSvcswiz61::Common);

package Pkg::VRTSvcswiz61::HPUX;
@Pkg::VRTSvcswiz61::HPUX::ISA = qw(Pkg::VRTSvcswiz61::Common);

package Pkg::VRTSvcswiz61::Linux;
@Pkg::VRTSvcswiz61::Linux::ISA = qw(Pkg::VRTSvcswiz61::Common);

package Pkg::VRTSvcswiz61::SunOS;
@Pkg::VRTSvcswiz61::SunOS::ISA = qw(Pkg::VRTSvcswiz61::Common);

1;
