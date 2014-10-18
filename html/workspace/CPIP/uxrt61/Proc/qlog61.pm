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

package Proc::qlog61::Common;
@Proc::qlog61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='qlog';
    $proc->{name}='qlog name';
    $proc->{desc}='qlog description';
    return;
}

package Proc::qlog61::AIX;
@Proc::qlog61::AIX::ISA = qw(Proc::qlog61::Common);

package Proc::qlog61::HPUX;
@Proc::qlog61::HPUX::ISA = qw(Proc::qlog61::Common);

package Proc::qlog61::Linux;
@Proc::qlog61::Linux::ISA = qw(Proc::qlog61::Common);

package Proc::qlog61::SunOS;
@Proc::qlog61::SunOS::ISA = qw(Proc::qlog61::Common);

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
