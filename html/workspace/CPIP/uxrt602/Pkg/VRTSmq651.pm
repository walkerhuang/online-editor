use strict;

package Pkg::VRTSmq651::Common;
@Pkg::VRTSmq651::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSmq6';
    $pkg->{name}=Msg::new("Veritas High Availability Agent 5.1 for WebSphereMQ and WebSphereMQFTE by Symantec")->{msg};
    $pkg->{mpok} = 1;
    return;
}
package Pkg::VRTSmq651::AIX;
@Pkg::VRTSmq651::AIX::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::HPUX;
@Pkg::VRTSmq651::HPUX::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::Linux;
@Pkg::VRTSmq651::Linux::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::SunOS;
@Pkg::VRTSmq651::SunOS::ISA = qw(Pkg::VRTSmq651::Common);

1;
