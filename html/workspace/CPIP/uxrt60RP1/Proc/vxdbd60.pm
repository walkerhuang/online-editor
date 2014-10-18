use strict;

package Proc::vxdbd60::Common;
@Proc::vxdbd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxdbd';
    $proc->{name}='vxdbd name';
    $proc->{desc}='vxdbd description';
    $proc->{start_period}=120;
    $proc->{stop_period}=120;
    $proc->{controlfile}='/opt/VRTS/bin/vxdbdctrl';
    $proc->{prev_controlfile1}='/opt/VRTSdbed/common/bin/vxdbdctrl';
    $proc->{prev_controlfile2}='/opt/VRTSdbcom/bin/vxdbdctrl';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if($sys->exists("$proc->{controlfile}")) {
        $sys->cmd("$proc->{controlfile} stop");
    }
    if ($sys->exists("$proc->{prev_controlfile1}")) {
        # fix for e2407762
        # stop vxdbd using the old control file when we are upgrading
        $sys->cmd("$proc->{prev_controlfile1} stop");
    } elsif ($sys->exists("$proc->{prev_controlfile2}")) {
        # stop vxdbd using the old control file when we are upgrading
        $sys->cmd("$proc->{prev_controlfile2} stop");
    }
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

package Proc::vxdbd60::AIX;
@Proc::vxdbd60::AIX::ISA = qw(Proc::vxdbd60::Common);

package Proc::vxdbd60::HPUX;
@Proc::vxdbd60::HPUX::ISA = qw(Proc::vxdbd60::Common);

package Proc::vxdbd60::Linux;
@Proc::vxdbd60::Linux::ISA = qw(Proc::vxdbd60::Common);

package Proc::vxdbd60::SunOS;
@Proc::vxdbd60::SunOS::ISA = qw(Proc::vxdbd60::Common);

1;
