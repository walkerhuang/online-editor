use strict;

package Pkg::VRTSvlic32::Common;
@Pkg::VRTSvlic32::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvlic';
    $pkg->{name}=Msg::new("Veritas Licensing")->{msg};
    $pkg->{gavers}='3.2.60.7';
    return;
}

#Add dependency for other products only when uninstall VRTSvlic
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps);
    if (Cfg::opt('uninstall')) {
        push (@softdeps,'VRTSvxvm') if ($sys->pkgvers('VRTSvxvm'));
        push (@softdeps,'VRTSvxsf') if ($sys->pkgvers('VRTSvxsf'));
        push (@softdeps,'VRTSvcs') if ($sys->pkgvers('VRTSvcs'));
        return \@softdeps;
    }
    return [];
}

package Pkg::VRTSvlic32::AIX;
@Pkg::VRTSvlic32::AIX::ISA = qw(Pkg::VRTSvlic32::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSvlic32::HPUX;
@Pkg::VRTSvlic32::HPUX::ISA = qw(Pkg::VRTSvlic32::Common);

package Pkg::VRTSvlic32::Linux;
@Pkg::VRTSvlic32::Linux::ISA = qw(Pkg::VRTSvlic32::Common);

package Pkg::VRTSvlic32::SunOS;
@Pkg::VRTSvlic32::SunOS::ISA = qw(Pkg::VRTSvlic32::Common);

1;
