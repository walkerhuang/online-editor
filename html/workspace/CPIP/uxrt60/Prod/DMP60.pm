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

package Prod::DMP60::Solx64;
@Prod::DMP60::Solx64::ISA = qw(Prod::VM60::Solx64);

1;
