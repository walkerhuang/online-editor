use strict;

use EDR;
use CPIC;

use Rel::UXRT601;
require "Rel/UXRTLicensing601.pl";

use Prod::DMP60;
use Prod::FS60;
use Prod::SF60;
use Prod::SFHA60;
use Prod::SFCFSHA60;
use Prod::SFCFSRAC60;
use Prod::SFRAC60;
use Prod::SVS60;
use Prod::VCS60;
use Prod::VM60;
use Prod::LP60;
use Prod::SFSYBASECE60;

use Pkg::VRTSacclib52;
use Pkg::VRTSamf60;
use Pkg::VRTSaslapm60;
use Pkg::VRTSat50;
use Pkg::VRTSatClient50;
use Pkg::VRTScavf60;
use Pkg::VRTScps60;
use Pkg::VRTSdbac60;
use Pkg::VRTSdbed60;
use Pkg::VRTSfsadv60;
use Pkg::VRTSfssdk60;
use Pkg::VRTSgab60;
use Pkg::VRTSglm60;
use Pkg::VRTSgms60;
use Pkg::VRTSllt60;
use Pkg::VRTSlvmconv60;
use Pkg::VRTSob34;
use Pkg::VRTSodm60;
use Pkg::VRTSperl514;
use Pkg::VRTSsfmh41;
use Pkg::VRTSsfcpi601;
use Pkg::VRTSspt60;
use Pkg::VRTSsvs60;
use Pkg::VRTSvcs60;
use Pkg::VRTSvcsag60;
use Pkg::VRTSvcsdr60;
use Pkg::VRTSvcsea60;
use Pkg::VRTSveki60;
use Pkg::VRTSvlic32;
use Pkg::VRTSvxfen60;
use Pkg::VRTSvxfs60;
use Pkg::VRTSvxvm60;
use Pkg::VRTSlang60;
use Pkg::VRTSvbs60;

use Proc::amf60;
use Proc::CmdServer60;
use Proc::fdd60;
use Proc::gab60;
use Proc::had60;
use Proc::llt60;
use Proc::lmx60;
use Proc::odm60;
use Proc::qio60;
use Proc::qlog60;
use Proc::sfmhdiscovery60;
use Proc::vcsmm60;
use Proc::vvr60;
use Proc::vxattachd60;
use Proc::vxatd50;
use Proc::vxcached60;
use Proc::vxconfigbackupd60;
use Proc::vxconfigd60;
use Proc::vxcpserv60;
use Proc::vxdclid50;
use Proc::vxdclid60;
use Proc::vxdbd60;
use Proc::vxdmp60;
use Proc::vxesd60;
use Proc::vxfen60;
use Proc::vxfs60;
use Proc::vxglm60;
use Proc::vxgms60;
use Proc::vxio60;
use Proc::vxnotify60;
use Proc::vxpal50;
use Proc::vxportal60;
use Proc::vxrelocd60;
use Proc::vxsited60;
use Proc::vxspec60;
use Proc::vxsvc34;
use Proc::xprtld50;

package CPIP;
sub cpip_resume_subs {
    [ qw(Prod::SFCFSHA60::Common::cli_prestart_config_questions
         Prod::VCS60::Common::add_users
         Prod::VCS60::Common::ask_clustername
         Prod::VCS60::Common::ask_fencing_enabled
         Prod::VCS60::Common::ask_hbnics
         Prod::VCS60::Common::autocfg_hbnics
         Prod::VCS60::Common::cli_prestart_config_questions
         Prod::VCS60::Common::config_cluster
         Prod::VCS60::Common::config_gcoption
         Prod::VCS60::Common::config_smtp
         Prod::VCS60::Common::config_snmp
         Prod::VCS60::Common::config_vip
         Prod::VCS60::Common::config_vxss
         Prod::VCS60::Common::hb_config_option
         Prod::VCS60::Common::set_lowpri_for_slow_links
         Prod::VM60::AIX::cli_prestart_config_questions
         Prod::VM60::HPUX::cli_prestart_config_questions
         Prod::VM60::Linux::cli_prestart_config_questions
         Prod::VM60::SunOS::ask_upgrade_err_sys
         Prod::VM60::SunOS::cli_prestart_config_questions
    ) ]
}

Trace::binding(CPIP::traceconf());

1;
