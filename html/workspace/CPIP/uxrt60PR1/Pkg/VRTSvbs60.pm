use strict;

package Pkg::VRTSvbs60::Common;
@Pkg::VRTSvbs60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvbs';
    $pkg->{installpkgslast}=1;
    $pkg->{name}=Msg::new("Veritas Virtual Business Service")->{msg};
    return;
}

package Pkg::VRTSvbs60::AIX;
@Pkg::VRTSvbs60::AIX::ISA = qw(Pkg::VRTSvbs60::Common);

package Pkg::VRTSvbs60::HPUX;
@Pkg::VRTSvbs60::HPUX::ISA = qw(Pkg::VRTSvbs60::Common);

package Pkg::VRTSvbs60::Linux;
@Pkg::VRTSvbs60::Linux::ISA = qw(Pkg::VRTSvbs60::Common);

package Pkg::VRTSvbs60::SunOS;
@Pkg::VRTSvbs60::SunOS::ISA = qw(Pkg::VRTSvbs60::Common);

1;
