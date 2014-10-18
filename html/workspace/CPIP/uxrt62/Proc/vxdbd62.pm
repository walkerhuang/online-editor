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

package Proc::vxdbd62::Common;
@Proc::vxdbd62::Common::ISA = qw(Proc);

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
    $proc->{internal_configfile}='/opt/VRTSdbed/bin/internal/vxdbd_config';
    return;
}

sub is_enabled_sys {
    my ($proc,$sys)=@_;
    my ($status);

    $status = $sys->cmd("$proc->{internal_configfile} status 2>/dev/null");
    if ($status =~ /enabled/m) {
        return 1;
    } else {
        return 0;
    }
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

package Proc::vxdbd62::AIX;
@Proc::vxdbd62::AIX::ISA = qw(Proc::vxdbd62::Common);

package Proc::vxdbd62::HPUX;
@Proc::vxdbd62::HPUX::ISA = qw(Proc::vxdbd62::Common);

package Proc::vxdbd62::Linux;
@Proc::vxdbd62::Linux::ISA = qw(Proc::vxdbd62::Common);

package Proc::vxdbd62::SunOS;
@Proc::vxdbd62::SunOS::ISA = qw(Proc::vxdbd62::Common);

1;
