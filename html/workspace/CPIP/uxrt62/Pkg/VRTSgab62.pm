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

package Pkg::VRTSgab62::Common;
@Pkg::VRTSgab62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSgab';
    $pkg->{name}=Msg::new("Group Membership and Atomic Broadcast")->{msg};
    # some HPUX deviance
    $pkg->{startprocs}=[ qw(gab62) ];
    $pkg->{stopprocs}=[ qw(gab62) ];
    return;
}

package Pkg::VRTSgab62::AIX;
@Pkg::VRTSgab62::AIX::ISA = qw(Pkg::VRTSgab62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSgab.rte) ];
    return;
}
sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    $pkg->{donotrmonupgrade}=1 if(Cfg::opt("upgrade_kernelpkgs"));
    return;
}


package Pkg::VRTSgab62::HPUX;
@Pkg::VRTSgab62::HPUX::ISA = qw(Pkg::VRTSgab62::Common);

sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($vers);
    if (Cfg::opt('upgrade')) {
        $vers = $pkg->version_sys($sys);
        if (EDRu::compvers($vers,'4.1',2) == 0) {
            $pkg->{force_uninstall} = 1;
        }
    }
    return;
}

package Pkg::VRTSgab62::Linux;
@Pkg::VRTSgab62::Linux::ISA = qw(Pkg::VRTSgab62::Common);

package Pkg::VRTSgab62::RHEL5x8664;
@Pkg::VRTSgab62::RHEL5x8664::ISA = qw(Pkg::VRTSgab62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "libc.so.6"  =>  "glibc-2.5-49.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-49.x86_64",
        "libm.so.6"  =>  "glibc-2.5-49.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-58.x86_64",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "libc.so.6"  =>  "glibc-2.5-65.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-65.x86_64",
        "libm.so.6"  =>  "glibc-2.5-65.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",    
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "libc.so.6"  =>  "glibc-2.5-81.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-81.x86_64",
        "libm.so.6"  =>  "glibc-2.5-81.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "libc.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
        "libm.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };

    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSgab62::RHEL6x8664;
@Pkg::VRTSgab62::RHEL6x8664::ISA = qw(Pkg::VRTSgab62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "libc.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.80.el6.x86_64",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.80.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",    
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "libc.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.107.el6.x86_64",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.107.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.132.el6.x86_64",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.6'}={
        "libc.so.6"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.149.el6.i686",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.12-1.149.el6.x86_64",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.149.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.149.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.149.el6.x86_64",
    };
    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSgab62::RHEL7x8664;
@Pkg::VRTSgab62::RHEL7x8664::ISA = qw(Pkg::VRTSgab62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL7.0'}={
        "libc.so.6"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6()(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.17-55.el7.i686",
        "libc.so.6(GLIBC_2.13)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.4)(64bit)"  =>  "glibc-2.17-55.el7.x86_64",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.17-55.el7.i686",
        "libm.so.6"  =>  "glibc-2.17-55.el7.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.17-55.el7.i686 glibc-2.17-55.el7.x86_64",
    };

    for my $minorvers (keys %{$pkg->{oslibs}}) {
        if ($minorvers=~/RHEL(.*)/) {
            $pkg->{oslibs}{"OL$1"} = { %{$pkg->{oslibs}{$minorvers}} };
        }
    }
    return;
}

package Pkg::VRTSgab62::OL6x8664;
@Pkg::VRTSgab62::OL6x8664::ISA = qw(Pkg::VRTSgab62::RHEL6x8664);

package Pkg::VRTSgab62::OL7x8664;
@Pkg::VRTSgab62::OL7x8664::ISA = qw(Pkg::VRTSgab62::RHEL7x8664);

package Pkg::VRTSgab62::SLES10x8664;
@Pkg::VRTSgab62::SLES10x8664::ISA = qw(Pkg::VRTSgab62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.4-31.81.11.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
    };
    return;
}

package Pkg::VRTSgab62::SLES11x8664;
@Pkg::VRTSgab62::SLES11x8664::ISA = qw(Pkg::VRTSgab62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.31.1.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6()(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2.5)(64bit)"  =>  "glibc-2.11.3-17.54.1.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
   };
    return;
}

package Pkg::VRTSgab62::SunOS;
@Pkg::VRTSgab62::SunOS::ISA = qw(Pkg::VRTSgab62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{smf}=['/var/svc/manifest/system/gab.xml', '/lib/svc/method/gab'];
    return;
}

sub preremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS62');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS62');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

package Pkg::VRTSgab62::Solx64;
@Pkg::VRTSgab62::Solx64::ISA = qw(Pkg::VRTSgab62::SunOS);

sub preinstall_sys {
    my ($pkg,$sys)= @_;
    my $tmpdir = EDR::tmpdir();
    $sys->cmd("_cmd_chmod 755 $tmpdir");
    return 1;
}

sub postinstall_sys {
    my ($pkg,$sys)= @_;
    my $tmpdir = EDR::tmpdir();
    $sys->cmd("_cmd_chmod 700 $tmpdir");
    return 1;
}

1;
