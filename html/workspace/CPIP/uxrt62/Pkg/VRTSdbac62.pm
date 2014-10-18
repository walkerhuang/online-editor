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

package Pkg::VRTSdbac62::Common;
@Pkg::VRTSdbac62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbac';
    $pkg->{name}=Msg::new("Oracle Real Application Cluster Support Package")->{msg};
    $pkg->{stopprocs}=[ qw(vcsmm62 lmx62) ];
    $pkg->{startprocs}=[ qw(vcsmm62 lmx62) ];
    $pkg->{extra_types} = ['/etc/VRTSvcs/conf/PrivNIC.cf',
                    '/etc/VRTSvcs/conf/MultiPrivNIC.cf',
                    '/etc/VRTSvcs/conf/OracleServiceTypes.cf',
                    '/etc/VRTSvcs/conf/CRSResource.cf',
                    '/etc/VRTSvcs/conf/CSSD.cf',
                    ];
    return;
}

package Pkg::VRTSdbac62::AIX;
@Pkg::VRTSdbac62::AIX::ISA = qw(Pkg::VRTSdbac62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSdbac.rte) ];
    return;
}

package Pkg::VRTSdbac62::HPUX;
@Pkg::VRTSdbac62::HPUX::ISA = qw(Pkg::VRTSdbac62::Common);

package Pkg::VRTSdbac62::Linux;
@Pkg::VRTSdbac62::Linux::ISA = qw(Pkg::VRTSdbac62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{startprocs}=EDRu::arrdel($pkg->{startprocs}, 'lmx62');
    $pkg->{stopprocs}=EDRu::arrdel($pkg->{stopprocs}, 'lmx62');
    return;
}

package Pkg::VRTSdbac62::SunOS;
@Pkg::VRTSdbac62::SunOS::ISA = qw(Pkg::VRTSdbac62::Common);

package Pkg::VRTSdbac62::Sol11sparc;
@Pkg::VRTSdbac62::Sol11sparc::ISA = qw(Pkg::VRTSdbac62::SunOS);

sub init_plat {
    my $pkg=shift;
    $pkg->{startprocs}=EDRu::arrdel($pkg->{startprocs}, 'lmx62');
    $pkg->{stopprocs}=EDRu::arrdel($pkg->{stopprocs}, 'lmx62');
    return;
}
1;
