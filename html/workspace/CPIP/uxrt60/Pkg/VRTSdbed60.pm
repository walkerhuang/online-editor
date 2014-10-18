use strict;

package Pkg::VRTSdbed60::Common;
@Pkg::VRTSdbed60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbed';
    $pkg->{name}=Msg::new("Veritas Storage Foundation Databases")->{msg};
    $pkg->{startprocs}=[ qw(vxdbd60) ];
    $pkg->{stopprocs}=[ qw(vxdbd60) ];
    return;
}

package Pkg::VRTSdbed60::AIX;
@Pkg::VRTSdbed60::AIX::ISA = qw(Pkg::VRTSdbed60::Common);

package Pkg::VRTSdbed60::HPUX;
@Pkg::VRTSdbed60::HPUX::ISA = qw(Pkg::VRTSdbed60::Common);

package Pkg::VRTSdbed60::Linux;
@Pkg::VRTSdbed60::Linux::ISA = qw(Pkg::VRTSdbed60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbed';
    $pkg->{previouspkgnames} = [ qw(VRTSdbed-common) ];
    return;
}

package Pkg::VRTSdbed60::SLES11x8664;
@Pkg::VRTSdbed60::SLES11x8664::ISA = qw(Pkg::VRTSdbed60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{installonpatchupgrade}=1;
    return;
}

package Pkg::VRTSdbed60::SunOS;
@Pkg::VRTSdbed60::SunOS::ISA = qw(Pkg::VRTSdbed60::Common);

1;
