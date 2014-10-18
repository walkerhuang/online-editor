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

package Pkg::VRTSvcs62::Common;
@Pkg::VRTSvcs62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcs';
    $pkg->{name}=Msg::new("Cluster Server")->{msg};
    $pkg->{startprocs}=[ qw(had62 CmdServer62) ];
    $pkg->{stopprocs}=[ qw(had62 CmdServer62) ];
    $pkg->{autoremovedependentpkgs}=1;
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcs62::AIX;
@Pkg::VRTSvcs62::AIX::ISA = qw(Pkg::VRTSvcs62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSvcs.rte) ];
    return;
}

package Pkg::VRTSvcs62::HPUX;
@Pkg::VRTSvcs62::HPUX::ISA = qw(Pkg::VRTSvcs62::Common);

sub define_ospatches {
    my ($pkg,$padv,$sys) = @_;

    # we need to check PHCO_43449 only if HPUX OS version is 11.31.1303
    if (EDRu::compvers($sys->{fusionversion}, '11.31.1303') < 2) {
        push(@{$pkg->{ospatches}{"11.31IA"}},"PHCO_43449");
        push(@{$pkg->{ospatches}{"11.31PA"}},"PHCO_43449");
    }
}

package Pkg::VRTSvcs62::Linux;
@Pkg::VRTSvcs62::Linux::ISA = qw(Pkg::VRTSvcs62::Common);

package Pkg::VRTSvcs62::RHEL5x8664;
@Pkg::VRTSvcs62::RHEL5x8664::ISA = qw(Pkg::VRTSvcs62::Linux);

package Pkg::VRTSvcs62::RHEL6x8664;
@Pkg::VRTSvcs62::RHEL6x8664::ISA = qw(Pkg::VRTSvcs62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "/bin/ksh"  =>  "ksh-20100621-16.el6.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.6-4.el6.i686",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "/bin/ksh"  =>  "ksh-20100621-19.el6.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-3.el6.i686",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "/bin/ksh"  =>  "ksh-20120801-10.el6.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-4.el6.i686",
    };
    $pkg->{oslibs}{'RHEL6.6'}={
        "/bin/ksh"  =>  "ksh-20120801-21.el6.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-11.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-11.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-11.el6.i686",
    };
    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;

}

package Pkg::VRTSvcs62::RHEL7x8664;
@Pkg::VRTSvcs62::RHEL7x8664::ISA = qw(Pkg::VRTSvcs62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL7.0'}={
        "/bin/ksh"  =>  "ksh-20120801-19.el7.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.8.2-16.el7.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.8.2-16.el7.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.8.2-16.el7.i686",
    };

    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSvcs62::OL6x8664;
@Pkg::VRTSvcs62::OL6x8664::ISA = qw(Pkg::VRTSvcs62::RHEL6x8664);

package Pkg::VRTSvcs62::OL7x8664;
@Pkg::VRTSvcs62::OL7x8664::ISA = qw(Pkg::VRTSvcs62::RHEL7x8664);

package Pkg::VRTSvcs62::SLES10x8664;
@Pkg::VRTSvcs62::SLES10x8664::ISA = qw(Pkg::VRTSvcs62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "/bin/ksh"  =>  "ksh-93t-13.17.19.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTSvcs62::SLES11x8664;
@Pkg::VRTSvcs62::SLES11x8664::ISA = qw(Pkg::VRTSvcs62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "/bin/ksh"  =>  "ksh-93u-0.6.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "/bin/ksh"  =>  "ksh-93u-0.18.1.x86_64",
    };
    return;
}

package Pkg::VRTSvcs62::SunOS;
@Pkg::VRTSvcs62::SunOS::ISA = qw(Pkg::VRTSvcs62::Common);

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
    my $vcs = $pkg->prod('VCS62');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return 1;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS62');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

package Pkg::VRTSvcs62::Sol11sparc;
@Pkg::VRTSvcs62::Sol11sparc::ISA = qw(Pkg::VRTSvcs62::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{ospkgs}{all}=[ 'resource-pools' ];
    return;
}

package Pkg::VRTSvcs62::Sol11x64;
@Pkg::VRTSvcs62::Sol11x64::ISA = qw(Pkg::VRTSvcs62::Sol11sparc);

1;
