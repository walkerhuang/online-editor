use strict;

package Proc::vxesd60::Common;
@Proc::vxesd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxesd';
    $proc->{name}='vxesd name';
    $proc->{desc}='vxesd description';
    $proc->{stop_sleep}=10;
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    # Remove the vxesd lock file if present, so vxesd can start
    if($sys->exists('/etc/vx/.vxesd.lock')) {
         $sys->cmd('_cmd_rmr /etc/vx/.vxesd.lock');
         $sys->cmd('_cmd_touch /etc/vx/.vxesd.lock');
    }
    $sys->cmd('_cmd_vxddladm start eventsource');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($pids,$time);
    $sys->cmd('_cmd_vxddladm stop eventsource 2>/dev/null');
    $time=0;
    while ($time <= 60) {
        $pids = $sys->proc_pids("sbin/$proc->{proc}");
        last if ($#$pids < 0);
        sleep 5;
        $time += 5;
    }
    if ($#$pids >= 0) {
         Msg::log("stop failed, try to kill $proc->{proc} ...");
         $sys->kill_pids(@$pids);
    }
    $sys->cmd('_cmd_rmr /etc/vx/vxesd 2>/dev/null');
    $sys->cmd('_cmd_rmr /etc/vx/.vxesd.lock 2>/dev/null');

    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids("sbin/$proc->{proc}");
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

package Proc::vxesd60::AIX;
@Proc::vxesd60::AIX::ISA = qw(Proc::vxesd60::Common);

sub start_sys {
    my ($proc,$sys) = @_;
    # Prevent HBA API calls from esd
    # AIX scsi commands are seralized on ioctls pending at hba
    # level and causes performance issues
    $sys->cmd('_cmd_vxdmpadm settune dmp_monitor_fabric=off 2> /dev/null');
    return $proc->SUPER::start_sys($sys);
}

package Proc::vxesd60::HPUX;
@Proc::vxesd60::HPUX::ISA = qw(Proc::vxesd60::Common);

package Proc::vxesd60::Linux;
@Proc::vxesd60::Linux::ISA = qw(Proc::vxesd60::Common);

package Proc::vxesd60::SunOS;
@Proc::vxesd60::SunOS::ISA = qw(Proc::vxesd60::Common);

sub start_sys {
    my ($proc,$sys) = @_;
    if ($sys->padv->driver_sys($sys,'emcp')) {
        Msg::log('EMC powerpath is configured, prevent OS device attach events from vxesd...');
        $sys->cmd('_cmd_vxdmpadm settune dmp_monitor_osevent=off 2> /dev/null');
    } else {
        $sys->cmd('_cmd_vxdmpadm settune dmp_monitor_osevent=on 2> /dev/null');
    }
    return $proc->SUPER::start_sys($sys);
}

1;
