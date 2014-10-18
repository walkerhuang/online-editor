use strict;

package Pkg::VRTSsapwebas7160::Common;
@Pkg::VRTSsapwebas7160::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsapwebas71';
    $pkg->{name}=Msg::new("Veritas High Availability Agent for SAP WebAS by Symantec")->{msg};
    $pkg->{gavers}='5.0';
    $pkg->{mpok}=1;
    return;
}

package Pkg::VRTSsapwebas7160::Linux;
@Pkg::VRTSsapwebas7160::Linux::ISA = qw(Pkg::VRTSsapwebas7160::Common);

1;
