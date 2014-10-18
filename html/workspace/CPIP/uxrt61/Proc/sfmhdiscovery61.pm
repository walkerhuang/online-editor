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

package Proc::sfmhdiscovery61::Common;
@Proc::sfmhdiscovery61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='sfmh-discovery';
    $proc->{name}='sfmh-discovery name';
    $proc->{desc}='sfmh-discovery description';
    $proc->{controlfile}='/opt/VRTSsfmh/adm/vxvmdiscovery-ctrl.sh';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} stop") if($sys->exists($proc->{controlfile}));
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids("/opt/VRTSsfmh/bin/$proc->{proc}");
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids("/opt/VRTSsfmh/bin/$proc->{proc}");
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::sfmhdiscovery61::AIX;
@Proc::sfmhdiscovery61::AIX::ISA = qw(Proc::sfmhdiscovery61::Common);

package Proc::sfmhdiscovery61::HPUX;
@Proc::sfmhdiscovery61::HPUX::ISA = qw(Proc::sfmhdiscovery61::Common);

package Proc::sfmhdiscovery61::Linux;
@Proc::sfmhdiscovery61::Linux::ISA = qw(Proc::sfmhdiscovery61::Common);

package Proc::sfmhdiscovery61::SunOS;
@Proc::sfmhdiscovery61::SunOS::ISA = qw(Proc::sfmhdiscovery61::Common);

1;
