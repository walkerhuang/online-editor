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
package Transport::VCSCLI;
use strict;
@Transport::VCSCLI::ISA = qw(Transport);

# To support VCSCLI transportation
sub init_transport {
    my $trans=shift;
    my $haclipath="/opt/VRTSvcs/bin/hacli";
    Obj::reset_value($trans, 'haclipath', $haclipath);
    return 1;
}

# Check hacli connection on system
sub check_sys {
    my ($trans,$sys,$user)=@_;
    my ($haclipath,$localsys,$cmd,$sysname,$rc,$error_no,$error_msg);

    # check ssh
    $haclipath=$trans->{haclipath};
    if (!$haclipath || ! -f $haclipath) {
        $error_no=Transport->EBINARYNOTAVAILABLE;
        $error_msg=Msg::new("VCSCLI binary does not exist on the local system.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    $sysname=$sys->{sys};
    $cmd = "LC_ALL=C LANG=C $haclipath -cmd 'echo' -sys $sysname 2>&1";

    $localsys=EDR::get('localsys');
    $localsys->cmd($cmd);
    $rc=EDR::cmdexit();
    if ($rc) {
        # hacli connection is not configured
        $error_no=Transport->ESERVICENOTAVAILABLE;
        $error_msg=Msg::new("VCSCLI hacli connection is not setup $sys->{sys}.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    return 1;
}

# Setup ssh connection between local system and the remote system
sub setup_sys {
    my ($trans,$sys,$user,$passwd,$timeout)=@_;
    my ($haclipath,$cmd,$sysname,$error_no,$error_msg);

    # Check if the connection is already ready
    return 1 if ($sys->{transport} && $sys->{transport} eq 'VCSCLI');

    # check VCSCLI binary
    $haclipath=$trans->{haclipath};
    if (!$haclipath || !-f $haclipath) {
        $error_no=Transport->EBINARYNOTAVAILABLE;
        $error_msg=Msg::new("VCSCLI binary path is not defined on the local system.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    return 1;
}

sub unsetup_sys {
    my ($trans,$sys)=@_;
    return 1;
}

sub cmd_sys {
    my ($trans,$sys,$cmd)=@_;
    my ($haclipath,$sysname);
    my ($stdout,$stderr,$exitcode);

    $haclipath=$trans->{haclipath};

    $sysname=$sys->{sys};
    $cmd = "$haclipath -cmd '$cmd' -sys $sysname 2>&1";

    ($stdout,$stderr,$exitcode,$cmd)=Sys::run_local_command($cmd);
    return ($stdout,$stderr,$exitcode,$cmd);
}

sub copy_to_sys {
    my ($trans,$sys_src,$file_src,$sys_dest,$file_dest) = @_;
    return 1;
}

1;
