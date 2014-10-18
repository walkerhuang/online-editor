use strict;

package Proc::xprtld50::Common;
@Proc::xprtld50::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='xprtld';
    $proc->{name}='xprtld';
    $proc->{desc}='xprtld description';
    $proc->{xprtldctrl}='/opt/VRTSdcli/xprtl/adm/xprtldctrl';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids('/opt/VRTSdcli/xprtl/bin/xprtld');
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
    if ($sys->exists("$proc->{xprtldctrl}")) {
        $sys->cmd("$proc->{xprtldctrl} stop");
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids);
    $pids=$sys->proc_pids('/opt/VRTSdcli/xprtl/bin/xprtld');
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::xprtld50::AIX;
@Proc::xprtld50::AIX::ISA = qw(Proc::xprtld50::Common);

package Proc::xprtld50::HPUX;
@Proc::xprtld50::HPUX::ISA = qw(Proc::xprtld50::Common);

package Proc::xprtld50::Linux;
@Proc::xprtld50::Linux::ISA = qw(Proc::xprtld50::Common);

package Proc::xprtld50::SunOS;
@Proc::xprtld50::SunOS::ISA = qw(Proc::xprtld50::Common);

1;
