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

package Proc::vxfs61::Common;
@Proc::vxfs61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxfs';
    $proc->{name}='vxfs name';
    $proc->{desc}='vxfs description';
    $proc->{fatal}=1;
    return;
}

package Proc::vxfs61::AIX;
@Proc::vxfs61::AIX::ISA = qw(Proc::vxfs61::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} load");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm $proc->{proc} unload");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxcfg $proc->{proc} status");
    return !EDR::cmdexit();
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxfs61::HPUX;
@Proc::vxfs61::HPUX::ISA = qw(Proc::vxfs61::Common);

package Proc::vxfs61::Linux;
@Proc::vxfs61::Linux::ISA = qw(Proc::vxfs61::Common);

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

package Proc::vxfs61::SunOS;
@Proc::vxfs61::SunOS::ISA = qw(Proc::vxfs61::Common);

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

1;
