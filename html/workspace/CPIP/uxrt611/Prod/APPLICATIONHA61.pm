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

package Prod::APPLICATIONHA61::Common;
@Prod::APPLICATIONHA61::Common::ISA = qw(Prod);

sub init_common {
    my ($prod) = @_;
    $prod->{prod}='ApplicationHA';
    $prod->{abbr}='ApplicationHA';
    $prod->{vers}='6.1.1.000';
    $prod->{proddir}='applicationha';
    $prod->{eula}='EULA_ApplicationHA_Ux_6.1.pdf';
    $prod->{name}=Msg::new("Symantec ApplicationHA")->{msg};
    $prod->{mainpkg}='VRTSvcsvmw61';
    $prod->{bindir}='/opt/VRTSvcs/bin';
    $prod->{uuidconfig}="$prod->{bindir}/uuidconfig.pl";
    $prod->{uuidfile}='/etc/vx/.uuids/clusuuid';
    $prod->{lic_names} = ['VERITAS Cluster Server'];
    $prod->{lic_keyless_name} = 'VCS';
    $prod->{upgradevers}=[qw(6.0 6.1)];
    $prod->{zru_releases}=[qw(6.0 6.1)];
    $prod->{responsefileupgradeok} = 1;
    $prod->{upgrade_backup}= [
        '/opt/VRTSvcs/portal/admin/.xprtlaccess',
        '/opt/VRTSvcs/portal/admin/plugins/unix/conf/app.conf',
        '/opt/VRTSvcs/portal/admin/plugins/unix/conf/settings.conf',
        '/opt/VRTSvcs/portal/world/appcontrol_config_status.xml',
        '/opt/VRTSvcs/portal/world/GuestConfig.xml'
    ];
    $prod->{upgrade_backup_extra} = [
        '/etc/VRTSagents/ha/conf/Oracle/OracleTypes.cf',
        '/etc/VRTSagents/ha/conf/Db2udb/Db2udbTypes.cf',
        '/etc/VRTSvcs/conf/types.cf',
        '/etc/VRTSvcs/conf/vmwagtype.cf'
    ];
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs}=[ qw(VRTSsfmh60 VRTSvcs61 VRTSvcsag61 VRTSvcsea61 VRTSvcsvmw61 VRTSspt61 VRTSacclib52 VRTSvbs61) ];
    return;
}

# due to incident 3342461, AppHA only have english EULA
sub geteula {
    my ($prod,$lang)=@_;
    my $file="$prod->{proddir}/EULA/en/$prod->{eula}";
    return $file;
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
    return $sys->{post_upgrade_start_list};
}

sub description {
    my $msg=Msg::new("Symantec ApplicationHA is an easy-to-use solution that provides high availability for business-critical applications through application visibility and control in VMware, Solaris LDOM, IBM LPAR, and KVM environments. ApplicationHA is based on the industry-leading Symantec Cluster Server technology to provide a layer of unprecedented application protection in various virtual platforms.");
    $msg->print;
    return ;
}

sub completion_messages {
    my ($prod) = @_;
    my $cpic = Obj::cpic();
    my $web = Obj::web();
    my $failures=$cpic->failures('startfailmsg');
    if(Cfg::opt('configure','install','upgrade') && $#{$failures}<0) {
        my $msg = Msg::new("Open the URL:");
        $msg->print;
        $msg = Msg::new("https://<IP_or_Hostname>:5634/vcs/admin/application_health.html?priv=ADMIN");
        $msg->bold();
        $msg = Msg::new("in your browser to configure application monitoring.");
        $msg->print;
        if (EDRu::plat($prod->{padv}) eq 'Linux') {
            $msg = Msg::new("Check the updates to the ISV packages using the Symantec SORT web page: https://sort.symantec.com/agents. To make sure you have the latest version of the ISV package, download and install the latest package from the SORT web page.");
            $msg->print;
        }
        $msg = Msg::new("Also, if you have a Veritas Operations Manager Central Server with ApplicationHA add-on in your environment, you can configure application monitoring using the add-on.");
        $msg->print;
        if (Obj::webui()) {
            $msg = Msg::new("Open the URL: <B>https://IP_or_Hostname:5634/vcs/admin/application_health.html?priv=ADMIN</B> in your browser to configure application monitoring.\\n")->{msg};
            $msg .= Msg::new("Check the updates to ISV packages using the Symantec SORT web page: https://sort.symantec.com/agents. To make sure you have the latest version of the ISV package, download and install the latest package from the SORT web page.\\n")->{msg} if (EDRu::plat($prod->{padv}) eq 'Linux');
            $msg .= Msg::new("Also, if you have a Veritas Operations Manager Central Server with ApplicationHA add-on in your environment, you can configure ApplicationHA monitoring using the add-on.")->{msg};
            $web->web_script_form('alert', $msg);
        }
        Msg::n();
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

    $featured=$rel->feature_licensed_sys($sys, 'ApplicationHA');
    # the following two lines are added for
    # Etrack 3098108, i.e. covering -makeresponsefile option
    return $featured if ($featured>0);
    return $rel->prod_licensed_sys($sys);
}

sub configure_sys {
    my ($prod,$sys) =@_;
    my ($conf,$pids,$cfg,$edr,$msg,$exitcode);
    $cfg = Obj::cfg();
    $edr = Obj::edr();
    $prod->set_onenode_cluster_sys($sys,1);
    $prod->vcs_disable_sys($sys);
    $prod->config_uuid();

    $pids = $sys->proc_pids('/opt/VRTSsfmh/bin/xprtld');
    $conf = $sys->catfile('/etc/opt/VRTSsfmh/xprtld.conf');
    if ($conf !~ /namespaces\s+vcs/) {
        $conf = 'namespaces vcs=/opt/VRTSvcs/portal';
        $sys->appendfile($conf,'/etc/opt/VRTSsfmh/xprtld.conf');
        if (@$pids) {
            # if the process is running, dynamically add namespace
            $sys->cmd("/opt/VRTSsfmh/bin/xprtlc -l https://localhost/admin/xprtld/config/namespace/add -d namespace=vcs -d document_root=/opt/VRTSvcs/portal 2> /dev/null");
        }
        else {
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

sub vcs_backup_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(had61)) {
        $sys->proc($proci)->backup_sys($sys);
    }
    return;
}

sub vcs_restore_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(had61)) {
        $sys->proc($proci)->restore_sys($sys);
    }
    return;
}

sub vcs_disable_sys {
    my ($prod,$sys) = @_;
    for my $proci (qw(had61)) {
        $sys->proc($proci)->disable_sys($sys);
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
        unless (EDRu::inarr('VRTSsfmh60', @{$sys->{uninstallpkgs}})) {
            $sys->cmd("/opt/VRTSsfmh/adm/xprtldctrl start 2>/dev/null");
        }
    }
    return 1;
}

sub check_upgradeable_sys {
    my ($prod,$sys) = @_;
    my ($iver);
    $iver = $prod->version_sys($sys);
    return 0 unless ($iver);
    return 0 unless (EDRu::compvers($iver,$prod->{vers},4) == 2);
    $sys->set_value('appha_upgradeable', 1);
    return 1;
}

sub upgrade_configure_sys {
    my ($prod,$sys) =@_;
    $prod->vcs_restore_sys($sys);
    $prod->set_onenode_cluster_sys($sys,1);
    $prod->config_uuid();
    if ($sys->exists("/opt/VRTSagents/ha/bin/WebLogic/wls_update.pl")) {
        $sys->cmd("/opt/VRTSperl/bin/perl /opt/VRTSagents/ha/bin/WebLogic/wls_update.pl 2> /dev/null")
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

    return 1;
}

sub upgrade_postinstall_sys {
    my ($prod, $sys) = @_;
    my ($exitcode,$cfg,$edr,$msg,$maincf);
    my ($basename);
    $cfg  = Obj::cfg();
    $edr  = Obj::edr();

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
        my $rtn = $sys->cmd("/opt/VRTSvcs/bin/hacf -verify /opt/VRTSvcs/conf/configi 2> /dev/null");
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
    my $had;

    # check VCS running status
    $had = $sys->proc('had61');
    if ($had->check_sys($sys)) {
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

sub rollback_precheck_sys {
    my ($prod,$sys) = @_;
    my $had;

    $had = $sys->proc('had61');
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

package Prod::APPLICATIONHA61::Linux;
@Prod::APPLICATIONHA61::Linux::ISA = qw(Prod::APPLICATIONHA61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs61 VRTSsapnw0450 VRTSacclib52 VRTSspt61 VRTSVRTSwls51 VRTSvcswas51
        VRTSmq651 VRTSvcsvmw61 VRTSsfmh60 VRTSvcsea61 VRTSvcsag61 VRTSvcs61 VRTSvlic32 VRTSperl516
)];
    $prod->{minpkgs} = $prod->{recpkgs} = $prod->{allpkgs} = [ qw(VRTSsfmh60 VRTSvcs61 VRTSvcsag61 VRTSvcsea61 VRTSvcsvmw61 VRTSspt61 VRTSacclib52 VRTSvbs61 VRTSmq651 VRTSvcswas51 VRTSwls51 VRTSsapnw0450 VRTSjboss51 VRTSmysql51 VRTSsapcms51 VRTSsaplc50 VRTSsapwebas7150) ];
    $prod->{installonupgradepkgs} = [qw(VRTSvbs VRTSmq6 VRTSvcswas VRTSwls VRTSsapnw04 VRTSjboss VRTSmysql VRTSsapcms VRTSsaplc VRTSsapwebas71) ];
    $prod->{obsoleted_ga_release_pkgs} = [ qw(VRTSwls9) ];

    $prod->{initfile}{vcs} = '/etc/sysconfig/vcs';
    $prod->{upgradevers}=[qw(5.1 5.1.2 6.0 6.1)];
    $prod->{zru_releases}=[qw(5.1 5.1.2 6.0 6.1)];
    return;
}

sub other_requirements {
    return Msg::new("Symantec ApplicationHA can only be installed and run inside virtual machines in a KVM running Red Hat Enterprise Linux (RHEL) 6 update 3/4 or VMware virtualization environment.\nThe following VMware Servers and management clients are currently supported:\n\tVMware ESX Server version 4.1 Update 3, 5.0 Update 2, and 5.1\n\tVMware ESXi Server version 5.0 Update 2, 5.1 Update 1\n\tVMware vCenter Server version 4.1 Update 2, 5.0, and 5.1\n\tVMware vSphere Client version 4.1 Update 2, 5.0, and 5.1\n\tVMware vCenter Site Recovery Manager (SRM) 4.1, 5.0")->{msg};
}

package Prod::APPLICATIONHA61::RHEL5x8664;
@Prod::APPLICATIONHA61::RHEL5x8664::ISA = qw(Prod::APPLICATIONHA61::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(5.1 5.1.2 6.0 6.1)];
    $prod->{zru_releases}=[qw(5.1 5.1.2 6.0 6.1)];
    return;
}

package Prod::APPLICATIONHA61::RHEL6x8664;
@Prod::APPLICATIONHA61::RHEL6x8664::ISA = qw(Prod::APPLICATIONHA61::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(6.0 6.1)];
    $prod->{zru_releases}=[qw(6.0 6.1)];
    return;
}

package Prod::APPLICATIONHA61::SLES11x8664;
@Prod::APPLICATIONHA61::SLES11x8664::ISA = qw(Prod::APPLICATIONHA61::Linux);

sub init_padv {
    my ($prod) = @_;
    $prod->{upgradevers}=[qw(5.1.2 6.0 6.1)];
    $prod->{zru_releases}=[qw(5.1.2 6.0 6.1)];
    return;
}

package Prod::APPLICATIONHA61::SunOS;
@Prod::APPLICATIONHA61::SunOS::ISA = qw(Prod::APPLICATIONHA61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs61 VRTSacclib52 VRTSspt61 VRTSvcsvmw61 VRTSsfmh60 VRTSvcsea61
        VRTSvcsag61 VRTSvcs61 VRTSvlic32 VRTSperl516
)];
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

package Prod::APPLICATIONHA61::SolSparc;
@Prod::APPLICATIONHA61::SolSparc::ISA = qw(Prod::APPLICATIONHA61::SunOS);

sub other_requirements {
    return Msg::new("Symantec ApplicationHA can only be installed and run inside guest domains in an Oracle VM Server for SPARC virtualization environment.\nThe following versions are supported:\n\tOracle VM Server for SPARC 2.0 with version 7.3.0 or later\n\tOracle VM Server for SPARC 2.1 with version 7.4.0 or later")->{msg};
}

package Prod::APPLICATIONHA61::Solx64;
@Prod::APPLICATIONHA61::Solx64::ISA = qw(Prod::APPLICATIONHA61::SunOS);

package Prod::APPLICATIONHA61::AIX;
@Prod::APPLICATIONHA61::AIX::ISA = qw(Prod::APPLICATIONHA61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvbs61 VRTSacclib52 VRTSspt61 VRTSvcsvmw61 VRTSsfmh60 VRTSvcsea61
        VRTSvcsag61 VRTSvcs61 VRTSvlic32 VRTSperl516
)];
    return;
}

sub other_requirements {
    return Msg::new("Symantec ApplicationHA can only be installed and run inside managed LPARs in a IBM PowerVM virtualization environment, having:\n\tHMC 7.2.0.0 or later\n\tVIOS 2.1.3.10-FP-23 or later")->{msg};
}

package Prod::APPLICATIONHA61::HPUX;
@Prod::APPLICATIONHA61::HPUX::ISA = qw(Prod::APPLICATIONHA61::Common);

sub init_plat {
    my ($prod) = @_;
    $prod->{initfile}{vcs} = '/etc/default/vcs';
    return;
}

1;

