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

package Proc::vxconfigbackupd61::Common;
@Proc::vxconfigbackupd61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxconfigbackupd';
    $proc->{name}='vxconfigbackupd name';
    $proc->{desc}='vxconfigbackupd description';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_nohup _cmd_vxconfigbackupd > /dev/null 2>&1 < /dev/null &');
    sleep 2;
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    $sys->kill_pids(@$pids);
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

package Proc::vxconfigbackupd61::AIX;
@Proc::vxconfigbackupd61::AIX::ISA = qw(Proc::vxconfigbackupd61::Common);

package Proc::vxconfigbackupd61::HPUX;
@Proc::vxconfigbackupd61::HPUX::ISA = qw(Proc::vxconfigbackupd61::Common);

package Proc::vxconfigbackupd61::Linux;
@Proc::vxconfigbackupd61::Linux::ISA = qw(Proc::vxconfigbackupd61::Common);

package Proc::vxconfigbackupd61::SunOS;
@Proc::vxconfigbackupd61::SunOS::ISA = qw(Proc::vxconfigbackupd61::Common);

1;
