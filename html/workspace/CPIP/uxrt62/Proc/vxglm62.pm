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

package Proc::vxglm62::Common;
@Proc::vxglm62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxglm';
    $proc->{name}='vxglm name';
    $proc->{desc}='vxglm description';
    $proc->{fatal}=1;
    return;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## gabconfig -a output:\n\n");
    $sys->cmd('_cmd_gabconfig -a 2> /dev/null');
    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxglm62::AIX;
@Proc::vxglm62::AIX::ISA = qw(Proc::vxglm62::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/glmkextadm load 2> /dev/null');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/methods/glmkextadm unload 2> /dev/null') if($sys->exists('/etc/methods/glmkextadm'));
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    return 0 unless ($sys->exists('/etc/methods/glmkextadm'));
    my $glmconf = $sys->cmd("/etc/methods/glmkextadm status | _cmd_grep 'not loaded'");
    return 1 if ($glmconf eq '');
    return 0;
}

package Proc::vxglm62::HPUX;
@Proc::vxglm62::HPUX::ISA = qw(Proc::vxglm62::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('_cmd_kcmodule -B vxglm=loaded');
    $sys->cmd('/sbin/init.d/vxglm start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/init.d/vxglm stop');
    $sys->cmd('_cmd_kcmodule vxglm=unused');
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids('vxglmd');
    return 1 if ($#$pids>=0);
    return 0;
}

package Proc::vxglm62::Linux;
@Proc::vxglm62::Linux::ISA = qw(Proc::vxglm62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{start_period}=10;
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/etc/init.d/vxglm start');
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("export PATH=/bin:/sbin:\$PATH; /etc/init.d/vxglm stop");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->padv->driver_sys($sys,$proc->{proc});
    return 1 if($rtn ne '');
    return 0;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -aef');
    Msg::log("## modinfo output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_lsmod');
    Msg::log("## gabconfig -a output:\n\n");
    $sys->cmd('_cmd_gabconfig -a 2> /dev/null');
    return;
}

package Proc::vxglm62::SunOS;
@Proc::vxglm62::SunOS::ISA = qw(Proc::vxglm62::Common);

sub start_sys {
    my ($proc,$sys)=@_;
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
}

package Proc::vxglm62::Sol11sparc;
@Proc::vxglm62::Sol11sparc::ISA = qw(Proc::vxglm62::SunOS);

sub start_sys {
    my ($proc,$sys)=@_;
    my ($mn,$driver);
    $driver=$proc->{proc};
    $mn=$sys->padv->driver_sys($sys, $driver);
    if ($mn eq '') {
        $sys->cmd("_cmd_adddrv -f -m '* 0640 root sys' $driver 2>/dev/null; _cmd_modload -p drv/$driver 2>/dev/null");
    }
    return 1;
}
1;
