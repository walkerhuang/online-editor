use strict;

package Prod::SFCFSRAC60::Common;
@Prod::SFCFSRAC60::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{prod}='SFCFSRAC';
    $prod->{abbr}='SFCFS RAC';
    $prod->{obsoleted}=1;
    $prod->{vers}='6.0.000.000';
    $prod->{name}=Msg::new("Veritas Storage Foundation Cluster File System for Oracle RAC")->{msg};
    $prod->{proddir}='storage_foundation_cluster_file_system_for_oracle_rac';
    $prod->{eula}='EULA_SFCFS_Oracle_Rac_Ux_6.0.pdf';
    $prod->{mainpkg}='VRTScavf60';

    $prod->{extra_mainpkgs}=[ qw(VRTSvxvm60 VRTSvxfs60 VRTSvcs60 VRTSllt60 VRTSgab60 VRTSvxfen60 VRTSvcsag60)];

    $prod->{responsefileupgradeok}=1;
    $prod->{subprods}=[qw(VCS60 SF60)];

    $prod->{lic_names}=['Storage Foundation Cluster File System for Oracle RAC'];

    $prod->{menu_options}=['Veritas Volume Replicator'];

    $prod->{minimal_memory_requirment} = '2 GB';
    $prod->{minimal_swap_requirment} = '1 GB';
    $prod->{minimal_cpu_number_requirment} = 2;

    $prod->{cfsbin}='/opt/VRTS/bin';

    $prod->{has_poststart_config} = 1;
    $prod->{has_config} = 1;
    $prod->{multisystemserialpoststart}=1;

    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv VRTSamf VRTSsfmh VRTSvbs) ];

    my $padv=$prod->padv();
    $padv->{cmd}{cfscluster}="$prod->{cfsbin}/cfscluster";
    $padv->{cmd}{cfsdgadm}="$prod->{cfsbin}/cfsdgadm";
    $padv->{cmd}{cfsmntadm}="$prod->{cfsbin}/cfsmntadm";
    $padv->{cmd}{cfsmount}="$prod->{cfsbin}/cfsmount";
    $padv->{cmd}{cfsumount}="$prod->{cfsbin}/cfsumount";
    $padv->{cmd}{fsclustadm}="$prod->{cfsbin}/fsclustadm";
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

    $prod->pkgs_remove('VRTSdbed60');
    return $prod->{allpkgs};
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

sub perform_task_sys {
    my ($prod,$sys,$task) = @_;
    my ($sfcfs);

    $sfcfs=$prod->prod('SFCFSHA60');
    return $sfcfs->$task($sys);
}

sub perform_task {
    my ($prod,$task) = @_;
    my ($sfcfs);

    $sfcfs=$prod->prod('SFCFSHA60');
    return $sfcfs->$task();
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
    # TODO: diff from SFCFSHA. Will not asking whether to enable fencing?
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

sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_precheck_sys');
    return;
}

sub prestop_sys {
    my ($prod,$sys) = @_;
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
    my ($prod) = @_;
    return $prod->perform_task('check_config');
}

sub configure_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'configure_sys');
    return;
}

sub poststart_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'poststart_sys');
    return;
}

sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'upgrade_prestop_sys');
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
    $prod->perform_task_sys($sys,'upgrade_poststart_sys');
    return;
}

sub completion_messages {
    my $prod=shift;
    $prod->perform_task('completion_messages');
    return;
}

sub description {
    my ($msg);

    $msg=Msg::new("Veritas Storage Foundation Clustered File System for oracle RAC extends Veritas File System and Veritas Volume Manager to support shared data in a SAN environment. Using Veritas Storage Foundation Cluster File System, multiple servers can access shared storage and files, transparently to the applications and concurrently with each other.\n");
    $msg->print;
    return;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($pkgvers,$mpvers,$cpic,$rel,$pkg);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    return '' unless ($prod->{mainpkg});
    # Check license for the following options.
    return '' if (Cfg::opt(qw(install upgrade precheck patchupgrade addnode)) &&
                  (!$rel->prod_licensed_sys($sys,$prod->{prodi})));
    $pkg=$sys->pkg($prod->{mainpkg});
    $pkgvers=$pkg->version_sys($sys,$force_flag);
    $mpvers=$prod->{vers} if ($pkgvers && $prod->check_installed_patches_sys($sys,$pkgvers));
    $pkgvers= $prod->revert_base_version_sys($sys,$pkg,$pkgvers,$mpvers,$force_flag);
    return ($mpvers || $pkgvers);
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

sub startprocs {
    my $prod=shift;
    my $sfcfs = $prod->prod('SFCFSHA60');
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    my $ref_procs = Prod::startprocs($prod);
    $ref_procs=$sfcfs->reorder_vxglm($ref_procs);
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my ($sfcfs,$vm,$ref_procs);
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $vm = $prod->prod('VM60');
    $sfcfs = $prod->prod('SFCFSHA60');
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $vm->verify_procs_list_sys($sys,$ref_procs,'start');
    $ref_procs=$sfcfs->reorder_vxglm($ref_procs);
    return $ref_procs;
}

sub stopprocs {
    my $prod=shift;
    my ($ref_procs,$sfha);
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $sfha = $prod->prod('SFHA60');
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $sfha->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my ($ref_procs,$sfha);
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $sfha = $prod->prod('SFHA60');
    $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $sfha->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub addnode_poststart {
    my $prod = shift;
    my $sfcfs = $prod->prod('SFCFSHA60');
    $sfcfs->addnode_poststart();
    return;
}

##################################################################################################
#                                                                                                #
#                       Platform independent prepu checks' routines.                             #
#                                                                                                #
##################################################################################################


# Calling SFCFSRAC's sub prepucheck for several PrepU checks
# Excluding following:
# 1. VCSMM check
# 2. Oracle Integration check
# 3. LMX check
# 4. VCSMM port check under the GAB ports check

sub prepucheck {
        my $sfrac_upi = 'SFRAC';
        my $prod = shift;
        my $sysref = shift;
        my $upi = shift;
        my $vers = shift;
        my $is_sfcfsrac = 1;

        if ($vers eq '5.0MP2') {
                $vers = '5.0MP3'; # SFRAC not available for MP2
        }

        my $sfrac = $prod->prod('SFRAC60');
        my $err = $sfrac->prepucheck($is_sfcfsrac, $sysref, $upi, $vers);

        return $err;
}


package Prod::SFCFSRAC60::Linux;
@Prod::SFCFSRAC60::Linux::ISA = qw(Prod::SFCFSRAC60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60 VRTSvcsea60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60 VRTSvcsea60) ];
    $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60 VRTSvcsea60) ];
    $prod->{proddir}='storage_foundation_cluster_file_system_for_oracle_rac';
    $prod->{upgradevers}=[qw(4.1.40 5.0 5.1)];
    $prod->{zru_releases}=[qw(5.0.30 5.1)];
    $prod->{menu_options}=['Veritas Volume Replicator','Veritas File Replicator'];

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

1;