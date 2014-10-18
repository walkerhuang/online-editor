use strict;

package Pkg::VRTSveki60::Common;
@Pkg::VRTSveki60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSveki';
    $pkg->{name}=Msg::new("Veritas Kernel Interface")->{msg};
    return;
}

# no common as VRTSveki only exists on AIX
package Pkg::VRTSveki60::AIX;
@Pkg::VRTSveki60::AIX::ISA = qw(Pkg::VRTSveki60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{ospkgs}{'6.1'}=['bos.net.nfs.client' ];
    $pkg->{ospkgs}{'7.1'}=['bos.net.nfs.client' ];
#    $pkg->{startprocs}=[ qw(veki60) ];
#    $pkg->{stopprocs}=[ qw(veki60) ];
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
    my @procs=qw(vxgms60 vxglm60 gab60 llt60);
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

1;
