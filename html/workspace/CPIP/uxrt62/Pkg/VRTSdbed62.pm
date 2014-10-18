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

package Pkg::VRTSdbed62::Common;
@Pkg::VRTSdbed62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbed';
    $pkg->{name}=Msg::new("Storage Foundation Databases")->{msg};
    $pkg->{startprocs}=[ qw(vxdbd62) ];
    $pkg->{stopprocs}=[ qw(vxdbd62) ];
    return;
}

sub donotuninstall_sys {
    my ($pkg,$sys)=@_;

    #e3490292,in-place package upgrade:upgrading from any version 
    #of VRTSdbed >= 6.0 && < 6.2 to any version of VRTSdbed >= 6.2
    if(Cfg::opt("upgrade")
        && 2 != EDRu::compvers($sys->{prodvers}[0],'6.0')
        && 2 == EDRu::compvers($sys->{prodvers}[0],'6.2')
        && 2 != EDRu::compvers($pkg->rel->{vers},'6.2')){
        $pkg->{donotrmonupgrade}=1;
    }
    return;
}

package Pkg::VRTSdbed62::AIX;
@Pkg::VRTSdbed62::AIX::ISA = qw(Pkg::VRTSdbed62::Common);

#e3521824:VRTSdbed has denpendency with VRTSveki on AIX platform,
#so change inplace upgrade to uninstall+install upgrade.
sub donotuninstall_sys {
    return;
}

package Pkg::VRTSdbed62::HPUX;
@Pkg::VRTSdbed62::HPUX::ISA = qw(Pkg::VRTSdbed62::Common);

sub preremove_sys {
    my ($pkg,$sys) = @_;
    my $vxdba_dir_bak = '/var/vx/vxdba_old.cpisave';
    my $vxdba_dir = '/var/vx/vxdba';
    # backup /var/vx/vxdba/ during upgrade
    # since pkg uninstall will delete it on HP-UX
    if (Cfg::opt('upgrade')) {
        $sys->cmd("_cmd_rmr $vxdba_dir_bak");
        $sys->cmd("_cmd_mv -f $vxdba_dir $vxdba_dir_bak");
        if (EDR::cmdexit()) {
            Msg::log("Failed to backup $vxdba_dir on $sys->{sys}");
        }
    }
    return;
}

sub postinstall_sys {
    my ($pkg,$sys) = @_;
    my $vxdba_dir_bak = '/var/vx/vxdba_old.cpisave';
    my $vxdba_dir = '/var/vx/vxdba';
    # restore /var/vx/vxdba/ after upgrade
    # use 'mv -f' to keep the oracle user's permission.
    if (Cfg::opt('upgrade') && ($sys->exists($vxdba_dir_bak))) {
        $sys->cmd("_cmd_mv -f $vxdba_dir_bak/* $vxdba_dir/");
    }
    return;
}

package Pkg::VRTSdbed62::Linux;
@Pkg::VRTSdbed62::Linux::ISA = qw(Pkg::VRTSdbed62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbed';
    $pkg->{previouspkgnames} = [ qw(VRTSdbed-common) ];
    $pkg->{nopreun}=1;
    return;
}

package Pkg::VRTSdbed62::SLES11x8664;
@Pkg::VRTSdbed62::SLES11x8664::ISA = qw(Pkg::VRTSdbed62::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{installonpatchupgrade}=1;
    return;
}

package Pkg::VRTSdbed62::SunOS;
@Pkg::VRTSdbed62::SunOS::ISA = qw(Pkg::VRTSdbed62::Common);

1;
