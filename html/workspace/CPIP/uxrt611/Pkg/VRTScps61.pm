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

package Pkg::VRTScps61::Common;
@Pkg::VRTScps61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTScps';
    $pkg->{name}=Msg::new("Cluster Server - Coordination Point Server")->{msg};
    $pkg->{stopprocs}=[ qw(vxcpserv61) ];
    $pkg->{cpsadm} = '/opt/VRTScps/bin/cpsadm';
    $pkg->{cpsat} = '/opt/VRTScps/bin/cpsat';
    $pkg->{defport} = '14250';
    $pkg->{default_https_port} = '443';
    $pkg->{default_cps_conf_file}='/etc/vxcps.conf';
    $pkg->{default_security} = 1;
    $pkg->{default_db_dir} = '/etc/VRTScps/db';
    $pkg->{default_ha_db_dir} = '/cpsdb';
    $pkg->{default_cred_dir} = '/var/VRTSvcs/vcsauth/data';
    $pkg->{default_ha} = 0;
    $pkg->{default_fs} = 'vxfs';
    $pkg->{device_path} = '/dev/vx/dsk';
    $pkg->{mandate_vcs} = 1;
    $pkg->{min_port} = 49152;
    $pkg->{max_port} = 65535;
    $pkg->{cpsvol_min_size} = 10;

    $pkg->{cps_process} = '/opt/VRTScps/bin/vxcpserv';
    $pkg->{cpskey} = 'AJZU-9IBB-R6XP-MZOS-I2XO-PPNP-PPPP-PPP3-P';
    $pkg->{obsolete_cpskey} = 'AJZU-WPDM-38ZY-U2T8-CP3P-PPPP-PPPP-C3GC-P';

    $pkg->{https_server_security_dir}="/var/VRTScps/security";
    $pkg->{https_server_keys_dir}    ="/var/VRTScps/security/keys";
    $pkg->{https_server_certs_dir}   ="/var/VRTScps/security/certs";
    $pkg->{time_sync} = 120;

    $pkg->{https_client_security_dir}="/var/VRTSvxfen/security";
    $pkg->{https_client_keys_dir}    ="/var/VRTSvxfen/security/keys";
    $pkg->{https_client_certs_dir}   ="/var/VRTSvxfen/security/certs";

    return;
}

# Using preremove_sys to clean up CPS DB before an uninstallation

# See e1794040 and e2802682 for details
sub preremove_sys {
    my ($pkg,$sys) = @_;
    my $cfg = Obj::cfg();
    return 1 unless (Cfg::opt('uninstall') && $cfg->{fencing_delete_client_on_cps});

    $pkg->remove_from_cps_sys($sys);
    return '';
}

sub postremove_sys {
    my ($pkg,$sys) = @_;
    my ($keyfile,$rootpath);

    return 1 unless (Cfg::opt('uninstall'));

    $rootpath = Cfg::opt('rootpath');
    $keyfile = "$rootpath/etc/vx/licenses/lic/$pkg->{cpskey}.vxlic";
    $sys->cmd("_cmd_rmr $keyfile");
    return '';
}

sub remove_from_cps_sys {
    my ($pkg,$sys) = @_;
    my ($cpssys,$vcs,$vxfenconf,$vxfenpkg);
    $vcs = $sys->prod('VCS61');
    $vxfenpkg = $sys->pkg('VRTSvxfen61');
    $vxfenconf = $vcs->get_vxfen_config_sys($sys);
    return 1 unless ($vxfenconf->{vxfen_mechanism} =~ /cps/m);

    if (!$vxfenconf->{uuid}) {
        Msg::log("UUID was not found on $sys->{sys}. Cannot remove $sys->{sys} from Coordination Point Server. Refer to the documentation for the steps of manual clean up.");
        return 1;
    }
    for my $cpsname (@{$vxfenconf->{cps}}) {
        $cpssys = $vxfenpkg->create_cps_sys($cpsname);
        # Check if we can communicate with cps
        if (!$vxfenpkg->cps_transport_sys($cpssys)) {
            Msg::log("Cannot communicate with system $cpssys->{sys} which was found to be a Coordination Point server. Cannot remove $sys->{sys} from Coordination Point Server $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
            next;
        }
        # Remove the node from CPS
        $pkg->remove_node_from_cps($sys,$cpssys,$vxfenconf);
    }
    return '';
}

sub remove_node_from_cps {
    my ($pkg,$sys,$cpssys,$vxfenconf) = @_;
    my (@cpsusers,@lines,$clusname,$cpsadm,$cpport,$nodeid,$out,$sysname,$uuid,$vcs,$vcsconf);
    $vcs = $pkg->prod('VCS61');
    $uuid = $vxfenconf->{uuid};
    $cpsadm = $pkg->{cpsadm};
    $cpport = $vxfenconf->{cpport}{"$cpssys->{sys}"};
    $sysname = $sys->{vcs_sysname};
    $vcsconf = $vcs->get_config_sys($sys);
    if (!$vcsconf) {
        Msg::log("Cannot get the cluster name on $sys->{sys}. Cannot remove $sys->{sys} from Coordination Point Server $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
        return 1;
    }
    $clusname = $vcsconf->{clustername};
    $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_nodes -p $cpport -u $uuid 2>/dev/null | _cmd_grep $clusname.*${uuid}.*$sysname\\(");
    if ($out =~ /\s+$sysname\((\d+)\)\s+(\d+)/m) {
        $nodeid = $1;
        # 1. unregister from CPS
        if ($2 eq '1') {
            Msg::log("Unregistering $sys->{sys} from CP server $cpssys->{sys}...");
            $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a unreg_node -u $uuid -n $nodeid 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::log("Cannot unregister node $sys->{sys} from CP server $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
                return 1;
            }
        }
        # 2. get the cp users for this cluster
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_users -p $cpport -c $clusname 2>/dev/null | _cmd_grep '$uuid'");
        for my $cpsuser (split (/\n/, $out)) {
            push (@cpsusers, (split(/\//m, $cpsuser))[0]);
        }

        # 3. remove node from CPS
        Msg::log("Removing node $sys->{sys} from CP server $cpssys->{sys}...");
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_node -u $uuid -c $clusname -n $nodeid 2>/dev/null");
        # 4. Check if cluster info needs to be removed
        # Remove only if all the hosts in the cluster has been removed. (Denoted by a '-' in the 'Hostname(Node ID)' field)
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a list_nodes -u $uuid 2>/dev/null");
        if ($out =~ /^$clusname\s+$uuid\s+\-\s+\-/mx) {
            Msg::log("All the nodes in the cluster $clusname has been removed, removing the cluster from CP server $cpssys->{sys}...");
            $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_clus -u $uuid 2>/dev/null");
        }

        # 5. remove user from CPS
        # Remove only if the user is not part of any cluster. (Denoted by a '-' in the 'list_users' output)
        for my $cpsuser (@cpsusers) {
            $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_users -p $cpport 2>/dev/null | _cmd_grep '$cpsuser/'");
            @lines = split (/\n/, $out);
            for my $entry (@lines) {
                # The cluster name
                $out = (split (/\s+/m, $entry))[1];
                $out = EDRu::despace($out);
                next if ($out ne '-');
                Msg::log("Removing CP user $cpsuser from CP server $cpssys->{sys}...");
                $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_user -e $cpsuser -g vx 2>/dev/null");
                if (EDR::cmdexit()) {
                    Msg::log("Cannot remove the Coordination Point client user $cpsuser from Coordination Point server $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
                    last;
                }
            }
        }
    }
    return '';
}

sub cps_cleanup_sys {
    my ($pkg,$sys,$vxfenconf,$verbose) = @_;
    my ($cpsname,$cpssys,$msg);
    my ($vcs,$vxfenpkg);
    $vcs = $sys->prod('VCS61');
    $vxfenpkg = $sys->pkg('VRTSvxfen61');

    return 1 unless ($vxfenconf->{vxfen_mechanism} =~ /cps/m);

    # Only perform cps cleaning up from the first node in each client cluster.
    return 1 unless ($sys->{system1});

    # Getting UUID to list users corresponding to the cluster
    unless ($vxfenconf->{uuid}) {
        $msg = Msg::new("UUID was not found on $sys->{sys}. Cannot complete Coordination Point Server clean up for the cluster that $sys->{sys} is in. Refer to the documentation for the steps of manual clean up.");
        $sys->push_warning($msg);
        $verbose ? $msg->warning : $msg->log;
        return 1;
    }

    for my $cpsname (@{$vxfenconf->{cps}}) {
        # Assign a Sys object to this CPS
        $cpssys = $vxfenpkg->create_cps_sys($cpsname);
        # Check if we can communicate with cps
        if (!$vxfenpkg->cps_transport_sys($cpssys)) {
            $msg=Msg::new("Cannot communicate with system $cpssys->{sys} which was found to be a Coordination Point server. Cannot complete Coordination Point Server clean up on $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
            $sys->push_warning($msg);
            $verbose ? $msg->warning : $msg->log;
            next;
        }
        if ($verbose) {
            $msg = Msg::new("Cleaning up on Coordination Point server $cpsname");
            $msg->left;
            Msg::right_done();
        }
        $pkg->cleanup_from_cps_sys($sys,$cpssys,$vxfenconf,$verbose);
    }
    return '';
}

sub cleanup_from_cps_sys {
    my ($pkg,$sys,$cpssys,$vxfenconf,$verbose) = @_;
    my ($out,$msg,$uuid,$cpsuser,$entry,$cpsadm,@out,@cpsusers,$cpport,$vcs,$vcsconf,$clusname);

    $uuid = $vxfenconf->{uuid};
    $cpsadm = $pkg->{cpsadm};
    $cpport = $vxfenconf->{cpport}{"$cpssys->{sys}"};
    $vcs = $pkg->prod('VCS61');
    $vcsconf = $vcs->get_config_sys($sys);
    $clusname = $vcsconf->{clustername};

    # Get CPS users for this cluster
    $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_users -p $cpport -c $clusname 2>/dev/null | _cmd_grep '$uuid'");
    if (EDR::cmdexit() || $out eq '') {
        $msg = Msg::new("Cannot invoke 'cpsadm' to find the Coordination Point Server users registered from $sys->{sys}.");
        $sys->push_warning($msg);
        $verbose ? $msg->warning : $msg->log;
    }
    for my $cpsuser (split (/\n/, $out)) {
        push (@cpsusers, (split(/\//m, $cpsuser))[0]);
    }

    # Ready to clean up!
    # Using UUID instead of cluster name for the former's uniqueness
    # 1. Unregister all the client nodes from CP Server
    for (my $i = 0; $i < scalar @{$sys->{cluster_systems}}; $i++) {
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a unreg_node -u $uuid -n $i 2>/dev/null");
    }

    # 2. Remove the client cluster from the CP Server
    $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_clus -u $uuid 2>/dev/null");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Cannot invoke 'cpsadm' to remove the client cluster with UUID $uuid from Coordination Point server $cpssys->{sys}. Cannot complete Coordination Point Server clean up. Refer to the documentation for the steps of manual clean up.");
        $sys->push_warning($msg);
        $verbose ? $msg->warning : $msg->log;
        return 1;
    }

    # 3. Remove all the CPClient users for communicating to CP Server
    # Remove only if the user is not part of any cluster. (Denoted by a '-' in the 'list_users' output)
    for my $cpsuser (@cpsusers) {
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_users -p $cpport 2>/dev/null | _cmd_grep '$cpsuser/'");
        @out = split (/\n/, $out);
        for my $entry (@out) {
            # The cluster name
            $out = (split (/\s+/m, $entry))[1];
            $out = EDRu::despace($out);
            next if ($out ne '-');
            $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_user -e $cpsuser -g vx 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Cannot invoke 'cpsadm' to remove the Coordination Point client user $cpsuser from Coordination Point server $cpssys->{sys}. Cannot complete Coordination Point Server clean up. Refer to the documentation for the steps of manual clean up.");
                $sys->push_warning($msg);
                $verbose ? $msg->warning : $msg->log;
                last;
            }
        }
    }
    $msg = Msg::new("Successfully done clean up from the Coordination Point Server DB on Coordination Point server $cpssys->{sys} for the cluster (UUID: $uuid).");
    $msg->log;
    return '';
}

sub get_cps_port {
    my ($pkg, $cpssys) = @_;
    my ($cps_conf_file, $vip, $output, $defport, $fqdn);

    $cps_conf_file = $pkg->{default_cps_conf_file};
    $defport = $pkg->{default_https_port};
    ($fqdn,$vip) = $cpssys->nslookup($cpssys->{sys});
    $vip = ($vip) ? $vip : $cpssys->{sys};
    $output = $cpssys->cmd("_cmd_cat $cps_conf_file 2>/dev/null");
    chomp($output);
    for my $line ( split(/\n/, $output) ) {
        if($line =~ /vip_https=\[$vip\]:(\d+)/){
            $defport = $1;
            last;
        }
        if($line =~/port_https\s*=\s*(\d+)/){
            $defport = $1;
        }
    }
    return $defport;
}

sub get_cps_db_location {
    my ($pkg, $cpssys) = @_;
    my ($cps_conf_file, $output, $dblocation);

    $cps_conf_file = $pkg->{default_cps_conf_file};
    $output = $cpssys->cmd("_cmd_cat $cps_conf_file 2>/dev/null");
    chomp($output);
    for my $line ( split(/\n/, $output) ) {
        if($line =~ /^\s*db=\s*(\S+)/m){
            $dblocation = $1;
            last;
        }    
    }    
    return $dblocation;
}

sub check_vip_port_sys {
    my ($pkg,$cpsvip,$cpsport,$sys) = @_;
    my ($cps_conf_file,$output,$defport);

    $cps_conf_file = $pkg->{default_cps_conf_file};
    $defport = $pkg->{default_https_port};
    $output = $sys->cmd("_cmd_cat $cps_conf_file 2>/dev/null");
    chomp($output);
    for my $line ( split(/\n/, $output) ) {
        if($line =~/^\s*vip_https=\[$cpsvip\]:(\d+)/){
            $defport = $1;
            last;
        }
        if($line =~/^\s*port_https\s*=\s*(\d+)/){
            $defport = $1;
        }
    }

    return "https" if ($defport eq $cpsport);
    return "ipm";
}

sub check_vip_cps_type_sys {
    my ($pkg,$cpssys) = @_;
    my ($cps_conf_file,$vip,$output,$pids);

    $cps_conf_file = $pkg->{default_cps_conf_file};

    # the ip is not for the cps
    return 'not_cps' if (!$cpssys->exists($cps_conf_file));
    # check if the process "vxcpserv" is up
    $pids = $cpssys->proc_pids('vxcpserv');
    return 'not_cps' if ($#$pids<0);

    $vip = $cpssys->{sys};
    $output=$cpssys->cmd("_cmd_grep '^ *vip' $cps_conf_file 2>/dev/null | _cmd_grep '$vip'");

    return 'not_cps_vip' unless $output;

    if ($output=~/^\s*vip_https\s*=/) {
        # this vip is for HTTPS
        return 'https_vip';
    }

    # this vip is for ipm
    return 'ipm_vip';
}

# check if the vip and port is for HTTPS
sub check_vip_port_cps_type_sys {
    my ($pkg,$cpssys,$cpsport) = @_;
    my ($vip,$output,$cpspkg,$cpsadm);

    $cpspkg = $pkg->pkg('VRTScps61');
    $vip = $cpssys->{sys};
    $cpsadm = $cpspkg->{cpsadm};

    $output = $cpssys->cmd("$cpsadm -s $vip -p $cpsport -a server_security 2>/dev/null");
    return 'https_vip_port' if ($output=~/HTTPS/mg);

    return 'not_https_vip_port';
}

sub check_cps_installed {
    my $pkg = shift;
    my ($failed,$msg,$syslist,$vers,$cpspkg,$web);
    $cpspkg = $pkg->pkg('VRTScps61');
    $web = Obj::web();

    # Check if VRTScps is installed on all the client cluster nodes or not
    $failed = 0;
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $vers = $cpspkg->version_sys($sys,1);
        if ($vers eq '') {
            $failed = 1;
            $msg = Msg::new("VRTScps does not seem to be installed on $sys->{sys}. Install it first and then try again.");
            $msg->bold;
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            Msg::prtc();
        }
    }
    return 0 if ($failed);
    return 1;
}

sub config_cps {
    my $pkg = shift;
    my ($cfg,$cpic,$edr,$web);
    my ($ayn,$menuopt,$msg,$option,$out,$ret,$sysname,$sys0,$vcs);
    my (@systems,@hosts,$config_flag,$had,$rel,$singlenode_licensed,$vmmode);

    $cpic = Obj::cpic();
    $edr = Obj::edr();
    $web = Obj::web();
    $cfg = Obj::cfg();
    $rel = Obj::rel();
    $cpic->{systems} = $edr->init_sys_objects()
        unless (($cpic->{systems}) && ($cpic->nsystems));

    return 1 if (!$pkg->check_cps_installed());

    $vcs = $pkg->prod('VCS61');
    $had = $pkg->proc('had61');
    @systems = @{CPIC::get('systems')};
    $sys0 = $systems[0];
    for my $sys(@systems) {
        $sysname = $vcs->get_vcs_sysname_sys($sys);
        $sys->{vcs_sysname} = $sysname;
    }
    $pkg->verify_responsefile() if (Cfg::opt('responsefile'));

    $menuopt = [];
    $msg = Msg::new("Configure Coordination Point Server on single node VCS system");
    push (@$menuopt,$msg->{msg});
    $msg = Msg::new("Configure Coordination Point Server on SFHA cluster");
    push (@$menuopt,$msg->{msg});
    $msg = Msg::new("Unconfigure Coordination Point Server");
    push (@$menuopt,$msg->{msg});
    while (1) {
        Msg::title();
        $config_flag = {};
        if (Cfg::opt('responsefile')) {
            $option = 1 if ($cfg->{cps_singlenode_config});
            $option = 2 if ($cfg->{cps_sfha_config});
            $option = 3 if ($cfg->{cps_unconfig});
        } else {
            if(Obj::webui()) {
                $option = $web->web_script_form('cfgcps_type');
            } else {
                $msg = Msg::new("Enter the option:");
                $option = $msg->menu($menuopt);
            }
        }
        if ($option != 3) {
            $config_flag->{singlenode_config} = 1 if ($option == 1);
            $config_flag->{sfha_config} = 1 if ($option == 2);
            return if (!$pkg->configure_precheck_sys($sys0));
            if (!$pkg->{mandate_vcs}) {
                $msg = Msg::new("Do you want to provide High Availability to the CP server using VCS?\nNote: This requires the Symantec Cluster Server to be installed and configured.");
                $ayn = $msg->ayny();
            } else {
                $ayn = 'y';
            }
            if ($ayn ne 'y') {
                $ret = $pkg->start_cpserver_process();
                return $ret;
            }

            $out = $sys0->cmd('_cmd_hasys -list -localclus 2>/dev/null');
            if (EDR::cmdexit()) {
                $msg = Msg::new("Unable to run '$vcs->{bindir}/hasys -list -localclus' on the machine.\nInstall and configure $vcs->{name} on this machine.");
                $msg->die();
            }
            chomp($out);
            @hosts = split(/\n/,$out);
            if ($#hosts > 0) {
                $config_flag->{multinode_vcs} = 1;
                if ($config_flag->{singlenode_config}) {
                    $msg = Msg::new("There is more than one node in the cluster. Please retry configuration for configuring Coordination Point Server on SFHA cluster. Please use a single node cluster if you want to configure Coordination Point Server on single node VCS system.");
                    if (Cfg::opt('responsefile')) {
                        $msg->die();
                    } else {
                        if (Obj::webui()){
                            $web->web_script_form('alert', $msg);
                        }
                        $msg->error();
                        Msg::prtc();
                        next;
                    }
                }
                $msg = Msg::new("For configuring CP server on SFHA cluster, the CP server database should reside on shared storage. Refer to documenation for information on setting up of shared storage for CP server database.");
                $msg->print;
                $web->web_script_form('alert', $msg) if (Obj::webui());
            } elsif ($#hosts == 0) {
                $config_flag->{multinode_vcs} = 0;
                if ($config_flag->{sfha_config}) {
                    $msg = Msg::new("There is a single node in the VCS cluster. Please retry configuration for configuring Coordination Point Server on single node VCS");
                    if (Cfg::opt('responsefile')) {
                        $msg->die();
                    } else {
                        if (Obj::webui()){
                            $web->web_script_form('alert', $msg);
                        }
                        $msg->error();
                        Msg::prtc();
                        next;
                    }
                }
            }
            if ($config_flag->{sfha_config}) {
                # Check if VxVM is enabled
                for my $sys(@systems) {
                    $vmmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
                    if ($vmmode !~ /enable/m) {
                        $msg=Msg::new("VM is not running on $sys->{sys}. Make sure VM is running before configuring Coordination Point Server on SFHA cluster.");
                        $msg->die();
                    }
                }
            }
            if ($config_flag->{singlenode_config}) {
                # if single node VCS and only keyless VCS license exists,
                # apply a sinlge node VCS license key (CPS key) for CP server
                # and restart had is one-node mode due to CPS key limitation.
                $singlenode_licensed = 0;
                my $no_permanent_key = 0;
                if ((CPIC::get('prod') =~ /VCS/m) && ($vcs->check_installed_ha_product_sys($sys0) eq 'VCS61')) {
                    if (!$rel->prod_permanent_licensed_sys($sys0, 'VCS61')) {
                        $msg = Msg::new("A single node coordination point server will be configured and VCS will be started in one node mode, do you want to continue?");
                        $no_permanent_key = 1;
                    } else {
                        $msg = Msg::new("A single node coordination point server will be configured, do you want to continue?");
                    }
                    Msg::n();
                    $ayn = $msg->ayny();
                    Msg::n();
                    return if ($ayn eq 'N');
                    $singlenode_licensed = $pkg->register_singlenode_cps_license_sys($sys0);
                }
                if ($no_permanent_key && $singlenode_licensed && (!$had->is_onenode_running_sys($sys0))) {
                    $vcs->stop_vcs();
                    $ret = $vcs->onenode_startup_sys($sys0);
                    if ($ret) {
                        $msg = Msg::new("Failed to start VCS in one node mode on $sys0->{sys}. Fix the issues first and retry.");
                        $msg->error();
                        return 1;
                    }
                }
            }
            for my $sys(@{CPIC::get('systems')}) {
                return if $pkg->check_and_unconfigure_cps_sys($sys);
            }
            $ret = $pkg->configure_cpserver($config_flag);
            next if (EDR::getmsgkey($ret,'back'));
        } else {
            $ret = $pkg->unconfigure_cpserver();
            next if (EDR::getmsgkey($ret,'back'));
        }
        last;
    }
    Msg::n();
    return;
}

# apply a sinlge node VCS license key for CP server
sub register_singlenode_cps_license_sys {
    my ($pkg,$sys) = @_;
    my ($cpskey,$rk);
    $cpskey = $pkg->{cpskey};

    $rk=$sys->cmd("_cmd_vxlicinst -k $cpskey");
    if ($rk=~/\bsuccessfully\b/m) {
        Msg::log("Single node cps key successfully registered on $sys->{sys}");
        $sys->cmd('_cmd_vxkeyless -q set NONE');
        return 1;
    } elsif ($rk =~ /\bDuplicate\b/m) {
        Msg::log("Duplicate single node cps key detected on $sys->{sys}");
        $sys->cmd('_cmd_vxkeyless -q set NONE');
        return 1;
    } else {
        Msg::log("Single node cps key did not successfully validate on $sys->{sys}");
    }
    return 0;
}

sub configure_cpserver {
    my ($pkg,$config_flag) = @_;
    my ($cfg,$conf,$failed,$ret,$sys0,$vcs,$web);
    my ($msg);
    $vcs = $pkg->prod('VCS61');
    $sys0 = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();
    $web = Obj::web();
    # Generate the configuration file /etc/vxcps.conf
    if (Cfg::opt('responsefile')) {
        ($ret,$conf) = $pkg->responsefile_generate_config();
    } else {
        ($ret,$conf) = $pkg->generate_config($config_flag);
    }
    return $ret if ($ret);
    Msg::prtc();
    $failed = $pkg->addto_vcs_config($conf,$config_flag);
    if ($failed) {
        $msg = Msg::new("Could not add the CPSSG service group to the VCS configuration");
        $web->{complete_failed}=1;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        $msg->error();
        return 1;
    } else {
        $msg = Msg::new("Successfully added the CPSSG service group to VCS configuration.");
        $msg->nprint;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
    }

    sleep 20;
    if ($config_flag->{sfha_config} && $conf->{cps_security}) {
        $failed = $pkg->configure_security_sfha($conf);
    }

    $failed = $pkg->https_config($config_flag,$conf);

    $sys0->cmd("$vcs->{bindir}/hagrp -online CPSSG -sys $sys0->{vcs_sysname}");
    $failed = $pkg->waitfor_cpssg_online($conf);

    Msg::n();
    if ($failed) {
        $msg = Msg::new("The Symantec coordination point server configuration did not complete successfully");
        $web->{complete_failed}=1;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
    } else {
        $msg = Msg::new("The Symantec coordination point server has been configured on your system.");
    }
    $msg->bold;
    # Save cfg variables for responsefile
    $cfg->{cps_security} = $conf->{cps_security};
    $cfg->{cps_fips_mode} = $conf->{cps_fips_mode} if (defined $conf->{cps_fips_mode});
    $cfg->{cps_singlenode_config} = $config_flag->{singlenode_config};
    $cfg->{cps_sfha_config} = $config_flag->{sfha_config};

    return;
}

#  Configure security for CP server on SFHA cluster
#  1.  Create softlink from the default location of cps credentials to shared location
#  2.  Online mount resource to mount the shared location
#  3.  Create credentials at the shared location
#  4.  Create softlinks on the other nodes of the clsuter
sub configure_security_sfha {
    my ($pkg,$conf) = @_;
    my ($cps_cred_dir,$cps_default_cred_dir,$cred_dir,$msg,$sys0,$waittime);
    my ($ayn,$cfg,$count,$create_cred,$out,$ret);
    $cfg = Obj::cfg();
    $sys0 = ${CPIC::get('systems')}[0];
    $cred_dir = $conf->{cps_db_dir};
    $cps_default_cred_dir = "$pkg->{default_cred_dir}/CPSERVER";
    $cps_cred_dir = "$cred_dir/CPSERVER";
    # Check and remove if the directory or symlink already exists at the default location
    for my $sys(@{CPIC::get('systems')}) {
        if ($sys->exists($cps_default_cred_dir)) {
            $sys->cmd("_cmd_rmr $cps_default_cred_dir");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Unable to delete $cps_default_cred_dir on $sys->{sys}");
                $msg->error();
                return 1;
            }
        }
        # Creating softlink from the default CPS credential directory to the credential directory on shared storage
        $msg = Msg::new("Creating softlink $cps_default_cred_dir to $cps_cred_dir on $sys->{sys}");
        $msg->nprint;
        $sys->cmd("_cmd_ln -s $cps_cred_dir $cps_default_cred_dir");
        if (EDR::cmdexit()) {
            Msg::n();
            $msg = Msg::new("Unable to create softlink $cps_default_cred_dir to $cps_cred_dir on $sys->{sys}");
            $msg->error();
            return 1;
        } else {
            $msg = Msg::new("Successfully created softlink $cps_default_cred_dir to $cps_cred_dir on $sys->{sys}");
            $msg->nprint;
        }
    }

    # Online mount resource on current node for SFHA cluster in secure mode
    # and generate the credentials for CP server in shared directory
    $sys0->cmd("_cmd_hares -online cpsmount -sys $sys0->{vcs_sysname}");
    ## Wait for the mount resource to come online
    ## 120 secs should be sufficient to bring the cpsmount to come online along with the parent resources
    $waittime=120;
    $msg = Msg::new("Trying to bring cpsmount resource ONLINE and will wait for upto $waittime seconds");
    $msg->nprint;
    $sys0->cmd("_cmd_hares -wait cpsmount State ONLINE -sys $sys0->{vcs_sysname} -time $waittime");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Mount resource for CPS does not come online");
        $msg->error;
        return 1;
    } else {
        $msg = Msg::new("Mount resource for CPS is ONLINE");
        $msg->print;
    }

    # Check if the credentials exist at the mount point
    $create_cred = 1;
    if ($sys0->exists($cps_cred_dir)) {
        $count = $sys0->cmd("EAT_DATA_DIR=$cps_cred_dir /opt/VRTScps/bin/cpsat showcred | _cmd_awk '/Found/ { print \$2 }'");
        if ($count > 0) {
            $out = $sys0->cmd("EAT_DATA_DIR=$cps_cred_dir /opt/VRTScps/bin/cpsat showcred");
            $msg = Msg::new("Following credentials are already present at $cps_cred_dir:\n$out");
            $msg->print;
            $msg = Msg::new("Do you want to reuse these credentials?");
            $ayn = $msg->ayny();
            $create_cred = ($ayn eq 'Y') ? 0 : 1 ;
            if (Cfg::opt('responsefile')) {
                $create_cred = ($cfg->{cps_reuse_cred}) ? 0 : 1 ;
            }
            $cfg->{cps_reuse_cred} = 1 if ($ayn eq 'Y');
        }
    }
    if ($create_cred == 1) {
        $msg = Msg::new("Creating the credentials for CP server at $cps_cred_dir");
        $msg->nprint;
        $ret = $pkg->create_cps_credential($cps_cred_dir,$conf);
        if ($ret) {
            $msg = Msg::new("Unable to create CP server credentials");
            Msg::n();
            $msg->error();
            return $ret;
        }
        $msg = Msg::new("CP server credentials successfully created");
        $msg->nprint;
    }
    return 0;
}

sub create_cps_credential {
    my ($pkg,$credential_dir,$conf) = @_;
    my ($msg,$out,$ret,$vssat,$roothash,$sys0,$vcs,$eat_env0,$eat_env);

    $vcs = $pkg->prod('VCS61');
    $vssat='/opt/VRTSvcs/bin/vcsauth/vcsauthserver/bin/vssat';
    $sys0 = ${CPIC::get('systems')}[0];
    $sys0->cmd("_cmd_mkdir -p $credential_dir");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while creating credential directory $credential_dir");
        $msg->error();
        return 1;
    }
    $eat_env0 = $vcs->eat_get_env;
    $sys0->cmd("$eat_env0 $vssat createpd -d VCS_SERVER -t ab");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while creating private domain");
        $msg->error();
        return 1;
    }
    $sys0->cmd("$eat_env0 $vssat addprpl -t ab -d VCS_SERVICES -p CPSERVER -s password");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while creating CPSERVER principal");
        $msg->error();
        return 1;
    }
    $roothash = $sys0->cmd("$eat_env0 $vssat showbrokerhash | _cmd_grep \"Root Hash\"");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while obtaining root hash");
        $msg->error();
        return 1;
    }
    $roothash=~s/^Root\s+Hash:\s+//g;
    chomp($roothash);
    $eat_env = $vcs->eat_get_env("EAT_DATA_DIR='$credential_dir'");
    $sys0->cmd("$eat_env $vssat setuptrust -s high -b 127.0.0.1:14149 -r $roothash");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while setting up trust with the root broker");
        $msg->error();
        return 1;
    }
    if ($conf->{cps_fips_mode} == 1){
    $sys0->cmd("$eat_env $vssat setfipsmode -e");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Error while setting the FIPS");
            $msg->error();
            return 1;
        }
    }

    $sys0->cmd("$eat_env $vssat authenticate -b 127.0.0.1:14149 -d vx:VCS_SERVICES -p CPSERVER -s password");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while authenticating the principal for CPSERVER");
        $msg->error();
        return 1;
    }
    $sys0->cmd("$eat_env0 $vssat deleteprpl -t ab -d VCS_SERVICES -p CPSERVER -s");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Error while deleting CPSERVER principal");
        $msg->error();
        return 1;
    }
    return 0;
}

sub waitfor_cpssg_online {
    my ($pkg,$conf) = @_;
    my ($minvips,$msg,$numvips,$ret,$vip_mintime,$waittime,$web);
    $web = Obj::web();
    my $sys0 = ${CPIC::get('systems')}[0];
    $numvips = @{$conf->{all_vips}};
    # wait for some time for the CPSSG service group to come online
    # CPSSG service group can be brought online within 80 sec time interval
    # upto 8 virtual IPs.
    # Each vip takes around 8 secs to go online, hence add 8 sec interval
    # for every vip beyond 8
    $waittime = 120;
    $minvips = 8;
    $vip_mintime = 8;
    $waittime += ($numvips - $minvips)*$vip_mintime if ($numvips > $minvips);
    $msg = Msg::new("Trying to bring CPSSG service group ONLINE and will wait for upto $waittime seconds");
    $msg->nprint;
    $web->web_script_form('alert', $msg->{msg}) if (Obj::webui());
    $sys0->cmd("_cmd_hagrp -wait CPSSG State ONLINE -sys $sys0->{vcs_sysname} -time $waittime");
    $ret = EDR::cmdexit();
    if ($ret) {
        $msg = Msg::new("The Symantec coordination point server is not ONLINE");
        $msg->nprint;
    } else {
        $msg = Msg::new("The Symantec coordination point server is ONLINE");
        $msg->nprint;
    }
    $web->web_script_form('alert', $msg->{msg}) if (Obj::webui());

    return $ret;
}

#   Take inputs from the user for generating the /etc/vxcps.conf configuration file
#   Required information:
#       CPS Name
#       CPS Port Number
#       CPS Security information
#       CPS Database location
#   Subsequently, the /etc/vxcps.conf configuration file is written.

sub generate_config {
    my ($pkg,$config_flag) = @_;
    my ($ayn,$conf,$help,$msg,$ret,$summary);
    ($ret,$conf) = $pkg->ask_cps_info($config_flag);
    return ($ret,$conf) if ($ret);
    Msg::n();
    $summary = $pkg->display_config($conf);
    Msg::n();
    $msg = Msg::new("Is this information correct?");
    $help =Msg::new("Verification of the input");
    $ayn = $msg->ayny($help,'',$summary);
    if ($ayn eq 'Y') {
        $summary->add_summary(1);
    } else {
        ($ret,$conf) = $pkg->generate_config($config_flag);
        return ($ret,$conf);
    }
    ($ret,$conf) = $pkg->update_config_file($conf);
    return ($ret,$conf);
}

sub responsefile_generate_config {
    my ($pkg) = @_;
    my ($cfg,$conf,$ret,$summary,@all_vips,@all_ports);
    $cfg = Obj::cfg();
    $conf->{cpsname} = $cfg->{cpsname};
    $conf->{vips} = $cfg->{cps_https_vips};
    $conf->{ports} = $cfg->{cps_https_ports};
    $conf->{vips_ipm} = $cfg->{cps_ipm_vips};
    $conf->{ports_ipm} = $cfg->{cps_ipm_ports};
    $conf->{cps_db_dir} = $cfg->{cps_db_dir};
    $conf->{cps_security} = $cfg->{cps_security};
    $conf->{cps_fips_mode} = $cfg->{cps_fips_mode};

    @all_vips=();
    @all_vips=@{$cfg->{cps_https_vips}} if ($cfg->{cps_https_vips});
    @all_ports=();
    @all_ports=@{$cfg->{cps_https_ports}} if ($cfg->{cps_https_ports});

    if ($cfg->{cps_ipm_vips}) {
        $conf->{cps_oldsupport} = 1;
        push @all_vips, @{$cfg->{cps_ipm_vips}};
    }
    if ($cfg->{cps_ipm_ports}) {
        $conf->{cps_oldsupport} = 1;
        push @all_ports, @{$cfg->{cps_ipm_ports}};
    }
    $conf->{all_vips}=\@all_vips;
    $conf->{all_ports}=\@all_ports;

    $summary = $pkg->display_config($conf);
    $summary->add_summary(1);
    ($ret,$conf) = $pkg->update_config_file($conf);
    return ($ret,$conf);
}

sub ask_cps_info {
    my ($pkg,$config_flag) = @_;
    my (@ports,@vips,$answer,$backopt,$conf,$cps_db_dir,$cps_security,$cpsname,$defport,$invalid,$msg,$num,$cps_fips_mode);
    my ($defopt,$sys0,$pids,$ret,$web,$result,$vcs,$sec_or_fips);
    my (@all_vips,@all_ports,$vips,$ports,$vips_ipm,$ports_ipm,$default_https_port,$cps_oldsupport);

    $sys0 = ${CPIC::get('systems')}[0];
    $vcs = $pkg->prod("VCS61");
    $backopt = 1;
    $defport = $pkg->{defport};
    $default_https_port = $pkg->{default_https_port};
    $cps_security = 0;
    $web = Obj::web();
    if(Obj::webui()) {
        $result = $web->web_script_form('configcps',$pkg,$config_flag);
        return "__back__" if ($result eq '__back__');
        $cpsname = $result->{cpsname};
        $vips = \@{$result->{vips}};
        $ports = \@{$result->{ports}};
        $vips_ipm = \@{$result->{vips_ipm}};
        $ports_ipm = \@{$result->{ports_ipm}};
        $cps_db_dir = $result->{cps_db_dir};
        $cps_oldsupport = $result->{ipm_support};

        if($cps_oldsupport) {
            $msg = Msg::new("The communication between the CP server and application clusters will be secured by HTTPS. Older application clusters (before 6.1.0) cannot use HTTPS based communication to communicate with the CP server.\nDo you want to provide security support for older application clusters?");
            Msg::n();
            $answer = $msg->ayny('',$backopt);
            return $answer if (EDR::getmsgkey($answer,'back'));
            $cps_security = ($answer eq 'Y') ?  1: 0 ;
            # Check if the AT service resource is online
            if ($cps_security) {
                unless ($vcs->is_secure_cluster($sys0)) {
                    $msg = Msg::new("Security is not configured for this cluster.");
                    $web->web_script_form('alert',$msg->{msg});
                    $web->{complete_failed} = 1;
                    $ret = 1;
                    return ($ret,$conf);
                }
                $pids=$sys0->proc_pids('vcsauthserver');
                if ($#$pids<0) {
                    $msg = Msg::new("vcsauthserver is not running on the system. Check if security is enabled for this cluster and retry");
                    $web->web_script_form('alert',$msg->{msg});
                    $web->{complete_failed} = 1;
                    $ret = 1;
                    return ($ret,$conf);
                }

                if($vcs->is_fips_cluster($sys0)) {
                    $sec_or_fips = Msg::new("security with fips")->{msg};
                    $cps_fips_mode = 1;
                } else {
                    $sec_or_fips = Msg::new("secure")->{msg};
                    $cps_fips_mode = 0;
                }
                $msg=Msg::new("CP server will be configured in $sec_or_fips mode, since the cluster is configured in this mode.");
                $web->web_script_form('alert',$msg->{msg});
            }
        }
    } else {
        Msg::n();
        $msg = Msg::new("Communication between the CP server and application clusters will always be secured by HTTPS from 6.1.0 onwards; however, older version clusters (prior to 6.1.0) using IPM-based communication will still be supported. Enter the following information to configure CPS with HTTPS support:");
        $msg->printn;

        # Getting CPS Server Name
        while (1) {
            $msg = Msg::new("Enter the name of the CP server:");
            $answer = $msg->ask('','',$backopt);
            next if (!check_systemname($answer));
            return $answer if (EDR::getmsgkey($answer,'back'));
            $cpsname = $answer;
            last;
        }

        # to ask and get the https security cps info
        ($vips,$ports) = $pkg->ask_https_cps_info();
        return $vips if (EDR::getmsgkey($vips,'back'));

#        if (!Cfg::opt('upgrade')) {
        # to ask and get the https security cps info
        $msg = Msg::new("Do you want to support older (prior to 6.1.0) clusters?");
        Msg::n();
        $answer = $msg->ayny('',$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        $cps_oldsupport = ($answer eq 'Y') ?  1: 0 ;
        if ($cps_oldsupport) {
            ($vips_ipm,$ports_ipm) = $pkg->ask_ipm_cps_info($vips,$ports);
            return $vips_ipm if (EDR::getmsgkey($vips_ipm,'back'));

            # ask if enable Security
            $msg = Msg::new("Symantec recommends secure communication between the CP server and application clusters. Enabling security requires Symantec Product Authentication Service to be installed and configured on the cluster. Do you want to enable Security for the communications?");
            Msg::n();
            $answer = $msg->ayny('',$backopt);
            return $answer if (EDR::getmsgkey($answer,'back'));
            $cps_security = ($answer eq 'Y') ?  1: 0 ;
            # Check if the AT service resource is online
            if ($cps_security) {
                unless ($vcs->is_secure_cluster($sys0)) {
                    $msg = Msg::new("Security is not configured for this cluster.");
                    $msg->error();
                    $ret = 1;
                    return ($ret,$conf);
                }

                $pids=$sys0->proc_pids('vcsauthserver');
                if ($#$pids<0) {
                    $msg = Msg::new("vcsauthserver is not running on the system. Check if security is enabled for this cluster and retry");
                    $msg->error();
                    $ret = 1;
                    return ($ret,$conf);
                }

                Msg::n();
                if($vcs->is_fips_cluster($sys0)) {
                    $sec_or_fips = Msg::new("security with fips")->{msg};
                    $cps_fips_mode = 1;
                } else {
                    $sec_or_fips = Msg::new("secure")->{msg};
                    $cps_fips_mode = 0;
                }
                $msg=Msg::new("CP server will be configured in $sec_or_fips mode, since the cluster is configured in this mode.");
                $msg->print;
                sleep(1);
            }
        }
#       }

        Msg::n();
        # Get location of CPS database
        $msg = Msg::new("CP server uses an internal database to store the client information.");
        $msg->print;
        if ($config_flag->{sfha_config}) {
            $msg = Msg::new("As the CP server is being configured on SFHA cluster, the database should reside on shared storage with vxfs file system. Refer to documentation for information on setting up of shared storage for CP server database.");
            $msg->printn;
        }
        if ($config_flag->{singlenode_config}) {
            $msg = Msg::new("As the CP server is being configured on a single node VCS, database can reside on local file system.");
            $msg->printn;
        }
        while (1) {
            if ($vcs->is_secure_cluster($sys0) && $cps_security) {
                my $oldopt = $pkg->get_cps_db_location($sys0);    
                if ($oldopt) {
                    $msg = Msg::new("If you are reconfiguring CPS and want to reuse the credentials for IPM-based communication, use the path of the database: $oldopt.");
                    $msg->printn;
                }
            } 
            $defopt = ($config_flag->{sfha_config}) ? $pkg->{default_ha_db_dir} : $pkg->{default_db_dir};
            $msg = Msg::new("Enter absolute path of the database:");
            $answer = $msg->ask($defopt,'',$backopt);
            return $answer if (EDR::getmsgkey($answer,'back'));
            next if (!$pkg->validate_cps_db_dir_name($answer));
            $cps_db_dir= $answer;
            last;
        }
    }
    @all_vips=@$vips;
    @all_ports=@$ports;
    $conf->{cpsname} = $cpsname;
    $conf->{vips} = \@$vips;
    $conf->{ports} = \@$ports;
    $conf->{cps_db_dir} = $cps_db_dir;
    $conf->{cps_security} = $cps_security;
    $conf->{cps_oldsupport} = $cps_oldsupport;
    if ($cps_oldsupport) {
        $conf->{vips_ipm} = \@$vips_ipm;
        $conf->{ports_ipm} = \@$ports_ipm;
        push @all_vips, @$vips_ipm;
        push @all_ports, @$ports_ipm;
    }
    $conf->{all_vips}=\@all_vips;
    $conf->{all_ports}=\@all_ports;
    $conf->{cps_fips_mode} = $cps_fips_mode;
    $ret = 0;
    return ($ret,$conf);
}

sub ask_https_cps_info {
    my $pkg = shift;
    my (@ports,@vips,$msg,$answer,$backopt,$invalid,$num,$default_https_port,$localsys,$edr,$ping,$help);

    $edr = Obj::edr();
    $localsys=$edr->{localsys};
    $default_https_port = $pkg->{default_https_port};
    $backopt = 1;

    Msg::n();
    # Get Virtual IP from the user
    while (1) {
        $invalid = 0;
        $msg = Msg::new("Enter Virtual IP(s) for the CP server for HTTPS, separated by a space:");
        $help = Msg::new("Communication between the CP server and application clusters will always be secured by HTTPS from 6.1.0 onwards; however, older version clusters (prior to 6.1.0) using IPM-based communication will still be supported. A CP Server can be configured with more than one virtual IP address. For HTTPS-based communication, only IPv4 addresses are supported. For IPM-based communication, both IPv4 and IPv6 addresses are supported.");
        $answer = $msg->ask('',$help,$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        #$answer = EDRu::despace($answer);
        # check if the IP is in use
        $ping = $localsys->padv->ping($answer);
        if ($ping ne "noping") {
            $msg = Msg::new("This IP is already assigned. Re-enter another IP address");
            $msg->print;
            next;
        }

        @vips = split(/\s+/, $answer);
        if (!EDRu::arr_isuniq(@vips)) {
            $msg = Msg::new("Duplicate inputs. Re-enter values");
            $msg->print;
            next;
        }
        for my $vip(@vips) {
            if (!EDRu::is_ip_valid($vip)) {
                $msg = Msg::new("$vip is not a valid IP address. Re-enter values");
                $msg->print;
                $invalid = 1;
            }
        }
        next if ($invalid);
        last;
    }

    Msg::n();
    # Get port number for CP Server
    while (1) {
        $invalid = 0;
        $msg = Msg::new("Enter the default port '$default_https_port' to be used for all the virtual IP addresses for HTTPS communication or assign the corresponding port number in the range [49152, 65535] for each virtual IP address. Ensure that each port number is separated by a single space:");
        $answer = $msg->ask($default_https_port,'',$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        #$answer = EDRu::despace($answer);
        @ports = split(/\s+/, $answer);
        for my $port(@ports) {
            if (!Pkg::VRTSvxfen61::Common::validate_cps_port($port,$default_https_port)) {
                $invalid = 1;
            }
        }
        next if ($invalid);
        if (@ports > @vips) {
            $msg = Msg::new("The number of ports is larger than the number of Virtual IPs. Re-enter values");
            $msg->print;
            next;
        } elsif (@ports != @vips) {
            $num = @vips - @ports;
            foreach(1..$num) {
                push(@ports,$default_https_port);
            }
        }
        last;
    }

    return (\@vips,\@ports);
}

sub ask_ipm_cps_info {
    my ($pkg,$vips_https,$ports_https) = @_;
    my (@ports,@vips,$msg,$answer,$backopt,$invalid,$num,$defport,$duplicate,$localsys,$edr,$ping,$help);
    my ($num_ports,$num_vips);

    $edr = Obj::edr();
    $localsys=$edr->{localsys};
    $defport = $pkg->{defport};
    $backopt = 1;

    # Get Virtual IP from the user
    while (1) {
        Msg::n();
        while (1) {
            $invalid = 0;
            $duplicate = 0;
            $msg = Msg::new("Enter Virtual IP(s) for the CP server for IPM, separated by a space:");
            $help = Msg::new("Communication between the CP server and application clusters will always be secured by HTTPS from 6.1.0 onwards; however, older version clusters (prior to 6.1.0) using IPM-based communication will still be supported. A CP Server can be configured with more than one virtual IP address. For HTTPS-based communication, only IPv4 addresses are supported. For IPM-based communication, both IPv4 and IPv6 addresses are supported.");
            $answer = $msg->ask('',$help,$backopt);
            return $answer if (EDR::getmsgkey($answer,'back'));
            #$answer = EDRu::despace($answer);
            # check if the IP is in use
            $ping = $localsys->padv->ping($answer);
            if ($ping ne "noping") {
                $msg = Msg::new("This IP is already assigned. Re-enter another IP address");
                $msg->print;
                next;
            }

            @vips = split(/\s+/, $answer);
            if (!EDRu::arr_isuniq(@vips)) {
                $msg = Msg::new("Duplicate inputs. Re-enter values");
                $msg->print;
                next;
            }

            for my $vip(@vips) {
                if (!EDRu::is_ip_valid($vip)) {
                    $msg = Msg::new("$vip is not a valid IP address. Re-enter values");
                    $msg->print;
                    $invalid = 1;
                }
            }
            next if ($invalid);
            last;
        }

        Msg::n();
        # Get port number for CP Server
        while (1) {
            $invalid = 0;
            $msg = Msg::new("Enter the default port '$defport' to be used for all the virtual IP addresses for IPM-based communication, or assign the corresponding port number in the range [49152, 65535] for each virtual IP address. Ensure that each port number is separated by a single space:");
            $answer = $msg->ask($defport,'',$backopt);
            return $answer if (EDR::getmsgkey($answer,'back'));
            #$answer = EDRu::despace($answer);
            @ports = split(/\s+/, $answer);
            for my $port(@ports) {
                if (!Pkg::VRTSvxfen61::Common::validate_cps_port($port,$defport)) {
                    $invalid = 1;
                }
            }
            next if ($invalid);

            $num_ports = scalar @ports;
            $num_vips = scalar @vips;
            if ($num_ports > $num_vips) {
                $msg = Msg::new("The number of ports is larger than the number of Virtual IPs. Re-enter values");
                $msg->print;
                next;
            } elsif ($num_ports != $num_vips) {
                $num = $num_vips - $num_ports;
                foreach(1..$num) {
                    push(@ports,$defport);
                }
            }
            last;
        }

        # to check if the ip and port of HTTPS is duplicate with the ip and port of IPM
        # and the numbers of HTTP vips may be different with IPM vips
        for (my $i = 0; $i <= scalar(@{$vips_https})-1; $i++) {
            for (my $j = 0; $j <= $num_vips-1; $j++) {
                if (($vips_https->[$i] eq $vips[$j]) && ($ports_https->[$i] == $ports[$j])) {
                    my $dupli_vip = $vips_https->[$i];
                    my $dupli_port = $ports_https->[$i];
                    $msg = Msg::new("Duplicate inputs with the HTTPS Virtual IP '$dupli_vip' and port '$dupli_port'. Re-enter values");
                    $msg->print;
                    $duplicate = 1;
                }
            }
        }

        next if ($duplicate == 1);
        last;
    }

    return (\@vips,\@ports);
}

sub ask_dg_sys {
    my ($pkg,$sys) = @_;
    my (@disks,@groups,$dglist,$dgname,$ret,$vxfen_pkg,$vxvmdisks);
    my (@multisels,@newdg_disks,$backopt,$cfg,$choice,$line,$menuopt,$msg);

    $cfg = Obj::cfg();
    $vxfen_pkg = $pkg->pkg('VRTSvxfen61');
    $dglist = $vxfen_pkg->get_dglist_sys($sys);
    @groups = @{$dglist->{diskgroups}} if (defined($dglist->{diskgroups}));
    @disks = @{$dglist->{disks}} if (defined($dglist->{disks}));
    $msg=Msg::new("Symantec recommends to use the disk group that has at least two disks on which mirrored volume can be created");
    $msg->print;
    # if there's no disk group, directly create the new one, no need ask
    if (scalar(@groups) > 0) {
        $msg = Msg::new("Select one of the options below for CP server database disk group:");
        $msg->printn;
        $msg = Msg::new("Create a new disk group");
        $menuopt = [$msg->{msg}];
        $msg = Msg::new("Using an existing disk group");
        push (@{$menuopt},$msg->{msg});
        $msg = Msg::new("Enter the choice for a disk group:");
        $choice = $msg->menu($menuopt);
    }
    if(scalar(@groups) == 0 || $choice == 1) {
        $msg=Msg::new("\nList of available disks to create a new disk group");
        $msg->print;
        while(1) {
             if(@disks<1) {
                 $msg=Msg::new("A new disk group cannot be created since no free VxVM CDS disks are available. If there are disks available which are not under VxVM control, use the command vxdisksetup or use the installer to initialize them as VxVM disks.");
                 $msg->print;
                 ($ret,$vxvmdisks) = $vxfen_pkg->init_vxvm_disks();
                 return $ret if ($ret);
                 if (@{$vxvmdisks}) {
                     @disks=@{EDRu::arruniq(@disks,@{$vxvmdisks})};
                     next;
                 } else {
                     return 1;
                 }
             }
             $menuopt=[ @disks ];
             $msg=Msg::new("Select the disks to form a disk group. Enter the disk options, separated by spaces:");
             # enable multi select and paging
             $choice=$msg->menu($menuopt,'','',$backopt,1,1);
             @multisels=@{$choice};
             if(!EDRu::arr_isuniq(@multisels)) {
                 $msg=Msg::new("Duplicate inputs. Re-enter values");
                 $msg->print;
                 next;
             }
             last;
        }
        Msg::n();
        while (1) {
            $msg=Msg::new("Enter the new disk group name:");
            $dgname=$msg->ask('','',$backopt);
            next if (!$vxfen_pkg->validate_dgname($dgname));
            last if ($vxfen_pkg->validate_diskgroup($dgname,1));
            $msg=Msg::new("Disk group name already exists. Re-enter values");
            $msg->print;
        }
        $line='';
        for $choice(@multisels) {
            $line.="$disks[$choice-1] ";
        }
        $line = EDRu::despace($line);
        @newdg_disks = split(/\s+/,$line);
        $cfg->{cps_newdg_disks} = [ @newdg_disks ];
        # create new dg
        return 1 if (!$vxfen_pkg->create_new_dg_sys($sys,$dgname,$line));
    } else {
        Msg::n();
        $dgname=$pkg->select_dg_sys($sys,$dglist);
    }
    return 1 if (!$dgname);
    return ($ret,$dgname);
}

sub select_dg_sys {
    my ($pkg,$sys,$dglist) = @_;
    my (@groups,$errormsg,$menuopt,$msg);
    my ($backopt,$choice,$dg);
    @groups=();
    for my $dg (@{$dglist->{diskgroups}}) {
        if ($dglist->{$dg}{coordinator_flag}) {
            push (@groups,"$dg(coordinator)");
        } else {
            push (@groups,$dg);
        }
    }
    $menuopt=[ @groups ];
    $msg=Msg::new("Select one disk group as CP server database disk group:");
    $choice=$msg->menu($menuopt,'','',$backopt,0,1);
    return $choice if (EDR::getmsgkey($choice,'back'));
    $dg=$groups[$choice-1];
    $dg=~s/(\S+)\(.*/$1/m;
    return $dg unless (defined($dglist->{$dg}{state}) &&
        ($dglist->{$dg}{state} eq 'deported'));
    $errormsg=$sys->cmd("_cmd_vxdg -t import $dg");
    if (EDR::cmdexit()) {
        $msg=Msg::new("Failed to import the disk group $dg on $sys->{sys}.\n\n$errormsg\n");
        $msg->print;
        $msg=Msg::new("Import the disk group and try again");
        $msg->print;
        return '';
    }
    return $dg;
}

sub ask_vol_sys {
    my ($pkg,$sys,$dgname) = @_;
    my (@vollist,$volname,$volsize);
    my ($answer,$backopt,$cfg,$choice,$menuopt,$msg,$ret);
    my (@disks,$enable_mirror,$disklist,$fs,$vm,$min_volsize,$mkret);
    $cfg = Obj::cfg();
    $fs = $pkg->prod('FS61');
    $vm = $pkg->prod('VM61');
    $min_volsize = $pkg->{cpsvol_min_size};
    @vollist = @{$pkg->get_vol_sys($sys,$dgname)};
    # if there's no volume, diretly create a new one, no need ask
    if (scalar(@vollist) > 0) {
        $msg = Msg::new("Select one of the options below for CP server database volume:");
        $msg->print;
        $msg = Msg::new("Create a new volume on disk group $dgname");
        $menuopt = [$msg->{msg}];
        $msg = Msg::new("Using an existing volume on disk group $dgname");
        push (@{$menuopt},$msg->{msg});
        $msg = Msg::new("Enter the choice for a volume:");
        $choice = $msg->menu($menuopt);
        Msg::n();
    }
    if(scalar(@vollist) == 0 || $choice == 1) {
        # enable mirroring if more than one disks in selected disk group
        $disklist = $sys->cmd("_cmd_vxdisk -g $dgname list 2> /dev/null | _cmd_grep $dgname | _cmd_awk '{print \$1}'");
        if ($disklist) {
            @disks = split(/\n/,$disklist);
            $enable_mirror = 1 if (@disks > 1);
        }
        # ask volume name and size to create new volume
        while (1) {
            $msg = Msg::new("Enter the name of volume to be created on diskgroup $dgname:");
            $answer = $msg->ask();
            next if (!$pkg->validate_dg_vol_name($answer));
            $volname = $answer;
            $msg=Msg::new("Enter the volume size (in MB):");
            $answer = $msg->ask($min_volsize);
            next if (!$pkg->validate_vol_size($min_volsize,$answer));
            $volsize = $answer;
            next if ($vm->validate_vol_sys($sys, $volname, $volsize, 0, $dgname, $enable_mirror));
            last;
        }
        $msg = Msg::new("Creating volume '$volname' for CP server database on $sys->{sys}");
        $msg->left;
        if ($enable_mirror) {
            $sys->cmd("_cmd_vxassist -g $dgname make $volname ${volsize}m layout=mirror");
        } else {
            $sys->cmd("_cmd_vxassist -g $dgname make $volname ${volsize}m");
        }
        if (EDR::cmdexit()) {
            $msg->right_failed();
            return 1;
        } else {
            $msg->right_done();
        }
        # make vxfs file system on the volume
        $mkret = $fs->make_vxfs_sys($sys,$dgname,$volname);
        Msg::log("Make fs return $mkret");
        $cfg->{cps_newvol_volsize} = $volsize;
        $cfg->{cps_enable_mirroring} = $enable_mirror;
    } else {
        $menuopt = [ @vollist ];
        $msg = Msg::new("Select one volume as CP server database volume:");
        $choice = $msg->menu($menuopt,'','',$backopt,0,1);
        return $choice if (EDR::getmsgkey($choice,'back'));
        $volname = $vollist[$choice-1];
    }
    return ($ret, $volname);
}

sub get_vol_sys {
    my ($pkg,$sys,$dgname) = @_;
    my (@vollist,$vols);
    $vols = $sys->cmd("_cmd_vxinfo -g $dgname 2>/dev/null | _cmd_awk '{print \$1}'");
    if ($vols) {
        push (@vollist,split(/\n/,$vols));
    }
    return \@vollist;
}

sub validate_vol_size {
    my ($pkg,$minsize,$volsize) = @_;
    my ($msg);
    if ($volsize =~ /\D+/m || ($volsize < 1)) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("Invalid value. Re-enter values");
            $msg->print;
        }
        return 0;
    }
    if ($volsize < $minsize) {
        $msg = Msg::new("Volume with $volsize MB should be too small for CP server database volume. Use at least $minsize MB");
        $msg->print;
        return 0;
    }
    return 1;
}

sub validate_cps_db_dir_name {
    my ($pkg,$answer) = @_;
    my ($msg,$sys);
    $sys = ${CPIC::get('systems')}[0];
    if ($answer !~ /^\/(.*)$/m) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("The path $answer is not absolute. Re-enter values");
            $msg->print;
        }
        return 0;
    }
    if ($answer =~ /\s+/m) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("The path should not contain space. Re-enter values");
            $msg->print;
        }
        return 0;
    }
    if ($sys->exists($answer) && (!$sys->is_dir($answer))) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("$answer is not a directory. Re-enter values");
            $msg->print;
        }
        return 0;
    }
    return 1;
}

sub validate_dg_vol_name {
    my ($pkg,$name) = @_;
    my ($msg);
    if ($name !~ /^\w[\w-]*$/m) {
        unless (Cfg::opt('responsefile')) {
            $msg=Msg::new("Invalid name. Re-enter values.");
            $msg->print;
        }
        return 0;
    }
    return 1;
}

sub validate_prefix_length {
    my ($pkg,$answer) = @_;
    my ($max,$min,$msg);
    $min = (EDRu::plat($pkg->{padv}) eq 'Linux') ? 0 : 1;
    $max = 128;
    if (($answer =~ /\D+/m) || ($answer < $min) || ($answer > $max)) {
        $msg = Msg::new("Invalid prefix length. Prefix length should be in range [$min, $max]");
        $msg->print;
        return 0;
    }
    return 1;
}

sub display_config {
    my ($pkg,$conf) = @_;
    my ($cps_port_list,$cps_vip_list,$cps_port_list_ipm,$cps_vip_list_ipm,$msg,$smsg);

    $cps_port_list = join(', ', @{$conf->{ports}});
    $cps_vip_list = join(', ', @{$conf->{vips}});
    if ($conf->{cps_oldsupport}) {
        $cps_port_list_ipm = join(', ', @{$conf->{ports_ipm}});
        $cps_vip_list_ipm = join(', ', @{$conf->{vips_ipm}});
    }

    Msg::title();
    $msg = Msg::new("CP server configuration verification:");
    $msg->bold;
    Msg::n();
    $msg = Msg::new("CP server Name: $conf->{cpsname}");
    $msg->print;
    $smsg .= "$msg->{msg}\n";
    $msg = Msg::new("CP server Virtual IP(s) for HTTPS: $cps_vip_list");
    $msg->print;
    $smsg .= "$msg->{msg}\n";
    if ($conf->{cps_oldsupport}) {
        $msg = Msg::new("CP server Virtual IP(s) for IPM: $cps_vip_list_ipm");
        $msg->print;
        $smsg .= "$msg->{msg}\n";
    }
    $msg = Msg::new("CP server Port(s) for HTTPS: $cps_port_list");
    $msg->print;
    $smsg .= "$msg->{msg}\n";
    if ($conf->{cps_oldsupport}) {
        $msg = Msg::new("CP server Port(s) for IPM: $cps_port_list_ipm");
        $msg->print;
        $smsg .= "$msg->{msg}\n";

        $msg = Msg::new("CP server Security for IPM: $conf->{cps_security}");
        $msg->print;
        $smsg .= "$msg->{msg}\n";
    }

    if(defined $conf->{cps_fips_mode}) {
        $msg = Msg::new("CP server FIPS mode: $conf->{cps_fips_mode}");
        $msg->print;
        $smsg .= "$msg->{msg}\n";
    }
    $msg = Msg::new("CP server Database Dir: $conf->{cps_db_dir}");
    $msg->print;
    $smsg .= "$msg->{msg}\n";

    # return the summary message
    $msg = Msg::new("CP server configuration information:\n");
    $msg->{msg} .= $smsg;
    return $msg;
}

sub update_config_file {
    my ($pkg,$conf) = @_;
    my (@hosts,$content,$cps_conf_warning,$msg,$nodeid,$nodename,$out,$ret,$sys,$sys0,$vcs);
    $vcs = $pkg->prod('VCS61');
    $cps_conf_warning = '##  The vxcps.conf file determines the configuration for Symantec CP server.';
    $sys0 = ${CPIC::get('systems')}[0];
    $content = "$cps_conf_warning\n";
    $content .= "cps_name=$conf->{cpsname}\n";

    # if customer choose to support old security policy: ipm
    if ($conf->{cps_oldsupport}) {
        for my $i(0..$#{$conf->{vips_ipm}}) {
            if (${$conf->{ports_ipm}}[$i] != $pkg->{defport}) {
                $content .= "vip=[${$conf->{vips_ipm}}[$i]]:${$conf->{ports_ipm}}[$i]\n";
            } else {
                $content .= "vip=[${$conf->{vips_ipm}}[$i]]\n";
            }
        }
    }

    for my $i(0..$#{$conf->{vips}}) {
        if (${$conf->{ports}}[$i] != $pkg->{default_https_port}) {
            $content .= "vip_https=[${$conf->{vips}}[$i]]:${$conf->{ports}}[$i]\n";
        } else {
            $content .= "vip_https=[${$conf->{vips}}[$i]]\n";
        }
    }

    # if customer choose to support old security policy: ipm
    if ($conf->{cps_oldsupport}) {
        $content .= "port=$pkg->{defport}\n";
    }

    $content .= "port_https=$pkg->{default_https_port}\n";
    $content .= "security=$conf->{cps_security}\n";
    $content .= "fips_mode=$conf->{cps_fips_mode}\n" if (defined $conf->{cps_fips_mode});
    $content .= "db=$conf->{cps_db_dir}\n";
    $content .= "ssl_conf_file=/etc/vxcps_ssl.properties\n";
    Msg::log("The contenet of the /etc/vxcps.conf is $content\n");
    $sys0->writefile($content,$pkg->{default_cps_conf_file});
    $sys0->cmd("_cmd_chmod 600 $pkg->{default_cps_conf_file} 2>/dev/null");
    Msg::n();
    $msg = Msg::new("Successfully generated the /etc/vxcps.conf configuration file");
    $msg->bold;
    Msg::n();

    if (!$sys0->exists($conf->{cps_db_dir}) || !$sys0->is_dir($conf->{cps_db_dir})) {
        $sys0->cmd("_cmd_mkdir -p $conf->{cps_db_dir}");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Unable to create directory in $conf->{cps_db_dir} on $sys0->{sys}");
            $msg->die;
        } else {
            $msg = Msg::new("Successfully created directory $conf->{cps_db_dir} on $sys0->{sys}");
            $msg->printn;
        }
    }

    if (Cfg::opt('upgrade')) {
        return ($ret,$conf);
    }

    # If this is multinode VCS, copy configuration file and create mount point on all nodes
    $out = $sys0->cmd('_cmd_hasys -list -clus localclus');
    if (EDR::cmdexit()) {
        $msg = Msg::new("Unable to run '$vcs->{bindir}/hasys -list' on $sys0->{sys}.\nInstall and configure $vcs->{name} on this machine.");
        $msg->die();
    }
    chomp($out);
    @hosts = split(/\n/,$out);
    return ($ret,$conf) if ($#hosts == 0);

    $nodeid = $sys0->cmd('_cmd_hasys -nodeid 2>/dev/null');
    if ($nodeid =~ /Node name:\s*(\S+)/m) {
        $nodename = $1;
    }
    for my $sysi(@hosts) {
        next if ($nodename eq $sysi);
        $sys=($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
        if (!$sys->exists($conf->{cps_db_dir}) || !$sys->is_dir($conf->{cps_db_dir})) {
            $msg = Msg::new("Creating mount point $conf->{cps_db_dir} on $sysi");
            $msg->left;
            $sys->cmd("_cmd_mkdir -p $conf->{cps_db_dir}");
            if (EDR::cmdexit()) {
                $msg->right_failed;
                $msg = Msg::new("Unable to create directory in $conf->{cps_db_dir} on $sysi");
                $msg->die;
            } else {
                $msg->right_done;
            }
        }
        $msg = Msg::new("Copying configuration file $pkg->{default_cps_conf_file} to $sysi");
        $msg->left;
        $sys0->copy_to_sys($sys, $pkg->{default_cps_conf_file});
        $sys->cmd("_cmd_chmod 600 $pkg->{default_cps_conf_file} 2>/dev/null");
        $msg->right_done;
    }

    return ($ret,$conf);
}

sub check_systemname {
    my $name = shift;
    my $msg;
    if ($name !~ /^[a-zA-Z0-9_-]+$/m) {
        $msg = Msg::new("$name is not a valid CP server name");
        $msg->error;
        return 0;
    }
    return 1;
}

sub addto_vcs_config {
    my ($pkg,$conf,$config_flag) = @_;
    my (@nodeid_list,@system_list,@systems,$answer,$count,$cps_blockdevice,$cps_diskgroup,$cps_volume,$msg,$out,$sys0,$validated);
    my (@cps_virtual_ip,@cps_netmasks,@cps_prefix_length,@is_ipv4_ipv6,$cps_netmask,$cps_prefix_len,$i,$j,$nic_count,$nic_same,$numnics,$numvips,$ret);
    my (%vip2nicres_map,%nics_taken_care_of,@nic_list,@nic_list_for_vip,@nic_set,@nic_set_for_system,@nicres_list,@network_hosts,@network_hosts_for_nic,$public_nics);
    my ($cfg,$defopt,$fs,$line,$nwhosts_same,$vxfen_pkg,$backopt,$networkhosts_back,$input_flag);
    @systems = @{CPIC::get('systems')};
    $sys0 = $systems[0];
    $backopt = 1;
    $fs = $pkg->prod('FS61');
    $vxfen_pkg = $pkg->pkg('VRTSvxfen61');
    $cfg = Obj::cfg();
    my $web = Obj::web();
    Msg::title();
    $msg = Msg::new("Configuring CP server Service Group (CPSSG) for this cluster");
    $msg->print;
    $out = $sys0->cmd('_cmd_hasys -list -clus localclus');
    if (EDR::cmdexit()) {
        Msg::n();
        $msg = Msg::new("Failed to list nodes of the cluster");
        $msg->error();
        return 1;
    }
    chomp($out);
    @system_list = split(/\n/,$out);
    $out = $sys0->cmd("_cmd_hasys -display | _cmd_grep -i LLTNodeId | _cmd_awk '{print \$3}'");
    chomp($out);
    @nodeid_list = split(/\n/,$out);
    $numvips = @{$conf->{all_vips}};
    $i = 0;
    foreach (@{$conf->{all_vips}}) {
        if (EDRu::ip_is_ipv4(${$conf->{all_vips}}[$i])) {
            $is_ipv4_ipv6[$i] = 0;
        } else {
            $is_ipv4_ipv6[$i] = 1;
        }
        $i++;
    }
    $conf->{is_ipv4_ipv6} = \@is_ipv4_ipv6;
    $conf->{system_list} = [ @system_list ];
    $conf->{nodeid_list} = [ @nodeid_list ];
    if (Cfg::opt('responsefile')) {
        $conf->{prefix_length} = $cfg->{cps_prefix_length} if ($cfg->{cps_prefix_length});
        $conf->{netmasks} = $cfg->{cps_netmasks} if ($cfg->{cps_netmasks});
        $conf->{vip2nicres_map} = $cfg->{cps_vip2nicres_map};
        $conf->{nicres_list} = [ @nicres_list ];
        for my $vipkey (keys %{$cfg->{cps_nic_list}}) {
            if ($vipkey =~ /cpsvip(\d+)/m) {
                $i = $1;
                $nic_list[$i-1] = $cfg->{cps_nic_list}{"$vipkey"};
            }
        }
        for my $nickey (keys %{$cfg->{cps_network_hosts}}) {
            if ($nickey =~ /cpsnic(\d+)/m) {
                $i = $1;
                $network_hosts[$i-1] = $cfg->{cps_network_hosts}{"$nickey"};
            }
        }
        $conf->{nic_list} = [ @nic_list ];
        $conf->{network_hosts} = [ @network_hosts ];
        $conf->{cps_diskgroup} = $cfg->{cps_diskgroup};
        $conf->{cps_volume} = $cfg->{cps_volume};
        $conf->{cps_blockdevice} = "$pkg->{device_path}/$conf->{cps_diskgroup}/$conf->{cps_volume}";
        if ($cfg->{cps_newdg_disks}) {
            # create new diskgroup
            $line = join(' ', @{$cfg->{cps_newdg_disks}});
            return 1 if (!$vxfen_pkg->create_new_dg_sys($sys0,$conf->{cps_diskgroup},$line));
        }
        if ($cfg->{cps_newvol_volsize}) {
            $msg = Msg::new("Creating volume '$conf->{cps_volume}' for CP server database on $sys0->{sys}");
            $msg->left;
            if ($cfg->{cps_enable_mirroring}) {
                $sys0->cmd("_cmd_vxassist -g $conf->{cps_diskgroup} make $conf->{cps_volume} $cfg->{cps_newvol_volsize}m layout=mirror");
            } else {
                $sys0->cmd("_cmd_vxassist -g $conf->{cps_diskgroup} make $conf->{cps_volume} $cfg->{cps_newvol_volsize}m");
            }
            if (EDR::cmdexit()) {
                $msg->right_failed();
                return 1;
            } else {
                $msg->right_done();
            }
            $ret = $fs->make_vxfs_sys($sys0,$conf->{cps_diskgroup},$conf->{cps_volume});
            Msg::log("Make fs return $ret");
        }

        # e2843588: import DG with SCSI3 reserverion if'UseFence = SCSI3' is set in main.cf
        $pkg->import_dg_with_scsi3pr($conf->{cps_diskgroup}) if ($conf->{cps_diskgroup});

        $ret = $pkg->update_maincf($conf,$config_flag);
        return $ret;
    }
    if (Obj::webui()) {
        my $result1 = $web->web_script_form('cps_sg1',$conf,$config_flag);
        @nic_list = @{$result1->{nic_list}};
        %vip2nicres_map = %{$result1->{vip2nicres_map}};
        @nicres_list = @{$result1->{nicres_list}};

        my $result2 = $web->web_script_form('cps_sg2',$conf,$result1->{nic_list},$pkg);
        @cps_netmasks = @{$result2->{cps_netmasks}};
        @network_hosts = @{$result2->{network_hosts}};
        @cps_prefix_length = @{$result2->{cps_prefix_length}};

        if ($config_flag->{multinode_vcs}) {

            my ($ret,$vxvmdisks,$vxfen_pkg,$dglist,@disks,$result3,$result4);
            $vxfen_pkg = $pkg->pkg('VRTSvxfen61');
            $dglist = $vxfen_pkg->get_dglist_sys($sys0);
            @disks = @{$dglist->{disks}} if (defined($dglist->{disks}));

            if(@disks<1) {
                 my $numdisks = $#disks + 1;
                 $msg=Msg::new("A new disk group cannot be created since no free VxVM CDS disks are available. If there are disks available which are not under VxVM control, use the command vxdisksetup or use the installer to initialize them as VxVM disks.");
                 $web->web_script_form('alert',$msg->{msg});
                 ($ret,$vxvmdisks) = $vxfen_pkg->init_vxvm_disks();
                 if (@{$vxvmdisks}) {
                     $dglist->{disks}=\@{EDRu::arruniq(@disks,@{$vxvmdisks})};
                 } else {
                     return 1;
                 }
            }

            $result3 = $web->web_script_form('cps_dg',$conf,$pkg,$sys0,$dglist);
            $cps_diskgroup = $result3->{cps_diskgroup};
            $result4 = $web->web_script_form('cps_vol',$conf,$pkg,$sys0,$cps_diskgroup);
            $cps_volume = $result4->{cps_volume};
            $cps_blockdevice = "$pkg->{device_path}/$cps_diskgroup/$cps_volume";
        }

    } else {
        if ($numvips > 1) {
            Msg::n();
            do {
                $msg = Msg::new("Enter how many NIC resources you want to configure (1 to $numvips):");
                $nic_count = $msg->ask();
            } while ("$nic_count" eq "" || $nic_count =~ /\D/ || $nic_count > $numvips || $nic_count < 1);
        } else {
            $nic_count = $numvips;
        }
        $i = 1;
        for (my $count = 0; $count < $nic_count; $count++) {
            if ($config_flag->{multinode_vcs}) {
                Msg::n();
                $msg = Msg::new("Is the name of network interfaces for NIC resource - $i same on all the systems?");
                $answer = $msg->ayn();
                $nic_same = ($answer eq 'Y') ? 1 : 0;
            }
            @nic_set_for_system = ();
            if ($nic_same) {
                Msg::n();
                while (1) {
                    $defopt = '';
                    $public_nics=$sys0->padv->publicnics_sys($sys0);
                    $public_nics=EDRu::arruniq(@$public_nics);
                    $defopt = join(' ',@$public_nics) if (@$public_nics > 0);
                    $msg = Msg::new("Enter a valid network interface for NIC resource - $i:");
                    $answer = $msg->ask($defopt);
                    for my $sys(@systems) {
                        if (!check_nic_sys($sys,$answer)) {
                            $msg = Msg::new("Network interface validation failed on $sys->{sys}");
                            $msg->print;
                            $validated = 0;
                            last;
                        } else {
                            $validated = 1;
                        }
                    }
                    last if ($validated);
                }
                foreach (@systems) {
                    push (@nic_set_for_system, $answer);
                }
            } else {
                Msg::n();
                for my $sys(@systems) {
                    while(1) {
                        $defopt = '';
                        $public_nics=$sys->padv->publicnics_sys($sys);
                        $public_nics=EDRu::arruniq(@$public_nics);
                        $defopt = join(' ',@$public_nics) if (@$public_nics > 0);
                        $msg = Msg::new("Enter a valid network interface on $sys->{sys} for NIC resource - $i:");
                        $answer = $msg->ask($defopt);
                        if (!check_nic_sys($sys,$answer)) {
                            $msg = Msg::new("Network interface validation failed on $sys->{sys}");
                            $msg->print;
                            next;
                        }
                        last;
                    }
                    push (@nic_set_for_system, $answer);
                }
            }
            $nic_set[$count] = [ @nic_set_for_system ];
            $i++;
        }

        $count = 0;
        @cps_virtual_ip = @{$conf->{all_vips}};
        foreach(@cps_virtual_ip) {
            @nic_list_for_vip = ();
            if ($nic_count > 1) {
                Msg::n();
                do {
                    $msg = Msg::new("Enter the NIC resource you want to associate with the virtual IP $cps_virtual_ip[$count] (1 to $nic_count):");
                    $answer = $msg->ask();
                } while ($answer =~ /\D/ || $answer > $nic_count || $answer < 1);
            } else {
                $answer = 1;
            }

            $vip2nicres_map{$cps_virtual_ip[$count]} = $answer;
            $nicres_list[$answer-1] = 0;
            $i = 0;
            foreach(@systems) {
                push(@nic_list_for_vip, $nic_set[$answer-1][$i]);
                $i++;
            }
            $nic_list[$count] = [ @nic_list_for_vip ];
            $count++;
        }

        ##  Check if Network Hosts attribute can be added to NIC resource
        Msg::n();
        $msg = Msg::new("Symantec recommends configuring NetworkHosts attribute to ensure NIC resource to be always online");
        $msg->print;
        $i = 0;
        $numnics = 0;
        foreach (@nic_list) {
            $j = 0;
            $nwhosts_same = 0;
            while ($nic_list[$i][$j]) {
                if ($nwhosts_same) {
                    $network_hosts[$numnics] = [ @network_hosts_for_nic ];
                    $nics_taken_care_of{$nic_list[$i][$j].'@'.$system_list[$j]}  = '1';
                    $numnics++;
                    $j++;
                    next;
                }
                @network_hosts_for_nic = ();
                # We should ask the question for NetworkHosts attribute for every combination of (node, nic).
                # If a (node, nic) combination has already been taken care of, then we can skip that pair safely.
                if ($nics_taken_care_of{$nic_list[$i][$j].'@'.$system_list[$j]} eq '1') {
                    $j++;
                    next;
                }
                $msg = Msg::new("Do you want to add NetworkHosts attribute for the NIC device $nic_list[$i][$j] on system $systems[$j]->{sys}?");
                $answer = $msg->ayn;
                $nics_taken_care_of{$nic_list[$i][$j].'@'.$system_list[$j]}  = '1';
                $input_flag = 0;
                if ($answer eq 'Y') {
                    do {
                        $networkhosts_back = 0;
                        while (1) {
                            Msg::n();
                            $msg = Msg::new("Enter a valid IP address to configure NetworkHosts for NIC $nic_list[$i][$j] on system $systems[$j]->{sys}:");
                            $answer = $msg->ask('','',$backopt);
                            if (EDR::getmsgkey($answer,'back')) {
                                $networkhosts_back = 1;
                                last;
                            }
                            if (!EDRu::is_ip_valid($answer)) {
                                $msg = Msg::new("Invalid NetworkHosts value for the network interface/NIC $nic_list[$i][$j]");
                                $msg->print;
                                next;
                            }
                            last;
                        }

                        # first input the NetworkHosts and want to back
                        if (($networkhosts_back == 1) && ($input_flag == 0 )) {
                            Msg::n();
                            $msg = Msg::new("Do you want to add NetworkHosts attribute for the NIC device $nic_list[$i][$j] on system $systems[$j]->{sys}?");
                            $answer = $msg->ayn();
                        # input valid value or not the first input the NetworkHosts but want to back
                        } else {
                            push (@network_hosts_for_nic, $answer);
                            Msg::n();
                            $msg = Msg::new("Do you want to add another Network Host?");
                            $answer = $msg->ayn();
                            $input_flag = 1;
                        }
                    } while ($answer eq 'Y');
                    if ($j == 0 && $config_flag->{multinode_vcs}) {
                        $msg = Msg::new("Do you want to apply the same NetworkHosts for all systems?");
                        $answer = $msg->ayny();
                        $nwhosts_same = 1 if ($answer eq 'Y');
                    }
                }
                $network_hosts[$numnics] = [ @network_hosts_for_nic ];
                $numnics++;
                $j++;
            }
            $i++;
        }
        # Get the netmask
        $i = 0;
        my %netmask_unique = ();
        foreach(@cps_virtual_ip) {
            $defopt = '';
            Msg::n();
            if ($is_ipv4_ipv6[$i] == 1) {
                $defopt = ($sys0->linux()) ? '[0, 128]' : '[1, 128]';
                $msg = Msg::new("Enter the prefix length for virtual IP ${cps_virtual_ip[$i]}:");
                $answer = $msg->ask($defopt);
                redo if (!$pkg->validate_prefix_length($answer));
                $cps_prefix_len = $answer;
                push (@cps_prefix_length, $cps_prefix_len);

            } else {
                $defopt = $sys0->defaultnetmask(${cps_virtual_ip[$i]},$nic_list[$i][0]);
                # get the type of vip and port, and make the question more clear
                my @cps_ports = @{$conf->{all_ports}};
                if ("https" eq $pkg->check_vip_port_sys($cps_virtual_ip[$i],$cps_ports[$i],$sys0)) {
                    $msg = Msg::new("Enter the netmask for virtual IP for HTTPS ${cps_virtual_ip[$i]}:");
                } else {
                    if ($netmask_unique{"$cps_virtual_ip[$i]"}) {
                        $msg = Msg::new("The virtual IP for IPM ${cps_virtual_ip[$i]} is the same with HTTPS, the same netmask will be used for this virtual IP.");
                        $msg->print;
                        push (@cps_netmasks, $netmask_unique{"$cps_virtual_ip[$i]"});
                        $i++;
                        next;
                    } else {
                        $msg = Msg::new("Enter the netmask for virtual IP for IPM ${cps_virtual_ip[$i]}:");
                    }
                }
                $answer = $msg->ask($defopt);
                if (!EDRu::ip_is_ipv4($answer) || ($answer =~ /^0+\./m)) {
                    $msg = Msg::new("$answer is not a valid Netmask. Re-enter values");
                    $msg->print;
                    redo;
                }
                $cps_netmask = $answer;
                push (@cps_netmasks, $cps_netmask);
                $netmask_unique{"$cps_virtual_ip[$i]"} = $answer;
            }
            $i++;
        }

        if ($config_flag->{multinode_vcs}) {
            while (1) {
                Msg::n();
                ($ret,$answer) = $pkg->ask_dg_sys($sys0);
                next if ($ret == -1);
                return $ret if ($ret);
                last;
            }
            $cps_diskgroup = $answer;
            Msg::n();
            ($ret,$answer) = $pkg->ask_vol_sys($sys0,$cps_diskgroup);
            return $ret if ($ret);
            $cps_volume = $answer;
            $cps_blockdevice = "$pkg->{device_path}/$cps_diskgroup/$cps_volume";
        }
    }

    # e2843588: import DG with SCSI3 reserverion if'UseFence = SCSI3' is set in main.cf
    $pkg->import_dg_with_scsi3pr($cps_diskgroup) if ($cps_diskgroup);

    $conf->{prefix_length} = [ @cps_prefix_length ];
    $conf->{netmasks} = [ @cps_netmasks ];
    $conf->{nic_list} = [ @nic_list ];
    $conf->{network_hosts} = [ @network_hosts ];
    $conf->{vip2nicres_map} = \%vip2nicres_map;
    $conf->{nicres_list} = [ @nicres_list ];
    $conf->{cps_blockdevice} = $cps_blockdevice;
    $conf->{cps_diskgroup} = $cps_diskgroup;
    $conf->{cps_volume} = $cps_volume;
    # Save cfg variables for responsefile
    $cfg->{cpsname} = $conf->{cpsname};
    $cfg->{cps_https_vips} = $conf->{vips};
    $cfg->{cps_https_ports} = $conf->{ports};
    $cfg->{cps_ipm_vips} = $conf->{vips_ipm};
    $cfg->{cps_ipm_ports} = $conf->{ports_ipm};
    $cfg->{cps_db_dir} = $conf->{cps_db_dir};
    $cfg->{cps_prefix_length} = $conf->{prefix_length} if ($conf->{prefix_length});
    $cfg->{cps_netmasks} = $conf->{netmasks} if ($conf->{netmasks});
    for $i(0..$#nic_list) {
        $j = $i + 1;
        $cfg->{cps_nic_list}{"cpsvip$j"} = $nic_list[$i];
    }
    for $i(0..$#network_hosts) {
        $j = $i + 1;
        $cfg->{cps_network_hosts}{"cpsnic$j"} = $network_hosts[$i];
    }
    $cfg->{cps_vip2nicres_map} = $conf->{vip2nicres_map};
    $cfg->{cps_diskgroup} = $conf->{cps_diskgroup};
    $cfg->{cps_volume} = $conf->{cps_volume};

    $ret = $pkg->update_maincf($conf,$config_flag);
    return $ret;
}

sub import_dg_with_scsi3pr {
    my ($pkg, $cps_diskgroup) = @_;
    my $sys0 = ${CPIC::get('systems')}[0];
    my $vxfen_pkg = $pkg->pkg('VRTSvxfen61');
    my $usefence = $sys0->cmd("_cmd_grep 'UseFence = SCSI3' /etc/VRTSvcs/conf/config/main.cf 2>/dev/null");
    if ($usefence && ($usefence =~ /^\s*UseFence\s*=\s*SCSI3\s*$/m) && ($vxfen_pkg->vxfen_mode_sys($sys0) =~ /(disk|cps|sybase)/)) {
        Msg::log("'UseFence = SCSI3' is set in main.cf, import disk group $cps_diskgroup with SCSI3 reserverion");
        $sys0->cmd("_cmd_vxdg deport $cps_diskgroup");
        $sys0->cmd("_cmd_vxdg -o groupreserve='VCS' -o clearreserve -tC import $cps_diskgroup");
    }
    return;
}

sub update_maincf {
    my ($pkg,$conf,$config_flag) = @_;
    my (@add_cpssg_steps,@ip_res,$cmd,$failmsg,$list,$msg,$sys0,$sysnamelist,$rtn,$vcs);
    my (@network_hosts,@nic_list,@nicres_list,$count,$cps_mountpoint,$current_nic,$i,$j);
    my ($vip_res,$nic_res,%vip_res_unique);
    $sysnamelist = '';

    $sys0 = ${CPIC::get('systems')}[0];
    $vcs = $pkg->prod('VCS61');
    Msg::n();
    $msg = Msg::new("Updating main.cf with CPSSG service group");
    $msg->left;
    $vcs->haconf_makerw();

    $cmd = "$vcs->{bindir}/hagrp -add CPSSG";
    $failmsg = Msg::new("Failed to add the CPSSG service group to the VCS configuration on $sys0->{sys}");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    # Modify group
    $i = 0;
    for my $sysi(@{$conf->{system_list}}) {
        $sysnamelist .= $sysi." ${$conf->{nodeid_list}}[$i] ";
        $i++;
    }
    $cmd = "$vcs->{bindir}/hagrp -modify CPSSG SystemList -add $sysnamelist";
    $failmsg = Msg::new("Failed to add the SystemList attribute in the CPSSG service group");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $cmd = "$vcs->{bindir}/hagrp -modify CPSSG Parallel 0";
    $failmsg = Msg::new("Failed to modify the Parallel attribute of the CPSSG service group");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $list=join(' ', @{$conf->{system_list}});
    $cmd = "$vcs->{bindir}/hagrp -modify CPSSG AutoStartList $list";
    $failmsg = Msg::new("Failed to modify the AutoStartList attribute for $list of the CPSSG service group");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    # Adding vxcpserv
    $cmd = "$vcs->{bindir}/hares -add vxcpserv Process CPSSG";
    $failmsg = Msg::new("Failed to add vxcpserv as a Process resource to the CPSSG service group");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $cmd = "$vcs->{bindir}/hares -modify vxcpserv PathName $pkg->{cps_process}";
    $failmsg = Msg::new("Failed to modify the PathName attribute to $pkg->{cps_process} for the vxcpserv Process resource");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $cmd = "$vcs->{bindir}/hares -modify vxcpserv PathName $pkg->{cps_process}";
    $failmsg = Msg::new("Failed to modify the PathName attribute to $pkg->{cps_process} for the vxcpserv Process resource");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    if (!$config_flag->{multinode_vcs}) {
        $cmd = "$vcs->{bindir}/hares -override vxcpserv RestartLimit";
        $failmsg = Msg::new("Failed to override the RestartLimit attribute for the vxcpserv Process resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify vxcpserv RestartLimit 3";
        $failmsg = Msg::new("Failed to modify the RestartLimit attribute to 3 for the vxcpserv Process resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -override vxcpserv ConfInterval";
        $failmsg = Msg::new("Failed to override the ConfInterval attribute for the vxcpserv Process resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify vxcpserv ConfInterval 30";
        $failmsg = Msg::new("Failed to modify the ConfInterval attribute to 30 for the vxcpserv Process resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    }

    # Adding Virutal IP
    $i = 0;
    $count = 0;
    @nic_list = @{$conf->{nic_list}};
    %vip_res_unique = ();
    foreach my $vip (@{$conf->{all_vips}}) {
        # if the vip is duplicate, skip
        next if ($vip_res_unique{"$vip"}++);

        $count++;
        $vip_res="cpsvip$count";
        $cmd = "$vcs->{bindir}/hares -add $vip_res IP CPSSG";
        $failmsg = Msg::new("Failed to add $vip_res as an IP resource to the CPSSG service group");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify $vip_res Critical 0";
        $failmsg = Msg::new("Failed to modify the Critical attribute of $vip_res IP resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

        push (@ip_res, $vip_res);

        $cmd = "$vcs->{bindir}/hares -modify $vip_res Address $vip";
        $failmsg = Msg::new("Failed to modify the Address attribute to $vip for the $vip_res IP resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        if (${$conf->{is_ipv4_ipv6}}[$i] == 1) {
            $cmd = "$vcs->{bindir}/hares -modify $vip_res PrefixLen ${$conf->{prefix_length}}[$i]";
            $failmsg = Msg::new("Failed to modify the PrefixLen attribute to ${$conf->{prefix_length}}[$i] for the $vip_res IP resource");
        } else {
            $cmd = "$vcs->{bindir}/hares -modify $vip_res NetMask ${$conf->{netmasks}}[$i]";
            $failmsg = Msg::new("Failed to modify the NetMask attribute to ${$conf->{netmasks}}[$i] for the $vip_res IP resource");
        }
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -local $vip_res Device";
        $failmsg = Msg::new("Failed to add the Device attribute to the $vip_res IP resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

        $j = 0;
        foreach (@{$conf->{system_list}}) {
            $cmd = "$vcs->{bindir}/hares -modify $vip_res Device $nic_list[$i][$j] -sys ${$conf->{system_list}}[$j]";
            $failmsg = Msg::new("Failed to modify Device attribute to $nic_list[$i][$j] for ${$conf->{system_list}}[$j] for the $vip_res IP resource");
            push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
            $j++;
        }
        $i++;
    }

    # Adding quorum resource type
    push (@add_cpssg_steps, $pkg->add_quorum_agent_to_cps());
    $cmd = "$vcs->{bindir}/hatype -value Quorum ArgList | grep -w 'QuorumResources' | grep -w 'Quorum'";
    $failmsg = Msg::new("Failed to add Quorum Agent Type");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    # Add quorum resource
    $cmd = "$vcs->{bindir}/hares -add quorum Quorum CPSSG";
    $failmsg = Msg::new("Failed to add the Quorum resource to the CPSSG service group");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hares -modify quorum QuorumResources @ip_res";
    $failmsg = Msg::new("Failed to modify the Quorum resource");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hares -modify quorum Quorum 1";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    # Adding NIC
    $i = 0;
    $count = 0;
    $current_nic = 0;
    @nicres_list = @{$conf->{nicres_list}};
    @network_hosts = @{$conf->{network_hosts}};
    %vip_res_unique=();
    foreach my $vip (@{$conf->{all_vips}}) {
        # if the vip is duplicate, skip
        next if ($vip_res_unique{"$vip"}++);

        $count++;
        $nic_res="cpsnic$count";
        if (!$nicres_list[$conf->{vip2nicres_map}->{$vip}-1]) {
            $cmd = "$vcs->{bindir}/hares -add $nic_res NIC CPSSG";
            $failmsg = Msg::new("Failed to add $nic_res as a NIC resource to the CPSSG service group");
            push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
            $cmd = "$vcs->{bindir}/hares -modify $nic_res Critical 0";
            $failmsg = Msg::new("Failed to modify the Critical attribute of $nic_res NIC resource");
            push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
            if ((${$conf->{is_ipv4_ipv6}}[$i] == 1) && (!$sys0->linux())) {
                $cmd = "$vcs->{bindir}/hares -modify $nic_res Protocol IPv6";
                $failmsg = Msg::new("Failed to modify the Protocol attribute to IPv6 for the $nic_res NIC resource");
                push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
            }
            $cmd = "$vcs->{bindir}/hares -local $nic_res Device";
            $failmsg = Msg::new("Failed to add the Device attribute of $nic_res NIC resource");
            push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
            $cmd = "$vcs->{bindir}/hares -local $nic_res NetworkHosts";
            $failmsg = Msg::new("Failed to add the NetworkHosts attribute of $nic_res NIC resource");
            push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

            $nicres_list[$conf->{vip2nicres_map}->{$vip}-1] = $count;
            $j = 0;
            foreach (@{$conf->{system_list}}) {
                $cmd = "$vcs->{bindir}/hares -modify $nic_res Device $nic_list[$i][$j] -sys ${$conf->{system_list}}[$j]";
                $failmsg = Msg::new("Failed to modify the Device attribute of $nic_res NIC resource");
                push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
                if ($network_hosts[$current_nic] && @{$network_hosts[$current_nic]}) {
                    $cmd = "$vcs->{bindir}/hares -modify $nic_res NetworkHosts -add @{$network_hosts[$current_nic]} -sys ${$conf->{system_list}}[$j]";
                    $failmsg = Msg::new("Failed to add the NetworkHosts attribute to the $nic_res NIC resource");
                    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
                } else {
                    $cmd = "$vcs->{bindir}/hares -modify $nic_res PingOptimize 0";
                    $failmsg = Msg::new("Failed to add modify the PingOptimize attribute to 0 for the $nic_res NIC resource");
                    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
                }
                $current_nic++;
                $j++;
            }
            $i++;
        }
    }

    $cps_mountpoint = $conf->{cps_db_dir};
    if ($config_flag->{multinode_vcs}) {
        # Adding Mount Point
        $cmd = "$vcs->{bindir}/hares -add cpsmount Mount CPSSG";
        $failmsg = Msg::new("Failed to add cpsmount as a Mount resource to the CPSSG service group");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsmount MountPoint $cps_mountpoint";
        $failmsg = Msg::new("Failed to modify MountPoint attribute of cpsmount resource to $cps_mountpoint");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsmount BlockDevice $conf->{cps_blockdevice}";
        $failmsg = Msg::new("Failed to modify BlockDevice attribute of cpsmount resource to $conf->{cps_blockdevice}");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsmount FSType $pkg->{default_fs}";
        $failmsg = Msg::new("Failed to modify FSType attribute of cpsmount resource to $pkg->{default_fs}");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsmount FsckOpt '%-y'";
        $failmsg = Msg::new("Failed to modify FsckOpt attribute of cpsmount resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        # Adding Disk Group
        $cmd = "$vcs->{bindir}/hares -add cpsdg DiskGroup CPSSG";
        $failmsg = Msg::new("Failed to add cpsdg as a DiskGroup resource to the CPSSG service group");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsdg DiskGroup $conf->{cps_diskgroup}";
        $failmsg = Msg::new("Failed to modify cpsdg DiskGroup resource to $conf->{cps_diskgroup}");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        # Adding Volume
        $cmd = "$vcs->{bindir}/hares -add cpsvol Volume CPSSG";
        $failmsg = Msg::new("Failed to add cpsvol as a Volume resource to the CPSSG service group");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsvol Volume $conf->{cps_volume}";
        $failmsg = Msg::new("Failed to modify cpsvol Volume resource to $conf->{cps_volume}");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify cpsvol DiskGroup $conf->{cps_diskgroup}";
        $failmsg = Msg::new("Failed to modify DiskGroup attribute to $conf->{cps_diskgroup} for cpsvol Volume resource");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    }
    # Linking
    if ($config_flag->{multinode_vcs}) {
        $cmd = "$vcs->{bindir}/hares -link cpsmount cpsvol";
        $failmsg = Msg::new("Failed to link cpsmount to cpsvol");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -link cpsvol cpsdg";
        $failmsg = Msg::new("Failed to link cpsvol to cpsdg");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    }
    $count = 0;
    %vip_res_unique=();
    foreach my $vip (@{$conf->{all_vips}}) {
        # if the vip is duplicate, skip
        next if ($vip_res_unique{"$vip"}++);

        $count++;
        $vip_res="cpsvip$count";
        $nic_res="cpsnic$nicres_list[$conf->{vip2nicres_map}->{$vip}-1]";
        $cmd = "$vcs->{bindir}/hares -link $vip_res $nic_res";
        $failmsg = Msg::new("Failed to link $vip_res to $nic_res");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    }
    $cmd = "$vcs->{bindir}/hares -link vxcpserv quorum";
    $failmsg = Msg::new("Failed to link vxcpserv to quorum");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    if ($config_flag->{multinode_vcs}) {
        $cmd = "$vcs->{bindir}/hares -link vxcpserv cpsmount";
        $failmsg = Msg::new("Failed to link vxcpserv to cpsmount");
        push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    }

    $cmd = "$vcs->{bindir}/hagrp -enableresources CPSSG";
    $failmsg = Msg::new("Failed to enable resources of CPSSG service group");
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    for my $step(@add_cpssg_steps) {
        $sys0->cmd($step->{cmd});
        if (EDR::cmdexit()) {
            next if ($step->{failmsg}->{msg} eq 'ignore_quorum_error');
            Msg::right_failed();
            $step->{failmsg}->print;
            $rtn = 'error';
            last;
        }
    }
    if ($rtn eq 'error') {
        $vcs->haconf_dumpmakero();
        Msg::prtc();
        return 1;
    }
    # Makero
    $vcs->haconf_dumpmakero();
    $sys0->cmd("$vcs->{bindir}/haclus -wait DumpingMembership 0");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("Failed to save configuration");
        $msg->error();
    } else {
        Msg::right_done();
    }
    return;
}

sub add_quorum_agent_to_cps {
    my $pkg = shift;
    my (@add_cpssg_steps,$cmd,$failmsg,$vcs);
    $vcs = $pkg->prod('VCS61');
    $failmsg = Msg::new_obj("ignore_quorum_error");
    $cmd = "$vcs->{bindir}/hatype -add Quorum";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum SourceFile '/opt/VRTScps/bin/Quorum/QuorumTypes.cf'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ArgList QuorumResources Quorum State";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -add Quorum QuorumResources -string -vector";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -add Quorum Quorum -integer 1";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum IMFRegList -delete -keys";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AttrChangedTimeout 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum CloseTimeout 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum CleanRetryLimit 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum CleanTimeout 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ConfInterval 600";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum MonitorInterval 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum MonitorTimeout 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum LevelTwoMonitorFreq 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum NumThreads 10";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AgentPriority 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AgentClass TS";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ScriptPriority 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ScriptClass TS";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum LogFileSize 33554432";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OfflineMonitorInterval 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OfflineTimeout 300";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OfflineWaitLimit 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OnlineRetryLimit 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OnlineTimeout 300";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OnlineWaitLimit 2";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OpenTimeout 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum RestartLimit 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ToleranceLimit 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AgentStartTimeout 60";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AgentReplyTimeout 130";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum Operations OnOff";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum FaultOnMonitorTimeouts 4";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AlertOnMonitorTimeouts 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum InfoInterval 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum InfoTimeout 30";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum SupportedActions -delete -keys";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ActionTimeout 30";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AgentDirectory '/opt/VRTScps/bin/Quorum'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AgentFile '/opt/VRTSvcs/bin/Script51Agent'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum FireDrill 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum FaultPropagation 1";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ExternalStateChange -delete -keys";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum TypeOwner ''";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum TypeRecipients -delete -keys";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum AutoStart 1";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum Critical 1";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum TriggerResRestart 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum TriggerResStateChange 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum TriggerEvent 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum ResourceOwner ''";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum TriggerPath ''";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum ResourceRecipients '' ''";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum MonitorStatsParam Frequency 0 ExpectedValue 100 ValueThreshold 100 AvgThreshold 40";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum ContainerOpts -delete -keys";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum LogDbg -delete -keys";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/haattr -default Quorum ComputeStats 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum AEPTimeout 0";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum EPPriority '%-1'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum EPClass '%-1'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OnlinePriority '%-1'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum OnlineClass '%-1'";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    $cmd = "$vcs->{bindir}/hatype -modify Quorum IMF Mode 3 MonitorFreq 1 RegisterRetryLimit 3";
    push (@add_cpssg_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    return @add_cpssg_steps;
}

sub unconfigure_cpserver {
    my $pkg = shift;
    my (@hosts,$answer,$backopt,$cfg,$config_flag,$msg,$out,$ret,$vcs,$sys0,$web);
    my ($cpssg,$cpservers);
    $sys0 = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();
    $vcs = $pkg->prod('VCS61');
    $backopt = 1;
    $web = Obj::web();
    Msg::n();
    $msg = Msg::new("Unconfiguring coordination point server stops the vxcpserv process. VCS clusters using this server for coordination purpose will have one less coordination point. Are you sure you want to take the CP server offline?");
    $answer = $msg->aynn('',$backopt);
    $answer = 'Y' if (Cfg::opt('responsefile'));
    return $answer if (EDR::getmsgkey($answer,'back'));
    return if ($answer ne 'Y');
    if (!$pkg->{mandate_vcs}) {
        Msg::n();
        $msg = Msg::new("Is CP server configured with VCS for providing High Availability?");
        $answer = $msg->ayn('','',$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
    } else {
        $answer = 'Y';
    }

    if ($answer ne 'Y') {
        $ret = $pkg->stop_cpserver_process();
        if ($ret) {
            Msg::n();
            $msg = Msg::new("Could not stop the server");
            if (Obj::webui()){
                $web->{complete_failed}=1;
                $web->web_script_form('alert', $msg);
            }
            $msg->error();
            return $ret;
        }
    }
    $out = $sys0->cmd('_cmd_hasys -list');
    if (EDR::cmdexit()) {
        Msg::n();
        $msg = Msg::new("Unable to run '$vcs->{bindir}/hasys -list' on the $sys0->{sys}.\nVCS is not running on the machine");
        $msg->die();
    }
    chomp($out);
    @hosts = split(/\n/,$out);
    if ($#hosts > 0) {
        $config_flag->{multinode_vcs} = 1;
        $msg = Msg::new("A multinode cluster is currently configured");
        $msg->nprint;
    } elsif ($#hosts == 0) {
        $config_flag->{multinode_vcs} = 0;
        $msg = Msg::new("A single node cluster is currently configured");
        $msg->nprint;
    }
    # get the CPS service group name and vxcpserv resource name
    ($cpssg,$cpservers) = $pkg->get_cpssg_cpservers_sys($sys0);
    if (!$cpssg) {
        $msg = Msg::new("The Coordination Point Server is not configured in the cluster");
        if (Obj::webui()){
            $web->{complete_failed}=1;
            $web->web_script_form('alert', $msg);
        }
        $msg->error();

        return 1;
    }
    return 1 if $pkg->stop_and_remove_cps_from_vcs($cpssg,$cpservers);

    $pkg->delete_database_and_config_files($config_flag);
    # Save for responsefile
    $cfg->{cps_unconfig} = 1;

    if ($config_flag->{multinode_vcs} == 0) {
        $pkg->delete_singlenode_cps_license_after_unconfig;
    }

    return;
}

sub stop_and_remove_cps_from_vcs {
    my ($pkg,$cpssg,$cpservers) = (@_);
    my ($msg,$ret,$web);
    $web = Obj::web();

    $ret = $pkg->stop_cpserver($cpssg);
    if ($ret == 1) {
        $msg = Msg::new("Failed to stop the Coordination Point Server");
        if (Obj::webui()){
            $web->{complete_failed}=1;
            $web->web_script_form('alert', $msg);
        }
        $msg->error();
        return 1;
    }
    $msg = Msg::new("Removing the CP server from VCS configuration");
    $msg->nprint;
    $ret = $pkg->removefrom_vcs_config($cpssg,$cpservers);
    if ($ret) {
        $msg = Msg::new("Could not remove CP server from VCS configuration");
        $msg->nprint;
        return 1;
    } else {
        $msg = Msg::new("Successfully unconfigured the Symantec coordination point server");
        $msg->nprint;
    }
    return 0;
}

sub delete_singlenode_cps_license_after_unconfig {
    my $pkg = shift;
    my ($keyfile,$lic_dir,$sys,$out);
    $sys = ${CPIC::get('systems')}[0];
    $lic_dir = '/etc/vx/licenses/lic';
    $keyfile = "$lic_dir/$pkg->{cpskey}.vxlic";
    return if (!$sys->exists($keyfile));
    $sys->cmd("_cmd_rmr $keyfile");
    $out = $sys->cmd('_cmd_vxkeyless display 2> /dev/null');
    if (EDR::cmdexit()) {
        $sys->cmd('_cmd_vxkeyless -q set VCS');
    } else {
        $sys->cmd("_cmd_vxkeyless -q set $out,VCS") if ($out !~ /VCS/m);
    }
    return;
}

sub start_cpserver_process {
    my $pkg = shift;
    my ($msg,$ret,$sys0);
    $sys0 = ${CPIC::get('systems')}[0];
    $sys0->cmd($pkg->{cps_process});
    $ret = EDR::cmdexit();
    if ($ret) {
        $msg = Msg::new("Failed to start the vxcpserv process, vxcpserv returned $ret");
        $msg->nprint;
        return $ret;
    } else {
        $msg = Msg::new("Sucessfully started the vxcpserv process");
        $msg->nprint;
    }
    return 0;
}

# Stops the CP server by:
# 1. Killing the vxcpserver
sub stop_cpserver_process {
    my $pkg = shift;
    my ($ukpids,$pids,$sys0);
    $sys0 = ${CPIC::get('systems')}[0];
    $pids = $sys0->proc_pids('vxcpserv');
    $ukpids = $sys0->kill_pids(@$pids);
    return 1 if (@$ukpids > 0);
    return 0;
}

# Stops the CP server by:
# 1.Bringing the CPSSG group offline
# Return 0: CPSSG is offline
# Return 1: CPSSG is online
sub stop_cpserver {
    my ($pkg,$cpssg) = @_;
    my ($msg,$out,$ret,$sys0);
    my $systems = CPIC::get('systems');
    $sys0 = ${$systems}[0];
    for my $sys (@{$systems}) {
        $out = $sys->cmd("_cmd_hagrp -state $cpssg -sys $sys->{vcs_sysname}");
        $ret = EDR::cmdexit();
        chomp($out);
        Msg::log("The $cpssg group is $out on sys $sys->{sys}");
        next if ($ret || ($out =~ /OFFLINE/m));
        $msg = Msg::new("Stopping CP server on $sys->{sys}");
        $msg->left;
        $sys->cmd("_cmd_hagrp -clear $cpssg") if ($out !~ /ONLINE/m);
        $sys->cmd("_cmd_hagrp -offline $cpssg -any");
        if (!EDR::cmdexit()) {
            $sys->cmd("_cmd_hagrp -wait $cpssg State OFFLINE -sys $sys->{vcs_sysname} -time 60");
        } else {
            Msg::log("Unable to offline $cpssg on $sys->{sys}");
        }
        $out = $sys->cmd("_cmd_hagrp -state $cpssg -sys $sys->{vcs_sysname} | _cmd_grep OFFLINE");
        if (EDR::cmdexit()) {
            $msg->right_failed();
        } else {
            $msg->right_done();
        }
    }
    $sys0->cmd("_cmd_hagrp -state $cpssg | _cmd_grep ONLINE");
    return 1 if (!EDR::cmdexit());
    return 0;
}

# Removes CPSSG from VCS configuration. This includes:
# 1. Unlinking dependencies
# 2. Deleting resources
# 3. Deleting CPSSG service group
sub removefrom_vcs_config {
    my ($pkg,$cpssg,$cpservers) = @_;
    my (@systems,$msg,$out,$sys0,$vcs);
    my (@reses,$res_aref,$res_vips,$res_nics);
    $vcs = $pkg->prod('VCS61');
    @systems = @{CPIC::get('systems')};
    $sys0 = $systems[0];
    $vcs->haconf_makerw();
    $msg = Msg::new("Removing resource dependencies");
    $msg->left;
    # Unlink, remove resource dependency
    # find child resources of vxcpserv resource
    $res_aref = $pkg->unlink_child_resources_of_resource_from_sys($sys0,$cpservers);
    push (@reses, @$res_aref);
    unshift(@reses,$cpservers);
    ($res_vips,$res_nics) = $pkg->unlink_cpsvip_cpsnic_of_cpssg_from_sys($sys0, $cpssg);
    push (@reses, @$res_vips, @$res_nics);
    $msg->right_done;

    $msg = Msg::new("Deleting the resources configured under $cpssg service group");
    $msg->left();
    for my $res(@reses) {
        $sys0->cmd("_cmd_hares -delete $res");
    }
    $sys0->cmd("$vcs->{bindir}/hatype -delete Quorum");
    $msg->right_done;

    # delete CPSSG
    $msg = Msg::new("Deleting the $cpssg service group");
    $msg->left;
    $sys0->cmd("$vcs->{bindir}/hagrp -delete $cpssg");
    $vcs->haconf_dumpmakero();
    $sys0->cmd("$vcs->{bindir}/haclus -wait DumpingMembership 0");
    $msg->right_done;
    return;
}

# Find CPS service group and vxcpserv resource from VCS configuration
sub get_cpssg_cpservers_sys {
    my ($pkg,$sys) = @_;
    my ($cpserv_res,$cpssg,$out,$pathname,$res);
    $out = $sys->cmd("_cmd_hares -display -attribute PathName 2> /dev/null| _cmd_grep -v '#'");
    for my $line(split(/\n/, $out)) {
        ($res,undef, undef,$pathname) = split(/\s+/, $line);
        if ($pathname eq $pkg->{cps_process}) {
            $cpserv_res = $res;
            last;
        }
    }
    if ($cpserv_res) {
        $out = $sys->cmd("_cmd_hares -display $cpserv_res 2> /dev/null| _cmd_awk '\$2 == \"Group\" {print \$4}'");
        chomp($out);
        $cpssg = $out;
    }
    return ($cpssg,$cpserv_res);
}

# Unlink cps VIP resources from cps NIC resources
# Return list of cps VIP resources names, list of cps NIC resources names
sub unlink_cpsvip_cpsnic_of_cpssg_from_sys {
    my ($pkg,$sys,$cpssg) = @_;
    my (@cpsnics,@cpsvips);
    my ($out);
    $out = $sys->cmd("_cmd_hares -display -type IP 2> /dev/null| _cmd_awk '\$2 == \"Group\" && \$4 == \"$cpssg\" {print \$1}'");
    if ($out) {
        @cpsvips = split(/\n/,$out);
        for my $cpsvip(@cpsvips) {
        $out = $sys->cmd("_cmd_hares -dep $cpsvip 2> /dev/null | _cmd_tail -1 | _cmd_awk '{print \$3}'");
            for my $cpsnic(split(/\n/,$out)) {
                $sys->cmd("_cmd_hares -unlink $cpsvip $cpsnic");
            }
        }
    }
    $out = $sys->cmd("_cmd_hares -display -type NIC 2> /dev/null| _cmd_awk '\$2 == \"Group\" && \$4 == \"$cpssg\" {print \$1}'");
    if ($out) {
        @cpsnics = split(/\n/,$out);
    }
    return (\@cpsvips,\@cpsnics);
}

# Unlink vxcpserv resource and all its child resources
# Return all the child resources of vxcpserv resource
sub unlink_child_resources_of_resource_from_sys {
    my ($pkg,$sys,$res) = @_;
    my ($deps,@fields,@all_child_res,$childres_ref);
    @all_child_res = ();
    if ($res) {
        $deps = $sys->cmd("_cmd_hares -dep $res 2>/dev/null");
        for my $dep (split(/\n/,$deps)) {
            # Group    Parent    Child
            @fields=split(/\s+/, $dep);
            next if ($fields[0] =~ /^#/);
            next if ($fields[2] eq $res);
            # unlink res from child res
            $sys->cmd("_cmd_hares -unlink $res $fields[2]");
            push (@all_child_res,$fields[2]);

            $childres_ref = $pkg->unlink_child_resources_of_resource_from_sys($sys,$fields[2]);
            push (@all_child_res, @$childres_ref);
        }
    }
    return \@all_child_res;
}

sub delete_database_and_config_files {
    my ($pkg,$config_flag) = @_;
    my ($answer,$cfg,$dblocation,$msg,$out,$sys0,$msg1);
    $cfg = Obj::cfg();
    $sys0 = ${CPIC::get('systems')}[0];
    Msg::n();
    # Cannot delete the CP Server database for SFHA
    # it's on shared storage and has already been offlined(deported)
    if ($config_flag->{multinode_vcs}) {
        $answer = 'N';
    } else {
        Msg::n();
        $msg1 = Msg::new("If you are unconfiguring this CP server as part of upgrading it, you must not delete the CP server database as it would remove client cluster information for the existing clients and as a result existing client clusters would fail to use this CP server as one of the coordination points.");
        $msg1->print;
        $msg = Msg::new("Do you want to delete the CP server database?");
        $answer = $msg->aynn('', '', $msg1);
    }
    if ($answer eq 'Y') {
        Msg::n();
        $msg = Msg::new("This database will not be available if CP server is reconfigured on the cluster. Are you sure you want to proceed with the deletion of database?");
        $answer = $msg->aynn();
        Msg::n();
    }
    if (Cfg::opt('responsefile')) {
        $answer = 'Y' if ($cfg->{cps_delete_database});
    }
    if ($answer eq 'Y') {
        $out = $sys0->cmd("_cmd_cat $pkg->{default_cps_conf_file} 2> /dev/null| _cmd_grep '^db='");
        if ($out =~ /^db=\s*(\S+)/m) {
            $dblocation = $1;
            for my $sys(@{CPIC::get('systems')}) {
                $msg = Msg::new("Deleting $dblocation/current on $sys->{sys}");
                $msg->left;
                $sys->cmd("unlink $pkg->{default_cred_dir}/CPSERVER");
                $sys->cmd("_cmd_rmr $dblocation/CPSERVER");
                $sys->cmd("_cmd_rmr $dblocation/current/cps_uuid");
                $sys->cmd("_cmd_rmr $dblocation/current/cps_db");
                $sys->cmd("_cmd_rmr $dblocation/current");
                if (EDR::cmdexit()) {
                    $msg->right_failed;
                    $msg = Msg::new("Could not delete current database from $dblocation on $sys->{sys}. Please delete the database manually.");
                    $msg->warning;
                } else {
                    $msg->right_done;
                }
            }
        } else {
            $msg = Msg::new("Could not find the location of CP server database from configuration file $pkg->{default_cps_conf_file}. Please delete it manually");
            $msg->warning();
        }
        $cfg->{cps_delete_database} = 1;
    } else {
        if ($config_flag->{multinode_vcs}) {
            $msg = Msg::new("The CP server database is not being deleted on the shared storage. It can be re-used if CP server is reconfigured on the cluster. The same database location can be specified during CP server configuration.");
            $msg->print();
        } else {
            $msg = Msg::new("The CP server database is not being deleted. It can be re-used if CP server is reconfigured on the cluster. The same database location can be specified during CP server configuration.");
            $msg->print();
        }
    }

    # Delete the CPS configuration file and log files
    Msg::n();
    $msg = Msg::new("Do you want to delete the CP server configuration file ($pkg->{default_cps_conf_file}) and log files (in /var/VRTScps)?");
    $answer = $msg->aynn();
    if (Cfg::opt('responsefile')) {
        $answer = 'Y' if ($cfg->{cps_delete_config_log});
    }
    if ($answer eq 'Y') {
        Msg::n();
        for my $sys(@{CPIC::get('systems')}) {
            $msg = Msg::new("Deleting $pkg->{default_cps_conf_file} and log files on $sys->{sys}");
            $msg->left;
            $sys->cmd("_cmd_rmr $pkg->{default_cps_conf_file}");
            $sys->cmd("_cmd_rmr /var/VRTScps/log");
            $sys->cmd("_cmd_rmr /var/VRTScps/diag");
            $sys->cmd("_cmd_rmr /var/VRTScps/ldf");
            if (EDR::cmdexit()) {
                $msg->right_failed;
                $msg = Msg::new("Could not delete $pkg->{default_cps_conf_file} and log files on $sys->{sys}. Please delete them manually.");
                $msg->warning;
            } else {
                $msg->right_done;
            }
        }
        $cfg->{cps_delete_config_log} = 1;
    }
    return;
}

# return 1: valid nic
# return 0: invalid nic
sub check_nic_sys {
    my ($sys,$nic) = @_;
    my ($ret);

    # ([a-z]+(\d)+) -- pattern begins with lowercase chars and ends with digits
    # {1,2} -- above pattern can repeat exactly once('hme0') or twice ('e1000g0')
    if ($nic =~ /^([a-z]+(\d)+){1,2}$/m) {
        # Valid NIC device
        # Check if NIC is configured on the system
        if ($sys->hpux()) {
            $sys->cmd("/usr/sbin/nwmgr | _cmd_grep '^$nic'");
        } else {
            $sys->cmd("_cmd_ifconfig -a | _cmd_grep '^$nic'");
        }
        (EDR::cmdexit()) ? return 0 : return 1;
    }
    return 0;
}

# Create ca key, ca certificate, server private key on the system
#
# Only the following files are needed
#   1. /var/VRTScps/security/keys/ca.key
#   2. /var/VRTScps/security/keys/server_private.key
#   3. /var/VRTScps/security/certs/ca.crt
#   4. /var/VRTScps/security/certs/server.crt (Currently the CN field value for this file determine which VIP works)
#
sub https_create_server_keys_certs_sys {
    my ($pkg,$sys,$conf) = @_;
    my (@vips,@ips,$num,$vcs,$uuid,$keys_config_file,$content,$msg);

    my $server_keys_dir=$pkg->{https_server_keys_dir};
    my $server_certs_dir=$pkg->{https_server_certs_dir};
    my $server_private_key_file="$server_keys_dir/server_private.key";
    my $server_ca_key_file="$server_keys_dir/ca.key";
    my $server_ca_crt_file="$server_certs_dir/ca.crt";
    my $server_csr_file="$server_certs_dir/server.csr";
    my $server_crt_file="$server_certs_dir/server.crt";

    $sys->cmd("_cmd_mkdir -p $server_keys_dir $server_certs_dir");

    # Generate ca.key
    if (!$sys->exists($server_ca_key_file)) {
        $sys->cmd("_cmd_openssl genrsa -out $server_ca_key_file 4096");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Unable to create CA key $server_ca_key_file on $sys->{sys}");
            $msg->error();
            return 0;
        }
    }

    # Generate ca.crt
    $sys->cmd("_cmd_openssl req -new -x509 -days 3650 -key $server_ca_key_file -subj '/C=IN/L=Pune/OU=VCS/CN=CACERT' -out $server_ca_crt_file");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Unable to create CA certificate $server_ca_crt_file on $sys->{sys}");
        $msg->error();
        return 0;
    }

    # Generate server_private.key
    if (!$sys->exists($server_private_key_file)) {
        $sys->cmd("_cmd_openssl genrsa -out $server_private_key_file 2048");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Unable to create server private key $server_private_key_file on $sys->{sys}");
            $msg->error();
            return 0;
        }
    }

    # Generate keys config file
    $keys_config_file=$pkg->{https_server_security_dir} . "/keys.httpsconfig";
    $content =<< "_HTTPS_";
[ req ]
distinguished_name     = req_distinguished_name
req_extensions         = v3_req

[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_default = US
localityName = Locality Name (eg, city)
organizationalUnitName = Organizational Unit Name (eg, section)
commonName = Common Name (eg, YOUR name)
commonName_max = 64
emailAddress = Email Address
emailAddress_max = 40

[v3_req]
keyUsage               = keyEncipherment, dataEncipherment
extendedKeyUsage       = serverAuth
subjectAltName         = \@alt_names

[alt_names]
_HTTPS_

    @vips=();
    @vips=@{$conf->{vips}} if ($conf);

    # Add FQDN associated with the VIP into the vip list.
    @ips=($sys->{sys}, $sys->{hostname}, $sys->{fqdn});
    for my $vip (@vips) {
        my ($fqdn,$ip)=$sys->nslookup($vip);
        push (@ips, $fqdn) if ($fqdn);
    }

    for my $ip (@ips) {
        push(@vips, $ip) if ($ip && !EDRu::inarr($ip, @vips));
    }

    # add vips as "DNS.<index> = <vip>"
    $num = 0;
    for my $vip (@vips) {
        $num++;
        $content .= " DNS.$num                   = $vip\n";
    }

    $sys->writefile($content,$keys_config_file);

    # Generate server.csr
    $vcs = $pkg->prod('VCS61');
    $uuid = $vcs->get_uuid_sys($sys);
    $uuid ||= 'https_cp_server_' . $sys->{sys};
    $sys->cmd("_cmd_openssl req -new -key $server_private_key_file -config $keys_config_file -subj '/C=IN/L=Pune/OU=VCS/CN=$uuid' -out $server_csr_file");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Unable to create server certificate $server_csr_file on $sys->{sys}");
        $msg->error();
        return 0;
    }

    # Generate server.crt
    $sys->cmd("_cmd_openssl x509 -req -days 3650 -in $server_csr_file -CA $server_ca_crt_file -CAkey $server_ca_key_file -set_serial 01 -extensions v3_req -extfile $keys_config_file -out $server_crt_file");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Unable to create server certificate $server_crt_file on $sys->{sys}");
        $msg->error();
        return 0;
    }

    # This command is just for testing. It will dump the certificate contents
    $sys->cmd("_cmd_openssl x509 -noout -text -in $server_crt_file") if (Cfg::opt('debug'));;

    # Remove temp files, and chmod for /var/VRTScps/security directory
    $sys->cmd("_cmd_rmr $keys_config_file $server_csr_file; _cmd_chmod -R 700 $pkg->{https_server_security_dir}");

    return 1;
}

# Need cleanup client private keys on the server when add a CP server
sub https_cleanup_client_keys_sys {
    my ($pkg,$server,$uuid) = @_;
    return 1 unless ($uuid);

    my $client_keys_dir=$pkg->{https_client_keys_dir};
    my $client_private_key_file="$client_keys_dir/client_private_". $uuid . ".key";

    $server->cmd("_cmd_rmr $client_private_key_file 2>/dev/null");
    return 1;
}

# Setup HTTPS trust between server and the system
#
# Only the following files are needed
#   1. /var/VRTSvxfen/security/keys/client_private.key
#   2. /var/VRTSvxfen/security/certs/ca_<xxxxx>.crt
#   3. /var/VRTSvxfen/security/certs/client_<xxxxx>.crt
#
sub https_setup_server_trust_sys {
    my ($pkg,$sys,$server,$uuid) = @_;
    my ($vcs,$vip,$msg);

    return 0 unless ($server);

    if (!$uuid) {
        $vcs = $pkg->prod('VCS61');
        $uuid = $vcs->get_uuid_sys($sys) || $sys->{sys};
    }

    my $server_keys_dir=$pkg->{https_server_keys_dir};
    my $server_certs_dir=$pkg->{https_server_certs_dir};
    my $server_ca_key_file="$server_keys_dir/ca.key";
    my $server_ca_crt_file="$server_certs_dir/ca.crt";

    my $client_keys_dir=$pkg->{https_client_keys_dir};
    my $client_certs_dir=$pkg->{https_client_certs_dir};
    # check if in the live upgrade
    my $rootpath=Cfg::opt('rootpath') || '';
    my $client_private_key_file="$rootpath$client_keys_dir/client_private.key";
    my $sys_private_key_file="$client_keys_dir/client_private_". $uuid . ".key";
    my $sys_csr_file="$client_certs_dir/client_" . $uuid . ".csr";
    my $sys_crt_file="$client_certs_dir/client_" . $uuid . ".crt";

    # The client_private.key should be created only one copy for different CP servers.
    # $sys->{server_private_key_ready}=1, means client_private_<uuid>.key is ready in server side
    # $sys->{client_private_key_ready}=1, means client_private.key is ready in client side
    if (!$server->exists($sys_private_key_file)) {
        $server->cmd("_cmd_mkdir -p $client_keys_dir");

        if ($sys->exists($client_private_key_file)) {
            # Copy the client private key to the server for later usage to create client certificate on the server.
            $sys->copy_to_sys($server,$client_private_key_file,$sys_private_key_file);
            $sys->{client_private_key_ready}=1;
        } else {
            $server->cmd("_cmd_openssl genrsa -out $sys_private_key_file 2048");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Unable to create private key $sys_private_key_file for $sys->{sys} on $server->{sys}");
                $msg->error();
                return 0;
            }
        }
        $server->{server_private_key_ready}=1;
    }

    # Need copy the client_pravite.key from server to client
    if (!$sys->{client_private_key_ready}) {
        $sys->cmd("_cmd_mkdir -p $rootpath$client_keys_dir");
        $server->copy_to_sys($sys,$sys_private_key_file,$client_private_key_file);
        $sys->{client_private_key_ready}=1;
        $server->{server_private_key_ready}=1;
    }

    # Need copy the client_pravite.key from client to server
    if (!$server->{server_private_key_ready}) {
        $server->cmd("_cmd_mkdir -p $client_keys_dir");
        $sys->copy_to_sys($server,$client_private_key_file,$sys_private_key_file);
        $server->{server_private_key_ready}=1;
    }

    $server->cmd("_cmd_mkdir -p $client_certs_dir");
    $sys->cmd("_cmd_mkdir -p $rootpath$client_certs_dir");

    $server->cmd("_cmd_openssl req -new -key $sys_private_key_file -subj '/C=IN/L=Pune/OU=VCS/CN=$uuid' -out $sys_csr_file");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Unable to create csr file $sys_csr_file for $sys->{sys} on $server->{sys}");
        $msg->error();
        return 0;
    }

    my ($server_date,$server_time,$client_date,$client_time,$start_date);
    my ($sec,$min,$hour,$mday,$mon,$year);
    $server_date = $server->cmd('_cmd_date -u +%S:%M:%H:%d:%m:%Y');
    $client_date = $sys->cmd('_cmd_date -u +%S:%M:%H:%d:%m:%Y');

    ($sec,$min,$hour,$mday,$mon,$year) = split(/:/m,$server_date);
    $server_time = Time::Local::timegm ($sec, $min, $hour, $mday, $mon - 1, $year);

    ($sec,$min,$hour,$mday,$mon,$year) = split(/:/m,$client_date);
    $client_time = Time::Local::timegm ($sec, $min, $hour, $mday, $mon - 1, $year);

    $start_date=$server_time;
    $start_date=$client_time if ($server_time > $client_time);

    $server->cmd("_cmd_openssl x509 -req -days 3650 -in $sys_csr_file -CA $server_ca_crt_file -CAkey $server_ca_key_file -set_serial 01 -out $sys_crt_file");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Unable to create certificate $sys_crt_file on $server->{sys}");
        $msg->error();
        return 0;
    }

    $vip=$server->{sys};
    $server->copy_to_sys($sys,$server_ca_crt_file,"$rootpath$client_certs_dir/ca_$vip.crt");
    $server->copy_to_sys($sys,$sys_crt_file,"$rootpath$client_certs_dir/client_$vip.crt");

    # Remove temp files, and chmod for /var/VRTSvxfen/security directory
    $server->cmd("_cmd_rmr $sys_csr_file; _cmd_chmod -R 700 $pkg->{https_client_security_dir}");
    $sys->cmd("_cmd_chmod -R 700 $rootpath$pkg->{https_client_security_dir}");

    return 1;
}

sub https_create_server {
    my ($pkg,$conf) = @_;

    my $server = ${CPIC::get('systems')}[0];

    # Generate server keys and certs
    $pkg->https_create_server_keys_certs_sys($server,$conf);

    return 0;
}

sub https_setup_trust {
    my ($pkg,$systems,$servers,$uuid) = @_;
    my ($sys0,$vcs);

    $systems ||= CPIC::get('systems');
    $sys0 = $systems->[0];
    $servers ||= [ $sys0 ];

    if (!$uuid) {
        $vcs = $pkg->prod('VCS61');
        $uuid = $vcs->get_uuid_sys($sys0) || $sys0->{sys};
    }

    for my $server (@$servers) {
        for my $sys (@$systems) {
            $pkg->https_setup_server_trust_sys($sys,$server,$uuid);
        }
    }

    return 0;
}

# Configure the https for CP server(s)
sub https_config {
    my ($pkg,$config_flag,$conf) = @_;

    if ($config_flag->{sfha_config}) {
        return 1 if $pkg->https_config_sfha($conf);
    } else {
        return 1 if $pkg->https_config_delete_old_security();
    }

    return 1 if $pkg->https_create_server($conf);
    return 1 if $pkg->https_setup_trust();
    return 0;
}

# Prepare the softlink for CA creds
sub https_config_sfha {
    my ($pkg,$conf) = @_;
    my ($sys0,$msg,$waittime,$dbpath,$secpath);

    $sys0 = ${CPIC::get('systems')}[0];
    $dbpath = "$conf->{cps_db_dir}/security";
    $secpath = '/var/VRTScps/security';

    # Online mount resource on current node for SFHA cluster in secure mode
    # and generate the credentials for CP server in shared directory
    $sys0->cmd("_cmd_hares -online cpsmount -sys $sys0->{vcs_sysname}");
    ## Wait for the mount resource to come online
    ## 120 secs should be sufficient to bring the cpsmount to come online along with the parent resources
    $waittime=120;
    $msg = Msg::new("Trying to bring cpsmount resource ONLINE and will wait for upto $waittime seconds");
    $msg->nprint;
    $sys0->cmd("_cmd_hares -wait cpsmount State ONLINE -sys $sys0->{vcs_sysname} -time $waittime");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Mount resource for CPS does not come online");
        $msg->error;
        return 1;
    } else {
        $msg = Msg::new("Mount resource for CPS is ONLINE");
        $msg->print;
    }

    $sys0->cmd("_cmd_mkdir -p $dbpath 2>/dev/null");

    # Check and remove if the directory or symlink already exists at the default location
    for my $sys(@{CPIC::get('systems')}) {
        if ($sys->exists($secpath)) {
            $sys->cmd("_cmd_rmr $secpath");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Unable to delete $secpath on $sys->{sys}");
                $msg->error();
                return 1;
            }
        }
        $sys->cmd("_cmd_mkdir -p /var/VRTScps 2>/dev/null");

        # Creating softlink from the default CPS credential directory to the credential directory on shared storage
        $msg = Msg::new("Creating softlink $secpath to $dbpath on $sys->{sys}");
        $msg->nprint;
        $sys->cmd("_cmd_ln -s $dbpath $secpath");
        if (EDR::cmdexit()) {
            Msg::n();
            $msg = Msg::new("Unable to create softlink $secpath to $dbpath on $sys->{sys}");
            $msg->error();
            return 1;
        } else {
            $msg = Msg::new("Successfully created softlink $secpath to $dbpath on $sys->{sys}");
            $msg->nprint;
        }
    }

    return 0;
}

# Check and remove if the directory or symlink already exists at the default location
sub https_config_delete_old_security {
    my ($pkg) = @_;
    my ($secpath,$msg);

    $secpath = '/var/VRTScps/security';

    for my $sys(@{CPIC::get('systems')}) {
        if ($sys->exists($secpath)) {
            $sys->cmd("_cmd_rmr $secpath");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Unable to delete $secpath on $sys->{sys}");
                $msg->error();
                return 1;
            }
        }
        $sys->cmd("_cmd_mkdir -p /var/VRTScps 2>/dev/null");
    }
    return 0;
}

#To configure https cps, openssl needs to be installed
#return 1 if it is installed
#return 0 if not
sub https_check_openssl {
    my ($pkg) = @_;
    my ($out,$msg,$web,@systems,@badnodes,$badnodes);

    @badnodes = ();
    @systems = @{CPIC::get('systems')};
    for my $sys (@systems) {
        $out = $sys->cmd("_cmd_openssl version");
        if (EDR::cmdexit()) {
            push(@badnodes,$sys->{sys});
        }
    }

    if (scalar @badnodes) {
        $web = Obj::web();
        $badnodes = join(', ', @badnodes);
        $msg = Msg::new("CP server could not be configured without openssl installed, please first install openssl on $badnodes");
        $msg->nprint();
        Msg::n();
        $web->{complete_failed}=1;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        return 0;
    }

    return 1;
}

#   configure prechecks include:
#   1. VCS is not running on the system
sub configure_precheck_sys {
    my ($pkg,$sys) = @_;
    my ($msg,$out,$vcs,$web);
    $web = Obj::web();
    $vcs = $pkg->prod('VCS61');
    return 0 unless $pkg->https_check_openssl($sys);
    if ($pkg->{mandate_vcs}) {
        $out = $sys->cmd("_cmd_hasys -state");
        if (EDR::cmdexit()) {
            $msg = Msg::new("$vcs->{name} is not running on the node. CP server requires $vcs->{name} to be installed and configured. Please bring up VCS on the node before configuring CP server.");
            $msg->nprint();
            Msg::n();
            $web->{complete_failed}=1;
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            return 0;
        }
    }
    return 1;
}

sub check_and_unconfigure_cps_sys {
    my ($pkg,$sys) = (@_);
    my ($ayn,$cfg,$cpssg,$cpservers,$msg);
    $cfg = Obj::cfg();
    ($cpssg,$cpservers) = $pkg->get_cpssg_cpservers_sys($sys);
    return 0 if (!$cpssg);
    $msg = Msg::new("CP server service group is already present in vcs configuration. If you want to reconfigure the server, installer will unconfigure it first before reconfiguration.");
    $msg->printn;
    $msg = Msg::new("Unconfiguring coordination point server stops the vxcpserv process. VCS clusters using this server for coordination purpose will have one less coordination point. Are you sure you want to take the CP server offline?");
    if (Cfg::opt('responsefile')) {
        $ayn = ($cfg->{cps_reconfig}) ? 'Y' : 'N' ;
    } else {
        $ayn = $msg->aynn();
    }
    return 2 if ($ayn eq 'N');
    $cfg->{cps_reconfig} = 1;
    return $pkg->stop_and_remove_cps_from_vcs($cpssg,$cpservers);
}

sub verify_responsefile {
    my $pkg = shift;
    my ($cfg,$msg,$num,$sys0,$vxfen_pkg,$vm);
    my (@nics,@nw_hosts,@ports,@systems,@vips);
    my ($nic_prefix,$vip_prefix);
    $cfg = Obj::cfg();
    @systems = @{CPIC::get('systems')};
    $sys0 = $systems[0];
    $vm = $pkg->prod('VM61');
    $vxfen_pkg = $pkg->pkg('VRTSvxfen61');
    $nic_prefix = 'cpsnic';
    $vip_prefix = 'cpsvip';

    if (!$cfg->{opt}{configcps}) {
        $msg = Msg::new("\$CFG{opt}{configcps} must be set in responsefile");
        $msg->die;
    }
    if (!$cfg->{cps_sfha_config} && !$cfg->{cps_singlenode_config} && !$cfg->{cps_unconfig}) {
        $msg = Msg::new("\$CFG{cps_sfha_config}, \$CFG{cps_singlenode_config} or \$CFG{cps_unconfig} must be set in responsefile");
        $msg->die;
    }
    if (($cfg->{cps_sfha_config} && $cfg->{cps_singlenode_config}) ||
        ($cfg->{cps_sfha_config} && $cfg->{cps_unconfig}) ||
        ($cfg->{cps_singlenode_config} && $cfg->{cps_unconfig})) {
        $msg = Msg::new("\$CFG{cps_sfha_config}, \$CFG{cps_singlenode_config} or \$CFG{cps_unconfig} cannot be set in responsefile at the same time");
        $msg->die;
    }
    if ($cfg->{cps_singlenode_config} || $cfg->{cps_sfha_config}) {
        if ((!$cfg->{cps_db_dir}) || (!$cfg->{cpsname}) || (!defined($cfg->{cps_security})) || (!$cfg->{cps_https_vips}) ||
             (!$cfg->{cps_https_ports}) || (!$cfg->{cps_nic_list}) || (!$cfg->{cps_vip2nicres_map})) {
            $msg = Msg::new("\$CFG{cpsname}, \$CFG{cps_db_dir}, \$CFG{cps_https_vips}, \$CFG{cps_https_ports}, \$CFG{cps_nic_list}, \$CFG{cps_vip2nicres_map}, \$CFG{cps_security} must be set in responsefile");
            $msg->die;
        }
        if (!$pkg->validate_cps_db_dir_name($cfg->{cps_db_dir})) {
            $msg = Msg::new("\$CFG{cps_db_dir} in responsefile has an invalid value");
            $msg->die;
        }
        if (!check_systemname($cfg->{cpsname})) {
            $msg = Msg::new("\$CFG{cpsname} in responsefile has an invalid value");
            $msg->die;
        }
        if (($cfg->{cps_security} != 0) && ($cfg->{cps_security} != 1)) {
            $msg = Msg::new("\$CFG{cps_security} in responsefile has an invalid value");
            $msg->die;
        }

        if (ref($cfg->{cps_https_vips}) ne "ARRAY") {
            $msg = Msg::new("\$CFG{cps_https_vips} in responsefile is not a reference to an array");
            $msg->die;
        }
        @vips = @{$cfg->{cps_https_vips}};

        if ($cfg->{cps_ipm_vips}) {
            if (ref($cfg->{cps_ipm_vips}) ne "ARRAY") {
                $msg = Msg::new("\$CFG{cps_ipm_vips} in responsefile is not a reference to an array");
                $msg->die;
            } else {
                push(@vips,@{$cfg->{cps_ipm_vips}}) if ($cfg->{cps_ipm_vips});
            }
        }

        if (!EDRu::arr_isuniq(@vips)) {
            $msg = Msg::new("\$CFG{cps_https_vips} or \$CFG{cps_ipm_vips} in responsefile has duplicate value");
            $msg->die;
        }
        for my $vip(@vips) {
            if (!EDRu::is_ip_valid($vip)) {
                $msg = Msg::new("\$CFG{cps_https_vips} or \$CFG{cps_ipm_vips} in responsefile has an invalid value");
                $msg->die;
            }
        }
        if (ref($cfg->{cps_https_ports}) ne "ARRAY") {
            $msg = Msg::new("\$CFG{cps_https_ports} in responsefile is not a reference to an array");
            $msg->die;
        }
        @ports = @{$cfg->{cps_https_ports}};

        if ($cfg->{cps_ipm_ports}) {
            if (ref($cfg->{cps_ipm_ports}) ne "ARRAY") {
                $msg = Msg::new("\$CFG{cps_ipm_ports} in responsefile is not a reference to an array");
                $msg->die;
            } else {
                push(@ports,@{$cfg->{cps_ipm_ports}}) if ($cfg->{cps_ipm_ports});
            }
        }

        for my $port(@ports) {
            if (!Pkg::VRTSvxfen61::Common::validate_cps_port($port,$pkg->{defport},$pkg->{default_https_port})) {
                $msg = Msg::new("\$CFG{cps_https_ports} or \$CFG{cps_ipm_ports} in responsefile has an invalid value");
                $msg->die;
            }
        }

        # verify cps_nic_list, cps_network_hosts and cps_vip2nicres_map
        for my $vipkey(keys %{$cfg->{cps_nic_list}}) {
            if ($vipkey =~ /^$vip_prefix(\d+)$/m) {
                $num = $1;
                if (($num < 1) || ($num > (scalar @vips))) {
                    $msg = Msg::new("\$CFG{cps_nic_list} in responsefile has an invalid value");
                    $msg->die;
                }
                if (ref($cfg->{cps_nic_list}{"$vipkey"}) ne "ARRAY") {
                    $msg = Msg::new("\$CFG{cps_nic_list} in responsefile has an invalid value");
                    $msg->die;
                }

                @nics = @{$cfg->{cps_nic_list}{"$vipkey"}};
                if ($#nics != $#systems) {
                    $msg = Msg::new("\$CFG{cps_nic_list} in responsefile has an invalid value");
                    $msg->die;
                }
            } else {
                $msg = Msg::new("\$CFG{cps_nic_list} in responsefile has an invalid value");
                $msg->die;
            }
        }
        for my $vipkey(keys %{$cfg->{cps_vip2nicres_map}}) {
            if (!EDRu::inarr($vipkey,@vips)) {
                $msg = Msg::new("\$CFG{cps_vip2nicres_map} in responsefile has an invalid value");
                $msg->die;
            }
            $num = $cfg->{cps_vip2nicres_map}{"$vipkey"};
            if (($num < 1) || ($num > (scalar @vips))) {
                $msg = Msg::new("\$CFG{cps_vip2nicres_map} in responsefile has an invalid value");
                $msg->die;
            }
        }
        if (!$cfg->{cps_netmasks} && !$cfg->{cps_prefix_length}) {
            $msg = Msg::new("\$CFG{cps_netmasks} or \$CFG{cps_prefix_length} must be set in responsefile");
            $msg->die;
        } elsif ($cfg->{cps_netmasks}) {
           if (ref($cfg->{cps_netmasks}) ne "ARRAY") {
                $msg = Msg::new("\$CFG{cps_netmasks} in responsefile is not a reference to an array");
                $msg->die;
           }
            for my $netmask(@{$cfg->{cps_netmasks}}) {
                if (!EDRu::ip_is_ipv4($netmask) || ($netmask =~ /^0+\./m)) {
                    $msg = Msg::new("\$CFG{cps_netmasks} in responsefile has an invalid value");
                    $msg->die;
                }
            }
        } elsif ($cfg->{cps_prefix_length}) {
           if (ref($cfg->{cps_prefix_length}) ne "ARRAY") {
                $msg = Msg::new("\$CFG{cps_prefix_length} in responsefile has an invalid value");
                $msg->die;
           }
            for my $prefix_len(@{$cfg->{cps_prefix_length}}) {
                if (!$pkg->validate_prefix_length($prefix_len)) {
                    $msg = Msg::new("\$CFG{cps_prefix_length} in responsefile has an invalid value");
                    $msg->die;
                }
            }
        }
        for my $nickey(keys %{$cfg->{cps_network_hosts}}) {
            if ($nickey =~ /^$nic_prefix(\d+)/m) {
                $num = $1;
                if ($num < 1) {
                    $msg = Msg::new("\$CFG{cps_network_hosts} in responsefile has an invalid value");
                    $msg->die;
                }
                if (ref($cfg->{cps_network_hosts}{"$nickey"}) ne "ARRAY") {
                    $msg = Msg::new("\$CFG{cps_network_hosts} in responsefile has an invalid value");
                    $msg->die;
                }
                @nw_hosts = @{$cfg->{cps_network_hosts}{"$nickey"}};
                for my $nw_host(@nw_hosts) {
                    if (!EDRu::is_ip_valid($nw_host)) {
                        $msg = Msg::new("\$CFG{cps_network_hosts} in responsefile has an invalid value");
                        $msg->die;
                    }
                }
            } else {
                $msg = Msg::new("\$CFG{cps_network_hosts} in responsefile has an invalid value");
                $msg->die;
            }
        }
        if ($cfg->{cps_fips_mode} && ($cfg->{cps_fips_mode} != 0) && ($cfg->{cps_fips_mode} != 1)) {
            $msg = Msg::new("\$CFG{cps_fips_mode} in responsefile has an invalid value");
            $msg->die;
        }
        if ($cfg->{cps_sfha_config}) {
            if ((!$cfg->{cps_diskgroup}) || (!$cfg->{cps_volume})) {
                $msg = Msg::new("\$CFG{cps_diskgroup}, \$CFG{cps_volume} must be set in responsefile");
                $msg->die;
            }
            # $cfg->{cps_diskgroup} $cfg->{cps_volume} $cfg->{cps_newdg_disks} $cfg->{cps_newvol_volsize}
            if (!$vxfen_pkg->validate_dgname($cfg->{cps_diskgroup})) {
                $msg = Msg::new("\$CFG{cps_diskgroup} in responsefile has an invalid value");
                $msg->die;
            }
            if (!$pkg->validate_dg_vol_name($cfg->{cps_volume})) {
                $msg = Msg::new("\$CFG{cps_volume} in responsefile has an invalid value");
                $msg->die;
            }
            if ($cfg->{cps_newvol_volsize}) {
                if (!$pkg->validate_vol_size($pkg->{cpsvol_min_size},$cfg->{cps_newvol_volsize})) {
                    $msg = Msg::new("\$CFG{cps_newvol_volsize} in responsefile has an invalid value");
                    $msg->die;
                }
            }
            if (!$cfg->{cps_newdg_disks}) {
                # using existing dg
                if (!$vxfen_pkg->validate_diskgroup($cfg->{cps_diskgroup})) {
                    $msg = Msg::new("$cfg->{cps_diskgroup} does not exist on all the systems");
                    $msg->die;
                }
                # using existing diskgroup
                $sys0->cmd("_cmd_vxdg -q list 2> /dev/null | _cmd_grep -w $cfg->{cps_diskgroup}");
                if (EDR::cmdexit()) {
                    $sys0->cmd("_cmd_vxdg -t import $cfg->{cps_diskgroup}");
                }
                if (EDR::cmdexit()) {
                    $msg = Msg::new("Failed to import $cfg->{cps_diskgroup} on $sys0->{sys}");
                    $msg->die;
                }
                if ($cfg->{cps_newvol_volsize}) {
                    # creating new vol on existing dg
                    if ($vm->validate_vol_sys($sys0, $cfg->{cps_volume}, $cfg->{cps_newvol_volsize}, 0, $cfg->{cps_diskgroup}, $cfg->{cps_enable_mirroring})) {
                        $msg = Msg::new("Failed to check $cfg->{cps_volume} on $sys0->{sys}");
                        $msg->die;
                    }
                } else {
                    # using existing vol on existing dg
                    $sys0->cmd("_cmd_vxprint -g $cfg->{cps_diskgroup} $cfg->{cps_volume}");
                    if (EDR::cmdexit()) {
                        $msg = Msg::new("Failed to check $cfg->{cps_volume} on $sys0->{sys}");
                        $msg->die;
                    }
                }
            } else {
                # creating new dg and vol
                if (!$cfg->{cps_newvol_volsize}) {
                    $msg = Msg::new("\$CFG{cps_newvol_volsize} must be set in responsefile");
                    $msg->die;
                }
                if (!$vxfen_pkg->validate_diskgroup($cfg->{cps_diskgroup},1)) {
                    $msg = Msg::new("$cfg->{cps_diskgroup} already exists on the systems");
                    $msg->die;
                }
            }
        }
    }
    return;
}

sub responsefile_comments_for_cps {
    my ($cfg,$cmt,$edr);
    $cfg=Obj::cfg();
    $edr=Obj::edr();
    $cmt=Msg::new("This variable performs CP server configuration task");
    $edr->{rfc}{opt__configcps}=[$cmt->{msg},1,0,0];
    $cmt=Msg::new("This variable defines if the CP server will be configured on a singlenode VCS cluster");
    $edr->{rfc}{cps_singlenode_config}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines if the CP server will be configured on a SFHA cluster");
    $edr->{rfc}{cps_sfha_config}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines if the CP server will be unconfigured");
    $edr->{rfc}{cps_unconfig}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines if the CP server will be reconfigured");
    $edr->{rfc}{cps_reconfig}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the name of the CP server");
    $edr->{rfc}{cpsname}=[$cmt->{msg},1,0,0];
    $cmt=Msg::new("This variable defines the absolute path of CP server database");
    $edr->{rfc}{cps_db_dir}=[$cmt->{msg},1,0,0];
    $cmt=Msg::new("This variable defines if security is configured for the CP server");
    $edr->{rfc}{cps_security}=[$cmt->{msg},1,0,0];
    $cmt=Msg::new("This variable defines if security with fips is configured for the CP server");
    $edr->{rfc}{cps_fips_mode}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines if reusing the existing credentials for the CP server");
    $edr->{rfc}{cps_reuse_cred}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the virtual IP addresses for the HTTPS CP server");
    $edr->{rfc}{cps_https_vips}=[$cmt->{msg},1,1,0];
    $cmt=Msg::new("This variable defines the port number for the virtual IP addresses for the HTTPS CP server");
    $edr->{rfc}{cps_https_ports}=[$cmt->{msg},1,1,0];
    $cmt=Msg::new("This variable defines the virtual IP addresses for the IPM CP server");
    $edr->{rfc}{cps_ipm_vips}=[$cmt->{msg},1,1,0];
    $cmt=Msg::new("This variable defines the port number for the virtual IP addresses for the IPM CP server");
    $edr->{rfc}{cps_ipm_ports}=[$cmt->{msg},1,1,0];
    $cmt=Msg::new("This variable defines the NICs of the systems for the virtual IP address");
    $edr->{rfc}{cps_nic_list}=[$cmt->{msg},1,1,1,"cpsvip"];
    $cmt=Msg::new("This variable defines the netmasks for the virtual IP addresses");
    $edr->{rfc}{cps_netmasks}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the prefix length for the virtual IP addresses");
    $edr->{rfc}{cps_prefix_length}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the network hosts for the NIC resource");
    $edr->{rfc}{cps_network_hosts}=[$cmt->{msg},0,1,1,"cpsnic"];
    $cmt=Msg::new("This variable defines the NIC resource to associate with the virtual IP address");
    $edr->{rfc}{cps_vip2nicres_map}=[$cmt->{msg},1,0,1,"vip"];
    $cmt=Msg::new("This variable defines the disk group for the CP server database");
    $edr->{rfc}{cps_diskgroup}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the volume for the CP server database");
    $edr->{rfc}{cps_volume}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the disks to be used to create a new disk group for the CP server database");
    $edr->{rfc}{cps_newdg_disks}=[$cmt->{msg},0,1,0];
    $cmt=Msg::new("This variable defines the volume size to create a new volume for the CP server database");
    $edr->{rfc}{cps_newvol_volsize}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines deleting the database of the CP server during unconfiguration");
    $edr->{rfc}{cps_delete_database}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines deleting the config files and log files of the CP server during unconfiguration");
    $edr->{rfc}{cps_delete_config_log}=[$cmt->{msg},0,0,0];
    return;
}

package Pkg::VRTScps61::AIX;
@Pkg::VRTScps61::AIX::ISA = qw(Pkg::VRTScps61::Common);

package Pkg::VRTScps61::HPUX;
@Pkg::VRTScps61::HPUX::ISA = qw(Pkg::VRTScps61::Common);

package Pkg::VRTScps61::Linux;
@Pkg::VRTScps61::Linux::ISA = qw(Pkg::VRTScps61::Common);

package Pkg::VRTScps61::RHEL5x8664;
@Pkg::VRTScps61::RHEL5x8664::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "libcrypt.so.1"  =>  "glibc-2.5-49.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-49.i686",
        "libdl.so.2"  =>  "glibc-2.5-49.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-48.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-48.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-48.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-48.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-49.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libnsl.so.1"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-49.i686",
        "libresolv.so.2"  =>  "glibc-2.5-49.i686",
        "librt.so.1"  =>  "glibc-2.5-49.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-48.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-48.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-48.el5.i386",
        "libz.so.1"  =>  "zlib-1.2.3-3.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "libcrypt.so.1"  =>  "glibc-2.5-58.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "libresolv.so.2"  =>  "glibc-2.5-58.i686",
        "librt.so.1"  =>  "glibc-2.5-58.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "libcrypt.so.1"  =>  "glibc-2.5-65.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-65.i686",
        "libdl.so.2"  =>  "glibc-2.5-65.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-51.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-51.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-51.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-51.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-65.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libnsl.so.1"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-65.i686",
        "libresolv.so.2"  =>  "glibc-2.5-65.i686",
        "librt.so.1"  =>  "glibc-2.5-65.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-51.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-51.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-51.el5.i386",
        "libz.so.1"  =>  "zlib-1.2.3-4.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",    
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "libcrypt.so.1"  =>  "glibc-2.5-81.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-81.i686",
        "libdl.so.2"  =>  "glibc-2.5-81.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-52.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-52.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-52.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-52.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-81.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libnsl.so.1"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-81.i686",
        "libresolv.so.2"  =>  "glibc-2.5-81.i686",
        "librt.so.1"  =>  "glibc-2.5-81.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-52.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-52.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-52.el5.i386",
        "libz.so.1"  =>  "zlib-1.2.3-4.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "libcrypt.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-54.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-54.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-54.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-54.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libnsl.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libresolv.so.2"  =>  "glibc-2.5-107.el5_9.4.i686",
        "librt.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-54.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-54.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-54.el5.i386",
        "libz.so.1"  =>  "zlib-1.2.3-7.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTScps61::RHEL6x8664;
@Pkg::VRTScps61::RHEL6x8664::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.6-4.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.6-4.el6.i686",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.4.6-4.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.6-4.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libresolv.so.2"  =>  "glibc-2.12-1.80.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4.11)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4.9)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.7-3.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.7-3.el6.i686",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.4.7-3.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.7-3.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libresolv.so.2"  =>  "glibc-2.12-1.107.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4.11)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4.9)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.7-4.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.7-4.el6.i686",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.4.7-4.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.7-4.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libresolv.so.2"  =>  "glibc-2.12-1.132.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4.11)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4.9)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.x86_64",
    };
    return;
}

package Pkg::VRTScps61::SLES10x8664;
@Pkg::VRTScps61::SLES10x8664::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_4.2.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTScps61::SLES11x8664;
@Pkg::VRTScps61::SLES11x8664::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libgcc_s.so.1"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libstdc++.so.6"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.9)"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libz.so.1"  =>  "zlib-32bit-1.2.3-106.34.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libgcc_s.so.1"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libm.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libstdc++.so.6"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4.9)"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libz.so.1"  =>  "zlib-32bit-1.2.7-0.10.128.x86_64",
    };
    return;
}

package Pkg::VRTScps61::RHEL5ppc64;
@Pkg::VRTScps61::RHEL5ppc64::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libcrypt.so.1'  =>  'glibc-2.5-24.ppc',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.3)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_4.1.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libm.so.6'  =>  'glibc-2.5-24.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libresolv.so.2'  =>  'glibc-2.5-24.ppc',
        'libresolv.so.2(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'librt.so.1'  =>  'glibc-2.5-24.ppc',
        'librt.so.1(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTScps61::SLES10ppc64;
@Pkg::VRTScps61::SLES10ppc64::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_4.1.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libm.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libresolv.so.2'  =>  'glibc-2.4-31.54.ppc',
        'librt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'librt.so.1(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
    };
    return;
}

package Pkg::VRTScps61::SLES11ppc64;
@Pkg::VRTScps61::SLES11ppc64::ISA = qw(Pkg::VRTScps61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libgcc_s.so.1'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_4.1.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libm.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.6)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libresolv.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'librt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'librt.so.1(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libstdc++.so.6'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
    };
    return;
}

package Pkg::VRTScps61::SunOS;
@Pkg::VRTScps61::SunOS::ISA = qw(Pkg::VRTScps61::Common);

sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($rootpath,$vers);

    $rootpath=Cfg::opt('rootpath')||'';
    $vers = $pkg->version_sys($sys);
    # Remove VRTScps preremove scripts on ABE during Live Upgrade.
    if (Cfg::opt('upgrade') && $rootpath
        && (EDRu::compvers($vers,'6.0')==2)) {
        $sys->rm("$rootpath/var/sadm/pkg/$pkg->{pkg}/install/preremove");
    }
    return;
}

1;
