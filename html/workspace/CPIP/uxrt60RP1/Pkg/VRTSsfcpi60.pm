use strict;

package Pkg::VRTSsfcpi60::Common;
@Pkg::VRTSsfcpi60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsfcpi60';
    $pkg->{name}=Msg::new("Veritas Storage Foundation Installer")->{msg};
    $pkg->{installpkgslast}=1;
    $pkg->{installpatcheslast}=1;
    return;
}

sub donotuninstall_sys {
    my ($pkg,$sys) = @_;
    my (%pkgvers,$pkgi,$pkgver,$donotuninstall);
    $donotuninstall = 0;
    if (Cfg::opt('rollback')) {
        return 0;
    }
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
    my $scriptfile="$rootpath/opt/VRTS/install/bin/UXRT60/add_install_scripts";
    my $prod=CPIC::get('prod');
    if(Cfg::opt("upgrade_kernelpkgs")){
        if($sys->exists($scriptfile,$sys)){
            Msg::log("Creating install scripts");
            $sys->cmd("CALLED_BY=CPI $scriptfile force $prod 2>/dev/null");
        }
    }
    return;
}

# override verify_media and version_sys here to use old name if package with new name cannot be found.
sub verify_media {
    my ($cpic,$padv,$pkg,$pkgpath,$pkgi,$rel,$edr,$msg);
    $pkg = shift;
    return if ($pkg->nopadvpkg);
    $cpic = Obj::cpic();
    $edr = Obj::edr();
    $rel = $pkg->rel;
    # initiate the padv release object to define file, vers, size, and space
    if ($cpic->{fromdisk} || $rel->{nopkgs}) {
        $pkg->{vers}=$pkg->{gavers};
        $pkg->{vers}||=$rel->{gavers};
        return '';
    } elsif ($rel->{padv} eq 'Common') {
        $pkg->{vers}=$pkg->version();
        return '';
    }
    return '' if ($pkg->{file});

    $pkgpath=Cfg::opt('pkgpath');
    $pkgpath||=$rel->pkgs_patches_dir('pkgpath');
    $padv=$pkg->padv;
    $pkg->{file}=$padv->media_pkg_file($pkg, $pkgpath);
    if (!$pkg->{file}) {
        $pkg->{origpkg} = $pkg->{pkg};
        $pkg->{pkg} = "VRTSsfcpi";
        $pkg->{file}=$padv->media_pkg_file($pkg, $pkgpath);
        $rel->{cpipkg} = $pkg->{pkg};
        push @{$rel->{installonupgradepkgs}}, $pkg->{pkg};
    }
    if ($pkg->{file}) {
        # common version definitions also defined at the $rel level now
        $pkg->{vers} = $padv->media_pkg_version($pkg,$pkgpath);
        EDR::die("Cannot determine version of $pkg->{padv} $pkg->{pkg}")
            if (!$pkg->{vers});
        $pkg->{size}=$cpic->pkg_patch_size($pkg->{file});
        $pkg->{space}=$pkg->space();
    } elsif (Cfg::opt('mpok')) {
        $pkg->{mpok}=1;
    } elsif (!$rel->{verify_media}) {
        Msg::log("Cannot find $pkg->{pkg} for padv $pkg->{padv} in $pkgpath");
    } elsif (Cfg::opt('pkgpath')) {
        $pkgi =Msg::get('pdfr')." ".$pkg->{pkg};
        $msg = Msg::new("Cannot find $pkgi in $pkgpath");
        $msg->die;
    } else {
        EDR::die("Cannot find $pkg->{pkg} for padv $pkg->{padv} in $pkgpath");
    }
    return;
}

sub version_sys {
    my ($pkg,$sys,$force_flag,$prevpkgs_flag,$pbe_flag) = @_;
    my ($vers,$rel);
    $rel = $pkg->rel;
    $vers=$sys->{pkgvers}{$pkg->{pkg}};

    if ((!EDRu::vrts_symc($pkg->{pkg})) || (!$sys->{packages}) || ($force_flag)) {
        $vers=$sys->padv->pkg_version_sys($sys, $pkg, $prevpkgs_flag,$pbe_flag);
        $sys->set_value("pkgvers,$pkg->{pkg}", $vers) unless ($pbe_flag);
        return $vers;
    }
    if ( !$vers ) {
        for my $pkgi (qw/VRTSsfcpi VRTSsfcpi60/) {
            $vers=$sys->{pkgvers}{$pkgi};
            if ( $vers) {
                $pkg->{pkg} = $pkgi;
                $rel->{cpipkg} = $pkg->{pkg};
                push @{$rel->{installonupgradepkgs}}, $pkg->{pkg};
                last;
            }
        }
    }
    return $vers;
}

package Pkg::VRTSsfcpi60::AIX;
@Pkg::VRTSsfcpi60::AIX::ISA = qw(Pkg::VRTSsfcpi60::Common);

package Pkg::VRTSsfcpi60::HPUX;
@Pkg::VRTSsfcpi60::HPUX::ISA = qw(Pkg::VRTSsfcpi60::Common);

package Pkg::VRTSsfcpi60::Linux;
@Pkg::VRTSsfcpi60::Linux::ISA = qw(Pkg::VRTSsfcpi60::Common);

package Pkg::VRTSsfcpi60::SunOS;
@Pkg::VRTSsfcpi60::SunOS::ISA = qw(Pkg::VRTSsfcpi60::Common);

1;
