use strict;

package Pkg::VRTSatClient50::Common;
@Pkg::VRTSatClient50::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSatClient';
    $pkg->{gavers}='5.0.32.0';
    $pkg->{osuuid}='/etc/vx/uuid/bin/osuuid';
    $pkg->{name}=Msg::new("Symantec Product Authentication Service Client")->{msg};
    $pkg->{softdeps}=[ qw(VRTScmcm VRTSvcs) ];
    return;
}

package Pkg::VRTSatClient50::AIX;
@Pkg::VRTSatClient50::AIX::ISA = qw(Pkg::VRTSatClient50::Common);

package Pkg::VRTSatClient50::HPUX;
@Pkg::VRTSatClient50::HPUX::ISA = qw(Pkg::VRTSatClient50::Common);

package Pkg::VRTSatClient50::Linux;
@Pkg::VRTSatClient50::Linux::ISA = qw(Pkg::VRTSatClient50::Common);

package Pkg::VRTSatClient50::SunOS;
@Pkg::VRTSatClient50::SunOS::ISA = qw(Pkg::VRTSatClient50::Common);

1;
