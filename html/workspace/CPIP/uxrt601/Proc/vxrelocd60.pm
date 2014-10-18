use strict;

package Proc::vxrelocd60::Common;
@Proc::vxrelocd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxrelocd';
    $proc->{name}='vxrelocd name';
    $proc->{desc}='vxrelocd description';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_nohup _cmd_vxrelocd root > /dev/null 2>&1 < /dev/null &');
    sleep 2;
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
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

package Proc::vxrelocd60::AIX;
@Proc::vxrelocd60::AIX::ISA = qw(Proc::vxrelocd60::Common);

package Proc::vxrelocd60::HPUX;
@Proc::vxrelocd60::HPUX::ISA = qw(Proc::vxrelocd60::Common);

package Proc::vxrelocd60::Linux;
@Proc::vxrelocd60::Linux::ISA = qw(Proc::vxrelocd60::Common);

package Proc::vxrelocd60::SunOS;
@Proc::vxrelocd60::SunOS::ISA = qw(Proc::vxrelocd60::Common);

1;
