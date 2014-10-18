use strict;

package Proc::qio60::Common;
@Proc::qio60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='qio';
    $proc->{name}='qio name';
    $proc->{desc}='qio description';
    return;
}

package Proc::qio60::AIX;
@Proc::qio60::AIX::ISA = qw(Proc::qio60::Common);

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

package Proc::qio60::HPUX;
@Proc::qio60::HPUX::ISA = qw(Proc::qio60::Common);

package Proc::qio60::Linux;
@Proc::qio60::Linux::ISA = qw(Proc::qio60::Common);

package Proc::qio60::SunOS;
@Proc::qio60::SunOS::ISA = qw(Proc::qio60::Common);

1;
