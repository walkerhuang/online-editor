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

package Prod::SFHA61::Common;
@Prod::SFHA61::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{prod}='SFHA';
    $prod->{abbr}='SFHA';
    $prod->{vers}='6.1.0.000';
    $prod->{proddir}='storage_foundation_high_availability';
    $prod->{eula}='EULA_SFHA_Ux_6.1.pdf';
    $prod->{name}=Msg::new("Symantec Storage Foundation and High Availability")->{msg};
    $prod->{subprods}=[qw(VCS61 SF61)];
    $prod->{menu_modes}=['SF Standard HA','SF Enterprise HA'];
    $prod->{default_mode}=0;
    $prod->{menu_options}=['Symantec Volume Replicator','Global Cluster Option'];
    $prod->{lic_names}=['Storage Foundation',
                        'Storage Foundation for Oracle',
                        'Storage Foundation for DB2',
                        'Storage Foundation for Sybase'];

    $prod->{minimal_memory_requirment} = '1 GB';
    $prod->{minimal_swap_requirment} = '1 GB';

    $prod->{responsefileupgradeok}=1;
    $prod->{multisystemserialpoststart}=1;

    $prod->{licsuperprods} = [ qw(SFCFSHA61) ];
    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv VRTSdbed VRTSamf VRTSsfmh VRTSvbs VRTSvcswiz) ];

    $prod->{extra_mainpkgs}=[qw(VRTSllt61 VRTSgab61 VRTSvxfen61 VRTSvcsag61)];

    my $padv=$prod->padv();
    $padv->{cmd}{odmclustadm}='/opt/VRTSodm/bin/odmclustadm';

    $prod->{has_config} = 1;
    $prod->{superprods} = [qw(SFRAC61 SVS61 SFSYBASECE61 SFCFSHA61)];

    return;
}

sub default_systemnames {
    my ($prod,$localsys,$vcs);
    $prod=shift;
    $localsys=$prod->localsys;
    # comments this out because on HPUX1131par, the padv between sys and prod are different
    #return '' if ($localsys->{padv} ne $prod->{padv});
    $vcs=$prod->prod('VCS61');
    return $vcs->default_systemnames;
}

sub is_rdma_supported {
    my ($prod) = @_;
    my ($vcs,$vcs_rtn);

    $vcs=$prod->prod('VCS61');
    $vcs_rtn=$vcs->is_rdma_supported() if ($vcs->can('is_rdma_supported'));
    return $vcs_rtn;
}

sub verify_responsefile {
    my ($prod) = @_;
    $prod->perform_task('verify_responsefile');
    return;
}

sub ask_upgrade_configure {
    my ($prod) = @_;
    $prod->perform_task('ask_upgrade_configure');
    return;
}

sub upgrade_rolling_post_sys {
    my ($prod,$sys)=@_;
    my ($syslist,$vcs,$msg,$sys1,$done_upgrade);

    $syslist=CPIC::get('systems');
    $vcs=$sys->prod('VCS61');
    #all systems are rolling_upgraded
    #check if post tasks are done.
    $msg=$sys->cmd('_cmd_cat /etc/gabtab');
    #return unless($msg=~/V/);
    $vcs->upgrade_rolling_post_sys($sys);
    for my $sys1 (@$syslist) {
        #$vcs=$sys1->proc("had61");
        #$vcs->tsub("stop_sys",$sys1);
        $msg=$sys1->cmd('_cmd_vxdctl -c mode 2>/dev/null');
        if($msg=~/cluster active - MASTER/m){
            $sys1->cmd('_cmd_vxdctl upgrade ');
            $done_upgrade=1;
        }
        $sys1->cmd('_cmd_fsclustadm protoclear');
        $sys1->cmd('_cmd_fsclustadm protoupgrade ');
        $sys1->cmd('_cmd_odmclustadm protoclear ');
        $sys1->cmd('_cmd_odmclustadm protoupgrade');
    }
    unless ($done_upgrade){
        $msg=Msg::new("Unable to upgrade CVM protocol version. Please make sure CVM is online on all the nodes in the cluster and run 'vxdctl upgrade' to complete the upgrade.");
        $msg->log;
    }
    return;
}

sub adjust_ru_procs {
    my $prod=shift;
    if(Cfg::opt('upgrade_nonkernelpkgs')){
        my $procs=[qw(had61 CmdServer61)];
        return $procs;
    }
}

sub ru_prestop_sys {
    my ($prod,$sys) = @_;
    my ($ver1,$ver2,$ver3,$output);
    my $vcs=$sys->prod('VCS61');

    if (Cfg::opt('upgrade_kernelpkgs')) {
        #$vcs->ru_prestop_sys($sys);
        $output=$sys->cmd('_cmd_vxdctl protocolversion 2>&1');
        $ver1=$1 if($output=~/Cluster\s+running\s+at\s+protocol\s+(\d+)/mx);
        $ver2=$sys->cmd("_cmd_fsclustadm protoversion 2>&1 | _cmd_awk '/local/ {print \$3}'");
        $ver3=$sys->cmd("_cmd_odmclustadm protoversion 2>&1 | _cmd_awk '/local/ {print \$3}'");

        #Stop had
        #$sys->cmd('_cmd_hastop -local -evacuate 2>/dev/null') if(Cfg::opt('ha'));

        $vcs->ru_prestop_sys($sys);
        #set fs/vm/odm version
        $sys->cmd("_cmd_vxdctl setversion $ver1 2>&1") if($ver1);
        $sys->cmd("_cmd_fsclustadm protoset $ver2 2>&1") if($ver2);
        $sys->cmd("_cmd_odmclustadm protoset $ver3 2>&1") if($ver3);
    }
    return;
}


sub check_config {
    my $prod = shift;
    return $prod->perform_task('check_config');
}

sub set_mode {
    my ($prod,$mode_id)=@_;
    $prod->{mode}= $prod->{menu_modes}->[$mode_id-1];
    if ($mode_id==1) {
        $prod->{menu_options}=['Symantec Volume Replicator'];
    }
    Cfg::set_opt('prodmode',$prod->{mode});
    return;
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

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($fs,$fspkg,$fs_vers,$vm,$vmpkg,$vm_vers,$vcs,$vcspkg,$vcs_vers);
    my ($vmwpkg,$vmwpkgvers,$mpvers,$cpic,$rel,$iv,$cv,$hp_os,$ret,$index);

    $cpic=Obj::cpic();
    $rel=$cpic->rel;

    # if $vcsvmwver <= 6.0.100.000 or $vcsvmwver >=6.1, it's AppHA.
    $vmwpkg = $sys->pkg('VRTSvcsvmw61',1);
    if ($vmwpkg) {
        $vmwpkgvers=$vmwpkg->version_sys($sys,$force_flag);
        return '' if ($vmwpkgvers && (!(EDRu::compvers($vmwpkgvers, '6.0.100.000', 3) == 1)
                                  || !(EDRu::compvers($vmwpkgvers, '6.1.000.000', 3) == 2)));
    }

    # Set $noconfig_vcs,$noconfig_sf config.
    $index=EDRu::arrpos($prod->{prodi},@{$sys->{upgradeprod}});
    $prod->set_partial_flag_sys($sys,$index);

    $vm=$sys->prod('VM61');
    $vmpkg=$sys->pkg($vm->{mainpkg});
    $vm_vers=$vmpkg->version_sys($sys,$force_flag);
    $fs=$sys->prod('FS61');
    $fspkg=$sys->pkg($fs->{mainpkg});
    $fs_vers=$fspkg->version_sys($sys,$force_flag);
    $vcs=$sys->prod('VCS61');
    $vcspkg=$sys->pkg($vcs->{mainpkg});
    $vcs_vers=$vcspkg->version_sys($sys,$force_flag);
    $mpvers=$prod->{vers} if ($vm_vers && $fs_vers && $prod->check_installed_patches_sys($sys,$vcs_vers));
    $fs_vers =$prod->revert_base_version_sys($sys,$fspkg,$fs_vers,$mpvers,$force_flag);
    $vm_vers =$prod->revert_base_version_sys($sys,$vmpkg,$vm_vers,$mpvers,$force_flag);
    $vcs_vers=$prod->revert_base_version_sys($sys,$vcspkg,$vcs_vers,$mpvers,$force_flag);
    # For 6.0.2, there's an exception that we need VRTSvcsvmw package version as vcs_vers.
    if ($sys->linux() && $vmwpkgvers) {
        # $vmwpkg have a version 6.0.100.000 < $vcsvmwver < 6.1.000.000
        # We'll use $vmwpkgver if it has a higher version than VRTSvcs package.
        $vcs_vers = $vmwpkgvers if (EDRu::compvers($vmwpkgvers,$vcs_vers) == 1);
    }

    $cv=EDRu::compvers($vcs_vers,$prod->{vers},2);

    # AIX-specific case
    if ($sys->aix() &&
        (substr($vm_vers,0,1) eq '3') && (substr($fs_vers,0,1) eq '3')) {
        if ($cv) {
            return $vcs_vers if ((substr($vcs_vers,0,1) eq '3') &&
                                 ($rel->prod_licensed_sys($sys,$prod->{prodi})));
        } else {
            return $vcs_vers if (substr($vcs_vers,0,1) eq '3');
        }
    }

    if (!EDRu::compvers($vm_vers,$fs_vers,2)) {
        if ($cv) {
            # e2058622/2063342.For upgrade from 4.1_11.23 to 5.1SP_11.31, need OS Upgrade, then VM version should be greater than vcs_version
            if ($sys->hpux() && EDRu::compvers($vm_vers,$vcs_vers,2)==1) {
                $ret=$sys->cmd("_cmd_swlist -a os_release $vcspkg->{pkg} 2>/dev/null | _cmd_grep '^# $vcspkg->{pkg}'");
                $hp_os=$1 if($ret =~ /(\d+\.\d+)/m);
                return ($mpvers || $vcs_vers) if ($hp_os && EDRu::compvers($hp_os,$sys->{platvers}) == 2 && $rel->prod_licensed_sys($sys,$prod->{prodi}));
            }
        } else {
            # SFHA is already upgraded.
            return ($mpvers || $vcs_vers) if (!EDRu::compvers($vm_vers,$vcs_vers,2));
        }
        # patch upgrade.
        # e.g. upgrade to 6.0RP1. VCS6.0+SF5.1/VCS5.1+SF6.0
        # only VCS6.0/SF6.0 should be upgraded to 6.0RP1.
        if (Cfg::opt(qw(patchupgrade hotfixupgrade))) {
            if (!EDRu::compvers($vm_vers,$vcs_vers,2) && ($rel->prod_licensed_sys($sys,$prod->{prodi}))) {
                return ($mpvers || $vcs_vers);
            }
        } elsif ($vcs_vers && $vm_vers && ($rel->prod_licensed_sys($sys,$prod->{prodi}))) {
            # normal upgrade + mix product upgrade
            # e.g. upgrade to 6.0.1. VCS6.0.1+SF6.0/VCS6.0+SF5.1SP1/SF6.0.1+VCS6.0/SF6.0+VCS5.1SP1
            # return SFHA(VCS's version). But later in upgrade_prod_mix_check()->upgrade_sfha_prods_mix_check()
            # the command $rel->upgrade_sfha_check_sys will determine which one to upgrade
            return ($mpvers || $vcs_vers);
        }
    }
    return '';
}

sub set_partial_flag_sys {
    my ($prod, $sys, $index)=@_;
    my($cmpvers,$sfvers,$vcsvers);
    return 0 unless ($prod->{prod}=~/SFHA/);
    return 0 if(Cfg::opt("upgrade_nonkernelpkgs"));
    return 0 if(Cfg::opt("rolling_upgrade") && !Cfg::opt(qw(upgrade_nonkernelpkgs upgrade_kernelpkgs)));
    $cmpvers = $prod->{vers};
    $sfvers = ${$sys->{prodvers}}[($index+1)];
    $vcsvers = ${$sys->{prodvers}}[($index+2)];
    if (!EDRu::compvers($sfvers,$cmpvers,4) && EDRu::compvers($vcsvers,$cmpvers,4)) {
        $sys->{noconfig_sf}=1;
        $sys->{prod_to_upgrade}=$prod->prod('VCS61');
    }
    if (!EDRu::compvers($vcsvers,$cmpvers,4) && EDRu::compvers($sfvers,$cmpvers,4)) {
        $sys->{noconfig_vcs}=1;
        $sys->{prod_to_upgrade}=$prod->prod('SF61');
    }
    return 0;
}

# returns all right now, could be HA/mode based
sub set_pkgs {
    my($prod,$rel,$vcs,$fs,$vm,$category,@categories);
    $prod=shift;

    $rel=$prod->rel;
    $vm=$prod->prod('VM61');
    $fs=$prod->prod('FS61');
    $vcs=$prod->prod('VCS61');

    # SF mode: basic, standard or enterprise?
    if ($prod->{mode} && $prod->{mode} eq 'SF Basic') {
        $prod->{allpkgs}=EDRu::arrdel($prod->{allpkgs},'VRTSdbed61','VRTSvcsea61','VRTSodm61');
        $prod->{recpkgs}=EDRu::arrdel($prod->{recpkgs},'VRTSdbed61','VRTSvcsea61','VRTSodm61');
    }

    @categories=qw(minpkgs recpkgs allpkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$rel->{$category}},
                                        @{$vm->{$category}},
                                        @{$fs->{$category}},
                                        @{$vcs->{$category}},
                                        @{$prod->{$category}});
    }

    @categories=qw(obsoleted_ga_release_pkgs
                   obsoleted_but_need_refresh_when_upgrade_pkgs
                   obsoleted_but_still_support_pkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$rel->{$category}},
                                        @{$prod->{$category}},
                                        @{$vcs->{$category}},
                                        @{$vm->{$category}},
                                        @{$fs->{$category}});
    }
    return $prod->{allpkgs};
}

sub cli_prod_option {
    my $prod=shift;
    my $vcs=$prod->prod('VCS61');
    $vcs->cli_prod_option();
    return;
}
sub web_prod_option {
    my $prod=shift;
    my $vcs=$prod->prod('VCS61');
    $vcs->web_prod_option();
    return;
}

sub perform_task_sys {
    my ($prod,$sys,$task) = @_;
    my ($sf_rtn,$vcs_rtn,$vcs,$sf);

    unless (($task =~ /upgrade/) && $sys->{noconfig_sf}) {
        $sf=$prod->prod('SF61');
        $sf_rtn=$sf->$task($sys) if ($sf->can($task));
    }

    unless (($task =~ /upgrade/) && $sys->{noconfig_vcs}) {
        $vcs=$prod->prod('VCS61');
        $vcs_rtn=$vcs->$task($sys) if ($vcs->can($task));
    }

    return;
}

sub perform_task {
    my ($prod,$task) = @_;
    my ($sf_rtn,$vcs_rtn,$vcs,$sf);

    $sf=$prod->prod('SF61');
    $sf_rtn=$sf->$task() if ($sf->can($task));

    $vcs_rtn=1;
    $vcs=$prod->prod('VCS61');
    $vcs_rtn=$vcs->$task() if ($vcs->can($task));

    return ($sf_rtn && $vcs_rtn);
}

sub install_precheck_sys {
    my ($prod,$sys) = @_;
    my ($vm,$vcs,$vm_vers,$vcs_vers,$msg,$vcs_configed);
    $prod->perform_task_sys($sys,'install_precheck_sys');

    # HA mode: check vcs and vm version consistence for partial upgrade
    $vm=$sys->prod('VM61');
    $vcs=$sys->prod('VCS61');
    $vm_vers=$vm->version_sys($sys);
    $vcs_vers=$vcs->version_sys($sys);
    $vcs_configed=$vcs->check_config($sys);
    if ($vm_vers && $vcs_vers) {
        if ( !EDRu::compvers($vm_vers,$prod->{vers},2) && EDRu::compvers($vcs_vers,$prod->{vers},2) && $vcs_configed ) {
            # SF is 5.1 while VCS is lower version and VCS is configured
            # $msg=Msg::new("$prod->{name} $vm_vers and $vcs->{name} $vcs_vers are installed on $sys->{sys}. To install SFHA $prod->{vers}, upgrade $vcs->{name} $vcs_vers to $prod->{vers} using the installvcs script or VCS product selection.");
            # $sys->push_error($msg);
            # $sys->{nosfconfig}=1;
        } elsif ( !EDRu::compvers($vm_vers,$prod->{vers},2) && EDRu::compvers($vcs_vers,$prod->{vers},2) && !$vcs_configed ) {
            # SF is 5.1 while VCS is lower version and VCS is NOT configured
            # $msg=Msg::new("$prod->{name} $vm_vers and $vcs->{name} $vcs_vers are installed on $sys->{sys}. $vcs->{name} is not configured. To install SFHA $prod->{vers}, uninstall $vcs->{name} $vcs_vers then install $vcs->{name} $prod->{vers} on $sys->{sys} directly.");
            # $sys->push_error($msg);
            $msg=Msg::new("$prod->{name} $vm_vers and $vcs->{name} $vcs_vers are installed on $sys->{sys}. $vcs->{name} is not configured. To install SFHA $prod->{vers}, configure $vcs->{name} $vcs_vers then install $prod->{name} $prod->{vers} on $sys->{sys} directly using installsfha script.");
            $sys->push_error($msg);
        } elsif ( EDRu::compvers($vm_vers,$prod->{vers},2) && !EDRu::compvers($vcs_vers,$prod->{vers},2)) {
            # VCS is 5.1 while SF is lower version
            # $msg=Msg::new("$prod->{name} $vm_vers and $vcs->{name} $vcs_vers are installed on $sys->{sys}. To install SFHA $prod->{vers}, upgrade $prod->{name} $vm_vers to $prod->{vers} using the installsf script or SF product selection.");
            # $sys->push_error($msg);
            # $sys->{novcsconfig}=1;
        }
    }
    return;
}

sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my $vcs;

    # check whether VCS need to be upgrade
    $vcs=$prod->prod('VCS61');
    $vcs->check_upgradeable_sys($sys);
    $prod->perform_task_sys($sys,'upgrade_precheck_sys');
    return;
}


sub prestop_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'prestop_sys'); }
sub preremove_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'preremove_sys'); }
sub postremove_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'postremove_sys'); }
sub preinstall_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'preinstall_sys'); }
sub postinstall_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'postinstall_sys'); }
sub configure_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'configure_sys'); }
sub prestart_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'prestart_sys'); }
sub hotfixupgrade_precheck_sys { my ($prod, $sys) = @_; $prod->perform_task_sys($sys,"hotfixupgrade_precheck_sys"); }

sub preremove_tasks {
    my $prod = shift;
    $prod->perform_task('preremove_tasks');
    return;
}

sub poststart_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'poststart_sys');
    if ($sys->exists("/opt/VRTS/install/.$prod->{prod}.upgrade")) {
        # Remove .<UPI>.upgrade file
        $sys->cmd("_cmd_rmr /opt/VRTS/install/.$prod->{prod}.upgrade 2>/dev/null");
    }
    return;
}


sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;
    $prod->upgrade_rolling_post_sys($sys) if($sys->system1 &&  Cfg::opt('upgrade_nonkernelpkgs'));
    $prod->ru_prestop_sys($sys) if(Cfg::opt('upgrade_kernelpkgs'));

    return $prod->perform_task_sys($sys, 'upgrade_prestop_sys');
}

sub upgrade_preremove_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_preremove_sys'); }
sub upgrade_postremove_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_postremove_sys'); }
sub upgrade_preinstall_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_preinstall_sys'); }
sub upgrade_postinstall_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_postinstall_sys'); }
sub upgrade_configure_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_configure_sys'); }
sub upgrade_poststart_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_poststart_sys'); }

sub description {
    my ($msg);

    $msg=Msg::new("Symantec Storage Foundation combines the industry-leading technologies of Veritas Volume Manager and Veritas File System to deliver powerful, online storage management, optimal performance tuning, and sophisticated management capabilities to ensure continuous availability of mission-critical data.\n");
    $msg->print;
    $msg=Msg::new("Symantec Storage Foundation QuickStart (FST-QS) offers a limited-function version of Symantec Storage Foundation for entry-level servers.  Symantec Storage Foundation QuickStart includes basic versions of Veritas Volume Manager and Veritas File System. FST-QS provides journal-based fast recovery, high performance, on-line management of volumes, and mirroring for boot drives. You can upgrade FST-QS to the feature-complete Symantec Storage Foundation with an additional license.\n");
    $msg->print;
    $msg=Msg::new("Symantec Storage Foundation HA adds Symantec Cluster Server for high availability, multi-node management. It also includes the same bundled agents for File System and Volume Manager as those typically included in VCS.");
    $msg->print;
    return;
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);

    $cpic = Obj::cpic();
    $rel = $cpic->rel;
    my ($features,$fv,$iv,$vcs,$vcsmainpkg,$vm);
    # HA mode: check
    $vcs = $sys->prod('VCS61');
    $vcsmainpkg=$prod->pkg($vcs->{mainpkg});
    $iv=$vcsmainpkg->version_sys($sys);
    $features = $rel->feature_values_sys($sys, 'Mode#VERITAS Cluster Server');
    # the following line is for SF+VCS keys don't have VCS embeded in the previous line
    # it's a fix for etrack 2792984
    $features = $rel->feature_values_sys($sys, 'Mode') if ($#$features < 0);
    for my $fv (@$features) {
        if ( ($fv =~ /VCS/m) && !EDRu::compvers($iv,$vcs->{vers},1)) {
            $vcs->is_features_licensed_sys($sys);
            last;
        }
    }
    # set vvr option per license check
    $vm=$sys->prod('VM61');
    $vm->vr_licensed_sys($sys);
    $vm->vfr_licensed_sys($sys);

    return $rel->prod_licensed_sys($sys, '');
}

sub startprocs {
    my $prod = shift;
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    my $ref_procs = Prod::startprocs($prod);
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my ($cfg,$vcs,$vm,$ref_procs);
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    $cfg =Obj::cfg();
    $vm = $prod->prod('VM61');
    $vcs = $sys->prod('VCS61');
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $vm->verify_procs_list_sys($sys,$ref_procs,'start');
    if (!$cfg->{vcs_allowcomms}) {
        $ref_procs = EDRu::arrdel($ref_procs, 'llt61', 'gab61', 'vxfen61');
    } elsif ((!$sys->exists("$vcs->{vxfenmode}")) && (!$sys->exists("$vcs->{vxfendg}"))) {
        $ref_procs = EDRu::arrdel($ref_procs, 'vxfen61');
    }
    return $ref_procs;
}

sub verify_procs_list {
    my ($prod,$procs,$state)=@_;
    my ($cpic,$sf,$vcs);

    $sf = $prod->prod('SF61');
    $procs = $sf->verify_procs_list($procs,$state);
    $vcs = $prod->prod('VCS61');
    $cpic=$Obj::pool{'CPIC'};
    $procs = $vcs->verify_procs_list($procs,$state)
        if ($cpic && $cpic->{prod} && $cpic->{prod}=~/^(SFHA|SVS|SFCFS|SFRAC)/mx);
    return $procs;
}

sub stopprocs {
    my ($cpic,$prod,$vcs,$ref_procs);
    $prod=shift;
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    if (Cfg::opt('configure')) {
        $vcs = $prod->prod('VCS61');
        return $vcs->stopprocs();
    }
    $cpic=$Obj::pool{'CPIC'};
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $prod->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub verify_procs_list_sys {
    my ($prod,$sys,$procs,$state)=@_;
    my ($sf,$vcs,$cprod);
    $cprod=CPIC::get('prod');
    $sf = $prod->prod('SF61');
    $procs = $sf->verify_procs_list_sys($sys,$procs,$state);
    $vcs = $prod->prod('VCS61');
    $procs = $vcs->verify_procs_list_sys($sys,$procs,$state)
        if ($cprod=~/^(SFHA|SVS|SFCFS|SFRAC)/mx);
    return $procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    return adjust_ru_procs if(Cfg::opt('upgrade_nonkernelpkgs'));
    if (Cfg::opt('configure')) {
        my $vcs = $prod->prod('VCS61');
        return $vcs->stopprocs_sys($sys);
    }
    my $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub addnode_poststart {
    my ($msg,$errmsg,$proc,$proci,$startprocs,$sys,$sysi,$src_sys,$src_sysi,$vcs,$vxfen,$novxfen);
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

    # eTrack 3131876
    # To start vxfen61 or not depends on whether source cluster has it configured
    $novxfen = 0;
    $src_sysi = ${$cfg->{clustersystems}}[0];
    $src_sys = Obj::sys($src_sysi);
    $vcs = $src_sys->prod('VCS61');
    if ((!$src_sys->exists("$vcs->{vxfenmode}")) && (!$src_sys->exists("$vcs->{vxfendg}"))) {
        $novxfen = 1;
    }
    $vxfen = $src_sys->proc('vxfen61');
    if ($vxfen->check_service_sys($src_sys)==0) {
        # vxfen svc is disabled on existing cluster nodes.
        # it should be disabled on newly added nodes too.
        $novxfen = 2;
    }

    # start SFHA processes
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $startprocs = $prod->startprocs_sys($sys);
        # exclude vxfen process for new node if source cluster is not configured with fencing
        if ($novxfen) {
            $startprocs = EDRu::arrdel($startprocs, 'vxfen61');
            if ($novxfen == 2) {
                if ($vxfen->can('disable_service_sys')) {
                    $vxfen->disable_service_sys($sys);
                }
            }
        }
        for my $proci (@{$startprocs}) {
            $proc = $sys->proc($proci);
            next if ($proc->{donotstart});
            next if ($proc->check_sys($sys, 'prestart'));
            $msg = Msg::new("Starting $proc->{proc} on $sysi");
            if ($cpic->proc_start_sys($sys, $proc)) {
                CPIC::proc_start_passed_sys($sys, $proc);
                $msg->display_status();
            } else {
                $errmsg=Msg::new("Failed to start $proc->{proc} on $sysi");
                $msg->addError($errmsg->{msg});
                CPIC::proc_start_failed_sys($sys, $proc);
                $msg->display_status('failed');
            }
        }
    }
    return;
}

sub cli_poststart_config_questions {
    my $prod = shift;
    $prod->perform_task('cli_poststart_config_questions');
    return;
}

sub web_poststart_config_questions {
    my $prod = shift;
    $prod->perform_task('web_poststart_config_questions');
    return;
}

sub responsefile_poststart_config {
    my $prod = shift;
    $prod->perform_task('responsefile_poststart_config');
    return;
}

sub responsefile_comments {
    my $prod = shift;
    $prod->perform_task('responsefile_comments');
    return;
}

sub get_supported_tunables {
    my ($prod) =@_;
    my ($tunables,$sf,$vcs);
    $tunables = [];
    push @$tunables, @{$prod->get_tunables};
    $sf=$prod->prod('SF61');
    push @$tunables, @{$sf->get_supported_tunables};
    $vcs=$prod->prod('VCS61');
    push @$tunables, @{$vcs->get_supported_tunables};
    return $tunables;
}

package Prod::SFHA61::AIX;
@Prod::SFHA61::AIX::ISA = qw(Prod::SFHA61::Common);

sub init_plat {
    my $prod=shift;
    Prod::SF61::AIX::init_plat($prod);

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw.rte VRTSdbac61 VRTSdbac.rte VRTSvbs61 VRTSvcsea61 VRTSodm61
        VRTSgms61 VRTScavf61 VRTSglm61 VRTScpi.rte VRTSd2doc
        VRTSordoc VRTSfppm VRTSap VRTStep VRTSgapms.VRTSgapms
        VRTSmapro VRTSvail.VRTSvail VRTSd2gui VRTSorgui VRTSvxmsa
        VRTSdbdoc VRTSdb2ed VRTSdbed61 VRTSdbcom VRTSsybed
        VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw.rte VRTScspro
        VRTSvcsdb.rte VRTSvcsor.rte VRTSvcssy.rte VRTScmccc.rte
        VRTScmcs.rte VRTSacclib52 VRTSacclib.rte VRTScscm.rte
        VRTScscw.rte VRTScssim.rte VRTScutil VRTScutil.rte
        VRTSvcs.doc VRTSvcs.man VRTSvcs.msg.en_US VRTSvcsag61
        VRTSvcsag.rte VRTScps61 VRTSvcs61 VRTSvcs.rte VRTSamf61 VRTSvxfen61
        VRTSvxfen.rte VRTSgab61 VRTSgab.rte VRTSllt61 VRTSllt.rte
        VRTSfsmnd VRTSfssdk61 VRTSfsadv61 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb.rte VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid.rte
        VRTSalloc VRTSvsvc VRTSvmpro VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt61 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh60 VRTSob34 VRTSobc33 VRTSaslapm61
        VRTSat50 VRTSat.server VRTSat.client VRTSsmf VRTSpbx
        VRTSicsco VRTSvxfs61 VRTSvxvm61 VRTSveki61 VRTSjre15.rte
        VRTSjre.rte VRTSsfcpi61 VRTSperl516 VRTSperl.rte VRTSvlic32
    ) ];

    return;
}


package Prod::SFHA61::HPUX;
@Prod::SFHA61::HPUX::ISA = qw(Prod::SFHA61::Common);

sub init_plat {
    my $prod=shift;
    Prod::SF61::HPUX::init_plat($prod);

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSdbckp VRTSormap VRTScsocw VRTSdbac61 VRTScfsdc VRTSvbs61
        VRTSvcsea61 VRTSodm61 VRTSgms61 VRTScavf61 VRTSglm61
        VRTScpi VRTSap VRTStep VRTSgapms VRTSmapro VRTSvail
        VRTSorgui VRTSorweb VRTSvxmsa VRTSvrdev VRTSdbdoc VRTSdbed61
        VRTSdbcom VRTSvcsApache VRTScmc VRTSccacm VRTSvcsw
        VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy VRTScmccc VRTScmcs
        VRTScscm VRTScscw VRTScssim VRTScutil
        VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsag61 VRTScps61
        VRTSvcs61 VRTSamf61 VRTSvxfen61 VRTSgab61 VRTSllt61 VRTSfsmnd
        VRTSfssdk61 VRTSfsadv61 VRTSfsdoc VRTSfsman VRTSvrdoc VRTSvrw VRTSvrmcsg
        VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid VRTSvsvc
        VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc VRTSvmman SYMClma
        VRTSspt61 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh60 VRTSob34 VRTSobc33 VRTSaslapm61
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs61 VRTSvxvm61
        VRTSjre15 VRTSjre VRTSsfcpi61 VRTSperl516 VRTSvlic32 VRTSwl
    ) ];
    return;
}

package Prod::SFHA61::Linux;
@Prod::SFHA61::Linux::ISA = qw(Prod::SFHA61::Common);

sub init_plat {
    my $prod=shift;
    Prod::SF61::Linux::init_plat($prod);
    $prod->{menu_options}=['Symantec Volume Replicator','Symantec File Replicator Option','Global Cluster Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTScavf61 VRTScpi VRTSd2doc VRTSordoc VRTSfsnbl
        VRTSfppm VRTSap VRTStep VRTSgapms VRTSmapro-common
        VRTSvail VRTSd2gui-common VRTSorgui-common VRTSvbs61 VRTSvcsea61
        VRTSodm61 VRTSodm-platform VRTSodm-common VRTSvxmsa
        VRTSdbdoc VRTSdb2ed-common VRTSdbed61 VRTSdbed-common
        VRTSdbcom-common VRTSsybed-common VRTSvcsApache VRTScmc
        VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy
        VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScssim
        VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsdr61
        VRTSvcsag61 VRTScps61 VRTSvcsvmw61 VRTSvcs61 VRTSamf61 VRTSvxfen61 VRTSgab61
        VRTSllt61 VRTSfsmnd VRTSfssdk61 VRTSfsadv61 VRTSfsdoc VRTSfsman
        VRTSvrdoc VRTSvrw VRTSweb VRTSvcsvr VRTSvrpro VRTSalloc
        VRTSdcli VRTSvsvc VRTSvmpro VRTSddlpr VRTSvdid VRTSlvmconv61
        VRTSvmdoc VRTSvmman SYMClma VRTSspt61 VRTSaa VRTSmh
        VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSsfmh60 VRTSob34
        VRTSobc33 VRTSaslapm61 VRTSat50 VRTSatClient50 VRTSsmf VRTSpbx VRTSicsco
        VRTSvxfs61 VRTSvxfs-platform VRTSvxfs-common VRTSvxvm61
        VRTSvxvm-platform VRTSvxvm-common VRTSjre15 VRTSjre
        VRTSsfcpi61 VRTSperl516 VRTSvlic32
    ) ];
    return;
}

sub set_mode {
    my ($prod,$mode_id)=@_;
    $prod->{mode}= $prod->{menu_modes}->[$mode_id-1];
    if ($mode_id==1) {
        $prod->{menu_options}=['Symantec Volume Replicator','Symantec File Replicator Option'];
    }
    Cfg::set_opt('prodmode',$prod->{mode});
    return;
}

package Prod::SFHA61::SunOS;
@Prod::SFHA61::SunOS::ISA = qw(Prod::SFHA61::Common);

sub init_plat {
    my $prod=shift;
    Prod::SF61::SunOS::init_plat($prod);

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSdbac61 VRTSvbs61 VRTSvcsea61 VRTSodm61 VRTSgms61
        VRTScavf61 VRTSglm61 VRTScpi VRTSd2doc VRTSordoc VRTSfsnbl
        VRTSfppm VRTSap VRTStep VRTSspc VRTSspcq VRTSfasdc
        VRTSfasag VRTSfas VRTSgapms VRTSmapro VRTSvail VRTSd2gui
        VRTSorgui VRTSvxmsa VRTSdbdoc VRTSdb2ed VRTSdbed61
        VRTSdbcom VRTSsydoc VRTSsybed VRTSvcsApache VRTScmc
        VRTSccacm VRTSvcsw VRTScspro VRTSvcsdb VRTSvcsor VRTSvcssy
        VRTScmccc VRTScmcs VRTSacclib52 VRTScscm VRTScscw VRTScssim
        VRTScutil VRTSvcsdc VRTSvcsmn VRTSvcsmg VRTSvcsag61
        VRTScps61 VRTSvcs61 VRTSamf61 VRTSvxfen61 VRTSgab61 VRTSllt61
        VRTSfsmnd VRTSfssdk61 VRTSfsadv61 VRTSfsdoc VRTSfsman VRTSvrdoc
        VRTSvrw VRTSweb VRTSvcsvr VRTSvrpro VRTSddlpr VRTSvdid
        VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli VRTSvmdoc VRTSvmman
        SYMClma VRTSspt61 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh60 VRTSob34 VRTSobc33 VRTSaslapm61
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs61 VRTSvxvm61
        VRTSjre15 VRTSjre VRTSsfcpi61 VRTSperl516 VRTSvlic32
    ) ];
    return;
}


package Prod::SFHA61::SolSparc;
@Prod::SFHA61::SolSparc::ISA = qw(Prod::SFHA61::SunOS);

sub init_padv {
    my $prod=shift;
    return Prod::SF61::SolSparc::init_padv($prod);
}

package Prod::SFHA61::Sol11sparc;
@Prod::SFHA61::Sol11sparc::ISA = qw(Prod::SFHA61::SunOS);

sub init_padv {
    my $prod=shift;
    return Prod::SF61::Sol11sparc::init_padv($prod);
}

package Prod::SFHA61::Solx64;
@Prod::SFHA61::Solx64::ISA = qw(Prod::SFHA61::SunOS);

sub init_padv {
    my $prod=shift;
    return Prod::SF61::Solx64::init_padv($prod);
}

package Prod::SFHA61::Sol11x64;
@Prod::SFHA61::Sol11x64::ISA = qw(Prod::SFHA61::SunOS);

sub init_padv {
    my $prod=shift;
    return Prod::SF61::Sol11x64::init_padv($prod);
}

1;
