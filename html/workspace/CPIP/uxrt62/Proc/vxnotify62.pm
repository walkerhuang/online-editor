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

package Proc::vxnotify62::Common;
@Proc::vxnotify62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxnotify';
    $proc->{name}='vxnotify name';
    $proc->{desc}='vxnotify description';
    return;
}

sub stop_sys {
    my ($proc,$sys)=@_;

    #Check sfmh-discovery status before stopping vxnotify
    my $cpic=Obj::cpic();
    my $procobj=$sys->proc('sfmhdiscovery61');
    if($procobj && $procobj->check_sys($sys,"stop")){
        Msg::log("Stopping sfmh-discovery before vxnotify ");
        $procobj->stop_sys($sys);
        sleep 1;
     } else {
        Msg::log("sfmh-discovery is not running when stopping vxnotify");
     }

    my $pids=$sys->proc_pids($proc->{proc});
    $sys->kill_pids(@$pids);
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $pids=$sys->proc_pids($proc->{proc});
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

package Proc::vxnotify62::AIX;
@Proc::vxnotify62::AIX::ISA = qw(Proc::vxnotify62::Common);

package Proc::vxnotify62::HPUX;
@Proc::vxnotify62::HPUX::ISA = qw(Proc::vxnotify62::Common);

package Proc::vxnotify62::Linux;
@Proc::vxnotify62::Linux::ISA = qw(Proc::vxnotify62::Common);

package Proc::vxnotify62::SunOS;
@Proc::vxnotify62::SunOS::ISA = qw(Proc::vxnotify62::Common);

1;
