use strict;

package Prod::SFCFS60::Common;
@Prod::SFCFS60::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{vers}='6.0.001.000';

    if ($prod->{class}=~/SFCFSHA/m) {
        $prod->{prod}='SFCFSHA';
        $prod->{abbr}='SFCFSHA';
        $prod->{name}=Msg::new("Veritas Storage Foundation Cluster File System/HA")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
        $prod->{proddir}='storage_foundation_cluster_file_system';
        $prod->{eula}='EULA_CFSHA_Ux_6.0.pdf';

        # Use SFCFS60 as product name in installer script for SFCFSHA60.
        # Use installsfcfs/uninstallsfcfs as installer script name for SFCFSHA60.
        $prod->{installscript_prod}='SFCFS60';
        $prod->{installscript_name}='SFCFS';
        $prod->{mainpkg}='VRTScavf60';

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];
    } elsif ($prod->{class}=~/SVS/m) {
        $prod->{prod}='SVS';
        $prod->{abbr}='SVS';
        $prod->{name}=Msg::new("Symantec VirtualStore")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
        $prod->{not_prompt_minpkgs_warning}=1;
        $prod->{proddir}='virtualstore';
        $prod->{eula}='EULA_VirtualStore_Ux_6.0.pdf';
        $prod->{mainpkg}='VRTSsvs60';

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];
    } elsif ($prod->{class}=~/SFSYBASECE/m) {
        $prod->{prod}='SFSYBASECE';
        $prod->{abbr}='SFSYBASECE';
        $prod->{name}=Msg::new("Veritas Storage Foundation for Sybase ASE CE")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];
        $prod->{proddir}='storage_foundation_for_sybase_ce';
        $prod->{eula}='EULA_SFSybasece_Ux_6.0.pdf';

        $prod->{installscript_prod}='SFSYBASECE60';
        $prod->{installscript_name}='SFSYBASECE';
        $prod->{lic_names}=['Veritas Storage Foundation for Sybase ASE CE'];
        $prod->{mainpkg}='VRTScavf60';

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];
    } else {
        $prod->{prod}='SFCFS';
        $prod->{abbr}='SFCFS';
        $prod->{name}=Msg::new("Veritas Storage Foundation Cluster File System")->{msg};
        $prod->{menu_options}=['Veritas Volume Replicator'];
        $prod->{proddir}='storage_foundation_cluster_file_system';
        $prod->{eula}='EULA_CFS_Ux_6.0.pdf';
        $prod->{mainpkg}='VRTScavf60';

        $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];
    }
    $prod->{subprods}=[qw(VCS60 SF60 SFHA60)];

    $prod->{upgrade_flag_file}="/opt/VRTS/install/.$prod->{prod}.upgrade";

    if ($prod->{class}=~/SVS/m) {
        $prod->{lic_names}=['Symantec VirtualStore'];
    } elsif ($prod->{class}=~/SFSYBASECE/m) {
        $prod->{lic_names}=['Veritas Storage Foundation for Sybase ASE CE'];
    } else {
        $prod->{lic_names}=['Storage Foundation for Cluster File System',
                            'SANPoint Foundation Suite',
                            'Storage Foundation Cluster File System'];
    }

    $prod->{responsefileupgradeok}=1;
    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv VRTSamf) ];

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
       if($prod->{class}=~/SFSYBASECE/m){
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
    return 1 if (($cprod =~/SFCFS(\d+)/m) && $prod->{class}=~/SFCFSHA/m );
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
        $sysname=Prod::VCS60::Common::transform_system_name($sys->{sys});
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

    $sysname=Prod::VCS60::Common::transform_system_name($sys->{sys});
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
    my ($cpic,$cfg,$mprod);

    return unless (Cfg::opt('makeresponsefile'));
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $mprod=$prod->rel->prod_ha_menu('makeresponsefile',$cpic->{prod});
    $cpic->{prod}=$mprod;
    $cfg->{prod}=$mprod;
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

#sub cli_preinstall_messages {
#    my ($prod) = @_;
#    $prod->perform_task("cli_preinstall_messages");
#}
#
#sub web_preinstall_messages {
#    my ($prod) = @_;
#    $prod->perform_task("web_preinstall_messages");
#}
sub preinstall_messages {
    my ($prod) = @_;
    $prod->perform_task('preinstall_messages');
    return;
}

sub cli_prestart_config_questions {
    my ($prod) = @_;
    $prod->perform_task('cli_prestart_config_questions');
    return;
}

sub web_prestart_config_questions {
    my ($prod) = @_;
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
    if ($prod->{class}=~/SVS/m) {
        # Only check VMware vSphere Perl SDK for RHEL5
        $prod->check_vmware_vsphere_sdk_sys($sys);
    }
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
                    if (($sysi eq $obj_sysi->{hostname}) && ($temp[3] =~ /ONLINE|PARTIAL/mx)) {
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
        $sysname=Prod::VCS60::Common::transform_system_name($sys->{sys});
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

    $prod->perform_task_sys($sys,'configure_sys');
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

sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;

    my $vcs=$prod->prod('VCS60');
    my $vm=$prod->prod('VM60');
    my $sfha=$prod->prod('SFHA60');

    $vm->upgrade_prestop_sys($sys) if ($vm->can('upgrade_prestop_sys'));
    $sfha->upgrade_rolling_post_sys($sys) if($sys->system1 &&  Cfg::opt('upgrade_nonkernelpkgs'));
    $sfha->ru_prestop_sys($sys) if(Cfg::opt('upgrade_kernelpkgs'));


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
    return if (Cfg::opt(qw(fencing addnode security rootpath makeresponsefile)));

    if ($prod->{cfscluster_config_pending}==1) {
        $msg = Msg::new("Unable to complete $cprod configuration at this time\n");
        $msg->print;
        unless ( defined($reboot_systems) && (@$reboot_systems) ) {
            $msg = Msg::new("</opt/VRTS/bin/cfscluster config -s> must be run after the system is rebooted\n");
            $msg->print;
        }
    }

    return;
}

# start CVM and CFS Agents
sub start_cvm_cfs_agents {
    my ($prod,$sys) = @_;
    my ($aa,$b,$sysi,$vcs,$obj_sysi,$syslist,@av,@c);

    $vcs = $prod->prod('VCS60');
    return if $prod->{cvmcfs_started};
    $syslist=CPIC::get('systems');
    $aa = $sys->cmd("$vcs->{bindir}/hagrp -display cvm -attribute State");
    @av= split(/\n/,$aa);
    for my $b (@av) {
        @c = split(/\s+/, $b);
        # Only Online on nodes passed to CPI.
        # This is done to handle phased upgrades.
        next if ($c[0] eq '#Group');
        $sysi = $c[2];
        for my $obj_sysi (@$syslist) {
            if (($sysi eq $obj_sysi->{hostname}) && ($c[3] =~ /OFFLINE/m)) {
                Msg::log("Online cvm Group on $c[2]");
                $sys->cmd("$vcs->{bindir}/hagrp -online $c[0] -sys $c[2]");
                if (!EDR::cmdexit()) {
                    $sys->cmd("$vcs->{bindir}/hagrp -wait $c[0] State ONLINE -sys $c[2] -time 300");
                } else {
                    Msg::log("Unable to online cvm service group on $c[2]");
                }
                Msg::log("cvm Group on $c[2] is online");
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

# stop CVM and CFS Agents
sub stop_cvm_cfs_agents {
    my ($prod,$sys) = @_;
    my ($aa,$b,$sysi,$grp,$sys_master,$vxdctl_mode,$state,$padv,$port_f,$vcs,@tempdeps,@deps,@y,$count,$tempd,$obj_sysi,$syslist,@av,@c,$port_q,@master_nodes,$temp_sys,$z);
    $syslist=CPIC::get('systems');
    $vcs = $prod->prod('VCS60');
    $padv=$sys->padv;

    Msg::log('Stopping CVM and CFS Agents');
    $tempd = $sys->cmd("$vcs->{bindir}/hagrp -dep cvm | _cmd_grep -w cvm");
    @tempdeps = split(/\n/,$tempd);
    for my $z (@tempdeps) {
        @y=split(/\s+/, $z);
        next if ($y[0] eq '#Parent');
        push(@deps, $y[0]);
    }
    push(@deps, 'cvm');

    for my $z (@deps) {
        $aa = $sys->cmd("$vcs->{bindir}/hagrp -display $z -attribute State");
        @av= split(/\n/,$aa);
        @master_nodes = ();
        for my $b (@av) {
            @c = split(/\s+/, $b);
            # Only Offline on nodes passed to CPI.
            # This is done to handle phased upgrades.

            $grp=$c[0];
            $sysi=$c[2];
            $state=$c[3];

            next if ($grp eq '#Group');
            $count=0;
            for my $obj_sysi (@$syslist) {
                if ($sysi eq $obj_sysi->{hostname}) {
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

    for my $sys (@$syslist) {
        $port_f = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep -c 'Port f gen' ");
        $sys->cmd("$vcs->{bindir}/hares -offline vxfsckd -sys $sys->{hostname}")
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
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    return '' unless ($prod->{mainpkg});
    # Check VCS license if SFCFSHA
    return '' if (($prod->{class}=~/SFCFSHA/m) && (!$rel->feature_licensed_sys($sys, 'Mode#VERITAS Cluster Server', 'VCS')));

    # Check license for SFCFSHA, SVS for the following options.
    if (Cfg::opt(qw(install upgrade precheck patchupgrade addnode))) {
        return '' if (($prod->{class}=~/SVS/m) && (!$rel->prod_licensed_sys($sys,$prod->{prodi})));
    }

    $pkg=$sys->pkg($prod->{mainpkg});
    $pkgvers=$pkg->version_sys($sys,$force_flag);
    $mpvers=$prod->{vers} if ($pkgvers && $prod->check_installed_patches_sys($sys,$pkgvers));
    $pkgvers= $prod->revert_base_version_sys($sys,$pkg,$pkgvers,$mpvers,$force_flag);
    $pkgvers = $prod->version_mapping($pkgvers) if $prod->can('version_mapping');
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

    if ($prod->{class}=~/SFCFSHA/m) {
        $msg=Msg::new("Veritas Storage Foundation Clustered File System HA adds the full functionality of Veritas Cluster Server, and features the power and flexibility to protect everything from a single critical database instance to very large multi-application clusters in networked storage environments. In addition, increased automation and intelligent workload management allow cluster administrators to maximize individual resources by moving beyond reactive recovery to proactive management of availability and performance. SFCFS HA bundle includes support for application monitoring and failover through the Veritas Cluster Server product.");
        $msg->print;
    } elsif ($prod->{class}=~/SVS/m) {
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

    for my $port (qw(a b d f h v w)) {
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

sub register_postchecks_per_system {
    my ($prod,$sequence_id,$name,$desc,$handler);
    $prod=shift;
    $prod->perform_task('register_postchecks_per_system');

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
    my ($msg,$proc,$proci,$rtn,$startprocs,$sys,$sysi);
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

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

    $rtn = $prod->addnode_mount_share_dg();
    return;
}

sub addnode_config_cvm_cfs {
    my ($firstnode,$n,$rtn,$status,$sys,$sysi,$system);
    my $prod = shift;
    my $cprod=CPIC::get('prod');
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS60');

    $status = 1;
    $n = $#{$cfg->{clustersystems}};
    $vcs->haconf_makerw();
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    for my $sysi (@{$cfg->{newnodes}}) {
        $n++;
        $system = Prod::VCS60::Common::transform_system_name($sysi);
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

    # Make newnode cvm online
    if ($cprod ne 'SFRAC60') {
        # Make newnode cvm online
        for my $sysi (@{$cfg->{newnodes}}) {
            $system = Prod::VCS60::Common::transform_system_name($sysi);
            # Run hagrp on one node of cluster
            $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -online cvm -sys $system");
            if (EDRu::isverror($rtn)) {
                Msg::log("Make cvm online failed on $sysi");
                $status = 0;
            }
            $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -wait cvm State ONLINE -sys $system -time 120");
            if (EDRu::isverror($rtn)) {
                Msg::log("Waiting for cvm state online failed on $sysi.");
                $status = 0;
            }
        }
    } else {
       #
       # Start cvm outside vcs because the sfrac resources in cvm group
       # are still not configured for new nodes.
       #
       for my $sysi (@{$cfg->{newnodes}}) {
           $sys = Obj::sys($sysi);
           $rtn = $sys->cmd("$prod->{cfsbin}/vxclustadm -m vcs -t gab startnode");
           if (EDRu::isverror($rtn)) {
               Msg::log("Start cvm failed on $sys->{sys}.");
               $status = 0;
           }
           $rtn = $sys->cmd("$prod->{cfsbin}/vxfsckd");
           if (EDRu::isverror($rtn)) {
               Msg::log("Start cfs failed on $sys->{sys}.");
               $status = 0;
           }
       }
    }
    return $status;
}

sub addnode_mount_share_dg {
    my ($ayn,$activemode,$firstnode,$msg,$mount_info,$mounted,$mount_point,$mount_option,$n,$primary_node,$result,$rtn,$sharedg,$sharevol,@sharevols,$status,$sys,$sysi,$system);
    my $prod = shift;
    my $cfg = Obj::cfg();

    $status = 0;
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    # get the share volume and its mount point from first node of the cluster
    $result = $firstnode->cmd("_cmd_cfsmntadm display | _cmd_grep 'MOUNTED' | _cmd_sort -u ");
    if (EDR::cmdexit()) {
        Msg::log('cfsmntadm display error.');
        return 0;
    }
    my @temp = split(/\n/,$result);
    foreach (@temp) {
        ($mount_point,undef,$sharevol,$sharedg,$mounted) = split;
        if($mounted eq 'MOUNTED') {
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

    for my $sysi (@{$cfg->{newnodes}}) {
        # ask user whether wants to mount these shared volumes on the new node.
        # if "Y", add them on new node, otherwise, do nothing on new node.
        $msg = Msg::new("The cluster has above shared volumes. Would you like to mount these shared volumes on $sysi?");
        $ayn = $msg->ayny();
        next if( $ayn eq 'N');
        $system = Prod::VCS60::Common::transform_system_name($sysi);
        for my $mount_info (@sharevols) {
            $sharevol = $mount_info->[0];
            $mount_point = $mount_info->[1];
            $sharedg = $mount_info->[2];
            $msg = Msg::new("Mount $sharevol on $mount_point for $sysi");
            $msg->left;

            $activemode = $firstnode->cmd(" _cmd_cfsdgadm display | _cmd_grep $sharedg | _cmd_uniq | _cmd_awk '{print \$2}' ");
            unless($activemode) {
                Msg::log("There is no activation mode of $sharedg");
                Msg::right_failed();
                $status++;
                next;
            }

            # check whether the new node has added sharedg, if no, add the sharedg for the new node
            $rtn = $firstnode->cmd("_cmd_cfsdgadm display $sharedg | _cmd_grep $system");
            unless($rtn) {
                $rtn = $firstnode->cmd("_cmd_cfsdgadm add $sharedg $system=$activemode");
                if (EDRu::isverror($rtn)) {
                    Msg::log("Failed to add shared disk group $sharedg on $sysi");
                    Msg::right_failed();
                    $status++;
                    next;
                }
            }

            $primary_node = $firstnode->cmd("_cmd_fsclustadm -v showprimary $mount_point");
            Msg::log("The primary node is $primary_node");
            $mount_option = $firstnode->cmd("_cmd_cfsmntadm display -v $primary_node | _cmd_grep $sharevol | _cmd_awk '{print \$6}' ");
            # mount_option could be ""
            Msg::log("The mount_options of primary node is $mount_option");
            $rtn = $firstnode->cmd("_cmd_cfsmntadm modify $mount_point add $system=$mount_option");
            if (EDRu::isverror($rtn)) {
                Msg::log("Failed to modify $mount_point/$mount_option on $sysi: $rtn");
                Msg::right_failed();
                $status++;
                next;
            }
            $rtn = $firstnode->cmd("_cmd_cfsmount $mount_point $system");
            if (EDRu::isverror($rtn)) {
                Msg::log("Failed to mount $mount_point on $sysi: $rtn");
                Msg::right_failed();
                $status++;
                next;
            }

            Msg::right_done();
        }

        if ($status == 0) {
            Msg::log("Successfully mounted all shared resources on $sysi");
        } elsif ($status == $n){
            Msg::log("Failed to mount all shared resources on $sysi");
        } else {
            Msg::log("Partially failed to mount shared resources on $sysi with status: $status");
        }
    }
    return 1;
}

package Prod::SFCFS60::AIX;
@Prod::SFCFS60::AIX::ISA = qw(Prod::SFCFS60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='sfcfs';
    $prod->{upgradevers}=[qw(6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1)];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw.rte VRTSdbac60 VRTSdbac.rte VRTSvcsea60 VRTScfsdc
        VRTSodm60 VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi.rte
        VRTSd2doc VRTSordoc VRTSfppm VRTSap VRTStep VRTSvcsdb.rte
        VRTSvcsor.rte VRTSgapms.VRTSgapms VRTSmapro VRTSvail.VRTSvail
        VRTSd2gui VRTSorgui VRTSvxmsa VRTSdbdoc VRTSdb2ed VRTSdbed60
        VRTSdbcom VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw.rte
        VRTScspro VRTSvcsdb.rte VRTSvcssy.rte VRTScmccc.rte
        VRTScmcs.rte VRTSacclib52 VRTSacclib.rte VRTScscm.rte
        VRTScscw.rte VRTScssim.rte VRTScutil VRTScutil.rte
        VRTSvcs.doc VRTSvcs.man VRTSvcs.msg.en_US VRTSvcsag60
        VRTSvcsag.rte VRTScps60 VRTSvcs60 VRTSvcs.rte VRTSvxfen60
        VRTSvxfen.rte VRTSgab60 VRTSgab.rte VRTSllt60 VRTSllt.rte
        VRTSfsmnd VRTSfssdk60 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb.rte VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid.rte
        VRTSalloc VRTSvsvc VRTSvmpro VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSat.server VRTSat.client VRTSsmf VRTSpbx
        VRTSicsco VRTSvxfs60 VRTSvxvm60 VRTSveki60 VRTSjre15.rte
        VRTSjre.rte VRTSperl512 VRTSperl.rte VRTSvlic32
    ) ];

    return;
}

# to handle VRTScavf version is 1.0.4 in 4.0MP4 release.
sub version_mapping {
    my ($prod,$vers)=@_;
    $vers='4.0.4' if (EDRu::compvers($vers, '1.0.4', 3)==0);
    return $vers;
}

package Prod::SFCFS60::HPUX;
@Prod::SFCFS60::HPUX::ISA = qw(Prod::SFCFS60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_cluster_file_system';
    $prod->{upgradevers}=[qw(6.0)];
    $prod->{zru_releases}=[qw()];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSdbckp VRTSormap VRTScsocw VRTSdbac60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi VRTSd2doc VRTSordoc
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSgapms VRTSmapro
        VRTSvail VRTSd2gui VRTSorgui VRTSvxmsa VRTSvrdev VRTSdbdoc VRTSdb2ed
        VRTSdbed60 VRTSdbcom VRTSsydoc VRTSsybed VRTSvcsApache
        VRTScmc VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor
        VRTSvcssy VRTScmccc VRTScmcs VRTScscm VRTScscw
        VRTScssim VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg
        VRTSvcsag60 VRTScps60 VRTSvcs60 VRTSvxfen60 VRTSgab60
        VRTSllt60 VRTSfsmnd VRTSfssdk60 VRTSfsdoc VRTSfsman
        VRTSvrdoc VRTSvrw VRTSvrmcsg VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr
        VRTSvdid VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc
        VRTSvmman SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui
        VRTSfspro VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxvm60
        VRTSjre15 VRTSjre VRTSperl512 VRTSvlic32 VRTSwl
    ) ];
    return;
}


package Prod::SFCFS60::Linux;
@Prod::SFCFS60::Linux::ISA = qw(Prod::SFCFS60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_cluster_file_system';
    $prod->{upgradevers}=[qw(6.0)];
    $prod->{zru_releases}=[qw(5.0.30 5.1)];
    $prod->{menu_options}=['Veritas Volume Replicator','Veritas File Replicator','Global Cluster Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSvcsea60 VRTScfsdc VRTSodm60 VRTSodm-platform
        VRTSodm-common VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi
        VRTSd2doc VRTSordoc VRTSfsnbl VRTSfppm VRTSap VRTStep
        VRTSgapms VRTSmapro-common VRTSvail VRTSd2gui-common
        VRTSorgui-common VRTSvxmsa VRTSdbdoc VRTSdb2ed-common
        VRTSdbed60 VRTSdbed-common VRTSdbcom-common VRTSsybed-common
        VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw VRTScspro
        VRTSvcsdb VRTSvcsor VRTSvcssy VRTScmccc VRTScmcs
        VRTScscm VRTScscw VRTScssim VRTScutil VRTSvcsdc VRTSvcsmn
        VRTSvcsmg VRTSvcsdr60 VRTSvcsag60 VRTScps60 VRTSvcs60
        VRTSvxfen60 VRTSgab60 VRTSllt60 VRTSfsmnd VRTSfssdk60
        VRTSfsdoc VRTSfsman VRTSvrdoc VRTSvrw VRTSweb VRTSvcsvr
        VRTSvrpro VRTSalloc VRTSdcli VRTSvsvc VRTSvmpro VRTSddlpr
        VRTSvdid VRTSlvmconv60 VRTSvmdoc VRTSvmman SYMClma
        VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSatClient50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60
        VRTSvxfs-platform VRTSvxfs-common VRTSvxvm60 VRTSvxvm-platform
        VRTSvxvm-common VRTSjre15 VRTSjre VRTSperl512 VRTSvlic32
    ) ];
    return;
}

package Prod::SFCFS60::RHEL5x8664;
@Prod::SFCFS60::RHEL5x8664::ISA = qw(Prod::SFCFS60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->{class} =~ /SVS/m) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    }
    return;
}

package Prod::SFCFS60::RHEL6x8664;
@Prod::SFCFS60::RHEL6x8664::ISA = qw(Prod::SFCFS60::Linux);

sub init_padv {
    my $prod=shift;
    if ($prod->{class} =~ /SVS/m) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    }
    return;
}

package Prod::SFCFS60::SunOS;
@Prod::SFCFS60::SunOS::ISA = qw(Prod::SFCFS60::Common);

sub init_plat {
    my $prod=shift;
    if ($prod->{class} =~ /SVS/m) {
        $prod->{minpkgs}=[ qw(VRTSsfmh41 VRTSglm60 VRTScavf60 VRTSsvs60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSsvs60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='virtualstore';
    } else {
        $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
        $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
        $prod->{proddir}='storage_foundation_cluster_file_system';
    }

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSdbac60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi VRTSd2doc VRTSordoc
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSspc VRTSspcq
        VRTSfasdc VRTSfasag VRTSfas VRTSgapms VRTSmapro VRTSvail
        VRTSd2gui VRTSorgui VRTSvxmsa VRTSdbdoc VRTSdb2ed VRTSdbed60
        VRTSdbcom VRTSsydoc VRTSsybed VRTSvcsApache VRTScmc
        VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy
        VRTScmccc VRTScmcs VRTSacclib52 VRTScscm VRTScscw VRTScssim
        VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsag60
        VRTScps60 VRTSvcs60 VRTSvxfen60 VRTSgab60 VRTSllt60
        VRTSfsmnd VRTSfssdk60 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid
        VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxvm60
        VRTSjre15 VRTSjre VRTSperl512 VRTSvlic32
    ) ];
    return;
}

package Prod::SFCFS60::SolSparc;
@Prod::SFCFS60::SolSparc::ISA = qw(Prod::SFCFS60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1)];
    return;
}

package Prod::SFCFS60::Solx64;
@Prod::SFCFS60::Solx64::ISA = qw(Prod::SFCFS60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1)];
    return;
}

1;
