use strict;

package Pkg::VRTSlvmconv60::Common;
@Pkg::VRTSlvmconv60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSlvmconv';
    $pkg->{name}=Msg::new("Veritas Linux LVM to VxVM Converter")->{msg};
    return;
}

package Pkg::VRTSlvmconv60::Linux;
@Pkg::VRTSlvmconv60::Linux::ISA = qw(Pkg::VRTSlvmconv60::Common);

1;
