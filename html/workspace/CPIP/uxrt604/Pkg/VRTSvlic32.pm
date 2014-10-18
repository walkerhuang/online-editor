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

package Pkg::VRTSvlic32::Common;
@Pkg::VRTSvlic32::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvlic';
    $pkg->{name}=Msg::new("Veritas Licensing")->{msg};
    $pkg->{gavers}='3.2.60.7';
    return;
}

#Add dependency for other products only when uninstall VRTSvlic
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps,$rel);
    $rel=Obj::rel();
    if (Cfg::opt('uninstall')) {
        my $vxvm = $sys->pkg('VRTSvxvm60') if (EDRu::inarr($rel->{prods},"VM60"));
        my $vxfs = $sys->pkg('VRTSvxfs60') if (EDRu::inarr($rel->{prods},"FS60"));
        my $vcs = $sys->pkg('VRTSvcs60') if (EDRu::inarr($rel->{prods},"VCS60"));
        push (@softdeps, $vxvm->{pkg}) if ($vxvm && $vxvm->version_sys($sys));
        push (@softdeps, $vxfs->{pkg}) if ($vxfs && $vxfs->version_sys($sys));
        push (@softdeps, $vcs->{pkg}) if ($vcs && $vcs->version_sys($sys));
        return \@softdeps;
    }
    return [];
}

package Pkg::VRTSvlic32::AIX;
@Pkg::VRTSvlic32::AIX::ISA = qw(Pkg::VRTSvlic32::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSvlic32::HPUX;
@Pkg::VRTSvlic32::HPUX::ISA = qw(Pkg::VRTSvlic32::Common);

package Pkg::VRTSvlic32::Linux;
@Pkg::VRTSvlic32::Linux::ISA = qw(Pkg::VRTSvlic32::Common);

package Pkg::VRTSvlic32::SunOS;
@Pkg::VRTSvlic32::SunOS::ISA = qw(Pkg::VRTSvlic32::Common);

1;
