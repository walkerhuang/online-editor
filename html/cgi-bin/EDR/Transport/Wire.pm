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
package Transport::Wire;
use strict;
@Transport::Wire::ISA = qw(Transport);

# To Support NBU VTS

sub check_sys {
    my ($trans,$sys)=@_;
    return 0;
}

sub setup_sys {
    my ($trans,$sys)=@_;
    return 1;
}

sub unsetup_sys {
    my ($trans,$sys)=@_;
    return 1;
}

sub cmd_sys {
    my ($trans,$sys)=@_;
    return 1;
}

sub copy_to_sys {
    my ($trans,$src_sys,$src_file,$dest_sys,$dest_file)=@_;
    return 1;
}

1;
