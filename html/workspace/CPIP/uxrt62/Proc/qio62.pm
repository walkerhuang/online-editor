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

package Proc::qio62::Common;
@Proc::qio62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='qio';
    $proc->{name}='qio name';
    $proc->{desc}='qio description';
    return;
}

package Proc::qio62::AIX;
@Proc::qio62::AIX::ISA = qw(Proc::qio62::Common);

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

package Proc::qio62::HPUX;
@Proc::qio62::HPUX::ISA = qw(Proc::qio62::Common);

package Proc::qio62::Linux;
@Proc::qio62::Linux::ISA = qw(Proc::qio62::Common);

package Proc::qio62::SunOS;
@Proc::qio62::SunOS::ISA = qw(Proc::qio62::Common);

1;
