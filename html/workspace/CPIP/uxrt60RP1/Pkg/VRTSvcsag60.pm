use strict;

package Pkg::VRTSvcsag60::Common;
@Pkg::VRTSvcsag60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcsag';
    $pkg->{name}=Msg::new("Veritas Cluster Server Bundled Agents by Symantec")->{msg};
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcsag60::AIX;
@Pkg::VRTSvcsag60::AIX::ISA = qw(Pkg::VRTSvcsag60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSvcsag.rte) ];
    return;
}

package Pkg::VRTSvcsag60::HPUX;
@Pkg::VRTSvcsag60::HPUX::ISA = qw(Pkg::VRTSvcsag60::Common);

package Pkg::VRTSvcsag60::Linux;
@Pkg::VRTSvcsag60::Linux::ISA = qw(Pkg::VRTSvcsag60::Common);

package Pkg::VRTSvcsag60::SunOS;
@Pkg::VRTSvcsag60::SunOS::ISA = qw(Pkg::VRTSvcsag60::Common);

1;
