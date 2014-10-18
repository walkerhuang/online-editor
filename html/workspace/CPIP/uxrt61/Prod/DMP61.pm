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

package Prod::DMP61::Common;
@Prod::DMP61::Common::ISA = qw(Prod::VM61::Common);

package Prod::DMP61::AIX;
@Prod::DMP61::AIX::ISA = qw(Prod::VM61::AIX);

package Prod::DMP61::HPUX;
@Prod::DMP61::HPUX::ISA = qw(Prod::VM61::HPUX);

package Prod::DMP61::Linux;
@Prod::DMP61::Linux::ISA = qw(Prod::VM61::Linux);

package Prod::DMP61::SunOS;
@Prod::DMP61::SunOS::ISA = qw(Prod::VM61::SunOS);

package Prod::DMP61::SolSparc;
@Prod::DMP61::SolSparc::ISA = qw(Prod::VM61::SolSparc);

package Prod::DMP61::Sol11sparc;
@Prod::DMP61::Sol11sparc::ISA = qw(Prod::VM61::Sol11sparc);

package Prod::DMP61::Solx64;
@Prod::DMP61::Solx64::ISA = qw(Prod::VM61::Solx64);

package Prod::DMP61::Sol11x64;
@Prod::DMP61::Sol11x64::ISA = qw(Prod::VM61::Sol11x64);

1;
