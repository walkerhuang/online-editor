use strict;

package Proc::vhsm60::Common;
@Proc::vhsm60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vhsm';
    $proc->{name}='vhsm name';
    $proc->{desc}='vhsm description';
    return;
}

package Proc::vhsm60::AIX;
@Proc::vhsm60::AIX::ISA = qw(Proc::vhsm60::Common);

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

package Proc::vhsm60::HPUX;
@Proc::vhsm60::HPUX::ISA = qw(Proc::vhsm60::Common);

package Proc::vhsm60::Linux;
@Proc::vhsm60::Linux::ISA = qw(Proc::vhsm60::Common);

package Proc::vhsm60::SunOS;
@Proc::vhsm60::SunOS::ISA = qw(Proc::vhsm60::Common);

1;
