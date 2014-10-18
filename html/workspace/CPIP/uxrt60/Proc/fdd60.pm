use strict;

package Proc::fdd60::Common;
@Proc::fdd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='fdd';
    $proc->{name}='fdd name';
    $proc->{desc}='fdd description';
    return;
}

package Proc::fdd60::AIX;
@Proc::fdd60::AIX::ISA = qw(Proc::fdd60::Common);

package Proc::fdd60::HPUX;
@Proc::fdd60::HPUX::ISA = qw(Proc::fdd60::Common);

package Proc::fdd60::Linux;
@Proc::fdd60::Linux::ISA = qw(Proc::fdd60::Common);

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

package Proc::fdd60::SunOS;
@Proc::fdd60::SunOS::ISA = qw(Proc::fdd60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('echo vxfdd_nounload/W0 | adb -k -w > /dev/null 2>&1');
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
