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

package Pkg::VRTSvcswiz62::Common;
@Pkg::VRTSvcswiz62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}="VRTSvcswiz";
    $pkg->{name}=Msg::new("Cluster Server Wizards")->{msg};
    $pkg->{installpkgslast}=1;
    $pkg->{previouspkgnames}=[ qw(VRTSvcsvmw62) ];
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcswiz62::AIX;
@Pkg::VRTSvcswiz62::AIX::ISA = qw(Pkg::VRTSvcswiz62::Common);

package Pkg::VRTSvcswiz62::HPUX;
@Pkg::VRTSvcswiz62::HPUX::ISA = qw(Pkg::VRTSvcswiz62::Common);

package Pkg::VRTSvcswiz62::Linux;
@Pkg::VRTSvcswiz62::Linux::ISA = qw(Pkg::VRTSvcswiz62::Common);

package Pkg::VRTSvcswiz62::SunOS;
@Pkg::VRTSvcswiz62::SunOS::ISA = qw(Pkg::VRTSvcswiz62::Common);

1;
