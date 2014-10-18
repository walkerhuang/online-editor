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

package Proc::vxportal60::Common;
@Proc::vxportal60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxportal';
    $proc->{name}='vxportal name';
    $proc->{desc}='vxportal description';
    $proc->{fatal}=1;
    return;
}

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::vxportal60::AIX;
@Proc::vxportal60::AIX::ISA = qw(Proc::vxportal60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{proc}='portal';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} load 2> /dev/null");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} unload 2> /dev/null");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxcfg $proc->{proc} status 2> /dev/null");
    return !EDR::cmdexit();
}

package Proc::vxportal60::HPUX;
@Proc::vxportal60::HPUX::ISA = qw(Proc::vxportal60::Common);

package Proc::vxportal60::Linux;
@Proc::vxportal60::Linux::ISA = qw(Proc::vxportal60::Common);

package Proc::vxportal60::SunOS;
@Proc::vxportal60::SunOS::ISA = qw(Proc::vxportal60::Common);

package Proc::vxportal60::Sol11sparc;
@Proc::vxportal60::Sol11sparc::ISA = qw(Proc::vxportal60::SunOS);

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

package Proc::vxportal60::Sol11x64;
@Proc::vxportal60::Sol11x64::ISA = qw(Proc::vxportal60::Sol11sparc);

1;
