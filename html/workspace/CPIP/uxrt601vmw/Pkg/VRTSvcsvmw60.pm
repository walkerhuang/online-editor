use strict;

package Pkg::VRTSvcsvmw60::Common;
@Pkg::VRTSvcsvmw60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}="VRTSvcsvmw";
    $pkg->{name}=Msg::new("ApplicationHA Virtual Machine Wizards for application monitoring configurations, by Symantec.")->{msg};
    $pkg->{mpok} = 1;
}

package Pkg::VRTSvcsvmw60::AIX;
@Pkg::VRTSvcsvmw60::AIX::ISA = qw(Pkg::VRTSvcsvmw60::Common);

package Pkg::VRTSvcsvmw60::HPUX;
@Pkg::VRTSvcsvmw60::HPUX::ISA = qw(Pkg::VRTSvcsvmw60::Common);

package Pkg::VRTSvcsvmw60::Linux;
@Pkg::VRTSvcsvmw60::Linux::ISA = qw(Pkg::VRTSvcsvmw60::Common);

package Pkg::VRTSvcsvmw60::SunOS;
@Pkg::VRTSvcsvmw60::SunOS::ISA = qw(Pkg::VRTSvcsvmw60::Common);

1;
