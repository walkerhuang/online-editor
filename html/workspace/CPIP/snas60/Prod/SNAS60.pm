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

package Prod::SNAS60::Common;
@Prod::SNAS60::Common::ISA = qw(Prod::SFCFSHA61::Common);

sub responsefile_prestart_config {
    my ($prod) = @_;
    my ($ret,$msg,$cpic);
    $cpic=Obj::cpic();
    $ret = $prod->op_nic_hostname();
    if ($ret == 0 || $ret == 2) {
        $msg = Msg::new("NIC detection error. Double check the environment.");
        $msg->error();
        $cpic->edr_completion();
        return; 
    }
    $prod->perform_task('responsefile_prestart_config');
    $prod->ssh_com_setup(CPIC::get('systems'));
    return;
}

sub cli_prod_option {
    my $prod = shift;
    $prod->perform_task('cli_prod_option');
    $prod->{default_config} = 1;
    $prod->opt_addnode() if (Cfg::opt('addnode'));
    $prod->opt_delnode() if (Cfg::opt('delnode'));
    $prod->opt_update_parameter() if (Cfg::opt('updateparameter'));
    $prod->opt_snas_upgrade() if (Cfg::opt('snas_upgrade'));
    #$prod->opt_upgrade();
    return;
}

sub opt_snas_upgrade {
    my $prod = shift;
    for my $sub (qw(upgrade_check_version upgrade_precheck)) {
        if ($prod->can($sub)) {
            $prod->$sub();
        }
    }
    return;
}
sub upgrade_precheck {
    my ($prod) = @_;
    my $rel = Obj::rel();
    my $localsys = Obj::edr()->{localsys};
    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();
    my ($msg, $rpmpath, $pkglist, $ru_require);

    my $syslist = $rel->ru_confirm_cluster($localsys);
    $cfg->{systems}=$syslist;
    $cpic->systems();

    #if only hotfix invloved, we do simple upgrade or phase upgrade
    if (!$prod->{upgrade}{base_path} && !$prod->{upgrade}{mr_path} && $prod->{upgrade}{hf_path}) {
	    $cpic->set_install_pkgs();
	    for my $sys (@{$cpic->{systems}}) {
		    for my $patchi (@{$sys->{installpatches}}) {
			    unless (grep {$patchi =~ /$_/} @{$prod->{silent_upgrade}}) {
				    $ru_require = 1;
				    last;
			    }
		    }
		    last if ($ru_require);
	    }
    } else {
	    $ru_require = 1;
    }
    if ($ru_require) {
	    #for mr or major release, we do rolling upgrade
	    for my $sysname (@{$syslist}) {
		    my $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
		    if($rel->ru_precheck_sys($sys,1)!=1) {
			    $msg = Msg::new("Rolling upgrade precheck failed");
			    $msg->die();
		    }
	    }
	    for my $sub (qw(upgrade_save_configfile upgrade_ru_install)) {
		    if ($prod->can($sub)) {
			    $prod->$sub();
		    }
	    }

    } else {
	    #do simple upgrade if there is just SYMCsnas 
	    $msg = Msg::new("This upgrade process does not have any application downtime.");
	    $msg->bold();
	    $cpic->set_pkgs();
	    $cpic->install();
    }
    $cpic->edr_completion();  
    return 1;
}

sub upgrade_ru_install {
    my ($prod) = @_;
    my ($response, $cmd, $img_path, $script_name, $msg);
    my $tmpdir = EDR::get('tmpdir');
    my $resfile = "$tmpdir/ru.res";
    my $resfile = $prod->{ru_response};
    my $cpic = Obj::cpic();

    if ($prod->{upgrade}{mr_path}) {
        $img_path = $prod->{upgrade}{mr_path};
        if ($prod->{upgrade}{base_path}) {
            $response->{opt}{base_path} = $prod->{upgrade}{base_path};
        }
        if ($prod->{upgrade}{hf_path}) {
            $response->{opt}{hotfix_path} = $prod->{upgrade}{hf_path};
        }
    } elsif ($prod->{upgrade}{base_path}) {
        $img_path = $prod->{upgrade}{base_path};
        if ($prod->{upgrade}{hf_path}) {
            $response->{opt}{hotfix_path} = $prod->{upgrade}{hf_path};
        }
    } elsif ($prod->{upgrade}{hf_path}) {
        $img_path = $prod->{upgrade}{hf_path};
    } else {
        $msg = Msg::new("Nothing will be installed on cluster");
        $msg->die();
    }

    $script_name = EDR::cmd_local("_cmd_ls $img_path | _cmd_grep '^install*'");
    if (!$script_name) {
        $msg = Msg::new("Nothing will be installed in the cluster since no install script exists in the repository");
        $msg->die();
    }
    $cmd = "$img_path/$script_name";
    $prod->create_ru_responsefile($response, $resfile);

    $cmd .= " -responsefile $resfile > $prod->{upgrade_log} &";
    $msg = Msg::new("\nThe upgrade has started. Run 'cluster show' to see the progress of the upgrade. Upgrade details are saved at $prod->{upgrade_log}.");
    $msg->bold();
    system($cmd);
    $cpic->edr_completion();  
}

sub upgrade_check_version {
    my ($prod, $version) = @_;
    my $rel = Obj::rel();
    my $cpic = Obj::cpic();
    my ($localsys, $repository_path, $count, $img_path, $msg, $level, $current_version);
    my ($base_version, $mr_version, $hf_version);
    $version = $rel->{vers};
    $localsys = Obj::edr()->{localsys};
    $prod->read_preference_file_sys($localsys);
    $repository_path = $prod->get_repository_on_sys($localsys);

    if ($localsys->{store_release_imgs}{"InstalledHF"}) {
        $current_version = $localsys->{store_release_imgs}{"InstalledHF"};
    } elsif ($localsys->{store_release_imgs}{"InstalledMR"}) {
        $current_version = $localsys->{store_release_imgs}{"InstalledMR"};
    } elsif ($localsys->{store_release_imgs}{"InstalledBase"}) {
        $current_version = $localsys->{store_release_imgs}{"InstalledBase"};
    } else {
        $msg = Msg::new("No $prod->{abbr} product installed on $localsys->{sys}");
        $msg->die();
    }

    if (EDRu::compvers($current_version, $version, 4) != 2) {
        $msg = Msg::new("The current version $current_version is not lower than the version $version");
        $msg->die();
    }

    my @arr_vers = split(/\./, $version);
    if (EDRu::compvers($current_version, $version, 2)) {
        if ($arr_vers[2]) {
            $mr_version = "$arr_vers[0].$arr_vers[1].$arr_vers[2].0";
        } else {
            $base_version = "$arr_vers[0].$arr_vers[1].0.0";
        }
        $hf_version = "$arr_vers[0].$arr_vers[1].$arr_vers[2].$arr_vers[3]" if ($arr_vers[3]);
    } elsif (EDRu::compvers($current_version, $version, 3)) {
        $mr_version = "$arr_vers[0].$arr_vers[1].$arr_vers[2].0";
        $hf_version = "$arr_vers[0].$arr_vers[1].$arr_vers[2].$arr_vers[3]" if ($arr_vers[3]);
    } elsif (EDRu::compvers($current_version, $version, 4)) {
        $hf_version = $version;
    }

    #check repository
    if ($base_version) {
        $img_path = "$repository_path/ga/images/SSNAS/$base_version";
        if (!$prod->img_stored_on_sys($localsys, $img_path)) {
            $msg = Msg::new("Image $base_version is not stored on the system.");
            $msg->die();
        } else {
            $prod->{upgrade}{base_path} = $img_path;
        }
    }
    if ($mr_version) {
        $img_path = "$repository_path/patch/images/SSNAS/$mr_version";
        if (!$prod->img_stored_on_sys($localsys, $img_path)) {
            $msg = Msg::new("Image $mr_version is not stored on system.");
            $msg->die();
        } else {
            $prod->{upgrade}{mr_path} = $img_path;
        }
    }
    if ($hf_version) {
        $img_path = "$repository_path/hf/images/SSNAS/$hf_version";
        if (!$prod->img_stored_on_sys($localsys, $img_path)) {
            $msg = Msg::new("Image $hf_version is not stored on system.");
            $msg->die();
        } else {
            $prod->{upgrade}{hf_path} = $img_path;
        }
    }
}

sub opt_addnode {
    my $prod = shift;
    my $vcs = $prod->prod('VCS61');
    for my $sub (qw(addnode_messages addnode_get_cluster addnode_get_newnode addnode_compare_systems 
                    addnode_preconfig_newnode addnode_config_snas addnode_configure_heartbeat 
                    addnode_configure_cluster addnode_start_cluster addnode_poststart addnode_completion))
    {
        if ($prod->can($sub)) {
            $prod->$sub();
        } else {
            $vcs->$sub();
        }     
    }
    return;
}

sub opt_delnode {
    my $prod = shift;
    my $vcs = $prod->prod('VCS61');
    for my $sub (qw(delnode_precheck delnode delnode_completion))
    {
        if ($prod->can($sub)) {
            $prod->$sub();
        } else {
            $vcs->$sub();
        }     
    }
    return;
}

sub cli_print_requirements {
    my ($prod) = @_;
    my ($otherreqs,$prodspace,$rel,$msg,$platreqs,$platreqs_str,$ps,@space,$prodname,$pkg,$pkgspace);
    $rel=$prod->rel;

    $prodname = $prod->{name};
    $msg=Msg::new("The requirements for the product '$prodname':\n");
    $msg->print;

    $platreqs = $prod->{platreqs} || $rel->{platreqs};
    if (defined $platreqs) {
        $platreqs_str=join("\n",@{$platreqs});
        $msg=Msg::new("Required minimum OS/kernel versions:\n$platreqs_str");
        $msg->print;
    }

    $prod->cli_print_os_dependency();

    if ($prod->{minimal_memory_requirment}) {
        $msg=Msg::new("\nMinimum Memory Required: $prod->{minimal_memory_requirment}");
        $msg->print;
    }

    # Determine the space requirement for the product
    for my $pkgi (@{$prod->get_pkgs}) {
        $pkg=$prod->pkg($pkgi);
        $pkg->{space} = $pkg->space();
        $pkg->{space}||=[100,100,100,100];
        @space=@{$pkg->{space}};
        $pkgspace=$space[0]+$space[1]+$space[2]+$space[3];
        $prodspace+=$pkgspace;
    }
    $ps=int($prodspace/1024);
    $msg=Msg::new("\nSpace Requirements:\n$prod->{abbr} All Package Set - $ps MB");
    $msg->print;

    $otherreqs=$prod->other_requirements||'';
    unless ($otherreqs){
        $otherreqs = Msg::new("None")->{msg};
    }

    $msg=Msg::new("\nOther Requirements:\n$otherreqs");
    $msg->print;
    return '';
}

package Prod::SNAS60::AIX;
@Prod::SNAS60::AIX::ISA = qw(Prod::SNAS60::Common);

package Prod::SNAS60::HPUX;
@Prod::SNAS60::HPUX::ISA = qw(Prod::SNAS60::Common);

package Prod::SNAS60::Linux;
@Prod::SNAS60::Linux::ISA = qw(Prod::SNAS60::Common);

package Prod::SNAS60::RHEL5x8664;
@Prod::SNAS60::RHEL5x8664::ISA = qw(Prod::SNAS60::Linux);

package Prod::SNAS60::RHEL6x8664;
@Prod::SNAS60::RHEL6x8664::ISA = qw(Prod::SNAS60::Linux);

sub init_padv {
    my $prod=shift;
    my ($cpic,$edr,$padv);
    $prod->{name}=Msg::new("Symantec Storage: NAS")->{msg};
    $prod->{upgradevers}=[qw(6.0)];
    $prod->{prod}='SNAS';
    $prod->{abbr}='SNAS';
    $prod->{vers}='6.0.0.000';
    $prod->{proddir}='';
    $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
    $prod->{eula}='EULA_SNAS_Ux_6.0.pdf';
    $prod->{noeula} = 1;
    $prod->{allpkgs}=[ qw(VRTSglm61 VRTScavf61 VRTSgms61 VRTSdbms330 SYMCsnas60) ];
    $prod->{minpkgs}=[ qw(VRTSglm61 VRTScavf61 VRTSdbms330 SYMCsnas60) ];
    $prod->{recpkgs}=[ qw(VRTSglm61 VRTScavf61 VRTSgms61 VRTSdbms330 SYMCsnas60) ];
    $prod->{silent_upgrade} = [ qw(SYMCsnas SYMCsnascpi) ];
    $prod->{autostop} = 1;

    $prod->{lic_names}=['Storage Foundation for Cluster File System'];

    $prod->{installscript_prod}='SNAS60';
    $prod->{installscript_name}='SNAS';
    $prod->{mainpkg}='SYMCsnas60';
    $prod->{installallpkgs} = 1;

    $prod->{upgradevers}=[qw(6.0)];
    $prod->{zru_releases}=[qw(6.0)];

    $prod->{skip_pkgvers_postcheck} = 1;
    $prod->{skip_pkgverify_postcheck} = 1;

    $prod->{ru_response} = '/opt/SYMCsnas/log/ru_response';
    $prod->{upgrade_log} = '/opt/SYMCsnas/log/upgrade_output';
    $prod->{logdir}='/opt/SYMCsnas/log';
    $prod->{scriptslog}='CPI_script_executing.log';
    $prod->{scriptsdir}='/opt/SYMCsnas/scripts';
    $prod->{sysscriptsdir}='/opt/SYMCsnas/scripts/system';
    $prod->{storscriptsdir}='/opt/SYMCsnas/scripts/storage';
    $prod->{guiscriptsdir}='/opt/SYMCsnas/gui/scripts';
    $prod->{libscriptsdir}='/opt/SYMCsnas/scripts/lib';
    $prod->{installerdir}='/opt/SYMCsnas/install/image_install';
    $prod->{nicconf}->{filepath} = "/opt/SYMCsnas/conf";
    $prod->{nicconf}->{nodefilepath} = "/opt/SYMCsnas/nodeconf/";
    $prod->{nicconf}->{physicalipfile}="/opt/SYMCsnas/conf/net_pip_list.conf";
    $prod->{nicconf}->{publicdevicefile}="/opt/SYMCsnas/conf/net_pub_dev_list.conf";
    $prod->{nicconf}->{privatedevicefile}="/opt/SYMCsnas/conf/net_priv_dev.conf";
    $prod->{nicconf}->{privateipfile}="/opt/SYMCsnas/conf/net_priv_ip_list.conf";
    $prod->{nicconf}->{vipfile}="/opt/SYMCsnas/conf/net_vip_list.conf";
    $prod->{nicconf}->{vipdevicefile}="/opt/SYMCsnas/conf/net_vip_dev_list.conf";
    $prod->{nicconf}->{consoleipfile}="/opt/SYMCsnas/conf/net_console_ip.conf";
    $prod->{nicconf}->{consoledevfile}="/opt/SYMCsnas/conf/net_console_dev.conf";
    $prod->{nicconf}->{bonddevfile}="/opt/SYMCsnas/conf/net_bond_dev.conf";
    $prod->{nicconf}->{bonddevfile4shell}="/opt/SYMCsnas/conf/bonddevicefile";
    $prod->{nicconf}->{bonddevfile4shell_new}="/opt/SYMCsnas/conf/net_bond_dev_list.conf";
    $prod->{nicconf}->{exclusionfile}="/opt/SYMCsnas/conf/net_exclusion_dev.conf";
    $prod->{nicconf}->{nasinstallconf}="/opt/SYMCsnas/nodeconf/nasinstall.conf";
    $prod->{nicconf}->{udevconffile}="/etc/udev/rules.d/70-persistent-net.rules";
    $prod->{nicconf}->{globalroutes}="/opt/SYMCsnas/conf/net_globalroutes.conf";
    $prod->{nicconf}->{pciexclusionfile}="/opt/SYMCsnas/conf/net_pci_exclusion.conf";
    $prod->{nicconf}->{sysname}="/etc/VRTSvcs/conf/sysname";
    $prod->{nicconf}->{llthosts}="/etc/llthosts";
    $prod->{nicconf}->{llttab}="/etc/llttab";
    $prod->{nicconf}->{gabtab}="/etc/gabtab";
    $prod->{nicconf}->{vxfenmode}="/etc/vxfenmode";
    $prod->{nicconf}->{vxfendg}="/etc/vxfendg";
    $prod->{nicconf}->{vxfentab}="/etc/vxfentab";
    $prod->{nicconf}->{maincf}="/etc/VRTSvcs/conf/config/main.cf";
    $prod->{nicconf}->{smbglobalconf}="/opt/SYMCsnas/conf/smbglobal.conf";
    $prod->{nicconf}->{nlmmonitorname}="/opt/SYMCsnas/conf/nlm_monitor_name";
    $prod->{nicconf}->{cpuinfofile}="/opt/SYMCsnas/conf/cpuinfofile";
    $prod->{nicconf}->{optionfile}="/opt/SYMCsnas/conf/optionfile";
    $prod->{nicconf}->{guifile}="/opt/SYMCsnas/conf/GUI.conf";
 
    $prod->{nicconf}->{rcscriptpath}="/etc/rc.d/rc.local";
    $prod->{nicconf}->{rcscript}="/tmp/nicscript.sh";
    $prod->{clish}->{clishhomepath}="/home/clish";
    $prod->{clish}->{bashpath}="/bin/bash";
    $prod->{clish}->{clishpath}="/opt/SYMCsnas/clish/bin/clish";
    $prod->{clish}->{supporthomepath}="/home/support";
    $prod->{netproto}="ipv4";
    $prod->{netprotovip}="ipv4";
    $prod->{netprotoipv4}="ipv4";
    $prod->{netprotoipv6}="ipv6";
    $prod->{hostsfile}='/etc/hosts';
    $prod->{knownhosts}='/root/.ssh/known_hosts';
    $prod->{authkeys}='/root/.ssh/authorized_keys';
    $prod->{id_rsa_pub}='/root/.ssh/id_rsa.pub';
    $prod->{deleted_node_list}='/opt/SYMCsnas/conf/deleted_node_list';
    $prod->{fatal_error_key}="STOP";
    $prod->{ip_error_key}="IPERROR";
    $prod->{mode}->{master}="new";
    $prod->{mode}->{slave}="join";
    $prod->{vip_display_maximum}=4;
    $prod->{minimum_pub_nic_num}=1;
    $prod->{minimum_priv_nic_num}=1;
    $prod->{max_priv_nic_num}=2;
    $prod->{minimum_clus_name_length}=1;
    $prod->{maximum_clus_name_length}=15;
    $prod->{retry_times}=6;
    $prod->{priviparr}=['172.16.0.3',
                           '172.16.0.4',
                           '172.16.0.5',
                           '172.16.0.6',
                           '172.16.0.7',
                           '172.16.0.8',
                           '172.16.0.9',
                           '172.16.0.10',
                           '172.16.0.11',
                           '172.16.0.12',
                           '172.16.0.13',
                           '172.16.0.14',
                           '172.16.0.15',
                           '172.16.0.16',
                           '172.16.0.17',
                           '172.16.0.18',
                           '172.16.0.19'];

    $prod->{privateipnetmask}="255.255.255.0";
    $prod->{store_release_imgs}{config_file} = "/opt/VRTS/.install_pref";
    $prod->{privnic_prefix} = "priveth";
    $prod->{pubnic_prefix} = "pubeth";
    $prod->{gui_lib_dir} = '/opt/SYMCsnas/gui/third_party_libs';
    $prod->{gui_install_dir} = '/opt/SYMCsnas/gui/install';
    $prod->{dedup_snapshot_prefix} = "~dedup_ckpt_";

    $padv = $prod->padv();
    $padv->{cmd}{fsdedupadm} = '/opt/VRTSfsadv/bin/fsdedupadm';
    $prod->{version_conf} = '/opt/SYMCsnas/conf/version.conf';
    $prod->{nas_env} = '/opt/SYMCsnas/scripts/lib/base_env.sh';
    $prod->{third_party_rpm_dir} = 'third_party_rpms';
    $prod->{nwconfdir} = '/etc/sysconfig/network-scripts';
    $prod->{nwconfbkupdir} = '/etc/sysconfig/network-scripts/ifconfig_bak';
    $prod->{kernel_dump_dir} = '/opt/SYMCsnas/core/kernel';
    $prod->{grub_conf} = '/boot/grub/grub.conf';
    $prod->{kdump_conf} = '/etc/kdump.conf';
    $padv->{cmd}{llt}='/etc/init.d/llt';
    $padv->{cmd}{gab}='/etc/init.d/gab';
    $padv->{cmd}{gabconfig}='/sbin/gabconfig';
    $padv->{cmd}{sfcache}='/usr/sbin/sfcache';
    $padv->{cmd}{vxfen}='/etc/init.d/vxfen';
    $padv->{cmd}{hastart}='/opt/VRTSvcs/bin/hastart';

    $edr = Obj::edr();
    $edr->{no_hostname_check} = 1;
    $cpic = Obj::cpic();
    $cpic->{auto_native_install} = 1;
    $cpic->{donotdisplaypkgs} = 1;
    EDR::set_value('not_display_summary_file', 1);
    return ;
}

sub set_pkgs {
    my $prod = shift;
    my($category,@categories);

    $prod->SUPER::set_pkgs();
    @categories=qw(minpkgs recpkgs allpkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arrdel($prod->{$category},'VRTSodm61', 'VRTSob34', 'VRTSdbed61','VRTSgms61');
    }
    return $prod->{allpkgs};
}

sub preinstall_sys {
    my ($prod, $sys) = @_;

    $prod->SUPER::preinstall_sys($sys);
    $prod->get_imgs_stored_location_sys($sys);
    $prod->check_img_space_sys($sys);
    return;
}

sub upgrade_preinstall_sys {
    my ($prod, $sys) = @_;

    $prod->SUPER::upgrade_preinstall_sys($sys);
    $prod->get_imgs_stored_location_sys($sys);
    $prod->check_img_space_sys($sys);
    return;
}

#1. read config file and init $sys->{store_release_imgs}
#2. check if imgs already stored on system. if not stored, prepare to store them after installation.
sub get_imgs_stored_location_sys {
    my ($prod, $sys) = @_;
    my ($cpic, $rel, $repository_path);
    my ($base_path, $base_version, $mr_path, $mr_version, $hf_path, $hf_version, $dest_path);
    $cpic = Obj::cpic();

    $prod->init_preference_sys($sys);
    $repository_path = $prod->get_repository_on_sys($sys);
    $rel = $cpic->rel();
    #get base release image
    if ($rel->{type} =~ /B/) {
        $base_path = Cfg::opt('base_path') || $cpic->{mediapath};
        $base_version = $prod->rep_vers($rel->{vers},2);
        $dest_path = "ga/images/SSNAS/$base_version";
        if (!$prod->img_stored_on_sys($sys, "$repository_path/$dest_path") || Cfg::opt('install')) {
            $sys->{store_release_imgs}{base_img}{from} = $base_path;
            $sys->{store_release_imgs}{base_img}{to} = $dest_path;
        }
        $sys->{store_release_imgs}{"InstalledBase"} = $base_version;
        $sys->{store_release_imgs}{"InstalledMR"} = "";
        $sys->{store_release_imgs}{"InstalledHF"} = "";
    }
    #get mr release image
    if ($rel->{type} =~ /M/) {
        $mr_path = $cpic->{mediapath};
        $mr_version = $prod->rep_vers($rel->{vers}, 3);
        $dest_path = "patch/images/SSNAS/$mr_version";
        if (!$prod->img_stored_on_sys($sys, "$repository_path/$dest_path") || Cfg::opt('install')) {
            $sys->{store_release_imgs}{mr_img}{from} = $mr_path;
            $sys->{store_release_imgs}{mr_img}{to} = $dest_path;
        }
        $sys->{store_release_imgs}{"InstalledMR"} = $mr_version;
        $sys->{store_release_imgs}{"InstalledHF"} = "";
    }
    #get hotfix release images
    if ($rel->{type} =~ /H/) {
        $hf_path = Cfg::opt("hotfix_path") || $cpic->{mediapath};
        $hf_version = $prod->rep_vers($rel->{vers}, 4);
        $dest_path =  "hf/images/SSNAS/$hf_version";
        if (!$prod->img_stored_on_sys($sys, "$repository_path/$dest_path" || Cfg::opt('install'))) {
            $sys->{store_release_imgs}{hf_img}{from} = $hf_path;
            $sys->{store_release_imgs}{hf_img}{to} = $dest_path;
        }
        $sys->{store_release_imgs}{"InstalledHF"} = $hf_version;
    }
    return 1;
}

sub init_preference_sys {
    my ($prod, $sys) = @_;
    my ($content, $file, %preference_hash);
    unless($sys->exists($prod->{store_release_imgs}{config_file})) {
        $file = $prod->{store_release_imgs}{config_file};
        $preference_hash{"Repository"} = "/opt/VRTS/repository";
        $preference_hash{"StoreReleaseImages"} = "Y";
        $preference_hash{"InstalledBase"} = "";
        $preference_hash{"InstalledMR"} = "";
        $preference_hash{"InstalledHF"} = "";

        $content=JSON::to_json(\%preference_hash,{pretty=>1});
        unless($sys->exists("/opt/VRTS")) {
            $sys->cmd("_cmd_mkdir -p /opt/VRTS");
        }
        $sys->writefile($content, $file);
    }
    $prod->read_preference_file_sys($sys);
    return 1;
}

sub read_preference_file_sys {
    my ($prod, $sys) = @_;
    my ($content, $preference_hash);
    my $file = $prod->{store_release_imgs}{config_file};

    if ($sys->exists($file)) {
        $content = $sys->catfile($file);
    } else {
        Msg::die("Reference file $file is not existed on $sys->{sys}")
    }

    $preference_hash = EDRu::eval_json($content);
    for my $key (keys %{$preference_hash}) {
        $sys->{store_release_imgs}{$key} = $preference_hash->{$key};
    }
    return 1;
}

sub update_preference_file_sys {
    my ($prod, $sys) = @_;
    my $preference_file = $prod->{store_release_imgs}{config_file};
    my $content;

    $content = JSON::to_json($sys->{store_release_imgs}, {pretty=>1});
    $sys->writefile($content, $preference_file);
    return 1;
}
#Update the version.conf file on system.
sub update_version_conf_sys{
    my ($prod, $sys) = @_;
    my $conf_file= $prod->{version_conf};
    my ($content,$release_version,$build_date,$install_date,$release_version_word);
    my ($cpic,$rel,$snaspkg,$queryformat,$rpminfo);

    $snaspkg = $prod->pkg('SYMCsnas60');

    $queryformat = '--queryformat \'%{VERSION}__\' ';
    $queryformat .= '--queryformat \'%{BUILDTIME:date}__\' ';
    $queryformat .= '--queryformat \'%{INSTALLTIME:date}__\' ';
    $rpminfo = $sys->cmd("_cmd_rpm -q $queryformat $snaspkg->{pkg} 2> /dev/null");
    return 0 if(!$rpminfo);
    ($release_version,$build_date,$install_date) = split(/__/,$rpminfo);
    $release_version_word = $release_version;

    $content = "$release_version\|$build_date\|$install_date\|$release_version";
    $content .="\n";
    $sys->appendfile($content, $conf_file);
    #Remove extra newline appended
    $sys->cmd("_cmd_sed -i '/^\s*\$/d' $conf_file");
    return 1;
}

sub update_nbu_latest_dir_sys {
    my ($prod, $sys) = @_;
    my $env_file = $prod->{nas_env};
    my $keyword = "NAS_INSTALL_NBU_LATEST_BINARY_DIR=";

    if ($sys->{nbu_latest_dir} && $sys->exists($env_file)) {
	my $prev_line = $sys->cmd("_cmd_grep $keyword $env_file");
	if ($prev_line) {
	    my $new_line = $keyword . "\"$sys->{nbu_latest_dir}\"";
	    $sys->cmd("_cmd_sed -i 's|$prev_line|$new_line|g' $env_file");
	}
    }

    return 1;
}

#get the repository path forsys 
sub get_repository_on_sys {
    my ($prod, $sys) = @_;
    my $msg;
    if ($sys->{store_release_imgs}{"Repository"}) {
        return $sys->{store_release_imgs}{"Repository"};
    } else {
        $msg=Msg::new("Cannot find the repository directory on $sys->{sys}");
        $msg->die();
    }
    return 1;
}

#this sub should return the version string with 4 fileds just like version string in repository
#fields should be 2, 3, 4 corresponding with base, mr, hotfix.
#only intercept $fields heading fieds in $vers, other fileds would fill with 0
#for example
#rep_vers(6.0.1.1, 3)=>6.0.1.0
#rep_vers(6.0.1.1, 4)=>6.0.1.1                 
#rep_vers(6.0, 4)=>6.0.0.0                 
sub rep_vers {
    my ($prod, $vers, $fields) = @_; 
    my @vfields = split(/\./m, $vers);
    my $fullvers;
    for my $i (0..3) {
        if ($vfields[$i] && $fields > $i) {
            $fullvers .= "$vfields[$i]";
        } else {
            $fullvers .= "0";
        }   
        $fullvers .= ".";
    }   
    $fullvers =~ s/\.$//;
    return $fullvers;
}

#check if image is stored on sys:
#1. img_dir existed
#2. ssn_img.tar is not eixsted under %img_dir
sub img_stored_on_sys {
    my ($prod, $sys, $img_dir) = @_;
    my $tmp_tar = "ssn_img.tar";
    my $msg;
    if ($sys->exists($img_dir)) {
        if ($sys->exists("$img_dir/$tmp_tar")) {
            Msg::log("$img_dir/$tmp_tar is not removed after last installation. Assume img not existed on $sys->{sys}");
            return 0;
        }
        Msg::log("Img $img_dir existed on $sys->{sys}");
        return 1;
    }
    return 0;
}

sub del_obsoloted_img_sys {
    my ($prod, $sys) = @_;
    my ($installed_base, $installed_mr, $installed_hf, $repository_path);

    $installed_base = $sys->{store_release_imgs}{"InstalledBase"};
    $installed_mr = $sys->{store_release_imgs}{"InstalledMR"};
    $installed_hf = $sys->{store_release_imgs}{"InstalledHF"};
    $repository_path = $prod->get_repository_path($sys);

    #delete base imgs
    my $base_directory = "$repository_path/ga/images/SSNAS/";
    if ($sys->exists($base_directory)) {
        if ($installed_base) {
            $sys->cmd("cd $base_directory; _cmd_ls | _cmd_grep -v $installed_base | xargs _cmd_rmr ")
        } else {
            $sys->cmd("_cmd_rmr $base_directory/*")
        }
    }

    #delete mr imgs
    my $mr_directory = "$repository_path/patch/images/SSNAS/";
    if ($sys->exists($mr_directory)) {
        if ($installed_mr) {
            $sys->cmd("cd $mr_directory; _cmd_ls | _cmd_grep -v $installed_mr | xargs _cmd_rmr ")
        } else {
            $sys->cmd("_cmd_rmr $mr_directory/*")
        }
    }

    #delete hotfix images
    my $hotfix_directory = "$repository_path/hotfix/images/SSNAS/";
    if ($sys->exists($hotfix_directory)) {
        if ($installed_hf) {
            $sys->cmd("cd $hotfix_directory; _cmd_ls | _cmd_grep -v $installed_hf | xargs _cmd_rmr ")
        } else {
            $sys->cmd("_cmd_rmr $hotfix_directory/*")
        }
    }
    return 1;
}

sub get_repository_path {
    my ($prod, $sys) = @_;
    my $msg;
    if ($sys->{store_release_imgs}{"Repository"}) {
        return $sys->{store_release_imgs}{"Repository"};
    } else {
        $msg=Msg::new("Cannot find the Repository directory on $sys->{sys}");
        $msg->die();
    }
    return 1;
}

#copy img from localsys to other node
sub copy_img_to_sys {
    my ($prod, $sys, $level) = @_;
    my ($localtmptarfile, $tmptarfile, $repdir, $syslist, $sysobj, $img_exist, $srcpath, $despath, $nbupath);
    my $localsys = Obj::edr()->{localsys};
    my $repository_path;
    my $tmp_tar = "ssn_img.tar";
    my $tmpdir = EDR::get('tmpdir');

    if ($level eq 'base') {
        $srcpath = $sys->{store_release_imgs}{base_img}{from};
        $despath = $sys->{store_release_imgs}{base_img}{to};
    } elsif ($level eq 'mr') {
        $srcpath = $sys->{store_release_imgs}{mr_img}{from};
        $despath = $sys->{store_release_imgs}{mr_img}{to};
    } elsif ($level eq 'hf') {
        $srcpath = $sys->{store_release_imgs}{hf_img}{from};
        $despath = $sys->{store_release_imgs}{hf_img}{to};
    } else {
        Msg::log("level $level is not defined on $sys->{sys}");
        return;
    }

    $repository_path = $prod->get_repository_path($sys);
    $tmptarfile = "$repository_path/$despath/$tmp_tar";
    #make tar file on localsys
    $localtmptarfile = "$tmpdir/$level/$tmp_tar";

    if (EDRu::check_flag("making_tmp_tar_$level")) {
	    EDRu::wait_for_flag("make_tmp_tar_$level\_done");
    } else {
	    EDRu::create_flag("making_tmp_tar_$level");
	    EDRu::mkdir_local_nosys("$tmpdir/$level");
	    $localsys->cmd("cd $srcpath; _cmd_tar -cvf $localtmptarfile *");
	    EDRu::create_flag("make_tmp_tar_$level\_done");
    }    

    $sys->cmd("_cmd_rmr $repository_path/$despath 2>/dev/null");
    $sys->cmd("_cmd_mkdir -p $repository_path/$despath 2>/dev/null");

    #copy tar file to sys
    $localsys->copy_to_sys($sys,$localtmptarfile,$tmptarfile);

    #untar file on sys
    $sys->cmd("cd $repository_path/$despath; _cmd_tar -xvf $tmptarfile && _cmd_rmr $tmptarfile 2>/dev/null");

    #get nbu latest dir on sys
    $nbupath = "$repository_path/$despath/netbackup";
    if ($sys->exists($nbupath)) {
       $sys->set_value('nbu_latest_dir', "$repository_path/$despath/netbackup");
    }

    return 1;
}


sub check_img_space_sys {
    my ($prod, $sys) = @_;
    my ($cpic, $free, $img_size, $img_path, $msg, $require_space);
    $cpic = Obj::cpic();
    $free = $cpic->volumespace_sys($sys, '/opt') || $cpic->volumespace_sys($sys, '/');

    if ($sys->{store_release_imgs}{base_img}) {
        $img_path = $sys->{store_reelase_img}{base_img}{from};
        $img_size += $sys->cmd("_cmd_du -sk $img_path");
    }
    if ($sys->{store_release_imgs}{mr_img}) {
        $img_path = $sys->{store_reelase_img}{mr_img}{from};
        $img_size += $sys->cmd("_cmd_du -sk $img_path");
    }
    if ($sys->{store_release_imgs}{hf_img}) {
        $img_path = $sys->{store_reelase_img}{hf_img}{from};
        $img_size += $sys->cmd("_cmd_du -sk $img_path");
    }

    $require_space = $img_size * 3;
    if ($free < $require_space) {
        $msg = Msg::new("Not enough space in /opt on system $sys->{sys}.");
        Msg::log("On $sys->{sys} only $free KB for /opt, requirement is $require_space KB");
        $sys->push_error($msg);
    }
    return 1;
}


sub cli_prestart_config_questions {
    my ($prod) = @_;
    my ($mode,$ret,$vcs,$msg,$cpic);
    $cpic=Obj::cpic();
    $vcs = $prod->prod('VCS61');

    $ret = $prod->op_nic_hostname();
    if ($ret == 0 || $ret == 2) {
        $msg = Msg::new("NIC detecting error, double check the environment.");
        $msg->error();
        $cpic->edr_completion();  
        return; 
	}
    $ret = $prod->init_cfg_val();

    return 1 unless($vcs->prestart_config_common_questions);

    $prod->config_cluster();
    return;
}

# configure cluster id and heartbeat links
sub config_cluster {
    my $prod = shift;
    my ($cfg,$clus_id,$msg,$rhbn,$vcs_prod,$cpic);
    $cpic = Obj::cpic();
    $cfg = Obj::cfg();
    $vcs_prod = $prod->prod('VCS61');
    $cfg->{vcs_allowcomms} = 1;
    $cfg->{snas_clustername} ||= 'snascluster';
    $cfg->{vcs_clustername} = $cfg->{snas_clustername};

    $rhbn = $prod->set_priv_link();
    unless ($rhbn) {
        $msg = Msg::new("Private link detecting error");
        $msg->error();
        $cpic->edr_completion();  
    }
    $cfg->{vcs_clusterid} = int(rand(65535)) if (!defined($cfg->{vcs_clusterid}));
    $clus_id = $cfg->{vcs_clusterid};
    if ($vcs_prod->check_clusterid($clus_id,$rhbn)) {
        $clus_id = $vcs_prod->config_clusterid($clus_id,$rhbn);
    }

    unless (Cfg::opt('responsefile')) {
        $cfg->{vcs_clusterid}=$clus_id;
        $vcs_prod->set_hb_nics($rhbn, CPIC::get('systems'));
        $cfg->{vcs_clustername} = $cfg->{snas_clustername};
    }
    $prod->ssh_com_setup(CPIC::get('systems'));

    return;
}

sub set_priv_link {
    my $prod = shift;
    my ($rhbn,$n,$sys0);
    my $cpic = Obj::cpic();
    $sys0=${$cpic->{systems}}[0];
    return 0 unless ($sys0->{privenics_new});
    $n = 1;
    for my $nic (@{$sys0->{privenics_new}}) {
        for my $sys (@{CPIC::get('systems')}) {
            $rhbn->{"lltlink$n"}{$sys->{sys}} = $nic;
        }
        last if (++$n > 2);
    }
    # In case only 1 private NIC found, add 1 public NIC as low priority llt link
    if ($n == 2) {
        for my $sys (@{CPIC::get('systems')}) {
            $rhbn->{lltlinklowpri1}{$sys->{sys}} = @{$sys0->{publicnics_new}}[0];
        }
    }
    return $rhbn;
}

##########################update parameter###############################
sub opt_update_parameter {
    my $prod = shift;
    my $cpic = Obj::cpic();
    $cpic->run_subs(qw(systems));
    $prod->update_parameter();
    $cpic->edr_completion();
    return;
}

sub update_parameter {
    my ($prod) = shift;
    my ($output,$cpic,$msg);
    $cpic = Obj::cpic();

    $output = $prod->precheck_update_parameter();
    $output = $prod->phase_get_nic_for_update_parameter();
    if (!$output) {
        $msg = Msg::new("NIC checking failed");
        $msg->error();
        $cpic->edr_completion();
        return 0;
    }

    do {
        $output = $prod->cli_ask_update_parameter();
        return 0 if($output == 2);
        $prod->init_internal_val();
        $prod->phase_detect_ip_update_parameter();
        $prod->buildup_update_parameter();
        $output = $prod->display_update_parameter();
    } while (!$output);

    $output = $prod->phase_config_update_parameter();
    if (!$output) {
        $msg = Msg::new("VCS configuration failed");
        $msg->error();
        $cpic->edr_completion();
        return 0;
    }

    $output = $prod->handler_restart_network_update_parameter();


    for my $sys (@{$cpic->{systems}}) {
        $output = $prod->write_config_files_update_parameter_sys($sys);
        $output = $prod->write_nasinstallconf_update_parameter_sys($sys);
    }
    
    $output = $prod->phase_config_vcs_update_parameter();
    return 1;
}

sub precheck_update_parameter {
    my ($prod) = @_;
    my ($output);
    for my $sys(@{CPIC::get('systems')}) {
#TBD
    }
}

sub phase_get_nic_for_update_parameter {
    my $prod = shift;
    my ($cfg,$edr,$mode,$phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);

    $cfg = Obj::cfg();
    $edr=Obj::edr();

    $phase_name="Detecting PCI Devices, Network Devices";
    $phase_desc=Msg::new("Detecting network devices");
    $edr->{$prod->{fatal_error_key}} = 0;

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->set_fatal_error_key($prod->{fatal_error_key});
    $phase->initialize_tasks();


    $id=100;
    $task_name="product_checking_nics";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Detecting network devices"),
            'description_sys' => Msg::new("Detecting network devices on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_check_nics_for_update_parameter_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $phase->execute_tasks();

    Cfg::unset_opt('serial') if ($mode eq '');

    return $prod->phase_get_nic_for_update_parameter_post();

}

sub handler_check_nics_for_update_parameter_sys {
    my ($prod ,$sys) = @_;
    my ($cfg, $padv,$edr, $ethall,$output);
    my @publicnics = ();
    my @privatenics = ();
    my @bondnics = ();
    my @exclusionnics = ();
    $cfg = Obj::cfg();
    $padv=$sys->padv;

    $ethall=$padv->get_all_nic_sys($sys);

    for my $eth (@{$ethall}) {
        $output = $padv->is_slave_of_bonded_nic_sys($sys,$eth);
        next if($output);
        if ($eth =~ /^pubeth\d+$/m) {
            push(@publicnics, $eth);
        } elsif ($eth =~ /^priveth\d+$/m) {
            push(@privatenics, $eth);
        } elsif ($eth =~ /^bond\d+$/m) {
            push (@bondnics, $eth);
        } else {
            push (@exclusionnics, $eth);
        }
    }

    @publicnics = sort (@publicnics);
    @privatenics = sort (@privatenics);
    @bondnics = sort (@bondnics);
    @exclusionnics = sort (@exclusionnics);

    $sys->set_value('publicnic_change_ip','push',@publicnics);
    $sys->set_value('publicnic_bond_nic','push',@bondnics);
    $sys->set_value('publicnic_exclusion','push',@exclusionnics);
    return 1;
}


sub phase_get_nic_for_update_parameter_post {
    my ($prod) = @_;
    my ($cpic,$publicnic_str_tmp,$bondnic_tmp); 
    $cpic = Obj::cpic();
    my $system = @{$cpic->{systems}}[0];

    my @publicnic = @{$system->{publicnic_change_ip}};
    my @bondnic = @{$system->{publicnic_bond_nic}};

    my $publicnic_str = join(' ',@publicnic);
    my $bondnic_str = join(' ',@bondnic);
    for my $sys (@{$cpic->{systems}}) {
       $publicnic_str_tmp = join(' ',@{$sys->{publicnic_change_ip}});
       $bondnic_tmp = join(' ',@{$sys->{publicnic_bond_nic}});
       return 0 if(($publicnic_str ne $publicnic_str_tmp) || ($bondnic_str ne $bondnic_tmp));
    }

    return 1;
}

sub phase_detect_ip_update_parameter {
    my $prod = shift;
    my ($cfg,$edr,$mode,$phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);

    $cfg = Obj::cfg();
    $edr=Obj::edr();

    $phase_name="Detecting Available IPs";
    $phase_desc=Msg::new("Detecting available IPs");
    $edr->{$prod->{ip_error_key}} = 0;

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->set_fatal_error_key($prod->{fatal_error_key});
    $phase->initialize_tasks();

    $id=100;
    $task_name="product_detecting_ips";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Detecting available IPs"),
            'description_sys' => Msg::new("Detecting available IPs"),
            'if_per_system' => 0,
            'handler' => \&handler_check_ip_update_parameter,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $phase->execute_tasks();


    return $prod->phase_check_ip_post();


}

sub handler_check_ip_update_parameter {
    my ($prod) = @_;
    my ($cfg, $edr, $output);
    my $cfg = Obj::cfg();
    my $edr = Obj::edr();

    if ($prod->{netproto} eq $prod->{netprotoipv4}) {
        $output = $prod->precheck_ip_range($cfg->{snas_pipstart},$cfg->{snas_vipstart},$cfg->{snas_pnmaskstart},$cfg->{snas_vnmaskstart});   
    } else {
        $output = $prod->precheck_ip_range($cfg->{snas_pipstart},$cfg->{snas_vipstart},$cfg->{snas_pipprefix},$cfg->{snas_vipprefix});   
    }
    if ($output == 2) {
        Msg::log("public ip is out of range, install failed!");
        $edr->{$prod->{ip_error_key}} = 2;
        return 0;
    }
    if ($output == 3) {
        Msg::log("virtual ip is out of range, install failed!");
        $edr->{$prod->{ip_error_key}} = 3;
        return 0;
    }

    return 1;

}


sub buildup_update_parameter {
    my ($prod) = @_;
    my ($hostnameid,$cpic,$oldhostname,$cfg,$pubprefix,$privprefix,@conneths,$nconneths,@disconneths,$nconneths_new,$ndisconneths_new,$nconneths,$ndisconneths,$pubid,$privid,$pip,$pmask,$vip,$vmask,$i,$vcs,$sys0);
    my (@conneths_all_new,@conneths_all_old,@bond,$lengh);

    $cfg= Obj::cfg();
    $cpic = Obj::cpic();
    $hostnameid = 1;

    @{$cfg->{publiciparr}} = @{$prod->{snas_ip_pool}->{public}};
    @{$cfg->{virtualiparr}} = @{$prod->{snas_ip_pool}->{private}};
    @{$cfg->{publicnetmaskarr}} =  @{$prod->{snas_nmask_pool}->{public}};
    @{$cfg->{virtualnetmaskarr}} = @{$prod->{snas_nmask_pool}->{private}};

    $vcs = $prod->prod('VCS61');
    $sys0=${$cpic->{systems}}[0];
    my $old_cluster_name = $sys0->cmd("$vcs->{bindir}/haclus -list 2>/dev/null");
    $prod->set_value('old_cluster_name',$old_cluster_name);

    for my $sys (@{$cpic->{systems}}) {
        my $oldhostname = $sys->cmd("_cmd_hostname 2>/dev/null");
        $sys->set_value('oldhostname',$oldhostname);
        if ($hostnameid < 10) {
            $sys->{newhostname} = $cfg->{snas_clustername}."_0".$hostnameid;
        } else {
            $sys->{newhostname} = $cfg->{snas_clustername}."_".$hostnameid;
        }
        $hostnameid++;
    }

    for my $sys (@{$cpic->{systems}}) {
        my @conneths_new = ();
        my @conneths_old = ();
        my @bond_nic_new = ();

        @conneths_new = @{$sys->{publicnic_change_ip}};
        @conneths_old = @{$sys->{publicnic_change_ip}};
        @bond = @{$sys->{publicnic_bond_nic}};

        $sys->set_value('publicnics_new','push', @conneths_new);
        $sys->set_value('publicnics_old','push', @conneths_old);
        $sys->set_value('bond_nic_new','push', @bond);
    }

    for my $sys (@{$cpic->{systems}}) {
        my @pubip_arr=();
        my @pubnmask_arr=();
        my @privip_arr=();
        my @privnmask_arr=();

        for my $eth (@{$sys->{publicnics_new}}) {
            $pip = $prod->get_ip_from_ppool();
            $pmask = $prod->get_nmask_from_ppool();
            push (@pubip_arr,$pip);
            push (@pubnmask_arr,$pmask);

            for ($i = 0 ; $i < $cfg->{snas_nvip}; $i++) {
                $vip = $prod->get_ip_from_vpool();
                $vmask = $prod->get_nmask_from_vpool();
                push (@privip_arr,$vip);
                push (@privnmask_arr,$vmask);
            }
        }


        for my $eth (@{$sys->{bond_nic_new}}) {
            $pip = $prod->get_ip_from_ppool();
            $pmask = $prod->get_nmask_from_ppool();
            push (@pubip_arr,$pip);
            push (@pubnmask_arr,$pmask);

            for ($i = 0 ; $i < $cfg->{snas_nvip}; $i++) {
                $vip = $prod->get_ip_from_vpool();
                $vmask = $prod->get_nmask_from_vpool();
                push (@privip_arr,$vip);
                push (@privnmask_arr,$vmask);
            }
        }

        $sys->set_value('publicip','push', @pubip_arr);
        $sys->set_value('publicnetmask','push', @pubnmask_arr);
        $sys->set_value('privateip','push', @privip_arr);
        $sys->set_value('privatenetmask','push', @privnmask_arr);
    }

    return 1;

}

sub cli_ask_update_parameter {
    my $prod = shift;
    my ($ayn,$padv,$cfg,$done,$msg,$msg_str,$help,$backopt,$netm,$mcnic_ref,$prefix,$vcs,$vip,$snas,$pipstart,$pnmaskstart,$vipstart,$vnmaskstart,$clustername,$def_gateway,$dnsip,$dnsdomainname,$pciexclusionid,$consoleip,$output,$hintpnmask,$hintvnmask,$rpn,$defnic,$nicl,$output,$nvips,$sepconsoleport,$pipprefix,$ntpserver);
    $cfg = Obj::cfg();
    $backopt = '';

    my $cpic = Obj::cpic();
    my $sys = @{$cpic->{systems}}[0];
    $padv=$sys->padv;
    $rpn = $padv->publicnics_sys($sys);
    if ($#$rpn<0) {
        $msg = Msg::new("No active NIC devices have been discovered on $sys->{sys}");
        $msg->warning();
    } else {
        $nicl = join(' ',@$rpn);
    }
    $defnic = $$rpn[0];


    Msg::title();
    $msg = Msg::new("The following data is required to configure the Storage NAS cluster:\n");
    $msg->bold;
    $msg = Msg::new("\tThe Storage NAS cluster name");
    $msg->printn;
    $msg = Msg::new("\tAn initial public IP address");
    $msg->printn;
    $msg = Msg::new("\tAn initial virtual IP address");
    $msg->printn;
    $msg = Msg::new("\tNetmask of public IPs and virtual IPs");
    $msg->printn;
    $msg = Msg::new("\tDefault gateway IP address");
    $msg->printn;
    $msg = Msg::new("\tDNS server IP address and domain name");
    $msg->printn;
    $msg = Msg::new("\tConsole virtual IP address");
    $msg->printn;
    $msg = Msg::new("System IP addresses will be defined sequentially starting with the initial address. System hostnames will be renamed as clustername_01, clustername_02, etc.");
    $msg->printn;

    do {
        $clustername = $prod->ask_clustername();
        $clustername = EDRu::despace($clustername);
        next if (EDR::getmsgkey($clustername,'back'));


        $pipstart = $prod->ask_pip_sys($sys);
        $pipstart = EDRu::despace($pipstart);
        next if (EDR::getmsgkey($pipstart,'back'));

        if (EDRu::ip_is_ipv6($pipstart)) {
            $prod->{netproto} = $prod->{netprotoipv6};
        } else {
            $prod->{netproto} = $prod->{netprotoipv4};
        }

        if ($prod->{netproto} eq $prod->{netprotoipv4}) {
            $hintpnmask = $sys->defaultnetmask($pipstart,$defnic);
            $pnmaskstart = $prod->ask_pnmask_sys($sys,$hintpnmask);
            $pnmaskstart = EDRu::despace($pnmaskstart);
            next if (EDR::getmsgkey($pnmaskstart,'back'));
        } else {
            $hintpnmask = $sys->defaultnetmask($pipstart,$defnic);
            $pipprefix = $prod->ask_pipprefix($hintpnmask);
            $pipprefix = EDRu::despace($pipprefix);
            next if (EDR::getmsgkey($pnmaskstart,'back'));
        }

        $vipstart = $prod->ask_vip_sys($sys);
        $vipstart = EDRu::despace($vipstart);
        next if (EDR::getmsgkey($vipstart,'back'));

        $nvips = $prod->ask_nvip(1);
        $nvips = EDRu::despace($nvips);
        next if (EDR::getmsgkey($nvips,'back'));

        $def_gateway = $prod->ask_default_gateway_sys($sys);
        $def_gateway = EDRu::despace($def_gateway);
        next if (EDR::getmsgkey($def_gateway,'back'));

        $dnsip = $prod->ask_dnsip_sys($sys);
        $dnsip = EDRu::despace($dnsip);
        next if (EDR::getmsgkey($dnsip,'back'));

        $dnsdomainname = $prod->ask_dnsdomainname_sys($sys);
        $dnsdomainname = EDRu::despace($dnsdomainname);
        next if (EDR::getmsgkey($dnsdomainname,'back'));

        $consoleip = $prod->ask_consoleip_sys($sys);
        $consoleip = EDRu::despace($consoleip);
        next if (EDR::getmsgkey($consoleip,'back'));

        $sepconsoleport = $prod->ask_sep_console_port();
        $sepconsoleport = EDRu::despace($sepconsoleport);
        next if (EDR::getmsgkey($sepconsoleport,'back'));

        $ntpserver = $prod->ask_ntpserver();
        $ntpserver = EDRu::despace($ntpserver);
        next if (EDR::getmsgkey($ntpserver,'back'));

        Msg::n();
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny;
        $done = 1 if ($ayn eq 'Y');
    } while (!$done);

    $cfg->{snas_pipstart} = $pipstart;
    $cfg->{snas_pnmaskstart} = $pnmaskstart;
    $cfg->{snas_clustername} = $clustername;
    $cfg->{snas_vipstart} = $vipstart;
    $cfg->{snas_vnmaskstart} = $pnmaskstart;
    $cfg->{snas_defgateway} = $def_gateway;
    $cfg->{snas_dnsip} = $dnsip;
    $cfg->{snas_dnsdomainname} = $dnsdomainname;
    $cfg->{snas_consoleip} = $consoleip;
    $cfg->{snas_pciexclusionid} = $pciexclusionid;
    $cfg->{snas_nvip} = $nvips;
    $cfg->{snas_pipprefix} = $pipprefix;
    $cfg->{snas_sepconsoleport} = $sepconsoleport;
    $cfg->{snas_vipprefix} = $pipprefix;
    $cfg->{snas_ntpserver} = $ntpserver;


    my $system = @{$cpic->{systems}}[0];
    my $pubnicsnum = scalar(@{$system->{publicnic_change_ip}}) + scalar(@{$system->{publicnic_bond_nic}});
    $pubnicsnum-- if ($cfg->{snas_sepconsoleport});

    if($pubnicsnum < $prod->{minimum_pub_nic_num}) {
        $msg = Msg::new("The public NIC number does not meet the minimum requirement: $prod->{minimum_pub_nic_num}");
        $msg->printn;
        Msg::prtc();
        return 2;
    }

    return 1;

}


sub display_update_parameter {
    my ($prod) = @_;
    my (@titles,$cfg,$cpic,@pip,@vip,@nmask,@vnmask,@pubeths_new,@pubeths_old,@priveths,$pubprefix,$index,$msg,$oldhostname,$newhostname,$hostnameid,$id,$nicid,$ayn,$done,$privprefix,$i,$pid,$vid);
    my ($nicname,$nicname_new,$flag,$flag_bond,$content);

    $cfg = Obj::cfg();
    $cpic = Obj::cpic();

    $hostnameid = 1;
    $flag = 0;
    $flag_bond = 0;
    $pubprefix = "pubeth";
    $privprefix = "priveth";
    $content = '';

    my @p1_arr = ();
    my @p2_arr = ();
    my @p3_arr = ();
    my @p4_arr = ();
    my @pubeths=();

    my @element_p1 = ("System","Hostname","New Hostname");
    my @element_p2 = ("System","Gateway IP","DNS IP","Domain name");
    my @element_p3 = ("System","NIC name","Physical IP");
    my @element_p4 = ("Virtual IP");

    for my $sys (@{$cpic->{systems}}) {

        @pip = @{$sys->{publicip}};
        @vip = @{$sys->{privateip}};
        @nmask = @{$sys->{publicnetmask}};
        @vnmask = @{$sys->{privatenetmask}};
        $nicid =0;
        $index=0;

        my %hash_p1=();
        my %hash_p2=();

        if ($hostnameid < 10) {
            $newhostname = $cfg->{snas_clustername}."_0".$hostnameid;
        } else {
            $newhostname = $cfg->{snas_clustername}."_".$hostnameid;
        }
        $hostnameid++;

        $hash_p1{"System"}= $sys->{sys};
        $hash_p1{"Hostname"}=$sys->{oldhostname};
        $hash_p1{"New Hostname"}=$newhostname;

        push(@p1_arr,\%hash_p1);

        $hash_p2{"System"}=$sys->{sys};
        $hash_p2{"Gateway IP"}=$cfg->{snas_defgateway};
        $hash_p2{"DNS IP"}=$cfg->{snas_dnsip};
        $hash_p2{"Domain name"}=$cfg->{snas_dnsdomainname};

        push(@p2_arr,\%hash_p2);

        @pubeths = (@{$sys->{publicnics_new}},@{$sys->{bond_nic_new}});

        for ($i = 0 ; $i < @pubeths; $i++){

            my %hash_p3=();
            $hash_p3{"System"}= $sys->{sys};        
            $hash_p3{"NIC name"}=$pubeths[$i];
            $hash_p3{"Physical IP"}=$pip[$index];
            push(@p3_arr,\%hash_p3);
            $index++
        }
    }

    $index = 0;
    for my $vip (@{$cfg->{virtualiparr}}) {
        last if ($index == $prod->{vip_display_maximum});
        $content .= "$vip ";
        $index++;
    }

    if(scalar(@{$cfg->{virtualiparr}}) > $prod->{vip_display_maximum}) {
        my $vipnum = scalar(@{$cfg->{virtualiparr}});
        $content .= "...($vipnum in total)"
    }

    my %hash_p4 = ();
    $hash_p4{"Virtual IP"} = $content;
    push(@p4_arr,\%hash_p4);

    Msg::title();
    $msg = Msg::new("Configuration checklist:");
    $msg->bold;
    Msg::n();

    Msg::table(\@p1_arr,\@element_p1);
    Msg::n();
    Msg::table(\@p2_arr,\@element_p2);
    Msg::n();
    Msg::table(\@p3_arr,\@element_p3);
    Msg::n();
    Msg::table(\@p4_arr,\@element_p4);
    Msg::n();

    $msg = Msg::new("Is this information correct?");
    $ayn = $msg->ayny;
    return 1 if ($ayn eq 'Y');

    return 0;
}

sub phase_config_update_parameter {
    my $prod = shift;
    my ($cfg,$edr,$mode,$phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);

    $cfg = Obj::cfg();
    $edr=Obj::edr();

    $phase_name="Redefining IP, hostname, DNS, gateway";
    $phase_desc=Msg::new("Redefining IP, hostname, DNS, gateway");
    $edr->{$prod->{fatal_error_key}} = 0;

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->set_fatal_error_key($prod->{fatal_error_key});
    $phase->initialize_tasks();

    $id=100;
    $task_name="product_reassigning_ip";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring IP"),
            'description_sys' => Msg::new("Configuring IP on #{SYS}"),
            'if_per_system' => 0,
            'handler' => \&handler_config_ip_update_parameter,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_hostname";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring hostname"),
            'description_sys' => Msg::new("Configuring hostname on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_hostname_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_dns";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring DNS"),
            'description_sys' => Msg::new("Configuring DNS on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_dns_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_gateway";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring gateway"),
            'description_sys' => Msg::new("Configuring gateway on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_gateway_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_clustername";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring VCS_clustername"),
            'description_sys' => Msg::new("Configuring VCS_clustername on #{SYS}"),
            'if_per_system' => 0,
            'handler' => \&handler_vcs_clustername_update_parameter,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $phase->execute_tasks();

    return $prod->handler_vcs_clustername_update_parameter_post();
}

sub handler_vcs_clustername_update_parameter_post {
    my ($prod) = @_;
    my ($output,$edr,$msg,$ayn) ;
    $edr = Obj::edr();

    if ($edr->{$prod->{fatal_error_key}} == 1) {
        Msg::n();
        $msg = Msg::new("VCS restart failed. Double check your environment");
	
        $msg->printn;
        return 0;
    }
    return 1;
}

sub phase_config_vcs_update_parameter {
    my $prod = shift;
    my ($cfg,$edr,$mode,$phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);

    $cfg = Obj::cfg();
    $edr=Obj::edr();

    $phase_name="Configuring VCS";
    $phase_desc=Msg::new("Configuring VCS");
    $edr->{$prod->{fatal_error_key}} = 0;

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->set_fatal_error_key($prod->{fatal_error_key});
    $phase->initialize_tasks();

    $id=100;
    $task_name="product_configuring_VCS";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring VCS"),
            'description_sys' => Msg::new("Configuring VCS on #{SYS}"),
            'if_per_system' => 0,
            'handler' => \&handler_config_vcs,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $phase->execute_tasks();
    return 1;
}

sub handler_config_ip_update_parameter {
    my ($prod) = @_;
    my ($output,$sysi,$sys0,$system,@syslist);

    my $cfg = Obj::cfg();
    $output = $prod->configure_ip_nics_update_parameter();
    if (!$output) {
#TBD
#return 0;
    }

    return 1;

}

sub configure_ip_nics_update_parameter {
    my ($prod) = @_;
    my ($cfg);
    my (@pubeths,@privethsold,@pubethsnew,@privethsnew,@bondnicnew,$pip,$pmask,$vip,$vmask,$output,$res,$index,$nic,$nicnew,$i,$j);
    my (@iphostsarr,@freepriviparr,@physicaliparr,@privatedevicearr,@privateiparr,@publicdevicearr,@pubip_arr,@viparr,@vip_arr,@vipdevicearr,@bond,@bondnicold,@pubethsold);
    my ($newsysname,$padv,$sys,$syslist);
    my ($bondname,$mode,$nicname_new,$nicname);
    $cfg = Obj::cfg();

    $syslist = CPIC::get('systems');
    $sys = ${$syslist}[0];
    $padv=$sys->padv;

    if ($prod->{netproto} eq $prod->{netprotoipv4}) {
        $pmask = $cfg->{snas_pnmaskstart};
        $vmask = $pmask;
       } else {
        $pmask = $cfg->{snas_pipprefix};
        $vmask = $pmask;
    }

    @physicaliparr = ();
    @publicdevicearr = ();
    @privatedevicearr = ();
    @privateiparr = ();
    @viparr = ();
    @vipdevicearr = ();
    $res = 1;
    $index = 0;
    @freepriviparr = @{$prod->{priviparr}};

    for my $system (@$syslist) {
        $newsysname = $system->{newhostname};

        @pubip_arr = @{$system->{publicip}};
        @vip_arr = @{$system->{privateip}};
        $system->set_value('hostip',$pubip_arr[0]);

        @pubethsold  = @{$system->{publicnics_new}};
        @pubethsnew  = @{$system->{publicnics_new}};
        @bond        = @{$system->{bond_nic_new}};


        $index = 0;
        while ($index < @pubethsnew) {
            $pip = $pubip_arr[$index];
            $nic = $pubethsold[$index];
            $nicnew = $pubethsnew[$index];
            # rename NIC and configure public physical IP on each system
            $output = $padv->configure_ip_sys($system,$nic,$nicnew,$pip,$pmask,$prod->{netproto});
            $res &= $output;
            push (@physicaliparr, "$pip $pmask $newsysname $nicnew");

            for ($i = $index*$cfg->{snas_nvip} ; $i < ($index+1)*$cfg->{snas_nvip}; $i++) {
                $vip = $vip_arr[$i];
                push (@viparr, "$vip $vmask");
            }
            $index++;
        }

#config bond and assign ip

        for ($i = 0; $index < @pubip_arr && $i < @bond; $i++,$index++) {
            $pip = $pubip_arr[$index];
            $bondname = $bond[$i];
            $mode = $cfg->{bondmode}{$bondname};
            $output = $padv->configure_bond_ip_common($system,$bondname,$mode,$pip,$pmask,$prod->{netproto});

            $res &= $output;
            push (@physicaliparr, "$pip $pmask $newsysname $bondname");

            for ($j = $index*$cfg->{snas_nvip} ; $j < ($index+1)*$cfg->{snas_nvip}; $j++) {
                $vip = $vip_arr[$j];
                push (@viparr, "$vip $vmask");
            }
        }
    }

    @publicdevicearr = (@bond,@pubethsnew);
    @vipdevicearr = (@bond,@pubethsnew);
    @privatedevicearr = @privethsnew;

    $prod->set_value('physicaliparr','push', @physicaliparr);
    $prod->set_value('publicdevicearr','push', @publicdevicearr);
    $prod->set_value('viparr','push', @viparr);
    $prod->set_value('vipdevicearr','push', @vipdevicearr);
    $prod->set_value('iphostsarr','push', @iphostsarr);

    return $res;

}


sub handler_restart_network_update_parameter {
    my ($prod) = @_;
    my ($syslist, $syslistsrc, $systmp, $cmd, @pubeths,@pubethsnew,@pubeths_ip, @pubeths_ip_new,@priveths,@privethsnew,@pubip_arr,$pip,$pubnic,$privnic,$pubnicnew,$privnicnew,$scripts,$output,$index,$msg,$ret,$cfg,$pipprefix,$pnmaskstart,$bits,$ipaddress,$ipproto,%nichash,$background,@newnodes,$retry,$i,$flag);
    $cfg=Obj::cfg();
    $syslistsrc = CPIC::get('systems');
    $retry = $prod->{retry_times};
    %nichash = ();

    $pipprefix = $cfg->{snas_pipprefix};
    $pnmaskstart = $cfg->{snas_pnmaskstart};
    $bits = EDRu::mask2cidr($pnmaskstart) if($prod->{netproto} eq $prod->{netprotoipv4});

    if ($prod->{netproto} eq $prod->{netprotoipv6}) {
        $ipproto = "-6";
    } else {
        $ipproto = "-4";
    }  

    $cmd = '';

    for my $system (@$syslistsrc) {
        if (!$system->{islocal}) {
            push(@$syslist,$system);
        } else {
            $systmp = $system;
        }
    }

    push(@$syslist,$systmp) if (defined $systmp);

   for my $system (@$syslist) {
       $cmd = '';
       @pubip_arr = @{$system->{publicip}};
       @pubeths_ip =  @{$system->{publicnics_old}};
       @pubeths_ip_new =  @{$system->{publicnics_new}};
       $cmd .= "/sbin/service network restart >/dev/null 2>&1;\n";
       $cmd .= "/sbin/service iptables stop >/dev/null 2>&1;\n";

$scripts = <<"_RESTART_NETWORK"; 
$cmd
_RESTART_NETWORK

    $msg = Msg::new("Restarting network of $system->{sys}, wait a few minutes...");
    $msg->printn;
       $background = 1;
       $system->cmd_script($scripts,'','',$background);
       Msg::log("finish restarting $system->{sys}");
       $system->{hostname} = $system->{newhostname};
       $system->{vcs_sysname} = $system->{hostname};
       push(@newnodes, $system->{sys});
    }

    $cfg->{newnodes} = \@newnodes;
    my $localsys=EDR::get('localsys');

    for my $system (@$syslist) {
        $flag = 0;
        $i=0;

        while ($i < $retry) {
            $i++;
            sleep 10;
            $ret = $localsys->padv->ping($system->{sys});
            if ($ret eq 'noping') {
                Msg::log("Sleep 10, ping $system->{sys} again, try $i times");
                $flag = 1;
                next;
            } else {
                $flag = 0;
                Msg::log("Restarting new IP addresses on $system->{sys} succeeded.");
                last;
            }
        }

        if ($flag) {
            $msg = Msg::new("Restarting new IP addresses on $system->{sys} failed.");
            $msg->error;
            return 0;
        }
    }

    return 1;

}

sub write_config_files_update_parameter_sys {
    my ($prod,$sys) = @_;
    my $cfg = Obj::cfg();
    my @physicaliparr =@{$prod->{physicaliparr}};
    my @viparr = @{$prod->{viparr}};
    my @iphostsarr = @{$prod->{iphostsarr}};

    $sys->mkdir($prod->{nicconf}->{filepath});
    $prod->set_physicalipfile_sys($sys,@physicaliparr);
    $prod->set_consoleipfile_sys($sys);
    $prod->set_globalroutesfile_sys($sys);
    $prod->update_hosts_file_sys($sys,@iphostsarr);

    return 1;
}

sub build_key_path_update_parameter_sys {
    my ($prod,$sys) = @_;
    my (%kvs,$cfg,$edr,$cpic,$mode,$file,$output);

    %kvs = ();
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();

    $edr=Obj::edr();
    my $tmpdir=EDR::tmpdir();

    my $filelocpath = "$tmpdir/nasinstall.conf";
    $file = $prod->{nicconf}->{nasinstallconf};

    if ($sys->exists($file)) {
        $sys->copy_to_sys($prod->localsys,$file,$filelocpath);
        $output = $prod->read_default_values($filelocpath);
    } else {
        Msg::log("$file does not exist");
    }

    %kvs = $prod->{default}; 

    $kvs{"GATEWAYNAME"}=$cfg->{snas_clustername};
    $kvs{"NNODES"}=@{$cpic->{systems}};
    $kvs{"SEPCONSOLE"}=$cfg->{snas_sepconsoleport};
    $kvs{"NVIPS"}=$cfg->{snas_nvip};
    $kvs{"PIPSTART"}=$cfg->{snas_pipstart};
    $kvs{"PIPMASK"}=$cfg->{snas_pnmaskstart};
    $kvs{"VIPMASK"}=$cfg->{snas_vnmaskstart};
    $kvs{"VIPSTART"}=$cfg->{snas_vipstart};
    $kvs{"CONSIP"}=$cfg->{snas_consoleip};
    $kvs{"DNS"}=$cfg->{snas_dnsip};
    $kvs{"DOMAINNAME"}=$cfg->{snas_dnsdomainname};
    $kvs{"GATEWAY"}=$cfg->{snas_defgateway};
    $kvs{"NTPSERVER"}=$cfg->{snas_ntpserver};
    $kvs{"NETPROTO"}=$prod->{netproto};

    return \%kvs;
}

sub build_nasinstallconf_update_parameter_sys {
    my ($prod,$sys) = @_;
    my ($padv,@items,$confhash,$macs,$mac);

    $padv=$sys->padv;
    $confhash = $prod->build_key_path_update_parameter_sys($sys);
    if ($sys->system1 && !Cfg::opt('addnode')) {
        $confhash->{"MODE"}=$prod->{mode}->{master};
    } else {
        $confhash->{"MODE"}=$prod->{mode}->{slave};
    }

    foreach my $key(sort (keys %{$confhash})) {
        next if (!defined $confhash->{$key});
        push (@items,$key);
        push (@items,"\"$confhash->{$key}\"");
    }

    $sys->set_value('nasinstallconf','push', @items);
    return 1;
}

sub write_nasinstallconf_update_parameter_sys{
    my ($prod,$sys) = @_;
    my ($file,$filelocpath,$obj,$edr,$cpic,$tmpdir);

    $edr=Obj::edr();
    $tmpdir=EDR::tmpdir();

    $filelocpath = "$tmpdir/nasinstall.conf";
    $file = $prod->{nicconf}->{nasinstallconf};

    $sys->mkdir("$prod->{nicconf}->{nodefilepath}");
    $sys->cmd("_cmd_touch $prod->{nicconf}->{nasinstallconf}");

    $prod->build_nasinstallconf_update_parameter_sys($sys);

    $prod->set_default_values($filelocpath,@{$sys->{nasinstallconf}});
    if ($sys->{islocal}) {
        $sys->copyfile($filelocpath,$file);
    } else {
        $edr->localsys->copy_to_sys($sys,$filelocpath,$file);
    }
    return 1;
}


sub handler_config_vcs {
    my ($prod) = @_;
    my ($output,$cpic,$sys0,$vcs);
    $cpic=Obj::cpic();

    $sys0=${$cpic->{systems}}[0];
    
    $output = $prod->consoleip_update_parameter($sys0);
    if(!$output) {
        Msg::log("ManagementConsole offline failed");
        return 0;
    }

    $vcs = $prod->prod('VCS61');

    $output = $sys0->cmd("$vcs->{bindir}/hagrp -wait ManagementConsole State ONLINE -sys $sys0->{newhostname} -time 240 2>/dev/null");
    if(EDR::cmdexit()) {
        Msg::log("ManagementConsole start failed");
        return 0;
    }

    $prod->vip_update_parameter_sys($sys0);
    return 1;
}

sub vip_update_parameter_sys {
    my ($prod,$sys) = @_;
    my ($output,@oldviplist,$content,$scripts,$background,$index);
    my $cfg = Obj::cfg();
    my @newviplist = @{$prod->{viparr}};

    $output = $sys->cmd("_cmd_cat $prod->{nicconf}->{vipfile} 2>/dev/null");
    return 0 if($output eq '');

    my @vipliststr = split(/\n/,$output);
    for my $line (@vipliststr) {
        my @vip = split(/ /,$line);
        push (@oldviplist,$vip[0]);
    }

    $output = $sys->cmd("_cmd_cat $prod->{nicconf}->{publicdevicefile} 2>/dev/null");
    return 0 if($output eq '');
    my @publicdevicelist = split(/ /,$output);
    if ($cfg->{snas_sepconsoleport}) {
        my $eth = shift @publicdevicelist;
        Msg::log("using sepconsoleport, remove $eth from public device list");
    }

    $content = '';

    my $log = "$prod->{logdir}/$prod->{scriptslog}";
    for my $vip (@oldviplist) {
        $content .= "/bin/bash $prod->{scriptsdir}/net/net_ipconfig.sh del $vip >> $log 2>&1\n";
    }

    $index = 0;
    for my $viparr (@newviplist) {
        my @vip = split(/ /,$viparr);
        my $device = $publicdevicelist[$index%(scalar(@publicdevicelist))];
        $content .= "/bin/bash $prod->{scriptsdir}/net/net_ipconfig.sh add $vip[0] $vip[1] virtual $device any >> $log 2>&1\n" ;
        $index++;
    }

$scripts = <<"_NIC_CONFIG"; 
$content
_NIC_CONFIG

    $background = 0;
    $output = $sys->cmd_script($scripts,'','',$background);

    return 1;
}

sub handler_vcs_clustername_update_parameter {
    my ($prod) = @_;
    my ($cpic,$output,$i,$edr,$flag,$cfg,$vcs,$sys0);
    $cpic=Obj::cpic();
    $edr = Obj::edr();


    #stop all VCS on slave node
    for my $system (@{CPIC::get('systems')}) {
        $output = $prod->stop_vcs_proc_sys($system);
        if (!$output) {
            $edr->{$prod->{fatal_error_key}} = 1;
            Msg::log("stop vcs on $system->{sys} failed");
            return 0;
        } else {
            Msg::log("stop vcs on $system->{sys} successfully");
        }
    }

    #update the hostname of all the files
    $prod->update_vcs_config_file_update_parameter();

    for my $sys (@{CPIC::get('systems')}) {
        $output = $prod->start_vcs_proc_sys($sys);
        if (!$output) {
            $edr->{$prod->{fatal_error_key}} = 1;
            return 0; 
        }
        $output = $prod->check_vcs_status($sys);
        if(!$output) {
            Msg::log("restart VCS failed");
            $edr->{$prod->{fatal_error_key}} = 1;
            return 0;
        }
    }

    return 1;
}

sub stop_vcs_proc_sys {
    my ($prod,$sys) = @_;
    my ($i, $output, $sysname);
    my $cpic=Obj::cpic();
    my $vcs=$prod->prod('VCS61');

    while($i < $prod->{retry_times}*5) {
        $output = $sys->cmd("_cmd_hastop -local 2>/dev/null");
        my $had = $sys->proc('had61');
        last if (!$had->check_sys($sys,'start'));
        sleep 10;
        $i++;
    }

    $sysname = $vcs->get_vcs_sysname_sys($sys);
    $sys->cmd("_cmd_vxclustadm stopnode -sys $sysname 2>/dev/null");

    for my $proci (qw(vxfen61 gab61 llt61)) {
        my $proc = $sys->proc($proci);
        if (!$cpic->proc_stop_sys($sys, $proc)) {
            Msg::log("stop $proci on $sys->{sys} failed");
            return 0;
        }
    }
    return 1;
}

sub update_vcs_config_file_update_parameter {
    my ($prod) = @_;
    my ($edr,$cfg,$cpic,$vcs,$sys0);
    $edr = Obj::edr();
    $cfg = Obj::cfg();
    $cpic=Obj::cpic();
    
    for my $system (@{CPIC::get('systems')}) {
        for my $sys (@{CPIC::get('systems')}) {
            my $old_name = $sys->{oldhostname};
            my $new_name = $sys->{newhostname};
            $system->cmd("_cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{maincf} 2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{hostsfile} 2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{sysname} 2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{llthosts} 2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{llttab}  2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{cpuinfofile} 2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{optionfile} 2>/dev/null; _cmd_sed -i \"s/$old_name/$new_name/g\" $prod->{nicconf}->{guifile} 2>/dev/null");
        }
        $system->cmd("_cmd_sed -i \"s/\'$prod->{old_cluster_name}\'/\'$cfg->{snas_clustername}\'/g\" $prod->{nicconf}->{smbglobalconf} 2>/dev/null"); 
        $system->cmd("_cmd_sed -i \"s/$prod->{old_cluster_name}/$cfg->{snas_clustername}/g\" $prod->{nicconf}->{nlmmonitorname} 2>/dev/null");

        $system->cmd("_cmd_sed -i \"s/cluster $prod->{old_cluster_name}/cluster $cfg->{snas_clustername}/g\" $prod->{nicconf}->{maincf} 2>/dev/null");
        $system->cmd("_cmd_sed -i \"s/NetBiosName = $prod->{old_cluster_name}/NetBiosName = $cfg->{snas_clustername}/g\" $prod->{nicconf}->{maincf} 2>/dev/null");
        $system->cmd("_cmd_sed -i \"s/CVMClustName = $prod->{old_cluster_name}/CVMClustName = $cfg->{snas_clustername}/g\" $prod->{nicconf}->{maincf} 2>/dev/null");
    }
    return 1;
}

sub start_vcs_proc_sys {
    my ($prod,$sys) = @_;
    my $cpic=Obj::cpic();
    for my $proci (qw(llt61 gab61 vxfen61)) {
        my $proc = $sys->proc($proci);
        if (!$cpic->proc_start_sys($sys, $proc)) {
            return 0;
        }
    }
    $sys->cmd("_cmd_hastart 1>/dev/null 2>&1");
    return 1;
}

sub check_vcs_status {
    my ($prod,$sys) = @_;
    my ($output,$i,$had);
    $i = 0;
    $had = $sys->proc('had61');
    while($i < $prod->{retry_times}*20) {
        $output = $had->check_sys($sys,'poststart');
        return 1 if($output);
        sleep 10;
        $i++;
    }
    return 0;
}

sub consoleip_update_parameter {
    my ($prod,$sys) = @_;
    my ($output);
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');

    $vcs->haconf_makerw();
    $output = $sys->cmd("$vcs->{bindir}/hagrp -offline ManagementConsole -any 2>/dev/null");
    $output = $sys->cmd("$vcs->{bindir}/hagrp -wait ManagementConsole State OFFLINE -sys $sys->{newhostname} -time 240 2>/dev/null");
    if(EDR::cmdexit()) {
        Msg::log("ManagementConsole OFFLINE failed");
        return 0;
    }

    $output = $sys->cmd("$vcs->{bindir}/hares -modify consoleIP Address $cfg->{snas_consoleip} 2>/dev/null");
    $output = $sys->cmd("$vcs->{bindir}/hares -modify consoleIP NetMask $cfg->{snas_pnmaskstart} 2>/dev/null");
    $vcs->haconf_dumpmakero();
    $output = $sys->cmd("$vcs->{bindir}/hagrp -clear ManagementConsole");
    $output = $sys->cmd("$vcs->{bindir}/hagrp -online -propagate ManagementConsole -sys $sys->{newhostname} 2>/dev/null");
    return 1;
}
##########################update parameter end###########################

sub op_nic_hostname {
    my $prod = shift;
    my ($msg,$output,$done,$sub,$msg,$ayn,$cpic,$flag,$ayn);
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    $flag = 1;

    $output = $prod->preconfig_precheck();
    if ($output == 0) {
        $msg = Msg::new("The NICs have been configured. Use the -updateparameter option if you want to re-configure the network parameters");
        $msg->error();
        $cpic->edr_completion();
    }

    if ($output == 2){
        $msg = Msg::new("$prod->{nicconf}->{udevconffile} is not found");
        $msg->error();
        return 2;
    }

    if ($output == 3){
        $msg = Msg::new("Manually remove your bonded NICs first");
        $msg->error();
        return 2;
    }

    do {
        $output = $prod->cli_ask_start_value();
        if (!$output) {
            Msg::log("Errors in sub cli_ask_start_value with return value: $output");
            return 0;
        }

        $output = $prod->init_internal_val();

        $output = $prod->phase_detect_nic();
        if ($output == 1) {
        }
        if ($output ==2) {
            Msg::log("Errors in sub phase_detect_nic with return value: $output");
            return 0;
        }
        if ($output ==3) {
            next;
        }

        if (Cfg::opt('responsefile')) {
            if ($prod->is_responsefile_for_bonding_or_exclusion()){
                $output = $prod->init_bondpool_val();
                if ($output == 2) {
                    return 2;
                }
 
                $prod->bond_adapter_post();
            } else {
                $output = $prod->proc_nic_val();
                if ($output == 2) {
                    return 2;
                }
            }
        } else {
            Msg::n();
            $msg = Msg::new("Do you want to configure NIC bonding or exclude NICs?");
            $ayn = $msg->aynn;
            if($ayn eq 'Y') {
                $output = $prod->cli_ask_pci_display();
                if ($output == 2) {
                    return 2; 
                }
            } else {
                $output = $prod->proc_nic_val();
                if ($output == 2) {
                    return 2; 
                }
            }
        }

        $output = $prod->phase_detect_ip();
        if (!$output) {
            return 0;
        }

        $output = $prod->buildup_config_info();

        $output = $prod->display_info();
        next if(!$output);

        $output = $prod->phase_config_nic_ip_hostname();
        if (!$output) {
            Msg::log("Errors in sub phase_config_nic_ip_hostname with return value: $output");
            return 0;
        }

        $output = $prod->phase_config_nic_ip_hostname_post();
        if (!$output) {
            return 0;
        }

        $output = $prod->write_nasinstallconf();

        $output = $prod->handler_restart_network();

        if (!$output) {
            $prod->reboot_messages();
            $cpic=Obj::cpic();
            $cpic->edr_completion();
        } else {
            Msg::n();
            $msg=Msg::new("Redefining NIC, IP, hostname, DNS, gateway completed successfully.");
            $msg->bold;
        }
        $flag = 0;
    } while ($flag);

    return 1;
}

sub init_cfg_val {
    my $prod = shift;
    my ($cfg,$clustername,$sys,$cpic,$console_ip);
    my (@private_devs,@public_devs,@vips,$netmask_list,$dev_list,$vip,$nvip,$netmask);
    my (@epws,@pris,@users,$epw,$user,$vcs_prod);
    $cpic = Obj::cpic();
    $sys = @{$cpic->{systems}}[0];
    $cfg = Obj::cfg();
    $vcs_prod = $prod->prod('VCS61');

    return 1 if (Cfg::opt('responsefile'));
    $clustername = $sys->cmd("_cmd_hostname 2>/dev/null");
    $clustername=~s/_(\d+)$//g;
    $cfg->{snas_clustername} = $clustername;

    # add users
    $vcs_prod->set_vcsencrypt();
    $user = 'admin';
    $epw = $vcs_prod->encrypt_password('password');
    push(@users,$user);
    push(@epws,$epw);
    push(@pris,'Administrators');
    $cfg->{vcs_username} = \@users;
    $cfg->{vcs_userpriv} = \@pris;
    $cfg->{vcs_userenpw} = \@epws;

    #FIXME: return for now.
    return 1;
    $console_ip = $sys->cmd("_cmd_cat $prod->{nicconf}->{consoleipfile} 2>/dev/null");
    chomp($console_ip);
    $console_ip = EDRu::despace($console_ip);
    $cfg->{snas_console_ip} = $console_ip;
    
    $dev_list = $sys->cmd("_cmd_cat $prod->{nicconf}->{publicdevicefile} 2>/dev/null"); 
    @public_devs = split(/\s+/, $dev_list);
    $cfg->{snas_public_nics} = \@public_devs;

    $dev_list = $sys->cmd("_cmd_cat $prod->{nicconf}->{privatedevicefile} 2>/dev/null");
    @private_devs = split(/\s+/, $dev_list);
    $cfg->{snas_private_nics} = \@private_devs;

    $netmask_list = $sys->cmd("_cmd_cat $prod->{nicconf}->{vipfile} 2>/dev/null");
    for my $line(split(/\n/, $netmask_list)) {
        ($vip, $netmask) = split(/\s+/, $line);
        push (@vips, $vip) if ($vip);
        $cfg->{snas_vip_netmask} ||= $netmask;
    };
    $cfg->{snas_vips} = \@vips;

    $nvip = $sys->cmd("_cmd_grep '^NVIPS' $prod->{nicconf}->{nasinstallconf} 2>/dev/null");
    if ( $nvip =~ /^NVIPS.*=\D*(\d+)/) {
        $cfg->{snas_nvips_per_nic} = $1;
    }

    return 1;
}

sub init_internal_val {
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

    if (!Cfg::opt('responsefile')) {
        undef $cfg->{bondpool};
        undef $cfg->{bondmode};
    }

    for my $sys (@{$cpic->{systems}}) { 
        undef($sys->{oldhostname});
        undef($sys->{newhostname});
        undef(@{$sys->{allnics}});
        undef(@{$sys->{allnics_pciid}});
        undef(@{$sys->{unpingnics_pciid}});
        undef(@{$sys->{publicnics}});
        undef(@{$sys->{privenics}});
        undef(@{$sys->{unpingnics}});
        undef($sys->{npublicnics});
        undef($sys->{nprivenics});
        undef(@{$sys->{publicnics_all_old}});
        undef(@{$sys->{publicnics_all_new}});
        undef(@{$sys->{publicnics_new}});
        undef(@{$sys->{publicnics_old}});
        undef(@{$sys->{privenics_new}});
        undef(@{$sys->{bond_nic_new}});
        undef(@{$sys->{bond_nic_old}});
        undef(@{$sys->{publicip}});
        undef(@{$sys->{publicnetmask}});
        undef(@{$sys->{privateip}});
        undef(@{$sys->{privatenetmask}});
    }
    return 1;
}

sub phase_detect_nic {
    my $prod = shift;
    my ($cfg,$edr,$mode,$phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);

    $cfg = Obj::cfg();
    $edr=Obj::edr();
    $mode = Cfg::opt('serial');
    Cfg::set_opt('serial', 1) if ($mode eq '');

    $phase_name="Detecting PCI Devices, Network Devices";
    $phase_desc=Msg::new("Detecting network devices");
    $edr->{$prod->{fatal_error_key}} = 0;

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->set_fatal_error_key($prod->{fatal_error_key});
    $phase->initialize_tasks();


    $id=100;
    $task_name="product_checking_nics";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Detecting Network Devices"),
            'description_sys' => Msg::new("Detecting Network Devices on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_check_nics_sys,
            'handler_object_arg' => $prod,
            'post_handler' => \&post_handler_check_nics,
            'post_handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

     $phase->execute_tasks();

    Cfg::unset_opt('serial') if ($mode eq '');

    return $prod->phase_detect_nic_post();
}

sub phase_detect_ip {
    my $prod = shift;
    my ($cfg,$edr,$mode,$phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);

    $cfg = Obj::cfg();
    $edr=Obj::edr();
    $mode = Cfg::opt('serial');

    return 1 if (Cfg::opt('responsefile') && !Cfg::opt('addnode')); 
    Cfg::set_opt('serial', 1) if ($mode eq '');

    $phase_name="Detecting Available IPs";
    $phase_desc=Msg::new("Detecting available IPs");
    $edr->{$prod->{ip_error_key}} = 0;

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->set_fatal_error_key($prod->{fatal_error_key});
    $phase->initialize_tasks();

    $id=100;
    $task_name="product_detecting_ips";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Detecting available IPs"),
            'description_sys' => Msg::new("Detecting available IPs"),
            'if_per_system' => 0,
            'handler' => \&handler_check_ip,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

     $phase->execute_tasks();

    Cfg::unset_opt('serial') if ($mode eq '');

    return $prod->phase_check_ip_post();
}

sub phase_detect_nic_post {
    my $prod = shift;
    my ($msg,$cfg,$edr,$cpic,$backopt,$ayn,$help,@errorsysarr,$errorsys);
    $cfg = Obj::cfg();
    $edr=Obj::edr();
    $cpic = Obj::cpic();
    @errorsysarr=();
    $edr->{$prod->{fatal_error_key}} = 0;
    for my $sys (@{$cpic->{systems}}) {
        if ($sys->{$prod->{fatal_error_key}}) { 
            $edr->{$prod->{fatal_error_key}} = 1;
            push (@errorsysarr,$sys->{sys});
        }
    }

    Msg::n();
    $msg=Msg::new("Detecting PCI devices and network devices completed successfully.");
    $msg->bold;

    if ($edr->{$prod->{fatal_error_key}}) {
        $errorsys = join(' ',@errorsysarr);
        Msg::n();
        if ($cfg->{snas_sepconsoleport}) {
            $msg = Msg::new("Separate console port uses one public NIC exclusively");
            $msg->print();
        }
        $msg=Msg::new("Not enough network devices exist on $errorsys.");
        $msg->error();
        return 2;
    }

    return 1;
}

sub phase_config_nic_ip_hostname {
    my $prod = shift;
    my ($phase,$phase_name, $phase_desc,$task_name,%task_params,$id,$task);
    my $cfg = Obj::cfg();
#Cfg::set_opt('serial', 1);
    $phase_name="Redefining NIC, IP, hostname, DNS, gateway";
    $phase_desc=Msg::new("Redefining NIC, IP, hostname, DNS, gateway");

    $phase= Phase->new($phase_name);
    $phase->set_description($phase_desc);
    $phase->initialize_tasks();

    $id=100;
    $task_name="product_renaming_nics";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring NICs"),
            'description_sys' => Msg::new("Configuring NICs on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_nicnames_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_reassigning_ip";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring IP"),
            'description_sys' => Msg::new("Configuring IP on #{SYS}"),
            'if_per_system' => 0,
            'handler' => \&handler_config_ip,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_hostname";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring hostname"),
            'description_sys' => Msg::new("Configuring hostname on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_hostname_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_dns";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring DNS"),
            'description_sys' => Msg::new("Configuring DNS on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_dns_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $id+=100;
    $task_name="product_redefining_gateway";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Configuring gateway"),
            'description_sys' => Msg::new("Configuring gateway on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_config_gateway_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

#skip user group configuration
#   $id+=100;
#   $task_name="product_config_usergroup";
#   %task_params=(
#           'sequence_id' => $id,
#           'description' => Msg::new("Configuring User and Group"),
#           'description_sys' => Msg::new("Configuring User and Group on #{SYS}"),
#           'if_per_system' => 1,
#           'handler' => \&handler_users_groups_sys,
#           'handler_object_arg' => $prod,
#           );
#   $task=Task->new($task_name, %task_params);
#   $phase->add_task($task);

    $id+=100;
    $task_name="product_post_config_nicnames";
    %task_params=(
            'sequence_id' => $id,
            'description' => Msg::new("Performing postremove tasks"),
            'description_sys' => Msg::new("Performing postremove tasks on #{SYS}"),
            'if_per_system' => 1,
            'handler' => \&handler_postconfig_nicnames_sys,
            'handler_object_arg' => $prod,
            );
    $task=Task->new($task_name, %task_params);
    $phase->add_task($task);

    $phase->execute_tasks();

    return 1;
}

sub phase_config_nic_ip_hostname_post {
    my ($prod) = @_;
    my ($cfg);

    $cfg = Obj::cfg();
    $cfg->{opt}{confignic}=1;
    return 1;
}

sub handler_check_nics_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$padv,$edr,$oldhostname,$ethall,$nerreths,$nconneths,$ndisconneths,$nexclusioneths,@conneths,@disconneths,@unpingeths,@erreths,@exclusioneths,$output,$pipstart,$gateway,$pnmaskstart,$ipproto,$src_ipv4,$src_ipv6,$src_mask,$src_prefix,$expand_src_ipv6,$expand_sys_ipv6,@src_ipv4_arr,@src_ipv6_arr,@src_mask_arr,@src_prefix_arr,$scripts,$bits,$pipprefix,$ipaddress,$cmd,@src_prefixaddr,%src_ipv6_hash,$background,$retry,$flag,$i,$msg);
    $cfg = Obj::cfg();
    $padv=$sys->padv;
    $edr=Obj::edr();

    $ethall=$padv->get_all_nic_sys($sys);

#here use gateway from client
#$gateway = $padv->get_gateway_sys($sys);
    $gateway = $cfg->{snas_defgateway};
    $pipstart = $cfg->{snas_pipstart};
    $pipprefix = $cfg->{snas_pipprefix};
    $pnmaskstart = $cfg->{snas_pnmaskstart};
    $bits = EDRu::mask2cidr($pnmaskstart) if($prod->{netproto} eq $prod->{netprotoipv4});
    $oldhostname = $sys->cmd("_cmd_hostname 2>/dev/null");
    $sys->set_value('oldhostname',$oldhostname);

    if ($prod->{netproto} eq $prod->{netprotoipv6}) {
        $ipaddress = "$pipstart\/$pipprefix";
        $ipproto = "-6";
    } else {
        $ipaddress = "$pipstart\/$bits";
        $ipproto = "-4";
    }

    $nerreths=0;
    $nconneths=0;
    $ndisconneths=0;
    $nexclusioneths=0;
    %src_ipv6_hash=();
    @conneths=();
    @disconneths=();
    @unpingeths=();
    @erreths=();
    @src_ipv4_arr = ();
    @src_ipv6_arr = ();
    @src_mask_arr = ();
    @src_prefix_arr = ();
    @src_ipv6_arr = ();
    @exclusioneths = ();

$scripts = <<"_NIC_CONFIG"; 
/sbin/chkconfig --level 0123456 NetworkManager off >/dev/null 2>&1;
/sbin/chkconfig --level 0123456 iptables off >/dev/null 2>&1;
/sbin/service NetworkManager stop >/dev/null 2>&1;
/sbin/service iptables stop >/dev/null 2>&1;
/bin/sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config;
/bin/echo 0 >/selinux/enforce;
/sbin/service network restart >/dev/null 2>&1;
/sbin/sysctl -w net.ipv4.conf.all.rp_filter=0 >/dev/null 2>&1;
/sbin/sysctl -w net.ipv4.conf.default.rp_filter=0 >/dev/null 2>&1;
_NIC_CONFIG

    $background = 1;
    $flag = 0;
    $output = $sys->cmd_script($scripts,'','',$background);
    $retry = $prod->{retry_times}*3;
    $i = 0;
    
    while ($i < $retry) {
        $i++;
        sleep 10;
        $output = $sys->padv->ping($sys->{sys});
        if ($output eq 'noping') {
            Msg::log("Sleep 10, ping $sys->{sys} again, try $i times"); 
            $flag = 1;
            next;
        } else {
            $flag = 0;
            last;
        }
    }

    if ($flag) {
        $msg = Msg::new("Restarting network on $sys->{sys} failed.");
        $msg->error;
        $sys->set_value($prod->{fatal_error_key},2);
        return 0;
    }

    for my $eth (@{$ethall}) {
        $src_ipv4 = $sys->cmd("_cmd_ifconfig $eth | _cmd_grep 'inet addr' | _cmd_awk '{print \$2}'|_cmd_awk -F: '{print \$2}'");
        if(EDR::cmdexit()!=0) {
            Msg::log("Get ipv4 address failed");
            next;
        }

        $src_mask = $sys->cmd("_cmd_ifconfig $eth | _cmd_grep 'Mask' | _cmd_awk '{print \$4}'| _cmd_awk -F: '{print \$2}'");
        if(EDR::cmdexit()!=0) {
            Msg::log("Get netmask failed");
            next;
        }

        $src_ipv6 = $sys->cmd("_cmd_ifconfig $eth | _cmd_grep 'inet6 addr' | _cmd_awk '{print \$3}'|_cmd_awk -F'/' '{print \$1}'");
        if(EDR::cmdexit()!=0) {
            Msg::log("Get ipv6 address failed");
            next;
        }

        my @src_ipv6addr = split(/\n/,$src_ipv6);
        $src_ipv6_hash{$eth}=\@src_ipv6addr;

        $src_prefix = $sys->cmd("_cmd_ifconfig $eth | _cmd_grep 'inet6 addr' | _cmd_awk '{print \$3}'|_cmd_awk -F'/'  '{print \$2}'");
        @src_prefixaddr = split(/\n/,$src_prefix);
        $output = $sys->cmd("/sbin/sysctl -w net.ipv4.conf.$eth.rp_filter=0");

        if ($src_ipv4 eq '' || $src_mask eq '') {
            $src_ipv4 = "0.0.0.0";
            $src_mask = "0.0.0.0";
        }

        if ($src_ipv6addr[0] eq '' || $src_prefixaddr[0] eq '') {
            $src_ipv6 = "0:0:0:0:0:0:0:0";
            $src_prefix = 64;
        } else {
            $src_ipv6 = $src_ipv6addr[0];
            $src_prefix = $src_prefixaddr[0];
        }

        push (@src_ipv4_arr,$src_ipv4);
        push (@src_ipv6_arr,$src_ipv6);
        push (@src_mask_arr,$src_mask);
        push (@src_prefix_arr,$src_prefix);

        $expand_src_ipv6 = $prod->get_next_ip($src_ipv6,0);
        $expand_sys_ipv6 = $prod->get_next_ip($sys->{sys},0);
        if ($src_ipv4 eq $sys->{sys} || $src_ipv4 eq $sys->{ip} || EDRu::inarr($sys->{sys},@src_ipv6addr) || EDRu::inarr($sys->{ip},@src_ipv6addr) || $expand_src_ipv6 eq $expand_sys_ipv6 ||$prod->find_exclusion_nic_sys($sys,$eth)) {
            next;
        } else {
            $output = $sys->cmd("_cmd_ip addr flush $eth >/dev/null 2>&1; _cmd_ifconfig $eth down >/dev/null 2>&1");
        }
    }

    my $id = 0; 
    for my $eth (@{$ethall}){
        if ($prod->find_exclusion_nic_sys($sys,$eth)) {
            $id++;
            push (@exclusioneths, $eth); 
            $nexclusioneths++;
            next;
        }

        if (@src_ipv4_arr[$id] eq $sys->{sys} || @src_ipv6_arr[$id] eq $sys->{sys} || @src_ipv4_arr[$id] eq $sys->{ip} || EDRu::inarr($sys->{ip},@{$src_ipv6_hash{$eth}}) || EDRu::inarr($sys->{sys},@{$src_ipv6_hash{$eth}})) {
            $id++;
            $nconneths++;
            push (@conneths, $eth);
            next;
        }

        $id++;

$scripts = <<"_NIC_CONFIG";
/sbin/ip link set $eth up >/dev/null 2>&1;
/sbin/ip addr flush $eth  >/dev/null 2>&1;
/sbin/ip $ipproto addr add $ipaddress dev $eth >/dev/null 2>&1;
_NIC_CONFIG

        $background = 1;
        $output = $sys->cmd_script($scripts,'','',$background);

        sleep 5;
        if(EDR::cmdexit()!=0) {
            $nerreths++;
            push (@erreths, $eth);
            Msg::log("set up $eth failed, set as error nics");
            next;
        }

        if ($prod->{netproto} eq $prod->{netprotoipv4}) {
            $output = $sys->cmd("_cmd_ping -i 2 -c 3 -I $eth $gateway 2>/dev/null");
        } else {
            Msg::log("detecting $eth with ping6 command");
            $output = $sys->cmd("_cmd_ping6 -i 2 -c 3 -I $pipstart $gateway 2>/dev/null");
        }

        if (!EDR::cmdexit()) {
            $nconneths++;
            push (@conneths, $eth);
        } else {
            if ($ndisconneths < $prod->{max_priv_nic_num}) {
                $ndisconneths++;
                push (@disconneths, $eth);
            } else {
                $nconneths++;
                push (@conneths, $eth);
            }
            push (@unpingeths, $eth);
        }
        
        $output = $sys->cmd("_cmd_ip addr flush $eth >/dev/null 2>&1; _cmd_ifconfig $eth down >/dev/null 2>&1");
    }

    for my $eth (@{$ethall}) {
        $src_ipv4 = shift  @src_ipv4_arr;
        $src_ipv6 = shift  @src_ipv6_arr;
        $src_mask = shift @src_mask_arr;
        $src_prefix = shift @src_prefix_arr;

        if ($src_ipv4 eq $sys->{sys} || $src_ipv4 eq $sys->{ip} || EDRu::inarr($sys->{sys},@{$src_ipv6_hash{$eth}}) || EDRu::inarr($sys->{ip},@{$src_ipv6_hash{$eth}}) || $prod->find_exclusion_nic_sys($sys,$eth)) {
            next;
        } else {
            if ($src_ipv4 ne "0.0.0.0" || $src_ipv6 ne "0:0:0:0:0:0:0:0") {
                $cmd = '';

                if ($src_ipv4 ne "0.0.0.0") {
                    $bits = EDRu::mask2cidr($src_mask);
                    $ipaddress = "$src_ipv4\/$bits";
                    $ipproto = "-4";
                    $cmd .= "/sbin/ip $ipproto addr add $ipaddress dev $eth  >/dev/null 2>&1;\n";
                }
                if ($src_ipv6 ne "0:0:0:0:0:0:0:0") {
                    $ipaddress = "$src_ipv6\/$src_prefix";
                    $ipproto = "-6";
                    $cmd .= "/sbin/ip $ipproto addr add $ipaddress dev $eth  >/dev/null 2>&1;\n";
                }

$scripts = <<"_NIC_CONFIG"; 
/sbin/ip link set $eth up >/dev/null 2>&1;
/sbin/ip addr flush $eth >/dev/null 2>&1;
$cmd
_NIC_CONFIG

                $background = 1;
                $output = $sys->cmd_script($scripts,'','',$background);
                sleep 5;

            } else {
                $output = $sys->cmd("_cmd_ifconfig $eth up >/dev/null 2>&1");
                $output = $sys->cmd("_cmd_ip addr flush dev $eth >/dev/null 2>&1");
            }
        }
    }

#if ($prod->ismasternode()) {

#    }

    $sys->set_value('allnics','push',@{$ethall});
    $sys->set_value('publicnics','push',@conneths);
    $sys->set_value('privenics','push',@disconneths);
    $sys->set_value('unpingnics','push',@unpingeths);
    $sys->set_value('exclusioneths','push',@exclusioneths);
    $sys->set_value('npublicnics',$nconneths);
    $sys->set_value('nprivenics',$ndisconneths);
    $sys->set_value('nexclusioneths',$nexclusioneths);

    $nconneths-- if ($cfg->{snas_sepconsoleport});
    if ($nconneths >= $prod->{minimum_pub_nic_num} && $ndisconneths >= $prod->{minimum_priv_nic_num}) {
        return 1;
    } else {
        $sys->set_value($prod->{fatal_error_key},1);
        return 0;
    }
}

sub handler_pciexclusion_sys {
    my ($prod, $sys) = @_;
    my ($cfg, $edr, $msg, @pciid, @exclusionnic, $counter, $output,@fieldarr,$index,$i);
    $cfg = Obj::cfg();
    $edr = Obj::edr();
    @exclusionnic = ();
    $counter = 0;

    if (!$cfg->{snas_pciexclusionid}) {
        $sys->set_value('pciexclusion','push',@exclusionnic);
        return 1;
    }

    @pciid = split(/\s+|[,;_]/,$cfg->{snas_pciexclusionid});

    for my $id (@pciid) {
        $output = $sys->cmd("_cmd_lshal | _cmd_grep 'linux.sysfs_path =.*/net/.*' | _cmd_grep -v 'virtual' |_cmd_awk -F \\' '{print \$2}'| _cmd_grep -iw $id"); 
        @fieldarr = split(/\//,$output);
        $index = @fieldarr;
        for ($i = $index -1; $i >= 0; $i--) {
            if(@fieldarr[$i] eq "net"){
                push (@exclusionnic, @fieldarr[$i+1]);
                $counter++;
                last;
            }
        }
    }

    $sys->set_value('pciexclusion','push',@exclusionnic);
    return 1;
}

sub find_exclusion_nic_sys {
    my ($prod,$sys,$nic) = @_;
    my ($match);
    my $cfg = Obj::cfg();
    $match = grep /^$nic/,@{$sys->{pciexclusion}};
    return 1 if ($match);
    return 0;
}

sub handler_config_gateway_sys {
    my ($prod, $sys) = @_;
    my ($cfg, $padv, $edr, $msg, $output);
    $cfg = Obj::cfg();
    $padv=$sys->padv;
    $output = $padv->configure_gateway_sys($sys,$cfg->{snas_defgateway});
    if ($output) {
    
    } else {
    
    }
    return 1;
}

sub phase_check_ip_post {
    my ($prod) = @_;
    my ($output,$edr,$msg,$ayn) ;

    $edr = Obj::edr();

    if ($edr->{$prod->{ip_error_key}} == 2) {
        Msg::n();
        $msg = Msg::new("There are not enough available public IP's starting with initial IP address. Do you want to retry the configuration?");
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 2;
        }
        return 3;
    }

    if ($edr->{$prod->{ip_error_key}} == 3) {
        Msg::n();
        $msg = Msg::new("There are not enough available virtual IP's starting with initial IP address. Do you want to retry the configuration?");
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 2;
        }
        return 3;
    }

    return 1;
}



sub handler_check_ip {
    my ($prod) = @_;
    my ($cfg, $edr, $output);
    my $cfg = Obj::cfg();
    my $edr = Obj::edr();
    return 1 if (Cfg::opt('responsefile') && !Cfg::opt('addnode'));
    if ($prod->{netproto} eq $prod->{netprotoipv4}) {
        $output = $prod->precheck_ip_range($cfg->{snas_pipstart},$cfg->{snas_vipstart},$cfg->{snas_pnmaskstart},$cfg->{snas_vnmaskstart});   
    } else {
        $output = $prod->precheck_ip_range($cfg->{snas_pipstart},$cfg->{snas_vipstart},$cfg->{snas_pipprefix},$cfg->{snas_vipprefix});   
    }
    if ($output == 2) {
        Msg::log("public ip is out of range, install failed!");
        $edr->{$prod->{ip_error_key}} = 2;
        return 0;
    }
    if ($output == 3) {
        Msg::log("virtual ip is out of range, install failed!");
        $edr->{$prod->{ip_error_key}} = 3;
        return 0;
    }

    return 1;
}

sub handler_config_nicnames_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$cpic,$output);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $output = $prod->configure_nicnames($sys);
    if (!$output) {
        return 0;
    }
    return 1;
}

sub handler_postconfig_nicnames_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$cpic,$fname,$ifcfgdir,$ifcfgfile,$cmd,$scripts,$output);
    
    $ifcfgdir = $prod->{nwconfbkupdir};
    $ifcfgfile = "/etc/sysconfig/network-scripts/ifcfg-";
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $sys->mkdir($ifcfgdir);
    $cmd = '';

    for my $eth (@{$sys->{publicnics_all_old}}) {
        next if (($eth =~ /^pubeth\d+$/m) || ($eth =~ /^priveth\d+$/m));
        $fname = $ifcfgfile.$eth."*";
        $cmd .= "/bin/mv $fname $ifcfgdir\n";
    }
    for my $eth (@{$sys->{privenics}}) {
        next if (($eth =~ /^pubeth\d+$/m) || ($eth =~ /^priveth\d+$/m));
        $fname = $ifcfgfile.$eth."*";
        $cmd .= "/bin/mv $fname $ifcfgdir\n";
    }

$scripts = <<"_POST_CONFIG"; 
$cmd
_POST_CONFIG

    $output = $sys->cmd_script($scripts);
    return 1;
}

sub handler_config_hostname_sys {
    my ($prod,$sys) = @_;
    my $output;
    $output = $prod->configure_hostnames($sys);
    if (!$output) {
        return 0;
    }
    return 1;
}

sub handler_config_ip {
    my ($prod) = @_;
    my ($output,$sysi,$sys0,$system,@syslist);

    my $cfg = Obj::cfg();
    $output = $prod->configure_ip_nics();
    if (!$output) {
#TBD
#return 0;
    }

    if (Cfg::opt('addnode')) {
        $sysi = @{$cfg->{clustersystems}}[0];
        $sys0 = Obj::sys($sysi);
        $prod->addnode_write_config_files_sys($sys0);

        for my $sys(@{$cfg->{clustersystems}}[1..$#{$cfg->{clustersystems}}]) {
            $system = Obj::sys($sys);
            push(@syslist, $system);
        }
        push(@syslist, @{CPIC::get('systems')});
        $prod->copy_conf_to_othernodes($sys0,\@syslist);
    } else {
        for my $sys(@{CPIC::get('systems')}) {
            $prod->write_config_files_sys($sys);
        }
    }
    return 1;
}

sub handler_config_dns_sys {
    my ($prod, $sys) = @_;
    my ($padv,$cfg,$cpic,$output,$padv);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $padv=$sys->padv;
    $output = $padv->configure_dns_sys($sys,$cfg->{snas_dnsip},$cfg->{snas_dnsdomainname});
    if (!$output) {
        Msg::log("configure dns error");
#TBD
#return 0;
    }
    return 1;
}

sub handler_users_groups_sys {
    my ($prod,$sys) =@_;
    my ($output);
    $output = $prod->add_users_sys($sys);
    if ($output) {
        #TBD;
    }
    $output = $prod->add_groups_sys($sys);
    if ($output) {
        #TBD;
    }
    return 1;
}

sub post_handler_check_nics {
    my $prod = shift;
    my ($cpic,$edr,$cfg,$rtn,$msg);
    $cpic = Obj::cpic();
    $cfg = Obj::cfg();
    for my $sys (@{$cpic->{systems}}) {
        if ($sys->{$prod->{fatal_error_key}}) { 
            $edr->{$prod->{fatal_error_key}} = 1;
        }
    }
    # NIC number should be the same in all nodes in the cluster
#    $rtn = $prod->nicnum_consistency_check();
#    if ($rtn) {
#        $msg = Msg::new("Make sure the cluster nodes have the same public and private NIC");
#        $msg->error();
#    }

    return 0 if($edr->{$prod->{fatal_error_key}});
    return 1;
}

sub preconfig_precheck {
    my $prod = shift;
    my ($cpic, $sys,$msg,$flag,$nicall,$padv,$output);
    $cpic = Obj::cpic();

    $flag=0;
    for $sys (@{$cpic->{systems}}) {
        return 2 if (!$sys->exists($prod->{nicconf}->{udevconffile}));
        if ($prod->precheck_nicname($sys)) {
            $flag=1;
            last;
        }
    }

    if ($flag) {
        Msg::log("NIC is already renamed, skipping nic and host rename");
        return 0;
    }

    for $sys (@{$cpic->{systems}}) {
        $padv=$sys->padv;
        $nicall=$padv->get_all_nic_sys($sys);
        for my $nic (@{$nicall}) {     
            $output = $padv->is_bonded_nic_sys($sys,$nic);
            if ($output) {
                Msg::log("$nic on $sys->{sys} is bonded already, skipping nic and host rename");
                return 3;
            }
        }
    }

    return 1;
}

sub precheck_nicname {
    my ($prod, $sys) = @_;
    my ($padv, $edr, $ethall);
    $padv=$sys->padv;
    $edr=Obj::edr();

    $ethall=$padv->get_all_nic_sys($sys);
    for my $eth (@{$ethall}) {
       if (($eth =~ /^pubeth\d+$/m) || ($eth =~ /^priveth\d+$/m)) {
           return 1;
       }
    }
    return 0;
}

sub cli_ask_start_value {
    my $prod = shift;
    my ($ayn,$padv,$cfg,$done,$msg,$msg_str,$help,$backopt,$netm,$mcnic_ref,$prefix,$vcs,$vip,$snas,$pipstart,$pnmaskstart,$vipstart,$vnmaskstart,$clustername,$def_gateway,$dnsip,$dnsdomainname,$pciexclusionid,$consoleip,$output,$hintpnmask,$hintvnmask,$rpn,$defnic,$nicl,$output,$nvips,$sepconsoleport,$pipprefix,$ntpserver);
    $cfg = Obj::cfg();
    $backopt = '';

    my $cpic = Obj::cpic();
    my $sys = @{$cpic->{systems}}[0];
    $padv=$sys->padv;
    $rpn = $padv->publicnics_sys($sys);
    if ($#$rpn<0) {
        $msg = Msg::new("No active NIC devices have been discovered on $sys->{sys}");
        $msg->warning();
    } else {
        $nicl = join(' ',@$rpn);
    }
    $defnic = $$rpn[0];

    if (Cfg::opt('responsefile')) {
        if (EDRu::ip_is_ipv6($cfg->{snas_pipstart})) {
            $prod->{netproto} = $prod->{netprotoipv6};
        } else {
            $prod->{netproto} = $prod->{netprotoipv4};
        }
        $cfg->{snas_ntpserver} = '' if(!defined $cfg->{snas_ntpserver});
        return 1;
    }

    Msg::title();
    $msg = Msg::new("The following data is required to configure the Storage NAS cluster:\n");
    $msg->bold;
    $msg = Msg::new("\tThe Storage NAS cluster name");
    $msg->printn;
    $msg = Msg::new("\tAn initial public IP address");
    $msg->printn;
    $msg = Msg::new("\tAn initial virtual IP address");
    $msg->printn;
    $msg = Msg::new("\tNetmask of public IPs and virtual IPs");
    $msg->printn;
    $msg = Msg::new("\tDefault gateway IP address");
    $msg->printn;
    $msg = Msg::new("\tDNS server IP address and domain name");
    $msg->printn;
    $msg = Msg::new("\tConsole virtual IP address");
    $msg->printn;
    $msg = Msg::new("System IP addresses will be defined sequentially starting with the initial address. System hostnames will be renamed as clustername_01, clustername_02, etc.");
    $msg->printn;

    do {
        $clustername = $prod->ask_clustername();
        $clustername = EDRu::despace($clustername);
        next if (EDR::getmsgkey($clustername,'back'));


        $pipstart = $prod->ask_pip_sys($sys);
        $pipstart = EDRu::despace($pipstart);
        next if (EDR::getmsgkey($pipstart,'back'));

        if (EDRu::ip_is_ipv6($pipstart)) {
            $prod->{netproto} = $prod->{netprotoipv6};
        } else {
            $prod->{netproto} = $prod->{netprotoipv4};
        }

        if ($prod->{netproto} eq $prod->{netprotoipv4}) {
            $hintpnmask = $sys->defaultnetmask($pipstart,$defnic);
            $pnmaskstart = $prod->ask_pnmask_sys($sys,$hintpnmask);
            $pnmaskstart = EDRu::despace($pnmaskstart);
            next if (EDR::getmsgkey($pnmaskstart,'back'));
        } else {
            $hintpnmask = $sys->defaultnetmask($pipstart,$defnic);
            $pipprefix = $prod->ask_pipprefix($hintpnmask);
            $pipprefix = EDRu::despace($pipprefix);
            next if (EDR::getmsgkey($pnmaskstart,'back'));
        }

        $vipstart = $prod->ask_vip_sys($sys);
        $vipstart = EDRu::despace($vipstart);
        next if (EDR::getmsgkey($vipstart,'back'));

        $nvips = $prod->ask_nvip(1);
        $nvips = EDRu::despace($nvips);
        next if (EDR::getmsgkey($nvips,'back'));

        $def_gateway = $prod->ask_default_gateway_sys($sys);
        $def_gateway = EDRu::despace($def_gateway);
        next if (EDR::getmsgkey($def_gateway,'back'));

        $dnsip = $prod->ask_dnsip_sys($sys);
        $dnsip = EDRu::despace($dnsip);
        next if (EDR::getmsgkey($dnsip,'back'));

        $dnsdomainname = $prod->ask_dnsdomainname_sys($sys);
        $dnsdomainname = EDRu::despace($dnsdomainname);
        next if (EDR::getmsgkey($dnsdomainname,'back'));

        $consoleip = $prod->ask_consoleip_sys($sys);
        $consoleip = EDRu::despace($consoleip);
        next if (EDR::getmsgkey($consoleip,'back'));

        $sepconsoleport = $prod->ask_sep_console_port();
        $sepconsoleport = EDRu::despace($sepconsoleport);
        next if (EDR::getmsgkey($sepconsoleport,'back'));

        $ntpserver = $prod->ask_ntpserver();
        $ntpserver = EDRu::despace($ntpserver);
        next if (EDR::getmsgkey($ntpserver,'back'));

        Msg::n();
        $msg = Msg::new("Is this information correct?");
        $ayn = $msg->ayny;
        $done = 1 if ($ayn eq 'Y');
    } while (!$done);

    $cfg->{snas_pipstart} = $pipstart;
    $cfg->{snas_pnmaskstart} = $pnmaskstart;
    $cfg->{snas_clustername} = $clustername;
    $cfg->{snas_vipstart} = $vipstart;
    $cfg->{snas_vnmaskstart} = $pnmaskstart;
    $cfg->{snas_defgateway} = $def_gateway;
    $cfg->{snas_dnsip} = $dnsip;
    $cfg->{snas_dnsdomainname} = $dnsdomainname;
    $cfg->{snas_consoleip} = $consoleip;
    $cfg->{snas_pciexclusionid} = $pciexclusionid;
    $cfg->{snas_nvip} = $nvips;
    $cfg->{snas_pipprefix} = $pipprefix;
    $cfg->{snas_sepconsoleport} = $sepconsoleport;
    $cfg->{snas_vipprefix} = $pipprefix;
    $cfg->{snas_ntpserver} = $ntpserver;

    return 1;
}

############################bond configuration started ###############

sub proc_nic_val {
    my ($prod) = @_;
    my ($cpic,$pciid,$padv,$sys,$output,$bondname,$bondmode,$msg,$sys0);
    $cpic=Obj::cpic();
    my $cfg = Obj::cfg();
    $cfg->{bondpool} = {};
    $cfg->{bondmode} = {};

    $cfg->{publicbond} = [];
    $cfg->{exclusion} = [];
    $cfg->{publicfree} = [];
    $cfg->{exclusion} = [];
    $cfg->{bondname} = [];

    for my $sys (@{$cpic->{systems}}) {
        my @allnics_pciid = ();
        my @unpingpciids_tmp_arr=();
        for my $eth (@{$sys->{allnics}})  {
            $pciid = $sys->padv->get_pciid_by_nicname_sys($sys,$eth); 
            push (@allnics_pciid,$pciid);
        }

        for my $eth (@{$sys->{unpingnics}}) {
            my $pciid = $sys->padv->get_pciid_by_nicname_sys($sys,$eth);
            push (@unpingpciids_tmp_arr, $pciid);
        }
        $sys->set_value('allnics_pciid','push', @allnics_pciid);
        $sys->set_value('unpingnics_pciid','push', @unpingpciids_tmp_arr);
    }

    for my $sys (@{$cpic->{systems}}) { 
        undef(@{$sys->{publicnic_all}});
        undef(@{$sys->{publicnic_rename}});
        undef(@{$sys->{publicnic_change_ip}});
    }

    for my $sys (@{$cpic->{systems}}) {
        my $i = 0;
        my @privenics_update_tmp_arr = ();
        my @allnics_pciid_sys_arr = ();
        for my $pciid (@{$sys->{unpingnics_pciid}}) {
            last if($i == $prod->{max_priv_nic_num});
            if (!EDRu::inarr($pciid, ($sys->{allnics_pciid}))) {
                my $eth = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
                push (@privenics_update_tmp_arr, $eth);
                @allnics_pciid_sys_arr = @{$sys->{allnics_pciid}};
                @allnics_pciid_sys_arr = @{EDRu::arrdel(\@allnics_pciid_sys_arr,$pciid)};
                undef(@{$sys->{allnics_pciid}});
                $sys->set_value("allnics_pciid",'push', @allnics_pciid_sys_arr);
                @allnics_pciid_sys_arr = ();
                $i++;
            }
        }


        if(@privenics_update_tmp_arr == 0) {
            $msg = Msg::new("The private NIC number does not meet the minimum requirement: $prod->{minimum_priv_nic_num}");
            $msg->error();
            return 2;
        }

        undef(@{$sys->{privenics}});
        $sys->set_value("privenics",'push',@privenics_update_tmp_arr);
    }

    for my $sys (@{$cpic->{systems}}) {
        my @publicnic_all = ();
        my @publicnic_rename= ();
        my @publicnic_change_ip= ();
        my @publicnic_bond= ();
        my @publicnic_bond_nic= ();
        my @publicnic_exclusion= ();

        for my $pciid (@{$sys->{allnics_pciid}}) {
            $output = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
            push (@publicnic_all, $output);
            push (@publicnic_rename, $output);
            push (@publicnic_change_ip, $output);
        }

        $sys->set_value('publicnic_all','push', @publicnic_all);
        $sys->set_value('publicnic_rename','push', @publicnic_rename);
        $sys->set_value('publicnic_change_ip','push', @publicnic_change_ip);
        $sys->set_value('publicnic_bond','push', @publicnic_bond);
        $sys->set_value('publicnic_bond_nic','push', @publicnic_bond_nic);
        $sys->set_value('publicnic_exclusion','push', @publicnic_exclusion);
    }

    #check the number of private/public nics on each system
    my ($private_nic_num, $public_nic_num, $private_nic_num_sys, $public_nic_num_sys);
    if (Cfg::opt('addnode')) {
        $sys0 = Obj::sys(@{$cfg->{clustersystems}}[0]);
        # nprivenics,npublicnics are specified in subroutine cluster_nic_status
        $private_nic_num = $sys0->{nprivenics};
        $public_nic_num = $sys0->{npublicnics};
    } else {
        $sys0 = ${$cpic->{systems}}[0];
        $private_nic_num = scalar(@{$sys0->{privenics}});
        $public_nic_num  = scalar(@{$sys0->{publicnic_all}});
    }

    for my $sys (@{$cpic->{systems}}) {
        next if($sys->system1 && !Cfg::opt('addnode'));
        $private_nic_num_sys = scalar(@{$sys->{privenics}});
        $public_nic_num_sys = scalar(@{$sys->{publicnic_all}});
        Msg::log("NIC num of system0 is: private($private_nic_num), public($public_nic_num), $sys->{sys} is: private($private_nic_num_sys), public($public_nic_num_sys)");
        if ($private_nic_num != $private_nic_num_sys || $public_nic_num != $public_nic_num_sys) {
            $msg = Msg::new("The number of public and private NICs is not consistent on $sys0->{sys} and $sys->{sys}.");
            $msg->error();
            return 2;
        }
    }
    return 1;
}

sub is_responsefile_for_bonding_or_exclusion {
    my ($prod) = @_;
    my $cfg = Obj::cfg();

    if (defined $cfg->{publicfree} || (defined $cfg->{bondname} && defined $cfg->{publicbond})) {
        return 1;
    }
    return 0;
}

sub init_bondpool_val {
    my ($prod) = @_;
    my ($cpic,$pciid,$padv,$sys,$sys0,$output,$bondname,$bondmode,$msg);
    my %bondpoolhash = ();
    my %bondmodehash = ();
    $cpic=Obj::cpic();
    my $cfg = Obj::cfg();

    for my $sys (@{$cpic->{systems}}) {
        my @allnics_pciid = ();
        my @unpingpciids_tmp_arr=();
        for my $eth (@{$sys->{allnics}})  {
            $pciid = $sys->padv->get_pciid_by_nicname_sys($sys,$eth); 
            push (@allnics_pciid,$pciid);
        }

        for my $eth (@{$sys->{unpingnics}}) {
            my $pciid = $sys->padv->get_pciid_by_nicname_sys($sys,$eth);
            push (@unpingpciids_tmp_arr, $pciid);
        }
        $sys->set_value('allnics_pciid','push', @allnics_pciid);
        $sys->set_value('unpingnics_pciid','push', @unpingpciids_tmp_arr);
    }


#check the consistence of pciiids

    my @allnics_base = ();
    my $allnics_base_str = '';

    if (Cfg::opt('addnode')) {
        my $sysi = @{$cfg->{clustersystems}}[0];
        $sys = Obj::sys($sysi);
        $padv=$sys->padv;

        my $ethall=$padv->get_all_nic_sys($sys);
        for my $eth (@{$ethall}) {
            $pciid = $sys->padv->get_pciid_by_nicname_sys($sys,$eth); 
            push (@allnics_base,$pciid);
        }

    } else {
        $sys = @{$cpic->{systems}}[0];
        @allnics_base = @{$sys->{allnics_pciid}};
    }

    @allnics_base = sort(@allnics_base);
    $allnics_base_str = join(' ',@allnics_base);

    Msg::log("$sys->{sys}:$allnics_base_str");

    for my $sys (@{$cpic->{systems}}) {
        next if ($sys->system1 && !Cfg::opt('addnode'));

        my @allnics_tmp = @{$sys->{allnics_pciid}};
        @allnics_tmp = sort(@allnics_tmp);
        my $allnics_tmp_str = join(' ',@allnics_tmp);
        Msg::log("$sys->{sys}:$allnics_tmp_str");
        if($allnics_base_str ne $allnics_tmp_str) {
            Msg::log("The PCI IDs on $sys->{sys} is not consistent with other systems");
        }
    }

    #here is the sample list of bond configuration
    $sys = ${$cpic->{systems}}[0];

    #display all the nics
    @{$prod->{local_allnics_pciid}} = @{$sys->{allnics_pciid}};
    @{$prod->{local_allnics}} = @{$sys->{allnics}};
    @{$prod->{local_unpingnics_pciid}} = @{$sys->{unpingnics_pciid}};


    for my $sys (@{$cpic->{systems}}) {
       my @publicall_pciid = ();
       for my $eth (@{$sys->{publicnics}})  {
            $pciid = $sys->padv->get_pciid_by_nicname_sys($sys,$eth); 
            push (@publicall_pciid,$pciid);
       }
       $sys->set_value('publicall_pciid','push', @publicall_pciid);
    }

    #here is the sample list of bond configuration
    $sys = @{$cpic->{systems}}[0];

    @{$prod->{local_publicall_pciid}} = @{$sys->{publicall_pciid}};
    @{$prod->{local_publicall}} = @{$sys->{publicnics}};

    @{$prod->{local_exclusion}} = ();
    @{$prod->{local_publicbond}} = ();
    @{$prod->{local_bond}} = ();
    @{$prod->{local_publicfree}} = ();
    @{$prod->{local_notconsistent_pciid}} = ();

    for my $sysi (@{$cpic->{systems}}) {
        next if ($sysi->system1());
        for my $pciid (@{$prod->{local_allnics_pciid}}) {
            my $eth = $sysi->padv->get_nicname_by_pciid_sys($sysi,$pciid);
            push (@{$prod->{local_notconsistent_pciid}},$pciid) if ($eth eq '');
        }
    }
    $prod->{local_notconsistent_pciid} = EDRu::arruniq(@{$prod->{local_notconsistent_pciid}});

    if (Cfg::opt('addnode')) {
        $sys0 = Obj::sys(@{$cfg->{clustersystems}}[0]);
        $output = $sys0->cmd("_cmd_cat $prod->{nicconf}->{exclusionfile} 2>/dev/null");
        @{$prod->{local_exclusion}} = split(/\s+/, $output) if($output);
        $output = $sys0->cmd("_cmd_cat $prod->{nicconf}->{bonddevfile} 2>/dev/null");
        my @pcilist;
        for my $line (split(/\n/, $output)) {
            ($bondname,$bondmode,@pcilist) = split(/\s+/, $line);
            push (@{$prod->{local_publicbond}},@pcilist);
            push (@{$prod->{local_bond}},$bondname);
            @{$cfg->{bondpool}{$bondname}} = @pcilist;
            $cfg->{bondmode}{$bondname} = $bondmode;
        }
        $prod->{local_publicfree} = EDRu::arrdel($prod->{local_publicall_pciid}, (@{$prod->{local_publicbond}}, @{$prod->{local_exclusion}}));
    } elsif(Cfg::opt('responsefile')) {
        if (defined $cfg->{exclusion}) {
        @{$prod->{local_exclusion}} = @{$cfg->{exclusion}} if (defined $cfg->{exclusion});
        } else {
            $prod->{local_exclusion} = [];
            $cfg->{exclusion} = [];
        }

        if (defined $cfg->{publicbond}) {
            @{$prod->{local_publicbond}} = @{$cfg->{publicbond}};
        } else {
            $prod->{local_publicbond} = [];
            $cfg->{publicbond} = []; 
        }

        if (defined $cfg->{bondname}){
            @{$prod->{local_bond}} = @{$cfg->{bondname}};
        } else {
            $prod->{local_bond} = [];
            $cfg->{bondname} = [];
        }

        $prod->{local_publicfree} = EDRu::arrdel($prod->{local_publicall_pciid}, (@{$prod->{local_publicbond}}, @{$prod->{local_exclusion}}));

    } else {
        @{$prod->{local_publicfree}} = @{$sys->{allnics_pciid}};
        @{$prod->{local_exclusion}} = ();
        @{$prod->{local_publicbond}} = ();
        @{$prod->{local_bond}} = ();
        $cfg->{bondpool} = {};
        $cfg->{bondmode} = {};
    }

    return 1;
}

sub pci_device_status_list {
    my ($prod) = @_;
    my ($output,@status,$index,$eth,$pciid,$msg);

    my @nicinfo_array = ();
    my @element = ("NIC","PCI ID","bond status","If excluded");

    for ($index = 0 ; $index < @{$prod->{local_allnics_pciid}}; $index++) {
        $eth = ${$prod->{local_allnics}}[$index];
        $pciid = ${$prod->{local_allnics_pciid}}[$index];
        $output = $prod->find_out_nic_status($pciid); 
        @status = split(/_/,$output);
        my %nicinfo;
        if ($status[0] eq "physic") {
            $nicinfo{"NIC"} = $eth;
            $nicinfo{"PCI ID"} = $pciid;
            $nicinfo{"bond status"} = "(physical NIC)";
            $nicinfo{"If excluded"} = "N";
            push(@nicinfo_array,\%nicinfo);
            next;
        }
        if ($status[0] eq "bond") {
            $nicinfo{"NIC"} = $eth;
            $nicinfo{"PCI ID"} = $pciid;
            $nicinfo{"bond status"} = "(Slave of $status[1])";
            $nicinfo{"If excluded"} = "N";
            push(@nicinfo_array,\%nicinfo);
            next;
        }
        if ($status[0] eq "exclude") {
            $nicinfo{"NIC"} = $eth;
            $nicinfo{"PCI ID"} = $pciid;
            $nicinfo{"bond status"} = "(physical NIC)";
            $nicinfo{"If excluded"} = "Y";
            push(@nicinfo_array,\%nicinfo);
            next;
        }
    }

    Msg::table(\@nicinfo_array,\@element);
    Msg::n();
    return 1;
}

sub pci_device_menu_list {
    my ($prod,$option) = @_;
    my (@menucontent,$output,@status,$menuopt,$menu,$index,$eth,$pciid,$msg);
    @menucontent = ();

    for ($index = 0 ; $index < @{$prod->{local_allnics_pciid}}; $index++) {
        $eth = @{$prod->{local_allnics}}[$index];
        $pciid = @{$prod->{local_allnics_pciid}}[$index];
        $output = $prod->find_out_nic_status($pciid); 
        @status = split(/_/,$output);
        if ($status[0] eq "physic" && $option eq "nonexclude") {
            push (@menucontent,"$eth $pciid (physical NIC)");
            next;
        }
        if ($status[0] eq "bond" && ($option eq "bond" || $option eq "nonexclude")) {
            push (@menucontent,"$eth $pciid (Slave of $status[1])");
            next;
        }
        if ($status[0] eq "exclude" && $option eq "exclude") {
            push (@menucontent,"$eth $pciid (excluded NIC)");
            next;
        }
    }

    for ($index = 0 ; $index < @menucontent; $index++ ){
         my $msg_opt = Msg::new($menucontent[$index]);
         push (@{$menuopt},$msg_opt->{msg});
    }

    $msg = Msg::new("Choose a NIC:");
    $output = $msg->menu($menuopt,'','',1);
    return $output if (EDR::getmsgkey($output,'back'));
    my @res_arr = split(/ /,$menucontent[$output-1]);
    return $res_arr[1];
}

sub pub_pci_device_menu_list {
    my ($prod) = @_;
    my (@menucontent,$output,@status,$menuopt,$menu,$index,$eth,$pciid,$msg,$help,$sys0);
    @menucontent = ();

    $sys0 = ${CPIC::get('systems')}[0];
    my @pub_pci_device_arr = ();
    my @pub_pci_device_pciid_arr = @{$prod->{local_allnics_pciid}};

    for my $pciid ((@{$prod->{local_unpingnics_pciid}},@{$prod->{local_exclusion}},@{$prod->{local_publicbond}},@{$prod->{local_notconsistent_pciid}})){
        @pub_pci_device_pciid_arr = @{EDRu::arrdel(\@pub_pci_device_pciid_arr,$pciid)};
    }

    if(@pub_pci_device_pciid_arr == 0) {
        return '';
    }

    for my $pciid (@pub_pci_device_pciid_arr) {
        my $eth = $sys0->padv->get_nicname_by_pciid_sys($sys0,$pciid);
        push (@pub_pci_device_arr,$eth);
    }

    for ($index = 0 ; $index < @pub_pci_device_pciid_arr; $index++) {
        $eth = @pub_pci_device_arr[$index];
        $pciid = @pub_pci_device_pciid_arr[$index];
        $output = $prod->find_out_nic_status($pciid); 
        @status = split(/_/,$output);
        if ($status[0] eq "physic") {
            push (@menucontent,"$eth $pciid (physical NIC)");
            next;
        }
        if ($status[0] eq "bond") {
            push (@menucontent,"$eth $pciid (Slave of $status[1])");
            next;
        }
        if ($status[0] eq "exclude") {
            push (@menucontent,"$eth $pciid (excluded NIC)");
            next;
        }
    }

    for ($index = 0 ; $index < @menucontent; $index++ ){
         my $msg_opt = Msg::new($menucontent[$index]);
         push (@{$menuopt},$msg_opt->{msg});
    }

    $msg = Msg::new("Choose a NIC:");
    $help = Msg::new("The NICs which have been bonded, excluded or those not having consistent PCI ids on other nodes are not displayed.");
    $output = $msg->menu($menuopt,'',$help,1);
    return $output if (EDR::getmsgkey($output,'back'));
    return $pub_pci_device_pciid_arr[$output-1];
}

sub bond_menu_list {
    my ($prod) = @_;
    my (@menucontent,$index,$menuopt,$output,$msg);
    @menucontent=();

    @menucontent = @{$prod->{local_bond}};
    @menucontent = sort (@menucontent);

    for ($index = 0 ; $index < @menucontent; $index++) {
        my $msg_opt = Msg::new($menucontent[$index]);
        push (@{$menuopt},$msg_opt->{msg});
    }
    $msg = Msg::new("Choose a bond:");
    $output =  $msg->menu($menuopt,'','',1);
    return $output if (EDR::getmsgkey($output,'back'));
    return $menucontent[$output -1];

}

sub cli_ask_pci_display {
    my ($prod) = @_;
    my ($cfg,$sys,@pci_device_list,$menuopt,$menu,$msg,$msg_add_new,$msg_add_to,$msg_removebond,$msg_removenic,$msg_exclude,$msg_include,$msg_next);
    my ($bondname,$bondmode,$output,$pciid,$option);

    return 1 if (Cfg::opt('responsefile')); 
    $output = $prod->init_bondpool_val();
    if ($output == 2) {
        return 2;
    }

    $msg_exclude = Msg::new("Exclude a NIC");
    $msg_include = Msg::new("Include a NIC");
    $msg_add_new = Msg::new("Create a new bond");
    $msg_add_to = Msg::new("Add a NIC to a bond");
    $msg_removebond = Msg::new("Remove a bond");
    $msg_removenic = Msg::new("Remove a NIC from the bond list");
    $msg_next = Msg::new("Save and continue");
    push (@{$menuopt},$msg_exclude->{msg},$msg_include->{msg},$msg_add_new->{msg},$msg_add_to->{msg},$msg_removebond->{msg},$msg_removenic->{msg},$msg_next->{msg});

    while(1) {

        Msg::title();
        $msg=Msg::new("NIC bonding/NIC exclusion configuration");
        $msg->bold;
        Msg::n();

        $msg=Msg::new("NIC bonding supports only public NICs. Make sure the NICs you choose are connected to public network.");
        $msg->printn;
        $prod->pci_device_status_list();

        $msg=Msg::new("Select the NIC option to be configured in this cluster:");
        $menu=$msg->menu($menuopt,'','','');

            #exclusion
            if ($menu == 1){
                my $freenic_num = @{$prod->{local_publicfree}};
                my $bondnic_num = @{$prod->{local_publicbond}};
                next if (($freenic_num + $bondnic_num) == 1);

                $msg = Msg::new("Choose a NIC for exclusion");
                $msg->printn;
                $option  = "nonexclude";
                $pciid = $prod->pci_device_menu_list($option);
                next if (EDR::getmsgkey($pciid,'back'));
                $output = $prod->move_nic_to_exclusion($pciid);
                next;
            }

            #$inclusion
            elsif ($menu == 2) {
                my $excludenic_num = @{$prod->{local_exclusion}};
                next if($excludenic_num == 0);
                $msg = Msg::new("Choose a NIC for inclusion");
                $msg->printn;
                $option = "exclude";
                $pciid = $prod->pci_device_menu_list($option);
                next if (EDR::getmsgkey($pciid,'back'));
                $output = $prod->move_to_inclusion($pciid);
                next;
            }

            #add new
            elsif ($menu == 3) {
                $bondname = $prod->get_bond_name();
                if ($bondname eq '') {
                    $msg = Msg::new("The creation of $bondname failed.");
                    $msg->printn;
                    Msg::prtc();
                }

                Msg::n();
                $msg = Msg::new("Configure the mode of the NIC bonding:");
                $msg->printn;
                $bondmode = $prod->ask_bond_mode();
                next if (EDR::getmsgkey($bondmode,'back'));
                $output = $prod->bond_add_new($bondname, $bondmode);
                if ($output ne '') {
                    $msg = Msg::new("$output is created.");
                    $msg->printn;
                    Msg::prtc();
                } else {
                    $msg = Msg::new("The creation of $bondname failed.");
                    $msg->printn;
                    Msg::prtc();
                }
                next;
            }

            #add to
            elsif ($menu == 4){
                $output = $prod->invalid_existing_bond();
                if ($output == 0) {
                    $msg = Msg::new("No NIC bonding exists.");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

                $msg = Msg::new("Choose a NIC for bonding");
                $msg->printn;
                $pciid = $prod->pub_pci_device_menu_list();
                next if (EDR::getmsgkey($pciid,'back'));
                if ($pciid eq '') {
                    $msg = Msg::new("All the public NICs are already in use");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

                $output = $prod->is_nic_bonded($pciid);
                if ($output) {
                    $msg = Msg::new("$pciid cannot be added to $bondname");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

                $msg = Msg::new("Choose a bond name to add NICs");
                $msg->printn;
                $bondname = $prod->bond_menu_list();
                next if (EDR::getmsgkey($bondname,'back'));

                $output = $prod->bond_add_nic_to($bondname,$pciid);
                if ($output == 0) {
                    $msg = Msg::new("Adding NIC $pciid to $bondname failed");
                    $msg->printn;
                    Msg::prtc();
                } else {
                    $msg = Msg::new("Adding $pciid to $bondname was successful");
                    $msg->printn;
                    Msg::prtc();
                }

                next;
            }

            #remove bond
            elsif ($menu == 5){
                $output = $prod->invalid_existing_bond();
                if ($output == 0) {
                    $msg = Msg::new("No valid NIC bonding exists");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

                $msg = Msg::new("Choose a bond to be removed");
                $msg->printn;
                $bondname = $prod->bond_menu_list();
                next if (EDR::getmsgkey($bondname,'back'));

                $output = $prod->delete_bond($bondname);
                if ($output) {
                    $msg = Msg::new("Deleting NIC bonding $bondname succeeded");
                    $msg->printn;
                    Msg::prtc();
                } else {
                    $msg = Msg::new("Deleting NIC bonding $bondname failed");
                    $msg->printn;
                    Msg::prtc();
                }

                next;
            }
            
            #remove nic
            elsif ($menu == 6){
                $output = $prod->invalid_existing_bond();
                if ($output == 0) {
                    $msg = Msg::new("No valid NIC bonding exists");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

                my $bondnic_num = @{$prod->{local_publicbond}};
                next if($bondnic_num == 0);

                $msg = Msg::new("Choose a NIC to be deleted from the NIC bonding");
                $msg->printn;
                $option = "bond";
                $pciid = $prod->pci_device_menu_list($option);
                next if (EDR::getmsgkey($pciid,'back'));

                $output = $prod->bond_identify($pciid);
                if ($output eq '') {
                    $msg = Msg::new("The NIC with the PCI id $pciid is not bonded yet");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

                $output = $prod->bond_remove_nic($pciid);
                if ($output) {
                    $msg = Msg::new("The NIC with the PCI id $pciid has been removed from the NIC bonding");
                    $msg->printn;
                    Msg::prtc();
                    next;
                } else {
                    $msg = Msg::new("Failed to remove the NIC with PCI id $pciid from the NIC bonding");
                    $msg->printn;
                    Msg::prtc();
                    next;
                }

            }

            elsif ($menu == 7){
                #display bond check list            
                $output = $prod->filter_bondpool();
                $output = $prod->bond_adapter_post();
                if ($output == 2) {
                    next;
                } else {
                    last;
                }
            }

            else {
                $output = $prod->bond_adapter_post();
                if ($output == 2) {
                    next;
                } else {
                    last;
                }

            }
    }
    return 1;
}

sub bond_add_new {
    my ($prod,$bondname,$bondmode) = @_;

    my $cfg = Obj::cfg();
    my @newbond = ();
    if (exists $cfg->{bondpool}{$bondname}) {
        return '';
    }
    @{$cfg->{bondpool}{$bondname}} = @newbond;
    $cfg->{bondmode}{$bondname} = $bondmode;
    push(@{$prod->{local_bond}},$bondname);
    return $bondname;
}

sub is_nic_bonded{
    my ($prod,$pciid) = @_;

    return 1 if(EDRu::inarr($pciid, @{$prod->{local_publicbond}}) || EDRu::inarr($pciid,@{$prod->{local_exclusion}}));
    return 0;
}

sub bond_add_nic_to {
    my ($prod,$bondname,$pciid) = @_;
    my $cfg = Obj::cfg();

    return 0 if (!defined $cfg->{bondpool}{$bondname});

    push (@{$cfg->{bondpool}{$bondname}},$pciid);

    $prod->{local_publicfree} = EDRu::arrdel($prod->{local_publicfree},$pciid);
    push (@{$prod->{local_publicbond}},$pciid);
    @{$prod->{local_publicfree}} = sort (@{$prod->{local_publicfree}});
    @{$prod->{local_publicbond}} = sort (@{$prod->{local_publicbond}});

    return 1;
}

sub bond_remove_nic {
    my ($prod,$pciid) = @_;

    my $cfg = Obj::cfg();

    foreach my $key(sort (keys %{$cfg->{bondpool}})) {
        $cfg->{bondpool}{$key} = EDRu::arrdel($cfg->{bondpool}{$key},$pciid);
    }

    $prod->{local_publicbond} = EDRu::arrdel($prod->{local_publicbond},$pciid);
    push (@{$prod->{local_publicfree}},$pciid);
    @{$prod->{local_publicfree}} = sort (@{$prod->{local_publicfree}});
    @{$prod->{local_publicbond}} = sort (@{$prod->{local_publicbond}});

    return 1;
}


sub delete_bond {
    my ($prod,$bondname) = @_;
    my $cfg = Obj::cfg();

    push (@{$prod->{local_publicfree}},@{$cfg->{bondpool}{$bondname}});

    for my $pciid (@{$cfg->{bondpool}{$bondname}}) {
        $prod->{local_publicbond} = EDRu::arrdel($prod->{local_publicbond},$pciid);
    }

    delete $cfg->{bondpool}{$bondname}; 
    $prod->{local_bond} = EDRu::arrdel($prod->{local_bond},$bondname);

    @{$prod->{local_publicfree}} = sort (@{$prod->{local_publicfree}});
    @{$prod->{local_publicbond}} = sort (@{$prod->{local_publicbond}});
    @{$prod->{local_bond}} = sort (@{$prod->{local_bond}});

    return 1;
}


sub bond_identify {
    my ($prod,$pciid) = @_;
    my $cfg=Obj::cfg();

    foreach my $key(sort (keys %{$cfg->{bondpool}})) {
        return $key if (EDRu::inarr($pciid, @{$cfg->{bondpool}{$key}}));
    }
    return '';
}

sub find_out_nic_status {
    my ($prod, $pciid) = @_;
    my $bondname = $prod->bond_identify($pciid);
    return "bond_$bondname" if ($bondname ne '');
    return "exclude_$pciid" if(EDRu::inarr($pciid,@{$prod->{local_exclusion}}));
    return "physic_$pciid" if(EDRu::inarr($pciid,@{$prod->{local_publicfree}}));
}

sub invalid_existing_bond {
    my ($prod) = @_;
    my $flag = 0;

    return 1 if (@{$prod->{local_bond}} != 0);
    return 0;
}

sub move_nic_to_exclusion {
    my ($prod,$pciid) = @_;

    $prod->bond_remove_nic($pciid);
    $prod->{local_publicfree} = EDRu::arrdel($prod->{local_publicfree},$pciid);
    push(@{$prod->{local_exclusion}},$pciid);
    @{$prod->{local_publicfree}} = sort (@{$prod->{local_publicfree}});
    @{$prod->{local_exclusion}} = sort (@{$prod->{local_exclusion}});
    return 1;
}

sub move_to_inclusion {
    my ($prod,$pciid) = @_;

    $prod->{local_exclusion} = EDRu::arrdel($prod->{local_exclusion},$pciid);
    push(@{$prod->{local_publicfree}},$pciid);
    @{$prod->{local_publicfree}} = sort (@{$prod->{local_publicfree}});
    @{$prod->{local_exclusion}} = sort (@{$prod->{local_exclusion}});
    return 1;
}

sub ask_bond_mode {
    my ($prod)=@_;
    my ($msg_0,$msg_1,$msg_2,$msg_3,$msg_4,$msg_5,$msg_6,$answer,$backopt,$done,$msg,$help,$menuopt,$menu);

    $msg_0 = Msg::new("balance-rr");
    $msg_1 = Msg::new("active-backup");
    $msg_2 = Msg::new("balance-xor");
    $msg_3 = Msg::new("broadcast");
    $msg_4 = Msg::new("802.3ad");
    $msg_5 = Msg::new("balance-tlb");
    $msg_6 = Msg::new("balance-alb");

    push (@{$menuopt},$msg_0->{msg},$msg_1->{msg},$msg_2->{msg},$msg_3->{msg},$msg_4->{msg},$msg_5->{msg},$msg_6->{msg});

    $msg=Msg::new("Select the bonding mode:");
    $menu=$msg->menu($menuopt,'','',1);     
    return $menu if (EDR::getmsgkey($menu,'back'));

    return $menu-1;
}

sub filter_bondpool {
    my ($prod) = @_;
    my $cfg = Obj::cfg();
    my %bondpool_tmp_hash=();
    my %bondmode_tmp_hash=();
    foreach my $key (sort (keys %{$cfg->{bondpool}})) {
        if (@{$cfg->{bondpool}{$key}} != 0) {
            $bondpool_tmp_hash{$key} = $cfg->{bondpool}{$key};
            $bondmode_tmp_hash{$key} = $cfg->{bondmode}{$key};
        }
        delete $cfg->{bondpool}{$key};
        delete $cfg->{bondmode}{$key};
    }

    my $num=0;
    @{$prod->{local_bond}} = ();
    foreach my $key (sort (keys %bondpool_tmp_hash)) {
        my $keyname = 'bond'.$num;
        $cfg->{bondpool}{$keyname} = $bondpool_tmp_hash{$key};
        $cfg->{bondmode}{$keyname} = $bondmode_tmp_hash{$key};
        push (@{$prod->{local_bond}},$keyname);
        $num++;
    }   

    return '';
}

sub bond_adapter_post {
    my ($prod) = @_;
    
    my (%bondpoolhash,%bondmodehash,$output,$padv,$msg,$pubnics);


    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) { 
        undef(@{$sys->{publicnic_all}});
        undef(@{$sys->{publicnic_rename}});
        undef(@{$sys->{publicnic_change_ip}});
        undef(@{$sys->{publicnic_bond}});
        undef(@{$sys->{publicnic_bond_nic}});
        undef(@{$sys->{publicnic_exclusion}});
    }

    my @local_publicfree_tmp_arr = @{$prod->{local_publicfree}};
    for my $sys (@{$cpic->{systems}}) {
        my $i = 0;
        my @privenics_update_tmp_arr = ();
        my @privenics_update_pciid_tmp_arr = ();
        for my $pciid (@{$sys->{unpingnics_pciid}}) {
            last if($i == $prod->{max_priv_nic_num});
            if (!EDRu::inarr($pciid, (@{$prod->{local_exclusion}},@{$prod->{local_publicbond}}))) {
                push (@privenics_update_pciid_tmp_arr,$pciid);
                my $eth = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
                push (@privenics_update_tmp_arr, $eth);
                $prod->{local_publicfree} = EDRu::arrdel($prod->{local_publicfree},$pciid);
                $i++;
            }
        }

        if(@privenics_update_tmp_arr == 0) {
            @{$prod->{local_publicfree}} = @local_publicfree_tmp_arr;
            $msg = Msg::new("The private NIC number does not meet the minimum requirement: $prod->{minimum_priv_nic_num}");
            $msg->printn;
            Msg::prtc();
            return 2;
        }

        undef @{$sys->{privenics}};
        undef @{$sys->{privenics_pciid}};
        $sys->set_value('privenics','push',@privenics_update_tmp_arr);
        $sys->set_value('privenics_pciid','push', @privenics_update_pciid_tmp_arr);
    }

    $pubnics = scalar(@{$prod->{local_publicfree}}) + scalar(@{$prod->{local_publicbond}});
    $pubnics-- if ($cfg->{snas_sepconsoleport});
    if($pubnics < $prod->{minimum_pub_nic_num}) {
        @{$prod->{local_publicfree}} = @local_publicfree_tmp_arr;
        if ($cfg->{snas_sepconsoleport}) {
            $msg = Msg::new("Separate console port uses one public NIC exclusively");
            $msg->print();
        }
        $msg = Msg::new("The public NIC number does not meet the minimum requirement: $prod->{minimum_pub_nic_num}");
        $msg->printn;
        Msg::prtc();
        return 2;
    }

    for my $sys (@{$cpic->{systems}}) {
        my @publicnic_rename= ();
        my @publicnic_change_ip= ();
        my @publicnic_bond= ();
        my @publicnic_bond_nic= ();
        my @publicnic_exclusion= ();

        my @local_privenics_pciid = @{$sys->{privenics_pciid}};
        my @local_unpingnics_pciid = @{$sys->{unpingnics_pciid}};
        my @local_publicbond = @{$prod->{local_publicbond}};
        my @local_publicfree = @{EDRu::arrdel($sys->{allnics_pciid},(@local_publicbond,@{$prod->{local_exclusion}},@local_privenics_pciid))};

        for my $pciid (@local_publicfree,@{$prod->{local_publicbond}})
        {
            $output = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
            if ($output eq '') {
                @{$prod->{local_publicfree}} = @local_publicfree_tmp_arr;
                $msg = Msg::new("Cannot find the NIC with PCI id of $pciid on $sys->{sys}.");
                $msg->printn;
                Msg::prtc();
                return 2;
            }

            push (@publicnic_rename, $output);
        }

        if($sys->system1()) {
            $prod->set_value('npublicfree',scalar(@local_publicfree));
        } else {
            my $npublicfree_tmp = scalar(@local_publicfree);
            if ($npublicfree_tmp != $prod->{npublicfree}){
                my $sys0 = @{$cpic->{systems}}[0];
                @{$prod->{local_publicfree}} = @local_publicfree_tmp_arr;
                $msg = Msg::new("The number of public NICs is not consistent on $sys0->{sys} and $sys->{sys}.");
                $msg->printn;
                Msg::prtc();
                return 2;
            }
        }

        for my $pciid (@local_publicfree)
        {
            $output = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
            push (@publicnic_change_ip, $output);
        }

        for my $pciid (@local_publicbond)
        {
            $output = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
            push (@publicnic_bond, $output);
        }

        foreach my $key(sort (keys %{$cfg->{bondpool}})) {
            if (@{$cfg->{bondpool}{$key}} == 0) {
               delete $cfg->{bondpool}{$key}; 
               $prod->{local_bond} = EDRu::arrdel($prod->{local_bond},$key);
            }
        }

        @publicnic_bond_nic = @{$prod->{local_bond}};

        for my $pciid (@{$prod->{local_exclusion}})
        {
            $output = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
            push (@publicnic_exclusion, $output) if ($output ne '');
        }

        $sys->set_value('publicnic_all','push', @publicnic_rename);
        $sys->set_value('publicnic_rename','push', @publicnic_rename);
        $sys->set_value('publicnic_change_ip','push', @publicnic_change_ip);
        $sys->set_value('publicnic_bond','push', @publicnic_bond);
        $sys->set_value('publicnic_bond_nic','push', @publicnic_bond_nic);
        $sys->set_value('publicnic_exclusion','push', @publicnic_exclusion);
    }

#all public nics $prod->{publicnic_all}
#need to rename $prod->{publicnic_rename}
#need to assign ip $prod->{publicnic_change_ip}
#bond nics $prod->{publicnic_bond}
#bond name $prod->{publicnic_bond_nic}
#exclusion $prod->{publicnic_exclusion}

#for BAIT

    if (Cfg::opt('addnode') || !Cfg::opt('responsefile')){
        @{$cfg->{publicbond}} = @{$prod->{local_publicbond}};
        @{$cfg->{exclusion}} = @{$prod->{local_exclusion}};
        @{$cfg->{bondname}} = @{$prod->{local_bond}};
    }

    delete $prod->{local_publicall};
    delete $prod->{local_publicfree};
    delete $prod->{local_publicbond};
    delete $prod->{local_bond};
    delete $prod->{local_exclusion};

    return 1;
}

sub get_nicname_new_by_nicname_sys {
    my ($prod,$sys,$nicname) = @_;
    my ($index);
    my @pubethsold =  @{$sys->{publicnics_all_old}};
    my @pubethsnew =  @{$sys->{publicnics_all_new}};
    for ($index = 0 ; $index < @pubethsold; $index++) {
        return $pubethsnew[$index] if ($pubethsold[$index] eq $nicname);
    }
    return '';
}

############################bond configuration finished###############

sub display_info {
    my ($prod) = @_;
    my ($output) ;

    $output = $prod->display_initial_value();
    if ($output) {
        Msg::log("display ip pool info success!");
        return 1;
    } else {
        Msg::log("display ip pool info failed!");
        return 0;
    }

}

sub display_initial_value {
    my ($prod) = @_;
    my (@titles,$cfg,$cpic,@pip,@vip,@nmask,@vnmask,@pubeths_new,@pubeths_old,@priveths,@priveths_new,$index,$msg,$oldhostname,$newhostname,$hostnameid,$id,$nicid,$ayn,$done,$i,$pid,$vid);
    my ($nicname,$nicname_new,$flag,$flag_bond,$content);

    return 1 if (Cfg::opt('responsefile')); 

    $cfg = Obj::cfg();
    $cpic = Obj::cpic();

    $hostnameid = 1;
    $flag = 0;
    $flag_bond = 0;
    $content = '';

    my @p1_arr = ();
    my @p2_arr = ();
    my @p3_arr = ();
    my @p4_arr = ();
    my @p5_arr = ();
    my @p6_arr = ();

    my @element_p1 = ("System","Hostname","New Hostname");
    my @element_p2 = ("System","Gateway IP","DNS IP","Domain name");
    my @element_p3 = ("System","NIC name(previous name)","Physical IP");
    my @element_p4 = ("System","NIC name(previous name)");
    my @element_p5 = ("System","bond name","Slave NICs(previous names)","Physical IP");
    my @element_p6 = ("Virtual IP");

    for my $sys (@{$cpic->{systems}}) {

        @pip = @{$sys->{publicip}};
        @vip = @{$sys->{privateip}};
        @nmask = @{$sys->{publicnetmask}};
        $nicid =0;
        $index=0;

        my %hash_p1=();
        my %hash_p2=();

        if ($hostnameid < 10) {
            $newhostname = $cfg->{snas_clustername}."_0".$hostnameid;
        } else {
            $newhostname = $cfg->{snas_clustername}."_".$hostnameid;
        }
        $hostnameid++;

        $hash_p1{"System"}= $sys->{sys};
        $hash_p1{"Hostname"}=$sys->{oldhostname};
        $hash_p1{"New Hostname"}=$newhostname;

        push(@p1_arr,\%hash_p1);

        $hash_p2{"System"}=$sys->{sys};
        $hash_p2{"Gateway IP"}=$cfg->{snas_defgateway};
        $hash_p2{"DNS IP"}=$cfg->{snas_dnsip};
        $hash_p2{"Domain name"}=$cfg->{snas_dnsdomainname};

        push(@p2_arr,\%hash_p2);

        $pid=0;
        @pubeths_new = @{$sys->{publicnics_new}};
        @pubeths_old = @{$sys->{publicnics_old}};

        if (@{$sys->{publicnics_new}} != 0) {
            $flag = 1;
            for ($i = 0 ; $i < @pubeths_new; $i++){

                my %hash_p3=();
                $hash_p3{"System"}= $sys->{sys};        
                $hash_p3{"NIC name(previous name)"}="$pubeths_new[$i]($pubeths_old[$i])";
                $hash_p3{"Physical IP"}=$pip[$index];
                push(@p3_arr,\%hash_p3);
                $pid++;
                $index++;
            }
        }

        $vid=0;
        @priveths = @{$sys->{privenics}};
        @priveths_new = @{$sys->{privenics_new}};
        for my $eth (@priveths) {
            my %hash_p4=();
            $hash_p4{"System"} = $sys->{sys}; 
            $hash_p4{"NIC name(previous name)"}="$priveths_new[$vid]($eth)";
            $vid++;
            push(@p4_arr,\%hash_p4);
        }


        if (%{$cfg->{bondpool}}) {
            $flag_bond=1;
            foreach my $key(sort (keys %{$cfg->{bondpool}})) {

                my %hash_p5=();
                $hash_p5{"System"}= $sys->{sys}; 
                $hash_p5{"bond name"}=$key;
                $hash_p5{"Physical IP"} = $pip[$index];

                my @nic_name_arr = ();
                for my $pciid (@{$cfg->{bondpool}{$key}}){
                    $nicname = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
                    $nicname_new = $prod->get_nicname_new_by_nicname_sys($sys,$nicname);

                    push(@nic_name_arr,"$nicname_new($nicname)");

                }

                $hash_p5{"Slave NICs(previous names)"}=join(', ',@nic_name_arr);

                push(@p5_arr,\%hash_p5);
                $index++;
            }
        }
    }

    $index = 0;
    for my $vip (@{$cfg->{virtualiparr}}) {
        last if ($index == $prod->{vip_display_maximum});
        $content .= "$vip ";
        $index++;
    }

    if(scalar(@{$cfg->{virtualiparr}}) > $prod->{vip_display_maximum}) {
        my $vipnum = scalar(@{$cfg->{virtualiparr}});
        $content .= "...($vipnum in total)"
    }

    my %hash_p6 = ();
    $hash_p6{"Virtual IP"} = $content;
    push(@p6_arr,\%hash_p6);

    Msg::title();
    $msg = Msg::new("Configuration Checklist:");
    $msg->bold;
    Msg::n();

    Msg::table(\@p1_arr,\@element_p1);
    Msg::n();
    Msg::table(\@p2_arr,\@element_p2);
    Msg::n();

    if ($flag_bond) {
        Msg::table(\@p5_arr,\@element_p5);
        Msg::n();
    }

    if ($flag){
        Msg::table(\@p3_arr,\@element_p3);
        Msg::n();
    }

    Msg::table(\@p6_arr,\@element_p6);
    Msg::n();

    Msg::table(\@p4_arr,\@element_p4);

    Msg::n();
    $msg = Msg::new("Is this information correct?");
    $ayn = $msg->ayny;
    return 1 if ($ayn eq 'Y');

    return 0;
}

sub precheck_ip_range {
    my ($prod,$pipstart,$vipstart,$pnmaskstart,$vnmaskstart) = @_;
    my ($cfg,$sys,$padv,$npublicnicall,$nprivatenicall,$output,$id,$inuse,$vipbit,$vipstartbit,$pipbit,$pipstartbit,@nip);
    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();
    $npublicnicall = 0;
    for $sys (@{$cpic->{systems}}) {
        $npublicnicall  += (@{$sys->{publicnic_bond_nic}} + @{$sys->{publicnic_change_ip}});
    }

    my $pip = $prod->get_next_ip($pipstart,0);
    my $vip = $prod->get_next_ip($vipstart,0);
    $sys = @{$cpic->{systems}}[0];
    $padv  = $sys->padv;
    $id = 0;
    $prod->truncate_ip_pool();
    for ($id = 0 ; $id < $npublicnicall;) {
        $output = $prod->check_ip_available($sys,$pip); 
        if (!$output) {
            Msg::log("$pip is invalid!");
            $pip = $prod->get_next_ip($pip,1);
        }
        else {
            $prod->set_ip_to_ppool($pip);
            $prod->set_nmask_to_ppool($pnmaskstart);
            $pip = $prod->get_next_ip($pip,1);
            $id++;
        }

        last if($id == $npublicnicall);

        if ($prod->{netproto} eq $prod->{netprotoipv4}) {
            @nip = split(/\./,$pip);
            if ($nip[3] >= 255) {
                Msg::log("$pip is invalid! Out of range!");
                return 2;
            }
        } else {
            $pipbit = EDRu::ipv6bit($pip,$pnmaskstart);
            $pipstartbit = EDRu::ipv6bit($pipstart,$pnmaskstart);
            if ($pipbit != $pipstartbit || $pipbit ==2 || $pipstartbit==2) {
                Msg::log("$pip is invalid! Out of range!");
                return 2;
            }
        }
    } 

    $npublicnicall -= scalar(@{$cpic->{systems}}) if ($cfg->{snas_sepconsoleport});
    for ($id = 0 ; $id < $npublicnicall*$cfg->{snas_nvip};) {
        $output = $prod->check_ip_available($sys,$vip); 
        if (!$output) {
            Msg::log("$vip is invalid!");
            $vip = $prod->get_next_ip($vip,1);
        }
        else {
            $inuse = $prod->dedup_vip($vip);
            if (!$inuse) {
                $prod->set_ip_to_vpool($vip);
                $prod->set_nmask_to_vpool($vnmaskstart);
                $vip = $prod->get_next_ip($vip,1);
                $id++;
            } else {
                Msg::log("$vip is inuse!");
                $vip = $prod->get_next_ip($vip,1);
            }
        }

        last if($id == $npublicnicall*$cfg->{snas_nvip});

        if ($prod->{netproto} eq $prod->{netprotoipv4}) {
            @nip = split(/\./,$vip);
            if ($nip[3] >= 255) {
                Msg::log("$vip is invalid! Out of range!");
                return 3;
            }
        } else {
            $vipbit = EDRu::ipv6bit($vip,$vnmaskstart);
            $vipstartbit = EDRu::ipv6bit($vipstart,$vnmaskstart);
            if ($vipbit != $vipstartbit || $vipbit ==2 || $vipstartbit==2) {
                Msg::log("$vip is invalid! Out of range!");
                return 3;
            }
        }
    }

    return 1;
}

sub get_hint_ip {
    my ($prod,$sys,$ip) = @_;
    my ($i,$hint,$output,$flag);
    my $padv=$sys->padv;
    $hint = $ip;
    $flag = 0;
    for ($i = 0; $i < 6; $i++) { 
        $hint = $prod->get_next_ip($hint,1);
        $output = $prod->check_ip_available($sys,$hint);
        if (!$output) { 
            $flag = 1;
            next;
        } else {
            $flag = 0;
            last;
        }
    }
    if ($flag == 0) {
        return $hint;
    } else {
        return "0.0.0.0";
    }
}

sub check_pciid_available {
    my ($prod, $pciidstr) = @_;
    my (@pciid,$output);
    @pciid = split(/\s+|[,;_]/,$pciidstr);
    for my $id (@pciid) {
       $output = $id =~ /^[\da-z]+:[\da-z]+:[\da-z]+\.[\da-z]+$/;
       return 0 if (!$output);
    }
    return 1;
}

sub check_ip_available {
    my ($prod,$sys,$ip) = @_;
    my ($localsys,$padv,$ret);
    $localsys=EDR::get('localsys');
    $ret = $localsys->padv->ping($ip);
    if ($ret eq 'noping') {
        return 1;
    }
    return 0;
}

sub dedup_vip {
    my ($prod, $vip) = @_;
    my ($cfg, $matchpip,$matchvip);
    $cfg= Obj::cfg();
    $matchpip = grep /^$vip/,@{$prod->{snas_ip_pool}->{public}};
    $matchvip = grep /^$vip/,@{$prod->{snas_ip_pool}->{private}};
    if ($matchpip || $matchvip) {
        return 1;
    }
    return 0;
}

sub buildup_config_info {
    my ($prod) = @_;
    my ($hostnameid,$cpic,$oldhostname,$cfg,$pubprefix,$privprefix,@conneths,$nconneths,@disconneths,$nconneths_new,$ndisconneths_new,$nconneths,$ndisconneths,$pubid,$privid,$pip,$pmask,$vip,$vmask,$i);
    my (@conneths_all_new,@conneths_all_old,@connect_priv_nics,@disconneths_sys1,$bond,$msg,$sys0);

    $cfg= Obj::cfg();
    $cpic = Obj::cpic();
    $hostnameid = 1;
    $sys0 = ${CPIC::get('systems')}[0];

    #for BAIT
    if (Cfg::opt('responsefile') && !Cfg::opt('addnode')) {
        @{$prod->{snas_ip_pool}->{public}} = @{$cfg->{publiciparr}};
        @{$prod->{snas_ip_pool}->{private}} = @{$cfg->{virtualiparr}};
        @{$prod->{snas_nmask_pool}->{public}} = @{$cfg->{publicnetmaskarr}};
        @{$prod->{snas_nmask_pool}->{private}} = @{$cfg->{virtualnetmaskarr}};
    } else {
        @{$cfg->{publiciparr}} = @{$prod->{snas_ip_pool}->{public}};
        @{$cfg->{virtualiparr}} = @{$prod->{snas_ip_pool}->{private}};
        @{$cfg->{publicnetmaskarr}} =  @{$prod->{snas_nmask_pool}->{public}};
        @{$cfg->{virtualnetmaskarr}} = @{$prod->{snas_nmask_pool}->{private}};
    }

    if (Cfg::opt('addnode')) {
        $prod->addnode_init_new_hostname();
    } else {
        for my $sys (@{$cpic->{systems}}) {
            $oldhostname = $sys->{oldhostname};
            if ($hostnameid < 10) {
                $sys->{newhostname} = $cfg->{snas_clustername}."_0".$hostnameid;
            } else {
                $sys->{newhostname} = $cfg->{snas_clustername}."_".$hostnameid;
            }
            $hostnameid++;
        }
    }

    $pubprefix = $prod->{pubnic_prefix};
    $privprefix = $prod->{privnic_prefix};
    $nconneths_new = 0;
    $ndisconneths_new = 0;

    # check the link connectivity and set private eths order properly.
    $prod->check_private_link_connections();
    @disconneths_sys1 = @{$sys0->{privenics}};

    for my $sys (@{$cpic->{systems}}) {
        my @conneths_new = ();
        my @conneths_old = ();
        my @disconneths_new = ();
        my @bond_nic_new = ();
        my @bond_nic_old = ();

        @conneths_all_old = ();
        @conneths_all_new = ();


        @conneths =  @{$sys->{publicnic_all}};
        @disconneths = @{$sys->{privenics}}; 

        $pubid = 0;
        for my $eth (@conneths) {

            next if (EDRu::inarr($eth,@{$sys->{publicnic_exclusion}}));
            if (EDRu::inarr($eth,@{$sys->{publicnic_bond}})) {
                push(@bond_nic_old,$eth);
                push(@bond_nic_new,$pubprefix.$pubid);
            } else {
                push(@conneths_old,$eth);
                push (@conneths_new,$pubprefix.$pubid);
            }
            push (@conneths_all_old,$eth);
            push (@conneths_all_new,$pubprefix.$pubid);
            $pubid++;
        }

        $privid = 0;
        for my $eth (@disconneths) {
            if ($sys->system1()) {
                push (@disconneths_new,$privprefix.$privid);
            } else {
                @connect_priv_nics = @{$sys->{connected_priv_nics}};
                # check if private link connected to each other 
                if (@connect_priv_nics) {
                    if (defined($connect_priv_nics[$privid])) {
                        push (@disconneths_new,$privprefix.$connect_priv_nics[$privid]);
                    } else {
                        $msg = Msg::new("Private NIC $disconneths_sys1[$privid] on $sys0->{sys} is not connected to any NIC on $sys->{sys}. Check the physical NIC connection before proceeding");
                        $msg->die();
                    }
                } else {
                    $msg = Msg::new("Failed to check the private link connectivity on $sys->{sys}. Check the physical NIC connection before proceeding");
                    $msg->die();
                }
            }

            $privid++;
        }

        $sys->set_value('publicnics_all_old','push', @conneths_all_old);
        $sys->set_value('publicnics_all_new','push', @conneths_all_new);
        $sys->set_value('publicnics_new','push', @conneths_new);
        $sys->set_value('publicnics_old','push', @conneths_old);
        $sys->set_value('privenics_new','push', @disconneths_new);
        $sys->set_value('bond_nic_new','push', @bond_nic_new);
        $sys->set_value('bond_nic_old','push', @bond_nic_old);
    }

    for my $sys (@{$cpic->{systems}}) {
        my @pubip_arr=();
        my @pubnmask_arr=();
        my @privip_arr=();
        my @privnmask_arr=();

        for my $eth (@{$sys->{publicnics_new}}) {
            $pip = $prod->get_ip_from_ppool();
            $pmask = $prod->get_nmask_from_ppool();
            push (@pubip_arr,$pip);
            push (@pubnmask_arr,$pmask);

            for ($i = 0 ; $i < $cfg->{snas_nvip}; $i++) {
                $vip = $prod->get_ip_from_vpool();
                $vmask = $prod->get_nmask_from_vpool();
                push (@privip_arr,$vip);
                push (@privnmask_arr,$vmask);
            }
        }


        for my $eth (@{$sys->{publicnic_bond_nic}}) {
            $pip = $prod->get_ip_from_ppool();
            $pmask = $prod->get_nmask_from_ppool();
            push (@pubip_arr,$pip);
            push (@pubnmask_arr,$pmask);

            for ($i = 0 ; $i < $cfg->{snas_nvip}; $i++) {
                $vip = $prod->get_ip_from_vpool();
                $vmask = $prod->get_nmask_from_vpool();
                push (@privip_arr,$vip);
                push (@privnmask_arr,$vmask);
            }
        }

        $sys->set_value('publicip','push', @pubip_arr);
        $sys->set_value('publicnetmask','push', @pubnmask_arr);
        $sys->set_value('privateip','push', @privip_arr);
        $sys->set_value('privatenetmask','push', @privnmask_arr);
    }

    for my $sys (@{$cpic->{systems}}) {
        $prod->create_trigger_link_sys($sys);
    }

    return 1;
}

sub check_private_link_connections {
    my ($prod) = @_;
    my ($sys);

    $sys = ${CPIC::get('systems')}[0];
    $prod->kill_dlpiping_sys($sys);
    $prod->start_dlpiping();
    $prod->wait_for_dlpiping_result();
    $prod->parse_link_connections();
    $prod->kill_dlpiping_sys($sys);
    return;
}

sub start_dlpiping {
    my ($prod) = @_;
    my (%sap_mac,$last_sap,$mac,$sys);
    my ($cmd,$n0,$n,$tmpdir);
    $tmpdir = EDR::tmpdir();


    $sys = ${CPIC::get('systems')}[0];
    $last_sap = 52000; # 52000 is magical initial sap value for dlpiping test.

    foreach my $nic (@{$sys->{privenics}}){
        $last_sap++;
        $mac = $sys->padv->get_mac_by_nic_sys($sys,$nic);
        if ($mac) {
            $sap_mac{$last_sap}{mac} = $mac;
        } else {
            Msg::log("Failed get MAC address of $nic on $sys->{sys}.");
            $sap_mac{$last_sap}{mac} = 'FF:FF:FF:FF:FF:FF';
        }
        $sap_mac{$last_sap}{nic}=$nic;
        $cmd = " cd $tmpdir ; (/opt/VRTSllt/dlpiping -s -v -d $last_sap $nic >/dev/null  2>&1 & ) ";
        $sys->cmd($cmd);

    }
    for my $sysi (@{CPIC::get('systems')}) {
        next if $sysi->system1();
        $n = 0;
        foreach my $nic(@{$sysi->{privenics}}){
            for my $sap (52001..$last_sap) {
                $n0 = $sap-52001;
                Msg::log("Check $nic on $sysi->{sys} to $sap_mac{$sap}{nic} on $sys->{sys}");
                $cmd = "cd $tmpdir ; (/opt/VRTSllt/dlpiping -c -t 10 -d $sap $nic $sap_mac{$sap}{mac} > result-${n0}-${n}- 2>&1 &) ";
                $sysi->cmd($cmd);
            }
            $n++;
        }
    }
    return;
}

sub wait_for_dlpiping_result {
    my ($prod) = @_;
    my ($pids,$retry_count);
    for my $sysi (@{CPIC::get('systems')}) {
        next if $sysi->system1();
        sleep 3;
        $pids = $sysi->proc_pids('dlpiping');
        $retry_count = 10;
        while (scalar @$pids > 0 && $retry_count > 0) {
            sleep 3;
            $retry_count--;
            $pids = $sysi->proc_pids('dlpiping');
        }
    }
    return;
}

sub parse_link_connections {
    my ($prod) = @_;
    my (%connected_to,@resultfiles,@connected_nics,$client_nic,$cmd_out,$server_nic,$sys0,$tmpdir,@used_serv_nics,@used_cli_nics);

    $tmpdir = EDR::tmpdir();
    $sys0 = ${CPIC::get('systems')}[0];
    for my $sys (@{CPIC::get('systems')}) {
        next if ($sys->system1);
        # get content of each result file for debugging
        $sys->cmd("cd $tmpdir; _cmd_echo result_files ; for i in `_cmd_ls $tmpdir/result-*`;do echo \$i;_cmd_cat \$i;done 2>/dev/null");
        $cmd_out = $sys->cmd("_cmd_grep -l 'is alive' $tmpdir/result-* 2>/dev/null");
        @resultfiles = split (/\n/, $cmd_out);
        @resultfiles = sort {$a <=> $b} @resultfiles;
        @connected_nics = ();
        @used_serv_nics = ();
        @used_cli_nics = ();
        %connected_to = ();
        for my $file(@resultfiles) {
            if ($file =~ /result-(\d+)-(\d+)-.*/mx) {
                $server_nic = $1;
                $client_nic = $2;
                next if(EDRu::inarr($client_nic, @used_cli_nics) || EDRu::inarr($server_nic, @used_serv_nics));
                $connected_to{$server_nic} = $client_nic;
                push(@used_serv_nics, $server_nic);
                push(@used_cli_nics, $client_nic);
            }
        }
        for my $i(0..$#{$sys0->{privenics}}) {
            if (defined $connected_to{$i}) {
                $connected_nics[$i] = $connected_to{$i};
            } else {
                $connected_nics[$i] = undef;
            }
        }
        $sys->set_value('connected_priv_nics', 'push', @connected_nics);
    }
    return;
}

sub kill_dlpiping_sys {
    my ($prod, $sys) = (@_);
    my ($pids);

    $pids=$sys->proc_pids('dlpiping');
    $sys->kill_pids(@$pids);
    return;
}

sub configure_nicnames {
    my ($prod,$sys) = @_;
    my ($padv,$pubprefix,$priprefix,$gateway,$nconneths,$ndisconneths,@conneths,@disconneths,$nconneths_new,$ndisconneths_new,@conneths_new,@disconneths_new,$output,$id,$output,$couldrestart,$index);

    $padv=$sys->padv;
    my $cfg = Obj::cfg();
#$gateway = $padv->get_gateway_sys($sys); #may be sth err!
    $gateway = $cfg->{snas_defgateway};
    $couldrestart = 1;

    @conneths = @{$sys->{publicnics_all_old}};
    @conneths_new = @{$sys->{publicnics_all_new}};
    @disconneths = @{$sys->{privenics}};
    @disconneths_new = @{$sys->{privenics_new}};

    for ($index = 0; $index < @conneths; $index++) {
        $output = $padv->configure_nicname_sys($sys,@conneths[$index],@conneths_new[$index]);
        $couldrestart &= $output;
    }

    for ($index = 0; $index < @disconneths; $index++) {
        $output = $padv->configure_nicname_sys($sys,@disconneths[$index],@disconneths_new[$index]);
        $couldrestart &= $output;
    }

    return 1 if ($couldrestart);
    return 0;
}

sub configure_hostnames {
    my ($prod,$sys) = @_;
    my ($output,$padv);
    $padv=$sys->padv;
    $output = $padv->configure_hostname_sys($sys,$sys->{newhostname});
    if (!$output) {
        Msg::log("$sys config hostname failed!");
        return 0;
    } else {
        return 1;
    }
}

sub configure_ip_nics {
    my ($prod) = @_;
    my ($cfg);
    my (@pubeths,@privethsold,@pubethsnew,@privethsnew,@bondnicnew,$pip,$pmask,$vip,$vmask,$output,$res,$index,$nic,$nicnew,$i,$j);
    my (@iphostsarr,@freepriviparr,@physicaliparr,@privatedevicearr,@privateiparr,@publicdevicearr,@pubip_arr,@viparr,@vip_arr,@vipdevicearr,@bond,@bondnicold,@pubethsold);
    my ($newsysname,$padv,$syslist);
    my ($bondname,$mode,$nicname_new,$nicname);
    $cfg = Obj::cfg();

    $syslist = CPIC::get('systems');

    if ($prod->{netproto} eq $prod->{netprotoipv4}) {
        $pmask = $cfg->{snas_pnmaskstart};
        $vmask = $pmask;
       } else {
        $pmask = $cfg->{snas_pipprefix};
        $vmask = $pmask;
    }

    @physicaliparr = ();
    @publicdevicearr = ();
    @privatedevicearr = ();
    @privateiparr = ();
    @viparr = ();
    @vipdevicearr = ();
    $res = 1;
    $index = 0;
    @freepriviparr = @{$prod->{priviparr}};

    for my $system (@$syslist) {
        $padv = $system->padv;
        $newsysname = $system->{newhostname};

        @pubip_arr = @{$system->{publicip}};
        @vip_arr = @{$system->{privateip}};
        $system->set_value('hostip',$pubip_arr[0]);

        @privethsold  = @{$system->{privenics}};
        @privethsnew = @{$system->{privenics_new}};
        @pubethsold  = @{$system->{publicnics_old}};
        @pubethsnew  = @{$system->{publicnics_new}};
        @bondnicold  = @{$system->{bond_nic_old}};
        @bondnicnew  = @{$system->{bond_nic_new}};
        @bond        = @{$system->{publicnic_bond_nic}};


        $index = 0;
        while ($index < @pubethsnew) {
            $pip = $pubip_arr[$index];
            $nic = $pubethsold[$index];
            $nicnew = $pubethsnew[$index];
            # rename NIC and configure public physical IP on each system
            $output = $padv->configure_ip_sys($system,$nic,$nicnew,$pip,$pmask,$prod->{netproto});
            $res &= $output;
            push (@physicaliparr, "$pip $pmask $newsysname $nicnew");

            for ($i = $index*$cfg->{snas_nvip} ; $i < ($index+1)*$cfg->{snas_nvip}; $i++) {
                $vip = $vip_arr[$i];
                push (@viparr, "$vip $vmask");
            }
            $index++;
        }

        #config bond and assign ip

        for ($i = 0; $index < @pubip_arr && $i < @bond; $i++,$index++) {
            $pip = $pubip_arr[$index];
            $bondname = $bond[$i];
            $mode = $cfg->{bondmode}{$bondname};
            $output = $padv->configure_bond_ip_common($system,$bondname,$mode,$pip,$pmask,$prod->{netproto});

            $res &= $output;
            push (@physicaliparr, "$pip $pmask $newsysname $bondname");

            for ($j = $index*$cfg->{snas_nvip} ; $j < ($index+1)*$cfg->{snas_nvip}; $j++) {
                $vip = $vip_arr[$j];
                push (@viparr, "$vip $vmask");
            }
        }

        #config bond nic without assigning ip

        foreach my $key(sort (keys %{$cfg->{bondpool}})) {
            for my $pciid (@{$cfg->{bondpool}{$key}}){
                $nicname = $system->padv->get_nicname_by_pciid_sys($system,$pciid);
                $nicname_new = $prod->get_nicname_new_by_nicname_sys($system,$nicname);
                $output = $padv->configure_bondnic_sys($system,$key,$nicname,$nicname_new);
                $res &= $output;
            }
        }

        # rename NIC and configure private IP on priveth0 of each system
        my $privip = shift @freepriviparr;
        $index = 0;
        for my $priveth_new(@privethsnew) {
            if ($priveth_new eq "$prod->{privnic_prefix}".'0') {
                $output = $padv->configure_ip_sys($system,$privethsold[$index],$privethsnew[$index],$privip,$prod->{privateipnetmask},$prod->{netprotoipv4});
                $res &= $output;
                push (@privateiparr, "$privip $prod->{privateipnetmask} $newsysname $privethsnew[0]");
                push (@iphostsarr, "$privip\t$newsysname");
            } else {
                # configure priveth1
                $output = $padv->configure_ip_sys($system,$privethsold[$index],$privethsnew[$index],'','',$prod->{netprotoipv4});
                $res &= $output;
            }
            $index ++;
        }
    }
    # generate private ip array of all the systems 
    unless (Cfg::opt('addnode')) {
        for my $privip (@freepriviparr) {
            push (@privateiparr, "$privip $prod->{privateipnetmask}");
        }
    }

    @publicdevicearr = (@pubethsnew,@bond);
    @vipdevicearr = (@pubethsnew,@bond);
    @privatedevicearr = @privethsnew;

    $prod->set_value('physicaliparr','push', @physicaliparr);
    $prod->set_value('publicdevicearr','push', @publicdevicearr);
    $prod->set_value('privatedevicearr','push', @privatedevicearr);
    $prod->set_value('privateiparr','push', @privateiparr);
    $prod->set_value('viparr','push', @viparr);
    $prod->set_value('vipdevicearr','push', @vipdevicearr);
    $prod->set_value('iphostsarr','push', @iphostsarr);

    return $res;
}

sub write_config_files_sys {
    my ($prod,$sys) = @_;
    my $cfg = Obj::cfg();
    my @physicaliparr =@{$prod->{physicaliparr}};
    my @publicdevicearr = @{$prod->{publicdevicearr}};
    my @privateiparr = @{$prod->{privateiparr}};
    my @viparr = @{$prod->{viparr}};
    my @vipdevicearr = @{$prod->{vipdevicearr}};
    my @iphostsarr = @{$prod->{iphostsarr}};

    $sys->mkdir($prod->{nicconf}->{filepath});
    $prod->set_physicalipfile_sys($sys,@physicaliparr);
    $prod->set_publicdevicefile_sys($sys,@publicdevicearr);
    $prod->set_privatedevicefile_sys($sys);
    $prod->set_privateipfile_sys($sys,@privateiparr);
    $prod->set_vipfile_sys($sys,@viparr);
    $prod->set_vipdevicefile_sys($sys,@vipdevicearr);
    $prod->set_consoleipfile_sys($sys);
    $prod->set_consoledevfile_sys($sys);
    $prod->set_bonddevfile_sys($sys);
    $prod->set_bonddevfile4shell_sys($sys);
    $prod->set_exclusionfile_sys($sys);
    $prod->set_pci_exclusionfile_sys($sys);
    $prod->set_globalroutesfile_sys($sys);
    $prod->update_hosts_file_sys($sys,@iphostsarr);

#$prod->write_nasinstallconf_sys($sys);
    return 1;
}

sub handler_restart_network{
    my ($prod) = @_;
    my ($syslist, $syslistsrc, $systmp, $cmd, @pubeths,@pubethsnew,@pubeths_ip, @pubeths_ip_new,@priveths,@privethsnew,@pubip_arr,$pip,$pubnic,$privnic,$pubnicnew,$privnicnew,$scripts,$output,$index,$msg,$ret,$cfg,$pipprefix,$pnmaskstart,$bits,$ipaddress,$ipproto,%nichash,$background,@newnodes,$retry,$i,$flag,$log);
    $cfg=Obj::cfg();
    $syslistsrc = CPIC::get('systems');
    $retry = $prod->{retry_times};
    %nichash = ();
    $log = "$prod->{logdir}/$prod->{scriptslog}";

    $pipprefix = $cfg->{snas_pipprefix};
    $pnmaskstart = $cfg->{snas_pnmaskstart};
    $bits = EDRu::mask2cidr($pnmaskstart) if($prod->{netproto} eq $prod->{netprotoipv4});

    if ($prod->{netproto} eq $prod->{netprotoipv6}) {
        $ipproto = "-6";
    } else {
        $ipproto = "-4";
    }  

    $cmd = '';

    for my $system (@$syslistsrc) {
        if (!$system->{islocal}) {
            push(@$syslist,$system);
        } else {
            $systmp = $system;
        }
    }

    push(@$syslist,$systmp) if (defined $systmp);

    for my $system (@$syslist) {
        @pubeths =  @{$system->{publicnics_all_old}};
        @pubethsnew =  @{$system->{publicnics_all_new}};
        @priveths =  @{$system->{privenics}};
        @privethsnew =  @{$system->{privenics_new}};
        @pubip_arr = @{$system->{publicip}};
        @pubeths_ip =  @{$system->{publicnics_old}};
        @pubeths_ip_new =  @{$system->{publicnics_new}};

        $cmd="";
        for ($index = 0; $index < @pubeths; $index++) {
            $pubnic = $pubeths[$index];
            $cmd .= "/sbin/ip link set $pubnic down >/dev/null 2>&1;\n";
            $cmd .= "/sbin/ip link set $pubnic name pubn$index >/dev/null 2>&1;\n";
            $nichash{$pubnic}="pubn$index";
        }

        for ($index = 0; $index < @priveths; $index++) {
            $privnic = $priveths[$index];
            $cmd .= "/sbin/ip link set $privnic down >/dev/null 2>&1;\n";
            $cmd .= "/sbin/ip link set $privnic name privn$index >/dev/null 2>&1;\n";
            $nichash{$privnic}="privn$index";
        }

        for ($index = 0; $index < @pubeths; $index++) {
            $pubnic = $pubeths[$index];
            $pubnicnew = $pubethsnew[$index];
            $cmd .= "/sbin/ip link set $nichash{$pubnic} name $pubnicnew >/dev/null 2>&1;\n";
            $cmd .= "/sbin/ip link set $pubnicnew up >/dev/null 2>&1;\n";
        }

        for ($index = 0; $index < @pubeths_ip; $index++) {
            $pip = $pubip_arr[$index];
            $pubnic = $pubeths_ip[$index];
            $pubnicnew = $pubeths_ip_new[$index];

            if ($prod->{netproto} eq $prod->{netprotoipv6}) {
                $ipaddress = "$pip\/$pipprefix";
            } else {
                $ipaddress = "$pip\/$bits";
            }
            $cmd .= "/sbin/ip addr flush $pubnicnew >/dev/null 2>&1;\n";
            $cmd .= "/sbin/ip $ipproto addr add $ipaddress dev $pubnicnew >/dev/null 2>&1;\n";
            $cmd .= "/bin/bash $prod->{scriptsdir}/net/net_iptables.sh add_public $pubnicnew >> $log 2>&1\n";
        }

        for ($index = 0; $index < @priveths; $index++) {
            $privnic = $priveths[$index];
            $privnicnew = $privethsnew[$index];

            $cmd .= "/sbin/ip link set $nichash{$privnic} name $privnicnew >/dev/null 2>&1;\n";
            $cmd .= "/sbin/ip link set $privnicnew up >/dev/null 2>&1;\n";
            $cmd .= "/bin/bash $prod->{scriptsdir}/net/net_iptables.sh add_private $privnicnew >> $log 2>&1\n";
        }

        $cmd .= "/sbin/service network restart >/dev/null 2>&1;\n";

$scripts = <<"_RESTART_NETWORK"; 
$cmd
_RESTART_NETWORK

        Msg::log("restarting $system->{sys}");
        $background = 1;
        $system->cmd_script($scripts,'','',$background);
        Msg::log("finish restarting $system->{sys}");
        $Obj::pool{"Sys::$pubip_arr[0]"} = $Obj::pool{"Sys::$system->{sys}"};
        my $sys = $Obj::pool{"Sys::$pubip_arr[0]"};
        $sys->{sys} = $pubip_arr[0];
        $sys->{ip} = $pubip_arr[0];
        $sys->{pool} = "Sys::$pubip_arr[0]";
        $sys->{hostname} = $sys->{newhostname};
        $sys->{vcs_sysname} = $sys->{hostname};
        push(@newnodes, $sys->{sys});
    }

    $cfg->{newnodes} = \@newnodes;
    my $localsys=EDR::get('localsys');

    for my $system (@$syslist) {
        $flag = 0;
        $i=0;

        while ($i < $retry*2) {
            $i++;
            sleep 10;
            $ret = $localsys->padv->ping($system->{sys});

            my $output = 0;
            for ($index = 0; $index < @priveths; $index++) {
                my $privnicnew = $privethsnew[$index];
                $system->cmd("_cmd_ip -o link show dev '$privnicnew' 2>/dev/null");
                if (EDR::cmdexit()) {
                    Msg::log("$privnicnew is not up yet");
                    $output = 1;
                }
            }

            if ($ret eq 'noping' || $output == 1) {
                Msg::log("Sleep 10, ping $system->{sys} again, try $i times");
                $flag = 1;
                next;
            } else {
                $flag = 0;
                Msg::log("Restarting new IP addresses on $system->{sys} succeeded.");
                last;
            }
        }

        if ($flag) {
            $msg = Msg::new("Restarting new IP addresses on $system->{sys} failed.");
            $msg->error;
            return 0;
        }
    }

    return 1;
}

sub reboot_messages {
    my ($prod) = @_;
    my ($reboot_msg,$msg,$cpic,$padv,@reboot_systems,@reboot_systems_ip,$reboot_systems_str,$reboot_systems_ip_str);

    $cpic=Obj::cpic();
    $padv=Obj::padv($cpic->{padv});
    @reboot_systems=();
    @reboot_systems_ip=();
    for my $sys (@{$cpic->{systems}}) {
        push (@reboot_systems,$sys->{sys}); 
        push (@reboot_systems_ip,@{$sys->{publicip}}[0]);
    }
    $reboot_systems_str = join(' ',@reboot_systems);
    $reboot_systems_ip_str = join(' ',@reboot_systems_ip);
    $msg=Msg::new("It is strongly recommended to reboot the following systems:\n\t$reboot_systems_str\n\nExecute '$padv->{cmd}{shutdown}' to properly restart your systems");
    $reboot_msg.=$msg->{msg};
    my $script=EDR::get('script');
    $msg=Msg::new("\n\nAfter a reboot, run the '$script -configure' to continue configuring the following systems:\n\t$reboot_systems_ip_str");
    $reboot_msg.=$msg->{msg};
    Msg::display_bold($reboot_msg);
    return 1;
}

sub add_groups_sys {
    my ($prod, $sys)=@_;
    $sys->cmd("_cmd_groupadd -g 1001 master");
    $sys->cmd("_cmd_groupadd -g 1002 sysadmin");
    $sys->cmd("_cmd_groupadd -g 1003 stoadmin");
    $sys->cmd("_cmd_groupadd -g 1004 sysstoadmin");
    $sys->cmd("_cmd_groupadd -g 1005 Xmaster");
    return 1;
}

sub add_users_sys {
    my ($prod,$sys)=@_;
    $sys->mkdir($prod->{clish}->{clishhomepath});
    $sys->mkdir($prod->{clish}->{supporthomepath});
    $sys->cmd("_cmd_userdel -r master");
    $sys->cmd("_cmd_useradd master -d $prod->{clish}->{clishhomepath} -s $prod->{clish}->{clishpath} -g Xmaster -G master,root,sysadmin,stoadmin,sysstoadmin");
    $sys->cmd("_cmd_usermod -o -u 0 master");
    $sys->cmd("_cmd_chown -R master:Xmaster $prod->{clish}->{clishhomepath}");
    $sys->cmd("_cmd_useradd support -d $prod->{clish}->{supporthomepath} -s $prod->{clish}->{bashpath} -g root");
    $sys->cmd("_cmd_usermod -o -u 0 support");
    return 1;
}

sub build_key_path {
    my ($prod) = @_;
    my (%kvs,$cfg,$cpic,$mode);

    %kvs = ();
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();

    $kvs{"MODE"} = $prod->{mode}->{master};
    $kvs{"LICENSE_TYPE"}="ENTERPRISE";
    $kvs{"LICENSE"}="8RZG-3FSI-RVFF-8OTJ-ZLGO-WZP8-O63P-P";
    $kvs{"GATEWAYNAME"}=$cfg->{snas_clustername};
    $kvs{"NNODES"}=@{$cpic->{systems}};
    $kvs{"SINGLENODE"}="no";
    $kvs{"SEPCONSOLE"}=$cfg->{snas_sepconsoleport};
    $kvs{"NVIPS"}=$cfg->{snas_nvip};
    $kvs{"PIPSTART"}=$cfg->{snas_pipstart};
    $kvs{"VIPSTART"}=$cfg->{snas_vipstart};
    $kvs{"CONSIP"}=$cfg->{snas_consoleip};
    $kvs{"NTPSERVER"}=$cfg->{snas_ntpserver};
    $kvs{"DNS"}=$cfg->{snas_dnsip};
    $kvs{"DOMAINNAME"}=$cfg->{snas_dnsdomainname};
    $kvs{"GATEWAY"}=$cfg->{snas_defgateway};
    $kvs{"NPORTS"}="4";
    $kvs{"NLMMASTERIP"}="172.16.0.2";
    $kvs{"PRIVATE_NET_SUBNET"}="172.16.0.0";
    $kvs{"PRIVATE_NET_NETMASK"}="255.255.255.0";
    $kvs{"NETPROTO"}=$prod->{netproto};

    if($prod->{netproto} eq $prod->{netprotoipv4}) {
        $kvs{"PIPMASK"}=$cfg->{snas_pnmaskstart};
        $kvs{"VIPMASK"}=$cfg->{snas_vnmaskstart};
    } else {
        $kvs{"PIPMASK"}=$cfg->{snas_pipprefix};
        $kvs{"VIPMASK"}=$cfg->{snas_vipprefix};
    }

    $kvs{"PCIEXCLUSIONID"}=join(' ',@{$cfg->{exclusion}});
    $kvs{"PUBBONDEVICEID"}=join(' ',@{$cfg->{publicbond}});
    foreach my $key(sort (keys %{$cfg->{bondpool}})) {
        $mode = $cfg->{bondmode}{$key};
        $kvs{"PUB_BOND_MODE"}=$mode;
        last;
    }

    return \%kvs;
}

sub build_nasinstallconf_sys {
    my ($prod,$sys) = @_;
    my ($padv,@items,$confhash,$macs,$mac);

    $padv=$sys->padv;
    $confhash = $prod->build_key_path();
    $macs = $prod->get_all_nics_mac_sys($sys);
    $mac = join(',',@{$macs});
    if ($sys->system1 && !Cfg::opt('addnode')) {
        $confhash->{"MODE"}=$prod->{mode}->{master};
        $confhash->{"INSTSERVVIP"}="172.16.0.1";
        $confhash->{"NPORTS"}=@{$prod->{publicdevicearr}}+@{$prod->{privatedevicearr}};
    } else {
        $confhash->{"MODE"}=$prod->{mode}->{slave};
        $confhash->{"NPORTS"}=@{$prod->{publicdevicearr}}+@{$prod->{privatedevicearr}};
        $confhash->{"SERVERIP"}="172.16.0.1";
        $confhash->{"MACS"}=$mac;
        $confhash->{"PRIVATE0_MAC"}= $padv->get_mac_by_nic_sys($sys,@{$sys->{privenics}}[0]);
    }

    foreach my $key(sort (keys %{$confhash})) {
        next if (!defined $confhash->{$key});
        push (@items,$key);
        push (@items,"\"$confhash->{$key}\"");
    }

    $sys->set_value('nasinstallconf','push', @items);
    return 1;
}

sub write_nasinstallconf {
    my ($prod) = @_;
    my ($output,$cpic);
    $cpic = Obj::cpic();
    for my $sys (@{$cpic->{systems}}) {
        $output = $prod->write_nasinstallconf_sys($sys);
    }
}

sub write_nasinstallconf_sys{
    my ($prod,$sys) = @_;
    my ($file,$filelocpath,$obj,$edr,$cpic,$tmpdir);
    
    $edr=Obj::edr();
    $tmpdir=EDR::tmpdir();

    $filelocpath = "$tmpdir/nasinstall.conf"; 
    $file = $prod->{nicconf}->{nasinstallconf};

    $sys->mkdir("$prod->{nicconf}->{nodefilepath}");
    $sys->cmd("_cmd_touch $prod->{nicconf}->{nasinstallconf}");
    $sys->cmd("_cmd_cat /dev/null > $prod->{nicconf}->{nasinstallconf}");

    $prod->build_nasinstallconf_sys($sys);

    $prod->set_default_values($filelocpath,@{$sys->{nasinstallconf}});
    if ($sys->{islocal}) {
        $sys->copyfile($filelocpath,$file);
    } else {
        $edr->localsys->copy_to_sys($sys,$filelocpath,$file);
    }
    return 1;
}

sub get_all_nics_mac_sys {
    my ($prod,$sys) = @_;
    my ($padv,$output,@macs,$cpic);

    $cpic=Obj::cpic();
    $padv=$sys->padv;
    @macs=();

    my @publicdevicearr = @{$sys->{publicnics}};
    my @privatedevicearr = @{$sys->{privenics}};
    for my $nic (@publicdevicearr) {
        $output = $padv->get_mac_by_nic_sys($sys,$nic);
        push (@macs, $output);
    }
    for my $nic (@privatedevicearr) {
        $output = $padv->get_mac_by_nic_sys($sys,$nic);
        push (@macs, $output); 
    }
    return \@macs;
}

sub set_physicalipfile_sys {
    my ($prod,$sys,@arr) = @_;
    my $content;
    for my $line (@arr) {
        $content .= "$line\n";
    }
    if (Cfg::opt('addnode')) {
        $sys->appendfile($content,$prod->{nicconf}->{physicalipfile});
        $sys->cmd("_cmd_sed -i '/^\s*\$/d' $prod->{nicconf}->{physicalipfile}");
    } else {
        $sys->writefile($content,$prod->{nicconf}->{physicalipfile});
    }
    return 1;
}

sub set_publicdevicefile_sys {
    my ($prod,$sys,@arr) = @_;
    my $line = join(' ',@arr);
    $line .= "\n";
    $sys->writefile($line,$prod->{nicconf}->{publicdevicefile});
    return 1;
}

sub set_vipdevicefile_sys  {
    my ($prod,$sys,@arr) = @_;
    my $line = join(' ',@arr);
    $line .= "\n";
    $sys->writefile($line,$prod->{nicconf}->{vipdevicefile});
    return 1;
}

sub set_privatedevicefile_sys  {
    my ($prod,$sys,@arr) = @_;
    my $line = "$prod->{privnic_prefix}".'0';
    $sys->writefile($line,$prod->{nicconf}->{privatedevicefile});
    return 1;
}

sub set_privateipfile_sys  {
    my ($prod,$sys,@arr) = @_;
    my ($content,$ip);
    if (Cfg::opt(qw(addnode delnode))) {
        for my $line (@arr) {
            ($ip, undef) = split(/\s+/, $line);
            $sys->cmd("_cmd_sed -i 's/^$ip.*\$/$line/' $prod->{nicconf}->{privateipfile} 2>/dev/null");
        }
    } else {
        for my $line (@arr) {
            $content .= "$line\n";
        }
        $sys->writefile($content,$prod->{nicconf}->{privateipfile});
    }
    return 1;
}

sub set_vipfile_sys  {
    my ($prod,$sys,@arr) = @_;
    my $content = '';

    for my $line (@arr) {
        $content .= "$line\n";
    }
    if (Cfg::opt('addnode')) {
        $sys->appendfile($content,$prod->{nicconf}->{vipfile});
        $sys->cmd("_cmd_sed -i '/^\s*\$/d' $prod->{nicconf}->{vipfile}");
    } else {
        $sys->writefile($content,$prod->{nicconf}->{vipfile});
    }

    return 1;
}

sub set_consoleipfile_sys  {
    my ($prod,$sys) = @_;
    my ($cfg, $content);
    $cfg = Obj::cfg();

    $content = "$cfg->{snas_consoleip} ${$sys->{privatenetmask}}[0]\n";
    $sys->writefile($content,$prod->{nicconf}->{consoleipfile});

    return 1;
}

sub set_consoledevfile_sys  {
    my ($prod,$sys) = @_;
    my $content = "${$prod->{publicdevicearr}}[0]\n";
    $sys->writefile($content,$prod->{nicconf}->{consoledevfile});
    return 1;
}

sub set_bonddevfile4shell_sys {
    my ($prod,$sys) = @_;
    my ($cfg, $content,$mode,$eth);
    $cfg = Obj::cfg();

    $content = '';
    foreach my $key(sort (keys %{$cfg->{bondpool}})) {
        $mode = $cfg->{bondmode}{$key};
        $content .= "$key|";
        for my $pciid (@{$cfg->{bondpool}{$key}}) {
            $eth = $sys->padv->get_nicname_by_pciid_sys($sys,$pciid);
            $content .= "$eth ";
        }
        $content .= "|$mode\n";
    }

    if ($content eq '') {
        $sys->cmd("_cmd_touch $prod->{nicconf}->{bonddevfile4shell} 2>/dev/null");
        $sys->cmd("_cmd_touch $prod->{nicconf}->{bonddevfile4shell_new} 2>/dev/null");
    } else {
        $sys->writefile($content,$prod->{nicconf}->{bonddevfile4shell});
        $sys->writefile($content,$prod->{nicconf}->{bonddevfile4shell_new});
    }
    return 1;
}

sub set_bonddevfile_sys {
    my ($prod,$sys) = @_;
    my ($cfg, $content,$mode);
    $cfg = Obj::cfg();

    $content = '';
    foreach my $key(sort (keys %{$cfg->{bondpool}})) {
        $mode = $cfg->{bondmode}{$key};
        $content .= "$key $mode";
        for my $eth (@{$cfg->{bondpool}{$key}}) {
            $content .= " $eth";
        }
        $content .= "\n";
    }

    if ($content eq '') {
        $sys->cmd("_cmd_touch $prod->{nicconf}->{bonddevfile} 2>/dev/null");
    } else {
        $sys->writefile($content,$prod->{nicconf}->{bonddevfile});
    }
    return 1;
}

sub set_exclusionfile_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$content);
    $cfg = Obj::cfg();
    
    if (@{$cfg->{exclusion}} != 0) {
        $content = join(' ', @{$cfg->{exclusion}});
        $sys->writefile($content,$prod->{nicconf}->{exclusionfile});
    } else {
        $sys->cmd("_cmd_touch $prod->{nicconf}->{exclusionfile} 2>/dev/null");
    }
    return 1;
}

sub set_pci_exclusionfile_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$content);
    $cfg = Obj::cfg();
    
    $content = '';
    if ((defined $cfg->{exclusion}) && (@{$cfg->{exclusion}} != 0)) {
        for my $system (@{CPIC::get('systems')}) {
            for my $pciid (@{$cfg->{exclusion}}) {
                $content .= "$pciid|y|$system->{newhostname}\n";
            }
        }
        if (Cfg::opt('addnode')) {
            $sys->appendfile($content,$prod->{nicconf}->{pciexclusionfile});
            $sys->cmd("_cmd_sed -i '/^\s*\$/d' $prod->{nicconf}->{pciexclusionfile}");
        } else {
            $sys->writefile($content,$prod->{nicconf}->{pciexclusionfile});
        }
    } else {
        $sys->cmd("_cmd_touch $prod->{nicconf}->{pciexclusionfile} 2>/dev/null");
    }
    return 1;
}

sub set_globalroutesfile_sys {
    my ($prod,$sys) = @_;
    my ($content,$syslist,$id,$hostname,$cfg);
    $cfg= Obj::cfg();
    $syslist = CPIC::get('systems');
    $content = '';
    $id = 1;
    for my $system (@$syslist) {
        $hostname = $system->{newhostname};

        if ($prod->{netproto} eq $prod->{netprotoipv4}) {
            $content .= "$hostname 0.0.0.0/0 $cfg->{snas_defgateway} - -\n";
        } else {
            $content .= "$hostname ::/0 $cfg->{snas_defgateway} - -\n";
        }
        $id++;
    }
    if (Cfg::opt('addnode')) {
        $sys->appendfile($content,$prod->{nicconf}->{globalroutes});
        $sys->cmd("_cmd_sed -i '/^\s*\$/d' $prod->{nicconf}->{globalroutes}");
    } else {
        $sys->writefile($content,$prod->{nicconf}->{globalroutes});
    }
}


sub update_hosts_file_sys {
    my ($prod,$sys,@vars) = (@_);
    my ($hostsfile,$content,$ip,$host);
    $hostsfile = $prod->{hostsfile};
    $content = $sys->catfile($hostsfile);
    $content.="\n";
    for my $line(@vars) {
        ($ip,$host) = split (/\s+/, $line);
        $content =~ s/^.*$host.*\n//mg;
        $content.="$line\n";
    }
    $content=~s/^\s*\n//mg;
    $sys->writefile($content,$hostsfile);
    return 1;
}

sub get_next_ip {
    my ($prod,$ip,$step) = @_;
    my (@nip,$iparr);
    if (!(EDRu::ip_is_ipv4($ip)) && !(EDRu::ip_is_ipv6($ip))) {
        return "0.0.0.0";    
    }
    if (EDRu::ip_is_ipv4($ip)) {
        @nip = split(/\./,$ip);
        $nip[3]+=$step;
        if ($nip[3]>255) {
            $nip[2] += ($nip[3] - 255);
            $nip[3] -= 255;
        }
        if ($nip[2]>255) {
            $nip[1] += ($nip[2] - 255);
            $nip[2] -= 255;
        }
        if ($nip[1]>255) {
            $nip[0] += ($nip[1] - 255);
            $nip[1] -= 255;
        }
        if ($nip[0]>255) {
            return "0.0.0.0";
        }
        $ip = $nip[0].".".$nip[1].".".$nip[2].".".$nip[3];
    } else {
        $iparr = EDRu::ipv6toarr($ip);
        @nip = @{$iparr};
        $nip[7]=EDRu::hex2dec($nip[7]);
        $nip[6]=EDRu::hex2dec($nip[6]);
        $nip[5]=EDRu::hex2dec($nip[5]);
        $nip[4]=EDRu::hex2dec($nip[4]);
        $nip[3]=EDRu::hex2dec($nip[3]);
        $nip[2]=EDRu::hex2dec($nip[2]);
        $nip[1]=EDRu::hex2dec($nip[1]);
        $nip[0]=EDRu::hex2dec($nip[0]);

        $nip[7]+=$step;

        if ($nip[7] > 65535) {
            $nip[6] += ($nip[7] - 65535);
            $nip[7] -= 65535;
        }

        if ($nip[6] > 65535) {
            $nip[5] += ($nip[6] - 65535);
            $nip[6] -= 65535;
        }
        if ($nip[5] > 65535) {
            $nip[4] += ($nip[5] - 65535);
            $nip[5] -= 65535;
        }

        if ($nip[4] > 65535) {
            $nip[3] += ($nip[4] - 65535);
            $nip[4] -= 65535;
        }
        if ($nip[3] > 65535) {
            $nip[2] += ($nip[3] - 65535);
            $nip[3] -= 65535;
        }
        if ($nip[2] > 65535) {
            $nip[1] += ($nip[2] - 65535);
            $nip[2] -= 65535;
        }
        if ($nip[1] > 65535) {
            $nip[0] += ($nip[1] - 65535);
            $nip[1] -= 65535;
        }
        if ($nip[0] > 65535) {
            return "0:0:0:0:0:0:0:0";
        }

        $nip[7] = EDRu::dec2hex($nip[7]);
        $nip[6] = EDRu::dec2hex($nip[6]);
        $nip[5] = EDRu::dec2hex($nip[5]);
        $nip[4] = EDRu::dec2hex($nip[4]);
        $nip[3] = EDRu::dec2hex($nip[3]);
        $nip[2] = EDRu::dec2hex($nip[2]);
        $nip[1] = EDRu::dec2hex($nip[1]);
        $nip[0] = EDRu::dec2hex($nip[0]);

        $ip = "$nip[0]:$nip[1]:$nip[2]:$nip[3]:$nip[4]:$nip[5]:$nip[6]:$nip[7]";
    }
    return $ip;
}

sub get_next_mask {
    my ($prod,$ip,$step) = @_;
    return $ip;
}

sub truncate_ip_pool {
    my ($prod) = @_;
    my $cfg= Obj::cfg();
    @{$prod->{snas_ip_pool}->{public}} = ();
    @{$prod->{snas_ip_pool}->{private}} = ();
    @{$prod->{snas_nmask_pool}->{public}} = ();
    @{$prod->{snas_nmask_pool}->{private}} = ();
    return 1;
}

sub set_ip_to_ppool {
    my ($prod,$ip) = @_;
    push (@{$prod->{snas_ip_pool}->{public}},$ip);
    return;
}

sub get_ip_from_ppool{
    my ($prod) = @_;
    my $ip = shift @{$prod->{snas_ip_pool}->{public}};
    return $ip;
}

sub set_ip_to_vpool {
    my ($prod,$ip) = @_;
    push (@{$prod->{snas_ip_pool}->{private}},$ip);
    return;
}

sub get_ip_from_vpool{
    my ($prod) = @_;
    my $ip = shift @{$prod->{snas_ip_pool}->{private}};
    return $ip;
}

sub set_nmask_to_ppool {
    my ($prod,$ip) = @_;
    push (@{$prod->{snas_nmask_pool}->{public}},$ip);
    return;
}

sub get_nmask_from_ppool {
    my ($prod) = @_;
    my $ip = shift @{$prod->{snas_nmask_pool}->{public}};
    return $ip;
}

sub set_nmask_to_vpool {
    my ($prod,$ip) = @_;
    push (@{$prod->{snas_nmask_pool}->{private}},$ip);
    return;
}

sub get_nmask_from_vpool{
    my ($prod) = @_;
    my $ip = shift @{$prod->{snas_nmask_pool}->{private}};
    return $ip;
}

sub ask_pip_sys {
    my ($prod,$sys)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The public IP address is used for detecting the public and private NICs. System IP addresses will be defined sequentially starting with the initial address.\nEnter the first or starting physical IP address from the range of physical IP addresses that your network administrator provided. These IP addresses must be in a consecutive numerical range.");
        $msg=Msg::new("Enter the public IP starting address:");

        $answer=$msg->ask('',$help,$backopt);

        if (!EDRu::isip($answer) || !$prod->check_ip_available($sys,$answer)) {
            $msg=Msg::new("$answer contains an invalid IP address");
            $msg->print;
            next; 
        }
        $done=1;
    }
    return $answer;
}

sub ask_pnmask_sys {
    my ($prod,$sys,$hint)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The netmask is common for physical and virtual IP addresses.");
        $msg=Msg::new("Enter the netmask for the public IP address:");

        $answer=$msg->ask($hint,$help,$backopt);

        if (!EDRu::isip($answer)) {
            $msg=Msg::new("$answer contains an invalid IP address");
            $msg->print;
            next; 
        }
        $done=1;
    }
    return $answer;
}

sub ask_vip_sys {
    my ($prod,$sys)=@_;
    my ($answer,$backopt,$done,$msg,$help,$hintvip);

    $done=0;

    while (!$done) {
        $help=Msg::new("Enter the first or starting virtual IP address from the range of virtual IP addresses that your network administrator provided. These IP addresses must be in a consecutive numerical range.");
        $msg=Msg::new("Enter the virtual IP starting address:");
        $hintvip='';

        $answer=$msg->ask($hintvip,$help,$backopt);

        return $answer if (EDR::getmsgkey($answer,'back'));
        if ((!EDRu::ip_is_ipv4($answer) && ($prod->{netproto} eq $prod->{netprotoipv4})) || (!EDRu::ip_is_ipv6($answer) && ($prod->{netproto} eq $prod->{netprotoipv6})) || !EDRu::isip($answer) || !$prod->check_ip_available($sys,$answer)) {
            $msg=Msg::new("$answer contains invalid IP address");
            $msg->print;
            next; 
        }
        $done=1;
    }

    if (EDRu::ip_is_ipv4($answer)) {
        $prod->{netprotovip} = $prod->{netprotoipv4}; 
    } else {
        $prod->{netprotovip} = $prod->{netprotoipv6}; 
    }
    return $answer;
}

sub ask_vnmask_sys {
    my ($prod,$sys,$hintvnmask)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The netmask is common for physical and virtual IP addresses.");
        $msg=Msg::new("Enter the netmask for the virtual IP address:");
        if ($hintvnmask eq "0.0.0.0" ) {
            $hintvnmask = '';
        }
        $answer=$msg->ask($hintvnmask,$help,$backopt);
        if (!EDRu::isip($answer)) {
            $msg=Msg::new("$answer contains invalid IP address");
            $msg->print;
            next; 
        }
        $done=1;
    }
    return $answer;
}

sub ask_clustername {
    my ($prod)=@_;
    my ($vcs,$answer,$backopt,$done,$msg,$help);
    $vcs=$prod->prod('VCS61');

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The cluster name is used in the configuration files and all the nodes will be renamed as clustername_01, clustername_02, and so on in the Storage NAS cluster.");
        $msg=Msg::new("Enter the cluster name:");
        $answer=$msg->ask('',$help,$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        next if (!$vcs->verify_clustername($answer));
        if($answer =~ /[-]/) {
            $msg=Msg::new("Cluster name cannot use the character '-'. Input again");
            $msg->print;
            next;
        }
        if(length($answer) > $prod->{maximum_clus_name_length} || length($answer) < $prod->{minimum_clus_name_length}) {
            $msg=Msg::new("The length of cluster name cannot exceed $prod->{maximum_clus_name_length} characters. Input again");
            $msg->print;
            next;
        }
        $done=1;
    }
    return $answer;
}

sub ask_default_gateway_sys {
    my ($prod,$sys,$netproto)=@_;
    my ($answer,$backopt,$done,$msg,$help,$locgateway,$padv);

    $padv=$sys->padv;
    $locgateway = $padv->get_gateway_sys($sys,$prod->{netproto});
    $locgateway = '' if ($prod->{netproto} eq $prod->{netprotoipv6} && !EDRu::ip_is_ipv6($locgateway));
    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The IP address for the default gateway.");
        $msg=Msg::new("Enter the default gateway IP address:");
        $answer=$msg->ask($locgateway,$help,$backopt);
        if ((!EDRu::ip_is_ipv4($answer) && ($prod->{netproto} eq $prod->{netprotoipv4})) || (!EDRu::ip_is_ipv6($answer) && ($prod->{netproto} eq $prod->{netprotoipv6}))) {
            $msg=Msg::new("$answer contains invalid IP address");
            $msg->print;
            next; 
        }          
        $done=1;
    }    
    return $answer;
} 

sub ask_dnsip_sys {
    my ($prod,$sys)=@_;
    my ($padv,$answer,$backopt,$done,$msg,$help,$localdns);

    $padv=$sys->padv;
    $localdns = $padv->get_dns_sys($sys);

    $localdns = '' if (($prod->{netproto} eq $prod->{netprotoipv6} && !EDRu::ip_is_ipv6($localdns)) || ($prod->{netproto} eq $prod->{netprotoipv4} && !EDRu::ip_is_ipv4($localdns)));
    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The IP address for the Domain Name System (DNS) server.");
        $msg=Msg::new("Enter the DNS IP address:");
        $answer=$msg->ask($localdns,$help,$backopt);

        if ((!EDRu::ip_is_ipv4($answer) && ($prod->{netproto} eq $prod->{netprotoipv4})) || (!EDRu::ip_is_ipv6($answer) && ($prod->{netproto} eq $prod->{netprotoipv6}))) {
            $msg=Msg::new("$answer contains invalid IP address");
            $msg->print;
            next; 
        }        
        $done=1;
    }    
    return $answer;
} 

sub ask_dnsdomainname_sys {
    my ($prod,$sys)=@_;
    my ($padv,$answer,$backopt,$done,$msg,$help,$localdomain);

    $padv=$sys->padv;
    $localdomain = $padv->get_domain_sys($sys);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The DNS domain name is set as the default for all the nodes in the Storage NAS cluster.");
        $msg=Msg::new("Enter the DNS domain name:");
        $answer=$msg->ask($localdomain,$help,$backopt);
        return $answer if (EDR::getmsgkey($answer,'back'));
        if ($answer  eq '') {
            $msg=Msg::new("$answer is null");
            $msg->print;
            next; 
        }          
        $done=1;
    }    
    return $answer;
} 

sub ask_consoleip_sys {
    my ($prod,$sys)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The virtual IP address for the cluster management console.");
        $msg=Msg::new("Enter the console virtual IP address:");
        $answer=$msg->ask('',$help,$backopt);
        if ((!EDRu::ip_is_ipv4($answer) && ($prod->{netproto} eq $prod->{netprotoipv4})) || (!EDRu::ip_is_ipv6($answer) && ($prod->{netproto} eq $prod->{netprotoipv6})) || !EDRu::isip($answer) || !$prod->check_ip_available($sys,$answer)) {
            $msg=Msg::new("$answer contains invalid IP address");
            $msg->print;
            next; 
        }        
        $done=1;
    }    
    return $answer;
}

sub ask_pciexclusionid_option {
    my ($prod)=@_;
    my ($answer,$backopt,$ayn,$msg,$help);
    Msg::n();
    $msg = Msg::new("Do you want to exclude NICs by PCI IDs?");
    $ayn = $msg->aynn;
    if ($ayn eq 'N') {
        return 0;
    }
    return 1;
}

sub ask_pciexclusionid {
    my ($prod)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The PCI ID for the NIC exclusion is used for skipping the detection and configuration on the NIC that is specified with the PCI ID for exclusion.");
        $msg=Msg::new("Enter the PCI IDs for the NIC exclusion:");
        $answer=$msg->ask('',$help,$backopt);
        chomp($answer);
        $answer = EDRu::despace($answer);
        if (!$prod->check_pciid_available($answer)) {
            $msg=Msg::new("$answer contains an invalid PCI ID");
            $msg->print;
            next;
        }
        $done=1;
    }    
    return $answer;
} 

sub ask_pipprefix{
    my ($prod,$hint)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The prefix is common for physical and virtual IP addresses.");
        $msg=Msg::new("Enter the prefix for the public IP address:");

        $answer=$msg->ask($hint,$help,$backopt);

        if (!EDRu::isint($answer) || $answer > 128 || $answer < 1) {
            $msg=Msg::new("$answer contains an invalid IPv6 prefix length");
            $msg->print;
            next; 
        }
        $done=1;
    }
    return $answer;
}

sub ask_nvip {
    my ($prod,$hint)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $help=Msg::new("The number of virtual IPs per public NIC.");
        $msg=Msg::new("Enter the number of VIPs per interface:");

        $answer=$msg->ask($hint,$help,$backopt);

        if (!EDRu::isint($answer) || $answer <= 0 || $answer >= 10) {
            $msg=Msg::new("$answer contains an invalid number of VIPs per interface");
            $msg->print;
            next; 
        }
        $done=1;
    }
    return $answer;
}

sub ask_sep_console_port {
    my ($prod)=@_;
    my ($answer,$backopt,$done,$msg,$help,$hint);

    $done=0;
    $backopt='';
    $hint="0";
    while (!$done) {
        $msg=Msg::new("Do you want to use the separate console port?");
        $answer=$msg->aynn;

        if ($answer eq 'N') {
            $answer = '0';
        }
        if ($answer eq 'Y'){
            $answer = '1';
        }
        $done=1;
    }
    return $answer;
}

sub ask_ntpserver {
    my ($prod)=@_;
    my ($answer,$backopt,$done,$msg,$help);

    $done=0;
    $backopt='';
    while (!$done) {
        $msg=Msg::new("Do you want to configure the Network Time Protocol(NTP) server to synchronize the system clocks?");
        $answer=$msg->aynn;
        if ($answer eq 'N') {
            return '';
        }
        $done=1;
    }

    $done=0;
    while (!$done) {
        $help=Msg::new("System clocks can be synchronized using the Network Time Protocol(NTP) server.");
        $msg=Msg::new("Enter the Network Time Protocal server:");
        $answer=$msg->ask('',$help,$backopt,1);
        return $answer if (EDR::getmsgkey($answer,'back'));
        next if($prod->verify_ntpserver($answer));
        Msg::log("NTP server is null") if ($answer  eq '');
        $done=1;
    }    
    return $answer;
}

sub verify_ntpserver {
    my ($prod, $ntpservername) = @_;
    my ($msg);
    my $ntpservername_t = $ntpservername;

    $ntpservername_t = EDRu::despace($ntpservername_t);
    if($ntpservername_t =~ /[\\\/\:\*\?\"\'\<\>\|]/mxg) {
        $msg = Msg::new("$ntpservername contains invalid characters");
        $msg->print();
        return 1;
    }
    return 0;
}

sub get_bond_name {
    my ($prod)=@_; 
    my ($num,$bondname);
    my $cfg = Obj::cfg();
    $num = 0;
    while ($num < 65535) {
        return "bond$num" if (!exists $cfg->{bondpool}{"bond$num"});
        $num++;
    }
    return '';
}

sub poststart_sys {
    my ($prod,$sys) = @_;
    my ($vcs,$sysname,$syslist,$msg);
    my ($output,$flag,$edr,$sysname);

    my $cfg = Obj::cfg();
    $vcs = $prod->prod('VCS61');
    $prod->SUPER::poststart_sys($sys);
    return unless (Cfg::opt('configure') && !$cfg->{donotreconfigurevcs});
    if ($sys->system1) {
	# Before run installer -m master, stop the VCS on rest nodes.
        for my $system (@{CPIC::get('systems')}) {
            next if $system->system1;
            my $i = 0 ;
            while($i < $prod->{retry_times}*5) {
                $system->cmd("_cmd_hastop -local 2>/dev/null");
                my $had = $system->proc('had61');
                last if (!$had->check_sys($system,'start'));
                $i++;
            }
            if ($i >= $prod->{retry_times}*5) {
                Msg::log("Stop VCS failed on $system->{sys}.");
		$edr->{$prod->{fatal_error_key}} = 1;
		return 0
            }
        }

        Msg::n();
        $msg = Msg::new("Starting service groups");
        $msg->left();
        $sys->cmd("$prod->{installerdir}/installer -m master 2>/dev/null");
        $prod->configure_kdump_sys($sys);
        $msg->right_done();
        $syslist = CPIC::get('systems');
        $prod->copy_conf_to_othernodes($sys,$syslist);
        EDRu::create_flag('snas_configure_done');
    } else {
        EDRu::wait_for_flag('snas_configure_done');
        $msg = Msg::new("Node $sys->{newhostname}( $sys->{sys} ) is joining the cluster");
        $msg->left();
        $sys->cmd("$prod->{installerdir}/installer -m join 2>/dev/null");
        $prod->configure_kdump_sys($sys);

        $output = $prod->start_vcs_proc_sys($sys);
        if (!$output) {
            $edr->{$prod->{fatal_error_key}} = 1;
            return 0;
        }
        $output = $prod->check_vcs_status($sys);
        if(!$output) {
            Msg::log("restart VCS failed");
            $edr->{$prod->{fatal_error_key}} = 1;
            return 0;
        }
        $msg->right_done();
    }
    return;
}

sub copy_conf_to_othernodes {
    my ($prod,$sys,$syslist) = @_;
    my ($filepath,$tmptarfile,$sysobj);

    $filepath = $prod->{nicconf}->{filepath};
    $tmptarfile = "$filepath/conf.tar";
    $sys->cmd("cd $filepath; _cmd_tar --exclude=\"version.conf\" -cvf $tmptarfile *");
    
    for my $system (@{$syslist}) {
        next if ($system->{sys} eq $sys->{sys});
        $sys->copy_to_sys($system,$tmptarfile);
        $system->cmd("cd $filepath; _cmd_tar -xvf $tmptarfile && _cmd_rmr $tmptarfile 2>/dev/null");
        # Also copy /etc/hosts file to other node
        $sys->copy_to_sys($system,$prod->{hostsfile});
        $sys->copy_to_sys($system,$prod->{knownhosts});
        $sys->copy_to_sys($system,$prod->{authkeys});
    }
    $sys->cmd("cd $filepath; _cmd_rmr $tmptarfile 2>/dev/null");
    return;
}

sub addnode_messages {
    my $prod = shift;
    my $pdfrs=Msg::get('pdfrs');
    my($msg);
    my $cprod=CPIC::get('prod');
    $prod = $prod->prod($cprod);

    # display messages
    $msg = Msg::new("The following prerequisites are required to add a node to the cluster:\n");
    $msg->print;
    $msg = Msg::new("\t* $prod->{abbr} must be running on the cluster to which you want to add a node\n");
    $msg->print;
    $msg = Msg::new("Refer to the $prod->{abbr} Installation Guide for more details\n");
    $msg->print; 
    Msg::prtc();
    return;
}

sub addnode_get_cluster {
    my $prod = shift;
    my $cfg = Obj::cfg();
    my $rel = Obj::rel();

    # Check cluster status in VCS level
    $prod->perform_task('addnode_get_cluster');
    $cfg->{snas_clustername} ||= $cfg->{vcs_clustername};

    $prod->check_bond_exclusion();
}

sub check_bond_exclusion {
    my $prod = shift;
    my ($sysi,$sys0,$padv,$ethall);

    my $cfg = Obj::cfg();
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
    $padv=$sys0->padv;
    $ethall=$padv->get_all_nic_sys($sys0);
    if (grep {$_ !~ /^($prod->{privnic_prefix}|$prod->{pubnic_prefix})/} @$ethall) {
        $prod->{has_bond_exclusion} = 1;
    }
    return;
}

sub addnode_get_newnode {
    my $prod = shift;
    my ($conf,$sys,@syslist,@sysilist,@faillist,@newnodes,@clustersys,@allnodes,$rtn,$msg,$com_fail_nodes);

    my $edr = Obj::edr();
    my $cpic= Obj::cpic();
    my $cfg = Obj::cfg();
    my $rel = Obj::rel();
    my $vcs = $prod->prod('VCS61');
    
    # Use default password to establish transport with new nodes
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
        if (!$edr->transport_sys($sys)) {
            $conf->{$sysi}{transport_setup_method} = 'ssh';
            $conf->{$sysi}{transport_setup_passwd} = 'root123';
            push (@syslist, $sys);
            push (@sysilist, $sysi);
        }
        push (@newnodes, $sys);
    }
    if (@syslist) {
        $rtn = $edr->setup_transports(\@syslist, $conf);
    } else {
        $rtn = 1;
    }
    unless ($rtn) {
        for my $sysi (@{$edr->{transport_failed_sys}}) {
            $sys = Obj::sys($sysi);
            push (@faillist, $sys);
        }
        $rtn=$edr->ask_com_setup(\@faillist);
        if ($rtn == -1) {
            $com_fail_nodes = join ' ', $edr->{transport_failed_sys};
            $msg = Msg::new("Failed to set up $edr->{transport_setup_method} connection with the remote system(s) $com_fail_nodes.");
            $msg->die();
        }
    }
    # ET3597818,transport_sys for nodes which were failed in this step
    # before to make sure the tmpdir is created in the new node
    for my $sysi (@sysilist) {
        delete $Obj::pool{"Sys::$sysi"};
        $sys = Sys->new($sysi);
        $edr->transport_sys($sys);
    }

    # ET3629764, avoid user to add nodes which are already in the cluster
    for my $newsys (@newnodes) {
        $conf = $vcs->get_config_sys($newsys);
        if($conf) {
            $msg = Msg::new("System $newsys->{sys} is already a member of the cluster $conf->{clustername}");
            $msg->error();
            $rel->update_status_file("ADD",'',$cfg->{newnodes},"FAILED");
            $cpic->edr_completion();
        }
    }

    for my $sysi (@{$cfg->{clustersystems}}) {
        $sys = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
        push(@clustersys, $sys);
    }
    push (@allnodes, @clustersys, @newnodes);
    $prod->ssh_com_setup(\@allnodes);
    $cpic->{systems} = $edr->init_sys_objects();
    $edr->{systems} = $cpic->{systems};
    $prod->reinstall_newnodes();

    $rel->update_status_file("ADD","Configure new node(s) network",$cfg->{newnodes});
    # To compare with the nic status of new node(s) in later step
    $prod->cluster_nic_status();
    # To get the ip availability status in the cluster
    # and also DNS & Gateway status
    $prod->cluster_net_status();

    $prod->phase_detect_nic();
    if ($prod->{has_bond_exclusion}) {
        $rtn = $prod->init_bondpool_val();
        if ($rtn == 2) {
            $rel->update_status_file("ADD",'',$cfg->{newnodes},"FAILED");
            $cpic->edr_completion();
        }

        $prod->bond_adapter_post();
    } else {
        $rtn = $prod->proc_nic_val(); 
        if ($rtn == 2) {
            $msg = Msg::new("NIC detection error. Double check the environment.");
            $msg->error();
            $rel->update_status_file("ADD",'',$cfg->{newnodes},"FAILED");
            $cpic->edr_completion();
        }
    }
    $prod->phase_detect_ip();
}

sub reinstall_newnodes {
    my ($prod) = @_;
    my ($repository_path, $base_version, $mr_version, $hf_version, $base_path, $mr_path, $hf_path);
    my ($basecmd, $hfcmd, $cmd, $msg);
    my $tmpdir = EDR::get('tmpdir');
    my $resfile = "$tmpdir/addnode_install.res";
    my $localsys = Obj::edr()->{localsys};
    my $response;
    my $syslist = CPIC::get('systems');
    my $cfg = Obj::cfg();

    my @subs;
    my $cpic = Obj::cpic();
    my $rel = $cpic->rel();
    $rel->update_status_file("ADD","Uninstall packages on new node(s)",$cfg->{newnodes});
    Cfg::set_opt('uninstall');
    @subs = qw(set_pkgs shutdown uninstall);
    $cpic->run_subs(@subs);
    Cfg::unset_opt('uninstall');
    for my $sys (@{$cpic->{systems}}) {
        undef $sys->{pkgvers};
        undef $sys->{uninstallpkgs};
        undef $sys->{uninstallpatches};
        delete $sys->{donotquerykeys};
        delete $sys->{keys};
        $sys->set_value('stop_checks', 0);
    }

    $rel->update_status_file("ADD","Install packages on new node(s)",$cfg->{newnodes});
    $prod->read_preference_file_sys($localsys);
    $repository_path = $prod->get_repository_on_sys($localsys);

    if ($localsys->{store_release_imgs}{"InstalledBase"}) {
        $base_version = $localsys->{store_release_imgs}{"InstalledBase"};
        $base_path = "$repository_path/ga/images/SSNAS/$base_version";
        if (!$prod->img_stored_on_sys($localsys, $base_path)) {
            $msg = Msg::new("SNAS $base_version is not stored on $localsys->{sys}, cannot install SNAS $base_version on the new nodes");
            $msg->die();
        }
    }
    if ($localsys->{store_release_imgs}{"InstalledMR"}) {
        $mr_version = $localsys->{store_release_imgs}{"InstalledMR"};
        $mr_path = "$repository_path/patch/images/SSNAS/$mr_version";
        if (!$prod->img_stored_on_sys($localsys, $mr_path)) {
            $msg = Msg::new("SNAS $mr_version is not stored on $localsys->{sys}, cannot install SNAS $mr_version on the new nodes");
            $msg->die();
        }
    }
    if ($localsys->{store_release_imgs}{"InstalledHF"}) {
        $hf_version = $localsys->{store_release_imgs}{"InstalledHF"};
        $hf_path = "$repository_path/hf/images/SSNAS/$hf_version";
        if (!$prod->img_stored_on_sys($localsys, $hf_path)) {
            $msg = Msg::new("SNAS $hf_version is not stored on $localsys->{sys}, cannot install SNAS $hf_version on the new nodes");
            $msg->die();
        }
    }

    if ($mr_version) {
        if ($base_version) {
            $response->{opt}{base_path} = $base_path;
        }
        if ($hf_version) {
            $response->{opt}{hotfix_path} = $hf_path;
        }
        $cmd = "$mr_path/installmr";
    } elsif ($base_version) {
        if ($hf_version) {
            $response->{opt}{hotfix_path} = $hf_path;
        }
        $cmd = "$base_path/installsnas";
    } else {
        Msg::die("No base or Maintenance release installed on $localsys->{sys}");
    }

    $prod->create_install_response($response, $resfile);

    $cmd .= " -responsefile $resfile";

    Msg::log("\nExecuting the following command to start installation of SNAS on $localsys->{sys}:\n\n\t$cmd\n");

    my $ret = system($cmd);
    my $localversion = $prod->version_sys($localsys);
    if ($ret != 0) {
        $msg = Msg::new("Failed to install SNAS $localsys->{sys} on the new nodes");
        $msg->die();
    } else {
        $msg = Msg::new("Installation of SNAS $localsys->{sys} on the new nodes was successful");
        $msg->print();
    }
}

sub cluster_nic_status {
    my $prod = shift;
    my ($sysi,$sys0,$padv,$ethall,$nprivnics,$npubnics);

    my $cfg = Obj::cfg();
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
    $padv = $sys0->padv;
    $ethall=$padv->get_all_nic_sys($sys0);

    $nprivnics = grep /^$prod->{privnic_prefix}/,@$ethall;
    $npubnics = scalar(@$ethall) - $nprivnics;
    $sys0->set_value('npublicnics',$npubnics);
    $sys0->set_value('nprivenics',$nprivnics);
}

sub cluster_net_status {
    my ($prod) = @_;
    my ($sysi,$sys0,$padv,@usedpip,@usedvip,$output,@freeip,$pipstart,$vipstart,$msg,$err);

    my $cpic = Obj::cpic();
    my $rel = Obj::rel();
    my $cfg = Obj::cfg();
    $err = 0;
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = ($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);

    # cluster DNS & gateway
    $padv=$sys0->padv;
    $cfg->{snas_defgateway} = $padv->get_gateway_sys($sys0,$prod->{netproto});
    $cfg->{snas_dnsip} = $padv->get_dns_sys($sys0);
    $cfg->{snas_dnsdomainname} = $padv->get_domain_sys($sys0);

    $output = $sys0->cmd("_cmd_cat $prod->{nicconf}{physicalipfile} 2>/dev/null | _cmd_awk '{if(NF==4) print \$1}'");
    @usedpip = split (/\n/,$output);
    $output = $sys0->cmd("_cmd_cat $prod->{nicconf}{vipfile} | _cmd_awk '{if(NF==2) print \$1}'");
    @usedvip = split (/\n/,$output);
    $output = $sys0->cmd("_cmd_awk '{if(NF==2)print \$1}' $prod->{nicconf}{privateipfile} 2>/dev/null");
    @freeip = split (/\n/,$output);
    $prod->{priviparr} = \@freeip;
    
    # Find usable ip from the last ip been used & configured in the conf file
    # Used by handler_check_ip in later steps to detect IP availability for new nodes
    $output = $sys0->cmd("_cmd_cat $prod->{nicconf}->{nasinstallconf} 2>/dev/null");
    if ($output =~ /^PIPSTART.*=.*"(.*)"/m) {
        $pipstart = $1;
        while (EDRu::inarr($pipstart,@usedpip)) {
            $pipstart = $prod->get_next_ip($pipstart,1);
        }
        $cfg->{snas_pipstart} = $pipstart;
    } else {
        $err = 1;
    }
    if ($output =~ /^VIPSTART.*=.*"(.*)"/m) {
        $vipstart = $1;
        while (EDRu::inarr($vipstart,@usedvip)) {
            $vipstart = $prod->get_next_ip($vipstart,1);
        }
        $cfg->{snas_vipstart} = $vipstart;
    } else {
        $err = 1;
    }
    if ($output =~ /^PIPMASK.*=.*"(.*)"/m) {
        $cfg->{snas_pnmaskstart} = $1;
    } else {
        $err = 1;
    }
    if ($output =~ /^VIPMASK.*=.*"(.*)"/m) {
        $cfg->{snas_vnmaskstart} = $1;
    } else {
        $err = 1;
    }

    if ($err) {
        $msg .= Msg::new("Errors in the configuration file $prod->{nicconf}->{nasinstallconf}. Following items must be configured in $prod->{nicconf}->{nasinstallconf}:\n\tPIPSTART,PIPMASK,VIPSTART,VIPMASK\n");
        $msg->error();
        $rel->update_status_file("ADD",'',$cfg->{newnodes},"FAILED");
        $cpic->edr_completion();
    }
    return;
}

sub addnode_compare_systems {
    my $prod = shift;
    my ($rtn,$sysi,$sys0,$msg);

    my $cfg = Obj::cfg();
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = Obj::sys($sysi);

#    $rtn = $prod->nicnum_consistency_check($sys0);
#    if ($rtn) {
#        $msg = Msg::new("Make sure the new node has the same public and private NIC devices as the other systems in the cluster");
#        $msg->error();
#    }
    $prod->perform_task('addnode_compare_systems');
}

sub nicnum_consistency_check {
    my ($prod,$sys) = @_;
    my ($npubnics,$nprivnics);

    my $cpic = Obj::cpic();
    # For add node to init the required pub/priv nics number
    if ($sys) {
        $npubnics = $sys->{npublicnics};
        $nprivnics = $sys->{nprivenics};
        return 2 unless ($npubnics && $nprivnics);
    }
    # For install
    for my $sys (@{$cpic->{systems}}) {
        unless ($npubnics && $nprivnics) {
            $npubnics = $sys->{npublicnics};
            $nprivnics = $sys->{nprivenics};
            next;
        }
        next if (($npubnics == $sys->{npublicnics}) &&
                    ($nprivnics == $sys->{nprivenics}));
        # Return error if the pub/priv nics don't equal to that in other nodes
        return 1;
    }
    return 0;
}

sub privnics_link_status_sys {
    my ($prod,$sys,$privnic_maclist) = @_;
    my ($sysi,$sys0,@privniclist,$output,@pidarr,$pid,$rtn,$padv,$msg,$mac);

    my $cfg = Obj::cfg();
    @pidarr = ();
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = Obj::sys($sysi);
    if (!$privnic_maclist) {
        $prod->get_privnics_mac_sys($sys0);
        $privnic_maclist = $sys0->{privnicmac};
    }

    for my $nic (@{$privnic_maclist}) {
        # start dlpiping server in the master node
        $output = $sys0->cmd("_cmd_dlpiping -s $nic 2>/dev/null &");
        (undef,$pid)=split(/\s+/,$output);
        push(@pidarr, $pid);
    }

    @privniclist = $sys->{unpingnics};
    for my $nic (keys %{$privnic_maclist}) {
        $mac = $privnic_maclist->{$nic};
        for my $privnic (@privniclist) {
            next if (defined $sys->{privnic_newname}{$privnic});
            $sys->cmd("_cmd_ifconfig $privnic up; _cmd_sleep 2");
            # Utilize dlpiping client to detect the private nic connection status
            $rtn = $sys->cmd("_cmd_dlpiping -t5 -c $privnic $mac 2>/dev/null");
            unless ($rtn) {
                # Need to update publicnics/privenics
                $sys->{privnic_newname}{$privnic} = $nic;
                last;
            }
        }
    }

    $padv = $sys0->padv;
    @pidarr = $padv->kill_pids_sys($sys0,@pidarr);
    if (@pidarr) {
        $output = join(' ', @pidarr);
        $msg = Msg::log("Some dlpiping server processes are failed to kill: $output");
    }
}

sub get_privnics_mac_sys {
    my ($prod,$sys) = @_;
    my ($output,$privnicpre,@privnic,$mac,$padv);

    $padv=$sys->padv;
    $privnicpre = $prod->{privnic_prefix};
    $output = $sys->cmd("_cmd_ip link show 2>/dev/null | _cmd_awk -F': ' '/^[0-9]*: $privnicpre/ {print \$2}'");
    @privnic = split (/\n/, $output);
    for my $nic (@privnic) {
        $mac = $padv->get_mac_by_nic_sys($sys,$nic);
        $sys->{privnicmac}{$nic} = $mac;
    }
}

sub addnode_preconfig_newnode {
    my $prod = shift;
    my ($msg);

    for my $sys(@{CPIC::get('systems')}) {
        $prod->copy_crontab_sys($sys);
    }
    $prod->buildup_config_info();
    $prod->phase_config_nic_ip_hostname();
    $prod->write_nasinstallconf();
    # restart NICs solution(without system rebooting) to 
    # enable the nic renaming & ip re-assignment
    $prod->handler_restart_network();
    # init lltlink* and lltlinklowpri* based on the config of the cluster
    $prod->init_llt_nic_conf();
    for my $sys(@{CPIC::get('systems')}) {
        $sys->cmd("_cmd_service iptables stop 2>/dev/null");
        $prod->update_deleted_node_list($sys);
        $msg = Msg::new("Node $sys->{newhostname}( $sys->{sys} ) is joining the cluster");
        $msg->left;
        $sys->cmd("$prod->{installerdir}/installer -m join 2>/dev/null");
        $prod->configure_kdump_sys($sys);
        $msg->right_done;
    }
}

sub addnode_config_snas {
    my $prod = shift;
    my ($sys0);

    my $cfg = Obj::cfg();
    $sys0 = Obj::sys(@{$cfg->{clustersystems}}[0]);
    for my $sys(@{CPIC::get('systems')}) {
        $sys0->cmd("$prod->{storscriptsdir}/iscsiinitconfig.sh addnode $sys->{sys} $sys->{newhostname}");
        $sys->cmd("_cmd_vxddladm set namingscheme=ebn persistence=yes");
        # FIXME: Need confirm if it's needed, as existing addnode can do scan disks already
        #$sys->cmd("$prod->{storscriptsdir}/scanbus.sh  2>/dev/null");
    }
}

sub addnode_init_new_hostname {
    my $prod = shift;
    my ($sysi,$sys0,$sys,$clusname,@used_nids,$n,$hostid);

    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = Obj::sys($sysi);
    $clusname = $sys0->{vcs_conf}{clustername};
    if (!$clusname) {
        $clusname = $sys0->cmd("_cmd_grep '^cluster' $vcs->{maincf} 2> /dev/null | _cmd_awk '{print \$2}'");
    }
    
    $n = 0;
    @used_nids = split(/\n/, $sys0->cmd("_cmd_cat $vcs->{llthosts} | _cmd_awk '! /^[ \t]\$/ {print \$1}' 2>/dev/null"));
    for my $system (@{$cfg->{newnodes}}) {
        while (EDRu::inarr($n, @used_nids)) {
            $n++;
        }
        $sys = Obj::sys($system);
        $hostid = $n + 1;
        if ($hostid < 10) {
            $sys->{newhostname} = $clusname."_0".$hostid;
        } else {
            $sys->{newhostname} = $clusname."_".$hostid;
        }
        push (@used_nids, $n);
        $n++;
    }
    return;
}

sub addnode_write_config_files_sys {
    my ($prod,$sys) = @_;
    my $cfg = Obj::cfg();

    my @physicaliparr =@{$prod->{physicaliparr}};
    my @privateiparr = @{$prod->{privateiparr}};
    my @viparr = @{$prod->{viparr}};
    my @iphostsarr = @{$prod->{iphostsarr}};

    $sys->mkdir($prod->{nicconf}->{filepath});
    $prod->set_physicalipfile_sys($sys,@physicaliparr);
    $prod->set_privateipfile_sys($sys,@privateiparr);
    $prod->set_vipfile_sys($sys,@viparr);
    $prod->set_pci_exclusionfile_sys($sys);
    $prod->set_globalroutesfile_sys($sys);
    $prod->update_hosts_file_sys($sys,@iphostsarr);

    return 1;
}

sub init_llt_nic_conf {
    my ($prod) = shift;
    my ($conf,$sysi,$sys0,$n,$sys);

    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $sysi = @{$cfg->{clustersystems}}[0];
    $sys0 = Obj::sys($sysi);
    $conf = $vcs->get_config_sys($sys0);
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $n = 1;
        while (defined $conf->{"lltlink$n"}{$sys0->{sys}}) {
            $cfg->{"vcs_lltlink$n"}{$sysi} = $conf->{"lltlink$n"}{$sys0->{sys}};
            $n++;
        }
        $n = 1;
        while (defined $conf->{"lltlinklowpri$n"}{$sys0->{sys}}) {
            $cfg->{"vcs_lltlinklowpri$n"}{$sysi} = $conf->{"lltlinklowpri$n"}{$sys0->{sys}};
            $n++;
        }
    }
    return;
}

sub addnode_configure_cluster {
    my ($prod) = shift;
    $prod->perform_task('addnode_configure_cluster');
}

sub addnode_poststart {
    my ($prod) = shift;
    my $sfcfsha = $prod->prod('SFCFSHA61');
    my $cfg = Obj::cfg();
    my $rel = Obj::rel();
    $rel->update_status_file("ADD","Configure service on new node(s)",$cfg->{newnodes});
    $prod->addnode_config_groups();
    $sfcfsha->addnode_poststart();
    $prod->addnode_online_groups();
    $prod->addnode_to_nproc();
    $prod->update_ftp_cfg();
    $prod->enable_snas_services();
    $prod->addnode_config_cifs();
    $prod->create_disk_info_file();
    $prod->set_tunables();
    $prod->dmp_exclude_local_disk();
    $prod->config_gui();
    return;
}

# Need to do it in dependency order
sub addnode_config_groups {
    my ($prod) = shift;
    my ($sys0,$conf,$allsg,$sys);

    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    $conf = $vcs->get_config_sys($sys0);
    $allsg = $conf->{groups};

    $vcs->haconf_makerw();
    for my $sysi (@{$cfg->{newnodes}}) {
        $prod->{cfg_sg} = ();
        $sys = Prod::VCS61::Common::transform_system_name($sysi);
        $prod->addnode_config_group($allsg, $sys);
    }
    $vcs->haconf_dumpmakero();
    delete($prod->{cfg_sg});
    return;
}

sub addnode_config_group {
    my ($prod,$sgs,$sysname) = @_;
    my ($sys0,$depsgs,@depsgarr,$rtn,$max_pri);

    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);

    for my $sg(@{$sgs}) {
        next if (defined $prod->{cfg_sg}{$sg});
        $depsgs = $sys0->cmd("$vcs->{bindir}/hagrp -dep $sg 2>/dev/null | _cmd_grep '^$sg' | _cmd_awk '{print \$2}' | _cmd_uniq");
        if ($depsgs) {
            @depsgarr = split(/\s+/, $depsgs);
            @depsgarr = @{EDRu::arrdel(\@depsgarr, $sg)};
            $prod->addnode_config_group(\@depsgarr,$sysname);
        }
        $max_pri = $vcs->get_sg_max_priority($sg);
        $max_pri+=1;
        $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -modify $sg SystemList -add $sysname $max_pri");
        if(EDRu::isverror($rtn)) {
            Msg::log("Modify $sg SystemList to add $sysname failed.");
        }

        $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -value $sg Enabled");
        $sys0->cmd("$vcs->{bindir}/hagrp -disable $sg -sys $sysname") unless ($rtn);

        $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -value $sg AutoStartList");
        if ($rtn) {
            $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -modify $sg AutoStartList -add $sysname");
            if (EDRu::isverror($rtn)) {
                Msg::log("Modify $sg AutoStartList to add $sysname failed");
            }
        }

        $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -value $sg PreOnline");
        if ($rtn == 1) {
            $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -modify $sg PreOnline 1 -sys $sysname");
        }
        $prod->{cfg_sg}{$sg} = 1;
    }
}

sub addnode_online_groups {
    my ($prod) = shift;
    my ($sys0,$conf,$allsg,$sys,$msg,$rtn);

    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    $conf = $vcs->get_config_sys($sys0);
    $allsg = $conf->{groups};

    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Prod::VCS61::Common::transform_system_name($sysi);
        $msg = Msg::new("Online service groups on $sys");
        $msg->left();
        $rtn = $prod->addnode_online_group($allsg, $sys);
        if ($rtn) {
            Msg::right_done();
        } else {
            Msg::right_failed();
        }
    }    
    return;
}

sub addnode_online_group {
    my ($prod,$sgs,$sysname) = @_;
    my ($sys0,$rtn,$status);

    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $status = 1;
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);

    for my $sg(@{$sgs}) {
        $rtn = $sys0->cmd("_cmd_hagrp -value $sg Parallel 2>/dev/null");
        next unless ($rtn);
        $rtn = $sys0->cmd("_cmd_hagrp -state $sg -sys $sys0->{vcs_sysname} 2>/dev/null");
        next if ($rtn !~ /ONLINE/);
        $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -online -propagate $sg -sys $sysname");
        if (EDRu::isverror($rtn)) {
            Msg::log("Make $sg online failed on $sysname");
            $status = 0;
            next;
        }
        $rtn = $sys0->cmd("$vcs->{bindir}/hagrp -wait $sg State ONLINE -sys $sysname -time 120");
        if (EDRu::isverror($rtn)||EDR::cmdexit()) {
            Msg::log("Waiting for $sg state online failed on $sysname");
            $status = 0;
        }
    }
    return $status;
}

sub addnode_to_nproc {
    my $prod = shift;
    my ($sys0,$sys,$hostname,$newhost,$res,@reslist,$global,$nfsdcnt);
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');

    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    $hostname = $vcs->get_vcs_sysname_sys($sys0);
    $res = $sys0->cmd("_cmd_hares -list Type=NFS 2>/dev/null | _cmd_awk '{print \$1}' | _cmd_sort -u");
    $vcs->haconf_makerw();
    for my $line (split(/\n/, $res)) {
        $global = $sys0->cmd("_cmd_hares -display $line 2>/dev/null | _cmd_awk '/Nproc/ {print \$3}'");
        next if ($global eq 'global');
        $nfsdcnt = $sys0->cmd("_cmd_hares -value $line Nproc $hostname 2>/dev/null");
        for my $sysi(@{$cfg->{newnodes}}) {
            $sys = Obj::sys($sysi);
            $newhost = $vcs->get_vcs_sysname_sys($sys);
            $sys0->cmd("_cmd_hares -modify $line Nproc $nfsdcnt -sys $newhost");
        }
    }
    $vcs->haconf_dumpmakero();
    return;
}

sub update_ftp_cfg {
    my $prod = shift;
    my ($sys0);
    my $cfg = Obj::cfg();

    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys0->cmd("$prod->{scriptsdir}/ftp/ftpconfig.sh addnode \"$sysi\"");
    }
    return;
}

sub enable_snas_services {
    my $prod = shift;
    my ($sys);
    my $cfg = Obj::cfg();
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $sys->cmd("$prod->{scriptsdir}/misc/nas_services.sh enable");
    }
    return;
}

sub addnode_config_cifs {
    my $prod = shift;
    my ($sys0,$ctdblog,$sys);

    my $cfg = Obj::cfg();
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    $sys0->cmd("/bin/bash -c \". $prod->{libscriptsdir}/ctdb_lib.sh; ctdb_create_private_ip_file\"");

    $ctdblog = "$prod->{logdir}/ctdb.log";
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $sys->mkdir("/var/ctdb");
        $sys->mkdir("/var/ctdb/state");
        $sys->cmd("/bin/bash -c \". $prod->{libscriptsdir}/cifs_lib.sh; gen_smb_conf >> $ctdblog 2>>$ctdblog\"");
    }
    return;
}

sub create_disk_info_file {
    my $prod = shift;
    my $sys;
    my $cfg = Obj::cfg();
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $sys->cmd("$prod->{storscriptsdir}/create_disks_info.sh");
        $sys->cmd("/usr/bin/at -f $prod->{scriptsdir}/report/event_notify.sh now");
    }
    $prod->update_dedup_nodes();
    return;
}

sub set_tunables {
    my $prod = shift;
    my ($sys0,$dmppolicy,$sys);

    my $cfg = Obj::cfg();
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    $dmppolicy = "/etc/vx/dmppolicy.info";
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $sys0->copy_to_sys($sys,$dmppolicy);
        $sys0->cmd("$prod->{sysscriptsdir}/optionconfig.sh nodeadd $sys->{newhostname}");
    }
    return;
}

sub dmp_exclude_local_disk {
    my $prod = shift;
    my ($sys,$disks,$msg);
    
    my $cfg = Obj::cfg();
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $disks = $sys->cmd(". $prod->{nicconf}->{nasinstallconf}; _cmd_vxdmpadm list dmpnode 2>/dev/null | _cmd_grep -w \$ROOTDEVICE | _cmd_grep path | _cmd_awk '{print \$7}'");
        if ($disks) {
            $sys->cmd("_cmd_vxdmpadm exclude ctlr=$disks");
            $msg = Msg::new("Exclude local disk controller $disks on $sysi....");
            $msg->print();
        }
    }
    return;
}

sub config_gui {
    my $prod = shift;
    my ($sys0,$sys);
    my $cfg = Obj::cfg();
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    for my $sysi(@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $sys0->cmd("$prod->{guiscriptsdir}/webservice.sh addnode $sys->{newhostname}");
        $sys0->cmd("$prod->{guiscriptsdir}/rrdtool.pl addnode $sys->{newhostname}");
    }
    return;
}

sub copy_crontab_sys {
    my ($prod,$sys) = @_;
    my ($sys0,$output,@consarr,@tmpfilearr,$curr_cons,$curr_tmpfile);

    my $cfg = Obj::cfg();
    push(@consarr, "dst_policy.sh enforce");
    push(@consarr, "autosnap_policy.sh create");
    push(@tmpfilearr, "/tmp/local_cron.txt");
    push(@tmpfilearr, "/tmp/local_autosnap.txt");
    $sys0 = Obj::sys(${$cfg->{clustersystems}}[0]);
    
    for my $n (0..1) {
        $curr_cons = @consarr[$n];
        $curr_tmpfile = @tmpfilearr[$n];
        $output = $sys0->cmd("_cmd_crontab -l 2>/dev/null | _cmd_grep -v '^#' | _cmd_grep '$curr_cons'");
        $sys->cmd("_cmd_crontab -l 2>/dev/null | _cmd_grep -v '^#' | _cmd_grep -v '$curr_cons' > $curr_tmpfile");
        $sys->appendfile($output,$curr_tmpfile);
        $sys->cmd("_cmd_crontab $curr_tmpfile >/dev/null 2>&1");
    }
    return;
}

sub perform_task {
    my ($prod,$task) = @_;

    my $vcs = $prod->prod('VCS61');
    $vcs->$task() if($vcs->can($task));
    return;
}

sub install_thirdparty_pkgs_sys {
    my ($prod,$sys,$thirdpartypkgs_aref) = (@_);
    my ($cpic,$iof,$pkg,$ret,$third_party_rpm_dir,$tmpdir);
    $cpic = Obj::cpic();
    $third_party_rpm_dir = $prod->{third_party_rpm_dir};
    $tmpdir=EDR::tmpdir();

    Msg::log("Installing third party rpms on $sys->{sys}");
    if (!-d "$cpic->{mediapath}/$third_party_rpm_dir") {
        Msg::log("No $third_party_rpm_dir dir exists, do not install the third party rpms");
        return;
    }
    my $pkgpath = "$cpic->{mediapath}/$third_party_rpm_dir";
    for my $pkg_ver(@$thirdpartypkgs_aref) {
        my ($pkgi,$ver) = split(/\s+/, $pkg_ver);
        $pkg=Pkg::new_pkg('Pkg', $pkgi, $sys->{padv});
        $pkg->{file} = $sys->padv->media_pkg_file($pkg, $pkgpath);
        if (!$pkg->{file}) {
            Msg::log("No $pkg->{pkg} exists, error ...");
            return 0;
        }
        $pkg->copy_sys($sys);
        $iof=EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg});
        my $rpm = ($sys->{islocal}) ? $pkg->{file} : "$tmpdir/". EDRu::basename($pkg->{file});
        $sys->cmd("_cmd_rpm -U -v --nodeps $rpm 2>$iof 1>&2");
        $ret = EDR::cmdexit();
    
        $pkg->remove_sys($sys);
        $sys->copy_to_sys($cpic->localsys,$iof) unless ($sys->{islocal});
        return 0 if ($ret);
    }

    return 1;
}

sub upgrade_postinstall_sys {
    my ($prod,$sys) = (@_);

    if (Cfg::opt('rolling_upgrade')) {
	$sys->set_value('zru_supported', 1);
    }

    if ($sys->{store_release_imgs}{base_img}) {
        $prod->copy_img_to_sys($sys, 'base');
        delete $sys->{store_release_imgs}{base_img};
    }
    if ($sys->{store_release_imgs}{mr_img}) {
        $prod->copy_img_to_sys($sys, 'mr');
        delete $sys->{store_release_imgs}{mr_img};
    }
    if ($sys->{store_release_imgs}{hf_img}) {
        $prod->copy_img_to_sys($sys, 'hf');
        delete $sys->{store_release_imgs}{hf_img};
    }
    #$prod->del_obsoloted_img_sys($sys);
    $prod->update_preference_file_sys($sys) unless(Cfg::opt('upgrade_kernelpkgs'));
    $prod->update_version_conf_sys($sys);
    $prod->update_nbu_latest_dir_sys($sys);
}

sub postinstall_sys {
    my ($prod,$sys) = (@_);
    my (@files,$cpic,$third_party_rpm_dir);
    $cpic = Obj::cpic();

    if ($sys->{store_release_imgs}{base_img}) {
        $prod->copy_img_to_sys($sys, 'base');
        delete $sys->{store_release_imgs}{base_img};
    }
    if ($sys->{store_release_imgs}{mr_img}) {
        $prod->copy_img_to_sys($sys, 'mr');
        delete $sys->{store_release_imgs}{mr_img};
    }
    if ($sys->{store_release_imgs}{hf_img}) {
        $prod->copy_img_to_sys($sys, 'hf');
        delete $sys->{store_release_imgs}{hf_img};
    }
    #$prod->del_obsoloted_img_sys($sys);
    $prod->update_preference_file_sys($sys);
    $prod->update_nbu_latest_dir_sys($sys);
    $sys->cmd("_cmd_rm -f $prod->{version_conf}");
    $prod->update_version_conf_sys($sys);

    $third_party_rpm_dir = $prod->{third_party_rpm_dir};

    Msg::log("Copying gui jar files and tar files on $sys->{sys}");
    if (!-d "$cpic->{mediapath}/$third_party_rpm_dir") {
        Msg::log("No $third_party_rpm_dir dir exists, do not copy the gui tar files");
        return;
    }
    $sys->mkdir($prod->{gui_lib_dir});
    $sys->mkdir($prod->{gui_install_dir});
    @files = glob("$cpic->{mediapath}/$third_party_rpm_dir/*");
    for my $file(@files) {
        if ($file =~ /\.jar/m) {
            $prod->localsys->copy_to_sys($sys,$file,$prod->{gui_lib_dir});
        } elsif ($file =~ /\.tar/m) {
            Msg::log("Copying $file to $prod->{gui_install_dir}");
            $prod->localsys->copy_to_sys($sys,$file,$prod->{gui_install_dir});
        }
    }

    $prod->perform_task_sys($sys,'postinstall_sys');
    return;
}

# set up passwordless communication for root between the systems
sub ssh_com_setup {
    my ($prod, $systems_aref) = (@_);
    my (@systems,@keyfiles,$homedir);
    my ($authorized_keys_file,$keyfile,$keyfile_public,$knownhosts,$ssh_dir,$sshkey,$sshkeys,$user,$tmpkey);

    $homedir = '/root';
    $user = 'root';
    $ssh_dir = "$homedir/.ssh";
    $authorized_keys_file = "$ssh_dir/authorized_keys";
    @systems = @$systems_aref;
    @keyfiles=();
    $keyfile = Cfg::opt('keyfile');
    push(@keyfiles, $keyfile) if ($keyfile);
    push(@keyfiles, "$homedir/.ssh/id_rsa");
    push(@keyfiles, "$homedir/.ssh/id_dsa");

    $sshkeys = '';
    $knownhosts = '';
    for my $sys(@systems) {
        $sys->cmd("/etc/init.d/sshd start");

        $keyfile='';
        $keyfile_public='';
        for my $file (@keyfiles) {
            if ($sys->exists($file) && $sys->exists("$file".'.pub')) {
                $keyfile=$file;
                $keyfile_public="$file".'.pub';
                last;
            }
        }
        if (!$keyfile) {
            Msg::log("No existing ssh keyfile on $sys->{sys}, generate new keys");
            $keyfile="$homedir/.ssh/id_rsa";
            $keyfile_public=$keyfile.'.pub';
            $sys->cmd("_cmd_sshkeygen -q -t rsa -N \'\' -f $keyfile 2>/dev/null");
        }

        if ($sys->exists("$keyfile")) {
            $sshkey = $sys->readfile($keyfile_public);
            $sshkeys .= "$sshkey";
        }
        if ($sys->{newhostname}) {
            $knownhosts .= "$sys->{sys},$sys->{newhostname} ";
        } else {
            $knownhosts .= "$sys->{sys} ";
        }
    }

    for my $sys(@systems) {
        Msg::log("Adding all ssh keys to authorized_keys on $sys->{sys} and generate entries in known_hosts file");
        $sys->cmd("_cmd_mkdir -p $ssh_dir; _cmd_chmod 0700 $ssh_dir; _cmd_chown $user $ssh_dir");
        $tmpkey = $sys->readfile($authorized_keys_file);
        $tmpkey = $sshkeys.$tmpkey;
        $sys->writefile($tmpkey, $authorized_keys_file);
        $sys->cmd("_cmd_chmod 0600 $authorized_keys_file; _cmd_chown $user $authorized_keys_file; /sbin/restorecon -v $authorized_keys_file");
        $sys->cmd("_cmd_sshkeyscan -t rsa $knownhosts > $ssh_dir/known_hosts 2>/dev/null");
    }

    # set comsetup option so that it will not be cleaned up
    Cfg::set_opt('comsetup');

    return;
}
sub create_ru_responsefile {
    my ($prod, $response, $resfile) = @_;
    my ($rf,$cfg, $rel);
    $cfg = Obj::cfg();
    $rel = Obj::rel();
    my $syslist = $cfg->{systems};
    $response->{prod} = 'SNAS60';
    $response->{accepteula} = 1;
    $response->{reuse_config} = 1;
    $response->{opt}{rolling_upgrade} = 1;
    $response->{opt}{rollingupgrade_phase1} = 1;
    $response->{opt}{rollingupgrade_phase2} = 1;
    $response->{opt}{vfr} = 1;
    $response->{opt}{upgrade} = 1;
    $response->{ru_systems} = $syslist;

    my $upgrade_phase1_1=$rel->determine_ru_syslist($syslist);
    my $upgrade_phase1_2 = $syslist;
    $upgrade_phase1_2 = EDRu::arrdel($upgrade_phase1_2, @{$upgrade_phase1_1});
    $response->{phase1}{"0"} = $upgrade_phase1_1;
    $response->{phase1}{"1"} = $upgrade_phase1_2;
    $response->{systems} = $syslist;

    $rf="#\n# Configuration Values:\n#\nour \%CFG;\n\n".EDRu::hash2def($response, 'CFG')."\n1;\n";

    EDRu::writefile($rf, "$resfile");

    return 1;
}

sub create_install_response {
    my ($prod, $response, $resfile) = @_;
    my ($rf,$cfg);
    $cfg = Obj::cfg();
    $response->{accepteula} = 1;
    $response->{opt}{install} = 1;
    $response->{opt}{installallpkgs} = 1;
    $response->{opt}{noipc} = 1;
    $response->{opt}{updatekeys} = 1;
    $response->{opt}{vxkeyless} = 1;
    $response->{opt}{addnodeinstall} = 1;
    $response->{prod} = $prod->{prodi};
    $response->{systems} = $cfg->{newnodes};

    $rf="#\n# Configuration Values:\n#\nour \%CFG;\n\n".EDRu::hash2def($response, 'CFG')."\n1;\n";

    EDRu::writefile($rf, "$resfile");

    return 1;
}

sub create_trigger_link_sys {
    my ($prod,$sys) = @_;
    my (%trigger,$link,$cmd,$trigger_dir,$vcs);

    $vcs = $prod->prod('VCS61');
    $trigger_dir = "$vcs->{bindir}/triggers";
    %trigger = (
        'trigger_preonline' => 'preonline',
        'trigger_postoffline' => 'postoffline',
        'trigger_postonline.sh' => 'postonline',
        'trigger_resfault.sh' => 'resfault',
        'trigger_resstatechange.sh' => 'resstatechange',
        'trigger_sysoffline.sh' => 'sysoffline',
    );
    for my $tri (keys %trigger) {
        $link = $trigger{$tri};
        $cmd .= "_cmd_ln -sf $prod->{scriptsdir}/cluster/$tri $trigger_dir/$link;";
    }
    $sys->cmd($cmd);
    return;
}

sub delnode_precheck {
    my $prod = shift;
    my $rel = Obj::rel();
    my $cfg = Obj::cfg();
    $rel->update_status_file("DEL","Delete node(s) precheck",$cfg->{systems});
    $prod->perform_task('delnode_precheck');
    $prod->delnode_check_backup_job();
    $prod->delnode_check_dedup_job();
    $prod->delnode_umount_dedup_chkpnt();
}

sub delnode_check_quarantine_file {
    my $prod = shift;
    my ($output);

    my $cfg = Obj::cfg();
    for my $sys (CPIC::get('systems')) {
        #FIXME: In the script it specifically use root user to execute the command, need confirm if it's required
        $output = $sys->cmd("/opt/Symantec/symantec_antivirus/sav quarantine -l 2>/dev/null | wc -l");
    }
}

sub delnode_check_backup_job {
    my $prod = shift;
    my ($sys0,$bkupnode,$hostname,$msg,$ayn);

    my $edr = Obj::edr();
    my $rel = Obj::rel();
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    $sys0 = $edr->{localsys};
    $bkupnode = $sys0->cmd("_cmd_hagrp -state BackupGrp 2>/dev/null | _cmd_grep ONLINE | _cmd_awk '{print \$3}'");
    return unless ($bkupnode);
    for my $sys (@{$cpic->{systems}}) {
        $hostname = $vcs->get_vcs_sysname_sys($sys);
        #FIXME: Need to confirm whether BackupGrp is parallel or not, take it as non-parallel at present
        if ($bkupnode eq $hostname) {
            $msg = Msg::new("Active backup jobs are running on $bkupnode. Deleting this node from the cluster may cause the backup to fail.");
            $msg->warning();
            $msg = Msg::new("Do you want to continue?");
            $ayn = $msg->aynn();
            if ($ayn eq 'N') {
                $rel->update_status_file("DEL",'','',"DONE");
                $cpic->edr_completion();
            }
            last;
        }
    }
    return;
}

sub delnode_check_dedup_job {
    my $prod = shift;
    my ($sys0,$output,$msg,$ayn,$node,@nodes,$nodelist);

    my $edr = Obj::edr();
    my $rel = Obj::rel();
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    $sys0 = $edr->{localsys};
    $output = $sys0->cmd("_cmd_vxprint -x 2>/dev/null | _cmd_grep '^vt' | wc -l");
    # NLM file system exist
    if($output > 0) {
        $output = $sys0->cmd("_cmd_fsdedupadm status all 2>/dev/null");
        if (EDR::cmdexit()!=0) {
            $msg=Msg::new("Getting deduplication jobs status failed. Deleting this node from the cluster may cause the deduplication to fail."); 
            $msg->warning();
            $msg = Msg::new("Do you want to continue?");
            $ayn = $msg->aynn();
            if ($ayn eq 'N') {
                $rel->update_status_file("DEL",'','',"DONE");
                $cpic->edr_completion();
            }
        } else {
            for my $line (split(/\n/, $output)) {
                next unless ($line=~/RUNNING/);
                (undef,undef,undef,$node,undef,undef) = split(/\s+/m,$line); 
                if (EDRu::inarr($node, @{$cfg->{systems}})) {
                    push(@nodes, $node);
                }
            }
            if (scalar(@nodes) > 0) {
                $nodelist = join(' ',@nodes);
                $msg = Msg::new("Active dedup jobs are running on $nodelist. Delete aborted. Stop dedup jobs on $nodelist and try again.");
                $msg->error();
                $rel->update_status_file("DEL",'',$cfg->{systems},"FAILED");
                $cpic->edr_completion();
            }
        }
    }
    return;
}

sub delnode_umount_dedup_chkpnt {
    my $prod = shift;
    my ($cfg,$sys,$output,$msg,$mntpoint);
    $cfg = Obj::cfg();
    for my $sysi (@{$cfg->{systems}}) {
        $sys = Obj::sys($sysi);
        $output = $sys->cmd("_cmd_mount 2>/dev/null");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Could not check the mount list on $sys->{sys}.");
            $msg->warning();
            return 1;
        }
        for my $line (split(/\n/,$output)) {
            next unless ($line=~/$prod->{dedup_snapshot_prefix}/);
            (undef,undef,$mntpoint,undef) = split(/\s+/m, $line);
            $sys->cmd("_cmd_umount -f $mntpoint 2>/dev/null");
            if (EDR::cmdexit() != 0) {
                Msg::log("Unmount $mntpoint failed on $sys->{sys}.");
            }
        }
    }
    return 0;
}

sub delnode {
    my $prod = shift;
    my ($had,@run_nodes,@run_copy,@nonrun_nodes,$rel,$sysname,$maxtry,$msg,$nodelist,$proc,$rtn,$sys0);

    my $edr = Obj::edr();
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS61');
    my $fenpkg = $prod->pkg('VRTSvxfen61');
    $rel = $cpic->rel();
    $rel->update_status_file("DEL","Delete node(s)",$cfg->{systems});
    $maxtry = 15;
    for my $sys (@{$cpic->{systems}}) {
        unless ($sys->{canssh}) {
            push(@nonrun_nodes, $sys);
            next;
        }
        $had = $sys->proc('had61');
        if ($had->check_sys($sys)) {
            push(@run_nodes, $sys);
        } else {
            push(@nonrun_nodes, $sys);
        }
    }
    #TBD: should ntpd been stopped as that in the FileStore?
    # switch failover(offline parallel) service groups by CPI
    # For running node only
    if (scalar(@run_nodes)) {
        $rel->ru_switch_groups(\@run_nodes,2);
        $rel->ru_offline_parallel_groups(\@run_nodes);
        for my $sys (@run_nodes) {
            $sysname = $vcs->get_vcs_sysname_sys($sys);
            $sys->set_value('vcs_sysname',$sysname);
            $sys->cmd("_cmd_vxclustadm stopnode -sys $sysname");
        }

        for my $sys (@run_nodes) {
            $fenpkg->unregister_keys_sys($sys);
            $rtn = $fenpkg->stop_vcsfen_sys($sys);
            if ($rtn) {
                $rel->update_status_file("DEL",'',$cfg->{systems},"FAILED");
                $cpic->edr_completion();
            }

            for my $proci (qw(gab61 llt61)) {
                $proc = $sys->proc($proci);
                $msg=Msg::new("Stopping $proc->{proc} on $sys->{sys}");
                if ($cpic->proc_stop_sys($sys, $proc)) {
                    CPIC::proc_stop_passed_sys($sys, $proc);
                    $msg->display_status();
                } else {
                    CPIC::proc_stop_failed_sys($sys, $proc);
                    my $errmsg= Msg::new("Failed to stop $proc->{proc} on $sys->{sys}");
                    $msg->addError($errmsg->{msg});
                    $msg->display_status('failed');
                    $rel->update_status_file("DEL",'',$cfg->{systems},"FAILED");
                    $cpic->edr_completion();
                }
            }
        }
    }

    $msg = Msg::new("Clean up deleted nodes information on the cluster");
    $msg->left();
    $prod->delnode_update_maincf();
    $vcs->delnode_update_lltgab();
    $msg->right_done();
    $rel->update_status_file("DEL","Clean up the deleted node(s)",$cfg->{systems});
    $msg = Msg::new("Clean up deleted nodes");
    $msg->left();
    for my $sys (@{$cpic->{systems}}) {
        next unless ($sys->{canssh});
        $prod->restore_ifcfg_sys($sys);
        $sys->cmd("$prod->{scriptsdir}/cluster/cleanup.sh -delnode &");
    }
    $msg->right_done();
    $prod->delnode_free_resource();
    $sys0 = $edr->{localsys};
    for my $sys (@{$cpic->{systems}}) {
        $sys0->cmd("$prod->{sysscriptsdir}/optionconfig.sh nodedel $sys->{sys}");
        $sys0->cmd("$prod->{storscriptsdir}/iscsiinitconfig.sh delnode $sys->{sys}");
    }
    $prod->update_dedup_nodes();
    return;
}

sub update_dedup_nodes {
    my $prod = shift;
    my ($sys0,$dedup_nodes,@dedupnodes);
    my $edr = Obj::edr();
    my $vcs = $prod->prod('VCS61');
    $sys0 = $edr->{localsys};
    $dedup_nodes = $sys0->cmd("_cmd_awk '{print \$2}' $vcs->{llthosts} 2>/dev/null");
    @dedupnodes = split(/\n/, $dedup_nodes);
    $dedup_nodes = join(',', @dedupnodes);
    $sys0->cmd("_cmd_fsdedupadm setnodelist -n \"$dedup_nodes\" all");
    return;
}

sub delnode_update_maincf {
    my $prod = shift;
    my $sfcfsha = $prod->prod('SFCFSHA61');

    $sfcfsha->delnode_update_maincf();
    return;
}

sub restore_ifcfg_sys {
    my ($prod,$sys) = @_;
    my ($udevdir);

    Msg::log("Restore network configuration files in $sys->{sys}");
    $udevdir = "/etc/udev/rules.d";
    $sys->cmd("_cmd_cp -f $udevdir/70-persistent-net.rules.bakup $udevdir/70-persistent-net.rules");
    $sys->cmd("_cmd_rm -f $prod->{nwconfdir}/ifcfg-pubeth*");
    $sys->cmd("_cmd_rm -f $prod->{nwconfdir}/ifcfg-priveth*");
    $sys->cmd("_cmd_rm -f $prod->{nwconfdir}/ifcfg-bond*");
    $sys->cmd("_cmd_cat /dev/null > /etc/modprobe.conf");
    $sys->cmd("_cmd_cp $prod->{nwconfbkupdir}/* $prod->{nwconfdir}");
}

sub delnode_free_resource {
    my $prod = shift;
    my ($ctdb_ipfile,$cfg,$sys0,$sys,$node,$output,@privip_list,$ip,@remain,@remain_sys);

    my $edr = Obj::edr();
    # FIXME
    $ctdb_ipfile = "/etc/ctdb/nodes";
    $cfg = Obj::cfg();
    $sys0 = $edr->{localsys};
    for my $sys (@{CPIC::get('systems')}) {
        $node = $sys->{vcs_sysname};
        $node ||= $sys->{sys};
        # Update public ip conf file
        Msg::log("Update public ip conf file for $node");
        $sys0->cmd("_cmd_sed -i '/$node/d' $prod->{nicconf}->{physicalipfile}");
        # Update net_pci_exclusion.conf
        $sys0->cmd("_cmd_sed -i '/$node/d' $prod->{nicconf}->{pciexclusionfile}");
        # Update private ip conf file
        $output = $sys0->cmd("_cmd_awk '/$node/ {print \$1OFS\$2}' $prod->{nicconf}->{privateipfile}");
        push(@privip_list, $output) if ($output);
        ($ip,undef) = split(/\s+/, $output);
        Msg::log("Delete $ip from ctdb private ip file");
        $sys0->cmd("_cmd_sed -i '/$ip/d' $ctdb_ipfile");
    }
    Msg::log("Update private ip conf file for $node");
    $prod->set_privateipfile_sys($sys0,@privip_list);
    $sys0->cmd("/etc/init.d/ctdb status");
    $sys0->cmd("ctdb reloadnodes") unless (EDR::cmdexit());
    @remain = @{EDRu::arrdel($cfg->{clustersystems}, @{$cfg->{systems}})};
    for my $sysi (@remain) {
        next if ($sysi eq $sys0->{sys});
        $sys = Obj::sys($sysi);
        $sys0->copy_to_sys($sys,$ctdb_ipfile);
        push (@remain_sys, $sys);
    }
    # TODO: more files to copy(/root/.ssh/known_hosts)
    $prod->delnode_update_sshinfo($sys0);
    $prod->copy_conf_to_othernodes($sys0,\@remain_sys) if(@remain_sys);
    return;
}

sub delnode_update_sshinfo {
    my $prod = shift;
    my $sys0 = shift;
    my ($edr,$cfg,$knownhosts,$authkeyfile,$pubkey);
            
    $edr = Obj::edr();
    $cfg = Obj::cfg();
            
    for my $sysi (@{$cfg->{systems}}) {
        my $sys_obj = Obj::sys($sysi);
        if ($sys_obj->{canssh}){
            Msg::log("Delete ssh information for $sysi from $prod->{knownhosts}, $prod->{authkeys} and $prod->{nicconf}->{globalroutes}");   
            $sys0->cmd("_cmd_sed -i '/$sysi/d' $prod->{knownhosts}");
            $sys0->cmd("_cmd_sed -i '/$sysi/d' $prod->{authkeys}");
            # Update /etc/hosts
            Msg::log("Delete $sysi from $prod->{hostsfile}");
            $sys0->cmd("_cmd_sed -i '/$sysi/d' $prod->{hostsfile}");
        } else {
            Msg::log("$sysi is not reachable, hence adding its ssh key into the $prod->{deleted_node_list} file.");
            $pubkey= $sys0->cmd("_cmd_cat $prod->{authkeys} | _cmd_grep $sysi 2>/dev/null");
            if ($pubkey eq '') {
                Msg::log("Do not find SSH key for $sysi in $prod->{authkeys} file.");
            } else { 
                $pubkey .="\n";
                $sys0->appendfile($pubkey, $prod->{deleted_node_list});
                $sys0->cmd("_cmd_sed -i '/^\s*\$/d' $prod->{deleted_node_list}");
            }
        }
        $sys0->cmd("_cmd_sed -i '/$sysi/d' $prod->{nicconf}->{globalroutes}");
    }   
    return; 
}

sub update_deleted_node_list {
    my $prod = shift;
    my $sys_to_add = shift;

    my $pubkey= $sys_to_add->cmd("_cmd_cat $prod->{id_rsa_pub}| _cmd_awk '{if (NR==1) {print $2}}' 2>/dev/null");
    if ($pubkey ne '') {
        my $edr = Obj::edr();
        my $cfg = Obj::cfg();
        my $sys_local = $edr->{localsys};
        $sys_local->cmd("_cmd_sed -i '/$pubkey/d' $prod->{deleted_node_list}");
        for my $sysi (@{$cfg->{clustersystems}}) {
            my $sys0 = Obj::sys($sysi);
            $sys_local->copy_to_sys($sys0,$prod->{deleted_node_list});
        }
    }
    return;
}

sub preremove_sys {
    my ($prod,$sys)=@_;
    my $files="";
    $prod->perform_task_sys($sys,'preremove_sys');

    $sys->cmd("$prod->{scriptsdir}/cluster/cleanup.sh -uninstall & >/dev/null 2>&1");
    return;
}

sub postremove_sys { 
    my ($prod,$sys)=@_;
    my $files="";
    $prod->perform_task_sys($sys,'postremove_sys');
    
    $files.="$prod->{nicconf}->{llttab} ";
    $files.="$prod->{nicconf}->{llthosts} ";
    $files.="$prod->{nicconf}->{gabtab} ";
    $files.="$prod->{nicconf}->{vxfenmode} ";
    $files.="$prod->{nicconf}->{vxfendg} ";
    $files.="$prod->{nicconf}->{vxfentab} ";
    $files.="$prod->{nicconf}->{maincf} ";
    $sys->cmd("_cmd_rm -f $files >/dev/null 2>&1");
    $prod->restore_ifcfg_sys($sys);

    $sys->set_value('reboot',1);
    return;
}

sub precheck_task {
    my $prod = shift;
    return 1;
}

sub cli_select_systems {
    my ($prod,$def) = @_;
    my ($msg,$cfg,$helpmsg,$padv,@systems,$systems,$edr);
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    # remote windows executable forces local only
    if (Cfg::opt('rwe')) {
        $cfg->{systems}=[ $edr->localsys->{sys} ];
        return $cfg->{systems};
    }
    unless (defined $cfg->{systems}) {
        if ($cfg->{opt}{hostfile})    {
            $systems = EDRu::readfile($cfg->{opt}{hostfile});
            $systems =~ s/^\s+//;
            $systems =~ s/\s+$//;
        } else {
            if ($#{$edr->{padvs}}) {
                $msg=Msg::new("Enter the system IP addresses separated by spaces:");
            } else {
                $padv=Obj::padv($edr->{padvs}[0]);
                $msg=Msg::new("Enter the $padv->{name} system IP addresses separated by spaces:");
            }
            $helpmsg=Msg::new("Systems specified are required to have rsh or ssh configured for password free logins");
            $systems=$msg->ask('',$helpmsg);
        }
        @systems=split(/\s+/m,$systems);
        $cfg->{systems}=\@systems;
    }
    if ($prod->validate_systemnames(@{$cfg->{systems}})) {
        if (Cfg::opt('responsefile')) {
            $msg=Msg::new("\$CFG{systems} in the responsefile has invalid values");
            $msg->die;
        }
        undef($cfg->{systems});
        if (Cfg::opt('hostfile')) {
            $msg=Msg::new("Invalid host file: $cfg->{opt}{hostfile}");
            $msg->warning;
            Cfg::unset_opt('hostfile');
        }
        $prod->cli_select_systems();
    } else {
        return \@{$cfg->{systems}};
    }
    return;
}

sub validate_systemnames {
    my ($prod,@sysl) = @_;
    my ($edr,$msg);

    $edr = Obj::edr();
    for my $n (0..$#sysl) {
        unless (EDRu::ip_is_ipv4($sysl[$n]) || EDRu::ip_is_ipv6($sysl[$n])) {
            $msg = Msg::new("$sysl[$n] is not a valid ip address");
            $msg->warning();
            return 1;
        }
    }
    return $edr->validate_systemnames(@sysl);
}

sub install_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->check_gui_port_in_use_sys($sys);
    $prod->perform_task_sys($sys,'install_precheck_sys');
    return;
}

sub configure_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->check_gui_port_in_use_sys($sys);
    $prod->perform_task_sys($sys,'configure_precheck_sys');
    return;
}

sub check_gui_port_in_use_sys {
    my ($prod,$sys) = @_;
    my ($msg, $port);
    $port = 8443;
    if (EDRu::is_port_connectable($sys->{sys},$port)) {
        $msg = Msg::new("Port 8443 is already in use on $sys->{sys}, due to which GUI will not be able to come up. Close the port before proceeding.");
        $sys->push_warning($msg);
    }

    return;
}

sub configure_kdump_sys {
    my ($prod,$sys) = @_;

    $sys->cmd("_cmd_mkdir -p $prod->{kernel_dump_dir} 2>/dev/null");
    my $grub_conf_bk = $prod->{grub_conf}.".sys";
    my $kdump_conf_bk = $prod->{kdump_conf}.".sys";
    $sys->cmd("_cmd_cp -pf $prod->{grub_conf} $grub_conf_bk 2>/dev/null");
    $sys->cmd("_cmd_cp -pf $prod->{kdump_conf} $kdump_conf_bk 2>/dev/null");

    $sys->cmd("_cmd_sed -i 's/crashkernel=\\w*\\b/crashkernel=512M-2G:64M,2G-:256M/g' $prod->{grub_conf} 2>/dev/null");

    $sys->cmd("_cmd_sed -i '/^path\\b/d;' $prod->{kdump_conf} 2>/dev/null");
    $sys->cmd("_cmd_echo 'path /opt/SYMCsnas/core/kernel/' >> $prod->{kdump_conf}");
    $sys->cmd("_cmd_sed -i '/^core_collector\\b/d;' $prod->{kdump_conf} 2>/dev/null");
    $sys->cmd("_cmd_echo 'core_collector makedumpfile -c --message-level 1 -d 31' >> $prod->{kdump_conf}");

    $sys->cmd("chkconfig abrtd off 2>/dev/null");
    $sys->cmd("_cmd_service abrtd stop 2>/dev/null");
    $sys->cmd("chkconfig kdump on 2>/dev/null");
    $sys->cmd("_cmd_service kdump restart 2>/dev/null");

    my $output = $sys->cmd("_cmd_service kdump status");
    if ( $output =~ /Kdump is operational/ ) {
        $sys->set_value('kdumpreboot',1);
        $sys->set_value('reboot',1);
    } else {
        $sys->set_value('kdumpfailed',1);
        $sys->set_value('reboot',1);
    }

    return;
}

sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;
    my ($cacheareas,@cacheareas);

    # offline smartio caches
    unless (Cfg::opt('upgrade_nonkernelpkgs')) {
        # Workaround to delete following amf stop line before GA with Sushil Patil's confirmation
        $sys->cmd("/etc/init.d/amf stop 2>/dev/null");
        $cacheareas = $sys->cmd("_cmd_sfcache list -l 2>/dev/null | _cmd_awk '/^Cachearea:/ { cache=\$2 } /^State: *ONLINE/ { print cache }'");
        if ($cacheareas) {
            Msg::log("Offline cache areas on $sys->{sys}");
            @cacheareas = split(/\n+/m,$cacheareas);
            for my $cachearea (@cacheareas) {
                $sys->cmd("_cmd_sfcache offline $cachearea");
            }
            $sys->set_value('cacheareas', 'list', @cacheareas);
        }
    }
    $prod->SUPER::upgrade_prestop_sys($sys);
    return;
}

sub upgrade_poststart_sys {
    my ($prod,$sys) = @_;

    #onlin smartio caches
    unless (Cfg::opt('upgrade_nonkernelpkgs') || !$sys->{cacheareas}) {
        Msg::log("Online cache areas on $sys->{sys}");
        for my $cachearea (@{$sys->{cacheareas}}) {
            $sys->cmd("_cmd_sfcache online $cachearea");
        }
    }
    $prod->SUPER::upgrade_poststart_sys($sys);
    return;
}

package Prod::SNAS60::SunOS;
@Prod::SNAS60::SunOS::ISA = qw(Prod::SNAS60::Common);

1;
