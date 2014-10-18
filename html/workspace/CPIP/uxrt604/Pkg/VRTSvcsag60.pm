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

package Pkg::VRTSvcsag60::Common;
@Pkg::VRTSvcsag60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcsag';
    $pkg->{name}=Msg::new("Veritas Cluster Server Bundled Agents by Symantec")->{msg};
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcsag60::AIX;
@Pkg::VRTSvcsag60::AIX::ISA = qw(Pkg::VRTSvcsag60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSvcsag.rte) ];
    return;
}

package Pkg::VRTSvcsag60::HPUX;
@Pkg::VRTSvcsag60::HPUX::ISA = qw(Pkg::VRTSvcsag60::Common);

package Pkg::VRTSvcsag60::Linux;
@Pkg::VRTSvcsag60::Linux::ISA = qw(Pkg::VRTSvcsag60::Common);

package Pkg::VRTSvcsag60::SunOS;
@Pkg::VRTSvcsag60::SunOS::ISA = qw(Pkg::VRTSvcsag60::Common);

1;
