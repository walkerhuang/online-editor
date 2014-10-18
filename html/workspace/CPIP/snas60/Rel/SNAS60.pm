use strict;

package CPIC;

{   # Prevent 'Subroutine ... redefined' warning to pacify UnitTest report tool
    no warnings qw(redefine);

sub base_release { '6.0' };
}


package Rel::SNAS60::Common;
@Rel::SNAS60::Common::ISA = qw(Rel);

sub init_common {
    my ($rel) = @_;
    my $mediapath;

    $rel->{verify_media}=1; # comment out once release layout is stable
    $rel->{reli}='UXRT';
    $rel->{reltitle}=Msg::new("Symantec Storage: NAS")->{msg};
    $rel->{reltitle_short}=Msg::new("Symantec Storage: NAS")->{msg};
    $rel->{vers}='6.0';
    $rel->{basevers}='6.0';
    $rel->{baseversions}=[ '6.0' ];
    $rel->{gavers}='6.0';
    $rel->{titlevers}='6.0';
    $rel->{basetitlevers}='6.0';
    $rel->{type}='B';
    $rel->{pkgs}=1;
    $rel->{license_ver}="6.1";
    $rel->{keyless_license_ver}="6.1";
    $rel->{default_repository} = '/opt/VRTS/install/repository';
    $rel->{status_file} = '/opt/SYMCsnas/log/status';
    $rel->{operation} = {
        'RU' => '3,Rolling Upgrade',
        'ADD' => '6,Add Node',
        'DEL' => '3,Delete Node',
    };

    $rel->{build_state}='_BUILD_STATE_';
    $rel->{build_sprint}='_BUILD_SPRINT_';
    $rel->{build_date}='_BUILD_DATE_';

    $rel->{sort_upload_config_url}='https://telemetrics.symantec.com/data/uploader/uxrt60upload.conf';

    $rel->{prods}=[ qw(FS61 DMP61 VM61 VCS61 APPLICATIONHA61 SF61 SFHA61 SFCFSHA61 SNAS60 SFCFSRAC61 SVS61 SFSYBASECE61 SFRAC61) ];
    $rel->{pkgsetprods}=[ qw(SFRAC61 SFSYBASECE61 SVS61 SFCFSHA61 SFHA61 SF61 APPLICATIONHA61 VCS61 DMP61) ];
    $rel->{menuprods}=[ qw(DMP61 VCS61 SF61 SFHA61 SFCFSHA61 SFSYBASECE61 SFRAC61 APPLICATIONHA61) ];
    $rel->{upgradeprods} = [ qw(SNAS60 SFRAC61 SFSYBASECE61 SFCFSHA61 SFHA61 APPLICATIONHA61 SF61 VCS61 VM61 DMP61 FS61) ];
    $rel->{allpkgs}=[ qw(VRTSperl516 VRTSvlic32 SYMCsnascpi60 VRTSspt61) ];
    $rel->{minpkgs}=[ qw(VRTSperl516 VRTSvlic32 SYMCsnascpi60) ];
    $rel->{recpkgs}=[ qw(VRTSperl516 VRTSvlic32 SYMCsnascpi60 VRTSspt61) ];
    $rel->{cpipkg}='SYMCsnascpi60';

    $rel->{ru_prod}=[ qw(SNAS60 SFRAC61 SVS61 SFSYBASECE61 SFCFSHA61 SFHA61 VCS61) ];
    $rel->{ru_unkernelpkgs}=[ qw(VRTSvcs61 VRTSvcsag61 VRTSvcsea61 VRTScavf61 VRTSvbs61 VRTSvcswiz61) ];
    $rel->{ru_noupgrademsg_prod}=[ qw(SFRAC) ];
    $rel->{ru_version}='6.0';
    $rel->{bucket_version}='5.1';
    $rel->{pkgset_version}='5.1';

    $rel->{installonupgradepkgs}=[ qw(SYMCsnascpi60) ];

    $rel->{obsolete_scripts} = [qw( installfs       uninstallfs
                                    installvm       uninstallvm
                                    installsvs      uninstallsvs
                                    installsfora    uninstallsfora
                                    installsfsyb    uninstallsfsyb
                                    installsfcfs    uninstallsfcfs
                                    installsfdb2    uninstallsfdb2)];
    $mediapath=EDR::get('mediapath');
    if(-d "$mediapath/storage_foundation_basic") {
        $rel->{menuprods}=[ qw(SF61) ];
        $rel->{verify_media}=0; # do not check release layout
    }
    $rel->{oem}=1 if ((-f "$mediapath/.oem")
                      || (-f "$mediapath/../.oem")
                      || (EDRu::inarr('-oem',@ARGV)));
    $rel->{oem}='' if (EDRu::inarr('-nooem',@ARGV));

    $rel->{cross_upgradable_matrix}= {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => ['SFCFSHA'],
        'SFCFSHA' => [],
        'SFCFS' => ['SFCFSHA'],
        'SFHA' => [],
        'SF' => [],
        'VCS' => [],
        'VM' => ['SF'],
        'DMP' => ['SF'],
        'FS' => ['SF'],
        'AT' => ['ALL'],
        'SFSYBASECE' => [],
        'APPLICATIONHA' => [],
    };
    $rel->{partial_upgradable_matrix}= {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => ['SFCFSHA'],
        'SFCFSHA' => ['SFCFS'],
        'SFCFS' => [],
        'SFHA' => ['SF','VCS','VM','FS'],
        'SF' => ['VM','FS'],
        'VCS' => [],
        'VM' => [],
        'DMP' => [],
        'FS' => [],
        'AT' => [],
        'SFSYBASECE' => [],
        'APPLICATIONHA' => [],
    };
    $rel->{independent_prod_matrix} = {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => [],
        'SFCFSHA' => [],
        'SFCFS' => [],
        'SFHA' => [],
        'SF' => ['VCS','APPLICATIONHA'],
        'VCS' => ['SF','VM','DMP','FS'],
        'VM' => ['VCS','FS','APPLICATIONHA'],
        'DMP' => ['VCS','FS','APPLICATIONHA'],
        'FS' => ['VCS','VM','DMP','APPLICATIONHA'],
        'AT' => [],
        'SFSYBASECE' => [],
        'APPLICATIONHA' => ['SF','VM','DMP','FS'],
    };
    $rel->{upsell_prod_matrix} = {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => ['SFCFSHA'],
        'SFCFSHA' => [],
        'SFCFS' => [],
        'SFHA' => ['SFRAC', 'SFCFSRAC', 'SFCFSHA', 'SFCFS', 'SFSYBASECE'],
        'SF' => ['SFHA', 'SFRAC', 'SFCFSRAC', 'SFCFSHA', 'SFCFS', 'SFSYBASECE'],
        'VCS' => ['SFHA', 'SFRAC', 'SFCFSRAC', 'SFCFSHA', 'SFCFS', 'SFSYBASECE'],
        'VM' => ['SF', 'SFHA', 'SFRAC', 'SFCFSRAC', 'SFCFSHA', 'SFCFS', 'SFSYBASECE'],
        'DMP' => ['VM', 'SF', 'SFHA', 'SFRAC', 'SFCFSRAC', 'SFCFSHA', 'SFCFS', 'SFSYBASECE'],
        'FS' => ['SF', 'SFHA', 'SFRAC', 'SFCFSRAC', 'SFCFSHA', 'SFCFS', 'SFSYBASECE'],
        'AT' => [],
        'SFSYBASECE' => [],
        'APPLICATIONHA' => [],
    };
    $rel->{conflict_prod_matrix} = {
        'SFRAC' => ['ApplicationHA'],
        'SFCFSRAC' => ['ApplicationHA'],
        'SVS' => ['ApplicationHA'],
        'SFCFSHA' => ['ApplicationHA'],
        'SFCFS' => ['ApplicationHA'],
        'SFHA' => ['ApplicationHA'],
        'SF' => [],
        'ApplicationHA' => ['SFRAC','SFSYBASECE','SFCFSHA','SFHA','VCS'],
        'VCS'=> ['ApplicationHA'],
        'VM' => [],
        'DMP' => [],
        'FS' => [],
        'AT' => [],
        'SFSYBASECE' => ['ApplicationHA'],
    };
    $rel->init_obsolete_packages_description ();
    $rel->init_options();
    return;
}

sub adjust_options {
    my $rel = shift;
    my $edr = Obj::edr();
    if (Cfg::opt('snas_upgrade')) {
        my $cfg = Obj::cfg();
        my $prod = Obj::prod($cfg->{prod});
        $prod->opt_snas_upgrade();
    }
    $rel->init_pkg_options();
    $edr->{no_gssapi} = 1;
}

# use noipc and ssh for SNAS by default
sub init_options {
    my $rel = shift;

    push (@ARGV, '-noipc') unless (EDRu::inarr('-noipc', @ARGV));
    push (@ARGV, '-ssh') unless (EDRu::inarr('-ssh', @ARGV));
    return; 
}

sub init_pkg_options {
    my $rel = shift;
    my $pkg;

    return if (!Cfg::opt('upgradecv'));

    for my $pkgi(qw(SYMCsnas60 SYMCsnascpi60)) {
        $pkg = $rel->pkg($pkgi);
        $pkg->{forceinstall} = 1;
    }
    return; 
}

sub init_obsolete_packages_description {
    my $rel = shift;
    $rel->{package_descriptions} = {
        'SYMClma' => 'License Inventory Agent',
        'VRTSaa' => 'Storage Foundation Management Server',
        'VRTSacclib' => 'Cluster Server ACC Library',
        'VRTSalloc' => 'Storage Foundation Intelligent Storage Provisioning',
        'VRTSap' => 'Action Provider',
        'VRTSccacm' => 'Storage Foundation Management Server',
        'VRTSccg' => 'Storage Foundation Management Server',
        'VRTScfsdc' => 'Cluster File System Documentation',
        'VRTScmccc' => 'Cluster Management Console Cluster Connector',
        'VRTScmcs' => 'Cluster Management Console for single cluster environnments',
        'VRTScscm' => 'Cluster Server Cluster Manager',
        'VRTScscw' => 'Cluster Server Configuration Wizards',
        'VRTScsocw' => 'Cluster Server Oracle and RAC Configuration Wizards',
        'VRTScssim' => 'Cluster Server Simulator',
        'VRTScutil' => 'Cluster Utility',
        'VRTSdbcom' => 'Storage Foundation Common Utilities for Databases',
        'VRTSd2doc' => 'Storage Foundation for DB2 Documentation',
        'VRTSdbdoc' => 'Storage Foundation Documentation for Databases',
        'VRTSdbms3' => 'Shared DBMS',
        'VRTSdcli' => 'Distributed Command Line Interface',
        'VRTSddlpr' => 'Device Discovery Layer Services Provider',
        'VRTSdsa' => 'Datacenter Storage Agent',
        'VRTSfppm' => 'File Placement Policy Manager',
        'VRTSfsdoc' => 'File System Documentation',
        'VRTSfsman' => 'File System Manual Pages',
        'VRTSfsmnd' => 'File System SDK Manual Pages',
        'VRTSfsnbl' => 'File System NBU Libraries',
        'VRTSfspro' => 'File System Management Services Provider',
        'VRTSgapms' => 'Generic Array Plugin',
        'VRTSicsco' => 'Infrastructure Core Services Common',
        'VRTSjre' => 'JRE Redistribution',
        'VRTSjre15' => 'JRE Redistribution',
        'VRTSmapro' => 'Storage Mapping Provider',
        'VRTSmh' => 'Storage Foundation Management Server',
        'VRTSobc33' => 'Enterprise Administrator Core',
        'VRTSobgui' => 'Enterprise Administrator',
        'VRTSodm-platform' => 'Oracle Disk Manager Platform package',
        'VRTSordoc' => 'Storage Foundation for Oracle Documentation',
        'VRTSpbx' => 'Private Branch Exchange',
        'VRTSsmf' => 'Service Management Framework',
        'VRTStep' => 'Task Exec Provider',
        'VRTSvail' => 'Array Providers',
        'VRTSvcsApache' => 'Cluster Server Apache Agent',
        'VRTSvcsdb' => 'Cluster Server Db2udb Enterprise Extension',
        'VRTSvcsdc' => 'Cluster Server Documentation',
        'VRTSvcsmg' => 'Cluster Server English Message Catalogs',
        'VRTSvcsmn' => 'Manual Pages for Cluster Server',
        'VRTSvcsor' => 'High Availability Agent for Oracle',
        'VRTSvcsvr' => 'Cluster Server Agents for Volume Replicator',
        'VRTSvcssy' => 'Cluster Server Sybase Enterprise Extension',
        'VRTSvdid' => 'Device Identification API',
        'VRTSvlic' => 'Licensing',
        'VRTSvmdoc' => 'Volume Manager Documentation',
        'VRTSvmman' => 'Volume Manager Manual Pages',
        'VRTSvmpro' => 'Volume Manager Management Services Provider',
        'vrtsvrdoc' => 'Volume Replicator Documentation',
        'VRTSvrpro' => 'Volume Replicator Management Services Provider',
        'VRTSvrw' => 'Volume Replicator Web Console',
        'VRTSvsvc' => 'Volume Server and Client Provider',
        'VRTSvxfs-platform' => 'File System Platform Libraries',
        'VRTSvxmsa' => 'Mapping Service Application Libraries',
        'VRTSvxvm-platform' => 'Volume Manager Platform Libraries',
        'VRTSsfcpi' => 'Storage Foundation Installer',
        'VRTSweb' => 'Web Server',
    };
    return 1;
}

sub pkgdesc {
    my ($rel, $pkg) = @_;

    $pkg=$pkg->{pkg} if (ref($pkg) =~ m/^Pkg/);
    $pkg =~ s/\d+//g if ($pkg =~ /VRTSsfcpi/m);
    return $rel->SUPER::pkgdesc($pkg);
}

sub init_args {
    my $rel = shift;
    my ($arguments,$arg_def,$pdfrs,$plat);
    $pdfrs=Msg::get('pdfrs');

    $rel->{arguments} = $arguments = {
        # args_def: [ qw(jumpstart flash_archive kickstart nim) ],
        'args_def' => [ ],

        'args_opt' => [ qw(ssh security securityonenode securitytrust fips addnode delnode updateparameter fencing configcps disable_dmp_native_support vxunroot rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2 pseudo_hotfix snas_upgrade) ],

        # Those arguments have no specific entry here are considered as undocumented arguments.
        # Those arguments have specific entry here but without 'description' attribute are considered as undocumented arguments.
        # Those arguments have specific entry here and with 'undocumented' attribute are considered as undocumented arguments.

        # SNAS60 definition args
        'jumpstart' => {
		#'option_description' => Msg::new("<jumpstart_path>"),
            	#'description' => Msg::new("The -jumpstart option is used to generate finish scripts which can be used by Solaris Jumpstart Server for automated installation of all $pdfrs and patches for every product, an available location to store the finish scripts should be specified as a complete path. The -jumpstart option is supported on Solaris only."),
            'handler' => \&Rel::SNAS60::Common::process_jumpstart_arg,
        },
        'flash_archive' => {
		#'option_description' => Msg::new("<flash_archive_path>"),
            	#'description' => Msg::new("The -flash_archive option is used to generate Flash archive scripts which can be used by Solaris Jumpstart Server for automated Flash archive installation of all $pdfrs and patches for every product, an available location to store the post deployment scripts should be specified as a complete path. The -flash_archive option is supported on Solaris only."),
            'handler' => \&Rel::SNAS60::Common::process_flash_archive_arg,
        },
        'ai' => {
		#'option_description' => Msg::new("<ai_path>"),
            	#'description' => Msg::new("The -ai option is used to generate Automated Installation manifest which can be used by Solaris Automated Installation Server to install Symantec product together with the Solaris operation system. An available location to store the installation manifests should be specified as a complete path. The -ai option is supported on Solaris 11 only."),
            'handler' => \&Rel::SNAS60::Common::process_ai_arg,
        },
        'kickstart' => {
            'option_description' => Msg::new("<kickstart_path>"),
            'description' => Msg::new("The -kickstart option is used to generate kickstart scripts which can be used by Redhat Linux Kickstart for automated installation of all $pdfrs for every product, an available location to store the kickstart scripts should be specified as a complete path. The -kickstart option is supported on Redhat Linux only."),
            'handler' => \&Rel::SNAS60::Common::process_kickstart_arg,
        },
        'yumgroupxml' => {
            'option_description' => Msg::new("<yum_group_xml_path>"),
            'description' => Msg::new("The -yumgroupxml option is used to generate a yum group definition XML file which can be used by createrepo command on Redhat Linux to create yum group for automated installation of all $pdfrs for a product. An available location to store the XML file should be specified as a complete path. The -yumgroupxml option is supported on Redhat Linux only."),
            'handler' => \&Rel::SNAS60::Common::process_yumgroupxml_arg,
        },
        'nim' => {
		#'option_description' => Msg::new("<LPP_SOURCE>"),
            	#'description' => Msg::new("The -nim option is used to generate an installp_bundle which is used by an AIX NIM Server for automated installation of all $pdfrs and patches for every product. An available LPP_SOURCE directory must also be specified. The -nim option is supported on AIX only."),
            'handler' => \&Rel::SNAS60::Common::process_nim_arg,
        },

        # SNAS60 option args
        'ignite' => {
		#'description' => Msg::new("The -ignite option is used to generate a product bundle which is used by an HPUX Ignite Server for automated installation of all $pdfrs and patches for every product. The -ignite option is supported on HPUX only."),
            'handler' => \&Rel::SNAS60::Common::process_ignite_arg,
        },

        'security' => {
            'description' => Msg::new("The -security option is used to convert a running VCS cluster between secure and non-secure modes of operation"),
            'handler' => \&Rel::SNAS60::Common::process_security_arg,
        },
        'securityonenode' => {
            'description' => Msg::new("The -securityonenode option is used to configure a secure cluster node by node."),
            'handler' => \&Rel::SNAS60::Common::process_security_arg,
        },
        'securitytrust' => {
            'description' => Msg::new("The -securitytrust option is used to setup trust with another broker."),
            'handler' => \&Rel::SNAS60::Common::process_security_arg,
        },
        'fips' => {
		'description' => Msg::new("The -fips option is used to enable or disable security with fips mode on a running VCS cluster. It could only be used together with -security or -securityonenode option"),
            'handler' => \&Rel::SNAS60::Common::process_security_arg,
        },
        'fencing' => {
		'description' => Msg::new("The -fencing option is used to configure I/O fencing in a running cluster"),
            'handler' => \&Rel::SNAS60::Common::process_fencing_arg,
        },
        'configcps' => {
		'description' => Msg::new("The -configcps option is used to configure CP server on a running system or cluster"),
            'handler' => \&Rel::SNAS60::Common::process_fencing_arg,
        },
        'addnode' => {
		#'description' => Msg::new("The -addnode option is used to add a node to a running cluster"),
            'handler' => \&Rel::SNAS60::Common::process_addnode_arg,
        },
        'delnode' => {
		#'description' => Msg::new("The -delnode option is used to delete a node from a running cluster"),
            'handler' => \&Rel::SNAS60::Common::process_delnode_arg,
        },
        'updateparameter' => {
            'description' => Msg::new("The -updateparameter option is used to update the network parameter for a running cluster"),
            'handler' => \&Rel::SNAS60::Common::process_updateparameter_arg,
        },
        'upgrade_kernelpkgs' => {
		#'description' => Msg::new("The -upgrade_kernelpkgs option has been renamed to -rollingupgrade_phase1"),
            'handler' => \&Rel::SNAS60::Common::process_ru_arg,
        },
        'upgrade_nonkernelpkgs' => {
		#'description' => Msg::new("The -upgrade_nonkernelpkgs option has been renamed to -rollingupgrade_phase2"),
            'handler' => \&Rel::SNAS60::Common::process_ru_arg,
        },
        'rolling_upgrade' => {
		#'description' => Msg::new("The -rolling_upgrade option is used to perform rolling upgrade. Using this option, installer will detect the rolling upgrade status on cluster systems automatically without the need to specify rolling upgrade phase 1 or phase 2 explicitly."),
            'handler' => \&Rel::SNAS60::Common::process_ru_arg,
        },
        'rollingupgrade_phase1' => {
		#'description' => Msg::new("The -rollingupgrade_phase1 option is used to perform rolling upgrade phase 1. During this phase, the product kernel $pdfrs will be upgraded to the latest version"),
            'handler' => \&Rel::SNAS60::Common::process_ru_arg,
        },
        'rollingupgrade_phase2' => {
		#'description' => Msg::new("The -rollingupgrade_phase2 option is used to perform rolling upgrade phase 2. During this phase, VCS and other agent $pdfrs will be upgraded to the latest version. During this phase, product kernel drivers will be rolling-upgraded to the latest protocol version."),
            'handler' => \&Rel::SNAS60::Common::process_ru_arg,
        },
        'disable_dmp_native_support' => {
		#'description' => Msg::new("The -disable_dmp_native_support option disables Dynamic multi-pathing support for the native LVM volume groups/ZFS pools during an upgrade. Retaining Dynamic multi-pathing support for the native LVM volume groups/ZFS pools during an upgrade increases package upgrade time depending on the number of LUNs and native LVM volume groups/ZFS pools configured on the system."),
            'handler' => \&Rel::SNAS60::Common::process_dmp_arg,
        },
        'snas_upgrade' => {
		#'description' => Msg::new("The -snas_upgrade option is used to perform upgrade for snas product"),
            'handler' => \&Rel::SNAS60::Common::process_snas_upgrade_arg,
        },

        # Description redefine
        'configure' => {
            'description' => Msg::new("The -configure option is used to configure an unconfigured product after it's installed"),
        },
        # EDR level options which should be hidden for SNAS
        'rsh' => {
            'undocumented' => 1,
        },
        'prod' => {
            'undocumented' => 1,
        },
        'redirect' => {
            'undocumented' => 1,
        },
        'require' => {
            'undocumented' => 1,
        },
        'timeout' => {
            'undocumented' => 1,
        },
        'serial' => {
            'undocumented' => 1,
        },
        # CPIC level options which should be hidden for SNAS
        'hotfix_path' => {
            'undocumented' => 1,
        },
        'hotfix2_path' => {
            'undocumented' => 1,
        },
        'hotfix3_path' => {
            'undocumented' => 1,
        },
        'hotfix4_path' => {
            'undocumented' => 1,
        },
        'hotfix5_path' => {
            'undocumented' => 1,
        },
        'precheck' => {
            'undocumented' => 1,
        },
        'postcheck' => {
            'undocumented' => 1,
        },
        'upgrade' => {
            'undocumented' => 1,
        },
        'hostfile' => {
            'undocumented' => 1,
        },
        'noipc' => {
            'undocumented' => 1,
        }
    };

    # Pass $rel as handler argument.
    for my $arg (keys %{$arguments}) {
        $arg_def=$arguments->{$arg};
        if (ref($arg_def) eq 'HASH' &&
            defined $arg_def->{handler} &&
            !defined $arg_def->{handler_args}) {
            $arg_def->{handler_args} = [ $rel ];
        }
    }

    # Add args which depend on platforms
    $plat=Padv::plat($rel->{padv});
    if ($plat eq 'SunOS') {
        if ($rel->{padv} =~ /^Sol11/) {
            push @{$arguments->{args_def}}, qw(ai);
        } else {
            push @{$arguments->{args_def}}, qw(jumpstart flash_archive);
        }
    } elsif ($plat eq 'AIX') {
        push @{$arguments->{args_def}}, 'nim';
    } elsif ($plat eq 'Linux') {
        if ( $rel->{padv} =~ /^RHEL/mx ) {
            push @{$arguments->{args_def}}, 'kickstart';
            push @{$arguments->{args_def}}, 'yumgroupxml';
        }
    } elsif ($plat eq 'HPUX') {
        push @{$arguments->{args_opt}}, 'ignite';
    }

    return 1;
}

sub filter_args {
    my ($rel,$args_hash,$prod)=@_;
    my ($cpic,$script,@vcs_args,@non_appha_args,@non_snas_args,@dmp_args);

    @vcs_args = qw(security securityonenode securitytrust fips addnode fencing configcps
                   upgrade_kernelpkgs upgrade_nonkernelpkgs delnode updateparameter
                   rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2);
    @non_appha_args = qw(installrecpkgs installminpkgs recpkgs minpkgs settunables tunables
                        start stop tunablesfile);
    @dmp_args = qw(disable_dmp_native_support);

    @non_snas_args = qw(start stop browserid keyfile pkgpath patchpath rootpath sshpath scppath
                        installminpkgs installrecpkgs installallpkgs installminpkgs installrecpkgs installallpkgs
                        minpkgs recpkgs allpkgs repkgs missingpkgs pkgset pkgtable pkginfo listpatches
                        disable_dmp_native_support vxunroot license logpath tmppath kickstart yumgroupxml
                        makeresponsefile comcleanup comsetup version history nolic ignorepatchreqs
                        settunables tunables tunablesfile security securityonenode securitytrust fips fencing configcps
                        nospacecheck askfile ignorechecks);

    if ($prod) {
        if (!$rel->has_vcs($prod)) {
            # remove VCS arguments for non-VCS products.
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
        }
        if (!$rel->has_vm($prod)) {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @dmp_args);
        }
        if ($prod =~ /^APPLICATIONHA/) {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @non_appha_args);
            $args_hash->{args_def}=EDRu::arrdel($args_hash->{args_def}, @non_appha_args);
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, @non_appha_args);
        }
        if ($prod =~ /^SNAS/) {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @non_snas_args);
            $args_hash->{args_def}=EDRu::arrdel($args_hash->{args_def}, @non_snas_args);
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, @non_snas_args);
        }
    } else {
        $cpic=Obj::cpic();
        $script=$cpic->{script};
        if ($script eq 'installer') {
            # need keep Rolling_upgrade related arguments for installer script.
            @vcs_args = qw(security securityonenode securitytrust fips addnode delnode updateparameter fencing configcps);
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @non_snas_args);
            $args_hash->{args_def}=EDRu::arrdel($args_hash->{args_def}, @non_snas_args);
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, @non_snas_args);
        } elsif ($script eq 'install_lp') {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @{$rel->{arguments}->{args_opt}});
        } elsif ($script=~/install(sf|fs|vm|dmp)$/m || $script=~/install(sf|fs|vm|dmp)\d.*$/m) {
            # remove VCS arguments for installer script.
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
        } elsif ($script=~/installapplicationha$/m || $script=~/installapplicationha\d.*$/m) {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @non_appha_args);
            $args_hash->{args_def}=EDRu::arrdel($args_hash->{args_def}, @non_appha_args);
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, @non_appha_args);
        } elsif ($script =~ /installsnas/m) {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @non_snas_args);
            $args_hash->{args_def}=EDRu::arrdel($args_hash->{args_def}, @non_snas_args);
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, @non_snas_args);
        }

        if ($script =~ /uninstall/m) {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, qw(updateparameter));
        }

        if ($cpic->{fromdisk}) {
            # remove install/upgrade related options if run installer script from /opt/VRTS/install
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, qw(install upgrade precheck patchupgrade hotfixupgrade));
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, qw(upgrade_kernelpkgs upgrade_nonkernelpkgs rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2 installallpkgs installminpkgs installrecpkgs));
            $args_hash->{args_def}=EDRu::arrdel($args_hash->{args_def}, qw(pkgpath hotfix_path hotfix2_path hotfix3_path hotfix4_path hotfix5_path));
        }
    }
    return 1;
}

sub has_vcs {
    my ($rel,$prod)=@_;
    $prod=~s/\d+$//;
    return 0 if (EDRu::inarr($prod, qw(FS DMP VM SF APPLICATIONHA)));
    return 1;
}

sub has_vm {
    my ($rel,$prod)=@_;
    $prod=~s/\d+$//;
    return 0 if (EDRu::inarr($prod, qw(FS VCS)));
    return 1;
}

sub process_dmp_arg {
    my ($rel,$args_hash) = @_;
    return 0;
}

sub process_snas_upgrade_arg {
    my ($rel,$args_hash) = @_;
    my $cfg = Obj::cfg();
    my $cpic = Obj::cpic();

    Cfg::set_opt('responsefile');
    $cfg->set_value('prod',"SNAS60");
    $cfg->set_value('vcs_allowcomms', 1);
    $cpic->set_prod($cfg->{prod});
    $cpic->set_task('upgrade');
    return 0;
}

sub process_security_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    for my $opt (qw(security securityonenode securitytrust fips)) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
        }
        if (Cfg::opt($opt)) {
            if ($opt_cnt>1) {
                if (($opt eq 'security') || ($opt eq 'securityonenode')) {
                    if ($opt_cnt>2 || !Cfg::opt('fips')) {
                        $msg=Msg::new("The $opt option cannot be used with other options except fips");
                        $msg->die();
                    }
                } elsif ($opt eq 'fips') {
                    if ($opt_cnt>2 || !Cfg::opt(qw(security securityonenode))) {
                        $msg=Msg::new("The $opt option can only be used with security or securityonenode");
                        $msg->die();
                    }
                } else {
                    $msg=Msg::new("The $opt option cannot be used with other options");
                    $msg->die();
                }
            }
            if ($cpic->{task} ne 'configure') {
                $cpic->set_task('configure');
            }
            if (!$rel->has_vcs($prod)) {
                $msg=Msg::new("The $opt option cannot be used with this product");
                $msg->die();
            }
        }
    }

    if (Cfg::opt('fips') && !Cfg::opt(qw(security securityonenode))){
        $msg=Msg::new("The fips option cannot be used alone, it can only be used together with security or securityonenode option");
        $msg->die();
    }

    if (Cfg::opt('securityonenode') && $cfg->{systems}) {
        $msg=Msg::new("The securityonenode option can only be used with the local system.");
        $msg->die();
    }
    return 0;
}

sub process_fencing_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$option,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    if (Cfg::opt(qw(fencing configcps))) {
        $option = Cfg::opt('configcps') ? 'configcps' : 'fencing';
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
        }
        if ($opt_cnt>1) {
            $msg=Msg::new("The $option option cannot be used with other options");
            $msg->die();
        } elsif ($cpic->{task} ne 'configure') {
            $cpic->set_task('configure');
        }
        if (!$rel->has_vcs($prod)) {
            $msg=Msg::new("The $option option cannot be used with this product");
            $msg->die();
        }
    }
    return 0;
}

sub process_addnode_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    if (Cfg::opt('addnode')) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
            $opt_cnt-- if (Cfg::opt('ssh'));
        }
        if ($opt_cnt>1) {
            $msg=Msg::new("The addnode option cannot be used with other options");
            $msg->die();
        } elsif ($cpic->{task} ne 'configure') {
            $cpic->set_task('configure');
        }
        if (!$rel->has_vcs($prod)) {
            $msg=Msg::new("The addnode option cannot be used with this product");
            $msg->die();
        }

        $rel->silent_addnode_preconfig();
    }
    return 0;
}

sub silent_addnode_preconfig {
    my ($rel) = @_;
    my ($conf, $localsys, $msg);
    my $edr = Obj::edr();
    my $cpic= Obj::cpic();
    my $cfg = Obj::cfg();
    my $vcs = $rel->prod('VCS61');

    Cfg::set_opt('responsefile');
    $cfg->set_value('prod',"SNAS60");
    $cfg->set_value('vcs_allowcomms', 1);
    $cpic->set_prod($cfg->{prod});
    if ($cfg->{systems}) {
        @{$cfg->{systems}} = split(/,/, $cfg->{systems}[0]) if($cfg->{systems}[0] =~ /,/);
        $cfg->{newnodes} = $cfg->{systems};
    } else {
        $msg=Msg::new("The IP of the node you want to add is missing");
        $msg->die();
    }
    # Addnode for SNAS will only be executed in the cluster,
    # so the cluster information can be get via local system
    $localsys = $edr->{localsys};
    $conf = $vcs->get_config_sys($localsys);
    if ($conf){
        $cfg->{clustersystems} = $conf->{systems};
    } else {
        $msg=Msg::new("Cluster configuration information checking failed on $localsys->{sys}");
        $msg->die();
    }
}

sub process_delnode_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    if (Cfg::opt('delnode')) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
            $opt_cnt-- if (Cfg::opt('ssh'));
        }
        if ($opt_cnt>1) {
            $msg=Msg::new("The delnode option cannot be used with other options");
            $msg->die();
#        } elsif ($cpic->{task} ne 'configure') {
#            $cpic->set_task('configure');
        }
        if (!$rel->has_vcs($prod)) {
            $msg=Msg::new("The delnode option cannot be used with this product");
            $msg->die();
        }
    }
    if (!$cfg->{systems}) {
        $msg=Msg::new("The name of the node you want to delete is missing");
        $msg->die();
    }
    @{$cfg->{systems}} = split(/,/, $cfg->{systems}[0]) if($cfg->{systems}[0] =~ /,/);
    Cfg::set_opt('responsefile');
    $cfg->set_value('prod',"SNAS60");
    $cfg->set_value('vcs_allowcomms', 1);
    $cpic->set_prod($cfg->{prod});
    return 0;
}

sub process_updateparameter_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    if (Cfg::opt('updateparameter')) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
            $opt_cnt-- if (Cfg::opt('ssh'));
        }
        if ($opt_cnt>1) {
            $msg=Msg::new("The updateparameter option cannot be used with other options");
            $msg->die();
        } elsif ($cpic->{task} ne 'configure') {
            $cpic->set_task('configure');
        }
        if (!$rel->has_vcs($prod)) {
            $msg=Msg::new("The updateparameter option cannot be used with this product");
            $msg->die();
        }
    }
    return 0;
}

sub process_ru_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$opt,$cpic,$ru_opt_cnt);
    $cpic=Obj::cpic();
    $ru_opt_cnt=0;
    if (defined $args_hash->{options}) {
        $ru_opt_cnt=scalar @{$args_hash->{options}};
    }

    # In cmd options 'upgrade_kernelpkgs'&'upgrade_nonkernelpkgs' are filtered before because they are
    # not valid options anymore
    if(Cfg::opt("responsefile") && Cfg::opt("upgrade_kernelpkgs") && !Cfg::opt("rollingupgrade_phase1")){
        $msg=Msg::new("The -upgrade_kernelpkgs has been renamed to -rollingupgrade_phase1");
        $msg->die();

    } elsif(Cfg::opt("responsefile") && Cfg::opt("upgrade_nonkernelpkgs") && !Cfg::opt("rollingupgrade_phase2")){
        $msg=Msg::new("The -upgrade_nonkernelpkgs has been renamed to -rollingupgrade_phase2");
        $msg->die();
    }

    for my $opt (qw(rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2)) {
        next unless (Cfg::opt($opt));
        $ru_opt_cnt-- if(Cfg::opt('upgrade'));
        $ru_opt_cnt-- if(Cfg::opt('serial'));
        $ru_opt_cnt-- if(Cfg::opt('noipc'));
        $ru_opt_cnt-- if(Cfg::opt('makeresponsefile'));
        $ru_opt_cnt-- if(Cfg::opt('disable_dmp_native_support'));
        if ($ru_opt_cnt>1) {
            $msg=Msg::new("The $opt option can be only used with upgrade and serial option");
            $msg->die();
        }
        if(Cfg::opt("rollingupgrade_phase1")) {
            Cfg::set_opt("rolling_upgrade");
            Cfg::set_opt("upgrade_kernelpkgs");
        }
        if(Cfg::opt("rollingupgrade_phase2")) {
            Cfg::set_opt("rolling_upgrade");
            Cfg::set_opt("upgrade_nonkernelpkgs");
        }
        $cpic->set_task('upgrade') unless (Cfg::opt('upgrade'));
    }
    return 0;
}

sub process_jumpstart_arg {
    my ($rel) = @_;
    my ($cfg,$edr,$err,$msg);

    $cfg = Obj::cfg();
    $edr = Obj::edr();
    if (Cfg::opt('jumpstart')) {
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-jumpstart: cannot be used from local disk");
            $msg->warning;
            $err++;
        } elsif (! -d "$cfg->{opt}{jumpstart}") {
            $msg=Msg::new("-jumpstart: the specified directory $cfg->{opt}{jumpstart} should be available and writable");
            $msg->warning;
            $err++;
        } else {
            $cfg->{opt}{jumpstart}=~ s/\/$//m if ($cfg->{opt}{jumpstart} ne '/');
            $rel->jumpstart();
            $edr->exit_noexitfile();
        }
    }
    return $err;
}

sub process_flash_archive_arg {
    my ($rel) = @_;
    my ($cfg,$edr,$err,$msg);
    $cfg = Obj::cfg();
    $edr = Obj::edr();
    if (Cfg::opt('flash_archive')) {
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-flash_archive: cannot be used from local disk");
            $msg->warning;
            $err++;
        } elsif (! -d "$cfg->{opt}{flash_archive}") {
            $msg=Msg::new("-flash_archive: the specified directory $cfg->{opt}{flash_archive} should be available and writable");
            $msg->warning;
            $err++;
        } else {
            $cfg->{opt}{flash_archive}=~ s/\/$//m if ($cfg->{opt}{flash_archive} ne '/');
            $rel->flash_archive();
            $edr->exit_noexitfile();
        }
    }
    return $err;
}

sub process_ai_arg {
    my ($rel) = @_;
    my ($cfg,$edr,$err,$msg);
    $cfg = Obj::cfg();
    $edr = Obj::edr();
    if (Cfg::opt('ai')) {
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-ai: cannot be used from local disk");
            $msg->warning;
            $err++;
        } elsif (! -d "$cfg->{opt}{ai}") {
            $msg=Msg::new("-ai: the specified directory $cfg->{opt}{ai} should be available and writable");
            $msg->warning;
            $err++;
        } else {
            $cfg->{opt}{ai}=~ s/\/$//m if ($cfg->{opt}{ai} ne '/');
            $rel->ai();
            $edr->exit_noexitfile();
        }
    }
    return $err;
}

sub process_kickstart_arg {
    my ($rel) = @_;
    my ($cfg,$edr,$err,$msg);

    $cfg = Obj::cfg();
    $edr = Obj::edr();
    if (Cfg::opt('kickstart')) {
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-kickstart: cannot be used from local disk");
            $msg->warning;
            $err++;
        } elsif (! -d "$cfg->{opt}{kickstart}") {
            $msg=Msg::new("-kickstart: the specified directory $cfg->{opt}{kickstart} should be available and writable");
            $msg->warning;
            $err++;
        } else {
            $cfg->{opt}{kickstart}=~ s/\/$//m if ($cfg->{opt}{kickstart} ne '/');
            $rel->kickstart();
            $edr->exit_noexitfile();
        }
    }
    return $err;
}

sub process_yumgroupxml_arg {
    my ($rel) = @_;
    my ($cfg,$edr,$err,$msg);

    $cfg = Obj::cfg();
    $edr = Obj::edr();
    if (Cfg::opt('yumgroupxml')) {
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-yumgroupxml: cannot be used from local disk");
            $msg->warning;
            $err++;
        } elsif (! -d "$cfg->{opt}{yumgroupxml}") {
            $msg=Msg::new("-yumgroupxml: the specified directory $cfg->{opt}{yumgroupxml} should be available and writable");
            $msg->warning;
            $err++;
        } else {
            $cfg->{opt}{yumgroupxml}=~ s/\/$//m if ($cfg->{opt}{yumgroupxml} ne '/');
            $rel->yumgroupxml();
            $edr->exit_noexitfile();
        }
    }
    return $err;
}

sub process_nim_arg {
    my ($rel) = @_;
    my ($edr,$err,$msg);

    $edr = Obj::edr();
    if (Cfg::opt('nim')) {
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-nim: cannot be used from local disk");
            $msg->warning;
            $err++;
        } else {
            $rel->nim();
            $edr->exit_noexitfile();
        }
    }
    return $err;
}

sub process_ignite_arg {
    my ($rel,$args_hash) = @_;
    my ($cpic,$edr,$err,$msg,$opt_cnt);

    $edr = Obj::edr();
    $cpic = Obj::cpic();
    if (Cfg::opt('ignite')) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
        }
        if ($edr->{fromdisk}) {
            $msg=Msg::new("-ignite: cannot be used from local disk");
            $msg->warning;
            $err++;
        } elsif ($opt_cnt>1) {
            $msg=Msg::new("The ignite option cannot be used with other options");
            $msg->warning();
            $err++;
        } else {
            $edr->create_local_tempdir();
            $rel->ignite();
            $edr->{savelog}=1;
            $cpic->completion();
            return '';
        }
    }
    return $err;
}

sub config_without_reboot_message {
    my ($rel) = @_;
    my ($cpic,$installscript,$msg,$prod,$web,$padv,$tunablesfile);

    $cpic=Obj::cpic();
    return unless ($cpic->{prod});
    $prod=$cpic->prod;

    # skip configure message if LP or MLP
    return '' if (Cfg::opt(qw(upgrade)) &&
                  $prod->{lp} || $prod->disableconfig());
    return unless ($prod->can(CPIC::upgrade_sub('configure_sys')));
    if ((Cfg::opt(qw(install))) && (!Cfg::opt('configure')) && (!Cfg::opt('addnodeinstall'))) {
        $installscript= 'install' . lc($prod->{installscript_name} || $prod->{prod}) . $rel->get_local_script_version_suffix();
        if (Cfg::opt('rootpath')) {
            $msg=Msg::new("$prod->{name} cannot be started without configuration.\n\nRun the '/opt/VRTS/install/$installscript -configure' command after boot from the alternate root disk.\n");
        } elsif (Cfg::opt('tunablesfile')) {
            $tunablesfile=Cfg::opt('tunablesfile');
            $msg=Msg::new("$prod->{name} cannot be started without configuration.\n\nRun the '/opt/VRTS/install/$installscript -tunablesfile $tunablesfile -configure' command when you are ready to configure $prod->{name}.\n");
        } else {
            $msg=Msg::new("$prod->{name} cannot be started without configuration.\n\nRun the '/opt/VRTS/install/$installscript -configure' command when you are ready to configure $prod->{name}.\n");
        }
        $msg->print;

        $web=Obj::web();
        $msg=Msg::new("$prod->{name} cannot be started without configuration.\nStart webinstaller and select the task 'configure a product' when you are ready to configure $prod->{name}.\n");
        $web->web_script_form('alert',$msg) if (Obj::webui());

        if (!$cpic->{donotsettunables} && $cpic->{valid_tunables_poststart} && @{$cpic->{valid_tunables_poststart}}) {
            my $skipped_tunables = join("\n\t", @{EDRu::arruniq(sort map({$_->[0]} @{$cpic->{valid_tunables_poststart}}))});
            $msg=Msg::new("The following tunable parameter(s) were not set because they must be set after $prod->{name} is started: \n\t$skipped_tunables\n");
            $msg->print;
        }
    }
    return '';
}

sub reboot_messages {
    my ($rel) = @_;
    my ($cpic,$installscript,$msg,$padv,$pdfrs,$prod,$sys,$systems,$web,$patches,$pkgs,$reboot_msg,$install_failed,$skip_reboot_start_msg,$tunables,$rollingupgrade);

    $cpic=Obj::cpic();
    return unless ($cpic->{prod});
    # skip reboot message if LP or MLP
    return '' if (Cfg::opt(qw(upgrade)) && ($prod->{lp}));
    return unless (@{$cpic->{reboot_systems}});
    $rollingupgrade=1 if(Cfg::opt(qw(upgrade_kernelpkgs upgrade_nonkernelpkgs)));
    $prod=$cpic->prod;
    $reboot_msg='';
    $pdfrs=Msg::get('pdfrs');
    for my $sys (@{$cpic->{systems}}) {
        if ($sys->{encap} && Cfg::opt(qw(upgrade patchupgrade hotfixupgrade))) {
            $msg=Msg::new("The boot disk of $sys->{sys} is encapsulated. It is required to reboot the machine after upgrade.\n\n");
            $reboot_msg.=$msg->{msg};
        }
        if (defined $sys->{requirerebootpkgs}) {
            $pkgs=join(' ', @{$sys->{requirerebootpkgs}});
            $msg=Msg::new("The following $pdfrs require reboot while installing them on $sys->{sys}:\n\t$pkgs\n\n");
            $reboot_msg.=$msg->{msg};
        }
        if (defined $sys->{requirerebootpatches}) {
            $patches=join(' ', @{$sys->{requirerebootpatches}});
            $msg=Msg::new("The following patches require reboot while installing them on $sys->{sys}:\n\t$patches\n\n");
            $reboot_msg.=$msg->{msg};
        }
        if (defined $sys->{requirereboottunables}) {
            $tunables=join("\n\t", @{$sys->{requirereboottunables}});
            $msg=Msg::new("The following tunables require reboot to take effect on $sys->{sys}:\n\t$tunables\n\n");
            $reboot_msg.=$msg->{msg};
        }
        if (defined $sys->{kdumpreboot}) {
            $msg=Msg::new("kdump is configured on $sys->{sys}, but requires reboot to take effect.\n");
            $reboot_msg.=$msg->{msg};
        }
        if (defined $sys->{kdumpfailed}) {
            $msg=Msg::new("kdump failed to start on $sys->{sys}. Manually check kdump configuration before reboot.\n");
            $reboot_msg.=$msg->{msg};
        }
    }
    $systems=join("\n\t", @{$cpic->{reboot_systems}});
    $padv=Obj::padv($cpic->{padv});
    $msg=Msg::new("It is strongly recommended to reboot the following systems:\n\t$systems\n\nExecute '$padv->{cmd}{shutdown}' to properly restart your systems");
    $reboot_msg.=$msg->{msg};
    if (Cfg::opt(qw(configure upgrade))) {
        if (defined($cpic->{require_start_after_reboot_systems})
            && (@{$cpic->{require_start_after_reboot_systems}})) {
            $systems=join(' ', @{$cpic->{require_start_after_reboot_systems}});
            $installscript= 'install' . lc($prod->{installscript_name} || $prod->{prod}) . $rel->get_local_script_version_suffix();
            if ($prod->check_config()) {
                $msg=Msg::new("\n\nAfter reboot, run the '/opt/VRTS/install/$installscript -start $systems' command to start $prod->{name}");
            } else {
                $msg=Msg::new("\n\nAfter reboot, run the '/opt/VRTS/install/$installscript -configure $systems' command to configure $prod->{name}");
            }
            $reboot_msg.=$msg->{msg};
        }
    }
    if (Cfg::opt(qw(upgrade patchupgrade hotfixupgrade))) {
        $install_failed = 0;
        for my $sys (@{$cpic->{systems}}) {
            $install_failed=1 if ( (defined ($sys->{pkginstallfail}) && @{$sys->{pkginstallfail}})   ||
                                   (defined ($sys->{patchinstallfail}) && @{$sys->{patchinstallfail}}) );
            # No need to print the install -start message if upgrade with encapsulated bootdisk
            # and system has no VVR configuration
            $skip_reboot_start_msg=1 if (($sys->{encap}||$rollingupgrade) && !$sys->{rvg});
        }
        if ( $install_failed ) {
            $systems=join(' ', @{$cpic->{reboot_systems}});
            $msg=Msg::new("\n\nUpgrade was not successful on $systems. Fix the error(s) and retry after reboot");
            $reboot_msg.=$msg->{msg};
        } else {
            # only if parts of the systems need reboot, use -start to start all systems.
            if ($#{$cpic->{reboot_systems}} != $#{$cpic->{systems}}) {
                $systems=join(' ', map { $_->{sys} } @{$cpic->{systems}});
                $installscript= 'install' . lc($prod->{installscript_name} || $prod->{prod}) . $rel->get_local_script_version_suffix();
                if ($prod->check_config()) {
                    $msg=Msg::new("\n\nAfter reboot, run the '/opt/VRTS/install/$installscript -start $systems' command to start $prod->{name}");
                } else {
                    $msg=Msg::new("\n\nAfter reboot, run the '/opt/VRTS/install/$installscript -configure $systems' command to configure $prod->{name}");
                }
                $reboot_msg.=$msg->{msg} unless($skip_reboot_start_msg);
            }
        }
    }
    # prompt help message for start failure
    if (@{$cpic->failures('startfailmsg')}) {
        $msg = Msg::new("\n\nIt is likely that the startup failure issues will be resolved after rebooting the system. If issues persist after reboot, contact Symantec technical support or refer to installation guide for further troubleshooting.");
        $reboot_msg .= $msg->{msg};
    }

    Msg::display_bold($reboot_msg);
    if (Obj::webui()) {
        $web=Obj::web();
        $reboot_msg=~s/\n/\\n/g;
        $web->web_script_form('rebootmsg',$reboot_msg);
    }
    return '';
}

sub conflict_prod {
    my ($rel,$prodA,$prodB)=@_;
    return 1 if (EDRu::inarr($prodA->{prod},@{$rel->{conflict_prod_matrix}{$prodB->{prod}}}));
    return 0;
}

sub upgrade_prod_mix_check {
    my ($rel) = @_;

    # check upgrade status for SFHA products, like VCS/SF/SFHA/SFCFS/SFRAC.
    my $rtn=$rel->upgrade_sfha_prods_mix_check();

    # check upgrade status for other Symantec products, like NetBackup/VOM/ApplicationHA/CCS/ER
    $rtn=$rel->upgrade_symantec_prods_mix_check() || $rtn;
    return $rtn;
}

# Checks for various upgrade prod cases (it's here as we need right product for fsspace and ospatch checks)
# otherwise we set stop_checks
sub upgrade_sfha_prods_mix_check {
    my ($rel) = @_;
    my (@sys_prod_map,$cpic,$edr,$prod,$prev_prod,$prev_prodvers,$msg,$sys,$sys_prod_map,$prodname,
        $prodmix_flag,$versmix_flag,$nocurrentvers_flag,$prodvers,$relvers,$cprod,
        $upgrade_prod,$cprod_name,$prod_value_join,$cmpvers,$ayn,$cfg,$task_set,$format,
        $msg_pi, $msg_pv, $msg_sn,$msg_np, $msg_none,$ru_check_flag,$ru_prods,
        $patchupgrade_flag,$obsoleted_product_upgrade_flag,$mix_partial_upgrade,
        $upgrade_status,$index,$lprod,$prodobj,$cprod_installed,$upgrade_from_vers,$cv,$veki);

    $cfg=Obj::cfg();
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $relvers=$rel->{titlevers};
    $task_set=0;

    if ($cpic->{prod}) {
        $prod=$cpic->prod;
        $cprod = $cpic->{prod};
        $cprod_name = $prod->{abbr};
    }

    # If installer is killed during main release package installations (when doing SP combo install),
    # in resume it's detected as an upgrade. To avoid, this skip condition is added
    return '' if ($edr->{exitfile} && Cfg::opt('install'));

    # skip upgrade_prod_mix_check for LP, since no mix upgrade for LP
    return '' if ($cprod_name && $cprod_name eq 'LP');

    # only check prod mix status for precheck/install/upgrade/patchupgrade/hotfixupgrade
    return '' unless (Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade)));

    # Creating the sys-prod map to display in the message.
    $format = '%-17s - %-15s - %-s';
    $msg_pi = Msg::new("Product Installed")->{msg};
    $msg_pv = Msg::new("Product Version")->{msg};
    $msg_sn = Msg::new("System Name")->{msg};
    $msg_np     = Msg::new("None")->{msg};
    $msg_none   = Msg::new("None")->{msg};
    push(@sys_prod_map, Msg::string_sprintf($format, $msg_pi, $msg_pv, $msg_sn));
    for my $sys (@{$cpic->{systems}}) {
        return '' if ($sys->{stop_checks});
        $upgrade_prod = ${$sys->{upgradeprod_abbr}}[0];
        $upgrade_prod =~ s/\d//mg;
        $prodname   = $upgrade_prod || $msg_np;
        $prodvers   = ${$sys->{prodvers}}[0] || $msg_none;
        push(@sys_prod_map, Msg::string_sprintf($format, $prodname, $prodvers, $sys->{sys}));
    }

    $sys_prod_map=join("\n", @sys_prod_map);

    for my $sys (@{$cpic->{systems}}) {
        $prodmix_flag=$rel->determine_prodmix_upgrade($prev_prod,${$sys->{upgradeprod}}[0],$sys);
        $versmix_flag=$rel->determine_versmix_upgrade($prev_prod,${$sys->{upgradeprod}}[0],$prev_prodvers,${$sys->{prodvers}}[0],$sys);
        #$prev_prodvers && ${$sys->{prodvers}}[0] && EDRu::compvers(${$sys->{prodvers}}[0],$prev_prodvers,2));
        #$ru_check_flag=1 if (!EDRu::inarr(${$sys->{upgradeprod}}[0],@{$rel->{ru_prod}}) && Cfg::opt(qw(upgrade_kernelpkgs upgrade_nonkernelpkgs)));
        $nocurrentvers_flag=0;
        $patchupgrade_flag=0;
        $obsoleted_product_upgrade_flag=0;
        $cprod_installed=0;
        $mix_partial_upgrade=0;

        $index=EDRu::arrpos($cprod,@{$sys->{upgradeprod}});
        $cprod_installed=1 if ($index>=0);
        $index= ($index>=0) ? $index : 0;
        $prodname=$sys->{upgradeprod}[$index];
        if ($prodname) {
            $prodobj=$sys->prod($prodname);
            $cmpvers=$prodobj->{vers};
            $task_set = $nocurrentvers_flag = $rel->upgrade_sfha_check_sys($sys,$prodobj,$index);
            $cv = EDRu::compvers(${$sys->{prodvers}}[$index],$cmpvers,4);
            $nocurrentvers_flag = 1 if ($cv);
            if ($nocurrentvers_flag) {
                $upgrade_from_vers = $sys->{lower_vers} || ${$sys->{prodvers}}[$index];
                $patchupgrade_flag=1 if (!EDRu::compvers($upgrade_from_vers,$cmpvers,2) && $rel->{patches});
            }
            # $nocurrentvers_flag |= $rel->upgrade_sfha_check_sys($sys,$prodobj,$index);
        }

        $prodname=$sys->{upgradeprod}[0];
        if ($prodname) {
            $prodobj=$sys->prod($prodname);
            $obsoleted_product_upgrade_flag=1 if ($prodobj->{obsoleted});
            $upgrade_prod = $prodobj->{abbr};
        }

        # Checking if the product installed on the system is obsoleted in current release, like SFCFSRAC.
        if ($obsoleted_product_upgrade_flag==1 && $nocurrentvers_flag) {
            $prod_value_join="$upgrade_prod".' '."${$sys->{prodvers}}[0]";
            if ($cprod_name eq $upgrade_prod) {
                $msg = Msg::new("$prod_value_join was installed on $sys->{sys}. A direct upgrade from $upgrade_prod is not supported. Uninstall $prod_value_join and perform a fresh installation of $relvers product.");
            } else {
                $msg = Msg::new("$prod_value_join was installed on $sys->{sys}. A direct upgrade from $upgrade_prod to $cprod_name $relvers is not supported. Uninstall $prod_value_join and perform a fresh installation of $cprod_name $relvers.");
            }
            $sys->push_error($msg);
            set_value_allsys('stop_checks',1);
            return '';
        }

        # Checking if the product installed on the system is AppHA + Prod(contains VCS).
        if($rel->determine_prodmix_install($cpic->{prod},${$sys->{upgradeprod}}[0],$sys)) {
            $msg=Msg::new("$upgrade_prod is installed on $sys->{sys}. $cprod_name and $upgrade_prod cannot be installed together.");
            $sys->push_error($msg);
            set_value_allsys('stop_checks',1);
            return '';
        }

        $sys->set_value('partial_upgrade', 0);
        $upgrade_status = $rel->determine_cross_partial_upgrade($cprod,$sys->{upgradeprod});
        $prev_prod=$sys->{upgradeprod}[0];
        $prev_prodvers=$sys->{prodvers}[0];

        # Checking if the same product is upgraded on all the systems
        if ($prodmix_flag && $nocurrentvers_flag) {
            $msg=Msg::new("Entered systems have different products installed:\n$sys_prod_map\nSystems running different products must be upgraded independently");
            $sys->push_error($msg);
            set_value_allsys('stop_checks',1);
            return '';
        }

        # Checking if the same product version is installed on all the systems for upgrade
        if ($versmix_flag) {
            $msg=Msg::new("Entered systems have different versions of $cprod_name installed:\n$sys_prod_map\n Systems running different product versions must be upgraded independently");
            $sys->push_error($msg);
            set_value_allsys('stop_checks',1);
            return '';
        }

        # Pradnesh : block below needs modification
        # Checking if the product installed on the system is subset of product given through menu/install<prod> script.
        if (($upgrade_status eq 'prohibited_upgrade') && $nocurrentvers_flag) {
            $prod_value_join="$upgrade_prod".' '."${$sys->{prodvers}}[0]";
            $msg = Msg::new("$prod_value_join is installed. Upgrading $prod_value_join directly to $cprod_name $relvers is not supported. \n$sys_prod_map\nFirst run 'installer -upgrade' to upgrade product to $upgrade_prod $relvers and then run installer to install $cprod_name.");
            $sys->push_error($msg);
            set_value_allsys('stop_checks',1);
            return '';
        }

        # upsell
        if ($cpic->{prod} && $prev_prod && $prev_prodvers) {
            if ((EDRu::compvers($prev_prodvers,$sys->prod($prev_prod)->{vers},4)==0) &&
                (!$rel->determine_upsell_supported($upgrade_prod,$prod->{prod}))) {
                set_value_allsys('stop_checks',1);
                $msg = Msg::new("$sys_prod_map\nInstallation of $prod->{abbr} is not supported as $upgrade_prod is installed.");
                $sys->push_error($msg);
                return '';
            }
            if (EDRu::compvers($prev_prodvers,$sys->prod($prev_prod)->{vers},4)==0 && $rel->check_upsell_supported($sys->prod($prev_prod)->{abbr}, $prod->{abbr})) {
                $sys->{can_upsell} = 1;

            }
            # forbid the upsell path when running install<prod> with -upgrade option.
            if (!$nocurrentvers_flag && Cfg::opt('upgrade') && $cpic->{prod} ne $prev_prod) {
                set_value_allsys('stop_checks',1);
                $lprod=lc($prod->{prod});
                $msg = Msg::new("$sys_prod_map\nInstallation of $prod->{abbr} is not supported using install$lprod script with -upgrade option. Run 'install$lprod -install' to complete the task.");
                $sys->push_error($msg);
                return '';
            }
        }

        if (($upgrade_status eq 'cross_upgrade') && $nocurrentvers_flag) {
            $prod_value_join="$upgrade_prod".' '."${$sys->{prodvers}}[0]";
            $msg = Msg::new("$prod_value_join is installed on $sys->{sys}. To proceed with installation will upgrade $prod_value_join directly to $cprod_name $relvers on $sys->{sys}.");
            $sys->push_warning($msg);
        }

        if (($upgrade_status eq 'cross_install') && $nocurrentvers_flag) {
            $prod_value_join="$upgrade_prod".' '."${$sys->{prodvers}}[0]";
            $msg = Msg::new("$prod_value_join is installed on $sys->{sys}. To proceed with installation will install $cprod_name $relvers directly on $sys->{sys}.");
            $sys->push_warning($msg);
        }

        # Checking if the product installed on the system is superset of product given through menu/install<prod> script.
        if (($upgrade_status eq 'partial_upgrade') && $nocurrentvers_flag) {
            #For expample,$sys->{prodvers} arranged by SFHA,SF,VCS,VM,DMP,FS
            #$sys->{prodvers}[0] as the main product version is been used for verify whether partial upgrade more times
            for my $prodver (@{$sys->{prodvers}}) {
                if ($sys->{prodvers}[0]!= $prodver) {
                    $mix_partial_upgrade = 1;
                    last;
                }
            }
            if ($mix_partial_upgrade) {
                $msg = Msg::new("$cprod_name is a subset of $upgrade_prod. Upgrading only $cprod_name will partially upgrade the installed packages on the systems.\nRun 'installer -upgrade' for a complete upgrade.");
                $sys->set_value('mix_partial_upgrade',1);
            } else {
                $prod_value_join="$upgrade_prod".' '."${$sys->{prodvers}}[0]";
                $msg = Msg::new("$prod_value_join is installed on $sys->{hostname}. $cprod_name is a subset of $upgrade_prod. Upgrading only $cprod_name will partially upgrade the installed packages on the systems.\n$sys_prod_map\nRun 'installer -upgrade' for a complete upgrade.");
            }
            $sys->set_value('partial_upgrade', 1);
            $sys->push_warning($msg);
        }

        if ($sys->aix() && ($task_set || $sys->{partial_upgrade})) {
            $veki=$sys->pkg('VRTSveki61');
            if ($veki && $veki->version_sys($sys)) {
                $veki->{donotinstall}=1;
                $veki->{donotrmonupgrade}=1;
            }
        }
    }

    # Set upgradeprod for upsell install.
    unless ($prodmix_flag) {
        $cpic->set_value('upgradeprod',$prev_prod);
    }

    if ( ($cv == 2) && $nocurrentvers_flag && !Cfg::opt('upgrade') && ($upgrade_status ne 'cross_install') && $cprod_installed) {
        # here we unset install and set upgrade if we detect it's upgrade instead of install
        # if latest version is installed and we are installing extra pkgs only then it isn't considered upgrade
        if (Cfg::opt('install')) {
            if (Cfg::opt('responsefile')) {
                # 2794010: should block using install responsefile to upgrade a product
                $sys=${CPIC::get('systems')}[0];
                $msg=Msg::new("Cannot upgrade $cprod_name product because upgrade task is not set in the responsefile. Instead, install task is set in the responsefile. Check if the response file is correct for upgrade.");
                $sys->push_error($msg);
                set_value_allsys('stop_checks',1);
                return '';
            } else {
                $cpic->set_task('upgrade');
            }
        } elsif (Cfg::opt('precheck')) {
            $cpic->set_task('upgrade');
            Cfg::set_opt('precheck',1);
        }
        $task_set=1;
    }

    if (Cfg::opt('precheck')) {
        if (!EDRu::inarr('install',@{$rel->{args_task}})) {
            $cpic->set_task('patchupgrade');
            $task_set=1;
        } elsif ($patchupgrade_flag) {
            $cpic->set_task('patchupgrade');
            $task_set=1;
        }
        Cfg::set_opt('precheck',1);
    } elsif (Cfg::opt('upgrade')) {
        if (!$cprod_installed) {
            $msg=Msg::new("Cannot upgrade $cprod product because it is not installed on your system.");
            $msg->die;
        } elsif ($patchupgrade_flag) {
            $cpic->set_task('patchupgrade');
            $task_set=1;
        }
    }

    for my $sys (@{$cpic->{systems}}){
        $task_set=1 if ($sys->{skip_versioncheck});
    }
    $prod->set_pkgs() if (Cfg::opt(qw(upgrade patchupgrade hotfixupgrade)) && ($cpic->{prod}));
    if ($cpic->{prod}) {
        $ru_check_flag=$rel->determine_rolling_upgrade($cpic->{prod});
        $sys=@{$cpic->{systems}}[0];
        if ($ru_check_flag eq '0') {
            if (Cfg::opt('upgrade_kernelpkgs')){
                set_value_allsys('stop_checks',1);
                $msg = Msg::new("To perform rolling upgrade phase 1, make sure all the systems have not completed a rolling upgrade procedure");
                $sys->push_error($msg);
            } elsif (Cfg::opt('upgrade_nonkernelpkgs')){
                set_value_allsys('stop_checks',1);
                $msg = Msg::new("To perform rolling upgrade phase 2, make sure all the systems have completed rolling upgrade phase 1");
                $sys->push_error($msg);
            }
        } elsif( $ru_check_flag eq '-1') {
            set_value_allsys('stop_checks',1);
            $ru_prods=join(' ',@{$rel->{ru_prod}});
            $ru_prods=~s/\d+//mg;
            $msg = Msg::new("$prod->{abbr} is installed. Rolling upgrade is only supported from $rel->{ru_version} to higher versions of the products $ru_prods.");
            $sys->push_error($msg);
        }
    }

    return $task_set ? '1' : '';
}

sub upgrade_sfha_check_sys {
    my ($rel,$sys,$prod,$index)=@_;
    my($msg,$cmpvers,$sfvers,$vcsvers);
    my $cpic = Obj::cpic();
    # if cprod is SFHA, (index+1) is SF and (index+2) is VCS
    return "" unless ($prod->{prod}=~/SFHA/);
    return 0 if(Cfg::opt("upgrade_nonkernelpkgs"));
    $cmpvers = $prod->{vers};
    $sfvers = ${$sys->{prodvers}}[($index+1)];
    $vcsvers = ${$sys->{prodvers}}[($index+2)];
    if (!EDRu::compvers($sfvers,$cmpvers,3) && EDRu::compvers($vcsvers,$cmpvers,3)) {
        $sys->{noconfig_sf}=1;
        $sys->{prod_to_upgrade}=$prod->prod('VCS61');
        $sys->{lower_vers}=$vcsvers;
        Obj::cpic()->set_task('upgrade');
        $msg = Msg::new("SF $sfvers and VCS $vcsvers are installed on $sys->{sys}. Only VCS $vcsvers will be upgraded.");
        $sys->push_warning($msg);
        return 1;
    }
    if (!EDRu::compvers($vcsvers,$cmpvers,3) && EDRu::compvers($sfvers,$cmpvers,3)) {
        $sys->{noconfig_vcs}=1;
        $sys->{prod_to_upgrade}=$prod->prod('SF61');
        $sys->{lower_vers}=$sfvers;
        $prod->prod('VCS61')->set_vcs_allowcomms_sys($sys);
        $cpic->set_task('upgrade');
        $msg = Msg::new("SF $sfvers and VCS $vcsvers are installed on $sys->{sys}. Only SF $sfvers will be upgraded.");
        $sys->push_warning($msg);
        return 1;
    }
    return 0;
}

sub upgrade_symantec_prods_mix_check {
    my ($rel) = @_;
    my ($cpic,$rtn);

    $cpic=Obj::cpic();
    return '' unless (Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade uninstall)));
    $rtn='';
    for my $sys (@{$cpic->{systems}}) {
        # Check NetBackup
        $rtn=$rel->check_netbackup_compatibility_sys($sys) || $rtn;

        # Check VOM
        $rtn=$rel->check_vom_compatibility_sys($sys) || $rtn;
    }
    return $rtn;
}

# Check whether NetBackup product installed or not
sub netbackup_sys {
    my ($rel,$sys) = @_;
    my ($rootpath,$vers);
    $rootpath=Cfg::opt('rootpath')||'';
    if ($sys->exists("$rootpath/usr/openv/netbackup/version")) {
       $vers=$sys->cmd("_cmd_grep VERSION $rootpath/usr/openv/netbackup/version | _cmd_awk '{print \$3}'");
    } elsif ($sys->exists("$rootpath/usr/openv/netbackup/bin/version")) {
       $vers=$sys->cmd("_cmd_cat $rootpath/usr/openv/netbackup/bin/version | _cmd_awk '{print \$2}'");
    }
    if ($vers) {
        $sys->set_value('pkgvers,NetBackup', $vers);
        return $vers;
    }
    return '';
}

# Check whether VOM/SFM CS product installed or not
sub vomcs_sys {
    my ($rel,$sys) = @_;
    my ($vers,$cspkg);
    # SFM/VOM CS mainpkg is VRTSsfmcs.
    $cspkg=Pkg::new_pkg('Pkg', 'VRTSsfmcs', $sys->{padv});
    $vers=$cspkg->version_sys($sys);
    if ($vers) {
        $sys->set_value('pkgvers,SFMCS', $vers);
        return $vers;
    }
    return '';
}

sub check_tunable_info_sys {
    my ($rel,$sys,$tunable_info) = @_;
    my ($cpic,$vm);
    $cpic=Obj::cpic();
    $vm=$cpic->prod("VM61");

    # For dmp_native_support, we need to check $sys to determine if the reboot value needs to be changed
    # dmp_native_support only exists in has VM products.
    if ($tunable_info->{name} eq 'dmp_native_support' && $rel->has_vm($cpic->{prod}) && $vm->check_dmp_native_support_reboot_sys($sys)) {
        $tunable_info->{reboot}=1;
    }

    return 1;
}

# return 1 if $sys or $pkg's attributes are updated, otherwise, return ''
sub check_netbackup_compatibility_sys {
    my ($rel,$sys) = @_;
    my ($msg,@deppkgs_donotuninstall,$nbuvers,$vers,$pkgs,$pkg,$pdfrs,$cpic);

    # Check NetBackup
    $nbuvers=$rel->netbackup_sys($sys);
    if ($nbuvers) {
        Msg::log("NetBackup $nbuvers was installed on $sys->{sys}");
        return '';
        # If NetBackup installed, then skip uninstall VRTSpbx/VRTSicsco/VRTSat.
        for my $pkgname(qw(VRTSpbx VRTSicsco VRTSat50 VRTSatClient50)) {
            $cpic=Obj::cpic();
            $pkg=Pkg::new_pkg('Pkg', $pkgname, $cpic->{padv});
            $vers=$pkg->version_sys($sys);
            if ($vers) {
                push (@deppkgs_donotuninstall, $pkg->{pkg});
                push (@{$pkg->{softdeps}}, 'NetBackup');
            }
        }

        $pkgs=join(' ', @deppkgs_donotuninstall) if (@deppkgs_donotuninstall);
        if ($pkgs) {
            if (Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade uninstall))) {
                $pdfrs=Msg::get('pdfrs');
                $msg=Msg::new("NetBackup $nbuvers was installed on $sys->{sys}. The $pkgs $pdfrs on $sys->{sys} will not be uninstalled.");
                $sys->push_warning($msg);
            }
        } else {
            Msg::log("NetBackup $nbuvers was installed on $sys->{sys}");
            return '';
        }
    } else {
        Msg::log("NetBackup was not installed on $sys->{sys}");
        return '';
    }

    return 1;
}

# return 1 if $sys or $pkg's attributes are updated, otherwise, return ''
sub check_vom_compatibility_sys {
    my ($rel,$sys) = @_;
    my ($msg,$csvers,$mincsvers,$cscv,$mhpkg,$mhvers,$mhcv,$chpkg,$chvers,$pdfr,$rtn);

    $pdfr=Msg::get('pdfr');

    # Check VOM MH
    $mhpkg=$sys->pkg('VRTSsfmh60');
    $mhvers=$mhpkg->version_sys($sys);
    $mhcv=EDRu::compvers($mhvers,$mhpkg->{vers});

    # Check VOM CS
    $csvers=$rel->vomcs_sys($sys);
    if ($csvers) {
        # For e2107309, If VOM/SFM CS installed, then skip upgrade VRTSsfmh
        if ($mhvers && $mhcv==2 && Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade))) {
            # Minimal version of VRTSsfmcs which is compatible with 6.0
            $mincsvers='4.1';
            $cscv=EDRu::compvers($csvers, $mincsvers);
            if ($cscv==2) {
                # For e2585533: if VRTSsfmcs earlier than version 4.1, show an error and bail out.
                $msg=Msg::new("VOM Central Server $csvers was installed on $sys->{sys}. Upgrade VOM Central Server (CS) to minimal version $mincsvers to ensure proper product functionality");
                $sys->push_error($msg);
            } else {
                # Lower version of VRTSsfmh but higher than or equal to 4.1 was installed, skip upgrade.
                push(@{$sys->{donotupgradepkgs}},$mhpkg->{pkgi});

                $msg=Msg::new("VOM Central Server $csvers was installed on $sys->{sys}. The VRTSsfmh $pdfr on $sys->{sys} will not be upgraded.");
                $sys->push_warning($msg);
            }
        } elsif ($mhvers && Cfg::opt(qw(uninstall))) {
            $msg=Msg::new("VOM Central Server $csvers was installed on $sys->{sys}. The VRTSsfmh $pdfr on $sys->{sys} will not be uninstalled.");
            $sys->push_warning($msg);
            return '';
        } else {
            Msg::log("VOM Central Server $csvers was installed on $sys->{sys}");
            return '';
        }
    } else {
        Msg::log("VOM/SFM Central Server was not installed on $sys->{sys}");

        # For e2252596: To check whether the managed host is reporting to any central servers.
        if ($mhvers && $mhcv==2 && Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade))) {
            if (EDRu::inarr($mhpkg->{pkgi}, @{$sys->{donotupgradepkgs}})) {
                # VRTSsfmh may not require upgrade when ApplicationHA also installed.
                Msg::log("VRTSsfmh need not be upgraded");
            } else {
                # Need upgrade VRTSsfmh
                # print warning if the managed host is reporting to some SFM or VOM management servers.
                $rtn=$mhpkg->check_if_managedhost_connected_to_central_server_sys($sys);
                if ($rtn) {
                    $msg=Msg::new("The VRTSsfmh $pdfr on $sys->{sys} will be upgraded to $mhpkg->{vers}. Note that the system $sys->{sys} is reporting to the following management server(s):\n\t$rtn");
                    $sys->push_warning($msg);
                }
            }
        } elsif ($mhvers && Cfg::opt(qw(uninstall))) {
            # Check CCS MS/CH
            $chpkg=Pkg::new_pkg('Pkg', 'VRTSccch', $sys->{padv});
            $chvers=$chpkg->version_sys($sys);

            if (EDRu::inarr($mhpkg->{pkgi}, @{$sys->{donotuninstallpkgs}})) {
                # VRTSsfmh may not require uninstall when ApplicationHA also installed.
                Msg::log("VRTSsfmh need not be uninstalled");
            } elsif ($chvers) {
                # VRTSsfmh do not need uninstall if CCS MS/CH installed.
                $msg=Msg::new("CommandCentral Storage Management Server/Control Host was installed on $sys->{sys}. The VRTSsfmh $pdfr on $sys->{sys} will not be uninstalled.");
                $sys->push_warning($msg);
            } else {
                # Need uninstall VRTSsfmh
                # print warning if the managed host is reporting to some SFM or VOM management servers.
                $rtn=$mhpkg->check_if_managedhost_connected_to_central_server_sys($sys);
                if ($rtn) {
                    $msg=Msg::new("The VRTSsfmh $pdfr on $sys->{sys} will be uninstalled. Note that the system $sys->{sys} is reporting to the following management server(s):\n\t$rtn");
                    $sys->push_warning($msg);
                }
            }
        }
        return '';
    }

    return 1;
}

# There're many situation we need to get package array.
# Such as -pkgtable, -allpkgs, install package list for user.
# We can adjust the package install sequence here.
sub adjust_pkg_sequence {
    my ($rel, $pkgarray) = @_;
    my ($pkgi_cpi, @pkgs, @lastpkgs);
    # 1. always put VRTSvbs pkg after VRTSsfmh pkg
    # fix for e2567015
    # always put VRTSvcswiz pkg after VRTSsfmh pkg
    # fix for e3065970
    my ($mhpos,$vbpos,$wizpos,$vmwpos);
    $mhpos = EDRu::arrpos('VRTSsfmh60',@{$pkgarray});
    $vbpos = EDRu::arrpos('VRTSvbs61',@{$pkgarray});
    # both package exists, VRTSsfmh is installed later than VRTSvbs, adjust their sequence
    if($mhpos != -1 && $vbpos != -1 && $mhpos > $vbpos) {
        for my $i($vbpos..$mhpos) {
            ${$pkgarray}[$i] = ${$pkgarray}[$i+1];
        }
        ${$pkgarray}[$mhpos] = 'VRTSvbs61';
    }

    $mhpos = EDRu::arrpos('VRTSsfmh60',@{$pkgarray});
    $wizpos = EDRu::arrpos('VRTSvcswiz61',@{$pkgarray});
    $vmwpos = EDRu::arrpos('VRTSvcsvmw61',@{$pkgarray});

    # both package exists, VRTSsfmh is installed later than VRTSvcswiz, adjust their sequence
    if($mhpos != -1 && $wizpos != -1 && $mhpos > $wizpos) {
        for my $i($wizpos..$mhpos) {
            ${$pkgarray}[$i] = ${$pkgarray}[$i+1];
        }
        ${$pkgarray}[$mhpos] = 'VRTSvcswiz61';
    }
    # both package exists, VRTSsfmh is installed later than VRTSvcsvmw, adjust their sequence
    if($mhpos != -1 && $vmwpos != -1 && $mhpos > $vmwpos) {
        for my $i($vmwpos..$mhpos) {
            ${$pkgarray}[$i] = ${$pkgarray}[$i+1];
        }
        ${$pkgarray}[$mhpos] = 'VRTSvcsvmw61';
    }

    # 2. move VRTSsfcpi pkg to the last position
    for my $pkgi(@{$pkgarray}) {
        # VRTSsfcpi pkg is the last pkg to install
        if ($pkgi eq $rel->{cpipkg}) {
            $pkgi_cpi = $pkgi;
            next;
        }
        # other pkg which has installpkgslast flag
        if ($rel->pkg($pkgi)->{installpkgslast}) {
            push (@lastpkgs,$pkgi);
            next;
        }
        push (@pkgs,$pkgi);
    }
    push (@pkgs, @lastpkgs);
    push (@pkgs, $pkgi_cpi) if ($pkgi_cpi);
    return \@pkgs;
}

# Add VRTSsfcpi install/uninstall logic
# Add VRTSsvs uninstall logic for UxRT-6.1.0 onward
sub adjust_pkgs {
    my ($rel) = @_;
    my ($cpic, $cpipkg);
    $cpic=Obj::cpic();
    $cpipkg=$cpic->pkg($rel->{cpipkg});
    for my $sys (@{$cpic->{systems}}) {
        $cpipkg->set_sfcpi_upgrade_sys($sys);
        $rel->set_svs_upgrade_sys($sys);
    }
}

sub default_systemnames {
    my $rel=shift;
    my ($cpic,$vcs,$dfs,@systems,$cfg);
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $vcs=$cpic->prod("VCS61");
    if(Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs ))){
        return $rel->{nextrusys}  if($rel->{nextrusys});
        $dfs=$rel->ru_check_newnode();
        $dfs=~ s/^\s+|\s+$//g;
        @systems=split(/\s+/,$dfs);
        if(Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs ))){
            $cfg->{systems}=\@systems;
        } else {
            delete $cfg->{systems};
        }
        return $dfs;
    } elsif (Cfg::opt(qw(patchupgrade hotfixupgrade upgrade rollback))) {
        $dfs = $vcs->default_systemnames;
        return $dfs if $dfs;
    }
    return Obj::localsys()->{sys};
}

# Ask user if he would like to switch SGs himself.
# $way=0,1,2(undetermined,manual switch,CPI switch)
sub ru_switch_groups {
    my ($rel,$syslist,$way)=@_;
    my ($ayn,$msg,$webmsg,$helpmsg,$allmsg);
    my ($failoversg_hash,$failoverlist,$stage);
    my ($maincf,$sys);
    # $sgtargethash: Failover Service Group => Target machine it will failover on
    # $sgsourcehash: Failover Service Group => Source machine it failover from
    # $sgupdatedhash: updated $sgtargethash, failure failover service groups => target machines which are not onlined successfully
    my ($sgtargethash,$sgsourcehash,$sgupdatedhash);
    my ($systemlist,@sgarr);
    my ($sysname,$sglist,$grp,$depsgupdatehash);
    my ($waitmax,$waitstep,$waittime);
    my $cpic=Obj::cpic();
    my $edr=Obj::edr();
    my $web = Obj::web();
    my $vcs=$rel->prod('VCS61');

    # undetermined, ask user which way to switch service groups
    if ($way == 0) {
        $failoversg_hash = $rel->ru_aquire_failoversg_hash($syslist);
        # if no failover service group on the first subcluster, no need to switch
        return unless($failoversg_hash);
        # if there's no other subcluster.(1 node rolling upgrade)
        unless(@{$rel->{ru_idle_list}}) {
            #Todo: warn user no failover conception, if user continue, failover sgs offline.
            $msg=Msg::new("You are performing rolling upgrade on a single node cluster. All the failover service group(s) will be offline during rolling upgrade. Would you like to continue?");
            $ayn=$msg->aynn('','',$webmsg);
            Msg::n();
            if($ayn eq 'N') {
                $cpic->edr_completion();
            } else {
                return;
            }
        }
        $msg=Msg::new("The following failover service group(s) are online in this sub-cluster:");
        Msg::n();
        $webmsg.="$msg->{msg}";
        $msg->bold();
        for my $sys (@{$syslist}) {
            if($failoversg_hash->{$sys->{sys}}) {
                $failoverlist = join(' ', @{$failoversg_hash->{$sys->{sys}}});
                $msg = "$sys->{sys}: $failoverlist";
                Msg::print("$msg");
                $webmsg .= "$msg\n";
            }
        }
        Msg::n();
        $msg = Msg::new("In order to minimize downtime during rolling upgrade, switch failover service group(s) to the node(s) that are not being upgraded at this time.\n");
        $webmsg .= "$msg->{msg}";
        $webmsg =~ s/\n/\\n/g;
        $msg->print();
        $msg = Msg::new("Would you like to switch these service group(s) manually?");
        $helpmsg = Msg::new("Manually switching service group(s) requires you to log into the node(s) and use VCS command to switch the failover service group(s) to the node(s) that are not being upgraded at this time. This will reduce the risk of failover failures.");
        $ayn=$msg->aynn($helpmsg,'',$webmsg);
        if($ayn eq 'Y') {
            $rel->ru_switch_groups($syslist,1);
        } else {
            $rel->ru_switch_groups($syslist,2);
        }
    } elsif ($way == 1) {
        # give instructions to user, wait until user hit Enter
        $rel->ru_switch_sg_guide();
        # check if there're still online failover service groups on the subcluster
        $edr->set_progress_steps(1);
        $stage=Msg::new("Detecting failover service group(s) on the sub-cluster");
        $web->web_script_form('showstatus',$stage) if (Obj::webui());
        $msg=Msg::new("Detecting failover service group(s) on the sub-cluster");
        $msg->left;
        $msg->display_left($msg) if(Obj::webui());
        $failoversg_hash = $rel->ru_aquire_failoversg_hash($syslist);

        if ($failoversg_hash) {
            $msg->right_failed;
            $msg->display_right() if(Obj::webui());
            # Still has online SGs
            Msg::n();
            $msg=Msg::new("Switching failover service group(s) manually did not complete successfully.\n");
            $msg->warning();
            $webmsg="$msg->{msg}\\n";
            $msg=Msg::new("There are still online failover service group(s) in the first sub-cluster:");
            $msg->print();
            $webmsg.="$msg->{msg}\\n";
            for my $sys(@{$syslist}) {
                if($failoversg_hash->{$sys->{sys}}) {
                    $failoverlist = join(' ', @{$failoversg_hash->{$sys->{sys}}});
                    $msg = "$sys->{sys}: $failoverlist";
                    Msg::print($msg);
                    $webmsg .= "$msg\\n";
                }
            }
            Msg::n();
            $msg=Msg::new("Would you like to try again?");
            $ayn=$msg->ayny('','',$webmsg);
            if ($ayn eq 'Y') {
                $rel->ru_switch_groups($syslist,1);
            } else {
                $rel->ru_switch_groups($syslist,0);
            }
        } else {
            $msg->right_done;
            $msg->display_right() if(Obj::webui());
            $msg=Msg::new("All the online failover service group(s) have been successfully switched to the other sub-cluster.");
            Msg::n();
            $msg->printn();
        }
    } else {
        # inform user the risk of failover failure
        # Switching method
        # 1. list all the service groups that needs to switch.
        # 2. grep main.cf file to get related service group's system list.
        # 3. seqently try to switch failover sgs to corresponding systems(skip if the system is inside the subcluster)
        $failoversg_hash = $rel->ru_aquire_failoversg_hash($syslist);
        # if no failover service group on the first subcluster, no need to switch
        return unless($failoversg_hash);
        Msg::n();
        $msg=Msg::new("The following changes will be made on the cluster:");
        $msg->bold();
        $webmsg = "$msg->{msg}\\n";
        # Detecting service groups
        my @subclusterlist;
        for my $node (@{$syslist}) {
            push(@subclusterlist, $node->{sys});
        }
        $sys=@{$syslist}[0];
        $maincf=$sys->readfile($vcs->{maincf});
        while (($sysname,$sglist) = each %$failoversg_hash) {
            for my $sg (@{$sglist}) {
                $maincf=~m/\ngroup\s+$sg\s+\(\n\s+?SystemList\s+=\s+{\s+([\s\S]*?)\s+}/;
                $systemlist=$1;
                $systemlist=~s/\s+//g;
                @sgarr=split(/,/,$systemlist);
                for my $n(@sgarr) {
                    $n=~s/=\d//;
                }
                @sgarr=@{EDRu::arrdel(\@sgarr, @subclusterlist)};
                #Todo: if !@sgarr, which means no target machine to be fail over with.
                $sgtargethash->{$sg}=$sgarr[0] if(@sgarr);
                $sgsourcehash->{$sg}=$sysname;

                if($sgtargethash->{$sg}) {
                    $msg=Msg::new("Failover service group $sg will be switched to $sgtargethash->{$sg}");
                } else {
                    $msg=Msg::new("Failover service group $sg will not be switched because there is no system to failover on.");
                }
                $msg->print();
                $webmsg .= "$msg->{msg}\\n";
            }
        }

        # Ask user's permission for continue, if no service group(d) can be switched
        Msg::n();
        if (!%$sgtargethash) {
            $msg=Msg::new("There is no service group(s) that can be switched to the other sub-cluster. Are you sure you want to continue?");
            $ayn=$msg->ayny('','',$webmsg);
            if ($ayn eq 'N') {
                $cpic->edr_completion();
            } else {
                return;
            }
        }

        # Ask user's permission for switching strategy
        Msg::n();
        $msg=Msg::new("User may incur downtime while switching failover service group(s). Are you sure you want to continue?");
        $ayn=$msg->ayny('','',$webmsg);
        if ($ayn eq 'Y') {
            $edr->set_progress_steps(2);
            $stage=Msg::new("Switch failover service group(s)");
            $web->web_script_form('showstatus',$stage) if (Obj::webui());
            # if user allow to switch
            Msg::n();
            $msg=Msg::new("Switching failover service group(s)");
            $msg->left;
            $msg->display_left($msg) if(Obj::webui());
            if (!Cfg::opt('makeresponsefile')) {
                for my $sg (keys %$sgtargethash) {
                    $depsgupdatehash = $rel->ru_precheck_switch_groups($sys, $sg, $sgtargethash->{$sg});
                    if ($depsgupdatehash) {
                        my $dep_sgs=join ',', keys %$depsgupdatehash;
                        $msg = Msg::new("Service group $sg is not going to switch over because service group(s) $dep_sgs it depended on are not online in $sgtargethash->{$sg}");
                        $webmsg.="$msg->{msg}\\n";
                        $allmsg .= "$msg->{msg}\n";
                    } else {
                        $sys->cmd("_cmd_hagrp -switch $sg -to $sgtargethash->{$sg} 2>&1");
                    }
                }
            }
            if($sgupdatedhash) {
                $msg->right_failed;
            } else {
                $msg->right_done;
            }
            $msg->display_right() if(Obj::webui());
            $msg = Msg::new("$allmsg");
            $msg->warning();
            $msg=Msg::new("Waiting for service group(s) to come online on the other sub-cluster");
            $msg->left;
            $msg->display_left($msg) if(Obj::webui());
            # If some service groups are not switched because sgs they depended on are not online in the target nodes,
            # switch service group one more time 
	    $sgupdatedhash ||= $rel->ru_check_online_sgs($sgtargethash, 0);
	    if($sgupdatedhash) {
	        for my $sg (keys %$sgupdatedhash) {
		    $sys->cmd("_cmd_hagrp -switch $sg -to $sgtargethash->{$sg} 2>&1");
		}
	    }
	    $sgupdatedhash = $rel->ru_check_online_sgs($sgtargethash, 0);
            if($sgupdatedhash) {
                # sigh! There're service groups failed to online on the target system
                $msg->right_failed;
                $msg->display_right() if(Obj::webui());
                # failover service groups failed to online on the other subcluster after 5 min
                # tell user which failover service group switch failed
                $msg=Msg::new("The following service group(s) failed to come online on the target system(s):");
                $webmsg = "$msg->{msg}\\n";
                for my $sg (keys %$sgupdatedhash) {
                    $msg=Msg::new("Failover service group $sg failed to come online on machine $sgupdatedhash->{$sg}");
                    $msg->print();
                    $webmsg.="$msg->{msg}\\n";
                }
                Msg::n();
                $msg=Msg::new("Some failover service group(s) are still not online on the target system(s) after 5 minutes, it is possible that the service group(s) are still trying to come online on the target system(s).");
                $webmsg.="$msg->{msg}\\n";
                $msg->printn();
            } else {
                # Successfully evacuated
                $msg->right_done;
                $msg->display_right() if(Obj::webui());
                Msg::n();
                $msg=Msg::new("All the online failover service group(s) that can be switched have been switched to the other sub-cluster.");
                $msg->printn();
            }
        } else {
            $rel->ru_switch_groups($syslist,0);
        }
    }
    return;
}

# make sure all the depended service groups are online in the target node before switch a service group
sub ru_precheck_switch_groups {
    my ($rel, $sys, $sg, $targetnode) = @_;
    my ($ret, $depsgtgthash);

    # Find the the service group list that $sg depended on
    $ret = $sys->cmd("_cmd_hagrp -dep $sg 2>/dev/null | _cmd_awk '/^$sg / {print \$2}'");
    return '' unless ($ret);

    for my $depsg (split(/\n/m, $ret)) {
       $depsgtgthash->{$depsg} = $targetnode;
    }
    return $rel->ru_check_online_sgs($depsgtgthash);
}

# make sure all the failover service groups in $failoversg_list are online on the other subcluster
# $parallel=0,1,no value(check non-parallel sg, check parallel sg, both)
sub ru_check_online_sgs {
    my ($rel,$sgtargethash,$parallel)=@_;
    my ($waitmax,$waitstep,$waittime);
    my ($updatesghash,$sys);
    my ($sglist,$result);

    return '' if (Cfg::opt('makeresponsefile'));
    $sys=$rel->{ru_idle_list}[0];
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $waitmax=300;
    $waitstep=5;
    $waittime=0;
    while($waittime < $waitmax) {
        sleep $waitstep;
        $waittime += $waitstep;
        undef($updatesghash);
        for my $sg (keys %$sgtargethash) {
            undef($result);
            my $targetnode = $sgtargethash->{$sg};
            if (defined($parallel)) {
                $result=$sys->cmd("_cmd_hagrp -list State=~ONLINE Parallel=$parallel 2>/dev/null | _cmd_awk '/^$sg\[ \t]+$targetnode\$/ {print \$1}'");
            } else {
                $result=$sys->cmd("_cmd_hagrp -list State=~ONLINE 2>/dev/null | _cmd_awk '/^$sg\[ \t]+$targetnode\$/ {print \$1}'");
            }
            # if no result, means this failover service group still not online on target node.
            if(!$result) {
                # we need to record this to $updatesghash, only if this is the last time to check.
                if($waittime>=$waitmax) {
                    $updatesghash->{$sg} = $sgtargethash->{$sg};
                } else {
                    last;
                }
            }
        }
        last if($result);
    }
    return $updatesghash;
}

# show steps to switch service groups manually
sub ru_switch_sg_guide {
    my ($rel)=@_;
    my ($msg, $webmsg);
    my $vcs=$rel->prod("VCS61");
    my $web = Obj::web();
    $msg = Msg::new("Resume installer after the following steps are completed:");
    $webmsg.="$msg->{msg}\n";
    $msg->nprint();
    $msg = Msg::new("Step 1: Log in as the root user on one of the nodes of the existing cluster.");
    $webmsg.="$msg->{msg}\n";
    $msg->print();
    $msg = Msg::new("Step 2: Use command '$vcs->{bindir}/hagrp -list State=~ONLINE Parallel=0' to get the service groups that are online on the first sub-cluster.");
    $webmsg.="$msg->{msg}\n";
    $msg->print();
    $msg = Msg::new("Use command '$vcs->{bindir}/hagrp -switch failoversg -to targetnode' to switch service groups from first sub-cluster to the machine(s) in the second sub-cluster.");
    $webmsg.="$msg->{msg}\n";
    $msg->print();
    $msg = Msg::new("After switching all failover service groups, press Enter, to resume the installation program");
    $webmsg.=Msg::new("After switching all failover service groups, click OK, to resume the installation program\n")->{msg};
    $msg->print();
    Msg::prtc();
    Msg::n();
    $webmsg =~ s/\n/\\n/g;
    $web->web_script_form('alert', $webmsg) if (Obj::webui());
    return;
}

sub ru_aquire_failoversg_hash {
    my ($rel,$syslist)=@_;
    my ($failoverresult,$failoverhash);
    my (@failoverlist);
    for my $sys (@{$syslist}) {
        $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
        $failoverresult=$sys->cmd("_cmd_hagrp -list State=~ONLINE Parallel=0 2>/dev/null | _cmd_awk \'{if\(\"$sys->{sys}\"==\$2\) {print \$1}}'");
        unless ($failoverresult eq '') {
            @failoverlist=split(/\n/m, $failoverresult);
            $failoverhash->{$sys->{sys}}=[@failoverlist];
        }
    }
    return $failoverhash;
}

sub ru_offline_parallel_groups {
    my ($rel,$syslist)=@_;
    my ($edr,$cpic,$web,$msg,$webmsg);
    my (@parallellist,$parallelhash,$parallelresult,$verifiedhash,$sys,$parallellist,$ayn);
    my ($stage,$waitmax);
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $web = Obj::web();
    $waitmax=300;
    # Retrieve parallel service group
    for my $sys(@{$syslist}) {
        $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
        $parallelresult=$sys->cmd("_cmd_hagrp -list State=~ONLINE Parallel=1 2>/dev/null | _cmd_awk \'{if\(\"$sys->{sys}\"==\$2\) {print \$1}}'");
        unless ($parallelresult eq '') {
            @parallellist=split(/\n/m, $parallelresult);
            $parallelhash->{"$sys->{sys}"}=[@parallellist];
        }
    }
    return 0 unless ($parallelhash);
    $msg=Msg::new("The following parallel service group(s) in the sub-cluster will be offline:");
    $webmsg.="$msg->{msg}";
    $msg->bold();
    Msg::n();
    for my $sys (keys%{$parallelhash}) {
        $sys=Obj::sys($sys);
        $parallellist=join(' ', @{$parallelhash->{"$sys->{sys}"}});
        $msg = "$sys->{sys}: $parallellist";
        Msg::print("$msg");
        $webmsg .= "$msg\n";
    }
    Msg::n();
    # Ask user if he would like to continue.
    $msg=Msg::new("Are you sure you want to continue?");
    $webmsg =~ s/\n/\\n/g;
    $ayn=$msg->ayny('','',$webmsg);
    Msg::n();
    $cpic->edr_completion() if ($ayn eq 'N');

    $edr->set_progress_steps(2);
    $stage=Msg::new("Offline parallel service group(s)");
    $web->web_script_form('showstatus',$stage) if (Obj::webui());
    $msg=Msg::new("Offline parallel service group(s)");
    $msg->left;
    $msg->display_left($msg) if(Obj::webui());
    # User press continue, begin to offline parallel service groups
    for my $sys (keys%{$parallelhash}) {
        $sys=Obj::sys($sys);
        for my $grp (@{$parallelhash->{"$sys->{sys}"}}) {
            $sys->cmd("_cmd_hagrp -offline -propagate $grp -sys $sys->{sys} 2> /dev/null");
        }
    }
    $msg->right_done;
    $msg->display_right() if(Obj::webui());
    $msg=Msg::new("Waiting for service group(s) to be taken offline on the sub-cluster");
    $msg->left;
    $msg->display_left($msg) if(Obj::webui());
    # verify if all parallel service groups are offline
    for my $sys (keys%{$parallelhash}) {
        $sys=Obj::sys($sys);
        for my $grp (@{$parallelhash->{"$sys->{sys}"}}) {
            $sys->cmd("_cmd_hagrp -wait $grp State OFFLINE -sys $sys->{sys} -time $waitmax 2> /dev/null");
            if (EDR::cmdexit() != 0) {
                # means offline failure, record it
                push(@{$verifiedhash->{"$sys->{sys}"}},$grp);
            }
        }
    }
    if ($verifiedhash) {
        $msg->right_failed;
        $msg->display_right() if(Obj::webui());
        # if $verifiedhash exists, there're still online parallel service groups.
        Msg::n();
        $msg=Msg::new("The following parallel service group(s) are not in an OFFLINE state:");
        $msg->warning();
        for my $sys (keys%{$parallelhash}) {
            $sys=Obj::sys($sys);
            $parallellist=join(' ', @{$verifiedhash->{"$sys->{sys}"}});
            $msg = "$sys->{sys}: $parallellist";
            Msg::print("$msg");
            $webmsg .= "$msg\n";
        }
        Msg::n();
        $msg=Msg::new("There are still parallel service group(s) online in the sub-cluster. Symantec recommends that you solve the issue and re-run the operation.");
        $webmsg .="$msg->{msg}\n";
        $msg->printn();
        $msg=Msg::new("Do you want to continue?");
        $ayn=$msg->aynn('','',$webmsg);
        Msg::n();
        $cpic->edr_completion() if ($ayn eq 'N');

    }
    # Successful
    $msg->right_done;
    $msg->display_right() if(Obj::webui());
    Msg::n();
    return;
}

# rolling upgrade phase 1 part 1
# ask user to perform rolling upgrade phase 1 part 1
# user can choose his own nodes instead of using recommended nodes.
sub ask_usr_ru1 {
    my ($rel,$sclist,$syslist,$conf)=@_;
    my ($msg,$webmsg,$ayn);
    my $showlist = join(' ',@{$sclist});
    my $cpic=Obj::cpic();
    my $cfg = Obj::cfg();
    # responsefile support for RU
    if(defined $rel->{vcs_subcluster_num}) {
        $rel->{vcs_subcluster_num}++;
    } else {
        $rel->{vcs_subcluster_num} = 0;
    }
    $cfg->{phase1}{$rel->{vcs_subcluster_num}} = $sclist;
    $rel->{upgrade}{phase1_done} = $sclist;
    # user finally decided to perform RUP1
    # set options to make sure CPI do kernel package upgrade
    Cfg::set_opt("upgrade_kernelpkgs");
    Cfg::unset_opt("upgrade_nonkernelpkgs");
    # set ru_running_list & ru_idle_list for $rel
    $rel->{ru_running_list} = $sclist;
    $rel->{ru_idle_list} = EDRu::arrdel($syslist, @{$sclist});
    # Set cpic's phase name
    $cpic->{install_phase_name} = "rollingupgrade_phase1_install";
    $cpic->{uninstall_phase_name} = "rollingupgrade_phase1_uninstall";
    $cpic->{shutdown_phase_name} = "rollingupgrade_phase1_shutdown";
    $cpic->{startup_phase_name} = "rollingupgrade_phase1_startup";
    if (Obj::webui()){
        my $web=Obj::web();
        $web->{rup1list}=$sclist;
    }

    $rel->update_status_file("RU","Rolling upgrade phase 1",$sclist) unless(Cfg::opt('snas_upgrade'));

    return $sclist;
}

# rolling upgrade phase 1 part 2
# half nodes have been upgraded, So upgrade remaining half nodes.
# user have to perform phase 1 part 2 on remaining codes.
# function name mains it's the phase between phase 1 & phase 2.
sub ask_usr_ru1ru2 {
    my ($rel,$sclist,$rup2list)=@_;
    my ($msg,$webmsg,$ayn);
    my ($showlist,$showrup2list);
    my ($inputlist,@inputlist,@syslist);
    my ($hint,$helpmsg);
    my $cpic=Obj::cpic();
    my $cfg = Obj::cfg();
    if (defined($rel->{rollingupgrade_phasecount})) {
        $rel->{rollingupgrade_phasecount}++;
    } else {
        $rel->{rollingupgrade_phasecount}=1;
    }
    $showlist = join(' ', @{$sclist});
    $showrup2list = join(' ', @{$rup2list});
    $msg=Msg::new("Rolling upgrade phase 1 is performed on the system(s) $showrup2list. It is recommended to perform rolling upgrade phase 1 on the remaining system(s) $showlist.\n");
    $msg->bold;
    $webmsg = $msg->{msg};
    $webmsg =~ s/\n/\\n/g;
    $msg=Msg::new("Would you like to perform rolling upgrade phase 1 on the recommended system(s)?");
    $ayn=$msg->ayny('','',$webmsg);
    Msg::n();
    if($ayn eq 'N') {
        $msg=Msg::new("Do you want to quit without phase 1 performed on all systems?");
        $ayn = $msg->aynn();
        # quit installer
        if($ayn eq 'Y') {
            # in order to generate response file, otherwise if user choose 'q' option to quit, there would be no response file
            $cpic->edr_completion();
        } else {
            Msg::n();
        }
        my $failed=1;
        while($failed) {
             $failed=0;

             $msg=Msg::new("Enter the system names separated by spaces on which you want to perform rolling upgrade:");
             $helpmsg=Msg::new("The specified systems are required to be a subset of the following system(s): $showlist");
             if (Obj::webui()) {
                my $systems = Obj::web()->web_script_form('inputSystems',$msg);
                $sclist = $systems;
            } else {
                $inputlist=$msg->ask($hint,$helpmsg);
                Msg::n();
                @inputlist=split(/\s+/,$inputlist);
                # User can choose some of the remaining sys to perform RU.
                # Following situation need to consider:
                # 1. inputed node not belong to syslist
                # 2. repeated nodes
                my $len=scalar(@inputlist);
                my $repeated=0;
                @inputlist = @{EDRu::arruniq(@inputlist)};
                # there're repeated hostname inputed
                if(scalar(@inputlist) < $len) {
                    $repeated=1;
                }

                foreach my $node (@inputlist) {
                    if(!EDRu::inarr($node, @{$sclist})) {
                        $failed=1;
                        if(EDRu::inarr($node, @{$rup2list})) {
                            $msg=Msg::new("Kernel packages of $node have already been upgraded. Systems specified are required to be a subset of the following system(s): $showlist. Please try again.\n");
                            $msg->warning();
                        } else {
                            $msg=Msg::new("Systems specified are required to be a subset of the following systems: $showlist. Please try again.\n");
                            $msg->warning();
                        }
                        last;
                    }
                }
                next if($failed);

                if($repeated) {
                    $showlist=join(' ',@inputlist);
                    $msg=Msg::new("You have entered duplicate system names. Are you sure that you want to perform a rolling upgrade on $showlist?");
                    $webmsg .= $msg->{msg};
                    $webmsg =~ s/\n/\\n/g;
                    my $ayn=$msg->ayny('','',$webmsg);
                    Msg::n();
                    if($ayn eq 'N') {
                        $failed=1;
                    }
                }
            }
        }
    }
    # responsefile support for RU
    if(defined $rel->{vcs_subcluster_num}) {
        $rel->{vcs_subcluster_num}++;
    } else {
        $rel->{vcs_subcluster_num} = 0;
    }
    if (Cfg::opt('responsefile')) {
        my $n = 1 + $rel->{vcs_subcluster_num};
        my $keys = keys %{$cfg->{phase1}};
        # in case only part of the nodes are configured in response file
        if ($n > $keys) {
            my $showrup1list = join(' ', @{$sclist});
            $msg=Msg::new("Rolling upgrade phase 1 is not performed on the systems $showrup1list. The cluster is not fully upgraded.\n");
            $msg->warning;
            $cpic->edr_completion();
        } else {
            if(!(defined $cfg->{phase1}{$rel->{vcs_subcluster_num}}) ||
                !@{$cfg->{phase1}{$rel->{vcs_subcluster_num}}}) {
                    $msg = Msg::new("Response file error, no configuration for rolling upgrade phase 1.\n");
                    $msg->die;
            }
            @inputlist = ();
            # Ensure the phase1 procedure is still in sub-cluster range the response file provided
            while ($rel->{vcs_subcluster_num} < $keys) {
                foreach my $node (@{$cfg->{phase1}{$rel->{vcs_subcluster_num}}}) {
                    if(!EDRu::inarr($node, @{$sclist})) {
                        if(EDRu::inarr($node, @{$rup2list})) {
                            $msg = Msg::new("Node $node has performed rolling upgrade phase 1 already.");
                            $msg->print;
                            next;
                        }
                        $msg = Msg::new("Node $node is not in the cluster. Verify your cluster configuration and the response file.\n");
                        $msg->die;
                    }
                    push(@inputlist, $node);
                }
                # To make sure every upgrade step is executed for the whole sub-cluster
                if (@inputlist) {
                    if (scalar(@inputlist) == scalar(@{$cfg->{phase1}{$rel->{vcs_subcluster_num}}})) {
                        last;
                    } else {
                        my @donelist = @{EDRu::arrdel(\@{$cfg->{phase1}{$rel->{vcs_subcluster_num}}}, @inputlist)};
                        my $donelist = join(' ', @donelist);
                        $msg = Msg::new("Rolling upgrade phase 1 has been performed on nodes $donelist but not on other nodes in the configured sub-cluster in the response file. Verify your cluster configuration and the response file.\n");
                        $msg->die;
                    }
                }
                $rel->{vcs_subcluster_num}++;
                next;
            }
        }
    }
    $cfg->{phase1}{$rel->{vcs_subcluster_num}} = @inputlist ? \@inputlist : $sclist;

    Cfg::set_opt("upgrade_kernelpkgs");
    Cfg::unset_opt("upgrade_nonkernelpkgs");
    # set ru_running_list & ru_idle_list for $rel
    $rel->{ru_running_list} = @inputlist ? \@inputlist : $sclist;
    push (@{$rel->{upgrade}{phase1_done}}, @{$sclist});
    @syslist=(@{$sclist},@{$rup2list});
    $rel->{ru_idle_list} = EDRu::arrdel(\@syslist, @{$rel->{ru_running_list}});
    # Set cpic's phase name
    $cpic->{install_phase_name} = "rollingupgrade_phase1_install_$rel->{rollingupgrade_phasecount}";
    $cpic->{uninstall_phase_name} = "rollingupgrade_phase1_uninstall_$rel->{rollingupgrade_phasecount}";
    $cpic->{shutdown_phase_name} = "rollingupgrade_phase1_$rel->{rollingupgrade_phasecount}";
    $cpic->{startup_phase_name} = "rollingupgrade_phase1_startup_$rel->{rollingupgrade_phasecount}";
    if (Obj::webui()){
        my $web=Obj::web();
        $web->{rup1list}=$rel->{ru_running_list};
    }

    $rel->update_status_file("RU","Rolling upgrade phase 1",$rel->{ru_running_list});

    return $rel->{ru_running_list};
}

# rolling upgrade phase 2
# all nodes need to be upgraded.
sub ask_usr_ru2 {
    my ($rel,$sclist)=@_;
    my ($msg,$webmsg,$ayn);
    my $cpic = Obj::cpic();
    my $cfg = Obj::cfg();

    # Set the 2 opts before judging whether to perform phase 2
    # The reason is that SFRAC relink oracle database library need a flag to decide when to stop
    Cfg::set_opt("upgrade_nonkernelpkgs");
    Cfg::unset_opt("upgrade_kernelpkgs");
    $msg=Msg::new("Rolling upgrade phase 1 is performed on all the cluster systems. It is recommended to perform rolling upgrade phase 2 on all the cluster systems.\n");
    $msg->bold;
    $webmsg = $msg->{msg};
    $webmsg =~ s/\n/\\n/g;
    my $decided=0;
    while(!$decided) {
        $decided=1;
        $msg=Msg::new("Would you like to perform a rolling upgrade phase 2 on the cluster?");
        $ayn=$msg->ayny('','',$webmsg);
        $ayn = 'N' if (Cfg::opt('responsefile') && !Cfg::opt('rollingupgrade_phase2'));
        if($ayn eq 'N') {
            Msg::n();
            $msg=Msg::new("To perform rolling upgrade, all systems are required to be upgraded. If you are not ready to perform rolling upgrade phase 2 on the cluster, quit the installer.\n");
            $msg->warning();
            $webmsg = $msg->{msg};
            $msg=Msg::new("Are you sure you want to quit?");
            $ayn=$msg->ayny('','',$webmsg);
            $webmsg = '';
            # quit installer
            if($ayn eq 'Y') {
                $cpic->edr_completion();
            } else {
                $decided=0;
                Msg::n();
            }
        }
    }

    # set ru_running_list & ru_idle_list for $rel
    $rel->{ru_running_list} = $sclist;
    $rel->{ru_idle_list} = [];
    # Set cpic's phase name
    $cpic->{install_phase_name} = "rollingupgrade_phase2_install";
    $cpic->{uninstall_phase_name} = "rollingupgradeu_phase2_uninstall";
    $cpic->{shutdown_phase_name} = "rollingupgrade_phase2_shutdown";
    $cpic->{startup_phase_name} = "rollingupgrade_phase2_startup";

    $rel->update_status_file("RU","Rolling upgrade phase 2",$rel->{ru_running_list});
    return $sclist;
}

# determine on which phase and which nodes should be upgraded.
sub determine_ru_syslist{
    my ($rel,$syslist)=@_;
    # @rup1list: nodes need to perform RU phase 1
    # @rup2list: nodes need to perform RU phase 2
    my (@rup1list,@rup2list);
    my $web = Obj::web();
    my $cfg = Obj::cfg();
    # @sclist: subcluster list
    my (@sclist,$sys);
    for my $sysname (@{$syslist}) {
        $sys=Obj::sys($sysname);
        if($rel->determine_ru_phase_sys($sys)==1){
            push(@rup1list,$sysname);
        }
        else {
            push(@rup2list,$sysname);
        }
    }
    # All the nodes need to do RUP1. Choose some of them to perform RUP1.
    my ($cpic,$conf,$vcs);
    my ($msg,$webmsg,$existonlinesg);
    $cpic=Obj::cpic();
    $vcs=$cpic->prod("VCS61");
    # pick the 1st node and get it's main.cf info
    $sys=Obj::sys(@{$cfg->{systems}}[0]);
    $conf=$vcs->get_config_sys($sys);
    if(@rup1list && !@rup2list) {
        # $apps{$sysname} = amount of groups $sysname has
        my (%apps,@grps);
        # sub cluster length should be half of the whole system list
        my $sclength=int((scalar(@{$syslist})+1)/2);
        my $i=0;
        for my $sysname (@rup1list) {
            if($conf->{online_servicegroups}{$sysname}) {
                $existonlinesg=1;
                last;
            }
        }
        # if there're sgs in the cluster, print them
        if(@{$conf->{groups}} && $existonlinesg) {
            $msg=Msg::new("The following service group(s) are online in the cluster:");
            if($msg) {
                $msg->bold;
                $webmsg .= "$msg->{msg}\n";
            }
            for my $sysname (@rup1list) {
                $apps{$sysname}=0;
                if($conf->{online_servicegroups}{$sysname}) {
                    $msg=Msg::new("Service Groups Online on $sysname:$conf->{online_servicegroups}{$sysname}");
                    $msg->print;
                    $webmsg .= "$msg->{msg}\n";
                    @grps=split(/\s+/,$conf->{online_servicegroups}{$sysname});
                    $apps{$sysname}=scalar(@grps);
                }
            }
            $webmsg =~ s/\n/\\n/g;
            $web->web_script_form('alert', $webmsg) if (Obj::webui());
            # choose the nodes that have least service groups.
            foreach my $key (sort { $apps{$a} <=> $apps{$b}} keys %apps) {
                if($i < $sclength) {
                    push(@sclist,$key);
                    $i++;
                }
            }
            Msg::n();
        }
        # if there're no sgs, Randomly pick up the first half nodes
        else {
            foreach my $sysname (@{$syslist}) {
                if($i < $sclength) {
                   push(@sclist,$sysname);
                }
                $i++;
            }
        }
        return $rel->ask_usr_ru1(\@sclist,$syslist,$conf);
    }
    # Some nodes need to do RUP1. Some nodes need to do RUP2.
    # So it's phase 1 second state. All other nodes should be upgraded.
    if(@rup1list && @rup2list) {
        @sclist=@rup1list;
        return $rel->ask_usr_ru1ru2(\@sclist,\@rup2list);
    }
    # All nodes have done phase 1. Perform phase 2 on all nodes
    if(!@rup1list && @rup2list) {
        @sclist=@rup2list;
        return $rel->ask_usr_ru2(\@sclist);
    }
}

# determine rolling upgrade phase if makeresponsefile option is used
sub determine_ru_phase_response {
    my ($rel, $sys) = @_;
    my $cur_ru = 1;
    my $cfg = Obj::cfg();

    my $sysname = $sys->{sys};
    for my $n (0..$rel->{vcs_subcluster_num}) {
        if (EDRu::inarr($sysname, @{$cfg->{phase1}{$n}})) {
            $cur_ru = 2;
            last;
        }
    }
    return $cur_ru;
}

# determine current rolling upgrade phase
# set $sys->{rolling_upgrade} value to indicate current RU phase
sub determine_ru_phase_sys {
    my ($rel,$sys)=@_;
    my ($llt,$vcs,$cur_ru,$lltver,$vcsver,$lltmpver,$vcsmpver,$lltpkgver,$vcspkgver,$do,$cv,$amf,$amfver,$amfmpver,$amfpkgver);
    my $cfg = Obj::cfg();

    if ($rel->{upgrade}{phase1_done}) {
	    if (grep {$sys->{sys} eq $_} @{$rel->{upgrade}{phase1_done}}) {
		    return 2;
	    } else {
		    return 1;
	    }
    }

    $llt=$rel->pkg('VRTSllt61');
    $vcs=$rel->pkg('VRTSvcs61');
    $amf=$rel->pkg('VRTSamf61');
    $lltmpver=$llt->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
    $vcsmpver=$vcs->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
    $amfmpver=$amf->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
    $lltpkgver=$sys->padv->pkg_version_sys($sys,$llt);
    $vcspkgver=$sys->padv->pkg_version_sys($sys,$vcs);
    $amfpkgver=$sys->padv->pkg_version_sys($sys,$amf);
    $lltver=$lltmpver || $lltpkgver;
    $vcsver=$vcsmpver || $vcspkgver;
    $amfver=$amfmpver || $amfpkgver;
    return '' unless($lltver && $vcsver);
    $do=$sys->cmd("_cmd_grep -v '^#' /etc/gabtab 2>/dev/null");
    $cv=EDRu::compvers($vcsver,$lltver,4);
    Msg::log("Determine rolling upgrade on $sys->{sys}: llt version is $lltver,vcs version is $vcsver");

    # Incident: 2678213
    # LLT/GAB/VXFEN doesn't have patch in 6.0RP1 cross platform. So we use VRTSamf instead.
    # in HPUX, applying patch won't change version of VRTSamf. So we have to use grep command to ensure which version it is.
    if($sys->{padv} =~ /^HPUX/) {
        my $patches=$amf->patches_sys($sys);
        my $verstring;
        if(@{$patches}) {
            $verstring=$sys->cmd("_cmd_swlist -l product 2>/dev/null | _cmd_grep @{$patches}[0] 2>/dev/null");
        }
        if($verstring =~ /RP(\d)/) {
            # For 6.0RP1 only
            $amfver |= "0.0.00" . $1 . ".000";
        } elsif ($verstring =~ /VRTS (\d+\.\d+\.\d+\.\d+)/) {
            # For 6.0.3 and future releases
            $amfver = $1;
        }
    }
    if($cv==0) {
        $cv=EDRu::compvers($vcsver,$amfver,4);
    }

    if ($do=~/-V/m && $cv==2) { # phase 2
        $cur_ru=2;
    } else { # phase 1
        if (Cfg::opt('makeresponsefile')) {
            $cur_ru = $rel->determine_ru_phase_response($sys);
        } else {
            $cur_ru=1;
        }
    }
    $sys->set_value('rolling_upgrade',$cur_ru-1);
    return $cur_ru;
}

# check rolling upgrade on systems
# return -1 prod doesn't support
# return 0  nodes have not the same status
# return 1 rolling upgrade phase1
# return 2 rolling upgrade phase2
sub determine_rolling_upgrade {
    my ($rel,$prod) = @_;
    my ($cfg,$edr,$lltmpver,$vcspkgver,$sys,$cur_ru,$padv,$vcs,$prodver,$prodobj,$lltver,$lltpkgver,$cv,$vcsmpver,$do_ru2,$diff,$syslist,$sys1_ru,$llt,$do,$vcsver);
    $edr=Obj::edr();
    $syslist=CPIC::get('systems');
    $syslist||=$edr->init_sys_objects();
    $padv=CPIC::get('padv');
    $cfg=Obj::cfg();
    $prodobj=$rel->prod($prod);
    $sys1_ru=0;
    $cur_ru=0;
    return '' unless (Cfg::opt(qw(upgrade patchupgrade hotfixupgrade)));
    for my $sys (@$syslist) {
        $cur_ru=0;
        $llt=$rel->pkg('VRTSllt61');
        $vcs=$rel->pkg('VRTSvcs61');
        $lltmpver=$llt->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
        $vcsmpver=$vcs->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
        $lltpkgver=$sys->padv->pkg_version_sys($sys,$llt);
        $vcspkgver=$sys->padv->pkg_version_sys($sys,$vcs);
        $lltver=$lltmpver || $lltpkgver;
        $vcsver=$vcsmpver || $vcspkgver;
        return '' unless($lltver && $vcsver);
        $do=$sys->cmd("_cmd_grep -v '^#' /etc/gabtab 2>/dev/null");
        #$do1=$sys->cmd("_cmd_grep -v '^#' /etc/vxfenmode 2>/dev/null");
        #return 0 unless ($do=~/vxfen_protocol_version/);
        $cv=EDRu::compvers($vcsver,$lltver,4);
        Msg::log("Determine rolling upgrade on $sys->{sys}: llt version is $lltver,vcs version is $vcsver");

        if (Cfg::opt('makeresponsefile') &&
            !Cfg::opt('upgrade_kernelpkgs') &&
            ($rel->determine_ru_phase_response($sys) == 2)) {
            $cur_ru = 1;
            $do_ru2 = 1;
        } elsif ($do=~/-V/m && $cv==2) {
            $cur_ru=1;
            $do_ru2=1;
            return 0 if(Cfg::opt('upgrade_kernelpkgs'));
        }
        $sys1_ru=$cur_ru if($sys->system1);
        $diff=1 if($sys1_ru xor $cur_ru);
    }
    return 0 if($diff);
    if($do_ru2){
        $cfg->set_value('opt,upgrade_nonkernelpkgs',1);
    }
    $prodver=$$syslist[0]->{prodvers}[0] ||'' if ($$syslist[0]->{prodvers}[0]);
    $cv=EDRu::compvers($prodver,$rel->{ru_version},2);
    return -1 if ($cv==2 && Cfg::opt(qw(upgrade_kernelpkgs)));
    return -1 if ((!EDRu::inarr($prod,@{$rel->{ru_prod}})) && (Cfg::opt(qw(upgrade_kernelpkgs upgrade_nonkernelpkgs))));
    if(Cfg::opt('upgrade_kernelpkgs')){
        return 1;
    }
    if(Cfg::opt('upgrade_nonkernelpkgs')){
        $prodobj->{stop_prod}='VCS';
        for my $sys1 (@$syslist) {$sys1->set_value("zru_supported",1);}
        return 2;
    }
}

sub determine_versmix_upgrade {
    my ($rel,$prodA,$prodB,$prodversA,$prodversB,$sys)=@_;
    return "" unless ($prodversA && $prodversB);
    my @prods=qw(DMP VM FS SF VCS SFHA);
    $prodA =~ s/\d+//m;
    $prodB =~ s/\d+//m;
    if ((EDRu::inarr($prodA,@prods) || !$prodA) &&
        (EDRu::inarr($prodB,@prods) || !$prodB)) {
        return '';
    }
    return 1 if (EDRu::compvers($prodversB,$prodversA,2));
    return '';
}

sub determine_prodmix_upgrade {
    my ($rel,$prodA,$prodB,$sys) = @_;
    my @prods=qw(DMP VM FS SF VCS SFHA);
    $prodA =~ s/\d+//m;
    $prodB =~ s/\d+//m;
    if ((EDRu::inarr($prodA,@prods) || !$prodA) &&
        (EDRu::inarr($prodB,@prods) || !$prodB)) {
        $sys->set_value('skip_versioncheck', 1) unless ($prodB);
        return '';
    }
    # ON hold - return "" if ($prodA eq "AT" || $prodB eq "AT");
    ($prodA && $prodB && ($prodA ne $prodB)) ? return 1 : return '';
    return;
}

sub determine_prodmix_install {
    my ($rel,$prodA,$prodB,$sys) = @_;
    my @vcsprods=qw(VCS SFHA SFCFSHA SFSYBASECE SVS SFRAC);
    $prodA =~ s/\d+//m;
    $prodB =~ s/\d+//m;
    if ($prodA =~ /APPLICATIONHA/ && EDRu::inarr($prodB,@vcsprods) ||
        $prodB =~ /APPLICATIONHA/ && EDRu::inarr($prodA,@vcsprods)) {
        return 1;
    }
    return 0;
}

sub determine_cross_partial_upgrade {
    my ($rel,$cprod,$uprod)=@_;
    my ($cross_matrix,$partial_matrix,$independent_matrix);
    my $uprod1=${$uprod}[0];
    return '' unless ($cprod && $uprod1);
    $cprod  =~ s/\d+//m;
    $uprod1 =~ s/\d+//m;
    return '' if ($cprod eq $uprod1);

    $cross_matrix=$rel->{cross_upgradable_matrix}->{$uprod1};
    $partial_matrix=$rel->{partial_upgradable_matrix}->{$uprod1};
    $independent_matrix=$rel->{independent_prod_matrix}->{$uprod1};
    if (defined $cross_matrix && EDRu::inarr($cprod, @$cross_matrix)) {
        return 'cross_upgrade'; # cross stack upgrade path
    } elsif (defined $cross_matrix && EDRu::inarr('ALL', @$cross_matrix) && Cfg::opt(qw/install precheck/)) {
        return 'cross_install'; # specific cross stack install path for HP platform and AT product.
    } elsif (defined $partial_matrix && EDRu::inarr($cprod, @$partial_matrix)) {
        return 'partial_upgrade'; # partial upgrade support path
    } elsif (defined $independent_matrix && EDRu::inarr($cprod, @$independent_matrix)) {
        return 'independent_upgrade';
    }
    return 'prohibited_upgrade'; # unsupported path
}

sub determine_upsell_supported {
    my ($rel,$installed_prod,$tobeinstalled_prod)=@_;
    # upsell is supported in this release
    return 1;
}

sub basic_precheck_sys {
    my ($rel,$sys)=@_;
    my ($prod,$msg,$ivers,$cprod);

    $cprod=CPIC::get('prod');
    $prod=$sys->prod($cprod);
    $ivers=$prod->version_sys($sys);
    # fix e2009315: block cross stack upgrade for SF basic installer
    if ((Cfg::opt('prodmode') eq 'SF Basic') && ($prod->{prod} ne 'SF') && $ivers && Cfg::opt(qw(upgrade patchupgrade hotfixupgrade))) {
        $msg=Msg::new("$prod->{abbr} version $ivers cannot be upgraded to $prod->{abbr} version $prod->{vers} on $sys->{sys} using SF basic installer");
        $sys->push_error($msg);
        return 0;
    }
    return 1;
}

sub upgradevers_sys {
    my ($rel,$sys) = @_;
    my ($cscript,$msg,$cprod,$prodvers,$str,$prod);
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return '' if (Cfg::opt('ignorechecks'));

    $cscript=CPIC::get('script');
    $cprod=CPIC::get('prod');
    $prod=$sys->prod($cprod);
    if (Cfg::opt('upgrade')) {
        if (!$prod->upgradeable_version_sys($sys)) {
            $prodvers=$prod->version_sys($sys);
            if ($prodvers=~/^(\d+\.\d+)/mx) {
                $prodvers=$1;
            }
            if ($prod->{prod} =~ /^AT$/m) {
                $str='4.3.x 5.0.x';
                $msg=Msg::new("Cannot upgrade $prod->{abbr} to version $prod->{vers} on $sys->{sys}. Direct upgrade of $prod->{prod} from this version to $prod->{vers} on $sys->{sys} is not supported. This release supports upgrade from $str.");
                $sys->push_error($msg);
                $sys->set_value('stop_checks', 1);
                return '';
            }
            if ($rel->{latest_mp_name}{"$prodvers"}) {
                $str=$rel->{latest_mp_name}{"$prodvers"};
                $msg=Msg::new("Cannot upgrade $prod->{abbr} to version $rel->{vers} on $sys->{sys}. Upgrades to version $rel->{vers} from version $prodvers using $cscript are only supported from $str.");
                $sys->push_error($msg);
                # Do not stop check here.
                # For the unsupported upgrade path, user has to uninstall the old version and then install the new version. But if we stop check here, user will not be able to know if there is any issue for upgrade.
                #$sys->set_value("stop_checks", 1);
                return '';
            } else {
                $str=join(' ',@{$rel->{upgradevers}});
                $msg=Msg::new("Cannot upgrade $prod->{abbr} to version $rel->{vers} on $sys->{sys}. Direct upgrade of $prod->{prod} from this version to $rel->{vers} on $sys->{sys} is not supported. This release supports upgrade from $str.");
                $sys->push_error($msg);
                # Do not stop check here.
                # For the unsupported upgrade path, user has to uninstall the old version and then install the new version. But if we stop check here, user will not be able to know if there is any issue for upgrade.
                #$sys->set_value("stop_checks", 1);
                return '';
            }
        }
    }
    return 1;
}

sub cli_installer_menu {
    my ($rel) = @_;
    my ($cfg,$cpic,$prod,$msg,$mtask,$mprod,$mmode,$moptions,$task,$cprod);
    my ($edr, $args_hash, @options);
    return '' if (Cfg::opt('responsefile') && (EDR::get('exitfile') eq ''));

    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();

    $mtask='';
    $mprod='';
    $mmode='';
    $moptions=[];

    set_menu_msgs();

    sleep 3;

    $task=$cpic->{task};
    for my $mtask (@{$rel->{args_task}}) {
        if (Cfg::opt("$mtask")) {
            $task=$mtask;
            last;
        }
    }
    $cprod=$cfg->{prod}; # for the exitfile
    $cprod||=$cpic->{orig_prod};

    while (1) {
        EDR::reset_errors_warnings();

        if ($task) {
            $mtask=lc($task);
        } else {
            $mtask||=$rel->task_menu($mtask);
            if (EDR::getmsgkey($mtask,'back')) {
                $mtask='';
                next;
            } elsif ($mtask eq 'help') {
                $rel->task_menu_help();
                $mtask='';
                next;
            }
        }
        $cpic->set_task($mtask);
        $cpic->{task}=$mtask;
        if(Cfg::opt('upgrade') && (!$task)){
            my $upgrade_task=$rel->upgrade_menu();
            if(EDR::getmsgkey($upgrade_task,'back')){
                $cfg->{opt}{$mtask}=0;
                $mprod='';
                $mtask='';
                next;
            } elsif($upgrade_task){
                Cfg::set_opt($upgrade_task);
                Msg::n();
                # According to e2789316, -makeresponsefile could not co-exists with rollingupgrade options
                # Check if -makeresponsefile options exist when user select rolling upgrade task from task menu
                @options=keys %{Obj::cfg()->{opt}};
                $args_hash->{options}=EDRu::arrdel(\@options, @{$edr->{arguments}->{args_opt}});
                $rel->process_ru_arg($args_hash) if(Cfg::opt('rolling_upgrade'));
            }
            last;
        }
        last if Cfg::opt('upgrade');
        return "" if (!$rel->{pkgs});

        if (!$cprod) {
            $mprod||=$rel->prod_menu($mtask,$mprod);
        } else {
            $mprod||=$cprod; # for exitfile
        }
        if (EDR::getmsgkey($mprod,'back')) {
            delete $cfg->{opt}{$mtask};
            $mprod='';
            $mtask='';
            next;
        }
        $cpic->set_prod($mprod);

        if (($mtask =~ /^(install|license)/mx) && (Cfg::opt('vxkeyless'))) {
            $mmode=$rel->prod_mode_menu($mtask,$mprod,$mmode);
            if (EDR::getmsgkey($mmode,'back')) {
                $mmode='';
                $mprod='';
                next;
            }
            $prod=$rel->prod($cpic->{prod});
            $prod->set_mode($mmode) if ($mmode && $prod->can('set_mode'));
            $moptions=$rel->prod_options_menu($mtask,$mprod,$mmode,$moptions);
            $prod->set_options($moptions) if (@{$moptions} && $prod->can('set_options'));
        } elsif ($mtask eq 'requirements') {
            $mprod=$cprod unless ($cpic->{script} =~ /^installer/m);;
            $rel->prod_requirements_menu($mprod);
            $mprod='';
            $mtask='';
            next;
        } elsif ($mtask eq 'desc') {
            $rel->prod_desc_menu($mprod);
            $mprod='';
            $mtask='';
            next;
        }

        last;
    }

    return '';
}

sub task_menu {
    my ($rel,$task) = @_;
    my ($m,$bs,$msg,$be,$cfg,$ts,$buf,$localsys,@mo,$mm1,$tsl,$mm2,$cpic,@mk,$mkey,$prodi,@ilprods,@tasks,$prods,$dts,$prod);
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $prods=$rel->{prods};

    # task selection
    $cpic->cli_set_title($task);
    Msg::title();

    @ilprods=();
    for my $prodi (@$prods) {
        $prod=$rel->prod($prodi);
        push(@ilprods,$prodi) if ($prod->obsoleted || ($prod->{proddir} &&
            (-d "$cpic->{basemediapath}/$prod->{proddir}")));
    }

    $localsys=Obj::localsys();
    # skipping installed products table if systems are declared because users
    # were confused that the table should be relative to the systems, not localsys
    $rel->inst_lic_sys($localsys, @ilprods) if ((!defined($cfg->{systems})) || ($#{$cfg->{systems}}<0));

    # screen 1, task selection
    undef(@mk);
    $msg=Msg::new("\nTask Menu:\n");
    $msg->bold;

    $bs=EDR::get2('tput','bs');
    $be=EDR::get2('tput','be');
    @tasks=qw(precheck install configure upgrade postcheck uninstall license start desc stop requirements help);
    @mo=@tasks;
    while (@mo) {
        $m=shift(@mo);
        $mkey=Msg::get("key_$m");
        push(@mk,$mkey);
        $mm1="$bs$mkey$be) ".Msg::get("menu_$m");
        $m=shift(@mo);
        if ($m) {
            $mkey=Msg::get("key_$m");
            push(@mk,$mkey);
            $mm2="$bs$mkey$be) ".Msg::get("menu_$m");
        } else {
            $mm2='';
        }

        # Notes:
        # skipped i18n portion
        # hard coded indent because a blank message become null message
        $buf=Msg::string_sprintf('    %-50s %s', $mm1, $mm2);
        $msg=Msg::new_obj($buf);
        $msg->print;
    }
    Msg::n();

    $ts='';
    $tsl=join(',',@mk);
    $tsl="[$tsl]";
    $dts=Msg::get("key_$task");
    $tsl.=" ($dts)" if ($dts);
    while (!EDRu::inarr($ts,@mk)) {
        $msg=Msg::new("Enter a Task: $tsl");
        $ts=$msg->ask;
        $ts=uc($ts);
    }

    Msg::n();
    for my $m (@tasks) {
        return $m if ($ts eq Msg::get("key_$m"));
    }
    return '';
}

sub task_menu_help {
    menu_help(qw(install uninstall upgrade configure));
    menu_help(qw(start stop precheck postcheck license desc requirements));
    return '';
}

sub upgrade_menu {
    my ($rel)=@_;
    my ($cpic,$task,$msg,$cfg,$menu,@dopts);

    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $cpic->cli_set_title($task);
    Msg::title();
    $cpic->{menu}=[Msg::get('menu_fullupgrade'), Msg::get('menu_rollingupgrade')];
    @dopts=('','rolling_upgrade');

    $msg=Msg::new("Select the method by which you want to upgrade the product:");
    $menu=$msg->menu($cpic->{menu}, '1', '', 1);
    if (EDR::getmsgkey($menu,'back')) {
        return EDR::get2('msg','back');
    }

    return $dopts[$menu-1];
}

sub prod_ha_menu {
    my ($rel,$task,$prodname) = @_;
    my ($msg,$cfg,$prod_ha,$prodi_ha,$n,$cpic,@dprods,$prodi,$menu,$prod,$def);

    $cpic=Obj::cpic();

    if ($prodname =~ /^SFCFS(\d+)$/mx) {
        $prodi=$prodname;
        $prodi_ha="SFCFSHA$1";
    } else {
        return $prodname;
    }

    # if user use installer script and selected SFCFS, no need to show SFCFSHA for selection.
    return $prodname if ($cpic->{script}=~/installer$/m);
    # if user use installsfcfs with license/makeresponsefile task, need provide SFCFSHA for selection
    return $prodname unless ($cpic->{script}=~/installsfcfs$/mx && EDRu::inarr($task,qw/license makeresponsefile/));

    $prod=$rel->prod($prodi);
    $prod_ha=$rel->prod($prodi_ha);

    # Show SFCFS/SFCFSHA selection.
    $cfg=Obj::cfg();

    # screen 2, product selection
    $cpic->cli_set_title($task);
    Msg::title();
    $cpic->{menu}=[];

    # @dprods contains the products which are displayed in the menu
    # this could be different from @mprods in case of licensing
    @dprods=();

    $n="$prod->{name} ($prod->{abbr})";
    push(@{$cpic->{menu}},$n);
    push(@dprods, $prodi);
    $n="$prod_ha->{name} ($prod_ha->{abbr})";
    push(@{$cpic->{menu}},$n);
    push(@dprods, $prodi_ha);
    $cpic->{dprods}=[@dprods];

    if ($task eq 'install') {
        $msg=Msg::new("Select a product to install:");
    } elsif ($task eq 'uninstall') {
        $msg=Msg::new("Select a product to uninstall:");
    } elsif ($task eq 'configure') {
        $msg=Msg::new("Select a product to configure:");
    } elsif ($task eq 'start') {
        $msg=Msg::new("Select a product to start:");
    } elsif ($task eq 'stop') {
        $msg=Msg::new("Select a product to stop:");
    } elsif ($task eq 'upgrade') {
        $msg=Msg::new("Select a product to upgrade:");
    } elsif ($task eq 'license') {
        $msg=Msg::new("Select a product to license:");
    } elsif ($task eq 'precheck') {
        $msg=Msg::new("Select a product to perform pre-installation check for:");
    } elsif ($task eq 'postcheck') {
        $msg=Msg::new("Select a product to perform post-installation check for:");
    } elsif ($task eq 'desc') {
        $msg=Msg::new("Select a product to view its product description:");
    } elsif ($task eq 'requirements') {
        $msg=Msg::new("Select a product to view its product requirements:");
    } else {
        $msg=Msg::new("Select a product:");
    }
    $menu=$msg->menu($cpic->{menu}, '2', '', 0);
    $prodi=$dprods[$menu-1];
    return $prodi;
}

sub prod_menu {
    my ($rel,$task,$prodname) = @_;
    my ($i,$msg,$cfg,@mprods,$cpic,@dprods,$mprodi,$prodi,$mprod,$menu,$prod,$def,$needback,@nobackops);

    $cpic=Obj::cpic();
    $cfg=Obj::cfg();

    # screen 2, product selection
    $cpic->cli_set_title($task);
    Msg::title();
    $cpic->{menu}=[];

    $needback=1;
    @nobackops=qw(-install -uninstall -configure -start -stop -upgrade -license -precheck -postcheck -requirements);

    # only offer products available in ESD distribution
    @mprods=();
    # @dprods contains the products which are displayed in the menu
    # this could be different from @mprods in case of licensing
    @dprods=();
    for my $mprodi (@{$rel->{menuprods}}) {
        $prod=$rel->prod($mprodi);
        if (($rel->{type}=~/^M/) || (-d "$cpic->{basemediapath}/$prod->{proddir}")) {
            push(@mprods,$mprodi);
        }
    }

    $def='';
    $i=0;
    for my $mprodi (@mprods) {
        $i++;
        $mprod=$mprodi;
        if ($mprodi eq "$prodname") {
            $def="$i";
        }
        $prod=$rel->prod($mprod);
        # Notes:
        # below routine need to be re-visited after CPIP is_licensed_sys is completed
        next if (($task eq 'license') && (!ref(UNIVERSAL::can($prod, 'licensed_sys'))));
        push(@{$cpic->{menu}},"$prod->{name} ($prod->{abbr})");
        push(@dprods, $mprodi);
    }
    $cpic->{dprods}=[@dprods];

    if ($task eq 'install') {
        $msg=Msg::new("Select a product to install:");
    } elsif ($task eq 'uninstall') {
        $msg=Msg::new("Select a product to uninstall:");
    } elsif ($task eq 'configure') {
        $msg=Msg::new("Select a product to configure:");
    } elsif ($task eq 'start') {
        $msg=Msg::new("Select a product to start:");
    } elsif ($task eq 'stop') {
        $msg=Msg::new("Select a product to stop:");
    } elsif ($task eq 'upgrade') {
        $msg=Msg::new("Select a product to upgrade:");
    } elsif ($task eq 'license') {
        $msg=Msg::new("Select a product to license:");
    } elsif ($task eq 'precheck') {
        $msg=Msg::new("Select a product to perform pre-installation check for:");
    } elsif ($task eq 'postcheck') {
        $msg=Msg::new("Select a product to perform post-installation check for:");
    } elsif ($task eq 'desc') {
        $msg=Msg::new("Select a product to view its product description:");
    } elsif ($task eq 'requirements') {
        $msg=Msg::new("Select a product to view its product requirements:");
    } else {
        $msg=Msg::new("Select a product:");
    }

    foreach my $op (@nobackops){
        if (EDRu::inarr($op,@ARGV)){
            $needback=0;
            last;
        }
    }

    if ($task =~ /^install$/mi) {
        if ($#{$cpic->{menu}}<0) {
            $msg=Msg::new("No products available for installation");
            $msg->die;
        } elsif ($#{$cpic->{menu}}==0) {
            $msg=Msg::new("$cpic->{menu}->[0] is the only product available for installation");
            $msg->print;
            $menu=1;
        } else {
            $msg=Msg::new("Select a product to install:");
            $menu=$msg->menu($cpic->{menu}, $def, '', $needback);
        }
    } elsif ($#{$cpic->{menu}}==0) {
        $menu=1;
    } else {
        $menu=$msg->menu($cpic->{menu}, $def, '', $needback);
    }

    # back menu option
    if (EDR::getmsgkey($menu,'back')) {
        return EDR::get2('msg','back');
    }

    Msg::n();
    $prodi=$dprods[$menu-1];
    return $prodi;
}

sub prod_options_menu {
    my ($rel,$task,$prodname,$mmode,$moptions) = @_;
    my ($msg,$soption,$menu_options,$ayn,$options,$option,$prod);

    $prod=$rel->prod($prodname);
    $options=[];
    $menu_options = $prod->{menu_options};
    # Select option
    if ($menu_options) {
        Msg::title() unless ($mmode);
        # have to seperate VR/VFR from GCO because replication is now a two-level menu
        $soption=$rel->prod_replication_options_menu($prod,$menu_options);
        push (@{$options}, $soption) if ($soption ne 'NONE');
        $soption='';
        # the following for loop deals with GCO options only
        for my $option (@{$menu_options}) {
           next unless ($option eq 'Global Cluster Option');
           $soption='gco' if ($option eq 'Global Cluster Option');
           # Forcing gco to 1 for prod SVS
           Cfg::set_opt('gco', 1) if ($prod->{prod} =~ /SVS/m);
           if ($soption && Cfg::opt($soption)) {
               $ayn='Y';
           } else {
               $msg=Msg::new("Would you like to enable the $option?");
               $ayn=$msg->aynn;
           }
           if ($ayn eq 'Y') {
               $ayn=1;
           } else {
               $ayn=0;
           }
           push (@{$options}, $ayn);
        }
    }
    return $options;
}

# this new sub is added for the replication option changes
# we used to have VVR only, but now VFR is added to the list
# old VVR is now VR,
# the menu is now two levels for non-SVS SF products on Solaris/Linux
#
sub prod_replication_options_menu {
    my ($rel,$prod,$menu_options) = @_;
    my ($msg,$ayn,$mode,$soption,$options,$replication_options_menu,$help,$def);

    # $options is for return array ref ;
    $options='';
    # $replication_options_menu is used by this replication selection menu
    # with gco filtered out
    # and vfr filtered out for svs (vfr is by default enabled by svs)
    $replication_options_menu=[];
    for my $option (@{$menu_options}) {
        next if ($option eq 'Global Cluster Option');
        next if (($option eq 'Symantec File Replicator Option') && ($prod->{prod} =~ /SVS/m));
        $soption='';
        $soption='vr' if ($option eq 'Symantec Volume Replicator');
        $soption='vfr' if ($option eq 'Symantec File Replicator Option');
        push (@{$replication_options_menu}, $option);
        # set the default value if already set (upgrade case)
        $options=$soption if ($soption && Cfg::opt($soption)) ;

    }
    if ($#{$replication_options_menu} == 0) {
        # ask for user option directly
        # applies to PADV(s)/Prod(s) without VFR option, i.e. non-{solaris,linux} and non-SVS
        if ($replication_options_menu->[0] && (!$options)) {
            $msg=Msg::new("Would you like to enable the $replication_options_menu->[0]?");
            $ayn=$msg->aynn;
            if ($ayn eq 'Y') {
                $ayn='vr';
            } else {
                $ayn='';
            }
            $options=$ayn;
        }
    } elsif ($#{$replication_options_menu} == 1) {
        # add a 'both' option if both vr and vfr are available for the $prod menu_options
        $msg=Msg::new("Both");
        push (@{$replication_options_menu}, $msg->{msg});
        $msg=Msg::new("Would you like to enable replication?");
        $ayn=$msg->aynn;
        return $options if ($ayn ne 'Y');
        $msg=Msg::new("Select the replication option you would like to enable");
        $help=Msg::new("Select the replication option you would like to enable");
        $def='1';
        $mode=$msg->menu($replication_options_menu, $def, $help, 0);
        Msg::n();
        # the selection is either VR or VFR
        # and it's VFT if and only if it's chosen
        if ($mode eq '2') {
            $options='vfr';
        } else {
            $options='vr';
        }
    } else {
        $options='NONE';
    }
    return $options;
}

# According to e2851079, add $firstnode parameter
# Release Compatibility check should be skiped except the first node
sub ru_precheck_sys {
    my ($rel,$sys,$firstnode) = @_;
    my ($edr,$cfg,$cpic,$web);
    my ($rtn, $jeopardy_port_a);
    my ($msg,$error);
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    $cpic=Obj::cpic();
    $web=Obj::web();
    # 3 steps to precheck
    # if the any of the check failed, print the error message and return immediately.
    my $msglist = $edr->{msglist};
    $edr->{msglist} = $msglist if ($web->{perform_rolling_upgrade});
    if (Cfg::opt('snas_upgrade')) {
        $edr->set_progress_steps(2);
    } else {
        $edr->set_progress_steps(3);
        # 1. detect if the local node can communicate with first node
        if ($edr->check_and_setup_transport_sys($sys)==-1) {
            return -1;
        }
    }
    # 2. ensure first node padv is supported
    if ($firstnode) {
        $msg=Msg::new("Checking release compatibility on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        if ($edr->supported_padv_sys($sys)) {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        } else {
            Msg::right_failed();
            Msg::n();
            for my $errmsg (@{$sys->{errors}}) {
                if(Obj::webui()){
                    $msg->addError($errmsg);
                }
                Msg::print($errmsg);
            }
            return 0;
        }
    }
    # 3. check all other stuffs
    $msg=Msg::new("Checking rolling upgrade prerequisites on $sys->{sys}");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());
    $cpic->installed_prod_sys($sys);
    $msg->display_right() if (Obj::webui());
    # different package versions on same system
    # clean up error messages
    undef ($sys->{errors});
    unless ($rel->check_installed_pkgs_version_sys($sys) && $rel->ru_prod_version_sys($sys)) {
        $msg->right_failed;
        Msg::n();
        for my $errmsg (@{$sys->{errors}}) {
            if(Obj::webui()) {
                $msg->addError($errmsg);
            }
            Msg::print($errmsg);
        }
        return 0;
    }
    # VCS must be running
    my $had;
    $had = $sys->proc_pids('bin/had');
    if (scalar(@$had)==0) {
        $msg->right_failed;
        Msg::n();
        $error=Msg::new("The cluster is not running on $sys->{sys}. The cluster must be running on all systems in order to perform rolling upgrade.");
        if(Obj::webui()){
            $msg->addError($error->{msg});
        }
        $error->error();
        return 0;
    }
    # for SFCFSHA/SFRAC/SVS/SFSYBASECE, if llt link is in jeopardy state, quit RU.
    # Due to incident 3255773, product commands are not initialized for different OS version Solaris 9.
    # As command gabconfig shares the same position in all platforms. We use full path.
    $jeopardy_port_a = $sys->cmd("/sbin/gabconfig -a 2>/dev/null | _cmd_grep 'Port a' | _cmd_grep jeopardy");

    # if port a is in jeopardy and product has CVM, we think it's not a good state and should not perform RU.
    # due to incident 2439439
    if ($jeopardy_port_a && $cpic->{prod} =~ /^(SVS|SFCFS|SFRAC|SFSYBASECE)/mx) {
        $msg->right_failed;
        Msg::n();
        $error=Msg::new("The cluster is in a jeopardy state. The cluster cannot be in jeopardy state if rolling upgrade is to be performed.");
        if(Obj::webui()){
            $msg->addError($error->{msg});
        }
        $error->error();
        return 0;
    }
    $msg->right_done;

    $msg=Msg::new("Checking service group status on $sys->{sys}");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());

    my $fault_sgs = $sys->cmd("_cmd_hagrp -list State=~FAULTED 2>/dev/null | _cmd_awk \'{if\(\"$sys->{sys}\"==\$2\) {print \$1}}'");
    if ($fault_sgs) {
	    $msg->right_failed;
	    $error = Msg::new("Service Group $fault_sgs is faulted");
	    $error->error();
	    return 0;
    }
    $msg->right_done;

    return 1;
}

sub ru_prod_version_sys {
    my ($rel,$sys)=@_;
    my ($cpic,$prod,$prodname,$ivers,$msg,$cv,$basevers_flag);
    $cpic=Obj::cpic();
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return 1 if ($rel->{lp});
    if(!$sys->{upgradeprod_abbr}) {
        # no product for upgrade, so no product installed
        $msg=Msg::new("No product is installed on $sys->{sys}");
        $sys->push_error($msg);
        return '';
    }
    if ($cpic->{prod}) {
        $prod=$sys->prod;
        $prodname=$prod->{abbr};
        $ivers=$prod->version_sys($sys);
    }
    if ($prodname ne ${$sys->{upgradeprod_abbr}}[0]) {
        # different product, unless it's SFHA+VCS, will give error.
        if(!($prodname =~ /SFHA/ && ${$sys->{upgradeprod_abbr}}[0] =~/VCS/ || $prodname =~ /VCS/ && ${$sys->{upgradeprod_abbr}}[0] =~/SFHA/)) {
            $msg=Msg::new("${$sys->{upgradeprod_abbr}}[0] is installed on $sys->{sys}, but $prodname is installed on other system(s).\nSystems running different products must be upgraded independently.");
            $sys->push_error($msg);
            return '';
        }
    }
    $cv=EDRu::compvers($ivers,$prod->{vers},4) if ($ivers);
    if ($cv==0) {
        # Todo: add mix sfha prod version check & normal product check non-kernelpkgs
        my($fs,$vcs,$fsmpver,$vcsmpver,$fsver,$vcsver,$fspkgver,$vcspkgver);
        my($pkg,$pkgver,$pkgmpver);
        if($prodname =~ /^SFHA/) {
            # if prodname=SFHA, compare it's VCS and FS version
            $fs=$rel->pkg('VRTSvxfs61');
            $vcs=$rel->pkg('VRTSvcs61');
            $fsmpver=$fs->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
            $vcsmpver=$vcs->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
            $fspkgver=$sys->padv->pkg_version_sys($sys,$fs);
            $vcspkgver=$sys->padv->pkg_version_sys($sys,$vcs);
            $fsver=$fsmpver||$fspkgver;
            $vcsver=$vcsmpver||$vcspkgver;
            # $sfhaver=$verver and $vcsver!=$fsver
            if (!EDRu::compvers($ivers,$vcsver,4) && EDRu::compvers($vcsver,$fsver,4)) {
                $msg = Msg::new("Installer detected that VCS is already upgraded on $sys->{sys}, but SF has a different version of $fsver. Please try to use the option -upgrade to perform a normal upgrade.");
                $sys->push_error($msg);
                return '';
            }
        } else {
            # Products other than SFHA should use
            # main package & VRTSvcs package to decide if it's already installed.
            $pkg=$rel->pkg('VRTSvcs61');
            $pkgver=$sys->padv->pkg_version_sys($sys,$pkg);
            $pkgmpver=$pkg->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
            $pkgver=$pkgver||$pkgmpver;
            # if the installed product is SF only, then $pkgver=NULL. Skip this
            if ($pkgver) {
                # if any non-kernel package has a version lower than the package on the media
                # assume product not installed for RU.
                if (EDRu::compvers($pkg->{vers},$pkgver,4)!=1) {
                    $msg=Msg::new("$prodname version $ivers is already installed on $sys->{sys}");
                    $sys->push_error($msg);
                    return '';
                }
            }
        }
    } elsif (Cfg::opt(qw(patchupgrade hotfixupgrade)) && !$rel->{pkgs}) {
        for my $basevers (@{$rel->{baseversions}}) {
            $basevers_flag = 1 if (!EDRu::compvers($ivers,$basevers,3));
        }
        if (!$basevers_flag) {
            $msg=Msg::new("$prodname $rel->{basevers} does not appear to be installed on $sys->{sys}");
            $sys->push_error($msg);
            return '';
        }
    } elsif ($cv==1) {
        $msg=Msg::new("A more recent version of $prodname, $ivers, is already installed on $sys->{sys}");
        $sys->push_error($msg);
        return '';
    }
    # Only some of the products allow RU
    # And it's version should be higher than 5.1
    my ($ruvers,$cprod,$prodlist);
    $ruvers=$rel->{ru_version};
    $cprod=${$sys->{upgradeprod}}[0];
    $prodlist=join(" ",@{$rel->{ru_prod}});
    $prodlist=~s/\d+//g;
    unless ($ivers) {
        $prod=$rel->prod($cprod);
        $ivers=$prod->version_sys($sys);
    }
    $cv=EDRu::compvers($ivers,$ruvers,2);
    if ($cv==2 || !EDRu::inarr($cprod,@{$rel->{ru_prod}})) {
        $cprod=~s/\d+//g;
        $msg=Msg::new("The system is installed with $cprod($ivers); but this release only supports rolling upgrade from version $ruvers of the products $prodlist.");
        $sys->push_error($msg);
        return '';
    }
    if ($prod->zru_version_sys($sys)) {
        $sys->set_value('zru_supported',1);
    } else {
        $sys->set_value('zru_supported',0);
    }
    return 1;
}

sub ru_confirm_cluster {
    my ($rel,$sys) = @_;
    # All systems must be running on the cluster
    # Only needs to be checked one time.
    my ($cpic,$conf,$vcs);
    my ($msg,$webmsg,$error);
    my ($sysname,$edr,$cfg,$web);
    $edr=Obj::edr();
    $cfg=Obj::cfg();
    $cpic=Obj::cpic();
    $vcs=$cpic->prod("VCS61");
    $conf=$vcs->get_config_sys($sys);
    # Show cluster information to user
    my($clustername,@systems,$clusterid,$syslist);
    $clustername=$conf->{clustername};
    @systems=@{$conf->{systems}};
    if (Obj::webui()) {
        $web = Obj::web();
        $web->{cluser_sys} = $conf->{systems};
    }
    # make system list accessable global scope
    $rel->{cluster_systems}=\@systems;
    $clusterid=$conf->{clusterid};
    Msg::title();
    $msg=Msg::new("Cluster information verification:\n");
    $webmsg = $msg->{msg};
    $msg->bold;
    $msg=Msg::new("\tCluster Name: $clustername\n");
    $webmsg .= $msg->{msg};
    $msg->print;
    $msg=Msg::new("\tCluster ID Number: $clusterid\n");
    $webmsg .= $msg->{msg};
    $msg->print;
    $syslist=join(' ', @systems);
    $msg=Msg::new("\tSystems: $syslist\n");
    $msg->print;
    $webmsg .= $msg->{msg};
    $webmsg =~ s/\n/\\n/g;
    $webmsg =~ s/\t/&nbsp;&nbsp;/g;
    my($ayn);
    # cluster should not be single node
    if ($#systems > 0) {
        if (!Cfg::opt('responsefile') && !Cfg::opt('snas_upgrade')) {
            $msg=Msg::new("Would you like to perform rolling upgrade on the cluster?");
            $ayn=$msg->ayny('','',$webmsg);
            Msg::n();
        } else {
            $ayn='Y';
        }
    } else {
        $msg = Msg::new("In a single node cluster upgrade service groups will not able to do failover during Rolling Upgrade. Therefore please do a Full Upgrade for single node cluster as it will take less time than Rolling Upgrade.");
        $msg->error();
        Msg::n();
        if (Obj::webui()) {
            my $web = Obj::web();
            $web->web_script_form('alert', $msg);
        }
        $ayn = 'N';
    }
    if ($ayn eq 'Y') {
        # continue rolling upgrade
        return \@systems;
    } elsif ($ayn eq 'N') {
        if (!Obj::webui()) {
            $msg=Msg::new("Would you like to perform a rolling upgrade on the other cluster?");
            $ayn=$msg->aynn;
            Msg::n();
            if ($ayn eq 'N') {
                $cpic->edr_completion();
            }
            # user want to do rolling upgrade on other cluster
            do {
                $msg=Msg::new("Enter any system of another cluster that you would like to perform rolling upgrade:");
                $sysname=$msg->ask;
                # chop extra systems, in case they enter more
                $sysname=EDRu::despace($sysname);
                $sysname=~s/\s.*$//m;
                Msg::n();
            } while ($edr->validate_systemnames($sysname));

            my $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
            # only keep one hostname in $cfg->{systems}
            @systems=($sysname);
            $cfg->{systems}=\@systems;
            # the first machine need Release Compatibility check.
            if($rel->ru_precheck_sys($sys,1)!=1) {
                return $rel->ru_confirm_cluster($sys);
            }
        }
    }
    return;
}

sub update_status_file {
    my ($rel,$op,$desc,$nodes,$state) = @_;
    my ($syslist,$total_step,$operation,$msg,$content,$nodelist,$progress,$system,$oldcontent,$oldnodes,@remainnodes);
    my $cfg = Obj::cfg();
    my $localsys=EDR::get('localsys');
    unless (defined $rel->{operation}{$op}) {
        $msg = Msg::new("No $op operation defined");
        $msg->error();
        return 0;
    }
    if ($op eq 'RU') {
        for my $sysi (@{$cfg->{ru_systems}}) {
            $system=($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
            push(@{$syslist}, $system);
        }
    } else {
        @remainnodes = @{EDRu::arrdel($cfg->{clustersystems}, @{$cfg->{systems}})};
        for my $sysi (@remainnodes) {
            $system=($Obj::pool{"Sys::$sysi"}) ? Obj::sys($sysi) : Sys->new($sysi);
            push(@{$syslist}, $system);
        }
    }
    $state ||= "ONGOING";
    $nodelist = '';
    $nodelist = join(',',@$nodes) if((defined $nodes)&&($nodes ne ''));
    ($total_step,$operation) = split(/,/,$rel->{operation}{$op});
    # Should be only one operation at one time
    if ($desc) {
        if (defined $rel->{curr_step}) {
            $rel->{curr_step} += 1;
        } else {
            $rel->{curr_step} = 1;
        }
        $progress = "Stage $rel->{curr_step} of $total_step : ";
        $desc = $progress.$desc;
    } else {
        $oldcontent = $localsys->cmd("_cmd_cat $rel->{status_file} 2>/dev/null | _cmd_grep '$operation'");
        (undef,$oldnodes,$desc,undef) = split(/\|/, $oldcontent);
    }
    $nodelist ||= $oldnodes;
    $content = "$operation|$nodelist|$desc|$state|$$|$localsys->{sys}";
    # If the operation is done, just remove the related status line
    $localsys->cmd("_cmd_sed -i '/^$operation.*\$/'d $rel->{status_file}");
    EDRu::appendfile($content, $rel->{status_file}) unless (uc($state) eq "DONE");

    #copy to other systems
    for my $sys (@{$syslist}) {
	    next if $sys->{islocal};
	    $localsys->copy_to_sys($sys, $rel->{status_file}, $rel->{status_file}, 'noerr');
    }
    return 1;
}

sub get_ru_status {
    my ($rel) = @_;
    my $content = EDRu::readfile($rel->{status_file});
    return EDR::cmd_local("_cmd_awk 'END {print \$2}' $rel->{status_file}")
}

sub ru_check_cluster {
    my ($rel,$syslist)=@_;
    my ($sys, $msg, $error);
    my $cpic=Obj::cpic();
    # 1. Rolling upgrade for cluster with different products installed in nodes should be blocked.
    my $prior_node = '';
    my $prior_node_prod = '';
    $msg=Msg::new("Checking the product compatibility of the nodes in the cluster");
    $msg->left;
    $msg->display_left($msg) if (Obj::webui());
    for my $sysname (@{$syslist}) {
        $sys=$Obj::pool{"Sys::$sysname"};
        $cpic->installed_prod_sys($sys) unless (${$sys->{upgradeprod_abbr}}[0]);
        my $tmp_prod = ${$sys->{upgradeprod_abbr}}[0];
        $tmp_prod =~ s/\d//mg;
        if ($prior_node_prod) {
            if(!($tmp_prod eq $prior_node_prod)) {
                Msg::right_failed();
                Msg::n();
                $error = Msg::new("$prior_node_prod is installed on $prior_node, but $tmp_prod is installed on $sysname. Rolling upgrade is supported only if the same products are installed in the cluster.");
                if(Obj::webui()) {
                    $msg->addError($error->{msg});
                }
                $error->error();
                return 0;
            }
        }
        $prior_node = $sysname;
        $prior_node_prod = $tmp_prod;
    }
    Msg::right_done();
    Msg::n();
    return 1;
}

# perform rolling upgrade on following systems.
sub perform_rolling_upgrade {
    my ($rel,$syslist)=@_;
    my ($sys,$msg);
    my $cpic=Obj::cpic();
    # precheck remain sys
    my $web=Obj::web();
    my $stage=Msg::new("Verifying systems");
    # Due to incident 3268512, print a message explaining what packages will be upgraded during rolling upgrade
    $msg=Msg::new("Rolling upgrade phase 1 upgrades all VRTS product packages except non-kernel packages.\nRolling upgrade phase 2 upgrades all non-kernel packages including: VRTSvcs VRTSvcswiz VRTScavf VRTSvcsag VRTSvcsea VRTSvbs");
    $msg->printn();
    if(Obj::webui()){
        $msg=Msg::new("Rolling upgrade phase 1 upgrades all VRTS product packages except non-kernel packages.\\nRolling upgrade phase 2 upgrades all non-kernel packages including: VRTSvcs VRTSvcswiz VRTScavf VRTSvcsag VRTSvcsea VRTSvbs")->{msg};
        $web->web_script_form('alert', $msg);
        $web->{not_change_side_bar} = '1';
        $web->web_script_form('showstatus',$stage);
        $web->{perform_rolling_upgrade}=1;
        delete $web->{not_change_side_bar};
    }
    for my $sysname (@{$syslist}) {
        # exclude the sys already checked
        next if($Obj::pool{"Sys::$sysname"});
        $sys=Sys->new($sysname);
        if ($rel->ru_precheck_sys($sys)!=1) {
            $cpic->edr_completion();
        }
    }
    delete $web->{perform_rolling_upgrade};
    # if single node cluster perform RU, don't print blank line
    Msg::n() if(scalar(@{$syslist}) > 1);
    $cpic->edr_completion() unless ($rel->ru_check_cluster($syslist));
    # determine ru state
    # get list to do rolling upgrade.
    my $upgradelist=$rel->determine_ru_syslist($syslist);
    return join(' ', @{$upgradelist});
    # then set package and begin installation.
}

# if user decide to perform ru on another cluster
sub ru_check_newnode {
    my ($rel) = @_;
    my ($edr,$cpic,$cfg,$web,$sysname,@systems,$sys,$retry,$check_ret);
    $edr = Obj::edr();
    $cpic=Obj::cpic();
    $cfg = Obj::cfg();
    $web = Obj::web();
    do {
        # the following codes are moved from cli_prod_option
        # after EDR v1.1 ready they'll be removed
        my $msg = Msg::new("Enter one system of the cluster on which you would like to perform rolling upgrade");
        my $helpmsg=Msg::new("You are required to provide one system of the cluster. Installer will detect the other systems of the cluster automatically.");
        if (Obj::webui()) {
            $cfg->{systems} = $web->web_script_form('selectCluster', $msg);
            $sysname=${$cfg->{systems}}[0];
            $web->web_script_form('precheck');
        } else {
            # get first node
            my $localsys=Obj::localsys();
            $edr->{savelog}=1;
            if (!$cfg->{systems}) {
                if ($cfg->{opt}{hostfile}) {
                    $sysname = EDRu::readfile($cfg->{opt}{hostfile});
                } else {
                    $sysname = $msg->ask($localsys->{sys},$helpmsg);
                    Msg::n();
                }
                @systems=split(/\s+/m,$sysname);
                while ($edr->validate_systemnames(@systems)) {
                    if (Cfg::opt('hostfile')) {
                        $msg=Msg::new("Invalid host file: $cfg->{opt}{hostfile}");
                        $msg->warning;
                        Cfg::unset_opt('hostfile');
                    }
                    $sysname = $msg->ask($localsys->{sys},$helpmsg);
                    Msg::n();
                    @systems=split(/\s+/m,$sysname);
                }
                $cfg->{systems}=\@systems;
            }
            $sysname=${$cfg->{systems}}[0];
            # only keep one hostname in $cfg->{systems}
            @systems=($sysname);
            $cfg->{systems}=\@systems;
        }
        # end
        $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
        # the first machine need Release Compatibility check.

        $check_ret = $rel->ru_precheck_sys($sys,1);
        $retry = 0;
        if ($check_ret==-1) {
            undef $cfg->{systems};
            $retry = 1;
        }
    }while($retry);

    if ($check_ret==1) {
        # user confirm to do ru on the detected cluster
        my $syslist=$rel->ru_confirm_cluster($sys);
        if($syslist) {
            return $rel->perform_rolling_upgrade($syslist);
        }
    }
    $cpic->edr_completion();
}

sub cli_prod_option {
    my ($rel) = @_;
    # the annotation will be used when EDR v1.1 ready.
    # then rolling upgrade will be like option -security, -addnode.
    # it will go different flow and CPI won't check node twice.
#    return '' if (Cfg::opt('upgrade') && !Cfg::opt('rolling_upgrade'));
#    if (Cfg::opt('rolling_upgrade')) {
#        # get first node
#        my ($cfg,$edr);
#        my ($sys,$sysname,$localsys);
#        $edr=Obj::edr();
#        $cfg=Obj::cfg();
#        $localsys=Obj::localsys();
#        $sysname=$localsys->{sys};
#        $edr->{savelog}=1;
#        if(${$cfg->{systems}}[0]) {
#            $sysname=${$cfg->{systems}}[0];
#        }
#        # precheck first node
#        $rel->ru_check_newnode($sysname);
#    }
#    elsif (!Cfg::opt('upgrade')) {
#        my $cprod=CPIC::get('prod');
#        $rel->prod($cprod)->cli_prod_option();
#    }
    return '' if (Cfg::opt('upgrade'));
    my $cprod=CPIC::get('prod');
    $rel->prod($cprod)->cli_prod_option();
    return '';
}

sub web_prod_option {
    my ($rel) = @_;
    return '' if (Cfg::opt('upgrade'));
    my $cprod = CPIC::get('prod');
    $rel->prod($cprod)->web_prod_option();
    return '';
}

# added a new sub to deal with prod license type (vxkeyless by default, a traditional key as a choice)
#
sub license_option {
    my ($rel,$bypass_msg) = @_;
    my ($msg,$cfg,$type,$lic_types,$help);
    return '' if ($rel->{lp});

    $cfg=Obj::cfg();
    return '' if (Cfg::opt('responsefile'));

    # Select product license type : vxkeyless or enter a license key
    $msg=Msg::new("Enter a valid license key");
    push(@{$lic_types},$msg->{msg});
    $msg=Msg::new("Enable keyless licensing and complete system licensing later");
    push(@{$lic_types},$msg->{msg});

    if (Cfg::opt('vxkeyless') eq '') {
        if (Obj::webui()){
            my $web = Obj::web();
            $web->web_script_form('license_type');
        } else {

            Msg::title();
            $msg=Msg::new("To comply with the terms of Symantec's End User License Agreement, you have 60 days to either:\n\n * Enter a valid license key matching the functionality in use on the systems\n * Enable keyless licensing and manage the systems with a Management Server. For more details visit http://go.symantec.com/sfhakeyless. The product is fully functional during these 60 days.\n");
            $msg->print;

            $msg=Msg::new("How would you like to license the systems?");
            #$help=Msg::new("Proceed with:");
            $type=$msg->menu($lic_types, '2', $help, 0);
            Msg::n();
            if ($type eq '2') {
                Cfg::set_opt('vxkeyless', 1);
                Cfg::set_opt('updatekeys', 1);
            }
            Cfg::set_opt('bypass_licensing', 1) if ($type eq '3');
        }
    }
    return $type;
}

# added a new sub to deal with prod vxkeyless license type (Permanent by default, EVAL if chosen)
#
sub cli_license_vxkeyless_option {
    my ($rel) = @_;
    my($lic_types,$type,$msg,$help);
    return '' if ($rel->{lp});

    # Select product license type : Permanent or EVAL

    $msg=Msg::new("Permanent");
    push(@{$lic_types},$msg->{msg});
    $msg=Msg::new("Evaluation Only");
    push(@{$lic_types},$msg->{msg});

    if (Cfg::opt('eval') eq '') {
        Msg::title();

        $msg=Msg::new("Select product vxkeyless license type:");
        $help=Msg::new("Select product vxkeyless license type");
        $type=$msg->menu($lic_types, '1', $help, 0);
        Msg::n();
        Cfg::set_opt('eval', 1) if ($type eq '2');
    }
    return $type;
}

# added a new sub to deal with language pack selection
# Date: 2009-04-07
#
sub cli_language_menu {
    my ($rel) = @_;
    my ($edr,$cprod,$prod,$lang_selection,$default_lang,$selected_lang,$msg,$help,$def,$type,$ja,$zh);

    $cprod=CPIC::get('prod');
    return '' unless ($rel->{lp});

    if ($cprod) {
         $prod=$rel->prod($cprod);
         return '' if ($prod->{prod} ne 'LP');
    } else {
         return '';
    }

    # return if the language is determined
    if ($prod->{lang}) {
        $prod->getlangpkg();
         return '';
    }

    $ja=Msg::new("Japanese Language Packages");
    push(@{$lang_selection},$ja->{msg});
    $zh=Msg::new("Chinese (Simplified) Language Packages");
    push(@{$lang_selection},$zh->{msg});
    $default_lang = 1;
    $selected_lang = 'ja';

    Msg::title();

    if (Cfg::opt('install')) {
        $msg=Msg::new("Select Language Packages to install:");
        $help=Msg::new("Select Language Packages to install");
    } else {
        $msg=Msg::new("Select Language Packages to uninstall:");
        $help=Msg::new("Select Language Packages to uninstall");
    }
    $def=$default_lang||'1';
    $type=$msg->menu($lang_selection, $def, $help);
    Msg::n();
    $selected_lang='zh' if ($type eq '2');

    $prod->{lang}=$selected_lang;
    $prod->getlangpkg();
    return '';
}

sub prod_mode_menu {
    my ($rel,$task,$prodname,$mmode) = @_;
    my ($menu_modes,$msg,$mode,$default_mode,$help,$prod,$def);

    $prod=$rel->prod($prodname);
    $mode='';

    # Select product mode and options
    $menu_modes = $prod->{menu_modes};
    $default_mode = $prod->{default_mode}+1;
    # Select mode
    if ($menu_modes && (Cfg::opt('prodmode') eq '')) {
        Msg::title();
        $msg=Msg::new("Select product mode to install:");
        if ($task eq 'license') {
            $msg=Msg::new("Select product mode to license:");
        }
        $help=Msg::new("Select product mode");
        $def=$mmode||$default_mode||'1';
        $mode=$msg->menu($menu_modes, $def, $help, 1);
        # back menu option
        if (EDR::getmsgkey($mode,'back')) {
            return EDR::get2('msg','back');
        }
        Msg::n();
    }
    return $mode;
}

sub prod_desc_menu {
    my ($rel,$prodname) = @_;
    my ($msg,$ayn,$task,$menu,$prod);
    $prod=$rel->prod($prodname);

    # description menu
    if (ref(UNIVERSAL::can($prod, 'description'))) {
        $prod->description;
    } else {
        $msg=Msg::new("No description for $prod->{name} defined\n");
        $msg->print;
    }
    Msg::prtc();
    while (1) {
        Msg::title();
        $msg=Msg::new("Select a product to view its product description:");
        $menu=$msg->menu(CPIC::get('menu'), '', '', 1);
        # back menu option
        if (EDR::getmsgkey($menu,'back')) {
            return '';
        }
        Msg::n();
        $prodname=CPIC::get('dprods')->[$menu-1];
        $prod=$rel->prod($prodname);
        if (ref(UNIVERSAL::can($prod, 'description'))) {
            $prod->description;
        } else {
            $msg=Msg::new("No description for $prod->{name} defined\n");
            $msg->print;
        }
        Msg::prtc();
    }
    return '';
}

sub prod_requirements_menu {
    my ($rel,$prodname) = @_;
    my ($msg,$ayn,$task,$cpic,$menu,$prod);
    $cpic=Obj::cpic();
    $prod=$rel->prod($prodname);

    # requirements menu
    $prod->cli_print_requirements($rel);
    $cpic->completion();

    return '';
}

sub inst_lic_sys {
    my ($rel,$sys,@prods) = @_;
    my ($cpic,$padv,$padvisa,$msg,$prodi,$format,$pl,$name,$prod,$iv,$pkg,$ivers,$lic);

    return '' if ($#prods<0);

    $cpic=Obj::cpic();
    $padv=$cpic->{padv};

    $padvisa=EDR::get2('padvisa', $sys->{padv});
    $padvisa||=$sys->{padv};

    # Need to be replaced by better way of detection of CPI script's padv
    # Currently just stripped from the installer file name

    if (($sys->{padv} ne $padv) && ($padvisa ne $padv)) {
    # Usability prefers to not display the table without any such warning message now that we are doing Any to Any
    #    $msg=Msg::new("\nCannot determine product install/license status on system $sys->{sys} as its platform is $sys->{padv}. Software included in this distribution is intended for systems of platform $padv.\n");
    #    $msg->print;
        return '';
    }

    # get the license info for all prods
    $rel->read_licenses_sys($sys);
    $sys->pkgs_patches();

    $format = '%-24s %42s    %-s';
    my $vi=Msg::new("Version Installed on $sys->{sys}");
    $pl=Msg::string_sprintf($format, Msg::get('menu_vendor_prod'), $vi->{msg},
                      Msg::get('menu_version_licensed'));
    $format = '%-51s %-18s %-s';

    Msg::bold($pl);
    print '=' x 80 . "\n";
    $pkg=$rel->pkg('VRTSvlic32');
    $iv=$pkg->version_sys($sys);
    if (!$iv) {
        $msg=Msg::new("Symantec Licensing Utilities (VRTSvlic) are not installed due to which products and licenses are not discovered.\nUse the menu below to continue.\n");
        $msg->print;
    } else {
        for my $prodi (@prods) {
            $prod=$rel->prod($prodi);
            $name=$prod->{name};
            $iv=$prod->version_sys($sys);
            $iv = (split(/%/m, $iv))[0] if ($iv =~ /%/m); # Split on '%' if it exists.
            if ($prod->obsoleted) {
                next if (!$iv);
                next if (!EDRu::compvers($iv,$rel->{vers},3));
            }
            $ivers=($iv) ? $iv : Msg::get('installed_none');
            $lic=($rel->prod_licensed_sys($sys, $prodi)) ?
                          Msg::get('license_yes') : Msg::get('license_no');
            $pl=Msg::string_sprintf($format, $name, $ivers, $lic);
            Msg::print($pl);
        }
    }
    return;
}

sub set_menu_msgs {
    my ($edr,$msg,$pdfrs);

    # menu license screen msgs
    $msg=Msg::new("Symantec Product");
    $msg->msg('menu_vendor_prod');
    $msg=Msg::new("Version Installed");
    $msg->msg('menu_version_installed');
    $msg=Msg::new("Licensed");
    $msg->msg('menu_version_licensed');

    # menu task selection
    # e1534297:  should not translate shortcut key.
    $edr=Obj::edr();
    #$msg=Msg::new("I");
    #$msg->msg("key_install");
    $edr->{msg}{key_install}='I';
    #$msg=Msg::new("G");
    #$msg->msg("key_upgrade");
    $edr->{msg}{key_upgrade}='G';
    #$msg=Msg::new("C");
    #$msg->msg("key_configure");
    $edr->{msg}{key_configure}='C';
    #$msg=Msg::new("L");
    #$msg->msg("key_license");
    $edr->{msg}{key_license}='L';
    #$msg=Msg::new("P");
    #$msg->msg("key_precheck");
    $edr->{msg}{key_precheck}='P';
    #$msg->msg("key_postcheck");
    $edr->{msg}{key_postcheck}='O';
    #$msg=Msg::new("U");
    #$msg->msg("key_uninstall");
    $edr->{msg}{key_uninstall}='U';
    #$msg=Msg::new("S");
    #$msg->msg("key_start");
    $edr->{msg}{key_start}='S';
    #$msg=Msg::new("X");
    #$msg->msg("key_stop");
    $edr->{msg}{key_stop}='X';
    #$msg=Msg::new("D");
    #$msg->msg("key_desc");
    $edr->{msg}{key_desc}='D';
    #$msg=Msg::new("?");
    #$msg->msg("key_help");
    $edr->{msg}{key_help}='?';

    $edr->{msg}{key_requirements}='R';
    $edr->{msg}{key_quit}='Q';

    # Installation Menu
    $msg=Msg::new("Install a Product");
    $msg->msg('menu_install');
    $msg=Msg::new("Upgrade a Product");
    $msg->msg('menu_upgrade');

    #sub menu for upgrade
    $msg=Msg::new("Full Upgrade");
    $msg->msg('menu_fullupgrade');
    $msg=Msg::new("Rolling Upgrade");
    $msg->msg('menu_rollingupgrade');
    $msg=Msg::new("Rolling Upgrade Phase 1");
    $msg->msg('menu_rollingupgrade1');
    $msg=Msg::new("Rolling Upgrade Phase 2");
    $msg->msg('menu_rollingupgrade2');

    $msg=Msg::new("Configure an Installed Product");
    $msg->msg('menu_configure');
    $msg=Msg::new("License a Product");
    $msg->msg('menu_license');
    $msg=Msg::new("Perform a Pre-Installation Check");
    $msg->msg('menu_precheck');
    $msg=Msg::new("Perform a Post-Installation Check");
    $msg->msg('menu_postcheck');
    $msg=Msg::new("Uninstall a Product");
    $msg->msg('menu_uninstall');
    $msg=Msg::new("Start a Product");
    $msg->msg('menu_start');
    $msg=Msg::new("Stop a Product");
    $msg->msg('menu_stop');
    $msg=Msg::new("View Product Descriptions");
    $msg->msg('menu_desc');
    $msg=Msg::new("View Product Requirements");
    $msg->msg('menu_requirements');
    $msg=Msg::new("Help");
    $msg->msg('menu_help');
    $msg=Msg::new("Quit");
    $msg->msg('menu_quit');

    # menu license msgs
    $msg=Msg::new("none");
    $msg->msg('installed_none');
    $msg=Msg::new("yes");
    $msg->msg('license_yes');
    $msg=Msg::new("no");
    $msg->msg('license_no');

    # menu Help msg
    $pdfrs=Msg::get('pdfrs');
    $msg=Msg::new("Installs $pdfrs and patches for an initial installation");
    $msg->msg('help_install');
    $msg=Msg::new("Starts processes associated with product");
    $msg->msg('help_start');
    $msg=Msg::new("Stops processes associated with product");
    $msg->msg('help_stop');
    $msg=Msg::new("Upgrades all $pdfrs and patches installed on the systems");
    $msg->msg('help_upgrade');
    $msg=Msg::new("Configures the product after installing a product without configuration");
    $msg->msg('help_configure');
    $msg=Msg::new("Installs or updates a product license key. This option can be used to update an evaluation key to a permanent key, or to license a feature in a previously installed product.");
    $msg->msg('help_license');
    $msg=Msg::new("Performs a pre-installation check to determine if systems meet all installation requirements. No products are installed.");
    $msg->msg('help_precheck');
    $msg=Msg::new("Performs a post-installation check to determine if systems are in healthy status.");
    $msg->msg('help_postcheck');
    $msg=Msg::new("Removes the selected product's $pdfrs, patches, files, and directories from the system provided they are not used by another Symantec product");
    $msg->msg('help_uninstall');
    $msg=Msg::new("Displays a brief overview of the selected product");
    $msg->msg('help_desc');
    $msg=Msg::new("Displays the brief requirements of the selected product");
    $msg->msg('help_requirements');

    return '';
}

sub menu_help {
    my @mo = @_;
    my ($m,$mkey,$mm,$bs,$be);
    Msg::title();

    $bs=EDR::get2('tput','bs');
    $be=EDR::get2('tput','be');
    while (@mo) {
        $m=shift(@mo);
        $mkey=Msg::get("key_$m");
        $mm="$bs$mkey$be) ".Msg::get("menu_$m");
        print("$mm\n\n");
        $mm=Msg::linebreak(Msg::get("help_$m"));
        print("$mm\n");
        print("\n") if (@mo);
    }
    Msg::prtc();
    return;
}

sub new_pkg_init_common {
    my ($rel,$pkg) = @_;
    my ($sfmh_pkg,$sys,$syslist);
    $syslist=CPIC::get('systems');

    push(@{$pkg->{softdeps}}, 'VRTSobc33')
        if ($pkg->{pkg} eq 'VRTSicsco');
    push(@{$pkg->{softdeps}}, 'VRTSobc33')
        if ($pkg->{pkg} eq 'VRTSpbx');
    push(@{$pkg->{stopprocs}}, 'vxpal50')
        if ($pkg->{pkg} eq 'VRTSobc33');
    if ($pkg->{pkg} eq 'VRTSdcli') {
        push(@{$pkg->{stopprocs}}, 'vxdclid50', 'xprtld50');
        $sfmh_pkg=$rel->pkg('VRTSsfmh60');
        for my $sys (@$syslist) {
           if ($sfmh_pkg->version_sys($sys)) {
               $pkg->{force_uninstall}=1;
               last;
           }
        }
    }

    if ($pkg->{pkg} eq 'VRTSmh') {
        no strict 'refs';
        no warnings 'redefine';
        # define new preremove_sys
        my $pkg_preremove_method="Pkg\::$pkg->{pkg}\::$pkg->{padv}\::preremove_sys";
        *{$pkg_preremove_method} = sub {
            my ($pkg1,$sys1)= @_;

            my $rootpath=Cfg::opt('rootpath')||'';
            if ($sys1->exists("$rootpath/opt/VRTSmh/bin/remove_cmsf.sh")) {
                # remove vxvm-discovery and rc scripts
                Msg::log('VRTSmh preremove:  calling /opt/VRTSmh/bin/remove_cmsf.sh to remove vxvm-discovery rc scripts');
                $sys1->cmd("$rootpath/opt/VRTSmh/bin/remove_cmsf.sh </dev/null >/dev/null 2>&1");
            }
            return 1;
        };
    }

    if ($pkg->{pkg} eq 'VRTSobgui' || $pkg->{pkg} eq 'VRTSmuobg' ) {
        no strict 'refs';
        no warnings 'redefine';
        # define new donotuninstall_sys
        my $donotuninstall_method="Pkg\::$pkg->{pkg}\::$pkg->{padv}\::donotuninstall_sys";
        *{$donotuninstall_method} = sub {
            my ($pkg1,$sys1)=@_;
            my $vers=$sys1->{pkgvers}{$pkg1->{pkg}};
            my $cv=EDRu::compvers($vers,'3.4',2);
            return ($cv==2) ? 0 : 1;
        }
    }

    if ($pkg->{pkg} eq 'VRTScutil') {
        $pkg->{nopreun}=1;
        no strict 'refs';
        no warnings 'redefine';
        # define new preremove_sys
        my $pkg_preremove_method="Pkg\::$pkg->{pkg}\::$pkg->{padv}\::preremove_sys";
        *{$pkg_preremove_method} = sub {
            my ($pkg1,$sys1)= @_;

            my $rootpath=Cfg::opt('rootpath')||'';
            my $file = "$rootpath/opt/VRTSvcs/bin/hagui";
            if ($sys1->is_symlink($file)) {
                $sys1->rm($file);
            }
            return 1;
        };
    }

    return;
}

sub require_versionmatrix_lib {
    my $rel=shift;
    my ($relvers,$vcfile);
    (undef, $relvers) = split(/::/m,$rel->{class},3);
    if ( $relvers =~ /^([A-Z]+)([0-9].*)$/m) {
        $vcfile=$1.'Vers'.$2.'.pl';
        require "Rel/$vcfile";
    }
    my $require_file = Cfg::opt('require');
    if ($require_file) {
        EDR::force_require($require_file);
    }
    return;
}

sub flash_archive {
    my ($rel) = @_;
    my($basename,$cpic,$edr,$backopt,$plat,$savepath,@relver,$relvers,$fh,$msg);
    my($vrts_postdeployment_script,$vrts_postdeployment_conf,$vrts_postdeployment_help);
    $cpic=Obj::cpic();
    @relver=split(/\D+/m,$rel->{vers});
    $relvers=$relver[0].$relver[1];
    $edr=Obj::edr();
    $plat=EDRu::plat($cpic->{padv});
    $backopt=0;
    unless (Cfg::opt('flash_archive') && $plat =~ /SunOS/m) {
        $msg = Msg::new("The -flash_archive option is only supported on Solaris platform");
        $msg->warning();
        return '';
    }
    $savepath = Cfg::opt('flash_archive');

    # setup the vrts_postdeployment.sh script
    $vrts_postdeployment_script = <<'_EOF_';
#!/bin/sh

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
# shall be solely in accordance with the terms of this Agreement.  $0

echo "==== Executing VRTS Flash archive post_deployment script: $me ===="

PATH=$PATH:/sbin:/usr/sbin
export PATH

#
# Notice:
# * Modify the CONF_DIR and FLASH_DIR below according to your
# * real environment
# * The location specified with CONF_DIR and FLASH_DIR should be under
#   the locally installed Jumpstart Flash archive
#

CONF_DIR="/a/etc/vx"
for file in `cat $CONF_DIR/vrts_postdeployment.cf`; do
    if [ -f /a$file ]; then
        newfile="$file.previous"
        echo "mv /a$file /a$newfile"
        mv /a$file /a$newfile
    fi
done

mkdir -p $CONF_DIR/reconfig.d/state.d
rm -f $CONF_DIR/reconfig.d/state.d/install-db
touch $CONF_DIR/reconfig.d/state.d/install-db

rm -f $CONF_DIR/vrts_postdeployment.cf

exit 0;
_EOF_

    # setup the vrts_postdeployment.cf with list of possible VRTS-related config files
    $vrts_postdeployment_conf = <<'_CONF_';
/etc/VRTSvcs/conf/config/CFSTypes.cf
/etc/VRTSvcs/conf/config/CRSResource.cf
/etc/VRTSvcs/conf/config/CVMTypes.cf
/etc/VRTSvcs/conf/config/Db2udbTypes.cf
/etc/VRTSvcs/conf/config/MultiPrivNIC.cf
/etc/VRTSvcs/conf/config/OracleASMTypes.cf
/etc/VRTSvcs/conf/config/OracleTypes.cf
/etc/VRTSvcs/conf/config/PrivNIC.cf
/etc/VRTSvcs/conf/config/SybaseTypes.cf
/etc/VRTSvcs/conf/config/main.cf
/etc/VRTSvcs/conf/config/main.cmd
/etc/VRTSvcs/conf/config/master.main.cf
/etc/VRTSvcs/conf/config/types.cf
/etc/VRTSvcs/conf/extra_types_cf
/etc/gabtab
/etc/llthosts
/etc/llttab
/etc/vxfendg
/etc/vxfenmode
/etc/vxfentab
/etc/vx/.uuids/clusuuid
/etc/vx/.vold_msg_buf_shm
/etc/vx/.vxesd.lock
/etc/vx/array.info
/etc/vx/cbr
/etc/vx/ddlconfig.info
/etc/vx/disk.info
/etc/vx/dmpevents.log
/etc/vx/dmppolicy.info.tmp
/etc/vx/guid.state
/etc/vx/jbod.info
/etc/vx/tempdb
/etc/vx/tempdb/cpi_cfs_dg
/etc/vx/vold_diag
/etc/vx/vold_diag/socket
/etc/vx/vold_inquiry
/etc/vx/vold_inquiry/socket
/etc/vx/vold_request
/etc/vx/vold_request/socket
/etc/vx/vxdba/logs/vxdbd.log
/etc/vx/vxdmp.exclude
/etc/vx/vxesd/vxesd.socket
/etc/vx/vxvm.exclude
_CONF_
# the following line may not be needed to rename
#/etc/vx/volboot

    # setup the vrts_postdeployment.help with brief instructions of how to include
    # vrts_deployment.sh & vrts_postdeployment.cf in the  to-be-created Flash Archive
    $vrts_postdeployment_help = <<'_HELP_';
The generated files, vrts_deployment.sh & vrts_postdeployment.cf, are customized
Flash archive postdeployment scripts to unconfigure VRTS product settings on a
clone system before initial rebooting. They should be included in your Flash archive(s)
as
    /etc/flash/postdeployment/vrts_postdeployment.sh
and
    /etc/vx/vrts_postdeployment.cf
in order to affect all clone systems. Please also make sure the two files having
the following ownership and permissions:
    chown root:root /etc/flash/postdeployment/vrts_postdeployment.sh
    chmod 755 /etc/flash/postdeployment/vrts_postdeployment.sh

    chown root:root /etc/vx/vrts_postdeployment.cf
    chmod 644 /etc/vx/vrts_postdeployment.cf
Please be reminded that you may not need them in a Flash archive which doesn't have
our VRTS product(s) installed.

For Flash archive creation, please use flarcreate command by following the Solaris
installation instructions on its official web site.
_HELP_

    # Code to write vrts_postdeployment.sh file
    $basename = Cfg::opt('flash_archive') . '/' . 'vrts_postdeployment.sh';
    $msg=Msg::new("Cannot open $basename for generating the vrts_postdeployment.sh script");
    open ($fh, '>', $basename) or $msg->die;
    print $fh $vrts_postdeployment_script;
    close($fh);
    EDR::cmd_local("_cmd_chmod +x $basename");
    $msg=Msg::new("The vrts_postdeployment.sh script is generated at $basename");
    $msg->bold;

    # Code to write vrts_postdeployment.cf file
    $basename = Cfg::opt('flash_archive') . '/' . 'vrts_postdeployment.cf';
    $msg=Msg::new("Cannot open $basename for generating the vrts_postdeployment.cf script");
    open ($fh, '>', $basename) or $msg->die;
    print $fh $vrts_postdeployment_conf;
    close($fh);
    EDR::cmd_local("_cmd_chmod +x $basename");
    $msg=Msg::new("The vrts_postdeployment.cf script is generated at $basename");
    $msg->bold;

    # Code to write vrts_postdeployment.help file
    $basename = Cfg::opt('flash_archive') . '/' . 'vrts_postdeployment.help';
    $msg=Msg::new("Cannot open $basename for generating the vrts_postdeployment.help script");
    open ($fh, '>', $basename) or $msg->die;
    print $fh $vrts_postdeployment_help;
    close($fh);
    EDR::cmd_local("_cmd_chmod +x $basename");
    $msg=Msg::new("The vrts_postdeployment.help script is generated at $basename");
    $msg->bold;

    return;
}

sub jumpstart {
    my ($rel) = @_;
    my($basename,$cpic,$patchlist,$plat,$pkg,$pkgslist,@pkgs,@patches,$pkgi,$prods,$prod,$prodi,$relvers,$savepath);
    my(@relver,$ayn,$backopt,$boot_dgname,$default_dmname,$dmname,$edr,$fh,$help,$mod_rel,$msg,$region_length,$patchi,$patch);
    $cpic=Obj::cpic();
    @relver=split(/\D+/m,$rel->{vers});
    $relvers=$relver[0].$relver[1];
    $edr=Obj::edr();
    $plat=EDRu::plat($cpic->{padv});
    $backopt=0;
    unless (Cfg::opt('jumpstart') && $plat =~ /SunOS/m) {
        $msg = Msg::new("The -jumpstart option is only supported on the Solaris platform");
        $msg->warning();
        return '';
    }
    $savepath = Cfg::opt('jumpstart');
    $prod=$cpic->prod if ($cpic->{prod});

    # Menu Questions for boot disk encapsulation
    unless ($prod->{nofinish_encap}) {
        $msg=Msg::new("Would you like to generate the finish script to encapsulate the boot disk?");
        $help=Msg::new("A finish script to encapsulate the boot disk is created if 'y' is chosen. Further parameters for boot disk encapsulation will be asked. Choosing 'n' will skip the procedure of generating a finish script to encapsulate the boot disk");
        $ayn=$msg->ayny($help, 0);
        if ($ayn eq 'Y') {
            $msg=Msg::new("\nSpecify the disk group name of the root disk to be encapsulated:");
            $boot_dgname=$msg->ask('','',$backopt);
            $msg=Msg::new("\nSpecify the private region length of the root disk to be encapsulated:");
            $region_length=$msg->ask('65536','',$backopt);
            $msg=Msg::new("\nSpecify the disk media name of the root disk to be encapsulated:");
            $default_dmname="$boot_dgname".'_01';
            $dmname=$msg->ask($default_dmname,'',$backopt);
        }
    }

    # Setup the script piece for encap boot disk script of VM
    my $encap_script = <<"_ENCAP_";
#!/bin/sh

# Copyright: Copyright (c) 2012 Symantec Corporation.
# All rights reserved.
#
# THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
# SYMANTEC CORPORATION. USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
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
# shall be solely in accordance with the terms of this Agreement.

###################################################################
#
# The following init script encapsulates the root disk.
# The script was copied to the /etc/rc2.d directory remotely
# as part of the vxvm jumpstart installation procedure.
#
###################################################################

: \${VOLROOT_DIR:=\$__VXVM_ROOT_DIR}
. \${VOL_SCRIPTS_LIB:-/usr/lib/vxvm/lib}/vxcommon

CMD=`basename \$0`

quit()
{
    code=\$1
    if [ -n "\$DEBUG" ]; then
            set -x
    fi
    rm -f /etc/init.d/vxvm-jumpstart /etc/rc2.d/S01vxvm-jumpstart
    if [ "\$code" -eq 100 ]; then
            shutdown -g0 -y -i6
            code=0
    fi
    exit \$code
}

trap 'quit 2' INT HUP QUIT TERM

if [ -n "\$DEBUG" ]; then
        set -x
fi

# if system is already encapsulated, then exit init script
df / | grep rootvol > /dev/null
if [ \$? -eq 0 ]; then
        echo "INFO: \$CMD: system is already encapsulated."
        quit 0
fi

# Do minimal vxvm installation
if [ -d /dev/vx/dmp ]
then
        /sbin/mount -F tmpfs dmpfs /dev/vx/dmp
fi
if [ -d /dev/vx/rdmp ]
then
        /sbin/mount -F tmpfs dmpfs /dev/vx/rdmp
fi

# set the license for vxconfigd to work
mount /opt 2> /dev/null
/opt/VRTS/bin/vxlicinst -k BZZ9-6CP6-XHIJ-TYW6-R6PC-P4PP-P6P3-PPP

vxconfigd -k -m disable > /dev/null 2>&1
vxdctl init > /dev/null 2>&1
vxdctl enable

voldmode=`vxdctl mode 2>/dev/null`
if [ "X\$voldmode" != "Xmode: enabled" ]
then
        echo "ERROR: \$CMD: vold could not be enabled."
        quit 1
fi

rm -f \$mkdbfile

# Determine root disk of system
set_rootdisk
if [ -z "\$rootdisk" ]; then
        echo "ERROR: \$CMD: Could not locate root disk : \$rootdisk."
        quit 2
fi

# Encapsulate root disk
/usr/lib/vxvm/bin/vxencap -c -g $boot_dgname -f sliced -s $region_length $dmname=\$rootdisk

# Exit if encapsulation of root disk failed
if [ ! -s /etc/vx/reconfig.d/disk.d/\$rootdisk/newpart ]
then
        echo "ERROR: \$CMD: Encapsulation of root disk failed."
        quit 3
fi

# encapsulation was successful.  Shutdown the system to complete encapsulation.
quit 100

_ENCAP_

    # setup the scripts pieces for finish scripts
    my $finish_script = <<'_EOF_';
#!/bin/sh

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
# shall be solely in accordance with the terms of this Agreement.  $0

echo "==== Executing finish script: $me ===="

PATH=$PATH:/sbin:/usr/sbin
export PATH

#
# Notice:
# * Modify the BUILDSRC and ENCAPSRC below according to your
# * real environment
# * The location specified with BUILDSRC and ENCAPSRC should be NFS
#   accessible to the Jumpstart Server
# * It's requied to set ENCAPSRC only if you are using jumpstart for
#   automatic boot disk encapsulation
# * Copy the whole directories of pkgs from installation media
#   to the BUILDSRC
# * Create the admin and response file for pkgadd according
#   to 'jumpstart_readme.txt' in the DVD
#

BUILDSRC="<hostname_or_ip>:/path/to/pkgs_patches"
ENCAPSRC="<hostname_or_ip>:/path/to/encap_script"

#
# Notice:
# * You do not have to change the following scripts
#

ROOT=/a
BUILDDIR="${ROOT}/build"
PKGDIR="${BUILDDIR}/pkgs"
PATCHDIR="${BUILDDIR}/patches"
ENCAPDIR="${ROOT}/encap_script"

mkdir -p ${BUILDDIR}
mount -F nfs -o vers=3 ${BUILDSRC} ${BUILDDIR}

for PKG in __PKGS__
do
    if [ -n "$PKG" ]
    then
        RESP="${PKGDIR}/${PKG}.response"
        echo "Installing package  -- $PKG"
        if [ -f ${RESP} ]
        then
            pkgadd -n -a ${PKGDIR}/admin  -d ${PKGDIR}/${PKG}.pkg -r ${RESP} -R ${ROOT} ${PKG}
        else
            pkgadd -v -a ${PKGDIR}/admin  -d ${PKGDIR}/${PKG}.pkg -R ${ROOT} ${PKG}
        fi
    fi
done

for PATCH in __PATCHES__
do
    if [ -n "$PATCH" ]
    then
        patchadd -R ${ROOT} -M ${PATCHDIR} ${PATCH}
    fi
done

CALLED_BY=JUMPSTART ${ROOT}/opt/VRTS/install/bin/__RELEASE__/add_install_scripts

touch ${ROOT}/noautoshutdown

umount ${BUILDDIR}

_EOF_

   my $encap_copy_lines = <<'_ENCAP_COPY_';

mkdir -p ${ENCAPDIR}
mount -F nfs -o vers=3 ${ENCAPSRC} ${ENCAPDIR}

cp ${ENCAPDIR}/encap_bootdisk_vm.fin ${ROOT}/etc/init.d/vxvm-jumpstart
ln ${ROOT}/etc/init.d/vxvm-jumpstart ${ROOT}/etc/rc2.d/S01vxvm-jumpstart
chmod 755 ${ROOT}/etc/init.d/vxvm-jumpstart
chmod 755 ${ROOT}/etc/rc2.d/S01vxvm-jumpstart

_ENCAP_COPY_

   my $finish_lines = <<'_FINISH_LINES_';

echo "==== Completed finish script $me ===="

exit 0

_FINISH_LINES_


    $mod_rel = $cpic->{release};
    # figure out the list of pkg and patch for current UPI, or all those UPIs in the DVD

    #As EDR has not yet reached upto the level of seperate product install scripts
    $prods = ($cpic->{prod}) ? [ $cpic->{prod} ] : $rel->{prods};

    foreach my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        # Waiting for mode porting in CPIP
        # Only generate the finish scripts for product which are displayed in the menu
        if ($cpic->{script} =~ /"installer"/mx) {
            next if (! -d "$cpic->{basemediapath}/$prod->{prod}}");
        }
        # Open finish scripts
        $basename = 'jumpstart_' . lc($prod->{prod}) . '.fin';
        $basename = Cfg::opt('jumpstart'). '/' . "$basename";
        $msg = Msg::new("Cannot open $basename for generating the finish scripts");
        open($fh, '>', $basename) or $msg->die;

        @pkgs=();
        @patches=();
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi,$cpic->{padv});
            next if ($pkg->{mpok});
            push(@pkgs,$pkg->{pkg});
            for my $patchi (@{$pkg->patches_allvers()})  {
                $patch=$cpic->patch($patchi) unless (ref($patchi));
                push(@patches,$patch->{patch_vers});
            }
        }
        $pkgslist = join(' ', @pkgs);
        $patchlist = join(' ', @patches);
        $pkgslist ||= '""';
        $patchlist ||= '""';

        # print the pkg list now
        my $tmp_finish_script = $finish_script;
        $tmp_finish_script = $tmp_finish_script . $encap_copy_lines if (($prod->{prod} =~ /SF|VM/m) && ($ayn eq 'Y'));
        $tmp_finish_script = $tmp_finish_script . $finish_lines;
        $tmp_finish_script =~ s/__RELEASE__/$mod_rel/mg;
        $tmp_finish_script =~ s/__RELVERS__/$relvers/mg;
        $tmp_finish_script =~ s/__PKGS__/$pkgslist/mg;
        $tmp_finish_script =~ s/__PATCHES__/$patchlist/mg;

        print $fh $tmp_finish_script;
        close($fh);
        EDR::cmd_local("_cmd_chmod +x $basename");
        $msg=Msg::new("The finish scripts for $prod->{abbr} is generated at $basename");
        $msg->bold;

    }

    # Code to write jumpstart encap boot disk script file
    if ($ayn eq 'Y') {
        #$basename = Cfg::opt("jumpstart") . "/" . "encap_bootdisk_vm".$relvers.".fin";
        $basename = Cfg::opt('jumpstart') . '/' . 'encap_bootdisk_vm'.'.fin';
        $msg=Msg::new("Cannot open $basename for generating the encapsulated bootdisk script");
        open ($fh, '>', $basename) or $msg->die;
        print $fh $encap_script;
        close($fh);
        EDR::cmd_local("_cmd_chmod +x $basename");
        $msg=Msg::new("The encapsulation boot disk script for VM is generated at $basename");
        $msg->bold;
    }
    return;
}

sub ai {
    my ($rel) = @_;
    my($basename,$cpic,$localsys,$backopt,$savepath,$fh,$msg,$errmsg);
    my($prod,$prodname,$prods,@prods,@pkgs,$pkg,$pkgslist);
    my($vrts_manifest_xml,$vrts_manifest_help,$helpfile,$os_url,$default_os_url,$symc_url);
    $cpic=Obj::cpic();
    $backopt=0;
    unless (Cfg::opt('ai') && $cpic->{padv} =~ /Sol11/m) {
        $msg = Msg::new("The -ai option is only supported on Solaris 11 platform");
        $msg->warning();
        return '';
    }
    $savepath = Cfg::opt('ai');

    # setup the vrts_manifest xml files for all products
    $vrts_manifest_xml = <<'_MANIFEST_';
<?xml version="1.0" encoding="UTF-8"?>
<!--

  Copyright: Copyright (c) 2012 Symantec Corporation.
  All rights reserved.

  THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
  SYMANTEC CORPORATION. USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
  WITHOUT THE PRIOR EXPRESS WRITTEN PERMISSION OF SYMANTEC CORPORATION.

  The Licensed Software and Documentation are deemed to be commercial
  computer software as defined in FAR 12.212 and subject to restricted
  rights as defined in FAR Section 52.227-19 "Commercial Computer
  Software - Restricted Rights" and DFARS 227.7202, "Rights in
  Commercial Computer Software or Commercial Computer Software
  Documentation", as applicable, and any successor regulations. Any use,
  modification, reproduction release, performance, display or disclosure
  of the Licensed Software and Documentation by the U.S. Government
  shall be solely in accordance with the terms of this Agreement.

-->
<!DOCTYPE auto_install SYSTEM "file:///usr/share/install/ai.dtd.1">
<auto_install>
  <ai_instance name="vrts___PRODUCT__">
    <target>
      <logical>
        <zpool name="rpool" is_root="true">
          <filesystem name="export" mountpoint="/export"/>
          <filesystem name="export/home"/>
          <be name="solaris"/>
        </zpool>
      </logical>
    </target>
    <software type="IPS">
      <destination>
        <image>
          <!-- Specify locales to install -->
          <facet set="false">facet.locale.*</facet>
          <facet set="true">facet.locale.de</facet>
          <facet set="true">facet.locale.de_DE</facet>
          <facet set="true">facet.locale.en</facet>
          <facet set="true">facet.locale.en_US</facet>
          <facet set="true">facet.locale.es</facet>
          <facet set="true">facet.locale.es_ES</facet>
          <facet set="true">facet.locale.fr</facet>
          <facet set="true">facet.locale.fr_FR</facet>
          <facet set="true">facet.locale.it</facet>
          <facet set="true">facet.locale.it_IT</facet>
          <facet set="true">facet.locale.ja</facet>
          <facet set="true">facet.locale.ja_*</facet>
          <facet set="true">facet.locale.ko</facet>
          <facet set="true">facet.locale.ko_*</facet>
          <facet set="true">facet.locale.pt</facet>
          <facet set="true">facet.locale.pt_BR</facet>
          <facet set="true">facet.locale.zh</facet>
          <facet set="true">facet.locale.zh_CN</facet>
          <facet set="true">facet.locale.zh_TW</facet>
        </image>
      </destination>
      <source>
        <publisher name="solaris">
          <origin name="__OS_REPOSITORY__"/>
        </publisher>
      </source>
      <software_data action="install">
        <name>pkg:/entire@latest</name>
        <name>pkg:/group/system/solaris-large-server</name>
        <name>pkg:/babel_install</name>
      </software_data>
      <software_data action="uninstall">
        <name>pkg:/babel_install</name>
        <name>pkg:/slim_install</name>
      </software_data>
    </software>
    <software type="IPS">
      <source>
        <publisher name="Symantec">
          <origin name="__SYMC_REPOSITORY__"/>
        </publisher>
      </source>
      <software_data action="install">
        __SYMC_PKGS__
      </software_data>
    </software>
  </ai_instance>
</auto_install>

_MANIFEST_

    $vrts_manifest_help = <<'_HELP_';

1. First follow the Oracle documentations to setup a Solaris AI server and DHCP server:
* http://docs.oracle.com/cd/E23824_01/html/E21798/useaipart.html


2. Setup Symantec package repository

# svcadm enable svc:/network/dns/multicast:default

# mkdir /ai
# zfs create -o compression=on -o mountpoint=/ai rpool/ai

# mkdir /ai/repo_symc
# pkgrepo create /ai/repo_symc
# pkgrepo add-publisher -s /ai/repo_symc Symantec
# pkgrecv -s <media>/pkgs/VRTSpkgs.p5p -d /ai/repo_symc '*'

# svccfg -s application/pkg/server setprop pkg/inst_root=/ai/repo_symc
# svccfg -s application/pkg/server setprop pkg/readonly=true
# svccfg -s application/pkg/server setprop pkg/port=10002
# svcadm refresh application/pkg/server
# svcadm enable application/pkg/server


3. Setup install service on AI server

# mkdir /ai/iso

Download AI image from Oracle website and put the iso under /ai/iso:
* http://www.oracle.com/technetwork/server-storage/solaris11/downloads/index.html

Create a install service, for example:
# installadm create-service -n sol11-x86 -s /ai/iso/sol-11-1111-ai-x86.iso -d /ai/aiboot/



4. Run 'installer' to generate manifest xml files for all Symantec products or specific product.

# mkdir /ai/manifests
# <media>/installer -ai /ai/manifests


5. Generate system configuration for specific client, like hostname, user accounts, IP address.

# mkdir /ai/profiles
# sysconfig create-profile -o /ai/profiles/profile_client.xml

Or
# cp /ai/aiboot/auto-install/sc_profiles/sc_sample.xml /ai/profiles/profile_client.xml



6. Add a client and match it to the specified product manifest and system configuration

# installadm create-client -e "<client_MAC>" -n sol11x86

# installadm add-manifest -n sol11x86 -f /ai/manifests/vrts_manifest_sfha.xml
# installadm create-profile -n sol11x86 -f /ai/profiles/profile_client.xml -p profile_sc
# installadm set-criteria -n sol11x86 -m vrts_sfha -p profile_sc -c mac="<client_MAC>"
# installadm list -m -c -p -n sol11x86


7. PXE boot the client machine or "boot net:dhcp - install" to begin to install OS and Symantec product.

_HELP_

    $default_os_url="http://pkg.oracle.com/solaris/release";
    $localsys = EDR::get('localsys');
    if($localsys->{padv} =~ /^Sol11/m) {
        $os_url=$localsys->cmd("_cmd_pkg publisher -HPn solaris 2>/dev/null | _cmd_grep 'Origin URI'");
        if ($os_url) {
            $default_os_url=$os_url;
            $default_os_url=~s/^\s*Origin URI:\s*//;
        }
    }

    $msg=Msg::new("Specify the repository URL for Oracle Solaris installation:");
    while (1) {
        $os_url=$msg->ask($default_os_url,'',$backopt);
        if (EDRu::isurl($os_url)) {
            last;
        } else {
            $errmsg=Msg::new("The URL '$os_url' is not valid. Input again");
            $errmsg->warning();
        }
    }
    Msg::n();

    $msg=Msg::new("Specify the repository URL for Symantec packages installation:");
    while (1) {
        $symc_url=$msg->ask('','',$backopt);
        if (EDRu::isurl($symc_url)) {
            last;
        } else {
            $errmsg=Msg::new("The URL '$symc_url' is not valid. Input again");
            $errmsg->warning();
        }
    }
    Msg::n();

    $prods = ($cpic->{prod}) ? [ $cpic->{prod} ] :
             (Cfg::opt('prodmode') eq 'SF Basic') ? [ 'SF61' ] :
             $rel->{prods};
    foreach my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        $prodname=lc($prod->{prod});
        if ($cpic->{script} =~ /"installer"/mx) {
            next if (! -d "$cpic->{basemediapath}/$prod->{prod}}");
        }

        # generate manifest file
        $basename = 'vrts_manifest_' . $prodname . '.xml';
        $basename = Cfg::opt('ai'). '/' . "$basename";
        $msg = Msg::new("Cannot open $basename for generating the manifest xml file");
        open($fh, '>', $basename) or $msg->die;

        @pkgs=();
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi,$cpic->{padv});
            next if ($pkg->{mpok});
            push(@pkgs,$pkg->{pkg});
        }
        if (@pkgs) {
            $pkgslist='<name>pkg:/';
            $pkgslist.=join("</name>\n        <name>pkg:/", @pkgs);
            $pkgslist.='</name>';
        }
        $pkgslist||='';

        # print the pkg list now
        my $tmp_manifest = $vrts_manifest_xml;
        $tmp_manifest =~ s/__PRODUCT__/$prodname/mg;
        $tmp_manifest =~ s/__OS_REPOSITORY__/$os_url/mg;
        $tmp_manifest =~ s/__SYMC_REPOSITORY__/$symc_url/mg;
        $tmp_manifest =~ s/__SYMC_PKGS__/$pkgslist/mg;

        print $fh $tmp_manifest;
        close($fh);
        $msg=Msg::new("The AI manifest file for $prod->{abbr} is generated at $basename");
        $msg->bold;
    }

    # write help informations
    $helpfile = 'vrts_manifest.help';
    $basename = Cfg::opt('ai') . '/' . $helpfile;
    $msg=Msg::new("Cannot open $basename for generating the $helpfile");
    open ($fh, '>', $basename) or $msg->die;
    print $fh $vrts_manifest_help;
    close($fh);
    $msg=Msg::new("The help file '$helpfile' is generated at $basename");
    $msg->bold;

    return;
}

# this sub could generate a kickstart script and could be used to install VRTS pkgs
# during redhat kickstart automation installaion.
sub kickstart {
    my ($rel) = @_;
    my ($basename,$mod_rel,$msg,$pkg,$pkgi,@pkgs,$prod,$prods,$rpmlist,$savepath,$fd,$ver);

    my $edr = Obj::edr();
    my $cpic = Obj::cpic();

    unless(Cfg::opt('kickstart') && $cpic->{padv} =~ /^RHEL/m) {
        $msg = Msg::new("The -kickstart option is only supported on the Red Hat Linux platform");
        $msg->warning();
        return '';
    }

    $savepath = Cfg::opt('kickstart');

    # setup the scripts pieces for kickstart scripts
    my $ks_script = <<'_EOF_';
__DEP_PKGS__
%post --nochroot
# Add necessary scripts or commands here to your need
# This generated kickstart file is only for the automated installation of products in the DVD

PATH=$PATH:/sbin:/usr/sbin:/bin:/usr/bin
export PATH

#
# Notice:
# * Modify the BUILDSRC below according to your real environment
# * The location specified with BUILDSRC should be NFS accessible
#   to the Kickstart Server
# * Copy the whole directories of rpms from installation media
#   to the BUILDSRC
#

BUILDSRC="<hostname_or_ip>:/path/to/rpms"

#
# Notice:
# * You do not have to change the following scripts
#

# define path varibles
ROOT=/mnt/sysimage
BUILDDIR="${ROOT}/build"
RPMDIR="${BUILDDIR}/rpms"

# define log path
KSLOG="${ROOT}/var/tmp/kickstart.log"

echo "==== Executing kickstart post section: ====" >> ${KSLOG}

mkdir -p ${BUILDDIR}
mount -t nfs -o nolock,vers=3 ${BUILDSRC} ${BUILDDIR} >> ${KSLOG} 2>&1

# install rpms one by one
for RPM in _RPMLIST_
do
    echo "Installing package  -- $RPM" >> ${KSLOG}
    rpm -U -v --root ${ROOT} ${RPMDIR}/${RPM}-* >> ${KSLOG} 2>&1
done

umount ${BUILDDIR}

CALLED_BY=KICKSTART ${ROOT}/opt/VRTS/install/bin/__RELEASE__/add_install_scripts >> ${KSLOG} 2>&1

echo "==== Completed kickstart file ====" >> ${KSLOG}

exit 0
__END__

_EOF_

    $mod_rel = $cpic->{release};
    $prods = ($cpic->{prod}) ? [ $cpic->{prod} ] : $rel->{prods};
    for my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        next if ($prod->obsoleted);

        # figure out the list of pkg and patch for current UPI, or all those UPIs in the DVD
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            next if ($pkg->{mpok});
            push(@pkgs,$pkg->{pkg});
        }
        $rpmlist = join(' ',@pkgs);
        @pkgs = ();
        $ver=$prod->{release};
        $ver=~s/.XRT//;
        $basename = 'kickstart_' . lc($prod->{prod}) . $ver . '.ks';
        $basename = "$savepath". '/' . "$basename";
        $msg = Msg::new("Cannot open $basename for generating the kickstart scripts");
        open($fd, '>', $basename) or $msg->die;
        # add the rpm list into kickstart script file
        my $tmp_ks_script = $ks_script;
        $tmp_ks_script=~s/__RELEASE__/$mod_rel/mg;
        $tmp_ks_script=~s/_RPMLIST_/$rpmlist/mg;
        if ( $cpic->{padv} =~ /^RHEL([0-9])/mx && $1 > 5 ) {
            $tmp_ks_script=~s/__END__/\%end/mg;
            $tmp_ks_script=~s/__DEP_PKGS__/# The packages below are required and will be installed from OS installation media automatically\n# during the automated installation of products in the DVD, if they have not been installed yet.\n\%packages\ndevice-mapper\ndevice-mapper-libs\nparted\nlibgcc.i686\ncompat-libstdc++-33\ned\nksh\nnss-softokn-freebl.i686\nglibc.i686\nlibstdc++.i686\naudit-libs.i686\ncracklib.i686\ndb4.i686\nlibselinux.i686\npam.i686\nlibattr.i686\nlibacl.i686\n\%end\n/g;
        }else {
            $tmp_ks_script=~s/__END__//mg;
            $tmp_ks_script=~s/__DEP_PKGS__/# The packages below are required and will be installed from OS installation media automatically\n# during the automated installation of products in the DVD, if they have not been installed yet.\n\%packages\nlibattr.i386\nlibacl.i386\n/g;
        }
        print $fd $tmp_ks_script;

        close($fd);
        $msg = Msg::new("The kickstart script for $prod->{prod} is generated at $basename");
        $msg->bold;

    }
    return;
}

sub yumgroupxml {
    my ($rel) = @_;
    my ($basename,$msg,$pkg,$pkgi,@pkgs,$prod,$prods,$savepath,$ver,$fd,$xml);

    my $edr = Obj::edr();
    my $cpic = Obj::cpic();

    unless(Cfg::opt('yumgroupxml') && $cpic->{padv} =~ /^RHEL/m) {
        $msg = Msg::new("-yumgroupxml option is only supported on Ret Hat Linux platform");
        $msg->warning();
        return '';
    }

    $cpic->verify_media($rel);

    $savepath = Cfg::opt('yumgroupxml');

    if ($cpic->{prod}) {
        $prods = [ $cpic->{prod} ];
    } else {
        $prods = [ $rel->prod_menu('yumgroupxml','') ];
    }

    for my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        next if ($prod->obsoleted);

        # figure out the list of pkg and patch for current UPI, or all those UPIs in the DVD
        @pkgs = ();
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            next if ($pkg->{mpok});
            push(@pkgs,$pkg->{pkg});
        }
        $ver=$prod->{release};
        $ver=~s/.XRT//;
        $basename = 'comps_' . lc($prod->{prod}) . $ver . '.xml';
        $basename = "$savepath". '/' . "$basename";
        $msg = Msg::new("Cannot open $basename for generating the yum group XML file");
        open($fd, '>', $basename) or $msg->die;

        $xml = "<comps>\n";
        $xml.="\t<group>\n";
        $xml.="\t\t<id>".uc($prod->{prod}).$ver."</id>\n";
        $xml.="\t\t<name>".uc($prod->{prod}).$ver."</name>\n";
        $xml.="\t\t<default>true</default>\n";
        $xml.="\t\t<description>RPMs of ".$prod->{name}.' '.$prod->{vers}."</description>\n";
        $xml.="\t\t<uservisible>true</uservisible>\n";
        $xml.="\t\t<packagelist>\n";
        for my $pkg (sort @pkgs) {
            $xml.="\t\t\t<packagereq type=\"default\">".$pkg."</packagereq>\n";
        }
        $xml.="\t\t</packagelist>\n";
        $xml.="\t</group>\n";
        $xml.="</comps>\n";
        $xml.="\n";

        print $fd $xml;

        close($fd);
        $msg = Msg::new("The yum group XML for $prod->{prod} is generated at $basename");
        $msg->bold;
    }
    return;
}

# ignite
sub ignite {
    my ($rel)=@_;
    my ($rtn,$msg,$errmsg,$mprod,$prod,$def,$bundle_name,$bundle_dir,$ver,$pkg,$pkgarray,$pkglist,$pkgspace_required,$suffix);
    my ($obsoleted_bundles,$obsoleted_bundled_pkgs,$obsoleted_note,$equal_prod,$obsoleted_note_os);
    my (@patches,$ayn,$patch);

    my $cpic = Obj::cpic();
    my $edr = Obj::edr();
    my $localsys = EDR::get('localsys');
    unless(Cfg::opt('ignite') && ($cpic->{padv} =~ /^HPUX/m) && ($localsys->{padv} =~ /^HPUX/m)) {
        $msg = Msg::new("The -ignite option is only supported on the HPUX platform");
        $msg->warning();
        $edr->exit_noexitfile();
    }
    $cpic->verify_media($rel);

    # step 1. check if the local node is an Ignite server
    $rtn = $localsys->cmd("_cmd_swlist | _cmd_grep -i ignite 2>/dev/null | _cmd_grep -v grep");
    if ($rtn !~/ignite/i) {
        $msg = Msg::new("'$edr->{script} -ignite' is not running on an Ignite server\n");
        $msg->warning();
        $edr->exit_noexitfile();
    }

    # step 2. show product selection menu if required
    $mprod = '';
    if ($cpic->{prod} =~/VM/mx) {
        $msg = Msg::new("The -ignite option is not supported with VM product\n");
        $msg->warning();
        $edr->exit_noexitfile();
    }
    while (1) {
        if (!$cpic->{prod}) {
            $mprod||=$rel->prod_menu('install',$mprod);
        }
        if ($mprod=~/^$edr->{msg}{back}$/mxi) {
            $mprod = '';
            next;
        }
        $cpic->set_prod($mprod);
        last;
    }
    $prod=$cpic->prod();

    if ($rel->{type}=~/^M/) {
        $msg = Msg::new("Bundle for Rolling Patch release is only used to install the patches, ensure base packages of the product are installed before installing this bundle on the systems. Would you like to continue?");
        $ayn = $msg->ayny();
        $edr->exit_noexitfile() if ($ayn eq 'N');
        Msg::n();
    }

    # get the obsoleted_bundles and obsoleted_bundled_pkgs
    if($cpic->{prod} =~ /DMP/) {
        $equal_prod = $prod;
    } else {
        # for SFCFSHA and SFRAC, the obsoleted_bundles is not set
        $equal_prod = $prod->prod('SF61');
    }
    $obsoleted_bundles = join(' ',@{$equal_prod->{obsoleted_bundles}}) if $equal_prod->{obsoleted_bundles};
    $obsoleted_bundled_pkgs = join(' ',@{$equal_prod->{obsoleted_bundled_pkgs}}) if $equal_prod->{obsoleted_bundled_pkgs};
    if($obsoleted_bundles || $obsoleted_bundled_pkgs) {
        $obsoleted_note = Msg::new("Ensure that the following OS native bundles and packages are removed before the bundle installation.\n    OS bundles: $obsoleted_bundles\n    OS packages : $obsoleted_bundled_pkgs\n");
        $obsoleted_note_os = Msg::new("Ensure that the following OS native bundles and packages are deselected before installing the bundle with HPUX OS.\n    OS bundles: $obsoleted_bundles\n    OS packages : $obsoleted_bundled_pkgs\n");
    }
    # adjust package sequence in order to list packages properly.
    $pkgarray = $rel->adjust_pkg_sequence($prod->allpkgs);
    # step 3. check the space requirement on Ignite server for selected product
    # figure out the list of packages for current product
    for my $pkgi (@{$pkgarray}) {
        $pkg=$cpic->pkg($pkgi);
        next if ($pkg->{mpok});
        $pkglist .= "$pkg->{pkg} ";
        $pkgspace_required+=$pkg->{size};
        for my $patchi (@{$pkg->patches_allvers()}) {
            $patch=$cpic->patch($patchi);
            push (@patches, $patch);
        }
    }
    if ($rel->{type}=~/^M/) {
        $pkglist = '';
        $pkgspace_required = 0;
         for my $patch (@patches) {
            $pkglist .= "$patch->{patch} ";
            $pkgspace_required += $patch->{size};
        }
    }
    Msg::log("Required space for the depots is $pkgspace_required KB");

    $msg=Msg::new("The selected $prod->{abbr} depots :\n$pkglist\n");
    $msg->print();

    # ask user to input the bundle directory
    $def="/var/opt/ignite/depots";
    $msg=Msg::new("Enter the file directory to create the $prod->{abbr} bundle:");
    $errmsg=Msg::new("The input directory $bundle_dir does not exist on the Ignite server");
    while (1) {
        $bundle_dir=$msg->ask($def);
        ($localsys->is_dir($bundle_dir)) ? last : $errmsg->warning();
    }
    # check the free space under specified directory
    my $dfk=$localsys->cmd("_cmd_dfk $bundle_dir 2>/dev/null");
    my @dfk=split(/\n/,$dfk);
    $dfk=pop @dfk;
    @dfk=split(/\s+/m,$dfk);
    $msg=Msg::new("Checking the free space of file system");
    if ( $dfk[3] < $pkgspace_required ) {
        $msg->display_status('failed');
        $msg=Msg::new("$pkgspace_required KB is required in the $bundle_dir directory and only $dfk[3] KB is available on the Ignite server");
        $msg->warning();
        return '';
    } else {
        $msg->display_status();
    }
    Msg::n();

    # step 4. ask user for the bundle name (default value is <prodabbr_vers_bundle>, eg: SF61_bundle)
    $ver=$rel->{titlevers};
    $ver=~s/[\.\s+]//g;
    $def="$prod->{prod}${ver}_bundle";
    $msg=Msg::new("Enter a name for the bundle which holds all the $prod->{abbr} depots:");
    while (1) {
        $bundle_name=$msg->ask($def);
        if ($localsys->is_dir($bundle_name)) {
            $errmsg=Msg::new("The input bundle name $bundle_name is a directory");
            $errmsg->warning();
        } elsif ($bundle_name=~/\s+/) {
            $errmsg=Msg::new("The input bundle name $bundle_name can not contain space characters");
            $errmsg->warning();
        } elsif ($bundle_name=~/\//) {
            $errmsg=Msg::new("The input bundle name $bundle_name can not contain / characters");
            $errmsg->warning();
        } else {
            last;
        }
    }

    # step 5. copy the depots of selected product from media to the location of Software Distributor (SD) depots of Ignite server
    # check if the SD directory already existed
    my $bundle_depot_dir="$bundle_dir/$bundle_name";
    my $bundle_data_dir="/var/opt/ignite/data/$bundle_name";
    if ( $localsys->is_dir($bundle_depot_dir)){
        # remove the existent depot dir
        $msg=Msg::new("The bundle depot directory($bundle_depot_dir) already exists on Ignite server.");
        $msg->warning();
        $msg=Msg::new("Do you want to remove it, then proceed?");
        my $ayn=$msg->ayny();
        if ($ayn eq 'Y') {
            $localsys->cmd("_cmd_swreg -u -l depot $bundle_depot_dir 2>/dev/null");
            $localsys->cmd("_cmd_rmr $bundle_depot_dir");
            $msg=Msg::new("Removing obsolete depot directory for $prod->{abbr}");
            $msg->display_status();
        } else {
            return '';
        }
    }

    $msg=Msg::new("Creating depot directory for $prod->{abbr}");
    $localsys->cmd("_cmd_mkdir -p $bundle_depot_dir");
    $localsys->cmd("_cmd_mkdir -p $bundle_data_dir");
    $msg->display_status();

    # copy the product depots from media to local SD
    if ($rel->{type}=~/^M/) {
        my $patchpath=$rel->pkgs_patches_dir('patchpath');
        for my $patch (@patches) {
            $msg=Msg::new("Copying $patch->{patch} depot from media to local repository");
            $rtn=$localsys->cmd("_cmd_swcopy -x enforce_dependencies=false -s $patchpath $patch->{patch} @ $bundle_depot_dir 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg->display_status('failed');
                Msg::print($rtn);
                return '';
            } else {
                $msg->display_status();
            }
        }
    } else {
        my $pkgpath=$rel->pkgs_patches_dir('pkgpath');
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            next if ($pkg->{mpok});
            $msg=Msg::new("Copying $pkg->{pkg} depot from media to local repository");
            $rtn=$localsys->cmd("_cmd_swcopy -x enforce_dependencies=false -s $pkgpath $pkg->{pkg} @ $bundle_depot_dir 2>/dev/null");
            if (EDR::cmdexit()) {
                $msg->display_status('failed');
                Msg::print($rtn);
                return '';
            } else {
                $msg->display_status();
            }
        }
    }

    # step 6. make a bundle from the copied depots
    $msg=Msg::new("Creating a bundle ($bundle_name) for $prod->{abbr}");
    $rtn=$localsys->cmd("_cmd_make_bundles -B -n $bundle_name -t $bundle_name $bundle_depot_dir 2>/dev/null");
    if (EDR::cmdexit()) {
        $msg->display_status('failed');
        Msg::print($rtn);
        return '';
    } else {
        $msg->display_status();
    }

    # step 7. make_config for the newly-created bundle
    $msg=Msg::new("Generating configuration file for the newly-created bundle");
    $localsys->cmd("_cmd_rmr $bundle_data_dir/core_media_cfg 2>/dev/null");
    $rtn=$localsys->cmd("_cmd_make_config -s $bundle_depot_dir -c $bundle_data_dir/core_media_cfg 2>/dev/null");
    if (EDR::cmdexit()) {
        $msg->display_status('failed');
        Msg::print($rtn);
        return '';
    } else {
        # add post_load_cmd = "/opt/VRTS/install/bin/SNAS60/add_install_scripts" in core_media_cfg
        my $content=$localsys->cmd("_cmd_cat $bundle_data_dir/core_media_cfg 2>/dev/null");
        my @conts=split(/\n/,$content);
        my $filecont="";
        for my $line (@conts) {
            if ($line=~/sd_software_list/) {
                $filecont.="    ";
                $filecont.="post_load_cmd = \"/opt/VRTS/install/bin/SNAS60/add_install_scripts\"\n";
            }
            $filecont.=$line."\n";
        }
        EDRu::writefile($filecont,"$bundle_data_dir/core_media_cfg");
        $msg->display_status();
    }

    # step 8. add the cfg files into OS core media repository
    my $indexfile="/var/opt/ignite/data/INDEX";
    my @os_media_list;
    if ($localsys->exists($indexfile) && (!$rel->{type}=~/^M/)) {
        my $output=$localsys->cmd("_cmd_grep -v '#' $indexfile 2>/dev/null | _cmd_grep -v 11.23 | _cmd_grep -v 11.11");
        for my $line (split(/\n/,$output)) {
            if ($line=~/^cfg\s+"(.*)"\s+\{/) {
                push(@os_media_list,$1);
            }
        }
        if (scalar(@os_media_list)>=1){
            push (@os_media_list,"None of the above");
            my $help=Msg::new("Choose the OS config clause which you want to install $bundle_name with. Choose 'None of the above' if you don't want to do this.");
            $msg=Msg::new("\nHere are all the supported HPUX config clauses on the Ignite Server");
            $msg->print();
            $msg=Msg::new("Choose HPUX config clause with which you want to install $bundle_name");
            my $index=$msg->menu(\@os_media_list,'',$help);
            # skip this step if user choose 'None of the above'
            if ($index != scalar(@os_media_list)) {
                $msg=Msg::new("Adding the $bundle_name into HPUX config clause($os_media_list[$index-1])");
                $rtn=$localsys->cmd("_cmd_manage_index -a -f $bundle_data_dir/core_media_cfg -c '$os_media_list[$index-1]' -i $indexfile 2>/dev/null");
                if (EDR::cmdexit()) {
                    $msg->display_status('failed');
                    Msg::print($rtn);
                    return '';
                } else {
                    $msg->display_status();
                    $msg=Msg::new("\nSuccessfully add $bundle_name into HPUX config clause($os_media_list[$index-1]) on Ignite server.");
                    $msg->print();
                    if ($cpic->{prod} !~ /VCS/) {
                        $obsoleted_note_os->nprint() if $obsoleted_note_os;
                    }
                }
            } else {
                $suffix = $rel->get_local_script_version_suffix();
                $msg=Msg::new("If there are install scripts missing under the /opt/VRTS/install directory after the product bundle installation, manually generate these scripts by running the command '/opt/VRTS/install/bin/$rel->{reli}$suffix/add_install_scripts'.\n");
                $msg->nprint();
                $obsoleted_note->nprint() if ($obsoleted_note && ($cpic->{prod} !~ /VCS/));
            }
        }
    }

    # step 9. print some completion messages on how to install the newly-created bundle
    $msg=Msg::new("Successfully created $bundle_name on Ignite server.");
    $msg->print();
    return '';
}

# nim
sub nim {
    my ($rel) = @_;
    my ($ayn,$help,$msg,$mprod,$patch,$pkg,$pkgi,$prod,$prodi,$rtn);
    my ($bff_dir,$bnd_file,$bnd_name,$lpp_source,$lpp_location,$lpplist,$master,$mr,$tmp_bnd_file,$updlist,$vx_nim_path);

    my $edr = Obj::edr();
    my $cpic = Obj::cpic();

    unless(Cfg::opt('nim') && $cpic->{padv} =~ /^AIX/m) {
        $msg = Msg::new("The -nim option is only supported on the AIX platform");
        $msg->warning();
        return '';
    }
    $mr = 1 if ($rel->{type}=~/^M/);

    $edr->{savelog} = 1;
    $cpic->verify_media($rel);

    # check if current host is a nim master
    $rtn = EDR::cmd_local("_cmd_lslpp -L 2>/dev/null | _cmd_grep 'nim.master' ");
    if ($rtn eq '') {
        $master = 0;
        $msg = Msg::new("$edr->{script} is not running on a NIM master\n");
        $msg->warning();
        $msg = Msg::new("Only an installp_bundle configuration file will be generated to list the packages that need to be installed\n");
        $msg->print();
        $msg = Msg::new("You can manually create installp_bundle on the NIM master with this configuration, then copy all listed packages to your LPP_SOURCE manually. Or you can exit and run $edr->{script} on the nim master directly.");
        $msg->print();
        $msg = Msg::new("Do you want to continue?");
        $ayn = $msg->aynn();
        return '' if ($ayn eq 'N');
    } else {
        $master = 1;
    }

    $mprod='';
    $rel->set_menu_msgs();

    sleep 3;
    # show product selection menu if required
    while (1) {
        if (!$cpic->{prod}) {
            $mprod||=$rel->prod_menu('install',$mprod);
        }
        if ($mprod=~/^$edr->{msg}{back}$/mxi) {
            $mprod='';
            next;
        }
        $cpic->set_prod($mprod);
        last;
    }
    $prod=$cpic->prod;
    $prodi=$prod->{prod}.$rel->{titlevers};
    $prodi=~s/\.//g;

    # figure out the list of packages for current product
    for my $pkgi (@{$prod->allpkgs}) {
        $pkg=$cpic->pkg($pkgi);
        next if ($pkg->{mpok});
        $lpplist .= "I:$pkg->{pkg}\n" unless ($mr);
        for my $patchi (@{$pkg->patches_allvers()}) {
            $patch=$cpic->patch($patchi);
            $updlist .= "I:$patch->{patchname}\n";
        }
    }

    $tmp_bnd_file = "/var/tmp/$prodi.bnd";
    if (!$mr) {
        EDRu::writefile($lpplist,$tmp_bnd_file);
    } else {
        EDRu::writefile($updlist,$tmp_bnd_file);
    }
    $msg = Msg::new("The installp_bundle configuration file $tmp_bnd_file generated for product $prodi\n");
    $msg->bold();

    return 1 unless ($master);

    # check LPP_SOURCE for VRTS base lpp
    $lpp_source = Cfg::opt('nim');
    while (1) {
        unless ($lpp_source) {
            if ($mr) {
                $msg = Msg::new("Enter the LPP_SOURCE name which save the $prod->{abbr} base packages:");
            } else {
                $msg = Msg::new("Enter an LPP_SOURCE name to save the $prod->{abbr} packages:");
            }
            $help = Msg::new("Press q to exit");
            $lpp_source = $msg->ask('',$help);
        }
        $rtn = EDR::cmd_local("_cmd_lsnim -l $lpp_source 2>/dev/null");
        if ($rtn eq '') {
            $msg = Msg::new("Cannot find the LPP_SOURCE $lpp_source");
            $msg->bold();
            $lpp_source = '';
            next;
        } else {
            # location
            if ($rtn =~ /location\s*=\s*(.+)/mx) {
                $lpp_location = $1;
            } else {
                $msg = Msg::new("Cannot extract detailed information for LPP_SOURCE $lpp_source using the lsnim command");
                $msg->bold();
                $lpp_source = '';
                next;
            }
            # simages = yes
            if ($rtn !~ /simages\s*=\s*yes/mx) {
                $msg = Msg::new("LPP_SOURCE $lpp_source cannot be used for BOS installation");
                $msg->bold();
                $msg = Msg::new("Do you want to continue?");
                $ayn = $msg->aynn();
                if ($ayn eq 'N') {
                    $lpp_source = '';
                    next;
                }
            }
            # Rstate = ready for use
            if ($rtn !~ /Rstate\s*=\s*ready for use/m) {
                $msg = Msg::new("The Rstate of LPP_SOURCE $lpp_source is not ready for use");
                $msg->bold();
                $msg = Msg::new("Do you want to continue?");
                $ayn = $msg->aynn();
                if ($ayn eq 'N') {
                    $lpp_source = '';
                    next;
                }
            }
            last;
        }
    }

    $bff_dir = "$lpp_location/installp/ppc";
    if (! -d "$bff_dir") {
        EDR::cmd_local("_cmd_mkdir -p $bff_dir");
    }

    # copy VRTS base lpp from media to lpp_source
    unless ($mr) {
        Msg::n();
        $msg = Msg::new("Copy the following packages to $bff_dir for LPP_SOURCE $lpp_source\n");
        $msg->bold;
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            next if ($pkg->{mpok});
            my $dest = EDRu::basename($pkg->{file}).".$pkg->{vers}";
            Msg::left("$pkg->{pkg}");
            EDR::cmd_local("_cmd_cp -rp $pkg->{file} $bff_dir/$dest");
            if (EDR::cmdexit()) {
                Msg::right_failed();
                Msg::n();
                $msg = Msg::new("Failed to copy $pkg->{file} to $bff_dir. Check your local diskspace and file system.");
                $msg->warning();
                return '';
            }
            Msg::right_done();
        }
    }

    # copy patches from media to lpp_source
    if ($updlist) {
        Msg::n();
        $msg = Msg::new("Copy the following patches to $bff_dir for LPP_SOURCE $lpp_source\n");
        $msg->bold;
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            next if ($pkg->{mpok});
            for my $patchi (@{$pkg->patches_allvers()}) {
                $patch=$cpic->patch($patchi);
                my $dest = EDRu::basename($patch->{file}).".$patch->{vers}";
                Msg::left("$patch->{patchname}");
                EDR::cmd_local("_cmd_cp -rp $patch->{file} $bff_dir/$dest");
                if (EDR::cmdexit()) {
                    Msg::right_failed();
                    Msg::n();
                    $msg = Msg::new("Failed to copy $pkg->{file} to $bff_dir. Check your local diskspace and file system.");
                    $msg->warning();
                    return '';
                }
                Msg::right_done();
            }
        }
    } elsif ($mr) {
        $msg = Msg::new("No LPP_SOURCE $lpp_source patches found for $prod->{abbr}$rel->{titlevers}");
        $msg->bold();
        return '';
    }

    # update .toc for LPP_SOURCE directory
    EDR::cmd_local("_cmd_inutoc $bff_dir");

    # define installp_bundle
    my $default = $prodi . '_bundle';
    Msg::n();
    $msg = Msg::new("$edr->{script} will create an installp_bundle for $prod->{abbr}$rel->{titlevers} on this NIM master");
    $msg->bold();
    while (1) {
        $msg = Msg::new("Enter a name for the installp_bundle:");
        $help = Msg::new("Press Enter to use the default name");
        my $answer = $msg->ask($default,$help);
        my $str = $answer;
        $str =~ s/[A-Za-z0-9_-]//mxg;
        if ($str) {
            $msg = Msg::new("installp_bundle name cannot use the characters: $str");
            $msg->print();
        } else {
            $rtn = EDR::cmd_local("_cmd_lsnim -l $answer 2>/dev/null");
            if ($rtn) {
                $msg = Msg::new("installp_bundle $answer is already defined in this NIM master");
                $msg->bold();
                $msg = Msg::new("Do you want to remove the existing installp_bundle and create a new one with the same name? Answer 'n' to input another bundle name");
                $help = Msg::new("Answering 'y' will remove the existing installp_bundle and create a new one with the same name. Answering 'n' you can enter a different name for installp_bundle. Answering 'q' will keep the current installp_bundle unchanged and no installp_bundle will be created.");
                $ayn = $msg->aynn($help);
                next if ($ayn eq 'N');
                EDR::cmd_local("_cmd_nim -o remove $answer");
                $bnd_name = $answer;
                last;
            } else {
                $bnd_name = $answer;
                last;
            }
        }
    }
    $vx_nim_path = '/opt/VRTS/nim';
    EDR::cmd_local("_cmd_mkdir -p $vx_nim_path");
    $tmp_bnd_file = "/var/tmp/$prodi.bnd";
    $bnd_file = "$vx_nim_path/$bnd_name.bundle";
    EDR::cmd_local("_cmd_cp -f $tmp_bnd_file $bnd_file");
    EDR::cmd_local("_cmd_nim -o define -t installp_bundle -a server=master -a location=$bnd_file $bnd_name");
    Msg::n();
    $msg = Msg::new("installp_bundle $bnd_name is created for $prod->{abbr}");
    $msg->bold();

    return '';
}

sub set_value_allsys {
    for my $sys(@{EDR::systems()}) { $sys->set_value(@_); }
    return;
}

sub minpkgs_nag {
    my ($ayn,$msg,$rel);
    # VRTSsfmh minpkgs nag
    $msg=Msg::new("\nNote that the minimal package set does not include managed host software for the Central Management Server, a requirement for keyless licensing. The VRTSsfmh package must be installed separately if you select the minimal package set and also choose to enable keyless licensing.\n\nAre you sure you would like to install the minimal package set?");
    $ayn=$msg->ayny();
    return $ayn;
}

sub feature_usage_sys{
    my ($rel,$sys) = @_;
    my ($rootpath,$vxftrk_bin);
    $rootpath = Cfg::opt("rootpath");
    $vxftrk_bin = $rootpath.'/opt/VRTS/bin/vxftrk';
    if($sys->exists($vxftrk_bin)){
        $sys->{vxftrk} = $sys->cmd($vxftrk_bin);
        $sys->set_value('vxftrk', $sys->{vxftrk});
    }
    return;
}

sub get_sort_product_name{
    my ($rel, $prod) = @_;
    if ($prod eq "vvr") {
        $prod = "vm";
    } elsif ($prod eq "sfcfsha") {
        $prod = "sfcfs";
    } elsif ($prod eq "sforaha") {
        $prod = "sfora";
    } elsif ($prod eq "sfsybha") {
        $prod = "sfsyb";
    } elsif ($prod eq "sfdb2ha") {
        $prod = "sfdb2";
    }
    return $prod;
}

sub get_product_for_settunables{
    my ($rel) = @_;
    my (@settunables_products, $cpic, $prod, $msg, $sysi);
    $cpic = Obj::cpic();
    @settunables_products = qw /SVS61 SFRAC61 SFSYBASECE61 SFCFSHA61 SFHA61 SF61 VM61 FS61 DMP61 VCS61/;

    for my $sys (@{$cpic->{systems}}) {
        $sysi = $sys->{sys};
        $msg = Msg::new("Checking installed product on $sysi");
        $msg->left;
        $sys->{settunable_prodvers} = Msg::new("No Product Installed")->{msg};
        $sys->{settunable_prod} = undef;
        for my $prodi (@settunables_products) {
            next if(!EDRu::inarr($prodi, @{$rel->{prods}}));
            $prod = $cpic->prod($prodi);
            if ($prod->version_sys($sys)) {
                $sys->{settunable_prodvers} = $prod->{abbr}." ".$prod->version_sys($sys);
                $sys->{settunable_prod} = $prodi;
                last;
            }
        }
        Msg::right($sys->{settunable_prodvers});
    }
    Msg::n();
    return $cpic->{systems}[0]{settunable_prod};
}

sub check_upsell_supported {
    my ($rel, $installedprodname, $toinstallprodname) = @_;
    my ($upsellmatrix, $can_upsell);

    $can_upsell = 0;
    $upsellmatrix = $rel->{upsell_prod_matrix}->{$installedprodname};
    if (EDRu::inarr($toinstallprodname, @$upsellmatrix)){
        $can_upsell = 1;
    }
    return $can_upsell;
}

sub completion {
    my $rel=shift;
    return;
}

# Uninstall VRTSsvs for upgrade due to
# SVS merging into SFCFSHA
sub set_svs_upgrade_sys {
    my ($rel,$sys) = @_;
    my ($cpic, $prod, $prodver);

    return 1 unless (Cfg::opt('upgrade'));

    $cpic=Obj::cpic();
    $prod=$sys->prod($cpic->{prod});
    $prodver = $prod->{vers};
    for my $oldpkg (keys%{$sys->{pkgvers}}) {
        next unless ($oldpkg =~ /VRTSsvs/);
        push (@{$cpic->{uninstallpkgs}},$oldpkg) unless (EDRu::inarr($oldpkg,@{$cpic->{uninstallpkgs}}));
    }
    return;
}

sub match_prod {
    my ($rel,$prod)=@_;
    my ($matched_prod);

    $prod=uc($prod);
    return "" unless ($prod);
    $matched_prod="";
    for my $rel_prod (@{$rel->{prods}}) {
        if (($prod eq $rel_prod) ||
            ($prod=~/^\D+$/ && $rel_prod=~/^$prod\d+/)) {
            $matched_prod=$rel_prod;
            last;
        }
    }
    return $matched_prod;
}

package Rel::SNAS60::AIX;
@Rel::SNAS60::AIX::ISA = qw(Rel::SNAS60::Common);

sub init_plat {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(6.1 7.1) ];
    $rel->{platreqs}=[ 'AIX 6.1 TL6', 'AIX 6.1 TL7', 'AIX 6.1 TL8',
                       'AIX 7.1 TL0', 'AIX 7.1 TL1', 'AIX 7.1 TL2' ];
    $rel->{upgradevers}=[ qw(5.0.3 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFCFSRAC61 SVS61 SFSYBASECE61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS61 SFSYBASECE61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS61 SFSYBASECE61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS61 SFSYBASECE61));
    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50)];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSacclib:504,0,0,0
VRTSamf:4624,8471,0,7
VRTSaslapm:0,1018,0,1000
VRTScavf:816,67,0,2
VRTScps:38188,14095,0,5
VRTSdbac:4039,3026,0,513
VRTSdbed:136114,0,0,5
VRTSfsadv:35243,0,0,3
VRTSfssdk:3249,0,0,0
VRTSgab:639,3437,0,76
VRTSglm:32,395,0,18
VRTSgms:0,160,0,0
VRTSllt:1157,557,0,228
VRTSob:94380,0,0,297
VRTSodm:531,584,0,5
VRTSperl:78368,0,0,0
SYMCsnascpi60:13882,0,0,0
VRTSsfmh:140690,0,0,0
VRTSspt:26636,0,0,0
VRTSvbs:64801,0,0,1
VRTSvcs:391031,24260,0,258
VRTSvcsag:21635,0,0,46
VRTSvcsea:6848,0,0,56
VRTSvcsvmw:11260,0,0,1
VRTSvcswiz:6982,0,0,0
VRTSveki:0,130,0,0
VRTSvlic:88,0,0,1426
VRTSvxfen:695,1706,0,1004
VRTSvxfs:30511,12031,0,3105
VRTSvxvm:8756,206238,0,29774
_PKGSPACE_

    $rel->{commands_need_be_checked}=[ qw(entstat genkex getconf hostid installp inutoc ldd lsattr lsdev lslpp lsps netstat nm odmget prtconf strload) ];

    return;
}

sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($msg,$iosl,$cprodabbr,$ostl,$tl,$platvers);
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return '' if (Cfg::opt('ignorechecks'));
    $cprodabbr=CPIC::get('prod');
    $cprodabbr=~s/\d+$//m;
    my $minimum_vios_ioslevel = '2.1.3.10-FP-23';
    my $minvers = $minimum_vios_ioslevel;

    # VIOS ioslevel check
    if ($sys->exists('/usr/ios/cli/ioscli')) {
        $ostl = $sys->cmd('/usr/ios/cli/ioscli ioslevel 2> /dev/null');
        # format the output for EDR::cmpvers
        $iosl = $ostl;
        $iosl =~ s/\D+/\./mg if ($iosl);
        $minvers =~ s/\D+/\./mg;
        if ($iosl) {
            if ($cprodabbr !~ /DMP/m) {
                $msg = Msg::new("Cannot perform any task for $cprodabbr on system $sys->{sys} since it is a VIO server. Only the DMP product is supported on VIO server.");
                $sys->push_error($msg);
                return '';
            }
            if (2 == EDRu::compvers($iosl,$minvers)) {
                $msg=Msg::new("Cannot perform any task for $cprodabbr on system $sys->{sys} since its ioslevel is $ostl. Minimum VIOS ioslevel required is $minimum_vios_ioslevel.");
                $sys->push_error($msg);
                return '';
            } else {
                # Do not need check TL version if VIOS installed
                return 1;
            }
        }
    }

    $tl = $sys->{ostechlevel};

    if ($sys->{platvers} eq '6.1') {
        if ($tl < 6) {
            # CPI should detect OS version by 'oslevel -qs' option and compare with 'oslevel -s'
            my ($newlevel,$newtl,$platvers);
            $newlevel = $sys->cmd("_cmd_oslevel -qs | _cmd_head -1 2>/dev/null");
            $newtl = $1 if ($newlevel =~ /\n\d+-(\d+)/);
            if ($newtl >= 6) {
                $rel->get_nonupdated_filesets_sys($sys, $newlevel);
            } else {
                $platvers = join "\n\t", grep { /6\.1/ } @{$rel->{platreqs}};
                $msg=Msg::new("Cannot perform any task for $cprodabbr on system $sys->{sys} since its oslevel is 6.1 TL $tl. The following oslevels are supported to perform tasks for $cprodabbr :\n\t$platvers");
                $sys->push_error($msg);
                return '';
            }
        }
    }

    # AIX 7.1 TL 0 or later - no check needed

    return 1;
}

sub get_nonupdated_filesets_sys {
    my ($rel, $sys, $newlevel) = @_;
    my ($newtl, $level, $output, $msg);

    $newtl = $1 if ($newlevel =~ /\n\d+-(\d+)/);
    $level = $1 if ($newlevel =~ /\n(\d+?-\d+)-/);
    $output = $sys->cmd("_cmd_oslevel -rl $level");
    $msg=Msg::new("The following filesets have lower levels than the recommended level for TL $newtl on $sys->{sys}. It is recommended to upgrade the filesets to the recommended level.\n$output");
    $sys->push_warning($msg);
    return 1;
}

# AIX
sub new_pkg_init_plat {
    my ($rel,$pkg) = @_;
    push(@{$pkg->{softdeps}}, 'VRTSccsta.ccsta', 'VRTShalR')
        if (EDRu::inarr($pkg->{pkg},qw/VRTSpbx VRTSicsco VRTSjre VRTSjre15/));
    push(@{$pkg->{softdeps}}, 'VRTSccsta.ccsta')
        if ($pkg->{pkg} eq 'VRTSobc33');
    $pkg->{previouspkgnames}=[ qw( VRTSvrw.rte ) ]
        if ($pkg->{pkg} eq 'VRTSvrw');
    push(@{$pkg->{softdeps}}, qw(VRTScmcm VRTSvcs))
        if ($pkg->{pkg} =~ /^VRTSat\./);

    return;
}

sub get_tunable_value_sys{
    my ($rel,$sys,$tunable) =@_;
    my ($origval);
    $origval = $sys->cmd("_cmd_vmo -o $tunable 2>/dev/null |_cmd_awk '{print \$3}'");
    chomp $origval;
    return $origval;
}

sub set_tunable_value_sys{
    my ($rel,$sys,$tunable,$value) =@_;
    my ($out);
    $out = $sys->cmd("_cmd_yes | _cmd_vmo -p -y -o $tunable=$value");
    return (EDR::cmdexit(), $out);
}

sub init_obsolete_packages_description {
    my $rel = shift;
    my $pkg_desc_aix;
    $pkg_desc_aix = {
        'VRTSacclib.rte' => 'Cluster Server ACC Library',
        'VRTSat.client' => 'Product Authentication Service Client',
        'VRTSat.server' => 'Product Authentication Service Server',
        'VRTScmccc.rte' => 'Cluster Management Console Cluster Connector',
        'VRTScmcs.rte' => 'Cluster Management Console for single cluster environnments',
        'VRTScscm.rte' => 'Cluster Server Cluster Manager',
        'VRTScscw.rte' => 'Cluster Server Configuration Wizards',
        'VRTScsocw.rte' => 'Cluster Server Oracle and RAC Configuration Wizards',
        'VRTScssim.rte' => 'Cluster Server Simulator',
        'VRTScutil.rte' => 'Cluster Utility',
        'VRTSdbac.rte' => 'Oracle Real Application Cluster Support Package',
        'VRTSgab.rte' => 'Group Membership and Atomic Broadcast',
        'VRTSgapms.VRTSgapms' => 'Generic Array Plugin',
        'VRTSjre.rte' => 'JRE Redistribution',
        'VRTSjre15.rte' => 'JRE Redistribution',
        'VRTSllt.rte' => 'Low Latency Transport',
        'VRTSperl.rte' => 'Perl Redistribution',
        'VRTSvail.VRTSvail' => 'Array Providers',
        'VRTSvcs.msg.en_US' => 'Cluster Server English Message Catalogs',
        'VRTSvcs.man' => 'Manual Pages for Cluster Server',
        'VRTSvcs.rte' => 'Cluster Server',
        'VRTSvcsag.rte' => 'Cluster Server Bundled Agents',
        'VRTSvcsdb.rte' => 'Cluster Server Db2udb Enterprise Extension',
        'VRTSvcsor.rte' => 'High Availability Agent for Oracle',
        'VRTSvcssy.rte' => 'Cluster Server Sybase Enterprise Extension',
        'VRTSvdid.rte' => 'Device Identifier',
        'VRTSvxfen.rte' => 'I/O Fencing',
        'VRTSweb.rte' => 'Web Server',
    };
    $rel->SUPER::init_obsolete_packages_description();
    $rel->{package_descriptions} = {%{$rel->{package_descriptions}}, %$pkg_desc_aix};
    return 1;
}

package Rel::SNAS60::HPUX;
@Rel::SNAS60::HPUX::ISA = qw(Rel::SNAS60::Common);

sub init_plat {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(11.31) ];
    $rel->{platreqs}=[ 'HP-UX 11iv3, 1103 fusion or later(IA or PA)' ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFCFSRAC61 SVS61 SFSYBASECE61 APPLICATIONHA61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS61 SFSYBASECE61 APPLICATIONHA61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS61 SFSYBASECE61 APPLICATIONHA61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS61 SFSYBASECE61 APPLICATIONHA61));
    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50)];
    $rel->{ru_version}='5.1.100.000';
    $rel->{cross_upgradable_matrix}= {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => [],
        'SFCFSHA' => [],
        'SFCFS' => ['SFCFSHA'],
        'SFHA' => [],
        'SF' => ['ALL'],
        'VCS' => [],
        'VM' => ['ALL'],
        'DMP' => ['SF'],
        'FS' => ['ALL'],
        'AT' => ['ALL'],
    };

    $rel->{commands_need_be_checked}=[ qw(getconf hostid ioscan kcmodule kctune lanadmin lanscan machinfo model netstat nm swagentd swapinfo swinstall swlist swmodify swreg swremove) ];
    #$rel->{commands_need_be_checked_for_install}=[ qw(gunzip) ];
    #$rel->{commands_need_be_checked_for_upgrade}=[ qw(gunzip) ];
    #$rel->{commands_need_be_checked_for_patchupgrade}=[ qw(gunzip) ];

    #$rel->{batchuninstall}=1;
    return;
}

sub check_willow_sys {
    my ($rel,$sys)=@_;
    my ($msg,$iv);
    $iv=$sys->cmd("_cmd_swlist -l product -a revision -x verbose=0 VRTSwl 2> /dev/null | _cmd_grep VRTSwl");
    if ($iv=~/\s*VRTSwl\s*(\S+)/mx) {
        $iv=$1;
        $iv=$sys->padv->pkg_version_cleanup($iv);
        $msg=Msg::new("Incompatible VRTSwl $iv package is detected on $sys->{sys}. It will be removed as part of the installation.");
        $sys->push_warning($msg);
        return '';
    }
    return 1;
}

# HPUX
sub new_pkg_init_plat {
    my ($rel,$pkg) = @_;
    push(@{$pkg->{softdeps}}, 'VRTSccsta', 'VRTShalR')
        if (EDRu::inarr($pkg->{pkg},qw/VRTSpbx VRTSicsco VRTSjre VRTSjre15/));
    push(@{$pkg->{softdeps}}, 'VRTSccsta')
        if ($pkg->{pkg} eq 'VRTSobc33');
    return;
}

sub completion {
    my $rel=shift;
    my $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        if ($sys->{depotregisteredpath}) {
           $sys->cmd("_cmd_swreg -u -l depot $sys->{depotregisteredpath}");
        }
    }
    $rel->SUPER::completion();
    return;
}

sub platvers_sys {
    my ($rel,$sys)=@_;
    my ($oslevel,$msg,$fusion_version,$recommended_fusion_version,$recommeded_fusion_version_desc);
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return '' if (Cfg::opt('ignorechecks'));

    $recommended_fusion_version='1103';
    $recommeded_fusion_version_desc=Msg::new("HP-UX 11i Version 3 March 2011 release update")->{msg};
    #get the HPUX os level string, the recommended version should be fusion 1103 or later
    $fusion_version=$sys->{fusionversion};
    if ($fusion_version) {
        $oslevel='';
        if ($fusion_version=~/11\.31\.(\d+)/mx) {
            $oslevel=$1;
            $sys->set_value('oslevel',$oslevel);
        }
        if (!$oslevel || $oslevel < $recommended_fusion_version) {
            $msg=Msg::new("The OS version of $sys->{sys} is HPUX B.$fusion_version. The recommended OS version is HPUX B.11.31.$recommended_fusion_version($recommeded_fusion_version_desc) or later.");
            $sys->push_warning($msg);
            return '';
        }
    } else {
        $msg=Msg::new("Cannot check the HPUX OS version on $sys->{sys}. The recommended OS version is HPUX B.11.31.$recommended_fusion_version($recommeded_fusion_version_desc) or later.");
        $sys->push_warning($msg);
        return '';
    }
    $rel->check_willow_sys($sys) if (Cfg::opt(qw/install upgrade/));

    return 1;
}

sub preinstall_sys {
    my ($rel,$sys) = @_;
    if (defined $sys->{requirerebootpkgspatches}) {
        $sys->padv->auto_reboot_disable_sys($sys);
        $sys->set_value('reboot', 1);
    }
    return 1;
}

sub postinstall_sys {
    my ($rel,$sys) = @_;
    if (defined $sys->{requirerebootpkgspatches}) {
        $sys->padv->auto_reboot_enable_sys($sys);
    }
    return 1;
}

sub preremove_sys {
    my ($rel,$sys) = @_;
    if (defined $sys->{requirerebootpkgspatches}) {
        $sys->padv->auto_reboot_disable_sys($sys);
        $sys->set_value('reboot', 1);
    }
    return 1;
}

sub postremove_sys {
    my ($rel,$sys) = @_;
    if (defined $sys->{requirerebootpkgspatches}) {
        $sys->padv->auto_reboot_enable_sys($sys);
    }
    return 1;
}

package Rel::SNAS60::HPUX1131;
@Rel::SNAS60::HPUX1131::ISA = qw(Rel::SNAS60::HPUX);

sub init_padv {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(11.31) ];
    $rel->{upgradevers}=[ qw(3.5 4.1 5.0 5.0.1 5.1.100) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:419,1453,0,7
VRTSaslapm:0,5596,0,5413
VRTScavf:781,65,0,7
VRTScps:30873,0,0,2
VRTSdbac:4779,1774,0,497
VRTSdbed:212410,0,0,5
VRTSfsadv:32499,0,0,3
VRTSfssdk:3471,0,0,0
VRTSgab:175,2459,0,104
VRTSglm:1,766,0,116
VRTSgms:0,459,0,2
VRTSllt:650,1041,0,690
VRTSob:126598,0,0,201
VRTSodm:18826,901,0,372
VRTSperl:175846,0,0,0
SYMCsnascpi60:4911,0,0,0
VRTSsfmh:199353,0,0,0
VRTSspt:32704,0,0,0
VRTSvbs:73970,0,0,1
VRTSvcs:251802,10243,0,248
VRTSvcsag:4960,1,0,58
VRTSvcsea:9174,0,0,52
VRTSvlic:122,1919,0,4388
VRTSvxfen:1049,1510,0,542
VRTSvxfs:7602,36694,0,30686
VRTSvxvm:26153,446134,0,515172
_PKGSPACE_
    return;
}

package Rel::SNAS60::Linux;
@Rel::SNAS60::Linux::ISA = qw(Rel::SNAS60::Common);

sub init_plat {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC61 SFCFSRAC61 SFSYBASECE61 SFCFSHA61 SFHA61
                                APPLICATIONHA61 SF61 VCS61 VM61 DMP61 FS61) ];
    $rel->{platreqs} = ['RHEL5 U5 (2.6.18-194.el5)', 'RHEL5 U6 (2.6.18-238.el5)', 'RHEL5 U7 (2.6.18-274.el5)', 'RHEL5 U8 (2.6.18-308.el5)', 'RHEL5 U9 (2.6.18-348.el5)',
                         'RHEL6 U3 (2.6.32-279.el6)', 'RHEL6 U4 (2.6.32-358.el6)','RHEL6 U5 (2.6.32-431.el6)',
                         'SLES11 SP2 (3.0.13)',
                         'SLES11 SP3 (3.0.76)',
                         'OEL5 U5 (2.6.18-194.el5)','OEL5 U6 (2.6.18-238.el5)','OEL5 U7 (2.6.18-274.el5)','OEL5 U8 (2.6.18-308.el5)','OEL5 U9 (2.6.18-348.el5)',
                         'OEL6 U3 (2.6.32-279.el6)','OEL6 U4 (2.6.32-358.el6)','OEL6 U5 (2.6.32-431.el6)'];
    $rel->{upgradevers}=[ qw(5.0.30 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50 VRTSatClient50)];

    $rel->{commands_need_be_checked}=[ qw(arch ethtool getconf hostid modprobe modunload netstat nm) ];

    return;
}

# Just status display message are commented because we are following KISS as different no. of status messages on
# different plats create unnecessary complexity for EDR
sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($patchlevel,$msg,$rpm_dir,$kret,$ksles,$padv,$kstring,$cpic,@f,$distro,@pkg_files,$pkg,$prod);
    my ($localsys,$mediapath,$tmpdir,$vmware,$testVMware,$vmware_script,@vmware_tool_scripts,$state,$platvers);
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
    $ksles=$1 if ($kstring =~ /\-\d+\.([\d+\.]+)/mx);
    $ksles =~ s/\.$// if ($ksles);
    @f=split(/\W/m,$kstring);

    $localsys = Obj::localsys();
    $mediapath=EDR::get('mediapath');
    $tmpdir = EDR::tmpdir();
    $vmware = 0;
    $testVMware = "$mediapath/scripts/bin/testVMware";

    # Check ESX/KVM for AppHA
    if ($prod->{prod} =~ /ApplicationHA/) {
        $testVMware = "/opt/VRTSsfmh/bin/testVMware" unless ($localsys->exists($testVMware));
        if ($localsys->exists($testVMware)) {
            $localsys->copy_to_sys($sys,$testVMware,"$tmpdir/");
            $sys->cmd("$tmpdir/testVMware");
            if (EDR::cmdexit() == 0) {
                # it's VMware
                $sys->set_value('vmtype','vmware');
                $vmware = 1;

                @vmware_tool_scripts=('/etc/init.d/vmware-tools','/etc/vmware-tools/services.sh');
                for my $script (@vmware_tool_scripts) {
                    if($sys->exists($script)) {
                        $vmware_script=$script;
                        last;
                    }
                }

                if ($vmware_script) {
                    $state = $sys->cmd("$vmware_script status 2> /dev/null");
                    # vmware-tools not running
                    if ($state =~ /not/i) {
                        # try to start it
                        $sys->cmd("$vmware_script start 2> /dev/null");
                        sleep 5;
                        $state = $sys->cmd("$vmware_script status 2> /dev/null");
                        if ($state =~ /not/i) {
                            $msg = Msg::new("VMware-tools is not running, $cpic->{script} script attempted to start it but failed. Start the tool before installing $prod->{abbr}");
                            $sys->push_error($msg);
                            return '';
                        }
                    }
                } else {
                    $msg = Msg::new("The installer did not detect VMware-tools installed on $sys->{sys}. Install VMware-tools and start it before you perform any tasks on $prod->{abbr}");
                    $sys->push_error($msg);
                    return '';
                }
            }
        } else {
            $msg = Msg::new("$cpic->{script} cannot detect if you are running under a VMware environment on $sys->{sys}, which is required to install ApplicationHA under the VMware or the KVM environment.");
            $sys->push_warning($msg);
            # if installer do NOT have testVMware utility, print a warning but pass the check
            $vmware = 1;
        }

        # AppHA only support to be installed on VMware VM, and KVM on RHEL,
        # do not support to be installed on physical systems, or KVM on OEL/SuSE
        if (!$vmware) {
            if ($sys->{virtual_type} eq Padv->VIRT_KVM) {
                if ($distro ne 'RHEL') {
                    $msg=Msg::new("$prod->{prod} for KVM does not support to be installed to OEL and SuSE.");
                    $sys->push_error($msg);
                    return '';
                }
            } else {
                $msg=Msg::new("$prod->{prod} is only supported on systems running under VMware or KVM environment");
                $sys->push_error($msg);
                return '';
            }
        }
    }

    if ($distro eq 'RHEL') {
        $padv->{cmd}{selinuxenabled}='/usr/sbin/selinuxenabled';
        if ($kstring =~ /el6/m) {
            if ($kret < 431) { # RHEL6u5 check
                $platvers = join "\n\t", grep { /RHEL6/ } @{$rel->{platreqs}};
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. The following Kernel Release are supported to install this product:\n\t$platvers");
                $sys->push_stop_checks_error($msg);
                return '';
            } elsif (!$ksles || (EDRu::compvers($ksles, '11.2') == 2)) {
                $platvers = join "\n\t", grep { /RHEL6/ } @{$rel->{platreqs}};
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. The following Kernel Release are supported to install this product:\n\t$platvers");
                $sys->push_warning($msg);
            }
        } elsif ($kstring =~ /el5/m) {
            if ($kret < 194) { # RHEL5u5 or above check
                $platvers = join "\n\t", grep { /RHEL5/ } @{$rel->{platreqs}};
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. The following Kernel Release are supported to install this product:\n\t$platvers");
                $sys->push_stop_checks_error($msg);
                return '';
            }
        }

    } elsif ($distro eq 'SLES') {
        $padv->{cmd}{selinuxenabled}='/usr/bin/selinuxenabld';

        #In 6.1, only SLES 11 SP2 is supported,
        #SLES 10 SP3 kernel version is above 2.6.16.60-0.54.5
        #SLES 10 SP4 kernel version is above 2.6.16.60-0.85.1
        #For PATCHLEVEL is higher than SuSE 11 SP2, maybe does not support

        $patchlevel=$sys->{patchlevel};

        if ($f[0] >= 3) {
            # sles11sp2/sp3 is using kernel 3.x
            if ($patchlevel != 2 && $patchlevel != 3) {
                $msg=Msg::new("SuSE 11 SP2 or SP3 are the recommended platforms for the release on $sys->{sys}.");
                $sys->push_warning($msg);
                return '';
            }
        } else {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 3.0.13(SLES11 SP2) or 3.0.76(SLES11 SP3) is supported on SuSE11. Upgrade the OS to SLES11 SP2 or SP3 in order to install this product");
            $sys->push_error($msg);
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
            if ($kstring =~ /uek/m || $kstring !~ /^2\.6\.32/m) {
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Red Hat compatible Kernel Release 2.6.32 is supported on Oracle Linux 6. you may configure the operating system to boot with this kernel instead.");
                $sys->push_error($msg);
                return '';
            }
        } elsif ($kstring =~ /el5/m) {
            # OL5 check
            if ($kstring =~ /uek/m || $kstring !~ /^2\.6\.18/m) {
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

    # XEN is not supported in 6.0
    if ($kstring =~ /xen/m) {
        $msg=Msg::new("Kernel Release on $sys->{sys} is $kstring. Xen kernel is not supported in this release.");
        $sys->push_error($msg);
        return '';
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

# Linux
sub new_pkg_init_plat {
    my ($rel,$pkg) = @_;
    push(@{$pkg->{softdeps}}, 'VRTSccsta', 'VRTShalR')
        if (EDRu::inarr($pkg->{pkg},qw/VRTSpbx VRTSicsco VRTSjre VRTSjre15/));
    push(@{$pkg->{softdeps}}, 'VRTSccsta')
        if ($pkg->{pkg} eq 'VRTSobc33');
    $pkg->{force_uninstall}=1 if ($pkg->{pkg} eq 'VRTSweb');
    $pkg->{force_uninstall}=1 if ($pkg->{pkg} eq 'VRTSdcli');
    return;
}

sub get_tunable_value_sys{
    my ($rel,$sys,$tunable) =@_;
    my ($origval);
    $origval = $sys->cmd("_cmd_cat /proc/sys/vm/$tunable 2>/dev/null");
    chomp $origval;
    return $origval;
}

sub set_tunable_value_sys{
    my ($rel,$sys,$tunable,$value) =@_;
    my ($cpic, $file, @lines, @newlines, $tunable_info);
    $cpic= Obj::cpic();
    if ($sys->exists('/etc/sysctl.conf')) {
        $file = $sys->readfile('/etc/sysctl.conf');
        @lines = split (/\n/,$file);
        @newlines = ();
        for my $line (@lines) {
            if ($line !~ /^vm.$tunable = / ) {
                push @newlines, $line;
            }
        }
        $file = join("\n", @newlines);
    } else {
        $file = '';
    }
    $sys->writefile($file, '/etc/sysctl.conf');

    $tunable_info=$cpic->get_tunable_info($tunable);
    if ($value != 0 || !$tunable_info->{zero_to_reset}) {
        $sys->appendfile("\nvm.$tunable = $value\n", '/etc/sysctl.conf');
    }

    $sys->cmd("echo $value > /proc/sys/vm/$tunable 2>/dev/null");

    $file = $sys->readfile('/etc/sysctl.conf');
    return (0,$file);
}

sub init_obsolete_packages_description {
    my $rel = shift;
    my $pkg_desc_lin;
    $pkg_desc_lin = {
        'VRTSodm-common' => 'Oracle Disk Manager',
        'VRTSmapro-common' => 'Storage Mapping Provider',
        'VRTSd2gui-common' => 'Storage Foundation Graphical User Interface for DB2',
        'VRTSdb2ed-common' => 'Storage Foundation for DB2',
        'VRTSdbcom-common' => 'Storage Foundation Common Utilities for Databases',
        'VRTSdbed-common' => 'Storage Foundation for Oracle',
        'VRTSorgui-common' => 'High Availability Agent for Oracle',
        'VRTSsybed-common' => 'Storage Foundation for Sybase',
        'VRTSvxfs-common' => 'File System Common Libraries',
        'VRTSvxvm-common' => 'Volume Manager Common Libraries',
    };
    $rel->SUPER::init_obsolete_packages_description();
    $rel->{package_descriptions} = {%{$rel->{package_descriptions}}, %$pkg_desc_lin};
    return 1;
}

sub prod_options_menu {
    my ($rel,$task,$prodname) = @_;
    my $options=[];
    $options = [qw(vfr)] if ($prodname =~ /SNAS/);
    return $options;
}

package Rel::SNAS60::RHEL5x8664;
@Rel::SNAS60::RHEL5x8664::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC61 SFCFSRAC61 SFCFSHA61 SFHA61
                                APPLICATIONHA61 SF61 VCS61 VM61 DMP61 FS61) ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFSYBASECE61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SFSYBASECE61));
    $rel->{platreqs} = ['RHEL5 U5 (2.6.18-194.el5)', 'RHEL5 U6 (2.6.18-238.el5)', 'RHEL5 U7 (2.6.18-274.el5)', 'RHEL5 U8 (2.6.18-308.el5)', 'RHEL5 U9 (2.6.18-348.el5)',
                        'OEL5 U5 (2.6.18-194.el5)','OEL5 U6 (2.6.18-238.el5)','OEL5 U7 (2.6.18-274.el5)','OEL5 U8 (2.6.18-308.el5)','OEL5 U9 (2.6.18-348.el5)'];
    $rel->{platvers}=[ qw(2.6.18-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSacclib:504,0,0,0
VRTSamf:5557,228,0,16
VRTSaslapm:0,0,0,1388
VRTScavf:798,84,0,0
VRTScps:32467,0,0,5
VRTSdbac:3407,69,0,344
VRTSdbed:112532,1,0,5
VRTSfsadv:13772,1,0,9
VRTSfssdk:1195,3,0,0
VRTSgab:3657,369,0,60
VRTSglm:62,0,0,310
VRTSgms:5,0,0,105
VRTSjboss:139,0,0,1
VRTSllt:3864,59,0,360
VRTSlvmconv:3,181,0,96
VRTSmq6:304,0,0,19
VRTSmysql:151,0,0,3
VRTSob:71977,0,0,206
VRTSodm:205,324,0,261
VRTSperl:71568,0,0,0
VRTSsapcms:159,0,0,5
VRTSsaplc:185,0,0,56
VRTSsapnw04:262,0,0,47
VRTSsapwebas71:248,0,0,55
SYMCsnascpi60:13894,0,0,0
VRTSsfmh:109397,0,0,0
VRTSspt:29854,0,0,0
VRTSvbs:54670,0,0,1
VRTSvcs:161202,11267,0,263
VRTSvcsag:84625,0,0,71
VRTSvcsdr:731,0,0,1
VRTSvcsea:12717,0,0,55
VRTSvcsvmw:15502,0,0,1
VRTSvcswas:162,0,0,28
VRTSvcswiz:11874,0,0,0
VRTSvlic:76,0,0,1236
VRTSvxfen:1125,43,0,703
VRTSvxfs:4297,20185,0,6953
VRTSvxvm:1900,63634,0,42679
VRTSwls:348,0,0,10
_PKGSPACE_
    return;
}

package Rel::SNAS60::RHEL5ppc64;
@Rel::SNAS60::RHEL5ppc64::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SVS61 SFRAC61 SFSYBASECE61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS61 SFRAC61 SFSYBASECE61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS61 SFRAC61 SFSYBASECE61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS61 SFRAC61 SFSYBASECE61));
    $rel->{platvers}=[ qw(2.6.18-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:5936,207,0,15
VRTSaslapm:0,0,0,1639
VRTSatClient:29834,0,0,685
VRTSatServer:62713,0,29,1041
VRTScavf:740,86,0,0
VRTScps:41798,0,0,2
VRTSdbed:22822,0,0,0
VRTSfssdk:1536,3,0,0
VRTSgab:3482,427,0,98
VRTSglm:52,0,0,483
VRTSgms:7,0,0,1599
VRTSllt:3037,57,0,460
VRTSlvmconv:3,184,0,101
VRTSob:77473,0,0,227
VRTSodm:223,587,0,311
VRTSperl:52046,0,0,0
SYMCsnascpi60:3596,0,0,0
VRTSsfmh:67785,0,0,0
VRTSspt:5451,0,0,0
VRTSvcs:158181,9865,0,327
VRTSvcsag:3098,0,0,0
VRTSvcsdr:778,0,0,1
VRTSvcsea:12425,0,0,34
VRTSvlic:69,0,0,1636
VRTSvxfen:905,61,0,784
VRTSvxfs:3552,24137,0,8039
VRTSvxvm:1481,58209,0,28116
_PKGSPACE_
    return;
}

package Rel::SNAS60::RHEL6x8664;
@Rel::SNAS60::RHEL6x8664::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{prods}=[ qw(FS61 VM61 VCS61 SF61 SFHA61 SFCFSHA61 SNAS60) ];
    $rel->{pkgsetprods}=[ qw(SNAS60) ];
    $rel->{menuprods}=[ qw(SNAS60) ];
    $rel->{upgradeprods} = [ qw(SNAS60 SFCFSHA61 SFHA61
                                SF61 VCS61 VM61 FS61) ];
    $rel->{platreqs} =[ 'RHEL6 U5 (2.6.32-431.11.2.el6)'];
    $rel->{platvers}=[ qw(2.6.32-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSacclib:504,0,0,0
VRTSamf:9967,222,0,16
VRTSaslapm:0,0,0,877
VRTScavf:801,84,0,0
VRTScps:29544,0,0,6
VRTSdbms3:45055,0,0,0
VRTSdbac:9028,66,0,333
VRTSdbed:112209,1,0,5
VRTSfsadv:14051,1,0,9
VRTSfssdk:1916,3,0,0
VRTSgab:15062,374,0,61
VRTSglm:62,0,0,395
VRTSgms:5,0,0,84
VRTSjboss:139,0,0,1
VRTSllt:31293,59,0,351
VRTSlvmconv:3,180,0,96
VRTSmq6:304,0,0,19
VRTSmysql:151,0,0,3
VRTSob:71837,0,0,206
VRTSodm:190,456,0,307
VRTSperl:71814,0,0,0
VRTSsapcms:159,0,0,5
VRTSsaplc:185,0,0,56
VRTSsapnw04:282,0,0,18
VRTSsapwebas71:249,0,0,29
SYMCsnascpi:5773,0,0,0
SYMCsnas:14683,0,0,0
VRTSsfmh:109396,0,0,0
VRTSspt:30036,0,0,0
VRTSvbs:55230,0,0,1
VRTSvcs:137017,7589,0,263
VRTSvcsag:77310,0,0,71
VRTSvcsdr:2910,0,0,1
VRTSvcsea:7389,0,0,55
VRTSvcsvmw:13915,0,0,1
VRTSvcswas:162,0,0,28
VRTSvcswiz:11874,0,0,0
VRTSvlic:76,0,0,1251
VRTSvxfen:14707,46,0,689
VRTSvxfs:2634,21094,0,25875
VRTSvxvm:1888,57087,0,37747
VRTSwls:348,0,0,10
_PKGSPACE_
    return;
}

package Rel::SNAS60::RHEL6ppc64;
@Rel::SNAS60::RHEL6ppc64::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS61 SFRAC61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS61 SFRAC61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS61 SFRAC61));
    $rel->{platvers}=[ qw(2.6.32-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:3898,190,0,15
VRTSaslapm:0,0,0,692
VRTScavf:689,80,0,0
VRTScps:20026,0,0,2
VRTSdbac:4744,66,0,384
VRTSdbed:50546,1,0,3
VRTSfsadv:11376,0,0,3
VRTSfssdk:1158,3,0,0
VRTSgab:5003,369,0,61
VRTSglm:60,0,0,396
VRTSgms:5,0,0,83
VRTSllt:3646,50,0,343
VRTSlvmconv:3,176,0,93
VRTSob:72984,0,0,206
VRTSodm:184,456,0,303
VRTSperl:116511,0,0,0
SYMCsnascpi60:4462,0,0,0
VRTSsfmh:89983,0,0,0
VRTSspt:25422,0,0,0
VRTSsvs:137315,0,0,0
VRTSvbs:47009,0,0,3
VRTSvcs:160972,7186,0,232
VRTSvcsag:2817,0,0,69
VRTSvcsdr:1017,0,0,1
VRTSvcsea:13805,0,0,46
VRTSvlic:59,0,0,1221
VRTSvxfen:5108,42,0,657
VRTSvxfs:3009,18121,0,7296
VRTSvxvm:1581,47900,0,31806
_PKGSPACE_
    return;
}

package Rel::SNAS60::SLES10x8664;
@Rel::SNAS60::SLES10x8664::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC61 SFCFSRAC61 SFSYBASECE61 SFCFSHA61 SFHA61
                                SF61 VCS61 VM61 DMP61 FS61) ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(APPLICATIONHA61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(APPLICATIONHA61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(APPLICATIONHA61));

    $rel->{platvers}=[ qw(2.6.16-* 2.6.22-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:24608,205,0,16
VRTSaslapm:0,0,0,1185
VRTScavf:717,80,0,0
VRTScps:22584,0,0,2
VRTSdbac:8432,73,0,349
VRTSdbed:113455,1,0,5
VRTSfsadv:14193,1,0,9
VRTSfssdk:1230,3,0,0
VRTSgab:10896,362,0,67
VRTSglm:61,0,0,1021
VRTSgms:5,0,0,223
VRTSllt:6744,54,0,359
VRTSlvmconv:3,175,0,95
VRTSob:71837,0,0,206
VRTSodm:188,425,0,965
VRTSperl:109889,0,0,0
SYMCsnascpi60:4842,0,0,0
VRTSsfmh:87718,0,0,0
VRTSspt:28041,0,0,0
VRTSsvs:138779,0,0,0
VRTSvbs:55224,0,0,1
VRTSvcs:154971,9024,0,250
VRTSvcsag:2913,0,0,69
VRTSvcsdr:1759,0,0,1
VRTSvcsea:12496,0,0,51
VRTSvlic:62,0,0,1210
VRTSvxfen:11494,45,0,699
VRTSvxfs:3450,21756,0,18317
VRTSvxvm:1774,58744,0,49195
_PKGSPACE_
    return;
}

package Rel::SNAS60::SLES10ppc64;
@Rel::SNAS60::SLES10ppc64::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SVS61 SFRAC61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS61 SFRAC61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS61 SFRAC61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS61 SFRAC61));

    $rel->{platvers}=[ qw(2.6.16-* 2.6.22-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:11299,209,0,15
VRTSaslapm:0,0,0,1627
VRTSatClient:29834,0,0,685
VRTSatServer:62713,0,29,1041
VRTScavf:743,86,0,0
VRTScps:40869,0,0,2
VRTSdbed:21857,0,0,0
VRTSfssdk:1580,3,0,0
VRTSgab:6842,426,0,103
VRTSglm:54,0,0,509
VRTSgms:7,0,0,2081
VRTSllt:4984,58,0,450
VRTSlvmconv:3,184,0,101
VRTSob:77473,0,0,227
VRTSodm:231,582,0,484
VRTSperl:52127,0,0,0
SYMCsnascpi60:3596,0,0,0
VRTSsfmh:67785,0,0,0
VRTSspt:5451,0,0,0
VRTSvcs:156312,9782,0,327
VRTSvcsag:3112,0,0,0
VRTSvcsdr:1492,0,0,1
VRTSvcsea:12425,0,0,34
VRTSvlic:73,0,0,1520
VRTSvxfen:7135,63,0,789
VRTSvxfs:3353,23987,0,8701
VRTSvxvm:1591,58593,0,51425
_PKGSPACE_
    return;
}

package Rel::SNAS60::SLES11x8664;
@Rel::SNAS60::SLES11x8664::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC61 SFCFSRAC61 SFSYBASECE61 SFCFSHA61 SFHA61
                                APPLICATIONHA61 SF61 VCS61 VM61 DMP61 FS61) ];
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SFSYBASECE61));
    $rel->{platreqs}=['SLES11 SP2 (3.0.13)','SLES11 SP3 (3.0.76)'];
    $rel->{platvers}=[ qw(2.6.27-* 2.6.32-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSacclib:504,0,0,0
VRTSamf:10070,227,0,16
VRTSaslapm:0,0,0,1369
VRTScavf:719,80,0,0
VRTScps:30605,0,0,6
VRTSdbac:4657,74,0,348
VRTSdbed:112748,1,0,5
VRTSfsadv:14363,1,0,9
VRTSfssdk:1334,3,0,0
VRTSgab:1751,382,0,80
VRTSglm:68,0,0,1035
VRTSgms:8,0,0,200
VRTSjboss:139,0,0,1
VRTSllt:3820,53,0,367
VRTSlvmconv:3,175,0,95
VRTSmq6:304,0,0,19
VRTSmysql:151,0,0,3
VRTSob:71837,0,0,206
VRTSodm:203,455,0,849
VRTSperl:72469,0,0,0
VRTSsapcms:159,0,0,5
VRTSsaplc:185,0,0,56
VRTSsapnw04:262,0,0,47
VRTSsapwebas71:249,0,0,29
SYMCsnascpi60:4842,0,0,0
VRTSsfmh:109396,0,0,0
VRTSspt:30036,0,0,0
VRTSvbs:55231,0,0,1
VRTSvcs:169596,7512,0,263
VRTSvcsag:86582,0,0,71
VRTSvcsdr:935,0,0,1
VRTSvcsea:10828,0,0,51
VRTSvcsvmw:14022,0,0,1
VRTSvcswas:162,0,0,28
VRTSvcswiz:11874,0,0,0
VRTSvlic:65,0,0,1189
VRTSvxfen:5453,48,0,707
VRTSvxfs:3472,23146,0,12858
VRTSvxvm:1793,53696,0,53843
VRTSwls:348,0,0,10
_PKGSPACE_
    return;
}

sub preinstall_sys {
    my ($rel,$sys) = @_;
    my ($rootpath,$conf,$modprobe_file);
    $rootpath=Cfg::opt('rootpath')||'';
    $modprobe_file="$rootpath/etc/modprobe.d/unsupported-modules";
    if ($sys->exists("$modprobe_file"))  {
        $conf=$sys->readfile("$modprobe_file");
        $conf=~s/\n[ \t]*allow_unsupported_modules.*\n/\nallow_unsupported_modules 1\n/;
    } else {
        $conf="allow_unsupported_modules 1\n";
    }

    $sys->writefile($conf,$modprobe_file);
    Msg::log('Changing /etc/modprod.d/unsupported-modules to allow unsupported modules');
    return;
}

package Rel::SNAS60::SLES11ppc64;
@Rel::SNAS60::SLES11ppc64::ISA = qw(Rel::SNAS60::Linux);

sub init_padv {
    my ($rel) = @_;
    #$rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SVS61 SFRAC61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS61 SFRAC61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS61 SFRAC61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS61 SFRAC61));

    $rel->{platvers}=[ qw(2.6.32-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:3105,211,0,15
VRTSaslapm:0,0,0,1722
VRTSatClient:29834,0,0,685
VRTSatServer:62713,0,29,1041
VRTScavf:748,86,0,0
VRTScps:39431,0,0,2
VRTSdbed:21857,0,0,0
VRTSfssdk:1689,3,0,0
VRTSgab:4069,443,0,119
VRTSglm:61,0,0,466
VRTSgms:9,0,0,1880
VRTSllt:3252,62,0,458
VRTSlvmconv:3,184,0,101
VRTSob:77473,0,0,227
VRTSodm:238,585,0,326
VRTSperl:60047,0,0,0
SYMCsnascpi60:3596,0,0,0
VRTSsfmh:67785,0,0,0
VRTSspt:5451,0,0,0
VRTSvcs:133856,7802,0,327
VRTSvcsag:3287,0,0,0
VRTSvcsdr:882,0,0,1
VRTSvcsea:1110,0,0,34
VRTSvlic:75,0,0,1477
VRTSvxfen:4436,67,0,794
VRTSvxfs:3681,24328,0,8037
VRTSvxvm:1650,53607,0,31039
_PKGSPACE_
    return;
}

sub preinstall_sys {
    my ($rel,$sys) = @_;
    my ($rootpath,$conf,$modprobe_file);
    $rootpath=Cfg::opt('rootpath')||'';
    $modprobe_file="$rootpath/etc/modprobe.d/unsupported-modules";
    if ($sys->exists("$modprobe_file"))  {
        $conf=$sys->readfile("$modprobe_file");
        $conf=~s/\n[ \t]*allow_unsupported_modules.*\n/\nallow_unsupported_modules 1\n/;
    } else {
        $conf="allow_unsupported_modules 1\n";
    }

    $sys->writefile($conf,$modprobe_file);
    Msg::log('Changing /etc/modprod.d/unsupported-modules to allow unsupported modules');
    return;
}


package Rel::SNAS60::SunOS;
@Rel::SNAS60::SunOS::ISA = qw(Rel::SNAS60::Common);

sub init_plat {
    my ($rel) = @_;

    $rel->{driververs}='6.1';

    $rel->{prods}=EDRu::arrdel($rel->{prods}, 'SFCFSRAC61');
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, 'VCS61') if ($rel->{oem});
    $rel->{upgradeprods} = [ qw(SFRAC61 SFCFSHA61 SFHA61 APPLICATIONHA61 SF61 VCS61 VM61 DMP61 FS61) ];

    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50)];
    $rel->{'commands_need_be_checked'}=[ qw(adddrv fstyp getconf hostid isainfo kstat ldd mdb ndd netstat nm nohup pkgadd pkgchk pkginfo pkgrm prtconf prtdiag rmdrv route swap) ];
    $rel->{'commands_need_be_checked_for_5.9'}=[ qw(patchadd patchrm showrev) ];
    $rel->{'commands_need_be_checked_for_5.10'}=[ qw(bootadm patchadd patchrm showrev zoneadm) ];
    $rel->{'commands_need_be_checked_for_patchupgrade'}=[ qw(gunzip) ];
    $rel->{'commands_need_be_checked_for_patchupgrade_5.10'}=[ qw(patchadd) ];

    return;
}

sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($script,$msg,$train_arch,$perm,$file,$web,$osupdatelevel,$perm_new,$cpic,$pkg_dir,$runlevel,$prod,$platvers);

    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return '' if (Cfg::opt('ignorechecks'));

    # Check the Solaris Kernel.
    # For 6.1,
    # Solaris 10/11 32 bit is not supported
    if ($sys->{kerbit} == 32) {
        $msg=Msg::new("$sys->{sys}: Solaris 32-bit is not supported. ");
        $sys->push_error($msg);
        $sys->set_value('stop_checks', 1);
        return '';
    }

    # Check the Solaris run-level.
    # Only run-level S, 2, 3 are supported.
    if (Cfg::opt(qw(install upgrade patchupgrade hotfixupgrade precheck uninstall))) {
        $runlevel=$sys->padv->runlevel_sys($sys);
        if ($runlevel && $runlevel !~ /[S23]/m) {
            $msg=Msg::new("$sys->{sys}: Current run-level $runlevel is not supported. Change the run-level to S, 2, or 3 and re-start the installation program");
            $sys->push_error($msg);
            $sys->set_value('stop_checks', 1);
            return '';
        }
    }

    # Check the Solaris Update version.
    # For 6.1,
    # Solaris 10 with Update 9 or later is supported(Revised for support 9, 10 and 11).
    if (Cfg::opt(qw(install upgrade patchupgrade hotfixupgrade precheck))) {
        $osupdatelevel=$sys->{osupdatelevel};
        if ($sys->{platvers} eq '5.10') {
            if ($osupdatelevel && $osupdatelevel < 9) {
                $platvers=join(',',@{$rel->{platreqs}});
                $msg=Msg::new("Solaris 10 Update $osupdatelevel is installed on $sys->{sys}. The following kernel release are recommended to install the product:\n$platvers");
                $sys->push_warning($msg);
            }
        } elsif ($sys->{platvers} eq '5.11') {
            if (!$osupdatelevel) {
                # if the system is Solaris 11 GA, suggest upgrading to Solaris 11 update 1.
                my $sru_level=$sys->padv->sru_version_sys($sys);
                $sys->set_value('sru_level', $sru_level);
                if ($sru_level == 0) {
                    $msg=Msg::new("Solaris 11 SRU 11.0.x.y.z found on $sys->{sys} is not supported. Upgrade the OS to Solaris 11 SRU 11.1.x.y.z in order to install this product.");
                } else {
                    $msg=Msg::new("Solaris 11 SRU $sru_level found on $sys->{sys} is not supported. Upgrade the OS to Solaris 11 SRU 11.1.x.y.z in order to install this product.");
                }
                $sys->push_error($msg);
                $sys->set_value('stop_checks', 1);
                return '';
            }
        }
    }

    #check permissions of /tmp directory.
    if (Cfg::opt(qw(install upgrade patchupgrade hotfixupgrade precheck))) {
        $perm=$sys->cmd('_cmd_ls -ld /tmp 2>/dev/null');
        unless ($perm=~/^drw[xstST]rw/mx) {
            if ($perm ne '') {
                $sys->cmd('_cmd_chmod a+w /tmp');
                $perm_new=$sys->cmd('_cmd_ls -ld /tmp');
                $perm=(split(/\s+/m, $perm))[0];
                $perm_new=(split(/\s+/m, $perm_new))[0];
                $msg=Msg::new("The /tmp directory on $sys->{sys} does not have write permission which will cause pkgadd command failure when installing packages. Installer has automatically changed the permission of /tmp from '$perm' to '$perm_new' on $sys->{sys}.");
                $sys->push_warning($msg);
            }
        }
    }

    # Check to exit the installation if the target node architecture
    # is not the same as that of the release train. The SunOS arch
    # that the release train supports can be found by the ARCH listed
    # in any of the pkg info files. If this does not match the arch of
    # target node, exit the installer.

    $sys->{zone}=$sys->padv->zone_sys($sys);
    $sys->set_value('zone', $sys->{zone});

    # installer should be running from global zone
    if ($sys->{zone} && $sys->{zone} ne 'global') {
        $script=EDR::get('script');
        $msg=Msg::new("$sys->{sys} is running in a local zone. $script only supports systems running in the global zone.");
        $sys->set_value('stop_checks', 1);
        $sys->push_error($msg);
        return '';
    }

    # make sure all zones with installed status are booted.
    # do not boot zones on alternative boot environment.
    # do not boot zones on Solaris11
    if (!Cfg::opt('rootpath') && $sys->{padv}=~/Sol10/ &&
        $sys->{zone} && Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade uninstall))) {
        my ($zone,$zones,@installed_zones,@failed_zones,@cpi_booted_zones);

        $zones=$sys->cmd('_cmd_zoneadm list -civ 2>/dev/null');
        for my $zone (split(/\n/,$zones)) {
            next if ($zone =~ /^\s*$/m);
            next if ($zone =~ /^\s*ID/m);
            if ($zone =~ /^\s*\S+\s+(\S+)\s+installed/mx) {
                next if ($1 eq 'global');
                push(@installed_zones, $1);
            }
        }

        for my $zone (@installed_zones) {
            $sys->cmd("_cmd_zoneadm -z $zone boot -s");
            if (EDR::cmdexit() != 0) {
                push(@failed_zones, $zone);
            } else {
                # if precheck/install/upgrade/patchupgrade/hotfixupgrade/uninstall, need halt the zones after jobs finished.
                push(@cpi_booted_zones, $zone);
            }
        }
        if (@failed_zones) {
            $zones=join("\n\t",@failed_zones);
            $msg=Msg::new("The following zones on system $sys->{sys} are not bootable, due to which packages may not be installed or removed successfully:\n\t$zones");
            $sys->push_error($msg);
        }

        if (@cpi_booted_zones) {
            $sys->set_value('cpi_booted_zones','list',@cpi_booted_zones);
        }
    }

    $cpic=Obj::cpic();
    # do not do this check if you are using /opt/VRTS scripts
    return 1 if ($cpic->{fromdisk});
    $prod=$sys->prod($cpic->{prod});
    $pkg_dir=$rel->pkgs_patches_dir('pkgpath');
    if ($pkg_dir && (-e "$pkg_dir/info")) {
        $file= "$pkg_dir/info/*";
        # Need to convert this to regex
        $train_arch=EDR::cmd_local("_cmd_grep ARCH $file | _cmd_sed -n '1p'");
        if ($train_arch && $train_arch!~/$sys->{arch}$/mx) {
            $msg=Msg::new("Cannot perform any task for $cpic->{prod} on system $sys->{sys} as its architecture is $sys->{arch}. This release supports $train_arch.");
            $sys->push_error($msg);
            return '';
        }
    }

    return 1;
}

sub revert_booted_zones_sys {
    my ($rel,$sys)=@_;

    return 1 if (!defined $sys->{cpi_booted_zones});

    for my $zone (@{$sys->{cpi_booted_zones}}) {
        $sys->cmd("_cmd_zoneadm -z $zone halt");
    }
    undef $sys->{cpi_booted_zones};

    return 1;
}

sub post_platvers {
    my $rel=shift;
    my ($systems,$edr);

    $edr=Obj::edr();
    $systems=CPIC::get('systems');
    for my $sys (@$systems) {
        next if (! defined $sys->{cpi_booted_zones});

        # register the sub to be called when Ctrl+C is typed.
        $edr->register_cleanup_task(\&Rel::SNAS60::SunOS::revert_booted_zones_sys, $rel, $sys);
    }
    return 1;
}

sub completion {
    my $rel=shift;
    my ($rootpath,$syslist);

    return unless (Cfg::opt(qw(precheck install upgrade patchupgrade hotfixupgrade uninstall configure)));

    $rootpath=Cfg::opt('rootpath');
    $rootpath=($rootpath) ? "-R $rootpath" : '';

    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        $rel->revert_booted_zones_sys($sys);

        $sys->cmd("_cmd_bootadm update-archive $rootpath 2>/dev/null") if ($sys->{need_update_archive});
    }

    $rel->SUPER::completion();
    return;
}

# SunOS
sub new_pkg_init_plat {
    my ($rel,$pkg) = @_;
    push(@{$pkg->{softdeps}}, 'VRTSccsta', 'VRTShalR')
        if (EDRu::inarr($pkg->{pkg},qw/VRTSpbx VRTSicsco VRTSjre15 VRTSjre/));
    push(@{$pkg->{softdeps}}, 'VRTSccsta', 'VRTSccsts')
        if ($pkg->{pkg} eq 'VRTSobc33');
    push(@{$pkg->{softdeps}}, 'VRTSccer', 'VRTSccsts')
        if (EDRu::inarr($pkg->{pkg},qw/VRTSat VRTSjre15 VRTSweb VRTSperl VRTSvlic VRTSsmweb VRTSjre/));
    $pkg->{force_uninstall}=1 if ($pkg->{pkg} eq 'SYMClma' and Cfg::opt('rootpath'));
    $pkg->{force_uninstall}=1 if ($pkg->{pkg} eq 'VRTSmuddl' and $rel->{lp});

    if ($pkg->{pkg} eq 'VRTSvcssy') {
        no strict 'refs';
        no warnings 'redefine';
        # define new preremove_sys
        my $pkg_preremove_method="Pkg\::$pkg->{pkg}\::$pkg->{padv}\::preremove_sys";
        *{$pkg_preremove_method} = sub {
            my ($pkg1,$sys1)= @_;
            my ($rootpath,$vers);
            $rootpath=Cfg::opt('rootpath')||'';
            $vers = $pkg1->version_sys($sys1);
            # Remove VRTSvcssy preremove scripts on ABE during Live Upgrade.
            if (Cfg::opt('upgrade') && $rootpath
                && (EDRu::compvers($vers,'6.0')==2)) {
                $sys1->rm("$rootpath/var/sadm/pkg/$pkg1->{pkg}/install/preremove");
            }
            return;
        };
    }
    return;
}

sub pkg_mpversion_sys {
    my ($rel,$sys,$pkg,$force_flag) = @_;
    my ($pstamps,$mpvers,$pkgvers,$pstamp);

    $pstamp = $sys->padv->pkginfovalue_sys($sys, 'PSTAMP', $pkg);
    chomp($pstamp);
    $pstamp = EDRu::despace($pstamp);
    return '' if (!$pstamp);

    $pstamps = {'5.0' => {"5\\.0\\.3" => '5.0.3', 'MP3' => '5.0.3',
                          "5\\.0\\.1" => '5.0.1', 'MP1' => '5.0.1'},
                '4.1' => {"4\\.1\\.2" => '4.1.2', 'MP2' => '4.1.2'}};
    $pkgvers = $pkg->version_sys($sys,$force_flag);
    # since 5.1RP1, the pstamp format comply with certain rule
    # eg: for 5.1RP1 PSTAMP=5.1.001.000-5.1RP1-yyyy-mm-dd
    if (EDRu::compvers($pkgvers,'5.1') != 2 ) {
        # 5.1 doesn't comply with the rule.
        # $pkgvers changes from '5.1' to '6.0.000.000'
        $pkgvers =~ s/^(\d+\.\d+).*/$1/;
        return $pkgvers if ($pstamp !~ /^$pkgvers\.\d+\.\d+/mx);
        $mpvers = $pstamp;
        $mpvers =~ s/-.*//mg;
        return $mpvers;
    }
    # pkg's own pstamps mapping
    for my $mpvers (keys(%{$pkg->{pstamps}->{"$pkgvers"}})) {
        if($pstamp =~ /$mpvers/mi){
            return $pkg->{pstamps}->{"$pkgvers"}{"$mpvers"};
        }
    }
    # general pstamps mapping
    for my $mpvers (keys(%{$pstamps->{"$pkgvers"}})) {
        if($pstamp =~ /$mpvers/mi){
            return $pstamps->{"$pkgvers"}{"$mpvers"};
        }
    }
    return '';
}

sub get_tunable_value_sys{
    my ($rel,$sys,$tunable) =@_;
    my ($origval);
    $origval = $sys->cmd("_cmd_grep '^set $tunable=' /etc/system 2>/dev/null |_cmd_tail -1");
    if ( $origval ) {
        chomp $origval;
        $origval =~ s/^set $tunable=//;
    }
    return $origval;
}

sub set_tunable_value_sys{
    my ($rel,$sys,$tunable,$value) =@_;
    my ($cpic, $file, @lines, @newlines, $tunable_info);
    $cpic= Obj::cpic();
    if ($sys->exists('/etc/system')) {
        $file = $sys->readfile('/etc/system');
        @lines = split (/\n/,$file);
        @newlines = ();
        for my $line (@lines) {
            if ($line !~ /^set $tunable=/ ) {
                push @newlines, $line;
            }
        }
        $file = join("\n", @newlines);
    } else {
        $file = '';
    }
    $sys->writefile($file, '/etc/system');

    $tunable_info=$cpic->get_tunable_info($tunable);
    if ($value != 0 || !$tunable_info->{zero_to_reset}) {
        $sys->appendfile("\nset $tunable=$value\n", '/etc/system');
    }
    $file = $sys->readfile('/etc/system');
    return (0,$file);
}

sub preremove_sys {
    my ($rel,$sys) = @_;

    # need run 'bootadm update-archive' when complete installation
    $sys->set_value('need_update_archive',1);

    return 1;
}

sub preinstall_sys {
    my ($rel,$rootpath,$sys);
    ($rel,$sys) = (@_);
    $rootpath=Cfg::opt('rootpath')||'';
    if (($rootpath) && ($sys->exists("$rootpath/tmp/AdDrEm.lck"))) {
        $sys->rm("$rootpath/tmp/AdDrEm.lck");
    }

    # need run 'bootadm update-archive' when complete installation
    $sys->set_value('need_update_archive',1);

    return;
}

package Rel::SNAS60::SolSparc;
@Rel::SNAS60::SolSparc::ISA = qw(Rel::SNAS60::SunOS);

sub init_padv {
    my ($rel) = @_;

    # Add LP
    my $mediapath=EDR::get('mediapath');
    if (-d "$mediapath/docs/ja") {
        $rel->{lp}=1;
        $rel->{verify_media}=0; # do not check release layout
        push(@{$rel->{prods}}, 'LP61');
    }

    $rel->{upgradeprods} = [ qw(SFRAC61 SFSYBASECE61 SFCFSHA61 SFHA61 APPLICATIONHA61 SF61 VCS61 VM61 DMP61 FS61) ];
    # List LP pkgs to uninstall
    $rel->{langpkgs}=[  qw(SYMCjalma SYMCzhlma VRTSatJA VRTSatZH VRTSjaap
                           VRTSjacav60 VRTSjacfd VRTSjacmc VRTSjacs60 VRTSjacsb
                           VRTSjacsd VRTSjacse60 VRTSjacsi VRTSjacsj VRTSjacsm
                           VRTSjacso VRTSjacsp VRTSjacss VRTSjacsu60 VRTSjacsw
                           VRTSjad2d VRTSjad2g VRTSjadb2 VRTSjadba60 VRTSjadbc
                           VRTSjadbd VRTSjadbe60 VRTSjadcm VRTSjafad VRTSjafag
                           VRTSjafas VRTSjafs60 VRTSjafsc VRTSjafsd VRTSjafsm
                           VRTSjagap VRTSjaico VRTSjamcm VRTSjampr VRTSjamsa
                           VRTSjaodm61 VRTSjaord VRTSjaorg VRTSjaorm VRTSjapbx
                           VRTSjasmf VRTSjaspq VRTSjasqd VRTSjasqm VRTSjavm60
                           VRTSjavmc VRTSjavmd VRTSjavmm VRTSjavrd VRTSjavvr
                           VRTSjaweb VRTSmualc VRTSmuap  VRTSmuc33 VRTSmucsd
                           VRTSmudcp VRTSmuddl VRTSmufp  VRTSmufsp VRTSmufsw
                           VRTSmulic32 VRTSmuob VRTSmuobg VRTSmuobw VRTSmusfm
                           VRTSmutep VRTSmuvmp VRTSmuvmw VRTSzhico VRTSzhpbx
                           VRTSzhsmf VRTSzhvm60 VRTSzhvmc VRTSzhvmd VRTSzhvmm) ];

    $rel->{platvers}=[ qw(5.10) ];
    my $msg = Msg::new("Solaris 10 Update 9, 10, 11 (64-bit only)");
    $rel->{platreqs}=[ $msg->{msg} ];
    $rel->{upgradevers}=[ qw(5.0.3 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSacclib:504,0,0,0
VRTSamf:411,1582,3,8
VRTSaslapm:0,525,0,1379
VRTScavf:772,66,0,2
VRTScps:28050,0,0,2
VRTSdbac:1911,82,5,2959
VRTSdbed:128421,0,2,5
VRTSfsadv:15972,0,3,2
VRTSfssdk:2217,0,0,0
VRTSgab:140,544,3,1118
VRTSglm:43,0,0,514
VRTSgms:1,0,0,105
VRTSllt:503,77,3,1085
VRTSob:91159,0,0,205
VRTSodm:1391,1,3,3
VRTSperl:99858,0,0,0
SYMCsnascpi60:7132,0,0,0
VRTSsfmh:127489,0,0,0
VRTSspt:22679,0,0,0
VRTSvbs:60061,0,0,1
VRTSvcs:231138,13045,0,251
VRTSvcsag:6439,1,0,60
VRTSvcsea:18333,0,0,76
VRTSvcsvmw:13358,0,0,1
VRTSvcswiz:6994,0,0,0
VRTSvlic:2852,0,0,2669
VRTSvxfen:330,186,3,2330
VRTSvxfs:43885,5549,4,5947
VRTSvxvm:7175,187182,20,32218
_PKGSPACE_
    return;
}

package Rel::SNAS60::Solx64;
@Rel::SNAS60::Solx64::ISA = qw(Rel::SNAS60::SunOS);

sub init_padv {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(5.10) ];
    my $msg = Msg::new("Solaris 10 Update 8, 9, 10 (64-bit only)");
    $rel->{platreqs}=[ $msg->{msg} ];
    $rel->{upgradevers}=[ qw(5.0.3 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFSYBASECE61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, 'SFSYBASECE61');
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE61));
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:416,1303,3,8
VRTSaslapm:0,1252,0,2009
VRTScavf:779,66,0,2
VRTScps:35421,0,0,2
VRTSdbac:2002,87,5,2510
VRTSdbed:134314,0,2,5
VRTSfssdk:2170,0,0,0
VRTSgab:144,554,3,1088
VRTSglm:40,0,0,531
VRTSgms:1,0,0,103
VRTSllt:541,78,3,986
VRTSob:81624,0,0,196
VRTSodm:1240,1,3,3
VRTSperl:98236,0,0,0
SYMCsnascpi60:4842,0,0,0
VRTSsfmh:119579,0,0,0
VRTSspt:20381,0,0,0
VRTSsvs:158265,0,0,0
VRTSvbs:98551,0,0,1
VRTSvcs:248607,13829,0,251
VRTSvcsag:6747,1,0,60
VRTSvcsea:22083,0,0,76
VRTSvlic:1295,0,0,1340
VRTSvxfen:327,169,3,2231
VRTSvxfs:36537,4871,4,5775
VRTSvxvm:6428,184795,20,40919
_PKGSPACE_
    return;
}

package Rel::SNAS60::Sol11sparc;
@Rel::SNAS60::Sol11sparc::ISA = qw(Rel::SNAS60::SunOS);

sub init_padv {
    my ($rel) = @_;

    # Add LP
    my $mediapath=EDR::get('mediapath');
    if (-d "$mediapath/docs/ja") {
        $rel->{lp}=1;
        $rel->{verify_media}=0; # do not check release layout
        push(@{$rel->{prods}}, 'LP61');
    }

    $rel->{batchuninstall}=1;
    $rel->{inplaceupgrade}=1;

    # List LP pkgs to uninstall
    $rel->{langpkgs}=[  qw(VRTSjacav60 VRTSjacs60 VRTSjacse60 VRTSjadba60
                           VRTSjadbe60 VRTSjafs60 VRTSjaodm61 VRTSjavm60
                           VRTSzhvm60 VRTSmulic32) ];

    $rel->{platvers}=[ qw(5.11) ];
    my $msg = Msg::new("Solaris 11 Update 1 (64-bit only)");
    $rel->{platreqs}=[ $msg->{msg} ];
    $rel->{upgradevers}=[ qw(6.0.10) ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:321,2440,3,7
VRTSaslapm:0,553,0,1341
VRTScavf:742,66,0,2
VRTScps:27779,0,0,2
VRTSdbac:2440,117,5,3020
VRTSdbed:45420,0,2,3
VRTSfsadv:14228,0,0,0
VRTSfssdk:2158,0,0,0
VRTSgab:141,543,3,1115
VRTSglm:43,0,0,515
VRTSgms:1,0,0,105
VRTSllt:535,76,3,1078
VRTSodm:1384,1,3,3
VRTSperl:106816,0,0,0
SYMCsnascpi60:7064,0,0,0
VRTSsfmh:95422,0,0,0
VRTSspt:21986,0,0,0
VRTSvbs:54228,0,0,3
VRTSvcs:174185,7081,5,228
VRTSvcsag:4006,0,0,58
VRTSvcsea:18297,0,0,71
VRTSvcswiz,7014,0,0,0
VRTSvlic:2852,0,0,2672
VRTSvxfen:320,177,3,2269
VRTSvxfs:40333,5366,4,5604
VRTSvxvm:6714,164020,20,28861
_PKGSPACE_
    return;
}

sub preremove_sys {
    my ($rel,$sys) = @_;
    my ($rootpath,$files);

    # To fix issue that uninstalling VRTSvlic hang due to some special pipe files on Solaris 11 GA
    if (!$sys->{osupdatelevel} && !$sys->{sru_level}) {
        # if on Solaris 11 GA
        $files='';
        $rootpath=Cfg::opt('rootpath')||'';
        if (EDRu::inarr('VRTSvlic32', @{$sys->{uninstallpkgs}})) {
            $files.=" $rootpath/etc/vx/vold_*";
        }
        if (EDRu::inarr('VRTSvxvm61', @{$sys->{uninstallpkgs}})) {
            $files.=" $rootpath/etc/vx/vxesd";
        }

        $sys->cmd("_cmd_rm -rf $files 2>/dev/null") if ($files);
    }

    # need run 'bootadm update-archive' when complete installation
    $sys->set_value('need_update_archive',1);

    return 1;
}

package Rel::SNAS60::Sol11x64;
@Rel::SNAS60::Sol11x64::ISA = qw(Rel::SNAS60::Sol11sparc);

sub init_padv {
    my ($rel) = @_;

    $rel->{batchuninstall}=1;
    $rel->{inplaceupgrade}=1;

    $rel->{platvers}=[ qw(5.11) ];
    my $msg = Msg::new("Solaris 11 Update 1 (64-bit only)");
    $rel->{platreqs}=[ $msg->{msg} ];
    $rel->{upgradevers}=[ qw(6.0.10) ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SFSYBASECE61 APPLICATIONHA61));
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:321,2031,3,7
VRTSaslapm:0,1228,0,1926
VRTSat:79534,0,29,1307
VRTScavf:749,66,0,2
VRTScps:35270,0,0,2
VRTSdbac:2422,84,5,2536
VRTSdbed:45743,0,2,3
VRTSfssdk:2112,0,0,0
VRTSgab:145,553,3,1083
VRTSglm:40,0,0,531
VRTSgms:1,0,0,103
VRTSllt:577,77,3,979
VRTSob:83165,0,0,196
VRTSodm:1231,1,3,3
VRTSperl:105965,0,0,0
SYMCsnascpi60:4444,0,0,0
VRTSsfmh:104631,0,0,0
VRTSspt:19708,0,0,0
VRTSsvs:156788,0,0,0
VRTSvbs:83797,0,0,3
VRTSvcs:267464,13691,5,228
VRTSvcsag:6451,0,0,58
VRTSvcsea:22487,0,0,71
VRTSvlic:1295,0,0,1343
VRTSvxfen:317,160,3,2170
VRTSvxfs:33103,4698,4,5442
VRTSvxvm:6136,175199,20,38354
_PKGSPACE_
    return;
}

1;