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

package Prod::SVS61::Common;
@Prod::SVS61::Common::ISA = qw(Prod::SFCFSHA61::Common);

package Prod::SVS61::AIX;
@Prod::SVS61::AIX::ISA = qw(Prod::SFCFSHA61::AIX);

package Prod::SVS61::HPUX;
@Prod::SVS61::HPUX::ISA = qw(Prod::SFCFSHA61::HPUX);

package Prod::SVS61::Linux;
@Prod::SVS61::Linux::ISA = qw(Prod::SFCFSHA61::Linux);

package Prod::SVS61::RHEL5x8664;
@Prod::SVS61::RHEL5x8664::ISA = qw(Prod::SFCFSHA61::RHEL5x8664);

package Prod::SVS61::RHEL6x8664;
@Prod::SVS61::RHEL6x8664::ISA = qw(Prod::SFCFSHA61::RHEL6x8664);

package Prod::SVS61::RHEL6ppc64;
@Prod::SVS61::RHEL6ppc64::ISA = qw(Prod::SFCFSHA61::RHEL6ppc64);

package Prod::SVS61::SLES10x8664;
@Prod::SVS61::SLES10x8664::ISA = qw(Prod::SFCFSHA61::SLES10x8664);

package Prod::SVS61::SLES11x8664;
@Prod::SVS61::SLES11x8664::ISA = qw(Prod::SFCFSHA61::SLES11x8664);

package Prod::SVS61::SLES11ppc64;
@Prod::SVS61::SLES11ppc64::ISA = qw(Prod::SFCFSHA61::SLES11ppc64);

package Prod::SVS61::SunOS;
@Prod::SVS61::SunOS::ISA = qw(Prod::SFCFSHA61::SunOS);

package Prod::SVS61::SolSparc;
@Prod::SVS61::SolSparc::ISA = qw(Prod::SFCFSHA61::SolSparc);

package Prod::SVS61::Sol11sparc;
@Prod::SVS61::Sol11sparc::ISA = qw(Prod::SFCFSHA61::Sol11sparc);

package Prod::SVS61::Solx64;
@Prod::SVS61::Solx64::ISA = qw(Prod::SFCFSHA61::Solx64);

package Prod::SVS61::Sol11x64;
@Prod::SVS61::Sol11x64::ISA = qw(Prod::SFCFSHA61::Sol11x64);

1;
