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

package Proc::vvr62::Common;
@Proc::vvr62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vvr';
    $proc->{name}='vvr name';
    $proc->{desc}='vvr description';
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
    $proc->{multisystemserialstart}=1;
    return;
}

sub start_sys{
    my ($proc, $sys)=@_;
    # Restart vxnetd, vradmind and vxrsyncd
    $sys->cmd(' _cmd_vvrstop > /dev/null 2>&1');
    $sys->cmd(' _cmd_vvrstart > /dev/null 2>&1');
    return 1;
}

sub stop_sys{
    my ($proc, $sys)=@_;
    my ($vxdctl_mode);
    # Stop vxnetd, vradmind and vxrsyncd
    $sys->cmd('_cmd_vvrstop 2> /dev/null');

    # Close the gab ports
    $vxdctl_mode = $sys->cmd("_cmd_vxdctl -c mode 2>/dev/null | _cmd_grep 'mode:'");
    if ($vxdctl_mode =~ /MASTER|SLAVE/m) {
         $sys->cmd('_cmd_vxclustadm stopnode > /dev/null 2>&1');
    }
    return 1;
}

sub check_sys {
    my ($proc, $sys, $state)=@_;
    my ($pids);

    $pids = $sys->proc_pids('in.vxrsyncd');
    if ($#$pids == -1) {
        return 0 if ($state =~ /start/m);
    } else {
        return 1 if ($state =~ /stop/m);
    }
    $pids = $sys->proc_pids('vradmind');
    if ($#$pids == -1) {
        return 0 if ($state =~ /start/m);
    } else {
        return 1 if ($state =~ /stop/m);
    }

    return $proc->check_heartbeat_sys($sys);

}

sub check_heartbeat_sys {
    my ($proc,$sys) = @_;
    my ($count,$line,$heartbeat_port,$procs);
    $heartbeat_port=$sys->cmd('_cmd_vvrport heartbeat');
    return 0 unless ($heartbeat_port);
    $procs = $sys->cmd("_cmd_netstat -an | _cmd_grep -w $heartbeat_port");
    for my $line (split (/\n+/,$procs)) {
        $count++ if ($line=~/^\s*(\S+\s+){3}\S*\.$heartbeat_port\b/mx);
    }
    return 0 if ($count < 2);
    return 1;
}

package Proc::vvr62::AIX;
@Proc::vvr62::AIX::ISA = qw(Proc::vvr62::Common);

package Proc::vvr62::HPUX;
@Proc::vvr62::HPUX::ISA = qw(Proc::vvr62::Common);

package Proc::vvr62::Linux;
@Proc::vvr62::Linux::ISA = qw(Proc::vvr62::Common);

sub check_heartbeat_sys {
    my ($proc,$sys) = @_;
    my ($procs);
    $procs=$sys->proc_pids('vxnetd');
    return 0 if ($#$procs == -1);
    return 1;
}

package Proc::vvr62::SunOS;
@Proc::vvr62::SunOS::ISA = qw(Proc::vvr62::Common);

sub check_heartbeat_sys {
    my ($proc,$sys) = @_;
    my ($count,$line,$heartbeat_port,$procs);
    $heartbeat_port=$sys->cmd('_cmd_vvrport heartbeat');
    return 0 unless ($heartbeat_port);
    $procs = $sys->cmd("_cmd_netstat -an | _cmd_grep -w $heartbeat_port");
    for my $line (split (/\n+/,$procs)) {
        $count++ if ($line=~/^\s*\S*\.$heartbeat_port\b/mx);
    }
    return 0 if ($count < 2);
    return 1;
}

1;
