use strict;

package Pkg::VRTSvcsvmw60::Common;
@Pkg::VRTSvcsvmw60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}="VRTSvcsvmw";
    $pkg->{pstamp_vers}=1;
    $pkg->{force_uninstall} = 1;
    $pkg->{name}=Msg::new("High Availability virtual machine wizards for application monitoring configurations, by Symantec" )->{msg};
#    $pkg->{startprocs}=[ qw(VMwareDisksAgent) ];
#    $pkg->{stopprocs}=[ qw(VMwareDisksAgent) ];
    return;
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
