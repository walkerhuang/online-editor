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

use Rel::UXRT62;
require "Rel/Releasedefs.pl";
require "Rel/UXRTLicensing62.pl";

use Prod::DMP62;
use Prod::FS62;
use Prod::SF62;
use Prod::SFHA62;
use Prod::SFCFSHA62;
use Prod::SFCFSRAC62;
use Prod::SFRAC62;
use Prod::SVS62;
use Prod::VCS62;
use Prod::VM62;
use Prod::LP62;
use Prod::SFSYBASECE62;
use Prod::APPLICATIONHA62;

use Pkg::VRTSacclib52;
use Pkg::VRTSamf62;
use Pkg::VRTSaslapm62;
use Pkg::VRTSat50;
use Pkg::VRTSatClient50;
use Pkg::VRTScavf62;
use Pkg::VRTScps62;
use Pkg::VRTSdbac62;
use Pkg::VRTSdbed62;
use Pkg::VRTSfsadv62;
use Pkg::VRTSfssdk62;
use Pkg::VRTSgab62;
use Pkg::VRTSglm62;
use Pkg::VRTSgms62;
use Pkg::VRTSllt62;
use Pkg::VRTSob34;
use Pkg::VRTSodm62;
use Pkg::VRTSperl516;
use Pkg::VRTSsfmh61;
use Pkg::VRTSsfcpi62;
use Pkg::VRTSspt62;
use Pkg::VRTSsvs62;
use Pkg::VRTSvcs62;
use Pkg::VRTSvcsag62;
use Pkg::VRTSvcsdr62;
use Pkg::VRTSvcsea62;
use Pkg::VRTSveki62;
use Pkg::VRTSvlic32;
use Pkg::VRTSvxfen62;
use Pkg::VRTSvxfs62;
use Pkg::VRTSvxvm62;
use Pkg::VRTSlang62;
use Pkg::VRTSvbs62;
use Pkg::VRTSvcswiz62;
use Pkg::VRTSvcsvmw62;

use Proc::amf62;
use Proc::CmdServer62;
use Proc::fdd62;
use Proc::gab62;
use Proc::had62;
use Proc::veki62;
use Proc::llt62;
use Proc::lmx62;
use Proc::odm62;
use Proc::qio62;
use Proc::qlog62;
use Proc::sfmhdiscovery61;
use Proc::vcsmm62;
use Proc::vvr62;
use Proc::vxattachd62;
use Proc::vxatd50;
use Proc::vxcached62;
use Proc::vxconfigbackupd62;
use Proc::vxconfigd62;
use Proc::vxcpserv62;
use Proc::vxdclid50;
use Proc::vxdclid61;
use Proc::vxdbd62;
use Proc::vxdmp62;
use Proc::vxesd62;
use Proc::vxfen62;
use Proc::vxfs62;
use Proc::vxglm62;
use Proc::vxgms62;
use Proc::vxio62;
use Proc::vxnotify62;
use Proc::vxpal50;
use Proc::vxportal62;
use Proc::vxrelocd62;
use Proc::vxsited62;
use Proc::vxspec62;
use Proc::vxsvc34;
use Proc::xprtld61;
use Proc::svsweb62;
use Proc::vxcafs62;

package CPIP;

sub cpip_resume_subs {
    [ qw(Prod::SFRAC62::Common::cli_prestart_config_questions
         Prod::SFRAC62::Common::config_sfrac_subcomponents
         Prod::SFRAC62::Common::create_oracle_user_group
         Prod::SFRAC62::Common::create_ocr_vote_storage
         Prod::SFRAC62::Common::install_oracle_clusterware
         Prod::SFRAC62::Common::install_oracle_database
         Prod::SFRAC62::Common::config_cssd_agent
         Prod::SFRAC62::Common::relink_oracle_database
         Prod::SFRAC62::Common::post_config_check_sfrac
         Prod::SFRAC62::Common::config_haip
         Prod::SFRAC62::Common::config_privnic
         Prod::SFRAC62::Common::config_multiprivnic
         Prod::SFCFSHA62::Common::cli_prestart_config_questions
         Prod::SFSYBASECE62::Common::cli_prestart_config_questions
         Prod::VCS62::Common::add_users
         Prod::VCS62::Common::ask_clustername
         Prod::VCS62::Common::ask_fencing_enabled
         Prod::VCS62::Common::ask_hbnics
         Prod::VCS62::Common::autocfg_hbnics
         Prod::VCS62::Common::cli_prestart_config_questions
         Prod::VCS62::Common::config_cluster
         Prod::VCS62::Common::config_gcoption
         Prod::VCS62::Common::config_smtp
         Prod::VCS62::Common::config_snmp
         Prod::VCS62::Common::config_vip
         Prod::VCS62::Common::config_vxss
         Prod::VCS62::Common::hb_config_option
         Prod::VCS62::Common::set_lowpri_for_slow_links
         Prod::VM62::AIX::cli_prestart_config_questions
         Prod::VM62::HPUX::cli_prestart_config_questions
         Prod::VM62::Linux::cli_prestart_config_questions
         Prod::VM62::SunOS::ask_upgrade_err_sys
         Prod::VM62::SunOS::cli_prestart_config_questions
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

