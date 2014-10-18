use strict;

package Prod::SFCFSHA60::Common;
@Prod::SFCFSHA60::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{vers}='6.0.100.000';
    $prod->{default_cluster_protocol_version} = 120;

    if ($prod->sfcfsha) {
        $prod->{prod}='SFCFSHA';
        $prod->{abbr}='SFCFSHA';
        $prod->{name}=Msg::new("Veritas Storage Foundation Cluster File System HA")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
        $prod->{proddir}='storage_foundation_cluster_file_system_ha';
        $prod->{eula}='EULA_CFSHA_Ux_6.0.1.pdf';

        $prod->{installscript_prod}='SFCFSHA60';
        $prod->{installscript_name}='SFCFSHA';
        $prod->{mainpkg}='VRTScavf60';
        $prod->{licsuperprods}=[ qw(SFRAC60) ];

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];
        $prod->{superprods} = [qw(SFRAC60 SVS60)];

    } elsif ($prod->svs) {
        $prod->{prod}='SVS';
        $prod->{abbr}='SVS';
        $prod->{name}=Msg::new("Symantec VirtualStore")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
        $prod->{not_prompt_minpkgs_warning}=1;
        $prod->{proddir}='virtualstore';
        $prod->{eula}='EULA_VirtualStore_Ux_6.0.1.pdf';
        $prod->{mainpkg}='VRTSsvs60';

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];

    } elsif ($prod->sfsybasece) {
        $prod->{prod}='SFSYBASECE';
        $prod->{abbr}='SFSYBASECE';
        $prod->{name}=Msg::new("Veritas Storage Foundation for Sybase ASE CE")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
        $prod->{proddir}='storage_foundation_for_sybase_ce';
        $prod->{eula}='EULA_SF_Sybase_CE_Ux_6.0.1.pdf';

        $prod->{installscript_prod}='SFSYBASECE60';
        $prod->{installscript_name}='SFSYBASECE';
        $prod->{lic_names}=['Veritas Storage Foundation for Sybase ASE CE'];
        $prod->{mainpkg}='VRTScavf60';

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];

        $prod->{menu_sfsybasece} = ['config_cfs', 'config_fencing', 'config_sfsybasece', 'exit_cleanly'];

        my $msg = Msg::new("Configure Cluster File System");
        $msg->msg('sfsybasece_config_cfs');
        $msg = Msg::new("Configure I/O Fencing in Sybase Mode");
        $msg->msg('sfsybasece_config_fencing');
        $msg = Msg::new("Configure Sybase ASE CE Instance in VCS");
        $msg->msg('sfsybasece_config_sfsybasece');
        $msg = Msg::new("Exit $prod->{abbr} Configuration");
        $msg->msg('sfsybasece_exit_cleanly');

    }
    $prod->{subprods}=[qw(VCS60 SF60 SFHA60)];

    $prod->{upgrade_flag_file}="/opt/VRTS/install/.$prod->{prod}.upgrade";

    if ($prod->svs) {
        $prod->{lic_names}=['Symantec VirtualStore'];
    } elsif ($prod->sfsybasece) {
        $prod->{lic_names}=['Veritas Storage Foundation for Sybase ASE CE'];
    } else {
        $prod->{lic_names}=['Storage Foundation for Cluster File System',
                            'SANPoint Foundation Suite',
                            'Storage Foundation Cluster File System'];
    }

    $prod->{responsefileupgradeok}=1;
    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv VRTSamf VRTSsfmh VRTSvbs) ];

    $prod->{cfsbin}='/opt/VRTS/bin';

    $prod->{cfscluster_config_pending} = 1;

    $prod->{has_poststart_config} = 1;
    $prod->{has_config} = 1;
    $prod->{multisystemserialpoststart}=1;

    $prod->{minimal_cpu_number_requirment} = 2;
    $prod->{minimal_memory_requirment} = '2 GB';
    $prod->{minimal_swap_requirment} = '1 GB';

    my $padv=$prod->padv();
    $padv->{cmd}{cfscluster}="$prod->{cfsbin}/cfscluster";
    $padv->{cmd}{cfsdgadm}="$prod->{cfsbin}/cfsdgadm";
    $padv->{cmd}{cfsmntadm}="$prod->{cfsbin}/cfsmntadm";
    $padv->{cmd}{cfsmount}="$prod->{cfsbin}/cfsmount";
    $padv->{cmd}{cfsumount}="$prod->{cfsbin}/cfsumount";
    $padv->{cmd}{fsclustadm}="$prod->{cfsbin}/fsclustadm";
    $padv->{cmd}{vcsmmconfig}='/sbin/vcsmmconfig';
    $padv->{cmd}{odmclusteradm}='/opt/VRTS/bin/odmclustadm';
    $padv->{cmd}{cfsshare}="$prod->{cfsbin}/cfsshare";
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';

    return;
}

sub default_systemnames {
    my $prod=shift;
    my $vcs=$prod->prod('VCS60');
    return $vcs->default_systemnames;
}

sub adjust_ru_procs {
    my $prod=shift;
    if(Cfg::opt('upgrade_nonkernelpkgs')){
        my $procs=[qw(had60 CmdServer60)];
        return $procs;
    }
}

sub set_options {
    my ($prod,$options) = @_;
    my ($id,$option);

    $id=0;
    for my $option (@{$options}) {
        if($option) {
           if ($id == 0) {
               Cfg::set_opt(lc($option), 1);
               if (lc($option) eq 'vvr') {
                   Cfg::unset_opt('vvr');
                   Cfg::set_opt('vr', 1);
               }
           } elsif ($id == 1) {
               Cfg::set_opt('gco', 1);
           }
        }
        $id++;
    }
    return;
}

sub set_pkgs {
    my($prod,$rel,$vcs,$vm,$fs,$sf,$sf1,$category,@categories);
    $prod=shift;

    $rel=$prod->rel;
    $vm=$prod->prod('VM60');
    $fs=$prod->prod('FS60');
    $vcs=$prod->prod('VCS60');
    $sf=$prod->prod('SF60');

    #Ensure VRTSodm60 is after VRTSgsm51 in the pkg list.
    $sf1->{allpkgs} = EDRu::arrdel($sf->{allpkgs},'VRTSodm60');
    $sf1->{minpkgs} = $sf->{minpkgs};
    $sf1->{recpkgs} = EDRu::arrdel($sf->{recpkgs},'VRTSodm60');

    @categories=qw(minpkgs recpkgs allpkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$rel->{$category}},
                                        @{$vm->{$category}},
                                        @{$fs->{$category}},
                                        @{$vcs->{$category}},
                                        @{$sf1->{$category}},
                                        @{$prod->{$category}});
       if($prod->sfsybasece()){
            $prod->{$category}=EDRu::arrdel($prod->{$category},'VRTSgms60');
            $prod->{$category}=EDRu::arrdel($prod->{$category},'VRTSodm60');
            $prod->{$category}=EDRu::arrdel($prod->{$category},'VRTScps60');
            $prod->{$category}=EDRu::arrdel($prod->{$category},'VRTSdbed60');
       }
    }

    @categories=qw(obsoleted_ga_release_pkgs
                   obsoleted_but_need_refresh_when_upgrade_pkgs
                   obsoleted_but_still_support_pkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$rel->{$category}},
                                        @{$prod->{$category}},
                                        @{$sf->{$category}},
                                        @{$vcs->{$category}},
                                        @{$vm->{$category}},
                                        @{$fs->{$category}});
    }
    return $prod->{allpkgs};
}

# return 1 if using installsfcfs to configure SFCFSHA
# and SFCFSHA is licensed
sub configure_alternate_prod {
    my ($prod)=@_;
    my $cprod=CPIC::get('prod');
    return 1 if (($cprod =~/SFCFS(\d+)/m) && $prod->sfcfsha );
    return;
}

# check the license and update prod from SFCFS to SFCFSHA
sub update_prod {
    my ($prod) = @_;
    my ($sys,$cpic,$name_sfcfsha,$ivers,$prod_sfcfsha);
    $cpic=Obj::cpic();
    $sys=@{CPIC::get('systems')}[0];
    $name_sfcfsha='SFCFSHA60';

    $prod_sfcfsha=$prod->prod($name_sfcfsha);
    $ivers=$prod_sfcfsha->version_sys($sys,1);
    if ($ivers && $prod_sfcfsha->configure_alternate_prod()) {
        $cpic->set_prod($name_sfcfsha);
        $cpic->cli_set_title();
    }
    return;
}

sub clear_and_start_cvm {
    my ($cvm_state, $sys, $msg,$vcs,$sysname,$syslist,$prod);
    $prod = shift;

    $vcs = $prod->prod('VCS60');
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $sysname=$sys->{vcs_sysname};
        if (!$sysname) {
            $sysname = $vcs->get_vcs_sysname_sys($sys);
            $sys->{vcs_sysname} = $sysname;
        }
        $cvm_state = $sys->cmd("$vcs->{bindir}/hagrp -state cvm -sys $sysname");
        if ($cvm_state eq 'ONLINE') {
            Msg::log('cvm already Online');
        } else {
            $sys->cmd("$vcs->{bindir}/hagrp -clear cvm -sys $sysname");
            $sys->cmd("$vcs->{bindir}/hagrp -online cvm -sys $sysname");
            if (!EDR::cmdexit()) {
               $sys->cmd("$vcs->{bindir}/hagrp -wait cvm State ONLINE -sys $sysname -time 300 ");
            }

            if (EDR::cmdexit()) {
               $msg = Msg::new("Unable to online cvm service group on $sys->{sys}");
               $sys->push_warning($msg);
            }
        }
    }
    return;
}

sub freeze_cvm {
    my ($prod,$sys)=@_;
    my $cvm_vxconfigd_state;
    my $vcs = $prod->prod('VCS60');
    my $sysname;

    $sysname=$sys->{vcs_sysname};
    $cvm_vxconfigd_state = $sys->cmd("$vcs->{bindir}/hares -state cvm_vxconfigd -sys $sysname");
    if ($cvm_vxconfigd_state eq 'ONLINE') {
        $sys->cmd("$vcs->{bindir}/hagrp -freeze cvm");
    }

    return;
}

sub cli_prod_option
{
    my $prod=shift;
    $prod->perform_task('cli_prod_option');
    return;
}

sub web_prod_option
{
    my $prod=shift;
    $prod->perform_task('web_prod_option');
    return;
}

# Add a HA menu to fix 1988793
sub cli_initiation_questions {
    my ($prod)=@_;
    my ($cpic,$cfg,$mode,$mprod);

    if (($prod->svs()) && (Cfg::opt('install'))) {
        $mode=$prod->svs_config_mode('install');
        if ($mode eq 'typical') {
            Cfg::set_opt('silent');
            $prod->{silent_installconfig} = 1;
        }
    }
    return unless (Cfg::opt('makeresponsefile'));
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $mprod=$prod->rel->prod_ha_menu('makeresponsefile',$cpic->{prod});
    $cpic->{prod}=$mprod;
    $cfg->{prod}=$mprod;
    return;
}

sub web_initiation_questions {
    my ($prod) = @_;
    return unless (Cfg::opt('install') || Cfg::opt('configure'));
    return if (Cfg::opt( qw(addnode fencing security configcps) ));

    my $web = Obj::web();
    if ($prod->svs()&& !$prod->{silent_installconfig}) {
        my $mode = $web->web_script_form('config_mode');
        if ($mode eq 'typical') {
            $prod->{silent_installconfig} = 1;
        }
    }
    return;
}

sub perform_task_sys {
    my ($prod,$sys,$task) = @_;
    my ($sf_rtn,$vcs_rtn,$vcs,$sf);

    $sf=$prod->prod('SF60');
    $sf_rtn=$sf->$task($sys) if ($sf->can($task));

    $vcs=$prod->prod('VCS60');
    $vcs_rtn=$vcs->$task($sys) if ($vcs->can($task));
    return;
}

sub perform_task {
    my ($prod,$task) = @_;
    my ($sf_rtn,$vcs_rtn,$vcs,$sf);

    $sf=$prod->prod('SF60');
    $sf_rtn=$sf->$task() if ($sf->can($task));

    $vcs=$prod->prod('VCS60');
    $vcs_rtn=$vcs->$task() if ($vcs->can($task));
    return;
}

sub verify_responsefile {
    my ($prod) = @_;
    $prod->perform_task('verify_responsefile');
    return;
}

sub require_start_after_reboot_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys, 'require_start_after_reboot_sys');
    return;
}

sub responsefile_comments {
    my ($prod) = @_;
    $prod->perform_task('responsefile_comments');
    return;
}

sub responsefile_prestart_config {
    my ($prod) = @_;
    $prod->perform_task('responsefile_prestart_config');
    return;
}

sub responsefile_poststart_config {
    my $prod =shift;
    $prod->perform_task('responsefile_poststart_config');
    return;
}

sub preinstall_messages {
    my ($prod) = @_;
    $prod->perform_task('preinstall_messages');
    return;
}

sub cli_prestart_config_questions {
    my ($prod) = @_;
    my ($mode,$ret);
    my $installconfig = CPIC::get('installconfig');

    if ($prod->svs()) {
        # if separate configure then provide menu to choose mode
        # if custom install then custom configure without asking mode
        while ((!$installconfig) || ($prod->{silent_installconfig})) {
            if ($prod->{silent_installconfig}) {
                $mode = 'typical';
            } else {
                $mode = $prod->svs_config_mode('configure');
            }
            if ($mode eq 'typical') {
                $ret = $prod->svs_auto_config();
                next if (EDR::getmsgkey($ret, 'back'));
                return 1;
            } else {
                Msg::title();
                last;
            }
        }
    }

    $prod->perform_task('cli_prestart_config_questions');
    return;
}

sub svs_config_mode {
    my ($prod,$task) = @_;
    my ($default,$help,$menu_opts,$mode,$msg);

    $default = 1;

    Msg::title();
    if ($task eq 'install') {
        $help = Msg::new("To install $prod->{abbr} in typical mode, installer will ask minimum questions during installation and automatically configure cluster heartbeat links.\nTo install $prod->{abbr} in custom mode, installer will ask all the questions during installation.\nA typical installation includes installing $prod->{abbr}, licensing the product and then configuring the product with little user interaction.");
    } else {
        $help = Msg::new("To configure $prod->{abbr} in typical mode, installer will ask minimum questions during configuration and automatically configure cluster heartbeat links.\nTo configure $prod->{abbr} in custom mode, installer will ask all the questions during configuration.");
    }
    $msg = Msg::new("Typical");
    $menu_opts = [$msg->{msg}];
    $msg = Msg::new("Custom");
    push(@{$menu_opts},$msg->{msg});
    if ($task eq 'install') {
        $msg = Msg::new("Choose the mode you would like to install $prod->{abbr}:");
    } else {
        $msg = Msg::new("Choose the mode you would like to configure $prod->{abbr}:");
    }
    $mode = $msg->menu($menu_opts,$default,$help);
    return 'typical' if ($mode == 1);
    return 'custom';
}

sub svs_auto_config {
    my ($ayn,$cfg,$clus_id,$clus_name,$msg,$prod,$rhbn,$vcs_prod);
    $prod = shift;
    $cfg = Obj::cfg();

    $cfg->{vcs_allowcomms} = 1;
    $vcs_prod = $prod->prod('VCS60');
    Cfg::set_opt('silent');

    $rhbn = $vcs_prod->auto_config_llt();
    return $rhbn if (EDR::getmsgkey($rhbn, 'back'));
    # in case llt auto detection failed and silent option was unsest.
    $cfg->{vcs_clusterid} = int(rand(65535)) if (!defined($cfg->{vcs_clusterid}));
    $clus_id = $cfg->{vcs_clusterid};
    if ($vcs_prod->check_clusterid($clus_id,$rhbn)) {
        Cfg::unset_opt('silent');
        $clus_id = $vcs_prod->config_clusterid($clus_id,$rhbn);
    }
    # in case cluster id auto detection failed and silent option was unset.
    Cfg::set_opt('silent');
    $clus_name = lc("$prod->{abbr}$clus_id");
    $msg = $vcs_prod->display_config_info($clus_name, $clus_id, $rhbn);
    $msg->add_summary(1);
    unless (Cfg::opt('responsefile')) {
        $cfg->{vcs_clusterid}=$clus_id;
        $vcs_prod->set_hb_nics($rhbn, CPIC::get('systems'));
        $cfg->{vcs_clustername}=$clus_name;
    }
    delete($cfg->{autocfgllt});
    return 'done';
}

sub web_prestart_config_questions {
    my ($prod) = @_;
    my $edr = Obj::edr();
    my $web = Obj::web();
    my $cfg = Obj::cfg();

    if ($prod->{silent_installconfig}) {
        $cfg->{vcs_allowcomms} = 1;
        my $vcs = $prod->prod('VCS60');
        if ($vcs->web_autocfg_hbnics()) {
            $vcs->set_hb_nics($web->{rhbn},$edr->{systems});
            delete $cfg->{autocfgllt};

            if (!$cfg->{vcs_clusterid}) {
                $cfg->{vcs_clusterid} = int(rand(65535));
                if ($vcs->check_clusterid($cfg->{vcs_clusterid}, $web->{rhbn})) {
                    $vcs->web_config_clusterid($web->{rhbn});
                }
            }
            $cfg->{vcs_clustername} = lc("$prod->{abbr}$cfg->{vcs_clusterid}");

            return;
        }
    }
    $prod->perform_task('web_prestart_config_questions');
    return;
}

sub cli_poststart_config_questions {
    my ($prod) = @_;
    $prod->perform_task('cli_poststart_config_questions');
    return;
}

sub web_poststart_config_questions {
    my ($prod) = @_;
    $prod->perform_task('web_poststart_config_questions');
    return;
}

sub stop_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->check_cvmstatus_sys($sys);
    $prod->perform_task_sys($sys,'stop_precheck_sys');
    return;
}

sub uninstall_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'uninstall_precheck_sys');
    return;
}

sub install_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'install_precheck_sys');
    return;
}

sub configure_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'configure_precheck_sys');
    return;
}

sub start_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'start_precheck_sys');
    return;
}

sub check_vmware_vsphere_sdk_sys {
    my ($prod,$sys) = @_;
    my ($msg,$exitcode,$rtn);

    $rtn=$sys->cmd("/usr/bin/perl -e 'eval {require VMware::VIRuntime}; die \$\@ if \$\@'");
    $exitcode=EDR::cmdexit();

    if ($exitcode) {
        $msg=Msg::new("VMware vSphere SDK for Perl is not installed or not working as expected on $sys->{sys}. Download and install the SDK from VMware website and re-run the installation program.");
        $sys->push_warning($msg);
    }
    return;
}

sub check_cvmstatus_sys {
    my ($prod,$sys) = @_;
    my ($sysi,$msg,@temp,$grp,$vcs,$obj_sysi,$syslist,$line,$rtn,$cvm_online,$cvm_frozen);

    # Check if cvm is frozen and online.
    # If so, quit upgrading and ask user to unfreeze cvm before upgrading.
    $vcs=$prod->prod('VCS60');
    unless (Cfg::opt('rootpath')) {
        $rtn = $sys->cmd("$vcs->{bindir}/hagrp -list Frozen=1 2>/dev/null");
        for my $line (split(/\n+/,$rtn)) {
            ($grp)=split(/\s+/m,$line, 2);
            if($grp && ($grp eq 'cvm')){
                $cvm_frozen=1;
                last;
            }
        }

        if ($cvm_frozen) {
            $rtn = $sys->cmd("$vcs->{bindir}/hagrp -display cvm -attribute State");
            $syslist=CPIC::get('systems');
            for my $line (split(/\n+/,$rtn)) {
                @temp = split(/\s+/m, $line);
                next if ($temp[0] eq '#Group');
                $sysi = $temp[2];
                for my $obj_sysi (@$syslist) {
                    my $sysname = $obj_sysi->{vcs_sysname};
                    if (($sysi eq $sysname) && ($temp[3] =~ /ONLINE|PARTIAL/mx)) {
                        $cvm_online=1;
                        last;
                    }
                }
            }
            if ($cvm_online) {
                if(Cfg::opt('upgrade')) {
                    $msg = Msg::new("Cannot upgrade if cvm service group is frozen and online. Unfreeze cvm service group before upgrading.");
                } elsif(Cfg::opt('stop')) {
                    $msg = Msg::new("Cannot stop if cvm service group is frozen and online. Unfreeze cvm service group before stop.");
                }
                $sys->push_error($msg);
                return 0;
            }
        }
    }
}

sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_precheck_sys');
    $prod->check_cvmstatus_sys($sys);
    return;
}

sub prestop_sys {
    my ($prod,$sys) = @_;

    if (!Cfg::opt('rootpath')) {
        $prod->stop_agents_sys($sys);
    }

    $prod->perform_task_sys($sys,'prestop_sys');
    return;
}

sub preremove_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'preremove_sys');
    return;
}

sub preremove_tasks {
    my $prod = shift;
    $prod->perform_task('preremove_tasks');
    return;
}

sub postremove_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'postremove_sys');
    return;
}

sub preinstall_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'preinstall_sys');
    return;
}

sub postinstall_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'postinstall_sys');
    return;
}

sub check_config {
    my ($syslist,$cvm_state,$had,$maincf,$port_f,$port_v,$port_w,$prod,$rootpath,$sf,$sf_config,$sys,$sysname,$vcs,$vcs_config);
    $prod = shift;
    $rootpath = Cfg::opt('rootpath') || '';

    $sf=$prod->prod('SF60');
    $sf_config=$sf->check_config();
    return 0 unless $sf_config;
    $vcs=$prod->prod('VCS60');
    $vcs_config=$vcs->check_config();
    return 0 unless $vcs_config;

    # Check SFCFS configuration here.
    # If VCS is running, check if gab ports v,w and f are up and check if cvm service group is configured and online.
    # If VCS is not running, check main.cf, is cvm service group is configured.
    $syslist=CPIC::get('systems');
    $sys=$$syslist[0];
    $had = $sys->proc('had60');
    if ($had->check_sys($sys)) {
        $port_v = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port v gen' ");
        return 0 if ($port_v == 0);
        $port_w = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port w gen' ");
        return 0 if ($port_w == 0);
        $port_f = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port f gen' ");
        return 0 if ($port_f == 0);
        $sysname = $sys->{vcs_sysname};
        $cvm_state = $sys->cmd("$vcs->{bindir}/hagrp -state cvm -sys $sysname");
        return 0 if ($cvm_state ne 'ONLINE');
    } else {
        $maincf=$sys->readfile("$rootpath$vcs->{configdir}/main.cf");
        return 0 if ($maincf!~/\n\s*group\s+cvm[\s+\(]/x);
    }
    return 1;
}

sub configure_sys {
    my ($prod,$sys) = @_;
    # for SVS typical installation/configuration, backup existing conf files
    $prod->backup_conf_files_sys($sys) if (Cfg::opt('silent'));
    $prod->perform_task_sys($sys,'configure_sys');
    return;
}

sub backup_conf_files_sys {
    my ($prod,$sys) = @_;
    my (@files,$confdir,$out,$rootpath,$vcs);
    $vcs = $prod->prod('VCS60');
    $rootpath = Cfg::opt('rootpath') || '';
    $confdir = "$rootpath$vcs->{configdir}";
    if ($sys->exists($confdir)) {
        $out = $sys->cmd("_cmd_ls $confdir/*.cf 2> /dev/null");
        for my $file(split(/\n/,$out)) {
            $sys->cmd("_cmd_cp $file $file.cpisave");
        }
    }
    @files = ("$rootpath$vcs->{llthosts}","$rootpath$vcs->{llttab}","$rootpath$vcs->{gabtab}","$rootpath$vcs->{vxfenmode}","$rootpath$vcs->{vxfendg}");
    for my $file(@files) {
        if ($sys->exists($file)) {
            $sys->cmd("_cmd_cp $file $file.cpisave");
        }
    }
    return;
}

sub poststart_sys {
    my ($prod,$sys) = @_;
    my ($vcs,$vm);
    $vcs=$prod->prod('VCS60');
    $vm=$prod->prod('VM60');

    if ($sys->system1) {
        $prod->sfcfs_start_agents();
        EDRu::create_flag('sfcfs_start_agents_done');
    } else {
        EDRu::wait_for_flag('sfcfs_start_agents_done');
    }
    $vm->poststart_sys($sys) if ($vm->can('poststart_sys'));

    $vcs->poststart_sys($sys) if ($vcs->can('poststart_sys'));

    # Start CVM and CFS Agents ..
    if ($sys->system1) {
        $prod->clear_and_start_cvm();
        EDRu::create_flag('clear_and_start_cvm_done');
    } else {
        EDRu::wait_for_flag('clear_and_start_cvm_done');
    }
    return;
}

sub ru_prestop_sys {
    my ($prod,$sys) = @_;
    my ($ver1,$ver2,$ver3,$output);
    my $vcs=$sys->prod('VCS60');

    if (Cfg::opt('upgrade_kernelpkgs')) {
        $vcs->ru_prestop_sys($sys);
        $output=$sys->cmd('_cmd_vxdctl protocolversion 2>&1');
        $ver1=$1 if($output=~/Cluster\s+running\s+at\s+protocol\s+(\d+)/mx);
        $ver2=$sys->cmd("_cmd_fsclustadm protoversion 2>&1 | _cmd_grep 'local' | awk '{print \$3}'");
        $ver3=$sys->cmd("_cmd_odmclustadm protoversion 2>&1 | _cmd_grep 'local' | awk '{print \$3}'");

        Msg::log("Starting Stopping CVM in rolling upgrade on $sys->{sys}");
        $prod->stop_agents_sys($sys);
        Msg::log("Finished Stopping CVM in rolling upgrade on $sys->{sys}");

        #Stop had again, if CVM related process is using VCS resource, had may not be stopped at first time in $vcs->ru_prestop_sys($sys)
        $sys->cmd('_cmd_hastop -local -evacuate 2>/dev/null');

        #set fs/vm/odm version
        $sys->cmd("_cmd_vxdctl setversion $ver1 2>&1") if($ver1);
        $sys->cmd("_cmd_fsclustadm protoset $ver2 2>&1") if($ver2);
        $sys->cmd("_cmd_odmclustadm protoset $ver3 2>&1") if($ver3);
    }
    return;
}

sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;

    my $vcs=$prod->prod('VCS60');
    my $vm=$prod->prod('VM60');
    my $sfha=$prod->prod('SFHA60');

    $vm->upgrade_prestop_sys($sys) if ($vm->can('upgrade_prestop_sys'));
    $sfha->upgrade_rolling_post_sys($sys) if($sys->system1 &&  Cfg::opt('upgrade_nonkernelpkgs'));
    $prod->ru_prestop_sys($sys) if(Cfg::opt('upgrade_kernelpkgs'));


    if (!Cfg::opt('rootpath')) {
        $prod->stop_agents_sys($sys) unless(Cfg::opt('upgrade_kernelpkgs') || Cfg::opt('upgrade_nonkernelpkgs'));
    }

    $vcs->upgrade_prestop_sys($sys) if ($vcs->can('upgrade_prestop_sys'));
    return;
}


sub upgrade_preremove_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_preremove_sys');
    return;
}

sub upgrade_postremove_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_postremove_sys');
    return;
}

sub upgrade_preinstall_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_preinstall_sys');
    return;
}

sub upgrade_postinstall_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_postinstall_sys');
    return;
}

sub upgrade_configure_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_configure_sys');
    return;
}

sub upgrade_poststart_sys {
    my ($prod,$sys) = @_;
    my ($vcs,$vm,$csystems,$nsystems);
    $vcs=$prod->prod('VCS60');
    $vm=$prod->prod('VM60');

    if ($sys->system1) {
        $prod->sfcfs_start_agents();
        EDRu::create_flag('sfcfs_start_agents_done');
    } else {
        EDRu::wait_for_flag('sfcfs_start_agents_done');
    }

    # by pass the check done in poststart_sys of VCS, which is VCS specific.
    $vcs->upgrade_poststart_sys($sys) if ($vcs->can('upgrade_poststart_sys'));

    # Get number of systems from the main.cf
    $nsystems = $sys->cmd("_cmd_grep '^system' $vcs->{maincf} 2> /dev/null | _cmd_wc -l");
    $csystems = scalar(@{CPIC::get('systems')});
    Msg::log("Number of systems in main.cf = $nsystems");
    Msg::log("Number of systems provided = $csystems");

    # Start CVM and CFS Agents ..
    # It is Phased Upgrade if number of systems in main.cf != number of
    # systems in $cpic->{systems} (systems passed to CPI)
    # If Phased Upgrade, do not start the Agents.
    # Refer to the Installation Guide for the Correct procedure.
    if ($csystems == $nsystems) {
        Msg::log('Starting CVM as it is not phased upgrade');
        if ($sys->system1) {
            $prod->start_cvm_cfs_agents($sys);
            EDRu::create_flag('start_cvm_cfs_agents_done');
        } else {
            EDRu::wait_for_flag('start_cvm_cfs_agents_done');
        }
    }
    $vm->upgrade_poststart_sys($sys) if ($vm->can('upgrade_poststart_sys'));
    if ($sys->exists("$prod->{upgrade_flag_file}")) {
        # Remove .<UPI>.upgrade file
        $sys->cmd("_cmd_rmr $prod->{upgrade_flag_file}");
    }
    return;
}

sub completion_messages {
    my ($prod,$msg,$cprod,$reboot_systems);
    $prod=shift;
    $cprod=CPIC::get('prod');
    $cprod=~s/\d+$//m;
    $reboot_systems=CPIC::get('require_start_after_reboot_systems');
    $prod->perform_task('completion_messages');

    return unless (Cfg::opt('configure'));
    return if (Cfg::opt(qw(fencing addnode security configcps rootpath makeresponsefile)));

    if ($prod->{cfscluster_config_pending}==1) {
        $msg = Msg::new("Unable to complete $cprod configuration at this time\n");
        unless ( defined($reboot_systems) && (@$reboot_systems) ) {
            $msg->{msg} .= Msg::new("</opt/VRTS/bin/cfscluster config -s> must be run after the system is rebooted\n")->{msg};
        }
        $msg->print();
        if (Obj::webui()) {
            $msg->{msg} =~ s/<(.*)>/&lt;$1&gt;/mg;
            my $web = Obj::web();
            $web->web_script_form('alert',$msg);
        }
    }
    if ($prod->svs()) {
        $msg = Msg::new("Refer to $prod->{name} installation and configuration guide for how to set up VirtualStore and register VMware vSphere Plug-in for VirtualStore.");
        $msg->bold;
        Msg::n();
    }

    return;
}

# start CVM and CFS Agents
sub start_cvm_cfs_agents {
    my ($prod,$sys) = @_;
    my ($cvmstate,$grp,$sysi,$state,$vcs,$syslist,@fields);

    $vcs = $prod->prod('VCS60');
    return if $prod->{cvmcfs_started};
    $syslist=CPIC::get('systems');
    $cvmstate = $sys->cmd("$vcs->{bindir}/hagrp -display cvm -attribute State");
    for my $line (split(/\n/,$cvmstate)) {
        next if ($line=~/^#Group/);
        @fields = split(/\s+/, $line);
        $grp=$fields[0];
        $sysi=$fields[2];
        $state=$fields[3];

        # Only Online on nodes passed to CPI.
        # This is done to handle phased upgrades.
        for my $obj_sysi (@$syslist) {
            my $sysname = $obj_sysi->{vcs_sysname};
            if (($sysi eq $sysname) && ($state =~ /OFFLINE/m)) {
                Msg::log("Online cvm Group on $sysi");
                $sys->cmd("$vcs->{bindir}/hagrp -online $grp -sys $sysi");
                if (!EDR::cmdexit()) {
                    $sys->cmd("$vcs->{bindir}/hagrp -wait $grp State ONLINE -sys $sysi -time 300");
                } else {
                    Msg::log("Unable to online cvm service group on $sysi");
                }
                Msg::log("cvm Group on $sysi is online");
            }
        }
    }
    $prod->{cvmcfs_started}=1;

    return;
}

sub sfcfs_start_agents {
    my ($msg,$sys,$syslist,$cprod,$vm,$vcs);
    my $prod = shift;

    $syslist=CPIC::get('systems');
    $cprod=CPIC::get('prod');
    $cprod=~s/\d+$//m;
    $vm = $prod->prod('VM60');
    $vcs = $prod->prod('VCS60');

    Msg::log("\nConfiguring CFS agents:\n");
    Msg::log("Confirming $prod->{abbr} configuration daemon startup");

    for my $sys (@$syslist) {
        if ($vm->vold_status_sys($sys) ne 'enabled') {
            Msg::log('Disabled');
            $msg=Msg::new("Unable to complete $cprod configuration at this time.\n</opt/VRTS/bin/cfscluster config -s> must be run after the system is rebooted.");
            $sys->push_warning($msg);
            return 0;
        }
    }
    $prod->set_value('cfscluster_config_pending',0);
    Msg::log('All systems Enabled');
    # TODO: check for update
    return 1 if (Cfg::opt('upgrade'));
    Msg::log('Starting CFS agents');
    $sys = $$syslist[0];
    $sys->cmd('_cmd_cfscluster config -t 200 -s');
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("Unable to start CFS agents.");
        $sys->push_error($msg);
        $prod->set_value('cfscluster_config_pending',1);
        return 0;
    }
    Msg::log('CFS agents are started');

    # Copy CVMTypes.cf and CFSTypes.cf to /etc/VRTSvcs/conf for Dynamic Upgrade.
    for my $sys (@$syslist) {
        if (($sys->exists("$vcs->{configdir}/CVMTypes.cf"))
            && (!$sys->exists("$vcs->{confdir}/CVMTypes.cf"))) {
            $sys->cmd("_cmd_cp $vcs->{configdir}/CVMTypes.cf $vcs->{confdir}/CVMTypes.cf");
        }
        if (($sys->exists("$vcs->{configdir}/CFSTypes.cf"))
            && (!$sys->exists("$vcs->{confdir}/CFSTypes.cf"))) {
            $sys->cmd("_cmd_cp $vcs->{configdir}/CFSTypes.cf $vcs->{confdir}/CFSTypes.cf");
        }
    }
    return;
}

sub stop_agents_sys {
    my ($prod,$sys) = @_;
    my ($cfscluster,$fsclustadm);

    $cfscluster = $sys->cmd_bin('cfscluster');
    $fsclustadm = $sys->cmd_bin('fsclustadm');
    unless ($sys->exists($cfscluster) && $sys->exists($fsclustadm)){
        if ($sys->system1) {
            if ((Cfg::opt('upgrade'))) {
                EDRu::create_flag('stop_cvm_cfs_agents_done');
            }
            EDRu::create_flag('sfcfs_stop_agents_all_done');
        }
        return;
    }

    $prod->stop_odm_sys($sys);

    # If upgrade, do not stop VCS.
    # Just stop the CVM and CFS Agents. (Offline group cvm)
    if ((Cfg::opt('upgrade'))) {
        if ($sys->system1) {
            $prod->stop_cvm_cfs_agents($sys) if ($sys->{prod_running});
            EDRu::create_flag('stop_cvm_cfs_agents_done');
        } else {
            EDRu::wait_for_flag('stop_cvm_cfs_agents_done');
        }
        return 1;
    }

    if ($sys->system1) {
        $prod->sfcfs_stop_agents_all($sys);
        EDRu::create_flag('sfcfs_stop_agents_all_done');
    } else {
        EDRu::wait_for_flag('sfcfs_stop_agents_all_done');
    }

    return 1;

}

# used to get which groups should be offline before offlining $group
# returns @groups
sub all_groups_depend_on_group {
    my ($prod,$sys,$group) = @_;
    my ($vcs, @groups, $deps,@fields, @depgroups);
    $vcs = $prod->prod('VCS60');
    @groups = ();
    if ($group) {
        $deps = $sys->cmd("$vcs->{bindir}/hagrp -dep $group 2>/dev/null");
        for my $dep (split(/\n/,$deps)) {
            @fields=split(/\s/, $dep);
            next if ($fields[0] eq $group);
            next if ($fields[0] =~ /^#Parent/);
            @depgroups = $prod->all_groups_depend_on_group($sys, $fields[0]);
            if (@depgroups) {
                push(@groups, @depgroups);
            }
            push(@groups, $fields[0]);
        }
    }
    return @groups;
}

# stop CVM and CFS Agents
sub stop_cvm_cfs_agents {
    my ($prod,$sys) = @_;
    my ($padv,$port_f,$vcs,@deps,@cvmdeps,$syslist,$port_q);
    $syslist=CPIC::get('systems');
    $vcs = $prod->prod('VCS60');
    $padv=$sys->padv;

    Msg::log('Stopping CVM and CFS Agents');
    @cvmdeps = $prod->all_groups_depend_on_group($sys, 'cvm');
    if (@cvmdeps) {
        push(@deps, @cvmdeps);
    }
    push(@deps, 'cvm');
    $prod->offline_groups($sys,\@deps);
    for my $sys (@$syslist) {
        $port_f = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port f gen' ");
        my $sysname = $sys->{vcs_sysname};
        $sys->cmd("$vcs->{bindir}/hares -offline vxfsckd -sys $sysname")
            if (($port_f >=1) && ($sys->proc_pids('vxfsckd')));
        $sys->cmd('_cmd_fsclustadm cfsdeinit');
        # Stop Qlog
        $port_q = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port q gen' ");
        $padv->unload_driver_sys($sys,'qlog')
            if (($sys->sunos()) && ($port_q >= 1));
    }
    Msg::log('CVM and CFS Agents are stopped');
    return;
}

sub offline_groups {
    my ($prod,$sys,$deps) = @_;
    my ($grpstate,$sysi,$grp,$sys_master,$vxdctl_mode,$state,$vcs,$count,$syslist,@fields,@master_nodes,$temp_sys);
    $syslist=CPIC::get('systems');
    $vcs = $prod->prod('VCS60');

    for my $dep (@{$deps}) {
        $grpstate = $sys->cmd("$vcs->{bindir}/hagrp -display $dep -attribute State");
        @master_nodes = ();
        for my $line (split(/\n/,$grpstate)) {
            next if ($line=~/^#Group/);

            @fields = split(/\s+/, $line);
            $grp=$fields[0];
            $sysi=$fields[2];
            $state=$fields[3];

            # Only Offline on nodes passed to CPI.
            # This is done to handle phased upgrades.
            $count=0;
            for my $obj_sysi (@$syslist) {
                my $sysname = $obj_sysi->{vcs_sysname};
                if ($sysi eq $sysname) {
                    $temp_sys=$obj_sysi;
                    last;
                }
                $count ++;
            }
            next if ($count == scalar(@$syslist));
            # Offline Slave nodes before Master node.
            if ($grp eq 'cvm') {
                $vxdctl_mode = $temp_sys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'mode:'");
                if ($vxdctl_mode=~/MASTER/m) {
                    push(@master_nodes,$sysi);
                } else {
                    $prod->offline_group_sys($sys,$sysi,$grp,$state);
                }
            } else {
                $prod->offline_group_sys($sys,$sysi,$grp,$state);
            }
        }
        for my $sys_master (@master_nodes) {
            $prod->offline_group_sys($sys,$sys_master,$grp,$state);
        }
    }
    return;
}

sub offline_group_sys {
    my ($prod,$sys,$sysi,$grp,$state) = @_;
    my ($vcs);
    $vcs = $prod->prod('VCS60');
    if ($state =~ /FAULTED/m) {
        $sys->cmd("$vcs->{bindir}/hagrp -clear $grp -sys $sysi");
    }
    if ($state =~ /ONLINE|PARTIAL/mx) {
        $sys->cmd("$vcs->{bindir}/hagrp -offline $grp -sys $sysi");
        if (!EDR::cmdexit()) {
            $sys->cmd("$vcs->{bindir}/hagrp -wait $grp State OFFLINE -sys $sysi -time 300");
        } else {
            Msg::log("Unable to offline $grp on $sysi");
        }
    }
    return;
}

# Common define for AIX and Linux.
# Solaris and HPUX will define their own sfcfs_stop_agents_all
sub sfcfs_stop_agents_all {
    my ($prod,$sys) = @_;
    my ($sysi,$port_h,$sys_master,$port_v,$vxdctl_mode,$padv,$syslist,$port_q,@master_nodes);
    $syslist=CPIC::get('systems');
    $padv = $sys->padv;

    for my $sysi (@$syslist) {
        $port_v = $sysi->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port v gen' ");
        $port_h = $sysi->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port h gen' ");
        if ($port_v >= 1) {
            if ($port_h == 0) {
                $sysi->cmd('_cmd_cfscluster start');
            }
        }
        # Stop Qlog only for SunOS
        if ($sys->sunos()) {
            $port_q = $sysi->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port q gen' ");
            $padv->unload_driver_sys($sysi,'qlog') if ($port_q >= 1);
        }
    }

    if ($prod->svs()) {
       my @cfsnfsdeps = $prod->all_groups_depend_on_group($sys, 'cfsnfssg');
       push (@cfsnfsdeps,'cfsnfssg');
       $prod->offline_groups($sys,\@cfsnfsdeps);
    }
    # Stop Slave nodes before Master node.
    for my $sysi (@$syslist) {
        $vxdctl_mode = $sysi->cmd("_cmd_vxdctl -c mode | _cmd_grep 'mode:'");
        if ($vxdctl_mode=~/MASTER/m) {
            push (@master_nodes, $sysi);
        } else {
            $prod->cfscluster_stop_sys($sysi);
        }
    }
    for my $sys_master (@master_nodes) {
        $prod->cfscluster_stop_sys($sys_master);
    }
    return;
}

sub cfscluster_stop_sys {
    my ($prod,$sys) = @_;
    Msg::log("Stopping Cluster Manager and Agents on $sys->{sys}");
    $sys->cmd('_cmd_cfscluster stop -f');
    $sys->cmd('_cmd_fsclustadm cfsdeinit');
    Msg::log("Cluster Manager and Agents on $sys->{sys} are stopped");
    return;
}

#installer should stop odm before stopping VCS because odm register on gab,
#if odm isn't stopped, gab can't be stopped also
sub stop_odm_sys {
    my ($prod,$sys) = @_;
    my ($odmver,$odmpkg,$odm,$gmspkg,$vxgms);
    $odmpkg=$sys->pkg('VRTSodm60');
    if (defined $odmpkg) {
        $odm=$sys->proc('odm60');
        $odmver=$odmpkg->version_sys($sys);
        $odm->stop_sys($sys)
            if ($odmver && ($odm->check_sys($sys,'prestop_sys')));
    }
    $gmspkg=$sys->pkg('VRTSgms60');
    if (defined $gmspkg) {
        $vxgms=$sys->proc('vxgms60');
        $vxgms->stop_sys($sys)
            if (($gmspkg->version_sys($sys)) && ($vxgms->check_sys($sys,'prestop_sys')));
    }
    return;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($pkgvers,$mpvers,$cpic,$rel,$cv,$pkg);
    my ($sfcfsha_licensed,$sfsybasece_licensed);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    return '' unless ($prod->{mainpkg});

    $pkg=$sys->pkg($prod->{mainpkg});
    $pkgvers=$pkg->version_sys($sys,$force_flag);
    $mpvers=$prod->{vers} if ($pkgvers && $prod->check_installed_patches_sys($sys,$pkgvers));
    $pkgvers= $prod->revert_base_version_sys($sys,$pkg,$pkgvers,$mpvers,$force_flag);
    $pkgvers = $prod->version_mapping($pkgvers) if $prod->can('version_mapping');

    if ($prod->sfsybasece()) {
        $sfcfsha_licensed=$rel->prod_licensed_sys($sys, 'SFCFSHA60');
        $sfsybasece_licensed=$rel->prod_licensed_sys($sys,$prod->{prodi});
        if ($pkgvers) {
            # if sfsybasece & sfcfsha are both not licensed, or both licensed
            if( ($sfcfsha_licensed && $sfsybasece_licensed) || 
                (!$sfcfsha_licensed && !$sfsybasece_licensed) ) {
                # if user is using sfsybasece script, assume it is sfsybasece
                return $pkgvers if($cpic->{script} =~ /sfsybasece/i);
                # if it's defined in $cpic->{prod} (user choose SFSYBASECE product in installer menu)
                return $pkgvers if ($cpic->{prod} && $cpic->{prod} =~ /SFSYBASECE/);
            } elsif ($sfsybasece_licensed) {
                # if only sfsybasece is licensed
                return $pkgvers;
            }
        }
        # in other scenario(e.g. no license upgrade with installer script), installer auto detect product. we assume product is SFCFSHA
        return '';
    }

    $cv=EDRu::compvers($pkgvers,$prod->{vers},2);
    if ($cv) {
        if ($rel->prod_licensed_sys($sys,$prod->{prodi})) {
            return ($mpvers || $pkgvers);
        }
    } else {
        return ($mpvers || $pkgvers);
    }
    return '';
}

sub description {
    my ($prod,$msg);
    $prod=shift;

    if ($prod->sfcfsha()) {
        $msg=Msg::new("Veritas Storage Foundation Clustered File System HA adds the full functionality of Veritas Cluster Server, and features the power and flexibility to protect everything from a single critical database instance to very large multi-application clusters in networked storage environments. In addition, increased automation and intelligent workload management allow cluster administrators to maximize individual resources by moving beyond reactive recovery to proactive management of availability and performance. SFCFS HA bundle includes support for application monitoring and failover through the Veritas Cluster Server product.");
        $msg->print;
    } elsif ($prod->svs()) {
        $msg=Msg::new("Symantec VirtualStore powered by VERITAS Cluster File System serves as a highly scalable, highly available NFS data storage for your VMware virtual machine images. VirtualStore is built on top of Symantec's Cluster File System which provides high availability and linear scalability across the cluster. With integration with VMware Virtual Center, VirtualStore gives you a complete solution for managing your VMware virtual machine images.");
        $msg->print;
    } else {
        $msg=Msg::new("Veritas Storage Foundation Clustered File System extends Veritas File System and Veritas Volume Manager to support shared data in a SAN environment. Using Veritas Storage Foundation Cluster File System, multiple servers can access shared storage and files, transparently to the applications and concurrently with each other. SFCFCS by itself is not licensed for application monitoring and is targeted for parallel applications, applications with their own built in high availability, or only the need for shared data access.");
        $msg->print;
    }
    return;
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);

    $cpic = Obj::cpic();
    $rel = $cpic->rel;
    my ($features,$fv,$vcs,$vm);
    # HA mode: check
    $features = $rel->feature_values_sys($sys, 'Mode#VERITAS Cluster Server');
    for my $fv (@$features) {
        if ($fv eq 'VCS') {
            $vcs = $sys->prod('VCS60');
            $vcs->is_features_licensed_sys($sys);
            last;
        }
    }

    # set vvr option per license check
    $vm=$sys->prod('VM60');
    $vm->vr_licensed_sys($sys);
    $vm->vfr_licensed_sys($sys);

    return $rel->prod_licensed_sys($sys);
}

sub reorder_vxglm {
    my ($prod,$ref_procs) = @_;
    my ($v,@a);
    if((EDRu::inarr('vxglm60', @{$ref_procs})) && (EDRu::inarr('had60', @{$ref_procs}))) {
        $ref_procs=EDRu::arrdel($ref_procs, 'vxglm60');
        for my $v (@{$ref_procs}) {
            if ($v eq 'had60') {
                push (@a,'vxglm60',$v);
            } else {
                push (@a,$v);
            }
        }
        return \@a;
    }
    return $ref_procs;
}

sub startprocs {
    my $prod=shift;
    return adjust_ru_procs() if(Cfg::opt('upgrade_nonkernelpkgs'));
    my $ref_procs = Prod::startprocs($prod);
    $ref_procs=$prod->reorder_vxglm($ref_procs);
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my ($vm,$ref_procs);
    return adjust_ru_procs() if(Cfg::opt('upgrade_nonkernelpkgs'));
    $vm = $prod->prod('VM60');
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $vm->verify_procs_list_sys($sys,$ref_procs,'start');
    $ref_procs=$prod->reorder_vxglm($ref_procs);
    return $ref_procs;
}

sub stopprocs {
    my $prod=shift;
    my ($ref_procs,$sfha);
    return adjust_ru_procs() if(Cfg::opt('upgrade_nonkernelpkgs'));
    $sfha = $prod->prod('SFHA60');
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $sfha->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my ($ref_procs,$sfha);
    return adjust_ru_procs() if(Cfg::opt('upgrade_nonkernelpkgs'));
    $sfha = $prod->prod('SFHA60');
    $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $sfha->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub postcheck_gabconfig_sys {
    my ($prod,$sys) = @_;
    my ($msg,$ports,%gab_ports,%gab_jeopardy_ports,$port,@jeopardy_ports,$line,$rtn,@ports);

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

    for my $port (qw(a b d f h u v w y)) {
        next if($port=~/d/m && $prod->sfsybasece());
        push (@ports, $port) unless($gab_ports{$port});
        push (@jeopardy_ports, $port) if($gab_jeopardy_ports{$port});
    }

    if (@ports) {
        $ports=join(',',@ports);
        $msg=Msg::new("The following gab ports are not started on $sys->{sys}:\n\t$ports");
        $sys->push_warning($msg);
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

sub postcheck_cvmconfig_sys{
    my ($prod,$sys) = @_;
    my ($msg,$provers,$cpic,$rtn,$rtn1,$tmpdir,$nodeid,$nodeid1,$output,$cprod,@m);
    $cpic=Obj::cpic();
    $rtn=$sys->cmd("_cmd_hasys -state $sys->{vcs_sysname} 2>/dev/null");
    $tmpdir=EDR::tmpdir();
    $cprod=CPIC::get('prod');
    $cprod=~s/\d+//g;
    if ($rtn !~/RUNNING/){
        $msg=Msg::new("$cprod is not in RUNNING status on $sys->{sys}. It is recommended to start VCS and then start or configure $cprod.");
        $sys->push_warning($msg);
        return 0;
    }
    if($sys->system1){
        $rtn=$sys->cmd("_cmd_hagrp -state cvm 2>/dev/null | _cmd_grep 'ONLINE' | _cmd_grep -v '#' | _cmd_sed -n '1p' |_cmd_awk '{print \$3}'");
        my $tsys=($Obj::pool{"Sys::$rtn"}) ? Obj::sys($rtn) : '';
        if($tsys){
            $provers=$tsys->cmd("_cmd_grep volboot /etc/vx/volboot 2>/dev/null | _cmd_awk '{print \$4}'");
            EDRu::writefile($provers, "$tmpdir/protocolversion", 1) if($provers);
        }
    }
    $rtn=$sys->cmd("_cmd_hagrp -state cvm -sys $sys->{vcs_sysname} 2>/dev/null");
    if($rtn !~/ONLINE/){
        $msg=Msg::new("CVM is not running on $sys->{sys}");
        push(@m,$msg);
        $rtn1=$sys->cmd("_cmd_grep '^group cvm ' /etc/VRTSvcs/conf/config/main.cf 2>/dev/null");
        unless($rtn1){
            $msg=Msg::new("\n\tThe group cvm is not configured on $sys->{sys}");
            push(@m,$msg);
        }

        $rtn1=$sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port b'");
        unless($rtn1){
            $msg=Msg::new("\n\tvxfen is not running on $sys->{sys}");
            push(@m,$msg);
        }
        $rtn1=$sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port a'");
        unless($rtn1){
            $msg=Msg::new("\n\tgab is not running on $sys->{sys}");
            push(@m,$msg);
        }

        $rtn1=$sys->cmd("/opt/VRTSvcs/bin/hagrp -value cvm AutoStartList 2>/dev/null | _cmd_grep $sys->{sys}");
        unless($rtn1){
            $msg=Msg::new("\n\tThe attribute AutoStartList is not configured on $sys->{sys}");
            push(@m,$msg);
        }
        $rtn1=$sys->cmd("_cmd_hares -value cvm_clus CVMNodeId 2>/dev/null");
        if($rtn1){
            $nodeid=$1 if($rtn1=~/$sys->{sys}\cI(\d+)/);
            $output=$sys->cmd("_cmd_grep $sys->{sys} /etc/llthosts 2>/dev/null");
            if($output){
                $nodeid1= $1 if($output=~/(\d+)\s+$sys->{vcs_sysname}/);
                if($nodeid ne $nodeid1){
                    $msg=Msg::new("\n\tThe attribute CVMNodeId is not consistent with the defenition in /etc/llthosts");
                    push(@m,$msg);
                }
            }
        }
        my ($pv,$localsys,$pv1,$out);
        $out=$sys->cmd("_cmd_grep volboot /etc/vx/volboot 2>/dev/null ");
        if($out){
            (undef,undef,undef,$pv)=split(/\s+/,$out);
        }

        $localsys = $prod->localsys;
        $pv1=$localsys->catfile("$tmpdir/protocolversion") if($localsys->exists("$tmpdir/protocolversion"));
        if($pv & $pv1 && ($pv ne $pv1)){
              $msg=Msg::new("\n\tCVM protocol version is $pv on $sys->{sys}. It is recommended to check the protocol version.");
              push(@m,$msg);
        }

        $sys->push_warning(@m);
        return 0;
    }
    return 1;
}

sub postcheck_fsproto_sys {
    my ($prod,$sys) = @_;
    my ($supported_protos,$current_proto,$max_proto,$msg,$currentmsg,$maxmsg,$supportedmsg,$versmsg);
    $currentmsg = Msg::new("Current version");
    $maxmsg = Msg::new("Latest version");
    $supportedmsg = Msg::new("Supported version(s)");
    if ($sys->exists($sys->padv->{cmd}{fsclustadm})) {
        $supported_protos = $sys->cmd("_cmd_fsclustadm protoversion 2>/dev/null | _cmd_grep '^local:' 2>/dev/null | awk '{print \$2}'");
        $current_proto = $sys->cmd("_cmd_fsclustadm protoversion 2>/dev/null | _cmd_grep '^local:' 2>/dev/null | awk '{print \$3}'");
        if ( $supported_protos && $current_proto && $current_proto ne '-') {
            $max_proto = (reverse sort {$a<=>$b} split(/,/,$supported_protos))[0];
            if ($current_proto != $max_proto) {
                $versmsg = sprintf("\n\t%-21s: %s\n\t%-21s: %s\n\t%-21s: %s", $currentmsg->{msg},$current_proto, $maxmsg->{msg},$max_proto, $supportedmsg->{msg},$supported_protos);
                $msg = Msg::new("VxFS cluster is not running at the latest protocol version on $sys->{sys}:$versmsg");
                $sys->push_warning($msg);
                return 0;
            }
        }
    }
    return 1;
}

sub postcheck_odmproto_sys {
    my ($prod,$sys) = @_;
    my ($supported_protos,$current_proto,$max_proto,$msg,$currentmsg,$maxmsg,$supportedmsg,$versmsg);
    $currentmsg = Msg::new("Current version");
    $maxmsg = Msg::new("Latest version");
    $supportedmsg = Msg::new("Supported version(s)");
    if ($sys->exists($sys->padv->{cmd}{odmclustadm})) {
        $supported_protos = $sys->cmd("_cmd_odmclustadm protoversion 2>/dev/null | _cmd_grep '^local:' 2>/dev/null | awk '{print \$2}'");
        $current_proto = $sys->cmd("_cmd_odmclustadm protoversion 2>/dev/null | _cmd_grep '^local:' 2>/dev/null | awk '{print \$3}'");
        if ( $supported_protos && $current_proto && $current_proto ne '-') {
            $max_proto = (reverse sort {$a<=>$b} split(/,/,$supported_protos))[0];
            if ($current_proto != $max_proto) {
                $versmsg = sprintf("\n\t%-21s: %s\n\t%-21s: %s\n\t%-21s: %s", $currentmsg->{msg},$current_proto, $maxmsg->{msg},$max_proto, $supportedmsg->{msg},$supported_protos);
                $msg = Msg::new("VxODM cluster is not running at the latest protocol version on $sys->{sys}:$versmsg");
                $sys->push_warning($msg);
                return 0;
            }
        }
    }
    return 1;
}

sub postcheck_mountedcfs_sys {
    my ($prod,$sys) = @_;
    my ($fs, $mounted_bds, $vcs, $vcs_bds, $dgname, $dgflag, $msg, $nonvcsbdsmsg);
    $fs= $prod->prod('FS60');
    $mounted_bds = $fs->mounted_vxfs_blockdevice_sys($sys);
    $vcs = $prod->prod('VCS60');
    $vcs_bds = $vcs->cfsmount_res_sys($sys);
    $nonvcsbdsmsg = '';
    for my $bd (@{$mounted_bds}) {
        if ($bd =~ /^\/dev\/vx\/dsk\/([^\/]*)\/.*$/mx) {
            $dgname = $1;
            $dgflag = $sys->cmd("_cmd_vxdg list $dgname 2>/dev/null | _cmd_grep '^flags:'");
            if ( $dgflag =~ /shared/) {
                if (!EDRu::inarr($bd, @{$vcs_bds})) {
                    $nonvcsbdsmsg .= "\n\t$bd";
                }
            }
        }
    }
    if ($nonvcsbdsmsg) {
        $msg = Msg::new("The following mounted CFS block devices are not configured in VCS on $sys->{sys}:$nonvcsbdsmsg");
        $sys->push_warning($msg);
        return 0;
    } else {
        return 1;
    }
}

sub register_postchecks_per_system {
    my ($prod,$sequence_id,$name,$desc,$handler);
    $prod=shift;
    $prod->perform_task('register_postchecks_per_system');

    $sequence_id=510;
    $name='cvmconfig';
    $desc=Msg::new("cvm status");
    $handler=\&postcheck_cvmconfig_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=511;
    $name='fsproto';
    $desc=Msg::new("CFS protocol version");
    $handler=\&postcheck_fsproto_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=512;
    $name='odmproto';
    $desc=Msg::new("ODM protocol version");
    $handler=\&postcheck_odmproto_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=513;
    $name='cfsmounts';
    $desc=Msg::new("Mounted CFS file systems");
    $handler=\&postcheck_mountedcfs_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    # need override VCS 330_gabconfig postcheck.
    $sequence_id=330;
    $name='gabconfig';
    $desc=Msg::new("gabconfig ports status");
    $handler=\&postcheck_gabconfig_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    return 1;
}

sub register_postchecks_per_cluster {
    my ($prod,$sequence_id,$name,$desc,$handler);
    $prod=shift;
    $prod->perform_task('register_postchecks_per_cluster');

    return 1;
}

sub addnode_poststart {
    my ($cfsnfssg,$firstnode,$msg,$out,$proc,$proci,$rtn,$startprocs,$sys,$sysi);
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    # start other SFCFS processes
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $startprocs = $prod->startprocs_sys($sys);
        for my $proci (@{$startprocs}) {
            $proc = $sys->proc($proci);
            next if ($proc->{donotstart});
            next if ($proc->check_sys($sys, 'prestart'));
            $msg = Msg::new("Starting $proc->{proc} on $sysi");
            if ($cpic->proc_start_sys($sys, $proc)) {
                CPIC::proc_start_passed_sys($sys, $proc);
                $msg->display_status();
            } else {
                CPIC::proc_start_failed_sys($sys, $proc);
                $msg->display_status('failed');
            }
        }
    }

    $msg = Msg::new("Configure CVM and CFS");
    $msg->left();
    $rtn = $prod->addnode_config_cvm_cfs();
    if ($rtn) {
        Msg::right_done();
    } else {
        Msg::right_failed();
    }

    if ($prod->svs()) {
        $rtn = $prod->addnode_config_cnfs();
    } else {
        # configure cnfs on new nodes if configured
        $out = $firstnode->cmd("_cmd_grep '^CFSSG_SVC_GRP' /opt/VRTSvxfs/cfs/lib/cfsadm.env 2> /dev/null");
        if ($out =~ /CFSSG_SVC_GRP\s*=\s*(.*)/m) {
            $cfsnfssg = $1;
            $cfsnfssg = EDRu::despace($cfsnfssg);
            $firstnode->cmd("_cmd_hagrp -display $cfsnfssg");
            if (!EDR::cmdexit()) {
                $rtn = $prod->addnode_config_cnfs();
                sleep 5;
            }
        }
        $rtn = $prod->addnode_mount_share_dg();
    }
    if (!$rtn) {
        $msg = Msg::new("Addnode poststart did not completed successfully");
        $sys->push_error($msg);
    }
    return $rtn;
}

sub addnode_config_cnfs {
    my ($msg,$status,$sys,$sysname);
    my $prod = shift;
    my $cfg = Obj::cfg();

    $status = 1;
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $sysname = $sys->{vcs_sysname};
        $msg = Msg::new("Configure clustered NFS on $sysname");
        $msg->left;
        $sys->cmd("_cmd_cfsshare addnode $sysname");
        if (EDR::cmdexit()) {
            $msg->right_failed();
            $status = 0;
        } else {
            $msg->right_done();
        }
    }
    return $status;
}

sub addnode_config_cvm_cfs {
    my ($firstnode,$n,$out,$rtn,$status,$sys,$sysi,$system,$vxfsckd,$vxfsckd_activation,$asymmetry_key,$asymmetry_value);
    my $prod = shift;
    my $cprod=CPIC::get('prod');
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS60');

    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    if (!EDRu::inarr('cvm', split (/\n/, $firstnode->cmd("$vcs->{bindir}/hagrp -list 2>/dev/null | _cmd_awk '{print \$1}' | _cmd_sort | _cmd_uniq")))) {
        Msg::log('Group cvm does not exist in cluster');
        return 1;
    }

    $status = 1;
    $vcs->haconf_makerw();
    # get ActivationMode attribute
    $out = $firstnode->cmd("$vcs->{bindir}/hares -list Group=cvm Type=CFSfsckd 2>/dev/null| _cmd_awk '{print \$1}'");
    $vxfsckd = (split(/\n/,$out))[0] if ($out);
    if ($vxfsckd) {
        $system = $firstnode->{vcs_sysname};
        $out = $firstnode->cmd("$vcs->{bindir}/hares -value $vxfsckd ActivationMode $system 2>/dev/null");
        chomp($out);
        $vxfsckd_activation = $out if ($out);
    }
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $system = $sys->{vcs_sysname};
        $n = $firstnode->cmd("$vcs->{bindir}/hasys -value $system LLTNodeId");
        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -modify cvm SystemList -add $system $n");
        if(EDRu::isverror($rtn)) {
            Msg::log("Modify cvm SystemList to add $sysi failed.");
            $status = 0;
        }

        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -modify cvm AutoStartList -add $system");
        if (EDRu::isverror($rtn)) {
            Msg::log("Modify cvm AutoStartList to add $sysi failed");
            $status = 0;
        }

        $rtn = $firstnode->cmd("$vcs->{bindir}/hares -modify cvm_clus CVMNodeId -add $system $n");
        if(EDRu::isverror($rtn)) {
            Msg::log("Modify cvm_clus CVMNodeId to add $sysi $n failed.");
            $status = 0;
        }

        # update ActivationMode attribute with new nodes
        if ($vxfsckd_activation) {
            $rtn=$firstnode->cmd("$vcs->{bindir}/hares -modify $vxfsckd ActivationMode $vxfsckd_activation -sys $system");
            if(EDRu::isverror($rtn)) {
                Msg::log("Modify $vxfsckd ActivationMode to add $sysi failed.");
                $status = 0;
            }
        }
    }
    $vcs->haconf_dumpmakero();

    # Run vxclustadm on all nodes of the cluster except new nodes
    for my $sysi (@{$cfg->{clustersystems}}) {
        $sys = Obj::sys($sysi);
        $rtn = $sys->cmd("$prod->{cfsbin}/vxclustadm -m vcs -t gab reinit");
        if (EDRu::isverror($rtn)) {
            Msg::log('Make the nodes of the cluster re-read the cluster configuration file failed.');
            $status = 0;
        }
    }

    # set the asymmetry value on all new nodes, according to the value of existing node
    # changed to storage_connectivity using the command vxtune, refer to e2744683
    $asymmetry_key = 'storage_connectivity';
    $rtn = $firstnode->cmd("_cmd_vxtune -o local $asymmetry_key");
    if ((!EDRu::isverror($rtn)) && ($rtn =~ /$asymmetry_key\s+(\w+)/)) {
        $asymmetry_value = $1;
        for my $sysi (@{$cfg->{newnodes}}) {
            $sys = Obj::sys($sysi);
            # next if the value is the same as nodeone
            $rtn = $sys->cmd("_cmd_vxtune -o local $asymmetry_key");
            if ((!EDRu::isverror($rtn)) && ($rtn =~ /$asymmetry_key\s+(\w+)/)) {
                next if ($asymmetry_value eq $1);
            } else {
                Msg::log("Get tunable $asymmetry_key failed on $sysi.");
                $status = 0;
                next;
            }

            $rtn = $sys->cmd("_cmd_vxtune -o local $asymmetry_key $asymmetry_value");
            if (EDRu::isverror($rtn)||EDR::cmdexit()) {
                Msg::log("Set tunable $asymmetry_key to $asymmetry_value failed on $sysi.");
                $status = 0;
            }
        }
    } else {
        Msg::log("Get tunable $asymmetry_key failed on $firstnode->{sys}");
        $status = 0;
    }

    # Make newnode cvm online
    if ($cprod ne 'SFRAC60') {
        # Make newnode cvm online
        for my $sysi (@{$cfg->{newnodes}}) {
            $sys = Obj::sys($sysi);
            $system = $sys->{vcs_sysname};
            # Run hagrp on one node of cluster
            $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -online cvm -sys $system");
            if (EDRu::isverror($rtn)) {
                Msg::log("Make cvm online failed on $sysi");
                $status = 0;
            }
            $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -wait cvm State ONLINE -sys $system -time 120");
            if (EDRu::isverror($rtn)||EDR::cmdexit()) {
                Msg::log("Waiting for cvm state online failed on $sysi.");
                $status = 0;
            }
        }
    } else {
        #
        # Start cvm resources only because the sfrac resources in cvm group
        # are still not configured for new nodes.
        #
        for my $sysi (@{$cfg->{newnodes}}) {
            $sys = Obj::sys($sysi);
            $system = $sys->{vcs_sysname};
            for my $resname (qw/cvm_vxconfigd cvm_clus vxfsckd/ ) {
                $rtn = $firstnode->cmd("$vcs->{bindir}/hares -online $resname -sys $system");
                if (EDRu::isverror($rtn)) {
                    Msg::log("Make $resname online failed on $sysi");
                    $status = 0;
                }
                $rtn = $firstnode->cmd("$vcs->{bindir}/hares -wait $resname State ONLINE -sys $system -time 120");
                if (EDRu::isverror($rtn)||EDR::cmdexit()) {
                    Msg::log("Waiting for $resname state online failed on $sysi.");
                    $status = 0;
                }
            }
        }
    }
    return $status;
}

sub addnode_mount_share_dg {
    my ($ayn,$activemode,$failed,$firstnode,$msg,$mount_info,$mounted,$mount_point,$mount_option,$n,$primary_node,$output,$rtn,$sharedg,$sharevol,@sharevols,$sys,$sysi,$system,$master_node,@lines,@fields);
    my $prod = shift;
    my $cfg = Obj::cfg();
    my $cprod=CPIC::get('prod');
    my $vcs = $prod->prod('VCS60');
    my ($cvmgroupstate, $resnames, @resnames, $depresnames, @depresnames, $restype, $cfsmount_res_in_cvm, $cvmvoldg_res_in_cvm);
    my ($dgstate,$state,@ldisabled_vols);

    $state = 'LDISABLED';
    $dgstate = {};
    $failed = 0;
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    # get the share volume and its mount point from first node of the cluster
    $output = $firstnode->cmd("_cmd_cfsmntadm display 2>/dev/null | _cmd_grep 'MOUNTED' | _cmd_sort -u ");
    if (EDR::cmdexit()) {
        Msg::log('cfsmntadm display error.');
        return 1;
    }
    @lines = split(/\n/,$output);
    foreach (@lines) {
        ($mount_point,undef,$sharevol,$sharedg,$mounted) = split;
        if($mounted eq 'MOUNTED') {
            $sysi = ${$cfg->{newnodes}}[0];
            $sys = Obj::sys($sysi);
            $system = $sys->{vcs_sysname};
            $output = $firstnode->cmd("_cmd_cfsmntadm display $mount_point");
            if ((!EDR::cmdexit()) && ($output =~ /\n\s*$system\s+MOUNTED/m)) {
                Msg::log("Shared volume $sharevol is already mounted on mount point $mount_point of system $sysi");
                next;
            }
            push (@sharevols,[$sharevol,$mount_point,$sharedg]);
        }
    }

    $n = scalar @sharevols;
    unless ($n > 0 ) {
        Msg::log('No share disk resources were found in cluster');
        return 1;
    }
    $msg = Msg::new("The cluster has $n shared volumes mounted\n");
    $msg->print;
    printf("%18s %18s %18s \n",'shared_volumes','mounted_point','shared_disk_group');
    my $web_str = EDRu::fixed_length_str('shared_volumes',30,'L');
    $web_str .= EDRu::fixed_length_str('mounted_point',30,'L');
    $web_str .= EDRu::fixed_length_str('shared_disk_group',30,'R');
    $web_str .= "\\n";
    for my $mount_info (@sharevols) {
        printf("%18s %18s %18s \n",$mount_info->[0], $mount_info->[1],$mount_info->[2]);
        $web_str .= EDRu::fixed_length_str($mount_info->[0],30,'L');
        $web_str .= EDRu::fixed_length_str($mount_info->[1],30,'L');
        $web_str .= EDRu::fixed_length_str($mount_info->[2],30,'R');
        $web_str .= "\\n";
    }
    $web_str =~ s/\s/&nbsp;/mg;
    my $web = Obj::web();
    $web->web_script_form('alert',$web_str) if (Obj::webui());

    $master_node = $firstnode->cmd("_cmd_vxdctl -c mode |_cmd_grep '^master:'| _cmd_awk '{print \$2}'");
    if( ! $master_node) {
        Msg::log("There is no master node. Use $firstnode->{sys} instead.");
        $master_node = $firstnode->{sys};
    }
    for my $sysi (@{$cfg->{newnodes}}) {
        @ldisabled_vols = ();
        for my $mount_info (@sharevols) {
            my $sysnew = Obj::sys($sysi);
            push (@ldisabled_vols,$mount_info->[0]) if $prod->is_ioship_on_and_ldisabled_sys($sysnew,$mount_info->[0],$mount_info->[2],$dgstate);
        }

        # ask user whether wants to mount these shared volumes on the new node.
        # if "Y", add them on new node, otherwise, do nothing on new node.
        $cvmgroupstate = $sys->cmd("_cmd_hagrp -state cvm -sys $sys->{vcs_sysname} ");
        if ($cprod =~ /^SFRAC\d+/mx && $cvmgroupstate ne 'ONLINE') {
            $msg = Msg::new("The cluster has above shared volumes. Due to service group dependencies, these shared volumes cannot be mounted before cvm service group is online on $sysi. Would you like to configure these shared volumes on $sysi?");
        } else {
            $msg = Msg::new("The cluster has above shared volumes. Would you like to mount these shared volumes on $sysi?");
        }
        if(scalar @ldisabled_vols){
            my $ldisabled_vols = join(',',@ldisabled_vols);
            my $ldisabled_msg = Msg::new(" (Will skip volumn(s) which are in $state state: $ldisabled_vols)");
            $msg->{msg}.=$ldisabled_msg->{msg};
        }
        $ayn = $msg->ayny();
        if( $ayn eq 'N'){
            if ($cprod =~ /^SFRAC\d+/mx && $cvmgroupstate ne 'ONLINE') {
                $cfsmount_res_in_cvm = $sys->cmd("_cmd_hares -list Type=CFSMount Group=cvm 2>/dev/null | _cmd_awk '{print \$1}' 2>/dev/null |_cmd_sort -u");
                $cfsmount_res_in_cvm = join("\n\t",split(/\n/,$cfsmount_res_in_cvm));
                $cvmvoldg_res_in_cvm = $sys->cmd("_cmd_hares -list Type=CVMVolDg Group=cvm 2>/dev/null | _cmd_awk '{print \$1}' 2>/dev/null |_cmd_sort -u");
                $cvmvoldg_res_in_cvm = join("\n\t",split(/\n/,$cvmvoldg_res_in_cvm));
                if ($cfsmount_res_in_cvm || $cvmvoldg_res_in_cvm) {
                    if ($cfsmount_res_in_cvm) {
                        if ($cvmvoldg_res_in_cvm) {
                            $msg = Msg::new("As you selected not to configure these shared volumes on $sysi, before cvm service group can be brought online on this system, you must manually update NodeList and MountOpt attributes for the following CFSMount resources configured in cvm service group\n\n\t$cfsmount_res_in_cvm\n\nand CVMActivation attribute for the following CVMVolDg resources configured in cvm service group\n\n\t$cvmvoldg_res_in_cvm");
                        } else {
                            $msg = Msg::new("As you selected not to configure these shared volumes on $sysi, before cvm service group can be brought online on this system, you must manually update NodeList and MountOpt attributes for the following CFSMount resources configured in cvm service group\n\n\t$cfsmount_res_in_cvm");
                        }
                    } else {
                        $msg = Msg::new("As you selected not to configure these shared volumes on $sysi, before cvm service group can be brought online on this system, you must manually update CVMActivation attribute for the following CVMVolDg resources configured in cvm service group\n\n\t$cvmvoldg_res_in_cvm");
                    }
                    if (Obj::webui()) {
                        $web_str = $msg->{msg};
                        $web_str =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
                        $web_str =~ s/\n\n/<br\/>&nbsp;<br\/>/g;
                        $web_str =~ s/\n/<br\/>/g;
                        $web->web_script_form('alert',$web_str);
                        Msg::log($web_str);
                    } else {
                        $msg->print();
                        Msg::prtc();
                    }
                }
            }
            next;
        }
        $sys = Obj::sys($sysi);
        $system = $sys->{vcs_sysname};
        for my $mount_info (@sharevols) {
            $sharevol = $mount_info->[0];
            $mount_point = $mount_info->[1];
            $sharedg = $mount_info->[2];
            next if EDRu::inarr($sharevol, @ldisabled_vols);
            if ($cprod =~ /^SFRAC\d+/mx && $cvmgroupstate ne 'ONLINE') {
                $msg = Msg::new("Configuring mountpoint $mount_point for $sysi");
            } else {
                $msg = Msg::new("Mounting $sharevol on $mount_point for $sysi");
            }
            $msg->left;

            $activemode = undef;
            $output = $firstnode->cmd(" _cmd_cfsdgadm display $sharedg | _cmd_sed -e '1d' ");
            @lines = split(/\n/,$output);
            for ( @lines ) {
                @fields = split;
                if ( $fields[0] eq "$master_node" ) {
                    $activemode = $fields[1];
                    last;
                }
            }
            if($activemode) {
                # check whether the new node has added sharedg, if no, add the sharedg for the new node
                $rtn = undef;
                for ( @lines ) {
                    @fields = split;
                    if ( $fields[0] eq "$system" ) {
                        $rtn = $fields[0];
                        last;
                    }
                }
                if (! $rtn) {
                    $rtn = $firstnode->cmd("_cmd_cfsdgadm add $sharedg $system=$activemode");
                    if (EDRu::isverror($rtn)) {
                        Msg::log("Failed to add shared disk group $sharedg on $sysi");
                        Msg::right_failed();
                        $failed++;
                        next;
                    }
                }
            }

            $primary_node = $firstnode->cmd("_cmd_fsclustadm -v showprimary $mount_point");
            Msg::log("The primary node is $primary_node");
            $mount_option = '';
            $output = $firstnode->cmd("_cmd_cfsmntadm display -v $primary_node | _cmd_sed -e '1,2d'");
            @lines = split(/\n/,$output);
            for ( @lines ) {
                @fields = split;
                if ( $fields[0] eq "$mount_point" && $fields[2] eq "$sharevol" && $fields[3] eq "$sharedg" ) {
                    $mount_option = $fields[5];
                    last;
                }
            }
            # mount_option could be ""
            if (! $mount_option ) {
                $mount_option = '';
            }
            Msg::log("The mount_options of primary node is $mount_option");
            $rtn = $firstnode->cmd("_cmd_cfsmntadm modify $mount_point add $system=$mount_option");
            if (EDRu::isverror($rtn)) {
                Msg::log("Failed to modify $mount_point/$mount_option on $sysi: $rtn");
                Msg::right_failed();
                $failed++;
                next;
            }
            # make sure CVMActivation of CVMVolDg is added for $mount_point on $sys
            $resnames = $sys->cmd("_cmd_hares -list Type=CFSMount MountPoint='$mount_point' 2>/dev/null |_cmd_awk '{print \$1}' 2>/dev/null |sort -u ");
            @resnames = split(/\n/,$resnames);
            if ( scalar @resnames > 0) {
                if (scalar @resnames > 1) {
                    Msg::log("Multiple CFSMount resourses defined for mount point $mount_point");
                }
                for my $cfsmntres (@resnames) {
                    $depresnames =$sys->cmd("_cmd_hares -dep $cfsmntres 2>/dev/null | _cmd_sed '1d' 2>/dev/null | _cmd_awk  '{print \$3}'");
                    @depresnames = split(/\n/,$depresnames);
                    for my $dep (@depresnames) {
                        next if ($dep eq $cfsmntres);
                        $restype = $sys->cmd("_cmd_hares -value $dep Type");
                        chomp $restype;
                        next if ($restype ne 'CVMVolDg');
                        $activemode = $sys->cmd("_cmd_hares -value $dep CVMActivation $sys->{vcs_sysname}");
                        chomp $activemode;
                        if ( ! $activemode ) {
                            $activemode = $sys->cmd("_cmd_hares -value $dep CVMActivation $firstnode->{vcs_sysname}");
                            chomp $activemode;
                            if ($activemode) {
                                $sys->cmd("$vcs->{bindir}/haconf -makerw");
                                $sys->cmd("_cmd_hares -modify $dep CVMActivation $activemode -sys $system");
                                $sys->cmd("$vcs->{bindir}/haconf -dump -makero");
                            } else {
                                Msg::log("No CVMActivation defined for $dep on $firstnode->{vcs_sysname} or $system");
                            }
                        }
                    }
                }
            } else {
                Msg::log("No CFSMount resourse defined for mount point $mount_point");
            }

            if ($cprod =~ /^SFRAC\d+/mx && $cvmgroupstate ne 'ONLINE') {
                $rtn = 1; # For SFRAC, deferring mounting shared DGs until SFRAC is fully configured on new nodes.
            #    $failed++;
                next;
            } else {
                $rtn = $firstnode->cmd("_cmd_cfsmount $mount_point $system");
            }
            if (EDRu::isverror($rtn)) {
                Msg::log("Failed to mount $mount_point on $sysi: $rtn");
                Msg::right_failed();
                $failed++;
                next;
            }

            Msg::right_done();
        }

        if ($failed == 0) {
            Msg::log("Successfully mounted all shared resources on $sysi");
        } elsif ($failed == $n){
            Msg::log("Failed to mount all shared resources on $sysi");
        } else {
            Msg::log("Partially failed to mount shared resources on $sysi with status: $failed");
        }
    }
    return (!$failed);
}

sub sfcfsha {
    my $prod=shift;
    return 1 if ($prod->{class} =~ /SFCFSHA/m);
    return 0;
}

# return 1 only if the dg is iostate:on and 
sub is_ioship_on_and_ldisabled_sys {
    my ($prod,$sys,$vol,$dg,$dgstate) = @_;
    my ($rtn,$state);

    $state = 'LDISABLED';
    # no need to check the dg's ioship state
#    unless(defined $dgstate->{$dg}{ioship}) {
#        $rtn = $sys->cmd("_cmd_vxdg list $dg 2>/dev/null");
#        if ($rtn =~ /^\s*ioship\s*:\s*(\S+)/m) {
#            $dgstate->{$dg}{ioship} = $1;
#        } else {
#            return 0;
#        }
#    }
    # not fit if the ioship is not on
#    return 0 unless ($dgstate->{$dg}{ioship} =~ /on/);

    #
    $rtn = $sys->cmd("_cmd_vxprint -g $dg 2>/dev/null");
    return 1 if ($rtn =~ /\s+$vol\s+.*$state/m);
    return 0;
}

sub svs {
    my $prod=shift;
    return 1 if ($prod->{class} =~ /SVS/m);
    return 0;
}

sub sfsybasece {
    my $prod=shift;
    return 1 if ($prod->{class} =~ /SFSYBASECE/m);
    return 0;
}

sub get_supported_tunables {
    my ($prod) =@_;
    my ($tunables,$sfha, $sfcfsha);
    $tunables = [];
    push @$tunables, @{$prod->get_tunables};
    if ($prod->svs() || $prod->sfsybasece()) {
        $sfcfsha=$prod->prod('SFCFSHA60');
        push @$tunables, @{$sfcfsha->get_supported_tunables};
    } else {
        $sfha=$prod->prod('SFHA60');
        push @$tunables, @{$sfha->get_supported_tunables};
    }
    return $tunables;
}

package Prod::SFCFSHA60::AIX;
@Prod::SFCFSHA60::AIX::ISA = qw(Prod::SFCFSHA60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='sfcfsha';
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0)];
    $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw.rte VRTSdbac60 VRTSdbac.rte VRTSvbs60 VRTSvcsea60 VRTScfsdc
        VRTSodm60 VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi.rte
        VRTSd2doc VRTSordoc VRTSfppm VRTSap VRTStep VRTSvcsdb.rte
        VRTSvcsor.rte VRTSgapms.VRTSgapms VRTSmapro VRTSvail.VRTSvail
        VRTSd2gui VRTSorgui VRTSvxmsa VRTSdbdoc VRTSdb2ed VRTSdbed60
        VRTSdbcom VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw.rte
        VRTScspro VRTSvcsdb.rte VRTSvcssy.rte VRTScmccc.rte
        VRTScmcs.rte VRTSacclib52 VRTSacclib.rte VRTScscm.rte
        VRTScscw.rte VRTScssim.rte VRTScutil VRTScutil.rte
        VRTSvcs.doc VRTSvcs.man VRTSvcs.msg.en_US VRTSvcsag60
        VRTSvcsag.rte VRTScps60 VRTSvcs60 VRTSvcs.rte VRTSamf60 VRTSvxfen60
        VRTSvxfen.rte VRTSgab60 VRTSgab.rte VRTSllt60 VRTSllt.rte
        VRTSfsmnd VRTSfssdk60 VRTSfsadv60 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb.rte VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid.rte
        VRTSalloc VRTSvsvc VRTSvmpro VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSat.server VRTSat.client VRTSsmf VRTSpbx
        VRTSicsco VRTSvxfs60 VRTSvxvm60 VRTSveki60 VRTSjre15.rte
        VRTSjre.rte VRTSsfcpi602 VRTSperl514 VRTSperl.rte VRTSvlic32
    ) ];

    return;
}

# to handle VRTScavf version is 1.0.4 in 4.0MP4 release.
sub version_mapping {
    my ($prod,$vers)=@_;
    $vers='4.0.4' if (EDRu::compvers($vers, '1.0.4', 3)==0);
    return $vers;
}

package Prod::SFCFSHA60::HPUX;
@Prod::SFCFSHA60::HPUX::ISA = qw(Prod::SFCFSHA60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_cluster_file_system_ha';
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1 6.0)];
    $prod->{zru_releases}=[qw()];
    $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSdbckp VRTSormap VRTScsocw VRTSdbac60 VRTSvbs60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi VRTSd2doc VRTSordoc
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSgapms VRTSmapro
        VRTSvail VRTSd2gui VRTSorgui VRTSvxmsa VRTSvrdev VRTSdbdoc VRTSdb2ed
        VRTSdbed60 VRTSdbcom VRTSsydoc VRTSsybed VRTSvcsApache
        VRTScmc VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor
        VRTSvcssy VRTScmccc VRTScmcs VRTScscm VRTScscw
        VRTScssim VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg
        VRTSvcsag60 VRTScps60 VRTSvcs60 VRTSamf60 VRTSvxfen60 VRTSgab60
        VRTSllt60 VRTSfsmnd VRTSfssdk60 VRTSfsadv60 VRTSfsdoc VRTSfsman
        VRTSvrdoc VRTSvrw VRTSvrmcsg VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr
        VRTSvdid VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc
        VRTSvmman SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui
        VRTSfspro VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxvm60
        VRTSjre15 VRTSjre VRTSsfcpi602 VRTSperl514 VRTSvlic32 VRTSwl
    ) ];
    return;
}


package Prod::SFCFSHA60::Linux;
@Prod::SFCFSHA60::Linux::ISA = qw(Prod::SFCFSHA60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_cluster_file_system_ha';
    $prod->{upgradevers}=[qw(5.0.30 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0.30 5.1 6.0)];
    $prod->{menu_options}=['Veritas Volume Replicator','Veritas File Replicator','Global Cluster Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSvbs60 VRTSvcsea60 VRTScfsdc VRTSodm60 VRTSodm-platform
        VRTSodm-common VRTSgms60 VRTSsvs60 VRTScavf60 VRTSglm60 VRTScpi
        VRTSd2doc VRTSordoc VRTSfsnbl VRTSfppm VRTSap VRTStep
        VRTSgapms VRTSmapro-common VRTSvail VRTSd2gui-common
        VRTSorgui-common VRTSvxmsa VRTSdbdoc VRTSdb2ed-common
        VRTSdbed60 VRTSdbed-common VRTSdbcom-common VRTSsybed-common
        VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw VRTScspro
        VRTSvcsdb VRTSvcsor VRTSvcssy VRTScmccc VRTScmcs
        VRTScscm VRTScscw VRTScssim VRTScutil VRTSvcsdc VRTSvcsmn
        VRTSvcsmg VRTSvcsdr60 VRTSvcsag60 VRTScps60 VRTSvcs60 VRTSamf60
        VRTSvxfen60 VRTSgab60 VRTSllt60 VRTSfsmnd VRTSfssdk60
        VRTSfsadv60 VRTSfsdoc VRTSfsman VRTSvrdoc VRTSvrw VRTSweb VRTSvcsvr
        VRTSvrpro VRTSalloc VRTSdcli VRTSvsvc VRTSvmpro VRTSddlpr
        VRTSvdid VRTSlvmconv60 VRTSvmdoc VRTSvmman SYMClma
        VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSatClient50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60
        VRTSvxfs-platform VRTSvxfs-common VRTSvxvm60 VRTSvxvm-platform
        VRTSvxvm-common VRTSjre15 VRTSjre VRTSsfcpi602 VRTSperl514 VRTSvlic32
    ) ];
    return;
}

package Prod::SFCFSHA60::RHEL5x8664;
@Prod::SFCFSHA60::RHEL5x8664::ISA = qw(Prod::SFCFSHA60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } elsif ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60) ];
    }
    return;
}

package Prod::SFCFSHA60::RHEL6x8664;
@Prod::SFCFSHA60::RHEL6x8664::ISA = qw(Prod::SFCFSHA60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } elsif ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60 SFSYBASECE60) ];
    }
    return ;
}

package Prod::SFCFSHA60::RHEL6ppc64;
@Prod::SFCFSHA60::RHEL6ppc64::ISA = qw(Prod::SFCFSHA60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } elsif ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60 SFSYBASECE60) ];
    }
    return ;
}

package Prod::SFCFSHA60::SLES10x8664;
@Prod::SFCFSHA60::SLES10x8664::ISA = qw(Prod::SFCFSHA60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } elsif ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60 SFSYBASECE60) ];
    }
    return ;
}

package Prod::SFCFSHA60::SLES11x8664;
@Prod::SFCFSHA60::SLES11x8664::ISA = qw(Prod::SFCFSHA60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } elsif ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60 SFSYBASECE60) ];
    }
    return ;
}

package Prod::SFCFSHA60::SLES11ppc64;
@Prod::SFCFSHA60::SLES11ppc64::ISA = qw(Prod::SFCFSHA60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } elsif ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60 SFSYBASECE60) ];
    }
    return ;
}

package Prod::SFCFSHA60::SunOS;
@Prod::SFCFSHA60::SunOS::ISA = qw(Prod::SFCFSHA60::Common);

sub init_plat {
    my $prod=shift;
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } else {
        $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='storage_foundation_cluster_file_system_ha';
    }

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSdbac60 VRTSvbs60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSgms60 VRTSsvs60 VRTScavf60 VRTSglm60 VRTScpi VRTSd2doc VRTSordoc
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSspc VRTSspcq
        VRTSfasdc VRTSfasag VRTSfas VRTSgapms VRTSmapro VRTSvail
        VRTSd2gui VRTSorgui VRTSvxmsa VRTSdbdoc VRTSdb2ed VRTSdbed60
        VRTSdbcom VRTSsydoc VRTSsybed VRTSvcsApache VRTScmc
        VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy
        VRTScmccc VRTScmcs VRTSacclib52 VRTScscm VRTScscw VRTScssim
        VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsag60
        VRTScps60 VRTSvcs60 VRTSamf60 VRTSvxfen60 VRTSgab60 VRTSllt60
        VRTSfsmnd VRTSfssdk60 VRTSfsadv60 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid
        VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxvm60
        VRTSjre15 VRTSjre VRTSsfcpi602 VRTSperl514 VRTSvlic32
    ) ];
    return;
}

package Prod::SFCFSHA60::SolSparc;
@Prod::SFCFSHA60::SolSparc::ISA = qw(Prod::SFCFSHA60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0)];
    if ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60 SFSYBASECE60) ];
    }
    return;
}

package Prod::SFCFSHA60::Sol11sparc;
@Prod::SFCFSHA60::Sol11sparc::ISA = qw(Prod::SFCFSHA60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } else {
        $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
        $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='storage_foundation_cluster_file_system_ha';
    }

    if ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60) ];
    }
    return;
}

package Prod::SFCFSHA60::Solx64;
@Prod::SFCFSHA60::Solx64::ISA = qw(Prod::SFCFSHA60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0)];
    if ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60) ];
    }
    return;
}

package Prod::SFCFSHA60::Sol11x64;
@Prod::SFCFSHA60::Sol11x64::ISA = qw(Prod::SFCFSHA60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    if ($prod->svs()) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } else {
        $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
        $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='storage_foundation_cluster_file_system_ha';
    }

    if ($prod->sfcfsha) {
        $prod->{licsuperprods}=[ qw(SFRAC60) ];
    }
    return;
}

1;
