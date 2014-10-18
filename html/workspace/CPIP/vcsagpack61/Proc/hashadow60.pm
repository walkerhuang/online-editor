use strict;

package Proc::hashadow60::Common;
@Proc::hashadow60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='hashadow';
    $proc->{name}='Veritas HA Shadow';
    $proc->{desc}='Veritas HA Shadow description';
    $proc->{controlfile}='/opt/VRTSvcs/bin/hashadow';
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
    my $pids=$sys->proc_pids('hashadow');
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('hashadow');
    # kill hashadow
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::hashadow60::AIX;
@Proc::hashadow60::AIX::ISA = qw(Proc::hashadow60::Common);

package Proc::hashadow60::HPUX;
@Proc::hashadow60::HPUX::ISA = qw(Proc::hashadow60::Common);

package Proc::hashadow60::Linux;
@Proc::hashadow60::Linux::ISA = qw(Proc::hashadow60::Common);

package Proc::hashadow60::SunOS;
@Proc::hashadow60::SunOS::ISA = qw(Proc::hashadow60::Common);

1;
