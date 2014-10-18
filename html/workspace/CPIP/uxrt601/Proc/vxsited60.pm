use strict;

package Proc::vxsited60::Common;
@Proc::vxsited60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxsited';
    $proc->{name}='vxsited name';
    $proc->{desc}='vxsited description';
    return;
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

package Proc::vxsited60::AIX;
@Proc::vxsited60::AIX::ISA = qw(Proc::vxsited60::Common);

package Proc::vxsited60::HPUX;
@Proc::vxsited60::HPUX::ISA = qw(Proc::vxsited60::Common);

package Proc::vxsited60::Linux;
@Proc::vxsited60::Linux::ISA = qw(Proc::vxsited60::Common);

package Proc::vxsited60::SunOS;
@Proc::vxsited60::SunOS::ISA = qw(Proc::vxsited60::Common);

1;
