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

package Pkg::VRTSperl514::Common;
@Pkg::VRTSperl514::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSperl';
    $pkg->{name}=Msg::new("Veritas Perl 5.14.2 Redistribution")->{msg};
    $pkg->{gavers}='5.14.2.0';
    return;
}

#Add dependency for other products only when uninstall VRTSperl
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps,$rel);
    $rel=Obj::rel();
    if (Cfg::opt('uninstall')) {
        push (@softdeps,'VRTScmcm') if ($sys->pkgvers('VRTScmcm'));
        push (@softdeps,'VRTSccsta.ccsta') if ($sys->pkgvers('VRTSccsta.ccsta'));
        push (@softdeps,'VRTSccsta') if ($sys->pkgvers('VRTSccsta'));
        push (@softdeps,'VRTShalR') if ($sys->pkgvers('VRTShalR'));
        push (@softdeps,'VRTSccsts') if ($sys->pkgvers('VRTSccsts'));
        push (@softdeps,'VRTSccer') if ($sys->pkgvers('VRTSccer'));
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

package Pkg::VRTSperl514::AIX;
@Pkg::VRTSperl514::AIX::ISA = qw(Pkg::VRTSperl514::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{previouspkgnames}=[ qw(VRTSperl.rte) ];
    return;
}

package Pkg::VRTSperl514::HPUX;
@Pkg::VRTSperl514::HPUX::ISA = qw(Pkg::VRTSperl514::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSperl514::Linux;
@Pkg::VRTSperl514::Linux::ISA = qw(Pkg::VRTSperl514::Common);

package Pkg::VRTSperl514::SunOS;
@Pkg::VRTSperl514::SunOS::ISA = qw(Pkg::VRTSperl514::Common);

package Pkg::VRTSperl514::Sol11sparc;
@Pkg::VRTSperl514::Sol11sparc::ISA = qw(Pkg::VRTSperl514::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSperl514::Sol11x64;
@Pkg::VRTSperl514::Sol11x64::ISA = qw(Pkg::VRTSperl514::Sol11sparc);

1;
