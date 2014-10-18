use strict;

package Pkg::VRTSdbac60::Common;
@Pkg::VRTSdbac60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbac';
    $pkg->{name}=Msg::new("Veritas Oracle Real Application Cluster Support Package by Symantec")->{msg};
    $pkg->{stopprocs}=[ qw(vcsmm60 lmx60) ];
    $pkg->{startprocs}=[ qw(vcsmm60 lmx60) ];
    $pkg->{extra_types} = ['/etc/VRTSvcs/conf/PrivNIC.cf',
                    '/etc/VRTSvcs/conf/MultiPrivNIC.cf',
                    '/etc/VRTSvcs/conf/OracleServiceTypes.cf',
                    '/etc/VRTSvcs/conf/CRSResource.cf'
                    ];
    return;
}

package Pkg::VRTSdbac60::AIX;
@Pkg::VRTSdbac60::AIX::ISA = qw(Pkg::VRTSdbac60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSdbac.rte) ];
    return;
}

package Pkg::VRTSdbac60::HPUX;
@Pkg::VRTSdbac60::HPUX::ISA = qw(Pkg::VRTSdbac60::Common);

package Pkg::VRTSdbac60::Linux;
@Pkg::VRTSdbac60::Linux::ISA = qw(Pkg::VRTSdbac60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{startprocs}=EDRu::arrdel($pkg->{startprocs}, 'lmx60');
    $pkg->{stopprocs}=EDRu::arrdel($pkg->{stopprocs}, 'lmx60');
    return;
}

package Pkg::VRTSdbac60::SunOS;
@Pkg::VRTSdbac60::SunOS::ISA = qw(Pkg::VRTSdbac60::Common);

1;
