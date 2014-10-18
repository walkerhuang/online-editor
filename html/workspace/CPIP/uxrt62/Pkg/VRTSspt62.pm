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

package Pkg::VRTSspt62::Common;
@Pkg::VRTSspt62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSspt';
    $pkg->{name}=Msg::new("Software Support Tools")->{msg};
    $pkg->{softdeps}=[ qw(VRTSvcsvmw) ];
    return;
}

sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps, $vxvm, $vxfs, $vcs,$dep);
    if ($pkg->{softdeps}) {
        for my $dep (@{$pkg->{softdeps}}) {
            push (@softdeps, $dep) if ($sys->pkgvers($dep));
        }
    }
    if (Cfg::opt('uninstall')) {
        $vxvm = $sys->pkg('VRTSvxvm62');
        $vxfs = $sys->pkg('VRTSvxfs62');
        $vcs = $sys->pkg('VRTSvcs62');
        push (@softdeps, $vxvm->{pkg}) if ($vxvm->version_sys($sys));
        push (@softdeps, $vxfs->{pkg}) if ($vxfs->version_sys($sys));
        push (@softdeps, $vcs->{pkg}) if ($vcs->version_sys($sys));
    }
    return \@softdeps;
}

package Pkg::VRTSspt62::AIX;
@Pkg::VRTSspt62::AIX::ISA = qw(Pkg::VRTSspt62::Common);

package Pkg::VRTSspt62::HPUX;
@Pkg::VRTSspt62::HPUX::ISA = qw(Pkg::VRTSspt62::Common);

package Pkg::VRTSspt62::Linux;
@Pkg::VRTSspt62::Linux::ISA = qw(Pkg::VRTSspt62::Common);

package Pkg::VRTSspt62::SunOS;
@Pkg::VRTSspt62::SunOS::ISA = qw(Pkg::VRTSspt62::Common);

1;
