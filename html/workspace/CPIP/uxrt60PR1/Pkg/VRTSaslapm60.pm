use strict;

package Pkg::VRTSaslapm60::Common;
@Pkg::VRTSaslapm60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSaslapm';
    $pkg->{name}=Msg::new("Veritas Volume Manager - ASL/APM")->{msg};
    return;
}

package Pkg::VRTSaslapm60::AIX;
@Pkg::VRTSaslapm60::AIX::ISA = qw(Pkg::VRTSaslapm60::Common);

package Pkg::VRTSaslapm60::HPUX;
@Pkg::VRTSaslapm60::HPUX::ISA = qw(Pkg::VRTSaslapm60::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSaslapm60::Linux;
@Pkg::VRTSaslapm60::Linux::ISA = qw(Pkg::VRTSaslapm60::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSaslapm60::SunOS;
@Pkg::VRTSaslapm60::SunOS::ISA = qw(Pkg::VRTSaslapm60::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{ospkgs}{all}=[ 'SUNWcsu' ];
    return;
}

1;
