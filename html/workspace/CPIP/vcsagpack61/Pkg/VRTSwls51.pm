use strict;

package Pkg::VRTSwls51::Common;
@Pkg::VRTSwls51::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSwls';
    $pkg->{name}=Msg::new("Veritas High Availability Agent 5.1 for WebLogic Server by Symantec")->{msg};
    return;
}
package Pkg::VRTSwls51::AIX;
@Pkg::VRTSwls51::AIX::ISA = qw(Pkg::VRTSwls51::Common);

package Pkg::VRTSwls51::HPUX;
@Pkg::VRTSwls51::HPUX::ISA = qw(Pkg::VRTSwls51::Common);

package Pkg::VRTSwls51::Linux;
@Pkg::VRTSwls51::Linux::ISA = qw(Pkg::VRTSwls51::Common);

package Pkg::VRTSwls51::SunOS;
@Pkg::VRTSwls51::SunOS::ISA = qw(Pkg::VRTSwls51::Common);

1;
