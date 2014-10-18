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

package Prod::SF61::Common;
@Prod::SF61::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{prod}='SF';
    $prod->{abbr}='SF';
    $prod->{vers}='6.1.0.000';
    $prod->{proddir}='storage_foundation';
    $prod->{eula}='EULA_SFHA_Ux_6.1.pdf';
    $prod->{name}=Msg::new("Symantec Storage Foundation")->{msg};
    $prod->{menu_modes}=['SF Standard','SF Enterprise'];
    $prod->{default_mode}=1;
    $prod->{menu_options}=['Symantec Volume Replicator'];
    $prod->{lic_names}=['Storage Foundation',
                        'Storage Foundation for Oracle',
                        'Storage Foundation for DB2',
                        'Storage Foundation for Sybase'];
    $prod->{responsefileupgradeok}=1;
    $prod->{multisystemserialpoststart}=1;

    $prod->{minimal_memory_requirment} = '1 GB';
    $prod->{minimal_swap_requirment} = '1 GB';

    $prod->{licsuperprods}=[ qw(SFHA61) ];
    $prod->{installonupgradepkgs} = [ qw(VRTSfsadv VRTSdbed) ];

    my $edr=$Obj::pool{'EDR'};
    if($edr && (-d "$edr->{mediapath}/storage_foundation_basic")) {
        $prod->{proddir}='storage_foundation_basic';
        $prod->{eula}='EULA_SF_Basic_Ux_6.1.pdf';
        $prod->{name}=Msg::new("Symantec Storage Foundation Basic")->{msg};
        $prod->{menu_modes}=undef;
        $prod->{menu_options}=undef;
        $prod->{mode}='SF Basic';
        Cfg::set_opt('prodmode',$prod->{mode});
    }
    return;
}

sub default_systemnames {
    my $prod=shift;
    my $localsys=$prod->localsys;
    return '' if ($localsys->{padv} ne $prod->{padv});
    return $localsys->{hostname};
}

sub set_mode {
    my ($prod,$mode_id)=@_;
    $prod->{mode}=$prod->{menu_modes}->[$mode_id-1];
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

sub verify_responsefile {
    my ($prod) = @_;
    $prod->perform_task('verify_responsefile');
    return;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($vm_vers,$mpvers,$fs_vers,$fspkg,$vm,$vmpkg,$fs);
    my $rel=Obj::rel();

    $vm=$sys->prod('VM61');
    $vmpkg=$sys->pkg($vm->{mainpkg});
    $vm_vers=$vmpkg->version_sys($sys,$force_flag);
    $fs=$sys->prod('FS61');
    $fspkg=$sys->pkg($fs->{mainpkg});
    $fs_vers=$fspkg->version_sys($sys,$force_flag);;
    $mpvers=$prod->{vers} if ($vm_vers && $fs_vers && $prod->check_installed_patches_sys($sys,$vm_vers));
    $vm_vers= $prod->revert_base_version_sys($sys,$vmpkg,$vm_vers,$mpvers,$force_flag);
    $fs_vers= $prod->revert_base_version_sys($sys,$fspkg,$fs_vers,$mpvers,$force_flag);
    # AIX-specific case
    if ($sys->aix() &&
            (substr($vm_vers,0,1) eq '3') && (substr($fs_vers,0,1) eq '3')) {
        return ($mpvers || $vm_vers) if($rel->prod_licensed_sys($sys,$prod->{prodi}));
    }

    if (!EDRu::compvers($vm_vers,$fs_vers,2)) {
        return ($mpvers || $vm_vers) if($rel->prod_licensed_sys($sys,$prod->{prodi}));
    }
    return '';
}

# returns all right now, could be HA/mode based
sub set_pkgs {
    my($prod,$rel,$vm,$fs,$category,@categories);
    $prod=shift;

    $rel=$prod->rel;
    $vm=$prod->prod('VM61');
    $fs=$prod->prod('FS61');

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
                                        @{$prod->{$category}});
    }

    @categories=qw(obsoleted_ga_release_pkgs
                   obsoleted_but_need_refresh_when_upgrade_pkgs
                   obsoleted_but_still_support_pkgs);
    for my $category (@categories) {
        $prod->{$category}=EDRu::arruniq(@{$rel->{$category}},
                                        @{$prod->{$category}},
                                        @{$vm->{$category}},
                                        @{$fs->{$category}});
    }

    return $prod->{allpkgs};
}

sub check_config {
    my $prod = shift;
    return $prod->perform_task('check_config');
}

sub cli_prod_option {
}

sub perform_task_sys {
    my ($prod,$sys,$task) = @_;
    my ($vm,$vm_rtn,$fs_rtn,$fs);

    $vm=$prod->prod('VM61');
    $fs=$prod->prod('FS61');

    $vm_rtn=$vm->$task($sys) if ($vm->can($task));
    $fs_rtn=$fs->$task($sys) if ($fs->can($task));

    return;
}

sub perform_task {
    my ($prod,$task) = @_;
    my ($vm,$vm_rtn,$fs_rtn,$fs);

    $vm=$prod->prod('VM61');
    $fs=$prod->prod('FS61');

    $vm_rtn=$vm->$task() if ($vm->can($task));
    $fs_rtn=$fs->$task() if ($fs->can($task));

    return ($vm_rtn && $fs_rtn);
}

sub prestop_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'prestop_sys'); }
sub preremove_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'preremove_sys'); }
sub postremove_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'postremove_sys'); }
sub preinstall_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'preinstall_sys'); }
sub postinstall_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'postinstall_sys'); }
sub configure_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'configure_sys'); }

sub poststart_sys {
    my ($prod,$sys) = @_;
    $prod->perform_task_sys($sys,'poststart_sys');
    if ($sys->exists("/opt/VRTS/install/.$prod->{prod}.upgrade")) {
        # Remove .<UPI>.upgrade file
        $sys->cmd("_cmd_rmr /opt/VRTS/install/.$prod->{prod}.upgrade 2>/dev/null");
    }
    return;
}

sub install_precheck_sys {
    my ($prod,$sys)= @_;
    $prod->obsoleted_bundles_sys($sys);
    $prod->obsoleted_bundled_pkgs_sys($sys);
    $prod->perform_task_sys($sys,'install_precheck_sys');
    return 1;
}

sub upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($cv,$dbed_prod,%dbed_vers,$ha,$msg,$vcs,$cprod);
    $cprod=CPIC::get('prod');
    if ($cprod =~ /^SF(HA)?\d+/mx) {
        $ha = ($cprod=~/HA/m) ? 'HA' : '';
        $dbed_vers{SFDB2} = $sys->{pkgvers}->{VRTSdb2ed} || $sys->{pkgvers}->{'VRTSdb2ed-common'};
        $dbed_vers{SFSYB} = $sys->{pkgvers}->{VRTSsybed} || $sys->{pkgvers}->{'VRTSsybed-common'};
        $dbed_vers{SFORA} = $sys->{pkgvers}->{VRTSdbed} || $sys->{pkgvers}->{'VRTSdbed-common'};
        $cv=($sys->{padv} =~ /11.31/m) ? EDRu::compvers($dbed_vers{SFORA},'5.1.0.0',4) :
            EDRu::compvers($dbed_vers{SFORA},'5.1.0.0',2);
        $dbed_vers{SFORA}='' if ($cv<2);
        for my $dbed_prod (keys %dbed_vers) {
            next unless $dbed_vers{$dbed_prod};
            $sys->{dbed_prod}="$dbed_prod$ha";
            $sys->set_value('dbed_prod',$sys->{dbed_prod});
            $msg = Msg::new("The installer has detected that $sys->{dbed_prod} $dbed_vers{$dbed_prod} is installed on $sys->{sys}. $sys->{dbed_prod} will be upgraded to $prod->{abbr}$ha $prod->{vers}. Some features will be lost. Refer to the SF $prod->{vers} Release Notes for unsupported features.");
            $sys->push_warning($msg);
        }
    }
    $prod->obsoleted_bundles_sys($sys);
    $prod->obsoleted_bundled_pkgs_sys($sys);
    $prod->perform_task_sys($sys,'upgrade_precheck_sys');
    return;
}

sub upgrade_prestop_sys { my ($prod,$sys)=@_; return $prod->perform_task_sys($sys, 'upgrade_prestop_sys'); }
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
    $msg=Msg::new("Symantec Storage Foundation QuickStart (FST-QS) offers a limited-function version of Symantec Storage Foundation for entry-level servers.  Symantec Storage Foundation QuickStart includes basic versions of Veritas Volume Manager and Veritas File System. FST-QS provides journal-based fast recovery, high performance, on-line management of volumes, and mirroring for boot drives. You can upgrade FST-QS to the feature-complete Symantec Storage Foundation with an additional license.");
    $msg->print;
    return;
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);

    $cpic = Obj::cpic();
    $rel = $cpic->rel;

    # set vvr option per license check
    my $vm=$sys->prod('VM61');
    $vm->vr_licensed_sys($sys);
    $vm->vfr_licensed_sys($sys);

    return $rel->prod_licensed_sys($sys, '');
}

sub startprocs {
    my ($prod,$ref_procs);
    $prod = shift;
    $ref_procs = Prod::startprocs($prod);
    return $ref_procs;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my ($cfg,$vm,$ref_procs);
    $cfg =Obj::cfg();
    $vm = $prod->prod('VM61');
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $vm->verify_procs_list_sys($sys,$ref_procs,'start');
    return $ref_procs;
}

sub verify_procs_list {
    my ($prod,$procs,$state)=@_;
    my ($cpic,$fs,$vm,$vcs);
    $vm = $prod->prod('VM61');
    $fs = $prod->prod('FS61');
    $procs = $vm->verify_procs_list($procs,$state);
    $procs = $fs->verify_procs_list($procs,$state);
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure'))) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    return $procs;
}

sub stopprocs {
    my ($prod,$ref_procs);
    $prod=shift;
    if (Cfg::opt('configure')) {
        return [];
    }
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $prod->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub verify_procs_list_sys {
    my ($prod,$sys,$procs,$state)=@_;
    my ($cpic,$fs,$vm,$vcs);
    $vm = $prod->prod('VM61');
    $fs = $prod->prod('FS61');
    $vcs = $prod->prod('VCS61');
    $procs = $vm->verify_procs_list_sys($sys,$procs,$state);
    $procs = $fs->verify_procs_list_sys($sys,$procs,$state);
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure'))) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    return $procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    if (Cfg::opt('configure')) {
        return [];
    }
    my $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub addnode_poststart {
    my ($msg,$errmsg,$proc,$proci,$startprocs,$sys,$sysi);
    my $prod = shift;
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

    # start SFHA processes
    for my $sysi (@{$cfg->{newnodes}}) {
        $sys = Obj::sys($sysi);
        $startprocs = $prod->startprocs_sys($sys);
        for my $proci (@{$startprocs}) {
            next if (EDRu::inarr($proci,qw(llt61 gab61 vxfen61 had61)));
            $proc = $sys->proc($proci);
            next if ($proc->{donotstart});
            $msg = Msg::new("Starting $proc->{proc} on $sysi");
            $msg->left;
            if ($cpic->proc_start_sys($sys, $proc)) {
                CPIC::proc_start_passed_sys($sys, $proc);
                Msg::right_done();
            } else {
                $errmsg = Msg::new("Failed to start $proc->{proc} on $sysi");
                $msg->addError($errmsg->{msg});
                CPIC::proc_start_failed_sys($sys, $proc);
                Msg::right_failed();
            }
        }
    }
    return;
}

sub get_supported_tunables {
    my ($prod) =@_;
    my ($tunables,$fs,$vm);
    $tunables = [];
    push @$tunables, @{$prod->get_tunables};
    $fs=$prod->prod('FS61');
    push @$tunables, @{$fs->get_supported_tunables};
    $vm=$prod->prod('VM61');
    push @$tunables, @{$vm->get_supported_tunables};
    return $tunables;
}

package Prod::SF61::AIX;
@Prod::SF61::AIX::ISA = qw(Prod::SF61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61) ];
    $prod->{minpkgs}=[ qw() ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61) ];
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0 6.1)];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw.rte VRTScpi.rte VRTSd2doc VRTSordoc VRTSfppm
        VRTSap VRTStep VRTSvcsdb.rte VRTSvcsor.rte VRTSgapms.VRTSgapms
        VRTSmapro VRTSvail.VRTSvail VRTSd2gui VRTSorgui VRTSodm61
        VRTSvxmsa VRTSdbdoc VRTSdb2ed VRTSdbed61 VRTSdbcom
        VRTSvcssy.rte VRTSsybed VRTSfsmnd VRTSfssdk61 VRTSfsadv61 VRTSfsdoc
        VRTSfsman VRTSvrdoc VRTSvrw VRTSweb.rte VRTSvcsvr VRTSvrpro
        VRTSddlpr VRTSvdid.rte VRTSalloc VRTSvsvc VRTSvmpro
        VRTSdcli VRTSvmdoc VRTSvmman SYMClma VRTSspt61 VRTSaa
        VRTSmh VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSsfmh60
        VRTSob34 VRTSobc33 VRTSaslapm61 VRTSat50 VRTSat.server
        VRTSat.client VRTSsmf VRTSpbx VRTSicsco VRTSvxfs61
        VRTSvxvm61 VRTSveki61 VRTSjre15.rte VRTSjre.rte VRTSsfcpi61 VRTSperl516
        VRTSperl.rte VRTSvlic32
    ) ];
    return;
}

package Prod::SF61::HPUX;
@Prod::SF61::HPUX::ISA = qw(Prod::SF61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61) ];
    $prod->{minpkgs}=[ qw() ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61) ];
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1 6.0 6.1)];
    $prod->{obsoleted_bundles}=[ qw(Base-VxTools-50 Base-VxVM-50 B3929FB Base-VxFS-50 Base-VxVM Base-VxTools-501 Base-VxVM-501 B3929GB Base-VxFS-501) ];
    $prod->{obsoleted_bundled_pkgs}=[ qw(AVXTOOL AVXVM AONLINEJFS OnlineJFS01 AVXFS) ];
    $prod->{zru_releases}=[qw()];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSdbckp VRTSormap VRTScsocw VRTScfsdc VRTScpi VRTSap
        VRTStep VRTSvcsor VRTSgapms VRTSmapro VRTSvail VRTSorgui
        VRTSorweb VRTSodm61 VRTSvxmsa VRTSvrdev VRTSdbdoc VRTSdbed61
        VRTSdbcom VRTSfsmnd VRTSfssdk61 VRTSfsadv61 VRTSfsdoc VRTSfsman
        VRTSvrdoc VRTSvrw VRTSvrmcsg VRTSweb VRTSvcsvr VRTSvrpro
        VRTSddlpr VRTSvdid VRTSvsvc VRTSvmpro VRTSalloc VRTSdcli
        VRTSvmdoc VRTSvmman SYMClma VRTSspt61 VRTSaa VRTSmh
        VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSsfmh60 VRTSob34
        VRTSobc33 VRTSaslapm61 VRTSat50 VRTSsmf VRTSpbx VRTSicsco
        VRTSvxfs61 VRTSvxvm61 VRTSjre15 VRTSjre VRTSsfcpi61 VRTSperl516
        VRTSvlic32 VRTSwl
    ) ];
    return;
}

package Prod::SF61::Linux;
@Prod::SF61::Linux::ISA = qw(Prod::SF61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61 ) ];
    $prod->{minpkgs}=[ qw() ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61 ) ];
    $prod->{upgradevers}=[qw(5.0.30 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(4.1.40 5.0 5.1 6.0 6.1)];
    $prod->{menu_options}=['Symantec Volume Replicator', 'Symantec File Replicator Option'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTScavf61 VRTScpi VRTSd2doc VRTSordoc VRTSfsnbl
        VRTSfppm VRTSap VRTStep VRTSvcsdb VRTSvcsor VRTSgapms
        VRTSmapro-common VRTSvail VRTSd2gui-common VRTSorgui-common
        VRTSodm61 VRTSodm-platform VRTSodm-common VRTSvxmsa
        VRTSdbdoc VRTSdb2ed-common VRTSdbed61 VRTSdbed-common
        VRTSdbcom-common VRTSvcssy VRTSsybed-common VRTSfsmnd
        VRTSfssdk61 VRTSfsadv61 VRTSfsdoc VRTSfsman VRTSvrdoc VRTSvrw VRTSweb
        VRTSvcsvr VRTSvrpro VRTSalloc VRTSdcli VRTSvsvc VRTSvmpro
        VRTSddlpr VRTSvdid VRTSlvmconv61 VRTSvmdoc VRTSvmman
        SYMClma VRTSspt61 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh60 VRTSob34 VRTSobc33 VRTSaslapm61
        VRTSat50 VRTSatClient50 VRTSsmf VRTSpbx VRTSicsco VRTSvxfs61
        VRTSvxfs-platform VRTSvxfs-common VRTSvxvm61 VRTSvxvm-platform
        VRTSvxvm-common VRTSjre15 VRTSjre VRTSsfcpi61 VRTSperl516 VRTSvlic32
    ) ];
    return;
}

package Prod::SF61::SunOS;
@Prod::SF61::SunOS::ISA = qw(Prod::SF61::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61) ];
    $prod->{minpkgs}=[ qw() ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSdbed61 VRTSodm61) ];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTScpi VRTSd2doc VRTSordoc VRTSfsnbl VRTSfppm
        VRTSap VRTStep VRTSspc VRTSspcq VRTSfasdc VRTSfasag
        VRTSfas VRTSvcsdb VRTSvcsor VRTSgapms VRTSmapro VRTSvail
        VRTSd2gui VRTSorgui VRTSodm61 VRTSvxmsa VRTSdbdoc VRTSdb2ed
        VRTSdbed61 VRTSdbcom VRTSsydoc VRTSsybed VRTSvcssy
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

package Prod::SF61::SolSparc;
@Prod::SF61::SolSparc::ISA = qw(Prod::SF61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0 6.1)];
    $prod->{zru_releases}=[qw(4.1.2 5.0 5.1 6.0 6.1)];
    return;
}

package Prod::SF61::Sol11sparc;
@Prod::SF61::Sol11sparc::ISA = qw(Prod::SF61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10 6.1)];
    $prod->{zru_releases}=[qw(6.0.10 6.1)];
    $prod->{allpkgs}=[ qw(VRTSdbed61 VRTSodm61) ];
    $prod->{minpkgs}=[ qw() ];
    $prod->{recpkgs}=[ qw(VRTSdbed61 VRTSodm61) ];
    return;
}

package Prod::SF61::Solx64;
@Prod::SF61::Solx64::ISA = qw(Prod::SF61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0 5.1 6.0)];
    return;
}

package Prod::SF61::Sol11x64;
@Prod::SF61::Sol11x64::ISA = qw(Prod::SF61::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    $prod->{allpkgs}=[ qw(VRTSdbed61 VRTSodm61) ];
    $prod->{minpkgs}=[ qw() ];
    $prod->{recpkgs}=[ qw(VRTSdbed61 VRTSodm61) ];
    return;
}

1;
