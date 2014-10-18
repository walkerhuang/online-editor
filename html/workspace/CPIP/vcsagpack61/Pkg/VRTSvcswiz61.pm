use strict;

package Pkg::VRTSvcswiz61::Common;
@Pkg::VRTSvcswiz61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}="VRTSvcswiz";
    $pkg->{pstamp_vers}=1;
    $pkg->{force_uninstall} = 1;
#    $pkg->{name}=Msg::new("High Availability virtual machine wizards for application monitoring configurations, by Symantec" )->{msg};
    $pkg->{name}=Msg::new("High Availability Wizards for Symantec Cluster Server, by Symantec")->{msg};
#    $pkg->{startprocs}=[ qw(VMwareDisksAgent) ];
#    $pkg->{stopprocs}=[ qw(VMwareDisksAgent) ];
    return;
}

package Pkg::VRTSvcswiz61::AIX;
@Pkg::VRTSvcswiz61::AIX::ISA = qw(Pkg::VRTSvcswiz61::Common);

package Pkg::VRTSvcswiz61::HPUX;
@Pkg::VRTSvcswiz61::HPUX::ISA = qw(Pkg::VRTSvcswiz61::Common);

package Pkg::VRTSvcswiz61::Linux;
@Pkg::VRTSvcswiz61::Linux::ISA = qw(Pkg::VRTSvcswiz61::Common);

package Pkg::VRTSvcswiz61::SunOS;
@Pkg::VRTSvcswiz61::SunOS::ISA = qw(Pkg::VRTSvcswiz61::Common);

1;
