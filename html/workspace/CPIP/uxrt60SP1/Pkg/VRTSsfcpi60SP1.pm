use strict;

package Pkg::VRTSsfcpi60SP1::Common;
@Pkg::VRTSsfcpi60SP1::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsfcpi60SP1';
    $pkg->{name}=Msg::new("Veritas Storage Foundation Installer")->{msg};
    $pkg->{installpkgslast}=1;
    return;
}

# to determine whether existing CPI pkgs need to be uninstalled.
# VRTSsfcpi60 pkg should be uninstalled unless partially upgrade from SFHA 6.0
sub donotinstall_sys {
    my ($pkg,$sys) = @_;
    my ($cpic, $cprod, $keepoldcpipkg,$oldcpipkg, @uninstallpkgs);
    $cpic=Obj::cpic();
    $cprod=CPIC::get('prod');
    if ($sys->{pkgvers}{VRTSsfcpi60} && ! Cfg::opt(qw/addnode postcheck/)) {
        $keepoldcpipkg = 0;
        # As long as the base version is 6.0, and it is partial upgrade, VRTSsfcpi60 won't be removed during upgrade.
        if ( $sys->{pkgvers}{VRTSvxvm} =~ /^0*6\.0/mx || $sys->{pkgvers}{VRTSvxfs} =~ /^0*6\.0/mx) {
            if ( $cprod =~ /VCS\d+/mx ) {
                $keepoldcpipkg = 1;
            }
        }

        if ($sys->{pkgvers}{VRTSvcs} =~ /^0*6\.0/mx ) {
            if ( $cprod =~ /SF\d+/mx || $cprod =~ /VM\d+/mx || $cprod =~ /FS\d+/mx || $cprod =~ /DMP\d+/mx ) {
                $keepoldcpipkg = 1;
            }
        }

        if (!$keepoldcpipkg) {
            $oldcpipkg=Pkg->new_pkg('VRTSsfcpi60', $cpic->{padv});
            $oldcpipkg=Pkg->new_pkg('VRTSsfcpi60', $sys->{padv});
            $oldcpipkg->set_uninstall_sys($sys);
            if (grep(/^VRTSperl/, @{$cpic->{uninstallpkgs}})) {
                @uninstallpkgs = ();
                for my $p (@{$cpic->{uninstallpkgs}}) {
                    if ( $p =~ /^VRTSperl/ ) {
                        push @uninstallpkgs, 'VRTSsfcpi60', $p;
                    } else {
                        push @uninstallpkgs, $p;
                    }
                }
                $cpic->{uninstallpkgs} = \@uninstallpkgs;
            } else {
                push @{$cpic->{uninstallpkgs}}, 'VRTSsfcpi60';
            }
            $cpic->{uninstallpkgs} = EDRu::arruniq(@{$cpic->{uninstallpkgs}});
        }
    }
    return 0;
}

sub donotuninstall_sys {
    my ($pkg,$sys) = @_;
    my (%pkgvers,$pkgi,$pkgver,$donotuninstall);
    $donotuninstall = 0;
    %pkgvers = %{$sys->{pkgvers}};
    for my $pkgi (qw /VRTSvxvm VRTSvxfs VRTSvcs/) {
        $pkgver = $pkgvers{$pkgi};
        if ( ! $pkgver) {
            next;
        }
        # Do not block uninstallation of VRTSsfcpi if VRTSvcs is installed as part of AppHA.
        if ( $pkgi eq 'VRTSvcs' && $pkgvers{'VRTSvcsvmw'} ) {
            next;
        }
        if ( $pkgver =~ /^6\.0/m && ! EDRu::inarr($pkgi.'60', @{$sys->{uninstallpkgs}})) {
            Msg::log("$pkg->{pkg} will not be uninstalled on $sys->{sys} because $pkgi $pkgver is still installed on that system.");
            $donotuninstall = 1;
            last;
        }
    }
    return $donotuninstall;
}

sub postinstall_sys {
    my ($pkg,$sys)=@_;
    my $rootpath = Cfg::opt('rootpath');
    my $scriptfile="$rootpath/opt/VRTS/install/bin/UXRT60SP1/add_install_scripts";
    my $prod=CPIC::get('prod');
    if(Cfg::opt("upgrade_kernelpkgs")){
        if($sys->exists($scriptfile,$sys)){
            Msg::log("Creating install scripts");
            $sys->cmd("CALLED_BY=CPI $scriptfile force $prod 2>/dev/null");
        }
    }
    return;
}

package Pkg::VRTSsfcpi60SP1::AIX;
@Pkg::VRTSsfcpi60SP1::AIX::ISA = qw(Pkg::VRTSsfcpi60SP1::Common);

package Pkg::VRTSsfcpi60SP1::HPUX;
@Pkg::VRTSsfcpi60SP1::HPUX::ISA = qw(Pkg::VRTSsfcpi60SP1::Common);

package Pkg::VRTSsfcpi60SP1::Linux;
@Pkg::VRTSsfcpi60SP1::Linux::ISA = qw(Pkg::VRTSsfcpi60SP1::Common);

package Pkg::VRTSsfcpi60SP1::SunOS;
@Pkg::VRTSsfcpi60SP1::SunOS::ISA = qw(Pkg::VRTSsfcpi60SP1::Common);

1;
