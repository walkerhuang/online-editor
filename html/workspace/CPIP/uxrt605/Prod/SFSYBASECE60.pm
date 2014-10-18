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

package Prod::SFSYBASECE60::Common;
@Prod::SFSYBASECE60::Common::ISA = qw(Prod::SFCFSHA60::Common);

sub postinstall_sys {
    my ($prod,$sys) = @_;
    $prod->copy_resstatechange_sys($sys);
    $prod->perform_task_sys($sys,'postinstall_sys');
    return;
}

sub upgrade_postinstall_sys {
    my ($prod,$sys) = @_;
    $prod->copy_resstatechange_sys($sys);
    $prod->perform_task_sys($sys,'upgrade_postinstall_sys');
    return;
}

sub copy_resstatechange_sys {
    my ($prod,$sys) = @_;
    my ($localsys,$mediapath,$file,$rootpath);
    $localsys = $prod->localsys;
    $rootpath = Cfg::opt('rootpath') || '';
    $mediapath=EDR::get('mediapath');
    $file="$mediapath/scripts/resstatechange";
    Msg::log("Copy script resstatechange to system");
    if($localsys->exists($file)){
        $localsys->copy_to_sys($sys,$file,"$rootpath/opt/VRTSvcs/bin/triggers/resstatechange");
    }
    return 1;
}

sub cli_prestart_config_questions {
    my ($prod) = @_;
    $prod->config_menu();
#    $prod->perform_task("cli_prestart_config_questions");
    return;
}

sub config_menu {
    my ($prod,$vcsalreadyup) = @_;
    my ($selection,$backopt);
    $backopt = 0;
    $selection = $prod->display_product_menu_and_act($backopt, @{$prod->{menu_sfsybasece}});
    return;
}

sub responsefile_prestart_config {
    my ($prod)=@_;
    $prod->config_menu;
    return;
}

# First arg = $prod
# Second arg = $backopt
# Third arg = complete menu for $prod (can have menu within a menu too)
sub display_product_menu_and_act {
    my ($prod,$backopt,@menuopts) = @_;
    my ($msg,$sfcfs,$edr,$menulist,$ret,$help,$choice,$menu,$def,$cfg,$web);

    $sfcfs = $prod->prod('SFCFSHA60');
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    $web = Obj::web();

    $def = 1; # Default option in the menu
    $help = '';

    while (1) {
        if (Obj::webui()) {
            $web->web_script_form('sfsybasece_select_task', $prod, \@menuopts);
            if ($web->param('back') eq 'back') {
                return;
            }
            $choice = $web->param('select_task');
        } else {
            # Task selection
            Msg::title();

            $menulist = [];
            for my $menukey (@menuopts) {
                $menu = Msg::get("sfsybasece_$menukey");
                push(@{$menulist}, $menu);
            }

            $msg = Msg::new("Choose option:");
            if(!Cfg::opt('responsefile')){
                $choice = $msg->menu($menulist, $def, $help, $backopt);
                $edr->{exitfile} = 'noexitfile' unless ($choice == 1);
                if (EDR::getmsgkey($choice,'back')) {
                    return;
                }
                $cfg->{sfsybasece}{menu}=$choice unless($choice ==4);
            } else {
                if($cfg->{sfsybasece}{menu}){
                    $choice=$cfg->{sfsybasece}{menu};
                } else {
                    $choice=$cfg->{sfsybasece}{menu};
                }
            }

            $choice = @menuopts[($choice-1)];
        }
        Msg::n();
        if ($prod->{"menu_$choice"}) {
            $prod->display_product_menu_and_act(1, @{$prod->{"menu_$choice"}});
        } else { # In the leaf node, no further menu
            if ($choice eq 'exit_cleanly') {
                my $cpic = Obj::cpic();
                $prod->set_value('cfscluster_config_pending',0);
                $cpic->completion();
                return;
            }
            $ret = $prod->$choice();
            if (($choice eq 'config_cfs') && ($ret == 1)) {
                return;
            }
        }
    }
    return;
}

sub config_cfs {
    my $prod = shift;

    my $cfg = Obj::cfg();
    if (!Cfg::opt('responsefile')){
        $cfg->{config_cfs} = 1;
    } else {
        return 1;
    }
    $prod->perform_task('cli_prestart_config_questions');
    $prod->perform_task('web_prestart_config_questions');
    return 1;
}

sub config_fencing {
    my $prod=shift;
    my ($cfg,$cpic,$edr,$pkg,$vcs,$ret);

    $vcs = $prod->prod('VCS60');
    $cfg=Obj::cfg();
    $pkg=$prod->pkg('VRTSvxfen60');
    $edr=Obj::edr();
    $edr->{savelog} = 1;
    $ret=$vcs->get_cluster_system(1);
    $pkg->config_vxfen() if($ret);
    if(Cfg::opt('responsefile')){
        $cpic=Obj::cpic();
        $prod->set_value('cfscluster_config_pending',0);
        $cpic->completion();
    }
    return;
}

sub config_sfsybasece {
    my $prod = shift;
    my $edr=Obj::edr();
    $edr->register_cleanup_task(\&dump_conf,$prod);
    $prod->print_guide_sybase;
    $prod->config_sybase_service_group();
    if(Cfg::opt('responsefile')){
        my $cpic=Obj::cpic();
        $prod->set_value('cfscluster_config_pending',0);
        $cpic->completion();
    }
    return;
}

sub sybase_location_menu_bak {
    my $prod=shift;
    my ($msg,$ayn,$choice);

    $msg=Msg::new("Are you using Sybase ASE CE installation binaries on local/private vxfs mount?");
    $ayn=$msg->aynn('',1);
    return '' if (EDR::getmsgkey($ayn,'back'));
    if ($ayn eq 'N'){
        $choice=1;
    } else {
        $choice=2;
    }
    return $choice;
}

sub sybase_location_menu {
    my $prod=shift;
    my (@menu,$msg,$choice,$warning,$ayn,$msgtl);

    $msg=Msg::new("CFS(Recommended)");
    push(@menu,$msg->{msg});
    $msg=Msg::new("Local VxFS");
    push(@menu,$msg->{msg});
    #push(@menu,"On local native OS filesystem");
    $msgtl=Msg::new("Choose the file system where Sybase ASE CE binaries will reside");
    $msg=Msg::new("Choose option:");
    while(1){
        $msgtl->print;
        $choice=$msg->menu(\@menu,1,'',1);
        return if (EDR::getmsgkey($choice,'back'));
        if($choice==3){
            $warning=Msg::new("\nAs you have chosen not to have Sybase ASE CE installation binaries on VxFS/CFS, they cannot be managed by VCS and the mount point on local native OS filesystem has to configured in a such a way that it is made available before Sybase ASE CE attempts to start.");
            $warning->print;
            Msg::n();
            $warning=Msg::new("Do you still want to have the Sybase binaries on local native OS filesystem?");
            $ayn=$warning->aynn;
            next if($ayn eq 'N');
        }
        return $choice;
    }
    return;
}

sub config_sybase_service_group {
    my $prod=shift;;
    my ($sys,$cfg,$rtn);

    $sys = @{CPIC::get("systems")}[0];
    $cfg=Obj::cfg();

    # prerequisite, cvm group should be online
    #clear_and_start_cvm();

    # volume manager should be enable
    return 0 unless ($prod->wait_vm_enable());

    # $cfg->{sybase_location}=1 : sybase is on CFS
    # $cfg->{sybase_location}=2 : sybase is on local VxFS
    # $cfg->{sybase_location}=3 : sybase is on local OS filesytem
    #$cfg->{sybase_location}=$prod->sybase_location_menu if(!Cfg::opt('responsefile'));
    #return 0 unless ($cfg->{sybase_location});

    # make the VCS configuration - main.cf writable
    # CPI::prod_sub( "UPI=VCS", "haconf_makerw" );
    $prod->make_conf_rw();

    # Typically, there are storage resources, network resources and application resources within a service group.
    # In this step, will ask information related with storage resources such as disk groups, volumes and mount points
    if (!Cfg::opt('responsefile')) {
        my %hash=();
        $cfg->{sfsybasece}{storage_resource} = \%hash;
        $rtn=$prod->ask_storage_resource( $sys, $cfg->{sfsybasece}{storage_resource} );
        return 0 unless($rtn);
    }

    # create service group - binmnt
    my $binmnt_service_group = 'binmnt';
    $prod->add_service_group( $sys, $binmnt_service_group ) unless($cfg->{sybase_location}==3);

    # create service group with name - sybasece
    my $sybase_service_group = 'sybasece';
    $prod->add_service_group( $sys, $sybase_service_group );

    $prod->link_binmnt_sybasece($sys,$sybase_service_group, $binmnt_service_group);

    # add storage resources into service group
    $rtn=$prod->add_storage_resource( $sys, $sybase_service_group, $binmnt_service_group, $cfg->{sfsybasece}{storage_resource} );
    #return 0 unless($rtn);

    # add application - vxfend into service group
    my $vxfend_resource_name = 'vxfend';
    $prod->add_sybase_vxfend( $sys, $sybase_service_group, $vxfend_resource_name );

    # ask sybase configuration related information
    # TODO: plain text password or encrypted one is used for response file?
    if ( !Cfg::opt('responsefile') ) {
        $prod->ask_sybase_configuration($sys);
    }
    # add sybase into service group
    my $ase_resource = "ase";
    $prod->add_sybase_ase( $sys, $sybase_service_group, $ase_resource, $cfg->{sfsybasece}{ase_server}, $cfg->{sfsybasece}{ase_owner}, $cfg->{sfsybasece}{ase_home}, $cfg->{sfsybasece}{ase_version}, $cfg->{sfsybasece}{ase_sa}, $cfg->{sfsybasece}{ase_pwd}, $cfg->{sfsybasece}{ase_quorum} );

    # dependencies
    $prod->create_group_resource_dependencies( $sys, $sybase_service_group, $binmnt_service_group, $ase_resource, $cfg->{sfsybasece}{storage_resource}, $vxfend_resource_name );

    # online service group - binmnt
    $prod->bring_sybase_online( $sys, $binmnt_service_group ) unless($cfg->{sybase_location}==3);

    # create run scripts as required.
    $prod->create_run_scripts( $sys, $cfg->{sfsybasece}{ase_home}, $cfg->{sfsybasece}{ase_server}, $cfg->{sfsybasece}{ase_quorum}, $cfg->{sfsybasece}{ase_owner} );

    # bring quorum volume/mount online
    $prod->bring_quorum_resource_online($sys, $cfg->{sfsybasece}{storage_resource});

    # set symantec membership mode
    $prod->set_membership_mode( $sys, $cfg->{sfsybasece}{ase_home}, $cfg->{sfsybasece}{ase_quorum}, "vcs", $ase_resource);

    # online service group - sybasece
    $prod->bring_sybase_online( $sys, $sybase_service_group );

    # haconf dump
    # CPI::prod_sub( "UPI=VCS", "haconf_dumpmakero" );
    $prod->dump_conf();

    $prod->display_warning();

    Msg::prtc();
    return;
}

sub display_warning {
    my ($prod)=@_;
    foreach my $msg (@{$prod->{warnings}}){
        $msg->warning;
    }
    return;
}

sub bring_quorum_resource_online {
    my ($prod,$sys,$mount_hash_ref) = @_;
    for my $disk_group ( keys %$mount_hash_ref ) {
        for my $volume ( keys %{ $$mount_hash_ref{$disk_group} } ) {
            if ( $$mount_hash_ref{$disk_group}{$volume}{usage} eq 'quorum device' ) {
                # by convention, disk group resouce is supposed to be ...
                my $disk_group_resource = $disk_group . "_voldg";
                my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
                $sys->cmd("_cmd_hares -online $disk_group_resource -sys $sysname" );
                $sys->cmd("_cmd_hares -wait $disk_group_resource State ONLINE -sys $sysname -time 300" );
                if ( $$mount_hash_ref{$disk_group}{$volume}{mount} ) {
                        # likewise, mount resource is supposed to be...
                        my $mount_resource = $disk_group . "_" . $volume . "_mnt";
                        $sys->cmd("_cmd_hares -online $mount_resource -sys $sysname" );
                        $sys->cmd("_cmd_hares -wait $mount_resource State ONLINE -sys $sysname -time 300" );
                }
                return;
            }
        }
    }
    return;
}


sub set_membership_mode {
    my ($prod,$sys,$home,$quorum,$mode,$ase_resource) = @_;
    my ($membership,$msg,$running,$status,$m);

    # check membership
    return unless($sys->exists("$home/ASE-15_0/bin/qrmutil"));
    $membership = $sys->cmd("$home/ASE-15_0/bin/qrmutil --quorum_dev=$quorum --display=config | _cmd_grep Membership");
    if (EDR::cmdexit() == 0) {
          (undef, $m) = split(/:/, $membership);
          $m =~ s/\'//g;
          $m =~s/\s//g;
          if($m eq $mode){
              Msg::log("The membership mode is $m already.");
              return;
          }else{
              Msg::log("The membership mode will be set into $mode from $m.");
          }
    }

    if ($ase_resource) {
         for my $node ( @{CPIC::get("systems") } ) {
            $running = $sys->cmd("_cmd_ps -ef | _cmd_grep dataserver | _cmd_grep -v grep | _cmd_wc -l");
            if ((EDR::cmdexit() == 0) && ($running + 0) > 0) {
                my $sysname = Prod::VCS60::Common::transform_system_name($node->{sys});
                Msg::log("The Sybase dataserver is running on sys $sysname, installer will bring it offline.");
                $sys->cmd("_cmd_hares -offline $ase_resource -sys $sysname" );
                $sys->cmd("_cmd_hares -wait $ase_resource State OFFLINE -sys $sysname -time 300" );
                # double check
                $status = $node->cmd("_cmd_ps -ef | _cmd_grep dataserver | _cmd_grep -v grep | _cmd_wc -l");
                if ((EDR::cmdexit() == 0) && ($status + 0) > 0) {
                    $msg=Msg::new("The Sybase dataserver is still running on system $sysname. Membership mode cannot be set into $mode.");
                    $msg->print;
                }
            }
        }
    }

    $sys->cmd("$home/ASE-15_0/bin/qrmutil --quorum_dev=$quorum --membership-mode=$mode " );
    $msg=Msg::new("Failed to update the membership mode to $mode by qrmutil --quorum_dev=$quorum --membership-mode=$mode");
    sleep(2);
    $membership = $sys->cmd("$home/ASE-15_0/bin/qrmutil --quorum_dev=$quorum --display=config 2>/dev/null| _cmd_grep Membership");
    if ($membership) {
          (undef, $m) = split(/:/, $membership);
          $m =~ s/\'//g;
          $m =~s/\s//g;
          if($m eq $mode){
              Msg::log("The membership mode is set to $m ");
              return;
          }else{
              push(@{$prod->{warnings}},$msg);
          }
    }
    return;
}

sub bring_sybase_online {
    my ($prod,$sys,$service_group) = @_;
    my $cfg=Obj::cfg();
    my $msg;
    #return if $CPI::PROD{SFCFSRAC}{CVMCFS_STARTED};
    my $status_lines = $sys->cmd("_cmd_hagrp -display $service_group -attribute State" );
    my @status_line_array = split( /\n/, $status_lines );
    my @sysnames;
    foreach my $sys1 (@{CPIC::get("systems")}){
        my $sysname = Prod::VCS60::Common::transform_system_name($sys1->{sys});
        push(@sysnames,$sysname);
    }
  NEXT_SYS_CHECK: for my $status_line (@status_line_array) {
        my @status_items_array = split( /\s+/, $status_line );
        if ( EDRu::inarr( $status_items_array[2], @sysnames ) ) {
            $msg=Msg::new("Onlining $service_group group on $status_items_array[2]");
            $msg->left();
            if ( $status_items_array[3] =~ /OFFLINE|PARTIAL/ ) {
                $sys->cmd("_cmd_hagrp -clear $status_items_array[0] -sys $status_items_array[2] " );
                sleep 15;
                $sys->cmd("_cmd_hagrp -online $status_items_array[0] -sys $status_items_array[2]" );
                $sys->cmd("_cmd_hagrp -wait $status_items_array[0] State ONLINE -sys $status_items_array[2] -time 300" );
                if($service_group=~/binmnt/ && $cfg->{sybase_location} == 2){
                    $sys->cmd("_cmd_hares -online 'sybase_install_mnt' -sys $status_items_array[2] 2>/dev/null");
                    $sys->cmd("_cmd_hares -wait 'sybase_install_mnt' State ONLINE -sys $status_items_array[2] -time 120");
                }

                # double check
                {
                    $status_line = $sys->cmd("_cmd_hagrp -display $service_group -attribute State |_cmd_grep $status_items_array[2]" );
                    @status_items_array = split( /\s+/, $status_line );
                    if ( $status_items_array[3] =~ /OFFLINE|PARTIAL/ ) {
                        $msg=Msg::new("Failed");
                        $msg->right();
                        $msg=Msg::new("Cannot bring service group $service_group online on system $status_items_array[2]. Refer to the log for details");
                        $msg->warning();
                        next NEXT_SYS_CHECK;
                    }
                }
            }
            $msg->right_done();
        }
    }
    return;
}

sub wait_vm_enable {
    my $prod=shift;
    my ($sys,$msg,$offlinelist,$vm_mode,$ayn,$cfg);
    $sys=@{CPIC::get('systems')}[0];
    $cfg=Obj::cfg();
    $vm_mode = $sys->cmd("_cmd_vxdctl mode 2> /dev/null");
    if ( $vm_mode !~ /enable/ ) {
        $msg=Msg::new("Configure VM before configuring ASE CE in VCS.");
        $msg->warning;
        Msg::prtc();
        return 0;
    }

    foreach my $sys (@{CPIC::get('systems')}) {
        my $had = $sys->proc('had60');
        if (!$had->check_sys($sys,'poststart')) {
            my $sysname = Prod::VCS60::Common::transform_system_name($sys->{sys});
            $offlinelist .=" $sysname";
        }
    }
    if($offlinelist){
        $msg=Msg::new("VCS is not running on the systems $offlinelist. You cannot proceed to configure Sybase ASE CE.");
        $msg->warning();
        Msg::prtc();
        return 0;
    }

    $sys=@{CPIC::get('systems')}[0];
    my $sfsybasece=$sys->cmd("_cmd_hares -display | _cmd_grep 'Sybase' 2>/dev/null");
    if($sfsybasece){
        $msg=Msg::new("Sybase ASE CE is already configured on the systems.");
        $msg->bold;
        unless(Cfg::opt("responsefile") && $cfg->{sybasece}{reconfigure}){
            $msg=Msg::new("Do you want to re-configure Sybase ASE CE?");
            $ayn=$msg->aynn;
            if($ayn eq 'N'){
                return 0;
            } else {
                $cfg->{sybasece}{reconfigure}=1;
            }
        }
    }

    my $vxfenmode=$sys->cmd("_cmd_vxfenadm -d 2>/dev/null | _cmd_grep -i 'sybase'");
    unless($vxfenmode){
        $msg=Msg::new("I/O Fencing is not running in Sybase Mode. It is recommended to configure I/O Fencing in Sybase Mode to configure Sybase ASE CE. Otherwise, Sybase CE group will not come online later.");
        $msg->warning;
        $msg=Msg::new("Do you want to continue?");
        $ayn=$msg->aynn;
        return 0 if($ayn eq 'N');
    }

    return 1;
}

sub add_service_group {
    my ( $prod,$sys, $service_group_name ) = @_;
    my ( $syss, $systems,$sysobjs );
    $sysobjs=CPIC::get("systems");
    $sys->cmd("_cmd_hagrp -add $service_group_name" );
    for my $nsys ( 0 .. $#{$sysobjs} ) {
        my $sysname = Prod::VCS60::Common::transform_system_name(@{$sysobjs}[$nsys]->{sys});
        $syss    .= "$sysname ";
        $systems .= "$sysname $nsys ";
    }
    $sys->cmd("_cmd_hagrp -modify $service_group_name SystemList $systems" );
    $sys->cmd("_cmd_hagrp -modify $service_group_name Parallel 1" );
    $sys->cmd("_cmd_hagrp -modify $service_group_name AutoFailOver 0" );
    $sys->cmd("_cmd_hagrp -modify $service_group_name AutoStartList $syss" );
    $sys->cmd("_cmd_hagrp -modify $service_group_name OnlineRetryLimit 3" );
    $sys->cmd("_cmd_hagrp -modify $service_group_name OnlineRetryInterval 120" );
    if($service_group_name=~/sybasece/){
        $sys->cmd("_cmd_hagrp -modify $service_group_name TriggerResStateChange 1" );
    }
    return;
}

sub list_all_dgs {
    my ($prod,$sys,$islocal) = @_;
    my $cmd='_cmd_vxdisk -o alldgs list | _cmd_grep online ';
    if($islocal){
        $cmd.='| _cmd_grep -v shared';
    } else {
        $cmd.='| _cmd_grep shared';
    }
    #my $dsklist = CPI::do_sys( $sys, "_PLAT_VXDISK -o alldgs list |_PLAT_GREP online |_PLAT_GREP shared |_PLAT_GREP -v \"(\"" );
    my $dsklist = $sys->cmd($cmd);
    my @disk_array_lines = split( /\n/, $dsklist );
    my @disk_groups;
    for (@disk_array_lines) {
        my ($group) = (split)[3];
        if ( $group ne '-' ) {
            $group =~ s/[\(\)]//g;
            push( @disk_groups, $group );
        }
    }
    return EDRu::arruniq(@disk_groups);
}

sub ask_disk_group {
    my ($prod,$disk_group_ref,$disk_groups_ref,$usage) = @_;
    my $msg;
    while (1) {
        $msg=Msg::new("Enter the disk group name used for $usage:");
        $$disk_group_ref=$msg->ask('','',1);
        return "__back__" if (EDR::getmsgkey($$disk_group_ref,'back'));
        if ( EDRu::arrpos( $$disk_group_ref, @$disk_groups_ref ) == -1 ) {
            $msg=Msg::new("Are you sure you want to use $$disk_group_ref for $usage?");
            my $ayn=$msg->aynn;
            if ($ayn eq 'Y') {
                return 0;
            } else {
                next;
            }
        } else {
            return 0;
        }
    }
    return 1;
}

sub ask_volume {
    my ( $prod,$volume_ref, $volumes_ref, $usage ) = @_;
    my $msg;
    while (1) {
        $msg=Msg::new("Enter the volume name used for $usage:");
        $$volume_ref = $msg->ask('','',1);
        return "__back__" if (EDR::getmsgkey($$volume_ref,'back'));
        if ( EDRu::arrpos( $$volume_ref, @$volumes_ref ) == -1 ) {
            $msg=Msg::new("Are you sure you want to use $$volume_ref for $usage?");
            my $ayn = $msg->aynn;
            if ($ayn eq 'Y') {
                return 0;
            } else {
                next;
            }
        } else {
            return 0;
        }
    }
    return 1;
}


sub import_disk_group {
    my ($prod,$sys, $disk_group,$usage) = @_;
    my $cfg=Obj::cfg();

    # check whether it is imported
    my $disk_group_list = $sys->cmd("_cmd_vxdg list | _cmd_grep enabled | _cmd_awk '{print \$1}'");

    my @disk_groups = split( /\s+/, $disk_group_list );
    if ( EDRu::arrpos( $disk_group, @disk_groups ) == -1 ) {
        if($usage){
            $sys->cmd("_cmd_vxdg  import $disk_group" );
        } else {
            $sys->cmd("_cmd_vxdg  -s import $disk_group" );
        }
        if(EDR::cmdexit()!=0){
            return 0;
        } else {
            return 1;
        }
    }
    return 1;
}


sub ask_dg_vol_mnt {
    my ( $prod,$sys, $mount_hash_ref, $usage ) = @_;
    my ( $disk_group, $volume,$mnt,$msg,$msg_usage,$ayn,$uselocal,@disk_groups,$disk_groups_ref,$rtn,$choice,$cfg );

    $cfg=Obj::cfg();
    $msg_usage='';
    if ($usage=~/sybase installation/) {
        $msg_usage = Msg::new("sybase installation")->{msg};
    } elsif ($usage eq 'quorum device') {
        $msg_usage = Msg::new("quorum device")->{msg};
    } elsif ($usage eq 'database devices') {
        $msg_usage = Msg::new("database devices")->{msg};
    }

START: while (1) {
        unless($disk_groups_ref){
            if ( $usage eq 'sybase installation' ) {
                if($cfg->{sybase_location} == 1){
                    $msg=Msg::new("\nThe information about CFS used for Sybase ASE CE installation is required to configure Sybase in VCS\n");
                } else {
                    $msg=Msg::new("\nThe information about private file system used for Sybase ASE CE installation is required to configure Sybase in VCS\n");
                }
                $msg->print;
            } else {
                if ( $usage eq 'quorum device' ) {
                    $msg=Msg::new("If quorum device is under a different CFS/volume from Sybase installation, CFS/volume used for quorum device needs to be added into the resource group");
                    $msg->print;
                    Msg::n();
                    $msg=Msg::new("Is quorum device under a different CFS/volume from Sybase installation?");
                    $ayn=$msg->ayny('',1);
                    return 0 if (EDR::getmsgkey($ayn,'back'));
                    $uselocal=0;
                    last if ($ayn eq 'N');
                } else {
                    $msg=Msg::new("\nIf there are some other CFS/volumes used for database devices such as master device, Sybase system procedure device or system database device, these CFS/volumes need to be added into the resource group");
                    $msg->print;
                    Msg::n();
                    $msg=Msg::new("Would you like to add some other disk groups, volumes, or even mount points used for database devices to the resource group?");

                    $ayn = $msg->aynn('',1);
                    return 0 if (EDR::getmsgkey($ayn,'back'));
                    $uselocal=0;
                    last if ($ayn eq 'N');
                }
            }
        }
        # list all available disk groups for choice
        $uselocal=1 if($cfg->{sybase_location}==2 && $usage=~/sybase installation/);
        $disk_groups_ref = $prod->list_all_dgs($sys,$uselocal);
        if($cfg->{sybase_location}==2 && $usage=~/sybase installation/){
            if($prod->{used_dgs}){
                $disk_groups_ref= EDRu::arrdel($disk_groups_ref,@{$prod->{used_dgs}});
            }
        }
        @disk_groups     = @$disk_groups_ref;
        unless (@disk_groups) {
            $msg=Msg::new("There are no disk groups available. Create a shared disk group, then continue");
            $msg->warning;
            Msg::prtc();
            return 0;
        }

        #push( @disk_groups, "Enter the disk group name manually" );
        if($cfg->{sybase_location}==2 && $usage=~/sybase installation/){
            $msg=Msg::new("Select one of the following disk groups used for $msg_usage on $sys->{sys}:");
        } else {
            $msg=Msg::new("Select one of the following disk groups used for $msg_usage:");
        }
        $msg->print;
        Msg::n();
        $msg=Msg::new("Enter the disk group");
        LISTDG: while (1){
            $choice=$msg->menu(\@disk_groups,1,'',1);
            if (EDR::getmsgkey($choice,'back')){
                undef $disk_groups_ref;
                return '__back__';
            }
            $disk_group = $disk_groups[ $choice - 1 ];
            last;
        }
        # import specific disk group in order to list its volumes for choice
        $rtn=$prod->import_disk_group( $sys, $disk_group,$uselocal);
        if(!$rtn){
            $msg=Msg::new("The diskgroup $disk_group cannot be imported. It is recommended to check if it is available");
            $msg->warning;
            next;
        }
        push(@{$prod->{used_dgs}},$disk_group) if($cfg->{sybase_location}==2 && $usage=~/sybase installation/);
        # list all volumes of specific disk group
        my $volume_list = $sys->cmd("_cmd_vxprint -v -g $disk_group 2>/dev/null | _cmd_grep ACTIVE | _cmd_grep ENABLED | _cmd_awk '{print \$2}'");
        my @volumes = split(/\s+/, $volume_list);
        my @purified_volumes;
        for my $v (@volumes) {
            if($cfg->{sybase_location}==2 && $usage=~/sybase installation/){
                push @purified_volumes, $v;
            } else {
                if ( !exists $$mount_hash_ref{$disk_group}{$v} ) {
                    push @purified_volumes, $v;
                }
            }
        }

        unless (@purified_volumes) {
            $msg=Msg::new("There are no volumes available in disk group $disk_group. Create volumes or check volume status, then continue");
            $msg->warning;
            Msg::prtc();
            next;
        }

        #push( @purified_volumes, "Enter the volume name manually" );
        if($cfg->{sybase_location}==2 && $usage=~/sybase installation/){
            $msg=Msg::new("Select one of the following volumes used for $msg_usage on $sys->{sys}:");
        } else {
            $msg=Msg::new("Select one of the following volumes used for $msg_usage:");
        }
        $msg->print;
        Msg::n();
        $msg=Msg::new("Enter the volume");
        LISTVOL: while (1) {
            $choice=$msg->menu(\@purified_volumes,1,'',1);
            if (EDR::getmsgkey($choice,'back')){
                next START;
            }
            $volume = $purified_volumes[ $choice - 1 ];
            last;
        }
        if ( ( $usage eq 'quorum device' ) || ( $usage eq 'database devices' ) ) {
            if ( $usage eq 'quorum device' ) {
                $msg=Msg::new("Quorum device can use either volume $volume directly or a file under CFS created on volume $volume.");
                $msg->print;
            }else {
                $msg=Msg::new("Database devices can use either volume $volume directly or files under CFS on created on volume $volume.");
                $msg->print;
                undef $disk_groups_ref;
            }
            Msg::n();
            $msg=Msg::new("Is there a CFS created on volume $volume?");
            $ayn=$msg->ayny('',1);
            if ($ayn eq 'N') {
                $$mount_hash_ref{$disk_group}{$volume}{mount} = '';
                $$mount_hash_ref{$disk_group}{$volume}{usage} = $usage;
                last if ( $usage eq 'quorum device' );
                next;
            }
        }
        # mount point
        my $mount_point_list = $sys->cmd("_cmd_mount -v|_cmd_grep $disk_group|_cmd_grep $volume|_cmd_awk '{print \$3}'" );
        my @mount_points = split( /\s+/, $mount_point_list );

        while (1) {
            #$CPI::COMM{BACKOPT} = 1;
            #if($cfg->{sybase_location}==2 && $usage=~/sybase installation/ && (!$prod->{sybase_mnt})){
            if($cfg->{sybase_location}==2 && $usage=~/sybase installation/ && ($sys->{sys} eq @{CPIC::get("systems")}[-1]->{sys})){
                $msg=Msg::new("\nThe information about the common mount point used for the Sybase ASE CE binaries on the cluster nodes is required to configure Sybase in VCS.");
                $msg->bold;
                $msg=Msg::new("\nEnter the name of the mount point where Sybase ASE CE installation binaries will reside:");
            } elsif (($cfg->{sybase_location} != 2 && $usage=~/sybase installation/) || ( $usage eq 'quorum device' ) || ( $usage eq 'database devices' ) ) {
                $msg=Msg::new("\nEnter mount point on which volume $volume: ");
            } else {
                $mnt=$prod->{sybase_mnt} if($prod->{sybase_mnt});
                last;
            }
            $mnt = $msg->ask('','',1);
            next START if ( EDR::getmsgkey($mnt,'back') );

            unless ( $sys->is_dir($mnt ) ) {
                $msg=Msg::new("The mount point $mnt is not a valid directory.");
                $msg->warning;
                Msg::n();
                $msg=Msg::new("Are you sure you want to use $mnt for the mount point?");
                $ayn = $msg->aynn;
                #next if ( $CPI::COMM{BACK} );
                if ($ayn eq 'N') {
                    next ;
                }
            }
            last;
        }

        $$mount_hash_ref{$disk_group}{$volume}{mount} = $mnt;
        $$mount_hash_ref{$disk_group}{$volume}{usage} = $usage;
        $$mount_hash_ref{$disk_group}{$volume}{sys}=$sys->{sys} if($cfg->{sybase_location}==2 && $usage=~/sybase installation/);
        $prod->{sybase_mnt}=$mnt if($cfg->{sybase_location}==2 && $usage=~/sybase installation/);
        last if ( $usage eq 'sybase installation' ) || ( $usage eq 'quorum device' );
    }
    return 1;
}

sub ask_storage_resource {
    my ( $prod, $sys, $storage_resource_ref ) = @_;
    my ($msg,$msg1,$rtn,$cfg);
    $cfg=Obj::cfg();
    while (1) {
        $prod->{used_dgs}=[qw()];
        # $cfg->{sybase_location}=1 : sybase is on CFS
        # $cfg->{sybase_location}=2 : sybase is on local VxFS
        # $cfg->{sybase_location}=3 : sybase is on local OS filesytem
        $cfg->{sybase_location}=$prod->sybase_location_menu unless(Cfg::opt('responsefile') || $cfg->{sybase_location});
        return 0 unless ($cfg->{sybase_location});

        if($cfg->{sybase_location}==2){
            undef $prod->{sybase_mnt};
            foreach my $sysi (@{CPIC::get("systems")}){
                $rtn=$prod->ask_dg_vol_mnt( $sysi, $storage_resource_ref, 'sybase installation' );
                return 0 unless($rtn);
                last if (EDR::getmsgkey($rtn,'back'));
            }
        } else {
            $rtn=$prod->ask_dg_vol_mnt( $sys, $storage_resource_ref, 'sybase installation' ) unless($cfg->{sybase_location}==3);
        }
        return 0 unless($rtn);
        if (EDR::getmsgkey($rtn,'back')){
            undef $cfg->{sybase_location};
            next;
        }
        # ask disk group, volume and mount point for quorum
        $rtn=$prod->ask_dg_vol_mnt( $sys, $storage_resource_ref, 'quorum device' );
        return 0 unless($rtn);

        # ask disk groups, volumes and mount points for database devices
        $rtn=$prod->ask_dg_vol_mnt( $sys, $storage_resource_ref, 'database devices' );
        return 0 unless($rtn);

        # message verification
        #CPI::title();
        $msg=Msg::new("Disk groups, volumes and mount points information verification:\n");
        $msg->bold;
        $msg1="";
        for my $disk_group ( keys %$storage_resource_ref ) {
            for my $volume ( keys %{ $$storage_resource_ref{$disk_group} } ) {
                $msg1 .= Msg::new("\tDisk Group Name: $disk_group\n")->{msg};
                if ( $$storage_resource_ref{$disk_group}{$volume}{mount} ) {
                    $msg1 .= Msg::new("\tVolume: $volume\n")->{msg};
                    $msg1 .= Msg::new("\tMount Point: $$storage_resource_ref{$disk_group}{$volume}{mount}\n\n")->{msg};
                } else {
                    $msg1 .= Msg::new("\tVolume: $volume\n\n")->{msg};
                }
            }
        }
        Msg::print($msg1);
        Msg::n();
        $msg=Msg::new("Is this information correct?");
        my $ayn = $msg->ayny;

        last if ($ayn eq 'Y');

        # empty hash back-reference
        #%$storage_resource_ref = {};
        for my $key (keys %$storage_resource_ref) { delete $storage_resource_ref->{$key}};
        next;
    }
    return 1;
}


sub add_storage_resource {
    my ( $prod, $sys, $sybase_service_group, $binmnt_service_group, $storage_hash_ref ) = @_;
    my $cfg=Obj::cfg();
    for my $disk_group ( keys %$storage_hash_ref ) {
        {
            # by default, disk group belongs to sybase service group
            my $service_group = $sybase_service_group;

            # go through all volumes owned by disk group.
            # only if one of these volumes is used to install sybase, disk group should belong to binmnt service group instead.
            for my $volume ( keys %{ $$storage_hash_ref{$disk_group} } ) {
                if ( lc($$storage_hash_ref{$disk_group}{$volume}{usage}) eq 'sybase installation' ) {
                    $service_group = $binmnt_service_group;
                    last;
                }
            }

            # add disk group into service group specified by $service_group
            if($cfg->{sybase_location}==2 && $service_group=~/binmnt/){
                $prod->add_sybase_disk_group_local( $sys, $service_group, $disk_group . "_dg", $disk_group,$storage_hash_ref );
            } else {
                $prod->add_sybase_disk_group( $sys, $service_group, $disk_group . "_voldg", $disk_group, join( " ", keys %{ $$storage_hash_ref{$disk_group} } ) );
            }
        }

        # add volumes to specific service group according to usage
        for my $volume ( keys %{ $$storage_hash_ref{$disk_group} } ) {
            my $mount = $$storage_hash_ref{$disk_group}{$volume}{mount};

            # If mount point is existed, add CFS mount to resource group
            if ($mount) {
                # if volume is used to Sybase binary, add CFSmount to binmnt resource group
                # otherwise, this is added to sybase service group
                if ( lc($$storage_hash_ref{$disk_group}{$volume}{usage}) eq 'sybase installation' ) {
                    if($cfg->{sybase_location}==2 && $binmnt_service_group=~/binmnt/){
                        my $sysname=$$storage_hash_ref{$disk_group}{$volume}{sys};
                        $prod->add_sybase_volume_local( $sys, $binmnt_service_group, $disk_group . "_" . $volume, $volume,$disk_group,$sysname);
                        $prod->add_sybase_mount_point_local( $sys, $binmnt_service_group, $disk_group, $disk_group . "_" . $volume . "_mnt", $mount,$volume,$sysname);
                    } else {
                        $prod->add_sybase_mount_point( $sys, $binmnt_service_group, $disk_group, $disk_group . "_" . $volume . "_mnt", $mount, $volume );
                    }
                }
                else {
                    $prod->add_sybase_mount_point( $sys, $sybase_service_group, $disk_group, $disk_group . "_" . $volume . "_mnt", $mount, $volume );
                }
            } else {
                if ( lc($$storage_hash_ref{$disk_group}{$volume}{usage}) eq 'sybase installation' ) {
                    if($cfg->{sybase_location}==2 && $binmnt_service_group=~/binmnt/){
                        my $sysname=$$storage_hash_ref{$disk_group}{$volume}{sys};
                        $prod->add_sybase_volume_local( $sys, $binmnt_service_group, $disk_group . "_" . $volume, $volume,$disk_group,$sysname);
                        $prod->add_sybase_mount_point_local( $sys, $binmnt_service_group, $disk_group, $disk_group . "_" . $volume . "_mnt", $mount,$volume,$sysname);
                    }
                }
            }
        }
    }
    return;
}

sub add_sybase_disk_group {
    my ( $prod, $sys, $service_group, $disk_group_resource, $disk_group, $volumes ) = @_;
    $sys->cmd("_cmd_hares -add $disk_group_resource CVMVolDg $service_group" );
    $sys->cmd("_cmd_hares -modify $disk_group_resource CVMDiskGroup $disk_group" );
    $sys->cmd("_cmd_hares -modify $disk_group_resource CVMVolume $volumes" );
    $sys->cmd("_cmd_hares -modify $disk_group_resource CVMActivation sw" );
    $sys->cmd("_cmd_hares -modify $disk_group_resource Enabled 1" );
    return 0;
}

sub add_sybase_mount_point {
    my ( $prod,$sys, $service_group, $disk_group, $cfs_mount_resource, $mnt_point, $volume ) = @_;

    # add CFSMount resource to service group
    $sys->cmd("_cmd_hares -add $cfs_mount_resource CFSMount $service_group" );

    # modify CFSMount resource attributes
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource MountPoint $mnt_point" );
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource BlockDevice /dev/vx/dsk/$disk_group/$volume" );

    $sys->cmd("_cmd_hares -modify $cfs_mount_resource Enabled 1" );
    return 0;
}

sub add_sybase_disk_group_local {
    my ( $prod, $sys, $service_group, $disk_group_resource, $disk_group, $storageref ) = @_;
    my  $sysname ;
    for my $volume ( keys %{$storageref->{$disk_group}} ) {
            if ( lc($storageref->{$disk_group}{$volume}{usage}) eq 'sybase installation' ) {
                $sysname=$storageref->{$disk_group}{$volume}{sys};
                last;
            }
    }
    $disk_group_resource="sybase_install_dg";
    $sys->cmd("_cmd_hares -add $disk_group_resource DiskGroup $service_group" );
    $sys->cmd("_cmd_hares -local $disk_group_resource DiskGroup " );
    $sys->cmd("_cmd_hares -modify $disk_group_resource DiskGroup $disk_group -sys $sysname " );
    $sys->cmd("_cmd_hares -modify $disk_group_resource Enabled 1" );
    return 0;
}

sub add_sybase_volume_local {
    my ( $prod, $sys, $service_group, $disk_group_resource, $volumes,$disk_group,$sysname ) = @_;
    $disk_group_resource="sybase_install_vol";
    $sys->cmd("_cmd_hares -add $disk_group_resource Volume $service_group" );
    $sys->cmd("_cmd_hares -local $disk_group_resource Volume " );
    $sys->cmd("_cmd_hares -local $disk_group_resource DiskGroup " );
    $sys->cmd("_cmd_hares -modify $disk_group_resource Volume $volumes -sys $sysname" );
    $sys->cmd("_cmd_hares -modify $disk_group_resource DiskGroup $disk_group -sys $sysname" );
    $sys->cmd("_cmd_hares -modify $disk_group_resource Enabled 1" );
    return 0;
}


sub add_sybase_mount_point_local {
    my ( $prod,$sys, $service_group, $disk_group,$cfs_mount_resource, $mnt_point,$volume,$sysname) = @_;
    # add CFSMount resource to service group
    $cfs_mount_resource="sybase_install_mnt";
    $sys->cmd("_cmd_hares -add $cfs_mount_resource Mount $service_group" );
    #$sys->cmd("_cmd_hares -local $cfs_mount_resource MountPoint " );
    $sys->cmd("_cmd_hares -local $cfs_mount_resource BlockDevice " );

    # modify CFSMount resource attributes
    #$sys->cmd("_cmd_hares -modify $cfs_mount_resource MountPoint $mnt_point -sys $sysname" );
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource MountPoint $mnt_point" )if($mnt_point);
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource BlockDevice /dev/vx/dsk/$disk_group/$volume -sys $sysname" );
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource FSType vxfs" );
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource FsckOpt '%-y'" );
    $sys->cmd("_cmd_hares -modify $cfs_mount_resource Enabled 1" );
    return 0;
}

sub read_env_variables {
    my ($prod,$sybase_home) = @_;
    my ($fd,$env_file);
    return unless ($sybase_home);
    $env_file = $sybase_home . "/SYBASE.env";
    return unless( -e $env_file);
    if ( open $fd,'<', $env_file ) {
        while (<$fd>) {
            chomp;
            my ( $key, $value ) = split /=/;
            if ( $key && $value ) {
                $ENV{$key} = $value unless($key eq "PATH");
            }
        }
        close $fd;
    }else {
        Msg::log("File :$env_file does not exist.");
    }
    return;
}

sub read_default_values_from_run_script {
    my ( $prod,$sys, $ase_home, $server_ref, $default_sybase_version_ref, $default_quorum_device_ref ) = @_;

    $prod->read_env_variables($ase_home);
    if ( $ENV{"SYBASE_ASE"} ) {
        my $raw_sybase_version;
        ( undef, $raw_sybase_version ) = split /-/, $ENV{"SYBASE_ASE"};
        if ($raw_sybase_version) {
            my ( $major, $minor ) = split /_/, $raw_sybase_version;
            $$default_sybase_version_ref = $minor ? $raw_sybase_version : $major if $major;
        }

        if ( $ENV{"SYBASE"} ) {
            my $run_script_dir = $ENV{"SYBASE"} . "/" . $ENV{"SYBASE_ASE"} . "/install";
            for my $node ( keys %$server_ref ) {
                my $run_script = $run_script_dir . "/" . "RUN_" . $$server_ref{$node}{SERVER};
                if ( -e $run_script ) {
                    my $run_script_content = $sys->cmd("_cmd_cat $run_script" );
                    if ( $run_script_content =~ /--quorum_dev\s*=\s*([a-zA-Z0-9_\/]+)\s/ ) {
                        if ($1) {
                            $$default_quorum_device_ref = $1;
                            last;
                        }

                    }
                }
            }
        }
    }
    return;
}

sub ask_sybase_configuration {
    my ($prod,$sys) = @_;
    my ( %server,$owner,$home,$version,$sa,$pwd,$quorum,$msg,$msg1 );

    # set system name as key of hash
    for my $node ( @{CPIC::get("systems")} ) {
        $server{$node->{hostname}} = undef;
    }

  START: while (1) {
        Msg::title();
        $msg1=Msg::new("\nTo configure SYBASE ASE CE instance under VCS, gather following information.");
        $msg1->print;
        $msg='';
        # ask server
        for my $node ( sort keys %server ) {
            $msg1=Msg::new("\nEnter Sybase instance on $node:");
            $server{$node}{SERVER} = $msg1->ask('','',1);
            next START if (EDR::getmsgkey($server{$node}{SERVER},'back'));
            $msg .= Msg::new("\tSybase Server on $node: $server{$node}{SERVER}\n")->{msg};
        }
        # ask owner
        $msg1=Msg::new("\nEnter Sybase UNIX user name: ");
        $owner = $msg1->ask('sybase','',1);
        next if (EDR::getmsgkey($owner,'back'));
        $msg .= Msg::new("\tSybase UNIX user name: $owner\n")->{msg};

        # ask home
        while (1) {
            $msg1=Msg::new("\nEnter Sybase home directory where sybase binaries reside: ");
            $home = $msg1->ask('/opt/sybase','',1);
            next START if (EDR::getmsgkey($home,'back'));
            unless ( $sys->is_dir($home ) ) {
                $msg1=Msg::new("The Sybase home directory where sybase binaries reside $home cannot be accessed. This may be due to a file system not being mounted");
                $msg1->warning;
                Msg::n();
                $msg1=Msg::new("Are you sure you want to use $home for Sybase home directory where sybase binaries reside?");
                my $ayn = $msg1->aynn;
                if ($ayn eq 'N') {
                    next;
                }
            }
            last;
        }

        $msg .= Msg::new("\tSybase home directory where sybase binaries reside: $home\n")->{msg};

        $prod->read_env_variables($home);

        # read default sybase version, default quorum device from RUN_<instance> file if existed
        my $default_sybase_version;
        my $default_quorum_device;
        $prod->read_default_values_from_run_script( $sys, $home, \%server, \$default_sybase_version, \$default_quorum_device );

        # ask version
        #$CPI::COMM{DEFANSWER} = $default_sybase_version if $default_sybase_version;
        $msg1=Msg::new("\nEnter Sybase version:");
        $version = $msg1->ask($default_sybase_version,'',1);
        next START if (EDR::getmsgkey($version,'back'));
        $msg .= Msg::new("\tSybase version: $version\n")->{msg};

        # ask user id, password
        $msg1=Msg::new("\nDo you want to input the username and/or password for the Sybase Admin user\n(default username = 'sa', password='')?");
        my $ayn = $msg1->aynn('',1);
        # by default, plain text password is a blank one
        next START if (EDR::getmsgkey($ayn,'back'));
        my $plain_text_pwd = '';
        $pwd = '';
        my $vcs=$sys->prod("VCS60");
        if ($ayn eq 'Y') {
            $sa = $vcs->ask_username("sa");
            next if (EDR::getmsgkey($sa,'back'));
            $plain_text_pwd = $vcs->ask_userpassword();
        }
        else {
            $sa = "sa";
        }

        if ( EDRu::despace($plain_text_pwd) ) {
            $vcs->set_vcsencrypt;
            $pwd = $vcs->encrypt_password($plain_text_pwd );
        }

        $msg .= Msg::new("\tSybase sa: $sa\n")->{msg};
        $msg .= Msg::new("\tPasswords are not displayed\n")->{msg};

        # ask quorum
        while (1) {
            $msg1=Msg::new("\nEnter Sybase quorum:");
            $quorum = $msg1->ask($default_quorum_device,'',1);
            next START if (EDR::getmsgkey($quorum,'back'));
            unless ( $sys->exists($quorum ) ) {
                # There is a possibility that the volume where quorum located is not mounted.
                $msg1=Msg::new("The quorum file $quorum cannot be accessed now. This may be due to a file system not being mounted");
                $msg1->warning;
                Msg::n();
                $msg1=Msg::new("Are you sure you want to use $quorum for Sybase quorum?");
                $ayn = $msg1->aynn;
                if ($ayn eq 'N') {
                    next;
                }
            }
            last;
        }
        $msg .= Msg::new("\tSybase quorum: $quorum\n")->{msg};

        $msg1=Msg::new("Sybase configuration information verification:\n");
        $msg1->bold;
        Msg::print($msg);
        $msg1=Msg::new("Is this information correct?");
        $ayn=$msg1->ayny;
        last if ($ayn eq 'Y') ;
    }
    my $cfg=Obj::cfg();
    $cfg->{sfsybasece}{ase_server}  = \%server;
    $cfg->{sfsybasece}{ase_owner}   = $owner;
    $cfg->{sfsybasece}{ase_home}    = $home;
    $cfg->{sfsybasece}{ase_version} = $version;
    $cfg->{sfsybasece}{ase_sa}      = $sa;
    $cfg->{sfsybasece}{ase_pwd}     = $pwd;
    $cfg->{sfsybasece}{ase_quorum}  = $quorum;
    return;
}

sub encrypt_password {
    my ( $prod,$sys, $plan_text_pw ) = @_;
    my $epw = EDRu::despace( CPI::do_sys( $sys, "$CPI::PROD{VCS}{VCSENCRYPT} -agent $plan_text_pw" ) );
    return $epw;
}

# ask for user password
#sub ask_userpassword {
#    my ( $ask, $askc, $upw, $msg );
#    while (1) {
#        $msg = anslate("Enter the password: ");
#        print($msg);
#        CPI::do_local("stty -echo");
#        $ask = <STDIN>;
#        print("\n");
#        $ask = CPI::despace($ask);
#
#        # empty is allowed???
#        #   if( $ask eq '') {
#        #       CPI::pl("Empty passwords are not allowed.");
#        #       next;
#        #   }
#
#        CPI::do_local("stty echo");
#        $msg = CPI::translate("Enter again: ");
#        print($msg);
#        CPI::do_local("stty -echo");
#        $askc = <STDIN>;
#        CPI::do_local("stty echo");
#        print("\n");
#        $askc = CPI::despace($askc);
#        return "$ask" if ( $ask eq $askc );
#
#        CPI::pl_warn("Passwords do not match!");
#    }
#}

sub add_sybase_ase {
    my ($prod, $sys, $service_group, $ase_resource, $ase_server_ref, $ase_owner, $ase_home, $ase_version, $ase_sa, $ase_pwd, $ase_quorum ) = @_;

    # add ASE to service group
    $sys->cmd("_cmd_hares -add $ase_resource Sybase $service_group" );

    # modify Sybase resource attributes
    for my $node ( keys %$ase_server_ref ) {
        $sys->cmd("_cmd_hares -local  $ase_resource Server" );
        $sys->cmd("_cmd_hares -modify $ase_resource Server $$ase_server_ref{$node}{SERVER} -sys $node" );
    }
    $sys->cmd("_cmd_hares -modify $ase_resource Owner $ase_owner" );
    $sys->cmd("_cmd_hares -modify $ase_resource Home $ase_home" );
    $ase_version =~ /sybase/ || ($ase_version = 'sybase' . $ase_version);
    $sys->cmd("_cmd_hares -modify $ase_resource Version $ase_version" );
    $sys->cmd("_cmd_hares -modify $ase_resource SA $ase_sa" );

    $ase_pwd = EDRu::despace($ase_pwd);
    if ($ase_pwd) {
        $sys->cmd("_cmd_hares -modify $ase_resource SApswd $ase_pwd" );
    }
    else {
        # need not set attribute
        #$sys->cmd("_cmd_hares -modify $ase_resource SApswd  \"\" " );
    }

    $sys->cmd("_cmd_hares -modify $ase_resource Quorum_dev $ase_quorum" );
    $sys->cmd("_cmd_hares -modify $ase_resource Enabled 1" );
    return;
}



sub add_sybase_vxfend {
    my ( $prod,$sys, $service_group, $vxfend_resource ) = @_;

    # add vxfend to service group
    $sys->cmd("_cmd_hares -add $vxfend_resource Process $service_group" );
    $sys->cmd("_cmd_hares -modify $vxfend_resource PathName /sbin/vxfend" );
    #$sys->cmd("_cmd_hares -modify $vxfend_resource Arguments '%-m sybase -k /tmp/vcmp_socket'" );
    $sys->cmd("_cmd_hares -modify $vxfend_resource Arguments '%-m sybase -k /tmp/vcmp_socket'" );
    $sys->cmd("_cmd_hares -modify $vxfend_resource Enabled 1" );
    return;
}

sub link_binmnt_sybasece {
    my ( $prod,$sys, $sybase_service_group, $binmnt_service_group)=@_;

    $sys->cmd("_cmd_hagrp -link $binmnt_service_group cvm online local firm" );
    $sys->cmd("_cmd_hagrp -link $sybase_service_group $binmnt_service_group online local firm" );
    return;
}

sub create_group_resource_dependencies {
    my ( $prod,$sys, $sybase_service_group, $binmnt_service_group, $ase_resource, $mount_hash_ref, $vxfend_resource ) = @_;
    my $cfg=Obj::cfg();
    #$sys->cmd("_cmd_hagrp -link $binmnt_service_group cvm online local firm" );
    #$sys->cmd("_cmd_hagrp -link $sybase_service_group $binmnt_service_group online local firm" );

    # disk groups, mount points
    for my $disk_group ( keys %$mount_hash_ref ) {

        # Through checking whether there is a volume used to sybase binary in this diskgroup,
        # draw a conclusion, which service group this disk group should belong to,
        # sybase service group or binmnt service group

        my $disk_group_belongs_to_binmnt_service_group = 0;
        for my $volume ( keys %{ $$mount_hash_ref{$disk_group} } ) {
            if ( lc($$mount_hash_ref{$disk_group}{$volume}{usage}) eq 'sybase installation' ) {
                $disk_group_belongs_to_binmnt_service_group = 1;
                last;
            }
        }

        my $disk_group_resource            = $disk_group . "_voldg";
        my $there_are_mounts_in_disk_group = 0;

        for my $volume ( keys %{ $$mount_hash_ref{$disk_group} } ) {

            # volume is used through mount point
            if ( $$mount_hash_ref{$disk_group}{$volume}{mount} ) {
                $there_are_mounts_in_disk_group = 1;
                my $mount_resource = $disk_group . "_" . $volume . "_mnt";
                if ( lc($$mount_hash_ref{$disk_group}{$volume}{usage}) eq 'sybase installation' ) {
                    if($cfg->{sybase_location}==2){
                        $disk_group_resource=$disk_group . "_dg";
                        my $volume_group_resource=$disk_group . "_" . $volume;
                        #$sys->cmd("_cmd_hares -link $mount_resource $volume_group_resource" );
                        #$sys->cmd("_cmd_hares -link $volume_group_resource $disk_group_resource" );
                        $sys->cmd("_cmd_hares -link 'sybase_install_mnt' 'sybase_install_vol'" );
                        $sys->cmd("_cmd_hares -link 'sybase_install_vol' 'sybase_install_dg'");

                    } else {
                        $sys->cmd("_cmd_hares -link $mount_resource $disk_group_resource" );
                    }
                } else {
                    if ($disk_group_belongs_to_binmnt_service_group) {
                        $sys->cmd("_cmd_hares -link $ase_resource $mount_resource" );
                    } else {
                        $sys->cmd("_cmd_hares -link $mount_resource $disk_group_resource" );
                        $sys->cmd("_cmd_hares -link $ase_resource $mount_resource" );
                    }
                }
            }
        }

        # Sybase depends on this disk group directly if
        # 1. this group should belong to sybase service group instead of binmnt service group;
        # 2. furthermore, no volumes in this disk group are used to mount somewhere
        if ( !$disk_group_belongs_to_binmnt_service_group && !$there_are_mounts_in_disk_group ) {
            $sys->cmd("_cmd_hares -link $ase_resource $disk_group_resource" );
        }
    }

    $sys->cmd("_cmd_hares -link $ase_resource $vxfend_resource" );
    return;
}

sub create_run_scripts {
    my ( $prod,$sys, $ase_home, $ase_server_ref, $quorum, $owner ) = @_;
    my ($msg,$fd,$filetxt);
    # read environment if it has not been read yet
    $prod->read_env_variables($ase_home);

    if ( $ENV{"SYBASE"} && $ENV{"SYBASE_ASE"} ) {
        my $run_script_dir = $ENV{"SYBASE"} . "/" . $ENV{"SYBASE_ASE"} . "/install";
        for my $node ( keys %$ase_server_ref ) {
            my $run_script = $run_script_dir . "/" . "RUN_" . $$ase_server_ref{$node}{SERVER};
            my $sysobj=Obj::sys($node);
            if ($sysobj->exists($run_script) ) {
                $msg=Msg::new("RUN_file:$run_script already exists on $node");
                $msg->bold;
                my $run_script_content = $sys->cmd("_cmd_cat $run_script" );
                if ( $run_script_content =~ /--quorum_dev\s*=\s*([a-zA-Z0-9_\/]+)\s/ ) {
                    if ( $1 ne $quorum ) {
                        $msg=Msg::new("The quorum device configuration in $run_script is $1, which is different from current configuration - $quorum");
                        $msg->warning;
                        $msg=Msg::new("Do you want to update quorum device configuration in $run_script?");
                        my $ayn = $msg->ayny;
                        if ($ayn eq 'Y') {
                            $filetxt=$ENV{"SYBASE"} . "/" . $ENV{"SYBASE_ASE"} . "/bin/dataserver --instance_name=" . $$ase_server_ref{$node}{SERVER} . " --quorum_dev=" . $quorum;
                            $sysobj->writefile($filetxt,$run_script);
                        }
                    }
                }
            } else {
                $msg=Msg::new("Creating RUN file: $run_script on $node");
                $msg->left;
                Msg::log("creating RUN_file:$run_script on $node");
                $filetxt=$ENV{"SYBASE"} . "/" . $ENV{"SYBASE_ASE"} . "/bin/dataserver --instance_name=" . $$ase_server_ref{$node}{SERVER} . " --quorum_dev=" . $quorum;
                $sysobj->writefile($filetxt,$run_script);

                $sysobj->cmd("_cmd_chown $owner $run_script" );
                $sysobj->cmd("_cmd_chmod +x $run_script" );
                $msg->right_done();
            }
        }
    }
    return;
}

sub make_conf_rw {
    my ($prod,$vcs);
    $prod=shift;
    $vcs=$prod->prod("VCS60");
    $prod->{DUMP_CONF} = 1;
    $vcs->haconf_makerw();
    return;
}

sub dump_conf {
    my ($prod,$vcs);
    $prod=shift;
    $vcs=$prod->prod("VCS60");
    $prod->{DUMP_CONF} = 1;
    $vcs->haconf_dumpmakero();
    return;
}

sub cleanup {
    my ($syslist,$prod,$sys,$rtn);
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];
    $prod=$sys->prod('VCS60');
    $rtn = $sys->cmd("$prod->{bindir}/haclus -value ReadOnly");
    if ($rtn eq '0') {
        $sys->cmd("$prod->{bindir}/haconf -dump -makero");
        sleep 5;
    }
    return;
}

sub print_guide_sybase {
    my ($prod)=@_;
    my $edr=Obj::edr();
    my $msg  = Msg::new("\nThis step helps you configure the Sybase resource group in VCS. Before continuing, complete the following steps:\n");
    $msg->bold;
    my $step = 1;
    $msg = Msg::new("\t$step. Install storage foundation Sybase CE\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Configure VCS/SFCFS\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Configure I/O fencing in Sybase Mode\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Create Sybase OS user and group\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Create disk group, volume and file system for Sybase installation binary\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Create disk groups, volumes or CFS for database devices and quorum device\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Install Sybase ASE CE\n");
    $msg->bold;
    $step++;
    $msg = Msg::new("\t$step. Create Sybase ASE CE cluster\n");
    $msg->bold;
    return;
}

#sub cpi_pre_cleanup {
#    if ( $CPI::PROD{SFSYBASECE}{DUMP_CONF} ) {
#        $CPI::PROD{SFSYBASECE}{DUMP_CONF} = 0;
#        CPI::prod_sub( "UPI=VCS", "haconf_dumpmakero" );
#    }
#}
sub addnode_poststart {
    my $prod = shift;
    #my $cfg = Obj::cfg();
    #$cfg->{newnodes}=[qw(sol92215)];
    #$cfg->{clustersystems}=[qw(sol92203)];
    my $sfcfsha=$prod->prod('SFCFSHA60');
    $sfcfsha->addnode_poststart;

    #if($prod->addnode_ask_sybase_config){
    #   $prod->addnode_config_sybase;
    #}
    my $msg=Msg::new("\nThe nodes have been added into CVM. Manual steps are needed to configure Sybase ASE CE in VCS.\n");
    $msg->bold;
    return;
}

sub addnode_ask_sybase_config {
    my ($firstnode,$n,$rtn,$status,$sys,$sysi,$system,$ismnt,$issybase,$sybaseonline,$ayn,$msg);
    my $prod = shift;
    my $cprod=CPIC::get('prod');
    my $cfg = Obj::cfg();
    my $vcs = $prod->prod('VCS60');
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $system = Prod::VCS60::Common::transform_system_name($firstnode->{sys});
    $rtn=$firstnode->cmd("_cmd_hagrp -display -sys $system | _cmd_grep 'State'");
    $sybaseonline=1;
    foreach my $line (split(/\n/,$rtn)){
       if($line=~/binmnt/){
            $ismnt=1;
            $sybaseonline= 0 if($line !~/ONLINE/);
       }
       if($line=~/sybasece/){
            $issybase=1;
            $sybaseonline= 0 if($line !~/ONLINE/);
       }
    }
    $prod->{sybase_online}=$sybaseonline;
    if($ismnt && $issybase){
        while (1){
            $msg=Msg::new("Sybase ASE CE is configured on the cluster. Do you want to configure it on the new node(s)?");
            $ayn=$msg->ayny;
            if($ayn eq 'Y'){
                my $out=$firstnode->cmd("_cmd_hares -display -group binmnt | _cmd_grep 'sybase_install_dg'");
                if($out=~/sybase_install_dg/){
                    $cfg->{sybase_location}=2;
                    $prod->addnode_ask_binmnt;
                }
                $rtn=$prod->addnode_ask_sybase_server;
                next unless($rtn);
                return 1;
            }
            last;
        }
    }
    return 0;
}

sub addnode_ask_sybase_server {
    my ($prod)=@_;
    my ($sysi,$msg,$server,$cfg,$system);
    $cfg=Obj::cfg();
    for my $sysi (@{$cfg->{newnodes}}) {
        $system = Prod::VCS60::Common::transform_system_name($sysi);
        while (1){
            $msg=Msg::new("\nEnter Sybase instance on $sysi:");
            $server = $msg->ask('','',1);
            return 0 if (EDR::getmsgkey($server,'back'));
            last;
        }
        $cfg->{sfsybasece}{ase_server}{$sysi}{server}=$server;
    }
    return 1;
}

sub addnode_ask_binmnt {
     my ($prod)=@_;
     my ($sysi,$msg,$server,$cfg,$system,%hash,$firstnode);
     $cfg=Obj::cfg();
     $cfg->{sfsybasece}{storage_resource} = \%hash;
     $firstnode=Obj::sys(${$cfg->{clustersystems}}[0]);
     $prod->{sybase_mnt}=$firstnode->cmd("_cmd_hares -value sybase_install_mnt MountPoint 2>/dev/null");
     for my $sysi (@{$cfg->{newnodes}}) {
        $system = Prod::VCS60::Common::transform_system_name($sysi);
        my $sys=Obj::sys($sysi);
        $prod->ask_dg_vol_mnt($sys, $cfg->{sfsybasece}{storage_resource}, 'sybase installation' );
     }
     return 1;
}

sub addnode_config_sybase {
    my ($firstnode,$n,$rtn,$status,$sys,$sysi,$system,$server,$msg);
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
        $status=1;
        $system = Prod::VCS60::Common::transform_system_name($sysi);
        $msg=Msg::new("Configure binmnt on $system");
        $msg->left;
        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -modify binmnt SystemList -add $system $n");
        if(EDRu::isverror($rtn)) {
            Msg::log("Modify binmnt SystemList to add $sysi failed.");
            $status = 0;
        }

        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -modify binmnt AutoStartList -add $system");
        if (EDRu::isverror($rtn)) {
            Msg::log("Modify binmnt AutoStartList to add $sysi failed");
            $status = 0;
        }
        if($status){
            $msg->right_done();
        } else {
            $msg->right_failed();
        }
    }

    if($cfg->{sybase_location}==2){
        $prod->add_storage_resource( $firstnode, 'sybasece', 'binmnt', $cfg->{sfsybasece}{storage_resource} );
    }

    for my $sysi (@{$cfg->{newnodes}}) {
        $status=1;
        $msg=Msg::new("Configure Sybase ASE CE on $system");
        $msg->left;
        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -modify sybasece SystemList -add $system $n");
        if(EDRu::isverror($rtn)) {
            Msg::log("Modify sybasece SystemList to add $sysi failed.");
            $status = 0;
        }

        $rtn = $firstnode->cmd("$vcs->{bindir}/hagrp -modify sybasece AutoStartList -add $system");
        if (EDRu::isverror($rtn)) {
            Msg::log("Modify sybasece AutoStartList to add $sysi failed");
            $status = 0;
        }

        $rtn=$firstnode->cmd("_cmd_hares -modify ase Server $cfg->{sfsybasece}{ase_server}{$sysi}{server} -sys $system" );
        if (EDRu::isverror($rtn)) {
            Msg::log("Modify sybasece ase server on  $sysi failed");
            $status = 0;
        }

        if($status){
            $msg->right_done();
        } else {
            $msg->right_failed();
        }
    }

    $vcs->haconf_dumpmakero();
    #return unless($prod->{sybase_online});
    # Make newnode binmnt online

    for my $sysi (@{$cfg->{newnodes}}) {
        $system = Prod::VCS60::Common::transform_system_name($sysi);
        $prod->online_sg_sysname($system,"binmnt");
    }

    $cfg->{sfsybasece}{ase_quorum}=$firstnode->cmd("_cmd_hares -value ase Quorum_dev 2>/dev/null");
    $cfg->{sfsybasece}{ase_owner}=$firstnode->cmd("_cmd_hares -value ase Owner 2>/dev/null");
    $cfg->{sfsybasece}{ase_home}=$firstnode->cmd("_cmd_hares -value ase Home 2>/dev/null");
    $prod->create_run_scripts( $firstnode, $cfg->{sfsybasece}{ase_home}, $cfg->{sfsybasece}{ase_server}, $cfg->{sfsybasece}{ase_quorum}, $cfg->{sfsybasece}{ase_owner} );

    for my $sysi (@{$cfg->{newnodes}}) {
        $system = Prod::VCS60::Common::transform_system_name($sysi);
        $prod->online_sg_sysname($system,"sybasece");
    }

    return $status;
}

sub online_sg_sysname {
    my ($prod,$sysi,$sg)=@_;
    my ($msg,$status,$rtn,$firstnode,$cfg);
    $status=1;
    $cfg=Obj::cfg();
    $firstnode = Obj::sys(${$cfg->{clustersystems}}[0]);
    $msg=Msg::new("Online $sg on $sysi");
    $msg->left;
    $rtn = $firstnode->cmd("_cmd_hagrp -online $sg -sys $sysi");
    if (EDRu::isverror($rtn)) {
        Msg::log("Make $sg online failed on $sysi");
        $status = 0;
    }

    $rtn = $firstnode->cmd("_cmd_hagrp -wait $sg State ONLINE -sys $sysi -time 300");
    if (EDRu::isverror($rtn)) {
        Msg::log("Waiting for $sg state online failed on $sysi.");
        $status = 0;
    }
    if($cfg->{sybase_location}==2){
        $firstnode->cmd("_cmd_hares -online 'sybase_install_mnt' -sys $sysi 2>/dev/null");
        $firstnode->cmd("_cmd_hares -wait 'sybase_install_mnt' State ONLINE -sys $sysi -time 120");
    }

    if($status){
        $msg->right_done();
    } else {
        $msg->right_failed();
    }
    return;
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

sub poststart_configure_sys {
    my ($prod, $sys) = @_;

    if (!Obj::webui()){
        unless($prod->{cfscluster_config_pending}==1){
            $prod->config_menu();
        }
    }
    return;
}


package Prod::SFSYBASECE60::AIX;
@Prod::SFSYBASECE60::AIX::ISA = qw(Prod::SFSYBASECE60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='sfcfsha';
    $prod->{upgradevers}=[qw(4.0.4 5.0 5.1 6.0 6.0.1 6.0.3)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0 6.0.1 6.0.3)];

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
        VRTSjre.rte VRTSsfcpi601 VRTSperl514 VRTSperl.rte VRTSvlic32
    ) ];

    return;
}

# to handle VRTScavf version is 1.0.4 in 4.0MP4 release.
sub version_mapping {
    my ($prod,$vers)=@_;
    $vers='4.0.4' if (EDRu::compvers($vers, '1.0.4', 3)==0);
    return $vers;
}

package Prod::SFSYBASECE60::HPUX;
@Prod::SFSYBASECE60::HPUX::ISA = qw(Prod::SFSYBASECE60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_for_sybase_ce';
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1 6.0 6.0.1 6.0.3)];
    $prod->{zru_releases}=[qw()];

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
        VRTSjre15 VRTSjre VRTSsfcpi601 VRTSperl514 VRTSvlic32 VRTSwl
    ) ];
    return;
}


package Prod::SFSYBASECE60::Linux;
@Prod::SFSYBASECE60::Linux::ISA = qw(Prod::SFSYBASECE60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_for_sybase_ce';
    $prod->{upgradevers}=[qw(4.1.40 5.0 5.1 6.0 6.0.1 6.0.3)];
    $prod->{zru_releases}=[qw(5.0.30 5.1 6.0 6.0.1 6.0.3)];
    $prod->{menu_options}=['Veritas Volume Replicator','Veritas File Replicator','Global Cluster Option'];
    $prod->{platreqs} = ['SLES10 SP4 (2.6.16.60)'];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSvbs60 VRTSvcsea60 VRTScfsdc VRTSodm60 VRTSodm-platform
        VRTSodm-common VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi
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
        VRTSvxvm-common VRTSjre15 VRTSjre VRTSsfcpi601 VRTSperl514 VRTSvlic32
    ) ];
    return;
}

package Prod::SFSYBASECE60::RHEL5x8664;
@Prod::SFSYBASECE60::RHEL5x8664::ISA = qw(Prod::SFSYBASECE60::Linux);

package Prod::SFSYBASECE60::RHEL6x8664;
@Prod::SFSYBASECE60::RHEL6x8664::ISA = qw(Prod::SFSYBASECE60::Linux);

package Prod::SFSYBASECE60::SunOS;
@Prod::SFSYBASECE60::SunOS::ISA = qw(Prod::SFSYBASECE60::Common);

sub init_plat {
    my $prod=shift;
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{allpkgs}=[ qw(VRTSob34 VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{proddir}='storage_foundation_for_sybase_ce';

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTScsocw VRTSdbac60 VRTSvbs60 VRTSvcsea60 VRTScfsdc VRTSodm60
        VRTSgms60 VRTScavf60 VRTSglm60 VRTScpi VRTSd2doc VRTSordoc
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
        VRTSjre15 VRTSjre VRTSsfcpi601 VRTSperl514 VRTSvlic32
    ) ];
    return;
}

sub need_extra_mainpkgs_sys {
    my ($prod, $sys) = @_;
    if ($sys->{pkgvers}{'VRTSvcssy'} eq '5.0.1') {
        return 0;
    }
    return 1;
}

package Prod::SFSYBASECE60::SolSparc;
@Prod::SFSYBASECE60::SolSparc::ISA = qw(Prod::SFSYBASECE60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(4.1.2 5.0 5.1 6.0 6.0.1 6.0.3)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0 6.0.1 6.0.3)];
    return;
}



package Prod::SFSYBASECE60::Sol11sparc;
@Prod::SFSYBASECE60::Sol11sparc::ISA = qw(Prod::SFSYBASECE60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{allpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    return;
}

package Prod::SFSYBASECE60::Solx64;
@Prod::SFSYBASECE60::Solx64::ISA = qw(Prod::SFSYBASECE60::SunOS);

sub init_padv {
    my $prod=shift;
    return;
}

package Prod::SFSYBASECE60::Sol11x64;
@Prod::SFSYBASECE60::Sol11x64::ISA = qw(Prod::SFSYBASECE60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{minpkgs}=[ qw(VRTSglm60 VRTScavf60) ];
    $prod->{recpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    $prod->{allpkgs}=[ qw(VRTSglm60 VRTScavf60 VRTSgms60 VRTSodm60) ];
    return;
}

1;
