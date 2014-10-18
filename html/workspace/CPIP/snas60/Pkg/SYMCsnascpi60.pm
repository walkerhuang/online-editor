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

package Pkg::SYMCsnascpi60::Common;
@Pkg::SYMCsnascpi60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='SYMCsnascpi';
    $pkg->{name}=Msg::new("Symantec Storage: NAS Installer")->{msg};
    $pkg->{installpkgslast}=1;
    $pkg->{donotrmonupgrade}=1;
    return;
}

# Add dependency for other products only when uninstall SYMCsnascpi 
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

sub postinstall_sys {
    my ($pkg,$sys)=@_;
    my $rootpath = Cfg::opt('rootpath');
    my $scriptfile="$rootpath/opt/VRTS/install/bin/SNAS60/add_install_scripts";
    my $prod=CPIC::get('prod');
    if(Cfg::opt("upgrade_kernelpkgs")){
        if($sys->exists($scriptfile,$sys)){
            Msg::log("Creating install scripts");
            $sys->cmd("CALLED_BY=CPI $scriptfile force $prod 2>/dev/null");
        }
    }
}

# Deal with VRTSsfcpi packages that should be uninstalled during upgrade
sub set_sfcpi_upgrade_sys {}

package Pkg::SYMCsnascpi60::AIX;
@Pkg::SYMCsnascpi60::AIX::ISA = qw(Pkg::SYMCsnascpi60::Common);

package Pkg::SYMCsnascpi60::HPUX;
@Pkg::SYMCsnascpi60::HPUX::ISA = qw(Pkg::SYMCsnascpi60::Common);

package Pkg::SYMCsnascpi60::Linux;
@Pkg::SYMCsnascpi60::Linux::ISA = qw(Pkg::SYMCsnascpi60::Common);

package Pkg::SYMCsnascpi60::SunOS;
@Pkg::SYMCsnascpi60::SunOS::ISA = qw(Pkg::SYMCsnascpi60::Common);

1;
