use strict;

package Proc::vxspec60::Common;
@Proc::vxspec60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxspec';
    $proc->{name}='vxspec name';
    $proc->{desc}='vxspec description';
    $proc->{fatal}=1;
    return;
}

# unload from kernel
# 1 on success, 0 on failure
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    $proc->driver_force_unload_sys($sys) if($proc->check_sys($sys));
    return 1;
}

sub driver_force_unload_sys {
    my ($proc,$sys)=@_;
    #$sys->cmd("_cmd_rmdrv $proc->{proc}");
    return 1;
}


# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::vxspec60::AIX;
@Proc::vxspec60::AIX::ISA = qw(Proc::vxspec60::Common);

package Proc::vxspec60::HPUX;
@Proc::vxspec60::HPUX::ISA = qw(Proc::vxspec60::Common);

package Proc::vxspec60::Linux;
@Proc::vxspec60::Linux::ISA = qw(Proc::vxspec60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

package Proc::vxspec60::SunOS;
@Proc::vxspec60::SunOS::ISA = qw(Proc::vxspec60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}


sub start_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check start failures in /var/adm/messages:\n");
    $sys->cmd('_cmd_tail -10 /var/adm/messages 2>/dev/null');
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check stop failures in /var/adm/messages:\n");
    $sys->cmd('_cmd_tail -10 /var/adm/messages 2>/dev/null');
    return 1;
}

1;
