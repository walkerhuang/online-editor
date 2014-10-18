use strict;

package Pkg::VRTSmysql::Common;
@Pkg::VRTSmysql::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSmysql';
    $pkg->{name}=Msg::new("Veritas High Availability Agent for MySQL by Symantec")->{msg};
    return;
}
package Pkg::VRTSmysql::AIX;
@Pkg::VRTSmysql::AIX::ISA = qw(Pkg::VRTSmysql::Common);

package Pkg::VRTSmysql::HPUX;
@Pkg::VRTSmysql::HPUX::ISA = qw(Pkg::VRTSmysql::Common);

package Pkg::VRTSmysql::Linux;
@Pkg::VRTSmysql::Linux::ISA = qw(Pkg::VRTSmysql::Common);

package Pkg::VRTSmysql::SunOS;
@Pkg::VRTSmysql::SunOS::ISA = qw(Pkg::VRTSmysql::Common);

1;
