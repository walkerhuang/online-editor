use strict;

package Proc::vxattachd60::Common;
@Proc::vxattachd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxattachd';
    $proc->{name}='vxattachd name';
    $proc->{desc}='vxattachd description';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_nohup _cmd_vxattachd root > /dev/null 2>&1 < /dev/null &');
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

package Proc::vxattachd60::AIX;
@Proc::vxattachd60::AIX::ISA = qw(Proc::vxattachd60::Common);

package Proc::vxattachd60::HPUX;
@Proc::vxattachd60::HPUX::ISA = qw(Proc::vxattachd60::Common);

package Proc::vxattachd60::Linux;
@Proc::vxattachd60::Linux::ISA = qw(Proc::vxattachd60::Common);

package Proc::vxattachd60::SunOS;
@Proc::vxattachd60::SunOS::ISA = qw(Proc::vxattachd60::Common);

1;
