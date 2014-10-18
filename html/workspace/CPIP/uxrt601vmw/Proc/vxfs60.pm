use strict;

package Proc::vxfs60::Common;
@Proc::vxfs60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxfs';
    $proc->{name}='vxfs name';
    $proc->{desc}='vxfs description';
    $proc->{fatal}=1;
    return;
}

package Proc::vxfs60::AIX;
@Proc::vxfs60::AIX::ISA = qw(Proc::vxfs60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} load");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} unload");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxcfg $proc->{proc} status");
    return !EDR::cmdexit();
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxfs60::HPUX;
@Proc::vxfs60::HPUX::ISA = qw(Proc::vxfs60::Common);

package Proc::vxfs60::Linux;
@Proc::vxfs60::Linux::ISA = qw(Proc::vxfs60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::vxfs60::SunOS;
@Proc::vxfs60::SunOS::ISA = qw(Proc::vxfs60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

1;
