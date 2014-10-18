use strict;

package Proc::vxconfigbackupd60::Common;
@Proc::vxconfigbackupd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxconfigbackupd';
    $proc->{name}='vxconfigbackupd name';
    $proc->{desc}='vxconfigbackupd description';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_nohup _cmd_vxconfigbackupd > /dev/null 2>&1 < /dev/null &');
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

package Proc::vxconfigbackupd60::AIX;
@Proc::vxconfigbackupd60::AIX::ISA = qw(Proc::vxconfigbackupd60::Common);

package Proc::vxconfigbackupd60::HPUX;
@Proc::vxconfigbackupd60::HPUX::ISA = qw(Proc::vxconfigbackupd60::Common);

package Proc::vxconfigbackupd60::Linux;
@Proc::vxconfigbackupd60::Linux::ISA = qw(Proc::vxconfigbackupd60::Common);

package Proc::vxconfigbackupd60::SunOS;
@Proc::vxconfigbackupd60::SunOS::ISA = qw(Proc::vxconfigbackupd60::Common);

1;
