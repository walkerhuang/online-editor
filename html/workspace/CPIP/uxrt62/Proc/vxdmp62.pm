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

package Proc::vxdmp62::Common;
@Proc::vxdmp62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxdmp';
    $proc->{name}='vxdmp name';
    $proc->{desc}='vxdmp description';
    $proc->{fatal}=1;
    return;
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

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxdmp62::AIX;
@Proc::vxdmp62::AIX::ISA = qw(Proc::vxdmp62::Common);

package Proc::vxdmp62::HPUX;
@Proc::vxdmp62::HPUX::ISA = qw(Proc::vxdmp62::Common);

package Proc::vxdmp62::Linux;
@Proc::vxdmp62::Linux::ISA = qw(Proc::vxdmp62::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

package Proc::vxdmp62::SunOS;
@Proc::vxdmp62::SunOS::ISA = qw(Proc::vxdmp62::Common);

# load to kernel
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

package Proc::vxdmp62::Sol11sparc;
@Proc::vxdmp62::Sol11sparc::ISA = qw(Proc::vxdmp62::SunOS);

# load to kernel
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
