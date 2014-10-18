#
# $Copyright: Copyright (c) 2014 Symantec Corporation.
# All rights reserved.
#
# THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
# SYMANTEC CORPORATION.  USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
# WITHOUT THE PRIOR EXPRESS WRITTEN PERMISSION OF SYMANTEC CORPORATION.
#
# The Licensed Software and Documentation are deemed to be commercial
# computer software as defined in FAR 12.212 and subject to restricted
# rights as defined in FAR Section 52.227-19 "Commercial Computer
# Software - Restricted Rights" and DFARS 227.7202, "Rights in
# Commercial Computer Software or Commercial Computer Software
# Documentation", as applicable, and any successor regulations. Any use,
# modification, reproduction release, performance, display or disclosure
# of the Licensed Software and Documentation by the U.S. Government
# shall be solely in accordance with the terms of this Agreement.  $
#
use strict;

package Pkg::VRTSsfcpi61::Common;
@Pkg::VRTSsfcpi61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsfcpi61';
    $pkg->{name}=Msg::new("Storage Foundation Installer")->{msg};
    $pkg->{installpkgslast}=1;
    $pkg->{installpatcheslast}=1;
    return;
}

# Add dependency for other products only when uninstall VRTSsfcpi
sub query_pkgdep_sys {
    my ($pkg,$sys)=@_;
    my ($vxvm,$vxfs,$vcs);
    my (@softdeps);
    if (Cfg::opt('uninstall')) {
        $vxvm = $sys->pkg('VRTSvxvm61');
        $vxfs = $sys->pkg('VRTSvxfs61');
        $vcs = $sys->pkg('VRTSvcs61');
        push (@softdeps, $vxvm->{pkg}) if ($vxvm->version_sys($sys));
        push (@softdeps, $vxfs->{pkg}) if ($vxfs->version_sys($sys));
        push (@softdeps, $vcs->{pkg}) if ($vcs->version_sys($sys));
        return \@softdeps;
    }
    return [];
}

# Deal with situations that won't uninstall old VRTSsfcpi package
sub donotuninstall_sys {
    return 0 unless (Cfg::opt('upgrade'));
    return 1;
}

# Deal with VRTSsfcpi packages that should be uninstalled during upgrade
sub set_sfcpi_upgrade_sys {
    my ($pkg,$sys) = @_;
    my ($cpic, $cprod, $prod, $prodver, $rel);
    my ($pkgver,$oldcpipkg,$donotuninstall);
    return 1 unless (Cfg::opt(qw/upgrade patchupgrade/));
    $cpic = Obj::cpic();
    $rel = Obj::rel();
    $cprod = CPIC::get('prod');
    $prod = $cpic->rel->prod($cprod);
    $prodver = $prod->{vers};
    for my $oldpkg (keys%{$sys->{pkgvers}}) {
        $donotuninstall=0;
        if ($oldpkg =~ /VRTSsfcpi/ && ($oldpkg ne $pkg->{pkg})) {
            # for rolling upgrade, the VRTSsfcpi package should be uninstalled
            if (!Cfg::opt('patchupgrade') && !Cfg::opt('rolling_upgrade')) {
                for my $pkgi (qw /VRTSvxvm VRTSvxfs VRTSvcs/) {
                    $pkgver = $sys->{pkgvers}{$pkgi};
                    next unless ($pkgver);
                    # Do not block uninstallation of VRTSsfcpi if VRTSvcs is installed as part of AppHA.
                    next if( $pkgi eq 'VRTSvcs' && $sys->{pkgvers}{'VRTSvcsvmw'} );
                    if (!EDRu::inarr($pkgi.'61', @{$sys->{installpkgs}}) && !EDRu::compvers($sys->{pkgvers}{$oldpkg},$pkgver,3) ) {
                        Msg::log("$oldpkg will not be uninstalled on $sys->{sys} because $pkgi $pkgver is still installed on that system.");
                        $donotuninstall=1;
                        last;
                    }
                }
            }
            # In RP releases, we don't need to consider partial upgrade
            # Just remove all the obsoleted VRTSsfcpi packages will be ok.
            if (Cfg::opt('patchupgrade') && !EDRu::inarr($oldpkg,@{$rel->{obsoletedsfcpipkgs}})) {
                $donotuninstall=1;
            }
            unless ($donotuninstall) {
                $oldcpipkg=Pkg->new_pkg($oldpkg, $cpic->{padv});
                $oldcpipkg=Pkg->new_pkg($oldpkg, $sys->{padv});
                $oldcpipkg->add_uninstall_sys($sys);
                push (@{$cpic->{uninstallpkgs}},$oldpkg) unless (EDRu::inarr($oldpkg,@{$cpic->{uninstallpkgs}}));
            }
        }
    }
    return 1;
}

sub postinstall_sys {
    my ($pkg,$sys)=@_;
    my $rootpath = Cfg::opt('rootpath');
    my $scriptfile="$rootpath/opt/VRTS/install/bin/UXRT61/add_install_scripts";
    my $prod=CPIC::get('prod');
    if(Cfg::opt("upgrade_kernelpkgs")){
        if($sys->exists($scriptfile,$sys)){
            Msg::log("Creating install scripts");
            $sys->cmd("CALLED_BY=CPI $scriptfile force $prod 2>/dev/null");
        }
    }
}

package Pkg::VRTSsfcpi61::AIX;
@Pkg::VRTSsfcpi61::AIX::ISA = qw(Pkg::VRTSsfcpi61::Common);

package Pkg::VRTSsfcpi61::HPUX;
@Pkg::VRTSsfcpi61::HPUX::ISA = qw(Pkg::VRTSsfcpi61::Common);

package Pkg::VRTSsfcpi61::Linux;
@Pkg::VRTSsfcpi61::Linux::ISA = qw(Pkg::VRTSsfcpi61::Common);

package Pkg::VRTSsfcpi61::SunOS;
@Pkg::VRTSsfcpi61::SunOS::ISA = qw(Pkg::VRTSsfcpi61::Common);

package Pkg::VRTSsfcpi61::Sol11sparc;
@Pkg::VRTSsfcpi61::Sol11sparc::ISA = qw(Pkg::VRTSsfcpi61::SunOS);

sub preremove_sys {
    my ($pkg,$sys)=@_;
    my $rootpath = Cfg::opt('rootpath');
    my $scriptfile="$rootpath/opt/VRTS/install/bin/UXRT61/add_install_scripts";
    $sys->cmd("CALLED_BY=CPI $scriptfile delete 2>/dev/null");
}

1;
