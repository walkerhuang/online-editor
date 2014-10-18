use strict;

package Proc::vxpal50::Common;
@Proc::vxpal50::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxpal';
    $proc->{name}='vxpal';
    $proc->{desc}='vxpal description';
    $proc->{start_period}=60;
    $proc->{stop_period}=10;
    $proc->{vxpal_bin_dir}='/opt/VRTSobc/pal33/bin';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my $agent;
    for my $agent (qw(gridnode actionagent StorageAgent DBEDAgent VAILAgent)) {
        if ($proc->status_agent_sys($sys,$agent)){
            $proc->stop_agent_sys($sys,$agent);
        }
    }
    my $pids=$sys->proc_pids($proc->{proc});
    $sys->kill_pids(@$pids);
    return 1;
}


sub status_agent_sys {
   my ($proc,$sys,$agent) = @_;
   my $stdout = $sys->cmd("$proc->{vxpal_bin_dir}/vxpalctrl -a $agent -c status");
   if( 0 != EDR::cmdexit()) {
       Msg::log('Bad exit code');
   }
   return 0 if ($stdout =~ m/NOT\s+RUNNING/i);
   return 1 if ($stdout =~ m/(RUNNING|STARTING|UNKNOWN)/i);
   # assume stopped.
   Msg::log('Indeterminate status');
   return 0;
}

sub stop_agent_sys {
    my ($proc,$sys,$agent) = @_;
    Msg::log("Stopping $agent on $sys->{sys}");
    $sys->cmd("$proc->{vxpal_bin_dir}/vxpalctrl -a $agent -c stop");
    return 1;
}

package Proc::vxpal50::AIX;
@Proc::vxpal50::AIX::ISA = qw(Proc::vxpal50::Common);

package Proc::vxpal50::HPUX;
@Proc::vxpal50::HPUX::ISA = qw(Proc::vxpal50::Common);

package Proc::vxpal50::Linux;
@Proc::vxpal50::Linux::ISA = qw(Proc::vxpal50::Common);

package Proc::vxpal50::SunOS;
@Proc::vxpal50::SunOS::ISA = qw(Proc::vxpal50::Common);

1;
