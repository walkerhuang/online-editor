use strict;

package Proc::gab60::Common;
@Proc::gab60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='gab';
    $proc->{name}='Veritas Group Membership and Atomic Broadcast';
    $proc->{desc}='Veritas Group Membership and Atomic Broadcast';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading  driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

package Proc::gab60::AIX;
@Proc::gab60::AIX::ISA = qw(Proc::gab60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S92gab';
    $proc->{kernelfile}='/etc/methods/gabkext';
    $proc->{driverfile}='/usr/lib/drivers/gab';
    $proc->{initconf}='/etc/default/gab';
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
    Msg::log('Unloading gab driver');
    $sys->cmd("$proc->{kernelfile} -stop 2> /dev/null");
    return 1;
}

package Proc::gab60::Linux;
@Proc::gab60::Linux::ISA = qw(Proc::gab60::Common);
sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/gab';
    $proc->{initconf}='/etc/sysconfig/gab';
    return;
}

package Proc::gab60::SunOS;
@Proc::gab60::SunOS::ISA = qw(Proc::gab60::Common);

sub init_plat {
    my $proc = shift;
    $proc->{controlfile}='/etc/rc2.d/S92gab';
    $proc->{smf_manifest}='/var/svc/manifest/system/gab.xml';
    $proc->{initconf}='/etc/default/gab';
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($cmdoutput);
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/gab');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/gab');
            $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
        }
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd('_cmd_gabconfig -U 2> /dev/null');
    }
    sleep 5;
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading gab driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

1;
