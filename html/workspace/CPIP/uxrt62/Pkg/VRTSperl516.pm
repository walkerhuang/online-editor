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

package Pkg::VRTSperl516::Common;
@Pkg::VRTSperl516::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSperl';
    $pkg->{name}=Msg::new("Perl Redistribution")->{msg};
    $pkg->{gavers}='5.16.1.26';
    return;
}

#Add dependency for other products only when uninstall VRTSperl
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps);
    if (Cfg::opt('uninstall')) {
        push (@softdeps,'VRTScmcm') if ($sys->pkgvers('VRTScmcm'));
        push (@softdeps,'VRTSccsta.ccsta') if ($sys->pkgvers('VRTSccsta.ccsta'));
        push (@softdeps,'VRTSccsta') if ($sys->pkgvers('VRTSccsta'));
        push (@softdeps,'VRTShalR') if ($sys->pkgvers('VRTShalR'));
        push (@softdeps,'VRTSccsts') if ($sys->pkgvers('VRTSccsts'));
        push (@softdeps,'VRTSccer') if ($sys->pkgvers('VRTSccer'));
        my $vxvm = $sys->pkg('VRTSvxvm62');
        my $vxfs = $sys->pkg('VRTSvxfs62');
        my $vcs = $sys->pkg('VRTSvcs62');
        push (@softdeps, $vxvm->{pkg}) if ($vxvm->version_sys($sys));
        push (@softdeps, $vxfs->{pkg}) if ($vxfs->version_sys($sys));
        push (@softdeps, $vcs->{pkg}) if ($vcs->version_sys($sys));
        return \@softdeps;
    }
    return [];
}

package Pkg::VRTSperl516::AIX;
@Pkg::VRTSperl516::AIX::ISA = qw(Pkg::VRTSperl516::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{previouspkgnames}=[ qw(VRTSperl.rte) ];
    return;
}

package Pkg::VRTSperl516::HPUX;
@Pkg::VRTSperl516::HPUX::ISA = qw(Pkg::VRTSperl516::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSperl516::Linux;
@Pkg::VRTSperl516::Linux::ISA = qw(Pkg::VRTSperl516::Common);

package Pkg::VRTSperl516::SunOS;
@Pkg::VRTSperl516::SunOS::ISA = qw(Pkg::VRTSperl516::Common);

package Pkg::VRTSperl516::Sol11sparc;
@Pkg::VRTSperl516::Sol11sparc::ISA = qw(Pkg::VRTSperl516::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSperl516::Sol11x64;
@Pkg::VRTSperl516::Sol11x64::ISA = qw(Pkg::VRTSperl516::Sol11sparc);

1;
