use strict;

package Proc::vxportal60::Common;
@Proc::vxportal60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxportal';
    $proc->{name}='vxportal name';
    $proc->{desc}='vxportal description';
    $proc->{fatal}=1;
    return;
}

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

package Proc::vxportal60::AIX;
@Proc::vxportal60::AIX::ISA = qw(Proc::vxportal60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{proc}='portal';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} load 2> /dev/null");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} unload 2> /dev/null");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxcfg $proc->{proc} status 2> /dev/null");
    return !EDR::cmdexit();
}

package Proc::vxportal60::HPUX;
@Proc::vxportal60::HPUX::ISA = qw(Proc::vxportal60::Common);

package Proc::vxportal60::Linux;
@Proc::vxportal60::Linux::ISA = qw(Proc::vxportal60::Common);

package Proc::vxportal60::SunOS;
@Proc::vxportal60::SunOS::ISA = qw(Proc::vxportal60::Common);

1;
