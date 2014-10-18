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

package Pkg::VRTSsfmh41::Common;
@Pkg::VRTSsfmh41::Common::ISA = qw(Pkg);

use JSON;

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsfmh';
    $pkg->{name}=Msg::new("Veritas Storage Foundation Managed Host by Symantec")->{msg};
    # sfmh-discovery.pl needs to be stopped
    # since it restarts vxnotify
    $pkg->{stopprocs}=[ qw(sfmhdiscovery60 vxdclid60) ];
    $pkg->{startprocs}=[ qw(sfmhdiscovery60) ];
    $pkg->{installpkgslast}=1;
    $pkg->{donotrmonupgrade}=1;

    # TODO: need update with last build.
    $pkg->{gavers}='4.1.103.0';

    return;
}

sub check_if_managedhost_connected_to_central_server_sys {
    my ($pkg,$sys)=@_;
    my ($rtn,$jsonobj,@mgmt_servers,$mgmt_server);

    @mgmt_servers=();
    $rtn=$sys->cmd("/opt/VRTSsfmh/bin/xprtlc -l https://localhost:5634/world/getvitals 2>/dev/null");
    if (!EDR::cmdexit()) {
        # xprtld is running on the system
        $jsonobj=JSON::from_json($rtn);
        if (defined $jsonobj->{DOMAINS}) {
            for my $mgmt_server (keys %{$jsonobj->{DOMAINS}}) {
                $mgmt_server=~s/:\d+.*$//;
                push (@mgmt_servers, $mgmt_server);
            }
        }
    } else {
        # xprtld is not running on the system, checking '/etc/default/sfm_resolv.conf'
	$rtn=$sys->catfile("/etc/default/sfm_resolv.conf");
        for my $line (split(/\n/, $rtn)) {
            if ($line=~m{ \[(.*)\] }mxs) {
                $mgmt_server=$1;
                $mgmt_server=~s/:\d+.*$//;
                push (@mgmt_servers, $mgmt_server) if ($mgmt_server ne 'domains');
            }
        }
    }
    return join (' ', @mgmt_servers);
}

#Add dependency for other products only when uninstall VRTSperl
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my ($vxvm,$vxfs,$vcs,@softdeps);
    if (Cfg::opt('uninstall')) {
        $vxvm = $sys->pkg('VRTSvxvm60');
        $vxfs = $sys->pkg('VRTSvxfs60');
        $vcs = $sys->pkg('VRTSvcs60');
        push (@softdeps, $vxvm->{pkg}) if ($vxvm->version_sys($sys));
        push (@softdeps, $vxfs->{pkg}) if ($vxfs->version_sys($sys));
        push (@softdeps, $vcs->{pkg}) if ($vcs->version_sys($sys));
        return \@softdeps;
    }
    return [];
}

package Pkg::VRTSsfmh41::AIX;
@Pkg::VRTSsfmh41::AIX::ISA = qw(Pkg::VRTSsfmh41::Common);

package Pkg::VRTSsfmh41::HPUX;
@Pkg::VRTSsfmh41::HPUX::ISA = qw(Pkg::VRTSsfmh41::Common);

package Pkg::VRTSsfmh41::Linux;
@Pkg::VRTSsfmh41::Linux::ISA = qw(Pkg::VRTSsfmh41::Common);

package Pkg::VRTSsfmh41::SunOS;
@Pkg::VRTSsfmh41::SunOS::ISA = qw(Pkg::VRTSsfmh41::Common);

1;
