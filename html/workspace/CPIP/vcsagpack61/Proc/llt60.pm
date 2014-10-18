use strict;

package Proc::llt60::Common;
@Proc::llt60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='llt';
    $proc->{name}='Veritas Low Latency Transport';
    $proc->{desc}='llt description';
    $proc->{start_period}=60;
    $proc->{stop_period}=10;
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading LLT driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

package Proc::llt60::AIX;
@Proc::llt60::AIX::ISA = qw(Proc::llt60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S70llt';
    $proc->{driverfile}='/usr/lib/drivers/pse/llt';
    $proc->{initconf}='/etc/default/llt';
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
    if ($sys->padv->driver_sys($sys,$proc->{driverfile})) {
        Msg::log('Unloading LLT driver');
        $sys->padv->unload_driver_sys($sys,$proc->{driverfile});
    }
    return 1;
}

package Proc::llt60::Linux;
@Proc::llt60::Linux::ISA = qw(Proc::llt60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/llt';
    $proc->{initconf}='/etc/sysconfig/llt';
    return;
}

package Proc::llt60::SunOS;
@Proc::llt60::SunOS::ISA = qw(Proc::llt60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc2.d/S70llt';
    $proc->{smf_manifest}='/var/svc/manifest/system/llt.xml';
    $proc->{initconf}='/etc/default/llt';
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($cmdoutput);
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/llt');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/llt');
            $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
        }
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd('_cmd_lltconfig -oU 2> /dev/null');
    }
    sleep 5;
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading LLT driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

1;
