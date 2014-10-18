use strict;

package Proc::vxatd50::Common;
@Proc::vxatd50::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxatd';
    $proc->{name}='Symantec Product Authentication Service';
    $proc->{desc}='vxatd description';
    $proc->{stop_sleep}=10;
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{donotstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists('/opt/VRTSat/bin/vxatd')) {
        $sys->cmd('/opt/VRTSat/bin/vxatd');
        return 1 if (EDR::cmdexit()==0);
    }
    return 0;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($pids);

    $proc->backup_sys($sys);
    $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids >= 0) {
        Msg::log("Try to kill -9 $proc->{proc} ...");
        $sys->kill_pids(@$pids);
    }
    return 1;
}

sub backup_sys {
    my ($proc,$sys)=@_;
    my ($pids,$vssat);

    return unless (Cfg::opt(qw(upgrade uninstall)));
    $vssat = '/opt/VRTSat/bin/vssat';
    $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids >= 0) {
        Msg::log("Backup the VxAT data:\n");
        $sys->cmd("$vssat showbackuplist 2>/dev/null");
    }
    return;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    return 0 if ($#$pids == -1);
    return 1;
}

package Proc::vxatd50::AIX;
@Proc::vxatd50::AIX::ISA = qw(Proc::vxatd50::Common);

package Proc::vxatd50::HPUX;
@Proc::vxatd50::HPUX::ISA = qw(Proc::vxatd50::Common);

package Proc::vxatd50::Linux;
@Proc::vxatd50::Linux::ISA = qw(Proc::vxatd50::Common);

package Proc::vxatd50::SunOS;
@Proc::vxatd50::SunOS::ISA = qw(Proc::vxatd50::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/opt/VRTSat/bin/vxatd';
    $proc->{smf_manifest}='/var/svc/manifest/system/vxat.xml';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    if($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -s system/vxatd');
        $sys->cmd('_cmd_svcadm enable system/vxatd');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile}");
    } else {
        return 0;
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($pids);
    $proc->backup_sys($sys);
    if($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vxatd');
    }
    $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids >= 0) {
        Msg::log("Try to kill -9 $proc->{proc} ...");
        $sys->kill_pids(@$pids);
    }
    return 1;
}
1;
