use strict;

package Pkg::VRTScutil60::Common;
@Pkg::VRTScutil60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTScutil';
    $pkg->{name}=Msg::new("Veritas Cluster Utility by Symantec")->{msg};
    return;
}

package Pkg::VRTScutil60::AIX;
@Pkg::VRTScutil60::AIX::ISA = qw(Pkg::VRTScutil60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTScutil.rte) ];
    return;
}

package Pkg::VRTScutil60::HPUX;
@Pkg::VRTScutil60::HPUX::ISA = qw(Pkg::VRTScutil60::Common);

package Pkg::VRTScutil60::Linux;
@Pkg::VRTScutil60::Linux::ISA = qw(Pkg::VRTScutil60::Common);

package Pkg::VRTScutil60::SunOS;
@Pkg::VRTScutil60::SunOS::ISA = qw(Pkg::VRTScutil60::Common);

1;
