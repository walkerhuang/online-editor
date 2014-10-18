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

package Pkg::VRTSvcs61::Common;
@Pkg::VRTSvcs61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcs';
    $pkg->{name}=Msg::new("Cluster Server")->{msg};
    $pkg->{startprocs}=[ qw(had61 CmdServer61) ];
    $pkg->{stopprocs}=[ qw(had61 CmdServer61) ];
    $pkg->{autoremovedependentpkgs}=1;
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcs61::AIX;
@Pkg::VRTSvcs61::AIX::ISA = qw(Pkg::VRTSvcs61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSvcs.rte) ];
    return;
}

package Pkg::VRTSvcs61::HPUX;
@Pkg::VRTSvcs61::HPUX::ISA = qw(Pkg::VRTSvcs61::Common);

sub define_ospatches {
    my ($pkg,$padv,$sys) = @_;

    # we need to check PHCO_43449 only if HPUX OS version is 11.31.1303
    if (EDRu::compvers($sys->{fusionversion}, '11.31.1303') < 2) {
        push(@{$pkg->{ospatches}{"11.31IA"}},"PHCO_43449");
        push(@{$pkg->{ospatches}{"11.31PA"}},"PHCO_43449");
    }
}

package Pkg::VRTSvcs61::Linux;
@Pkg::VRTSvcs61::Linux::ISA = qw(Pkg::VRTSvcs61::Common);

package Pkg::VRTSvcs61::RHEL5x8664;
@Pkg::VRTSvcs61::RHEL5x8664::ISA = qw(Pkg::VRTSvcs61::Linux);

sub init_padv {
    my $pkg=shift;
    return;
}

package Pkg::VRTSvcs61::RHEL6x8664;
@Pkg::VRTSvcs61::RHEL6x8664::ISA = qw(Pkg::VRTSvcs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.12.9-11.el6.i686",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.12.9-11.el6.i686",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.14.3-9.el6.i686",
    };
    return;
}

package Pkg::VRTSvcs61::SLES10x8664;
@Pkg::VRTSvcs61::SLES10x8664::ISA = qw(Pkg::VRTSvcs61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTSvcs61::SLES11x8664;
@Pkg::VRTSvcs61::SLES11x8664::ISA = qw(Pkg::VRTSvcs61::Linux);

sub init_padv {
    my $pkg=shift;
    return;
}

package Pkg::VRTSvcs61::SunOS;
@Pkg::VRTSvcs61::SunOS::ISA = qw(Pkg::VRTSvcs61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{ospkgs}{all}=[ 'SUNWpool' ];
    $pkg->{smf}=['/var/svc/manifest/system/vcs.xml', '/lib/svc/method/vcs'];
    return;
}

# workaround of 1638382, remove the preremove script of obsolete pkg
sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($rootpath,$vers,$preremove_script);

    $vers=$sys->padv->pkg_version_sys($sys, $pkg);
    if (Cfg::opt('rootpath') && ($vers eq '5.0')) {
        $rootpath = Cfg::opt('rootpath');
        $preremove_script="$rootpath/var/sadm/pkg/VRTSvcs/install/preremove";
        $sys->cmd("_cmd_rm $preremove_script");
    }
    my $vcs = $pkg->prod('VCS61');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return 1;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS61');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

package Pkg::VRTSvcs61::Sol11sparc;
@Pkg::VRTSvcs61::Sol11sparc::ISA = qw(Pkg::VRTSvcs61::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{ospkgs}{all}=[ 'resource-pools' ];
    return;
}

package Pkg::VRTSvcs61::Sol11x64;
@Pkg::VRTSvcs61::Sol11x64::ISA = qw(Pkg::VRTSvcs61::Sol11sparc);

1;
