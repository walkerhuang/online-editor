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

package Prod::SVS60::Common;
@Prod::SVS60::Common::ISA = qw(Prod::SFCFSHA60::Common);

package Prod::SVS60::AIX;
@Prod::SVS60::AIX::ISA = qw(Prod::SFCFSHA60::AIX);

package Prod::SVS60::HPUX;
@Prod::SVS60::HPUX::ISA = qw(Prod::SFCFSHA60::HPUX);

package Prod::SVS60::Linux;
@Prod::SVS60::Linux::ISA = qw(Prod::SFCFSHA60::Linux);

package Prod::SVS60::RHEL5x8664;
@Prod::SVS60::RHEL5x8664::ISA = qw(Prod::SFCFSHA60::RHEL5x8664);

package Prod::SVS60::RHEL6x8664;
@Prod::SVS60::RHEL6x8664::ISA = qw(Prod::SFCFSHA60::RHEL6x8664);

package Prod::SVS60::RHEL6ppc64;
@Prod::SVS60::RHEL6ppc64::ISA = qw(Prod::SFCFSHA60::RHEL6ppc64);

package Prod::SVS60::SLES10x8664;
@Prod::SVS60::SLES10x8664::ISA = qw(Prod::SFCFSHA60::SLES10x8664);

package Prod::SVS60::SLES11x8664;
@Prod::SVS60::SLES11x8664::ISA = qw(Prod::SFCFSHA60::SLES11x8664);

package Prod::SVS60::SLES11ppc64;
@Prod::SVS60::SLES11ppc64::ISA = qw(Prod::SFCFSHA60::SLES11ppc64);

package Prod::SVS60::SunOS;
@Prod::SVS60::SunOS::ISA = qw(Prod::SFCFSHA60::SunOS);

package Prod::SVS60::SolSparc;
@Prod::SVS60::SolSparc::ISA = qw(Prod::SFCFSHA60::SolSparc);

package Prod::SVS60::Sol11sparc;
@Prod::SVS60::Sol11sparc::ISA = qw(Prod::SFCFSHA60::Sol11sparc);

package Prod::SVS60::Solx64;
@Prod::SVS60::Solx64::ISA = qw(Prod::SFCFSHA60::Solx64);

package Prod::SVS60::Sol11x64;
@Prod::SVS60::Sol11x64::ISA = qw(Prod::SFCFSHA60::Sol11x64);

1;
