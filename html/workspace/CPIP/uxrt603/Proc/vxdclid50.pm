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
package Proc::vxdclid50::Common;
@Proc::vxdclid50::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxdclid';
    $proc->{name}='vxdclid';
    $proc->{desc}='vxdclid description';
    $proc->{vxadm}='/usr/sbin/vxadm';
    $proc->{vxdcli}='/etc/init.d/vxdcli.sh';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $pids=$sys->proc_pids("/usr/sbin/$proc->{proc}");
    if ($#$pids == -1) {
        return 0;
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists("$proc->{vxdcli}")) {
        $sys->cmd("$proc->{vxdcli} stop");
    } elsif ($sys->exists("$proc->{vxadm}")) {
        # 5.0MP3
        $sys->cmd("$proc->{vxadm} service stop");
    }
    return 1;
}

sub force_stop_sys {
    my ($proc,$sys) = @_;
    my ($pids);
    $pids=$sys->proc_pids("/usr/sbin/$proc->{proc}");
    $sys->kill_pids(@$pids);
    return 1;
}

package Proc::vxdclid50::AIX;
@Proc::vxdclid50::AIX::ISA = qw(Proc::vxdclid50::Common);

package Proc::vxdclid50::HPUX;
@Proc::vxdclid50::HPUX::ISA = qw(Proc::vxdclid50::Common);

sub init_plat {
    my $proc=shift;
    $proc->{vxdcli}='/sbin/init.d/vxdcli.sh';
    return;
}

package Proc::vxdclid50::Linux;
@Proc::vxdclid50::Linux::ISA = qw(Proc::vxdclid50::Common);

package Proc::vxdclid50::SunOS;
@Proc::vxdclid50::SunOS::ISA = qw(Proc::vxdclid50::Common);

1;
