use strict;

package Pkg::VRTSperl512::Common;
@Pkg::VRTSperl512::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSperl';
    $pkg->{name}=Msg::new("Veritas Perl 5.12.2 Redistribution")->{msg};
    $pkg->{gavers}='5.12.2.4';
    return;
}

#Add dependency for other products only when uninstall VRTSperl
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my (@softdeps);
    if (Cfg::opt('uninstall')) {
        push (@softdeps,'VRTScmcm') if ($sys->pkgvers('VRTScmcm'));
        push (@softdeps,'VRTSccsta.ccsta') if ($sys->pkgvers('VRTSccsta.ccsta'));
        push (@softdeps,'VRTSccsta') if ($sys->pkgvers('VRTSccsta'));
        push (@softdeps,'VRTShalR') if ($sys->pkgvers('VRTShalR'));
        push (@softdeps,'VRTSccsts') if ($sys->pkgvers('VRTSccsts'));
        push (@softdeps,'VRTSccer') if ($sys->pkgvers('VRTSccer'));
        my $vxvm = $sys->pkg('VRTSvxvm60');
        my $vxfs = $sys->pkg('VRTSvxfs60');
        my $vcs = $sys->pkg('VRTSvcs60');
        push (@softdeps, $vxvm->{pkg}) if ($vxvm->version_sys($sys));
        push (@softdeps, $vxfs->{pkg}) if ($vxfs->version_sys($sys));
        push (@softdeps, $vcs->{pkg}) if ($vcs->version_sys($sys));
        return \@softdeps;
    }
    return [];
}

package Pkg::VRTSperl512::AIX;
@Pkg::VRTSperl512::AIX::ISA = qw(Pkg::VRTSperl512::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{previouspkgnames}=[ qw(VRTSperl.rte) ];
    return;
}

package Pkg::VRTSperl512::HPUX;
@Pkg::VRTSperl512::HPUX::ISA = qw(Pkg::VRTSperl512::Common);

package Pkg::VRTSperl512::Linux;
@Pkg::VRTSperl512::Linux::ISA = qw(Pkg::VRTSperl512::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{gavers}='5.12.2.6';
    return;
}
package Pkg::VRTSperl512::SunOS;
@Pkg::VRTSperl512::SunOS::ISA = qw(Pkg::VRTSperl512::Common);

1;
