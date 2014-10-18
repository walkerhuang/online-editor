use strict;

package Pkg::VRTSperl514::Common;
@Pkg::VRTSperl514::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSperl';
    $pkg->{name}=Msg::new("Veritas Perl 5.14.2 Redistribution")->{msg};
    $pkg->{gavers}='5.14.2.0';
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

        push (@softdeps,'VRTSvxvm') if ($sys->pkgvers('VRTSvxvm'));
        push (@softdeps,'VRTSvxsf') if ($sys->pkgvers('VRTSvxsf'));
        push (@softdeps,'VRTSvcs') if ($sys->pkgvers('VRTSvcs'));
        return \@softdeps;
    }
    return [];
}

package Pkg::VRTSperl514::AIX;
@Pkg::VRTSperl514::AIX::ISA = qw(Pkg::VRTSperl514::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    $pkg->{previouspkgnames}=[ qw(VRTSperl.rte) ];
    return;
}

package Pkg::VRTSperl514::HPUX;
@Pkg::VRTSperl514::HPUX::ISA = qw(Pkg::VRTSperl514::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSperl514::Linux;
@Pkg::VRTSperl514::Linux::ISA = qw(Pkg::VRTSperl514::Common);

package Pkg::VRTSperl514::SunOS;
@Pkg::VRTSperl514::SunOS::ISA = qw(Pkg::VRTSperl514::Common);

package Pkg::VRTSperl514::Sol11sparc;
@Pkg::VRTSperl514::Sol11sparc::ISA = qw(Pkg::VRTSperl514::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSperl514::Sol11x64;
@Pkg::VRTSperl514::Sol11x64::ISA = qw(Pkg::VRTSperl514::Sol11sparc);

1;
