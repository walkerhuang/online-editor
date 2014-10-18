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

package Prod::VCS61::Common;
@Prod::VCS61::Common::ISA = qw(Prod);

sub init_common {
    my ($prod,$padv);
    $prod = shift;
    $prod->{prod}='VCS';
    $prod->{abbr}='VCS';
    $prod->{vers}='6.1.1.000';
    $prod->{proddir}='cluster_server';
    $prod->{eula}='EULA_SFHA_Ux_6.1.pdf';
    $prod->{name}=Msg::new("Symantec Cluster Server")->{msg};
    $prod->{mainpkg}='VRTSvcs61';
    $prod->{extra_mainpkgs}=[qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSvcsag61)];

    $prod->{lic_names}=['Veritas Cluster Server'];

    $prod->{menu_options}=['Global Cluster Option'];

    $prod->{minimal_memory_requirment} = '256 MB';

    $prod->{llthosts}='/etc/llthosts';
    $prod->{llttab}='/etc/llttab';
    $prod->{gabtab}='/etc/gabtab';
    $prod->{maincf}='/etc/VRTSvcs/conf/config/main.cf';
    $prod->{typescf}='/etc/VRTSvcs/conf/config/types.cf';
    $prod->{extra_types_cf}='/etc/VRTSvcs/conf/extra_types_cf';
    $prod->{vxfenmode}='/etc/vxfenmode';
    $prod->{vxfendg}='/etc/vxfendg';
    $prod->{nofinish_encap}=1;

    $prod->{configfiles}=[ $prod->{maincf}, $prod->{typescf} ];
    $prod->{secure}='/etc/VRTSvcs/conf/config/.secure';

    # define frequently referenced paths
    $prod->{confdir}='/etc/VRTSvcs/conf';
    $prod->{configdir}='/etc/VRTSvcs/conf/config';
    $prod->{bindir}='/opt/VRTSvcs/bin';
    $prod->{gcmbindir}='/opt/VRTSgcm/bin';

    $prod->{uuidconfig}="$prod->{bindir}/uuidconfig.pl";
    $prod->{uuidfile}='/etc/vx/.uuids/clusuuid';
    $prod->{responsefileupgradeok}=1;
    $prod->{cmd_hacf}="$prod->{bindir}/hacf";

    # For UXRT 5.1SP1, need define obsoleted pkgs from GA release
    $prod->{obsoleted_ga_release_pkgs} = [ qw(VRTScutil) ];
    $prod->{installonupgradepkgs} = [ qw(VRTSamf VRTSsfmh VRTSvbs VRTSvcswiz VRTSmq6 VRTSsapwebas71) ];

    # define commands consistent across platforms
    $padv = $prod->padv();
    $padv->{cmd}{lltstat} = '/sbin/lltstat';
    $padv->{cmd}{lltconfig} = '/sbin/lltconfig';
    $padv->{cmd}{gabconfig} = '/sbin/gabconfig';
    $padv->{cmd}{amfconfig} = '/opt/VRTSamf/bin/amfconfig';
    $padv->{cmd}{vxfenconfig} = '/sbin/vxfenconfig';
    $padv->{cmd}{vxfenadm} = '/sbin/vxfenadm';
    $padv->{cmd}{hastop} = '/opt/VRTSvcs/bin/hastop';
    $padv->{cmd}{hasys} = '/opt/VRTSvcs/bin/hasys';
    $padv->{cmd}{hagrp} = '/opt/VRTSvcs/bin/hagrp';
    $padv->{cmd}{hares} = '/opt/VRTSvcs/bin/hares';
    $padv->{cmd}{hastatus} = '/opt/VRTSvcs/bin/hastatus';


    # define role grouping attributes
    $prod->{rolegroupingattrs} = [ qw(AdministratorGroups OperatorGroups Guests) ];

    # todo: used for dynupgrade and need to be platform specific
    $prod->{deleted_agents} = [ qw() ];

    $prod->{max_number_in_cluster} = 64;

    # limits of heartbeat links
    $prod->{max_lltlinks} = 8;
    $prod->{max_hipri_links} = 4;
    #security default port number
    $prod->{vssdefport}=2821;

    $prod->{has_config} = 1;

    # eat related conf
    $prod->{eat_setup} = {
        'SourceDir'         => '',
        'DestDir'           => '/opt/VRTSvcs/bin/vcsauth/vcsauthserver',
        'DataDir'           => '/var/VRTSvcs/vcsauth/data/VCSAUTHSERVER',
        'RootBrokerName'    => 'vcsroot',
        'SetToRBPlusABorNot'=> '',
        'AcceptorMode'      => 'IP_ONLY',
        'IPPort'            => '14149',
        'BrokerExeName'     => 'vcsauthserver',
        'ClusterName'       => '',
        'SetupPDRs'         => '1',
        'FipsMode'          => '0',
    };
    $prod->{eat_data_root} = '/var/VRTSvcs/vcsauth/data';
    $prod->{eat_data_backup} = '/var/VRTSvcs/vcsauth/bkup';
    $prod->{eat_domain_expiry_year} = 8;
    $prod->{eat_processes} = [qw(HAD WAC CMDSERVER CPSERVER CPSADM)];
    $prod->{eat_domain_name} = "VCS_SERVICES";
    $prod->{eat_vcs_bin} = '/opt/VRTSvcs/bin';
    $prod->{eat_opt_space_need} = 100000;
    $prod->{eat_log_file} = '/var/VRTSvcs/log/vcsauthserver.log';
    $prod->{eat_shared_at_bin} = '/opt/VRTSat/bin';
    $prod->{eat_lu_modify_keys} = [qw(eat_data_root eat_data_backup eat_vcs_bin eat_log_file)];

    $prod->{eat_share_conf} = '/var/VRTSat/.VRTSat/profile/VRTSatlocal.conf';
    $prod->{amftab}=[ '/etc/amftab' ];
    $prod->{fencing_config_pending}=1;
    $prod->{superprods} = [qw(SFRAC61 SVS61 SFSYBASECE61 SFCFSHA61)];

    $prod->{replace_cps_key} = 0;
    return;
}

sub adjust_ru_procs {
    my $prod=shift;
    if(Cfg::opt('upgrade_nonkernelpkgs')){
        my $procs=[qw(had61 CmdServer61)];
        return $procs;
    }
}

sub ask_fencing_enabled {
    my ($ayn,$help,$msg,$description);
    my $prod = shift;
    my $cfg = Obj::cfg();
    my $vxfen=$prod->proc('vxfen61');
    return '' if (Cfg::opt('responsefile'));
    $msg = Msg::new("I/O Fencing\n");
    $msg->bold;
    $msg = Msg::new("It needs to be determined at this time if you plan to configure I/O Fencing in enabled or disabled mode, as well as help in determining the number of network interconnects (NICS) required on your systems. If you configure I/O Fencing in enabled mode, only a single NIC is required, though at least two are recommended.\n\nA split brain can occur if servers within the cluster become unable to communicate for any number of reasons. If I/O Fencing is not enabled, you run the risk of data corruption should a split brain occur. Therefore, to avoid data corruption due to split brain in CFS environments, I/O Fencing has to be enabled.\n");
    $msg->print;
    $description = $msg->{msg};
    $msg = Msg::new("If you do not enable I/O Fencing, you do so at your own risk\n");
    $msg->bold;
    $description .= $msg->{msg};
    $msg = Msg::new("See the Administrator's Guide for more information on I/O Fencing");
    $msg->print;
    $description .= $msg->{msg};
    $help = $msg;
    $msg = Msg::new("\nDo you want to configure I/O Fencing in enabled mode?");
    $ayn = $msg->ayny($help,0,$description);
    Msg::n();
    $cfg->{fencingenabled} = ($ayn eq 'Y') ? 1 : 0;
    return;
}

sub set_options {
    my ($prod,$options) = @_;
    my ($id,$option);
    $id=0;
    for my $option (@{$options}) {
        if($option) {
           if ($id == 0) {
               Cfg::set_opt('gco', 1);
           }
        }
        $id++;
    }
    return;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($pkgvers,$vmwpkg,$vmwpkgvers);
    my $rel=Obj::rel();

    return unless($rel->prod_licensed_sys($sys,$prod->{prodi}));
    # 1. $prod->{mainpkg}, which is VRTSvcs, must be installed with correct version
    # 2. return $prod->{mainpkg} version as VCS's version
    $pkgvers = $prod->SUPER::version_sys($sys,$force_flag);
    return '' unless ($pkgvers);

    # if $vcsvmwver <= 6.0.100.000, it's AppHA.
    # if 6.0.100 < $vcsvmwver < 6.0.XYZ it's TerraNova(VCS).
    # if $vcsvmwver >= 6.1, it's AppHA
    $vmwpkg = $sys->pkg('VRTSvcsvmw61',1);
    return $pkgvers unless ($vmwpkg);

    $vmwpkgvers=$vmwpkg->version_sys($sys,$force_flag);
    return $pkgvers if (!$vmwpkgvers || (EDRu::compvers($vmwpkgvers, '6.0.100.000', 3) == 1 && EDRu::compvers($vmwpkgvers, '6.1.000.000', 3) == 2));
    return '';
}

sub description {
    my $msg=Msg::new("Symantec Cluster Server, the industry's leading open systems clustering solution, is ideal for eliminating both planned and unplanned downtime, facilitating server consolidation, and effectively managing a wide range of applications in heterogeneous environments.");
    $msg->print;
    return;
}

sub verify_procs_list {
    my ($prod,$procs,$state)=@_;
    my $cfg = Obj::cfg();
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure')) &&
        ($cfg->{donotreconfigurevcs})) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    if ((defined $state && $state eq 'stop') && (Cfg::opt('upgrade_kernelpkgs'))) {
        my @ruprocs=();
        push(@ruprocs,'had61');
        push(@ruprocs,'CmdServer61');
        push(@ruprocs,@{$procs});
        $procs=EDRu::arruniq(@ruprocs)
    }

    return $procs;
}

sub stopprocs {
    my $prod=shift;
    my $ref_procs = Prod::stopprocs($prod);
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $ref_procs = $prod->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub verify_procs_list_sys {
    my ($prod,$sys,$procs,$state)=@_;
    my $cfg = Obj::cfg();
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure')) &&
        ($cfg->{donotreconfigurevcs})) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    if ((defined $state && $state eq 'stop') && (Cfg::opt('upgrade_kernelpkgs') && (!EDRu::inarr('had61',@{$procs})))) {
        push(@{$procs},'had61');
        push(@{$procs},'CmdServer61');

    }
    my $vm = $prod->prod('VM61');
    # adjust sfmh-discovery process
    $procs = $vm->adjust_sfmh_for_procs_sys($sys,$procs,$state);

    return $procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my $ref_procs = Prod::stopprocs_sys($prod, $sys);
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub vcs_enable_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$proc,@list);
    $cfg = Obj::cfg();
    if ($cfg->{vcs_allowcomms}) {
        @list = qw(llt61 gab61 had61 amf61);
        $prod->vxfen_enable_sys($sys);
    } else {
        @list = qw(had61 amf61);
    }
    for my $proci (@list) {
        $proc = $sys->proc($proci);
        $proc->enable_sys($sys);
    }
    return;
}

sub vxfen_enable_sys {
    my ($prod,$sys) = @_;
    my ($proc,$rootpath);
    $rootpath = Cfg::opt('rootpath');
    $proc = $sys->proc('vxfen61');
    if ($sys->exists("$rootpath$prod->{vxfenmode}") ||
        $sys->exists("$rootpath$prod->{vxfendg}")) {
        $proc->enable_sys($sys);
    }
    return;
}

sub vcs_disable_sys {
    my ($prod,$sys) = @_;

    for my $proci (qw(llt61 gab61 had61 vxfen61 amf61)) {
        my $proc = $sys->proc($proci);
        $proc->disable_sys($sys,1);
    }
    return;
}

sub vcs_reservedwords {
    my ($prod,$name) = @_;
    my @vcs_res_words = qw(
        ArgListValues
        Cluster
        ConfidenceLevel
        ConfidenceMsg
        Group
        IState
        MonitorOnly
        Name
        Path
        Probed
        Signaled
        Start
        State
        System
        Type
        MonitorMethod
        NameRule
        action
        after
        before
        boolean
        cluster
        condition
        event
        false
        firm
        global
        group
        hard
        heartbeat
        i18nstr
        int
        keylist
        local
        localclus
        offline
        online
        remote
        remotecluster
        requires
        resource
        set
        soft
        start
        state
        static
        stop
        str
        system
        temp
        true
        type
    );

    return 1 if (EDRu::inarr($name, @vcs_res_words));
    return 0;
}

sub set_vcs_allowcomms_sys {
    my ($prod,$sys) = @_;
    my $cfg = Obj::cfg();
    my $rootpath = Cfg::opt('rootpath') || '';
    my $maincf = $rootpath.$prod->{maincf};
    my $pids = $sys->proc_pids('bin/had -onenode');
    my $cprod=CPIC::get('prod');
    my $nsystems = 0;
    if ($sys->exists($maincf)) {
        $nsystems = $sys->cmd("_cmd_grep '^[ \t]*system[ \t]' $maincf 2> /dev/null | _cmd_wc -l");
        $prod->set_value('vcs_systems_num', $nsystems);
    }

    my $out = $sys->cmd("_cmd_grep 'UseFence' $maincf 2> /dev/null");
    if ($out =~ /UseFence\s+=\s+SCSI3/mx) {
        $prod->set_value('lgf_vxfen', 1);
    }

    return if(defined $cfg->{vcs_allowcomms});

    if (@$pids && $nsystems < 2 && ($cprod =~ /^(VCS|SFHA)\d+/mx)) {
        $cfg->set_value('vcs_allowcomms', 0);
    } elsif ($sys->exists("$rootpath$prod->{llthosts}") &&
             $sys->exists("$rootpath$prod->{llttab}") &&
             $sys->exists("$rootpath$prod->{gabtab}")) {
        $cfg->set_value('vcs_allowcomms', 1);
    } else {
        $cfg->set_value('vcs_allowcomms', 0);
    }
    $prod->set_value('vcs_allowcomms', $cfg->{vcs_allowcomms});
    return 1;
}

sub modify_maincf_for_lgf_onenode {
    my ($prod,$sys,$file) = @_;
    my ($n,$cprod,$cfg,$maincf,$tmpmaincf);

    $n= $prod->{vcs_systems_num};
    return unless ($n == 1);

    $cprod = CPIC::get('prod');
    return unless ($cprod =~ /(VCS|SFHA)\d+/mx);

    $cfg=Obj::cfg();
    if (!$cfg->{vcs_allowcomms} && $prod->{lgf_vxfen}) {
        $maincf=$sys->readfile($file);
        for my $line (split(/^/m,$maincf)) {
            next if($line=~/UseFence/m);
            $tmpmaincf.=$line;
        }
        $sys->writefile($tmpmaincf,$file);
    }
    return 1;
}

# ask to configure when upgrade
sub ask_upgrade_configure {
    my ($prod) = @_;
    my ($cpic,$sys);

    $cpic = Obj::cpic();
    $sys = ${$cpic->{systems}}[0];
    return if ($sys->{noconfig_vcs});

    $prod->ask_upgrade_singlenode_configure();
    # ask some questions for cp client, when upgrade.
    $prod->ask_upgrade_cpsfencing_configure();

    return 1;
}

sub ask_upgrade_cpsfencing_configure {
    my ($prod) = @_;
    my ($ret,$conf,$pkg,$sys,$vxfenconf,$msg,$cfg);

    return 1 unless (Cfg::opt(qw(upgrade)) && !Cfg::opt(qw(upgrade_nonkernelpkgs)));

    # if users choose not to start llt/gab, not ask question
    $cfg = Obj::cfg();
    return 1 if (!$cfg->{vcs_allowcomms});

    $pkg = $prod->pkg('VRTSvxfen61');
    $sys = ${CPIC::get('systems')}[0];
    $vxfenconf = $prod->get_vxfen_config_sys($sys);
    if ($vxfenconf->{vxfen_mechanism} && ($vxfenconf->{vxfen_mechanism} eq 'cps')) {
        $msg = Msg::new("Communication between the CP server and application clusters will always be secured by HTTPS from 6.1.0 onwards, enter the following information to configure I/O fencing with HTTPS support.");
        $msg->printn;

        # to ask some questions about cp client and update the config file
        # if choose 'back', ask again
        do {
            $ret = $pkg->https_config_client_upgrade();
        } while ($ret == -1);
    }

    return 1;
}

sub ask_upgrade_singlenode_configure {
    my ($prod) = @_;
    my ($n,$cprod,$cfg,$msg,$help,$rtn,$cpic,$super,$rootpath);

    # should only ask on rolling upgrade phase1
    return if (Cfg::opt('upgrade_nonkernelpkgs'));

    $rootpath=Cfg::opt('rootpath');
    return if ($rootpath);

    $n= $prod->{vcs_systems_num};
    return unless ($n == 1);

    $cprod = CPIC::get('prod');
    return unless ($cprod =~ /(VCS|SFHA)\d+/mx);

    # do not ask if start llt/gab if llt/gab not started before upgrade.
    $cfg=Obj::cfg();
    return unless ($cfg->{vcs_allowcomms});

    $cpic = Obj::cpic();
    $super = $cpic->prod;

    # Fix for ET3117989 - skip start of llt/gab for onenode cps
    if ($prod->{replace_cps_key} == 1) {
       $cfg->{vcs_allowcomms} = 0;
       return;
    }

    # ask whether to start LGF.
    Msg::n();
    $help= Msg::new("If you plan to run $super->{abbr} on a single node without any need for adding cluster node online, you have an option to proceed without starting GAB and LLT. Starting GAB and LLT is recommended.");
    $help->bold;

    if ($prod->{lgf_vxfen}) {
        Msg::n();
        $msg = Msg::new("I/O fencing was configured on this node, it will also be disabled if you do not want to start GAB and LLT.");
        $msg->bold;
    }

    Msg::n();
    $msg = Msg::new("Do you want to start GAB and LLT?");
    $rtn = $msg->ayny($help);
    Msg::n();
    if ($rtn eq 'N') {
        $cfg->{vcs_allowcomms} = 0;
    } else {
        $cfg->{vcs_allowcomms} = 1;
    }
    return 1;
}

sub upgrade_ru_check_sys {
    my ($prod,$sys) = @_;
    my ($msg,$had,$llt,$gab,$out,$rutype,$rel,$ru_running,$ru_idle);
    return 1 unless (Cfg::opt('upgrade_nonkernelpkgs') || Cfg::opt('upgrade_kernelpkgs'));
    $had = $sys->proc('had61');
    $gab = $sys->proc('gab61');
    $llt = $sys->proc('llt61');
    $rel = Obj::rel();

    $ru_running = scalar @{$rel->{ru_running_list}} if (defined $rel->{ru_running_list});
    $ru_idle = scalar @{$rel->{ru_idle_list}} if (defined $rel->{ru_idle_list});
    # for single node rolling upgrade, not check the status of llt/gab
    if ($ru_running + $ru_idle != 1) {
        unless ($had->check_sys($sys) && $gab->check_sys($sys) && $llt->check_sys($sys)) {
            $msg = Msg::new("To perform rolling upgrade, VCS/GAB/LLT must be running on $sys->{sys}.");
            $sys->push_error($msg);
            return 0;
        }
    }

    #Check Cluster Sercive group status in Precheck for rolling upgrade
    $out=$sys->cmd("$prod->{bindir}/hagrp -list 2>/dev/null | _cmd_awk '{print \$1}' | _cmd_sort | _cmd_uniq");
    my $sysname=$prod->get_vcs_sysname_sys($sys);
    foreach my $sg (split(/\n/,$out)){
        my $state=$sys->cmd("$prod->{bindir}/hagrp -display $sg -attribute State -sys $sysname 2>/dev/null");
        $rutype= "rolling upgrade phase1" if (Cfg::opt('upgrade_kernelpkgs'));
        $rutype= "rolling upgrade phase2" if (Cfg::opt('upgrade_nonkernelpkgs'));
        if($state){
           Msg::log("Service group state on $sys->{sys} for $rutype:\n$state");
        }
    }

    return 1;
}

sub verify_responsefile {
    my $prod=shift;
    my (@sevs,$cfg,$csg,$msg,$nics,$pkg,@systems);
    return if (Cfg::opt('uninstall'));
    $cfg=Obj::cfg();
    @sevs=qw(Information Warning Error SevereError);

    # verify cluster config: CLUSTERNAME, CLUSTERID, LLTLINK
    if (($cfg->{vcs_clustername}) || ($cfg->{vcs_clusterid}) || ($cfg->{'vcs_lltlink1'})) {
        unless ($prod->verify_clustername($cfg->{vcs_clustername})) {
            $msg=Msg::new("vcs_clustername has an incorrect value");
            $msg->die;
        }
        if ($cfg->{vcs_allowcomms} && ($cfg->{opt}{configure} || $cfg->{opt}{installconfig})) {
            #don't check VCS_LLTLINK when using -fencing or -cps
            if ( !Cfg::opt(qw(fencing configcps)) ) {
                if ( !EDRu::isint($cfg->{vcs_clusterid}) || ($cfg->{vcs_clusterid}<0) || ($cfg->{vcs_clusterid}>65535) ) {
                    $msg=Msg::new("vcs_clusterid must be an integer value between 0 and 65535");
                    $msg->die;
                }
                if (Cfg::opt('addnode')) {
                    @systems = @{$cfg->{newnodes}};
                } else {
                    @systems = @{$cfg->{systems}};
                }
                for my $sys (@systems) {
                    if (!$cfg->{'vcs_lltlink1'}{$sys}) {
                        $msg=Msg::new("vcs_lltlink1 is not configured for system $sys");
                        $msg->die;
                    }
                }
            }
        }
    }

    # verify csg config: CSGVIP, CSGNETMASK
    if ((defined($cfg->{vcs_csgvip})) || $cfg->{vcs_csgnetmask} || (defined($cfg->{vcs_csgnic}))) {
        $csg=1;
        if ( $cfg->{vcs_csgvip} && !EDRu::isip($cfg->{vcs_csgvip})) {
            $msg=Msg::new("vcs_csgvip is not a valid IP address");
            $msg->die;
        }
        if ($cfg->{vcs_csgnetmask} && !EDRu::isip($cfg->{vcs_csgnetmask})) {
            $msg=Msg::new("vcs_csgnetmask is not a valid netmask");
            $msg->die;
        }
        for my $sys (@{$cfg->{systems}}) {
            $nics++ if (defined($cfg->{vcs_csgnic}{$sys}));
        }
    }

    # verify smtp config: SMTPSERVER, SMTPRECP, SMTPRSEV
    if (($cfg->{vcs_smtpserver}) || (defined($cfg->{vcs_smtprecp})) || (defined($cfg->{vcs_smtprsev}))) {
        $csg=1;
        unless ($prod->verify_smtpserver($cfg->{vcs_smtpserver})) {
            $msg=Msg::new("vcs_smtpserver has an incorrect value");
            $msg->die;
        }
        if ($#{$cfg->{vcs_smtprecp}} != $#{$cfg->{vcs_smtprsev}}) {
            $msg=Msg::new("There are an unequal number of vcs_smtprecp and vcs_smtprsev array entries");
            $msg->die;
        }
        for my $n (0..$#{$cfg->{vcs_smtprecp}}) {
            unless ($prod->verify_emailadd(${$cfg->{vcs_smtprecp}}[$n])) {
                $msg=Msg::new("vcs_smtprecp has an incorrect value");
                $msg->die;
            }
            unless (EDRu::inarr(${$cfg->{vcs_smtprsev}}[$n],@sevs)) {
                $msg=Msg::new("${$cfg->{vcs_smtprsev}}[$n] is an incorrect vcs_smtprsev severity value.\nMust be Information, Warning, Error, or SevereError.");
                $msg->die;
            }
        }
    }

    # verify snmp config: SNMPPORT, SNMPCONS, SNMPCSEV
    if (($cfg->{vcs_snmpport}) || (defined($cfg->{vcs_snmpcons})) || (defined($cfg->{vcs_snmpcsev}))) {
        $csg=1;
        if (!EDRu::isint($cfg->{vcs_snmpport}) || (($cfg->{vcs_snmpport} > 65535) || ($cfg->{vcs_snmpport} < 0))) {
            $msg=Msg::new("vcs_snmpport has an incorrect value");
            $msg->die;
        }
        if ($#{$cfg->{vcs_snmpcons}} != $#{$cfg->{vcs_snmpcsev}}) {
            $msg=Msg::new("There are an unequal number of vcs_snmpcons and vcs_snmpcsev array entries");
            $msg->die;
        }
        for my $n (0..$#{$cfg->{vcs_snmpcons}}) {
            unless (EDRu::inarr(${$cfg->{vcs_snmpcsev}}[$n],@sevs)) {
                $msg=Msg::new("${$cfg->{vcs_snmpcsev}}[$n] is an incorrect vcs_snmpcsev severity value.\nMust be Information, Warning, Error, or SevereError.");
                $msg->die;
            }
        }
    }

    # validating definition, but could validate value too
    if ($csg) {
        unless (($cfg->{vcs_csgnic}{all}) || ($nics>$#{$cfg->{systems}})) {
            $msg=Msg::new("vcs_csgnic is not correctly set for all systems");
            $msg->die;
        }
    }

    # check if it is single node configure/upgrade/start. Verify the value of VCS_ALLOWCOMMS in that case.
    if (Cfg::opt(qw(configure upgrade start)) && !Cfg::opt(qw(fencing configcps rootpath))) {
        if (!defined($cfg->{vcs_allowcomms})) {
            if (scalar(@{$cfg->{systems}}) == 1) {
                $msg=Msg::new("vcs_allowcomms must be set to 1 or 0 for a single node cluster configuration");
                $msg->die;
            } elsif (scalar(@{$cfg->{systems}}) > 1) {
                $cfg->{vcs_allowcomms} = 1;
            }
        }
    }
    if (Cfg::opt('rootpath')) {
        if (defined($cfg->{vcs_allowcomms})) {
            $msg=Msg::new("vcs_allowcomms is an invalid attribute for Live Upgrade");
            $msg->die;
        }
    }
    if (defined ($cfg->{fencingenabled}) &&
        ($cfg->{fencingenabled} != 0) &&
        ($cfg->{fencingenabled} != 1)) {
        $msg=Msg::new("fencingenabled has invalid value");
        $msg->die;
    }

    $pkg = $prod->pkg('VRTSvxfen61');
    $pkg->verify_responsefile_for_fencing() if ($cfg->{fencingenabled});
    return;
}

sub uninstall_precheck_sys {
    my ($vcs,$sys) = @_;
    my ($cprod,$prod);

    $cprod=CPIC::get('prod');
    $prod = $vcs->prod($cprod);
    for my $pkg (qw(VRTSat50 VRTSatClient50)) {
        next if ($pkg eq 'VRTSatClient50') && (!$sys->linux);
        unless (EDRu::inarr($pkg,@{$prod->{allpkgs}})) {
#            $prod->set_value('allpkgs','push',$pkg);
#            $pkg=Pkg->new_pkg($pkgi, $sys->{padv});
#            $pkg->set_value();
        }
    }
    return 1;
}

sub rollback_precheck_sys {
    my ($prod,$sys) = @_;
    my $had;
    # set $cfg->{vcs_allowcomms}
    $prod->set_vcs_allowcomms_sys($sys);
    $had = $sys->proc('had61');
    if ($had->check_sys($sys, 'start')) {
        $sys->set_value('prod_running',1);
    }
    my $amf = $sys->proc('amf61');
    if ($amf->check_sys($sys, 'start')) {
        $sys->set_value('amf_running',1);
    }
    # check if vcs has vaild configurations and could be upgrade
    $prod->check_upgradeable_sys($sys) unless ($sys->{vcs_upgradeable});
    if ($sys->{vcs_upgradeable}) {
        $prod->maincf_upgrade_precheck_sys($sys);
    } elsif ($sys->system1) {
        EDRu::create_flag('maincf_upgrade_precheck_done');
    }
    return;
}

sub hotfixupgrade_precheck_sys {
    my ($prod, $sys) = @_;

    # set $cfg->{vcs_allowcomms}
    $prod->set_vcs_allowcomms_sys($sys) if ($sys->system1);
    return;
}

sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($msg,$syslist,$had,$cpic,$cprod,$rootpath,$vcsinitfile,$rel,$answer,$vxfenconf,$cfg);

    $rel = Obj::rel();
    $cpic=Obj::cpic();
    $cfg = Obj::cfg();
    $syslist=CPIC::get('systems');
    $prod->upgrade_ru_check_sys($sys);
    $prod->check_cluster_members_sys($sys);
    # check if vcs has vaild configurations and could be upgrade
    $prod->check_upgradeable_sys($sys) unless ($sys->{vcs_upgradeable});
    # set $cfg->{vcs_allowcomms}
    $prod->set_vcs_allowcomms_sys($sys) if ($sys->system1);
    # check whether or not vxfen config files are valid or need to be updated.
    $prod->vxfen_upgrade_precheck_sys($sys);
    # check if AT50 should be deleted and if cluster is secure
    $prod->eat_upgrade_precheck_sys($sys) if $sys->system1;

    # check if VCS_START's are set to 1. If not on any sys, skip starting prod after upgrade
    $cprod=$cpic->prod();
    if (!$prod->check_prod_enabled_sys($sys)) {
        if (Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs))) {
            $vcsinitfile = $prod->{initfile}{vcs};
            $msg = Msg::new("Rolling upgrade cannot proceed because VCS_START is not set to 1 on $sys->{sys}. To perform rolling upgrade, VCS_START must be set to 1 in $vcsinitfile so that VCS processes can be started during upgrade");
            $sys->push_error($msg);
        } else {
            $msg = Msg::new("$cprod->{abbr} will not be started because VCS_START is not set to 1");
            $sys->push_warning($msg);
        }
        $cpic->set_value('prod_not_enabled_before_upgrade',1);
    }

    $rootpath=Cfg::opt('rootpath');
    if ($sys->exists("$rootpath/opt/VRTSvcs/bin/vcsenv") && $sys->padv->file_modified_sys($sys, '/opt/VRTSvcs/bin/vcsenv')) {
        $sys->cmd('_cmd_cat $rootpath/opt/VRTSvcs/bin/vcsenv');
        $sys->cmd('_cmd_rm -f $rootpath/opt/VRTSvcs/bin/vcsenv.backup');
        $sys->cmd('_cmd_cp $rootpath/opt/VRTSvcs/bin/vcsenv $rootpath/opt/VRTSvcs/bin/vcsenv.backup');
        if ($rootpath) {
            $msg=Msg::new("$rootpath/opt/VRTSvcs/bin/vcsenv was saved to $rootpath/opt/VRTSvcs/bin/vcsenv.backup on $sys->{sys} for ABE mounted on $rootpath. All the changes made in $rootpath/opt/VRTSvcs/bin/vcsenv for previous release of $cprod->{name} must be manually migrated into $rootpath/opt/VRTSvcs/bin/custom_vcsenv for 6.0 or later releases and this file must be owned by root user. After $rootpath/opt/VRTSvcs/bin/custom_vcsenv is created or modified, $cprod->{name} should be restarted for the changes to take effect");
        } else {
            $msg=Msg::new("/opt/VRTSvcs/bin/vcsenv was saved to /opt/VRTSvcs/bin/vcsenv.backup on $sys->{sys}. All the changes made in /opt/VRTSvcs/bin/vcsenv for previous release of $cprod->{name} must be manually migrated into /opt/VRTSvcs/bin/custom_vcsenv for 6.0 or later releases and this file must be owned by root user. After /opt/VRTSvcs/bin/custom_vcsenv is created or modified, $cprod->{name} should be restarted for the changes to take effect");
        }
        $sys->push_warning($msg);
    }

    # check for vcs status
    unless (Cfg::opt('rootpath')) {
        $had = $sys->proc('had61');
        if($had->check_sys($sys, 'start')) {
            $sys->set_value('prod_running',1);
        } else {
            if (!$cpic->{prod_not_enabled_before_upgrade} && $cpic->{prod} =~ /^VCS\d+/mx) {
                $cprod=$cpic->prod();
                $msg = Msg::new("$cprod->{abbr} will not be started because it is not running before an upgrade");
                $sys->push_warning($msg);
                $cpic->set_value('prod_not_running_before_upgrade',1);
            }
            if ($prod->{upgrade_ignore_conf}) {
                if ($sys->system1) {
                    EDRu::create_flag('maincf_upgrade_precheck_done');
                }

                Msg::log('Had is not running, but upgrade_ignore_conf is set. Skipping config updates.');
                return 1;
            } else {
                if ($sys->system1) {
                    EDRu::create_flag('maincf_upgrade_precheck_done');
                }

                $msg = Msg::new("$prod->{abbr} is not running before upgrade on $sys->{sys}. Make sure all the configurations are valid before upgrade.");
                $sys->push_warning($msg);
            }
        }
    }

    # check whether any upgrade issues for main.cf
    return 0 unless ($prod->maincf_upgrade_precheck_sys($sys));
    $prod->check_os_patch_sys($sys);

    # should prompt user to upgrade server first only once if cps based fencing 
    return 1 if (defined($cfg->{client_vxfen_warning}) && ($cfg->{client_vxfen_warning} == 1));
    # vxfen is upgraded in RU phase 1 hence no need to prompt waring in RU phase 2
    return 1 if (Cfg::opt(qw(upgrade_nonkernelpkgs)));
    $vxfenconf = $prod->get_vxfen_config_sys($sys);
    if ($vxfenconf->{vxfen_mechanism} && ($vxfenconf->{vxfen_mechanism} eq 'cps')) {
        $cfg->set_value('client_vxfen_warning', 1);
    }

    return 1;
}

sub mount_res_sys {
    my ($prod, $sys) = @_;
    my ($mounts,$mount,$res_mp,$res_sys,$block_devices,@block_devices,$bd);
    # check Mount resource for FS.pm
    my $vcsmainpkg=$prod->pkg($prod->{mainpkg});
    my $iv=$vcsmainpkg->version_sys($sys);
    return \@block_devices unless ($iv);
    my $had = $sys->proc('had61');
    if($had->check_sys($sys, 'start')) {
        $mounts = $sys->cmd('_cmd_hares -display -type Mount -attribute FSType');
        for my $mount (split(/\n+/,$mounts)) {
            next if ($mount =~ /^#/m);
            if ($mount =~ /\s*(\S+)\s+FSType\s+(\S+)\s+vxfs/mx) {
                $res_mp = $1;
                $res_sys = $2;
                my $sysname = $sys->{vcs_sysname};
                if (($res_sys eq $sysname) || ($res_sys eq $sys->{sys})
                    || ($res_sys eq 'global')) {
                    $block_devices = $sys->cmd("_cmd_hares -display $res_mp -attribute BlockDevice");
                    for my $bd (split(/\n+/,$block_devices)) {
                        if ($bd =~ /\s*$res_mp\s+BlockDevice\s+\S+\s+(\S+)/mx) {
                            push (@block_devices,$1);
                        }
                    }
                }
            }
        }
    }
    return \@block_devices;
}

sub cfsmount_res_sys {
    my ($prod, $sys) = @_;
    my ($mounts,@block_devices);
    # check Mount resource for FS.pm
    my $vcsmainpkg=$prod->pkg($prod->{mainpkg});
    my $iv=$vcsmainpkg->version_sys($sys);
    return \@block_devices unless ($iv);
    my $had = $sys->proc('had61');
    if($had->check_sys($sys, 'start')) {
        $mounts = $sys->cmd("_cmd_hares -display -type CFSMount -attribute BlockDevice 2>/dev/null | _cmd_sed -e '1d' 2>/dev/null | _cmd_awk '{print \$4}'");
        @block_devices = split(/\n/, $mounts);
    }
    return \@block_devices;
}

sub patchupgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($configured,$syslist,$had,$msg,$cpic,$cprod,$vcsinitfile);
    $cpic=Obj::cpic();
    $syslist=CPIC::get('systems');
    $prod->upgrade_ru_check_sys($sys);
    # set $cfg->{vcs_allowcomms}
    $prod->set_vcs_allowcomms_sys($sys) if ($sys->system1);
    # check whether or not vxfen config files need to be updated.
    $prod->vxfen_upgrade_precheck_sys($sys);
    if (!defined($sys->{prod_configured})) {
        $configured = $prod->check_config();
        $sys->set_value('prod_configured',1);
    }
    # check if VCS_START's are set to 1. If not on any sys, skip starting prod after upgrade
    $cprod=$cpic->prod();
    if (!$prod->check_prod_enabled_sys($sys) && $sys->{prod_configured}) {
        if (Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs))) {
            $vcsinitfile = $prod->{initfile}{vcs};
            $msg = Msg::new("Rolling upgrade cannot proceed because VCS_START is not set to 1 on $sys->{sys}. To perform rolling upgrade, VCS_START must be set to 1 in $vcsinitfile so that VCS processes can be started during upgrade");
            $sys->push_error($msg);
        } else {
            $msg = Msg::new("$cprod->{abbr} will not be started because VCS_START is not set to 1");
            $sys->push_warning($msg);
        }
        $cpic->set_value('prod_not_enabled_before_upgrade',1);
    }
    # check VCS running status
    $had = $sys->proc('had61');
    if ($had->check_sys($sys)) {
        $sys->set_value('prod_running',1);
    } else {
        if (!$cpic->{prod_not_enabled_before_upgrade} && $cpic->{prod} =~ /^VCS\d+/mx && $sys->{prod_configured}) {
            $cprod=$cpic->prod();
            $msg = Msg::new("$cprod->{abbr} will not be started because it is not running before upgrade");
            $sys->push_warning($msg);
            $cpic->set_value('prod_not_running_before_upgrade',1);
        }
    }
    return if (Cfg::opt('upgrade_kernelpkgs'));
    # check if vcs has vaild configurations and could be upgrade
    $prod->check_upgradeable_sys($sys) unless ($sys->{vcs_upgradeable});
    if ($sys->{vcs_upgradeable}) {
        $prod->maincf_upgrade_precheck_sys($sys);
    } elsif ($sys->system1) {
        EDRu::create_flag('maincf_upgrade_precheck_done');
    }

    $prod->check_os_patch_sys($sys);
    return;
}

sub precheck_task {
    my $prod = shift;
    my ($edr,$systems,$sysname,$sys0,$msg,$rtn,$max_async_secs);

    $systems=CPIC::get('systems');

    # set vcs_sysname for each system
    for my $sys (@{$systems}) {
        $sysname = $prod->get_vcs_sysname_sys($sys);
        $sys->set_value('vcs_sysname',$sysname);
    }

    if (Cfg::opt(qw(hotfixupgrade patchupgrade upgrade))) {
        $prod->phased_upgrade_precheck() unless (Cfg::opt('upgrade_kernelpkgs')||Cfg::opt('rootpath'));
        # Save VCS configuration upgrade logs
        EDR::register_save_logfiles("upgrade");
    }

    $prod->{time_async} = 0;
    if (Cfg::opt(qw(precheck configure install hotfixupgrade patchupgrade upgrade))) {
        $edr=Obj::edr();
        $max_async_secs=5;
        $rtn=$edr->check_timesync($systems,$max_async_secs);
        if ($rtn) {
            Msg::log("The time setting on the cluster nodes is already synchronized.");
        } else {
            $prod->{time_async} = 1;
            if (Cfg::opt(qw(precheck))) {
                $sys0=$systems->[0];
                $msg=Msg::new("Systems have difference in clock by more than $max_async_secs seconds");
                $sys0->push_warning($msg);
            }
        }
    }
    return 1;
}

sub post_precheck_task {
    my $prod = shift;
    my ($cpic,$cfg,$sys,$msg);

    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $sys=${$cpic->{systems}}[0];

    if (defined $cfg->{client_vxfen_warning}) {
        $msg = Msg::new("Before upgrading the client cluster to $prod->{vers}, you must ensure that all the CP servers that this client cluster uses as coordination points have been upgraded to $prod->{vers}. If CP servers are not upgraded before the client cluster upgrades, then I/O fencing will not be configured properly and will fail to start post upgrade.");
        $sys->push_warning($msg);
        $msg = Msg::new("Using Coordination Point server over HTTPS requires clock synchronization between the hosts. Make sure the time settings of the client cluster are synchronized with the Coordination Point servers.");
        $sys->push_warning($msg);
    }
    return 1;
}

sub phased_upgrade_precheck {
    my($cprod,$syslist,$csystems,$edr,$msg,$nsystems,$prod,$str,$sys1,$sysi,$obj_sysi,@sysnames,$vcs,$ver1,$veri,@no_comm_systems);
    $vcs = shift;

    $syslist=CPIC::get('systems');
    $cprod=CPIC::get('prod');
    $edr = Obj::edr();
    $prod = $vcs->prod($cprod);

    $sys1 = $syslist->[0];
    # Get number of systems from the main.cf
    $nsystems = $sys1->cmd("_cmd_grep '^system' $vcs->{maincf} 2> /dev/null | _cmd_wc -l");
    $csystems = scalar(@$syslist);
    Msg::log("Number of systems in main.cf = $nsystems");
    Msg::log("Number of systems provided = $csystems");

    if ($csystems < $nsystems) {
        $ver1 = $prod->version_sys($sys1);
        for my $sysi (@$syslist) {
            my $sysname = $sysi->{vcs_sysname};
            push (@sysnames, $sysname);
        }
        $str = $sys1->cmd("_cmd_grep '^system' $vcs->{maincf} 2> /dev/null");
        for my $sysi (split(/\n/,$str)) {
            next unless ($sysi =~ /^system\s+(\S+)\s*/mx);
            $sysi = $1;
            $sysi =~ s/"(.*)"/$1/m; # remove double quote
            unless (EDRu::inarr($sysi, @sysnames)) {
                $obj_sysi = Sys->new($sysi);
                if (!$edr->transport_sys($obj_sysi)) {
                    Msg::log("Cannot communicate with system $obj_sysi->{sys}\n");
                    push(@no_comm_systems,$obj_sysi->{sys});
                    next;
                }
                if (!EDRu::inarr($obj_sysi->{padv}, @{$edr->{padvs}})) {
                    Msg::log("The OS kernel release on system $obj_sysi->{sys} is not supported\n");
                    next;
                }

                $obj_sysi->pkgs_patches();
                $veri = $prod->version_sys($obj_sysi);
                if (EDRu::compvers($ver1,$veri,4) == 2) {
                    $msg = Msg::new("You are performing $prod->{prod} phased upgrade phase 2 on the systems. The second subcluster will be upgraded.");
                    $sys1->push_note($msg);
                    $vcs->{phased_upgraded_system} = $obj_sysi;
                    Cfg::set_opt('nostart', 1);
                    $vcs->{upgrade_ignore_conf}=1;
                    return '';
                }
            }
        }
        #e3412012:installer should prompt user no matter whether the cluster is security.
        if (scalar @no_comm_systems){
            my $no_comm_systems = join(',',@no_comm_systems);
            $msg = Msg::new("Could not communicate with system(s) $no_comm_systems. This upgrade may fail if phased upgrade phase 1 has been performed on these systems.\nProceed if you are sure that no phased upgrade has been started on these systems, or setup passwordless ssh connection with at least one of the phased upgraded systems and re-run this upgrade again.");
            $sys1->push_warning($msg);
        }
        $msg = Msg::new("You are performing $prod->{prod} phased upgrade phase 1 on the systems. The first subcluster will be upgraded.");
        $sys1->push_note($msg);
        Cfg::set_opt('nostart', 1);
        $vcs->{phased_upgrade_1}=1;
    } else {
        if (Cfg::opt('rolling_upgrade')) {
            Msg::log("$cprod Rolling Upgrade");
        } else {
            Msg::log("$cprod Full Upgrade");
        }
    }
    return '';
}


sub completion_messages {
    my ($prod)=@_;
    my ($cfg,$msg,$rel,$web);
    my ($syslist,$sys,$pkg,$msg_printed);
    $web = Obj::web();
    $rel = Obj::rel();
    if ($prod->{phased_upgrade_1}) {
        $msg = Msg::new("You are performing phased upgrade phase 1 on the systems. Follow the steps in installation guide to upgrade the remaining systems.");
        $msg->print;
        if (Obj::webui()){
            $web->web_script_form('alert', $msg);
        }
        return 1;
    }
    $prod->completion_message_rollingupgrade if(Cfg::opt(qw(upgrade_kernelpkgs upgrade_nonkernelpkgs)));
    if (Cfg::opt("configure")) {
        $cfg = Obj::cfg();
        if ($cfg->{fencingenabled} && (!$cfg->{donotreconfigurevcs}) && $prod->{fencing_config_pending}) {
            my $cprod = $prod->prod(CPIC::get('prod'));
            my $installscript= '/opt/VRTS/install/install' . (lc($cprod->{installscript_name} || $cprod->{prod})) . $rel->get_local_script_version_suffix();
            if ($rel->{nowebinstaller}) {
                $msg = Msg::new("I/O fencing configuration is not complete. You can run the command '$installscript -fencing' to configure it.\n");
            } else {
                $msg = Msg::new("I/O fencing configuration is not complete. You have two ways to configure I/O fencing:\n    1. Run the command '$installscript -fencing'.\n    2. Select the I/O fencing configuration task while running the webinstaller.\n");
            }
            $msg->print;
            $web->web_script_form('alert', $msg) if (Obj::webui());
        }
    }
    return 1;
}

sub completion_message_rollingupgrade {
    my ($prod)=@_;
    my ($sys,$rel,$cpic,$edr,$msg,@subs,@systems,$cfg,$ayn,$web,$webmsg);
    my ($showrup1list,@rup1list,@rup2list,$success,$localsys,$tmpdir);
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    $cfg=Obj::cfg();
    $web = Obj::web();
    $localsys=Obj::localsys();
    $tmpdir=EDR::tmpdir();
    if(Cfg::opt('upgrade_nonkernelpkgs')) {
        $success=1;
        for my $sysname (@{$rel->{cluster_systems}}) {
            $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
            if ((defined ($sys->{pkginstallfail}) && @{$sys->{pkginstallfail}}) ||
                (defined ($sys->{patchinstallfail}) && @{$sys->{patchinstallfail}})) {
                $success=0;
                last;
            }
        }
        $success=0 if ($success && @{$cpic->failures('startfailmsg')});
        if ($success) {
            $msg=Msg::new("Rolling Upgrade has been successfully completed on the cluster.");
            $msg->bold;
            $web->web_script_form('alert', $msg) if (Obj::webui());
            return 1;
        } else {
            $msg=Msg::new("Rolling Upgrade did not complete successfully on the cluster.");
            $msg->bold;
            $web->web_script_form('alert', $msg) if (Obj::webui());
            return 0;
        }
    }
    @subs = qw(systems set_pkgs shutdown uninstall install licensing prestart_config startup);
    for my $sysname (@{$rel->{cluster_systems}}) {
        $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
        if($rel->determine_ru_phase_sys($sys) == 1){
            push(@rup1list,$sysname);
        } else {
            push(@rup2list,$sysname);
        }
    }
    if(@rup1list && @rup2list) {
        if(@{$cpic->{reboot_systems}}){
            $showrup1list = join(' ', @rup1list);
            $msg=Msg::new("It is recommended to perform rolling upgrade phase 1 on the systems $showrup1list in the next step. Rerun the installer to do this after reboot\n");
            $msg->bold;
            $web->web_script_form('alert', $msg) if (Obj::webui());
            return;
        } else {
            my $sclist = $rel->ask_usr_ru1ru2(\@rup1list,\@rup2list);
            if($sclist) {
                $rel->{nextrusys}=join(' ', @{$sclist});
                $web->{systemlist}=join(' ', @{$sclist});
                $cfg->{systems}=$sclist;
                $rel->{noruconfirm}=1;
                # remove previous flags under EDR::tmpdir();
                for my $file (@{$edr->{file_flags}}) {
                    $localsys->rm("$tmpdir/$file");
                }
                delete $edr->{file_flags} if ($edr->{file_flags} && @{$edr->{file_flags}});
                $cpic->set_task("upgrade");
                $cpic->run_subs(@subs,'completion');
            }
        }
    }
    if(!@rup1list && @rup2list) {
        if(@{$cpic->{reboot_systems}}){
            $msg=Msg::new("It is recommended to perform rolling upgrade phase 2 on all the cluster systems in the next step. Rerun the installer to do this after reboot");
            $msg->bold;
            $web->web_script_form('alert', $msg) if (Obj::webui());
            return;
        } else {
            my $sclist = $rel->ask_usr_ru2(\@rup2list);
            if($sclist) {
                $rel->{nextrusys}=join(' ', @{$sclist});
                $web->{systemlist}=join(' ', @{$sclist});
                $cfg->{systems}=$sclist;
                $rel->{noruconfirm}=1;
                # remove previous flags under EDR::tmpdir();
                for my $file (@{$edr->{file_flags}}) {
                    $localsys->rm("$tmpdir/$file");
                }
                $cpic->set_task("upgrade");
                foreach my $sysn(@rup2list){delete $Obj::pool{"Sys::$sysn"};}
                delete $cpic->{installpkgslast};
                delete $edr->{file_flags} if ($edr->{file_flags} && @{$edr->{file_flags}});
                $cpic->run_subs(@subs,'completion');
            }
        }
    }
    return;
}

sub check_cluster_members_sys {
    my ($prod,$sys) = @_;
    my ($m,$cprod,$msg,$sys0,$n,$syslist,$conf,$cpic);
    $cpic=Obj::cpic();
    $syslist=CPIC::get('systems');
    $cprod=CPIC::get('prod');
    $conf = $prod->get_config_sys($sys);
    if ($conf) {
        if ($sys->system1) {
            $m = scalar(@{$conf->{systems}});
            $n = scalar(@$syslist);
            return 1 if($m == $n);
            if ( $m < $n) {
                $msg = Msg::new("The entered systems belong to different clusters. Only the members of the same cluster can be upgraded as a whole.");
                $sys->push_error($msg);
            } elsif ($m > $n) {
                return 1 unless ($cprod eq 'VCS61' || $cprod eq 'SFHA61');
                $msg = Msg::new("Not all the members of the cluster, $conf->{clustername}, are included in this upgrade. Symantec recommends that you upgrade all the members of the cluster together, unless you plan to perform a phased upgrade for the cluster.");
                $sys->push_warning($msg) unless(Cfg::opt("upgrade_kernelpkgs"));
            }
        } else {
            $sys0 = $$syslist[0];
            $conf = $prod->get_config_sys($sys0);
            return 0 unless ($conf);
            return 1 if(EDRu::inarr($sys->{sys},@{$conf->{systems}}));
            my $sysname = $sys->{vcs_sysname};
            return 1 if(EDRu::inarr($sysname, @{$conf->{systems}}));
            $msg = Msg::new("$sys->{sys} does not belong to the cluster, $conf->{clustername}. Only the members of the same cluster can be upgraded as a whole.");
            $sys->push_error($msg);
        }
    } else {
        $msg = Msg::new("Cannot find valid $prod->{abbr} configuration information on $sys->{sys}");
        $sys->push_warning($msg);
        $cpic->set_value('prod_not_running_before_upgrade',1);
    }
    return 0;
}

sub vxfen_reuse_precheck {
    my ($prod)=shift;
    my (@cps,$clusname,$conf,$cpsadm,$cpspkg,$cpssys,$failed,$out,$usefence,$uuid,$vxfenconf,$vxfenpkg);
    my ($msg,$sys,$web);
    $web = Obj::web();
    $sys = ${CPIC::get('systems')}[0];
    $cpspkg = $prod->pkg('VRTScps61');
    $vxfenpkg = $prod->pkg('VRTSvxfen61');
    $cpsadm = $cpspkg->{cpsadm};

    return 1 unless ($sys->exists("$prod->{vxfenmode}"));
    $vxfenconf = $prod->get_vxfen_config_sys($sys);
    return 1 unless ($vxfenconf->{vxfen_mechanism} =~ /cps/m);
    Msg::log("Checking client cluster registration info on the CP servers...");
    for my $cpsname (@{$vxfenconf->{cps}}) {
        $cpssys = $vxfenpkg->create_cps_sys($cpsname);
        # Check if we can communicate with cps
        if (!$vxfenpkg->cps_transport_sys($cpssys)) {
            $msg=Msg::new("Cannot communicate with system $cpssys->{sys} which was found to be a Coordination Point server. Fencing may not start successfully if reusing currrent configuration.");
            $msg->warning;
            Msg::n();
            $web->web_script_form('alert',$msg) if (Obj::webui());
            $failed = 1;
            last;
        }
        push (@cps,$cpssys);
    }
    $conf = $prod->get_config_sys($sys);
    $clusname = $conf->{clustername};
    $uuid = $vxfenconf->{uuid};
    $out = $sys->cmd("_cmd_grep 'UseFence' $prod->{maincf} 2> /dev/null");
    if ($out =~ /UseFence\s+=\s+SCSI3/mx) {
        $usefence = 1;
    }
    if (!$failed) {
        for my $cpsi(@cps) {
            $out = $cpsi->cmd("$cpsadm -s $cpsi->{sys} -a list_nodes -p $vxfenconf->{cpport}{$cpsi->{sys}} |  _cmd_grep '$uuid' | _cmd_grep -w '$clusname'");
            if (EDR::cmdexit() || $out eq '') {
                $msg=Msg::new("Failed to find registration information on Coordination Point server $cpsi->{sys}. Fencing may not start successfully if reusing currrent configuration.");
                $msg->warning;
                Msg::n();
                $web->web_script_form('alert',$msg) if (Obj::webui());
                $failed = 1;
            }
        }
    }
    if ($failed && $usefence) {
        $msg = Msg::new("VCS may not start successfully since 'UseFence = SCSI3' is set in main.cf. Fix the fencing issues first or reconfigure the cluster.");
        $msg->warning;
        Msg::n();
        $web->web_script_form('alert',$msg) if (Obj::webui());
        return 0;
    }
    return 1;
}

sub vxfen_upgrade_precheck_sys {
    my ($prod,$sys)=@_;
    my ($conf,$configured,$msg);
    my $rootpath = Cfg::opt('rootpath') || '';
    if (Cfg::opt(qw(patchupgrade hotfixupgrade))) {
        if (!defined($sys->{prod_configured})) {
            $configured = $prod->check_config();
            $sys->set_value('prod_configured',$configured);
        }
        return 1 if (!$sys->{prod_configured});
    }
    if ($sys->exists("$rootpath$prod->{vxfenmode}")) {
        $conf=$prod->get_vxfen_config_sys($sys);
        $sys->set_value('vxfen_conf,vxfendg',$conf->{vxfendg});
        if (($conf->{vxfen_mode} !~ /^(disabled|customized)$/mx) &&
            (!$sys->exists("$rootpath$prod->{vxfendg}"))) {
                $msg=Msg::new("Vxfen may fail to start on $sys->{sys} after upgrade due to missing $rootpath$prod->{vxfendg}");
                $sys->push_warning($msg);
        }

        # check if openssl is installed
        if ($conf->{vxfen_mechanism} && ($conf->{vxfen_mechanism} eq 'cps')) {
            return 1 unless $prod->https_cpc_check_openssl_sys($sys);
        }
    } else {
        if($sys->exists("$rootpath$prod->{vxfendg}")) {
            $sys->set_value('vxfen_conf,vxfendg',1);
            $msg = Msg::new("Vxfen will use dmp disk policy by default after upgrade since $rootpath$prod->{vxfenmode} does not exist on $sys->{sys}");
            $sys->push_warning($msg);
        }
    }
    return 1;
}

sub get_vxfen_config_sys {
    my ($prod,$sys)=@_;
    my ($line,$str);
    my ($conf,$cps_sys1,$cpsvip,$defport,$order,$port,$sys1_flag,$uuid);
    my $vrtscps_pkg = $prod->pkg('VRTScps61');
    my $rootpath = Cfg::opt('rootpath') || '';

    $conf = {};
    $conf->{security} = '-1';
    $defport = $vrtscps_pkg->{default_https_port};
    $conf->{vxfen_mode} = $conf->{scsi3_disk_policy} = $conf->{vxfen_mechanism} = '';
    $conf->{cps} = [];
    $conf->{cpport}= {};
    $order = 1;

    $str=$sys->cmd("_cmd_cat $rootpath$prod->{vxfenmode} 2> /dev/null");

    # First get default port
    if ($str=~/^port\s*=\s*(\d+)\s*$/m) {
        $defport=$1;
    }

    for my $line (split(/^/m,$str)) {
        $line=EDRu::despace($line);
        next if ((!$line) || ($line=~/^#/m));
        if ($line=~/^\s*vxfen_mode\s*=\s*(\w+)/mx) {
            $conf->{vxfen_mode}=$1;
        } elsif ($line=~/^\s*scsi3_disk_policy\s*=\s*(\S+)/mx) {
            $conf->{scsi3_disk_policy}=$1;
        } elsif ($line=~/^\s*vxfen_mechanism\s*=\s*(\S+)/mx) {
            $conf->{vxfen_mechanism}=$1;
        } elsif ($line =~ /^\s*vxfendg\s*=\s*(\S+)/mx) {
            $conf->{vxfendg}=$1;
            $conf->{cporder}{$order} = $conf->{vxfendg};
            $order++;
        } elsif ($line =~ /^\s*security\s*=\s*(\d+)/mx) {
            $conf->{security} = $1;
        } elsif ($line =~ /^\s*fips_mode\s*=\s*(\d+)/mx) {
            # the fips_mode is new added during 6.0.1, it could be 1 or 0
            $conf->{fips_mode}=$1;
        } elsif ($line =~ /^\s*cps(\d+)\s*=\s*\[(.+)\]/mx) {
            $sys1_flag = 1;
            $conf->{cporder}{$order} = $line;
            $order++;
            for my $item(split(/,/,$line)) {
                ($cpsvip, $port) = split(/:/, $item);
                if ($cpsvip =~ /\[(.+)\]/m) {
                    $cpsvip = $1;
                    $cpsvip = EDRu::despace($cpsvip);
                    last if (!$cpsvip);
                    $cps_sys1 = $cpsvip if ($sys1_flag);
                } else {
                    last;
                }
                $conf->{cpport}{$cpsvip} = ($port) ? $port : $defport;
                push (@{$conf->{cps}}, $cpsvip) if ($sys1_flag);
                push (@{$conf->{vips}{$cps_sys1}}, $cpsvip);

                $sys1_flag = 0;
            }
        } elsif ($line =~ /^\s*vxfen_honor_cp_order\s*=\s*(\d+)/mx) {
            $conf->{vxfen_honor_cp_order}=$1;
        }
    }

    if ($conf->{vxfen_mode} =~ /(scsi3|sybase)/m) {
        $str = $sys->cmd("_cmd_cat $rootpath$prod->{vxfendg} 2> /dev/null");
        chomp ($str);
        $conf->{vxfendg} ||= $str;
    }

    $uuid = $prod->get_uuid_sys($sys);
    if (($uuid) && ($uuid !~ /NO_UUID/m)) {
        $conf->{uuid}=$uuid;
    }

    return $conf;
}

# get coordination information from output of command 'vxfenconfig -l'
sub get_vxfen_config_from_driver_sys {
    my ($prod,$sys)=@_;
    my ($line,$str);
    my (@uids,$conf,$cpoint,$cp_uid,$order);
    my ($count,$disk_index,$first_disk);

    $conf = {};
    $conf->{security} = '-1';
    $order = 0;

    $str = $sys->cmd("_cmd_vxfenconfig -l 2> /dev/null");
    for my $line (split(/^/m,$str)) {
        $line=EDRu::despace($line);
        next if ((!$line) || ($line =~ /^#/m) || ($line =~ /(^=|Fencing)/m));
        chomp($line);
        if ($line =~ /^\s*security\s*=\s*(\d+)/mx) {
            $conf->{security} = $1;
        } elsif ($line =~ /^\s*fips_mode\s*=\s*(\d+)/mx) {
            $conf->{fips_mode} = $1;
        } elsif ($line =~ /^\s*single_cp\s*=\s*(\d+)/mx) {
            $conf->{single_cp} = $1;
        } else {
            ($cpoint,$cp_uid) = split(/\s+/,$line,2);
            # in case uid has more than one field
            # eg: /dev/vx/rdmp/disk_11  HITACHI D60068340356
            $cp_uid =~ s/\s+//g;
            next if (!$cp_uid);
            if (!$conf->{cpoint}{"$cp_uid"}) {
                # coord piont with unique id
                $uids[++$order] = $cp_uid;
                push (@{$conf->{cpoint}{"$cp_uid"}},$cpoint);
            } else {
                # cp may have duplicate id due to multi vip and multi-path disk
                # save all multi vip but not save other multi-path disk
                push (@{$conf->{cpoint}{"$cp_uid"}},$cpoint) if ($cpoint =~ /\[/);
            }
        }
    }
    $count = 1;
    $first_disk = 1;
    for my $i(1..$#uids) {
        $cp_uid = $uids[$i];
        if (grep (/\/dev/,@{$conf->{cpoint}{"$cp_uid"}})) {
            # merge all the disks to one entry since we cannot reorder the disks
            if (!$first_disk) {
                $conf->{cporder}{$disk_index} .= ',' . join(',', @{$conf->{cpoint}{"$cp_uid"}});
                next;
            }
            $disk_index = $i;
            $first_disk = 0;
            $conf->{cporder}{$count++} = join(',', @{$conf->{cpoint}{"$cp_uid"}});
        } else {
            # cps entry
            $conf->{cporder}{$count++} = join(',', @{$conf->{cpoint}{"$cp_uid"}});
        }
    }

    return $conf;
}

sub get_vcs_sysname_sys {
    my ($prod,$sys) = @_;
    my (@systems,$maincf,$n,$rootpath,$str,$sysname,$system);
    $rootpath = Cfg::opt('rootpath');
    $maincf = "$rootpath$prod->{maincf}";
    $sysname = transform_system_name($sys->{sys});
    return $sysname if (!$prod->get_config_sys($sys));
    $str = $sys->cmd("_cmd_grep '^system' $maincf 2> /dev/null");
    for my $line(split(/\n/,$str)) {
        if ($line =~ /system\s+(\S+)/m) {
            $system = $1;
            $system =~ s/"(.*)"/$1/m; # remove double quote
            push (@systems,$system);
            $n ++;
        }
    }
    return $sysname if (!$n);
    if (1 == $n) {
        # get vcs sysname by main.cf if single node
        return $systems[0];
    } else {
        # get vcs sysname by llttab
        $str = $sys->cmd("_cmd_grep 'set-node' $rootpath$prod->{llttab} 2> /dev/null");
        for my $line(split(/\n/,$str)) {
            if ($line =~ /^\s*set-node\s+(\S+)/m) {
                $system = $1;
                $system =~ s/"(.*)"/$1/m; # remove double quote,just in case
                if ($system =~ /\//mx && $sys->exists($system)){
                    # filename as set-node arg
                    $system = $sys->readfile($system,1);
                    chomp $system;
                    $system = EDRu::despace($system);
                    $system =~ s/"(.*)"/$1/m;
                    # use the first word from the file as sysname
                    $system =~ s/(\S+).*/$1/;
                } elsif ($system =~ /^(\d+)$/mx) {
                    # nodeid as set-node arg
                    # search the name in /etc/llthosts
                    $str = $sys->cmd("_cmd_grep '^$system ' $rootpath$prod->{llthosts} 2> /dev/null");
                    if ($str =~ /^$system\s+(\S+)/mx) {
                        $system = $1;
                    }
                }
                return $system;
            }
        }
    }
    return $sysname;
}

sub maincf_upgrade_precheck_sys {
    my ($prod,$sys,$vcsvers) = @_;
    my ($rootpath,$vcspkg,$msg,$unfreeze_sg,$grp,@grp_syslist,$cmd_hacf,@grps,$delete_cmc,$treeref_olduser,@extra_types,$attrs,$vxss_autostartlist,$upgradepath,$sfua_delete_SfuaBase,$line,$rtn,$delete_VCSweb,$grp_syslists,$vxss_add_autostartlist);

    $rootpath = Cfg::opt('rootpath') || '';
    $upgradepath= EDR::tmpdir().'/upgrade';
    $cmd_hacf = $prod->{cmd_hacf};

    # Use hacf on ABE only if the OS on PBE is same with ABE.
    if ($rootpath) {
        my @uname = split(/\s+/m,$sys->{uname});
        if ($sys->{platvers} eq $uname[2]) {
            $cmd_hacf= "$rootpath$prod->{bindir}/hacf";
            $prod->set_value('cmd_hacf',$cmd_hacf);
        } else {
            $sys->set_value('osupgraded',1);
        }
    }

    if ($sys->system1) {
        # dump vcs configuraton
        if (!Cfg::opt('rootpath') && !$prod->{upgrade_ignore_conf} && $sys->{prod_running}) {
            $prod->haconf_makerw();
            $prod->haconf_dumpmakero();
        }

        if (!$vcsvers) {
            $vcspkg=$prod->pkg('VRTSvcs61');
            $vcsvers=$vcspkg->version_sys($sys) if (defined $vcspkg);
        }

        unless ($prod->dynupgrade_pre_upgrade_sys($sys,$vcsvers)) {
            EDRu::create_flag('maincf_upgrade_precheck_done');
            return 0;
        }

        # create cmd list
        $treeref_olduser = dynupgrade_import_file2tree_sys($sys, "$rootpath$prod->{configdir}/main.cmd");

        $prod->maincf_check_TriggerResStateChange_sys($sys,$treeref_olduser,$vcsvers);

        # Update PreOnline attribute.
        $prod->maincf_preonline_precheck_sys($sys,$treeref_olduser,$vcsvers);

        # vip will only bu updated for upgrade from less6.0 to 6.0 onwards
        $prod->maincf_precheck_if_update_vip_sys($sys,$vcsvers);

        # Change sourcefile path for types/service groups to config dir
        modify_sourcefile_sys($sys,$treeref_olduser,'GRP');
        unless ($prod->dynupgrade_pre_customize_changed_types_sys($sys,$treeref_olduser,$upgradepath)) {
            EDRu::create_flag('maincf_upgrade_precheck_done');
            return 0;
        }
        my $sourcefiles= modify_sourcefile_sys($sys,$treeref_olduser,'TYPE');
        dynupgrade_export_tree2file_sys( $sys, "$upgradepath/old_config/main.cmd", $treeref_olduser);
        $prod->translate_file_cmd2cf_sys( $sys, "$upgradepath/old_config");

        # Copy types for VRTSvcsea and VRTSdbac to old_conf;
        my ($extra_type,$extra_type_base,$pkg,$pkgi);
        for my $pkgi (qw(VRTSvcsea61 VRTSdbac61)) {
            $pkg = $prod->pkg($pkgi,1);
            next unless (defined $pkg);
            push (@extra_types,@{$pkg->{extra_types}});
        }
        for my $extra_type (@extra_types,@{$prod->{extra_types}}) {
            $extra_type_base = EDRu::basename($extra_type);
            if (EDRu::inarr($extra_type_base, @{$sourcefiles})) {
                $sys->cmd("_cmd_cp $upgradepath/old_config/$extra_type_base $upgradepath/old_conf")
                    unless ($sys->exists("$upgradepath/old_conf/$extra_type_base"));
                $sys->set_value("maincf_include,$extra_type_base", $extra_type_base);
            }
        }

        unless ($prod->maincf_check_obsolete_types_sys($sys,$treeref_olduser,$vcsvers)) {
            EDRu::create_flag('maincf_upgrade_precheck_done');
            return 0;
        }

        my $panic_system_on_dg_loss_attr = dynupgrade_get_attrvalue_of_typename($treeref_olduser,'DiskGroup','PanicSystemOnDGLoss');
        if ($panic_system_on_dg_loss_attr eq '1') {
            my @reslist=dynupgrade_get_resname_list_from_typename($treeref_olduser, 'DiskGroup');
            if (@reslist) {
                $msg = Msg::new("The default value of the DiskGroup agent attribute, PanicSystemOnDGLoss, will be changed from 1 to 0 after an upgrade. Refer to the Symantec Cluster Server Bundled Agents Reference Guide for the implications of this change.");
                $sys->push_warning($msg);
            }
        }

        $prod->maincf_upgrade_cvm_cfs_types_sys($sys,$treeref_olduser,$vcsvers);

        @grps=dynupgrade_get_grplist($treeref_olduser);

        # Add AutoStartList to VxSS Service Group if it is not defined.
        if (EDRu::inarr('VxSS',@grps)) {
            $vxss_autostartlist = dynupgrade_get_attr_from_tree($treeref_olduser,'GRP','VxSS','AutoStartList');
            unless ($vxss_autostartlist) {
                @grp_syslist = dynupgrade_get_systemlist_of_grpname($treeref_olduser,'VxSS');
                $grp_syslists = join (' ', @grp_syslist);
                $vxss_add_autostartlist = "hagrp -modify VxSS AutoStartList $grp_syslists";
                $sys->set_value('maincf_upgrade,21_vxss_add_autostartlist', $vxss_add_autostartlist);
            }
        }

        # Update DNS ResRecord.
        my $dns_resrecord = dynupgrade_modify_attr_value_DNS($treeref_olduser);
        if ($dns_resrecord) {
            $sys->set_value('maincf_upgrade,30_dns_resrecord', $dns_resrecord);
        }

        #remove service group.
        #Add 99_ prefix to make sure the delete operation is added to the end.
        $sfua_delete_SfuaBase='hagrp -delete Sfua_Base';
        $sys->set_value('maincf_upgrade,99_sfua_delete_SfuaBase', $sfua_delete_SfuaBase);
        $delete_cmc='hagrp -delete CMC';
        $sys->set_value('maincf_upgrade,99_delete_CMC', $delete_cmc);

        $delete_VCSweb='hares -delete VCSweb';
        $sys->set_value('maincf_upgrade,99_delete_VCSweb', $delete_VCSweb);

        $prod->padv_maincf_upgrade_precheck_sys($sys,$treeref_olduser,$vcsvers);
        $prod->padv_maincf_update_netmask_sys($sys,$treeref_olduser,$vcsvers);

        EDRu::create_flag('maincf_upgrade_precheck_done');
    } else {
        EDRu::wait_for_flag('maincf_upgrade_precheck_done');
    }
    return 1;
}

# run padv specific upgrade precheck for main.cf
sub padv_maincf_upgrade_precheck_sys {
    return;
}

# Update netmask for Solaris and HP-UX.
# It is overwritten on Linux, and it is not needed on AIX.
sub padv_maincf_update_netmask_sys {
    my ($prod,$sys,$treeref,$vcsvers) = @_;
    my ($attrref_netmask,$addressref,$address,$address_name,$netmask,$netmask_setting,$noderef,$type);
    my ($type_list,@reslist);

    # For IP resources
    $type_list = [ qw(IP MultiNICA IPMultiNIC IPMultiNICB) ];
    @reslist = Prod::VCS61::Common::dynupgrade_get_resname_list_from_typename_list($treeref, $type_list);
    for my $res (@reslist) {
        $noderef = Prod::VCS61::Common::dynupgrade_get_node_from_tree($treeref, 'RES', $res);
        $type = $noderef->{MAIN}->{RESTYPE};
        # For MultiNICA agent, Address value is specified in the Device attribute;
        # for other agents, Address value is specified in the Address attribute.
        if ($type eq "MultiNICA") {
            $address_name = "Device";
        } else {
            $address_name = "Address";
        }
        $attrref_netmask = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'NetMask');
        if (!$attrref_netmask) {
            $addressref = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', $address_name);
            $address = $addressref->{MODIFY}->{ATTRVAL}->[0];
            $address =~ s/.*"(.*)"/$1/m;
            # For Solaris, we need to check if netmask is defined in OS netmask database
            $netmask = $prod->get_netmask_by_address_from_netmasks_sys($sys,$address);
            if (!$netmask) {
                $netmask = $prod->get_netmask_by_address($address);
            }
            $netmask_setting .= "hares -modify $res NetMask \"$netmask\"\n";
        }
    }

    $sys->set_value('maincf_upgrade,22_netmask_setting', $netmask_setting);
    return;
}

# Get netmask from OS netmask database. This is overwritten on Solaris.
sub get_netmask_by_address_from_netmasks_sys {
    my ($prod,$sys,$address) = (@_);
    return "";
}

sub get_netmask_by_address {
    my ($prod,$address,$netmask);
    ($prod,$address) = (@_);
    $address =~ s/\..*$//m;
    $netmask = ($address<128) ? '255.0.0.0' :
        ($address<192) ? '255.255.0.0' :
        ($address<224) ? '255.255.255.0' :
        '255.0.0.0';
    return $netmask;
}

sub maincf_check_TriggerResStateChange_sys {
    my ($prod,$sys,$treeref) = @_;
    my ($grpref,@grps,$grp_triggers,@grp_triggers,$msg,@msgs,$res,$resref,$res_triggers,@res_triggers,$trigger,$triggerref);
    @grps = dynupgrade_get_grplist($treeref);
    for my $grp (@grps) {
        next unless $grp;
        $grpref = $treeref->{GRP}->{$grp};
        $triggerref = $grpref->{ATTR}->{TriggerResStateChange};
        if (defined $triggerref) {
            $trigger = $triggerref->{MODIFY}->{ATTRVAL}->[0];
            if ($trigger) {
                push (@grp_triggers, $grp);
            }
        }
    }
    my $branchref= dynupgrade_get_branch_from_tree( $treeref, 'RES');
    for my $res ( keys %{$branchref} ) {
        # get each resource node and main command
        $resref= dynupgrade_get_node_from_branch( $branchref, $res);
        $triggerref = $resref->{ATTR}->{TriggerResStateChange};
        if (defined $triggerref) {
            $trigger = $triggerref->{MODIFY}->{ATTRVAL}->[0];
            if ($trigger) {
                push (@res_triggers, $res);
            }
        }
    }
    $grp_triggers = join (' ',@grp_triggers);
    $res_triggers = join (' ',@res_triggers);
    if ($grp_triggers || $res_triggers) {
        $msg = Msg::new("The installer has detected that resstatechange trigger is configured by setting TriggerResStateChange attributes. The trigger may get invoked in the event of restarting of resources. In future releases, resstatechange trigger will not be invoked when a resource is restarted. Instead, resrestart trigger will be invoked if TriggerResRestart attribute is set. The resrestart trigger is available in the current release too. Refer to the VCS documentation for details.\n");
        push(@msgs,$msg);
    }
    if ($grp_triggers) {
        $msg = Msg::new("The following service groups have TriggerResStateChange configured: $grp_triggers\n");
        push(@msgs,$msg);
    }
    if ($res_triggers) {
        $msg = Msg::new("The following resources have TriggerResStateChange configured: $res_triggers\n");
        push(@msgs,$msg);
    }
    if (scalar @msgs) {
        $sys->push_warning(@msgs);
    }

    return;
}

# Update PreOnline attribute from service group level to system level.
sub maincf_preonline_precheck_sys {
    my ($prod,$sys,$treeref,$vcsvers) = @_;
    my ($msg,@grps,$grpref,$preonlineref,$preonline_cmd,@syslist,$preonline);

    # Check PreOnline setting in main.cf
    if ($vcsvers && (EDRu::compvers($vcsvers,'5.1') == 2)) {
        Msg::log('Checking the PreOnline setting informations');

        # get group list
        @grps = dynupgrade_get_grplist($treeref);
        for my $grp_name (@grps) {
            next unless ($grp_name);
            $preonline_cmd = '';
            $preonline = '';
            $grpref = $treeref->{GRP}->{$grp_name};
            $preonlineref = $grpref->{ATTR}->{PreOnline};
            if (defined $preonlineref) {
                $preonline = $preonlineref->{MODIFY}->{ATTRVAL}->[0];
                if ($preonline) {
                    # Modify PreOnline to 0
                    Msg::log("Changing PreOnline to 0 in Group $grp_name");
                    $preonlineref->{MODIFY}->{ATTRVAL}->[0] = 0;
                    @syslist = dynupgrade_get_systemlist_of_grpname($treeref,$grp_name);
                    for my $sysi (@syslist) {
                        $preonline_cmd .= "hagrp -modify $grp_name PreOnline $preonline -sys $sysi\n";
                    }
                    if ($preonline_cmd) {
                        Msg::log("Preonline setting: $preonline_cmd");
                        $sys->set_value("maincf_upgrade, 40_preonline_$grp_name", $preonline_cmd);
                    }
                }
            }
        }
    }
    return 1;
}

sub maincf_precheck_if_update_vip_sys {
    my ($prod,$sys,$vcsvers) = @_;

    return '' unless $vcsvers;

    $sys->set_value("update_vip_sgs", 1) if (EDRu::compvers($vcsvers,'6.0') == 2);
    $sys->set_value("update_NFSRestart", 1) if (EDRu::compvers($vcsvers,'5.1.100') == 2);
    $sys->set_value("upgrade_TriggersEnabled", 1) if (EDRu::compvers($vcsvers,'6.0') == 2);

    return 1;
}

sub maincf_upgrade_cvm_cfs_types_sys {
    my ($prod,$sys,$treeref_olduser,$vcsvers) = @_;
    my ($attr_node,$cfsmount_attr,$type_node,$attr_name,$type_name,$rtn,$cvmvoldg_reglist,$cvmvoldg_arglist);
    my ($cvmcluster_reglist,$cvmcluster_attr,$cvmcluster_arglist);

    # Update CFSMount
    # Add AMFMountType as a attr to CFSMount in 5.1SP1
    $type_name = 'CFSMount';
    if ($type_node = dynupgrade_get_node_from_tree( $treeref_olduser, 'TYPE', $type_name)) {
        $attr_name = 'AMFMountType';
        $attr_node = dynupgrade_get_node_from_tree( $type_node, 'ATTR', $attr_name);
        # do nothing if AMFMountType already exist
        unless ($attr_node) {
            $cfsmount_attr = 'haattr -add -temp CFSMount AMFMountType -string';
            $sys->set_value('maincf_upgrade,10_cfsmount_add', $cfsmount_attr);
        }
    }

    # Update CFSMount
    # Add Primary to ArgList in CFSMount in 5.1
    # Add AMFMountType to ArgList in CFSMount in 5.1SP1
    $rtn = dynupgrade_get_attrvalue_of_typename($treeref_olduser,'CFSMount','ArgList');
    if ($rtn) {
        $rtn .= ' Primary' if ($rtn!~/Primary/m);
        $rtn .= ' AMFMountType' if ($rtn!~/AMFMountType/m);
        $cfsmount_attr="hatype -modify CFSMount ArgList $rtn";
        $sys->set_value('maincf_upgrade,10_cfsmount_attr', $cfsmount_attr);
    }

    # Update CVMVolDg
    # Add CVMVolume to RegList in CVMVolDg in 5.1
    $rtn = dynupgrade_get_attrvalue_of_typename($treeref_olduser,'CVMVolDg','RegList');
    if ($rtn) {
        $rtn .= ' CVMVolume' if ($rtn!~/CVMVolume/m);
        $cvmvoldg_reglist="hatype -modify CVMVolDg RegList $rtn";
        $sys->set_value('maincf_upgrade,11_cvmvoldg_reglist', $cvmvoldg_reglist);
    }
    # Add CVMVolumeIoTest, CVMDGAction to ArgList in CVMVolDg in 5.1
    # Add CVMDeportOnOffline to ArgList in CVMVolDg in 5.1SP1
    # Add CVMDeactivateOnOffline to ArgList in CVMVolDg in 6.0.1
    $rtn = dynupgrade_get_attrvalue_of_typename($treeref_olduser,'CVMVolDg','ArgList');
    if ($rtn) {
        $rtn .= ' CVMVolumeIoTest' if ($rtn!~/CVMVolumeIoTest/m);
        $rtn .= ' CVMDGAction' if ($rtn!~/CVMDGAction/m);
        $rtn .= ' CVMDeportOnOffline' if ($rtn!~/CVMDeportOnOffline/m);
        $rtn .= ' CVMDeactivateOnOffline' if ($rtn!~/CVMDeactivateOnOffline/m);
        $rtn .= ' State' if ($rtn!~/State/m);
        $cvmvoldg_arglist="hatype -modify CVMVolDg ArgList $rtn\n";
        $cvmvoldg_arglist.="haattr -add CVMVolDg CVMVolumeIoTest -keylist\n";
        $cvmvoldg_arglist.="hatype -modify CVMVolDg OnlineRetryLimit 2\n";
        $cvmvoldg_arglist.="hatype -modify CVMVolDg OnlineTimeout 400\n";
        $cvmvoldg_arglist.="haattr -add CVMVolDg CVMDGAction -string\n";
        $cvmvoldg_arglist.="haattr -add CVMVolDg CVMDeportOnOffline -integer\n";
        $cvmvoldg_arglist.="haattr -add CVMVolDg CVMDeactivateOnOffline -integer";
        $sys->set_value('maincf_upgrade,11_cvmvoldg_arglist', $cvmvoldg_arglist);
    }

    # Update CVMCluster
    $type_name = 'CVMCluster';
    if ($type_node = dynupgrade_get_node_from_tree( $treeref_olduser, 'TYPE', $type_name)) {
        # Add CVMNodePreference as an attr to CVMCluster in 6.0.1
        $attr_name = 'CVMNodePreference';
        $attr_node = dynupgrade_get_node_from_tree( $type_node, 'ATTR', $attr_name);
        # do nothing if CVMNodePreference already exist
        $cvmcluster_attr.="haattr -add CVMCluster CVMNodePreference -string\n" unless ($attr_node);

        # Add CVMClus_storage_connectivity as an attr to CVMCluster in 6.0.1
        $attr_name = 'CVMClus_storage_connectivity';
        $attr_node = dynupgrade_get_node_from_tree( $type_node, 'ATTR', $attr_name);
        # do nothing if CVMClus_storage_connectivity already exist
        $cvmcluster_attr.='haattr -add CVMCluster CVMClus_storage_connectivity -keylist' unless ($attr_node);
        $sys->set_value('maincf_upgrade,12_cvmcluster_add', $cvmcluster_attr) if ($cvmcluster_attr);

        # Add CVMNodePreference to RegList in 6.0.1
        # Add CVMClus_storage_connectivity to RegList and ArgList in 6.0.1
        $rtn = dynupgrade_get_attrvalue_of_typename($treeref_olduser,'CVMCluster','RegList');
        if ($rtn) {
            $rtn .= ' CVMNodePreference' if ($rtn!~/CVMNodePreference/m);
            $rtn .= ' CVMClus_storage_connectivity' if ($rtn!~/CVMClus_storage_connectivity/m);
            $cvmcluster_reglist="hatype -modify CVMCluster RegList $rtn";
            $sys->set_value('maincf_upgrade,12_cvmcluster_reglist', $cvmcluster_reglist);
        } else {
            # should not add this line if no CVMTypes
            $cvmcluster_reglist='haattr -add -static CVMCluster RegList  -keylist CVMNodePreference CVMClus_storage_connectivity';
            $sys->set_value('maincf_upgrade,12_cvmcluster_reglist', $cvmcluster_reglist);
        }
        $rtn = dynupgrade_get_attrvalue_of_typename($treeref_olduser,'CVMCluster','ArgList');
        if (($rtn) && ($rtn!~/CVMClus_storage_connectivity/m)) {
            $rtn .= ' CVMClus_storage_connectivity';
            $cvmcluster_arglist="hatype -modify CVMCluster ArgList $rtn";
            $sys->set_value('maincf_upgrade,12_cvmcluster_arglist', $cvmcluster_arglist);
        }
    }

    return;
}

# Get attribute value of $attr_name for type $type_name from main.cmd
# Same as this command: hatype -display $type_name -attribute $attr_name
sub dynupgrade_get_attrvalue_of_typename {
    my ($treeref, $type_name, $attr_name)= @_;
    my $branchref= dynupgrade_get_node_from_tree( $treeref, 'TYPE', $type_name);
    my $noderef = dynupgrade_get_node_from_tree ($branchref, 'ATTR', $attr_name);
    return (defined $noderef->{ADD}->{ATTRVAL}) ?
        $noderef->{ADD}->{ATTRVAL} : $noderef->{MODIFY}->{ATTRVAL};
}

# Modify sourcefile
sub modify_sourcefile_sys {
    my ($sys, $treeref, $tree_name)= @_;
    my ($sourcefile, $sourcefilebase, @sourcefiles);
    for my $key (keys %{$treeref->{$tree_name}}) {
        $sourcefile = dynupgrade_get_sourcefile($treeref,$tree_name,$key);
        $sourcefile =~ s/^\"(\S+)\"$/$1/mx;
        $sourcefilebase=EDRu::basename($sourcefile);
        if ( ($sourcefile =~ /^\//m) || (($sourcefile =~ /\.\//m) && ($sourcefile !~ /^\.\/$sourcefilebase$/mx)) ){
            dynupgrade_set_sourcefile($treeref,$tree_name,$key,"\"\.\/$sourcefilebase\"");
            $sys->set_value("maincf_sourcefile_$tree_name,$key", "$sourcefile");
        }
        push (@sourcefiles, $sourcefilebase) if ($tree_name eq 'TYPE');
    }
    return ($tree_name eq 'TYPE') ? EDRu::arruniq(@sourcefiles) : '';
}

# Get sourcefile of $key in tree $tree_name
sub dynupgrade_get_sourcefile {
    my ($treeref, $tree_name, $key)= @_;
    my $branchref= dynupgrade_get_node_from_tree( $treeref, $tree_name, $key);
    return $branchref->{FILE}->{ATTRVAL};
}

# Set sourcefile of $key in tree $tree_name
sub dynupgrade_set_sourcefile {
    my ($treeref, $tree_name, $key, $source_file)= @_;
    my $branchref= dynupgrade_get_node_from_tree( $treeref, $tree_name, $key);
    $branchref->{FILE}->{ATTRVAL}=$source_file;
    return;
}

# Get group list from main.cmd
# Same as this command: hagrp -list
sub dynupgrade_get_grplist {
    my $treeref = shift;
    my $grpref = dynupgrade_get_branch_from_tree( $treeref, 'GRP');
    return (keys %{$grpref});
}

# Get resources list for group $grp_name from main.cmd
# Same as this command: hagrp -resources $grp_name
sub dynupgrade_get_res_from_grp {
    my ($treeref,$grp_name) = @_;
    my @resname_list= ();
    my $branchref= dynupgrade_get_branch_from_tree( $treeref, 'RES');
    my ( $resname, $noderef, $cmdref);

    for my $resname ( keys %{$branchref} ) {
        # get each resource node and main command
        $noderef= dynupgrade_get_node_from_branch( $branchref, $resname);
        $cmdref= $noderef->{MAIN};
        # compare the group name with required one
        if( $cmdref->{SERVGRP} eq $grp_name) {
            push ( @resname_list, $resname);
        }
    }

    return @resname_list;
}

# Get attribute value of $attr_name for resource $res_name from main.cmd
# Same as this command: hares -display $res_name -attribute $attr_name
sub dynupgrade_get_attrvalue_of_resname_array {
    my ($treeref, $res_name, $attr_name)= @_;
    my $branchref= dynupgrade_get_node_from_tree( $treeref, 'RES', $res_name);
    my $noderef = dynupgrade_get_node_from_tree ($branchref, 'ATTR', $attr_name);
    # return an array.
    return $noderef->{MODIFY}->{ATTRVAL};
}

sub dynupgrade_get_attrvalue_of_resname {
    my $attrs=dynupgrade_get_attrvalue_of_resname_array(@_);
    return $attrs->[0];
}

# Get the resource type of $res_name from main.cmd
# Same as this command: hares -display $res_name -attribute Type
sub dynupgrade_get_restype_of_resname {
    my ($treeref, $res_name)= @_;
    my $branchref= dynupgrade_get_node_from_tree( $treeref, 'RES', $res_name);
    return $branchref->{MAIN}->{RESTYPE};
}


# Get the SystemList defined for $grp_name from main.cmd
# Same as this command: hagrp -display $grp_name -attribute SystemList
sub dynupgrade_get_systemlist_of_grpname {
    my ($treeref, $grp_name)= @_;
    my ($sys_ref,@sys_list,$grp_sys,@grp_syslist);

    my $syslist_ref =  dynupgrade_get_branch_from_tree( $treeref, 'SYS');
    for my $sys_ref (@{$syslist_ref}) {
        push (@sys_list, $sys_ref->{CONTENT}) if ($sys_ref->{SUBCMD} eq '-add');
    }

    my $grp_syslist_ref = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name, 'SystemList');
    my $grp_syslist = $grp_syslist_ref->{MODIFY}->{ATTRVAL}->[0];
    for my $grp_sys (split(/\s+/m,$grp_syslist)) {
        push (@grp_syslist, $grp_sys) if (EDRu::inarr($grp_sys,@sys_list));
    }
    return @grp_syslist;
}

# Rename the attribute name
sub dynupgrade_rename_attr_name {
    my ($treeref,$type_name,$old_attr_name,$new_attr_name) = @_;
    my ($attrref,$noderef,$res,@reslist);
    @reslist = dynupgrade_get_resname_list_from_typename($treeref,$type_name);
    for my $res (@reslist) {
        $noderef=dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attrref=dynupgrade_get_node_from_tree($noderef,'ATTR',$old_attr_name);
        if (defined $attrref) {
            $attrref->{MODIFY}->{ATTRNAME}=$new_attr_name;
            $noderef->{ATTR}->{$new_attr_name} = $attrref;
            delete ($noderef->{ATTR}->{$old_attr_name});
        }
    }
    return;
}

sub dynupgrade_modify_attr_value_DNS {
    my ($treeref) = @_;
    my ($alias,$alias_ref,$dns_resrecord,$hostname,$hostname_ref,$noderef,$res,@reslist,$res_name,$resrecord,$resrecord_ref);
    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'DNS');
    for my $res (@reslist) {
        $noderef=dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $alias_ref=dynupgrade_get_node_from_tree($noderef,'ATTR','Alias');
        $hostname_ref=dynupgrade_get_node_from_tree($noderef,'ATTR','Hostname');
        $resrecord_ref=dynupgrade_get_node_from_tree($noderef,'ATTR','ResRecord');
        if (defined $alias_ref && defined $hostname_ref) {
            $alias=$alias_ref->{MODIFY}->{ATTRVAL}->[0];
            $hostname=$hostname_ref->{MODIFY}->{ATTRVAL}->[0];
            $res_name=$noderef->{MAIN}->{RESNAME};
            $resrecord='';
            if (defined $resrecord_ref) {
                $resrecord=$resrecord_ref->{MODIFY}->{ATTRVAL}->[0];
                $resrecord='' if ($resrecord =~ /-delete -keys/m);
            }
            $dns_resrecord.="hares -modify $res_name ResRecord $resrecord $alias $hostname\n";
        }
    }
    return $dns_resrecord;
}

sub dynupgrade_modify_attr_value {
    my ($treeref,$type_name,$attr_name,$old_attr_value,$new_attr_value) = @_;
    my ($attrref,$noderef,$res,@reslist);
    @reslist = dynupgrade_get_resname_list_from_typename($treeref,$type_name);
    for my $res (@reslist) {
        $noderef=dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attrref=dynupgrade_get_node_from_tree($noderef,'ATTR',$attr_name);
        if (defined $attrref) {
            $attrref->{MODIFY}->{ATTRVAL}->[0]=$new_attr_value
                if ($attrref->{MODIFY}->{ATTRVAL}->[0] =~ /^(\")?$old_attr_value(\")?$/mx);
        }
    }
    return;
}

sub configure_precheck_sys {
    my ($prod,$sys) = @_;
    my ($cscript,$cprod,$msg,$running,$syslist,$llt,$had,$gab);

    return if(Cfg::opt('rootpath'));
    $syslist=CPIC::get('systems');
    $cscript=CPIC::get('script');
    $cprod=CPIC::get('prod');
    $had = $sys->proc('had61');
    $gab = $sys->proc('gab61');
    $llt = $sys->proc('llt61');
    if($had->check_sys($sys)) {
        $running = 1;
    } elsif ($gab->check_sys($sys)) {
        $running = 1;
    } elsif ($llt->check_sys($sys)) {
        $running = 1;
    }

    if($running) {
        if($cprod ne 'SFRAC61') {
            $msg=Msg::new("VCS is running on $sys->{sys}. Execute $cscript -stop before configuration to stop VCS.");
            #$sys->push_error($msg);
            return '';
        } else {
            return 0;
        }
    }
    $prod->check_os_patch_sys($sys);

    return 1;
}

sub start_precheck_sys {
    my ($prod,$sys) = @_;
    my ($sysi,$msg,@missing_comms_files,$sysnum,$filename,$hacf_cmd,$comms_required,$onenode,$rtn,$maincf,$cfg,$gabports);
    @missing_comms_files = ();
    $sysnum = 0;
    $onenode = 0;
    $comms_required = 1;
    $sysi = $sys->{sys};
    # set $cfg->{vcs_allowcomms}
    $prod->set_vcs_allowcomms_sys($sys) if ($sys->system1);

    # check required config files.

    #  a. check existence of main.cf in /etc/VRTSvcs/conf/config/
    if ($sys->exists($prod->{maincf})) {
        $maincf = $sys->readfile($prod->{maincf});
    } else {
        $maincf = undef;
    }
    if (!$maincf){
        $filename = $prod->{maincf};
        $msg = Msg::new("$filename does not exist on $sysi.");
        $sys->push_error($msg);
        return 0;
    } else {
        $sysnum = grep {/^system/m} split (/\n/,$maincf);
    }

    #  b. validate main.cf by 'hacf -verify /etc/VRTSvcs/conf/config'
    $rtn = $sys->cmd("$prod->{cmd_hacf} -verify $prod->{configdir}");
    if (EDR::cmdexit() != 0) {
        $hacf_cmd = "\'$prod->{cmd_hacf} -verify $prod->{configdir}\'";
        $msg = Msg::new("main.cf is not valid on $sysi:\n\t$rtn\nFix the error(s), and verify the main.cf file before starting VCS by running $hacf_cmd on $sysi");
        $sys->push_error($msg);
        return 0;
    }

    #  c. Prompt for reconfigure if any of /etc/llttab /etc/llthosts or /etc/gabtab is missing and
    #     ONENODE is not set to yes or not set in
    #     *) /etc/sysconfig/vcs on Linux,
    #     *) /etc/rc.config.d/vcsconf on HP-UX,
    #     *) /etc/default/vcs on AIX or Solaris.
    $onenode = '';
    if ($sys->exists($prod->{initfile}{vcs})) {
        $onenode = $sys->cmd("unset ONENODE; . $prod->{initfile}{vcs} >/dev/null 2>/dev/null ; echo \$ONENODE");
        chomp $onenode;
    }
    if ($onenode) {
        if ( $onenode eq 'yes' ) {
            $comms_required = 0;
        }
    } else {
        # ONENODE is not used on AIX/SunOS/HPUX for pre-6.0 releases. -onenode will be added as argument of hastart if there is only one system configured.
        if ( !$sys->linux() && $sysnum == 1 ) {
            $comms_required = 0;
        }
    }
    if ($comms_required) {
        if (!$sys->exists($prod->{llttab})){
            push @missing_comms_files, $prod->{llttab};
            $filename = $prod->{llttab};
            $msg = Msg::new("LLT cannot be started on $sysi because $filename does not exist.");
            $sys->push_error($msg);
        }
        if (!$sys->exists($prod->{llthosts})){
            push @missing_comms_files, $prod->{llthosts};
            $filename = $prod->{llthosts};
            $msg = Msg::new("LLT cannot be started on $sysi because $filename does not exist.");
            $sys->push_error($msg);
        }
        if (!$sys->exists($prod->{gabtab})){
            push @missing_comms_files, $prod->{gabtab};
            $filename = $prod->{gabtab};
            $msg = Msg::new("GAB cannot be started on $sysi because $filename does not exist.");
            $sys->push_error($msg);
        }
        if ( scalar @missing_comms_files > 0 ) {
            $msg = Msg::new("HAD cannot be started on $sysi because LLT or GAB cannot be started and VCS is not configured in single-node mode on that system.\n Configure or reconfigure VCS.");
            $sys->push_error($msg);
            return 0;
        }
    }

    $cfg = Obj::cfg();
    if ($cfg->{opt}{start} && $sys->system1) {
        $gabports = $sys->cmd("_cmd_gabconfig -a 2>/dev/null");
        if ($gabports !~ /^\s*Port\s+a\s+/mx && @{$cfg->{systems}} < $sysnum) {
            $msg = Msg::new("Starting part of a cluster is not supported by installer. It could result in failure to start GAB later. You need to manually enable seed of control port with the command 'gabconfig -x' or edit /etc/gabtab file to update the number of nodes you want to start before you start part of the cluster.");
            $sys->push_warning($msg);
        }
    }

    $prod->check_os_patch_sys($sys);
    return 1;
}

sub stop_precheck_sys {
    my ($prod,$sys) = @_;
    return 1;
}

sub install_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->checknicconf_sys($sys) if ($prod->can('checknicconf_sys'));
    $prod->check_ksh_for_vxfen_sys($sys) if ($prod->can('check_ksh_for_vxfen_sys'));
    $prod->check_os_patch_sys($sys);
    return 1;
}

sub check_os_patch_sys {
    return;
}

sub precheck_sys {
    my ($prod,$sys) = @_;
    return 1;
}

sub preremove_tasks {
    my $prod = shift;
    $prod->vxfen_preremove_tasks;
    return;
}

sub vxfen_preremove_tasks {
    my (%flag,$clustername,$conf,$cpsname,$cpssys,$prod,$sys,$vxfenpkg,$syslist,$msg,@cps);
    my ($answer,$cfg,$help);
    return unless (Cfg::opt(qw/uninstall upgrade/));

    $prod = shift;
    $syslist=CPIC::get('systems');
    $vxfenpkg = $prod->pkg('VRTSvxfen61');
    $cfg = Obj::cfg();
    for my $sys (@$syslist) {
        next unless ($sys->exists($prod->{vxfenmode}));
        $conf = $prod->get_vxfen_config_sys($sys);
        next unless ($conf->{vxfen_mechanism} =~ /cps/m);
        # set the first node in each cluster
        next unless $prod->get_config_sys($sys);
        $clustername = $sys->{vcs_conf}{clustername};
        next if ($flag{"$clustername"});
        $sys->{system1} = 1;
        $flag{"$clustername"} = 1;
        # ask if user would like to keep the client cluster info on CP servers before unintall
        if (Cfg::opt('uninstall') && !Cfg::opt('responsefile')) {
            $msg = Msg::new("Do you want to delete the client cluster information registered on the Coordination Point servers?");
            $help = Msg::new("If you choose not to delete the client cluster information registered on the coordination point servers, when the client cluster is reconfigured with existing configuration files, the client cluster information registered on the coordination point servers can be reused. Otherwise, the client cluster information will be deleted from the coordination point servers.");
            $answer = $msg->aynn($help);
            $cfg->{fencing_delete_client_on_cps} = 1 if ($answer eq 'Y');
        }
        # create cps sys object in main thread.
        for my $cpsname (@{$conf->{cps}}) {
            $cpssys = $vxfenpkg->create_cps_sys($cpsname);
            if (Cfg::opt('upgrade')) {
                # Check if we can communicate with cps
                if (!$vxfenpkg->cps_transport_sys($cpssys)) {
                    $msg=Msg::new("Cannot communicate with system $cpssys->{sys} which was found to be a Coordination Point server.");
                    $msg->warning;
                    next;
                }
                push (@cps,$cpssys);
            }
        }
        # only get the cps list when upgrade with secure CPS fencing configuration
        $prod->{cpslist}=\@cps if (Cfg::opt('upgrade') && $conf->{security});
    }
    return;
}

sub upgrade_preremove_sys {
    my ($prod,$sys) = @_;
    my ($mkdir,$msg,$rootpath,$tmpdir,$vers,$initfile_content);
    $tmpdir=EDR::tmpdir();
    $rootpath = Cfg::opt('rootpath');
    $prod->backup_vcs_lock_files_sys($sys) if ($prod->can('backup_vcs_lock_files_sys'));

    #save the config files to tmpdir
    $mkdir=$sys->cmd("_cmd_mkdir -p $tmpdir/VCS-CFG-BAK");
    if ( $mkdir || EDR::cmdexit() ) {
        $msg=Msg::new("Cannot create $tmpdir on $sys->{sys}");
        $sys->push_error($msg);
        return '';
    }
    for my $cf (@{$prod->{amftab}}) {
        $cf = $rootpath.$cf if ($rootpath);
        next unless ($sys->exists($cf));
        $sys->cmd("_cmd_cp -pf $cf $tmpdir/VCS-CFG-BAK/");
    }

    # backup init files for llt/gab/vxfen/vcs/amf
    if ( ! $rootpath ) {
        $rootpath = '';
    }
    $initfile_content = {};
    for my $initfile (keys %{$prod->{initfile}}) {
        if (!$sys->exists($rootpath.$prod->{initfile}{$initfile})) {
            Msg::log('No '.$rootpath.$prod->{initfile}{$initfile}.' to backup');
            next;
        }
        Msg::log('Found '.$rootpath.$prod->{initfile}{$initfile}.' to backup');
        for my $line (split(/\n/, $sys->readfile($rootpath.$prod->{initfile}{$initfile}))) {
            if ( $line =~ /^\s*([a-zA-Z0-9_]+)=(.*)$/mx ) {
                $initfile_content->{$initfile}{$1}=$2;

            }
        }
    }
    $sys->set_value('initfile_content', JSON::to_json($initfile_content));

    return;
}

sub upgrade_postinstall_sys {
    my ($prod,$sys) = @_;
    my ($filename,$old,$rootpath,$tmpdir,$filecontent,$value,$initfile_content);

    $prod->add_namespace_vcs_sys($sys);
    $prod->configure_sso_sys($sys);
    $sys->cmd("/opt/VRTSvcs/portal/admin/synchronize_guest_config.pl CreateAppSGMap=Yes 2>/dev/null");

    $tmpdir=EDR::tmpdir();
    $rootpath = Cfg::opt('rootpath');
    for my $cf (@{$prod->{amftab}}) {
        $filename = EDRu::basename($cf);
        $old = "$tmpdir/VCS-CFG-BAK/$filename";
        $cf = $rootpath.$cf if ($rootpath);
        next unless ($sys->exists("$old"));
        $sys->cmd("_cmd_cp -pf $old $cf");
    }
    $sys->cmd("_cmd_rmr $tmpdir/VCS-CFG-BAK");
    $prod->register_extra_types() if($sys->system1);
    $prod->restore_vcs_lock_files_sys($sys) if ($prod->can('restore_vcs_lock_files_sys'));
    $prod->move_NFS_triggers_sys($sys) if ($prod->can('move_NFS_triggers_sys'));

    # restore init files for llt/gab/vxfen/vcs/amf
    if ( ! $rootpath ) {
        $rootpath = '';
    }
    $initfile_content = {};
    if ($sys->{initfile_content}) {
        $initfile_content = JSON::from_json($sys->{initfile_content});
    }
    for my $initfile (keys %{$initfile_content}) {
        Msg::log('Restoring '.$rootpath.$prod->{initfile}{$initfile});
        if ( $sys->exists($rootpath.$prod->{initfile}{$initfile})) {
            Msg::log('Reading '.$rootpath.$prod->{initfile}{$initfile});
            $filecontent = $sys->readfile($rootpath.$prod->{initfile}{$initfile});
        } else {
            Msg::log('Creating '.$rootpath.$prod->{initfile}{$initfile});
            $filecontent = '';
        }
        for my $key (sort keys %{$initfile_content->{$initfile}}) {
            $value = $initfile_content->{$initfile}{$key};
            Msg::log('Adding '."$key=$value".' into '.$rootpath.$prod->{initfile}{$initfile});
            if (!($filecontent =~ s/^\s*$key=.*$/$key=$value/mxg)) {
                Msg::log('Appending '."$key=$value".' into '.$rootpath.$prod->{initfile}{$initfile});
                $filecontent .= "\n$key=$value";
            }
        }
        $filecontent .= "\n";
        $sys->writefile($filecontent, $rootpath.$prod->{initfile}{$initfile});
    }

    # remove obsolete cps key and apply new cps key after upgrade if existed.
    $prod->replace_obsolete_cps_key_sys($sys);

    return;
}

# Remove obsolete cps key and apply new cps key after upgrade if existed.
sub replace_obsolete_cps_key_sys {
    my ($prod,$sys) = (@_);
    my ($cpspkg,$msg,$rootpath,$obsolete_keyfile,$cps_keyfile,$singlenode_licensed,$out);
    $rootpath = Cfg::opt('rootpath');
    $rootpath ||='';
    # remove the trailing '/'
    $rootpath =~ s/\/*$//g;
    $cpspkg = $prod->pkg('VRTScps61');
    $cps_keyfile = "$rootpath/etc/vx/licenses/lic/$cpspkg->{cpskey}.vxlic";
    $obsolete_keyfile = "$rootpath/etc/vx/licenses/lic/$cpspkg->{obsolete_cpskey}.vxlic";

    # Fix for ET3067356 - CPI did not upgrade the CPS key when upgrading vcs6.0 to vcs6.1.
    # return if (!$sys->exists($obsolete_keyfile));
    if (!$sys->exists($obsolete_keyfile) && !$sys->exists($cps_keyfile)) {
        $out = $sys->cmd("_cmd_grep SystemList $prod->{maincf}  2>/dev/null");
        if ($out =~ /,/m) {} else {
            $out = $sys->cmd("_cmd_grep VRTScps $prod->{maincf}  2>/dev/null");
            if ($out =~ /\bVRTScps\b/m) {
                # only vcs and sfha should be registered with single node key
                my $cprod=CPIC::get('prod');
                if ($cprod && $cprod =~/(VCS|SFHA)\d+/) {
                    $singlenode_licensed = $cpspkg->register_singlenode_cps_license_sys($sys);
                    $prod->set_value('replace_cps_key', 1);
                }
            }
        }
       return;
    }

    if (!$rootpath) {
        $out=$sys->cmd("_cmd_vxlicinst -k $cpspkg->{cpskey}");
        if ($out =~ /\b(successfully|Duplicate)\b/m) {
            Msg::log("Single node cps key successfully registered on $sys->{sys}");
            $sys->cmd("_cmd_rmr $obsolete_keyfile");
            # force license step to re-load keys
            $sys->set_value ('donotquerykeys', 0);
        } else {
            Msg::log("Single node cps key did not register successfully on $sys->{sys}, manually replace obsolete cps key $cpspkg->{obsolete_cpskey} with new key $cpspkg->{cpskey}");
        }
    } else {
        # Cannot register new key on alt disk, prompt to manually replace the old key.
        $msg = Msg::new("Obsolete license key $cpspkg->{obsolete_cpskey}.vxlic for the coordination point server is found under the directory $rootpath/etc/vx/licenses/lic/ on $sys->{sys}, manually remove it and register a new coordination point server license key $cpspkg->{cpskey} after an upgrade");
        $sys->push_warning($msg);
    }
    return;
}

# in Pinnacle, prod team request to back up and restore dns lock files for all platforms
# 1. for files in /var/VRTSvcs/lock/ with the name like "_online_lock", rename to "._online_lock" (5.0*)
# 2. for files in /var/VRTSvcs/lock/ with the name like "._online_lock", backup directly (5.1)
sub backup_vcs_lock_files_sys {
    my ($prod,$sys) = @_;
    my ($lockfilepath,$oldfolder,$newfolder,$lockfolder,$vcsvers,$rootpath,$nfsrestart,$nfs4);

    # check previous prod version
    $vcsvers = $prod->version_sys($sys,1);
    return  unless $vcsvers;

    $rootpath = Cfg::opt('rootpath');
    $oldfolder = "$rootpath/var/VRTSvcs/lock";
    $newfolder = "$rootpath/var/VRTSvcs/lock/volatile";
    $lockfilepath = EDR::tmpdir().'/VRTSvcs_lock';

    $lockfolder = (EDRu::compvers($vcsvers,'6.0') == 2) ? $oldfolder : $newfolder;
    if ($sys->cmd("_cmd_ls $lockfolder/*_online_lock 2>/dev/null")){
        $sys->cmd("_cmd_mkdir -p $lockfilepath");
        $sys->cmd("_cmd_cp $lockfolder/*_online_lock $lockfilepath/");
    }
    # fix for 2386268 if there is hidden file start with .
    if ($sys->cmd("_cmd_ls $lockfolder/.*_online_lock 2>/dev/null")){
        $sys->cmd("_cmd_mkdir -p $lockfilepath");
        $sys->cmd("_cmd_cp $lockfolder/.*_online_lock $lockfilepath/");
    }

    # e3419772, for NFSRestart agent, need to copy the following files (if present) from
    # /var/VRTSvcs/lock to /var/VRTSvcs/lock/volatile dir during upgrade:
    # 1. .nfsrestart_${ResName}_state
    if ($sys->cmd("_cmd_ls -a $oldfolder/.nfsrestart_*_state 2>/dev/null")
       || $sys->cmd("_cmd_ls -a $oldfolder/.nfs_lock_* 2>/dev/null")) {
        $lockfolder = $oldfolder;
        $nfsrestart = 1;
    } elsif ($sys->cmd("_cmd_ls -a $newfolder/.nfsrestart_*_state 2>/dev/null")) {
        $lockfolder = $newfolder;
        $nfsrestart = 1;
    } else {
        $nfsrestart = 0;
    }
    if ($nfsrestart){
        $sys->cmd("_cmd_mkdir -p $lockfilepath");
        $sys->cmd("_cmd_cp $lockfolder/.nfsrestart_*_state $lockfilepath/ 2>/dev/null");
        $sys->cmd("_cmd_cp $lockfolder/.nfs_lock_* $lockfilepath/ 2>/dev/null");
    }
    # 2. .nfs4_status_file
    if ($sys->cmd("_cmd_ls -a $oldfolder/.nfs4_status_file 2>/dev/null")) {
        $lockfolder = $oldfolder;
        $nfs4 = 1;
    } elsif ($sys->cmd("_cmd_ls -a $newfolder/.nfs4_status_file 2>/dev/null")) {
        $lockfolder = $newfolder;
        $nfs4 = 1;
    } else {
        $nfs4 = 0;
    }
    if ($nfs4){
        $sys->cmd("_cmd_mkdir -p $lockfilepath");
        $sys->cmd("_cmd_cp $lockfolder/.nfs4_status_file $lockfilepath/ 2>/dev/null");
    }

    return;
}

# restore the lock files
# touch the file /var/VRTSvcs/lock/.habootfile, refer to e2386268
sub restore_vcs_lock_files_sys {
    my ($prod,$sys) = @_;
    my ($files,$oldlockfile,@files,$lockfilepath,$newlockfile,$newfolder,$rootpath);

    $lockfilepath = EDR::tmpdir().'/VRTSvcs_lock';
    return 1 unless $sys->is_dir($lockfilepath);

    $rootpath = Cfg::opt('rootpath');
    $newfolder = "$rootpath/var/VRTSvcs/lock/volatile";
    $sys->cmd("_cmd_mkdir -p $newfolder");

    $files = $sys->cmd("cd $lockfilepath 2>/dev/null; _cmd_ls -a | _cmd_grep online_lock 2>/dev/null");
    @files = split(/\s+/m, $files);
    for my $oldlockfile (@files) {
        $newlockfile = $oldlockfile;
        $newlockfile =~ s/_online_lock/\._online_lock/m unless ($oldlockfile =~ /\._online_lock/mx);
        $sys->cmd("_cmd_cp $lockfilepath/$oldlockfile $newfolder/$newlockfile") unless $sys->exists("$newfolder/$newlockfile");
    }

    # e3419772, for Solaris, need rename old file name from .nfs_lock_$ResName to .nfsrestart_${ResName}_state
    $files = $sys->cmd("cd $lockfilepath 2>/dev/null; _cmd_ls -a | _cmd_grep nfs_lock 2>/dev/null");
    @files = split(/\s+/m, $files);
    for my $oldlockfile (@files) {
        $newlockfile = $oldlockfile;
        if ($oldlockfile =~ /\.nfs_lock/mx) {
            $newlockfile =~ s/\.nfs_lock/\.nfsrestart/m;
            $newlockfile = "${newlockfile}_state";
        }
        $sys->cmd("_cmd_cp $lockfilepath/$oldlockfile $newfolder/$newlockfile") unless $sys->exists("$newfolder/$newlockfile");
    }

    # e3419772, for other platforms, need copy .nfsrestart_${ResName}_state from /var/VRTSvcs/lock to /var/VRTSvcs/lock/volatile
    $files = $sys->cmd("cd $lockfilepath 2>/dev/null; _cmd_ls -a | _cmd_grep nfsrestart 2>/dev/null");
    @files = split(/\s+/m, $files);
    for my $oldlockfile (@files) {
        $sys->cmd("_cmd_cp $lockfilepath/$oldlockfile $newfolder/$oldlockfile") unless $sys->exists("$newfolder/$oldlockfile");
    }

    # e3419772, need copy .nfs4_status_file if NFSv4 is enabled
    $sys->cmd("_cmd_cp $lockfilepath/.nfs4_status_file $newfolder/") if $sys->exists("$lockfilepath/.nfs4_status_file");

    # e3448500, need delete the existing .habootfile before touching, if not when had starts, it finds the old time 
    # stamp, will delete the volatile directory contents, which will lead to nfs grp cannot come online automatically
    $sys->cmd("_cmd_rm -f /var/VRTSvcs/lock/.habootfile 2>/dev/null");
    $sys->cmd("_cmd_touch /var/VRTSvcs/lock/.habootfile 2>/dev/null");
    return;
}

sub backup_smf_scripts_sys {
    my ($prod,$sys,$pkg) = @_;
    my ($mkdir,$msg,$tmpdir,$vers);
    return unless (Cfg::opt('upgrade'));
    $tmpdir=EDR::tmpdir();

    # For Live upgrade, if it is upgraded from 5.1 or above to 6.0,
    # backup VCS SMF scripts on PBE
    if (Cfg::opt('rootpath')) {
        $vers = $prod->version_sys($sys);
        if ($vers && !(EDRu::compvers($vers,'5.1') == 2) &&
            (EDRu::compvers($vers,'6.0') == 2)) {
            #save the config files to tmpdir
            $mkdir=$sys->cmd("_cmd_mkdir -p $tmpdir/VCS-CFG-BAK");
            if ( $mkdir || EDR::cmdexit() ) {
                $msg=Msg::new("Cannot create $tmpdir on $sys->{sys}");
                $sys->push_error($msg);
                return '';
            }
            for my $smf (@{$pkg->{smf}}) {
                next unless ($sys->exists($smf));
                $sys->cmd("_cmd_cp -pf $smf $tmpdir/VCS-CFG-BAK/");
            }
        }
    }
    return;
}

sub restore_smf_scripts_sys {
    my ($prod,$sys,$pkg) = @_;
    my ($filename,$mkdir,$old,$tmpdir);
    return unless (Cfg::opt('upgrade'));
    $tmpdir=EDR::tmpdir();
    # For Live upgrade, if it is upgraded from 5.1 or above to 6.0,
    # restore VCS SMF scripts on PBE
    if (Cfg::opt('rootpath')) {
        for my $smf (@{$pkg->{smf}}) {
            $filename = EDRu::basename($smf);
            $old = "$tmpdir/VCS-CFG-BAK/$filename";
            next unless ($sys->exists("$old"));
            $sys->cmd("_cmd_cp -pf $old $smf");
        }
    }
    return;
}

# NFS triggers will be deleted from new implementation. The NFS triggers should be moved to sample_triggers directory.
sub move_NFS_triggers_sys{
    my ($prod,$sys) = @_;

    my $rootpath = Cfg::opt('rootpath');
    return 1 unless $sys->cmd("_cmd_ls $rootpath/opt/VRTSvcs/bin/triggers/nfs_* 2>/dev/null");
    $sys->cmd("_cmd_mkdir -p $rootpath/opt/VRTSvcs/bin/sample_triggers;_cmd_mv -f $rootpath/opt/VRTSvcs/bin/triggers/nfs_* $rootpath/opt/VRTSvcs/bin/sample_triggers/");
    return;
}

sub postinstall_sys {
    my ($prod,$sys) = @_;
    # Configure SFMH
    $prod->add_namespace_vcs_sys($sys);
    $prod->configure_sso_sys($sys);
    # save vcs extra types list, CPI will read it during vcs configuration
    $prod->register_extra_types() if($sys->system1);
    # skip link install if it's not a fresh install for VCS
    return if (defined(${$sys->{upgradeprod}}[0]) &&
        ${$sys->{upgradeprod}}[0] =~ /^(SFRAC|SVS|SFCFS|SFHA|VCS)/mx);
    # link install: disable it, if fresh installed
    $prod->vcs_disable_sys($sys);
    return;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my ($cfg,$procs,$vxfen);
    $cfg = Obj::cfg();
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $procs = Prod::startprocs_sys($prod, $sys);
    $procs = $prod->verify_procs_list_sys($sys,$procs,'start');
    if ($cfg->{vcs_allowcomms}) {
        if ((!$sys->exists("$prod->{vxfenmode}")) && (!$sys->exists("$prod->{vxfendg}"))) {
            $procs = EDRu::arrdel($procs, 'vxfen61');
        }
        return $procs;
    } else {
        $procs = EDRu::arrdel($procs, 'llt61');
        $procs = EDRu::arrdel($procs, 'gab61');
        $procs = EDRu::arrdel($procs, 'vxfen61');
        return $procs;
    }
}

sub get_extra_types_sys {
    my ($prod,$sys) = @_;
    my (@extypes,$type,$pkgi,$pkg);
    my $rootpath=Cfg::opt('rootpath') || '';
    if(!$sys->exists($rootpath.$prod->{extra_types_cf})) {
        $prod->register_extra_types();
    }
    if($sys->exists($rootpath.$prod->{extra_types_cf})) {
        my $type_list = $sys->cmd("_cmd_cat $rootpath$prod->{extra_types_cf} 2>/dev/null");
        my @types = split(/\n/,$type_list);
        for my $type (@types) {
            next unless($type);
            if($sys->exists("$rootpath$prod->{configdir}/$type")) {
                push (@extypes, $type);
            } else {
                Msg::log("Couldn't find $rootpath$prod->{configdir}/$type on $sys->{sys}")
            }
        }
        return EDRu::arruniq(@extypes);
    }
    return;
}

sub register_extra_types {
    my ($prod) = @_;
    my ($conf_dir,$config_dir,$padv,$pkg,$pkgi,$rootpath,$ext,$ext_name,$extype_file,$sys,$sysi,$syslist);
    my $localsys = $prod->localsys;
    my $tmpfile = EDR::tmpdir().'/extra_types_cf';
    $conf_dir = '/etc/VRTSvcs/conf';
    $config_dir = '/etc/VRTSvcs/conf/config';
    $extype_file= $prod->{extra_types_cf};

    if (Cfg::opt('rootpath')) {
        $rootpath = Cfg::opt('rootpath');
        $conf_dir = $rootpath.$conf_dir;
        $config_dir = $rootpath.$config_dir;
        $extype_file = $rootpath.$extype_file;
    }

    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $padv = $sys->{padv};
        $sysi = $sys->{sys};
        # delete old extra type filelist
        if($sys->exists($extype_file)) {
            $sys->cmd("_cmd_rmr $extype_file");
        }
        for my $pkgi (qw(VRTSvcsea61 VRTSdbac61)) {
            $pkg = $prod->pkg($pkgi,1);
            next unless (defined $pkg && $pkg->version_sys($sys,1));
            for my $ext (@{$pkg->{extra_types}}) {
                $ext = $rootpath.$ext if (Cfg::opt('rootpath'));
                # cp extra types.cf to /etc/VRTSvcs/conf/config
                # cp extra types.cf to /etc/VRTSvcs/conf for dynamic upgrade.
                if ($sys->exists($ext)) {
                    $sys->cmd("_cmd_cp $ext $conf_dir") unless (EDRu::dirname($ext) eq $conf_dir);
                    $sys->cmd("_cmd_cp $ext $config_dir");
                } else {
                    Msg::log("Could not find $ext on $sys->{sys}");
                }
                # tell CPI to incldue these types into main.cf
                $ext_name = EDRu::basename($ext);
                EDRu::appendfile($ext_name, "$tmpfile.$sysi");
            }
        }
        if($localsys->exists("$tmpfile.$sysi")) {
            $localsys->copy_to_sys($sys,"$tmpfile.$sysi",$extype_file);
        }
    }
    return 1;
}

sub include_extra_types_sys {
    my ($prod,$sys) = @_;
    my ($sysi,$extype,$uuid,$extypes,$inctype,$syslist,$rtn,$cmd_scripts,$new_inc,$had,$tmpdir,$maincf,@inctypes);
    my $rootpath=Cfg::opt('rootpath') || '';
    $tmpdir=EDR::tmpdir();
    $uuid=EDR::get('uuid');
    $syslist=CPIC::get('systems');
    if ($sys->system1) {
        $extypes = $prod->get_extra_types_sys($sys);
        if($extypes) {
            # Get the additional extra types to be included.
            $rtn = $sys->cmd("_cmd_grep '^include' $rootpath$prod->{maincf} 2> /dev/null");
            for my $inctype (split(/\n/,$rtn)) {
                next unless ($inctype =~ /^include\s+(\S+)/mx);
                $inctype = $1;
                $inctype =~ s/"(.*)"/$1/m;
                $inctype = EDRu::basename($inctype);
                push (@inctypes,$inctype);
            }
            $extypes = EDRu::arrdel($extypes,@inctypes);

            # no additional extra types to include.
            if ($#{$extypes} < 0) {
                EDRu::create_flag('add_extypes_done');
                return;
            }

            $had = $sys->proc('had61');
            if (!$rootpath && $had->check_sys($sys, 'start')) {
                # had is running. Include the extra types by ha commands.
                $prod->haconf_makerw();
                $sys->cmd("_cmd_mkdir $tmpdir/dir_extypes");
                for my $extype (@$extypes) {
                    $new_inc .= "\ninclude \"$extype\"";
                    $sys->cmd("_cmd_cp $prod->{configdir}/$extype $tmpdir/dir_extypes");
                }
                $sys->writefile($new_inc, "$tmpdir/dir_extypes/main.cf");
                $sys->cmd("$prod->{cmd_hacf} -cftocmd $tmpdir/dir_extypes");
                $cmd_scripts=$sys->readfile("$tmpdir/dir_extypes/main.cmd");
                $cmd_scripts=~s/\s*(hatype|haattr)/\n$prod->{bindir}\/$1/xg;
                $sys->writefile($cmd_scripts, "$tmpdir/dir_extypes/main.sh");
                $sys->cmd("_cmd_cat $tmpdir/dir_extypes/main.sh");
                $sys->cmd("_cmd_sh $tmpdir/dir_extypes/main.sh");
                $prod->haconf_dumpmakero();
            } else {
                # had is not running. Append "include <extra types>" to the end of main.cf
                for my $extype (@$extypes) {
                    $new_inc .= "\ninclude \"$extype\"";
                }
                $new_inc .= "\n";
                $sys->cmd("_cmd_cp $rootpath$prod->{maincf} $rootpath$prod->{maincf}.$uuid");
                $sys->appendfile($new_inc,$rootpath.$prod->{maincf});
                $rtn = $sys->cmd("$rootpath$prod->{cmd_hacf} -verify $rootpath$prod->{configdir}");
                if ($rtn) {
                    $sys->cmd("_cmd_mv $rootpath$prod->{maincf}.$uuid $rootpath$prod->{maincf}");
                } else {
                    for my $sysi (@$syslist) {
                        next if $sysi->system1;
                        $sys->copy_to_sys($sysi, $rootpath.$prod->{maincf});
                    }
                }
            }
            EDRu::create_flag('add_extypes_done');
        } else {
            EDRu::create_flag('add_extypes_done');
        }
    } else {
        EDRu::wait_for_flag('add_extypes_done');
    }
    return;
}

sub default_systemnames {
    my ($prod) = @_;
    my (@llthosts,$hosts,$host,$rel,$cpic);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    return $rel->default_systemnames if(Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs)));
    my $rootpath = Cfg::opt('rootpath')||'';
    return if (!-f "$rootpath$prod->{llthosts}");

    $hosts = EDR::cmd_local("_cmd_grep -v '^#' $rootpath$prod->{llthosts} 2>/dev/null |_cmd_awk '{print \$2}'");
    for my $host (split(/\n/,$hosts)) {
        next unless $host;
        push(@llthosts,$host);
    }
    return join(' ', @llthosts);
}

# display preinstallation messages and confirmations
sub cli_preinstall_messages {
    #TODO:add SFRAC check here
    return;
}

sub responsefile_poststart_config {
    my $prod =shift;
    my ($cfg,$pkg);
    $cfg=Obj::cfg();
    if ($cfg->{fencingenabled}) {
        $pkg=$prod->pkg('VRTSvxfen61');
        $pkg->config_vxfen();
    }
    return;
}

sub responsefile_prestart_config {
    my $prod = shift;
    my ($cfg,$sys,$syslist);

    $cfg=Obj::cfg();
    $syslist=CPIC::get('systems');
    if ($cfg->{donotreconfigurevcs}) {
        for my $sys(@$syslist) {
            $prod->vcs_enable_sys($sys);
        }
    }
    return 1;
}

sub responsefile_comments {
    # Each response file comment is a 4 item list
    # item 1 is the comment, previously translated in the prior line
    # item 2 a 0=optional, 1=required
    # item 3 is 0=scalar, 1=list
    # item 4 is 0=1d, 1=2d is System, other=other second dimension
    my ($cfg,$cmt,$cpic,$edr,$email,$pkg,$prod);
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    # There should be no 'upgrade_kernelpkgs' or 'upgrade_nonkernelpkgs' in response file
    # So deal with them before $cfg->create_responsefile()
    if (Cfg::opt('upgrade_kernelpkgs')) {
        Cfg::unset_opt('upgrade_kernelpkgs');
        Cfg::set_opt('rollingupgrade_phase1');
    }
    if (Cfg::opt('upgrade_nonkernelpkgs')) {
        Cfg::unset_opt('upgrade_nonkernelpkgs');
        Cfg::set_opt('rollingupgrade_phase2');
    }
    delete($cfg->{vcs_allowcomms}) if (defined $cfg->{vcs_allowcomms} && Cfg::opt('rootpath'));
    $cmt=Msg::new("This variable defines the name of the cluster");
    $edr->{rfc}{vcs_clustername}=[$cmt->{msg},1,0,0];
    $cmt=Msg::new("This variable must be an integer between 0 and 65535 which uniquely identifies the cluster");
    $edr->{rfc}{vcs_clusterid}=[$cmt->{msg},1,0,0];
    $cmt=Msg::new("This variable defines the NIC to be used for a private heartbeat link on each system.  Two LLT links are required per system (lltlink1 and lltlink2).  Up to four LLT links can be configured");
    $edr->{rfc}{'vcs_lltlink#'}=[$cmt->{msg},1,0,1];
    $cmt=Msg::new("This variable defines a low-priority heartbeat link.  Typically, low-priority heartbeat link is used on a public network link to provide an additional layer of communication");
    $edr->{rfc}{'vcs_lltlinklowpri#'}=[$cmt->{msg},0,0,1];
    $cmt=Msg::new("This variable defines the NIC for Cluster Manager (Web Console) to use on a system.  'ALL' can be entered as a system value if the same NIC is used on all systems");
    $edr->{rfc}{vcs_csgnic}=[$cmt->{msg},0,0,1];
    $cmt=Msg::new("This variable defines the virtual IP address to be used by the Cluster Manager (Web Console)");
    $edr->{rfc}{vcs_csgvip}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the Netmask of the virtual IP address to be used by the Cluster Manager (Web Console)");
    $edr->{rfc}{vcs_csgnetmask}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the domain-based hostname (example: smtp.yourcompany.com) of the SMTP server to be used for web notification");
    $edr->{rfc}{vcs_smtpserver}=[$cmt->{msg},0,0,0];
    $email="user\@yourcompany.com";
    $cmt=Msg::new("This variable defines a list of full email addresses (example: $email) of SMTP recipients");
    $edr->{rfc}{vcs_smtprecp}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the minimum severity level of messages (Information, Warning, Error, SevereError) that listed SMTP recipients are to receive");
    $edr->{rfc}{vcs_smtpserv}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the SNMP trap daemon port (default=162)");
    $edr->{rfc}{vcs_snmpport}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines a list of SNMP console system names");
    $edr->{rfc}{vcs_snmpcons}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the minimum severity level of messages (Information, Warning, Error, SevereError) that listed SNMP consoles are to receive");
    $edr->{rfc}{vcs_snmpcsev}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the NIC for the Virtual IP used for the Global Cluster Option.  'ALL' can be entered as a system value if the same NIC is used on all systems");
    $edr->{rfc}{vcs_gconic}=[$cmt->{msg},0,0,1];
    $cmt=Msg::new("This variable defines the virtual IP address to be used by the Global Cluster Option");
    $edr->{rfc}{vcs_gcovip}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the Netmask of the virtual IP address to be used by the Global Cluster Option)");
    $edr->{rfc}{vcs_gconetmask}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the security of the Global Cluster Option(0=unsecure,1=secure)");
    $edr->{rfc}{vcs_securegco}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines a list of VCS usernames");
    $edr->{rfc}{vcs_username}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines each user's VCS privileges");
    $edr->{rfc}{vcs_userpriv}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines an encrypted password for each VCS user");
    $edr->{rfc}{vcs_userenpw}=[$cmt->{msg},0,1,0];
    $prod=$cpic->prod;
    $cmt=Msg::new("This variable defines whether a single node $prod->{abbr} configuration should start GAB and LLT or not.");
    $edr->{rfc}{vcs_allowcomms}=[$cmt->{msg},1,0,0];
    #add new global variable for AT configuration
    $cmt=Msg::new("This variable defines if user chooses to set the cluster in secure enabled mode or not");
    $edr->{rfc}{vcs_eat_security}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines if user chooses to set the cluster in security with fips mode or not");
    $edr->{rfc}{vcs_eat_security_fips}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines whether to configure secure cluster node by node");
    $edr->{rfc}{opt__securityonenode}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the menu option number chosen to configure the secure cluster one by one");
    $edr->{rfc}{securityonenode_menu}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the folder where the configuration files are placed");
    $edr->{rfc}{security_conf_dir}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines whether to enable or disable secure mode on a running VCS cluster.");
    $edr->{rfc}{opt__security}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines whether to enable or disable security with fips mode on a running VCS cluster. It could only be used together with -security or -securityonenode option");
    $edr->{rfc}{opt__fips}=[$cmt->{msg},0,0,0];

    $cmt=Msg::new("This variable defines fencing as enabled");
    $edr->{rfc}{fencingenabled}=[$cmt->{msg},1,0,0];
    #$cmt=Msg::new("This variable defines a series of sub-cluster division. The index N indicatse the order to do RU phase1. The index starts from 0. Each item has a list of node(at least 1)");
    #$edr->{rfc}{phase1}{'#'}=[$cmt->{msg},0,1,0];
    $pkg=$prod->pkg('VRTSvxfen61');
    $pkg->responsefile_comments_for_fencing();
    $pkg=$prod->pkg('VRTScps61');
    $pkg->responsefile_comments_for_cps();
    return;
}

sub prestart_config_common_questions {
    my ($ayn,$cfg,$cpic,$sys0,$syslist,$cprod,$msg,$prod,$rel,$rtn);
    my ($askreconfigurevcs);
    $prod=shift;

    $cpic = Obj::cpic();
    $syslist=CPIC::get('systems');
    $sys0 = $$syslist[0];
    $cprod=CPIC::get('prod');
    $cfg = Obj::cfg();

    Msg::log("start VCS prestart_config_questions\n");
    $cfg->{vcs_allowcomms} = 1;
    #if ((($cprod eq 'VCS61')||($cprod eq 'SFHA61')) && (!$cfg->{fencingenabled})) {
    if ($cprod eq 'VCS61'||$cprod eq 'SFHA61'){
        if (scalar(@$syslist) == 1) {
            my $addmsg = Msg::new("If you plan to run $prod->{abbr} on a single node without any need for adding cluster node online, you have an option to proceed without starting GAB and LLT. Starting GAB and LLT is recommended.");
            $addmsg->bold;
            Msg::n();
            $msg = Msg::new("Do you want to start GAB and LLT?");
            $rtn = $msg->ayny('','',$addmsg);
            Msg::n();
            if ($rtn eq 'N') {
                $cfg->{vcs_allowcomms} = 0;
            }
        }
    }

    if ($cfg->{vcs_allowcomms} && $cprod!~/^SFRAC\d+/mx && $cprod!~/^SFSYBASECE\d+/) {
        $prod->ask_fencing_enabled() unless (Cfg::opt('makeresponsefile'));
    }

     # Due to incident 1823124, we do NOT ask user to reconfigure VCS if -responsefile is used and $cfg->{donotreconfigurevcs} not defined
     # check uuid, if uuid is not configured on systems, then it means that product is not configured before.
     if (Cfg::opt('responsefile') && !defined($cfg->{donotreconfigurevcs})) {
         $askreconfigurevcs=0;
     } elsif ($prod->check_config() && $prod->check_uuid()) {
         $askreconfigurevcs=1;
     }
     if ($askreconfigurevcs) {
        $rel=$prod->rel($prod->{padv});
        $msg=Msg::new("Installer has detected that $prod->{abbr} is already configured. If you re-configure $prod->{abbr}, you will lose all the current configurations in main.cf. And you need to offline all the resources manually before proceeding.\nIf you select not to re-configure, $prod->{abbr} configurations will not be changed and installer will start the processes with existing configuration. Make sure all the current configurations are compatible with $rel->{titlevers}.\n\nDo you want to re-configure $prod->{abbr}?");
        $ayn = $msg->aynn;
        Msg::n();
        if ($ayn eq 'N') {
            if (!$prod->vxfen_reuse_precheck()) {
                $msg = Msg::new("Do you want to continue?");
                $rtn = $msg->aynn();
                Msg::n();
                $cpic->completion() if ($rtn eq 'N');
            }
            $cfg->{donotreconfigurevcs}=1;
            # link install: enable vcs
            for my $sys(@$syslist) {
                $prod->vcs_enable_sys($sys);
            }
            return 0;
        }
        $cfg->{reconfigurevcs}=1;
        # As long as user decide to reconfigure $prod,
        # CPI will always stop all the processes in case 
        # the new configuration could not apply to the system.
        Cfg::set_opt('configure',1);
        foreach my $each_sys (@$syslist) {
            delete $each_sys->{vcs_conf};
        }
        if ($sys0->exists($prod->{vxfenmode})) {
            # save previous vxfen info
            $prod->{vxfen_conf} = $prod->get_vxfen_config_sys($sys0);
        }
    }
    Msg::title();
    $msg=Msg::new("To configure $prod->{abbr}, answer the set of questions on the next screen.\n");
    $msg->print;
    $msg=Msg::new("When [b] is presented after a question, 'b' may be entered to go back to the first question of the configuration set.\n");
    $msg->print;
    $msg=Msg::new("When [?] is presented after a question, '?' may be entered for help or additional information about the question.\n");
    $msg->print;
    $msg=Msg::new("Following each set of questions, the information you have entered will be presented for confirmation.  To repeat the set of questions and correct any previous errors, enter 'n' at the confirmation prompt.\n");
    $msg->print;
    if (Cfg::opt('configure')) {
        $msg = Msg::new("No configuration changes are made to the systems until all configuration questions are completed and confirmed.");
        $msg->print;
    } else {
        $msg = Msg::new("No configuration changes are made to the systems until all configuration questions are completed and $prod->{abbr} is installed successfully.");
        $msg->print;
    }
    Msg::prtc();
    return 1;
}

sub cli_prestart_config_questions {
    my $prod=shift;
    my $cprod=CPIC::get('prod');

    return 1 unless($prod->prestart_config_common_questions);
    $prod->config_cluster();
    return 1 if ($cprod=~/SFCFS\d+/m);
    $prod->config_vip();
    $prod->config_vxss();
    $prod->add_users();
    $prod->config_smtp();
    $prod->config_snmp();
    $prod->config_gcoption();
    return;
}

sub web_autocfg_hbnics {
    my ($msg);
    my $prod = shift;

    my $web = Obj::web();
    my $cfg = Obj::cfg();

    my $rhbn = $prod->autocfg_hbnics();
    if ($prod->num_hbnics($rhbn)< 1) {
        # auto detect failed
        $msg=Msg::new("Failed to detect and configure LLT heartbeat links. Configure LLT manually.");
        $web->web_script_form('alert',$msg->{msg});
    } else {
        my $notice;
        for my $sysi (@{CPIC::get('systems')}) {
            my $sys = $sysi->{sys};
            my $lmsg='';
            for my $n (1..$prod->num_hbnics($rhbn)) {
                my $key="lltlink$n";
                next unless ($rhbn->{$key}{$sys});
                $lmsg.="\nlink$n=$rhbn->{$key}{$sys}";
            }
            $notice .= Msg::new("Private Heartbeat NICs for $sys: $lmsg")->{msg};
            $notice .= "\n";

            if ($prod->num_lopri_hbnics($rhbn) > 0) {
                $lmsg = '';
                for my $n (1..$prod->num_lopri_hbnics($rhbn)) {
                    my $key="lltlinklowpri$n";
                    $lmsg.="\nlink-lowpri$n=$rhbn->{$key}{$sys}";
                }
                if ($prod->num_lopri_hbnics($rhbn) > 1) {
                    $notice .= Msg::new("Low-Priority Heartbeat NICs for $sys: $lmsg")->{msg};
                } else {
                    $notice .= Msg::new("Low-Priority Heartbeat NIC for $sys: $lmsg")->{msg};
                }
                $notice .= "\n";
            }
        }
        if ($web->{config_mode} eq 'typical') {
            Msg::log($notice);
            $web->{rhbn} = $rhbn;
            return 1;
        }
        $msg = Msg::new("Do you want to use this heartbeat configuration?");
        my $answer = $msg->aynn('','',$notice);
        if ($answer eq 'Y') {
            $web->{rhbn} = $rhbn;
            return 1;
        }
    }
    return 0;
}

sub web_prestart_config_questions {
    my ($rtvalue,$prod,$web,$cfg,$key,$msg,$help,$ayn,$multinode,$rpn,$alertmsg,$nic);
    $prod = shift;

    $cfg = Obj::cfg();
    $web = Obj::web();
    $web->{vxss_enabled} = 0;
    $web->{check_clus_id} = 1;

    return 1 unless($prod->prestart_config_common_questions);

    while (1) {
        $cfg->{vcs_allowcomms} = 1 unless (defined($cfg->{vcs_allowcomms}));
        $multinode = 1 if ($cfg->{vcs_allowcomms});
        if ($multinode) {
            $rtvalue=$web->web_script_form('vcs_select_cluster');
            if ($web->{numOfHeartbeats}+$web->{numOfLowPriority} == 1) {
                $alertmsg = Msg::new("You only selected one heartbeat for the cluster, it is strongly recommended to add more than one heartbeat.");
                $web->web_script_form('alert',$alertmsg->{msg});
            }
            if($web->{llt_rdma}){
                delete $web->{llt_rdma};
                next unless($prod->setup_rdma_env());
                $cfg->{lltoverudp} = 0;
                $cfg->{autocfgllt} = 0;
                $prod->{llt_rdma} = 1;
            }
            if ($cfg->{autocfgllt}) {
                if (!$prod->web_autocfg_hbnics()) {
                    $cfg->{autocfgllt} = 0;
                    next;
                }
            } else {
                my $unique = $web->{uniqueNicsPerSys};
                for my $sys (@{CPIC::get('systems')}) {
                    my $padv = $sys->padv;
                    my $nics = $padv->systemnics_sys($sys,1);
                    $rtvalue=$web->web_script_form('vcs_select_heartbeats', 'configure', $nics, $sys);
                    $rpn=$padv->gatewaynics_sys($sys);
                    $alertmsg = '';
                    for my $n (1..$web->{numOfHeartbeats}) {
                        $nic = $web->{rhbn}{"lltlink$n"}{$sys->{sys}};
                        if (EDRu::arrpos($nic,@$rpn)>=0){
                            $alertmsg.=Msg::new("$nic has an IP address configured on it. It could be a public NIC on $sys->{sys}.\\n")->{msg};
                        }
                    }
                    $web->web_script_form('alert',$alertmsg) if ($alertmsg ne '');
                    last if($rtvalue eq 'back');
                    last unless $unique;
                }
                next if($rtvalue eq 'back');
                my $diff = $prod->check_link_speed(CPIC::get('systems'),$web->{rhbn});
                next if (!$prod->web_check_link_speed($diff));

                if ($diff){
                    if ($prod->num_hbnics($web->{rhbn}) > 1) {
                        for my $n (2..$prod->num_hbnics($web->{rhbn})) {
                            $key="lltlink$n".'_low';
                            if ($web->{rhbn}->{$key} != $web->{rhbn}->{lltlink1_low}) {
                                $msg = Msg::new("Do you want to configure lower speed NICs as low-priority links?");
                                $help = Msg::new("The performance of LLT would be decreased if NICs with lower media speed were used as high priority private links. The overall performance of LLT will be the same as the high priority link with the lowest media speed.");
                                $ayn = $msg->ayny($help);
                                if ( $ayn eq 'Y' ) {
                                    $web->{rhbn} = $prod->set_lowpri_for_slow_links($web->{rhbn});
                                }
                                last;
                            }
                        }
                    }
                }
            }

            while ($web->{check_clus_id}) {
                delete $web->{check_clus_id};
                my $rtn = $prod->check_clusterid($cfg->{vcs_clusterid},$web->{rhbn});
                if ($rtn == 1) {
                    #$prod->web_config_clusterid($web->{rhbn});
                    $msg = Msg::new("The Cluster ID $cfg->{vcs_clusterid} is already in use. Enter a different Cluster ID.");
                    $cfg->{vcs_clusterid} = $web->web_script_form('vcs_cluster_id', $msg);
                } elsif ($rtn == -1) {
                    $msg = Msg::new("Failed to check if the cluster ID is in use. It is recommended to make sure that the cluster ID is not in use by another cluster.");
                    $cfg->{vcs_clusterid} = $web->web_script_form('vcs_cluster_id', $msg);
                }
            }
        } else {
            $rtvalue=$web->web_script_form('vcs_cluster_name');
        }

        my $webmsg = $prod->display_config_info($cfg->{vcs_clustername},$cfg->{vcs_clusterid},$web->{rhbn});

        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny('','',$webmsg);
        if ($ayn eq 'N') {
            next;
        }

        $rtvalue=$web->web_script_form('vcs_optional');
        next if($rtvalue eq 'back');

        if(($web->need_to_conf_nwh($prod))){
            $rtvalue=$web->web_script_form('vcs_nwhosts',$prod);
            next if($rtvalue eq 'back');
        }
        if ($cfg->{vcs_eat_security}) {
            if (!$prod->eat_configure_precheck()) {
                my $errmsg = Msg::new("Symantec Security Services could not be used.");
                $web->web_script_form('alert',$errmsg);

                delete $cfg->{vcs_eat_security};
            }
        }

        $prod->set_hb_nics($web->{rhbn},CPIC::get('systems'));
        # delete this hash key so that it do not show in responsefile
        delete $cfg->{autocfgllt};
        last; # done
    }
    return;
}

sub cli_poststart_config_questions {
    my ($prod) = @_;
    my ($cfg,$pkg,$cprod);
    $cfg=Obj::cfg();
    $cprod=CPIC::get('prod');
    if ($cprod=~/^SFSYBASECE\d+/mx) {
        $prod->ask_fencing_enabled() unless (Cfg::opt('makeresponsefile'));
    }
    if ($cfg->{fencingenabled}) {
        $pkg=$prod->pkg('VRTSvxfen61');
        $pkg->config_vxfen();
    }
    return;
}

sub web_poststart_config_questions {
    my ($prod) = @_;
    my ($cfg,$pkg);
    $cfg=Obj::cfg();
    if ($cfg->{fencingenabled}) {
        $pkg=$prod->pkg('VRTSvxfen61');
        $pkg->config_vxfen();
    }
    return;
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);

    $cpic = Obj::cpic();
    $rel = $cpic->rel;

    $prod->is_features_licensed_sys($sys);
    return $rel->prod_licensed_sys($sys);
}

sub is_features_licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);
    $cpic = Obj::cpic();
    $rel = $cpic->rel;
    if ($rel->feature_licensed_sys($sys, 'Global Cluster Option')) {
        Cfg::set_opt('gco');
    }
    return;
}


# if a nic is configured with IPv6 and the input IP addres is IPv6 then Set Protocol=IPv6, return 0;
sub nic_ipv6_sys {
    my ($prod,$sys,$nic) = @_;
    my ($cfg,$ips,$padv,$hasipv6,$gcoip,$ip);

    $cfg=Obj::cfg();
    $padv=$sys->padv;
    if($gcoip){
        $gcoip="$cfg->{vcs_gcovip}";
    } else {
        $gcoip="$cfg->{vcs_csgvip}";
    }

    $ips=$padv->nic_ips_sys($sys,$nic);
    for my $ip (@{$ips}) {
        $hasipv6=1 if(EDRu::ip_is_ipv6($ip));
    }
    return 1 if($hasipv6 && EDRu::ip_is_ipv6($gcoip));
    return 0;
}


#Protocol @sys1=IPv6
#Protocol @sys2=IPv6
sub nic_protocol_attr {
    my ($prod,$gco) = @_;
    my ($sys,$sysname,$ipv6,$attr,$nic,$cfg);
    return if(EDRu::plat($prod->{padv}) eq 'Linux');
    $nic='vcs_csgnic';
    $nic='vcs_gconic' if ($gco);

    $cfg=Obj::cfg();
    for my $sys (@{CPIC::get('systems')}) {
        $sysname =transform_system_name($sys->{sys});
        if ($cfg->{$nic}{all}) {
            $ipv6=$prod->nic_ipv6_sys($sys,$cfg->{$nic}{all},$gco);
        } elsif($cfg->{$nic}{$sys->{sys}})  {
            $ipv6=$prod->nic_ipv6_sys($sys,$cfg->{$nic}{$sys->{sys}},$gco);
        }
        $attr .="Protocol \@$sysname=IPv6\n" if ($ipv6);
    }
    return $attr;
}

sub ask_nhip {
    my ($prod,$sys)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt=1;
    while (!$done) {
        $help=Msg::new("List of hosts on the network to which the agent pings to determine if the network connection is alive.");
        $msg=Msg::new("Enter the NetworkHosts IP addresses, separated by spaces:");
        $answer=$msg->ask('',$help,$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        if (!$prod->validate_nwhosts($answer)) {
            $msg=Msg::new("$answer contains invalid IP address");
            $msg->print;
            next;
        }
        $done=1;
    }
    return $answer;
}

# Configure the Virtual IP
sub config_vip {
    my ($prod) = @_;
    my $cfg = Obj::cfg();
    return if (Cfg::opt('responsefile'));
    my($ayn,$cmsg,$done,$msg,$msg0,$help,$backopt,$netm,$vipnic,$vip,$prefix,$nwhosts,$nonhip,$nhip);
    while (!$done) {
        $backopt = 0;
        undef($nwhosts);
        Msg::title();
        $help = Msg::new("Virtual IP is the IP address that can move from one NIC to another or from one node to another. VCS fails over the IP address with your application. Virtual IP can be specified in RemoteGroup resource and can be used to connect to the cluster for administration.");
        $msg = Msg::new("You can configure it manually later if you are not ready to configure it at this time. Refer to $prod->{name} administrator's guide for the commands of manual configuration");
        $help->{msg} .= "\n$msg->{msg}";
        $msg = Msg::new("The following data is required to configure the Virtual IP of the Cluster:\n");
        $msg->bold;
        $msg = Msg::new("\tA public NIC used by each system in the cluster");
        $msg->print;
        $msg = Msg::new("\tA Virtual IP address and netmask");
        $msg->print;

        if (EDRu::plat($prod->{padv}) eq 'HPUX') {
            $msg=Msg::new("\tOne or more NetworkHosts IP addresses for connection checking\n");
            $msg->print;
            $nonhip=1;
        } else {
            Msg::n();
        }
        $msg = Msg::new("Do you want to configure the Virtual IP?");
        $ayn = $msg->aynn($help,$backopt);
        return if ($ayn eq 'N');

        Msg::n();
        $vipnic = $prod->ask_publicnic;
        next if (EDR::getmsgkey($vipnic,'back'));
        $vip = $prod->ask_vip;
        next if (EDR::getmsgkey($vip,'back'));
        $netm = $prod->ask_netmask($vip,$$vipnic{${$cfg->{systems}}[0]});
        next if (EDR::getmsgkey($netm,'back'));
        # AIX virtual nic specific configuration
        if ($prod->has_virtual_nic()) {
            $nwhosts=$prod->ask_networkhosts_csg($vipnic);
            next if (EDR::getmsgkey($nwhosts,'back'));
        }
        # HP specific network host configuration
        $nhip=$prod->ask_nhip() if ($nonhip);
        next if (EDR::getmsgkey($nhip,'back'));

        Msg::title();
        if (EDRu::ip_is_ipv6($vip)) {
            $prefix=Msg::new("Prefix");
        } else {
            $prefix=Msg::new("NetMask");
        }
        $msg = Msg::new("Cluster Virtual IP verification:\n");
        $msg->bold;
        $msg0 = $prod->display_csgnic($vipnic);
        $msg = Msg::new("\tIP: $vip\n");
        $msg0 .= $msg->{msg};
        $msg = Msg::new("\t$prefix->{msg}: $netm\n");
        $msg0 .= $msg->{msg};
        $msg0.=$prod->display_csgnwhosts($nwhosts) if ($nwhosts);
        if ($nhip) {
            $msg = Msg::new("\tNetworkHosts: $nhip\n");
            $msg0 .= $msg->{msg};
        }
        Msg::print($msg0);
        $backopt = 0;
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny;
        $done = 1 if ($ayn eq 'Y');
    }
    $prod->store_nic($vipnic,'vcs_csgnic');
    $cfg->{vcs_csgvip} = $vip;
    $cfg->{vcs_csgnetmask} = $netm;
    $cfg->{vcs_networkhosts} = $nhip if ($nhip);
    $prod->store_nwhosts_csg($nwhosts) if ($nwhosts);
    $msg = Msg::new("Cluster Virtual IP configuration:\n");
    $cmsg = $msg->{msg};
    push(@{$prod->{configmsg}},$cmsg,$msg0);
    return;
}



# Configure the Global Cluster Option
# Copies CSGVIP most likely if configured
sub config_gcoption {
    my ($prod) = @_;
    my $cfg = Obj::cfg();
    return '' unless (Cfg::opt('gco'));
    return '' if (Cfg::opt('responsefile'));

    my($ayn,$cmsg,$done,$msg,$msg0,$help,$backopt,$netm,$rgconic,$vip,$prefix,$nwhosts,$sys0,$nonhip,$nhip);

    while (!$done) {
        $backopt = 0;
        undef($nwhosts);
        Msg::title();
        $msg = Msg::new("The following data is required to configure the Global Cluster Option:\n");
        $msg->bold;
        $msg = Msg::new("\tA public NIC used by each system in the cluster");
        $msg->print;
        $msg = Msg::new("\tA Virtual IP address and netmask");
        $msg->print;
        if ((EDRu::plat($prod->{padv}) eq 'HPUX') && !$cfg->{vcs_csgvip} && !$cfg->{vcs_smtpserver} && !$cfg->{vcs_snmpport}) {
            $msg=Msg::new("\tOne or more NetworkHosts IP addresses for connection checking\n");
            $msg->print;
            $nonhip=1;
        } else {
            Msg::n();
        }

        $help = Msg::new("If Global Cluster Option is configured, then the connection between the global clusters will be available to the user");
        $msg = Msg::new("You can configure it manually later if you are not ready to configure it at this time, refer to $prod->{name} administrator's guide for the commands of manual configuration");
        $help->{msg} .= "\n$msg->{msg}";
        $msg = Msg::new("Do you want to configure the Global Cluster Option?");
        $ayn = $msg->aynn($help,$backopt);
        Msg::n();
        return if ($ayn eq 'N');

        $backopt = 1;
        if ($cfg->{vcs_csgvip}) {
            $vip = $prod->ask_vip($cfg->{vcs_csgvip},1);
            next if (EDR::getmsgkey($vip,'back'));
            if ($vip eq $cfg->{vcs_csgvip}) {
                $rgconic = $prod->{rcsgnic};
                $netm = $cfg->{vcs_csgnetmask};
            } else {
                $rgconic = $prod->ask_publicnic(2);
                next if (EDR::getmsgkey($rgconic,'back'));
                $netm = $prod->ask_netmask($vip,$$rgconic{${$cfg->{systems}}[0]});
                next if (EDR::getmsgkey($netm,'back'));
            }
        } else {
            $rgconic = $prod->ask_publicnic(2);
            next if (EDR::getmsgkey($rgconic,'back'));
            $vip = $prod->ask_vip('',1);
            next if (EDR::getmsgkey($vip,'back'));
            $netm = $prod->ask_netmask($vip,$$rgconic{${$cfg->{systems}}[0]});
            next if (EDR::getmsgkey($netm,'back'));
        }
        # AIX virtual nic specific configuration
        if ($prod->has_virtual_nic()) {
            $nwhosts=$prod->ask_networkhosts_gco($rgconic);
            next if (EDR::getmsgkey($nwhosts,'back'));
        }
        # HP specific network host configuration
        $nhip=$prod->ask_nhip() if ($nonhip);
        next if (EDR::getmsgkey($nhip,'back'));

        Msg::title();
        if ( EDRu::ip_is_ipv6($vip)) {
            $prefix=Msg::new("Prefix");
        } else {
            $prefix=Msg::new("NetMask");
        }
        $msg = Msg::new("Global Cluster Option configuration verification:\n");
        $msg->bold;
        $msg0 = $prod->display_csgnic($rgconic);
        $msg = Msg::new("\tIP: $vip\n");
        $msg0 .= $msg->{msg};
        $msg = Msg::new("\t$prefix->{msg}: $netm\n");
        $msg0 .= $msg->{msg};
        if ($nwhosts && %{$nwhosts}) {
            $sys0 = ${CPIC::get('systems')}[0];
            $msg = Msg::new("\tNetworkhosts: $nwhosts->{$sys0->{sys}}\n");
            $msg0 .= $msg->{msg};
        }
        if ($nhip) {
            $msg = Msg::new("\tNetworkHosts: $nhip\n");
            $msg0 .= $msg->{msg};
        }
        Msg::print($msg0);

        if ($vip eq $cfg->{vcs_csgvip}) {
            $msg = Msg::new("Matching the Cluster Virtual IP configuration\n");
            $msg->print;
        }
        $backopt = 0;
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny;
        $done = 1 if ($ayn eq 'Y');
    }

    $prod->store_nic($rgconic,'vcs_gconic');
    $cfg->{vcs_gcovip} = $vip;
    $cfg->{vcs_gconetmask} = $netm;
    $cfg->{vcs_gconwhosts} = $nwhosts->{$sys0->{sys}} if ($nwhosts);
    $cfg->{vcs_networkhosts} = $nhip if ($nhip);
    $msg = Msg::new("Global Cluster Option configuration:\n");
    $cmsg = $msg->{msg};
    push(@{$prod->{configmsg}},$cmsg,$msg0);
    return;
}

sub store_nwhosts_csg {
    my ($prod,$rnwhosts) = @_;
    my ($sys,$syslist,$cfg);

    $syslist=CPIC::get('systems');
    $cfg = Obj::cfg();
    for my $sys (@$syslist) {
        $cfg->{vcs_csgnwhosts}{$sys->{sys}} = $rnwhosts->{$sys->{sys}};
    }
    return;
}

sub has_virtual_nic {
    my ($prod)=@_;
    my ($sys,$syslist,$ret,$padv);
    #Only Aix has sub virtualnics_sys for now.
    $padv = $prod->padv;
    return 0 unless $padv->can('virtualnics_sys');
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $sys->{vionics}=$sys->padv->virtualnics_sys($sys);
        $ret||=1 if ($sys->{vionics});
    }
    return $ret;
}

sub ask_networkhosts_gco {
    my ($prod,$rnic)=@_;
    my ($sys,$syslist,$sys0,%nwhosts,$msg,$help,$backopt,$nic,$done,$answer);

    return 0 if (!$rnic);
    $backopt=1;
    $syslist=CPIC::get('systems');
    $sys0=$$syslist[0];

    for my $sys (@$syslist) {
        $nic=$$rnic{$sys->{sys}};
        if (EDRu::inarr($nic, @{$sys->{vionics}})) {
            while (!$done) {
                $msg=Msg::new("Enter the NetworkHosts for the Global Cluster Option:");
                $help=Msg::new("You have a virtual device for your Global Cluster Option, hence NetworkHosts attribute is needed for a virtual device.");
                $answer=$msg->ask('',$help,$backopt);
                return $answer if (EDR::getmsgkey($answer,'back'));
                if ($prod->validate_nwhosts($answer)) {
                    $done=1;
                    $nwhosts{$sys0->{sys}}=$answer;
                } else {
                    $msg=Msg::new("The NetworkHosts, $answer, is not a vaild ip address");
                    $msg->print;
                }
            }
        }
        last if ($nwhosts{$sys0->{sys}});
    }
    return \%nwhosts;
}

sub ask_networkhosts_csg {
    my ($prod,$rnic)=@_;
    my ($aayn,$sys,$syslist,$sys0,%nwhosts,$msg,$help,$backopt,$nic,$all,$answer,$firstanswer,$done);

    return 0 if (!$rnic);
    $backopt=1;
    $syslist=CPIC::get('systems');
    $sys0=$$syslist[0];
    $firstanswer=1;
    for my $sys (@$syslist) {
        $nic=$$rnic{$sys->{sys}};
        if ($all) {
            if (EDRu::inarr($nic, @{$sys->{vionics}})) {
                $nwhosts{$sys->{sys}}=$answer;
                next;
            }
        }
        if (EDRu::inarr($nic, @{$sys->{vionics}})) {
            $done=0;
            while (!$done) {
                $msg=Msg::new("$nic on $sys->{sys} is a virtual device. Enter its NetworkHosts:");
                $help=Msg::new("You must configure the NetworkHosts attribute for a virtual device. NetworkHosts is a list of hosts on the network that are pingable to determine if the network connection is alive. Enter the IP address of the host instead of the host name to prevent the monitor from timing out.");
                $answer=$msg->ask('',$help,$backopt);
                return $answer if (EDR::getmsgkey($answer,'back'));
                if ($prod->validate_nwhosts($answer)) {
                    $done=1;
                    $nwhosts{$sys->{sys}}=$answer;
                    if ($firstanswer==1) {
                        $firstanswer=0;
                        $msg=Msg::new("Do you want to apply the same NetworkHosts ($answer) for all systems?");
                        $help=Msg::new("The NetworkHosts will only be applied on systems which have virtual nics");
                        $aayn=$msg->ayny($help,$backopt);
                        return $aayn if (EDR::getmsgkey($aayn,'back'));
                        $all=1 if ($aayn eq 'Y');
                    }
                } else {
                    $msg=Msg::new("The NetworkHosts ($answer) is not a vaild ip address");
                    $msg->print;
                }
            }
        }
    }
    return \%nwhosts;
}

sub validate_nwhosts {
    my ($prod,$nwhosts)=@_;

    for my $ip (split(/\s+/,$nwhosts)) {
        return 0 if (!EDRu::isip($ip));
    }
    return 1;
}

# ask for the netmask on a public nic
sub ask_netmask {
    my ($prod,$vip,$nic) = @_;
    my ($msg,$help,$question,$answer,$cfg,$def,$sys,$netm,$backopt,$prefix);

    $cfg = Obj::cfg();
    $backopt = 1;
    $sys=${CPIC::get('systems')}[0];
    $def = $sys->defaultnetmask($vip,$nic);
    if(EDRu::ip_is_ipv6($vip)) {
        $prefix=Msg::new("Prefix");
    } else {
        $prefix=Msg::new("NetMask");
    }
    $help = Msg::new("The $prefix->{msg} that is configured for the physical address of this NIC (default selection) is typically used for logical addresses configured on the same NIC");
    $question = Msg::new("Enter the $prefix->{msg} for IP $vip:");
    while (1) {
        $netm = $question->ask($def,$help,$backopt);
        return $netm if (EDR::getmsgkey($netm,'back'));
        if (EDRu::ip_is_ipv6($vip)){
            unless ((EDRu::isint($netm) == 1) && (($netm > 0 && $netm <= 128) || ($netm == 0 && (EDRu::plat($prod->{padv}) =~ /^Linux|^SunOS/mx)))){
                $msg = Msg::new("$netm is not a valid prefix");
                $msg->print;
                next;
            }
        } else {
            if (!EDRu::isip($netm)) {
                $msg = Msg::new("$netm is not a valid netmask");
                $msg->print;
                next;
            }
        }
        return $netm;
    }
    return;
}

# ask for a virtual ip for cluster manager or the global cluster option
sub ask_vip {
    my ($prod,$def,$gco) = @_;
    my ($answer,$help,$msg,$backopt,$question);

    $backopt = 1;
    $help = Msg::new("A virtual address is an IP address that is configured on a public NIC interface on one system in a cluster at any given time to perform specific services that must remain highly available.");
    if($gco){
        $question = Msg::new("Enter the Virtual IP address for the Global Cluster Option:");
    }else{
        $question = Msg::new("Enter the Virtual IP address for the Cluster:");
    }
    while(1) {
        $answer = $question->ask($def,$help,$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        if (!EDRu::isip($answer)) {
            $msg = Msg::new("$answer is not a valid IP address");
            $msg->print;
        } else {
            return $answer;
        }
    }
    return;
}

sub get_severity_msgs {
    my ($msg, $prod, $sev_msgs);

    $prod = shift;
    $msg = Msg::new("Information");
    $sev_msgs->{'Information'} = $msg->{msg};
    $msg = Msg::new("Warning");
    $sev_msgs->{'Warning'} = $msg->{msg};
    $msg = Msg::new("Error");
    $sev_msgs->{'Error'} = $msg->{msg};
    $msg = Msg::new("SevereError");
    $sev_msgs->{'SevereError'} = $msg->{msg};
    return $sev_msgs;
}

# configure snmp notification:
# the snmp trap port, snmp consoles, and severity for each
sub config_snmp {
    my ($prod) = @_;
    my ($cfg,@conss,@sevs,$ayn,$cmsg,$cons,$done,$msg,$msg0,$help,$n,$backopt,$port,$rcsgnic,$sev,$nwhosts,$nonhip,$nhip);
    return if (Cfg::opt(qw(installonly responsefile)));

    $cfg = Obj::cfg();
    my $sev_msgs = $prod->get_severity_msgs;
    while (!$done) {
        undef(@conss);
        undef(@sevs);
        undef($nwhosts);
        Msg::title();
        $msg = Msg::new("The following information is required to configure SNMP notification:\n");
        $msg->bold;
        $msg = Msg::new("\tSystem names of SNMP consoles to receive VCS trap messages");
        $msg->print;
        $msg = Msg::new("\tSNMP trap daemon port numbers for each console");
        $msg->print;
        $msg = Msg::new("\tA minimum severity level of messages to send to each console");
        $msg->print;
        if ((EDRu::plat($prod->{padv}) eq 'HPUX') && !$cfg->{vcs_csgvip} && !$cfg->{vcs_smtpserver}) {
            $msg=Msg::new("\tOne or more NetworkHosts IP addresses for connection checking\n");
            $msg->print;
            $nonhip=1;
        } else {
            Msg::n();
        }

        $help = Msg::new("If SNMP is configured, VCS trap messages can be delivered to various systems");
        $msg = Msg::new("You can configure it manually later if you are not ready to configure it at this time, refer to $prod->{name} administrator's guide for the commands of manual configuration");
        $help->{msg} .= "\n$msg->{msg}";
        $msg = Msg::new("Do you want to configure SNMP notification?");
        $ayn = $msg->aynn($help,0);
        Msg::n();
        return if ($ayn eq 'N');

        $backopt = 1;
        $rcsgnic = $prod->ask_publicnic(1);
        next if (EDR::getmsgkey($rcsgnic,'back'));

        # AIX virtual nic specific configuration
        if ($prod->has_virtual_nic()) {
            if (!$prod->has_same_csg($rcsgnic)) {
                $nwhosts=$prod->ask_networkhosts_csg($rcsgnic);
                next if (EDR::getmsgkey($nwhosts,'back'));
            }
        }
        # HP specific network host configuration
        $nhip=$prod->ask_nhip() if ($nonhip);
        next if (EDR::getmsgkey($nhip,'back'));

        $port = $prod->ask_snmpport;
        next if (EDR::getmsgkey($port,'back'));

        while (($#conss<0) || ($ayn eq 'Y')) {
            $cons = lc($prod->ask_snmpconsole);
            last if (EDR::getmsgkey($cons,'back'));
            $sev = $prod->ask_severity($cons,1);
            last if (EDR::getmsgkey($sev,'back'));

            $n = EDRu::arrpos($cons,@conss);
            if ($n>=0) {
                $msg = Msg::new("$cons was previously entered. Changing priority to $sev_msgs->{$sev}.");
                $msg->print;
                $sevs[$n] = $sev;
            } else {
                push(@conss,$cons);
                push(@sevs,$sev);
            }

            $msg = Msg::new("Would you like to add another SNMP console?");
            $ayn = $msg->aynn(0,$backopt);
        }
        next if (EDR::getmsgkey($ayn,'back') || EDR::getmsgkey($cons,'back') || EDR::getmsgkey($sev,'back'));

        Msg::title();
        $msg = Msg::new("SNMP notification verification:\n");
        $msg->bold;
        $msg0 = $prod->display_csgnic($rcsgnic);
        $msg = Msg::new("\tSNMP port: $port\n");
        $msg0 .= $msg->{msg};
        for my $n (0..$#conss) {
            $msg = Msg::new("\tConsole: $conss[$n] receives SNMP traps for $sev_msgs->{$sevs[$n]} or higher events\n");
            $msg0 .= $msg->{msg};
        }
        if ($nhip) {
            $msg = Msg::new("\tNetworkHosts: $nhip\n");
            $msg0 .= $msg->{msg};
        }
        $msg0.=$prod->display_csgnwhosts($nwhosts) if ($nwhosts);
        Msg::print($msg0);
        $backopt = '';
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny;
        $done = 1 if ($ayn eq 'Y');
    }

    $prod->store_nic($rcsgnic,'vcs_csgnic');
    $cfg->{vcs_snmpport} = $port;
    $cfg->{vcs_snmpcons} = [];
    $cfg->{vcs_snmpcsev} = [];
    for my $n (0..$#conss) {
        push(@{$cfg->{vcs_snmpcons}},$conss[$n]);
        push(@{$cfg->{vcs_snmpcsev}},$sevs[$n]);
    }
    $cfg->{vcs_networkhosts} = $nhip if ($nhip);
    $prod->store_nwhosts_csg($nwhosts) if ($nwhosts);
    $msg = Msg::new("SNMP notification configuration:\n");
    $cmsg = $msg->{msg};
    push(@{$prod->{configmsg}},$cmsg,$msg0);
    return;
}


# ask for an snmp console server
sub ask_snmpconsole {
    my ($prod) = @_;
    my ($cons,$ping,$help,$msg,$backopt,$edr,$def);

    $backopt = 1;
    $edr = Obj::edr();

    $help = Msg::new("The console designated will receive notification of $prod->{abbr} events via SNMP trap messages");
    while (1) {
        $msg = Msg::new("Enter the SNMP console system name:");
        $cons = $msg->ask($def,$help,$backopt);
        return $cons if (EDR::getmsgkey($cons,'back'));

        #check the ping state of console system.
        my $localsys=EDR::get('localsys');

        $ping = $localsys->padv->ping($cons);
        if ($ping) {
            $msg = Msg::new("Cannot ping $cons");
            $msg->print;
        } else {
            return $cons;
        }
    }
    return;
}

# ask for the snmp port, default is 162
sub ask_snmpport {
    my ($prod) = @_;
    my ($ayn,$port,$def,$backopt,$msg,$help);

    $def = 162;
    $backopt = 1;
    $help = Msg::new("SNMP traps are sent to a specific port on each console server.  The default port number for SNMP trap messages is 162.");
    while (1) {
        $msg = Msg::new("Enter the SNMP trap daemon port:");
        $port = $msg->ask($def, $help, $backopt);
        return $port if (EDR::getmsgkey($port,'back'));

        if (($port>65535) || ($port<0) || ($port=~/\D/m)) {
            $msg = Msg::new("$port is an invalid port number");
            $msg->print;
        } elsif (($port!=162) && ($port<=1024)) {
            $msg = Msg::new("Are you sure you want to use $port as the SNMP trap port?");
            $ayn = $msg->aynn;
            return $port if ($ayn eq 'Y');
        } else {
            return $port;
        }
    }
    return;
}

# Configure SMTP Notification:
# A SMTP mail server, recipients, and severity for each
sub config_smtp {
    my ($prod) = @_;
    my (@recps,@sevs,$help,$ayn,$cfg,$cmsg,$done,$backopt,$msg,$n,$rcsgnic,$recp,$server,$sev,$msg0,$nwhosts,$nonhip,$nhip);
    return if (Cfg::opt(qw(installonly responsefile)));

    $cfg = Obj::cfg();
    my $sev_msgs = $prod->get_severity_msgs;

    $done = '';
    while (!$done) {
        undef(@recps);
        undef(@sevs);
        undef($nwhosts);
        $backopt = '';

        Msg::title();
        $msg = Msg::new("The following information is required to configure SMTP notification:\n");
        $msg->bold;
        $msg = Msg::new("\tThe domain-based hostname of the SMTP server");
        $msg->print;
        $msg = Msg::new("\tThe email address of each SMTP recipient");
        $msg->print;
        $msg = Msg::new("\tA minimum severity level of messages to send to each recipient");
        $msg->print;
        if ((EDRu::plat($prod->{padv}) eq 'HPUX') && !$cfg->{vcs_csgvip}) {
            $msg=Msg::new("\tOne or more NetworkHosts IP addresses for connection checking\n");
            $msg->print;
            $nonhip=1;
        } else {
            Msg::n();
        }

        $help = Msg::new("If SMTP is configured, status and failure messages about cluster can be delivered to users");
        $msg = Msg::new("You can configure it manually later if you are not ready to configure it at this time, refer to $prod->{name} administrator's guide for the commands of manual configuration");
        $help->{msg} .= "\n$msg->{msg}";
        $msg = Msg::new("Do you want to configure SMTP notification?");
        $ayn = $msg->aynn($help);
        return if ($ayn eq 'N');

        Msg::n();
        $backopt = 1;
        $rcsgnic = $prod->ask_publicnic(1);
        next if (EDR::getmsgkey($rcsgnic,'back'));

        # AIX virtual nic specific configuration
        if ($prod->has_virtual_nic()) {
            if (!$prod->has_same_csg($rcsgnic)) {
                $nwhosts=$prod->ask_networkhosts_csg($rcsgnic);
                next if (EDR::getmsgkey($nwhosts,'back'));
            }
        }
        # HP specific network host configuration
        $nhip=$prod->ask_nhip() if ($nonhip);
        next if (EDR::getmsgkey($nhip,'back'));

        $server = $prod->ask_smtpserver($server);
        next if (EDR::getmsgkey($server,'back'));

        while (($#recps<0) || ($ayn eq 'Y')) {
            $recp = lc($prod->ask_smtprecp($recp));
            last if ( EDR::getmsgkey($recp,'back') );
            $sev = $prod->ask_severity($recp);
            last if ( EDR::getmsgkey($sev,'back') );
            $n = EDRu::arrpos($recp,@recps);
            if ($n>=0) {
                $msg = Msg::new("$recp was previously entered. Changing priority to $sev_msgs->{$sev}.");
                $msg->print;
                $sevs[$n] = $sev;
            } else {
                push(@recps,$recp);
                push(@sevs,$sev);
            }

            $msg = Msg::new("Would you like to add another SMTP recipient?");
            $ayn = $msg->aynn(0,$backopt);
        }
        next if (EDR::getmsgkey($ayn,'back') || EDR::getmsgkey($recp,'back') || EDR::getmsgkey($sev,'back') );

        Msg::title();
        $msg = Msg::new("SMTP notification verification:\n");
        $msg->bold;
        $msg0 = $prod->display_csgnic($rcsgnic);
        $msg = Msg::new("\tSMTP Address: $server\n");
        $msg0 .= $msg->{msg};
        for my $n (0..$#recps) {
            $msg = Msg::new("\tRecipient: $recps[$n] receives email for $sev_msgs->{$sevs[$n]} or higher events\n");
            $msg0 .= $msg->{msg};
        }
        if ($nhip) {
            $msg = Msg::new("\tNetworkHosts: $nhip\n");
            $msg0 .= $msg->{msg};
        }
        $msg0.=$prod->display_csgnwhosts($nwhosts) if ($nwhosts);
        Msg::print($msg0);
        $backopt = '';
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny();
        $done = 1 if ($ayn eq 'Y');
    }

    $prod->store_nic($rcsgnic,'vcs_csgnic');
    $cfg->{vcs_smtpserver} = $server;
    $cfg->{vcs_smtprecp} = [];
    $cfg->{vcs_smtprsev} = [];
    for my $n (0..$#recps) {
        push(@{$cfg->{vcs_smtprecp}}, $recps[$n]);
        push(@{$cfg->{vcs_smtprsev}}, $sevs[$n]);
    }
    $cfg->{vcs_networkhosts} = $nhip if ($nhip);
    $prod->store_nwhosts_csg($nwhosts) if ($nwhosts);
    $cmsg = Msg::new("SMTP notification configuration:\n");
    push(@{$prod->{configmsg}},$cmsg,$msg0);
    return;
}

sub has_same_csg {
    my ($prod,$rnic)=@_;
    my ($cfg,$sys,$sys0,$syslist);

    $syslist=CPIC::get('systems');
    $cfg=Obj::cfg();
    if ( EDRu::hashvaleq($rnic)) {
        $sys0 = $$syslist[0];
        return 0 if ($cfg->{vcs_csgnic}{all} ne $$rnic{$sys0->{sys}});
    } else {
        for my $sys (@$syslist) {
            return 0 if ($cfg->{vcs_csgnic}{$sys->{sys}} ne $rnic->{$sys->{sys}});
        }
    }
    return 1;
}

# store a selected nic in a hash
sub store_nic {
    my ($prod,$rnic,$key) = @_;
    my ($sys,$sys0,$cfg);

    return if (!$rnic);
    $cfg = Obj::cfg();
    if ( EDRu::hashvaleq($rnic)) {
        $sys0 = ${CPIC::get('systems')}[0];
        $cfg->{$key}{all} = $$rnic{$sys0->{sys}};
        for my $sys (@{CPIC::get('systems')}) {
            undef($cfg->{$key}{$sys->{sys}});
        }
    } else {
        for my $sys (@{CPIC::get('systems')}) {
            $cfg->{$key}{$sys->{sys}} = $$rnic{$sys->{sys}};
        }
        undef($cfg->{$key}{all});
    }
    $prod->{"r$key"} = $rnic;
    return;
}

sub display_csgnwhosts {
    my ($prod,$rnwhosts)=@_;
    my ($syslist,$msg,$nmsg);

    return '' if (!$rnwhosts);
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        if ($rnwhosts->{$sys->{sys}}) {
            $msg=Msg::new("\tNetworkHosts ($sys->{sys}): $rnwhosts->{$sys->{sys}}\n");
            $nmsg.=$msg->{msg};
        }
    }
    return $nmsg;
}

# display csgnic information for confirmation
sub display_csgnic {
    my ($prod,$rcsgnic) = @_;
    my ($nmsg,$sys0,$msg);
    return '' if (!$rcsgnic);

    if ( EDRu::hashvaleq($rcsgnic) ) {
        $sys0 = ${CPIC::get('systems')}[0];
        $msg = Msg::new("\tNIC: $$rcsgnic{$sys0->{sys}}\n");
        $nmsg .= $msg->{msg};
    } else {
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("\tNIC ($sys->{sys}): $$rcsgnic{$sys->{sys}}\n");
            $nmsg .= $msg->{msg};
        }
    }
    return $nmsg;
}


# ask for severity for SMTP/SNMP notification
sub ask_severity {
    my ($prod,$rc,$snmp) = @_;
    my (@sevs,$sev,$msg,$help,$def,$backopt);

    $backopt = 1;
    @sevs = qw(Information Warning Error SevereError);
    $help = Msg::new("Information messages are events exhibiting normal behavior.  Warning messages draw attention to deviation from normal behavior.  Error messages draw attention to faults.  SevereError messages are critical errors that can lead to loss of data and/or corruption.");
    if ($snmp){
        $msg = Msg::new("Enter the minimum severity of events for which SNMP traps should be sent to $rc  [I=Information, W=Warning, E=Error, S=SevereError]:");
    }else{
        $msg = Msg::new("Enter the minimum severity of events for which mail should be sent to $rc  [I=Information, W=Warning, E=Error, S=SevereError]:");
    }
    while (!EDRu::inarr($sev,@sevs)) {
        $sev = $msg->ask($def,$help,$backopt);
        return $sev if (EDR::getmsgkey($sev,'back'));
        $sev = 'Information' if ($sev =~ /^I/mi);
        $sev = 'Warning' if ($sev =~ /^W/mi);
        $sev = 'Error' if ($sev =~ /^E/mi);
        $sev = 'SevereError' if ($sev =~ /^S/mi);
    }
    return $sev;
}

# ask for a smtp recipient
sub ask_smtprecp {
    my ($prod,$def) = @_;
    my ($email,$help,$msg,$answer,$backopt);
    $help = Msg::new("The SMTP recipient will receive notification of $prod->{abbr} events via email at the designated address");
    # vxgettext is sensitive with @
    $email="user\@yourcompany.com";
    $msg = Msg::new("Enter the full email address of the SMTP recipient\n(example: $email):");
    $backopt = 1;
    while (1) {
        $answer = $msg->ask($def,$help,$backopt);
        return $answer if ( EDR::getmsgkey($answer,'back') || $prod->verify_emailadd($answer));
    }
    return;
}

# verify an email address has proper format
sub verify_emailadd {
    my ($prod,$recp) = @_;
    my(@aa,@sa,$msg);

    @aa = split(/@/m,$recp);
    @sa = split(/\./m,$aa[1]);
    if ( ($#aa!=1) || ($#sa<1) ) {
        $msg = Msg::new("$recp is not a valid domain-based email address");
        $msg->print;
        return 0;
    }
    return 1;
}

# ask for one public nic
# $ntfrgco="" means first time in for cluster service group
# $ntfrgco=1 means potential second time in for notifier
# $ntfrgco=2 means potential second time in for global cluster option
sub ask_publicnic {
    my ($prod, $ntfrgco) = @_;
    my ($def,$help,$msg,%csgnic,$all,$aayn,$ayn,$en,$nic,$nicl,$rpn,$sys,$backopt,$padv);
    return '' if (($prod->{rcsgnic}) && ($ntfrgco == 1));

    $backopt = 1;
    for my $sys (@{CPIC::get('systems')}) {
        if ($all) {
            $csgnic{$sys->{sys}} = $nic;
            next;
        }
        $padv=$sys->padv;
        $rpn = $padv->publicnics_sys($sys);
        $rpn=EDRu::arruniq(@$rpn);
        if ($#$rpn<0) {
            $msg = Msg::new("No active NIC devices have been discovered on $sys->{sys}");
            $msg->warning();
        } else {
            $nicl = join(' ',@$rpn);
            $msg = Msg::new("Active NIC devices discovered on $sys->{sys}: $nicl");
            $msg->print();
        }
        Msg::n();

        $nic = '';
        while (!$nic) {
            #ask for the active NIC for VCS Notifier
            $def = $$rpn[0];
            $help = Msg::new("The NIC selected is typically the network card on which the system's public IP address is active.");
            if ($ntfrgco == 2) {
                $msg = Msg::new("Enter the NIC for Global Cluster Option to use on $sys->{sys}:");
            } elsif ($ntfrgco == 1){
                $msg = Msg::new("Enter the NIC for the $prod->{abbr} Notifier to use on $sys->{sys}:");
            } else {
                $msg = Msg::new("Enter the NIC for Virtual IP of the Cluster to use on $sys->{sys}:");
            }
            $en = $msg->ask($def,$help,$backopt);
            return $en if (EDR::getmsgkey($en,'back'));
            $en = EDRu::despace($en);

            if ($en eq '') {
            } elsif ($en =~/\s+/m) {
                $msg = Msg::new("Only one NIC name is needed at one time");
                $msg->print;
            } elsif (!$sys->is_nic($en)) {
                $msg = Msg::new("$en is not a valid NIC name");
                $msg->print;
            } elsif ((EDRu::inarr($sys,@{CPIC::get('systems')})) &&
                (!EDRu::inarr($en,@$rpn))) {
                $msg = Msg::new("$en does not appear to be an active NIC");
                $msg->print;
                $help = Msg::new("The NIC selected is typically the network card on which the systems public IP address is active. This NIC may or may not be the same on each system within a cluster.");
                $msg = Msg::new("Are you sure you want to use NIC $en ?");
                $ayn = $msg->aynn($help,$backopt);
                return $ayn if (EDR::getmsgkey($ayn,'back'));
                $nic = $en if ($ayn eq 'Y');
            } else {
                $nic=$en;
            }
        }
        $csgnic{$sys->{sys}} = $nic;

        #ask the nic for all systems.
        if ($sys eq ${CPIC::get('systems')}[0]) {
            $help = Msg::new("The NIC selected is typically the network card on which the systems public IP address is active. This NIC device may or may not be the same on each system within a cluster.");
            $msg = Msg::new("Is $nic to be the public NIC used by all systems?");
            $aayn = $msg->ayny($help,$backopt);
            return $aayn if (EDR::getmsgkey($aayn,'back'));
        }
        $all=1 if ($aayn eq 'Y');
    }
    return \%csgnic;
}

# ask for an SMTP mail server
sub ask_smtpserver {
    my ($prod,$def) = @_;
    my ($ask,$help,$msg,$backopt);
    $help = Msg::new("The SMTP server is a mail server on your network");
    $msg = Msg::new("Enter the domain-based hostname of the SMTP server\n(example: smtp.yourcompany.com):");
    $backopt = 1;
    while(1) {
        $ask = $msg->ask($def,$help,$backopt);
        return $ask if (EDR::getmsgkey($ask,'back') || $prod->verify_smtpserver($ask) );
    }
    return;
}


# verify an smtp server is a complete domain address and can be pinged
sub verify_smtpserver {
    my ($prod,$server) = @_;
    my(@f,$msg,$edr);

    $edr = Obj::edr();
    @f = split(/\./m,$server);
    my $localsys=EDR::get('localsys');
    if ( $#f<2 ) {
        $msg = Msg::new("$server does not include a domain");
        $msg->print;
    } elsif ($localsys->padv->ping($server)) {
        $msg = Msg::new("Cannot ping $server");
        $msg->print;
    } else {
        return 1;
    }
    return 0;
}

sub set_vcsencrypt {
    my ($prod) = @_;
    my $rootpath = Cfg::opt('rootpath');
    #check for vcsencrypt binary
    if (EDR::get('fromdisk')){
        $prod->{vcsencrypt} = "$rootpath$prod->{bindir}/vcsencrypt";
    }else{
    #TODO: we need to change the vcsencrypt file according to local padv when a2a build is ready.
        my $mediapath=EDR::get('mediapath');
        $prod->{vcsencrypt} = "$mediapath/scripts/vcsencrypt";
    }
    return 1 if (-x "$prod->{vcsencrypt}");

    Msg::log('Cannot find vcsencrypt binary - skipping add_users');
    return 0;
}

sub add_users {
    my ($prod) = @_;
    my ($cfg,$padv,$msg,$backopt,@epws,@pris,@users,$ayn,$ayn_more,$done,$epw,$pri,$user,$n);

    return '' if (Cfg::opt('responsefile'));
    $cfg = Obj::cfg();
    $padv = $prod->padv;
    return 1 if ($cfg->{vcs_eat_security} || $cfg->{opt}{installonly});

    return 0 unless ($prod->set_vcsencrypt);

    #ask for users info.(name/passwd/privilege)
    while (!$done) {
        Msg::title();
        undef(@users);
        undef(@epws);
        undef(@pris);
        $backopt = '';

        $msg = Msg::new("The following information is required to add $prod->{abbr} users:\n");
        $msg->bold;
        $msg = Msg::new("\tA user name");
        $msg->print;
        $msg = Msg::new("\tA password for the user");
        $msg->print;
        $msg = Msg::new("\tUser privileges (Administrator, Operator, or Guest)\n");
        $msg->print;

        $msg = Msg::new("Do you wish to accept the default cluster credentials of 'admin/password'?");
        $ayn = $msg->ayny;
        Msg::n();
        if ($ayn eq 'N') {
            $prod->{setadminpwd} = 1;
            $backopt = 1;
            $user = $prod->ask_username('admin');
            next if (EDR::getmsgkey($user,'back'));
            $backopt = '';
            $epw=$prod->encrypt_password;
            Msg::n();
        } else {
            $user = 'admin';
            $epw = $prod->encrypt_password('password');
        }
        push(@users,$user);
        push(@epws,$epw);
        push(@pris,'Administrators');

        $msg = Msg::new("Do you want to add another user to the cluster?");
        $ayn = $msg->aynn;
        while (($#users<0) || ($ayn eq 'Y')) {
            $backopt = 1;
            $user = $prod->ask_username;
            last if (EDR::getmsgkey($user,'back'));

            # check if the user has been entered beforehand so as to provide more info previously
            if( EDRu::inarr($user, @users) ) {
                $ayn_more= 'N';
                if( $user eq 'admin') {
                    $msg = Msg::new("$user was previously entered. Do you want to update its password?");
                    $ayn_more= $msg->aynn;
                } else {
                    $msg = Msg::new("$user was previously entered. Do you want to update its password and privilege?");
                    $ayn_more= $msg->aynn;
                }
                next if( $ayn_more eq 'N');
            }

            $epw = $prod->encrypt_password;
            $backopt = 1;
            $pri = $prod->ask_userprivilege($user);
            $n = EDRu::arrpos($user,@users);
            if ($n>=0) {
                $epws[$n]=$epw;
                $pris[$n]=$pri unless ($user eq 'admin');
            } else {
                push(@users,$user);
                push(@epws,$epw);
                push(@pris,$pri);
            }
            $msg = Msg::new("Would you like to add another user?");
            $ayn = $msg->aynn();
            Msg::n();
        }
        next if (EDR::getmsgkey($user,'back'));
        $backopt = '';
        Msg::title();
        $msg = Msg::new("$prod->{abbr} User verification:\n");
        $msg->bold();

        # find the max length of all names
        my $lenmax= 0;
        for my $name (@users) {
            $lenmax = (length($name) > $lenmax) ? length($name) : $lenmax;
        }

        # display names line by line with more spaces for the shorter names
        for my $n (0..$#users) {
            my $lenname = length($users[$n]);
            $msg = Msg::new("\tUser: $users[$n]");
            my $line = $msg->{msg};
            for my $ispaces ($lenname..$lenmax+4) {
                $line .= ' ';
            }
            $msg = Msg::new("Privilege: $pris[$n]");
            $line .= $msg->{msg};
            Msg::print($line);
        }
        Msg::n();
        $msg = Msg::new("\tPasswords are not displayed");
        $msg->printn;
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny();
        $done = 1 if ($ayn eq 'Y');
    }

    $cfg->{vcs_username} = [];
    $cfg->{vcs_userpriv} = [];
    @{$cfg->{vcs_userenpw}} = @epws;
    for my $n (0..$#users) {
        push(@{$cfg->{vcs_username}},$users[$n]);
        push(@{$cfg->{vcs_userpriv}},$pris[$n]);
    }
    return;
}

# ask for user name
sub ask_username {
    my($prod,$defanswer) = @_;
    my ($help, $msg, $answer,$backopt);

    $help = Msg::new("Username can have the following characters: alphabets[a-z][A-Z], numbers[0-9], underscore[_], or minus[-].");
    $msg = Msg::new("Enter the user name:");
    $backopt = 1;
    while (1) {
        $answer = $msg->ask($defanswer, $help, $backopt);
        return $answer if ( EDR::getmsgkey($answer,'back') || $prod->verify_username( $answer));
    }
    return;
}

sub verify_username {
    my ($prod,$name) = @_;
    my ($msg);

    $name =~ s/[A-Za-z0-9_-]//mxg;
    if ($name) {
        $msg = Msg::new("User name cannot use the characters: $name");
        $msg->print;
        return 0;
    }else{
        return 1;
    }
}

sub encrypt_password {
    my ($prod,$passwd) = @_;
    my ($epw,$sys,$edr);
    $edr = Obj::edr();
    $sys = ${CPIC::get('systems')}[0];
    # get password until effective
    $passwd = $prod->ask_userpassword if(!$passwd);

    #Install from localsys or from hardisk
    if ($sys->{islocal} || $edr->{fromdisk}){
        #Here we use system call which will not log the password in clear text.
        system("$prod->{vcsencrypt} -vcs '$passwd' 1> $edr->{tmpdir}/userpasswd");
        $epw = EDRu::despace(EDR::cmd_local("_cmd_cat $edr->{tmpdir}/userpasswd"));
    }else{
        $prod->localsys->copy_to_sys($sys,$prod->{vcsencrypt},"$edr->{tmpdir}/vcsencrypt");
        # Do not log the password
        $edr->{donotlog} = 1;
        $epw = EDRu::despace($sys->cmd("$edr->{tmpdir}/vcsencrypt -vcs '$passwd'"));
        $edr->{donotlog} = 0;
    }
    return $epw;
}

# ask for user password
sub ask_userpassword {
    my ($prod) = @_;
    my ($passwd,$passwd2,$msg,$bs,$be);

    $bs=EDR::get2('tput','bs');
    $be=EDR::get2('tput','be');
    while (1) {
        $msg = Msg::new("Enter the password: ");
        print "$bs$msg->{msg}$be";
        EDR::cmd_local('stty -echo');
        $passwd = <STDIN>;
        print("\n");
        $passwd = EDRu::despace($passwd);
        if( $passwd eq '') {
            $msg = Msg::new("Empty passwords are not allowed.");
            $msg->print;
            next;
        } elsif ($passwd=~/\P{IsASCII}/mx) {
            $msg = Msg::new("Only ASCII characters are allowed.");
            $msg->print;
            next;
        }
        EDR::cmd_local('stty echo');
        $msg = Msg::new("Enter again:");
        print "$bs$msg->{msg}$be";
        EDR::cmd_local('stty -echo');
        $passwd2 = <STDIN>;
        EDR::cmd_local('stty echo');
        print("\n");
        $passwd2 = EDRu::despace($passwd2);
        return $passwd if ($passwd eq $passwd2);

        $msg = Msg::new("Passwords do not match");
        $msg->warning();
    }
    return;
}


sub ask_userprivilege {
    my ($prod,$user)= @_;
    my (@pris,$pri,$msg,$help,$def,$backopt);

    @pris = qw(Administrators Operators Guests);
    $def = '';
    $backopt = 1;
    $help = Msg::new("Administrator users have full privileges to make changes to the cluster.\nOperator users have limited administrative privileges on the cluster.\nGuest users have read-only access to the cluster.");
    $msg = Msg::new("Enter the privilege for user $user (A=Administrator, O=Operator, G=Guest):");
    while (!EDRu::inarr($pri,@pris)) {
         $pri = $msg->ask($def,$help,$backopt);
         return $pri if (EDR::getmsgkey($pri,'back'));
         $pri = 'Administrators' if ($pri =~ /^A$/mi || $pri =~/^[Aa]dministrator$/mx);
         $pri = 'Operators' if ($pri =~ /^O$/mi || $pri =~/^[Oo]perator$/mx);
         $pri = 'Guests' if ($pri =~ /^G$/mi || $pri =~/^[Gg]uest$/m);
    }
    return $pri;
}

sub check_config {
    my $prod = shift;
    my ($cfg,$cprod,$clusterid,$clustername,$confi,$syslist,$llt_gab_configured,$mode,$rootpath,$sys0,$sysi);

    $syslist=CPIC::get('systems');
    $cprod=CPIC::get('prod');
    $cfg = Obj::cfg();
    
    $rootpath = Cfg::opt('rootpath') || '';
    for my $sysi (@$syslist) {
        $confi = $prod->get_config_sys($sysi);
        if ($confi) {
            return 0 if ((defined $clustername) && ($clustername ne $confi->{clustername}));
            $clustername = $confi->{clustername};
            return 0 if ((defined $clusterid) && ($clusterid ne $confi->{clusterid}));
            $clusterid = $confi->{clusterid};
        } else {
            return 0;
        }
    }
    # for single node cluster, check if llt/gab is configured before.
    if (scalar(@$syslist) == 1) {
        $sys0 = $$syslist[0];
        if ($sys0->exists("$rootpath$prod->{llthosts}")
                && $sys0->exists("$rootpath$prod->{llttab}")
                && $sys0->exists("$rootpath$prod->{gabtab}")) {
            $llt_gab_configured = 1;
        }
        if (($cprod=~/^(SVS|SFCFS|SFRAC|SFSYBASECE)/mx) || ($cfg->{vcs_allowcomms})) {
            return 0 unless $llt_gab_configured;
        }
        if (defined $cfg->{vcs_allowcomms} && ($cfg->{vcs_allowcomms} == 0)) {
            if ($sys0->exists("$rootpath$prod->{llthosts}")
                || $sys0->exists("$rootpath$prod->{llttab}")
                || $sys0->exists("$rootpath$prod->{gabtab}")) {
                return 0;
            }
        }
    }

    # check the EAT configurations
    $sys0 = $$syslist[0];
    return 0 if ($prod->is_secure_cluster($sys0)
                && 2 != EDRu::compvers($sys0->{prodvers}[0],'6.0')
                && !$prod->eat_check_secure_clus());

    return 1;
}

sub get_config_sys {
    my ($prod,$sys) = @_;
    my ($lltconf,$nlow,@values,$num,$n,$key,$system,$str,%conf,$line,@lines,$maincf,$llttab);
    my $rootpath = Cfg::opt('rootpath') || '';

    $maincf = "$rootpath$prod->{maincf}";
    if (!$sys->exists($maincf)) {
        Msg::log("$maincf not exists on $sys->{sys}");
        return 0;
    }
    return $sys->{vcs_conf} if (defined($sys->{vcs_conf}));

    $str = $sys->cmd("_cmd_grep '^cluster' $maincf 2> /dev/null");
    # get cluster name
    if ($str =~ /^cluster\s+(\S+)\s*/mx) {
        $conf{clustername} = $1;
    } else {
        Msg::log("No cluster defined in $maincf on $sys->{sys}");
        return 0;
    }

    # get secure cluster flag
    $str=$sys->cmd("_cmd_grep 'SecureClus' $maincf 2> /dev/null");
    if ($str=~/SecureClus\s*=\s*(\d)/mx) {
        $conf{secureclus} = $1;
    } else {
        $conf{secureclus} = 0;
    }

    # get cluster systems
    $conf{systems} = [];
    $num = 0;
    $str = $sys->cmd("_cmd_grep '^system' $maincf 2> /dev/null");
    for my $system (split(/\n/,$str)) {
        next unless ($system =~ /^system\s+(\S+)\s*/mx);
        $system = $1;
        $system =~ s/"(.*)"/$1/m; # remove double quote
        push(@{$conf{systems}},$system);
        $num ++;
    }
    if ($num == 0) { # no system defined
        Msg::log("No system defined in $maincf on $sys->{sys}");
        return 0;
    }

    # get service groups
    $conf{groups} = [];
    $str=$sys->cmd("_cmd_grep '^group' $prod->{maincf} | _cmd_awk '{print \$2}'");
    @{$conf{groups}} = split(/\s+/,$str) if $str;

    if ($num > 1) {
        # multi-node cluster, llt and gab should also be configured
        if (!$sys->exists("$rootpath$prod->{llthosts}")) {
            Msg::log("$rootpath$prod->{llthosts} not exists on $sys->{sys}");
            return 0;
        }
        if(!$sys->exists("$rootpath$prod->{llttab}")) {
            Msg::log("$rootpath$prod->{llttab} not exists on $sys->{sys}");
            return 0;
        }
        if(!$sys->exists("$rootpath$prod->{gabtab}")) {
            Msg::log("$rootpath$prod->{gabtab} not exists on $sys->{sys}");
            return 0;
        }

        # compare systems defined in llthosts and main.cf
        # if same, use the sorted system names in llthosts file.
        $lltconf = $prod->get_llt_config_sys($sys);
        if ($num != @{$lltconf->{systemlist}}) {
            Msg::log("The number of systems defined in $maincf is different from $rootpath$prod->{llthosts} on $sys->{sys}");
            return 0;
        }
        my $tmp_aref = EDRu::arruniq(@{$conf{systems}}, @{$lltconf->{systemlist}});
        if ($num != @{$tmp_aref}) {
            Msg::log("Systems defined in $maincf are different from $rootpath$prod->{llthosts} on $sys->{sys}");
            return 0;
        }
        $conf{systems} = $lltconf->{systemlist};
    }

    if ($sys->exists("$rootpath$prod->{llttab}")) {
        $llttab = $sys->cmd("_cmd_cat $rootpath$prod->{llttab} 2>/dev/null");
        # get cluster id
        if ($llttab =~ /^\s*set-cluster\s+(\d+)\s*/mx) {
            $conf{clusterid} = $1;
        } else {
            Msg::log("No cluster ID defined in $rootpath$prod->{llttab} on $sys->{sys}");
            return 0;
        }
        # get heartbeat nics line by line in $llttab
        $n = 0;
        $nlow = 0;
        @lines = split(/\n/, $llttab);
        for my $line (@lines) {
            if ($line =~ /^\s*link\s+.*/mx) {
                $n++;
                @values = split(/\s+/m,$line);
                if ( $values[4] =~ /udp6?/m ) {
                    $key = "lltlink$n";
                    $conf{$key}{$sys->{sys}} = $prod->convert_linkip2nic_sys($sys, $values[7]);
                    $conf{lltoverudp} = 1;
                    $key = "udplink$n".'_address';
                    $conf{$key}{$sys->{sys}} = $values[7];
                    $key = "udplink$n".'_port';
                    $conf{$key}{$sys->{sys}} = $values[5];
                } elsif ( $values[4] =~ /rdma/m ) {
                    $key = "lltlink$n";
                    $conf{$key}{$sys->{sys}} = $prod->convert_linkip2nic_sys($sys, $values[7]);
                    $conf{lltoverrdma} = 1;
                    $key = "rdmalink$n".'_address';
                    $conf{$key}{$sys->{sys}} = $values[7];
                    $key = "rdmalink$n".'_port';
                    $conf{$key}{$sys->{sys}} = $values[5];
                } else {
                    $key = "lltlink$n";
                    $conf{$key}{$sys->{sys}} = $prod->convert_linkdev2nic_sys($sys, $values[2]);
                }

            } elsif ($line =~ /^\s*link-lowpri\s+.*/mx) {
                $nlow++;
                @values = split(/\s+/m,$line);
                if ( $values[4] =~ /udp6?/m ) {
                    $key = "lltlinklowpri$nlow";
                    $conf{$key}{$sys->{sys}} = $prod->convert_linkip2nic_sys($sys, $values[7]);
                    $conf{lltoverudp} = 1;
                    $key = "udplinklowpri$nlow".'_address';
                    $conf{$key}{$sys->{sys}} = $values[7];
                    $key = "udplinklowpri$nlow".'_port';
                    $conf{$key}{$sys->{sys}} = $values[5];
                } elsif ( $values[4] =~ /rdma/m ) {
                    $key = "lltlinklowpri$nlow";
                    $conf{lltoverrdma} = 1;
                    $conf{$key}{$sys->{sys}} = $prod->convert_linkip2nic_sys($sys, $values[7]);
                    $key = "rdmalinklowpri$nlow".'_address';
                    $conf{$key}{$sys->{sys}} = $values[7];
                    $key = "rdmalinklowpri$nlow".'_port';
                    $conf{$key}{$sys->{sys}} = $values[5];
                } else {
                    $key = "lltlinklowpri$nlow";
                    $conf{$key}{$sys->{sys}} = $prod->convert_linkdev2nic_sys($sys, $values[2]);
                }
            }
        }
    } else {
        $conf{onenode} = 1 if ($num == 1);
    }

    # In RDMA, low-pri link could be udp type
    # So need to modify the scan result
    if ($conf{lltoverrdma}) {
        my $sysi = $sys->{sys};
        delete $conf{lltoverudp};
        for my $n (1..$prod->num_lopri_hbnics(\%conf)) {
            my $addrkey = "rdmalinklowpri${n}_address";
            my $maskkey = "rdmalinklowpri${n}_netmask";
            my $portkey = "rdmalinklowpri${n}_port";
            my $rdmaudp = "rdmalinklowpri${n}_udp";

            my $addrudp = "udplinklowpri${n}_address";
            my $maskudp = "udplinklowpri${n}_netmask";
            my $portudp = "udplinklowpri${n}_port";
            if (defined $conf{$addrudp}) {
                $conf{$addrkey}{$sysi} = $conf{$addrudp}{$sysi};
                $conf{$portkey}{$sysi} = $conf{$portudp}{$sysi};
                $conf{$rdmaudp}{$sysi} = 1;
            }
        }
    }

    #find online systems and service groupsa
    my ($pids,$online_systems,$offline_systems,$output,$online_sg_sys,$offline_sg_sys,$state);
    $pids=$sys->proc_pids('bin/had');
    if (@$pids) {
        $output=$sys->cmd("_cmd_hasys -display -attribute SysState 2>/dev/null | _cmd_grep -v '#'");
        foreach my $line(split(/\n/,$output)){
            ($system,undef,$state)=split(/\s+/,$line);
            if ($state=~/RUNNING/){
                $online_systems.=" $system";
            } else {
                $offline_systems.=" $system";
            }
        }
        $offline_systems=EDRu::despace($offline_systems);
        $online_systems=EDRu::despace($online_systems);
        if(!$offline_systems){
            foreach my $node (split(/\s+/,$online_systems)){
                $online_sg_sys=$offline_sg_sys='';
                foreach my $sg (@{$conf{groups}}){
                    $state=$sys->cmd("_cmd_hagrp -state $sg -sys $node 2>/dev/null");
                    if($state && $state=~/ONLINE/){
                        $online_sg_sys.=" $sg";
                    }else{
                        $offline_sg_sys.=" $sg";
                    }
                }
                $conf{online_servicegroups}{$node}=$online_sg_sys;
                $conf{offline_servicegroups}{$node}=$offline_sg_sys;
            }

        }
    } else {
        $offline_systems.=" $sys->{sys}";
    }

    $sys->{vcs_conf} = \%conf;
    $sys->set_value('cluster_systems','list',@{$conf{systems}});

    return \%conf;
}

sub get_llt_config_sys {
    my ($prod,$sys) = @_;
    my (%lltconf,$hostname,$llthosts,$llthosts_file);
    my $rootpath = Cfg::opt('rootpath') || '';
    $lltconf{systemlist} = [];
    $llthosts_file = "$rootpath$prod->{llthosts}";
    if ($sys->exists($llthosts_file)) {
        $llthosts = $sys->catfile($llthosts_file);
        for my $line(split(/\n/,$llthosts)) {
            if ($line =~ /^\s*(\d+)\s+(\S+)/) {
                $hostname = $2;
                $lltconf{hosts}{"$1"} = $hostname;
                $lltconf{hostsid}{$hostname} = $1;
            }
        }
        for my $nodeid(sort{$a <=> $b}(keys(%{$lltconf{hosts}}))) {
            push(@{$lltconf{systemlist}}, $lltconf{hosts}{$nodeid});
        }
    }
    return \%lltconf;
}

sub prestart_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$cprod);
    my ($cpspkg,$vxfen,$rootpath,$vxfenmodedisablefile,$vxfenmodefile,$vxfendgfile,$str);
    my $cpic=Obj::cpic();
    $cfg = Obj::cfg();
    $cprod=CPIC::get('prod');
    $vxfen=$sys->proc('vxfen61');

    $rootpath=Cfg::opt('rootpath')||'';
    $vxfenmodedisablefile="$rootpath/etc/vxfen.d/vxfenmode_disabled";
    $vxfenmodefile="$rootpath$prod->{vxfenmode}";
    $vxfendgfile="$rootpath$prod->{vxfendg}";
    $cpspkg = $sys->pkg('VRTScps61');

    if (!$cfg->{donotreconfigurevcs}) {
        # clean up old registration info from cps
        $cpspkg->remove_from_cps_sys($sys);
        # for SVS/SFCFS/SFCFSHA/SFRAC, start vxfen in disabled mode initially.
        if ($cprod =~ /^(SVS|SFCFS|SFRAC|SFSYBASECE)/mx) {
            $sys->cmd("_cmd_cp $vxfenmodedisablefile $vxfenmodefile");
        } else {
            # for VCS/SFHA, do not start vxfen initially
            $sys->set_value('donotstartprocs','push','vxfen61');
            $str = EDRu::datetime();
            $sys->cmd("_cmd_mv $vxfenmodefile $vxfenmodefile-$str") if ($sys->exists("$vxfenmodefile"));
            $sys->cmd("_cmd_mv $vxfendgfile $vxfendgfile-$str") if ($sys->exists("$vxfendgfile"));
            $vxfen->disable_sys($sys);
            if ($vxfen->can('disable_service_sys')) {
                $vxfen->disable_service_sys($sys);
            }
        }
    } else {
        if ($cprod =~ /^(SVS|SFCFS|SFRAC|SFSYBASECE)/mx) {
            if ((!$sys->exists($vxfenmodefile)) && (!$sys->exists($vxfendgfile))) {
                $sys->cmd("_cmd_cp $vxfenmodedisablefile $vxfenmodefile");
                $prod->vxfen_enable_sys($sys);
            }
        }
    }
    return 1;
}

sub configure_sys {
    my ($prod,$sys) = @_;
    my ($sysi,$sysname,$msg,$cprod,$cfg,$rtn,$hostname,$tmpdir,$cpic);
    my ($localsys,$rootpath);
    $cpic=Obj::cpic();
    $cfg = Obj::cfg();
    $cprod=CPIC::get('prod');

    $rootpath=Cfg::opt('rootpath')||'';

    #return if ($cfg->{donotreconfigurevcs});
    if ($cfg->{donotreconfigurevcs}) {
        $prod->include_extra_types_sys($sys);
        return;
    }

    # Only perform following tasks on first node of the cluster
    if ($sys->system1) {
        # destroy the EAT env to force reconfigure
        $sys->cmd("_cmd_rmr $prod->{eat_data_backup}");

        # uuid configuration
        $rtn = $prod->config_uuid();
        if ($rtn == -1) {
            $msg = Msg::new("Cannot find uuidconfig.pl for uuid configuration. Create uuid manually before starting VCS");
            $sys->push_warning($msg);
        }

        #for secure cluster configuration
        #uuid is needed, so this step is after create uuid
        if ($cfg->{vcs_eat_security}) {
            $prod->{fips} = 1 if ($cfg->{vcs_eat_security_fips});
            $rtn=$prod->eat_configure();
            if(!$rtn) {
                EDRu::create_flag("main_cf_done");
                return;
            }
        }

        # generate configuration files
        Msg::log("Creating $prod->{name} configuration files");
        if ($cfg->{vcs_allowcomms}) {
            $prod->update_llttab();
            $prod->update_llthosts();
            $prod->update_gabtab();
        }
        $prod->update_maincf($sys);
        EDRu::create_flag('main_cf_done');
    } else {
        EDRu::wait_for_flag('main_cf_done');
    }

    $tmpdir=EDR::tmpdir();
    return unless (-f "$tmpdir/main.cf");
    $sysi=$sys->{sys};
    $localsys=$prod->localsys;
    $hostname =transform_system_name($sysi);
    EDRu::writefile("$hostname\n","$tmpdir/sysname.$sysi");
    $localsys->copy_to_sys($sys,"$tmpdir/sysname.$sysi","$rootpath$prod->{confdir}/sysname");
    $localsys->copy_to_sys($sys,"$tmpdir/main.cf",$rootpath.$prod->{maincf});
    Msg::log("Copying configuration files to $sysi");
    if ($cfg->{vcs_allowcomms}) {
        $localsys->copy_to_sys($sys,"$tmpdir/llttab.$sysi",$rootpath.$prod->{llttab});
        $localsys->copy_to_sys($sys,"$tmpdir/llthosts",$rootpath.$prod->{llthosts});
        $localsys->copy_to_sys($sys,"$tmpdir/gabtab",$rootpath.$prod->{gabtab});
        $prod->set_onenode_cluster_sys($sys,0);
    } else {
        # All: set ONENODE=yes in vcs init file
        # SunOS: import manifest vcs-onenode.xml
        $prod->set_onenode_cluster_sys($sys,1);
        # remove old config files if exist
        if ($sys->exists($rootpath.$prod->{llttab})) {
           $sys->cmd("_cmd_mv $rootpath$prod->{llttab} $rootpath$prod->{llttab}.old");
        }
        if ($sys->exists($rootpath.$prod->{llthosts})) {
           $sys->cmd("_cmd_mv $rootpath$prod->{llthosts} $rootpath$prod->{llthosts}.old");
        }
        if ($sys->exists($rootpath.$prod->{gabtab})) {
           $sys->cmd("_cmd_mv $rootpath$prod->{gabtab} $rootpath$prod->{gabtab}.old");
        }
    }

    $sys->cmd("_cmd_cp $rootpath$prod->{confdir}/types.cf $rootpath$prod->{configdir}");
    $sys->cmd("_cmd_rmr $rootpath$prod->{configdir}/.stale");
    # on AIX, update /etc/pse.conf file
    $prod->update_pseconf_sys($sys) if $prod->can('update_pseconf_sys');

    # link install: configuration finished, enable it
    $prod->vcs_enable_sys($sys);
    if ($cpic->{reboot} && $prod->can('enable_vcs_services_after_reboot_sys')) {
        $prod->enable_vcs_services_after_reboot_sys($sys);
    }

    #create .secure file for CmdServer
    if ($cfg->{vcs_eat_security}) {
        $sys->cmd("_cmd_touch $rootpath$prod->{secure}");
    } else {
        $sys->cmd("_cmd_rmr $rootpath$prod->{secure}");
    }

    # reset vcs_sysname
    $sysname = $prod->get_vcs_sysname_sys($sys);
    $sys->set_value('vcs_sysname', $sysname);
    return;
}

# configure cluster information:
# Cluster name, ID, and heartbeat links
sub config_cluster {
    my($cprod,$ayn,$backopt,$cfg,$diff,$done,$help,$prod,$sysi,$sys,$script);
    my ($address,$cid,$cname,$key,$lmsg,$multinode,$msg,$n,$netmask,$rhbn,$output,$port,$cprodabbr,$summary);

    $prod = shift;
    $cfg = Obj::cfg();

    $cprodabbr=$cprod=CPIC::get('prod');
    $cprodabbr=~s/\d+$//m;
    $backopt = 1;
    # by default, set vcs_allowcomms to 1 if it isn't defined
    # this happens if other products (eg. sfcfs sfrac) calls vcs configure_sys to setup clusters
    # but foget to set this attribute to 1 in order to let cpi generate llt/gab config files
    $cfg->{vcs_allowcomms} = 1 unless (defined($cfg->{vcs_allowcomms}));
    $multinode = 1 if ($cfg->{vcs_allowcomms});
    while (!$done) {
        Msg::title();
        if ($multinode) {
            if ($cprod =~ /VCS\d+/m) {
                $msg = Msg::new("To configure VCS the following information is required:\n");
            } else {
                $msg = Msg::new("To configure VCS for $cprodabbr the following information is required:\n");
            }
            $msg->bold;
            $msg = Msg::new("\tA unique cluster name");
            $msg->print;
            if ($cfg->{fencingenabled}) {
                $msg = Msg::new("\tOne or more NICs per system used for heartbeat links");
            } else {
                $msg = Msg::new("\tTwo or more NICs per system used for heartbeat links");
            }
            $msg->print;
            $msg = Msg::new("\tA unique cluster ID number between 0-65535\n");
            $msg->print;
            if ($cprod !~ /SFRAC\d+/m) {
                $msg = Msg::new("\tOne or more heartbeat links are configured as private links");
                $msg->print;
                $msg = Msg::new("\tYou can configure one heartbeat link as a low-priority link\n");
                $msg->print;
            }
            $msg = Msg::new("All systems are being configured to create one cluster.\n");
            $msg->print;
        } else {
            $msg = Msg::new("To configure a single-node VCS cluster, a unique cluster name is required:\n");
            $msg->bold;
        }

        $cname=$prod->ask_clustername($cname);
        $cname||=$cfg->{vcs_clustername}; # for installer resilience
        if ($multinode) {
            #$cid=$prod->ask_clusterid($cid);
            #$cid||=$cfg->{vcs_clusterid}; # for installer resilience
            #next if (EDR::getmsgkey($cid,'back'));
            $rhbn=$prod->hb_config_option();
            last if (Cfg::opt('responsefile'));
            next if (EDR::getmsgkey($rhbn,'back'));
            if (!$cfg->{autocfgllt}) {
                # check media speed for private nics on each system
                $diff = $prod->check_link_speed(CPIC::get('systems'),$rhbn);
                if ($diff == 1) {
                    Msg::n();
                    $msg = Msg::new("The private NICs do not have same media speed.\n");
                    $msg->warning();
                    $msg = Msg::new("It is recommended that the media speed be same for all the private NICs. Consult your Operating System manual for information on how to set the Media Speed.\n");
                    $msg->bold;
                }
                if ($diff == 2) {
                    Msg::n();
                    $script=EDR::get('script');
                    $msg = Msg::new("$script cannot detect media speed for the selected private NICs properly. Consult your Operating System manual for information on how to set the Media Speed.\n");
                    $msg->warning();
                }
                if ($diff) {
                    $msg = Msg::new("Do you want to continue with current heartbeat configuration?");
                    $ayn = $msg->ayny();
                    next if ($ayn ne 'Y');

                    if ($prod->num_hbnics($rhbn) > 1) {
                        for my $n (2..$prod->num_hbnics($rhbn)) {
                            $key="lltlink$n".'_low';
                            if ($rhbn->{$key} != $rhbn->{lltlink1_low}) {
                                $msg = Msg::new("Do you want to configure lower speed NICs as low-priority links?");
                                $help = Msg::new("The performance of LLT would be decreased if NICs with lower media speed were used as high priority private links. The overall performance of LLT will be the same as the high priority link with the lowest media speed.");
                                $ayn = $msg->ayny($help);
                                if ( $ayn eq 'Y' ) {
                                    $rhbn = $prod->set_lowpri_for_slow_links($rhbn);
                                }
                                last;
                            }
                        }
                    }
                }
            }
            $cid=$prod->config_clusterid($cid,$rhbn);
            next if (EDR::getmsgkey($cid,'back') && !undef($cid));
            $msg = $prod->display_config_info($cname,$cid,$rhbn);
        } else {
            $msg=Msg::new("\tCluster Name: $cname");
            $msg->print;
        }

        $summary = $msg;

        if ($cfg->{autocfgllt} && $prod->num_hbnics($rhbn) == 1 && $prod->num_lopri_hbnics($rhbn) == 0) {
            Msg::n();
            $msg = Msg::new("The following warning was discovered on the systems:");
            $msg->bold;
            Msg::n();
            $msg = Msg::new("Only one LLT private link is available");
            $msg->print();
        }

        Msg::n();
        $msg = Msg::new("Is this information correct?");
        $help =Msg::new("Verification of the input");
        $ayn = $msg->ayny($help);
        if ($ayn eq 'Y') {
            $done=1;
            $summary->add_summary(1);
        }
    }
    unless (Cfg::opt('responsefile')) {
        if ($multinode) {
            $cfg->{vcs_clusterid}=$cid;
            $prod->set_hb_nics($rhbn,CPIC::get('systems'));
        }
        $cfg->{vcs_clustername}=$cname;
    }
    delete($cfg->{autocfgllt});
    return;
}

sub display_config_info {
    my ($prod,$cname,$cid,$rhbn) = @_;
    my ($address,$cfg,$lmsg,$msg,$netmask,$key,$port,$smsg,$sys,$addrkey,$maskkey,$portkey);
    $cfg = Obj::cfg();

    $smsg = '';
    Msg::title();
    $msg = Msg::new("Cluster information verification:\n");
    $msg->bold;
    $msg=Msg::new("\tCluster Name: \t   $cname");
    $msg->print;
    $smsg .= "$msg->{msg}\n";
    $msg=Msg::new("\tCluster ID Number: $cid");
    $msg->print;
    $smsg .= "$msg->{msg}\n";
    for my $sysi (@{CPIC::get('systems')}) {
        $sys=$sysi->{sys};
        $lmsg='';
        for my $n (1..$prod->num_hbnics($rhbn)) {
            $key="lltlink$n";
            next unless ($rhbn->{$key}{$sys});
            if ($cfg->{lltoverudp}) {
                $address=$rhbn->{"udplink$n".'_address'}{$sys};
                $netmask=$rhbn->{"udplink$n".'_netmask'}{$sys};
                $port=$rhbn->{"udplink$n".'_port'}{$sys};
                if (EDRu::ip_is_ipv6($address)) {
                    $msg=Msg::new("\n\t\tlink$n=$rhbn->{$key}{$sys} over UDP6\n\t\t  ip $address prefix $netmask port $port");
                } else {
                    $msg=Msg::new("\n\t\tlink$n=$rhbn->{$key}{$sys} over UDP\n\t\t  ip $address netmask $netmask port $port");
                }
                $lmsg.=$msg->{msg};
            } else {
                $addrkey = "rdmalink${n}_address";
                $maskkey = "rdmalink${n}_netmask";
                $portkey = "rdmalink${n}_port";
                if (defined $rhbn->{$addrkey}) {
                    $address = $rhbn->{$addrkey}{$sys};
                    $netmask = $rhbn->{$maskkey}{$sys};
                    $port = $rhbn->{$portkey}{$sys};
                    $msg=Msg::new("\n\t\tlink$n=$rhbn->{$key}{$sys} over RDMA\n\t\t  ip $address netmask $netmask port $port");
                    $lmsg.=$msg->{msg};
                } else {
                    $msg=Msg::new("\n\t\tlink$n=$rhbn->{$key}{$sys}");
                    $lmsg.=$msg->{msg};
                }
            }
        }
        Msg::n();
        $msg=Msg::new("\tPrivate Heartbeat NICs for $sys: $lmsg");
        $msg->print;
        $smsg .= "$msg->{msg}\n";
        if ($prod->num_lopri_hbnics($rhbn) > 0) {
            $lmsg = '';
            for my $n (1..$prod->num_lopri_hbnics($rhbn)) {
                $key="lltlinklowpri$n";
                if ($cfg->{lltoverudp}) {
                    $address=$rhbn->{"udplinklowpri$n".'_address'}{$sys};
                    $netmask=$rhbn->{"udplinklowpri$n".'_netmask'}{$sys};
                    $port=$rhbn->{"udplinklowpri$n".'_port'}{$sys};
                    if (EDRu::ip_is_ipv6($address)) {
                        $msg=Msg::new("\n\t\tlink-lowpri$n=$rhbn->{$key}{$sys} over UDP6\n\t\t  ip $address prefix $netmask port $port");
                    } else {
                        $msg=Msg::new("\n\t\tlink-lowpri$n=$rhbn->{$key}{$sys} over UDP\n\t\t  ip $address netmask $netmask port $port");
                    }
                    $lmsg.=$msg->{msg};
                } else {
                    $addrkey = "rdmalinklowpri${n}_address";
                    $maskkey = "rdmalinklowpri${n}_netmask";
                    $portkey = "rdmalinklowpri${n}_port";
                    my $rdmaudp = "rdmalinklowpri${n}_udp";
                    if (defined $rhbn->{$addrkey}) {
                        $address = $rhbn->{$addrkey}{$sys};
                        $netmask = $rhbn->{$maskkey}{$sys};
                        $port = $rhbn->{$portkey}{$sys};
                        my $rdmastr = defined $rhbn->{$rdmaudp} ? "UDP" : "RDMA";
                        $msg=Msg::new("\n\t\tlink-lowpri$n=$rhbn->{$key}{$sys} over $rdmastr\n\t\t  ip $address netmask $netmask port $port");
                        $lmsg.=$msg->{msg};
                    } else {
                        $msg=Msg::new("\n\t\tlink-lowpri$n=$rhbn->{$key}{$sys}");
                        $lmsg.=$msg->{msg};
                    }
                }
            }
            if ($prod->num_lopri_hbnics($rhbn) > 1) {
                $msg=Msg::new("\tLow-Priority Heartbeat NICs for $sys: $lmsg");
            } else {
                $msg=Msg::new("\tLow-Priority Heartbeat NIC for $sys: $lmsg");
            }
            $msg->print;
            $smsg .= "$msg->{msg}";
        }
    }

    # return the summary message
    $msg = Msg::new("Cluster configuration information:\n");
    $msg->{msg} .= $smsg;
    return $msg;
}

sub set_hb_nics {
    my ($prod,$rhbn,$rsystems) = @_;
    my @systems = @$rsystems;
    my $cfg = Obj::cfg();

    # delete pre-existing LLT cfg info
    for my $lltlinkkey (keys %{$cfg}) {
        if ( $lltlinkkey =~ /vcs_lltlink\d+/mx || $lltlinkkey =~ /vcs_lltlinklowpri\d+/mx) {
            delete $cfg->{$lltlinkkey};
        }
    }

    for my $sys (@systems) {
        $prod->set_hb_nics_sys($sys,$rhbn);
    }
    return;
}

sub set_hb_nics_sys {
    my ($prod,$sysi,$rhbn) = @_;
    my $cfg = Obj::cfg();
    my ($n,$sys,$addrkey,$maskkey,$portkey);

    if (ref($sysi) eq 'Sys') {
        $sys = $sysi->{sys};
    } else {
        $sys = $sysi;
    }
    for my $n (1..$prod->num_hbnics($rhbn)) {
        $cfg->{"vcs_lltlink$n"}{$sys}=$rhbn->{"lltlink$n"}{$sys};
        if ($cfg->{lltoverudp}) {
            $cfg->{"vcs_udplink$n".'_address'}{$sys}=$rhbn->{"udplink$n".'_address'}{$sys};
            $cfg->{"vcs_udplink$n".'_netmask'}{$sys}=$rhbn->{"udplink$n".'_netmask'}{$sys};
            $cfg->{"vcs_udplink$n".'_port'}{$sys}=$rhbn->{"udplink$n".'_port'}{$sys};
        }

        $addrkey = "rdmalink${n}_address";
        $maskkey = "rdmalink${n}_netmask";
        $portkey = "rdmalink${n}_port";
        if (defined $rhbn->{$addrkey}) {
            $cfg->{"vcs_$addrkey"}{$sys} = $rhbn->{$addrkey}{$sys};
            $cfg->{"vcs_$maskkey"}{$sys} = $rhbn->{$maskkey}{$sys};
            $cfg->{"vcs_$portkey"}{$sys} = $rhbn->{$portkey}{$sys};
        }
    }
    for my $n (1..$prod->num_lopri_hbnics($rhbn)) {
        $cfg->{"vcs_lltlinklowpri$n"}{$sys}=$rhbn->{"lltlinklowpri$n"}{$sys};
        if ($cfg->{lltoverudp}) {
            $cfg->{"vcs_udplinklowpri$n".'_address'}{$sys}=$rhbn->{"udplinklowpri$n".'_address'}{$sys};
            $cfg->{"vcs_udplinklowpri$n".'_netmask'}{$sys}=$rhbn->{"udplinklowpri$n".'_netmask'}{$sys};
            $cfg->{"vcs_udplinklowpri$n".'_port'}{$sys}=$rhbn->{"udplinklowpri$n".'_port'}{$sys};
        }

        $addrkey = "rdmalinklowpri${n}_address";
        $maskkey = "rdmalinklowpri${n}_netmask";
        $portkey = "rdmalinklowpri${n}_port";
        my $rdmaudp = "rdmalinklowpri${n}_udp";
        if (defined $rhbn->{$addrkey}) {
            $cfg->{"vcs_$addrkey"}{$sys} = $rhbn->{$addrkey}{$sys};
            $cfg->{"vcs_$maskkey"}{$sys} = $rhbn->{$maskkey}{$sys};
            $cfg->{"vcs_$portkey"}{$sys} = $rhbn->{$portkey}{$sys};
            $cfg->{"vcs_$rdmaudp"}{$sys} = $rhbn->{$rdmaudp}{$sys};
        }
    }
    return;
}

sub check_uuidconfig_pl {
    my ($localsys,$prod,$result,$mediapath,$rootpath,$uuidconfig);
    $prod = shift;
    $localsys = $prod->localsys;
    $mediapath=EDR::get('mediapath');
    $rootpath = Cfg::opt('rootpath')||'';
    # check existance of uuidconfig.pl
    # Check the file existance for the first node unless opt makeresponsefile
    unless (Cfg::opt('makeresponsefile')) {
        my $sys1 = CPIC::get('systems')->[0];
        $uuidconfig = "$rootpath$prod->{uuidconfig}";
        return 0 unless $sys1->exists("$uuidconfig");
        return 1;
    }

    if(EDR::get('fromdisk')) {
        unless($localsys->exists($prod->{uuidconfig})) {
            return 0;
        }
    } elsif ($localsys->exists("$mediapath/scripts/uuidconfig.pl")) {
        $prod->{uuidconfig} = "$mediapath/scripts/uuidconfig.pl";
    } elsif ($localsys->exists("$mediapath/cluster_server/scripts/uuidconfig.pl")) {
        $prod->{uuidconfig} = "$mediapath/cluster_server/scripts/uuidconfig.pl";
    } else {
        return 0;
    }
    return 1;
}

#check if all systems have the same uuid
sub check_uuid {
    my ($prod,@uuid_keys,$uuid_hash);
    $prod = shift;
    $uuid_hash=$prod->get_uuid();
    @uuid_keys=keys(%{$uuid_hash});
    return 1 if ($#uuid_keys == 0) && ($uuid_keys[0]!~/NO_UUID/m);
    return 0;
}

sub config_uuid {
    my ($prod,$cfg,$systems,$uuid);
    $prod = shift;
    return 1 if ($prod->rel->{type} eq "H");
    $cfg = Obj::cfg();
    $uuid = $cfg->{uuid};
    if(Cfg::opt('responsefile') && $uuid){
        $uuid =~ s/^/{/ if($uuid !~ /^{/);
        $uuid =~ s/$/}/ if($uuid !~ /}$/);
        $systems = CPIC::get('systems');
        for my $sys (@$systems) {
            $prod->set_uuid_2sys($sys,$uuid);
        }
        return 1;
    }
    return -1 unless ($prod->check_uuidconfig_pl());
    return $prod->check_configure_uuid();
}

#First,to check existing UUID,and then configure UUID according to the case of existing UUID.
sub check_configure_uuid {
    my ($prod,$rtn,$sys,$uuid_hash,$uuid_source,$uuid,$syslist,$nouuid,$uuid_count,@tmp,$cfg);
    $prod = shift;
    $cfg=Obj::cfg();
    $uuid_hash=$prod->get_uuid();
    $nouuid=0;
    $uuid_count=0;
    while (($uuid,$syslist) = each %{$uuid_hash}) {
        if($uuid=~/NO_UUID/m){
            $nouuid=1;
         }else{
            $uuid_count=$uuid_count+1;
            $uuid_source=$syslist;
         }
    }
    # no uuid or more than 1 different uuids
    if($uuid_count!=1 || (Cfg::opt("configure") && !$cfg->{donotreconfigurevcs})){
        $rtn = $prod->create_uuid();
    }elsif($nouuid){
        chomp($uuid_source);
        $syslist=EDRu::despace($uuid_source);
        @tmp=split(/\s+/m,$syslist);
        $sys=$tmp[0] if($#tmp>=0);
        $rtn = $prod->copy_uuid($sys,$uuid_hash->{NO_UUID});
    }else{
        # All sys have same uuids.
        $rtn=1;
    }
    return $rtn;
}

sub create_uuid {
    my ($syslist,$prod,$rtn,$sys,$sys1);
    $prod = shift;
    $syslist=CPIC::get('systems');
    $sys1=$$syslist[0];
    $rtn = $prod->create_uuid_sys($sys1);
    unless($rtn){
        Msg::log('UUID could not be created successfully on the cluster');
        return 0;
    }
    for my $sys (@$syslist) {
        next if ($sys->system1);
        $prod->copy_uuid_2sys($sys1,$sys);
    }
    return 1;
}

sub get_uuid {
    my $prod = shift;
    my ($syslist,$uuids,%uuid_hash);
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $uuids=$prod->get_uuid_sys($sys);
        $uuids||='NO_UUID';
        if(exists($uuid_hash{$uuids})){
            $uuid_hash{$uuids}=$uuid_hash{$uuids}.' '.$sys->{sys};
        } else {
            $uuid_hash{$uuids}=$sys->{sys};
        }
    }
    return \%uuid_hash;
}

sub get_uuid_sys {
    my ($prod,$sys) = @_;
    my ($rootpath,$uuidfile,$uuid);
    $rootpath=Cfg::opt('rootpath') || '';
    $uuidfile="$rootpath$prod->{uuidfile}";
    $uuid=$sys->cmd("_cmd_cat $uuidfile") if ($sys->exists("$uuidfile"));
    return $uuid;
}

sub copy_uuid_2sys {
    my ($prod,$sys_src,$sys_dest) = @_;
    return 0 unless(($sys_src) && ($sys_dest));
    my $uuid=$prod->get_uuid_sys($sys_src);
    return $prod->set_uuid_2sys($sys_dest,$uuid);
}

sub set_uuid_2sys{
    my ($prod,$sys_dest,$uuid) = @_;
    my ($uuidpath,$rootpath,$edr,$uuidfile,$cmd);
    return 0 unless($sys_dest);
    $uuidfile=$prod->{uuidfile};
    $rootpath = Cfg::opt('rootpath') || '';
    $uuidfile=$rootpath.$uuidfile;
    $uuidpath=$uuidfile;
    $uuidpath=~s/\/clusuuid//mg;
    $sys_dest->cmd("_cmd_mkdir -p $uuidpath");
    $sys_dest->cmd("echo $uuid > $uuidfile");
    if(EDR::cmdexit()){
        Msg::log("FAILED to set UUID to $sys_dest->{sys}");
        return 0;
    }
    return 1;
}

sub create_uuid_sys {
    my ($prod,$sys) = @_;
    my ($rsh,$syslist,$hostname,$cmd);

    #3531260:Translate IP to hostname for /opt/VRTSvcs/bin/uuidconfig.pl needed.
    if ($sys->{islocal}) {
        $hostname = $sys->{hostname};
    } else {
        if (EDRu::ip_is_ipv4($sys->{sys}) || EDRu::ip_is_ipv6($sys->{sys})) {
            $hostname = $sys->cmd("_cmd_hostname");
        } else {
            $hostname = $sys->{sys};   
        }
    }
    my $rootpath=Cfg::opt('rootpath') || '';
    $rsh=$sys->{rsh};
    my $export_rootpath = ($rootpath) ?
        "INSTALL_ROOT_PATH=$rootpath; export INSTALL_ROOT_PATH;" : '';
    my $cmd_uuidconfig = $export_rootpath.$rootpath.$prod->{uuidconfig};
    if($rsh =~/rsh/m) {
        $cmd=$cmd_uuidconfig." -cpi -rsh -clus -configure -force $hostname";
    }else {
        $cmd=$cmd_uuidconfig." -cpi -clus -configure -force $hostname";
    }
    if (Cfg::opt('makeresponsefile')) {
        EDR::cmd_local($cmd);
    } else {
        $sys->cmd($cmd);
    }
    if(EDR::cmdexit()){
        Msg::log('UUID could not be created successfully on the cluster');
        return 0;
    }
    return 1;
 }


sub copy_uuid {
    my ($prod,$sys_src,$sys_dest) = @_;
    my ($src_obj,@sysnamelist,$sys,@syslist);

    return 0 if(($sys_src eq  '') || ($sys_dest eq ''));
    $src_obj=($Obj::pool{"Sys::$sys_src"}) ? Obj::sys($sys_src) : Sys->new($sys_src);
    @sysnamelist=split(/\s+/m,$sys_dest);
    for my $sysname (@sysnamelist){
        $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
        push(@syslist,$sys);
    }
    for my $sys (@syslist){
        $prod->copy_uuid_2sys($src_obj,$sys);
    }
    return 1;
}

sub ask_clusterid {
    my ($prod,$def_id) = @_;
    my ($msg,$cfg,$w_msg,$backopt,$answer,$help);
    return '' if (Cfg::opt('responsefile'));

    $cfg=Obj::cfg();
    $def_id = '' unless ($def_id);
    $msg = Msg::new("Enter a unique cluster ID number between 0-65535:");
    $w_msg=Msg::new("The cluster ID number is wrong. Re-enter the cluster ID");
    $help = Msg::new("Each $prod->{abbr} cluster has a unique identifier that is an integer value between 0 and 65535. System will panic if it is configured with a Cluster identifier that is already being used by another cluster.");
    $backopt = 1;
    while (1) {
        $answer = $msg->ask($def_id,$help,$backopt);
        return "$answer" if (EDR::getmsgkey($answer,'back'));
        $answer=~s/^0+//m;
        $answer||=0;
        if ((EDRu::isint($answer) == 1) && ($answer>=0) && ($answer<=65535)){
           $cfg->{vcs_clusterid}=$answer;
           return "$answer";
        } else {
           $w_msg->print;
        }
    }
    return;
}

# ask for cluster name
sub ask_clustername {
    my ($prod,$def_name) = @_;
    my ($msg,$edr,$backopt,$answer,$help);
    my $cfg=Obj::cfg();
    return '' if (Cfg::opt('responsefile'));
    $msg = Msg::new("Enter the unique cluster name:");
    $help = Msg::new("Each $prod->{abbr} cluster has a name which must begin with a letter of an alphabet. Only letters, numbers, or the characters - and _ are allowed in a cluster name.");
    $backopt = 0;
    while (1) {
        $answer = $msg->ask($def_name,$help,$backopt);
        if ($prod->verify_clustername($answer)) {
            $cfg->{vcs_clustername}=$answer;
            return $answer;
        }
    }
    return;
}

sub ask_bonded_nic {
    my ($prod,$nic) = @_;
    my ($msg,$ayn);
    $msg=Msg::new("Is $nic a bonded NIC?");
    $ayn=$msg->aynn();
    return 1 if ($ayn eq 'Y');
    return 0;
}

sub is_rdma_supported {
    my ($prod) = @_;

    return $prod->{padv} =~ /RHEL6|SLES11/ ? 1 : 0;
}

sub hb_config_option {
    my ($prod,$autocfg_failed) = @_;
    my ($msg,$items,$cfg,$backopt,$defaultopt,$rhbn,$help,$option);

    my $rdma_sp = $prod->is_rdma_supported();
    $cfg = Obj::cfg();
    $msg = Msg::new("Configure the heartbeat links using LLT over Ethernet");
    push(@{$items},$msg->{msg});
    $msg = Msg::new("Configure the heartbeat links using LLT over UDP");
    push(@{$items},$msg->{msg});
    $help = Msg::new("Configuring heartbeat links using LLT over Ethernet is the recommended option.\nLLT over UDP is slower than LLT over Ethernet. Use LLT over UDP only when the hardware configuration makes it necessary.");
    if ($rdma_sp) {
        $msg = Msg::new("Configure the heartbeat links using LLT over RDMA");
        push(@{$items},$msg->{msg});
        $msg = Msg::new("\nLLT over RDMA (Remote Direct Memory Access) enables GAB and LLT to support the fast interconnect between cluster nodes. RDMA works on both InfiniBand and Ethernet networks.");
        $help->{msg} .= $msg->{msg};
    }
    if (!Cfg::opt('makeresponsefile') && scalar(@{CPIC::get('systems')}) > 1 && !$autocfg_failed) {
        $msg = Msg::new("Automatically detect configuration for LLT over Ethernet");
        push(@{$items},$msg->{msg});
        $help->{msg} .= Msg::new("\nIf option 'Automatically detect configuration for LLT over Ethernet' is selected, installer checks network connectivity of all NICs on each system and configures interconnected NICs for LLT heartbeat links. The priority of each LLT heartbeat link is determined by the media speed of the link and whether this link is connected to a public network.")->{msg};
    }

    $msg = Msg::new("How would you like to configure heartbeat links?");

    $backopt = 1;
    if ($cfg->{lltoverudp}) {
        $defaultopt = '2';
    } elsif (!Cfg::opt('makeresponsefile') && scalar(@{CPIC::get('systems')}) > 1 && !$autocfg_failed) {
        $defaultopt = $rdma_sp ? '4' : '3';
    } else {
        $defaultopt = '1';
    }
    while (1) {
        Msg::title() if (! $autocfg_failed);
        $option = $msg->menu($items, $defaultopt, $help, $backopt);
        Msg::n();
        $prod->{llt_rdma} = 0;
        if ($option eq '2') {
            $cfg->{lltoverudp} = 1;
            $cfg->{autocfgllt} = 0;
            return $prod->ask_hbnics();
        } elsif (($option eq '3') && $rdma_sp) {
            # Re-show the LLT configure menu if fail to setup RDMA environment.
            next if (!$prod->setup_rdma_env());

            $cfg->{lltoverudp} = 0;
            $cfg->{autocfgllt} = 0;
            $prod->{llt_rdma} = 1;

            return $prod->ask_hbnics();
        } elsif (($option eq '4') || (($option eq '3') && !$rdma_sp)) {
            return $prod->auto_config_llt();
        } elsif (EDR::getmsgkey($option,'back')) {
            return $option;
        } else {
            $cfg->{lltoverudp} = 0;
            $cfg->{autocfgllt} = 0;
            return $prod->ask_hbnics();
        }
    }
}

# Return 0:  means fail to setup RDMA environment on the systems
# Return 1:  means successfully setup RDMA environment on the systems
sub setup_rdma_env {
    my ($prod) = @_;

    if (Cfg::opt(qw/responsefile makeresponsefile silent/)) {
        # setup RDMA environment require user confirmation.
        # so we don't provide this option with responsefile.
        return 0;
    }

    $prod->{rdma_fatal_errors}=0;

    # $rdma_type could the following values:
    #   1.  RoCE
    #   2.  InfiniBand
    my $rdma_type=$prod->get_rdma_type();
    return 0 if (!$rdma_type);
    if(Obj::webui()){
        my $web = Obj::web();
        $web->web_script_form('showstatus','');
    }
    # Check if RDMA required OS pkgs are ready
    my $rtn=$prod->check_rdma_required_os_pkgs($rdma_type);
    return 0 if ($prod->{rdma_fatal_errors});
    if (!$rtn) {
        # If there are some required OS pkgs not installed
        # then try to install them
        $rtn=$prod->install_rdma_required_os_pkgs($rdma_type);
        return 0 if (!$rtn);
    }

    # If required OS pkgs are ready
    # then check if RDMA driver configuration ready
    $rtn=$prod->check_rdma_configurations($rdma_type);
    return 0 if ($prod->{rdma_fatal_errors});
    if (!$rtn) {
        # if RDMA driver and service not ready
        # then create RDMA driver and service configuration
        $rtn=$prod->setup_rdma_configurations($rdma_type);
        return 0 if (!$rtn);
    }

    # If required OS pkgs are ready
    # and RDMA driver configuration are ready
    # then check IP address for RDMA NICs
    $rtn=$prod->check_rdma_nic_ips($rdma_type);
    return 0 if ($prod->{rdma_fatal_errors});
    if (!$rtn) {
        # if IP addresses of RDMA NICs not ready
        # then setup IP addresses for RDMA NICs
        # Design changed: do not need configure IP address here, will configure it later when select LLT links.
        #$rtn=$prod->setup_rdma_nic_ips($rdma_type);
        #return 0 if (!$rtn);
    }

    return 1;
}

sub display_rdma_errors_warnings {
    my ($prod) = @_;
    my ($cpic,$errors);

    $cpic = Obj::cpic();
    $errors='';
    for my $sys (@{$cpic->{systems}}) {
        for my $msg (@{$sys->{errors}},
                     @{$sys->{warnings}},
                     @{$sys->{notes}}) {
            $errors.=$msg . "\n";
        }
        undef $sys->{errors};
        undef $sys->{warnings};
        undef $sys->{notes};
    }

    chomp $errors;
    if ($errors) {
        Msg::print("\n" . $errors);
        if (Obj::webui()) {
            my $web = Obj::web();
            $web->web_script_form('alert',$errors);
        }
        return 0;
    }
    return 1;
}

sub get_rdma_type {
    my ($prod) = @_;
    my ($msg,$help,$menus,$backopt,$defaultopt,$option,$cfg,$web);

    if(Obj::webui()){
        $web = Obj::web();
        my $type = $web->web_script_form('rdma_type');
        return '' if ($web->{back} eq'back');
        return $type;
    }
    $msg = Msg::new("Converged Ethernet (RoCE)");
    push(@{$menus},$msg->{msg});

    $msg = Msg::new("InfiniBand");
    push(@{$menus},$msg->{msg});

    $msg=Msg::new("Choose the RDMA interconnect type");

    $backopt = 1;
    $defaultopt = 1;
    $help=Msg::new("Remote Direct Memory Access (RDMA) is the remote memory access capability that allows server to server data movement directly between application memories with minimal CPU involvement. Data transfer using RDMA needs RDMA-enabled network cards and switches. Networks designed with RDMA over Converged Ethernet (RoCE) and InfiniBand architecture support RDMA capability.");

    $option = $msg->menu($menus,$defaultopt,$help,$backopt);
    if ($option eq '1') {
        return 'RoCE';
    } elsif ($option eq '2') {
        return 'InfiniBand';
    }
    return '';
}

sub check_rdma_required_os_pkgs {
    my ($prod,$rdma_type) = @_;
    my ($cpic,$msg,$rtn,$feature,$pdfrs,$missing_ospkgs,$pkgs);

    $rtn=1;
    $pdfrs=Msg::get('pdfrs');
    $feature='LLT_over_RDMA';
    $feature.='_' . $rdma_type if ($rdma_type);

    Msg::n();
    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {
        undef $sys->{errors};
        undef $sys->{warnings};
        undef $sys->{notes};

        $msg=Msg::new("Checking required OS $pdfrs for LLT over RDMA on $sys->{hostname}");
        $msg->left();
        $msg->display_status() if(Obj::webui());
        if ($prod->check_rdma_required_os_pkgs_sys($sys,$feature)) {
            Msg::right_done();
        } else {
            Msg::right_failed();
            $rtn=0;
            $missing_ospkgs=$sys->{missing_ospkgs_for_feature}{$feature};
            if (defined $missing_ospkgs && @{$missing_ospkgs}) {
                $pkgs = join("\n\t",@{$missing_ospkgs});
                $msg=Msg::new("The following required OS $pdfrs were not found on $sys->{sys}. Install the required OS $pdfrs as they are important for troubleshooting and functionality:\n\t$pkgs");
                $sys->push_warning($msg);
            }
        }
    }

    $prod->display_rdma_errors_warnings();

    # Pause if something wrong happen
    Msg::prtc() if ($prod->{rdma_fatal_errors});

    return $rtn;
}

sub check_rdma_required_os_pkgs_sys {
    my ($prod,$sys,$feature) = @_;
    my ($msg,$pdfrs,$mlnx,$vers);

    # Check if Mellanox OFED external packages installed, which is not support
    $mlnx=$sys->cmd("/usr/bin/ofed_info 2>/dev/null | _cmd_grep '^MLNX_OFED'");
    if ($mlnx) {
        $pdfrs=Msg::get('pdfrs');
        $vers='';
        if ($mlnx=~/.*\((.*)\)/) {
            $vers=" ($1)";
        }
        $msg=Msg::new("The external OFED ${pdfrs}${vers} were installed on the system $sys->{sys}, which is not supported. Only the OFED ${pdfrs} shipped with native OS are supported.");
        $sys->push_error($msg);
        $prod->{rdma_fatal_errors}=1;
        return 0;
    }

    # Check if any required OS packages are installed or not.
    return $prod->check_feature_required_os_pkgs_sys($sys,$feature);
}

sub install_rdma_required_os_pkgs {
    my ($prod,$rdma_type) =@_;
    my ($msg,$help,$menus,$backopt,$defaultopt,$option,$pdfrs,$native_method);

    $pdfrs=Msg::get('pdfrs');

    # Show messages that some required OS packages were not installed
    # CPI will provide 2 options to help user install those packages
    # or show guidance how to install thme manually.
    Msg::n();

    $native_method=$prod->{native_install_tool};
    if ($native_method) {
        if (Obj::webui()){
            my $web = Obj::web();
            $option = $web->web_script_form('rdma_missing',$pdfrs, $native_method);
        } else {
            $msg=Msg::new("Some required OS $pdfrs were not found. The installer will provide some guidance about how to install OS $pdfrs using native methods, like $native_method, or how to manually install the required OS $pdfrs.");
            $msg->printn();

            # Show options about how to install those missing required OS packages.
            $msg = Msg::new("Install the missing required OS $pdfrs with $native_method, if $native_method is configured on the systems");
            push(@{$menus},$msg->{msg});

            $msg = Msg::new("Install the missing required OS $pdfrs manually, (detailed steps will be provided)");
            push(@{$menus},$msg->{msg});

            $msg = Msg::new("How would you like to install the missing required OS $pdfrs?");

            $backopt = 1;
            $defaultopt = 1;
            $help=Msg::new("Select option about how to install those missing required OS $pdfrs");

            $option = $msg->menu($menus,$defaultopt,$help,$backopt);
        }
        if ($option eq '1') {
            return $prod->install_rdma_required_os_pkgs_with_native_tool($rdma_type);
        } elsif ($option eq '2') {
            return $prod->install_rdma_required_os_pkgs_with_manual_guide($rdma_type);
        }
    } else {
        $msg=Msg::new("Some required OS $pdfrs were not found, installer will provide some guidance about how to install them manually.");
        $msg->printn();

        return $prod->install_rdma_required_os_pkgs_with_manual_guide($rdma_type);
    }

    return 0;
}

sub install_rdma_required_os_pkgs_with_native_tool {
    my ($prod,$rdma_type)=@_;
    my ($cpic,$msg,$pdfrs,$native_method,$feature,$missing_ospkgs,$rtn);

    $pdfrs=Msg::get('pdfrs');
    $native_method=$prod->{native_install_tool};
    $feature='LLT_over_RDMA';
    $feature.='_' . $rdma_type if ($rdma_type);

    $msg = Msg::new("Installation may take a few minutes, be patient.");
    $msg->nprint;

    Msg::n();
    $rtn=1;
    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {
        $missing_ospkgs=$sys->{missing_ospkgs_for_feature}{$feature};
        next unless (defined $missing_ospkgs && @{$missing_ospkgs});

        $msg=Msg::new("Install the missing OS $pdfrs with $native_method on $sys->{hostname}");
        $msg->left();
        if ($prod->install_rdma_required_os_pkgs_with_native_tool_sys($sys,$missing_ospkgs)) {
            Msg::right_done();
        } else {
            Msg::right_failed();
            $prod->{rdma_fatal_errors}=1;
            $rtn=0;
        }
    }

    $prod->display_rdma_errors_warnings();

    # Pause if something wrong happen
    Msg::prtc() if (!$rtn);

    return $rtn;
}

sub install_rdma_required_os_pkgs_with_native_tool_sys {
    my ($prod,$sys,$missing_ospkgs)=@_;
    my ($native_install_cmd,$pkgs,$msg);

    return 1 unless (defined $missing_ospkgs && @{$missing_ospkgs});

    $native_install_cmd=$prod->{native_install_cmd};
    return 1 unless ($native_install_cmd);

    $pkgs=join(' ', @{$missing_ospkgs});
    $sys->cmd("$native_install_cmd $pkgs 2>&1");
    if (EDR::cmdexit()) {
        $msg=Msg::new("'$native_install_cmd $pkgs' failed on $sys->{sys}");
        $sys->push_warning($msg);
        return 0;
    }
    return 1;
}

sub install_rdma_required_os_pkgs_with_manual_guide {
    my ($prod,$rdma_type)=@_;
    my ($cpic,$msg,$pdfrs,$native_method,$native_cmd,$package_cmd,$feature,$missing_ospkgs,$pkgs,$webmsg);

    $pdfrs=Msg::get('pdfrs');
    $feature='LLT_over_RDMA';
    $feature.='_' . $rdma_type if ($rdma_type);

    Msg::n();
    $cpic = Obj::cpic();

    $native_method=$prod->{native_install_tool};
    $native_cmd=$prod->{native_install_cmd};
    if ($native_method && $native_cmd) {
        $msg=Msg::new("If $native_method was configured on the systems, run the following command to install the OS $pdfrs manually:");
        $msg->printn;
        $webmsg .= $msg->{msg}.'\\n';
        for my $sys (@{$cpic->{systems}}) {
            $missing_ospkgs=$sys->{missing_ospkgs_for_feature}{$feature};
            next unless (defined $missing_ospkgs && @{$missing_ospkgs});

            $pkgs=join(' ', @{$missing_ospkgs});
            $msg=Msg::new("    On $sys->{sys}, run: $native_cmd $pkgs");
            $msg->print;
            $webmsg .= $msg->{msg}.'\\n';
        }
    }

    $package_cmd=$prod->{package_install_cmd};
    if ($package_cmd) {
        Msg::n();
        $msg=Msg::new("Or change directory to the package repository, and run the following package install command to install the OS $pdfrs manually:");
        $msg->printn;
        $webmsg .= $msg->{msg}.'\\n';
        for my $sys (@{$cpic->{systems}}) {
            $missing_ospkgs=$sys->{missing_ospkgs_for_feature}{$feature};
            next unless (defined $missing_ospkgs && @{$missing_ospkgs});

            $msg=Msg::new("    On $sys->{sys}, run:");
            $msg->print;
            $webmsg .= $msg->{msg}.'\\n';
            for my $pkg (@{$missing_ospkgs}) {
                $msg=Msg::new("        $package_cmd ${pkg}-*.rpm");
                $msg->print;
                $webmsg .= $msg->{msg}.'\\n';
            }
        }
    }
    if (Obj::webui()){
        my $web = Obj::web();
        $web->web_script_form('alert',$webmsg);
    }
    Msg::prtc();
    return 0;
}

sub check_rdma_configurations {
    my ($prod,$rdma_type) = @_;
    my ($cpic,$msg,$rtn);

    Msg::n();
    $rtn=1;
    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {

        # Checking RDMA kernel modules
        $msg=Msg::new("Checking RDMA driver and configuration on $sys->{hostname}");
        $msg->left();
        $msg->display_status() if(Obj::webui());
        if ($prod->check_rdma_driver_config_sys($sys,$rdma_type)) {
            Msg::right_done();
            $sys->{rdma_driver_config_ready}=1;
        } else {
            #Msg::right_failed();
            Msg::right_done();
            $rtn=0;
            $sys->{rdma_driver_config_ready}=0;
            next if ($prod->{rdma_fatal_errors});
        }

        if ($rdma_type eq 'InfiniBand') {
            # Checking RDMA opensm service if InfiniBand
            $msg=Msg::new("Checking RDMA opensm service on $sys->{hostname}");
            $msg->left();
            if ($prod->check_rdma_opensm_service_sys($sys,$rdma_type)) {
                Msg::right_done();
                $sys->{rdma_opensm_service_ready}=1;
            } else {
                #Msg::right_failed();
                Msg::right_done();
                $rtn=0;
                $sys->{rdma_opensm_service_ready}=0;
            }
        }
    }

    $prod->display_rdma_errors_warnings();

    # Pause if something wrong happen
    Msg::prtc() if ($prod->{rdma_fatal_errors});

    return $rtn;
}

sub check_rdma_driver_config_sys {
    my ($prod,$sys,$rdma_type) = @_;
    my ($ib_ports,$drv,$msg);

    $drv=$prod->{rdma_driver_file} || '';
    return 1 if (!$drv);

    #$drv_entries=$sys->cmd("_cmd_grep -v '^#' $drv 2>/dev/null");
    return 0;
}

sub check_rdma_opensm_service_sys {
    my ($prod,$sys,$rdma_type) = @_;
    return 1;
}

sub setup_rdma_configurations {
    my ($prod,$rdma_type) = @_;
    my ($cpic,$msg,$rtn);

    $rtn=1;
    $cpic = Obj::cpic();

    # Configure RDMA based on above questions
    Msg::n();
    for my $sys (@{$cpic->{systems}}) {
        if (!$sys->{rdma_driver_config_ready}) {
            $msg=Msg::new("Configuring and starting RDMA drivers on $sys->{hostname}");
            $msg->left();
            if ($prod->setup_rdma_driver_config_sys($sys,$rdma_type)) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $rtn=0;
            }
        }

        if ($rdma_type eq 'InfiniBand') {
            # Configure RDMA opensm service if InfiniBand
            if (!$sys->{rdma_opensm_service_ready}) {
                $msg=Msg::new("Configuring and starting RDMA opensm service on $sys->{hostname}");
                $msg->left();
                if ($prod->setup_rdma_opensm_service_sys($sys,$rdma_type)) {
                    Msg::right_done();
                } else {
                    Msg::right_failed();
                    $rtn=0;
                }
            }
        }
    }

    $prod->display_rdma_errors_warnings();

    # Pause if something wrong happen
    Msg::prtc() if ($prod->{rdma_fatal_errors});

    return $rtn;
}

sub setup_rdma_driver_config_sys {
    my ($prod,$sys,$rdma_type) = @_;
    return 1;
}

sub setup_rdma_opensm_service_sys {
    my ($prod,$sys,$rdma_type) = @_;
    return 1;
}

sub check_rdma_nic_ips {
    my ($prod,$rdma_type) = @_;
    my ($cpic,$msg,$systems,$rtn);

    # Check each NIC's IP for every system
    Msg::n();
    $rtn=1;
    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {
        # Check RDMA IP address configuration on NICs
        $msg=Msg::new("Checking the IP address for the RDMA enabled NICs on $sys->{hostname}");
        $msg->left();
        $msg->display_status() if(Obj::webui());
        if ($prod->check_rdma_nic_ips_sys($sys,$rdma_type)) {
            Msg::right_done();
            $sys->{rdma_nic_ips_ready}=1;
        } else {
            #Msg::right_failed();
            Msg::right_done();
            $rtn=0;
            $sys->{rdma_nic_ips_ready}=0;
        }
    }

    $prod->display_rdma_errors_warnings();

    # Pause if something wrong happen
    if ($prod->{rdma_fatal_errors}) {
        # if no RDMA enabled NIC exist on the system
        # print errors and exit.
        Msg::prtc();
    } else {
        $prod->display_rdma_nic_ips();
    }
    return $rtn;
}

sub check_rdma_nic_ips_sys {
    my ($prod,$sys,$rdma_type) = @_;
    my ($padv,$all_nics,$rdma_nics,@rdma_nics_without_ip,$ips,$ip,$default_ip,$need_configure_ip,$msg);

    # Get if there are some RDMA enabled NICs already configured IPv4 addresses
    # Totally 3 scenarios:
    # 1. No RDMA enabled NICs on the systems, report error and do not need configure IP.
    # 2. All RDMA enabled NICs on the systems have IP assigned, report succeed and do not need configure IP.
    # 3. Some RDMA enabled NICs do not have IP, report warning and need configure IP.
    $padv = $sys->padv;
    $all_nics=$padv->systemnics_sys($sys,1);
    $rdma_nics=$prod->rdmanics_sys($sys,$all_nics);
    if (!@$rdma_nics) {
        # Case 1.
        $msg=Msg::new("There are no RDMA enabled NICs on $sys->{sys}");
        $sys->push_warning($msg);
        $prod->{rdma_fatal_errors}=1;
        return 0;
    }

    $sys->set_value('rdma_nics', 'list', @$rdma_nics);

    $need_configure_ip=0;
    for my $nic (@$rdma_nics) {
        $ips=$padv->nic_ips_sys($sys,$nic);
        if (@$ips) {
            @$ips = grep { EDRu::ip_is_ipv4($_) } @$ips;
        }
        if (@$ips) {
            $sys->set_value("rdma_nic_ip,$nic", 'list', @$ips);
            if (!$sys->{rdma_nic_default_ip}) {
                $default_ip=$ips->[0];
                $sys->set_value("rdma_nic_default_ip", $default_ip);
            }
        } else {
            push @rdma_nics_without_ip, $nic;
            $need_configure_ip=1;
        }
    }

    if ($need_configure_ip) {
        # Case 3
        $rdma_nics=join ' ', @rdma_nics_without_ip;
        $msg=Msg::new("There are no IP addresses assigned for RDMA enabled NICs $rdma_nics on $sys->{sys}");
        $sys->push_warning($msg);
        $sys->set_value('rdma_nics_without_ip', 'list', @rdma_nics_without_ip);
        return 0;
    }

    # Case 2 that all RDMA enabled NICs have IP configured
    return 1;
}

sub display_rdma_nic_ips {
    my ($prod,$rdma_type,$confirm) = @_;
    my ($cpic,$msg,$nics,$ips,$ip);
    my ($format,$msg_system,$msg_nic,$msg_ip,$webmsg);

    # Display each NIC's IP for every system
    Msg::n();

    # Show help information and title
    $msg=Msg::new("More detailed information about the IP address of the RDMA enabled NICs:");
    $msg=Msg::new("Confirm the IP address of the RDMA enabled NICs:") if ($confirm);
    $msg->printn;

    $webmsg = '<b>'.$msg->{msg}.'</b>';
    $webmsg .= '<table cellspacing=20>';
    $webmsg .= '<tbody>';

    $format = '%-20s %-15s   %-s';
    $msg_system=Msg::new("System");
    $msg_nic=Msg::new("RDMA NIC");
    $msg_ip=Msg::new("IP Address");
    $msg=Msg::string_sprintf($format,$msg_system->{msg},$msg_nic->{msg},$msg_ip->{msg});
    Msg::bold($msg);
    print '=' x 80 . "\n";

    $webmsg .= '<tr>';
    $webmsg .= '<td>' . '<B>' . $msg_system->{msg} . '</B>' . '</td>';
    $webmsg .= '<td>' . '<B>' . $msg_nic->{msg} . '</B>' . '</td>';
    $webmsg .= '<td>' . '<B>' . $msg_ip->{msg} . '</B>' . '</td>';
    $webmsg .= '</tr>';

    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {
        # Display RDMA IP address configuration on NICs
        $nics=$sys->{rdma_nics};
        next unless (defined $nics && @{$nics});

        for my $nic (@$nics) {
            $ip='';
            if ($confirm) {
                $ip=$sys->{rdma_nic_configured_ip}{$nic} || $sys->{rdma_nic_ip}{$nic};
                $ip||=Msg::new("NULL")->{msg};
            } else {
                $ips=$sys->{rdma_nic_ip}{$nic};
                if ($ips && @{$ips}) {
                    $ip=join ',', @$ips;
                } else {
                    $ip=Msg::new("NULL")->{msg};
                }
            }
            $msg=Msg::string_sprintf($format,$sys->{sys},$nic,$ip);

            $webmsg .= '<tr>';
            $webmsg .= '<td>' . $sys->{sys} . '</td>';
            $webmsg .= '<td>' . $nic . '</td>';
            $webmsg .= '<td>' . $ip . '</td>';
            $webmsg .= '</tr>';

            Msg::print($msg);
        }
    }
    if (Obj::webui()){
        $webmsg .= '</tbody>';
        $webmsg .= '</table>';
        my $web = Obj::web();
        $web->web_script_form('alert', $webmsg);
    }
    Msg::n();

    return 1;
}

sub save_rdma_nic_ips {
    my ($prod,$rdma_type) = @_;
    my ($cpic,$msg,$rtn,$rdma_nics,$rdma_ip,$rdma_netmask);

    # Check each NIC's IP for every system
    Msg::n();
    $rtn=1;
    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {
        # Save RDMA IP address configuration for NICs
        $rdma_nics=$sys->{rdma_nics};
        next unless ($rdma_nics && @{$rdma_nics});

        for my $nic (@{$rdma_nics}) {
            $rdma_ip=$sys->{rdma_nic_configured_ip}{$nic};
            $rdma_netmask=$sys->{rdma_nic_configured_netmask}{$nic}||'255.255.255.0';
            next unless $rdma_ip;

            $msg=Msg::new("Saving IP address configuration for RDMA NIC $nic on $sys->{hostname}");
            $msg->left();
            if ($prod->save_rdma_nic_ips_sys($sys,$rdma_type,$nic,$rdma_ip,$rdma_netmask)) {
                Msg::right_done();
            } else {
                #Msg::right_failed();
                Msg::right_done();
                $rtn=0;
            }
        }
    }

    $prod->display_rdma_errors_warnings();

    # Pause if something wrong happen
    if ($prod->{rdma_fatal_errors}) {
        # if no RDMA enabled NIC exist on the system
        # print errors and exit.
        Msg::prtc();
    }

    return $rtn;
}

sub save_rdma_nic_ips_sys {
    my ($prod,$sys,$rdma_type,$nic,$rdma_ip,$rdma_netmask) = @_;

    return $sys->padv->configure_static_ip_sys($sys,$nic,$rdma_ip,$rdma_netmask);
}

sub auto_config_llt {
    my ($prod) = @_;
    my ($cfg,$msg,$rhbn);
    $cfg = Obj::cfg();
    $cfg->{lltoverudp} = 0;
    $cfg->{autocfgllt} = 1;
    # On Linux systems NICs need to be activated before DLPI can work correctly on them.
    if (EDRu::plat($prod->{padv}) eq 'Linux') {
        $msg=Msg::new("On Linux systems, only activated NICs can be detected and configured automatically.");
        $msg->print;
        Msg::prtc();
    }
    $rhbn = $prod->autocfg_hbnics();
    if ($prod->num_hbnics($rhbn)< 1) {
        # if llt auto detection failed, unset silent option.
        Cfg::unset_opt('silent');
        $msg=Msg::new("Failed to detect and configure LLT heartbeat links. Configure LLT manually.");
        $msg->n();
        $msg->bold();
        $msg->n();
        return $prod->hb_config_option('autocfg_failed');
    } else {
        return $rhbn;
    }
}

# ask for all heartbeat links
sub ask_hbnics {
    my($cfg,$padv,$prod,$sys,$sysi,$msg,$cprod);
    my($all,$ayn,%hbn,@en,$dsn,$hb,$hb2,$hb3,$hb4,$hbl,$ip,$port,$rpn,$rsn,$all_rsn,$udp_port,$used_port,$rtn,$rdmas);
    return '' if (Cfg::opt('responsefile'));
    $prod=shift;

    $cfg=Obj::cfg();
    $cprod=CPIC::get('prod');
    $used_port = [];
    $rdmas = [];
    my $rdma_tag = $prod->{llt_rdma} ? 1 : 0;
    for my $sys (@{CPIC::get('systems')}) {
        $sysi=$sys->{sys};
        $padv=$sys->padv;
        if ($all) {
            $hbn{lltlink1}{$sysi}=$en[1];
            $hbn{lltlink2}{$sysi}=$en[2] if ($en[2]);
            $hbn{lltlink3}{$sysi}=$en[3] if ($en[3]);
            $hbn{lltlink4}{$sysi}=$en[4] if ($en[4]);
            $hbn{lltlinklowpri1}{$sysi}=$en[$prod->{max_hipri_links}+1] if ($en[$prod->{max_hipri_links}+1]);
            $cfg->{$sysi}{bonded_nics}=$cfg->{${CPIC::get('systems')}[0]->{sys}}{bonded_nics};
        } else {
            undef(@en);
            $rsn=$rpn=[];
            if (EDRu::inarr($sys,@{CPIC::get('systems')})) {
                $msg=Msg::new("Discovering NICs on $sysi");
                $msg->left;
                $padv=$sys->padv;
                $all_rsn=$padv->systemnics_sys($sys,1);
                $rsn=$all_rsn;
                $rsn=$prod->rdmanics_sys($sys,$all_rsn) if ($rdma_tag);
                $rpn=$padv->gatewaynics_sys($sys);
                EDRu::arruniq(@$rsn);
                $dsn=join(' ',@$rsn);
                if ($#$rsn<0) {
                    $msg=Msg::new("No NICs discovered");
                    $msg->right;
                } else {
                    $msg=Msg::new("Discovered $dsn");
                    $msg->right;
                    #$msg=Msg::new("\nTo use aggregated interfaces for private heartbeat, enter the name of an aggregated interface. \nTo use a NIC for private heartbeat, enter a NIC which is not part of an aggregated interface.\n");
                    #$msg->print;
                }
                Msg::n();
            }
        }

ASK_CFG_LINK1_AGAIN:
        unless ($all) {
            # link 1
            $hb = $prod->ask_hbnic_sys($sys,1,$rsn,$rpn,undef,undef,$rdma_tag);
            return $hb if (EDR::getmsgkey($hb,'back'));
            $hbn{lltlink1}{$sysi} = $en[1] = $hb;
            if ($padv->is_bonded_nic_sys($sys,$hb)){
                push(@{$cfg->{$sysi}{bonded_nics}},$hb);
            }
        }

        $rtn = $prod->config_llt_rdma_sys($sys,\%hbn,\@en,$used_port,1,$rdmas);
        return $rtn if (EDR::getmsgkey($rtn,'back'));
        goto ASK_CFG_LINK1_AGAIN if ($rtn eq 'N');
        if ($cfg->{lltoverudp}) {
            $ip = $prod->ask_nic_ip_sys($sys,$en[1],1,0,\%hbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            goto ASK_CFG_LINK1_AGAIN if ($ip eq 'N');
            $hbn{udplink1_address}{$sysi}=$ip->{address};
            $hbn{udplink1_netmask}{$sysi}=$ip->{netmask};
            if ($used_port->[1]) {
                $port = $used_port->[1];
                $msg=Msg::new("The UDP Port for this link: $port");
                $msg->printn;
                $hbn{udplink1_port}{$sysi} = $used_port->[1];
            } else {
                $udp_port = $prod->ask_udp_port_sys($sys,1,$used_port);
                return $udp_port if (EDR::getmsgkey($udp_port,'back'));
                $hbn{udplink1_port}{$sysi} = $used_port->[1] = $udp_port;
            }
        }

ASK_CFG_LINK2_AGAIN:
        # link 2
        unless ($all) {
            # If fencing is not enabled, we must ask for second private link
            if (!$cfg->{fencingenabled}) {
                Msg::n();
                $hb2='Y'
            }
            $hb2||= $prod->ask_second_hb;
            return $hb2 if (EDR::getmsgkey($hb2,'back'));
            if ($hb2 eq 'Y') {
                $hb = $prod->ask_hbnic_sys($sys,2,$rsn,$rpn,\@en);
                return $hb if (EDR::getmsgkey($hb,'back'));
                $hbn{lltlink2}{$sysi} = $en[2] = $hb;
                if ($padv->is_bonded_nic_sys($sys,$hb)){
                    push(@{$cfg->{$sysi}{bonded_nics}},$hb);
                }
            }
        }
        if ($hb2 eq 'Y') {
            $rtn = $prod->config_llt_rdma_sys($sys,\%hbn,\@en,$used_port,2,$rdmas);
            return $rtn if (EDR::getmsgkey($rtn,'back'));
            if ($rtn eq 'N') {
                pop @en;
                goto ASK_CFG_LINK2_AGAIN;
            }
        }
        if ($cfg->{lltoverudp} && ($hb2 eq 'Y')) {
            $ip = $prod->ask_nic_ip_sys($sys,$en[2],2,0,\%hbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            if ($ip eq 'N') {
                pop @en;
                goto ASK_CFG_LINK2_AGAIN;
            }
            $hbn{udplink2_address}{$sysi}=$ip->{address};
            $hbn{udplink2_netmask}{$sysi}=$ip->{netmask};
            if ($used_port->[2]) {
                $port = $used_port->[2];
                $msg=Msg::new("The UDP Port for this link: $port");
                $msg->printn;
                $hbn{udplink2_port}{$sysi} = $used_port->[2];
            } else {
                $udp_port = $prod->ask_udp_port_sys($sys,2,$used_port);
                return $udp_port if (EDR::getmsgkey($udp_port,'back'));
                $hbn{udplink2_port}{$sysi} = $used_port->[2] = $udp_port;
            }
        }

ASK_CFG_LINK3_AGAIN:
        # link 3
        unless ($all) {
            if (($hb2 eq 'Y') && ($#$rsn>2)) {
                $hb3=$prod->ask_third_hb;
                return $hb3 if (EDR::getmsgkey($hb3,'back'));
            }
            if ($hb3 eq 'Y') {
                $hb = $prod->ask_hbnic_sys($sys,3,$rsn,$rpn,\@en);
                return $hb if (EDR::getmsgkey($hb,'back'));
                $hbn{lltlink3}{$sysi} = $en[3] = $hb;
                if ($padv->is_bonded_nic_sys($sys,$hb)){
                    push(@{$cfg->{$sysi}{bonded_nics}},$hb);
                }
            }
        }
        if ($hb3 eq 'Y') {
            $rtn = $prod->config_llt_rdma_sys($sys,\%hbn,\@en,$used_port,3,$rdmas);
            return $rtn if (EDR::getmsgkey($rtn,'back'));
            if ($rtn eq 'N') {
                pop @en;
                goto ASK_CFG_LINK3_AGAIN;
            }
        }
        if ($cfg->{lltoverudp} && ($hb3 eq 'Y')) {
            $ip = $prod->ask_nic_ip_sys($sys,$en[3],3,0,\%hbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            if ($ip eq 'N') {
                pop @en;
                goto ASK_CFG_LINK3_AGAIN;
            }
            $hbn{udplink3_address}{$sysi}=$ip->{address};
            $hbn{udplink3_netmask}{$sysi}=$ip->{netmask};
            if ($used_port->[3]) {
                $port = $used_port->[3];
                $msg=Msg::new("The UDP Port for this link: $port");
                $msg->printn;
                $hbn{udplink3_port}{$sysi} = $used_port->[3];
            } else {
                $udp_port = $prod->ask_udp_port_sys($sys,3,$used_port);
                return $udp_port if (EDR::getmsgkey($udp_port,'back'));
                $hbn{udplink3_port}{$sysi} = $used_port->[3] = $udp_port;
            }
        }

ASK_CFG_LINK4_AGAIN:
        # link 4
        unless ($all) {
            if (($hb3 eq 'Y') && ($#$rsn>3)) {
                $hb4=$prod->ask_fourth_hb;
                return $hb4 if (EDR::getmsgkey($hb4,'back'));
            }
            if ($hb4 eq 'Y') {
                $hb = $prod->ask_hbnic_sys($sys,4,$rsn,$rpn,\@en);
                return $hb if (EDR::getmsgkey($hb,'back'));
                $hbn{lltlink4}{$sysi} = $en[4] = $hb;
                if ($padv->is_bonded_nic_sys($sys,$hb)){
                    push(@{$cfg->{$sysi}{bonded_nics}},$hb);
                }
            }
        }
        if ($hb4 eq 'Y') {
            $rtn = $prod->config_llt_rdma_sys($sys,\%hbn,\@en,$used_port,4,$rdmas);
            return $rtn if (EDR::getmsgkey($rtn,'back'));
            if ($rtn eq 'N') {
                pop @en;
                goto ASK_CFG_LINK4_AGAIN;
            }
        }
        if ($cfg->{lltoverudp} && ($hb4 eq 'Y')) {
            $ip = $prod->ask_nic_ip_sys($sys,$en[4],4,0,\%hbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            if ($ip eq 'N') {
                pop @en;
                goto ASK_CFG_LINK4_AGAIN;
            }
            $hbn{udplink4_address}{$sysi}=$ip->{address};
            $hbn{udplink4_netmask}{$sysi}=$ip->{netmask};
            if ($used_port->[4]) {
                $port = $used_port->[4];
                $msg=Msg::new("The UDP Port for this link: $port");
                $msg->printn;
                $hbn{udplink4_port}{$sysi} = $used_port->[4];
            } else {
                $udp_port = $prod->ask_udp_port_sys($sys,4,$used_port);
                return $udp_port if (EDR::getmsgkey($udp_port,'back'));
                $hbn{udplink4_port}{$sysi} = $used_port->[4] = $udp_port;
            }
        }

ASK_CFG_LINK_LOWPRI_AGAIN:
        # link lowpri
        unless ($all) {
            if ($hb2 eq 'Y') {
                $hbl = $prod->ask_lowpri_hb if ($cprod !~ /SFRAC\d+/m && $cprod !~ /SFSYBASECE\d+/m);
                return $hbl if (EDR::getmsgkey($hbl,'back'));
            } else {
                $hbl = 'Y' if ($hb2 eq 'N');
            }
            if ($hbl eq 'Y') {
                $rsn=$all_rsn;
                $hb = $prod->ask_hbnic_sys($sys,'lowpri',$rsn,$rpn,\@en);
                return $hb if (EDR::getmsgkey($hb,'back'));
                $hbn{lltlinklowpri1}{$sysi} = $en[$prod->{max_hipri_links}+1] = $hb;
                if ($padv->is_bonded_nic_sys($sys,$hb)){
                    push(@{$cfg->{$sysi}{bonded_nics}},$hb);
                }
            }
        }
        if ($hbl eq 'Y') {
            $rtn = $prod->config_llt_rdma_sys($sys,\%hbn,\@en,$used_port,$prod->{max_hipri_links}+1,$rdmas,1);
            return $rtn if (EDR::getmsgkey($rtn,'back'));
            if ($rtn eq 'N') {
                pop @en;
                goto ASK_CFG_LINK_LOWPRI_AGAIN;
            }
        }
        if ($cfg->{lltoverudp} && ($hbl eq 'Y')) {
            $ip = $prod->ask_nic_ip_sys($sys,$en[$prod->{max_hipri_links}+1],'lowpri',0,\%hbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            if ($ip eq 'N') {
                pop @en;
                goto ASK_CFG_LINK_LOWPRI_AGAIN;
            }
            $hbn{udplinklowpri1_address}{$sysi}=$ip->{address};
            $hbn{udplinklowpri1_netmask}{$sysi}=$ip->{netmask};
            if ($used_port->[$prod->{max_hipri_links}+1]) {
                $port = $used_port->[$prod->{max_hipri_links}+1];
                $msg=Msg::new("The UDP Port for this link: $port");
                $msg->printn;
                $hbn{udplinklowpri1_port}{$sysi} = $used_port->[$prod->{max_hipri_links}+1];
            } else {
                $udp_port = $prod->ask_udp_port_sys($sys,'lowpri',$used_port);
                return $udp_port if (EDR::getmsgkey($udp_port,'back'));
                $hbn{udplinklowpri1_port}{$sysi} = $used_port->[$prod->{max_hipri_links}+1] = $udp_port;
            }
        }

        if ($sys == ${CPIC::get('systems')}[0] && $#{CPIC::get('systems')} > 0 && !$all) {
            $ayn = $prod->ask_common_nics;
            return $ayn if (EDR::getmsgkey($ayn,'back'));
            $all = 1 if ($ayn eq 'Y');
        }
    }
    return \%hbn;
}

sub config_llt_rdma_sys {
    my ($prod,$sys,$hbn,$ens,$used_port,$id,$rdmas,$lowid) = @_;
    my ($ip,$msg,$rtn,$sysi,$port,$addrkey,$maskkey,$portkey,$udp_port,$rdmaudp);

    return '' unless $prod->{llt_rdma};
    return '' if (defined $rdmas->[$id]) && ($rdmas->[$id] == 0);
    my $rdmatag = 'rdma';
    my $rdmastr = 'RDMA';

    $sysi = $sys->{sys};
    if ($lowid) {
        $addrkey = "rdmalinklowpri${lowid}_address";
        $maskkey = "rdmalinklowpri${lowid}_netmask";
        $portkey = "rdmalinklowpri${lowid}_port";
        $rdmaudp = "rdmalinklowpri${lowid}_udp";
    } else {
        $addrkey = "rdmalink${id}_address";
        $maskkey = "rdmalink${id}_netmask";
        $portkey = "rdmalink${id}_port";
    }

    if (!defined $rdmas->[$id] && $lowid) {
        $msg=Msg::new("Input 'y' to go on configuring the RDMA link, input 'n' for the UDP link");
        $rtn=$msg->ayny('','b');
        return $rtn if (EDR::getmsgkey($rtn,'back'));
        unless ($rtn eq 'Y') {
            $rdmas->[$id] = 0;
            $rdmatag = '';
            $rdmastr = 'UDP';
            $hbn->{$rdmaudp}{$sysi} = 1;
        } else {
            if (!$sys->is_nic_rdma_capable($ens->[$id])) {
                Msg::n();
                $msg = Msg::new("$ens->[$id] is not a NIC support RDMA. Configure VCS again.");
                $msg->bold();
                Msg::prtc();
                return '__back__';
            }
        }
    }

    if (defined $hbn->{$rdmaudp}) {
        $rdmatag = '';
        $rdmastr = 'UDP';
        $hbn->{$rdmaudp}{$sysi} = 1;
    }

    $rdmas->[$id] = 1;
    $ip = $lowid ? $prod->ask_nic_ip_sys($sys,$ens->[$id],'lowpri',$rdmatag,$hbn)
                 : $prod->ask_nic_ip_sys($sys,$ens->[$id],$id,$rdmatag,$hbn);
    return $ip if (EDR::getmsgkey($ip,'back') || $ip eq 'N');
    $hbn->{$addrkey}{$sysi}=$ip->{address};
    $hbn->{$maskkey}{$sysi}=$ip->{netmask};
    if ($used_port->[$id]) {
        $port = $used_port->[$id];
        $msg=Msg::new("The $rdmastr Port for this link: $port");
        $msg->print;
        $hbn->{$portkey}{$sysi} = $used_port->[$id];
    } else {
        $udp_port = $lowid ? $prod->ask_udp_port_sys($sys,'lowpri',$used_port,$rdmatag)
                           : $prod->ask_udp_port_sys($sys,$id,$used_port,$rdmatag);
        return $udp_port if (EDR::getmsgkey($udp_port,'back'));
        $hbn->{$portkey}{$sysi} = $used_port->[$id] = $udp_port;
    }
    return '';
}

# $active_nics (for Linux only, ignored on other Plats):
#  0 do not active NICs
#  1 active/deactive NICs
sub autocfg_hbnics {
    my ($prod,$active_nics) = @_;
    my ($speed_value,$n_lowpri,$sysi,$dev_dir,$last_sap,$key_high,$msg,$cprod,$a1,$sys0,$gatewaynics_sys0,$rnics,$dlpi,$sys,@sorted_resultfiles,$localsys,$n,$padv,$nic,$mac,$used_nics,$link_index,$non_nic_num,$link_num,$link,$cmd_out,@resultfiles,$n_hipri,$rhbn,$all_connected,$key_low,$retry_count,%sap_mac,$max_links,$b1,$dev_n,$selected_speed,$nic_num,$n0,$dev_l,$connected_nic,$cmd,$rpids,@sorted_links_index,$connected_nics,$tmpdir,$sysi0,$sap,$dev);
    my $rootpath = Cfg::opt('rootpath');
    $cprod=CPIC::get('prod');

    Msg::title();
    my $edr = Obj::edr();
    $edr->set_progress_steps(2+@{CPIC::get('systems')});
    my $stage = Msg::new("Configuring LLT links");
    $stage->display_bold($stage) if (Cfg::opt(qw(redirect)));

    #get system nics on all systems.
    #create temp dir on all nodes and copy dlpiping binary into it.
    #so all dlpiping processes started by CPI could be identified by dirname.
    $localsys=EDR::get('localsys');
    $tmpdir = EDR::tmpdir().'/dlpitest_'.$localsys->{sys}.'_'.$$;

    for my $sys (@{CPIC::get('systems')}) {
        $sysi = $sys->{sys};
        $padv = $sys->padv;
        if (!$sys->exists($rootpath.'/opt/VRTSllt/dlpiping')) {
            Msg::log("$rootpath/opt/VRTSllt/dlpiping command was not found on $sysi. VRTSllt package was not installed successfully.");
        }
        $rnics->{$sysi} = $padv->systemnics_sys($sys,1);
        $cmd = "_cmd_rmr $tmpdir >/dev/null 2>&1 ;";
        $cmd .= "_cmd_mkdir -p $tmpdir >/dev/null 2>&1 ;";
        $cmd .= "_cmd_cp $rootpath/opt/VRTSllt/dlpiping $tmpdir/dlpiping_cpi >/dev/null 2>&1 ";
        $sys->cmd($cmd);
        # on AIX, load dlpi if it has not been loaded yet.
        if ($sys->aix()) {
            $dlpi=$sys->cmd("_cmd_strload -q -d /usr/lib/drivers/pse/dlpi 2>/dev/null | _cmd_awk '{print \$2}'");
            chomp($dlpi);
            if ($dlpi eq 'no') {
                $sys->cmd('_cmd_strload -f /etc/dlpi.conf');
            }
        }
    }

    # start dlpiping_cpi -s in background for each NIC on the first sys.
    $sys = CPIC::get('systems')->[0];
    $rpids = $sys->proc_pids('dlpiping_cpi');
    if (scalar @$rpids > 0) {
        $cmd = '_cmd_kill -s 9 '. join (' ', @$rpids) . '  ';
        $sys->cmd($cmd);
    }
    $sysi = $sys->{sys};
    $msg = Msg::new("Checking system NICs on $sysi");
    $stage->display_left($msg);
    $last_sap = 52000; # 52000 is magical initial sap value for dlpiping test.
    if (!$sys->linux()) {
        if ($sys->aix()) {
            $dev_dir = '/dev/dlpi';
        } else {
            $dev_dir = '/dev';
        }
    }
    Msg::log("Found NICs on $sysi: @{$rnics->{$sysi}}");
    $non_nic_num = 0;
    $cmd = "cd $tmpdir ";
    for my $n (0..$#{$rnics->{$sysi}}) {
        $nic = $rnics->{$sysi}->[$n];
        $last_sap++;
        if ($nic =~ /sit\d+/m || $nic =~ /vsw\d+/m){ # skip sit# on Linux, vsw# on Solaris
            $non_nic_num++;
            $sap_mac{$last_sap} = '00:00:00:00:00:00';
        } else {
            if ($sys->linux()) {
                $dev = $nic;
                $mac=$sys->cmd("_cmd_ifconfig '$nic' 2>/dev/null | _cmd_grep 'HWaddr'");
                if ($mac=~/HWaddr\s+([0-9A-Fa-f:]+)[\s\n\$]/x) {
                    $mac=$1;
                } else {
                    Msg::log("Failed get MAC address of $dev on $sysi.");
                    $mac='FF:FF:FF:FF:FF:FF';
                }
            } else {
                if ($sys->{padv} =~ /^Sol11/m) {
                    $dev = "/dev/net/$nic";
                } elsif ( $nic =~ /^(.*[A-Za-z])(\d+)$/mx) {
                    $dev = "$dev_dir/$1:$2";
                } else {
                    $dev = "$dev_dir/$nic";
                }
                $mac=$sys->cmd("$rootpath/opt/VRTSllt/getmac $dev 2>/dev/null | _cmd_grep '$dev'");
                $mac =~ s/^\s*//m; #remove leading spaces if any.
                (undef, $mac) = split /\s/m, $mac;
                chomp $mac;
            }
            if ($mac) {
                $sap_mac{$last_sap} = $mac;
            } else {
                Msg::log("Failed get MAC address of $dev on $sysi.");
                $sap_mac{$last_sap} = 'FF:FF:FF:FF:FF:FF';
            }
            $cmd .= " ; (./dlpiping_cpi -s -v -d $last_sap $dev >/dev/null 2>&1 &) ";
            if (length($cmd) > 1024) {
                $sys->cmd($cmd);
                $cmd = "cd $tmpdir ";
            }
        }
    }
    $sys->cmd($cmd);
    $nic_num = $#{$rnics->{$sysi}} + 1 - $non_nic_num;
    if ( $nic_num <= 1 ) {
        $msg=Msg::new("$nic_num NIC found");
    } else {
        $msg=Msg::new("$nic_num NICs found");
    }
    $stage->display_right($msg);

    # try dlpiping_cpi -c for all nics on all other nodes
    for my $sys (@{CPIC::get('systems')}) {
        next if ($sys->system1);
        $sysi = $sys->{sys};
        $msg = Msg::new("Checking system NICs on $sysi");
        $stage->display_left($msg);
        Msg::log("Found NICs on $sysi: @{$rnics->{$sysi}}");
        $cmd = "cd $tmpdir ";
        $non_nic_num = 0;
        for my $n (0..$#{$rnics->{$sysi}}) {
            $nic = $rnics->{$sysi}->[$n];
            if ($nic =~ /sit\d+/m || $nic =~ /vsw\d+/m){ # skip sit# on Linux, vsw# on Solaris
                $non_nic_num++;
            } else {
                if ($sys->linux()) {
                    $dev = $nic;
                } else {
                    $dev_l=$dev_n=$nic;
                    $dev_l=~s/(.*[A-Za-z])\d*/$1/mxg;
                    $dev_n=~s/.*[A-Za-z](\d*)$/$1/mxg;
                    $dev = "$dev_dir/$dev_l:$dev_n";
                    if ($sys->{padv} =~ /^Sol11/m) {
                        $dev = "/dev/net/$nic";
                    } elsif ( $nic =~ /^(.*[A-Za-z])(\d+)$/mx) {
                        $dev = "$dev_dir/$1:$2";
                    } else {
                        $dev = "$dev_dir/$nic";
                    }
                    # make sure this NIC is detected.
                    $sys->cmd("$rootpath/opt/VRTSllt/getmac $dev");
                }
                for my $sap (52001..$last_sap) {
                    $n0 = $sap-52001;
                    $cmd .= " ; (./dlpiping_cpi -c -t 10 -d $sap $dev $sap_mac{$sap} > result-$n".'-'."$n0".'- 2>&1 &) ';
                    if (length($cmd) > 1024) {
                        $sys->cmd($cmd);
                        $cmd = "cd $tmpdir ";
                    }
                }
            }
        }
        $sys->cmd($cmd);
        sleep 3;
        $rpids = $sys->proc_pids('dlpiping_cpi');
        $retry_count = 10;
        while (scalar @$rpids > 0 && $retry_count > 0) {
            sleep 3;
            $retry_count--;
            $rpids = $sys->proc_pids('dlpiping_cpi');
        }
        $nic_num = $#{$rnics->{$sysi}} + 1 - $non_nic_num;
        if ( $nic_num <= 1 ) {
            $msg=Msg::new("$nic_num NIC found");
        } else {
            $msg=Msg::new("$nic_num NICs found");
        }
        $stage->display_right($msg);
    }


    # sleep a while and check result files.
    for my $sys (@{CPIC::get('systems')}) {
        $sysi = $sys->{sys};
        next if ($sys->system1);
        # get content of each result file for debugging
        $sys->cmd("echo result_files ; for i in `_cmd_ls $tmpdir/result-*`;do echo \$i;_cmd_cat \$i;done 2>/dev/null");
        $cmd_out = $sys->cmd("_cmd_grep -l 'is alive' $tmpdir/result-* 2>/dev/null");
        @resultfiles = split /\n/, $cmd_out;
        @sorted_resultfiles = sort {
            $a1 = $a;
            $a1 =~ s/.*result-(\d+)-.*/$1/mx;
            $b1 = $b;
            $b1 =~ s/.*result-(\d+)-.*/$1/mx;
            $a1 <=> $b1;
        } @resultfiles;
        $connected_nics->{$sysi} = \@sorted_resultfiles;
        Msg::log("Found connected links on $sysi: @sorted_resultfiles");
    }

    # Cleanup...
    for my $sys (@{CPIC::get('systems')}) {
        $rpids = $sys->proc_pids('dlpiping_cpi');
        $cmd = '';
        if (scalar @$rpids > 0) {
            $cmd .= '_cmd_kill -s 9 '. join (' ', @$rpids) . ' ; ';
        }
        $cmd .= "_cmd_rmr $tmpdir >/dev/null 2>&1 ";
        $sys->cmd($cmd);
    }

    $msg = Msg::new("Checking network links");
    $stage->display_left($msg);

    # parse results and create $rhbn
    $sys0 = CPIC::get('systems')->[0];
    $sysi0 = $sys0->{sys};
    $link_num = 0;
    for my $n (0..$#{$rnics->{$sysi0}}) {
        $link->{$sysi0} = $n;
        $all_connected = 1;
        for my $sys (@{CPIC::get('systems')}) {
            next if ($sys->system1);
            $sysi = $sys->{sys};
            $all_connected = 0;
            for my $connected_nic (@{$connected_nics->{$sysi}}) {
                if ( $connected_nic =~ /result-(\d+)-$n-/mx) {
                    if (!EDRu::inarr($1, @{$used_nics->{$sysi}})) {
                        $all_connected = 1;
                        $link->{$sysi} = $1;
                        last;
                    }
                }
            }
            if (!$all_connected) {
                last;
            }
        }

        if ($all_connected) {
            $link_num++;
            for my $sys (@{CPIC::get('systems')}) {
                $sysi = $sys->{sys};
                $rhbn->{"link$link_num"}{$sysi} = $rnics->{$sysi}->[$link->{$sysi}];
                push @{$used_nics->{$sysi}}, $link->{$sysi};

                $key_high = "link$link_num".'_high';
                $key_low = "link$link_num".'_low';
                $selected_speed = $sys->padv->nic_speed_sys($sys,$rhbn->{"link$link_num"}{$sysi});

                if ($selected_speed =~ /\D*(\d+\.?\d*)\s*[Gg]/mx) {
                    $speed_value = $1;
                    $speed_value *= 1000;
                } elsif ($selected_speed =~ /\D*(\d+\.?\d*)\D*/mx) {
                    $speed_value = $1;
                } else {
                    $speed_value = 0;
                }
                if ( ! defined($rhbn->{$key_high})) {
                    $rhbn->{$key_high} = $speed_value;
                } elsif ( $rhbn->{$key_high} < $speed_value ) {
                    $rhbn->{$key_high} = $speed_value;
                }
                if ( !defined($rhbn->{$key_low})) {
                    $rhbn->{$key_low} = $speed_value;
                } elsif ( $rhbn->{$key_low} > $speed_value ) {
                    $rhbn->{$key_low} = $speed_value;
                }
            }
        }
    }
    if ( $link_num == 1) {
        $msg=Msg::new("1 link found");
        $stage->display_right($msg);
    } else {
        $msg=Msg::new("$link_num links found");
        $stage->display_right($msg);
    }

    # sort links from high speed to low.
    @sorted_links_index= sort {
        $a1 = $rhbn->{"link$a".'_low'};
        $b1 = $rhbn->{"link$b".'_low'};
        if ($b1>$a1) {
            return 1;
        } elsif ($b1 == $a1) {
            return ($a<$b)?-1:1;
        } else {
            return -1;
        }
    } (1..$link_num);

    $msg = Msg::new("Setting link priority");
    $stage->display_left($msg);

    # set priority of connected links.
    $n_hipri = 1;
    $n_lowpri = 1;
    $n = 0;
    $gatewaynics_sys0 = $sys0->padv->gatewaynics_sys($sys0);
    $max_links = $prod->{max_lltlinks} > $link_num ? $link_num : $prod->{max_lltlinks};
    while (($n<$link_num)&&($n_hipri + $n_lowpri < $prod->{max_lltlinks} + 2)) {
        $link_index=$sorted_links_index[$n];
        if (($cprod =~ /SFRAC\d+/m || $cprod =~ /SFSYBASECE\d+/m) && EDRu::inarr($rhbn->{"link$link_index"}{$sysi0},@{$gatewaynics_sys0})) {
            # Do not use public NICs as heartbeat links for SFRAC
            Msg::log('Ignore public link over '.$rhbn->{"link$link_index"}{$sysi0}." on $sysi0 for SFRAC product");
        } elsif ($n_hipri>$prod->{max_hipri_links} || EDRu::inarr($rhbn->{"link$link_index"}{$sysi0},@{$gatewaynics_sys0})) {
            # set lowpri if already had enough hipri ones, or, the NICs are connected to public network through gateway.
            for my $sys (@{CPIC::get('systems')}) {
                $sysi = $sys->{sys};
                $rhbn->{"lltlinklowpri$n_lowpri"}{$sysi} = $rhbn->{"link$link_index"}{$sysi};
            }
            $rhbn->{"lltlinklowpri$n_lowpri".'_low'} = $rhbn->{"link$link_index".'_low'};
            $rhbn->{"lltlinklowpri$n_lowpri".'_high'} = $rhbn->{"link$link_index".'_high'};
            $n_lowpri++;
        } else {
            for my $sys (@{CPIC::get('systems')}) {
                $sysi = $sys->{sys};
                $rhbn->{"lltlink$n_hipri"}{$sysi} = $rhbn->{"link$link_index"}{$sysi};
            }
            $rhbn->{"lltlink$n_hipri".'_low'} = $rhbn->{"link$link_index".'_low'};
            $rhbn->{"lltlink$n_hipri".'_high'} = $rhbn->{"link$link_index".'_high'};
            $n_hipri++;
        }
        $n++;
    }
    $rhbn = $prod->set_lowpri_for_slow_links($rhbn);
    if ( $link_num < 1) {
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
    } else {
        if ( $n_hipri == 1) {
            $msg = Msg::new("No high priority links found");
            $stage->display_right($msg);
        } else {
            $stage->display_right();
        }
    }
    Msg::n();
    sleep(3);
    return $rhbn;
}

#####################################
# Args:
#  $prod - Prod object
#  $sys  - Sys object
#  $rhbn - Reference to Heartbeat NICs hash for all systems
#  $rsns - Reference to system NICs hash for all systems
#  $rpns - Reference to public NICs hash for all systems
#  $min_hipri_links - Minimum number of hi-pri links required
#  $max_links - Maximum number of heartbeat links supported
#  $is_first_node - Whether this is the first node in cluster. The numbers of hipri/lowpri links are determined on the first node.
#     0 - no
#     1 - yes
#  $ask_for_nic_names - Whether ask user for the NIC names for each link. Alwasys ask for nic names on the first node.
#     0 - do not ask
#     1 - ask
#    -1 - do not ask anyway.
#  $is_udp - Whether it is an LLT link over UDP
#     0 - no
#     1 - yes
#     2 - ask. Used for mix configuration of LLT over UDP and LLT over Ethernet (future development).
#  $sysi0 - the name of the first node in cluster, used to retrieving its configuration info.
#  $no_lowpri_links - do not configure Low-Priority links. For SFRAC.
######################################
sub ask_hbnics_sys {
    my ($prod, $sys, $rhbn, $rsns, $rpns, $min_hipri_links, $max_links, $is_first_node, $ask_for_nic_names, $is_udp, $sysi0, $no_lowpri_links) = @_;
    my ($ask_nic,$cfg,$sysi,$padv,@configured_nics,@configured_udp_ports,$backopt,$help,$ip,$msg,$n,$nic,$port,$ayn,$selected_nic,$default_nic,$en,$pn,$sn,$dsn,$link,$min_lowpri_links,$udp);
    my ($addrkey,$maskkey,$portkey);
    $cfg = Obj::cfg();
    my $oldsys = Obj::sys(${$cfg->{clustersystems}}[0]);
    my $oldsysi = $oldsys->{sys};

    $sysi = $sys->{sys};
    $padv = $sys->padv;
    if ($ask_for_nic_names) {
        Msg::n();
        $msg=Msg::new("Discovering NICs on $sysi");
        $msg->left;
        $dsn=join(' ',@{$rsns->{$sysi}});
        if ($#{$rsns->{$sysi}}<0) {
            $msg=Msg::new("No NICs discovered");
            $msg->right;
        } else {
            $msg=Msg::new("Discovered $dsn");
            $msg->right;
            #$msg=Msg::new("\nTo use aggregated interfaces for private heartbeat, enter the name of an aggregated interface. \nTo use a NIC for private heartbeat, enter a NIC which is not part of an aggregated interface.\n");
            #$msg->print;
        }
        Msg::n();
    }

    #ask for hipri nics
    for my $link (1..$max_links) {
        if ($link > $min_hipri_links && $link > $prod->{max_hipri_links}) {
            last;
        }
        if ($is_first_node && $link>$min_hipri_links) {
            $ayn = $prod->ask_nth_hb($link);
            return $ayn if (EDR::getmsgkey($ayn,'back'));
            last if ($ayn ne 'Y');
        }
        if ((!$is_first_node) && $link>$prod->num_hbnics($rhbn)) {
            last;
        }

        #ask for nic name
        $ask_nic = 0;
        if ( $is_first_node ) {
            $ask_nic = 1;
            $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
        } elsif ($ask_for_nic_names > 0) {
            $ask_nic = 1;
            $default_nic = $rhbn->{"lltlink$link"}{$sysi0};
            if (!EDRu::inarr($default_nic,@{$rsns->{$sysi}})) {
                $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
            }
        } elsif ($ask_for_nic_names < 0) {
            $ask_nic = 0;
            $selected_nic = $rhbn->{"lltlink$link"}{$sysi0};
        } elsif (!EDRu::inarr($rhbn->{"lltlink$link"}{$sysi0},@{$rsns->{$sysi}})) {
            $ask_nic = 1;
            $default_nic = $rhbn->{"lltlink$link"}{$sysi0};
            $msg=Msg::new("$default_nic was specified for this private heartbeat link on $sysi0, but it is not a NIC discovered on $sysi");
            $msg->print;
            Msg::n();
            $msg=Msg::new("Discovering NICs on $sysi");
            $msg->left;
            $dsn=join(' ',@{$rsns->{$sysi}});
            if ($#{$rsns->{$sysi}}<0) {
                $msg=Msg::new("No NICs discovered");
                $msg->right;
            } else {
                $msg=Msg::new("Discovered $dsn");
                $msg->right;
                #$msg=Msg::new("\nTo use aggregated interfaces for private heartbeat, enter the name of an aggregated interface. \nTo use a NIC for private heartbeat, enter a NIC which is not part of an aggregated interface.\n");
                #$msg->print;
            }
            Msg::n();
            $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
        } elsif (EDRu::inarr($rhbn->{"lltlink$link"}{$sysi0},@configured_nics)) {
            $ask_nic = 1;
            $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
            $n = EDRu::arrpos($rhbn->{"lltlink$link"}{$sysi0}, @configured_nics);
            $nic = $rhbn->{"lltlink$link"}{$sysi0};
            $msg=Msg::new("$nic is already being used for another private heartbeat link");
            $msg->print;
        } else {
            $ask_nic = 0;
            $selected_nic = $rhbn->{"lltlink$link"}{$sysi0};
        }

        $addrkey = "rdmalink${link}_address";
        $maskkey = "rdmalink${link}_netmask";
        $portkey = "rdmalink${link}_port";

ASK_CFG_LINK_AGAIN_WHEN_ADD_NODE:
        if ( $ask_nic ) {
            my $rdma_tag = defined $rhbn->{$addrkey} ? 1 : 0;
            $selected_nic = $prod->ask_hbnic_sys($sys,$link,$rsns->{$sysi},$rpns->{$sysi},\@configured_nics,$default_nic,$rdma_tag);
            return $selected_nic if (EDR::getmsgkey($selected_nic,'back'));
        }
        $rhbn->{"lltlink$link"}{$sysi} = $selected_nic;
        $configured_nics[$link] = $selected_nic;

        # use udp for this link?
        $udp = 0;
        if ( $is_udp == 1) {
            $udp = 1;
        } elsif ( $is_udp == 2) {
            if ( $is_first_node) {
                $backopt = 1;
                $msg=Msg::new("Do you want to configure this private heartbeat link over UDP?");
                $help = Msg::new("Configuring heartbeat link using LLT over Ethernet is the recommended option.\nLLT over UDP is slower than LLT over Ethernet. Use LLT over UDP only when the hardware configuration makes it necessary");
                $ayn=$msg->aynn($help,$backopt);
                return $ayn if (EDR::getmsgkey($ayn,'back'));
                $udp = 1 if ($ayn eq 'Y');
            }
            else {
                $udp = 1 if ($rhbn->{"lltlink$link".'_udp'});
            }
        }
        # ask for udp information.
        if ($udp) {
            $rhbn->{"lltlink$link".'_udp'} = 1;
            # ask for IP address
            $ip = $prod->ask_nic_ip_sys($sys,$rhbn->{"lltlink$link"}{$sysi},$link,0,$rhbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            if ($ip eq 'N') {
              pop @configured_nics;
              goto ASK_CFG_LINK_AGAIN_WHEN_ADD_NODE;
            }
            $rhbn->{"udplink$link".'_address'}{$sysi} = $ip->{address};
            $rhbn->{"udplink$link".'_netmask'}{$sysi} = $ip->{netmask};
            # ask for port on the first node only
            if ($is_first_node) {
                $port = $prod->ask_udp_port_sys($sys,$link,\@configured_udp_ports);
                return $port if (EDR::getmsgkey($port,'back'));
                $rhbn->{"udplink$link".'_port'}{$sysi} = $port;
                push(@configured_udp_ports, $port);
            } else {
                $port = $rhbn->{"udplink$link".'_port'}{$sysi0};
                $msg=Msg::new("The UDP Port for this link: $port");
                $msg->printn;
                $rhbn->{"udplink$link".'_port'}{$sysi} = $rhbn->{"udplink$link".'_port'}{$sysi0};
            }
        } elsif (defined $rhbn->{$addrkey}) {
            $ip = $prod->ask_nic_ip_sys($sys,$rhbn->{"lltlink$link"}{$sysi},$link,'rdma',$rhbn);
            return $ip if (EDR::getmsgkey($ip,'back'));
            if ($ip eq 'N') {
              pop @configured_nics;
              goto ASK_CFG_LINK_AGAIN_WHEN_ADD_NODE;
            }
            $rhbn->{$addrkey}{$sysi}=$ip->{address};
            $rhbn->{$maskkey}{$sysi}=$ip->{netmask};
            if ($is_first_node) {
                $port = $prod->ask_udp_port_sys($sys,$link,\@configured_udp_ports,'rdma',$rhbn);
                return $port if (EDR::getmsgkey($port,'back'));
                $rhbn->{$portkey}{$sysi} = $port;
                push(@configured_udp_ports, $port);
            } else {
                $port = $rhbn->{$portkey}{$sysi0};
                $msg=Msg::new("The RDMA Port for this link: $port");
                $msg->print;
                $rhbn->{$portkey}{$sysi} = $rhbn->{$portkey}{$sysi0};
            }
        }
    }

    if (!$no_lowpri_links) {
        # At least one lowpri link is required if:
        #   a) Only one hipri link is configured and,
        #   b) vxfen is not enabled.
        # Else lowpri links are optional.
        if ( $prod->num_hbnics($rhbn) == 1 && !$cfg->{fencingenabled} ) {
            $min_lowpri_links = 1;
        } else {
            $min_lowpri_links = 0;
        }

        #ask for lowpri nics
        for my $link (1..$max_links-$prod->num_hbnics($rhbn)) {
            if ($is_first_node && $link > $min_lowpri_links) {
                $ayn = $prod->ask_lowpri_hb($link);
                return $ayn if (EDR::getmsgkey($ayn,'back'));
                last if ($ayn ne 'Y');
            }
            if ((!$is_first_node) && $link>$prod->num_lopri_hbnics($rhbn)) {
                last;
            }
            #ask for nic name
            $ask_nic = 0;
            if ( $is_first_node ) {
                $ask_nic = 1;
                $default_nic = undef;
                for my $item (@{$rpns->{$sysi}} ) {
                    if (EDRu::inarr($item, @configured_nics)) {
                        next;
                    } else {
                        $default_nic = $item;
                        last;
                    }
                }
                if ( ! $default_nic) {
                    $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
                }
            } elsif ($ask_for_nic_names > 0) {
                $ask_nic = 1;
                $default_nic = $rhbn->{"lltlinklowpri$link"}{$sysi0};
                if (!EDRu::inarr($default_nic,@{$rsns->{$sysi}})) {
                    $default_nic = undef;
                    for my $item (@{$rpns->{$sysi}} ) {
                        if (EDRu::inarr($item, @configured_nics)) {
                            next;
                        } else {
                            $default_nic = $item;
                            last;
                        }
                    }
                    if ( ! $default_nic) {
                        $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
                    }
                }
            } elsif ($ask_for_nic_names < 0) {
                $ask_nic = 0;
                $selected_nic = $rhbn->{"lltlinklowpri$link"}{$sysi0};
            } elsif (!EDRu::inarr($rhbn->{"lltlinklowpri$link"}{$sysi0},@{$rsns->{$sysi}})) {
                $ask_nic = 1;
                $default_nic = $rhbn->{"lltlinklowpri$link"}{$sysi0};
                $msg=Msg::new("$default_nic was specified for this low-priority heartbeat link on $sysi0, but it is not a NIC discovered on $sysi");
                $msg->print;
                $msg=Msg::new("Discovering NICs on $sysi");
                $msg->left;
                $dsn=join(' ',@{$rsns->{$sysi}});
                if ($#{$rsns->{$sysi}}<0) {
                    $msg=Msg::new("No NICs discovered");
                    $msg->right;
                } else {
                    $msg=Msg::new("Discovered $dsn");
                    $msg->right;
                    #$msg=Msg::new("\nTo use aggregated interfaces for private heartbeat, enter the name of an aggregated interface. \nTo use a NIC for private heartbeat, enter a NIC which is not part of an aggregated interface.\n");
                    #$msg->print;
                }
                Msg::n();
                $default_nic = undef;
                for my $item (@{$rpns->{$sysi}} ) {
                    if (EDRu::inarr($item, @configured_nics)) {
                        next;
                    } else {
                        $default_nic = $item;
                        last;
                    }
                }
                if ( ! $default_nic) {
                    $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
                }
            } elsif (EDRu::inarr($rhbn->{"lltlinklowpri$link"}{$sysi0},@configured_nics)) {
                $ask_nic = 1;
                $n = EDRu::arrpos($rhbn->{"lltlinklowpri$link"}{$sysi0}, @configured_nics);
                $nic = $rhbn->{"lltlinklowpri$link"}{$sysi0};
                if ($n<=8) {
                    $msg=Msg::new("$nic is already being used for a private heartbeat link");
                } else {
                    $msg=Msg::new("$nic is already being used for another low-priority heartbeat link");
                }
                $msg->print;
                $default_nic = undef;
                for my $item (@{$rpns->{$sysi}} ) {
                    if (EDRu::inarr($item, @configured_nics)) {
                        next;
                    } else {
                        $default_nic = $item;
                        last;
                    }
                }
                if ( ! $default_nic) {
                    $default_nic = $prod->default_hbnic($rsns->{$sysi},$rpns->{$sysi},\@configured_nics);
                }
            } else {
                $ask_nic = 0;
                $selected_nic = $rhbn->{"lltlinklowpri$link"}{$sysi0};
            }

ASK_CFG_LINK_LOWPRI_AGAIN_WHEN_ADD_NODE:
            if ( $ask_nic ) {
                $selected_nic = $prod->ask_hbnic_sys($sys,"lowpri$link",$rsns->{$sysi},$rpns->{$sysi},\@configured_nics,$default_nic);
                return $selected_nic if (EDR::getmsgkey($selected_nic,'back'));
            }
            $rhbn->{"lltlinklowpri$link"}{$sysi} = $selected_nic;
            $configured_nics[$link+8] = $selected_nic;

            # use udp for this link?
            $udp = 0;
            if ( $is_udp == 1) {
                $udp = 1;
            } elsif ( $is_udp == 2) {
                if ( $is_first_node) {
                    $backopt = 1;
                    $msg=Msg::new("Do you want to configure this low-priority heartbeat link over UDP?");
                    $help = Msg::new("Configuring heartbeat link using LLT over Ethernet is the recommended option.\nLLT over UDP is slower than LLT over Ethernet. Use LLT over UDP only when the hardware configuration makes it necessary");
                    $ayn=$msg->aynn($help,$backopt);
                    return $ayn if (EDR::getmsgkey($ayn,'back'));
                    $udp = 1 if ($ayn eq 'Y');
                } else {
                    $udp = 1 if ($rhbn->{"lltlinklowpri$link".'_udp'});
                }
            }
            $addrkey = "rdmalinklowpri${link}_address";
            $maskkey = "rdmalinklowpri${link}_netmask";
            $portkey = "rdmalinklowpri${link}_port";
            my $rdmaudp = "rdmalinklowpri${link}_udp";
            # ask for udp information.
            if ($udp) {
                $rhbn->{"lltlinklowpri$link".'_udp'} = 1;
                # ask for IP address
                $ip = $prod->ask_nic_ip_sys($sys,$rhbn->{"lltlinklowpri$link"}{$sysi},"lowpri$link",0,$rhbn);
                return $ip if (EDR::getmsgkey($ip,'back'));
                if ($ip eq 'N') {
                    pop @configured_nics;
                    goto ASK_CFG_LINK_LOWPRI_AGAIN_WHEN_ADD_NODE;
                }
                $rhbn->{"udplinklowpri$link".'_address'}{$sysi} = $ip->{address};
                $rhbn->{"udplinklowpri$link".'_netmask'}{$sysi} = $ip->{netmask};

                # ask for port
                if ($is_first_node) {
                    $port = $prod->ask_udp_port_sys($sys,"lowpri$link",\@configured_udp_ports);
                    return $port if (EDR::getmsgkey($port,'back'));
                    $rhbn->{"udplinklowpri$link".'_port'}{$sysi} = $port;
                    push(@configured_udp_ports, $port);
                } else {
                    $port = $rhbn->{"udplinklowpri$link".'_port'}{$sysi0};
                    $msg=Msg::new("The UDP Port for this link: $port");
                    $msg->printn;
                    $rhbn->{"udplinklowpri$link".'_port'}{$sysi} = $rhbn->{"udplinklowpri$link".'_port'}{$sysi0};
                }
            } elsif (defined $rhbn->{$addrkey}) {
                my $rdmatag = (defined $rhbn->{$rdmaudp}) ? '' : 'rdma' ;
                my $rdmastr = (defined $rhbn->{$rdmaudp}) ? 'UDP' : 'RDMA' ;
                $ip = $prod->ask_nic_ip_sys($sys,$rhbn->{"lltlinklowpri$link"}{$sysi},"lowpri$link",$rdmatag,$rhbn);
                return $ip if (EDR::getmsgkey($ip,'back'));
                if ($ip eq 'N') {
                    pop @configured_nics;
                    goto ASK_CFG_LINK_LOWPRI_AGAIN_WHEN_ADD_NODE;
                }
                $rhbn->{$addrkey}{$sysi}=$ip->{address};
                $rhbn->{$maskkey}{$sysi}=$ip->{netmask};
                $rhbn->{$rdmaudp}{$sysi}=(defined $rhbn->{$rdmaudp}) ? 1 : 0;
                if ($is_first_node) {
                    $port = $prod->ask_udp_port_sys($sys,"lowpri$link",\@configured_udp_ports,$rdmatag);
                    return $port if (EDR::getmsgkey($port,'back'));
                    $rhbn->{$portkey}{$sysi} = $port;
                    push(@configured_udp_ports, $port);
                } else {
                    $port = $rhbn->{$portkey}{$sysi0};
                    $msg=Msg::new("The $rdmastr Port for this link: $port");
                    $msg->print;
                    $rhbn->{$portkey}{$sysi} = $rhbn->{$portkey}{$sysi0};
                }
            }
        }
    }

    return $rhbn;
}

# ask for all heartbeat links for added nodes
sub ask_hbnics_addnode {
    my ($prod,$rhbn,$sysi0)=@_;
    my($cfg,$padv,$sys,$sysi,$msg,$cprod);
    my ($all,$ayn,%hbn,@en,$dsn,$hb,$hb2,$hb3,$hb4,$hbl,$ip,$rpns,$rsns,$udp_port,$used_port,$min_nics,$min_nics_sys,$num_high,$num_low);
    my ($min_hipri_links, $max_links, $is_first_node, $ask_for_nic_names, $is_udp, $rdma_tag);
    return '' if (Cfg::opt('responsefile'));
    $cfg=Obj::cfg();
    $cprod=CPIC::get('prod');
    if ( ! $sysi0) {
        $sysi0 = ${$cfg->{clustersystems}}[0] if ($cfg->{clustersystems});
    }

    # get nics for all systems first in order to find out the maximum links could be setup
    $min_nics = -1;
    $rdma_tag = $prod->{llt_rdma} ? 1 : 0;
    for my $sys (@{CPIC::get('systems')}) {
        $sysi=$sys->{sys};
        $padv=$sys->padv;
        $rsns->{$sysi}=$padv->systemnics_sys($sys,1);
        $rsns->{$sysi}=$prod->rdmanics_sys($sys,$rsns->{$sysi}) if ($rdma_tag);
        $rpns->{$sysi}=$padv->gatewaynics_sys($sys);
        $rsns->{$sysi}=EDRu::arruniq(@{$rsns->{$sysi}});
        $rpns->{$sysi}=EDRu::arruniq(@{$rpns->{$sysi}});
        if ($min_nics < 0 || $min_nics > @{$rsns->{$sysi}}) {
            $min_nics = @{$rsns->{$sysi}};
            $min_nics_sys = $sysi;
        }
    }

    $msg = Msg::new("Each node to be added to the cluster should have the same LLT heartbeat configuration as the existing node(s).\n");
    $msg->bold();
    $num_high = $prod->num_hbnics($rhbn);
    $num_low = $prod->num_lopri_hbnics($rhbn);
    if ($num_low>0) {
        $msg = Msg::new("To connect to the existing node(s) properly, each new node is required to be configured with $num_high private and $num_low low-priority heartbeat links.");
    } else {
        $msg = Msg::new("To connect to the existing node(s) properly, each new node is required to be configured with $num_high private heartbeat link(s).");
    }
    $msg->bold();

    $min_hipri_links = 1;
    if ( $cprod =~ /(SFRAC|SVS|SFCFS)/mx) {
        $min_hipri_links = 2;
    }
    $max_links = $prod->{max_lltlinks};
    $is_first_node = 0;
    $ask_for_nic_names = 1;
    if ( $cfg->{lltoverudp} ) {
        $is_udp = 1;
    } else {
        $is_udp = 0;
    }

    for my $sys (@{CPIC::get('systems')}) {
        $sysi=$sys->{sys};
        if ($sys == ${CPIC::get('systems')}[0]){
            $ayn = $prod->ask_hbnics_sys($sys, $rhbn, $rsns,$rpns, $min_hipri_links, $max_links, $is_first_node, $ask_for_nic_names, $is_udp, $sysi0 );
            return $ayn if (EDR::getmsgkey($ayn,'back'));
            if ($#{CPIC::get('systems')} > 0 && $ask_for_nic_names) {
                $ayn = $prod->ask_common_nics;
                return $ayn if (EDR::getmsgkey($ayn,'back'));
                $ask_for_nic_names = 0 if ($ayn eq 'Y');
            }
        }else {
            $ayn = $prod->ask_hbnics_sys($sys, $rhbn, $rsns,$rpns, $min_hipri_links, $max_links, 0, $ask_for_nic_names, $is_udp, ${CPIC::get('systems')}[0]->{sys});
            return $ayn if (EDR::getmsgkey($ayn,'back'));
        }
    }
    return $rhbn;
}

# Return '__back__' to back to previous menu.
# Return 'N' to select another NIC
sub ask_nic_ip_sys {
    my ($prod,$sys,$nic,$id,$rdma,$rhbn) = @_;
    my ($sysi,$msg,%ip,$ips,$num_ips,$idx,$padv,$answer,$address,$netmask,$question,$help);
    my (@invalid_ips,$default_ip,$valid_ip,$is_ipv4,$subnet,$tmp_subnet,$next_id,$rtn,$linktype,$key,$sys_ip,@used_ips,$localsys);

    $padv = $sys->padv;
    $sysi = $sys->{sys};

    $ips=$padv->nic_ips_sys($sys,$nic);

    @invalid_ips=('0.0.0.0', '::');
    $ips=EDRu::arrdel($ips, @invalid_ips);

    if ($rdma) {
        # only display IPV4 address for RDMA links
        if (@$ips) {
            @$ips = grep { EDRu::ip_is_ipv4($_) } @$ips;
        }
        $help = Msg::new("Configuring a heartbeat link using LLT over RDMA requires a permanent IP address assigned to the selected heartbeat NIC");
    } else {
        $help = Msg::new("Configuring a heartbeat link using LLT over UDP requires a permanent IP address assigned to the selected heartbeat NIC");
    }

    $num_ips=scalar @$ips;
    if ($num_ips) {
        # if the NIC has IP addresses assigned, need select one for LLT configuration.
        $idx=0;
        while (1) {
            $address=$ips->[$idx];

            if ($id =~ /lowpri/m) {
                if ($id eq 'lowpri' || $id eq 'lowpri1') {
                    $question = Msg::new("Do you want to use the address $address for the low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri2') {
                    $question = Msg::new("Do you want to use the address $address for the second low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri3') {
                    $question = Msg::new("Do you want to use the address $address for the third low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri4') {
                    $question = Msg::new("Do you want to use the address $address for the fourth low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri5') {
                    $question = Msg::new("Do you want to use the address $address for the fifth low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri6') {
                    $question = Msg::new("Do you want to use the address $address for the sixth low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri7') {
                    $question = Msg::new("Do you want to use the address $address for the seventh low-priority heartbeat link on $sysi:");
                } elsif ($id eq 'lowpri8') {
                    $question = Msg::new("Do you want to use the address $address for the eighth low-priority heartbeat link on $sysi:");
                }
            }elsif ($id == 1) {
                $question = Msg::new("Do you want to use the address $address for the first private heartbeat link on $sysi:");
            } elsif ($id == 2) {
                $question = Msg::new("Do you want to use the address $address for the second private heartbeat link on $sysi:");
            } elsif ($id == 3) {
                $question = Msg::new("Do you want to use the address $address for the third private heartbeat link on $sysi:");
            } elsif ($id == 4) {
                $question = Msg::new("Do you want to use the address $address for the fourth private heartbeat link on $sysi:");
            } elsif ($id == 5) {
                $question = Msg::new("Do you want to use the address $address for the fifth private heartbeat link on $sysi:");
            } elsif ($id == 6) {
                $question = Msg::new("Do you want to use the address $address for the sixth private heartbeat link on $sysi:");
            } elsif ($id == 7) {
                $question = Msg::new("Do you want to use the address $address for the seventh private heartbeat link on $sysi:");
            } elsif ($id == 8) {
                $question = Msg::new("Do you want to use the address $address for the eighth private heartbeat link on $sysi:");
            }
            $answer = $question->ayny($help,1);
            return $answer if (EDR::getmsgkey($answer,'back'));
            if ($answer eq 'Y') {
                $netmask=$sys->defaultnetmask($address,$nic);
                $ip{address} = $address;
                $ip{netmask} = $netmask;
                return \%ip;
            } else {
                $idx=($idx+1) % $num_ips;
                last if ($idx==0);
            }
        }
    }

    # if no IP was assigned or not selected for the NIC, ask if assign one IP address for the NIC

    # Begin to assign a new IP for the NIC with policy: 192.168.<linkno+1>.<nodeid+1>
    # The NICs with same link id should be in same subnet

    # To get the assigned subnet and the next id for IP 4th field.
    $subnet='';
    $next_id=0;
    $default_ip='';

    $linktype='udplink';
    $linktype='rdmalink' if ($rdma);

    # To get default IP address
    if (defined $rhbn) {
        $key=$linktype.$id.'_address';
        if (defined $rhbn->{$key}) {
            # if the same link of previous system is already configured
            # try to get subnet of the same link of previous system
            for my $sys (keys %{$rhbn->{$key}}) {
                $sys_ip=$rhbn->{$key}{$sys};
                if (EDRu::ip_is_ipv4($sys_ip) &&
                    $sys_ip=~/^(.*)\.(\d+)\.(\d+)$/mx) {
                    $subnet||=$1. '.' . $2;
                    $next_id=$3 if ($3>$next_id);
                }
            }
            $next_id++;
            $default_ip=$subnet . '.' . $next_id if ($subnet);
        } else {
            # if the same link of previous system is not configured,
            # check if previous link is configured
            if ($id=~/^lowpri(\d+)/) {
                $key=$linktype.'lowpri'.($1-1).'_address';
            } elsif ($id=~/^\d+/) {
                $key=$linktype.($id-1).'_address';
            }
            if (defined $rhbn->{$key}) {
                # if previous link of previous or same system is already configured
                # try to get subnet of the previous link on the systems
                $tmp_subnet='';
                for my $sys (keys %{$rhbn->{$key}}) {
                    $sys_ip=$rhbn->{$key}{$sys};
                    if (EDRu::ip_is_ipv4($sys_ip) &&
                        $sys_ip=~/^(.*)\.(\d+)\.(\d+)$/mx) {
                        $tmp_subnet||=$1. '.' . ($2 + 1);
                        $next_id=$3 if ($sys eq $sysi);
                    }
                }
                $next_id||=1;
                $default_ip=$tmp_subnet . '.' . $next_id if ($tmp_subnet);
            }
        }
    }

    $default_ip||='192.168.1.1';

    Msg::n();
    while (1) {
        $question = Msg::new("Enter the IP address for the NIC $nic on $sysi:");
        $address = $question->ask($default_ip,$help,1);
        return $address if (EDR::getmsgkey($address,'back'));
        $valid_ip=1;
        $is_ipv4=EDRu::ip_is_ipv4($address);
        if ($rdma && !$is_ipv4) {
            $valid_ip=0;
        } elsif (!EDRu::isip($address)) {
            $valid_ip=0;
        }
        if (!$valid_ip) {
            # invalid IP
            $msg=Msg::new("$address is not a valid IP address. Re-enter value");
            $msg->warning;
        } else {
            # valid IP
            if ($is_ipv4) {
                # Check if same subnet
                if ($subnet && $address!~/^$subnet\./) {
                    $msg=Msg::new("The IP address $address for the NIC $nic on $sysi is not the subnet $subnet which was configured for the same link of other systems. Re-enter value");
                    $msg->warning;
                    next;
                }
            }

            # Check if the IP is used or ever configured

            # push used IPs
            @used_ips=();
            $idx=1;
            while ($idx<9) {
                $key=$linktype.$idx.'_address';
                if (defined $rhbn->{$key}) {
                    for my $sys (keys %{$rhbn->{$key}}) {
                        $sys_ip=$rhbn->{$key}{$sys};
                        push @used_ips, $sys_ip if (defined $sys_ip);
                    }
                }

                # add lowpri IPs
                $key=$linktype.'lowpri'.$idx.'_address';
                if (defined $rhbn->{$key}) {
                    for my $sys (keys %{$rhbn->{$key}}) {
                        $sys_ip=$rhbn->{$key}{$sys};
                        push @used_ips, $sys_ip if (defined $sys_ip);
                    }
                }
                $idx++;
            }
            if (EDRu::inarr($address, @used_ips)) {
                $msg=Msg::new("The IP address $address for the NIC $nic on $sysi is already configured. Re-enter value");
                $msg->warning;
                next;
            }

            $rtn=1;
            $netmask=$sys->defaultnetmask($address,$nic);

            if (!EDRu::inarr($address, @{$ips})) {
                # if the address is not configured with the current NIC
                $localsys=$prod->localsys;
                if ($localsys->padv->ping($address)) {
                    # if the IP is not used by other systems or other NICs 
                    # then configure the IP as static IP.
                    $rtn=$padv->configure_static_ip_sys($sys,$nic,$address,$netmask);
                } else {
                    $msg=Msg::new("The IP address $address for the NIC $nic on $sysi is already used. Re-enter value");
                    $msg->warning;
                    next;
                }
            }

            if ($rtn) {
                $ip{address} = $address;
                $ip{netmask} = $netmask;
                return \%ip;
            } else {
                # fail to configure the static IP.
                $msg=Msg::new("Failed to configure the IP address for the NIC $nic on $sysi. Resolve the issue manually and try again");
                $msg->warning;
            }
        }
    }
    return;
}

sub ask_udp_port_sys {
    my ($prod,$sys,$id,$used_port,$rdma) = @_;
    my ($sysi,$def_port,$msg,$port,$question,$help,$udp,$strrdma);
    $sysi = $sys->{sys};
    $udp = $rdma ? '' : ' UDP';
    $strrdma = $rdma ? ' (RDMA)' : '';
    $help = Msg::new("Input an available 16-bit integer from the following range:\n  Use available ports in the private range 49152 to 65535.\n  Do not use the following ports:\n    Ports from the range of well-known ports, 0 to 1023.\n    Ports from the range of registered ports, 1024 to 49151.\nYou can use the netstat command to list the $udp ports currently in use.");
    if ($id =~ /lowpri/m) {
        if ($id eq 'lowpri' || $id eq 'lowpri1') {
            $question = Msg::new("Enter the$udp port for the low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50010'; # for capability, will be increased automatically if it has been used.
        } elsif ($id eq 'lowpri2') {
            $question = Msg::new("Enter the$udp port for the second low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50011';
        } elsif ($id eq 'lowpri3') {
            $question = Msg::new("Enter the$udp port for the third low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50012';
        } elsif ($id eq 'lowpri4') {
            $question = Msg::new("Enter the$udp port for the fourth low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50013';
        } elsif ($id eq 'lowpri5') {
            $question = Msg::new("Enter the$udp port for the fifth low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50014';
        } elsif ($id eq 'lowpri6') {
            $question = Msg::new("Enter the$udp port for the sixth low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50015';
        } elsif ($id eq 'lowpri7') {
            $question = Msg::new("Enter the$udp port for the seventh low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50016';
        } elsif ($id eq 'lowpri8') {
            $question = Msg::new("Enter the$udp port for the eighth low-priority heartbeat link$strrdma on $sysi:");
            $def_port = '50017';
        }
    } elsif ($id == 1) {
        $question = Msg::new("Enter the$udp port for the first private heartbeat link$strrdma on $sysi:");
        $def_port = '50000';
    } elsif ($id == 2) {
        $question = Msg::new("Enter the$udp port for the second private heartbeat link$strrdma on $sysi:");
        $def_port = '50001';
    } elsif ($id == 3) {
        $question = Msg::new("Enter the$udp port for the third private heartbeat link$strrdma on $sysi:");
        $def_port = '50002';
    } elsif ($id == 4) {
        $question = Msg::new("Enter the$udp port for the fourth private heartbeat link$strrdma on $sysi:");
        $def_port = '50003';
    } elsif ($id == 5) {
        $question = Msg::new("Enter the$udp port for the fifth private heartbeat link$strrdma on $sysi:");
        $def_port = '50004';
    } elsif ($id == 6) {
        $question = Msg::new("Enter the$udp port for the sixth private heartbeat link$strrdma on $sysi:");
        $def_port = '50005';
    } elsif ($id == 7) {
        $question = Msg::new("Enter the$udp port for the seventh private heartbeat link$strrdma on $sysi:");
        $def_port = '50006';
    } elsif ($id == 8) {
        $question = Msg::new("Enter the$udp port for the eighth private heartbeat link$strrdma on $sysi:");
        $def_port = '50007';
    }
    while (EDRu::inarr($def_port,@$used_port)) {
        $def_port++;
    }
    while (1) {
        $port = $question->ask($def_port,$help,1);
        return $port if (EDR::getmsgkey($port,'back'));
        if (EDRu::isint($port) && ($port>0)&& ($port < 65536)) {
            if (EDRu::inarr($port,@$used_port)) {
                $msg = Msg::new("$udp port $port is already used by another private heartbeat link on $sysi");
                $msg->print();
                next;
            } else {
                last;
            }
        } else {
            $msg = Msg::new("$port is not a valid $udp port");
            $msg->print();
        }
    }
    return $port;
}

sub default_hbnic {
    my ($prod,$rsn,$rpn,$ren) = @_;
    my $cfg = Obj::cfg();
    if ($cfg->{lltoverudp}) {
        for my $nic (@$rsn) {
            next if ($nic eq $$rpn[0]);
            next if ($ren && EDRu::inarr($nic,@$ren));
            return $nic;
        }
    } else {
        for my $nic (@$rsn) {
            next if (EDRu::inarr($nic,@$rpn));
            next if ($ren && EDRu::inarr($nic,@$ren));
            return $nic;
        }
    }
    return;
}

# ask for a heartbeat nic
sub ask_hbnic_sys {
    my ($prod,$sysi,$fst,$rsn,$rpn,$ren,$default_nic,$rdma_tag) = @_;
    my ($sn,$msg,$cfg,$backopt,$sys,$ayn,$padv,$nic,$max_hipri_links,$help,$pn,$en,$def,$rdma,$rdmalowpri);
    $sys=$sysi->{sys};
    $padv=$sysi->padv();
    $cfg=Obj::cfg();
    $backopt=1;
    $rdma_tag ||= $prod->{llt_rdma} ? 1 : 0;
    $rdma = '';
    $rdma = ' (RDMA)' if $rdma_tag;
    if ($rdma_tag) {
        $rdmalowpri = Msg::new("(RDMA or UDP)")->{msg};
    } else {
        $rdmalowpri = '';
    }

    if ($fst =~ /lowpri/m) {
        $help=Msg::new("The NIC selected as a low-priority heartbeat link is typically the network card on which the system's public IP address is active");
    } else {
        $help=Msg::new("The NIC selected as a private heartbeat link is typically not plumbed or configured with an IP address. NIC devices used for each heartbeat link must have a private connection using network switches, hubs, or crossover cables.\n\nEnter any NIC at the prompt if a NIC device on your system is not properly discovered.");
    }
    while (!$nic) {
        if ($default_nic) {
            $def = $default_nic;
        } else {
            $def=$prod->default_hbnic($rsn,$rpn,$ren);
        }
        if ($fst =~ /lowpri/m) {
            $def = $default_nic||$rpn->[0];
            if ($fst eq 'lowpri' || $fst eq 'lowpri1') {
                Msg::n();
                $msg=Msg::new("Enter the NIC for the low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri2' ) {
                $msg=Msg::new("Enter the NIC for the second low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri3' ) {
                $msg=Msg::new("Enter the NIC for the third low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri4' ) {
                $msg=Msg::new("Enter the NIC for the fourth low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri5' ) {
                $msg=Msg::new("Enter the NIC for the fifth low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri6' ) {
                $msg=Msg::new("Enter the NIC for the sixth low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri7' ) {
                $msg=Msg::new("Enter the NIC for the seventh low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            } elsif ( $fst eq 'lowpri8' ) {
                $msg=Msg::new("Enter the NIC for the eighth low-priority heartbeat link$rdmalowpri on $sys:");
                $en=$msg->ask($def,$help,$backopt);
            }
        } elsif ($fst eq '1') {
            $msg=Msg::new("Enter the NIC for the first private heartbeat link$rdma on $sys:");
            if ( Cfg::opt('addnode')) {
                $en=$msg->ask($def,$help,0);
            } else {
                $en=$msg->ask($def,$help,$backopt);
            }
        } elsif ($fst eq '2') {
            $msg=Msg::new("Enter the NIC for the second private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        } elsif ($fst eq '3') {
            $msg=Msg::new("Enter the NIC for the third private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        } elsif ($fst eq '4') {
            $msg=Msg::new("Enter the NIC for the fourth private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        } elsif ($fst eq '5') {
            $msg=Msg::new("Enter the NIC for the fifth private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        } elsif ($fst eq '6') {
            $msg=Msg::new("Enter the NIC for the sixth private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        } elsif ($fst eq '7') {
            $msg=Msg::new("Enter the NIC for the seventh private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        } elsif ($fst eq '8') {
            $msg=Msg::new("Enter the NIC for the eighth private heartbeat link$rdma on $sys:");
            $en=$msg->ask($def,$help,$backopt);
        }
        return $en if (EDR::getmsgkey($en,'back'));
        $en=EDRu::despace($en);
        $pn=EDRu::arrpos($en,@$rpn);
        $sn=EDRu::arrpos($en,@$rsn);
        $max_hipri_links = $prod->{max_hipri_links};
        if ($en eq '') {
        } elsif ($en =~/\s+/m) {
            $msg=Msg::new("Only one NIC name is needed at a time");
            $msg->print;
        } elsif (EDRu::isnic($en) == 0) {
            $msg=Msg::new("$en is not a valid NIC name");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+1]) {
            $msg=Msg::new("$en is already being used for the first low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+2]) {
            $msg=Msg::new("$en is already being used for the second low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+3]) {
            $msg=Msg::new("$en is already being used for the third low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+4]) {
            $msg=Msg::new("$en is already being used for the fourth low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+5]) {
            $msg=Msg::new("$en is already being used for the fifth low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+6]) {
            $msg=Msg::new("$en is already being used for the sixth low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+7]) {
            $msg=Msg::new("$en is already being used for the seventh low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[$max_hipri_links+8]) {
            $msg=Msg::new("$en is already being used for the eighth low-priority heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[1]) {
            $msg=Msg::new("$en is already being used for the first private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[2]) {
            $msg=Msg::new("$en is already being used for the second private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[3]) {
            $msg=Msg::new("$en is already being used for the third private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[4]) {
            $msg=Msg::new("$en is already being used for the fourth private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[5]) {
            $msg=Msg::new("$en is already being used for the fifth private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[6]) {
            $msg=Msg::new("$en is already being used for the sixth private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[7]) {
            $msg=Msg::new("$en is already being used for the seventh private heartbeat link");
            $msg->print;
        } elsif ($en eq $ren->[8]) {
            $msg=Msg::new("$en is already being used for the eighth private heartbeat link");
            $msg->print;
        } elsif ((($pn>=0) && ($fst !~ /lowpri/m)) && !($cfg->{lltoverudp}) && !$rdma_tag ||
            (($#$rsn>=0) && ($sn<0))) {
            if (($pn>=0) && ($fst !~ /lowpri/m)) {
                $msg=Msg::new("$en has an IP address configured on it. It could be a public NIC on $sys.");
                $msg->print;
                $help=Msg::new("The NIC selected as a private heartbeat link is typically not plumbed or configured with an IP address. NIC devices used for each heartbeat link must have a private connection using network switches, hubs, or crossover cables.");
                if ($fst eq '1') {
                    $msg=Msg::new("Are you sure you want to use $en for the first private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '2') {
                    $msg=Msg::new("Are you sure you want to use $en for the second private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '3') {
                    $msg=Msg::new("Are you sure you want to use $en for the third private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '4') {
                    $msg=Msg::new("Are you sure you want to use $en for the fourth private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '5') {
                    $msg=Msg::new("Are you sure you want to use $en for the fifth private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '6') {
                    $msg=Msg::new("Are you sure you want to use $en for the sixth private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '7') {
                    $msg=Msg::new("Are you sure you want to use $en for the seventh private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } elsif ($fst eq '8') {
                    $msg=Msg::new("Are you sure you want to use $en for the eighth private heartbeat link?");
                    $ayn=$msg->aynn($help,$backopt);
                } else {
                    if ($fst eq 'lowpri' || $fst eq 'lowpri1') {
                        $msg=Msg::new("Are you sure you want to use $en for the low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri2') {
                        $msg=Msg::new("Are you sure you want to use $en for the second low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri3') {
                        $msg=Msg::new("Are you sure you want to use $en for the third low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri4') {
                        $msg=Msg::new("Are you sure you want to use $en for the fourth low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri5') {
                        $msg=Msg::new("Are you sure you want to use $en for the fifth low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri6') {
                        $msg=Msg::new("Are you sure you want to use $en for the sixth low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri7') {
                        $msg=Msg::new("Are you sure you want to use $en for the seventh low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    } elsif ($fst eq 'lowpri8') {
                        $msg=Msg::new("Are you sure you want to use $en for the eighth low-priority heartbeat link?");
                        $ayn=$msg->aynn($help,$backopt);
                    }
                }
                return $ayn if (EDR::getmsgkey($ayn,'back'));
                $nic=$en if ($ayn eq 'Y');
            } elsif (Cfg::opt('makeresponsefile')) {
                $nic=$en;
            } else {
                $msg=Msg::new("$en is not a NIC discovered on $sys");
                $msg->print;
                next;
            }
        } else {
            $nic=$en;
        }
    }
    return "$nic";
}

# Ask about a second heartbeat link
sub ask_second_hb {
    my ($prod,$cfg,$ayn,$msg,$help,$backopt);
    $prod=shift;
    $cfg = Obj::cfg();
    $backopt=1;
    $help = Msg::new("A $prod->{abbr} cluster is typically configured to use two private heartbeat links, but some $prod->{abbr} clusters may be configured with just one private heartbeat link and a second low-priority heartbeat link. The NIC selected as a low-priority heartbeat link is typically the network card on which the system's public IP address is active.");
    Msg::n();
    $msg = Msg::new("Would you like to configure a second private heartbeat link?");
    if ($cfg->{fencingenabled}) {
        $ayn = $msg->aynn($help,$backopt);
    } else {
        $ayn = $msg->ayny($help,$backopt);
    }
    return $ayn;
}

# Ask about a third heartbeat link
sub ask_third_hb {
    my ($prod,$ayn,$msg,$help,$backopt);
    $prod=shift;
    $backopt=1;
    $help = Msg::new("A $prod->{abbr} cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
    Msg::n();
    $msg = Msg::new("Would you like to configure a third private heartbeat link?");
    $ayn = $msg->aynn($help,$backopt);
    return $ayn;
}

# Ask about a fourth heartbeat link
sub ask_fourth_hb {
    my ($prod,$ayn,$msg,$help,$backopt);
    $prod=shift;
    $backopt=1;
    $help = Msg::new("A $prod->{abbr} cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
    Msg::n();
    $msg = Msg::new("Would you like to configure a fourth private heartbeat link?");
    $ayn = $msg->aynn($help,$backopt);
    return $ayn;
}

# Ask about more (1st-8th) heartbeat links
sub ask_nth_hb {
    my ($prod,$n) = @_;
    my ($msg,$abbr,$backopt,$ayn,$help);
    $backopt=1;
    $abbr = $prod->{abbr};
    if ($n==1) {
        # the first heartbeat link is required.
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure the first private heartbeat link?");
    } elsif ($n==2) {
        $help = Msg::new("A $abbr cluster is typically configured to use two private heartbeat links, but some $abbr clusters may be configured with just one private heartbeat link and a second low-priority heartbeat link. The NIC selected as a low-priority heartbeat link is typically the network card on which the system's public IP address is active.");
        $msg = Msg::new("Would you like to configure a second private heartbeat link?");
    } elsif ($n==3) {
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure a third private heartbeat link?");
    } elsif ($n==4) {
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure a fourth private heartbeat link?");
    } elsif ($n==5) {
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure a fifth private heartbeat link?");
    } elsif ($n==6) {
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure a sixth private heartbeat link?");
    } elsif ($n==7) {
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure a seventh private heartbeat link?");
    } elsif ($n==8) {
        $help = Msg::new("A $abbr cluster requires two private heartbeat links, but additional heartbeat links may be configured for increased performance and protection.");
        $msg = Msg::new("Would you like to configure an eighth private heartbeat link?");
    }
    $ayn = $msg->aynn($help,$backopt);
    return $ayn;
}

# Ask about a lowpri heartbeat link
sub ask_lowpri_hb {
    my ($prod,$n) = @_;
    my ($msg,$backopt,$ayn,$help);
    $backopt=1;
    if (!defined($n)||$n==0||$n==1) {
        Msg::n();
        $msg = Msg::new("Do you want to configure an additional low-priority heartbeat link?");
    } elsif ($n==2) {
        Msg::n();
        $msg = Msg::new("Do you want to configure a second low-priority heartbeat link?");
    } elsif ($n==3) {
        $msg = Msg::new("Do you want to configure a third low-priority heartbeat link?");
    } elsif ($n==4) {
        $msg = Msg::new("Do you want to configure a fourth low-priority heartbeat link?");
    } elsif ($n==5) {
        $msg = Msg::new("Do you want to configure a fifth low-priority heartbeat link?");
    } elsif ($n==6) {
        $msg = Msg::new("Do you want to configure a sixth low-priority heartbeat link?");
    } elsif ($n==7) {
        $msg = Msg::new("Do you want to configure a seventh low-priority heartbeat link?");
    } elsif ($n==8) {
        $msg = Msg::new("Do you want to configure an eighth low-priority heartbeat link?");
    }
    $help=Msg::new("Configuring a low-priority heartbeat link on the public network is an option that provides an additional method of confirming system failure.");
    $ayn = $msg->aynn($help,$backopt);
    return $ayn;
}

# Ask about using common NIC numbers
sub ask_common_nics {
    my ($prod,$ayn,$msg,$help,$backopt,$warn,$cprod);
    $prod=shift;
    $cprod=CPIC::get('prod');
    $backopt=1;
    $help = Msg::new("Enter 'y' if the NIC devices used for this heartbeat link are the same on all systems in the cluster. Enter 'n' if NIC devices used for this heartbeat link are not the same on all systems in the cluster.");
    Msg::n();
    $msg = Msg::new("Are you using the same NICs for private heartbeat links on all systems?");
    $ayn = $msg->ayny($help,$backopt);
    if ($ayn eq 'N' && $cprod eq 'SFRAC61' ){
        while(1){
           $warn=Msg::new("Oracle Clusterware needs that you must use the same NICs for private heartbeat links on\nall systems of your cluster, otherwise it will not get configured on your cluster.");
           $warn->warning();
           $ayn = $msg->ayny($help,$backopt);
           next if ($ayn eq 'N');
           last;
        } 
    }
    return $ayn;
}

# verify a clustername starts with a letter and has valid characters
sub verify_clustername {
    my ($prod,$name) = @_;
    my ($msg,$fc,$cname,$ask);
    $fc=substr($name,0,1);
    if ($fc =~ /[^A-Za-z]/m) {
         $msg=Msg::new("Cluster Name must start with a letter");
         $msg->print();
         return 0;
    }
    $cname=$name;
    $cname =~ s/[A-Za-z0-9_-]//mxg;
    if ($cname) {
        $msg = Msg::new("Cluster Name cannot use the characters: $cname");
        $msg->print();
    } elsif ($prod->vcs_reservedwords($name)) {
        $msg = Msg::new("$name is a VCS reserved word and cannot be used as a cluster name");
        $msg->print();
    } else {
        return 1;
    }
    return 0;
}


# purpose:  transform the system name from user input to the proper format
#           in order to make sure correct hostname or IP format is used in main.cf as SystemList by VCS engine
#           besides fixing the incident 1010374,our purpose is to process IPv4,IPv6 and FQDN name simultaneous.
#           It can be applied in main.cf file.
# params:   $sysname original system name from user input
# returns:  $sysname system name VCS which engine can identify
#
sub transform_system_name {
    my $sysname = shift;
    return unless ($sysname);

    # previously, CPI add double quotas for IPv4 IPv6 and FQDN address used in main.cf
    # to make it accepted by VCS enginee, this is an un-documented VCS behavior
    # confirmed with VCS team, change design into:
    # CPI replace IPv4 IPv6 FQDN address with nodename as the system name

    if (EDRu::ip_is_ipv4($sysname) || EDRu::ip_is_ipv6($sysname) || ($sysname =~ /\.\w+/m)) {
        # return "\"$sysname\""; # add double quotation marks
        my $sys = Obj::sys($sysname);
        return $sys->{hostname};
    } else {
        # return it when parameter is regular hostname
        return $sysname;
    }
}

# Get RDMA capable NICs
sub rdmanics_sys {
    my ($prod,$sys,$nics) = @_;
    my @rdma_nics=();

    for my $nic (@$nics) {
        if ($sys->is_nic_rdma_capable($nic)) {
            push @rdma_nics, $nic;
        }
    }
    return \@rdma_nics;
}

# create an /etc/llttab entry for a NIC
sub convert_nic2lltlink_sys {
    my ($prod,$sys,$nic,$lp) = @_;
    my ($n,$vionics,$l,$lowpri,$dev);
    return '' if (!$nic);
    if ($lp) {
        $lowpri='-lowpri';
    } else {
        $lowpri='';
    }

    $dev = ($sys->aix()) ? '/dev/dlpi' : '/dev';
    $l=$n=$nic;
    $l=~s/(.*[A-Za-z])\d*/$1/mxg;
    $n=~s/.*[A-Za-z](\d*)$/$1/mxg;
    if( $sys->aix() ) {
        $vionics= $sys->padv->virtualnics_sys($sys);
        # if any configured NIC is found a virtual I/O Micro-partition NIC => set default MTU to be 1500 b/s
        if( EDRu::inarr($nic, @$vionics) ) {
            return "link$lowpri $nic $dev/$l:$n - ether - 1500\n";
        }
    }
    if ( $sys->{padv} =~ /^Sol11/m ) {
        return "link$lowpri $nic /dev/net/$nic - ether - -\n";
    }
    return "link$lowpri $nic $dev/$l:$n - ether - -\n";
}

sub convert_nic2rdma_sys {
    my ($prod,$sys,$n,$lp) = @_;
    my ($lowpri,$lowkey,$dev,$sysi,$plat,$nic,$port,$address,$linktype,$devn,$bcastaddr);

    if ($lp) {
        $lowpri='-lowpri';
        $lowkey='lowpri'
    } else {
        $lowpri='';
        $lowkey='';
    }
    my $cfg = Obj::cfg();

    $plat=EDRu::plat($prod->{padv});
    $sysi=$sys->{sys};
    if($plat =~ /AIX/m) {
        $dev = '/dev/xti/udp'
    } elsif ($plat =~ /SunOS|HPUX/m) {
        $dev = '/dev/udp'
    } else {
        $dev = 'udp';
    }
    $nic = $cfg->{"vcs_lltlink$lowkey$n"}{$sysi};
    $port = $cfg->{"vcs_rdmalink$lowkey$n".'_port'}{$sysi};
    $address = $cfg->{"vcs_rdmalink$lowkey$n".'_address'}{$sysi};
    $devn = $dev;
    if ($cfg->{"vcs_rdmalink$lowkey$n".'_udp'}{$sysi}) {
        $linktype = 'udp';
    } else {
        $linktype = 'rdma';
    }
    if(EDRu::ip_is_ipv6($address)) {
        $devn = "$dev".'6';
    }
    $bcastaddr=$sys->padv->nic_bcast_sys($sys,$nic,$address);
    $bcastaddr="-" unless($bcastaddr);
    #$content .= "link $nic $devn - $linktype $port - $address -\n";
    return "link$lowpri $nic $devn - $linktype $port - $address $bcastaddr\n";
}

# get the original NIC name from an Ethernet link/link-lowpri devname in /etc/llttab (For LLT over Ethernet)
sub convert_linkdev2nic_sys {
    my ($prod,$sys,$linkdev) = @_;
    my ($nic,$dev);
    return '' if (!$linkdev);
    $dev = ($sys->aix()) ? '/dev/dlpi/' : '/dev/';
    if ( $sys->{padv} =~ /^Sol11/m) {
        $dev = '/dev/net/';
    }
    $nic = $linkdev;
    $nic=~s/$dev//m;
    $nic=~s/://m;
    return $nic;
}

# get the original NIC name from a link/link-lowpri IP address in /etc/llttab (For LLT over UDP)
sub convert_linkip2nic_sys {
    my ($prod,$sys,$linkip) = @_;
    my ($rnics,$nic,$found,$nici,$output,$dev);
    return '' if (!$linkip);
    $rnics = $sys->padv()->systemnics_sys($sys,1);
    $found = 0;
    for my $nici (@$rnics) {
        next unless $nici;
        $output = $sys->cmd("_cmd_ifconfig '$nici'");
        if ( $output =~ /[^A-Fa-f0-9]$linkip[^A-Fa-f0-9]/mx) {
            $found = 1;
            $nic = $nici;
            last;
        }
    }
    if (!$found) {
        $nic = '';
    }
    return $nic;
}

sub generate_udplinks_sys {
    my ($prod,$sys,$bcast) = @_;
    my ($sysi,$content,$plat,$n,$nic,$port,$system,$devn,$nid,$address,$linktype,$dev,$bcastaddr);
    my $cfg = Obj::cfg();

    $plat=EDRu::plat($prod->{padv});
    $sysi=$sys->{sys};
    if($plat =~ /AIX/m) {
        $dev = '/dev/xti/udp'
    } elsif ($plat =~ /SunOS|HPUX/m) {
        $dev = '/dev/udp'
    } else {
        $dev = 'udp';
    }
    $content = '';
    for my $n (1..$prod->num_hbnics_cfg($cfg)) {
        $nic = $cfg->{"vcs_lltlink$n"}{$sysi};
        $port = $cfg->{"vcs_udplink$n".'_port'}{$sysi};
        $address = $cfg->{"vcs_udplink$n".'_address'}{$sysi};
        $devn = $dev;
        $linktype = 'udp';
        if(EDRu::ip_is_ipv6($address)) {
            $devn = "$dev".'6';
            $linktype = 'udp6';
        }
        if($bcast){
            $bcastaddr=$sys->padv->nic_bcast_sys($sys,$nic,$address);
        }
        $bcastaddr="-" unless($bcastaddr);
        #$content .= "link $nic $devn - $linktype $port - $address -\n";
        $content .= "link $nic $devn - $linktype $port - $address $bcastaddr\n";
    }

    for my $n (1..$prod->num_lopri_hbnics_cfg($cfg)) {
        $nic = $cfg->{"vcs_lltlinklowpri$n"}{$sysi};
        $port = $cfg->{"vcs_udplinklowpri$n".'_port'}{$sysi};
        $address = $cfg->{"vcs_udplinklowpri$n".'_address'}{$sysi};
        $devn = $dev;
        $linktype = 'udp';
        if(EDRu::ip_is_ipv6($address)) {
            $devn = "$dev".'6';
            $linktype = 'udp6';
        }
        if($bcast){
            $bcastaddr=$sys->padv->nic_bcast_sys($sys,$nic,$address);
        }
        $bcastaddr="-" unless($bcastaddr);
        #$content .= "link-lowpri $nic $devn - $linktype $port - $address -\n";
        $content .= "link-lowpri $nic $devn - $linktype $port - $address $bcastaddr\n";
    }
    $nid = 0;
    my $systems = cluster_systems();
    for my $system (@$systems) {
        my $sysname;
        if(ref($system) eq 'Sys'){
            $sysname = transform_system_name($system->{sys});
        }else{
            $sysname = $system;
        }

        my $sysnamei = transform_system_name($sysi);
        if ($sysname eq $sysnamei) {
            $nid++;
            next;
        }
        for my $n (1..$prod->num_hbnics_cfg($cfg)) {
            $nic = $cfg->{"vcs_lltlink$n"}{$sysi};
            $address = $cfg->{"vcs_udplink$n".'_address'}{$sysname};
            $content.= "set-addr $nid $nic $address\n";
        }
        for my $n (1..$prod->num_lopri_hbnics_cfg($cfg)) {
            $nic = $cfg->{"vcs_lltlinklowpri$n"}{$sysi};
            $address = $cfg->{"vcs_udplinklowpri$n".'_address'}{$sysname};
            $content.= "set-addr $nid $nic $address\n";
        }
        $nid++;
    }
    $content.="set-bcasthb 0\n";
    $content.="set-arp 0\n";

    return $content;
}

sub update_llttab {
    my ($prod,$tmp) = @_;
    my ($sysi,$sys,$cfg,$llttab,$hostname,$n,$tmpdir,$addrkey);
    $cfg = Obj::cfg();
    $tmpdir=EDR::tmpdir();
    for my $sys (@{CPIC::get('systems')}) {
        $sysi = $sys->{sys};
        $hostname = transform_system_name($sysi);
        $llttab="set-node $hostname\nset-cluster $cfg->{vcs_clusterid}\n";
        if ($cfg->{lltoverudp}) {
            $llttab.=$prod->generate_udplinks_sys($sys,$tmp);
        } else {
            for my $n (1..$prod->num_hbnics_cfg($cfg)) {
                $addrkey = "vcs_rdmalink${n}_address";
                $llttab.= (defined $cfg->{$addrkey}) && $cfg->{$addrkey}{$sysi} ?
                          $prod->convert_nic2rdma_sys($sys,$n)
                        : $prod->convert_nic2lltlink_sys($sys, $cfg->{"vcs_lltlink$n"}{$sysi});
            }
            for my $n (1..$prod->num_lopri_hbnics_cfg($cfg)) {
                $addrkey = "vcs_rdmalinklowpri${n}_address";
                $llttab.= (defined $cfg->{$addrkey}) && $cfg->{$addrkey}{$sysi} ?
                          $prod->convert_nic2rdma_sys($sys,$n,'lowpri')
                        : $prod->convert_nic2lltlink_sys($sys, $cfg->{"vcs_lltlinklowpri$n"}{$sysi},1);
            }
        }
        EDRu::writefile($llttab,"$tmpdir/llttab.$sysi",1);
    }
    return;
}

sub update_llthosts {
    my ($prod,$cfg,$llthosts,$n,$sysi,$lltsys,$tmpdir,$systems);
    $prod = shift;
    $cfg = Obj::cfg();

    $llthosts = '';
    $n=0;
    $tmpdir=EDR::tmpdir();
    $systems = cluster_systems();
    for my $sysi (@$systems) {
        if(ref($sysi) eq 'Sys'){
            $lltsys = transform_system_name($sysi->{sys});
        }else{
            $lltsys = $sysi;
        }
        $llthosts.="$n $lltsys\n";
        $n++;
    }
    EDRu::writefile($llthosts,"$tmpdir/llthosts",1 );
    return;
}

sub update_gabtab {
    my ($prod,$cfg,$gabtab,$n,$tmpdir,$systems);
    $prod = shift;
    $cfg = Obj::cfg();

    $systems = cluster_systems();
    $n = $#$systems+1;
    $gabtab = "/sbin/gabconfig -c -n$n\n";
    $tmpdir=EDR::tmpdir();
    EDRu::writefile($gabtab,"$tmpdir/gabtab", 1);
    return;
}

sub update_maincf {
    my ($prod,$sys) = @_;
    my ($admins,$ddev_nwhosts,$sysi,$extype,$cfg,$ddev,$drid,$cdev_nwhosts,$extypes,$opers,$n,$drnd,$cdev,$csl,$users,$sys2,$prefix,$ddev_attr,$maincf,$tmpdir,$recp,$cdev_attr,$cons,$secure,$systems);
    $cfg = Obj::cfg();

    $tmpdir=EDR::tmpdir();
    $maincf="include \"types.cf\"\n";
    # include extra vcs types
    $extypes = $prod->get_extra_types_sys($sys);
    if($extypes) {
        for my $extype (@$extypes) {
            $maincf.="include \"$extype\"\n";
        }
    }
    $maincf.="\ncluster $cfg->{vcs_clustername} (";
    $maincf.="\n\tSecureClus = 1" if $cfg->{vcs_eat_security};
    for my $n (0..$#{$cfg->{vcs_username}}) {
        $users.=', ' if ($users);
        $users.="\"${$cfg->{vcs_username}}[$n]\" = ${$cfg->{vcs_userenpw}}[$n]";
        if (${$cfg->{vcs_userpriv}}[$n] eq 'Administrators') {
            $admins.=', ' if ($admins);
            $admins.="\"${$cfg->{vcs_username}}[$n]\"";
        } elsif (${$cfg->{vcs_userpriv}}[$n] eq 'Operators') {
            $opers.=', ' if ($opers);
            $opers.="\"${$cfg->{vcs_username}}[$n]\"";
        }
    }
    $maincf .= "\n\tUserNames = { $users }" if ($users);
    $maincf .= "\n\tAdministrators = { $admins }" if ($admins);
    $maincf .= "\n\tOperators = { $opers }" if ($opers);
    if ($cfg->{vcs_gcovip}) {
        $maincf .= "\n\tClusterAddress = \"$cfg->{vcs_gcovip}\"";
    } elsif ($cfg->{vcs_csgvip}) {
        $maincf .= "\n\tClusterAddress = \"$cfg->{vcs_csgvip}\"";
    }
    $maincf .= "\n\tCounterInterval = 5\n\t)\n\n";

    $n=0;
    $systems = cluster_systems();
    for my $sysi (@$systems) {
        $sys2 =transform_system_name($sysi->{sys});
        $maincf.="system $sys2 (\n\t)\n\n";
        $csl.= ', ' if ($csl);
        $csl.= $sys2;
        $n++;
    }

    #get the vcs_csgnic string
    $cdev = "\t\tDevice = \"$cfg->{vcs_csgnic}{all}\"\n" if ($cfg->{vcs_csgnic}{all});
    if ($cfg->{vcs_csgnic}{${$cfg->{systems}}[0]}) {
        for my $sys (@{$cfg->{systems}}) {
            $sys2 = transform_system_name($sys);
            $cdev.="\t\tDevice\@$sys2 = \"$cfg->{vcs_csgnic}{$sys}\"\n";
        }
    }
    $cdev_attr=$prod->nic_protocol_attr() if ($cdev);

    # For AIX
    $cdev_nwhosts=$prod->nic_nwhosts_csg() if ($cdev && $sys->aix());
    # For HP
    $cdev_nwhosts=$prod->store_nhip() if ($cdev && $sys->hpux());

    #get the vcs_gconic string
    $ddev="\t\tDevice = \"$cfg->{vcs_gconic}{all}\"\n" if ($cfg->{vcs_gconic}{all});
    if ($cfg->{vcs_gconic}{${$cfg->{systems}}[0]}) {
        for my $sys (@{$cfg->{systems}}) {
            $sys2 = transform_system_name($sys);
            $ddev.="\t\tDevice\@$sys2 = \"$cfg->{vcs_gconic}{$sys}\"\n";
        }
    }
    $ddev_attr=$prod->nic_protocol_attr(1) if($ddev);
    # for AIX
    $ddev_nwhosts=$prod->nic_nwhosts_gco() if ($ddev && $sys->aix());
    # for HP
    $ddev_nwhosts=$prod->store_nhip() if ($ddev && $sys->hpux());

    #GCO info
    $prefix=EDRu::ip_is_ipv6($cfg->{vcs_csgvip})? 'PrefixLen' : 'NetMask';
    $secure = ' -secure' if $cfg->{vcs_eat_security};
    $maincf .= "group ClusterService (\n\tSystemList = { $csl }\n\tAutoStartList = { $csl }\n\tOnlineRetryLimit = 3\n\tOnlineRetryInterval = 120\n\t)\n\n" if (($cdev) || ($ddev));
    $maincf .= "\tApplication wac (\n\t\tStartProgram = \"/opt/VRTSvcs/bin/wacstart$secure\"\n\t\tStopProgram = \"/opt/VRTSvcs/bin/wacstop\"\n\t\tMonitorProcesses = { \"/opt/VRTSvcs/bin/wac$secure\" }\n\t\tRestartLimit = 3\n\t\t)\n\n" if ($cfg->{vcs_gcovip});
    $maincf .= "\tIP webip (\n$cdev\t\tAddress = \"$cfg->{vcs_csgvip}\"\n\t\t$prefix = \"$cfg->{vcs_csgnetmask}\"\n\t\t)\n\n" if ($cfg->{vcs_csgvip});
    if (($cfg->{vcs_gcovip}) && ($cfg->{vcs_gcovip} ne $cfg->{vcs_csgvip})) {
        $prefix = EDRu::ip_is_ipv6($cfg->{vcs_gcovip})? 'PrefixLen' : 'NetMask';
        $maincf .= "\tIP gcoip (\n$ddev\t\tAddress = \"$cfg->{vcs_gcovip}\"\n\t\t$prefix = \"$cfg->{vcs_gconetmask}\"\n\t\t)\n\n";
        $drid = 'gcoip';
    } else {
        $drid = 'webip';
    }
    #$maincf .= "\tNIC csgnic (\n$cdev\t\t)\n\n";
    if ($cdev) {
        if ($cdev_attr ) {
            if ($cdev_nwhosts) {
                $maincf .= "\tNIC csgnic (\n$cdev\t\t$cdev_attr\t\t$cdev_nwhosts\t\t)\n\n";
            } else {
                $maincf .= "\tNIC csgnic (\n$cdev\t\t$cdev_attr\t\t)\n\n";
            }
        } else {
           if ($cdev_nwhosts) {
                $maincf .= "\tNIC csgnic (\n$cdev\t\t$cdev_nwhosts\t\t)\n\n";
           } else {
                $maincf .= "\tNIC csgnic (\n$cdev\t\t)\n\n";
           }
       }
    }

    if ($ddev){
        if ($ddev ne $cdev){
            if($ddev_attr) {
                if ($ddev_nwhosts) {
                    $maincf .= "\tNIC gconic (\n$ddev\t\t$ddev_attr\t\t$ddev_nwhosts\t\t)\n\n";
                } else {
                    $maincf .= "\tNIC gconic (\n$ddev\t\t$ddev_attr\t\t)\n\n";
                }
            } else {
                if ($ddev_nwhosts) {
                    $maincf .= "\tNIC gconic (\n$ddev\t\t$ddev_nwhosts\t\t)\n\n";
                } else {
                    $maincf .= "\tNIC gconic (\n$ddev\t\t)\n\n";
                }
            }
            $drnd='gconic';
        } else {
            $drnd='csgnic';
        }
    }

    #log SNMP and SMTP
    $maincf .= "\tNotifierMngr ntfr (\n" if (($cfg->{vcs_smtpserver}) || ($cfg->{vcs_snmpport}));
    #log SNMP
    if ($cfg->{vcs_snmpport}) {
        for my $n (0..$#{$cfg->{vcs_snmpcons}}) {
            $cons.=', ' if ($cons);
            $cons.="\"${$cfg->{vcs_snmpcons}}[$n]\" = ${$cfg->{vcs_snmpcsev}}[$n]";
        }
        $maincf.="\t\tSnmpConsoles = { $cons }\n";
        $maincf.="\t\tSnmpdTrapPort = $cfg->{vcs_snmpport}\n" if ($cfg->{vcs_snmpport}!=162);
    }
    #log SMTP
    if ($cfg->{vcs_smtpserver}) {
        for my $n (0..$#{$cfg->{vcs_smtprecp}}) {
            $recp.=', ' if ($recp);
            $recp.="\"${$cfg->{vcs_smtprecp}}[$n]\" = ${$cfg->{vcs_smtprsev}}[$n]";
        }
        $maincf .= "\t\tSmtpServer = \"$cfg->{vcs_smtpserver}\"\n\t\tSmtpRecipients ={ $recp }\n";
    }
    $maincf .= "\t\t)\n\n" if (($cfg->{vcs_smtpserver}) || ($cfg->{vcs_snmpport}));

   #$maincf .= "\tVRTSWebApp VCSweb (\n\t\tCritical = 0\n\t\tAppName = \"cmc\"\n\t\tInstallDir = \"/opt/VRTSweb/VERITAS\"\n\t\tTimeForOnline = 5\n\t\tRestartLimit = 3\n\t\t)\n\n\tVCSweb requires webip\n" if ($cfg->{vcs_csgvip});

    $maincf .= "\twebip requires csgnic\n" if ($cfg->{vcs_csgvip});
    $maincf .= "\tntfr requires csgnic\n" if (($cdev) && (($cfg->{vcs_snmpport}) || ($cfg->{vcs_smtpserver})));

    $maincf .= "\twac requires $drid\n" if ($cfg->{vcs_gcovip});
    $maincf .= "\t$drid requires $drnd\n" if ($drnd);

    EDRu::writefile($maincf,"$tmpdir/main.cf", 1);
    return;
}

sub store_nhip {
    my ($prod)=@_;
    my ($cfg,$ip,$nwhosts,$nwhost);

    $cfg=Obj::cfg();
    if ($cfg->{vcs_networkhosts}) {
        for my $ip (split(' ',$cfg->{vcs_networkhosts})) {
            $nwhost.=',' if($nwhost);
            $nwhost.="\"$ip\"" if ($ip);
        }
        $nwhosts='NetworkHosts = {'.$nwhost."}\n" if ($nwhost);
    }
    return $nwhosts;

}

sub nic_nwhosts_gco {
    my ($prod)=@_;
    my ($cfg,$ip,$ddev_nwhosts,$nwhost);

    $cfg=Obj::cfg();
    if ($cfg->{vcs_gconwhosts}) {
        for my $ip (split(' ',$cfg->{vcs_gconwhosts})) {
            $nwhost.=',' if($nwhost);
            $nwhost.="\"$ip\"" if ($ip);
        }
        $ddev_nwhosts='NetworkHosts = {'.$nwhost."}\n" if ($nwhost);
    }
    return $ddev_nwhosts;
}

sub nic_nwhosts_csg {
    my ($prod)=@_;
    my ($cfg,$syslist,$ip,$cdev_nwhosts,$nwhost,$sys);

    $cfg=Obj::cfg();
    $syslist=CPIC::get('systems');

    for my $sys (@$syslist) {
        $nwhost='';
        if ($cfg->{vcs_csgnwhosts}{$sys->{sys}}) {
            for my $ip (split(' ', $cfg->{vcs_csgnwhosts}{$sys->{sys}})) {
                $nwhost.=',' if($nwhost);
                $nwhost.="\"$ip\"" if ($ip);
            }
            $cdev_nwhosts.="\t\t" if ($cdev_nwhosts);
            $cdev_nwhosts.="NetworkHosts\@$sys->{sys} = {".$nwhost."}\n" if ($nwhost);
        }
    }
    return $cdev_nwhosts;
}
###
#
# performing vcs upgrade
#
###

sub check_upgradeable_sys {
    my ($prod,$sys) = @_;
    my ($conf,$iver);

    $iver = $prod->version_sys($sys);
    return 0 unless ($iver);
    return 0 unless ((EDRu::compvers($iver,$prod->{vers},4) == 2)||Cfg::opt('rollback'));
    $conf = $prod->get_config_sys($sys);
    return 0 unless ($conf);
    $sys->set_value('vcs_upgradeable', 1);
    return 1;
}

sub prestop_sys {
    my($prod,$sys) = @_;
    return 1;
}

# Start vxatd on each node in AB mode
# Delete the HA_SERVICES from ab pdr,add it to to local pdr
# Create the  webserver_VCS_principal for the new pdr.
sub at_upgrade_configure_sys{
    my ($prod,$sys)=@_;
    my ($chroot,$domain,$rootpath);

    return unless($sys->{secureclus});
    $rootpath = Cfg::opt('rootpath') || '';
    $chroot = ($rootpath) ? "_cmd_chroot $rootpath" : '';

    #delete the HA_SERVICES from ab pdr if any
    if ($rootpath && $sys->{osupgraded}) {
        # for LU with OS upgraded
        $prod->delete_domain_by_file_sys($sys,$rootpath);
    } else {
        # for normal upgrade or LU without OS upgraded
        $domain=$sys->cmd("$chroot _cmd_vssat listpd --pdrtype ab");
        if ($domain=~/Domain\s+?Name\s+?HA_SERVICES\@/mx) {
            $sys->cmd("$chroot _cmd_vssat deletepd --pdrtype ab --domain HA_SERVICES --silent");
        }
    }
    return;
}

# delete the HA_SERVICES from ab type domain
# by editing /var/VRTSat/ABAuthSource file directly
sub delete_domain_by_file_sys {
    my ($prod,$sys,$rootpath)=@_;
    my ($content,$line,$output,$save,$abfile);

    return if(!$rootpath);
    $abfile="$rootpath/var/VRTSat/ABAuthSource";
    if ($sys->exists($abfile)) {
        $content=$sys->cmd("_cmd_cat $abfile");
        for my $line (split(/\n/,$content)) {
            # Modify the file to remove the HA_SERVICE attributes.
            if ($line=~/^\[HA_SERVICE/mx) {
                $save=0;
            } elsif ($line=~/^\[/m) {
                $save=1;
            }
            $output.="$line\n" if ($save);
        }
        $sys->writefile($output,$abfile);
    }
    return;
}

sub upgrade_configure_sys {
    my ($prod,$sys) = @_;
    my ($sysi,$msg,$cfg,$uuid,$sysm,$copy_uuid_success,$obj_sysi,$syslist,$rtn,$vxfen,$cpic,$out,$amf,$initfile_content,$rootpath,$nsystems,$maincf,$usefence);

    $usefence = 1;
    $vxfen=$sys->proc('vxfen61');
    if ((!$sys->exists($prod->{vxfenmode})) && (!$sys->exists($prod->{vxfendg}))) {
        $usefence = 0;
        $vxfen->disable_sys($sys);
        if ($vxfen->can('disable_service_sys')) {
            $vxfen->disable_service_sys($sys);
        }
    } elsif(($sys->exists($prod->{vxfenmode})) && ($sys->exists($prod->{vxfendg}))) {
        $out=$sys->cmd("_cmd_cat $prod->{vxfenmode} 2>/dev/null | _cmd_grep -v '^#'");
        #scsi3_disk_policy=dmp
        if($out=~/vxfen_mode=scsi3/ && $out !~/scsi3_disk_policy/){
            Msg::log("Update vxfenmode file as scsi3_disk_policy is missing in 4.1");
            $sys->appendfile('scsi3_disk_policy=dmp',$prod->{vxfenmode});
        }
    }

    $cpic=Obj::cpic();
    # enable LGF and vcs after reboot if reboot is needed or it is phased upgrade
    if (($cpic->{reboot}||$prod->{upgrade_ignore_conf}||$prod->{phased_upgrade_1}) && $prod->can('enable_vcs_services_after_reboot_sys')) {
        $prod->enable_vcs_services_after_reboot_sys($sys);
    }

    if (!$cpic->{prod_not_enabled_before_upgrade}) {
        $amf = $sys->proc("amf61");
        $amf->enable_sys($sys);
    }

    return 1 if(Cfg::opt('upgrade_kernelpkgs'));
    unless ($sys->{vcs_upgradeable}){
        if($sys->system1){
            EDRu::create_flag('maincf_upgrade_done');
        }
        return 0;
    }
    $syslist=CPIC::get('systems');
    $cfg = Obj::cfg();
    # by default, set vcs_allowcomms to 1 if it isn't defined
    # this happens if other products (eg. sfcfs sfrac) calls vcs upgrade_configure_sys
    # but foget to set this attribute to 1
    $cfg->{vcs_allowcomms} = 1 unless (defined($cfg->{vcs_allowcomms}));

    # rm or create the secure file for CmdServer, according to the secure status
    $rootpath=Cfg::opt('rootpath')||'';
    if ($prod->{eat_upgrade_secure}) {
        $sys->cmd("_cmd_touch $rootpath$prod->{secure}");
    } else {
        $sys->cmd("_cmd_rmr $rootpath$prod->{secure}");
    }

    # perform following tasks only on first node of cluster
    if ($sys->system1) {
        # config uuid
        if ($prod->{upgrade_ignore_conf}) {
            #copy uuid from hosts upgraded in phased 1 to hosts upgraded in phased 2.
            for my $sysi (@{$sys->{cluster_systems}}) {
                if (defined $Obj::pool{"Sys\::$sysi"}) {
                    $obj_sysi = $Obj::pool{"Sys\::$sysi"};
                    next if (EDRu::inarr($obj_sysi,@$syslist));
                    next unless ($obj_sysi->{rsh} || $obj_sysi->{islocal});
                }
                $uuid=$prod->get_uuid_sys($obj_sysi);
                next if (!$uuid || $uuid =~ /NO_UUID/m);
                for my $sysm (@$syslist) {
                    $prod->set_uuid_2sys($sysm,$uuid);
                }
                $copy_uuid_success=1;
                last;
            }
            if (!$copy_uuid_success) {
                $msg = Msg::new("Cannot copy UUID from the hosts upgraded in phase 1 to the hosts upgraded in phase 2. Manually create UUID on all the nodes in the cluster, before rebooting the hosts.");
                $sys->push_warning($msg);
                EDRu::create_flag('maincf_upgrade_done');
                return 0;
            }
        } else {
            $rtn = $prod->config_uuid();
            if($rtn == -1) {
                $msg = Msg::new("Cannot find uuidconfig.pl for UUID configuration. Manually create UUID before starting VCS");
                $sys->push_warning($msg);
            }
        }
        # configure secure cluster for EAT
        # uuid is needed here, so this step is after creating uuid
        $prod->eat_upgrade_configure if $prod->{eat_upgrade_secure} || $prod->{eat_upgrade_secure_fencingonly};

        # perform dynamic upgrade during phase upgrade 1 or normal upgrade
        # only cleanup and recreate cps user on CPS server during phase upgrade 1 or normal upgrade
        # no need to do these steps during phase upgrade 2
        if (!$prod->{upgrade_ignore_conf}) {
            unless ($prod->dynupgrade_upgrade_sys($sys)) {
                EDRu::create_flag('maincf_upgrade_done');
                return 0;
            }
            # secure cps upgrade configure
            $prod->securecps_upgrade_configure();
        }

        # todo: some manually upgrade steps required
        EDRu::create_flag('maincf_upgrade_done');
    } else {
        EDRu::wait_for_flag('maincf_upgrade_done');
    }

    $initfile_content = undef;
    if ($sys->{initfile_content}) {
        $initfile_content = JSON::from_json($sys->{initfile_content});
    }

    if (!$initfile_content || !defined($initfile_content->{vcs}{VCS_START})) {
        $prod->set_initconf_variable_sys($sys, 'vcs', 'VCS_START', '1');
    }
    if (!$initfile_content || !defined($initfile_content->{vcs}{VCS_STOP})) {
        $prod->set_initconf_variable_sys($sys, 'vcs', 'VCS_STOP', '1');
    }
    if (!$initfile_content || !defined($initfile_content->{amf}{AMF_START})) {
        $prod->set_initconf_variable_sys($sys, 'amf', 'AMF_START', '1');
    }
    if (!$initfile_content || !defined($initfile_content->{amf}{AMF_STOP})) {
        $prod->set_initconf_variable_sys($sys, 'amf', 'AMF_STOP', '1');
    }

    if ($cfg->{vcs_allowcomms}) {

        $rootpath=Cfg::opt('rootpath');
        $maincf = $sys->readfile("$rootpath$prod->{configdir}/main.cf");
        $nsystems = grep({/^\s*system\s+/mx} split(/\n/,$maincf));
        if ($usefence) {
            if (!$initfile_content || !defined($initfile_content->{vxfen}{VXFEN_START})) {
                $prod->set_initconf_variable_sys($sys, 'vxfen', 'VXFEN_START', '1');
            }
            if (!$initfile_content || !defined($initfile_content->{vxfen}{VXFEN_STOP})) {
                $prod->set_initconf_variable_sys($sys, 'vxfen', 'VXFEN_STOP', '1');
            }
        }

        if ($nsystems < 2 && $usefence == 0 && $initfile_content && $initfile_content->{vcs} && $initfile_content->{vcs}{ONENODE} && $initfile_content->{vcs}{ONENODE} eq 'yes') {
            $prod->set_onenode_cluster_sys($sys,1);

            if (!$initfile_content || !defined($initfile_content->{llt}{LLT_START})) {
                $prod->set_initconf_variable_sys($sys, 'llt', 'LLT_START', '0');
            }
            if (!$initfile_content || !defined($initfile_content->{llt}{LLT_STOP})) {
                $prod->set_initconf_variable_sys($sys, 'llt', 'LLT_STOP', '0');
            }
            if (!$initfile_content || !defined($initfile_content->{gab}{GAB_START})) {
                $prod->set_initconf_variable_sys($sys, 'gab', 'GAB_START', '0');
            }
            if (!$initfile_content || !defined($initfile_content->{gab}{GAB_STOP})) {
                $prod->set_initconf_variable_sys($sys, 'gab', 'GAB_STOP', '0');
            }
        } else {
            # All: remove ONENODE=yes in vcs init file
            # SunOS: remove manifest for system/vcs-onenode
            $prod->set_onenode_cluster_sys($sys,0);

            if (!$initfile_content || !defined($initfile_content->{llt}{LLT_START})) {
                $prod->set_initconf_variable_sys($sys, 'llt', 'LLT_START', '1');
            }
            if (!$initfile_content || !defined($initfile_content->{llt}{LLT_STOP})) {
                $prod->set_initconf_variable_sys($sys, 'llt', 'LLT_STOP', '1');
            }
            if (!$initfile_content || !defined($initfile_content->{gab}{GAB_START})) {
                $prod->set_initconf_variable_sys($sys, 'gab', 'GAB_START', '1');
            }
            if (!$initfile_content || !defined($initfile_content->{gab}{GAB_STOP})) {
                $prod->set_initconf_variable_sys($sys, 'gab', 'GAB_STOP', '1');
            }
        }
    } else {
        # All: set ONENODE=yes in vcs init file
        # SunOS: import manifest vcs-onenode.xml
        $prod->set_onenode_cluster_sys($sys,1);

        if (!$initfile_content || !defined($initfile_content->{llt}{LLT_START})) {
            $prod->set_initconf_variable_sys($sys, 'llt', 'LLT_START', '0');
        }
        if (!$initfile_content || !defined($initfile_content->{llt}{LLT_STOP})) {
            $prod->set_initconf_variable_sys($sys, 'llt', 'LLT_STOP', '0');
        }
        if (!$initfile_content || !defined($initfile_content->{gab}{GAB_START})) {
            $prod->set_initconf_variable_sys($sys, 'gab', 'GAB_START', '0');
        }
        if (!$initfile_content || !defined($initfile_content->{gab}{GAB_STOP})) {
            $prod->set_initconf_variable_sys($sys, 'gab', 'GAB_STOP', '0');
        }
    }

    return 1;
}

sub include_cssdcf_to_maincf_under_new_conf {
    my($prod,$sys,$path) = @_;
    my($cssdfound,$maincf,$new_inc,$rtn,$cmd_hacf,$cprod);

    $cprod=CPIC::get('prod');
    if ($cprod!~/^SFRAC\d+/mx) {
        return 1;
    }

    $cmd_hacf= $prod->{cmd_hacf};

    unless($sys->is_dir($path)) {
        return 0;
    }

    $cssdfound = "";
    $maincf = $sys->readfile("$path/main.cf");
    $cssdfound = grep { /^\s*include\s+\"CSSD\.cf\"/mx } split(/\n/,$maincf);
    return 1 if ($cssdfound);

    return 0 unless($sys->exists("$path/CSSD.cf"));

    $new_inc = "include \"CSSD\.cf\"\n";
    $maincf = $new_inc.$maincf;
    $sys->writefile($maincf,"$path/main.cf");

    # verify effectiveness of .cf files
    $rtn = $sys->cmd("$cmd_hacf -verify $path");
    return 0 if($rtn);
    # create main.cmd for .cf files
    $sys->cmd("$cmd_hacf -cftocmd $path");
    return 1 if ($sys->exists("$path/main.cmd"));
    return 0;
}

sub poststart_sys {
    my($prod,$sys) = @_;
    return 1;
}

sub ru_prestop_sys {
    my ($prod,$sys)=@_;
    my (@procs,$proc,$procobj,$cprod,$msg);
    if (Cfg::opt('upgrade_kernelpkgs')) {
        @procs=qw(gab61 vxfen61);
        for my $proc (@procs) {
             $procobj=$sys->proc($proc);
             $procobj->prestop_sys($sys);
        }
        $cprod=CPIC::get('prod');
        if($cprod=~/^SFRAC\d+/mx){
            $procobj=$sys->proc('vcsmm61');
            $procobj->prestop_sys($sys) if($procobj);
        }
        # Check if had is stopped
        $proc='had61';
        $procobj=$sys->proc($proc);
        # Use had61::Common::check_sys because
        # on had61::SunOS::check_sys, had will be considered stopped when SMF service system/vcs not online
        if (Proc::had61::Common::check_sys($procobj,$sys,'stop')) {
            # Still running, execute hastop command
            $sys->cmd('_cmd_hastop -local -evacuate 2>/dev/null');
            if (EDR::cmdexit() != 0) {
                $msg=Msg::new("Failed to stop VCS on $sys->{sys}. Contact Symantec technical support or refer to the installation guide for further troubleshooting.");
                # Stop had failed for some reason
                $sys->push_error($msg);
                return 1;
            }
            sleep 2;
        }
    }
    return 0;
}

sub upgrade_rolling_post_sys {
    my ($prod,$sys)=@_;
    my ($msg,$cprod,$syslist,$sys1);

    $cprod=CPIC::get('prod');
    $syslist=CPIC::get('systems');
    #all systems are rolling_upgraded
    #check if post tasks are done.
    $msg=$sys->cmd('_cmd_cat /etc/gabtab');
    return unless($msg=~/V/m);
    for my $sys1 (@$syslist) {
        if($sys1->exists('/etc/gabtab.rubak')){
            $sys1->cmd('_cmd_rmr /etc/gabtab');
            $sys1->cmd('_cmd_cp -rfp /etc/gabtab.rubak /etc/gabtab 2>/dev/null');
        }
        if($sys1->exists('/etc/vcsmmtab.rubak') && $cprod=~/^SFRAC\d+/mx){
            $sys1->cmd('_cmd_rmr /etc/vcsmmtab');
            $sys1->cmd('_cmd_cp -rfp /etc/vcsmmtab.rubak /etc/vcsmmtab 2>/dev/null');
        }
        if($sys1->exists('/etc/vxfenmode.rubak')){
            $sys1->cmd('_cmd_rmr /etc/vxfenmode');
            $sys1->cmd('_cmd_cp -rfp /etc/vxfenmode.rubak /etc/vxfenmode 2>/dev/null');
        }
        if($sys1->system1){
            $sys1->cmd('_cmd_gabconfig -R ');
            $sys1->cmd('_cmd_vxfenconfig -R');
            $sys1->cmd('_cmd_vcsmmconfig -R') if ($cprod=~/^SFRAC\d+/mx);
        }
    }
    return;
}

sub stop_vcs_rollingupgrade {
    my ($prod,$sys)=@_;
    my ($cpic,$ck,$iter,$maxiters,$msg,$pids,@pids,$stop);
    $stop = $sys->cmd("$prod->{bindir}/hastop -local -evacuate");
    Msg::log('Stopping VCS for Rolling ugprade before upgrade_precheck');
    sleep 3;
    if (EDRu::isverror($stop)) {
        @pids=();
        $pids=$sys->proc_pids('bin/had');
        push @pids, @{$pids} if (@{$pids});
        $pids=$sys->proc_pids('hashadow');
        push @pids, @{$pids} if (@{$pids});
        $pids=$sys->proc_pids('bin/CmdServer');
        push @pids, @{$pids} if (@{$pids});
        $sys->kill_pids(@pids);
    }
    return;
}


sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;
    my ($maincf);

    if(Cfg::opt('upgrade_kernelpkgs')){
        $prod->ru_prestop_sys($sys);
        return 1;
    } elsif(Cfg::opt('upgrade_nonkernelpkgs')){
        if($sys->system1){
            $prod->upgrade_rolling_post_sys($sys);
            EDRu::create_flag("upgrade_rolling_post");
        } else {
            EDRu::wait_for_flag("upgrade_rolling_post");
        }
    }

    unless ($sys->{vcs_upgradeable} && $prod->upgrade_gabtab_sys($sys)){
        if($sys->system1){
            EDRu::create_flag('maincf_pre_upgrade_done');
        }
        return 0;
    }

    # set secure cluster attribute to each system
    $maincf=$sys->cmd("_cmd_cat $prod->{maincf}");
    $sys->set_value('secureclus',1) if ($maincf=~/SecureClus\s*=\s*1/mx);

    # following tasks only performed on first node
    if ($sys->system1) {
        #return 0 unless ($prod->maincf_check_obsolete_types_sys($sys));

        # freeze service group
        if (!Cfg::opt('rootpath') && !$prod->{upgrade_ignore_conf} && $sys->{prod_running}) {
            $prod->haconf_makerw();
            $prod->freeze_groups();
            $prod->haconf_dumpmakero();
        }

        # todo: support for lower version upgrade
        # todo: support other exceptions those can not handle by dynmic upgrade

        EDRu::create_flag('maincf_pre_upgrade_done');
    } else {
        EDRu::wait_for_flag('maincf_pre_upgrade_done');
    }

    return 1;
}

#In 6.1.0, vcs changed
#1. Group::Load/System::Capacity are changes from scalar integer to
#integer assoc (as multidimensional) type attributes
#2. Cluster::HostMonLogLvl is replaced by Cluster::Statistics
#So, during precheck, those conf needs to be removed and added back after dynupgrade
sub dynupgrade_pre_customize_changed_types_sys {
    my ($prod,$sys,$treeref,$upgradepath) = @_;
    my ($rtn,@grps,$attr,$attrname,$attrvalue,$result_lines,$noderef,$HostMonLogLvlValue);
    my ($syslist_ref,$sysout_ref,$cluslist_ref,$clusout_ref,$reshash_ref);

    $sys->copyfile("$upgradepath/old_config/main.cf","$upgradepath/old_config/main.cf.ori");

    # Requirement from incident 3263089. Applies only when $system is RHEL6 and OS version >=6.2
    if ($sys->{padv} =~ /^RHEL6/ && EDRu::compvers($sys->{updatelevel},'6.2') < 2) {
        # if MonitorProcesses = { "/usr/sbin/dhcpd" }, replace it with
        # MonitorProgram = "/opt/VRTSvcs/bin/utils/getServiceStatus dhcpd"
        $reshash_ref =  dynupgrade_get_branch_from_tree( $treeref, 'RES');
        for my $res_key (keys %{$reshash_ref}) {
            for my $attr_key (keys %{$reshash_ref->{$res_key}{ATTR}}) {
                if ($attr_key eq 'MonitorProcesses' &&
                @{$reshash_ref->{$res_key}->{ATTR}{$attr_key}{MODIFY}{ATTRVAL}}[0] =~ m{/usr/sbin/dhcpd}) {
                    delete $reshash_ref->{$res_key}->{ATTR}{$attr_key};
                    $result_lines .= "hares -modify $res_key MonitorProgram \"/opt/VRTSvcs/bin/utils/getServiceStatus dhcpd\"";
                }
            }
        }
    }

    # Get the Cluster::HostMonLogLvl value
    $cluslist_ref =  dynupgrade_get_branch_from_tree( $treeref, 'CLUS');
    $clusout_ref = [];
    $HostMonLogLvlValue = undef;
    for my $clus_ref (@{$cluslist_ref}) {
        if (($clus_ref->{SUBCMD} eq '-modify') &&
            ($clus_ref->{CONTENT} =~ /^\s*HostMonLogLvl\s+(\S+)\s*$/)) {
            $HostMonLogLvlValue = $1;
            next;
       }
       push (@$clusout_ref, $clus_ref);
    }
    $treeref->{CLUS} = $clusout_ref;

    # if HostMonLogLvl = DisableHMAgent, replace it with Statistics = Disabled
    if ($HostMonLogLvlValue && $HostMonLogLvlValue eq 'DisableHMAgent') {
        $result_lines .= "haclus -modify Statistics Disabled\n";
    } else {
        # if HostMonLogLvl is not found in main.cf or is NOT set to DisableHMAgent:
        # check if:
        # Group::Load is defined for some group OR
        # System::Capacity is defined for some system OR
        # Group::FailOverPolicy = Load for some group OR
        # Group::AutoStartPolicy = Load for some group
        if ($prod->dynupgrade_pre_customize_check_for_statistics_sys($sys,$treeref)) {
            $result_lines .= "haclus -modify Statistics MeterHostOnly\n";
        }
    }

    # Change the System::Capacity
    # from "Capacity = 5" to "Capacity = { Units = 5 }"
    $syslist_ref =  dynupgrade_get_branch_from_tree( $treeref, 'SYS');
    $sysout_ref = [];
    for my $sys_ref (@{$syslist_ref}) {
        if (($sys_ref->{SUBCMD} eq '-modify') &&
            ($sys_ref->{CONTENT} =~ /^\s*(\S+\s+Capacity)\s+(\S+)\s*$/)) {
            $result_lines .= "hasys -modify $1 Units $2\n";
            next;
        }
        push (@$sysout_ref, $sys_ref);
    }
    $treeref->{SYS} = $sysout_ref;

    # update Group::Load
    # from "Load = 8" to "Load = { Units = 8 }"
    @grps=dynupgrade_get_grplist($treeref);
    $attrname = "Load";
    for my $grp_name (@grps) {
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name,$attrname);
        next unless $attr;

        $attrvalue = $attr->{MODIFY}{ATTRVAL}[0];
        next unless ($attrvalue =~ /^\s*\S+\s*$/);

        $noderef= dynupgrade_get_node_from_tree( $treeref, 'GRP', $grp_name);
        delete( $noderef->{ATTR}->{$attrname} );

        $result_lines .= "hagrp -modify $grp_name $attrname Units $attrvalue\n";
    }

    # delete the AutoStartPolicy in the main.cf and add into the result_lines,
    # in order to make old main.cf verified successfully with the new hacf
    $attrname = "AutoStartPolicy";
    for my $grp_name (@grps) {
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name,$attrname);
        next unless $attr;

        $attrvalue = $attr->{MODIFY}{ATTRVAL}[0];
        next unless ($attrvalue eq "Load");

        $noderef= dynupgrade_get_node_from_tree( $treeref, 'GRP', $grp_name);
        delete( $noderef->{ATTR}->{$attrname} );

        $result_lines .= "hagrp -modify $grp_name $attrname $attrvalue\n";
    }

    # delete the FailOverPolicy in the main.cf and add into the result_lines,
    # in order to make old main.cf verified successfully with the new hacf
    $attrname = "FailOverPolicy";
    for my $grp_name (@grps) {
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name,$attrname);
        next unless $attr;

        $attrvalue = $attr->{MODIFY}{ATTRVAL}[0];
        next unless ($attrvalue eq "Load");

        $noderef= dynupgrade_get_node_from_tree( $treeref, 'GRP', $grp_name);
        delete( $noderef->{ATTR}->{$attrname} );

        $result_lines .= "hagrp -modify $grp_name $attrname $attrvalue\n";
    }

    return 1 unless $result_lines;
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines;
        $sys->set_value('dyn_manual_cmd_lu', $result_lines);
    } else {
        $sys->set_value('maincf_upgrade,30_customize_changed_types', $result_lines);
    }

    return 1;
}

# Check if
# 0.Statistics = MeterHostOnly NOT defined in cluster
# 1.Group::Load is defined for some group
# 2.System::Capacity is defined for some system
# 3.Group::FailOverPolicy = Load for some group
# 4.Group::AutoStartPolicy = Load for some group
sub dynupgrade_pre_customize_check_for_statistics_sys {
    my ($prod,$sys,$treeref) = @_;
    my ($cluslist_ref,@grps,$attr,$attrname,$attrvalue,$syslist_ref);
    
    $cluslist_ref=dynupgrade_get_branch_from_tree($treeref, 'CLUS');
    for my $clus_ref (@{$cluslist_ref}) {
        if (($clus_ref->{SUBCMD} eq '-modify') &&
            ($clus_ref->{CONTENT} =~ /^\s*Statistics\s+MeterHostOnly\s*$/)) {
            return 0;
        }
    }
    # check if Group::Load is defined for some group
    @grps=dynupgrade_get_grplist($treeref);
    $attrname = "Load";
    for my $grp_name (@grps) {
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name,$attrname);
        return 1 if $attr;
    }

    # check if System::Capacity is defined for some system
    $syslist_ref =  dynupgrade_get_branch_from_tree( $treeref, 'SYS');
    for my $sys_ref (@{$syslist_ref}) {
        return 1 if ($sys_ref->{CONTENT} =~ /^\s*\S+\s+Capacity\s+\S+\s*$/);
    }

    # check if Group::FailOverPolicy = Load for some group
    $attrname = "FailOverPolicy";
    for my $grp_name (@grps) {
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name,$attrname);
        next unless $attr;

        $attrvalue = $attr->{MODIFY}{ATTRVAL}[0];
        return 1 if ($attrvalue eq "Load");
    }

    # check if Group::AutoStartPolicy = Load for some group
    $attrname = "AutoStartPolicy";
    for my $grp_name (@grps) {
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name,$attrname);
        next unless $attr;

        $attrvalue = $attr->{MODIFY}{ATTRVAL}[0];
        return 1 if ($attrvalue eq "Load");
    }

    return 0;
}

sub dynupgrade_pre_upgrade_sys {
    my ($prod,$sys,$vcsvers) = @_;
    my ($rootpath,$msg,$uuid,$upgradepath,$rtn,$maincf);
    my ($cpic,$rel);
    $cpic = Obj::cpic();
    $rel = Obj::rel();

    $rootpath=Cfg::opt('rootpath');
    $upgradepath= EDR::tmpdir().'/upgrade';
    $uuid=EDR::get('uuid');
    # below steps will ensure the old config files to be available

    # Pre Step 1- backup old cf files
    $sys->cmd("_cmd_rmr $upgradepath");

    $rtn = $prod->backup_cf_files_sys($sys, "$rootpath$prod->{configdir}", "$upgradepath/old_config");
    return 0 unless ($rtn);

    $rtn = $prod->backup_cf_files_sys($sys, "$rootpath$prod->{confdir}", "$upgradepath/old_conf");
    return 0 unless ($rtn);

    $msg = Msg::new("\nFailed to upgrade because the system configuration files are not available\n");

    # Pre Step 2- create cmd files for old user config
    if ($rootpath) {
        $maincf=$sys->readfile("$rootpath$prod->{configdir}/main.cf");
        $sys->cmd("_cmd_mv $rootpath$prod->{configdir}/main.cf $rootpath$prod->{configdir}/main.cf.$uuid");
        $maincf=~s/\s*include\s+\"(\/\S+)\"/\ninclude \"$rootpath$1\"/g;
        $sys->writefile($maincf,"$rootpath$prod->{configdir}/main.cf");
    }

    # Check if main.cf exist, if not exist, print warning and do not translate any configuration.
    unless ($sys->exists($prod->{maincf})) {
        $msg = Msg::new("The main.cf file does not exist on $sys->{sys}");
        $sys->push_warning($msg);
        $cpic->set_value('prod_not_running_before_upgrade',1);
        return 0;
    }

    # Verify if main.cf is valid before upgrade.
    $rtn= $sys->cmd("$prod->{cmd_hacf} -verify $rootpath$prod->{configdir}");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("The main.cf file is not valid:\n$rtn\nFix the errors, and verify the main.cf file before upgrade by running \'$prod->{cmd_hacf} -verify $rootpath$prod->{configdir}\'");
        $sys->push_error($msg);
        return 0;
    }

    $rtn = $prod->translate_file_cf2cmd_sys( $sys, "$rootpath$prod->{configdir}", 1);
    $sys->cmd("_cmd_mv $rootpath$prod->{configdir}/main.cf.$uuid $rootpath$prod->{configdir}/main.cf") if ($rootpath);
    unless($rtn) {
        $sys->push_error($msg);
        return 0;
    }

    # SFRAC needs to save the old cssd resource name if have, before RU2 starts.
    if ($cpic->{prod} =~ /^SFRAC\d+/mx && !$rel->{old_cssd_resource_name}) {
        my $old_cssd_resource_name = $sys->cmd("_cmd_grep 'cssd-monitor' $rootpath$prod->{configdir}/main.cmd | _cmd_awk '{print \$3}'");
        if ($old_cssd_resource_name) {
            $rel->set_value('old_cssd_resource_name',$old_cssd_resource_name);
        }
    }

    # Fix 2026573.
    $prod->padv_mend_old_cf_sys($sys, "$upgradepath/old_config");
    $prod->padv_mend_old_cf_sys($sys, "$upgradepath/old_conf");

    # Pre Step 3- create cmd files for old sys conf
    $rtn = $prod->translate_file_cf2cmd_sys( $sys, "$upgradepath/old_conf");
    unless($rtn) {
        $sys->push_error($msg);
        return 0;
    }

    return 1;
}

sub dynupgrade_upgrade_sys {
    my ($prod,$sys) = @_;
    my ($msg,$lines_ref,$syslist,$rtn,$localsys);
    my $rootpath=Cfg::opt('rootpath');
    my $upgradepath = EDR::tmpdir().'/upgrade';
    my ($treeref_oldsys, $treeref_olduser, $treeref_newsys, $treeref_result, $treeref_custom, $deleted_attrs_ref, $typename);
    my ($msgcssd);
    $syslist=CPIC::get('systems');
    # below process steps will ensure to create the result cmd list file after upgrade

    # Post Step 1- backup new system cf files
    $rtn = $prod->backup_cf_files_sys( $sys, "$rootpath$prod->{confdir}", "$upgradepath/new_conf");
    return 0 unless ($rtn);

    # Post Step 2- create cmd files
    $msg = Msg::new("Failed to upgrade because the system configuration files are not available");
    # for new sys conf
    $rtn = $prod->translate_file_cf2cmd_sys( $sys, "$upgradepath/new_conf");
    unless($rtn) {
        $sys->push_error($msg);
        return 0;
    }

    # When adding new type such as CSSD.cf, in the main.cf under the $upgradepath/new_conf, there is no "include CSSD.cf", adding it here.
    $msgcssd = Msg::new("Failed to include the CSSD type to the main.cf");
    $rtn = $prod->include_cssdcf_to_maincf_under_new_conf($sys,"$upgradepath/new_conf");
    unless($rtn) {
        $sys->push_error($msgcssd);
        return 0;
    }

    # for old sys conf
    $rtn = $prod->translate_file_cf2cmd_sys( $sys, "$upgradepath/old_conf");
    unless($rtn) {
        $sys->push_error($msg);
        return 0;
    }
    # old user config
    # delete the UseFence from the main.cf
    $prod->modify_maincf_for_lgf_onenode($sys,"$upgradepath/old_config/main.cf");
    $rtn = $prod->translate_file_cf2cmd_sys( $sys, "$upgradepath/old_config", 1);
    unless($rtn) {
        $sys->push_error($msg);
        return 0;
    }

    # Post Step 3- create the result directory
    $sys->cmd("_cmd_mkdir -p $upgradepath/result_config");

    # calculate cmd list files existed
    unless ( $sys->exists("$upgradepath/old_config/main.cmd" ) &&
        $sys->exists("$upgradepath/old_conf/main.cmd" ) &&
        $sys->exists("$upgradepath/new_conf/main.cmd" ) ) {

        $msg = Msg::new("Dynamic upgrade failed because required configuration files are not available");
        $sys->push_warning($msg);
        return 0;
    }

    # Post Step 4- load cmd list files
    $treeref_oldsys = dynupgrade_import_file2tree_sys( $sys, "$upgradepath/old_conf/main.cmd");
    $lines_ref = dynupgrade_import_file2lines_sys($sys, "$upgradepath/old_config/main.cmd");
    # update extra configuration
    $lines_ref = $prod->maincf_upgrade_sys($sys,$lines_ref);

    $treeref_olduser= dynupgrade_import_lines2tree($lines_ref);
    $treeref_newsys = dynupgrade_import_file2tree_sys( $sys, "$upgradepath/new_conf/main.cmd");

    # Post Step 5- find customized list
    $deleted_attrs_ref= dynupgrade_get_removed_attrs( $treeref_oldsys, $treeref_newsys );
    $treeref_custom= dynupgrade_minus_trees( $treeref_olduser, $treeref_oldsys);
    dynupgrade_export_tree2file_sys( $sys, "$upgradepath/result_config/custom.cmd", $treeref_custom);

    # Post Step 6- merge the cumstomized change list into the new system tree
    $treeref_result= dynupgrade_merge_trees_A_over_B( $treeref_custom, $treeref_newsys);

    # Post Step 7- delete obsolete types and validate result tree
    for my $typename (@{$prod->{deleted_agents}}) {
        delete ($treeref_result->{TYPE}->{$typename}) if (defined($treeref_result->{TYPE}->{$typename}));
    }
    for my $typename (keys %{$prod->{rename_attrs}}) {
        for my $attr (keys %{$prod->{rename_attrs}->{$typename}}) {
            dynupgrade_rename_attr_name($treeref_result, $typename, $attr, $prod->{rename_attrs}->{$typename}->{$attr});
        }
    }
    # Customized update the result tree.
    # Only update the configurations that required the new configuration files.
    $treeref_result = $prod->maincf_result_upgrade_sys($sys, $treeref_result, $treeref_newsys);

    $treeref_result = dynupgrade_validate_tree( $treeref_result, $deleted_attrs_ref);

    # Change sourcefile to original values.
    for my $group (sort keys %{$sys->{maincf_sourcefile_GRP}}) {
        my $sourcefile = $sys->{maincf_sourcefile_GRP}{$group};
        dynupgrade_set_sourcefile(
            $treeref_result,'GRP',$group,"\"$sourcefile\"");
    }
    for my $typename (sort keys %{$sys->{maincf_sourcefile_TYPE}}) {
        my $sourcefile = $sys->{maincf_sourcefile_TYPE}{$typename};
        dynupgrade_set_sourcefile(
            $treeref_result,'TYPE',$typename,"\"$sourcefile\"");
    }

    # Post Step 8- export tree into file
    dynupgrade_export_tree2file_sys( $sys, "$upgradepath/result_config/main.cmd", $treeref_result);

    $localsys=$prod->localsys;
    if( $sys->exists("$upgradepath/result_config/main.cmd" ) ) {
        # distribute updated *.cf to each node
        unless ($sys->{islocal}) {
            EDR::cmd_local("_cmd_mkdir -p $upgradepath/result_config");
            $sys->copy_to_sys($localsys,"$upgradepath/result_config/main.cmd");
        }
        # put the new main.cmd into the log
        $sys->cmd("_cmd_cat $upgradepath/result_config/main.cmd");

        for my $sys (@$syslist) {
            $localsys->copy_to_sys($sys,"$upgradepath/result_config/main.cmd","$rootpath$prod->{configdir}/main.cmd");
            # create the .cf files based on the command list
            my $ret= $prod->translate_file_cmd2cf_sys( $sys, "$rootpath$prod->{configdir}",1);
            unless( $ret) {
                $msg = Msg::new("Dynamic upgrade failed because the configuration files are not valid");
                $sys->push_warning($msg);
                return 0;
            }

            # Remove $rootpath from main.cf
            if ($rootpath) {
                my $maincf=$sys->readfile("$rootpath$prod->{configdir}/main.cf");
                $maincf=~s/\s*include\s+\"$rootpath(\/\S+)\"/\ninclude \"$1\"/g;
                $sys->writefile($maincf,"$rootpath$prod->{configdir}/main.cf");
            }

            if ($sys->system1) {
                # put the new main.cf into the log
                $sys->cmd("_cmd_cat $rootpath$prod->{configdir}/main.cf");
            }
            $sys->cmd("_cmd_rmr $rootpath$prod->{configdir}/main.cmd");
        }
    } else {
        $msg = Msg::new("Dynamic upgrade failed because main.cmd is not available");
        $sys->push_warning($msg);
        return 0;
    }

    # Copy nfs_postoffline during upgrade.
    # But in 5.1SP1, the nfs related triggers will be moved back, so detete the copy
#    my @reslist= dynupgrade_get_resname_list_from_typename( $treeref_result, "NFSRestart" );
#    if (@reslist) {
#        Msg::log("There is NFSRestart resource in main.cf; Copy nfs_postoffline from /opt/VRTSvcs/bin/sample_triggers to /opt/VRTSvcs/bin/triggers.");
#        for $sys(@{$cpic->{systems}}) {
#            if ($sys->exists("$rootpath/opt/VRTSvcs/bin/sample_triggers/nfs_postoffline")) {
#                $sys->cmd("_cmd_mkdir -p $rootpath/opt/VRTSvcs/bin/triggers");
#                $sys->cmd("_cmd_cp $rootpath/opt/VRTSvcs/bin/sample_triggers/nfs_postoffline $rootpath/opt/VRTSvcs/bin/triggers/");
#            }
#        }
#    }

    return 1;
}

# restore extra informations for main.cf upgrade
sub maincf_upgrade_sys {
    my ($prod,$sys,$lines_ref) = @_;
    my ($unfreeze_sg,$grp,$line,$category);

    # Update attributes StartVolumes and StopVolumes
    for my $line (@{$lines_ref}) {
        if ($line=~/(hares\s+\-modify\s+\w+\s+(Start|Stop)Volumes)\s+(?!1\b)/mx) {
            Msg::log("Modify main.cmd from: $line");
            $line="$1 0";
            Msg::log("                  To: $line");
        }
        if ($line=~/(haattr\s+\-add\s+DiskGroup\s+(Start|Stop)Volumes)\s+\-string\s+(\S+)/mx) {
            Msg::log("Modify main.cmd from: $line");
            $line=($3 eq '1') ? "$1 -boolean 1" : "$1 -boolean 0";
            Msg::log("                  To: $line");
        }
    }

    # unfreeze service group
    unless (Cfg::opt('rootpath')) {
        for my $grp (@{$sys->{frozen_grps}}) {
            $unfreeze_sg="hagrp -modify $grp Frozen 0";
            $sys->set_value("maincf_upgrade,20_unfreeze_$grp", $unfreeze_sg);
        }
    }

    for my $category (sort keys %{$sys->{maincf_upgrade}}) {
        next unless ($sys->{maincf_upgrade}{$category});
        push(@{$lines_ref},split(/\n+/,$sys->{maincf_upgrade}{$category}));
        Msg::log("Upgrade main.cmd for user configuration: $sys->{maincf_upgrade}{$category}\n");
    }
    return $lines_ref;
}

# This sub is used for upgrade the main.cmd based on the new configuration files.
sub maincf_result_upgrade_sys {
    my ($prod,$sys,$treeref_result,$treeref_newsys) = @_;

    # Update NFSRestart ResRecord
    $treeref_result = maincf_result_upgrade_NFSRestart($sys,$treeref_result);

    # Update Oracle resource
    $treeref_result = $prod->maincf_result_upgrade_Oracle_sys($sys, $treeref_result);

    # Update Sybase resource
    $treeref_result = $prod->maincf_result_upgrade_Sybase_sys($sys, $treeref_result);

    # Update Apache resource
    $treeref_result = $prod->maincf_result_upgrade_Apache_sys($sys, $treeref_result);

    # Update vip* service groups
    $treeref_result = $prod->maincf_result_upgrade_vip_sys($sys, $treeref_result);

    # Update TriggersEnabled for all service groups
    $treeref_result = $prod->maincf_result_upgrade_TriggersEnabled_sys($sys, $treeref_result);

    # Update cp agent service group
    $treeref_result = $prod->maincf_result_upgrade_cpagent_sys($sys, $treeref_result);

    # Remove cp agent if not start llt/gab
    $treeref_result = $prod->maincf_result_upgrade_remove_cpagent_sys($sys, $treeref_result);

    # Update cssd resource
    $treeref_result = $prod->maincf_result_upgrade_cssd_sys($sys, $treeref_result);

    # update containrization settings.
    $treeref_result = $prod->padv_maincf_upgrade_sys($sys, $treeref_result, $treeref_newsys) if ($prod->can('padv_maincf_upgrade_sys'));

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the requirment updates will be in doc, and printed as not to user during upgrade
    $prod->dynupgrade_print_manual_steps_lu($sys) if Cfg::opt('rootpath') && $sys->{osupgraded};

    dynupgrade_modify_attr_value($treeref_result,'Sybase','Monscript','/opt/VRTSvcs/bin/Sybase/SqlTest.pl','/opt/VRTSagents/ha/bin/Sybase/SqlTest.pl');

    dynupgrade_update_IMF($sys,$treeref_result);
    return $treeref_result;
}

sub dynupgrade_print_manual_steps_lu {
    my ($prod,$sys) = @_;
    my ($msg,$cmds);

    if ($sys->{dyn_manual_cmd_lu}) {
        $msg = Msg::new("Because the OS is updated during live upgrade, the cluster configurations need to be manually updated after the cluster is started from the ABE. Refer to following commands:\n\n");
        $cmds = "haconf -makerw\n$sys->{dyn_manual_cmd_lu}haconf -dump -makero\n";
        $cmds =~ s{^\s*ha}{/opt/VRTSvcs/bin/ha}gm;
        $msg->{msg} .= $cmds;
        $sys->push_note($msg);
    }
    return 1;
}

sub dynupgrade_update_IMF {
    my ($sys,$treeref_result) = @_;
    my ($imf,@lines,$rtn);

    # Change the IMF mode for CVMVxconfigd agent to 2
    $rtn = dynupgrade_get_attrvalue_of_typename($treeref_result,"CVMVxconfigd","IMF");
    if ($rtn) {
        $rtn =~ s/Mode\s+\d+\s*(.*)/Mode 2 $1/;
        $imf = "hatype -modify CVMVxconfigd IMF $rtn\n";
    }

    # Change the IMF mode for CFSMount and CFSfsckd agents to 3
    $rtn = dynupgrade_get_attrvalue_of_typename($treeref_result,"CFSMount","IMF");
    if ($rtn) {
        $rtn =~ s/Mode\s+\d+\s*(.*)/Mode 3 $1/;
        $imf .= "hatype -modify CFSMount IMF $rtn\n";
    }
    $rtn = dynupgrade_get_attrvalue_of_typename($treeref_result,"CFSfsckd","IMF");
    if ($rtn) {
        $rtn =~ s/Mode\s+\d+\s*(.*)/Mode 3 $1/;
        $imf .= "hatype -modify CFSfsckd IMF $rtn\n";
    }

    if ($imf) {
        @lines= split(/\n+/, $imf);
        $treeref_result= dynupgrade_import_lines2tree(\@lines,$treeref_result);
    }
    return $treeref_result;
}


#####################
# add modify old cssd resource type Application as the new cssd CSSD resource
sub maincf_result_upgrade_cssd_sys {
    my ($prod,$sys,$treeref) = @_;
    my ($cssd_group_name,@reslist,$res_group_name,$res_ref,$result_lines,$num,$cmdref,$msg,$crshome);
    my (@cssd_child,$cprod,$rel,$old_cssd_resource_name);

    $cprod=CPIC::get('prod');
    if ($cprod!~/^SFRAC\d+/mx) {
        return $treeref;
    }

    $rel = Obj::rel();
    if ($rel->{old_cssd_resource_name}) {
        $old_cssd_resource_name = $rel->{old_cssd_resource_name};
    }

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'Application');
    for my $res (@reslist) {
        if ($res eq $old_cssd_resource_name) {
            $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
            $cssd_group_name = $res_ref->{MAIN}->{SERVGRP};
            @cssd_child=();
            for my $link_ref (@{$treeref->{RESLINK}->{RESLINK}->{RESLINK}}){
                next unless $link_ref->{RESPARENT} eq $res;
                $result_lines .= "hares -unlink $link_ref->{RESPARENT} $link_ref->{RESCHILD}\n";
                push @cssd_child,  $link_ref->{RESCHILD};
            }
            $result_lines .= "hares -delete $res\n";
            last;
        }
    }

    if ($cssd_group_name) {
        $result_lines .= "hares -add $old_cssd_resource_name CSSD $cssd_group_name\n";
        $result_lines .= "hares -modify $old_cssd_resource_name Critical 0\n";
        $crshome = $prod->upgrade_get_old_crs_home($sys);
        if($crshome){
            $result_lines .= "hares -modify $old_cssd_resource_name CRSHOME $crshome\n";
        }else{
            $msg=Msg::new("The CRSHOME attribute of the new CSSD agent cssd is not set. Symantec recommends that you reconfigure the new cssd agent after completing the upgrade.");
            $sys->push_note($msg);
        }
        for my $name_child (@cssd_child) {
            $result_lines .= "hares -link $old_cssd_resource_name $name_child\n";
        }
        $result_lines .= "hares -modify $old_cssd_resource_name Enabled 1\n";
    }

    if ($result_lines) {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }
    return $treeref;
}

sub upgrade_get_old_crs_home {
    my ($prod,$sys) = @_;
    my ($crshome_line,$crshome,$crsinitdir);

    if ($sys->exists("$prod->{initdir}/init.ohasd")) {
        $crsinitdir = "$prod->{initdir}/init.ohasd";
    } else {
        $crsinitdir = "$prod->{initdir}/init.crsd";
    }
    $crshome_line = $sys->cmd("_cmd_grep 'ORA_CRS_HOME=' $crsinitdir 2>/dev/null");
    chomp $crshome_line;
    if ($crshome_line=~/^\s*ORA_CRS_HOME\s*=\s*([^#\n]*)/m) {
        $crshome=$1;
        $crshome=~s/\s*$//;
    } else {
        $crshome='';
    }
    Msg::log("Cannot get the ORACLE_CRS_HOME") unless($crshome);
    return $crshome;
}

# modify cp agent service group if needed
# add Phantom resource if cp agent servie group doesn't have Phantom resource
sub maincf_result_upgrade_cpagent_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@cpgrplist,@grplist,@reslist,$attr_ref_in,$res_group_name,$res_ref,$result_lines);

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'CoordPoint');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $res_group_name = $res_ref->{MAIN}->{SERVGRP};
        push (@cpgrplist,$res_group_name);
        # add LevelTwoMonitorFreq since 6.0.1
        # Only if coordinator disk exists
        $attr_ref_in = dynupgrade_get_attr_from_node($res_ref,'LevelTwoMonitorFreq');
        unless ($attr_ref_in) {
            if ($sys->{vxfen_conf}{vxfendg}) {
                $result_lines .= "hares -override $res LevelTwoMonitorFreq\n";
                $result_lines .= "hares -modify $res LevelTwoMonitorFreq 5\n";
            }
        }
    }
    @cpgrplist = @{EDRu::arruniq(@cpgrplist)};
    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'Phantom');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $res_group_name = $res_ref->{MAIN}->{SERVGRP};
        push (@grplist,$res_group_name);
    }
    @grplist = @{EDRu::arruniq(@grplist)};
    # get the cp agent group that doesn't have phantom resource
    @cpgrplist = @{EDRu::arrdel(\@cpgrplist,@grplist)};

    for my $cpagentgrp(@cpgrplist) {
        $result_lines .= "hares -add RES_phantom_$cpagentgrp Phantom $cpagentgrp\n";
        $result_lines .= "hares -modify RES_phantom_$cpagentgrp Enabled 1\n";
    }
    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }
    return $treeref;
}

# if users choose no to start llt/gab when upgrade, remove cpagent
sub maincf_result_upgrade_remove_cpagent_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@cpgrplist,@reslist,$res_group_name,$res_ref,$result_lines,$cfg);

    # if users choose to start llt/gab, should not remove cpagent
    $cfg = Obj::cfg();
    return $treeref if ($cfg->{vcs_allowcomms});

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'CoordPoint');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $res_group_name = $res_ref->{MAIN}->{SERVGRP};
        push (@cpgrplist,$res_group_name);
        $result_lines .= "hares -delete $res\n";
    }

    @cpgrplist = @{EDRu::arruniq(@cpgrplist)};
    for my $cpagentgrp(@cpgrplist) {
        $result_lines .= "hagrp -delete $cpagentgrp\n";
    }

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }

    return $treeref;
}

# modify all service groups with the name vip*
# add TriggerPath
# add TriggersEnabled
# this is only applicable for upgrade from prior 6.0 to 6.0 or onwards
# before 5.1, the PreOnline is not per sys, this has been took care by maincf_preonline_precheck_sys
sub maincf_result_upgrade_vip_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@grps,$attr,$attr_values,$result_lines,@systems,$sys_name,@systems_TriEn,$tri_path);
    my ($cprod_name);

    return $treeref unless $sys->{update_vip_sgs};

    # this will only be done for prods with VRTScavf
    $cprod_name=CPIC::get('prod');
    return $treeref if ($cprod_name =~ /^(VCS|SFHA)\d+$/);

    @grps=dynupgrade_get_grplist($treeref);
    $tri_path = '"bin/cavftriggers/vip"';
    for my $grp_name (@grps) {
        # set TriggerPath if not exist
        next unless ($grp_name =~ /^vip/);
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name, 'TriggerPath');
        unless ($attr && ($attr->{MODIFY}{ATTRVAL}[0] eq /$tri_path/)) {
            $result_lines .= "hagrp -modify $grp_name TriggerPath $tri_path\n";
        }

        # get the sys list that already have TriggersEnabled
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name, 'TriggersEnabled');
        $attr_values = $attr->{MODIFY}->{ATTRVAL};
        @systems_TriEn = ();
        for my $attr_value (@$attr_values) {
            if ($attr_value =~ /-sys\s+(.+)/) {
                $sys_name = $1;
                push(@systems_TriEn,$sys_name);
            }
        }

        # get sys list that have PreOnline
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name, 'PreOnline');
        $attr_values = $attr->{MODIFY}->{ATTRVAL};
        for my $attr_value (@$attr_values) {
            if ($attr_value =~ /-sys\s+(.+)/) {
                $sys_name = $1;
                next if EDRu::inarr($sys_name,@systems_TriEn);
                $result_lines .= "hagrp -modify $grp_name TriggersEnabled PREONLINE POSTONLINE POSTOFFLINE -sys $sys_name\n";
            }
        }
    }

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }
    return $treeref;
}

# update the TriggersEnabled attr for ALL SGs: e2567387
# If no PreOnline: add POSTONLINE POSTOFFLINE triggers for them
# If ye PreOnline: add PreOnline
# this is only applicable for upgrade from prior 6.0 to now
sub maincf_result_upgrade_TriggersEnabled_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@grps,$attr,$attr_values,$result_lines,$sys_name,@systems_TriEn,@systems_PreOnline);
    my (@grp_syslist);

    return $treeref unless $sys->{upgrade_TriggersEnabled};

    @grps=dynupgrade_get_grplist($treeref);
    # get the sys list that already have TriggersEnabled
    for my $grp_name (@grps) {
        @grp_syslist = Prod::VCS61::Common::dynupgrade_get_systemlist_of_grpname($treeref,$grp_name);

        # get the sys list that already have TriggersEnabled
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name, 'TriggersEnabled');
        $attr_values = $attr->{MODIFY}->{ATTRVAL};
        @systems_TriEn = ();
        for my $attr_value (@$attr_values) {
            if ($attr_value =~ /-sys\s+(.+)/) {
                $sys_name = $1;
                push(@systems_TriEn,$sys_name) unless (EDRu::inarr($sys_name,@systems_TriEn));
            }
        }

        # get sys list that have PreOnline
        $attr = dynupgrade_get_attr_from_tree($treeref, 'GRP', $grp_name, 'PreOnline');
        $attr_values = $attr->{MODIFY}->{ATTRVAL};
        @systems_PreOnline = ();
        for my $attr_value (@$attr_values) {
            if ($attr_value =~ /-sys\s+(.+)/) {
                $sys_name = $1;
                push(@systems_PreOnline,$sys_name) unless (EDRu::inarr($sys_name,@systems_PreOnline));
            }
        }

        for my $sysname (@grp_syslist) {
            unless (EDRu::inarr($sysname,@systems_TriEn)) {
                if (EDRu::inarr($sysname,@systems_PreOnline)) {
                    $result_lines .= "hagrp -modify $grp_name TriggersEnabled PREONLINE POSTONLINE POSTOFFLINE -sys $sysname\n";
                } else {
                    $result_lines .= "hagrp -modify $grp_name TriggersEnabled POSTONLINE POSTOFFLINE -sys $sysname\n";
                }
            }
        }
    }

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }
    return $treeref;
}

# update the Oracle and Netlsnr resource when upgrade
# for Oracle, if LevelTwoMonitorFreq exist, set it to 0 if DetailMonitor is 0
#             if LevelTwoMonitorFreq not exist, set it as the DetailMonitor
#             and remove type DetailMonitor(do not do this, only delete from resource)
# for Netlsnr, just override LevelTwoMonitorFreq attr and set it to 1.
# this applies to all upgrade path
sub maincf_result_upgrade_Oracle_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@reslist,$res,$res_ref,$attr_ref,$attr_ref_in,$attr_value);
    my ($result_lines,$rtn);

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'Oracle');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attr_ref = dynupgrade_get_attr_from_node($res_ref,'DetailMonitor');
        $attr_ref_in = dynupgrade_get_attr_from_node($res_ref,'LevelTwoMonitorFreq');
        if ($attr_ref_in) {
            if ( $attr_ref ) {
                $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0];
                $result_lines .= "hares -modify $res LevelTwoMonitorFreq 0\n" if ($attr_value == 0);
                delete( $res_ref->{ATTR}->{DetailMonitor});
            }
        } else {
            if ( $attr_ref ) {
                $result_lines .= "hares -override $res LevelTwoMonitorFreq\n";
                $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0];
                $result_lines .= "hares -modify $res LevelTwoMonitorFreq $attr_value\n";
                delete( $res_ref->{ATTR}->{DetailMonitor});
            }
        }

        # for each Oracle resource, modify MonitorOption attribute and set its value to 0
        $attr_ref = dynupgrade_get_attr_from_node($res_ref,'MonitorOption');
        if ($attr_ref) {
            $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0];
            $result_lines .= "hares -modify $res MonitorOption 0\n" unless ($attr_value == 0);
        }
    }

#    $rtn = dynupgrade_get_attrvalue_of_typename($treeref,'Oracle','ArgList');
#    if ($rtn =~ /\bDetailMonitor\b/) {
#        $rtn =~ s/\bDetailMonitor\b//;
#        $result_lines .= "hatype -modify Oracle ArgList $rtn\n";
#        $rtn = dynupgrade_get_attr_from_tree($treeref, 'TYPE', 'Oracle', 'DetailMonitor');
#        $result_lines .= "haattr -delete Oracle DetailMonitor\n" if $rtn;
#    }

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'Netlsnr');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attr_ref = dynupgrade_get_attr_from_node($res_ref,'LevelTwoMonitorFreq');
        next if $attr_ref;
        $result_lines .= "hares -override $res LevelTwoMonitorFreq\n";
        $result_lines .= "hares -modify $res LevelTwoMonitorFreq 1\n";
    }

    # for each ASMInst resource, modify MonitorOption attribute and set its value to 0
    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'ASMInst');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attr_ref = dynupgrade_get_attr_from_node($res_ref,'MonitorOption');
        if ($attr_ref) {
            $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0];
            $result_lines .= "hares -modify $res MonitorOption 0\n" unless ($attr_value == 0);
        }
    }

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }
    return $treeref;
}

# update the Sybase resource when upgrade, DetailMonitor is obsoleted
# for Sybase, if LevelTwoMonitorFreq exist, set it to 0 if DetailMonitor is 0
#             if LevelTwoMonitorFreq not exist, set it as the DetailMonitor
#             and remove type DetailMonitor(do not do this, only delete from resource)
# this applies to all upgrade path
sub maincf_result_upgrade_Sybase_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@reslist,$res,$res_ref,$attr_ref,$attr_ref_in,$attr_value);
    my ($result_lines);

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'Sybase');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attr_ref = dynupgrade_get_attr_from_node($res_ref,'DetailMonitor');
        $attr_ref_in = dynupgrade_get_attr_from_node($res_ref,'LevelTwoMonitorFreq');
        if ($attr_ref_in) {
            if ( $attr_ref ) {
                $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0];
                $result_lines .= "hares -modify $res LevelTwoMonitorFreq 0\n" if ($attr_value == 0);
                delete( $res_ref->{ATTR}->{DetailMonitor});
            }
        } else {
            $result_lines .= "hares -override $res LevelTwoMonitorFreq\n";
            if ( $attr_ref ) {
                $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0];
                $result_lines .= "hares -modify $res LevelTwoMonitorFreq $attr_value\n";
                delete( $res_ref->{ATTR}->{DetailMonitor});
            } else {
                $result_lines .= "hares -modify $res LevelTwoMonitorFreq 0\n";
            }
        }
    }

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }
    return $treeref;
}

# update the Apache resource when upgrade
# for Apache, if  SecondLevelMonitor == 1, then override LevelTwoMonitorFreq and set LevelTwoMonitorFreq = 1
# also, set SecondLevelMonitor = 0
# this applies to all upgrade path
sub maincf_result_upgrade_Apache_sys {
    my ($prod,$sys,$treeref) = @_;
    my (@reslist,$res,$res_ref,$attr_ref,$attr_ref_in,$attr_value);
    my ($result_lines,$rtn);

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'Apache');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $attr_ref = dynupgrade_get_attr_from_node($res_ref,'SecondLevelMonitor');
        $attr_value = $attr_ref->{MODIFY}->{ATTRVAL}->[0] if ($attr_ref);
        return $treeref if (!$attr_ref || !$attr_value);

        # set the SecondLevelMonitor 0
        $result_lines .= "hares -modify $res SecondLevelMonitor 0\n";

        $attr_ref_in = dynupgrade_get_attr_from_node($res_ref,'LevelTwoMonitorFreq');
        $result_lines .= "hares -override $res LevelTwoMonitorFreq\n" if (!$attr_ref_in);
        $result_lines .= "hares -modify $res LevelTwoMonitorFreq 1\n";

    }

    # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
    # so the cmds will be print to user
    if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
        $sys->{dyn_manual_cmd_lu} .= $result_lines if $result_lines;
    } else {
        my @lines= split(/\n+/, $result_lines);
        $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    }

    return $treeref;
}

# update the NFSRestart related resources when dynupgrade:
# 1. Insert a new res NFSRestart_l into res_grps which already have NFSRestart res, new res is the same as old except Lower attr
# 2. If these groups have Share share_res, change require relation: share_res -> [child] to share_res -> NFSRestart_l -> [child].
sub maincf_result_upgrade_NFSRestart {
    my ($sys,$treeref) = @_;
    my (@reslist,@NFSRestart_groups,$res,$result_lines,$res_ref,$res_group_name,$attr,$attr_ref,$res_added);
    my (@share_reslist,$share_res,$share_res_ref,@mount_reslist,$mount_res_ref);
    my ($rootpath,$newfolder);

    # this task should only be done during upgrade from less than 5.1.100
    return $treeref unless $sys->{update_NFSRestart};

    $rootpath = Cfg::opt('rootpath');
    $newfolder = "$rootpath/var/VRTSvcs/lock/volatile";
    $sys->cmd("_cmd_mkdir -p $newfolder 2>/dev/null");

    @reslist = dynupgrade_get_resname_list_from_typename($treeref,'NFSRestart');
    for my $res (@reslist) {
        $res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$res);
        $res_group_name = $res_ref->{MAIN}->{SERVGRP};
        next if EDRu::inarr($res_group_name,@NFSRestart_groups);
        push(@NFSRestart_groups, $res_group_name);
        # in case it is updated during previous upgrade
        next if dynupgrade_get_node_from_tree($treeref,'RES',"NFSRestart_L_$res_group_name");
        $res_added = 0;

        #update the "require relations"
        @share_reslist = dynupgrade_get_resname_list_from_typename($treeref,'Share');
        for my $share_res (@share_reslist){
            $share_res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$share_res);
            next unless $share_res_ref->{MAIN}->{SERVGRP} eq $res_group_name;

            unless ($res_added) {
                #add another NFSRestart resource
                $result_lines .= "hares -add NFSRestart_L_$res_group_name NFSRestart $res_group_name\n";

                #copy resouce attributes
                for my $attr (keys %{$res_ref->{ATTR}}){
                    $attr_ref = dynupgrade_get_node_from_tree($res_ref,'ATTR',$attr);
                    $result_lines .= "hares -modify NFSRestart_L_$res_group_name $attr $attr_ref->{MODIFY}->{ATTRVAL}->[0]\n";
                }
                $result_lines .= "hares -modify NFSRestart_L_$res_group_name Lower 1\n";
                $res_added = 1;
            }
            # All the resources that Share resource requires, move to be required by NFSRestart_L_$res_group_name(NFSRestart resource).
            for my $link_ref (@{$treeref->{RESLINK}->{RESLINK}->{RESLINK}}){
                next unless $link_ref->{RESPARENT} eq $share_res;
                $result_lines .= "hares -unlink $link_ref->{RESPARENT} $link_ref->{RESCHILD}\n";
                $result_lines .= "hares -link NFSRestart_L_$res_group_name $link_ref->{RESCHILD}\n"
                    unless $result_lines =~ "hares -link NFSRestart_L_$res_group_name $link_ref->{RESCHILD}\n";
            }
            $result_lines .= "hares -link $share_res NFSRestart_L_$res_group_name\n";
        }
        # All the Mount resources that NFSRestart resource requires, move to be required by NFSRestart_L_$res_group_name(NFSRestart resource).
        @mount_reslist = dynupgrade_get_resname_list_from_typename($treeref,'Mount');
        for my $mount_res (@mount_reslist) {
            $mount_res_ref = dynupgrade_get_node_from_tree($treeref,'RES',$mount_res);
            next unless $mount_res_ref->{MAIN}->{SERVGRP} eq $res_group_name;
            for my $link_ref (@{$treeref->{RESLINK}->{RESLINK}->{RESLINK}}){
                next if (($link_ref->{RESCHILD} ne $mount_res) || ($link_ref->{RESPARENT} ne $res));
                $result_lines .= "hares -unlink $link_ref->{RESPARENT} $link_ref->{RESCHILD}\n";
                $result_lines .= "hares -link NFSRestart_L_$res_group_name $link_ref->{RESCHILD}\n"
                    unless $result_lines =~ "hares -link NFSRestart_L_$res_group_name $link_ref->{RESCHILD}\n";
            }
        }
        # e3419772, need create a new file for newly created resource
        $sys->cmd("_cmd_touch $newfolder/.nfsrestart_NFSRestart_L_${res_group_name}_state 2>/dev/null") unless $sys->exists("$newfolder/.nfsrestart_NFSRestart_L_${res_group_name}_state");
    }
    my @lines= split(/\n+/, $result_lines);
    $treeref= dynupgrade_import_lines2tree(\@lines,$treeref);
    return $treeref;
}

sub upgrade_poststart_sys {
    my($prod,$sys) = @_;

    # check whether old cps is configured
    $prod->upgrade_check_old_cps_sys($sys);

    return 0 unless ($sys->{vcs_upgradeable});
    #$prod->haconf_makerw();
    #$prod->unfreeze_groups();
    #$prod->haconf_dumpmakero();

    return;
}

sub upgrade_check_old_cps_sys {
    my($prod,$sys) = @_;
    my ($pkg,$cps_conf_file,$pids,$output,$msg);

    #should only display on the first node
    return unless ($sys->system1);

    $pkg = $prod->pkg('VRTScps61');
    $cps_conf_file = $pkg->{default_cps_conf_file};
    return if (!$sys->exists($cps_conf_file));

    # if not upgrade from before 6.1.0 to 6.1.0
    $output = $sys->readfile($cps_conf_file);
    chomp($output);
    return if ($output=~/https/mg);

    # check if cps is configured before upgrade
    $output = $sys->readfile($prod->{maincf});
    chomp($output);
    if ($output=~/cpsvip\d+/mg) {
        $msg = Msg::new("Communication between the CP server and application clusters will always be secured by HTTPS from 6.1.0 onwards, reconfigure the CP server with HTTPS support after an upgrade.");
        $sys->push_warning($msg);
    }

    return;
}

sub upgrade_gabtab_sys {
    my ($prod,$sys) = @_;
    my ($sysi,$gabtab,$line,@l,$tmpdir,$ngabtab);
    my $rootpath = Cfg::opt('rootpath');
    return 1 unless $sys->exists("$rootpath/etc/gabtab");
    $sysi = $sys->{sys};
    $tmpdir = EDR::tmpdir();
    Msg::log("Updating gabtab on $sysi");
    $gabtab=$sys->cmd("_cmd_cat $rootpath/etc/gabtab");
    @l=split(/\n/,$gabtab);
    for my $line (@l) {
        next if ($line=~/gabdiskhb/m);
        $ngabtab.="$line\n";
    }
    EDRu::writefile($ngabtab, "$tmpdir/gabtab.$sysi");
    EDR::cmd_local("_cmd_chmod 644 $tmpdir/gabtab.$sysi");
    $prod->localsys->copy_to_sys($sys,"$tmpdir/gabtab.$sysi","$rootpath/etc/gabtab");
    return 1;
}

sub backup_cf_files_sys {
    my ($prod,$sys,$src,$dest) = @_;
    my ($msg);

    if($sys->is_dir($src)) {
        unless($sys->is_dir($dest)) {
            $sys->cmd("_cmd_mkdir -p $dest");
        }
        $sys->cmd("_cmd_cp -pf $src/*.cf $dest\/");
    } else {
        $msg = Msg::new("Backup of cf files on $sys->{sys} failed because $src directory was not found");
        $sys->push_error($msg);
        return 0;
    }
    return 1;
}

sub display_unsupported_agents_msg {
    my ($prod,$deleted_types_resources_ref,$sys) = @_;
    my ($msg,$typename,@msgs);
    my $nfslockexist = 0;

    $msg=Msg::new("The installer has detected that your existing configuration contains the following types and resources that are no longer supported in $prod->{abbr} $prod->{vers}:\n");
    push(@msgs,$msg);
    for my $typename ( keys %{$deleted_types_resources_ref} ) {
        $msg=Msg::new("\tType : $typename\n");
        push(@msgs,$msg);
        # display type related resources
        $msg=Msg::new("\t$typename\'s Resource(s) : ${$deleted_types_resources_ref}{$typename} \n\n");
        push(@msgs,$msg);
        # check NFSLock specifically
        if ("$typename" eq 'NFSLock') {
            $nfslockexist = 1;
        }
    }

    # check with users if they hope to erase the obsolete types and resources manually
    $msg = Msg::new("Obsolete types and resources can be erased from the system either automatically by the installer, or manually by the user\n\n");
    push(@msgs,$msg);
    $msg = Msg::new("If you want to remove the obsolete types and resources manually, then follow the steps below:\n");
    push(@msgs,$msg);
    $msg = Msg::new("    Step 1 - Quit the installer\n");
    push(@msgs,$msg);
    $msg = Msg::new("    Step 2 - Stop $prod->{abbr} if it is running\n");
    push(@msgs,$msg);
    $msg = Msg::new("    Step 3 - Edit main.cf file to remove the obsolete resources\n");
    push(@msgs,$msg);
    $msg = Msg::new("    Step 4 - Edit types.cf file to remove the obsolete types\n");
    push(@msgs,$msg);
    $msg = Msg::new("    Step 5 - Restart $prod->{abbr}, and rerun the installer to proceed with the upgrade\n\n");
    push(@msgs,$msg);
    $msg = Msg::new("If you want to remove the obsolete types and resources automatically using the installer, then proceed with the upgrade\n\n");
    push(@msgs,$msg);
    if ($nfslockexist == 1) {
        $msg = Msg::new("\nNote: The NFSLock agent is no longer supported in $prod->{abbr} $prod->{vers} and is now replaced by the new NFSRestart agent. Refer to the $prod->{prod} $prod->{vers} Bundled Agents Reference Guide for details on how to configure a NFSRestart resource.\n");
        push(@msgs,$msg);
    }

    $sys->push_warning(@msgs);
    return '';
}

sub maincf_check_obsolete_types_sys {
    my ($prod,$sys,$treeref_olduser,$vcsvers) = @_;
    my ($typeref,$msg,$typename);
    my @deleted_types= ();
    my %deleted_types_resources= ();

    # below steps are used for checking the obsolete types with customer

    # precheck step 3 - import old user cmd list for checking
    # $treeref_olduser= dynupgrade_import_lines2tree($lines_ref);

    # precheck step 5 - find obsolete types

    for my $typename ( @{$prod->{deleted_agents}} ) {
        $typeref=  $treeref_olduser->{TYPE}->{$typename};
        if( defined( $typeref) ) {
            push( @deleted_types, $typename);
        }
    }

    # precheck step 6 - find obsolete resources
    for my $typename ( @deleted_types ) {
        my @reslist= dynupgrade_get_resname_list_from_typename( $treeref_olduser, $typename );
        if( scalar(@reslist) > 0) {
            $deleted_types_resources{$typename}= join( '  ', @reslist);
        }
    }

    # precheck step 7 - check with user on the obsolete types/resources
    if( scalar (keys %deleted_types_resources )> 0 ) {
        $prod->display_unsupported_agents_msg( \%deleted_types_resources, $sys);
    }
    # precheck step 8 - go on installation
    return 1;
}

sub freeze_groups {
    my $prod = shift;
    my ($syslist,$grp,@grps,$line,$sys,$rtn,@frozen_grps);
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];

    $rtn = $sys->cmd("$prod->{bindir}/hagrp -list Frozen=0 2>/dev/null");
    return if (EDR::cmdexit());
    for my $line (split(/\n+/,$rtn)) {
        ($grp)=split(/\s+/m,$line, 2);
        if($grp && !EDRu::inarr($grp,@grps)) {
            push(@grps,$grp);
        }
    }
    for my $grp (@grps) {
        next if ($grp eq 'ClusterService'); # Do not freeze Service Group : ClusterService
        Msg::log("Freezing group: $grp");
        $sys->cmd("$prod->{bindir}/hagrp -freeze $grp -persistent");
        push(@frozen_grps, $grp);
    }
    $sys->set_value('frozen_grps','list',@frozen_grps);
    return;
}

sub unfreeze_groups {
    my $prod = shift;
    my ($syslist,$grp,@grps,$line,$rtn,$sys);
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];
    $rtn = $sys->cmd("$prod->{bindir}/hagrp -list Frozen=1 2>/dev/null");
    for my $line (split(/\n+/,$rtn)) {
        ($grp)=split(/\s+/m,$line, 2);
        if($grp && !EDRu::inarr($grp,@grps)) {
            push(@grps,$grp);
        }
    }
    for my $grp (@grps) {
        Msg::log("Unfreeze group: $grp");
        $sys->cmd("$prod->{bindir}/hagrp -unfreeze $grp -persistent");
    }
    return;
}

sub haconf_dumpmakero {
    my $prod = shift;
    my ($syslist,$sys,$rtn,$done,$count);
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];
    $rtn = $sys->cmd("$prod->{bindir}/haclus -value ReadOnly");
    if ($rtn eq '0') {
        $done = 0;
        $count = 0;
        # We should try again after some times if one haconf -dump fails
        while ($count < 5) {
            $rtn = $sys->cmd("$prod->{bindir}/haconf -dump -makero");
            if (EDR::cmdexit() || EDRu::isverror($rtn)) {
                sleep 5;
                $count++;
            } else {
                sleep 5;
                $count++;
                if ($prod->haconf_dump_ok()) {
                    $done = 1;
                    last;
                }
            }
        }
        Msg::log("The command haconf -dump -makero failed") unless $done;
    }
    return;
}

# if the dump is ok, it will return '0' for <31 nodes(eg, '5' stands for node0/2 is dumping), '0 0' for >31 nodes
sub haconf_dump_ok {
    my $prod = shift;
    my ($syslist,$sys,$rtn,$done,$count);
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];
    $rtn = $sys->cmd("$prod->{bindir}/haclus -value DumpingMembership");

    if (EDR::cmdexit() || EDRu::isverror($rtn)) {
        return 0;
    } else {
        return 1 if ($rtn =~ /^\s*0\s*$/) || ($rtn =~ /^\s*0\s+0\s*$/);
    }
    return 0;
}

sub haconf_makerw {
    my $prod = shift;
    my ($syslist,$sys,$rtn);
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];
    $rtn = $sys->cmd("$prod->{bindir}/haclus -value ReadOnly");
    if ($rtn eq '1') {
        $sys->cmd("$prod->{bindir}/haconf -makerw");
        sleep 3;
    }
    return;
}

sub translate_file_cmd2cf_sys {
    my ($prod,$sys,$path,$is_resultconfig)= @_;
    my ($cmd_hacf,$rootpath,$content,$typescfpath,$ret);
    $cmd_hacf= $prod->{cmd_hacf};

    # create main.cmd for .cf files
    $sys->cmd("$cmd_hacf -cmdtocf $path" );
    return 0 if(EDR::cmdexit());

    #To fix incident 3056133,CPI modify the types.cf manually
    #CPI will call the original hacf utility during OS liveupgrade and rollback.This action resolves some mistakes in types.cf.
    $rootpath=Cfg::opt('rootpath')||'';
    if (($sys->{osupgraded} || Cfg::opt('rollback'))&& $is_resultconfig) {
        $typescfpath="$rootpath$prod->{typescf}";
        $prod->correct_typescf_syntax_errors_sys($sys,$typescfpath);
    }
    # verify effectiveness of .cf files
    $ret= $sys->cmd("$cmd_hacf -verify $path" );
    return 0 if($ret);
    return 1;
}

sub correct_typescf_syntax_errors_sys {
    my ($prod,$sys,$typescfpath)=@_;
    my $content=$sys->readfile($typescfpath);
    if($content=~/primary=stop/mx) {
        $content=~s/primary=stop/primary="stop"/g;
        $sys->writefile($content,$typescfpath);
    }
    return 1;
}

# if WPAR WorkLoad attribute in types.cf has values -1 set for both CPU and MEM, mark it as WorkLoad {}
# if WPAR WorkLoad attribute in types.cf has -1 and +ve value of the attribute, Delete the key-value pair which has -1 value
sub set_workload_typescf_sys {
    my ($prod,$sys,$path) = @_;
    my ($content,$tmptypescf);
    
    $content = $sys->readfile("$path/types.cf");
    for my $line(split(/^/m, $content)) {
        # the format of types.cf in $upgradepath/old_conf is different
        $line =~ s/\s+=\s+\{\s+CPU\s+=\s+\"-1\",\s+MEM\s+=\s+\"-1\"\s+\}//m;
        if ($line =~ /^\s*int\s+WorkLoad\{\}\s+=\s+\{/mx) {
            $line =~ s/\s+CPU\s*=\s*\"-1\",//m;
            $line =~ s/(,|)\s+MEM\s*=\s*\"-1\"//m;
        }    
        $tmptypescf .= $line;
    }
    $sys->writefile($tmptypescf,"$path/types.cf");    

    return 1;
}

# if WPAR WorkLoad attribute in main.cf has values -1 set for both CPU and MEM, mark it as WorkLoad = {}
# else if  WPAR WorkLoad attribute in main.cf has -1 and +ve value of the attribute, Delete the key-value pair which has -1 value
# else continue with the Pre-falcon functionality
sub set_workload_maincf_sys {
    my ($prod,$sys,$path) = @_;
    my ($maincf,$tmpmaincf);

    $maincf = $sys->readfile("$path/main.cf");
    for my $line(split(/^/m, $maincf)) {
        $line =~ s/\s+CPU\s+=\s+\"-1\",\s+MEM\s+=\s+\"-1\"//m;
        if ($line =~ /^\s*WorkLoad\s+=\s+\{/mx) {
            $line =~ s/CPU\s+=\s+\"-1\",//m;
            $line =~ s/(,|)\s+MEM\s+=\s+\"-1\"//m;
        }
        $tmpmaincf .= $line;
    }
    $sys->writefile($tmpmaincf,"$path/main.cf");

    return 1;
}

sub translate_file_cf2cmd_sys {
    my ($prod,$sys,$path,$is_userconfig) = @_;
    my ($cmd_hacf,$rtn,$maincf);
    $cmd_hacf= $prod->{cmd_hacf};

    unless($sys->is_dir($path)) {
        return 0;
    }

    # set the WorkLoad value, e3514548
    $prod->set_workload_typescf_sys($sys,$path);
    $prod->set_workload_maincf_sys($sys,$path);

    # deal with system configuraiton directory (conf)=> create a main.cf file only including types.cf
    if(!$is_userconfig) {
        # create a null main.cf for sys
        $maincf= "include \"types.cf\"\n";
        for my $category (sort keys %{$sys->{maincf_include}}) {
            my $extra_type = $sys->{maincf_include}{$category};
            next unless ($extra_type);
            if ($sys->exists("$path/$extra_type")) {
                $maincf.="include \"$extra_type\"\n";
            }
        }
        # output to updated types.cf
        $sys->writefile($maincf, "$path/main.cf" );
    }
    # verify effectiveness of .cf files
    $rtn = $sys->cmd("$cmd_hacf -verify $path");
    return 0 if($rtn);
    # create main.cmd for .cf files
    $sys->cmd("$cmd_hacf -cftocmd $path");
    return 1 if ($sys->exists("$path/main.cmd"));
    return 0;
}

sub padv_mend_old_cf_sys {
    my ($prod, $sys, $path) = @_;
    return 1;
}

sub dynupgrade_get_branch_from_tree {
    my ($treeref, $branch_name)= @_;
    return $treeref->{$branch_name};
}

sub dynupgrade_get_node_from_tree {
    my ($treeref, $branch_name, $node_name)= @_;
    my $branchref= dynupgrade_get_branch_from_tree( $treeref, $branch_name);
    return $branchref->{$node_name};
}

sub dynupgrade_get_attr_from_tree {
    my ($treeref, $branch_name, $node_name, $attr_name)= @_;
    my $noderef= dynupgrade_get_node_from_tree( $treeref, $branch_name, $node_name);
    return $noderef->{ATTR}->{$attr_name};
}

sub dynupgrade_get_node_from_branch {
    my ($branchref, $node_name)= @_;
    return $branchref->{$node_name};
}

sub dynupgrade_get_attr_from_branch {
    my ($branchref, $node_name, $attr_name)= @_;
    my $noderef= dynupgrade_get_node_from_branch( $branchref, $node_name);
    return $noderef->{ATTR}->{$attr_name};
}

sub dynupgrade_get_attr_from_node {
    my ($noderef, $attr_name)= @_;
    return $noderef->{ATTR}->{$attr_name};
}

sub dynupgrade_get_resname_list_from_typename {
    my ($treeref, $type_name)= @_;
    my @resname_list= ();
    my $branchref= dynupgrade_get_branch_from_tree( $treeref, 'RES');
    my ( $resname, $noderef, $cmdref);

    for my $resname ( keys %{$branchref} ) {
        # get each resource node and main command
        $noderef= dynupgrade_get_node_from_branch( $branchref, $resname);
        $cmdref= $noderef->{MAIN};
        # compare the type name with required one
        if( $cmdref->{RESTYPE} eq $type_name) {
            push ( @resname_list, $resname);
        }
    }

    return @resname_list;
}

sub dynupgrade_get_resname_list_from_typename_list {
    my ($treeref, $type_name_list)= @_;
    my @resname_list= ();
    my $branchref= dynupgrade_get_branch_from_tree( $treeref, 'RES');
    my ( $resname, $noderef, $cmdref);

    for my $resname ( keys %{$branchref} ) {
        # get each resource node and main command
        $noderef= dynupgrade_get_node_from_branch( $branchref, $resname);
        $cmdref= $noderef->{MAIN};
        # compare the type name with required one
        if(EDRu::inarr($cmdref->{RESTYPE},@{$type_name_list})) {
            push ( @resname_list, $resname);
        }
    }

    return @resname_list;
}

# Responsibility: To find the obsolete types-attributes matrix from the old tree
# Input:          Tree references
# Output:         Obsolete attributes
sub dynupgrade_get_removed_attrs {
    my (@vars) = @_;
    my $brachref_old= $vars[0]->{TYPE};
    my $brachref_new= $vars[1]->{TYPE};
    my ($typeref_old, $typeref_new, $typename, $attrname);
    my %deleted_attrs= ();

    # to browse each type node from TYPE branch
    for my $typename (keys %{$brachref_old} ) {
        $typeref_old= dynupgrade_get_node_from_branch( $brachref_old, $typename);
        $typeref_new= dynupgrade_get_node_from_branch( $brachref_new, $typename);
        if( !$typeref_old || !$typeref_new) {
            next;
        }
        # to browse each attribute from type node
        for my $attrname (keys %{$typeref_old->{ATTR}}) {
            my $attrref_old= dynupgrade_get_attr_from_node( $typeref_old, $attrname);
            my $attrref_new= dynupgrade_get_attr_from_node( $typeref_new, $attrname);
            if( defined( $attrref_old) && !defined( $attrref_new) ) {
                # to add the first obsolete attribute
                if( !defined($deleted_attrs{$typename}) ) {
                    $deleted_attrs{$typename}= [$attrname];
                } else {
                    # to add more obsolete attribute
                    push ( @{$deleted_attrs{$typename}}, $attrname);
                }
            }
        }
    }
    return \%deleted_attrs;
}

# Responsibility: To merge tree B by tree A
# Input:          Tree references
# Output:         Merged tree
sub dynupgrade_merge_trees_A_over_B {
    return dynupgrade_merge_trees_B_over_A( $_[1], $_[0]);
}

# Responsibility: To merge tree A by tree B
# Input:          Tree references
# Output:         Merged tree
sub dynupgrade_merge_trees_B_over_A {
    my ($treeref1, $treeref2)= @_;
    my $treeref_result= undef;

    #merge types
    $treeref_result= dynupgrade_merge_branches_B_over_A( $treeref1, $treeref2, 'TYPE');

    #clusters/systems/resources/groups/links/others that are from main.cf should only be copied
    $treeref_result->{CLUS}   = $treeref2->{CLUS};
    $treeref_result->{SYS}    = $treeref2->{SYS};
    $treeref_result->{GRP}    = $treeref2->{GRP};
    $treeref_result->{RES}    = $treeref2->{RES};
    $treeref_result->{GRPLINK}= $treeref2->{GRPLINK};
    $treeref_result->{RESLINK}= $treeref2->{RESLINK};
    $treeref_result->{OTHER}  = $treeref2->{OTHER};

    return $treeref_result;
}

# Responsibility: To merge tree A by tree B with a branch
# Input:          tree references; tree branch
# Output:         merged tree
sub dynupgrade_merge_branches_B_over_A {
    my ($treeref1, $treeref2, $branch_name)= @_;
    my ($nodename, $noderef1, $noderef2, $treeref_result );

    #copy tree 1 to result
    %{$treeref_result}= %{$treeref1};

    #merge nodes
    for my $nodename (keys %{$treeref2->{$branch_name}} ) {
        $noderef1= dynupgrade_get_node_from_tree( $treeref_result, $branch_name, $nodename);
        $noderef2= dynupgrade_get_node_from_tree( $treeref2, $branch_name, $nodename);

        #new node => added to list
        if( !defined( $noderef1) ) {
            $treeref_result->{$branch_name}->{$nodename}= $noderef2;
            next;
        }
        #overwrite
        $treeref_result->{$branch_name}->{$nodename}= dynupgrade_merge_nodes_B_over_A( $noderef1, $noderef2);
    }

    return $treeref_result;
}

# Responsibility: To merge node A by Node B
# Input:          node references; etc.
# Output:         merged node
sub dynupgrade_merge_nodes_B_over_A {
    my ($noderef1, $noderef2)= @_;
    my ( $attrname, $attrref1, $attrref2);
    my $noderef_result= {};

    #set result as noderef1
    %{$noderef_result}= %{$noderef1};

    #main cmd
    $noderef_result->{MAIN}= $noderef2->{MAIN};
    #file cmd
    $noderef_result->{FILE}= $noderef2->{FILE};

    #attributes
    for my $attrname ( keys %{$noderef2->{ATTR}} ) {
        # exceptional for ArgList => reserve the values to be the ones from new version
        if( $attrname eq 'ArgList' ) {
            next;
        }
        # other attributes
        $attrref1= dynupgrade_get_attr_from_node( $noderef_result, $attrname );
        $attrref2= dynupgrade_get_attr_from_node( $noderef2, $attrname );

        %{$attrref1}= %{$attrref2};
        $noderef_result->{ATTR}->{$attrname}= $attrref1;
    }
    return $noderef_result;
}

# Responsibility: Tree A minus tree B
# Input:          tree references
# Output:         Result tree
sub dynupgrade_minus_trees {
    my ($treeref1, $treeref2)= @_;
    my ( $treeref_result, $treeref_temp );

    # minus types only
    $treeref_temp= dynupgrade_minus_treebranches( $treeref1, $treeref2, 'TYPE');
    $treeref_result->{TYPE}= $treeref_temp->{TYPE};

    # cluster/system/resources/groups/links/other should only be reserved for main.cf
    $treeref_result->{CLUS}   = $treeref1->{CLUS};
    $treeref_result->{SYS}    = $treeref1->{SYS};
    $treeref_result->{RES}    = $treeref1->{RES};
    $treeref_result->{GRP}    = $treeref1->{GRP};
    $treeref_result->{GRPLINK}= $treeref1->{GRPLINK};
    $treeref_result->{RESLINK}= $treeref1->{RESLINK};
    $treeref_result->{OTHER}  = $treeref1->{OTHER};

    return $treeref_result;
}

# Responsibility: Tree A minus tree B with branch
# Input:          tree references; branch name
# Output:         Result tree
sub dynupgrade_minus_treebranches {
    my ($treeref1, $treeref2, $branch_name)= @_;
    my ( $nodename, $noderef1, $noderef2, $noderef_result );
    my $treeref_result  = {};

    # minus objects
    for my $nodename (keys %{$treeref1->{$branch_name}} ) {
        $noderef1= dynupgrade_get_node_from_tree( $treeref1, $branch_name, $nodename );
        # object that should be reserved
        if( !defined( dynupgrade_get_node_from_tree( $treeref2, $branch_name, $nodename) ) ) {
            $treeref_result->{$branch_name}->{$nodename}= $noderef1;
            next;
        }

        # find the corresponding object
        $noderef2= dynupgrade_get_node_from_tree( $treeref2, $branch_name, $nodename );
        $noderef_result= dynupgrade_minus_nodes( $noderef1, $noderef2);
        if( $noderef_result ) {
            $treeref_result->{$branch_name}->{$nodename}= $noderef_result;
        } else {
            delete( $treeref_result->{$branch_name}->{$nodename} );
        }
    }
    return $treeref_result;
}

# Responsibility: Node A minus node B
# Input:          node references
# Output:         Result node
sub dynupgrade_minus_nodes {
    my ($noderef1, $noderef2 )= @_;
    my ($cmp, $attrname, $attrref1, $attrref2);
    my $noderef_result  = {};

    # set result as noderef1
    %{$noderef_result}= %{$noderef1};

    # attrubutes
    for my $attrname ( keys %{$noderef2->{ATTR}} ) {
        $attrref1= dynupgrade_get_attr_from_node( $noderef_result, $attrname);
        $attrref2= dynupgrade_get_attr_from_node( $noderef2, $attrname);

        # add cmd
        if( defined( $attrref1->{ADD} ) && defined( $attrref2->{ADD}) ) {
            $cmp= dynupgrade_compare_ha_cmds( $attrref1->{ADD}, $attrref2->{ADD});
            if( $cmp ne 'EQUAL_ATTR_ADD_TYPENAME_ATTRNAME_ATTRVAL' ) {
                next;
            }
        }
        # defalut attribute cmd
        if( defined( $attrref1->{DEFAULT}) && defined( $attrref2->{DEFAULT}) ) {
            $cmp= dynupgrade_compare_ha_cmds( $attrref1->{DEFAULT}, $attrref2->{DEFAULT});
            if( $cmp ne 'EQUAL_ATTR_DEFAULT_TYPENAME_ATTRNAME_ATTRVAL' ) {
                next;
            }
        }
        # modify cmd
        if( defined( $attrref1->{MODIFY}) && defined( $attrref2->{MODIFY}) ) {
            $cmp= dynupgrade_compare_ha_cmds( $attrref1->{MODIFY}, $attrref2->{MODIFY});
            if( $cmp ne 'EQUAL_TYPE_MODIFY_TYPENAME_ATTRNAME_ATTRVAL' ) {
                next;
            }
        }
        # attribute totally match => remove attribute
        delete( $noderef_result->{ATTR}->{$attrname} );
    }
    # no attributes left => remove node
    if( (keys %{$noderef_result->{ATTR}}) == 0) {
        $noderef_result= undef;
    }

    return $noderef_result;
}

# Responsibility: To update a command to tree
# Input:          Tree reference; cmd reference
# Output:         Updated tree
sub dynupgrade_update_cmd2tree {
    my ($treeref, $cmdref)= @_;
    my $branch_name = $cmdref->{TREE_BRANCH};
    my $node_name   = $cmdref->{TREE_NODENAME};
    my $node_class  = $cmdref->{TREE_NODECLASS};
    my $attr_class  = $cmdref->{TREE_ATTRCLASS};

    #delete a node
    if( $node_class eq 'DELETE') {
        delete( $treeref->{$branch_name}->{$node_name} );
        return;
    }
    # clusters/systems/others commands
    if( $branch_name eq 'CLUS' ||
        $branch_name eq 'SYS' ||
        $branch_name eq 'OTHER' ) {
        if( !defined ( $treeref->{$branch_name}) ) {
            $treeref->{$branch_name}= [];
        }
        push( @{$treeref->{$branch_name}}, $cmdref);
        return;
    }

    #update type/res/group/resource_link/group_link command to related branch and node
    my $noderef= dynupgrade_get_node_from_tree( $treeref, $branch_name, $node_name );
    $treeref->{$branch_name}->{$node_name}= dynupgrade_update_cmd2node( $noderef, $cmdref, $node_class, $attr_class);
    return;
}

# Responsibility: To update a command to tree node
# Input:          tree node; cmd reference; etc.
# Output:         updated node
sub dynupgrade_update_cmd2node {
    my ($noderef, $cmdref, $node_class, $attr_class)= @_;
    my ( $attrref, $attrname);

    # init node if not defined
    if( !defined ($noderef) ) {
        $noderef= {'MAIN'=>undef, 'FILE'=>undef, 'ATTR'=>{}, 'GRPLINK'=>[], 'RESLINK'=>[]};
    }

    # to add the command to related branch of the node
    if( $node_class eq 'MAIN' ||
        $node_class eq 'FILE' ) {
        $noderef->{$node_class}= $cmdref;
        return $noderef;
    }
    if( $node_class eq 'ATTR' ) {
        $attrname= $cmdref->{ATTRNAME};
        # delete attr
        if( $attr_class eq 'DELETE') {
            delete( $noderef->{ATTR}->{$attrname} );
            return $noderef;
        }
        # add
        if( !defined( $noderef->{ATTR}->{$attrname}) ) {
            $noderef->{ATTR}->{$attrname}= {};
        }
        # other attr actions
        $attrref= $noderef->{ATTR}->{$attrname};
        if( $attr_class eq 'MODIFY' && $cmdref->{CMD} =~ /^(hares|hagrp)$/mx) {
            if ( !defined($attrref->{$attr_class}->{ATTRVAL}) || scalar(@{$attrref->{$attr_class}->{ATTRVAL}}) <= 0
                 || ( $cmdref->{ATTRVAL} !~ /\s+\-sys\s+/mx && $cmdref->{ATTRVAL} !~ /^(\s+)?\-add\s+/mx) ) {

                my $cmd_attrval= $cmdref->{ATTRVAL};
                $attrref->{$attr_class}= $cmdref;
                $attrref->{$attr_class}->{ATTRVAL}= [$cmd_attrval];
            } else {
                push ( @{$attrref->{$attr_class}->{ATTRVAL}}, $cmdref->{ATTRVAL} );
            }
        } else {
            # other attr actions
            $attrref->{$attr_class}= $cmdref;
        }
        return $noderef;
    }
    # add grp link
    if( $node_class eq 'GRPLINK' ) {
        if( !defined( $noderef->{$node_class} ) ) {
            $noderef->{$node_class}= [];
        }
        push( @{$noderef->{$node_class}}, $cmdref);
        return $noderef;
    }
    # grp unlink
    if( $node_class eq 'GRPUNLINK') {
        for( my $idx= $#{$noderef->{GRPLINK}}; $idx>= 0; $idx-- ) {
            my $cmdref1= ${$noderef->{GRPLINK}}[$idx];
            if( $cmdref1->{GRPPARENT} eq $cmdref->{GRPPARENT} &&
                $cmdref1->{GRPCHILD} eq $cmdref->{GRPCHILD} ) {
                $noderef->{GRPLINK} = dynupgrade_del_from_array_by_index( $noderef->{GRPLINK}, $idx);
                return $noderef;
            }
        }
        return $noderef;
    }
    # add res link
    if( $node_class eq 'RESLINK' ) {
        if( !defined( $noderef->{$node_class} ) ) {
            $noderef->{$node_class}= [];
        }
        push( @{$noderef->{$node_class}}, $cmdref);
        return $noderef;
    }
    # res unlink
    if( $node_class eq 'RESUNLINK') {
        for( my $idx= $#{$noderef->{RESLINK}}; $idx>= 0; $idx-- ) {
            my $cmdref1= ${$noderef->{RESLINK}}[$idx];
            if( $cmdref1->{RESPARENT} eq $cmdref->{RESPARENT} &&
                $cmdref1->{RESCHILD} eq $cmdref->{RESCHILD} ) {
                $noderef->{RESLINK} = dynupgrade_del_from_array_by_index( $noderef->{RESLINK}, $idx);
                return $noderef;
            }
        }
        return $noderef;
    }
    Msg::log("Error in processing command: [$cmdref->{CMD}]\n");
    return $noderef;
}

# Responsibility: To validate a tree to be effective
# Input:          Tree reference, the matrix of deleted attributes
# Output:         Updated tree
sub dynupgrade_validate_tree {
    my ($treeref,$deleted_attrs_ref) = @_;
    my ($cmdref,$num,$attrname,$nodename,$noderef);

    # update type attributes
    for my $nodename (keys %{$deleted_attrs_ref} ) {
        # get each type node
        $noderef= dynupgrade_get_node_from_tree( $treeref, 'TYPE', $nodename);
        # browse the attributes in each type
        for my $attrname ( @{$deleted_attrs_ref->{$nodename}} ) {
            # delete the obsolete ones
            if( defined ($noderef->{ATTR}->{$attrname} ) ) {
                delete( $noderef->{ATTR}->{$attrname} );
            }
        }
    }

    # update group link
    $noderef= $treeref->{GRPLINK}->{GRPLINK};
    if( $noderef) {
        $num= @{$noderef->{GRPLINK}};
        for( my $idx= $num-1; $idx>= 0; $idx-- ) {
            $cmdref= @{$noderef->{GRPLINK}}[$idx];
            my $name_parent= $cmdref->{GRPPARENT};
            my $name_child = $cmdref->{GRPCHILD};

            # not found related nodes => delete
            if( !defined( $treeref->{GRP}->{$name_parent} ) ||
                !defined( $treeref->{GRP}->{$name_child} ) ) {
                $noderef->{GRPLINK} = dynupgrade_del_from_array_by_index( $noderef->{GRPLINK}, $idx);
                next;
            }
        }
    }

    # update resource
    for my $nodename (keys %{$treeref->{RES}} ) {
        # get each resource
        $noderef= dynupgrade_get_node_from_tree( $treeref, 'RES', $nodename );

        $cmdref= $noderef->{MAIN};
        # get the name and group of a resource
        my $name_type= $cmdref->{RESTYPE};
        my $name_grp = $cmdref->{SERVGRP};
        # not found type|group in type|group list=> remove resource
        if( !defined( $treeref->{TYPE}->{$name_type} ) ||
            !defined( $treeref->{GRP}->{$name_grp} ) ) {
            delete( $treeref->{RES}->{$nodename} );
            next;
        }

        # get resource related type node
        my $noderef_type= dynupgrade_get_node_from_tree( $treeref, 'TYPE', $name_type );

        # browse the attributes in the resource to delete the obsolete ones
        # the attribute in a resource can not be found in the deleted type attribute list => delete the attribute in the resource
        for my $attrname ( @{$deleted_attrs_ref->{$name_type}} ) {
            # delete the obsolete attribute
            if( defined ($noderef->{ATTR}->{$attrname} ) ) {
                delete( $noderef->{ATTR}->{$attrname} );
            }
        }
    }

    # update resource link
    $noderef= dynupgrade_get_node_from_tree( $treeref, 'RESLINK', 'RESLINK');
        if( $noderef ) {
        $num= @{$noderef->{RESLINK}};
        for( my $idx= $num-1; $idx>= 0; $idx-- ) {
            $cmdref= @{$noderef->{RESLINK}}[$idx];
            my $name_parent= $cmdref->{RESPARENT};
            my $name_child = $cmdref->{RESCHILD};
            # not found related nodes => delete
            if( !defined( $treeref->{RES}->{$name_parent} ) ||
                !defined( $treeref->{RES}->{$name_child} ) ) {
                $noderef->{RESLINK} = dynupgrade_del_from_array_by_index( $noderef->{RESLINK}, $idx);
                next;
            }
        }
    }

    return $treeref;
}

# Responsibility: To import file into a tree
# Input:          System name; cmd file name
# Output:         Reference of result tree
sub dynupgrade_import_file2tree_sys {
    my ( $sys, $nameIn)= @_;
    my $lines_ref= dynupgrade_import_file2lines_sys( $sys, $nameIn);
    my $tree_ref= dynupgrade_import_lines2tree( $lines_ref);
    return $tree_ref;
}

# Responsibility: To import file into strings
# Input:          System name; cmd file name
# Output:         Reference of result strings
sub dynupgrade_import_file2lines_sys {
    my ( $sys, $nameIn)= @_;

    my $content= $sys->readfile($nameIn);

    # read file until the end
    my @lines= split(/\n+/, $content);
    return \@lines;
}

# Responsibility: To load a tree from file lines
# Input:          File lines; cmd reference
# Output:         Created tree
sub dynupgrade_import_lines2tree {
    my (@vars) = @_;
    my (@lines, $line, %tree);
    @lines= @{$vars[0]};
    my $treeref = $vars[1];
    if ($treeref) {
        %tree = %{$treeref};
    } else {
        %tree= ();
    }

    $line= undef;

    while( scalar(@lines) ) {
        $line= shift @lines;

        # The substitution group below is based on the regular expressions in order to get one line to be neated
        # with items seperated by only one spaces

        # 1- to remove the redundant spaces in order to reserve only one space charracter between each couple of items
        $line=~s/\s+/ /mg;
        # 2- to remove the spaces at the beginning
        $line=~s/^\s+//mg;
        # 3- to remove the spaces in the end
        $line=~s/\s+$//mg;
        if( !$line) {
            next;
        }

        # parse line into command
        my $cmdref= dynupgrade_parse_ha_cmd($line);
        # build command into tree
        dynupgrade_update_cmd2tree (\%tree, $cmdref);
        $line= undef;
    }
    return \%tree;
}

# Responsibility: To export a tree into a file
# Input:          System name; cmd file name; tree reference; etc.
# Output:         N/A
sub dynupgrade_export_tree2file_sys {
    my ( $sys, $nameOut, $tree_ref)= @_;
    my $result= dynupgrade_export_tree2string( $tree_ref);
    $sys->writefile($result, $nameOut );
    return;
}

# Responsibility: To serialize a tree into string
# Input:          Tree reference; sub tree branch name
# Output:         Serialized string
sub dynupgrade_export_tree2string {
    my ($treeref)= @_;
    my $result= '';

    # export types
    $result.= dynupgrade_export_branch2string( $treeref, 'TYPE');

    # export clusters
    $result.= dynupgrade_export_branch2string( $treeref, 'CLUS');

    # export systems
    $result.= dynupgrade_export_branch2string( $treeref, 'SYS');

    # export groups
    $result.= dynupgrade_export_branch2string( $treeref, 'GRP');

    # export resources
    $result.= dynupgrade_export_branch2string( $treeref, 'RES');

    # export others
    $result.= dynupgrade_export_branch2string( $treeref, 'OTHER');

    # export group/resource links
    $result.= dynupgrade_export_branch2string( $treeref, 'GRPLINK');
    $result.= dynupgrade_export_branch2string( $treeref, 'RESLINK');

    return $result;
}

# Responsibility: To serialize a subtree into string
# Input:          Tree reference; sub tree branch name
# Output:         Serialized string
sub dynupgrade_export_branch2string {
    my ($treeref, $branch_name)= @_;
    my $result= '';
    my $key= undef;
    my $noderef= undef;

    # export other list
    if( $branch_name eq 'CLUS' ||
        $branch_name eq 'SYS' ||
        $branch_name eq 'OTHER' ) {
        my $cmdref= undef;
        for my $cmdref ( @{$treeref->{$branch_name}} ) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
        return $result;
    }
    # export one branch such as one of TYPE/RES/GRP/RESLINK/GRPLINK
    for my $key (keys %{$treeref->{$branch_name}} ) {
        # export one node of a branch
        $noderef= $treeref->{$branch_name}->{$key};
        $result.= dynupgrade_export_node2string( $noderef);
    }
    return $result;
}

# Responsibility: To serialize a node into string
# Input:          Node reference
# Output:         Serialized string
sub dynupgrade_export_node2string {
    my ($noderef)= @_;
    my $result= '';
    my ( $cmdref, $attrref, $attrname );

    # main command
    $cmdref= $noderef->{MAIN};
    if( $cmdref) {
        $result.= dynupgrade_export_ha_cmd( $cmdref);
    }
    # file command
    $cmdref= $noderef->{FILE};
    if( $cmdref) {
        $result.= dynupgrade_export_ha_cmd( $cmdref);
    }
    # group link only
    for my $cmdref ( @{$noderef->{GRPLINK}} ) {
        $result.= dynupgrade_export_ha_cmd( $cmdref);
    }
    # rsource link only
    for my $cmdref ( @{$noderef->{RESLINK}} ) {
        $result.= dynupgrade_export_ha_cmd( $cmdref);
    }

    # export ATTR commands
    for my $attrname (keys %{$noderef->{ATTR}} ) {
        $attrref= $noderef->{ATTR}->{$attrname};

        # add
        $cmdref= $attrref->{ADD};
        if( $cmdref) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
        # local
        $cmdref= $attrref->{LOCAL};
        if( $cmdref) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
        # default
        $cmdref= $attrref->{DEFAULT};
        if( $cmdref) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
        # override
        $cmdref= $attrref->{OVERRIDE};
        if( $cmdref) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
        # undooverride
        $cmdref= $attrref->{UNDOOVERRIDE};
        if( $cmdref) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
        # modify
        $cmdref= $attrref->{MODIFY};
        if( $cmdref) {
            $result.= dynupgrade_export_ha_cmd( $cmdref);
        }
    }

    return $result;
}

# Responsibility: To parse the ha command into cmd object
# Input:          Ha command line name
# Output:         Cmd object reference
sub dynupgrade_parse_ha_cmd {
    my ($line) = @_;
    my %cmd = ();
    my @items= ();

    # split the line into items by spaces
    @items       = split( /\s+/m, $line);
    $cmd{CMD}    = shift @items;
    $cmd{SUBCMD} = shift @items;

    if( scalar(@items) <= 0) {
        return \%cmd;
    }
    # commands for types
    if( $cmd{CMD} eq 'hatype') {
        if( $cmd{SUBCMD} eq '-add' ) {
            $cmd{TYPENAME} = shift @items;
            $cmd{TREE_NODECLASS}= 'MAIN';
        }
        elsif( $cmd{SUBCMD} eq '-modify' ) {
            $cmd{TYPENAME} = shift @items;
            $cmd{ATTRNAME} = shift @items;
            $cmd{ATTRVAL}  = join( ' ', @items);
            $cmd{TREE_NODECLASS}= 'ATTR';
            if( $cmd{ATTRNAME} eq 'SourceFile' ) {
                $cmd{TREE_NODECLASS}= 'FILE';
            }
            $cmd{TREE_ATTRCLASS}= 'MODIFY';
        } elsif( $cmd{SUBCMD} eq '-delete' ) {
            $cmd{TYPENAME} = shift @items;
            $cmd{TREE_NODECLASS}= 'DELETE';
        } else {
            $cmd{CONTENT}= join( ' ', @items);
            $cmd{TREE_BRANCH}= 'OTHER';
            return \%cmd;
        }
        $cmd{TREE_BRANCH}= 'TYPE';
        $cmd{TREE_NODENAME}= $cmd{TYPENAME};
        return \%cmd;
    }
    # commands for attributes
    if( $cmd{CMD} eq 'haattr') {
        $cmd{TREE_BRANCH}= 'TYPE';
        $cmd{TREE_NODECLASS}= 'ATTR';
        if( $cmd{SUBCMD} eq '-add') {
            if( $items[0] eq '-static' || $items[0] eq '-temp') {
                $cmd{ATTRPRETYPE} = shift @items;
            }
            $cmd{TYPENAME} = shift @items;
            $cmd{ATTRNAME} = shift @items;
            if( $items[0] eq '-string' || $items[0] eq '-integer' || $items[0] eq '-boolean' ) {
                $cmd{ATTRVALTYPE} = shift @items;
            }
            if( $items[0] eq '-scalar' || $items[0] eq '-keylist' || $items[0] eq '-assoc' || $items[0] eq '-vector') {
                $cmd{ATTRVALDIM} = shift @items;
            }
            if( scalar(@items) > 0) {
                $cmd{ATTRVAL} = join( ' ', @items);
            }
            $cmd{TREE_ATTRCLASS}= 'ADD';
        } elsif( $cmd{SUBCMD} eq '-default') {
            $cmd{TYPENAME} = shift @items;
            $cmd{ATTRNAME} = shift @items;
            if( scalar(@items) > 0) {
                $cmd{ATTRVAL} = join( ' ', @items);
            }
            $cmd{TREE_ATTRCLASS}= 'DEFAULT';
        } elsif( $cmd{SUBCMD} eq '-delete') {
            if( $items[0] eq '-static' || $items[0] eq '-temp') {
                $cmd{ATTRPRETYPE} = shift @items;
            }
            ( $cmd{TYPENAME}, $cmd{ATTRNAME} )= @items;
            $cmd{TREE_ATTRCLASS}= 'DELETE';
        } else {
            $cmd{CONTENT}= join( ' ', @items);
            $cmd{TREE_BRANCH}= 'OTHER';
            return \%cmd;
        }
        $cmd{TREE_NODENAME}= $cmd{TYPENAME};
        return \%cmd;
    }
    # commands for group
    if( $cmd{CMD} eq 'hagrp') {
        $cmd{TREE_BRANCH}= 'GRPLINK';
        $cmd{TREE_NODENAME}= 'GRPLINK';
        if( $cmd{SUBCMD} eq '-link') {
            ( $cmd{GRPPARENT},$cmd{GRPCHILD},$cmd{GDCATEGORY}, $cmd{GDLOCATION}, $cmd{GDTYPE} )= @items;
            $cmd{TREE_NODECLASS}= 'GRPLINK';
            return \%cmd;
        } elsif( $cmd{SUBCMD} eq '-unlink') {
            ( $cmd{GRPPARENT}, $cmd{GRPCHILD} )= @items;
            $cmd{TREE_NODECLASS}= 'GRPUNLINK';
            return \%cmd;
        }

        $cmd{TREE_BRANCH}= 'GRP';
        if( $cmd{SUBCMD} eq '-add') {
            $cmd{TYPENAME} = shift @items;
            $cmd{TREE_NODECLASS}= 'MAIN';
        } elsif( $cmd{SUBCMD} eq '-modify') {
            $cmd{TYPENAME} = shift @items;
            $cmd{ATTRNAME} = shift @items;
            if( scalar(@items) > 0) {
                $cmd{ATTRVAL} = join( ' ', @items);
            }
            $cmd{TREE_NODECLASS}= 'ATTR';
            if( $cmd{ATTRNAME} eq 'SourceFile' ) {
                $cmd{TREE_NODECLASS}= 'FILE';
            }
            $cmd{TREE_ATTRCLASS}= 'MODIFY';
        } elsif( $cmd{SUBCMD} eq '-delete') {
            $cmd{TYPENAME} = shift @items;
            $cmd{TREE_NODECLASS}= 'DELETE';
        } else {
            $cmd{CONTENT}= join( ' ', @items);
            $cmd{TREE_BRANCH}= 'OTHER';
            return \%cmd;
        }
        $cmd{TREE_NODENAME}= $cmd{TYPENAME};
        return \%cmd;
    }
    # commands for resources
    if( $cmd{CMD} eq 'hares') {
        $cmd{TREE_BRANCH}= 'RESLINK';
        $cmd{TREE_NODENAME}= 'RESLINK';
        if( $cmd{SUBCMD} eq '-link') {
            ( $cmd{RESPARENT}, $cmd{RESCHILD} )= @items;
            $cmd{TREE_NODECLASS}= 'RESLINK';
            return \%cmd;
        }
        elsif( $cmd{SUBCMD} eq '-unlink') {
            ( $cmd{RESPARENT}, $cmd{RESCHILD} )= @items;
            $cmd{TREE_NODECLASS}= 'RESUNLINK';
            return \%cmd;
        }

        $cmd{TREE_BRANCH}= 'RES';
        if( $cmd{SUBCMD} eq '-add') {
            ( $cmd{RESNAME}, $cmd{RESTYPE}, $cmd{SERVGRP} )= @items;
            $cmd{TREE_NODECLASS}= 'MAIN';
        } elsif( $cmd{SUBCMD} eq '-delete') {
            $cmd{RESNAME} = shift @items;
            $cmd{TREE_NODECLASS}= 'DELETE';
        } elsif( $cmd{SUBCMD} eq '-modify') {
            $cmd{RESNAME} = shift @items;
            $cmd{ATTRNAME} = shift @items;
            if( scalar(@items) > 0) {
                $cmd{ATTRVAL} = join( ' ', @items);
            }
            $cmd{TREE_NODECLASS}= 'ATTR';
            if( $cmd{ATTRNAME} eq 'SourceFile' ) {
                $cmd{TREE_NODECLASS}= 'FILE';
            }
            $cmd{TREE_ATTRCLASS}= 'MODIFY';
        } elsif( $cmd{SUBCMD} eq '-override') {
            ( $cmd{RESNAME}, $cmd{ATTRNAME} )= @items;
            $cmd{TREE_NODECLASS}= 'ATTR';
            $cmd{TREE_ATTRCLASS}= 'OVERRIDE';
        } elsif( $cmd{SUBCMD} eq '-undooverride') {
            ( $cmd{RESNAME}, $cmd{ATTRNAME} )= @items;
            $cmd{TREE_NODECLASS}= 'ATTR';
            $cmd{TREE_ATTRCLASS}= 'UNDOOVERRIDE';
        } elsif( $cmd{SUBCMD} eq '-local') {
            ( $cmd{RESNAME}, $cmd{ATTRNAME} )= @items;
            $cmd{TREE_NODECLASS}= 'ATTR';
            $cmd{TREE_ATTRCLASS}= 'LOCAL';
        } else {
            $cmd{CONTENT}= join( ' ', @items);
            $cmd{TREE_BRANCH}= 'OTHER';
            return \%cmd;
        }
        $cmd{TREE_NODENAME}= $cmd{RESNAME};
        return \%cmd;
    }
    # commands for clusters
    if( $cmd{CMD} eq 'haclus') {
        $cmd{CONTENT}= join( ' ', @items);
        $cmd{TREE_BRANCH}= 'CLUS';
        return \%cmd;
    }
    # commands for systems
    if( $cmd{CMD} eq 'hasys') {
        $cmd{CONTENT}= join( ' ', @items);
        $cmd{TREE_BRANCH}= 'SYS';
        return \%cmd;
    }

    # others
    $cmd{CONTENT}= join( ' ', @items);
    $cmd{TREE_BRANCH}= 'OTHER';
    return \%cmd;
}

# Responsibility: To serialize the cmd object to a string line
# Input:          Ha command line name
# Output:         A string line of serialized ha cmd
sub dynupgrade_export_ha_cmd {
    my ($cmd_ref) = @_;
    my %cmd= %$cmd_ref;
    my $line= '';

    if( !%cmd ) {
        return $line;
    }

    $line.= "$cmd{CMD}" . " $cmd{SUBCMD}";
    # cluster/system/other types firstly
    if( $cmd{TREE_BRANCH} eq 'CLUS' ||
        $cmd{TREE_BRANCH} eq 'SYS' ||
        $cmd{TREE_BRANCH} eq 'OTHER' ) {
        $line.= " $cmd{CONTENT}";
        return $line."\n";
    }
    if( $cmd{CMD} eq 'hatype') {
        if( $cmd{SUBCMD} eq '-add' ) {
            $line.= " $cmd{TYPENAME}";
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-modify' ) {
            $line.= " $cmd{TYPENAME}"." $cmd{ATTRNAME}"." $cmd{ATTRVAL}";
            return $line."\n";
        }
    }
    if( $cmd{CMD} eq 'haattr') {
        if( $cmd{SUBCMD} eq '-add') {
            if( defined $cmd{ATTRPRETYPE}) {
                $line.= " $cmd{ATTRPRETYPE}";
            }
            $line.= " $cmd{TYPENAME}"." $cmd{ATTRNAME}";
            if( defined $cmd{ATTRVALTYPE} ) {
                $line.= " $cmd{ATTRVALTYPE}";
            }
            if( defined $cmd{ATTRVALDIM}) {
                $line.= " $cmd{ATTRVALDIM}";
            }
            if( defined $cmd{ATTRVAL}) {
                $line.= " $cmd{ATTRVAL}";
            }
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-default') {
            $line.= " $cmd{TYPENAME}"." $cmd{ATTRNAME}";
            if( defined $cmd{ATTRVAL}) {
                $line.= " $cmd{ATTRVAL}";
            }
            return $line."\n";
        }
    }
    if( $cmd{CMD} eq 'hagrp') {
        if( $cmd{SUBCMD} eq '-add') {
            $line.= " $cmd{TYPENAME}";
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-modify') {
            $line.= " $cmd{TYPENAME}"." $cmd{ATTRNAME}";
            if ($cmd{TREE_NODECLASS} eq 'FILE') {
                return $line." $cmd{ATTRVAL}\n";
            }
            if( defined $cmd{ATTRVAL} && scalar(@{$cmd{ATTRVAL}})> 0 ) {
                my $idx;
                for( $idx=0; $idx< scalar(@{$cmd{ATTRVAL}})-1; $idx++ ) {
                    $line.= " $cmd{ATTRVAL}->[$idx]". "\n" . "$cmd{CMD}". " $cmd{SUBCMD}". " $cmd{TYPENAME}"." $cmd{ATTRNAME}";
                }
                $line.= " $cmd{ATTRVAL}->[$idx]";
            }
            return $line."\n";
        }
        # GRP_LINK
        if( $cmd{SUBCMD} eq '-link') {
            $line.= " $cmd{GRPPARENT}"." $cmd{GRPCHILD}"." $cmd{GDCATEGORY}"." $cmd{GDLOCATION}"." $cmd{GDTYPE}";
            return $line."\n";
        }
    }
    if( $cmd{CMD} eq 'hares') {
        if( $cmd{SUBCMD} eq '-add') {
            $line.= " $cmd{RESNAME}"." $cmd{RESTYPE}"." $cmd{SERVGRP}";
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-modify') {
            $line.= " $cmd{RESNAME}"." $cmd{ATTRNAME}";
            if ($cmd{TREE_NODECLASS} eq 'FILE') {
                return $line." $cmd{ATTRVAL}\n";
            }
            if( defined $cmd{ATTRVAL} && scalar(@{$cmd{ATTRVAL}})> 0 ) {
                my $idx;
                for( $idx=0; $idx< scalar(@{$cmd{ATTRVAL}})-1; $idx++ ) {
                    $line.= " $cmd{ATTRVAL}->[$idx]". "\n" . "$cmd{CMD}". " $cmd{SUBCMD}". " $cmd{RESNAME}"." $cmd{ATTRNAME}";
                }
                $line.= " $cmd{ATTRVAL}->[$idx]";
            }
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-override') {
            $line.= " $cmd{RESNAME}"." $cmd{ATTRNAME}";
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-undooverride') {
            $line.= " $cmd{RESNAME}"." $cmd{ATTRNAME}";
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-local') {
            $line.= " $cmd{RESNAME}"." $cmd{ATTRNAME}";
            return $line."\n";
        }
        if( $cmd{SUBCMD} eq '-link') {
            $line.= " $cmd{RESPARENT}"." $cmd{RESCHILD}";
            return $line."\n";
        }
    }
    #error
    Msg::log("Cannot get effective command [$cmd{CMD}] and sub command [$cmd{SUBCMD}]\n");
    return '';
}

# Responsibility: To delete an item from array according to the index
# Input:          Array reference; index
# Output:         N/A
sub dynupgrade_del_from_array_by_index {
    my ($arrayref,$idx) = @_;
    # over bridge
    if( $idx< 0 || $idx > $#{$arrayref} ) {
        return $arrayref;
    }
    @{$arrayref}=(@{$arrayref}[0..$idx-1], @{$arrayref}[$idx+1..$#{$arrayref}]);
    return $arrayref;
}

# Responsibility: To compare ha command objects
# Input:          command object
# Output:         compared string result
sub dynupgrade_compare_ha_cmds {
    my ($cmd1_ref,$cmd2_ref) = @_;
    my %cmd1= %$cmd1_ref;
    my %cmd2= %$cmd2_ref;

    if( $cmd1{CMD} eq 'hatype' && $cmd2{CMD} eq 'hatype') {
        if( $cmd1{SUBCMD} eq '-add' && $cmd2{SUBCMD} eq '-add') {
            if( $cmd1{TYPENAME} eq $cmd2{TYPENAME}) {
                return 'EQUAL_TYPE_ADD_TYPENAME';
            }
            return 'EQUAL_TYPE_ADD';
        }
        if( $cmd1{SUBCMD} eq '-modify' && $cmd2{SUBCMD} eq '-modify') {
            if( $cmd1{TYPENAME} eq $cmd2{TYPENAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    if( $cmd1{ATTRVAL} eq $cmd2{ATTRVAL}) {
                        return 'EQUAL_TYPE_MODIFY_TYPENAME_ATTRNAME_ATTRVAL';
                    }
                    return 'EQUAL_TYPE_MODIFY_TYPENAME_ATTRNAME';
                }
                return 'EQUAL_TYPE_MODIFY_TYPENAME';
            }
            return 'EQUAL_TYPE_MODIFY';
        }
        return 'EQUAL_TYPE';
    }
    if( $cmd1{CMD} eq 'haattr' && $cmd2{CMD} eq 'haattr') {
        if( $cmd1{SUBCMD} eq '-add' && $cmd2{SUBCMD} eq '-add') {
            if( $cmd1{TYPENAME} eq $cmd2{TYPENAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    if( $cmd1{ATTRVAL} eq $cmd2{ATTRVAL} &&
                        $cmd1{ATTRPRETYPE} eq $cmd2{ATTRPRETYPE} &&
                        $cmd1{ATTRVALTYPE} eq $cmd2{ATTRVALTYPE} &&
                        $cmd1{ATTRVALDIM} eq $cmd2{ATTRVALDIM} ) {
                        return 'EQUAL_ATTR_ADD_TYPENAME_ATTRNAME_ATTRVAL';
                    }
                    return 'EQUAL_ATTR_ADD_TYPENAME_ATTRNAME';
                }
                return 'EQUAL_ATTR_ADD_TYPENAME';
            }
            return 'EQUAL_ATTR_ADD';
        }
        if( $cmd1{SUBCMD} eq '-default' && $cmd2{SUBCMD} eq '-default') {
            if( $cmd1{TYPENAME} eq $cmd2{TYPENAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    if( $cmd1{ATTRVAL} eq $cmd2{ATTRVAL} ) {
                        return 'EQUAL_ATTR_DEFAULT_TYPENAME_ATTRNAME_ATTRVAL';
                    }
                    return 'EQUAL_ATTR_DEFAULT_TYPENAME_ATTRNAME';
                }
                return 'EQUAL_ATTR_DEFAULT_TYPENAME';
            }
            return 'EQUAL_ATTR_DEFAULT';
        }
        return 'EQUAL_ATTR';
    }
    if( $cmd1{CMD} eq 'hagrp' && $cmd2{CMD} eq 'hagrp') {
        if( $cmd1{SUBCMD} eq '-add' && $cmd2{SUBCMD} eq '-add') {
            if( $cmd1{TYPENAME} eq $cmd2{TYPENAME}) {
                return 'EQUAL_GRP_ADD_TYPENAME';
            }
            return 'EQUAL_GRP_ADD';
        }
        if( $cmd1{SUBCMD} eq '-modify' && $cmd2{SUBCMD} eq '-modify') {
            if( $cmd1{TYPENAME} eq $cmd2{TYPENAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    if( $cmd1{ATTRVAL} eq $cmd2{ATTRVAL}) {
                        return 'EQUAL_GRP_MODIFY_TYPENAME_ATTRNAME_ATTRVAL';
                    }
                    return 'EQUAL_GRP_MODIFY_TYPENAME_ATTRNAME';
                }
                return 'EQUAL_GRP_MODIFY_TYPENAME';
            }
            return 'EQUAL_GRP_MODIFY';
        }
        if( $cmd1{SUBCMD} eq '-link' && $cmd2{SUBCMD} eq '-link') {
            if( $cmd1{GRPPARENT} eq $cmd2{GRPPARENT}) {
                if( $cmd1{GRPCHILD} eq $cmd2{GRPCHILD}) {
                    return 'EQUAL_GRP_LINK_GRPPARENT_GRPCHILD';
                }
                return 'EQUAL_GRP_LINK_GRPPARENT';
            }
            return 'EQUAL_GRP_LINK';
        }
        return 'EQUAL_GRP';
    }
    if( $cmd1{CMD} eq 'hares' && $cmd2{CMD} eq 'hares') {
        if( $cmd1{SUBCMD} eq '-add' && $cmd2{SUBCMD} eq '-add') {
            if( $cmd1{RESNAME} eq $cmd2{RESNAME}) {
                if( $cmd1{RESTYPE} eq $cmd2{RESTYPE}) {
                    if( $cmd1{SERVGRP} eq $cmd2{SERVGRP}) {
                        return 'EQUAL_RES_ADD_RESNAME_RESTYPE_SERVGRP';
                    }
                    return 'EQUAL_RES_ADD_RESNAME_RESTYPE';
                }
                return 'EQUAL_RES_ADD_RESNAME';
            }
            return 'EQUAL_RES_ADD';
        }
        if( $cmd1{SUBCMD} eq '-modify' && $cmd2{SUBCMD} eq '-modify') {
            if( $cmd1{RESNAME} eq $cmd2{RESNAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    if( $cmd1{ATTRVAL} eq $cmd2{ATTRVAL}) {
                        return 'EQUAL_RES_MODIFY_RESNAME_ATTRNAME_ATTRVAL';
                    }
                    return 'EQUAL_RES_MODIFY_RESNAME_ATTRNAME';
                }
                return 'EQUAL_RES_MODIFY_RESNAME';
            }
            return 'EQUAL_RES_MODIFY';
        }
        if( $cmd1{SUBCMD} eq '-override' && $cmd2{SUBCMD} eq '-override') {
            if( $cmd1{RESNAME} eq $cmd2{RESNAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    return 'EQUAL_RES_OVERRIDE_RESNAME_ATTRNAME';
                }
                return 'EQUAL_RES_OVERRIDE_RESNAME';
            }
            return 'EQUAL_RES_OVERRIDE';
        }
        if( $cmd1{SUBCMD} eq '-undooverride' && $cmd2{SUBCMD} eq '-undooverride') {
            if( $cmd1{RESNAME} eq $cmd2{RESNAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    return 'EQUAL_RES_UNDOOVERRIDE_RESNAME_ATTRNAME';
                }
                return 'EQUAL_RES_UNDOOVERRIDE_RESNAME';
            }
            return 'EQUAL_RES_UNDOOVERRIDE';
        }
        if( $cmd1{SUBCMD} eq '-local' && $cmd2{SUBCMD} eq '-local') {
            if( $cmd1{RESNAME} eq $cmd2{RESNAME}) {
                if( $cmd1{ATTRNAME} eq $cmd2{ATTRNAME}) {
                    return 'EQUAL_RES_LOCAL_RESNAME_ATTRNAME';
                }
                return 'EQUAL_RES_LOCAL_RESNAME';
            }
            return 'EQUAL_RES_LOCAL';
        }
        if( $cmd1{SUBCMD} eq '-link' && $cmd2{SUBCMD} eq '-link') {
            if( $cmd1{RESPARENT} eq $cmd2{RESPARENT}) {
                if( $cmd1{RESCHILD} eq $cmd2{RESCHILD}) {
                    return 'EQUAL_RES_LINK_RESPARENT_RESCHILD';
                }
                return 'EQUAL_RES_LINK_RESPARENT';
            }
            return 'EQUAL_RES_LINK';
        }
        return 'EQUAL_RES';
    }
    return 'NONE';
}

#
# End: perform vcs upgrade
#

### START OF VXSS SUBROUTINES

# break out here with the -security option, not running normal CPI flow
sub cli_prod_option {
    my ($prod)=@_;
    $prod->security_menu() if (Cfg::opt('security'));
    $prod->securityonenode_menu() if (Cfg::opt('securityonenode'));
    $prod->securitytrust() if (Cfg::opt('securitytrust'));
    $prod->vxfen_option() if (Cfg::opt('fencing'));
    $prod->config_cps() if (Cfg::opt('configcps'));
    $prod->opt_addnode() if (Cfg::opt('addnode'));
    return '';
}

sub web_prod_option {
    my ($prod) = @_;
    $prod->security_menu() if (Cfg::opt('security'));
    $prod->vxfen_option() if (Cfg::opt('fencing'));
    $prod->config_cps() if (Cfg::opt('configcps'));
    $prod->web_opt_addnode() if (Cfg::opt('addnode'));
    return '';
}

sub config_vxss {
    my ($prod)=@_;
    my ($ayn,$msg,$rtn,$cfg,$help,$checked);
    my ($one,$two,$menuopt,$menu);

    $cfg=Obj::cfg();
    # lighten/remove platform block as VCS+VxSS versions are released
    Msg::title();
    $msg=Msg::new("$prod->{name} can be configured in secure mode\n");
    $msg->print;
    $msg=Msg::new("Running $prod->{abbr} in Secure Mode guarantees that all inter-system communication is encrypted, and users are verified with security credentials.\n");
    $msg->print;
    $msg=Msg::new("When running $prod->{abbr} in Secure Mode, NIS and system usernames and passwords are used to verify identity. $prod->{abbr} usernames and passwords are no longer utilized when a cluster is running in Secure Mode.\n");
    $msg->print;
    return '' if Cfg::opt('responsefile');

    $help=Msg::new("Choose 'y' to configure the cluster in secure mode automatically");
    $msg = Msg::new("You can configure it manually later if you are not ready to configure it at this time, refer to $prod->{name} administrator's guide for the commands of manual configuration");
    $help->{msg} .= "\n$msg->{msg}";

    while(1) {
        $msg=Msg::new("Would you like to configure the $prod->{abbr} cluster in secure mode?");
        $ayn=$msg->aynn($help);
        if ($ayn eq 'Y') {
            if(!$checked && !$prod->eat_configure_precheck){
                $msg=Msg::new("Symantec Security Services could not be used.");
                $msg->print;
                Msg::prtc();
                return 1;
            }
            $checked = 1;
            $cfg->{vcs_eat_security} = 1;

            $msg=Msg::new("Configure the cluster in secure mode without fips");
            $one=$msg->{msg};
            $msg=Msg::new("Configure the cluster in secure mode with fips");
            $two=$msg->{msg};
            $menuopt=[$one,$two];
            $msg=Msg::new("Select the option you would like to perform");
            if ($prod->check_solx64_for_fips) {
                $menu = 1;
            } else {
                $menu=$msg->menu($menuopt,1,'',1);
                next if (EDR::getmsgkey($menu,'back'));
            }
            $cfg->{vcs_eat_security_fips} = 1 if ($menu==2);
            last;
        } else {
            delete $cfg->{vcs_eat_security};
            delete $cfg->{vcs_eat_security_fips};
            last;
        }
    }

    return 1;
}

sub get_vxss_cluster {
    my ($prod,$sys,$no_comm_check,$not_stop)=@_;
    my ($syslist,$edr,$msg,$rcs,$cfg,$conf,$sc,$nr,$info);

    $edr=Obj::edr();
    $cfg=Obj::cfg();
    unless ($sys) {
        $sys=${$cfg->{systems}}[0]||$edr->{localsys}->{sys};
        $cfg->{systems}[0] ||= $sys;
        #initialize the input systems now
        $sys=($Obj::pool{"Sys::$sys"}) ? Obj::sys($sys) : Sys->new($sys);
    }
    if (!$edr->transport_sys($sys)) {
        $msg=Msg::new("Cannot communicate with system $sys->{sys}\n");
        $msg->die();
    } else {
        $conf=$prod->get_config_sys($sys);
        unless ($conf) {
            $msg=Msg::new("$prod->{abbr} is not configured on $sys->{sys}\n");
            return $msg if $not_stop;
            $msg->die();
        }
    }
    $info = $prod->get_cluster_info_sys($sys,$conf);
    $info->print;

    $rcs= $conf->{systems};
    $syslist=CPIC::get('systems');
    # generate sys obj according to sysname list
    if ($#$rcs<0) {
        $msg=Msg::new("$prod->{abbr} is not configured on $sys->{sys}\n");
        return $msg if $not_stop;
        $msg->die();
    } else {
        $sc=$sys->cmd("$prod->{bindir}/haclus -value SecureClus");
        $nr=$sys->cmd("$prod->{bindir}/hasys -state | _cmd_grep RUNNING | _cmd_wc -l");
        $nr=~s/\s+//m;
        if (EDRu::isverror($sc)) {
            $msg=Msg::new("$prod->{abbr} is not running on system $sys->{sys}\n");
            return $msg if $not_stop;
            $msg->die();
        } elsif ($nr<($#$rcs+1)) {
            $msg=Msg::new("$prod->{abbr} is not running on all systems in this cluster. All $prod->{abbr} systems must be in RUNNING state.");
            return $msg if $not_stop;
            $msg->die();
        }

        for my $sysname (@$rcs) {
            last if $no_comm_check;
            $sys = ($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname)
                                                 : Sys->new($sysname);
            if (!$edr->transport_sys($sys)) {
                $msg=Msg::new("Cannot communicate with system $sys->{sys}\n");
                $msg->die;
            }
            push (@$syslist,$sys) unless (EDRu::inarr($sys,@$syslist));
        }
    }
    return '';
}

sub is_secure_cluster{
    my ($prod,$sys)=@_;
    my ($mode,$maincf,$rootpath);

#    $mode=$sys->cmd("$prod->{bindir}/haclus -value SecureClus 2>/dev/null");
    $rootpath = Cfg::opt('rootpath');
    $maincf = $sys->readfile("$rootpath/$prod->{maincf}");
    if ($maincf =~ /SecureClus\s*=\s*(\d)/) {
        $mode = $1;
    } else {
        $mode = 0;
    }
    return $mode;
}

sub stop_vcs {
    my ($prod)=@_;
    my ($syslist,$ck,$iter,$maxiters,$msg,$pids,@pids,$stop,$sys);

    $prod->haconf_makerw();
    $prod->freeze_groups();

    $syslist=CPIC::get('systems');
    $sys=$$syslist[0];
    $msg=Msg::new("Stopping $prod->{abbr}");
    $prod->haconf_dumpmakero();
    $stop = $sys->cmd("$prod->{bindir}/hastop -all -force");
    # if there was any error in performing 'hastop -all -force',
    # the error number will be caught in $stop (something like: 'VCS ERROR V-16-1-10026')
    if (EDRu::isverror($stop)) {
        for my $sys (@$syslist) {
            @pids=();
            $pids=$sys->proc_pids('bin/had');
            push @pids, @{$pids} if (@{$pids});
            $pids=$sys->proc_pids('hashadow');
            push @pids, @{$pids} if (@{$pids});
            $sys->kill_pids(@pids);
        }
    }
    # CSG system takes a while to shut down
    # must verify before restart
    $maxiters = 15;
    for my $sys (@$syslist) {
        $iter = 0;
        for (0..$maxiters) {
            $iter++;
            my $had=$prod->proc('had61');
            my $rtn=$had->check_sys($sys);
            last if ($rtn ==0);
            sleep(1);
        }
        if ($iter > $maxiters) {
            # VCS did not stop after $maxiters seconds, even after issuing 'hastop -all -force'
            # kill vcs processes
            @pids=();
            $pids=$sys->proc_pids('bin/had');
            push @pids, @{$pids} if (@{$pids});
            $pids=$sys->proc_pids('hashadow');
            push @pids, @{$pids} if (@{$pids});
            $sys->kill_pids(@pids);
        }
    }
    $msg->display_status();
    return;
}

sub secure_startup {
    my ($prod)=@_;
    my ($cfg,$syslist,$msg,$nr,$pids,$proc,$rc,$status,$sys,$localsys,$tmpdir);

    $cfg = Obj::cfg();
    $syslist=CPIC::get('systems');

    unless (defined $cfg->{vcs_allowcomms}) {
        $sys=$$syslist[0];
        $prod->set_vcs_allowcomms_sys($sys);
    }

    for my $sys (@$syslist) {
        # on Sol, 'svcadm disable/enable vcs' will stop/start CmdServer, and on Sol11, the svcadm may hang: 2783814/2689029
        $sys->cmd('/opt/VRTSvcs/bin/CmdServer -stop') unless ($sys->{padv} =~ /^sol/i);
    }

    $tmpdir=EDR::tmpdir();
    $localsys=$prod->localsys;
    for my $sys (@$syslist) {
        $msg=Msg::new("Starting $prod->{abbr} on $sys->{sys}");
        $localsys->copy_to_sys($sys,"$tmpdir/main.cf",$prod->{maincf});
        sleep(1);
        $proc=$prod->proc('had61');
        $proc->start_sys($sys);
        sleep(1);
        $msg->display_status();
    }

    #Start CmdServer after had/hashadow is started
    for my $sys (@$syslist) {
        $sys->cmd('/opt/VRTSvcs/bin/CmdServer');
    }

    $sys=$$syslist[0];
    $msg=Msg::new("Confirming $prod->{abbr} startup");
    while (($rc<=10) && ($nr<=$#{$syslist})) {
        sleep 6;
        $nr=$sys->cmd("$prod->{bindir}/hasys -state | _cmd_grep RUNNING | _cmd_wc -l");
        $rc++;
    }
    # so all systems have same main.cf
    $prod->haconf_makerw();
    sleep 1;
    $prod->haconf_dumpmakero();
    if ($nr==1) {
        $status=Msg::new("$nr system RUNNING");
    } else {
        $status=Msg::new("$nr systems RUNNING");
    }
    $msg->display_status($status);
    $prod->haconf_makerw();
    $prod->unfreeze_groups();
    $prod->haconf_dumpmakero();
    Msg::n();
    return $nr;
}

sub onenode_startup_sys {
    my ($prod,$sys)=@_;
    my ($cfg,$cpic,$enable_lgf,$msg,$proc,$ret,$status);

    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $enable_lgf = 1;

    # update config files to use one node
    # enable llt/gab/vxfen for one node
    # start had in onenode mode
    $prod->set_onenode_cluster_sys($sys,1,$enable_lgf);
    $cfg->set_value('vcs_allowcomms', 0) if (defined($cfg->{vcs_allowcomms}));
    $msg=Msg::new("Starting $prod->{abbr} in one node mode on $sys->{sys}");
    $proc=$prod->proc('had61');
    if ($cpic->proc_start_sys($sys, $proc)) {
        $status = Msg::new("Done");
        $ret = 0;
    } else {
        $status = Msg::new("Failed");
        $ret = 1;
    }
    $msg->display_status($status);
    $prod->haconf_makerw();
    $prod->unfreeze_groups();
    $prod->haconf_dumpmakero();
    return $ret;
}

sub eat_configure {
    my ($prod)=@_;
    my ($syslist,@processes,$domain_name,$sys);
    my ($domain);

    $prod->eat_initiate(1);
    $syslist = CPIC::get("systems");
    @processes = @{$prod->{eat_processes}};
    $domain_name = $prod->{eat_domain_name};

    if ($prod->{phased_upgraded_system}) {
        # this is phased upgrade 2, so collect the domain and creds from the node of phased 1 cluter
        $sys = $prod->{phased_upgraded_system};
        $sys->cmd("_cmd_mkdir -p $prod->{eat_tempdir}");
        $prod->eat_addnode_collect_domain_creds($sys);
    } else {
    # install embed at RAB =1 and create domain and HAD/CMDSERVER/WAC credentials on NODE1
        $sys = $$syslist[0];
        $prod->eat_install_sys($sys,$prod->{eat_setup},"RAB");
        $prod->eat_start_sys($sys);
        $prod->eat_create_export_domain_sys($sys,$domain_name,$prod->{eat_domain_expiry_year});
        for my $pro (@processes) {
            $prod->eat_create_export_credential_sys($sys,$pro);
        }
    }

    # install embed at RAB =0 and import domain and HAD/CMDSERVER/WAC credentials on NODE2-n
    for my $sys (@$syslist) {
        # skip node1 since it is installed as the source node, EXCEPT for phased upgrade 2
        next if ($sys->system1() && (! $prod->{phased_upgraded_system}));
        $prod->eat_install_sys($sys,$prod->{eat_setup},"NO RAB");
        $prod->eat_import_domain_sys($sys,$domain_name);
        for my $pro (@processes) {
            $prod->eat_import_credential_sys($sys,$pro);
        }
        $prod->eat_start_sys($sys);
    }

    # create directory data/CLIENT; data/TRUST and setuptrust
    for my $sys (@$syslist) {
        $prod->eat_create_client_setuptrust_trust_sys($sys);
    }

    # during fresh configure, this step will be done at sub update_maincf Update main.cf with SecureClus = 1.
    return 1;
}

# upgrade from eat
# all the conf files have been backed up during precheck, so just setup the eat and import the conf files
sub eat_configure_from_eat {
    my ($prod)=@_;
    my ($syslist,@processes,$domain_name,$sys);
    my ($domain);

    $prod->eat_configure_from_eat_atutil_restore;
    return 1;

    $prod->eat_initiate(1);
    $syslist = CPIC::get("systems");
    @processes = @{$prod->{eat_processes}};
    $domain_name = $prod->{eat_domain_name};

    for my $sys (@$syslist) {
        $prod->eat_install_sys($sys,$prod->{eat_setup},"NO RAB");
        $prod->eat_import_domain_sys($sys,$domain_name);
        for my $pro (@processes) {
            $prod->eat_import_credential_sys($sys,$pro);
        }
        $prod->eat_start_sys($sys);
    }

    # create directory data/CLIENT; data/TRUST and setuptrust
    for my $sys (@$syslist) {
        $prod->eat_create_client_setuptrust_trust_sys($sys);
        # modify back the /rootpath/ from the AT files
        $prod->eat_lu_configure_complete_sys($sys) if Cfg::opt('rootpath');
    }

    return 1;
}

# Change export/import to backup/restore for secure cluster, refer to 2791006
sub eat_configure_from_eat_atutil_restore {
    my ($prod)=@_;
    my ($syslist,$fold,$backup,$rootpath,$tmpdir);

    $prod->eat_initiate(1);
    $rootpath = Cfg::opt('rootpath');
    $syslist = CPIC::get("systems");
    $tmpdir = EDR::tmpdir();
    $fold = "$rootpath/var/VRTSvcs/vcsauth";
    $backup = "$tmpdir/vcsauth_atutil_backup";

    for my $sys (@$syslist) {
        $prod->eat_install_sys($sys,$prod->{eat_setup},"NO RAB");
        #restore the conf files
        $sys->cmd("_cmd_rmr $fold");
        $sys->cmd("_cmd_mkdir -p $fold");
        $sys->cmd("_cmd_cpp -rf $backup/* $fold/");
        $prod->eat_start_sys($sys) unless $rootpath;
        # modify back the /rootpath/ from the AT files
        $prod->eat_lu_configure_complete_sys($sys) if $rootpath;
    }

    return 1;
}

sub eat_configure_from_eat_atutil_backup {
    my ($prod)=@_;
    my ($syslist,$fold,$backup,$rootpath,$tmpdir);

    $rootpath = Cfg::opt('rootpath');
    $syslist = CPIC::get("systems");
    $tmpdir = EDR::tmpdir();
    $fold = "$rootpath/var/VRTSvcs/vcsauth";
    $backup = "$tmpdir/vcsauth_atutil_backup";
    for my $sys (@$syslist) {
        $sys->cmd("_cmd_rmr $backup");
        # e3244403: do not dereference symbolic links since the source may be offline
        $sys->cmd("_cmd_cpp -rf $fold $backup");
    }
    return 1;
}

# if the parameter conf_tag set to 1,then related folders will be re-create
sub eat_initiate {
    my ($prod,$conf_tag,$syslist_arg) = @_;
    my ($sys,$syslist);

    for my $sysi (@$syslist_arg) {
        $sys = $sysi;
        $sys = Obj::sys($sysi) unless ref($sysi) eq "Sys";
        push(@$syslist,$sys);
    }

    $prod->{eat_tempdir} = EDR::tmpdir() . '/eat';
    $syslist ||= CPIC::get("systems");
    for my $sys (@$syslist) {
        $sys->cmd("_cmd_mkdir -p $prod->{eat_tempdir}");
        $sys->cmd("_cmd_rm -rf $prod->{eat_data_backup}") if $conf_tag;
        $sys->cmd("_cmd_mkdir -p $prod->{eat_data_backup}");
    }
    EDR::cmd_local("_cmd_mkdir -p $prod->{eat_tempdir}");

    # change the ClusterName to uuid as the domain name. refer to e2551511
    $sys = $$syslist[0];
    my $uuid = $prod->get_uuid_sys($sys);
    if ( $uuid && ($uuid !~ /NO_UUID/m) ) {
        $uuid =~ s/^\{//;
        $uuid =~ s/\}$//;
        Msg::log("Use uuid as cluster name: $uuid");
        $prod->{eat_setup}{ClusterName} = $uuid;
    } elsif ($conf_tag) {
        my $msg = Msg::new("Could not find the valid uuid, check uuid configurations across the cluster.");
        $msg->die;
    }

    # delete this root_hash reference in case that install RAB again but setuptrust with the old RAB root_hash
    delete $prod->{eat_root_hash};
    return;
}

# check if there are enough space in /opt
sub eat_configure_precheck {
    my ($prod,$syslist)=@_;
    my (@txts,$err_txt);

    $syslist ||= CPIC::get("systems");
    for my $sys (@$syslist) {
        $err_txt = $prod->eat_precheck_opt_space_sys($sys);
        push(@txts,$err_txt) if $err_txt;
    }
    if (@txts) {
        $err_txt = join('\n',@txts);
        Msg::print($err_txt);
        return 0;
    }
    return 1;
}

sub eat_precheck_opt_space_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$msg,$free,$inuse);
    $cpic=Obj::cpic();

    $inuse = $sys->cmd("_cmd_du -sk $prod->{eat_setup}{DestDir}");
    $free = $cpic->volumespace_sys($sys,'/opt') || $cpic->volumespace_sys($sys,'/');
    if (($free + $inuse) < $prod->{eat_opt_space_need}) {
        $msg = Msg::new("Not enough space in /opt on system $sys->{sys}.");
        Msg::log("On $sys->{sys} only $free KB for /opt, requirement is $prod->{eat_opt_space_need} KB");
        return $msg->{msg};
    }
    return '';
}

sub eat_install_sys {
    my ($prod,$sys,$eat_setup,$rab_mode)=@_;
    my ($eat_setup_txt,$eat_setup_filename,$eat_source,$eat_broker_setup,$bin_dir,$msg,$path);

    # unzip and tar xvf the source tar.gz file
    $eat_source = $prod->eat_get_source_sys($sys);
    unless ($eat_source) {
        $msg=Msg::new("Could not find the AT source package on system $sys->{sys}");
        $msg->die;
    }

#    $sys->cmd("gunzip -c $eat_source | tar xvf - -C $prod->{eat_tempdir}");
    $sys->cmd("cd $prod->{eat_tempdir}; _cmd_gunzip -c $eat_source | _cmd_tar xvf -");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to un-zip and un-tar the EAT source package on system $sys->{sys}");
        $msg->die;
    }
    $eat_broker_setup = $sys->cmd("_cmd_find $prod->{eat_tempdir} | _cmd_grep broker_setup.sh");
    unless ($eat_broker_setup) {
        $msg=Msg::new("Could not find the broker_setup.sh script on system $sys->{sys}");
        $msg->die;
    }

    $bin_dir = EDRu::dirname($eat_broker_setup);
    $eat_setup->{SourceDir} = $eat_broker_setup;
    # exlude /bin/Linux.2.6.9_x86-64_gcc-3.4.3/broker_setup.sh from ..../VxAT/v6.1.6.0
    $eat_setup->{SourceDir} =~ s/\/[^\/]+\/[^\/]+\/broker_setup.sh$//;

    if (defined $rab_mode) {
        if ($rab_mode eq 'RAB') {
            $rab_mode = '1';
        } else {
            $rab_mode = '0';
        }
        $eat_setup->{SetToRBPlusABorNot} = $rab_mode;
    }

    # set the fips mode
    $eat_setup->{FipsMode} = 1 if $prod->{fips};

    # prepare the configuration setup file
    $eat_setup_filename = "$prod->{eat_tempdir}/eat_setup";
    for my $key (sort keys %$eat_setup) {
        $eat_setup_txt .= "$key=$eat_setup->{$key}\n";
    }
    $sys->writefile($eat_setup_txt,$eat_setup_filename);
    $sys->cmd("_cmd_cat $eat_setup_filename");

    $prod->eat_stop_sys($sys);
    $path = $prod->eat_check_env_path_sys($sys);
    $sys->cmd("cd $bin_dir;$path ./broker_setup.sh $eat_setup_filename");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to install EAT on system $sys->{sys}");
        $msg->die;
    }
    # modify the default file path of vcsauthserver log
    $sys->cmd("$prod->{eat_setup}{DestDir}/bin/vssregctl -s -f $prod->{eat_setup}{DataDir}/root/.VRTSat/profile/VRTSatlocal.conf -b 'Security\\Authentication\\Authentication Broker' -k UpdatedDebugLogFileName -v $prod->{eat_log_file} -t string");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to change the vcsauthserver log path on system $sys->{sys}");
        $msg->die;
    }
    return 1;
}

sub eat_get_source_sys {
    my ($prod,$sys)=@_;
    my ($eat_source_dir,$eat_source);

    $eat_source_dir = $prod->{eat_vcs_bin};
    $eat_source = $sys->cmd("_cmd_ls $eat_source_dir | _cmd_grep VxAT | _cmd_grep tar.gz");
    $eat_source = "$eat_source_dir/$eat_source" if $eat_source;
    return $eat_source;
}

#   the sh file broker_setup.sh will use cp -f, the VRTS cp denies -f, so check if the cp is from VRTS
#   refer to e2403644
sub eat_check_env_path_sys {
    my ($prod,$sys)=@_;
    my ($cmd,$cmd_flag,$path,$cmd_path,$msg);

    $cmd = "cp";
    $cmd_flag = "-rpf";
    $sys->cmd("_cmd_touch $prod->{eat_tempdir}/$cmd 1>/dev/null 2>&1");
    $sys->cmd("$cmd $cmd_flag $prod->{eat_tempdir}/$cmd $prod->{eat_tempdir}/$cmd.new 2>&1");
    if (EDR::cmdexit()) {
        $cmd_path = $sys->cmdswap("_cmd_$cmd");
        $cmd_path = EDRu::dirname($cmd_path);
        $path = "PATH=$cmd_path:\$PATH";
        $sys->cmd("$path $cmd $cmd_flag $prod->{eat_tempdir}/$cmd $prod->{eat_tempdir}/$cmd.new 2>&1");
        if (EDR::cmdexit()) {
            $msg=Msg::new("Could not run command 'cp'. Check the enviroment.");
            $msg->die;
        }
        return $path;
    }

    return '';
}

sub eat_start_sys {
    my ($prod,$sys)=@_;
    my ($eat_exe,$eat_sh,$eat_exe_orig,$eat_sh_orig,$pids);

    $eat_exe = "$prod->{eat_setup}{DestDir}/bin/$prod->{eat_setup}{BrokerExeName}";
    $eat_sh = "$eat_exe.sh";
    if (Cfg::opt('rootpath')) {
        $eat_exe_orig = "$prod->{eat_DestDir_orig}/bin/$prod->{eat_setup}{BrokerExeName}";
        $eat_sh_orig = "$eat_exe_orig.sh";
        # kill vcsauthserver in PBE
        $pids = $sys->proc_pids($eat_exe_orig);
        if (scalar @$pids) {
            $sys->kill_pids(@$pids);
            $sys->{eat_lu_pbe_running} = 1;
        }
    }

    $sys->cmd($eat_sh);
    return;
}

sub eat_stop_sys {
    my ($prod,$sys)=@_;
    my ($eat_sh,$eat_exe,$pids,$msg,$port,$eat_exe_orig,$eat_sh_orig,$killpids);

    $eat_exe = "$prod->{eat_setup}{DestDir}/bin/$prod->{eat_setup}{BrokerExeName}";
    $eat_sh = "$eat_exe.sh";
    $port = $prod->{eat_setup}{IPPort};

    $pids=$sys->proc_pids("$eat_exe");
    $killpids = $sys->kill_pids(@$pids);
    if (@$killpids) {
        $msg=Msg::new("Process $eat_exe on $sys->{sys} could not be stopped. A secure cluster could not be configured.");
        $msg->die;
    }

    if (Cfg::opt('rootpath')) {
        $eat_exe_orig = "$prod->{eat_DestDir_orig}/bin/$prod->{eat_setup}{BrokerExeName}";
        $eat_sh_orig = "$eat_exe_orig.sh";
        # kill vcsauthserver in PBE
        $pids = $sys->proc_pids($eat_exe_orig);
        if (scalar @$pids) {
            $killpids = $sys->kill_pids(@$pids);
            $sys->{eat_lu_pbe_running} = 1;
            if (@$killpids) {
                $msg=Msg::new("Process $eat_exe_orig on $sys->{sys} could not be stopped. A secure cluster could not be configured.");
                $msg->die;
            }
        }
    }

    # check if the EAT port is still listened, if so, error out
    if (EDRu::is_port_connectable($sys->{sys},$port)) {
        Msg::log("Port $port on $sys->{sys} is being used. Secure cluster configuration may fail.");
    }
    return;
}

sub eat_create_export_domain_sys {
    my ($prod,$sys,$domain_name,$expire)=@_;
    $prod->eat_create_domain_sys($sys,$domain_name,$expire);
    $prod->eat_export_domain_sys($sys,$domain_name);
    return;
}

# this sub will explicitly return the un-initialized env variables
sub eat_get_env {
    my ($prod,@env) = @_;
    my (@eat_env,@out,$out);

    @out = @env;
    @eat_env = qw(EAT_DATA_DIR EAT_HOME_DIR);
    # add the above env, if they are not in the parameters.
    $out = join(' ',@out);
    for my $eat_env (@eat_env) {
        push(@out,"$eat_env=''") unless ($out =~ /\b$eat_env=/);
    }
    $out = join(' ',@out);
    return $out;
}

sub eat_create_domain_sys {
    my ($prod,$sys,$domain_name,$expire)=@_;
    my ($vssat,$eat_env);

    $eat_env = $prod->eat_get_env;
    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $expire = "-c " . $expire*365*24*60*60 if $expire;

    $sys->cmd("$eat_env $vssat createpd -t ab -d $domain_name $expire");
    return;
}

sub eat_export_domain_sys {
    my ($prod,$sys,$domain_name)=@_;
    my ($atutil,$file,$backup_file);

    $atutil = "$prod->{eat_setup}{DestDir}/bin/atutil";
    $file = "$prod->{eat_tempdir}/$domain_name";
    $backup_file = "$prod->{eat_data_backup}/$domain_name";

    $sys->cmd("$atutil export -b -z $prod->{eat_setup}{DataDir} -f $file -p password");
    $sys->copyfile($file, $backup_file);
    $sys->copy_to_sys($prod->localsys,$file);
    return;
}

sub eat_create_export_credential_sys {
    my ($prod,$sys,$pro,$expire)=@_;
    $prod->eat_create_credential_sys($sys,$pro,$expire);
    $prod->eat_export_credential_sys($sys,$pro);
    return;
}

sub eat_create_credential_sys {
    my ($prod,$sys,$pro,$expire)=@_;
    my ($pro_dir,$pro_prpl,$vssat,$root_hash,$eat_env,$eat_env0,$msg);

    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $pro_dir = "$prod->{eat_data_root}/$pro";
    $pro_prpl = $pro;
    $expire = "-e " . $expire*365*24*60*60 if $expire;

    $sys->cmd("_cmd_rm -rf $pro_dir");
    $sys->cmd("_cmd_mkdir $pro_dir");
    $eat_env0 = $prod->eat_get_env;
    $sys->cmd("$eat_env0 $vssat addprpl -t ab -d $prod->{eat_domain_name} -p $pro_prpl -s password $expire -q service");

    # get the root hash
    $root_hash = $prod->eat_get_root_hash_sys($sys);

    $eat_env = $prod->eat_get_env("EAT_DATA_DIR='$pro_dir'");
    $sys->cmd("$eat_env $vssat setuptrust -b 127.0.0.1:$prod->{eat_setup}{IPPort} -s high -r $root_hash");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to set up trust for $pro on system $sys->{sys}");
        $msg->die;
    }
    $prod->eat_credential_enablefips($sys,$pro);
    $sys->cmd("$eat_env $vssat authenticate -d vx:$prod->{eat_domain_name} -p $pro_prpl -s password -b 127.0.0.1:$prod->{eat_setup}{IPPort}");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to authenticate principle for $pro on system $sys->{sys}");
        $msg->die;
    }

    # delete the prpl, it is useless as the credential is created
    $sys->cmd("$eat_env0 $vssat deleteprpl -t ab -d $prod->{eat_domain_name} -p $pro_prpl -s");
    return;
}

# enable the fips if -fips
sub eat_credential_enablefips {
    my ($prod,$sys,$pro)=@_;
    my ($pro_dir,$pro_prpl,$vssat,$eat_env,$msg);

    return 1 unless $prod->{fips};

    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $pro_dir = "$prod->{eat_data_root}/$pro";
    $pro_prpl = $pro;

    $eat_env = $prod->eat_get_env("EAT_DATA_DIR='$pro_dir'");
    $sys->cmd("$eat_env $vssat setfipsmode -e");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to enable security with fips mode for $pro on system $sys->{sys}");
        $msg->die;
    }

    return 1;
}

sub eat_get_root_hash_sys {
    my ($prod,$sys)=@_;
    my ($root_hash,$vssat,$eat_env);

    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $eat_env = $prod->eat_get_env;
    unless ($prod->{eat_root_hash}{$sys->{sys}}) {
        $root_hash = $sys->cmd("$eat_env $vssat showbrokerhash | _cmd_grep 'Root Hash'");
        if ($root_hash =~ /Root Hash:\s*(\S+)\s*$/) {
            $prod->{eat_root_hash}{$sys->{sys}} = $1;
        } else {
            Msg::log("Failed to get root_hash, showbrokerhash failed on $sys->{sys}");
            return "";
        }
    }
    return $prod->{eat_root_hash}{$sys->{sys}};
}

sub eat_export_credential_sys {
    my ($prod,$sys,$pro)=@_;
    my ($pro_dir,$pro_prpl,$atutil,$file,$backup_file);

    $atutil = "$prod->{eat_setup}{DestDir}/bin/atutil";
    $pro_dir = "$prod->{eat_data_root}/$pro";
    $pro_prpl = $pro;
    $file = "$prod->{eat_tempdir}/$pro_prpl";
    $backup_file = "$prod->{eat_data_backup}/$pro_prpl";
    if (!$sys->is_dir($prod->{eat_tempdir})){
        $sys->mkdir($prod->{eat_tempdir});
    }
    $sys->cmd("$atutil export -c -z $pro_dir -f $file -p password");
    $sys->cmd("_cmd_cp -rf $file $backup_file");
    my $localsys=$prod->localsys;
    if (!$localsys->is_dir($prod->{eat_tempdir})) {
        EDR::cmd_local("_cmd_mkdir -p $prod->{eat_tempdir}");
    }
    $sys->copy_to_sys($localsys,$file);
    return;
}

sub eat_import_domain_sys {
    my ($prod,$sys,$domain_name,$file)=@_;
    my ($atutil,$backup_file,$msg);

    $atutil = "$prod->{eat_setup}{DestDir}/bin/atutil";
    $file ||= "$prod->{eat_tempdir}/$domain_name";
    $backup_file = "$prod->{eat_data_backup}/$domain_name";

    $prod->localsys->copy_to_sys($sys,$file);
    $sys->cmd("$atutil import -z $prod->{eat_setup}{DataDir} -f $file -p password");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to import private domain with $file on system $sys->{sys}");
        $msg->die;
    }
    $sys->copyfile($file,$backup_file);
    return;
}

sub eat_import_credential_sys {
    my ($prod,$sys,$pro,$file)=@_;
    my ($pro_dir,$pro_prpl,$atutil,$backup_file,$msg);

    $atutil = "$prod->{eat_setup}{DestDir}/bin/atutil";
    $pro_dir = "$prod->{eat_data_root}/$pro";
    $pro_prpl = $pro;
    $file ||= "$prod->{eat_tempdir}/$pro_prpl";
    $backup_file = "$prod->{eat_data_backup}/$pro_prpl";

    $sys->cmd("_cmd_rm -rf $pro_dir");
    $sys->cmd("_cmd_mkdir $pro_dir");
    $prod->localsys->copy_to_sys($sys,$file);
    $sys->cmd("$atutil import -z $pro_dir -f $file -p password");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to import credential with $file on system $sys->{sys}");
        $msg->die;
    }

    # the import will not import the fips, VxAT team want to fix this, but may not catch stratus timeframe, so fix in CPI
    $prod->eat_credential_enablefips($sys,$pro);
    $sys->cmd("_cmd_cp -rf $file $backup_file");
    return;
}

sub eat_create_client_setuptrust_trust_sys {
    my ($prod,$sys)=@_;
    my ($vssat,$client_dir,$trust_dir,$eat_env,$root_hash);

    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $client_dir = "$prod->{eat_data_root}/CLIENT";
    $trust_dir = "$prod->{eat_data_root}/TRUST";

    $sys->cmd("_cmd_rm -rf $client_dir");
    $sys->cmd("_cmd_mkdir $client_dir");
    $sys->cmd("_cmd_rm -rf $trust_dir");
    $sys->cmd("_cmd_mkdir $trust_dir");

    $eat_env = $prod->eat_get_env("EAT_DATA_DIR='$trust_dir'");
    # get the root hash
    $root_hash = $prod->eat_get_root_hash_sys($sys);
    $sys->cmd("$eat_env $vssat setuptrust -b 127.0.0.1:$prod->{eat_setup}{IPPort} -s high -r $root_hash");
    $prod->eat_credential_enablefips($sys,'TRUST');
    return;
}

sub eat_maincf_secure_sys {
    my ($prod,$sys)=@_;
    my ($maincf,$cfg,$tmpdir,$clustername);

    $cfg=Obj::cfg();
    $maincf=$sys->cmd("_cmd_cat $prod->{maincf}");
    if ($maincf=~/SecureClus\s*=\s*0/) {
        $maincf=~s/SecureClus\s*=\s*0/SecureClus = 1/;
    } else {
        $clustername||=$sys->cmd("_cmd_grep '^cluster' $prod->{maincf} | _cmd_awk '{print \$2}'");
        $maincf=~s/cluster\s+$clustername\s*\(/cluster $clustername \(\n\tSecureClus = 1/;
    }

    # add -secure for wac, there should be only one wac in main.cf
    $maincf =~ s{/opt/VRTSvcs/bin/wacstart}{/opt/VRTSvcs/bin/wacstart -secure}g unless $maincf =~ m{/opt/VRTSvcs/bin/wacstart\s+-secure};
    $maincf =~ s{/opt/VRTSvcs/bin/wac\b}{/opt/VRTSvcs/bin/wac -secure}g unless $maincf =~ m{/opt/VRTSvcs/bin/wac\s+-secure};

    $tmpdir=EDR::tmpdir();
    EDRu::writefile($maincf, "$tmpdir/main.cf", 1);
    return;
}

sub eat_maincf_unsecure_sys {
    my ($prod,$sys)=@_;
    my ($maincf,$tmpdir);

    $maincf=$sys->cmd("_cmd_cat $prod->{maincf}");
    $maincf=~s/SecureClus\s*=\s*1/SecureClus = 0/;

    # remove -secure for wac
    $maincf =~ s{/opt/VRTSvcs/bin/wacstart\s+-secure}{/opt/VRTSvcs/bin/wacstart}g;
    $maincf =~ s{/opt/VRTSvcs/bin/wac\s+-secure}{/opt/VRTSvcs/bin/wac}g;

    $tmpdir=EDR::tmpdir();
    EDRu::writefile($maincf, "$tmpdir/main.cf", 1);
    return;
}

# this sub is not intended to use in rootpath mode
sub eat_check_secure_clus {
    my ($prod) = @_;
    my ($syslist,$cred,$cred0);

    $prod->eat_initiate();
    $syslist = CPIC::get("systems");
    for my $sys (@$syslist) {
        $cred = $prod->eat_check_secure_sys($sys);
        return 0 unless $cred;
        if ($cred0) {
            return 0 unless $cred0->{uuid} eq $cred->{uuid};
        } else {
            $cred0 = $cred;
        }
    }
    return 1;
}

sub eat_check_secure_sys {
    my ($prod,$sys)=@_;
    my ($eat_exe,@processes,$vssat,$client_dir,$trust_dir,$eat_env);
    my ($rb_cred,$cred,$showcred,$showalltrustedcreds,$cred_prev);

    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $showcred = "showcred";
    $showalltrustedcreds = "showalltrustedcreds";
    $client_dir = "$prod->{eat_data_root}/CLIENT";
    $trust_dir = "$prod->{eat_data_root}/TRUST";
    $eat_env = $prod->eat_get_env;

    # check if vssat.sh exist
    $eat_exe = "$prod->{eat_setup}{DestDir}/bin/$prod->{eat_setup}{BrokerExeName}.sh";
    return 0 unless $sys->exists($eat_exe);

    # check if bkup file contains required files
    return 0 if $prod->eat_check_bkup_error_sys($sys);

    # check the domain
    $sys->cmd("$eat_env $vssat showpd -t ab -d $prod->{eat_domain_name}");
    return 0 if EDR::cmdexit();

    # get the root rb cred
    $rb_cred = $prod->eat_get_cred_by_subcommand_pro_sys($sys,$showalltrustedcreds);
    return 0 unless $rb_cred;

    # check the CLIENT and TRUST folder
    return 0 unless $sys->is_dir($client_dir) && $sys->is_dir($trust_dir);
    $cred = $prod->eat_get_cred_by_subcommand_pro_sys($sys,$showalltrustedcreds,'','TRUST');
    return 0 unless $cred;

    @processes = @{$prod->{eat_processes}};
    for my $pro (@processes) {
        $cred = $prod->eat_get_cred_by_subcommand_pro_sys($sys,$showcred,$pro,$pro);
        $cred_prev||=$cred;
        return 0 unless $cred && ($cred_prev->{uuid} eq $cred->{uuid});
    }

    return $cred;
}

sub eat_get_uuiddomain_sys {
    my ($prod,$sys,$pro)=@_;
    my ($cred,$eat_uuid_domain);

    $pro ||= 'CPSADM';
    $cred = $prod->eat_get_cred_by_subcommand_pro_sys($sys,'showcred',$pro,$pro);
    if ($cred) {
        $eat_uuid_domain = $cred->{domain_name};
    } else {
        $eat_uuid_domain = '';
    }
    return $eat_uuid_domain;
}

sub eat_get_cred_by_subcommand_pro_sys {
    my ($prod,$sys,$cmd,$name,$pro)=@_;
    my ($vssat,$pro_dir,$eat_env,@rtns,$count,$cred);

    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $name ||= $prod->{eat_setup}{RootBrokerName};
    if ($pro) {
        $pro_dir = "$prod->{eat_data_root}/$pro";
        $eat_env = $prod->eat_get_env("EAT_DATA_DIR='$pro_dir'");
    } else {
        $eat_env = $prod->eat_get_env;
    }

    @rtns = split(/\n/,$sys->cmd("$eat_env $vssat $cmd"));
    $count = -1;
    while ($count < scalar @rtns) {
        $count++;
        last if $rtns[$count] =~ /^User Name:\s*$name/;
    }

    while ($count < scalar @rtns) {
        $count++;
        last unless $rtns[$count];
        if ($rtns[$count] =~ /^Certificate Hash\s+(\S+)/) {
            $cred->{hash} = $1;
        } elsif ($rtns[$count] =~ /^UUID:\s+(\S+)/) {
            $cred->{uuid} = $1;
        } elsif ($rtns[$count] =~ /^Domain Name:\s+(\S+)/) {
            $cred->{domain_name} = $1;
        }
    }

    return $cred if $cred->{hash} && $cred->{uuid};
    return 0;
}

sub eat_update_CmdServer_secure_file {
    my ($prod,$syslist_arg)=@_;
    my ($sys,$cfg,$syslist);

    for my $sysi (@$syslist_arg) {
        $sys = Obj::sys($sysi) unless ref($sysi) eq "Sys";
        push(@$syslist,$sys);
    }

    $cfg=Obj::cfg();
    $syslist ||= CPIC::get("systems");

    for my $sys (@$syslist) {
        if ($prod->{eat_enable} || $cfg->{vcs_eat_security}) {
            $sys->cmd("_cmd_touch $prod->{secure}");
        } else {
            $sys->cmd("_cmd_rmr $prod->{secure}");
        }
    }
    return 1;
}

sub eat_enable {
    my ($prod)=@_;
    my ($syslist,$sys,$msg,$nsys,$mode,$sec_or_fips);

    $syslist=CPIC::get("systems");
    $sys=$$syslist[0];

    if ($prod->{fips}) {
        $sec_or_fips = Msg::new("security with fips")->{msg};
    } else {
        $sec_or_fips = Msg::new("secure")->{msg};
    }

    unless($prod->eat_configure_precheck){
        $msg=Msg::new("Failed to pass the precheck for $sec_or_fips cluster configuration.");
        $msg->die;
    }

    # delete all cluster users during transform
    $msg=Msg::new("Deleting cluster users for $prod->{abbr}");
    $prod->eat_delete_cluster_users($sys);
    $msg->display_status();

    $msg=Msg::new("Configuring a $sec_or_fips cluster for $prod->{abbr}");
    # do not re-install and re-create credentials and so on if they already exist
    # do re-install if fips
    if (!$prod->{fips} && $prod->eat_check_secure_clus()) {
        # stop and start eat, in case they are stop. This could be deleted if eat process start/stop added into vcs
        for my $sysi (@$syslist) {
            $prod->eat_stop_sys($sysi);
            $prod->eat_start_sys($sysi);
        }
    } else {
        $prod->eat_configure();
    }
    $msg->display_status();

    $prod->stop_vcs();
    # modify main.cf
    $msg=Msg::new("Updating $prod->{abbr} configuration");
    $prod->eat_maincf_secure_sys($sys);
    $prod->eat_update_CmdServer_secure_file();
    $msg->display_status();

    $nsys=$prod->secure_startup();
    $mode=$sys->cmd("$prod->{bindir}/haclus -value SecureClus");
    if (($mode==1) && ($nsys==$#{$syslist}+1)) {
        $msg=Msg::new("Succeeded to enable $sec_or_fips mode\n");
        $msg->bold;
    } else {
        $msg=Msg::new("Failed to enable $sec_or_fips mode\n");
        $msg->bold;
    }
    return;
}

sub eat_disable {
    my ($prod)=@_;
    my ($syslist,$sys,$msg,$nsys,$mode,$sec_or_fips);

    $syslist=CPIC::get("systems");
    $sys=$$syslist[0];

    if ($prod->{fips}) {
        $sec_or_fips = Msg::new("security with fips")->{msg};
    } else {
        $sec_or_fips = Msg::new("secure")->{msg};
    }

    # delete all cluster users during transform
    $msg=Msg::new("Deleting cluster users for $prod->{abbr}");
    $prod->eat_delete_cluster_users($sys);
    $msg->display_status();

    $sys->cmd("$prod->{bindir}/hagrp -state VxSS");
    unless (EDR::cmdexit()) {
        $msg=Msg::new("Deleting VxSS Service group");
        $prod->haconf_makerw();
        $sys->cmd("$prod->{bindir}/hares -delete vxatd");
        $sys->cmd("$prod->{bindir}/hares -delete phantom_vxss");
        $sys->cmd("$prod->{bindir}/hagrp -delete VxSS");
        $prod->haconf_dumpmakero();
        $msg->display_status();
    }

    $prod->stop_vcs();
    $msg=Msg::new("Updating $prod->{abbr} configuration");
    $prod->eat_maincf_unsecure_sys($sys);
    $prod->eat_update_CmdServer_secure_file();
    $msg->display_status();

    # destroy the EAT env if disable fips
    $sys->cmd("_cmd_rmr $prod->{eat_data_backup}") if $prod->{fips};

    $nsys=$prod->secure_startup();
    $mode=$sys->cmd("$prod->{bindir}/haclus -value SecureClus");
    if (($nsys==scalar(@$syslist)) && ($mode==0)) {
        $msg=Msg::new("Succeeded to disable $sec_or_fips mode\n");
        $msg->print;
    } else {
        $msg=Msg::new("Failed to disable $sec_or_fips mode\n");
        $msg->print;
    }
    return;
}

# delete the privilege of groups/clusters:
# AdministratorGroups Administrators Guests OperatorGroups Operators
# delete the users
sub eat_delete_cluster_users {
    my ($prod,$sys)=@_;
    my ($rtn,$hauser,$hagrp,$haclus,@privs,$privs_reg);
    my ($priv,@users,$group_name,$group_system,@values);

    $hauser = "$prod->{bindir}/hauser";
    $hagrp = "$prod->{bindir}/hagrp";
    $haclus = "$prod->{bindir}/haclus";
    @privs = qw(Administrator Operator Guest);
    $privs_reg = join('|',@privs);

    # back up the main.cf file
    $sys->cmd("_cmd_cp -rf $prod->{maincf} $prod->{maincf}.securitybackup 2>/dev/null");
    $prod->haconf_makerw();

    # delete the priv for users related to group
    $rtn = $sys->cmd("$hagrp -list 2>/dev/null");
    for my $group (split(/\n/,$rtn)) {
        ($group,@values) = (split(/\s+/,$group));
        $rtn = $sys->cmd("$hagrp -display $group 2>/dev/null");
        for my $line (split(/\n/,$rtn)) {
            next if $line =~ /^#/;
            ($group_name,$priv,$group_system,@users) = (split(/\s+/,$line));
            next unless scalar @users;
            next unless $priv =~ /$privs_reg/;
            # delete the last letter 's'
            $priv =~ s/s$//;
            for my $user (@users) {
                $sys->cmd("$hauser -delpriv $user $priv -group $group 2>/dev/null");
            }
        }
    }

    # delete the priv for users related to cluster
    $rtn = $sys->cmd("$haclus -display 2>/dev/null");
    for my $line (split(/\n/,$rtn)) {
        next if $line =~ /^#/;
        ($priv,@users) = split(/\s+/,$line);
        next unless scalar @users;
        next unless $priv =~ /$privs_reg/;
        # delete the last letter 's'
        $priv =~ s/s$//;
        for my $user (@users) {
            $sys->cmd("$hauser -delpriv $user $priv 2>/dev/null");
        }
    }

    # delete users
    $rtn = $sys->cmd("$hauser -list 2>/dev/null");
    for my $user (split(/\s+/,$rtn)) {
        $sys->cmd("$hauser -delete $user 2>/dev/null");
    }

    $prod->haconf_dumpmakero();
    return 1;
}

sub eat_addnode {
    my ($prod)=@_;
    my ($syslist,$firstnode,@processes,$cfg,$domain_name,$sys);

    $cfg=Obj::cfg();
    $prod->eat_initiate(1,$cfg->{newnodes});
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $firstnode->cmd("_cmd_mkdir -p $prod->{eat_tempdir}");

    $syslist = $cfg->{newnodes};
    @processes = @{$prod->{eat_processes}};
    $domain_name = $prod->{eat_domain_name};

    # collect the domain and creds from the first node of running cluter
    $prod->eat_addnode_collect_domain_creds($firstnode);

    # install embed at RAB =0 and import domain and HAD/CMDSERVER/WAC/CPSERVER credentials on new nodes
    for my $sysi (@$syslist) {
        $sys = Obj::sys($sysi);
        $prod->eat_install_sys($sys,$prod->{eat_setup},"NO RAB");
        $prod->eat_import_domain_sys($sys,$domain_name);
        for my $pro (@processes) {
            $prod->eat_import_credential_sys($sys,$pro);
        }
        $prod->eat_start_sys($sys);
    }

    # create directory data/CLIENT; data/TRUST and setuptrust
    for my $sysi (@$syslist) {
        $sys = Obj::sys($sysi);
        $prod->eat_create_client_setuptrust_trust_sys($sys);
    }
    return 1;
}

sub eat_addnode_collect_domain_creds {
    my ($prod,$sys)=@_;
    my (@processes,$domain_name,$file,$backup_file,$pro_prpl);

    @processes = @{$prod->{eat_processes}};
    $domain_name = $prod->{eat_domain_name};
    $file = "$prod->{eat_tempdir}/$domain_name";
    $backup_file = "$prod->{eat_data_backup}/$domain_name";

    if ($sys->exists($backup_file)) {
        $sys->copyfile($backup_file, $file);
        $sys->copy_to_sys($prod->localsys,$file);
    } else {
        $prod->eat_export_domain_sys($sys,$domain_name);
    }

    for my $pro (@processes) {
        $pro_prpl = $pro;
        $file = "$prod->{eat_tempdir}/$pro_prpl";
        $backup_file = "$prod->{eat_data_backup}/$pro_prpl";
#       always export the credentials before using, refer to e2706918
#        if ($sys->exists($backup_file)) {
#            $sys->copyfile($backup_file, $file);
#            $sys->copy_to_sys($prod->localsys,$file);
#        } else {
            $prod->eat_export_credential_sys($sys,$pro);
#        }
    }
    return 1;
}

sub eat_securityonenode_first {
    my ($prod,$sys)=@_;
    my ($msg,@processes,$domain_name);

    Msg::title();
    # delete all cluster users during transform
    $msg=Msg::new("Deleting cluster users for $prod->{abbr}");
    $prod->eat_delete_cluster_users($sys);
    $msg->display_status();

    $msg=Msg::new("Performing security configuration on first node");
    $msg->left;

    $prod->eat_initiate(1,[$sys]);
    @processes = @{$prod->{eat_processes}};
    $domain_name = $prod->{eat_domain_name};

    # install embed at RAB =1 and create domain and HAD/CMDSERVER/WAC credentials on NODE1
    $prod->eat_install_sys($sys,$prod->{eat_setup},"RAB");
    $prod->eat_start_sys($sys);
    $prod->eat_create_export_domain_sys($sys,$domain_name,$prod->{eat_domain_expiry_year});
    for my $pro (@processes) {
        $prod->eat_create_export_credential_sys($sys,$pro);
    }
    # create directory data/CLIENT; data/TRUST and setuptrust
    $prod->eat_create_client_setuptrust_trust_sys($sys);

    $msg=Msg::new("Done");
    $msg->right;
    $msg=Msg::new("\nSecurity configuration files have been saved at $prod->{eat_data_backup}. Copy them to other nodes of the cluster. (Do not put them under /var/VRTSvcs/ directory)\n");
    $msg->print;
    return 1;
}

sub eat_securityonenode_other {
    my ($prod,$sys)=@_;
    my ($msg,$conf_dir,@processes,$domain_name,$file,$pro_prpl);

    $conf_dir = $prod->eat_ask_security_conf_dir($sys);
    if (EDR::getmsgkey($conf_dir,'back')) {
        return $conf_dir;
    }

    $prod->eat_initiate(1,[$sys]);
    @processes = @{$prod->{eat_processes}};
    $domain_name = $prod->{eat_domain_name};

    Msg::title();
    $msg=Msg::new("Performing security configuration on this node");
    $msg->left;

    $prod->eat_install_sys($sys,$prod->{eat_setup},"NO RAB");
    $file = "$conf_dir/$domain_name";
    $prod->eat_import_domain_sys($sys,$domain_name,$file);
    for my $pro (@processes) {
        $pro_prpl = $pro;
        $file = "$conf_dir/$pro_prpl";
        $prod->eat_import_credential_sys($sys,$pro,$file);
    }
    $prod->eat_start_sys($sys);

    # create directory data/CLIENT; data/TRUST and setuptrust
    $prod->eat_create_client_setuptrust_trust_sys($sys);

    $msg=Msg::new("Done");
    $msg->right;
    $msg=Msg::new("\nThis step needs to be performed on all nodes of cluster except the first node. Then manual steps need to be performed to complete the secure cluster configuration.\n");
    $msg->print;
    return 1;
}

sub eat_ask_security_conf_dir {
    my ($prod,$sys)=@_;
    my ($cfg,$conf_dir,$msg,$count,$eat_data_dir);

    $cfg=Obj::cfg();
    $count = -1;
    while(1) {
        $count++;
        if (Cfg::opt('responsefile')) {
            if ($count) {
                $msg=Msg::new("The \$CFG{security_conf_dir} variable is not set correctly in the responsefile.");
                $msg->die;
            }
            $conf_dir = $cfg->{security_conf_dir};
        } else {
            $msg=Msg::new("Enter the security conf file directory:");
            $conf_dir = $msg->ask('','',1);
            return $conf_dir if (EDR::getmsgkey($conf_dir,'back'));
        }

        if (-d $conf_dir){
            # the /opt/VRTSvcs/bin/vcsauth and /var/VRTSvcs/vcsauth folders may be cleared later, so avoid to use this directory
            $eat_data_dir = $prod->{eat_data_root};
            $eat_data_dir =~ s/data$//;
            if ($conf_dir =~ m{$prod->{eat_vcs_bin}|$eat_data_dir}) {
                $msg=Msg::new("Move the security conf files to a place other than $prod->{eat_vcs_bin} or $eat_data_dir and try again.");
                $msg->print;
                next;
            }

            if ($msg = $prod->eat_check_bkup_error_sys($sys,$conf_dir)) {
                Msg::print($msg);
                next;
            }

            $cfg->{security_conf_dir} = $conf_dir;
            return $conf_dir;
        } else {
            $msg=Msg::new("$conf_dir is not a directory.");
            $msg->print;
        }
    }
    return 1;
}

sub eat_check_bkup_error_sys {
    my ($prod,$sys,$conf_dir)=@_;
    my ($srcfile,$domain_name,@processes,$msg,$pro_prpl,$error);

    # check domain/cred fils
    $conf_dir ||= $prod->{eat_data_backup};
    $error = '';
    $domain_name = $prod->{eat_domain_name};
    @processes = @{$prod->{eat_processes}};
    $srcfile = "$conf_dir/$domain_name";
    if ($sys->exists($srcfile)) {
    } else {
        $msg=Msg::new("Could not find file $domain_name under $conf_dir\n");
        $error .= $msg->{msg};
    }

    for my $pro (@processes) {
        $pro_prpl = $pro;
        $srcfile = "$conf_dir/$pro_prpl";
        if ($sys->exists($srcfile)) {
        } else {
            $msg=Msg::new("Could not find file $pro_prpl under $conf_dir\n");
            $error .= $msg->{msg};
        }
    }
    return $error;
}

sub eat_upgrade_precheck_sys {
    my ($prod,$sys)=@_;
    my ($rootpath,$secureclus,$vcsvers);

    $rootpath = Cfg::opt('rootpath');
    $prod->{eat_chroot} = ($rootpath) ? "_cmd_chroot $rootpath" : '';
    $prod->set_value('eat_chroot',$prod->{eat_chroot});

    $prod->eat_initiate();
    $secureclus = $prod->is_secure_cluster($sys);
    if ($secureclus == 1) {
        $prod->set_value('eat_upgrade_secure',1);
        $vcsvers = $prod->version_sys($sys,1);
        unless (EDRu::compvers($vcsvers,'6.0') == 2) {
            $prod->set_value('eat_upgrade_secure_from_eat',1);
            # check if the cluster is configured in fips mode, fips is a special case of secure
            $prod->set_value('fips',1) if($prod->is_fips_cluster($sys));
        }
        $prod->eat_check_share_at_status();
    } elsif ($secureclus == 2) {
        # this might be fips, stay tuned. -- it is decided to not modify the SecureClus value during fips mode
    } elsif ($prod->is_cps_secure_fencing($sys)) {
        $prod->set_value('eat_upgrade_secure_fencingonly',1);
    }

    if ($prod->{eat_upgrade_secure_from_eat} || $prod->{eat_upgrade_secure_fencingonly}) {
        $prod->eat_configure_from_eat_atutil_backup;
        # if upgrade from 6.0, that is from eat to eat, so back up the conf file firstly
        #Msg::log("Backing up the conf files for embedded AT");
        #$prod->eat_addnode_collect_domain_creds($sys);
    }

    $prod->eat_check_if_delete_shared_at();
    return 1;
}

# return 1 if the  cluster is configured secure fencing without fips
sub is_cps_secure_fencing {
    my ($prod,$sys)=@_;
    my $conf;

    return 0 unless ($sys->exists($prod->{vxfenmode}));
    $conf = $prod->get_vxfen_config_sys($sys);
    return 0 unless ($conf->{vxfen_mechanism} =~ /cps/m);
    return 1 if ($conf->{security} && ($conf->{fips_mode} != 1));
    return 0;
}

# return 1 if the cluster is configured fips fencing
sub is_cps_fips_fencing {
    my ($prod,$sys)=@_;
    my $conf;

    return 0 unless ($sys->exists($prod->{vxfenmode}));
    $conf = $prod->get_vxfen_config_sys($sys);
    return 0 unless ($conf->{vxfen_mechanism} =~ /cps/m);
    return 1 if ($conf->{security} && ($conf->{fips_mode} == 1));
    return 0;
}

sub eat_check_share_at_status {
    my ($prod)=@_;
    my ($syslist,$vssat,$vxatd,$pids,$msg);

    return 1 if Cfg::opt('rootpath');
    $syslist = CPIC::get("systems");
    $vssat = "$prod->{eat_shared_at_bin}/vssat";
    $vxatd = "$prod->{eat_shared_at_bin}/vxatd";

    for my $sys (@$syslist) {
        next unless $sys->exists($vxatd);
        $pids = $sys->proc_pids($vxatd);
        unless (scalar @$pids) {
            $msg = Msg::new("$vxatd is not running on $sys->{sys}. Installer will be unable to setuptrust with the shared broker, however the secure upgrade can still proceed.");
            $sys->push_warning($msg);
            next;
        }
        unless (EDRu::is_port_connectable($sys->{sys},2821)) {
            $msg = Msg::new("Port 2821 cannot be connected on $sys->{sys}. Installer will be unable to setuptrust with the shared broker, however the secure upgrade can still proceed.");
            $sys->push_warning($msg);
        }
    }
    return 1;
}

sub eat_check_if_delete_shared_at {
    my ($prod)=@_;
    my ($syslist,$vssat,$rtn);

    $syslist = CPIC::get("systems");
    $vssat = "$prod->{eat_shared_at_bin}/vssat";
    for my $sys (@$syslist) {
        if ($prod->{eat_upgrade_secure}) {
            $sys->set_value('donotuninstallpkgs','push',qw(VRTSat50 VRTSatClient50 VRTSat.server VRTSat.client));
            $sys->set_value('donotstopprocs','push','vxatd50');
        } else {
            next unless $sys->exists($vssat);
            $rtn = $sys->cmd("$prod->{eat_chroot} $vssat showbrokermode");
            if ($rtn =~ /Broker mode is :\s+(\d)/) {
                $sys->set_value('donotuninstallpkgs','push',qw(VRTSat50 VRTSatClient50 VRTSat.server VRTSat.client)) if $1;
                $sys->set_value('donotstopprocs','push','vxatd50') if $1;
            }
        }
    }
    return 1;
}

sub eat_upgrade_configure {
    my ($prod)=@_;
    my ($syslist,$eat_vssat,$vxatd,$msg,$rootpath,$had_dir,$eat_env,@setupfail,$failsys,$sys0);

    $rootpath = Cfg::opt('rootpath');
    $prod->eat_lu_modify_variables($rootpath) if $rootpath;
    if ($prod->{eat_upgrade_secure_from_eat} || $prod->{eat_upgrade_secure_fencingonly}) {
        # this is upgrade from eat, so cpi will back up eat data, and restore them
        $prod->eat_configure_from_eat;
        return 1;
    } else {
        $prod->eat_configure;
    }

    $vxatd = "$prod->{eat_shared_at_bin}/vxatd";
    $had_dir = "$prod->{eat_data_root}/HAD";
    $eat_env = $prod->eat_get_env("EAT_DATA_DIR='$had_dir'");

    $syslist = CPIC::get("systems");
    $eat_vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";

    $prod->eat_lu_configure_prepare() if $rootpath;
    for my $sys (@$syslist) {
        # no need to setuptrust with shared AT if no shared AT exists, eg, upgrade from 6.0
        next unless $sys->exists($vxatd);
        $sys->cmd("_cmd_yes y | $eat_env $eat_vssat setuptrust -b 127.0.0.1:2821 -s high  2>/dev/null");
        if (EDR::cmdexit()) {
            push(@setupfail,$sys->{sys});
        }
        $prod->eat_lu_configure_complete_sys($sys) if $rootpath;
    }

    if (scalar @setupfail) {
        $sys0=$$syslist[0];
        $failsys = join(',',@setupfail);
        $msg=Msg::new("Could not setuptrust with shared broker on system(s) $failsys. This will not affect the secure cluster function, but the initial credentials could not be used.");
        $sys0->push_note($msg);
    }
    return 1;
}

sub securecps_upgrade_configure {
    my ($prod)=@_;
    my ($sys1,$cpservers,$syslist,$conf);

    # skip this if cluster is upgrade from 6.0
    return 1 if $prod->{eat_upgrade_secure_from_eat} || $prod->{eat_upgrade_secure_fencingonly};

    $syslist=CPIC::get("systems");
    # Upgrade from VCS cluster with CPS fencing configured
    # setup trust with CPS servers
    $sys1=$$syslist[0];
    $cpservers=$prod->{cpslist};
    # this cpservers will have nodes only if the cpserver is in secure mode
    if ($#{$cpservers}>=0) {
        my $pkg=$prod->pkg("VRTSvxfen61");
        $pkg->get_cps_version($cpservers);
        $pkg->establish_trust_cps_cpc($cpservers,1);
        $conf = $prod->get_vxfen_config_sys($sys1);
        $pkg->update_clusterinfo_on_cps_when_upgrade($conf,$cpservers);
        # fencing upgraded successfully. If CPS is secure, do the following:
        # update the exported creds files on each node
        # next time when addnode, the new node can simply import the CPSADM creds. No need to setup trust with CPS broker.
        for my $sysi (@$syslist) {
            $prod->eat_export_credential_sys($sysi,'CPSADM');
        }
    }
    return 1;
}

sub eat_lu_modify_variables {
    my ($prod,$rootpath)=@_;

    for my $key (@{$prod->{eat_lu_modify_keys}}) {
        $prod->{"${key}_orig"} = $prod->{$key};
        $prod->{$key} = "$rootpath/$prod->{$key}";
    }
    $prod->{eat_DestDir_orig} = $prod->{eat_setup}{DestDir};
    $prod->{eat_setup}{DestDir} = "$rootpath/$prod->{eat_setup}{DestDir}";
    $prod->{eat_setup}{DataDir} = "$rootpath/$prod->{eat_setup}{DataDir}";
    return 1;
}

# this sub will do following prepares for setuptrust
#   1  stop shared at process(if exist);
#   2  chroot /rootpath /opt/VRTSat/bin/vxatd
# TODO: Maybe for next release upgrade, CPI will have to do more for LU, to stop/restart the HostMonitor, because it will start the vcsauthserver autoly
sub eat_lu_configure_prepare {
    my ($prod)=@_;
    my ($vxatd,$pids,$count,$limit,$syslist,%started,@failed,$failed);

    $vxatd = "$prod->{eat_shared_at_bin}/vxatd";
    $syslist = CPIC::get("systems");

    for my $sys (@$syslist) {
        #   1  stop shared at process(if exist);
        $pids = $sys->proc_pids($vxatd);
        if (scalar @$pids) {
            $sys->kill_pids(@$pids);
            $sys->{eat_shared_at_running} = 1;
        }
        #   2  chroot /rootpath /opt/VRTSat/bin/vxatd
        $sys->cmd("$prod->{eat_chroot} $vxatd < /dev/null > /dev/null");
    }

    $count = 0;
    $limit = 10;
    while ($count < $limit) {
        sleep 1;
        Msg::log("check vxatd port status count $count");
        @failed = ();
        for my $sys (@$syslist) {
            next if $started{$sys->{sys}};
            if (EDRu::is_port_connectable($sys->{sys},2821)) {
                $started{$sys->{sys}} = 1;
            } else {
                push(@failed,$sys->{sys});
            }
        }
        last unless scalar @failed;
        $count++;
    }

    if ($count == $limit) {
        $failed = join(',',@failed);
        Msg::log("The vxatd could not be successfully started from ABE on $failed, port 2821 is not available.");
    }
    return 1;
}

# corresponding to previous sub, this sub will revert the system to initial state
#   1  stop vxatd (ABE)
#   2  start vxatd if exist befor (PBE)
#   3  stop vcsauthserver (ABE) and start it (PBE) if exist before
#   4  modify EAT conf/script files
sub eat_lu_configure_complete_sys {
    my ($prod,$sys)=@_;
    my ($vxatd,$pids);
    my ($eat_exe_orig,$eat_sh_orig,$eat_exe,$eat_sh,$eat_vssat,@eat_files,$backfile);

    $vxatd = "$prod->{eat_shared_at_bin}/vxatd";

    #   1  stop rootpath shared at process;
    $pids = $sys->proc_pids($vxatd);
    if (scalar @$pids) {
        $sys->kill_pids(@$pids);
    }

    #   2  start /opt/VRTSat/bin/vxatd
    $sys->cmd("$vxatd < /dev/null > /dev/null") if $sys->{eat_shared_at_running};

    #   3  start eat process to initial state
    $eat_exe = "$prod->{eat_setup}{DestDir}/bin/$prod->{eat_setup}{BrokerExeName}";
    $eat_sh = "$eat_exe.sh";
    $eat_vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
    $eat_exe_orig = "$prod->{eat_DestDir_orig}/bin/$prod->{eat_setup}{BrokerExeName}";
    $eat_sh_orig = "$eat_exe_orig.sh";
    $sys->cmd("$eat_sh stop");
    $prod->eat_stop_sys($sys);
    $sys->cmd("$eat_sh_orig") if $sys->{eat_lu_pbe_running};

    #   4  modify related EAT files on ABE, clean the /rootpath
    @eat_files = split(/\n/,$sys->cmd("_cmd_find $prod->{eat_data_root} -name 'VRTSatlocal.conf'"));
    push(@eat_files,$eat_sh,$eat_vssat);
    for my $filename (@eat_files) {
        $backfile = "${filename}_eatback";
        $sys->cmd("_cmd_cp -f $filename $backfile");
        # modify the /altroot/opt/VRTS to /opt/VRTS, now not for /altroot/var/VRTS
        $sys->cmd("_cmd_sed -e 's|$prod->{eat_vcs_bin}|$prod->{eat_vcs_bin_orig}|g' -e 's|$prod->{eat_data_root}|$prod->{eat_data_root_orig}|g' $backfile > $filename");
    }
    return 1;
}

sub securityonenode_menu {
    my ($prod)=@_;
    my ($edr,$cfg,$sys,$cpic);
    my ($msg,$one,$two,$rtn,$menuopt,$menu,$help,$done,$ayn,$fips,$withfips,$secwac);

    Cfg::unset_opt('install');
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    $cpic=Obj::cpic();
    $edr->{savelog} = 1;
    $cpic->{systems} ||= [$edr->{localsys}];
    $edr->{systems} = $cpic->{systems};
    $fips = '';
    $withfips = '';

    if (Cfg::opt('fips')) {
        $prod->{fips} = 1;
        $fips = ' -fips';
        $withfips = ' with fips';
    }

    $msg=Msg::new("The -securityonenode$fips option is used to configure secure cluster$withfips node by node. Manual operations need to be performed during the configuration.");
    $msg->add_summary;

    $sys=$edr->{localsys};
    $msg = $prod->get_vxss_cluster($sys,'no_comm_check','not_stop');
    if ($msg) {
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        $ayn = $msg->aynn();
        $edr->exit_exitfile() if ($ayn eq 'N');
    }
    if ($prod->is_secure_cluster($sys)) {
        $msg=Msg::new("The cluster is already in secure mode.");
        $msg->die();
    }
    my $solnodes;
    if ($prod->{fips} && ($solnodes = $prod->check_solx64_for_fips)) {
        $msg = Msg::new("The architecture is x86 of $solnodes. Security with fips is not supported.");
        $msg->die;
    }
    $msg = Msg::new("(Note that all user configurations about this cluster will be deleted during step 1, command '/opt/VRTSvcs/bin/hauser' could be used to create cluster user manually.)\n");
    $msg->print;

    $secwac = "Application wac (\n\t\t\tStartProgram = \"/opt/VRTSvcs/bin/wacstart -secure\"\n\t\t\tStopProgram = \"/opt/VRTSvcs/bin/wacstop\"\n\t\t\tMonitorProcesses = { \"/opt/VRTSvcs/bin/wac -secure\"}\n\t\t\tRestartLimit = 3\n\t\t)";

    $help=Msg::new("The -securityonenode$fips option is used to configure a secure cluster$withfips node by node. Manual operations also need to be performed during the configuration.\n\n1. Run installvcs -securityonenode$fips and choose 1 on the first node of cluster. Installer will perform configuration and save the security configuration files under $prod->{eat_data_backup}\n\n2. Copy the security configuration files from the first node to other nodes.\n\n3. Run installvcs -securityonenode$fips and choose 2 on other nodes of cluster one by one. Installer will perform security configuration on the node using the security configuration files.\n");
    $msg=Msg::new("\n4. Manual operations:\n\tFreeze service groups on node A of cluster. (Do not freeze service group 'ClusterService')\n\t\tRun '/opt/VRTSvcs/bin/haconf -makerw'\n\t\tRun '/opt/VRTSvcs/bin/hagrp -list Frozen=0' to find service groups.\n\t\tRun '/opt/VRTSvcs/bin/hagrp -freeze <group name> -persistent' for related service groups\n\t\tRun '/opt/VRTSvcs/bin/haconf -dump -makero'\n");
    $help->{msg}.=$msg->{msg};
    $msg=Msg::new("\tRun '/opt/VRTSvcs/bin/hastop -all -force' on node A.\n\tRun '/opt/VRTSvcs/bin/CmdServer -stop' on all nodes.\n\tModify /etc/VRTSvcs/conf/config/main.cf of node A, add/modify 'SecureClus = 1' to the cluster definition, eg:\n\t\tcluster <cluster name> (\n\t\t\tSecureClus = 1\n\t\t)\n\t\n\tModify /etc/VRTSvcs/conf/config/main.cf of node A, add '-secure' to the wac application definition if global clustering is configured, eg:\n\t\t$secwac\n\tRun 'touch /etc/VRTSvcs/conf/config/.secure' on all nodes.\n\tRun '/opt/VRTSvcs/bin/hastart' on node A, then on all other nodes.\n\tRun '/opt/VRTSvcs/bin/CmdServer' on all the nodes.\n");
    $help->{msg}.=$msg->{msg};
    $msg=Msg::new("\tUnfreeze service groups on node A.\n\t\tRun '/opt/VRTSvcs/bin/haconf -makerw'\n\t\tRun '/opt/VRTSvcs/bin/hagrp -list Frozen=1' to find service groups.\n\t\tRun '/opt/VRTSvcs/bin/hagrp -unfreeze <group name> -persistent' for related service groups\n\t\tRun '/opt/VRTSvcs/bin/haconf -dump -makero'");
    $help->{msg}.=$msg->{msg};
    $msg=Msg::new("Perform security configuration on first node and export security configuration files.");
    $one=$msg->{msg};
    $msg=Msg::new("Perform security configuration on remaining nodes with security configuration files.");
    $two=$msg->{msg};
    while (!$done) {
        $rtn='';
        $menuopt=[$one,$two];
        $msg=Msg::new("Select the option you would like to perform");
        $menu=$msg->menu($menuopt,$cfg->{securityonenode_menu},$help);

        $cfg->{securityonenode_menu} ||= $menu;
        $rtn=$prod->eat_securityonenode_first($sys) if ($menu==1);
        $rtn=$prod->eat_securityonenode_other($sys) if ($menu==2);
        $done=1 unless (EDR::getmsgkey($rtn,'back'));
    }
    $help->print;
    Msg::n();

    Cfg::unset_opt('configure');
    $cpic->completion();
    return;
}

# for -securitytrust option
# Ask user to input a outer RB name or ip and port number
# Setuptrust between each VCS node and the outer RB
sub securitytrust {
    my ($prod)=@_;
    my ($cpic,$edr,$localsys,$sys0,$sys,$msg,$outerRB,$port,$ayn,$ping,$retry,$count,$help);

    $cpic=Obj::cpic();
    $edr=Obj::edr();
    $edr->{savelog}=1;
    $localsys=$prod->localsys;
    $cpic->{systems} ||= [];
    $edr->{systems} = $cpic->{systems};
    $count = 0;
    $retry = 2;

    $msg=Msg::new("The -securitytrust option is used to setup trust with another broker.");
    $msg->add_summary;

    Cfg::unset_opt('install');
    $prod->get_cluster_system();
    $prod->get_vxss_cluster();
    $sys0=${$cpic->{systems}}[0];

    if (!$prod->is_secure_cluster($sys0)) {
        $msg=Msg::new("The -securitytrust option is only supported with a secure cluster");
        $msg->die();
    } else {
        $msg=Msg::new("Input the broker name or IP address:");
        $outerRB=$msg->ask();
        while($count < $retry){
            $count++;
            Msg::log("Ping for the $count time");
            $ping=$localsys->padv->ping($outerRB);
            last unless $ping;
        }
        if ($ping =~ m/noping/) {
            $msg=Msg::new("Cannot ping the broker $outerRB");
            $msg->die();
        }
        $msg=Msg::new("Input the broker port:");
        $help=Msg::new("14545 is the default port for VOM, 14149 is the default port for VCS or CPS.");
        my $def_port=14545;
        $port=$msg->ask($def_port,$help);

        $msg=Msg::new("Input the data directory to setup trust with:");
        my $eat_env=$msg->ask("$prod->{eat_data_root}/HAD");
        for my $sys (@{$cpic->{systems}}) {
            if (!$sys->is_dir($eat_env)){
                $msg=Msg::new("$eat_env directory was not found on $sys->{sys}");
                $msg->die();
            }
        }
        $eat_env = $prod->eat_get_env("EAT_DATA_DIR='$eat_env'");

        my $prodi=$cpic->prod()->{abbr};
        $msg=Msg::new("Are you sure that you want to setup trust for the $prodi cluster with the broker $outerRB and port $port?");
        $ayn=$msg->ayny();
        if ($ayn eq 'Y') {
            my $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";
            my $tmp_roothash=EDR::tmpdir()."/root_hash";
            for my $sys (@{CPIC::get('systems')}) {
                $msg=Msg::new("Setup trust with broker $outerRB on cluster node $sys->{sys}");
                $sys->cmd("_cmd_yes y | $eat_env $vssat setuptrust -b $outerRB:$port -s high  2>/dev/null");
                if (EDR::cmdexit()){
                    $msg->display_status('failed');
                    $msg=Msg::new("Failed to set up trust with broker $outerRB on this cluster");
                    $msg->print();
                    last;
                } else {
                    $msg->display_status();
                }
                $prod->eat_export_credential_sys($sys,'HAD');
            }
        }
    }
    Msg::n();
    Cfg::unset_opt('configure');
    $cpic->completion();
    return;
}

sub get_cluster_info_sys {
    my ($prod,$sys,$conf)=@_;
    my ($info,$syslist,$grouplist);

    $conf ||= $prod->get_config_sys($sys);
    return '' unless $conf;

    $info = Msg::new("Following cluster information detected:\n");
    $info->{msg} .= Msg::new("\tCluster Name: $conf->{clustername}\n")->{msg};
    unless ($conf->{onenode}) {
        $info->{msg} .= Msg::new("\tCluster ID: $conf->{clusterid}\n")->{msg};
    }
    $syslist = join(' ',@{$conf->{systems}});
    $info->{msg} .= Msg::new("\tSystems: $syslist\n")->{msg};
    $grouplist = join(' ',@{$conf->{groups}});
    $info->{msg} .= Msg::new("\tService Groups: $grouplist\n")->{msg};
    return $info;
}

sub security_menu {
    my ($prod)=@_;
    my ($cfg,$cpic,$edr,$msg,$ayn,$sys0,$web,$info,$sec_or_fips,$option,$rtn);

    $web = Obj::web();

    Cfg::unset_opt('install');
    $cpic=Obj::cpic();
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    $edr->{savelog} = 1;
    $cpic->{systems} ||= [];
    $edr->{systems} = $cpic->{systems};

    if (Cfg::opt('fips')) {
        $prod->{fips} = 1;
        $sec_or_fips = Msg::new("security with fips")->{msg};
        $option = '-fips';
    } else {
        $sec_or_fips = Msg::new("secure")->{msg};
        $option = '-security';
    }
    $msg=Msg::new("The -$option option is used to enable or disable $sec_or_fips mode of a running VCS cluster.");
    $msg->add_summary;

    $prod->get_cluster_system();
    $prod->get_vxss_cluster();

    my $solnodes;
    if ($prod->{fips} && ($solnodes = $prod->check_solx64_for_fips)) {
        $msg = Msg::new("The architecture is x86 of $solnodes. Security with fips is not supported.");
        $msg->die;
    }

    $prod->check_prod_enabled_cluster;
    $sys0 = ${$cpic->{systems}}[0];
    $info = $prod->get_cluster_info_sys($sys0);
    $rtn=$edr->check_timesync($cpic->{systems}, 5);
    if (!$rtn) {
        $msg=Msg::new("The $sec_or_fips cluster may not work after conversion if the cluster nodes have time offset.\n");
        $msg->bold();
    }

    $msg = Msg::new("Note that all user configurations about this cluster will be deleted during transformation. The command '/opt/VRTSvcs/bin/hauser' could be used to create cluster user manually.\n");
    $msg->print;
    $info->{msg} .= $msg->{msg};

    $prod->check_security_fips_conflict($sys0);
    if ($prod->is_secure_cluster($sys0)) {
        $msg=Msg::new("Do you want to disable $sec_or_fips mode in this $prod->{abbr} cluster?");
        $ayn=$msg->ayny('','',$info);
        Msg::n();
        if ($ayn eq 'Y') {
            Msg::title();
            $msg=Msg::new("Restarting $prod->{abbr} with $sec_or_fips mode disabled:\n");
            $msg->bold;
            $msg->{msg} =~ s/[\n:]//g;
            if (Obj::webui()) {
                $web->web_script_form('showstatus',$msg);
                $web->{completion_instruction} = Msg::new("Disable $sec_or_fips mode");
            }
            $prod->eat_disable();
        }
    } else {
        $msg=Msg::new("Do you want to enable $sec_or_fips mode in this $prod->{abbr} cluster?");
        $ayn=$msg->ayny('','',$info);
        Msg::n();
        if ($ayn eq 'Y') {
            Msg::title();
            $msg=Msg::new("Restarting $prod->{abbr} with $sec_or_fips mode enabled:\n");
            $msg->bold;
            $msg->{msg} =~ s/[\n:]//g;
            if (Obj::webui()) {
                $web->web_script_form('showstatus',$msg);
                $web->{completion_instruction} = Msg::new("Enable $sec_or_fips mode");
            }

            $prod->{eat_enable} = 1;
            $prod->eat_enable();
        }
    }

#    Cfg::set_opt('responsefile');
    Cfg::unset_opt('configure');
    $cpic->completion();
    return;
}

# check if a cluster could be converted using -security or -fips option
# cluster could be turned to security or fips mode from normal mode, so this sub should not be called if cluster is on normal mode
# if cluster is fips, but option is -security, die
# if cluster is secure, but option is -fips, die
# print warning if user want to disable fips, if it is used by a fips cpserver fencing
sub check_security_fips_conflict {
    my ($prod,$sys)=@_;
    my ($msg,$isfips,$ayn);
    my $cpic=Obj::cpic();

    if ($prod->is_secure_cluster($sys)) {
        $isfips = $prod->is_fips_cluster($sys);
        if (!$isfips && $prod->{fips}) {
            $msg=Msg::new("The cluster is running in secure mode. It cannot be converted using the -security -fips option. You should use -security\n");
            $msg->die();
        }

        if ($isfips && !$prod->{fips}) {
            $msg=Msg::new("The cluster is running with security with fips mode. It cannot be converted using the -security option. You should use -security -fips option\n");
            $msg->die();
        }

        if ($isfips && $prod->is_cps_fips_fencing($sys)) {
            $msg = Msg::new("Fencing may fail for this cluster, if security with fips mode is disabled. Do you want to continue?");
            $ayn = $msg->aynn();
            $cpic->edr_completion() if ($ayn eq 'N');
        }
    } elsif($prod->{fips} && $prod->is_cps_secure_fencing($sys)) {
        $msg = Msg::new("Fencing may fail for this cluster, if you continue to configure security with fips. Do you want to continue?");
        $ayn = $msg->aynn();
        $cpic->edr_completion() if ($ayn eq 'N');
    }
    return 1;
}

# a fips cluster is also a secure cluster, so call this sub ONLY if the cluster is secure
sub is_fips_cluster {
    my ($prod,$sys)=@_;
    my ($eat_env,$vssat,$output);

    $eat_env = $prod->eat_get_env;
    $vssat = "$prod->{eat_setup}{DestDir}/bin/vssat";

    return 0 unless ($sys->exists($vssat));
    $output = $sys->cmd("$eat_env $vssat showfipsmode");
    return 1 if ($output =~ /FIPS\s+MODE\s+is\s*:\s*On/i);
    return 0;
}

sub check_solx64_for_fips {
    my ($prod)=@_;
    my ($syslist,@errlist,$errlist);

    # the x64 is supported now, so just return '' to enable x64
    return '';
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        push(@errlist,$sys->{sys}) if ($sys->{padv} =~ /sol\S*64/i);
    }
    $errlist = join(',',@errlist);
    return $errlist;
}

sub check_prod_enabled_cluster {
    my ($prod)=@_;
    my ($syslist,@errlist,$errlist,$vcsinitfile,$msg);

    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        if (!$prod->check_prod_enabled_sys($sys)) {
            push(@errlist,$sys->{sys});
        }
    }

    if(scalar @errlist) {
        $errlist = join(',',@errlist);
        $vcsinitfile = $prod->{initfile}{vcs};
        $msg = Msg::new("VCS_START is not set to 1 on $errlist. To configure security, VCS_START must be set to 1 in $vcsinitfile so that VCS processes can be started during the configuration.");
        $msg->die;
    }
    return 1;
}

sub vxfen_option {
    my ($cpic,$edr,$pkg,$prod);
    $prod=shift;
    $cpic=Obj::cpic();
    $pkg=$prod->pkg('VRTSvxfen61');
    $edr=Obj::edr();
    $edr->{savelog} = 1;
    $prod->get_cluster_system();
    $pkg->config_vxfen();
    $cpic->completion();
    return;
}

sub config_cps {
    my $prod = shift;
    my ($cpic,$edr,$pkg);
    $cpic=Obj::cpic();
    $edr=Obj::edr();
    $edr->{savelog} = 1;
    $pkg=$prod->pkg('VRTScps61');
    $prod->get_cluster_system();
    $pkg->config_cps();
    $cpic->completion();
    return;
}

sub get_cluster_system {
    my ($prod,$noexit)=@_;
    # get the system cluster configuration infomation
    my (@systems,$ayn,$clustername,$clusterid,$conf,$done,$failed,$msg,$sys,$sysname,$syslist);
    my ($backopt,$cfg,$edr);
    $cfg=Obj::cfg();
    $edr=Obj::edr();
    my $web = Obj::web();
    $failed=0;
    while(1){
        if ($failed) {
            if (Cfg::opt('responsefile')) {
                $msg=Msg::new("An error occurred when using the responsefile");
                $msg->die;
            }
            if (Cfg::opt('configcps')) {
                $msg=Msg::new("Would you like to configure CP Server on another system or cluster?");
            } elsif (Cfg::opt('security')) {
                $msg=Msg::new("Would you like to configure secure mode on another system or cluster?");
            } elsif (Cfg::opt('securitytrust')) {
                $msg=Msg::new("Would you like to set up trust with the broker for another system or cluster?");
            } else {
                $msg=Msg::new("Would you like to configure I/O fencing for another $prod->{abbr} cluster?");
            }
            $ayn=$msg->aynn;
            Msg::n();
            if ($ayn eq 'N'){
                return 0 if($noexit);
                $web->web_script_form("completion",1) if (Obj::webui());
                EDR::exit_noexitfile();
            }
            undef($cfg->{systems});
        }
        if (defined($cfg->{systems}) && ${$cfg->{systems}}[0]) {
            $sysname=${$cfg->{systems}}[0];
        } else {
            if (Obj::webui()) {
                $msg = Msg::new("Enter one system of the cluster");
                $cfg->{systems} = $web->web_script_form("selectCluster", $msg);
                $sysname=${$cfg->{systems}}[0];
            } else {
                do {
                    if (Cfg::opt('configcps')) {
                        $msg=Msg::new("Enter the name of the system to configure the CP Server:");
                    } elsif (Cfg::opt('security')) {
                        $msg=Msg::new("Enter the name of the system to configure secure mode:");
                    } elsif (Cfg::opt('securitytrust')) {
                        $msg=Msg::new("Enter the name of the system to set up trust with the broker:");
                    } else {
                        $msg=Msg::new("Enter the name of one system in the $prod->{abbr} cluster for which you would like to configure I/O fencing:");
                    }
                    $backopt = 1 if ($failed);
                    $sysname=$msg->ask('', '', $backopt);
                    Msg::n();
                    next if (EDR::getmsgkey($sysname, 'back'));
                    # chop extra systems, in case they enter more
                    $sysname=EDRu::despace($sysname);
                    $sysname=~s/\s.*$//m;
                } while ($edr->validate_systemnames($sysname));
            }
        }
        $failed=1;
        $web->web_script_form('precheck') if(Obj::webui());
        $edr->set_progress_steps(3);
        if (Cfg::opt('configcps')) {
            $edr->set_progress_steps(2);
        } else {
            $edr->set_progress_steps(3);
        }
        $sys=($Obj::pool{"Sys::$sysname"}) ?
            Obj::sys($sysname) : Sys->new($sysname);

        @{$cfg->{systems}}=($sysname);
        if ($edr->check_and_setup_transport_sys($sys)==-1) {
            next;
        }

        $msg=Msg::new("Checking release compatibility on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        if ($edr->supported_padv_sys($sys)) {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        } else {
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                $msg->addError($errmsg);
                Msg::print("$errmsg\n");
            }
            undef($sys->{errors});
            next;
        }
        unless (Cfg::opt('configcps')) {
            next if (!$prod->check_prod_install_sys($sys));
        }

        $conf=$prod->get_config_sys($sys);
        if ($conf) {
            $clustername=$conf->{clustername};
            @systems=@{$conf->{systems}};
            $clusterid=$conf->{clusterid};
        } else {
            $msg=Msg::new("Cluster configuration information checking failed on $sys->{sys}");
            $msg->print;
            $web->web_script_form('alert', $msg) if(Obj::webui());
            next;
        }

        Msg::title();
        my $webmsg;
        $msg=Msg::new("Cluster information verification:\n");
        $webmsg = $msg->{msg};
        $msg->bold;
        $msg=Msg::new("\tCluster Name: $clustername\n");
        $webmsg .= $msg->{msg};
        $msg->print;
        $msg=Msg::new("\tCluster ID Number: $clusterid\n");
        $webmsg .= $msg->{msg};
        $msg->print;
        $syslist=join(' ', @systems);
        $msg=Msg::new("\tSystems: $syslist");
        $webmsg .= $msg->{msg};
        $msg->printn;

        if (!Cfg::opt('responsefile')) {
            if (Cfg::opt('configcps')) {
                $msg=Msg::new("Would you like to configure CP Server on the cluster?");
            } elsif (Cfg::opt('security')) {
                $msg=Msg::new("Would you like to configure secure mode on the cluster?");
            } elsif (Cfg::opt('securitytrust')) {
                $msg=Msg::new("Would you like to set up trust with the broker on the cluster?");
            } else {
                $msg=Msg::new("Would you like to configure I/O fencing on the cluster?");
            }
            $ayn=$msg->ayn('y','','',$webmsg);
            Msg::n();
        } else {
            $ayn='Y';
        }
        next unless ($ayn eq 'Y');

        $done=1;
        $web->{marquee_syslist} = $syslist if (Obj::webui());
        $web->web_script_form('precheck') if (Obj::webui());

        if (Cfg::opt('configcps')) {
            $edr->set_progress_steps(2*scalar(@systems));
        } else {
            $edr->set_progress_steps(3*scalar(@systems));
        }

        for my $sysname (@systems) {
            $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname)
                                               : Sys->new($sysname);
            if ($edr->check_and_setup_transport_sys($sys)==-1) {
                $done=0;
                next;
            }

            $msg=Msg::new("Checking release compatibility on $sys->{sys}");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());
            if ($edr->supported_padv_sys($sys)) {
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            } else {
                Msg::right_failed();
                for my $errmsg (@{$sys->{errors}}) {
                    $msg->addError($errmsg);
                    Msg::print("$errmsg\n");
                }
                undef($sys->{errors});
                $done=0;
                next;
            }

            unless (Cfg::opt('configcps')) {
                if (!$prod->check_prod_install_sys($sys)) {
                    $done=0;
                    next;
                }
                $conf=$prod->get_config_sys($sys);
                if (!$conf) {
                    $msg=Msg::new("Cluster configuration information checking failed on $sys->{sys}");
                    $msg->print;
                    $web->web_script_form('alert', $msg) if(Obj::webui());
                    $done=0;
                    next;
                }
            }
        }
        last if ($done);
    }
    $cfg->{vcs_clusterid}=$clusterid;
    $cfg->{vcs_clustername}=$clustername;
    @{$cfg->{systems}}=@systems;
    return 1;
}

#To configure https cps, openssl needs to be installed
#return 1 if it is installed
#return 0 if not
sub https_cpc_check_openssl_sys {
    my ($prod,$sys) = @_;
    my ($out,$msg,$web);

    $out = $sys->cmd("_cmd_openssl version 2>/dev/null");
    if (EDR::cmdexit()) {
        $web = Obj::web();
        if (Cfg::opt('upgrade')) {
            $msg = Msg::new("Vxfen could not start without openssl installed, you need to install openssl on $sys->{sys}");
            $sys->push_error($msg);
        } else {
            $msg = Msg::new("CP client could not be configured without openssl installed, first install openssl on $sys->{sys}");
            $msg->error();
        }
        Msg::n();
        $web->{complete_failed}=1;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        return 0;
    }

    return 1;
}

sub check_prod_install_sys {
    my ($prod,$sys) = @_;
    my ($cprod,$cprodi,$msg,$result,$ivers,$cpic);
    $cpic=Obj::cpic();
    $cprodi=CPIC::get('prod');
    ($cprodi)? $cprod=$cpic->prod($cprodi):$cprod=$cpic->prod("VCS61");
    $msg=Msg::new("Checking $cprod->{abbr} installation on $sys->{sys}");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());
    $ivers=$cprod->version_sys($sys, 1);
    if ($ivers) {
        $msg=Msg::new("Version $ivers");
        $msg->right;
        $msg->display_right() if (Obj::webui());
        $result=1;
    } else {
        $msg=Msg::new("Not installed");
        $msg->right;
        $msg->display_right() if (Obj::webui());
        $result=0;
    }

    return $result;
}

sub check_installed_ha_product_sys {
    my ($prod,$sys) = @_;
    my (@prodlist,$installed_prodi,$clus_prod,$clus_lic,$clus_ver,$rel);
    $rel = Obj::rel();
    @prodlist = qw(SFRAC61 SFSYBASECE61 SVS61 SFCFSHA61 SFHA61 VCS61);

    for my $prodi (@prodlist) {
        $clus_prod = $prod->prod($prodi,1);
        next unless (defined($clus_prod));
        $clus_ver = $clus_prod->version_sys($sys,1);
        if ($clus_ver) {
            $clus_lic = $rel->prod_licensed_sys($sys,$prodi);
            if ($clus_lic) {
                $installed_prodi = $prodi;
                last;
            }
        }
    }
    Msg::log("Installed ha prod on $sys->{sys} is $installed_prodi") if ($installed_prodi);
    return $installed_prodi;
}

# 0 the link speed of each private NICs are equal
# 1 the link speed of some private NICs are different
# 2 failed to detect link speed on some private NICs
sub check_link_speed {
    my ($prod,$systems,$nics) = @_;
    my ($speed_value,$sysii,$out,$sysi,$common_speed,$key_high,$msg,$sys,$nic,$key,$link,$key_low,$diff,$fail,$selected_speed,$virtualdev);
    my $web = Obj::web();

    $diff = 0;
    $fail = 0;
    $virtualdev = 0;
    for my $sysii (@$systems) {
        if (ref($sysii) eq 'Sys') {
            $sys = $sysii;
        } else {
            $sys = Obj::sys("$sysii");
        }
        $sysi = $sys->{sys};
        for my $link (1..$prod->num_hbnics($nics)) {
            $key = "lltlink$link";
            $key_high = "lltlink$link".'_high';
            $key_low = "lltlink$link".'_low';
            next unless (defined($nics->{$key}{$sysi}));
            $nic = $nics->{$key}{$sysi};
            $msg = Msg::new("Checking media speed for $nic on $sysi");
            $msg->left();
            $selected_speed = $sys->padv->nic_speed_sys($sys,$nic);

            if ( $selected_speed =~ /virtual/i || $selected_speed =~ /not applicable/i) {
                $virtualdev = 1;
            }

            if ($selected_speed =~ /\D*(\d+\.?\d*)\s*[Gg]/mx) {
                $speed_value = $1;
                $speed_value *= 1000;
            } elsif ($selected_speed =~ /\D*(\d+\.?\d*)\D*/mx) {
                $speed_value = $1;
            } else {
                $speed_value = 0;
            }
            if ( ! defined($nics->{$key_high})) {
                $nics->{$key_high} = $speed_value;
            } elsif ( $nics->{$key_high} < $speed_value ) {
                $nics->{$key_high} = $speed_value;
            }
            if ( !defined($nics->{$key_low})) {
                $nics->{$key_low} = $speed_value;
            } elsif ( $nics->{$key_low} > $speed_value ) {
                $nics->{$key_low} = $speed_value;
            }

            if ($selected_speed eq '') {
                $out = Msg::new("Unknown")->{msg};
            } else {
                $out = $selected_speed;
            }
            Msg::right("$out");
            if (Obj::webui()) {
                $web->{nicspeedinfo} .= Msg::new("The media speed of $nic on $sysi is: $out")->{msg};
                $web->{nicspeedinfo} .= "\n";
            }
            if ($selected_speed !~ /\d+/m) {
                $fail = 1;
                next;
            }
            unless (defined($common_speed) || $fail) {
                $common_speed = $selected_speed;
                next;
            }
            unless($diff || $fail) {
                $diff = 1 if ($common_speed ne $selected_speed);
            }
        }
        $sys->{nics_comm_speed} = $common_speed unless($diff || $fail);
    }
    Msg::n();

    return 0 if ($virtualdev && !$diff);
    return 2 if ($fail);
    return 1 if ($diff);
    return 0;
}

sub web_check_link_speed {
    my ($prod, $diff) = @_;
    my ($desc,$msg);

    my $web = Obj::web();
    my $script=EDR::get('script');
    if ($diff == 1) {
        $desc = Msg::new("The private NICs do not have same media speed.\n")->{msg};
        $desc .= Msg::new("It is recommended that the media speed be same for all the private NICs. Without this, LLT may not function properly. Consult your Operating System manual for information on how to set the Media Speed.\n")->{msg};
        $desc .= $web->{nicspeedinfo};
    }
    if ($diff == 2) {
        $desc = Msg::new("$script cannot detect media speed for the selected private NICs properly. Consult your Operating System manual for information on how to set the Media Speed.\n")->{msg};
        $desc .= $web->{nicspeedinfo};
    }
    delete $web->{nicspeedinfo};
    if ($diff) {
        $msg = Msg::new("Do you want to continue with current heartbeat configuration?");
        my $answer = $msg->ayny('','',$desc);
        return 0 if ($answer ne 'Y');
    }
    return 1;
}

sub task_need_skip_sys {
    my ($prod, $sys, $file) = @_;
    my ($conf,$cprod,$prod_validate,$singlenode);

    $conf = $prod->get_config_sys($sys);
    $singlenode = ($conf && scalar(@{$conf->{systems}}) == 1);
    $cprod=CPIC::get('prod');
    $prod_validate = 1 if ($cprod =~ /^(VCS|SFHA)\d+$/);

    if (($prod_validate) && (!$sys->exists($file))) {
        return 1 if (($singlenode) || ($file eq $prod->{vxfenmode}));
    }
    return 0;
}

sub postcheck_lltstat_sys {
    my ($prod,$sys) = @_;
    my (@down_links,$llt_sys,$rtn);

    return if $prod->task_need_skip_sys($sys, $prod->{llttab});
    $rtn=$sys->cmd('_cmd_lltstat -nvv 2>&1');
    $llt_sys='';
    for my $line (split(/\n/,$rtn)) {
        if ($line=~/^\s*\*?\s*\d{1,2}\s+(\S+)\s+\S+/mx) {
            $llt_sys=$1;
        } elsif ($line=~/^\s*\*?\s*\d{1,2}\s+/mx) {
            $llt_sys='';
        } elsif ($llt_sys && $line=~/^\s*(\S+)\s+DOWN/mx) {
            push(@down_links, "$llt_sys\t$1");
        }
    }

    if (@down_links) {
        $sys->set_value('down_links', 'list', @down_links);
        return 0;
    }

    return 1;
}

sub postcheck_nics {
    my ($prod) = @_;
    my (@sys_nics,$pids,$row,$col);
    my ($speed_value,$n_lowpri,$sysi,$dev_dir,$last_sap,$key_high,$msg,$cprod,$a1,$sys0,$gatewaynics_sys0,$rnics,$dlpi,$sys,@sorted_resultfiles,$localsys,$n,$padv,$nic,$mac,$used_nics,$link_index,$non_nic_num,$link_num,$link,$cmd_out,@resultfiles,$n_hipri,$rhbn,$all_connected,$key_low,$retry_count,%sap_mac,$max_links,$b1,$dev_n,$selected_speed,$nic_num,$n0,$dev_l,$connected_nic,$cmd,$rpids,@sorted_links_index,$connected_nics,$tmpdir,$sysi0,$sap,$dev,$result_sys_nic);
    my $rootpath = Cfg::opt('rootpath');
    $row=$col=0;
    $tmpdir = EDR::tmpdir();
    for my $sys (@{CPIC::get('systems')}) {
        $sysi = $sys->{sys};
        $padv = $sys->padv;
        if (!$sys->exists($rootpath.'/opt/VRTSllt/dlpiping')) {
            Msg::log("$rootpath/opt/VRTSllt/dlpiping command was not found on $sysi. VRTSllt package was not installed successfully.");
            return \@sys_nics;
        }
    }

    for my $sys (@{CPIC::get('systems')}) {
        # skip starting dlpiping -s on the last system
        next if ($sys eq ${CPIC::get('systems')}[-1]);
        $result_sys_nic = undef;
        $last_sap = 52000; # 52000 is magical initial sap value for dlpiping test.
        $row++;
        if (!$sys->linux()) {
            if ($sys->aix()) {
                $dev_dir = '/dev/dlpi';
            } else {
                $dev_dir = '/dev';
            }
        }

        $cmd_out=$sys->readfile("/etc/llttab");
        foreach my $line (split(/\n/,$cmd_out)){
            if($line =~/^link/){
                $last_sap++;
                (undef,$nic,undef)=split(/\s+/,$line,3);
                if ($nic =~ /sit\d+/m || $nic =~ /vsw\d+/m){ # skip sit# on Linux, vsw# on Solaris
                    $non_nic_num++;
                    $sap_mac{$last_sap}{mac} = '00:00:00:00:00:00';
                } else {
                    if ($sys->linux()) {
                        $dev = $nic;
                        $mac=$sys->cmd("_cmd_ifconfig '$nic' | _cmd_grep 'HWaddr'");
                        if ($mac=~/HWaddr\s+([0-9A-Fa-f:]+)[\s\n\$]/x) {
                            $mac=$1;
                        } else {
                            Msg::log("Failed get MAC address of $dev on $sysi.");
                            $mac='FF:FF:FF:FF:FF:FF';
                        }
                    } else {
                        if ($sys->{padv} =~ /^Sol11/m) {
                            $dev = "/dev/net/$nic";
                        } elsif ( $nic =~ /^(.*[A-Za-z])(\d+)$/mx) {
                            $dev = "$dev_dir/$1:$2";
                        } else {
                            $dev = "$dev_dir/$nic";
                        }
                        $mac=$sys->cmd("$rootpath/opt/VRTSllt/getmac $dev 2>/dev/null | _cmd_grep '$dev'");
                        $mac =~ s/^\s*//m; #remove leading spaces if any.
                        (undef, $mac) = split /\s/m, $mac;
                        chomp $mac;
                    }
                }
                if ($mac) {
                    $sap_mac{$last_sap}{mac} = $mac;
                } else {
                    Msg::log("Failed get MAC address of $dev on $sys.");
                    $sap_mac{$last_sap}{mac} = 'FF:FF:FF:FF:FF:FF';
                }
                $sap_mac{$last_sap}{nic}=$nic;
                $cmd = " cd $tmpdir ; ( /opt/VRTSllt/dlpiping -s -v -d $last_sap $dev >/dev/null  2>&1 & ) ";
                $sys->cmd($cmd);
                $result_sys_nic->{server}{nics}{$nic} = 0;
            }
        }
        $col=0;
        for my $sysi (@{CPIC::get('systems')}) {
            $col++;
            next if($col<=$row);
            for $nic (keys %{$result_sys_nic->{server}{nics}}) {
                $result_sys_nic->{server}{nics}{$nic} = 0;
            }
            $result_sys_nic->{client} = undef;
            $cmd_out=$sysi->readfile("/etc/llttab");
            foreach my $line (split(/\n/,$cmd_out)){
                if($line =~/^link/){
                    (undef,$nic,undef)=split(/\s+/,$line,3);
                    $result_sys_nic->{client}{nics}{$nic} = 0;
                    if ($nic =~ /sit\d+/m || $nic =~ /vsw\d+/m){ # skip sit# on Linux, vsw# on Solaris
                        $non_nic_num++;
                    } else {
                        if ($sys->linux()) {
                            $dev = $nic;
                        } else {
                            $dev_l=$dev_n=$nic;
                            $dev_l=~s/(.*[A-Za-z])\d*/$1/mxg;
                            $dev_n=~s/.*[A-Za-z](\d*)$/$1/mxg;
                            $dev = "$dev_dir/$dev_l:$dev_n";
                            if ($sys->{padv} =~ /^Sol11/m) {
                                $dev = "/dev/net/$nic";
                            }elsif ( $nic =~ /^(.*[A-Za-z])(\d+)$/mx) {
                                $dev = "$dev_dir/$1:$2";
                            } else {
                                $dev = "$dev_dir/$nic";
                            }
                            # make sure this NIC is detected.
                            $sysi->cmd("$rootpath/opt/VRTSllt/getmac $dev");
                        }
                        for my $sap (52001..$last_sap) {
                            $n0 = $sap-52001;
                            Msg::log("Check $nic on $sysi->{sys} to $sap_mac{$sap}{nic} on $sys->{sys}");
                            $cmd = " /opt/VRTSllt/dlpiping -c -t 10 -d $sap $dev $sap_mac{$sap}{mac}";
                            $sysi->cmd($cmd);
                            if (EDR::cmdexit() == 0) {
                                $connected_nic = $sap_mac{$sap}{nic};
                                $result_sys_nic->{client}{nics}{$nic} = 1;
                                $result_sys_nic->{server}{nics}{$connected_nic} = 1;
                            }
                        }
                    }
                }
            }
            for $nic (keys %{$result_sys_nic->{client}{nics}}) {
                if ($result_sys_nic->{client}{nics}{$nic} == 0) {
                    push(@sys_nics,"$sysi->{sys}#$nic#$sys->{sys}#all");
                }
            }
            for $nic (keys %{$result_sys_nic->{server}{nics}}) {
                if ($result_sys_nic->{server}{nics}{$nic} == 0) {
                    push(@sys_nics,"$sys->{sys}#$nic#$sysi->{sys}#all");
                }
            }
        }
        $pids=$sys->proc_pids('dlpiping');
        $sys->kill_pids(@$pids);
    }
    return \@sys_nics;
}

sub postcheck_lltconfig_sys {
    my ($prod,$sys) = @_;
    my ($msg,$rtn,$rtn1,$rtn2,$rtn3,$report,$downlinks,$output,$sysname,$nic,$systemnics,$wrongnics,$slavenics,$list,@m);

    return if $prod->task_need_skip_sys($sys, $prod->{llttab});
    my $padv=$sys->padv;
    $rtn=$sys->cmd('_cmd_lltconfig 2>&1');
    $rtn1=$sys->cmd("_cmd_gabconfig -a 2>&1 | _cmd_grep 'Port a'");
    if ($rtn!~/LLT is running/m || $rtn1=~/jeopardy/) {
        if($rtn1=~/jeopardy/){
            $msg=Msg::new("llt is running in jeopardy state on $sys->{sys}");
            push(@m,$msg);
        } else {
            $msg=Msg::new("llt is not in 'running' state on $sys->{sys}");
            push(@m,$msg);
        }
        unless ($sys->exists('/etc/llthosts') && $sys->exists('/etc/llttab')){
            $msg=Msg::new("\n\tllt is not configured on $sys->{sys}. Check LLT configuraton");
            push(@m,$msg);
        }
        if($sys->exists('/etc/llttab') && $sys->exists('/etc/llthosts')){
            $rtn1=$sys->cmd("_cmd_grep '^set-node' /etc/llttab 2>/dev/null");
            $rtn2=$sys->cmd("_cmd_grep '^set-cluster' /etc/llttab 2>/dev/null");
            $rtn3=$sys->catfile("/etc/llthosts");
            unless($rtn1 && $rtn2=~/\d+/){
                $msg=Msg::new("\n\tconfiguration file /etc/llttab is invalid");
                push(@m,$msg);
            }
            if($rtn3){
                foreach my $ln (split(/\n/,$rtn3)){
                    if($ln !~ /^\d+\s+/){
                        $msg=Msg::new("\n\t/etc/llthosts is invalid on $sys->{sys}");
                        push(@m,$msg);
                        last;
                    }
                }
            }
            $sysname=$1 if($rtn1=~/^set-node\s+(.*)/);
            $sysname =~ s/"(.*)"/$1/m;
            if ($sysname =~ /\//mx && $sys->exists($sysname)){
                # filename as set-node arg
                $sysname = $sys->readfile($sysname,1);
                chomp $sysname;
                $sysname =~ s/"(.*)"/$1/m;
            }
            if($sysname){
                $output=$sys->cmd("_cmd_grep $sysname /etc/llthosts 2>/dev/null");
                if (!$output || $output =~ /#/){
                    $msg=Msg::new("\n\tthe system name in /etc/llthosts is different with that in /etc/llttab");
                    push(@m,$msg);
                }
            }
            $rtn2=$sys->cmd("_cmd_grep '^link' /etc/llttab 2>/dev/null | _cmd_wc -l");
            if($rtn2==0){
                $msg=Msg::new("\n\theartbeatlink is not configured on $sys->{sys}");
                push(@m,$msg);
            } else {
                $rtn=$sys->catfile('/etc/llttab');
                (undef,$slavenics)=$padv->bondednics_sys($sys);
                $systemnics=$padv->systemnics_sys($sys,1);
                foreach my $line (split(/\n/,$rtn)){
                    if($line=~/^link/){
                        (undef,$nic,undef)=split(/\s+/,$line,3);
                        if(!EDRu::inarr($nic,@{$systemnics})){
                            if(EDRu::inarr($nic,@{$slavenics})){
                                $list.=" $nic";
                            } else {
                                $wrongnics.=" $nic";
                            }
                        }
                    }
                }
                if($wrongnics){
                    $msg=Msg::new("\n\tThe NICS$wrongnics cannot be found on $sys->{sys}. It is recommended to check the NICs configuration");
                    push(@m,$msg);
                }
                if($list){
                    $msg=Msg::new("\n\tThe NICS$list is a part of bonding/agreegation NIC on $sys->{sys}. It cannot be used for the heartbeat link.");
                    push(@m,$msg);
                }
            }
        }
    }
    $prod->postcheck_lltstat_sys($sys);
    $downlinks=$sys->{down_links};
    if($downlinks && @{$downlinks} && $sys->system1){
        my $downnics=$prod->postcheck_nics();
        foreach my $line(@{$downnics}){
            my ($sys1,$nic1,$sys2,$nic2)=split(/#/,$line);
            if ( $nic2 eq 'all' ) {
                $msg=Msg::new("\n\tThe NIC $nic1 on $sys1 cannot communicate with any NIC configured for LLT on $sys2. It is recommended to check the configuration of this NIC");
            } else {
                $msg=Msg::new("\n\tThe NIC $nic1 on $sys1 cannot communicate with the NIC $nic2 on $sys2. It is recommended to check the configuration of this NIC");
            }
            push(@m,$msg);
        }
    }
    if (@m) {
        $sys->push_error(@m);
        return 0;
    }
    return 1;
}

sub postcheck_lltvers_sys {
    my ($prod,$sys)=@_;
    return $prod->postcheck_pkg_vers_sys($sys,"VRTSllt61");
}

sub postcheck_pkg_vers_sys {
    my ($prod,$sys,$pkgname)=@_;
    my ($systems,$vers,$pkg,$isru,$msg,$pkgvers,$cpic,$rel);
    $cpic = Obj::cpic();
    $rel = Obj::rel();
    # for MR/HF releases, don't do package check.
    return 1 if ($rel->{type}!~/B/);
    $systems=CPIC::get("systems");
    $pkg = $sys->pkg($pkgname);
    $vers=$pkg->version_sys($sys);
    if ($cpic->{fromdisk}) {
        $pkgvers = $pkg->{gavers} || $rel->{vers};
    } else {
        $pkgvers = $pkg->{vers};
    }
    $isru=$sys->cmd("_cmd_grep 'V' /etc/gabtab 2>/dev/null");
    if(EDRu::compvers($vers,$pkgvers) != 0 && !$isru){
        $pkgname=~s/\d+//g;
        $msg=Msg::new("The package version of $pkgname on $sys->{sys} is not consistent with the release. Verify if the $pkgname package is installed correctly");
        $sys->push_error($msg);
        return 0;
    }
    return 1;
}

sub postcheck_clusterid_sys {
    my ($prod,$sys)=@_;
    my ($out,$output,$proc,$msg,$clusterid,$found);
    $proc=$sys->proc("llt61");
    $found=0;
    return 1 if($proc->check_sys($sys));
    if($sys->system1){
       $output=$sys->catfile("/etc/llttab");
       foreach my $ln (split(/\n/,$output)){
           if($ln=~/set-cluster\s+(\d+)/){
                $clusterid=$1;
                last;
           }
       }
       if($clusterid){
            $out=$sys->cmd("_cmd_lltconfig -N 2>&1");
            #line=cidfound =   2415, vermaj = 3, vermin = 7;
            #line=ClusterID =  12541,  LLTProtocolVersion = 5.0
            return -1 if(EDR::cmdexit() !=0 || $out=~/ERROR/);
            foreach my $line(split /\n/, $out){
                if($line=~/cidfound/){
                    $found=1 if($line=~/cidfound\s+=\s+$clusterid,/);
                } else {
                    $found=1 if($line=~/ClusterID\s+=\s+$clusterid,/);
                }
            }
            if ($found) {
                $msg=Msg::new("There is another cluster using the same cluster ID. Reconfigure the cluster using a different cluster ID.");
                $sys->push_error($msg);
                return 0;
            }
        }
    }
    return 1;

}

sub postcheck_lltenable_sys {
    my ($prod,$sys)=@_;
    my ($msg,$report,$file,$conf,$proc,$rtn);

    return if $prod->task_need_skip_sys($sys, $prod->{llttab});
    $proc=$sys->proc("llt61");
    $file=$proc->{initconf};
    $conf=$sys->catfile($file);
    $rtn=$sys->cmd('_cmd_lltconfig 2>&1');
    if ($rtn!~/LLT is running/m) {
        if($conf !~/\s*LLT_START\s*=\s*1/){
            $report=Msg::new("llt is configured to NOT start on $sys->{sys}. Check in $file if it is configured correctly");
            $sys->push_error($report);
            return 0;
        }
    }
    return 1;
}

sub postcheck_gab_sys {
    my ($prod,$sys)=@_;
    my ($msg,$report,$file,$conf,$proc,@m);

    return if $prod->task_need_skip_sys($sys, $prod->{gabtab});
    $proc=$sys->proc("gab61");
    $file=$proc->{initconf};
    $conf=$sys->catfile($file);
    if($conf !~/\s*GAB_START\s*=\s*1/){
       $msg=Msg::new("GAB is configured to NOT start on $sys->{sys}. Check in $file if it is configured correctly");
       push(@m,$msg);
    }
    if($sys->exists('/etc/gabtab')){
       my $out=$sys->cmd("_cmd_cat /etc/gabtab 2>/dev/null | _cmd_grep -v '#'");
       my $n=$#{CPIC::get("systems")}+1;
       if($out !~ /gabconfig\s+\-c\s+\-n\d+\s*$/){
          unless($out =~ /gabconfig\s+\-c\s+\-n\d+\s+\-V\d+\s*$/){
             $msg=Msg::new("\n\tgab configuration file is incorrect. It is recommended to check the configuration file /etc/gabtab");
             push(@m,$msg);
          }
       }
    } else {
        $msg=Msg::new("\n\tgab is not configured to on $sys->{sys}.It is recommended to configure GAB on the cluster.");
        push(@m,$msg);
    }
    if (@m) {
        $sys->push_error(@m);
        return 0;
    }
    return 1;
}

sub postcheck_gabvers_sys {
    my ($prod,$sys)=@_;
    return $prod->postcheck_pkg_vers_sys($sys,"VRTSgab61");
}

sub postcheck_vxfenvers_sys {
    my ($prod,$sys)=@_;
    return $prod->postcheck_pkg_vers_sys($sys,"VRTSvxfen61");
}

sub postcheck_vcsvers_sys {
    my ($prod,$sys)=@_;
    return $prod->postcheck_pkg_vers_sys($sys,"VRTSvcs61");
}


sub postcheck_vxfen_sys {
    my ($prod,$sys) = @_;
    my ($msg,$line,$rtn,$proc,$file,$report,$output,$vxfenmode,$diskgroup,@m);

    return if $prod->task_need_skip_sys($sys, $prod->{vxfenmode});

    $proc=$sys->proc("vxfen61");
    $file=$proc->{initconf};

    $rtn=$sys->cmd('_cmd_vxfenadm -d 2>&1');
    for my $line (split(/\n/,$rtn)) {
        if ($line=~/ERROR/m) {
            $msg=Msg::new("vxfen is not started on $sys->{sys}");
            push(@m,$msg);
            if (!$sys->exists('/etc/vxfenmode') && !$sys->exists('/etc/vxfendg')) {
                $msg=Msg::new("\n\tvxfen is not configured on $sys->{sys}. It is recommended to check I/O Fencing configuration in file /etc/vxfenmode.");
                push(@m,$msg);
                $sys->push_warning(@m);
                return 0;
            }

            $vxfenmode='';
            $output=$sys->cmd("_cmd_grep 'vxfen_mode' /etc/vxfenmode 2>/dev/null");
            if ($output =~/^\s*vxfen_mode\s*=\s*(scsi3|sybase|disabled|customized)\s*/mx) {
                $vxfenmode=$1;
            }
            if ($vxfenmode) {
                if ($vxfenmode eq 'scsi3' || $vxfenmode eq 'sybase') {
                    $diskgroup=$sys->cmd("_cmd_cat /etc/vxfendg 2>/dev/null");
                    chomp $diskgroup;
                    if ($diskgroup) {
                        $rtn=$sys->cmd("_cmd_vxdisk -o alldgs list 2>/dev/null | _cmd_grep $diskgroup");
                        if (!$rtn) {
                           $msg=Msg::new("\n\tCoordinator disk defined in file /etc/vxfendg is not found or VM is not running on $sys->{sys}.");
                           push(@m,$msg);
                           $sys->push_error(@m);
                           return 0;
                        }
                    }
                }
            } else {
                $msg=Msg::new("\n\tWrong vxfen configuration on $sys->{sys}. It is recommended to check I/O Fencing configuration in file /etc/vxfenmode.");
                push(@m,$msg);
                $sys->push_error(@m);
                return 0;
            }

            $output=$sys->cmd("_cmd_grep 'VXFEN_START' $file 2>/dev/null");
            if ($output !~ /^\s*VXFEN_START\s*=\s*1/mx){
                $msg=Msg::new("\n\tvxfen is configured to NOT start on $sys->{sys}. Check in $file if it is configured correctly");
                push(@m,$msg);
            }
            $sys->push_error(@m);
            return 0;
        } elsif ($line=~/Fencing Mode: Disabled/m) {
            $msg=Msg::new("vxfen is in disable state on $sys->{sys}");
            $sys->push_warning($msg);
            return 0;
        }
    }
    return 1;
}

sub postcheck_had_sys {
    my ($prod,$sys) = @_;
    my ($rtn,$msg,$report,@m);
    $rtn=$sys->cmd("/opt/VRTSvcs/bin/hacf -verify /etc/VRTSvcs/conf/config/");
    if (EDR::cmdexit()!=0) {
        $msg=Msg::new("\n\tVCS configuration is incorrect on $sys->{sys}. It is recommended to check VCS configuration");
        push(@m,$msg);
    }
    $rtn=$sys->catfile("/etc/VRTSvcs/conf/sysname");
    if($rtn ne $sys->{hostname}){
        $msg=Msg::new("\n\tThe system name in /etc/VRTSvcs/conf/sysname is not consistent with hostname on $sys->{sys}. It is recommended to check the configuration file.");
        push(@m,$msg);
    }
    unless($prod->check_uuid){
        $msg=Msg::new("\n\tUUID is not configured on the cluster correctly. Configure UUID again on the cluster.");
        push(@m,$msg);
        unless($sys->exists($prod->{uuidconfig})){
            $msg=Msg::new("\n\tuuidconfig.pl cannot be found on the cluster. Check if the cluster is installed correctly.\n");
            push(@m,$msg);
        }
    }
    if (@m) {
        $sys->push_error(@m);
        return 0;
    }

    return 1;
}

sub postcheck_gabconfig_sys {
    my ($prod,$sys) = @_;
    my ($msg,$ports,%gab_ports,%gab_jeopardy_ports,$port,@jeopardy_ports,$line,$rtn,@ports,@check_ports);

    return if $prod->task_need_skip_sys($sys, $prod->{gabtab});
    $rtn=$sys->cmd("_cmd_gabconfig -l 2> /dev/null| _cmd_grep 'Driver state' | _cmd_awk '{ print \$4;}'");
    if (($rtn ne 'Configured') && ($rtn ne 'ConfiguredPartition')) {
        $msg=Msg::new("GAB is not in configured state on $sys->{sys}");
        $sys->push_error($msg);
        return 0;
    }

    $rtn=$sys->cmd("_cmd_gabconfig -a 2>&1 | _cmd_grep 'Port' | _cmd_grep 'gen'");
    for my $line (split(/\n/,$rtn)) {
        if ($line=~/GAB gabconfig ERROR/m) {
            $msg=Msg::new("GAB is not started on $sys->{sys}");
            $sys->push_error($msg);
            return 0;
        } elsif ($line=~/^Port (\S)\s+gen\s+\S+\s+membership/m) {
            $gab_ports{$1}=1;
        } elsif ($line=~/^Port (\S)\s+gen\s+\S+\s+jeopardy/m) {
            $gab_jeopardy_ports{$1}=1;
        }
    }

    @check_ports=qw(a h);
    if ($sys->exists("$prod->{vxfenmode}")) {
        @check_ports=qw(a b h);
    }

    for my $port (@check_ports) {
        push (@ports, $port) unless($gab_ports{$port});
        push (@jeopardy_ports, $port) if($gab_jeopardy_ports{$port});
    }

    if (@ports) {
        $ports=join(',',@ports);
        $msg=Msg::new("The following gab ports are not started on $sys->{sys}:\n\t$ports");
        #$sys->push_warning($msg);
    }

    if (@jeopardy_ports) {
        $ports=join(',',@jeopardy_ports);
        $msg=Msg::new("The following gab ports are in jeopardy state on $sys->{sys}:\n\t$ports");
        $sys->push_warning($msg);
        return 0;
    }

    return 1 unless (@ports);
    return 0;
}

sub postcheck_hastatus_sys {
    my ($prod,$sys) = @_;
    my ($msg,@offline_groups,$state,$group,$onlines,$warning,$line,$rtn,$parallel,@failover_groups,@systems,$systems,$groups,@m);

    $rtn=$sys->cmd("_cmd_hasys -state $sys->{vcs_sysname}");
    for my $line (split(/\n/,$rtn)) {
        next if ($line=~/^#/m);
        if ($line !~/RUNNING/m) {
            $msg=Msg::new("HAD is not in RUNNING status on $sys->{sys}");
            push(@m,$msg);
            #$sys->push_error($msg);
            $rtn=$sys->cmd("/opt/VRTSvcs/bin/hacf -verify /etc/VRTSvcs/conf/config/");
            if (EDR::cmdexit()!=0 || $rtn=~/WARNING/) {
                $msg=Msg::new("\n\t$rtn\nIt is recommended to check VCS configuration on $sys->{sys}");
                push(@m,$msg);
            }
            $rtn=$sys->catfile("/etc/VRTSvcs/conf/sysname");
            if($rtn ne $sys->{hostname}){
                $msg=Msg::new("\n\tThe system name in /etc/VRTSvcs/conf/sysname is not consistent with hostname on $sys->{sys}. It is recommended to check the configuration file.");
                push(@m,$msg);
            }
            unless($prod->check_uuid){
                $msg=Msg::new("\n\tUUID is not configured on the cluster correctly. Configure UUID again on the cluster.");
                push(@m,$msg);
                unless($sys->exists($prod->{uuidconfig})){
                    $msg=Msg::new("\n\tuuidconfig.pl cannot be found on the cluster. Check if the cluster is installed correctly.\n");
                    push(@m,$msg);
                }
            }

            $sys->push_error(@m);
            return 0;
        } elsif ($line=~/^(\S+)\s+SysState\s+(\S+)/mx) {
            push (@systems,"$1") if ($2 ne 'RUNNING');
        }
    }

    if (@systems) {
        $systems=join(',',@systems);
        $msg=Msg::new("Checking from $sys->{sys}, HAD is not in running state on the following systems:\n\t$systems");
        $sys->push_error($msg);
        $warning=1;
    }

    my $sysname = $sys->{vcs_sysname};
    $rtn=$sys->cmd("_cmd_hagrp -state -sys $sysname 2>&1");
    for my $line (split(/\n/,$rtn)) {
        next if ($line=~/^#/m);
        if ($line=~/^(\S+)\s+State\s+\S+\s+\|(\S+)\|/mx) {
            $group=$1;
            $state=$2;
            $parallel=$sys->cmd("_cmd_hagrp -value $group Parallel 2>/dev/null");
            if ($parallel ne '0') {
                push(@offline_groups, $group) if ($state ne 'ONLINE');
            } else {
                # For failover service group
                $onlines=$sys->cmd("_cmd_hagrp -state $group | _cmd_grep ONLINE | _cmd_wc -l 2>/dev/null");
                if ($onlines != 1) {
                    push(@failover_groups, $group);
                }
            }
        }
    }

    if (@offline_groups) {
        $groups=join("\n\t",@offline_groups);
        $msg=Msg::new("The following service groups are not in online state on $sys->{sys}:\n\t$groups");
        $sys->push_warning($msg);
        $warning=1;
    }

    if (@failover_groups) {
        $groups=join("\n\t",@failover_groups);
        $msg=Msg::new("Checking from $sys->{sys}, the following Failover service groups are not online on one and only one system:\n\t$groups");
        $sys->push_warning($msg);
        $warning=1;
    }

    return 0 if($warning);
    return 1;
}

sub register_postchecks {
    my ($prod,$sequence_id,$name,$desc,$handler, $sysname);
    $prod=shift;
    for my $sys (@{CPIC::get('systems')}) {
        $sysname = $prod->get_vcs_sysname_sys($sys);
        $sys->set_value('vcs_sysname',$sysname);
    }
    $sequence_id=300;
    $name='lltstat';
    $desc=Msg::new("lltstat status");
    $handler=\&postcheck_lltstat_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=320;
    $name='lltconfig';
    $desc=Msg::new("llt configuration");
    $handler=\&postcheck_lltconfig_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=322;
    $name='lltlinkinstall';
    $desc=Msg::new("llt starting setting");
    $handler=\&postcheck_lltenable_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=323;
    $name='clusterid';
    $desc=Msg::new("clusterid configuration");
    $handler=\&postcheck_clusterid_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=330;
    $name='gabconfig';
    $desc=Msg::new("gabconfig ports status");
    $handler=\&postcheck_gabconfig_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=332;
    $name='gabenable';
    $desc=Msg::new("GAB starting setting");
    $handler=\&postcheck_gab_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=335;
    $name='vxfen';
    $desc=Msg::new("vxfen status");
    $handler=\&postcheck_vxfen_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=340;
    $name='hastatus';
    $desc=Msg::new("had status");
    $handler=\&postcheck_hastatus_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    return 1;
}

#
# VCS add node
#

sub opt_addnode {
    my $vcs = shift;
    my $cprod=CPIC::get('prod');
    my $prod = $vcs->prod($cprod);
    for my $sub (qw(addnode_messages addnode_get_cluster addnode_get_newnode addnode_compare_systems
                    addnode_configure_heartbeat addnode_configure_cluster addnode_start_cluster
                    addnode_poststart addnode_completion))
    {
        if ($prod->can($sub)) {
            $prod->$sub();
        } else {
            $vcs->$sub();
        }
    }
    return;
}

sub web_opt_addnode {
    my $vcs = shift;
    my $cprod = CPIC::get('prod');
    my $prod = $vcs->prod($cprod);

    for my $sub (qw(web_addnode_messages web_addnode_get_cluster web_addnode_get_newnode addnode_compare_systems
                    web_addnode_configure_heartbeat addnode_configure_cluster addnode_start_cluster
                    addnode_poststart addnode_completion)) {
        if ($prod->can($sub)) {
            $prod->$sub();
        } else {
            $vcs->$sub();
        }
    }
    return;
}

sub addnode_messages {
    my $prod = shift;
    my $pdfrs=Msg::get('pdfrs');
    my($msg);
    my $cprod=CPIC::get('prod');
    $prod = $prod->prod($cprod);


    # display messages
    $msg = Msg::new("Following are the prerequisites to add a node to the cluster:\n");
    $msg->print;
    $msg = Msg::new("\t* The cluster to which you want to add the node must have all required $prod->{abbr} $pdfrs installed\n");
    $msg->print;
    $msg = Msg::new("\t* New node must have all required $prod->{abbr} $pdfrs installed\n");
    $msg->print;
    $msg = Msg::new("\t* $prod->{abbr} must be running on the cluster to which you want to add a node\n");
    $msg->print;
    $msg = Msg::new("\t* There should be no prior running $prod->{abbr} processes on the new node\n");
    $msg->print;
    $msg = Msg::new("\t* New node must have the same $prod->{abbr} version as that of the existing cluster nodes\n");
    $msg->print;
    $msg = Msg::new("Refer to the $prod->{abbr} Installation Guide for more details\n");
    $msg->print;
    Msg::prtc();
    return;
}

sub web_addnode_messages {
    my $pdfrs=Msg::get('pdfrs');
    my($msg,$cprod);
    $cprod=CPIC::get('prod');
    $cprod=~s/\d+$//m;
    my $web = Obj::web();

    $msg = Msg::new("Following are the prerequisites to add a node to the cluster:\\n")->{msg};
    $msg .= Msg::new("<ul><li>The cluster to which you want to add the node must have all required $cprod $pdfrs installed</li>")->{msg};
    $msg .= Msg::new("<li>New node must have all required $cprod $pdfrs installed</li>")->{msg};
    $msg .= Msg::new("<li>$cprod must be running on the cluster to which you want to add a node</li>")->{msg};
    $msg .= Msg::new("<li>There should be no prior running $cprod processes on the new node</li>")->{msg};
    $msg .= Msg::new("<li>New node must have the same $cprod version as that of the existing cluster nodes</li></ul>")->{msg};
    $msg .= Msg::new("\\nRefer to the $cprod Installation Guide for more details")->{msg};

    $web->web_script_form('alert', $msg);
    return;
}

sub addnode_get_cluster {
    my ($ayn,$clustername,$clusterid,$conf,$done,$had,$llttab,$maincf,$msg,$node,$sys,$sysi,@systems,$syslist,$smsg);
    my $prod = shift;
    my $edr = Obj::edr();
    my $cfg = Obj::cfg();
    my $cprod=CPIC::get('prod');
    $cprod=~s/\d+$//m;

    $edr->{savelog} = 1;
    # ask for the running cluster by entering one of its nodes
    while(1) {
        Msg::title();
        if (Cfg::opt('responsefile')) {
            $node = ${$cfg->{clustersystems}}[0];
        } else {
            $msg = Msg::new("Enter one node of the $cprod cluster to which you would like to add one or more new nodes:");
            $node = $msg->ask();
            $node = EDRu::despace($node);
            Msg::n();
        }
        next if ($edr->validate_systemnames($node));
        $sysi = $node;
        $sys = Sys->new($sysi); # initialize system objects

        # @{$cfg->{systems}} = ($node);
        if ($edr->check_and_setup_transport_sys($sys)==-1) {
            next;
        }

        $msg=Msg::new("Checking release compatibility on $sysi");
        $msg->left;
        if ($edr->supported_padv_sys($sys)) {
            Msg::right_done();
        } else {
            Msg::right_failed();
            Msg::n();
            for my $errmsg (@{$sys->{errors}}) {
                Msg::print("$errmsg\n");
            }
            undef($sys->{errors});
            next;
        }

        if (Cfg::opt('responsefile')) {
            @systems = @{$cfg->{clustersystems}};
        } else {
            # get cluster systems
            $conf = $prod->get_config_sys($sys);
            if ($conf) {
                $clustername = $conf->{clustername};
                @systems = @{$conf->{systems}};
                if ($conf->{onenode}) {
                    # onenode cluster
                    Msg::n();
                    $msg = Msg::new("Cluster $clustername is a single node cluster, and llt/gab are not configured on the node");
                    $msg->print();
                    $msg = Msg::new("So no cluster ID can be found, it can be configured after heartbeat link configuration");
                    $msg->print();
                } else {
                    $clusterid = $conf->{clusterid};
                }
            } else {
                $msg = Msg::new("Can not find valid configuration information on $sysi");
                $msg->print;
                next;
            }

            # show verification messages
            Msg::n();
            $msg = Msg::new("Following cluster information detected:\n");
            $msg->bold;
            $smsg.=$msg->{msg}."\n";
            $msg = Msg::new("\tCluster Name: $clustername");
            $msg->print;
            $smsg.=$msg->{msg}."\n";
            $msg = Msg::new("\tCluster ID: $clusterid");
            $msg->print;
            $smsg.=$msg->{msg}."\n";
            $syslist = join(' ',@systems);
            $msg = Msg::new("\tSystems: $syslist");
            $smsg.=$msg->{msg}."\n";
            $msg->printn;
            $msg = Msg::new("Is this information correct?");
            $ayn = $msg->ayny;
            Msg::n();
            next if ($ayn eq 'N');
        }
        $msg->{msg}=$smsg;
        # Add the cluster info into summary file
        $msg->add_summary(1);

        # check max number in cluster
        if (scalar(@systems) == $prod->{max_number_in_cluster}) {
            $msg = Msg::new("The cluster, $clustername, already has $prod->{max_number_in_cluster} nodes. $prod->{abbr} supports only a maximum of $prod->{max_number_in_cluster} nodes in a cluster.");
            $msg->print;
            next;
        }

        # check if only singlenode license exists
        if ((scalar(@systems) == 1) && $prod->singlenode_vcs_licensed_sys($sys)) {
            $msg = Msg::new("Only single-node VCS license exists on $sys->{sys}, cannot add a new node to the single-node cluster");
            $msg->print;
            next;
        }

        $done = 1;

        # check communication
        for my $sysi (@systems) {
            next if ($sysi eq $node); # already check it at the beginning
            $sys = Sys->new($sysi); # initialize system objects
            $msg = Msg::new("Checking communication on $sysi");
            $msg->left;
            $sys->set_value('stop_checks', 0);
            if ($edr->transport_sys($sys)) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $done = 0;
            }
        }
        next unless($done);

        # check vcs running state
        for my $sysi (@systems) {
            $sys = Obj::sys($sysi);
            $had = $sys->proc('had61');
            $msg = Msg::new("Checking $prod->{abbr} running state on $sysi");
            $msg->left;
            if ($had->check_sys($sys,'poststart')) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $done = 0;
            }
            # set vcs_sysname
            $sys->{vcs_sysname} = $prod->get_vcs_sysname_sys($sys);
        }

        if ($done) {
            unless (Cfg::opt('responsefile')) {
                $cfg->{vcs_clustername} = $clustername;
                $cfg->{vcs_clusterid} = $clusterid;
                $cfg->{clustersystems} = \@systems;
            }
            sleep 3;
            last;
        } else {
            Msg::n();
            for my $sysi (@systems) {
                $sys = Obj::sys($sysi);
                for my $errmsg (@{$sys->{errors}}) {
                    Msg::print("$errmsg\n");
                }
                undef($sys->{errors});
            }
        }

    } continue {
        if (Cfg::opt('responsefile')) {
            $msg = Msg::new("Failed to add node(s) using response file");
            $msg->die();
        }
        $msg = Msg::new("Do you want to enter a node name for another cluster?");
        $ayn = $msg->aynn;
        Msg::n();
        EDR::exit_exitfile() if ($ayn eq 'N');
    }
    return;
}

sub web_addnode_get_cluster {
    my ($ayn,$clustername,$clusterid,$conf,$done,$errmsg,$had,$llttab,$maincf,$msg,$node,@systems);
    my $errinfo;

    my $prod = shift;
    my $edr = Obj::edr();
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $edr->{savelog} = 1;
    # ask for the running cluster by entering one of its nodes

    while(1) {
        if (Cfg::opt('responsefile')) {
            $node = ${$cfg->{clustersystems}}[0];
        } else {
            $msg = Msg::new("Enter one system of the cluster to which you would like to add one or more new nodes");
            my $syslist = $web->web_script_form('selectCluster', $msg);
            $node = $$syslist[0];
        }

        $web->web_script_form('precheck');
        my $stage = Msg::new("Retrieving cluster information");
        $edr->set_progress_steps(2);

        my $sysi = $node;
        my $sys = Sys->new($sysi);

        if ($edr->check_and_setup_transport_sys($sys)==-1) {
            next;
        }

        $msg = Msg::new("Checking release compatibility on $sysi");
        $stage->display_left($msg);
        if ($edr->supported_padv_sys($sys)) {
            $stage->display_right();
        } else {
            for my $errmsg (@{$sys->{errors}}) {
                $stage->addError($errmsg);
            }
            next;
        }

        if (Cfg::opt('responsefile')) {
            @systems = @{$cfg->{clustersystems}};
        } else {
            # get cluster systems
            $conf = $prod->get_config_sys($sys);
            if ($conf) {
                $clustername = $conf->{clustername};
                @systems = @{$conf->{systems}};
                $clusterid = $conf->{clusterid} unless ($conf->{onenode});
            } else {
                $msg = Msg::new("Can not find valid configuration information on $sysi");
                $stage->addError($msg->{msg});
                next;
            }

            # show verification messages
            $msg = Msg::new("Following cluster information detected:\n");
            $msg->{msg} .= Msg::new("\tCluster Name: $clustername\n")->{msg};
            unless ($conf->{onenode}) {
                $msg->{msg} .= Msg::new("\tCluster ID: $clusterid\n")->{msg};
            }

            my $syslist = join(' ',@systems);
            $msg->{msg} .= Msg::new("\tSystems: $syslist\n")->{msg};
            my $ask_msg = Msg::new("Is this information correct?");

            $ayn = $ask_msg->ayny('', '', $msg);
            next if ($ayn eq 'N');
            $msg->add_summary(1);
            $web->{marquee_syslist} = $syslist if (Obj::webui());
        }

        # check max number in cluster
        if (scalar(@systems) == $prod->{max_number_in_cluster}) {
            $msg = Msg::new("The cluster, $clustername, already has $prod->{max_number_in_cluster} nodes. $prod->{abbr} supports only a maximum of $prod->{max_number_in_cluster} nodes in a cluster.");
            $web->web_script_form('alert', $msg->{msg});
            next;
        }

        # check if only singlenode license exists
        if ((scalar(@systems) == 1) && $prod->singlenode_vcs_licensed_sys($sys)) {
            $msg = Msg::new("Only single-node VCS license exists on $sys->{sys}, cannot add a new node to the single-node cluster");
            $web->web_script_form('alert', $msg->{msg});
            next;
        }

        $done = 1;

        # check communication
        $errinfo = '';
        for my $sysi (@systems) {
            next if ($sysi eq $node); # already check it at the beginning
            $sys = Sys->new($sysi); # initialize system objects
            $sys->set_value('stop_checks', 0);
            if ($edr->transport_sys($sys)) {
            } else {
                $errinfo .= join('\\n', @{$sys->{errors}});
                $errinfo .= '\\n';
                $done = 0;
            }
        }
        unless ($done) {
            $web->web_script_form('alert', $errinfo);
            next;
        }
        # check vcs running state
        for my $sysi (@systems) {
            $sys = Obj::sys($sysi);
            $had = $sys->proc('had61');

            if (!$had->check_sys($sys,'poststart')) {
                $msg = Msg::new("$prod->{abbr} is not in running state on $sysi, the cluster needs to be running when adding node(s)");
                $stage->addError($msg->{msg});
                $done = 0;
            }
            # set vcs_sysname
            $sys->{vcs_sysname} = $prod->get_vcs_sysname_sys($sys);
        }

        if ($done) {
            unless (Cfg::opt('responsefile')) {
                $cfg->{vcs_clustername} = $clustername;
                $cfg->{vcs_clusterid} = $clusterid;
                $cfg->{clustersystems} = \@systems;
            }
            last;
        } else {
            $web->web_script_form('alert',$web->{errors});
            undef($web->{errors});
        }

    } continue {
        if (Cfg::opt('responsefile')) {
            $msg = Msg::new("Failed to add node(s) using response file");
            $msg->die();
        }
        $msg = Msg::new("Do you want to enter a node name for another cluster?");
        $ayn = $msg->aynn;
        Msg::n();
        $msg = Msg::new("Failed to add node(s)");
        $msg->die() if ($ayn eq 'N');
    }
    return;
}

sub addnode_get_newnode {
    my ($ayn,$done,$had,$msg,$nodelist,@newnodes,$sys,$sysi,$syslist,@allsystems,@t_newnodes);
    my $prod = shift;
    my $edr = Obj::edr();
    my $cfg = Obj::cfg();
    my @procs = (qw(llt61 gab61));
    my ($vxfenpkg,$sys0);
    $vxfenpkg = $prod->pkg('VRTSvxfen61');
    $sysi = ${$cfg->{clustersystems}}[0];
    $sys0 = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);

    # ask for new node to be added
    while (1) {
        @t_newnodes=();
        if (Cfg::opt('responsefile')) {
            @newnodes = @{$cfg->{newnodes}};
        } elsif (defined $cfg->{systems}) {
            @newnodes = @{$cfg->{systems}};
        } else {
            Msg::title();
            $msg = Msg::new("Enter the system names separated by spaces to add to the cluster:");
            $nodelist = $msg->ask();
            Msg::n();
            $nodelist = EDRu::despace($nodelist);
            @newnodes = split(/\s+/m,$nodelist);
        }
        next if ($edr->validate_systemnames(@newnodes));

        # check each new node
        $done = 1;
        for my $sysi (@newnodes) {
            $sys = Sys->new($sysi); # initialize system objects
            if(EDRu::inarr($sysi,@{$cfg->{clustersystems}})) {
                $msg = Msg::new("System $sysi is already a member of the cluster $cfg->{vcs_clustername}");
                $sys->push_error($msg);
                $done = 0;
                next;
            }

            if ($edr->check_and_setup_transport_sys($sys)==-1) {
                $done = 0;
                next;
            }

            # only check time sync for the sys that passed transport_sys check
            push (@t_newnodes,$sys->{sys});

            $msg=Msg::new("Checking release compatibility on $sysi");
            $msg->left;
            if ($edr->supported_padv_sys($sys)) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $done = 0;
                next;
            }

            $msg=Msg::new("Checking swap space on $sysi");
            $msg->left;
            if ($prod->swap_size_sys($sys)) {
                Msg::right_done();
            } else {
                Msg::right_failed();
            }

            $had = $sys->proc('had61');
            if ($had->check_sys($sys,'poststart')) {
                $msg = Msg::new("$prod->{abbr} is already running on $sysi");
                $sys->push_error($msg);
                $done = 0;
            }

            for my $procname (@procs) {
                my $proc = $sys->proc($procname);
                if ($proc->check_sys($sys)) {
                    $msg = Msg::new("LLT/GAB is already running on $sysi");
                    $sys->push_error($msg);
                    $done = 0;
                    last;
                }
            }

            my $conf = $prod->get_config_sys($sys);
            if ($conf) {
                $msg = Msg::new("The node $sysi is already a member of cluster $conf->{clustername}");
                $sys->push_error($msg);
                $done = 0;
            }
            # set vcs_sysname
            $sys->{vcs_sysname} = transform_system_name($sysi);
        }

        for my $sysi (@newnodes) {
            $sys = Obj::sys($sysi);
            for my $errmsg (@{$sys->{warnings}}) {
                Msg::bold("$errmsg\n");
            }
            undef($sys->{warnings});
        }

        # check time sync
        Msg::n();
        if ($vxfenpkg->vxfen_mode_sys($sys0) =~ /^(cps|nonscsi3)$/) {
            $msg = Msg::new("Using Coordination Point server over HTTPS requires clock synchronization between the hosts. Make sure the time settings of the client cluster are synchronized with Coordination Point servers.");
            $msg->bold;
            Msg::n();
        }
        @allsystems = ();
        push(@allsystems,@t_newnodes,@{$cfg->{clustersystems}});
        $edr->check_and_setup_timesync(\@allsystems);

        if ($done) {
            unless (Cfg::opt('responsefile')) {
                $syslist = join(' ',@newnodes);
                $msg = Msg::new("Do you want to add the system(s) $syslist to the cluster $cfg->{vcs_clustername}?");
                $ayn = $msg->ayny;
                Msg::n();
                next if ($ayn eq 'N');
                $cfg->{newnodes} = \@newnodes;
            }
            last;
        } else {
            for my $sysi (@newnodes) {
                $sys = Obj::sys($sysi);
                for my $errmsg (@{$sys->{errors}}) {
                    Msg::bold("$errmsg\n");
                }
                undef($sys->{errors});
            }
        }

    } continue {
        if (Cfg::opt('responsefile')) {
            $msg = Msg::new("Failed to add node(s) using response file");
            $msg->die();
        }
        undef($cfg->{systems});
        $msg = Msg::new("Do you want to enter other node name?");
        $ayn = $msg->aynn;
        Msg::n();
        EDR::exit_exitfile() if ($ayn eq 'N');
    }
    return;
}

sub web_addnode_get_newnode {
    my ($ayn,$done,$errmsg,$had,$msg,$nodelist,@newnodes,$sys,$sysi,@allsystems,@t_newnodes);
    my $prod = shift;
    my $edr = Obj::edr();
    my $cfg = Obj::cfg();
    my $web = Obj::web();
    my @procs = (qw(llt61 gab61));
    my ($vxfenpkg,$sys0);
    $sysi = ${$cfg->{clustersystems}}[0];
    $vxfenpkg = $prod->pkg('VRTSvxfen61');
    $sys0 = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);


    # ask for new node to be added
    while (1) {
        @t_newnodes = ();
        if (Cfg::opt('responsefile')) {
            @newnodes = @{$cfg->{newnodes}};
        } else {
            $msg = Msg::new("Enter the system names separated by spaces to add to the cluster");
            my $syslist = $web->web_script_form('selectNewSystems', $msg);
            @newnodes = @$syslist;
        }
        $web->{marquee_syslist} = $web->{marquee_syslist}.' '.join(' ',@newnodes) if (Obj::webui());
        $web->web_script_form('precheck');
        my $stage = Msg::new("Checking new cluster node");
        $edr->set_progress_steps(3);

        # check each new node
        $done = 1;
        for my $sysi (@newnodes) {
            $sys = Sys->new($sysi); # initialize system objects
            if(EDRu::inarr($sysi,@{$cfg->{clustersystems}})) {
                $msg = Msg::new("System $sysi is already a member of the cluster $cfg->{vcs_clustername}");
                $stage->addError($msg->{msg});
                $done = 0;
                next;
            }

            if ($edr->check_and_setup_transport_sys($sys)==-1) {
                next;
            }

            # only check time sync for the sys that passed transport_sys check
            push (@t_newnodes, $sys->{sys});

            $msg=Msg::new("Checking release compatibility on $sysi");
            $stage->display_left($msg);
            if ($edr->supported_padv_sys($sys)) {
                $stage->display_right();
            } else {
                for my $errmsg (@{$sys->{errors}}) {
                    $stage->addError($errmsg);
                }
                undef($sys->{errors});
                $done = 0;
                next;
            }

            $msg=Msg::new("Checking swap space on $sysi");
            $stage->display_left($msg);
            if ($prod->swap_size_sys($sys)) {
                $stage->display_right();
            } else {
                for my $errmsg (@{$sys->{warnings}}) {
                    $stage->addWarning($errmsg);
                }
                undef($sys->{warnings});
            }

            $had = $sys->proc('had61');
            if ($had->check_sys($sys,'poststart')) {
                $msg = Msg::new("$prod->{abbr} is already running on $sysi");
                $stage->addError($msg->{msg});
                $done = 0;
            }

            for my $procname (@procs) {
                my $proc = $sys->proc($procname);
                if ($proc->check_sys($sys)) {
                    $msg = Msg::new("LLT/GAB is already running on $sysi");
                    $stage->addError($msg->{msg});
                    $done = 0;
                    last;
                }
            }

            my $conf = $prod->get_config_sys($sys);
            if ($conf) {
                $msg = Msg::new("The node $sysi is already a member of cluster $conf->{clustername}");
                $stage->addError($msg->{msg});
                $done = 0;
            }
            # set vcs_sysname
            $sys->{vcs_sysname} = transform_system_name($sysi);
        }

        if ($done) {
            Msg::n();
            if ($vxfenpkg->vxfen_mode_sys($sys0) =~ /^(cps|nonscsi3)$/) {
                $msg = Msg::new("Using Coordination Point server over HTTPS requires clock synchronization between the hosts. Make sure the time settings of the client cluster are synchronized with Coordination Point servers.");
                $stage->addNote($msg->{msg});
            }
            @allsystems = ();
            push(@allsystems,@t_newnodes,@{$cfg->{clustersystems}});
            $edr->check_and_setup_timesync(\@allsystems, 5);

            unless (Cfg::opt('responsefile')) {
                my $syslist = join(' ',@newnodes);
                $msg = Msg::new("Do you want to add the system(s) $syslist to the cluster $cfg->{vcs_clustername}?");
                $ayn = $msg->aynn;
                next if ($ayn eq 'N');
                $cfg->{newnodes} = \@newnodes;
            }
            last;
        }

    } continue {
        if (Cfg::opt('responsefile')) {
            $msg = Msg::new("Failed to add node(s) using response file");
            $msg->die();
        }
        undef($cfg->{systems});
    }
    return;
}

sub addnode_compare_systems {
    my ($errmsg,$errmsgobj,$minpkgs,@misspkgs,$n,$msg,$pkgi,$pkg,$prodi,$sysi,$sys,$warnmsg,$warnmsgobj);
    my ($clus_prod,$clus_lic,$clus_ver,$failed,$installed_prodi,$node_prod,$node_lic,$node_ver);
    my ($check_protocolversion, $clus_protocolversion, $local_protocolversion); # extra checks for SFCFSHA/SVS/SFSYBASECE/SFRAC
    my ($check_gco, $check_vr, $check_vfr,$check_lic_gco,$check_lic_vr,$check_lic_vfr);
    my ($check_cpspkgver,$vxfenpkg,$cpspkg,$sfcfsha);
    my $vcs = shift;
    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();
    my $rel = $cpic->rel;
    my $edr = Obj::edr();
    my $prod = $cpic->prod();
    my $padv = $cpic->{padv};
    my @prodlist = qw(SFRAC61 SFSYBASECE61 SVS61 SFCFSHA61 SFHA61 VCS61);

    $n = 0;
    # check installed product and version on first node of the cluster
    $sys = Obj::sys(${$cfg->{clustersystems}}[0]);
    # initialize patches version on Solaris, original called in $edr->rel_padv_sys
    $sys->padv->patches_sys($sys) unless ($sys->{patchvers});
    $msg = Msg::new("Checking installed product on cluster $cfg->{vcs_clustername}");
    $msg->left();
    for my $prodi (@prodlist) {
        $clus_prod = $vcs->prod($prodi,1);
        next unless (defined($clus_prod));
        $clus_ver = $clus_prod->version_sys($sys,1);
        if ($clus_ver) {
            $clus_lic = $rel->prod_licensed_sys($sys,$prodi);
            if ($clus_lic) {
                Msg::right("$clus_prod->{abbr} $clus_ver");
                $installed_prodi = $prodi;
            }
            last;
        }
    }
    if (!$clus_ver) {
        Msg::right_failed();
        Msg::n();
        $msg = Msg::new("$prod->{abbr} is not installed properly on $sys->{sys}");
        $msg->die();
    }
    if (!$clus_lic) {
        Msg::right_failed();
        Msg::n();
        $msg = Msg::new("$clus_prod->{abbr} is installed on $sys->{sys}, but it does not have valid license");
        $msg->die();
    }
    if ($clus_prod->configure_alternate_prod()) {
        $cpic->{prod} = $installed_prodi;
        $prod = $cpic->prod();
    }
    if ($clus_prod->{prod} ne $prod->{prod}) {
        my $upi = lc($clus_prod->{prod});
        $upi = 'sfcfs' if ($upi eq 'sfcfsha'); # no installsfcfsha script
        Msg::n();
        $msg = Msg::new("$clus_prod->{abbr} is installed on cluster $cfg->{vcs_clustername}, use install$upi -addnode to add new node(s)");
        $msg->die();
    }

    # check cluster protocol version if cvm is configured
    $check_protocolversion = 0;
    if ($installed_prodi ne 'SFHA61' && $installed_prodi ne 'VCS61') {
        $check_protocolversion = $sys->cmd('_cmd_vxdctl -c mode 2>/dev/null');
        if ( $check_protocolversion && $check_protocolversion =~ /cluster\s+active/mx) {
            $check_protocolversion = 1;
            $msg = Msg::new("Checking cluster protocol version on cluster $cfg->{vcs_clustername}");
            $msg->left();
            $clus_protocolversion = $sys->cmd('_cmd_vxdctl protocolversion 2>/dev/null');
            if ($clus_protocolversion =~ /Cluster\s+running\s+at\s+protocol\s+(\d+)/mx ) {
                $clus_protocolversion = $1;
                Msg::right("$clus_protocolversion");
            } else {
                Msg::right(Msg->new('Not Applicable')->{msg});
                Msg::log("Failed to get cluster protocol version");
                $check_protocolversion = 0;
            }
        } else {
            $check_protocolversion = $sys->cmd('_cmd_hagrp -resources cvm 2>/dev/null');
            chomp $check_protocolversion;
            if ($check_protocolversion) {
                $check_protocolversion = 1;
                $msg = Msg::new("Checking cluster protocol version on cluster $cfg->{vcs_clustername}");
                $msg->left();
                $clus_protocolversion = $sys->cmd('_cmd_vxdctl setversion 2>/dev/null');
                chomp $clus_protocolversion;
                Msg::right("$clus_protocolversion");
            } else {
                $check_protocolversion = 0;
            }
        }
    }

    # check whether GCO or VVR is configured on cluster
    $check_gco = $check_vr = $check_vfr = 0;
    $check_gco = $sys->cmd('_cmd_hares -list Type=Application StartProgram=/opt/VRTSvcs/bin/wacstart 2>/dev/null');
    $check_gco = $check_gco ? 1 : 0;

    $check_vr = $sys->cmd("_cmd_hares -display -attribute Type 2>/dev/null | _cmd_sed -e '1d' | _cmd_awk '{print \$4}' | _cmd_grep '^RVG'");
    $check_vr = $check_vr ? 1 : 0;

    # check whether GCO or VVR is licensed on cluster
    # assuming all the cluster nodes have the same license keys installed
    $check_lic_gco = $check_lic_vr = $check_lic_vfr = 0;
    $check_lic_gco = $rel->feature_licensed_sys($sys, 'Global Cluster Option');
    $check_lic_gco = $check_lic_gco ? 1 : 0;

    $check_lic_vr = $rel->feature_licensed_sys($sys, "VVR");
    $check_lic_vr = $check_lic_vr ? 1 : 0;
    $check_lic_vfr = $rel->feature_licensed_sys($sys, "VFR");
    $check_lic_vfr = $check_lic_vfr ? 1 : 0;

    # check whether CPS is configured for vxfen
    $check_cpspkgver = undef;
    $vxfenpkg = $vcs->pkg('VRTSvxfen61');
    $cpspkg = $sys->pkg('VRTScps61');
    if ($vxfenpkg && $cpspkg && $vxfenpkg->vxfen_mode_sys($sys) =~ /^(cps|nonscsi3)$/) {
        $check_cpspkgver = $cpspkg->version_sys($sys);
    }

    Cfg::set_opt('installminpkgs');
    $minpkgs = $prod->minpkgs();
    $failed = 0;
    $errmsg = '';
    $warnmsg = '';

    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        # check installed product and version on new node
        $msg = Msg::new("Checking installed product on $sysi");
        $msg->left;
        for my $prodi (@prodlist) {
            $node_prod = $vcs->prod($prodi,1);
            next unless (defined($node_prod));
            $node_ver = $node_prod->version_sys($sys,1);
            if ($node_ver) {
                $node_lic = $rel->prod_licensed_sys($sys,$prodi);
                if ($node_lic) {
                    Msg::right("$node_prod->{abbr} $node_ver");
                }
                last;
            }
        }
        if (!$node_ver) {
            Msg::right_failed();
            $errmsgobj = Msg::new("$prod->{abbr} is not installed completely on $sysi. At least the minimal package set for $prod->{prod} should be installed prior to adding this node to a running cluster");
            $errmsg .= "\n".$errmsgobj->{msg}."\n";
            $failed = 1;
            next;
        }
        if (!$node_lic) {
            Msg::right_failed();
            $errmsgobj = Msg::new("$node_prod->{abbr} is installed on $sysi, but it does not have valid license");
            $errmsg .= "\n".$errmsgobj->{msg}."\n";
            $failed = 1;
            next;
        }
        if ($node_prod->{prod} ne $prod->{prod}) {
            $errmsgobj = Msg::new("$clus_prod->{abbr} is installed on cluster $cfg->{vcs_clustername}, whereas, $node_prod->{abbr} is installed on $sysi. Adding a node between different products is not supported");
            $errmsg .= "\n".$errmsgobj->{msg}."\n";
            $failed = 1;
            next;
        }

        # make version compare between cluster and each new node
        if (EDRu::compvers($clus_ver, $node_ver) == 0) {
            $msg = Msg::new("Checking installed packages on $sysi");
            $msg->left;
            # packages integrality validation, at least the minimial package set required.
            for my $pkgi (@{$minpkgs}) {
                $cpic->create_cpip_objects($sys->{padv});
                $pkg = $sys->pkg($pkgi);
                next if ($pkg->donotinstall_sys($sys));
                push(@misspkgs, $pkgi) unless ($pkg->version_sys($sys));
            }
            if(scalar(@misspkgs) > 0) {
                Msg::right_failed();
                Msg::n();
                $msg = Msg::new("At a minimum, the following packages should be installed prior to adding $sysi to a running cluster:");
                $msg->bold();
                $n=$cpic->list_packages($sys,$n,\@misspkgs);
                $errmsg .= "\n".$msg->{msg};
                $errmsg .= "\n";
                $errmsg .= join(' ', @misspkgs);
                $errmsg .= "\n";
                $failed = 1;
                @misspkgs = ();
            } elsif($check_cpspkgver && !EDRu::inarr('VRTScps61', @{$minpkgs}) && $cpspkg && $cpspkg->version_sys($sys) ne $check_cpspkgver ) {
                Msg::right_failed();
                Msg::n();
                $msg = Msg::new("CPS based fencing is configured in cluster $cfg->{vcs_clustername}, hence package VRTScps $check_cpspkgver should be installed prior to adding $sysi to the cluster");
                $msg->bold();
                $errmsg .= "\n".$msg->{msg}."\n";
                $failed = 1;
            } else {
                Msg::right_done();
            }

        } elsif (EDRu::compvers($clus_ver, $node_ver) == 1) {
            $errmsgobj = Msg::new("$prod->{abbr} installed on $sysi has a lower version than the members in cluster $cfg->{vcs_clustername}");
            $errmsg .= "\n".$errmsgobj->{msg}."\n";
            $failed = 1;
        } elsif (EDRu::compvers($clus_ver, $node_ver) == 2) {
            $errmsgobj = Msg::new("$prod->{abbr} installed on $sysi has a higher version than the members in cluster $cfg->{vcs_clustername}");
            $errmsg .= "\n".$errmsgobj->{msg}."\n";
            $failed = 1;
        }

        # check cluster protocol version in /etc/vx/volboot
        if ( $check_protocolversion && $clus_protocolversion) {
            $msg = Msg::new("Checking cluster protocol version on $sysi");
            $msg->left();
            $sfcfsha = $vcs->prod("SFCFSHA61",1);
            if ( $sfcfsha ) {
                $local_protocolversion = $sfcfsha->{default_cluster_protocol_version};
            }
            if ($sys->exists('/etc/vx/volboot')) {
                for (split(/\n/,$sys->cmd('_cmd_cat /etc/vx/volboot 2>/dev/null'))) {
                    if (/^volboot\s+[0-9\.]+\s+[0-9\.]+\s+([0-9]+)\s*$/) {
                        $local_protocolversion = $1;
                        last;
                    }
                }
            }
            Msg::right("$local_protocolversion");
            if ( $local_protocolversion != $clus_protocolversion) {
                $errmsgobj = Msg::new("Cluster protocol version mismatch was detected between cluster $cfg->{vcs_clustername} and $sysi. Refer to the $prod->{abbr} Installation Guide for more details on how to set or upgrade cluster protocol version");
                $errmsg .= "\n".$errmsgobj->{msg}."\n";
                $failed = 1;
            }
        }

        if ( $check_gco || $check_lic_gco ) {
            $msg = Msg::new("Checking license for Global Cluster Option on $sysi");
            $msg->left;
            if (!$rel->feature_licensed_sys($sys, 'Global Cluster Option')) {
                if ($check_gco) {
                    $errmsgobj = Msg::new("Global Cluster Option (GCO) is configured in the cluster $cfg->{vcs_clustername} but it is not licensed on $sysi");
                    $errmsg .= "\n".$errmsgobj->{msg}."\n";
                    $failed = 1;
                    Msg::right_failed();
                }
                if ($check_lic_gco) {
                    $warnmsgobj = Msg::new("Global Cluster Option (GCO) is licensed in the cluster $cfg->{vcs_clustername} but it is not licensed on $sysi");
                    $warnmsg .= "\n".$warnmsgobj->{msg}."\n";
                    Msg::right_done();
                }
            } else {
                Msg::right_done();
            }
        }
        if ( ($check_vr || $check_lic_vr) && $installed_prodi ne 'VCS61') {
            $msg = Msg::new("Checking license for Symantec Volume Replicator on $sysi");
            $msg->left;
            if (!$rel->feature_licensed_sys($sys, 'VVR')) {
                if ($check_vr) {
                    $errmsgobj = Msg::new("Symantec Volume Replicator is configured in the cluster $cfg->{vcs_clustername} but it is not licensed on $sysi");
                    $errmsg .= "\n".$errmsgobj->{msg}."\n";
                    $failed = 1;
                    Msg::right_failed();
                }
                if ($check_lic_vr) {
                    $warnmsgobj = Msg::new("Symantec Volume Replicator is licensed in the cluster $cfg->{vcs_clustername} but it is not licensed on $sysi");
                    $warnmsg .= "\n".$warnmsgobj->{msg}."\n";
                    Msg::right_done();
                }
            } else {
                Msg::right_done();
            }
        }
        if ( ($check_vfr || $check_lic_vfr) && $installed_prodi ne 'VCS61') {
            $msg = Msg::new("Checking license for Symantec File Replicator Option on $sysi");
            $msg->left;
            if (!$rel->feature_licensed_sys($sys, 'VFR')) {
                if ($check_vfr) {
                    $errmsgobj = Msg::new("Symantec File Replicator Option is configured in cluster $cfg->{vcs_clustername} but it is not licensed on $sysi");
                    $errmsg .= "\n".$errmsgobj->{msg}."\n";
                    $failed = 1;
                    Msg::right_failed();
                }
                if ($check_lic_vfr) {
                    $warnmsgobj = Msg::new("Symantec File Replicator Option is licensed in cluster $cfg->{vcs_clustername} but it is not licensed on $sysi");
                    $warnmsg .= "\n".$warnmsgobj->{msg}."\n";
                    Msg::right_done();
                }
            } else {
                Msg::right_done();
            }
        }
    }
    if ($warnmsg) {
        $msg = Msg::new("The following warnings were discovered on the systems:\n$warnmsg");
        $msg->warning();
    }
    if ($failed) {
        $msg = Msg::new("The following errors were discovered on the systems:\n$errmsg");
        $msg->die();
    }

    Cfg::unset_opt('installminpkgs');
    return 1;
}

sub get_llt_nics {
    my ($prod, $sys) = @_;
    my ($llt_nics, $msg);
    my $vcs = $prod->prod('VCS61');

    return '' unless ($sys->exists($vcs->{llttab}));
    $llt_nics = $sys->cmd("_cmd_awk '/^link/ { print \$2 }' $vcs->{llttab} 2>/dev/null");
    chomp($llt_nics);
    $llt_nics =~ s/\n/\ /g;
    return $llt_nics;
}

# create llttab on new node
sub addnode_configure_heartbeat {
    my ($address,$ayn,$common_speed,$clus_conf,$diff,$key,$lmsg,$msg,$smsg,$n,$netmask,$nic,$onenode,$port,$rhbn,$addrkey,$maskkey,$portkey);
    my ($sys,$sysi);
    my $prod = shift;
    my $edr = Obj::edr();
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

    # reset system list in $cfg->{systems}
    $cfg->{systems} = [];
    my $sys1 = Obj::sys(${$cfg->{clustersystems}}[0]);
    $clus_conf = $prod->get_config_sys($sys1);
    unless ($clus_conf) {
        $msg = Msg::new("The configuration of $sys1->{sys} is not valid, check the cluster.\n");
        $msg->die();
    }
    if ($clus_conf->{onenode}) {
        # without llt/gab, ask for heartbeat confiuration on this node as well
        push (@{$cfg->{systems}}, @{$cfg->{clustersystems}});
        $onenode = 1;
    }
    push(@{$cfg->{systems}}, @{$cfg->{newnodes}});
    $cpic->{systems}=$edr->init_sys_objects();

    while (1) {
        last if (Cfg::opt('responsefile'));
        Msg::title();
        if ($onenode) {
            $rhbn = $prod->hb_config_option();
        } else {
            if ($clus_conf->{lltoverudp}) {
                $cfg->{lltoverudp} = 1;
            }
            if ($clus_conf->{lltoverrdma}) {
                next if (!$prod->setup_rdma_env());

                $cfg->{lltoverudp} = 0;
                $cfg->{autocfgllt} = 0;
                $prod->{llt_rdma} = 1;
            }
            $rhbn=$prod->ask_hbnics_addnode($clus_conf, $sys1->{sys});
        }
        next if (EDR::getmsgkey($rhbn,'back'));

        my $cprod=CPIC::get('prod');
        if ($cprod =~ /^SFRAC\d+/mx) {
            my $llt_nics_str_vcs = $prod->get_llt_nics($sys1);
            my $llt_nics_ne = 0;
            for my $sys (@{CPIC::get('systems')}) {
                my $llt_nics_str_new = '';
                $sysi=$sys->{sys};
                $lmsg='';
                for my $link (1..$prod->num_hbnics($rhbn)) {
                    $key = "lltlink$link";
                    next unless (defined($rhbn->{$key}{$sysi}));
                    $llt_nics_str_new .=' '.$rhbn->{$key}{$sysi};
                }
                $llt_nics_str_new=~ s/^\s+//;
                if ($llt_nics_str_vcs ne $llt_nics_str_new){
                    $llt_nics_ne++;
                    Msg::n();
                    $msg = Msg::new("The LLT links ($llt_nics_str_new) on $sysi are different from the LLT links ($llt_nics_str_vcs) on other nodes.");
                    $msg->bold;
                    $msg->prtc();
                    last;
                }
            }
            next if ($llt_nics_ne);
        }

        if (!$cfg->{autocfgllt}) {
            # check link speed on new nodes
            $diff = $prod->check_link_speed(CPIC::get('systems'),$rhbn);
            unless ($onenode || $diff) {
                # check link speed on original cluster
                $diff = $prod->check_link_speed($cfg->{clustersystems},$clus_conf);
                unless ($diff) {
                    $sysi = ${$cfg->{newnodes}}[0];
                    $sys = Obj::sys($sysi);
                    $diff = 1 if ($sys1->{nics_comm_speed} ne $sys->{nics_comm_speed});
                }
            }
            if ($diff == 1) {
                Msg::n();
                $msg = Msg::new("The private NICs do not have same media speed.\n");
                $msg->warning();
                $msg = Msg::new("It is recommended that the media speed be same for all the private NICs. Without this, LLT may not function properly. Consult your Operating System manual for information on how to set the Media Speed.\n");
                $msg->bold;
            }
            if ($diff == 2) {
                Msg::n();
                $msg = Msg::new("$edr->{script} cannot detect media speed for the selected private NICs properly. Consult your Operating System manual for information on how to set the Media Speed.\n");
                $msg->warning();
            }
            if ($diff) {
                $msg = Msg::new("Do you want to continue with current heartbeat configuration?");
                $ayn = $msg->ayny();
                next if ($ayn ne 'Y');
            }
        }

        my $cid;
        $cid = $clus_conf->{clusterid} if (defined($clus_conf->{clusterid}));
        if ($onenode) {
            Msg::n();
            $cid = $prod->config_clusterid($cid, $rhbn);
            next if (EDR::getmsgkey($cid,'back'));
        }
        $smsg = $prod->display_config_info($clus_conf->{clustername},$cid,$rhbn);
        Msg::n();
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny();
        last if ($ayn eq 'Y');
    }
    $smsg->add_summary(1) if ($smsg && (ref($smsg) =~ m/^Msg/));

    delete($cfg->{autocfgllt});
    $prod->addnode_update_llttab($rhbn,$onenode);
    return 1;
}

sub addnode_update_llttab {
    my ($prod,$rhbn,$onenode) = @_;
    my $cfg = Obj::cfg();
    my $edr = Obj::edr();
    my $cpic = Obj::cpic();
    my ($conf,$n,$sys,$sysi,$localsys);

    $localsys=$prod->localsys;
    if ($cfg->{lltoverudp}) {
        if(!Cfg::opt('responsefile')){
            $prod->set_hb_nics($rhbn,CPIC::get('systems'));
            unless ($onenode) {
                for my $sysi (@{$cfg->{clustersystems}}) {
                    $sys = Obj::sys($sysi);
                    $conf = $prod->get_config_sys($sys);
                    $prod->set_hb_nics_sys($sys,$conf);
                }
            }
        }

        $cfg->{systems} = [];
        push (@{$cfg->{systems}}, @{$cfg->{clustersystems}});
        push(@{$cfg->{systems}}, @{$cfg->{newnodes}});
        $cpic->{systems}=$edr->init_sys_objects();
        $prod->update_llttab();
        for my $sys (@{CPIC::get('systems')}) {
            $sysi = $sys->{sys};
            $localsys->copy_to_sys($sys,"$edr->{tmpdir}/llttab.$sysi",$prod->{llttab});
        }
    } else {
        $prod->set_hb_nics($rhbn,CPIC::get('systems')) unless (Cfg::opt('responsefile'));
        $prod->update_llttab();
        for my $sys (@{CPIC::get('systems')}) {
            $sysi = $sys->{sys};
            $localsys->copy_to_sys($sys,"$edr->{tmpdir}/llttab.$sysi",$prod->{llttab});
        }
    }
    return;
}

sub web_addnode_configure_heartbeat {
    my ($answer,$msg,$n,$onenode,$rtvalue,$sys,$sysi,$unique);
    my $prod = shift;
    my $web = Obj::web();
    my $edr = Obj::edr();
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    my ($done);

    # reset system list in $cfg->{systems}
    $cfg->{systems} = [];
    my $sys1 = Obj::sys(${$cfg->{clustersystems}}[0]);
    my $clus_conf = $prod->get_config_sys($sys1);
    unless ($clus_conf) {
        $msg = Msg::new("The configuration of $sys1->{sys} is not valid, check the cluster.\n");
        $msg->die();
    }
    if ($clus_conf->{onenode}) {
        # without llt/gab, ask for heartbeat confiuration on this node as well
        push (@{$cfg->{systems}}, @{$cfg->{clustersystems}});
        $onenode = 1;
    }
    push(@{$cfg->{systems}}, @{$cfg->{newnodes}});
    $cpic->{systems}=$edr->init_sys_objects();

    while (!$done) {
        if ($onenode) {
            $rtvalue=$web->web_script_form('vcs_select_cluster');
            $unique = $web->{uniqueNicsPerSys};
            if ($web->{numOfHeartbeats}+$web->{numOfLowPriority} == 1) {
                my $alertmsg = Msg::new("You only selected one heartbeat for the cluster, it is strongly recommended to add more than one heartbeat.");
                $web->web_script_form('alert',$alertmsg->{msg});
            }
        }
        if ($cfg->{autocfgllt}) {
            if (!$prod->web_autocfg_hbnics()) {
                $cfg->{autocfgllt} = 0;
                next;
            }
        } else {
            for my $sys (@{CPIC::get('systems')}) {
                my $nics = $sys->padv->systemnics_sys($sys, 1);
                $rtvalue = $web->web_script_form('vcs_select_heartbeats', 'addnode', $nics, $sys);
                last if ($rtvalue eq 'back');
                if ($sys->system1() && ($cpic->nsystems() > 1) && !$unique && !$onenode) {
                    $msg = Msg::new("Are you using the same NICs for private heartbeat links on all systems?");
                    $answer = $msg->ayny();
                    $unique = ($answer eq 'Y') ? 0 : 1;
                    $web->{uniqueNicsPerSys} = $unique;
                }
                last unless $unique;
            }
            next if($rtvalue eq 'back');
            # check link speed on new nodes
            my $diff = $prod->check_link_speed(CPIC::get('systems'),$web->{rhbn});
            unless ($onenode || $diff) {
                # check link speed on original cluster
                $diff = $prod->check_link_speed($cfg->{clustersystems},$clus_conf);
                unless ($diff) {
                    $sysi = ${$cfg->{newnodes}}[0];
                    $sys = Obj::sys($sysi);
                    $diff = 1 if ($sys1->{nics_comm_speed} ne $sys->{nics_comm_speed});
                }
            }
            next if (!$prod->web_check_link_speed($diff));
        }
        $done = 1;
        # delete this hash key so that it do not show in responsefile
        delete $cfg->{autocfgllt};
    }

    $prod->addnode_update_llttab($web->{rhbn},$onenode);
    return 1;
}

sub addnode_configure_cluster {
    my ($addr,$gabtab,$id,$llthosts,$lltsys,$msg,$n,$nic,$nsysi,$firstnode,$sys,$sysi,$system,$cfg,$tmpdir,@used_nids,$localsys);
    my $prod = shift;

    $cfg = Obj::cfg();
    $tmpdir=EDR::tmpdir();
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $n = scalar(@{$cfg->{newnodes}}) + scalar(@{$cfg->{clustersystems}});
    # create gabtab
    $gabtab = "/sbin/gabconfig -c -n$n\n";
    EDRu::writefile($gabtab,"$tmpdir/gabtab");
    # create llthosts
    # new node should append to the llthosts, this will keep the sequence of old nodes
    $n = 0;
    if ($firstnode->exists($prod->{llthosts})) {
        $llthosts = $firstnode->cmd("_cmd_cat $prod->{llthosts}");
        $llthosts.="\n" if ($llthosts);
        @used_nids = split(/\n/, $firstnode->cmd("_cmd_cat $prod->{llthosts} | _cmd_awk '{print \$1}'"));
    } else {
        @used_nids = ();
    }
    for my $sysi (@{$cfg->{clustersystems}}, @{$cfg->{newnodes}}) {
        next if ($llthosts =~ /^\s*\d+\s+$sysi\s*$/mx); # sysi already exist in /etc/llthosts
        $lltsys = transform_system_name($sysi);
        next if ($llthosts =~ /^\s*\d+\s+$lltsys\s*$/mx); # hostname already exist in /etc/llthosts
        while (EDRu::inarr($n, @used_nids)) {
            $n++;
        }
        if ( $n > 63 ) {
            last;
        }
        $llthosts.="$n $lltsys\n";
        $n++;
    }

    $llthosts = join("\n",sort {$a <=> $b} split(/\n/,$llthosts));
    $llthosts.="\n";
    EDRu::writefile($llthosts,"$tmpdir/llthosts");

    $localsys=$prod->localsys;
    for my $sysi (@{$cfg->{clustersystems}}, @{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        # copy updated gabtab to cluster members
        if ($sys->exists($prod->{gabtab})) {
            $sys->cmd("_cmd_mv $prod->{gabtab} $prod->{gabtab}.prev");
        }
        $localsys->copy_to_sys($sys,"$tmpdir/gabtab",$prod->{gabtab});
        # copy updated llthosts to cluster members
        if ($sys->exists($prod->{llthosts})) {
            $sys->cmd("_cmd_mv $prod->{llthosts} $prod->{llthosts}.prev");
        }
        $localsys->copy_to_sys($sys,"$tmpdir/llthosts",$prod->{llthosts});
    }

    if ($cfg->{lltoverudp}) {
        # add llt links to original cluster members
        $id = scalar(@{$cfg->{clustersystems}});
        for my $nsysi (@{$cfg->{newnodes}}) {
            for my $sysi (@{$cfg->{clustersystems}}) {
                $sys = Obj::sys($sysi);
                for my $n (1..$prod->num_hbnics_cfg($cfg)) {
                    if ($cfg->{"vcs_lltlink$n"}{$nsysi}) {
                        $nic = $cfg->{"vcs_lltlink$n"}{$sysi};
                        $addr = $cfg->{"vcs_udplink$n".'_address'}{$nsysi};
                        $sys->cmd("_cmd_lltconfig -a set $id '$nic' $addr");
                    }
                }
                for my $n (1..$prod->num_lopri_hbnics_cfg($cfg)) {
                    $nic = $cfg->{"vcs_lltlinklowpri$n"}{$sysi};
                    $addr = $cfg->{"vcs_udplinklowpri$n".'_address'}{$nsysi};
                    $sys->cmd("_cmd_lltconfig -a set $id '$nic' $addr");
                }
            }
            $id++;
        }
    }

    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        # create /etc/VRTSvcs/conf/sysname on new added nodes
        $system = transform_system_name($sysi);
        EDRu::writefile("$system\n","$tmpdir/sysname.$sysi");
        $localsys->copy_to_sys($sys,"$tmpdir/sysname.$sysi","$prod->{confdir}/sysname");

        # copy uuid from cluster to new node
        if ($prod->check_uuidconfig_pl()) {
            $prod->copy_uuid($firstnode->{sys},$sys->{sys});
        } else {
            $msg = Msg::new("Cannot find uuidconfig.pl for UUID configuration. Manually create UUID before starting VCS");
            $msg->warning();
        }
        # link install: enable vcs
        $cfg->{vcs_allowcomms} = 1;
        $prod->vcs_enable_sys($sys);

        # on AIX, configure DLPI diriver
        $prod->update_pseconf_sys($sys) if $prod->can('update_pseconf_sys');
    }

    $prod->addnode_config_CSSG();

    return 1;
}

sub addnode_start_cluster {
    my ($failures,$firstnode,$had,$msg,$n,$onenode,$pids,$proci,$proc,$sys,$sysi,$system,@syslist,$errmsg);
    my $prod = shift;
    my $edr = Obj::edr();
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    my $web = Obj::web();
    my ($retry, $interval, $gabports);

    my $stage = Msg::new("Stopping $prod->{abbr}");
    $stage->log();

    # stop 'had' on single node cluster
    if (scalar(@{$cfg->{clustersystems}}) == 1) {
        # one node cluster
        $sysi = ${$cfg->{clustersystems}}[0];
        $sys = Obj::sys($sysi);
        $pids = $sys->proc_pids('bin/had -onenode');
        if (@$pids) {
            Msg::title();
            $onenode = 1;
            $web->web_script_form('stopprocess') if (Obj::webui());
            $edr->set_progress_steps(1);
            $had = $sys->proc('had61');
            $msg=Msg::new("Stopping $had->{proc} on $sysi");
            $stage->display_left($msg);
            if ($cpic->proc_stop_sys($sys, $had)) {
                CPIC::proc_stop_passed_sys($sys, $had);
                $stage->display_right();
            } else {
                $errmsg=Msg::new("Failed to stop $had->{proc}on $sysi");
                CPIC::proc_stop_failed_sys($sys, $had);
                $msg->addError($errmsg->{msg});
                $stage->display_right('failed');
            }

            # All: remove ONENODE=yes in vcs init file
            # SunOS: remove manifest for system/vcs-onenode
            $prod->set_onenode_cluster_sys($sys,0);
        }
    }
    if ($onenode) {
        # llt/gab do not start for single node cluster, need to start it
        push(@syslist, @{$cfg->{clustersystems}});
        # enable llt/gab/vxfen for previous onenode cluster
        $prod->vcs_enable_sys($sys);
    }
    Msg::title();
    $stage = Msg::new("Starting services");
    $stage->log();
    # start llt/gab on new added node
    push(@syslist, @{$cfg->{newnodes}});
    $web->web_script_form('startprocess') if (Obj::webui());
    for my $proci (qw(llt61 gab61)) {
        for my $sysi (@syslist) {
            $sys = Obj::sys($sysi);
            $proc = $sys->proc($proci);
            $msg=Msg::new("Starting $proc->{proc} on $sysi");
            if ($cpic->proc_start_sys($sys, $proc)) {
                CPIC::proc_start_passed_sys($sys, $proc);
                $msg->display_status();
            } else {
                CPIC::proc_start_failed_sys($sys, $proc);
                my $errmsg= Msg::new("Failed to start $proc->{proc} on $sysi");
                $msg->addError($errmsg->{msg});
                $msg->display_status('failed');
            }
        }
    }

    $failures=$cpic->failures('startfailmsg');
    if ($#$failures >= 0) {
        Msg::n();
        $msg = Msg::new("LLT and GAB startup did not complete successfully");
        $msg->bold();
        $msg = Msg::new("Check your heartbeat link configurations");
        $msg->die();
    }

    # check Port a in gabconfig -a
    $retry = 20;
    $interval = 6;
    $gabports = '';
    $sysi = $syslist[0];
    $sys = Obj::sys($sysi);
    $msg=Msg::new("Checking GAB control port seed");
    $msg->left();
    while ($retry > 0) {
        $gabports = $sys->cmd("_cmd_gabconfig -a 2>&1");
        if ($gabports =~ /^\s*Port\s+a\s+/mx) {
            Msg::log("Port a is available in gab");
            $msg->right_done();
            last;
        }
        $retry--;
        Msg::log("Port a is not available in gab. Sleep $interval seconds and $retry retries left)");
        sleep $interval;
    }

    if ($gabports !~ /^\s*Port\s+a\s+/mx) {
        $msg->right_failed();
        Msg::n();

        if (Obj::webui()){
            $msg = Msg::new("GAB control port seed is not enabled after GAB is started on all systems. Check your LLT and GAB configurations");
            $msg->die();
        }
        else {
            $msg = Msg::new("GAB control port seed is not enabled after GAB is started on all systems");
            $msg->bold();
            $msg = Msg::new("Check your LLT and GAB configurations");
            $msg->die();
        }
    }

    # restart vxfen/had for single node cluster
    if ($onenode) {
        Msg::n();
        $msg = Msg::new("Restarting cluster $cfg->{vcs_clustername}");
        $msg->bold;
        $sysi = ${$cfg->{clustersystems}}[0];
        $sys = Obj::sys($sysi);
        for my $proci (qw(vxfen61 had61)) {
            # do not start vxfen for VCS/SFHA
            next if (($proci eq 'vxfen61') && ($cpic->{prod} =~ /(VCS|SFHA)/m));
            $proc = $sys->proc($proci);
            $msg=Msg::new("Starting $proc->{proc} on $sysi");
            if ($cpic->proc_start_sys($sys, $proc)) {
                CPIC::proc_start_passed_sys($sys, $proc);
                $msg->display_status();
            } else {
                $errmsg = Msg::new("Failed to start $proc->{proc} on $sysi");
                CPIC::proc_start_failed_sys($sys, $proc);
                $msg->addError($errmsg->{msg});
                $msg->display_status('failed');
            }
        }
    }

    # check vcs status on first node of cluster
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $had = $firstnode->proc('had61');
    unless ($had->check_sys($firstnode, 'poststart')) {
        $msg = Msg::new("Cluster $cfg->{vcs_clustername} must be active before adding a node");
        $firstnode->push_error($msg);
        $msg->die();
    }

    # reset system list in $cfg->{systems}
    $cfg->{systems} = [];
    push(@{$cfg->{systems}}, @{$cfg->{clustersystems}});
    push(@{$cfg->{systems}}, @{$cfg->{newnodes}});
    $cpic->{systems}=$edr->init_sys_objects();

    $prod->haconf_makerw();

    # update main.cf
    for my $sysi (@{$cfg->{newnodes}}) {
        $system = transform_system_name($sysi);
        $firstnode->cmd("$prod->{bindir}/hasys -add $system");
    }
    # configure vxss
    $prod->addnode_configure_vxss();

    $prod->addnode_update_CSSG();

    $prod->haconf_dumpmakero();

    $prod->addnode_configure_fencing();

    # start 'had' on new nodes
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        # reset onenode cluster mode to false on new node to remove a possible previous old config
        $prod->set_onenode_cluster_sys($sys,0);
        $sys->mkdir("$prod->{configdir}");
        $firstnode->copy_to_sys($sys,$prod->{maincf});
        $proc = $sys->proc('amf61');
        $msg=Msg::new("Starting $proc->{proc} on $sysi");
        $errmsg = Msg::new("Failed to start $proc->{proc} on $sysi");
        if ($cpic->proc_start_sys($sys, $proc)) {
            CPIC::proc_start_passed_sys($sys, $proc);
            $msg->display_status();
        } else {
            $msg->addError($errmsg->{msg});
            CPIC::proc_start_failed_sys($sys, $proc);
            $msg->display_status('failed');
        }
        $proc = $sys->proc('had61');
        $msg=Msg::new("Starting $proc->{proc} on $sysi");
        $errmsg = Msg::new("Failed to start $proc->{proc} on $sysi");
        if ($cpic->proc_start_sys($sys, $proc)) {
            CPIC::proc_start_passed_sys($sys, $proc);
            $msg->display_status();
        } else {
            $msg->addError($errmsg->{msg});
            CPIC::proc_start_failed_sys($sys, $proc);
            $msg->display_status('failed');
        }
    }
    $prod->poststart_errors($cpic) if ($cpic->sys_error);
    EDR::reset_errors_warnings();
    return 1;
}

sub addnode_configure_vxss {
    my ($mode,$firstnode);
    my $prod = shift;
    my $cfg = Obj::cfg();

    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $mode = $firstnode->cmd("$prod->{bindir}/haclus -value SecureClus");
    # no secure cluster
    if ($mode ne '1') {
        $prod->eat_update_CmdServer_secure_file($cfg->{newnodes});
        return 0;
    }

    $prod->set_value('fips',1) if($prod->is_fips_cluster($firstnode));
    my $msg=Msg::new("Configuring security for new nodes");
    $msg->left;

    $prod->{eat_enable} = 1;
    $prod->eat_addnode();
    $prod->eat_update_CmdServer_secure_file($cfg->{newnodes});

    $msg=Msg::new("Done");
    $msg->right;
    return 1;
}

sub addnode_configure_fencing {
    my($firstnode,$msg,$sys,$sysi,$proc,$proci,$vxfenmode);
    my($ret,$cps_aref,$ports_href,$conf,$uuid,$errmsg,$max_pri,$lltconf,$nodeid);
    my ($vxfen_mechanism,$vxfendg,$service_enabled,$vxfen,$vxfensg_name);
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    my $vxfen_pkg = $prod->pkg('VRTSvxfen61');

    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $service_enabled = 1;
    $vxfen = $firstnode->proc('vxfen61');
    if ($vxfen->check_service_sys($firstnode)==0) {
        $service_enabled = 0;
    }
    if ($firstnode->exists($prod->{vxfenmode})) {
        $conf = $firstnode->cmd("_cmd_cat $prod->{vxfenmode} 2>/dev/null");
        if ($conf =~ /vxfen_mode\s*=\s*(\w*)/mx) {
            $vxfenmode = $1;
            Msg::log("Fencing works in $vxfenmode mode for cluster $cfg->{vcs_clustername}");
            $vxfenmode = 'scsi3' if($vxfenmode=~/sybase/);
        } else {
            $msg = Msg::new("Could not get vxfen mode from first node, $firstnode->{sys}, of the cluster, $cfg->{vcs_clustername}. Fencing will not be started on the newly added node");
            $msg->print();
            $msg->addNote($msg->{msg});
            return;
        }
    } else {
        # only vxfendg, vxfenmode=scsi3
        if ($firstnode->exists($prod->{vxfendg})) {
            $vxfenmode = 'scsi3';
        } else {
            # no vxfenmode and vxfendg, do not start vxfen
            return;
        }
    }

    $vxfen_mechanism = '';
    $vxfendg = '';
    if ($vxfenmode eq 'customized') {
        if ($conf =~ /vxfen_mechanism\s*=\s*cps\s*/mx) {
            $vxfen_mechanism = 'cps';
            Msg::log("Fencing works in $vxfenmode mode with vxfen_mechanism=$vxfen_mechanism");
            ($ret, $cps_aref, $ports_href) = $vxfen_pkg->addnode_get_cp_client_conf($firstnode);
            if ($ret) {
                $vxfenmode = 'disabled';
                $msg = Msg::new("Failed to read Coordination Point Client configuration from $prod->{vxfenmode} on first node, $firstnode->{sys}, of cluster, $cfg->{vcs_clustername}. Fencing will be started in disabled mode on the newly added node.");
                $msg->print();
                $msg->addNote($msg->{msg});
            } else {
                my $cnt = 1;
                my %ports = %$ports_href;
                Msg::log('Existing Coordination Point client side configuration');
                for my $sys (@$cps_aref) {
                    Msg::log("cp$cnt=$sys->{sys}:$ports{$sys->{sys}}");
                    $cnt++;
                }
                $uuid = $prod->addnode_get_cluster_uuid();
                if ($uuid == -1) {
                    $vxfenmode = 'disabled';
                    $msg = Msg::new("Failed to get the UUID for the cluster, $cfg->{vcs_clustername}. Coordination Point client configuration cannot be completed without UUID. Fencing will be started in disabled mode on the newly added node.");
                    $msg->print;
                    $msg->addNote($msg->{msg});

                } else {
                    Msg::log("Cluster uuid=$uuid");
                }
            }
            if ($conf =~ /vxfendg\s*=\s*(\S+)/mx) {
                $vxfendg = $1;
                Msg::log("Fencing works in $vxfenmode mode with vxfendg=$vxfendg");
            }
        } else {
            $msg = Msg::new("Fencing works in customized mode for cluster, $cfg->{vcs_clustername}. Configure fencing manually after add node procedure completes.");
            $msg->print;
            $msg->addNote($msg->{msg});
            return;
        }
    }

    # VCS is non-secure but CPS is secure
    # Import CPS credentials for newly added node
    # $prod->eat_addnode() if (!$prod->{eat_enable});
    (undef,$vxfensg_name) = $vxfen_pkg->get_cpagent_attribute_value('Group');
    $max_pri = $prod->get_sg_max_priority($vxfensg_name);
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        if ($vxfenmode eq 'scsi3' || (($vxfenmode eq 'customized') && ($vxfen_mechanism eq 'cps'))) {
            $max_pri++;
            if ($vxfenmode ne 'scsi3') {
                $lltconf = $prod->get_llt_config_sys($sys);
                $nodeid = $lltconf->{hostsid}{$sys->{vcs_sysname}};
                $ret = $vxfen_pkg->addnode_configure_cpc_sys($sys, $cfg->{vcs_clustername}, $nodeid,
                                                                 $uuid, $cps_aref, $ports_href);
                if ($ret) {
                    $msg = Msg::new("Failed to add Coordination Point client $sysi to one or more Coordination Point Server(s). Manually configure fencing on $sysi after addnode procedure completes.");
                    $msg->warning();
                    $msg->addWarning($msg->{msg});
                    next;
                }
                # copy related config files if non_scsi3 fencing
                $vxfen_pkg->addnode_configure_nonscsi3_sys($sys, $firstnode);
            }
            # configure cp agent on new nodes
            $ret = $vxfen_pkg->addnode_configure_cp_agent($firstnode, $sys, $max_pri);
            if ($ret) {
                $msg = Msg::new("Failed to add new node $sysi into SystemList of the VCS group containing CoordPoint type resource. Manually add the node into SystemList after add node procedure completes.");
                $msg->warning();
                $msg->addWarning($msg->{msg});
            }

            # copy vxfenmode and vxfendg from cluster to new node
            if ($vxfenmode eq 'scsi3') {
                $firstnode->copy_to_sys($sys,$prod->{vxfendg});
            }
            $firstnode->copy_to_sys($sys,$prod->{vxfenmode}) if ($firstnode->exists($prod->{vxfenmode}));
            if (($vxfenmode eq 'scsi3') || ($vxfendg ne '')) {
                # check VM running state on new node
                my $vm = $prod->prod('VM61');
                if ($vm->vold_status_sys($sys) ne 'enabled') {
                    Msg::log("Starting VM before starting fencing on $sysi");
                    my $startprocs = $vm->startprocs_sys($sys);
                    for my $proci (@$startprocs) {
                        $proc = $sys->proc($proci);
                        $msg=Msg::new("Starting $proc->{proc} on $sysi");
#                        $msg->left();
                        if ($cpic->proc_start_sys($sys, $proc)) {
                             CPIC::proc_start_passed_sys($sys, $proc);
                             $msg->display_status();
#                             Msg::right_done();
                        } else {
                            $errmsg=Msg::new("Failed to start $proc->{proc} on $sysi");
                            $msg->addError($errmsg->{msg});
                             CPIC::proc_start_failed_sys($sys, $proc);
#                             Msg::right_failed();
                            $msg->display_status('failed');
                        }
                    }
                }
                if ($vm->vold_status_sys($sys) ne 'enabled') {
                    $msg = Msg::new("Failed to start VM processes. Manually configure fencing on $sysi after addnode procedure completes.");
                    $msg->warning();
                    $msg->addWarning($msg->{msg});
                }
            }
        } elsif ($vxfenmode eq 'disabled') {
                $sys->cmd("_cmd_cp /etc/vxfen.d/vxfenmode_disabled $prod->{vxfenmode}");
        }
        $proc = $sys->proc('vxfen61');
        $proc->enable_sys($sys);
        if (!$service_enabled) {
            # vxfen svc is disabled on existing cluster nodes.
            # it should be disabled on newly added nodes too.
            if ($vxfen->can('disable_service_sys')) {
                $vxfen->disable_service_sys($sys);
            }
            next;
        }
        $msg=Msg::new("Starting $proc->{proc} on $sysi");
#        $msg->left();
        if ($cpic->proc_start_sys($sys, $proc)) {
            CPIC::proc_start_passed_sys($sys, $proc);
#            Msg::right_done();
            $msg->display_status();
        } else {
            $errmsg = Msg::new("Failed to start $proc->{proc} on $sysi");
            $msg->addError($errmsg->{msg});
            CPIC::proc_start_failed_sys($sys, $proc);
#            Msg::right_failed();
            $msg->display_status('failed');
        }
    }
    return;
}

sub addnode_get_cluster_uuid {
    my $prod = shift;
    my ($uuid_hash, $nuuid, @uuids, $uuid, $msg);

    if (!$prod->check_uuidconfig_pl()) {
        return -1;
    }

    $uuid_hash = $prod->get_uuid();
    $nuuid = keys %{$uuid_hash};
    if ($nuuid != 1) {
         return -1;
    }

    @uuids = keys %{$uuid_hash};
    $uuid = shift @uuids;

    return $uuid;
}

sub get_publicnic_sys {
    my ($prod,$sys) = @_;
    my ($msg,$nicl,$rpn,$en,$def);
    my $sysi = $sys->{sys};
    while(1){
        $rpn=$sys->padv->publicnics_sys($sys);
        $rpn=EDRu::arruniq(@$rpn);
        if ($#$rpn<0) {
            $msg = Msg::new("No active NIC devices have been discovered on $sysi");
            $msg->warning;
        } else {
            $nicl=join(' ',@$rpn);
            $msg = Msg::new("Active NIC devices discovered on $sysi: $nicl");
            $msg->print;
        }
        $def = $$rpn[0];
        $msg = Msg::new("Enter the NIC for the $prod->{abbr} to use on $sysi:");
        $en=$msg->ask($def);
        if (!$sys->is_nic($en)) {
            $msg = Msg::new("$en is not a valid NIC name");
            $msg->print;
        }else{
            return $en;
        }
    }
    return;
}

sub addnode_config_CSSG {
    return '' if (Cfg::opt('responsefile'));
    my ($all,$ask_gconic,$ask_csgnic,$ayn,$csgnic,$firstnode,$gco,$gcoip,$gconic,$msg,$n,$rtn,$smtp,$snmp,$sys,$sysi,$system,$vip);
    my $prod = shift;
    my $cfg = Obj::cfg();

    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $rtn = $firstnode->cmd("$prod->{bindir}/hagrp -list 2>/dev/null |_cmd_grep ClusterService");
    return 1 if ($rtn eq '');

    $rtn = $firstnode->cmd("$prod->{bindir}/haclus -value AutoAddSystemToCSG 2>/dev/null");
    return 1 if ($rtn eq '0');

    # smtp
    $rtn = $firstnode->cmd("$prod->{bindir}/hares -display ntfr -attribute SmtpServer 2>/dev/null |_cmd_grep -v Resource | _cmd_awk '{print \$4}'");
    if($rtn ne ''){
        $msg = Msg::new("SMTP notification is configured in the cluster $cfg->{vcs_clustername}");
        $msg->print;
        $smtp = 1;
        $ask_csgnic = 1;
    }
    # snmp
    $rtn = $firstnode->cmd("$prod->{bindir}/hares -display ntfr -attribute SnmpConsoles 2>/dev/null |_cmd_grep -v Resource | _cmd_awk '{print \$4}'");
    if($rtn ne ''){
        $msg = Msg::new("SNMP notification is configured in the cluster $cfg->{vcs_clustername}");
        $msg->print;
        $snmp = 1;
        $ask_csgnic = 1;
    }
    # webip
    $rtn = $firstnode->cmd("$prod->{bindir}/hares -list 2>/dev/null |_cmd_grep webip");
    if($rtn ne ''){
        $msg = Msg::new("Cluster Virtual IP is configured on the cluster $cfg->{vcs_clustername}");
        $msg->print();
        $vip = 1;
        $ask_csgnic = 1;
    }
    # gco
    $rtn = $firstnode->cmd("$prod->{bindir}/hares -list 2>/dev/null |_cmd_grep wac");
    if($rtn ne ''){
        $msg = Msg::new("Global Cluster Option is configured on the cluster $cfg->{vcs_clustername}.");
        $msg->print();
        $gcoip = $firstnode->cmd("$prod->{bindir}/hares -dep wac 2>/dev/null |_cmd_grep -v Group |_cmd_awk '{print \$3}'");
        if($gcoip ne 'webip') {
            $gco = 1;
            $gconic = $firstnode->cmd("$prod->{bindir}/hares -dep $gcoip  |_cmd_grep -v Group |_cmd_awk '{print \$3}'|_cmd_grep -v $gcoip");
            if ($gconic eq 'gconic') {
                $ask_gconic = 1;
            } else {
                $ask_csgnic = 1;
            }
            $gconic = '';
        }
    }

    $n = scalar(@{$cfg->{newnodes}});

    $all = 0;
    if ($ask_csgnic) {
        Msg::n();
        $msg = Msg::new("A public NIC device is required by following services on each of the newly added nodes:");
        $msg->bold();
        if($smtp) {
            $msg = Msg::new("SMTP notification");
            $msg->print();
        }
        if($snmp) {
            $msg = Msg::new("SNMP notification");
            $msg->print();
        }
        if($vip) {
            $msg = Msg::new("Cluster Virtual IP");
            $msg->print();
        }
        if($gco && !$ask_gconic) {
            $msg = Msg::new("Global Cluster Option");
            $msg->print();
        }
        for my $sysi (@{$cfg->{newnodes}}) {
            $sys = Obj::sys($sysi);
            if ($all) {
                $cfg->{vcs_csgnic}{$sysi} = $csgnic;
                next;
            }
            $csgnic = $prod->get_publicnic_sys($sys);

            if (($n>1) && ($sysi eq ${$cfg->{newnodes}}[0])) {
                $msg = Msg::new("Is $csgnic the public NIC used by other new nodes?");
                $ayn = $msg->ayny();
                $all = 1 if ($ayn eq 'Y');
            }
            $cfg->{vcs_csgnic}{$sysi} = $csgnic;
        }
    }

    $all = 0;
    if ($ask_gconic) {
        Msg::n();
        $msg = Msg::new("A public NIC device is required by Global Cluster Option on each of the newly added nodes:");
        $msg->bold();
        for my $sysi (@{$cfg->{newnodes}}) {
            $sys = Obj::sys($sysi);
            if ($all) {
                $cfg->{vcs_gconic}{$sysi} = $gconic;
                next;
            }
            $gconic = $prod->get_publicnic_sys($sys);
            if (($n>1) && ($sysi eq ${$cfg->{newnodes}}[0])) {
                $msg = Msg::new("Is $gconic the public NIC used by other new nodes?");
                $ayn = $msg->ayny();
                $all = 1 if ($ayn eq 'Y');
            }
            $cfg->{vcs_gconic}{$sysi} = $gconic;
        }
    }
    return;
}

sub addnode_update_CSSG {
    my ($csgnic,$firstnode,$gconic,$global_csgnic,$global_gconic,$msg,$rtn,$sysi,$system,$max_pri);
    my $prod = shift;
    my $cfg = Obj::cfg();

    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $rtn = $firstnode->cmd("$prod->{bindir}/hagrp -list 2>/dev/null |_cmd_grep ClusterService");
    return 1 if ($rtn eq '');

    $rtn = $firstnode->cmd("$prod->{bindir}/haclus -value AutoAddSystemToCSG 2>/dev/null");
    return 1 if ($rtn eq '0');

    # update SystemList AutoStartList
    $max_pri = $prod->get_sg_max_priority('ClusterService');
    for my $sysi (@{$cfg->{newnodes}}) {
        $max_pri++;
        $system = transform_system_name($sysi);
        $firstnode->cmd("$prod->{bindir}/hagrp -modify ClusterService SystemList -add $system $max_pri");
        $firstnode->cmd("$prod->{bindir}/hagrp -modify ClusterService AutoStartList -add $system");
    }
    # update csgnic resource
    $global_csgnic = 0;
    if (defined($cfg->{vcs_csgnic})) {
        $msg = Msg::new("Updating csgnic resource");
        $msg->left();
        if (EDRu::hashvaleq($cfg->{vcs_csgnic})) {
            $sysi = ${$cfg->{newnodes}}[0];
            $csgnic = $cfg->{vcs_csgnic}{$sysi};
            $rtn = $firstnode->cmd("$prod->{bindir}/hares -display csgnic -attribute Device |_cmd_grep $csgnic | _cmd_awk '{print \$3}'");
            $global_csgnic = 1 if ($rtn eq 'global');
        }
        if (!$global_csgnic) {
            $rtn = $firstnode->cmd("$prod->{bindir}/hares -local csgnic Device");
            for my $sysi (@{$cfg->{newnodes}}) {
                $system = transform_system_name($sysi);
                $csgnic = $cfg->{vcs_csgnic}{$sysi};
                $rtn = $firstnode->cmd("$prod->{bindir}/hares -modify csgnic Device $csgnic -sys $system");
            }
        }
        Msg::right_done();
    }

    # update webip resource
    $rtn = $firstnode->cmd("$prod->{bindir}/hares -list 2>/dev/null |_cmd_grep webip");
    if ($rtn ne '') {
        $msg = Msg::new("Updating webip resource");
        $msg->left();
        if (!$global_csgnic) {
            $rtn = $firstnode->cmd("$prod->{bindir}/hares -local webip Device");
            for my $sysi (@{$cfg->{newnodes}}) {
                $system = transform_system_name($sysi);
                $csgnic = $cfg->{vcs_csgnic}{$sysi};
                $rtn = $firstnode->cmd("$prod->{bindir}/hares -modify webip Device $csgnic -sys $system");
            }
        }
        Msg::right_done();
    }

    # update gconic resource
    $global_gconic = 0;
    if (defined($cfg->{vcs_gconic})) {
        $msg = Msg::new("Updating gconic resources");
        $msg->left();
        if (EDRu::hashvaleq($cfg->{vcs_gconic})) {
            $sysi = ${$cfg->{newnodes}}[0];
            $gconic = $cfg->{vcs_gconic}{$sysi};
            $rtn = $firstnode->cmd("$prod->{bindir}/hares -display gconic -attribute Device |_cmd_grep $gconic | _cmd_awk '{print \$3}'");
            $global_gconic = 1 if ($rtn eq 'global');
        }
        if (!$global_gconic) {
            $rtn = $firstnode->cmd("$prod->{bindir}/hares -local gconic Device");
            for my $sysi (@{$cfg->{newnodes}}) {
                $system = transform_system_name($sysi);
                $gconic = $cfg->{vcs_gconic}{$sysi};
                $rtn = $firstnode->cmd("$prod->{bindir}/hares -modify gconic Device $gconic -sys $system");
            }
        }
        Msg::right_done();
    }

    # update gcoip resource
    $rtn = $firstnode->cmd("$prod->{bindir}/hares -list 2>/dev/null |_cmd_grep gcoip");
    if ($rtn ne '') {
        $msg = Msg::new("Updating gcoip resource");
        $msg->left();
        if (defined($cfg->{vcs_gconic})) {
            if (!$global_gconic) {
                $rtn = $firstnode->cmd("$prod->{bindir}/hares -local gcoip Device");
                for my $sysi (@{$cfg->{newnodes}}) {
                    $system = transform_system_name($sysi);
                    $gconic = $cfg->{vcs_gconic}{$sysi};
                    $rtn = $firstnode->cmd("$prod->{bindir}/hares -modify gcoip Device $gconic -sys $system");
                }
            }
        }elsif (defined($cfg->{vcs_csgnic})) {
            if (!$global_csgnic) {
                $rtn = $firstnode->cmd("$prod->{bindir}/hares -local gcoip Device");
                for my $sysi (@{$cfg->{newnodes}}) {
                    $system = transform_system_name($sysi);
                    $gconic = $cfg->{vcs_csgnic}{$sysi};
                    $rtn = $firstnode->cmd("$prod->{bindir}/hares -modify gcoip Device $gconic -sys $system");
                }
            }
        }
        Msg::right_done();
    }
    return;
}

sub addnode_poststart {
    return 1;
}

sub addnode_completion {
    my ($errors,$msg);
    my ($vcs);
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $web = Obj::web();

    Msg::n();
    $errors = $cpic->failures('stopfailmsg', 'startfailmsg', 'errors');
    if ($#$errors < 0) {
        $msg = Msg::new("Addnode completed successfully");
        $msg->add_summary(1);
    } else {
        $prod->addnode_handle_errors($cpic);
        $web->{complete_failed} = 1;
        $msg = Msg::new("Addnode did not complete successfully");
        $msg->add_summary(1);
    }
    $msg->bold();
    Msg::n();
    $vcs = $prod->prod('VCS61');
    $vcs->completion_messages();
    $cpic->edr_completion();
    return '';
}

sub addnode_handle_errors {
    my ($prod,$cpic) = @_;
    my ($msg,$errmsg,$warnings,$errors);
    # count errors and warnings
    for my $sys (@{$cpic->{systems}}) {
        $errors+=scalar(@{$sys->{errors}}) if ($sys->{errors});
        $warnings+=scalar(@{$sys->{warnings}}) if ($sys->{warnings});
    }

    # print errors and warnings
    if ($errors) {
        $msg=Msg::new("The following errors were discovered on the systems:");
        $msg->print;
        $msg->add_summary(1);
        $msg->addError($msg->{msg});

        for my $sys (@{$cpic->{systems}}) {
            for my $errmsg ((@{$sys->{errors}})) {
                Msg::print($errmsg);
                Msg::add_summary($errmsg);
                $msg->addError($errmsg);
            }
        }
        Msg::n();
    }

    if ($warnings) {
        $msg=Msg::new("The following warnings were discovered on the systems:");
        $msg->print;
        $msg->add_summary(1);
        $msg->addWarning($msg->{msg});

        for my $sys (@{$cpic->{systems}}) {
            for my $errmsg ((@{$sys->{warnings}})) {
                Msg::print($errmsg);
                Msg::add_summary($errmsg);
                $msg->addWarning($errmsg);
            }
        }
        Msg::n();
    }

    return '';

}

sub num_hbnics{
    my ($prod,$nics) = @_;
    my ($nr_hbnics);
    $nr_hbnics=1;
    while (defined($nics->{"lltlink$nr_hbnics"})) {
        $nr_hbnics++;
    }
    $nr_hbnics--;
    return $nr_hbnics;
}

sub num_lopri_hbnics{
    my ($prod,$nics) = @_;
    my ($nr_lowpri_hbnics);
    $nr_lowpri_hbnics=1;
    while (defined($nics->{"lltlinklowpri$nr_lowpri_hbnics"})) {
        $nr_lowpri_hbnics++;
    }
    $nr_lowpri_hbnics--;
    return $nr_lowpri_hbnics;
}

sub num_hbnics_cfg{
    my ($prod,$cfg) = @_;
    my ($nr_hbnics);
    $nr_hbnics=1;
    while (defined($cfg->{"vcs_lltlink$nr_hbnics"})) {
        $nr_hbnics++;
    }
    $nr_hbnics--;
    return $nr_hbnics;
}

sub num_lopri_hbnics_cfg{
    my ($prod,$cfg) = @_;
    my ($nr_lowpri_hbnics);
    $nr_lowpri_hbnics=1;
    while (defined($cfg->{"vcs_lltlinklowpri$nr_lowpri_hbnics"})) {
        $nr_lowpri_hbnics++;
    }
    $nr_lowpri_hbnics--;
    return $nr_lowpri_hbnics;
}

sub set_lowpri_for_slow_links{
    my ($prod,$rhbn) = @_;
    my ($sysi,$new_key,$new_key_udp_addr,$cfg,%linkspeeds,$new_rhbn_lowpri_link_idx,$new_key_udp_port,$sys,@links_to_lowpri,@sorted_links,$nic,$key,$least_hipri_links,$link,$new_rhbn,$cpic,$key_low,$new_rhbn_link_idx,$key_udp_addr,$new_key_udp_mask,$key_udp_port,$key_udp_mask);

    $cpic = Obj::cpic();
    $cfg = Obj::cfg();
    $least_hipri_links = 1;
    if ( $cpic->{prod} =~ /SFRAC/m || $cpic->{prod} =~ /(SVS|SFCFS)/mx) {
        $least_hipri_links = 2;
    }

    if ( $least_hipri_links >= $prod->num_hbnics($rhbn)) {
        return $rhbn;
    }

    %linkspeeds = ();
    for my $link (1..$prod->num_hbnics($rhbn)) {
        $key = "lltlink$link";
        $key_low = "lltlink$link".'_low';
        if ( defined ($rhbn->{$key_low})) {
            $linkspeeds{$key} = $rhbn->{$key_low};
        } else {
            $linkspeeds{$key} = 0;
        }
    }
    @sorted_links = sort {$linkspeeds{$b} <=> $linkspeeds{$a}} keys(%linkspeeds); # sort numerically descending

    for my $link ($least_hipri_links..$#sorted_links) {
        if ($linkspeeds{$sorted_links[$link]} < $linkspeeds{$sorted_links[$least_hipri_links - 1]}) {
            push @links_to_lowpri, $sorted_links[$link];
        }
    }

    # lltlink#_high/lltlink#_low is not needed since we have set slower links as low pri links.
    $new_rhbn_link_idx = 1;
    $new_rhbn_lowpri_link_idx = 1;
    for my $link (1..$prod->num_hbnics($rhbn)) {
        $key = "lltlink$link";
        if ( grep {$key eq $_} @links_to_lowpri ) {
            # low-pri
            $new_key = "lltlinklowpri$new_rhbn_lowpri_link_idx";
            for my $sys (@{CPIC::get('systems')}) {
                $sysi = $sys->{sys};
                $new_rhbn->{$new_key}{$sysi} = $rhbn->{$key}{$sysi};
                if ($cfg->{lltoverudp}) {
                    $key_udp_addr = "udplink$link".'_address';
                    $key_udp_mask = "udplink$link".'_netmask';
                    $key_udp_port = "udplink$link".'_port';
                    $new_key_udp_addr = "udplinklowpri$new_rhbn_lowpri_link_idx".'_address';
                    $new_key_udp_mask = "udplinklowpri$new_rhbn_lowpri_link_idx".'_netmask';
                    $new_key_udp_port = "udplinklowpri$new_rhbn_lowpri_link_idx".'_port';
                    $new_rhbn->{$new_key_udp_addr}{$sysi} = $rhbn->{$key_udp_addr}{$sysi};
                    $new_rhbn->{$new_key_udp_mask}{$sysi} = $rhbn->{$key_udp_mask}{$sysi};
                    $new_rhbn->{$new_key_udp_port}{$sysi} = $rhbn->{$key_udp_port}{$sysi};
                }
            }
            $new_rhbn_lowpri_link_idx ++;
        } else {
            # hi-pri
            $new_key = "lltlink$new_rhbn_link_idx";
            for my $sys (@{CPIC::get('systems')}) {
                $sysi = $sys->{sys};
                $new_rhbn->{$new_key}{$sysi} = $rhbn->{$key}{$sysi};
                if ($cfg->{lltoverudp}) {
                    $key_udp_addr = "udplink$link".'_address';
                    $key_udp_mask = "udplink$link".'_netmask';
                    $key_udp_port = "udplink$link".'_port';
                    $new_key_udp_addr = "udplink$new_rhbn_link_idx".'_address';
                    $new_key_udp_mask = "udplink$new_rhbn_link_idx".'_netmask';
                    $new_key_udp_port = "udplink$new_rhbn_link_idx".'_port';
                    $new_rhbn->{$new_key_udp_addr}{$sysi} = $rhbn->{$key_udp_addr}{$sysi};
                    $new_rhbn->{$new_key_udp_mask}{$sysi} = $rhbn->{$key_udp_mask}{$sysi};
                    $new_rhbn->{$new_key_udp_port}{$sysi} = $rhbn->{$key_udp_port}{$sysi};
                }
            }
            $new_rhbn_link_idx ++;
        }
    }
    # low-pri links specified by user.
    for my $link (1..$prod->num_lopri_hbnics($rhbn)) {
        $key = "lltlinklowpri$link";
        $new_key = "lltlinklowpri$new_rhbn_lowpri_link_idx";
        for my $sys (@{CPIC::get('systems')}) {
            $sysi = $sys->{sys};
            $new_rhbn->{$new_key}{$sysi} = $rhbn->{$key}{$sysi};
            if ($cfg->{lltoverudp}) {
                $key_udp_addr = "udplinklowpri$link".'_address';
                $key_udp_mask = "udplinklowpri$link".'_netmask';
                $key_udp_port = "udplinklowpri$link".'_port';
                $new_key_udp_addr = "udplinklowpri$new_rhbn_lowpri_link_idx".'_address';
                $new_key_udp_mask = "udplinklowpri$new_rhbn_lowpri_link_idx".'_netmask';
                $new_key_udp_port = "udplinklowpri$new_rhbn_lowpri_link_idx".'_port';
                $new_rhbn->{$new_key_udp_addr}{$sysi} = $rhbn->{$key_udp_addr}{$sysi};
                $new_rhbn->{$new_key_udp_mask}{$sysi} = $rhbn->{$key_udp_mask}{$sysi};
                $new_rhbn->{$new_key_udp_port}{$sysi} = $rhbn->{$key_udp_port}{$sysi};
            }
        }
        $new_rhbn_lowpri_link_idx ++;
    }
    return $new_rhbn;
}

sub config_clusterid {
    my ($prod,$cid,$rhbn)=@_;
    my ($clusterid,$defaultid,$msg,$ayn,$ret);
    while (1) {
        $defaultid=($cid && ($cid =~ /\d+/) && !$ret) ? $cid : int(rand(65535));
        $clusterid=$prod->ask_clusterid($defaultid);
        return $clusterid if (EDR::getmsgkey($clusterid,'back'));
        $msg=Msg::new("\nThe cluster cannot be configured if the cluster ID $clusterid is in use by another cluster. Installer can perform a check to determine if the cluster ID is duplicate. The check will take less than a minute to complete.");
        $msg->printn;
        $msg=Msg::new("Would you like to check if the cluster ID is in use by another cluster?");
        $ayn=$msg->ayny;
        Msg::n();
        if($ayn eq 'Y'){
            $msg=Msg::new("Checking cluster ID");
            $msg->left;
            $ret=$prod->check_clusterid($clusterid,$rhbn);
            $msg->right_done();
            Msg::n();
            if($ret==1){
                $msg=Msg::new("The cluster ID $clusterid is already in use. Configure the cluster ID again.");
                $msg->print;
                next;
            }elsif($ret == -1){
                $msg=Msg::new("Failed to check if the cluster ID is in use. It is recommended to make sure that the cluster ID is not in use by another cluster.");
                $msg->bold;
                $msg->prtc();
            } else {
                $msg=Msg::new("Duplicated cluster ID detection passed. The cluster ID $clusterid can be used for the cluster.");
                $msg->bold;
                $msg->prtc();
            }
        }
        last;
    }
    return $clusterid;
}

sub check_clusterid {
    my ($prod,$clusterid,$rhbn)=@_;
    my ($out,$sys,$sysi,$tmpdir,$localsys);
    $tmpdir=EDR::tmpdir();
    $sys=@{CPIC::get('systems')}[0];
    $sysi=$sys->{sys};
    $prod->set_hb_nics($rhbn,CPIC::get('systems'));
    $prod->update_llttab(1);
    $prod->update_llthosts;
    $localsys=$prod->localsys;
    $localsys->copy_to_sys($sys,"$tmpdir/llttab.$sysi",$prod->{llttab});
    $localsys->copy_to_sys($sys,"$tmpdir/llthosts",$prod->{llthosts});
    # on AIX, update /etc/pse.conf file
    $prod->update_pseconf_sys($sys) if $prod->can('update_pseconf_sys');

    $out=$sys->cmd("_cmd_lltconfig -N 2>&1");
    #line=cidfound =   2415, vermaj = 3, vermin = 7;
    #line=ClusterID =  12541,  LLTProtocolVersion = 5.0
    return -1 if(EDR::cmdexit() !=0 || $out=~/ERROR/);
    foreach my $line(split /\n/, $out){
        if($line=~/cidfound/){
            return 1 if($line=~/cidfound\s+=\s+$clusterid,/);
        } else {
            return 1 if($line=~/ClusterID\s+=\s+$clusterid,/);
        }
    }
    return 0;
}

sub handle_precheck_issues {
    my ($prod,$systems)=@_;
    if ($prod->{time_async}){
        my $edr = Obj::edr();
        $edr->ask_timesync($systems);
    }
    return;
}

sub check_prod_enabled_sys{
    my ($prod,$sys)=@_;
    my ($had);
    $had = $sys->proc('had61');
    if ($had) {
        return $had->is_enabled_sys($sys);
    }
    return 0;
}

sub set_initconf_variable_sys {
    my ($prod,$sys,$procname,$var,$value) = @_;
    my ($rootpath, $initconf, $conf);

    return 0 if (!$procname || !$prod->{initfile}{$procname} || !$var || !defined($value));

    $conf = '';
    $rootpath = Cfg::opt('rootpath');
    $initconf = $rootpath.$prod->{initfile}{$procname};

    if ($sys->exists($initconf)) {
        $conf = $sys->cmd("_cmd_cat $initconf 2>/dev/null");
    }

    if ( $conf =~ /^\s*$var\s*=/mx) {
        $conf =~ s/^(\s*$var\s*=\s*).*/$1$value/mxg;
    } else {
        $conf .= "\n$var=$value";
    }
    $conf .= "\n";
    $sys->writefile($conf,$initconf);
    return 1;
}

sub set_vcs_onenode_sys {
    my ($prod,$sys,$onenode,$enable_lgf) = @_;
    my $rootpath = Cfg::opt('rootpath');
    my $initconf = $rootpath . $prod->{initfile}{vcs};
    my $conf = '';
    my $oldonenode = '';
    if ($sys->exists($initconf)) {
        $conf = $sys->cmd("_cmd_cat $initconf 2>/dev/null");
        $oldonenode = $sys->cmd("unset ONENODE; . $initconf >/dev/null 2>/dev/null ; echo \$ONENODE");
    }

    # PM requested to not stop LGF during CPS onenode licensing
    if($onenode && !$enable_lgf){
        for my $proci (qw(vxfen61 gab61 llt61)) {
            my $proc = $sys->proc($proci);
            $proc->disable_sys($sys);
        }
    }
    # skip update vcs init file if expected ONENODE value is already set in it.
    if (($onenode && $oldonenode eq 'yes') || (!$onenode && $oldonenode eq 'no')) {
        return 1;
    }

    # change or append ONENODE= in vcs init file
    if ( $conf =~ /^\s*ONENODE=.*$/mx) {
        if ($onenode) {
            $conf =~ s/^\s*ONENODE=.*/ONENODE=yes/mxg;
        } else {
            $conf =~ s/^\s*ONENODE=.*/ONENODE=no/mxg;
        }
    } else {
        if ($onenode) {
            $conf .= "\nONENODE=yes";
        }else {
            $conf .= "\nONENODE=no";
        }
    }
    $conf .= "\n";
    $sys->writefile($conf,$initconf);
    return 1;
}

sub set_onenode_cluster_sys {
    my($prod,$sys,$onenode,$enable_lgf) = @_;
    return $prod->set_vcs_onenode_sys($sys,$onenode,$enable_lgf);
}

sub singlenode_vcs_licensed_sys {
    my ($prod,$sys) = (@_);
    my (@rv,$feature,$fv,$pname,$prodname,$rel);
    $rel = Obj::rel();
    $prodname = $prod->{abbr};
    $feature = 'Coordination Point Server';
    $rel->read_licenses_sys($sys);
    for my $lk (keys(%{$sys->{keys}})) {
        $pname = $sys->{keys}{$lk}{'Product Name'};
        $pname =~ s/^VERITAS //mg;
        for my $lname (@{$prod->{lic_names}}) {
            $lname =~ s/^Veritas //mg;
            if ($pname =~ /$lname/m) {
                $fv = $sys->{keys}{$lk}{$feature};
                ($fv) ? push(@rv,$fv) : return 0;
            }
        }
    }
    $sys->set_value('donotquerykeys', 0);
    return 1 if (@rv);
    return 0;
}

sub add_namespace_vcs_sys {
    my ($prod,$sys)=@_;
    my ($pids,$conf,$rootpath,$xprtldconf,$xprtldconf_generated);

    $rootpath = Cfg::opt('rootpath') || '';

    $xprtldconf=$rootpath . '/etc/opt/VRTSsfmh/xprtld.conf';
    $xprtldconf_generated = $sys->exists($xprtldconf);

    if (($sys->{padv}=~/^Sol11/m) && (!$xprtldconf_generated)) {
        # Due to incident 3148358, xprtld.conf is generated after VRTSsfmh's SMF service started.
        # Since CPI install all Solaris 11 packages together, VRTSsfmh's SMF service may not started immediately.
        # Hence wait at most 20 seconds until xprtld.conf get generated
        for (1..10) {
            sleep 2;
            $xprtldconf_generated = $sys->exists($xprtldconf);
            last if ($xprtldconf_generated);
        }
    }

    if ($xprtldconf_generated) {
        $conf = $sys->catfile($xprtldconf);
    } else {
        Msg::log("$xprtldconf cannot be accessed, skip adding namespace into xprtld.conf");
    }

    if ($conf && $conf !~ /namespaces\s+vcs/) {
        $conf = 'namespaces vcs=/opt/VRTSvcs/portal';
        $sys->appendfile($conf,$xprtldconf);
        return 1 if($rootpath);
        $pids = $sys->proc_pids('/opt/VRTSsfmh/bin/xprtld');
        if (@$pids) {
            # if the process is running, dynamically add namespace
            $sys->cmd("/opt/VRTSsfmh/bin/xprtlc -l https://localhost/admin/xprtld/config/namespace/add -d namespace=vcs -d document_root=/opt/VRTSvcs/portal 2> /dev/null");
        }
    }
    # if $pids not defined or @$pids is empty, we need to start xptrld
    unless ((defined $pids) && @$pids) {
        $sys->cmd("/opt/VRTSsfmh/adm/xprtldctrl start 2> /dev/null");
    }
    return 1;
}

sub configure_sso_sys {
    my ($prod,$sys)=@_;
    my ($edr,$cfg,$msg,$exitcode);

    return 1 if (Cfg::opt('rootpath'));
    $edr=Obj::edr();
    $cfg=Obj::cfg();

    if ($cfg->{sso_console_ip} && $cfg->{sso_local_username} && $cfg->{sso_local_password}) {
        $edr->{donotlog} = 1;
        $sys->cmd("/opt/VRTSvcs/portal/admin/configureSSO.pl $cfg->{sso_console_ip} $cfg->{sso_local_username} $cfg->{sso_local_password}");
        $edr->{donotlog} = 0;
        $exitcode = EDR::cmdexit();
        if ($exitcode) {
            $msg = Msg::new("configureSSO.pl failed with exit code $exitcode.");
            $sys->push_warning($msg);
        }
    }
    return 1;
}

sub cluster_systems {
    my ($systems,$syscfg,$cfg);
    $cfg=Obj::cfg();
    $syscfg = $cfg->{systemscfg};
    $systems = CPIC::get('systems');
    return $syscfg if($syscfg);
    return $systems;
}

sub cluster_master_sys {
    my ($prod, $system) = @_;
    my ($vxdctl_master, $msg);
    eval {$vxdctl_master = $system->cmd("_cmd_vxdctl -c mode | _cmd_awk '/master:/ {print \$2}'");};
    my $errstr = $@;

    my $web = Obj::web();
    if ($errstr) {
        $msg = Msg::log("Problem running 'vxdctl' on $system->{sys}. Error info: $errstr");
        $msg = Msg::new("Cannot determine the MASTER node");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
    # You might want to print the manual steps here
        Msg::prtc() ;
        return 1;
    } else {
        if (!$vxdctl_master) {
            $msg = Msg::log("Cannot determine the MASTER node. Error info: check the cluster status.");
            $msg = Msg::new("Cannot determine the MASTER node");
            $msg->print;
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            # You might want to print the manual steps here
        }
        return 1 if (EDR::cmdexit());
        chomp($vxdctl_master);
        my $tempmaster = $vxdctl_master;
        # Procedure to determine sys obj of master.
        # 1. find in Obj::pool directly.
        # 2. check all Sys objects in Obj::pool to see whose vcs_sysname is $tempmaster.
        if ($Obj::pool{"Sys::$vxdctl_master"}) {
            $vxdctl_master = Obj::sys($vxdctl_master);
            for my $syskey (keys %Obj::pool) {
                next if ($syskey !~ /^Sys::/mx);
                my $sys = $Obj::pool{$syskey};
                if ($sys && !$sys->{vcs_sysname}) {
                    $sys->{vcs_sysname} = $prod->get_vcs_sysname_sys($sys);
                }
                if ($sys && $sys->{vcs_sysname} eq $tempmaster) {
                    $vxdctl_master = $sys;
                    last;
                }
            }
        } else {
            Msg::log("No existing Sys object for $tempmaster found");
            $vxdctl_master = Sys->new($tempmaster);
            my $edr = Obj::edr();
            if (!$edr->transport_sys($vxdctl_master)) {
                $msg = Msg::new("The CVM master node $tempmaster cannot be accessed as root user via either SSH or RSH without entering password from local system. Make sure SSH or RSH communication is configured in password-less mode on $tempmaster.");
                $msg->print;
                Msg::prtc() ;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
        }

        if (!$vxdctl_master) {
            $msg = Msg::new("The node $tempmaster doesn't seem to be a part of the cluster, or CVM is not running on the node $tempmaster");
            $msg->print;
            Msg::prtc() ;
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            return 1;
        }
    }
    return $vxdctl_master;
}

# By default, the order of systems in the list defines the priority of systems used in a failover. For example, the following definition configures SystemA to be the first choice on failover, followed by SystemB and then SystemC.
#       SystemList = { SystemA, SystemB, SystemC}
#
# If you do not assign numeric priority values, VCS assigns a priority to the system without a number by adding 1 to the priority of the preceding system. For example, if the SystemList is defined as follows, VCS assigns the values SystemA = 0, SystemB = 2, SystemC = 3.
#       SystemList = {SystemA, SystemB=2, SystemC}
sub get_sg_max_priority {
    my ($prod, $sgname) = @_; 
    my ($syslist, $max, $firstnode, @val);
    my $cfg = Obj::cfg();

    $max = 0;
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $syslist = $firstnode->cmd("_cmd_hagrp -value $sgname SystemList -localclus 2>/dev/null | _cmd_awk '{ for (i=1; i<=NF; i++) { if (i%2==0) print \$i } }'");
    @val = split(/\s+/, $syslist);
    @val = sort {$b <=> $a} @val;
    $max = shift @val;
    return $max;
}

package Prod::VCS61::AIX;
@Prod::VCS61::AIX::ISA = qw(Prod::VCS61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSveki61 VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{minpkgs}=[ qw(VRTSveki61 VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTSvcsag61 VRTSsfmh60 VRTSvcswiz61) ];
    $prod->{recpkgs}=[ qw(VRTSveki61 VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0 6.1)];
    $prod->{deleted_agents} = [ qw(ServiceGroupHB ClusterMonitorConfig ClusterConnectorConfig VRTSWebApp) ];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw.rte VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw.rte
        VRTScspro VRTSvcsdb.rte VRTSvcsor.rte VRTSvcssy.rte
        VRTSvcsvr VRTScmccc.rte VRTScmcs.rte VRTSacclib52 VRTSacclib.rte
        VRTScscm.rte VRTSweb.rte VRTScscw.rte VRTScssim.rte VRTSvbs61 VRTSsfmh60
        VRTSvcsea61 VRTScutil VRTScutil.rte VRTSjre15.rte VRTSvcs.doc VRTSvcs.man
        VRTSvcs.msg.en_US VRTSvcsag61 VRTSvcsag.rte VRTScps61
        VRTSvcs61 VRTSvcs.rte VRTSamf61 VRTSvxfen61 VRTSvxfen.rte VRTSgab61
        VRTSgab.rte VRTSllt61 VRTSllt.rte VRTSveki61 VRTScpi.rte
        VRTSvsvc SYMClma VRTSspt61 VRTSat50 VRTSat.server VRTSat.client
        VRTSsmf VRTSpbx VRTSicsco VRTSjre.rte VRTSsfcpi61 VRTSperl516 VRTSperl.rte
        VRTSvlic32
    ) ];
    # For UXRT 5.1SP1, VRTSacclib need to be fresh on AIX and Solaris.
    $prod->{obsoleted_but_need_refresh_when_upgrade_pkgs} = [ qw(VRTSacclib52) ];

    $prod->{initfile}{llt} = '/etc/default/llt';
    $prod->{initfile}{gab} = '/etc/default/gab';
    $prod->{initfile}{vxfen} = '/etc/default/vxfen';
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{initfile}{amf} = '/etc/default/amf';

    #add for checking oracle rac crs home
    $prod->{initdir} = '/etc/';
    return;
}

sub padv_maincf_update_netmask_sys {
    return;
}

sub upgrade_preinstall_sys {
    my ($prod,$sys)=@_;
    if ($sys->{partial_upgrade} && $sys->pkgvers('VRTSveki')) {
        Msg::log("Set PRIVATE flag for VRTSveki package");
        $sys->cmd('_cmd_swvpdmgr -p VRTSveki 2>/dev/null');
    }
}

sub update_pseconf_sys {
    my ($prod,$sys) = @_;
    my ($dlpi,$npse,$line,@l,$llt,$pse,$tmpdir,$uen);
    $tmpdir=EDR::tmpdir();
    Msg::log("Updating pse.conf on $sys->{sys}");
    $pse=$sys->cmd('_cmd_cat /etc/pse.conf');
    @l=split(/\n/,$pse);
    for my $line (@l) {
        if (($line=~/^#d+/m) && ($line=~/\/dev\/dlpi\/en/mx)) {
            $line=~s/^#d\+/d+/m;
            $uen=1;
        }
        next if (($line=~/^d/m) && ($line=~/llt/m));
        $npse.="$line\n";
    }
    if ($uen) {
        EDRu::writefile($npse, "$tmpdir/pse.conf.$sys->{sys}");
        $prod->localsys->copy_to_sys($sys,"$tmpdir/pse.conf.$sys->{sys}",'/etc/pse.conf');
        $dlpi=$sys->cmd("_cmd_strload -q -d /usr/lib/drivers/pse/dlpi | _cmd_awk '{print \$2}'");
        chomp($dlpi);
        if ($dlpi eq 'no') {
            $sys->cmd('_cmd_strload -f /etc/dlpi.conf');
        }
        $llt=$sys->cmd("_cmd_strload -q -d /usr/lib/drivers/pse/llt | _cmd_awk '{print \$2}'");
        if ($llt eq 'no') {
            $sys->cmd('_cmd_strload -d /usr/lib/drivers/pse/llt');
        }
        Msg::log('pse.conf updated');
    } else {
        Msg::log('pse.conf correct without update');
    }
    return;
}

package Prod::VCS61::HPUX;
@Prod::VCS61::HPUX::ISA = qw(Prod::VCS61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61) ];
    $prod->{minpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTSvcsag61) ];
    $prod->{recpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61) ];
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(3.5 4.1 5.0 5.1 6.0 6.1)];
    $prod->{deleted_agents} = [ qw(ServiceGroupHB ClusterMonitorConfig CampusCluster ClusterConnectorConfig VRTSWebApp) ];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw
        VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy VRTSvcsvr VRTScmccc
        VRTScmcs VRTScscm VRTSweb VRTScscw VRTScssim VRTSvbs61 VRTSsfmh60
        VRTSvcsea61 VRTScutil VRTSjre15 VRTSvcsdc VRTSvcsmn
        VRTSvcsmg VRTSvcsdr61 VRTSvcsag61 VRTScps61 VRTSvcs61
        VRTSamf61 VRTSvxfen61 VRTSgab61 VRTSllt61 VRTScpi VRTSvsvc SYMClma
        VRTSspt61 VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSjre
        VRTSsfcpi61 VRTSperl516 VRTSvlic32 VRTSwl
    ) ];

    $prod->{initfile}{llt} = '/etc/rc.config.d/lltconf';
    $prod->{initfile}{gab} = '/etc/rc.config.d/gabconf';
    $prod->{initfile}{vxfen} = '/etc/rc.config.d/vxfenconf';
    $prod->{initfile}{vcs} = '/etc/rc.config.d/vcsconf';
    $prod->{initfile}{amf} = '/etc/rc.config.d/amf';

    #add for checking oracle rac crs home
    $prod->{initdir} = '/etc/init.d/';
    $prod->{initdir} = '/sbin/init.d';
    return;
}

sub check_os_patch_sys {
    my ($msg, $prod, $sys);
    ($prod, $sys) = (@_);
    if (($sys->{oslevel} eq '1103') || ($sys->{oslevel} eq '1109')) {
        $sys->padv->patches_sys($sys);
        # If PHKL_41700 is installed, check if hires_timeout_enable is set to 1
        if (EDRu::inarr('PHKL_41700',@{$sys->{patches}})) {
            return if (EDRu::inarr('PHKL_41967',@{$sys->{patches}}));
            my $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep hires_timeout_enable");
            if ($param =~ /hires_timeout_enable\s+0\s+/) {
                $msg = Msg::new("Patch PHKL_41700 is installed on $sys->{sys}. Install patch PHKL_41967 for an important fix. Or you can tune hires_timeout_enable kernel parameter to 1 before starting the cluster. Run the following command to set this variable to 1: kctune hires_timeout_enable=1. VCS will fail to start if the recommended patch is not installed or the kernel parameter is not set properly.");
                $sys->push_warning($msg);
            }
        }
    }
    return;
}

sub padv_mend_old_cf_sys {
    my ($prod, $sys, $path) = @_;
    my $typecf = $sys->readfile("$path/types.cf");
    if ($typecf =~ /\s*static\s+int\s+Operations\s+=\s+None/mx) {
        $typecf =~ s/(\s*static\s+)int(\s+Operations\s+=\s+None)/$1str$2/mxg;
        $sys->writefile($typecf, "$path/types.cf");
    }
    return 1;
}

sub padv_maincf_upgrade_sys{
    my ($prod,$sys,$treeref_result,$treeref_newsys) = @_;
    # modify vxatd path if upgrade from 4.1 on HPUX platform
    Prod::VCS61::Common::dynupgrade_modify_attr_value($treeref_result,'ProcessOnOnly','PathName','/opt/VRTSat/bin/pa20_64/vxatd','/opt/VRTSat/bin/vxatd');
    return $treeref_result;
}

package Prod::VCS61::Linux;
@Prod::VCS61::Linux::ISA = qw(Prod::VCS61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsdr61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{minpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTSvcsag61 VRTSsfmh60 VRTSvcswiz61) ];
    $prod->{recpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsdr61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{upgradevers}=[qw(5.0.30 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(4.1.40 5.0 5.1 6.0 6.1)];
    $prod->{deleted_agents} = [ qw(ServiceGroupHB ClusterMonitorConfig CampusCluster ClusterConnectorConfig SANVolume VRTSWebApp) ];
    $prod->{rename_attrs} = {'Apache' => {'Address' => 'HostName',
                                          'Postdirective' => 'DirectiveAfter',
                                          'Predirective' => 'DirectiveBefore',
                                          'ServerRoot' => 'httpdDir'}
                            };
    $prod->{extra_types}=['vcsApacheTypes.cf'];
    $prod->{obsoleted_but_need_refresh_when_upgrade_pkgs} = [ qw(VRTSacclib52) ];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw
        VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy VRTSvcsvr VRTScmccc
        VRTScmcs VRTScscm VRTSweb VRTScscw VRTScssim VRTSvbs61 VRTSsfmh60
        VRTSvcsea61 VRTScutil VRTSjre15 VRTSvcsdc VRTSvcsmn
        VRTSvcsmg VRTSvcsdr61 VRTSvcsag61 VRTScps61 VRTSvcsvmw61 VRTSvcs61
        VRTSamf61 VRTSvxfen61 VRTSgab61 VRTSllt61 VRTScpi VRTSvsvc SYMClma
        VRTSspt61 VRTSat50 VRTSatClient50 VRTSsmf VRTSpbx VRTSicsco
        VRTSjre VRTSsfcpi61 VRTSperl516 VRTSvlic32
    ) ];

    $prod->{initfile}{llt} = '/etc/sysconfig/llt';
    $prod->{initfile}{gab} = '/etc/sysconfig/gab';
    $prod->{initfile}{vxfen} = '/etc/sysconfig/vxfen';
    $prod->{initfile}{vcs} = '/etc/sysconfig/vcs';
    $prod->{initfile}{amf} = '/etc/sysconfig/amf';

    #add for checking oracle rac crs home
    $prod->{initdir} = '/etc/init.d/';
    return;
}

sub padv_maincf_update_netmask_sys {
    my ($prod,$sys,$treeref,$vcsvers) = @_;
    my ($attrref_netmask,$addressref,$address,$netmask,$netmask_setting,$noderef);
    my ($attrref_options,$attrref_ipoptions,$attrref_iprouteoptions,$attrref_linkoptions,$attrref_ipv4addroptions);
    my (@reslist_ip,@reslist_ipmultinic,@reslist_multinica);

    # For IP resources
    @reslist_ip = Prod::VCS61::Common::dynupgrade_get_resname_list_from_typename($treeref, 'IP');
    for my $res (@reslist_ip) {
        $noderef = Prod::VCS61::Common::dynupgrade_get_node_from_tree($treeref, 'RES', $res);
        $attrref_netmask = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'NetMask');
        if (!$attrref_netmask) {
            $netmask = '255.0.0.0';
            $attrref_options = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'Options');
            if ($attrref_options) {
                $attrref_ipoptions = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'IPOptions');
                $attrref_iprouteoptions = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'IPRouteOptions');
                if (!$attrref_ipoptions && ! $attrref_iprouteoptions) {
                    $addressref = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'Address');
                    $address = $addressref->{MODIFY}->{ATTRVAL}->[0];
                    $address =~ s/.*"(.*)"/$1/m;
                    $netmask = $prod->get_netmask_by_address($address);
                }
            }
            $netmask_setting.="hares -modify $res NetMask \"$netmask\"\n";
        }
    }

    @reslist_ipmultinic = Prod::VCS61::Common::dynupgrade_get_resname_list_from_typename($treeref, 'IPMultiNIC');
    for my $res (@reslist_ipmultinic) {
        $noderef = Prod::VCS61::Common::dynupgrade_get_node_from_tree($treeref, 'RES', $res);
        $attrref_netmask = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'NetMask');
        if (!$attrref_netmask) {
            $netmask = '255.0.0.0';
            $attrref_options = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'Options');
            if ($attrref_options) {
                $attrref_ipoptions = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'IPOptions');
                if (!$attrref_ipoptions) {
                    $addressref = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'Address');
                    $address = $addressref->{MODIFY}->{ATTRVAL}->[0];
                    $address =~ s/.*"(.*)"/$1/m;
                    $netmask = $prod->get_netmask_by_address($address);
                }
            }
            $netmask_setting.="hares -modify $res NetMask \"$netmask\"\n";
        }
    }

    @reslist_multinica = Prod::VCS61::Common::dynupgrade_get_resname_list_from_typename($treeref, 'MultiNICA');
    for my $res (@reslist_multinica) {
        $noderef = Prod::VCS61::Common::dynupgrade_get_node_from_tree($treeref, 'RES', $res);
        $attrref_netmask = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'NetMask');
        if (!$attrref_netmask) {
            $netmask = '255.0.0.0';
            $attrref_options = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'Options');
            if ($attrref_options) {
                $attrref_linkoptions = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'LinkOptions');
                $attrref_ipv4addroptions = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'IPv4AddrOptions');
                if (!$attrref_linkoptions && ! $attrref_ipv4addroptions) {
                    $addressref = Prod::VCS61::Common::dynupgrade_get_node_from_tree($noderef, 'ATTR', 'Device');
                    $address = $addressref->{MODIFY}->{ATTRVAL}->[0];
                    $address =~ s/.*"(.*)"/$1/m;
                    $netmask = $prod->get_netmask_by_address($address);
                }
            }
            $netmask_setting.="hares -modify $res NetMask \"$netmask\"\n";
        }
    }

    $sys->set_value('maincf_upgrade,22_netmask_setting', $netmask_setting);
    return;
}

sub is_vlan_nic_sys {
    my ($prod,$sys,$nic) = @_;
    return $sys->exists("/proc/net/vlan/$nic");
}

sub convert_nic2lltlink_sys {
    my ($prod,$sys,$nic,$lowpri) = @_;
    my ($msg,$cfg,@ifc);
    $cfg=Obj::cfg();
    return '' unless ($nic);

    if ($lowpri) {
        $lowpri='-lowpri';
    } else {
        $lowpri='';
    }

    if ($prod->is_vlan_nic_sys($sys, $nic) || $sys->padv->is_bonded_nic_sys($sys, $nic)) {
        # VLAN interface. Cant use MAC here.
        return "link$lowpri $nic $nic - ether - -\n";
    }
    my $output = $sys->cmd("_cmd_ip -o link show dev '$nic'");
    if (EDR::cmdexit()) {
        $msg=Msg::new("NIC $nic does not exist on system $sys->{sys}. LLT may not come up. Exiting installation.");
        $msg->die;
    }
    chomp($output);
    @ifc = split (/\s+/m,$output);
    my $idx = EDRu::arrpos('link/ether', @ifc);
    if ($idx == -1) {
        # NIC without a MC?
        return '';
    }
    # The next index will be the MAC
    return "link$lowpri $nic eth-$ifc[$idx+1] - ether - -\n";
}

# get the original NIC name from a link/link-lowpri devname in /etc/llttab (For LLT over Ethernet)
sub convert_linkdev2nic_sys {
    my ($prod,$sys,$linkdev) = @_;
    my ($rnics,$nic,$mac,$found,$h,$nici,$output,$dev);
    return '' if (!$linkdev);
    $rnics = $sys->padv->systemnics_sys($sys,1);
    $found = 0;
    $mac = $linkdev;
    $h = '[A-Fa-f0-9]';
    if ( $mac !~ /eth-$h$h:$h$h:$h$h:$h$h:$h$h:$h$h/mx) {
        return $mac;
    }
    $mac=~s/eth-//m;

    for my $nici (@$rnics) {
        next unless $nici;
        $output = $sys->cmd("_cmd_ifconfig '$nici'");
        if ( $output =~ /[^A-Fa-f0-9]$mac[^A-Fa-f0-9]/mxi) {
            $found = 1;
            $nic = $nici;
            last;
        }
    }
    if ( !$found) {
        $nic = $linkdev; # return original value if no NIC with specified MAC found.
    }
    return $nic;
}

# check if node has ksh installed, vxfen need this rpm
sub check_ksh_for_vxfen_sys {
    my ($prod,$sys) = @_;
    my ($rtn,$pkg,$msg,$padv,$oslib);

    $padv=$sys->padv;
    $pkg = 'ksh';
    $oslib = '/bin/ksh';

    if($padv->can('oslibrary_sys')) {
        # do not check if this node do not have the lib
        return 1 unless $padv->oslibrary_sys($sys,$oslib);
    }

    $rtn = $sys->cmd("_cmd_rpm -qa $pkg 2>/dev/null");
    unless ($rtn) {
        $msg=Msg::new("The '$pkg' rpm is not installed on $sys->{sys}, it is recommended to install it on the system.");
        $sys->push_warning($msg);
    }
    return 1;
}

sub checknicconf_sys {
    my ($prod,$sys) = @_;
    my ($name,$msg,$cnffile,$nic,%iflist,$mac,$line,$rtn,$masternics,$slavenics);

    # only check for suse linux
    unless ($sys->{padv} =~ /SLES10/m) {
        return 0;
    }
    ($masternics,$slavenics)=$sys->padv->bondednics_sys($sys);
    $rtn = $sys->cmd('_cmd_ip -o link show');
    for my $line (split(/\n/,$rtn)) {
        if ($line=~/\d+:\s+(\w*):.*link\/ether\s+(\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})\s+/mx){
            $nic=$1;
            $mac=$2;
        } else {
            next;
        }

        next if ($prod->is_vlan_nic_sys($sys,$nic));
        next if ($nic =~ /bond\d+/m);
        next if (EDRu::inarr($nic,@{$masternics}));
        next if (EDRu::inarr($nic,@{$slavenics}));

       if (exists ($iflist{$mac})) {
            $iflist{$mac}.=" $nic";
        } else {
            $iflist{$mac} = $nic;
        }
    }

    my $fp = 0;
    $rtn= $sys->cmd("_cmd_grep '^FORCE_PERSISTENT_NAMES' /etc/sysconfig/network/config");
    if( $rtn =~ /^FORCE_PERSISTENT_NAMES\s+=\s+no/mx ) {
        $fp= 0;
    } else {
        $fp= 1;
    }

    if ($fp) {
        # for sles10, use rule based framework to find the PERSISTENT_NAMEs
        my (%filelist, $mac_addr, $content, @lines);
        $content= $sys->cmd("_cmd_grep '^.*SUBSYSTEM.*==.*net.*ACTION.*==.*add' /etc/udev/rules.d/30-net_persistent_names.rules");
        @lines= split(/\n+/, $content);
        for(@lines) {
            # remove comments
            s/#.*$//;

            # parse lines similar to:
            #   SUBSYSTEM=="net", ACTION=="add", SYSFS{address}=="00:0c:29:3c:04:fd", IMPORT="/lib/udev/rename_netiface %k eth0"
            #   SUBSYSTEM=="net", ACTION=="add", SYSFS{address}=="00:0c:29:3c:04:07", IMPORT="/lib/udev/rename_netiface %k eth1"
            if (/^.*?SUBSYSTEM\s*?==\s*?\"net\"\s*?,\s*?ACTION\s*?==\s*?\"add\"\s*?,\s*?SYSFS\{address\}\s*?==\s*?\"(\w{2}(:\w{2}){5})\".*?IMPORT.*\%k\s+(\w*?)\".*?$/) {
                $filelist{$1}= $3;
            }
        }

        # make sure each nic name has the right mac address
        for my $mac_addr ( keys %iflist) {
            # find the undefined NIC
            if( !$filelist{$mac_addr} ) {
                $msg = Msg::new("PERSISTENT_NAME is not set for all the NICs. Manually set it before the next reboot.");
                $sys->push_warning($msg);
                next;
            }
            if ($iflist{$mac_addr} ne $filelist{$mac_addr}) {
                $msg = Msg::new("WRONG configuration. NIC with MAC address $mac_addr has name $iflist{$mac_addr}, but config file says $filelist{$mac_addr}");
                $sys->push_error($msg);
                next;
            }
            # MAC address correctly set
            Msg::log("$iflist{$mac_addr} on $sys->{sys} configured correctly");
        }

    } else {

        #$sys->copy_to_sys($localsys,"/etc/sysconfig/network/ifcfg-eth-id-*",EDR::tmpdir());
        $rtn = $sys->cmd('_cmd_ls /etc/sysconfig/network/ifcfg-eth-id-*');
        for my $cnffile (split(/\n/,$rtn)) {
            my ($addr);

            Msg::log("Processing file $cnffile on $sys->{sys}");
            $addr = lc($cnffile);
            $addr = substr ($addr, -17); # Last 17 chars are the MAC
            if (!defined($iflist{$addr})) {
                # A file has already been found for this NIC.
                # We should proceed only if the current file is the higher
                # priority one, i.e., the one with the file name in caps.
                # But since the array has been lexicographiaclly sorted,
                # that cannot be. So we can safely skip this file.
                Msg::log("File $cnffile from $sys->{sys} skipped. This happens when there are two files for the same MAC address, and the current file is the one with lowercase filename.");
                next;
            }
            undef $name;
            $rtn = $sys->cmd("_cmd_grep '^PERSISTENT_NAME' $cnffile 2>/dev/null");
            if ($rtn =~ /PERSISTENT_NAME\s+=\s+(.*)/mx) {
                $name = $1;
                if ($iflist{$addr}!~ /$name/m) {
                    $msg = Msg::new("WRONG configuration. NIC with MAC address $addr has name $iflist{$addr}, but config file says $name.");
                    $sys->push_error($msg);
                } else {
                    Msg::log("$name on $sys->{sys} configured correctly");
                }
            } else {
                $msg = Msg::new("No PERSISTENT_NAME set for NIC with MAC address $addr (present name $iflist{$addr}), though config file exists.");
                $sys->push_warning($msg);
            }
            $iflist{$addr} = undef; # File for this guy found & processed
        }

        for my $key (keys (%iflist)) {
            if (defined($iflist{$key})) {
                $msg = Msg::new("Configuration file for NIC with MAC address $key (present name $iflist{$key}) not found");
                $sys->push_warning($msg);
            }
        }
    }

    return;
}

sub completion_messages {
    my ($prod)=@_;
    my ($msg,$web,$syslist,$sys,$pkg,$msg_printed);
    $prod->SUPER::completion_messages();
    $web = Obj::web();

    return unless (Cfg::opt(qw(configure install addnode upgrade patchupgrade hotfixupgrade)));

    # Randomly pick up a machine in the cluster and check if has VRTSvcswiz package
    $syslist=CPIC::get('systems');
    $sys = @$syslist[0] || $prod->localsys;
    $sys = Obj::sys($sys) if(ref($sys) ne 'Sys');
    $pkg = $prod->pkg('VRTSvcswiz61',1);
    $msg_printed = 0;

    if(defined($pkg) && $pkg->version_sys($sys)) {
        if($sys->exists("/opt/VRTSsfmh/bin/testVMware")) {
            $sys->cmd("/opt/VRTSsfmh/bin/testVMware");
            if(EDR::cmdexit() eq '0') {
                $msg=Msg::new("You are running this virtual machine under a VMware environment. You may access the cluster view for this virtual machine using the vSphere client. To access the cluster view for the virtual machine using the vSphere client, log on to the vCenter Server through the vSphere client, navigate to the virtual machine in the inventory view and click on the 'Symantec High Availability' tab.\nYou may also access the cluster view from a browser. To access the cluster view through a browser, open the URL below in a browser:\n");
                $msg->print();
                $msg = Msg::new("https://<VM_IP_or_Hostname>:5634/vcs/admin/application_health.html\n");
                $msg->bold();
                if(Obj::webui()) {
                    $msg = Msg::new("You are running this virtual machine under a VMware environment. You may access the cluster view for this virtual machine using the vSphere client. To access the cluster view for the virtual machine using the vSphere client, log on to the vCenter Server through the vSphere client, navigate to the virtual machine in the inventory view and click on the \\'Symantec High Availability\\' tab.\nYou may also access the cluster view from a browser. To access the cluster view through a browser, open the URL below in a browser:\\n<B>https://VM_IP_or_Hostname:5634/vcs/admin/application_health.html\\n")->{msg};
                    $web->web_script_form('alert', $msg);
                }
                $msg_printed=1;
            }
        }
        if (!$msg_printed) {
            $msg=Msg::new("After configuring the cluster, you can configure application monitoring using Veritas Operations Manager (VOM).\nTo launch the Symantec High Availability Configuration Wizard:\n1. Log on to the VOM Management Server domain.\n2. In the VOM home page, click the Availability icon from the list of perspectives.\n3. Locate the cluster and then right-click on the cluster or on one of the systems under the cluster.\n4. Click Configure Application.");
            $msg->printn();
            if(Obj::webui()) {
                $msg=Msg::new("After configuring the cluster, you can configure application monitoring using the Veritas Operations Manager (VOM).\\nTo launch the Symantec High Availability Configuration Wizard:\\n1. Log on to the VOM Management Server domain.\\n2. In the VOM home page, click the Availability icon from the list of perspectives.\\n3. Locate the cluster and then right-click on the cluster or on one of the systems under the cluster.\\n4. Click Configure Application.")->{msg};
                $web->web_script_form('alert', $msg);
            }
        }
    }
    return;
}

sub setup_rdma_driver_config_sys {
    my ($prod,$sys,$rdma_type) = @_;

    my $conf_file=$prod->{rdma_driver_file};
    return 1 if (!$conf_file);

    my $content=<<'_EOL_';
ONBOOT=yes
RDMA_UCM_LOAD=yes
MTHCA_LOAD=yes
IPOIB_LOAD=yes
SDP_LOAD=yes
MLX4_LOAD=yes
MLX4_EN_LOAD=yes
_EOL_

    my $conf_file_backup=$prod->{rdma_driver_file}. '.orig';
    if (!$sys->exists($conf_file_backup)) {
        $sys->movefile($conf_file, $conf_file_backup);
    }
    $sys->writefile($content, $conf_file);

    # Enable RDMA service on reboot
    my $rdma_service=$prod->{rdma_service};
    if ($rdma_service) {
        $sys->cmd("/etc/init.d/$rdma_service start 2>/dev/null");
        $sys->cmd("/sbin/chkconfig --level 235 $rdma_service on 2>/dev/null");
    }

    return 1;
}

sub check_rdma_opensm_service_sys {
    my ($prod,$sys,$rdma_type) = @_;
    my ($init_script,$opensm_service,$status,$msg,$ib_ports);

    return 1 unless ($rdma_type eq 'InfiniBand');

    $opensm_service='';
    $init_script='';
    if ($sys->exists('/etc/init.d/opensmd')) {
        $opensm_service='opensmd';
        $init_script='/etc/init.d/opensmd';
    } elsif ($sys->exists('/etc/init.d/opensm')) {
        $opensm_service='opensm';
        $init_script='/etc/init.d/opensm';
    }
    $prod->{rdma_opensm_service}=$opensm_service;
    $prod->{rdma_opensm_init_script}=$init_script;

    $ib_ports=$sys->cmd("/usr/sbin/ibstat -p 2>/dev/null");
    if (!$ib_ports) {
        $msg=Msg::new("There are no InfiniBand NICs exist on $sys->{sys}");
        $sys->push_error($msg);
        $prod->{rdma_fatal_errors}=1;
        return 0;
    }

    if (!$init_script) {
        $msg=Msg::new("The opensm init script does not exist on $sys->{sys}");
        $sys->push_error($msg);
        return 0;
    }

    $status=$sys->cmd("$init_script status 2>/dev/null");
    return 1 if ($status =~ /running/);

    $msg=Msg::new("$opensm_service service is not in running state on $sys->{sys}");
    $sys->push_warning($msg);

    return 0;
}

sub setup_rdma_opensm_service_sys {
    my ($prod,$sys,$rdma_type) = @_;
    my ($status,$ib_ports,$opensm_service,$opensm_init_script,$opensm_file,$opensm_config,$need_create,$msg);

    $opensm_service=$prod->{rdma_opensm_service};
    $opensm_init_script=$prod->{rdma_opensm_init_script};

    if ($opensm_service eq 'opensm') {
        $ib_ports=$sys->cmd("/usr/sbin/ibstat -p 2>/dev/null");
        return 0 if (!$ib_ports);

        $ib_ports=~s/\n+/ /g;

        $need_create=1;
        $opensm_file='/etc/sysconfig/opensm';
        $opensm_config=$sys->catfile($opensm_file);
        if ($opensm_config=~/^\s*GUIDS=(['"])(.*)\1/mx) {
            if ($2 eq $ib_ports) {
                $need_create=0;
            } else {
                $opensm_config=~s/^\s*GUIDS=.*$/GUIDS="$ib_ports"/mx;
            }
        } else {
            $opensm_config.="\nGUIDS=\"$ib_ports\"\n";
        }

        if ($need_create) {
            $sys->movefile($opensm_file, $opensm_file.'.bak');
            $sys->writefile($opensm_config, $opensm_file);
        }
    }

    # Enable OpenSM service on reboot
    if ($opensm_service) {
        $sys->cmd("/sbin/chkconfig --level 235 $opensm_service on 2>/dev/null");
    }

    if ($opensm_init_script) {
        $sys->cmd("$opensm_init_script start 2>/dev/null");
        sleep 1;
        $status=$sys->cmd("$opensm_init_script status 2>/dev/null");
        if ($status =~ /running/) {
            return 1;
        } else {
            $msg=Msg::new("Failed to set up $opensm_service service configuration on $sys->{sys}");
            $sys->push_warning($msg);
            $prod->{rdma_fatal_errors}=1;
        }
    }

    return 0;
}

package Prod::VCS61::RHEL6x8664;
@Prod::VCS61::RHEL6x8664::ISA = qw(Prod::VCS61::Linux);

sub init_padv {
    my $prod=shift;
    $prod->{native_install_tool} = 'yum';
    $prod->{native_install_cmd} = '/usr/bin/yum -y install';
    $prod->{package_install_cmd} = '/usr/bin/rpm -Uvh';
    $prod->{rdma_driver_file} = '/etc/rdma/rdma.conf';
    $prod->{rdma_service} = 'rdma';

    $prod->{feature_required_os_pkgs} = {
      'LLT_over_RDMA' => [
         #'libibverbs 1.1.4',
         'libibverbs-devel 1.1.4',
         'libibverbs-utils 1.1.4',
         'libmthca 1.0.5',
         'libmlx4 1.0.1',
         'libibumad 1.3.4',
         #'librdmacm 1.0.10',
         'librdmacm-utils 1.0.10',
         'rdma 1.0',
         'opensm 3.3.5',
         'opensm-libs 3.3.5',
         'ibutils 1.5.4',
         'infiniband-diags 1.0.0',
         'perftest 1.2.3',
      ]
    };

    $prod->{feature_required_os_pkgs}{LLT_over_RDMA_InfiniBand} = $prod->{feature_required_os_pkgs}{LLT_over_RDMA};
    $prod->{feature_required_os_pkgs}{LLT_over_RDMA_RoCE} = EDRu::arrdel($prod->{feature_required_os_pkgs}{LLT_over_RDMA}, 'opensm 3.3.5', 'opensm-libs 3.3.5');

    return;
}

package Prod::VCS61::SLES11x8664;
@Prod::VCS61::SLES11x8664::ISA = qw(Prod::VCS61::Linux);

sub init_padv {
    my $prod=shift;
    $prod->{native_install_tool} = 'zypper';
    $prod->{native_install_cmd} = '/usr/bin/zypper -n install';
    $prod->{package_install_cmd} = '/usr/bin/rpm -Uvh';
    $prod->{rdma_driver_file} = '/etc/infiniband/openib.conf';
    $prod->{rdma_service} = 'openibd';
    $prod->{feature_required_os_pkgs} = {
      'LLT_over_RDMA' => [
         'libibverbs 1.1.4',
         'libmthca-rdmav2 1.0.5',
         'libmlx4-rdmav2 1.0',
         'libibumad3 1.3.6',
         'librdmacm 1.0.13',
         'ofed 1.5.2',
         'opensm 3.3.7',
         'ibutils 1.5.4',
         'infiniband-diags 1.5.7',
      ]
    };
    $prod->{feature_required_os_pkgs}{LLT_over_RDMA_InfiniBand} = $prod->{feature_required_os_pkgs}{LLT_over_RDMA};
    $prod->{feature_required_os_pkgs}{LLT_over_RDMA_RoCE} = EDRu::arrdel($prod->{feature_required_os_pkgs}{LLT_over_RDMA}, 'opensm 3.3.7');

    return;
}

package Prod::VCS61::SunOS;
@Prod::VCS61::SunOS::ISA = qw(Prod::VCS61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{minpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTSvcsag61 VRTSsfmh60 VRTSvcswiz61) ];
    $prod->{recpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{deleted_agents} = [ qw(DiskReservation NFSLock ServiceGroupHB
                                   CampusCluster ClusterMonitorConfig CFSQlogckd
                                   ClusterConnectorConfig SANVolume VRTSWebApp) ];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw
        VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy VRTSvcsvr VRTScmccc
        VRTScmcs VRTSacclib52 VRTScscm VRTSweb VRTScscw VRTScssim
        VRTSvbs61 VRTSsfmh60 VRTSvcsea61 VRTScutil VRTSjre15 VRTSvcsdc VRTSvcsmn
        VRTSvcsmg VRTSvcsag61 VRTScps61 VRTSvcs61 VRTSamf61 VRTSvxfen61
        VRTSgab61 VRTSllt61 VRTScpi VRTSvsvc SYMClma VRTSspt61
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSjre VRTSsfcpi61 VRTSperl516
        VRTSvlic32
    ) ];
    # For UXRT 5.1SP1, VRTSacclib need to be fresh on AIX and Solaris.
    $prod->{obsoleted_but_need_refresh_when_upgrade_pkgs} = [ qw(VRTSacclib52) ];

    $prod->{initfile}{llt} = '/etc/default/llt';
    $prod->{initfile}{gab} = '/etc/default/gab';
    $prod->{initfile}{vxfen} = '/etc/default/vxfen';
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{initfile}{amf} = '/etc/default/amf';

    #add for checking oracle rac crs home
    $prod->{initdir} = '/etc/init.d/';
    return;
}

sub set_onenode_cluster_sys {
    my($prod,$sys,$onenode,$enable_lgf) = @_;
    my $manifest = 'vcs-onenode.xml';
    my $fmri = 'svc:/system/vcs-onenode:default';
    my $clustervcs = 'svc:/system/vcs:default';
    my $rootpath = Cfg::opt('rootpath');
    my $smfprofile_upgrade = "$rootpath/var/svc/profile/upgrade";
    my $orig_manifest = '/var/svc/manifest/system/vcs.xml';
    if ($sys->{padv} =~ /^Sol11/m) {
        $fmri = 'svc:/system/vcs-onenode';
        $clustervcs = 'svc:/system/vcs';
    }
    $prod->set_vcs_onenode_sys($sys, $onenode, $enable_lgf);
    if ($onenode) {
        if ($rootpath) {
            $sys->cmd("echo svcadm disable -s $clustervcs >> $smfprofile_upgrade");
            $sys->cmd("echo svccfg delete $clustervcs >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/bin/rm -f /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/bin/cp /etc/VRTSvcs/conf/$manifest /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/sbin/svccfg import /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/bin/rm -f /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo svcadm enable $fmri >> $smfprofile_upgrade");
        } else {
            $sys->cmd("_cmd_svcadm disable -s $clustervcs");
            $sys->cmd("_cmd_svccfg delete $clustervcs");

            # permanently disable LGF
            unless ($enable_lgf) {
                $sys->cmd("_cmd_svcadm disable -s system/vxfen");
                $sys->cmd("_cmd_svcadm disable -s system/gab");
                $sys->cmd("_cmd_svcadm disable -s system/llt");
            }

            $sys->cmd("_cmd_rmr /var/tmp/temp_manifest");
            $sys->cmd("_cmd_cp /etc/VRTSvcs/conf/$manifest /var/tmp/temp_manifest");
            $sys->cmd("_cmd_svccfg import /var/tmp/temp_manifest");
            $sys->cmd("_cmd_rmr /var/tmp/temp_manifest");
        }
    } else {
        if ($rootpath) {
            $sys->cmd("echo svcadm disable -s $fmri >> $smfprofile_upgrade");
            $sys->cmd("echo svccfg delete $fmri >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/bin/rm -f /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/bin/cp $orig_manifest /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/sbin/svccfg import /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo /usr/bin/rm -f /var/tmp/temp_manifest >> $smfprofile_upgrade");
            $sys->cmd("echo svcadm enable $clustervcs >> $smfprofile_upgrade");
        } else {
            $sys->cmd("_cmd_svcadm disable -s $fmri");
            $sys->cmd("_cmd_svccfg delete $fmri");
            $sys->cmd("_cmd_rmr /var/tmp/temp_manifest");
            $sys->cmd("_cmd_cp $orig_manifest /var/tmp/temp_manifest");
            $sys->cmd("_cmd_svccfg import /var/tmp/temp_manifest");
            $sys->cmd("_cmd_rmr /var/tmp/temp_manifest");
        }
    }
    return 1;
}

sub enable_vcs_services_after_reboot_sys {
    my ($prod,$sys) = @_;
    my ($rootpath,$smfprofile_upgrade,@vcs_smfs,$cfg);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath')||'';
    $smfprofile_upgrade = "$rootpath/var/svc/profile/upgrade";
    @vcs_smfs=();
    if ($cfg->{vcs_allowcomms}) {
        @vcs_smfs = qw(llt gab);
        if ($sys->exists("$rootpath$prod->{vxfenmode}") ||
            $sys->exists("$rootpath$prod->{vxfendg}")) {
            push @vcs_smfs, 'vxfen';
        }
    }
    push @vcs_smfs, 'amf';
    if ($cfg->{vcs_allowcomms}) {
        push @vcs_smfs, 'vcs';
    } else {
        push @vcs_smfs, 'vcs-onenode';
    }
    for my $smf(@vcs_smfs) {
        $sys->cmd("echo 'svcadm enable system/$smf' >> $smfprofile_upgrade");
    }
    return 1;
}

# precheck for main.cf upgrade
sub padv_maincf_upgrade_precheck_sys {
    my ($prod,$sys,$treeref,$vcsvers) = @_;
    my ($rootpath,@grps,@grp_syslist,@reses,$res_type,$consistent,$msg);
    my ($grp_container_type,$grp_container_names,$res_container_type,$res_container_names,$sys_container,$compvers_rtn,$zone_num,$multi_zone);

    $rootpath=Cfg::opt('rootpath') || '';

    #return unless ($sys->exists($prod->{maincf}));

    # Check containerization setting in main.cf
    if ($vcsvers && (EDRu::compvers($vcsvers,'5.1') == 2) && $sys->{zone}) {
        Msg::log("Checking the zone setting informations of main.cf on $sys->{sys}");

        $compvers_rtn = EDRu::compvers($prod->{vers},'6.0.100',3);
        # Retrieve Service Group and Resource hierarchy informations from main.cf of 5.0 version
        # get group list
        @grps = Prod::VCS61::Common::dynupgrade_get_grplist($treeref);
        for my $grp_name (@grps) {
            next unless ($grp_name);

            # get resources list
            @reses = Prod::VCS61::Common::dynupgrade_get_res_from_grp($treeref, $grp_name);
            next unless (@reses);
            $zone_num=0;
            for my $res_name (@reses) {
                next unless ($res_name);
                $res_type = Prod::VCS61::Common::dynupgrade_get_restype_of_resname($treeref,$res_name);

                # Currently only support 'Zone' type
                if ($res_type eq 'Zone') {
                    $zone_num++;
                }
            }
            $sys->set_value("maincf_grp_multi_zone,$grp_name", 1) if ($zone_num > 1);
        }

        for my $grp_name (@grps) {
            next unless ($grp_name);

            # get group system list
            @grp_syslist = Prod::VCS61::Common::dynupgrade_get_systemlist_of_grpname($treeref,$grp_name);
            next unless (@grp_syslist);

            # get resources list
            @reses = Prod::VCS61::Common::dynupgrade_get_res_from_grp($treeref, $grp_name);
            next unless (@reses);

            # get group container settings
            $grp_container_type=undef;
            $grp_container_names=undef;
            $consistent=1;
            $multi_zone=defined $sys->{maincf_grp_multi_zone}{$grp_name} ? 1 : 0;

            for my $res_name (@reses) {
                next unless ($res_name);

                $res_type = Prod::VCS61::Common::dynupgrade_get_restype_of_resname($treeref,$res_name);

                # Currently only support 'Zone' type
                if ($res_type eq 'Zone') {
                    $res_container_type='Zone';
                    $res_container_names = Prod::VCS61::Common::dynupgrade_get_attrvalue_of_resname_array($treeref, $res_name, 'ZoneName');
                } else {
                    $res_container_type = Prod::VCS61::Common::dynupgrade_get_attrvalue_of_typename($treeref,$res_type,'ContainerType');
                    if ($res_container_type) {
                        $res_container_names = Prod::VCS61::Common::dynupgrade_get_attrvalue_of_resname_array($treeref, $res_name, 'ContainerName');
                    }
                }
                next unless ($res_container_type && $res_container_names && @{$res_container_names});

                # Check if container type are consistent across the group.
                # Applicable for upgrading from version before 5.1 to versions do not 
                # support ResContainerInfo attribute(Before 6.0.1)
                if ($compvers_rtn == 2 || !$multi_zone) {
                    if ($grp_container_type) {
                        if ($grp_container_type ne $res_container_type) {
                            Msg::log("ContainerType value '$res_container_type' for resource '$res_name' in group '$grp_name' is not consistent with other resources");
                            $consistent=0;
                            next;
                        }
                    } else {
                        $grp_container_type=$res_container_type;
                    }
                }

                # get container name for each system
                my %sys_containers=();
                my $allsys_container='';
                for my $res_container (@{$res_container_names}) {
                    if ($res_container=~/^(\S+)\s+-sys\s+(\S+)/) {
                        $sys_containers{$2}=$1;
                        if ($compvers_rtn != 2 && $multi_zone) {
                            $sys->set_value("maincf_res_container_name,$grp_name,$res_name,$2", $1);
                        }
                    } elsif ($res_container=~/^\s*(\S+)\s*$/) {
                        $allsys_container=$1;
                        if ($compvers_rtn != 2 && $multi_zone) {
                            $sys->set_value("maincf_res_container_name,$grp_name,$res_name", $1);
                        }
                    }
                }

                if ($allsys_container || keys %sys_containers) {
                    $sys->set_value("maincf_res_container_type,$grp_name,$res_name", $res_container_type);
                    next if ($compvers_rtn != 2 && $multi_zone);
                    for my $sysi (@grp_syslist) {
                        $sys_container= $sys_containers{$sysi} || $allsys_container || '';
                        if (defined $grp_container_names &&
                            defined $grp_container_names->{$sysi} &&
                            $sys_container ne $grp_container_names->{$sysi}) {
                            Msg::log("ContainerName value '$sys_container' for resource '$res_name' in group '$grp_name' is not consistent with other resources");
                            $consistent=0;
                        } else {
                            $grp_container_names->{$sysi}=$sys_container;
                        }
                    }
                }
            }

            if (!$consistent) {
                $msg=Msg::new("In the file '$rootpath$prod->{maincf}' on $sys->{sys}, the ContainerName and ContainerType value of all resources in group '$grp_name' are not consistent");
                $sys->push_error($msg);
            } elsif ($grp_container_names && ($compvers_rtn == 2 || !$multi_zone)) {
                $sys->set_value("maincf_grp_container_type,$grp_name", $grp_container_type) if ($grp_container_type);
                for my $sysi (@grp_syslist) {
                    $sys_container=$grp_container_names->{$sysi};
                    $sys->set_value("maincf_grp_container_name,$grp_name,$sysi", $sys_container) if ($sys_container);
                }
            }
        }
    }

    return 1;
}

# Update containerization settings to main.cf.
sub padv_maincf_upgrade_sys {
    my ($prod,$sys,$treeref_result,$treeref_newsys) = @_;
    my ($grp_name,$grp_container_name,$grp_container_type,@grp_syslist,$sysi,@grps);
    my (@reses,$res_name,$res_type,$res_container_type,$res_container_name,$container_opts);
    my ($container_settings,@container_settings);

    # Service groups with multiple zones
    for my $grp_name (sort keys %{$sys->{maincf_res_container_name}}) {
        # get group system list
        @grp_syslist = Prod::VCS61::Common::dynupgrade_get_systemlist_of_grpname($treeref_result,$grp_name);
        next unless (@grp_syslist);

        # get resources list
        @reses = Prod::VCS61::Common::dynupgrade_get_res_from_grp($treeref_result, $grp_name);
        next unless (@reses);
        for my $res_name (@reses) {
            $res_container_type=$sys->{maincf_res_container_type}{$grp_name}{$res_name};
            if($res_container_type && ($res_container_type eq 'Zone')) {
                if (ref($sys->{maincf_res_container_name}{$grp_name}{$res_name})) {
                    for my $sysi (@grp_syslist) {
                        $res_container_name = $sys->{maincf_res_container_name}{$grp_name}{$res_name}{$sysi};
                        if ($res_container_name) {
                            $container_settings.="hares -modify $res_name ResContainerInfo Name $res_container_name Type $res_container_type Enabled 1 -sys $sysi\n";
                        }
                    }
                } else {
                    $res_container_name = $sys->{maincf_res_container_name}{$grp_name}{$res_name};
                    if ($res_container_name) {
                        $container_settings.="hares -modify $res_name ResContainerInfo Name $res_container_name Type $res_container_type Enabled 1\n";
                    }
                }
            }
            $res_type = Prod::VCS61::Common::dynupgrade_get_restype_of_resname($treeref_result,$res_name);
            next if ($res_type eq 'Zone');

            $container_opts = Prod::VCS61::Common::dynupgrade_get_attrvalue_of_typename($treeref_newsys,$res_type,'ContainerOpts');
            if($res_container_type) {
                if ($res_container_type eq 'Zone') {
                    $container_settings.="hares -override $res_name ContainerOpts\nhares -modify $res_name ContainerOpts RunInContainer 1 PassCInfo 0\n"
                        if ($container_opts !~ /RunInContainer\s+1\s+PassCInfo\s+0/mx);
                } else {
                    $container_settings.="hares -override $res_name ContainerOpts\nhares -modify $res_name ContainerOpts RunInContainer 0 PassCInfo 1\n"
                        if ($container_opts !~ /RunInContainer\s+0\s+PassCInfo\s+1/mx);
                }
            } else {
                $container_settings.="hares -override $res_name ContainerOpts\nhares -modify $res_name ContainerOpts RunInContainer 0 PassCInfo 0\n"
                    if ($container_opts =~ /RunInContainer\s+\d+\s+PassCInfo\s+\d+/mx);
            }
        }
    }
    # Service groups with only 1 zone
    for my $grp_name (sort keys %{$sys->{maincf_grp_container_name}}) {
        next unless ($sys->{maincf_grp_container_name}{$grp_name});
        next unless Prod::VCS61::Common::dynupgrade_get_node_from_tree($treeref_result,'GRP',$grp_name);
        @grp_syslist = Prod::VCS61::Common::dynupgrade_get_systemlist_of_grpname($treeref_result,$grp_name);
        next unless (@grp_syslist);

        for my $sysi (@grp_syslist) {
            $grp_container_name = $sys->{maincf_grp_container_name}{$grp_name}{$sysi};
            $grp_container_type = $sys->{maincf_grp_container_type}{$grp_name};

            next unless ($grp_container_type && $grp_container_name);

            my $tmp_cmds = "hagrp -modify $grp_name ContainerInfo Type $grp_container_type Name $grp_container_name Enabled 1 -sys $sysi\n";
            # if os upgraded, CPI will use hacf of PBE, and following new attr will make the old hacf fail
            # so the cmds will be print to user
            if (Cfg::opt('rootpath') && $sys->{osupgraded}) {
                $sys->{dyn_manual_cmd_lu} .= $tmp_cmds;
            } else {
                $container_settings.=$tmp_cmds;
            }
        }

        # get resources list
        @reses = Prod::VCS61::Common::dynupgrade_get_res_from_grp($treeref_result, $grp_name);
        for my $res_name (@reses) {
            $res_type = Prod::VCS61::Common::dynupgrade_get_restype_of_resname($treeref_result,$res_name);
            next if ($res_type eq 'Zone');

            $container_opts = Prod::VCS61::Common::dynupgrade_get_attrvalue_of_typename($treeref_newsys,$res_type,'ContainerOpts');
            $res_container_type=$sys->{maincf_res_container_type}{$grp_name}{$res_name};
            if($res_container_type) {
                if ($res_container_type eq 'Zone') {
                    $container_settings.="hares -override $res_name ContainerOpts\nhares -modify $res_name ContainerOpts RunInContainer 1 PassCInfo 0\n"
                        if ($container_opts !~ /RunInContainer\s+1\s+PassCInfo\s+0/mx);
                } else {
                    $container_settings.="hares -override $res_name ContainerOpts\nhares -modify $res_name ContainerOpts RunInContainer 0 PassCInfo 1\n"
                        if ($container_opts !~ /RunInContainer\s+0\s+PassCInfo\s+1/mx);
                }
            } else {
                $container_settings.="hares -override $res_name ContainerOpts\nhares -modify $res_name ContainerOpts RunInContainer 0 PassCInfo 0\n"
                    if ($container_opts =~ /RunInContainer\s+\d+\s+PassCInfo\s+\d+/mx);
            }
        }
    }
    Msg::log("Upgrade main.cmd for user configuration: $container_settings\n");
    @container_settings = split (/\n+/,$container_settings);
    $treeref_result = Prod::VCS61::Common::dynupgrade_import_lines2tree(\@container_settings, $treeref_result);
    return $treeref_result;
}

# Get netmask from OS netmask database. This is overwritten on Solaris.
sub get_netmask_by_address_from_netmasks_sys {
    my ($prod,$sys,$address) = @_;
    my (@netmasks_files,$netmask,$netmasks);
    my ($addr,$index);
    $netmask='';
    return $netmask unless $address;
    @netmasks_files = ("/etc/netmasks", "/etc/inet/netmasks");
    for my $file (@netmasks_files) {
        if ($sys->exists($file) && !$sys->is_symlink($file)) {
            $netmasks.=$sys->readfile($file);
        }
    }
    if ($netmasks) {
        for ($index=32; $index>0; $index--) {
            $addr = EDRu::netmask_base($address,$index);
            if ($netmasks =~ /^\s*$addr\s+(\S+)/mxg) {
                $netmask = $1;
                last;
            }
        }
    }
    return $netmask;
}

package Prod::VCS61::SolSparc;
@Prod::VCS61::SolSparc::ISA = qw(Prod::VCS61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(4.1.2 5.0 5.1 6.0 6.1)];
    return;
}

package Prod::VCS61::Sol11sparc;
@Prod::VCS61::Sol11sparc::ISA = qw(Prod::VCS61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10 6.1)];
    $prod->{zru_releases}=[qw(6.0.10 6.1)];
    $prod->{allpkgs}=[ qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSamf61 VRTSvcs61 VRTScps61 VRTSvcsag61 VRTSvcsea61 VRTSsfmh60 VRTSvbs61 VRTSvcswiz61) ];
    $prod->{obsoleted_but_need_refresh_when_upgrade_pkgs} = [];
    return;
}

package Prod::VCS61::Solx64;
@Prod::VCS61::Solx64::ISA = qw(Prod::VCS61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0 5.1 6.0)];
    return;
}

package Prod::VCS61::Sol11x64;
@Prod::VCS61::Sol11x64::ISA = qw(Prod::VCS61::Sol11sparc);

1;
