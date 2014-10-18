use strict;

package Proc::vxdclid60::Common;
@Proc::vxdclid60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxdclid';
    $proc->{name}='vxdclid';
    $proc->{desc}='vxdclid description';
    $proc->{vxadm}='/opt/VRTSsfmh/bin/vxadm';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids("/opt/VRTSsfmh/bin/$proc->{proc}");
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
    if ($sys->exists("$proc->{vxadm}")) {
        $sys->cmd("$proc->{vxadm} service stop");
    }else{
        $sys->cmd("/opt/VRTSsfmh/adm/xprtldctrl stop");
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids);
    $pids=$sys->proc_pids("/opt/VRTSsfmh/bin/$proc->{proc}");
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::vxdclid60::AIX;
@Proc::vxdclid60::AIX::ISA = qw(Proc::vxdclid60::Common);

package Proc::vxdclid60::HPUX;
@Proc::vxdclid60::HPUX::ISA = qw(Proc::vxdclid60::Common);

package Proc::vxdclid60::Linux;
@Proc::vxdclid60::Linux::ISA = qw(Proc::vxdclid60::Common);

package Proc::vxdclid60::SunOS;
@Proc::vxdclid60::SunOS::ISA = qw(Proc::vxdclid60::Common);

1;
