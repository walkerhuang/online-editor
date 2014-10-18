use strict;

package Proc::qlog60::Common;
@Proc::qlog60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='qlog';
    $proc->{name}='qlog name';
    $proc->{desc}='qlog description';
    return;
}

package Proc::qlog60::AIX;
@Proc::qlog60::AIX::ISA = qw(Proc::qlog60::Common);

package Proc::qlog60::HPUX;
@Proc::qlog60::HPUX::ISA = qw(Proc::qlog60::Common);

package Proc::qlog60::Linux;
@Proc::qlog60::Linux::ISA = qw(Proc::qlog60::Common);

package Proc::qlog60::SunOS;
@Proc::qlog60::SunOS::ISA = qw(Proc::qlog60::Common);

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
