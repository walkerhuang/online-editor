use strict;

package Proc::vxnotify60::Common;
@Proc::vxnotify60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxnotify';
    $proc->{name}='vxnotify name';
    $proc->{desc}='vxnotify description';
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;

    #Check sfmh-discovery status before stopping vxnotify
    my $cpic=Obj::cpic();
    my $procobj=$sys->proc('sfmhdiscovery60');
    if($procobj && $procobj->check_sys($sys,"stop")){
        Msg::log("Stopping sfmh-discovery before vxnotify ");
        $procobj->stop_sys($sys);
        sleep 1;
     } else {
        Msg::log("sfmh-discovery is not running when stopping vxnotify");
     }

    my $pids=$sys->proc_pids($proc->{proc});
    $sys->kill_pids(@$pids);
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

package Proc::vxnotify60::AIX;
@Proc::vxnotify60::AIX::ISA = qw(Proc::vxnotify60::Common);

package Proc::vxnotify60::HPUX;
@Proc::vxnotify60::HPUX::ISA = qw(Proc::vxnotify60::Common);

package Proc::vxnotify60::Linux;
@Proc::vxnotify60::Linux::ISA = qw(Proc::vxnotify60::Common);

package Proc::vxnotify60::SunOS;
@Proc::vxnotify60::SunOS::ISA = qw(Proc::vxnotify60::Common);

1;
