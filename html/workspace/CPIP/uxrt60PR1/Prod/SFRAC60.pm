#use strict;

package Prod::SFRAC60::Common;
@Prod::SFRAC60::Common::ISA = qw(Prod);

use Socket;
use Time::Local;
use Net::Domain qw (hostname hostfqdn hostdomain);

sub init_common {
    my $prod = shift;
    my $msg;

    $prod->{prod}='SFRAC';
    $prod->{abbr}='SF Oracle RAC';
    $prod->{vers}='6.0.010.000';
    $prod->{proddir}='storage_foundation_for_oracle_rac';
    $prod->{eula}='EULA_SF_Oracle_Rac_Ux_6.0.pdf';
    $prod->{name}=Msg::new("Veritas Storage Foundation for Oracle RAC")->{msg};
    $prod->{mainpkg}='VRTSdbac60';

    $prod->{extra_mainpkgs}=[qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];

    $prod->{lic_names}=['Veritas Storage Foundation for Oracle RAC'];
    $prod->{responsefileupgradeok}=1;
    $prod->{subprods}=[qw(VCS60 SF60)];

    # Location of VCSMM config file
    $prod->{vcsmmtab}='/etc/vcsmmtab';
    $prod->{menu_options}=['Veritas Volume Replicator','Global Cluster Option'];

    $prod->{minimal_memory_requirment} = '2 GB';
    $prod->{minimal_swap_requirment} = '8 GB';
    $prod->{minimal_cpu_speed_requirment} = '2 GHz';
    $prod->{minimal_cpu_number_requirment} = 2;

    # Common variables needed during Oracle installation
    $prod->{display} = $ENV{DISPLAY};
    $prod->{oracle_base} = $ENV{ORACLE_BASE};
    $prod->{db_home} = $ENV{ORACLE_HOME};
    $prod->{crs_home} = $ENV{ORA_CRS_HOME};
    $prod->{oui_args} = '';
    $prod->{oracle_install_script} = 'runInstaller';
    $prod->{oracle_bits} = '64'; # Oracle supports only 64 bits on both Sparc and X86 archs
    $prod->{oracle_uid} = 5006;
    $prod->{oracle_gid} = 5006;
    $prod->{oracle_user_home} = '';
    $prod->{oracle_sgroups} = '';

    $prod->{crs_release} = '';
    $prod->{crs_patch_level} = '';
    $prod->{db_release} = '';
    $prod->{db_patch_level} = '';

    $prod->{oratab} = '/var/opt/oracle/oratab';
    $prod->{cmd_nm_64} = '_cmd_nm';

    $prod->{priv_res_name} = '';
    $prod->{mpriv_res_name} = '';
    $prod->{ip_alias_name} = '-priv';
    $prod->{priv_mask} = '255.255.255.0';
    $prod->{priv_data} = {};
    $prod->{mpriv_data} = {};
    $prod->{priv_nics} = '';
    $prod->{mpriv_nics} = '';
    $prod->{hosts_file} = '/etc/hosts';

    $prod->{cfsmnt_res_name} = 'ocrvote_mnt';
    $prod->{cfsvotemnt_res_name} = 'vote_mnt';
    $prod->{cfsocrmnt_res_name} = 'ocr_mnt';
    $prod->{cvmvoldg_res_name} = 'ocrvote_voldg';
    $prod->{ocrvote_mntpt} = '/ocrvote';

    $prod->{storage_opts}=[];
    $msg=Msg::new("CVM Raw Volume");
    push @{$prod->{storage_opts}}, $msg->{msg};
    $msg=Msg::new("Clustered File System");
    push @{$prod->{storage_opts}}, $msg->{msg};

    $prod->{dg_opts}=[];
    $msg=Msg::new("Create a disk group");
    push @{$prod->{dg_opts}}, $msg->{msg};
    $msg=Msg::new("Use an existing disk group");
    push @{$prod->{dg_opts}}, $msg->{msg};

    $prod->{mount_points} = "_cmd_dfk | _cmd_grep -v Filesystem | awk '{print \$6}'";

    $prod->{clusnodes} = ();
    $prod->{newnodes} = ();
    $prod->{allnodes} = ();
    $prod->{cssd_offline_file} = '/var/VRTSvcs/lock/cssd-pretend-offline';

    $prod->{has_poststart_config} = 1;
    $prod->{has_config} = 1;
    $prod->{multisystemserialpoststart}=1;

    # SF Oracle RAC configuration menu
    $prod->{menu_sfrac} = ['config_sfrac_subcomponents', 'pre_post_checks', 'preinstall_oracle', 'install_oracle', 'postinstall_oracle', 'exit_cleanly'];
    $prod->{menu_preinstall_oracle} = ['create_oracle_user_group', 'create_ocr_vote_storage', 'create_private_network', 'exit_cleanly'];
    $prod->{menu_install_oracle} = ['install_oracle_clusterware', 'install_oracle_database', 'exit_cleanly'];
    $prod->{menu_postinstall_oracle} = ['config_cssd_agent', 'relink_oracle_database', 'exit_cleanly'];
    $prod->{menu_create_private_network} = ['config_privnic', 'config_multiprivnic', 'exit_cleanly'];
    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv VRTSamf VRTSsfmh VRTSvbs) ];

    $msg = Msg::new("Configure $prod->{abbr} sub-components");
    $msg->msg('sfrac_config_sfrac_subcomponents');
    $msg = Msg::new("Prepare to Install Oracle");
    $msg->msg('sfrac_preinstall_oracle');
    $msg = Msg::new("Install Oracle Clusterware/Grid Infrastructure and Database");
    $msg->msg('sfrac_install_oracle');
    $msg = Msg::new("Post Oracle Installation Tasks");
    $msg->msg('sfrac_postinstall_oracle');
    $msg = Msg::new("$prod->{abbr} Installation and Configuration Checks");
    $msg->msg('sfrac_pre_post_checks');

    $msg = Msg::new("Exit $prod->{abbr} Configuration");
    $msg->msg('sfrac_exit_cleanly');

    $msg = Msg::new("Create Oracle User and Group");
    $msg->msg('sfrac_create_oracle_user_group');
    $msg = Msg::new("Create Storage for OCR and Voting disk");
    $msg->msg('sfrac_create_ocr_vote_storage');
    $msg = Msg::new("Oracle Network Configuration");
    $msg->msg('sfrac_create_private_network');

    $msg = Msg::new("Install Oracle Clusterware/Grid Infrastructure");
    $msg->msg('sfrac_install_oracle_clusterware');
    $msg = Msg::new("Install Oracle Database");
    $msg->msg('sfrac_install_oracle_database');

    $msg = Msg::new("Configure CSSD agent");
    $msg->msg('sfrac_config_cssd_agent');
    $msg = Msg::new("Relink Oracle Database Binary");
    $msg->msg('sfrac_relink_oracle_database');

    $msg = Msg::new("Configure private IP addresses (PrivNIC Configuration)");
    $msg->msg('sfrac_config_privnic');

    $msg = Msg::new("Configure private IP addresses (MultiPrivNIC Configuration)");
    $msg->msg('sfrac_config_multiprivnic');

    $prod->{silent_create_oracle_user_group} = ['oracle_user', 'oracle_uid', 'oracle_group', 'oracle_gid', 'oracle_user_home'];
    $prod->{silent_create_ocr_vote_storage} = ['ocrvotedgoption', 'ocrvotedgname', 'ocrvotescheme', 'oracle_user', 'oracle_group'];
    $prod->{silent_install_oracle_clusterware} = ['crs_home', 'oracle_base', 'crs_installpath', 'crs_responsefile', 'oracle_group'];
    $prod->{silent_install_oracle_database} = ['db_home', 'crs_home', 'oracle_user', 'oracle_base', 'db_installpath', 'db_responsefile', 'oracle_group'];
    $prod->{silent_config_privnic} = ['privnic_resname'];
    $prod->{silent_config_multiprivnic} = ['multiprivnic_resname'];
    $prod->{silent_relink_oracle_database} = ['db_home', 'crs_home', 'oracle_user', 'oracle_group'];
    $prod->{obsolete_scripts} = [ qw(installsfsybasece uninstallsfsybasece) ];
    return;
}

sub default_systemnames {
    my $prod=shift;
    my $vcs=$prod->prod('VCS60');
    return $vcs->default_systemnames;
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
    my($prod,$sfcfs,$category,@categories);

    $prod=shift;
    $sfcfs=$prod->prod('SFCFSHA60');

    @categories=qw(minpkgs recpkgs allpkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$sfcfs->{$category}},
                                        @{$prod->{$category}});
    }

    @categories=qw(obsoleted_ga_release_pkgs
                   obsoleted_but_need_refresh_when_upgrade_pkgs
                   obsoleted_but_still_support_pkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$prod->{$category}},
                                        @{$sfcfs->{$category}});
    }
    return $prod->{allpkgs};
}

sub description {
    my $prod=shift;
    my $msg=Msg::new("Veritas Storage Foundation for Oracle RAC is an integrated suite of industry-leading Veritas storage management and high-availability software, engineered specifically to improve performance, availability, and manageability of Real Application Cluster (RAC) environments. $prod->{abbr} delivers a flexible solution that makes it simple to deploy and manage RAC.");
    $msg->print;
    return;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($rootpath,$pkgvers,$mpvers,$cpic,$rel,$cv,$pkg);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    $rootpath=Cfg::opt('rootpath') || '';
    return '' unless ($prod->{mainpkg});
    $pkg=$sys->pkg($prod->{mainpkg});
    $pkgvers=$pkg->version_sys($sys,$force_flag);
    $cv=EDRu::compvers($pkgvers,$prod->{vers},2);
    $mpvers=$prod->{vers} if ($pkgvers && $prod->check_installed_patches_sys($sys,$pkgvers));
    $pkgvers= $prod->revert_base_version_sys($sys,$pkg,$pkgvers,$mpvers,$force_flag);
    if ($cv) {
        return ($mpvers || $pkgvers) if ($rel->prod_licensed_sys($sys,$prod->{prodi}));
    } else {
        return ($mpvers || $pkgvers);
    }
    return '';
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);
   
    $cpic = Obj::cpic();
    $rel = $cpic->rel();

    if ($rel->feature_licensed_sys($sys, 'Global Cluster Option')) {
        Cfg::set_opt('gco');
    }

    if($rel->feature_licensed_sys($sys, 'VVR')) {
        Cfg::set_opt('vvr');
    }

    return $rel->prod_licensed_sys($sys);
}

# To show SFRAC support matrix with "installsfrac -requirements"
sub other_requirements
{
    return Msg::new("For information on supported Oracle versions with SF Oracle RAC:\n\thttp://seer.entsupport.symantec.com/docs/280186.htm")->{msg};
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

sub task_title {
    my ($prod, $task) = @_;

    Msg::title();
    my $menu = Msg::get("sfrac_$task");
    $msg = Msg::new($menu);
    $msg->bold;
    $msg->n;
    return;
}

sub perform_task_sys {
    my ($prod,$sys,$task) = @_;
    my ($sfcfs);

    $sfcfs = $prod->prod('SFCFSHA60');
    return $sfcfs->$task($sys);
}

sub perform_task {
    my ($prod,$task) = @_;
    my ($sfcfs);

    $sfcfs = $prod->prod('SFCFSHA60');
    return $sfcfs->$task();
}

sub verify_responsefile_option {
    my ($prod, $menuopt) = @_;
    my $cfg = Obj::cfg();

    if ($prod->{"menu_$menuopt"}) {
        for my $item (@{$prod->{"menu_$menuopt"}}) {
            $incomplete_data = $prod->verify_responsefile_option($item);
        }
    } else {
        if ($menuopt ne 'exit_cleanly' &&
            $menuopt ne 'config_sfrac_subcomponents' &&
            $menuopt ne 'pre_post_checks') {
            if ($cfg->{$menuopt}) {
                for my $item (@{$prod->{"silent_$menuopt"}}) {
                    if ($cfg->{$item} eq '') {
                        my $menu = Msg::get("sfrac_$menuopt");
                        $msg = Msg::new("$menu: value for '$item' not found in the response file");
                        $msg->print;
                        $incomplete_data = 1;
                    }
                }
                $menu_verify_method = "verify_responsefile_$menuopt";
                $prod->$menu_verify_method() if ($prod->can($menu_verify_method));
            }
        }
    }
    return $incomplete_data;
}

sub verify_responsefile {
    my ($prod) = @_;
    my ($incomplete_data);

    if ($cfg->{config_sfrac_subcomponents}) {
        $prod->perform_task('verify_responsefile');
    }

    $incomplete_data = 0;
    for my $item (@{$prod->{menu_sfrac}}) {
        $incomplete_data = $prod->verify_responsefile_option($item);
    }
    if ($incomplete_data) {
        $msg = Msg::new("Responsefile does not contain all the required information for the chosen options");
        $msg->die;
    }
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
    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();
    my $sfcfs = $prod->prod('SFCFSHA60');

    if (($cfg->{opt}{configure}) && (!$cfg->{config_sfrac_subcomponents})) {
        # $sfcfs->{cfscluster_config_pending} flag is required only
        # during config_sfrac_subcomponents
        $sfcfs->{cfscluster_config_pending} = 0;
        for my $item (@{$prod->{menu_sfrac}}) {
            if($prod->run_and_return($item)) {
                last;
            }
        }
        $cpic->completion();
    }
    $prod->perform_task('responsefile_prestart_config');
    return;
}

sub responsefile_poststart_config {
    my ($prod) = @_;
    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();

    if ($cfg->{config_sfrac_subcomponents}) {
        for my $item (@{$prod->{menu_sfrac}}) {
            last if($prod->run_and_return($item));
        }
        $cpic->completion();
    }
    $prod->perform_task('responsefile_poststart_config');
    return;
}

sub run_and_return {
    my ($prod, $menuopt) = @_;
    my $ret = 0;

    if ($prod->{"menu_$menuopt"}) {
        for my $item (@{$prod->{"menu_$menuopt"}}) {
            $ret ||= $prod->run_and_return($item);
        }
    } else {
        $ret ||= $prod->$menuopt()
            if ($menuopt ne 'exit_cleanly' &&
                $menuopt ne 'config_sfrac_subcomponents' &&
                $menuopt ne 'pre_post_checks');
    }
    return $ret;
}

sub sfrac_enable_sys {
    my ($prod, $sys) = @_;
    my ($proci, $proc);

    my $procs = $prod->pkg($prod->{mainpkg})->{startprocs};
    for my $proci (@$procs) {
        $proc = $sys->proc($proci);
        $proc->enable_sys($sys);
    }
    return;
}

sub sfrac_disable_sys {
    my ($prod,$sys) = @_;
    my ($proci,$proc);

    my $procs = $prod->pkg($prod->{mainpkg})->{startprocs};
    for my $proci (@$procs) {
        $proc = $sys->proc($proci);
        $proc->disable_sys($sys);
    }
    return;
}

sub prestop_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys, 'prestop_sys');
    return;
}

sub preremove_sys {
    my ($prod, $sys) = @_;
    my $vm = $prod->prod('VM60');

    $vm->preremove_sys($sys) if ($vm->can('preremove_sys'));
    return;
}

sub preremove_tasks {
    my $prod = shift;
    $prod->perform_task('preremove_tasks');
    return;
}

sub postremove_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'postremove_sys');
    return;
}

sub cli_preinstall_messages {
    my ($prod) = @_;
    my $vcs = $prod->prod('VCS60');

    $vcs->cli_preinstall_messages() if ($vcs->can('cli_preinstall_messages'));
    return;
}

sub preinstall_sys {
    my ($prod,$sys) = @_;

    $prod->perform_task_sys($sys, 'preinstall_sys');
    return;
}

sub postinstall_sys {
    my ($prod, $sys) = @_;
    $prod->perform_task_sys($sys, 'postinstall_sys');
    return;
}

sub check_config {
    my ($prod,$rootpath,$sfrac,$sfrac_config,$sysi,$vcsmm_config,$syslist);
    $prod = shift;
    $rootpath = Cfg::opt('rootpath') || '';

    $sfrac=$prod->prod('SFCFSHA60');
    $sfrac_config=$sfrac->check_config();
    return 0 unless $sfrac_config;

    # Check if vcsmmtab is present on all nodes of the cluster.
    $vcsmm_config = 1;
    $syslist=CPIC::get('systems');
    for my $sysi (@$syslist) {
        if (!($sysi->exists("$rootpath$prod->{vcsmmtab}"))) {
            $vcsmm_config = 0;
        }
    }
    return $vcsmm_config;
}

sub configure_sys {
    my ($prod, $sys) = @_;
    $prod->perform_task_sys($sys, 'configure_sys');

    # Only perform the following operations once per cluster install.
    return unless ($sys->system1);

    # Creating conf file for VCSMM and copying it to other nodes as well
    EDRu::writefile('/sbin/vcsmmconfig -c >/var/VRTSvcs/log/vcsmmconfig.log 2>&1 &', $prod->{vcsmmtab});
    my $localsys=$prod->localsys;
    for my $othersys (@{CPIC::get('systems')}) {
        $localsys->copy_to_sys($othersys,"$prod->{vcsmmtab}",'/etc/vcsmmtab') unless ($othersys->{islocal});
    }
    return;
}

sub pre_post_checks {
    my ($prod, $upi, $ver);

    $prod = shift;
    $upi = $prod->{prod};
    $ver = $prod->{vers};

    $prod->task_title('pre_post_checks');
    $msg = Msg::new("This menu option can be used for the following purpose.");
    $msg->print;
    $msg->n;

    $msg = Msg::new("\ta) Validate the cluster for new deployments after configuring $prod->{abbr} sub-components");
    $msg->print;
    $msg->n;
    $msg = Msg::new("\tb) Validate the cluster for existing deployments after installing Oracle RAC");
    $msg->print;
    $msg->n;
    $msg = Msg::new("It is recommended to run the $prod->{abbr} Installation and Configuration checks after any configuration changes are made to the system. Typical scenarios are OS patch updates, Oracle patch updates, SF Oracle RAC patch updates, addition of new nodes to the cluster, and networking changes.");
    $msg->print;
    $msg->n;
    $msg = Msg::new("Some of the checks will be skipped depending on the stage of $prod->{abbr} installation, as asserted by the user.");
    $msg->print;
    Msg::prtc();

    my $return_prepucheck = $prod->prepucheck(CPIC::get('systems'), $upi, $ver);
    if($return_prepucheck eq "back") {
        return;
    }
    $msg = Msg::new("If any of the above checks failed, see the $prod->{name} Administrator's guide to determine the reason for the failure and take corrective action. Rerun the checks after fixing the issues.");
    $msg->bold;
    $msg->n;
    Msg::prtc();
    return;
}

sub poststart_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys, 'poststart_sys');
    my $vcsalreadyup = 1;
    # VCS 'can'not poststart_sys, and after VCS is started it's the right time to
    # ask for Oracle installation/configuration
    # $prod->config_menu($vcsalreadyup);
    return;
}

sub web_prestart_config_questions {
    my ($prod) = @_;
    my $vcsalreadyup = 0;

    $prod->config_menu($vcsalreadyup);

#    $prod->perform_task("web_prestart_config_questions");
    for my $sys (@{CPIC::get('systems')}) {
        $prod->sfrac_enable_sys($sys);
    }
    return;
}

sub cli_prestart_config_questions {
    my ($prod) = @_;
    my $vcsalreadyup = 0;

    $prod->config_menu($vcsalreadyup);
#    $prod->perform_task("cli_prestart_config_questions");
    return;
}

sub cli_poststart_config_questions {
    # This subroutine is not there in CPI::SFRAC.pm, still adding here
    my ($prod) = @_;

    $prod->perform_task('cli_poststart_config_questions');
    return;
}

sub stop_precheck_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'stop_precheck_sys');
    return;
}

sub install_precheck_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'install_precheck_sys');

    # Called for only one system.
    # [TBD] A stub to be provided by EDR in the main thread.
    if ( $sys->system1 ) {
    $prod->pre_sfrac_checks($sys, 1);
    $msg = Msg::new("If any of the above checks failed, see the $prod->{name} Administrator's guide to determine the reason for the failure and take corrective action. Rerun the checks after fixing the issues.");
    #$msg->bold;
    #$msg->n;
    #Msg::prtc();
    }
    return;
}

sub upgrade_precheck_sys {
    my ($prod, $sys) = @_;
    my ($msg);

    if (!$sys->exists($prod->{vcsmmtab})) {
        $msg = Msg::new("$prod->{vcsmmtab} does not exist on $sys->{sys}. vcsmm may not be able to start after upgrade.");
        $sys->push_warning($msg);
    }

    $prod->perform_task_sys($sys,'upgrade_precheck_sys');
    return;
}

sub configure_precheck_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,"configure_precheck_sys");
    return;
}

sub uninstall_precheck_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'uninstall_precheck_sys');
    return;
}

sub start_precheck_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'start_precheck_sys');
    return;
}

sub upgrade_prestop_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_prestop_sys');
    return;
}

sub upgrade_preremove_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_preremove_sys');
    return;
}

sub upgrade_postremove_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_postremove_sys');
    return;
}

sub upgrade_preinstall_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_preinstall_sys');
    return;
}

sub upgrade_postinstall_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_postinstall_sys');
    return;
}

sub upgrade_configure_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_configure_sys');
    return;
}



sub upgrade_poststart_sys {
    my ($prod, $sys) = @_;

    $prod->perform_task_sys($sys,'upgrade_poststart_sys');
    return;
}

sub completion_messages {
    my $prod=shift;

    # During rolling upgrade, at the end of upgrade of kernel packages
    # provide option to relink oracle
    if ((Cfg::opt('upgrade_kernelpkgs')) && (!Obj::webui()) && (!Cfg::opt('responsefile'))) {
        my @menu = @{$prod->{menu_postinstall_oracle}};
        shift(@menu); # remove the cssd agent configuration menu option
        $selection = $prod->display_product_menu_and_act($backopt, @menu);
    }
    $prod->perform_task('completion_messages');
    return;
}

sub startprocs {
    my $prod=shift;
    my $sfcfs = $prod->prod('SFCFSHA60');
    return $sfcfs->adjust_ru_procs if (Cfg::opt('upgrade_nonkernelpkgs'));
    my $ref_procs = Prod::startprocs($prod);
    $ref_procs=$sfcfs->reorder_vxglm($ref_procs);
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod, $sys) = @_;
    my ($vm, $ref_procs);
    $sfcfs = $prod->prod('SFCFSHA60');
    return $sfcfs->adjust_ru_procs if (Cfg::opt('upgrade_nonkernelpkgs'));
    $vm = $prod->prod('VM60');
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $vm->verify_procs_list_sys($sys,$ref_procs,'start');
    $ref_procs=$sfcfs->reorder_vxglm($ref_procs);
    return $ref_procs;
}

sub stopprocs {
    my $prod=shift;
    my ($ref_procs,$sfha,$sfcfs);
    $sfcfs = $prod->prod('SFCFSHA60');
    return $sfcfs->adjust_ru_procs if (Cfg::opt('upgrade_nonkernelpkgs'));

    $sfha = $prod->prod('SFHA60');
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $sfha->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my ($ref_procs,$sfcfs);
    $sfcfs = $prod->prod('SFCFSHA60');
    return $sfcfs->adjust_ru_procs if (Cfg::opt('upgrade_nonkernelpkgs'));

    $sfha = $prod->prod('SFHA60');
    $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $sfha->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub config_menu {
    my ($prod, $selection, $backopt, $vcsalreadyup);
    $prod = shift;
    $vcsalreadyup = shift;
    $backopt = 0;

    if ($vcsalreadyup) {
        shift(@{$prod->{menu_sfrac}});
    }
    $selection = $prod->display_product_menu_and_act($backopt, @{$prod->{menu_sfrac}});
    return;
}

sub poststart_configure_sys {
    my ($prod, $sys) = @_;
    my ($fencing_cmd,$msg);
    $fencing_cmd="/opt/VRTS/install/installsfrac -fencing";

    # TBD: Message should be diplayed only when user re-configure sfrac components.
    if ( $sys->system1 ) {
        if ($rel->{nowebinstaller}) {
            $msg = Msg::new("\nIf you have not yet configured Symantec I/O fencing, you can run the command '$fencing_cmd' to configure it.\n");
        } else {
            $msg = Msg::new("\nIf you have not yet configured Symantec I/O fencing, you have two ways to configure it:\n 1.Run the command '$fencing_cmd' \n 2.Use the I/O fencing configuration task on webinstaller.\n");
        }
        $msg->print;
        Msg::prtc();
        if (Obj::webui()){
            my $web=Obj::web();
            unless($web->{ask_to_configure_fencing}){
                $web->web_script_form("alert",$msg);
                $web->{ask_to_configure_fencing} = 1;
            }
        }
    }
    
    

    if (!Obj::webui()){
        my $cfg = Obj::cfg();
        $cfg->{create_oracle_user_group} = 0;
        $cfg->{create_ocr_vote_storage} = 0;
        $cfg->{config_privnic} = 0;
        $cfg->{config_multiprivnic} = 0;
        $cfg->{install_oracle_clusterware} = 0;
        $cfg->{install_oracle_database} = 0;
        $cfg->{config_cssd_agent} = 0;
        $cfg->{relink_oracle_database} = 0;

        $backopt = 0;
    }
    return;
}

# First arg = $prod
# Second arg = $backopt
# Third arg = complete menu for $prod (can have menu within a menu too)
sub display_product_menu_and_act {
    my ($prod,$backopt,@menuopts) = @_;
    my ($msg,$sfcfs,$ii,$edr,$menukey,$menulist,$ret,$help,$choice,$menu,$def);

    $sfcfs = $prod->prod('SFCFSHA60');
    $edr=Obj::edr();
    my $web = Obj::web();

    $def = 1; # Default option in the menu
    $help = '';
    if(Cfg::opt("makeresponsefile")) {
        $msg = Msg::new("Currently SFRAC installer does not support -makeresponsefile option. \n");
        $msg->print;
        Msg::prtc();
        $sfcfs->{cfscluster_config_pending} = 0;
        my $cpic = Obj::cpic();
        $cpic->completion();
        return;

    }

    while (1) {
        if (Obj::webui()) {
            if ( $menuopts[0] eq 'config_sfrac_subcomponents' ) {
                $prod->{web_sfrac_main_menu} = 1;
            } else {
                $prod->{web_sfrac_main_menu} = 0; 
            } 
            $web->web_script_form('sfract_select_task', $prod, \@menuopts);
            if ($web->param('back') eq 'back') {
                return;
            }
            $choice = $web->param('select_task');
        } else {
            # Task selection
            Msg::title();

            $menulist = [];
            for my $menukey (@menuopts) {
                $menu = Msg::get("sfrac_$menukey");
                push(@{$menulist}, $menu);
            }

            $msg = Msg::new("Choose option:");
            $choice = $msg->menu($menulist, $def, $help, $backopt);
            Msg::n();
            $edr->{exitfile} = 'noexitfile' unless ($choice == 1);
            if (EDR::getmsgkey($choice,'back')) {
                return;
            }
            $choice = @menuopts[(0+$choice) - 1];
        }
        if ($prod->{"menu_$choice"}) {
            $prod->display_product_menu_and_act(1, @{$prod->{"menu_$choice"}});
        } else { # In the leaf node, no further menu
            # $sfcfs->{cfscluster_config_pending} flag is required only
            # during config_sfrac_subcomponents
            if ($choice ne 'config_sfrac_subcomponents') {
                $sfcfs->{cfscluster_config_pending} = 0;
            } else {
                $sfcfs->{cfscluster_config_pending} = 1;
            }
            if ($choice eq 'exit_cleanly') {
                if (Cfg::opt('upgrade_kernelpkgs')) {
                    return;
                }
                my $cpic = Obj::cpic();
                $cpic->completion();
                return;
            }
            $ret = $prod->$choice();
            if (($choice eq 'config_sfrac_subcomponents') && ($ret == 1)) {
                return;
            }
        }
    }
    return;
}

sub config_sfrac_subcomponents {
    my $prod = shift;
    my ($sys, $msg, $ret);
    my $vcs = $prod->prod('VCS60');
    my $cfg = Obj::cfg();

    #for $sys (@{CPIC::get("systems")}) {
    #    $ret = $vcs->tsub("configure_precheck_sys", $sys);
    #    if ($ret == 0) {
    #        $msg = Msg::new("\nAlready configured and running on one or more node(s) of your cluster,\nstop these using $cpic->{script} -stop before reconfiguring.");
    #        $msg->print;
    #        Msg::prtc();
    #        return 0;
    #    }
    #}

    $cfg->{config_sfrac_subcomponents} = 1 if (!Cfg::opt('responsefile'));
    $prod->perform_task('cli_prestart_config_questions');
    $prod->perform_task('web_prestart_config_questions');
    for my $sys (@{CPIC::get('systems')}) {
        $prod->sfrac_enable_sys($sys);
    }

    return 1;
}

# Check the existence of UID in /etc/passwd
# Return 1 if cannot read the file
# Return 2 if found that ID present in the file
# Return 0 otherwise
sub check_uid_existence {
    my ($prod, $id) = @_;
    my ($msg, $sys, $grepout, $errstr);
    for my $sys (@{CPIC::get('systems')}) {
        $grepout = 0;
        eval {
            $sys->cmd("_cmd_grep $id /etc/passwd");
            $grepout = EDR::cmdexit();
        };
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem reading /etc/passwd on $sys->{sys}. Error Info: $errstr");
            $msg->print;
            return 1;
        }
        if (!$grepout) {
            my $uidstr = $sys->cmd("_cmd_grep $id /etc/passwd | _cmd_cut -d ':' -f3");
	    my @uid = split(/\n/, $uidstr);
	    for my $uid (@uid) {
	       chomp($uid);
 	       if ($uid == $id ) {
                   $msg = Msg::new("ID: $id already exists. Input again");
               	   $msg->log;
	           return 2;
               }
	    }
        }
    }
    return 0;
}

# Check the existence of GID in /etc/group
# Return 1 if cannot read the file
# Return 2 if found that ID present in the file
# Return 0 otherwise
sub check_gid_existence {
    my ($prod, $id) = @_;
    my ($msg, $sys, $grepout, $errstr);
    for my $sys (@{CPIC::get('systems')}) {
        $grepout = 0;
        eval {
            $sys->cmd("_cmd_grep -w $id /etc/group");
            $grepout = EDR::cmdexit();
        };
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem reading /etc/group on $sys->{sys}. Error Info: $errstr");
            $msg->print;
            return 1;
        }
        if (!$grepout) {
            $msg = Msg::new("ID: $id already exists. Input again");
            $msg->log;
            return 2;
        }
    }
    return 0;
}

sub get_uniq_uid {
    my $prod = shift;
    my $reserved = shift; # Max of the reserved UIDs on all Unices, as per man pages
    my $range = shift; # What range to look for the random number
    my $count = 0; # How many times do you want to try before asking the user
    my $random;
    my ($sys, $msg, $ret, $found, $trials);
    $found = 1;
    $trials = 5;

RETRY:    while ($count < $trials) { # Try, say, 5 times and then ask user for UID and GID
        $random = int(rand($range)) + $reserved; # Random number outside of 'reserved' pool and within 'range'
        $ret = $prod->check_uid_existence($random);
        if ($ret == 1) {
            last RETRY;
        } elsif ($ret == 2) {
            $count++;
            $found = 0 if ($count >= $trials);
            $range += 1000;
            next RETRY;
        }
        last;
    }
    return 0 if (!$found); # So that if cannot find a suitable number then fail later
    return $random;
}

sub get_uniq_gid {
    my $prod = shift;
    my $reserved = shift;
    my $range = shift; # What range to look for the random number
    my $count = 0; # How many times do you want to try before asking the user
    my $random;
    my ($sys, $msg, $ret, $found, $trials);
    $found = 1;
    $trials = 5;

RETRY:    while ($count < $trials) { # Try, say, 5 times and then ask user for UID and GID
        $random = int(rand($range)) + $reserved; # Random number outside of 'reserved' pool and within 'range'
        $ret = $prod->check_gid_existence($random);
        if ($ret == 1) {
            last RETRY;
        } elsif ($ret == 2) {
            $count++;
            $found = 0 if ($count >= $trials);
            $range += 1000;
            next RETRY;
        }
        last;
    }
    return 0 if (!$found); # So that if cannot find a suitable number then fail later
    return $random;
}

sub create_oracle_user_group {
    my $prod = shift;
    my $cfg = Obj::cfg();
    my $preinst = 1;
    my ($ou, $og, $og2, $oh, $ouid, $ogid, $ogid2, $oshell);
    my ($repeat, $question, $answer, $sys, $backopt, $help, $msg, $ret, $ayn, $def);
    my $user_exists = 0;
    my $group_exists = 0;
    my $orahome_exists = 0;
    my $reserved = 1000;
    my $range = 1000;
    my $web = Obj::web();


    return 0 if (Cfg::opt('responsefile') && $cfg->{create_oracle_user_group} == 0);
    $cfg->{create_oracle_user_group} = 1;
    $prod->{create_oracle_user_group} = 1;

    $prod->task_title('create_oracle_user_group');

    $def = '';
    $help = '';
    $backopt = 1;

    $msg = Msg::new("Beginning to create Oracle User and Group");
    $msg->log;

DNA_CREATE_ORACLE_USER_GROUP:

    if (Obj::webui())
    {
        $web->web_script_form("create_oracle_user_group", $web, $prod, $sys);
        if ($web->param("back") eq "back") {
            $prod->{create_oracle_user_group} = 0;
            return 0;
        }
    }


    # Oracle user
    if ($prod->can('find_oracle_user')) {
        $ret = $prod->find_oracle_user($preinst);
    }
    if ($ret == 0) {
        $ou = $prod->{oracle_user};
    } elsif ($ret == 2) {
        $user_exists = 1;
        $group_exists = 1;
        $orahome_exists = 1;
        $ou = $prod->{oracle_user};
        $og = $prod->{oracle_group};
        $ouid = $prod->{oracle_uid};
        $ogid = $prod->{oracle_gid};
        $oh = $prod->{oracle_user_home};
    } elsif ($ret == 3) {
        $prod->{create_oracle_user_group} = 0;
        return 0;
    } elsif ($ret == 4) {
        goto DNA_CREATE_ORACLE_USER_GROUP;
    } else {
        $msg = Msg::new("Could not determine Oracle user. Refer to the installer logs for more information.");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        $prod->{create_oracle_user_group} = 0;
        return 1;
    }

    $msg = Msg::new("Assigned Oracle user: $ou"); # True: With or without responsefile
    $msg->log;

    # Because $user_exists $group_exists $orahome_exists are set as we need them

    if ($user_exists == 1) {
        $msg = Msg::new("Oracle user ($ou) already exists with group $og on all the nodes. Please provide other username.");
        $msg->print if (!Obj::webui());
        return if (Cfg::opt('responsefile'));
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
	$prod->{oracle_user} = '';
        $prod->{create_oracle_user_group} = 0;
        $user_exists = 0;
        $orahome_exists = 0;
        $group_exists = 0;
	goto DNA_CREATE_ORACLE_USER_GROUP;
    }

    # Figure out Oracle UID/GID
    $msg = Msg::new("Beginning to assign Oracle UID and GID");
    $msg->log;
    goto DNA_OUID if (Cfg::opt('responsefile') || $user_exists);

    $ouid = $prod->get_uniq_uid($reserved, $range);
    # Ask user with suggestion as gotten above
    while (1) {
        if (!Obj::webui())
        {
            $question = Msg::new("Enter Oracle user's ID (numerical):");
            $answer = $question->ask($ouid, $help, $backopt);
            return 0 if (EDR::getmsgkey($answer,'back'));
        }
        else
        {
            $answer=$cfg->{oracle_uid};
        }
        chomp($answer);
        if ($answer =~ /\D+/m) {
            $msg = Msg::new("Enter a numerical value. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
            next;
        }
        if ((0+$answer) < $reserved || (0+$answer) > 65535) {
            $msg = Msg::new("The UID must be within $range and 65535. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }

            next;
        }
        $ret = $prod->check_uid_existence(0+$answer);
        if (!$ret) {
            last;
        } elsif ($ret == 2) {
            $msg = Msg::new("ID: $answer already exists. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
        }
    }
    $ouid = $answer;

DNA_OUID:
    # Oracle group
    if ($prod->can('find_oracle_group')) {
        $ret = $prod->find_oracle_group($preinst, 1);
    }
    if ($ret == 0) {
        $og = $prod->{oracle_group};
    } elsif ($ret == 2) {
        $group_exists = 1;
        $msg = Msg::new("Oracle group $prod->{oracle_group} already exists on all the nodes with identical attributes");
        goto SKIP_ORAGROUP if (Cfg::opt('responsefile'));
        $msg->print if (!Obj::webui());
        $msg = Msg::new("Do you want to continue?");
        $msg= Msg::new("Oracle group $prod->{oracle_group} already exists on all the nodes with gid  $prod->{oracle_gid} . The new attributes entered will be ignored. Do you want to continue?") if (Obj::webui());
        $ret = $msg->ayny;
        if ($ret eq 'N')
        {
            $prod->{create_oracle_user_group} = 0;
            return 0;
        }
        $og = $prod->{oracle_group};
        $ogid = $prod->{oracle_gid};
    } elsif ($ret == 3) {
        $prod->{create_oracle_user_group} = 0;
        return 0;
    } elsif ($ret == 4) {
        goto DNA_CREATE_ORACLE_USER_GROUP;
    } else {
        $msg = Msg::new("Could not determine Oracle group. Refer to the installer logs for more information.");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        $prod->{create_oracle_user_group} = 0;
        return 1;
    }

SKIP_ORAGROUP:
    if (Cfg::opt('responsefile')) {
        $og = $cfg->{oracle_group};
    }
    $msg = Msg::new("Assigned $og as Oracle group");
    $msg->log;

    goto DNA_OGID if (Cfg::opt('responsefile') || $group_exists);
    $ogid = $prod->get_uniq_gid($reserved, $range);
    # Ask user with suggestion as gotten above
    while (1) {
        if (!Obj::webui())
        {
            $question = Msg::new("Enter Oracle group's ID (numerical):");
            $answer = $question->ask($ogid, $help, $backopt);
            return 0 if (EDR::getmsgkey($answer,'back'));
        }
        else
        {
            $answer=$cfg->{oracle_gid};
        }
        chomp($answer);
        if ($answer =~ /\D+/m) {
            $msg = Msg::new("Enter a numerical value. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
            next;
        }
        if ((0+$answer) < $reserved || (0+$answer) > 65535) {
            $msg = Msg::new("The GID must be within $range and 65535. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
            next;
        }
        $ret = $prod->check_gid_existence(0+$answer);
        if (!$ret) {
            last;
        } elsif ($ret == 2) {
            $msg = Msg::new("ID: $answer already exists. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
        }
    }
    $ogid = $answer;

DNA_OGID:
    if (Cfg::opt('responsefile')) {
        $ouid = $cfg->{oracle_uid};
        $ogid = $cfg->{oracle_gid};
    }
    $msg = Msg::new("Assigned Oracle UID: $ouid, Oracle GID: $ogid ");
    $msg->log;

    goto SKIP_ORAHOME if (Cfg::opt('responsefile'));
    if ($orahome_exists) {
        $msg = Msg::new("Oracle user $ou already exists with user's home directory at $oh on all the nodes");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        $msg=Msg::new("Oracle user $ou already exists with user's home directory at $oh on all the nodes. Do you want to continue?") if (Obj::webui());
        $ret = $msg->ayny;
        if ($ret eq 'N')
        {
            $prod->{create_oracle_user_group} = 0;
            return 0;
        }
        goto SKIP_ORAHOME;
    }

    # Oracle user home dir
    while(1) {
        if (!Obj::webui())
        {
            $question = Msg::new("Enter absolute path of Oracle user's Home directory:");
            $answer = $question->ask($def, $help, $backopt);
            return 0 if (EDR::getmsgkey($answer,'back'));
        }
        else
        {
            $answer=$cfg->{oracle_user_home};
        }
        chomp($answer);
        if ($answer =~ /^\/$/m) {
            $msg = Msg::new("The Oracle user's Home directory must be other than $answer. Input again");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
            next;
        }
        last;
    }
    $oh = $answer;

SKIP_ORAHOME:
    if (Cfg::opt('responsefile')) {
        $oh = $cfg->{oracle_user_home};
    }
    $msg = Msg::new("Assigned Oracle user's home directory: $oh");
    $msg->log;

    $prod->task_title('create_oracle_user_group');
    $msg = Msg::new("Oracle user/group information verification:");
    $msg->bold;
    $msg = Msg::new("\n\tOracle UNIX user name: $ou");
    $msg->print;
    $msg = Msg::new("\tOracle UNIX group name: $og");
    $msg->print;
    $msg = Msg::new("\tOracle user's home directory: $oh");
    $msg->print;
    $msg = Msg::new("\tOracle user ID (UID): $ouid");
    $msg->print;
    $msg = Msg::new("\tOracle group ID (GID): $ogid");
    $msg->print;
    $msg->n;
    $msg = Msg::new("Is this information correct?");

    goto DNA_CONFIRMOUG if (Cfg::opt('responsefile'));
    if(Obj::webui()){
        my $mesg="";
        $msg = Msg::new("Oracle user/group information verification: \\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("Oracle UNIX user name: $ou \\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("Oracle UNIX group name: $og \\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("Oracle user's home directory: $oh\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("Oracle user ID (UID): $ouid\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("Oracle group ID (GID): $ogid\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\\nIs this information correct?");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new($mesg);
    }
    $ayn = $msg->ayny;
    if ($ayn eq 'N') {
        $prod->{create_oracle_user_group} = 0;
        return 1;
    }

    # Save config for responsefile
    if (!Cfg::opt('responsefile')) {
        $cfg->{oracle_user} = $ou;
        $cfg->{oracle_group} = $og;
        $cfg->{oracle_user_home} = $oh;
        $cfg->{oracle_uid} = $ouid;
        $cfg->{oracle_gid} = $ogid;
    }

DNA_CONFIRMOUG:
    goto SKIP_CREATION if ($user_exists);
    # Create Oracle user now
    for my $sys (@{CPIC::get('systems')}) {
        $ret = $prod->create_ora_user_group($sys, $ou, $og, $oh, $ouid, $ogid, $oshell, $user_exists, $group_exists, $orahome_exists)
                if ($prod->can('create_ora_user_group'));
        $msg = Msg::new("Creation of Oracle user on $sys->{sys}");
        $msg->left;
        if ($ret) {
            Msg::right_failed();
            $msg = Msg::new("Refer to the installer logs for more information.");
            $msg->print;
            $msg = Msg::new(" Creation of Oracle user on $sys->{sys} failed. Refer to the installer logs for more information.") if (Obj::webui());
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            Msg::prtc();
            return 1;
        } else {
            Msg::right_done();
        }
    }

SKIP_CREATION:
    # A sanity check for Oracle user and group together
    my $problem = 0;
    $problem = $prod->oracle_sanity($ou, $og);

    $msg = Msg::new("Oracle User/Group Verification");
    $msg->left;
    if ($problem) {
        Msg::right_failed;
        $msg = Msg::new("Oracle User/Group Verification failed")  if (Obj::webui());
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        return 1;
    } else {
        Msg::right_ok;
    }

    if ($user_exists == 0) {
        $msg = Msg::new("\nYou need to set the password of the Oracle user '$prod->{oracle_user}' manually on all the nodes of your cluster before you configure ssh/rsh connection on them");
        $msg->print;
    }

    Msg::prtc();
    if (Obj::webui())
    {
        $msg = Msg::new("Creation of Oracle User/Group was successful\n. \nYou need to set the password of the Oracle user '$prod->{oracle_user}' manually on all the nodes of your cluster before you configure ssh/rsh connection on them. Please also configure passwordless SSH/RSH access across the nodes for this user.") ;
        $web->web_script_form("alert", $msg->{msg});
    }
    # Oracle secondary group(s) addition
    $prod->task_title('create_oracle_user_group');

    $answer = 'N';
    $preinst = 1;
    my $mkgrperr = 0;
#    my $str = "a";
    my $secgrphelp = Msg::new("This step creates secondary group ID(s) on the cluster nodes. Oracle requires some other special groups for identifying operating system accounts that have database admin (OSDBA) privileges and for identifying those accounts that have limited database admin (OSOPER) privileges. You should create such groups on all systems and Oracle user should be part of these groups.");
    while (1) {
        $group_exists = 0;
        goto DNA_SECGRP if (Cfg::opt('responsefile'));

#        $str = "another" if ($answer eq "Y");
#        $question = Msg::new("Do you want to create $str secondary group for Oracle user?");
        if ($answer eq 'N') {
            $question = Msg::new("Do you want to create a secondary group for Oracle user?");
        } else {
            $question = Msg::new("Do you want to create another secondary group for Oracle user?");
        }
        $ayn = $question->aynn($secgrphelp, 1);
	last if (($ayn eq 'N') || (EDR::getmsgkey($ayn,'back')));
        $answer = 'Y' if ($ayn eq 'Y');

DNA_CREATE_SEC_GROUP:

        if (Obj::webui())
        {
            $web->web_script_form("create_oracle_sec_group", $web, $prod, $sys);
            if ($web->param("back") eq "back") {
                goto DNA_CREATE_ORACLE_USER_GROUP;
            }
        }

        # Check the current status of this secondary Oracle group
        if ($prod->can('find_oracle_group')) {
            $ret = $prod->find_oracle_group($preinst, 2);
        }
        if ($ret == 0) {
            $og2 = $prod->{oracle_group};
        } elsif ($ret == 2) {
            $msg = Msg::new("Oracle group '$prod->{oracle_group}' already exists on all the nodes with identical attributes.");
            $msg->print;
            $question = Msg::new("Do you want to continue?");
            $question=Msg::new("Oracle group $prod->{oracle_group} already exists on all the nodes with gid  $prod->{oracle_gid} . The new attributes entered will be ignored. Do you want to continue?") if (Obj::webui());
            $ret = $question->ayny;
            if ($ret eq 'N')
            {
                $prod->{create_oracle_user_group} = 0;
                return 0;
            }
            $group_exists = 1;
            $og2 = $prod->{oracle_group};
            $ogid2 = $prod->{oracle_gid};
        } elsif ($ret == 3) {
            $prod->{create_oracle_user_group} = 0;
            return 0;
        } else {
            $msg = Msg::new("Could not determine Oracle group. Refer to the installer logs for more information.");
            $msg->print;
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            Msg::prtc();
            $prod->{create_oracle_user_group} = 0;
            return 1;
        }

        goto DNA_SECGRP if ($group_exists);
        $ogid2 = $prod->get_uniq_gid(1000, 1000);
        while (1) {
            if (!Obj::webui())
            {
                $question = Msg::new("Enter Oracle group's ID (numerical):");
                $answer = $question->ask($ogid2, $help, $backopt);
                return 0 if (EDR::getmsgkey($answer,'back'));
            }
            else
            {
                $answer= pop (@{$cfg->{oracle_secondary_gid}});;
            }
            chomp($answer);
            if ($answer =~ /\D+/m) {
                $msg = Msg::new("Enter a numerical value. Input again");
                $msg->print;
                if (Obj::webui()){
                    $web->web_script_form("alert", $msg->{msg}) ;
                    goto DNA_CREATE_SEC_GROUP;
                }
                next;
            }
            if ((0+$answer) < $reserved || (0+$answer) > 65535) {
                $msg = Msg::new("The GID must be within $range and 65535. Input again");
                $msg->print;
                if (Obj::webui()){
                    $web->web_script_form("alert", $msg->{msg}) ;
                    goto DNA_CREATE_SEC_GROUP;
                }
                next;
            }
            $ret = $prod->check_gid_existence(0+$answer);
            if (!$ret) {
                last;
            } elsif ($ret == 2) {
                $msg = Msg::new("ID: $answer already exists. Input again");
                if (Obj::webui()){
                    $web->web_script_form("alert", $msg->{msg}) ;
                    goto DNA_CREATE_SEC_GROUP;
                }
                $msg->print;
            }
        }
        $ogid2 = $answer;

        $msg = Msg::new("Assigned $og2 as secondary Oracle group and $ogid2 as the GID");
        $msg->log;


        push (@{$cfg->{oracle_secondary_group}}, $og2);
        push (@{$cfg->{oracle_secondary_gid}}, $ogid2);

DNA_SECGRP:
        if (Cfg::opt('responsefile')) {
            last if (((scalar @{$cfg->{oracle_secondary_group}}) < 1) || ((scalar @{$cfg->{oracle_secondary_gid}}) < 1));
            $og2 = pop (@{$cfg->{oracle_secondary_group}});
            $ogid2 = pop (@{$cfg->{oracle_secondary_gid}});
            $ou = $cfg->{oracle_user};
        }

        # Create secondary group on all systems and make Oracle user part of it
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Adding Oracle user '$ou' to group '$og2' on $sys->{sys}");
            $msg->left;
            if (!$group_exists) {
                $ret = $prod->create_oragrp($sys, $ogid2, $og2);
                $mkgrperr = 1 if ($ret);
                if (!$mkgrperr) {
                    $ret = $prod->modify_group_info($sys, $ou, $og2, $ogid2);
                }
            } else {
                $ret = $prod->modify_group_info($sys, $ou, $og2, $ogid2);
            }
            if ($ret) {
                Msg::right_failed;
                $msg = Msg::new(" Adding Oracle user '$ou' to group '$og2' on $sys->{sys} failed") if (Obj::webui());
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                Msg::prtc();
                $prod->{create_oracle_user_group} = 0;
                return 1;
            } else {
                Msg::right_done;
            }
        }
    }
    if (Obj::webui() && ($answer eq 'Y')) {
        $msg = Msg::new(" Adding Oracle user '$ou' to group '$og2' was successful") ;
        $web->web_script_form("alert", $msg->{msg});
    }

    $prod->{create_oracle_user_group} = 0;
    Msg::prtc();
    return;
}

sub oracle_sanity {
    my ($prod, $ou, $og) = @_;
    my $problem = 0;
    my ($ret, $sys, $msg);
    my $web = Obj::web();

    return 1 if ($ou eq '' || $og eq '');
    for my $sys (@{CPIC::get('systems')}) {
        $ret = $sys->cmd("_cmd_id $ou");
        if (!EDR::cmdexit()) {
            $ret = $sys->cmd("_cmd_groups $ou 2>/dev/null");
            if ($ret =~ /\b$og\b/m) {
                $msg = Msg::new("Oracle user $ou is a member of the group $og on $sys->{sys}");
                $msg->log;
            } else {
		my $grp_str = $sys->cmd("_cmd_grep -iw '$og' /etc/group");
                if ($grp_str =~ m/^$og/  ) {
                    $msg = Msg::new("Group $og is not present on $sys->{sys}");
                    $msg->print;
                    goto GRP_OUT;
                }
                $msg = Msg::new("Oracle user $ou is not a member of the group $og on $sys->{sys}");
                $msg->print;
GRP_OUT:
                $problem = 1;
                if (Obj::webui())
                {
                    $web->web_script_form("alert", $msg->{msg}) ;
                    return $problem;
                }

                next;
            }
        } else {
            $msg = Msg::new("Oracle user $ou doesn't exist on $sys->{sys}");
            $msg->print;
            $problem = 1;
            if (Obj::webui())
            {
                $web->web_script_form("alert", $msg->{msg}) ;
                return $problem;
            }
            next;
        }
    }

    return $problem;
}

sub print_inst_storage {
    my $prod = shift;
    my ($msg);
    my $web = Obj::web();
    $prod->task_title('create_ocr_vote_storage');

    $msg = Msg::new("Installation instructions for creating disk groups, volumes and file systems for Oracle");
    $msg->bold;
    $msg = Msg::new("1. Login to CVM master node and create CVM volumes or CFS directories on shared storage for:");
    $msg->print;
    $msg = Msg::new("\t* Database storage");
    $msg->print;
    $msg = Msg::new("\t* OCR and Voting disk");
    $msg->print;
    $msg = Msg::new("\tThey can be on CVM raw volume or Clustered File System");
    $msg->print;
    $msg = Msg::new("2. Login to all nodes:");
    $msg->print;
    $msg = Msg::new("\t To create local filesystems for Oracle Clusterware/Grid Infrastructure Home and Oracle Home");
    $msg->print;
    $msg = Msg::new("3. Login to all nodes to create mount points and to mount the filesystems");
    $msg->print;
    $msg = Msg::new("4. Login to all the cluster nodes and complete the following:");
    $msg->print;
    $msg = Msg::new("\tChange the permission of all of the above to Oracle user and group");
    $msg->print;
    $msg = Msg::new("5. Create VCS resources for CVM Volumes and CFS files");
    $msg->print;
    $msg = Msg::new("Refer to sample configurations in /etc/VRTSvcs/conf/sample_rac/ directory");
    $msg->print;
    $msg->n;
    $msg = Msg::new("Example for Oracle data disk group, volume and mount creation:");
    $msg->print;
    $msg = Msg::new("\tvxdg -s init oradatadg HDS0_30 IBM0_30 EMC0_30 HDS1_30 # To create the shared disk group");
    $msg->print;
    $msg = Msg::new("\tvxassist -g oradatadg make oradatavol 6G # To create the volume");
    $msg->print;
    $msg = Msg::new("\n\tOn HP-UX, do following step on all the nodes:");
    $msg->print;
    $msg = Msg::new("\t\tvxdg -g oradatadg set activation=sw #To set the activation mode (sw) to allow shared access to the disk group");
    $msg->print;
    $msg = Msg::new("\n\tFollowing steps are applicable to all the platforms:");
    $msg->print;
    $msg = Msg::new("\tvxvol -g oradatadg startall # To start the volume in the disk group if it has not started");
    $msg->print;
    $msg = Msg::new("\tmkdir /oradata # To create a mount point");
    $msg->print;
    $msg = Msg::new("\tmkfs -F vxfs -o largefiles /dev/vx/rdsk/oradatadg/oradatavol # To create file system on Solaris / HP-UX / AIX");
    $msg->print;
    $msg = Msg::new("\tmkfs -t vxfs -o largefiles /dev/vx/rdsk/oradatadg/oradatavol # To create file system on Linux");
    $msg->print;
    $msg = Msg::new("\tmount -F vxfs -o cluster,largefiles /dev/vx/dsk/oradatadg/oradatavol /oradata # To mount shared file system on Solaris / HP-UX / AIX");
    $msg->print;
    $msg = Msg::new("\tmount -t vxfs -o cluster,largefiles /dev/vx/dsk/oradatadg/oradatavol /oradata # To mount shared file system on Linux");
    $msg->print;
    $msg = Msg::new("\tchown -R oracle:oinstall /oradata # To change permissions to Oracle user/group");
    $msg->print;

    if(Obj::webui())
    {
        $msg = Msg::new("Installation instructions for creating disk groups, volumes and file systems for Oracle:\\n")->{msg};
        $msg .= Msg::new("1. Login to CVM master node and create CVM volumes or CFS directories on shared storage for:\\n")->{msg};
        $msg .= Msg::new("\\t* Database storage\\n")->{msg};
        $msg .= Msg::new("\\t* OCR and Voting disk\\n")->{msg};
        $msg .= Msg::new("\\tThey can be on CVM raw volume or Clustered File System\\n")->{msg};
        $msg .= Msg::new("2. Login to all the cluster nodes:\\n")->{msg};
        $msg .= Msg::new("\\t To create local filesystems for Oracle Clusterware/Grid Infrastructure Home and Oracle Home\\n")->{msg};
        $msg .= Msg::new("3. Login to all the cluster nodes to create mount points and to mount the filesystems\\n")->{msg};
        $msg .= Msg::new("4. Login to all the cluster nodes and complete the following:\\n")->{msg};
        $msg .= Msg::new("\\tChange the permission of all of the above to Oracle user and group\\n")->{msg};
        $msg .= Msg::new("5. Create VCS resources for CVM Volumes and CFS files\\n")->{msg};
        $msg .= Msg::new("Refer to sample configurations in /etc/VRTSvcs/conf/sample_rac/ directory\\n")->{msg};
        $msg .= Msg::new("Example for Oracle data disk group, volume and mount creation:\\n")->{msg};
        $msg .= Msg::new("\\tvxdg -s init oradatadg HDS0_30 IBM0_30 EMC0_30 HDS1_30 # To create the shared disk group\\n")->{msg};
        $msg .= Msg::new("\\tvxassist -g oradatadg make oradatavol 6G # To create the volume\\n")->{msg};
        $msg .= Msg::new("\\n\\tOn HP-UX, do following step on all the nodes:\\n")->{msg};
        $msg .= Msg::new("\\t\\tvxdg -g oradatadg set activation=sw #To set the activation mode (sw) to allow shared access to the disk group\\n")->{msg};
        $msg .= Msg::new("\\n\\tFollowing steps are applicable to all the platforms:\\n")->{msg};
        $msg .= Msg::new("\\tvxvol -g oradatadg startall # To start the volume in the disk group if it has not started\\n")->{msg};
        $msg .= Msg::new("\\tmkdir /oradata # To create a mount point\\n")->{msg};
        $msg .= Msg::new("\\tmkfs -F vxfs -o largefiles /dev/vx/rdsk/oradatadg/oradatavol # To create file system on Solaris / HP-UX / AIX\\n")->{msg};
        $msg .= Msg::new("\\tmkfs -t vxfs -o largefiles /dev/vx/rdsk/oradatadg/oradatavol # To create file system on Linux \\n")->{msg};
        $msg .= Msg::new("\\tmount -F vxfs -o cluster,largefiles /dev/vx/dsk/oradatadg/oradatavol /oradata # To mount shared file system on Solaris / HP-UX / AIX\\n")->{msg};
        $msg .= Msg::new("\\tmount -t vxfs -o cluster,largefiles /dev/vx/dsk/oradatadg/oradatavol /oradata # To mount shared file system on Linux \\n")->{msg};
        $msg .= Msg::new("\\tchown -R oracle:oinstall /oradata # To change permissions to Oracle user/group\\n")->{msg};

        $web->web_script_form('alert', $msg);

    }
    return;
}

sub verify_mount_point {
    my $name = shift;
    my ($sys);
    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd("_cmd_mount | _cmd_grep -w $name ");
        if (!EDR::cmdexit()) {
            return 1;
        }
    }
    return 0;
}

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub verify_dg_vol_name {
    my ($name, $nopopup) = @_;
    my ($msg, $len);
    my $web = Obj::web();

    if (check_vcs_reswords($name)) {
        if ($nopopup != 1)
        {
            $msg = Msg::new("The name $name is a VCS reserved word. Input again");
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            $msg->print;
        }
        return 1;
    }
    if ($name !~ /^[0-9a-zA-Z|\_\-]*$/mx) {
        if ($nopopup != 1)
        {
            $msg = Msg::new("Invalid name chosen. Input again");
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            $msg->print;
        }
        return 1;
    }

    $len = length($name);
    if ($len > 31) {
        if ($nopopup != 1)
        {
            $msg = Msg::new("Diskgroup/Volume name length should be less than 32 characters. Input again");
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            $msg->print;
        }
        return 1;
    }

    return 0;
}

sub verify_responsefile_create_ocr_vote_storage {
    my $prod = shift;
    my $cfg = Obj::cfg();

    if (($cfg->{ocrvotedgoption} != 0) && ($cfg->{ocrvotedgoption} != 1)) {
        $msg = Msg::new("Invalid Disk Group option specified in the responsefile");
        $msg->print;
        $incomplete_data = 1;
    }

    if (($cfg->{ocrvotescheme} != 0) && ($cfg->{ocrvotescheme} != 1)) {
        $msg = Msg::new("Invalid Storage Scheme specified in the responsefile");
        $msg->print;
        $incomplete_data = 1;
    }

    Msg::log("oracle_user: $oracle_user, grid_user: $grid_user");
    if (($cfg->{oracle_user} eq '') && ($cfg->{grid_user} eq '')) {
        $msg = Msg::new("One of oracle_user or grid_user must be set in the responsefile");
        $msg->print;
        $incomplete_data = 1;
    }
    return;
}

sub verify_responsefile_install_oracle_clusterware {
    my $prod = shift;
    my $cfg = Obj::cfg();

    Msg::log("oracle_user: $cfg->{oracle_user}, grid_user: $cfg->{grid_user}");
    if (($cfg->{oracle_user} eq '') && ($cfg->{grid_user} eq '')) {
        $msg = Msg::new("One of oracle_user or grid_user must be set in the responsefile");
        $msg->print;
        $incomplete_data = 1;
    }

    Msg::log("oracle_base: $cfg->{oracle_base}, grid_base: $cfg->{grid_base}");
    if ($cfg->{grid_user} ne '') {
        if ($cfg->{grid_base} eq '') {
            $msg = Msg::new("grid_base must be set in the responsefile");
            $msg->print;
            $incomplete_data = 1;
        }
    }

    if ($cfg->{oracle_user} ne '') {
        if ($cfg->{oracle_base} eq '') {
            $msg = Msg::new("oracle_base must be set in the responsefile");
            $msg->print;
            $incomplete_data = 1;
        }
    }
    return;
}

sub create_ocr_vote_storage {
    my $prod = shift;
    my ($ayn, $msg, $cfg, $sys, $errstr, $question, $answer, $repeat, $preinst, $ret, $out);
    $cfg = Obj::cfg();
    my $web = Obj::web();

    return 0 if (Cfg::opt('responsefile') && $cfg->{create_ocr_vote_storage} == 0);

    $prod->task_title('create_ocr_vote_storage');

    $msg = Msg::new("Ensure that $prod->{abbr} is running for creating disk groups, volumes and file systems for Oracle");
    $msg->bold;
    Msg::prtc() if (!Obj::webui());
    $msg->n;
    $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());

    if (Cfg::opt('responsefile')) {
        goto DNA_INSTR;
    }
    $question = Msg::new("Do you want the installer to assist you in creating disk groups, volumes and file systems for Oracle? ");
    $ayn = $question->aynn;
    if ($ayn ne 'Y') {
        $prod->print_inst_storage;
        Msg::prtc() if (!Obj::webui());
        return;
    }
    $cfg->{create_ocr_vote_storage} = 1;

DNA_INSTR:
    my ($vxdctl_master,$indices,$index,$def,$help,$cmd);
    my ($ocrdgname, $votedgname, $dgname);
    my ($ocrvolname, $votevolname, $volname, $ocrvolsize, $votevolsize, $volsize);
    my (@availdisks, @seldisks, @storeopts, $storeopt);
    my ($defvolname, $defdgname, $defvolsize, $unavailsize);
    my ($onraw, $oncfs);
    my ($defmntpt, $defocrmntpt, $defvotemntpt, $cfsmntpt, $ocrmount, $votemount, $mk, $mkret, %mnt, %mntret, $res);
    my $webresult;
    my @multisels;
    my $enable_mirroring;
    my $enable_sep_filesys;

    my $localsys = $prod->localsys;
    my $vxdevlist = '/usr/lib/vxvm/bin/vxdevlist';
    $defdgname = 'ocrvotedg';
    $defmntpt = '/ocrvote';
    $defocrmntpt = '/ocr';
    $defvotemntpt = '/vote';
    $preinst = 1;

    $msg = Msg::log('Beginning to create storage for OCR and Voting disk');
    # 1.
    # Determine the Master node so that commands can be run from there
    eval {$vxdctl_master = $localsys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'master:' | _cmd_awk '{print \$2}'");};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::log("Problem running 'vxdctl' on $localsys->{sys}. Error info: $errstr");
        $msg = Msg::new("Cannot determine the MASTER node");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
    # You might want to print the manual steps here
        Msg::prtc() ;
        return 1;
    } else {
        return 1 if (EDR::cmdexit());
        chomp($vxdctl_master);
        my $tempmaster = $vxdctl_master;
        $vxdctl_master = ($Obj::pool{"Sys::$vxdctl_master"}) ? Obj::sys($vxdctl_master) : '';
        if (!$vxdctl_master) {
            $msg = Msg::new("The node $tempmaster doesn't seem to be a part of the cluster, or CVM is not running on the node $tempmaster");
            $msg->print;
            Msg::prtc() ;
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            return 1;
        }
    }

    # 2.
    # Show user all the available disks and ask which one(s) to be used
    # Avoid showing disks which are part of deported diskgroup(s)
DNA_SELECT_OPTION:
    if (Cfg::opt('responsefile')){
        goto DNA_DISKS if (!$cfg->{ocrvotedgoption});
        goto DNA_VOLTYPE if ($cfg->{ocrvotedgoption});
        $enable_mirroring = $cfg->{enable_mirroring};
    }
    $availdisks = $vxdctl_master->cmd('_cmd_vxdisk -o alldgs list | _cmd_grep -v LVM | _cmd_grep -v invalid | _cmd_grep -v error');
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::log("Problem finding eligible disks on $vxdctl_master->{sys}. Error info: $errstr");
    # You might want to print the manual steps here
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
        return;
    } else {
        return if (EDR::cmdexit());

        Msg::n();
        $msg = Msg::new("Choose option:");

        my @dgopts = @{$prod->{dg_opts}};
        my @dgdiskstrlist = ();
        my @diskstrlist = ();
        my @dgnamelist = ();

        if (Obj::webui())
        {
            $prod->{create_ocr_vote_storage} = 1;
            $webresult=$web->web_script_form("selectocroptions", $web, $prod, $sys);
            if ($web->param("back") eq "back") {
                $prod->{create_ocr_vote_storage} = 0;
                return 0;
            }
            $index = 1 if ($webresult eq "1"); 
            $index = 2 if ($webresult eq "2"); 
            $prod->{create_ocr_vote_storage} = 0;
        } else {
    # Display choice for creating a new disk group or use an existing disk group
            $index = $msg->menu(\@dgopts, $def, $help, 1);
            return 0 if (EDR::getmsgkey($index,'back'));
        }
        if ($index eq 1) {
            $msg = Msg::new("\nDo you want to enable mirroring?");
        } else {
            $msg = Msg::new("\nDo you want to use an existing mirrored diskgroup?");
        }
            $ayn = $msg->ayny;
            if ($ayn eq 'N') {
                $enable_mirroring = 0;
            } else {
                $enable_mirroring = 1;
            }

DNA_OPTION_CREATE_DG:
        @diskstrlist = ();
        if ($index eq 1) {
            @availdisks = split(/\n/, $availdisks);
            for my $item (@availdisks) {
                my $diskstr = $item;
                $diskstr =~ s/\s+/ /mg;
                @strlist = split(/ /m, $diskstr);
                push(@diskstrlist, $item) if ($strlist[3] eq '-');
            }


            if (Obj::webui())
            {
                $prod->{create_ocr_vote_storage} = 2;
                $webresult=$web->web_script_form("create_dg", \@diskstrlist, $enable_mirroring);
                if ($web->param("back") eq "back") {
                    goto DNA_SELECT_OPTION;
                }
                $prod->{create_ocr_vote_storage} = 0;
                $dgname = $webresult->{dg_name};
                @seldisks= @{$webresult->{diskstrlist}};
            } else {

                $msg = Msg::new("\nThe following disks are not part of any disk group");
                $msg->print;
                $msg = Msg::new("Select the serial numbers of at least two disks separated by spaces for creating storage for OCR and Voting disk, excluding disks used for the Operating System and data:") if ($enable_mirroring == 1);
                $msg = Msg::new("Select the serial numbers of at least a disk for creating storage for OCR and Voting disk, excluding disks used for the Operating System and data:") if ($enable_mirroring == 0);
                $indices = $msg->menu(\@diskstrlist, $def, $help, 1, 1, 1);
                goto DNA_SELECT_OPTION if (EDR::getmsgkey($index,'back'));
            }
            $cfg->{ocrvotedgoption} = 0;
        } elsif ($index eq 2) {
            $msg = Msg::new("\nExisting disk groups with at least two disks (For Mirroring)") if ($enable_mirroring == 1);
            $msg = Msg::new("\nExisting disk groups ") if ($enable_mirroring == 0);
            $msg->print;
            my $dgnamelist = '';
            $dgnamelist = $vxdctl_master->cmd("_cmd_vxdg list | _cmd_grep -w 'shared' | awk {'print \$1'}");
            if (EDR::cmdexit()) {
                $msg = Msg::log("Problem finding eligible disks groups on $vxdctl_master->{sys}. Error info: $errstr");
                Msg::prtc();
                if (Obj::webui()) {
                    $web->web_script_form("alert", $msg->{msg});
                    goto DNA_SELECT_OPTION ;
                }
                return;
            }
            @dgnamelist=split(/\n/,$dgnamelist);
            for my $dg (@dgnamelist){
                my $diskname =$vxdctl_master->cmd("_cmd_vxdisk -g $dg list | awk {'print \$1'} | grep -v 'DEVICE'");
                if (EDR::cmdexit()) {
                    $msg = Msg::log("Problem finding eligible disks for disk group $dg on $vxdctl_master->{sys}. Error info: $errstr");
                    if (Obj::webui()) {
                        $web->web_script_form("alert", $msg->{msg});
                        goto DNA_SELECT_OPTION ;
                    }
                    Msg::prtc();
                    return;
                }
                @diskname=split(/\n/,$diskname);
                if ($enable_mirroring == 1) {
                    my $nopopup = 1;
                    if ($#diskname + 1 >= 2){
                        if (!verify_dg_vol_name($dg, $nopopup)) {
                            push(@dgdiskstrlist,$dg);
                        }
                    }
                } elsif ($enable_mirroring == 0) {
                    my $nopopup = 1;
                    if (!verify_dg_vol_name($dg, $nopopup)) {
                        push(@dgdiskstrlist,$dg);
                    }
                }
            }
            if (!@dgdiskstrlist) {
                $msg = Msg::new("No disk groups (with at least two disks) found") if ($enable_mirroring == 1) ;
                $msg = Msg::new("No disk groups found") if ($enable_mirroring == 0) ;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                goto DNA_SELECT_OPTION if (Obj::webui());
                $msg->print;
                Msg::prtc();
                return;
            }
            if (Obj::webui())
            {
                $prod->{create_ocr_vote_storage} = 3;
                $webresult=$web->web_script_form("use_dg", \@dgdiskstrlist, $enable_mirroring);
                if ($web->param("back") eq "back") {
                    goto DNA_SELECT_OPTION;
                }
                $dgname=$webresult->{dg_name};
                $prod->{create_ocr_vote_storage} = 0;

            } else {
                $msg = Msg::new("Use the command 'vxdisk -g <disk group name> list' to view the disks in the disk group\n");
                $msg->print;
                $msg = Msg::new("Select the disk group:");
                my $index = $msg->menu(\@dgdiskstrlist, $def, $help, 1);
                goto DNA_SELECT_OPTION if (EDR::getmsgkey($index,'back'));
                $dgname = $dgdiskstrlist[$index - 1];

            }
            $cfg->{ocrvotedgoption} = 1;
            $cfg->{ocrvotedgname} = $dgname;

            goto DNA_VOLTYPE;
        }

DNA_DISKINDEX_CHECK:

        if(!Obj::webui())
        {
            return unless ($indices && @{$indices});
            my $str = join(' ', @{$indices});
            if (EDR::getmsgkey($str,'back')) {
                goto DNA_SELECT_OPTION;
            }

            my %counter=();
            foreach (@{$indices})
            {
                if ($counter{$_}++) {
                    $msg = Msg::new("Choose unique disk numbers");
                    $msg->print;
                    $indices = $msg->menu(\@diskstrlist, $def, $help, 1, 1, 1);
                    goto DNA_DISKINDEX_CHECK;
                }
            }
            @seldisks=();
            for my $index (@{$indices}) {
                push (@seldisks, $diskstrlist[$index - 1]);
            }

        }

    # At least 2 disks needed as mirroring is assumed
        if ($enable_mirroring == 1) {
            if ($#seldisks + 1 < 2) {
                $msg = Msg::new("For mirroring, choose at least two disks");
                $msg->print;

                if (Obj::webui())
                {
                    $web->web_script_form("alert", $msg->{msg}) ;
                    $index=1;
                    goto DNA_OPTION_CREATE_DG; 
                } else {
                    $indices = $msg->menu(\@diskstrlist, $def, $help, 1, 1, 1);
                    goto DNA_DISKINDEX_CHECK;
                }
            }
        }
    }

DNA_DISKS:
    if (Cfg::opt('responsefile')) {
        for my $disk (@{$cfg->{ocrvotedisks}}) {
            $line = $localsys->cmd("_cmd_vxdisk list | _cmd_grep -w $disk");
            if (!EDR::cmdexit()) {
                push (@seldisks, $line);
            } else {
                $msg = Msg::new("Could not retrieve disk details. See logs for more details.");
                $msg->print;
                return;
            }
        }
    }
    # check DISK TYPE valid for VxVM
    # DEVICE       TYPE            DISK         GROUP        STATUS
    # c4t15d1      auto:cdsdisk    c4t15d1      ocrvotedg    online shared
    #
    # valid -- simple|nopriv|auto:hpdisk|cdsdisk|none
    # 3.
    # Ask for DG name
    while (1) {
        $repeat = 0;
        if (Obj::webui())
        {
            $answer=$dgname;
        } elsif (Cfg::opt('responsefile')) {
            $answer = $cfg->{ocrvotedgname};
        } else {
            $question = Msg::new("Enter the disk group name:");
            if ($defdgname eq '') {
                $answer = $question->ask($help,1,1);
            } else {
                $answer = $question->ask($defdgname, $help, 1);
            }
            goto DNA_SELECT_OPTION  if (EDR::getmsgkey($answer,'back'));
        }

        chomp($answer);

        if (verify_dg_vol_name($answer)) {
            return 1 if (Cfg::opt('responsefile'));
            goto DNA_OPTION_CREATE_DG if (Obj::webui());
            next;
        }

        $ret = $prod->validate_dgname($answer, $vxdctl_master);
        if ($ret == 2) {
            Msg::n();
            return 1 if (Cfg::opt('responsefile'));
            $msg = Msg::new("Input another name. Refer to the installer logs for more information");
            if (Obj::webui())
            {
                goto DNA_OPTION_CREATE_DG; 
            }
            $msg->print;
            $repeat = 1;
        } elsif ($ret == 1) {
            Msg::n();
            return 1 if (Cfg::opt('responsefile'));
            $msg = Msg::new("Details of '$answer' disk group: (Consult 'vxprint' manpage for details about the various fields)");
            $msg->print;
            $out = $vxdctl_master->cmd("_cmd_vxprint -g $answer");
            $msg = Msg::new($out);
            $msg->print;
            Msg::n();
            $msg = Msg::new("Input another name. Refer to the installer logs for more information");
            $msg->print;
            $defdgname = '';
            $repeat = 1;
            if (Obj::webui())
            {
                $msg = Msg::new("Disk group with the name '$dgname' already exists\\n")->{msg};
                $msg .= Msg::new("\\nInput another name. Refer to the installer logs for more information")->{msg};
                $web->web_script_form('alert', $msg);
                goto DNA_OPTION_CREATE_DG; 

            }
        }
        last if !$repeat;
    }
    $ocrdgname = $votedgname = $dgname = $answer;

    # Display all the info gathered so far for verification
    $prod->task_title('create_ocr_vote_storage');

    if (Obj::webui())
    {

        my $mesg="";
        $msg = Msg::new("Verify information for creating storage for OCR and Voting disk (Disks allocation):\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\n\tCVM Master node: $vxdctl_master->{sys}\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\tSelected disks including mirroring: \\n") if ($enable_mirroring == 1);
        $msg = Msg::new("\tSelected disks: \\n") if ($enable_mirroring == 0);
        $mesg .=$msg->{msg}; 
        my $count = 0;
        for my $disk (@seldisks) {
            $count++;
            my $handle = (split(/\s+/m, $disk))[0];
            $msg = Msg::new("\t\t${count}. $handle\\n");
            $mesg .=$msg->{msg}; 
        }
        $msg = Msg::new("\tDisk group name: $dgname\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\\nIs this information correct?");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new($mesg);
        $ayn = $msg->ayny;
    } else {

        $msg = Msg::new("Verify information for creating storage for OCR and Voting disk (Disks allocation):");
        $msg->bold;
        $msg = Msg::new("\n\tCVM Master node: $vxdctl_master->{sys}");
        $msg->print;
        $msg = Msg::new("\tSelected disks including mirroring: ") if ($enable_mirroring == 1);
        $msg = Msg::new("\tSelected disks: ") if ($enable_mirroring == 0);
        $msg->print;
        my $count = 0;
        for my $disk (@seldisks) {
            $count++;
            my $handle = (split(/\s+/m, $disk))[0];
            $msg = Msg::new("\t\t${count}. $handle");
            $msg->print;
        }
        $msg = Msg::new("\tDisk group name: $dgname");
        $msg->print;

        $question = Msg::new("\nIs this information correct?");
        $ayn = $question->ayny;
    }  

    goto DNA_CONFIRMSTORE if (Cfg::opt('responsefile'));

    if ($ayn eq 'N') {
        return 1;
    }

    # Save config for responsefile
    @{$cfg->{ocrvotedisks}} = ();
    for my $disk (@seldisks) {
        my $handle = (split(/\s+/m, $disk))[0];
        push (@{$cfg->{ocrvotedisks}}, $handle);
    }
    $cfg->{ocrvotedgname} = $dgname;
    $cfg->{enable_mirroring} = $enable_mirroring;

DNA_CONFIRMSTORE:
    # 4.
    # Perform pre-disk-init checks here
    # Like: labeling check
    # They are all PADV specific
    if ($prod->can('check_disk_labeling')) {
        $ret = $prod->check_disk_labeling(@seldisks);
        if ($ret) {
            $msg = Msg::new("At least one of the disks selected is unsuitable for initializing. See logs for more info.");
            $msg->print;
            if (Obj::webui())
            {
                $web->web_script_form("alert",$msg->{msg}) ;
                goto DNA_SELECT_OPTION; 
            }
            Msg::prtc();
            return 1;
        }
    }

    # Preparing for disks and disk group init
    my $initdisks = '';
    my @initdisks;
    my $tmpdsk;
    for my $disk (@seldisks) {
        $tmpdsk = (split(/\s+/m, $disk))[0];
        $initdisks = $initdisks.$tmpdsk.' ';
        push (@initdisks, $tmpdsk);
    }

    # 5.
    # Initialize disks (on Master)
    for my $tmpdsk (@initdisks) {
        $msg = Msg::new("Initializing disk $tmpdsk on Master ($vxdctl_master->{sys})");
        $msg->left;
        eval {$vxdctl_master->cmd("_cmd_vxdisk -f init $tmpdsk type=auto format=cdsdisk");};
        $errstr = $@;
        if ($errstr) {
            Msg::right_failed;
            $msg = Msg::new("Initializing disk $tmpdsk on Master ($vxdctl_master->{sys}) failed. Refer to the installer logs for more information.") if (Obj::webui()); 
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());

            $msg = Msg::new("Error info: $errstr");
            $msg->log;
            Msg::prtc();
            return 1;
        } else {
            if (EDR::cmdexit()) {
                Msg::right_failed;
                $msg = Msg::new("Initializing disk $tmpdsk on Master ($vxdctl_master->{sys}) failed. Refer to the installer logs for more information.") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                Msg::prtc();
                return 1;
            }
            Msg::right_done;
        }
    }

    # 6.
    # Assign disk group name (On Master)
    $msg = Msg::new("Initializing disk group on Master ($vxdctl_master->{sys})");
    $msg->left;

    eval {$vxdctl_master->cmd("_cmd_vxdg -s init $dgname $initdisks");};
    
    $errstr = $@;
    if ($errstr) {
        Msg::right_failed;
        $msg = Msg::new("Error info: $errstr");
        $msg->log;
        $msg = Msg::new("Initializing disk group on Master ($vxdctl_master->{sys}) failed. Refer to the installer logs for more information.") if (Obj::webui()); 
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        return 1;
    } else {
        if (EDR::cmdexit()) {
            Msg::right_failed;
            $msg = Msg::new("Initializing disk group on Master ($vxdctl_master->{sys}) failed. Refer to the installer logs for more information.") if (Obj::webui()); 
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            Msg::prtc();
            return 1;
        }
        Msg::right_done;
    }
    Msg::prtc();

DNA_VOLTYPE:
    # 7.
    # Ask whether using raw CVM volumes or CFS
    $prod->task_title('create_ocr_vote_storage');

    # Define the available choice for storage types here
    @storeopts = @{$prod->{storage_opts}};
DNA_SELECT_STORAGE:
    $defvolsize = 640;

    if (Cfg::opt('responsefile')) {
        $dgname = $cfg->{ocrvotedgname};
        $storeopt = $prod->{storage_opts}[$cfg->{ocrvotescheme}];
        $onraw = 1 if ($storeopt eq $prod->{storage_opts}[0]);
        $oncfs = 1 if ($storeopt eq $prod->{storage_opts}[1]);
    } else {
        if(Obj::webui())
        {
            $prod->{create_ocr_vote_storage} = 4;
            $webresult=$web->web_script_form("selectstorageoptions", $web, $prod, $sys);
            if ($web->param("back") eq "back") {
                goto DNA_SELECT_OPTION;
            }
            if ($webresult eq "1")
            {
                $onraw = 1;
                $storeopt = $storeopts[0];
                $index=1;
            }
            if ($webresult eq "2")
            {
                $oncfs = 1 ;
                $storeopt = $storeopts[1];
                $index=2;
            }
            $prod->{create_ocr_vote_storage} = 0;
        } else {
            $onraw = 0 ;
            $oncfs = 0 ;
            $msg = Msg::new("Storage scheme for OCR and Voting disk storage:");
            $msg->print;
            $msg = Msg::new("Select the storage scheme to be used:");
            $index = $msg->menu(\@storeopts, $def, $help, 1);
            goto DNA_SELECT_OPTION if (EDR::getmsgkey($index,'back'));
            $storeopt = $storeopts[$index - 1];
            $onraw = 1 if ($storeopt eq $prod->{storage_opts}[0]);
            $oncfs = 1 if ($storeopt eq $prod->{storage_opts}[1]);
            Msg::n;
        }
    }


    # 8.
    # Ask for volume name and size
    if ($onraw) {

DNA_SEP_FILESYS:
    # Separate queries for OCR and Vote volumes
        $defvolname = 'ocrvol';
        $defvolsize /= 2;
        $unavailsize = 0; # You have all the space to create volume here

DNA_CREATE_RAW_VOL:

            if (Obj::webui())
            {
                $prod->{create_ocr_vote_storage} = 5;
                $webresult=$web->web_script_form("create_raw_vol", $web, $prod, $sys);
                if ($web->param("back") eq "back") {
                    $onraw = 0 ;
                    $oncfs = 0 ;
                    goto DNA_SELECT_STORAGE;
                }
                $prod->{create_ocr_vote_storage} = 0;

            }
        while (1) {
            $repeat = 0;
    # Volume name for OCR
            if (Cfg::opt('responsefile')) {
                $answer = $cfg->{ocrvolname};
            } else {

                if (Obj::webui())
                {
                    $answer=$cfg->{ocrvolname} ;

                } else {
                    $question = Msg::new("Enter the volume name for OCR:");
                    $answer = $question->ask($defvolname, $help, 1);
                    goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                }

            } 
            chomp($answer);

            if (verify_dg_vol_name($answer)) {
                return 1 if (Cfg::opt('responsefile'));
                goto DNA_CREATE_RAW_VOL if(Obj::webui());
                next;
            }

            $ocrvolname = $answer;

    # Volume size for OCR
            if (Cfg::opt('responsefile')) {
                $answer = $cfg->{ocrvolsize};
            } else {
                if (Obj::webui())
                {
                    $answer=$cfg->{ocrvolsize};
                } else {
                    $question = Msg::new("Enter the volume size for OCR (in MB):");
                    $answer = $question->ask($defvolsize, $help, 1);
                    goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                }
            }
            chomp($answer);
            if ($answer =~ /\D+/m) {
                $msg = Msg::new("Enter only a numerical. Input again");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                if (Obj::webui())
                {
                    $web->web_script_form("alert", $msg->{msg}) ;
                    goto DNA_CREATE_RAW_VOL ;

                }
                next;
            }
            if ((0+$answer) < $defvolsize) {
                $msg = Msg::new("Volume with the size $answer MB would be too small for OCR purposes. Choose at least $defvolsize MB of space.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                if (Obj::webui())
                {
                    $web->web_script_form("alert", $msg->{msg}) ;
                    goto DNA_CREATE_RAW_VOL ;

                }
                next;
            }
            $ocrvolsize = $answer;

            if ($prod->validate_vol($ocrvolname, $ocrvolsize, $unavailsize, $dgname, $vxdctl_master, $enable_mirroring)) {
                $msg = Msg::new("Input another name. Refer to the installer logs for more information");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                if (Obj::webui())
                {
                    goto DNA_CREATE_RAW_VOL ;

                }
                $repeat = 1;
            }
            last if !$repeat;
        }

        $defvolname = 'votevol';
        $unavailsize = $ocrvolsize; # You have (total - $ocrvolsize) available
            while (1) {
                $repeat = 0;
    # Volume name for Vote
                if (Cfg::opt('responsefile')) {
                    $answer = $cfg->{votevolname};
                } else {
                    if (Obj::webui())
                    {
                        $answer=$cfg->{votevolname} ;
                    } else {
                        $question = Msg::new("Enter the volume name for Vote:");
                        $answer = $question->ask($defvolname, $help, 1);
                        goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                    }
                }
                chomp($answer);

                if (verify_dg_vol_name($answer)) {
                    return 1 if (Cfg::opt('responsefile'));
                    goto DNA_CREATE_RAW_VOL if(Obj::webui());
                    next;
                }

                $votevolname = $answer;

    # Volume size for Vote
                if (Cfg::opt('responsefile')) {
                    $answer = $cfg->{votevolsize};
                } else {
                    if (Obj::webui())
                    {
                        $answer = $cfg->{votevolsize};
                    } else {
                        $question = Msg::new("Enter the volume size for Vote (in MB):");
                        $answer = $question->ask($defvolsize, $help, 1);
                        goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                    }
                }
                chomp($answer);
                if ($answer =~ /\D+/m) {
                    $msg = Msg::new("Enter only a numerical. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    if (Obj::webui())
                    {
                        $web->web_script_form("alert", $msg->{msg}) ;
                        goto DNA_CREATE_RAW_VOL ;

                    }
                    next;
                }
                if ((0+$answer) < $defvolsize) {
                    $msg = Msg::new("Volume with the size $answer MB would be too small for Vote purposes. Choose at least $defvolsize MB of space.");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    if (Obj::webui())
                    {
                        $web->web_script_form("alert", $msg->{msg}) ;
                        goto DNA_CREATE_RAW_VOL ;
                    }
                    next;
                }
                $votevolsize = $answer;

                if ($prod->validate_vol($votevolname, $votevolsize, $unavailsize, $dgname, $vxdctl_master , $enable_mirroring)) {
                    $msg = Msg::new("Input another name. Refer to the installer logs for more information");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    if (Obj::webui())
                    {
                        goto DNA_CREATE_RAW_VOL ;
                    }
                    $repeat = 1;
                }
                last if !$repeat;
            }
    } elsif ($oncfs) {
    # Single query for both OCR and Vote
        $msg = Msg::new("\nDo you want to create separate filesystems for ocr and vote?");
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            $enable_sep_filesys = 0;
        } else {
            $enable_sep_filesys = 1;
        }
        if (Cfg::opt('responsefile')) {
            $enable_sep_filesys = $cfg->{enable_sep_filesys};
        }
 DNA_CREATE_CFS:
        if ($enable_sep_filesys == 0){
            $defvolname = 'ocrvotevol';
            $unavailsize = 0; # You have all the space to create volume here


                if (Obj::webui())
                {
                    $prod->{create_ocr_vote_storage} = 6;
                    $webresult=$web->web_script_form("create_cfs", $web, $prod, $sys);
                    if ($web->param("back") eq "back") {
                        $onraw = 0 ;
                        $oncfs = 0 ;
                        goto DNA_SELECT_STORAGE;
                    }
                    $prod->{create_ocr_vote_storage} = 0;
                }
            while (1) {
                $repeat = 0;
    # Volume name for OCR/Vote
                if (Cfg::opt('responsefile')) {
                    $answer = $cfg->{ocrvotevolname};
                } else {
                    if (Obj::webui())
                    {
                        $answer=$cfg->{ocrvotevolname} ;
                    } else {
                        $question = Msg::new("Enter the volume name for OCR and Voting disk:");
                        $answer = $question->ask($defvolname, $help, 1);
                        goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                    }
                }
                chomp($answer);

                if (verify_dg_vol_name($answer)) {
                    return 1 if (Cfg::opt('responsefile'));
                    goto DNA_CREATE_CFS if(Obj::webui());
                    next;
                }

                $volname = $answer;

    # Volume size for OCR
                if (Cfg::opt('responsefile')) {
                    $answer = $cfg->{ocrvotevolsize};
                } else {
                    if (Obj::webui())
                    {
                        $answer=$cfg->{ocrvotevolsize} ;
                    } else {
                        $question = Msg::new("Enter the volume size for OCR and Voting disk (in MB):");
                        $answer = $question->ask($defvolsize, $help, 1);
                        goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                    }
                }
                chomp($answer);
                if ($answer =~ /\D+/m) {
                    $msg = Msg::new("Enter only a numerical. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    if (Obj::webui())
                    {
                        $web->web_script_form("alert", $msg->{msg}) ;
                        goto DNA_CREATE_CFS;

                    }
                    next;
                }
                if ((0+$answer) < $defvolsize) {
                    $msg = Msg::new("Volume with the size $answer MB would be too small for storing OCR and Voting disk. Choose at least $defvolsize MB of space.");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    if (Obj::webui())
                    {
                        $web->web_script_form("alert", $msg->{msg}) ;
                        goto DNA_CREATE_CFS;

                    }
                    next;
                }
                $volsize = $answer;

                if ($prod->validate_vol($volname, $volsize, $unavailsize, $dgname, $vxdctl_master, $enable_mirroring)) {
                    $msg = Msg::new("Input another name. Refer to the installer logs for more information");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    if (Obj::webui())
                    {
                        goto DNA_CREATE_CFS;

                    }
                    $repeat = 1;
                }
                last if !$repeat;
            }
        } elsif ($enable_sep_filesys == 1) {
            goto DNA_SEP_FILESYS; 
        }
    } else {
        $msg = Msg::new("Unknown storage scheme: $storeopt");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    # 9.
    # Ask Oracle user/group
    # Saved in $prod->{oracle_user} and $prod->{oracle_group} respectively

DNA_CREATE_OCR_USER_GROUP:

    if(Obj::webui())
    {
        $prod->{create_ocr_vote_storage} = 7;
        $webresult=$web->web_script_form("create_ocr_user_group", $web,$prod,$sys);
        if ($web->param("back") eq "back") {
            goto DNA_CREATE_RAW_VOL if ($onraw == 1);
            goto DNA_CREATE_CFS if ($oncfs == 1);
        }
        $prod->{create_ocr_vote_storage} = 0;

    }

    $ret = $prod->find_oracle_user($preinst);
    if ($ret == 3)
    {
        goto DNA_SELECT_STORAGE;
    }
    if ($ret == 1) {
        $msg = Msg::new("There was a problem in finding Oracle user");
        $msg->print;
        Msg::prtc();
        if (Obj::webui())
        {
            $web->web_script_form("alert", $msg->{msg}) ;
        }
        return 1;
    }
    if ($ret == 4)
    {
        goto DNA_CREATE_OCR_USER_GROUP;

    }

    # [TBD] We should clean up the code like above to consider grid and oracle user.
    if (Cfg::opt('responsefile')) {
    # Comment : Do not use Oracle release
        if ($cfg->{grid_user} eq '') {
            $temp_user = $cfg->{oracle_user};
        } else {
            $temp_user = $cfg->{grid_user};
        }
    } else {
        $temp_user = $prod->{oracle_user};
    }

    $ret = $prod->find_oracle_group($preinst, 1);
    if ($ret == 3)
    {
        goto DNA_SELECT_STORAGE;
    }
    if ($ret == 1) {
        $msg = Msg::new("There was a problem in finding Oracle group");
        $msg->print;
        if (Obj::webui())
        {
            $web->web_script_form("alert", $msg->{msg}) ;
        }
        Msg::prtc();
        return 1;
    }
    if ($ret == 4)
    {
        goto DNA_CREATE_OCR_USER_GROUP;

    }

    # Sanity check for Oracle user cum group
    # Comment >> Change to use temp_user
    if ($prod->oracle_sanity($temp_user, $prod->{oracle_group}) == 1) {
        $msg = Msg::new("There was a problem in sanity test for Oracle user/group");
        $msg->print;
        goto DNA_CREATE_OCR_USER_GROUP if (Obj::webui());
        Msg::prtc();
        return 1;
    }
    Msg::prtc();

    # Display all the info gathered so far for verification
    $prod->task_title('create_ocr_vote_storage');

    if(Obj::webui())
    {
        my $mesg="";
        $msg = Msg::new("Verify information about creating storage for OCR and Voting disk:\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\\n\\tStorage scheme for OCR and Voting disk: $storeopt\\n");
        $mesg .=$msg->{msg}; 
        if ($onraw) {
            $msg = Msg::new("\\tVolume name for OCR: $ocrvolname\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("\\tVolume size for OCR: $ocrvolsize MB\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("\\tVolume name for Voting disk: $votevolname\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("\\tVolume size for Voting disk: $votevolsize MB\\n");
            $mesg .=$msg->{msg}; 
        } elsif ($oncfs) {
            if ($enable_sep_filesys == 0) {
                $msg = Msg::new("\\tVolume name for OCR and Voting disk: $volname\\n");
                $mesg .=$msg->{msg}; 
                $msg = Msg::new("\\tVolume size for OCR and Voting disk: $volsize MB\\n");
                $mesg .=$msg->{msg}; 
            } elsif ($enable_sep_filesys == 1) {
                $msg = Msg::new("\\tVolume name for OCR: $ocrvolname\\n");
                $mesg .=$msg->{msg}; 
                $msg = Msg::new("\\tVolume size for OCR: $ocrvolsize MB\\n");
                $mesg .=$msg->{msg}; 
                $msg = Msg::new("\\tVolume name for Voting disk: $votevolname\\n");
                $mesg .=$msg->{msg}; 
                $msg = Msg::new("\\tVolume size for Voting disk: $votevolsize MB\\n");
                $mesg .=$msg->{msg}; 
            }

        }
        $msg = Msg::new("\\tOracle UNIX user: $temp_user\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\\tOracle UNIX group: $prod->{oracle_group}\\n");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new("\\nIs this information correct?");
        $mesg .=$msg->{msg}; 
        $msg = Msg::new($mesg);
        $ayn = $msg->ayny;

    } else {
        $msg = Msg::new("Verify information about creating storage for OCR and Voting disk:");
        $msg->print;
        $msg = Msg::new("\n\tStorage scheme for OCR and Voting disk: $storeopt");
        $msg->print;
        if ($onraw) {
            $msg = Msg::new("\tVolume name for OCR: $ocrvolname");
            $msg->print;
            $msg = Msg::new("\tVolume size for OCR: $ocrvolsize");
            $msg->print;
            $msg = Msg::new("\tVolume name for Voting disk: $votevolname");
            $msg->print;
            $msg = Msg::new("\tVolume size for Voting disk: $votevolsize");
            $msg->print;
        } elsif ($oncfs) {
            if ($enable_sep_filesys == 0) {
                $msg = Msg::new("\tVolume name for OCR and Voting disk: $volname");
                $msg->print;
                $msg = Msg::new("\tVolume size for OCR and Voting disk: $volsize");
                $msg->print;
            } elsif ($enable_sep_filesys == 1) {
                $msg = Msg::new("\tVolume name for OCR: $ocrvolname");
                $msg->print;
                $msg = Msg::new("\tVolume size for OCR: $ocrvolsize");
                $msg->print;
                $msg = Msg::new("\tVolume name for Voting disk: $votevolname");
                $msg->print;
                $msg = Msg::new("\tVolume size for Voting disk: $votevolsize");
                $msg->print;
            }
        }
        $msg = Msg::new("\tOracle UNIX user: $temp_user");
        $msg->print;
        $msg = Msg::new("\tOracle UNIX group: $prod->{oracle_group}");
        $msg->print;
        $msg->n;

        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny;
    }
    
    goto DNA_CONFIRMVOLS if (Cfg::opt('responsefile'));
    if ($ayn eq 'N') {
        return 1;
    }
    # Save config for responsefile
    if (!Cfg::opt('responsefile')) {
        $cfg->{ocrvotescheme} = $index - 1;
        $cfg->{ocrvolname} = $ocrvolname;
        $cfg->{ocrvolsize} = $ocrvolsize;
        $cfg->{votevolname} = $votevolname;
        $cfg->{votevolsize} = $votevolsize;
        $cfg->{ocrvotevolname} = $volname;
        $cfg->{ocrvotevolsize} = $volsize;
        $cfg->{oracle_user} = $temp_user;

        $cfg->{oracle_group} = $prod->{oracle_group};
        $cfg->{enable_sep_filesys} = $enable_sep_filesys;
    }

DNA_CONFIRMVOLS:
    # If the call is coming from 'responsefile' you need not perform any checks
    # because it'd not even pass the 'create_oracle_user_group' if the responsefile
    # was altered (which is the fear why you'd want to validate Oracle user/group
        if (Cfg::opt('responsefile')) {
        $prod->{oracle_user} = $cfg->{oracle_user};
        $prod->{oracle_group} = $cfg->{oracle_group};
        }

    # 10.
    # Create volume
        if ($onraw || ($enable_sep_filesys == 1)) {
        $msg = Msg::new("Creating volume '$ocrvolname' for OCR on CVM Master ($vxdctl_master->{sys})");
        $msg->left;
        eval {$vxdctl_master->cmd("_cmd_vxassist -g $dgname make $ocrvolname ${ocrvolsize}m nmirror=2 layout=mirror $initdisks");} if ($enable_mirroring == 1);
        eval {$vxdctl_master->cmd("_cmd_vxassist -g $dgname make $ocrvolname ${ocrvolsize}m $initdisks");} if ($enable_mirroring == 0);
        $errstr = $@;
        if ($errstr) {
        Msg::right_failed;
        $msg = Msg::new("Error info: $errstr");
        $msg->log;
        Msg::prtc();
        $msg = Msg::new(" Creating volume '$ocrvolname' for OCR on CVM Master ($vxdctl_master->{sys}) failed") if (Obj::webui()); 
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
        } else {
            if (EDR::cmdexit()) {
                Msg::right_failed;
                Msg::prtc();
                $msg = Msg::new(" Creating volume '$ocrvolname' for OCR on CVM Master ($vxdctl_master->{sys}) failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            Msg::right_done;
        }

        $msg = Msg::new("Creating volume '$votevolname' for Voting disk on CVM Master ($vxdctl_master->{sys})");
        $msg->left;
        eval {$vxdctl_master->cmd("_cmd_vxassist -g $dgname make $votevolname ${votevolsize}m nmirror=2 layout=mirror $initdisks");} if ($enable_mirroring == 1);
        eval {$vxdctl_master->cmd("_cmd_vxassist -g $dgname make $votevolname ${votevolsize}m $initdisks");} if ($enable_mirroring == 0);
        $errstr = $@;
        if ($errstr) {
            Msg::right_failed;
            $msg = Msg::new("Error info: $errstr");
            $msg->log;
            Msg::prtc();
            $msg = Msg::new(" Creating volume '$votevolname' for OCR on CVM Master ($vxdctl_master->{sys}) failed") if (Obj::webui()); 
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            return 1;
        } else {
            if (EDR::cmdexit()) {
                Msg::right_failed;
                Msg::prtc();
                $msg = Msg::new(" Creating volume '$votevolname' for OCR on CVM Master ($vxdctl_master->{sys}) failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            Msg::right_done;
        }
        } elsif ($oncfs) {
            
            if ($enable_sep_filesys == 0) {
                $msg = Msg::new("Creating volume '$volname' for OCR and Voting disk on CVM Master ($vxdctl_master->{sys})");
                $msg->left;
                eval {$vxdctl_master->cmd("_cmd_vxassist -g $dgname make $volname ${volsize}m nmirror=2 layout=mirror $initdisks");} if ($enable_mirroring == 1);
                eval {$vxdctl_master->cmd("_cmd_vxassist -g $dgname make $volname ${volsize}m  $initdisks");} if ($enable_mirroring == 0);
                $errstr = $@;
                if ($errstr) {
                    Msg::right_failed;
                    $msg = Msg::new("Error info: $errstr");
                    $msg->log;
                    Msg::prtc();
                    $msg = Msg::new(" Creating volume '$volname' for OCR and Voting disk on CVM Master ($vxdctl_master->{sys}) failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        Msg::prtc();
                        $msg = Msg::new(" Creating volume '$volname' for OCR and Voting disk on CVM Master ($vxdctl_master->{sys}) failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        return 1;
                    }
                    Msg::right_done;
                }
            } 
        }

    # 11.
    # Set user/group for volume(s)
        if ($onraw) {
            $msg = Msg::new("Setting the owner of the volume '$ocrvolname' as '$temp_user:$prod->{oracle_group}'");
            $msg->left;
            eval {$vxdctl_master->cmd("_cmd_vxedit -g $dgname set user=$temp_user group=$prod->{oracle_group} mode=660 $ocrvolname");};
            $errstr = $@;
            if ($errstr) {
                Msg::right_failed;
                $msg = Msg::new("Error info: $errstr");
                $msg->log;
                Msg::prtc();
                $msg = Msg::new(" Setting the owner of the volume '$ocrvolname' as '$temp_user:$prod->{oracle_group}' failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                if (EDR::cmdexit()) {
                    Msg::right_failed;
                    Msg::prtc();
                    $msg = Msg::new(" Setting the owner of the volume '$ocrvolname' as '$temp_user:$prod->{oracle_group}' failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                }
                Msg::right_done;
            }

            $msg = Msg::new("Setting the owner of volume '$votevolname' as '$temp_user:$prod->{oracle_group}'");
            $msg->left;
            eval {$vxdctl_master->cmd("_cmd_vxedit -g $dgname set user=$temp_user group=$prod->{oracle_group} mode=660 $votevolname");};
            $errstr = $@;
            if ($errstr) {
                Msg::right_failed;
                $msg = Msg::new("Error info: $errstr");
                $msg->log;
                Msg::prtc();
                $msg = Msg::new(" Setting the owner of the volume '$votevolname' as '$temp_user:$prod->{oracle_group}' failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                if (EDR::cmdexit()) {
                    Msg::right_failed;
                    Msg::prtc();
                    $msg = Msg::new(" Setting the owner of the volume '$votevolname' as '$temp_user:$prod->{oracle_group}' failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                }
                Msg::right_done;
            }
        }

    # 12.
    # Start volume(s) on all nodes
        for my $sys (@{CPIC::get('systems')}) {
            eval {$sys->cmd("_cmd_vxdg -g $dgname set activation=sw");};
            if ($vxdctl_master == $sys) {
                $msg = Msg::new("Starting all the volumes on diskgroup '$dgname' on $sys->{sys}");
                $msg->left;
                eval {$vxdctl_master->cmd("_cmd_vxvol -g $dgname startall");};
                $errstr = $@;
                if ($errstr) {
                    Msg::right_failed;
                    $msg = Msg::new("Error info: $errstr");
                    $msg->log;
                    Msg::prtc();
                    $msg = Msg::new(" Starting all the volumes on diskgroup '$dgname' on $sys->{sys} failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        Msg::prtc();
                        $msg = Msg::new(" Starting all the volumes on diskgroup '$dgname' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        return 1;
                    }
                    Msg::right_done;
                }
            }
        }

    # 13.
    # Create and mount CFS if so was the choice
        if ($oncfs) {
    # Create mount point on all nodes with Oracle user/group as the owner
DNA_CREATE_CFSMOUNT:

          if(Obj::webui())
          {
              $prod->{create_ocr_vote_storage} = 8;
              if ($enable_sep_filesys == 0) {
                  $webresult=$web->web_script_form("create_cfsmount", $web,$prod,$sys);
              } elsif ($enable_sep_filesys == 1) {
                  $webresult=$web->web_script_form("create_cfsmount_sep_filesys", $web, $prod, $sys);
              }

              if ($web->param("back") eq "back") {
                  goto DNA_CREATE_CFS;
              }
              $prod->{create_ocr_vote_storage} = 0;

          }


            while (1) {
                $repeat = 0;
                if (Cfg::opt('responsefile')) {
                    if ($enable_sep_filesys == 0) {
                        $answer = $cfg->{ocrvotemount};
                    } elsif ($enable_sep_filesys == 1) {
                        $ocrmount  = $cfg->{ocrmount};
                        $votemount  = $cfg->{votemount};
                    }
                } else {

                    if(Obj::webui())
                    {
                        if ($enable_sep_filesys == 0) {
                            $answer = $cfg->{ocrvotemount};
                        } elsif ($enable_sep_filesys == 1) {
                            $ocrmount  = $cfg->{ocrmount};
                            $votemount  = $cfg->{votemount};
                        }
                    } else {
                        if ($enable_sep_filesys == 0) {
                            $question = Msg::new("Enter the mount point location for CFS (common for all the nodes):");
                            $answer = $question->ask($defmntpt, $help, 1);
                            goto DNA_SELECT_STORAGE if (EDR::getmsgkey($answer,'back'));
                        } elsif ($enable_sep_filesys == 1) {
                            $question = Msg::new("Enter the mount point location for OCR storage (common for all the nodes):");
                            $ocrmount = $question->ask($defocrmntpt, $help, 1);
                            goto DNA_SELECT_STORAGE if (EDR::getmsgkey($ocrmount,'back'));
                            $question = Msg::new("Enter the mount point location for Vote storage (common for all the nodes):");
                            $votemount = $question->ask($defvotemntpt, $help, 1);
                            goto DNA_SELECT_STORAGE if (EDR::getmsgkey($votemount,'back'));
                        }
                    }
                }
                chomp($answer) if ($enable_sep_filesys == 0);
                chomp($ocrmount) if ($enable_sep_filesys == 1);
                chomp($votemount) if ($enable_sep_filesys == 1);

                if ($enable_sep_filesys == 0) {
                    my $first_char = substr( $answer, 0, 1 );
                    if ($first_char ne '/') {
                        $msg = Msg::new("Enter the absolute mount point location for CFS. Make sure that there are no leading or trailing spaces.");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    if ($answer !~ /^[0-9a-zA-Z|\-|\_|\/]*$/mx) {
                        $msg = Msg::new("Invalid name chosen. Make sure that there are no leading or trailing spaces. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    if (verify_mount_point($answer)) {
                        $msg = Msg::new("$answer already seems to be mounted on one or more nodes on the cluster. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                } elsif ($enable_sep_filesys == 1) {
                    $ocrmount = trim($ocrmount);
                    $votemount = trim($votemount);
                    if ($votemount eq $ocrmount) {
                        $msg = Msg::new("Enter different mount point locations for OCR and Vote storage.");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    my $first_char = substr( $ocrmount, 0, 1 );
                    if ($first_char ne '/') {
                        $msg = Msg::new("Enter the absolute mount point location for OCR storage.");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    if ($ocrmount!~ /^[0-9a-zA-Z|\-|\_|\/]*$/mx) {
                        $msg = Msg::new("Invalid OCR mount name chosen. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    if (verify_mount_point($ocrmount)) {
                        $msg = Msg::new("$ocrmount already seems to be mounted on one or more nodes on the cluster. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    $first_char = substr( $votemount, 0, 1 );
                    if ($first_char ne '/') {
                        $msg = Msg::new("Enter the absolute mount point location for Vote storage.");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    if ($votemount!~ /^[0-9a-zA-Z|\-|\_|\/]*$/mx) {
                        $msg = Msg::new("Invalid Vote mount name chosen. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                    if (verify_mount_point($votemount)) {
                        $msg = Msg::new("$votemount already seems to be mounted on one or more nodes on the cluster. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;

                        }
                        next;
                    }
                }
                
                if ($enable_sep_filesys == 0) {
                    $msg = Msg::new("Creating CFS mount point at $answer");
                    $msg->left;
                    $ret = $prod->create_dir($answer, $temp_user, $prod->{oracle_group}, '755');
                    if ($ret) {
                        Msg::right_failed;
                        $msg = Msg::new("Failed to create directory $answer on at least one node. Try again.");
                        $msg->log;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;
                        }
                        $repeat = 1;
                    } else {
                        Msg::right_done;
                    }
                } elsif ($enable_sep_filesys == 1) {
                    $msg = Msg::new("Creating CFS mount point at $ocrmount");
                    $msg->left;
                    $ret = $prod->create_dir($ocrmount, $temp_user, $prod->{oracle_group}, '755');
                    if ($ret) {
                        Msg::right_failed;
                        $msg = Msg::new("Failed to create directory $ocrmount on at least one node. Try again.");
                        $msg->log;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;
                        }
                        $repeat = 1;
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Creating CFS mount point at $votemount");
                    $msg->left;
                    $ret = $prod->create_dir($votemount, $temp_user, $prod->{oracle_group}, '755');
                    if ($ret) {
                        Msg::right_failed;
                        $msg = Msg::new("Failed to create directory $votemount on at least one node. Try again.");
                        $msg->log;
                        return 1 if (Cfg::opt('responsefile'));
                        if (Obj::webui())
                        {
                            $web->web_script_form("alert", $msg->{msg}) ;
                            goto DNA_CREATE_CFSMOUNT;
                        }
                        $repeat = 1;
                    } else {
                        Msg::right_done;
                    }

                }

                last if !$repeat;
            }


            if ($enable_sep_filesys == 0) {
                $cfsmntpt = $answer;
                $cfg->{ocrvotemount} = $cfsmntpt if (!Cfg::opt('responsefile'));
            } elsif ($enable_sep_filesys == 1) {

                $cfg->{ocrmount} = $ocrmount if (!Cfg::opt('responsefile'));
                $cfg->{votemount} = $votemount if (!Cfg::opt('responsefile'));
            }
    #if ($enable_sep_filesys == 1) Make (on Master) and mount (on all nodes) CFS
    # They are PADV specific operations
            $msg = Msg::new("Creating CFS on the Master node and mounting it on all the nodes") if ($enable_sep_filesys == 0);
            $msg = Msg::new("Creating OCR and Vote storage on the Master node and mounting it on all the nodes") if ($enable_sep_filesys == 1);
            $msg->left;
            if ($prod->can('make_mount_cfs')) {

                if ($enable_sep_filesys == 0) {
                    ($ret, $mk, $mkret, %mnt, %mntret) = $prod->make_mount_cfs($dgname, $volname, $cfsmntpt, $vxdctl_master);
                    if ($ret) {
                        Msg::right_failed;
                        Msg::prtc();
                        $msg = Msg::new(" Creating CFS on the Master node and mounting it on all the nodes failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        return 1;
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Make FS gave: $mk");
                    $msg->log;
                    for my $sys (@{CPIC::get('systems')}) {
                        $msg = Msg::new("Mount FS on $sys->{sys} gave: $mnt{$sys}");
                        $msg->log;
                    }
                } elsif ($enable_sep_filesys == 1) {
                    ($ret, $mk, $mkret, %mnt, %mntret) = $prod->make_mount_cfs($dgname, $ocrvolname, $ocrmount, $vxdctl_master);
                    if ($ret) {
                        Msg::right_failed;
                        Msg::prtc();
                        $msg = Msg::new(" Creating OCR on the Master node and mounting it on all the nodes failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        return 1;
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Make FS gave: $mk");
                    $msg->log;
                    for my $sys (@{CPIC::get('systems')}) {
                        $msg = Msg::new("Mount FS on $sys->{sys} gave: $mnt{$sys}");
                        $msg->log;
                    }
                    ($ret, $mk, $mkret, %mnt, %mntret) = $prod->make_mount_cfs($dgname, $votevolname, $votemount, $vxdctl_master);
                    if ($ret) {
                        Msg::right_failed;
                        Msg::prtc();
                        $msg = Msg::new(" Creating Vote on the Master node and mounting it on all the nodes failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        return 1;
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Make FS gave: $mk");
                    $msg->log;
                    for my $sys (@{CPIC::get('systems')}) {
                        $msg = Msg::new("Mount FS on $sys->{sys} gave: $mnt{$sys}");
                        $msg->log;
                    }
                }
            } else {
                $msg = Msg::new(" Creating CFS on the Master node and mounting it on all the nodes failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                Msg::right_failed;
            }

    # Oracle user/group's ownership to this mountpoint
            for my $sys (@{CPIC::get('systems')}) {
                if ($enable_sep_filesys == 0) {
                    $msg = Msg::new("Setting the owner of the CFS mountpoint '$cfsmntpt' as '$temp_user:$prod->{oracle_group}' on $sys->{sys}");
                    $msg->left;
                    $ret = $sys->cmd("_cmd_chown -R $temp_user:$prod->{oracle_group} $cfsmntpt");
                    $msg = Msg::new($ret);
                    $msg->log;
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        $msg = Msg::new(" Setting the owner of the CFS mountpoint '$cfsmntpt' as '$temp_user:$prod->{oracle_group}' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Setting the permissions of the CFS mountpoint '$cfsmntpt' as '755' on $sys->{sys}");
                    $msg->left;
                    $ret = $sys->cmd("_cmd_chmod 755 $cfsmntpt");
                    $msg = Msg::new($ret);
                    $msg->log;
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        $msg = Msg::new(" Setting the owner of the CFS mountpoint '$cfsmntpt' as '755' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    } else {
                        Msg::right_done;
                    }
                } elsif ($enable_sep_filesys == 1) {
                    $msg = Msg::new("Setting the owner of the OCR mountpoint '$ocrmount' as '$temp_user:$prod->{oracle_group}' on $sys->{sys}");
                    $msg->left;
                    $ret = $sys->cmd("_cmd_chown -R $temp_user:$prod->{oracle_group} $ocrmount");
                    $msg = Msg::new($ret);
                    $msg->log;
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        $msg = Msg::new(" Setting the owner of the OCR mountpoint '$ocrmount' as '$temp_user:$prod->{oracle_group}' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Setting the owner of the Vote mountpoint '$votemount' as '$temp_user:$prod->{oracle_group}' on $sys->{sys}");
                    $msg->left;
                    $ret = $sys->cmd("_cmd_chown -R $temp_user:$prod->{oracle_group} $votemount");
                    $msg = Msg::new($ret);
                    $msg->log;
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        $msg = Msg::new(" Setting the owner of the Vote mountpoint '$votemount' as '$temp_user:$prod->{oracle_group}' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Setting the permissions of the OCR mountpoint '$ocrmount' as '755' on $sys->{sys}");
                    $msg->left;
                    $ret = $sys->cmd("_cmd_chmod 755 $ocrmount");
                    $msg = Msg::new($ret);
                    $msg->log;
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        $msg = Msg::new(" Setting the owner of the OCR mountpoint '$ocrmount' as '755' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    } else {
                        Msg::right_done;
                    }
                    $msg = Msg::new("Setting the permissions of the Vote mountpoint '$votemount' as '755' on $sys->{sys}");
                    $msg->left;
                    $ret = $sys->cmd("_cmd_chmod 755 $votemount");
                    $msg = Msg::new($ret);
                    $msg->log;
                    if (EDR::cmdexit()) {
                        Msg::right_failed;
                        $msg = Msg::new(" Setting the owner of the Vote mountpoint '$votemount' as '755' on $sys->{sys} failed") if (Obj::webui()); 
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    } else {
                        Msg::right_done;
                    }
                }
            }
        }
        Msg::prtc();

    # 14.
    # If everything till now was successfull, add this configuration to main.cf
        $prod->task_title('create_ocr_vote_storage');

        if ($oncfs) {
            if ($enable_sep_filesys == 0) {
                $msg = Msg::new("Adding CFSMount '$prod->{cfsmnt_res_name}_$dgname' and CVMVolDg '$prod->{cvmvoldg_res_name}_$dgname' resources to VCS configuration:");
            } elsif ($enable_sep_filesys == 1) {
                $msg = Msg::new("Adding CFSMount '$prod->{cfsvotemnt_res_name}_$dgname', '$prod->{cfsocrmnt_res_name}_$dgname'  and CVMVolDg '$prod->{cvmvoldg_res_name}_$dgname' resources to VCS configuration:");
            }
        } elsif ($onraw) {
            $msg = Msg::new("Adding CVMVolDg '$prod->{cvmvoldg_res_name}_$dgname' resource to VCS configuration:");
        }
        $msg->print;
        $ret = $prod->change_vcs_config_perm;
        $msg = Msg::new("Changing permissions on the VCS configuration file");
        $msg->left;
        if ($ret) {
            Msg::right_failed;
            Msg::prtc;
            $msg = Msg::new(" Changing permissions on the VCS configuration file failed") if (Obj::webui()); 
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            return 1;
        } else {
            Msg::right_done;
        }

        if ($oncfs) {
            if ($enable_sep_filesys == 0) {
                $ret = $prod->set_up_fs($cfsmntpt, $dgname, $volname, $enable_sep_filesys);
                $msg = Msg::new("Setting up the file system");
                $msg->left;
                if ($ret) {
                    Msg::right_failed;
                    Msg::prtc;
                    $msg = Msg::new(" Setting up the file system failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    Msg::right_done;
                }
            } elsif ($enable_sep_filesys == 1) {
                $ret = $prod->set_up_fs($ocrmount, $dgname, $ocrvolname, $enable_sep_filesys, 0);
                $msg = Msg::new("Setting up the OCR file system");
                $msg->left;
                if ($ret) {
                    Msg::right_failed;
                    Msg::prtc;
                    $msg = Msg::new(" Setting up the OCR file system failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    Msg::right_done;
                }
                $ret = $prod->set_up_fs($votemount, $dgname, $votevolname, $enable_sep_filesys, 1);
                $msg = Msg::new("Setting up the Vote file system");
                $msg->left;
                if ($ret) {
                    Msg::right_failed;
                    Msg::prtc;
                    $msg = Msg::new(" Setting up the file system failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    Msg::right_done;
                }
            }
            if ($enable_sep_filesys == 0) {
                $ret = $prod->set_up_vols($dgname, $volname);
                $msg = Msg::new("Setting up the volumes");
                $msg->left;
                if ($ret) {
                    Msg::right_failed;
                    Msg::prtc;
                    $msg = Msg::new(" Setting up the volumes failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    Msg::right_done;
                }

                $ret = $prod->link_parent_child(1, $dgname, $enable_sep_filesys);
                $msg = Msg::new("Linking the parent and child");
                $msg->left;
                if ($ret) {
                    Msg::right_failed;
                    Msg::prtc;
                    $msg = Msg::new(" Linking the parent and child failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    Msg::right_done;
                }

                $ret = $prod->begin_enabling_system(1, $dgname, $enable_sep_filesys);
                $msg = Msg::new("Beginning enabling the system");
                $msg->left;
                if ($ret) {
                    Msg::right_failed;
                    Msg::prtc;
                    $msg = Msg::new("Beginning enabling the system failed") if (Obj::webui()); 
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    return 1;
                } else {
                    Msg::right_done;
                }
            }
        } 
	if ($onraw || ($enable_sep_filesys == 1)) {
            $ret = $prod->set_up_vols($dgname, $ocrvolname);
            $msg = Msg::new("Setting up the OCR volume");
            $msg->left;
            if ($ret) {
                Msg::right_failed;
                Msg::prtc;
                $msg = Msg::new(" Setting up the OCR volume failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                Msg::right_done;
            }

            $ret = $prod->set_up_vols($dgname, $votevolname);
            $msg = Msg::new("Setting up the Vote volume");
            $msg->left;
            if ($ret) {
                Msg::right_failed;
                Msg::prtc;
                $msg = Msg::new(" Setting up the Vote volume failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                Msg::right_done;
            }

            $ret = $prod->link_parent_child(0, $dgname, $enable_sep_filesys)if ($onraw);
            if ($enable_sep_filesys == 1) {
                $ret = $prod->link_parent_child(1, $dgname, $enable_sep_filesys);
            }
            $msg = Msg::new("Linking the parent and child");
            $msg->left;
            if ($ret) {
                Msg::right_failed;
                Msg::prtc;
                $msg = Msg::new("Linking the parent and child failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                Msg::right_done;
            }

            $ret = $prod->begin_enabling_system(0, $dgname, $enable_sep_filesys) if ($onraw);
            if ($enable_sep_filesys == 1) {
                $ret = $prod->begin_enabling_system(1, $dgname, $enable_sep_filesys);
            }
            $msg = Msg::new("Beginning enabling the system");
            $msg->left;
            if ($ret) {
                Msg::right_failed;
                Msg::prtc;
                $msg = Msg::new("Beginning enabling the system failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                Msg::right_done;
            }
        }

    # Make the CVMVolDg resource online
        $res = $prod->{cvmvoldg_res_name}."_$dgname";
        for my $sys (@{CPIC::get('systems')}) {
            $ret = $prod->make_online_system($res, $sys);
            $msg = Msg::new("Making CVMVolDg resource '$res' online on $sys->{sys}");
            $msg->left;
            if ($ret) {
                Msg::right_failed;
                Msg::prtc;
                $msg = Msg::new("Making CVMVolDg resource '$res' online on $sys->{sys} failed") if (Obj::webui()); 
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                Msg::right_done;
            }
        }
        Msg::prtc;
        if (Obj::webui())
        {
            $msg = Msg::new("Creation of OCR Vote storage was successful ") ; 
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        }
        return;
}

sub make_online_system {
    my ($prod, $res, $sys) = @_;
    my $vcs = $prod->prod('VCS60');
    my $ret = 0;
    my $out;
    my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});

    # Before onlining Probe the resource
    $out = $sys->cmd("$vcs->{bindir}/hares -wait $res Probed 1 -sys $sysname -time 30");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());

    $out = $sys->cmd("$vcs->{bindir}/hares -online $res -sys $sysname");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());

    return $ret;
}

sub verify_online {
    my ($prod, $sys, $oncfs, $dgname, $volname) = @_;
    my $vcs = $prod->prod('VCS60');
    my $ret = 0;
    my $ou;
    my $cvmresname = $prod->{cvmvoldg_res_name}."_$dgname";
    my $cfsresname = $prod->{cfsmnt_res_name}."_$dgname";
    my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});

    $ou = $sys->cmd("$vcs->{bindir}/hares -state $cvmresname -sys $sysname");
    $ret = ($ret || 1) if ($ou !~ /ONLINE/m);
    if ($oncfs) {
        $ou = $sys->cmd("$vcs->{bindir}/hares -state $cfsresname -sys $sysname");
        $ret = ($ret || 1) if ($ou !~ /ONLINE/m);
    }
    return $ret;
}

# Ignoring 'VCS WARNING' for now
sub begin_enabling_system {
    my ($prod, $oncfs, $dgname, $enable_sep_filesys) = @_;
    my $vcs = $prod->prod('VCS60');
    my ($out, $ret);
    my $cvmresname = $prod->{cvmvoldg_res_name}."_$dgname";
    my $cfsresname = $prod->{cfsmnt_res_name}."_$dgname";
    my $cfsvoteresname = $prod->{cfsvotemnt_res_name}."_$dgname";
    my $cfsocrresname = $prod->{cfsocrmnt_res_name}."_$dgname";

    # Begin enabling the system
    $ret = 0;
    $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cvmresname Enabled 1");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
    if ($oncfs) {
        if ($enable_sep_filesys == 0) {        
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsresname Enabled 1");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        } elsif ($enable_sep_filesys == 1) {
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsvoteresname Enabled 1");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsocrresname Enabled 1");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        }
    }
    $out = EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());

    return $ret;

}

# Ignoring 'VCS WARNING' for now
sub link_parent_child {
    my ($prod, $oncfs, $dgname, $enable_sep_filesys) = @_;
    my $vcs = $prod->prod('VCS60');
    my ($out, $ret);
    my $cvmresname = $prod->{cvmvoldg_res_name}."_$dgname";
    my $cfsresname = $prod->{cfsmnt_res_name}."_$dgname";
    my $cfsvoteresname = $prod->{cfsvotemnt_res_name}."_$dgname";
    my $cfsocrresname = $prod->{cfsocrmnt_res_name}."_$dgname";

    # Link parent and child
    $ret = 0;
    if ($oncfs) {
        if ($enable_sep_filesys == 0) {        
            $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cfsresname $cvmresname");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cfsresname vxfsckd");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        } elsif ($enable_sep_filesys == 1) {
            $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cfsvoteresname $cvmresname");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cfsvoteresname vxfsckd");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cfsocrresname $cvmresname");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cfsocrresname vxfsckd");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        } 
    }
    $out = EDR::cmd_local("$vcs->{bindir}/hares -link $cvmresname cvm_clus");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());

    return $ret;
}

# Ignoring 'VCS WARNING' for now
sub change_vcs_config_perm {
    my $prod = shift;
    my $vcs = $prod->prod('VCS60');
    my $ret;

    $ret = EDR::cmd_local("$vcs->{bindir}/haconf -makerw");

    return 0 if ($ret =~ /Cluster already writable/m);
    return 1 if (EDR::cmdexit());
    return 0;
}

# Ignoring 'VCS WARNING' for now
sub set_up_vols {
    my ($prod, $dgname, $volname) = @_;
    my $vcs = $prod->prod('VCS60');
    my ($msg, $ret, $out);
    my $cvmresname = $prod->{cvmvoldg_res_name}."_$dgname";

    # Set up the volumes
    $ret = 0;
    $out = EDR::cmd_local("$vcs->{bindir}/hares -add $cvmresname CVMVolDg cvm");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
    $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cvmresname CVMDiskGroup $dgname");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
    $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cvmresname CVMVolume -add $volname");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
    $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cvmresname CVMActivation sw");
    $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());

    return $ret;
}

# Ignoring 'VCS WARNING' for now
sub set_up_fs {
    my ($prod, $cfsmntpt, $dgname, $volname, $enable_sep_filesys, $ocr) = @_;
    my $vcs = $prod->prod('VCS60');
    my ($out, $ret);
    my $cfsresname = $prod->{cfsmnt_res_name}."_$dgname";
    my $cfsvoteresname = $prod->{cfsvotemnt_res_name}."_$dgname";
    my $cfsocrresname = $prod->{cfsocrmnt_res_name}."_$dgname";

    my $syslist = '';
    for my $sys (@{CPIC::get('systems')}) {
        $syslist = "$syslist $sys->{sys}";
    }

    # Set up the file system
    $ret = 0;
    if ($enable_sep_filesys == 0) {        
        $out = EDR::cmd_local("$vcs->{bindir}/hares -add $cfsresname CFSMount cvm");
        $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsresname Critical 0");
        $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsresname MountPoint $cfsmntpt");
        $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsresname BlockDevice /dev/vx/dsk/${dgname}/${volname}");
        $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsresname MountOpt mincache=direct");
        $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsresname NodeList $syslist");
        $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
    } elsif ($enable_sep_filesys == 1) {
        if ($ocr == 1) {
            $out = EDR::cmd_local("$vcs->{bindir}/hares -add $cfsvoteresname CFSMount cvm");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsvoteresname Critical 0");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsvoteresname MountPoint $cfsmntpt");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsvoteresname BlockDevice /dev/vx/dsk/${dgname}/${volname}");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsvoteresname MountOpt mincache=direct");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsvoteresname NodeList $syslist");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        } elsif ($ocr == 0) {
            $out = EDR::cmd_local("$vcs->{bindir}/hares -add $cfsocrresname CFSMount cvm");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsocrresname Critical 0");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsocrresname MountPoint $cfsmntpt");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsocrresname BlockDevice /dev/vx/dsk/${dgname}/${volname}");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsocrresname MountOpt mincache=direct");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
            $out = EDR::cmd_local("$vcs->{bindir}/hares -modify $cfsocrresname NodeList $syslist");
            $ret = $ret || (($out =~ /VCS WARNING/m) ? 0 : EDR::cmdexit());
        }
    } 

    return $ret;
}

# Validate volume name and size
# Return 0 means things are okay
# Return 1 means volume name already exists
#     or invalid diskgroup specified
# Return 2 means volume size specified cannot be accommodated
# Return 3 means unfathomable error
sub validate_vol {
    my ($prod, $volname, $volsize, $unavailsize, $dgname, $master, $enable_mirroring) = @_;
    my ($msg, $status, $ret, $temp, $availsize);
    my $web = Obj::web();
    $status = 0;

    # Check if the volume name is non-existent, if so check size available
    $ret = $master->cmd("_cmd_vxprint -g $dgname $volname");
    if (!EDR::cmdexit()) {
        $msg = Msg::new("(Volume with the name $volname already exists)");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    } elsif ($ret =~ /Record $volname not found/m) { # What's the EDR::cmdexit() here, 11 or 2816?
        $ret = $master->cmd("_cmd_vxassist -g $dgname maxsize layout=mirror") if ($enable_mirroring == 1);
        $ret = $master->cmd("_cmd_vxassist -g $dgname maxsize ") if ($enable_mirroring == 0);
        if (EDR::cmdexit()) {
            if ($ret =~ /"Diskgroup $dgname not found"/m) {
                $msg = Msg::new("(Diskgroup $dgname doesn't seem to exist anymore)");
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            } else {
                $msg = Msg::new("Inconsistency error with 'vxassist' command on $master->{sys}. Exiting validating volume.");
                $msg->log;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 3;
            }
        } else {
# Do the size check here
            ($temp, $temp, $temp, $temp, $availsize) = split(/\s+/m, $ret);
            $availsize =~ s/\D+//mg;
            $msg = Msg::new("Availavle volume size: $availsize MB");
            $msg->log;
            if (((0+$availsize) - (0+$unavailsize)) >= (0+$volsize)) {
                $msg = Msg::new("Volume with size $volsize MB can be successfully created");
                $msg->log;
                return 0;
            } else {
                $msg = Msg::new("(Volume with the size $volsize MB cannot be successfully created due to insufficient space)");
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 2;
            }
        }
    } else {
        $msg = Msg::new("Some error with 'vxprint' command on $master->{sys}. Exiting validating volume.");
        $msg->log;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 2;
    }
}

# Validate name and existence
# Return 0 if DG name is okay to be used
# Return 1 if DG already exists
# Return 2 if some unknown error
sub validate_dgname {
    my ($prod, $dgname, $master) = @_;
    my ($msg, $ret,$retval);
    $ret = $master->cmd("_cmd_vxdg list $dgname");
    my $web = Obj::web();
    $retval=EDR::cmdexit();
    if ($retval==0) {
        $msg = Msg::new("Disk group with the name '$dgname' already exists");
        $msg->print;
        return 1;
    } elsif ($retval==11) {
        $ret = $master->cmd("_cmd_vxdisk -o alldgs list | _cmd_grep '($dgname)'");
        if (EDR::cmdexit()) {
            return 0;
        } else {
            $msg = Msg::new("Disk group with the name '$dgname' already exists on some other node of the cluster or is deported.");
            $msg->print;
            if (Obj::webui())
            {
                $msg = Msg::new("Disk group with the name '$dgname' already exists on some node of the cluster or is deported. Input again");
                $web->web_script_form("alert", $msg->{msg}) ;
            }
            return 2;
        }

    } else {
        $msg = Msg::new("Some error with 'vxdg' command on $master->{sys}. Exiting.");
        $msg->log;
        if (Obj::webui())
        {
            $msg = Msg::new("Some error with 'vxdg' command on $master->{sys}. Input again");
            $web->web_script_form("alert", $msg->{msg}) ;
        }
        return 2;
    }
}

sub validate_display {
    my ($prod,$display) = @_;
    my $sys = ${CPIC::get('systems')}[0];
    if ($sys->exists("/etc/redhat-release")) {
        $prod->{xdpyinfo_path} = '/usr/bin/xdpyinfo';
    } elsif ($sys->exists("/etc/SuSE-release")) {
        $prod->{xdpyinfo_path} = '/usr/X11R6/bin/xdpyinfo';
    }

    if ($sys->exists("/usr/openwin/bin/xdpyinfo")) {
        $prod->{xdpyinfo_path} = '/usr/openwin/bin/xdpyinfo';
    } elsif ($sys->exists("/usr/bin/X11/xdpyinfo")) {
        $prod->{xdpyinfo_path} = '/usr/bin/X11/xdpyinfo';
    }

    $sys->cmd("$prod->{xdpyinfo_path} -display $display");
    if (EDR::cmdexit()) {
        return 1;
    }
    return 0;
}

sub config_privnic {
    my $prod = shift;
    my $cfg = Obj::cfg();
    my $clusnodes = ();
    my $newnodes = ();

    return 0 if (Cfg::opt('responsefile') && $cfg->{config_privnic} == 0);
    $cfg->{config_privnic} = 1;

    $prod->task_title('config_privnic');

    return $prod->config_privnic_common(0, CPIC::get('systems'), $clusnodes, $newnodes);
}

sub config_privnic_common {
    my ($prod, $isaddnode, $allnodes_ref, $clusnodes_ref, $newnodes_ref)  = @_;
    my ($priv_ip, $priv_mask);
    my ($sys, $sys1, $key, $inf, $nics, $nics_str);
    my ($ret, $err, $msg, $question, $ayn, $done, $help, $backopt);
    my ($res_name, $priv_alias, $add_ip_addr, $is_ipv4);
    my ($nodes_ref, $priv_rsrc);
    my %systems;
    my $vcs = $prod->prod('VCS60');
    my $cfg = Obj::cfg();
    my $web = Obj::web();
   
    $err = 0;
    $help = '';
    $backopt = 1;
    $add_ip_addr = 0;
    my $update_inf_prio = 0;

    if (!$isaddnode) {
        $msg = Msg::new("This step will configure private IP addresses using PrivNIC resource of VCS");
        $msg->print;
        $msg = Msg::new("* All LLT links will be used for PrivNIC configuration");
        $msg->print;
        $msg = Msg::new("* Ensure that the same NICs are used for private interconnect on each node of your cluster");
        $msg->print;
    } else {
        $msg = Msg::new("This step will re-configure the existing PrivNIC resources for the new nodes being added");
        $msg->print;
        $msg = Msg::new("* All LLT links will be used for PrivNIC configuration on new nodes");
        $msg->print;
        $msg = Msg::new("* Ensure that the same NICs are used for private interconnect on each old and new node of your cluster");
        $msg->print;
    }

    $msg = Msg::new("* All IP addresses must be of same type, either all IPv4 or all IPv6");
    $msg->print;
    if ($prod->{hosts_file} eq '/etc/hosts') {
        $msg = Msg::new("* The private IP addresses must be added to /etc/hosts on all nodes before installing Oracle Clusterware. If you choose the Installer to add IP addresses in /etc/hosts then only those IP addresses which do not already exist in this file on any node will be added");
        $msg->print;
    } else {
        $msg = Msg::new("* The private IP addresses must be added to /etc/hosts or $prod->{hosts_file} file on all nodes before installing Oracle Clusterware (IPv4 addresses in /etc/hosts and IPv6 addresses in $prod->{hosts_file}). If you choose the Installer to add IP addresses in /etc/hosts and $prod->{hosts_file} files then only those IP addresses which do not already exist in these files on any node will be added");
        $msg->print;
    }

    $msg = Msg::new("* Oracle UDP IPC private IP addresses must be added to the oracle init file as cluster_interconnect parameter");
    $msg->print;
    $msg = Msg::new("* All IP addresses must be in the same subnet. Otherwise, Oracle Clusterware/Grid Infrastructure/Oracle Database UDP IPC will not be able to communicate properly across the nodes");
    $msg->bold;

    Msg::prtc();
    Msg::n();


    # Check if VCS is running.
    if (!$prod->is_vcs_up($allnodes_ref)) {
        $msg = Msg::new("\nVCS Engine is down on one or more nodes. Cannot proceed with PrivNIC Configuration.\nStart VCS Engine on all the nodes and then try again");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $nics = $prod->get_nics($allnodes_ref);
    if ($#$nics < 0) {
        return 1;
    }

    if (!$isaddnode) {
        $ret = $prod->check_resource('PrivNIC');
        if ($ret) {
            return 1;
        }
    } else {
        $msg = Msg::new("Discovering the PrivNIC resources which need reconfiguration");
        $msg->left;
        $sys = @{$newnodes_ref}[0];
        $priv_rsrc = $prod->addnode_check_resource('PrivNIC', $sys);
        if ($#$priv_rsrc < 0) {
            $msg = Msg::new("doesn't exist");
            $msg = Msg::new("PrivNIC resource doesn't exist") if (Obj::webui());
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            $msg->right;
            Msg::prtc;
            return 1;
        } else {
            my $str = join(' ', @$priv_rsrc);
            $msg = Msg::new("discovered $str");
            $msg = Msg::new("PrivNIC resource $str discovered ") if (Obj::webui());
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            $msg->right;
        }
    }

    for ($done = 0;  ! $done; ) {

        Msg::n();

WEB_ASK_PRIV_RESOURCE:
        while (1) {
            if ($prod->{priv_res_name} eq '') {
                if (!$isaddnode) {
                    $prod->{priv_res_name} = 'ora_priv';
                } else {
                    $prod->{priv_res_name} = @$priv_rsrc[0];
                }
            }

            if (Cfg::opt('responsefile')) {
                $res_name = $cfg->{privnic_resname};
            } else {
		if (Obj::webui()){
			$prod->{config__priv} = 1;
			$web->web_script_form("config_privnic_res_name",$prod);
			$prod->{config__priv} = 0;
			if ($web->param("back") eq "back") {
				return 0;
			}
			$res_name = $cfg->{privnic_resname};
		}else{
	                $question = Msg::new("Enter the PrivNIC resource name:");
        	        $res_name = $question->ask($prod->{priv_res_name}, $help, $backopt);
		}
            }
            return 0 if (EDR::getmsgkey($res_name,'back'));

            if (!$isaddnode) {
                $ret = $prod->validate_resource($res_name);
                if ($ret) {
                    return 1 if (Cfg::opt('responsefile'));
                    next;
                }

                EDR::cmd_local("$vcs->{bindir}/hares -display $res_name");
                if (EDR::cmdexit() == 0) {
                    $msg = Msg::new("$res_name already exists. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
		    if (Obj::webui()) {
			$web->web_script_form("alert",$msg->{msg});
		    }
                    next;
                }
            } else {
                my ($tmp_rsrc, $tmp_found);
                $tmp_found = 0;
                for my $tmp_rsrc (@$priv_rsrc) {
                    if ($tmp_rsrc eq $res_name) {
                        $tmp_found = 1;
                    }
                }
                if (!$tmp_found) {
                    $msg = Msg::new("$res_name should be from the above discovered list. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
		    if (Obj::webui()) {
                        $web->web_script_form("alert",$msg->{msg});
                    }
                    next;
                }
            }

            $prod->{priv_res_name} = $res_name;
            $cfg->{privnic_resname} = $res_name if (!Cfg::opt('responsefile'));
            last;
        }

        %systems = ();

        $nics_str = join(' ',@$nics);
        if ($nics_str ne $prod->{priv_nics}) {
            $prod->{priv_data} = {};
            $prod->{priv_nics} = $nics_str;
        }

        my ($inf_input);
        my @interface = @$nics;

        if (!Cfg::opt('responsefile') && (!$isaddnode)) {
            my $tmp_str='';
            my $prio = 0;
            my $seperator='';
            for my $item (@$nics) {
                $tmp_str = "$tmp_str $item=$prio";
                $prio++;
            }
            $update_inf_prio = 0;
		if (Obj::webui()){
			$msg = Msg::new("PrivNIC agent requires you to set the priority of the network interfaces. Based on this priority, the agent chooses the appropriate interface during failover.\n Current PrivNIC interface priority order is:$tmp_str. \n\nDo you want to update the priority of the PrivNIC interfaces?");
			$ayn = $msg->aynn;
		}else{
       			$msg = Msg::new("PrivNIC agent requires you to set the priority of the network interfaces. Based on this priority, the agent chooses the appropriate interface during failover.");
                       	$msg->print;
                       	$msg = Msg::new("Current PrivNIC interface priority order is:$tmp_str");
                       	$msg->print;
                       	$msg = Msg::new("Do you want to update the priority of the PrivNIC interfaces?");
                       	$ayn = $msg->aynn;
		}
            if ($ayn eq 'y' || $ayn eq 'Y') {
                $update_inf_prio = 1;
WEB_ASK_INF_PRIO:
                while(1) {
                    my $wrong_input = 0;
                    my $seperator='';

			if (Obj::webui()){
				$prod->{config__priv} = 2;
				$web->web_script_form("config_privnic_inf_prio",$nics_str);
				$prod->{config__priv} = 0;
	       			if ($web->param("back") eq "back") {
                                    goto WEB_ASK_PRIV_RESOURCE;
		                }	
				$inf_input = $cfg->{privnic_interface_priority};
			} else {
				$question = Msg::new("Enter the interface name in the decreasing priority order separated by a space:");
				$inf_input = $question->ask($nics_str, $help, $backopt);
				return 0 if (EDR::getmsgkey($inf_input,'back'));
			}
                    @interface = split(/\s+/m,$inf_input);
                    $tmp_str = '';
                    for my $item (@interface) {
                        if(EDR::cmd_local("echo $nics_str | _cmd_grep -w $item") eq '') {
                            $tmp_str = "$tmp_str$seperator $item";
                            $seperator=',';
                            $wrong_input++;
                        }
                    }
                    if($wrong_input > 0){
                        if($wrong_input == 1) {
                            $msg = Msg::new("Error:$tmp_str is not an LLT interface. Input again");
                        }else{
                            $msg = Msg::new("Error:$tmp_str are not LLT interfaces. Input again");
                        }
                        $msg->print;
			if (Obj::webui()) {
				$web->web_script_form("alert",$msg->{msg});
			}
                        next;
                    }
                    $tmp_str = '';
                    $seperator='';
                    for my $item (@$nics) {
                        if(EDR::cmd_local("echo $inf_input | _cmd_grep -w $item") eq '') {
                            $tmp_str = "$tmp_str$seperator $item";
                            $seperator=',';
                            $wrong_input++;
                        }
                    }
                    if($wrong_input > 0){
                        $msg = Msg::new("Error: For maximum failover options, all available LLT links must be used for PrivNIC configuration. Specify the names of the remaining LLT interfaces:<$tmp_str>.");
                        $msg->print;
			if (Obj::webui()) {
				$web->web_script_form("alert",$msg->{msg});
			}
                        next;
                    }
		    if(($#interface + 1) != ($#$nics + 1)) {
			$msg = Msg::new("An interface has been specified more than once. Specify each interface only once");
			$msg->print;
			if (Obj::webui()){
				$web->web_script_form("alert",$msg->{msg});
			}
			next;
		    }
                    last;
                }
            }
            my $inf_str = join(' ',@interface);
            $cfg->{privnic_interface_priority} = $inf_str;
        }else {
            my $inf_str = $cfg->{privnic_interface_priority};
            if($inf_str ne ''){
                @interface = split(/\s/m,$inf_str);
            }
        }

        for my $sys (@{$allnodes_ref}) {
            @{$systems{$sys->{sys}}{'inf'}} = @interface;
        } # for


        if (!$isaddnode) {
            for my $sys (@{$allnodes_ref}) {
                $systems{$sys->{sys}}{'ip'} = '';
                $systems{$sys->{sys}}{'alias'} = '';
            }
        } else {
            $ret = $prod->addnode_populate_privrsrc_info($prod->{priv_res_name},
                                                    $clusnodes_ref, \%systems);
            if ($ret) {
                return 1;
            }

            for my $sys (@{$newnodes_ref}) {
                $systems{$sys->{sys}}{'ip'} = '';
                $systems{$sys->{sys}}{'alias'} = '';
            }
        }

        if (Cfg::opt('responsefile')) {
            $add_ip_addr = $cfg->{nic_add_ip_to_files};
            goto DNA_ADDIP;
        }
        $add_ip_addr = 0;
        if ($prod->{hosts_file} eq '/etc/hosts') {
            $msg = Msg::new("Do you want the Installer to add IP addresses in /etc/hosts file?");
        } else {
            $msg = Msg::new("Do you want the Installer to add IP addresses in /etc/hosts and $prod->{hosts_file} files?");
        }
        $ayn = $msg->ayny;
        if ($ayn eq 'y' || $ayn eq 'Y') {
            $add_ip_addr = 1;
        }
        $cfg->{nic_add_ip_to_files} = $add_ip_addr;
        Msg::n();

DNA_ADDIP:
        $is_ipv4 = 1;
        my $ip_cnt = 0;  #Total ip counts
        my $ip_sys_cnt = 0;  #Total ips for a system
        my $def_ip = '';
        my $def_alias = '';
        if (!$isaddnode) {
            $nodes_ref = $allnodes_ref;
        } else {
            $prod->task_title('config_privnic');
            if (Obj::webui())
            {
                my $mesg="";
                $msg = Msg::new("Existing configuration for the PrivNIC resource:\\n");
                $mesg .=$msg->{msg};
                $msg = Msg::new("Resource name: $prod->{priv_res_name}\\n");
                $mesg .=$msg->{msg};
                for my $sys (@{$clusnodes_ref}) {
                    if ($ip_cnt == 0) {
                        my @alias_parts = split(/-/m, $systems{$sys->{sys}}{'alias'});
                        my $alias_parts_cnt = @alias_parts;
                        if ($alias_parts_cnt > 1) {
                            $prod->{ip_alias_name} = "-$alias_parts[1]";
                        }
                        $is_ipv4 = EDRu::ip_is_ipv4($systems{$sys->{sys}}{'ip'});
                    }
                    $ip_cnt++;

                    $msg = Msg::new("System: $sys->{sys}\\n");
                    $mesg .=$msg->{msg};
                    my $infs = join(' ', @{$systems{$sys->{sys}}{'inf'}});
                    $msg = Msg::new("\tPrivate Interfaces: $infs\\n");
                    $mesg .=$msg->{msg};
                    $msg = Msg::new("\tPrivate IP address: $systems{$sys->{sys}}{'ip'}\\n");
                    $mesg .=$msg->{msg};
                    $msg = Msg::new("\tPrivate IP address: $systems{$sys->{sys}}{'ip'}\\n");
                    $mesg .=$msg->{msg};
                    $msg = Msg::new("\tAlias for above IP: $systems{$sys->{sys}}{'alias'}\\n");
                    $mesg .=$msg->{msg};
                }
                $msg = Msg::new("\\nIs this information correct?");
                $mesg .=$msg->{msg};
                $msg = Msg::new($mesg);
                $ayn = $msg->ayny;


            } else {
                $msg = Msg::new("Existing configuration for the PrivNIC resource:");
                $msg->bold;
                $msg = Msg::new("Resource name: $prod->{priv_res_name}");
                $msg->print;

                for my $sys (@{$clusnodes_ref}) {
                    if ($ip_cnt == 0) {
                        my @alias_parts = split(/-/m, $systems{$sys->{sys}}{'alias'});
                        my $alias_parts_cnt = @alias_parts;
                        if ($alias_parts_cnt > 1) {
                            $prod->{ip_alias_name} = "-$alias_parts[1]";
                        }
                        $is_ipv4 = EDRu::ip_is_ipv4($systems{$sys->{sys}}{'ip'});
                    }
                    $ip_cnt++;

                    $msg = Msg::new("System: $sys->{sys}");
                    $msg->print;
                    my $infs = join(' ', @{$systems{$sys->{sys}}{'inf'}});
                    $msg = Msg::new("\tPrivate Interfaces: $infs");
                    $msg->print;
                    $msg = Msg::new("\tPrivate IP address: $systems{$sys->{sys}}{'ip'}");
                    $msg->print;
                    $msg = Msg::new("\tAlias for above IP: $systems{$sys->{sys}}{'alias'}");
                    $msg->print;
                }

                Msg::n();
                $msg = Msg::new("Is this information correct?");
                $ayn = $msg->ayny;
            }
            if ($ayn eq 'N') {
                return 1;
            }
            Msg::n();
            $nodes_ref = $newnodes_ref;
        }

        my $priv_sys_index = -1;
        my $sys_i = 0;
        #for my $sys (@{$nodes_ref}) {
        for ($sys_i = 0; $sys_i < (@{$nodes_ref}); $sys_i++ ) {
            $ip_sys_cnt = 0;
WEB_ASK_PRIV_AGAIN:
            my $sys = @{$nodes_ref}[$sys_i];
	    if (Obj::webui()) {
                if (exists($prod->{priv_data}{$sys->{sys}}{'ip'})) {
                    $def_ip = $prod->{priv_data}{$sys->{sys}}{'ip'};
                } else {
                    $def_ip = '';
                }
                $prod->ask_privnic_ip($sys, $def_ip);

                if (exists($prod->{priv_data}{$sys->{sys}}{'alias'})) {
                    $def_alias = $prod->{priv_data}{$sys->{sys}}{'alias'};
                } else {
                    $def_alias = '';
                }
                $prod->ask_privnic_alias($sys->{sys}, $def_alias);

		$prod->{config__priv} = 3;
            	$web->web_script_form("config_privnic",$sys,$add_ip_addr);
		$prod->{config__priv} = 0;
	            if ($web->param("back") eq "back") {
                       if ($priv_sys_index == -1 ) {
                           if ($update_inf_prio == 1) {
                               goto WEB_ASK_INF_PRIO;
                           } else {
                               goto WEB_ASK_PRIV_RESOURCE;
                           }
                       } else {
                           $sys = @{$nodes_ref}[$priv_sys_index];
		           $sys_i = $priv_sys_index;
                           $priv_sys_index--;
                           $systems{$sys->{sys}}{'ip'} = '';
                           if ($add_ip_addr) {
                               $systems{$sys->{sys}}{'alias'} = '';
                           }
                           goto WEB_ASK_PRIV_AGAIN;
                       } 
	            }
        	    $priv_ip = $cfg->{$sys->{sys}}->{privnicip};
	            $priv_alias = $cfg->{$sys->{sys}}->{hostname_for_ip};
            }
            $priv_sys_index++;

            while (1) {
                if (exists($prod->{priv_data}{$sys->{sys}}{'ip'})) {
                    $def_ip = $prod->{priv_data}{$sys->{sys}}{'ip'};
                } else {
                    $def_ip = '';
                }
		
		if (!Obj::webui()) {
               		$priv_ip = $prod->ask_privnic_ip($sys, $def_ip);
		        if (EDR::getmsgkey($priv_ip,'back')) {
        		       	return 0;
                	}
		}

                # Using the check_ips sub to avoid
                # writing duplicate code.
                my @priv_ips = ($priv_ip);
                $ret = $prod->check_ips($sys, '', $ip_cnt, $is_ipv4, $add_ip_addr, \@priv_ips, \%systems, 'PrivNIC', $allnodes_ref);
                if (Cfg::opt('responsefile')) {
                    return 1 if ($ret);
                } else {
		    if (Obj::webui()){
                        goto WEB_ASK_PRIV_AGAIN if ($ret);
                    }else {
	                next if ($ret);
		    }
                }

                if ($ip_cnt == 0) {
                    $is_ipv4 = EDRu::ip_is_ipv4($priv_ip);
                }

                $prod->{priv_data}{$sys->{sys}}{'ip'} = $priv_ip;
                last;
            }

            while ($add_ip_addr) {
		if (exists($prod->{priv_data}{$sys->{sys}}{'alias'})) {
                        $def_alias = $prod->{priv_data}{$sys->{sys}}{'alias'};
                } else {
                        $def_alias = '';
                }

		if (!Obj::webui()){
 	               $priv_alias = $prod->ask_privnic_alias($sys->{sys}, $def_alias);
        	        if (EDR::getmsgkey($priv_alias,'back')) {
                	    return 0;
	                }
		}

                my @priv_aliases = ($priv_alias);
                $ret = $prod->check_aliases($sys, '', \@priv_aliases, \%systems, 'PrivNIC', $allnodes_ref);
                if (Cfg::opt('responsefile')) {
                    return 1 if ($ret);
                } else {
		    if (Obj::webui()){
			goto WEB_ASK_PRIV_AGAIN if ($ret);	
		    }else{
                    	next if ($ret);
		    }
                }

                $prod->{priv_data}{$sys->{sys}}{'alias'} = $priv_alias;
                if ($ip_sys_cnt == 0) {
                    if($priv_alias =~ /^$sys->{sys}/mx) {
                        $prod->{ip_alias_name} = substr $priv_alias, length($sys->{sys});
                    }
                }

                last;
            }

            $ip_sys_cnt++;
            $ip_cnt++;
            Msg::n();
        } # for

        if (!$isaddnode && $is_ipv4) {
            while (1) {
                $prod->{config__priv} = 4 if (Obj::webui());
                $priv_mask = $prod->ask_netmask();
                $prod->{config__priv} = 0 if (Obj::webui());
                if (Obj::webui()) {
                    if ($priv_mask eq 'back') {
                        $sys = @{$nodes_ref}[$priv_sys_index];
                        $sys_i = $priv_sys_index;
                        $priv_sys_index--;
                        $systems{$sys->{sys}}{'ip'} = '';
                        if ($add_ip_addr) {
                            $systems{$sys->{sys}}{'alias'} = '';
                        }
                        goto WEB_ASK_PRIV_AGAIN;
                    }
                }
                if (EDR::getmsgkey($priv_mask,'back')) {
                    return 0;
                }

                if (!EDRu::ip_is_ipv4($priv_mask)) {
                    $msg = Msg::new("The IPv4 Netmask is expected. Input again");
                    $msg->print;

                    return 1 if (Cfg::opt('responsefile'));

		    if (Obj::webui()) {
                	$web->web_script_form("alert",$msg->{msg});
        	    }
                    next;
                }

                $prod->{priv_mask} = $priv_mask;
                $cfg->{nic_netmask} = $priv_mask if(!Cfg::opt('responsefile'));
                last;
            }
        }

        $prod->task_title('config_privnic');

        $msg = Msg::new("Verify private IP configuration information:");
        $msg->bold;

        $msg = Msg::new("Resource name: $prod->{priv_res_name}");
        $msg->print;

	my $msg_str = "";
        for my $sys (@{$nodes_ref}) {
            $msg = Msg::new("System: $sys->{sys}");
            $msg->print;
            $msg_str .= "$msg->{msg}\n";
            my $infs = join(' ', @{$systems{$sys->{sys}}{'inf'}});
            $msg = Msg::new("\tPrivate Interfaces: $infs");
            $msg->print;
            $msg_str .= "$msg->{msg}\n";
            $msg = Msg::new("\tPrivate IP address: $systems{$sys->{sys}}{'ip'}");
            $msg->print;
            $msg_str .= "$msg->{msg}\n";
            if ($add_ip_addr) {
                $msg = Msg::new("\tAlias for above IP: $systems{$sys->{sys}}{'alias'}");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            }
        }

        if (!$isaddnode && $is_ipv4) {
            $msg = Msg::new("\n\tNetmask: $priv_mask");
            $msg->print;
            $msg_str .= "$msg->{msg}\n\n";
        }

        Msg::n();

        goto DNA_CONFIRMNET if (Cfg::opt('responsefile'));
	if (Obj::webui()) {	
		$msg = Msg::new("$msg_str \n\nIs this information correct?");
	}else {
	        $msg = Msg::new("Is this information correct?");
	}
        $ayn = $msg->ayny;
        if ($ayn eq 'N' || $ayn eq 'n') {
            Msg::n();
            next;
        }

DNA_CONFIRMNET:
        $done = 1;
    } # for

    $msg = Msg::new("Changing configuration to read-write mode");
    $msg->left;
    EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
    EDR::cmd_local("$vcs->{bindir}/haconf -makerw");
    if (EDR::cmdexit() != 0) {
        Msg::right_failed();
        Msg::prtc();
	if (Obj::webui()) {
		$err = 1;
		goto done;
	}
        return 1;
    }
    Msg::right_done();

    if (!$isaddnode) {
        $ret = $prod->add_resource($prod->{priv_res_name}, 'PrivNIC');
        if ($ret) {
            return 1;
        }
    }
    $msg = Msg::new("Updating resource configuration");
    $msg->left;
    for my $sys (@{$nodes_ref}) {
        my $ip = $systems{$sys->{sys}}{'ip'};
        my $pri = 0;
        my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
        for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
            EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{priv_res_name} Device -add $inf $pri -sys $sysname");
            if (EDR::cmdexit() != 0) {
                $err = 1;
                goto done;
            }

            EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{priv_res_name} Address $ip -sys $sysname");
            if (EDR::cmdexit() != 0) {
                $err = 1;
                goto done;
            }

            $pri++;

        } #for
    } #for

    if (!$isaddnode && $is_ipv4) {
        EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{priv_res_name} NetMask $priv_mask");
        if (EDR::cmdexit() != 0) {
            $err = 1;
            goto done;
        }
    }

    EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{priv_res_name} Enabled 1");
    if (EDR::cmdexit() != 0) {
        $err = 1;
        goto done;
    }

    EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
    Msg::right_done();
    $msg = Msg::new("PrivNIC configuration was successful");
    if (Obj::webui()) {
    	$web->web_script_form("alert",$msg->{msg});
    }


    if ($add_ip_addr) {
        my $hfile;
        if ($prod->{hosts_file} eq '/etc/hosts') {
            $hfile = '/etc/hosts';
        } else {
            if ($is_ipv4) {
                $hfile = '/etc/hosts';
            } else {
                $hfile = $prod->{hosts_file};
            }
        }

        if ($isaddnode) {
            $msg = Msg::new("Adding existing configuration in $hfile on new nodes:");
            $msg->print;
            $ret = $prod->save_priv_configuration($is_ipv4,
                           \%systems, $clusnodes_ref, $newnodes_ref);
            return 1 if ($ret);
        }

        $msg = Msg::new("Saving configuration in $hfile on all nodes:");
        $msg->print;

        if (!$isaddnode) {
            $ret = $prod->save_priv_configuration($is_ipv4,
                        \%systems, $allnodes_ref, $allnodes_ref);
        } else {
            $ret = $prod->save_priv_configuration($is_ipv4,
                        \%systems, $newnodes_ref, $allnodes_ref);
        }

        if ($ret) {
            return 1;
        }
    }
done:
    if ($err) {
        if (!$isaddnode) {
            EDR::cmd_local("$vcs->{bindir}/hares -delete $prod->{priv_res_name}");
        }
        EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
        Msg::right_failed();
        Msg::prtc();
	if (Obj::webui()) {
		$msg = Msg::new("PrivNIC configuration failed. Refer to the log file for details");
		$web->web_script_form("alert",$msg->{msg});
	}
    }

    #Reset the default entries for IP addresses and Aliases
    for my $sys (@{$allnodes_ref}) {
        $prod->{priv_data}{$sys->{sys}}{'ip'} = '';
        $prod->{priv_data}{$sys->{sys}}{'alias'} = '';
    }
    $prod->{priv_res_name} = '';
    $prod->{ip_alias_name} = '-priv';

    Msg::prtc();

    $nic_config_complete=0;
    return 0;
}

sub config_multiprivnic {
    my $prod = shift;
    my $cfg = Obj::cfg();
    my $clusnodes = ();
    my $newnodes = ();

    return 0 if (Cfg::opt('responsefile') && $cfg->{config_multiprivnic} == 0);
    $cfg->{config_multiprivnic} = 1;

    $prod->task_title('config_multiprivnic');

    return $prod->config_multiprivnic_common(0, CPIC::get('systems'), $clusnodes, $newnodes);
}

sub config_multiprivnic_common {
    my ($prod, $isaddnode, $allnodes_ref, $clusnodes_ref, $newnodes_ref)  = @_;
    my ($mpriv_ips_ref, @mpriv_ips, $mpriv_ip, $mpriv_mask);
    my ($sys, $sys1, $key, $inf, $nics, $nics_str, $ip, $ips);
    my ($ret, $err, $msg, $question, $ayn, $done, $help, $backopt);
    my ($res_name, $add_ip_addr, $is_ipv4);
    my ($mpriv_aliases_ref, @mpriv_aliases, @def_aliases, $num_aliases);
    my ($nodes_ref, $mpriv_rsrc);
    my %systems;
    my $vcs = $prod->prod('VCS60');
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $err = 0;
    $help = '';
    $backopt = 1;
    $add_ip_addr = 0;

    if (!$isaddnode) {
        $msg = Msg::new("This step will configure private IP addresses using MultiPrivNIC resource of VCS");
        $msg->print;
        $msg = Msg::new("* All LLT links will be used for MultiPrivNIC configuration");
        $msg->print;
        $msg = Msg::new("* Ensure that the same NICs are used for private interconnect on each node of your cluster");
        $msg->print;
    } else {
        $msg = Msg::new("This step will re-configure the existing MultiPrivNIC resources for the new nodes being added");
        $msg->print;
        $msg = Msg::new("* All LLT links will be used for MultiPrivNIC configuration on new nodes");
        $msg->print;
        $msg = Msg::new("* Ensure that the same NICs are used for private interconnect on each old and new node of your cluster");
        $msg->print;
    }

    $msg = Msg::new("* All IP addresses must be of same type, either all IPv4 or all IPv6");
    $msg->print;
    if ($prod->{hosts_file} eq '/etc/hosts') {
        $msg = Msg::new("* The private IP addresses must be added to /etc/hosts on all nodes before installing Oracle Clusterware. If you choose the Installer to add IP addresses in /etc/hosts then only those IP addresses which do not already exist in this file on any node will be added");
        $msg->print;
    } else {
        $msg = Msg::new("* The private IP addresses must be added to /etc/hosts or $prod->{hosts_file} file on all nodes before installing Oracle Clusterware (IPv4 addresses in /etc/hosts and IPv6 addresses in $prod->{hosts_file}). If you choose the Installer to add IP addresses in /etc/hosts and $prod->{hosts_file} files then only those IP addresses which do not already exist in these files on any node will be added");
        $msg->print;
    }

    $msg = Msg::new("* Oracle UDP IPC private IP addresses must be added to the oracle init file as cluster_interconnect parameter");
    $msg->print;
    $msg = Msg::new("* IP addresses used for a NIC on all nodes of your cluster must be in the same subnet, which must be different from the subnets for the IP addresses on other NICs. Otherwise, Oracle Clusterware/Grid Infrastructure/Oracle Database UDP IPC will not be able to communicate properly across the nodes");
    $msg->bold;

    Msg::prtc();

    Msg::n();

    # Check if VCS is running.
    if (!$prod->is_vcs_up($allnodes_ref)) {
        $msg = Msg::new("\nVCS Engine is down on one or more nodes. Cannot proceed with MultiPrivNIC Configuration.\nStart VCS Engine on all the nodes and then try again");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $nics = $prod->get_nics($allnodes_ref);
    if ($#$nics < 0) {
        return 1;
    }

    if (!$isaddnode) {
        $ret = $prod->check_resource('MultiPrivNIC');
        if ($ret) {
            return 1;
        }
    } else {
        $msg = Msg::new("Discovering the MultiPrivNIC resources which need reconfiguration");
        $msg->left;
        $sys = @{$newnodes_ref}[0];
        $mpriv_rsrc = $prod->addnode_check_resource('MultiPrivNIC', $sys);
        if ($#$mpriv_rsrc < 0) {
            $msg = Msg::new("doesn't exist");
            $msg->right;
            if (Obj::webui()){
                $msg = Msg::new("MultiPrivNIC resource doesn't exist");
                $web->web_script_form("alert",$msg->{msg});
            }
            Msg::prtc;
            return 1;
        } else {
            my $str = join(' ', @$mpriv_rsrc);
            $msg = Msg::new("discovered $str");
            if (Obj::webui()){
                $msg = Msg::new("MultiPrivNIC resource $str discovered");
                $web->web_script_form("alert",$msg->{msg});
            }
            $msg->right;
        }
    }


    for ($done = 0;  ! $done; ) {

        Msg::n();

WEB_ASK_MULTI_PRIV_RESOURCE:
        while (1) {
            if ($prod->{mpriv_res_name} eq '') {
                if (!$isaddnode) {
                    $prod->{mpriv_res_name} = 'multi_priv';
                } else {
                    $prod->{mpriv_res_name} = @$mpriv_rsrc[0];
                }
            }

            if (Cfg::opt('responsefile')) {
                $res_name = $cfg->{multiprivnic_resname};
            } else {
		if (Obj::webui()) {
			$prod->{config_multi_priv} = 1;
			$web->web_script_form("config_multi_privnic_res_name", $prod);
			$prod->{config_multi_priv} = 0;
			if ($web->param("back") eq "back") {
				return 0;
			}
			$res_name = $cfg->{multiprivnic_resname};
		} else {
	                $question = Msg::new("Enter the MultiPrivNIC resource name:");
        	        $res_name = $question->ask($prod->{mpriv_res_name}, $help, $backopt);
		}
            }
            return 0 if (EDR::getmsgkey($res_name,'back'));

            if (!$isaddnode) {
                $ret = $prod->validate_resource($res_name);
                if ($ret) {
                    return 1 if (Cfg::opt('responsefile'));
                    next;
                }

                EDR::cmd_local("$vcs->{bindir}/hares -display $res_name");
                if (EDR::cmdexit() == 0) {
                    $msg = Msg::new("$res_name already exists. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
		    if (Obj::webui()) {
			$web->web_script_form("alert",$msg->{msg});
		    }
                    next;
                }
            } else {
                my ($tmp_rsrc, $tmp_found);
                $tmp_found = 0;
                for my $tmp_rsrc (@$mpriv_rsrc) {
                    if ($tmp_rsrc eq $res_name) {
                        $tmp_found = 1;
                    }
                }
                if (!$tmp_found) {
                    $msg = Msg::new("$res_name should be from the above discovered list. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
		    if (Obj::webui()) {
			$web->web_script_form("alert",$msg->{msg});
		    }
                    next;
                }
            }

            $prod->{mpriv_res_name} = $res_name;
            $cfg->{multiprivnic_resname} = $res_name if (!Cfg::opt('responsefile'));
            last;
        }

        %systems = ();

        $nics_str = join(' ',@$nics);
        if ($nics_str ne $prod->{mpriv_nics}) {
            $prod->{mpriv_data} = {};
            $prod->{mpriv_nics} = $nics_str;
        }

        for my $sys (@{$allnodes_ref}) {
            @{$systems{$sys->{sys}}{'inf'}} = @$nics;
        } # for

        for my $sys (@{$allnodes_ref}) {
            for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
                @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
                @{$systems{$sys->{sys}}{'alias'}{$inf}} = ('');
            }
        }
        if ($isaddnode) {
            $ret = $prod->addnode_populate_mprivrsrc_info($prod->{mpriv_res_name},
                                  $clusnodes_ref, \%systems);
            if ($ret) {
                return 1;
            }

        }


        if (Cfg::opt('responsefile')) {
            $add_ip_addr = $cfg->{nic_add_ip_to_files};
            goto DNA_ADDIP;
        }
        $add_ip_addr = 0;
        if ($prod->{hosts_file} eq '/etc/hosts') {
            $msg = Msg::new("Do you want the Installer to add IP addresses in /etc/hosts file?");
        } else {
            $msg = Msg::new("Do you want the Installer to add IP addresses in /etc/hosts and $prod->{hosts_file} files?");
        }
        $ayn = $msg->ayny;
        if ($ayn eq 'y' || $ayn eq 'Y') {
            $add_ip_addr = 1;
        }

        $cfg->{nic_add_ip_to_files} = $add_ip_addr if (!Cfg::opt('responsefile'));
        Msg::n();

DNA_ADDIP:
        $is_ipv4 = 1;
        my $ip_cnt = 0;   #Total ip count
        my $ip_sys_cnt = 0;  #Total ips for a system
        my $inf_ip_cnt = 0;  #Total ips for an interface
        my @def_ips = ();
        if (!$isaddnode) {
             $nodes_ref = $allnodes_ref;
        } else {
            $prod->task_title('config_multiprivnic');
            if (Obj::webui()) {
                my $mesg="";
                $msg = Msg::new("Existing configuration for the MultiPrivNIC resource:\\n");
                $mesg .=$msg->{msg};
                $msg = Msg::new("Resource name: $prod->{mpriv_res_name}\\n");
                $mesg .=$msg->{msg};
                my $ipdone = 0;
                my $aliasdone = 0;
                for my $sys (@{$clusnodes_ref}) {
                    $msg = Msg::new("System: $sys->{sys}\\n");
                    $mesg .=$msg->{msg};
                    my $infs = join(' ', @{$systems{$sys->{sys}}{'inf'}});
                    $msg = Msg::new("\tPrivate Interfaces: $infs\\n");
                    $mesg .=$msg->{msg};
                    for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
                        my $ips = join(' ', @{$systems{$sys->{sys}}{'ip'}{$inf}});
                        $msg = Msg::new("\tPrivate IPs on $inf:$ips\\n");
                        my $aliases = join(' ', @{$systems{$sys->{sys}}{'alias'}{$inf}});
                        $mesg .=$msg->{msg};
                        $msg = Msg::new("\tAliases for above IPs:$aliases\\n");
                        $mesg .=$msg->{msg};
                        my $tmp_ip = @{$systems{$sys->{sys}}{'ip'}{$inf}}[1];
                        my $tmp_alias = @{$systems{$sys->{sys}}{'alias'}{$inf}}[1];
                        if (!$ipdone && $tmp_ip)  {
                            $is_ipv4 = EDRu::ip_is_ipv4($tmp_ip );
                            $ipdone = 1;
                        }
                        if (!$aliasdone && $tmp_alias) {
                            my @alias_parts = split(/-/m, $tmp_alias);
                            my $alias_parts_cnt = @alias_parts;
                            if ($alias_parts_cnt > 1) {
                                $prod->{ip_alias_name} = "-$alias_parts[1]";
                            }
                            $aliasdone = 1;
                        }
                        $ip_cnt += @{$systems{$sys->{sys}}{'ip'}{$inf}};
                    }
                }
                $msg = Msg::new("\\nIs this information correct?");
                $mesg .=$msg->{msg};
                $msg = Msg::new($mesg);
                $ayn = $msg->ayny;

            } else {

                $msg = Msg::new("Existing configuration for the MultiPrivNIC resource:");
                $msg->bold;
                $msg = Msg::new("Resource name: $prod->{mpriv_res_name}");
                $msg->print;

                my $ipdone = 0;
                my $aliasdone = 0;
                for my $sys (@{$clusnodes_ref}) {
                    $msg = Msg::new("System: $sys->{sys}");
                    $msg->print;
                    my $infs = join(' ', @{$systems{$sys->{sys}}{'inf'}});
                    $msg = Msg::new("\tPrivate Interfaces: $infs");
                    $msg->print;
                    for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
                        my $ips = join(' ', @{$systems{$sys->{sys}}{'ip'}{$inf}});
                        $msg = Msg::new("\tPrivate IPs on $inf:$ips");
                        my $aliases = join(' ', @{$systems{$sys->{sys}}{'alias'}{$inf}});
                        $msg->print;
                        $msg = Msg::new("\tAliases for above IPs:$aliases");
                        $msg->print;
                        my $tmp_ip = @{$systems{$sys->{sys}}{'ip'}{$inf}}[1];
                        my $tmp_alias = @{$systems{$sys->{sys}}{'alias'}{$inf}}[1];
                        if (!$ipdone && $tmp_ip)  {
                            $is_ipv4 = EDRu::ip_is_ipv4($tmp_ip );
                            $ipdone = 1;
                        }
                        if (!$aliasdone && $tmp_alias) {
                            my @alias_parts = split(/-/m, $tmp_alias);
                            my $alias_parts_cnt = @alias_parts;
                            if ($alias_parts_cnt > 1) {
                                $prod->{ip_alias_name} = "-$alias_parts[1]";
                            }
                            $aliasdone = 1;
                        }
                        $ip_cnt += @{$systems{$sys->{sys}}{'ip'}{$inf}};
                    }
                }

                Msg::n();
                $msg = Msg::new("Is this information correct?");
                $ayn = $msg->ayny;
            }
            if ($ayn eq 'N') {
                return 1;
            }
            Msg::n();
            $nodes_ref = $newnodes_ref;
        }

        my $priv_sys_index = -1;
        my $priv_inf_index = -1;
        my $sys_i = 0;
        my $inf_i = 0;

        #for my $sys (@{$nodes_ref}) {
        for ($sys_i = 0; $sys_i < (@{$nodes_ref}); $sys_i++ ) {
            $ip_sys_cnt = 0;

            my $sys = @{$nodes_ref}[$sys_i];
            my $priv_inf_index = -1;
            #for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
            for ($inf_i = 0; $inf_i < (@{$systems{$sys->{sys}}{'inf'}}); $inf_i++) {
                $inf_ip_cnt = 0;

WEB_ASK_MULTI_PRIV_AGAIN:
                $sys = @{$nodes_ref}[$sys_i];
		my $inf = @{$systems{$sys->{sys}}{'inf'}}[$inf_i];
		if (Obj::webui()) {
			$prod->{config_multi_priv} = 2;
			$web->web_script_form("config_multi_privnic",$sys,$inf,$add_ip_addr);
			$prod->{config_multi_priv} = 0;
			if ($web->param("back") eq "back") {
                            if ($priv_inf_index == -1) {
                                if ($priv_sys_index == -1) {
                                    goto WEB_ASK_MULTI_PRIV_RESOURCE;
                                } else {
                                    $sys = @{$nodes_ref}[$priv_sys_index];
                                    $sys_i = $priv_sys_index;
                                    $priv_sys_index--;
                                    $inf_i = (@{$systems{$sys->{sys}}{'inf'}}) - 1;
                                    $inf = @{$systems{$sys->{sys}}{'inf'}}[$inf_i];
                                    $priv_inf_index = $inf_i - 1;
                                    @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
   	                            if ($add_ip_addr) {
                                        @{$systems{$sys->{sys}}{'alias'}{$inf}} = ('');
                                    }
                                    goto WEB_ASK_MULTI_PRIV_AGAIN;
                                }
                            } else {
                                $inf = @{$systems{$sys->{sys}}{'inf'}}[$priv_inf_index];   
                                $inf_i = $priv_inf_index;
                                $priv_inf_index--;
                                @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
                                if ($add_ip_addr) {
                                    @{$systems{$sys->{sys}}{'alias'}{$inf}} = ('');
                                }
                                goto WEB_ASK_MULTI_PRIV_AGAIN;
                            }
			}
		}
                $priv_inf_index++;

                while (1) {

                    if (exists($prod->{mpriv_data}{$sys->{sys}}{'ip'}{$inf})) {
                        @def_ips = @{$prod->{mpriv_data}{$sys->{sys}}{'ip'}{$inf}};
                    } else {
                        @def_ips = ();
                    }
	            $mpriv_ips_ref = $prod->ask_mprivnic_ips($sys, $inf, \@def_ips);
        	    @mpriv_ips = @$mpriv_ips_ref;
                    return 0 if (EDR::getmsgkey($mpriv_ips[0],'back'));
                    if ($mpriv_ips[0] eq 'x') {
                        @{$prod->{mpriv_data}{$sys->{sys}}{'ip'}{$inf}} = ('x');
                        @{$prod->{mpriv_data}{$sys->{sys}}{'alias'}{$inf}} = ('');
                        goto next_inf;
                    }

                    $ret = $prod->check_ips($sys, $inf, $ip_cnt, $is_ipv4, $add_ip_addr, \@mpriv_ips, \%systems, 'MultiPrivNIC', $allnodes_ref);
                    if (Cfg::opt('responsefile')) {
                        return 1 if ($ret);
                    } else {
			if(Obj::webui()) {	
				goto WEB_ASK_MULTI_PRIV_AGAIN if ($ret); 
			}else {
                       	 	next if ($ret);
			}

                    }

                    if ($ip_cnt == 0) {
                        $is_ipv4 = EDRu::ip_is_ipv4($mpriv_ips[0]);
                    }

                    @{$prod->{mpriv_data}{$sys->{sys}}{'ip'}{$inf}} = @mpriv_ips;
                    last;
                }#while

                while ($add_ip_addr) {
                    if (exists($prod->{mpriv_data}{$sys->{sys}}{'alias'}{$inf})) {
                        @def_aliases = @{$prod->{mpriv_data}{$sys->{sys}}{'alias'}{$inf}};
                    } else {
                        @def_aliases = ();
                    }
                    $num_aliases = @mpriv_ips;
	            $mpriv_aliases_ref = $prod->ask_mprivnic_aliases($sys->{sys}, $inf, $ip_sys_cnt, $num_aliases, \@def_aliases);
                    if (Obj::webui()) {
                        if ($mpriv_aliases_ref == -1) {
                            @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
                            goto WEB_ASK_MULTI_PRIV_AGAIN; 
                        }
                    }
        	    @mpriv_aliases = @$mpriv_aliases_ref;
                    return 0 if (EDR::getmsgkey($mpriv_aliases[0],'back'));
                           
                    if ($mpriv_aliases[0] eq 'x') {
                        @{$prod->{mpriv_data}{$sys->{sys}}{'alias'}{$inf}} = ('x');
                        goto next_inf1;
                    }

                    $ret = $prod->check_aliases($sys, $inf, \@mpriv_aliases, \%systems, 'MultiPrivNIC', $allnodes_ref);
                    if (Cfg::opt('responsefile')) {
                        return 1 if ($ret);
                    } else {
			if(Obj::webui()) {
                            if ($ret) {
			        @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
                                goto WEB_ASK_MULTI_PRIV_AGAIN;
                            }
                        }else{
	                    next if ($ret);
			}
                    }

                    @{$prod->{mpriv_data}{$sys->{sys}}{'alias'}{$inf}} = @mpriv_aliases;
                    if ($ip_sys_cnt == 0) {
                        my @alias_parts = split(/-/m, $mpriv_aliases[0]);
                        my $alias_parts_cnt = @alias_parts;
                        if ($alias_parts_cnt > 1) {
                            $prod->{ip_alias_name} = "-$alias_parts[1]";
                        }
                    }

                    last;
                }
next_inf1:
                $ip_cnt += @mpriv_ips;
                $ip_sys_cnt += @mpriv_ips;
                $inf_ip_cnt += @mpriv_ips;
next_inf:
                Msg::n();
            } # for inf
            $priv_sys_index++;
            Msg::n();
        } # for sys

        if (!$isaddnode && $is_ipv4) {
            while(1) {
	        $prod->{config_multi_priv} = 3 if (Obj::webui());
	        $mpriv_mask = $prod->ask_netmask();
                $prod->{config_multi_priv} = 0 if (Obj::webui());
                
                if (Obj::webui()) {
		    if ($mpriv_mask eq 'back') {
                        my $sys = @{$nodes_ref}[$priv_sys_index];
                        $sys_i = $priv_sys_index;
                        $priv_sys_index--;
			$inf_i = (@{$systems{$sys->{sys}}{'inf'}}) - 1;
                        my $inf = @{$systems{$sys->{sys}}{'inf'}}[$inf_i];
                        $priv_inf_index = $inf_i - 1;
                        @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
                        if ($add_ip_addr) {
                            @{$systems{$sys->{sys}}{'alias'}{$inf}} = ('');
                        }
                        goto WEB_ASK_MULTI_PRIV_AGAIN;
                    }
                }

        	if (EDR::getmsgkey($mpriv_mask,'back')) {
                	return 0;
                }
		

                if (!EDRu::ip_is_ipv4($mpriv_mask)) {
                    $msg = Msg::new("The IPv4 Netmask is expected. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
		    if (Obj::webui()) {
			$web->web_script_form("alert",$msg->{msg});
		    }
                    next;
                }

                $prod->{priv_mask} = $mpriv_mask;
                $cfg->{nic_netmask} = $mpriv_mask if (!Cfg::opt('responsefile'));
                last;
            }
        }

        $prod->task_title('config_multiprivnic');

	my $msg_str = "";
        $msg = Msg::new("Verify private IP configuration information:");
        $msg->bold;
	$msg_str = "$msg->{msg}\n";

        $msg = Msg::new("Resource name: $prod->{mpriv_res_name}");
        $msg->print;
	$msg_str .= "$msg->{msg}\n"; 
        my $i = 1;
        for my $sys (@{$nodes_ref}) {
            $msg = Msg::new("System: $sys->{sys}");
            $msg->print;
	    $msg_str .= "$msg->{msg}\n";
            my $infs = join(' ', @{$systems{$sys->{sys}}{'inf'}});
            $msg = Msg::new("\tPrivate Interfaces: $infs");
            $msg->print;
	    $msg_str .= "$msg->{msg}\n";
            for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
                my $ips = join(' ', @{$systems{$sys->{sys}}{'ip'}{$inf}});
                $msg = Msg::new("\tPrivate IPs on $inf:$ips");
                my $aliases = join(' ', @{$systems{$sys->{sys}}{'alias'}{$inf}});
                $msg->print;
		$msg_str .= "$msg->{msg}\n";
                if ($add_ip_addr) {
                    $msg = Msg::new("\tAliases for above IPs:$aliases");
                    $msg->print;
		    $msg_str .= "$msg->{msg}\n";
                }
            }
        }

        if (!$isaddnode && $is_ipv4) {
            $msg = Msg::new("\n\tNetmask: $mpriv_mask");
            $msg->print;
	    $msg_str .= "$msg->{msg}\n";
        }

        Msg::n();

        goto DNA_CONFIRMNET if (Cfg::opt('responsefile'));
	if (Obj::webui()) {
		$msg = Msg::new("$msg_str \n\n Is this information correct?");
		$msg->print;
	}else {
	        $msg = Msg::new("Is this information correct?");
	}
       	$ayn = $msg->ayny;
        if ($ayn eq 'N' || $ayn eq 'n') {
            Msg::n();
            next;
        }

DNA_CONFIRMNET:
        $done = 1;
    } # for

    $msg = Msg::new("Changing configuration to read-write mode");
    $msg->left;
    EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
    EDR::cmd_local("$vcs->{bindir}/haconf -makerw");
    if (EDR::cmdexit() != 0) {
        Msg::right_failed();
        Msg::prtc();
        return 1;
    }
    Msg::right_done();

    if (!$isaddnode) {
        $ret = $prod->add_resource($prod->{mpriv_res_name}, 'MultiPrivNIC');
        if ($ret) {
            return 1;
        }
    }

    $msg = Msg::new("Updating resource configuration");
    $msg->left;

    for my $sys (@{$nodes_ref}) {
        my $pri = 0;
        my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
        for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
            EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{mpriv_res_name} Device -add $inf $pri -sys $sysname");
            if (EDR::cmdexit() != 0) {
                $err = 1;
                goto done;
            }
            $pri++;
        } #for inf

        $pri = 0;
        for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
            for my $ip (@{$systems{$sys->{sys}}{'ip'}{$inf}}) {
                if ($ip ne '')  {
                    EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{mpriv_res_name} Address -add $ip $pri -sys $sysname");
                    if (EDR::cmdexit() != 0) {
                        $err = 1;
                        goto done;
                    }
                }
            } #for ip
            $pri++;
        }#for inf
    } #for sys

    if (!$isaddnode && $is_ipv4) {
        EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{mpriv_res_name} NetMask $mpriv_mask");
        if (EDR::cmdexit() != 0) {
            $err = 1;
            goto done;
        }
    }

    EDR::cmd_local("$vcs->{bindir}/hares -modify $prod->{mpriv_res_name} Enabled 1");
    if (EDR::cmdexit() != 0) {
        $err = 1;
        goto done;
    }

    EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
    Msg::right_done();
    if (Obj::webui()) {
	$msg = Msg::new("MultiPrivNIC configuration was successful");
	$web->web_script_form("alert",$msg->{msg});
    }

    if ($add_ip_addr) {
        my $hfile;
        if ($prod->{hosts_file} eq '/etc/hosts') {
            $hfile = '/etc/hosts';
        } else {
            if ($is_ipv4) {
                $hfile = '/etc/hosts';
            } else {
                $hfile = $prod->{hosts_file};
            }
        }

        if ($isaddnode) {
            $msg = Msg::new("Adding existing configuration in $hfile on new nodes:");
            $msg->print;
            $ret = $prod->save_mpriv_configuration($is_ipv4, \%systems,
                        $clusnodes_ref, $newnodes_ref);
            return 1 if ($ret);
        }

        $msg = Msg::new("\nSaving configuration in $hfile on all nodes:");
        $msg->print;

        if (!$isaddnode) {
            $ret = $prod->save_mpriv_configuration($is_ipv4, \%systems,
                                $allnodes_ref, $allnodes_ref);
        } else {
            $ret = $prod->save_mpriv_configuration($is_ipv4, \%systems,
                               $newnodes_ref, $allnodes_ref);
        }

        if ($ret) {
            return 1;
        }
    }
done:
    if ($err) {
        if (!$isaddnode) {
            EDR::cmd_local("$vcs->{bindir}/hares -delete $prod->{mpriv_res_name}");
        }
        EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
        Msg::right_failed();
        Msg::prtc();
    }

    #Reset the default entries for IP addresses and Aliases
    for my $sys (@{$allnodes_ref}) {
        for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
            @{$prod->{mpriv_data}{$sys->{sys}}{'ip'}{$inf}} = ('');
            @{$prod->{mpriv_data}{$sys->{sys}}{'alias'}{$inf}} = ('');
        }
    }
    $prod->{mpriv_res_name} = '';
    $prod->{ip_alias_name} = '-priv';

    Msg::prtc();

    $nic_config_complete=0;
    return 0;
}

sub check_ips {
    my ($prod, $sys, $inf, $ip_cnt_r, $is_ipv4_r, $add_ip_addr, $ips_r, $systems_r, $res_type, $nodes_ref) = @_;
    my ($mpriv_ip, $is_ip_bad, @ip_parts, $uniq_ip, $prefix_len, $ip_parts_cnt, $ret, $msg);
    my ($is_ip_plumbed, $is_ip_in_hfile);
    my $ip_cnt = $ip_cnt_r;
    my $is_ipv4 = $is_ipv4_r;
    my @mpriv_ips = @$ips_r;
    my %systems = %$systems_r;
    my @used_ips = ();
    my @plumbed_ips = ();
    my @hfile_ips = ();
    my $cfg = Obj::cfg();
    my $web = Obj::web();
    my $tmpdir=EDR::tmpdir();
    $is_ip_bad = 0;
    for my $mpriv_ip (@mpriv_ips) {
        if (!$prod->is_ip_valid($mpriv_ip)) {
            $msg = Msg::new("$mpriv_ip is not a valid IP address");
            $msg->print;
	    $is_ip_bad = 1;
	    if (Obj::webui()) {
		$msg = Msg::new("$mpriv_ip is not a valid IP address. Input again");
            	$web->web_script_form("alert",$msg->{msg});
		last;
            }
            next;
        }

        # The below uniq_ip calculation is needed only
        # for IPv6 addresses, but making it generic to
        # make the code simpler.
        $prefix_len = -1;
        @ip_parts = split(/\//m, $mpriv_ip);
        $uniq_ip = $ip_parts[0];
        $ip_parts_cnt = @ip_parts;
        if ($ip_parts_cnt > 1) {
            $prefix_len = $ip_parts[1];
        }

        if ($ip_cnt == 0) {
            $is_ipv4 = EDRu::ip_is_ipv4($mpriv_ip);
        } else {
            if ($is_ipv4 && !EDRu::ip_is_ipv4($mpriv_ip) ||
                !$is_ipv4 && EDRu::ip_is_ipv4($mpriv_ip)) {
                $msg = Msg::new("All IP addresses must of same type, either IPv4 or IPv6");
                $msg->print;
                $msg = Msg::new("Input again");
                $msg->print;
		if (Obj::webui()) {
			$msg = Msg::new("All IP addresses must of same type, either IPv4 or IPv6. Input again");
                	$web->web_script_form("alert",$msg->{msg});
            	}
                goto ERROR;
            }

            if ($res_type eq 'MultiPrivNIC' ) {
                for my $sys_name (keys (%systems)) {
                    for my $inf_name (@{$systems{$sys_name}{'inf'}}) {
                        for my $ip_addr (@{$systems{$sys_name}{'ip'}{$inf_name}}) {
                            if (($ip_addr eq $uniq_ip) ||
                                    ($ip_addr =~ /^$uniq_ip\/.*$/mx)) {
                                $msg = Msg::new("IP address $mpriv_ip is duplicate or already used");
                                $msg->print;
                                $is_ip_bad = 1;
				if (Obj::webui()) {
		                        $msg = Msg::new("IP address $mpriv_ip is duplicate or already used. Input again");
                        		$web->web_script_form("alert",$msg->{msg});
					last;
                		}
                                goto next_ip;
                            }
                        }
                    }
                }
            } else {
                for my $sys_name (keys (%systems)) {
                    my $ip_addr = $systems{$sys_name}{'ip'};
                    if (($ip_addr eq $uniq_ip) ||
                        ($ip_addr =~ /^$uniq_ip\/.*$/mx)) {
                        $msg = Msg::new("IP address $mpriv_ip is already used");
                        $msg->print;
                        $is_ip_bad = 1;
			if (Obj::webui()) {
				$msg = Msg::new("IP address $mpriv_ip is already used. Input again");
                        	$web->web_script_form("alert",$msg->{msg});
				last;
                	}
                        goto next_ip;
                    }
                }
            } #if
        } #if

        if (!$is_ipv4) {
            if ($prefix_len == -1) {
                $msg = Msg::new("Subnet prefix was not specified for IP address $mpriv_ip");
                $msg->print;
                $is_ip_bad = 1;
		if (Obj::webui()) {
			$msg = Msg::new("Subnet prefix was not specified for IP address $mpriv_ip. Input again");
	                $web->web_script_form("alert",$msg->{msg});
        	        last;
                }
                next;
            }

            if ($prefix_len > 127) {
                $msg = Msg::new("The Subnet prefix must be less than 128 for IP address $mpriv_ip");
                $msg->print;
                $is_ip_bad = 1;
		if (Obj::webui()) {
			$msg = Msg::new("The Subnet prefix must be less than 128 for IP address $mpriv_ip. Input again");
                        $web->web_script_form("alert",$msg->{msg});
                        last;
                }
                next;
            }
        }

        $ret = $prod->get_plumbed_ips($nodes_ref);
        return 1 if ($ret);

        $is_ip_plumbed = 0;
        $ret = $prod->search_word($prod->localsys, "$tmpdir/plumbed_ips.txt", "$uniq_ip", 'ip');
        if ($ret == 0) {
            $is_ip_plumbed = 1;
        }

        $is_ip_in_hfile = 0;
        if($add_ip_addr){
            for my $sys1 (@{$nodes_ref}) {
                $ret = $prod->search_word($sys1, '/etc/hosts', "$uniq_ip", 'ip');
                if ($ret == 0) {
                    $is_ip_in_hfile = 1;
                    last;
                } else {
                    next if ($prod->{hosts_file} eq '/etc/hosts');
                    # Solaris specific checks
                    $ret = $prod->search_word($sys1, $prod->{hosts_file}, "$uniq_ip", 'ip');
                    if ($ret == 0) {
                        $is_ip_in_hfile = 1;
                        goto last;
                    }
                }
            } #for
        } #if

        if ($is_ip_plumbed && $is_ip_in_hfile) {
            push (@used_ips, $mpriv_ip);
        } elsif ($is_ip_plumbed) {
            push (@plumbed_ips, $mpriv_ip);
        } elsif ($is_ip_in_hfile) {
            push (@hfile_ips, $mpriv_ip);
        }

        $ip_cnt++;
        if ($res_type eq 'MultiPrivNIC') {
            push (@{$systems{$sys->{sys}}{'ip'}{$inf}}, $mpriv_ip);
        } else {
            $systems{$sys->{sys}}{'ip'} = $mpriv_ip;
        }
next_ip:
    } #for

    if ($is_ip_bad) {
        $msg = Msg::new("Input again.");
        $msg->print;
    } else {
	my $msg_str = "";
        my $plumbed_ip_cnt = @plumbed_ips;
        my $hfile_ip_cnt = @hfile_ips;
        my $used_ip_cnt = @used_ips;

        my $addr_str = 'address';
        if ($res_type eq 'MultiPrivNIC') {
            $addr_str = 'address(es)';
        }

        if ($plumbed_ip_cnt) {
            my $plumbed_ips_str = join(' ', @plumbed_ips);
            $msg = Msg::new("IP $addr_str $plumbed_ips_str is already in use. It is plumbed on one or more interface(s)");
            $msg->print;
            $msg_str = "$msg->{msg}\n";
        }

        if ($hfile_ip_cnt) {
            my $hfile_ips_str = join(' ', @hfile_ips);
            if ($prod->{hosts_file} eq '/etc/hosts') {
                $msg = Msg::new("\nIP $addr_str $hfile_ips_str is already in use and it exists in /etc/hosts file on one or more node(s).");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            } else {
                $msg = Msg::new("\nIP $addr_str $hfile_ips_str is already in use and it exists in /etc/hosts or $prod->{hosts_file} file on one or more node(s).");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            }
        }

        if ($used_ip_cnt) {
            my $used_ips_str = join(' ', @used_ips);
            if ($prod->{hosts_file} eq '/etc/hosts') {
                $msg = Msg::new("IP $addr_str $used_ips_str is already in use. It is plumbed on one or more interface(s), and it exists in /etc/hosts file on one or more node(s).");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            } else {
                $msg = Msg::new("IP $addr_str $used_ips_str already in use. It is plumbed on one or more interface(s), and it exists in /etc/hosts or $prod->{hosts_file} file on one or more node(s).");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            }
        }

        if (($hfile_ip_cnt || $used_ip_cnt) && $add_ip_addr) {
            if ($prod->{hosts_file} eq '/etc/hosts') {
                $msg = Msg::new("Additional entry for the same IP address will be added to /etc/hosts file.");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            } else {
                $msg = Msg::new("Additional entry for the same IP address will be added to /etc/hosts or $prod->{hosts_file} file.");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            }
        }

        if ($plumbed_ip_cnt || $hfile_ip_cnt || $used_ip_cnt) {
            if (Cfg::opt('responsefile')) {
                if ($cfg->{nic_reuseip}) {
                    $msg = Msg::new("'nic_reuseip' is set. $res_type Configuration will continue.");
                    $msg->log;
                } else {
                    $msg = Msg::new("\n$res_type Configuration will be aborted due to above errors\n");
                    $msg->bold;
                    goto ERROR;
                }
            } else {
		if (Obj::webui()) {
			$msg = Msg::new("$msg_str \n\nDo you want to use it anyway?");
		}else{
	                $msg = Msg::new("Do you want to use it anyway?");
		}
                my $ayn = $msg->aynn;
                if ($ayn eq 'n' || $ayn eq 'N') {
                    $cfg->{nic_reuseip} = 0;
                    goto ERROR;
                }
                $cfg->{nic_reuseip} = 1;
            }
        }
        return 0;
    }

ERROR:
    if ($res_type eq 'MultiPrivNIC') {
         @{$systems{$sys->{sys}}{'ip'}{$inf}} = ('');
    } else {
        $systems{$sys->{sys}}{'ip'} = '';
    }
    return 1;
}

sub search_word {
    my ($prod, $sys, $file, $s_word, $opr) = @_;
    my ($output, @lines, @words, $line, $word_cnt, $cnt);

    $output = $sys->cmd("_cmd_grep -v '^#' $file");
    @lines = split(/\n/,  $output);

    if ($opr eq 'ip') {
        for my $line (@lines) {
            @words = split(/(\s|\t)+/m, $line);
            if (($words[0] eq $s_word) ||
                    ($words[0] =~ /^$s_word\/.*$/mx)) {
                return 0;
            }
        }
    } else {
        for my $line (@lines) {
            @words = split(/(\s|\t)+/m, $line);
            $word_cnt = @words;
            $cnt = 1;
            while ($cnt < $word_cnt) {
                if ($words[$cnt] eq $s_word) {
                    return 0;
                }
                $cnt++;
            }
        }
    }

    return 1;
}

sub check_aliases {
    my ($prod, $sys, $inf, $aliases_r, $systems_r, $res_type, $nodes_ref) = @_;
    my ($alias, $is_alias_bad, $ret, $msg);
    my @mpriv_aliases = @$aliases_r;
    my %systems = %$systems_r;
    my @used_aliases = ();
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $is_alias_bad = 0;
    for my $alias (@mpriv_aliases) {
        if (!$prod->is_alias_valid($alias)) {
            $is_alias_bad = 1;
	    if (Obj::webui()) {
		last;
	    }
            next;
        }

        if ($res_type eq 'MultiPrivNIC') {
            for my $sys_name (keys (%systems)) {
                for my $inf_name (@{$systems{$sys_name}{'inf'}}) {
                    for my $als (@{$systems{$sys_name}{'alias'}{$inf_name}}) {
                        if ($als eq $alias) {
                            $msg = Msg::new("Alias $alias is duplicate or already used,");
                            $msg->print;
                            $is_alias_bad = 1;
			    if (Obj::webui()) {
        	                $msg = Msg::new("Alias $alias is duplicate or already used. Input again");
	                        $web->web_script_form("alert",$msg->{msg});
                        	last;
                    	    }
                            goto next_alias;
                        }
                    }
                }
            }
        } else {
            for my $sys_name (keys (%systems)) {
                my $als = $systems{$sys_name}{'alias'};
                if ($als eq $alias) {
                    $msg = Msg::new("Alias $alias is already used,");
                    $msg->print;
                    $is_alias_bad = 1;
		    if (Obj::webui()) {
			$msg = Msg::new("Alias $alias is already used. Input again");
			$web->web_script_form("alert",$msg->{msg});
		    }		    
                    goto next_alias;
                }
            }
        }

        for my $sys1 (@{$nodes_ref}) {
            $ret = $prod->search_word($sys1, '/etc/hosts', "$alias", 'alias');
            if ($ret == 0) {
                push (@used_aliases, $alias);
                last;
            } else {
                next if ($prod->{hosts_file} eq '/etc/hosts');
                # Solaris specific checks
                $ret = $prod->search_word($sys1, $prod->{hosts_file}, "$alias", 'alias');
                if ($ret == 0) {
                    push (@used_aliases, $alias);
                    last;
                }
            }
        } #for

        if ($res_type eq 'MultiPrivNIC') {
            push (@{$systems{$sys->{sys}}{'alias'}{$inf}}, $alias);
        } else {
            $systems{$sys->{sys}}{'alias'} = $alias;
        }
next_alias:
    }

    if ($is_alias_bad) {
        $msg = Msg::new("Input again.");
        $msg->print;
    } else {
        my $used_alias_cnt = @used_aliases;
	my $msg_str = "";
        if ($used_alias_cnt) {
            my $alias_str = 'alias';
            if ($res_type eq 'MultiPrivNIC') {
                $alias_str = 'alias(es)';
            }

            my $used_aliases_str = join(' ', @used_aliases);
            if ($prod->{hosts_file} eq '/etc/hosts') {
                $msg = Msg::new("The $alias_str $used_aliases_str already in use, exists in /etc/hosts file on one or more node(s)");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            } else {
                $msg = Msg::new("The $alias_str $used_aliases_str already in use, exists in /etc/hosts or $prod->{hosts_file} file on one or more node(s)");
                $msg->print;
                $msg_str .= "$msg->{msg}\n";
            }

            if (Cfg::opt('responsefile')) {
                if ($cfg->{nic_reusealias}) {
                    $msg = Msg::new("'nic_reusealias' is set. $res_type Configuration will continue.");
                    $msg->log;
                } else {
                    $msg = Msg::new("\n$res_type Configuration will be aborted due to above errors\n");
                    $msg->bold;
                    goto ERROR;
                }
            } else {
		if (Obj::webui()) {
			$msg = Msg::new("$msg_str  \n\nDo you want to use it anyway?");
		}else{
	                $msg = Msg::new("Do you want to use it anyway?");
		}
                my $ayn = $msg->aynn;
                if ($ayn eq 'n' || $ayn eq 'N') {
                    $cfg->{nic_reusealias} = 0;
                    goto ERROR;
                }
                $cfg->{nic_reusealias} = 1;
            }
        }

        return 0;
    }
ERROR:
    if ($res_type eq 'MultiPrivNIC') {
        @{$systems{$sys->{sys}}{'alias'}{$inf}} = ('');
	@{$systems{$sys->{sys}}{'ip'}{$inf}} = ('') if (Obj::webui());
    } else {
        $systems{$sys->{sys}}{'alias'} = '';
	$systems{$sys->{sys}}{'ip'} = '' if (Obj::webui());
    }
    return 1;
}

sub is_alias_valid {
    my ($prod, $alias) = @_;
    my ($alias_len, $msg);
    my $web = Obj::web();

    $alias_len = length($alias);
    if ($alias_len > 32) {
        $msg = Msg::new("$alias is not a valid Alias. The length cannot exceed 32 characters.");
        $msg->print;
	if (Obj::webui()) {
		$msg = Msg::new("$alias is not a valid Alias. The length cannot exceed 32 characters. Input again");
		$web->web_script_form("alert",$msg->{msg});
	}	
        return 0;
    }

    if ($alias =~ /.*_.*/m) {
        $msg = Msg::new("Underscore ('_') is not a valid character in a hostname according to RFC 2396.");
        $msg->print;
	if (Obj::webui()) {
                $msg = Msg::new("Underscore ('_') is not a valid character in a hostname according to RFC 2396. Input again");
                $web->web_script_form("alert", $msg->{msg});
        }
        return 0;
    }

    if (!($alias =~ /^[a-zA-Z][0-9a-zA-Z|\-]*[0-9a-zA-Z]$/mx)) {
        $msg = Msg::new("$alias is not a valid Alias. Make sure the alias does not start with a digit and does not contain special characters.");
        $msg->print;
	if (Obj::webui()) {
		$msg = Msg::new("$alias is not a valid Alias. Make sure the alias does not start with a digit and does not contain special characters. Input again");
	       	$web->web_script_form("alert",$msg->{msg});
	}
        return 0;
    }

    return 1;
}

sub check_resource {
    my ($prod, $res_type) = @_;
    my ($res_names, @resources, $res, @deleted_res, $delete_failed);
    my ($output, @lines, $line, @words, $word, $ips_str, $res_data, $flag);
    my ($msg, $ayn);
    my $vcs = $prod->prod('VCS60');
    my $cfg = Obj::cfg();
    my $tmpdir=EDR::tmpdir();
    $msg = Msg::new("Checking the existence of $res_type resources");
    $msg->left;

    EDR::cmd_local("$vcs->{bindir}/hares -display -type $res_type");
    if (EDR::cmdexit() == 0) {
        my $cmd = "$vcs->{bindir}/hares -display -type $res_type | _cmd_awk '{print \$1}' | _cmd_grep -v '^#' | _cmd_uniq";
        $res_names = EDR::cmd_local("$cmd");
        chomp($res_names);
        if ($res_names eq '') {
            Msg::right_failed();
            $msg = Msg::new("Couldn't find the resource name(s) for $res_type resource type");
            $msg->print;
            Msg::prtc();
            return 1;
        }

        @resources = split(/\n/, $res_names);
        my $str = join (' ', @resources);
        $msg = Msg::new("got $str");
        $msg->right;

        if (Cfg::opt('responsefile')) {
            if ($cfg->{nic_reconfigure_existing_resource}) {
                $ayn = 'Y';
            } else {
                $ayn = 'N';
            }
        } else {
            $msg = Msg::new("Do you want to delete and reconfigure?");
            $ayn = $msg->ayny();
        }

        if ($ayn eq 'N' || $ayn eq 'n') {
            $msg = Msg::new("Do you want to add an additional $res_type resource?");
            $ayn = $msg->ayny();
            if ($ayn eq 'N' || $ayn eq 'n') {
                return 1;
            }
            $cfg->{nic_reconfigure_existing_resource} = 0 if (!Cfg::opt('responsefile'));
            if ($res_type eq 'MultiPrivNIC') {
                if ($prod->{mpriv_res_name} eq '') {
                    my $res_cnt = @resources;
                    $prod->{mpriv_res_name} = "$resources[0]_$res_cnt";
                }
            } else {
                if ($prod->{priv_res_name} eq '') {
                    my $res_cnt = @resources;
                    $prod->{priv_res_name} = "$resources[0]_$res_cnt";
                }
            }
            return 0;
        }
        $cfg->{nic_reconfigure_existing_resource} = 1 if (!Cfg::opt('responsefile'));

        if ($res_type eq 'MultiPrivNIC') {
            if ($prod->{mpriv_res_name} eq '') {
                $prod->{mpriv_res_name} = $resources[0];
            }
        } else {
            if ($prod->{priv_res_name} eq '') {
                $prod->{priv_res_name} = $resources[0];
            }
        }

        $msg = Msg::new("Deleting $str resources");
        $msg->left;

        EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
        EDR::cmd_local("$vcs->{bindir}/haconf -makerw");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            Msg::prtc();
            return 1;
        }

        @deleted_res = ();
        $delete_failed = 0;
        EDR::cmd_local("_cmd_rm $tmpdir/ip_addresses.txt");
        for my $res (@resources) {
            #Save resource info
            $res_data = Msg::new("\nResource name: $res")->{msg};
            $output = EDR::cmd_local("$vcs->{bindir}/hares -display $res -attribute Address | _cmd_grep -v '^#'");
            @lines = split(/\n/, $output);
            for my $line (@lines) {
                @words = split(/\s+/m, $line);
                shift(@words);shift(@words);
                $ips_str = shift(@words);
                $ips_str = "$ips_str".':';
                $flag = 1;
                for my $word (@words) {
                    if ($flag) {
                        $ips_str = "$ips_str"." $word";
                        $flag = 0;
                    } else {
                        $flag = 1;
                    }
                }
                $res_data .= "\n$ips_str";
            }

            #Delete the resource
            EDR::cmd_local("$vcs->{bindir}/hares -delete $res");
            if (EDR::cmdexit() != 0) {
                $delete_failed = 1;
                next;
            }

            #Save resource info in a temporary file
            EDR::cmd_local("echo \'$res_data\' >> $tmpdir/ip_addresses.txt");
            if (EDR::cmdexit() != 0) {
                Msg::right_failed();
                $msg = Msg::new("Failed to add entries in $tmpdir/ip_addresses.txt file");
                $msg->print;
                Msg::prtc();
                return 1;
            }
        }

        EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");

        if ($delete_failed == 1) {
            $msg = Msg::new("Failed to delete one or more resource(s)");
            $msg->right;
        } else {
            Msg::right_done();
        }

        if ($prod->{hosts_file} eq '/etc/hosts') {
            #On Solaris $prod->{hosts_file} = /etc/inet/ipnodes
            $msg = Msg::new("\nThe following IP addresses were associated with the deleted $res_type resource(s). You must unplumb\nand remove the unused IP addresses from /etc/hosts file before assigning these to a new resource.");
            $msg->print;
        } else {
            $msg = Msg::new("\nThe following IP addresses were associated with the deleted $res_type resource(s). You must unplumb and\nremove the unused IP addresses from /etc/hosts and $prod->{hosts_file} files before assigning these to a new resource.");
            $msg->print;
        }

        $output =  EDR::cmd_local("_cmd_cat $tmpdir/ip_addresses.txt");
        Msg::print("$output");
        Msg::prtc();

        if ($delete_failed == 1) {
            return 1;
        }

    } else {
        $msg = Msg::new("doesn't exist");
        $msg->right;
    }

    return 0;
}

sub check_vcs_reswords {
    my $name = shift;

    my @vcs_res_words = (
    'ArgListValues',
    'Cluster',
    'ConfidenceLevel',
    'ConfidenceMsg',
    'Group',
    'IState',
    'MonitorOnly',
    'Name',
    'Path',
    'Probed',
    'Signaled',
    'Start',
    'State',
    'System',
    'Type',
    'MonitorMethod',
    'NameRule',
    'action',
    'after',
    'before',
    'boolean',
    'cluster',
    'condition',
    'event',
    'false',
    'firm',
    'global',
    'group',
    'hard',
    'heartbeat',
    'i18nstr',
    'int',
    'keylist',
    'local',
    'localclus',
    'offline',
    'online',
    'remote',
    'remotecluster',
    'requires',
    'resource',
    'set',
    'soft',
    'start',
    'state',
    'static',
    'stop',
    'str',
    'system',
    'temp',
    'true',
    'type',
    );

    for my $word (@vcs_res_words) {
        if ($name eq $word) {
            return 1;
        }
    }

    return 0;
}

# The validation part is based on the code written in
# src/lib/primitives/CheckName.C file under vcs_engine project.
sub validate_resource {
    my ($prod, $res_name) = @_;
    my ($len, $msg, $word);
    my $web = Obj::web();

    if (!($res_name =~ /^[a-zA-Z][0-9a-zA-Z|\-|_|]*$/mx)) {
        $msg = Msg::new("Invalid resource name. Input again");
        $msg->print;
	if (Obj::webui()) {
        	$web->web_script_form("alert",$msg->{msg});
        }
        return 1;
    }

    if (check_vcs_reswords($res_name)) {
        $msg = Msg::new("The resource name $res_name is a reserved word. Input again");
        $msg->print;
	if (Obj::webui()) {
        	$web->web_script_form("alert",$msg->{msg});
        }
        return 1;
    }

    $len = length($res_name);
    if ($len > 1024) {
        $msg = Msg::new("The length of resource name cannot exceed 1024 characters. Input again");
        $msg->print;
	if (Obj::webui()) {
                $web->web_script_form("alert",$msg->{msg});
        }
        return 1;
    }

    return 0;
}

sub add_resource {
    my ($prod, $res_name, $res_type) = @_;
    my ($msg, $err);
    my $vcs = $prod->prod('VCS60');

    $err = 0;

    $msg = Msg::new("Adding new $res_name resource");
    $msg->left;

    EDR::cmd_local("$vcs->{bindir}/hares -add $res_name $res_type cvm");
    if (EDR::cmdexit() != 0) {
        $err = 1;
        goto done;
    }

    EDR::cmd_local("$vcs->{bindir}/hares -modify $res_name Critical 0");
    if (EDR::cmdexit() != 0) {
        $err = 1;
        goto done;
    }

    EDR::cmd_local("$vcs->{bindir}/hares -local $res_name Device");
    if (EDR::cmdexit() != 0) {
        $err = 1;
        goto done;
    }

    EDR::cmd_local("$vcs->{bindir}/hares -local $res_name Address");
    if (EDR::cmdexit() != 0) {
        $err = 1;
        goto done;
    }

done:
    if ($err) {
        EDR::cmd_local("$vcs->{bindir}/hares -delete $res_name");
        EDR::cmd_local("$vcs->{bindir}/haconf -dump -makero");
        Msg::right_failed();
        Msg::prtc();
        return 1;
    }

    Msg::right_done();
    return 0;
}

sub ask_privnic_ip {
    my ($prod, $sys, $def_ip) = @_;
    my ($msg, $question, $help, $backopt, $is_ipv4);
    my $priv_ip = '';
    my $cfg = Obj::cfg();

    $help = '';
    $backopt = 1;

    if (Cfg::opt('responsefile')) {
        $priv_ip = $cfg->{$sys->{sys}}->{privnicip};
    } elsif (Obj::webui()) {
        $cfg->{$sys->{sys}}->{privnicip} = $def_ip;
    } else {
        $question = Msg::new("Enter the private IP for $sys->{sys}:");
       	$priv_ip = $question->ask("$def_ip", $help, $backopt);
	
    }

    $cfg->{$sys->{sys}}->{privnicip} = $priv_ip if (!Cfg::opt('responsefile'));
    return $priv_ip;
}

sub ask_mprivnic_ips {
    my ($prod, $sys, $inf, $def_ips_r) = @_;
    my (@ips, $ips_str, $msg, $question, $help, $backopt);
    my $def_ips_str = join(' ', @$def_ips_r);
    my $cfg = Obj::cfg();

    $help = '';
    $backopt = 1;

    $help = Msg::new("Enter 'x' if you want to skip.");
    if (Cfg::opt('responsefile')) {
        $ips_str = $cfg->{$sys->{sys}}->{$inf}->{multiprivnicip};
    } else {
        if (!Obj::webui()) {
            $question = Msg::new("Enter IP addresses for $sys->{sys} for $inf separated by space:");
            $ips_str = $question->ask($def_ips_str, $help, $backopt);
        } else {
            $ips_str = $cfg->{$sys->{sys}}->{$inf}->{multiprivnicip};
        }
    }
    if (EDR::getmsgkey($ips_str,'back')) {
        @ips = (EDR::get2('msg','back'));
    } elsif ($ips_str eq 'x' || $ips_str eq 'X') {
        @ips = ('x');
    } else {
        @ips = split(' ', $ips_str);
    }

    $cfg->{$sys->{sys}}->{$inf}->{multiprivnicip} = join(' ', @ips) if (!Cfg::opt('responsefile'));
    return \@ips;
}

sub ask_privnic_alias {
    my ($prod, $sys_name, $def_alias) = @_;
    my ($msg, $question, $help, $backopt);
    my $alias;
    my $cfg = Obj::cfg();

    $help = '';
    $backopt = 1;

    if ($def_alias eq '') {
        my $sysname = Prod::VCS60::Common::transform_system_name($sys_name);
        $def_alias = "$sysname"."$prod->{ip_alias_name}";
    }

    if (Cfg::opt('responsefile')) {
        $alias = $cfg->{$sys_name}->{hostname_for_ip};
    } elsif (Obj::webui()) {
        $cfg->{$sys_name}->{hostname_for_ip} = $def_alias;
    } else {
        $question = Msg::new("Enter Hostname alias for the above IP address:");
        $alias =  $question->ask($def_alias, $help, $backopt);
        $cfg->{$sys_name}->{hostname_for_ip} = $alias;
    }

    return $alias;
}

sub ask_mprivnic_aliases {
    my ($prod, $sys_name, $inf, $ip_sys_cnt, $num_aliases, $def_aliases_r) = @_;
    my (@aliases, $aliases_str, $def_alias_cnt, $alias_cnt, $cnt);
    my ($msg, $question, $help, $backopt);
    my @def_aliases = @$def_aliases_r;
    my $def_aliases_str = join(' ', @def_aliases);
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $help = '';
    $backopt = 1;

    if ($def_aliases_str eq '') {
        my $sysname = Prod::VCS60::Common::transform_system_name($sys_name);
        $def_alias_cnt = 0;
        while ($def_alias_cnt < $num_aliases) {
            if (($def_alias_cnt == 0) && ($ip_sys_cnt == 0)) {
                $def_aliases_str = "$def_aliases_str"."$sysname"."$prod->{ip_alias_name}";
            } else {
                $cnt = $ip_sys_cnt + $def_alias_cnt;
                $def_aliases_str = "$def_aliases_str"."$sysname"."$prod->{ip_alias_name}".'-'."$cnt";
            }

            $def_alias_cnt++;
            if ($def_alias_cnt < $num_aliases) {
                $def_aliases_str = "$def_aliases_str ";
            }
        }
    } elsif ($def_aliases_str ne 'x') {
        $def_alias_cnt = @def_aliases;
        if ($def_alias_cnt > $num_aliases) {
            $def_alias_cnt = 0;
            $def_aliases_str = '';
            while ($def_alias_cnt < $num_aliases) {
                $def_aliases_str = "$def_aliases_str"."$def_aliases[$def_alias_cnt]";
                $def_alias_cnt++;
                if ($def_alias_cnt < $num_aliases) {
                     $def_aliases_str = "$def_aliases_str ";
                }
            }
        } elsif ($def_alias_cnt < $num_aliases) {
            while ($def_alias_cnt < $num_aliases) {
                $def_aliases_str = "$def_aliases_str"." $def_aliases[$def_alias_cnt - 1]";
                $def_alias_cnt++;
            }
        }
    }

    while (1) {
        if ($prod->{hosts_file} eq '/etc/hosts') {
            $help = Msg::new("Enter 'x' if you want to skip. In that case this entry will not be added to /etc/hosts file.");
        } else {
            $help = Msg::new("Enter 'x' if you want to skip. In that case this entry will not be added to /etc/hosts and $prod->{hosts_file} files.");
        }

        if (Cfg::opt('responsefile')) {
            $aliases_str = $cfg->{$sys_name}->{$inf}->{hostname_for_ip};
        } else {
            if (!Obj::webui()) {
                $question = Msg::new("Enter Hostname aliases for the above IP addresses separated by space:");
                $aliases_str = $question->ask($def_aliases_str, $help, $backopt);
            } else {
                $aliases_str = $cfg->{$sys_name}->{$inf}->{hostname_for_ip};
            }
        }
        if (EDR::getmsgkey($aliases_str,'back')) {
            @aliases = (EDR::get2('msg','back'));
            last;
        } elsif ($aliases_str eq 'x' || $aliases_str eq 'X') {
            @aliases = ('x');
            last;
        }

        @aliases = split(' ', $aliases_str);
        $cfg->{$sys_name}->{$inf}->{hostname_for_ip} = join(' ', @aliases) if (!Cfg::opt('responsefile'));
        $alias_cnt = @aliases;


        if ($alias_cnt != $num_aliases) {
            if ($num_aliases == 1) {
                $msg = Msg::new("Only 1 alias is expected. Input again");
                $msg->print;
            } else {
                $msg = Msg::new("$num_aliases aliases are expected. Input again");
                $msg->print;
            }
            if (Obj::webui()) {
                $web->web_script_form("alert", $msg->{msg});
                return -1;
            }
            if (Cfg::opt('responsefile')) {
                my @emparr = ();
                return \@emparr;
            }
            next;
        }

        last;
    }

    return \@aliases;
}

sub ask_netmask {
    my $prod = shift;
    my ($msg, $question, $help, $backopt, $is_ipv4);
    my $priv_mask = '';
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $help = '';
    $backopt = 1;

    while (1) {
        if (Cfg::opt('responsefile')) {
            $priv_mask = $cfg->{nic_netmask};
        } else {
	    if (Obj::webui()){
		$web->web_script_form("config_net_mask",$prod);
                if ($web->param("back") eq "back") {
                    return 'back';
                }		
		$priv_mask = $cfg->{nic_netmask};
	    }else{
	            $question = Msg::new("Enter the Netmask for private network:");
        	    $priv_mask = $question->ask($prod->{priv_mask}, $help, $backopt);
	    }
        }
        return $priv_mask if (EDR::getmsgkey($priv_mask,'back'));
        chomp($priv_mask);

        my $mask = $priv_mask;
        if ($prod->is_ip_valid($mask)) {
            last;
        }

        $msg = Msg::new("$priv_mask is not a valid Netmask. Input again");
        $msg->print;
        last if (Cfg::opt('responsefile'));
	if (Obj::webui()) {
        	$web->web_script_form("alert",$msg->{msg});
        }
    }

    return $priv_mask;
}

sub is_ip_valid {
    my ($prod, $ip) = @_;
    my ($is_ipv4, $ipv4_addr, $ipv6_addr, @octets, $ocnt);
    my (@ip_parts, $ip_uniq, $cnt, $bcnt, $tcnt);

    $is_ipv4 = EDRu::ip_is_ipv4($ip);
    if ($is_ipv4) {
        @octets = split(/\./m, $ip);
        $ocnt = @octets;
        if ($ocnt == 4) {
            return 1;
        } else {
            return 0;
        }
    }

    if (!($ip =~ /:/m)) {
         return 0;
    }

    if ($ip =~ /\//m) {
        if (!($ip =~ /^.+\/\d+$/m)) {
            return 0;
        }

        @ip_parts = split(/\//m, $ip);
        $cnt = @ip_parts;
        if ($cnt > 2) {
            return 0;
        }

        $ip_uniq = $ip_parts[0];

        $bcnt = $ip_parts[1] + 0;
        if (!($bcnt <= 128)) {
            return 0;
        }

    } else {
        $ip_uniq = $ip;
    }


    if (!EDRu::ip_is_ipv6($ip_uniq)) {
        return 0;
    }

    if ($ip_uniq =~ /\./m) {
        @ip_parts = split(/\:/m, $ip_uniq);
        $cnt = @ip_parts;
        $cnt--;
        $ipv4_addr = $ip_parts[$cnt];
        @octets = split(/\./m, $ipv4_addr);
        $ocnt = @octets;
        if ($ocnt != 4) {
            return 0;
        }

        $ipv6_addr = '';
        my $i =0;
        while ($i < $cnt) {
            $ipv6_addr = $ipv6_addr."$ip_parts[$i]:";
            $i++;
        }

        $tcnt = 6;
    } else {
        $ipv6_addr = $ip_uniq;
        $tcnt = 8;
    }

    if (!($ipv6_addr =~ /::/m)) {
        @ip_parts = split(/:/m, $ipv6_addr);
        $cnt = @ip_parts;
        if ($cnt == $tcnt) {
            return 1;
        } else {
            return 0;
        }
    }

    return 1;
}

sub get_nics {
    my ($prod, $systems_ref) = @_;
    my ($msg, $sys, $sys_cnt, $llt_nics_str, $llt_nics_str_1);
    my @nics = ();

    $sys_cnt = 1;

    $msg = Msg::new("Discovering LLT links");
    $msg->left;

    for my $sys (@{$systems_ref}) {
        $llt_nics_str = $prod->get_llt_nics($sys);
        if ($llt_nics_str eq '') {
            Msg::right_failed();
            $msg = Msg::new("No LLT link configured on $sys->{sys}");
            $msg->print;
            Msg::prtc();
            @nics = ();
            return \@nics;
        }

        if ($sys_cnt == 1) {
            $llt_nics_str_1 = $llt_nics_str;
        } elsif ($llt_nics_str ne $llt_nics_str_1) {
            Msg::right_failed();
            $msg = Msg::new("The LLT links $llt_nics_str on $sys->{sys} are different from other nodes");
            $msg->print;
            Msg::prtc();
            @nics = ();
            return \@nics;
        }
        $sys_cnt++;
    } #for

    $msg = Msg::new("discovered $llt_nics_str_1");
    $msg->right;
    @nics = split(/\ /m, $llt_nics_str_1);
    return \@nics;
}

sub get_llt_nics {
    my ($prod, $sys) = @_;
    my ($llt_nics, $msg);
    my $vcs = $prod->prod('VCS60');

    $sys->cmd("_cmd_ls $vcs->{llttab}");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$vcs->{llttab} doesn't exist on $sys->{sys}");
        $msg->log;
        return '';
    }

    $llt_nics = $sys->cmd("_cmd_grep '^link' $vcs->{llttab} | _cmd_awk '{print \$2}'");

    chomp($llt_nics);

    $llt_nics =~ s/\n/\ /g;
    return $llt_nics;
}

sub save_priv_configuration {
    my ($prod, $is_ipv4, $systems_r, $src_nodes_ref, $dst_nodes_ref) = @_;
    my ($sys, @ip_parts, $uniq_ip, $ip_entry, $msg, $found, $ret, $alias,$tmpdir);
    my %systems = %$systems_r;

    $found = 0;
    $tmpdir=EDR::tmpdir();
    EDR::cmd_local("_cmd_rm -f $tmpdir/tmp_hosts");
    for my $sys (@{$src_nodes_ref}) {
        $alias = $systems{$sys->{sys}}{'alias'};
        if ($alias ne '') {
            $ret = $prod->check_hosts_file($alias, $dst_nodes_ref);
            if ($ret) {
                next;
            }
            $found = 1;
            @ip_parts = split(/\//m, $systems{$sys->{sys}}{'ip'});
            $uniq_ip = $ip_parts[0];
            $ip_entry = "$uniq_ip $systems{$sys->{sys}}{'alias'}";
            EDR::cmd_local("echo $ip_entry >> $tmpdir/tmp_hosts");
            if (EDR::cmdexit() != 0) {
                $msg = Msg::new("Failed to save the $ip_entry entry in  $tmpdir/tmp_hosts file");
                $msg->print;
                Msg::prtc();
                return 1;
            }
        }
    }

    if ($found) {
        if ($is_ipv4) {
            $ret = $prod->save_hosts_configuration('/etc/hosts', $dst_nodes_ref);
            if ($ret) {
                return 1;
            }
        } else {
            $ret = $prod->save_hosts_configuration($prod->{hosts_file}, $dst_nodes_ref);
            if ($ret) {
                return 1;
            }
        }
    }

    return 0;
}

sub save_mpriv_configuration {
    my ($prod, $is_ipv4, $systems_r, $src_nodes_ref, $dst_nodes_ref) = @_;
    my ($sys, $inf, $cnt, @ip_parts, $uniq_ip, $ip_entry, $msg, $ret);
    my (@ips, @aliases, $num_ips, $num_aliases, $ip, $alias, $atleat_one);
    my %systems = %$systems_r;
    my $TS = `date +%m%d%y_%H%M%S`;
    my $tmpdir=EDR::tmpdir();

    EDR::cmd_local("_cmd_rm -f $tmpdir/tmp_hosts");
    $atleat_one = 0;
    for my $sys (@{$src_nodes_ref}) {
        for my $inf (@{$systems{$sys->{sys}}{'inf'}}) {
            $num_ips = @{$systems{$sys->{sys}}{'ip'}{$inf}};
            $num_aliases = @{$systems{$sys->{sys}}{'alias'}{$inf}};
            if ($num_ips > 1 && $num_aliases > 1) {
                @ips = @{$systems{$sys->{sys}}{'ip'}{$inf}};
                @aliases = @{$systems{$sys->{sys}}{'alias'}{$inf}};
                $cnt = 1;
                while (($cnt < $num_ips) && ($cnt < $num_aliases)) {
                    $ret = $prod->check_hosts_file($aliases[$cnt], $dst_nodes_ref);
                    if ($ret) {
                        $cnt++;
                        next;
                    }

                    @ip_parts = split(/\//m, $ips[$cnt]);
                    $uniq_ip = $ip_parts[0];
                    $ip_entry = "$uniq_ip $aliases[$cnt]";
                    EDR::cmd_local("echo $ip_entry >> $tmpdir/tmp_hosts");
                    if (EDR::cmdexit() != 0) {
                        $msg = Msg::new("Failed to save the $ip_entry entry in $tmpdir/tmp_hosts file");
                        $msg->print;
                        Msg::prtc();
                        return 1;
                    }
                    $atleat_one = 1;
                    $cnt++;
                } #while
            } #if
        } #for
    } #for

    return 0 if (!$atleat_one);

    if ($is_ipv4) {
        $ret = $prod->save_hosts_configuration('/etc/hosts', $dst_nodes_ref);
        if ($ret) {
            return 1;
        }
    } else {
        $ret = $prod->save_hosts_configuration($prod->{hosts_file}, $dst_nodes_ref);
        if ($ret) {
            return 1;
        }
    }

    return 0;
}

sub check_hosts_file {
    my ($prod, $alias, $nodes_ref) = @_;
    my ($sys, $msg, $ret);

    for my $sys (@{$nodes_ref}) {
        $ret = $prod->search_word($sys, '/etc/hosts', "$alias", 'alias');
        if ($ret == 0) {
            $msg = Msg::new("Entry for the alias $alias already exists in /etc/hosts file on $sys->{sys}. No entry will be added for this alias on any node.");
            $msg->print;
            return 1;
        } else {
            next if ($prod->{hosts_file} eq '/etc/hosts');
            # Solaris specific checks
            $ret = $prod->search_word($sys, $prod->{hosts_file}, "$alias", 'alias');
            if ($ret == 0) {
                $msg = Msg::new("Entry for the alias $alias already exists in $prod->{hosts_file} file on $sys->{sys}. No entry will be added for this alias on any node.");
                $msg->print;
                return 1;
            }
        }
    }
    return 0;
}

sub save_hosts_configuration {
    my ($prod, $hosts_file, $nodes_ref) = @_;
    my ($localsys,$msg,$tmpdir);
    my $TS = `date +%m%d%y_%H%M%S`;

    $tmpdir=EDR::tmpdir();
    chomp($TS);
    $msg = Msg::new("Backing up $hosts_file file as $hosts_file-$TS");
    $msg->left;

    for my $sys (@{$nodes_ref}) {
        $sys->cmd("_cmd_cp -f $hosts_file $hosts_file-$TS");
        if (EDR::cmdexit() != 0) {
            goto done;
        }
    }
    Msg::right_done();

    $msg = Msg::new("Adding entries to $hosts_file file");
    $msg->left;

    $localsys=$prod->localsys;
    for my $sys (@{$nodes_ref}) {
        $localsys->copy_to_sys($sys,"$tmpdir/tmp_hosts","$tmpdir/tmp_hosts") unless ($sys->{islocal});
        $sys->cmd("_cmd_cat $tmpdir/tmp_hosts >> $hosts_file");
        if (EDR::cmdexit() != 0) {
            $sys->cmd("_cmd_rm $tmpdir/tmp_hosts") unless ($sys->{islocal});
            goto done;
        }
        $sys->cmd("_cmd_rm $tmpdir/tmp_hosts") unless ($sys->{islocal});
    }

    Msg::right_done();
    EDR::cmd_local("_cmd_rm $tmpdir/tmp_hosts");
    return 0;

done:
    Msg::right_failed();
    $msg = Msg::new("Add below entries to $hosts_file on all nodes");
    $msg->print;
    my $out = EDR::cmd_local("_cmd_cat $tmpdir/tmp_hosts");
    Msg::print("$out");
    EDR::cmd_local("_cmd_rm $tmpdir/tmp_hosts");
    Msg::prtc();
    return 1;
}

sub get_plumbed_ips {
    my ($prod, $nodes_ref) = @_;
    my ($sys, $output, $msg);
    my $tmpdir=EDR::tmpdir();

    EDR::cmd_local("_cmd_rm $tmpdir/plumbed_ips.txt");
    for my $sys (@{$nodes_ref}) {
#        $output = $sys->cmd("ifconfig -a | _cmd_grep inet | _cmd_awk \'{print \$2}\' | _cmd_awk -F\'\/\' \'{print \$1}\'");
        $output = $sys->cmd("ifconfig -a | _cmd_grep inet | _cmd_awk \'{print \$2}\'");
        EDR::cmd_local("echo \'$output\' >> $tmpdir/plumbed_ips.txt");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Failed to save plumbed ips in $tmpdir/plumbed_ips.txt");
            $msg->print;
            Msg::prtc();
            return 1;
        }
    }

    return 0;
}

sub verify_home_dirs {
    my ($prod, $home_dir) = @_;
    my ($ret, $sys, @cpnodes, $msg);
    my $iscfs = $prod->is_cfsmount($home_dir);

    # Verify that the home directory is valid on all cluster nodes.
    $ret = 0;
    @cpnodes = ($iscfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $msg = Msg::new("Verifying Oracle binaries on $sys->{sys}");
        $msg->left;
        $sys->cmd("_cmd_ls $home_dir > /dev/null");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            $ret = 1; next;
        }

        $sys->cmd("_cmd_ls $home_dir/bin > /dev/null");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            $ret = 1; next;
        }

        $sys->cmd("_cmd_ls $home_dir/lib > /dev/null");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            $ret = 1; next;
        }

        $sys->cmd("_cmd_ls $home_dir/rdbms/lib > /dev/null");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            $ret = 1; next;
        }

        Msg::right_done();
    } # for

    return $ret;
}

sub copy_and_replace {
    my ($prod, $sys, $src, $dst) = @_;
    my ($out, $msg);
    my $orauser = $prod->{oracle_user};
    my $oragrp = $prod->{oracle_group};
    my $TS = `date +%m%d%y_%H%M%S`;

    $out = $sys->cmd("_cmd_ls $dst");
    if ($out eq $dst) {
        $sys->cmd("_cmd_cp -rp $dst $dst-$TS");
        $sys->cmd("_cmd_chown $orauser:$oragrp $dst-$TS");
        $sys->cmd("_cmd_rm $dst");
        if (EDR::cmdexit() != 0) {
            return 1;
        }
    }

    $sys->cmd("_cmd_cp $src $dst");
    if (EDR::cmdexit() != 0) {
        return 1;
    }

    $sys->cmd("_cmd_chown $orauser:$oragrp $dst");
    if (EDR::cmdexit() != 0) {
        return 1;
    }

    return 0;
}

sub copy_and_link {
    my ($prod, $sys, $src, $dst) = @_;
    my ($out, $msg);
    my $orauser = $prod->{oracle_user};
    my $oragrp = $prod->{oracle_group};
    my $TS = `date +%m%d%y_%H%M%S`;

    $out = $sys->cmd("_cmd_ls $dst");
    if ($out eq $dst) {
        $sys->cmd("_cmd_cp $dst $dst-$TS");
        $sys->cmd("_cmd_chown $orauser:$oragrp $dst-$TS");
        $sys->cmd("_cmd_rm $dst");
        if (EDR::cmdexit() != 0) {
            return 1;
        }
    }

    $sys->cmd("_cmd_ln -s $src $dst");
    if (EDR::cmdexit() != 0) {
        return 1;
    }

    $sys->cmd("_cmd_chown $orauser:$oragrp $dst");
    if (EDR::cmdexit() != 0) {
        return 1;
    }

    return 0;
}

sub is_cfsmount {
    my ($prod, $dir) = @_;
    my ($fs, $ret, $out, $msg);

    if (! -d "$dir") {
        $msg = Msg::new("CFS check on Non-existent directory $dir\n");
        $msg->log;
        return 0;
    }

    my $subdir = $dir;
    my $found = 0;

    while ($subdir ne '/') {
        $fs = EDR::cmd_local("$prod->{mount_points} | _cmd_grep $subdir");
        if (EDR::cmdexit() != 0) {
            $subdir = EDRu::dirname($subdir);
        } else {
            if ($fs eq $subdir) {
                $found = 1;
            }
            last;
        }
    }

    if (!$found) {
        $msg = Msg::new("$dir is a local file system\n");
        $msg->log;
        return 0;
    }

    #
    # Run fsclustadm with $fs as the argument. Error indicates jfs.
    # If output is primary/secondary, it is a cfs mountpoint. Output
    # "local" indicates vxfs (non-clustered).
    #
    $out = EDR::cmd_local("/opt/VRTS/bin/fsclustadm mounttype $fs 2>/dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$dir is on a non-vxfs local file system\n");
        $msg->log;
        return 0;
    }

    if (($out eq 'primary') || ($out eq 'secondary')) {
        $msg = Msg::new("$dir is on a CFS mountpoint\n");
        $msg->log;
        return 1;
    }

    if ($out eq 'local') {
        $msg = Msg::new("$dir is a vxfs local file system\n");
        $msg->log;
        return 0;
    } else {
        $msg = Msg::new("is_cfsmount: Unknown output\n");
        $msg->print;
        return 1;
    }
}

sub is_cfsmount_sys {
    my ($prod, $dir, $sys) = @_;
    my ($fs, $ret, $out, $msg);

    if (!$sys->is_dir("$dir")) {
        $msg = Msg::new("CFS check on Non-existent directory $dir on $sys->{sys}\n");
        $msg->log;
        return 2;
    }

    $fs = EDR::cmd_local("$prod->{mount_points} | _cmd_grep $dir");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("'df' on $dir failed while checking for CFS\n");
        $msg->log;
        return 0;
    }

    #
    # Run fsclustadm with $fs as the argument. Error indicates jfs.
    # If output is primary/secondary, it is a cfs mountpoint. Output
    # "local" indicates vxfs (non-clustered).
    #
    $out = $sys->cmd("/opt/VRTSvxfs/sbin/fsclustadm mounttype $fs 2>/dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$dir is on a non-vxfs local file system\n");
        $msg->log;
        return 0;
    }

    if (($out eq 'primary') || ($out eq 'secondary')) {
        $msg = Msg::new("$dir is on a CFS mountpoint\n");
        $msg->log;
        return 1;
    }

    if ($out eq 'local') {
        $msg = Msg::new("$dir is a vxfs local file system\n");
        $msg->log;
        return 0;
    } else {
        $msg = Msg::new("is_cfsmount: Unknown output\n");
        $msg->print;
        return 3;
    }
}

sub is_cfsmount_all_systems {
    my ($prod, $dir_path) = @_;
    my ($sys, $iscfs, @dir_parts, $dir, $cnt, $i);

    @dir_parts = split(/\//m, $dir_path);
    for my $sys (@{CPIC::get('systems')}) {
        $cnt = @dir_parts;
        while ($cnt) {
            $dir = '';
            $i = 0;
            while ($i < $cnt) {
                $dir = "$dir"."\/$dir_parts[$i]";
                $i++;
            }

            if ($sys->is_dir("$dir")) {
                last;
            }

            $cnt--;
        }

        if ($dir =~ /\//m) {
            return 0;
        }
        $iscfs = $prod->is_cfsmount_sys($dir, $sys);
        if ($iscfs) {
            return $iscfs;
        }
    }

    return 0;
}

sub install_oracle_clusterware {
    my $prod= shift;
    my ($ret, $msg, $ayn);
    my $cfg = Obj::cfg();
    my $localsys = $prod->localsys;
    my $web = Obj::web();

    return 0 if (Cfg::opt('responsefile') && $cfg->{install_oracle_clusterware} == 0);
    $cfg->{install_oracle_clusterware} = 1;
    $prod->task_title('install_oracle_clusterware');

    if (!Cfg::opt('responsefile')) {
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure needs that you must use the same NICs on all systems of your cluster for private heartbeat links. Otherwise, it will not get configured on your cluster. The same is true for public links.\nFor example: If en0 is used for a public link on node 1 then you must use en0 for the public link on the rest of the nodes of your cluster.");
        $msg->print;
        $msg = Msg::new("\nDo you want to continue?");
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure needs that you must use the same NICs on all systems of your cluster for private heartbeat links. Otherwise, it will not get configured on your cluster. The same is true for public links.\nFor example: If en0 is used for a public link on node 1 then you must use en0 for the public link on the rest of the nodes of your cluster.\\nDo you want to continue?") if (Obj::webui());
        $ayn = $msg->ayny;
        if ($ayn eq 'n' || $ayn eq 'N') {
            return 0;
        }
    }

    $ret = $prod->install_crs_common();
    if ($ret != 0) {
        return 1;
    }

    $msg = Msg::new("\n\t\t\t\tORACLE CLUSTERWARE/GRID INFRASTRUCTURE INSTALLATION\n");
    $msg->bold;

    if ($prod->can('set_crs_install_env')) {
        $ret = $prod->set_crs_install_env();
        if ($ret != 0) {
            $msg = Msg::new("\nOne or more steps failed above. Cannot proceed with the Installation.");
            $msg->print;
            if (Obj::webui())
            {
                $msg = Msg::new("\nOne or more steps failed in setting CRS install environment. Cannot proceed with the Installation.");
                $web->web_script_form("alert", $msg->{msg});
            }
            Msg::prtc();
            return 1;
        }
    }

    my $temp_user;
    if (Cfg::opt('responsefile')) {
        # Comment >> check for release.
        if ($prod->{crs_release} !~ /11.2/m) {
            $temp_user = $cfg->{oracle_user};
        } else {
            $temp_user = $cfg->{grid_user};
        }
    } else {
        $temp_user = $prod->{oracle_user};
    }
    $ret = $prod->invoke_oui_installer($prod->{crs_release}, $prod->{crs_patch_level},
                                       $prod->{crs_installpath}, $prod->{crs_home}, 'crs',
                                       $temp_user);
    if ($ret != 0) {
        $msg = Msg::new("\nOracle installation failed. See the logs for details.");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        return 1;
    }
    my $bs=EDR::get2('tput','bs');
    my $be=EDR::get2('tput','be');
    if (!Cfg::opt('responsefile')) {
        $msg = Msg::new("Press <RETURN> here after completing the installation from OUI:");
        print "\n$bs$msg->{msg}$be ";
        <STDIN>;
    }
    if (Obj::webui()) {
        $msg = Msg::new("Click <OK> here after completing the installation from OUI.");
        $web->web_script_form("alert", $msg->{msg});
    }
    Msg::n();

    #
    # Verify that the binaries have been installed in crs_home.
    #
    $ret = $prod->verify_home_dirs($prod->{crs_home});
    if ($ret != 0) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure binaries are not installed properly");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        return 1;
    }

    # Copying the responsefile created for CRS installation
    my $tmpdir=EDR::tmpdir();
    if ($prod->{crs_release} !~ /11.2/m) {
        $localsys->copyfile("$prod->{crs_home}/install.crs_responsefile","$tmpdir/install.crs_responsefile") if (!Cfg::opt('responsefile'));
    }

    $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure Installation is now complete");
    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
    $msg->print;
    Msg::prtc();

    return 0;
}

# Given resource type as first argument and a hash of attributes as second,
# returns the ref to the array of resource(s) name. If failed return "".
#
# The hash will have attribute name as the keys and attribute value as the values.
#
# The subroutine below will keep searching for the appropriate resource until it
# finds the (mostly unique) resource which has ALL the attributes passed to it.
# In case it finds more than one resources it returns an array of them all.
sub get_resname {
    my $prod = shift;
    my $restype = shift;
    my $attribs = shift;
    my @emp;
    my $vcs = $prod->prod('VCS60');
    my $sys = @{CPIC::get('systems')}[0];
    my ($resname, @resname, $str);
    return '' if (ref($attribs) !~ /HASH/m);

    for my $key (keys %$attribs) {
        $str = $str.$key.'='.$$attribs{$key}.' ';
    }

    $resname = $sys->cmd("$vcs->{bindir}/hares -list $str Type=$restype");
    if (EDR::cmdexit()) {
        return '';
    } else {
        chomp($resname);
        my @tmparr = split(/\n/, $resname);
        for my $item (@tmparr) {
            push (@resname, (split(/\s+/m,$item))[0]) if ($item ne '');
        }
        $resname = EDRu::arruniq(@resname); # Get only the unique elements
    }

    return $resname; # A ref to the array
}

# Return resource name for OCR/Vote device or file
# It's a device if number of args == 2
# It's a file if number of args == 1
#
# Uses sub get_resname
sub get_ovresname {
    my ($ocrdg, $ocrvol, $cfsmtpt);
    my ($type, %attribs, @resname);
    my ($prod, $msg, $ret);
    my $cfsmnt = 0;
    if ($#_ == 2) { # 3 args
        ($prod, $ocrdg, $ocrvol) = @_;
        $type = 'CVMVolDg';
        $ocrdg = EDRu::despace($ocrdg);
        $ocrvol = EDRu::despace($ocrvol);
        %attribs = ('CVMDiskGroup' => $ocrdg, 'CVMVolume' => $ocrvol);
    } elsif ($#_ == 1) { # 2 arg
        $cfsmnt = 1;
        ($prod, $cfsmtpt) = @_;
        $type = 'CFSMount';
        $cfsmtpt = EDRu::despace($cfsmtpt);
        %attribs = ('MountPoint' => $cfsmtpt);
    } else {
        return '';
    }
    $ret = $prod->get_resname($type, \%attribs);
    @resname = @{$ret};
    if (ref($ret) !~ /ARRAY/m && $ret eq '') {
    # Could also be a case where attribute passed (CVMDiskGroup CVMVolume MountPoint)
    # had more than one values (like an array)
    #
    # So, let's try to pass no attributes and see if we get any results
        %attribs = (); # Empty hash
        $ret = $prod->get_resname($type, \%attribs);
        if ($ret eq '') {
            $msg = Msg::new("(Failed to find resource(s) of type $type. See logs for more details.)");
            $msg->print;
            return '';
        }
        @resname = @{$ret};
        my $vcs = $prod->prod('VCS60');
        my $sys = @{CPIC::get('systems')}[0];
        my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
        for my $item (@resname) {
            if ($cfsmnt) {
                $ret = $sys->cmd("$vcs->{bindir}/hares -value $item MountPoint $sysname | _cmd_grep -w $cfsmtpt");
            } else {
                $ret = $sys->cmd("$vcs->{bindir}/hares -value $item CVMVolume $sysname | _cmd_grep -w $ocrvol");
            }
            return $item if (!EDR::cmdexit()); # Return at the first match
        }
        $msg = Msg::new("(Failed to find resource(s) of type $type. See logs for more details.)");
        $msg->print;
        return '';
    } elsif ($#resname > 0) { # More than one kinda OCR/Vote resource!
        $msg = Msg::new("Found more than one resources of type $type for the given attributes. Cannot proceed. Consult logs for more information.");
        $msg->print;
        Msg::prtc();
        return '';
    }
    return $resname[0];
}

# Using the Oracle Clusterware installation files find out the location for the OCR device/file
sub get_ocrloc {
    my $prod = shift;
    my @emp;
    my $crshome = $prod->{crs_home};
    return \@emp if ($crshome eq '');
    my $sys = @{CPIC::get('systems')}[0];

    $sys->cmd("_cmd_ls $crshome/bin/ocrcheck 2> /dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$crshome/bin/ocrcheck doesn't exist on $sys->{sys}");
        $msg->print;
        Msg::prtc();
        return '';
    }

    my $ocrloc = $sys->cmd("$crshome/bin/ocrcheck | _cmd_grep 'Device\/File Name'");
    return \@emp if (EDR::cmdexit());
    chomp($ocrloc);
    my @ocrloc = split(/\n/, $ocrloc);
    for my $item (@ocrloc) {
        $item= (split(/:/m, $item))[1];
        $item = EDRu::despace($item);
    }
    return \@ocrloc;
}

# Using the Oracle Clusterware installation files find out the location for the Vote device/file
sub get_voteloc {
    my $prod = shift;
    my @emp;
    my $crshome = $prod->{crs_home};
    return \@emp if ($crshome eq '');
    my $sys = @{CPIC::get('systems')}[0];

    $sys->cmd("_cmd_ls $crshome/bin/crsctl 2> /dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$crshome/bin/crsctl doesn't exist on $sys->{sys}");
        $msg->print;
        Msg::prtc();
        return '';
    }

    my $voteloc = $sys->cmd("$crshome/bin/crsctl query css votedisk");
    return \@emp if (EDR::cmdexit());
    chomp($voteloc);
    my @voteloc = split(/\n/, $voteloc);
    pop (@voteloc);
    $ret = $prod->get_oraver_from_opatch('crs', 'Oracle Clusterware');
    if ($ret != 0) {
        $ret = $prod->get_oraver_from_opatch('crs', 'Oracle Grid Infrastructure');
    }
    for my $item (@voteloc) {
        if ($prod->{crs_release} =~ /11.2/m) {
            next if($item =~ /^[#-]/m);
            $item = $1 if ($item =~ /\((.*)\)/m);
        } else {
            $item = (split(/\s+/m, $item))[3];
        }
        $item = EDRu::despace($item);
    }
    @voteloc = grep(!/^#/,@voteloc);
    @voteloc = grep(!/^-/,@voteloc);
    return \@voteloc;
}

# Find the service group for the given resource (name)
sub get_servgrp {
    my $prod = shift;
    my $resname = shift;
    return '' if ($resname eq '');
    my $sys = @{CPIC::get('systems')}[0];
    my $vcs = $prod->prod('VCS60');
    my ($msg, $srvgrp, @srvgrp);
    $srvgrp = $sys->cmd("$vcs->{bindir}/hares -display $resname | grep -w Group");
    return '' if (EDR::cmdexit());
    chomp($srvgrp);
    @srvgrp = split(/\n/, $srvgrp);
    if ($#srvgrp > 0) {
        $msg = Msg::new("The resource $resname is present with mutiple service groups. Cannot proceed. See logs for more information.");
        $msg->print;
        Msg::prtc();
        return '';
    }
    chomp($srvgrp[0]);
    @srvgrp = split(/\s+/m, $srvgrp[0]);
    $srvgrp = pop(@srvgrp);
    $srvgrp = EDRu::despace($srvgrp);
    return $srvgrp;
}

# Find the PrivNIC/MultiPrivNIC resource name as per the IP address
sub get_netresname {
    my $prod = shift;
    my $mpnic = 0; # Is it a MultiPrivNIC resource?
    my ($nicres,$ret,$privhost,$privip);
    return '' if ($prod->{crs_home} eq '');

    my $sys = @{CPIC::get('systems')}[0];
    my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});

    $ret = $prod->get_oraver_from_opatch('crs', 'Oracle Clusterware');
    if ($ret != 0) {
        $ret = $prod->get_oraver_from_opatch('crs', 'Oracle Grid Infrastructure');
    }
    if ($prod->{crs_release} =~ /11.2/m) {
        $privhost = $sys->cmd("$prod->{crs_home}/bin/olsnodes -p -l");
        return '' if (EDR::cmdexit());
        my $privips = (split(/\s+/m, $privhost))[1];
        $privip = (split(/,/m, $privips))[0];

    } else {
        $privhost = $sys->cmd("$prod->{crs_home}/bin/olsnodes -p");
        return '' if (EDR::cmdexit());
        $privhost = (split(/\s+/m, $privhost))[1];
        return '' if (!$sys->exists('/etc/hosts'));
        $privip = $sys->cmd("_cmd_cat /etc/hosts | _cmd_grep -v '^#' | _cmd_grep -w $privhost");
        return '' if EDR::cmdexit();
        $privip = (split(/\s+/m, $privip))[0];
    }

    my %cssdattrib = ('Address' => $privip);
    $ret = $prod->get_resname('PrivNIC', \%cssdattrib);
    if ($ret eq '') { # PrivNIC failed, try MultiPrivNIC
        $mpnic = 1;
        %cssdattrib = (); # Empty hash
        $ret = $prod->get_resname('MultiPrivNIC', \%cssdattrib);
    }
    return '' if ($ret eq '');
    my @resname = @{$ret};
    if ($mpnic) {
        my $vcs = $prod->prod('VCS60');
        for my $item (@resname) {
            $ret = $sys->cmd("$vcs->{bindir}/hares -value $item Address $sysname | _cmd_grep -w $privip");
            return $item if (!EDR::cmdexit()); # Return at the first match
        }
        return '';
    }
    if (ref($ret) =~ /ARRAY/m && $#resname > 0) {
        $msg = Msg::new("Found more than one resources of type $type for the given attributes. Cannot proceed. Consult logs for more information.");
        $msg->log();
        return '';
    }
    return $resname[0];
}

# Return 0 if everything went alright or cssd already installed/configured
# Return something else otherwise (1)
sub config_cssd_agent {
    my $prod = shift;
    my $cfg = Obj::cfg();
    my ($errstr, $ret, $msg, $ayn, $index);
    my $cssdres = 'cssd';
    my $web = Obj::web();
    my $vcs = $prod->prod('VCS60');
    my $sys = @{CPIC::get('systems')}[0];
    my ($servicegroup, @servicegroup, $resname, @resname);
    my $def;
    my $help = '';

    return 0 if (Cfg::opt('responsefile') && $cfg->{config_cssd_agent} == 0);
    $cfg->{config_cssd_agent} = 1;
    $prod->task_title('config_cssd_agent');

    # Check if cssd resource already exists
    my %cssdattrib = ('StartProgram' => '/opt/VRTSvcs/rac/bin/cssd-online');
    $ret = $prod->get_resname('Application', \%cssdattrib);
    @resname = @{$ret};
    if (ref($ret) !~ /ARRAY/m && $ret eq '') {
        $resname = '';
    } elsif ($#resname > 0) { # More than one kinda CSSD resource!
        $msg = Msg::new("Found more than one CSSD resources for the given attributes. Cannot proceed. Consult logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    } else {
        $resname = $resname[0];
    }

    if ($resname ne '') {
        if (Cfg::opt('responsefile')) {
            $ayn = $cfg->{reconfigure_cssd_resource} ? 'Y' : 'N';
        } else {
            $msg = Msg::new("The CSSD agent resource ($resname) already exists. Do you want to delete and reconfigure this resource?");
            $ayn = $msg->ayny;
        }
        if ($ayn eq 'N') {
            $msg = Msg::new("CSSD agent is already configured. Check the VCS configuration.");
            $msg->log;
            $cfg->{reconfigure_cssd_resource} = 0 if (!Cfg::opt('responsefile'));
            return 1;
        }

        $cfg->{reconfigure_cssd_resource} = 1 if (!Cfg::opt('responsefile'));
        $msg = Msg::new("Deleting resource: $resname");
        $msg->left;
        $ret = $sys->cmd("$vcs->{bindir}/haconf -makerw");
        if ($ret !~ /Cluster already writable/m && EDR::cmdexit()) {
            Msg::right_failed();
            $msg = Msg::new("(Failed to change mode of VCS configuration file to Read/Write. HAD maybe down. Check logs for more information.)");
            $web->web_script_form("alert", $msg) if (Obj::webui());
            $msg->print;
            Msg::prtc();
            return 1;
        }
        $sys->cmd("$vcs->{bindir}/hares -delete $resname");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            $msg = Msg::new("(Failed to delete resource $resname from VCS configuration. Check logs for more information.)");
            $web->web_script_form("alert", $msg) if (Obj::webui());
            $msg->print;
            Msg::prtc();
            return 1;
        }

        $ret = $sys->cmd("$vcs->{bindir}/haconf -dump -makero");
        if ($ret !~ /VCS WARNING/m && EDR::cmdexit()) {
            Msg::right_failed();
            $msg = Msg::new("Failed to update the VCS configuration file about the deletion of the resource ${resname}. HAD maybe down. Check logs for more information.)");
            $msg->print;
            $web->web_script_form("alert", $msg) if (Obj::webui());
            Msg::prtc();
            return 1;
        }
        Msg::right_done();
    }
    Msg::prtc();

    if (Obj::webui()) {
         $prod->{config_cssd_agent} = 1;# webinstaller sidesteps
         $web->web_script_form("config_cssd_agent_get_crs_home", $prod) if (Obj::webui());
         $prod->{config_cssd_agent} = 0;# webinstaller sidesteps
	 if ($web->param("back") eq "back") {
             return 0;
         }
    }

    # Need to check if Oracle Clusterware is running before configuring cssd agent
    return 1 if ($prod->determine_crs_home('post_crs_install'));
    if (!$prod->is_crs_up(CPIC::get('systems'))) {
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure is down on one or more nodes. Cannot proceed with cssd agent configuration. Start Oracle Clusterware/Grid Infrastruture first and then try again.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }

    # Add cssd agent
    # Determine service group with the help of OCR/Vote location
    # Find out OCR/Vote and PrivNIC/MultiPrivNIC dependencies as well
    my ($ocrloc,$voteloc,$ocrdg,$ocrvol,$votedg,$votevol,$temp,$cfsmtpt);
    my ($ocrvolres, $votevolres, @ocrvolres, @votevolres, $i, @mntpts, $mntpts);
    $ocrloc = $prod->get_ocrloc;
    $voteloc = $prod->get_voteloc;
    for my $item (@{$ocrloc}) {
        $item = EDRu::despace($item);
        if ($item =~ /\/dev\/vx\//mx) {
            $item = reverse $item;
            ($ocrvol, $ocrdg, $temp) = split(/\//m, $item, 3);
            $ocrvol = reverse $ocrvol;
            $ocrdg = reverse $ocrdg;
            $ocrvolres = $prod->get_ovresname($ocrdg, $ocrvol);
            push (@ocrvolres, $ocrvolres) if ($ocrvolres ne '');
            $servicegroup = $prod->get_servgrp($ocrvolres);
            push (@servicegroup, $servicegroup) if ($servicegroup ne '');
        } elsif ($item ne '') {
            $mntpts = $sys->cmd($prod->{mount_points});
            if (EDR::cmdexit()) {
                $msg = Msg::new("'df' failed while checking for CFS mount point.");
                $msg->log;
                return 1;
            }
            @mntpts = split (/\n/, $mntpts);
            for my $cfsmtptstr (@mntpts) {
                next if ($cfsmtptstr eq '/');
                if (substr($item, 0, length ($cfsmtptstr)) eq $cfsmtptstr) {
                    $cfsmtpt = $cfsmtptstr;
                    last;
                }
            }
            $ocrvolres = $prod->get_ovresname($cfsmtpt);
            push (@ocrvolres, $ocrvolres) if ($ocrvolres ne '');
            $servicegroup = $prod->get_servgrp($ocrvolres);
            push (@servicegroup, $servicegroup) if ($servicegroup ne '');
        }
    }
    $ocrvolres = EDRu::arruniq(@ocrvolres);
    @ocrvolres = @{$ocrvolres};

    if (scalar @ocrvolres < 1) {
        goto SKIP_VOTELOC;
    }

    for my $item (@{$voteloc}) {
        $item = EDRu::despace($item);
        if ($item =~ /\/dev\/vx\//mx) {
            $item = reverse $item;
            ($votevol, $votedg, $temp) = split(/\//m, $item, 3);
            $votevol = reverse $votevol;
            $votedg = reverse $votedg;
            $votevolres = $prod->get_ovresname($votedg, $votevol);
            push (@votevolres, $votevolres) if ($votevolres ne '');
            $servicegroup = $prod->get_servgrp($votevolres);
            push (@servicegroup, $servicegroup) if ($servicegroup ne '');
        } elsif ($item ne '') {
            $mntpts = $sys->cmd($prod->{mount_points});
            if (EDR::cmdexit()) {
                $msg = Msg::new("'df' failed while checking for CFS mount point.");
                $web->web_script_form("alert", $msg) if (Obj::webui());
                $msg->log;
                return 1;
            }
            @mntpts = split (/\n/, $mntpts);
            for my $cfsmtptstr (@mntpts) {
                next if ($cfsmtptstr eq '/');
                if (substr($item, 0, length ($cfsmtptstr)) eq $cfsmtptstr) {
                    $cfsmtpt = $cfsmtptstr;
                    last;
                }
            }
            $votevolres = $prod->get_ovresname($cfsmtpt);
            push (@votevolres, $votevolres) if ($votevolres ne '');
            $servicegroup = $prod->get_servgrp($votevolres);
            push (@servicegroup, $servicegroup) if ($servicegroup ne '');
        }
    }
    $votevolres = EDRu::arruniq(@votevolres);
    @votevolres = @{$votevolres};
SKIP_VOTELOC:
    if (scalar @ocrvolres < 1 || scalar @votevolres < 1) {
        $msg = Msg::new("Cannot determine the VCS resource(s) for the OCR or/and Voting disk. Consult logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->warning;
        Msg::prtc();
        return 1;
    }

    my $nicres = $prod->get_netresname;
    if ($nicres eq '') {
        $msg = Msg::new("Cannot determine the PrivNIC/MultiPrivNIC resource for Oracle clusterware Private IPs. Consult logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->warning;
        Msg::prtc();
        return 1;
    }
    $servicegroup = $prod->get_servgrp($nicres);
    push (@servicegroup, $servicegroup) if ($servicegroup ne '');

    $servicegroup = EDRu::arruniq(@servicegroup);
    if (scalar @{$servicegroup} > 1) {
        $msg = Msg::new("Cannot continue as VCS resources for OCR, Voting and Oracle clusterware Private IPs are part of different VCS service groups. Consult logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->bold;
        Msg::prtc();
        return 1;
    }
    if (scalar @{$servicegroup} < 1) {
        $msg = Msg::new("Cannot continue as VCS service group containing the OCR and Voting disk cannot be determined. Consult logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->bold;
        Msg::prtc();
        return 1;
    }

    $prod->task_title('config_cssd_agent');

# Show all the information for confirmation

    if (Obj::webui()) {
        my $mesg = Msg::new("The Oracle Clusterware components, the corresponding VCS resource and service groups are as follows:\n");
        my $bs1 = '%-15s %-35s %-s';
        my $msg_type = Msg::new("Type")->{msg};
        #$msg_type = EDRu::fixed_length_str('Type',30,'L');
        #$mesg->{msg} .=$msg_type;
        my $msg_resource = Msg::new("Resource Name")->{msg};
        #$msg_resource = EDRu::fixed_length_str('Resource Name',30,'L');
        #$mesg->{msg} .=$msg_resource;
        my $msg_service = Msg::new("Service Group")->{msg};
        #$msg_service = EDRu::fixed_length_str('Service Group',30,'L');
        #$mesg->{msg} .=$msg_service;
        #$mesg->{msg} .= Msg::string_sprintf($bs1, $msg_type, $msg_resource, $msg_service);
        my $bs = Msg::string_sprintf($bs1, $msg_type, $msg_resource, $msg_service);
        $bs =~ s/\s/&nbsp;/mg;
        $mesg->{msg} .= $bs;
        $mesg->{msg} .= '\n';
        $mesg->{msg} .= "=============================================================\n";
        my $msg_pip = Msg::new("Private IP")->{msg};
        my $msg_ocr = Msg::new("OCR")->{msg};
        my $msg_vd = Msg::new("Voting disk")->{msg};
        $bs = Msg::string_sprintf($bs1, $msg_pip, $nicres, $servicegroup[0]);
        $bs =~ s/\s/&nbsp;/mg;
        #$mesg->{msg} .= Msg::print($bs);
        $mesg->{msg} .= $bs;
        $mesg->{msg} .= '\n';
        for my $item (@ocrvolres) {
           $bs = Msg::string_sprintf($bs1, $msg_ocr, $item, $servicegroup[0]);
           $bs =~ s/\s/&nbsp;/mg;
           $mesg->{msg} .= $bs;
           $mesg->{msg} .= '\n';
        }
        for my $item (@votevolres) {
           $bs = Msg::string_sprintf($bs1, $msg_vd, $item, $servicegroup[0]);
           $bs =~ s/\s/&nbsp;/mg;
           $mesg->{msg} .=$bs;
           $mesg->{msg} .= '\n';
        }
	    $mesg->{msg} .= '\n';
        $mesg->{msg} .= '\n';
        $mesg->{msg} .= Msg::new("Do you want to continue?")->{msg};
        $ayn = $mesg->ayny();

    } else {
        $msg = Msg::new("The Oracle Clusterware components, the corresponding VCS resource and service groups are as follows:");
        $msg->bold;
        $msg->n;
        $bs1 = '%-15s %-35s %-s';
        $msg_type = Msg::new("Type")->{msg};
        $msg_resource = Msg::new("Resource Name")->{msg};
        $msg_service = Msg::new("Service Group")->{msg};
        $bs = Msg::string_sprintf($bs1, $msg_type, $msg_resource, $msg_service);
        Msg::bold($bs);
        print "=============================================================\n";
        $msg_pip = Msg::new("Private IP")->{msg};
        $msg_ocr = Msg::new("OCR")->{msg};
        $msg_vd = Msg::new("Voting disk")->{msg};
        $bs = Msg::string_sprintf($bs1, $msg_pip, $nicres, $servicegroup[0]);
        Msg::print($bs);
        for my $item (@ocrvolres) {
            $bs = Msg::string_sprintf($bs1, $msg_ocr, $item, $servicegroup[0]);
            Msg::print($bs);
        }
        for my $item (@votevolres) {
            $bs = Msg::string_sprintf($bs1, $msg_vd, $item, $servicegroup[0]);
            Msg::print($bs);
        }
        $msg->n;
        goto DNA_CONFIRMCSSDRES if (Cfg::opt('responsefile'));
        $msg = Msg::new("Do you want to continue?");
        $ayn = $msg->ayny;
    }
    return 1 if ($ayn eq 'N');

DNA_CONFIRMCSSDRES:
    # Change VCS config to read/write
    $ret = $sys->cmd("$vcs->{bindir}/haconf -makerw");
    if ($ret !~ /Cluster already writable/m && EDR::cmdexit()) {
        $msg = Msg::new("Failed to change mode of VCS configuration file to Read/Write. Check logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $msg = Msg::new("Adding CSSD agent to VCS configuration");
    $msg->left;
    $sys->cmd("$vcs->{bindir}/hares -add $cssdres Application $servicegroup[0]");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("Failed to set the CSSD resource (cssd). Refer to the installer logs for more information.");
        if (Obj::webui()) {
             $msg = Msg::new("Failed to set the CSSD resource (cssd). Refer to the installer logs for more information.");
             $web->web_script_form("alert", $msg) if (Obj::webui());
        }
        $msg->print;
        Msg::prtc();
        return 1;
    }
    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres StartProgram /opt/VRTSvcs/rac/bin/cssd-online");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to set StartProgram attribute for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres StopProgram /opt/VRTSvcs/rac/bin/cssd-offline");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to set StopProgram attribute for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres CleanProgram /opt/VRTSvcs/rac/bin/cssd-clean");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to set CleanProgram attribute for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres MonitorProgram /opt/VRTSvcs/rac/bin/cssd-monitor");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to set MonitorProgram attribute for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres Critical 0");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to set Critical attribute to 0 for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    $sys->cmd("$vcs->{bindir}/hares -override $cssdres OnlineWaitLimit");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to override OnlineWaitLimit attribute for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres OnlineWaitLimit 5");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("(Failed to set OnlineWaitLimit attribute to 5 for CSSD agent. Check logs for more information.)");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    Msg::right_done();

    # Identify and add dependencies
    # 1. Add PrivNIC/MultiPrivNIC dependency
    my $status = 1;
    $msg = Msg::new("Setting dependency of the CSSD resource on PrivNIC/MultiPrivNIC resource");
    $msg->left;
    $sys->cmd("$vcs->{bindir}/hares -link $cssdres $nicres");
    if (!EDR::cmdexit()) {
        Msg::right_done();
    } else {
        if (Obj::webui()) {
                $msg = Msg::new("Setting dependency of the CSSD resource on PrivNIC/MultiPrivNIC resource failed");
                $web->web_script_form("alert", $msg) if (Obj::webui());
        }
        Msg::right_failed();
        Msg::prtc();
        return 1;
    }

    # 2. Add (CFSMount for OCR/Vote) XOR (CVMVolDg for OCR and Vote) dependency
    for my $item (@ocrvolres) {
        if ($item ne '') {
            $msg = Msg::new("Setting dependency of the CSSD resource on OCR (CFSMount/CVMVolDg) resource $item");
            $msg->left;
            $ret = $sys->cmd("$vcs->{bindir}/hares -link $cssdres $item");
            if ($ret !~ /VCS WARNING/m && EDR::cmdexit()) {
                if (Obj::webui()) {
                       $msg = Msg::new("Setting dependency of the CSSD resource on OCR (CFSMount/CVMVolDg) resource $item failed");
                       $web->web_script_form("alert", $msg) if (Obj::webui());
                }
                Msg::right_failed();
                Msg::prtc();
                return 1;
            } else {
                Msg::right_done();
            }
        }
    }
    for my $item (@votevolres) {
        if ($item ne '') {
            $msg = Msg::new("Setting dependency of the CSSD resource on Voting disk (CFSMount/CVMVolDg) resource $item");
            $msg->left;
            $ret = $sys->cmd("$vcs->{bindir}/hares -link $cssdres $item");
            if ($ret !~ /VCS WARNING/m && EDR::cmdexit()) {
                if (Obj::webui()) {
                       $msg = Msg::new("Setting dependency of the CSSD resource on Voting disk (CFSMount/CVMVolDg) resource $item failed");
                       $web->web_script_form("alert", $msg);
                }
                Msg::right_failed();
                Msg::prtc();
                return 1;
            } else {
                Msg::right_done();
            }
        }
    }

    # Enable cssd resource
    $msg = Msg::new("Enabling CSSD agent");
    $msg->left;
    $sys->cmd("$vcs->{bindir}/hares -modify $cssdres Enabled 1");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("Failed to enable CSSD resource (cssd). Refer to the installer logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    Msg::right_done();


    # Save configuration
    $msg = Msg::new("Saving the updated VCS configuration");
    $msg->left;
    $ret = $sys->cmd("$vcs->{bindir}/haconf -dump -makero");
    if ($ret !~ /VCS WARNING/m && EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("Failed to save VCS configuration. Check logs for more information.");
        $web->web_script_form("alert", $msg) if (Obj::webui());
        $msg->print;
        Msg::prtc();
        return 1;
    }
    Msg::right_done();

    for my $sys (@{CPIC::get('systems')}) {
        $msg = Msg::new("Disable Oracle Clusterware/Grid Infrastructure auto-startup on $sys->{sys}");
        $msg->left;
        $sys->cmd("$prod->{crs_home}/bin/crsctl disable crs");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            $msg = Msg::new("(Failed to disable Oracle Clusterware/Grid Infrastructure auto-startup on $sys->{sys}.)");
            $msg->log;
        }
        Msg::right_done();
    }

    if (Obj::webui()) {
        $msg = Msg::new("Successfully configured the CSSD resource");
        $web->web_script_form("alert", $msg) if (Obj::webui());
    }
    Msg::prtc();
    return 0;
}

sub install_crs_common {
    my $prod = shift;
    my ($ret, $msg);
    my $preinst = 0;
    my $cfg = Obj::cfg();
    my $web = Obj::web();


DNA_INSTALL_CRS:
    # Vars needed: DISPLAY ORA_CRS_HOME CRS_INSTALLPATH ORACLE_USER
    # ORACLE_GROUP (because create_dir needs it)
    while (1) {
        # DISPLAY
        if (Obj::webui()) {
            $prod->{install_oracle_clusterware} = 1;
            $web->web_script_form("install_oracle_crs", $prod);
            if ($web->param("back") eq "back") {
                $prod->{install_oracle_clusterware} = 0;
                return 1;
            }
            $prod->{install_oracle_clusterware} = 0;
        } elsif (!Cfg::opt('responsefile')) {
            return 1 if ($prod->find_display());
        }
        # ORACLE_USER
        if (Cfg::opt('responsefile') && $prod->{display} eq '') {
            $ret = $prod->validate_display($cfg->{oracle_display});
        } else {
            $ret = $prod->validate_display($prod->{display});
        }
        if ($ret == 1)
        {
            $msg = Msg::new("There are issues using the DISPLAY value you provided. Either the DISPLAY variable has not been set properly or there are display connectivity problems. Refer to the installation logs for more details.");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_INSTALL_CRS ;
            }
            return 1 if (Cfg::opt('responsefile'));
            goto DNA_INSTALL_CRS ;
        }
        $ret = $prod->find_user($preinst);
            return 1 if ($ret == 1);
            return 1 if ($ret == 3);
            goto DNA_INSTALL_CRS if ($ret == 4);

        # ORACLE_GROUP
        $ret = $prod->find_oracle_group($preinst, 1);
            return 1 if ($ret == 1);
            return 1 if ($ret == 3);
            goto DNA_INSTALL_CRS if ($ret == 4);

        # Sanity check for Oracle user cum group
        my $temp_user;
        if ($prod->{grid_user} ne ''){
            $temp_user = $prod->{grid_user};
        } else {
            $temp_user = $prod->{oracle_user};
        }
        
        if ($prod->oracle_sanity($temp_user , $prod->{oracle_group}) == 1) {
            goto DNA_INSTALL_CRS if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # ORACLE_BASE
        if ($prod->find_base('crs')) {
            goto DNA_INSTALL_CRS if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # ORA_CRS_HOME
        if ($prod->find_crs_home('crs_install')) {
            goto DNA_INSTALL_CRS if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # CRS_INSTALLPATH
        if ($prod->find_installpath('crs')) {
            goto DNA_INSTALL_CRS if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # CRS_RELEASE CRS_PATCH_LEVEL
        if ($prod->find_oracle_version('crs', 'crs_install')) {
            goto DNA_INSTALL_CRS if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        $prod->task_title('install_oracle_clusterware') if (!Cfg::opt('responsefile'));
        if (Obj::webui()) {
            my $mesg="";
            $msg = Msg::new("\\nVerify Oracle Clusterware installation information\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("DISPLAY variable: $prod->{display}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle UNIX User: $prod->{oracle_user}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle UNIX Group: $prod->{oracle_group}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle Base: $prod->{oracle_base}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle Clusterware/Grid Infrastructure Home: $prod->{crs_home}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle Clusterware/Grid Infrastructure Installation Path: $prod->{crs_installpath}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle Version: $prod->{crs_release}.$prod->{crs_patch_level}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Is this information correct?\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new($mesg);
            my $ayn = $msg->ayny;
            if ($ayn ne 'n' && $ayn ne 'N') {
                last;
            } else {
                goto DNA_INSTALL_CRS;
            }

        } else {
            $msg = Msg::new("Verify Oracle Clusterware installation information");
            $msg->bold;
            $msg = Msg::new("\n\tDISPLAY variable: $prod->{display}");
            $msg->print;

            if ($prod->{grid_user} ne '') {
                $msg = Msg::new("\tOracle UNIX User: $prod->{grid_user}");
            } else {
                $msg = Msg::new("\tOracle UNIX User: $prod->{oracle_user}");
            }
            $msg->print;

            $msg = Msg::new("\tOracle UNIX Group: $prod->{oracle_group}");
            $msg->print;

            if ($prod->{grid_base} ne '') {
                $msg = Msg::new("\tGrid Base: $prod->{grid_base}");
            } else {
                $msg = Msg::new("\tOracle Base: $prod->{oracle_base}");
            }
            $msg->print;

            $msg = Msg::new("\tOracle Clusterware/Grid Infrastructure Home: $prod->{crs_home}");
            $msg->print;
            $msg = Msg::new("\tOracle Clusterware/Grid Infrastructure Installation Path: $prod->{crs_installpath}");
            $msg->print;
            $msg = Msg::new("\tOracle Version: $prod->{crs_release}.$prod->{crs_patch_level}");
            $msg->print;

            if (Cfg::opt('responsefile')) {
                $msg = Msg::new("\tOracle Clusterware/Grid Infrastructure installation response file: $cfg->{crs_responsefile}");
                $msg->print;
            }

            last if (Cfg::opt('responsefile'));
            $msg = Msg::new("\nIs this information correct?");
            my $ayn = $msg->ayny;
            if ($ayn ne 'n' && $ayn ne 'N') {
                last;
            }

        }
    }
    if (!Cfg::opt('responsefile')) {
        if ($prod->{crs_release} =~ /11.2/m){
            $cfg->{grid_user} = $prod->{oracle_user};
        } else {
            $cfg->{oracle_user} = $prod->{oracle_user};
        }
        $cfg->{oracle_group} = $prod->{oracle_group};
        $cfg->{crs_home} = $prod->{crs_home};
        if ($prod->{crs_release} =~ /11.2/m){
            $cfg->{grid_base} = $prod->{oracle_base};
        } else {
            $cfg->{oracle_base} = $prod->{oracle_base};
        }
        $cfg->{crs_installpath} = $prod->{crs_installpath};
    }

    return 0;
}

sub invoke_oui_installer {
    my ($prod, $release, $patch_level, $instpath, $homedir, $oraprod, $temp_user) = @_;
    my ($msg, $prod_str, $oui_args, $run_cmd, $ret);
    my $tmpdir=EDR::tmpdir();
    my $bs=EDR::get2('tput','bs');
    my $be=EDR::get2('tput','be');
    my $edrprtc=EDR::get2('msg','prtc');
    my $cfg = Obj::cfg();
    my $web = Obj::web();
    my $localsys = $prod->localsys;

    if ($oraprod eq 'db') {
        $prod_str = 'Oracle Database';
    } else {
        $prod_str = 'Oracle Clusterware';
    }

    $msg = Msg::new("Starting Oracle Universal Installer...\nSee the logs in $tmpdir/install.oracle.${oraprod}.log");
    $msg->print;
    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());

    # Prepare the command with arguments for starting Oracle installer

    # get the OUI_ARGS environment variable to be passed to the Oracle installer.
    # We can pass the following options along with other options:
    # -ignoreSysPrereqs
    # -ignorePrereq
    # -ignoreInternalDriverError
    $oui_args = $ENV{'OUI_ARGS'};
    $oui_args = $prod->{oui_args_web} if (Obj::webui());
    chomp($oui_args);
    $oui_args = $oui_args."$prod->{oui_args}";

    if (Cfg::opt('responsefile')) {
        # Oracle silent installation using the response file
        if ($oraprod eq 'crs') {
            $oui_args = $oui_args.' -formCluster';
            if ($prod->{grid_base} ne '') {
                $oui_args = $oui_args." ORACLE_BASE=$prod->{grid_base}";
            } else {
                $oui_args = $oui_args." ORACLE_BASE=$prod->{oracle_base}";
            }
        } else {
            $oui_args = $oui_args." ORACLE_BASE=$prod->{oracle_base}";
        }
        $oui_args = $oui_args.' -waitforcompletion -silent -responseFile '.$cfg->{${oraprod}.'_responsefile'};
        $oui_args = $oui_args." UNIX_GROUP_NAME=$cfg->{oracle_group}";
        $oui_args = $oui_args." ORACLE_HOME=$homedir";
        $oui_args = $oui_args." FROM_LOCATION=$instpath/stage/products.xml";
            if ($oraprod eq 'db') {
            $oui_args = $oui_args.' n_configurationOption=3';
        }
    } else {
        # Interactive Oracle installation using the OUI
        # for non 11gR2 releases.
        if ($release !~ /11.2/m) {
            EDR::cmd_local("_cmd_touch $tmpdir/install.${oraprod}_responsefile");
            EDR::cmd_local("_cmd_chown $temp_user:$prod->{oracle_group} $tmpdir/install.${oraprod}_responsefile");
            EDR::cmd_local("_cmd_chmod 777 $tmpdir/install.${oraprod}_responsefile");
            $oui_args = $oui_args." -record -destinationFile $homedir/install.${oraprod}_responsefile";
        }

        $run_cmd = $run_cmd."ORACLE_BASE=$prod->{oracle_base};export ORACLE_BASE;";
        $run_cmd = $run_cmd."ORACLE_HOME=$homedir;export ORACLE_HOME;";
    }
    $run_cmd = $run_cmd."$prod->{oui_export}";
    if (!Cfg::opt('responsefile')) {
        # DISPLAY required for interactive installation
        $run_cmd = $run_cmd."DISPLAY=$prod->{display};export DISPLAY;";
    }
    my $envlang=EDR::get('envlang');
    $run_cmd = $run_cmd."LC_ALL=$envlang;export LC_ALL;";
    $run_cmd = $run_cmd."$instpath/$prod->{oracle_install_script} $oui_args";

    if (!Cfg::opt('responsefile')) {
        EDR::cmd_local("_cmd_rm -f $tmpdir/install.oracle.${oraprod}.log 2>/dev/null");
    }
    EDR::cmd_local("_cmd_touch $tmpdir/install.oracle.${oraprod}.log");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("Failed to create $tmpdir/install.oracle.${oraprod}.log");
        $msg->log;
        return 1;
    }

    # Start the Oracle installer
    $msg = Msg::new("Invoking runInstaller with command: $run_cmd\n");
    $msg->log;
    $prod->save_term;
    EDR::cmd_local("_cmd_rm -f $tmpdir/prerootsh 2>/dev/null");
    chdir('/tmp');

    $msg=Msg::new("User is: $temp_user");
    $msg->log;
    EDR::cmd_local("_cmd_su $temp_user -c '$run_cmd' > $tmpdir/install.oracle.${oraprod}.log 2>&1; _cmd_touch $tmpdir/prerootsh");
    $ret = EDR::cmdexit(); # Can be set due to any of 'su' or '$run_cmd' failures
    $prod->restore_term;
    if (Cfg::opt('responsefile') && $oraprod eq 'crs') {
        # Wait for the Oracle installer to complete the installation
        # When the installer exits, we touch the file preroot.sh
        # The installation can take more than EDR timeout for any
        # command execution, hence cannot depend on the return value of
        # the cmdexit
        # In addition check for root.sh file to confirm the successful
        # installation

        while (!$localsys->exists("$tmpdir/prerootsh")) {
            sleep 10;
        }
        if (!$localsys->exists("$homedir/root.sh")) {
            Msg::log("root.sh cannot be located on $sys->{sys} at $homedir/");
            return 1;
        }

        # Execute orainstRoot.sh file if prompted by the installer
        open(CRSLOG, '< '."$tmpdir/install.oracle.${oraprod}.log");
        my (@line) = grep(/orainstRoot.sh/, <CRSLOG>);
        for my $item (@line) {
            my (@strs) = split(/ /m, $item);
            for my $str (@strs) {
                $exestr = $1 if($str =~ /(\/.*\.sh)/m);
            }
        }
        if ($localsys->exists($exestr)) {
            for my $sys (@{CPIC::get('systems')}) {
                if (!$sys->{islocal}) {
                    if (!$sys->exists($exestr)) {
                        $localsys->copy_to_sys($sys, $exestr);
                    }
                }
                $msg = Msg::new("Executing $exestr on $sys->{sys}");
                $msg->left;
                $sys->cmd("$exestr");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    $msg = Msg::new("(The execution of $exestr script failed on $sys->{sys}. For installation to end successfully, Oracle requires you to run the $exestr. Run it manually on this systems as root user.)");
                    $msg->print;
                    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                    Msg::prtc();
                } else {
                    Msg::right_done();
                }
            }
        }

        # Execute root.sh file
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Executing $homedir/root.sh on $sys->{sys}");
            $msg->left;
            $sys->cmd("$homedir/root.sh");
            if (EDR::cmdexit()) {
                Msg::right_failed;
                $msg = Msg::new("(The execution of root.sh script failed on $sys->{sys}.For installation to end successfully, Oracle requires you to run the $homedir/root.sh. Run it manually on this systems as root user.)");
                $msg->print;
                Msg::prtc();
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            } else {
                Msg::right_done;
            }
        }
        # Verify if the node apps are created
        $line = $localsys->cmd("$homedir/bin/crs_stat -t 2> /dev/null");
        if (!EDR::cmdexit()) {
            $crs_up = 1;
            while (1) {
                $line = $localsys->cmd("$homedir/bin/crs_stat -t 2> /dev/null| _cmd_grep 'No resources are registered'");
                if (!EDR::cmdexit()) {
                    $msg = Msg::new("\nExecution of vipca failed\nDo the following steps as a superuser:\n\t 1. Set the DISPLAY environment variable\n\t 2. Run the command '$homedir/bin/vipca'\nOn completion, proceed to complete the installation of Oracle Clusterware");
                    if (Obj::webui()) { 
                        $web->web_script_form("alert", $msg->{msg}) ;
                        last;
                    } else {
                        $msg->bold;
                        print "\n$bs$edrprtc$be";
                        $prtc = <STDIN>;
                        chomp($prtc);
                        my $edrquit=EDR::get2('key','quit');
                        if ($prtc=~/^$edrquit$/mi) {
                            $ayn=Msg::confirm_quit();
                            if ($ayn) {
                                $msg=Msg::new("User entered $ayn: exiting");
                                $msg->log;
                                EDR::exit_exitfile();
                            }
                        }
                    }
                } else {
                    last;
                }

            }
        }

        # Execute configToolAllCommands file if prompted by the installer
        open(CRSLOG, '< '."$tmpdir/install.oracle.${oraprod}.log");
        @line = grep(/configToolAllCommands/, <CRSLOG>);
        for my $item (@line) {
            my (@strs) = split(/ /m, $item);
            for my $str (@strs) {
                $exestr = $1 if($str =~ /(\/.*configToolAllCommands)/mx);
            }
        }
        if ($localsys->exists($exestr)) {
            $msg = Msg::new("Executing $exestr");
            $msg->left;
            chdir('/tmp');
            $msg=Msg::new("User is: $temp_user");
            $msg->log;
            $localsys->cmd("_cmd_su $temp_user -c '$exestr'");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $msg = Msg::new("(The execution of $exestr failed. For installation to end successfully, Oracle requires you to run the $exestr. Run it manually on this systems as '$temp_user' user.)");
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                Msg::prtc();
            } else {
                Msg::right_done;
            }
        }
    }
    if (Cfg::opt('responsefile') && $oraprod eq 'db') {
        while (!$localsys->exists("$tmpdir/prerootsh")) {
            sleep 10;
        }
        if (!$localsys->exists("$homedir/root.sh")) {
            Msg::log("root.sh cannot be located on $sys->{sys} at $homedir/");
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            return 1;
        }
    }

    EDR::cmd_local("_cmd_rm -f $tmpdir/prerootsh 2>/dev/null");

    # Sleep here because ora_output file does not get written to
    # immediately. 10 seconds is just some arbitrary number. May need to tune this.
    sleep(10);

    if ($ret != 0) {
        Msg::right_failed();
        $msg = Msg::new("\nFailed to start OUI for installing Oracle Clusterware/Grid Infrastructure\n");
        $msg->log;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    } else {
        EDR::cmd_local("_cmd_grep -Ew 'InternalError|OUI-10025|X11|OUI-10026|OUI-10027|xclock|DISPLAY|X11' $tmpdir/install.oracle.${oraprod}.log > /dev/null");
        if (EDR::cmdexit() == 0) {
            Msg::right_failed();
            $msg = Msg::new("\nFailed to start OUI for installing Oracle Clusterware/Grid Infrastructure. See $tmpdir/install.oracle.${oraprod}.log for more details.\n");
            $msg->log;
            $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
            return 1;
        } else {
            if (Cfg::opt('responsefile') && $oraprod eq 'db') {
                $msg = Msg::new("Check the $prod->{abbr}/Oracle DB installation logs to find whether the Oracle DB installation was successful.\nYou may need to run root.sh etc scripts to complete the installation. This can be done after the silent installation for $prod->{abbr} exits.");
                $msg->bold;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                Msg::prtc();
            }
        }
    }

    return 0;
}

sub install_oracle_database {
    my $prod= shift;
    my ($ret, $msg);
    my $tmpdir=EDR::tmpdir();
    my $bs=EDR::get2('tput','bs');
    my $be=EDR::get2('tput','be');
    my $edrquit=EDR::get2('key','quit');
    my $edrprtc=EDR::get2('msg','prtc');
    my $cfg = Obj::cfg();
    my $localsys = $prod->localsys;
    my $web = Obj::web();

    return 0 if (Cfg::opt('responsefile') && $cfg->{install_oracle_database} == 0);
    $cfg->{install_oracle_database} = 1;
    $prod->task_title('install_oracle_database');

    $ret = $prod->install_db_common();
    if ($ret) {
        return 1;
    }

    # Check if Oracle Clusterware is running.
    if (!$prod->is_crs_up(CPIC::get('systems'))) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure is down on one or more nodes. Cannot proceed with Oracle Installation.\nStart Oracle Clusterware/Grid Infrastructure  on all the nodes and then try again.");
        $msg->log;
        $msg->print;
        Msg::prtc();
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    }

    $msg = Msg::new("\n\t\t\t\tORACLE DATABASE INSTALLATION\n");
    $msg->bold;

    if ($prod->can('set_db_install_env')) {
        $ret = $prod->set_db_install_env();
        if ($ret != 0) {
            $msg = Msg::new("\nOne or more steps failed above. Cannot proceed with the Installation.");
            $msg->print;
            Msg::prtc();
            if (Obj::webui())
            {
                $msg = Msg::new("\nOne or more steps failed in setting the Database install environment. Cannot proceed with the Installation.");
                $web->web_script_form("alert", $msg->{msg});
            }
            return 1;
        }
    }
    $ret = $prod->invoke_oui_installer($prod->{db_release}, $prod->{db_patch_level},
                                       $prod->{db_installpath}, $prod->{db_home}, 'db',
                                       $prod->{oracle_user});
    if ($ret != 0) {
        $msg = Msg::new("\nOracle installation failed. See the logs for details.");
        $msg->print;
        Msg::prtc();
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    }

    if (!Cfg::opt('responsefile')) {
        $msg = Msg::new("Press <RETURN> here after completing the installation from OUI:");
        print "\n$bs$msg->{msg}$be ";
        <STDIN>;
    }
    if (Obj::webui()) {
        $msg = Msg::new("Click <OK> here after completing the installation from OUI:");
        $web->web_script_form("alert", $msg->{msg});
    }

    #
    # Verify that the binaries have been installed in db_home.
    #
    $ret = $prod->verify_home_dirs($prod->{db_home});
    if ($ret != 0) {
        $msg = Msg::new("\nOracle Database binaries are not installed properly");
        $msg->print;
        Msg::prtc();
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    }

    my $ayn;
    if (Cfg::opt('responsefile')) {
        $msg = Msg::new("\n You need to run $prod->{db_home}/root.sh script to complete the installation");
        $msg->print;
        print "\n$bs$edrprtc$be";
        $prtc = <STDIN>;
        chomp($prtc);
        if ($prtc=~/^$edrquit$/mi) {
            $ayn=Msg::confirm_quit();
            if ($ayn) {
                $msg=Msg::new("User entered $ayn: exiting");
                $msg->log;
                EDR::exit_exitfile();
            }
        }
        $ayn = 'N';
    } else {
        if ($prod->{db_release} !~ /11.2/m) {
            # Copying the responsefile created for DB installation
            $localsys->copyfile("$prod->{db_home}/install.db_responsefile","$tmpdir/install.db_responsefile") if (!Cfg::opt('responsefile'));
        }
            $msg = Msg::new("\nYou must relink Oracle with $prod->{abbr} libraries in order to complete Oracle installation\nDo you wish to link Oracle now?");
            $ayn = $msg->ayny;
    }
    if (!Cfg::opt('responsefile')) {
        if (($ayn eq 'N') || ($ayn eq 'n')) {
            $cfg->{relink_oracle_database} = 0;
        } else {
            $cfg->{relink_oracle_database} = 1;
        }
    }
    return 0 if (($ayn eq 'N') || ($ayn eq 'n'));

    $ret = $prod->relink_crs();
    if ($ret != 0) {
        Msg::prtc();
        return 1;
    }
    $msg = Msg::new("Relinking Oracle Database");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    $ret = $prod->relink_oracle();
    if ($ret != 0) {
        $msg = Msg::new("\nOracle relinking failed on one or more systems");
        $msg->print;
        Msg::prtc();
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 0;
    }

    $msg = Msg::new("\nOracle relinking is now complete");
    $msg->print;
    Msg::prtc();
    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());

    return 0;
}

sub install_db_common {
    my $prod = shift;
    my ($ret, $msg);
    my $preinst = 0;
    my $cfg = Obj::cfg();
    my $web = Obj::web();

DNA_INSTALL_DB:
    while(1) {
        # DISPLAY
        if (Obj::webui()) {
            $prod->{install_oracle_database} = 1;
            $web->web_script_form("install_oracle_db", $prod);
            if ($web->param("back") eq "back") {
                $prod->{install_oracle_database} = 0;
                return 1;
            }
                $prod->{install_oracle_database} = 0;
        } elsif (!Cfg::opt('responsefile')) {
            return 1 if ($prod->find_display());
        }
        # ORACLE_USER
        if (Cfg::opt('responsefile') && $prod->{display} eq '') {
            $ret = $prod->validate_display($cfg->{oracle_display});
        } else {
            $ret = $prod->validate_display($prod->{display});
        }
        if ($ret == 1)
        {
            $msg = Msg::new("There are issues using the DISPLAY value you provided. Either the DISPLAY variable has not been set properly or there are display connectivity problems. Refer to the installation logs for more details.");
            $msg->print;
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg}) ;
                goto DNA_INSTALL_DB ;
            }
            return 1 if (Cfg::opt('responsefile'));
            goto DNA_INSTALL_DB ;
        }

        # ORACLE_USER
        $ret = $prod->find_oracle_user($preinst);
            return 1 if ($ret == 1);
            return 1 if ($ret == 3);
            goto DNA_INSTALL_DB if ($ret == 4);

        # ORACLE_GROUP
        $ret = $prod->find_oracle_group($preinst, 1);
            return 1 if ($ret == 1);
            return 1 if ($ret == 3);
            goto DNA_INSTALL_DB if ($ret == 4);

        # Sanity check for Oracle user cum group
        if ($prod->oracle_sanity($prod->{oracle_user}, $prod->{oracle_group}) == 1) {
            goto DNA_INSTALL_DB if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # ORACLE_BASE
        if ($prod->find_base('db')) {
            goto DNA_INSTALL_DB if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # ORA_CRS_HOME
        if ($prod->determine_crs_home('post_crs_install')) {
            goto DNA_INSTALL_DB if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # DB_HOME
        if ($prod->find_db_home('db_install')) {
            goto DNA_INSTALL_DB if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # DB_INSTALLPATH
        if ($prod->find_installpath('db')) {
            goto DNA_INSTALL_DB if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        # DB_RELEASE DB_PATCH_LEVEL
        if ($prod->find_oracle_version('db', 'db_install')) {
            goto DNA_INSTALL_DB if (Obj::webui());
            return 1 if (!Obj::webui());
        }

        $prod->task_title('install_oracle_database') if (!Cfg::opt('responsefile'));
        if (Obj::webui()) {
            my $mesg="";
            $msg = Msg::new("\\nVerify Oracle database installation information\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("DISPLAY variable: $prod->{display}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle UNIX User: $prod->{oracle_user}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle UNIX Group: $prod->{oracle_group}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle Base: $prod->{oracle_base}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Oracle Clusterware/Grid Infrastructure Home: $prod->{crs_home}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("\tOracle Database Home: $prod->{db_home}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("\tOracle Database Installation Path: $prod->{db_installpath}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("\tOracle Version: $prod->{db_release}.$prod->{db_patch_level}\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new("Is this information correct?\\n");
            $mesg .=$msg->{msg}; 
            $msg = Msg::new($mesg);
            my $ayn = $msg->ayny;
            if ($ayn ne 'n' && $ayn ne 'N') {
                return 0;
            } else {
                goto DNA_INSTALL_DB;
            }


        } else {

            $msg = Msg::new("Verify Oracle database installation information");
            $msg->bold;
            if ( !Cfg::opt('responsefile')) {
                $msg = Msg::new("\n\tDISPLAY variable: $prod->{display}");
                $msg->print;
            }
            $msg = Msg::new("\tOracle UNIX User: $prod->{oracle_user}");
            $msg->print;
            $msg = Msg::new("\tOracle UNIX Group: $prod->{oracle_group}");
            $msg->print;
            $msg = Msg::new("\tOracle Base: $prod->{oracle_base}");
            $msg->print;
            $msg = Msg::new("\tOracle Clusterware/Grid Infrastructure Home: $prod->{crs_home}");
            $msg->print;
            $msg = Msg::new("\tOracle Database Home: $prod->{db_home}");
            $msg->print;
            $msg = Msg::new("\tOracle Database Installation Path: $prod->{db_installpath}");
            $msg->print;
            $msg = Msg::new("\tOracle Version: $prod->{db_release}.$prod->{db_patch_level}");
            $msg->print;

            if (Cfg::opt('responsefile')) {
                $msg = Msg::new("\tOracle Database installation response file: $cfg->{db_responsefile}");
                $msg->print;
            }
            $msg->n;

            last if (Cfg::opt('responsefile'));
            $msg = Msg::new("Is this information correct?");
            my $ayn = $msg->ayny;
            if ($ayn ne 'n' && $ayn ne 'N') {
                last;
            }
        }
    }
    if (!Cfg::opt('responsefile')) {
        $cfg->{oracle_user} = $prod->{oracle_user};
        $cfg->{oracle_group} = $prod->{oracle_group};
        $cfg->{crs_home} = $prod->{crs_home};
        $cfg->{db_home} = $prod->{db_home};
        $cfg->{oracle_base} = $prod->{oracle_base};
        $cfg->{db_installpath} = $prod->{db_installpath};
    }

    return 0;
}

sub find_display {
    my $prod = shift;
    my ($answer,$help,$backopt,$question);
    my $web = Obj::web();

    $help = '';
    $backopt = 1;
    
    if (!Obj::webui())
    {
        $question = Msg::new("Enter DISPLAY environment variable:");
        $answer = $question->ask($prod->{display}, $help, $backopt);
    } elsif (!Obj::webui()){
        $answer = $prod->{display} ;
    }

    return 3 if (EDR::getmsgkey($answer,'back'));
    chomp($answer);
    $prod->{display} = $answer;
    return 0;
}

# Validate the Oracle user/group names for the following:
# 1) Should not contain special characters
# 2) Should not start with Numbers
# 3) Should be limited to 9 characters
# 4) Should not be an VCS reserved word
sub validate_oraugname {
    my ($prod, $name) = @_;
    my ($maxlen, $msg, $word);
     my $web = Obj::web();
    $maxlen = `/usr/bin/getconf LOGIN_NAME_MAX`;
    chomp($maxlen);

    if ($name !~ /^[a-zA-Z|_][0-9a-zA-Z|\-|\_]*$/mx) {
        $msg = Msg::new("Invalid name chosen. Input again");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    }

    if (check_vcs_reswords($name)) {
        $msg = Msg::new("The chosen name: $name is a VCS reserved word. Input again");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    }

    if ($maxlen < length($name)) {
        $msg = Msg::new("The chosen name cannot exceed $maxlen characters. Input again");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        return 1;
    }

    return 0;
}

# This is only for Oracle Grid Infrastructure/Clusterware installation
sub find_user {
    my $prod = shift;
    my $preinst = shift;
    my $ret1=0, $ret2=0;
    my $cfg = Obj::cfg();

    if (Cfg::opt('responsefile')) {
        if ($cfg->{install_oracle_clusterware} && $cfg->{grid_user} ne '') {
            $ret1 = $prod->find_grid_user($preinst);
        }

        if ($cfg->{oracle_user} ne '') {
            $ret2 = $prod->find_oracle_user($preinst);
        }

        return 1 if ($ret1 !=0 && $ret1 != 2);
        return 1 if ($ret2 !=0 && $ret2 != 2);
    } else {
	$ret1 = $prod->find_oracle_user($preinst);
        $prod->{grid_user} = $prod->{oracle_user};
        return $ret1;
    }

    return 0;
}
# Return 0: Either Oracle user is alright, or user has asserted to take care of it manually.
# Return 1: Things are bad, don't use $prod->{oracle_user} for purposes.
# Return 2: Oracle user already exists on all the nodes with same config
# Return 3: Back opt
#
# Note (AIX):
# By default, AIX 5.3 has a user name length limitation of 8 characters,
# regardless of the back end authentication mechanism.
#
# To confirm this, run:
# getconf LOGIN_NAME_MAX
# or
# lsattr -El sys0 -a max_logname
#
# To set the size limitation to a new (higher) value,
# run (where # is the new maximum user name length):
# chdev -l sys0 -a max_logname=#
sub find_oracle_user {
    my $prod = shift;
    my $preinst = shift;
    my ($answer,$help,$msg,$backopt,$question);
    my $cfg = Obj::cfg();
    my $ret;
    my $uid = '0';

    $help = '';
    $backopt = 1;

    # For oracle user
    while (1) {
        if (Cfg::opt('responsefile')) {
            return 1 if ($prod->validate_oraugname($cfg->{oracle_user}));
            $answer = $cfg->{oracle_user};
            return 3 if (EDR::getmsgkey($answer,'back'));
        } else {
            if (!(Obj::webui())){
                $question = Msg::new("Enter Oracle UNIX user name:");
                $answer = $question->ask($prod->{oracle_user}, $help, $backopt);
                return 3 if (EDR::getmsgkey($answer,'back'));
                chomp($answer);
                next if ($prod->validate_oraugname($answer));
            }
            else
            {
                $answer = $cfg->{oracle_user};
                my $ret = $prod->validate_oraugname($answer);
                if ($ret !=0)
                {
                    return 4; # returning 4 in case of webinstaller to go back to the same form.
                }

            }

        }

        $ret = $prod->validate_orauser($answer, $uid, CPIC::get('systems'));
        if ($ret == 0) {
            $prod->{oracle_user} = $answer;
            last;
        } elsif ($ret == 1) {
            $msg = Msg::new("Oracle user '$answer' already exists on a subset of the nodes with the same UIDs on those nodes. In order to use this user for Oracle installation, it must exist on all the nodes. Create the user manually on nodes where it is not present or choose a different user.");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            $msg = Msg::new("Restart current task? (Answering 'No' means you will manually create the user on the remaining nodes before the installation of Oracle Clusterware/Grid Infrastructure or database)");
            $msg = Msg::new("Oracle user '$answer' already exists on a subset of the nodes with the same UIDs on those nodes. In order to use this user for Oracle installation, it must exist on all the nodes. Create the user manually on nodes where it is not present or choose a different user. Restart current task? (Answering 'No' means you will manually create the user on the remaining nodes before the installation of Oracle Clusterware/Grid Infrastructure or database)") if(Obj::webui());
            my $ayn = $msg->ayny;
            if ($ayn eq 'Y')
            {
                if(Obj::webui())
                {
                    return 4;
                }
                else
                {
                    next;
                }
            } 
            $prod->{oracle_user} = $answer;
            return 3;
        } elsif ($ret == 2) {
            $prod->{oracle_user} = $answer;
            return 2;
        } elsif ($ret == 3) {
            $msg = Msg::new("Oracle user '$answer' has different UIDs on some systems. Correct the UIDs manually. Refer to the installer logs for more information.");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            $msg = Msg::new("Restart current task? (Answering 'No' means you will manually correct the UIDs on all nodes before the installation of Oracle Clusterware/Grid Infrastructure or database)");
            $msg = Msg::new("Oracle user '$answer' has different UIDs on some systems. Correct the UIDs manually. Refer to the installer logs for more information. Restart current task? (Answering 'No' means you will manually create the user on the remaining nodes before the installation of Oracle Clusterware/Grid Infrastructure or database)") if(Obj::webui());
            my $ayn = $msg->ayny;
            if ($ayn eq 'Y')
            {
                if(Obj::webui())
                {
                    return 4;
                }
                else
                {
                    next;
                }
            } 
            return 3;
        }
    }

    return 0;
}

sub find_grid_user {
    my $prod = shift;
    my $preinst = shift;
    my ($answer,$help,$msg,$backopt,$question);
    my $cfg = Obj::cfg();
    my $ret;
    my $uid = '0';

    $help = '';
    $backopt = 1;

    $grid_user = $cfg->{grid_user};
    if ($grid_user ne '') {
        return 1 if ($prod->validate_oraugname($cfg->{grid_user}));
        $answer = $grid_user;
        return 3 if (EDR::getmsgkey($answer,'back'));
    }

    $ret = $prod->validate_orauser($answer, $uid, CPIC::get('systems'));
    if ($ret == 0) {
        $prod->{grid_user} = $answer;
        return 0;
    } elsif ($ret == 1) {
        $msg = Msg::new("Oracle user '$answer' already exists on a subset of the nodes with the same UIDs on those nodes. In order to use this user for Oracle installation, it must exist on all the nodes. Create the user manually on nodes where it is not present or choose a different user.");
        $msg->print;
        return 1;
    } elsif ($ret == 2) {
        $msg = Msg::new("User $answer already exists on all the nodes with the same configuration");
        $msg->log;
        $prod->{grid_user} = $answer;
        return 2;
    } elsif ($ret == 3) {
        $msg = Msg::new("Oracle user '$answer' has different UIDs on some systems. Correct the UIDs manually. Refer to the installer logs for more information.");
        $msg->print;
        return 1;
    }

    return 0;
}
# Return 0: Either Oracle group is alright, or user has asserted to take care of it manually.
# Return 1: Things are bad, don't use $prod->{oracle_group} for purposes.
# Return 2: Oracle group already exists on all the nodes with same config
# Return 3: Back opt
sub find_oracle_group {
    my $prod = shift;
    my $preinst = shift;
    my $ary = shift; # Primary, secondary, tertiary... group
    my ($answer, $help, $msg, $backopt, $question, $suggestion);
    my $cfg = Obj::cfg();
    my $ret;
    my $gid = '0';

    $help = '';
    $backopt = 1;
    if ($ary == 1) {
        $suggestion = $prod->{oracle_group};
    } elsif ($ary == 2) {
        $suggestion = 'dba, oper etc.';
    }

    while (1) {
        if (Cfg::opt('responsefile')) {
            return 1 if ($prod->validate_oraugname($cfg->{oracle_group}));
            $answer = $cfg->{oracle_group};
            return 3 if (EDR::getmsgkey($answer,'back'));
        } else {
            if (!(Obj::webui())){
                $question = Msg::new("Enter Oracle UNIX group name:");
                $answer = $question->ask($suggestion, $help, $backopt);
                return 3 if (EDR::getmsgkey($answer,'back'));
                chomp($answer);
                next if ($prod->validate_oraugname($answer));
            }
            else
            {
                              
                if ($ary == 1) {
                    $answer = $cfg->{oracle_group};
                } elsif ($ary == 2) {
                    $answer = pop (@{$cfg->{oracle_secondary_group}});;
                }
                my $ret = $prod->validate_oraugname($answer);
                if ($ret !=0)
                {
                    return 4; # returning 4 in case of webinstaller to go back to same form.
                }
            }
        }
        $ret = $prod->validate_oragroup($answer, $gid, CPIC::get('systems'));
        if ($ret == 0) {
            $prod->{oracle_group} = $answer;
            last;
        } elsif ($ret == 1) {
            $msg = Msg::new("Oracle group $answer already exists on a strict subset of the nodes, but has same GID on all nodes. For using this group for Oracle installation, it should exist on all the nodes. Create the group manually on those nodes where it is not present and make the Oracle user a part of it or choose a different group of which Oracle user is already a part.");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            $msg = Msg::new("Restart current task? (Answering 'No' means you will manually take care of this before proceeding to the installation of Oracle Clusterware/Grid Infrastructure or database)");
            $msg = Msg::new("Oracle group $answer already exists on a strict subset of the nodes, but has same GID on all nodes. For using this group for Oracle installation, it should exist on all the nodes. Create the group manually on those nodes where it is not present and make the Oracle user a part of it or choose a different group of which Oracle user is already a part. Restart current task? (Answering 'No' means you will manually create the user on the remaining nodes before the installation of Oracle Clusterware/Grid Infrastructure or database)") if(Obj::webui());
            my $ayn = $msg->aynn;
            if ($ayn eq 'Y')
            {
                if(Obj::webui())
                {
                    return 4;
                }
                else
                {
                    next;
                }
            } 
            $prod->{oracle_group} = $answer;
        } elsif ($ret == 2) {
            $msg = Msg::new("Group $answer already exists on all the nodes with the same configuration");
            $msg->log;
            $prod->{oracle_group} = $answer;
            return 2;
        } elsif ($ret == 3) {
            $msg = Msg::new("Oracle group $answer has different GID on some systems. This needs to be manually corrected. Refer to the installer logs for more information.");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            $msg = Msg::new("Restart current task? (Answering 'No' means you will manually take care of this before proceeding to the installation of Oracle Clusterware/Grid Infrastructure or database)");
            $msg = Msg::new("Oracle group $answer has different GID on some systems. This needs to be manually corrected. Refer to the installer logs for more information. Restart current task? (Answering 'No' means you will manually create the user on the remaining nodes before the installation of Oracle Clusterware/Grid Infrastructure or database)") if(Obj::webui());
            my $ayn = $msg->ayny;
            if ($ayn eq 'Y')
            {
                if(Obj::webui())
                {
                    return 4;
                }
                else
                {
                    next;
                }
            } 
            return 1;
        }
    }

    return 0;
}

sub find_installpath {
    my ($prod, $oraprod) = @_;
    my ($str,$answer,$help,$msg,$backopt,$question);
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    return 1 if ($oraprod ne 'crs' && $oraprod ne 'db');

    if ($oraprod eq 'crs') {
        $str = 'Clusterware';
    } else {
        $str = 'Database';
    }

    $help = '';
    $backopt = 1;

    while (1) {
        if (Cfg::opt('responsefile')) {
            if ($oraprod eq 'crs') {
                $answer = $cfg->{crs_installpath};
            } elsif ($oraprod eq 'db') {
                $answer = $cfg->{db_installpath};
            }
        } elsif (!Obj::webui()){
            $question = Msg::new("Enter absolute path of Oracle $str install image:");
            $answer = $question->ask($prod->{$oraprod.'_installpath'}, $help, $backopt);
        } elsif (Obj::webui()){
            $answer = $prod->{$oraprod.'_installpath'};
        }


        return 3 if (EDR::getmsgkey($answer,'back'));

        chomp($answer);

        if (! -d $answer) {
            $msg = Msg::new("$answer: No such directory. Input again");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            if (Obj::webui()) {
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            next;
        }

        if (! -e $answer."/$prod->{oracle_install_script}") {
            $msg = Msg::new("Cannot find $answer/$prod->{oracle_install_script} in ${answer}. Input again");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            if (Obj::webui()) {
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            next;
        }

        $prod->{$oraprod.'_installpath'} = $answer;
        if ($oraprod eq 'crs') {
            $cfg->{crs_installpath} = $answer if (!Cfg::opt('responsefile'));
        } elsif ($oraprod eq 'db') {
            $cfg->{db_installpath} = $answer if (!Cfg::opt('responsefile'));
        }

        last;
    }

    return 0;
}

# If called from a responsefile we prefer the version which is discovered
# than the one mentioned in the responsefile
sub find_oracle_version {
    my ($prod, $oraprod, $opr) = @_;
    my ($ret, $str, $msg, $answer,$help,$backopt,$question);
    my (@digits, $release, $patch_level);
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    if (($oraprod ne 'crs' && $oraprod ne 'db') ||
            ($opr ne 'crs_install' && $opr ne 'db_install' && $opr ne 'relink')) {
        return 1;
    }

    if ($opr eq 'crs_install' || $opr eq 'db_install') {
        $ret = $prod->get_oraver_from_xml($oraprod);
    } else {
        $ret = $prod->get_oraver_from_opatch($oraprod, 'Oracle Database');
    }

    $help = '';
    $backopt = 1;

    if (!$ret) {
        my $oraprod_release=$prod->{$oraprod.'_release'};
        my $oraprod_patch_level=$prod->{$oraprod.'_patch_level'};

        if (!Cfg::opt('responsefile')) {
            $msg = Msg::new("Oracle Version Detected: $oraprod_release.$oraprod_patch_level");
            $msg->print;
        }
        return 0 if (Cfg::opt('responsefile') && ($cfg->{oracle_version}));
        $msg = Msg::new("Do you want to continue?");
        $msg = Msg::new("Oracle Version Detected: $oraprod_release.$oraprod_patch_level\\n \\nDo you want to continue?") if (Obj::webui());
        my $ayn = $msg->ayny;
        if ($ayn eq 'N' || $ayn eq 'n') {
            return 1;
        } else {
            return 0;
        }
    }

    $msg = Msg::new("Oracle Version could not be discovered");
    $msg->print;

DNA_ORACLE_VERSION:

    if (Obj::webui())
    {
        $web->web_script_form("oracle_version_crs_db", $prod , $oraprod);
        if ($web->param("back") eq "back") {
            return 1;
        }
    }
    while (1) {
        if (Cfg::opt('responsefile')) {
            $answer = $cfg->{oracle_version};
        } elsif (!Obj::webui()) {
            $question = Msg::new("Enter Oracle Version (e.g. 10.2.0.1, 11.1.0.6):");
            $answer = $question->ask($prod->{$oraprod.'_release'.'.'.$oraprod.'_patch_level'}, $help, $backopt);
        } elsif (Obj::webui()){
            $answer = $prod->{$oraprod.'_release'.'.'.$oraprod.'_patch_level'};
        }

        return 3 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);

        @digits = split(/\./m, $answer);
        $release = "$digits[0].$digits[1]";
        $patch_level = "$digits[2].$digits[3]";

        if (($release ne '10.2') && ($release ne '11.1') && ($release ne '11.2')) {
            $msg = Msg::new("The Oracle version $answer is not valid. Input again");
            $msg->log;
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            if (Obj::webui())
            {
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                goto DNA_ORACLE_VERSION;
            }
            next;
        }

        $prod->{$oraprod.'_release'} = $release;
        $prod->{$oraprod.'_patch_level'} = $patch_level;
        $cfg->{oracle_version} = $answer if (!Cfg::opt('responsefile'));
        last;
    }

    return 0;
}

sub find_crs_home {
    my ($prod, $opr) = @_;
    my ($repeat, $sys, $ret, $str, $msg, $answer,$help,$backopt,$question);
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    if ($opr ne 'crs_install' && $opr ne 'post_crs_install') {
        return 1;
    }

    $help = '';
    $backopt = 1;

    while (1) {
        $repeat = 0;
        if (Cfg::opt('responsefile')) {
            if ($cfg->{crs_home} eq '') {
                $answer = $prod->{crs_home};
            } else {
                $answer = $cfg->{crs_home};
            }
        } else {
            if (!Obj::webui()) {
                $question = Msg::new("Enter absolute path of Oracle Clusterware/Grid Infrastructure Home directory:");
                $answer = $question->ask($prod->{crs_home}, $help, $backopt);
            } else {
                $answer = $prod->{crs_home};
            }
        }
        return 3 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);
	$answer = trim($answer);

        my $temp_user = $prod->{oracle_user};
        if (Cfg::opt('responsefile')) {
            if ($cfg->{grid_user} ne '') {
                $temp_user = $cfg->{grid_user};
            } else {
                $temp_user = $cfg->{oracle_user};
            }
        }
        if ($answer eq '/') {
            $msg = Msg::new("The CRS home directory cannot be '/'. Input again");
            $msg->print;
            if (Obj::webui()) {
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            return 1 if (Cfg::opt('responsefile'));
            next;
        }

        if ($opr eq 'crs_install') {
            my $ret = $prod->create_dir($answer, $temp_user, $prod->{oracle_group}, '755');
            if ($ret) {
                $msg = Msg::new("Failed to create directory ${answer}. Input valid directory name.");
                $msg->print;
                if (Obj::webui()){
                    $web->web_script_form("alert", $msg->{msg});
                    return 1;
                }
                return 1 if (Cfg::opt('responsefile'));
                $repeat = 1;
            }

            for my $sys (@{CPIC::get('systems')}) {
                # In 11gR2, we need to modify permission
                # for container directory for grid user.
                my $arg_chown = "$temp_user:$prod->{oracle_group} $answer";
                my $arg_chmod = "755 $answer";

                $sys->cmd('_cmd_chown '.$arg_chown);
                $ret = $ret || EDR::cmdexit();
                $sys->cmd('_cmd_chmod '.$arg_chmod);
                $ret = $ret || EDR::cmdexit();

                my $dir_name = $sys->cmd('_cmd_dirname '.$answer);
                if ($dir_name eq '/') {
                        $msg = Msg::new("The specified Oracle Clusterware home directory will cause a change in the permissions of the / directory. The installer will skip permission changes to the root directory. Review and update the permissions on the root directory to comply with Oracle requirements. Alternatively, specify another path.");
                        $msg->print;
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        last;
                }

                $arg_chown = "$temp_user:$prod->{oracle_group} $dir_name";
                $arg_chmod = "755 $dir_name";

                $sys->cmd('_cmd_chown '.$arg_chown);
                $ret = $ret || EDR::cmdexit();
                $sys->cmd('_cmd_chmod '.$arg_chmod);
                $ret = $ret || EDR::cmdexit();
            }
        } else {
            for my $sys (@{CPIC::get('systems')}) {
                if (!$sys->exists("$answer/bin/crs_stat")) {
                    $msg = Msg::new("Oracle Clusterware/Grid Infrastructure does not seem to be installed at $answer on $sys->{sys}. Input correct path.");
                    $msg->print;
                    if (Obj::webui()){
                        $web->web_script_form("alert", $msg->{msg});
                        return 1;
                    }
                    return 1 if (Cfg::opt('responsefile'));
                    $repeat = 1;
                    last;
                }
            }
        }
        last if !$repeat;
    }

    $prod->{crs_home} = $answer;
    $cfg->{crs_home} = $answer if (!Cfg::opt('responsefile'));

    return 0;
}

sub find_db_home {
    my ($prod, $opr) = @_;
    my ($repeat, $sys, $ret, $str, $msg, $answer,$help,$backopt,$question);
    my $cfg = Obj::cfg();
    my $web = Obj::web();
    my $warn_user = 0;

    if ($opr ne 'db_install' && $opr ne 'relink') {
        return 1;
    }

    $help = '';
    $backopt = 1;

    while (1) {
        $repeat = 0;
        if (Cfg::opt('responsefile')) {
            $answer = $cfg->{db_home};
        } else {
            if (!Obj::webui()) {
                $question = Msg::new("Enter absolute path of Oracle Database Home directory:");
                $answer = $question->ask($prod->{db_home}, $help, $backopt);
            } else {
                $answer = $prod->{db_home};
            }
        }
        return 3 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);

        if ($answer eq '/') {
            $msg = Msg::new("The Oracle Database home directory cannot be '/'. Input again");
            $msg->print;
            if (Obj::webui()) {
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            return 1 if (Cfg::opt('responsefile'));
            next;
        }
        if ($opr eq 'db_install') {
            my $ret = $prod->create_dir($answer, $prod->{oracle_user}, $prod->{oracle_group}, '755');
            if ($ret) {
                $msg = Msg::new("Failed to create directory ${answer}. Input valid directory name.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                $repeat = 1;
                if (Obj::webui()){
                    $web->web_script_form("alert", $msg->{msg});
                    return 1;
                }
            }
        } else {
            for my $sys (@{CPIC::get('systems')}) {
                if (!$sys->exists("$answer/bin/oracle")) {
                    $msg = Msg::new("Oracle Database does not seem to be installed at $answer on $sys->{sys}. Input correct path.");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    $repeat = 1;
                    if (Obj::webui()){
                        $web->web_script_form("alert", $msg->{msg});
                        return 1;
                    }
                    last;
                }
		my $dbhome_owner = $sys->cmd("_cmd_ls -ld $answer | _cmd_awk '{print \$3}'");
		if($dbhome_owner ne $prod->{oracle_user}) {
                    if($prod->{oracle_user} eq '') {
                        $prod->{oracle_user} = $dbhome_owner;
                    } else {
                        $warn_user = 1;
                    }
                }
            }
            if($warn_user eq "1") {
                $msg = Msg::new("Oracle user entered ($prod->{oracle_user}) does not own Oracle Database Home. Relinking Oracle database might fail.\n Do you want to continue");
                $ayn = $msg->ayny;
                if ($ayn eq 'n' || $ayn eq 'N') {
		    return 1;
                }
            }
        }
        last if !$repeat;
    }

    $prod->{db_home} = $answer;
    $cfg->{db_home} = $answer if (!Cfg::opt('responsefile'));

    return 0;
}


sub find_base {
    my ($prod, $oraprod) = @_;
    my $ret1=0; $ret2=0;
    my $cfg = Obj::cfg();

    if (Cfg::opt('responsefile') && $oraprod eq 'crs') {
        if ($cfg->{install_oracle_clusterware} && $cfg->{grid_user} ne '') {
            $ret1 = $prod->find_grid_base($oraprod);
        }

        return 1 if ($ret1);
    } else {
        return $prod->find_oracle_base($oraprod);
    }

    return 0;
}

sub find_oracle_base {
    my ($prod, $oraprod) = @_;
    my ($ret, $str, $msg, $answer, $help, $backopt, $question, $iscfs, $ayn);

    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $help = '';
    $backopt = 1;

    while (1) {
        if (Cfg::opt('responsefile')) {
            $answer = $cfg->{oracle_base};
        } elsif (!Obj::webui()){
            $question = Msg::new("Enter absolute path of Oracle Base directory:");
            $answer = $question->ask($prod->{oracle_base}, $help, $backopt);
        } elsif (Obj::webui()){
            $answer = $prod->{oracle_base};
        }
       
      
        return 3 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);
        if ($answer eq '/') {
            $msg = Msg::new("The Oracle Base directory cannot be '/'. Input again");
            $msg->print;
            if (Obj::webui()) {
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                return 1;
            }
            return 1 if (Cfg::opt('responsefile'));
            next;
        }

        if ($oraprod eq 'crs') {
            $iscfs = $prod->is_cfsmount_all_systems($answer);
            if ($iscfs) {
                if ($iscfs == 1) {
                    $msg = Msg::new("The Oracle Base directory cannot be on a shared location. Input again");
                    $msg->print;
                    if (Obj::webui()) {
                        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                        return 1;
                    }
                    return 1 if (Cfg::opt('responsefile'));
                    next;
                } else {
                    $msg = Msg::new("Failed to determine if the specified Oracle Base directory is on a shared location. This directory must be local. Check this manually and confirm.");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    $msg = Msg::new("Do you want to continue?");
                    $msg = Msg::new("Failed to determine if the specified Oracle Base directory is on a shared location. This directory must be local. Check this manually and confirm. \\n Do you want to continue?");
                    $ayn = $msg->aynn;
                    if ($ayn eq 'N') {
                        next if (!Obj::webui());
                        return 1 if (Obj::webui());
                    }
                }
            }
        }
        my $pdir = EDRu::dirname($answer);
	if ($pdir eq '/') {
		$msg = Msg::new("The permissions for the root (/) directory will not be modified for the specified Oracle Base directory, and it may cause the Oracle 11g Release 2 installation to fail. Do you want to continue ?");
		my $ayn = $msg->ayny;
		if ($ayn ne 'n' && $ayn ne 'N') {
			last;
		}
		goto PDIR_ROOT; 
        }
        $ret = $prod->create_dir($pdir, $prod->{oracle_user}, $prod->{oracle_group}, '755',0);
        if ($ret) {
            $msg = Msg::new("Failed to create directory ${pdir}. Input valid directory name.");
            $msg->print;
            return 1 if (Cfg::opt("responsefile"));
            if (Obj::webui())
            {
                $web->web_script_form("alert", $msg->{msg}) ;
                return 1;
            }
            next;
        }

PDIR_ROOT:
        $ret = $prod->create_dir($answer, $prod->{oracle_user}, $prod->{oracle_group}, '755',0);
        if ($ret) {
            $msg = Msg::new("Failed to create directory ${answer}. Input valid directory name.");
            $msg->print;
            return 1 if (Cfg::opt('responsefile'));
            if (Obj::webui())
            {
                $web->web_script_form("alert", $msg->{msg}) ;
                return 1;
            }
            next;
        }
        last;
    }

    $prod->{oracle_base} = $answer;
    $cfg->{oracle_base} = $answer if (!Cfg::opt('responsefile'));

    return 0;
}

sub find_grid_base {
    my ($prod, $oraprod) = @_;
    my ($ret, $str, $msg, $answer, $help, $backopt, $question, $iscfs, $ayn);
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    $help = '';
    $backopt = 1;

    if (Cfg::opt('responsefile')) {
        $answer = $cfg->{grid_base};
    }

    return 3 if (EDR::getmsgkey($answer,'back'));
    chomp($answer);

    if ($oraprod eq 'crs') {
        $iscfs = $prod->is_cfsmount_all_systems($answer);
        if ($iscfs == 1) {
            $msg = Msg::new("The Grid Base directory cannot be on a shared location. Provide proper value for grid_base in the responsefile.");
            $msg->print;
            if (Obj::webui())
            {
                $web->web_script_form("alert", $msg->{msg}) ;
                return 1;
            }
            return 1 if (Cfg::opt('responsefile'));
        }
    }
    my $pdir = EDRu::dirname($answer);
    $ret = $prod->create_dir($pdir, $prod->{oracle_user}, $prod->{oracle_group}, "755");
    if ($ret) {
        $msg = Msg::new("Failed to create directory ${pdir}. Input valid directory name.");
        $msg->print;
        if (Obj::webui())
        {
            $web->web_script_form("alert", $msg->{msg}) ;
            return 1;
        }
        return 1 if (Cfg::opt("responsefile"));
        next;
    }

    $ret = $prod->create_dir($answer, $prod->{grid_user}, $prod->{oracle_group}, '755');
    if ($ret) {
        $msg = Msg::new("Failed to create directory ${answer}. Provide proper value for grid_base in the responsefile.");
        $msg->print;
        if (Obj::webui())
        {
            $web->web_script_form("alert", $msg->{msg}) ;
            return 1;
        }
        return 1 if (Cfg::opt('responsefile'));
    }

    $prod->{grid_base} = $answer;

    return 0;
}

# Extract the oracle release from the "stage/product.xml" file
# Return 1 if cannot probe the above file.
#
# Also, set the CRS/DB release and patch level
# for future use
sub get_oraver_from_xml {
    my ($prod, $oraprod) = @_;
    my ($msg, $line, $release, $patch_level, $prodxml);
    my $sys = $prod->localsys;

    return 1 if ($oraprod ne 'crs' && $oraprod ne 'db');

    $prodxml = $prod->{$oraprod.'_installpath'}.'/stage/products.xml';
    if (! -e $prodxml) {
        $msg = Msg::new("Cannot find '$prodxml'");
        $msg->log;
        return 1;
    }

    if ($oraprod eq 'db') {
        $line = $sys->cmd("_cmd_grep 'COMP NAME' $prodxml 2>/dev/null | _cmd_grep 'oracle.server' 2>/dev/null");
    } else {
        $line = $sys->cmd("_cmd_grep 'COMP NAME' $prodxml 2>/dev/null | _cmd_grep 'oracle.crs' 2>/dev/null");
    }

    if (EDR::cmdexit()) {
        $line = $sys->cmd("_cmd_grep 'PATCHSET NAME' $prodxml 2>/dev/null");
    }

    my @strings = split(/\"/m, $line);
    my $oraversion_str = $strings[3];
    chomp($oraversion_str);
    if ($oraversion_str !~ /^(\d.)+/m) {
        $msg = Msg::new("The oracle release $oraversion_str is not valid");
        $msg->log;
        return 1;
    }
    $msg = Msg::new("get oraversion from optach function : oraversion is $prod->{oraver}");
    $msg->log;

    my @digits = split(/\./m, $oraversion_str);
    $release = "$digits[0].$digits[1]";
    $patch_level = "$digits[2].$digits[3]";
    chomp($release);
    chomp($patch_level);
    $prod->{$oraprod.'_release'} = $release;
    $prod->{$oraprod.'_patch_level'} = $patch_level;

    return 0;
}

sub get_oraver_from_opatch {
    my $prod = shift;
    my $oraprod = shift;
    my $productstr = shift;

    my ($msg,$release,$patch_level,$prodxml,$orauser);
    if ($oraprod eq 'crs') {
        $home = $prod->{crs_home};
    } elsif ($oraprod eq 'db') {
        $home = $prod->{db_home};
    } else {
        return 1;
    }


    my $sys = $prod->localsys;

#   my $optach_script = "$prod->{db_home}/OPatch/opatch";
    my $optach_script = "$home/OPatch/opatch";
    if (! -e $optach_script) {
        $msg = Msg::new("Cannot find '$optach_script'");
        $msg->log;
        return 1;
    }

    my $defval = $sys->cmd("_cmd_ls -al $optach_script | _cmd_awk '{print \$3}' 2> /dev/null");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem determining Oracle user");
        $msg->log;
        $question = Msg::new("\nEnter the Oracle user name:");
        $orauser = $question->ask($deforauser);
    } else {
        $orauser = $defval;
    }

    $prod->save_term if (!Obj::webui());
    chdir('/tmp');
    my $line = $sys->cmd("_cmd_su $orauser -c '_cmd_sh $optach_script lsinventory -oh $home 2> /dev/null' | _cmd_grep '$productstr' | _cmd_tail -1");

    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem determining Oracle Version on $sys->{sys}");
        $msg->log;
        return 1;
    }
    $prod->restore_term if (!Obj::webui());

    my @strings = split(/\s+/m, $line);
    my $cnt = @strings;
    my $oraversion_str = $strings[$cnt-1];  # Oracle Database version e.g. 11.1.0.6.0
    if ($oraversion_str !~ /^(\d.)+/m) {
        $msg = Msg::new("The oracle release $oraversion_str is not valid");
        $msg->log;
        return 1;
    }

    $prod->{oraver} = $oraversion_str;
    my @digits = split(/\./m, $oraversion_str);
    $release = "$digits[0].$digits[1]";
    $patch_level = "$digits[2].$digits[3]";
    chomp($release);
    chomp($patch_level);

    $prod->{${oraprod}.'_release'} = $release;
    $prod->{${oraprod}.'_patch_level'} = $patch_level;

    return 0;
}

# Check if the given Oracle user exits on some nodes
# If so, then check if the 'uid' is different on them
#
# Return 0: Oracle user doesn't exist anywhere
# Return 1: exists somewhere but 'uid' is same at those nodes
# Return 2: exists everywhere with 'uid' also same
# Return 3: exists some/everywhere but 'uid' is different on some nodes
sub validate_orauser {
    my ($prod, $orauser, $uid, $systems_ref) = @_;
    my ($ret, $passwdfile_usr);
    my ($puser, %puserid, $orauserid, $temp);
    my (%noorausr, $noorausr, $difforauid);
    my ($msg, $sys, $sys1, $nsystems, $csystems);
    my $localsys = $prod->localsys;

    $csystems = $#{$systems_ref} + 1;
    $nsystems = 0;

    $noorausr = 1;
    $difforauid = 0;
    $orauserid = $uid;
    for $sys (@{$systems_ref}) {
        $noorausr{$sys} = 1;
        $passwdfile_usr = $sys->cmd("_cmd_cat /etc/passwd | _cmd_grep '^$orauser:'");
        if ($passwdfile_usr) {
            $noorausr{$sys} = 0;
            $noorausr = 0;
            $nsystems++;
            $msg = Msg::new("Oracle user $orauser already exists on $sys->{sys}");
            $msg->log;
            ($puser, $temp, $puserid{$sys}, $temp, $temp, $prod->{oracle_user_home}, $temp) = split(/:/m, $passwdfile_usr, 7);
            if ($orauserid eq '0') {
                $orauserid = $puserid{$sys};
            } else {
                if ($puserid{$sys} ne $orauserid) {
                    $difforauid = 1;
                    last;
                }
            }
        }
    }

    return 0 if ($noorausr);

    if ($difforauid) {
        return 3;
    } else {
        if ($nsystems == $csystems) {
            $prod->{oracle_uid} = $orauserid;

            # Setting the primary group for the already everywhere existing user
            if ($prod->determine_group($localsys, $orauser)) {
                $msg = Msg::new("Error in determining the group for the Oracle user $orauser on $localsys->{sys}");
                $msg->log;
                return 1; # As it's equivalent of the case when we return 1 (See above)
            }
            $msg = Msg::new("Oracle user $orauser already exists on all the nodes with the group $prod->{oracle_group} (GID: $prod->{oracle_gid})");
            $msg->log;

            return 2;
        }
        return 1;
    }
}

# Check if the given Oracle group exits on some nodes
# If so, then check if the 'gid' is different on them
#
# Return 0: Oracle group doesn't exist anywhere
# Return 1: exists somewhere but 'gid' is same at those nodes
# Return 2: exists everywhere with 'gid' also same
# Return 3: exists some/everywhere but 'gid' is different on some nodes
sub validate_oragroup {
    my ($prod, $oragroup, $gid, $systems_ref) = @_;
    my ($ret, $groupfile_group);
    my ($pgroup, %pgroupid, $oragroupid, $temp);
    my (%nooragroup, $nooragroup, $difforagid);
    my ($msg, $sys, $sys1, $nsystems, $csystems);

    $csystems = $#{$systems_ref} + 1;
    $nsystems = 0;

    $nooragroup = 1;
    $difforagid = 0;
    $oragroupid = $gid;
    for $sys (@{$systems_ref}) {
        $nooragroup{$sys} = 1;
        $groupfile_group = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$oragroup:'");
        if ($groupfile_group) {
            $nooragroup{$sys} = 0;
            $nooragroup = 0;
            $nsystems++;
            $msg = Msg::new("Oracle group $oragroup already exists on $sys->{sys}");
            $msg->log;
            ($pgroup, $temp, $pgroupid{$sys}, $temp) = split(/:/m, $groupfile_group, 4);
            if ($oragroupid eq '0') {
                $oragroupid = $pgroupid{$sys};
            } else {
                if ($pgroupid{$sys} ne $oragroupid) {
                    $difforagid = 1;
                }
            }
        }
    }

    return 0 if ($nooragroup);

    if ($difforagid) {
        return 3;
    } else {
        if ($nsystems == $csystems) {
            $prod->{oracle_gid} = $oragroupid;
            return 2;
        }
        return 1;
    }
}

# Creates given directory on all sytems if
# not created already.
sub create_dir {
    my ($prod, $dir_name, $orauser, $oragroup, $perms, $recursive) = @_;
    my $arg_mkdir = "-p $dir_name";
    my $arg_chown = "-R $orauser:$oragroup $dir_name";
    my $arg_chmod = "-R $perms $dir_name";
    my ($sys, $msg);
    my $ret = 0;

    if($recursive eq 0 ){
        $arg_chown = "$orauser:$oragroup $dir_name";
        $arg_chmod = "$perms $dir_name";
    }

    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd('_cmd_mkdir '.$arg_mkdir);
        $ret = EDR::cmdexit();
        $sys->cmd('_cmd_chown '.$arg_chown);
        $ret = $ret || EDR::cmdexit();
        $sys->cmd('_cmd_chmod '.$arg_chmod);
        $ret = $ret || EDR::cmdexit();

        if ($ret) {
            $msg = Msg::new("Create directory operation on $sys->{sys} failed");
            $msg->log;
            last;
        }
    }
    return $ret;
}

sub relink_oracle_database {
    my $prod = shift;
    my ($msg, $ret, $skgxn_name);
    my $cfg = Obj::cfg();
    my $sys = @{CPIC::get('systems')}[0];
    my $preinst = 0;
    my $web = Obj::web();
    my $mesg = "";

    return 0 if (Cfg::opt('responsefile') && $cfg->{relink_oracle_database} == 0);
    $cfg->{relink_oracle_database} = 1;

    $prod->task_title('relink_oracle_database');

    while (1) {
        if (Obj::webui()){
            $prod->{web_relink_oracle_database} = 1;
            $web->web_script_form('relink_oracle_db', $prod);
            $prod->{web_relink_oracle_database} = 0;
            if ($web->param('back') eq 'back') {
                return 1;
            }
        }
        # ORACLE_USER
        $ret = $prod->find_oracle_user($preinst);
        return 1 if ($ret == 1);
        return 1 if ($ret == 3);
        # if validation of oracle user fails, it return 4 in case of web installer
        next if ($ret == 4);

        # ORACLE_GROUP
        $ret = $prod->find_oracle_group($preinst, 1);
        return 1 if ($ret == 1);
        return 1 if ($ret == 3);
        # if validation of oracle grp fails, it return 4 in case of web installer
        next if ($ret == 4);

        # Sanity check for Oracle user cum group
        return 1 if ($prod->oracle_sanity($prod->{oracle_user}, $prod->{oracle_group}) == 1);

        # ORA_CRS_HOME
        if ($prod->determine_crs_home('post_crs_install')) {
            if (Obj::webui()){
                next;
            } else {
                return 1;
            }
        }

        # DB_HOME
        if ($prod->find_db_home('relink')) {
            if (Obj::webui()){
                next;
            } else {
                return 1;
            }
        }

        # DB_RELEASE DB_PATCH_LEVEL
        return 1 if ($prod->find_oracle_version('db', 'relink'));

        $prod->task_title('relink_oracle_database') if (!Cfg::opt('responsefile'));

        $mesg = "";
        $msg = Msg::new("Verify Oracle database information");
        $msg->bold;
        $mesg .= "$msg->{msg}\n";
        $msg = Msg::new("\tOracle UNIX User: $prod->{oracle_user}");
        $msg->print;
        $mesg.="$msg->{msg}\n";
        $msg = Msg::new("\tOracle UNIX Group: $prod->{oracle_group}");
        $msg->print;
        $mesg.="$msg->{msg}\n";
        $msg = Msg::new("\tOracle Clusterware/Grid Infrastructure Home: $prod->{crs_home}");
        $msg->print;
        $mesg.="$msg->{msg}\n";
        $msg = Msg::new("\tOracle Database Home: $prod->{db_home}");
        $msg->print;
        $mesg.="$msg->{msg}\n";
        $msg = Msg::new("\tOracle Version: $prod->{db_release}.$prod->{db_patch_level}");
        $msg->print;
        $mesg.="$msg->{msg}\n";
        $msg->n;

        last if (Cfg::opt('responsefile'));
        $msg = Msg::new("Is this information correct?");
        $mesg.=$msg->{msg};
        $msg = Msg::new($mesg) if(Obj::webui());
        
        my $ayn = $msg->ayny;
        if ($ayn ne 'n' && $ayn ne 'N') {
            last;
        }
    } # while

    if (!Cfg::opt('responsefile')) {
        $cfg->{oracle_user} = $prod->{oracle_user};
        $cfg->{oracle_group} = $prod->{oracle_group};
        $cfg->{crs_home} = $prod->{crs_home};
        $cfg->{db_home} = $prod->{db_home};
    }

    #
    # Verify that the binaries have been installed in crs_home.
    #
    $ret = $prod->verify_home_dirs($prod->{crs_home});
    if ($ret != 0) {
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure binaries are not installed properly");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui()); 
        Msg::prtc();
        return 1;
    }

    #
    # Verify that the binaries have been installed in db_home.
    #
    $ret = $prod->verify_home_dirs($prod->{db_home});
    if ($ret != 0) {
        $msg = Msg::new("Oracle Database binaries are not installed properly");
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
        return 1;
    }

    $ret = $prod->relink_crs();
    if ($ret != 0) {
        Msg::prtc();
        return 1;
    }

    #
    # Check if Oracle instance is running.
    #
    $ret = $prod->is_db_up($prod->{db_home});
    if ($ret == 2) {
        $msg = Msg::new("\nFailed to determine the status of Oracle Database. Shutdown the Oracle Database on all nodes of your cluster if it is up before proceeding further. Check the logs for more information.");
        $msg->print;
        $mesg = $msg->{msg};

        if (!Cfg::opt('responsefile')) {
            $msg = Msg::new("\nDo you want to continue with Oracle relinking?");
            $mesg.=$msg->{msg};
            $msg = Msg::new($mesg) if(Obj::webui());

            my $ayn = $msg->aynn;
            if ($ayn eq 'N') {
                return 1;
            }
        }
    } elsif ($ret == 1) {
        $msg = Msg::new("\nOracle instance is running on one or more node(s) of your cluster.\nStop it before relinking Oracle.");
        $msg->log;
        $msg->print;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui()); 
        Msg::prtc();
        return 1;
    }
    $msg = Msg::new("Relinking Oracle Database");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    $ret = $prod->relink_oracle();
    if ($ret != 0) {
        Msg::prtc();
        return 1;
    }

    $msg = Msg::new("\nOracle relinking completed successfully");
    $msg->print;
    $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
    Msg::prtc();

    return 0;
}

sub is_crs_up {
    my ($prod, $systems_ref) = @_;
    my $ret = 0;
    my ($sys, $msg);

    for my $sys (@{$systems_ref}) {
        $msg = Msg::new("Verifying Oracle Clusterware/Grid Infrastructure status on $sys->{sys}");
        $msg->left;

        $sys->cmd("$prod->{crs_home}/bin/crs_stat -t 2> /dev/null");
        if (!EDR::cmdexit()) {
            $msg = Msg::new("Running");
            $msg->right;
            $ret = 1;
        } else {
            $msg = Msg::new("Not running");
            $msg->right;
        }
    }

    return $ret;
}

sub get_skgxn_lib {
    my ($prod, $crshome, $db_release) = @_;
    my $skgxn_name = 'libskgxn2.so';
    return $skgxn_name;
}

sub relink_crs {
    my $prod = shift;

    #
    # Check if libskgxn2.so/libskgxn2.a points to the VCSMM library
    #

    $skgxn_name = $prod->get_skgxn_lib($prod->{crs_home}, $prod->{db_release});
    $ret = $prod->verify_libskgxn($skgxn_name, $prod->{crs_home});
    if ($ret) {
        $ret = $prod->link_libskgxn($skgxn_name, $prod->{crs_home});
        if ($ret) {
            return 1;
        }
    }
    $prod->set_css_misscount($prod->{crs_home}) if $prod->can('set_css_misscount');

    return;
}

sub verify_libskgxn {
    my ($prod, $skgxn_name, $crs_home) = @_;
    my ($sys, @cpnodes, $msg);
    my $failed = 0;

    @cpnodes = ($iscfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $msg = Msg::new("Verifying skgxn library on $sys->{sys}");
        $msg->left;
        $sys->cmd("_cmd_ls $crs_home/lib/$skgxn_name");
        if (!EDR::cmdexit()) {
            $sys->cmd("$prod->{cmd_nm_64} $crs_home/lib/$skgxn_name 2> /dev/null | _cmd_grep vcsmm");
            if (!EDR::cmdexit()) {
                Msg::right_done();
                next;
            }
        }
        $msg = Msg::new("Not linked to Veritas library");
        $msg->right;
        $failed = 1;
    }
    return $failed;
}

sub is_db_up {
    my ($prod, $db_home) = @_;
    my ($msg, $output, @lines, @words, $line, $run_cmd, $srvctl_output);
    my ($s, $sys, $crs_up, $result);
    my $localsys = $prod->localsys;
    my $web = Obj::web();
    $db_home =~ s/\/$//;;

    Msg::n();
    $msg = Msg::new("Verifying Oracle Database status");
    $msg->left;

    # find the node where CRS is up
    $crs_up = 0;
    for my $s (@{CPIC::get('systems')}) {
        $s->cmd("$prod->{crs_home}/bin/crs_stat -t 2> /dev/null");
        if (!EDR::cmdexit()) {
            $crs_up = 1;
            $sys = $s;
            last;
        }
    }

    if (!$crs_up) {
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure is down on all nodes, so declaring Oracle Database down");
        $msg->log;
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::right_done;
        return 0;
    }

    $sys->cmd("_cmd_ls $prod->{oratab} 2> /dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$prod->{oratab} doesn't exist on $sys->{sys}");
        $msg->log;

        open(CRSSTAT, "$prod->{crs_home}/bin/crs_stat 2> /dev/null |");
        my (@line) = grep(/NAME/, <CRSSTAT>);
        for my $item (@line) {
            my (@strs) = split(/=/m, $item);
            my (@fields) = split(/\./m, $strs[1]);
            chomp $fields[2];
            if ($fields[2] eq 'db') {
                $dbname = $fields[1];

                if ($prod->{db_release} eq '10.2') {
                    $run_cmd = "$prod->{crs_home}/bin/srvctl config database -d $dbname -a | _cmd_grep -i 'Oracle_home' | _cmd_awk '{print \$2}'";
                } else {
                   $run_cmd = "$prod->{crs_home}/bin/srvctl config database -d $dbname -a | _cmd_grep 'Oracle home' | _cmd_awk '{print \$3}'";
                }

                $srvctl_output = $sys->cmd("$run_cmd");
                if ($srvctl_output eq $db_home) {
                    $run_cmd = "ORACLE_HOME=$db_home; export ORACLE_HOME;";
                    $run_cmd = $run_cmd."$db_home/bin/srvctl status database -d $dbname";
                    chdir('/tmp');
                    $srvctl_output = $sys->cmd("_cmd_su $prod->{oracle_user} -c '$run_cmd'");
                    if (EDR::cmdexit() != 0) {
                        $result = ($srvctl_output =~ /PRKR-1001/m);
                        if ($result) {
                            #
                            # Consider the database down if the srvctl command returns with
                            # "PRKR-1001 : cluster database <db name> does not exist"
                            # error.
                            #
                            next;
                        }
                        Msg::right_failed();
                        return 2;
                    }

                    for my $s (@{CPIC::get('systems')}) {
                        $result = ($srvctl_output =~ /is running on node $s->{sys}/m);
                        if ($result) {
                            $msg = Msg::new("UP");
                            $msg->right;
                            return 1;
                        }
                    }
                }
            }
        }

    } else {
        $output = $sys->cmd("_cmd_grep -v '^#' $prod->{oratab}");
        @lines = split(/\n/,  $output);
        for my $line (@lines) {
            next if ($line eq '');
            @words = split(/:/m, $line);
            if ($words[1] eq $db_home) {
                $run_cmd = "ORACLE_HOME=$db_home; export ORACLE_HOME;";
                $run_cmd = $run_cmd."$db_home/bin/srvctl status database -d $words[0]";
                chdir('/tmp');
                $srvctl_output = $sys->cmd("_cmd_su $prod->{oracle_user} -c '$run_cmd'");
                if (EDR::cmdexit() != 0) {
                    $result = ($srvctl_output =~ /PRKR-1001/m);
                    if ($result) {
                        #
                        # Consider the database down if the srvctl command returns with
                        # "PRKR-1001 : cluster database <db name> does not exist"
                        # error.
                        #
                        next;
                    }
                    Msg::right_failed();
                    return 2;
                }
                for my $s (@{CPIC::get('systems')}) {
                    $result = ($srvctl_output =~ /is running on node $s->{sys}/m);
                    if ($result) {
                        $msg = Msg::new("UP");
                        $msg->right;
                        return 1;
                    }
                }
            }
        }
    }
    Msg::right_done;

    return 0;
}

sub is_vcs_up {
    my ($prod, $systems_ref)  = @_;
    my $ret = 1;
    my ($sys, $msg, $had);

    for my $sys (@{$systems_ref}) {
        $msg = Msg::new("Verifying VCS Engine status on $sys->{sys}");
        $msg->left;

        $had = $sys->proc('had60');
        if ($had->check_sys($sys)) {
            $msg = Msg::new("Running");
            $msg->right;
        } else {
            $msg = Msg::new("Not running");
            $msg->right;
            $ret = 0;
        }
    }

    return $ret;
}

# To be called only if Oracle Clusterware is installed (running: good, but not needed)
sub determine_crs_home {
    my $prod = shift;
    my $operation = shift;
    my $sys = @{CPIC::get('systems')}[0];
    my $crshome;
    my $crsinitdir;

    if (!Obj::webui()) {
        if ($sys->exists("$prod->{initdir}/init.ohasd")) {
            $crsinitdir = "$prod->{initdir}/init.ohasd";
        } else {
            $crsinitdir = "$prod->{initdir}/init.crsd";
        }
        $crshome = $sys->cmd("_cmd_grep 'ORA_CRS_HOME=' $crsinitdir");
        $prod->{crs_home} = (split(/=/m, $crshome))[1] if (!EDR::cmdexit());
    }
    return 1 if ($prod->find_crs_home($operation));
    return 0;
}

# Save the terminal state
sub save_term {
    my $prod = shift;
    $prod->{save_term} = EDR::cmd_local('stty -g');
    return;
}

# Restore the terminal state
sub restore_term {
    my $prod = shift;
    EDR::cmd_local("stty '$prod->{save_term}'");
    return;
}

sub addnode_poststart {
    my $prod = shift;
    my ($sysobj, $sys, $sysname, $msg, $ret);
    my (@clusnodes, @newnodes, @allnodes);
    my $cfg = Obj::cfg();
    my $web = Obj::web();

    for my $sysname (@{$cfg->{clustersystems}}) {
        $sysobj = Sys->new($sysname); # initialize system objects
        push(@clusnodes, $sysobj);
        push(@allnodes, $sysobj);
    }

    for my $sysname (@{$cfg->{newnodes}}) {
        $sysobj = Sys->new($sysname); # initialize system objects
        push(@newnodes, $sysobj);
        push(@allnodes, $sysobj);
    }

    $prod->{clusnodes} = \@clusnodes;
    $prod->{newnodes} = \@newnodes;
    $prod->{allnodes} = \@allnodes;

    for my $sys (@{$prod->{clusnodes}}) {
#       print "\n====$sys->{sys}========\n";
    }

    for my $sys (@{$prod->{newnodes}}) {
#       print "\n====$sys->{sys}========\n";
    }

    for my $sys (@{$prod->{allnodes}}) {
#        print "\n====$sys->{sys}========\n";
    }
    $prod->addnode_start_procs();
    $prod->perform_task('addnode_poststart');

    Msg::title();
    $msg = Msg::new("The following $prod->{abbr} specific operations need to be performed for the new nodes being added. You can skip all of these steps if you are not going to install Oracle Clusterware/Grid Infrastructure and Database on new nodes.\n");
    $msg = Msg::new("Some $prod->{abbr} specific operations need to be performed for the new nodes being added to cluster. Options for these operations will appear once you click ok button. You can skip all of these steps by selecting Finish dropdown menu if you are not going to install Oracle Clusterware/Grid Infrastructure and Database on new nodes..\n") if (Obj::webui());
    $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
    $msg->print;

    #
    # print menu for addnode
    #
    $prod->addnode_menu_sfrac();

    return;
}

sub addnode_menu_sfrac {
    my $prod = shift;
    my (@menuopts, $menulist, $menu, $menukey, $choice);
    my ($backopt, $def, $help, $ret, $msg);
    my ($priv_rsrc_ref, $mpriv_rsrc_ref, $newsys);
    my $web = Obj::web();

    $msg = Msg::new("Create Oracle User and Group");
    $msg->msg('addnode_create_oracle_user_group');

    $msg = Msg::new("Configure private IP addresses (PrivNIC Configuration)");
    $msg->msg('addnode_config_privnic');

    $msg = Msg::new("Configure private IP addresses (MultiPrivNIC Configuration)");
    $msg->msg('addnode_config_multiprivnic');

    $msg = Msg::new("Mount OCR and Vote devices");
    $msg->msg('addnode_mount_ocr_and_vote');

    $msg = Msg::new("Create Oracle Clusterware/Grid Infrastructure and Database home directories");
    $msg->msg('addnode_install_oracle_crs_and_db');

    $msg = Msg::new("Finish");
    $msg->msg('finish');

    $def = 1; # Default option in the menu
    $help = '';
    $backopt = 0;
    @menuopts = ();
    $menulist = [];
    $newsys = @{$prod->{newnodes}}[0];

    push(@menuopts, 'addnode_create_oracle_user_group');
    $priv_rsrc_ref = $prod->addnode_check_resource('PrivNIC', $newsys);
    if ($#$priv_rsrc_ref >= 0) {
        $nic_config_complete=1;
        push(@menuopts, 'addnode_config_privnic');
    }

    $mpriv_rsrc_ref = $prod->addnode_check_resource('MultiPrivNIC', $newsys);
    if ($#$mpriv_rsrc_ref >= 0) {
        $nic_config_complete=1;
        push(@menuopts, 'addnode_config_multiprivnic');
    }

#    push(@menuopts, "addnode_mount_ocr_and_vote");
#    push(@menuopts, "addnode_install_oracle_crs_and_db");
    push(@menuopts, 'finish');

    for my $menukey (@menuopts) {
        $menu = Msg::get("$menukey");
        push(@{$menulist}, $menu);
    }

    while(1) {
        if (Obj::webui()) {
            $web->web_script_form('sfrac_addnode_select_task', $prod, \@menuopts);
            if ($web->param('back') eq 'back') {
                return;
            }
            $choice = $web->param('select_task');
        } else {
            $msg = Msg::new("Choose option:");
            $choice = $msg->menu($menulist, $def, $help, $backopt);
            $choice = @menuopts[(0+$choice) - 1];

        }
	if ($choice eq 'finish') {
		if($nic_config_complete==1) {
			if ($#$priv_rsrc_ref >= 0) {
				$msg = Msg::new("Warning: PrivNIC configuration must be updated for newly added node.");   
				$msg->print;
			} elsif($#$mpriv_rsrc_ref >= 0) {
				$msg = Msg::new("Warning: MultiPrivNIC configuration must be updated for newly added node.");
				$msg->print;
			}
		}	

		$prod->addnode_online_cvm_group();
                $prod->addnode_comp_message();
            last;
        } else {
            $ret = $prod->$choice();
        }
        Msg::title();
    }
    return;
}

sub addnode_start_procs {
    my $prod = shift;
    my ($sys, $firstnode, $proc, $msg);
    my $fname = '/usr/sbin/cluster/utilities/cldomain';
    my $cpic = Obj::cpic();
    my $web = Obj::web();

    $firstnode = @{$prod->{clusnodes}}[0];

    for my $sys (@{$prod->{newnodes}}) {
        $firstnode->copy_to_sys($sys, $prod->{vcsmmtab});
        my $procs = $prod->pkg($prod->{mainpkg})->{startprocs};
        for my $proci (@$procs) {
            $proc = $sys->proc($proci);
            $msg = Msg::new("Starting $proc->{proc} on $sys->{sys}");
            $msg->left();
            if ($cpic->proc_start_sys($sys, $proc)) {
                CPIC::proc_start_passed_sys($sys, $proc);
                Msg::right_done();
            } else{
                CPIC::proc_start_failed_sys($sys, $proc);
                $msg = Msg::new("Starting $proc->{proc} on $sys->{sys} failed") if (Obj::webui());
                $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
                Msg::right_failed();
            }
        }

        my $smallsys = Prod::VCS60::Common::transform_system_name($firstnode->{sys});
        my $vcs = $prod->prod('VCS60');
        my $cssd = eval {$firstnode->cmd("$vcs->{bindir}/hares -list Type=Application StartProgram=~cssd-online StopProgram=~cssd-offline MonitorProgram=~cssd-monitor CleanProgram=~cssd-clean Enabled=1 2>/dev/null | _cmd_grep -i $smallsys");};
        if ($cssd) {
            $sys->cmd("_cmd_touch $prod->{cssd_offline_file}");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Failed to create $prod->{cssd_offline_file} file on $sys->{sys}. Create it manually if you have configured CSSD resource in the cluster. Otherwise, cvm group will not be online until CSSD resource is up on new nodes.");
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
                Msg::prtc();
            }
        }

        if ($prod->can('addnode_copy_cldomain_file')) {
            $ret = $prod->addnode_copy_cldomain_file($fname, $firstnode, $sys);
            if (!$ret) {
                $msg = Msg::new("Failed to copy file $fname from $firstnode->{sys} to $sys->{sys}. Copy it manually before installing Oracle Clusterware/Grid Infrastructure on new nodes.");
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
                Msg::prtc();
            }
        }
    }
    return;
}

sub addnode_online_cvm_group {
    $prod = shift;
    my ($sys, $ret, $firstnode, $msg);
    my $vcs = $prod->prod('VCS60');
    my $web = Obj::web();

    # Make newnode cvm online
    $firstnode = @{$prod->{clusnodes}}[0];
    for my $sys (@{$prod->{newnodes}}) {
        my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});

        # Before onlining Probe the group
        $rtn = $sys->cmd("$vcs->{bindir}/hagrp -wait cvm ProbesPending 0 -sys $sysname -time 60");
        if (EDR::cmdexit()) {
            $msg = Msg::new("The 'cvm' service group is not probed on $sysname. Online the 'cvm' service group using the command \n \t $vcs->{bindir}/hagrp -online cvm -sys $sysname");
            $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
            next;
        }

        # Run hagrp on one node of cluster
        $msg = Msg::new("Bringing the cvm group online");
        $msg->left;
        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -online cvm -sys $sysname");
#        if (EDR::cmdexit()) {
#            Msg::right_failed();
#            next;
#        }
        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -wait cvm State ONLINE -sys $sysname -time 120");
#        if (EDR::cmdexit()) {
#            Msg::right_failed();
#            next;
#        }
        Msg::right_done();
    }
    return;
}

sub addnode_comp_message {
    $prod = shift;
    my $msg;
    my $web = Obj::web();

    $msg = Msg::new("\nThe new node has been added to the SF Oracle RAC cluster. If you want to add this node to Oracle Clusterware/Grid Infrastructure, follow Oracle's addnode procedure to install and configure the Oracle Clusterware/Grid Infrastructure and Database on the new nodes.");
    $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
    $msg->print;

    my $sys = @{$prod->{clusnodes}}[0];
    my $smallsys = Prod::VCS60::Common::transform_system_name($sys->{sys});
    my $vcs = $prod->prod('VCS60');
    my $cssd = eval {$sys->cmd("$vcs->{bindir}/hares -list Type=Application StartProgram=~cssd-online StopProgram=~cssd-offline MonitorProgram=~cssd-monitor CleanProgram=~cssd-clean Enabled=1 2>/dev/null | _cmd_grep -i $smallsys");};
    if ($cssd) {
        $msg = Msg::new("Also, remove the file $prod->{cssd_offline_file} from new nodes once you complete Oracle's addnode procedure. This file was created on new nodes to make the state of CSSD agent OFFLINE instead of keeping the default state UNKNOWN until you install and configure Oracle Clusterware/Grid Infrastructure and Database on the new nodes.");
        $web->web_script_form("alert", $msg->{msg}) if(Obj::webui());
        $msg->print;
    }
    Msg::prtc();
    return;
}

sub addnode_config_privnic {
    my $prod = shift;
    $prod->config_privnic_common(1, $prod->{allnodes}, $prod->{clusnodes}, $prod->{newnodes});
    return;
}

sub addnode_config_multiprivnic {
    my $prod = shift;
    $prod->config_multiprivnic_common(1, $prod->{allnodes}, $prod->{clusnodes}, $prod->{newnodes});
    return;
}

sub addnode_mount_ocr_and_vote {
    my $prod = shift;
    my ($sys, $msg, $question, $answer, $help, $ayn, $ret);
    my ($cmd, $vote_loc, $ocr_loc, $vote_dev, $ocr_dev, $ocrvote_dev, $is_loc_same);
    my (@vote_loc_parts, @ocr_loc_parts, $vote_cnt, $ocr_cnt, $cnt, $vote_mntp, $ocr_mntp);
    my $vcs = $prod->prod('VCS60');
    my $localsys = @{$prod->{clusnodes}}[0];

    Msg::title();
    $msg = Msg::new("This step will create the mount point(s) on which the filesystem used for Oracle clusterware OCR and Vote disks will be mounted. Skip this step if you are using raw volumes for the OCR and Vote disks.");
    $msg->print;

    Msg::prtc();

    # Check if VCS is running.
    if (!$prod->is_vcs_up($prod->{allnodes})) {
        $msg = Msg::new("\nVCS Engine is down on one or more nodes. Cannot proceed. Start VCS Engine on all the nodes and then try again.");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $ret = $prod->addnode_find_oracle_user_group($prod->{allnodes});
    if (($ret == 10) || ($ret == 7)) {
        # back option or error condition
        return $ret;
    }

    $ret = $prod->addnode_find_crs_home();
    if ($ret == 10) {
        # back option
        return $ret;
    }

    return 1 if ($prod->determine_crs_home('post_crs_install'));
    if (!$prod->is_crs_up($prod->{clusnodes})) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure is down on one or more nodes in the current cluster (without new nodes). Cannot proceed further. Start Oracle Clusterware/Grid Infrastructure on all the nodes in the current cluster and then try again.");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $localsys->cmd("_cmd_ls $prod->{crs_home}/bin/crsctl 2> /dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$prod->{crs_home}/bin/crsctl doesn't exist on $sys->{sys}");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $cmd = "$prod->{crs_home}/bin/crsctl query css votedisk | _cmd_head -n 1 |_cmd_awk '{print \$3}'";
    $vote_loc = $localsys->cmd("$cmd");
    if ($vote_loc eq '') {
        $msg = Msg::new("\nFailed to determine the location of the Vote disk. Check the logs for more details.");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $localsys->cmd("_cmd_ls $prod->{crs_home}/bin/ocrcheck 2> /dev/null");
    if (EDR::cmdexit() != 0) {
        $msg = Msg::new("$prod->{crs_home}/bin/ocrcheck doesn't exist on $sys->{sys}");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    $cmd = "$prod->{crs_home}/bin/ocrcheck | grep 'Device/File Name' | _cmd_awk '{print \$4}'";
    $ocr_loc = $localsys->cmd("$cmd");
    if ($ocr_loc eq '') {
        $msg = Msg::new("\nFailed to determine the location of the OCR disk. Check the logs for more details.");
        $msg->print;
        Msg::prtc();
        return 1;
    }

    @vote_loc_parts = split("\/", $vote_loc);
    @ocr_loc_parts = split("\/", $ocr_loc);
    $vote_cnt = @vote_loc_parts;
    $ocr_cnt = @ocr_loc_parts;
    $is_loc_same = 1;
    $vote_mntp = '';
    $ocr_mntp = '';

    if (($vote_loc_parts[1] eq 'dev') && ($ocr_loc_parts[1] eq 'dev')) {
        $is_loc_same = ($vote_loc eq $ocr_loc);
    } else {
        if ($vote_loc_parts[1] ne 'dev') {
            $vote_mntp = $prod->addnode_get_mntpt($vote_loc, $localsys);
        }

        if ($ocr_loc_parts[1] ne 'dev') {
            $ocr_mntp = $prod->addnode_get_mntpt($ocr_loc, $localsys);
        }

        if (($vote_loc_parts[1] ne 'dev') && ($ocr_loc_parts[1] ne 'dev')) {
            $is_loc_same = ($vote_mntp eq $ocr_mntp);
        } else {
            $is_loc_same = 0;
        }
    }

    if ($is_loc_same) {
        if ($vote_loc_parts[1] ne 'dev') {
            $ocrvote_dev = $prod->addnode_get_mntdev($vote_mntp, $localsys);
            if ($ocrvote_dev eq '') {
                $msg = Msg::new("Failed to determine the device name used for OCR and Vote disks. Check the logs for more details.");
                $msg->print;
                Msg::prtc();
                return 2;
            }
        }

        Msg::title();
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure OCR and Vote disks information verification:");
        $msg->bold;
        if ($vote_loc_parts[1] eq 'dev') {
            $msg = Msg::new("OCR Vote device name: $vote_loc");
            $msg->print;
            $msg = Msg::new("OCR Vote mount point: none (configured on raw volume)");
            $msg->print;
        } else {
            $msg = Msg::new("OCR Vote device name: $ocrvote_dev");
            $msg->print;
            $msg = Msg::new("OCR Vote mount point: $vote_mntp");
            $msg->print;
        }

        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 0;
        }

        if ($vote_loc_parts[1] eq 'dev') {
            # check the device on new nodes.
            return 0;
        }

        $msg = Msg::new("Creating mount point on new node(s)");
        $msg->left;
        $ret = $prod->addnode_create_dir($vote_mntp, $prod->{oracle_user},
                                   $prod->{oracle_group}, '755', $prod->{newnodes});
        if ($ret) {
            Msg::right_failed();
            $msg = Msg::new("Failed to create mount point $vote_mntp on one or more node(s). Check the logs for more details.");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        Msg::right_done();

        $msg = Msg::new("Mounting $ocrvote_dev on $vote_mntp on new node(s)");
        $msg->left;
        $ret = $prod->addnode_mount_dev($vote_mntp, $ocrvote_dev, $prod->{newnodes});
        if ($ret) {
            Msg::right_failed();
            $msg = Msg::new("Failed to mount on one or more node(s). Check the logs for more details.");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        Msg::right_done();

        # ToDo: online CFSmount

    } else {
        if ($ocr_loc_parts[1] ne 'dev') {
            $ocr_dev = $prod->addnode_get_mntdev($ocr_mntp, $localsys);
            if ($ocr_dev eq '') {
                $msg = Msg::new("Failed to determine the device name used for OCR disk. Check the logs for more details.");
                $msg->print;
                Msg::prtc();
                return 2;
            }
        }

        if ($vote_loc_parts[1] ne 'dev') {
            $vote_dev =$prod->addnode_get_mntdev($vote_mntp, $localsys);
            if ($vote_dev eq '') {
                $msg = Msg::new("Failed to determine the device name used for Vote disk. Check the logs for more details.");
                $msg->print;
                Msg::prtc();
                return 2;
            }
        }

        Msg::title();
        $msg = Msg::new("Oracle Clusterware/Grid Infrastructure OCR and Vote disks information verification:");
        $msg->bold;
        if ($ocr_loc_parts[1] eq 'dev') {
            $msg = Msg::new("OCR device name: $ocr_loc");
            $msg->print;
            $msg = Msg::new("OCR mount point: none (configured on raw volume)");
            $msg->print;
        } else {
            $msg = Msg::new("OCR device name: $ocr_dev");
            $msg->print;
            $msg = Msg::new("OCR mount point: $ocr_mntp");
            $msg->print;
        }
        if ($vote_loc_parts[1] eq 'dev') {
            $msg = Msg::new("Vote device name: $vote_loc");
            $msg->print;
            $msg = Msg::new("Vote mount point: none (configured on raw volume)");
            $msg->print;
        } else {
            $msg = Msg::new("Vote device name: $vote_dev");
            $msg->print;
            $msg = Msg::new("Vote mount point: $vote_mntp");
            $msg->print;
        }

        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 0;
        }

        if (($ocr_loc_parts[1] eq 'dev') && ($vote_loc_parts[1] eq 'dev')) {
            # check the device on new nodes.
            return 0;
        }

        $msg = Msg::new("Creating mount points on new node(s)");
        $msg->left;
        $ret = 0;
        if ($ocr_loc_parts[1] ne 'dev') {
            $ret = $prod->addnode_create_dir($ocr_mntp, $prod->{oracle_user},
                                     $prod->{oracle_group}, '755', $prod->{newnodes});
        }

        if ($vote_loc_parts[1] ne 'dev') {
            $ret |= $prod->addnode_create_dir($vote_mntp, $prod->{oracle_user},
                                    $prod->{oracle_group}, '755', $prod->{newnodes});
        }

        if ($ret) {
            Msg::right_failed();
            $msg = Msg::new("Failed to create above mount point(s) on one or more node(s). Check the logs for more details.");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        Msg::right_done();

        if ($ocr_loc_parts[1] ne 'dev') {
            $msg = Msg::new("Mounting $ocr_dev on $ocr_mntp on new node(s)");
            $msg->left;
            $ret = $prod->addnode_mount_dev($ocr_mntp, $ocr_dev, $prod->{newnodes});
            if ($ret) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }
        }

        if ($vote_loc_parts[1] ne 'dev') {
            $msg = Msg::new("Mounting $vote_dev on $vote_mntp on new node(s)");
            $msg->left;
            my $ret1 = $prod->addnode_mount_dev($vote_mntp, $vote_dev, $prod->{newnodes});
            if ($ret1) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }

            $ret = $ret | $ret1;
        }

        if ($ret) {
            $msg = Msg::new("Failed to mount on one or more nodes. Check the logs for more details.");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        # ToDo: online CFSmount
    }

    Msg::prtc();
    return 0;
}

#Plat specific func: default Solaris
sub addnode_get_mntdev {
    my ($prod, $mpoint, $sys) = @_;
    my ($cmd, $mnt_dev);

    $cmd = "_cmd_mount | _cmd_grep -w $mpoint | _cmd_awk '{print \$3}'";
    $mnt_dev = $sys->cmd("$cmd");
    return $mnt_dev;
}

#Plat specific func: default Solaris
sub addnode_mount_dev {
    my ($prod, $mpoint, $dev, $nodes_ref) = @_;
    my ($sys, $cmd, $msg, $isfailed);

    $isfailed = 0;
    for my $sys (@{$nodes_ref}) {
        if (!$prod->addnode_get_mntdev($mpoint, $sys)) {
            $cmd = "_cmd_mount -F vxfs -o cluster,largefiles $dev $mpoint";
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                $isfailed = 1;
            }
        }
    }
    return $isfailed;
}

sub addnode_get_mntpt {
    my ($prod, $path, $sys) = @_;
    my ($cmd, $mntpt);

    $mntpt = EDR::cmd_local("$prod->{mount_points} | _cmd_grep $path");
    if (EDR::cmdexit()) {
        return '';
    }
    return $mntpt;
}

sub addnode_online_CFSMount_res {
    my ($prod, $mpoint, $sys) = @_;

    $sys->cmd("$vcs->{bindir}/hares -display -type CFSMount");
    if (EDR::cmdexit() == 0) {
        $cmd = "$vcs->{bindir}/hares -display -type CFSMount | _cmd_grep MountPoint | _cmd_awk '{print \$4}' | _cmd_grep -w '$mpoint'";
        $sys->cmd("$cmd");
        if (EDR::cmdexit() == 0) {
            #Online the resource if it is not already
            return 0;
        }
    }

    return 1;
}

sub addnode_install_oracle_crs_and_db {
    my $prod = shift;
    my ($sys, $msg, $question, $answer, $help, $cmd, $ayn, $ret);
    $help = '';

    Msg::title();
    $msg = Msg::new("This step will create home directories for the Oracle Clusterware/Grid Infrastructure and Database on new nodes where you can install these using Oracle's addnode scripts. You need to mount the necessary filesystems before you proceed further if these home directories are on the mounted filesystem. Skip this step if you are not going to install Oracle Clusterware/Grid Infrastructure and Database on new nodes.");
    $msg->print;

    Msg::prtc;

    while (1) {
        $ret = $prod->addnode_find_oracle_user_group($prod->{allnodes});
        if (($ret == 10) || ($ret == 7)) {
            # back option or error condition
            return $ret;
        }

        $ret = $prod->addnode_find_crs_home();
        if ($ret == 10) {
            return $ret;
        }

        $ret = $prod->addnode_find_db_home();
        if ($ret == 10) {
            return $ret;
        }

        Msg::title();
        $msg = Msg::new("Oracle environment information verification");
        $msg->bold;
        $msg = Msg::new("\tOracle UNIX User: $prod->{oracle_user}");
        $msg->print;
        $msg = Msg::new("\tOracle UNIX Group: $prod->{oracle_group}");
        $msg->print;
        $msg = Msg::new("\tOracle Clusterware/Grid Infrastructure Home: $prod->{crs_home}");
        $msg->print;
        $msg = Msg::new("\tOracle Database Home: $prod->{db_home}");
        $msg->print;
        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny;
        if ($ayn eq 'Y') {
            last;
        }
    }

    $msg = Msg::new("Creating Oracle Clusterware/Grid Infrastructure Home on new node(s)");
    $msg->left;
    $ret = $prod->addnode_create_dir($prod->{crs_home}, $prod->{oracle_user},
                             $prod->{oracle_group}, '755', $prod->{newnodes});
    if ($ret) {
        Msg::right_failed();
        $msg = Msg::new("Failed to create $prod->{crs_home} on one or more nodes. Check the logs for more details.");
        $msg->print;
        Msg::prtc();
        return 1;
    }
    Msg::right_done();

    $msg = Msg::new("Creating Oracle Database Home on new node(s)");
    $msg->left;
    $ret = $prod->addnode_create_dir($prod->{db_home}, $prod->{oracle_user},
                               $prod->{oracle_group}, '755', $prod->{newnodes});
    if ($ret) {
        Msg::right_failed();
        $msg = Msg::new("Failed to create $prod->{db_home} on one or more nodes. Check the logs for more details.");
        $msg->print;
        Msg::prtc();
        return 1;
    }
    Msg::right_done();

    Msg::prtc();

    #ToDo: Invoke Oracle GUI installer

    return 0;
}

sub addnode_find_crs_home {
    my $prod = shift;
    my ($sys, $msg, $question, $answer, $help, $cmd, $ayn, $ret);
    $help = '';

    while (1) {
        $question = Msg::new("Enter absolute path of Oracle Clusterware/Grid Infrastructure Home directory:");
        $answer = $question->ask($prod->{crs_home}, $help, 1);
        return 10 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);

        if ($answer !~ /^[0-9a-zA-Z|\-|\_|\/]*$/mx) {
            $msg = Msg::new("Invalid name chosen. Input again");
            $msg->print;
            next;
        }

        for my $sys (@{$prod->{clusnodes}}) {
            if (!$sys->exists("$answer/bin/crs_stat")) {
                $msg = Msg::new("Oracle Clusterware/Grid Infrastructure does not seem to be installed at $answer on $sys->{sys}. Input correct path.");
                $msg->print;
                goto LOOP;
            }
        }
        $prod->{crs_home} = $answer;
        last;
LOOP:
    }

    return 0;
}

sub addnode_find_db_home {
    my $prod = shift;
    my ($sys, $msg, $question, $answer, $help, $cmd, $ayn, $ret);
    $help = '';

    while (1) {
        $question = Msg::new("Enter absolute path of Oracle Database Home directory:");
        $answer = $question->ask($prod->{db_home}, $help, 1);
        return 10 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);

        if ($answer !~ /^[0-9a-zA-Z|\-|\_|\/]*$/mx) {
            $msg = Msg::new("Invalid name chosen. Input again");
            $msg->print;
            next;
        }

        for my $sys (@{$prod->{clusnodes}}) {
            if (!$sys->exists("$answer/bin/oracle")) {
                $msg = Msg::new("Oracle database does not seem to be installed at $answer on $sys->{sys}. Input correct path.");
                $msg->print;
                goto LOOP;
            }
        }
        $prod->{db_home} = $answer;
        last;
LOOP:
    }
    return 0;
}

sub addnode_check_resource {
    my ($prod, $res_type, $sys) = @_;
    my (@resources, @tmp_rsrcs, $res_names, $rsrc);
    my ($ip_addr, $msg, $cmd);
    my $vcs = $prod->prod('VCS60');
    my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});

    @resources = ();

    $sys->cmd("$vcs->{bindir}/hares -display -type $res_type");
    if (EDR::cmdexit() == 0) {
        $cmd = "$vcs->{bindir}/hares -display -type $res_type | _cmd_grep Device | _cmd_awk '{print \$1}' | _cmd_uniq";
        $res_names = $sys->cmd("$cmd");
        chomp($res_names);
        @tmp_rsrcs = split(/\n/, $res_names);

        for my $rsrc (@tmp_rsrcs) {
            $cmd = "$vcs->{bindir}/hares -display $rsrc | _cmd_grep Device | _cmd_grep $sysname | _cmd_awk '{print \$4}'";
            $ip_addr = $sys->cmd("$cmd");
            chomp($ip_addr);
            if ($ip_addr eq '') {
                push(@resources, $rsrc);
            }
        }

    }
done:
    return \@resources;
}

sub addnode_populate_privrsrc_info {
    my ($prod, $res_name, $nodes_ref, $systems_ref) = @_;
    my ($sys, $cmd, $ip_addr, $alias);
    my %systems = %$systems_ref;
    my $vcs = $prod->prod('VCS60');
    my $web = Obj::web();

    for my $sys (@{$nodes_ref}) {
        my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
        $cmd = "$vcs->{bindir}/hares -value $res_name Address $sysname";
        $ip_addr = $sys->cmd("$cmd");
        chomp($ip_addr);
        if ($ip_addr eq '') {
            $msg = Msg::new("Failed to get the resource $res_name information (IP address). Check the logs for more details.");
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            $msg->print;
            Msg::prtc();
            return 1;
        }

        $systems{$sys->{sys}}{'ip'} = "$ip_addr";

        $alias = $prod->addnode_get_alias($sys, "$ip_addr");
        if ($alias ne '') {
            $systems{$sys->{sys}}{'alias'} = "$alias";
        } else {
            $systems{$sys->{sys}}{'alias'} = '';
            $msg = Msg::new("Didn't find hostname/alias for $ip_addr in /etc/hosts and $prod->{hosts_file} files");
            $msg->log;
        }
    }

    return 0;
}

sub addnode_populate_mprivrsrc_info {
    my ($prod, $res_name, $nodes_ref, $systems_ref) = @_;
    my ($line, @words, $word, $ip_addr, $inf, $flag);
    my ($alias, $sys, $cmd, $msg);
    my %systems = %$systems_ref;
    my $vcs = $prod->prod('VCS60');
    my $web = Obj::web();

    for my $sys (@{$nodes_ref}) {
        my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
        $cmd = "$vcs->{bindir}/hares -display $res_name | _cmd_grep Address | _cmd_grep $sysname";
        $line = $sys->cmd("$cmd");
        chomp($line);
        if ($line) {
            @words = split(/\s+/m, $line);
            shift(@words);shift(@words);shift(@words);
            $flag = 1;
            for my $word (@words) {
                if ($flag) {
                    $flag = 0;
                    $ip_addr = $word;
                    if ($ip_addr ne '') {
                        $alias = $prod->addnode_get_alias($sys, $ip_addr);
                    }
                            } else {
                    $flag = 1;
                    if ($ip_addr ne '') {
                        $inf = @{$systems{$sys->{sys}}{'inf'}}[$word + 0];
                        push(@{$systems{$sys->{sys}}{'ip'}{$inf}}, $ip_addr);
                        if ($alias ne '') {
                             push(@{$systems{$sys->{sys}}{'alias'}{$inf}}, $alias);
                        }
                    }
                }
            }
        }
    }

    return 0;
}

sub addnode_get_alias {
    my ($prod, $sys, $ip_addr) = @_;
    my (@ip_parts, $uniq_ip, $alias);

    # Truncate the subnet prefix part in case of IPv6 address.
    @ip_parts = split(/\//m, $ip_addr);
    $uniq_ip = $ip_parts[0];

    $alias = $prod->addnode_get_alias_from_file($sys, '/etc/hosts', "$uniq_ip");
    if (($alias eq '') && ($prod->{hosts_file} ne '/etc/hosts')) {
        $alias = $prod->addnode_get_alias_from_file($sys, $prod->{hosts_file}, "$uniq_ip");
    }

    return $alias;
}

sub addnode_get_alias_from_file {
    my ($prod, $sys, $file, $ip_addr) = @_;
    my ($output, @lines, @words, $line, $word_cnt, $alias);

    $alias = '';
    $output = $sys->cmd("_cmd_grep -v '^#' $file");
    @lines = split(/\n/,  $output);

    for my $line (@lines) {
        chomp($line);
        @words = split(/\s+/m, $line);
        $word_cnt = @words;
        #Take the last one if multiple entries are there
        if (($word_cnt > 1) && ($words[0] eq $ip_addr)) {
            $alias = $words[1];
        }
    }

    return $alias;
}

sub addnode_create_oracle_user_group {
    my $prod = shift;
    my ($msg, $ret, $ayn);
    my ($oragrp_exists, $orausr_exists, $orahome_exists);
    my $web = Obj::web();

    $oragrp_exists = 0;
    $orausr_exists = 0;
    $orahome_exists = 0;

    Msg::title();
    $msg = Msg::new("This step will create Oracle user and groups on the new nodes being added. For this, you need to provide the Oracle user and group names which are already being used in the current cluster for Oracle operations. The same Oracle user and groups will be created on the new nodes with the same uid and gid. These Oracle user and groups should not already exist on the new nodes, if exist, then the uid and gid of these Oracle user and groups must be same to the uid and gid used in the current cluster for these.");
    $msg->print;
    $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
    Msg::prtc();

    while (1) {
        $ret = $prod->addnode_find_oracle_user_group($prod->{clusnodes});
        if (($ret == 10) || ($ret == 7)) {
            # back option or error condition
            if ($ret == 10) {
                return 0;
            }
            return 7;
        }
        Msg::title();
        if (Obj::webui()) {
            my $mesg="";
            $msg = Msg::new("Oracle user/group information verification: \\n");
            $mesg .=$msg->{msg};
            $msg = Msg::new("Oracle UNIX user name: $prod->{oracle_user}\\n");
            $mesg .=$msg->{msg};
            $msg = Msg::new("Oracle UNIX group name: $prod->{oracle_group}\\n");
            $mesg .=$msg->{msg};
            $msg = Msg::new("Oracle user's home directory: $prod->{oracle_user_home}\\n");
            $mesg .=$msg->{msg};
            $msg = Msg::new("Oracle user ID (UID): $prod->{oracle_uid}\\n");
            $mesg .=$msg->{msg};
            $msg = Msg::new("Oracle group ID (GID): $prod->{oracle_gid}\\n");
            $mesg .=$msg->{msg};
            $msg = Msg::new("\\nIs this information correct?");
            $mesg .=$msg->{msg};
            $msg = Msg::new($mesg);


        } else {
            $msg = Msg::new("Oracle user/group information verification:");
            $msg->bold;
            $msg = Msg::new("\tOracle UNIX user name: $prod->{oracle_user}");
            $msg->print;
            $msg = Msg::new("\tOracle UNIX group name: $prod->{oracle_group}");
            $msg->print;
            $msg = Msg::new("\tOracle user ID (UID): $prod->{oracle_uid}");
            $msg->print;
            $msg = Msg::new("\tOracle group ID (GID): $prod->{oracle_gid}");
            $msg->print;
            $msg = Msg::new("\tOracle secondary groups: $prod->{oracle_sgroups}");
            $msg->print;
            $msg = Msg::new("\tOracle user's home directory: $prod->{oracle_user_home}");
            $msg->print;
            $msg = Msg::new("\nIs this information correct?");
        }
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            next;
        }

        Msg::n();

        $ret = $prod->addnode_validate_oragrp_on_clusnodes($prod->{oracle_group},
                                               '0', $prod->{clusnodes});
        if ($ret != 2) {
            $msg = Msg::new("\nDo you want to enter different Oracle user name?");
            $ayn = $msg->ayny;
            if ($ayn eq 'N') {
                return 1;
            }
            next;
        }
        last;
    }

    $ret = $prod->addnode_validate_oragrp_on_newnodes($prod->{oracle_group},
                                   $prod->{oracle_gid}, $prod->{newnodes});
    if (($ret == 3) || ($ret == 6) || ($ret == 10)) {
        return $ret;
    } elsif ($ret == 2) {
        $oragrp_exists = 1;
    }

    $ret = $prod->addnode_validate_orauser_on_newnodes($prod->{oracle_user},
                        $prod->{oracle_uid}, $prod->{oracle_group}, $prod->{newnodes});
    if (($ret == 3) || ($ret == 6) || ($ret == 7) || ($ret == 10)) {
        return $ret;
    } elsif ($ret == 2) {
        $orausr_exists = 1;
    }

    $ret = $prod->addnode_validate_orahomedir_on_newnodes($prod->{oracle_user},
               $prod->{oracle_group}, $prod->{oracle_user_home}, $prod->{newnodes});
    if ($ret == 3) {
        return $ret;
    } elsif ($ret == 2) {
        $orahome_exists = 1;
    }

    if (!$oragrp_exists) {
        $ret = $prod->addnode_create_oragroup($prod->{oracle_group},
                                       $prod->{oracle_gid}, $prod->{newnodes});
        if ($ret) {
            $msg = Msg::new("Failed to add group on one or more new nodes. Check the logs for more details.");
            $msg->print;
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            Msg::prtc();
            return $ret;
        }
    }

    if (!$orausr_exists) {
        $ret = $prod->addnode_create_orauser($prod->{oracle_user}, $prod->{oracle_uid},
                                  $prod->{oracle_gid}, $prod->{oracle_user_home}, $prod->{newnodes});
        if ($ret) {
            $msg = Msg::new("Failed to add/modify user on one or more nodes. Check the logs for more details.");
            $msg->print;
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            Msg::prtc();
            return $ret;
        }
    }

    if (!$orahome_exists) {
        $ret = $prod->addnode_create_dir($prod->{oracle_user_home},
                  $prod->{oracle_user}, $prod->{oracle_group}, '755', $prod->{newnodes});
        if ($ret) {
            $msg = Msg::new("Failed to create Oracle home directory $prod->{oracle_user_home} on one or more nodes. Check the logs for more details.");
            $msg->print;
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            Msg::prtc();
            return $ret;
        }
    }

    if (!$orausr_exists) {
        $msg = Msg::new("\nYou need to set the password of the Oracle user $prod->{oracle_user} manually before you configure ssh/rsh connection on these nodes");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    }

    if ($prod->{oracle_sgroups}) {
        $msg = Msg::new("Do you want to configure secondary group(s) on new nodes?");
        $ayn= $msg->ayny;
        if ($ret eq 'N') {
            return 0;
        }

        $ret = $prod->addnode_conf_sgroups_on_new_nodes($prod->{oracle_user},
                   $prod->{oracle_sgroups}, $prod->{clusnodes}, $prod->{newnodes});
        if ($ret) {
            Msg::prtc();
        }
    }

    return 0;
}

sub addnode_find_oracle_user_group {
    my ($prod, $nodes_ref) = @_;
    my ($answer, $help, $msg, $backopt, $question, $ret);
    my $web = Obj::web();

    $help = '';
    $backopt = 1;

    while (1) {

        if (Obj::webui()) {
            $answer=$web->web_script_form("addnode_user", $prod);
            if ($web->param("back") eq "back") {
                return 10 ;
            }
        }
        else {
            $question = Msg::new("Enter Oracle UNIX user name: ");
            $answer = $question->ask($prod->{oracle_user}, $help, $backopt);
            chomp($answer);
            return 10 if (EDR::getmsgkey($answer,'back'));
        }

        next if ($prod->validate_oraugname($answer));

        # Validate Oracle user on nodes in the current cluster
        $ret = $prod->addnode_validate_orauser($answer, '0', '', $nodes_ref);
        if ($ret == 0) {
            $msg = Msg::new("Oracle user $answer doesn't exist on any node in the current cluster.\nInput again");
            $msg->print;
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            next;
        } elsif ($ret == 1) {
            $msg = Msg::new("Oracle user $answer doesn't exist on all the nodes in the current cluster.\nInput again");
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            $msg->print;
            next;
        } elsif ($ret == 2) {
            #
            # Oracle user $answer exists on all the nodes with
            # correct attributes.
            #
            $prod->{oracle_user} = $answer;
            # Set primary and other groups for this user.
            my $system = @{$nodes_ref}[0];
            if ($prod->determine_group($system, $answer)) {
                $msg = Msg::new("Failed to determining the groups for the Oracle user $answer on $system->{sys}");
                $msg->print;
                $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
                Msg::prtc();
                $ret = 7;
            }
            last;
        } elsif ($ret == 3) {
            $msg = Msg::new("Oracle user $answer has different UID on one or more nodes in the current cluster.\nInput again");
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            $msg->print;
            next;
        } elsif (($ret == 4) || ($ret == 5)) {
            $msg = Msg::new("Oracle user $answer has different primary group on one or more nodes in the current cluster.\nInput again");
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            $msg->print;
            next;
        } elsif ($ret == 7) {
            $msg = Msg::new("Command failed. Check the logs for more details.");
            $msg->print;
            $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
            Msg::prtc();
            last;
        }
    } #while

    return $ret;
}

sub addnode_validate_orauser_on_newnodes {
    my ($prod, $user_name, $uid, $grp_name, $newnodes_ref) = @_;
    my ($msg, $ayn, $ret);
    my $web = Obj::web();

    # Validate Oracle user on new nodes
    $ret = $prod->addnode_validate_orauser($user_name, $uid,
                                           $grp_name, $newnodes_ref);
    #if ($ret == 0) Oracle user doesn't exist on any new node.
    if ($ret == 1) {
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on one or more new nodes. Installer will create it on the remaining nodes.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on one or more new nodes. Installer will create it on the remaining nodes. Do you want to continue?") if(Obj::webui());
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 10;
        }
    } elsif ($ret == 2) {
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on all new nodes with correct attributes");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    } elsif ($ret == 3) {
        $msg = Msg::new("Oracle user $prod->{oracle_user} has different UID on one or more new nodes. Correct this manually and retry.");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    } elsif ($ret == 4) {
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on some new nodes, but has a different primary group set on one or more new nodes. Installer will create it on the remaining nodes and set the Oracle group $grp_name as a primary group for it on all new nodes.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on some new nodes, but has a different primary group set on one or more new nodes. Installer will create it on the remaining nodes and set the Oracle group $grp_name as a primary group for it on all new nodes. Do you want to continue?") if(Obj::webui());
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 10;
        }
    } elsif ($ret == 5) {
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on all new nodes, but has a different primary group set on one or more new nodes. Installer will set the Oracle group $grp_name as a primary group for this Oracle user on all new nodes.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        $msg = Msg::new("Oracle user $prod->{oracle_user} already exists on all new nodes, but has a different primary group set on one or more new nodes. Installer will set the Oracle group $grp_name as a primary group for this Oracle user on all new nodes. Do you want to continue?") if(Obj::webui());
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 10;
        }
    } elsif ($ret == 6) {
        $msg = Msg::new("The UID $uid already in use on one or more new nodes for other user. Correct this manually and retry.");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    } elsif ($ret == 7) {
        $msg = Msg::new("Command failed. Check the logs for more details.");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    }

    return $ret;
}

sub addnode_validate_oragrp_on_clusnodes {
    my ($prod, $grp_name, $gid, $clusnode_ref) = @_;
    my ($ret, $msg);
    my $web = Obj::web();

    # Validate Oracle group on nodes in the current cluster
    $ret = $prod->addnode_validate_oragroup($grp_name, $gid, $clusnode_ref);
    if ($ret == 0) {
        $msg = Msg::new("Oracle group $grp_name doesn't exist on any node in the current cluster");
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        $msg->print;
    } elsif ($ret == 1) {
        $msg = Msg::new("Oracle group $grp_name doesn't exist on all the nodes in the current cluster");
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        $msg->print;
    } elsif ($ret == 3) {
        $msg = Msg::new("Oracle group $grp_name has different GID on one or more nodes in the current cluster");
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        $msg->print;
    }

    # ($ret == 2) ==> exists on all the nodes with the same GID

    return $ret;
}

sub addnode_validate_oragrp_on_newnodes {
    my ($prod, $grp_name, $gid, $newnode_ref) = @_;
    my ($msg, $ret, $ayn);
    my $web = Obj::web();

    # Validate Oracle group on new nodes
    $ret = $prod->addnode_validate_oragroup($grp_name, $gid, $newnode_ref);
    #if ($ret == 0) Oracle group doesn't exist on any new node.
    if ($ret == 1) {
        $msg = Msg::new("Oracle group $grp_name already exists on one or more new nodes. Installer will create it on the remaining nodes.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        $ayn = $msg->ayny;
        if ($ayn eq 'N') {
            return 10;
        }
    } elsif ($ret == 2) {
        $msg = Msg::new("Oracle group $grp_name already exists on all new nodes with correct GID");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    } elsif ($ret == 3) {
        $msg = Msg::new("Oracle group $grp_name already exists on one or more new nodes, but has different GID than the GID used in the current cluster. Correct this manually and retry.");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    } elsif ($ret == 6) {
        $msg = Msg::new("The GID $gid already in use on one or more new nodes for other group. Correct this manually and retry.");
        $msg->print;
        $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
        Msg::prtc();
    }

    return $ret;
}

# addnode_validate_orauser
# Retun values:
#  0 : given user doesn't exist on any node
#  1 : given user exists on some nodes
#  2 : given user exists on all nodes
#  3 : given user exists on one or more nodes but
#      with different UID
#  4 : given user exists on some nodes but with
#      different GID
#  5 : given user exists on all nodes but with
#      different primary group
#  6 : given GID already in use for other user
#  7 : error.
sub addnode_validate_orauser {
    my ($prod, $orauser, $uid, $oragrp, $systems_ref) = @_;
    my ($passwdfile_usr, $puser, $puserid, $pgroup, $puserhome, $temp);
    my ($orauserid, $oragroup, $orausr_exists);
    my ($difforagrp, $nsystems, $csystems);
    my ($msg, $sys, $ret);

    $csystems = $#{$systems_ref} + 1;
    $nsystems = 0;
    $orausr_exists = 0;
    $difforagrp = 0;
    $orauserid = $uid;
    $oragroup = $oragrp;
    for my $sys (@{$systems_ref}) {
        $passwdfile_usr = $sys->cmd("_cmd_cat /etc/passwd | _cmd_grep '^$orauser:'");
        if ($passwdfile_usr) {
            ($puser, $temp, $puserid, $temp, $temp, $puserhome, $temp) = split(/:/m, $passwdfile_usr, 7);
            $orausr_exists = 1;
            $nsystems++;
            $msg = Msg::new("Oracle user $orauser exists on $sys->{sys}");
            $msg->log;

            if ($orauserid eq '0') {
                $orauserid = $puserid;
            } else {
                if ($puserid ne $orauserid) {
                    return 3;
                }
            }

            $pgroup = $prod->addnode_get_group($sys, $orauser);
            if ($oragroup eq '') {
                $oragroup = $pgroup;
            } else {
                if ($pgroup ne $oragroup) {
                    $difforagrp = 1;
                }
            }
        } else {
            if ($orauserid ne '0') {
                $sys->cmd("_cmd_cat /etc/passwd | _cmd_awk -F':' '{print \$3}' | _cmd_grep -w $orauserid");
                if (EDR::cmdexit() == 0) {
                    return 6;
                }
            }
        }
    } #for

    if ($orausr_exists == 0) {
        return 0;
    }

    if ($nsystems == $csystems) {
        if ($difforagrp) {
            return 5;
        } else {
            $prod->{oracle_uid} = $orauserid;
            $prod->{oracle_user_home} = $puserhome;
            return 2;
        }
    } else {
        if ($difforagrp) {
            return 4;
        } else {
            return 1;
        }
    }
}

# This func is plat specific: default: AIX
sub addnode_get_group {
    my ($prod, $sys, $user) = @_;
    my ($groups, $grp);

    $groups = $sys->cmd("_cmd_groups $user");
    chomp($groups);
    $grp = (split(/\s+/m, $groups))[2];

    return $grp;
}

sub addnode_validate_oragroup {
    my ($prod, $oragroup, $gid, $systems_ref) = @_;
    my ($pgroup, $pgroupid, $oragroupid, $temp);
    my ($group_exists, $nsystems, $csystems);
    my ($msg, $sys, $ret);

    $csystems = $#{$systems_ref} + 1;
    $nsystems = 0;
    $oragroupid = $gid;
    $group_exists = 0;
    for my $sys (@{$systems_ref}) {
        $groupfile_entry = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$oragroup:'");
        if ($groupfile_entry) {
            ($pgroup, $temp, $pgroupid, $temp) = split(/:/m, $groupfile_entry, 4);
            $group_exists = 1;
            $nsystems++;
            $msg = Msg::new("Oracle group $oragroup exists on $sys->{sys}");
            $msg->log;
            if ($oragroupid eq '0') {
                $oragroupid = $pgroupid;
            } else {
                if ($pgroupid ne $oragroupid) {
                    return 3;
                }
            }
        } else {
            if ($oragroupid ne '0') {
                $sys->cmd("_cmd_cat /etc/group | _cmd_awk -F':' '{print \$3}' | _cmd_grep -w $oragroupid");
                if (EDR::cmdexit() == 0) {
                    return 6;
                }
            }
        }
    }

    if ($group_exists == 0 ) {
        return 0;
    }

    if ($nsystems == $csystems) {
        return 2;
    } else {
        return 1;
    }
}

# This func is plat specific: default: SOL
sub addnode_create_oragroup {
    my ($prod, $group, $gid, $systems_ref) = @_;
    my ($sys, $groupfile_entry, $pgid, $temp, $msg, $isfailed);

    $isfailed = 0;
    for my $sys (@{$systems_ref}) {
        $groupfile_entry = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$group'");
        if (!$groupfile_entry) {
            $msg = Msg::new("Adding Oracle group $group with GID $gid on $sys->{sys}");
            $msg->left;
            $sys->cmd("_cmd_groupadd -g $gid $group");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $isfailed = 1;
                next;
            }
            Msg::right_done();
        }
    }

    return $isfailed;
}

sub addnode_create_orauser {
    my ($prod, $user, $uid, $gid, $homedir, $systems_ref) = @_;
    my ($sys, $passwdfile_entry, $puid, $pgid, $temp, $msg, $isfailed, $basedir);

    $isfailed = 0;
    for my $sys (@{$systems_ref}) {
        $passwdfile_entry = $sys->cmd("_cmd_cat /etc/passwd | _cmd_grep '^$user:'");
        if ($passwdfile_entry) {
            ($temp, $temp, $puid, $pgid, $temp, $temp, $temp) = split(/:/m, $passwdfile_entry, 7);
            if ($pgid ne $gid) {
                $msg = Msg::new("Changing primary group ID of Oracle user $user to GID $gid on $sys->{sys}");
                $msg->left;
                $sys->cmd("_cmd_usermod -g $gid $user");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    $isfailed = 1;
                    next;
                }
                Msg::right_done();
                next;
            }
        } else {
            $msg = Msg::new("Adding Oracle user $user with UID $uid on $sys->{sys}");
            $msg->left;
            if (!$sys->is_dir("$homedir")) {
                $basedir = $sys->cmd("dirname $homedir");
                $sys->cmd("mkdir -p $basedir");
                $sys->cmd("_cmd_useradd -md $homedir -g $gid -u $uid $user");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    $isfailed = 1;
                    next;
                }
            } else {
                $sys->cmd("_cmd_useradd -d $homedir -g $gid -u $uid $user");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    $isfailed = 1;
                    next;
                }
                $sys->cmd("chown $uid:$gid $homedir");
                $sys->cmd("_cmd_chmod 755 $homedir");
            }
            Msg::right_done();
        }
    }
    return $isfailed;
}

sub addnode_validate_orahomedir_on_newnodes {
    my ($prod, $user, $group, $homedir, $systems_ref) = @_;
    my ($sys, $ls_output, $puser, $pgroup, $temp, $msg, $ayn);
    my ($csystems, $nsystems);

    $csystems = $#{$systems_ref} + 1;
    $nsystems = 0;
    for my $sys (@{$systems_ref}) {
        $ls_output = $sys->cmd("_cmd_ls -ld $homedir");
        if (EDR::cmdexit() == 0) {
            $nsystems++;
        }
    }

    if ($csystems == $nsystems) {
        return 2;
    } else {
        return 1;
    }

    return 0;
}

sub addnode_conf_sgroups_on_new_nodes {
    my ($prod, $orauser, $oragroups, $clusnodes_ref, $newnodes_ref) = @_;
    my (@groups, $grp, $gid, $temp, $groupfile_entry);
    my ($sys, $localsys, $ret, $err, $msg);
    my $web = Obj::web();

    $err = 0;
    $localsys = @{$clusnodes_ref}[0];
    @groups = split(/\s/m, $oragroups);
    for my $grp (@groups) {
        $groupfile_entry = $localsys->cmd("_cmd_cat /etc/group | _cmd_grep '^$grp:'");
        if ($groupfile_entry) {
            ($temp, $temp, $gid, $temp) = split(/:/m, $groupfile_entry, 4);
            $ret = $prod->addnode_validate_oragroup($grp, $gid, $newnodes_ref);
            if ($ret == 3) {
                $msg = Msg::new("Oracle group $grp already exists on one or more new nodes with different GID. Correct this manually and retry.");
                $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
                $msg->print;
                $err = 1;
                next;
            }

            if ($ret == 6) {
                $msg = Msg::new("The GID $gid (GID of group $grp) already in use on one or more new nodes for other group. Correct this manually and retry.");
                $msg->print;
                $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
                $err = 1;
                next;
            }

        }

        for my $sys (@{$newnodes_ref}) {
            $groupfile_entry = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$grp:'");
            if (!$groupfile_entry) {
                $ret = $prod->create_oragrp($sys, $gid, $grp);
                if ($ret) {
                    $msg = Msg::new("Failed to create group $grp on $sys->{sys}. Check the logs for more details.");
                    $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
                    $msg->print;
                    $err = 1;
                    last;
                }
            }

            $ret = $prod->modify_group_info($sys, $orauser, $grp, $gid);

            if ($ret) {
                $msg = Msg::new("Failed to add group $grp to Oracle user $orauser on $sys->{sys}. Check the logs for more details.");
                $web->web_script_form("alert",$msg->{msg}) if (Obj::webui());
                $msg->print;
                $err = 1;
                last;
            }
        }
    }

    return $err;
}

sub addnode_create_dir {
    my ($prod, $dir_name, $orauser, $oragroup, $perms, $systems_ref) = @_;
    my $arg_mkdir = "-p $dir_name";
    my $arg_chown = "-R $orauser:$oragroup $dir_name";
    my $arg_chmod = "-R $perms $dir_name";
    my ($sys, $msg);
    my $ret = 0;

    for my $sys (@{$systems_ref}) {
        if (!$sys->is_dir("$dir_name")) {
            $sys->cmd('_cmd_mkdir '.$arg_mkdir);
            $ret = EDR::cmdexit();
            $sys->cmd('_cmd_chown '.$arg_chown);
            $ret = $ret || EDR::cmdexit();
            $sys->cmd('_cmd_chmod '.$arg_chmod);
            $ret = $ret || EDR::cmdexit();

            if ($ret) {
                $msg = Msg::new("Create directory operation on $sys->{sys} failed");
                $msg->log;
                last;
            }
        }
    }
    return $ret;
}


##################################################################################################
#                                                                                                #
#                       Platform independent prepu checks' routines.                             #
#                                                                                                #
##################################################################################################

#sfrac  checking part
#first need define the parameters of sfrac prepu check
#including :time_sync,os_sync
#step:   1, define specifications parameters
#        2, call sfrac checking
#        3, call the sub-function according to these platform which will call the record_result
#        4, get the return after checking

sub prepucheck {
    # the $syslistref ,$upi and $vers will be passed in
    # by PrepU framework, product team can use the 3
    # variables directly

    my ($prod, $ii, $msg, $crshome, $is_sfcfsrac);

    $prod = shift;
    $is_sfcfsrac = 0; # Default value
    if ($#_ == 3) { # Called from within SFCFSRAC
        $is_sfcfsrac = shift;
    }

    my ($syslistref, $upi, $vers) = @_;
    my ($sys, $res, $overall_res);
    my $web = Obj::web();

    # for prod_plat_sub function to detect the os
    my @nodes =@{$syslistref};

    # [TBD] The following should be removed once message related to
    # "product specific check" is shown properly by PrepU framework code.
    # Current message is this:
    # "Running the product specific checking for Veritas Storage Foundation for Oracle RAC 5.1"
    #

    $prod->{results} = {};

    Msg::title();
    $msg = Msg::new("Performing product specific checks for $prod->{name} $prod->{vers}" );

    my $syslist = '';
    for my $sys (@{$syslistref}) {
        $syslist = "$syslist $sys->{sys}";
    }

    $msg = Msg::new("Running the prepucheck with syslist: $syslist, upi: $upi and version: $vers");
    $msg->log;

    # firstly call define-function to store parameters
    # into hash table. This is done under platform specific code.

    $prod->prepu_sfrac_defines($syslistref);

    # secondly call the function according to version
    # except for some checking which are not related
    # to version change the version into digit
    $vers =~ s/\D+//mg;

    $msg = Msg::new("sfrac selected version is $vers");
    $msg->log;

    # Check if DBAC package is installed or not. If not
    # then skip SFRAC post install specific checks.
    my $flag_present = -1;
    my $bad_flag = 0;
    my $dbac_present = 0;

    for my $sys (@{$syslistref}) {
        $dbac_present = $prod->is_dbac_present($sys);
        if ($dbac_present eq '0') {
            $msg = Msg::new("DBAC package not present on $sys->{sys}. $prod->{abbr} is not installed on $sys->{sys}.");
            $msg->log;
            # If DBAC was present on some other node, there is a mismatch
            if ($flag_present eq '1') {
                $bad_flag = '1';
            } else {
                $flag_present = '0';
            }
        } else {
            $msg = Msg::new("DBAC package present on $sys->{sys}. $prod->{abbr} is installed on $sys->{sys}.");
            $msg->log;

            # If DBAC was not present on some other node, there is a mismatch
            if ($flag_present eq '0') {
                $bad_flag = '1';
            } else {
                $flag_present = '1';
            }
        }
    }

    if ($bad_flag eq '1') {
        $msg = Msg::new("$prod->{abbr} is installed on some systems while it is not installed on other systems");
        $msg->log;
        $msg = Msg::new("$prod->{abbr} specific checks will be skipped");
        $msg->log;
        $dbac_present = 0;
    }

    $msg = Msg::new("Final value of dbac_present: $dbac_present");
    $msg->log;

    #Get oracle information
    my $do_oracle_checks = get_oracle_information($prod, $nodes[0], $syslistref);
    if($do_oracle_checks eq "back"){
	 return "back";
    }
    Msg::title();
    ###################################################
    #        Main PrepU Checks          #
    ###################################################

    # Adding a pointer to ICG for resolution of any failures in checks below
    for my $sys (@{$syslistref}) {
        $prod->{prepu_desc} = "Note: For resolution of any failure in checks performed below, consult 'Installation and Configuration Guide' of $prod->{abbr}-$vers for the $sys->{plat} platform.";
        last;
    }

    my (@skipped_checks, $check_count);

    # Calcute the check steps
    $check_count = -1;

#    my $web = Obj::web();
    my $edr = Obj::edr();
    # [TBD] The framework doesn't allow any statement after the title.
    # When this is fixed, we should show the following message on screen.

    $msg = Msg::new("If any of the following checks fail, see the $prod->{name} Administrator's guide to determine the reason for the failure and take corrective action. Rerun the checks after fixing the issues.");
    #$msg->bold;
    #$msg->n;

#    $web->{start} = time();
#    $web->{stage} = Msg::new("Installation and Configuration Checks");
#    $web->{msglist} = "";
#    $web->{completed} = 0;

    # Bypass llt checks if LLT is configured over UDP
    my $devudp = '';
    if (Sys::exists($nodes[0], '/etc/llttab')) {
        $devudp = $nodes[0]->cmd("_cmd_cat /etc/llttab | _cmd_grep 'udp' | _cmd_awk '{print \$3}' | _cmd_uniq ");
    }

    my $n = @{$syslistref};
#        $web->{steps} = 0;
#    $web->{steps} ++;               # check_time_sync_sys
#    $web->{steps} ++;               # check_archtype_sys
#    $web->{steps} ++;               # check_oslevel_sys
#    $web->{steps} ++;               # check_cpuspeed_sys
#    $web->{steps} += $n;            # check_kernelparams_sys
#
#    if (!$devudp) {
#        $web->{steps} += $n;        # check_lltprechecks_sys
#        $web->{steps} ++;           # check_mtu
#    }
#
#    if ($dbac_present || $is_sfcfsrac) {
#                $web->{steps} += $n;         # check_fencing_sys
#        $web->{steps} += $n;            # check_odm_sys
#        $web->{steps} += $n;           # check_gabports_sys
#        $web->{steps} ++;              # check CPS based fencing
#        $web->{steps} += $n;          # check fencing keys
#    }
#
#    if ($dbac_present) {
#        $web->{steps} += $n;            # check_vcsmm_sys
#        if ($nodes[0]->{plat} ne 'Linux'){
#            $web->{steps} += $n;            # check_lmx_sys
#        }
#                $web->{steps} += $n*2;          # No of llt links
#        $web->{steps} ++;        # cluster-ID match
#        $web->{steps} ++;        # /etc/llthosts file match
#        if (!$devudp) {
#            $web->{steps} += ($n*2);  # check_lltprivnetwork_sys
#        }
#    }
    my $steps = 0;
    $steps ++;               # check_time_sync_sys
    $steps ++;               # check_archtype_sys
    $steps ++;               # check_oslevel_sys
    $steps ++;               # check_cpuspeed_sys

    if (!$devudp) {
        $steps += $n;        # check_lltprechecks_sys
        $steps ++;           # check_mtu
    }

    if ($dbac_present || $is_sfcfsrac) {
                $steps += $n;         # check_fencing_sys
        $steps += $n;            # check_odm_sys
        $steps += $n;           # check_gabports_sys
        $steps ++;              # check CPS based fencing
        $steps += $n;          # check fencing keys
    }

    if ($dbac_present) {
        $steps += $n;            # check_vcsmm_sys
        if (!$nodes[0]->linux()){
            $steps += $n;            # check_lmx_sys
        }
                $steps += $n*2;          # No of llt links
        $steps ++;        # cluster-ID match
        $steps ++;        # /etc/llthosts file match
        if (!$devudp) {
            $steps += ($n*2);  # check_lltprivnetwork_sys
        }
    }
    if ($dbac_present || $is_sfcfsrac) {
        $steps += $n;          # check user nobody 
    }

    if($do_oracle_checks == 0){
        $steps ++;         # check_oradblevel_sys
        $steps += $n;      # check_oracle_perm
        $steps ++;         # check_nodes_clus
        $steps += $n;      # check_kernelparams_sys
        if ($is_sfcfsrac){
            $steps += ($n*7);    # check_sfracoracleintegration_sys
        }

        if ($dbac_present){
            if (!($prod->{crs_release} =~ /11.2/m)){
                $steps += $n;    # Node ID mismatch check for Oracle
                $steps += $n;    # Check for vendor clusterware
            }
            $steps += ($n*4);    # check_sfracoracleintegration_sys : No diagwait check
        }

        if ($is_sfcfsrac) {
            $steps += ($n*2); # check_sfracoracleintegration_sys
            $msg = Msg::new("Steps  = $steps");
            $msg->log;
        }
    }

    $edr->set_progress_steps($steps);

    if (Obj::webui) {
        $msg = Msg::new("Starting SF Oracle RAC installation and configuration checks. Failed checks will be displayed in red. Refer to the logs and the $prod->{name} Administrator's guide to determine the reason for the failure and take corrective action. Rerun the checks after fixing the issues");
        $web->web_script_form("alert", $msg->{msg});
        $prod->{sfrac_install_config_check} = 4;
        $web->web_script_form("sfrac_install_config_checks", 0);
        $prod->{sfrac_install_config_check} = 0;
    }

    # Pre checks..
    # Time Synchronization, Sys Architecture, OS level,
    # CPU speed and Kernel parameters checks.

    $res = $prod->pre_sfrac_checks($nodes[0], 0);    # 0 indicates, it is calling from VIAS code.
    if ($res)
    {
        $msg = Msg::new("Problem encountered with pre-installation checks");
        $msg->log;
        $overall_res = 1;
    }


    if (!$devudp) {
        # Read the /etc/llttab file and plumb the devices if not already done so.
        $res = $prod->plat_plumbdev_sys($nodes[0], $syslistref);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with plumbing LLT interfaces. Some checks need interfaces to be plumbed.)");
            $msg->log;
        }


        # LLT prechecks (Full Dulplex check and Jumbo Frame Setting  and cross connection check)
        $res = $prod->check_lltprechecks_sys($nodes[0], $syslistref);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with LLT prechecks (Full Duplex, Jumbo Frame and Cross Connection)");
            $msg->log;
            $overall_res = 1;
        }

    } else {
        $msg = Msg::new("When LLT is configured over UDP, the following LLT checks are skipped");
        $msg->log;
        $msg = Msg::new("=================================");
        $msg->log;
        $msg = Msg::new("LLT Links' Full Duplex setting");
        $msg->log;
        $msg = Msg::new("LLT Link Jumbo Frame setting (MTU)");
        $msg->log;
        $msg = Msg::new("LLT Links' cross connection");
        $msg->log;
        $msg = Msg::new("LLT Links' speed and auto negotiation settings");
        $msg->log;
        $msg = Msg::new("=================================");
        $msg->log;

    }

    # [TBD] LLT private NICs checks
    # Perform only if SFRAC is installed.
    if ($dbac_present) {
        $res = $prod->check_lltprivnetwork_sys($nodes[0], $syslistref, $devudp);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with LLT and private network checks");
            $msg->log;
            $overall_res = 1;
        }
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'LLT private link check';
    }

    if (!$dbac_present) {
        $msg = Msg::new("DBAC package is not installed on all the cluster nodes. The following checks have been skipped:");
        $msg->log;
        for ($ii=0; $ii<=$#skipped_checks; $ii++) {
            Msg::log(($ii + 1).' '.$skipped_checks[$ii]);
        }
    }

    # Fencing check for SFRAC
    # 1. Check if fencing is configured in enabled node on all the nodes
    # 2. If so, check if all the nodes have their keys registered on all
    # the coordinator disks
    #
    # For SFCFSRAC
    # 1. Success if fencing is configured but in disabled mode
    if ($dbac_present || $is_sfcfsrac) {
        $res = $prod->check_fencing_sys($nodes[0], $syslistref, $is_sfcfsrac);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with fencing check");
            $msg->log;
            $overall_res = 1;
        }
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'Fencing check';
    }

    # ODM check
    #
    # Perform if SFRAC is installed or perform for SFCFSRAC.
    if ($dbac_present || $is_sfcfsrac) {
        $res = $prod->check_odm_sys($nodes[0], $syslistref);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with ODM check");
            $msg->log;
            $overall_res = 1;
        }
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'ODM check';
    }

    # VCSMM check
    #
    # Perform only if SFRAC is installed.
    goto SKIPPED_VCSMM if ($is_sfcfsrac);
    if ($dbac_present) {
        $res = $prod->check_vcsmm_sys($nodes[0], $syslistref);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with VCSMM check");
            $msg->log;
            $overall_res = 1;
        }
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'VCSMM check';
    }

SKIPPED_VCSMM:

    # GAB ports check
    # Check if all 8 GAB ports are up for SFRAC, or 7 for SFCFSRAC
    #
    # Perform only if SFRAC is installed or called from SFCFSRAC
    # In the later case skip the check for Port 'o' (VCSMM)
    if ($dbac_present || $is_sfcfsrac) {
        $res = $prod->check_gabports_sys($nodes[0], $syslistref, $is_sfcfsrac);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with GAB port check");
            $msg->log;
            $overall_res = 1;
        }
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'GAB ports check';
    }

    # LMX check.
    # Only helper thread specific check is done, since
    # there is no cross platform way to check if LMX is
    # running or not
    #
    # Perform only if SFRAC is installed.
    goto SKIPPED_LMX if ($is_sfcfsrac || $nodes[0]->linux());
    if ($dbac_present) {
        $res = $prod->check_lmx_sys($nodes[0], $syslistref);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with LMX check");
            $msg->log;
            $overall_res = 1;
        }
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'LMX check';
    }


SKIPPED_LMX:

    # [TBD - Partial] SFRAC/Oracle integration checks
    #
    # Perform only if SFRAC is installed.
    if ($dbac_present || $is_sfcfsrac) {
        # Check whether user nobody exists on the system.
        $res = $prod->check_user_nobody($nodes[0], $syslistref);
        if ($res) {
            $msg = Msg::new("Problem encountered in verifying user nobody");
            $msg->log;
            $overall_res = 1;
        }
        if($do_oracle_checks == 0){
            $res = $prod->check_sfracoracleintegration_sys($nodes[0], $syslistref, $is_sfcfsrac, $dbac_present);
        }else {
            $res = $do_oracle_checks;
        }

        if ($res eq '1')
        {
            $msg = Msg::new("Problem encountered with $prod->{abbr} Oracle integration checks");
            $msg->log;
            $overall_res = 1;
        } elsif ($res eq '2') {
            $msg = Msg::new("Oracle not installed at all, or not intalled properly. Oracle integration checks SKIPPED.");
            $msg->log;
            goto SKIPPED_ORAINT;
        }
        goto SKIPPED_ORAINT if ($is_sfcfsrac);

        # Check whether llttab and llthosts are readable by Oracle user.
        $res = $prod->check_oracle_perm($nodes[0], $syslistref);
        if ($res) {
            $msg = Msg::new("Problem encountered with Oracle user permissions check");
            $msg->log;
            $overall_res = 1;
        }

        # Check whether SFRAC and RAC have same nodes.
        $res = $prod->check_nodes_clus($nodes[0], $syslistref);
        if ($res) {
            $msg = Msg::new("Problem encountered with equivalence check of nodes in $prod->{abbr} and RAC");
            $msg->log;
            $overall_res = 1;
        }
        
    } else {
        $check_count += 1;
        $skipped_checks[$check_count] = 'Oracle integration check';

        $check_count += 1;
        $skipped_checks[$check_count] = 'Oracle user permissions check';
    }



    # Oracle DB level check
    # Note that the ORA_CRS_HOME here would be same for all the nodes, a basic necessity of SFRAC installation
    $res = $prod->check_oradblevel_sys($nodes[0], $syslistref);
    if ($res)
    {
        $msg = Msg::new("Problem encountered with Oracle DB level check");
        $msg->log;
        $overall_res = 1;
    }

SKIPPED_ORAINT:

#    $web = Obj::web();
#    $web->{steps} = $web->{completed};
#    $web->write_status();
    if(!Obj::webui()){
        $edr->{steps} = 0;
        $msg->set_progress();
    }
    # Msg::progress($web, Msg::new(""));

    if ($overall_res)
    {
        $msg = Msg::new("Finished the prepucheck, and at least one of the checks encountered some problems");
        $msg->log;
        # returning 1 informs the prepucheck_sys is failed
        # return 0;
        return $prod->{results};
    }

    $msg = Msg::new("Finished the prepucheck and no checks encountered problems");
    $msg->log;
    # returning 0 informs the prepucheck_sys is completed
    return $prod->{results};
}



sub find_users {
    my ($self, $sys, $name) = @_;
    my @result = ();

    # Local user
    my $rc = $sys->cmd("_cmd_cut -d: -f 1,6,7 /etc/passwd | _cmd_grep -v nologin | _cmd_grep -i $name 2>/dev/null");
    for my $item (split(/\n/, $rc)) {
        chomp($item);
        push(@result, $item);
    }

    # NIS+ user
    $rc = $sys->cmd("ypcat -k passwd 2>/dev/null | _cmd_cut -d: -f 1,6,7 | _cmd_grep -i $name");
    for (split(/\n/, $rc)) {
        chomp;
        push(@result, $2) if (/(.*)\s+(.*)/);
    }
    return \@result;
}


sub get_oracle_info {
    my ($self, $sys) = @_;

    my @users = @{$self->find_users($sys, 'ora')};
    my @db_dirs = ();
    my @result;

    for my $item (@users) {
        chomp $item;
        my ($ora_user, $userdir, $shell) = split(/:/m, $item);
        next if (!$userdir || $userdir eq '/');

        my $ora_home = '';
        my $crs_home = '';
        my $ora_ver = '';
        my $ora_prodname = 'Oracle';

        if ($sys->exists("/etc/profile")) {
            $rc = $sys->cmd("cat /etc/profile | grep ORACLE_HOME | awk '{print \$2}' ");
        }

        if (($rc eq '') && ($sys->exists("$userdir/.profile"))) {
            $rc = $sys->cmd("cat $userdir/.profile | grep ORACLE_HOME | awk '{print \$2}' ");
        }

        if (($rc eq '') && ($sys->exists("$userdir/.bash_profile"))) {
                $rc = $sys->cmd("cat $userdir/.bash_profile | grep ORACLE_HOME | awk '{print \$2}'");
        }

        for (split(/\n/, $rc)) {
            $ora_home = $1 if (/ORACLE_HOME=(.*)/);
        }
        if (!$ora_home) {
            my $msg = Msg::new("Cannot find the Oracle HOME dir");
            $msg->log;
            next;
        }
        if (!$sys->exists($ora_home)) {
            my $msg = Msg::new("Oracle HOME dir '$ora_home' does not exist");
            $msg->log;
            next;
        }

        $rc = '';
        if ($sys->exists("/etc/profile")) {
            $rc = $sys->cmd("cat /etc/profile | grep CRS_HOME | awk '{print \$2}' ");
        }

        if (($rc eq '') && ($sys->exists("$userdir/.profile"))) {
            $rc = $sys->cmd("cat $userdir/.profile | grep CRS_HOME | awk '{print \$2}' ");
        }

        if (($rc eq '') && ($sys->exists("$userdir/.bash_profile"))) {
            $rc = $sys->cmd("cat $userdir/.bash_profile | grep CRS_HOME | awk '{print \$2}'");
        }

        for (split(/\n/, $rc)) {
            $crs_home = $1 if (/CRS_HOME=(.*)/);
        }

        my $ora_bits = 32;
        $ora_bits = 64 if ($sys->cmd("file $ora_home/bin/oracle 2>/dev/null") =~ /64/m);

        # Use command "opatch to get the oracle version, and installed patches
        my $opatch_cmd = "$ora_home/OPatch/opatch";

        if ($sys->exists($opatch_cmd)) {
            my $inv_dir = $sys->cmd("_cmd_find $ora_home -name oraInst.loc -follow 2>/dev/null");
            $inv_dir = " -invPtrLoc $inv_dir" if ($inv_dir);

             my $oprc = $sys->cmd("_cmd_su $ora_user -c \'ORACLE_HOME=$ora_home CRS_HOME=$crs_home $opatch_cmd lsinventory $inv_dir -all\' </dev/null 2>/dev/null");
            my @lines = split(/\n/, $oprc);

            # Get installed products
            my $begin = 0;
            my @prods;
            for (@lines) {
                next if (/^\s*$/);
                $begin = 1 if (/Installed Top-level Products/);
                last if (/There are \d+ products installed/);
                if ($begin) {
                    if (/\s{2,}/) {
                        $ora_ver = $';
                        $ora_prodname = $`;
                        push(@prods, { 'ora_prodname' => $`,
                                     'ora_ver'      => $' });

                    }
                }
            }
            for my $item (@prods) {
                if ($item->{ora_prodname} =~ /Oracle Database/m) {
                    if ($item->{ora_prodname} !~ /Patch Set/m) {
                        $ora_prodname = $item->{ora_prodname};
                        $ora_ver      = $item->{ora_ver};
                   }
                }
            }

            for my $item (@prods) {
               if ($item->{ora_prodname} =~ /Oracle Database/m) {
                    if ($item->{ora_prodname} =~ /Patch Set/m) {
                        if (EDRu::compvers($ora_ver, $item->{ora_ver}, 3) == 0 &&
                                EDRu::compvers($ora_ver, $item->{ora_ver}) == 2) {
                           $ora_ver = $item->{ora_ver};
                        }
                    }
               }
            }
}

        if (!$ora_ver) {
            # Cannot get oracle version by opatch
            # Sqlplus can be used to detect oracle version
            #   1. Connect to oracle database
            #   2. SQL> select * from v$version where banner like 'Oracle%'
            #   ...
            # But we cannot login, so we use sqlplus' version as oracle version
            my $ovrc = $sys->cmd("_cmd_su $ora_user -c \'ORACLE_HOME=$ora_home CRS_HOME=$crs_home $ora_home/bin/sqlplus -v\' </dev/null 2>/dev/null");
            for (split /\n/, $ovrc) {
                if (/SQL\*Plus.*\s+([\d\.*]+)\s+/i) {
                    $ora_ver = $1;
                    last;
                }
            }
            # Oracle8i do not support "sqlplus -v", use "sqlplus -?" instead
            if (!$ora_ver) {
                $ovrc = $sys->cmd("_cmd_su $ora_user -c \'ORACLE_HOME=$ora_home CRS_HOME=$crs_home $ora_home/bin/sqlplus -?\' </dev/null 2>/dev/null");
                for (split /\n/, $ovrc) {
                    if (/SQL\*Plus: Release ([\d\.*]+)\s+/i) {
                        $ora_ver = $1;
                        last;
                    }
                }
            }
        }

        if ($ora_ver) {
            my %software = ();
            $software{PRODUCT} = 'Oracle';
            $software{PRODNAME} = $ora_prodname;
            $software{VERSION} = $ora_ver;
            $software{ORACLE_HOME} = $ora_home;
            $software{CRS_HOME} = $crs_home;
            $software{ORACLE_USER_HOME} = $userdir;
            $software{HOMEDIR} = $ora_home;
            $software{USERNAME} = $ora_user;
            $software{PATCH} = '';          #TODO: will be added later
            $software{BITS} = $ora_bits;

            if (!EDRu::inarr($software{HOMEDIR}, @db_dirs)) {
                push(@result, \%software);
                push(@db_dirs, $software{HOMEDIR});
            }
        }
    }
    return \@result;
}



sub pre_sfrac_checks {

    my ($prod, $sys, $syslistref, $msg, $res, $overall_res, $precheck);

    $prod = shift;
    $sys = shift;
    $precheck = shift;    # Calling from installer or VIAS.
    $syslistref = CPIC::get('systems');

    if (!exists($sys->{discover}{SOFTWARE})) {
        $sys->{discover}{SOFTWARE} = $prod->get_oracle_info($sys);
    }

    if (! $precheck){

        # The diff between times of two nodes can't be more than 5 seconds.
        $prod->{time_sync} = 5 if (! $prod->{time_sync});       # Initialize if not already done.

        # Time synchronization checks
        $res = $prod->check_time_sync_sys($sys, $syslistref, $prod->{time_sync}, $precheck);
        if ($res)
        {
            $msg = Msg::new("Problem encountered with time synchronization check");
            $msg->log;
            $overall_res = 1;
        }

    }

    # System architecture checks
    $res = $prod->check_archtype_sys($sys, $syslistref, $precheck);
    if ($res)
    {
        $msg = Msg::new("Problem encountered with system architecture check");
        $msg->log;
        $overall_res = 1;

    }

    # OS level checks
    $res = $prod->check_oslevel_sys($sys, $syslistref, $precheck);
    if ($res)
    {
        $msg = Msg::new("Problem encountered with oslevel checking");
        $msg->log;
        $overall_res = 1;
    }

    # CPU speed checks
    $res = $prod->check_cpuspeed_sys($sys, $syslistref, $precheck);
    if ($res)
    {
        $msg = Msg::new("Problem encountered with CPU speed check");
        $msg->log;
        $overall_res = 1;
    }

    if ($precheck) {
        if ($overall_res) {
            #$msg = Msg::new("See the $prod->{name} Administrator's guide to determine the reason for the failure and take corrective action. Rerun the checks after fixing the issues.");
            my @tmp = @{$syslistref};
            my $sys = $tmp[-1];        # Gets the last element. The following message prints at the end of all the warnings.
            $msg = Msg::new("See the $prod->{name} Administrator's guide to take corrective action. Rerun the checks after fixing the issues.");
            $sys->push_warning( $msg);
        }
    }

    return $overall_res;
}


sub prepu_sfrac_defines {
    my ($prod, $syslistref, $sys, $plat, $msg, $padv);

    $prod = shift;
    $syslistref = shift;

    my @nodes = @{$syslistref};
    # The diff between times of two nodes can't be more than 5 seconds.
    $prod->{time_sync} = 5;


    $prod->{ipc_utility} = '/opt/VRTSvcs/ops/bin/ipc_version_chk_shared';
    $prod->{libvcsmm32} = '/usr/lib/libvcsmm.so';
    $prod->{libvcsmm64} = '/usr/lib64/libvcsmm.so';
    $prod->{libodm32} = '/usr/lib/libodm.so';
    $prod->{libodm64} = '/usr/lib64/libodm.so';
    $prod->{lib_path} = '/opt/VRTSvcs/rac/lib/';
    $prod->{libskgxp} = '/opt/VRTSvcs/ops/lib/';
    $prod->{vxfentab} = '/etc/vxfentab';


    $padv = $prod->padv();
    #$padv->{cmd}{lltstat} = "/sbin/lltstat";

    $sys = $nodes[0];        # Taking one of the systems as sys.

    if( $sys->{arch} =~ /64/m ) {
        $prod->{bits} = 64;
    } else {
        $prod->{bits} = 32;
    }

    $msg = Msg::new("\$prod->{bits}: $prod->{bits}");
    $msg->log;

    # [TBD] This is not a permanent solution.
        # The following has been done only to satisfy
        # the requirement of a case where:
        # Platform of the system where VIAS has been invoked
        # is different from the platform of the target cluster
        # nodes.
        #
        # Get the "cut" command path.

        $padv->{cmd}{basename} = $sys->cmd('_cmd_which basename');
        $padv->{cmd}{cut} = $sys->cmd('_cmd_which cut');

        $msg = Msg::new("Path for BASENAME command: $padv->{cmd}{basename}");
        $msg->log;
        $msg = Msg::new("Path for CUT command: $padv->{cmd}{cut}");
        $msg->log;


    # parameters  needed the version
    for my $sys (@{$syslistref}) {
        $msg = Msg::new("Plat: $sys->{plat}");
        $msg->log;
        #$prod->tsub("plat_prepu_sfrac_defines", $sys);
        my $product = $prod->prod('SFRAC60');
        $product->plat_prepu_sfrac_defines($sys);
    }
    return '';
}

sub check_time_sync_sys {

    my $prod = shift;
    my $sys_t = shift; # target host of the checking
    my $syslistref = shift;
    my $time_sync  = shift;
    my $precheck = shift;
    my $errstr = '';
    my $msg_check;

    my ($item,$desc,$status,$summary,$ret);
    my (%nodes_timer,$timer_sin,%timer_sec);
    my ($sec,$min,$hour,$mday,$mon,$year);
    my ($msg, $sys, $sys1, $sys2, $ii, $flag, @diff, $timer_diff);

    $msg = Msg::new("Time synchronization check for $prod->{abbr}");
    $msg->log;

    $item = 'Time synchronization check';
    $desc = 'synchronizing time settings on cluster nodes';

    $msg_check = Msg::new("Checking time synchronization");
    my $stage = Msg::new("Installation and Configuration Checks");
    $stage->display_left($msg_check) if (! $precheck);


    #get time of each node
    for my $sys (@{$syslistref}) {
        eval {$timer_sin = $sys->cmd('date -u +%S:%M:%H:%d:%m:%Y');};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Can't get date and error info: $errstr");
            $msg->log;
            $msg = Msg::new("Failed");
            $stage->display_right($msg) if (! $precheck);
            $msg_check->addError($msg_check->{msg});
            if ($precheck) {
                $msg = Msg::new("Couldn't complete the Time synchronization check. Failed to get system 'date' information.");
                $sys->push_warning( $msg);
            }
            return 1;
        }

        $nodes_timer{$sys} = $timer_sin;
    }

    # Normalize the timers on all the nodes.
    for my $sys (@{$syslistref}) {
        ($sec,$min,$hour,$mday,$mon,$year) = split(/:/m,$nodes_timer{$sys});

        # timegm() expects 'month' value in the range 0..11
        eval {$timer_sec{$sys} = timegm ($sec, $min, $hour, $mday, $mon - 1, $year);};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Can't change \$timer_ref:$timer_sin and error info: $errstr");
            $msg->log;
            $msg = Msg::new("Failed");
            $stage->display_right($msg) if (! $precheck);
            $msg_check->addError($msg_check->{msg});
            if ($precheck) {
                $msg = Msg::new("Couldn't complete the Time synchronization check. Failed to perform range checking on the system 'date'.");
                $sys->push_warning( $msg);
            }
            return 1;
        }
    }

    $flag = 0;
    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1->{sys} eq $sys2->{sys}) {
                next;
            }

            if ($timer_sec{$sys1} > $timer_sec{$sys2}) {
                $timer_diff = $timer_sec{$sys1} - $timer_sec{$sys2};
            } else {
                $timer_diff = $timer_sec{$sys2} - $timer_sec{$sys1};
            }
            # If timer differences are more than expected, then report it.
            if ($timer_diff > $time_sync) {
                $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                $ii = $ii + 1;
                $flag = 1;
            }
        }
    }

    if ($flag) {
        # [TBD] We need to include this reporting into summary.
        #$summary = "Checking of synchronizing time was failed. Make sure to synchronize the time settings on each node. Time setting is not synchronized on the following node combinations:";
        #for ($ii=0; $ii<=$#diff; $ii++) {
        #    $summary = $summary."\n$diff[$ii]"
        #}
        $msg = Msg::new("Failed");
        $stage->display_right($msg) if (! $precheck);
        $msg_check->addError($msg_check->{msg});
        if ($precheck) {
            $msg = Msg::new("Nodes have difference in clock by more than 5 sec");
            $sys_t->push_warning($msg);
        }
        $status = 0;
        $summary = 'Date and time are not synchronized across the cluster. Date and time settings should be identical on all cluster nodes.';
    } else {
        $msg = Msg::new("Passed");
        $stage->display_right($msg) if (! $precheck);
        $status = 1; # 1: informing checking is ok
        $summary = "Synchronized time setting on cluster nodes checking of $prod->{abbr} is OK.";
    }

    $ret = $prod->prepu_record_result($sys_t->{sys}, $item, $desc, $status, $summary, \%nodes_timer);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    #return 0 for complete
    return (! $status);
}


sub check_archtype_sys {
    my ($prod, $sys, $syslistref, $msg);
    my ($sys1, $sys2, $item, $desc, $status, $summary, $arrayref);
    my (%arch_type, $para, @diff, $flag, $ii, $mismatch_list, $precheck);
    my $msg_check;

    $prod = shift;
    $sys = shift; # target host of the checking
    $syslistref = shift;
    $precheck = shift;
    $status = 1;

    $msg = Msg::new("Check architecture type of systems");
    $msg->log;
    $msg_check = Msg::new("Checking system architecture information");
    my $stage = Msg::new("Installation and Configuration Checks");
    $stage->display_left($msg_check) if (! $precheck);
    for my $sysi (@{$syslistref}) {
        #get the architecture type of cluster nodes
        $arch_type{$sysi} = $prod->get_archtype_sys($sysi);
    }

    $ii = 0;
    $item = 'System architecture type check';
    $desc = 'System architecture type check';
    $summary = 'System architecture type is identical.';
    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1->{sys} eq $sys2->{sys}) {
                next;
            }

            if ($arch_type{$sys1} ne $arch_type{$sys2}) {
                $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                $ii = $ii + 1;
                $flag = 1;
            }
        }
    }

    if ($flag) {
        $summary = 'The check for system architecture type is failed. Within a cluster, all nodes must use identical system acrhiteture.';
        for ($ii=0; $ii<=$#diff; $ii++) {
             $mismatch_list = $mismatch_list.' '.$diff[$ii];
        }
        $msg = Msg::new("Combinations with mismatched system architecture types: $mismatch_list");
        $msg->log;

        $msg = Msg::new("Failed");
        $stage->display_right($msg) if (! $precheck);
        $msg_check->addError($msg_check->{msg});
        if ($precheck) {
            $msg = Msg::new("Mismatch in system's architecture");
            $sys->push_warning( $msg);
        }
        $status = 0;
    } else {
        $msg = Msg::new("System architecture type check passed");
        $msg->log;

        $msg = Msg::new("Passed");
        $stage->display_right($msg) if (! $precheck);
    }

    $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    #return 0 for complete
    return (! $status);
}



sub check_oslevel_sys {
    my ($prod, $sys, $syslistref, $msg);
    my ($sys1, $sys2, $item, $desc, $status, $summary, $arrayref);
    my ($os_ref, %os_ref, $para, @diff, $flag, $ii, $mismatch_list, $precheck);
    my $msg_check;

    $prod = shift;
    $sys = shift; # target host of the checking
    $syslistref = shift;
    $precheck = shift;
    $status = 1;

    $msg = Msg::new("For OS level of sfrac");
    $msg->log;
    $msg_check = Msg::new("Checking OS and patch level synchronization");
    my $stage = Msg::new("Installation and Configuration Checks");
    $stage->display_left($msg_check) if (! $precheck);

    for my $sysi (@{$syslistref}) {
        #get the oslevel of cluster nodes
        $os_ref{$sysi} = $prod->get_oslevel_sys($sysi);
    }

    $ii = 0;
    $item = 'OS version synchronization check';
    $desc = 'OS version synchronization check';
    $summary = 'OS and patch levels are synchronized.';
    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1 eq $sys2) {
                next;
            }

            if ("$os_ref{$sys1}" ne "$os_ref{$sys2}") {
                $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                $ii = $ii + 1;
                $flag = 1;
            }
        }
    }

    if ($flag) {
        $summary = 'The check for OS version and patch level failed. Within a cluster, all nodes must use identical operating system versions and patch levels.';
        # [TBD] Today we are not showing mismatched cases in weblink.
        # We should do it for future.
        #$summary = $summary."\n\tFollowing mismatches found:";
        for ($ii=0; $ii<=$#diff; $ii++) {
        #    $summary = $summary."\n\t\t$diff[$ii]";
            $mismatch_list = $mismatch_list.' '.$diff[$ii];
        }
        $msg = Msg::new("Combinations with mismatched OS and patch level: $mismatch_list");
        $msg->log;

        $msg = Msg::new("Failed");
        $stage->display_right($msg) if (! $precheck);
        $msg_check->addError($msg_check->{msg});
        if ($precheck) {
            $msg = Msg::new("OS Version or Patch level mismatch found");
            $sys->push_error( $msg);
        }
        $status = 0;
    } else {
        $msg = Msg::new("OS and Patch level check passed");
        $msg->log;

        $msg = Msg::new("Passed");
        $stage->display_right($msg) if (! $precheck);
    }

    my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    #return 0 for complete
    return (! $status);
}


sub check_cpuspeed_sys {
    my ($prod, $sys, $syslistref, $msg);
    my ($sys1, $sys2, $item, $desc, $status, $summary, $arrayref);
    my (%cpu_speed, $para, @diff, $flag, $ii, $mismatch_list, $precheck);
    my $msg_check;

    $prod = shift;
    $sys = shift; # target host of the checking
    $syslistref = shift;
    $precheck = shift;
    $status = 1;

    $msg = Msg::new("Checking CPU speed");
    $msg->log;
    $msg_check = Msg::new("Checking for CPU frequency match");
    my $stage = Msg::new("Installation and Configuration Checks");
    $stage->display_left($msg_check) if (! $precheck);
    for my $sysi (@{$syslistref}) {
        #get the processor speed of cluster nodes
        $cpu_speed{$sysi} = $prod->get_cpuspeed_sys($sysi);
    }

    $ii = 0;
    $item = 'Processor speed check';
    $desc = 'Checking whether processors have same same clock frequency';
    $summary = 'Processors have same clock cycle frequency';
    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1->{sys} eq $sys2->{sys}) {
                next;
            }

            if ("$cpu_speed{$sys1}" ne "$cpu_speed{$sys2}") {
                $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                $ii = $ii + 1;
                $flag = 1;
            }
        }
    }

    if ($flag) {
        $summary = 'The check for processor speed failed. Within a cluster, all nodes must have identical processors with same clock cycle frequency.';
        for ($ii=0; $ii<=$#diff; $ii++) {
            $mismatch_list = $mismatch_list.' '.$diff[$ii];
        }
        $msg = Msg::new("Combinations with mismatched frequencies: $mismatch_list");
        $msg->log;

        $msg = Msg::new("Failed");
        $stage->display_right($msg) if (! $precheck);
        $msg_check->addError($msg_check->{msg});
        if ($precheck) {
            $msg = Msg::new("Mismatch in CPU clock frequency");
            $sys->push_warning($msg);
        }
        $status = 0;
    } else {
        $msg = Msg::new("Processor speed check passed");
        $msg->log;

        $msg = Msg::new("Passed");
        $stage->display_right($msg) if (! $precheck);
    }

    my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    #return 0 for complete
    return (! $status);
}


sub check_oradblevel_sys {
    my $prod = shift;
    my $sys = shift; # Target host of the checking
    my $syslistref = shift;

    my $msg;
    my $msg_check;
    my $errstr = '';

    $msg = Msg::new("For Oracle DB level of $prod->{abbr}");
    $msg->log;
    my ($sys1, $sys2, %orahome, $orahome, %oraversions, $flag);
    my ($item, $desc, $status, $summary, $ret);
    $status = 1;

    $msg_check = Msg::new("Checking Oracle DB level");
    my $stage = Msg::new("Installation and Configuration Checks");
    $stage->display_left($msg_check);

    $item = 'Oracle DB level synchronization check';
    $desc = 'Oracle DB level synchronization check';

    # Perform the Oracle DB level check below
    # su <oracle_user>
    # Assuming that <oracle_user> == 'oracle' always

    # Getting some Oracle installation specific info from PrepU framework
    my ($oracle_arr);

    for my $oracle_arr (@{$sys->{discover}{SOFTWARE}}) {
        if ($oracle_arr->{PRODUCT} ne 'Oracle') {
            next;
        }
        $prod->{orauser} = $oracle_arr->{USERNAME};         # Will be used in prepucheck() later after call to this function.
    }

    # Conn 1: checking if 'su' works AND <oracle-user> user is there
    # Using the scalar $prod->{orauser} as the <oracle-user>
    if ($prod->{orauser} eq '') {
        $msg = Msg::new("Oracle user could not be found in PrepU framework on $sys->{sys}");
        $msg->log;
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});
        return 1;
    }

    # Conn 2: saving ORACLE_HOMEs locally
    # For every node, check if ORACLE_HOME is set, else ask after suggesting
    for my $sys2 (@{$syslistref}) {
        if ($prod->{db_home} eq '') {
            my $oratab = $prod->{oratab};
            my $oratabcat;
            my @oratablines;
            my @oratabitems;
            if ($sys2->exists($oratab)) {
                # Assuming $oratab has only one uncommented line having ORACLE_HOME info
                $oratabcat = $sys2->cmd("_cmd_cat $oratab 2>/dev/null");
                @oratablines = split(/\n/, $oratabcat);
                for my $line (@oratablines) {
                    chomp($line);
                    # Remove leading/trailing whitespaces
                    $line =~ s/(^(\s)+)//mg;
                    $line =~ s/((\s)+$)//mg;
                    if ($line eq '') {
                        next;
                    }
                    if ($line !~ /^#/m) {
                        @oratabitems = split(/:/m, $line);
                        $orahome{$sys2} = $oratabitems[1];
                    }
                }

                # If cannot find ORACLE_HOME info in "/etc/oratab"
                if ($orahome{$sys2} eq '') {
                    $msg = Msg::new("ORACLE_HOME not set on $sys2->{sys}. Set it appropriately.");
                    $msg->log;
                    $msg = Msg::new("Failed");
                    $stage->display_right($msg);
                    $msg_check->addError($msg_check->{msg});
                    return 1;
                }
            } else {
                $msg = Msg::new("ORACLE_HOME not set on $sys2->{sys}. Set it appropriately.");
                $msg->log;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                return 1;
            }
        } else {
            $orahome{$sys2} = $prod->{db_home};
        }
    }

    # Find the Oracle DB level now
    for my $sys2 (@{$syslistref}) {
        eval {$oraversions{$sys2} = $sys2->cmd("_cmd_su $prod->{orauser} -c '_cmd_sh $orahome{$sys2}/OPatch/opatch lsinventory -oh $orahome{$sys2} 2>/dev/null' | _cmd_grep 'Oracle Database'");};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem running 'opatch' utility on $sys2->{sys}. Error info: $errstr");
            $msg->log;
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            return 1;
        }
        chomp($oraversions{$sys2});
        my @oraversions = split(/\s+/m, $oraversions{$sys2});
        $oraversions{$sys2} = $oraversions[2]; # Oracle Database 11g
    }

    # Check now whether all Oracle versions are same or not
    $flag = 0; # Oracle DB level same
    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($oraversions{$sys1} ne $oraversions{$sys2}) {
                $msg = Msg::new("Oracle DB level different on: $sys1->{sys} ($oraversions{$sys1}) and $sys2->{sys} ($oraversions{$sys2}).");
                $msg->log;
                $flag = 1; # Oracle DB level different
            }
        }
    }

    if ($flag) {
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});
        $summary = 'The check for Oracle DB level failed. Within a cluster, all nodes must use identical Oracle DB versions.';
        $status = 0;
    } else {
        $summary = 'Oracle DB levels are synchronized.';
        $msg = Msg::new("Oracle DB level check passed");
        $msg->log;
        $msg = Msg::new("Passed");
        $stage->display_right($msg);
    }

    $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%oraversions);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    # return 0 for test completion
    return (! $status);
}

# Check for Kernel/System parameters
# as per SFRAC/Oracle requirements.
sub check_kernelparams_sys {
    my ($prod, $sys, $syslistref, $cmd_ret);
    my ($msg, $ii, $overall_status);
    my $msg_check;
    $prod = shift;
    $sys = shift;
    $syslistref = shift;
    $overall_status = 0;

    # use the CPI::pl_log() for logging
    $msg = Msg::new("For kernel parameters check of sfrac");
    $msg->log;

    my ($item, $desc, $status, $summary, @param_list);
    my ($os_ref,$para,%kernel_status);

    $item = 'Kernel parameters check';
    $desc = 'Checks of kernel parameters as required by Oracle RAC';
    my $stage = Msg::new("Installation and Configuration Checks");
    $status = 1;
    for my $sys (@{$syslistref}) {
        $msg_check = Msg::new("Checking Kernel Parameters on $sys->{sys}");
        $stage->display_left($msg_check);
        #Platform specific checking
        $cmd_ret = $prod->plat_check_kernelparams_sys($sys, \@param_list);
        if ($cmd_ret eq 1) {
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $summary = "Kernel parameters check Failed on $sys->{sys}. ";
            $summary = $summary."\n\tParameters check failure details:";
            $status = 0;
            $kernel_status{$sys} = "Kernel parameters check Failed on $sys->{sys}. ";
            # Populate information about failed parameter checks
            for ($ii=0; $ii<=$#param_list; $ii++) {
                $summary = $summary."\n\t\t".$param_list[$ii];
            }
            $overall_status=1;
        } elsif ($cmd_ret eq 2) {
            $msg = Msg::new("Failed (See the logs)");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $summary = "Kernel parameters check is unknown on $sys->{sys}";
            $status = 0;
            $kernel_status{$sys} = "Could not find values for few kernel parameters on $sys->{sys}.";
            for ($ii=0; $ii<=$#param_list; $ii++) {
                $summary = $summary."\n\t\t".$param_list[$ii];
            }
        } else {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
            $summary = "Kernel parameters check is OK on $sys->{sys}\n";
            $kernel_status{$sys} = "Kernel parameters check is OK on $sys->{sys}";
        }
        my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%kernel_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    return $overall_status;
}

# 1. Need to check in what mode fencing is configured
# on various cluster nodes. Moreover, we need to
# distinguish between error and Fencing not configured.
# 2. If fencing enabled in cps mode, check entry of nodes
# on cp servers, use check 3 if disks also used else skip
# check 3
# 3. Check if all the nodes have their
# keys registered on all the coordinator disks
sub check_fencing_sys {
    my $prod = shift;
    my $sysi = shift; # target host of the checking
    my $syslistref = shift;
    my $is_sfcfsrac = shift;
    my $localsys = $prod->localsys;
    my ($overall_status);
    my %vxfen_enabled;
    my $msg;
    my $errstr = '';
    my $msg_check;

    my $nsystems = $#{@{$syslistref}} + 1; # Number of systems passed to CPI
    $overall_status=0;

    $msg = Msg::log("For enabled IO fencing configuration of $prod->{abbr}");

    my ($item, $desc, $status, $summary);
    my (%fencing_status, $cmd_ret, $ret, $usefence);

    if ($is_sfcfsrac) {
        $item = 'Fencing configuration check: Disabled mode';
    } else {
        $item = 'Fencing configuration check: Enabled mode';
    }
    $desc = 'Checking if Symantec I/O Fencing module configuration is proper on all the nodes';

    my $stage = Msg::new("Installation and Configuration Checks");
    #just get the package information
    for my $sys (@{$syslistref}) {
        $vxfen_enabled{$sys} = 0;
        $status = 1;

        $msg_check = Msg::new("Checking Fencing configuration on $sys->{sys}");
        $stage->display_left($msg_check);
        # Get I/O Fencing module status
        $cmd_ret = $sys->cmd('_cmd_vxfenadm -d 2>/dev/null');

        if ("$cmd_ret" eq '') {
            $msg = Msg::log("Symantec I/O Fencing module is not configured on node: $sys->{sys}");
            $fencing_status{$sys} = "Fencing module is not configured on $sys->{sys}";
            $summary = "Fencing module is not configured on $sys->{sys}";
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $status = 0;
        } else {
            if ($cmd_ret =~ /Disabled/m) {
                if ($is_sfcfsrac) {
                    $fencing_status{$sys} = "Fencing module is configured in disabled mode on $sys->{sys}";
                    $summary = "Fencing module is configured in disabled mode on $sys->{sys}";
                    $msg = Msg::new("Passed");
                    $stage->display_right($msg);
                } else {
                    $fencing_status{$sys} = "Fencing module is configured in disabled mode on $sys->{sys}. It should be configured in enabled mode.";
                    $summary = "Fencing module configured in disabled mode on $sys->{sys}. It should be configured in enabled mode.";
                    $msg = Msg::new("Failed (Configured in disabled mode)");
                    $stage->display_right($msg);
                    $msg_check->addError($msg_check->{msg});
                    $status = 0;
                    $overall_status = 1;
                }
            } else {
                if ($is_sfcfsrac) {
                    $fencing_status{$sys} = "Fencing module is configured in enabled mode on $sys->{sys}. It should be configured in disabled mode.";
                    $summary = "Fencing module configured in enabled mode on $sys->{sys}. It should be configured in disabled mode.";
                    $msg = Msg::new("Failed (Configured in enabled mode)");
                    $stage->display_right($msg);
                    $msg_check->addError($msg_check->{msg});
                    $status = 0;
                    $overall_status = 1;
                } else {
                    $vxfen_enabled{$sys} = 1;
                    $usefence = $sys->cmd("_cmd_cat /etc/VRTSvcs/conf/config/main.cf | _cmd_grep 'UseFence' | _cmd_grep 'SCSI3' ");
                    if ($usefence =~ /SCSI3/m) {
                        my $commented_usefence = $sys->cmd("_cmd_cat /etc/VRTSvcs/conf/config/main.cf | _cmd_grep 'UseFence' | _cmd_grep 'SCSI3' | _cmd_grep '\/\/' ");
                        if ($commented_usefence =~ /SCSI3/m){
                            $fencing_status{$sys} = "The UseFence variable is set to SCSI3 but is commented in /etc/VRTsvcs/conf/config/main.cf file on $sys->{sys}.It should be UseFence = SCSI3.";
                            $summary = "The UseFence variable is set to SCSI3 but is commented in /etc/VRTSvcs/conf/config/main.cf file on $sys->{sys}. It should be UseFence = SCSI3";
                            $msg = Msg::new("Failed (Fencing is enabled but commented in the main.cf file)");
                            $stage->display_right($msg);
                            $msg_check->addError($msg_check->{msg});
                            $status = 0;
                            $overall_status = 1;

                        }else{
                            $fencing_status{$sys} = "Fencing module is configured as $usefence on $sys->{sys}";
                            $summary = "Fencing module is configured as $usefence on $sys->{sys}";
                            $msg = Msg::new("Passed");
                            $stage->display_right($msg);
                        }
                    }else{
                        $fencing_status{$sys} = "Either the UseFence variable is empty or is not set to SCSI3 in /etc/VRTsvcs/conf/config/main.cf file on $sys->{sys}.It should be UseFence = SCSI3.";
                        $summary = "Either the UseFence variable is empty or is not set to SCSI3 in /etc/VRTSvcs/conf/config/main.cf file on $sys->{sys}. It should be UseFence = SCSI3";
                        $msg = Msg::new("Failed (Fencing is enabled but UseFence attribute is not set to SCSI3)");
                        $stage->display_right($msg);
                        $msg_check->addError($msg_check->{msg});
                        $status = 0;
                        $overall_status = 1;
                    }
                }
            }
        }

        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%fencing_status);
        if ($ret) {
            $msg = Msg::log("Problem encountered in recording the result for '$item'");
        }
    }

    # Do the check number 2 here, skip if for SFCFSRAC

    goto SKIP_KEYS_CHECK if ($is_sfcfsrac);

    my $is_cps_fence= $localsys->cmd(" _cmd_vxfenadm -d 2>/dev/null| _cmd_grep 'Fencing Mechanism' | _cmd_grep 'cps' ");
    $msg_check = Msg::new("Checking Coordination Point server configuration");
    $stage->display_left($msg_check);

    #skip this cps check if mechanism is not cps
    if (!$is_cps_fence)
    {
        $msg = Msg::log('Fencing is not configured using Coordination Point servers, Skipping the check');
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        goto SKIP_CPS_CHECK;
    }

    my $fencps = $localsys->cmd("vxfenconfig -l | _cmd_grep '\\[' | awk '{print \$1}'");
    my @fencps = split(/\n/,$fencps);

    my $fqdn = hostfqdn();
    my $export_cmd;
    my $sercurity = $localsys->cmd("vxfenconfig -l | _cmd_grep 'security'");
    if($sercurity ne ''){
        my @security_val = split(/=/m,$sercurity);
        if($security_val[1] == 1) {
	    my $clusuuid = "";
	    my $sys = $$syslistref[0];
	    if ($sys->exists('/etc/vx/.uuids/clusuuid')) {
	        $clusuuid = $sys->cmd("_cmd_cat /etc/vx/.uuids/clusuuid");
		chomp($clusuuid);
		Msg::log("Cluster UUID is: $clusuuid");
		$clusuuid =~ s/^\{//; 
		$clusuuid =~ s/\}$//;
	    }
            $export_cmd = "CPS_USERNAME=CPSADM\@VCS_SERVICES\@$clusuuid; CPS_DOMAINTYPE=vx; export CPS_USERNAME; export CPS_DOMAINTYPE";
        } else {
            $export_cmd = "CPS_USERNAME=cpsclient\@$fqdn; CPS_DOMAINTYPE=vx; export CPS_USERNAME; export CPS_DOMAINTYPE";
        }
    }

    #CP server from local node
    for my $cps (@fencps) {
        $cps =~ s/^\[//m;
        $cps =~ s/\]//m;

        my ($server, $port) = split(':', $cps);
        my $command = "$export_cmd; /opt/VRTScps/bin/cpsadm -s $server -p $port -a ping_cps 2> /dev/null";
        $localsys->cmd($command);

        if (EDR::cmdexit()) {
            $msg = Msg::log("Problem executing the command: $command on $localsys->{sys}");
            $msg = Msg::log("Failed to ping Coordination Point server: $server");
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status = 1;
            #[TBD] In future we need to create 2 lists :
            #First for all the CP servers PASSED, second for FAILED.
            goto SKIP_CPS_CHECK;
        }

        for my $sys (@{$syslistref}) {
            my $command = "$export_cmd; /opt/VRTScps/bin/cpsadm -s $server -p $port -a list_nodes 2>/dev/null | _cmd_grep '$sys->{sys}(' ";
            $localsys->cmd($command);
            if (EDR::cmdexit()) {
                $msg = Msg::log("Problem executing the command: $command on $sys->{sys}");
                $msg = Msg::log("error info: $errstr");
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $overall_status = 1;
                goto SKIP_CPS_CHECK;
            }
        }
    }

    $msg = Msg::new("Passed");
    $stage->display_right($msg);
    $overall_status = 0;

    # Check on each disk for the keys on this system
    my $fencps_disks = $localsys->cmd("_cmd_cat $prod->{vxfentab} | _cmd_grep -v '^#' | _cmd_grep '\/dev'");

    # Do the check number 3 here, skip if only cp servers used for fencing

SKIP_CPS_CHECK:
    $msg = Msg::log("For checking nodes' keys on coordinator disks of $prod->{abbr}");
    $item = "Fencing check: Nodes' keys on coordinator disks";
    $desc = 'Checking if Symantec I/O Fencing module configuration is proper on all the nodes';

OUTER:    for my $sys (@{$syslistref}) {
        # Default init
        $fencing_status{$sys} = "Fencing module is not configured on $sys->{sys}";
        $summary = "Fencing module is not configured on $sys->{sys}";
        $status = 0;

        $msg_check = Msg::new("Checking the presence of fencing keys on coordinator disks on $sys->{sys}");
        $stage->display_left($msg_check);

        # If only CPS skip check for disks
        if (!$fencps_disks && $is_cps_fence) {
             $msg = Msg::new("Skipped");
             $stage->display_right($msg);
             next;
        }
        if ($vxfen_enabled{$sys}) {
            my ($nodeid, $disks, $is_key);
            eval {
                $nodeid = $sys->cmd('_cmd_lltstat -N 2>/dev/null');
            };
            $errstr = $@;
            if ($errstr) {
                $msg = Msg::log("Problem running 'lltstat' on $sys->{sys}. Error info: $errstr");
                $msg = Msg::log("Skipping the check for nodes' keys on coordinator disks on $sys->{sys}");
                $msg = Msg::new("Skipped");
                $stage->display_right($msg);
                $overall_status = 1;
                next;
            } else {
                chomp($nodeid);
                $nodeid += 0;

                my $clusid;
                eval {
                    $clusid = $sys->cmd('_cmd_lltstat -C 2>/dev/null');
                };
                $errstr = $@;
                if ($errstr) {
                    $msg = Msg::log("Problem running 'lltstat' on $sys->{sys}. Error info: $errstr");
                    $msg = Msg::log("Skipping the check for nodes' keys on coordinator disks on $sys->{sys}");
                    $msg = Msg::new("Skipped");
                    $stage->display_right($msg);
                    $overall_status = 1;
                    next;
                }

                chomp($clusid);
                $clusid += 0;

                my $nodekey = sprintf('VF%04X%02X', $clusid, $nodeid);

                if (!$sys->exists("$prod->{vxfentab}")) {
                    $errstr = $@;
                    $msg = Msg::log("Problem reading '$prod->{vxfentab}' file on $sys->{sys}. Error info: $errstr");
                    $msg = Msg::log("Skipping the check for nodes' keys on coordinator disks on $sys->{sys}");
                    $msg = Msg::new("Skipped");
                    $stage->display_right($msg);
                    $overall_status = 1;
                    next;
                }
                my $disks = $sys->cmd("_cmd_cat $prod->{vxfentab} | _cmd_grep -v '^#' | _cmd_grep '\/dev'");
                #chomp($disks);
                my @fendisks = split(/\n/, $disks);
                my $ndisks = $#fendisks + 1;
                $msg = Msg::log("$ndisks disks discovered on $sys->{sys} as follows: $disks");

                # Check on each disk for the keys of this system
                my $nkeys = 0;
                for my $disk (@fendisks) {
                    eval {$is_key = $sys->cmd("_cmd_vxfenadm -s $disk 2>/dev/null | _cmd_grep '$nodekey'");};
                    $errstr = $@;
                    if ($errstr) {
                        $msg = Msg::log("Problem running 'vxfenadm' on $sys->{sys}. Error info: $errstr");
                        $msg = Msg::log("Skipping the check for nodes' keys on coordinator disks on $sys->{sys}");
                        $msg = Msg::new("Skipped");
                        $stage->display_right($msg);
                        $overall_status = 1;
                        next OUTER;
                    } else {
                        $nkeys++ if ($is_key);
                    }
                }
                $msg = Msg::log("Total $nkeys keys found on coordinator disks for $sys->{sys}");
                if ($nkeys == $ndisks) {
                    $fencing_status{$sys} = 'Number of keys on the coordinator disks is equal to number of nodes in the cluster.';
                    $summary = 'Number of keys on the coordinator disks is equal to number of nodes in the cluster.';
                    $status = 1;
                    $msg = Msg::new("Passed");
                    $stage->display_right($msg);
                } elsif ($nkeys < $ndisks) {
                    $fencing_status{$sys} = "Node $sys->{sys} doesn't have its keys registered on all the coordinator disks. Use 'vxfenadm' command to see which one.";
                    $summary = 'Number of keys on the coordinator disks is less than either the number of nodes in the cluster or the number of paths (due to DMP), whichever is applicable.';
                    $msg = Msg::new("Failed");
                    $stage->display_right($msg);
                    $msg_check->addError($msg_check->{msg});
                    $overall_status = 1;
                }
            }
        } else {
            $msg = Msg::log("Skipping the check for nodes' keys on coordinator disks as fencing is not enabled");
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $overall_status = 1;
            next;
        }

        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%fencing_status);
        if ($ret) {
            $msg = Msg::log("Problem encountered in recording the result for '$item'");
        }
    }

SKIP_KEYS_CHECK:

    return $overall_status;
}

sub check_odm_sys {
    my $prod = shift;
    my $sys = shift; # target host of the checking
    my $syslistref = shift;
    my ($overall_status);

    my $msg_check;
    $overall_status=0;

    $msg = Msg::new("For ODM configuration");
    $msg->log;

    my ($item, $desc, $status, $summary);
    my ($odmconf, %odm_status);

    $item = 'ODM configuration check';
    $desc = 'Checking if ODM is configured properly on all the nodes';
    my $stage = Msg::new("Installation and Configuration Checks");
    #just get the package information
    for my $sys (@{$syslistref}) {
        $status = 1;

        # If GAB 'port o' is up, then ODM is running in
        # CLUSTER mode
        $msg_check = Msg::new("Checking ODM configuration on $sys->{sys}");
        $stage->display_left($msg_check);
        $odmconf = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port d'");
        if ($odmconf eq '') {
            # If /dev/odm is mounted, then ODM is running
            # in STANDALONE mode
            $odmconf = $sys->cmd('_cmd_mount 2>/dev/null | _cmd_grep -w /dev/odm');
            if ($odmconf eq '') {
                $odm_status{$sys} = "ODM not configured on $sys->{sys}";
                $summary = "ODM not configured on $sys->{sys}";
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $status = 0;
                $overall_status = 1;
            } else {
                $odm_status{$sys} = "ODM is configured in STANDALONE mode on $sys->{sys}. It should be configured in CLUSTER mode.";
                $summary = "ODM is configured in STANDALONE mode on $sys->{sys}. It should be configured in CLUSTER mode.";
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $status = 0;
                $overall_status = 1;
            }
        } else {
            $odm_status{$sys} = "ODM is configured in CLUSTER mode on $sys->{sys}";
            $summary = "ODM is configured in CLUSTER mode on $sys->{sys}";
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }

        my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%odm_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    return $overall_status;
}

sub check_gabports_sys {
    my $prod = shift;
    my $temp_sys = shift; # target host of the checking
    my $syslistref = shift;
    my $is_sfcfsrac = shift;
    my ($overall_status, $vxdctl_master, $up_port_cnt);
    my $localsys = $prod->localsys;
    my $msg_check;

    $overall_status = 0;

    $msg = Msg::new("For gab ports configured");
    $msg->log;

    my ($item, $desc, $status, $summary);
    my ($gabports, %gabports_status);

    $item = "GAB ports' availability check";
    $desc = 'Checking if all the required gabports are up';
    my $stage = Msg::new("Installation and Configuration Checks");
    eval {$vxdctl_master = $localsys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'master:' | _cmd_awk '{print \$2}'");};
    #just get the package information
    for my $sys (@{$syslistref}) {
        $status = 1;

        # Get the gabport up
        $msg_check = Msg::new("Checking GAB ports configuration on $sys->{sys}");
        $stage->display_left($msg_check);
        $gabports = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port' | _cmd_grep 'gen' | _cmd_grep 'membership' | _cmd_wc -l");


        if ($gabports >= 0) {
            $msg = Msg::new("GAB is configured on node: $sys->{sys} with $gabports ports");
            $msg->log;
            if ($is_sfcfsrac) {
                $up_port_cnt = 8;
            } else {
                $up_port_cnt = 10;
            }
            if ($gabports < $up_port_cnt) {
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $gabports_status{$sys} = "Only $gabports GAB ports configured on $sys->{sys}. Actually $up_port_cnt ports should be configured.";
                $summary = "Only $gabports GAB ports configured on $sys->{sys}. Actually $up_port_cnt ports should be configured.";
                $status = 0;
                $overall_status = 1;
            } else {
                $msg = Msg::new("Passed");
                $stage->display_right($msg);
                $gabports_status{$sys} = "All $gabports GAB ports configured on $sys->{sys}";
                $summary = "All $gabports GAB ports configured on $sys->{sys}";
            }
        } else {
            $msg = Msg::new("GAB is not configured on node: $sys->{sys}");
            $msg->log;
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $gabports_status{$sys} = "GAB is not configured on $sys->{sys}";
            $summary = "GAB is not configured on $sys->{sys}";
            $status = 0;
            $overall_status = 1;
        }

        my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%gabports_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    return $overall_status;
}

sub check_vcsmm_sys {
    my $prod = shift;
    my $temp_sys = shift; # target host of the checking
    my $syslistref = shift;
    my $result;
    my ($overall_status);
    my $msg_check;

    $overall_status = 0;

    $msg = Msg::new("For VCSMM module configuration");
    $msg->log;

    my ($item, $desc, $status, $summary);
    my (%vcsmm_status);

    $item = 'VCSMM configuration check';
    $desc = 'Checking if VCSMM module is configured properly on all the nodes';
    my $stage = Msg::new("Installation and Configuration Checks");
    #just get the package information
    for my $sys (@{$syslistref}) {
        $status = 1;

        $msg_check = Msg::new("Checking VCSMM configuration on $sys->{sys}");
        $stage->display_left($msg_check);
        $result = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o' | _cmd_grep 'membership'");

        if ($result eq '') {
            $msg = Msg::new("VCSMM module is not configured on node: $sys->{sys}");
            $msg->log;
            $vcsmm_status{$sys} = "VCSMM not configured on $sys->{sys}";
            $summary = "VCSMM not configured on $sys->{sys}";
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $status = 0;
            $overall_status = 1;
        } else {
            $vcsmm_status{$sys} = "VCSMM configured on $sys->{sys}";
            $summary = "VCSMM configured on $sys->{sys}";
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }

        my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%vcsmm_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    return $overall_status;
}

# [TBD]
# Chekcing LMX module status. Apart from Linux,
# today there is no way by which we can detect
# the status of LMX module.
# Only checking LMX helper thread status.
sub check_lmx_sys {
    my $prod = shift;
    my $temp_sys = shift; # target host of the checking
    my $syslistref = shift;
    my ($overall_status);

    $overall_status = 0;

    $msg = Msg::new("For LMX helper thread configuration");
    $msg->log;

    my ($item, $desc, $status, $summary);
    my ($temp_status, %lmx_ht_status);

    $item = 'LMX helper thread configuration check';
    $desc = 'Checking LMX helper thread configuration on all the nodes';
    my $stage = Msg::new("Installation and Configuration Checks");
    #just get the package information
    for my $sys (@{$syslistref}) {
        $status = 1;
        my $plat = $sys->cmd('_cmd_uname 2>/dev/null');

        # [TBD] The following command may not be available
        # on other platforms.

        $msg_check = Msg::new("Checking LMX helper thread disabled on $sys->{sys}");
        $stage->display_left($msg_check);
        if (!$sys->exists('/opt/VRTSvcs/rac/bin/lmxshow')) {
            $msg = Msg::new("/opt/VRTSvcs/rac/bin/lmxshow file does not exist on $sys->{sys}. Cannot proceed with the LMX helper thread check.");
            $msg->log;
            $temp_status = 2;
        } else {
            $temp_status = $sys->cmd("/opt/VRTSvcs/rac/bin/lmxshow -t 2>/dev/null | _cmd_grep update_enabled | _cmd_cut -d ':' -f2 | _cmd_cut -d ' ' -f2");
        }

        if (($temp_status eq '') || ($temp_status eq '0')) {
            $msg = Msg::new("LMX is running with helper thread DISABLED on node: $sys->{sys}");
            $msg->log;
            $lmx_ht_status{$sys} = "LMX helper thread DISABLED on $sys->{sys}";
            $summary = "LMX helper thread DISABLED on $sys->{sys}";
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        } elsif ($temp_status eq '1') {
            $msg = Msg::new("LMX is running with helper thread ENABLED on node: $sys->{sys}. LMX helper thread should be disabled.");
            $msg->log;
            $lmx_ht_status{$sys} = 0;
            $summary = "LMX helper thread ENABLED on $sys->{sys}. LMX helper thread should be disabled.";
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $status = 0;
            $overall_status = 1;
        } elsif ($temp_status eq '2') {
            if ($plat =~ /Linux/m){
                $msg = Msg::new("LMX is not supported on Linux, hence this check is skipped on $sys->{sys}.");
                $msg->log;
                $summary = "LMX is not supported on Linux, hence this check is skipped on $sys->{sys}.";
            }
            else{
                $msg = Msg::new("Could not run LMX helper thread check on $sys->{sys} due to missing /opt/VRTSvcs/rac/bin/lmxshow file. LMX does not seem to be installed on $sys->{sys}.");
                $msg->log;
                $summary = "Could not run LMX helper thread check on $sys->{sys} due to missing /opt/VRTSvcs/rac/bin/lmxshow file. LMX does not seem to be installed on $sys->{sys}.";
            }
            $lmx_ht_status{$sys} = 1;
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $status = 2;
            $overall_status = 1;
        }

        my $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%lmx_ht_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    return $overall_status;
}

# Check the following:
# 1. [TBD - Partial] If /etc/init.d/init.cssd contains proper patch
# 1'. If Oracle Process Daemon (oprocd) is NOT running
# 2. Validate node id mismatch for LLT and CRS node ids
# 3. CRS/Oracle DB libs are linked properly
# 4. Tunable checks for LLT/LMX, VCSMM mm_max_slaves etc
# 5. [TBD - Not doing] If SFRAC version installed supports the Oracle version installed
# 6. Check whether cssd resource exists in CVM service group
#
# Return value 1 indicates failure
# Return value 2 indicates Oracle not installed
#
sub check_sfracoracleintegration_sys {
    my ($prod, $sys, $syslistref, $dbhome);
    my (%integration_status);

    my ($found);
    my ($ay,$sysname,$dirpath);
    my ($orahome,$tmpstr);
    my ($tmpstr1,$tmpint,$oragroup);
    my ($orauser,$oragroups);
    my (@fileopaths, @libpaths, $fileopath, $libpath);
    my ($oracleversion);
    my ($crshome);
    my ($skgxplibpath);
    my ($choice,$done);
    
    my ($oui_args);
    my ($line,$ayn,$aynn);
    my ($ipc_utility,$ipc_version,$ipc_lib);
    my ($overall_status, $vcs, $errstr);
    my $msg_check;

    $prod = shift;
    $sys = shift;
    $syslistref = shift;
    $is_sfcfsrac = shift;
    $dbac_present = shift;
    $overall_status = 0;
    $errstr = '';
    $vcs = $prod->prod('VCS60');
    $msg = Msg::log("is_sfcfsrac = $is_sfcfsrac");
    $msg = Msg::log("For $prod->{abbr} Oracle integration checks");

    my @nodes =@{$syslistref};

    if (Cfg::opt('responsefile')) {
        if ($prod->{crs_home} eq '') {
            $msg = Msg::log('ORA_CRS_HOME or GRID_HOME not set in responsefile. Data collector will try to get it from other information and skip the test with failure if information could not be retrieved.');
        } else {
            $crshome = $prod->{crs_home};
        }

        if ($prod->{db_home} eq '') {
            $msg = Msg::log('ORACLE_HOME not set in responsefile. Data collector will try to get it from other information and skip the test with failure if information could not be retrieved.');
        } else {
            $dbhome = $prod->{db_home};
        }

    }

    $dbhome = $prod->{db_home};
    $crshome = $prod->{crs_home};
    $orauser = $prod->{oracle_user};
    my ($item, $desc, $status, $summary);

    my $stage = Msg::new("Oracle integration checks for $prod->{abbr}");

    # Kernel parameters check
    my $res;
    $res = $prod->check_kernelparams_sys($nodes[0], $syslistref);
    if ($res)
    {
        $msg = Msg::new("Problem encountered with Kernel parameter check");
        $msg->log;
        $overall_status= 1;
    }

    for my $sys (@{$syslistref}) {
        my (@nodelist_crs, @nodename_crs, @nodenum_crs);
        my (@nodelist_llt, @nodename_llt, @nodenum_llt);
        my ($element_number, $counter, $change_required);
        my ($ret);

        # Check init.cssd patch. Not applicable for SFCFSRAC and 11gR2.
        goto OPROCD_CHECK if (($is_sfcfsrac) || ($prod->{oraver} =~ /11.2/m));
        $item = "$prod->{abbr} Oracle integration - vendor clusterware check";
        $desc = 'Checking vendor clusterware';
        $summary = 'Check for vendor clusterware is OK.';
        $status = 1;

        $msg = Msg::new("Checking vendor clusterware on $sys->{sys}");
        $stage->display_left($msg);
        $ret = $prod->check_initcssd_sys($sys, $prod->{oraver});

        if ($ret) {
            $integration_status{$sys} = "Check for vendor clusterware failed on $sys.";
            $summary = "Check for vendor clusterware failed on $sys->{sys}";
            $status = 0;
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $status = 0;
            $overall_status = 1;
        } else {
            $integration_status{$sys} = "Check for vendor clusterware is OK on $sys->{sys}.";
            $summary = "Check for vendor clusterware is OK on $sys->{sys}.";
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }

        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%integration_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }

OPROCD_CHECK :
        # Check whether Oracle Process Daemon is NOT running
        $item = "$prod->{abbr} Oracle integration - Oracle Process Daemon check";
        $desc = 'Check for Oracle Process Daemon';

        $msg_check = Msg::new("Checking presence of Oracle Process Daemon (oprocd) on $sys->{sys}");
        $stage->display_left($msg_check);
        $retval = $prod->check_oprocd_sys($sys, $prod->{oraver});

        if($dbac_present){
            if ($retval == 1) {
                $integration_status{$sys} = "Check for oprocd has failed because 'oprocd' is running on $sys->{sys}.Please stop 'oprocd' process.";
                $summary = "Check for oprocd has failed because 'oprocd' is running on $sys->{sys}.Please stop 'oprocd' process.";
                $status = 0;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $overall_status = 1;
            } elsif ($retval == 2) {
                $integration_status{$sys} = "Check for 'oprocd' is skipped on $sys->{sys}.";
                $summary = "Check for 'oprocd' is skipped on $sys->{sys}.";
                $status = 2;
                $msg = Msg::new("Skipped");
                $stage->display_right($msg);
                goto OPROC_END;
            } else {
                $integration_status{$sys} = "Check for 'oprocd' is OK on $sys->{sys}.";
                $summary = "Check for 'oprocd' is OK on $sys->{sys}.";
                $status = 1;
                $msg = Msg::new("Passed");
                $msg->log;
                $stage->display_right($msg);
            }
        }
        if($is_sfcfsrac){
            if ($retval == 1) {
                $integration_status{$sys} = "Check for 'oprocd' is OK on $sys->{sys}.";
                $summary = "Check for 'oprocd' is OK on $sys->{sys}.";
                $status = 1;
                $msg = Msg::new("Passed");
                $stage->display_right($msg);
            } else {
                $integration_status{$sys} = "Check for 'oprocd' has failed on $sys->{sys} because oprocd is not running on the system.Please start 'oprocd' process.";
                $summary = "Check for 'oprocd' has failed on $sys->{sys} because oprocd is not running on the system.Please start 'oprocd' process.";
                $status = 0;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $overall_status = 1;
            }
        }


        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%integration_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
OPROC_END:

        # Check for diagwait value
        goto CRS_END if($dbac_present);

        $item = "$prod->{abbr} Oracle integration - Diagwait value check";
        $desc = 'Check for Diagwait value';

        $msg = Msg::new("Checking the diagwait value on $sys->{sys}");
        $stage->display_left($msg);

        ###If the oprocd is running then this value is calculated o/w skipped.
        if ($is_sfcfsrac && $retval == 1) {

            my $diag = $sys->cmd("$crshome/bin/crsctl get css diagwait 2>/dev/null");
            $msg = Msg::new("diagwait value = $diag");
            $msg->log;
            $errstr = $@;
            if ($errstr)  {
                $integration_status{$sys} = "Problem running '$crshome/bin/crsctl get css diagwait' command on $sys->{sys}. ";
                $summary = "Problem running '$crshome/bin/crsctl get css diagwait' command on $sys->{sys}. ";
                $msg = Msg::new("Skipped");
                $stage->display_right($msg);
                $status = 2;
                $overall_status = 1;
            }elsif ($diag =~ /Configuration parameter diagwait is not defined./m) {

                $integration_status{$sys} = "Configuration parameter diagwait is not defined on $sys->{sys}. ";
                $summary = "Configuration parameter diagwait is not defined on $sys->{sys}.";
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $status = 0;
                $overall_status = 1;
            }else{
                if ($diag < 13) {
                    $integration_status{$sys} = "'diagwait' value is less than 13 on $sys->{sys}";
                    $summary = "'diagwait' value is less than 13 on $sys->{sys}";
                    $status = 0;
                    $msg = Msg::new("Failed");
                    $stage->display_right($msg);
                    $overall_status = 1;
                }else {
                    $integration_status{$sys} = "'diagwait' value is equal to more than 13 on $sys->{sys}";
                    $summary = "'diagwait' value is equal to or more than 13 on $sys->{sys}";
                    $status = 1;
                    $msg = Msg::new("Passed");
                    $stage->display_right($msg);
                }
            }
        }
        else {
            $integration_status{$sys} = "Check for 'diagwait' value is skipped on $sys->{sys}.";
            $summary = "Check for 'diagwait' value is skipped on $sys->{sys} because 'oprocd' is not running.";
            $status = 2;
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
        }
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%integration_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }

        goto DIAG_END if ($is_sfcfsrac);

CRS_END:
        if ($prod->{crs_release} =~ /11.2/m){
            $msg = Msg::new("Skipped node ID mismatch check for Oracle 11gR2");
            $msg->log;
            goto SFRAC_LIBLINK_CHECK;
        }

        # Check CRS and LLT node ids mismatch
        $item = "$prod->{abbr} Oracle integration - Node ID match check";
        $desc = 'Checking node ID match between LLT and Oracle Clusterware';
        $summary = 'Check for node ID match between LLT and Oracle Clusterware is OK.';
        $status = 1;
        $msg = Msg::new("Checking Node id mismatch for LLT & Oracle Clusterware on $sys->{sys}");
        $stage->display_left($msg);
        # Validate node id match for LLT and CRS.
        # First get current Oracle's membership pattern.
        # Then compare whether there is any need to
        # change llthosts and main.cf or not.
        # We have already retrieved CRS node numberings.

        # Compare the node-ids for LLT and CRS.
        # Since we have already validated olsnodes during
        # ORA_CRS_HOME validation, we don't need to repeat that here.
        my $temp_out = $sys->cmd("$crshome/bin/olsnodes -n");

        # If olsnodes command fails, we need to handle that.
        if ($temp_out =~ /failed/m) {
            $status = 0;
            $msg = Msg::new("Failure in running olsnodes command on $sys->{sys}. Node ID match check cannot proceed.");
            $msg->log;
            $summary="Failure in running olsnodes command on $sys->{sys}. Node ID match check could not proceed.";
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
            if ($ret) {
                $msg = Msg::new("Problem encountered in recording the result for '$item'");
                $msg->log;
            }

            goto SFRAC_LIBLINK_CHECK;
        }

        my $temp_list = $sys->cmd("$crshome/bin/olsnodes -n");
        @nodelist_crs = split(/\n+/, $temp_list);
        $counter=0;
        while ($nodelist_crs[$counter]) {
            chomp($nodelist_crs[$counter]);
            Msg::log("nodelist_crs[$counter]: $nodelist_crs[$counter]");
            ($nodename_crs[$counter], $nodenum_crs[$counter]) = split(/\s+/m, $nodelist_crs[$counter], 2);
            $counter++;
        }
        $msg = Msg::new("Oracle Clusterware array fillup complete");
        $msg->log;



        # Read from /etc/llthosts
        if (!$sys->exists("$vcs->{llthosts}")) {
            $status = 0;
            $msg = Msg::new("$vcs->{llthosts} file is missing on $sys->{sys}. Node ID match check cannot proceed. Skipping.");
            $msg->log;
            $summary="$vcs->{llthosts} file is missing on $sys->{sys}. Node ID match check could not proceed.";
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
            if ($ret) {
                $msg = Msg::new("Problem encountered in recording the result for '$item'");
                $msg->log;
            }

            goto SFRAC_LIBLINK_CHECK;
        }
        $temp_list = $sys->cmd("_cmd_cat $vcs->{llthosts} 2>/dev/null");
        @nodelist_llt = split(/\n+/, $temp_list);
        $counter=0;
        while ($nodelist_llt[$counter]) {
            chomp($nodelist_llt[$counter]);
            Msg::log("nodelist_llt[$counter]: $nodelist_llt[$counter]");
            ($nodenum_llt[$counter], $nodename_llt[$counter]) = split(/\s+/m, $nodelist_llt[$counter], 2);
            $counter++;
        }

        # Changing the node numbers in /etc/llthosts
        # if they are different
        # from Oracle's membership numering
        $counter=0;
        $change_required=0;
        $msg = Msg::new("LLT array fillup complete");
        $msg->log;
        $msg = Msg::new("NODE NAME\t\tLLT NODE ID\t\tOracle Clusterware NODE ID\n");
        $msg->log;
        while ($nodename_llt[$counter]) {
            $element_number = Oracle_find_element_number($nodename_llt[$counter], \@nodename_crs);

            if ($element_number eq '') {
                $msg = Msg::new("There is no node $nodename_llt[$counter] present in Oracle Clusterware membership, which is listed in $vcs->{llthosts}\n");
                $msg->log;
                $change_required=1;
                last;
            }

            $msg = Msg::new("$nodename_llt[$counter]\t\t$nodenum_llt[$counter]\t\t\t$nodenum_crs[$element_number]\n");
            $msg->log;

            if ($nodenum_llt[$counter] ne $nodenum_crs[$element_number]) {
                $nodenum_llt[$counter] = $nodenum_crs[$element_number];
                if ($change_required == 0) {
                    $change_required=1;
                }
            }

            $counter++;
        }

        $msg = Msg::new("Oracle Clusterware array fillup complete");
        $msg->log;

        if ($change_required == 1) {
            $msg = Msg::new("Node numbering of LLT and Oracle Clusterware is different. It should be fixed. This step is mandatory for $prod->{abbr} to function.\n");
            $msg->log;
            $msg = Msg::new("(Failed) Node IDs don't match");
            $stage->display_right($msg);
            $summary = 'Check for node ID match between LLT and Oracle Clusterware failed.';
            $status = 0;
            $overall_status = 1;
        } else {
            $msg = Msg::new("(Passed) Node IDs match");
            $stage->display_right($msg);
        }

        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }

SFRAC_LIBLINK_CHECK:
        # Check library linking
        $item = "$prod->{abbr} Oracle integration - Library linking check";
        $desc = 'Checking if libraries are properly linked';
        $status=1;

        $msg_check = Msg::new("Checking Oracle Library linking on $sys->{sys}");
        $stage->display_left($msg_check);
        $ret = $prod->check_liblink_sys($sys, $crshome, $dbhome, $prod->{oraver}, $prod->{orauser});

        $integration_status{$sys} = "Libraries are linked properly on $sys->{sys}.";
        $summary = "Libraries are linked properly on $sys->{sys}.";
        if ($ret eq '1') {
            $integration_status{$sys} = "Libraries are not linked properly on $sys->{sys}.";
            $summary = "Libraries are not linked properly on $sys->{sys}.";
            $status = 0;
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status = 1;
        } elsif ($ret eq '2') {
            $integration_status{$sys} = "No Oracle version found. Library linking check skipped on $sys->{sys}.";
            $summary = "No Oracle version found. Library linking check skipped on $sys->{sys}.";
            $status = 0;
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $overall_status = 1;
        } elsif ($ret eq '3') {
            $integration_status{$sys} = "Could not discover IPC library version. Library linking check skipped on $sys->{sys}.";
            $summary = "Could not discover IPC library version. Library linking check skipped on $sys->{sys}.";
            $status = 0;
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $overall_status = 1;
        } else {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%integration_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }

        # Check tunables for LLT/LMX/VCSMM
        # [TBD - Not Doing] LLT/LMX remaining
        # VCSMM done
        $item = "$prod->{abbr} Oracle integration - Tunables check";
        $desc = 'Checking tunables for VCSMM';
        $status = 1;

        $msg_check = Msg::new("Checking Tunables for VCSMM");
        $stage->display_left($msg_check);
        $ret = $prod->check_tunables_sys($sys);
        $integration_status{$sys} = 'Tunables are set properly';
        $summary = 'Tunables are set properly';
        if ($ret eq '1') {
            $integration_status{$sys} ='Tunables are not set properly';
            $summary ='Tunables are not set properly';
            $status = 0;
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status = 1;
        } elsif ($ret eq '2') {
            $integration_status{$sys} = 'Skipped the test due to missing tunable file';
            $summary ='Skipped the test due to missing tunable file';
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $overall_status = 1;
        } else {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%integration_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }

        # [TBD - Not Doing] Check compatibility of Oracle and SFRAC
        #    versions installed
        #$item = "SFRAC Oracle integration checks - Compatibility matrix";
        #$desc = "Checking the compatibility between Oracle and SFRAC versions.";


        #$ret = CPI::prepu_record_result($sys, $item, $desc, $status, $summary, \%integration_status);


        # Checking whether cssd resource exists in CVM service group
        $item = "$prod->{abbr} Oracle integration - cssd resource in CVM check";
        $desc = 'Checking whether cssd resource exists in CVM service group';
        $status = 1;

        $msg_check = Msg::new("Checking whether cssd resource exists in CVM service group");
        $stage->display_left($msg_check);
        my $smallsys = Prod::VCS60::Common::transform_system_name($sys->{sys});
        my $vcs = $prod->prod('VCS60');
        my $cssd = eval {$sys->cmd("$vcs->{bindir}/hares -list Type=Application StartProgram=~cssd-online StopProgram=~cssd-offline MonitorProgram=~cssd-monitor CleanProgram=~cssd-clean Enabled=1 2>/dev/null | _cmd_grep -i $smallsys");};
        $errstr = $@;
        if ($errstr) {
            $integration_status{$sys} = "Problem running 'hares' command on $sys->{sys}. Error info: $errstr";
            $summary = "Problem running 'hares' command on $sys->{sys}. Error info: $errstr";
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status = 1;
        } else {
            if ($cssd) {
                $integration_status{$sys} = "'cssd' resource exists in CVM service group on $sys->{sys}";
                $summary = "'cssd' resource exists in CVM service group on $sys->{sys}";
                $msg = Msg::new("Passed");
                $stage->display_right($msg);

            } else {
                $integration_status{$sys} = "'cssd' resource doesn't exist in CVM service group on $sys->{sys}";
                $summary = "'cssd' resource doesn't exist in CVM service group on $sys->{sys}";
                $status = 0;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $overall_status = 1;
            }
        }
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%integration_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
DIAG_END:
    }
    return $overall_status;
}

sub get_oracle_information {
    my ($prod, $sys, $syslistref, $dbhome, $msg);
    my ($crshome);
    my ($ayn,$aynn);
    my ($done);
    my ($orauser);
    my $ask_web = 0;
    my $web = Obj::web();
    $prod = shift;
    $sys = shift;
    $syslistref = shift;
    my $detected;

    # Try to get Oracle installation specific information from PrepU framework
    my ($oracle_arr, $ora_inventory, @temp_inventory);

    if (!exists($sys->{discover}{SOFTWARE})) {
        $sys->{discover}{SOFTWARE} = $prod->get_oracle_info($sys);
    }
    for my $oracle_arr (@{$sys->{discover}{SOFTWARE}}) {
        if ($oracle_arr->{PRODUCT} ne 'Oracle') {
            next;
        }

        $dbhome = $oracle_arr->{HOMEDIR} if (!$dbhome);
        $prod->{orabits} = $oracle_arr->{BITS};
        $prod->{oraver} = $oracle_arr->{VERSION};
        $prod->{oraarch} = $oracle_arr->{ARCH};
        $prod->{orauser} = $oracle_arr->{USERNAME};
        $msg = Msg::log("Check_sfracoracle_integration function: oraversion: $prod->{oraver}");

    }

    if ($dbhome ne '') {
        $ora_inventory = $sys->cmd("_cmd_grep inventory_loc $dbhome/oraInst.loc | _cmd_cut -d '=' -f2");
        # If remote do_sys may returns more than one value
        # and the following code should handle that.
        @temp_inventory = split(/\n/, $ora_inventory, 3);
        $ora_inventory = $temp_inventory[0];
        $msg = Msg::new("Oracle Inventory location is: $ora_inventory");
        $msg->log;
        $crshome = $sys->cmd("_cmd_cat $ora_inventory/ContentsXML/inventory.xml 2>/dev/null | _cmd_grep CRS | cut -d' ' -f3 | cut -d'=' -f2") if (!$crshome);
        $crshome =~ tr/"//d;
        if(Obj::webui()){       
            $msg = Msg::new("Oracle database detected. Enter the Oracle username to continue");           
            $web->web_script_form("alert", $msg->{msg});
            $ask_web = 1;
            $detected = 1;
        }
    } else {
        # If responsefile has been used,
        # then return with error
        if (Cfg::opt('responsefile')) {
            $msg = Msg::log('ORA_CRS_HOME or GRID_HOME and/or ORACLE_HOME not known. Skipping this test with failure.');
            return 1;
        } else {
            # Explicitly ask if Oracle is installed or not.
            $msg = Msg::new("\n The installer was unable to detect an Oracle database installation due to the absence of the ORACLE_HOME environment variable. Is it installed?");
            $ayn = $msg->ayny;
            if ($ayn eq 'N') {
                # 2 indicates Oracle not installed.
                return 2;
            }elsif($ayn eq 'Y'){

                $msg = Msg::new("\nUnless you specify the Oracle Software installation path, some checks will be skipped. Do you want to enter the Oracle Software installation path?");
                $ayn = $msg->ayny;

                if ($ayn eq 'N') {
                    # 2 indicates Oracle not installed.
                    return 2;
                }else {
                   if(Obj::webui()){                  
                       $ask_web = 1;
                   }
                }

            }
        }
    }

    if($ask_web == 1){
        my $tmpstr;
        my $crsinitdir;

        if ($sys->exists("$prod->{initdir}/init.ohasd")) {
                $crsinitdir = "$prod->{initdir}/init.ohasd";
        } else {
                $crsinitdir = "$prod->{initdir}/init.crsd";
        }
        $tmpstr= $sys->cmd("_cmd_grep 'ORA_CRS_HOME=' $crsinitdir");
        $prod->{crs_home} = (split(/=/m, $tmpstr))[1] if (!EDR::cmdexit());
    }
WEB_ASK_ORA_INFO:
    
    if($ask_web == 1){
        $done=0;
        if ($detected == 1) {
            $prod->{crs_home} = $crshome ;
            $prod->{db_home} = $dbhome ;
        } else {
            $crshome = '';
            $dbhome = '';
        }
        $prod->{sfrac_install_config_check} = 1;
        $web->web_script_form('oracle_checks', $prod, $detected);
        $prod->{sfrac_install_config_check} = 0;
        if ($web->param('back') eq 'back') {
                return "back";
        }
    }

    while (($crshome eq '') && (!$done)) {
        $done=1;

        # ORA_CRS_HOME
        if(Obj::webui()){
            goto WEB_ASK_ORA_INFO if($prod->determine_crs_home('post_crs_install'));
        }else{
            return "back" if($prod->determine_crs_home('post_crs_install'));
        }
        $crshome = $prod->{crs_home};
        chomp($crshome);

        $msg = Msg::new("\nValidating Oracle Clusterware/Grid Infrastructure home");
        $msg->log;
        if($crshome eq '..' || $crshome eq '' )  {
            $msg = Msg::new("Error");
            $msg->log;
            $msg = Msg::new("Oracle Clusterware/Grid Infrastructure Home is not specified or contains ..");
            $msg->log;
            $msg->print;
            $done = 0;
            $crshome = '';
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg});
                goto WEB_ASK_ORA_INFO;
            }
            next;
        }

        # Check if ORA_CRS_HOME is valid on all the cluster nodes.
        for my $sys (@{$syslistref}) {
            if (!$sys->is_dir($crshome)) {
                if ($prod->{oraver} =~ /11.2/m){
                    $msg = Msg::new("\nCannot find GRID_HOME at $crshome on $sys->{sys}. Do you want to skip Oracle Integration Checks?");
                }else{
                    $msg = Msg::new("\nCannot find ORA_CRS_HOME at $crshome on $sys->{sys}. Do you want to skip Oracle Integration Checks?");
                }

                $msg->log;
                $aynn = $msg->aynn;
                if ($aynn eq 'Y') {
                    $msg = Msg::new("Skipping Oracle integration checks");
                    $msg->log;
                    return 2;
                }

                $done = 0;
                $crshome = '';
                # Come out of "for loop"
                last;
            } elsif(!$sys->exists("$crshome/bin/olsnodes")) {

                if ($prod->{oraver} =~ /11.2/m){
                    $msg = Msg::new("Specified GRID_HOME patch does not seem to have Oracle Clusterware installed properly under it on $sys->{sys}. Do you want to skip Oracle Integration checks?");
                    $msg->log;

                }else{

                    $msg = Msg::new("Specified ORA_CRS_HOME path does not seem to have Oracle Clusterware installed properly under it on $sys->{sys}. Do you want to skip Oracle Integration checks?");
                    $msg->log;
                }


                $aynn = $msg->aynn;
                if ($aynn eq 'Y') {
                    $msg = Msg::new("Skipping Oracle integration checks");
                    $msg->log;
                    return 2;
                }

                $done=0;
                $crshome='';
                # Come out of "for loop"
                last;
            }
        }
    }
    $msg = Msg::new("Done");
    $msg->log;
    if ($prod->{oraver} =~ /11.2/m){
        $msg = Msg::new("GRID_HOME is: $crshome");
        $msg->log;
    } else {
        $msg = Msg::new("ORA_CRS_HOME is: $crshome");
        $msg->log;
    }
    $prod->{crs_home} = $crshome;
    $done=0;
    while (($dbhome eq '') && (!$done)) {
        $done=1;

        # DB_HOME
        if(Obj::webui()){
            goto WEB_ASK_ORA_INFO if($prod->find_db_home('relink'));
        }else{
            return 2 if($prod->find_db_home('relink'));
        }
        $dbhome = $prod->{db_home};

        chomp($dbhome);

        $msg = Msg::new("\nValidating DB home");
        $msg->log;
        if($dbhome eq '..' || $dbhome eq '' )  {
            $msg = Msg::new("Error");
            $msg->log;
            $msg = Msg::new("DB HOME is not specified or contains ..");
            $msg->log;
            $msg->print;
            $done=0;
            $dbhome='';
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg});
                goto WEB_ASK_ORA_INFO;
            }
            next;
        }

        # Check if DB_HOME is valid on all the cluster nodes.
        for my $sys (@{$syslistref}) {
            if (!$sys->is_dir($dbhome)) {
                $msg = Msg::new("Cannot find DB_HOME at $dbhome on $sys->{sys}. Do you want to skip Oracle Integration Checks?");

                $aynn = $msg->aynn();
                if ($aynn eq 'Y') {
                    $msg = Msg::new("Skipping Oracle integration checks");
                    $msg->log;
                    return 2;
                }

                $done=0;
                $dbhome='';
                # Come out of "for loop"
                last;

            # Checks for oclsmon in 10g and for oclsomon in 11g
            } elsif( !$sys->exists("$dbhome/bin/oracle") ) {
                $msg = Msg::new("Specified DB_HOME does not seem to have Oracle Database software installed properly under it on $sys->{sys}. Do you want to skip Oracle Integration checks?");
                $aynn = $msg->aynn();
                if ($aynn eq 'Y') {
                    $msg = Msg::new("Skipping Oracle integration checks");
                    $msg->log;
                    return 2;
                }

                $done=0;
                $dbhome='';
                # Come out of "for loop"
                last;
            }
        }
    }

    $done=0;
    while (($orauser eq '') && (!$done)) {
        $orauser = $sys->cmd("_cmd_ls -ald $dbhome | _cmd_awk '{print \$3}' 2> /dev/null");
	$done = 1;
        if (!Obj::webui()){
	    if ($orauser eq '') {
                $question = Msg::new("\nEnter the Oracle user name, for eg- oracle :");
                $orauser = $question->ask($deforauser);
	    }
        }else{
            $orauser = $prod->{oracle_user};
        }

        chomp($orauser);
        $msg = Msg::new("\nValidating Oracle user");
        $msg->log;
        if($orauser eq '..' || $orauser eq '' )  {
            $msg = Msg::new("Error");
            $msg->log;
            $msg = Msg::new("Oracle user name is not specified or contains ..");
            $msg->log;
            $msg->print;
            $done = 0;
            $orauser = '';
            if (Obj::webui()){
                $web->web_script_form("alert", $msg->{msg});
                goto WEB_ASK_ORA_INFO;
            }
            next;
        }

        my $warn_user = 0;

	# Check if Oracle user is valid on all the cluster nodes.
	for my $sys (@{$syslistref}) {
		my $id_ret = $sys->cmd("/usr/bin/id $orauser");
		if (EDR::cmdexit() ) {
			$msg = Msg::new("Oracle user: $orauser does not exist on $sys->{sys}.Do you want to skip Oracle Integration checks?");
			$aynn = $msg->aynn();
			if ($aynn eq 'Y') {
				$msg = Msg::new("Skipping Oracle integration checks");
				$msg->log;
				return 2;
			}
			$done = 0;
			$orauser = '';
			goto WEB_ASK_ORA_INFO if (Obj::webui());
			# Come out of "for loop"
			last;
		}
		my $dbhome_owner = $sys->cmd("_cmd_ls -ld $dbhome | _cmd_awk '{print \$3}'");
		if($dbhome_owner ne $orauser) {
			$warn_user = 1;
		}
	}
	if($warn_user eq "1") {
	    $msg = Msg::new("Oracle user entered ($orauser) does not own Oracle Database Home. Oracle specific checks might fail.\n Do you want to continue");
	    $ayn = $msg->ayny;
	    if ($ayn eq 'n' || $ayn eq 'N') {
		    goto WEB_ASK_ORA_INFO if (Obj::webui());
		    next;
	    }
	}
    }

    if ($prod->{orabits} eq '' ) {
        $prod->{orabits} = 32;
        $prod->{orabits} = 64 if ($sys->cmd("file $dbhome/bin/oracle 2>/dev/null") =~ /64/m);
    }

DNA_CHECK_DBVERSION:
    if ( $prod->{oraver} eq '' ) {
        $prod->{db_home} = $dbhome;
        $prod->{oracle_user} = $orauser;
        my $ret = $prod->get_oraver_from_opatch('db', 'Oracle Database');
        if ($ret) {
            $msg = Msg::new("Oracle Version cannot be determined");
            $msg->print;
            if (Obj::webui()){
                $prod->{sfrac_install_config_check} = 2;
                $web->web_script_form('oracle_version', $prod);
                $prod->{sfrac_install_config_check} = 0;
                if ($web->param('back') eq 'back') {
                    goto WEB_ASK_ORA_INFO;
                }
                $answer = $prod->{oraver};
            }else{
                $question = Msg::new("Enter Oracle Version (e.g. 10.2.0.1, 11.1.0.6):");
                $answer = $question->ask($prod->{$oraprod.'_release'.'.'.$oraprod.'_patch_level'}, $help, $backopt);
            }
            chomp($answer);

            @digits = split(/\./m, $answer);
            $release = "$digits[0].$digits[1]";

            if (($release ne '10.2') && ($release ne '11.1') && ($release ne '11.2')) {
                $msg = Msg::new("The Oracle version $answer is not valid. Input again");
                $msg->log;
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                goto DNA_CHECK_DBVERSION;
            }
            $prod->{oraver} = $release;
        }
    }

    $prod->{db_home} = $dbhome;
    $prod->{orauser} = $orauser;
    $prod->{bits} = $prod->{orabits};

DNA_CHECK_CRSVERSION:
    if ( $prod->{crs_release} eq '' ) {
        $prod->{crs_home} = $crshome;
        $prod->{oracle_user} = $orauser;
        $ret = $prod->get_oraver_from_opatch('crs', 'Oracle Clusterware');
        if ($ret != 0) {   
            $ret = $prod->get_oraver_from_opatch('crs', 'Oracle Grid Infrastructure');
        }
        if ($ret) {
            $msg = Msg::new("Oracle Clusterware Version cannot be determined");
            $msg->print;
            if (Obj::webui()){
                $prod->{sfrac_install_config_check} = 3;
                $web->web_script_form('crs_version', $prod);
                $prod->{sfrac_install_config_check} = 0;
                if ($web->param('back') eq 'back') {
                    goto DNA_CHECK_DBVERSION;
                }
                $answer = $prod->{crs_release};
            }else{
                $question = Msg::new("Enter Oracle Clusterware Version (e.g. 10.2.0.1, 11.1.0.6):");
                $answer = $question->ask($prod->{$oraprod.'_release'.'.'.$oraprod.'_patch_level'}, $help, $backopt);
            }
            chomp($answer);

            @digits = split(/\./m, $answer);
            $release = "$digits[0].$digits[1]";

            if (($release ne '10.2') && ($release ne '11.1') && ($release ne '11.2')) {
                $msg = Msg::new("The Oracle version $answer is not valid. Input again");
                $msg->log;
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                goto DNA_CHECK_CRSVERSION;
            }

            $prod->{crs_release} = $release;
        }
    }
    $msg = Msg::new("Done");
    $msg->log;
    $msg = Msg::new("DB_HOME is: $dbhome");
    $msg->log;
    $msg = Msg::new("BITS is: $prod->{orabits}");
    $msg->log;
    $msg = Msg::new("ORAVERSION is: $prod->{oraver}");
    $msg->log;
    $msg = Msg::new("CRSVERSION is: $prod->{crs_release}");
    $msg->log;

    return 0;
}


# Function to get element number in Oracle's provided nodelist,
# which will be compared with nodenames from llthosts/main.cf.
sub Oracle_find_element_number {
    my($node_name, $array_ref);
    my($counter);

    $counter=0;
    $node_name = shift;
    $array_ref = shift;
    while ($array_ref->[$counter]) {
        Msg::log("Oracle Clusterware name: '$array_ref->[$counter]', LLT name: '$node_name'");
        if ("$array_ref->[$counter]" eq "$node_name") {
            return $counter;
        }
        $counter++;
    }

    return '';
}

# Check tunables for VCSMM
#
# Return value 1 means failure
# Return value 2 means skipped the test
#
sub check_tunables_sys {
    my ($sys, $mm_slave_max);

    $prod = shift;
    $sys = shift;

    # Check VCSMM tunables

    if ($prod->{vcsmmconfig} eq '') {
        $msg = Msg::new("vcsmm config file not supplied on $sys->{sys}, using default value: 32768 for mm_slave_max");
        $msg->log;
        return 0;
    }

    if (!$sys->exists($prod->{vcsmmconfig})) {
        if ($sys->hpux()) {
            $msg = Msg::new("$prod->{vcsmmconfig} file does not exist on $sys->{sys}. Trying to get value for mm_slave_max using system command.");
            $msg->log;
            $mm_slave_max = $sys->cmd("_cmd_kctune -m vcsmm  2>/dev/null | _cmd_grep mm_slave_max | _cmd_awk '{print \$3}'");
        } else {
            $msg = Msg::new("$prod->{vcsmmconfig} file does not exist on $sys->{sys}. Skipping the tunable check for VCSMM. Using default value: 32768 for mm_slave_max");
            $msg->log;
            return 2;
        }
    } else {
        $mm_slave_max = $sys->cmd("_cmd_cat $prod->{vcsmmconfig} 2>/dev/null | grep '^mm_slave_max=' 2>/dev/null | _cmd_cut -d '=' -f2");

        if ($sys->hpux()) {
            $msg = Msg::new("Could not get mm_slave_max value from $prod->{vcsmmconfig} file on $sys->{sys}. Trying to get value for mm_slave_max using system command.");
            $msg->log;
            $mm_slave_max = $sys->cmd("_cmd_kctune -m vcsmm  2>/dev/null | _cmd_grep mm_slave_max | _cmd_awk '{print \$3}'");
        }
    }

    chomp($mm_slave_max);
    if ($mm_slave_max eq '') {
        $msg = Msg::new("mm_slave_max is not set in $prod->{vcsmmconfig} on $sys->{sys}, using default value: 32768");
        $msg->log;
        return 0;
    }

    if ($mm_slave_max lt '256') {
        $msg = Msg::new("Low value ($mm_slave_max) specified for mm_slave_max in $prod->{vcsmmconfig} on $sys->{sys}. This may cause problems for Oracle RAC. Specify value larger than 256");
        $msg->log;
        return 1;
    }

    # If we come here, then it means mm_slave_max is proper
    $msg = Msg::new("mm_slave_max value is proper on $sys->{sys}");
    $msg->log;
    return;
}



# Checks the following:
# 1'    - Check whether links are full duplex or not
# 1''   - Check whether jumbo frame settings are same of all the links
sub check_lltprechecks_sys {
    my ($sys, $syslistref, $cmd_ret, $llt_link1, $llt_link2);
    my ($item,$desc,$cfg);
    my ($overall_status);
    my $msg_check;

    $prod = shift;
    $sys = shift;
    $syslistref = shift;

    $cfg = Obj::cfg();
    $overall_status=0;

    # (1') Check whether links are full duplex or not
    $item = "Links' Full Duplex setting check";
    $desc = 'Checking link duplex setting';
    my $stage = Msg::new("Installation and Configuration Checks");
    for my $sys (@{$syslistref}) {
        my $sysi = $sys->{sys};
        $msg_check = Msg::new("Checking LLT Links' Full Duplex setting for $sys->{sys}");
        $stage->display_left($msg_check);
        if (Cfg::opt('responsefile')) {
            if ($cfg->{vcs_lltlink1}{$sysi} eq '') {
                $msg = Msg::new("LLT Link1 not defined. Network links' duplexity check cannot proceed for $sys->{sys}.");
                $msg->log;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                next;
            } else {
                $llt_link1 = $cfg->{vcs_lltlink1}{$sysi};
            }

            if ($cfg->{vcs_lltlink2}{$sysi} eq '') {
                $msg = Msg::new("LLT Link2 not defined. Using only one link");
                $msg->log;
            } else {
                $llt_link2 = $cfg->{vcs_lltlink2}{$sysi};
            }

            # As of now, check for only two links available. LLT links info passed.
            $cmd_ret = $prod->check_full_duplex_link_sys($sys, 1, $item, $desc, $llt_link1, $llt_link2);
        } else {
            # As of now, check for only two links available. LLT link info not passed.
            $cmd_ret = $prod->check_full_duplex_link_sys($sys, 0, $item, $desc, $llt_link1, $llt_link2);
        }

        if ($cmd_ret == 0) {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        } elsif ($cmd_ret == 2) {
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $overall_status=1;
        } elsif ($cmd_ret == 3) {
            $msg = Msg::new("Not Applicable (Virtual Devices)");
            $stage->display_right($msg);
        } else {
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status=1;
        }
    }

    # (1'') Check whether jumbo frame settings are same of all the links
    $item = 'Link Jumbo Frame setting (MTU) check';
    $desc = 'LLT private links Jumbo Frame setting (MTU)';

    my %frame_size = {};
    my $mismatch = 0;

    $msg_check = Msg::new("Checking LLT Link Jumbo Frame setting (MTU)");
    $stage->display_left($msg_check);

    for my $sys (@{$syslistref}) {
        my $sysi = $sys->{sys};
        if (Cfg::opt('responsefile')) {
            if ($cfg->{vcs_lltlink1}{$sysi} eq '') {
                $msg = Msg::new("LLT Link1 not defined. Network links' Jumbo frame check cannot proceed for $sys->{sys}.");
                $msg->log;
                $mismatch = 2;
                goto PRN_RES;
            } else {
                $llt_link1 = $cfg->{vcs_lltlink1}{$sysi};
            }

            if ($cfg->{vcs_lltlink2}{$sysi} eq '') {
                $msg = Msg::new("LLT Link2 not defined. Using only one link");
                $msg->log;
            } else {
                $llt_link2 = $cfg->{vcs_lltlink2}{$sysi};
            }

            # As of now, check for only two links available. LLT links info passed.
            $frame_size{$sys} = $prod->get_jumbo_frame_setting_sys($sys, 1, $item, $desc, $llt_link1, $llt_link2);
        } else {
            # As of now, check for only two links available. LLT link info not passed.
            $frame_size{$sys} = $prod->get_jumbo_frame_setting_sys($sys, 0, $item, $desc, $llt_link1, $llt_link2);
        }

    }

    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1->{sys} eq $sys2->{sys}) {
                next;
            }
            if ($frame_size{$sys} ne '-1') {
                if ($frame_size{$sys1} ne $frame_size{$sys2}) {
                    $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                    $ii = $ii + 1;
                    $mismatch = 1;
                }
            } else {
                $mismatch = 2;
                goto PRN_RES;
            }
        }
    }

    # For single node clusters.
    my $nodecnt = @{$syslistref};
    if ($nodecnt == 1) {
        my @fsize = split(' ', $frame_size{$sys});
        if ( ($fsize[0] eq '-1') || ($fsize[1] eq '-1') ) {
            $mismatch = 2;
        } elsif ($fsize[0] ne $fsize[1]) {
            $mismatch = 1;
        } else {
            $mismatch = 0;
        }
        goto PRN_RES;
    }

    if ($mismatch) {
        $msg = Msg::new("The check for jumbo frame size is failed. All links of all the nodes should have same jumbo frame size.");
        for ($ii=0; $ii<=$#diff; $ii++) {
            $mismatch_list = $mismatch_list.' '.$diff[$ii];
        }
        $msg = Msg::new("Combinations with mismatched jumbo frame settings: $mismatch_list");
        $msg->log;
    }

PRN_RES:
    if ($mismatch == 0) {
        $msg = Msg::new("Passed");
        $stage->display_right($msg);

        $status = 1;
        $summary = 'All the links in the cluster have identical jumbo frame settings.';

    } elsif ($mismatch == 2) {
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        $overall_status=1;
        $status = 0;
        $summary = 'Cannot proceed with the check for jumbo frame settings. Skipping.';

    } else {
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});
        $overall_status=1;
        $status = 0;
        $summary = 'Some links in the cluster have different jumbo frame settings.';
    }

    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);


    # (3) Check whether any of the systems have cross connected links.
    $item = 'LLT links cross connection check';
    $desc = 'Checking whether links of a system are cross connected (multiple links connected to a single switch or connected directly )';
    for my $sys (@{$syslistref}) {
        my $sysi = $sys->{sys};
        $msg_check = Msg::new("Checking for LLT Links' cross connection for $sys->{sys}");
        $stage->display_left($msg_check);
        if (Cfg::opt('responsefile')) {
            if ($cfg->{vcs_lltlink1}{$sysi} eq '') {
                $msg = Msg::new("LLT Link1 not defined. Network links' cross connection check cannot proceed for $sys->{sys}.");
                $msg->log;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                next;
            } else {
                $llt_link1 = $cfg->{vcs_lltlink1}{$sysi};
            }

            if ($cfg->{vcs_lltlink2}{$sysi} eq '') {
                $msg = Msg::new("LLT Link2 not defined. Using only one link");
                $msg->log;
            } else {
                $llt_link2 = $cfg->{vcs_lltlink2}{$sysi};
            }

            # As of now, check for only two links available. LLT links info passed.
            $cmd_ret = $prod->check_cross_connection_sys($sys, 1, $item, $desc, $llt_link1, $llt_link2);

        } else {
            # As of now, check for only two links available. LLT links info passed.
            $cmd_ret = $prod->check_cross_connection_sys($sys, 0, $item, $desc, $llt_link1, $llt_link2);
        }

        if ($cmd_ret == 0) {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        } elsif ($cmd_ret == 2) {
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $overall_status=1;
        } else {
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status=1;
        }
    }

    return $overall_status;
}


sub check_cross_connection_sys {
    my ($sys,$flag,@link,@dev,$ret,$errstr);
    my ($item, $desc, $summary, $output, @arr, $retval);
    my ($command, $macaddr, $pid, $status, $result, $prod, $msg);

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    if ($flag == 1) {
        $link[0] = shift;
        if($link[0] =~ '(.*)([0-9])') {
            $dev[0] = "/dev/$1:$2";
        }
        $link[1] = shift;
        if($link[1] =~ '(.*)([0-9])') {
            $dev[1] = "/dev/$1:$2";
        }

    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");
            $dev[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");
            $dev[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}'");

            $msg = Msg::new("LLT Link1 on $sys->{sys}: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $link[1]");
            $msg->log;

        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT links' cross connection check cannot proceed for $sys->{sys}");
            $msg->log;
            $summary = "/etc/llttab not present on $sys->{sys}.Hence Skipping this test. ";
            $retval = 2;
            $status = 0;
            goto SKIPPED_TEST;
        }
    }

    $retval = 2;
    $status = 0;

    my $plat = $sys->cmd('_cmd_uname 2>/dev/null');

    if ($sys->{padv} =~ /Sol11/m) {
        $dev[0] =~ s/^.*\///mx;
        $dev[0] =~ s/://mx;
        $dev[0] = '/dev/net/'.$dev[0];
        $dev[1] =~ s/^.*\///mx;
        $dev[1] =~ s/://mx;
        $dev[1] = '/dev/net/'.$dev[1];
    }

    $macaddr = '';
    if ($plat =~ /Linux/m) {
        my $add_dev0 = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}' | _cmd_cut -d'-' -f2 ");
        my $add_dev1 = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}' | _cmd_cut -d'-' -f2 ");
        $dev[0] = $sys->cmd("_cmd_ifconfig -a | _cmd_grep -i $add_dev0 | _cmd_awk \'{print \$1}\' | _cmd_head -1");
        $dev[1] = $sys->cmd("_cmd_ifconfig -a | _cmd_grep -i $add_dev1 | _cmd_awk \'{print \$1}\' | _cmd_head -1");

        $macaddr = $sys->cmd("_cmd_ifconfig -a | _cmd_grep -i $add_dev0 | _cmd_awk \'{print \$5}\' | _cmd_head -1");

        $msg = Msg::new("uname is $tmp on $sys->{sys}");

        $msg = Msg::new("add_dev0: $add_dev0 and add_dev1: $add_dev1  on $sys->{sys}");
        $msg->log;
        $msg = Msg::new("dev[0]:$dev[0] and dev[1]:$dev[1]  on $sys->{sys}");
        $msg->log;
        $msg = Msg::new("macaddr is $macaddr  on $sys->{sys}");
        $msg->log;
   } else {

        if ($sys->exists('/opt/VRTSllt/getmac')) {
            $macaddr = $sys->cmd("/opt/VRTSllt/getmac $dev[0] | _cmd_awk '{print \$2}'");
        } else {
            $summary = "The check cannot be done on $sys->{sys} as /opt/VRTSllt/getmac command is not found";
            $msg = Msg::new("getmac command does not exist on $sys->{sys}. LLT links' cross connection check cannot proceed for $sys->{sys}");
            $msg->log;
        }
   }

   if ($sys->exists('/opt/VRTSllt/dlpiping')) {
       $command = "/opt/VRTSllt/dlpiping -s $dev[0] > /dev/null 2>&1 < /dev/null &";
       $sys->cmd($command);
       $errstr = $@;
       if (EDR::cmdexit()) {
           $msg = Msg::new("Problem executing the command: $command on $sys->{sys}");
           $msg->log;
           $msg = Msg::new("error info: $errstr");
           $msg->log;
           $result = 'unknown result';
           goto EXIT_TEST;
       }
       sleep 5;
       #$command = "/opt/VRTSllt/dlpiping -c $dev[1] $macaddr";
       $result = $sys->cmd("/opt/VRTSllt/dlpiping -c $dev[1] $macaddr 2>/dev/null");

EXIT_TEST:

       if ( $result =~ /is alive/m) {
           $status = 0;
           $summary = "LLT links are cross connected on $sys->{sys}";
           Msg::log("LLT links are cross connected on $sys->{sys}");
           $retval = 1;
       } elsif ( $result =~ /no response/m ) {
           $status = 1;
           $summary = "LLT links are not cross connected on $sys->{sys}";
           $retval = 0;
       } else {
           $status = 0;
           $summary = 'Cannot determine whether LLT links are cross connected or not';
           $retval = 2;
       }

       # To kill the dlpiping server.

       $output = $sys->cmd("_cmd_ps -ef | _cmd_grep '/opt/VRTSllt/dlpiping -s $dev[0]' | _cmd_grep -v grep | _cmd_awk '{ print \$2}' ");
       @arr = split(/\n/, $output);
       $msg = Msg::new("Killing the dlpiping server on $sys->{sys}");
       $msg->log;
       for my $pid (@arr) {
           $sys->cmd("_cmd_kill -9 $pid");    # If mulptiple servers get created
       }

   } else {
       ####/opt/VRTSllt/dlpiping is present only on 5.1 version or higher
       $summary = "The check cannot be done on $sys->{sys} as /opt/VRTSllt/dlpiping command is not found";
       $msg = Msg::new("dlpiping command does not exist on $sys->{sys}. LLT links' cross connection check cannot proceed for $sys->{sys}.");
       $msg->log;
   }

SKIPPED_TEST:

   $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
   if ($ret) {
       $msg = Msg::new("Problem encountered in recording the result for '$item'");
       $msg->log;
   }
   return $retval;
}


# Checks the following:
# 1. Unique MAC addresses across cluster and NIC speed and
#    autonegotiation setting
# 2. LLT links' priorities, and also if LLT links are on public network
# 3. /etc/llthosts same on all the nodes
# 4. Cluster-id in /etc/llttab same on all the nodes
sub check_lltprivnetwork_sys {
    my ($sys, $sys1, $sys2, $syslistref, $ii, $ret, $devudp);
    my (@diff, $flag, $cmd_ret, %clusid, $ora_user);
    my ($llt_link1, $llt_link2);
    my (%check_status, $item, $desc, $summary, $status);
    my ($llthosts_file_present, $llttab_file_present);
    my ($llthosts_bad_flag, $llttab_bad_flag, $orauserperm);
    my ($overall_status, $vcs, $prod, $data, $plat, $localsys, $errstr);
    my $msg_check;

    $prod = shift;
    $sys=shift;
    $syslistref=shift;
    $devudp = shift;

    $overall_status=0;
    $errstr = '';
    my $stage = Msg::new("Installation and Configuration Checks");
    $vcs = $prod->prod('VCS60');
    $localsys = $prod->localsysname;

    # Check the presence of /etc/llttab on all the nodes
    $llttab_file_present = -1;
    $llttab_bad_flag = 0;
    for my $sys (@{$syslistref}) {

        if ($sys->exists("$vcs->{llttab}")) {
            if ($llttab_file_present eq '-1') {
                $llttab_file_present = 1;
            } elsif ($llttab_file_present eq '0') {
                $llttab_bad_flag = 1;
                last;
            }
        } else {
            if ($llttab_file_present eq '-1') {
                $llttab_file_present = 0;
            } elsif ($llttab_file_present eq '1') {
                $llttab_bad_flag = 1;
                last;
            }
        }
    }

    if ($llttab_bad_flag) {
        $msg = Msg::new("Checking LLT Private Links");
        $msg->log;
        $msg = Msg::new("$vcs->{llttab} file is not present on some nodes, while it is present on other nodes.");
    }

    if (!$llttab_file_present) {
        $msg = Msg::new("$vcs->{llttab} file is not present on any node. Skipping LLT Private Link Check.");
        $msg->log;
        goto LLT_LINK_CHECK_EXIT;
    }

    if ($devudp) {
        goto LLT_LINK_CHECK_EXIT;
    }

    #(1) NIC speed and autonegotiation setting
    for my $sys (@{$syslistref}) {
        my $sysi = $sys->{sys};
        $msg_check = Msg::new("Checking LLT Links' speed and auto negotiation settings for $sys->{sys}");
        $stage->display_left($msg_check);
        if (Cfg::opt('responsefile')) {
            if ($cfg->{vcs_lltlink1}{$sysi} eq '') {
                $msg = Msg::new("LLT Link1 not defined. Network links check cannot proceed for $sys->{sys}.");
                $msg->log;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                next;
            } else {
                $llt_link1 = $cfg->{vcs_lltlink1}{$sysi};
            }

            if ($cfg->{vcs_lltlink2}{$sysi} eq '') {
                $msg = Msg::new("LLT Link2 not defined. Using only one link");
                $msg->log;
            } else {
                $llt_link2 = $cfg->{vcs_lltlink2}{$sysi};
            }

            # As of now, check for only two links available.
            $cmd_ret = $prod->check_mac_speed_autoneg_sys($sys, 1, $llt_link1, $llt_link2);
        } else {
            # As of now, check for only two links available.
            $cmd_ret = $prod->check_mac_speed_autoneg_sys($sys, 0, $llt_link1, $llt_link2);
        }

	if ($cmd_ret == 2) {
   	    $msg = Msg::new("LLT interface are virtual interface(vlan) hence skipping check.");
            $msg->log;
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            next;
        } 

        if ($cmd_ret == 0) {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        } elsif ($cmd_ret == 3) {
            $msg = Msg::new("Not Applicable (Virtual Devices)");
            $stage->display_right($msg);
        } else {
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg}); 
            $overall_status=1;
        }

    }

LLT_LINK_CHECK_EXIT:

    # (2) LLT links' priorities, and also if LLT links are on public network
    for $sys (@{$syslistref}) {
        $item = "LLT links' high priority and private link check";
        $desc = 'Checking if at least 2 high priority LLT links are present and if they are on private network';

        $msg_check = Msg::new("Checking LLT Links configured on private link and as high priority on $sys->{sys}");
        $stage->display_left($msg_check);
        my ($links, @linkinfo, @pris, $hipri, $lopri, $numlinks);
        $cmd_ret = 0;

        eval {$links = $sys->cmd("_cmd_lltstat -l 2>/dev/null | _cmd_grep 'link' | _cmd_grep 'pri'");};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem running lltstat on $sys->{sys}. Problem info: $errstr");
            $msg->log;
            $msg = Msg::new("Skipped due to failure in lltstat");
            $stage->display_right($msg);
            $overall_status=1;
            next;
        }

        @linkinfo = split(/\n/, $links);
        $numlinks = $#linkinfo + 1;
        $msg = Msg::new("The number of links used by LLT on $sys->{sys}: $numlinks");
        $msg->log;

        # Warn if number of LLT links < 2
        if ($numlinks < 2) {
            $msg = Msg::new("Number of LLT links used are insufficient: $numlinks");
            $msg->log;
            $cmd_ret = 1;
        }

        # Check priority of links
        for ($ii = 0; $ii < $numlinks; $ii++) {
            $pris[$ii] = $sys->cmd("echo '$linkinfo[$ii]' 2>/dev/null | _cmd_awk '{print \$6}'");
            chomp($pris[$ii]);
        }
        $hipri = 0;
        $lopri = 0;
        for ($ii = 0; $ii < $#pris + 1; $ii++) {
            if ($pris[$ii] eq 'hipri') {
                $hipri++;
            } else {
                $lopri++;
            }
        }
        $msg = Msg::new("The number of High Priority links on $sys->{sys}: $hipri");
        $msg->log;

        # Warn if there is less than 2 hipri links
        if ($hipri < 2) {
            $msg = Msg::new("There are only $hipri High Priority links present on $sys->{sys}");
            $msg->log;
            $cmd_ret = 1;
        }

        # Warn if any of the LLT links is on public network
        my ($pubipaddr, $link1, $link2, $public_status);
        eval {$pubipaddr = gethostbyname($sys->{sys}); $pubipaddr = inet_ntoa($pubipaddr);};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem using Perl function gethostbyname/inet_ntoa on $sys->{sys}. Problem info: $errstr");
            $msg->log;
            $msg = Msg::new("Skipped due to failure in calling Perl's sub");
            $msg->log;
            $overall_status = 1;
            next;
        }
        chomp($pubipaddr);
        $msg = Msg::new("Public IP plumed on $sys->{sys} is: $pubipaddr");
        $msg->log;

        $link1 = $sys->cmd("echo '$linkinfo[0]' 2>/dev/null | _cmd_awk '{print \$3}'");
        $link2 = $sys->cmd("echo '$linkinfo[1]' 2>/dev/null | _cmd_awk '{print \$3}'");

        $msg = Msg::new("LLT Link 1 as per lltstat: $link1");
        $msg->log;
        $msg = Msg::new("LLT Link 2 as per lltstat: $link2");
        $msg->log;

        $public_status = $prod->check_llt_link_public_sys($sys, $pubipaddr, $link1, $link2);

        if ($public_status) {
            $msg = Msg::new("At least one of the LLT links is on public network on $sys->{sys}");
            $msg->log;
            $cmd_ret = 1;
        }

        if ($cmd_ret eq 0) {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
            $summary = "Success on $sys->{sys}: Found at leat 2 high priority LLT links and they are in a private network";
            $status = 1;
        } else {
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg}); 
            $summary = "Failure on $sys->{sys}: Cannot find 2 high priority LLT links or they are on a public network";
            $status = 0;
            $overall_status=1;
        }
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    #(3) /etc/llthosts same on all the nodes
    $item = "LLT configuration - $vcs->{llthosts} check";
    $desc = "Check for $vcs->{llthosts} file match. $vcs->{llthosts} should be identical on all the cluster nodes.";
    $status = 1;
    $llthosts_file_present = -1;
    $llthosts_bad_flag = 0;

    EDR::cmd_local('_cmd_rm -rf /tmp/llthosts 2>/dev/null');
    EDR::cmd_local('_cmd_mkdir -p /tmp/llthosts 2>/dev/null');
    for my $sys (@{$syslistref}) {
        if ($sys->exists($vcs->{llthosts})) {
            if ($llthosts_file_present eq '-1') {
                $llthosts_file_present = 1;
            } elsif ($llthosts_file_present eq '0') {
                $llthosts_bad_flag = 1;
                last;
            }
        } else {
            if ($llthosts_file_present eq '-1') {
                $llthosts_file_present = 0;
            } elsif ($llthosts_file_present eq '1') {
                $llthosts_bad_flag = 1;
                last;
            }
        }
    }

    # If /etc/llthosts is present on some nodes,
    # and not present on other nodes, then report
    # error.
    if ($llthosts_bad_flag eq '1') {
        $msg_check = Msg::new("Checking for $vcs->{llthosts} file match");
        $stage->display_left($msg_check);
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});
        $check_status{$sys} = "$vcs->{llthosts} file is not present on some nodes, while it is present on other nodes";
        $summary = "$vcs->{llthosts} file is not present on some nodes, while it is present on other nodes";
        $status = 0;
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }

        goto LLTHOSTS_CHECK_RECORD;
    }

    # For single node VIAS test.
    if (!$llthosts_file_present) {
        $msg = Msg::new("($vcs->{llthosts} file is not present on any node. Skipping this check.");
        $msg->log;
        goto LLTHOSTS_CHECK_EXIT;
    }

    $msg_check = Msg::new("Checking for $vcs->{llthosts} file match");
    $stage->display_left($msg_check);

    for my $sys (@{$syslistref}) {
        if ($sys->{islocal}) {
            EDR::cmd_local("_cmd_cp $vcs->{llthosts} /tmp/llthosts/$sys->{sys} 2>/dev/null");
        } else {
            $msg = Msg::new("Transport used is : $sys->{rcp}");
            $msg->log;
            $sys->copy_to_sys($prod->localsys,$vcs->{llthosts},"/tmp/llthosts/$sys->{sys}");        # Copies from remote system $sys to local system.
        }
    }

    # [TBD - Optimize] The below logic can be enhanced where we
    # compare each row of /etc/llthosts to find the difference.
    # Today, it's simple "diff command".
    $flag = 0;
    $ii = 0;
    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1->{sys} eq $sys2->{sys}) {
                next;
            }

            #remove blank lines
            EDR::cmd_local("_cmd_awk '/./' /tmp/llthosts/$sys1->{sys} > /tmp/llthosts/$sys1->{sys}.tmp 2> /dev/null");
            EDR::cmd_local("_cmd_awk '/./' /tmp/llthosts/$sys2->{sys} > /tmp/llthosts/$sys2->{sys}.tmp 2> /dev/null");
            EDR::cmd_local("_cmd_mv /tmp/llthosts/$sys1->{sys}.tmp  /tmp/llthosts/$sys1->{sys} 2> /dev/null");
            EDR::cmd_local("_cmd_mv /tmp/llthosts/$sys2->{sys}.tmp  /tmp/llthosts/$sys2->{sys} 2> /dev/null");

            EDR::cmd_local("_cmd_diff -b /tmp/llthosts/$sys1->{sys} /tmp/llthosts/$sys2->{sys} 2>/dev/null");
            if (EDR::cmdexit() == 0) {
                $msg = Msg::new("$vcs->{llthosts} identical on $sys1->{sys} & $sys2->{sys}");
                $msg->log;
            } else {
                $msg = Msg::new("$vcs->{llthosts} different on $sys1->{sys} & $sys2->{sys}");
                $msg->log;
                $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                $ii = $ii + 1;
                $flag = (!$flag)? 1 : $flag;
            }
        }
    }

    if ($flag) {
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});
        $overall_status=1;

        # Log all the mismatch cases.
        $msg = Msg::new("==========================");
        $msg->log;
        $msg = Msg::new("/etc/llthosts differences between:");
        $msg->log;
        for ($ii = 0; $ii <= $#diff ; $ii++ ) {
            $msg = Msg::new($diff[$ii]);
            $msg->log;
        }
        $msg = Msg::new("==========================");
        $msg->log;
        $check_status{$sys} = "$vcs->{llthosts} is not identical on all hosts";
        $summary = "$vcs->{llthosts} is not identical on all hosts";
        $status = 0;
    } else {
        $msg = Msg::new("Passed");
        $stage->display_right($msg);
        $check_status{$sys} = "$vcs->{llthosts} is identical on all hosts";
        $summary = "$vcs->{llthosts} is identical on all hosts";
    }

LLTHOSTS_CHECK_RECORD:
    # Record the result.
    $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%check_status);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

LLTHOSTS_CHECK_EXIT:

    #(4) Cluster-id in /etc/llttab same on all the nodes
    $item = 'LLT configuration - Cluster-ID check';
    $desc = "Check for cluster-ID (specified in $vcs->{llttab}) match. cluster-ID should be identical on all cluster nodes.";
    $status = 1;
    $msg_check = Msg::new("Checking for cluster-ID match");
    $stage->display_left($msg_check);

    $flag = 0;
    $ii = 0;

    # If /etc/llttab is present on some nodes,
    # and not present on other nodes, then report
    # error.
    if ($llttab_bad_flag eq '1') {
        $msg = Msg::new("Checking for $vcs->{llttab} file match");
        $msg->log;
        $msg = Msg::new("$vcs->{llttab} file is not present on some nodes, while it is present on other nodes");
        $msg->log;
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        $summary = "/etc/llttab not present on $sys->{sys}.Hence Skipping this test. ";
        $status = 0;
        $overall_status=1;
        goto LLTTAB_CHECK_RECORD;
    }

    if (!$llttab_file_present) {
        $msg = Msg::new("$vcs->{llttab} file is not present on any node. Skipping cluster-ID match check.");
        $msg->log;
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        $summary = "/etc/llttab not present on $sys->{sys}.Hence Skipping this test. ";
        $status = 0;
        $overall_status=1;
        goto LLTTAB_CHECK_RECORD;
    }

    for my $sys (@{$syslistref}) {
        if ($sys->exists("$vcs->{llttab}")) {
            $clusid{$sys} = $sys->cmd("_cmd_cat $vcs->{llttab} 2>/dev/null | _cmd_grep set-cluster | _cmd_awk '{print \$2}'");
        }
    }

    for my $sys1 (@{$syslistref}) {
        for my $sys2 (@{$syslistref}) {
            if ($sys1->{sys} eq $sys2->{sys}) {
                next;
            }

            if ($clusid{$sys1} ne $clusid{$sys2}) {
                $diff[$ii] = "$sys1->{sys}:$sys2->{sys}";
                $ii = $ii + 1;
                $flag = 1;
            }
        }
    }

    if ($flag) {
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});
        $overall_status=1;

        # Log all the mismatch cases.
        Msg::log("==========================");
        Msg::log("Cluster-ID differences between:");
        for ($ii = 0; $ii <= $#diff ; $ii++ ) {
            Msg::log($diff[$ii]);
        }
        Msg::log("==========================");

        $check_status{$sys} = 'Cluster-ID is not identical on all hosts';
        $summary = 'Cluster-ID is not identical on all hosts';
        $status = 0;
    } else {
        $msg = Msg::new("Passed");
        $stage->display_right($msg);
        $check_status{$sys} = 'Cluster-ID is identical on all hosts';
        $summary = 'Cluster-ID is identical on all hosts';
    }

LLTTAB_CHECK_RECORD:
    # Record the result.
    $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%check_status);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    $item = 'LLT Link Count Check';
    $desc = 'Check for number of llt links configured';

    for my $sys (@{$syslistref}) {
        $msg_check = Msg::new("Checking for the number of llt links on $sys->{sys}");
        $stage->display_left($msg_check);
        $status = 1;
        if ($llttab_file_present) {
            my $llt_nic_val  = $sys->cmd("_cmd_grep '^link' $vcs->{llttab} | _cmd_awk '{print \$2}' | _cmd_uniq");
            my @llt_nics = split(/\n/, $llt_nic_val);
            my $llt_nicnos = @llt_nics;
            $msg = Msg::new("$llt_nicnos links configured for llt on $sys->{sys}.");
            $msg->log;
            if ($llt_nicnos < 2) {
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
                $overall_status=1;

                # Log the messages.
                $msg = Msg::new("Less than 2 links configured for llt on $sys->{sys}.");
                $msg->log;

                $summary = "$llt_nicnos links configured. Number of links configured should be equal to or more than 2";
                $status = 0;
            } else {
                $msg = Msg::new("Passed");
                $stage->display_right($msg);

                # Log the messages.
                $msg = Msg::new("2 or more links configured for llt on $sys->{sys}.");
                $msg->log;

                $summary = "$llt_nicnos links configured. Minimum 2 links is configured ";
                $status = 1;
            }
        } else {
            $msg = Msg::new("/etc/lltab file is not found. Skipping the count for llt links on $sys->{sys}.");
            $msg->log;
            $summary = "/etc/llttab file is not present on $sys->{sys}. Skipping this test. ";
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            $status = 2;
        }

        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }
LLTTAB_CHECK_EXIT:

    return $overall_status;
}

#  Check if user nobody exists on the system. 

sub check_user_nobody{

    my ($prod, $sys, $syslistref,$msg);
    my ($overall_status );

    $prod = shift;
    $sys= shift;
    $syslistref = shift;
    $user_nobody = "nobody";
    $overall_status = 0;

    my $stage = Msg::new("Installation and Configuration Checks");
    for my $sys (@{$syslistref}) {
        $status = 1;
        $msg_check = Msg::new("Verifying for USER:$user_nobody on $sys->{sys}");
        $stage->display_left($msg_check);
        my $id_ret = $sys->cmd("/usr/bin/id $user_nobody");
        if (EDR::cmdexit() ) {
            $msg = Msg::new("User: $user_nobody does not exist on $sys->{sys}");
            $msg->log;
            $msg = Msg::new("Failed");
            $stage->display_right($msg);
            $msg_check->addError($msg_check->{msg});
            $overall_status=1;
        } else {
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }

    }
    return $overall_status;
}

# 5. /etc/llttab and /etc/llthosts are read by Oracle user
# 6. Check if number of nodes configured under SFRAC and those under RAC are same

sub check_oracle_perm {

    #(5) /etc/llttab and /etc/llthosts are read by Oracle user
    my ($prod, $sys, $syslistref, $orauserperm, $item, $desc, $msg);
    my ($ora_user, $oracle_arr, $tmpstr, );
    my ($overall_status, $status, %check_status);
    my $msg_check;

    $prod = shift;
    $sys= shift;
    $syslistref = shift;
    $orauserperm = 0;

    my $vcs = $prod->prod('VCS60');
    $ora_user = $prod->{orauser};
    my $stage = Msg::new("Installation and Configuration Checks");
    if ($ora_user eq '') {
        $msg = Msg::new("No Oracle user detected. Skipping check for oracle user permission for $vcs->{llthosts} and $vcs->{llttab} files.");
        $msg->log;
        $overall_status=1;
    }

    $item = 'LLT configuration - Oracle user permissions check';
    $desc = "Permission check for oracle user for $vcs->{llthosts} file";

    for my $sys (@{$syslistref}) {
        $status = 1;
        $msg_check = Msg::new("Checking permissions for ORACLE_USER:$ora_user on $sys->{sys}");
        $stage->display_left($msg_check);

        if ($overall_status) {
            $check_status{$sys} = 'No Oracle user found';
            $summary = 'No Oracle user found. Skipping the check';
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            goto SKIP_CHECK;
        }


        if ( !$sys->exists($vcs->{llthosts}) ) {
            $msg = Msg::new("$vcs->{llthosts} is not available on $sys->{sys}. Skipping this check.");
            $msg->log;
            $check_status{$sys} = 'File to be checked is missing.';
            $summary = 'Atleast one of the files to be checked is not found.';
            $msg = Msg::new("Skipped");
            $stage->display_right($msg);
            goto SKIP_CHECK;
        }

        $tmpstr = "_cmd_su $ora_user -c \'_cmd_cat $vcs->{llthosts}\'";
        $cmd_ret = $sys->cmd($tmpstr);

        if (EDR::cmdexit()){
            if (($cmd_ret =~ /Permission/m) || ($cmd_ret =~ /annot open/m)) {
                $orauserperm = 0;
                $msg = Msg::new("Permission denied for ORACLE_USER:$ora_user for files $vcs->{llthosts} on $sys->{sys}");
                $msg->log;
                $check_status{$sys} = "Oracle user: $ora_user does not have permission to access $vcs->{llthosts}";
                $summary = "Oracle user: $ora_user does not have permission to access $vcs->{llthosts}";
                $status = 0;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
            } else {
                $msg = Msg::new("Cannot access file $vcs->{llthosts} on $sys->{sys} for unknown reason");
                $msg->log;
                $msg = Msg::new("Failed");
                $stage->display_right($msg);
                $msg_check->addError($msg_check->{msg});
            }
        } else {
            $orauserperm = 1;
            $check_status{$sys} = "Oracle user: $ora_user has permission to access $vcs->{llthosts}";
            $summary = "Oracle user: $ora_user has permission to access $vcs->{llthosts}";
            $msg = Msg::new("Passed");
            $stage->display_right($msg);
        }

SKIP_CHECK:

        # Record the result.
        $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%check_status);
        if ($ret) {
            $msg = Msg::new("Problem encountered in recording the result for '$item'");
            $msg->log;
        }
    }

    $prod->{oraperm} = $orauserperm;
    return $overall_status;

}


sub check_nodes_clus {

    # (6) Check if number of nodes configured under SFRAC and those under RAC are same
    # We will not fail the "LLT and private network checks" because of failure in the check below

    # Getting some Oracle installation specific info from PrepU framework
    # Repeating this part of the code to keep it independent from check (5) above
    #

    my ($prod, $sys, $msg, $localsys, $orauserperm, $tmpstr, $cmd_ret);
    my ($overall_status, $llthosts_file_present, $llttab_file_present);
    my ($llthosts_bad_flag, $llttab_bad_flag, $status, %check_status);
    my ($ret, $summary, $item, $desc, $crs_home);
    my $msg_check;

    $prod = shift;
    $sys = shift;
    $crs_home = shift;

    $orauserperm = $prod->{oraperm};
    $localsys = $prod->localsysname;
    my $vcs = $prod->prod('VCS60');
    my $stage = Msg::new("Installation and Configuration Checks");
    $msg_check = Msg::new("Checking equivalence of $prod->{abbr} cluster and RAC instances from $localsys");
    $stage->display_left($msg_check);
    if ($prod->{orauser}  eq '') {
        $msg = Msg::new("No Oracle user detected. Skipping checking if number of nodes configured under $prod->{abbr} and those under RAC are same.");
        $msg->log;
        # $overall_status=1;
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        goto SKIP_CHECK;
    }

    $item = "LLT configuration - Equivalence of $prod->{abbr} cluster and RAC instances check";
    $desc = "Check to assert that the nodes running RAC insatances are all the members of $prod->{abbr} cluster";

    if ( !$sys->exists($vcs->{llthosts}) || !$sys->exists($vcs->{llttab}) ) {
        $msg = Msg::new("Either $vcs->{llthosts} or $vcs->{llttab} or both are not available on $sys->{sys}. Skipping this check.");
        $msg->log;
        $check_status{$sys} = 'File to be checked is missing.';
        $summary = 'Atleast one of the files to be checked is not found.';
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        goto SKIP_CHECK;
    }

    if (!$orauserperm) {
        $msg = Msg::new("Oracle user: $prod->{orauser} does not have permission to access $vcs->{llthosts} and $vcs->{llttab}");
        $check_status{$sys} = "Oracle user: $prod->{orauser} does not have permission to access $vcs->{llthosts} and $vcs->{llttab}";
        $summary = 'Access denied for required files.';
        $msg->log;
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        goto SKIP_CHECK;
    }

    $status = 1;

    $tmpstr = "_cmd_su $prod->{orauser} -c \'_cmd_cat $vcs->{llthosts} 2>/dev/null\' 2>/dev/null";
    $cmd_ret = EDR::cmd_local($tmpstr);
    # Removing leading and trailing newlines
    $cmd_ret =~ s/\n+$//g;
    $cmd_ret =~ s/^\n+//g;

    my @clusnodes_llthosts = split(/\n/, $cmd_ret);

    $tmpstr = "_cmd_su $prod->{orauser} -c '$prod->{crs_home}/bin/olsnodes 2>/dev/null' 2>/dev/null";
    $cmd_ret = EDR::cmd_local($tmpstr);
        if (EDR::cmdexit()) {
        $msg = Msg::new("Oracle user $prod->{orauser} has problems in running 'olsnodes' utility");
        $msg->log;
        $check_status{$sys} = "Oracle user $prod->{orauser} has problems in running 'olsnodes' utility.";
        $summary = 'Cannot run olsnodes utility.';
        $msg = Msg::new("Skipped");
        $stage->display_right($msg);
        goto SKIP_CHECK;
    }
    # Removing leading and trailing newlines
    $cmd_ret =~ s/\n+$//g;
    $cmd_ret =~ s/^\n+//g;

    my @clusnodes_olsnodes = split(/\n/, $cmd_ret);

    # Assuming that 'olsnodes' is a subset of 'llthosts'
    for my $olsnode (@clusnodes_olsnodes) {
        my $index = 0;
        for my $lltnode (@clusnodes_llthosts) {
            if ($lltnode =~ /$olsnode/m) {
                delete $clusnodes_llthosts[$index];
                last;
            }
            $index++;
        }
    }

    if (!@clusnodes_llthosts) {
        $msg = Msg::new("$prod->{abbr} membership and Oracle Clusterware/Grid Infrastructure membership are equal");
        $msg->log;
        $check_status{$sys} = "$prod->{abbr} membership and Oracle Clusterware/Grid Infrastructure membership are equal";
        $summary = "$prod->{abbr} membership and Oracle Clusterware/Grid Infrastructure membership are equal";
        $msg = Msg::new("Passed");
        $stage->display_right($msg);
    } else {
        $msg = Msg::new("$prod->{abbr} membership and Oracle Clusterware/Grid Infrastructure membership are not equal. The following nodes are not part of the RAC.");
        $msg->log;
        for my $node (@clusnodes_llthosts) {
            $msg = Msg::new($node);
            $msg->log;
        }
        $check_status{$sys} = "$prod->{abbr} membership and Oracle Clusterware/Grid Infrastructure membership are not equal. Some nodes are not part of the RAC.";
        $summary = "$prod->{abbr} membership and Oracle Clusterware/Grid Infrastructure membership are not equal. Some nodes are not part of the RAC.";
        $status = 0;
        $msg = Msg::new("Failed");
        $stage->display_right($msg);
        $msg_check->addError($msg_check->{msg});

    }

SKIP_CHECK:

    # Record the result.
    $ret = $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%check_status);
    if ($ret) {
        $msg = Msg::new("Problem encountered in recording the result for '$item'");
        $msg->log;
    }

    return 0;
}




sub prepu_record_result {
    my ($prod, $sys, $item, $desc, $status, $summary, $dataref) = @_;
    return 1 if ($sys eq '' or $item eq '' or $status eq '' or $summary eq '' or $desc eq '');
    if (defined $dataref) {
        return 1 if (ref($dataref) !~ /HASH/m and ref($dataref) !~ /ARRAY/m);
        my @data = ref($dataref) =~ /HASH/m ? values(%{$dataref}) : @{$dataref};
        for my $data (@data) {
            return 1 if(ref(\$data) !~ /SCALAR/m);
        }
    }
    my %rcd = ( ITEM => "$item",
                DESC => "$desc",
                STATUS => "$status",
                SUMMARY => "$summary"
                );
    if (defined $dataref) {
        $rcd{RETTYPE} = ref($dataref);
        $rcd{RETDATA} = $dataref;
    }
    push(@{$prod->{results}{$sys}}, \%rcd);
    return 0;
}

sub get_supported_tunables {
    my ($prod) =@_;
    my ($tunables,$sfcfsha);
    $tunables = [];
    push @$tunables, @{$prod->get_tunables};
    $sfcfsha=$prod->prod('SFCFSHA60');
    push @$tunables, @{$sfcfsha->get_supported_tunables};
    return $tunables;
}

package Prod::SFRAC60::HPUX;
@Prod::SFRAC60::HPUX::ISA = qw(Prod::SFRAC60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1)];
    $prod->{zru_releases}=[qw()];

    # no need to check cpu speed for HPUX
    $prod->{minimal_cpu_speed_requirment} = undef;

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSdbckp VRTSormap VRTScsocw VRTSdbac60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi VRTSd2doc VRTSordoc
        VRTSfsnbl VRTSfppm VRTSap VRTStep VRTSspc VRTSspcq
        VRTSfasdc VRTSfasag VRTSfas VRTSgapms VRTSmapro VRTSvail
        VRTSd2gui VRTSorgui VRTSvxmsa VRTSvrdev VRTSdbdoc VRTSdb2ed VRTSdbed60
        VRTSdbcom VRTSsydoc VRTSsybed VRTSvcsApache VRTScmc
        VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy
        VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScssim
        VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsag60
        VRTScps60 VRTSvcs60 VRTSvxfen60 VRTSgab60 VRTSllt60
        VRTSfsmnd VRTSfssdk60 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSvrmcsg VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid
        VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxvm60
        VRTSjre15 VRTSjre VRTSperl512 VRTSvlic32 VRTSwl
    ) ];

    my $padv=$prod->padv();

    $padv->{cmd}{vxdctl}='/usr/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{mkfs}='/usr/sbin/mkfs';
    $padv->{cmd}{format}='/usr/sbin/format';
    $padv->{cmd}{psrinfo} = '/usr/sbin/psrinfo';
    $padv->{cmd}{prctl} = '/usr/bin/prctl';
    $padv->{cmd}{prtconf} = '/usr/sbin/prtconf';
    $padv->{cmd}{sysdef} = '/usr/sbin/sysdef';

    # Setting SF Oracle RAC/PADV specific variables here
    $prod->{lib_path} = '/opt/VRTSvcs/rac/lib/';
    $prod->{bin_path} = '/opt/VRTSvcs/rac/bin/';
    $prod->{initdir} = '/etc/init.d/';
    $prod->{ipc_utility} = '/opt/VRTSvcs/ops/bin/ipc_version_chk_shared';
    $prod->{hosts_file} = '/etc/hosts';
    $prod->{mount_points} = "/usr/sbin/mount | awk '{print \$1}'";
    $prod->{initdir} = '/sbin/init.d';
    $prod->{vendor_skgxn_path} = '/opt/nmapi/nmapi2/[pa20_64|hpux64]/lib';
    $prod->{xdpyinfo_path} = '/usr/contrib/bin/X11/xdpyinfo';
    return;
}


sub determine_group {
    my ($prod, $sys, $user) = @_;
    my ($ret, $stat);
    $stat = 0;

    $ret = $sys->cmd("_cmd_groups $user");
    chomp($ret);
    ($prod->{oracle_group}, $prod->{oracle_sgroups}) = split(/\s+/m, $ret, 2);
    chomp($prod->{oracle_sgroups});
    $stat = $stat || EDR::cmdexit();

    $ret = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$prod->{oracle_group}:'");
    chomp($ret);
    $prod->{oracle_gid} = (split(/:/m, $ret, 4))[2];
    $stat = $stat || EDR::cmdexit();

    return $stat;
}

sub addnode_get_group {
    my ($prod, $sys, $user) = @_;
    my ($groups, $grp);

    $groups = $sys->cmd("_cmd_groups $user");
    chomp($groups);
    $grp = (split(/\s+/m, $groups))[0];

    return $grp;
}

sub create_oragrp {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupadd -g $ogid $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem adding Oracle group $og on $sys->{sys}");
        $msg->print;
        return 1;
    }
    $msg = Msg::new("Added Oracle group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub delete_group {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupdel $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem deleting group $og on $sys->{sys}");
        $msg->log;
        return 1;
    }
    $msg = Msg::new("Deleted group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub create_ora_user_group {
    my ($prod, $sys, $ou, $og, $oh, $ouid, $ogid, $oshell, $user_exists, $group_exists, $orahome_exists) = @_;
    my $msg;
    my $basedir;
    my $ret = 0;

    goto SKIP_GROUP if($group_exists);
    return 1 if ($prod->create_oragrp($sys, $ogid, $og) == 1);

SKIP_GROUP:
    goto SKIP_CREATION if ($user_exists);
    if (!$sys->is_dir("$oh")) {
        $basedir = $sys->cmd("dirname $oh");
        $sys->cmd("mkdir -p $basedir");
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
    } else {
        $sys->cmd("_cmd_useradd -d $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
        $sys->cmd("chown $ou:$og $oh");
        $sys->cmd("_cmd_chmod 755 $oh");
    }

SKIP_CREATION:
    $msg = Msg::new("Added Oracle user $ou with UID $ouid on $sys->{sys}");
    $msg->log;

    return 0;
}

# Modifies group information for a user
# Adding the given group for Oracle user
sub modify_group_info {
    my ($prod, $sys, $user, $group, $groupid) = @_;
    my (@old_group_names, $ret, $grp, $allgrps);

    $ret = $sys->cmd("_cmd_groups $user");
    return 1 if (EDR::cmdexit());
    chomp($ret);
    @old_group_names = split(/\s+/m, $ret);
    $allgrps = $group;
    for my $grp (@old_group_names) {
        $allgrps = $allgrps.','.$grp if ($grp ne '');
    }

    $sys->cmd("_cmd_usermod -G $allgrps $user");
    return 1 if (EDR::cmdexit());

    return 0;
}

sub get_plumbed_ips {
    my ($prod, $nodes_ref) = @_;
    my ($sys, $output, $msg,$tmpdir);

    $tmpdir=EDR::tmpdir();
    EDR::cmd_local("_cmd_rm $tmpdir/plumbed_ips.txt");
    for my $sys (@{$nodes_ref}) {
        $output = $sys->cmd("netstat -in | _cmd_grep -v Address | _cmd_grep -v none | _cmd_awk \'{print \$4}\'");
        EDR::cmd_local("echo \'$output\' >> $tmpdir/plumbed_ips.txt");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Failed to save plumbed ips in $tmpdir/plumbed_ips.txt");
            $msg->print;
            Msg::prtc();
            return 1;
        }
    }

    return 0;
}

sub set_install_env {
    my ($prod, $release, $patch_level, $instpath) = @_;
    my ($sys, $msg);
    my $tmpdir=EDR::tmpdir();
    my $bs=EDR::get2('tput','bs');
    my $be=EDR::get2('tput','be');
    $prod->{oui_args} = '';
    $prod->{oui_export} = '';

    # If SKIP_ROOTPRE is not set, invoke the rootpre.sh script.
    if ((($release eq '10.2') && ($patch_level eq '0.1'))) {
        if ($ENV{'SKIP_ROOTPRE'} eq 'TRUE') {
            $msg = Msg::new("SKIP_ROOTPRE environment variable is set. Will not invoke Oracle rootpre.sh script.");
            $msg->print;
        } else {
            my $is_failed = 0;
            for my $sys (@{CPIC::get('systems')}) {
                $msg = Msg::new("Invoking Oracle rootpre.sh on $sys->{sys}");
                $msg->left;
                $prod->localsys->copy_to_sys($sys,"$instpath/rootpre","$tmpdir/rootpre");
                $sys->cmd("cd $tmpdir/rootpre; ./rootpre.sh");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    $is_failed = 1;
                } else {
                    Msg::right_done();
                }
            }

            if ($is_failed == 1) {
                my $rootpre_loc;
                $rootpre_loc = "$instpath/rootpre";

                $msg = Msg::new("The execution of rootpre.sh script failed on one or more systems. For installation to proceed, Oracle requires you to run the rootpre.sh script located under ${rootpre_loc}. Run it manually on these systems as root user.");
                $msg->print;
                return 0 if (Cfg::opt('responsefile'));
                $msg = Msg::new("Press <RETURN> after running rootpre.sh:");
                print "\n$bs$msg->{msg}$be ";
                <STDIN>;
            }
        }

        $prod->{oui_export} = 'SKIP_ROOTPRE=TRUE;export SKIP_ROOTPRE;';
    }

    return 0;
}

sub set_crs_install_env {
    my $prod = shift;
    my $ret;
    my $msg;

    my $padv=$prod->padv();
    if ($padv->{arch} eq 'i86pc') {
        $msg = Msg::new("Architecture is x84. Running 'rootpre.sh'");
        $msg->log;
            $ret = $prod->set_install_env($prod->{crs_release}, $prod->{crs_patch_level}, $prod->{crs_installpath});
    } else {
        $msg = Msg::new("Architecture is probably 'sparc'. Need not run 'rootpre.sh'");
        $msg->log;
        $ret = 0;
    }

    return $ret;
}

sub get_skgxn_lib {
    my ($prod, $crshome, $db_release) = @_;

    my $sys = ${CPIC::get('systems')}[0];
    $mach_hardware = $sys->cmd('_cmd_uname -m 2>/dev/null');
    if ($mach_hardware eq 'ia64') {
        $so_ext = 'so';
    } else {
        $so_ext = 'sl';
    }
    my $skgxn_name = "libskgxn2.$so_ext";

    return $skgxn_name;
}

sub relink_oracle {
    my $prod = shift;
    my $msg;
    my $tmpdir = EDR::tmpdir();
    my $localsys = $prod->localsys;
    my $orauser = $prod->{oracle_user};
    my $oragrp = $prod->{oracle_group};
    my $cfsmnt = $prod->is_cfsmount($prod->{db_home});

    my $release = '';
    if ($prod->{db_release} eq '10.2') {
        $release = '10gR2';
    } elsif ($prod->{db_release} eq '11.1') {
        $release = '11gR1';
    } elsif ($prod->{db_release} eq '11.2') {
        $release = '11gR2';
    }

    my @cpnodes = ($cfsmnt) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    my $system;
    for my $system (@cpnodes) {
        $msg = Msg::new("Relinking Oracle Database software on $system->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        my $timestamp = `date +%m%d%y_%H%M%S`;
        my $logfile = "$tmpdir/install.linkrac.$system->{sys}.log.$timestamp";
        my $tmplogfile = "/tmp/linkrac.$system->{sys}";
            $system->cmd("_cmd_touch $tmplogfile");
            $system->cmd("_cmd_chown $prod->{oracle_user}:$prod->{oracle_group} $tmplogfile");
        my $run_cmd = '';
        $run_cmd = $run_cmd."ORACLE_HOME=$prod->{db_home};export ORACLE_HOME;";
        $run_cmd = $run_cmd."/opt/VRTSvcs/rac/bin/linkrac $release > $tmplogfile 2>&1";
        chdir('/tmp');
        my $ret = $system->cmd("_cmd_su $prod->{oracle_user} -c '$run_cmd'");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            next;
        } else {
            $ret = $system->cmd("_cmd_egrep -i '(error|usage)' $tmplogfile");
            if (!EDR::cmdexit() && $ret ne '') {
                Msg::right_failed();
                $system->copy_to_sys($cpic->localsys,$tmplogfile,$logfile);
                next;
            }
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
            $system->copy_to_sys($prod->localsys,$tmplogfile,$logfile);
        }
        $system->cmd("_cmd_rm $tmplogfile");
    }

    return 0;
}


sub getipclib {
    my $ipclib;
    my $ipc_version;
    my $prod = shift;
    my ($oravers, $orabits) = @_;

    $ipc_version = '25'; # Hard coding it as Oakmont has only Oracle 10GR2 and onwards
    $ipclib='libskgxp10_ver' . $ipc_version . '_' . $orabits . '.so';

    return $ipclib;
}

sub link_libskgxn {
    my ($prod, $skgxn_name, $crs_home) = @_;
    my ($sys, @cpnodes, $msg, $cmd);
    $sys = ${CPIC::get('systems')}[0];
    $mach_hardware = $sys->cmd('_cmd_uname -m 2>/dev/null');
    if ($mach_hardware eq 'ia64') {
        $so_ext = 'so';
        $nmapidir_64 = '/opt/nmapi/nmapi2/lib/hpux64';
    } else {
        $so_ext = 'sl';
        $nmapidir_64 = '/opt/nmapi/nmapi2/lib/pa20_64';
    }
    my $crsup = $prod->is_crs_up(CPIC::get('systems'));
    if ($crsup) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure should be linked with Veritas Membership library. To link Oracle Clusterware/Grid Infrastructure, the Oracle Clusterware/Grid Infrastructure will be stopped.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        my $ayn = $msg->ayny;
        if ($ayn eq 'n' || $ayn eq 'N') {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s $nmapidir_64/$skgxn_name $prod->{crs_home}/lib/libskgxn2.$so_ext \n 3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        $cmd = "$crs_home/bin/crsctl stop crs";
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Stopping Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            } else {
                Msg::right_done();
            }
        }
        if (($failed_systems != 0) || ($prod->is_crs_up(CPIC::get('systems')))) {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s $nmapidir_64/$skgxn_name $prod->{crs_home}/lib/libskgxn2.$so_ext \n 3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
    }
    $prod->link_vcsmm_lib($crs_home);
    $cmd = "$crs_home/bin/crsctl start crs";
    if ($crsup) {
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Starting Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            }
            my $count = 0;
            my $crsup = 0;
            while ($count < 40) {
                $sys->cmd("$prod->{crs_home}/bin/crs_stat -t 2> /dev/null");
                if (!EDR::cmdexit()) {
                    $crsup = 1;
                    last;
                }
                sleep(3);
                $count++;
            }
            if ($crsup) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $failed_systems++;
            }
        }
        if ($failed_systems != 0) {
            $msg = Msg::new("Start Oracle Clusterware/Grid Infrastructure on failed systems:\n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 0;
        }
    }

    return 0;
}

# Link the Veritas Membership library
# 'sub do_skgxn' in CPI
sub link_vcsmm_lib {
    my $prod = shift;
    my $crs_home = shift;
    my ($msg, $sys);
    my $orabits = $prod->{oracle_bits};

    $sys = ${CPIC::get('systems')}[0];
    $mach_hardware = $sys->cmd('_cmd_uname -m 2>/dev/null');
    if ($mach_hardware eq 'ia64') {
        $so_ext = 'so';
        $nmapidir_64 = '/opt/nmapi/nmapi2/lib/hpux64';
    } else {
        $so_ext = 'sl';
        $nmapidir_64 = '/opt/nmapi/nmapi2/lib/pa20_64';
    }

    my $vrtsgxn = $prod->{lib_path} . "libskgxn2_${orabits}.$so_ext";
    my $orclgxn = "$nmapidir_64/libskgxn2.$so_ext";
    my $crsgxn = "$crs_home/lib/libskgxn2.$so_ext";


    for my $sys (@{CPIC::get('systems')}) {
        $msg = Msg::new("Linking Oracle skgxn library on $sys->{sys}");
        $msg->left;

        my $timestamp = `date +%m%d%y_%H%M%S`;
        $sys->cmd("_cmd_mv $crsgxn $crsgxn-$timestamp");
        $sys->cmd("_cmd_ln -s $orclgxn $crsgxn 2>/dev/null");
        if (EDR::cmdexit()) {
            Msg::right_failed();
        } else {
            Msg::right_done();
        }
    }
    return;
}

# Check the labeling status of the given disks
# If not labeled already then label them
# Run 'vxdisk scandisks' in the end
#
# Return 1 if cannot label disk(s)
# Return 0 if everything went fine
sub check_disk_labeling {
    my ($prod, @disks) = @_;
    my ($sys, $disk, $msg, $status);
    $tmpdir=EDR::tmpdir();
    my $auxformat = "$tmpdir/label_while_formattig";

    open AUXFORMAT, '+>', $auxformat or return 1;
    print AUXFORMAT 'label';
    close AUXFORMAT;

    $status = 0;
    for my $disk (@disks) {
        my ($handle, $label, $temp);
        ($handle, $temp, $temp, $temp, $label) = split(/\s+/m, $disk, 5);
        if ($label eq 'nolabel' || $label eq 'error') {
            $handle =~ s/s\d$//mg if ($handle =~ /s\d$/m);
            for my $sys (@{CPIC::get('systems')}) {
                $sys->cmd("_cmd_format -d $handle -f $auxformat");
                if (EDR::cmdexit()) {
                    $msg = Msg::new("Formatting and labeling of disk $handle failed on $sys");
                    $msg->log;
                    $status = 1;
                    next;
                }
                $sys->cmd('_cmd_vxdisk scandisks');
            }
        }
    }
    return $status;
}

# Make and mount CFS
# Return[0] == 0 if everything went fine
sub make_mount_cfs {
    my ($prod, $dgname, $volname, $cfsmntpt, $master) = @_;
    my ($mk, $mkret, %mnt, %mntret);
    my ($sys, $ret);
    my $vxloc = '/dev/vx';

    $ret = 0;

    $mk = $master->cmd("_cmd_mkfs -F vxfs -o largefiles ${vxloc}/rdsk/${dgname}/${volname}");
    $mkret = EDR::cmdexit();

    for my $sys (@{CPIC::get('systems')}) {
        $mnt{$sys} = $sys->cmd("_cmd_mount -F vxfs -o cluster,largefiles,mntlock=VCS $vxloc/dsk/${dgname}/${volname} $cfsmntpt");
        $mntret{$sys} = EDR::cmdexit();
        $ret = $ret || $mntret{$sys};
    }

    $ret = $ret || $mkret;
    return ($ret, $mk, $mkret, %mnt, %mntret);
 }


##################################################################################################
#                                                 #
#                       Platform specific prepu checks routines.                                 #
#                                                 #
##################################################################################################


# Code for prepu prod-specific checking
sub plat_prepu_sfrac_defines {
    my $prod = shift;
    $prod->{vcsmmconfig} = '/etc/rc.config.d/vcsmmconf';    # Config file. Not a command.

    my $padv = $prod->padv();
    $padv->{cmd}{kctune} = '/usr/sbin/kctune';
    $padv->{cmd}{ldd} = '/usr/ccs/bin/ldd';
    $padv->{cmd}{nm} = '/usr/bin/nm';
    $padv->{cmd}{diff} = '/usr/bin/diff';
    $padv->{cmd}{strings} = '/usr/bin/strings';
    $padv->{cmd}{adb} = '/usr/bin/adb';
    $padv->{cmd}{lltstat} = '/sbin/lltstat';
    $padv->{cmd}{file} = '/usr/bin/file';

    $prod->{cmd}{vxfenadm} = '/sbin/vxfenadm';
    $prod->{cmd}{gabconfig} = '/sbin/gabconfig';

    return;
}

# Check if DBAC package is present or not.
sub is_dbac_present {
    my ($prod, $ret, $sys);
    $prod = shift;
    $sys = shift;

    $ret = $sys->cmd('_cmd_swlist -l product 2>/dev/null | _cmd_grep dbac');
    if ($ret eq '') {
        return 0;
    } else {
        return 1;
    }
}


sub get_oslevel_sys {
    my ($prod, $sys, $msg, $os_ref, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking
    $errstr = '';

    $msg = Msg::new("get os level of sfrac");
    $msg->log;

    eval {$os_ref = $sys->cmd('_cmd_uname  -r ');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get os version and patch level error info :$errstr");
        $msg->log;
        return 1;
    }

    return $os_ref;
}


# Platform specific code for checking the system architecture
sub get_archtype_sys {
    my ($prod, $sys, $archtype, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking
    $errstr = '';

    $msg = Msg::new("get architecture type");
    $msg->log;

    eval {$archtype = $sys->cmd('_cmd_uname  -m');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get architeture type, error info :$errstr");
        $msg->log;
        return '';
    }

    return $archtype;
}



# Platform specific code for checking processor speed.
sub get_cpuspeed_sys {
    my ($prod, $sys, $msg, $cpuinfo, @cpuspeed, $cpucnt);
    my ($arch, $osref, $errstr);

    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get processor speed");
    $msg = $msg->log;


    eval {$arch = $sys->cmd('_cmd_uname  -m');};
    $msg = Msg::new("Architecture type: $arch");
    $msg->log;

    if ($arch =~ /ia64/m) {
        eval {$osref = $sys->cmd('_cmd_uname  -r');};
        if ($osref =~ /11.31/m) {
            # For IA 11.31 systems:
            # machinfo | grep "GHz"
            #     4 Intel(R) Itanium 2 processors (1.3 GHz, 3 MB)

            eval {$cpuinfo = $sys->cmd('_cmd_machinfo | _cmd_grep GHz');};
            $errstr = $@;
            if ($errstr) {
                $msg = Msg::new("Can't get the processor information, error info :$errstr");
                $msg->log;
                return '';
            }

            if ( $cpuinfo =~ "[\ ]+([0-9]+)[\ ]+.+[\(]+([0-9\.]+)[\ ]+GHz.+[\)]" ) {
                $cpucnt = $1;
                $cpuspeed = $2*1000;    #Convert to MHz
            }

            $cpuinfo = $cpuspeed;
            for(my $ii=1; $ii<$cpucnt; $ii++) {
                $cpuinfo = "$cpuinfo $cpuspeed";
            }
            return $cpuinfo;
        } else {
            # For IA 11.23 (or less) systems:
            # $machinfo | grep "Number of CPUs"
            #     Number of CPUs = 2
            # $machinfo | grep "Clock speed"
            #     Clock speed = 1300 MHz

            eval {$cpuinfo = $sys->cmd("_cmd_machinfo | _cmd_grep 'Number of CPUs'");};
            $errstr = $@;
            if ($errstr) {
                $msg = Msg::new("Can't get the processor information, error info :$errstr");
                $msg->log;
                return '';
            }
            if($cpuinfo =~ ".+[\ ]+([0-9]+)") {
                $cpucnt = $1;
            }

            eval {$cpuinfo = $sys->cmd("_cmd_machinfo | _cmd_grep 'Clock speed'");};
            $errstr = $@;
            if ($errstr) {
                $msg = Msg::new("Can't get the processor information, error info :$errstr");
                $msg->log;
                return '';
            }
            if($cpuinfo =~ "[\ ]+([0-9]+)[\ ]+MHz") {
                $cpuspeed = $1;
            }

            $cpuinfo = $cpuspeed;
            for(my $ii=1; $ii<$cpucnt; $ii++) {
                $cpuinfo = "$cpuinfo $cpuspeed";
            }
            return $cpuinfo;
        }
    } elsif ($arch =~ 9000) {
        # For PA machines:
        # $ ioscan -fnkC processor | grep Processor | wc -l
        #    4
        # $echo itick_per_usec/D | adb /stand/vmunix /dev/kmem | tail -1
        #    itick_per_usec: 799
        #

        eval {$cpuinfo = $sys->cmd("_cmd_ioscan -fnkC processor | _cmd_grep 'Processor' | _cmd_wc -l");};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Can't get the processor information, error info :$errstr");
            $msg->log;
            return '';
        }

        if($cpuinfo =~ '.*([0-9]+).*') {
            $cpucnt = $1;
        }

        eval {$cpuinfo = $sys->cmd("echo 'itick_per_usec/D' | _cmd_adb /stand/vmunix /dev/kmem ");};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Can't get the processor information, error info :$errstr");
            $msg->log;
            return '';
        }

        if($cpuinfo =~ ".*:[\ ]+([0-9]+)") {
            $cpuspeed = $1;
        }
        $cpuinfo = $cpuspeed;
        for(my $ii=1; $ii<$cpucnt; $ii++) {
            $cpuinfo = "$cpuinfo $cpuspeed";
        }
        return $cpuinfo;
    }
}


# Platform specific Code for checking if init.cssd
# file has been patched properly
sub check_initcssd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status);
    my ($mach_hardware, $so_ext, $nmapidir_64);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Checking for whether some vendor clusterware is present (non-Oracle)
    eval {$mach_hardware = $sys->cmd('_cmd_uname  -m');};
    if ($mach_hardware eq 'ia64') {
        $so_ext = 'so';
        $nmapidir_64 = '/opt/nmapi/nmapi2/lib/hpux64';
    } else {
        $so_ext = 'sl';
        $nmapidir_64 = '/opt/nmapi/nmapi2/lib/pa20_64';
    }

    if(!$sys->exists("$nmapidir_64/libnmapi2.$so_ext")) {
        $status = 1;
    }

    # Check if Veritas Clusterware
    if (!$sys->exists('/opt/nmapi/nmapi2/bin/clsinfo')) {
        $status = 1;
    }

    return $status;
}

# Platform specific code for checking if 'oprocd' is running
sub check_oprocd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status, $oprocd);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Check if for this $oraversion this check doesn't apply
    # (Applies only for version >= 10.2.0.4)
    # In that case return $status as 0
    if ($oraversion =~ /^9/m ||
        $oraversion =~ /10.1/m ||
        $oraversion =~ /10.2.0.1/m ||
        $oraversion =~ /10.2.0.2/m ||
        $oraversion =~ /10.2.0.3/m) { # !(Oracle 10.2.0.4 or 11g)
        return $status;
    }

    # If 'oprocd' check applies for the given $oraversion,
    # then check using 'ps' utility
    $oprocd = $sys->cmd("_cmd_ps -ef | _cmd_grep 'oprocd' | _cmd_awk '{print \$4}'");
    chomp($oprocd);
    if ($oprocd eq 'oprocd' || $oprocd eq 'oprocd.bin' || $oprocd eq './oprocd.bin start') {
        $status = 1;
    }

    return $status;
}


# For Some LLT link related checks, the interfaces meed to be plumbed.
# This routine plumbs them if they are not plumbed.
# [TBD] The devces are not umplumbed after the checks. Needs to be handled later.

sub plat_plumbdev_sys {
    my ($prod, $syslistref, @link, $sys, $res);

    $prod = shift;
    $prod = shift;
    $syslistref = shift;
    $res = 0;

    for my $sys (@{$syslistref}) {
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}' ");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}' ");

            $sys->cmd("_cmd_ifconfig '$link[0]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[0] is invalid or not plumbed. Trying to plumb");
                $msg->log;
                $sys->cmd("_cmd_ifconfig '$link[0]' plumb 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg = Msg::new(" Problem in plumbing LLT interface $link[0]");
                    $msg->log;
                    $res = 1;
                } else {
                    $msg = Msg::new("Interface $link[0] is plumbed successfully");
                    $msg->log;
                }
            }

            $sys->cmd("_cmd_ifconfig '$link[1]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[1] is invalid or not plumbed. Trying to plumb");
                $msg->log;
                $sys->cmd("_cmd_ifconfig '$link[1]' plumb 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg = Msg::new(" Problem in plumbing LLT interface $link[1]");
                    $msg->log;
                    $res = 1;
                } else {
                    $msg = Msg::new("Interface $link[1] is plumbed successfully");
                    $msg->log;
                }
            }

        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            $res = 1;
        }
    }
    return $res;
}


# Platform specific Code for checking if Oracle's
# libraries are linked properly with Symantec libraries.
# Current implementation assumes that all the cluster nodes
# are running the same OS on same ARCH.
sub check_liblink_sys {
    my ($prod, $sys, $crshome, $orahome, $oraversion, $status);
    my ($arch, $lib_dir64, $msg);
    my ($lib_skgxp, $lib_odm);
    my ($vcsipc_lib, $cmd_ret, $odm_lib, $oracle_num);

    $prod = shift;
    $sys = shift;
    $crshome = shift;
    $orahome = shift;
    $oraversion = shift;

    if (($oraversion =~ /11.1/m) ||
        ($oraversion =~ /11.2/m)) { # Keep adding 11.2, 11.3 here as they get realesed
        $oracle_num = '11';
    }

    $status = 0;
    $arch = $sys->cmd('_cmd_uname -m');

    $msg = Msg::new("check_liblink_sys called with -> crshome:$crshome, orahome:$orahome, oracle_version:$oraversion, TARGETARCH: $arch");
    $msg->log;

    if ($arch =~ 9000) {
        $lib_dir64 = pa20_64;
    } elsif ($arch =~ /ia64/m) {
        $lib_dir64 = hpux64;
    }

    $lib_skgxp='libskgxp';
    $lib_odm='libodm';

    # IPC library check.
    $vcsipc_lib = $sys->cmd("_cmd_ldd $orahome/bin/oracle | _cmd_grep $lib_skgxp | _cmd_awk '{print \$3}'");

    if ($oracle_num eq '11') {
        $msg = Msg::new("Skipping the IPC library check for Oracle version 11 on $sys->{sys}");
        $msg->log;
        goto SKIP_IPC;
    }

    if ($vcsipc_lib eq '') {
        $cmd_ret = $sys->cmd("_cmd_nm $orahome/bin/oracle | _cmd_grep vcsipc_poll");
        if ($cmd_ret eq '') {
            $status = 1;
            $msg = Msg::new("IPC library linking check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status = 0;
            $msg = Msg::new("IPC library linking check on $sys->{sys} is OK");
            $msg->log;
        }
    } else {
        $cmd_ret = $sys->cmd("_cmd_nm $vcsipc_lib | _cmd_grep vcsipc_poll");
        if ($cmd_ret eq '') {
            $status = 1;
            $msg = Msg::new("IPC library linking check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status = 0;
            $msg = Msg::new("IPC library linking check on $sys->{sys} is OK");
            $msg->log;
        }
    }
SKIP_IPC:
    # VCSMM library check.
    $cmd_ret = $sys->cmd("_cmd_ldd $orahome/bin/oracle | _cmd_grep '\/usr\/lib\/$lib_dir64\/libvcsmm.1'");
    if ($cmd_ret eq '') {
        $status = 1;
        $msg = Msg::new("VCSMM library check on $sys->{sys} has failed");
        $msg->log;
    } else {
        $status = 0;
        $msg = Msg::new("VCSMM library check on $sys->{sys} is OK");
        $msg->log;
    }

    # OBM library check.
    $odm_lib = $sys->cmd("_cmd_ldd $orahome/bin/oracle | _cmd_grep odm | _cmd_awk '{print \$3}'");
    if ($odm_lib eq '') {
        $status = 1;
        $msg = Msg::new("ODM library check on $sys->{sys} has failed");
        $msg->log;
    } else {
        $cmd_ret = $sys->cmd("_cmd_strings $odm_lib | _cmd_grep -i veritas");
        if ($cmd_ret eq '') {
            $status = 1;
            $msg = Msg::new("ODM library check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status = 0;
            $msg = Msg::new("ODM library check on $sys->{sys} is OK");
            $msg->log;
        }
    }

    return $status;
}

# Check for kernel parameters on HP-UX that are
# required for Oracle RAC
# Return @param_list with the list of kernel parameters
# for which check failed.
sub plat_check_kernelparams_sys {
    my ($sys, $params, $param, $nproc, $param_list, $counter);
    my ($temp, $status, $semmns, $prod);

    $prod = shift;
    $sys = shift;
    $param_list = shift;
    $counter = -1;
    $status = 0;

    $nproc = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep nproc | _cmd_awk '{print \$2}'");
    if ($nproc =~ /now/m) {
        $nproc = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep nproc | _cmd_awk '{print \$3}'");
    }
    $msg = Msg::new("nproc is : $nproc");
    $msg->log;
    if ((0+$nproc) < 4096) {
        $msg = Msg::new("nproc value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "nproc value is $nproc. It should be equat to or more than 4096";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep ksi_alloc_max | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep ksi_alloc_max | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < ((0+$nproc) * 8)) {
        $msg = Msg::new("ksi_alloc_max value is not as per the requirement ($param:($nproc * 8))");
        $msg->log;
        $param_list->[++$counter] = "ksi_alloc_max value is $param. It should be equal to or more than (nproc * 8). Current value for nproc: $nproc.";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semmni | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semmni | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < (0+$nproc)) {
        $msg = Msg::new("semmni value is not as per the requirement ($param:$nproc)");
        $msg->log;
        $param_list->[++$counter] = "semmni value is $param . It should be equal to or more than nproc. Current value for nproc: $nproc.";
        $status = 1;
    }

    $semmns = (0+$param) * 2;
    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semmns | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semmns | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < (0+$semmns)) {
        $msg = Msg::new("semmns value is not as per the requirement ($param:$semmns)");
        $msg->log;
        $param_list->[++$counter] = "semmns value is $param. It should be equal to or more than (semmni * 2)";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semmnu | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semmnu | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < ((0+$nproc) - 4)) {
        $msg = Msg::new("semmnu value is not as per the requirement ($param:($nproc - 4))");
        $msg->log;
        $param_list->[++$counter] = "semmnu value is $param. It should be equal to or more than (nproc - 4). Current value for nproc: $nproc.";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semvmx | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep semvmx | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < 32767) {
        $msg = Msg::new("semvmx value is not as per the requirement ($param:32767)");
        $msg->log;
        $param_list->[++$counter] = "semvmx value is $param. It should be equal to or more than 32767";
        $status = 1;
    }

    # shmmax should be at least half of the
    # total available physical memory
    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep shmmax | _cmd_awk '{print \$2}'");
    $cmd = "/usr/sbin/dmesg | grep Physical: | awk '{print \$2}'";
    $temp = $sys->cmd("$cmd");
    $msg = Msg::new("Total physical memory is $temp ");
    $msg->log;
    $temp = $temp * 1024;
    $temp = $temp / 2;
    $msg = Msg::new("Total physical memory * 1024 /2 is $temp ");
    $msg->log;

    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep shmmax | _cmd_awk '{print \$3}'");
        $cmd = "/usr/sbin/dmesg | grep Physical: | awk '{print \$2}'";
        $temp = $sys->cmd("$cmd");
        $msg = Msg::new("Total physical memory is $temp ");
        $msg->log;
        $temp = $temp * 1024;
        $temp = $temp / 2;
        $msg = Msg::new("Total physical memory * 1024 /2 is $temp ");
        $msg->log;
    }
    $msg = Msg::new("shmmax value is $param: 1/2 of total physical memory is $temp ");
    $msg->log;

    if ((0+$param) < (0+$temp)) {
        $msg = Msg::new("shmmax value is not as per the requirement. It should be atleast half of the total available physical memory ");
        $msg->log;
        $param_list->[++$counter] = "shmmax value is $param. It should be atleast half of the total available physical memory";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep shmmni | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep shmmni | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < 512) {
        $msg = Msg::new("shmmni value is not as per the requirement ($param:512)");
        $msg->log;
        $param_list->[++$counter] = "shmmni value is $param. It should be equal to or more than 512";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep shmseg | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep shmseg | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < 120) {
        $msg = Msg::new("shmseg value is not as per the requirement ($param:120)");
        $msg->log;
        $param_list->[++$counter] = "shmseg value is $param. It should be equal to or more than 120";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep vps_ceiling | _cmd_awk '{print \$2}'");
    if ($param =~ /now/m) {
        $param = $sys->cmd("_cmd_kctune 2>/dev/null | _cmd_grep vps_ceiling | _cmd_awk '{print \$3}'");
    }
    if ((0+$param) < 64) {
        $msg = Msg::new("vps_ceiling value is not as per the requirement ($param:64)");
        $msg->log;
        $param_list->[++$counter] = "vps_ceiling value is $param. It should be equal to or more than 64";
        $status = 1;
    }

    # [TBD] Some more parameters can be added.

    return $status;
}

# Check link speed and Autonegotiation settings
sub check_mac_speed_autoneg_sys {
    my ($prod, $msg, $sys, $flag, @link, @autoneg, @speed, @mac, $ii, $summary);
    my ($cmd_ret, %autoneg_status, %speed_status, %mac_status);
    my ($item, $desc, $status_autoneg, $status_speed, $status_mac);

    $prod = shift;
    $sys = shift;
    # $flag indicates if link1 and link2 have been
    # supplied or not.
    $flag = shift;

    if ($flag eq 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {

        # Links not provided, get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            if ($sys->{padv} =~ /HPUX1131/m) {

                $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}'");
                $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}'");

                $link[0] =~ s/\n/\ /g;
                $link[0] =~ s/\/dev\///mg;
                $link[0] =~ s/://mg;

                $link[1] =~ s/\n/\ /g;
                $link[1] =~ s/\/dev\///mg;
                $link[1] =~ s/://mg;

            }else{

                $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}' |_cmd_cut -d':' -f2");
                $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}' |_cmd_cut -d':' -f2");
            }
            $msg = Msg::log("LLT Link1: $link[0]");
            $msg = Msg::log("LLT Link2: $link[1]");
        } else {
            $msg = Msg::log("/etc/llttab does not exist on $sys. LLT Private Link check cannot proceed for $sys->{sys}.");
            return 1;
        }
    }

    # For link Auto-negotiation setting
    $item = 'Link autonegotiation setting check';
    $desc = 'Checking link Auto-Negotiation setting';
    $autoneg_status{$sys} = '';
    $summary='';
    $status_autoneg = 1;
    # [TBD] Today only supporting two LLT links
    for ($ii=0; $ii<2; $ii++) {
        if ($sys->{padv} =~ /HPUX1131/m) {
            $autoneg[$ii] = $sys->cmd("/usr/sbin/nwmgr  -A all -c $link[$ii] --script  2>/dev/null | _cmd_grep -i 'auto_on' | _cmd_awk '{print \$2}'");
            if ($autoneg[$ii] eq '') {
                $msg = Msg::log("Could not get Auto Negotiation setting for $link[$ii] on $sys->{sys}");
            }else {
                $msg = Msg::log("Auto Negotiation setting for $link[$ii] is $autoneg[$ii] on $sys->{sys}");
            }

        } else {
            $autoneg[$ii] = $sys->cmd("_cmd_lanadmin -x $link[$ii] 2>/dev/null | _cmd_grep -i 'Autonegotiation' | _cmd_awk '{print \$3}' |_cmd_cut -d'.' -f1");
            if ($autoneg[$ii] eq '') {
                $msg = Msg::log("Could not get Auto Negotiation setting for $link[$ii] on $sys->{sys}");
            } else {
                $msg = Msg::log("Auto Negotiation setting for $link[$ii] is $autoneg[$ii] on $sys->{sys}");
            }
        }
    }

    if ("$autoneg[0]" eq "$autoneg[1]") {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0] and $link[1] are identical on $sys->{sys}.";
        $summary = "Auto Negotiation setting on $link[0] and $link[1] are identical on $sys->{sys}.";
    } else {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $summary = "Auto Negotiation setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $status_autoneg = 0;
    }

    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%autoneg_status);

    # For link speed
    $item = 'Link speed setting check';
    $desc = 'Checking link speed setting';
    $speed_status{$sys} = '';
    $summary='';
    $status_speed = 1;

    for ($ii=0; $ii<2; $ii++) {
        if ($sys->{padv} =~ /HPUX1131/m) {
            $speed[$ii] = $sys->cmd("/usr/sbin/nwmgr -A all -c $link[$ii] 2>/dev/null | _cmd_grep -i 'Speed' | _cmd_awk '{print \$3}'");
        } else {
            $speed[$ii] = $sys->cmd("_cmd_lanadmin -x $link[$ii] 2>/dev/null | _cmd_grep 'Speed' | _cmd_awk '{print \$3}'");
        }
        if ($speed[$ii] eq '') {
            $msg = Msg::new("Could not get Speed setting for $link[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Speed setting for $link[$ii] is $speed[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    if ("$speed[0]" eq "$speed[1]") {
        $speed_status{$sys} = "Link speed setting on $link[0] and $link[1] are identical on $sys->{sys}.";
        $summary = "Link Speed setting on $link[0] and $link[1] are identical on $sys->{sys}.";
    } else {
        $speed_status{$sys} = "Link speed setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $summary = "Link Speed setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $status_speed = 0;
    }
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%speed_status);

    # For unique MAC address
    #
    # [TBD] Today we only check the uniqueness
    # on a node. In future, we might need to check
    # uniqueness across the cluster.
    $item = 'Unique MAC address check';
    $desc = 'Checking uniqueness for LLT links';
    $mac_status{$sys} = '';
    $summary='';
    $status_mac = 1;

    for ($ii=0; $ii<2; $ii++) {
        if (!$link[$ii] eq '') {
            if ($sys->{padv} =~ /HPUX1131/m) {
                $mac[$ii] = $sys->cmd("/usr/sbin/nwmgr -A all -c $link[$ii] --script  2>/dev/null | _cmd_grep -i '#mac#' | _cmd_cut -d '#' -f '4'");
             }else{
                $mac[$ii] = $sys->cmd("_cmd_lanadmin -g $link[$ii] 2>/dev/null | _cmd_grep -i 'Station Address' | _cmd_awk '{print \$4}'");
            }
            if ($mac[$ii] eq '') {
                $msg = Msg::new("Could not get MAC address for $link[$ii] on $sys->{sys}");
                $msg->log;
            } else {
                $msg = Msg::new("MAC address for $link[$ii] is $mac[$ii]");
                $msg->log;
            }
        }
    }

    # [TBD] Today only supporting two LLT links.
    if ("$mac[0]" eq "$mac[1]") {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are identical on $sys->{sys}.";
        $status_mac = 0;
        $summary = "MAC addresses on $link[0] and $link[1] are identical on $sys->{sys}.";
    } else {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $summary = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}.";
    }
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%mac_status);

    $msg = Msg::new("status_autoneg: $status_autoneg, status_speed: $status_speed, status_mac: $status_mac");
    $msg->log;
    return !($status_autoneg & $status_speed & $status_mac);
}

# Check links' full duplexity status
sub check_full_duplex_link_sys {
    # Array 'duplex' will have full duplexity info for both the links
    my ($sys, $flag, @link, @duplex, $item, $desc, $status, $summary);
    my ($cmd_ret, $ii, %duplex_status, $prod, $msg);

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}'");
            if ($link[0] =~ /dev/m) {
                $link[0] =~ s/\/dev\///mg;
                $link[0] =~ s/://mg;
            }
            if ($link[1] =~ /dev/m) {
                $link[1] =~ s/\/dev\///mg;
                $link[1] =~ s/://mg;
            }
            $msg = Msg::log("LLT Link1 on $sys->{sys}: $link[0]");
            $msg = Msg::log("LLT Link2 on $sys->{sys}: $link[1]");
        } else {
            $msg = Msg::log("/etc/llttab does not exist on $sys->{sys}. LLT link duplexity check cannot proceed for $sys->{sys}");
            $cmd_ret = 2;
            $status = 0;
            $duplex_status{$sys} = "/etc/llttab is not present on $sys->{sys}. Skipping the test.";
            $summary = "/etc/llttab is not present on $sys->{sys}. Skipping the test.";
            goto SKIPPED;

        }
    }

    if ($sys->{padv}!~ /HPUX1131/m) {
        $link[0] = $sys->cmd("_cmd_lanscan 2>/dev/null | _cmd_grep $link[0] | _cmd_awk '{print \$3}'");
        $link[1] = $sys->cmd("_cmd_lanscan 2>/dev/null | _cmd_grep $link[1] | _cmd_awk '{print \$3}'");
    }

    # Checking Duplex status (Half/Full) of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {
        if ($sys->{padv} =~ /HPUX1131/m){
            $duplex[$ii] = $sys->cmd("/usr/sbin/nwmgr  -A all -c $link[$ii] 2>/dev/null | _cmd_grep -i 'Full Duplex' | _cmd_awk '{print \$5,\$6}'");
             if (EDR::cmdexit()) {
                 $msg = Msg::log("Error in running 'nwmgr'. Open of $link[$ii] failed on $sys->{sys}");
                 $cmd_ret = 2;
                 $status = 0;
                 $duplex_status{$sys} = "Error in running 'nwmgr'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
                 $summary = "Error in running 'nwmgr'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
                 goto SKIPPED;
             } else {
                 chomp($duplex[$ii]);
                 if ($duplex[$ii] eq '') {
                     $msg = Msg::log("Link $link[$ii] is not Full Duplex on $sys->{sys}");
                 } else {
                     $msg = Msg::log("Link $link[$ii] is $duplex[$ii] on $sys->{sys}");
                 }
             }

        } else {
            $duplex[$ii] = $sys->cmd("_cmd_lanadmin -x $link[$ii] 2>/dev/null | _cmd_grep -i 'Full-Duplex' | _cmd_awk '{print \$4}'");
            if (EDR::cmdexit()) {
                $msg = Msg::log("Error in running 'lanadmin'. Open of $link[$ii] failed on $sys->{sys}");
                $cmd_ret = 2;
                $status = 0;
                $duplex_status{$sys} = "Error in running 'lanadmin'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
                $summary = "Error in running 'lanadmin'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
                goto SKIPPED;
            } else {
                chomp($duplex[$ii]);
                if ($duplex[$ii] eq '') {
                    $msg = Msg::log("Link $link[$ii] is not Full-Duplex on $sys->{sys}");
                } else {
                    $msg = Msg::log("Link $link[$ii] is $duplex[$ii] on $sys->{sys}");
                }
            }
        }
    }

    if (($duplex[0] eq 'Full-Duplex.' && $duplex[1] eq 'Full-Duplex.')|| ($duplex[0] eq 'Full Duplex' && $duplex[1] eq 'Full Duplex')) {
        $status = 1;
        $duplex_status{$sys} = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $summary = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $cmd_ret = 0;
    } else {
        $status = 0;
        $duplex_status{$sys} = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}.";
        $summary = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}.";
        $cmd_ret = 1;
    }

SKIPPED:
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%duplex_status);
    return $cmd_ret;
}

# Check links' jumbo frame settings
# Jumbo frames are Ethernet frames with more than 1,500 bytes of payload (MTU)
# Thus, we'll check if all the links have same MTU setting
# They should also be between 1500 and 9200 Bytes
sub get_jumbo_frame_setting_sys {
    # Array 'jumbo' will have MTU info for both the links
    my ($sys, $flag, @link, @jumbo, $item, $desc, $status, $summary);
    my ($cmd_ret, $ii, %jumbo_frame_status, $prod, $msg, $errstr, $frsize);

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    $errstr = '';

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}'");
            if ($link[0] =~ /dev/m) {
                $link[0] =~ s/\/dev\///mg;
                $link[0] =~ s/://mg;
            }
            if ($link[1] =~ /dev/m) {
                $link[1] =~ s/\/dev\///mg;
                $link[1] =~ s/://mg;
            }
            $msg = Msg::log("LLT Link1 on $sys->{sys}: $link[0]");
            $msg = Msg::log("LLT Link2 on $sys->{sys}: $link[1]");
        } else {
            $msg = Msg::log("/etc/llttab does not exist on $sys->{sys}. LLT link jumbo frame check cannot proceed for $sys->{sys}");
            return '-1';
        }
    }
    if ($sys->{padv}!~ /HPUX1131/m) {
        $link[0] = $sys->cmd("_cmd_lanscan 2>/dev/null | _cmd_grep $link[0] | _cmd_awk '{print \$3}'");
        $link[1] = $sys->cmd("_cmd_lanscan 2>/dev/null | _cmd_grep $link[1] | _cmd_awk '{print \$3}'");
    }

    # Checking Jumbo Frame Setting of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {

        eval {    if ($sys->{padv} =~ /HPUX1131/m) {
                $jumbo[$ii] = $sys->cmd("/usr/sbin/nwmgr  -A all -c $link[$ii] --script 2>/dev/null | _cmd_grep -i '#mtu#' | _cmd_cut -d '#' -f '4'");
            } else {
                $jumbo[$ii] = $sys->cmd("_cmd_lanadmin -m $link[$ii] 2>/dev/null | _cmd_awk '{print \$4}'");
            }
        };
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("The NIC: $link[$ii] doesn't seem to be plumbed. Error info: $errstr");
            $msg->log;
            next;
        }
        chomp($jumbo[$ii]);
        if ($jumbo[$ii] =~ /\d\d\d\d/m && $jumbo[$ii] >= 1500 && $jumbo[$ii] <= 9200) {
            $msg = Msg::new("Link $link[$ii] has MTU = $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Link $link[$ii] has suspicious value of MTU: $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
            $msg = Msg::new("The NIC: $link[$ii] couldn't be probed for Jumbo Frame setting on $sys->{sys}. Skipping.");
            $msg->log;
            return '-1'; # Skipping the test
        }
    }
    $frsize = join(' ', @jumbo);
    return $frsize;
}


# Check if the given IP addr is plumed on a LLT link
# Hence making LLT link appear on public network
sub check_llt_link_public_sys {
    my ($sys, $ipaddr, $link1, $link2, $ret, @privipaddrs);
    my ($prod, $msg);

    $prod = shift;
    $sys = shift;
    $ipaddr = shift;
    $link1 = shift;
    $link2 = shift;

    $ret = 0;

    if ($link1 !~ /^lan/m || $link2 !~ /^lan/m) {
        $msg = Msg::new("Invalid values of LLT links passed on $sys->{sys}: $link1 and $link2");
        $msg->log;
        return 1;
    }

    $privipaddrs[0] = $sys->cmd("_cmd_ifconfig $link1 2>/dev/null | _cmd_grep 'inet' | _cmd_awk '{print \$2}'");
    $privipaddrs[1] = $sys->cmd("_cmd_ifconfig $link2 2>/dev/null | _cmd_grep 'inet' | _cmd_awk '{print \$2}'");
    chomp($privipaddrs[0]);
    chomp($privipaddrs[1]);
    $msg = Msg::new("IP address plumed on $link1: $privipaddrs[0]");
    $msg->log;
    $msg = Msg::new("IP address plumed on $link2: $privipaddrs[1]");
    $msg->log;

    if ($ipaddr eq $privipaddrs[0]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link1");
        $msg->log;
        $ret = 1;
    } elsif ($ipaddr eq $privipaddrs[1]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link2");
        $msg->log;
        $ret = 1;
    }

    return $ret;
}


package Prod::SFRAC60::Linux;
@Prod::SFRAC60::Linux::ISA = qw(Prod::SFRAC60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{upgradevers}=[qw(5.0.30 5.1)];
    $prod->{zru_releases}=[qw(5.0.30 5.1)];
    $prod->{menu_options}=['Veritas Volume Replicator','Veritas File Replicator','Global Cluster Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSdbac60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSodm-platform VRTSodm-common VRTSgms60 VRTScavf60
        VRTSglm60 VRTScpi VRTSd2doc VRTSordoc VRTSfsnbl VRTSfppm
        VRTSap VRTStep VRTSgapms VRTSmapro-common VRTSvail
        VRTSd2gui-common VRTSorgui-common VRTSvxmsa VRTSdbdoc
        VRTSdb2ed-common VRTSdbed60 VRTSdbed-common VRTSdbcom-common
        VRTSsybed-common VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw
        VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy VRTScmccc VRTScmcs
        VRTScscm VRTScscw VRTScssim VRTScutil
        VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsdr60 VRTSvcsag60
        VRTScps60 VRTSvcs60 VRTSvxfen60 VRTSgab60 VRTSllt60
        VRTSfsmnd VRTSfssdk60 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb VRTSvcsvr VRTSvrpro VRTSalloc VRTSdcli
        VRTSvsvc VRTSvmpro VRTSddlpr VRTSvdid VRTSlvmconv60
        VRTSvmdoc VRTSvmman SYMClma VRTSspt60 VRTSaa VRTSmh
        VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSsfmh41 VRTSob34
        VRTSobc33 VRTSaslapm60 VRTSat50 VRTSatClient50 VRTSsmf
        VRTSpbx VRTSicsco VRTSvxfs60 VRTSvxfs-platform VRTSvxfs-common
        VRTSvxvm60 VRTSvxvm-platform VRTSvxvm-common VRTSjre15
        VRTSjre VRTSperl512 VRTSvlic32
    ) ];

    my $padv=$prod->padv();
    $padv->{cmd}{vxdctl}='/usr/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{mkfs}='/sbin/mkfs';
    $padv->{cmd}{format}='/usr/sbin/format';
    $padv->{cmd}{psrinfo} = '/usr/sbin/psrinfo';
    $padv->{cmd}{prctl} = '/usr/bin/prctl';
    $padv->{cmd}{sysdef} = '/usr/sbin/sysdef';
    $prod->{cmd_nm_64} = '/usr/bin/nm';
    $prod->{oratab} = '/etc/oratab';

    # Setting SF Oracle RAC/PADV specific variables here
    $prod->{lib_path} = '/opt/VRTSvcs/rac/lib/';
    $prod->{bin_path} = '/opt/VRTSvcs/rac/bin/';
    $prod->{initdir} = '/etc/init.d/';
    $prod->{vendor_skgxn_path} = '/usr/lib64';
    return;
}

sub determine_group {
    my ($prod, $sys, $user) = @_;
    my ($ret, $stat, $tmp);
    $stat = 0;

    $ret = $sys->cmd("_cmd_groups $user");
    chomp($ret);
    ($tmp, $tmp, $prod->{oracle_group}, $prod->{oracle_sgroups}) = split(/\s+/m, $ret, 4);
    chomp($prod->{oracle_sgroups});
    $stat = $stat || EDR::cmdexit();

    $ret = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$prod->{oracle_group}:'");
    chomp($ret);
    $prod->{oracle_gid} = (split(/:/m, $ret, 4))[2];
    $stat = $stat || EDR::cmdexit();

    return $stat;
}

sub create_oragrp {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupadd -g $ogid $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem adding Oracle group $og on $sys->{sys}");
        $msg->print;
        return 1;
    }
    $msg = Msg::new("Added Oracle group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub delete_group {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupdel $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem deleting group $og on $sys->{sys}");
        $msg->log;
        return 1;
    }
    $msg = Msg::new("Deleted group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub create_ora_user_group {
    my ($prod, $sys, $ou, $og, $oh, $ouid, $ogid, $oshell, $user_exists, $group_exists, $orahome_exists) = @_;
    my $msg;
    my $basedir;
    my $ret = 0;

    goto SKIP_GROUP if($group_exists);
    return 1 if ($prod->create_oragrp($sys, $ogid, $og) == 1);

SKIP_GROUP:
    goto SKIP_CREATION if ($user_exists);
    if (!$sys->is_dir("$oh")){
	$basedir = $sys->cmd("dirname $oh");
        $sys->cmd("mkdir -p $basedir");
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
    } else {
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
        $sys->cmd("chown $ou:$og $oh");
        $sys->cmd("_cmd_chmod 755 $oh");
    }

SKIP_CREATION:
    $msg = Msg::new("Added Oracle user $ou with UID $ouid on $sys->{sys}");
    $msg->log;

    return 0;
}

# Modifies group information for a user
# Adding the given group for Oracle user
sub modify_group_info {
    my ($prod, $sys, $user, $group, $groupid) = @_;
    my (@old_group_names, $ret, $grp, $allgrps);

    $ret = $sys->cmd("_cmd_groups $user");
    return 1 if (EDR::cmdexit());
    chomp($ret);
    $ret = (split(/:\s*/m, $ret))[1];
    @old_group_names = split(/\s+/m, $ret);
    $allgrps = $group;
    for my $grp (@old_group_names) {
        $allgrps = $allgrps.','.$grp if ($grp ne '');
    }

    $sys->cmd("_cmd_usermod -G $allgrps $user");
    return 1 if (EDR::cmdexit());

    return 0;
}

sub relink_oracle {
    my $prod = shift;
    my $msg;
    my $orauser = $prod->{oracle_user};
    my $oragrp = $prod->{oracle_group};
    my $cfsmnt = $prod->is_cfsmount($prod->{db_home});

    # ODM lib
    my $vrtsodm;
    my $padv=$prod->padv();

    $vrtsodm = '/opt/VRTSodm/lib64/libodm.so';

    my $orclodm = "$prod->{db_home}/lib/libodm11.so";

    my @cpnodes = ($cfsmnt) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    my $system;
    for my $system (@cpnodes) {
        $msg = Msg::new("\n$system->{sys}");
        $msg->log;
        $msg->bold;


        $msg = Msg::new("Copying $prod->{abbr} ODM library on $system->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        my $timestamp = `date +%m%d%y_%H%M%S`;
        $system->cmd("_cmd_mv $orclodm $orclodm-$timestamp");
        $system->cmd("_cmd_cp $vrtsodm $orclodm");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            return 1;
        } else {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        }

        $msg = Msg::new("Setting permissions $orauser:$oragrp for Oracle ODM library");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $system->cmd("_cmd_chown $orauser:$oragrp $orclodm");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            return 1;
        } else {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        }
    }

    return 0;
}

sub link_libskgxn {
    my ($prod, $skgxn_name, $crs_home) = @_;
    my ($sys, @cpnodes, $msg, $cmd);

    my $crsup = $prod->is_crs_up(CPIC::get('systems'));
    if ($crsup) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure should be linked with Veritas Membership library. To link Oracle Clusterware/Grid Infrastructure, the Oracle Clusterware/Grid Infrastructure will be stopped.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        my $ayn = $msg->ayny;
        if ($ayn eq 'n' || $ayn eq 'N') {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s $prod->{lib_path}${orabits}/vcsmm.so $prod->{crs_home}/lib/libskgxn2.so \n 3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        $cmd = "$crs_home/bin/crsctl stop crs";
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Stopping Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            } else {
                Msg::right_done();
            }
        }
        if (($failed_systems != 0) || ($prod->is_crs_up(CPIC::get('systems')))) {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s $prod->{lib_path}${orabits}/vcsmm.so $prod->{crs_home}/lib/libskgxn2.so \n 3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
    }
    $prod->link_vcsmm_lib($crs_home);
    $cmd = "$crs_home/bin/crsctl start crs";
    if ($crsup) {
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Starting Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            }
            my $count = 0;
            my $crsup = 0;
            while ($count < 40) {
                $sys->cmd("$prod->{crs_home}/bin/crs_stat -t 2> /dev/null");
                if (!EDR::cmdexit()) {
                    $crsup = 1;
                    last;
                }
                sleep(3);
                $count++;
            }
            if ($crsup) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $failed_systems++;
            }
        }
        if ($failed_systems != 0) {
            $msg = Msg::new("Start Oracle Clusterware/Grid Infrastructure on failed systems:\n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 0;
        }
    }

    return 0;
}

# Link the Veritas Membership library
# 'sub do_skgxn' in CPI
sub link_vcsmm_lib {
    my $prod = shift;
    my $crs_home = shift;
    my ($msg, $sys);
    my $orabits = $prod->{oracle_bits};
    my $vrtsgxn = '/etc/ORCLcluster/lib/libskgxn2.so';
    my $orclgxn = "$prod->{crs_home}/lib/libskgxn2.so";

    for my $sys (@{CPIC::get('systems')}) {
        $msg = Msg::new("Linking Veritas skgxn library on $sys->{sys}");
        $msg->left;

        my $timestamp = `date +%m%d%y_%H%M%S`;
        $sys->cmd("_cmd_mv $orclgxn $orclgxn-$timestamp");
        $sys->cmd("_cmd_ln -s $vrtsgxn $orclgxn");
        if (EDR::cmdexit()) {
            Msg::right_failed();
        } else {
            Msg::right_done();
        }
    }
    return;
}

sub set_css_misscount {
    my $prod = shift;
    my $crs_home = shift;
    my ($msg, $cmd);
    my $web=Obj::web();

    my $sys = ${CPIC::get('systems')}[0];
    my $crsup = $prod->is_crs_up(CPIC::get('systems'));
    if ($crsup) {
        $cmd = "$crs_home/bin/crsctl get css misscount";
        my $misscount = $sys->cmd("$cmd");
        if (!EDR::cmdexit()) {
            if ($misscount >= 600) {
                return;
            } elsif (($misscount > 60) && ($misscount < 600)) {
                $msg = Msg::new("\nUpdate css misscount to 600 seconds for Vendor Clusteware\nExecute the following commands on one of the cluster nodes:\n\t $crs_home/bin/crsctl set css misscount 600");
                $msg->print;
                $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
                Msg::prtc();
                return;
            }
        }
        $cmd = "$crs_home/bin/crsctl set css misscount 600";
        $msg = Msg::new("Changing css misscount to 600");
        $msg->left;
        $sys->cmd("$cmd");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            if(Obj::webui())
            {
                $msg = Msg::new("Changing css misscount to 600 failed");
                $web->web_script_form("alert", $msg->{msg});
            }
        } else {
            Msg::right_done();
        }
    } else {
        $msg = Msg::new("\nUpdate css misscount to 600 seconds for Vendor Clusteware\nExecute the following commands on one of the cluster nodes:\n\t $crs_home/bin/crsctl start crs \n\t $crs_home/bin/crsctl set css misscount 600");
        $msg->print;
        $msg = Msg::new("\\nUpdate css misscount to 600 seconds for Vendor Clusteware\\nExecute the following commands on one of the cluster nodes:\\n $crs_home/bin/crsctl start crs \\n $crs_home/bin/crsctl set css misscount 600") if (Obj::webui());
        $web->web_script_form("alert", $msg->{msg}) if (Obj::webui());
        Msg::prtc();
    }
    return;
}

# Make and mount CFS
# return[0] == 0 if everything went fine
sub make_mount_cfs {
    my ($prod, $dgname, $volname, $cfsmntpt, $master) = @_;
    my ($mk, $mkret, %mnt, %mntret);
    my ($sys, $ret);
    my $vxloc = '/dev/vx';

    $ret = 0;
    $mk = $master->cmd("_cmd_mkfs -t vxfs -o largefiles ${vxloc}/rdsk/${dgname}/${volname}");
    $mkret = EDR::cmdexit();

    for my $sys (@{CPIC::get('systems')}) {
        $mnt{$sys} = $sys->cmd("_cmd_mount -t vxfs -o cluster,largefiles,mntlock=VCS  $vxloc/dsk/${dgname}/${volname} $cfsmntpt");
        $mntret{$sys} = EDR::cmdexit();
        $ret = $ret || $mntret{$sys};
    }

    $ret = $ret || $mkret;
    return ($ret, $mk, $mkret, %mnt, %mntret);
}


##################################################################################################
#                                                                                                #
#                       Platform specific prepu checks routines.                                 #
#                                                                                                #
##################################################################################################

sub plat_prepu_sfrac_defines {

    my $prod = shift;
    my $padv = $prod->padv();
        $pdav->{cmd}{vxfenadm} = '/sbin/vxfenadm';
        $pdav->{cmd}{gabconfig} = '/sbin/gabconfig';
        $pdav->{cmd}{vcsmmconfig} = '/etc/sysconfig/vcsmm';
    $padv->{cmd}{lltstat} = '/sbin/lltstat';

    return;
}


# Check if DBAC package is present or not.
sub is_dbac_present {
    my ($prod, $ret, $sys);
    $prod = shift;
    $sys = shift;

    $ret = $sys->cmd('_cmd_rpm -qa 2>/dev/null | _cmd_grep dbac');
    if ($ret eq '') {
        return 0;
    } else {
        return 1;
    }
}

sub get_oslevel_sys {
    my ($prod, $sys, $msg, $os_ref);
    $prod = shift;
    $sys = shift; # target host of the checking

    $msg = Msg::new("Get os level of sfrac");
    $msg->log;

    if ($sys->exists('/etc/redhat-release')) {
        $os_ref = $sys->cmd('_cmd_cat /etc/redhat-release');
    } elsif ($sys->exists('/etc/SuSE-release')) {
        $os_ref = $sys->cmd('_cmd_cat /etc/SuSE-release');
    }

    if ($os_ref eq '') {
        $msg = Msg::new("Can't get os version and patch level info on $sys->{sys}");
        $msg->log;
    }

    return $os_ref;
}


# Platform specific code for checking the system architecture
sub get_archtype_sys {
    my ($prod, $sys, $archtype, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get architecture type");
    $msg->log;

    eval {$archtype = $sys->cmd('_cmd_uname  -p');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get architeture type, error info :$errstr");
        $msg->log;
        return '';
    }

    return $archtype;
}


# Platform specific code for checking processor speed.
sub get_cpuspeed_sys {
    my ($prod, $sys, $msg);
    my ($cpuinfo, @cpuspeed, $cpucnt, $errstr);

    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("Get processor speed");
    $msg->log;

    # $grep "MHz" '/proc/cpuinfo'
    # cpu MHz         : 2386.331
    # cpu MHz         : 2386.331
    # cpu MHz         : 2386.331
    # cpu MHz         : 2386.331

    eval {$cpuinfo = $sys->cmd("_cmd_grep MHz '/proc/cpuinfo' ");};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get the processor information, error info :$errstr");
        $msg->log;
        return '';
    }

    my @lines = split(/\n/, $cpuinfo);

    for(my $ii=0; $ii<=$#lines; $ii++) {
        if($lines[$ii] =~ ".+[\ ]+([0-9\.]+)") {
            $cpuspeed[$ii] = $1;
            $cpuspeed[$ii] = int ($cpuspeed[$ii]+ 0.5);     # Rounding off.
        }
    }
    $cpuinfo = join(' ', @cpuspeed);

    return $cpuinfo;
}

# Platform specific code for checking if 'oprocd' is running
# Linux's behavior is different than other plats
# Here the 'status' should be '0' if 'oprocd' is running
sub check_oprocd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status, $oprocd);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Check if for this $oraversion this check doesn't apply
    # (Applies only for version >= 10.2.0.4)
    # In that case return $status as 0
    if ($oraversion =~ /^9/m ||
        $oraversion =~ /10.1/m ||
        $oraversion =~ /10.2.0.1/m ||
        $oraversion =~ /10.2.0.2/m ||
        $oraversion =~ /10.2.0.3/m) { # !(Oracle 10.2.0.4 or 11g)
        return $status;
    }

    # If 'oprocd' check applies for the given $oraversion,
    # then check using 'ps' utility
    $oprocd = $sys->cmd("_cmd_ps -A | _cmd_grep 'oprocd' | _cmd_awk '{print \$4}'");
    chomp($oprocd);
    if ($oprocd eq 'oprocd' || $oprocd eq 'oprocd.bin' || $oprocd eq './oprocd.bin start') {
        $status = 1;
    } else {
        $status = 0;
    }

    return $status;
}


# Platform specific Code for checking if init.cssd
# file has been patched properly
sub check_initcssd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    $cmd_ret = $sys->cmd('_cmd_grep VERITAS /etc/init.d/init.cssd | _cmd_grep SFRAC');

    if ($cmd_ret eq '') {
        $status = 1;
    }

    return $status;
}


# For Some LLT link related checks, the interfaces meed to be plumbed.
# This routine plumbs them if they are not plumbed.
# [TBD] The devces are not umplumbed after the checks. Needs to be handled later.

sub plat_plumbdev_sys {
    my ($prod, $syslistref, @link, $sys, $res);

    $prod = shift;
    $prod = shift;
    $syslistref = shift;
    $res = 0;

    for my $sys (@{$syslistref}) {
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}' ");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}' ");

            $sys->cmd("_cmd_ifconfig '$link[0]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[0] is invalid or not plumbed. Trying to plumb.");
                $msg->log;
                $sys->cmd("_cmd_ifconfig '$link[0]' up 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg = Msg::new(" Problem in plumbing LLT interface $link[0]");
                    $msg->log;
                    $res = 1;
                } else {
                    $msg = Msg::new("Interface $link[0] is plumbed successfully");
                    $msg->log;
                }
            }

            $sys->cmd("_cmd_ifconfig '$link[1]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[1] is invalid or not plumbed. Trying to plumb.");
                $msg->log;
                $sys->cmd("_cmd_ifconfig '$link[1]' up 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg = Msg::new(" Problem in plumbing LLT interface $link[1]");
                    $msg->log;
                    $res = 1;
                } else {
                    $msg = Msg::new("Interface $link[1] is plumbed successfully");
                    $msg->log;
                }
            }

        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            $res = 1;
        }
    }
    return $res;
}


# Platform specific Code for checking if Oracle's
# libraries are linked properly with Symantec libraries.
sub check_liblink_sys {
    my ($found, $ay, $dirpath);
    my ($ayn, $sys, $orahome, $orauser, $crshome);
    my ($tmpstr, $tmpstr1, $tmpint);
    my (@fileopaths, @libpaths, $fileopath, $libpath);
    my ($skgxplibpath, $temp_version, $oracle_num, $oracleversion);
    my ($ipc_utility, $ipc_version, $ipc_lib);
    my ($single_line, $status, $prod, $msg);

    $single_line='=============================================';

    # status=0 means successful.
    $status=0;

    $prod = shift;
    $sys = shift;
    $crshome = shift;
    $orahome = shift;
    $temp_version = shift;
    $orauser = shift;

    $msg = Msg::new("check_liblink_sys called with -> crshome:$crshome, orahome:$orahome, oracle_version:$temp_version, oracle_user:$orauser");
    $msg->log;

    $oracleversion='';
    # Calculate precise Oracle Version
    if ($temp_version =~ /10.1/m) {
        $oracleversion='10gR1';
        # Numerical Oracle version to use during calculations
        $oracle_num='10';
    }
    if ($temp_version =~ /10.2/m) {
        $oracleversion='10gR2';
        # Numerical Oracle version to use during calculations
        $oracle_num='10';
    }
    if ($temp_version =~ /11.1/m) {
        $oracleversion='11gR1';
        # Numerical Oracle version to use during calculations
        $oracle_num='11';
    }
    if ($temp_version =~ /11.2/m) {
        $oracleversion='11gR2';
        # Numerical Oracle version to use during calculations
        $oracle_num='11';
    }

    if ($oracleversion eq '') {
        $msg = Msg::new("No Oracle version found. Skipping platform specific $prod->{abbr} check for relinking.");
        $msg->log;
        return 2;
    } else {
        Msg::log("ORACLE_VERSION: ${oracleversion}, ORACLE_NUM: ${oracle_num}");
    }

    # [TBD] today we are checking only for one database home.
    # We need to handle the case, where multiple databases are there.

    #[TBD] We should get misscount and show it
    #CPI::do_local("$crshome/bin/crsctl set css misscount 150");
    $msg = Msg::new("Checking files");
    $msg->log;

    #
    # On both 64 bit as well as 32 bit oracle uses
    # $ORACLE_HOME/lib directory to store the
    # respective libraries. i.e.
    # if platfrom is 32 bit -> $ORACLE_HOME/lib
    # contains 32 bit library.
    # if platform is 64 bit -> $ORACLE_HOME/lib
    # contains 64 bit library.
    # hence use the $CPI::PROD{SFRAC}{BITS} variable
    # to determine which library goes into
    # $ORACLE_HOME/lib directory.
    #
    # Same logic used for CRS libraries too.
    #

    $dirpath = $orahome.'/'.'lib';

    $fileopaths[++$#fileopaths] =  $dirpath.'/'.'libodm'.${oracle_num}."\.so";
    # If libodm.so is not installed properly
    # at /usr/lib$prod->{bits}/libodm.so,
    # pick it from /opt/VRTSodm/lib$prod->{bits}/libodm.so, 
    # where VRTSodm package installs it originally.
    
    if( $sys->{arch} =~ /64/m ) {
        $prod->{bits} = 64;
    } else {
        $prod->{bits} = 32;
    }
    $prod->{libodm32} = '/usr/lib/libodm.so';
    $prod->{libodm64} = '/usr/lib64/libodm.so';
 
    if ($sys->exists($prod->{'libodm'.$prod->{bits}})) {
        $libpaths[++$#libpaths] = $prod->{'libodm'.$prod->{bits}};
    } else {
        my $path1=$prod->{'libodm'.$prod->{bits}};
        my $path2='/opt/VRTSodm/lib'.$prod->{bits}.'/libodm.so';
        $msg = Msg::log("Warning : libodm.so not present on $sys->{sys} at its standard path $path1. Picking it from $path2");
      #  $libpaths[++$#libpaths] = "/opt/VRTSodm/lib$prod->{bits}/libodm.so";
        $libpaths[++$#libpaths] = $path2;
    }

    # put our libraries in $ORA_CRS_HOME/lib also.
    # add thier names and path to the library array.

    #reset $dirpath variable to reflect $ORA_CRS_HOME/lib directory.

    $dirpath = $crshome.'/'.'lib';

    $fileopaths[++$#fileopaths] =  $dirpath.'/'.'libskgxn2.so';
    $libpaths[++$#libpaths] = $prod->{'libvcsmm'.$prod->{bits}};

    # Check if the files are link to our files
    for ($tmpint = 0; $tmpint <= $#libpaths ; $tmpint++) {
        $libpath = $libpaths[$tmpint];

        if ($sys->exists($libpath)) {
            $msg = Msg::new("Veritas library file $libpath is present on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Veritas library file $libpath is not present on $sys->{sys}. This may be because $prod->{abbr} is not installed properly.");
            $msg->log;
            $msg->print;
            $found = 0;
            last;
        }

        # Check if Oracle library file
        # exists and is not a link
        $fileopath = $fileopaths[$tmpint];

        if ($sys->exists($fileopath)) {
            $ay = '';
            # Check if this is already a symbolic
            # link to our library.
            # Note that each \ is for 1 temp
            # variable and string merging.
            $tmpstr1 = " _cmd_diff --brief $fileopath $libpath | _cmd_wc -l ";
            if ($sys->{localsys}) {
                $tmpstr = "_cmd_su $orauser -c $tmpstr1";
            } else {
                $tmpstr = "_cmd_su $orauser -c \'$tmpstr1\' ";
            }
            $ay = $sys->cmd($tmpstr);
            chomp($ay);
            $msg = Msg::new($single_line);
            $msg->log;
            if (0 != (0+$ay)) {
                Msg::log('['.(1+$tmpint)."] >> $fileopath is not linked");
                $status=1;
            } else {
                Msg::log('['.(1+$tmpint)."] >> $fileopath is linked");
            }
            $msg = Msg::new($single_line);
            $msg->log;
        } else {
            $msg = Msg::new("Oracle library file $fileopath is missing on $sys->{sys}. Oracle may not have been properly installed or upgraded on $sys->{sys}\n");
            $msg->log;
            $status=1;
        }
    }

    return $status;
}

# Check for kernel parameters on linux that are
# required for Oracle RAC
# Return @param_list with the list of kernel parameters
# for which check failed.
sub plat_check_kernelparams_sys {
    my ($sys, $params, $param, $param_list, $counter);
    my ($prod, $msg, $temp, $status);

    $prod = shift;
    $sys = shift;
    $param_list = shift;
    $counter = -1;
    $status = 0;
    $oraversion = $prod->{oraver};

    # sem (semmsl, semmns, semopm, semmni) check
    $param = $sys->cmd("_cmd_cat /proc/sys/kernel/sem | _cmd_awk '{print \$1}'");
    if ((0+$param) < 250) {
        $msg = Msg::new("semmsl value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "semmsl value is $param. It should be equal to or more than 250";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_cat /proc/sys/kernel/sem | _cmd_awk '{print \$2}'");
    if ((0+$param) < 32000) {
        $msg = Msg::new("semmns value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "semmns value is $param. It should be equal to or more than 32000";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_cat /proc/sys/kernel/sem | _cmd_awk '{print \$3}'");
    if ((0+$param) < 100) {
        $msg = Msg::new("semopm value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "semopm value is $param. It should be equal to or more than 100";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_cat /proc/sys/kernel/sem | _cmd_awk '{print \$4}'");
    if ((0+$param) < 128) {
        $msg = Msg::new("semmni value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "semmni value is $param. It should be equal to or more than 128";
        $status = 1;
    }
    # shmall should be at least 1073741824 for 11.2 and 2097152 for 10.*
    $param = $sys->cmd('_cmd_cat /proc/sys/kernel/shmall');
    if ((0+$param) < 2097152) {
        $msg = Msg::new("shmall value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "shmall value is $param. It should be equal to or more than  $shmall_value";
        $status = 1;
    }

    # shmmax should be at least half of the
    # total available physical memory
    $temp = $sys->cmd("_cmd_cat /proc/meminfo | _cmd_grep MemTotal | _cmd_cut -d':' -f2 | _cmd_awk '{print \$1}'");
    $temp = $temp * 1024;
    $temp = $temp / 2;
    $param = $sys->cmd('_cmd_cat /proc/sys/kernel/shmmax');
    $msg = Msg::new("temp: $temp, param: $param");
    $msg->log;
    if ((0+$param) < (0+$temp)) {
        $msg = Msg::new("shmmax value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "shmmax value is $param. It should be at least half of the total available physical memory";
        $status = 1;
    }
    # shmmni should be at least 4096 for 11.* and 2046 for 10.*
    if ($oraversion =~ /11.2/m){
        $shmmni_value = 4096;
    }
    else{
        $shmmni_value = 2046;
    }

    $param = $sys->cmd('_cmd_cat /proc/sys/kernel/shmmni');
    if ((0+$param) < $shmmni_value) {
        $msg = Msg::new("shmmni value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "shmmni value is $param. It should be equal to or more than $sh";
        $status = 1;
    }

    # file-max should be at least 6553600 for 11.2 and 4096 for 10*
    if ($oraversion =~ /11.2/m){
        $filemax = 6553600;
    }
    else{
        $filemax = 4096;
    }
    $ip_local_port_range_max = 65000;
    if ($oraversion =~ /11.2/m){
        $ip_local_port_range_max = 65500;
    }

    $param = $sys->cmd('_cmd_cat /proc/sys/fs/file-max');
    if ((0+$param) < $filemax) {
        $msg = Msg::new("file-max value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "file-max value is $param. It should be equal to or more than $filemax";
        $status = 1;
    }
    # ip_local_port_range should be 1024 to 65536
    $param = $sys->cmd("_cmd_cat /proc/sys/net/ipv4/ip_local_port_range | _cmd_awk '{print \$1}'");
    if ((0+$param) < 1024) {
        $msg = Msg::new("ip_local_port_range min value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "ip_local_port_range min value is $param. It should be equal to or more than 1024";
        $status = 1;
    }

    $param = $sys->cmd("_cmd_cat /proc/sys/net/ipv4/ip_local_port_range | _cmd_awk '{print \$2}'");
    if ((0+$param) >  $ip_local_port_range_max) {
        $msg = Msg::new("ip_local_port_range max value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "ip_local_port_range max value is $param. It should be equal to or less than $ip_local_port_range_max";
        $status = 1;
    }

    # rmem_default should be at least 262144
    $param = $sys->cmd('_cmd_cat /proc/sys/net/core/rmem_default');
    if ((0+$param) < 262144) {
        $msg = Msg::new("rmem_default value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "rmem_default value is $param. It should be equal to or more than 262144";
        $status = 1;
    }
    # rmem_max should be at least 4194304 for 11* and 262144 for 10*
    if ($oraversion =~ /11.2/m){
        $rmemmax = 4194304;
    }else{
        $rmemmax = 262144;
    }
    $param = $sys->cmd('_cmd_cat /proc/sys/net/core/rmem_max');
    if ((0+$param) < $rmemmax) {
        $msg = Msg::new("rmem_max value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "rmem_max value is $param. It should be equal to or more than $rmemmax";
        $status = 1;
    }

    # wmem_default should be at least 262144
    $param = $sys->cmd('_cmd_cat /proc/sys/net/core/wmem_default');
    if ((0+$param) < 262144) {
        $msg = Msg::new("wmem_default value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "wmem_default value is $param. It should be equal to or more than 262144";
        $status = 1;
    }

    # wmem_max should be at least 262144
    $param = $sys->cmd('_cmd_cat /proc/sys/net/core/wmem_max');
    if ((0+$param) < 262144) {
        $msg = Msg::new("wmem_max value is not as per the requirement");
        $msg->log;
        $param_list->[++$counter] = "wmem_max value is $param. It should be equal to or more than 262144";
        $status = 1;
    }

    return $status;
}


# Check link speed and Autonegotiation settings
# [TBD - Partial] Check for unique MAC address
sub check_mac_speed_autoneg_sys {
    my ($sys, $flag, @link, @autoneg, @speed, @mac, $ii, $summary);
    my ($prod, $msg, $cmd_ret, %autoneg_status, %speed_status, %mac_status);
    my ($item, $desc, $status_autoneg, $status_speed, $status_mac);

    $prod = shift;
    $sys = shift;
    # $flag indicates if link1 and link2 have been
    # supplied or not.
    $flag = shift;

    if ($flag eq 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {

        # Links not provided, get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$3}' | _cmd_cut -d'-' -f2");
            $link[0] = $sys->cmd("_cmd_ifconfig -a 2>/dev/null | _cmd_grep -i '$link[0]' | _cmd_head -1 | _cmd_awk '{print \$1}'");

            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$3}' | _cmd_cut -d'-' -f2");
            $link[1] = $sys->cmd("_cmd_ifconfig -a 2>/dev/null | _cmd_grep -i '$link[1]' | _cmd_head -1 | _cmd_awk '{print \$1}'");

            $msg = Msg::new("LLT Link1: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            return 1;
        }
    }

    # For link Auto-negotiation setting
    # [TBD] Today only supporting two LLT links
    for ($ii=0; $ii<2; $ii++) {
        $autoneg[$ii] = $sys->cmd("_cmd_ethtool $link[$ii] 2>/dev/null | _cmd_grep 'Auto-negotiation:' | _cmd_awk '{print \$2}'");
        if ($autoneg[$ii] eq '') {
            $msg = Msg::new("Could not get Auto Negotiation setting for $link[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Auto Negotiation setting for $link[$ii] is $autoneg[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    # For link auto-negotiation setting
    $item = 'Link Auto-Negotiation setting check';
    $desc = 'Checking link Auto-Negotiation setting';
    $autoneg_status{$sys} = '';
    $summary='';
    $status_autoneg = 1;
    if ("$autoneg[0]" eq "$autoneg[1]") {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0] and $link[1] are identical on $sys->{sys}.";
        $summary = "Auto Negotiation setting on $link[0] and $link[1] are identical on $sys->{sys}.";
        $msg = Msg::new("Auto Negotiation settings on the links ($link[0] and $link[1]) are identical");
        $msg->log;
    } else {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $summary = "Auto Negotiation setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $status_autoneg = 0;
        $msg = Msg::new("Auto Negotiation settings on the links ($link[0] and $link[1]) are not identical");
        $msg->log;
    }

    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%autoneg_status);

    # For link speed
    $item = 'Link speed setting check';
    $desc = 'Checking link speed setting';
    $speed_status{$sys} = '';
    $summary='';
    $status_speed = 1;

    for ($ii=0; $ii<2; $ii++) {
        $speed[$ii] = $sys->cmd("_cmd_ethtool $link[$ii] 2>/dev/null | _cmd_grep -i 'Speed:' | _cmd_awk '{print \$2}'");
        if ($speed[$ii] eq '') {
            $msg = Msg::new("Could not get Speed setting for $link[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Speed setting for $link[$ii] is $speed[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    if ("$speed[0]" eq "$speed[1]") {
        $speed_status{$sys} = "Link speed setting on $link[0] and $link[1] are identical on $sys->{sys}.";
        $summary = "Link speed setting on $link[0] and $link[1] are identical on $sys->{sys}.";
        $msg = Msg::new("Speed settings on the links ($link[0] and $link[1]) are identical");
        $msg->log;
    } else {
        $speed_status{$sys} = "Link speed setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $summary = "Link speed setting on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $status_speed = 0;
        $msg = Msg::new("Speed settings on the links ($link[0] and $link[1]) are not identical");
        $msg->log;
    }
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%speed_status);

    # For unique MAC address
    #
    # [TBD] Today we only check the uniqueness
    # on a node. In future, we might need to check
    # uniqueness across the cluster.
    $item = 'Unique MAC address check';
    $desc = 'Checking uniqueness for LLT links';
    $mac_status{$sys} = '';
    $summary='';
    $status_mac = 1;

    for ($ii=0; $ii<2; $ii++) {
        if (!$link[$ii] eq '') {
            $mac[$ii] = $sys->cmd("_cmd_ifconfig $link[$ii] 2>/dev/null | _cmd_grep -i 'HWaddr' | _cmd_awk '{print \$5}'");
            if ($mac[$ii] eq '') {
                $msg = Msg::new("Could not get MAC address for $link[$ii] on $sys->{sys}");
                $msg->log;
            } else {
                $msg = Msg::new("MAC address for $link[$ii] is $mac[$ii]");
                $msg->log;
            }
        }
    }

    # [TBD] Today only supporting two LLT links.
    if ("$mac[0]" eq "$mac[1]") {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are identical on $sys->{sys}.";
        $status_mac = 0;
        $summary = "MAC addresses on $link[0] and $link[1] are identical on $sys->{sys}.";
        $msg = Msg::new("MAC addresses on the links ($link[0] and $link[1]) are not unique");
        $msg->log;
    } else {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}";
        $summary = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}";
        $msg = Msg::new("MAC addresses on the links ($link[0] and $link[1]) are unique");
        $msg->log;
    }
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%mac_status);

    $msg = Msg::new("status_autoneg: $status_autoneg, status_speed: $status_speed, status_mac: $status_mac");
    $msg->log;
    return !($status_autoneg & $status_speed & $status_mac);
}

# Check links' full duplexity status
sub check_full_duplex_link_sys {
    # Array 'duplex' will have full duplexity info for both the links
    my ($sys, $flag, @link, @duplex, $item, $desc, $status, $summary);
    my ($cmd_ret, $ii, %duplex_status, $prod, $msg);

    $prod= shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");
            if ($link[0] =~ /dev/m) {
                $link[0] =~ s/\/dev\///mg;
                $link[0] =~ s/://mg;
            }
            if ($link[1] =~ /dev/m) {
                $link[1] =~ s/\/dev\///mg;
                $link[1] =~ s/://mg;
            }
            $msg = Msg::new("LLT Link1 on $sys->{sys}: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT link duplexity check cannot proceed for $sys->{sys}.");
            $msg->log;
            return 1;
        }
    }

    # Checking Duplex status (Half/Full) of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {
        $duplex[$ii] = $sys->cmd("_cmd_ethtool $link[$ii] 2>/dev/null | _cmd_grep -i 'Duplex' | _cmd_awk '{print \$2}'");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Error in running 'ethtool'. Open of $link[$ii] failed on $sys->{sys}.");
            $msg->log;
            $cmd_ret = 2;
            $status = 0;
            $duplex_status{$sys} = "Error in running 'ethtool'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
            $summary = "Error in running 'ethtool'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
            goto SKIPPED;
        } else {
            chomp($duplex[$ii]);
            $msg = Msg::new("Link $link[$ii] is $duplex[$ii]-Duplex on $sys->{sys}");
            $msg->log;
        }
    }

    if ($duplex[0] eq 'Full' && $duplex[1] eq 'Full') {
        $status = 1;
        $duplex_status{$sys} = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $summary = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}";
        $cmd_ret = 0;
    } else {
        $status = 0;
        $duplex_status{$sys} = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}";
        $summary = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}";
        $cmd_ret = 1;
    }

SKIPPED:
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%duplex_status);
    return $cmd_ret;
}

# Check links' jumbo frame settings
# Jumbo frames are Ethernet frames with more than 1,500 bytes of payload (MTU)
# Thus, we'll check if all the links have same MTU setting
# They should also be between 1500 and 9200 Bytes
sub get_jumbo_frame_setting_sys {
    # Array 'jumbo' will have MTU info for both the links
    my ($sys, $flag, @link, @jumbo, $item, $desc, $status, $summary, $frsize);
    my ($cmd_ret, $ii, %jumbo_frame_status, $prod, $msg, $output, $errstr);

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    $errstr = '';

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");

            $msg = Msg::new("LLT Link1 on $sys->{sys}: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT link jumbo frame check cannot proceed for $sys->{sys}");
            $msg->log;
            return '-1';
        }
    }

    # Checking Jumbo Frame Setting of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {
        eval {$output = $sys->cmd("_cmd_ifconfig $link[$ii] 2>/dev/null | _cmd_grep -i 'MTU'");};

        #   UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
        if ( $output !~ /UP/m ) {
            $errstr = $@;
            $msg = Msg::new("The NIC: $link[$ii] doesn't seem to be plumbed. Error info: $errstr");
            $msg->log;
            next;
        }

        if ( $output =~ /.+[\ ]+(MTU):([0-9]+).*/m ) {
            $jumbo[$ii] = $2;
        }

        chomp($jumbo[$ii]);
        if ($jumbo[$ii] =~ /\d\d\d\d/m && $jumbo[$ii] >= 1500 && $jumbo[$ii] <= 9200) {
            $msg = Msg::new("Link $link[$ii] has MTU = $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Link $link[$ii] has suspicious value of MTU: $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
            $msg = Msg::new("The NIC: $link[$ii] couldn't be probed for Jumbo Frame setting on $sys->{sys}. Skipping.");
            $msg->log;
            return '-1'; # Skipping the test
        }
    }
    $frsize = join(' ', @jumbo);
    return $frsize;
}

# Check if the given IP addr is plumed on a LLT link
# Hence making LLT link appear on public network
sub check_llt_link_public_sys {
    my ($prod, $msg, $sys, $ipaddr, $link1, $link2, $ret, @privipaddrs);

    $prod = shift;
    $sys = shift;
    $ipaddr = shift;
    $link1 = shift;
    $link2 = shift;

    $ret = 0;

    if ($link1 !~ /^eth/m || $link2 !~ /^eth/m) {
        $msg = Msg::new("Invalid values of LLT links passed on $sys->{sys}: $link1 and $link2");
        $msg->log;
        return 1;
    }

    $privipaddrs[0] = $sys->cmd("_cmd_ifconfig $link1 2>/dev/null | _cmd_grep 'inet addr' | _cmd_awk '{print \$2}' | _cmd_cut -d':' -f2");
    $privipaddrs[1] = $sys->cmd("_cmd_ifconfig $link2 2>/dev/null | _cmd_grep 'inet addr' | _cmd_awk '{print \$2}' | _cmd_cut -d':' -f2");
    chomp($privipaddrs[0]);
    chomp($privipaddrs[1]);
    $msg = Msg::new("IP addr plumed on $link1: $privipaddrs[0]");
    $msg->log;
    $msg = Msg::new("IP addr plumed on $link2: $privipaddrs[1]");
    $msg->log;

    if ($ipaddr eq $privipaddrs[0]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link1");
        $msg->log;
        $ret = 1;
    } elsif ($ipaddr eq $privipaddrs[1]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link2");
        $msg->log;
        $ret = 1;
    }

    return $ret;
}

sub get_plumbed_ips {
    my ($prod, $nodes_ref) = @_;
    my ($sys, $output, $msg);
    my $tmpdir=EDR::tmpdir();

    EDR::cmd_local("_cmd_rm $tmpdir/plumbed_ips.txt");
    for my $sys (@{$nodes_ref}) {
#        $output = $sys->cmd("ifconfig -a | _cmd_grep inet | _cmd_awk \'{print \$2}\' | _cmd_awk -F\'\/\' \'{print \$1}\'");
        $output = $sys->cmd("ifconfig -a | _cmd_grep inet | _cmd_awk \'{print \$2}\' | _cmd_awk -F: \'{print \$2}\'");
        EDR::cmd_local("echo \'$output\' >> $tmpdir/plumbed_ips.txt");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Failed to save plumbed ips in $tmpdir/plumbed_ips.txt");
            $msg->print;
            Msg::prtc();
            return 1;
        }
    }

    return 0;
}


package Prod::SFRAC60::SunOS;
@Prod::SFRAC60::SunOS::ISA = qw(Prod::SFRAC60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];

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

    my $padv=$prod->padv();
    $padv->{cmd}{vxdctl}='/usr/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{mkfs}='/usr/sbin/mkfs';
    $padv->{cmd}{format}='/usr/sbin/format';
    $padv->{cmd}{psrinfo} = '/usr/sbin/psrinfo';
    $padv->{cmd}{prctl} = '/usr/bin/prctl';
    $padv->{cmd}{prtconf} = '/usr/sbin/prtconf';
    $padv->{cmd}{sysdef} = '/usr/sbin/sysdef';

    # Setting SF Oracle RAC/PADV specific variables here
    $prod->{lib_path} = '/opt/VRTSvcs/rac/lib/';
    $prod->{bin_path} = '/opt/VRTSvcs/rac/bin/';
    $prod->{initdir} = '/etc/init.d/';
    $prod->{ipc_utility} = '/opt/VRTSvcs/ops/bin/ipc_version_chk_shared';
    $prod->{hosts_file} = '/etc/inet/ipnodes';
    $prod->{vendor_skgxn_path} = '/opt/ORCLcluster/lib';
    $prod->{xdpyinfo_path} = '/usr/openwin/bin/xdpyinfo';
    return;
}

sub determine_group {
    my ($prod, $sys, $user) = @_;
    my ($ret, $stat);
    $stat = 0;

    $ret = $sys->cmd("_cmd_groups $user");
    chomp($ret);
    ($prod->{oracle_group}, $prod->{oracle_sgroups}) = split(/\s+/m, $ret, 2);
    chomp($prod->{oracle_sgroups});
    $stat = $stat || EDR::cmdexit();

    $ret = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$prod->{oracle_group}:'");
    chomp($ret);
    $prod->{oracle_gid} = (split(/:/m, $ret, 4))[2];
    $stat = $stat || EDR::cmdexit();

    return $stat;
}

sub addnode_get_group {
    my ($prod, $sys, $user) = @_;
    my ($groups, $grp);

    $groups = $sys->cmd("_cmd_groups $user");
    chomp($groups);
    $grp = (split(/\s+/m, $groups))[0];

    return $grp;
}

sub upgrade_configure_sys {
    my ($prod, $sys) = @_;
    my ($rootpath,$smfprofile_upgrade,@sfrac_smfs,$cfg);

    $prod->perform_task_sys($sys, 'upgrade_configure_sys');

    $rootpath = Cfg::opt('rootpath')||'';
    $smfprofile_upgrade = "$rootpath/var/svc/profile/upgrade";
    @sfrac_smfs=();
    @sfrac_smfs = qw(vcsmm lmx);
    for my $smf(@sfrac_smfs) {
        $sys->cmd("echo 'svcadm enable system/$smf' >> $smfprofile_upgrade");
    }
    return;
}

sub create_oragrp {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupadd -g $ogid $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem adding Oracle group $og on $sys->{sys}");
        $msg->print;
        return 1;
    }
    $msg = Msg::new("Added Oracle group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub delete_group {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupdel $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem deleting group $og on $sys->{sys}");
        $msg->log;
        return 1;
    }
    $msg = Msg::new("Deleted group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub create_ora_user_group {
    my ($prod, $sys, $ou, $og, $oh, $ouid, $ogid, $oshell, $user_exists, $group_exists, $orahome_exists) = @_;
    my $msg;
    my $basedir;
    my $ret = 0;

    goto SKIP_GROUP if($group_exists);
    return 1 if ($prod->create_oragrp($sys, $ogid, $og) == 1);

SKIP_GROUP:
    goto SKIP_CREATION if ($user_exists);
    if (!$sys->is_dir("$oh")) {
        $basedir = $sys->cmd("dirname $oh");
        $sys->cmd("mkdir -p $basedir");
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
    } else {
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
        $sys->cmd("chown $ou:$og $oh");
        $sys->cmd("_cmd_chmod 755 $oh");
    }

SKIP_CREATION:
    $msg = Msg::new("Added Oracle user $ou with UID $ouid on $sys->{sys}");
    $msg->log;

    return 0;
}

# Modifies group information for a user
# Adding the given group for Oracle user
sub modify_group_info {
    my ($prod, $sys, $user, $group, $groupid) = @_;
    my (@old_group_names, $ret, $grp, $allgrps);

    $ret = $sys->cmd("_cmd_groups $user");
    return 1 if (EDR::cmdexit());
    chomp($ret);
    @old_group_names = split(/\s+/m, $ret);
    $allgrps = $group;
    for my $grp (@old_group_names) {
        $allgrps = $allgrps.','.$grp if ($grp ne '');
    }

    $sys->cmd("_cmd_usermod -G $allgrps $user");
    return 1 if (EDR::cmdexit());

    return 0;
}

sub set_install_env {
    my ($prod, $release, $patch_level, $instpath) = @_;
    my ($sys, $msg);
    my $tmpdir=EDR::tmpdir();
    my $bs=EDR::get2('tput','bs');
    my $be=EDR::get2('tput','be');
    $prod->{oui_args} = '';
    $prod->{oui_export} = '';

    # If SKIP_ROOTPRE is not set, invoke the rootpre.sh script.
    if ((($release eq '10.2') && ($patch_level eq '0.1'))) {
        if ($ENV{'SKIP_ROOTPRE'} eq 'TRUE') {
            $msg = Msg::new("SKIP_ROOTPRE environment variable is set. Will not invoke Oracle rootpre.sh script.");
            $msg->print;
        } else {
            my $is_failed = 0;
            for my $sys (@{CPIC::get('systems')}) {
                $msg = Msg::new("Invoking Oracle rootpre.sh on $sys->{sys}");
                $msg->left;
                $prod->localsys->copy_to_sys($sys,"$instpath/rootpre","$tmpdir/rootpre");
                $sys->cmd("cd $tmpdir/rootpre; ./rootpre.sh");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    $is_failed = 1;
                } else {
                    Msg::right_done();
                }
            }

            if ($is_failed == 1) {
                my $rootpre_loc;
                $rootpre_loc = "$instpath/rootpre";

                $msg = Msg::new("The execution of rootpre.sh script failed on one or more systems. For installation to proceed, Oracle requires you to run the rootpre.sh script located under ${rootpre_loc}. Run it manually on these systems as root user.");
                $msg->print;
                return 0 if (Cfg::opt('responsefile'));
                $msg = Msg::new("Press <RETURN> after running rootpre.sh:");
                print "\n$bs$msg->{msg}$be ";
                <STDIN>;
            }
        }

        $prod->{oui_export} = 'SKIP_ROOTPRE=TRUE;export SKIP_ROOTPRE;';
    }

    return 0;
}

sub set_crs_install_env {
    my $prod = shift;
    my $ret;
    my $msg;

    my $padv=$prod->padv();
    if ($padv->{arch} eq 'i86pc') {
        $msg = Msg::new("Architecture is x84. Running 'rootpre.sh'");
        $msg->log;
        $ret = $prod->set_install_env($prod->{crs_release}, $prod->{crs_patch_level}, $prod->{crs_installpath});
    } else {
        $msg = Msg::new("Architecture is probably 'sparc'. Need not run 'rootpre.sh'");
        $msg->log;
        $ret = 0;
    }

    return $ret;
}

sub relink_oracle {
    my $prod = shift;
    my $msg;
    my $orauser = $prod->{oracle_user};
    my $oragrp = $prod->{oracle_group};
    my $cfsmnt = $prod->is_cfsmount($prod->{db_home});

    # IPC lib
    my ($orclgxp, $ipclib, $vrtsgxp);
    if ($prod->{db_release} eq '10.2') {
        $orclgxp = "$prod->{db_home}/lib/libskgxp10.so";
        $ipclib  = $prod->getipclib($prod->{db_release}, $prod->{oracle_bits});
        $vrtsgxp = $prod->{lib_path} . $ipclib;
    }

    # ODM lib
    my $vrtsodm;
    my $padv=$prod->padv();
    if ($padv->{arch} eq 'i86pc') {
        $vrtsodm = '/opt/VRTSodm/lib/amd64';
    } else {
        $vrtsodm = '/usr/lib/sparcv9';
    }
    $vrtsodm = "${vrtsodm}/libodm.so";

    my $orclodm;
    if ($prod->{db_release} eq '10.2') {
        $orclodm = "$prod->{db_home}/lib/libodm10.so";
    } else {
        $orclodm = "$prod->{db_home}/lib/libodm11.so";
    }

    my @cpnodes = ($cfsmnt) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    my $system;
    for my $system (@cpnodes) {
        $msg = Msg::new("\n$system->{sys}");
        $msg->log;
        $msg->bold;

        my $timestamp = `date +%m%d%y_%H%M%S`;
        if ($prod->{db_release} eq '10.2') {
            $msg = Msg::new("Backing up Oracle skgxp library on $system->{sys}");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());

            $system->cmd("_cmd_mv $orclgxp ${orclgxp}.$timestamp 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                return 1;
            } else {
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            }

            $msg = Msg::new("Copying $prod->{abbr} skgxp library on $system->{sys}");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());

            $system->cmd("_cmd_cp $vrtsgxp $orclgxp 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                return 1;
            } else {
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            }

            $msg = Msg::new("Setting permissions $orauser:$oragrp Oracle skgxp library");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());

            $system->cmd("_cmd_chown $orauser:$oragrp $orclgxp 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                return 1;
            } else {
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            }
        }

        $msg = Msg::new("Copying $prod->{abbr} ODM library on $system->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());

        $system->cmd("_cmd_rm $orclodm");
        $system->cmd("_cmd_cp $vrtsodm $orclodm 2>/dev/null");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            return 1;
        } else {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        }

        $msg = Msg::new("Setting permissions $orauser:$oragrp Oracle ODM library");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());

        $system->cmd("_cmd_chown $orauser:$oragrp $orclodm 2>/dev/null");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            return 1;
        } else {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        }
    }

    return 0;
}

sub getipclib {
    my $ipclib;
    my $ipc_version;
    my $prod = shift;
    my ($oravers, $orabits) = @_;

    $ipc_version = '25'; # Hard coding it as Oakmont has only Oracle 10GR2 and onwards
    $ipclib='libskgxp10_ver' . $ipc_version . '_' . $orabits . '.so';

    return $ipclib;
}

sub link_libskgxn {
    my ($prod, $skgxn_name, $crs_home) = @_;
    my ($sys, @cpnodes, $msg, $cmd);

    my $crsup = $prod->is_crs_up(CPIC::get('systems'));
    if ($crsup) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure should be linked with Veritas Membership library. To link Oracle Clusterware/Grid Infrastructure, the Oracle Clusterware/Grid Infrastructure will be stopped.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        my $ayn = $msg->ayny;
        if ($ayn eq 'n' || $ayn eq 'N') {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s /opt/ORCLcluster/lib/libskgxn2.so $prod->{crs_home}/lib/libskgxn2.so \n 3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        $cmd = "$crs_home/bin/crsctl stop crs";
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Stopping Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            } else {
                Msg::right_done();
            }
        }
        if (($failed_systems != 0) || ($prod->is_crs_up(CPIC::get('systems')))) {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s /opt/ORCLcluster/lib/libskgxn2.so $prod->{crs_home}/lib/libskgxn2.so \n 3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
    }
    $prod->link_vcsmm_lib($crs_home);
    $cmd = "$crs_home/bin/crsctl start crs";
    if ($crsup) {
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Starting Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            }
            my $count = 0;
            my $crsup = 0;
            while ($count < 40) {
                $sys->cmd("$prod->{crs_home}/bin/crs_stat -t 2> /dev/null");
                if (!EDR::cmdexit()) {
                    $crsup = 1;
                    last;
                }
                sleep(3);
                $count++;
            }
            if ($crsup) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $failed_systems++;
            }
        }
        if ($failed_systems != 0) {
            $msg = Msg::new("Start Oracle Clusterware/Grid Infrastructure on failed systems:\n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 0;
        }
    }

    return 0;
}

# Link the Veritas Membership library
# 'sub do_skgxn' in CPI
sub link_vcsmm_lib {
    my $prod = shift;
    my $crs_home = shift;
    my ($msg, $sys);
    my $orabits = $prod->{oracle_bits};
    my $vrtsgxn = $prod->{lib_path} . "libskgxn2_${orabits}.so";
    my $orclgxn = '/opt/ORCLcluster/lib/libskgxn2.so';
    my $crsgxn = "$crs_home/lib/libskgxn2.so";

    for my $sys (@{CPIC::get('systems')}) {
        $msg = Msg::new("Linking Veritas skgxn library on $sys->{sys}");
        $msg->left;

        my $timestamp = `date +%m%d%y_%H%M%S`;
        $sys->cmd("_cmd_mv $orclgxn $orclgxn-$timestamp");
        $sys->cmd("_cmd_ln -s $vrtsgxn $orclgxn 2>/dev/null");
        if (EDR::cmdexit()) {
            Msg::right_failed();
        } else {
            Msg::right_done();
        }

        $msg = Msg::new("Linking Oracle skgxn library on $sys->{sys}");
        $msg->left;

        $sys->cmd("_cmd_mv $crsgxn $crsgxn-$timestamp");
        $sys->cmd("_cmd_ln -s $orclgxn $crsgxn 2>/dev/null");
        if (EDR::cmdexit()) {
            Msg::right_failed();
        } else {
            Msg::right_done();
        }
    }
    return;
}

# Check the labeling status of the given disks
# If not labeled already then label them
# Run 'vxdisk scandisks' in the end
#
# Return 1 if cannot label disk(s)
# Return 0 if everything went fine
sub check_disk_labeling {
    my ($prod, @disks) = @_;
    my ($sys, $disk, $msg, $status,$tmpdir);
    $tmpdir=EDR::tmpdir();
    my $auxformat = "$tmpdir/label_while_formattig";

    open AUXFORMAT, '+>', $auxformat or return 1;
    print AUXFORMAT 'label';
    close AUXFORMAT;

    $status = 0;
    for my $disk (@disks) {
        my ($handle, $label, $temp);
        ($handle, $temp, $temp, $temp, $label) = split(/\s+/m, $disk, 5);
        if ($label eq 'nolabel' || $label eq 'error') {
            $handle =~ s/s\d$//mg if ($handle =~ /s\d$/m);
            for my $sys (@{CPIC::get('systems')}) {
                $sys->cmd("_cmd_format -d $handle -f $auxformat");
                if (EDR::cmdexit()) {
                    $msg = Msg::new("Formatting and labeling of disk $handle failed on $sys");
                    $msg->log;
                    $status = 1;
                    next;
                }
                $sys->cmd('_cmd_vxdisk scandisks');
            }
        }
    }
    return $status;
}

# Make and mount CFS
# Return[0] == 0 if everything went fine
sub make_mount_cfs {
    my ($prod, $dgname, $volname, $cfsmntpt, $master) = @_;
    my ($mk, $mkret, %mnt, %mntret);
    my ($sys, $ret);
    my $vxloc = '/dev/vx';

    $ret = 0;
    $mk = $master->cmd("_cmd_mkfs -F vxfs -o largefiles ${vxloc}/rdsk/${dgname}/${volname}");
    $mkret = EDR::cmdexit();

    for my $sys (@{CPIC::get('systems')}) {
        $mnt{$sys} = $sys->cmd("_cmd_mount -F vxfs -o cluster,largefiles,mntlock=VCS $vxloc/dsk/${dgname}/${volname} $cfsmntpt");
        $mntret{$sys} = EDR::cmdexit();
        $ret = $ret || $mntret{$sys};
    }

    $ret = $ret || $mkret;
    return ($ret, $mk, $mkret, %mnt, %mntret);
}


##################################################################################################
#                                                                                                #
#                       Platform specific prepu checks routines.                                 #
#                                                                                                #
##################################################################################################

sub plat_prepu_sfrac_defines {
    my $prod = shift;
    my $padv = $prod->padv();
    $padv->{cmd}{diff} = '/usr/bin/diff';
    $padv->{cmd}{vxfenadm} = '/sbin/vxfenadm';
    $padv->{cmd}{gabconfig} = '/sbin/gabconfig';
    $padv->{vcsmmconfig} = '/kernel/drv/vcsmm.conf';    # Config file. Not a command.
    $padv->{cmd}{lltstat} = '/sbin/lltstat';
    return;
}

# Check if DBAC package is present or not.
sub is_dbac_present {
    my ($prod, $ret, $sys);
    $prod = shift;
    $sys = shift;

    $ret = $sys->cmd('_cmd_pkginfo 2>/dev/null | _cmd_grep dbac');
    if ($ret eq '') {
        return 0;
    } else {
        return 1;
    }
}

sub get_oslevel_sys {
    my ($prod, $sys, $msg, $os_ref, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get os level of sfrac");
    $msg->log;

    eval {$os_ref = $sys->cmd('_cmd_uname  -r ');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get os version and patch level error info :$errstr");
        $msg->log;
        return '';
    }

    return $os_ref;
}


# Platform specific code for checking the system architecture
sub get_archtype_sys {
    my ($prod, $sys, $archtype, $msg, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get architecture type");
    $msg->log;

    eval {$archtype = $sys->cmd('_cmd_uname  -p');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get architeture type, error info :$errstr");
        $msg->log;
        return '';
    }

    return $archtype;
}


# Platform specific code for checking processor speed.
sub get_cpuspeed_sys {
    my ($prod, $sys, $msg, $errstr);
    my ($cpuinfo, @cpuspeed, $cpucnt);

    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get processor speed");
    $msg->log;


    # $psrinfo | grep MHz
    eval {$cpuinfo = $sys->cmd('_cmd_psrinfo -v | _cmd_grep MHz');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get the processor information, error info :$errstr");
        $msg->log;
        return '';
    }
    my @lines = split(/\n/, $cpuinfo);
    for(my $ii=0; $ii<=$#lines; $ii++) {
        if($lines[$ii] =~ ".+[\ ]+([0-9]+)[\ ]+MHz.+") {
            $cpuspeed[$ii] = $1;
        }
    }
    $cpuinfo = join(' ', @cpuspeed);
    return $cpuinfo;
}


# Platform specific code for checking if 'oprocd' is running
sub check_oprocd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status, $oprocd);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Check if for this $oraversion this check doesn't apply
    # (Applies only for version >= 10.2.0.4)
    # In that case return $status as 0
    if ($oraversion =~ /^9/m ||
        $oraversion =~ /10.1/m ||
        $oraversion =~ /10.2.0.1/m ||
        $oraversion =~ /10.2.0.2/m ||
        $oraversion =~ /10.2.0.3/m) { # !(Oracle 10.2.0.4 or 11g)
        return $status;
    }

    # If 'oprocd' check applies for the given $oraversion,
    # then check using 'ps' utility
    $oprocd = $sys->cmd("_cmd_ps -A | _cmd_grep 'oprocd' | _cmd_awk '{print \$4}'");
    chomp($oprocd);
    if ($oprocd eq 'oprocd' || $oprocd eq 'oprocd.bin' || $oprocd eq './oprocd.bin start') {
        $status = 1;
    }

    return $status;
}


# Platform specific Code for checking if init.cssd
# file has been patched properly
sub check_initcssd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Checking for whether some vendor clusterware is present (non-Oracle)
    if(!$sys->exists('/opt/ORCLcluster/lib/libskgxn2.so')) {
        $status = 1;
    }

    # Check if Veritas Clusterware
    if (!$sys->exists('/opt/ORCLcluster/bin/clsinfo')) {
        $status = 1;
    }

    return $status;
}


# [TBD] Today reading the kernel parameters' values
# from /etc/system, but we may change it to get from
# sysdef command.
# Check for kernel parameters on solaris platform that are
# required for Oracle RAC
# Return @param_list with the list of kernel parameters
# for which check failed.
sub plat_check_kernelparams_sys {
    my ($prod, $msg);
    my ($sys, $param, $param_list, $counter);
    my ($status, $cmd_ret, $skipped, $found, $total_mem, $t_mem);

    $prod = shift;
    $sys = shift;
    $param_list = shift;
    $counter = -1;
    $status = 0;
    $skipped = 0;


    # Solaris 10 specific
    $found = 1;
    $param='shmsys:shminfo_shmmax';
    if ($sys->{platvers} =~ /10/m || $sys->{platvers} =~ /11/m) {
        $cmd_ret = $sys->cmd("_cmd_prctl -n project.max-shm-memory -P \$\$ | _cmd_grep privileged | _cmd_awk '{print \$3}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with prctl.");
            $msg->log;
            $found = 0;
        }
    } else {
        $cmd_ret = $sys->cmd("_cmd_sysdef -i | _cmd_grep -i SHMMAX | _cmd_awk '{print \$1}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with sysdef.");
            $msg->log;
            $found = 0;
        }
    }
    # Valid for Solaris 9 and Solaris 10
    if ($found eq '1' ) {
        $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
        $total_mem = $sys->cmd("_cmd_prtconf 2> /dev/null | _cmd_grep -i 'Memory size' | _cmd_awk '{print \$3}'");
        $total_mem = $total_mem * 1024 * 1024;
        $t_mem = $total_mem / 2;
        $msg = Msg::new("Total physical memory: $total_mem , Half of total physical memory: $t_mem, $param : $cmd_ret.");
        $msg->log;
    }
    if ($cmd_ret eq '') {
        $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}.");
        $msg->log;
        $param_list->[++$counter] = "$param value is UNKNOWN.";
        $skipped = 1;
    } elsif ((0+$cmd_ret) < (0+$t_mem)) {
        $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}. Total physical memory is $total_mem. It should be at least half of the total available physical memory.");
        $msg->log;
        $param_list->[++$counter] = "$param value is $cmd_ret. Total physical memory is $total_mem. It should be at least half of the total available physical memory.";
        $status = 1;
    } else {
        $msg = Msg::new("Kernel parameter $param is proper on $sys->{sys}.");
        $msg->log;
        $status ||= 0;
    }


    # Solaris 10 specific
    $found = 1;
    $param='shmsys:shminfo_shmmni';
    if ($sys->{platvers} =~ /10/m || $sys->{platvers} =~ /11/m) {
        $cmd_ret = $sys->cmd("_cmd_prctl -n project.max-shm-ids -P \$\$ | _cmd_grep privileged | _cmd_awk '{print \$3}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with prctl.");
            $msg->log;
            $found = 0;
        }
    } else {
        $cmd_ret = $sys->cmd("_cmd_sysdef -i | _cmd_grep -i SHMMNI | _cmd_awk '{print \$1}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with sysdef.");
            $msg->log;
            $found = 0;
        }
    }
    # Valid for Solaris 9 and Solaris 10
    if (! $found ) {
        $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
    }
    if ($cmd_ret eq '') {
        $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}. Should be 100 or more.");
        $msg->log;
        $param_list->[++$counter] = "$param value is UNKNOWN. It should be equal to or more than 100";
        $skipped = 1;
    } elsif ((0+$cmd_ret) < 100) {
        $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}. Should be 100 or more.");
        $msg->log;
        $param_list->[++$counter] = "$param value is $cmd_ret. It should be equal to or more than 100";
        $status = 1;
    } else {
        $msg = Msg::new("Kernel parameter $param is proper $sys->{sys}");
        $msg->log;
        $status ||= 0;
    }


    # Solaris 10 specific
    $found = 1;
    $param='semsys:seminfo_semmni';
    if ($sys->{platvers} =~ /10/m || $sys->{platvers} =~ /11/m) {
        $cmd_ret = $sys->cmd("_cmd_prctl -n project.max-sem-ids -P \$\$ | _cmd_grep privileged | _cmd_awk '{print \$3}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with prctl.");
            $msg->log;
            $found = 0;
        }
    } else {
        $cmd_ret = $sys->cmd("_cmd_sysdef -i | _cmd_grep -i SEMMNI | _cmd_awk '{print \$1}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with sysdef.");
            $msg->log;
            $found = 0;
        }
    }
    # Valid for Solaris 9 and Solaris 10
    if (! $found ) {
        $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
    }
    if ($cmd_ret eq '') {
        $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}. Should be 100 or more.");
        $msg->log;
        $param_list->[++$counter] = "$param value is UNKNOWN. Should be 100 or more.";
        $skipped = 1;
    } elsif ((0+$cmd_ret) < 100) {
        $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}. Should be 100 or more.");
        $msg->log;
        $param_list->[++$counter] = "$param value is $cmd_ret. It should be equal to or more than 100";
        $status = 1;
    } else {
        $msg = Msg::new("Kernel parameter $param is proper on $sys->{sys}.");
        $msg->log;
        $status ||= 0;
    }




    # Solaris 10 specific
    $found = 1;
    $param='semsys:seminfo_semmsl';
    if ($sys->{platvers} =~ /10/m || $sys->{platvers} =~ /11/m) {
        $cmd_ret = $sys->cmd("_cmd_prctl -n process.max-sem-nsems -P \$\$ | _cmd_grep privileged | _cmd_awk '{print \$3}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with prctl.");
            $msg->log;
            $found = 0;
        }
    } else {
        $cmd_ret = $sys->cmd("_cmd_sysdef -i | _cmd_grep -i SEMMSL | _cmd_awk '{print \$1}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with sysdef.");
            $msg->log;
            $found = 0;
        }
    }
    # Valid for Solaris 9 and Solaris 10
    if (! $found ) {
        $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
    }
    if ($cmd_ret eq '') {
        $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}. Should be 256 or more.");
        $msg->log;
        $param_list->[++$counter] = "$param value is UNKNOWN. It should be equal to or more than 1024";
        $skipped = 1;
    } elsif ((0+$cmd_ret) < 256 ) {
        $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}.. Should be 256 or more.");
        $msg->log;
        $param_list->[++$counter] = "$param value is $cmd_ret. It should be equal to or more than 1024";
        $status = 1;
    } else {
        $msg = Msg::new("Kernel parameter $param is proper on $sys->{sys}");
        $msg->log;
        $status ||= 0;
    }


    if ($sys->{platvers} !~ /10/m && $sys->{platvers} =~ /11/m) {
        $found = 1;
        $param='semsys:seminfo_semvmx';
        $cmd_ret = $sys->cmd("_cmd_sysdef -i | _cmd_grep -i SEMVMX | _cmd_awk '{print \$1}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with sysdef.");
            $msg->log;
            $found = 0;
        }
        if (! $found ) {
            $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
        }
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}. Should be 32767 or more.");
            $msg->log;
            $param_list->[++$counter] = "$param value is UNKNOWN. It should be equal to or more than 32767";
            $skipped = 1;
        } elsif ((0+$cmd_ret) < 32767) {
            $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}. Should be 32767 or more.");
            $msg->log;
            $param_list->[++$counter] = "$param value is $cmd_ret. It should be equal to or more than 32767";
            $status = 1;
        } else {
            $msg = Msg::new("Kernel parameter $param is proper on $sys->{sys}");
            $msg->log;
            $status ||= 0;
        }


        $found = 1;
        $param='semsys:seminfo_semmns';
        $cmd_ret = $sys->cmd("_cmd_sysdef -i | _cmd_grep -i SEMMNS | _cmd_awk '{print \$1}'");
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is not found with sysdef.");
            $msg->log;
            $found = 0;
        }
        if (! $found ) {
            $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
        }
        if ($cmd_ret eq '') {
            $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}. Should be 1024 or more.");
            $msg->log;
            $param_list->[++$counter] = "$param value is UNKNOWN. It should be equal to or more than 1024";
            $skipped = 1;
        } elsif ((0+$cmd_ret) < 1024 ) {
            $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}. Should be 1024 or more.");
            $msg->log;
            $param_list->[++$counter] = "$param value is $cmd_ret. It should be equal to or more than 1024";
            $status = 1;
        } else {
            $msg = Msg::new("Kernel parameter $param is proper on $sys->{sys}.");
            $msg->log;
            $status ||= 0;
        }
    }


    # Others
    $param='noexec_user_stack';
    $cmd_ret = $sys->cmd("_cmd_cat /etc/system | _cmd_grep -v '^*' | _cmd_grep $param | _cmd_cut -d'=' -f2 | _cmd_head -1");
    if ($cmd_ret eq '') {
        $msg = Msg::new("Kernel parameter $param is UNKNOWN on $sys->{sys}. Should be set to 1.");
        $msg->log;
        $param_list->[++$counter] = "$param value is UNKNOWN. It should be 1";
        $skipped = 1;
    } elsif ((0+$cmd_ret) != 1) {
        $msg = Msg::new("Kernel parameter $param is NOT proper on $sys->{sys}. Should be set to 1.");
        $param_list->[++$counter] = "$param value is $cmd_ret. It should be 1";
        $status = 1;
    } else {
        $msg = Msg::new("Kernel parameter $param is proper on $sys->{sys}");
        $msg->log;
        $status ||= 0;
    }

    if ($skipped && !$status) {
        $status =2;
        $msg = Msg::new("Status of some kernel parameters is unknown. Refer to Oracle documentation to set them properly if they are invalid.");
        $msg->log;
    } elsif ( $status == 1 ) {
        $msg = Msg::new("Some kernel parameters are set wrong. Refer to Oracle documentation to set them properly.");
        $msg->log;
    }
    return $status;
}


# For Some LLT link related checks, the interfaces meed to be plumbed.
# This routine plumbs them if they are not plumbed.
# [TBD] The devces are not umplumbed after the checks. Needs to be handled later.

sub plat_plumbdev_sys {
    my ($prod, $syslistref, @link, $sys, $res);

    $prod = shift;
    $prod = shift;
    $syslistref = shift;
    $res = 0;

    for my $sys (@{$syslistref}) {
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}' ");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}' ");

            $sys->cmd("_cmd_ifconfig '$link[0]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[0] is invalid or not plumbed. Trying to plumb.");
                $msg->log;
                $sys->cmd("_cmd_ifconfig '$link[0]' plumb 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg = Msg::new(" Problem in plumbing LLT interface $link[0]");
                    $msg->log;
                    $res = 1;
                } else {
                    $msg = Msg::new("Interface $link[0] is plumbed successfully");
                    $msg->log;
                }
            }

            $sys->cmd("_cmd_ifconfig '$link[1]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[1] is invalid or not plumbed. Trying to plumb.");
                $msg->log;
                $sys->cmd("_cmd_ifconfig '$link[1]' plumb 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg = Msg::new(" Problem in plumbing LLT interface $link[1]");
                    $msg->log;
                    $res = 1;
                } else {
                    $msg = Msg::new("Interface $link[1] is plumbed successfully");
                    $msg->log;
                }
            }

        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            $res = 1;
        }
    }
    return $res;
}



# Platform specific Code for checking if Oracle's
# libraries are linked properly with Symantec libraries.
# Current implementation assumes that all the cluster nodes
# are running the same OS on same ARCH.
sub check_liblink_sys {
    my ($prod, $sys, $crshome, $orahome, $oraversion, $status);
    my ($arch, $lib_dir64, $msg);
    my ($lib_skgxp, $lib_odm, $vcsmm_lib);
    my ($vcsipc_lib, $cmd_ret, $odm_lib, $oracle_num);

    $prod = shift;
    $sys = shift;
    $crshome = shift;
    $orahome = shift;
    $oraversion = shift;

    if (($oraversion =~ /11.1/m) ||
        ($oraversion =~ /11.2/m)) { # Keep adding 11.2, 11.3 here as they get realesed
        $oracle_num = '11';
    }

    $status = 0;
    $arch = $sys->cmd('_cmd_uname -m');

    $msg = Msg::new("check_liblink_sys called with -> crshome:$crshome, orahome:$orahome, oracle_version:$oraversion, TARGETARCH: $arch");
    $msg->log;

    $lib_dir64 = $prod->{orabits};

    $lib_skgxp='libskgxp';
    $lib_odm='libodm';

    if ($oracle_num eq '11') {
        $msg = Msg::new("Skipping the IPC library check for Oracle version 11 on $sys->{sys}");
        $msg->log;
        $status ||= 0;
        goto SKIP_IPC;
    }

    # IPC library check.
    $vcsipc_lib = $sys->cmd("_cmd_ldd $orahome/bin/oracle | _cmd_grep $lib_skgxp | _cmd_awk '{print \$3}'");

    if ($vcsipc_lib eq '') {
        $cmd_ret = $sys->cmd("_cmd_nm $orahome/bin/oracle | _cmd_grep vcsipc_poll");
        if ($cmd_ret eq '') {
            $status ||= 1;
            $msg = Msg::new("IPC library linking check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status ||= 0;
            $msg = Msg::new("IPC library linking check on $sys->{sys} is OK");
            $msg->log;
        }
    } else {
        $cmd_ret = $sys->cmd("_cmd_nm $vcsipc_lib | _cmd_grep vcsipc_poll");
        if ($cmd_ret eq '') {
            $status ||= 1;
            $msg = Msg::new("IPC library linking check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status ||= 0;
            $msg = Msg::new("IPC library linking check on $sys->{sys} is OK");
            $msg->log;
        }
    }
SKIP_IPC:
    # VCSMM library check.
    $vcsmm_lib = $sys->cmd("LD_LIBRARY_PATH=$crshome/lib; export LD_LIBRARY_PATH; _cmd_ldd $crshome/bin/ocssd.bin | _cmd_grep 'libskgxn2' | _cmd_awk '{print \$3}'");
    if ($vcsmm_lib eq '') {
        $status ||= 1;
        $msg = Msg::new("VCSMM library check on $sys->{sys} has failed");
        $msg->log;
    } else {
        $cmd_ret = $sys->cmd("_cmd_strings $vcsmm_lib | _cmd_grep -i veritas");
        if ($cmd_ret eq '') {
            $status ||= 1;
            $msg = Msg::new("VCSMM library check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status ||= 0;
            $msg = Msg::new("VCSMM library check on $sys->{sys} is OK");
            $msg->log;
        }
    }

    # OBM library check.
    $odm_lib = $sys->cmd("_cmd_ldd $orahome/bin/oracle | _cmd_grep odm | _cmd_awk '{print \$3}'");
    if ($odm_lib eq '') {
        $status ||= 1;
        $msg = Msg::new("ODM library check on $sys->{sys} has failed");
        $msg->log;
    } else {
        $cmd_ret = $sys->cmd("_cmd_strings $odm_lib | _cmd_grep -i veritas");
        if ($cmd_ret eq '') {
            $status ||= 1;
            $msg = Msg::new("ODM library check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status ||= 0;
            $msg = Msg::new("ODM library check on $sys->{sys} is OK");
            $msg->log;

        }
    }

    return $status;
}


# Check link speed and Autonegotiation settings
sub check_mac_speed_autoneg_sys {
    my ($sys, $flag, @link, @instance, @autoneg, @speed, @mac, $ii, $summary, @dev, @devname, @devfile);
    my ($prod, $msg, $cmd_ret, %autoneg_status, %speed_status, %mac_status);
    my ($item, $desc, $status_autoneg, $status_speed, $status_mac, $phys);

    $prod = shift;
    $sys = shift;
    # $flag indicates if link1 and link2 have been
    # supplied or not.
    $flag = shift;

    if ($flag eq 1) {
        # Link name contains instance number as well
        $dev[0] = shift;
        $devname[0] = $dev[0];
        $devname[0] =~ s/^.*\///mx;
        
        $link[0] = $devname[0];
        $link[0] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
        $instance[0] = $devname[0];
        $instance[0] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;

        if ($sys->{padv} =~ /Sol11/m) {
            $devfile[0] = "/dev/net/".$devname[0];
        } else {
            $devfile[0] = "/dev/".$link[0].$instance[0];
        }

        $dev[1] = shift;
        $devname[1] = $dev[1];
        $devname[1] =~ s/^.*\///mx;
        
        $link[1] = $devname[1];
        $link[1] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
        $instance[1] = $devname[1];
        $instance[1] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;

        if ($sys->{padv} =~ /Sol11/m) {
            $devfile[1] = "/dev/net/".$devname[1];
        } else {
            $devfile[1] = "/dev/".$link[1].$instance[1];
        }

        $msg = Msg::new("LLT Link1 Name: $link[0]");
        $msg->log;
        $msg = Msg::new("LLT Link1 Instance number: $instance[0]");
        $msg->log;
        $msg = Msg::new("LLT Link2 Name: $link[1]");
        $msg->log;
        $msg = Msg::new("LLT Link2 Instance number: $instance[1]");
        $msg->log;
    } else {

        # Links not provided, get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $dev[0] = $sys->cmd("_cmd_grep '^[\\t ]*link[\\t ]' /etc/llttab | _cmd_sed -n '1p' | _cmd_awk '{print \$3}' | _cmd_sed 's/://g'");
            $devname[0] = $dev[0];
            $devname[0] =~ s/^.*\///mx;
            
            $link[0] = $devname[0];
            $link[0] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
            $instance[0] = $devname[0];
            $instance[0] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;
            
            if ($sys->{padv} =~ /Sol11/m) {
                $devfile[0] = "/dev/net/".$devname[0];
            } else {
                $devfile[0] = "/dev/".$link[0].$instance[0];
            }

            $dev[1] = $sys->cmd("_cmd_grep '^[\\t ]*link[\\t ]' /etc/llttab | _cmd_sed -n '2p' | _cmd_awk '{print \$3}' | _cmd_sed 's/://g'");
            $devname[1] = $dev[1];
            $devname[1] =~ s/^.*\///mx;
            
            $link[1] = $devname[1];
            $link[1] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
            $instance[1] = $devname[1];
            $instance[1] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;
            
            if ($sys->{padv} =~ /Sol11/m) {
                $devfile[1] = "/dev/net/".$devname[1];
            } else {
                $devfile[1] = "/dev/".$link[1].$instance[1];
            }

            $msg = Msg::new("LLT Link1 Complete Name: $devfile[0]");
            $msg->log;
            $msg = Msg::new("LLT Link1 Short Name: $devname[0]");
            $msg->log;
            $msg = Msg::new("LLT Link1 Instance number: $instance[0]");
            $msg->log;

            $msg = Msg::new("LLT Link2 Complete Name: $devfile[1]");
            $msg->log;
            $msg = Msg::new("LLT Link2 Short Name: $devname[1]");
            $msg->log;
            $msg = Msg::new("LLT Link2 Instance number: $instance[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            return 1;
        }
    }


    $item = 'Link Auto-Negotiation setting check';
    $desc = 'Checking Auto Negotiation setting';
    $status_autoneg = 1;
    # For link Auto-negotiation setting
    # [TBD] Today only supporting two LLT links
    for ($ii=0; $ii<2; $ii++) {
        if ( $sys->{padv} =~ /Sol11/m) {
            $phys = $sys->cmd("_cmd_dladm show-phys -p -o DEVICE $devname[$ii]");
            if ( $phys =~ /^vnet/mx) {
                return 3;
            }
            $autoneg[$ii] = $sys->cmd("_cmd_dladm show-linkprop -c -o VALUE -p adv_autoneg_cap $devname[$ii]");
        } else {
            $autoneg[$ii] = $sys->cmd("_cmd_kstat -m $link[$ii] -i $instance[$ii] 2>/dev/null | _cmd_grep -i 'adv_cap_autoneg' | _cmd_awk '{print \$2}' | _cmd_uniq");
        }
        if ($autoneg[$ii] eq '') {
            $msg = Msg::new("Could not get Auto Negotiation setting for $link[$ii]$instance[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Auto Negotiation setting for $link[$ii]$instance[$ii] is $autoneg[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    if (("$autoneg[0]" eq '') || ("$autoneg[1]" eq '')) {
        $autoneg_status{$sys} = "Could not get Auto Negotiation setting for $link[0]$instance[0] or $link[1]$instance[1] on $sys->{sys}.";
        $summary = "Could not get Auto Negotiation setting for $link[0]$instance[0] or $link[1]$instance[1] on $sys->{sys}.";
        $status_autoneg = 0;
    } elsif ("$autoneg[0]" eq "$autoneg[1]") {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0]$instance[0] and $link[1]$instance[1] are identical on $sys->{sys}.";
        $summary = "Auto Negotiation setting on $link[0]$instance[0] and $link[1]$instance[1] are identical on $sys->{sys}.";
    } else {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0]$instance[0] and $link[1]$instance[1] are not identical on $sys->{sys}.";
        $summary = "Auto Negotiation setting on $link[0]$instance[0] and $link[1]$instance[1] are not identical on $sys->{sys}.";
        $status_autoneg = 0;
    }

    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%autoneg_status);


    # For link speed
    $item = 'Link speed setting check';
    $desc = 'Checking link speed setting';
    $speed_status{$sys} = '';
    $summary='';
    $status_speed = 1;

    for ($ii=0; $ii<2; $ii++) {
        if ( $sys->{padv} =~ /Sol11/m) {
            $speed[$ii] = $sys->cmd("_cmd_dladm show-linkprop -c -o VALUE -p speed $devname[$ii]");
        }else {
            $speed[$ii] = $sys->cmd("_cmd_kstat -m $link[$ii] -i $instance[$ii] 2>/dev/null | _cmd_grep -i 'link_speed' | _cmd_awk '{print \$2}'");
        }
        if ($speed[$ii] eq '') {
            $msg = Msg::new("Could not get Speed setting for $link[$ii]$instance[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Speed setting for $link[$ii]$instance[$ii] is $speed[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    if ("$speed[0]" eq "$speed[1]") {
        $speed_status{$sys} = "Link speed setting on $link[0]$instance[0] and $link[1]$instance[1] are identical on $sys->{sys}.";
        $summary = "Link speed setting on $link[0]$instance[0] and $link[1]$instance[1] are identical on $sys->{sys}.";
    } else {
        $speed_status{$sys} = "Link speed setting on $link[0]$instance[0] and $link[1]$instance[1] are not identical on $sys->{sys}.";
        $summary = "Link speed setting on $link[0]$instance[0] and $link[1]$instance[1] are not identical on $sys->{sys}.";
        $status_speed = 0;
    }
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%speed_status);


    # For unique MAC address
    #
    # [TBD] Today we only check the uniqueness
    # on a node. In future, we might need to check
    # uniqueness across the cluster.
    $item = 'Unique MAC address check';
    $desc = 'Checking uniqueness for LLT links';
    $mac_status{$sys} = '';
    $summary='';
    $status_mac = 1;

    for ($ii=0; $ii<2; $ii++) {
        if (!$link[$ii] eq '') {
            # Try to get MAC address using ifconfig.
            $mac[$ii] = $sys->cmd("_cmd_ifconfig $link[$ii]$instance[$ii] 2>/dev/null | _cmd_grep -i 'ether' | _cmd_awk '{print \$2}'");
            if ($mac[$ii] eq '') {
                $msg = Msg::new("Could not get MAC address using ifconfig command for $link[$ii] on $sys->{sys}. Using getmac command to get MAC address.");
                $msg->log;
                # If failed, then try to get MAC address using getmac.
                if ($sys->exists('/opt/VRTSllt/getmac')) {
                    my $getmacop = $sys->cmd("/opt/VRTSllt/getmac $devfile[$ii] 2>/dev/null");
                    if (EDR::cmdexit()) {
                        $msg = Msg::new("Could not get MAC address using getmac command for $link[$ii] on $sys->{sys}. Perhaps the device /dev/$link[$ii]$instance[$ii] does not exist on $sys->{sys}. No other way remaining to get the MAC address. Skipping this check.");
                        $msg->log;
                        my $lltstatnvv = $sys->cmd('/sbin/lltstat -nvv 2>/dev/null');
                        $msg = Msg::new($lltstatnvv);
                        $msg->log;
                        last;
                    }
                    chomp($getmacop);
                    $mac[$ii] = (split(/\s+/m, $getmacop))[1];
                    if ("$mac[$ii]" eq '') {
                        $msg = Msg::new("Could not get MAC address using getmac command for $link[$ii] on $sys->{sys}. No other way remaining to get the MAC address. Skipping this check.");
                        $msg->log;
                        last;
                    } else {
                        $msg = Msg::new("MAC address for $link[$ii]$instance[$ii] is $mac[$ii]");
                        $msg->log;
                    }
                } else {
                    $msg = Msg::new("Could not get MAC address using getmac command for $link[$ii] on $sys->{sys}. /opt/VRTSllt/getmac command does not exist on $sys->{sys}. No other way remaining to get the MAC address. Skipping this check.");
        $msg->log;
                    last;
                }
            } else {
                $msg = Msg::new("MAC address for $link[$ii] is $mac[$ii]");
                $msg->log;
            }
        }
    }

    # [TBD] Today only supporting two LLT links.
    if (("$mac[0]" eq '') || ("$mac[1]" eq '')) {
        $mac_status{$sys} = "Some issues in getting MAC address for $link[0] or $link[1] on $sys->{sys}.";
        $summary = "Some issues in getting MAC address for $link[0] or $link[1] on $sys->{sys}.";
        $status_mac = 0;
    } elsif ("$mac[0]" eq "$mac[1]") {
        $mac_status{$sys} = "MAC addresses on $link[0]$instance[0] and $link[1]$instance[1] are identical on $sys->{sys}.";
        $summary = "MAC addresses on $link[0]$instance[0] and $link[1]$instance[1] are identical on $sys->{sys}.";
        $status_mac = 0;
    } else {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}.";
        $summary = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}.";
    }
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%mac_status);

    $msg = Msg::new("status_autoneg: $status_autoneg, status_speed: $status_speed, status_mac: $status_mac");
    $msg->log;
    return !($status_autoneg & $status_speed & $status_mac);
}

# Check links' full duplexity status
sub check_full_duplex_link_sys {
    # Array 'duplex' will have duplexity info for both the links
    my ($sys, $flag, @link, @duplex, $item, $desc, $status, $summary, @dev, @devname, @devfile);
    my ($cmd_ret, $ii, %duplex_status, $prod, $msg, $phys);

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    if ($flag == 1) {
        $dev[0] = shift;
        $devname[0] = $dev[0];
        $devname[0] =~ s/^.*\///mx;
        
        $link[0] = $devname[0];
        $link[0] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
        $instance[0] = $devname[0];
        $instance[0] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;

        if ($sys->{padv} =~ /Sol11/m) {
            $devfile[0] = "/dev/net/".$devname[0];
        } else {
            $devfile[0] = "/dev/".$link[0].$instance[0];
        }

        $dev[1] = shift;
        $devname[1] = $dev[1];
        $devname[1] =~ s/^.*\///mx;
        
        $link[1] = $devname[1];
        $link[1] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
        $instance[1] = $devname[1];
        $instance[1] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;

        if ($sys->{padv} =~ /Sol11/m) {
            $devfile[1] = "/dev/net/".$devname[1];
        } else {
            $devfile[1] = "/dev/".$link[1].$instance[1];
        }
        $link[0] = $devfile[0];
        $link[1] = $devfile[1];
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $dev[0] = $sys->cmd("_cmd_grep '^[\\t ]*link[\\t ]' /etc/llttab | _cmd_sed -n '1p' | _cmd_awk '{print \$3}' | _cmd_sed 's/://g'");
            $devname[0] = $dev[0];
            $devname[0] =~ s/^.*\///mx;
            
            $link[0] = $devname[0];
            $link[0] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
            $instance[0] = $devname[0];
            $instance[0] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;
            
            if ($sys->{padv} =~ /Sol11/m) {
                $devfile[0] = "/dev/net/".$devname[0];
            } else {
                $devfile[0] = "/dev/".$link[0].$instance[0];
            }

            $dev[1] = $sys->cmd("_cmd_grep '^[\\t ]*link[\\t ]' /etc/llttab | _cmd_sed -n '2p' | _cmd_awk '{print \$3}' | _cmd_sed 's/://g'");
            $devname[1] = $dev[1];
            $devname[1] =~ s/^.*\///mx;
            
            $link[1] = $devname[1];
            $link[1] =~ s/^(.*[a-zA-Z])[0-9]*$/$1/mx;
            $instance[1] = $devname[1];
            $instance[1] =~ s/^.*[a-zA-Z]([0-9]*)$/$1/mx;
            
            if ($sys->{padv} =~ /Sol11/m) {
                $devfile[1] = "/dev/net/".$devname[1];
            } else {
                $devfile[1] = "/dev/".$link[1].$instance[1];
            }

            $link[0] = $devfile[0];
            $link[1] = $devfile[1];

            $msg = Msg::new("LLT Link1 on $sys->{sys}: $devfile[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $devfile[1]");
            $msg->log;
            $msg = Msg::new("LLT Link1 Complete Name: $devfile[0]");
            $msg->log;
            $msg = Msg::new("LLT Link1 Instance number: $instance[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 Complete Name: $devfile[1]");
            $msg->log;
            $msg = Msg::new("LLT Link2 Instance number: $instance[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT link duplexity check cannot proceed for $sys->{sys}.");
            $msg->log;
            $cmd_ret = 2;
            $status = 0;
            $duplex_status{$sys} = "/etc/llttab is not present on $sys->{sys}. Skipping the test.";
            $summary = "/etc/llttab is not present on $sys->{sys}. Skipping the test.";
            goto SKIPPED;

        }
    }

    # Checking Duplex status (Half/Full) of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {
        if ($sys->{padv} =~ /Sol11/m) {
            $phys = $sys->cmd("_cmd_dladm show-phys -p -o DEVICE $devname[$ii]");
            if ( $phys =~ /^vnet/mx) {
                return 3;
            }
            $duplex[$ii] = $sys->cmd("_cmd_dladm show-linkprop  -c -o VALUE -p duplex $devname[$ii]");
        } else {
            if ($link[$ii] =~ /ce/m) {
                $duplex[$ii] = $sys->cmd("_cmd_kstat -m ce -i $instance[$ii] 2>/dev/null | _cmd_grep -i link_duplex | _cmd_awk '{print \$2}'");
            } else {
                $duplex[$ii] = $sys->cmd("_cmd_ndd -get $link[$ii] link_duplex");
            }

            if (EDR::cmdexit()) {
                $msg = Msg::new("Error in running 'ndd'. Open of $link[$ii] failed on $sys->{sys}.");
                $msg->log;
                $cmd_ret = 2;
                $status = 0;
                $duplex_status{$sys} = "Error in running 'ndd'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
                $summary = "Error in running 'ndd'. Open of $link[$ii] failed on $sys->{sys}. Skipping the test.";
                goto SKIPPED;
            } else {
                chomp($duplex[$ii]);
                if ((0+$duplex[$ii]) == 2) {
                    $msg = Msg::new("Link $link[$ii] is Full-Duplex on $sys->{sys}");
                    $msg->log;
                } elsif ((0+$duplex[$ii]) == 1) {
                    $msg = Msg::new("Link $link[$ii] is Half-Duplex on $sys->{sys}");
                    $msg->log;
                } else {
                    $msg = Msg::new("Link $link[$ii] is UNKNOWN on $sys->{sys}");
                    $msg->log;
                }
            }
        }
    }

    if (($duplex[0] == 2 && $duplex[1] == 2) || ($duplex[0] eq 'full' && $duplex[1] eq 'full')) {
        $status = 1;
        $duplex_status{$sys} = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $summary = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $cmd_ret = 0;
    } else {
        $status = 0;
        $duplex_status{$sys} = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}.";
        $summary = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}.";
        $cmd_ret = 1;
    }

SKIPPED:
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%duplex_status);
    return $cmd_ret;
}

# Check links' jumbo frame settings
# Jumbo frames are Ethernet frames with more than 1,500 bytes of payload (MTU)
# Thus, we'll check if all the links have same MTU setting
# They should also be between 1500 and 9200 Bytes
sub get_jumbo_frame_setting_sys {
    # Array 'jumbo' will have MTU info for both the links
    my ($sys, $flag, @link, @jumbo, $item, $desc, $status, $summary);
    my ($cmd_ret, $ii, %jumbo_frame_status, $prod, $msg, $errstr, $frsize);

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    $errstr = '';

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");

            $msg = Msg::new("LLT Link1 on $sys->{sys}: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT link jumbo frame check cannot proceed for $sys->{sys}.");
            $msg->log;
            return '-1';
        }
    }

    # Checking Jumbo Frame Setting of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {
        eval {$jumbo[$ii] = $sys->cmd("_cmd_netstat -i -I $link[$ii] 2>/dev/null | _cmd_grep $link[$ii] | _cmd_awk '{print \$2}'");};
        if ($jumbo[$ii] == '') {
            $errstr = $@;
            $msg = Msg::new("The NIC: $link[$ii] doesn't seem to be plumbed. Error info: $errstr");
            $msg->log;
            next;
        }
        chomp($jumbo[$ii]);
        if ($jumbo[$ii] =~ /\d\d\d\d/m && $jumbo[$ii] >= 1500 && $jumbo[$ii] <= 9200) {
            $msg = Msg::new("Link $link[$ii] has MTU = $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Link $link[$ii] has suspicious value of MTU: $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
            $msg = Msg::new("The NIC: $link[$ii] couldn't be probed for Jumbo Frame setting on $sys->{sys}. Skipping.");
            $msg->log;
            return '-1'; # Skipping the test
        }
    }
    $frsize = join(' ', @jumbo);
    return $frsize;
}


# Check if the given IP addr is plumed on a LLT link
# Hence making LLT link appear on public network
sub check_llt_link_public_sys {
    my ($sys, $ipaddr, $link1, $link2, $ret, @privipaddrs);
    my ($prod, $msg);

    $prod = shift;
    $sys = shift;
    $ipaddr = shift;
    $link1 = shift;
    $link2 = shift;

    $ret = 0;

    # if ($link1 !~ /^bge/ || $link2 !~ /^bge/) {
    #    $msg = Msg::new("Invalid values of LLT links passed on $sys->{sys}: $link1 and $link2");
    #    $msg->log;
    #    return 1;
    #}

    $sys->cmd("_cmd_ifconfig $link1 2>/dev/null");
    if (EDR::cmdexit()) {
        $msg = Msg::new("LLT link $link1: Invalid link or not plumbed on $sys->{sys} ");
        $msg->log;
        return 1;
    }
    $sys->cmd("_cmd_ifconfig $link2 2>/dev/null");
    if (EDR::cmdexit()) {
        $msg = Msg::new("LLT link $link2: Invalid link or not plumbed on $sys->{sys} ");
        $msg->log;
        return 1;
    }

    $privipaddrs[0] = $sys->cmd("_cmd_ifconfig $link1 2>/dev/null | _cmd_grep 'inet' | _cmd_awk '{print \$2}'");
    $privipaddrs[1] = $sys->cmd("_cmd_ifconfig $link2 2>/dev/null | _cmd_grep 'inet' | _cmd_awk '{print \$2}'");
    chomp($privipaddrs[0]);
    chomp($privipaddrs[1]);
    $msg = Msg::new("IP addr plumed on $link1: $privipaddrs[0]");
    $msg->log;
    $msg = Msg::new("IP addr plumed on $link2: $privipaddrs[1]");
    $msg->log;

    if ($ipaddr eq $privipaddrs[0]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link1");
        $msg->log;
        $ret = 1;
    } elsif ($ipaddr eq $privipaddrs[1]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link2");
        $msg->log;
        $ret = 1;
    }

    return $ret;
}


package Prod::SFRAC60::AIX;
@Prod::SFRAC60::AIX::ISA = qw(Prod::SFRAC60::Common);

sub init_plat {
    my $prod=shift;

    my $padv=$prod->padv();
    $padv->{cmd}{vxdctl}='/usr/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{mkfs}='/usr/sbin/mkfs';
    $padv->{cmd}{lsattr}='/usr/sbin/lsattr';

    $prod->{oratab} = '/etc/oratab';
    $prod->{cmd_nm_64} = '_cmd_nm -X64';

    $prod->{proddir}='sfrac';
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{upgradevers}=[qw(5.0.3 5.1)];
    $prod->{zru_releases}=[qw(5.0.3 5.1)];

    # Setting SF Oracle RAC/PADV specific variables here
    $prod->{lib_path} = '/opt/VRTSvcs/rac/lib64/';
    $prod->{bin_path} = '/opt/VRTSvcs/rac/bin/';
    $prod->{initdir} = '/etc/';
    $prod->{vendor_skgxn_path} = '/opt/ORCLcluster/lib';

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

sub determine_group {
    my ($prod, $sys, $user) = @_;
    my ($ret, $stat, $tmp);
    $stat = 0;

    $ret = $sys->cmd("_cmd_groups $user");
    chomp($ret);
    ($tmp, $tmp, $prod->{oracle_group}, $prod->{oracle_sgroups}) = split(/\s+/m, $ret, 4);
    chomp($prod->{oracle_sgroups});
    $stat = $stat || EDR::cmdexit();

    $ret = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$prod->{oracle_group}:'");
    chomp($ret);
    $prod->{oracle_gid} = (split(/:/m, $ret, 4))[2];
    $stat = $stat || EDR::cmdexit();

    return $stat;
}

sub create_oragrp {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupadd id=$ogid $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem adding Oracle group $og on $sys->{sys}");
        $msg->print;
        return 1;
    }
    $msg = Msg::new("Added Oracle group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub delete_group {
    my ($prod, $sys, $ogid, $og) = @_;
    my $msg;
    $sys->cmd("_cmd_groupdel $og");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Problem deleting group $og on $sys->{sys}");
        $msg->log;
        return 1;
    }
    $msg = Msg::new("Deleted group $og with GID $ogid on $sys->{sys}");
    $msg->log;
    return 0;
}

sub addnode_create_oragroup {
    my ($prod, $group, $gid, $systems_ref) = @_;
    my ($sys, $groupfile_entry, $pgid, $temp, $msg, $isfailed);

    $isfailed = 0;
    for my $sys (@{$systems_ref}) {
        $groupfile_entry = $sys->cmd("_cmd_cat /etc/group | _cmd_grep '^$group'");
        if (!$groupfile_entry) {
            $msg = Msg::new("Adding Oracle group $group with GID $gid on $sys->{sys}");
            $msg->left;
            $sys->cmd("_cmd_groupadd id=$gid $group");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $isfailed = 1;
                next;
            }
            Msg::right_done();
        }
    }

    return $isfailed;
}

sub create_ora_user_group {
    my ($prod, $sys, $ou, $og, $oh, $ouid, $ogid, $oshell, $user_exists, $group_exists, $orahome_exists) = @_;
    my $msg;
    my $basedir;
    my $ret = 0;

    goto SKIP_GROUP if($group_exists);
    return 1 if ($prod->create_oragrp($sys, $ogid, $og) == 1);

SKIP_GROUP:
    goto SKIP_CREATION if ($user_exists);
    if (!$sys->is_dir("$oh")) {
        $basedir = $sys->cmd("dirname $oh");
        $sys->cmd("mkdir -p $basedir");
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
    } else {
        $sys->cmd("_cmd_useradd -md $oh -g $ogid -u $ouid $ou");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Problem adding Oracle user $ou on $sys->{sys}");
            $msg->print;
            if (!$group_exists) {
                $msg = Msg::new("Trying to delete Oracle user: $ou if created");
                $msg->log;
                $sys->cmd("userdel $ou");
                $msg = Msg::new("Trying to delete Oracle group just created: $og");
                $msg->log;
                $prod->delete_group($sys, $ogid, $og);
            }
            return 1;
        }
        $sys->cmd("chown $ou:$og $oh");
        $sys->cmd("_cmd_chmod 755 $oh");
    }

SKIP_CREATION:
    $msg = Msg::new("Added Oracle user $ou with UID $ouid on $sys->{sys}");
    $msg->log;

    return 0;
}

# Modifies group information for a user
# Adding the given group for Oracle user
sub modify_group_info {
    my ($prod, $sys, $user, $group, $groupid) = @_;
    my (@old_group_names, $ret, $grp, $allgrps);

    $ret = $sys->cmd("_cmd_groups $user");
    return 1 if (EDR::cmdexit());
    chomp($ret);
    @old_group_names = split(/\s+/m, (split(/:/m, $ret))[1]);
    $allgrps = $group;
    for my $grp (@old_group_names) {
        chomp($grp);
        $allgrps = $allgrps.','.$grp if ($grp ne '');
    }

    $sys->cmd("_cmd_usermod -G $allgrps $user");
    return 1 if (EDR::cmdexit());

    return 0;
}

# Make and mount CFS
# Return[0] == 0 if everything went fine
sub make_mount_cfs {
    my ($prod, $dgname, $volname, $cfsmntpt, $master) = @_;
    my ($mk, $mkret, %mnt, %mntret);
    my ($sys, $ret);
    my $vxloc = '/dev/vx';

    $ret = 0;
    $mk = $master->cmd("_cmd_mkfs -V vxfs ${vxloc}/rdsk/${dgname}/${volname}");
    $mkret = EDR::cmdexit();

    for my $sys (@{CPIC::get('systems')}) {
    my $export_ret = $sys->cmd("ODMDIR=/etc/objrepos; export ODMDIR");
        $mnt{$sys} = $sys->cmd("_cmd_mount -V vxfs -o cluster,mntlock=VCS $vxloc/dsk/${dgname}/${volname} $cfsmntpt");
        $mntret{$sys} = EDR::cmdexit();
        $ret = $ret || $mntret{$sys};
    }

    $ret = $ret || $mkret;
    return ($ret, $mk, $mkret, %mnt, %mntret);
}

sub addnode_get_mntdev {
    my ($prod, $mpoint, $sys) = @_;
    my ($cmd, $mnt_dev);

    $cmd = "_cmd_mount | _cmd_grep -w $mpoint | _cmd_awk '{print \$1}'";
    $mnt_dev = $sys->cmd("$cmd");
    return $mnt_dev;
}

sub addnode_mount_dev {
    my ($prod, $mpoint, $dev, $nodes_ref) = @_;
    my ($sys, $cmd, $msg, $isfailed);

    $isfailed = 0;
    for my $sys (@{$nodes_ref}) {
        if (!$prod->addnode_get_mntdev($mpoint, $sys)) {
            $cmd = "_cmd_mount -V vxfs -o cluster $dev $mpoint";
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                $isfailed = 1;
            }
        }
    }
    return $isfailed;
}

sub check_fileset_prereqs {
    my @filesets = (
            'bos.adt.base',
            'bos.adt.lib',
            'bos.adt.libm',
            'bos.perf.libperfstat',
            'bos.perf.perfstat',
            'bos.perf.proctools',
            'perfagent.tools',
            'X11.motif.lib',
            'Java*',
            'rsct.basic.rte',
            'rsct.clients.rte',
            'rsct.compat.basic.rte',
            'rsct.compat.clients.rte'
    );
    my ($fileset_missing, $mfl, $sys, $file, $msg);
    $fileset_missing = '';
    $mfl = '';

    for my $sys (@{CPIC::get('systems')}) {
        $msg = Msg::new("Verifying fileset prerequisites on $sys->{sys}");
        $msg->left;
        for my $file (@filesets) {
            $sys->cmd("lslpp -l $file");
            if (EDR::cmdexit() != 0) {
                $fileset_missing = "$file"." $fileset_missing";
                $msg = Msg::new("Fileset $file not installed on $sys->{sys}");
                $msg->log;
            } # if
        } # for $file

        if ($fileset_missing ne '') {
             $mfl = "$fileset_missing"."$mfl";
             $fileset_missing = '';
             Msg::right_failed();
        } else {
             Msg::right_done();
        } # if

    } # for $sys

    return $mfl;
}

sub compare_oracle_userid {
    my $prod = shift;
    my ($output, $sys, $userid, $local_userid, $idstr, $msg);

    $local_userid = '';

    $msg = Msg::new("Comparing Oracle UNIX user id on all systems");
    $msg->left;

    for my $sys (@{CPIC::get('systems')}) {
        $output = $sys->cmd("lsuser -f $prod->{oracle_user} | _cmd_grep -w id");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Error");
            $msg->right;
            return 1;
        }

        chomp($output);
        $msg = Msg::new("OUTPUT is $output");
        $msg->log;
        ($idstr, $userid) = split(/=/m, $output);
        if ($local_userid eq '') {
            $local_userid = $userid;
            next;
        }

        $msg = Msg::new("userid is $userid, local_userid is $local_userid");
        $msg->log;

        if ($userid ne $local_userid) {
            $msg = Msg::new("Error");
            $msg->right;
            return 1;
        }
    } # for

    $msg = Msg::new("ok");
    $msg->right;

    return 0;
}

sub compare_oracle_groupid {
    my $prod = shift;
    my ($output, $sys, $groupid, $local_groupid, $idstr, $msg);
    $local_groupid = '';

    $msg = Msg::new("Comparing Oracle UNIX group id on all systems");
    $msg->left;

    for my $sys (@{CPIC::get('systems')}) {
        $output = $sys->cmd("lsgroup -f $prod->{oracle_group} | _cmd_grep -w id");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Error");
            $msg->right;
            return 1;
        }

        chomp($output);
        $msg = Msg::new("OUTPUT is $output");
        $msg->log;
        ($idstr, $groupid) = split(/=/m, $output);
        if ($local_groupid eq '') {
            $local_groupid = $groupid;
            next;
        }

        $msg = Msg::new("groupid is $groupid, local_groupid is $local_groupid");
        $msg->log;

        if ($groupid ne $local_groupid) {
            $msg = Msg::new("Error");
            $msg->right;
            return 1;
        }
    } # for

    $msg = Msg::new("ok");
    $msg->right;

    return 0;
}

sub create_install_files {
    my $prod = shift;
    my ($sys, $cid, $str, $msg,$tmpdir);

    $tmpdir=EDR::tmpdir();
    $msg = Msg::new("Retrieving cluster ID");
    $msg->left;
    $cid = EDR::cmd_local('/sbin/lltstat -C');
    if (EDR::cmdexit() != 0) {
        Msg::right_failed();
        return 1;
    }

    Msg::right_done();

    # Create a new file and write cluster id into it,
    # overwrite file, if already exists.
    EDRu::writefile($cid, "$tmpdir/cldomain");

    for my $sys (@{CPIC::get('systems')}) {
        $msg = Msg::new("Creating cldomain file on $sys->{sys}");
        $msg->left;

#        $str = "/usr/sbin/cluster/utilities";
#        $sys->cmd("_cmd_mkdir -p $str");
#        if (EDR::cmdexit() != 0) {
#            $msg = Msg::new("Error creating the directory $str on $sys\n");
#            $msg->print;
#            return 1;
#        }

        $str = '/usr/sbin/cluster/utilities/cldomain';
        #remove if already exists
#        $sys->cmd("_cmd_rm -f $str");
#        if (EDR::cmdexit() != 0) {
#            Msg::right_failed();
#            return 1;
#        }

        $prod->localsys->copy_to_sys($sys,"$tmpdir/cldomain","$str");

        $sys->cmd("_cmd_chmod 744 $str");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        Msg::right_done();
    } # for
    return 0;
}

sub addnode_copy_cldomain_file {
    my ($prod, $fname, $src, $dest) = @_;
    return $src->copy_to_sys($dest, $fname);
}

#
# This subroutine builds libskgxn2.a which is the membership library
# used by the Oracle's CRS daemons. There is a dependency on the object
# file named shr_skgxn2.o in the way oracle expects the library to have
# been built. We need to do the following to emulate it (both 32 and 64-bit):
# 1. copy libvcsmm.so to sh_skgxn2.o
# 2. archive the .o using the command: ar -qv -X64 libskgxn2.a sh_skgxn2.o
#
#TODO: Move the below work to packaging
sub build_skgxn_archive
{
    my $prod = shift;
    my ($sys, $ret, $msg);
    my $vcshome = '/opt/VRTSvcs';

    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd('/usr/sbin/slibclean');

        $msg = Msg::new("Archiving $prod->{abbr} libskgxn2.a on $sys->{sys}");
        $msg->left;

        #
        # Build 32-bit libskgxn2.a
        #
        $sys->cmd("_cmd_rm -f $vcshome/rac/lib/libskgxn2.a");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_ls $vcshome/rac/lib/libvcsmm.so");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_cp $vcshome/rac/lib/libvcsmm.so $vcshome/rac/lib/shr_skgxn2.o");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("ar -qv $vcshome/rac/lib/libskgxn2.a $vcshome/rac/lib/shr_skgxn2.o");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_ls $vcshome/rac/lib/libskgxn2.a");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_rm -f $vcshome/rac/lib/shr_skgxn2.o");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        #
        # Build 64-bit libskgxn2.a
        #
        $sys->cmd("_cmd_rm -f $vcshome/rac/lib64/libskgxn2.a");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_ls $vcshome/rac/lib64/libvcsmm.so");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_cp $vcshome/rac/lib64/libvcsmm.so $vcshome/rac/lib64/shr_skgxn2.o");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("ar -X64 -qv $vcshome/rac/lib64/libskgxn2.a $vcshome/rac/lib64/shr_skgxn2.o");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_ls $vcshome/rac/lib64/libskgxn2.a");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_rm $vcshome/rac/lib64/shr_skgxn2.o");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        Msg::right_done();

    } # for

    return 0;
}

#TODO: Move the below work to packaging
sub create_orcl_dir {
    my $prod = shift;
    my ($ret, $sys, $msg);
    my $cldir = '/opt/ORCLcluster';
    my $vcshome = '/opt/VRTSvcs';

    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd('/usr/sbin/slibclean');

        $msg = Msg::new("Copying libraries to $cldir on $sys->{sys}");
        $msg->left;

        $sys->cmd("_cmd_mkdir -p $cldir/lib32");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        # Copy in 32-bit libraries.
        $sys->cmd("_cmd_cp -f $vcshome/rac/lib/libskgxn2.a $cldir/lib32/libskgxn2.a");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_cp -f $vcshome/rac/lib/libskgxp10_ver25_32.so $cldir/lib32/libskgxp10.so");
        $sys->cmd("_cmd_cp -f $vcshome/rac/lib/libskgxp10_ver25_32.a $cldir/lib32/libskgxp10.a");
        $sys->cmd("_cmd_cp -f $vcshome/rac/lib/libvcsmm.so $cldir/lib32/libskgxn2.so");

        $sys->cmd("_cmd_mkdir -p $cldir/lib");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        # Copy in 64-bit libraries.
        $sys->cmd("_cmd_cp -f $vcshome/rac/lib64/libskgxn2.a $cldir/lib/libskgxn2.a");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $sys->cmd("_cmd_cp -f $vcshome/rac/lib/libskgxp10_ver25_64.so $cldir/lib/libskgxp10.so");
        $sys->cmd("_cmd_cp -f $vcshome/rac/lib/libskgxp10_ver25_64.a $cldir/lib/libskgxp10.a");
        $sys->cmd("_cmd_cp -f $vcshome/rac/lib64/libvcsmm.so $cldir/lib/libskgxn2.so");

        Msg::right_done();

    } # for

    return 0;
}

sub link_libskgxn {
    my ($prod, $skgxn_name, $crs_home) = @_;
    my ($sys, @cpnodes, $msg, $cmd);

    my $crsup = $prod->is_crs_up(CPIC::get('systems'));
    if ($crsup) {
        $msg = Msg::new("\nOracle Clusterware/Grid Infrastructure should be linked with Veritas Membership library. To link Oracle Clusterware/Grid Infrastructure, the Oracle Clusterware/Grid Infrastructure will be stopped.");
        $msg->print;
        $msg = Msg::new("Do you want to continue?");
        my $ayn = $msg->ayny;
        if ($ayn eq 'n' || $ayn eq 'N') {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s /opt/ORCLcluster/lib/libskgxn2.a $prod->{crs_home}/lib/libskgxn2.a \n\t ln -s /opt/ORCLcluster/lib/libskgxn2.so $prod->{crs_home}/lib/libskgxn2.so \n\t ln -s /opt/ORCLcluster/lib/libskgxnr.so $prod->{crs_home}/lib/libskgxnr.so \n3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        $cmd = "$crs_home/bin/crsctl stop crs";
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Stopping Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            } else {
                Msg::right_done();
            }
        }
        if (($failed_systems != 0) || ($prod->is_crs_up(CPIC::get('systems')))) {
            $msg = Msg::new("\nExecute following commands on all cluster nodes:\n 1. Stop Oracle Clusterware/Grid Infrastructure\n\t $crs_home/bin/crsctl stop crs \n 2. Link the Veritas Membership library to Oracle Clusterware/Grid Infrastructure home \n\t ln -s /opt/ORCLcluster/lib/libskgxn2.a $prod->{crs_home}/lib/libskgxn2.a \n\t ln -s /opt/ORCLcluster/lib/libskgxn2.so $prod->{crs_home}/lib/libskgxn2.so \n\t ln -s /opt/ORCLcluster/lib/libskgxnr.so $prod->{crs_home}/lib/libskgxnr.so \n3. Start Oracle Clusterware/Grid Infrastructure \n\t $crs_home/bin/crsctl start crs");
            Msg::prtc();
            return 1;
        }
    }
    $prod->link_vcsmm_lib($crs_home, $skgxn_name);
    $cmd = "$crs_home/bin/crsctl start crs";
    if ($crsup) {
        my $failed_systems = 0;
        for my $sys (@{CPIC::get('systems')}) {
            $msg = Msg::new("Starting Oracle Clusterware/Grid Infrastructure on $sys->{sys}");
            $msg->left;
            $sys->cmd("$cmd");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                $failed_systems++;
            }
            my $count = 0;
            my $crsup = 0;
            while ($count < 40) {
                $sys->cmd("$prod->{crs_home}/bin/crs_stat -t 2> /dev/null");
                if (!EDR::cmdexit()) {
                    $crsup = 1;
                    last;
                }
                sleep(3);
                $count++;
            }
            if ($crsup) {
                Msg::right_done();
            } else {
                Msg::right_failed();
                $failed_systems++;
            }
        }
        if ($failed_systems != 0) {
            $msg = Msg::new("Start Oracle Clusterware/Grid Infrastructure on failed systems:\n\t $crs_home/bin/crsctl start crs");
            $msg->print;
            Msg::prtc();
            return 0;
        }
    }

    return 0;
}

# Link the Veritas Membership library
# 'sub do_skgxn' in CPI
sub link_vcsmm_lib {
    my $prod = shift;
    my $crs_home = shift;
    my $skgxn_name = shift;
    my ($msg, $sys);
    my $vrtsgxn;
    my $orclgxn;
    my $crsgxn;
    my $TS = `date +%m%d%y_%H%M%S`;

    for my $sys (@{CPIC::get('systems')}) {
        $orclgxn = '/opt/ORCLcluster/lib/libskgxn2.a';
        $crsgxn = "$crs_home/lib/libskgxn2.a";
        $vrtsgxn = $prod->{lib_path}.'libskgxn2.a';

        if ($sys->exists($crsgxn)) {
            $msg = Msg::new("Linking Veritas skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_mv $orclgxn $orclgxn-$TS");
            $sys->cmd("_cmd_ln -s $vrtsgxn $orclgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }

            $msg = Msg::new("Linking Oracle skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_cp -rp $crsgxn $crsgxn-$TS");
            $sys->cmd("_cmd_mv $crsgxn $crsgxn-$TS");
            $sys->cmd("_cmd_ln -s $orclgxn $crsgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }
        }

        $orclgxn = '/opt/ORCLcluster/lib/libskgxn2.so';
        $crsgxn = "$crs_home/lib/libskgxn2.so";
        $vrtsgxn = $prod->{lib_path}.'libvcsmm.so';

        if ($sys->exists($crsgxn)) {
            $msg = Msg::new("Linking Veritas skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_mv $orclgxn $orclgxn-$TS");
            $sys->cmd("_cmd_ln -s $vrtsgxn $orclgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }

            $msg = Msg::new("Linking Oracle skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_mv $crsgxn $crsgxn-$TS");
            $sys->cmd("_cmd_ln -s $orclgxn $crsgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }
        }

        $orclgxn = '/opt/ORCLcluster/lib/libskgxnr.so';
        $crsgxn = "$crs_home/lib/libskgxnr.so";
        $vrtsgxn = $prod->{lib_path}.'libvcsmm.so';

        if ($sys->exists($crsgxn)) {
            $msg = Msg::new("Linking Veritas skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_mv $orclgxn $orclgxn-$TS");
            $sys->cmd("_cmd_ln -s $vrtsgxn $orclgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }

            $msg = Msg::new("Linking Oracle skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_cp -rp $crsgxn $crsgxn-$TS");
            $sys->cmd("_cmd_rm $crsgxn");
            $sys->cmd("_cmd_ln -s $orclgxn $crsgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }
        }

        $orclgxn = '/opt/ORCLcluster/lib/libskgxnr.a';
        $crsgxn = "$crs_home/lib/libskgxnr.a";
        $vrtsgxn = $prod->{lib_path}.'libskgxn2.a';

        if ($sys->exists($crsgxn)) {
            $msg = Msg::new("Linking Veritas skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_mv $orclgxn $orclgxn-$TS");
            $sys->cmd("_cmd_ln -s $vrtsgxn $orclgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }

            $msg = Msg::new("Linking Oracle skgxn library on $sys->{sys}");
            $msg->left;

            $sys->cmd("_cmd_cp -rp $crsgxn $crsgxn-$TS");
            $sys->cmd("_cmd_rm $crsgxn");
            $sys->cmd("_cmd_ln -s $orclgxn $crsgxn 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
            } else {
                Msg::right_done();
            }
        }
    }
    return;
}

sub copy_libodm {
    my ($prod, $homedir, $iscfs) = @_;
    my ($sys, @cpnodes, $msg);
    my $odmhome = '/opt/VRTSodm';

    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd('/usr/sbin/slibclean');
    } # for

    @cpnodes = ($iscfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $msg = Msg::new("Copying $prod->{abbr} ODM library on $sys->{sys}");
        $msg->left;

        if ($prod->{db_release} eq '10.2') {
            if ($prod->copy_and_replace($sys, "$odmhome/lib/libodm64.so",
                "$homedir/lib/libodm10.so") != 0) {
                Msg::right_failed();
                return 1;
            }
            $sys->cmd("_cmd_chmod 644 $homedir/lib/libodm10.so");
        } else { # 11G
            if ($prod->copy_and_replace($sys, "$odmhome/lib/libodm64.so",
                "$homedir/lib/libodm11.so") != 0) {
                Msg::right_failed();
                return 1;
            }
            $sys->cmd("_cmd_chmod 644 $homedir/lib/libodm11.so");
        }

        Msg::right_done();
     } # for

     return 0;
}

sub copy_libskgxp_per_ipcutil {
    my ($prod, $homedir, $iscfs) = @_;
    my ($sys, @cpnodes, $out, $output, $ipc_ver, $ora_skgxplib);
    my ($ipc_lib, $ora_rel, $ext_libs);
    my $msg;
    my $vcshome = '/opt/VRTSvcs';
    my $orauser = $prod->{oracle_user};
    my $oragrp = $prod->{oracle_group};
    my $tmpdir=EDR::tmpdir();

    #Do nothing for 11g
    if (($prod->{db_release} eq '11.1') ||
        ($prod->{db_release} eq '11.2')) {
        return 0;
    }

    $ora_rel = '10';
    $ext_libs = '-lcore10 -lodm -lpthread';

    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd('/usr/sbin/slibclean');
    } # for

    @cpnodes = ($iscfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $msg = Msg::new("Copying $prod->{abbr} skgxp on $sys->{sys}");
        $msg->left;
        $sys->cmd("_cmd_ls $homedir/lib/libskgxpg.a");
        if (EDR::cmdexit() == 0) {
            $ora_skgxplib = "$homedir/lib/libskgxpg.a";
        } else {
            $ora_skgxplib = "$homedir/lib/libskgxpu.a";
            $sys->cmd("_cmd_ls $homedir/lib/libskgxpu.a");
            if (EDR::cmdexit() != 0) {
                goto TRY_PATCH;
            }
        }

        $sys->cmd("/usr/bin/nm -X64 $ora_skgxplib | _cmd_grep vcsipc_poll");
        if (EDR::cmdexit() != 0) {
            my $timestamp = `date +%m%d%y_%H%M%S`;
            my ($ora_skgxplib_orcl) = "$ora_skgxplib.$timestamp";
            $msg = Msg::new("Backing up Oracle skgxp library on $sys->{sys}");
            $msg->log;
            $sys->cmd("_cmd_cp -rp $ora_skgxplib $ora_skgxplib_orcl");
        }

        $sys->cmd("_cmd_ls $vcshome/rac/bin/ipc_version_chk_static_64.o");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Could not find ipc_version_chk_static");
            $msg->log;
            goto TRY_PATCH;
        }

        $sys->cmd("/usr/bin/ld -b64 -o $tmpdir/ipc_version_check_static_64 $vcshome/rac/bin/ipc_version_chk_static_64.o /lib/crt0_64.o $ora_skgxplib -lc -L $homedir/lib -L $homedir/lib32 $ext_libs");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Failed to link ipc_version_chk");
            $msg->log;
            goto TRY_PATCH;
           }

        $ipc_ver = $sys->cmd("$tmpdir/ipc_version_check_static_64");
        $sys->cmd("_cmd_rm $tmpdir/ipc_version_check_static_64");
        chomp($ipc_ver);
        $ipc_ver =~ s/[\D]*//m;
        $ipc_lib = "$vcshome/rac/lib/libskgxp"."$ora_rel".'_ver'."$ipc_ver".'_64.a';
        $msg = Msg::new("Using ipc library: $ipc_lib");
        $msg->log;

        $sys->cmd("_cmd_ls $ipc_lib");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("Invalid IPC library $ipc_lib");
            $msg->log;
            goto TRY_PATCH;
        }

        if ($prod->copy_and_replace($sys, $ipc_lib, $ora_skgxplib) != 0) {
            $msg = Msg::new("Failed to link $ipc_lib to $ora_skgxplib");
            $msg->log;
            goto TRY_PATCH;
           }
        Msg::right_done();
        next;

TRY_PATCH:
        #
        # one of the relink scripts copies libskgxpu to libskgxp10
        # Hence copy and replace both.
        #
        if ($prod->copy_and_replace($sys,
            "$vcshome/rac/lib/libskgxp10_ver25_64.a",
            "$ora_skgxplib") != 0) {
            Msg::right_failed();
            return 1;
        }
        Msg::right_done();
    } # for

    return 0;
}

sub set_install_env {
    my ($prod, $release, $patch_level, $instpath) = @_;
    my ($sys, $msg);
    my $tmpdir=EDR::tmpdir();
    my $bs=EDR::get2('tput','bs');
    my $be=EDR::get2('tput','be');
    my $localsys=$prod->localsys;

    $prod->{oui_args} ='';
    $prod->{oui_export} = '';
    #
    # If SKIP_ROOTPRE is not set, invoke the rootpre.sh script.
    #
    if ((($release eq '10.2') && ($patch_level eq '0.1')) ||
        (($release eq '11.1') && ($patch_level eq '0.6')) ||
        (($release eq '11.2'))) { 
        if ($ENV{'SKIP_ROOTPRE'} eq 'TRUE') {
            $msg = Msg::new("SKIP_ROOTPRE environment variable is set. Will not invoke Oracle rootpre.sh script.");
            $msg->print;
        } else {
            my $is_failed = 0;
            for my $sys (@{CPIC::get('systems')}) {
                $msg = Msg::new("Invoking Oracle rootpre.sh on $sys->{sys}");
                $msg->left;
                $localsys->copy_to_sys($sys,"$instpath/rootpre","$tmpdir/rootpre");
                if (($release eq '11.1') ||
                    ($release eq '11.2')) {
                    $localsys->copy_to_sys($sys,"$instpath/rootpre.sh","$tmpdir/rootpre.sh");
                    $sys->cmd("cd $tmpdir; ./rootpre.sh");
                } else {
                    $sys->cmd("cd $tmpdir/rootpre; ./rootpre.sh");
                }
                if (EDR::cmdexit() != 0) {
                    Msg::right_failed();
                    $is_failed = 1;
                } else {
                    Msg::right_done();
                }
            } # for

            if ($is_failed == 1) {
                my $rootpre_loc;
                if (($release eq '11.1') ||
                    ($release eq '11.2')) {
                    $rootpre_loc = "$instpath";
                } else {
                    $rootpre_loc = "$instpath/rootpre";
                }

                $msg = Msg::new("The rootpre.sh command failed on one or more systems. For installation to proceed, Oracle requires\nyou to run the rootpre.sh script located under $rootpre_loc.\nRun it manually on these systems.\n");
                $msg->print;
                goto DNA_ROOTPRE if (Cfg::opt('responsefile'));
                $msg = Msg::new("Press <RETURN> here after running rootpre.sh:");
                print "\n$bs$msg->{msg}$be ";
                <STDIN>;
            } # is_failed
            $prod->{oui_export} = 'export SKIP_ROOTPRE=TRUE;';
        } # if SKIP_ROOTPRE
    } else {
        if ($ENV{'SKIP_SLIBCLEAN'} eq 'TRUE') {
            $msg = Msg::new("SKIP_SLIBCLEAN environment variable is set. Will not invoke slibclean.");
            $msg->print;
        } else {
            my $is_failed = 0;
            my $slib_clean = 1;
            for my $sys (@{CPIC::get('systems')}) {
                $msg = Msg::new("Invoking slibclean on $sys->{sys}");
                $msg->left;
                $sys->cmd('/usr/sbin/slibclean');
                if (EDR::cmdexit() != 0) {
                    Msg::right_failed();
                    $is_failed = 1;
                } else {
                    Msg::right_done();
                }

                if ($is_failed == 1) {
                    $msg = Msg::new("The /usr/sbin/slibclean command failed on one or more systems. For installation to proceed, Oracle requires\nyou to run this command. Run it manually on these systems.\n");
                    $msg->print;
                    if (Cfg::opt('responsefile')) {
                        $slib_clean = 0;
                        next;
                    }
                    $msg = Msg::new("Press <RETURN> here after running slibclean command:");
                    print "\n$bs$msg->{msg}$be ";
                    <STDIN>;
                } # is_failed
            } # for
            $prod->{oui_export} = 'export SKIP_SLIBCLEAN=TRUE;' if ($slib_clean);
        } # if SKIP_SLIBCLEAN
    } # if release

DNA_ROOTPRE:
    if (($release eq '11.1') || ($release eq '11.2')) {
        for my $sys (@{CPIC::get('systems')}) {
            my $argstr = $sys->cmd('/usr/sbin/lsattr -l sys0 -a ncargs -E');
            my $argsz = EDR::cmd_local("echo $argstr | _cmd_awk '{print \$2}'" );
            if ($argsz < 128) {
                $msg = Msg::new("Changing system ncargs on $sys->{sys} to 128\n");
                $msg->left;
                $sys->cmd('/usr/sbin/chdev -l sys0 -a ncargs=128');
                if (EDR::cmdexit() != 0) {
                    Msg::right_failed();
                    $msg = Msg::new("/usr/sbin/chdev command failed on $sys->{sys}\n");
                    $msg->log;
                    return 1;
                }
                Msg::right_done();
            }
        } # for
    }

    # Set the user capabilities for oracle user
    if ((($release eq '10.2') && ($patch_level eq '0.4')) ||
        ($release eq '11.1') || ($release eq '11.2')) {
        for my $sys (@{CPIC::get('systems')}) {
            my $attrstr = $sys->cmd("lsuser -a capabilities $prod->{oracle_user}");
            if (($attrstr !~ /CAP_NUMA_ATTACH/m) ||
                ($attrstr !~ /CAP_BYPASS_RAC_VMM/m) ||
                ($attrstr !~ /CAP_PROPAGATE/m)) {
                $msg = Msg::new("Changing oracle user\'s capabilities on $sys->{sys}");
                $msg->left;
                $sys->cmd("chuser capabilities=CAP_BYPASS_RAC_VMM,CAP_PROPAGATE,CAP_NUMA_ATTACH $prod->{oracle_user}");
                if (EDR::cmdexit() != 0) {
                    Msg::right_failed();
                    $msg = Msg::new("chuser command failed on $sys->{sys}\n");
                    $msg->log;
                    return 1;
                }
                Msg::right_done();
            } #if
        } # for
    } #if release

    if (($release eq '10.2') && ($patch_level eq '0.3')) {
        $prod->{oui_args} = '-ignoresysprereqs ';
    }

    return 0;
}

sub set_crs_install_env {
    my $prod = shift;
    my ($ayn,$ip,$ret,$sys,$msg);
    my $crshome = $prod->{crs_home};
    #
    # Verify that the required filesets are installed.
    #
    #$ret = $prod->check_fileset_prereqs();
    #if ($ret ne "") {
    #    $msg=Msg::new("The following filesets are missing: $ret\n");
    #    $msg->print;
    #    return 1 if (Cfg::opt("responsefile"));
    #    $msg = Msg::new("Do you wish to continue anyway?");
    #    $ayn = $msg->ayny;
    #    if ($ayn eq "n" || $ayn eq "N") {
    #        return 1;
    #    }
    #}

    #
    # Verify that Oracle user id is the same on all nodes.
    #
    #$ret = $prod->tsub("compare_oracle_userid");
    #if ($ret ne 0) {
    #    $msg = Msg::new("\nOracle user id is not the same on all nodes. Cannot proceed with installation.");
    #    $msg->print;
    #    Msg::prtc(); return;
    #}

    #
    # Verify that Oracle group id is the same on all nodes.
    #
    #$ret = $prod->tsub("compare_oracle_groupid");
    #if ($ret ne 0) {
    #    $msg = Msg::new("\nOracle group id is not the same on all nodes. Cannot proceed with installation.");
    #    $msg->print;
    #    Msg::prtc(); return;
    #}

    #
    # Create the filese required by Oracle's installer.
    #
    $ret = $prod->create_install_files();
    if ($ret ne 0) {
        return 1;
    }

    #
    # Create an archive of our vcsmm library.
    #
    #$ret = $prod->build_skgxn_archive();
    #if ($ret != 0) {
    #    return 1;
    #}

    #
    # create the ORCLcluster directory.
    #
    #$ret = $prod->create_orcl_dir();
    #if ($ret != 0) {
    #    return 1;
    #}

    $ret = $prod->set_install_env($prod->{crs_release}, $prod->{crs_patch_level},
                                  $prod->{crs_installpath});
    if ($ret != 0) {
        return 1;
    }
    return 0;
}

sub gen_ora_relink_script {
    my $prod = shift;
    my $ora_relink;
    my $orahome = $prod->{db_home};
    my $tmpdir=EDR::tmpdir();
    $ora_relink = "#!/usr/bin/ksh\n";
    $ora_relink .= "export LDR_CNTRL=MAXDATA=0x90000000\n";
    $ora_relink .= "export ORACLE_HOME=$orahome\n";
    $ora_relink .= "cd $orahome/rdbms/lib\n";
    $ora_relink .= "make -f ins_rdbms.mk rac_on\n";
    $ora_relink .= "if [ \$? -ne 0 ]; then\n";
    $ora_relink .= "\texit 1\n";
    $ora_relink .= "fi\n";
    $ora_relink .= "make -f ins_rdbms.mk ioracle\n";
    $ora_relink .= "if [ \$? -ne 0 ]; then\n";
    $ora_relink .= "\texit 1\n";
    $ora_relink .= "fi\n";
    $ora_relink .= "exit 0\n";

    EDRu::writefile($ora_relink, "$tmpdir/ora_relink");
    return;
}

sub do_relink_oracle {
    my ($prod, $iscfs) = @_;
    my ($out, $sys, @cpnodes, $ret, $msg);
    my $orahome = $prod->{db_home};
    my $orauser = $prod->{oracle_user};
    my $oragroup = $prod->{oracle_group};
    my $ts = `date +%m%d%y_%H%M%S`;
    my $ip;
    my $tmpdir=EDR::tmpdir();

    $msg = Msg::new("Creating Oracle relink script");
    $msg->left;
    $prod->gen_ora_relink_script();
    if (! -f "$tmpdir/ora_relink") {
        Msg::right_failed();
        return 1;
    }

    Msg::right_done();

    @cpnodes = ($iscfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $msg = Msg::new("Checking for env_rdbms.mk file on $sys->{sys}");
        $msg->left;
        $out = $sys->cmd("_cmd_ls $orahome/rdbms/lib/env_rdbms.mk");
        if ($out ne "$orahome/rdbms/lib/env_rdbms.mk") {
            Msg::right_failed();
            return 1;
        }
        Msg::right_done();
        #
        # Replace -lha_gs_r and -lha_em_r with spaces in env_rdbms.mk
        #

        if (($prod->{db_release} ne '11.1') &&
            ($prod->{db_release} ne '11.2')) {
            $sys->cmd("_cmd_cp $orahome/rdbms/lib/env_rdbms.mk $orahome/rdbms/lib/env_rdbms.mk.$ts");
            $sys->cmd("_cmd_chown $orauser:$oragroup $orahome/rdbms/lib/env_rdbms.mk.$ts");

            #
            # Replace -lha_gs_r and -lha_em_r with spaces in env_rdbms.mk
            #

            $sys->cmd("_cmd_sed 's/-lha_gs_r//g;s/-lha_em_r//g' $orahome/rdbms/lib/env_rdbms.mk > $orahome/rdbms/lib/env_rdbms.mk.tmp ");
            $msg = Msg::new("Updating env_rdbms.mk file on $sys->{sys}");
            $msg->left;
            $sys->cmd("_cmd_cp $orahome/rdbms/lib/env_rdbms.mk.tmp $orahome/rdbms/lib/env_rdbms.mk");
            if (EDR::cmdexit() != 0) {
                Msg::right_failed();
                return 1;
            }
            Msg::right_done();
            $sys->cmd("_cmd_chown $orauser:$oragroup $orahome/rdbms/lib/env_rdbms.mk");
            $sys->cmd("_cmd_rm $orahome/rdbms/lib/env_rdbms.mk.tmp");
        }

        #
        # Relink Oracle.
        #
        $msg = Msg::new("Relinking Oracle on $sys->{sys}");
        $msg->left;
        if (! $sys->{islocal}) {
            $prod->localsys->copy_to_sys($sys,"$tmpdir/ora_relink","$tmpdir/ora_relink");
        }

        $sys->cmd("_cmd_chmod 755 $tmpdir");
        $sys->cmd("_cmd_chmod 744 $tmpdir/ora_relink");
        $sys->cmd("_cmd_chown $orauser:$oragroup $tmpdir/ora_relink");
        $prod->save_term;
        $sys->cmd("_cmd_su $orauser -c $tmpdir/ora_relink");
        if (EDR::cmdexit() != 0) {
            Msg::right_failed();
            return 1;
        }

        $prod->restore_term;
        Msg::right_done();
    } # for

    return 0;
}

sub set_db_install_env {
    my $prod = shift;
    my $ret;
    #
    # Verify that Oracle user id is the same on all nodes.
    #
    #$ret = $prod->tsub("compare_oracle_userid");
    #if ($ret ne 0) {
    #    $msg = Msg::new("\nOracle user id is not the same on all nodes. Cannot proceed with installation.");
    #    $msg->print;
    #        Msg::prtc(); return;
    #}

    #
    # Verify that Oracle group id is the same on all nodes.
    #
    #$ret = $prod->tsub("compare_oracle_groupid");
    #if ($ret ne 0) {
    #    $msg = Msg::new("\nOracle group id is not the same on all nodes. Cannot proceed with installation.");
    #    $msg->print;
    #    Msg::prtc(); return;
    #}

    $ret = $prod->set_install_env($prod->{db_release}, $prod->{db_patch_level},
                                  $prod->{db_installpath});
    if ($ret != 0) {
        return 1;
    }

    return 0;
}

sub remove_liblltdb {
    my $prod = shift;
    my (@cpnodes, $sys);
    my $orahome = $prod->{db_home};
    my $oracfs = $prod->is_cfsmount($orahome);
    my $crshome = $prod->{crs_home};
    my $crscfs = $prod->is_cfsmount($crshome);

    for my $sys (@{CPIC::get('systems')}) {
        $sys->cmd('/usr/sbin/slibclean');
        $sys->cmd('_cmd_rm -f /opt/ORCLcluster/lib/liblltdb.so');
        $sys->cmd('_cmd_rm -f /opt/ORCLcluster/lib32/liblltdb.so');
    } # for

    @cpnodes = ($crscfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $sys->cmd("_cmd_rm -f $crshome/lib/liblltdb.so");
        $sys->cmd("_cmd_rm -f $crshome/lib32/liblltdb.so");
    } # for

    @cpnodes = ($oracfs) ? (${CPIC::get('systems')}[0]) : (@{CPIC::get('systems')});
    for my $sys (@cpnodes) {
        $sys->cmd("_cmd_rm -f $orahome/lib/liblltdb.so");
        $sys->cmd("_cmd_rm -f $orahome/lib32/liblltdb.so");
    } # for
}

sub relink_oracle {
    my $prod = shift;
    my ($ret, $ip, $msg);
    my $orahome = $prod->{db_home};
    my $oracfs = $prod->is_cfsmount($orahome);

    if ($prod->copy_libodm($orahome, $oracfs) != 0) {
        return 1;
    }

    if ($prod->copy_libskgxp_per_ipcutil($orahome, $oracfs) != 0) {
        return 1;
    }

    #
    # Relink Oracle
    #
    if ($prod->do_relink_oracle($oracfs) != 0) {
        return 1;
    }

    return 0;
}

sub get_skgxn_lib {
    my ($prod, $crshome, $db_release) = @_;
    my $skgxn_name = '';
    my $localsys = ${CPIC::get('systems')}[0];

    $skgxn_name = $localsys->cmd("LIBPATH=$crshome/lib; export LIBPATH; _cmd_ldd $crshome/bin/ocssd.bin | _cmd_grep 'libskgxn2'");
    if ($skgxn_name ne '') {
        # extract /crshome/lib/libskgxn2.a from /crshome/lib/libskgxn2.a(shr_skgxn2.o)
        my @tmp = split(/\(/m, $skgxn_name);
        $skgxn_name = $tmp[0];
        # extract libskgxn2.a from /crshome/lib/libskgxn2.a
        @tmp = split(/\//m, $skgxn_name);
        my $cnt = @tmp;
        $skgxn_name = $tmp[$cnt - 1];
    } else {
        if ($db_release eq '10.2') {
            $skgxn_name = 'libskgxn2.a';
        } else {
            $skgxn_name = 'libskgxn2.so';
        }
    }

    return $skgxn_name;
}

##################################################################################################
#                                                                                                #
#                       Platform specific prepu checks routines.                                 #
#                                                                                                #
##################################################################################################


sub plat_prepu_sfrac_defines {
    my $prod = shift;
    my $padv = $prod->padv();
    $padv->{cmd}{diff} = '/usr/bin/diff';
    $padv->{cmd}{vxfenadm} = '/sbin/vxfenadm';
    $padv->{cmd}{gabconfig} = '/sbin/gabconfig';
    $padv->{cmd}{lltstat} = '/sbin/lltstat';
    # [TBD] Not known the location of vcsmm on AIX
    #$prod->{cmd}{vcsmmconfig} = "/sbin/gabconfig";
    return;
}

# Check if DBAC package is present or not.
sub is_dbac_present {
    my ($prod, $ret, $sys);
    $prod = shift;
    $sys = shift;

    $ret = $sys->cmd('_cmd_lslpp -L 2>/dev/null | _cmd_grep dbac');
    if ($ret eq '') {
            return 0;
    } else {
            return 1;
    }
}


sub get_oslevel_sys {
    my ($prod, $sys, $msg, $os_ref, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    # use the $msg = Msg::new() for logging
    $msg = Msg::new("For os level of sfrac");
    $msg->log;

    eval {$os_ref = $sys->cmd('_cmd_oslevel -r ');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get os version and patch level error info :$errstr");
        $msg->log;
        return '';
    }

    return $os_ref;
}


# Platform specific code for checking the system architecture
sub get_archtype_sys {
    my ($prod, $sys, $archtype, $msg, $errstr);
    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get architecture type");
    $msg->log;

    eval {$archtype = $sys->cmd('_cmd_uname  -p');};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get architeture type, error info :$errstr");
        $msg->log;
        return '';
    }

    return $archtype;
}


# Platform specific code for checking processor speed.
sub get_cpuspeed_sys {
    my ($prod, $sys, $msg, $errstr);
    my ($cpuinfo, $cpuspeed, $cpucnt);

    $prod = shift;
    $sys = shift; # target host of the checking

    $errstr = '';

    $msg = Msg::new("get processor speed");
    $msg->log;

    #prtconf | more
    # <snippet>
    # Number Of Processors: 2            .
    # Processor Clock Speed: 1656 MHz        .
    #</snippet>

    eval {$cpuinfo = $sys->cmd("_cmd_prtconf 2> /dev/null | _cmd_grep 'Number Of Processors:'");};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get the processor count information, error info :$errstr");
        $msg->log;
        return '';
    }
    if($cpuinfo =~ "Number Of Processors:[\ ]+([0-9]+)") {
        $cpucnt = $1;
    }

    eval {$cpuinfo = $sys->cmd("_cmd_prtconf 2> /dev/null | _cmd_grep 'Processor Clock Speed:'");};
    $errstr = $@;
    if ($errstr) {
        $msg = Msg::new("Can't get the processor clock speed information, error info :$errstr");
        $msg->log;
        return '';
    }
    if($cpuinfo =~ "Processor Clock Speed:[\ ]+([0-9]+)[\ ]+MHz") {
        $cpuspeed = $1;
    }

    $cpuinfo = $cpuspeed;
    for(my $ii=1; $ii<$cpucnt; $ii++) {
        $cpuinfo = "$cpuinfo $cpuspeed";
    }
    return $cpuinfo;
}


# Platform specific code for checking if 'oprocd' is running
sub check_oprocd_sys {
    my ($prod, $sys, $oraversion, $cmd_ret, $status, $oprocd);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Check if for this $oraversion this check doesn't apply
    # (Applies only for version >= 10.2.0.4)
    # In that case return $status as 0
    if ($oraversion =~ /^9/m ||
        $oraversion =~ /10.1/m ||
        $oraversion =~ /10.2.0.1/m ||
        $oraversion =~ /10.2.0.2/m ||
        $oraversion =~ /10.2.0.3/m) { # !(Oracle 10.2.0.4 or 11g)
        return $status;
    }

    # If 'oprocd' check applies for the given $oraversion,
    # then check using 'ps' utility
    $oprocd = $sys->cmd("_cmd_ps -A | _cmd_grep 'oprocd' | _cmd_awk '{print \$4}'");
    chomp($oprocd);
    if ($oprocd eq 'oprocd' || $oprocd eq 'oprocd.bin' || $oprocd eq './oprocd.bin start') {
        $status = 1;
    }

    return $status;
}


# Platform specific Code for checking if init.cssd
# file has been patched properly
sub check_initcssd_sys {
    my ($sys, $oraversion, $cmd_ret, $status);

    $prod = shift;
    $sys = shift;
    $oraversion = shift;
    $status = 0;

    # Check if non-CRS clusterware
    if(!$sys->exists('/usr/sbin/cluster/utilities/cldomain')) {
        $status = 1;
    }
    # Check if Veritas Clusterware
    if (!$sys->exists('/opt/ORCLcluster/bin/clsinfo')) {
        $status = 1;
    }

    return $status;
}


# For Some LLT link related checks, the interfaces meed to be plumbed.
# This routine plumbs them if they are not plumbed.
# [TBD] The devces are not umplumbed after the checks. Needs to be handled later.

sub plat_plumbdev_sys {
    my ($prod, $syslistref, @link, $sys, $res);

    $prod = shift;
    $prod = shift;
    $syslistref = shift;
    $res = 0;

    for my $sys (@{$syslistref}) {
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}' ");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}' ");

            $sys->cmd("_cmd_ifconfig '$link[0]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[0] is invalid");
                $msg->log;
            }

            $sys->cmd("_cmd_ifconfig '$link[1]' 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("LLT interface $link[1] is invalid");
                $msg->log;
            }
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            $res = 1;
        }
    }
    return $res;
}


# Platform specific Code for checking if Oracle's
# libraries are linked properly with Symantec libraries.
sub check_liblink_sys {
    my ($sys, $crshome, $orahome, $oraversion, $ora_rel);
    my ($status, $vcshome, $odmhome, $prod, $msg);
    my ($ext_libs, $ora_skgxplib, $cmd_ret, $vcsmm_lib);

    $prod = shift;
    $sys = shift;
    $crshome = shift;
    $orahome = shift;
    $oraversion = shift;
    $vcshome = '/opt/VRTSvcs';
    $odmhome = '/opt/VRTSodm';
    $status=0;

    $msg = Msg::new("check_liblink_sys called with -> crshome:$crshome, orahome:$orahome, oracle_version:$oraversion");
    $msg->log;

    # IPC library check
    if ($oraversion =~ /11/m) {
        $status ||= 0;
        goto VCSMM_CHECK;
    } elsif ($oraversion !~ /10/m) {
        $msg = Msg::new("Unsupported Oracle version: $oraversion");
        $msg->log;
        return 1;
    }

    $cmd_ret = $sys->cmd("/usr/bin/nm -X64 $orahome/bin/oracle | _cmd_grep vcsipc_poll");
    if ($cmd_ret eq '') {
        $msg = Msg::new("skgxp library is NOT linked on $sys->{sys}");
        $msg->log;
        $status ||= 1;
        goto VCSMM_CHECK;
    } else {
        $msg = Msg::new("skgxp library is linked on $sys->{sys}");
        $msg->log;
        $status ||= 0;
    }

    # VCSMM library check
VCSMM_CHECK:

    # First checking if the lib files are present or not
    # If not, then jumping to ODM_CHECK, logging error
    if (!$sys->exists("$vcshome/rac/lib64/libskgxn2.a")) {
        $msg = Msg::new("Library file in VCS lib missing: $vcshome/rac/lib64/libskgxn2.a");
        $msg->log;
        $status ||= 1;
        goto ODM_CHECK;
    }

    $vcsmm_lib = $sys->cmd("LIBPATH=$crshome/lib; export LIBPATH; _cmd_ldd $crshome/bin/ocssd.bin | _cmd_grep 'libskgxn2'");
    if ($vcsmm_lib eq '') {
        $status ||= 1;
        $msg = Msg::new("VCSMM library check on $sys->{sys} has failed");
        $msg->log;
    } else {
        my @tmp = split (/\(/m, $vcsmm_lib);    #Taking only the archive file name.
        $vcsmm_lib = $tmp[0];
        $cmd_ret = $sys->cmd("_cmd_strings $vcsmm_lib | _cmd_grep -i veritas");
        if ($cmd_ret eq '') {
            $status ||= 1;
            $msg = Msg::new("VCSMM library check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status ||= 0;
            $msg = Msg::new("VCSMM library check on $sys->{sys} is OK");
            $msg->log;
        }
    }


    # ODM library check
ODM_CHECK:

    # First checking if the library file in ODM_HOME is present or not
    # If not, then skipping to SKIP_ODM
    if (!$sys->exists("$odmhome/lib/libodm64.so")) {
        $msg = Msg::new("ODM library file missing: $odmhome/lib/libodm64.so");
        $msg->log;
        $status ||= 1;
        goto SKIP_ODM;
    }

    # OBM library check.
    my $oranum;
    if ($oraversion =~ /11/m) {
        $oranum = 11;
    } elsif ( $oraversion =~ /10/m) {
        $oranum = 10;
    } else {
        $msg = Msg::new("Unsupported Oracle version: $oraversion");
        $msg->log;
        $status ||= 1;
        goto SKIP_ODM;
    }

    $odm_lib = "$orahome/lib/libodm".$oranum.'.so';        # Construct the odm library file name.

    if (! $sys->exists($odm_lib)) {
        $status ||= 1;
        $msg = Msg::new("ODM library check on $sys->{sys} has failed");
        $msg->log;
    } else {
        $cmd_ret = $sys->cmd("_cmd_strings $odm_lib | _cmd_grep -i veritas");
        if ($cmd_ret eq '') {
            $status ||= 1;
            $msg = Msg::new("ODM library check on $sys->{sys} has failed");
            $msg->log;
        } else {
            $status ||= 0;
            $msg = Msg::new("ODM library check on $sys->{sys} is OK");
            $msg->log;
        }
    }

SKIP_ODM:
    return $status;
}

# Check for kernel parameters that are
# required for Oracle RAC
# Return @param_list with the list of kernel parameters
# for which check failed.
sub plat_check_kernelparams_sys {
    my ($prod, $msg, $sys, $status, $cmd_ret, $counter, $param_list, $maxuprocval);

    $prod = shift;
    $sys = shift;
    $param_list = shift;
    $status = 0;
    $counter = -1;
    if ($oraversion =~ /11.2/m){
        $maxuprocval = 16384;
    }
    else {
        $maxuprocval = 2048;
    }

    $cmd_ret = $sys->cmd("_cmd_lsattr -E -l sys0 2>/dev/null | _cmd_grep maxuproc | _cmd_awk '{print \$2}'");
    if ("$cmd_ret" eq '') {
        $msg = Msg::new("maxuproc parameter's value is UNKNOWN");
        $msg->log;
        $param_list->[++$counter] = "maxuproc value is UNKNOWN on $sys->{sys}. It should be 16384 or more for oracle versions 11.2 or 2048 or more for oracle versions less than 11.2 ";
        $status = 1;
    } elsif ((0+$cmd_ret) < $maxuprocval) {
        $msg = Msg::new("maxuproc parameter's value is NOT as per the requirement on $sys->{sys}. It should be 16384 or more for oracle versions 11.2 or 2048 or more for oracle versions less than 11.2 ");
        $msg->log;
        $param_list->[++$counter] = "maxuproc value is NOT as per the requirement on $sys->{sys}. It should be 16384 or more for oracle versions 11.2 or 2048 or more for oracle versions less than 11.2.";
        $status = 1;
    } else {
        $msg = Msg::new("maxuproc parameter's value is as per the requirement");
    }

    return $status;
}

# Check link speed and Autonegotiation settings
sub check_mac_speed_autoneg_sys {
    my ($sys, $flag, @link, @autoneg, @speed, @mac, $ii, $summary);
    my ($prod, $msg, $cmd_ret, %autoneg_status, %speed_status, %mac_status);
    my ($item, $desc, $status_autoneg, $status_speed, $status_mac);

    $prod = shift;
    $sys = shift;
    # $flag indicates if link1 and link2 have been
    # supplied or not.
    $flag = shift;

    if ($flag eq 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {

        # Links not provided, get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");

            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");

            $msg = Msg::new("LLT Link1: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT Private Link check cannot proceed for $sys->{sys}.");
            $msg->log;
            return 1;
        }
    }

    my $skip_check = 0;
    if(is_vlan($sys, $link[0]) || is_vlan($sys, $link[1])) {
        $skip_check = 2;
        return $skip_check;
    }

    # For link Auto-negotiation setting
    $item = 'Link autonegotiation setting check';
    $desc = 'Checking Autonegotiation setting';
    $autoneg_status{$sys}='';
    $summary='';
    $status_autoneg = 1;

    # [TBD] Today only supporting two LLT links
    for ($ii=0; $ii<2; $ii++) {
        $autoneg[$ii]= $sys->cmd("_cmd_entstat -d $link[$ii] 2>/dev/null | _cmd_grep -i 'Auto negotiation'");
        if ($autoneg[$ii] eq '') {
            $msg = Msg::new("Could not get Auto Negotiation setting for $link[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Auto Negotiation setting for $link[$ii] is $autoneg[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    if ("$autoneg[0]" eq "$autoneg[1]") {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0] and $link[1] are identical on $sys->{sys}";
        $msg->log;
        $summary = "Auto Negotiation setting on $link[0] and $link[1] are identical on $sys->{sys}";
        $msg->log;
    } else {
        $autoneg_status{$sys} = "Auto Negotiation setting on $link[0] and $link[1] are not identical on $sys->{sys}";
        $msg->log;
        $summary = "Auto Negotiation setting on $link[0] and $link[1] are not identical on $sys->{sys}";
        $msg->log;
        $status_autoneg = 0;
    }

        $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%autoneg_status);

    # For link speed
    $item = 'Link speed setting check';
    $desc = 'Checking link speed setting';
    $speed_status{$sys} = '';
    $summary='';
    $status_speed = 1;

    for ($ii=0; $ii<2; $ii++) {
        $speed[$ii] = $sys->cmd("_cmd_entstat -d $link[$ii] 2>/dev/null | _cmd_grep -i 'Media Speed Running' | _cmd_awk '{print \$4}'");
        if ($speed[$ii] eq '') {
            $msg = Msg::new("Could not get Speed setting for $link[$ii] on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Speed setting for $link[$ii] is $speed[$ii] on $sys->{sys}");
            $msg->log;
        }
    }

    if ("$speed[0]" eq "$speed[1]") {
        $speed_status{$sys} = "Link speed setting on $link[0] and $link[1] are identical on $sys->{sys}";
        $summary = "Link speed setting on $link[0] and $link[1] are identical on $sys";
    } else {
        $speed_status{$sys} = "Link speed setting on $link[0] and $link[1] are not identical on $sys->{sys}";
        $summary = "Link speed setting on $link[0] and $link[1] are not identical on $sys->{sys}";
        $status_speed = 0;
    }
        $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%speed_status);

    # For unique MAC address
    #
    # [TBD] Today we only check the uniqueness
    # on a node. In future, we might need to check
    # uniqueness across the cluster.
    $item = 'Unique MAC address check';
    $desc = 'Checking uniqueness for LLT links';
    $mac_status{$sys} = '';
    $summary='';
    $status_mac = 1;

    for ($ii=0; $ii<2; $ii++) {
        if (!$link[$ii] eq '') {
            $mac[$ii] = $sys->cmd("_cmd_entstat $link[$ii] 2>/dev/null | _cmd_grep -i 'Hardware Address' | _cmd_awk '{print \$3}'");
            if ($mac[$ii] eq '') {
                $msg = Msg::new("Could not get MAC address for $link[$ii] on $sys->{sys}");
                $msg->log;
            } else {
                $msg = Msg::new("MAC address for $link[$ii] is $mac[$ii]");
                $msg->log;
            }
        }
    }

    # [TBD] Today only supporting two LLT links.
    if ("$mac[0]" eq "$mac[1]") {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are identical on $sys->{sys}";
        $summary = "MAC addresses on $link[0] and $link[1] are identical on $sys->{sys}";
        $status_mac = 0;
    } else {
        $mac_status{$sys} = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}";
        $summary = "MAC addresses on $link[0] and $link[1] are not identical on $sys->{sys}";
    }
        $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%mac_status);

    $msg = Msg::new("status_autoneg: $status_autoneg, status_speed: $status_speed, status_mac: $status_mac");
    $msg->log;
    return !($status_autoneg & $status_speed & $status_mac);
}

# Check links' full duplexity status
sub check_full_duplex_link_sys {
    # Array 'duplex' will have duplexity info for both the links
    my ($sys, $flag, @link, @duplex, $item, $desc, $status, $summary);
    my ($cmd_ret, $ii, %duplex_status, $prod, $msg);

    $prod= shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");
            if ($link[0] =~ /dev/m) {
                $link[0] =~ s/\/dev\///mg;
                $link[0] =~ s/://mg;
            }
            if ($link[1] =~ /dev/m) {
                $link[1] =~ s/\/dev\///mg;
                $link[1] =~ s/://mg;
            }
            $msg = Msg::new("LLT Link1 on $sys->{sys}: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT link duplexity check cannot proceed for $sys->{sys}");
            $msg->log;
            $cmd_ret = 2;
            $status = 0;
            $duplex_status{$sys} = "/etc/llttab is not present on $sys. Skipping the test.";
            $summary = "/etc/llttab is not present on $sys. Skipping the test.";
            goto SKIPPED;

        }
    }

    # Checking Duplex status (Half/Full) of the links
    # [TBD] Today supporting only two LLT links
    for ($ii = 0; $ii < 2; $ii++) {
        #$duplex[$ii] = $sys->cmd("_cmd_entstat -d $link[$ii] 2>/dev/null | _cmd_grep -i 'Duplex' | _cmd_awk '{print \$6}'");
        my @tmp  = $sys->cmd("_cmd_entstat -d $link[$ii] 2>/dev/null");
        @tmp = grep (/Duplex/, @tmp);        # Lines with the term Duplex.
        if ( grep (/Full/, @tmp)) {
            $duplex[$ii] = 'Full';
        } elsif (grep (/Half/, @tmp)) {
            $duplex[$ii] = 'Half';
        } else {
            $duplex[$ii] = 'non';
        }

        if (EDR::cmdexit()) {
            $msg = Msg::new("Error in running 'entstat'. Open of $link[$ii] failed on $sys->{sys}");
            $msg->log;
            $cmd_ret = 2;
            $status = 0;
            $duplex_status{$sys} = "Error in running 'entstat'. Open of $link[$ii] failed on $sys. Skipping the test.";
            $summary = "Error in running 'entstat'. Open of $link[$ii] failed on $sys. Skipping the test.";
            goto SKIPPED;
        } else {
            $msg = Msg::new("Link $link[$ii] is $duplex[$ii]-Duplex on $sys->{sys}");
            $msg->log;
        }
    }

    if ($duplex[0] eq 'Full' && $duplex[1] eq 'Full') {
        $status = 1;
        $duplex_status{$sys} = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $summary = "Both the Links $link[0] and $link[1] are Full-Duplex on $sys->{sys}.";
        $cmd_ret = 0;
    } else {
        $status = 0;
        $duplex_status{$sys} = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}.";
        $summary = "At least one of the Links $link[0] and $link[1] is not Full-Duplex on $sys->{sys}.";
        $cmd_ret = 1;
    }

SKIPPED:
    $prod->prepu_record_result($sys->{sys}, $item, $desc, $status, $summary, \%duplex_status);
    return $cmd_ret;

}

# Check links' jumbo frame settings
# Jumbo frames are Ethernet frames with more than 1,500 bytes of payload (MTU)
# Thus, we'll check if all the links have same MTU setting
# They should also be between 1500 and 9200 Bytes
sub get_jumbo_frame_setting_sys {
    # Array 'jumbo' will have MTU info for both the links
    my ($sys, $flag, @link, @jumbo, $item, $desc, $status, $summary);
    my ($cmd_ret, $ii, %jumbo_frame_status, $prod, $msg, $errstr, $frsize);
    

    $prod = shift;
    $sys = shift;
    $flag = shift; # Whether link1 and link2 have been supplied or not
    $item = shift;
    $desc = shift;

    $errstr = '';

    if ($flag == 1) {
        $link[0] = shift;
        $link[1] = shift;
    } else {
        # Links not provided; try to get them from /etc/llttab
        if ($sys->exists('/etc/llttab')) {
            $link[0] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_head -1 | _cmd_awk '{print \$2}'");
            $link[1] = $sys->cmd("_cmd_cat /etc/llttab | _cmd_grep link | _cmd_tail -1 | _cmd_awk '{print \$2}'");

            $msg = Msg::new("LLT Link1 on $sys->{sys}: $link[0]");
            $msg->log;
            $msg = Msg::new("LLT Link2 on $sys->{sys}: $link[1]");
            $msg->log;
        } else {
            $msg = Msg::new("/etc/llttab does not exist on $sys->{sys}. LLT link umbo frame check cannot proceed for $sys->{sys}");
            $msg->log;
            return '-1';
        }
    }

    # Checking Jumbo Frame Setting of the links
    # [TBD] Today supporting only two LLT links
    my $vcs=$prod->prod('VCS60');
    my $vnic = 0;
    if ($vcs->has_virtual_nic()) {
        $vnic = 1;
    }

    for ($ii = 0; $ii < 2; $ii++) {
        eval {$jumbo[$ii] = $sys->cmd("_cmd_netstat -i -I $link[$ii] 2>/dev/null | _cmd_grep $link[$ii] | _cmd_awk '{print \$2}' | _cmd_tail -1");};
        if ($jumbo[$ii] == '') {
            $errstr = $@;
            $msg = Msg::new("The NIC: $link[$ii] doesn't seem to be plumbed. Error info: $errstr");
            $msg->log;
            next;
        }
        chomp($jumbo[$ii]);
        if ($vnic && grep (/$link[$ii]/, @{$sys->{vionics}})) {
            $msg = Msg::new("$jumbo[$ii] is a virtual NIC");
            $msg->log;
            $msg = Msg::new("Link $link[$ii] has MTU = $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
            $msg = Msg::new("Changing the MTU to 1500 Bytes on $sys->{sys}");
            $msg->log;
            $jumbo[$ii] = 1500;
        }

        if ($jumbo[$ii] =~ /\d\d\d\d/m && $jumbo[$ii] >= 1500 && $jumbo[$ii] <= 9200) {
            $msg = Msg::new("Link $link[$ii] has MTU = $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
        } else {
            $msg = Msg::new("Link $link[$ii] has suspicious value of MTU: $jumbo[$ii] Bytes on $sys->{sys}");
            $msg->log;
            $msg = Msg::new("The NIC: $link[$ii] couldn't be probed for Jumbo Frame setting on $sys->{sys}! Skipping.");
            $msg->log;
            return '-1'; # Skipping the test
        }
    }
    $frsize = join(' ', @jumbo);
    return $frsize;
}

# Check if the given IP addr is plumed on a LLT link
# Hence making LLT link appear on public network
sub check_llt_link_public_sys {
    my ($prod, $msg, $sys, $ipaddr, $link1, $link2, $ret, @privipaddrs);

    $prod = shift;
    $sys = shift;
    $ipaddr = shift;
    $link1 = shift;
    $link2 = shift;

    $ret = 0;

    if ($link1 !~ /^en/m || $link2 !~ /^en/m) {
        $msg = Msg::new("Invalid values of LLT links passed on $sys->{sys}: $link1 and $link2");
        $msg->log;
        return 1;
    }

    $privipaddrs[0] = $sys->cmd("_cmd_ifconfig $link1 2>/dev/null | _cmd_grep 'inet' | _cmd_awk '{print \$2}'");
    $privipaddrs[1] = $sys->cmd("_cmd_ifconfig $link2 2>/dev/null | _cmd_grep 'inet' | _cmd_awk '{print \$2}'");
    chomp($privipaddrs[0]);
    chomp($privipaddrs[1]);
    $msg = Msg::new("IP addr plumed on $link1: $privipaddrs[0]");
    $msg->log;
    $msg = Msg::new("IP addr plumed on $link2: $privipaddrs[1]");
    $msg->log;

    if ($ipaddr eq $privipaddrs[0]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link1");
        $msg->log;
        $ret = 1;
    } elsif ($ipaddr eq $privipaddrs[1]) {
        $msg = Msg::new("Public IP addr $ipaddr is plumed on LLT link $link2");
        $msg->log;
        $ret = 1;
    }

    return $ret;
}

sub is_vlan {
    my ($sys,$nic) = @_;
    my $ret = $sys->cmd("/usr/sbin/lsdev | _cmd_grep -w $nic | _cmd_grep -i virtual");
    if($ret eq "") {
        return 0;
    } else {
        return 1;
    }
}

package Prod::SFRAC60::SolSparc;
@Prod::SFRAC60::SolSparc::ISA = qw(Prod::SFRAC60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1)];
    $prod->{zru_releases}=[qw(5.0.3 5.1)];
    $prod->{minimal_cpu_speed_requirment} = '1 GHz';
    return;
}

package Prod::SFRAC60::Sol11sparc;
@Prod::SFRAC60::Sol11sparc::ISA = qw(Prod::SFRAC60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{minimal_cpu_speed_requirment} = '1 GHz';
    $prod->{allpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    return;
}

package Prod::SFRAC60::Solx64;
@Prod::SFRAC60::Solx64::ISA = qw(Prod::SFRAC60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1)];
    $prod->{zru_releases}=[qw(5.0.3 5.1)];
    return;
}

package Prod::SFRAC60::Sol11x64;
@Prod::SFRAC60::Sol11x64::ISA = qw(Prod::SFRAC60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSdbac60 VRTSgms60 VRTSodm60 VRTSdbed60 VRTSvcsea60) ];
    return;
}

1;
