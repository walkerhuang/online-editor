use strict;

package Proc::vxgms60::Common;
@Proc::vxgms60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxgms';
    $proc->{name}='vxgms name';
    $proc->{desc}='vxgms description';
    $proc->{fatal}=1;
    return;
}

package Proc::vxgms60::AIX;
@Proc::vxgms60::AIX::ISA = qw(Proc::vxgms60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/gmskextadm load');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/gmskextadm unload') if($sys->exists('/etc/methods/gmskextadm'));
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    return 0 unless $sys->exists('/etc/methods/gmskextadm');
    my $gmsconf = $sys->cmd("/etc/methods/gmskextadm status | _cmd_grep 'not loaded'");
    return 1 if ($gmsconf eq '');
    return 0;
}

package Proc::vxgms60::HPUX;
@Proc::vxgms60::HPUX::ISA = qw(Proc::vxgms60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/vxgms start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/vxgms stop');
    $sys->cmd('_cmd_kcmodule vxgms=unused');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('vxgmsd');
    return 1 if ($#$pids>=0);
    return 0;
}

package Proc::vxgms60::Linux;
@Proc::vxgms60::Linux::ISA = qw(Proc::vxgms60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{start_period}=20;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxgms start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxgms stop');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->padv->driver_sys($sys,$proc->{proc});
    return 1 if ($rtn ne '');
    return 0;
}

package Proc::vxgms60::SunOS;
@Proc::vxgms60::SunOS::ISA = qw(Proc::vxgms60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_adddrv vxgms');
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->padv->driver_sys($sys,$proc->{proc});
    return 1 if ($rtn ne '');
    return 0;
    # TODO: start/stop/stat ?
}

1;
