use strict;

package Proc::vxsvc34::Common;
@Proc::vxsvc34::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxsvc';
    $proc->{name}='vxsvc name';
    $proc->{desc}='vxsvc description';
    $proc->{vxsvcctrl} = '/opt/VRTSob/bin/vxsvcctrl';
    $proc->{vxsvc} = '/opt/VRTSob/bin/vxsvc';
    $proc->{vxsvc_log} = '/var/vx/isis/vxsvc.log';
    $proc->{start_period}=60;
    $proc->{stop_period}=20;
    $proc->{noreboot_failstart}=1;
    $proc->{noreboot_failstop}=1;
    return;
}

sub check_sys {
    my ($proc,$sys,$state)= @_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids>=0) {
        # stopping
        return 1 if ($state =~ /stop/m);
        # starting
        my $stdout = $sys->cmd("$proc->{vxsvcctrl} status 2>/dev/null");
        if ($stdout =~ /NOT\s+RUNNING/mx) {
            return 0;
        } elsif ($stdout =~ /RUNNING/mi) {
            return 1;
        } else {
            # default NOT RUNNING
            return 0;
        }
    } else {
        return 0;
    }
}

sub start_sys {
    my ($proc, $sys)= @_;
    $sys->cmd("echo `date` >>$proc->{vxsvc_log}");
    $sys->cmd("$proc->{vxsvcctrl} activate");
    $sys->cmd("$proc->{vxsvcctrl} start </dev/null >/dev/null 2>&1"); #original call
    $sys->cmd("echo `date` >>$proc->{vxsvc_log}");
    $sys->cmd("$proc->{vxsvc} </dev/null >>$proc->{vxsvc_log} 2>&1");
    return 1;
}

sub stop_sys {
    my ($proc,$sys) = @_;
    $sys->cmd("$proc->{vxsvcctrl} stop 2>/dev/null");
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids);
    $pids=$sys->proc_pids($proc->{proc});
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::vxsvc34::AIX;
@Proc::vxsvc34::AIX::ISA = qw(Proc::vxsvc34::Common);

package Proc::vxsvc34::HPUX;
@Proc::vxsvc34::HPUX::ISA = qw(Proc::vxsvc34::Common);

package Proc::vxsvc34::Linux;
@Proc::vxsvc34::Linux::ISA = qw(Proc::vxsvc34::Common);

package Proc::vxsvc34::SunOS;
@Proc::vxsvc34::SunOS::ISA = qw(Proc::vxsvc34::Common);

sub init_plat {
    my $proc=shift;
    $proc->{smf_manifest}='/var/svc/manifest/system/vxsvc.xml';
    return;
}

sub check_sys {
    my ($proc, $sys, $state)= @_;
    my $stdout;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids>=0) {
        # stopping
        return 1 if ($state =~ /stop/m);
        # starting
        if ($sys->exists($proc->{smf_manifest})) {
           $stdout=$sys->cmd("_cmd_svcs -v -p /system/vxsvc 2>/dev/null | _cmd_awk '{print \$1}'");
           if ($stdout =~ /online/m) {
               return 1;
           } else {
               return 0;
           }
        } else {
            $stdout = $sys->cmd("$proc->{vxsvcctrl} status 2>/dev/null");
            if ($stdout =~ /NOT\s+RUNNING/mx) {
                return 0;
            } elsif ($stdout =~ /RUNNING/mi) {
                return 1;
            } else {
                # default NOT RUNNING
                return 0;
            }
        }
    } else {
        return 0;
    }
}

1;
