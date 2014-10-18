use strict;

package Proc::vxdmp60::Common;
@Proc::vxdmp60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxdmp';
    $proc->{name}='vxdmp name';
    $proc->{desc}='vxdmp description';
    $proc->{fatal}=1;
    return;
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

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxdmp60::AIX;
@Proc::vxdmp60::AIX::ISA = qw(Proc::vxdmp60::Common);

package Proc::vxdmp60::HPUX;
@Proc::vxdmp60::HPUX::ISA = qw(Proc::vxdmp60::Common);

package Proc::vxdmp60::Linux;
@Proc::vxdmp60::Linux::ISA = qw(Proc::vxdmp60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

package Proc::vxdmp60::SunOS;
@Proc::vxdmp60::SunOS::ISA = qw(Proc::vxdmp60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

1;
