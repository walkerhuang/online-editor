use strict;

package Pkg::VRTSacclib52::Common;
@Pkg::VRTSacclib52::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSacclib';
    $pkg->{name}=Msg::new("Veritas Cluster Server ACC Library by Symantec")->{msg};
    $pkg->{gavers}='5.2';
    return;
}

package Pkg::VRTSacclib52::AIX;
@Pkg::VRTSacclib52::AIX::ISA = qw(Pkg::VRTSacclib52::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSacclib.rte) ];
    return;
}

package Pkg::VRTSacclib52::HPUX;
@Pkg::VRTSacclib52::HPUX::ISA = qw(Pkg::VRTSacclib52::Common);

package Pkg::VRTSacclib52::Linux;
@Pkg::VRTSacclib52::Linux::ISA = qw(Pkg::VRTSacclib52::Common);

package Pkg::VRTSacclib52::SunOS;
@Pkg::VRTSacclib52::SunOS::ISA = qw(Pkg::VRTSacclib52::Common);

1;
