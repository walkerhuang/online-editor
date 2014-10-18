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

package Pkg::VRTSvcsvmw60::Common;
@Pkg::VRTSvcsvmw60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}="VRTSvcsvmw";
    $pkg->{name}=Msg::new("ApplicationHA Virtual Machine Wizards for application monitoring configurations, by Symantec.")->{msg};
    $pkg->{mpok} = 1;
}

package Pkg::VRTSvcsvmw60::AIX;
@Pkg::VRTSvcsvmw60::AIX::ISA = qw(Pkg::VRTSvcsvmw60::Common);

package Pkg::VRTSvcsvmw60::HPUX;
@Pkg::VRTSvcsvmw60::HPUX::ISA = qw(Pkg::VRTSvcsvmw60::Common);

package Pkg::VRTSvcsvmw60::Linux;
@Pkg::VRTSvcsvmw60::Linux::ISA = qw(Pkg::VRTSvcsvmw60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{installonpatchupgrade}=1;
}

sub set_install_sys {
    my ($pkg,$sys,$prod) = @_;
    # If the product is not VCS and SFHA, do not install VRTSvcsvmw if it's not installed before upgrade
    if ($prod->{prod}!~/VCS/ && $prod->{prod}!~/SFHA/) {
        return 0 unless ($pkg->version_sys($sys));
        $pkg->{installonpatchupgrade}=0;
    }
    return $pkg->SUPER::set_install_sys($sys);
}

package Pkg::VRTSvcsvmw60::SunOS;
@Pkg::VRTSvcsvmw60::SunOS::ISA = qw(Pkg::VRTSvcsvmw60::Common);

1;
