use strict;

package Proc::sfmhdiscovery60::Common;
@Proc::sfmhdiscovery60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='sfmh-discovery';
    $proc->{name}='sfmh-discovery name';
    $proc->{desc}='sfmh-discovery description';
    $proc->{controlfile}='/opt/VRTSsfmh/adm/vxvmdiscovery-ctrl.sh';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} stop");
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids("/opt/VRTSsfmh/bin/$proc->{proc}");
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids("/opt/VRTSsfmh/bin/$proc->{proc}");
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::sfmhdiscovery60::AIX;
@Proc::sfmhdiscovery60::AIX::ISA = qw(Proc::sfmhdiscovery60::Common);

package Proc::sfmhdiscovery60::HPUX;
@Proc::sfmhdiscovery60::HPUX::ISA = qw(Proc::sfmhdiscovery60::Common);

package Proc::sfmhdiscovery60::Linux;
@Proc::sfmhdiscovery60::Linux::ISA = qw(Proc::sfmhdiscovery60::Common);

package Proc::sfmhdiscovery60::SunOS;
@Proc::sfmhdiscovery60::SunOS::ISA = qw(Proc::sfmhdiscovery60::Common);

1;
