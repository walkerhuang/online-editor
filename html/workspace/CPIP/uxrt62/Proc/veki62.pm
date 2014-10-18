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

package Proc::veki62::Common;
@Proc::veki62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='veki';
    $proc->{name}='veki name';
    $proc->{desc}='veki description';
    $proc->{fatal}=1;
    return;
}

package Proc::veki62::AIX;
@Proc::veki62::AIX::ISA = qw(Proc::veki62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{driverfile}='/usr/lib/drivers/veki.ext';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/vekiextadm load');
    $sys->cmd('/etc/methods/vekiextadm config');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/vekiextadm unconfig');
    $sys->cmd('/etc/methods/vekiextadm unload');
    sleep 3;
    if($proc->check_sys($sys)){
        Msg::log("Unload Driver on $sys->{sys}");
        $sys->padv->unload_driver_sys($sys,$proc->{driverfile});
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $mod;
    $mod=$sys->padv->driver_sys($sys, $proc->{driverfile});
    if ($mod eq '') {
        return 0;
    }
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc} on $sys->{sys}:\n\n");
    $sys->cmd('_cmd_ps -aef');
    return;
}

package Proc::veki62::HPUX;
@Proc::veki62::HPUX::ISA = qw(Proc::veki62::Common);

package Proc::veki62::Linux;
@Proc::veki62::Linux::ISA = qw(Proc::veki62::Common);

package Proc::veki62::RHEL7x8664;
@Proc::veki62::RHEL7x8664::ISA = qw(Proc::veki62::Linux);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/veki start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/veki stop');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $mod=$sys->padv->driver_sys($sys, 'veki');
    if ($mod eq '') {
        return 0;
    }
    return 1;
}

package Proc::veki62::SunOS;
@Proc::veki62::SunOS::ISA = qw(Proc::veki62::Common);

1;
