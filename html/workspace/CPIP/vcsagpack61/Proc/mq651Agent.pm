use strict;

package Proc::mq651Agent::Common;
@Proc::mq651Agent::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='WebSphereMQ_Agent';
    $proc->{name}='VCS WebSphereMQ Agent';
    $proc->{desc}='VCS WebSphereMQ Agent';
    $proc->{start_period}=20;
    $proc->{stop_period}=10;
    return;
}


sub start_sys {
    my ($proc,$sys)=@_;
    Msg::log("Got in MQ start");
    my $vcs=$proc->prod('AGPACK61');
    $sys->cmd("$vcs->{bindir}/haagent -start WebSphereMQ -sys $sys->{sys}");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    Msg::log("Got in MQ stop");
    my $vcs=$proc->prod('AGPACK61');
    $sys->cmd("$vcs->{bindir}/haagent -stop WebSphereMQ6 -force -sys $sys->{sys}");
    $sys->cmd("$vcs->{bindir}/haagent -stop WebSphereMQ -force -sys $sys->{sys}");
    return 1;
}

sub check_sys {
	my ($proc,$sys,$state)=@_;
	Msg::log("Got in MQ check");
	my $bMQAgentRunning = isAgentRunning($proc,$sys,"WebSphereMQ");
	my $bMQ6AgentRunning = isAgentRunning($proc,$sys,"WebSphereMQ6");

	if ($state=~/start/m) {
		# When in startup phase,
		# Need to consider only WebSphereMQ agent
		return $bMQAgentRunning;
	} elsif ($state=~/stop/m) {
		# When in stop phase,
		# regard MQ Agent running if WebSphereMQ agent running or WebSphereMQ6 agent running
		if ( $bMQAgentRunning || $bMQ6AgentRunning ) {
			return 1;
		}
	}
	return 0;
}  

sub isAgentRunning {
	my ($proc,$sys,$sAgentName)=@_;
	my $vcs=$proc->prod('AGPACK61');
	my $rtn = $sys->cmd("$vcs->{bindir}/haagent -display $sAgentName | grep Running | awk '{print \$3}'");
	Msg::log("haagent display check output $rtn");
	if ($rtn) {
		if ($rtn =~ /Yes/m) {
			Msg::log("Agent $sAgentName is running.");
			return 1;
		} else {
			Msg::log("Agent $sAgentName is not running.");
			return 0;
		}
	}

	return 0;
}

package Proc::mq651Agent::AIX;
@Proc::mq651Agent::AIX::ISA = qw(Proc::mq651Agent::Common);


package Proc::mq651Agent::HPUX;
@Proc::mq651Agent::HPUX::ISA = qw(Proc::mq651Agent::Common);

package Proc::mq651Agent::Linux;
@Proc::mq651Agent::Linux::ISA = qw(Proc::mq651Agent::Common);

package Proc::mq651Agent::SunOS;
@Proc::mq651Agent::SunOS::ISA = qw(Proc::mq651Agent::Common);

1;
