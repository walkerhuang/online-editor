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

package Proc::svsweb61::Common;
@Proc::svsweb61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='svsweb';
    $proc->{name}='svsweb name';
    $proc->{desc}='svsweb description';
    $proc->{start_period}=60;
    $proc->{stop_period}=10;
    return;
}

sub enable_sys {
    my ($proc,$sys) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    return 1;
}

sub disable_sys {
    my ($proc,$sys) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $rtn;
    if ($sys->exists($proc->{controlfile})) {
        $rtn=$sys->cmd("$proc->{controlfile} status 2>/dev/null");
        if ($rtn=~ / is running/m) {
            Msg::log("$proc->{proc} is running on $sys->{sys}");
            return 1;
        } elsif ($rtn =~ / stopped/m) {
            Msg::log("$proc->{proc} is stopped on $sys->{sys}");
            return 0;
        }
    }
    return 0;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} stop");
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::svsweb61::AIX;
@Proc::svsweb61::AIX::ISA = qw(Proc::svsweb61::Common);

package Proc::svsweb61::HPUX;
@Proc::svsweb61::HPUX::ISA = qw(Proc::svsweb61::Common);

package Proc::svsweb61::Linux;
@Proc::svsweb61::Linux::ISA = qw(Proc::svsweb61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/opt/VRTSsvs/bin/svsweb';
    return;
}

package Proc::svsweb61::SunOS;
@Proc::svsweb61::SunOS::ISA = qw(Proc::svsweb61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/opt/VRTSsvs/bin/svsweb';
    return;
}

1;
