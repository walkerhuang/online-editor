use strict;

package Proc::vxglm60::Common;
@Proc::vxglm60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxglm';
    $proc->{name}='vxglm name';
    $proc->{desc}='vxglm description';
    $proc->{fatal}=1;
    return;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## gabconfig -a output:\n\n");
    $sys->cmd('_cmd_gabconfig -a 2> /dev/null');
    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxglm60::AIX;
@Proc::vxglm60::AIX::ISA = qw(Proc::vxglm60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/glmkextadm load 2> /dev/null');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/glmkextadm unload 2> /dev/null') if($sys->exists('/etc/methods/glmkextadm'));
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $glmconf = $sys->cmd("/etc/methods/glmkextadm status | _cmd_grep 'not loaded'");
    return 1 if ($glmconf eq '');
    return 0;
}

package Proc::vxglm60::HPUX;
@Proc::vxglm60::HPUX::ISA = qw(Proc::vxglm60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_kcmodule -B vxglm=loaded');
    $sys->cmd('/sbin/init.d/vxglm start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/vxglm stop');
    $sys->cmd('_cmd_kcmodule vxglm=unused');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('vxglmd');
    return 1 if ($#$pids>=0);
    return 0;
}

package Proc::vxglm60::Linux;
@Proc::vxglm60::Linux::ISA = qw(Proc::vxglm60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{start_period}=10;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxglm start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("export PATH=/bin:/sbin:\$PATH; /etc/init.d/vxglm stop");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->padv->driver_sys($sys,$proc->{proc});
    return 1 if($rtn ne '');
    return 0;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -aef');
    Msg::log("## modinfo output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_lsmod');
    Msg::log("## gabconfig -a output:\n\n");
    $sys->cmd('_cmd_gabconfig -a 2> /dev/null');
    return;
}

package Proc::vxglm60::SunOS;
@Proc::vxglm60::SunOS::ISA = qw(Proc::vxglm60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
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
}

1;
