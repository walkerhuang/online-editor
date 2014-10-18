use strict;

package Prod::AGPACK61::Common;
@Prod::AGPACK61::Common::ISA = qw(Prod);

sub init_common {
    my ($prod) = @_;
    my ($padv);
    $prod->{prod}='agpack';
    $prod->{abbr}='Agent Pack';
    $prod->{vers}='6.1.1.100';
    $prod->{proddir}='agpack';
    #$prod->{eula}='EULA_VCS_Ux_6.0.pdf';
    $prod->{name}=Msg::new("Symantec High Availability Wizards Agent Pack")->{msg};
    $prod->{mainpkg}='VRTSvcswiz61';
    $prod->{bindir}='/opt/VRTSvcs/bin';
    #$prod->{uuidconfig}="$prod->{bindir}/uuidconfig.pl";
    #$prod->{uuidfile}='/etc/vx/.uuids/clusuuid';
    #$prod->{lic_name} = 'VERITAS Cluster Server';
    #$prod->{lic_keyless_name} = 'VCS';
    $prod->{responsefileupgradeok} = 1;
    #$prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}=[ qw(VRTSvcsea60 VRTSvcsvmw60 VRTSmq651 VRTSvcswas51 VRTSwls51 VRTSacclib52 VRTSsapnw0450 VRTSmysql ) ];
    $padv = $prod->padv();
    my @pkgs = ( qw(VRTSsapwebas7151 VRTSmq651 VRTSvcswiz61) );	
    if ( $0 !~ m/uninstallagpack/ ) {
	# Install acclib package but skip it from uninstall as it might be required for other agents
	unshift(@pkgs,"VRTSacclib52");
	# set upgrade option if current run is not 'uninstallagpack'
	Cfg::set_opt("upgrade");
    }
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}= \@pkgs ;
    return;
}
sub upgradeable{
	my ($prod,$ivers) = @_;
	if($ivers =~ /6.1/){
		return 1;
	}
	return 0;
}

sub verify_responsefile{
    my ($prod) = @_;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($pkgvers,$rel,$mpvers,$pkg);
    return '' unless ($prod->{mainpkg});
    $pkg=$sys->pkg($prod->{mainpkg});
    $pkgvers=$pkg->version_sys($sys,$force_flag);
    #$mpvers=$prod->{vers} if ($pkgvers && $prod->check_installed_patches_sys($sys,$pkgvers));
    #$pkgvers= $prod->revert_base_version_sys($sys,$pkg,$pkgvers,$mpvers,$force_flag);
    return ($mpvers || $pkgvers);
}


package Prod::AGPACK61::Linux;
@Prod::AGPACK61::Linux::ISA = qw(Prod::AGPACK61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(VRTSwls9)];

	my $localsys = Obj::localsys();
	my @pkgs = ( qw(VRTSsapwebas7151 VRTSmq651 VRTSvcswiz61) );	
	$localsys->cmd("/opt/VRTSsfmh/bin/testVMware");
	if (EDR::cmdexit() == 0){
		if ( $0 !~ m/uninstallagpack/ ) {
			# Install acclib package but skip it from uninstall as it might be required for other agents
			unshift(@pkgs,"VRTSacclib52");
		}
		$prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}= \@pkgs;
	}
	$prod->{installonupgradepkgs} = [ qw(VRTSmq6 VRTSsapwebas71) ];
#    $prod->{initfile}{vcs} = '/etc/sysconfig/vcs';
	return;
}

# yjain:: check the min version from which upgrade is possible

sub upgradeable{
    my ($prod,$ivers) = @_;
    if($ivers =~ /6.1/){
        return 1;
    }
    return 0;
}


package Prod::AGPACK61::RHEL5x8664;
@Prod::AGPACK61::RHEL5x8664::ISA = qw(Prod::AGPACK61::Linux);

package Prod::AGPACK61::SunOS;
@Prod::AGPACK61::SunOS::ISA = qw(Prod::AGPACK61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}=[ qw(VRTSvcsea60 VRTSvcswiz61 VRTSacclib52 ) ];
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    return;
}


package Prod::AGPACK61::SolSparc;
@Prod::AGPACK61::SolSparc::ISA = qw(Prod::AGPACK61::SunOS);

package Prod::AGPACK61::Solx64;
@Prod::AGPACK61::Solx64::ISA = qw(Prod::AGPACK61::SunOS);

package Prod::AGPACK61::AIX;
@Prod::AGPACK61::AIX::ISA = qw(Prod::AGPACK61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{minpkgs} = $prod->{recpkgs} =  $prod->{allpkgs}=[ qw(VRTSvcsea60 VRTSvcswiz61 VRTSacclib52 ) ];
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    return;
}

package Padv::SunOS;
@Padv::SunOS::ISA = qw(Padv);

sub media_pkg_version {
    my ($padv,$pkg)=@_;
    if ($pkg->{pstamp_vers}) {
        my $pstamp=$padv->media_pkginfovalue($pkg,'PSTAMP');
        $pstamp=~/(\d+\.\d+\.\d+\.\d+)/;
        return $1;
    }
    my $vers=$padv->media_pkginfovalue($pkg,'VERSION');
    return $padv->pkg_version_cleanup($vers);
}

sub pkg_version_sys {
    my ($padv,$sys,$pkg,$prevpkgs_flag,$pbe_flag)=@_;
    my ($i,$rootpath,$iv,$pkgi);
    # if $prevpkgs_flag=1, then do not check pkg's previous name.
    $rootpath=$pbe_flag ? '' : Cfg::opt('rootpath');
    for my $pkgi ($pkg->{pkg},@{$pkg->{previouspkgnames}}) {
        my $tmpiv = "";
        if ($pkg->{pstamp_vers}) {
            $tmpiv=$sys->cmd("_cmd_grep '^PSTAMP=' $rootpath/var/sadm/pkg/$pkgi/pkginfo 2>/dev/null");
            $tmpiv=~s/.*=//;
            $tmpiv=~/(\d+\.\d+\.\d+\.\d+)/;
            $tmpiv=$1;
        } else {
            $tmpiv=$sys->cmd("_cmd_grep '^VERSION=' $rootpath/var/sadm/pkg/$pkgi/pkginfo 2>/dev/null");
        }
        #$iv||= $sys->cmd("_cmd_grep '^VERSION=' $rootpath/var/sadm/pkg/$pkgi/pkginfo 2>/dev/null");
        $iv||=$tmpiv;
        last if ($iv || $prevpkgs_flag);
    }
    $iv=~s/VERSION=//m;
    # Check for multiple instances - TBD for PSTAMP
    if ($pkg->{otherinst}) {
        $i=2;
        while ($sys->exists("$rootpath/var/sadm/pkg/$pkg->{pkg}.$i/pkginfo")) {
            $i++;
        }
        if ($i>2) {
            $i--;
            $iv=$sys->cmd("_cmd_grep '^VERSION=' $rootpath/var/sadm/pkg/$pkg->{pkg}.$i/pkginfo 2>/dev/null");
            $iv=~s/VERSION=//m;
            $sys->{installno}{$pkg} = $i;
        }
    }
    return $padv->pkg_version_cleanup($iv);
}

package Padv::AIX;
@Padv::AIX::ISA = qw(Padv);

sub pkg_uninstall_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($uof,$pkgname);
    $sys->cmd('_cmd_installp -C');
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    $pkgname = ($pkg->{pkgname}) ? $pkg->{pkgname} : $pkg->{pkg};
    if ($pkg->{force_uninstall}) {
        $sys->cmd("cd /lpp/$pkgname/deinstl/; _cmd_rmr *unpre_i");
    }
    $sys->cmd("_cmd_installp -u $pkgname 2>$uof 1>&2");
    return '';
}


1;

