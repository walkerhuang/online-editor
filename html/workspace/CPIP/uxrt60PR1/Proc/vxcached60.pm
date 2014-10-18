use strict;

package Proc::vxcached60::Common;
@Proc::vxcached60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxcached';
    $proc->{name}='vxcached name';
    $proc->{desc}='vxcached description';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_nohup _cmd_vxcached root > /dev/null 2>&1 < /dev/null &');
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
    my $pids= $sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

package Proc::vxcached60::AIX;
@Proc::vxcached60::AIX::ISA = qw(Proc::vxcached60::Common);

package Proc::vxcached60::HPUX;
@Proc::vxcached60::HPUX::ISA = qw(Proc::vxcached60::Common);

package Proc::vxcached60::Linux;
@Proc::vxcached60::Linux::ISA = qw(Proc::vxcached60::Common);

package Proc::vxcached60::SunOS;
@Proc::vxcached60::SunOS::ISA = qw(Proc::vxcached60::Common);

1;
