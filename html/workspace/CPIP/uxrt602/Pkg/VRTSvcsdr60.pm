use strict;

package Pkg::VRTSvcsdr60::Common;
@Pkg::VRTSvcsdr60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcsdr';
    $pkg->{name}=Msg::new("Veritas Cluster Server Disk Reservation Modules")->{msg};
    return;
}

package Pkg::VRTSvcsdr60::Linux;
@Pkg::VRTSvcsdr60::Linux::ISA = qw(Pkg::VRTSvcsdr60::Common);

1;
