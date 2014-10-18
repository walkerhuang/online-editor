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

package Proc::vxesd61::Common;
@Proc::vxesd61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxesd';
    $proc->{name}='vxesd name';
    $proc->{desc}='vxesd description';
    $proc->{stop_sleep}=10;
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    # Remove the vxesd lock file if present, so vxesd can start
    if($sys->exists('/etc/vx/.vxesd.lock')) {
         $sys->cmd('_cmd_rmr /etc/vx/.vxesd.lock');
         $sys->cmd('_cmd_touch /etc/vx/.vxesd.lock');
    }
    $sys->cmd('_cmd_vxddladm start eventsource');
    $sys->cmd('_cmd_vxrecover -sn > /dev/null 2>&1');
    $sys->cmd('_cmd_vxrecover -b -o iosize=64k > /dev/null 2>&1');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($pids,$time);
    $sys->cmd('_cmd_vxddladm stop eventsource 2>/dev/null');
    $time=0;
    while ($time <= 60) {
        $pids = $sys->proc_pids("sbin/$proc->{proc}");
        last if ($#$pids < 0);
        sleep 5;
        $time += 5;
    }
    if ($#$pids >= 0) {
         Msg::log("stop failed, try to kill $proc->{proc} ...");
         $sys->kill_pids(@$pids);
    }
    $sys->cmd('_cmd_rmr /etc/vx/vxesd 2>/dev/null');
    $sys->cmd('_cmd_rmr /etc/vx/.vxesd.lock 2>/dev/null');

    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids("sbin/$proc->{proc}");
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

package Proc::vxesd61::AIX;
@Proc::vxesd61::AIX::ISA = qw(Proc::vxesd61::Common);

sub start_sys {
    my ($proc,$sys) = @_;
    # Prevent HBA API calls from esd
    # AIX scsi commands are seralized on ioctls pending at hba
    # level and causes performance issues
    $sys->cmd('_cmd_vxdmpadm settune dmp_monitor_fabric=off 2> /dev/null');
    return $proc->SUPER::start_sys($sys);
}

package Proc::vxesd61::HPUX;
@Proc::vxesd61::HPUX::ISA = qw(Proc::vxesd61::Common);

package Proc::vxesd61::Linux;
@Proc::vxesd61::Linux::ISA = qw(Proc::vxesd61::Common);

package Proc::vxesd61::SunOS;
@Proc::vxesd61::SunOS::ISA = qw(Proc::vxesd61::Common);

sub start_sys {
    my ($proc,$sys) = @_;
    if ($sys->padv->driver_sys($sys,'emcp')) {
        Msg::log('EMC powerpath is configured, prevent OS device attach events from vxesd...');
        $sys->cmd('_cmd_vxdmpadm settune dmp_monitor_osevent=off 2> /dev/null');
    } else {
        $sys->cmd('_cmd_vxdmpadm settune dmp_monitor_osevent=on 2> /dev/null');
    }
    return $proc->SUPER::start_sys($sys);
}

1;
