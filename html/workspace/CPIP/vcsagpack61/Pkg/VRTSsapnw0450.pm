use strict;

package Pkg::VRTSsapnw0450::Common;
@Pkg::VRTSsapnw0450::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsapnw04';
    $pkg->{name}=Msg::new("Veritas High Availability Agent for SAP NetWeaver by Symantec")->{msg};
    return;
}
package Pkg::VRTSsapnw0450::AIX;
@Pkg::VRTSsapnw0450::AIX::ISA = qw(Pkg::VRTSsapnw0450::Common);

package Pkg::VRTSsapnw0450::HPUX;
@Pkg::VRTSsapnw0450::HPUX::ISA = qw(Pkg::VRTSsapnw0450::Common);

package Pkg::VRTSsapnw0450::Linux;
@Pkg::VRTSsapnw0450::Linux::ISA = qw(Pkg::VRTSsapnw0450::Common);

package Pkg::VRTSsapnw0450::SunOS;
@Pkg::VRTSsapnw0450::SunOS::ISA = qw(Pkg::VRTSsapnw0450::Common);

1;
