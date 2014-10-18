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

package Proc::vxio60::Common;
@Proc::vxio60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxio';
    $proc->{name}='vxio name';
    $proc->{desc}='vxio description';
    $proc->{fatal}=1;
    return;
}

sub start_sys {
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    my ($vxspec);
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    if ($proc->check_sys($sys)) {
        # try to unload vxspec and then unload vxio again.
        $vxspec = $sys->proc('vxspec60');
        if ($vxspec && $vxspec->check_sys($sys)) {
            $vxspec->stop_sys($sys);
            sleep 5;
        }
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::vxio60::AIX;
@Proc::vxio60::AIX::ISA = qw(Proc::vxio60::Common);

package Proc::vxio60::HPUX;
@Proc::vxio60::HPUX::ISA = qw(Proc::vxio60::Common);

package Proc::vxio60::Linux;
@Proc::vxio60::Linux::ISA = qw(Proc::vxio60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

package Proc::vxio60::SunOS;
@Proc::vxio60::SunOS::ISA = qw(Proc::vxio60::Common);

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
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

1;
