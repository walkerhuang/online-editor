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

package Proc::vxdbd61::Common;
@Proc::vxdbd61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxdbd';
    $proc->{name}='vxdbd name';
    $proc->{desc}='vxdbd description';
    $proc->{start_period}=120;
    $proc->{stop_period}=120;
    $proc->{controlfile}='/opt/VRTS/bin/vxdbdctrl';
    $proc->{prev_controlfile1}='/opt/VRTSdbed/common/bin/vxdbdctrl';
    $proc->{prev_controlfile2}='/opt/VRTSdbcom/bin/vxdbdctrl';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if($sys->exists("$proc->{controlfile}")) {
        $sys->cmd("$proc->{controlfile} stop");
    }
    if ($sys->exists("$proc->{prev_controlfile1}")) {
        # fix for e2407762
        # stop vxdbd using the old control file when we are upgrading
        $sys->cmd("$proc->{prev_controlfile1} stop");
    } elsif ($sys->exists("$proc->{prev_controlfile2}")) {
        # stop vxdbd using the old control file when we are upgrading
        $sys->cmd("$proc->{prev_controlfile2} stop");
    }
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

package Proc::vxdbd61::AIX;
@Proc::vxdbd61::AIX::ISA = qw(Proc::vxdbd61::Common);

package Proc::vxdbd61::HPUX;
@Proc::vxdbd61::HPUX::ISA = qw(Proc::vxdbd61::Common);

package Proc::vxdbd61::Linux;
@Proc::vxdbd61::Linux::ISA = qw(Proc::vxdbd61::Common);

package Proc::vxdbd61::SunOS;
@Proc::vxdbd61::SunOS::ISA = qw(Proc::vxdbd61::Common);

1;
