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

package Prod::SVS62::Common;
@Prod::SVS62::Common::ISA = qw(Prod::SFCFSHA62::Common);

package Prod::SVS62::AIX;
@Prod::SVS62::AIX::ISA = qw(Prod::SFCFSHA62::AIX);

package Prod::SVS62::HPUX;
@Prod::SVS62::HPUX::ISA = qw(Prod::SFCFSHA62::HPUX);

package Prod::SVS62::Linux;
@Prod::SVS62::Linux::ISA = qw(Prod::SFCFSHA62::Linux);

package Prod::SVS62::RHEL5x8664;
@Prod::SVS62::RHEL5x8664::ISA = qw(Prod::SFCFSHA62::RHEL5x8664);

package Prod::SVS62::RHEL6x8664;
@Prod::SVS62::RHEL6x8664::ISA = qw(Prod::SFCFSHA62::RHEL6x8664);

package Prod::SVS62::RHEL6ppc64;
@Prod::SVS62::RHEL6ppc64::ISA = qw(Prod::SFCFSHA62::RHEL6ppc64);

package Prod::SVS62::RHEL7x8664;
@Prod::SVS62::RHEL7x8664::ISA = qw(Prod::SFCFSHA62::RHEL7x8664);

package Prod::SVS62::OL6x8664;
@Prod::SVS62::OL6x8664::ISA = qw(Prod::SFCFSHA62::OL6x8664);

package Prod::SVS62::OL7x8664;
@Prod::SVS62::OL7x8664::ISA = qw(Prod::SFCFSHA62::OL7x8664);

package Prod::SVS62::SLES10x8664;
@Prod::SVS62::SLES10x8664::ISA = qw(Prod::SFCFSHA62::SLES10x8664);

package Prod::SVS62::SLES11x8664;
@Prod::SVS62::SLES11x8664::ISA = qw(Prod::SFCFSHA62::SLES11x8664);

package Prod::SVS62::SLES11ppc64;
@Prod::SVS62::SLES11ppc64::ISA = qw(Prod::SFCFSHA62::SLES11ppc64);

package Prod::SVS62::SunOS;
@Prod::SVS62::SunOS::ISA = qw(Prod::SFCFSHA62::SunOS);

package Prod::SVS62::SolSparc;
@Prod::SVS62::SolSparc::ISA = qw(Prod::SFCFSHA62::SolSparc);

package Prod::SVS62::Sol11sparc;
@Prod::SVS62::Sol11sparc::ISA = qw(Prod::SFCFSHA62::Sol11sparc);

package Prod::SVS62::Solx64;
@Prod::SVS62::Solx64::ISA = qw(Prod::SFCFSHA62::Solx64);

package Prod::SVS62::Sol11x64;
@Prod::SVS62::Sol11x64::ISA = qw(Prod::SFCFSHA62::Sol11x64);

1;
