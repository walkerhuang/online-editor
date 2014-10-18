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
# $

use strict;

use EDR;
use CPIC;

use Rel::UXRT61;
require "Rel/Releasedefs.pl";
require "Rel/UXRTLicensing61.pl";

use Prod::DMP61;
use Prod::FS61;
use Prod::SF61;
use Prod::SFHA61;
use Prod::SFCFSHA61;
use Prod::SFCFSRAC61;
use Prod::SFRAC61;
use Prod::SVS61;
use Prod::VCS61;
use Prod::VM61;
use Prod::LP61;
use Prod::SFSYBASECE61;
use Prod::APPLICATIONHA61;

use Pkg::VRTSacclib52;
use Pkg::VRTSamf61;
use Pkg::VRTSaslapm61;
use Pkg::VRTSat50;
use Pkg::VRTSatClient50;
use Pkg::VRTScavf61;
use Pkg::VRTScps61;
use Pkg::VRTSdbac61;
use Pkg::VRTSdbed61;
use Pkg::VRTSfsadv61;
use Pkg::VRTSfssdk61;
use Pkg::VRTSgab61;
use Pkg::VRTSglm61;
use Pkg::VRTSgms61;
use Pkg::VRTSllt61;
use Pkg::VRTSlvmconv61;
use Pkg::VRTSob34;
use Pkg::VRTSodm61;
use Pkg::VRTSperl516;
use Pkg::VRTSsfmh60;
use Pkg::VRTSsfcpi61;
use Pkg::VRTSspt61;
use Pkg::VRTSsvs61;
use Pkg::VRTSvcs61;
use Pkg::VRTSvcsag61;
use Pkg::VRTSvcsdr61;
use Pkg::VRTSvcsea61;
use Pkg::VRTSveki61;
use Pkg::VRTSvlic32;
use Pkg::VRTSvxfen61;
use Pkg::VRTSvxfs61;
use Pkg::VRTSvxvm61;
use Pkg::VRTSlang61;
use Pkg::VRTSvbs61;

use Pkg::VRTSvcswiz61;
use Pkg::VRTSmq651;
use Pkg::VRTSsapwebas7150;

use Pkg::VRTSjboss51;
use Pkg::VRTSmysql51;
use Pkg::VRTSsapcms51;
use Pkg::VRTSsaplc50;
use Pkg::VRTSsapnw0450;
use Pkg::VRTSvcswas51;
use Pkg::VRTSwls51;
use Pkg::VRTSvcsvmw61;

use Proc::amf61;
use Proc::CmdServer61;
use Proc::fdd61;
use Proc::gab61;
use Proc::had61;
use Proc::llt61;
use Proc::lmx61;
use Proc::odm61;
use Proc::qio61;
use Proc::qlog61;
use Proc::sfmhdiscovery61;
use Proc::vcsmm61;
use Proc::vvr61;
use Proc::vxattachd61;
use Proc::vxatd50;
use Proc::vxcached61;
use Proc::vxconfigbackupd61;
use Proc::vxconfigd61;
use Proc::vxcpserv61;
use Proc::vxdclid50;
use Proc::vxdclid61;
use Proc::vxdbd61;
use Proc::vxdmp61;
use Proc::vxesd61;
use Proc::vxfen61;
use Proc::vxfs61;
use Proc::vxglm61;
use Proc::vxgms61;
use Proc::vxio61;
use Proc::vxnotify61;
use Proc::vxpal50;
use Proc::vxportal61;
use Proc::vxrelocd61;
use Proc::vxsited61;
use Proc::vxspec61;
use Proc::vxsvc34;
use Proc::xprtld50;
use Proc::svsweb61;
use Proc::vxcafs61;

package CPIP;
sub cpip_resume_subs {
    [ qw(Prod::SFRAC61::Common::cli_prestart_config_questions
         Prod::SFRAC61::Common::config_sfrac_subcomponents
         Prod::SFRAC61::Common::create_oracle_user_group
         Prod::SFRAC61::Common::create_ocr_vote_storage
         Prod::SFRAC61::Common::install_oracle_clusterware
         Prod::SFRAC61::Common::install_oracle_database
         Prod::SFRAC61::Common::config_cssd_agent
         Prod::SFRAC61::Common::relink_oracle_database
         Prod::SFRAC61::Common::post_config_check_sfrac
         Prod::SFRAC61::Common::config_haip
         Prod::SFRAC61::Common::config_privnic
         Prod::SFRAC61::Common::config_multiprivnic
         Prod::SFCFSHA61::Common::cli_prestart_config_questions
         Prod::SFSYBASECE61::Common::cli_prestart_config_questions
         Prod::VCS61::Common::add_users
         Prod::VCS61::Common::ask_clustername
         Prod::VCS61::Common::ask_fencing_enabled
         Prod::VCS61::Common::ask_hbnics
         Prod::VCS61::Common::autocfg_hbnics
         Prod::VCS61::Common::cli_prestart_config_questions
         Prod::VCS61::Common::config_cluster
         Prod::VCS61::Common::config_gcoption
         Prod::VCS61::Common::config_smtp
         Prod::VCS61::Common::config_snmp
         Prod::VCS61::Common::config_vip
         Prod::VCS61::Common::config_vxss
         Prod::VCS61::Common::hb_config_option
         Prod::VCS61::Common::set_lowpri_for_slow_links
         Prod::VM61::AIX::cli_prestart_config_questions
         Prod::VM61::HPUX::cli_prestart_config_questions
         Prod::VM61::Linux::cli_prestart_config_questions
         Prod::VM61::SunOS::ask_upgrade_err_sys
         Prod::VM61::SunOS::cli_prestart_config_questions
    ) ]
}

sub get_hotfix_sort_url {
    my $url;

#    $url = "http://pilotlnx11.veritas.com/cgi-bin/sort_release_web_service.pl";
#    $url = "https://dev-sort.engba.symantec.com/kb_38/3_8/vos_services/rest/patch_services/1.0/release";
#    $url= "https://staging-sort.symantec.com/vos_services/rest/patch_services/1.0/release";
    $url="https://sort.symantec.com/vos_services/rest/patch_services/1.0/release";

    return $url;
}

sub get_release_version {
    my ($release) = @_;

    my $self = {};
    my $class ="Rel\::$release\::Common";
    bless($self, $class);
    $self->{class} = $class;
    $self->init();
    return $self->{titlevers};
}

Trace::binding(CPIP::traceconf());

1;
