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

package Prod::SVS60::SLES10x8664;
@Prod::SVS60::SLES10x8664::ISA = qw(Prod::SFCFSHA60::SLES10x8664);

package Prod::SVS60::SLES11x8664;
@Prod::SVS60::SLES11x8664::ISA = qw(Prod::SFCFSHA60::SLES11x8664);

package Prod::SVS60::SunOS;
@Prod::SVS60::SunOS::ISA = qw(Prod::SFCFSHA60::SunOS);

package Prod::SVS60::SolSparc;
@Prod::SVS60::SolSparc::ISA = qw(Prod::SFCFSHA60::SolSparc);

package Prod::SVS60::Solx64;
@Prod::SVS60::Solx64::ISA = qw(Prod::SFCFSHA60::Solx64);

1;
