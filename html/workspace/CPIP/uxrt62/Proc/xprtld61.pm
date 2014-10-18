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

package Proc::xprtld61::Common;
@Proc::xprtld61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='xprtld';
    $proc->{name}='xprtld';
    $proc->{desc}='xprtld description';
    $proc->{xprtldctrl}='/opt/VRTSsfmh/adm/xprtldctrl';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids('/opt/VRTSsfmh/bin/xprtld');
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    my ($pids);
    $pids = $sys->proc_pids('/opt/VRTSsfmh/bin/xprtld');
    unless ((defined $pids) && @$pids) {
        $sys->cmd("$proc->{xprtldctrl} start 2> /dev/null");
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists("$proc->{xprtldctrl}")) {
        $sys->cmd("$proc->{xprtldctrl} stop");
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids);
    $pids=$sys->proc_pids('/opt/VRTSsfmh/bin/xprtld');
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::xprtld61::AIX;
@Proc::xprtld61::AIX::ISA = qw(Proc::xprtld61::Common);

package Proc::xprtld61::HPUX;
@Proc::xprtld61::HPUX::ISA = qw(Proc::xprtld61::Common);

package Proc::xprtld61::Linux;
@Proc::xprtld61::Linux::ISA = qw(Proc::xprtld61::Common);

package Proc::xprtld61::SunOS;
@Proc::xprtld61::SunOS::ISA = qw(Proc::xprtld61::Common);

1;
