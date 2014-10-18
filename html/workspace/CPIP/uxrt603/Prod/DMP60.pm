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

package Prod::DMP60::Common;
@Prod::DMP60::Common::ISA = qw(Prod::VM60::Common);

package Prod::DMP60::AIX;
@Prod::DMP60::AIX::ISA = qw(Prod::VM60::AIX);

package Prod::DMP60::HPUX;
@Prod::DMP60::HPUX::ISA = qw(Prod::VM60::HPUX);

package Prod::DMP60::Linux;
@Prod::DMP60::Linux::ISA = qw(Prod::VM60::Linux);

package Prod::DMP60::SunOS;
@Prod::DMP60::SunOS::ISA = qw(Prod::VM60::SunOS);

package Prod::DMP60::SolSparc;
@Prod::DMP60::SolSparc::ISA = qw(Prod::VM60::SolSparc);

package Prod::DMP60::Sol11sparc;
@Prod::DMP60::Sol11sparc::ISA = qw(Prod::VM60::Sol11sparc);

package Prod::DMP60::Solx64;
@Prod::DMP60::Solx64::ISA = qw(Prod::VM60::Solx64);

package Prod::DMP60::Sol11x64;
@Prod::DMP60::Sol11x64::ISA = qw(Prod::VM60::Sol11x64);

1;
