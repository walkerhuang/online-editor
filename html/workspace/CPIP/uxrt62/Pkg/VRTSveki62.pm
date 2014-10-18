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

package Pkg::VRTSveki62::Common;
@Pkg::VRTSveki62::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSveki';
    $pkg->{name}=Msg::new("Kernel Interface")->{msg};
    return;
}

# no common as VRTSveki only exists on AIX
package Pkg::VRTSveki62::AIX;
@Pkg::VRTSveki62::AIX::ISA = qw(Pkg::VRTSveki62::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{ospkgs}{'6.1'}=['bos.net.nfs.client' ];
    $pkg->{ospkgs}{'7.1'}=['bos.net.nfs.client' ];
#    $pkg->{startprocs}=[ qw(veki62) ];
#    $pkg->{stopprocs}=[ qw(veki62) ];
    return;
}

sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    if(Cfg::opt("upgrade_kernelpkgs")){
        $pkg->{donotrmonupgrade}=1
    }
    return;
}

sub preinstall_sys {
    my ($pkg,$sys)=@_;
    my $dev='/usr/lib/drivers/veki.ext';
    my @procs=qw(vxgms62 vxglm62 gab62 llt62);
    my $cpic=Obj::cpic();
    if(Cfg::opt("upgrade_kernelpkgs")){
        for my $proc(@procs){
            my $procobj=$sys->proc($proc);
            if($procobj && $procobj->check_sys($sys,"stop")){
                Msg::log("Stopping $proc because it is runing in preinstall_sys_veki");
                $procobj->stop_sys($sys);
                sleep 1;
            } else {
                Msg::log("$proc is not running in preinstall_sys_veki");
            }
        }

        #lsdev -Cc vxdrv
        my @devs=qw(vxspec vxio vxdmp);
        my $out=$sys->cmd("_cmd_lsdev -Cc vxdrv 2>/dev/null | _cmd_grep 'Available'");

        foreach my $dev(@devs){
            if($out=~/$dev/){
                $sys->cmd("/usr/lib/methods/ucfgvxvm -l $dev 2>/dev/null");
                if((EDR::cmdexit() != 0)){
                    Msg::log("Can not unload $dev");
                }
            }
        }
    }
    return 1;
}

package Pkg::VRTSveki62::Linux;
@Pkg::VRTSveki62::Linux::ISA = qw(Pkg::VRTSveki62::Common);

package Pkg::VRTSveki62::RHEL7x8664;
@Pkg::VRTSveki62::RHEL7x8664::ISA = qw(Pkg::VRTSveki62::Linux);

sub init_plat {
    my $pkg=shift;
    $pkg->{startprocs}=[ qw(veki62) ];
    #$pkg->{stopprocs}=[ qw(veki62) ];
    return;
}

1;
