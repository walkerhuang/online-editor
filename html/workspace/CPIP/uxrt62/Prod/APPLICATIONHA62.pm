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

package Prod::APPLICATIONHA62::Common;
@Prod::APPLICATIONHA62::Common::ISA = qw(Prod);

sub init_common {
    my ($prod) = @_;
    $prod->{prod}='ApplicationHA';
    $prod->{abbr}='ApplicationHA';
    $prod->{vers}='6.2.0.000';
    $prod->{proddir}='applicationha';
    $prod->{eula}='EULA_ApplicationHA_Ux_6.2.pdf';
    $prod->{name}=Msg::new("Symantec ApplicationHA")->{msg};
    $prod->{mainpkg}='VRTSvcsvmw62';
    $prod->{bindir}='/opt/VRTSvcs/bin';
    $prod->{uuidconfig}="$prod->{bindir}/uuidconfig.pl";
    $prod->{uuidfile}='/etc/vx/.uuids/clusuuid';
    $prod->{lic_names} = ['VERITAS Cluster Server'];
    $prod->{lic_keyless_name} = 'VCS';
    $prod->{upgradevers}=[qw(6.0 6.1 6.2)];
    $prod->{zru_releases}=[qw(6.0 6.1 6.2)];
    $prod->{responsefileupgradeok} = 1;
    $prod->{upgrade_backup}= [
        '/opt/VRTSvcs/portal/admin/.xprtlaccess',
        '/opt/VRTSvcs/portal/admin/plugins/unix/conf/app.conf',
        '/opt/VRTSvcs/portal/admin/plugins/unix/conf/settings.conf',
        '/opt/VRTSvcs/portal/world/appcontrol_config_status.xml',
        '/opt/VRTSvcs/portal/world/GuestConfig.xml',
        '/opt/VRTSvcs/portal/admin/ConfigDetails.xml'
    ];
    $prod->{upgrade_backup_extra} = [
        '/etc/VRTSagents/ha/conf/Oracle/OracleTypes.cf',
        '/etc/VRTSagents/ha/conf/Db2udb/Db2udbTypes.cf',
        '/etc/VRTSvcs/conf/types.cf',
        '/etc/VRTSvcs/conf/vmwagtype.cf'
    ];
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}=[ qw(VRTSsfmh61 VRTSamf62 VRTSvcs62 VRTSvcsag62 VRTSvcsea62 VRTSvcsvmw62 VRTSspt62 VRTSacclib52 VRTSvbs62) ];
    $prod->{maincf}='/etc/VRTSvcs/conf/config/main.cf';
    return;
}

# due to incident 3342461, AppHA only have english EULA
sub geteula {
    my ($prod,$lang)=@_;
    my $file="$prod->{proddir}/EULA/en/$prod->{eula}";
    return $file;
}

sub cli_prod_option {
    my ($prod)=@_;
    $prod->security_menu() if (Cfg::opt('security'));
    return '';
}

sub security_system_precheck {
    my ($prod,$noexit)=@_;
    # get the system cluster configuration infomation
    my ($rel,@systems,$ayn,$conf,$failed,$msg,$sys,$sysname,$syslist);
    my ($backopt,$cpic,$cfg,$edr,$vcs);
    $cfg=Obj::cfg();
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $rel=Obj::cpic()->rel;
    my $web = Obj::web();
    $failed=0;
    while(1){
        if ($failed) {
            if (Cfg::opt('responsefile')) {
                $msg=Msg::new("An error occurred when using the responsefile");
                $msg->die;
            }
            if (Cfg::opt('security')) {
                $msg=Msg::new("Would you like to configure secure mode on another system?");
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
                $msg = Msg::new("Enter the system name of ApplicationHA");
                $cfg->{systems} = $web->web_script_form("selectSystem", $msg);
                $sysname=${$cfg->{systems}}[0];
            } else {
                do {
                    if (Cfg::opt('security')) {
                        $msg=Msg::new("Enter the name of the system to configure secure mode:");
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

        $vcs=Obj::cpic()->prod("VCS62");
        next if (!$vcs->check_prod_install_sys($sys));
        $conf=$vcs->get_config_sys($sys);
        if ($conf) {
            @systems=@{$conf->{systems}};
        } else {
            $msg=Msg::new("Application configuration information checking failed on $sys->{sys}");
            $msg->print;
            $web->web_script_form('alert', $msg) if(Obj::webui());
            next;
        }

        Msg::title();
        my $webmsg;
        $msg=Msg::new("Application information verification:\n");
        $webmsg = $msg->{msg};
        $msg->bold;
        $syslist=join(' ', @systems);
        $msg=Msg::new("\tSystems: $syslist");
        $webmsg .= $msg->{msg};
        $msg->printn;

        if (!Cfg::opt('responsefile')) {
            if (Cfg::opt('security')) {
                $msg=Msg::new("Would you like to configure secure mode on the system?");
            }
            $ayn=$msg->ayn('y','','',$webmsg);
            Msg::n();
        } else {
            $ayn='Y';
        }
        last if ($ayn eq 'Y');
    }
    @{$cfg->{systems}}=@systems;
    push(@{$cpic->{systems}}, $sys);
    return 1;
}

sub get_applicationha_info_sys {
    my ($prod,$sys,$conf)=@_;
    my ($info,$syslist,$grouplist,$vcs);

    $vcs = Obj::cpic->prod("VCS62");
    $conf ||= $vcs->get_config_sys($sys);
    return '' unless $conf;

    $info = Msg::new("Following ApplicationHA information detected:\n");
    $syslist = join(' ',@{$conf->{systems}});
    $info->{msg} .= Msg::new("\tSystem: $syslist\n")->{msg};
    $grouplist = join(' ',@{$conf->{groups}});
    $info->{msg} .= Msg::new("\tService Groups: $grouplist\n")->{msg};
    return $info;
}

sub security_menu {
    my ($prod)=@_;
    my ($cfg,$cpic,$edr,$msg,$ayn,$sys0,$web,$info,$sec_or_fips,$option,$rtn,$vcs);

    $web = Obj::web();

    Cfg::unset_opt('install');
    $cpic=Obj::cpic();
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    $edr->{savelog} = 1;
    $cpic->{systems} ||= [];
    $vcs = $cpic->prod("VCS62");
    $edr->{systems} = $cpic->{systems};

    if (Cfg::opt('fips')) {
        $prod->{fips} = 1;
        $vcs->{fips} = 1;
        $sec_or_fips = Msg::new("security with FIPS")->{msg};
        $option = '-fips';
    } else {
        $sec_or_fips = Msg::new("secure")->{msg};
        $option = '-security';
    }
    $msg=Msg::new("The -$option option is used to enable or disable $sec_or_fips mode of a running ApplicationHA system.");
    $msg->add_summary;

    $prod->security_system_precheck();

    my $solnodes;
    if ($prod->{fips} && ($solnodes = $vcs->check_solx64_for_fips)) {
        $msg = Msg::new("The architecture is x86 of $solnodes. Security with FIPS is not supported.");
        $msg->die;
    }

    $vcs->check_prod_enabled_cluster;
    $sys0 = ${$cpic->{systems}}[0];
    $info = $prod->get_applicationha_info_sys($sys0);
    $msg = Msg::new("Note that all user configurations about this system will be deleted during transformation. The command '/opt/VRTSvcs/bin/hauser' could be used to create system user manually.\n");
    $msg->print;
    $info->{msg} .= $msg->{msg};

    $vcs->check_security_fips_conflict($sys0);
    if ($vcs->is_secure_cluster($sys0)) {
        $msg=Msg::new("Do you want to disable $sec_or_fips mode in this $prod->{abbr} system?");
        $ayn=$msg->ayny('','',$info);
        Msg::n();
        if ($ayn eq 'Y') {
            $msg = Msg::new("Symantec recommends that you install the system in secure mode. This ensures that communication between cluster components is encrypted and cluster information is visible to specified users only.");
            $msg->warning();
            my $webmsg = $msg;
            $msg = Msg::new("\n\nAre you sure that you want to disable $sec_or_fips mode on this $prod->{abbr} system?");
            $rtn = $msg->ayny('','',$webmsg);
            if ($rtn eq 'Y') {
                Msg::title();
                $msg=Msg::new("Restarting $prod->{abbr} with $sec_or_fips mode disabled:\n");
                $msg->bold;
                $msg->{msg} =~ s/[\n:]//g;
                if (Obj::webui()) {
                    $web->web_script_form('showstatus',$msg);
                    $web->{completion_instruction} = Msg::new("Disable $sec_or_fips mode");
                }
                $vcs->eat_disable('AppHA');
            }
        }
    } else {
        $msg=Msg::new("Do you want to enable $sec_or_fips mode on this $prod->{abbr} system?");
        $ayn=$msg->ayny('','',$info);
        if ($ayn eq 'Y') {
            # ask users to enter usergroups for which they want to give guest privilege
            $vcs->secureclus_usergroups_config('AppHA');
            Msg::title();
            $msg=Msg::new("Restarting $prod->{abbr} with $sec_or_fips mode enabled:\n");
            $msg->bold;
            $msg->{msg} =~ s/[\n:]//g;
            if (Obj::webui()) {
                $web->web_script_form('showstatus',$msg);
                $web->{completion_instruction} = Msg::new("Enable $sec_or_fips mode");
            }

            $vcs->{eat_enable} = 1;
            $vcs->eat_enable('AppHA');
        }
    }

    Cfg::unset_opt('configure');
    $cpic->completion();
    return;
}

sub default_systemnames {
    my ($prod) = @_;
    my ($rel,$cpic,$localsys);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    return $rel->default_systemnames if(Cfg::opt(qw(online_upgrade)));
    $localsys=$prod->localsys;
    return '' if ($localsys->{padv} ne $prod->{padv});
    return $localsys->{hostname};
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my (@post_upgrade_start_list, $ref_procs, $proc);
    $ref_procs=$prod->SUPER::stopprocs_sys($sys);
    # Check if each process is running
    # If it is running, record it, and start it after upgrade
    if (Obj::cfg('upgrade')) {
        for my $proci (@$ref_procs) {
            $proc = $sys->proc($proci);
            push (@post_upgrade_start_list, $proci) if ($proc->check_sys($sys,'prestop'));
        }
        if (@post_upgrade_start_list) {
            $sys->set_value('post_upgrade_start_list','list',@post_upgrade_start_list);
            $ref_procs = \@post_upgrade_start_list;
        } else {
            $ref_procs = [];
        }
    }
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my (@post_check_start_list);
    #e3491953:get postcheck process.
    if (Cfg::opt("postcheck") && !(defined $sys->{post_upgrade_start_list})) {
        if ($sys->proc('had62')->is_enabled_sys($sys)) {
            push (@post_check_start_list, qw(had62 CmdServer62));
        }
        if ($sys->proc('amf62')->is_enabled_sys($sys)) {
            push (@post_check_start_list, qw(amf62));
        }
        return \@post_check_start_list;
    }
    #e3503639:
    #Restore configure file, because they have been covered after install.
    $prod->vcs_restore_sys($sys);
    $prod->amf_restore_sys($sys);
    #VCS should be started after upgrade if following both conditions are met:
    #a. VCS was running before upgrade
    #b. VCS_START value is 1.
    if (!$sys->proc('had62')->is_enabled_sys($sys)
        || !EDRu::inarr('had62', @{$sys->{post_upgrade_start_list}})) {
        #either condition couldn't met, then VCS won't be started.
        $sys->{post_upgrade_start_list} = EDRu::arrdel($sys->{post_upgrade_start_list}, 'had62');
    }
    
    if (2 == EDRu::compvers($sys->{prodvers}[0] ,'6.2')) {
        #Upgrade from pre-6.2 version of product to 6.2
        #amf process should keep consistent with had process after upgrade.
        if (EDRu::inarr('had62', @{$sys->{post_upgrade_start_list}})) {
            push @{$sys->{post_upgrade_start_list}}, qw(amf62);
        }
    } else {
        #Upgrade from ApplicationHA 6.2 to future versions
        #amf process should be started if it was running initially and AMF_start value is 1.
        if (!$sys->proc('amf62')->is_enabled_sys($sys)
           || !EDRu::inarr('amf62', @{$sys->{post_upgrade_start_list}})) {
            #either condition couldn't met, then AMF won't be started.
            $sys->{post_upgrade_start_list} = EDRu::arrdel($sys->{post_upgrade_start_list}, 'amf62');
        } 
    }

    return $sys->{post_upgrade_start_list};
}

sub description {
    my $msg=Msg::new("Symantec ApplicationHA is an easy-to-use solution that provides high availability for business-critical applications through application visibility and control in VMware, Solaris LDOM, IBM LPAR, and KVM environments. ApplicationHA is based on the industry-leading Symantec Cluster Server technology to provide a layer of unprecedented application protection in various virtual platforms.");
    $msg->print;
    return ;
}

sub completion_messages {
    my ($prod) = @_;
    my ($cpic, $web, $failures, $msg, $webmsg);
    $cpic = Obj::cpic();
    $web = Obj::web();
    $failures=$cpic->failures('startfailmsg');
    
    # For install/upgrade/patchupgrade on Linux platform, the following message must be printed.
    if(Cfg::opt(qw/install upgrade patchupgrade/) && EDRu::plat($prod->{padv}) eq 'Linux') {
        $msg=Msg::new("The following VCS agent packages are not installed or upgraded by the installer:\nVRTSjboss, VRTSmq6, VRTSmysql, VRTSsapcms, VRTSsaplc, VRTSsapnw04, VRTSsapwebas71, VRTSvcswas, VRTSwls, VRTSacclib.\nSymantec recommends that you download the latest agent packages from SORT: https://sort.symantec.com/agents and upgrade to the latest version.\n");
        $msg->print;
        if (Obj::webui()) {
            $webmsg=Msg::new("The following VCS agent packages are not installed or upgraded by the installer:\\nVRTSjboss, VRTSmq6, VRTSmysql, VRTSsapcms, VRTSsaplc, VRTSsapnw04, VRTSsapwebas71, VRTSvcswas, VRTSwls, VRTSacclib.\\nSymantec recommends that you download the latest agent packages from SORT: https://sort.symantec.com/agents and upgrade to the latest version.\\n")->{msg};
        }
    }
    
    if(Cfg::opt(qw/install upgrade patchupgrade configure/) && $#{$failures}<0) {
        my $msg = Msg::new("Open the URL:");
        $msg->print;
        $msg = Msg::new("https://<IP_or_Hostname>:5634/vcs/admin/application_health.html?priv=ADMIN");
        $msg->bold();
        $msg = Msg::new("in your browser to configure application monitoring.");
        $msg->print;
        $msg = Msg::new("Also, if you have a Veritas Operations Manager Central Server with ApplicationHA add-on in your environment, you can configure application monitoring using the add-on.");
        $msg->print;
        if (Obj::webui()) {
            $webmsg .= Msg::new("Open the URL: <B>https://IP_or_Hostname:5634/vcs/admin/application_health.html?priv=ADMIN</B> in your browser to configure application monitoring.\\n")->{msg};
            $webmsg .= Msg::new("Also, if you have a Veritas Operations Manager Central Server with ApplicationHA add-on in your environment, you can configure ApplicationHA monitoring using the add-on.")->{msg};
        }
        Msg::n();
    }
    
    if (Obj::webui() && $webmsg) {
        $web->web_script_form('alert', $webmsg);
    }

    return;
}

sub verify_responsefile {
    my ($prod) = @_;
    return;
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel,$featured);

    $cpic = Obj::cpic();
    $rel = $cpic->rel;

    # the following two lines are for E3600803
    # APPLICATIONHA is now a valid prod level for 'vxkeyless display'
    $featured=$prod->is_vxkeyless_licensed_sys($sys);
    return $featured if ($featured);
    $featured=$rel->feature_licensed_sys($sys, 'ApplicationHA');
    # the following two lines are added for
    # Etrack 3098108, i.e. covering -makeresponsefile option
    return $featured if ($featured>0);
    return $rel->prod_licensed_sys($sys);
}

sub is_vxkeyless_licensed_sys {
    my ($prod,$sys) = @_;
    my ($licensed);

    $licensed = "";
    $licensed = "vxkeyless" if ( $sys->{vxkeyless} &&
                                ($sys->{vxkeyless} =~ /applicationha/i));
    return $licensed;
}

sub postinstall_sys {
    my ($prod,$sys) =@_;
    my ($conf,$pids,$cfg,$edr,$msg,$exitcode);
    my ($vcs);
    $cfg = Obj::cfg();
    $edr = Obj::edr();
    $vcs=$prod->prod("VCS62");
    $prod->set_onenode_cluster_sys($sys,1);
    $prod->appha_disable_sys($sys);
    $prod->config_uuid();
    $vcs->register_extra_types() if($sys->system1);

    $pids = $sys->proc_pids('/opt/VRTSsfmh/bin/xprtld');
    $conf = $sys->catfile('/etc/opt/VRTSsfmh/xprtld.conf');
    if ($conf !~ /namespaces\s+vcs/) {
        $conf = 'namespaces vcs=/opt/VRTSvcs/portal';
        $sys->appendfile($conf,'/etc/opt/VRTSsfmh/xprtld.conf');
        if (@$pids) {
            # if the process is running, dynamically add namespace
            $sys->cmd("/opt/VRTSsfmh/bin/xprtlc -l https://localhost/admin/xprtld/config/namespace/add -d namespace=vcs -d document_root=/opt/VRTSvcs/portal 2> /dev/null");
        } else {
            $sys->cmd("/opt/VRTSsfmh/adm/xprtldctrl start 2> /dev/null");
        }
    }
    if($sys->{vmtype} eq 'vmware') {
        #$sys->cmd("_cmd_touch /opt/VRTSvcs/portal/admin/.vmware");
        if ($cfg->{sso_console_ip} && $cfg->{sso_local_username} && $cfg->{sso_local_password}) {
            $edr->{donotlog} = 1;
            $sys->cmd("/opt/VRTSvcs/portal/admin/configureSSO.pl $cfg->{sso_console_ip} $cfg->{sso_local_username} $cfg->{sso_local_password} 2> /dev/null");
            $edr->{donotlog} = 0;
            $exitcode = EDR::cmdexit();
            if ($exitcode) {
                $msg = Msg::new("WARNING: configureSSO.pl failed with exit code $exitcode.");
                $msg->log;
            }
        } else {
            $msg = Msg::new("WARNING: Missing some arguments to execute configureSSO.pl.");
            $msg->log;
        }
    } else {
        #$sys->cmd("_cmd_touch /opt/VRTSvcs/portal/admin/.nonvmware");
    }
    return;
}

sub postremove_sys {
    my ($prod,$sys) = @_;
    return 1;
}

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

sub appha_disable_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(had62 amf62)) {
        $sys->proc($proci)->disable_sys($sys);
    }
    return;
}

sub vcs_backup_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(had62)) {
        $sys->proc($proci)->backup_sys($sys);
    }
    return;
}

sub vcs_restore_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(had62)) {
        $sys->proc($proci)->restore_sys($sys);
    }
    return;
}

sub amf_backup_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(amf62)) {
        $sys->proc($proci)->backup_sys($sys);
    }
    return;
}

sub amf_restore_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(amf62)) {
        $sys->proc($proci)->restore_sys($sys);
    }
    return;
}

# why so many uuid subroutines?!! Can we combine some to one?
sub config_uuid {
    my $prod = shift;
    return -1 unless ($prod->check_uuidconfig_pl());
    return $prod->check_configure_uuid();
}

sub check_uuidconfig_pl {
    my $prod = shift;
    my ($localsys,$mediapath);
    $localsys = Obj::localsys();
    $mediapath=EDR::get('mediapath');
    # check existance of uuidconfig.pl
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
    my $prod = shift;
    my $uuid_hash=$prod->get_uuid();
    my @uuid_keys=keys(%{$uuid_hash});
    return 1 if ($#uuid_keys == 0) && ($uuid_keys[0]!~/NO_UUID/m);
    return 0;
}

#First,to check existing UUID,and then configure UUID according to the case of existing UUID.
sub check_configure_uuid {
    my $prod = shift;
    my ($rtn,$sys,$uuid_hash,$uuid_source,$uuid,$syslist,$nouuid,$uuid_count,@tmp,$cfg);
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
    my $prod = shift;
    my ($syslist,$rtn,$sys1);
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
    my $uuid=$sys->catfile($prod->{uuidfile});
    return $uuid;
}

sub copy_uuid_2sys {
    my ($prod,$sys_src,$sys_dest) = @_;
    return 0 unless($sys_src && $sys_dest);
    my $uuid=$prod->get_uuid_sys($sys_src);
    return $prod->set_uuid_2sys($sys_dest,$uuid);
}

sub set_uuid_2sys {
    my ($prod,$sys_dest,$uuid) = @_;
    my ($uuidpath,$uuidfile);
    return 0 unless($sys_dest);
    $uuidfile=$prod->{uuidfile};
    $uuidpath=$uuidfile;
    $uuidpath=~s/\/clusuuid//mg;
    $sys_dest->cmd("_cmd_mkdir -p $uuidpath 2> /dev/null");
    $sys_dest->cmd("echo $uuid > $uuidfile 2> /dev/null");
    if(EDR::cmdexit()){
        Msg::log("FAILED to set UUID to $sys_dest->{sys}");
        return 0;
    }
    return 1;
}

sub create_uuid_sys {
    my ($prod,$sys) = @_;
    my ($rsh,$hostname,$cmd);

    $hostname = ($sys->{islocal}) ? $sys->{hostname} : $sys->{sys};
    $rsh=$sys->{rsh};
    my $cmd_uuidconfig = $prod->{uuidconfig};
    if ($rsh =~/rsh/m) {
        $cmd=$cmd_uuidconfig." -cpi -rsh -clus -configure -force $hostname";
    } else {
        $cmd=$cmd_uuidconfig." -cpi -clus -configure -force $hostname";
    }
    EDR::cmd_local($cmd);
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

sub set_onenode_cluster_sys {
    my($prod,$sys, $onenode) = @_;
    my $initconf = $prod->{initfile}{vcs};
    my $conf = $sys->catfile($initconf);
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

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;

    # 1. $prod->{mainpkg}, which is VRTSvcsvmw, must be installed
    my $pkgvers = $prod->SUPER::version_sys($sys,$force_flag);
    return '' unless ($pkgvers);

    # 2. if VRTSvcsvmw version begin with 6.0 and >= 6.0.200, it should be TerraNova
    return '' if (EDRu::compvers($pkgvers, '6.0', 2) == 0 &&
                 (EDRu::compvers($pkgvers, '6.0.200', 3) != 2));

    return $pkgvers;
}

sub preremove_sys {
    my ($prod, $sys) = @_;
    my ($conf,$configfile,$pids);
    $configfile="/etc/opt/VRTSsfmh/xprtld.conf";
    $sys->cmd("/opt/VRTSvcs/bin/utils/remove_ip 2>/dev/null");

    # remove the 'namespace vcs' line from /etc/opt/VRTSsfmh/xprtld.conf
    $conf = $sys->catfile($configfile);
    if ($conf =~ /^\s*namespaces\s+vcs=/mx) {
        $conf =~ s/^\s*namespaces\s+vcs=.*//mx;
        $sys->writefile($conf,$configfile);
    }

    # if xprtld is running, dynamically remove namespace vcs
    $pids = $sys->proc_pids("/opt/VRTSsfmh/bin/xprtld");
    if(@$pids) {
        $sys->cmd("/opt/VRTSsfmh/bin/xprtlc -l https://localhost/admin/xprtld/config/namespace/remove -d namespace=vcs 2>/dev/null");
    } else {
        # if xprtld is not running but VRTSsfmh will not be uninstalled
        # manually start xprtld
        unless (EDRu::inarr('VRTSsfmh61', @{$sys->{uninstallpkgs}})) {
            $sys->cmd("/opt/VRTSsfmh/adm/xprtldctrl start 2>/dev/null");
        }
    }
    return 1;
}

sub check_upgradeable_sys {
    my ($prod,$sys) = @_;
    my ($vcs,$conf,$iver);
    $iver = $prod->version_sys($sys);
    return 0 if (!$iver || EDRu::compvers($iver,$prod->{vers},4) == 1);
    # Currently we use VCS's get_config_sys, even though it will perform some unnecessary checks(LLT/clustersystems etc)
    # But we'll also get the correct result for AppHA configurations.
    $vcs=$prod->prod("VCS62");
    $conf=$vcs->get_config_sys($sys);
    return 0 if (!$conf);
    $sys->set_value('appha_upgradeable', 1);
    return 1;
}

#AMF_START and AMF_STOP status should be consistent with VCS separately.
sub set_amf_consistent_with_vcs {
    my ($prod,$sys) = @_;

    for my $argu (qw(START STOP)) {
        if ($sys->proc('had62')->is_enabled_sys($sys, $argu)) {
            $sys->proc('amf62')->enable_sys($sys, $argu);        
        } else {
            $sys->proc('amf62')->disable_sys($sys, $argu);        
        }
    }

    return 1;
}

sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($vcs,$had);

    # check VCS running status
    $had = $sys->proc('had62');
    $vcs=$prod->prod("VCS62");
    if ($had->check_sys($sys)) {
        $sys->set_value('prod_running',1);
    }
    # check if vcs has vaild configurations and could be upgrade
    $prod->check_upgradeable_sys($sys) unless ($sys->{appha_upgradeable});
    if ($sys->{appha_upgradeable}) {
        $vcs->register_extra_types() if ($sys->system1); 
        $vcs->maincf_upgrade_precheck_sys($sys);
    } 
    return 1;
}

sub upgrade_configure_sys {
    my ($prod,$sys) =@_;
    my ($amf,$vcs);
    $prod->vcs_restore_sys($sys);
    
    #3503639:the release which lower then 6.2 won't have amf package
    if (2 == EDRu::compvers($sys->{prodvers}[0],'6.2')) {
        #Upgrade from pre-6.2 version of product to 6.2
        #The status of amf configuration should be consistent with vcs.
        $prod->set_amf_consistent_with_vcs($sys);
    } else {
        #Upgrade from ApplicationHA 6.2 to future versions
        #Keep consistent with the status before upgrade.
        $prod->amf_restore_sys($sys);
    }

    $prod->set_onenode_cluster_sys($sys,1);
    $prod->config_uuid();
    if ($sys->exists("/opt/VRTSagents/ha/bin/WebLogic/wls_update.pl")) {
        $sys->cmd("/opt/VRTSperl/bin/perl /opt/VRTSagents/ha/bin/WebLogic/wls_update.pl 2> /dev/null")
    }

    if ($sys->{appha_upgradeable}) {
        # dynamic upgrade
        $vcs=$prod->prod("VCS62");
        $vcs->dynupgrade_upgrade_sys($sys);
    }
    return 1;
}

sub check_config {
    my ($prod,$sys)=@_;
    my ($maincf,$str,$num,$system);
    my $rootpath = Cfg::opt('rootpath') || '';

    $maincf = "$rootpath$prod->{maincf}";
    if (!$sys->exists($maincf)) {
        Msg::log("$maincf not exists on $sys->{sys}");
        return 0;
    }

    $str = $sys->cmd("_cmd_grep '^cluster' $maincf 2> /dev/null");
    # get cluster name
    if ($str =~ /^cluster\s+(\S+)\s*/mx) {
        Msg::log("cluster $1 defined in $maincf on $sys->{sys}");
    } else {
        Msg::log("No cluster defined in $maincf on $sys->{sys}");
        return 0;
    }

    # get cluster systems
    $num = 0;
    $str = $sys->cmd("_cmd_grep '^system' $maincf 2> /dev/null");
    for my $system (split(/\n/,$str)) {
        next unless ($system =~ /^system\s+(\S+)\s*/mx);
        $system = $1;
        $system =~ s/"(.*)"/$1/m; # remove double quote
        Msg::log("System $system defined in $maincf on $sys->{sys}");
        $num ++;
    }
    if (0 == $num) { # no system defined
        Msg::log("No system defined in $maincf on $sys->{sys}");
        return 0;
    }

    return 1;
}

sub upgrade_preremove_sys {
    my ($prod, $sys) = @_;
    my ($edr, $pids);
    $edr = Obj::edr();
    $sys->mkdir("$edr->{tmpdir}/backup/config");

    # Backup AppHA configure files
    for my $backup (@{$prod->{upgrade_backup}}) {
        if ($sys->exists("$backup")) {
            $sys->copyfile("$backup", "$edr->{tmpdir}/backup/");
        }
    }

    # Backup VCS configure files
    $sys->copyfile("/etc/VRTSvcs/conf/config/*", "$edr->{tmpdir}/backup/config/");
    $prod->vcs_backup_sys($sys);

    # Backup AMF configure files
    $prod->amf_backup_sys($sys);

    return 1;
}

sub upgrade_postinstall_sys {
    my ($prod, $sys) = @_;
    my ($exitcode,$cfg,$edr,$msg,$maincf);
    my ($basename,$vcs);
    $cfg  = Obj::cfg();
    $edr  = Obj::edr();
    $vcs=$prod->prod("VCS62");
    $vcs->register_extra_types() if($sys->system1);

    # Recover the files previously backed up
    for my $backup (@{$prod->{upgrade_backup}}) {
        $basename=EDRu::basename($backup);
        if ($sys->exists("$edr->{tmpdir}/backup/$basename")) {
            $sys->copyfile("$edr->{tmpdir}/backup/$basename", $backup);
        }
    }
    $sys->copyfile("$edr->{tmpdir}/backup/config/*", "/etc/VRTSvcs/conf/config/");

    # Porting from AppHA 6.0
    for my $backup (@{$prod->{upgrade_backup_extra}}) {
        if ($sys->exists("$backup")) {
            $sys->copyfile("$backup", "/etc/VRTSvcs/conf/config/");
        }
    }

    $maincf = $sys->readfile("$edr->{tmpdir}/backup/config/main.cf");
    if($maincf =~ /VRTSWebApp|SANVolume|Scsi3PR/) {
        $msg = Msg::new("WARNING: VRTSWebApp, SANVolume, and Scsi3PR are obsoleted resource types, please remove them from the main.cf on $sys->{hostname}");
        $msg->log;
        $sys->set_value('maincf',$msg->msg);
    } else {
        my $rtn = $sys->cmd("/opt/VRTSvcs/bin/hacf -verify /opt/VRTSvcs/conf/config 2> /dev/null");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("WARNING: main.cf on $sys->{hostname} is not valid:\n$rtn\nFix the errors, and verify the main.cf file before running \'/opt/VRTSvcs/binhacf -verify /opt/VRTSvcs/conf/config\'");
            $msg->log;
            $sys->set_value('maincf', $msg->msg);
        }
    }

    if($sys->exists("/opt/VRTSagents/ha/bin/WebLogic/wls_update.pl 2> /dev/null")){
        $sys->cmd("/opt/VRTSperl/bin/perl /opt/VRTSagents/ha/bin/WebLogic/wls_update.pl 2> /dev/null")
    }
    $sys->cmd("/opt/VRTSvcs/portal/admin/settings_upgrade.pl $edr->{tmpdir}/backup/settings.conf 2> /dev/null");
    $exitcode = EDR::cmdexit();
    if ($exitcode) {
        $msg = Msg::new("WARNING: settings_upgrade.pl failed with exit code $exitcode.");
        $msg->log;
    }
    if ($cfg->{sso_console_ip} && $cfg->{sso_local_username} && $cfg->{sso_local_password}) {
        $edr->{donotlog} = 1;

        $sys->cmd("/opt/VRTSvcs/portal/admin/configureSSO.pl $cfg->{sso_console_ip} $cfg->{sso_local_username} $cfg->{sso_local_password} 2> /dev/null");
        $edr->{donotlog} = 0;
        $exitcode = EDR::cmdexit();
        if ($exitcode) {
            $msg = Msg::new("WARNING: configureSSO.pl failed with exit code $exitcode.");
            $msg->log;
        }
    }

    return 1;
}

sub upgrade_poststart_sys {
    my ($prod,$sys) = @_;
    $sys->cmd("/opt/VRTSvcs/portal/admin/synchronize_guest_config.pl 2> /dev/null");
    my $exitcode = EDR::cmdexit();
    if ($exitcode) {
        my $msg = Msg::new("WARNING: synchronize_guest_config.pl failed with exit code $exitcode.");
        $msg->log;
    }
    return 1;
}

sub patchupgrade_precheck_sys {
    my ($prod,$sys) = @_;
    return $prod->upgrade_precheck_sys($sys);
}

sub rollback_precheck_sys {
    my ($prod,$sys) = @_;
    my $had;

    $had = $sys->proc('had62');
    if ($had->check_sys($sys, 'start')) {
        $sys->set_value('prod_running',1);
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

package Prod::APPLICATIONHA62::Linux;
@Prod::APPLICATIONHA62::Linux::ISA = qw(Prod::APPLICATIONHA62::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs62 VRTSacclib52 VRTSspt62 VRTSvcsvmw62 VRTSsfmh61 VRTSvcsea62
        VRTSvcsag62 VRTSvcs62 VRTSamf62 VRTSsfcpi62 VRTSvlic32 VRTSperl516
    )];

    $prod->{initfile}{vcs} = '/etc/sysconfig/vcs';
    $prod->{initfile}{amf} = '/etc/sysconfig/amf';
    $prod->{upgradevers}=[qw(5.1 5.1.2 6.0 6.1 6.2)];
    $prod->{zru_releases}=[qw(5.1 5.1.2 6.0 6.1 6.2)];
    $prod->{installonupgradepkgs} = [qw(VRTSamf VRTSvbs)];
    $prod->{obsoleted_but_still_support_pkgs}=[qw(VRTSjboss VRTSmq6 VRTSmysql VRTSsapcms VRTSsaplc VRTSsapnw04 VRTSsapwebas71 VRTSvcswas VRTSwls)];
    return;
}

sub other_requirements {
    return Msg::new("Symantec ApplicationHA can only be installed and run inside virtual machines in a KVM running Red Hat Enterprise Linux (RHEL) 6 update 3/4 or VMware virtualization environment.\nThe following VMware Servers and management clients are currently supported:\n\tVMware ESX Server version 4.1 Update 3, 5.0 Update 2, and 5.1\n\tVMware ESXi Server version 5.0 Update 2, 5.1 Update 1\n\tVMware vCenter Server version 4.1 Update 2, 5.0, and 5.1\n\tVMware vSphere Client version 4.1 Update 2, 5.0, and 5.1\n\tVMware vCenter Site Recovery Manager (SRM) 4.1, 5.0")->{msg};
}

package Prod::APPLICATIONHA62::RHEL5x8664;
@Prod::APPLICATIONHA62::RHEL5x8664::ISA = qw(Prod::APPLICATIONHA62::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(5.1 5.1.2 6.0 6.1 6.2)];
    $prod->{zru_releases}=[qw(5.1 5.1.2 6.0 6.1 6.2)];
    return;
}

package Prod::APPLICATIONHA62::RHEL6x8664;
@Prod::APPLICATIONHA62::RHEL6x8664::ISA = qw(Prod::APPLICATIONHA62::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(6.0 6.1 6.2)];
    $prod->{zru_releases}=[qw(6.0 6.1 6.2)];
    return;
}

package Prod::APPLICATIONHA62::RHEL7x8664;
@Prod::APPLICATIONHA62::RHEL7x8664::ISA = qw(Prod::APPLICATIONHA62::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(6.2)];
    $prod->{zru_releases}=[qw(6.2)];
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}=[ qw(VRTSveki62 VRTSsfmh61 VRTSamf62 VRTSvcs62 VRTSvcsag62 VRTSvcsea62 VRTSvcsvmw62 VRTSspt62 VRTSacclib52 VRTSvbs62) ];
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs62 VRTSacclib52 VRTSspt62 VRTSvcsvmw62 VRTSsfmh61 VRTSvcsea62
        VRTSvcsag62 VRTSvcs62 VRTSamf62 VRTSveki62 VRTSsfcpi62 VRTSvlic32 VRTSperl516
    )];

    $prod->{installonupgradepkgs} = [qw(VRTSveki VRTSamf VRTSvbs)];
    return;
}

package Prod::APPLICATIONHA62::OL6x8664;
@Prod::APPLICATIONHA62::OL6x8664::ISA = qw(Prod::APPLICATIONHA62::RHEL6x8664);

package Prod::APPLICATIONHA62::OL7x8664;
@Prod::APPLICATIONHA62::OL7x8664::ISA = qw(Prod::APPLICATIONHA62::RHEL7x8664);

package Prod::APPLICATIONHA62::SLES11x8664;
@Prod::APPLICATIONHA62::SLES11x8664::ISA = qw(Prod::APPLICATIONHA62::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(5.1.2 6.0 6.1 6.2)];
    $prod->{zru_releases}=[qw(5.1.2 6.0 6.1 6.2)];
    return;
}

package Prod::APPLICATIONHA62::SunOS;
@Prod::APPLICATIONHA62::SunOS::ISA = qw(Prod::APPLICATIONHA62::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{initfile}{amf} = '/etc/default/amf';
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs62 VRTSacclib52 VRTSspt62 VRTSvcsvmw62 VRTSsfmh61 VRTSvcsea62
        VRTSvcsag62 VRTSvcs62 VRTSamf62 VRTSsfcpi62 VRTSvlic32 VRTSperl516
)];
    $prod->{installonupgradepkgs} = [qw(VRTSamf)];
    
    return;
}

sub set_onenode_cluster_sys {
    my($prod,$sys,$onenode) = @_;
    my $initconf = $prod->{initfile}{vcs};
    my $conf = $sys->catfile($initconf);
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
    my $manifest = 'vcs-onenode.xml';
    my $fmri = 'svc:/system/vcs-onenode:default';
    my $smfprofile_upgrade = "/var/svc/profile/upgrade";
    if ($onenode) {
        $sys->cmd("_cmd_cp -rp /etc/VRTSvcs/conf/$manifest /var/svc/manifest/system/$manifest 2> /dev/null");
        $sys->cmd("_cmd_svcadm disable system/vcs 2> /dev/null");
        $sys->cmd("_cmd_svccfg delete system/vcs 2> /dev/null");
        $sys->cmd("_cmd_svccfg import /var/svc/manifest/system/$manifest 2> /dev/null");
    } else {
        return 1 unless ($sys->exists("/var/svc/manifest/system/$manifest"));
        $sys->cmd("_cmd_svcadm disable -s $fmri 2> /dev/null");
        $sys->cmd("_cmd_svccfg delete $fmri 2> /dev/null");
        $sys->cmd("_cmd_rm -f /var/svc/manifest/system/$manifest 2> /dev/null");
    }
    return 1;
}

package Prod::APPLICATIONHA62::SolSparc;
@Prod::APPLICATIONHA62::SolSparc::ISA = qw(Prod::APPLICATIONHA62::SunOS);

sub other_requirements {
    return Msg::new("Symantec ApplicationHA can only be installed and run inside guest domains in an Oracle VM Server for SPARC virtualization environment.\nThe following versions are supported:\n\tOracle VM Server for SPARC 2.0 with version 7.3.0 or later\n\tOracle VM Server for SPARC 2.1 with version 7.4.0 or later")->{msg};
}

package Prod::APPLICATIONHA62::Solx64;
@Prod::APPLICATIONHA62::Solx64::ISA = qw(Prod::APPLICATIONHA62::SunOS);

package Prod::APPLICATIONHA62::AIX;
@Prod::APPLICATIONHA62::AIX::ISA = qw(Prod::APPLICATIONHA62::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}=[ qw(VRTSveki62 VRTSsfmh61 VRTSamf62 VRTSvcs62 VRTSvcsag62 VRTSvcsea62 VRTSvcsvmw62 VRTSspt62 VRTSacclib52 VRTSvbs62) ];
    $prod->{installonupgradepkgs} = [qw(VRTSveki VRTSamf)];
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{initfile}{amf} = '/etc/default/amf';
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs62 VRTSacclib52 VRTSspt62 VRTSvcsvmw62 VRTSsfmh61 VRTSvcsea62
        VRTSvcsag62 VRTSvcs62 VRTSamf62 VRTSveki62 VRTSsfcpi62 VRTSvlic32 VRTSperl516
)];        
    return;
}

sub other_requirements {
    return Msg::new("Symantec ApplicationHA can only be installed and run inside managed LPARs in a IBM PowerVM virtualization environment, having:\n\tHMC 7.2.0.0 or later\n\tVIOS 2.1.3.10-FP-23 or later")->{msg};
}

package Prod::APPLICATIONHA62::HPUX;
@Prod::APPLICATIONHA62::HPUX::ISA = qw(Prod::APPLICATIONHA62::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{initfile}{amf} = '/etc/rc.config.d/amf';
    $prod->{installonupgradepkgs} = [qw(VRTSamf)];
    return;
}

1;

