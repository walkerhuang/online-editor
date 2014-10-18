#
# $Copyright: Copyright (c) 2014 Symantec Corporation.
# All rights reserved.
#
# THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
# SYMANTEC CORPORATION.  USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
# WITHOUT THE PRIOR EXPRESS WRITTEN PERMISSION OF SYMANTEC CORPORATION.
#
# The Licensed Software and Documentation are deemed to be commercial
# computer software as defined in FAR 12.212 and subject to restricted
# rights as defined in FAR Section 52.227-19 "Commercial Computer
# Software - Restricted Rights" and DFARS 227.7202, "Rights in
# Commercial Computer Software or Commercial Computer Software
# Documentation", as applicable, and any successor regulations. Any use,
# modification, reproduction release, performance, display or disclosure
# of the Licensed Software and Documentation by the U.S. Government
# shall be solely in accordance with the terms of this Agreement.  $
#
use strict;

package Proc::vxpal50::Common;
@Proc::vxpal50::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxpal';
    $proc->{name}='vxpal';
    $proc->{desc}='vxpal description';
    $proc->{start_period}=60;
    $proc->{stop_period}=10;
    $proc->{vxpal_bin_dir}='/opt/VRTSobc/pal33/bin';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my $agent;
    for my $agent (qw(gridnode actionagent StorageAgent DBEDAgent VAILAgent)) {
        if ($proc->status_agent_sys($sys,$agent)){
            $proc->stop_agent_sys($sys,$agent);
        }
    }
    my $pids=$sys->proc_pids($proc->{proc});
    $sys->kill_pids(@$pids);
    return 1;
}


sub status_agent_sys {
   my ($proc,$sys,$agent) = @_;
   my $stdout = $sys->cmd("$proc->{vxpal_bin_dir}/vxpalctrl -a $agent -c status");
   if( 0 != EDR::cmdexit()) {
       Msg::log('Bad exit code');
   }
   return 0 if ($stdout =~ m/NOT\s+RUNNING/i);
   return 1 if ($stdout =~ m/(RUNNING|STARTING|UNKNOWN)/i);
   # assume stopped.
   Msg::log('Indeterminate status');
   return 0;
}

sub stop_agent_sys {
    my ($proc,$sys,$agent) = @_;
    Msg::log("Stopping $agent on $sys->{sys}");
    $sys->cmd("$proc->{vxpal_bin_dir}/vxpalctrl -a $agent -c stop");
    return 1;
}

package Proc::vxpal50::AIX;
@Proc::vxpal50::AIX::ISA = qw(Proc::vxpal50::Common);

package Proc::vxpal50::HPUX;
@Proc::vxpal50::HPUX::ISA = qw(Proc::vxpal50::Common);

package Proc::vxpal50::Linux;
@Proc::vxpal50::Linux::ISA = qw(Proc::vxpal50::Common);

package Proc::vxpal50::SunOS;
@Proc::vxpal50::SunOS::ISA = qw(Proc::vxpal50::Common);

1;
