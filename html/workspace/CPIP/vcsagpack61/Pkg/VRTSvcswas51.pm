use strict;

package Pkg::VRTSvcswas51::Common;
@Pkg::VRTSvcswas51::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcswas';
    $pkg->{name}=Msg::new("VERITAS High Availability Agent 5.1 for WebSphere Application Server by Symantec")->{msg};
    return;
}
package Pkg::VRTSvcswas51::AIX;
@Pkg::VRTSvcswas51::AIX::ISA = qw(Pkg::VRTSvcswas51::Common);

package Pkg::VRTSvcswas51::HPUX;
@Pkg::VRTSvcswas51::HPUX::ISA = qw(Pkg::VRTSvcswas51::Common);

package Pkg::VRTSvcswas51::Linux;
@Pkg::VRTSvcswas51::Linux::ISA = qw(Pkg::VRTSvcswas51::Common);

package Pkg::VRTSvcswas51::SunOS;
@Pkg::VRTSvcswas51::SunOS::ISA = qw(Pkg::VRTSvcswas51::Common);

1;
