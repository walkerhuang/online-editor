use strict;

package Rel::AGPACK61::Common;
@Rel::AGPACK61::Common::ISA = qw(Rel);

sub init_common {
    my ($rel) = @_;
    $rel->{reltitle}=Msg::new("Symantec High Availability Wizards Agent Pack")->{msg};
    $rel->{titlevers}='6.1';
    $rel->{pkgs}=1;
    $rel->{args_task} = [ qw(configure install uninstall) ];
    $rel->{prods}=[ qw(AGPACK61) ];
    $rel->{pkgsetprods}=[ qw(AGPACK61) ];
    $rel->{minpkgs} = $rel->{recpkgs} = $rel->{allpkgs}=[ qw(VRTSvcswiz61) ];
    $rel->{sort_upload_config_url}='https://telemetrics.symantec.com/data/uploader/uxrt60upload.conf';
    return;
}

sub cli_installer_menu {
    my ($rel) = @_;
    my ($cpic,$task);
    $cpic=Obj::cpic();
    $task=$cpic->{task};
    for my $mtask (@{$rel->{args_task}}) {
        if (Cfg::opt("$mtask")) {
            $task=$mtask;
            last;
        }
    }
    $cpic->set_task($task);
    $cpic->{task}=$task;
    Rel::cli_installer_menu($rel);
}

sub filter_args{
    my ($rel,$args_hash,$prod)=@_;
    $args_hash->{args_def} = ["require","responsefile","keyfile","hostfile","sshpath","scppath","mediapath"];
    $args_hash->{args_opt} = ["serial","rsh","installallpkgs","allpkgs","makeresponsefile","trace"];
    $args_hash->{args_task} = ["install","configure","uninstall","upgrade","precheck"];
}

sub read_licenses{ return; }
sub check_update{ return; }

sub configure_sys{
    my ($prod,$sys) =@_;
#    my ($conf,$cfg,$pid,@lines,$cf,$cfg,$edr,$msg,$had);
#    $cfg  = Obj::cfg();
#    $edr = Obj::edr();
#    $prod->vcs_restore_sys($sys);
#    $prod->set_onenode_cluster_sys($sys,1);
#    $prod->config_uuid();
    if($sys->exists("/opt/VRTSagents/ha/bin/WebLogic/wls_update.pl")){
        $sys->cmd("/opt/VRTSperl/bin/perl /opt/VRTSagents/ha/bin/WebLogic/wls_update.pl")
    }
#    if($sys->{vcsrunning} == 1){
#        $had = Obj::proc("had60");
#        $had->set_value('donotstart',0);
#    }
    return;
}

sub preremove_sys {
    my ($prod, $sys) = @_;
    my $edr = Obj::edr();
    $sys->cmd("_cmd_mkdir -p $edr->{tmpdir}/backup");
    $sys->cmd("_cmd_mkdir -p $edr->{tmpdir}/backup/config");
    $sys->cmd("_cmd_cp -f /opt/VRTSvcs/portal/admin/.xprtlaccess $edr->{tmpdir}/backup/") if $sys->exists("/opt/VRTSvcs/portal/admin/.xprtlaccess");
    $sys->cmd("_cmd_cp -f /opt/VRTSvcs/portal/admin/plugins/unix/conf/app.conf $edr->{tmpdir}/backup/")if $sys->exists("/opt/VRTSvcs/portal/admin/plugins/unix/conf/app.conf");
    $sys->cmd("_cmd_cp -f /opt/VRTSvcs/portal/admin/plugins/unix/conf/settings.conf $edr->{tmpdir}/backup/")if $sys->exists("/opt/VRTSvcs/portal/admin/plugins/unix/conf/settings.conf");
#    $sys->cmd("_cmd_cp -f /etc/sysconfig/vcs $edr->{tmpdir}/backup/")if $sys->exists("/etc/sysconfig/vcs");
    $sys->cmd("_cmd_cp -f /opt/VRTSvcs/portal/world/appcontrol_config_status.xml $edr->{tmpdir}/backup/")if $sys->exists("/opt/VRTSvcs/portal/world/appcontrol_config_status.xml");
    $sys->cmd("_cmd_cp -f /opt/VRTSvcs/portal/world/GuestConfig.xml $edr->{tmpdir}/backup/")if $sys->exists("/opt/VRTSvcs/portal/world/GuestConfig.xml");
#    $sys->cmd("_cmd_cp -rf /etc/VRTSvcs/conf/config/* $edr->{tmpdir}/backup/config/");
#    $prod->vcs_backup_sys($sys);
    return 1;
}

sub postinstall_sys {
    my ($prod, $sys) = @_;
    my $exitcode;
    my $cpic = Obj::cpic();
    my $cfg  = Obj::cfg();
    my $edr  = Obj::edr();
    my $msg;
    #my $pkg  = Obj::pkg('VRTSsfmh40', $prod->{padv});
    #$pkg->postinstall_sys($sys);
#    $sys->cmd("_cmd_cp -f $edr->{tmpdir}/backup/config/*  /etc/VRTSvcs/conf/config/");
    $sys->cmd("_cmd_cp -f $edr->{tmpdir}/backup/.xprtlaccess  /opt/VRTSvcs/portal/admin/")if $sys->exists("$edr->{tmpdir}/backup/.xprtlaccess");
    $sys->cmd("_cmd_cp -f $edr->{tmpdir}/backup/app.conf /opt/VRTSvcs/portal/admin/plugins/unix/conf/")if $sys->exists("$edr->{tmpdir}/backup/app.conf");
#    $sys->cmd("_cmd_cp -f $edr->{tmpdir}/backup/vcs /etc/sysconfig/")if $sys->exists("$edr->{tmpdir}/backup/vcs");
    $sys->cmd("_cmd_cp -f $edr->{tmpdir}/backup/appcontrol_config_status.xml /opt/VRTSvcs/portal/world/")if $sys->exists("$edr->{tmpdir}/backup/appcontrol_config_status.xml");
    $sys->cmd("_cmd_cp -f $edr->{tmpdir}/backup/GuestConfig.xml /opt/VRTSvcs/portal/world/")if $sys->exists("$edr->{tmpdir}/backup/GuestConfig.xml");

    $sys->cmd("_cmd_cp -f /etc/VRTSagents/ha/conf/Oracle/OracleTypes.cf /etc/VRTSvcs/conf/config/")if $sys->exists("/etc/VRTSagents/ha/conf/Oracle/OracleTypes.cf");
    $sys->cmd("_cmd_cp -f /etc/VRTSagents/ha/conf/Db2udb/Db2udbTypes.cf /etc/VRTSvcs/conf/config/")if $sys->exists("/etc/VRTSagents/ha/conf/Db2udb/Db2udbTypes.cf");
#    $sys->cmd("_cmd_cp -f /etc/VRTSvcs/conf/types.cf /etc/VRTSvcs/conf/config/")if $sys->exists("/etc/VRTSvcs/conf/types.cf");
#    $sys->cmd("_cmd_cp -f /etc/VRTSvcs/conf/vmwagtype.cf /etc/VRTSvcs/conf/config/")if $sys->exists("/etc/VRTSvcs/conf/vmwagtype.cf");

#    my $maincf = $sys->readfile("$edr->{tmpdir}/backup/config/main.cf");
#    if($maincf =~ /VRTSWebApp|SANVolume|Scsi3PR/){
#        $msg = Msg::new("WARNING: VRTSWebApp, SANVolume and Scsi3PR are obsoleted resource types, please remove them from main.cf on $sys->{hostname}");
#        $msg->log;
#        $sys->set_value('maincf',$msg->msg);
#    }else{
#        my $rtn = $sys->cmd("/opt/VRTSvcs/bin/hacf -verify /opt/VRTSvcs/conf/config");
#        if (EDR::cmdexit() != 0) {
#            $msg = Msg::new("WARNING: main.cf on $sys->{hostname} is not valid:\n$rtn\nFix the errors, and verify the main.cf file before running \'/opt/VRTSvcs/binhacf -verify /opt/VRTSvcs/conf/config\'");
#            $msg->log;
#            $sys->set_value('maincf',$msg->msg);
#        }
#    }
    if($sys->exists("/opt/VRTSagents/ha/bin/WebLogic/wls_update.pl")){
        $sys->cmd("/opt/VRTSperl/bin/perl /opt/VRTSagents/ha/bin/WebLogic/wls_update.pl") 
    }
    $sys->cmd("/opt/VRTSvcs/portal/admin/settings_upgrade.pl $edr->{tmpdir}/backup/settings.conf");
    $exitcode = EDR::cmdexit();
    if ($exitcode) {
        $msg = Msg::new("WARNING: settings_upgrade.pl failed with exit code $exitcode.");
        $msg->log;
    }
#    if ($cfg->{sso_console_ip} && $cfg->{sso_local_username} && $cfg->{sso_local_password}) {
#        $edr->{donotlog} = 1;
#        
#        $sys->cmd("/opt/VRTSvcs/portal/admin/configureSSO.pl $cfg->{sso_console_ip} $cfg->{sso_local_username} $cfg->{sso_local_password}");
#        $edr->{donotlog} = 0;
#        my $exitcode = EDR::cmdexit();
#        if ($exitcode) {
#            $msg = Msg::new("WARNING: configureSSO.pl failed with exit code $exitcode.");
#            $msg->log;
#        }
#    }

    return 1;
}

sub poststart_sys {
    my($prod,$sys) = @_;
    $sys->cmd("/opt/VRTSvcs/portal/admin/synchronize_guest_config.pl");
    my $exitcode = EDR::cmdexit();
    if ($exitcode) {
        my $msg = Msg::new("WARNING: synchronize_guest_config.pl failed with exit code $exitcode.");
        $msg->log;
    }
}

package Rel::AGPACK61::AIX;
@Rel::AGPACK61::AIX::ISA = qw(Rel::AGPACK61::Common);

package Rel::AGPACK61::Linux;
@Rel::AGPACK61::Linux::ISA = qw(Rel::AGPACK61::Common);

# Just status display message are commented because we are following KISS as different no. of status messages on
# different plats create unnecessary complexity for EDR
sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($patchlevel,$xen_supp,$msg,$rpm_dir,$kret,$ksles,$padv,$kstring,$cpic,@f,$distro,@pkg_files,$pkg,$prod);
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return '' if (Cfg::opt('ignorechecks'));

    $cpic=Obj::cpic();
    $prod=$sys->prod($cpic->{prod});
    $padv=$sys->padv($sys->{padv});
    $distro=$padv->distro_sys($sys);
    $kstring=$sys->cmd('_cmd_uname -r');
    $kstring =~ /\-(\d+)/m;
    $kret = $1;
    $ksles=$1 if ($kstring =~ /\-\d+\.(\d+)/mx);
    @f=split(/\W/m,$kstring);

    my $localsys = Obj::localsys();
    my $mediapath=EDR::get('mediapath');
    my $tmpdir = EDR::tmpdir();
    my $vmware = 0;
    my $testVMware = "$mediapath/scripts/bin/testVMware";
    my $vmware_tools_svc = "";

    if(!$localsys->exists($testVMware)){
        $testVMware = '/opt/VRTSsfmh/bin/testVMware';
    }

    if($localsys->exists($testVMware)){
        $localsys->copy_to_sys($sys,$testVMware,"$tmpdir/");
        $sys->cmd("$tmpdir/testVMware");
	if (EDR::cmdexit() == 0){
		$vmware = 1;
		# VMware tool existence check
		if ($sys->exists("/etc/init.d/vmware-tools")) {
			$vmware_tools_svc = "/etc/init.d/vmware-tools";
		}
		elsif ($sys->exists("/etc/vmware-tools/services.sh")) {
			$vmware_tools_svc = "/etc/vmware-tools/services.sh";
		}
		elsif ($sys->exists("/etc/init.d/vmware-tools-services")) {
			$vmware_tools_svc = "/etc/init.d/vmware-tools-services";
		}else{
			$msg = Msg::new("vmware-tools does not exist, Please install vmware-tools and start it before install $prod->{abbr}");
			$sys->push_error($msg);
			return '';
		}
		# VMware toll running status check
		if ( $vmware_tools_svc ne "" ) {
			$sys->set_value('vmtype','vmware');
			my $state = $sys->cmd("$vmware_tools_svc status");
			if ($state =~ /not/i) {
				#if not running start it and again check status
				$sys->cmd("$vmware_tools_svc start");
				sleep 5;
				$state = $sys->cmd("$vmware_tools_svc status");
				if ($state =~ /not/i) {
					$msg = Msg::new("vmware-tools is not running, installer attemped to start it but failed. Please start it before install $prod->{abbr}");
					$sys->push_error($msg);
					return '';
				}
			}
		}
	}
    }
    
    # KVM just support RHEL5 and RHEL6
    if($vmware == 0 && $distro ne 'RHEL'){
        $msg=Msg::new("$prod->{prod} for KVM does not support to be installed to OEL and SuSE.");
        $sys->push_error($msg);
        return '';
    }

    # Need to add LMH install hack
    # Need to add 5.0MP2 combo installer hack

    if ($distro eq 'RHEL') {
        $padv->{cmd}{selinuxenabled}='/usr/sbin/selinuxenabled';
        # RHEL5 check
        if ($kstring =~ /el6/m) {
        } elsif ($kstring =~ /el5/m) {
            if ($kret < 128) { # RHEL5u3 or above check
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.18-128.el5(RHEL5 U3) or higher is supported on RHEL5. Upgrade the OS to Update5 or higher in order to install this product");
                $sys->push_error($msg);
                return '';
            }
        }
    } elsif ($distro eq 'SLES') {
        $padv->{cmd}{selinuxenabled}='/usr/bin/selinuxenabld';

        #SLES 10 SP4 or above check
        #In 6.0, SLES 10 SP4 is supported,
        #SP3 kernel version is above 2.6.16.60-0.54.5
        #SP4 kernel version is above 2.6.16.60-0.85.1
        #For PATCHLEVEL is higher than SuSE 10 SP4 and SuSE11 SP1, maybe does not support

        $patchlevel=$sys->{patchlevel};

        if (($f[2]==16) && ($f[3] < 60)) {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.16.60-0.85(SLES10 SP4) or higher is supported on SuSE10. Upgrade the OS to SLES10 SP4 or higher in order to install this product");
            $sys->push_error($msg);
            return '';
        }
        if (($f[2]==16) && ($f[3]==60) && ($f[5] < 85)) {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.16.60-0.85(SLES10 SP4) or higher is supported on SuSE10. Upgrade the OS to SLES10 SP4 or higher in order to install this product");
            $sys->push_error($msg);
            return '';
        }

        #SLES 11 SP1 or above check
        if (($f[2]==27) || (($f[2]==32) && ($f[3] < 12))) {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.32.12(SLES11 SP1) or higher is supported on SuSE11. Upgrade the OS to SLES11 SP1 or higher in order to install this product");
            $sys->push_error($msg);
            return '';
        }
        if (($f[2]==32) && (defined($patchlevel)) && ($patchlevel>1)){
            $msg=Msg::new("SuSE 11 SP1 is the recommended platform for the release on $sys->{sys}.");
            $sys->push_warning($msg);
            return '';
        }

    } elsif ($distro eq 'ESX') {
        # FIX: Figure this check out later for VMWARE. (Get versions of ESX supported and edit)
        if ($kret < 34) {
            $msg=Msg::new("Kernel Release $kstring is not supported on $sys->{sys}. Only Kernel Release 2.6.9-34.EL or higher is supported on RHEL.");
            $sys->push_error($msg);
            return '';
        }
    } elsif ($distro eq 'OL') {
        # FIX: Figure this check out later for Oracle Linux.
        $padv->{cmd}{selinuxenabled}='/usr/sbin/selinuxenabled';
        if ($kstring =~ /el6/m) {
            # OL6 check
            if ($kstring !~ /^2\.6\.32/m) {
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Red Hat compatible Kernel Release 2.6.32 is supported on Oracle Linux 6. you may configure the operating system to boot with this kernel instead.");
                $sys->push_error($msg);
                return '';
            }
        } elsif ($kstring =~ /el5/m) {
            # OL5 check
            if ($kstring !~ /^2\.6\.18/m) {
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Red Hat compatible Kernel Release 2.6.18 is supported on Oracle Linux 5. you may configure the operating system to boot with this kernel instead.");
                $sys->push_error($msg);
                return '';
            }
        }
    } else {
        $msg=Msg::new("Distribution is not recognized as SuSE or Red Hat on $sys->{sys}");
        $sys->push_error($msg);
        return '';
    }

    # XEN dom0 with RHEL5/x64 U5,OEL5.3,SLES10/x64 SP3/SP4,and SLES11/x64 SP1(Supported for VxVM. No VxFS support)
    # The kernel releases supported for both xen and non-xen systems are the same, so only check x86_64 architecture here.
    if ($kstring =~ /xen/m) {
        $xen_supp=1 if (($distro eq 'RHEL')||($distro eq 'SLES'))&&($sys->{arch} eq 'x86_64')&&($prod->{prod} eq 'VM');
        unless ($xen_supp) {
            $msg=Msg::new("Kernel Release $kstring is not supported on $sys->{sys} with $prod->{prod}. Only Volume Manger product is supported on Xen kernels in this release. Run the installvm script from the volume_manager directory to install the VxVM product.");
            $sys->push_error($msg);
            return '';
        }
    }

    # Distribution match on all systems removed as any to many support is added
    for my $pkgi (@{$rel->allpkgs}) {
        $pkg=$sys->pkg($pkgi);
        push(@pkg_files,$pkg->{file});
    }

    if (@pkg_files) {
       return 1 if ($cpic->{fromdisk});
       $rpm_dir=$rel->pkgs_patches_dir('pkgpath');;
       if ((($sys->{arch}=~/686/m)||($sys->{arch}=~/586/m)) && (grep {/86_64/m} @pkg_files)) {
            $msg=Msg::new("System $sys->{sys} is architecture $sys->{arch} and x86_64 rpms were found in $rpm_dir. Check that you are installing from the correct DVD. Some rpms will not install correctly on this system.");
            $sys->push_error($msg);
            return '';
        }

       if ((($distro eq 'RHEL') && (grep {/SLES/} @pkg_files))
            ||  (($distro eq 'SLES') && (grep {/RHEL/} @pkg_files))) {
            $msg=Msg::new("System $sys->{sys} is distribution $distro and incompatible rpms were found in $rpm_dir. Check that you are installing from the correct DVD. Some rpms will not install correctly on this system.");
            $sys->push_error($msg);
            return '';
       }
    }

    # No need for selinux checks any more
    return 1;
}

sub adjust_pkg_sequence {
        my ($rel, $pkgarray) = @_;
        return $pkgarray;
}

package Rel::AGPACK61::RHEL5x8664;
@Rel::AGPACK61::RHEL5x8664::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::RHEL5ppc64;
@Rel::AGPACK61::RHEL5ppc64::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::RHEL6x8664;
@Rel::AGPACK61::RHEL6x8664::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::SLES10x8664;
@Rel::AGPACK61::SLES10x8664::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::SLES10ppc64;
@Rel::AGPACK61::SLES10ppc64::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::SLES11x8664;
@Rel::AGPACK61::SLES11x8664::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::SLES11ppc64;
@Rel::AGPACK61::SLES11ppc64::ISA = qw(Rel::AGPACK61::Linux);

package Rel::AGPACK61::SunOS;
@Rel::AGPACK61::SunOS::ISA = qw(Rel::AGPACK61::Common);

package Rel::AGPACK61::SolSparc;
@Rel::AGPACK61::SolSparc::ISA = qw(Rel::AGPACK61::SunOS);

package Rel::AGPACK61::Solx64;
@Rel::AGPACK61::Solx64::ISA = qw(Rel::AGPACK61::SunOS);

package CPIP;
sub cpip_resume_subs {
	[qw( Prod::AGPACK61::Common::cli_prestart_config_questions)]
}


1;
