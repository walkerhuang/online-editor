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

package Proc::vxspec61::Common;
@Proc::vxspec61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxspec';
    $proc->{name}='vxspec name';
    $proc->{desc}='vxspec description';
    $proc->{fatal}=1;
    return;
}

# unload from kernel
# 1 on success, 0 on failure
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    $proc->driver_force_unload_sys($sys) if($proc->check_sys($sys));
    return 1;
}

sub driver_force_unload_sys {
    my ($proc,$sys)=@_;
    #$sys->cmd("_cmd_rmdrv $proc->{proc}");
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::vxspec61::AIX;
@Proc::vxspec61::AIX::ISA = qw(Proc::vxspec61::Common);

package Proc::vxspec61::HPUX;
@Proc::vxspec61::HPUX::ISA = qw(Proc::vxspec61::Common);

package Proc::vxspec61::Linux;
@Proc::vxspec61::Linux::ISA = qw(Proc::vxspec61::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

package Proc::vxspec61::SunOS;
@Proc::vxspec61::SunOS::ISA = qw(Proc::vxspec61::Common);

# Due to e2960455, we use rem_drv/add_drv to unload/load driver
# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_adddrv $proc->{proc} 2>/dev/null");
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    $sys->cmd("_cmd_rmdrv $proc->{proc}");
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check start failures in /var/adm/messages:\n");
    $sys->cmd('_cmd_tail -10 /var/adm/messages 2>/dev/null');
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## Check stop failures in /var/adm/messages:\n");
    $sys->cmd('_cmd_tail -10 /var/adm/messages 2>/dev/null');
    return 1;
}

package Proc::vxspec61::Sol11sparc;
@Proc::vxspec61::Sol11sparc::ISA = qw(Proc::vxspec61::SunOS);

sub start_sys {
    my ($proc,$sys)=@_;
    $proc->SUPER::start_sys($sys);
    $sys->padv->add_etc_system_entry_sys($sys,[$proc->{proc}]);
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $proc->SUPER::stop_sys($sys);
    $sys->padv->rm_etc_system_entry_sys($sys,[$proc->{proc}]);
    return 1;
}

1;
