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

package Proc::vxcafs62::Common;
@Proc::vxcafs62::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxcafs';
    $proc->{name}='vxcafs name';
    $proc->{desc}='vxcafs description';
    return;
}


package Proc::vxcafs62::Linux;
@Proc::vxcafs62::Linux::ISA = qw(Proc::vxcafs62::Common);
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
package Proc::vxcafs62::AIX;
@Proc::vxcafs62::AIX::ISA = qw(Proc::vxcafs62::Common);
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm cafs load");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_vxkextadm cafs unload");
    return 1;
}

sub check_sys {
    my ($proc,$sys)=@_;
    my $ret = $sys->cmd("_cmd_vxcfg cafs status 2>&1");
    return 0 if ($ret =~ /USAGE:/);
    return !EDR::cmdexit();
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::vxcafs62::HPUX;
@Proc::vxcafs62::HPUX::ISA = qw(Proc::vxcafs62::Common);

package Proc::vxcafs62::SunOS;
@Proc::vxcafs62::SunOS::ISA = qw(Proc::vxcafs62::Common);

sub init_plat {
    my $proc=shift;
    $proc->{reboot_donotstart}=1;
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
1;
