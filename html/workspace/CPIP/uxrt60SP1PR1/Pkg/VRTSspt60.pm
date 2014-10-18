use strict;

package Pkg::VRTSspt60::Common;
@Pkg::VRTSspt60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSspt';
    $pkg->{name}=Msg::new("Veritas Software Support Tools by Symantec")->{msg};
    $pkg->{softdeps}=[ qw(VRTSvcsvmw) ];
    return;
}

sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps, $vxvm, $vxfs, $vcs,$dep);
    if ($pkg->{softdeps}) {
        for my $dep (@{$pkg->{softdeps}}) {
            push (@softdeps, $dep) if ($sys->pkgvers($dep));
        }
    }
    if (Cfg::opt('uninstall')) {
        push (@softdeps,'VRTSvxvm') if ($sys->pkgvers('VRTSvxvm'));
        push (@softdeps,'VRTSvxsf') if ($sys->pkgvers('VRTSvxsf'));
        push (@softdeps,'VRTSvcs') if ($sys->pkgvers('VRTSvcs'));
    }
    return \@softdeps;
}

package Pkg::VRTSspt60::AIX;
@Pkg::VRTSspt60::AIX::ISA = qw(Pkg::VRTSspt60::Common);

package Pkg::VRTSspt60::HPUX;
@Pkg::VRTSspt60::HPUX::ISA = qw(Pkg::VRTSspt60::Common);

package Pkg::VRTSspt60::Linux;
@Pkg::VRTSspt60::Linux::ISA = qw(Pkg::VRTSspt60::Common);

package Pkg::VRTSspt60::SunOS;
@Pkg::VRTSspt60::SunOS::ISA = qw(Pkg::VRTSspt60::Common);

1;
