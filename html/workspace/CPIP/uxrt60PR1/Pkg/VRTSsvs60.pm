use strict;

package Pkg::VRTSsvs60::Common;
@Pkg::VRTSsvs60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsvs';
    $pkg->{installpkgslast}=1;
    $pkg->{name}=Msg::new("Symantec VirtualStore")->{msg};
    return;
}

package Pkg::VRTSsvs60::AIX;
@Pkg::VRTSsvs60::AIX::ISA = qw(Pkg::VRTSsvs60::Common);

package Pkg::VRTSsvs60::HPUX;
@Pkg::VRTSsvs60::HPUX::ISA = qw(Pkg::VRTSsvs60::Common);

package Pkg::VRTSsvs60::Linux;
@Pkg::VRTSsvs60::Linux::ISA = qw(Pkg::VRTSsvs60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{nodeps}=1;
    return;
}

package Pkg::VRTSsvs60::SunOS;
@Pkg::VRTSsvs60::SunOS::ISA = qw(Pkg::VRTSsvs60::Common);

1;
