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

package Proc::vxcpserv60::Common;
@Proc::vxcpserv60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxcpserv';
    $proc->{name}='vxcpserv';
    $proc->{desc}='vxcpserv description';
    $proc->{cpsadm}='/opt/VRTS/bin/cpsadm';
    $proc->{stop_period}=10;
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids('bin/vxcpserv');
    if ($#$pids == -1) {
        Msg::log("vxcpserv is not running on $sys->{sys}.");
        return 0;
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    return 1;
}

sub stop_sys {
    my ($proc,$sys) = @_;
    my ($vcs,$had,$sysname);
    $had=$proc->proc('had60');
    $vcs=$proc->prod('VCS60');
    $sysname = $sys->{vcs_sysname};
    $sysname ||= $vcs->get_vcs_sysname_sys($sys);
    if ($had->check_sys($sys, 'start')) {
        $sys->cmd("$vcs->{bindir}/hagrp -offline CPSSG -sys $sysname");
    } else {
        $sys->cmd("$proc->{cpsadm} -s $sysname -a halt_cps");
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids,$proc_name);
    $proc_name='bin/vxcpserv';
    $pids=$sys->proc_pids($proc_name);
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::vxcpserv60::AIX;
@Proc::vxcpserv60::AIX::ISA = qw(Proc::vxcpserv60::Common);

package Proc::vxcpserv60::HPUX;
@Proc::vxcpserv60::HPUX::ISA = qw(Proc::vxcpserv60::Common);

package Proc::vxcpserv60::Linux;
@Proc::vxcpserv60::Linux::ISA = qw(Proc::vxcpserv60::Common);

package Proc::vxcpserv60::SunOS;
@Proc::vxcpserv60::SunOS::ISA = qw(Proc::vxcpserv60::Common);

1;
