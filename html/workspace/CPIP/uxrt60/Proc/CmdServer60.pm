use strict;

package Proc::CmdServer60::Common;
@Proc::CmdServer60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='CmdServer';
    $proc->{name}='Veritas Command Server';
    $proc->{desc}='CmdServer description';
    $proc->{controlfile}='/opt/VRTSvcs/bin/CmdServer';
    $proc->{stop_period}=10;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile}");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} -stop");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('CmdServer');
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('CmdServer');
    # kill CmdServer
    $sys->kill_pids(@$pids);
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check start failures in CmdServer-log_A.log:\n");
    $sys->cmd('_cmd_tail -10 /var/VRTSvcs/log/CmdServer-log_A.log 2>/dev/null');
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check stop failures in CmdServer-log_A.log:\n");
    $sys->cmd('_cmd_tail -10 /var/VRTSvcs/log/CmdServer-log_A.log 2>/dev/null');
    return 1;
}

package Proc::CmdServer60::AIX;
@Proc::CmdServer60::AIX::ISA = qw(Proc::CmdServer60::Common);

package Proc::CmdServer60::HPUX;
@Proc::CmdServer60::HPUX::ISA = qw(Proc::CmdServer60::Common);

package Proc::CmdServer60::Linux;
@Proc::CmdServer60::Linux::ISA = qw(Proc::CmdServer60::Common);

package Proc::CmdServer60::SunOS;
@Proc::CmdServer60::SunOS::ISA = qw(Proc::CmdServer60::Common);

1;
