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

package Prod::DMP62::Common;
@Prod::DMP62::Common::ISA = qw(Prod::VM62::Common);

package Prod::DMP62::AIX;
@Prod::DMP62::AIX::ISA = qw(Prod::VM62::AIX);

package Prod::DMP62::HPUX;
@Prod::DMP62::HPUX::ISA = qw(Prod::VM62::HPUX);

package Prod::DMP62::Linux;
@Prod::DMP62::Linux::ISA = qw(Prod::VM62::Linux);

package Prod::DMP62::RHEL7x8664;
@Prod::DMP62::RHEL7x8664::ISA = qw(Prod::VM62::RHEL7x8664);

package Prod::DMP62::OL7x8664;
@Prod::DMP62::OL7x8664::ISA = qw(Prod::VM62::OL7x8664);

package Prod::DMP62::SunOS;
@Prod::DMP62::SunOS::ISA = qw(Prod::VM62::SunOS);

package Prod::DMP62::SolSparc;
@Prod::DMP62::SolSparc::ISA = qw(Prod::VM62::SolSparc);

package Prod::DMP62::Sol11sparc;
@Prod::DMP62::Sol11sparc::ISA = qw(Prod::VM62::Sol11sparc);

package Prod::DMP62::Solx64;
@Prod::DMP62::Solx64::ISA = qw(Prod::VM62::Solx64);

package Prod::DMP62::Sol11x64;
@Prod::DMP62::Sol11x64::ISA = qw(Prod::VM62::Sol11x64);

1;
