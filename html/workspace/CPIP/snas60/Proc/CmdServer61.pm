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

package Proc::CmdServer61::Common;
@Proc::CmdServer61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='CmdServer';
    $proc->{name}='Symantec Command Server';
    $proc->{desc}='CmdServer description';
    $proc->{controlfile}='/opt/VRTSvcs/bin/CmdServer';
    $proc->{stop_period}=10;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile}");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} -stop");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('CmdServer');
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('CmdServer');
    # kill CmdServer
    $sys->kill_pids(@$pids);
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check start failures in CmdServer-log_A.log:\n");
    $sys->cmd('_cmd_tail -10 /var/VRTSvcs/log/CmdServer-log_A.log 2>/dev/null');
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check stop failures in CmdServer-log_A.log:\n");
    $sys->cmd('_cmd_tail -10 /var/VRTSvcs/log/CmdServer-log_A.log 2>/dev/null');
    return 1;
}

package Proc::CmdServer61::AIX;
@Proc::CmdServer61::AIX::ISA = qw(Proc::CmdServer61::Common);

package Proc::CmdServer61::HPUX;
@Proc::CmdServer61::HPUX::ISA = qw(Proc::CmdServer61::Common);

package Proc::CmdServer61::Linux;
@Proc::CmdServer61::Linux::ISA = qw(Proc::CmdServer61::Common);

package Proc::CmdServer61::SunOS;
@Proc::CmdServer61::SunOS::ISA = qw(Proc::CmdServer61::Common);

1;
