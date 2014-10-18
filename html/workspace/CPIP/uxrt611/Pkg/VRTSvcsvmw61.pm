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

package Pkg::VRTSvcsvmw61::Common;
@Pkg::VRTSvcsvmw61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcsvmw';
    $pkg->{name}=Msg::new("ApplicationHA Virtual Machine Wizards for application monitoring configurations")->{msg};
    $pkg->{unkernelpkg}=1;
    $pkg->{installpkgslast}=1;
    $pkg->{installpatcheslast}=1;
    return;
}

package Pkg::VRTSvcsvmw61::AIX;
@Pkg::VRTSvcsvmw61::AIX::ISA = qw(Pkg::VRTSvcsvmw61::Common);

package Pkg::VRTSvcsvmw61::HPUX;
@Pkg::VRTSvcsvmw61::HPUX::ISA = qw(Pkg::VRTSvcsvmw61::Common);

package Pkg::VRTSvcsvmw61::Linux;
@Pkg::VRTSvcsvmw61::Linux::ISA = qw(Pkg::VRTSvcsvmw61::Common);

package Pkg::VRTSvcsvmw61::SunOS;
@Pkg::VRTSvcsvmw61::SunOS::ISA = qw(Pkg::VRTSvcsvmw61::Common);

1;
