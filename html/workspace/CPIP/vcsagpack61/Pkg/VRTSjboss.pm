use strict;

package Pkg::VRTSjboss::Common;
@Pkg::VRTSjboss::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjboss';
    $pkg->{name}=Msg::new("Veritas High Availability Agent for JBoss by Symantec")->{msg};
    return;
}
package Pkg::VRTSjboss::AIX;
@Pkg::VRTSjboss::AIX::ISA = qw(Pkg::VRTSjboss::Common);

package Pkg::VRTSjboss::HPUX;
@Pkg::VRTSjboss::HPUX::ISA = qw(Pkg::VRTSjboss::Common);

package Pkg::VRTSjboss::Linux;
@Pkg::VRTSjboss::Linux::ISA = qw(Pkg::VRTSjboss::Common);

package Pkg::VRTSjboss::SunOS;
@Pkg::VRTSjboss::SunOS::ISA = qw(Pkg::VRTSjboss::Common);

1;
