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

package Pkg::VRTSat50::Common;
@Pkg::VRTSat50::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSat';
    $pkg->{upi}='VRTSat';
    $pkg->{gavers}='5.0.32.0';
    $pkg->{name}=Msg::new("Product Authentication Service")->{msg};
    $pkg->{osuuid}='/etc/vx/uuid/bin/osuuid';
    $pkg->{startprocs}=[ qw(vxatd50) ];
    $pkg->{stopprocs}=[ qw(vxatd50) ];
    $pkg->{softdeps}=[ qw(VRTScmcm VRTSvcs) ];
    return;
}

sub preremove_sys {
    my ($pkg, $sys) = @_;
    my $file;

    my $rootpath = Cfg::opt('rootpath');
    # backup the vxat data
    $file = EDR::tmpdir() . "/VxAT_data_$sys->{sys}.tar";
    $sys->cmd("_cmd_tar -cvf $file $rootpath/var/VRTSat $rootpath/var/VRTSat_lhc");
    $sys->copy_to_sys($pkg->localsys,$file);
    EDR::register_save_logfiles($file);
    return;
}

sub set_donotstopprocs_sys {
   my ($pkg,$sys)=@_;
   my ($proc);
   for my $proc (@{$pkg->{stopprocs}}) {
       push (@{$sys->{donotstopprocs}},$proc);
   }
    return;
}

package Pkg::VRTSat50::AIX;
@Pkg::VRTSat50::AIX::ISA = qw(Pkg::VRTSat50::Common);
sub init_plat {
    my $pkg=shift;
    $pkg->{pkgname}='VRTSat';
    # VRTSat breaks into VRTSat.client and VRTSat.server
    # use previouspkgnames for uninstall
    $pkg->{previouspkgnames} = [ qw(VRTSat.server VRTSat.client) ];
    $pkg->{space}=[144943,0,28,648];
    return;
}


package Pkg::VRTSat50::HPUX;
@Pkg::VRTSat50::HPUX::ISA = qw(Pkg::VRTSat50::Common);

# Workaround for e2026573/2430898 to remove the obsolete VRTSat pkg entry in IPD after OS upgrade
sub preremove_sys {
    my ($pkg,$sys)=@_;
    my ($output,@versions,$bigver,$ver,$msg,$cv);

    Pkg::VRTSat50::Common::preremove_sys($pkg,$sys);
    $output=$sys->cmd("_cmd_swlist -l product -a revision -x verbose=0 VRTSat 2> /dev/null | _cmd_grep VRTSat | _cmd_awk '{print \$2}'");
    @versions=split(/\n/,$output);
    $bigver='';
    for my $ver (@versions) {
        if ($bigver ne '') {
            $cv=EDRu::compvers($bigver,$ver,4);
            if ($cv==0) {
                $msg=Msg::new("Error: Duplicate versions of VRTSat $ver found on $sys->{sys}");
                $msg->die;
            } elsif ($cv==2) {
                ($ver,$bigver)=($bigver,$ver);
            }
            $sys->cmd("_cmd_swmodify -u VRTSat.\*,r=$ver VRTSat 2>/dev/null");
        } else {
            $bigver=$ver;
        }
    }
    return;
}

package Pkg::VRTSat50::Linux;
@Pkg::VRTSat50::Linux::ISA = qw(Pkg::VRTSat50::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{pkg}='VRTSatServer';
    $pkg->{nodeps}=1;
    $pkg->{nopostun}=1;
    return;
}

package Pkg::VRTSat50::SunOS;
@Pkg::VRTSat50::SunOS::ISA = qw(Pkg::VRTSat50::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{smf}=['/var/svc/manifest/system/vxat.xml', '/lib/svc/method/vxatd'];
    return;
}

sub preremove_sys {
    my ($pkg, $sys) = @_;

    Pkg::VRTSat50::Common::preremove_sys($pkg,$sys);
    my $vcs = $pkg->prod('VCS62');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    $pkg->web_patch_postremove_sys($sys);
    return;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS62');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

# workaround for incident 2373302
# when upgrade with webinstaller
# patch for VRTSat 4.3.28.0 (x64) or 4.3.22.1 (sparc) postremove script
# on the host which running xprtlwid, do not remove /var/VRTSat
sub web_patch_postremove_sys {
    my ($pkg, $sys) = @_;

    return unless (Obj::webui());
    return unless (Cfg::opt('upgrade'));

    my $web = Obj::web();
    return unless ($sys->{islocal} && -f "$web->{tmpdir}/browserid");

    my $pkgver = $pkg->version_sys($sys,1);
    return unless (($pkgver eq '4.3.28.0') || ($pkgver eq '4.3.22.1'));

    my $postremove_script = '/var/sadm/pkg/VRTSat/install/postremove';
    return unless ($sys->exists($postremove_script));
    my $script = $sys->readfile($postremove_script);
    # return if already patched
    if ($script =~ /^\s*\#.*rm.+\/var\/VRTSat.+\;$/m) {
        Msg::log("VRTSat postremove script was already patched");
        return;
    }
    $sys->writefile($script,"$web->{tmpdir}/postremove.vxatd.bak");
    $script =~ s/(^\s+echo.+\/var\/VRTSat.+\;$)/\#$1/m;
    $script =~ s/(^\s+rm.+\/var\/VRTSat.+\;$)/\#$1\nexit 0\;/m;
    $sys->writefile($script,"$web->{tmpdir}/postremove.vxatd.patch");
    Msg::log("patch VRTSat postremove script for web installer");
    $sys->writefile($script,$postremove_script);
    return 1;
}

1;
