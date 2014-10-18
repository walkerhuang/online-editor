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

package Pkg::VRTSvxfen61::Common;
@Pkg::VRTSvxfen61::Common::ISA = qw(Pkg);

sub init_common {
    my ($pkg,$padv);
    $pkg=shift;
    $pkg->{pkg}='VRTSvxfen';
    $pkg->{name}=Msg::new("I/O Fencing")->{msg};

    $pkg->{startprocs}=[ qw(vxfen61) ];
    $pkg->{stopprocs}=[ qw(vxfen61) ];
    $pkg->{status}=0;
    $pkg->{vxfenmode_file}="/etc/vxfenmode";
    $pkg->{vxfendg_file}='/etc/vxfendg';
    $pkg->{vxenv_file}='/etc/vxenviron';
    $pkg->{llttab_sendhbcap}=1800;

    # define commands consistent across platforms
    $padv = $pkg->padv();
    $padv->{cmd}{vxfenadm} = '/sbin/vxfenadm';
    $padv->{cmd}{vxfendebug} = '/opt/VRTSvcs/vxfen/bin/vxfendebug';
    $padv->{cmd}{vxfenconfig} = '/sbin/vxfenconfig';
    return;
}

#
#################################################################
#               VXFEN CONFIGURATION SUPPORT                     #
#################################################################
# The apis for fencing (both CP based and disk based) is        #
# config_vxfen. This is being used by SFRAC, SVS, SFCFS/HA,     #
# SFHA and VCS products. And the api for CPS configuration is   #
# configure_cpc.                                                #
#################################################################

#################################################################
#>>>>>>>>       Implementation Starts                   <<<<<<<<#
#################################################################

#
# Configures fencing in disabled mode
#

sub configure_disabled_mode {
    my ($cfg,$cpic,$fencing_failed,$msg,$oldvxfenconf,$proc,$sys,$sys0,$str,$vcs,$web,$rst_vcs);
    my $pkg=shift;
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $web=Obj::web();
    $vcs = $pkg->prod('VCS61');
    $sys0 = ${CPIC::get('systems')}[0];
    $cfg->{fencing_option}=3;
    $cfg->{fencingenabled} = 0 if (defined($cfg->{fencingenabled}));
    undef($cfg->{non_scsi3_fencing}) if (defined($cfg->{non_scsi3_fencing}));
    $msg = Msg::new("I/O Fencing configuration");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    # CPS Clean Up
    # scenario:  migrate from CPS/non-scsi3 to disabled mode.
    # 1. remove cp agent if any.
    $pkg->remove_cpagent();
    Msg::n();
    $rst_vcs = $pkg->stop_vcsfen();
    if ($rst_vcs eq 'vcs_stop_failed') {
        Msg::n();
        $msg = Msg::new("Failed to stop VCS. VCS needs to be stopped before applying fencing configuration");
        $msg->bold;
        Msg::n();
        return;
    } else {
        unless (-3 == $pkg->{status}) {
           # 2. clean up cps database if vxfen is running in cps mode
           $oldvxfenconf = $vcs->get_vxfen_config_sys($sys0);
           $pkg->cleanup_from_cps($oldvxfenconf);
           # 3. vxfen config file clean up
           $pkg->update_vxfen_files_without_nonscsi3();
        }
    }

    $fencing_failed=0;
    for my $sys (@{$cpic->{systems}}) {
        # Populate /etc/vxfenmode with vxfen_mode=disabled
        if ($sys->exists($pkg->{vxfenmode_file})) {
            $str=EDRu::datetime();
            $sys->cmd("_cmd_cp $pkg->{vxfenmode_file} $pkg->{vxfenmode_file}-$str");
        }
        $msg=Msg::new("Configuring fencing in disabled mode on $sys->{sys}");
        $msg->left;
        $sys->cmd("echo vxfen_mode=disabled | _cmd_tee $pkg->{vxfenmode_file} 2>/dev/null");
        $proc=$pkg->proc('vxfen61');
        $proc->enable_sys($sys);
        if ($cpic->proc_start_sys($sys, $proc)) {
            CPIC::proc_start_passed_sys($sys, $proc);
            Msg::right_done();
        } else {
            $proc->{noreboot_failstart}=1;
            CPIC::proc_start_failed_sys($sys, $proc);
            Msg::right_failed();
            $fencing_failed=1;
        }
    }
    $pkg->update_maincf_without_usefence;

    # set vxfen starting status
    if ($fencing_failed) {
        # starting fencing in disable mode failed
        $pkg->{status} = -3;
    } elsif (-3 == $pkg->{status}) {
        # starting vxfen in enabled mode failed and successfully fell back to disable mode
        $pkg->{status} = -4;
    } else {
        # starting vxfen in disable mode succeeded
        $pkg->{status} = 1;
    }

    return;
}

sub update_maincf_without_usefence {
    my ($tmpdir,$maincf,$maincf_dir,$msg,$pkg,$str,$sys,$tmpmaincf,$vcs,$syslist);
    $pkg = shift;

    $tmpdir = EDR::tmpdir();
    $vcs=$pkg->prod('VCS61');
    $maincf_dir=$vcs->{configdir};
    $tmpmaincf='';
    $syslist=CPIC::get('systems');
    $sys=$$syslist[0];
    if($sys->cmd("_cmd_grep UseFence $maincf_dir/main.cf 2> /dev/null")) {
        $str=EDRu::datetime();
        $sys->cmd("_cmd_cp $maincf_dir/main.cf $maincf_dir/main.cf-$str");
        # Update main.cf to inform VCS that Fencing is not configured
        # delete UseFence=SCSI3 from main.cf
        $msg=Msg::new("Updating main.cf without fencing");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $maincf=$sys->readfile("$maincf_dir/main.cf");
        for my $line (split(/^/m,$maincf)) {
            next if($line=~/UseFence/m);
            $tmpmaincf.=$line;
        }
        EDRu::writefile($tmpmaincf,"$tmpdir/main.cf");
        for my $sys (@$syslist) {
            $pkg->localsys->copy_to_sys($sys,"$tmpdir/main.cf","$maincf_dir/main.cf");
        }
        Msg::right_done();
        $msg->display_right() if (Obj::webui());
    } else {
        Msg::log('Fencing is in disalbed mode, no need to update main.cf');
    }
    return;
}

sub cleanup_from_cps {
    my ($pkg,$oldvxfenconf) = @_;
    my ($cpspkg,$sys,$syslist);

    $cpspkg = $pkg->pkg('VRTScps61');
    $syslist=CPIC::get('systems');
    $sys = $$syslist[0];
    $sys->{system1} = 1;
    $cpspkg->cps_cleanup_sys($sys,$oldvxfenconf,1);
    return;
}

sub update_vxfen_files_without_nonscsi3 {
    my $pkg = shift;
    for my $sys (@{CPIC::get('systems')}) {
        $pkg->non_scsi3_restorefiles_sys($sys);
    }
    return;
}

sub ask_configure_cpagent {
    my ($pkg,$verbose) = @_;
    my ($ayn,$cfg,$msg,$ret);
    $cfg = Obj::cfg();
    return if ($pkg->check_cpagent_configured($verbose));
    # Ask if to configure CP Agent
    while (1) {
        $msg = Msg::new("The Coordination Point Agent monitors the registrations on the coordination points.");
        $msg->print;
        if (Cfg::opt('responsefile')) {
            $ayn = $cfg->{fencing_config_cpagent} ? 'Y' : 'N';
        } else {
            $msg = Msg::new("Do you want to configure Coordination Point Agent on the client cluster?");
            $ayn = $msg->ayny;
        }
        if ($ayn eq 'N') {
            $cfg->{fencing_config_cpagent} = 0 if (!Cfg::opt('responsefile'));
        } else {
            $cfg->{fencing_config_cpagent} = 1 if (!Cfg::opt('responsefile'));
            $ret = $pkg->configure_cpagent();
            next if (EDR::getmsgkey($ret,'back'));
            Msg::n();
        }
        last;
    }
    return;
}

sub disable_cpagent_level2freq {
    my $pkg = shift;
    my ($orig_level2,$out,$sys0);
    return unless ($pkg->check_cpagent_configured());
    $sys0 = ${CPIC::get('systems')}[0];
    $out = $sys0->cmd("_cmd_hares -display -attribute LevelTwoMonitorFreq -type CoordPoint 2> /dev/null | _cmd_grep -v '#'");
    if ($out && $out =~ /\s+(\d+)$/m) {
        $orig_level2 = $1;
        $pkg->modify_cpagent_level2freq(0) if ($orig_level2);
    }
    return $orig_level2;
}

sub enable_cpagent_level2freq {
    my ($pkg,$level2freq) = @_;
    return unless ($pkg->check_cpagent_configured());
    $pkg->modify_cpagent_level2freq($level2freq) if ($level2freq);
    return;
}

sub configure_cpagent {
    my (@add_cpagent_steps,$backopt,$cfg,$cmd,$failmsg,$help,$msg,$out,$pkg,$question,$res,$rtn,$sys,$sys0,$syslist,$vcs,$vxfengrp,$web);
    my ($defopt,$level2freq);
    $pkg = shift;
    $vxfengrp = '';
    $help = '';
    $backopt = 1;
    $syslist = CPIC::get('systems');
    $sys0 = $$syslist[0];
    $vcs = $pkg->prod('VCS61');
    $web = Obj::web();
    $cfg = Obj::cfg();
    if (Obj::webui()) {
        $vxfengrp = $sys0->cmd("$vcs->{bindir}/hagrp -list -localclus 2>/dev/null | _cmd_awk '{print \$1}' | _cmd_grep -w 'vxfen'");
        if ($vxfengrp eq '') {
            $vxfengrp = 'vxfen'; # Suggestion
        } else {
            $vxfengrp = ''; # No suggestion
        }
        $vxfengrp = $web->web_script_form('cpagent',$vxfengrp,$sys0,$vcs);
        # ask to configure LevelTwoMonitorFreq
        if (!$pkg->{no_coord_disks}) {
            Msg::n();
            $level2freq = $pkg->ask_cpagent_level2freq();
            return 'error' if ($level2freq eq 'error');
        }
    } else {
        while (1) {
            if (Cfg::opt('responsefile')) {
                $vxfengrp = $cfg->{fencing_cpagentgrp};
            } else {
                $vxfengrp = $sys0->cmd("$vcs->{bindir}/hagrp -list -localclus 2>/dev/null | _cmd_awk '{print \$1}' | _cmd_grep -w 'vxfen'");
                if ($vxfengrp eq '') {
                    $vxfengrp = 'vxfen'; # Suggestion
                } else {
                    $vxfengrp = ''; # No suggestion
                }
                $question = Msg::new("Enter a non-existing name for the service group for Coordination Point Agent:");
                $vxfengrp = $question->ask($vxfengrp, $help, $backopt);
            }
            return $vxfengrp if (EDR::getmsgkey($vxfengrp,'back'));
            if ($vcs->vcs_reservedwords($vxfengrp)) {
                $msg = Msg::new("Group name $vxfengrp for Coordination Point Agent is a VCS reserved word");
                $msg->print;
                return 'error' if (Cfg::opt('responsefile'));
                next;
            }
            if ($vxfengrp !~ /^\p{IsAlpha}[\w-]*$/mx) {
                $msg = Msg::new("Group name '$vxfengrp' for Coordination Point Agent has special character(s)");
                $msg->print;
                return 'error' if (Cfg::opt('responsefile'));
                next;
            }
            $out = $sys0->cmd("$vcs->{bindir}/hagrp -list -localclus 2>/dev/null | _cmd_awk '{print \$1}' | _cmd_grep -w $vxfengrp");
            if ($out ne '') {
                $msg = Msg::new("Group name $vxfengrp for Coordination Point Agent already exists");
                $msg->print;
                return 'error' if (Cfg::opt('responsefile'));
                next;
            }
            # ask to configure LevelTwoMonitorFreq
            if (!$pkg->{no_coord_disks}) {
                Msg::n();
                $level2freq = $pkg->ask_cpagent_level2freq();
                return 'error' if ($level2freq eq 'error');
            }
            last;
        }
    }
    $cfg->{fencing_cpagentgrp} = $vxfengrp;
    Msg::n();
    $msg = Msg::new("Adding Coordination Point Agent via $sys0->{sys}");
    $msg->left;
    # Makerw
    $out = $sys0->cmd("$vcs->{bindir}/haconf -makerw");
    if (EDR::cmdexit()) {
        if ($out !~ /Cluster already writable/m) {
            Msg::right_failed();
            $msg = Msg::new("Cannot make the VCS configuration read/write on $sys0->{sys}. Configure the Coordination Point Agent manually.");
            $msg->print;
            $web->web_script_form('alert',$msg)if (Obj::webui());
            Msg::prtc();
            return 'error';
        }
    }

    # Add group
    $cmd = "$vcs->{bindir}/hagrp -add $vxfengrp";
    $failmsg = Msg::new("Cannot add the group $vxfengrp on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    # Modify group
    my $sysnamelist = '';
    my $index = 0;
    for my $sys (@$syslist) {
        my $sysname = $sys->{vcs_sysname};
        $sysnamelist .= $sysname." $index ";
        $index++;
    }
    EDRu::despace($sysnamelist);
    $cmd = "$vcs->{bindir}/hagrp -modify $vxfengrp SystemList $sysnamelist";
    $failmsg = Msg::new("Cannot modify the SystemList attribute of the group $vxfengrp on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $cmd = "$vcs->{bindir}/hagrp -modify $vxfengrp AutoFailOver 0";
    $failmsg = Msg::new("Cannot modify the AutoFailOver attribute of the group $vxfengrp on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $cmd = "$vcs->{bindir}/hagrp -modify $vxfengrp Parallel 1";
    $failmsg = Msg::new("Cannot modify the Parallel attribute of the group $vxfengrp on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    # Add CoordPoint resource
    $cmd = "$vcs->{bindir}/hares -add coordpoint CoordPoint $vxfengrp";
    $failmsg = Msg::new("Cannot add the resource coordpoint to the group $vxfengrp on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    if ($level2freq) {
        $cmd = "$vcs->{bindir}/hares -override coordpoint LevelTwoMonitorFreq";
        $failmsg = Msg::new("Cannot override the LevelTwoMonitorFreq attribute of the resource coordpoint on $sys0->{sys}. Configure the Coordination Point Agent manually.");
        push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
        $cmd = "$vcs->{bindir}/hares -modify coordpoint LevelTwoMonitorFreq $level2freq";
        $failmsg = Msg::new("Cannot modify the LevelTwoMonitorFreq attribute of the resource coordpoint to $level2freq on $sys0->{sys}. Configure the Coordination Point Agent manually.");
        push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});
    }

    $cmd = "$vcs->{bindir}/hares -modify coordpoint Enabled 1";
    $failmsg = Msg::new("Cannot modify the Enabled attribute of the resource coordpoint to '1' on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $res = "RES_phantom_$vxfengrp";
    $cmd = "$vcs->{bindir}/hares -add $res Phantom $vxfengrp";
    $failmsg = Msg::new("Cannot add the resource $res to the group $vxfengrp on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    $cmd = "$vcs->{bindir}/hares -modify $res Enabled 1";
    $failmsg = Msg::new("Cannot modify the Enabled attribute of the resource $res to '1' on $sys0->{sys}. Configure the Coordination Point Agent manually.");
    push (@add_cpagent_steps, {'cmd'=>$cmd, 'failmsg'=>$failmsg});

    for my $step(@add_cpagent_steps) {
        $sys0->cmd($step->{cmd});
        if (EDR::cmdexit()) {
            Msg::right_failed();
            $step->{failmsg}->print;
            $web->web_script_form('alert',$step->{failmsg})if (Obj::webui());
            $rtn = 'error';
            last;
        }
    }

    if ($rtn eq 'error') {
        $sys0->cmd("$vcs->{bindir}/haconf -dump -makero");
        Msg::prtc();
        return 'error';
    }

    # Makero
    $sys0->cmd("$vcs->{bindir}/haconf -dump -makero");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        $msg = Msg::new("Cannot dump the VCS configuration into main.cf and make it read-only on $sys0->{sys}. Configure the Coordination Point Agent manually.");
        $msg->print;
        $web->web_script_form('alert',$msg)if (Obj::webui());
        Msg::prtc();
        return 'error';
    }
    Msg::right_done();
    return 'done';
}

# ask if user would like to set LevelTwoMonitorFreq of CP agent and the value
sub ask_cpagent_level2freq {
    my $pkg = shift;
    my ($answer,$ayn,$backopt,$cfg,$defopt,$done,$help,$level2freq,$msg,$web);
    $cfg = Obj::cfg();
    $web = Obj::web();
    $backopt = 1;
    $defopt = '5';
    $level2freq = 0;
    if (Cfg::opt('responsefile')) {
        $level2freq = $cfg->{fencing_cpagent_monitor_freq};
        return 'error' if (!$pkg->validate_level2freq($level2freq));
    } else {
        $msg = Msg::new("Additionally the Coordination Point Agent can also monitor changes to the Coordinator Disk Group constitution such as a disk being accidently deleted from the Coordinator Disk Group. The frequency of this detailed monitoring can be tuned with the LevelTwoMonitorFreq attribute. For example, if you set this attribute to 5, the agent will monitor the Coordinator Disk Group constitution every five monitor cycles. If LevelTwoMonitorFreq attribute is not set, the agent will not monitor any changes to the Coordinator Disk Group.");
        $msg->printn;
        $help = Msg::new("The value should be 0 to 65535. 0 means not to monitor the Coordinator Disk Group constitution.");
        while (1) {
            $msg = Msg::new("Do you want to set LevelTwoMonitorFreq?");
            $ayn = $msg->ayny();
            $done = 0;
            if ($ayn eq 'Y') {
                if (Obj::webui()){
                    $answer = $web->web_script_form('cpagent_level2freq',$pkg,$defopt);
                    #done = 2, back
                } else {
                    while (!$done) {
                        $msg = Msg::new("Enter the value of the LevelTwoMonitorFreq attribute(0 to 65535):");
                        $answer = $msg->ask($defopt,$help,$backopt);
                        if (EDR::getmsgkey($answer,'back')) {
                            $done = 2;
                            last;
                        }
                        next if (!$pkg->validate_level2freq($answer));
                        $done = 1;
                    }
                }
                next if ($done == 2);
                $level2freq = $answer;
                $cfg->{fencing_cpagent_monitor_freq} = $level2freq;
            }
            last;
        }
    }
    return $level2freq;
}

# If LevelTwoMonitorFreq of CP agent is not defined or set to 0
# Ask if user would like to set LevelTwoMonitorFreq and modify the LevelTwoMonitorFreq attribute
sub update_cpagent_level2freq {
    my $pkg = shift;
    my ($cfg,$level2freq,$out,$sys0);
    $sys0 = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();

    if (Cfg::opt('responsefile')) {
        $level2freq = $cfg->{fencing_cpagent_monitor_freq};
    } else {
        $out = $sys0->cmd("_cmd_hares -display -attribute LevelTwoMonitorFreq -type CoordPoint 2> /dev/null | _cmd_grep -v '#'");
        if (!$out || $out =~ /\s+0$/m) {
            $level2freq = $pkg->ask_cpagent_level2freq();
        }
    }
    if ($level2freq > 0) {
        $pkg->modify_cpagent_level2freq($level2freq);
    }
    return;
}

# modify the LevelTwoMonitorFreq attribute of CP agent to the given value
sub modify_cpagent_level2freq {
    my ($pkg,$level2freq) = @_;
    my ($msg,$out,$reslist,$sys0,$vcs);
    $sys0 = ${CPIC::get('systems')}[0];
    $vcs = $pkg->prod('VCS61');

    $vcs->haconf_makerw();
    $reslist = $sys0->cmd("_cmd_hares -list Type=CoordPoint -localclus 2>/dev/null| _cmd_awk '{print \$1}' | _cmd_uniq ");
    for my $res(split(/\n/,$reslist)) {
        $msg = Msg::new("Modifying LevelTwoMonitorFreq attribute of $res to $level2freq");
        $msg->left;
        $sys0->cmd("_cmd_hares -override $res LevelTwoMonitorFreq");
        $sys0->cmd("_cmd_hares -modify $res LevelTwoMonitorFreq $level2freq");
        if (EDR::cmdexit()) {
            $msg->right_failed;
            $msg = Msg::new("Cannot modify the LevelTwoMonitorFreq attribute of the resource $res to $level2freq on $sys0->{sys}. Configure it manually");
            $msg->error();
        } else {
            $msg->right_done;
        }
    }
    $vcs->haconf_dumpmakero();
    return;
}

sub check_cpagent_configured {
    my ($pkg,$verbose) = @_;
    my ($cpgrp,$msg,$out,$sys0,$vcs,$web);
    $sys0 = ${CPIC::get('systems')}[0];
    $vcs = $pkg->prod('VCS61');
    $web = Obj::web();
    $cpgrp = $sys0->cmd("$vcs->{bindir}/hares -display -attribute Group -type CoordPoint 2>/dev/null | _cmd_grep -v '^#' | _cmd_awk '{print \$1}'");
    if ($cpgrp) {
        return 1 if (!$verbose);
        $msg = Msg::new("There is already at least one group with a resource of type 'CoordPoint' as displayed below. Manually check if it has all the attributes set correctly.");
        $msg->print;
        $out = $sys0->cmd("$vcs->{bindir}/hares -display -attribute Group -type CoordPoint");
        Msg::print($out);
        Msg::prtc();
        if (Obj::webui()){
            $out =~ s/\s+/__SPACE__/g;
            my $result="";
            my @outArry=split(/__SPACE__/,$out);
            for (my $i=0;$i<@outArry;$i++){
                $outArry[$i]=EDRu::fixed_length_str($outArry[$i],20,'L');
                $result.=$outArry[$i];
                $result.="\\n" if ((($i%4)==3)&&($i!=@outArry-1));
            }
            $result =~ s/\s/&nbsp;/g;
            $web->web_script_form('alert',$msg->{msg}."\\n".$result);
        }
        return 1;
    }
    return 0;
}

sub remove_cpagent {
    my ($had,$msg,$pkg,$res,$sys0,$vcs,$vxfengrp,$vxfengrps,$vxfenres,$syslist);

    $pkg = shift;
    $syslist=CPIC::get('systems');
    $sys0 = $$syslist[0];
    $had = $pkg->proc('had61');
    return if (!($had->check_sys($sys0,'start')));
    $vcs = $pkg->prod('VCS61');
    $vxfengrps = $sys0->cmd("$vcs->{bindir}/hares -display -attribute Group -type CoordPoint 2> /dev/null |_cmd_grep -v '^#' | _cmd_awk '{print \$4}'");
    return '' if ($vxfengrps eq '');
    $vcs->haconf_makerw();
    for my $vxfengrp (split(/\n/, $vxfengrps)) {
        $msg = Msg::new("Deleting Coordination Point Agent Service Group $vxfengrp");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $vxfenres = $sys0->cmd("$vcs->{bindir}/hagrp -resources $vxfengrp -localclus 2> /dev/null");
        for my $res (split(/\n/, $vxfenres)) {
             $sys0->cmd("$vcs->{bindir}/hares -delete $res");
        }
        $sys0->cmd("$vcs->{bindir}/hagrp -delete $vxfengrp");
        $msg->right_done;
        $msg->display_right() if (Obj::webui());
    }
    $vcs->haconf_dumpmakero();
    return;
}

#
# Configure Fencing
# This function allows us to ask vxfen configuration
# questions for all platforms before starting it.
#
# It asks for diskgroup && disk policy and based on the
# inputs populates /etc/vxfenmode file, which is then
# used by fencing driver during startup. This function
# will not be called during normal startup by CPI core,
# so we need to start fencing driver manually here. Before
# configuring Fencing, VCS should be stopped as it's Fencing's
# client. The flow is:
#       a) Stop Fencing (If it's already started)
#       b) Configure Fencing
#       c) Start Fencing
#
#       $ret=-2   return from fencing configuration before starting vxfen
#       $ret=1    vxfen is configured in disabled mode
#       $ret=0    vxfen is configured in enbaled mode

sub configure_fencing {
    my ($pkg,$sys) = @_;
    my ($msg_cpc,$msg,$webmsg,$cprod,$maincf_dir,$cfg,$webresult,$web,$diskpolicyOptions,$msg_dsk,$backopt,$msg_disabled,$ayn,$fencing_failed,$dgtype,$str,$syslist,$msg_sybase,$menuopt,$tmpmaincf,$ret,$maincf,$tmpdir,$menu,$addmsg,$msg_migrate);
    my ($help,$mode,$vxfenmode,$msg_cp_order,$msg_refresh_keys);

    $backopt=1;
    $cfg=Obj::cfg();
    $web=Obj::web();
    $syslist=CPIC::get('systems');
    $tmpdir=EDR::tmpdir();

    # Run this routine only on the first node
    return 1 if (!$sys->system1);
    $fencing_failed=0;
    $ayn='Y';

    # verify response file for fencing option
    $pkg->verify_responsefile_for_fencing() if (Cfg::opt('responsefile') && Cfg::opt('fencing'));

    while (1) {
        # Actual code for Fencing configuration
        Msg::title();
        $msg=Msg::new("Fencing configuration");
        $msg->bold;

        $pkg->{newdg}='';
        # Input for configuring fencing (CP clients or disk-based)
        if (Cfg::opt('responsefile')) {
                $menu=$cfg->{fencing_option};
        } else {
            if (Obj::webui()){
                $webresult=$web->web_script_form('fencing_type',$pkg);
                $menu = $webresult->{fencingtype};
                $dgtype = $webresult->{dgtype};
                $diskpolicyOptions = $webresult->{mechanismOptions};
            } else {
                $menuopt=[];
                $msg_cpc=Msg::new("Configure Coordination Point client based fencing");
                $msg_sybase=Msg::new("Configure fencing in Sybase mode");
                $msg_dsk=Msg::new("Configure disk based fencing");
                $msg_disabled=Msg::new("Configure fencing in disabled mode");
                $msg_migrate=Msg::new("Replace/Add/Remove coordination points");
                $msg_refresh_keys=Msg::new("Refresh keys/registrations on the existing coordination points");
                $msg_cp_order=Msg::new("Set the order of existing coordination points");

                if(CPIC::get('prod')=~/SFSYBASECE/m){
                        if(Cfg::opt('fencing')){
                            push (@{$menuopt},$msg_sybase->{msg},$msg_migrate->{msg},$msg_refresh_keys->{msg});
                            $msg=Msg::new("Select the fencing mechanism to be configured in this Application Cluster:");
                            $menu=$msg->menu($menuopt,'','');
                            $menu++;
                            $menu++ if ($menu==3 || $menu==4);
                        } else {
                            $menu=2;
                        }
                } else {
                    $help = Msg::new("I/O fencing that uses coordinator disks is referred to as disk-based I/O fencing. I/O fencing that uses at least one CP server system is referred to as server-based I/O fencing. Server-based fencing can include only CP servers, or a mix of CP servers and coordinator disks. In virtualized environments that do not support SCSI-3 PR, VCS supports non-SCSI-3 server-based I/O fencing.");
                    push (@{$menuopt},$msg_cpc->{msg},$msg_dsk->{msg});
                    if (Cfg::opt('fencing')) {
                        push (@{$menuopt},$msg_disabled->{msg},$msg_migrate->{msg},$msg_refresh_keys->{msg},$msg_cp_order->{msg});
                    }
                    $msg=Msg::new("Select the fencing mechanism to be configured in this Application Cluster:");
                    $menu=$msg->menu($menuopt,'',$help);
                }
                Msg::n();
            }
        }
        $cfg->{fencing_option}=$menu;

        # check whether openssl is installed except choosing 3(Configure fencing in disabled mode)
        if ($menu != 3) {
            my $vcs = $pkg->prod('VCS61');
            return -2 unless $vcs->https_cpc_check_openssl_sys($sys);
        }

        # add a message to prompt users to configure fencing with 6.1.0 CP Server
        if ($menu == 1) {
            $webmsg = '';
            $msg = Msg::new("Communication between the CP server and application clusters will always be secured by HTTPS from 6.1.0 onwards, you must ensure that all the CP Servers that the client cluster uses as coordination points have been upgraded to 6.1.0 or later. If the CP server has lower version than the client cluster, fencing may not be configured properly in the client cluster.");
            $msg->printn;
            $webmsg .= $msg->{msg}.'\\n';
            $msg = Msg::new("Before configuring Coordination Point clients, make sure that the password-less rsh or ssh connection from clients to CP servers is configured.");
            $msg->printn;
            $webmsg .= $msg->{msg}.'\\n';
            $msg = Msg::new("Using Coordination Point server over HTTPS requires clock synchronization between the hosts. Make sure the time settings of the client cluster are synchronized with Coordination Point servers.");
            $msg->printn;
            $webmsg .= $msg->{msg}.'\\n';
            $web->web_script_form('alert', $webmsg) if(Obj::webui());
        }

        if (($menu == 1) || ($menu == 2)) {
            $help = Msg::new("The disk based or Coordination Point client based fencing requires setting the cluster level UseFence attribute. This attribute cannot be changed while the cluster is running. Installer will stop VCS to set the UseFence attribute. Installer will start VCS at the end of configuration.");
            $msg = Msg::new("This I/O fencing configuration option requires a restart of VCS. Installer will stop VCS at a later stage in this run. Note that the service groups will be online only on the systems that are in the 'AutoStartList' after restarting VCS. Do you want to continue?");
            if (Cfg::opt('responsefile')) {
                $ayn = 'Y';
            } else {
                # for SFSYBASECE, if not use -fencing, will not print the menu, so should not exist 'b' option
                if (CPIC::get('prod')=~/SFSYBASECE/m && !Cfg::opt('fencing')) {
                    $ayn = $msg->ayn('',$help);
                } else {
                    $ayn = $msg->ayn('',$help,$backopt);
                }
                next if (EDR::getmsgkey($ayn,'back'));
                Msg::n();
            }
            if ($ayn eq 'N') {
                if (Obj::webui()){
                    $web->{complete_failed} = 1;
                    return -2;
                }
                EDR::exit_exitfile();
            }
        }
        if ($menu==1) {
            $fencing_failed=$pkg->configure_cpc();
            $mode = 'cps' unless ($fencing_failed);
        }
        if ($menu==2) {
            $fencing_failed=$pkg->configure_dskfenc($dgtype,$diskpolicyOptions);
            unless ($fencing_failed) {
                $mode = (CPIC::get('prod')=~/SFSYBASECE/m) ? 'sybase' : 'disk';
            }
        }
        if ($menu==4) {
            $ret = $pkg->migrate_fencing();
            # back option
            next if ((EDR::getmsgkey($ret,'back')) || ($ret == -1));
            # recover the original LevelTwoMonitorFreq if it was set before migration
            # and at least one coordination disk
            $pkg->enable_cpagent_level2freq($pkg->{orig_cpagent_level2freq}) if ($pkg->{orig_cpagent_level2freq} &&
                $pkg->{cpagent_level2freq_disabled_by_cpi} && (!$pkg->{no_coord_disks}));
            if ($ret) {
                Msg::n();
                $web->{complete_failed}=1;
                $msg = Msg::new("Online fencing migration did not complete successfully");
                $msg->bold;
                $msg->add_summary();
                Msg::n();
            }
            return -2;
        }
        if ($menu == 5) {
            $ret = $pkg->refresh_cp_registrations();
            # back option
            next if ((EDR::getmsgkey($ret,'back')) || ($ret == -1));
            if ($ret) {
                Msg::n();
                $web->{complete_failed}=1;
                $msg = Msg::new("Online fencing migration did not complete successfully");
                $msg->bold;
                $msg->add_summary();
                Msg::n();
            }
            return -2;
        }
        if ($menu == 6) {
            $ret = $pkg->update_cp_order();
            # back option
            next if ((EDR::getmsgkey($ret,'back')) || ($ret == -1));
            if ($ret) {
                Msg::n();
                $web->{complete_failed}=1;
                $msg = Msg::new("Online fencing migration did not complete successfully");
                $msg->bold;
                $msg->add_summary();
                Msg::n();
            }
            return -2;
        }
        if ($menu==3) {
            # choose to configure fencing in disabled mode
            # check if vxfen is already running in disabled mode
            my $n = 0;
            my $m = 0;
            for my $tmpsys(@{$syslist}) {
                $vxfenmode = $pkg->vxfen_mode_sys($tmpsys);
                $n ++ if ($vxfenmode =~ /disabled/im);
                $m ++ if ($vxfenmode =~ /error/im);
            }
            if ($n == @{$syslist}) {
                $msg = Msg::new("Fencing is already running in disabled mode");
                $msg->bold;
                $web->web_script_form('alert', $msg) if (Obj::webui());
                Msg::prtc();
                next;
            }
            $addmsg=Msg::new("Installer will stop VCS before applying the I/O fencing configuration. To make sure VCS shuts down successfully, unfreeze any frozen service group and unmount the mounted file systems in the cluster. Note that the service groups will be online only on the systems that are in the 'AutoStartList' after restarting VCS.");
            $addmsg->bold;
            Msg::n();
            $msg=Msg::new("Are you ready to stop VCS and apply fencing configuration on all nodes at this time?");
            $ayn=$msg->ayny('',$backopt,$addmsg);
            $ayn='Y' if (Cfg::opt('responsefile'));
            next if (EDR::getmsgkey($ayn,'back'));
            if ($ayn eq 'N') {
                Msg::n();
                $web->{complete_failed}=1;
                $msg = Msg::new("Fencing configuration is not applied");
                $msg->printn;
                $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
                $ret=-2;
                last;
            }
            $pkg->{unconfigured} = 1 if ($m == @{$syslist});
            $pkg->configure_disabled_mode();
            $ret=1;
            last;
        }
        if ($fencing_failed eq '__back__') {
            next;
        } elsif ($fencing_failed == -1) {
            # back option
            next;
        } elsif ($fencing_failed == 1) {
            $msg=Msg::new("Do you want to retry fencing configuration?");
            $ayn=$msg->aynn('',$backopt);
            Msg::n();
            next if (($ayn eq 'Y')||(EDR::getmsgkey($ayn,'back')));
        } elsif ($fencing_failed == -2 ) {
            # return from fencing configuration
            $ret=-2;
            last;
        } else {
            # Check if main.cf already has UseFence attribute
            $maincf_dir='/etc/VRTSvcs/conf/config';
            $tmpmaincf='';
            unless($sys->cmd("_cmd_grep UseFence $maincf_dir/main.cf 2> /dev/null"))
            {
                $str=EDRu::datetime();
                $sys->cmd("_cmd_cp $maincf_dir/main.cf $maincf_dir/main.cf-$str");
                # Update main.cf to inform VCS that Fencing has been configured
                # add UseFence=SCSI3 to main.cf
                $msg=Msg::new("Updating main.cf with fencing");
                $msg->display_left($msg) if (Obj::webui());
                $msg->left;
                $maincf=$sys->readfile("$maincf_dir/main.cf");
                for my $line (split(/^/m,$maincf)) {
                    $tmpmaincf.=$line;
                    $tmpmaincf.="\tUseFence=SCSI3\n" if($line=~/^cluster/m);
                }
                EDRu::writefile($tmpmaincf,"$tmpdir/main.cf");
                for my $sys (@$syslist) {
                    $pkg->localsys->copy_to_sys($sys,"$tmpdir/main.cf","$maincf_dir/main.cf");
                }
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            }
            $ret=0;
        }
        if ($fencing_failed == 1) {
           # if starting fencing failed, start vxfen in disabled mode.
           if (-3 == $pkg->{status}) {
               $msg=Msg::new("Fencing will be configured in disabled mode");
               $msg->print;
               $pkg->configure_disabled_mode();
               $ret = 1;
               # destroy the dg created in fencing configuration
               $pkg->destroy_dg($pkg->{newdg}) if ($pkg->{newdg});
           } else {
               # other failure occurs before starting vxfen.
               $ret=-2;
           }
        }
        last;
    }

    # Inform others that Fencing configuration is Done.
    return ($ret,$mode);
}

sub validate_cps_port {
    my ($answer,@defports) = @_;
    my ($msg);

    if ($answer =~ /\D+/m ||
        ((!EDRu::inarr($answer,@defports)) && ($answer > 65535 || $answer < 49152))) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("Enter only a numerical value between 49152 and 65535 or the default value. Input again");
            $msg->print;
        }
        return 0;
    }
    return 1;
}

sub validate_cps_vip_num {
    my $number = shift;
    my $msg;
    if ($number =~ /\D+/m) {
        $msg = Msg::new("Enter only a numerical value. Input again");
        $msg->print;
        return 0;
    }
    if ($number < 1) {
        $msg = Msg::new("Invalid value. There must be at least one VIP or FQHN for the Coordination Point server. Input again");
        $msg->print;
        return 0;
    } elsif ($number > 65535) {
        # prevent too large number
        $msg = Msg::new("The number should be no more than 65535. Input again");
        $msg->print;
        return 0;
    }
    return 1;
}

#
# Subroutine to validate diskgroup
# which will be used by fencing driver
# during startup.
#
# Input: diskgroup name
# Output:
#       Return 1 if diskgroup is valid on all nodes
#       Return 0 if diskgroup is not valid on all nodes
#
sub validate_diskgroup {
    my ($pkg,$diskgroup,$nodg_check) = @_;
    my ($sys,$n,$syslist);
    $syslist=CPIC::get('systems');
    $n=0;
    for my $sys (@$syslist) {
        $sys->cmd("_cmd_vxdisk -o alldgs list | _cmd_grep -w $diskgroup");
        if (EDR::cmdexit()) {
            return 0 if (!$nodg_check);
            $n++;
        }
    }
    # if nodg_check flag is set
    # return 1 only if the diskgroup doesn't exist on any of the host
    return 0 if ( $nodg_check && ($n<scalar(@$syslist)) );
    return 1;
}

sub validate_dgname {
    my ($pkg,$dgname) = @_;
    my ($msg,$sys,$vcs,$cpic);
    $vcs=$pkg->prod('VCS61');
    if ($dgname !~ /^\w[\w-]*$/m) {
        unless (Cfg::opt('responsefile')) {
            $msg=Msg::new("Invalid name. Retry.");
            $msg->print;
        }
        return 0;
    }
    if ($vcs->vcs_reservedwords($dgname)) {
        unless (Cfg::opt('responsefile')) {
            $msg=Msg::new("The name $dgname is a VCS reserved word. Input again");
            $msg->print;
        }
        return 0;
    }
    return 1;
}

sub validate_dgnum {
    my ($pkg,$dgname) = @_;
    my ($msg,$web,$sys,$n,$prev,$syslist);
    $syslist=CPIC::get('systems');
    $web=Obj::web();
    for my $sys (@$syslist) {
        $n=$sys->cmd("_cmd_vxdisk -o alldgs list 2>/dev/null| _cmd_awk '{print \$4}'| _cmd_grep -w $dgname | _cmd_wc -l");
        chomp($n);
        if ($sys->system1) {
            $prev=$n;
        } elsif ($n!=$prev) {
            $msg=Msg::new("The number of disks in disk group $dgname on system $sys->{sys} does not match that on the first host");
            $msg->print;
            $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
            return 0;
        }
        if (($n <3) || ($n%2==0)) {
            $msg=Msg::new("The number of disks in disk group $dgname on system $sys->{sys} should be odd and no less than three");
            $msg->print;
            $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
            return 0;
        }
    }
    return 1;
}

sub validate_level2freq {
    my ($pkg,$number) = @_;
    my $msg;
    if ($number =~ /\D+/m) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("Enter only a numerical value. Input again");
            $msg->print;
        }
        return 0;
    }
    if ($number > 65535) {
        # prevent too large number
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("The number should be no more than 65535. Input again");
            $msg->print;
        }
        return 0;
    }
    return 1;
}

sub non_scsi3_supported {
   my $pkg = shift;
   my $cprod = CPIC::get('prod');
   return 0 if ($cprod =~ /SFRAC/m);
   return 1;
}

# if non scsi3 fencing
# move default DiskGroup attribute Reservation in types.cf from ClusterDefault to NONE
# for each resource of the type DiskGroup
# --1. set the value of the MonitorReservation attribute to 0
# --2. set the value of the Reservation attribute to NONE
sub non_scsi3_updateresources {
    my $pkg = shift;
    my ($dgres,$dg_res,$hacmd,$had,$maincmd,$sys0,$msg,$out,$ret,$vcs);

    $had = $pkg->proc('had61');
    $vcs = $pkg->prod('VCS61');
    $sys0 = ${CPIC::get('systems')}[0];
    if ($had->check_sys($sys0,'start')) {
        # vcs is running
        # make rw
        $vcs->haconf_makerw();
        # set default DiskGroup attribute Reservation in types.cf to NONE
        $sys0->cmd("$vcs->{bindir}/haattr -default DiskGroup Reservation NONE");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Cannot modify the default Reservation attribute of DiskGroup to NONE from $sys0->{sys}. Manually set default Reservation attribute to NONE for DiskGroup resource.");
            $msg->print;
        }
        $dg_res = $sys0->cmd("$vcs->{bindir}/hares -list Type=DiskGroup");
        if (!EDR::cmdexit() && $dg_res) {
            for my $dgres (split/\n/,$dg_res) {
                $dgres =~ s/\s+.*//m;
                $out = $sys0->cmd("$vcs->{bindir}/hares -value $dgres MonitorReservation");
                if (!EDR::cmdexit() && $out) {
                    # set the value of the MonitorReservation attribute to 0
                    $sys0->cmd("$vcs->{bindir}/hares -modify $dgres MonitorReservation 0");
                    if (EDR::cmdexit()) {
                        $msg = Msg::new("Cannot modify the MonitorReservation attribute of the resource $dgres to 0 from $sys0->{sys}. Manually set MonitorReservation attribute to 0 for DiskGroup resource.");
                        $msg->print;
                    }
                }
                $out = $sys0->cmd("$vcs->{bindir}/hares -value $dgres Reservation");
                if (!EDR::cmdexit() && ($out !~ /NONE/m)) {
                    # set the value of the attribute Reservation to NONE
                    $sys0->cmd("$vcs->{bindir}/hares -modify $dgres Reservation NONE");
                    if (EDR::cmdexit()) {
                        $msg = Msg::new("Cannot modify the Reservation attribute of the resource $dgres to NONE from $sys0->{sys}. Manually set MonitorReservation attribute to NONE for DiskGroup resource.");
                        $msg->print;
                    }
                }
            }
        }
        # make ro
        $vcs->haconf_dumpmakero();
    } else {
        # vcs is not running
        $ret = $vcs->translate_file_cf2cmd_sys($sys0,$vcs->{configdir},1);
        if ($ret) {
            $maincmd = $sys0->readfile("$vcs->{configdir}/main.cmd");
            $hacmd = "hatype -modify DiskGroup Reservation NONE\n";
            $maincmd .= $hacmd;
            $out = $sys0->cmd("_cmd_grep DiskGroup.*\\( $vcs->{maincf}");
            for my $line(split(/\n/,$out)) {
                if ($line =~ /\s*DiskGroup\s+(\S+)\s+\(/mx) {
                    $dgres = $1;
                    $maincmd =~ s/hares -modify $dgres Reservation .*/hares -modify $dgres Reservation NONE/mg;
                    $maincmd =~ s/hares -modify $dgres MonitorReservation .*/hares -modify $dgres MonitorReservation 0/mg;
                }
            }
            $sys0->writefile($maincmd,"$vcs->{configdir}/main.cmd");
            $ret = $vcs->translate_file_cmd2cf_sys($sys0,$vcs->{configdir});
            if ($ret) {
                for my $sys(@{CPIC::get('systems')}) {
                    next if ($sys->{sys} eq $sys0->{sys});
                    $sys0->copy_to_sys($sys,$vcs->{typescf});
                    $sys0->copy_to_sys($sys,$vcs->{maincf});
                }
            }
            $sys0->cmd("_cmd_rmr $vcs->{configdir}/main.cmd");
        }
    }
    return;
}

sub non_scsi3_updatefiles_sys {
    my ($pkg,$sys) = @_;
    my ($out,$msg,$vxenv_file,$tmpconf,$vxfen_vxfnd_tmt,$vxfen_initfile,$vcs,$line,$vxfen_proc,$suffix);

    $vxfen_vxfnd_tmt = 25;
    $vxenv_file = $pkg->{vxenv_file};
    $vcs = $sys->prod('VCS61');
    $vxfen_proc = $sys->proc('vxfen61');
    $vxfen_initfile = $vxfen_proc->{initconf};
    $suffix = EDRu::datetime();
    my $replaced;

    # set parameters for non-scsi3 fencing
    $msg = Msg::new("Updating $vxenv_file file on $sys->{sys}");
    $msg->left;
    $tmpconf = '';
    if ($sys->exists($vxenv_file)) {
        $out = $sys->readfile($vxenv_file);
        if ($out) {
            for my $line (split/^/m, $out) {
                if ($line =~ /^\s*data_disk_fencing\s*=/mx) {
                    $line = "data_disk_fencing=off\n";
                    $replaced = 1;
                }
                $tmpconf .= $line;
            }
        }
        if (!$replaced) {
            $tmpconf .= "data_disk_fencing=off\n";
        }
        $sys->cmd("_cmd_mv $vxenv_file $vxenv_file-$suffix");
        $sys->writefile($tmpconf, $vxenv_file);
    } else {
        $sys->cmd("echo data_disk_fencing=off > $vxenv_file" );
    }
    Msg::right_done();
    # update /etc/sysconfig/vxfen on Linux
    $replaced = 0;
    if (($sys->linux()) && $sys->exists($vxfen_initfile)) {
        $msg = Msg::new("Updating $vxfen_initfile file on $sys->{sys}");
        $msg->left;
        $tmpconf = '';
        $out = $sys->readfile($vxfen_initfile);
        if ($out) {
            for my $line (split/^/m, $out) {
                if ($line =~ /^\s*vxfen_vxfnd_tmt\s*=.*/mx) {
                    $line = "vxfen_vxfnd_tmt=$vxfen_vxfnd_tmt\n";
                    $replaced = 1;
                }
                $tmpconf .= $line;
            }
            if (!$replaced) {
                $tmpconf .= "vxfen_vxfnd_tmt=$vxfen_vxfnd_tmt\n";
            }
            $sys->cmd("_cmd_mv $vxfen_initfile $vxfen_initfile-$suffix");
            $sys->writefile($tmpconf, $vxfen_initfile);
        }
        Msg::right_done();
    }
    # update llttab
    if ($sys->exists($vcs->{llttab})) {
        $msg = Msg::new("Updating $vcs->{llttab} file on $sys->{sys}");
        $msg->left;
        $tmpconf = '';
        $out = $sys->readfile($vcs->{llttab});
        if ($out) {
            if ($out =~ /set-timer\s+sendhbcap:/mx) {
                for my $line (split/^/m, $out) {
                    $line =~ s/^.*set-timer\s+sendhbcap:.*/set-timer sendhbcap:$pkg->{llttab_sendhbcap}/m;
                    $tmpconf .= $line;
                }
            } else {
                for my $line (split/^/m, $out) {
                    $tmpconf .= $line;
                    $tmpconf .= "set-timer sendhbcap:$pkg->{llttab_sendhbcap}\n" if ($line =~ /set-cluster/mx);
                }
            }
            $sys->cmd("_cmd_mv $vcs->{llttab} $vcs->{llttab}-$suffix");
            $sys->writefile($tmpconf, $vcs->{llttab});
        }
        Msg::right_done();
    }
    return;
}

sub non_scsi3_restorefiles_sys {
    my ($pkg,$sys) = @_;
    my ($content,$suffix,$vcs,$vxenv_file,$vxfen_initfile,$vxfen_proc);

    $vxenv_file = $pkg->{vxenv_file};
    $vcs = $sys->prod('VCS61');
    $vxfen_proc = $sys->proc('vxfen61');
    $vxfen_initfile = $vxfen_proc->{initconf};
    $suffix = EDRu::datetime();

    # 1. restore /etc/vxenviron file
    if ($sys->exists($vxenv_file)) {
        $content = $sys->readfile("$vxenv_file");
        if ($content =~ /^\s*data_disk_fencing\s*=/mx) {
            Msg::log("Remove data_disk_fencing entry from $vxenv_file");
            $content =~ s/^\s*data_disk_fencing\s*=.*\n?//mg;
            $sys->cmd("_cmd_mv $vxenv_file $vxenv_file-$suffix");
            $sys->writefile($content, $vxenv_file);
        }
    }
    # 2. restore /etc/sysconfig/vxfen on Linux
    if (($sys->linux())) {
        if ($sys->exists($vxfen_initfile)) {
            $content = $sys->readfile($vxfen_initfile);
            if ($content =~ /^\s*vxfen_vxfnd_tmt\s*=/mx) {
                Msg::log("Comment out entry vxfen_vxfnd_tmt from $vxfen_initfile");
                $content =~ s/^\s*vxfen_vxfnd_tmt\s*=/#vxfen_vxfnd_tmt=/mg;
                $sys->cmd("_cmd_mv $vxfen_initfile $vxfen_initfile-$suffix");
                $sys->writefile($content, $vxfen_initfile);
            }
        }
    }
    # 3. restore /etc/llttab file
    if ($sys->exists($vcs->{llttab})) {
        $content = $sys->readfile($vcs->{llttab});
        if ($content  =~ /^\s*set-timer\s+sendhbcap:/mx) {
            Msg::log("Remove entry set-timer from $vcs->{llttab}");
            $content =~ s/^\s*set-timer\s+sendhbcap:.*\n?//mg;
            $sys->cmd("_cmd_mv $vcs->{llttab} $vcs->{llttab}-$suffix");
            $sys->writefile($content, $vcs->{llttab});
        }
    }
    # 4. /etc/vxfenmode file will be overwriten hence no need to restore
    return;
}

sub validate_cp_num {
    my ($number,$oldncp,$alldisk) = @_;
    my $msg;
    if ($number =~ /\D+/m) {
        $msg = Msg::new("Enter only a numerical value. Input again");
        $msg->print;
        return 0;
    }
    if (defined($oldncp)) {
        $number += $oldncp;
    }
    if($number == 1) {
        $msg = Msg::new("Symantec recommends at least three or more odd number of coordination points to avoid a single point of failure. However, if fencing is configured to use a single Coordination Point server, it is strongly recommended to make the Coordination Point server highly available by configuring it on a SFHA cluster. It is important to note that during a failover of the Coordination Point server in the SFHA cluster, if there is a network partition on the client cluster at the same time, the whole client cluster will be brought down because the arbitration facility will not be available for the duration of the failover.");
        if ($alldisk) {
            $msg=Msg::new("Total number of coordination points should be odd and no less than three. Input again");
            $msg->print;
            return 0;
        } else {
            $msg->warning;
            Msg::prtc();
        }
    }
    if ($number%2 == 0) {
        if ($oldncp) {
            $msg = Msg::new("Total number of coordination points which include both existing coordination points and new coordination points should be odd in number. Input again");
        } else {
            $msg = Msg::new("Total number of coordination points should be odd in number. Input again");
        }
        $msg->print;
        return 0;
    }
    return 1;
}

sub validate_cp_disk_num {
    my ($number,$ncp,$oldncp) = @_;
    my $msg;
    if ($number =~ /\D+/m) {
        $msg = Msg::new("Enter only a numerical value. Input again");
        $msg->print;
        return 0;
    }
    if ($number < 0) {
        $msg = Msg::new("The number cannot be negative. Input again");
        $msg->print;
        return 0;
    }
    if (defined($oldncp)) {
        if (($oldncp == 0) && ($ncp == 1) && ($number == $ncp)) {
            $msg = Msg::new("Invalid value. There must be at least one Coordination Point server as a coordination point.");
            $msg->print;
            return 0;
        } elsif ($number > $ncp) {
            $msg = Msg::new("Invalid value. Input again");
            $msg->print;
            return 0;
        }
    } else {
        if ($number == $ncp) {
            $msg = Msg::new("Invalid value. There must be at least one Coordination Point server as a coordination point.");
            $msg->print;
            return 0;
        } elsif ($number > $ncp) {
            $msg = Msg::new("Invalid value. The total number of disks cannot be larger than the total number of coordination points.");
            $msg->print;
            return 0;
        }
    }
    return 1;
}

sub validate_cps_vip_fqhn {
    my $answer = shift;
    my $msg;
    # fqhn must meet: no part can be all numbers; each part doesn't start or end with a hyphen.
    if (!EDRu::ip_is_ipv4($answer) && !EDRu::ip_is_ipv6($answer) &&
            ($answer !~ /^((?!\d+\.|-)[a-zA-Z0-9_\-]{1,}(?<!-)\.)+[a-zA-Z]{2,}$/mx)) {
        $msg = Msg::new("IP address/hostname: $answer doesnot seem to be valid. Input again");
        $msg->print;
        return 0;
    }

    if ($answer =~ /\"/m) {
        $msg = Msg::new("Double quote characters are not allowed as part of IP addresses or FQDNs. Input again");
        $msg->print;
        return 0;
    }
    return 1;
}

sub create_vxfencoorddg {
    my ($pkg,$disks,$dgname) = @_;
    my ($msg,$sys0,$initdisks,$disk,$tmpdsk,$ret,@initdisks,$web);
    $initdisks = '';
    $web = Obj::web();
    $sys0 = ${CPIC::get('systems')}[0];

    for my $disk (@{$disks}) {
        $tmpdsk = (split(/\s+/m, $disk))[0];
        $initdisks = $initdisks.$tmpdsk.' ';
        push (@initdisks, $tmpdsk);
    }

    # Initialize disks
    for my $tmpdsk (@initdisks) {
        $msg = Msg::new("Initializing disk $tmpdsk on $sys0->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $sys0->cmd("_cmd_vxdisk -f init $tmpdsk type=auto format=cdsdisk");
        if (EDR::cmdexit()) {
            Msg::right_failed();
            Msg::prtc();
            if (Obj::webui()) {
                $msg = Msg::new("Initializing disk $tmpdsk on $sys0->{sys} failed");
                $web->web_script_form('alert',$msg->{msg});
            }
            return 1;
        }
        Msg::right_done();
        $msg->display_right() if (Obj::webui());
    }

    # Assign disk group name
    $msg = Msg::new("Initializing disk group $dgname on $sys0->{sys}");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());
    $sys0->cmd("_cmd_vxdg -o coordinator=on init $dgname $initdisks");
    if (EDR::cmdexit()) {
        Msg::right_failed();
        Msg::prtc();
        if (Obj::webui()) {
            $msg = Msg::new("Initializing disk group $dgname on $sys0->{sys} failed");
            $web->web_script_form('alert',$msg->{msg});
        }
        return 1;
    }
    Msg::right_done();
    $msg->display_right() if (Obj::webui());
    $pkg->{newdg}=$dgname;

    # Deport the DG
    $ret = $pkg->deport_diskgroup_on_sys($sys0, $dgname);
    return $ret;
}

# from 6.0.1, the cpsadm server_security command changed the output to CPS SECURITY: 1\nFIPS MODE: 0
sub get_cps_security {
    my ($pkg,$cps_aref,$ports_href) = @_;
    my ($cpsadm,$msg,$security,$security_val,$cpspkg,$web,$fips_mode_val,$fips_mode,$rtn);
    $cpspkg=$pkg->pkg('VRTScps61');
    $cpsadm = $cpspkg->{cpsadm};
    $web = Obj::web();
    # Check the security status of CP servers
    $security_val = '';
    $fips_mode_val = '';
    for my $server(@{$cps_aref}) {
        if (!$server->exists('/etc/vx/.uuids/clusuuid')) {
            $msg=Msg::new("Unable to open /etc/vx/.uuids/clusuuid on $server->{sys}. Ensure the Coordination Point server has a valid UUID.");
            $msg->print;
            Msg::prtc();
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            return 'error';
        }
        $rtn = $security = $server->cmd("$cpsadm -s $server->{sys} -a server_security -p ${$ports_href}{$server->{sys}} 2>/dev/null");
        if (!EDR::cmdexit() && $security =~ /SECURITY:\s*(\d)/mx) {
            $security=$1;
            if ($security_val ne '' && $security_val != $security){
                $msg = Msg::new("All the Coordination Point servers are not in the same mode (secure or non-secure). It is mandatory to have all the Coordination Point servers in the same mode before configuring the client cluster");
                $msg->bold;
                Msg::prtc();
                $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
                return 'error';
            }
        } else {
            $security = -1; # Couldn't determine; will ask the user
        }
        $security_val = $security unless ($security == -1);

        if ($rtn =~ /FIPS\s+MODE:\s*(\d+)/imx) {
            $fips_mode=$1;
        } else {
            # consider it is not in fips mode, if the server does not support fips
            $fips_mode = 0;
        }
        if ($fips_mode_val ne '' && $fips_mode_val != $fips_mode){
            $msg = Msg::new("All the Coordination Point servers are not in the same mode (secure or non-secure or security with fips). It is mandatory to have all the Coordination Point servers in the same mode before configuring the client cluster");
            $msg->bold;
            Msg::prtc();
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            return 'error';
        }
        $fips_mode_val = $fips_mode;
    }

    return ($security,$fips_mode);
}

sub get_cps_version {
    my ($pkg,$cps) = @_;
    my ($cpspkg);
    $cpspkg = $pkg->pkg('VRTScps61');
    for my $sys (@$cps) {
        $sys->{cpsver}=$cpspkg->version_sys($sys);
        # set port number as 2821 if CPS version <=6.0
        # Otherwise port number is 14149
        $sys->{cpsport}= (EDRu::compvers($sys->{cpsver},'6.0',2)==2) ? 2821 : 14149;
    }
    return 1;
}

sub establish_trust_cps_cpc {
    my ($pkg,$cps,$noprint) = @_;
    my ($syslist,$vcs,$eat_env,$msg,$cpsat,$cpspkg,$rtn,$clientnode0,$web);

    $web = Obj::web();
    $syslist=CPIC::get("systems");
    $cpspkg = $pkg->pkg('VRTScps61');
    $cpsat = $cpspkg->{cpsat};
    $vcs=$pkg->prod('VCS61');
    $eat_env="EAT_DATA_DIR='$vcs->{eat_data_root}/CPSADM'";
    for my $clientnode (@$syslist) {
        for my $cpserver (@$cps) {
            $msg = Msg::new("Establishing trust between client cluster node $clientnode->{sys} and Coordination Point server node $cpserver->{sys}");
            ($noprint)? $msg->log() : $msg->left();
            if (Obj::webui()){
                ($noprint)? $msg->log() : $msg->display_left($msg);
            }
            $rtn = $clientnode->cmd("_cmd_yes y | $eat_env $cpsat setuptrust -b $cpserver->{sys}:$cpserver->{cpsport} -s high");
            if (EDR::cmdexit() && !$noprint) {
                Msg::right_failed();
                Msg::print("$rtn");
                Msg::prtc();
                $web->{complete_failed} = 1 if (Obj::webui());
                return 1;
            }
            Msg::right_done() unless ($noprint);
            if (Obj::webui()){
                $msg->display_right() unless ($noprint);
            }
        }
    }

    $clientnode0=$$syslist[0];
    for my $cpserver (@$cps) {
        $msg = Msg::new("Establishing trust between Coordination Point server $cpserver->{sys} and client cluster node $clientnode0->{sys}");
        ($noprint)? $msg->log() : $msg->left();
        if (Obj::webui()){
            ($noprint)? $msg->log() : $msg->display_left($msg);
        }
        if ($cpserver->{cpsport}==2821) {
            $eat_env="";
        } elsif ($cpserver->{cpsport}==14149) {
            $eat_env="EAT_DATA_DIR='$vcs->{eat_data_root}/CPSERVER'";
        }
        $rtn= $cpserver->cmd("_cmd_yes y | $eat_env $cpsat setuptrust -b $clientnode0->{sys}:14149 -s high");
        if (EDR::cmdexit() && !$noprint) {
            Msg::right_failed();
            Msg::print("$rtn");
            Msg::prtc();
            $web->{complete_failed} = 1 if (Obj::webui());
            return 1;
        }
        Msg::right_done() unless ($noprint);
        if (Obj::webui()){
            $msg->display_right() unless ($noprint);
        }
    }
    return 0;
}

sub ask_cps_num {
    my $pkg = shift;
    my ($answer,$backopt,$cfg,$defncp,$defndisks,$help,$ncp,$ndisks,$question,$ret,$msg);

    $cfg = Obj::cfg();
    $defncp = 3;
    $defndisks = 0;
    $ndisks = 0;
    $backopt = 1;
    $ret = 0;
    # Ask Coordination points numbers.
    while (1) {
        if (Cfg::opt('responsefile')) {
            $answer = $cfg->{fencing_ncp};
        } else {
            if ($pkg->{non_scsi3}) {
                $question = Msg::new("Enter the total number of coordination points. All coordination points should be Coordination Point servers:");
            } else {
                $question = Msg::new("Enter the total number of coordination points including both Coordination Point servers and disks:");
            }

            $answer = $question->ask($defncp, $help, $backopt);
            Msg::n();
        }
        return -1 if (EDR::getmsgkey($answer,'back'));
        chomp($answer);
        if (!validate_cp_num($answer)) {
            return 1 if (Cfg::opt('responsefile'));
            next;
        }
        $ncp = $answer;
        last;
    }
    if($answer != 1) {
        while (1) {
            if ($pkg->{non_scsi3}) {
                $ndisks = 0;
                last;
            }
            if (Cfg::opt('responsefile')) {
                $answer = $cfg->{fencing_ndisks};
            } else {
                $question = Msg::new("Enter the total number of disks among these:");
                $answer = $question->ask($defndisks, $help, $backopt);
                Msg::n();
            }
            chomp($answer);
            return -1 if (EDR::getmsgkey($answer,'back'));
            if (!validate_cp_disk_num($answer,$ncp)) {
                return 1 if (Cfg::opt('responsefile'));
                next;
            }
            $ndisks = $answer;
            last;
        }
    }

    return ($ret,$ncp,$ndisks);
}

sub ask_new_coord_points_num {
    my ($pkg,$oldncp) = @_;
    my ($answer,$alldisk_flag,$backopt,$cfg,$defncp,$defndisks,$help,$ncp,$ndisks,$question,$ret,$cpic,$sys,$vmmode,$vm_disabled,$msg);

    $cfg = Obj::cfg();
    $defncp = ($oldncp%2 == 0) ? (($oldncp == 0) ? 3 : 1) : 2 ;
    $defndisks = 0;
    $ndisks = 0;
    $backopt = 1;
    $ret = 0;
    # Check if VM is already running
    $cpic=Obj::cpic();
    $sys=${$cpic->{systems}}[0];
    $vmmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    $vm_disabled = 1 if ($vmmode !~ /enable/m);
    # Ask Coordination points numbers.
    while (1) {
        if (Cfg::opt('responsefile')) {
            $answer = $cfg->{fencing_ncp};
        } else {
            if ($pkg->{sybase_mode}) {
                $question = Msg::new("Enter the total number of new coordination points");
                $alldisk_flag = 1;
            # if VRTSvxvm isn't installed, all of the new coordination points should be servers
            } elsif ($vm_disabled) {
                $msg = Msg::new("Volume Manager is not running, only Coordination Point Servers will be asked as Coordination Points");
                $msg->printn;
                $question = Msg::new("Enter the total number of new Coordination Points Servers");
            } else {
                $question = Msg::new("Enter the total number of new coordination points including both Coordination Point servers and disks:");
            }
            $answer = $question->ask($defncp, $help, $backopt);
            Msg::n();
        }
        chomp($answer);
        return $answer if (EDR::getmsgkey($answer,'back'));
        if (!validate_cp_num($answer,$oldncp,$alldisk_flag)) {
            return 1 if (Cfg::opt('responsefile'));
            next;
        }
        $ncp = $answer;
        last;
    }
    $ndisks = $ncp if ($pkg->{sybase_mode});
    while (1) {
        last if (($pkg->{sybase_mode}) || (($oldncp == 0) && ($ncp == 1)) || ($ncp == 0) || $vm_disabled);
        if (Cfg::opt('responsefile')) {
            $answer = $cfg->{fencing_ndisks};
        } else {
            $question = Msg::new("Enter the total number of disks among these:");
            $answer = $question->ask($defndisks, $help, $backopt);
        }
        chomp($answer);
        return $answer if (EDR::getmsgkey($answer,'back'));
        if (!validate_cp_disk_num($answer,$ncp,$oldncp)) {
            return 1 if (Cfg::opt('responsefile'));
            next;
        }
        $ndisks = $answer;
        last;
    }
    Msg::n() unless ($pkg->{sybase_mode} || $vm_disabled);
    return ($ret,$ncp,$ndisks);
}

sub ask_cps {
    my ($pkg,$ncp,$ndisks,$defport,$current_cps_aref) = @_;
    my (@cps,@cpsvips,%ports,$answer,$backopt,$cfg,$cpsadm,$cpserver,$cps_sys1,$defcnt,$help,$index,$msg,$out,$question,$sys,$vip_counts,$vrtscps_pkg,@cps_host);
    $backopt = 1;
    $defcnt = 1;
    $cfg = Obj::cfg();
    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    $cpsadm = $vrtscps_pkg->{cpsadm};

    for ($index = 0; $index < ($ncp - $ndisks); $index++) {
        my $number = $index + 1;
        # Ask to input the number of VIPs/FQHN
        if (!Cfg::opt('responsefile')) {
            $question = Msg::new("How many IP addresses would you like to use to communicate to Coordination Point Server #$number?");
            $help = Msg::new("Each Coordination Point Server may have more than one Virtual IP address configured. Input the total number of the Virtual IP addresses you would like to use to communicate to the Coordination Point Server.");
            while (1) {
                $answer = $question->ask($defcnt, $help, $backopt);
                chomp($answer);
                return -1 if (EDR::getmsgkey($answer,'back'));
                next if (!validate_cps_vip_num($answer));
                last;
            }
        }
        Msg::n();
        if (Cfg::opt('responsefile')) {
            $cpserver = shift(@{$cfg->{fencing_cps}});
            $vip_counts = scalar(@{$cfg->{fencing_cps_vips}->{"$cpserver"}});
        } else {
            $vip_counts = $answer;
        }
        for my $vip_index(1..$vip_counts) {
            # Ask to input the VIPs/FQHN
            if (Cfg::opt('responsefile')) {
                $answer = shift(@{$cfg->{fencing_cps_vips}->{"$cpserver"}});
            } else {
                $question = Msg::new("Enter the Virtual IP address or fully qualified host name #$vip_index for the HTTPS Coordination Point Server #$number:");
                $help = '';
                $answer = $question->ask('', $help, $backopt);
            }
            chomp($answer);
            return -1 if (EDR::getmsgkey($answer,'back'));
            if (!validate_cps_vip_fqhn($answer)) {
                return 1 if (Cfg::opt('responsefile'));
                redo;
            }
            my @tmpcpsvips = @cpsvips;
            push (@tmpcpsvips,$answer);
            if (!EDRu::arr_isuniq(@tmpcpsvips)) {
                $msg = Msg::new("Duplicate of previous Coordination Point Server entry. Input again");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                redo;
            }
            # Check if given VIP is duplicate of current cps's vips
            if ($current_cps_aref) {
                if (!$pkg->validate_new_cps_vip($current_cps_aref,$answer)) {
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }
            }
            # Check for communication
            # Assign a Sys object to this CPS
            $sys = $pkg->create_cps_sys($answer);
            # Check if we can communicate with this system
            if (!$pkg->cps_transport_sys($sys)) {
                $msg=Msg::new("Cannot communicate with system $sys->{sys}. Make sure password-less rsh or ssh is configured or the CP Server is up and running.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                redo;
            }
            # Check if vips of each cps points to the same host
            if (1 != $vip_index) {
                if ($sys->{hostname} ne $cps_sys1->{hostname}) {
                    $msg=Msg::new("The VIP or FQHN $answer does not point to the same host as $cps_sys1->{sys}. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }
            # for different cp servers, the host pointed by vip should not be same
            } else {
                if (EDRu::inarr($sys->{hostname}, @cps_host)) {
                    $msg=Msg::new("The specified VIP '$sys->{sys}' points to the same server '$sys->{hostname}' with one previous IP. Re-enter IP address");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }
            }

            # reset vip for each sys
            $sys->{vips} = [] if ($vip_index == 1);
            Msg::n();
            # Ask for the port to connect to
            if (Cfg::opt('responsefile')) {
                $defport = $vrtscps_pkg->get_cps_port($sys);
                $answer = $cfg->{fencing_cps_ports}->{"$sys->{sys}"};
            } else {
                #$question = Msg::new("Enter the port in the range [49152, 65535] which the Coordination Point Server $sys->{sys} would be listening on or simply accept the default port suggested:");
                $question = Msg::new("Enter the port that the coordination point server $sys->{sys} would be listening on or accept the default port suggested:");
                $defport = $vrtscps_pkg->get_cps_port($sys);
                $answer = $question->ask($defport, $help, $backopt);
            }
            chomp($answer);
            return -1 if (EDR::getmsgkey($answer,'back'));
            if (!validate_cps_port($answer,$defport)) {
                return 1 if (Cfg::opt('responsefile'));
                redo;
            }

            # check if the vip and port is for HTTPS or IPM
            my $vip_port_type = $vrtscps_pkg->check_vip_port_cps_type_sys($sys,$answer);
            if ($vip_port_type ne "https_vip_port") {
                $msg=Msg::new("The CP server for the specified VIP or FQHN '$sys->{sys}' and port $answer is not a HTTPS CP server. Re-enter values");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                redo;
            }
#            $out = $sys->cmd("$cpsadm -s $sys->{sys} -p $answer -a ping_cps");
#            if ($out !~ /successfully pinged/) {
#                $msg=Msg::new("The host name or host IP address of the Coordination Point server may be incorrect or the Coordination Point server may not be configured or running on $sys->{sys} or it is not listening on port $answer. Input again");
#                $msg->print;
#                return 1 if (Cfg::opt('responsefile'));
#                redo;
#            }
            # valid ip and port
            push (@cpsvips,$sys->{sys});
            $ports{$sys->{sys}} = $answer;
            if ($vip_index == 1) {
                $cps_sys1 = $sys;
                push (@cps, $cps_sys1);
                push (@cps_host, $sys->{hostname});

            }
            $cps_sys1->{port}->{$sys->{sys}} = $answer;
            push (@{$cps_sys1->{vips}}, $sys->{sys});
            Msg::n();
        }
    }
    return (0, \@cps, \%ports);
}

sub web_get_cps_disks {
    my ($pkg, $ndisks) = @_;
    my (@alldisks,@disks,@expt_free_disks,$dgname,$disk,$disklist,$errstr,$group,$diskpolicy,$msg,$ret,$unused,$vxvmdisks,$ayn);
    my $sys0 = ${CPIC::get('systems')}[0];
    my $web=Obj::web();
    $ret = 0;

    while (1) {
        eval {$disklist = $pkg->get_dglist_sys($sys0);};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem in getting the list of available disks on $sys0->{sys}");
            $web->web_script_form("alert",$msg);
            return 1;
        }
        @alldisks = @{$disklist->{disks}} if (defined($disklist->{disks}));
        @expt_free_disks = @{$disklist->{disks_exported_free}} if (defined($disklist->{disks_exported_free}));

        if ($#alldisks + 1 == 0 && $#expt_free_disks >= 0) {
            next unless ($pkg->ask_unexport_disk eq 'N');
        }
        last;
    }

    while (1) {
        if ($#alldisks + 1 < $ndisks) {
            my $numdisks = $#alldisks + 1;
            $msg = Msg::new("System $sys0->{sys} has only $numdisks free disks out of which $ndisks coordination disks could not be configured");
            $web->web_script_form("alert",$msg);
            ($ret,$vxvmdisks) = $pkg->init_vxvm_disks();
            return $ret if ($ret);
            if (@{$vxvmdisks}) {
                @alldisks=@{EDRu::arruniq(@alldisks,@{$vxvmdisks})};
                next;
            } else {
                return 1;
            }
        }
        last;
    }

    my $flag = 1;
    while($flag){
    	$flag = 0;
        my $result = $web->web_script_form("coordination_disk",$pkg,\@alldisks,$ndisks);
        $msg = Msg::new("Before you continue with configuration, Symantec recommends that you run the vxfentsthdw utility (I/O fencing test hardware utility), in a separate console, to test whether the shared storage supports I/O fencing.  You can access the utility at '/opt/VRTSvcs/vxfen/bin/vxfentsthdw'.");
        $web->web_script_form("alert",$msg);
        my @multisels = @{$result->{disks}};
        undef @disks;
        for my $index(@multisels) {
            $disk=$alldisks[$index-1];
            push (@disks, $disk);
        }

        ($ret,$dgname) = $pkg->ask_new_fencing_dgname();
        $diskpolicy = $web->{migration_mechanism};
        undef $web->{migration_mechanism};

        my $devpath = '/dev/vx/rdmp/';
        unless ($diskpolicy eq 'raw') {
            for my $disk (@disks) {
                $unused = $sys0->cmd("_cmd_vxfenadm -r $devpath$disk");
                if (EDR::cmdexit()) {
                    $msg = Msg::new("Problem reading the reservation on the disk specified by the disk path $devpath$disk");
                    $flag = 1;
                    last;
                } elsif ($unused !~ /No keys/m) {
                    $msg = Msg::new("The disk $disk seems to have already been reserved. Try a different disk or unreserve this disk and then try again.");
                    $flag = 1;
                    last;
                }

                $unused = $sys0->cmd("_cmd_vxfenadm -s $devpath$disk");
                if (EDR::cmdexit()) {
                    $msg = Msg::new("Problem reading the keys registered on the disk specified by disk path $devpath$disk");
                    $flag = 1;
                    last;
                } elsif ($unused !~ /No keys/m) {
                    $msg = Msg::new("The disk $disk already seems to have the keys registered on it. Try a different disk or unregister the keys on this disk and then try again.");
                    $flag = 1;
                    last;
                }
            }
            if ($flag){
        	   $web->web_script_form("alert",$msg);
            }
        }
    }
    return ($ret,\@disks,$dgname,$diskpolicy);
}

sub ask_cps_disks {
    my ($pkg, $ndisks) = @_;
    my (@disks,$dgname,$diskpolicy,$ret);
    $ret = 0;

    # Ask for the disk policy for fencing
    ($ret,$diskpolicy) = $pkg->ask_disk_policy();
    return $ret if ($ret);
    ($ret, @disks) = $pkg->get_coord_disks($ndisks, $diskpolicy);
    return $ret if ($ret);
    Msg::n();
    ($ret,$dgname) = $pkg->ask_new_fencing_dgname();
    return $ret if ($ret);
    return ($ret,\@disks,$dgname,$diskpolicy);
}

sub ask_new_fencing_dgname {
    my $pkg = shift;
    my ($answer,$ayn,$backopt,$cfg,$help,$msg,$out,$question,$ret,$web);
    my (@disks,$dgname);
    my $sys0 = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();
    $ret = 0;
    $backopt = 1;
    $web = Obj::web();
    # Create a DG with the disks obtained above
    # Ask for DG name
    my $defdgname = 'vxfencoorddg';
    while (1) {
    	if (Obj::webui()){
    		my $result = $web->web_script_form("coordination_dg",$pkg);
    		return -1 if ($result eq 'back');
    		$answer = $result->{dgname};
            $web->{migration_mechanism} = $result->{mechanism};
    	} else {
            if (Cfg::opt('responsefile')) {
                $answer = $cfg->{fencing_dgname};
            } else {
                $question = Msg::new("Enter the disk group name for coordinating disk(s):");
                $answer = $question->ask($defdgname, $help, $backopt);
            }
            return -1 if (EDR::getmsgkey($answer,'back'));
            chomp($answer);
    	}
        if ((!Obj::webui())&&(!$pkg->validate_dgname($answer))) {
            return 1 if (Cfg::opt('responsefile'));
            next;
        }

        if (!$pkg->validate_diskgroup($answer, 1)) {
            return 1 if (Cfg::opt('responsefile') && !$cfg->{fencing_reusedg});
            Msg::n();
            $msg = Msg::new("Details of '$answer' diskgroup: (Consult 'vxprint' manpage for details about the various fields)");
            $msg->print;
            $out = $sys0->cmd("_cmd_vxprint -g $answer");
            Msg::print($out);
            Msg::n();
            $msg = Msg::new("Reusing the existing diskgroup '$answer' may delete the existing volumes and data on the diskgroup");
            $msg->bold;
            if (!Cfg::opt('responsefile')) {
                $question = Msg::new("Do you still want to continue?");
                $ayn = $question->aynn('',$backopt,$msg);
                next if (EDR::getmsgkey($ayn,'back'));
                if ($ayn eq 'N') {
                    $cfg->{fencing_reusedg} = 0;
                    next;
                }
                $cfg->{fencing_reusedg} = 1;
            }

            # check if the dg is deported, if so, import it before destroy
            my $dgs_href = $pkg->get_dglist_sys($sys0);
            if (defined($dgs_href->{$answer}{state}) && ($dgs_href->{$answer}{state} eq 'deported')) {
                $msg = Msg::new("Importing diskgroup '$answer'");
                $msg->left;
                $sys0->cmd("_cmd_vxdg -t import $answer 2>/dev/null");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    Msg::prtc();
                    if (Obj::webui()) {
                        $msg = Msg::new("Importing diskgroup '$answer' failed");
                        $web->web_script_form("alert",$msg);
                    }
                    return 1;
                }
                Msg::right_done();
            }

            $msg = Msg::new("Destroying diskgroup '$answer'");
            $msg->left;
            $sys0->cmd("_cmd_vxdg -o coordinator destroy $answer 2>/dev/null");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                Msg::prtc();
                if (Obj::webui()){
                    $msg = Msg::new("Destroying diskgroup '$answer' failed");
                    $web->web_script_form("alert",$msg);
                }
                return 1;
            }
                Msg::right_done();
                Msg::prtc();
        }
        last;
    }
    $dgname = $answer;

    # Perform pre-disk-init checks here
    # Like: labeling check
    # They are all PADV specific
    my @copy_of_disks = @disks;
    $ret = $pkg->check_disk_labeling(@copy_of_disks);
    if ($ret) {
        $msg = Msg::new("At least one of the disks selected is unsuitable for initializing. See logs for more info.");
        $msg->print;
        Msg::prtc();
        $web->web_script_form("alert",$msg);
        return 1;
    }
    return ($ret,$dgname);
}

sub ask_disk_policy {
    my $pkg = shift;
    my ($backopt,$cfg,$diskpolicy,$mechhelp,$msg,$question,$ret,$sys0,$web);
    $sys0 = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();
    $backopt = 1;
    $ret = 0;
    $web = Obj::web();
    # Ask for the disk policy for fencing
    $mechhelp = Msg::new("Fencing driver can use raw or dmp devices for its operation. Fencing disk policy indicates what kind of devices are being used by the driver. Input values are: raw/dmp.");
    while (1) {
    	if (Obj::webui()){
    		$diskpolicy = $web->{migration_mechanism};
    		undef $web->{migration_mechanism};
    	} else {
            if (Cfg::opt('responsefile')) {
                $diskpolicy = $cfg->{fencing_scsi3_disk_policy};
            } else {
                # On HP 1131 only dmp devices are supported
                if ($sys0->{platvers} =~ /11\.31/m) {
                    $diskpolicy = 'dmp';
                } else {
                    $question = Msg::new("Enter disk policy for the disk(s) (raw/dmp):");
                    $diskpolicy = $question->ask('', $mechhelp, $backopt);
                }
            }
            return -1 if (EDR::getmsgkey($diskpolicy,'back'));
            if ($diskpolicy !~ /^(raw|dmp)$/mx) {
                $msg=Msg::new("Invalid input. Retry.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                next;
            }
            last;
    	}
    }
    return ($ret,$diskpolicy);
}

sub get_migration_disks {
    my ($pkg,$ndisks,$dgname) = @_;
    my (@alldisks,@disks,@disks_avail,@disks_inuse,@expt_free_disks,@groups,$disk,$disklist,$errstr,$msg,$ret,$sys0,$vxvmdisks);
    my (@multisels,$ayn,$backopt,$cfg,$choice,$dg,$dglist,$done,$menuopt,$out,$web,$webmsg);
    $sys0 = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();
    $web = Obj::web();
    $backopt = 1;
    $ret = 0;

    $dglist = $pkg->get_dglist_sys($sys0);
    @groups=@{$dglist->{diskgroups}} if (defined($dglist->{diskgroups}));
    @disks_avail=@{$dglist->{disks}} if (defined($dglist->{disks}));
    @disks_inuse=@{$dglist->{disks_inuse}} if (defined($dglist->{disks_inuse}));
    @expt_free_disks=@{$dglist->{disks_exported_free}} if (defined($dglist->{disks_exported_free}));

    while ($#disks_avail + 1 == 0 && $#expt_free_disks >= 0) {
        if ($pkg->ask_unexport_disk eq 'Y') {
            $dglist=$pkg->get_dglist_sys($sys0);
            @disks_avail=@{$dglist->{disks}} if (defined($dglist->{disks}));
            @expt_free_disks=@{$dglist->{disks_exported_free}} if (defined($dglist->{disks_exported_free}));
            next;
        }
        last;
    }
    push (@alldisks, @disks_avail);
#    for my $tmpdisk (@disks_inuse) {
        # do not display current fencing dg
#        next if ($dglist->{ingroup}{$tmpdisk} eq $dgname);
#        my $tmpgroup = $dglist->{ingroup}{$tmpdisk};
#        push (@alldisks, "$tmpdisk($tmpgroup)");
#    }
    while (1) {
        if(@alldisks<$ndisks) {
            my $numdisks = $#alldisks + 1;
            $msg=Msg::new("System $sys0->{sys} has only $numdisks free disk(s) out of which $ndisks coordination disk(s) could not be configured.");
            $msg->print;
            $web->web_script_form("alert",$msg) if (Obj::webui());
            ($ret,$vxvmdisks) = $pkg->init_vxvm_disks();
            return $ret if ($ret);
            if (@{$vxvmdisks}) {
                @alldisks=@{EDRu::arruniq(@alldisks,@{$vxvmdisks})};
                next;
            } else {
                return 1;
            }
        }
        last;
    }
    $msg = Msg::new("List of available disks:");
    $msg->print;
    while(1) {
        $done = 1;
        @disks = ();
        $menuopt=[ @alldisks ];
        if (Obj::webui()) {
        	$webmsg = '';
        	my $result = $web->web_script_form("coordination_disk",$pkg,\@alldisks,$ndisks);
        	@multisels = @{$result->{disks}};
        	for my $index(@multisels) {
                $disk=$alldisks[$index-1];
                $disk =~ s/\(.*//;
                if ($dglist->{ingroup}{$disk}) {
                    $dg = $dglist->{ingroup}{$disk};
                    $webmsg .= Msg::new("The disk $disk belongs to disk group $dg. Installer will remove disk $disk from disk group $dg if you choose disk $disk.\n")->{msg};
                }
                push (@disks, $disk);
            }
            if ($webmsg ne ''){
            	$msg = Msg::new("Do you still want to choose these disks as coordination point?");
                $ayn = $msg->aynn('',$backopt,$webmsg);
                if ($ayn eq 'N') {
                    $done = 0;
                    $cfg->{fencing_reusedisk} = 0;
                    next;
                }else{
                	$cfg->{fencing_reusedisk} = 1;
                }
            }
            last;
        } else {
            if (Cfg::opt('responsefile')) {
                @multisels = @{$cfg->{fencing_disks}};
            } else {
                $msg=Msg::new("Select $ndisks disk(s) as coordination points. Enter the disk options, separated by spaces:");
                # enable multi select and paging
                $choice=$msg->menu($menuopt,'','',$backopt,1,1);
                return -1 if (EDR::getmsgkey($choice,'back'));
                @multisels=@{$choice};
            }
            if(@multisels != $ndisks) {
                $msg=Msg::new("The total number of disks should be equal to $ndisks. Input again");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                next;
            }
            if(!EDRu::arr_isuniq(@multisels)) {
                $msg=Msg::new("Duplicate inputs. Input again");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                next;
            }
            for my $index(@multisels) {
                if (Cfg::opt('responsefile')) {
                    $disk=$index;
                } else {
                    $disk=$alldisks[$index-1];
                    $disk =~ s/\(.*//;
                }
                if ($dglist->{ingroup}{$disk}) {
                    $dg = $dglist->{ingroup}{$disk};
                    return 1 if ((Cfg::opt('responsefile')) && (!$cfg->{fencing_reusedisk}));
                    $msg = Msg::new("The disk $disk belongs to disk group $dg. Installer will remove disk $disk from disk group $dg if you choose disk $disk.");
                    $msg->print;
                    if (!Cfg::opt('responsefile')) {
                        $msg = Msg::new("Do you still want to choose disk $disk as coordination point?");
                        $ayn = $msg->aynn('','',$backopt);
                        if ($ayn eq 'N') {
                            $done = 0;
                            $cfg->{fencing_reusedisk} = 0;
                            last;
                        }
                        return -1 if (EDR::getmsgkey($ayn,'back'));
                        $cfg->{fencing_reusedisk} = 1;
                    }
                }
                push (@disks, $disk);
            }
            next if (!$done);
            last;
        }
    }
    # Remove from original disk group
    for my $d(@disks) {
        $dg = $dglist->{ingroup}{$d};
        next if (!$dg);
        if ($dglist->{$dg}{state} eq 'deported') {
            $msg = Msg::new("Importing disk group $dg on $sys0->{sys}");
            $msg->left;
            $sys0->cmd("_cmd_vxdg -t import $dg");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                return 1;
            }
            Msg::right_done();
            $dglist->{$dg}{state} = 'imported';
        }
        $msg = Msg::new("Removing disk $d from disk group $dg on $sys0->{sys}");
        $msg->left;
        $out = $sys0->cmd("_cmd_vxdisk list $d | _cmd_grep disk:");
        my $tmpdisk = $d;
        $tmpdisk = $1 if ($out =~ /disk:\s+name=(\S+)\s+/m);
        $out = $sys0->cmd("_cmd_vxdg -g $dg -o coordinator rmdisk $tmpdisk");
        if (EDR::cmdexit()) {
            if ($out =~ /Cannot\s+remove\s+last\s+disk/m) {
                $sys0->cmd("_cmd_vxdg -o coordinator destroy $dg");
                if (EDR::cmdexit()) {
                    $msg->right_failed;
                    return 1;
                } else {
                    Msg::right_done();
                }
            } else {
                Msg::right_failed();
                return 1;
            }
        } else {
             Msg::right_done();
        }
    }

    @{$cfg->{fencing_disks}} = @disks;
    $cfg->{fencing_ndisks} = scalar @disks;

    return ($ret,\@disks);
}

sub display_cp_info {
    my ($pkg,$conf,$noconfig_info) = @_;
    my (@cps,@disks,%ports,$ayn,$help,$msg,$str,$webmsg);
    @cps = @{$conf->{cps}};
    %ports = %{$conf->{ports}};

    # Show all the info so far for user confirmation
    if ($noconfig_info) {
        $msg = Msg::new("Coordination points verification");
        $msg->bold;
        $webmsg = $msg->{msg};
    } else {
        Msg::title();
        $msg = Msg::new("CPS based fencing configuration: Coordination points verification");
        $msg->bold;
        $webmsg = $msg->{msg};
    }
    $msg = Msg::new("\n\tTotal number of coordination points being used: $conf->{ncp}");
    $msg->print;
    $webmsg .= $msg->{msg};
    $msg = Msg::new("\tCoordination Point Server ([VIP or FQHN]:Port):");
    $msg->print;
    $webmsg .= "\n".$msg->{msg};
    my $count = 0;
    for my $server (@cps) {
        $count++;
        $str = '';
        for my $vip(@{$server->{vips}}) {
            $str .= "[$vip]:$ports{$vip},";
        }
        $str =~ s/,$//;
        Msg::print("\t\t${count}. $server->{sys} ($str)");
        $webmsg .= "\n\t\t${count}. $server->{sys} ($str)";
    }
    if ($conf->{ndisks}) {
        $msg = Msg::new("\tSCSI-3 disks:");
        $msg->print;
        $webmsg .= "\n".$msg->{msg};
        $count = 0;
        @disks = @{$conf->{disks}};
        for my $d (@disks) {
            $count++;
            Msg::print("\t\t${count}. $d");
            $webmsg .= "\n\t\t${count}. $d";
        }
        $msg = Msg::new("\tDisk Group name for the disks in customized fencing: $conf->{vxfendg}");
        $msg->print;
        $webmsg .= "\n".$msg->{msg};
        $msg = Msg::new("\tDisk policy used for customized fencing: $conf->{scsi3_disk_policy}");
        $msg->print;
        $webmsg .= "\n".$msg->{msg};
    }

    unless (Cfg::opt('responsefile')) {
        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny($help,'',$webmsg);
        Msg::n();
        return -1 if ($ayn eq 'N');
    }
    return 0;
}

sub update_clusterinfo_on_cps_when_upgrade {
    my ($pkg,$conf,$cpservers) = @_;
    my ($msg,$sys1,$uuid,$syslist,$vcs,$cpspkg,$cpsadm,$out,$cpport,@cpsusers,$clusname);

    # get VCS uuid from system 1
    $syslist=CPIC::get("systems");
    $sys1=$$syslist[0];
    $vcs=$pkg->prod('VCS61');
    $uuid = $vcs->get_uuid_sys($sys1);

    # get VCS clusname from system1
    my $rootpath = Cfg::opt('rootpath') || '';
    my $maincf = "$rootpath$vcs->{maincf}";
    my $str = $sys1->cmd("_cmd_grep '^cluster' $maincf 2> /dev/null");
    # get cluster name
    if ($str =~ /^cluster\s+(\S+)\s*/mx) {
        $clusname=$1;
    } else {
        $msg=Msg::new("Failed to get clusname from $maincf");
        $msg->log();
        return 0;
    }

    $cpspkg=$pkg->pkg('VRTScps61');
    $cpsadm=$cpspkg->{cpsadm};

    for my $cps (@$cpservers) {
        # Get old CP client users for this cluster
        $cpport=$conf->{cpport}{$cps->{sys}} || $cpspkg->{defport};
        $out=$cps->cmd("$cpsadm -s $cps->{sys} -a list_users -p $cpport -c $clusname 2>/dev/null | _cmd_grep '$uuid'");
        if (EDR::cmdexit() || $out eq '') {
            $msg = Msg::new("Cannot invoke 'cpsadm' to find the users registered from $cps->{sys}.");
            $msg->log;
            next;
        }
        for my $line (split (/\n/, $out)) {
            push (@cpsusers, (split(/\//m, $line))[0]);
        }

        for my $cpsuser (@cpsusers) {
            # 1.Remove the cluster from old CP client user name
            $cps->cmd("$cpsadm -s $cps->{sys} -a rm_clus_from_user -p $cpport -u $uuid -e $cpsuser -f cps_operator -g vx 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Failed to rm_clus_from_user $cpsuser on Coordination Point server $cps->{sys}");
                $msg->log;
                next;
             }
             # 2.Delete the old CP client username
             $cps->cmd("$cpsadm -s $cps->{sys} -p $cpport -a rm_user -e $cpsuser -g vx 2>/dev/null");
             if (EDR::cmdexit()) {
                $msg = Msg::new("Failed to rm_user $cpsuser on Coordination Point server $cps->{sys}");
                $msg->log;
                next;
             }
        }

        # 3.Create the new CP client username
        my $sysname = $sys1->{vcs_sysname};
        my $cpsuser="cpsclient\@$sysname";
        $cps->cmd("$cpsadm -s $cps->{sys} -a add_user -p $cpport -e $cpsuser -g vx 2>/dev/null");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Failed to add_user $cpsuser on Coordination Point server $cps->{sys}");
            $msg->log;
            next;
        }
        # 4.Add the cluster to the new CP client username
        $cps->cmd("$cpsadm -s $cps->{sys} -a add_clus_to_user -p $cpport -u $uuid -e $cpsuser -g vx -f cps_operator 2>/dev/null");
        if (EDR::cmdexit()) {
            $msg = Msg::new("Failed to add_user $cpsuser on Coordination Point server $cps->{sys}");
            $msg->log;
            next;
        }
    }
    return 1;
}

sub update_clusterinfo_on_cps {
    my ($pkg,$conf,$new_flag,$donotcleanup) = @_;
    my (@cps,%ports,$clusname,$cpsadm,$cpsat,$edr,$msg,$out,$syslist,$uuid,$cpspkg,$web);
    my ($sysname,$vcs,$user);
    $edr = Obj::edr();
    $web = Obj::web();
    $edr->{msglist} = '';
    $syslist = CPIC::get('systems');
    %ports = %{$conf->{ports}};
    $clusname = $conf->{clustername};
    $uuid = $conf->{uuid};
    $cpspkg = $pkg->pkg('VRTScps61');
    $cpsadm = $cpspkg->{cpsadm};
    $cpsat = $cpspkg->{cpsat};
    $vcs = $pkg->prod("VCS61");

    if ($new_flag) {
        @cps = @{$conf->{newcps}};
    } else {
        @cps = @{$conf->{cps}};
    }

    $msg = Msg::new("Updating client cluster information on Coordination Point Servers");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    for my $cpserver (@cps) {
        Msg::n();
        $msg = Msg::new("Updating client cluster information on Coordination Point Server $cpserver->{sys}");
        $msg->bold;
        $msg->display_left($msg) if (Obj::webui());

        # Check if client cluster is already registered on the cps
        $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep -w '$clusname'");
        $msg->display_right() if (Obj::webui());
        if (EDR::cmdexit() || $out eq '') {
            $msg = Msg::new("Adding the client cluster to the Coordination Point Server $cpserver->{sys}");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());
            # Add cluster
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_clus -p $ports{$cpserver->{sys}} -c $clusname -u $uuid 2>/dev/null");
            if ($out =~ /already exists\./m){
                Msg::right_failed();
                Msg::prtc();
                $msg = Msg::new("Add cluster ($clusname) operation failed. Cluster with UUID ($uuid) already exists. Ensure each cluster has a unique UUID.");
                $msg->print;
                $web->web_script_form("alert",$msg) if (Obj::webui());
                Msg::prtc();
                return 1;
            }
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep -w '$clusname'");
            if (EDR::cmdexit() || $out eq '') {
                unless ($donotcleanup) {
                    #  Clean Up: adding client cluster failed, then do 1. remove cluster
                    for my $tmpcpserver (@cps) {
                        $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_clus -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid 2>/dev/null");
                    }
                }
                Msg::right_failed();
                Msg::prtc();
                if (Obj::webui()){
                    $msg = Msg::new("Add cluster ($clusname) operation failed.");
                    $web->web_script_form("alert",$msg);
                }
                return 1;
            } else {
                # Add cluster successfully
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            }
        }
        my  $count = 0;
        for my $sys (@$syslist) {
            $sysname = $sys->{vcs_sysname};
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep $clusname.*${uuid}.*$sysname\\(");
            if (EDR::cmdexit() || $out eq '') {
                Msg::n();
                $msg = Msg::new("Registering client node $sys->{sys} with Coordination Point Server $cpserver->{sys}");
                $msg->left;
                $msg->display_left($msg) if (Obj::webui());
                $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_node -p $ports{$cpserver->{sys}} -c $clusname -u $uuid -h $sysname -n $count 2>/dev/null");
                $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep $clusname.*${uuid}.*$sysname\\(");
                if (EDR::cmdexit() || $out eq '') {
                    unless ($donotcleanup) {
                        # Clean Up: register client node failed, then do 1. remove cluster
                        for my $tmpcpserver (@cps) {
                            $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_clus -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid 2>/dev/null");
                        }
                    }
                    Msg::right_failed();
                    Msg::prtc();
                    if (Obj::webui()){
                        $msg = Msg::new("Register client node failed.");
                        $web->web_script_form("alert",$msg);
                    }
                    return 1;
                } else {
                    # register node successfully
                    Msg::right_done();
                    $msg->display_right() if (Obj::webui());
                }
            }
            $count++;

            # get the domain name from credencial
            my $eat_uuid_domain;
            $user = "cpsclient\@$sysname";
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} 2>/dev/null | _cmd_grep $user/");
            if (EDR::cmdexit() || $out eq '') {
                $msg = Msg::new("Adding CPClient user for communicating to Coordination Point Server $cpserver->{sys}");
                $msg->left;
                $msg->display_left($msg) if (Obj::webui());
                $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_user -p $ports{$cpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
                $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} 2>/dev/null | _cmd_grep $user/");
                if (EDR::cmdexit() || $out eq '') {
                    unless ($donotcleanup) {
                        # Clean Up: add CPClient user failed, then do 1. remove cluster; 2. remove users
                        for my $tmpcpserver (@cps) {
                            $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_clus -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid 2>/dev/null");
                            for my $tmpsys (@$syslist) {
                                $user = "cpsclient\@$tmpsys->{vcs_sysname}";
                                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_user -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
                            }
                        }
                    }
                    Msg::right_failed();
                    Msg::prtc();
                    if (Obj::webui()){
                        $msg = Msg::new("Add CPClient user failed.");
                        $web->web_script_form("alert",$msg);
                    }
                    return 1;
                } else {
                    # add user successfully
                    Msg::right_done();
                    $msg->display_right() if (Obj::webui());
                }
            }

            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep $user/.*$clusname/$uuid");
            if (EDR::cmdexit() || $out eq '') {
                $msg = Msg::new("Adding cluster $clusname to the CPClient user on Coordination Point Server $cpserver->{sys}");
                $msg->left;
                $msg->display_left($msg) if (Obj::webui());
                $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_clus_to_user -p $ports{$cpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
                $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep $user/.*$clusname/$uuid");
                if (EDR::cmdexit() || $out eq '') {
                    unless ($donotcleanup) {
                        # Clean Up: add CPClient user failed, then do 1. remove cluster; 2. remove users
                        for my $tmpcpserver (@cps) {
                            $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_clus -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid 2>/dev/null");
                            for my $tmpsys (@$syslist) {
                                $user = "cpsclient\@$tmpsys->{vcs_sysname}";
                                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_user -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
                            }
                        }
                    }
                    Msg::right_failed();
                    Msg::prtc();
                    if (Obj::webui()){
                        $msg = Msg::new("Add CPClient user failed.");
                        $web->web_script_form("alert",$msg);
                    }
                    return 1;
                } else {
                    # add cluster to user successfully
                    Msg::right_done();
                    $msg->display_right() if (Obj::webui());
                }
            }
        }
    }
    return 0;
}

sub get_new_cpservers {
    my ($pkg,$conf) = @_;
    my (@cps,@newservers,%ports,$clusname,$cpsadm,$out,$uuid,$cpspkg);
    @cps = @{$conf->{cps}};
    %ports = %{$conf->{ports}};
    $clusname = $conf->{clustername};
    $uuid = $conf->{uuid};
    $cpspkg = $pkg->pkg('VRTScps61');
    $cpsadm = $cpspkg->{cpsadm};
    my $ret = 0;

    for my $cpserver(@cps) {
        $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep -w '$clusname'");
        if (EDR::cmdexit() || $out eq '') {
            # new cp servers
            push (@newservers, $cpserver);
        }
    }
    return ($ret,\@newservers);
}

sub get_uuid {
    my ($pkg,$clusname,$clusid) = @_;
    my ($msg,$ret,$vcs,$web,$webmsg);
    my ($uuid_hash,$nuuid,@uuids,$uuid);
    $ret = 0;
    $vcs = $pkg->prod("VCS61");
    $web = Obj::web();
    # Updating client cluster information on CP Servers
    if (!$vcs->check_uuidconfig_pl()) {
        $msg = Msg::new("Could not find 'uuidconfig.pl' for UUID configuration. Coordination Point client configuration will not complete without UUID utility.");
        $msg->bold;
        Msg::prtc();
    }
    $uuid_hash = $vcs->get_uuid();
    $nuuid = keys %{$uuid_hash};
    if ($nuuid != 1) {
        $msg = Msg::new("For the given set of cluster nodes, unique UUID was not found.");
        $msg->print;
        $webmsg = $msg->{msg};
        $msg = Msg::new("Hence, the cluster $clusname (ID: $clusid) seems to be in an inconsistent state. Cannot go ahead.");
        $msg->print;
        $webmsg .= $msg->{msg};
        Msg::prtc();
        $web->web_script_form("alert",$webmsg);
        return 1;
    }
    @uuids = keys %{$uuid_hash};
    $uuid = shift @uuids;
    return ($ret,$uuid);
}

sub confirm_stop_vcsfen {
    my $pkg = shift;
    my ($ayn,$backopt,$msg,$web,$webmsg);
    my ($syslist,$vcs,$sys0,$autodisablegrps,@autodisablegrp,$autodisablegrplist);
    $web = Obj::web();
    $syslist=CPIC::get('systems');
    $vcs = $pkg->prod('VCS61');
    $sys0 = $$syslist[0];

    Msg::n();
    $webmsg=Msg::new("Installer will stop VCS before applying fencing configuration. To make sure VCS shuts down successfully, unfreeze any frozen service group and unmount the mounted file systems in the cluster.");
    $webmsg->bold;
    # check if any group is set to AutoDisableNoOffline, and prompt users to offline manually 
    $autodisablegrps = $sys0->cmd("$vcs->{bindir}/hagrp -list State=~ONLINE SysDownPolicy=AutoDisableNoOffline 2>/dev/null | _cmd_awk '{print \$1}'");
    for my $grp (split(/\n/, $autodisablegrps)) {
        push @autodisablegrp, $grp if (!EDRu::inarr($grp,@autodisablegrp));
    }
    if (@autodisablegrp) {
        $autodisablegrplist = join ' ', @autodisablegrp;
        Msg::n();
        $msg = Msg::new("The value of the attribute 'SysDownPolicy' of the following service groups is 'AutoDisableNoOffline', these service groups need to be brought offline manually before stopping VCS:\n\t$autodisablegrplist");
        $webmsg->{msg} .= "\n$msg->{msg}";
        $msg->print;
    }

    Msg::n();
    $msg=Msg::new("Are you ready to stop VCS and apply fencing configuration on all nodes at this time?");
    $ayn=$msg->ayny('',$backopt,$webmsg);
    $ayn='Y' if (Cfg::opt('responsefile'));
    return -1 if (EDR::getmsgkey($ayn,'back'));
    if ($ayn eq 'N') {
        Msg::n();
        $web->{complete_failed}=1;
        $msg = Msg::new("Fencing configuration is not applied");
        $msg->printn;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        return -2;
    }
    return 0;
}

# Configure CP client based fencing
# Return 0 if CP client is configured on all nodes
# Return 1 if CP client could not be confiugred on any of the nodes
sub configure_cpc {
    my ($cfg,$cpic,$edr,$sys0,$pkg,$vcs,$vxfen);
    my (@oldcps,$clusid,$clusname,$conf,$cpssys,$oldvxfenconf);
    my ($cpsadm,$cpsat,$vmmode, $msg, $index, $sys, $secmode,$cpserver, $cpspkg);
    my ($backopt, $ayn, $help, $question, $answer, $ret, $out);
    my ($disk_aref,$ncp,$ndisks,@cps,@disks,$defport,%ports,$dgname,$diskpolicy,$uuid);
    my ($dg_res,$loser_exit_delay, $suffix, $vxfen_script_timeout);
    my ($vcs_conf,$web,$webmsg);
    $pkg = shift;
    $cpic = Obj::cpic();
    $cfg = Obj::cfg();
    $sys0 = ${CPIC::get('systems')}[0];
    $vcs = $pkg->prod('VCS61');
    $vxfen = $pkg->proc('vxfen61');
    $web=Obj::web();
    $clusid = $cfg->{vcs_clusterid};
    $clusname = $cfg->{vcs_clustername};
    $edr=Obj::edr();
    $conf = {};

    $backopt = 1;
    $help = '';
    # non-scsi3 parameters
    $loser_exit_delay = 55;
    $vxfen_script_timeout = 25;

    $cpspkg = $pkg->pkg('VRTScps61');
    $cpsadm = $cpspkg->{cpsadm};
    $cpsat = $cpspkg->{cpsat};
    $defport = $cpspkg->{defport};

    # Check if VRTScps is installed on all the client cluster nodes or not
    return 1 if (!$pkg->check_pkg_installed('VRTScps61'));

    # Check $clusname in case user does not re configure vcs when $cfg->{vcs_clustername} is not defined
    unless ($clusname) {
        $vcs_conf = $vcs->get_config_sys($sys0);
        return 1 unless ($vcs_conf);
        $clusname ||= $vcs_conf->{clustername};
        return 1 unless ($clusname);
        $clusid ||= $vcs_conf->{clusterid};
    }

    $pkg->{non_scsi3} = 0;
    if ($pkg->non_scsi3_supported()) {
        $ayn = '';
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("Does your storage environment support SCSI3 PR?");
            $help = Msg::new("SCSI-3 Persistent Reservation (SCSI-3 PR) supports device access from multiple systems, or from multiple paths from a single system. At the same time it blocks access to the device from other systems, or other paths.\nUse of SCSI 3 PR protects against all elements in the IT environment that might be trying to write illegally to storage, not only VCS related elements.");
            $ayn = $msg->ayn('', $help, $backopt);
            return -1 if (EDR::getmsgkey($ayn,'back'));
            Msg::n();
        }
        $pkg->{non_scsi3} = 1 if ((Cfg::opt('responsefile') && $cfg->{non_scsi3_fencing}) || ($ayn eq 'N'));
    }

    if ($pkg->{non_scsi3}) {
        $msg = Msg::new("In virtualized environments that do not support SCSI-3 PR, VCS attempts to minimize the chances of data corruption with discreet use of timings in the event of unreachable nodes or network partition. However, if a server becomes unresponsive, VCS assumes that the node has left the cluster and reconfigures itself.");
        $msg->bold;
        $webmsg = $msg->{msg}."\n";
        Msg::n();
        $msg = Msg::new("This feature only works with UseFence Cluster attribute set to SCSI3 and all coordination points being Coordination Point servers");
        $msg->bold;
        $webmsg .= $msg->{msg}."\n";
        Msg::n();
    } else {
        $msg = Msg::new("Since you have selected to configure Coordination Point clients, you would be asked to give details about Coordination Point Servers/Disks to be used as coordination points");
        $msg->bold;
        Msg::prtc();
        Msg::n();
    }

    if ($pkg->{non_scsi3}) {
        $msg = Msg::new("In this environment, either Non-SCSI3 fencing can be configured or fencing can be configured in disabled mode");
        $msg->print;
        $webmsg .= $msg->{msg}."\n";
        Msg::n();
        $msg = Msg::new("Do you want to configure Non-SCSI3 fencing?");
        $ayn = $msg->ayny('',$backopt,$webmsg);
        return -1 if (EDR::getmsgkey($ayn,'back'));
        Msg::n();
        return 1 if ($ayn eq 'N');
    }
    #web coordination servers and disks number
    if (Obj::webui()){
        my $num = $web->web_script_form('coordination_num',$pkg);
        return $num if ($num eq '__back__');
        $ncp = $num->{ncp};
        $ndisks = $num->{ndisks};
        if($ncp == 1) {
            $msg = Msg::new("\nWarning: Symantec recommends at least three or more odd number of coordination points to avoid a single point of failure. However, if fencing is configured to use a single CP server, it is strongly recommended to make the CP server highly available by configuring it on a SFHA cluster. It is important to note that during a failover of the CP server in the SFHA cluster, if there is a network partition on the client cluster at the same time, the whole client cluster will be brought down because arbitration facility will not be available for the duration of the failover.");
            $web->web_script_form('alert',$msg->{msg});
        }
    } else {
        ($ret,$ncp,$ndisks)=$pkg->ask_cps_num();
        return $ret if ($ret);
    }

    # Check if VM is already running only if at least one disk is being used.
    # If VM is not running in the case mentioned, return 1
    if ($ndisks) {
        $vmmode = $sys0->cmd('_cmd_vxdctl mode 2>/dev/null');
        if ($vmmode !~ /enabled/m) {
            $msg=Msg::new("Configure VM before configuring Coordination Point server based fencing in the customized mode");
            $msg->print;
            $web->web_script_form('alert',$msg) if (Obj::webui());
            return 1;
        }
    }

    # State the following warning before asking for CP Servers
    #Msg::title();
    $msg = Msg::new("You are now going to be asked for the Virtual IP addresses or fully qualified host names of the Coordination Point Servers. Note that the installer assumes these values to be the identical as viewed from all the client cluster nodes.");
    $msg->bold;

    Msg::prtc();
    Msg::n();
    # Get CP servers and their ports
    # web
    if (Obj::webui()){
    	my($num,$result);
    	while(1){
    	    $num = $web->web_script_form('cp_server_vipnum',$ncp - $ndisks);
    	    return $num if ($num eq '__back__');
            $result = $web->web_script_form('cp_server',$pkg,$ncp - $ndisks,$num);
            last unless($result eq 'back');
    	}
        push (@cps,@{$result->{fencing_cps}});
        %ports = %{$result->{fencing_ports}};
    } else {
        my ($cps_aref, $port_href);
        ($ret,$cps_aref, $port_href) = $pkg->ask_cps($ncp,$ndisks,$defport);
        return $ret if ($ret);
        @cps = @{$cps_aref};
        %ports = %{$port_href};
    }

    if ($ndisks) {
        if (Obj::webui()){
            ($ret,$disk_aref,$dgname,$diskpolicy) = $pkg->web_get_cps_disks($ndisks);
        } else {
            ($ret,$disk_aref,$dgname,$diskpolicy) = $pkg->ask_cps_disks($ndisks);
        }
        return $ret if ($ret);
        @disks = @{$disk_aref};
    }

    $conf->{ncp} = $ncp;
    $conf->{ndisks} = $ndisks;
    $conf->{disks} = $disk_aref;
    $conf->{cps} = \@cps;
    $conf->{ports} = \%ports;
    $conf->{vxfendg} = $dgname;
    $conf->{scsi3_disk_policy} = $diskpolicy;
    $conf->{loser_exit_delay} = $loser_exit_delay;
    $conf->{vxfen_script_timeout} = $vxfen_script_timeout;
    $ret = $pkg->display_cp_info($conf);
    return $ret if ($ret);

    if ($ndisks) {
        # Preparing for disks and disk group init
        return 1 if ($pkg->create_vxfencoorddg(\@disks,$dgname));
        if (!$pkg->validate_diskgroup($dgname)) {
            $msg =Msg::new("Disk group $dgname is not available on all the systems");
            $msg->print;
            $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
            return 1;
        }
    }

    $ret = $pkg->https_config_client_fresh(\@cps,\%ports);
    return $ret if $ret;

    # get client cluster uuid
    ($ret, $uuid)= $pkg->get_uuid($clusname,$clusid);
    return $ret if ($ret);
    $conf->{clustername} = $clusname;
    $conf->{uuid} = $uuid;

    # Show all the info so far for user confirmation
    Msg::title();
    $msg = Msg::new("CPS based fencing configuration: Client cluster verification");
    $msg->bold;
    $webmsg = $msg->{msg};
    $msg = Msg::new("\n\tCPS Admin utility : $cpsadm");
    $msg->print;
    $webmsg .= $msg->{msg};
    $msg = Msg::new("\tCluster ID: $clusid");
    $msg->print;
    $webmsg .= "\n".$msg->{msg};
    $msg = Msg::new("\tCluster Name: $clusname");
    $msg->print;
    $webmsg .= "\n".$msg->{msg};
    $msg = Msg::new("\tUUID for the above cluster: $uuid");
    $msg->print;
    $webmsg .= "\n".$msg->{msg};
    if (!Cfg::opt('responsefile')) {
        $question = Msg::new("\nIs this information correct?");
        $ayn = $question->ayny('','',$webmsg);
        if ($ayn eq 'N') {
            return -1;
        }
    }

    # update clister info on CP servers
    Msg::title();
    $ret = $pkg->update_clusterinfo_on_cps($conf);
    return $ret if ($ret);

    $ret = $pkg->confirm_stop_vcsfen();
    $edr->{msglist} = '';
    $msg = Msg::new("Configuring Fencing");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    return $ret if ($ret);

    # Save config for responsefile
    $cfg->{fencing_ncp} = $ncp;
    $cfg->{fencing_cps} = [];
    $cfg->{fencing_disks} = [];
    for my $server (@cps) {
        push (@{$cfg->{fencing_cps}}, $server->{sys});
        $cfg->{fencing_cps_vips}->{"$server->{sys}"} = [];
        push (@{$cfg->{fencing_cps_vips}->{"$server->{sys}"}}, @{$server->{vips}});
        for my $vip(@{$server->{vips}}) {
            $cfg->{fencing_cps_ports}->{"$vip"} = $ports{$vip};
        }
    }
    $cfg->{fencing_ndisks} = scalar @disks;
    for my $d (@disks) {
        push (@{$cfg->{fencing_disks}}, $d);
    }
    if ($ndisks) {
        # Save config for responsefile
        $cfg->{fencing_dgname} = $dgname;
        $cfg->{fencing_scsi3_disk_policy} = $diskpolicy;
    }

    # if non scsi3 fencing
    # move default DiskGroup attribute Reservation in types.cf from ClusterDefault to NONE
    # for each resource of the type DiskGroup
    # --1. set the value of the MonitorReservation attribute to 0
    # --2. set the value of the Reservation attribute to NONE
    if ($pkg->{non_scsi3}) {
        $pkg->non_scsi3_updateresources;
        $cfg->{non_scsi3_fencing}=1;
    }

    # Stop VCS, Fencing on all the cluster nodes
    Msg::n();
    $pkg->stop_vcsfen();

    # CPS Clean Up
    # scenario 1: migrate from CPS to other CPS.
    # scenario 2: migrate from non-scsi3 to CPS.
    # clean up old info in cps database if vxfen is already running in cps mode
    unless (-3 == $pkg->{status}) {
        $oldvxfenconf = $vcs->get_vxfen_config_sys($sys0);
        for my $cpsname(@{$oldvxfenconf->{cps}}) {
            $cpssys = $pkg->create_cps_sys($cpsname);
            push (@oldcps,$cpssys);
        }
        if (($oldvxfenconf->{vxfen_mechanism} =~ /cps/im) && (@oldcps)) {
            $pkg->remove_cps(\@oldcps,$oldvxfenconf,$conf->{cps});
        }
        # vxfen config file clean up
        $pkg->update_vxfen_files_without_nonscsi3();
    }

    # Apply fencing configuration
    # Generate /etc/vxfenmode file with these details in each of the CP client cluster nodes
    $pkg->update_vxfen_files($conf);

    # Start Fencing on all the cluster nodes. Start VCS on all the cluster nodes
    Msg::n();
    for my $sys (@{$cpic->{systems}}) {
        $msg = Msg::new("Starting Fencing on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $vxfen->enable_sys($sys);
        if ($cpic->proc_start_sys($sys, $vxfen)) {
            CPIC::proc_start_passed_sys($sys, $vxfen);
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
            $pkg->{status}=1;
        } else {
            $vxfen->{noreboot_failstart}=1;
            CPIC::proc_start_failed_sys($sys, $vxfen);
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                $msg->addError($errmsg);
            }
            $pkg->{status}=-3;
            $msg = Msg::new("Could not start VxFEN on $sys->{sys}");
            $msg->print;
            $web->web_script_form("alert",$msg) if (Obj::webui());
            Msg::prtc();
            # CPS Clean Up
            $pkg->stop_vcsfen();
            # 1. clean up cps database
            $oldvxfenconf = $vcs->get_vxfen_config_sys($sys0);
            $pkg->cleanup_from_cps($oldvxfenconf);
            # 2. vxfen config file clean up if it is non scsi3 fencing
            $pkg->update_vxfen_files_without_nonscsi3() if ($pkg->{non_scsi3});
            return 1;
        }
    }

    $pkg->{no_coord_disks} = 1 if (!$ndisks);

    return 0;
}

sub https_config_client_fresh {
    my ($pkg,$cps_aref,$ports_href) = @_;
    my ($systems,$cps);

    my $web = Obj::web();
    $systems = CPIC::get('systems');
    $cps=$pkg->pkg('VRTScps61');

    if (!$pkg->https_check_cps($systems,$cps_aref)) {
        $web->{complete_failed}=1;
        return 1;
    }
    return 0 if (Cfg::opt('makeresponsefile'));

    return 1 if $cps->https_setup_trust($systems,$cps_aref);

    return 0;
}

sub https_check_cps {
    my ($pkg,$system_aref,$cps_aref) = @_;
    my (@systems,$cpspkg,$edr,$msg,$rtn,$web);

    $cpspkg = $pkg->pkg('VRTScps61');
    $edr = Obj::edr();
    $web = Obj::web();
    $msg = Msg::new("Using Coordination Point server over HTTPS requires clock synchronization between the hosts. Make sure the time settings of the client cluster are synchronized with Coordination Point servers.");
    $msg->bold;

    push (@systems, @{$system_aref}, @{$cps_aref});
    $rtn = $edr->check_and_setup_timesync(\@systems, $cpspkg->{time_sync});

    if (!$rtn) {
        $msg = Msg::new("Time synchronization check failed. Manually synchronize the clock of the client cluster with the CP servers.");
        $msg->printn;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        # do not exit installer if upgrade and time is not synchronized 
        if (Cfg::opt('upgrade')) {
            Msg::prtc();
            return 1;
        }
        return 0;
    }
    return 1;
}

sub https_config_client_upgrade {
    my ($pkg) = @_;
    my ($question,$help,$answer,$defcnt,$backopt,$vip_counts,$sys,$vrtscps_pkg);
    my ($vxfen_mode,$vxfen_mechanism,$security,$single_cp,$fips_mode);
    my (@systems,$sys0,$str,$msg,$defport,%ports,@cps,$cps_sys1,$suffix,$vip_index);
    my ($ret,$ncp,$ndisks,$index,$cpserver,$cfg,@cpsvips,$output,@cps_host);
    my ($prod,$cpservers,$conf,$vcs);
    my ($clusname,$clusid,$uuid,$sysname,$cpic);
    my ($web,$num,$result);

    $cfg = Obj::cfg();
    @systems = @{CPIC::get('systems')};
    $sys0 = $systems[0];
    $defcnt = 1;
    $backopt = 1;
    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    $prod = CPIC::get('prod');
    $cpic = Obj::cpic();
    $vcs = $pkg->prod('VCS61');
    $conf = $vcs->get_vxfen_config_sys($sys0);
    # check if in the live upgrade
    my $rootpath=Cfg::opt('rootpath') || '';
    $pkg->{vxfenmode_file}="$rootpath/etc/vxfenmode";

    $vxfen_mode = $sys0->cmd("_cmd_grep '^ *vxfen_mode' /etc/vxfenmode 2>/dev/null");
    $vxfen_mechanism = $sys0->cmd("_cmd_grep '^ *vxfen_mechanism' /etc/vxfenmode 2>/dev/null");
    $security = $sys0->cmd("_cmd_grep '^ *security' /etc/vxfenmode 2>/dev/null");
    $single_cp = $sys0->cmd("_cmd_grep '^ *single_cp' /etc/vxfenmode 2>/dev/null");
    $fips_mode = $sys0->cmd("_cmd_grep '^ *fips_mode' /etc/vxfenmode 2>/dev/null");

    $str .= "$vxfen_mode\n";
    $str .= "$vxfen_mechanism\n";
    $str .= "$security\n";
    $str .= "$single_cp\n";
    $str .= "$fips_mode\n";

    if (Obj::webui() && !Cfg::opt('responsefile')) {
        $web = Obj::web();

        while(1) {
            $num = $web->web_script_form('cp_server_vipnum',scalar(@{$conf->{cps}}),'',1);
            $result = $web->web_script_form('cp_server',$pkg,scalar(@{$conf->{cps}}),$num);
            last unless($result eq 'back');
        }
        push (@cps,@{$result->{fencing_cps}});
        %ports = %{$result->{fencing_ports}};

        $vip_index=1;
        $defport = $vrtscps_pkg->{default_https_port};
        foreach my $vip (keys(%ports)) {
            $str .= "cps$vip_index=[$vip]:$ports{$vip}\n";
            $vip_index++;
        }
        $str .= "port=$defport\n";

    } else {
        for ($index = 0; $index < scalar(@{$conf->{cps}}); $index++) {
            my $number = $index + 1;

            if (!Cfg::opt('responsefile')) {
                #get the port and ip for https
                $question = Msg::new("How many IP addresses would you like to use to communicate to Coordination Point Server #$number?");
                $help = Msg::new("Each Coordination Point Server may have more than one Virtual IP address configured. Input the total number of the Virtual IP addresses you would like to use to communicate to the Coordination Point Server.");
                while (1) {
                    $answer = $question->ask($defcnt, $help);
                    chomp($answer);
                    next if (!validate_cps_vip_num($answer));
                    last;
                }
            }

            Msg::n();
            if (Cfg::opt('responsefile')) {
                $cpserver = shift(@{$cfg->{fencing_cps}});
                $vip_counts = scalar(@{$cfg->{fencing_cps_vips}->{"$cpserver"}});
            } else {
                $vip_counts = $answer;
            }

            for $vip_index(1..$vip_counts) {
                if (Cfg::opt('responsefile')) {
                    $answer = shift(@{$cfg->{fencing_cps_vips}->{"$cpserver"}});
                } else {
                    $question = Msg::new("Enter the Virtual IP address or fully qualified host name #$vip_index for the HTTPS Coordination Point Server #$number:");
                    $help = '';
                    $answer = $question->ask('', $help, $backopt);
                }
                chomp($answer);
                return -1 if (EDR::getmsgkey($answer,'back'));
                if (!validate_cps_vip_fqhn($answer)) {
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }
                my @tmpcpsvips = @cpsvips;
                push (@tmpcpsvips,$answer);
                if (!EDRu::arr_isuniq(@tmpcpsvips)) {
                    $msg = Msg::new("Duplicate of previous Coordination Point Server entry. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }

                # Check for communication
                $sys = $pkg->create_cps_sys($answer);
                if (!$pkg->cps_transport_sys($sys)) {
                    $msg=Msg::new("Cannot communicate with system $sys->{sys}. Make sure password-less rsh or ssh is configured or the CP Server is up and running.");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }

                # Check if vips of each cps points to the same host
                if (1 != $vip_index) {
                    if ($sys->{hostname} ne $cps_sys1->{hostname}) {
                        $msg=Msg::new("The VIP or FQHN $answer does not point to the same host as $cps_sys1->{sys}. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        redo;
                    }
                # for different cp servers, the host pointed by vip should not be same
                } else {
                    if (EDRu::inarr($sys->{hostname}, @cps_host)) {
                        $msg=Msg::new("The specified VIP '$sys->{sys}' point to the same server '$sys->{hostname}' with one previous IP. Input again");
                        $msg->print;
                        return 1 if (Cfg::opt('responsefile'));
                        redo;
                    }
                }

                # reset vip for each sys
                $sys->{vips} = [] if ($vip_index == 1);
                Msg::n();
                # Ask for the port to connect to
                if (Cfg::opt('responsefile')) {
                    $defport = $vrtscps_pkg->get_cps_port($sys);
                    $answer = $cfg->{fencing_cps_ports}->{"$sys->{sys}"};
                } else {
                    $question = Msg::new("Enter the port which the Coordination Point Server $sys->{sys} would be listening on or simply accept the default port suggested:");
                    $defport = $vrtscps_pkg->get_cps_port($sys);
                    $answer = $question->ask($defport, $help, $backopt);
                }
                chomp($answer);
                return -1 if (EDR::getmsgkey($answer,'back'));
                if (!validate_cps_port($answer,$defport)) {
                    $msg=Msg::new("The port is invalid. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }

                # check if the vip and port is for HTTPS and IPM
                my $vip_port_type = $vrtscps_pkg->check_vip_port_cps_type_sys($sys,$answer);
                if ($vip_port_type ne "https_vip_port") {
                    $msg=Msg::new("The CP server for the specified VIP or FQHN '$sys->{sys}' and port $answer is not a HTTPS CP server. Input again");
                    $msg->print;
                    return 1 if (Cfg::opt('responsefile'));
                    redo;
                }

                push (@cpsvips,$sys->{sys});
                $ports{$sys->{sys}} = $answer;
                if ($vip_index == 1) {
                    $cps_sys1 = $sys;
                    push (@cps, $cps_sys1);
                    push (@cps_host, $sys->{hostname});
                }
                $cps_sys1->{port}->{$sys->{sys}} = $answer;
                push (@{$cps_sys1->{vips}}, $sys->{sys});
                Msg::n();
            }
        }
    }

    # update the /etc/vxfenmode file in each of the CP client cluster nodes
    $conf = {};
    $conf->{ports} = \%ports;
    $conf->{cps} = \@cps;
    $conf->{security} = 0;
    if (!Cfg::opt("makeresponsefile")) {
        $pkg->update_vxfen_files_when_upgrade($conf);
    }

    # update the response file
    $cfg->{fencing_cps} = [];
    for my $server (@cps) {
        push (@{$cfg->{fencing_cps}}, $server->{sys});
        $cfg->{fencing_cps_vips}->{"$server->{sys}"} = [];
        push (@{$cfg->{fencing_cps_vips}->{"$server->{sys}"}}, @{$server->{vips}});
        for my $vip(@{$server->{vips}}) {
            $cfg->{fencing_cps_ports}->{"$vip"} = $ports{$vip};
        }
    }

    $pkg->https_config_client_fresh(\@cps,\%ports);
    return if (Cfg::opt("makeresponsefile"));

    # update cluster info on cps
    $rootpath = Cfg::opt('rootpath') || '';
    my $maincf = "$rootpath$vcs->{maincf}";
    $str = $sys0->cmd("_cmd_grep '^cluster' $maincf 2> /dev/null");
    # get cluster name
    if ($str =~ /^cluster\s+(\S+)\s*/mx) {
        $clusname=$1;
    } else {
        $msg=Msg::new("Failed to get clusname from $maincf");
        $msg->log();
        return 0;
    }

    $uuid = $vcs->get_uuid_sys($sys0);
    $conf->{clustername} = $clusname;
    $conf->{uuid} = $uuid;

    for my $sysi (@{$cpic->{systems}}) {
        $sysname = $vcs->get_vcs_sysname_sys($sysi);
        $sysi->{vcs_sysname} = $sysname;
    }

    $pkg->update_clusterinfo_on_cps($conf);

    # for rolling upgrade, when product includes CFS, need copy /etc/vxfenmode to vxfenmode.rubak
    # in case that /etc/vxfenmode is re-wroten
    return unless (Cfg::opt("upgrade_kernelpkgs"));
    $output = $sys0->readfile($pkg->{vxfenmode_file});
    if ($output=~/vxfen_protocol_version/m) {
        $output=~s/vxfen_protocol_version(.*)\n*//mxg;
    }
    $sys0->writefile($output,'/etc/vxfenmode.rubak');

    return;
}

sub config_cps_cpc_security {
    my ($pkg,$cps_aref,$ports_href) = @_;
    my (@cps,%ports,$msg,$secmode,$security,$fips_mode,$ret,$vcs,$sys0,$web,$sec_or_fips);
    $vcs = $pkg->prod("VCS61");
    $sys0 = ${CPIC::get('systems')}[0];
    $web = Obj::web();
    ($security,$fips_mode) = $pkg->get_cps_security($cps_aref,$ports_href);
    if ($security eq 'error') {
        $web->{complete_failed}=1;
        return 1;
    } elsif ($security == -1) {
        $msg=Msg::new("Failed to get the security setting of the Coordination Point servers");
        $msg->print();
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        $web->{complete_failed}=1;
        return 1;
    } elsif ($security == 1) {
        $secmode = $vcs->is_secure_cluster($sys0);
        if (($fips_mode != 1) && ($secmode == 1) && ($vcs->is_fips_cluster($sys0))) {
            $msg=Msg::new("The client cluster is in security with fips mode, while the Coordination Point servers are configured in secure mode, hence fencing could not be configured.");
            $msg->print();
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            $web->{complete_failed}=1;
            return 1;
        }
        if (($fips_mode == 1) && !(($secmode == 1) && ($vcs->is_fips_cluster($sys0)))) {
            $msg=Msg::new("To configure fencing, the client cluster must be configured in security with fips mode, since the Coordination Point servers are configured in security with fips mode.");
            $msg->print();
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            $web->{complete_failed}=1;
            return 1;
        }
        if($fips_mode == 1) {
            $sec_or_fips = Msg::new("security with fips")->{msg};
        } else {
            $sec_or_fips = Msg::new("secure")->{msg};
        }
        Msg::n();
        $msg = Msg::new("Since the Coordination Point servers are configured in $sec_or_fips mode, installer will configure the client cluster to secure the communication between Coordination Point servers and client cluster.");
        $msg->bold;
        Msg::prtc();
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        $msg = Msg::new("Configure fencing in $sec_or_fips mode");
        $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
        if ($secmode == 1) {
            $msg = Msg::new("VCS is running in $sec_or_fips mode on $sys0->{sys}");
            $msg->print;
            # start vcsauthserver processes. Otherwise setuptrust will fail.
            my $syslist=CPIC::get("systems");
            for my $sysi (@$syslist) {
                $vcs->eat_stop_sys($sysi);
                $vcs->eat_start_sys($sysi);
            }
        } else {
            Msg::title();
            $msg = Msg::new("Configuring the cluster to secure the communication with Coordination Point servers:");
            $msg->bold;
            if (!$vcs->eat_check_secure_clus()) {
                $vcs->eat_configure();
            } else {
                # start vcsauthserver processes. Otherwise setuptrust will fail.
                my $syslist=CPIC::get("systems");
                for my $sysi (@$syslist) {
                    $vcs->eat_stop_sys($sysi);
                    $vcs->eat_start_sys($sysi);
                }
            }
        }
        $pkg->get_cps_version($cps_aref);
        $ret = $pkg->establish_trust_cps_cpc($cps_aref);
    }
    return ($ret,$security,$fips_mode);
}

sub update_vxfen_files {
    my ($pkg,$conf) = @_;
    my ($index,$msg,$sys,$str,$syslist,$suffix);
    $syslist = CPIC::get('systems');

    $str = $pkg->get_cps_vxfenmode_str($conf);
    for my $sys (@$syslist) {
        Msg::n();
        $msg = Msg::new("Updating $pkg->{vxfenmode_file} file on $sys->{sys}");
        $msg->left;
        # Back it up
        if ($sys->exists($pkg->{vxfenmode_file})) {
            $suffix = EDRu::datetime();
            $sys->cmd("_cmd_cp $pkg->{vxfenmode_file} $pkg->{vxfenmode_file}-$suffix");
        }
        # Write new things to it
        $sys->writefile($str,$pkg->{vxfenmode_file});
        Msg::right_done();
        # update related files for non-scsi3 fencing
        $pkg->non_scsi3_updatefiles_sys($sys) if ($pkg->{non_scsi3});
    }
    return;
}

sub update_vxfen_files_when_upgrade {
    my ($pkg,$conf) = @_;
    my ($index,$msg,$sys,$sys0,$str,$syslist,$suffix,$out);
    $syslist = CPIC::get('systems');

    # to delete the vip and ports in the original vxfenmode file
    $sys0 = ${$syslist}[0];
    $out=$sys0->readfile($pkg->{vxfenmode_file});
    $str = $pkg->get_cps_vxfenmode_str_when_upgrade($conf);

    $out=~s/cps1=.*\n*/___HTTPS_CONFIG___/mg;
    $out=~s/(cps\d*|port)=.*\n*//mg;
    $out=~s/___HTTPS_CONFIG___/$str/mg;

    # update the changes to /etc/vxfenmode
    for my $sys (@$syslist) {
        Msg::n();
        $msg = Msg::new("Updating $pkg->{vxfenmode_file} file on $sys->{sys}");
        $msg->left;

        # Back it up
        if ($sys->exists($pkg->{vxfenmode_file})) {
            $suffix = EDRu::datetime();
            $sys->cmd("_cmd_cp $pkg->{vxfenmode_file} $pkg->{vxfenmode_file}-$suffix");
        }

        $sys->writefile($out,$pkg->{vxfenmode_file});
        Msg::right_done();
    }

    return;
}

sub get_cps_vxfenmode_str {
    my ($pkg,$conf) = @_;
    my (%ports,$defport,$index,$str,$vrtscps_pkg);
    %ports = %{$conf->{ports}};
    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    $defport = $vrtscps_pkg->{defport};

    $str = '';
    $str = "vxfen_mode=customized\nvxfen_mechanism=cps\n";
    $str .= "security=$conf->{security}\n" if (defined $conf->{security});
    $str .= "single_cp=1\n" if ($conf->{ncp} == 1);
    $str .= "fips_mode=$conf->{fips_mode}\n" if (defined $conf->{fips_mode});
    $index = 1;
    for my $s(@{$conf->{cps}}) {
       my $tmpstr = '';
       for my $vip(@{$s->{vips}}) {
           if ($ports{$vip} ne $defport) {
               $tmpstr .= "[$vip]:$ports{$vip},";
           } else {
               $tmpstr .= "[$vip],";
           }
       }
       $tmpstr =~ s/,$//;
       $str .= "cps$index=$tmpstr\n";
       $index++;
    }
    # modify for CPS_HTTPS multiple vips, not include "port=14250" in /etc/vxfenmode
    #$str .= "port=$defport\n";

    if ($conf->{ndisks}) {
        $str .= "vxfendg=$conf->{vxfendg}\nscsi3_disk_policy=$conf->{scsi3_disk_policy}\n";
    }
    # add parameters in vxfenmode for non-scsi3 fencing
    if ($pkg->{non_scsi3}) {
        $str .= "loser_exit_delay=$conf->{loser_exit_delay}\n";
        $str .= "vxfen_script_timeout=$conf->{vxfen_script_timeout}\n";
    }
    return $str;
}

# get the vip(s) and port(s) from configure
sub get_cps_vxfenmode_str_when_upgrade {
    my ($pkg,$conf) = @_;
    my (%ports,$defport,$index,$str,$vrtscps_pkg);

    %ports = %{$conf->{ports}};
    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    $defport = $vrtscps_pkg->{default_https_port};
    $index = 1;
    $str = '';

    for my $cps(@{$conf->{cps}}) {
        my $tmpstr = '';
        for my $vip(@{$cps->{vips}}) {
            if ($ports{$vip} && $ports{$vip} ne $defport) {
                $tmpstr .= "[$vip]:$ports{$vip},";
            } else {
                $tmpstr .= "[$vip],";
            }
        }
        $tmpstr =~ s/,$//;
        $str .= "cps$index=$tmpstr\n";
        $index++;
    }

    $str .= "port=$defport\n";

    return $str;
}

sub get_cps_vxfenmode_ordered_str {
    my ($pkg,$newconf,$oldconf,$added_conf) = @_;
    my (%ports,$defport,$index,$str,$vrtscps_pkg);
    my ($orderedconf,@addedcps);
    $orderedconf = {};
    %$orderedconf = %$oldconf;
    @addedcps = @{$added_conf->{cps}};
    %ports = %{$newconf->{ports}};
    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    $defport = $vrtscps_pkg->{defport};

    $str = '';
    $str = "vxfen_mode=customized\nvxfen_mechanism=cps\n";
    $str .= "security=$newconf->{security}\n" if (defined $newconf->{security});
    $str .= "single_cp=1\n" if ($newconf->{ncp} == 1);
    $str .= "fips_mode=$newconf->{fips_mode}\n" if (defined $newconf->{fips_mode});
    $str .= "vxfen_honor_cp_order=$newconf->{vxfen_honor_cp_order}\n" if (defined $newconf->{vxfen_honor_cp_order});
    for my $order(sort {$a <=> $b} keys %{$oldconf->{cporder}}) {
        my $oldcp = $oldconf->{cporder}{$order};
        if ($oldcp !~ /\[/) {
            if ($oldconf->{vxfendg} && (!$newconf->{ndisks}) || ($oldconf->{vxfendg} ne $newconf->{vxfendg})) {
                delete $orderedconf->{cporder}{$order};
            }
            next;
        }
        my $notremoved = 0;
        $oldcp =~ s/^\s*cps\d+\s*=\s*//g;
        $orderedconf->{cporder}{$order} = $oldcp;
        for my $cps(@{$newconf->{cps}}) {
            for  my $vip(@{$cps->{vips}}) {
                if ($oldcp =~ /\b$vip\b/) {
                    $notremoved = 1;
                    last;
                }
            }
            last if ($notremoved);
        }
        next if ($notremoved);
        if (@addedcps) {
            my $cps = shift (@addedcps);
            my $tmpstr = '';
            for my $vip(@{$cps->{vips}}) {
                if ($ports{$vip} ne $defport) {
                    $tmpstr .= "[$vip]:$ports{$vip},";
                } else {
                    $tmpstr .= "[$vip],";
                }
            }
            $tmpstr =~ s/,$//;
            $orderedconf->{cporder}{$order} = $tmpstr;
        } else {
            delete $orderedconf->{cporder}{$order};
        }
    }

    # record the cp following the new order
    $index = 1;
    for my $order(sort {$a <=> $b} keys %{$orderedconf->{cporder}}) {
        my $cp = $orderedconf->{cporder}{$order};
        if ($cp !~ /\[/) {
            $str .= "vxfendg=$orderedconf->{vxfendg}\n";
            next;
        }
        $str .= "cps$index=$cp\n";
        $index ++;
    }
    for my $cps(@addedcps) {
        my $tmpstr = '';
        for my $vip(@{$cps->{vips}}) {
            if ($ports{$vip} ne $defport) {
                $tmpstr .= "[$vip]:$ports{$vip},";
            } else {
                $tmpstr .= "[$vip],";
            }
        }
        $tmpstr =~ s/,$//;
        $str .= "cps$index=$tmpstr\n";
        $index ++;
    }

    # add default port
    $str .= "port=$defport\n";

    if ($newconf->{ndisks}) {
        if ($oldconf->{ndisks}) {
            $str .= "scsi3_disk_policy=$newconf->{scsi3_disk_policy}\n";
        } else {
            $str .= "vxfendg=$newconf->{vxfendg}\nscsi3_disk_policy=$newconf->{scsi3_disk_policy}\n";
        }
    }
    # add parameters in vxfenmode for non-scsi3 fencing
    if ($pkg->{non_scsi3}) {
        $str .= "loser_exit_delay=$newconf->{loser_exit_delay}\n";
        $str .= "vxfen_script_timeout=$newconf->{vxfen_script_timeout}\n";
    }
    return $str;
}

# Create a Sys object for the CPS and return it
sub create_cps_sys {
    my ($pkg,$sysname) = @_;
    my ($sys);

    $sys = $Obj::pool{"Sys::$sysname"} || Sys->new($sysname);
    return $sys;
}

# This function is copy (except rcp call) of the transport_sys
# function in the initiation.pl file. The rcp for CP Server
# which is Virtual IP doesn't work.
sub cps_transport_sys {
    my ($pkg,$sys) = @_;
    my ($edr,$tmppadv,$rtn);
    $edr = Obj::edr();
    # scalars must be passed to threaded call
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');

    # temporarily set the plat/padv for the system to localsys or the
    # first padv in $edr->{padvs}, shouldn't matter during transport_sys
    $sys->{padv}=$edr->{localsys}{padv};

    # check if in the live upgrade
    my $rootpath = Cfg::opt('rootpath') || '';
    Cfg::unset_opt('rootpath') if ($rootpath);

    # check if the system is the local system
    if (!$sys->{islocal}) {
        $tmppadv = $sys->{padv};
        if ($sys->{islocal}="Padv\::$tmppadv"->islocal_sys($sys)) {
            $sys->set_value('islocal', $sys->{islocal});
        }
    }

    $sys->set_value('stop_checks', 0);
    if ($sys->{islocal}) {
        $rtn=$edr->padv_ipv_sys($sys);
    } else {
        $rtn=$edr->ping_sys($sys);
        $rtn=$edr->rsh_sys($sys) if ($rtn);
        $rtn=$edr->shell_sys($sys) if ($rtn);
        $rtn=$edr->padv_ipv_sys($sys) if ($rtn);
        $rtn=$edr->create_tempdir_sys($sys) if ($rtn);
    }

    # enable the rootpath
    Cfg::set_opt("rootpath", $rootpath) if ($rootpath);

    return $rtn;
}

# Check the labeling status of the given disks
# If not labeled already then label them
# Run 'vxdisk scandisks' in the end
#
# Return 1 if cannot label disk(s)
# Return 0 if everything went fine
sub check_disk_labeling {
    my ($pkg, @disks) = @_;
    my ($sys, $disk, $msg, $status,$tmpdir,$auxformat);

    $tmpdir=EDR::tmpdir();
    $auxformat = "$tmpdir/label_while_formattig";

    open my $fh, '+>', $auxformat or return 1;
    print $fh 'label';
    close $fh;

    $status = 0;
    for my $disk (@disks) {
        my ($handle, $label, $temp);
        ($handle, $temp, $temp, $temp, $label) = split(/\s+/m, $disk, 5);
        if ($label eq 'nolabel' || $label eq 'error') {
            $handle =~ s/s\d$//mg if ($handle =~ /s\d$/m);
            for my $sys (@{CPIC::get('systems')}) {
                $sys->cmd("_cmd_format -d $handle -f $auxformat");
                if (EDR::cmdexit()) {
                    Msg::log("Formatting and labeling of disk $handle failed on $sys");
                    $status = 1;
                    next;
                }
                $sys->cmd('_cmd_vxdisk scandisks');
            }
        }
    }
    return $status;
}

sub check_pkg_installed {
    my ($pkg,$cpkg) = @_;
    my ($failed,$msg,$syslist,$vers,$web);
    $cpkg = $pkg->pkg($cpkg) unless (ref($cpkg) =~ m/^Pkg/);
    $web = Obj::web();

    # Check if VRTScps is installed on all the client cluster nodes or not
    $failed = 0;
    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $vers = $cpkg->version_sys($sys,1);
        if ($vers eq '') {
            $failed = 1;
            $msg = Msg::new("$cpkg->{pkg} does not seem to be installed on $sys->{sys}. Install it first and then try again.");
            $msg->bold;
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            Msg::prtc();
        }
    }
    return 0 if ($failed);
    return 1;
}

sub check_ssh_passwdless_sys0_sys {
    my ($pkg,$sys0,$sys) = @_;
    return 1 if ($sys eq $sys0);
    $sys0->cmd("_cmd_ssh -x -o NumberOfPasswordPrompts=0 $sys->{sys} LANG=C LC_ALL=C a=b");
    return 0 if (EDR::cmdexit());
    return 1;
}

sub check_rsh_passwdless_sys0_sys {
    my ($pkg,$sys0,$sys) = @_;
    my $test;
    return 1 if ($sys eq $sys0);
    $test = 'Symantec';
    $sys0->cmd("_cmd_rsh $sys->{sys} LANG=C LC_ALL=C echo $test");
    return 0 if (EDR::cmdexit());
    return 1;
}

sub addnode_get_cp_client_conf {
    my ($pkg,$sys) = @_;
    my (@cps,%ports,$conf,$cp_cnt,$s,$vcs);

    my $ret = 0;

    $vcs = $pkg->prod('VCS61');
    $conf = $vcs->get_vxfen_config_sys($sys);
    $cp_cnt = scalar(@{$conf->{cps}});
    %ports = %{$conf->{cpport}};
    for my $vip(@{$conf->{cps}}) {
        $s = Sys->new($vip);
        # Check if we can communicate with this system
        if (!$pkg->cps_transport_sys($s)) {
            Msg::log("Cannot communicate with Coordination Point Server $s->{sys}");
            $ret = 1;
            return ($ret, \@cps, \%ports);
        }
        push (@cps,$s);
    }

    if ($cp_cnt == 0) {
        Msg::log("Failed to get the Coordination Point information from the vxfenmode file on $sys->{sys}");
        $ret = 1;
    }
    return ($ret, \@cps, \%ports);
}


sub addnode_configure_cpc_sys {
    my ($pkg, $sys, $clusname, $count, $uuid, $cps_aref, $ports_href) = @_;
    my ($cpserver,$msg,$out,$sysname,$user);
    my @cps = @$cps_aref;
    my %ports = %$ports_href;
    my $cpsadm = '/opt/VRTScps/bin/cpsadm';
    $sysname = $sys->{vcs_sysname};
    my ($vcs,$eat_uuid_domain,$vrtscps_pkg);

    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    for my $cpserver (@cps) {
        # create keys/crts for adding node on client side
        $vrtscps_pkg->https_setup_server_trust_sys($sys,$cpserver,$uuid);

        Msg::log("Registering client node $sys->{sys} with Coordination Point Server $cpserver->{sys}");
        $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null |  _cmd_grep $clusname.*${uuid}.*$sysname\\(");
        if (EDR::cmdexit() || $out eq '') {
            $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_node -p $ports{$cpserver->{sys}} -c $clusname -u $uuid -h $sysname -n $count 2>/dev/null");
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_nodes -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null |  _cmd_grep $clusname.*${uuid}.*$sysname\\(");
        }
        if (EDR::cmdexit() || $out eq '') {
            # Clean Up
            for my $tmpcpserver (@cps) {
                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_node -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -h $sysname -n $count 2>/dev/null");
            }
            return 1;
        }

        Msg::log("Adding Coordination Point Client user for communicating to Coordination Point Server $cpserver->{sys}");
        $user = "cpsclient\@$sysname";

        $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} 2>/dev/null | _cmd_grep $user/");
        if (EDR::cmdexit() || $out eq '') {
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_user -p $ports{$cpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} 2>/dev/null | _cmd_grep $user/");
        }
        if (EDR::cmdexit() || $out eq '') {
            # Clean Up
            for my $tmpcpserver (@cps) {
                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_user -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_node -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -h $sysname -n $count 2>/dev/null");
            }
            return 1;
        }

        Msg::log("Adding cluster $clusname to the Coordination Point Client user on Coordination Point Server $cpserver->{sys}");
        $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep $user/.*$clusname");
        if (EDR::cmdexit() || $out eq '') {
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a add_clus_to_user -p $ports{$cpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} -u $uuid 2>/dev/null | _cmd_grep $user/.*$clusname");
        }
        if (EDR::cmdexit() || $out eq '') {
            # Clean Up
            for my $tmpcpserver (@cps) {
                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_user -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -e $user -f cps_operator -g vx 2>/dev/null");
                $tmpcpserver->cmd("$cpsadm -s $tmpcpserver->{sys} -a rm_node -p $ports{$tmpcpserver->{sys}} -c $clusname -u $uuid -h $sysname -n $count 2>/dev/null");
            }
            return 1;
        }
    }
    return 0;
}

sub addnode_configure_nonscsi3_sys {
    my ($pkg, $sys, $clus_node)= @_;
    return 0 if (!$pkg->non_scsi3_supported());
    my $vxfen_proc = $sys->proc('vxfen61');
    # copy non-scsi3 config files from cluster node to new node.
    $clus_node->copy_to_sys($sys, $pkg->{vxenv_file}) if $clus_node->exists($pkg->{vxenv_file});
    if (($sys->linux())) {
        $clus_node->copy_to_sys($sys, $vxfen_proc->{initconf}) if $clus_node->exists($vxfen_proc->{initconf});
    }
    return;
}

sub addnode_configure_cp_agent {
    my ($pkg, $firstnode, $sys, $count) = @_;
    my ($cpgrp, $out, $msg);
    my $vcs = $pkg->prod('VCS61');

    # Find the group containing CoordPoint type resource
    $cpgrp = $firstnode->cmd("$vcs->{bindir}/hares -display -attribute Group -type CoordPoint 2>/dev/null | _cmd_grep -v '^#' | _cmd_awk '{print \$4}'");
    if ($cpgrp ne '') {
        Msg::log("CoordPoint type resource configured in $cpgrp VCS group");
        $out = $firstnode->cmd("$vcs->{bindir}/haconf -makerw");
        if (EDR::cmdexit()) {
            if ($out !~ /Cluster already writable/m) {
                Msg::log("Failed to make VCS configuration writable on $firstnode->{sys}");
                return 1;
            }
        }

        # Add new node to SystemList
        my $sysname = $sys->{vcs_sysname};
        $firstnode->cmd("$vcs->{bindir}/hagrp -modify $cpgrp SystemList -add $sysname $count");
        if (EDR::cmdexit()) {
            Msg::log("Failed to add new node $sys->{sys} to SystemList of $cpgrp VCS group");
            return 1;
        }

        $firstnode->cmd("$vcs->{bindir}/haconf -dump -makero");
    } else {
        Msg::log('No CoordPoint type resource configured');
    }
    return 0;
}

# Find and validate disks which will be used by CPS fencing driver during startup
# Return 0 if all disks could be checked on all nodes
# Return 1 if any of the disk could not be validated on any of the nodes
sub get_coord_disks {
    my ($pkg,$ndisks,$diskpolicy) = @_;
    my ($i, $disk, $group, @disks, @seldisks, $choice, $unused, $msg, $backopt, $help, $def, $errstr, $ayn, $vxvmdisks, @expt_free_disks);
    my $tmpdg = 'tmpfencoorddg';
    my $ret = 0;
    my $cfg = Obj::cfg();
    my $sys = ${CPIC::get('systems')}[0];
    my $devpath = '/dev/vx/rdmp/';
    my ($disklist);
    $backopt = 1;

    while (1) {
        # Present the list of available disks to the user
        eval {$disklist = $pkg->get_dglist_sys($sys);};
        $errstr = $@;
        if ($errstr) {
            $msg = Msg::new("Problem in getting the list of available disks on $sys->{sys}");
            $msg->print;
            Msg::prtc();
            return 1;
        }
        @disks = @{$disklist->{disks}} if (defined($disklist->{disks}));
        @expt_free_disks = @{$disklist->{disks_exported_free}} if (defined($disklist->{disks_exported_free}));

        if($#disks + 1 == 0 && $#expt_free_disks >= 0) {
            next unless ($pkg->ask_unexport_disk eq 'N');
        }
        last;
    }

	while (1) {
        my $numdisks = $#disks + 1;
        if($numdisks < $ndisks) {
            $msg = Msg::new("System $sys->{sys} has only $numdisks free disk(s) out of which $ndisks coordination disk(s) could not be configured");
            $msg->print;
            Msg::prtc();
            ($ret,$vxvmdisks) = $pkg->init_vxvm_disks();
            return $ret if ($ret);
            if (@{$vxvmdisks}) {
                @disks=@{EDRu::arruniq(@disks,@{$vxvmdisks})};
                next;
            } else {
                return 1;
            }
        }
        last;
    }

    for ($i = 1; $i <= $ndisks; $i++) {
        $msg = Msg::new("Select disk number $i for coordination point");
        $msg->bold;

        if (Cfg::opt('responsefile')) {
            $disk = pop (@{$cfg->{fencing_disks}});
        } else {
            $msg = Msg::new("Enter a valid disk which is available from all the cluster nodes for coordination point");
            # (... $backopt, 0, 1) => (... back option, multi-selection disabled, paging enabled)
            $choice = $msg->menu(\@disks, $def, $help, $backopt, 0, 1);
            return -1 if (EDR::getmsgkey($choice,'back'));
            $disk = $disks[$choice - 1];
        }

        # Ask to run vxfentsthdw utility for this disk before continuing
        Msg::n();
        $msg = Msg::new("Before you continue with configuration, Symantec recommends that you run the vxfentsthdw utility (I/O fencing test hardware utility), in a separate console, to test whether the shared storage supports I/O fencing.  You can access the utility at '/opt/VRTSvcs/vxfen/bin/vxfentsthdw'.");
        $msg->print;
        Msg::prtc();

        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("As per the 'vxfentsthdw' run you performed, do you want to continue with this disk?");
            $ayn = $msg->ayny;
            redo if ($ayn eq 'N');
        }

        # skip disk check if disk policy is raw
        unless ($diskpolicy eq 'raw') {
            $unused = $sys->cmd("_cmd_vxfenadm -r $devpath$disk");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Problem reading the reservation on the disk specified by the disk path $devpath$disk");
                $msg->print;
                Msg::prtc();
                return 1;
            } elsif ($unused !~ /No keys/m) {
                $msg = Msg::new("The disk $disk seems to have already been reserved. Try a different disk or unreserve this disk and then try again.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                Msg::prtc();
                redo;
            }

            $unused = $sys->cmd("_cmd_vxfenadm -s $devpath$disk");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Problem reading the keys registered on the disk specified by disk path $devpath$disk");
                $msg->print;
                Msg::prtc();
                return 1;
            } elsif ($unused !~ /No keys/m) {
                $msg = Msg::new("The disk $disk already seems to have the keys registered on it. Try a different disk or unregister the keys on this disk and then try again.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                Msg::prtc();
                redo;
            }
        }
        push (@seldisks, $disk);
        splice(@disks, $choice - 1, 1);
    }
    Msg::prtc();
    return ($ret, @seldisks);
}

#
# Subroutine to configure disk based fencing on this cluster
#
# Input:
# Output:
#       Return 0 if disk based fencing configured on all nodes in this cluster
#       Return 1 if disk based fencing could not be configured on any of the nodes in this cluster
#       Return -1 if 'b' is input.
#
sub configure_dskfenc {
    my ($pkg,$dgtype,$diskpolicyOptions) = @_;
    my (@disks,$msg,$newdg_menuopt,$cfg,$webresult,$dglist,$web,$backopt,$addmsg,$sys,$ayn,@items,$group,$cpic,$str,$vxfen,$line,$menuopt,$vmmode,$diskpolicy,@groups,@multisels,$dgname,$help,$dg_menuopt,$choice,@expt_free_disks);
    my ($oldvxfenconf,$ret,$vxvmdisks,$vcs);
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $sys=${$cpic->{systems}}[0];
    $vcs = $pkg->prod('VCS61');
    $web=Obj::web();
    $diskpolicy='dmp';
    $backopt=1;
    # Check if VM is already running. If not, return 1
    $vmmode=$sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    if ($vmmode !~ /enable/m) {
        $msg=Msg::new("Make sure Volume Manager is running before configuring disk based fencing");
        $msg->error();
        $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
        return 1;
    }

    while (1) {
        unless ((Obj::webui()) && ($dgtype ne '0')) {
            $msg=Msg::new("Do you have SCSI3 PR enabled disks?");
            $help = Msg::new("SCSI-3 Persistent Reservation (SCSI-3 PR) supports device access from multiple systems, or from multiple paths from a single system. At the same time it blocks access to the device from other systems, or other paths.\nUse of SCSI 3 PR protects against all elements in the IT environment that might be trying to write illegally to storage, not only VCS related elements.");
            $ayn=$msg->ayny($help, $backopt);
        }
        return -1 if (EDR::getmsgkey($ayn,'back'));
        Msg::n();
        if ($ayn eq 'N') {
            if(CPIC::get('prod')=~/SFSYBASECE/m){
                $msg=Msg::new("Fencing cannot be configured without SCSI3 PR disks in Sybase mode");
            }else{
                $msg=Msg::new("Since you don't have SCSI3 PR enabled disks, you cannot configure disk based fencing but you can use Coordination Point client based fencing");
            }
            $msg->print;
            Msg::n();
            $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
            return 1;
        }

        $msg=Msg::new("Since you have selected to configure disk based fencing, you need to provide the existing disk group to be used as coordinator or create a new disk group for it.");
        $msg->print;
        Msg::n();

        $dglist=$pkg->get_dglist_sys($sys);
        @groups=@{$dglist->{diskgroups}} if (defined($dglist->{diskgroups}));
        @disks=@{$dglist->{disks}} if (defined($dglist->{disks}));
        @expt_free_disks=@{$dglist->{disks_exported_free}} if (defined($dglist->{disks_exported_free}));
        # to choose with one of the option to create a new disk group
        # if the user chose to create a new disk group, present the list of disks
        $msg=Msg::new("Create a new disk group");
        $newdg_menuopt=$msg->{msg};
        $menuopt=[$newdg_menuopt];
        # and ask the user to choose exactly 3 disks either raw/dmp
        # create a disk group through vxdg -o <disk group name> disks
        # confirm this disk group for fencing configuration and populate /etc/vxfenmode
        if (!Cfg::opt('responsefile')) {
            if (Obj::webui()) {
                if ($dgtype eq '0') {
                    $choice = 1;
                }
            } else {
                $msg=Msg::new("Select one of the options below for fencing disk group:");
                $msg->print;
                $msg=Msg::new("Using an existing disk group");
                $dg_menuopt=$msg->{msg};
                push (@{$menuopt},$dg_menuopt) if (@groups>0);
                $msg=Msg::new("Enter the choice for a disk group:");
                $choice=$msg->menu($menuopt,'','',$backopt);
            }
        }
        next if (EDR::getmsgkey($choice,'back'));
        last;
    }

    if($choice==1) {
        while ($#disks + 1 == 0 && $#expt_free_disks >= 0) {
            if ($pkg->ask_unexport_disk eq 'Y') {
                $dglist=$pkg->get_dglist_sys($sys);
                @disks=@{$dglist->{disks}} if (defined($dglist->{disks}));
                @expt_free_disks=@{$dglist->{disks_exported_free}} if (defined($dglist->{disks_exported_free}));
                next;
            }
            last;
        }

        $msg=Msg::new("\nList of available disks to create a new disk group");
        $msg->print;
        while(1) {
             if(@disks<3) {
                 my $numdisks = $#disks + 1;
                 $msg=Msg::new("A new disk group cannot be created as the number of available free VxVM CDS disks is $numdisks which is less than three. If there are disks available which are not under VxVM control, use the command vxdisksetup or use the installer to initialize them as VxVM disks.");
                 $msg->print;
                 $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
                 ($ret,$vxvmdisks) = $pkg->init_vxvm_disks();
                 return $ret if ($ret);
                 if (@{$vxvmdisks}) {
                     @disks=@{EDRu::arruniq(@disks,@{$vxvmdisks})};
                     next;
                 } else {
                     $msg=Msg::new("Initializing VxVM disk failed.");
                     $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
                     return 1;
                 }
             }
             last if (Obj::webui());
             $menuopt=[ @disks ];
             $msg=Msg::new("Select odd number of disks and at least three disks to form a disk group. Enter the disk options, separated by spaces:");
             # enable multi select and paging
             $choice=$msg->menu($menuopt,'','',$backopt,1,1);
             if (EDR::getmsgkey($choice,'back')) {
                 return -1;
             }
             @multisels=@{$choice};

             if((@multisels < 3) || (scalar(@multisels)%2 == 0)) {
                 $msg=Msg::new("The total number of disks should be odd and no less than three. Input again");
                 $msg->print;
                 next;
             }
             if(!EDRu::arr_isuniq(@multisels)) {
                 $msg=Msg::new("Duplicate inputs. Input again");
                 $msg->print;
                 next;
             }
             last;
        }
        # Create disk group with vxdg
        if (Obj::webui()) {
            $webresult = $web->web_script_form('new_dg',$pkg,\@disks);
            return '__back__' if ($webresult eq 'back'||$webresult eq '');
            if (ref($webresult) ne "HASH") {
                $web->web_script_form('alert',$webresult);
                return 1;
            }
            $dgname = $webresult->{dg_name};
            @multisels = @{$webresult->{disks}};
            $diskpolicyOptions=$webresult->{mechanismOptions};
        } else {
            Msg::n();
            while (1) {
                $msg=Msg::new("Enter the new disk group name:");
                $dgname=$msg->ask('','',$backopt);
                if (EDR::getmsgkey($dgname,'back')) {
                    return -1;
                }
                next if (!$pkg->validate_dgname($dgname));
                last if ($pkg->validate_diskgroup($dgname,1));
                $msg=Msg::new("Disk group name already exists. Input again");
                $msg->print;
            }
            $line='';
            for my $choice (@multisels) {
                $line.="$disks[$choice-1] ";
            }
            # create new fencing dg
            return 1 if (!$pkg->create_new_dg_sys($sys,$dgname,$line));
            EDRu::despace($line);
            @items = split(/\s+/m,$line);
            $cfg->{fencing_newdg_disks}=[ @items ];
        }
    } elsif (!Cfg::opt('responsefile')) {
        if (Obj::webui()) {
            $dgname = $dgtype;
        } else {
            $dgname=$pkg->select_fencing_dg_sys($sys,$dglist);
        }
        if (EDR::getmsgkey($dgname,'back')) {
            return -1;
        }
        return 1 if (!$dgname);
        return 1 if (!$pkg->validate_dgnum($dgname));
    }

    if (Cfg::opt('responsefile')) {
        $dgname=$cfg->{fencing_dgname};
        $diskpolicy=$cfg->{fencing_scsi3_disk_policy};
        if (defined($cfg->{fencing_newdg_disks}) && @{$cfg->{fencing_newdg_disks}}) {
            $line=join (' ', @{$cfg->{fencing_newdg_disks}});
            # create new fencing dg
            return 1 if (!$pkg->create_new_dg_sys($sys,$dgname,$line));
        }
        return 1 if (!$pkg->validate_dgnum($dgname));
    }
    if (!Cfg::opt('responsefile')) {
        Msg::n();
        $addmsg = Msg::new("Before you continue with configuration, Symantec recommends that you run the vxfentsthdw utility (I/O fencing test hardware utility), in a separate console, to test whether the shared storage supports I/O fencing.  You can access the utility at '/opt/VRTSvcs/vxfen/bin/vxfentsthdw'.");
        $addmsg->print;
        $msg = Msg::new("As per the 'vxfentsthdw' run you performed, do you want to continue with this disk group?");
        $ayn = $msg->ayny('','',$addmsg);
        return 1 if ($ayn eq 'N');
    }

    $msg=Msg::new("\nUsing disk group $dgname");
    $msg->print;
    $sys->cmd("_cmd_vxdg deport $dgname");
    $sys->cmd("_cmd_vxdg -t import $dgname");
    $sys->cmd("_cmd_vxdg -g $dgname set coordinator=on");
    $sys->cmd("_cmd_vxdg deport $dgname");

    # Populate /etc/vxfenmode with the details
    if (!Cfg::opt('responsefile') && ($sys->{platvers} !~ /11\.31/m)) {
        if (Obj::webui()){
            $diskpolicy = $diskpolicyOptions;
        }else{
            while (1) {
                # Input for fencing disk poilicy
                $help=Msg::new("Fencing driver can use raw or dmp devices for its operation. Fencing disk policy indicates what kind of devices are being used by the driver. Input values are raw or dmp.");
                Msg::n();
                $msg=Msg::new("Enter disk policy for the disk(s) (raw/dmp):");
                $diskpolicy=$msg->ask('',$help,$backopt);
                if (EDR::getmsgkey($diskpolicy,'back')) {
                    return -1;
                }
                last if ($diskpolicy =~ /^(raw|dmp)$/mx);
                $msg=Msg::new("Invalid input. Retry.");
                $msg->print;
            }
        }
    }

    Msg::log("Fencing configuration =>> diskgroup:$dgname, disk policy:$diskpolicy");

    Msg::title();
    $msg=Msg::new("I/O fencing configuration verification");
    $msg->bold;
    $addmsg = $msg->{msg};
    $msg=Msg::new("\n\tDisk Group: $dgname");
    $msg->print;
    $addmsg .= $msg->{msg};
    $msg=Msg::new("\n\tFencing disk policy: $diskpolicy");
    $msg->print;
    $addmsg .= $msg->{msg};
    $msg=Msg::new("\nIs this information correct?");
    $ayn=$msg->ayny('','',$addmsg);
    if ($ayn eq 'N') {
        return -1;
    }
    $ret = $pkg->confirm_stop_vcsfen();
    return $ret if ($ret);
#    $web->tsub("web_script_form","stopprocess");
    $cfg->{fencing_dgname}=$dgname;
    $cfg->{fencing_scsi3_disk_policy}=$diskpolicy;
    $msg = Msg::new("Configure fencing");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());

    Msg::n();
    $pkg->stop_vcsfen();

    unless (-3 == $pkg->{status}) {
        # CPS Clean Up
        # senario: migrating from CPS to disk based fencing
        # 1. clean up cps database
        $oldvxfenconf = $vcs->get_vxfen_config_sys($sys);
        $pkg->cleanup_from_cps($oldvxfenconf);
        # 2. vxfen config file clean up
        $pkg->update_vxfen_files_without_nonscsi3();
    }

    for my $sys (@{$cpic->{systems}}) {
        $str=EDRu::datetime();
        # Populate /etc/vxfendg
        if ($sys->exists($pkg->{vxfendg_file})) {
            $sys->cmd("_cmd_cp $pkg->{vxfendg_file} $pkg->{vxfendg_file}-$str");
        }
        $sys->cmd("echo $dgname > $pkg->{vxfendg_file}");

        # Populate /etc/vxfenmode
        if ($sys->exists($pkg->{vxfenmode_file})) {
            $sys->cmd("_cmd_cp $pkg->{vxfenmode_file} $pkg->{vxfenmode_file}-$str");
        }
        if(CPIC::get('prod')=~/SFSYBASECE/m){
            $sys->cmd("_cmd_cp /etc/vxfen.d/vxfenmode_sybase $pkg->{vxfenmode_file}");
            $pkg->update_vxfen_sybase_sys($sys, $diskpolicy);
        }else{
            $sys->cmd("_cmd_cp /etc/vxfen.d/vxfenmode_scsi3_$diskpolicy $pkg->{vxfenmode_file}");
        }
    }

    for my $sys (@{$cpic->{systems}}) {
        # Start VXFEN now.
        $msg=Msg::new("Starting Fencing on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $vxfen=$pkg->proc('vxfen61');
        $vxfen->enable_sys($sys);
        if ($cpic->proc_start_sys($sys, $vxfen)) {
            CPIC::proc_start_passed_sys($sys, $vxfen);
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
            $pkg->{status}=1;
        } else {
            $vxfen->{noreboot_failstart}=1;
            CPIC::proc_start_failed_sys($sys, $vxfen);
            Msg::right_failed();
            $pkg->{status}=-3;
            $msg=Msg::new("Could not start VxFEN on $sys->{sys}");
            $msg->print;
            $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
            return 1;
        }
    }

    return 0;
}

sub init_vxvm_disks {
    my (@disks,@initdisks,$ayn,$disk,$group,$list,$msg,$pkg,$ret,$rootdisk,$sys,$web,$result);
    my (@multisels,$backopt,$choice,$menuopt,$status);
    $pkg = shift;
    $sys = ${CPIC::get('systems')}[0];
    $backopt = 1;
    $web = Obj::web();

    $rootdisk=$sys->cmd('_cmd_vxgetrootdisk 2>/dev/null');
    $list=$sys->cmd('_cmd_vxdisk -o alldgs list 2>/dev/null | _cmd_grep -v LVM |_cmd_grep -v cdsdisk');
    for my $line(split(/\n/,$list)) {
        next if ($line =~ /DEVICE\s+TYPE/m);
        ($disk,undef,undef,$group,$status)=split(/\s+/m,$line);
        next if (($disk eq $rootdisk) || ($status eq 'error'));
        if ($group eq '-') {
            push (@disks, $disk);
        }
    }
    if (@disks) {
        $msg = Msg::new("\nDo you want to initialize more disks as VxVM disks?");
        $ayn = $msg->ayny('',$backopt);
        return -1 if (EDR::getmsgkey($ayn,'back'));
        return 1 if ($ayn eq 'N');
        $msg = Msg::new("\nList of disks which can be initialized as VxVM disks:");
        $msg->print;
        if (Obj::webui()){
            $result = $web->web_script_form('select_disk',\@disks);
            @multisels=@{$result->{disks}};
            $msg = Msg::new("Intializing disks");
            $web->web_script_form('showstatus',$msg->{msg});
        } else {
            while (1) {
                $menuopt=[ @disks ];
                $msg=Msg::new("Enter the disk options, separated by spaces:");
                # enable multi select and paging
                $choice=$msg->menu($menuopt,'','',$backopt,1,1);
                return -1 if (EDR::getmsgkey($choice,'back'));
                @multisels=@{$choice};
                if(!EDRu::arr_isuniq(@multisels)) {
                    $msg=Msg::new("Duplicate inputs. Input again");
                    $msg->print;
                    next;
                }
                last;
            }
       }
       for my $choice (@multisels) {
           $disk = $disks[$choice-1];
           $msg = Msg::new("Intializing disk $disk on $sys->{sys}");
           $msg->left;
           $msg->display_left($msg) if (Obj::webui());
           my $tmpdisk = $disk;
           # remove the slice no
           $tmpdisk =~ s/s\d+$// if ($sys->{plat} eq 'SunOS');
           $sys->cmd("_cmd_vxdisksetup -i $tmpdisk");
           if (EDR::cmdexit()) {
               Msg::right_failed();
               Msg::prtc();
               next;
           }
           Msg::right_done();
           $msg->display_right() if (Obj::webui());
           push (@initdisks,$disk);
       }
       Msg::n();
    }

    return ($ret,\@initdisks);
}

sub update_vxfen_sybase_sys {
    my ($pkg,$sys,$diskpolicy) = @_;
    my ($out,$out1,$tempdir,$tempfile);
    $tempfile='vxfenmode_sybase';
    $tempdir=EDR::tmpdir();
    $sys->cmd("_cmd_mv $pkg->{vxfenmode_file} $tempdir/$tempfile");
    $out=$sys->cmd("_cmd_cat $tempdir/$tempfile 2>/dev/null");

    for my $line (split(/\n/,$out)) {
        if($line !~/\s+?#/m && $line=~/scsi3_disk_policy=/mx){
            $line="scsi3_disk_policy=$diskpolicy";
        }
        $out1.="$line\n";
    }

    $sys->writefile($out1,$pkg->{vxfenmode_file});
    return;
}

sub destroy_dg {
    my ($pkg, $dgname) = @_;
    my $sys = ${CPIC::get('systems')}[0];
    $sys->cmd("_cmd_vxdg -t import $dgname");
    $sys->cmd("_cmd_vxdg -g $dgname set coordinator=off");
    $sys->cmd("_cmd_vxdg destroy $dgname");
    return;
}

sub disk_coordinator_flag_sys {
    my ($pkg,$sys,$diskname) = @_;
    my ($str);
    $str=$sys->cmd("_cmd_vxdisk list $diskname | _cmd_grep flags");
    return 1 if ($str=~/coordinator/m);
    return 0;
}

sub get_dglist_sys {
    my ($pkg,$sys) = @_;
    my (@disks,@disks_inuse,$dglist,$disk,$group,$line,@grps,$list,%groups,@expt_free_disks,@status,$vm);
    $dglist={};
    $vm=$pkg->prod('VM61');
    # Get all the physically fully shared disks in CVM cluster using '-o fullshared'
    $list = $sys->cmd('_cmd_vxdisk -o fullshared -o alldgs list 2>/dev/null | _cmd_grep online |_cmd_grep cdsdisk');
    if (EDR::cmdexit()) {
        $list=$sys->cmd('_cmd_vxdisk -o alldgs list 2>/dev/null | _cmd_grep online |_cmd_grep cdsdisk');
    }
    for my $line (split(/\n/,$list)) {
        next if ($line =~ /DEVICE\s+TYPE/m);
        ($disk,undef,undef,$group,@status)=split(/\s+/m,$line);
        if ($group eq '-') {
            # In platforms which should not support FSS, shared disk are also be able to export/unexport,
            # so we don't check whether it's fss enabled platform or not
            #if ($vm->is_fss_enabled() && grep(m/exported|remote/, @status)) {
            if (grep(m/exported|remote/, @status)) {
                push (@expt_free_disks, $disk);
            } else {
                push (@disks, $disk);
            }
        } else {
            if ($group=~/[\(\)]/m) {
                $group=~s/[\(\)]//mg;
                $dglist->{$group}{state}||='deported';
            }
            $dglist->{$group}{state}||='imported';
            $dglist->{$group}{coordinator_flag}||=1
                if ($pkg->disk_coordinator_flag_sys($sys,$disk));
            push (@{$dglist->{$group}{disks}}, $disk);
            $groups{$group}=1;
            push (@disks_inuse, $disk);
            $dglist->{ingroup}{$disk}=$group;
        }
    }
    @grps=keys %groups;
    $dglist->{diskgroups}=[ @grps ];
    $dglist->{disks}=[ @disks ];
    $dglist->{disks_inuse}=[ @disks_inuse ];
    if ($vm->is_fss_enabled()) {
        $dglist->{disks_exported_free}=[ @expt_free_disks ];
    }
    return $dglist;
}

sub select_fencing_dg_sys {
    my ($pkg,$sys,$dglist) = @_;
    my ($msg,$errormsg,$menuopt,@groups,$dg,$choice);
    @groups=();
    for my $dg (@{$dglist->{diskgroups}}) {
        if ($dglist->{$dg}{coordinator_flag}) {
            push (@groups,"$dg(coordinator)");
        } else {
            push (@groups,$dg);
        }
    }
    $menuopt=[ @groups ];
    $msg=Msg::new("Select one disk group as fencing disk group:");
    $choice=$msg->menu($menuopt,'','',1,0,1);
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

sub create_new_dg_sys {
    my ($pkg,$sys,$dgname,$disks_line) = @_;
    my ($msg);
    $sys->cmd("_cmd_vxdg init $dgname $disks_line");

    if (EDR::cmdexit()) {
        Msg::n();
        $msg=Msg::new("Disk group $dgname failed to be created");
        $msg->printn;
        return '';
    }
    if(!$pkg->validate_diskgroup($dgname)) {
        Msg::n();
        $msg=Msg::new("Disk group $dgname is not available on all the nodes. Ensure all the fencing disks are available on all the nodes.");
        $msg->warning;
        Msg::prtc();
        $sys->cmd("_cmd_vxdg destroy $dgname");
        return '';
    } else {
        $msg=Msg::new("Created disk group $dgname");
        $msg->print;
        $pkg->{newdg}=$dgname;
    }
    return 1;
}

sub migrate_fencing {
    my $pkg = shift;
    my ($vxfen_mode,$ret,$sys0);
    $sys0 = ${CPIC::get('systems')}[0];
    $ret = $pkg->migrate_fencing_precheck();
    return $ret if ($ret);
    $vxfen_mode = $pkg->vxfen_mode_sys($sys0);
    $ret = $pkg->replace_cp($vxfen_mode);
    return $ret;
}

sub migrate_fencing_precheck {
    my $pkg = shift;
    my (@rshfail_systems,@sshfail_systems,$msg,$sys0,$syslist,$vxfen_mode,$web);

    $web = Obj::web();
    $syslist = CPIC::get('systems');
    $sys0 = $$syslist[0];
    @sshfail_systems = ();
    @rshfail_systems = ();
    $sys0->{rsh_option} = '';

    # systems configuration precheck
    undef($pkg->{sybase_mode});
    for my $sys(@{$syslist}) {
        $vxfen_mode = $pkg->vxfen_mode_sys($sys);
        if ($vxfen_mode !~ /(disk|cps|sybase|nonscsi3)/im) {
            $msg = Msg::new("vxfen is not running in enabled mode or online migration from current mode is not supported on $sys->{sys}");
            $msg->print;
            $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
            Msg::prtc();
            return -1;
        }
        next if ($sys eq $sys0);
        # check ssh or rsh passwdless
        if(!$pkg->check_ssh_passwdless_sys0_sys($sys0,$sys)) {
            push(@sshfail_systems,$sys);
        }
        if (!$pkg->check_rsh_passwdless_sys0_sys($sys0,$sys)) {
            push(@rshfail_systems,$sys);
        }
    }
    # vxfenswap requires the systems all use ssh or all use rsh, some use ssh while others use rsh is not allowed
    if ((@sshfail_systems) && (@rshfail_systems)) {
        $msg = Msg::new("Online fencing migration requires that ssh or rsh commands used between systems in the cluster execute without prompting for passwords. Configure ssh or rsh for password free logins first");
        $msg->print;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        Msg::prtc();
        return 1;
    }
    $pkg->{sybase_mode} = 1 if ($vxfen_mode =~ /sybase/im);
    $sys0->{rsh_option} = (@sshfail_systems) ? '-n' : '';
    return 0;
}

sub replace_cp {
    my ($pkg,$vxfen_mode) = (@_);
    my ($clusid,$clusname,$diskpolicy,$vcs,$vcs_conf,$uuid);
    my ($cfg,$backopt,$defopt,$help,$menu,$menuopt,$msg,$ret,$str,$sys0,$syslist);
    my ($added_cp_href,$conf_href,$oldvxfenconfig,$removed_cp_href);
    my ($dgname,$newconf,$scsi3,$security,$web,$fips_mode);
    my ($cpres,$cp_count,$fault_tolerance);
    $cfg = Obj::cfg();
    $web = Obj::web();
    $syslist = CPIC::get('systems');
    $sys0 = $$syslist[0];
    $backopt = 1;
    $security = 0;
    $vcs = $pkg->prod("VCS61");

    # get vxfen config file info before migration
    $oldvxfenconfig = $vcs->get_vxfen_config_sys($sys0);

    # Display current coordination points and ask coordination points to be removed.
    Msg::title();
    $msg = Msg::new("Online fencing migration allows you to online replace coordination points.");
    $msg->printn;
    $msg = Msg::new("Installer will ask questions to get the information of the coordination points to be removed or added. Then it will call vxfenswap utility to commit the coordination points change.");
    $msg->printn;
    $msg = Msg::new("Warning: It may cause the whole cluster to panic if a node leaves membership before the coordination points change is complete.");
    $msg->bold;
    Msg::n();
    ($ret,$conf_href) = $pkg->get_current_coord_points();
    return $ret if ($ret);
    if ($conf_href->{ncp} == 0) {
        $msg = Msg::new("Could not proceed as there was no coordination point");
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        $msg->print;
        return 1;
    }
    ($ret,$removed_cp_href) = $pkg->ask_coord_points_to_remove($conf_href);
    return $ret if ($ret);
    my $removed_ncp =  $removed_cp_href->{ncp};

    # Ask coordination points to be added.
    Msg::title();
    ($ret,$added_cp_href) = $pkg->ask_coord_points_to_add($conf_href,$removed_ncp);
    return $ret if ($ret);

    # Diskplay the removed and added info
    $ret = $pkg->display_new_cp_info($conf_href,$removed_cp_href,$added_cp_href);
    return $ret if ($ret);

    # Check if VRTScps pkg is installed on all nodes.
    if (@{$added_cp_href->{cps}}) {
        return 1 if (!$pkg->check_pkg_installed('VRTScps61'));
    }

    Msg::title();
    ($ret,$newconf) = $pkg->get_new_coord_points($conf_href,$removed_cp_href,$added_cp_href);

    # Set cluster info
    $clusid = $cfg->{vcs_clusterid};
    $clusname = $cfg->{vcs_clustername};
    unless ($clusname) {
        $vcs_conf = $vcs->get_config_sys($sys0);
        return 1 unless ($vcs_conf);
        $clusname ||= $vcs_conf->{clustername};
        return 1 unless ($clusname);
        $clusid ||= $vcs_conf->{clusterid};
    }
    # get client cluster uuid
    ($ret, $uuid)= $pkg->get_uuid($clusname,$clusid);
    return $ret if ($ret);

    $newconf->{clustername} = $clusname;
    $newconf->{uuid} = $uuid;
    $added_cp_href->{clustername} = $clusname;
    $added_cp_href->{uuid} = $uuid;

    # Check the security status of the new CP servers
    if (@{$newconf->{cps}}) {
        for my $server(@{$newconf->{cps}}) {
            if (!$pkg->cps_transport_sys($server)) {
                $msg=Msg::new("Cannot communicate with system $server->{sys}");
                $msg->print;
                return 1;
            }
        }
#        ($ret,$security,$fips_mode) = $pkg->config_cps_cpc_security($newconf->{cps},$newconf->{ports});
        $ret = $pkg->https_config_client_fresh($newconf->{cps},$newconf->{ports});
        return $ret if ($ret);
    }
    $added_cp_href->{security} = $security;
    $newconf->{security} = $security;
    $added_cp_href->{fips_mode} = $fips_mode;
    $newconf->{fips_mode} = $fips_mode;

    # Check if all coordination points are disks
    if (!@{$newconf->{cps}}) {
        if ($vxfen_mode eq 'cps') {
        	if (Obj::webui()) {
        		$cfg->{fencing_mode} = $web->web_script_form('disk_mode');
        		$scsi3 = 1 if ($cfg->{fencing_mode} eq 'scsi3');
        	} else {
                $msg = Msg::new("All the coordination points are disks. You can configure vxfen in either scsi3 mode or customized mode, choose 'SCSI3' mode for disk based fencing or 'customized' mode for cps based fencing. Symantec recommends to configure vxfen in scsi3 mode.");
                $msg->print;
                $menuopt = [];
                $msg = Msg::new("SCSI3");
                push (@{$menuopt}, $msg->{msg});
                $msg = Msg::new("Customized");
                push (@{$menuopt}, $msg->{msg});
                $msg = Msg::new("Select the vxfen mode:");
                $defopt = 1;
                $help = Msg::new("Since all coordination points are disks, it is recommended to configure vxfen in scsi3 mode");
                if (Cfg::opt('responsefile')) {
                    $menu = ($cfg->{fencing_mode} eq 'scsi3') ? 1 : 2;
                } else {
                    $menu = $msg->menu($menuopt,$defopt,$help,$backopt);
                    $cfg->{fencing_mode} = ($menu == 1) ? 'scsi3' : 'customized';
                }
                return $menu if (EDR::getmsgkey($menu,'back'));
                $scsi3 = 1 if ($menu == 1);
        	}
        } else {
            $scsi3 = 1;
        }
    } else {
        # retain vxfen_honor_cp_order value in old /etc/vxfenmode file
        $newconf->{vxfen_honor_cp_order} = $conf_href->{vxfen_honor_cp_order};
    }

    # Check if using current diskgroup and disk policy or create new dg
    $dgname = $conf_href->{vxfendg};
    $diskpolicy = $conf_href->{scsi3_disk_policy};
    $removed_cp_href->{vxfendg} = $dgname;
    if ((!$dgname) && ($newconf->{ndisks})) {
        Msg::n();
        ($ret,$dgname) = $pkg->ask_new_fencing_dgname();
        return $ret if ($ret);
        Msg::n();
        if(Obj::webui()){
        	$diskpolicy = $web->{migration_mechanism};
        	undef $web->{migration_mechanism};
        } else {
        	($ret,$diskpolicy) = $pkg->ask_disk_policy();
            return $ret if ($ret);
        }

        $cfg->{fencing_dgname} = $dgname;
        $cfg->{fencing_scsi3_disk_policy} = $diskpolicy;
    }

    $added_cp_href->{vxfendg} = $dgname;
    $newconf->{vxfendg} = $dgname;
    $newconf->{scsi3_disk_policy} = $diskpolicy;

    # disable cpagent LevelTwoMonitorFreq temporarily
    $pkg->{orig_cpagent_level2freq} = $pkg->disable_cpagent_level2freq();
    $pkg->{cpagent_level2freq_disabled_by_cpi} = 1;

    if ($removed_cp_href->{ndisks}) {
        Msg::n();
        $msg = Msg::new("Removing disks from disk group $removed_cp_href->{vxfendg}");
        $msg->printn;
        $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
        my $adddisk = $added_cp_href->{ndisks};
        $ret = $pkg->remove_disks($removed_cp_href,$adddisk);
        return $ret if ($ret);
    }

    $ret = $pkg->add_coord_points($added_cp_href,$removed_cp_href);
    return $ret if ($ret);

    if ($scsi3) {
        $pkg->prepare_disk_test_files($diskpolicy);
        Msg::n();
        $ret = $pkg->vxfenswap($dgname);

    } else {
        if ($newconf->{vxfen_honor_cp_order}) {
            $str = $pkg->get_cps_vxfenmode_ordered_str($newconf,$conf_href,$added_cp_href);
        } else {
            $str = $pkg->get_cps_vxfenmode_str($newconf);
        }
        $pkg->prepare_cps_test_files($str);
        Msg::n();
        $ret = $pkg->vxfenswap();
    }
    # if vxfenswap failed, roll back the change made by installer
    if ($ret) {
        my $ret2 = $pkg->rollback_disk_change($removed_cp_href,$added_cp_href);
        if ($ret2) {
            $msg = Msg::new("Failed to recover original fencing disk group. Refer to the installation guide or consult technical support to recover it manually");
            $msg->printn;
        }
        $ret2 = $pkg->rollback_server_change($added_cp_href);
        if ($ret2) {
            $msg = Msg::new("Failed to remove the cluster information from newly added Coordination Point servers. Refer to the installation guide or consult technical support to remove it from the newly added Coordination Point servers manually");
            $msg->printn;
        }
        return $ret;
    }

    $pkg->{no_coord_disks} = 1 if (!$newconf->{ndisks});
    # ask to configure cp agent if needed
    if (!$pkg->check_cpagent_configured()) {
        $pkg->ask_configure_cpagent();
    } else {
        # if at least one coordination disk and original cpagent level2monitorfreq is not set
        # ask if user would like to set it
        if (!$pkg->{no_coord_disks} && !$pkg->{orig_cpagent_level2freq}) {
            $pkg->update_cpagent_level2freq();
            Msg::n();
        }
        # e2768793: if FaultTolerance attribute of cp agent is set,
        # check if it needs to be updated after vxfenswap.
        ($cpres,$fault_tolerance) = $pkg->get_cpagent_attribute_value('FaultTolerance');
        if ($cpres && ($fault_tolerance > 0)) {
            $cp_count = $pkg->get_cp_count();
            my $max = 0;
            $max = int(($cp_count-1)/2) if ($cp_count > 0);
            if ($fault_tolerance > $max) {
                # cp agent will be faulted, ask to update FaultTolerance to new value (0 ~ ($cp_count-1)/2)
                $pkg->update_cpagent_faulttolerance($cpres,$cp_count);
            }
        }
    }

    if (@{$removed_cp_href->{cps}}) {
        $msg = Msg::new("Cleaning up client cluster information on removed Coordination Point servers");
        $msg->print;
        $ret = $pkg->remove_cps($removed_cp_href->{cps},$oldvxfenconfig,$newconf->{cps});
        return $ret if ($ret);
        Msg::n();
    }

    return 0;
}

sub refresh_cp_registrations {
    my $pkg=shift;
    my ($msg,$ret,$sys0);
    my ($dglist,$vcs,$vxfenconfig,$vxfen_mode,$web,$web_msg);
    $web = Obj::web();
    $ret = $pkg->migrate_fencing_precheck();
    return $ret if ($ret);

    Msg::title();
    $msg = Msg::new("If the coordination points lose the registrations of the cluster nodes, the cluster might panic when a network partition occurs. You must refresh registrations on coordination points if the CoordPoint agent issues an alert on the loss of such registrations.");
    $msg->printn;
    $web_msg = $msg->{msg}.'\n' if (Obj::webui());
    $msg = Msg::new("You can perform a planned refresh of registrations on coordination points when the VCS cluster is online, without incurring application downtime on the VCS cluster. This operation does not affect any existing registrations on the coordination points.");
    $msg->printn;
    $web_msg .= $msg->{msg}.'\n' if (Obj::webui());
    $msg = Msg::new("Warning: It may cause the whole cluster to panic if a node leaves membership before the coordination points change is complete.");
    $msg->bold;
    $web_msg .= $msg->{msg}.'\n' if (Obj::webui());
    Msg::n();
    $web->web_script_form('alert',$web_msg) if (Obj::webui());
    $sys0 = ${CPIC::get('systems')}[0];
    # get vxfen config info from vxfenmode file
    $vcs = $pkg->prod('VCS61');
    $vxfenconfig = $vcs->get_vxfen_config_sys($sys0);
    $vxfen_mode = $pkg->vxfen_mode_sys($sys0);
    $dglist = $pkg->get_dglist_sys($sys0);
    if ($vxfen_mode =~ /^(disk|sybase)$/m) {
        $ret = $pkg->refresh_disk_fencing_reg($vxfenconfig,$dglist);
    } elsif($vxfen_mode =~ /^(cps|nonscsi3)$/m) {
        $ret = $pkg->refresh_cps_fencing_reg($vxfenconfig,$dglist);
    } else {
        $msg = Msg::new("This option is not supported since vxfen is not running in enabled mode");
        $msg->printn;
        $ret = 1;
    }
    return $ret;
}

sub refresh_disk_fencing_reg {
    my ($pkg,$vxfenconfig,$dglist) = (@_);
    my ($msg,$ret,$vxfendg,$web);
    $web = Obj::web();
    $vxfendg = $vxfenconfig->{vxfendg};
    $msg = Msg::new("Make sure that the diskgroup $vxfendg which is currently in use by vxfen contains exactly the same disks which vxfen is currently using as coordination disks. This operation will not affect the disks which have all the registrations in place.");
    $msg->bold;
    Msg::n();
    $web->web_script_form('alert',$msg) if (Obj::webui());
    $ret = $pkg->display_disk_cp_info($vxfenconfig,$dglist);
    return $ret if ($ret);
    $pkg->prepare_test_files();
    Msg::n();
    # commit the change
    $ret = $pkg->vxfenswap($vxfendg);
    return $ret;
}

sub refresh_cps_fencing_reg {
    my ($pkg,$vxfenconfig,$dglist) = (@_);
    my ($cfg,$conf,$msg,$ret,$sys0,$vxfendg);
    my ($clusid,$clusname,$uuid,$vcs,$vcs_conf,$web);
    $web = Obj::web();
    $cfg = Obj::cfg();
    $sys0 = ${CPIC::get('systems')}[0];
    $vxfendg = $vxfenconfig->{vxfendg};
    $msg = Msg::new("Make sure that the /etc/vxfenmode file contains exactly the same coordination points which are currently in use by vxfen. Also, make sure that the diskgroup $vxfendg mentioned in the /etc/vxfenmode file contains exactly the same disks that vxfen is currently using as coordination disks. This operation will not affect the coordination points that have all the registrations in place.");
    $msg->bold;
    Msg::n();
    $web->web_script_form('alert',$msg) if (Obj::webui());
    ($ret,$conf) = $pkg->get_current_coord_points();
    $conf->{security} = $vxfenconfig->{security};
    $conf->{fips_mode} = $vxfenconfig->{fips_mode};
    $clusid = $cfg->{vcs_clusterid};
    $clusname = $cfg->{vcs_clustername};
    unless ($clusname) {
        $vcs_conf = $vcs->get_config_sys($sys0);
        return 1 unless ($vcs_conf);
        $clusname ||= $vcs_conf->{clustername};
        return 1 unless ($clusname);
        $clusid ||= $vcs_conf->{clusterid};
    }
    # get client cluster uuid
    ($ret, $uuid)= $pkg->get_uuid($clusname,$clusid);
    return $ret if ($ret);
    $conf->{clustername} = $clusname;
    $conf->{uuid} = $uuid;

    $ret = $pkg->display_cp_info($conf,1);
    return $ret if ($ret);

    for my $server(@{$conf->{cps}}) {
        if (!$pkg->cps_transport_sys($server)) {
            $msg=Msg::new("Cannot communicate with system $server->{sys}");
            $msg->print;
            return 1;
        }
    }
    Msg::title();
    $ret = $pkg->update_clusterinfo_on_cps($conf,0,1);
    return $ret if ($ret);

    Msg::n();
    $pkg->prepare_test_files();
    Msg::n();
    # commit the change
    $ret = $pkg->vxfenswap();
    return $ret;
}

sub display_disk_cp_info {
    my ($pkg,$vxfenconfig,$dglist) = (@_);
    my (@disks,$ayn,$diskpolicy,$msg,$vxfendg,$str);

    $vxfendg = $vxfenconfig->{vxfendg};
    $diskpolicy = $vxfenconfig->{scsi3_disk_policy};
    $msg=Msg::new("Coordination points verification:");
    $msg->bold;
    $msg=Msg::new("\n\tDisk Group: $vxfendg");
    $msg->print;
    $msg=Msg::new("\n\tFencing disk policy: $diskpolicy");
    $msg->print;
    if (defined($dglist->{$vxfendg}{disks})) {
        push (@disks, @{$dglist->{$vxfendg}{disks}});
    }
    if (@disks) {
        $str = join("\n\t\t", @disks);
        $msg=Msg::new("\n\tI/O fencing disks:\n\t\t$str");
        $msg->print;
    }

    unless (Cfg::opt('responsefile')) {
        $msg=Msg::new("\nIs this information correct?");
        $ayn=$msg->ayny('','');
        Msg::n();
        return -1 if ($ayn eq 'N');
    }
    return 0;
}

sub prepare_test_files {
    my $pkg=shift;
    my $msg;
    $msg = Msg::new("Preparing vxfenmode.test file on all systems");
    $msg->bold;
    my $web = Obj::web();
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    for my $sys(@{CPIC::get('systems')}) {
        $msg = Msg::new("Preparing /etc/vxfenmode.test on system $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $sys->cmd('_cmd_cp /etc/vxfenmode /etc/vxfenmode.test');
        $msg->right_done;
        $msg->display_right() if (Obj::webui());
    }
    return;
}

sub update_cp_order {
    my $pkg=shift;
    my ($cfg,$msg,$ret,$sys0,$vcs,$vxfenconfig,$web,$web_msg);
    my ($dglist,$new_order_aref);
    $web = Obj::web();
    $cfg = Obj::cfg();
    $sys0 = ${CPIC::get('systems')}[0];
    $vcs = $pkg->prod('VCS61');
    # get vxfen config info from vxfenmode file
    $vxfenconfig = $vcs->get_vxfen_config_sys($sys0);
    if (!defined($vxfenconfig->{cps}) || !@{$vxfenconfig->{cps}}) {
        $msg = Msg::new("This option only supports customized fencing having coordination point servers as coordination points");
        $msg->print;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        Msg::prtc();
        return -1;
    }
    $ret = $pkg->migrate_fencing_precheck();
    return $ret if ($ret);

    Msg::title();
    $msg = Msg::new("Online fencing migration allows you to online change the order of coordination points.");
    $msg->printn;
    $web_msg = $msg->{msg} . '\n' if (Obj::webui());
    $msg = Msg::new("Installer will ask the new order of existing coordination points. Then it will call the vxfenswap utility to commit the coordination points change.");
    $msg->printn;
    $web_msg .= $msg->{msg} . '\n' if (Obj::webui());
    $msg = Msg::new("Warning: It may cause the whole cluster to panic if a node leaves membership before the coordination points change is complete.");
    $msg->bold;
    $web_msg .= $msg->{msg} . '\n' if (Obj::webui());
    $web->web_script_form("alert",$web_msg) if (Obj::webui());
    Msg::n();

    # get vxfen config info from driver
    $vxfenconfig =  $vcs->get_vxfen_config_from_driver_sys($sys0);
    if ($vxfenconfig->{single_cp}) {
        $msg = Msg::new("Only one coordination point is configured, no need to reorder.");
        $msg->print;
        Msg::prtc();
        return -1;
    }

    ($ret, $new_order_aref) = $pkg->ask_cp_order($vxfenconfig);
    return $ret if ($ret);
    $ret = $pkg->display_cp_new_order($vxfenconfig,$new_order_aref);
    return $ret if ($ret);
    $cfg->{fencing_cp_new_order} = $new_order_aref;
    $ret = $pkg->cp_new_order_commit($vxfenconfig,$new_order_aref);
    return $ret;
}

sub ask_cp_order {
    my ($pkg,$vxfenconfig) = (@_);
    my (@disks,@sels,$cp,$cp_count,$sys0,$vxfendg);
    my ($backopt,$cfg,$menu,$menuopt,$help,$line,$msg,$web);
    $cfg = Obj::cfg();
    $web = Obj::web();
    $sys0 = ${CPIC::get('systems')}[0];
    $backopt = 1;

    # Show the current order and ask for new order
    $msg = Msg::new("Current coordination points order: (coordination disks/coordination point server)");
    $msg->bold unless (Cfg::opt('responsefile'));
    for my $i(sort {$a <=> $b} keys%{$vxfenconfig->{cporder}}) {
        @disks = ();
        $cp = $vxfenconfig->{cporder}{$i};
        push (@{$menuopt},$cp);
    }
    $help = Msg::new("Each coordination point server may have more than one virtual IP configured. Reordering of the virtual IP of the coordination point server is not supported; reordering the coordination disks in the fencing disk group is not supported either.");
    $cp_count = @{$menuopt};
    if(Obj::webui()){
        @sels= @{$web->web_script_form("change_cp_order",$menuopt)};
    } else {
        while (1) {
            $msg = Msg::new("Input the new order of the coordination points by the numbers, separated by a space");
            if (Cfg::opt('responsefile')) {
                @sels = @{$cfg->{fencing_cp_new_order}};
            } else {
                $menu = $msg->menu($menuopt,'',$help,$backopt,1);
                return $menu if (EDR::getmsgkey($menu,'back'));
                @sels = @{$menu};
            }
            if (!$pkg->validate_cp_new_order(\@sels,$cp_count)) {
                if (Cfg::opt('responsefile')) {
                    $msg = Msg::new("fencing_cp_new_order is not a valid value in the responsefile");
                    $msg->print;
                    return 1;
                }
                $msg=Msg::new("Invalid input. Re-enter values");
                $msg->print;
                next;
            }
            last;
        }
    }

    return (0,\@sels);
}

sub display_cp_new_order {
    my ($pkg,$vxfenconfig,$order_aref) = (@_);
    my ($ayn,$help,$msg,$webmsg);
    my ($count,$cp);
    # Show all the info so far for user confirmation
    Msg::title();
    $msg = Msg::new("New coordination points order:(coordination disks/coordination point server)");
    $msg->bold;
    $webmsg = $msg->{msg};
    $count = 0;
    for my $order (@{$order_aref}) {
        $count++;
        $cp = $vxfenconfig->{cporder}{$order};
        Msg::print("\t\t${count}. $cp");
        $webmsg .= "\n\t\t${count}. $cp";
    }

    unless (Cfg::opt('responsefile')) {
        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny($help,'',$webmsg);
        Msg::n();
        return -1 if ($ayn eq 'N');
    }
    return 0;
}

sub cp_new_order_commit {
    my ($pkg,$vxfenconfig,$order_aref) = (@_);
    my ($index,$line,$ret,$str,$sys0,$vxfendg);
    my ($defport,$vrtscps_pkg);
    $vrtscps_pkg = $pkg->pkg('VRTScps61');

    $sys0 = ${CPIC::get('systems')}[0];
    $defport = $vrtscps_pkg->{defport};
    $index = 0;
    $str = $sys0->readfile('/etc/vxfenmode');
    if ($str =~ /^\s*vxfendg\s*=\s*(\S+)\s*\n*/mx) {
        $vxfendg = $1;
    }
    # substitute old cp for new cp
    $str =~ s/^\s*vxfendg\s*=.*\n*//mg;
    $str =~ s/^\s*cps\d+\s*=.*\n*//mg;
    $str =~ s/^\s*vxfen_honor_cp_order\s*=.*\n*//mg;
    for my $order (@{$order_aref}) {
        $line = $vxfenconfig->{cporder}{$order};
        if (($line !~ /\[/mx) && $vxfendg) {
            $str .= "vxfendg=$vxfendg\n";
        } else {
            $index ++;
            $line =~ s/\:$defport//g;
            $str .= "cps$index=$line\n";
        }
    }
    # make vxfen use the cp in the order in /etc/vxfenmode file
    $str .= "vxfen_honor_cp_order=1\n";
    $pkg->prepare_cps_test_files($str);
    # commit the change
    Msg::n();
    $ret = $pkg->vxfenswap();

    return $ret;
}

sub validate_cp_new_order {
    my ($pkg, $options_aref,$cp_count) = (@_);
    my @options = @{$options_aref};
    return 0 if ((@options != $cp_count) || (!EDRu::arr_isuniq(@options)));
    return 1;
}

sub get_cpagent_attribute_value {
    my ($pkg, $attr) = @_;
    my ($attr_value,$cpres,$sys);
    $sys = ${CPIC::get('systems')}[0];
    $cpres = $sys->cmd("_cmd_hares -list Type=CoordPoint -localclus 2>/dev/null| _cmd_awk '{print \$1}' | _cmd_uniq");
    if ($cpres) {
        $cpres = (split(/\n/,$cpres))[0];
        $attr_value = $sys->cmd("_cmd_hares -display $cpres -attribute $attr -localclus 2>/dev/null| _cmd_tail -1 | _cmd_awk '{print \$4}'");
        chomp($attr_value);
        return ($cpres,$attr_value);

    }
    return;
}

sub get_cp_count {
    my $pkg = shift;
    my ($cp_count,$disk_count,$server_count,$sys);
    $sys = ${CPIC::get('systems')}[0];
    $disk_count = $sys->cmd("_cmd_vxfenconfig -L 2>/dev/null |_cmd_grep Disk-Count | _cmd_awk '{print \$3}'");
    chomp($disk_count);
    $disk_count ||= 0;
    $server_count = $sys->cmd("_cmd_vxfenconfig -L 2>/dev/null |_cmd_grep Server-Count | _cmd_awk '{print \$3}'");
    chomp($server_count);
    $server_count ||= 0;
    $cp_count = $disk_count + $server_count;
    return $cp_count;
}

sub update_cpagent_faulttolerance {
    my ($pkg,$cpres,$cp_count) = @_;
    my ($answer,$cfg,$defopt,$max,$msg,$sys,$value,$vcs,$web);
    $sys = ${CPIC::get('systems')}[0];
    $cfg = Obj::cfg();
    $web = Obj::web();
    $vcs = $pkg->prod('VCS61');
    $defopt = 0;
    $max = 0;
    $max =  int(($cp_count-1)/2) if ($cp_count > 0);
    $msg = Msg::new("The attribute FaultTolerance of Coordination Point Agent needs to be updated due to the number of coordination points changed");
    $msg->print;
    if ($max < 1) {
        $msg = Msg::new("The attribute FaultTolerance will be set to 0 as the number of coordination points is $cp_count");
        $msg->print;
        $value = 0;
    } elsif (Cfg::opt('responsefile')) {
        $value = $cfg->{fencing_cpagent_faulttolerance};
        $value ||= 0;
        if (!$pkg->validate_cpagent_faulttolerance($max,$value)) {
            Msg::log("The value of fencing_cpagent_faulttolerance in responsefile is invalid, reset FaultTolerance attribute to 0");
            $value = 0;
        }
    } else {
        if (Obj::webui()) {
            $value = $web->web_script_form('cpagent_faulttolerance',$pkg,$defopt,$max);
        } else {
            while (1) {
                $msg = Msg::new("Enter the value of the FaultTolerance attribute (0 to $max):");
                $answer = $msg->ask($defopt);
                next if (!$pkg->validate_cpagent_faulttolerance($max,$answer));
                last;
            }
            $value = $answer;
            $cfg->{fencing_cpagent_faulttolerance} = $answer;
        }
    }
    $vcs->haconf_makerw();
    $sys->cmd("_cmd_hares -modify $cpres FaultTolerance $value");
    $vcs->haconf_dumpmakero();
    return;
}

sub validate_cpagent_faulttolerance {
    my ($pkg,$max,$answer) = @_;
    my $msg;
    if ($answer =~ /\D+/ || $answer < 0 || $answer > $max) {
        unless (Cfg::opt('responsefile')) {
            $msg = Msg::new("Invalid value. Input again");
            $msg->print;
        }
        return 0;
    }
    return 1;
}

sub get_new_coord_points {
    my ($pkg,$conf_href,$removed_cp_href,$added_cp_href) = @_;
    my (@cps,%ports,$dgname,$diskpolicy,$ncp,$ndisks,$newconf,$uuid);
    my ($msg,$ret);
    $newconf = {};

    $ncp = $conf_href->{ncp} + $added_cp_href->{ncp} - $removed_cp_href->{ncp};
    $ndisks = $conf_href->{ndisks} + $added_cp_href->{ndisks} - $removed_cp_href->{ndisks};
    @cps = @{EDRu::arrdel($conf_href->{cps},@{$removed_cp_href->{cps}})};
    push (@cps, @{$added_cp_href->{cps}});
    %ports = %{$conf_href->{ports}};
    for my $vip(keys %{$added_cp_href->{ports}}) {
        $ports{$vip} = $added_cp_href->{ports}->{$vip};
    }

    $newconf->{ncp} = $ncp;
    $newconf->{ndisks} = $ndisks;
    $newconf->{cps} = \@cps;
    $newconf->{ports} = \%ports;
    return ($ret,$newconf);
}

sub remove_cps {
    my ($pkg,$removed_cps_aref,$oldvxfenconf,$newcps_aref) = @_;
    my (@newcps,$cpspkg,$cpssys,$msg,$sys0);
    my $verbose = 0;
    $cpspkg = $pkg->pkg("VRTScps61");
    $sys0 = ${CPIC::get('systems')}[0];

    @newcps = @{$newcps_aref};
    for my $cpssys (@{$removed_cps_aref}) {
        # Check if the old cps will be reused
        next if (EDRu::inarr($cpssys,@newcps));
        if (!$pkg->cps_transport_sys($cpssys)) {
            $msg=Msg::new("Cannot communicate with system $cpssys->{sys}. Cannot complete Coordination Point server clean up on $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
            $msg->warning;
            next;
        }

        $msg = Msg::new("Cleaning up on Coordination Point server $cpssys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $cpspkg->cleanup_from_cps_sys($sys0,$cpssys,$oldvxfenconf,$verbose);
        Msg::right_done();
        $msg->display_right() if (Obj::webui());
    }
    return 0;
}

sub remove_disks {
    my ($pkg,$removed_cp_href,$adddisk) = @_ ;
    my ($dgs_href,$dgname,$msg,$nodg,$out,$ret);
    my $sys0 = ${CPIC::get('systems')}[0];

    return 0 if (!@{$removed_cp_href->{disks}});

    $dgname = $removed_cp_href->{vxfendg};
    $dgs_href = $pkg->get_dglist_sys($sys0);

    if (defined($dgs_href->{$dgname}{state}) &&
        ($dgs_href->{$dgname}{state} eq 'deported')) {
        $msg = Msg::new("Importing disk group $dgname on $sys0->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $sys0->cmd("_cmd_vxdg -t import $dgname");
        if (EDR::cmdexit()) {
            $msg->right_failed();
            return 1;
        } else {
            $msg->right_done();
            $msg->display_right() if (Obj::webui());
        }
    }

    for my $disk(@{$removed_cp_href->{disks}}) {
        $msg = Msg::new("Removing disk $disk from disk group $dgname");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $out = $sys0->cmd("_cmd_vxdisk list $disk | _cmd_grep disk:");
        my $tmpdisk = $disk;
        $tmpdisk = $1 if ($out =~ /disk:\s+name=(\S+)\s+/m);
        $out = $sys0->cmd("_cmd_vxdg -g $dgname -o coordinator rmdisk $tmpdisk");
        if (EDR::cmdexit()) {
            if ($out =~ /Cannot\s+remove\s+last\s+disk/m) {
                $sys0->cmd("_cmd_vxdg -o coordinator destroy $dgname");
                if (EDR::cmdexit()) {
                    $msg->right_failed;
                    return 1;
                } else {
                    Msg::right_done();
                    $msg->display_right() if (Obj::webui());
                }
                $nodg = 1;
            } else {
                $msg->right_failed;
                return 1;
            }
        } else {
            $msg->right_done;
        }
    }
    # if only remove disk, deport disk group after removal is finished
    if (!($adddisk || $nodg)) {
        $ret = $pkg->deport_diskgroup_on_sys($sys0,$dgname);
    }
    return $ret;
}

sub deport_diskgroup_on_sys {
    my ($pkg,$sys,$dgname) = @_;
    my ($msg,$ret,$web);
    $web = Obj::web();
    $msg = Msg::new("Deporting the disk group $dgname on $sys->{sys}");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());
    $sys->cmd("_cmd_vxdg deport $dgname");
    $ret = EDR::cmdexit();
    $sys->cmd("_cmd_vxdg -t import $dgname");
    $ret ||= EDR::cmdexit();
    $sys->cmd("_cmd_vxdg deport $dgname");
    $ret ||= EDR::cmdexit();
    if ($ret) {
        Msg::right_failed();
        Msg::prtc();
        if (Obj::webui()){
            $msg = Msg::new("Deporting the disk group $dgname on $sys->{sys} failed");
            $web->web_script_form('alert',$msg);
        }
        return 1;
    }
    Msg::right_done();
    $msg->display_left($msg) if (Obj::webui());
    Msg::prtc();
    return 0;
}

sub add_coord_points {
    my ($pkg,$added_cp_href,$removed_cp_href) = @_ ;
    my ($dgname,$dgs_href,$hasdg_flag,$msg,$ret);
    my $sys0 = ${CPIC::get('systems')}[0];
    my $web = Obj::web();
    if ($added_cp_href->{ndisks}) {
        $dgname = $added_cp_href->{vxfendg};
        $dgs_href = $pkg->get_dglist_sys($sys0);
        if (defined($dgs_href->{$dgname}{state}) &&
        ($dgs_href->{$dgname}{state} eq 'deported')) {
            $msg = Msg::new("Importing disk group $dgname on $sys0->{sys}");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());
            $sys0->cmd("_cmd_vxdg -t import $dgname");
            if (EDR::cmdexit()) {
                $msg->right_failed();
                Msg::prtc();
                return 1;
            } else {
                $msg->right_done();
                $msg->display_right() if (Obj::webui());
            }
        }
        $hasdg_flag = EDRu::inarr($dgname,@{$dgs_href->{diskgroups}});

        if (!$hasdg_flag) {
            return 1 if $pkg->create_vxfencoorddg($added_cp_href->{disks},$dgname);
        }
        if (!$pkg->validate_diskgroup($dgname)) {
            $msg =Msg::new("Disk group $dgname is not available on all the systems");
            $msg->print;
            $web->web_script_form('alert',$msg->{msg}) if (Obj::webui());
            Msg::prtc();
            return 1;
        }
        if ($hasdg_flag) {
            for my $disk(@{$added_cp_href->{disks}}) {
                $msg = Msg::new("Adding disk $disk to disk group $dgname");
                $msg->left;
                $msg->display_left($msg) if (Obj::webui());
                $sys0->cmd("_cmd_vxdg -g $dgname -o coordinator adddisk $disk");
                if (EDR::cmdexit()) {
                    $msg->right_failed;
                    Msg::prtc();
                    if (Obj::webui()) {
                        $msg = Msg::new("Adding disk $disk to disk group $dgname failed");
                        $web->web_script_form('alert',$msg->{msg});
                    }
                    return 1;
                } else {
                    $msg->right_done;
                    $msg->display_right() if (Obj::webui());
                }
            }
            $ret = $pkg->deport_diskgroup_on_sys($sys0,$dgname);
            return $ret if ($ret);
        }
    }

    if (@{$added_cp_href->{cps}}) {
        $ret = $pkg->update_clusterinfo_on_cps($added_cp_href);
        if ($ret) {
            my $ret2 = $pkg->rollback_disk_change($removed_cp_href,$added_cp_href);
            if ($ret2) {
                $msg = Msg::new("Failed to recover original fencing disk group. Refer to the installation guide or consult technical support to recover it manually");
                $msg->printn;
            }
            return $ret;
        }
        Msg::n();
    }

    return 0;
}

sub ask_coord_points_to_remove {
    my ($pkg,$conf_href) = @_;
    my (@sels,$backopt,$defopt,$disk,$menu,$menuopt,$webmenuopt,$help,$msg,$ret);
    my ($cfg,$removed_cp_href,$web);
    $backopt = 1;
    $removed_cp_href = {};
    $removed_cp_href->{servers} = [];
    $removed_cp_href->{disks} = [];
    $cfg = Obj::cfg();
    $web = Obj::web();

    $msg = Msg::new("Select the coordination points you would like to remove from currently configured coordination points:");
    $msg->bold;
    $menuopt = [];
    $webmenuopt = [];
    push (@{$menuopt}, @{$conf_href->{disks}},@{$conf_href->{servers}});
    push (@{$webmenuopt}, @{$conf_href->{disks}},@{$conf_href->{servers}});
    $msg = Msg::new("All");
    push (@{$menuopt},$msg->{msg});
    $msg = Msg::new("None");
    push (@{$menuopt},$msg->{msg});
    if ($pkg->{sybase_mode}) {
        $help = Msg::new("Choose the options to remove the coordination points. Choose the option of 'All' to remove all the coordination points. Choose the option of 'None' if you do not want to remove any coordination point.");
    } else {
        $help = Msg::new("Each Coordination Point server can have multiple vips and corresponding port. Choose the options to remove them from current coordination points. Choose the option of 'All' to remove all the coordination points. Choose the option of 'None' if you do not want to remove any coordination point.");
    }
    $defopt = scalar @{$menuopt};
    while (1) {
        $msg = Msg::new("Enter the options, separated by spaces:");
        if (Cfg::opt('responsefile')) {
            my (@rdisks,@rservers);
            @rdisks = @{$cfg->{disks_to_remove}} if (defined($cfg->{disks_to_remove}));
            @rservers = @{$cfg->{servers_to_remove}} if (defined($cfg->{servers_to_remove}));
            if ((!@rdisks) && (!@rservers)) {
                @{$menu} = ($defopt);
            } else {
                for my $item(@rdisks,@rservers) {
                    my $pos = EDRu::arrpos($item, @{$menuopt});
                    if ($pos == -1) {
                        $msg = Msg::new("Coordination point $item is not found in current coordination points");
                        $msg->print;
                        return 1;
                    }
                    push (@{$menu}, $pos+1);
                }
            }
        } else {
            if (Obj::webui()) {
                $menu = $web->web_script_form('migration_remove',$webmenuopt);
            } else {
                $menu = $msg->menu($menuopt,$defopt,$help,$backopt,1,1);
            }
        }
        return $menu if (EDR::getmsgkey($menu,'back'));
        @sels = @{$menu};
        if (Obj::webui() && (0 == @sels)){
            $msg = Msg::new("You have chosen not to remove any coordination points");
            $web->web_script_form('alert',$msg->{msg});
                last;
        } elsif (1 == @sels) {
            if ($sels[0] == $defopt) {
                $msg = Msg::new("You have chosen not to remove any coordination points");
                $msg->print;
                Msg::prtc();
                last;
            } elsif ($sels[0] == ($defopt-1)) {
                $msg = Msg::new("You have chosen to remove all coordination points");
                $msg->print;
                push (@{$removed_cp_href->{servers}}, @{$conf_href->{servers}});
                push (@{$removed_cp_href->{disks}}, @{$conf_href->{disks}});
                Msg::prtc();
                last;
            }
        } else {
            if (!$pkg->validate_coord_points_to_remove(\@sels,$defopt)) {
                $msg=Msg::new("Invalid input. Retry.");
                $msg->print;
                return 1 if (Cfg::opt('responsefile'));
                next;
            }
        }
        for my $index(@sels) {
            if (${$menuopt}[$index-1] =~ /\[.+\]/m) {
                push (@{$removed_cp_href->{servers}}, ${$menuopt}[$index-1]);
            } else {
                push (@{$removed_cp_href->{disks}},${$menuopt}[$index-1]);
            }
        }
        last;
    }

    # save for response file
    @{$cfg->{servers_to_remove}} = @{$removed_cp_href->{servers}};
    @{$cfg->{disks_to_remove}} = @{$removed_cp_href->{disks}};

    $removed_cp_href->{ncp} = @{$removed_cp_href->{disks}} + @{$removed_cp_href->{servers}};
    $removed_cp_href->{ndisks} = scalar @{$removed_cp_href->{disks}};
    ($removed_cp_href->{cps},$removed_cp_href->{ports}) = $pkg->parse_cps_ports($removed_cp_href->{servers});
    return ($ret,$removed_cp_href);
}

sub parse_cps_ports {
    my ($pkg,$server_aref) = @_;
    my (@cps,%ports,$cpsvip,$cps_sys1,$port,$sys1_flag);
    for my $s(@{$server_aref}) {
        $sys1_flag = 1;
        for my $item(split(/,/,$s)) {
            ($cpsvip, $port) = split(/:/, $item);
            if ($cpsvip =~ /\[(.+)\]/m) {
                $cpsvip = $1;
                $cpsvip = EDRu::despace($cpsvip);
                last if (!$cpsvip);
            } else {
                last;
            }
            $ports{$cpsvip} = $port;
            if ($sys1_flag) {
                $cps_sys1 = $pkg->create_cps_sys($cpsvip);
                push (@cps, $cps_sys1);
            }
            $sys1_flag = 0;
        }
    }
    return (\@cps,\%ports);
}

sub ask_coord_points_to_add {
    my ($pkg,$conf_href,$removed_ncp) = @_;
    my ($cps_aref,$defport,$disk_aref,$ncp,$ndisks,$oldncp,$port_href);
    my ($added_cp_href,$backopt,$cfg,$dgname,$help,$msg,$ret,$vrtscps_pkg,$web);
    $added_cp_href = {};
    $added_cp_href->{servers} = [];
    $added_cp_href->{cps} = [];
    $added_cp_href->{ports} = {};
    $disk_aref = [];
    $dgname = $conf_href->{vxfendg};
    $cfg = Obj::cfg();
    $web = Obj::web();

    $backopt = 1;
    $vrtscps_pkg = $pkg->pkg('VRTScps61');
    $defport = $vrtscps_pkg->{defport};

    if ($pkg->{sybase_mode}) {
        $msg = Msg::new("You will be asked to give details about the disks to be used as new coordination points. Note that the installer assumes these values to be the identical as viewed from all the client cluster nodes.");
    } else {
        $msg = Msg::new("You will be asked to give details about Coordination Point Servers/Disks to be used as new coordination points. Note that the installer assumes these values to be the identical as viewed from all the client cluster nodes.");
    }
    $msg->printn;
    $oldncp = $conf_href->{ncp} - $removed_ncp;
    if (Obj::webui()){
        my $num = $web->web_script_form('coordination_num',$pkg,$oldncp,1);
        return $num if ($num eq '__back__');
        $ncp = $num->{ncp};
        $ndisks = $num->{ndisks};
        if($oldncp + $ncp == 1) {
            $msg = Msg::new("\nWarning: Symantec recommends at least three or more odd number of coordination points to avoid a single point of failure. However, if fencing is configured to use a single CP server, it is strongly recommended to make the CP server highly available by configuring it on a SFHA cluster. It is important to note that during a failover of the CP server in the SFHA cluster, if there is a network partition on the client cluster at the same time, the whole client cluster will be brought down because arbitration facility will not be available for the duration of the failover.");
            $web->web_script_form('alert',$msg->{msg});
        }
    } else {
        ($ret,$ncp,$ndisks)=$pkg->ask_new_coord_points_num($oldncp);
        return $ret if ($ret);
    }
    if ($ncp - $ndisks > 0) {
        if (Obj::webui()){
            my($num,$result);
            while(1){
                $num = $web->web_script_form('cp_server_vipnum',$ncp - $ndisks,1);
                return $num if ($num eq '__back__');
                $result = $web->web_script_form('cp_server',$pkg,$ncp - $ndisks,$num,$conf_href->{cps});
                last unless($result eq 'back');
            }
            $cps_aref = $result->{fencing_cps};
            $port_href = $result->{fencing_ports};
        } else {
            ($ret,$cps_aref, $port_href) = $pkg->ask_cps($ncp,$ndisks,$defport,$conf_href->{cps});
            return $ret if ($ret);
        }
    }

    if ($ndisks) {
        ($ret,$disk_aref) = $pkg->get_migration_disks($ndisks,$dgname);
        return $ret if ($ret);
    }
    for my $cps(@{$cps_aref}) {
        my $str = '';
        for my $vip(@{$cps->{vips}}) {
            $str .= "[$vip]:$port_href->{$vip},";
        }
        $str =~ s/,$//;
        push (@{$added_cp_href->{servers}}, $str);
    }

    # save config info for resonsefile
    $cfg->{fencing_ncp} = $ncp;
    for my $server (@{$cps_aref}) {
        push (@{$cfg->{fencing_cps}}, $server->{sys});
        push (@{$cfg->{fencing_cps_vips}->{"$server->{sys}"}}, @{$server->{vips}});
        for my $vip(@{$server->{vips}}) {
            $cfg->{fencing_cps_ports}->{"$vip"} = $port_href->{$vip};
        }
    }

    $added_cp_href->{cps} = $cps_aref;
    $added_cp_href->{ports} = $port_href;
    $added_cp_href->{disks} = $disk_aref;
    $added_cp_href->{ncp} = @{$cps_aref} + @{$disk_aref};
    $added_cp_href->{ndisks} = scalar @{$disk_aref};
    return ($ret,$added_cp_href);
}

sub display_new_cp_info {
    my ($pkg,$conf_href,$removed_cp_href,$added_cp_href) = @_;
    my ($ayn,$help,$msg,$smsg,$tmpmsg,$webmsg);
    my ($newservers,$newdisks);

    # Show all the info for user confirmation
    Msg::title();
    $msg = Msg::new("Coordination points verification");
    $webmsg = $msg->{msg};
    $msg->bold;
    $msg = Msg::new("\n\tCurrent coordination points:");
    $webmsg .= $msg->{msg}."\n";
    $msg->print;
    $smsg = Msg::new("\tOld set of coordination points:\n");
    my $index = 0;
    for my $cp (@{$conf_href->{servers}},@{$conf_href->{disks}}) {
        $index++;
        $tmpmsg = "\t\t${index}. $cp\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
        $smsg->{msg} .= $tmpmsg;
    }
    $msg = Msg::new("\tCoordination points to be removed:");
    $webmsg .= $msg->{msg}."\n";
    $msg->print;
    my $count = 0;
    for my $server(@{$removed_cp_href->{servers}}) {
        $count++;
        $tmpmsg = "\t\t${count}. $server\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
    }
    for my $disk(@{$removed_cp_href->{disks}}) {
        $count++;
        $tmpmsg = "\t\t${count}. $disk\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
    }
    if ($count == 0) {
        $msg = Msg::new("None");
        $msg->{msg} = "\t\t$msg->{msg}\n";
        $webmsg .= $msg->{msg};
        $msg->print;
    }

    $msg = Msg::new("\tCoordination points to be added:");
    $webmsg .= $msg->{msg}."\n";
    $msg->print;
    $count = 0;
    for my $server(@{$added_cp_href->{servers}}) {
        $count++;
        $tmpmsg = "\t\t${count}. $server\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
    }
    for my $disk(@{$added_cp_href->{disks}}) {
        $count++;
        $tmpmsg = "\t\t${count}. $disk\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
    }
    if ($count == 0) {
        $msg = Msg::new("None");
        $msg->{msg} = "\t\t$msg->{msg}\n";
        $webmsg .= $msg->{msg};
        $msg->print;
    }

    $msg = Msg::new("\tNew set of Coordination points:");
    $webmsg .= $msg->{msg}."\n";
    $smsg->{msg} .= $msg->{msg}."\n";
    $msg->print;
    $count = 0;
    $newservers = EDRu::arrdel($conf_href->{servers}, @{$removed_cp_href->{servers}});
    $newdisks = EDRu::arrdel($conf_href->{disks}, @{$removed_cp_href->{disks}});
    push (@{$newservers}, @{$added_cp_href->{servers}});
    push (@{$newdisks}, @{$added_cp_href->{disks}});
    for my $server(@{$newservers}) {
        $count++;
        $tmpmsg = "\t\t${count}. $server\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
        $smsg->{msg} .= $tmpmsg;
    }
    for my $disk(@{$newdisks}) {
        $count++;
        $tmpmsg = "\t\t${count}. $disk\n";
        Msg::print($tmpmsg);
        $webmsg .= $tmpmsg;
        $smsg->{msg} .= $tmpmsg;
    }
    $smsg->add_summary();

    unless (Cfg::opt('responsefile')) {
        $msg = Msg::new("\nIs this information correct?");
        $ayn = $msg->ayny($help,'',$webmsg);
        Msg::n();
        return -1 if ($ayn eq 'N');
    }
    return 0;
}


sub get_current_coord_points {
    my $pkg = shift;
    my ($conf,$cp,$msg,$out,$ret,$sys0);
    my (@cps,%ports,$s,$vcs,$vxfenconfig);
    $sys0 = ${CPIC::get('systems')}[0];
    $conf->{disks} = [];
    $conf->{servers} = [];
    $conf->{ncp} = 0;
    $conf->{ndisks} = 0;
    # get vxfen config info from vxfenmode file
    $vcs = $pkg->prod("VCS61");
    $vxfenconfig = $vcs->get_vxfen_config_sys($sys0);

    $conf->{vxfendg} = $vxfenconfig->{vxfendg};
    if ($conf->{vxfendg}) {
        my $dglist = $pkg->get_dglist_sys($sys0);
        my $group = $conf->{vxfendg};
        if (defined($dglist->{$group}{disks})) {
            push (@{$conf->{disks}}, @{$dglist->{$group}{disks}});
        }
        $conf->{ndisks} += scalar @{$conf->{disks}};
        $conf->{ncp} += scalar @{$conf->{disks}};
        while (my ($order,$cp) = each (%{$vxfenconfig->{cporder}})) {
            $conf->{cporder}{$order} = $cp if ($cp eq $conf->{vxfendg});
        }
    }
    for my $sysi(@{$vxfenconfig->{cps}}) {
        $conf->{ncp} ++;
        $s = $pkg->create_cps_sys($sysi);
        $s->{vips} = [];
        if (defined($vxfenconfig->{vips}{$sysi})) {
            push (@{$s->{vips}}, @{$vxfenconfig->{vips}{$sysi}});
            $cp = '';
            for my $vip(@{$vxfenconfig->{vips}{$sysi}}) {
                my $port = $vxfenconfig->{cpport}{$vip};
                $ports{$vip} = $port;
                $cp .= "[$vip]:$port,";
            }
            $cp =~ s/,$//;
            push (@{$conf->{servers}}, $cp);
        }
        push (@cps,$s);
        while (my ($order,$cp) = each (%{$vxfenconfig->{cporder}})) {
            $conf->{cporder}{$order} = $cp if ($cp =~ /\b$sysi\b/);
        }
    }
    $conf->{cps} = \@cps;
    $conf->{ports} = \%ports;
    $conf->{scsi3_disk_policy} = $vxfenconfig->{scsi3_disk_policy};
    $conf->{vxfen_honor_cp_order} = $vxfenconfig->{vxfen_honor_cp_order};
    return ($ret,$conf);
}

sub validate_coord_points_to_remove {
    my ($pkg,$options_aref,$defopt) = @_;
    my (@options);
    @options = @{$options_aref};
    if ((@options != 1) && (EDRu::inarr($defopt,@options) || EDRu::inarr($defopt-1,@options))) {
        return 0;
    }
    return 0 if (!EDRu::arr_isuniq(@options));
    return 1;
}

sub validate_coord_points_to_add {
    my ($pkg,$current_cps_aref,$added_cps_aref) = @_;
    my (%existflag,$msg,$web);
    $web = Obj::web();
    for my $cps(@{$current_cps_aref},@{$added_cps_aref}) {
        for my $vip(@{$cps->{vips}}) {
            if ($existflag{$vip}) {
                $msg = Msg::new("The VIP or FQHN of the coordination point $cps->{sys} cannot the same as that of the current coordination point");
                $msg->print;
                $web->web_script_form("alert",$msg) if (Obj::webui());
                return 0;
            }
            $existflag{$vip} = 1;
        }
    }
    return 1;
}

sub validate_new_cps_vip {
    my ($pkg,$current_cps_aref,$newvip) = @_;
    my $msg;
    for my $cps(@{$current_cps_aref}) {
        if (EDRu::inarr($newvip, @{$cps->{vips}})) {
            $msg = Msg::new("The VIP or FQHN $newvip cannot the same as that of the current coordination point");
            $msg->print;
            return 0;
        }
    }
    return 1;
}

sub prepare_cps_test_files {
    my ($pkg,$str) = @_;
    my ($msg,$web);
    $web = Obj::web();

    $msg = Msg::new("Preparing vxfenmode.test file on all systems");
    $msg->bold;
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    for my $sys(@{CPIC::get('systems')}) {
        $msg = Msg::new("Preparing /etc/vxfenmode.test on system $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $sys->writefile($str, '/etc/vxfenmode.test');
        $msg->right_done;
        $msg->display_right() if (Obj::webui());
    }
    return;
}

sub prepare_disk_test_files {
    my ($pkg,$diskpolicy) = @_;
    my ($msg,$web);
    $web = Obj::web();

    $msg = Msg::new("Preparing vxfenmode.test file on all systems");
    $msg->bold;
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    for my $sys(@{CPIC::get('systems')}) {
        $msg = Msg::new("Preparing /etc/vxfenmode.test on system $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        if ($pkg->{sybase_mode}) {
            $sys->cmd("_cmd_cp /etc/vxfenmode /etc/vxfenmode.test");
        } else {
            $sys->cmd("_cmd_cp /etc/vxfen.d/vxfenmode_scsi3_$diskpolicy /etc/vxfenmode.test");
        }
        $msg->right_done;
        $msg->display_right() if (Obj::webui());
    }
    return;
}

sub vxfenswap {
    my ($pkg,$dgname) = @_;
    my ($logfile,$msg,$option,$out,$ret,$sys0,$vxfenswap);
    $sys0 = ${CPIC::get('systems')}[0];
    $vxfenswap = '/opt/VRTSvcs/vxfen/bin/vxfenswap';
    $option = $sys0->{rsh_option};

    $msg = Msg::new("Running vxfenswap...");
    $msg->print;
    if ($dgname) {
        $out = $sys0->cmd("_cmd_yes y| $vxfenswap -g $dgname -a autoconfirm $option");
    } else {
        $out = $sys0->cmd("_cmd_yes y| $vxfenswap -a autoconfirm $option");
    }
    $ret = EDR::cmdexit();

    if ($out =~ /\/var\/VRTSvcs\/log\/vxfen\/vxfenswap\.log\.(\d+)/m) {
        $logfile = "vxfenswap.log.$1";
    } else {
        $logfile = 'vxfenswap.log';
    }
    $msg = Msg::new("Refer to $logfile under /var/VRTSvcs/log/vxfen on $sys0->{sys} for details");
    $msg->print;

    if ($ret) {
        $msg = Msg::new("The vxfenswap operation did not complete successfully");
        $msg->bold;
        Msg::prtc();
        Msg::n();
    } else {
        $msg = Msg::new("Successfully completed the vxfenswap operation");
        $msg->bold;
        $msg->add_summary();
        Msg::n();
    }
    return $ret;
}

sub rollback_disk_change {
    my ($pkg,$removed_cp_href,$added_cp_href) = @_;
    my ($dgname,$dglist,$diskstr,$msg,$out,$ret,$sys0);
    $sys0 = ${CPIC::get('systems')}[0];

    return 0 if (!($removed_cp_href->{ndisks} || $added_cp_href->{ndisks}));
    $msg = Msg::new("Rolling back the coordination disks change");
    $msg->left;
    $dglist=$pkg->get_dglist_sys($sys0);
    if ($removed_cp_href->{ndisks}) {
        # Add the removed disks back
        $dgname = $removed_cp_href->{vxfendg};
        $diskstr = join(' ', @{$removed_cp_href->{disks}});
        if (!defined($dglist->{$dgname}{state})) {
            $sys0->cmd("_cmd_vxdg -o coordinator=on init $dgname $diskstr");
            $ret = EDR::cmdexit();
        } elsif ($dglist->{$dgname}{state} eq 'deported') {
            $sys0->cmd("_cmd_vxdg -t import $dgname");
            $sys0->cmd("_cmd_vxdg -g $dgname -o coordinator adddisk $diskstr");
            $ret = EDR::cmdexit();
        } else {
            $sys0->cmd("_cmd_vxdg -g $dgname -o coordinator adddisk $diskstr");
            $ret = EDR::cmdexit();
        }
    }
    if ($ret) {
        $msg->right_failed;
        Msg::prtc();
        return 1;
    }
    if ($added_cp_href->{ndisks}) {
        $dgname = $added_cp_href->{vxfendg};
        $sys0->cmd("_cmd_vxdg -t import $dgname");
        for my $disk(@{$added_cp_href->{disks}}) {
            $out = $sys0->cmd("_cmd_vxdisk list $disk | _cmd_grep disk:");
            my $tmpdisk = $disk;
            $tmpdisk = $1 if ($out =~ /disk:\s+name=(\S+)\s+/m);
            $out = $sys0->cmd("_cmd_vxdg -g $dgname -o coordinator rmdisk $tmpdisk");
            if (EDR::cmdexit()) {
                if ($out =~ /Cannot\s+remove\s+last\s+disk/m) {
                    $sys0->cmd("_cmd_vxdg -o coordinator destroy $dgname");
                    $ret ||= 1 if (EDR::cmdexit());
                } else {
                    $ret ||= 1;
                }
            }
        }
    }
    if ($ret) {
        $msg->right_failed;
        Msg::prtc();
        return 1;
    } else {
        $msg->right_done;
    }
    return 0;
}

sub rollback_server_change {
    my ($pkg,$added_cp_href) = @_;
    my (@cps,@cpsusers,@outs,%ports,$cpsadm,$cpspkg,$out,$ret,$vcs);
    my ($clusname,$msg,$uuid,$cpsuser);

    @cps = @{$added_cp_href->{cps}};
    return 0 if (!@cps);

    $cpspkg = $pkg->pkg('VRTScps61');
    $cpsadm = $cpspkg->{cpsadm};
    $clusname = $added_cp_href->{clustername};
    $uuid = $added_cp_href->{uuid};
    %ports = %{$added_cp_href->{ports}};
    $vcs = $pkg->prod('VCS61');

    $msg = Msg::new("Rolling back the coordination point servers change");
    $msg->left;
    for my $cpserver(@cps) {
        # get the users
        $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} -c $clusname 2>/dev/null | _cmd_grep '$uuid'");
        for my $cpsuser (split (/\n/, $out)) {
            push (@cpsusers, (split(/\//m, $cpsuser))[0]);
        }
        # remove the cluster
        $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a rm_clus -p $ports{$cpserver->{sys}} -c $clusname -u $uuid 2>/dev/null");
        $ret ||= EDR::cmdexit();
        # remove users
        for my $cpsuser (@cpsusers) {
            $out = $cpserver->cmd("$cpsadm -s $cpserver->{sys} -a list_users -p $ports{$cpserver->{sys}} 2>/dev/null | _cmd_grep '$cpsuser/'");
            @outs = split (/\n/, $out);
                for my $entry (@outs) {
                # The cluster name
                $out = (split (/\s+/m, $entry))[1];
                $out = EDRu::despace($out);
                next if ($out ne '-');
                $cpserver->cmd("$cpsadm -s $cpserver->{sys} -p $ports{$cpserver->{sys}} -a rm_user -e $cpsuser -g vx 2>/dev/null");
                $ret ||= EDR::cmdexit();
            }
        }
    }
    if ($ret) {
        Msg::right_failed();
        Msg::prtc();
    } else {
        Msg::right_done();
    }
    return $ret;
}

sub verify_responsefile_for_fencing {
    my (@disks,$cfg,$msg,$pkg);
    $pkg = shift;
    $cfg = Obj::cfg();
    unless ($cfg->{fencing_option}) {
        $msg = Msg::new("fencing_option must be set in responsefile");
        $msg->die;
    }
    if ($cfg->{fencing_option} == 1) {
        # TODO: veriry responsefile for cp client based fencing
    } elsif ($cfg->{fencing_option} == 2) {
        $pkg->verify_responsefile_for_dskfenc();
    } elsif (!EDRu::inarr($cfg->{fencing_option},(3,4,5,6))) {
        $msg = Msg::new("fencing_option in response file is not a valid fencing configuration option");
        $msg->die;
    }
    if ($cfg->{fencing_cpagent_monitor_freq}) {
        if (!$pkg->validate_level2freq($cfg->{fencing_cpagent_monitor_freq})) {
            $msg = Msg::new("fencing_cpagent_monitor_freq in response file is not a valid value");
            $msg->die;
        }
    }
    if ($cfg->{fencing_cpagent_faulttolerance}) {
        if (($cfg->{fencing_cpagent_faulttolerance} =~ /\D+/) || ($cfg->{fencing_cpagent_faulttolerance} < 0)) {
            $msg = Msg::new("fencing_cpagent_faulttolerance in response file is not a valid value");
            $msg->die;
        }
    }
    return;
}

sub responsefile_comments_for_fencing {
    my ($cfg,$cmt,$edr);
    $cfg=Obj::cfg();
    $edr=Obj::edr();
    if (Cfg::opt('fencing')) {
        $cmt=Msg::new("This variable performs fencing configuration");
        $edr->{rfc}{opt__fencing}=[$cmt->{msg},1,0,0];
    }
    if ($cfg->{fencing_option}) {
        $cmt=Msg::new("This variable defines the I/O fencing configuration mode. (1: cp client-based fencing; 2: disk-based fencing or Sybase mode fencing for SFSYBASECE; 3: disabled mode; 4: online fencing migration; 5: Refresh keys/registrations on the existing coordination points; 6: Change the order of existing coordination points)");
        $edr->{rfc}{fencing_option}=[$cmt->{msg},1,0,0];
    }
    $cmt=Msg::new("This variable defines if the coordination point agent is configured");
    $edr->{rfc}{fencing_config_cpagent}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the coordination point agent");
    $edr->{rfc}{fencing_cpagentgrp}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the LevelTwoMonitorFreq attribute of the coordination point agent");
    $edr->{rfc}{fencing_cpagent_monitor_freq}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the FaultTolerance attribute of the coordination point agent");
    $edr->{rfc}{fencing_cpagent_faulttolerance}=[$cmt->{msg},0,0,0];
    if ($cfg->{fencing_option} == 2) {
        $cmt=Msg::new("This variable defines the disks which are used to create a new disk group");
        $edr->{rfc}{fencing_newdg_disks}=[$cmt->{msg},0,1,0];
        $cmt=Msg::new("This variable defines fencing disk group");
        $edr->{rfc}{fencing_dgname}=[$cmt->{msg},1,0,0];
        $cmt=Msg::new("This variable defines fencing disk policy");
        $edr->{rfc}{fencing_scsi3_disk_policy}=[$cmt->{msg},1,0,0];
    } else {
        $cmt=Msg::new("This variable defines fencing disk group");
        $edr->{rfc}{fencing_dgname}=[$cmt->{msg},0,0,0];
        $cmt=Msg::new("This variable defines fencing disk policy");
        $edr->{rfc}{fencing_scsi3_disk_policy}=[$cmt->{msg},0,0,0];
        if ($cfg->{fencing_option} == 3) {
            $cmt=Msg::new("This variable defines the total number of coordination points");
            $edr->{rfc}{fencing_ncp}=[$cmt->{msg},1,0,0];
            $cmt=Msg::new("This variable defines the total number of coordination disks");
            $edr->{rfc}{fencing_ndisks}=[$cmt->{msg},1,0,0];
            $cmt=Msg::new("This variable defines the coordination disks");
            $edr->{rfc}{fencing_disks}=[$cmt->{msg},0,1,0];
            $cmt=Msg::new("This variable defines the Coordination Point Servers");
            $edr->{rfc}{fencing_cps}=[$cmt->{msg},0,1,0];
            $cmt=Msg::new("This variable defines the virtual IP addresses or fully qualified host names of the Coordination Point Servers");
            $edr->{rfc}{fencing_cps_vips}=[$cmt->{msg},0,1,1];
            $cmt=Msg::new("This variable defines the port that the Coordination Point Server listens on");
            $edr->{rfc}{fencing_cps_ports}=[$cmt->{msg},0,0,1];
        } elsif ($cfg->{fencing_option} == 4) {
            $cmt=Msg::new("This variable defines the total number of new coordination points");
            $edr->{rfc}{fencing_ncp}=[$cmt->{msg},1,0,0];
            $cmt=Msg::new("This variable defines the total number of new coordination disks");
            $edr->{rfc}{fencing_ndisks}=[$cmt->{msg},1,0,0];
            $cmt=Msg::new("This variable defines the new coordination disks");
            $edr->{rfc}{fencing_disks}=[$cmt->{msg},0,1,0];
            $cmt=Msg::new("This variable defines the new Coordination Point Servers");
            $edr->{rfc}{fencing_cps}=[$cmt->{msg},0,1,0];
            $cmt=Msg::new("This variable defines the virtual IP addresses or fully qualified host names of the new Coordination Point Servers");
            $edr->{rfc}{fencing_cps_vips}=[$cmt->{msg},0,1,1];
            $cmt=Msg::new("This variable defines the port that the new Coordination Point Server listens on");
            $edr->{rfc}{fencing_cps_ports}=[$cmt->{msg},0,0,1];
            $cmt=Msg::new("This variable defines the Coordination Point Servers to be removed");
            $edr->{rfc}{servers_to_remove}=[$cmt->{msg},0,1,0];
            $cmt=Msg::new("This variable defines the coordination disks to be removed");
            $edr->{rfc}{disks_to_remove}=[$cmt->{msg},0,1,0];
        } elsif ($cfg->{fencing_option} == 6) {
            $cmt=Msg::new("This variable defines the new order of the current coordination points");
            $edr->{rfc}{fencing_cp_new_order}=[$cmt->{msg},1,1,0];
        }
    }
    return;
}

sub verify_responsefile_for_dskfenc {
    my (@disks,$cfg,$msg,$pkg);
    $pkg = shift;
    $cfg = Obj::cfg();
    unless ($cfg->{fencing_dgname} && $cfg->{fencing_scsi3_disk_policy}) {
        $msg = Msg::new("fencing_dgname, fencing_scsi3_disk_policy must be set in responsefile");
        $msg->die;
    }
    if ($cfg->{fencing_option} != 2) {
        $msg = Msg::new("fencing_option in response file is not a valid fencing configuration option");
        $msg->die;
    }
    if (!$pkg->validate_dgname($cfg->{fencing_dgname})) {
        $msg = Msg::new("fencing_dgname in response file is not a valid disk group name");
        $msg->die;
    }
    if ($cfg->{fencing_scsi3_disk_policy} !~ /^(raw|dmp)$/mx) {
        $msg = Msg::new("fencing_scsi3_disk_policy in response file is not a valid disk policy");
        $msg->die;
    }
    if (defined($cfg->{fencing_newdg_disks})) {
        $msg = Msg::new("fencing_newdg_disks in response file is not a valid reference of disks\' names for fencing");
        $msg->die if (ref($cfg->{fencing_newdg_disks}) ne 'ARRAY');
        @disks = @{$cfg->{fencing_newdg_disks}};
        if((@disks < 3) || (scalar(@disks)%2 == 0) || !EDRu::arr_isuniq(@disks)) {
            $msg->die;
        }
    }
    $pkg->verify_responsefile_for_dskfenc_precheck() if Cfg::opt('fencing');
    return;
}

sub verify_responsefile_for_dskfenc_precheck {
    my (@disks,$cfg,$dgname,$msg,$pkg);
    $pkg = shift;
    $cfg = Obj::cfg();
    $dgname=$cfg->{fencing_dgname};
    if (!defined($cfg->{fencing_newdg_disks})) {
        if (!$pkg->validate_dgnum($dgname)) {
            $msg = Msg::new("The disk group $dgname in response file is not valid on all the nodes");
            $msg->die;
        }
    } else {
        if (!$pkg->validate_diskgroup($dgname,1)) {
            $msg = Msg::new("The disk group $dgname in response file is already existed in the cluster");
            $msg->die;
        }
    }
    return;
}

sub stop_vcsfen {
    my (@master_nodes,$sys,$sys_master,$vxdctl,$vxdctl_mode,$syslist,$res_vcs);
    my $pkg=shift;
    $syslist=CPIC::get('systems');
    # Stop Slave nodes before Master node.
    for my $sys (@$syslist) {
        $vxdctl_mode = '';
        $vxdctl = $sys->cmd_bin('vxdctl');
        $vxdctl_mode = $sys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'mode:'")
            if ($sys->exists($vxdctl));
        if ($vxdctl_mode=~/MASTER/m) {
            push(@master_nodes,$sys);
        } else {
            $res_vcs = $pkg->stop_vcsfen_sys($sys);
            return 'vcs_stop_failed' if ('vcs_stop_failed' eq $res_vcs);
        }
    }
    for my $sys_master (@master_nodes) {
        $res_vcs = $pkg->stop_vcsfen_sys($sys_master);
        return 'vcs_stop_failed' if ('vcs_stop_failed' eq $res_vcs);
    }
    return;
}

sub stop_vcsfen_sys {
    my ($pkg,$sys) = @_;
    my ($msg,$port_h,$cpic,$proc,$had,$sysname,$vcs);
    $cpic=Obj::cpic();
    $had=$pkg->proc('had61');
    $proc=$pkg->proc('vxfen61');
    $vcs = $pkg->prod('VCS61');
    if ($had->check_sys($sys,'stop')) {
        $msg=Msg::new("Stopping VCS on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $sysname = $sys->{vcs_sysname};
        $sys->cmd("/opt/VRTSvcs/bin/hastop -sys $sysname");
        $sys->cmd('/opt/VRTS/bin/hasys -wait localsys SysState EXITED -time 600');
        $port_h = $sys->cmd("_cmd_gabconfig -a | _cmd_grep 'Port h'");
        if ($port_h) {
            CPIC::proc_stop_failed_sys($sys, $had);
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                $msg->addError($errmsg);
            }
            return 'vcs_stop_failed';
        } else {
            CPIC::proc_stop_passed_sys($sys, $had);
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        }
    }
    if ($proc->check_sys($sys,'stop')) {
        $msg=Msg::new("Stopping Fencing on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        if ($cpic->proc_stop_sys($sys, $proc)) {
            CPIC::proc_stop_passed_sys($sys, $proc);
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        } else {
            CPIC::proc_stop_failed_sys($sys, $proc);
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                $msg->addError($errmsg);
            }
        }
    }
    return;
}

sub config_vxfen {
    my ($ayn,$cpic,$done,$edr,$msg,$option,$pkg,$port_h,$ret,$sys,$had,$vm);
    my ($gab,$gab_running,$sysname,$vcs,$vcs_running);
    $pkg = shift;
    $cpic = Obj::cpic();
    $edr = Obj::edr();
    $done = 1;
    $vcs_running = 1;
    $gab_running = 1;
    my $web = Obj::web();
    $cpic->{systems} = $edr->init_sys_objects()
        unless (($cpic->{systems}) && ($cpic->nsystems));
    $sys = ${$cpic->{systems}}[0];
    $vcs = $pkg->prod('VCS61');
    $vm = $pkg->prod('VM61');
    $had = $pkg->proc('had61');
    $gab = $pkg->proc('gab61');

    for my $sysi (@{$cpic->{systems}}) {
        $sysname = $vcs->get_vcs_sysname_sys($sysi);
        $sysi->{vcs_sysname} = $sysname;
    }
    $vcs->{fencing_config_pending} = 0;

    # if gab/VCS is not started successfully return error
    $vcs_running = 0 if (!($had->check_sys($sys,'start')));
    $gab_running = 0 if (!($gab->check_sys($sys,'start')));
    if ((!$gab_running) || (!$vcs_running)) {
        if (!$gab_running) {
            $msg = Msg::new("Fencing could not be configured as gab is not configured or started successfully");
        } else {
            $msg = Msg::new("Fencing could not be configured as VCS is not configured or started successfully");
        }
        Msg::n();
        $msg->error;
        Msg::n();
        $web->{complete_failed}=1;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        return '';
    }
    # if VRTSvxfen is not installed return error
    if (!$pkg->check_pkg_installed('VRTSvxfen61')) {
        $msg = Msg::new("Fencing could not be configured as VRTSvxfen is not installed");
        $msg->printn;
        $web->{complete_failed}=1;
        $web->web_script_form('alert',$msg->{msg})if (Obj::webui());
        return '';
    }
    # if vxfen is already started in enabled mode
    if ($pkg->vxfen_enabled_sys($sys)) {
        Msg::n();
        $msg = Msg::new("Fencing is already started in enabled mode, do you want to reconfigure it?");
        $ayn = $msg->ayny();
        return '' if ($ayn eq 'N');
    }

    ($ret,$option) = $pkg->configure_fencing($sys);
    # return from fencing configuration directly
    return '' if ($ret == -2);

    for my $sys (@{$cpic->{systems}}) {
        $msg = Msg::new("Starting VCS on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        if ($cpic->proc_start_sys($sys,$had)) {
            CPIC::proc_start_passed_sys($sys, $had);
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        } else {
            CPIC::proc_start_failed_sys($sys, $had);
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                $msg->addError($errmsg);
            }
            $done = 0;
        }
    }
    Msg::n();
    # configure cp agent after vxfen is configured and vcs restarts
    if (($option =~ /^(cps|disk|sybase)$/m) && $done) {
        $pkg->ask_configure_cpagent(1);
    }
    # update summary file
    $cpic->update_summary_stop();
    $cpic->update_summary_start();

    $msg = Msg::new("I/O Fencing configuration");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());
    if ($pkg->{status}>0){
        Msg::right_done();
        $msg->display_right() if (Obj::webui());
        Msg::n();
        $msg = Msg::new("I/O Fencing configuration completed successfully");
        $msg->bold;
    # failed to configure fencing in enabled mode, configured fencing in disabled mode
    } elsif (-4 == $pkg->{status}) {
        Msg::right_failed();
        Msg::n();
        $msg = Msg::new("I/O Fencing configuration did not complete successfully, fell back to disabled mode.");
        $msg->bold;
    } else {
        Msg::right_failed();
        Msg::n();
        $msg = Msg::new("I/O Fencing configuration did not complete successfully");
        $msg->bold;
    }
    Msg::n();
    return '';
}

sub vxfen_enabled_sys {
    my ($pkg,$sys) = @_;
    my $vxfen = $pkg->proc('vxfen61');
    my %vxfen_config = $vxfen->parse_vxfenadm_output($sys);
    if (defined($vxfen_config{fencing_mode}) && ($vxfen_config{fencing_mode} !~ /Disabled/m)) {
         return 1;
    }
    return 0;
}

sub vxfen_mode_sys {
    my ($pkg,$sys) = @_;
    my (%vxfen_config,$out,$vxfen);
    $vxfen = $pkg->proc('vxfen61');
    %vxfen_config = $vxfen->parse_vxfenadm_output($sys);
    if (defined($vxfen_config{fencing_mode})) {
        if ($vxfen_config{fencing_mode} =~ /SCSI3/im) {
            return 'disk';
        } elsif (($vxfen_config{fencing_mode} =~ /Customized/im) &&
            defined($vxfen_config{mechanism}) && ($vxfen_config{mechanism} =~ /cps/mi)) {
            $out = $sys->cmd("_cmd_grep '^data_disk_fencing' $pkg->{vxenv_file} 2> /dev/null");
            if (!EDR::cmdexit() && $out) {
                return 'nonscsi3';
            }
            return 'cps';
        } elsif ($vxfen_config{fencing_mode} =~ /Disabled/im) {
            return 'disabled';
        } elsif ($vxfen_config{fencing_mode} =~ /sybase/im) {
            return 'sybase';
        }
    } else {
        return 'error';
    }
    return '';
}

sub vxfen_disk_policy_sys {
    my ($pkg,$sys) = @_;
    my ($vcs,$vxfen_conf);
    $vcs = $pkg->prod('VCS61');
    $vxfen_conf = $vcs->get_vxfen_config_sys($sys);
    return $vxfen_conf->{scsi3_disk_policy};
}

sub ask_unexport_disk {
    my ($pkg) = @_;
    my ($msg, $web, $ayn);

    my $vm = $pkg->prod('VM61');
    return 'N' unless ($vm->is_fss_enabled());
    $web = Obj::web();
    $msg = Msg::new("Installer could not detect any disk that satisfies the requirements for coordinator disks. It might happen that if 'vxdisk -o alldisks export' was executed before invoking the installer, in which case no disk would be listed because exported devices cannot be used as coordinator disks. If there are disks that have direct connectivity with all the cluster nodes and you do not want to mark them as exported devices, then unexport them with the command 'vxdisk unexport <disk list>' in a separate console, and refresh the list of disks in the installer console to continue.");
    $msg->print;
    if (Obj::webui()) {
        $msg->{msg}=~s/\</&#60/g;
        $msg->{msg}=~s/\>/&#62/g;
        $web->web_script_form('alert',$msg->{msg});
    }

    $msg = Msg::new("Do you want to unexport any disk(s)? It should be done in a separate console.");
    $ayn = $msg->ayny;
    if ($ayn eq 'Y') {
        $msg = Msg::new("Continue after the unexport operation.");
        $msg->print;
        if (Obj::webui()) {
            $web->web_script_form('alert',$msg->{msg});
        } else {
            Msg::prtc();
        }
    }
    return $ayn;
}

#################################################################
#>>>>>>>>       Implementation Ends                     <<<<<<<<#
#################################################################

package Pkg::VRTSvxfen61::AIX;
@Pkg::VRTSvxfen61::AIX::ISA = qw(Pkg::VRTSvxfen61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSvxfen.rte) ];
    $pkg->{llttab_sendhbcap}=3200;
    return;
}

package Pkg::VRTSvxfen61::HPUX;
@Pkg::VRTSvxfen61::HPUX::ISA = qw(Pkg::VRTSvxfen61::Common);

package Pkg::VRTSvxfen61::Linux;
@Pkg::VRTSvxfen61::Linux::ISA = qw(Pkg::VRTSvxfen61::Common);

package Pkg::VRTSvxfen61::RHEL5x8664;
@Pkg::VRTSvxfen61::RHEL5x8664::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL5.5'}={
        "/bin/ksh"  =>  "ksh-20100202-1.el5.x86_64",
        "libc.so.6"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-49.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-49.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-48.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-48.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-49.i686",
        "libnsl.so.1"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-49.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-49.i686",
        "librt.so.1"  =>  "glibc-2.5-49.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-48.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-48.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-48.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-49.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.6'}={
        "/bin/ksh"  =>  "ksh-20100202-1.el5_5.1.x86_64",
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "librt.so.1"  =>  "glibc-2.5-58.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "perl(Exporter)"  =>  "perl-5.8.8-32.el5_5.2.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.7'}={
        "/bin/ksh"  =>  "ksh-20100202-1.el5_6.6.x86_64",
        "libc.so.6"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-65.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-65.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-51.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-51.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-65.i686",
        "libnsl.so.1"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-65.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-65.i686",
        "librt.so.1"  =>  "glibc-2.5-65.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-51.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-51.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-51.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-65.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.8'}={
        "/bin/ksh"  =>  "ksh-20100621-5.el5.x86_64",
        "libc.so.6"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-81.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-81.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-52.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-52.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-81.i686",
        "libnsl.so.1"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-81.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-81.i686",
        "librt.so.1"  =>  "glibc-2.5-81.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-52.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-52.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-52.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-81.x86_64",
    };
    $pkg->{oslibs}{'RHEL5.9'}={
        "/bin/ksh"  =>  "ksh-20100621-12.el5.x86_64",
        "libc.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-54.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-54.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libnsl.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-107.el5_9.4.i686",
        "librt.so.1"  =>  "glibc-2.5-107.el5_9.4.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-54.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-54.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-54.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-107.el5_9.4.x86_64",
    };
    return;
}

package Pkg::VRTSvxfen61::RHEL6x8664;
@Pkg::VRTSvxfen61::RHEL6x8664::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{'RHEL6.3'}={
        "/bin/ksh"  =>  "ksh-20100621-16.el6.x86_64 mksh-39-7.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.80.el6.i686",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.80.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.6-4.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.6-4.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.80.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.80.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.80.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.80.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.6-4.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.80.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.4'}={
        "/bin/ksh"  =>  "mksh-39-7.el6.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.107.el6.i686",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.107.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.7-3.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.7-3.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.107.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.107.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.107.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.107.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-3.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.107.el6.x86_64",
    };
    $pkg->{oslibs}{'RHEL6.5'}={
        "/bin/ksh"  =>  "mksh-39-7.el6_4.1.x86_64",
        "libc.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.132.el6.i686",
        "libc.so.6(GLIBC_2.7)"  =>  "glibc-2.12-1.132.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.7-4.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.7-4.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.132.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.132.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.132.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.132.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.7-4.el6.i686",
        "perl(Exporter)"  =>  "perl-5.10.1-136.el6.x86_64",
        "perl(strict)"  =>  "perl-5.10.1-136.el6.x86_64",
        "perl(warnings)"  =>  "perl-5.10.1-136.el6.x86_64",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.132.el6.x86_64",
    };
    return;
}

package Pkg::VRTSvxfen61::SLES10x8664;
@Pkg::VRTSvxfen61::SLES10x8664::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "/bin/ksh"  =>  "ksh-93t-13.17.19.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTSvxfen61::SLES11x8664;
@Pkg::VRTSvxfen61::SLES11x8664::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{SLES11SP2}={
        "/bin/ksh"  =>  "ksh-93u-0.6.1.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libgcc_s.so.1"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.3-17.31.1.x86_64",
        "libstdc++.so.6"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++46-32bit-4.6.1_20110701-0.13.9.x86_64",
    };
    $pkg->{oslibs}{SLES11SP3}={
        "/bin/ksh"  =>  "ksh-93u-0.18.1.x86_64",
        "libc.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libgcc_s.so.1"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc_s1-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.3-17.54.1.x86_64",
        "libstdc++.so.6"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++6-32bit-4.7.2_20130108-0.15.45.x86_64",
    };
    return;
}

package Pkg::VRTSvxfen61::RHEL5ppc64;
@Pkg::VRTSvxfen61::RHEL5ppc64::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        '/bin/ksh'  =>  'ksh-20060214-1.7.ppc',
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libm.so.6'  =>  'glibc-2.5-24.ppc',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'librt.so.1'  =>  'glibc-2.5-24.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTSvxfen61::SLES10ppc64;
@Pkg::VRTSvxfen61::SLES10ppc64::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        '/bin/ksh'  =>  'ksh-93s-59.7.ppc',
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libm.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'librt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
    };
    return;
}

package Pkg::VRTSvxfen61::SLES11ppc64;
@Pkg::VRTSvxfen61::SLES11ppc64::ISA = qw(Pkg::VRTSvxfen61::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        '/bin/ksh'  =>  'ksh-93t-9.4.ppc64',
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libgcc_s.so.1'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libm.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.6)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'librt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libstdc++.so.6'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
    };
    return;
}

package Pkg::VRTSvxfen61::SunOS;
@Pkg::VRTSvxfen61::SunOS::ISA = qw(Pkg::VRTSvxfen61::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{smf}=['/var/svc/manifest/system/vxfen.xml', '/lib/svc/method/vxfen'];
    return;
}

sub preremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS61');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS61');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

1;
