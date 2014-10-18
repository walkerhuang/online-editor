use strict;

package Proc::VMwareDisksAgent::Common;
@Proc::VMwareDisksAgent::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='Veritas High Availability Agent for VMware disk management by Symantec';
    $proc->{name}='Veritas High Availability Agent for VMware disk management by Symantec';
    $proc->{desc}='Veritas High Availability Agent for VMware disk management by Symantec';
    $proc->{start_period}=20;
    $proc->{stop_period}=10;
    return;
}


sub start_sys {
    my ($proc,$sys)=@_;
    Msg::log("Got in VMwareDisksAgent start");
    my $vcs=$proc->prod('AGPACK61');
    $sys->cmd("$vcs->{bindir}/haagent -start VMwareDisks -sys $sys->{sys}");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    Msg::log("Got in VMwareDisksAgent stop");
    my $vcs=$proc->prod('AGPACK61');
    $sys->cmd("$vcs->{bindir}/haagent -stop VMwareDisks -force -sys $sys->{sys}");
    return 1;
}

sub check_sys {
	my ($proc,$sys,$state)=@_;
	Msg::log("Got in VMwareDisksAgent check");
	my $vcs=$proc->prod('AGPACK61');
	my $rtn = $sys->cmd("$vcs->{bindir}/haagent -display VMwareDisks | grep Running | awk '{print \$3}'");
	Msg::log("VMwareDisksAgent check $rtn");
	if ($rtn) {
		if ($rtn =~ /Yes/m) {
			Msg::log("VMwareDisksAgent Agent already running.");
			return 1;
		} else {
			Msg::log("VMwareDisksAgent Agent not running.");
			return 0;
		}
        }
	return 0;
}  
package Proc::VMwareDisksAgent::AIX;
@Proc::VMwareDisksAgent::AIX::ISA = qw(Proc::VMwareDisksAgent::Common);


package Proc::VMwareDisksAgent::HPUX;
@Proc::VMwareDisksAgent::HPUX::ISA = qw(Proc::VMwareDisksAgent::Common);

package Proc::VMwareDisksAgent::Linux;
@Proc::VMwareDisksAgent::Linux::ISA = qw(Proc::VMwareDisksAgent::Common);

package Proc::VMwareDisksAgent::SunOS;
@Proc::VMwareDisksAgent::SunOS::ISA = qw(Proc::VMwareDisksAgent::Common);

1;
