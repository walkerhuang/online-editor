use strict;

package Proc::veki60::Common;
@Proc::veki60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='veki';
    $proc->{name}='veki name';
    $proc->{desc}='veki description';
    $proc->{fatal}=1;
    return;
}

package Proc::veki60::AIX;
@Proc::veki60::AIX::ISA = qw(Proc::veki60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{driverfile}='/usr/lib/drivers/veki.ext';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/vekiextadm load');
    $sys->cmd('/etc/methods/vekiextadm config');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/vekiextadm unconfig');
    $sys->cmd('/etc/methods/vekiextadm unload');
    sleep 3;
    if($proc->check_sys($sys)){
        Msg::log("Unload Driver on $sys->{sys}");
        $sys->padv->unload_driver_sys($sys,$proc->{driverfile});
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $mod;
    $mod=$sys->padv->driver_sys($sys, $proc->{driverfile});
    if ($mod eq '') {
        return 0;
    }
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc} on $sys->{sys}:\n\n");
    $sys->cmd('_cmd_ps -aef');
    return;
}

package Proc::veki60::HPUX;
@Proc::veki60::HPUX::ISA = qw(Proc::veki60::Common);

package Proc::veki60::Linux;
@Proc::veki60::Linux::ISA = qw(Proc::veki60::Common);

package Proc::veki60::SunOS;
@Proc::veki60::SunOS::ISA = qw(Proc::veki60::Common);

1;
