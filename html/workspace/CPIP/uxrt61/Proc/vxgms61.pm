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

package Proc::vxgms61::Common;
@Proc::vxgms61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxgms';
    $proc->{name}='vxgms name';
    $proc->{desc}='vxgms description';
    $proc->{fatal}=1;
    return;
}

package Proc::vxgms61::AIX;
@Proc::vxgms61::AIX::ISA = qw(Proc::vxgms61::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/gmskextadm load');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/gmskextadm unload') if($sys->exists('/etc/methods/gmskextadm'));
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    return 0 unless $sys->exists('/etc/methods/gmskextadm');
    my $gmsconf = $sys->cmd("/etc/methods/gmskextadm status | _cmd_grep 'not loaded'");
    return 1 if ($gmsconf eq '');
    return 0;
}

package Proc::vxgms61::HPUX;
@Proc::vxgms61::HPUX::ISA = qw(Proc::vxgms61::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/vxgms start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/vxgms stop');
    $sys->cmd('_cmd_kcmodule vxgms=unused');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('vxgmsd');
    return 1 if ($#$pids>=0);
    return 0;
}

package Proc::vxgms61::Linux;
@Proc::vxgms61::Linux::ISA = qw(Proc::vxgms61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{start_period}=20;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxgms start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxgms stop');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->padv->driver_sys($sys,$proc->{proc});
    return 1 if ($rtn ne '');
    return 0;
}

package Proc::vxgms61::SunOS;
@Proc::vxgms61::SunOS::ISA = qw(Proc::vxgms61::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_adddrv vxgms');
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->padv->driver_sys($sys,$proc->{proc});
    return 1 if ($rtn ne '');
    return 0;
    # TODO: start/stop/stat ?
}

1;