use strict;

package Rel::UXRT60::Common;
@Rel::UXRT60::Common::ISA = qw(Rel);

sub init_common {
    my ($rel) = @_;
    my $mediapath;

    $rel->{verify_media}=1; # comment out once release layout is stable
    $rel->{reli}='UXRT';
    $rel->{reltitle}=Msg::new("Storage Foundation and High Availability Solutions")->{msg};
    $rel->{vers}='6.0.000.0';
    $rel->{basevers}='6.0';
    $rel->{gavers}='6.0';
    $rel->{titlevers}='6.0';
    $rel->{nopatches}=1;

    $rel->{build_state}='_BUILD_STATE_';
    $rel->{build_sprint}='_BUILD_SPRINT_';
    $rel->{build_date}='_BUILD_DATE_';

    $rel->{sort_upload_config_url}='https://telemetrics.symantec.com/data/uploader/uxrt60upload.conf';

    $rel->{prods}=[ qw(FS60 DMP60 VM60 VCS60 SF60 SFHA60 SFCFSHA60 SFCFSRAC60 SVS60 SFSYBASECE60 SFRAC60) ];
    $rel->{pkgsetprods}=[ qw(SFRAC60 SFSYBASECE60 SVS60 SFCFSHA60 SFHA60 SF60 VCS60 DMP60) ];
    #$rel->{menuprods}=EDRu::arrdel($rel->{prods}, qw(FS60 VM60 SFCFSRAC60));
    $rel->{menuprods}=[ qw(DMP60 VCS60 SF60 SFHA60 SFCFSHA60 SVS60 SFSYBASECE60 SFRAC60) ];
    $rel->{upgradeprods} = [ qw(SFRAC60 SFSYBASECE60 SFCFSHA60 SFHA60 SF60 VCS60 VM60 DMP60 FS60) ];
    $rel->{allpkgs}=[ qw(VRTSvlic32 VRTSperl512 VRTSsfcpi60 VRTSspt60) ];
    $rel->{minpkgs}=[ qw(VRTSvlic32 VRTSperl512 VRTSsfcpi60) ];
    $rel->{recpkgs}=[ qw(VRTSvlic32 VRTSperl512 VRTSsfcpi60 VRTSspt60) ];
    $rel->{cpipkg}='VRTSsfcpi60';

    $rel->{ru_prod}=[ qw(SFRAC60 SVS60 SFCFSHA60 SFHA60 VCS60) ];
    $rel->{ru_unkernelpkgs}=[ qw(VRTSvcs60 VRTSvcsag60 VRTSvcsea60 VRTScavf60) ];
    $rel->{ru_noupgrademsg_prod}=[ qw(SFRAC) ];
    $rel->{ru_version}='5.1';
    $rel->{bucket_version}='5.1';
    $rel->{pkgset_version}='5.1';

    $rel->{installonupgradepkgs}=[ qw(VRTSsfcpi60) ];

    $rel->{obsolete_scripts} = [qw( installfs       uninstallfs
                                    installvm       uninstallvm
                                    installsfora    uninstallsfora
                                    installsfsyb    uninstallsfsyb
                                    installsfcfs    uninstallsfcfs
                                    installsfdb2    uninstallsfdb2)];
    $mediapath=EDR::get('mediapath');
    if(-d "$mediapath/storage_foundation_basic") {
        $rel->{menuprods}=[ qw(SF60) ];
        $rel->{verify_media}=0; # do not check release layout
    }
    $rel->{oem}=1 if ((-f "$mediapath/.oem")
                      || (-f "$mediapath/../.oem")
                      || (EDRu::inarr('-oem',@ARGV)));
    $rel->{oem}='' if (EDRu::inarr('-nooem',@ARGV));

    $rel->{cross_upgradable_matrix}= {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => [],
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
    };
    $rel->{partial_upgradable_matrix}= {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => [],
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
    };
    $rel->{independent_prod_matrix} = {
        'SFRAC' => [],
        'SFCFSRAC' => [],
        'SVS' => [],
        'SFCFSHA' => [],
        'SFCFS' => [],
        'SFHA' => [],
        'SF' => ['VCS'],
        'VCS' => ['SF','VM','DMP','FS'],
        'VM' => ['VCS','FS'],
        'DMP' => ['VCS','FS'],
        'FS' => ['VCS','VM','DMP'],
        'AT' => [],
        'SFSYBASECE' => [],
    };
    return;
}

sub init_args {
    my $rel = shift;
    my ($arguments,$arg_def,$pdfrs,$plat);
    $pdfrs=Msg::get('pdfrs');

    $rel->{arguments} = $arguments = {
        # args_def: [ qw(jumpstart flash_archive kickstart nim) ],
        'args_def' => [ ],

        'args_opt' => [ qw(security securityonenode securitytrust addnode fencing
                           vxunroot upgrade_kernelpkgs upgrade_nonkernelpkgs
                           rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2) ],

        # Those arguments have no specific entry here are considered as undocumented arguments.
        # Those arguments have specific entry here but without 'description' attribute are considered as undocumented arguments.
        # Those arguments have specific entry here and with 'undocumented' attribute are considered as undocumented arguments.

        # UXRT60 definition args
        'jumpstart' => {
            'option_description' => Msg::new("<jumpstart_path>"),
            'description' => Msg::new("The -jumpstart option is used to generate finish scripts which can be used by Solaris Jumpstart Server for automated installation of all $pdfrs and patches for every product, an available location to store the finish scripts should be specified as a complete path. The -jumpstart option is supported on Solaris only."),
            'handler' => \&Rel::UXRT60::Common::process_jumpstart_arg,
        },
        'flash_archive' => {
            'option_description' => Msg::new("<flash_archive_path>"),
            'description' => Msg::new("The -flash_archive option is used to generate Flash archive scripts which can be used by Solaris Jumpstart Server for automated Flash archive installation of all $pdfrs and patches for every product, an available location to store the post deployment scripts should be specified as a complete path. The -flash_archive option is supported on Solaris only."),
            'handler' => \&Rel::UXRT60::Common::process_flash_archive_arg,
        },
        'kickstart' => {
            'option_description' => Msg::new("<kickstart_path>"),
            'description' => Msg::new("The -kickstart option is used to generate kickstart scripts which can be used by Redhat Linux Kickstart for automated installation of all $pdfrs for every product, an available location to store the kickstart scripts should be specified as a complete path. The -kickstart option is supported on Redhat Linux only."),
            'handler' => \&Rel::UXRT60::Common::process_kickstart_arg,
        },
        'yumgroupxml' => {
            'option_description' => Msg::new("<yum_group_xml_path>"),
            'description' => Msg::new("The -yumgroupxml option is used to generate a yum group definition XML file which can be used by createrepo command on Redhat Linux to create yum group for automated installation of all $pdfrs for a product. An available location to store the XML file should be specified as a complete path. The -yumgroupxml option is supported on Redhat Linux only."),
            'handler' => \&Rel::UXRT60::Common::process_yumgroupxml_arg,
        },
        'nim' => {
            'option_description' => Msg::new("<LPP_SOURCE>"),
            'description' => Msg::new("The -nim option is used to generate an installp_bundle which is used by an AIX NIM Server for automated installation of all $pdfrs and patches for every product. An available LPP_SOURCE directory must also be specified. The -nim option is supported on AIX only."),
            'handler' => \&Rel::UXRT60::Common::process_nim_arg,
        },

        # UXRT60 option args
        'ignite' => {
            'description' => Msg::new("The -ignite option is used to generate a product bundle which is used by an HPUX Ignite Server for automated installation of all $pdfrs and patches for every product. The -ignite option is supported on HPUX only."),
            'handler' => \&Rel::UXRT60::Common::process_ignite_arg,
        },

        'security' => {
            'description' => Msg::new("The -security option is used to convert a running VCS cluster between secure and non-secure modes of operation"),
            'handler' => \&Rel::UXRT60::Common::process_security_arg,
        },
        'securityonenode' => {
            'description' => Msg::new("The -securityonenode option is used to configure a secure cluster node by node."),
            'handler' => \&Rel::UXRT60::Common::process_security_arg,
        },
        'securitytrust' => {
            'description' => Msg::new("The -securitytrust option is used to setup trust with another broker."),
            'handler' => \&Rel::UXRT60::Common::process_security_arg,
        },
        'fencing' => {
            'description' => Msg::new("The -fencing option is used to configure I/O fencing in a running cluster"),
            'handler' => \&Rel::UXRT60::Common::process_fencing_arg,
        },
        'addnode' => {
            'description' => Msg::new("The -addnode option is used to add a node to a running cluster"),
            'handler' => \&Rel::UXRT60::Common::process_addnode_arg,
        },
        'upgrade_kernelpkgs' => {
            'description' => Msg::new("The -upgrade_kernelpkgs option has been renamed to -rollingupgrade_phase1"),
            'handler' => \&Rel::UXRT60::Common::process_ru_arg,
        },
        'upgrade_nonkernelpkgs' => {
            'description' => Msg::new("The -upgrade_nonkernelpkgs option has been renamed to -rollingupgrade_phase2"),
            'handler' => \&Rel::UXRT60::Common::process_ru_arg,
        },
        'rolling_upgrade' => {
            'description' => Msg::new("The -rolling_upgrade option is used to perform rolling upgrade. Using this option, installer will detect the rolling upgrade status on cluster systems automatically without the need to specify rolling upgrade phase 1 or phase 2 explicitly."),
            'handler' => \&Rel::UXRT60::Common::process_ru_arg,
        },
        'rollingupgrade_phase1' => {
            'description' => Msg::new("The -rollingupgrade_phase1 option is used to perform rolling upgrade phase 1. During this phase, the product kernel $pdfrs will be upgraded to the latest version"),
            'handler' => \&Rel::UXRT60::Common::process_ru_arg,
        },
        'rollingupgrade_phase2' => {
            'description' => Msg::new("The -rollingupgrade_phase2 option is used to perform rolling upgrade phase 2. During this phase, VCS and other agent $pdfrs will be upgraded to the latest version. During this phase, product kernel drivers will be rolling-upgraded to the latest protocol version."),
            'handler' => \&Rel::UXRT60::Common::process_ru_arg,
        },
    };

    # Pass $rel as handler argument.
    for my $arg (keys %{$arguments}) {
        $arg_def=$arguments->{$arg};
        next unless (ref($arg_def) eq 'HASH' &&
                     defined $arg_def->{handler} &&
                     !defined $arg_def->{handler_args});
        $arg_def->{handler_args} = [ $rel ];
    }

    # Add args which depend on platforms
    $plat=Padv::plat($rel->{padv});
    if ($plat eq 'SunOS') {
        push @{$arguments->{args_def}}, qw(jumpstart flash_archive);
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
    my ($cpic,$script,@vcs_args);

    @vcs_args = qw(security securityonenode securitytrust addnode fencing
                   upgrade_kernelpkgs upgrade_nonkernelpkgs
                   rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2);

    if ($prod) {
        if (!$rel->has_vcs($prod)) {
            # remove VCS arguments for non-VCS products.
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
        }
    } else {
        $cpic=Obj::cpic();
        $script=$cpic->{script};
        if ($script eq 'installer') {
            # need keep Rolling_upgrade related arguments for installer script.
            @vcs_args = qw(security securityonenode securitytrust addnode fencing);
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
        } elsif ($script eq 'install_lp') {
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @{$rel->{arguments}->{args_opt}});
        } elsif ($script=~/install(sf|fs|vm|dmp)$/m) {
            # remove VCS arguments for installer script.
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, @vcs_args);
        }

        if ($cpic->{fromdisk}) {
            # remove install/upgrade related options if run installer script from /opt/VRTS/install
            $args_hash->{args_task}=EDRu::arrdel($args_hash->{args_task}, qw(install upgrade));
            $args_hash->{args_opt}=EDRu::arrdel($args_hash->{args_opt}, qw(upgrade_kernelpkgs upgrade_nonkernelpkgs rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2));
        }
    }
    return 1;
}

sub has_vcs {
    my ($rel,$prod)=@_;
    $prod=~s/\d+$//;
    return 0 if (EDRu::inarr($prod, qw(FS DMP VM SF)));
    return 1;
}

sub has_vm {
    my ($rel,$prod)=@_;
    $prod=~s/\d+$//;
    return 0 if (EDRu::inarr($prod, qw(FS VCS)));
    return 1;
}

sub process_security_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    for my $opt (qw(security securityonenode securitytrust)) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
        }
        if (Cfg::opt($opt)) {
            if ($opt_cnt>1) {
                $msg=Msg::new("The $opt option cannot be used with other options");
                $msg->die();
            } elsif ($cpic->{task} ne 'configure') {
                $cpic->set_task('configure');
            }
            if (!$rel->has_vcs($prod)) {
                $msg=Msg::new("The $opt option cannot be used with this product");
                $msg->die();
            }
        }
    }
    if (Cfg::opt('securityonenode') && $cfg->{systems}) {
        $msg=Msg::new("The securityonenode option can only be used with the local system.");
        $msg->die();
    }
    return 0;
}

sub process_fencing_arg {
    my ($rel,$args_hash) = @_;
    my ($msg,$cfg,$cpic,$prod,$opt_cnt);
    $cfg = Obj::cfg();
    $cpic = Obj::cpic();
    $prod = $cpic->{prod};
    if (Cfg::opt('fencing')) {
        $opt_cnt=0;
        if (defined $args_hash->{options}) {
            $opt_cnt=scalar @{$args_hash->{options}};
        }
        if ($opt_cnt>1) {
            $msg=Msg::new("The fencing option cannot be used with other options");
            $msg->die();
        } elsif ($cpic->{task} ne 'configure') {
            $cpic->set_task('configure');
        }
        if (!$rel->has_vcs($prod)) {
            $msg=Msg::new("The fencing option cannot be used with this product");
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
    if(Cfg::opt("upgrade_kernelpkgs")){
        $msg=Msg::new("The -upgrade_kernelpkgs has been renamed to -rollingupgrade_phase1");
        $msg->die();

    } elsif(Cfg::opt("upgrade_nonkernelpkgs")){
        $msg=Msg::new("The -upgrade_nonkernelpkgs has been renamed to -rollingupgrade_phase2");
        $msg->die();
    }

    for my $opt (qw(upgrade_kernelpkgs upgrade_nonkernelpkgs rolling_upgrade rollingupgrade_phase1 rollingupgrade_phase2)) {
        next unless (Cfg::opt($opt));
        $ru_opt_cnt-- if(Cfg::opt('upgrade'));
        $ru_opt_cnt-- if(Cfg::opt('serial'));
        if ($ru_opt_cnt>1) {
            $msg=Msg::new("The $opt option can be only used with upgrade and serial option");
            $msg->die();
        }
        Cfg::set_opt("upgrade_kernelpkgs") if(Cfg::opt("rollingupgrade_phase1"));
        Cfg::set_opt("upgrade_nonkernelpkgs") if(Cfg::opt("rollingupgrade_phase2"));
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
    my ($cpic,$installscript,$msg,$prod,$web,$padv);

    $cpic=Obj::cpic();
    return unless ($cpic->{prod});
    $prod=$cpic->prod;

    # skip configure message if LP or MLP
    return '' if (Cfg::opt(qw(upgrade)) &&
                  $prod->{lp} || $prod->disableconfig());
    return unless ($prod->can(CPIC::upgrade_sub('configure_sys')));
    if ((Cfg::opt(qw(install))) && (!Cfg::opt('configure'))) {
        $installscript= 'install' . lc($prod->{installscript_name} || $prod->{prod});
        if (Cfg::opt('rootpath')) {
            $msg=Msg::new("$prod->{name} cannot be started without configuration.\n\nRun the '/opt/VRTS/install/$installscript -configure' command after boot from the alternate root disk.\n");
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
        if ($sys->{encap} && Cfg::opt(qw/upgrade patchupgrade/)) {
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
    }
    $systems=join("\n\t", @{$cpic->{reboot_systems}});
    $padv=Obj::padv($cpic->{padv});
    $msg=Msg::new("It is strongly recommended to reboot the following systems:\n\t$systems\n\nExecute '$padv->{cmd}{shutdown}' to properly restart your systems");
    $reboot_msg.=$msg->{msg};
    if (Cfg::opt(qw(configure upgrade))) {
        if (defined($cpic->{require_start_after_reboot_systems})
            && (@{$cpic->{require_start_after_reboot_systems}})) {
            $systems=join(' ', @{$cpic->{require_start_after_reboot_systems}});
            $installscript= 'install' . lc($prod->{installscript_name} || $prod->{prod});
            $msg=Msg::new("\n\nAfter reboot, run the '/opt/VRTS/install/$installscript -start $systems' command to start $prod->{name}");
            $reboot_msg.=$msg->{msg};
        }
    }
    if (Cfg::opt(qw(upgrade patchupgrade))) {
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
                $installscript= 'install' . lc($prod->{installscript_name} || $prod->{prod});
                $msg=Msg::new("\n\nAfter reboot, run the '/opt/VRTS/install/$installscript -start $systems' command to start $prod->{name}");
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
        $patchupgrade_flag,$obsoleted_product_upgrade_flag,
        $upgrade_status,$index,$lprod,$prodobj,$cprod_installed,$upgrade_from_vers);

    $cfg=Obj::cfg();
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $relvers=$rel->{basevers};
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

    # only check prod mix status for precheck/install/upgrade/patchupgrade
    return '' unless (Cfg::opt(qw(precheck install upgrade patchupgrade)));

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

        $index=EDRu::arrpos($cprod,@{$sys->{upgradeprod}});
        $cprod_installed=1 if ($index>=0);
        $index= ($index>=0) ? $index : 0;
        $prodname=$sys->{upgradeprod}[$index];
        if ($prodname) {
            $prodobj=$sys->prod($prodname);
            $cmpvers=$prodobj->{vers};
            $task_set = $nocurrentvers_flag = $rel->upgrade_sfha_check_sys($sys,$prodobj,$index);
            $nocurrentvers_flag = 1 if (EDRu::compvers(${$sys->{prodvers}}[$index],$cmpvers,4));
            if ($nocurrentvers_flag) {
                $upgrade_from_vers = $sys->{lower_vers} || ${$sys->{prodvers}}[$index];
                $patchupgrade_flag=1 if (!EDRu::compvers($upgrade_from_vers,$cmpvers,2));
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
            $prod_value_join="$upgrade_prod".' '."${$sys->{prodvers}}[0]";
            $msg = Msg::new("$prod_value_join is installed on $sys->{hostname}. $cprod_name is a subset of $upgrade_prod. Upgrading only $cprod_name will partially upgrade the installed packages on the systems.\n$sys_prod_map\nRun 'installer -upgrade' for a complete upgrade.");
            $sys->push_warning($msg);
            $sys->set_value('partial_upgrade', 1);
        }
    }

    # Set upgradeprod for upsell install.
    unless ($prodmix_flag) {
        $cpic->set_value('upgradeprod',$prev_prod);
    }

    if ( $nocurrentvers_flag && !Cfg::opt('upgrade') && ($upgrade_status ne 'cross_install') && $cprod_installed) {
        # here we unset install and set upgrade if we detect it's upgrade instead of install
        # if latest version is installed and we are installing extra pkgs only then it isn't considered upgrade
        if (Cfg::opt('install')) {
            $cpic->set_task('upgrade');
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
    $prod->set_pkgs() if (Cfg::opt(qw(upgrade patchupgrade)) && ($cpic->{prod}));
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

    return $task_set ? '1' : '';
}

sub upgrade_sfha_check_sys {
    my ($rel,$sys,$prod,$index)=@_;
    my($msg,$cmpvers,$sfvers,$vcsvers);
    # if cprod is SFHA, (index+1) is SF and (index+2) is VCS
    return "" unless ($prod->{prod}=~/SFHA/);
    return 0 if(Cfg::opt("upgrade_nonkernelpkgs"));
    $cmpvers = $prod->{vers};
    $sfvers = ${$sys->{prodvers}}[($index+1)];
    $vcsvers = ${$sys->{prodvers}}[($index+2)];
    if (!EDRu::compvers($sfvers,$cmpvers,4) && EDRu::compvers($vcsvers,$cmpvers,4)) {
        $sys->{noconfig_sf}=1;
        $sys->{prod_to_upgrade}=$prod->prod('VCS60');
        $sys->{lower_vers}=$vcsvers;
        $msg = Msg::new("SF $sfvers and VCS $vcsvers are installed on $sys->{sys}. Only VCS $vcsvers will be upgraded.");
        $sys->push_warning($msg);
        return 1;
    }
    if (!EDRu::compvers($vcsvers,$cmpvers,4) && EDRu::compvers($sfvers,$cmpvers,4)) {
        $sys->{noconfig_vcs}=1;
        $sys->{prod_to_upgrade}=$prod->prod('SF60');
        $sys->{lower_vers}=$sfvers;
        $prod->prod('VCS60')->set_vcs_allowcomms_sys($sys);
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
    return '' unless (Cfg::opt(qw(precheck install upgrade patchupgrade uninstall)));
    $rtn='';
    for my $sys (@{$cpic->{systems}}) {
        # Check NetBackup
        $rtn=$rel->check_netbackup_compatibility_sys($sys) || $rtn;

        # Check ApplicationHA
        $rtn=$rel->check_applicationha_compatibility_sys($sys) || $rtn;

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

# always put VRTSvbs pkg after VRTSsfmh pkg
# fix for e2567015
sub adjust_lastpkg_sequence {
    my ($rel)=@_;
    my ($cpic,$mhpos,$vbpos);
    $cpic=Obj::cpic();
    return unless ($cpic->{installpkgslast});
    $mhpos = EDRu::arrpos('VRTSsfmh41',@{$cpic->{installpkgslast}});
    return if ($mhpos == -1);
    $vbpos = EDRu::arrpos('VRTSvbs60',@{$cpic->{installpkgslast}});
    return if ($vbpos == -1);
    return if ($mhpos < $vbpos);
    for (my $i = $vbpos; $i < $mhpos; $i++) {
        ${$cpic->{installpkgslast}}[$i] = ${$cpic->{installpkgslast}}[$i+1];
    }
    ${$cpic->{installpkgslast}}[$mhpos] = 'VRTSvbs60';
    return 1;
}

# Check whether ApplicationHA product installed or not
sub applicationha_sys {
    my ($rel,$sys) = @_;
    my ($vers,$pkg);

    # ApplicationHA mainpkg is VRTSvcsvmw.
    $pkg=Pkg::new_pkg('Pkg', 'VRTSvcsvmw', $sys->{padv});
    $vers=$pkg->version_sys($sys);
    if ($vers) {
       $sys->set_value('pkgvers,ApplicationHA', $vers);
       return $vers;
    }
    return '';
}

# return 1 if $sys or $pkg's attributes are updated, otherwise, return ''
sub check_netbackup_compatibility_sys {
    my ($rel,$sys) = @_;
    my ($msg,@deppkgs_donotuninstall,$nbuvers,$vers,$pkgs,$pkg,$pdfrs);

    # Check NetBackup
    $nbuvers=$rel->netbackup_sys($sys);
    if ($nbuvers) {
        # If NetBackup installed, then skip uninstall VRTSpbx/VRTSicsco/VRTSat.
        for my $pkgname(qw(VRTSpbx VRTSicsco VRTSat50 VRTSatClient50)) {
            $pkg=Pkg::new_pkg('Pkg', $pkgname, $sys->{padv});
            $vers=$pkg->version_sys($sys);
            if ($vers) {
                push (@deppkgs_donotuninstall, $pkg->{pkg});
                push (@{$pkg->{softdeps}}, 'NetBackup');
            }
        }

        $pkgs=join(' ', @deppkgs_donotuninstall) if (@deppkgs_donotuninstall);
        if ($pkgs) {
            if (Cfg::opt(qw(precheck install upgrade patchupgrade uninstall))) {
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
    my ($msg,$csvers,$mincsvers,$cscv,$mhpkg,$mhvers,$mhcv,$pdfr,$rtn);

    $pdfr=Msg::get('pdfr');

    # Check VOM MH
    $mhpkg=$sys->pkg('VRTSsfmh41');
    $mhvers=$mhpkg->version_sys($sys);
    $mhcv=EDRu::compvers($mhvers,$mhpkg->{vers});

    # Check VOM CS
    $csvers=$rel->vomcs_sys($sys);
    if ($csvers) {
        # For e2107309, If VOM/SFM CS installed, then skip upgrade VRTSsfmh
        if ($mhvers && $mhcv==2 && Cfg::opt(qw(precheck install upgrade patchupgrade))) {
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
        if ($mhvers && $mhcv==2 && Cfg::opt(qw(precheck install upgrade patchupgrade))) {
            if (EDRu::inarr($mhpkg->{pkgi}, @{$sys->{donotupgradepkgs}})) {
                # VRTSsfmh may not require upgrade when ApplicationHA also installed.
                Msg::log("VRTSsfmh need not be upgraded");
            } else {
                # Need upgrade VRTSsfmh
                # print warning if the managed host is reporting to some SFM or VOM management servers.
                $rtn=$mhpkg->check_if_managedhost_connected_to_central_server_sys($sys);
                if ($rtn) {
                    $msg=Msg::new("The VRTSsfmh $pdfr on $sys->{sys} will be upgraded to $mhpkg->{vers}. Note that the system $sys->{sys} is reporting to the following management servers:\n\t$rtn");
                    $sys->push_warning($msg);
                }
            }
        } elsif ($mhvers && Cfg::opt(qw(uninstall))) {
            if (EDRu::inarr($mhpkg->{pkgi}, @{$sys->{donotuninstallpkgs}})) {
                # VRTSsfmh may not require uninstall when ApplicationHA also installed.
                Msg::log("VRTSsfmh need not be uninstalled");
            } else {
                # Need uninstall VRTSsfmh
                # print warning if the managed host is reporting to some SFM or VOM management servers.
                $rtn=$mhpkg->check_if_managedhost_connected_to_central_server_sys($sys);
                if ($rtn) {
                    $msg=Msg::new("The VRTSsfmh $pdfr on $sys->{sys} will be uninstalled. Note that the system $sys->{sys} is reporting to the following management servers:\n\t$rtn");
                    $sys->push_warning($msg);
                }
            }
        }
        return '';
    }

    return 1;
}

# return 1 if $sys or $pkg's attributes are updated, otherwise, return ''
sub check_applicationha_compatibility_sys {
    my ($rel,$sys) = @_;
    my ($msg,$apphavers,$mhpkg,$mhvers,$mhcv,$cpic,$prod,$pdfr);

    # Check ApplicationHA
    $apphavers=$rel->applicationha_sys($sys);
    if ($apphavers) {
        # For 2132199, need block install/upgrade for VCS involved products if ApplicationHA installed.

        $pdfr=Msg::get('pdfr');
        $mhpkg=$sys->pkg('VRTSsfmh41');
        $mhvers=$mhpkg->version_sys($sys);
        $mhcv=EDRu::compvers($mhvers,$mhpkg->{vers});

        if (Cfg::opt(qw(precheck install upgrade patchupgrade))) {
            $cpic=Obj::cpic();
            $prod=$cpic->prod;
            if ($rel->has_vcs($prod->{prod})) {
                # For those products involved VCS, block install/upgrade.
                $msg=Msg::new("ApplicationHA $apphavers was installed on $sys->{sys} which conflicts with $prod->{abbr}.");
                $sys->push_error($msg);
                return '';
            } else {
                # For those products not involved VCS, allow install/upgrade,
                # But do not upgrade VRTSsfmh for e2132199.
                push(@{$sys->{donotupgradepkgs}},$mhpkg->{pkgi});

                if ($mhvers && $mhcv==2) {
                    $msg=Msg::new("ApplicationHA $apphavers was installed on $sys->{sys}. The VRTSsfmh $pdfr on $sys->{sys} will not be upgraded.");
                    $sys->push_warning($msg);
                } else {
                    $msg=Msg::new("ApplicationHA $apphavers was installed on $sys->{sys}");
                    $sys->push_note($msg);
                }
            }
        } elsif ($mhvers && Cfg::opt(qw(uninstall))) {
            push(@{$mhpkg->{softdeps}}, 'ApplicationHA');
            push(@{$sys->{donotuninstallpkgs}},$mhpkg->{pkgi});
            $msg=Msg::new("ApplicationHA $apphavers was installed on $sys->{sys}. The VRTSsfmh $pdfr on $sys->{sys} will not be uninstalled.");
            $sys->push_warning($msg);
        } else {
            Msg::log("ApplicationHA $apphavers was installed on $sys->{sys}");
            return '';
        }
    } else {
        Msg::log("ApplicationHA was not installed on $sys->{sys}");
        return '';
    }

    return 1;
}

sub default_systemnames {
    my $rel=shift;
    my ($cpic,$vcs,$dfs,@systems,$cfg);
    $cpic=Obj::cpic();
    $cfg=Obj::cfg();
    $vcs=$cpic->prod("VCS60");
    if(Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs ))){
        return $rel->{nextrusys}  if($rel->{nextrusys});
        $dfs=$rel->determine_rolling_upgrade_system;
        $dfs=~ s/^\s+|\s+$//g;
        @systems=split(/\s+/,$dfs);
        if(Cfg::opt(qw(rolling_upgrade upgrade_kernelpkgs upgrade_nonkernelpkgs ))){
            $cfg->{systems}=\@systems;
        } else {
            delete $cfg->{systems};
        }
        return $dfs;
    } elsif (Cfg::opt("upgrade")) {
        $dfs = $vcs->default_systemnames;
        return $dfs if $dfs;
    }
    return Obj::localsys()->{sys};
}

sub determine_rolling_upgrade_system {
    # get the system cluster configuration infomation
    my (@systems,$ayn,$clustername,$clusterid,$conf,$done,$failed,$msg,$prod,$sys,$sysname,$syslist);
    my ($web,$cfg,$edr,$localsys,$cpic,$webmsg);
    my ($rulist,$non_rulist,$final_list,$sub,$rutype,$rel,$helpmsg,$def,$prodvers,$cv,$warning,$cprod,$prodlist,$had,$task,$vcs,$ruvers,$namefailed);
    $cfg=Obj::cfg();
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    $web=Obj::web();
    $localsys=Obj::localsys();
    $vcs=$prod=$cpic->prod("VCS60");

    $sysname=$localsys->{sys};
    if(${$cfg->{systems}}[0]) {
        $sysname=${$cfg->{systems}}[0];
    }

    $failed=0;
    while(1){
        if ($failed) {
            if (Cfg::opt('responsefile')) {
                $msg=Msg::new("An error occured when using responsefile");
                $msg->die();
            }
            unless($namefailed){
                if (Obj::webui()) {
                    $cpic->edr_completion();
                } else {
                    Msg::prtc();
                    Cfg::unset_opt("upgrade");
                    Cfg::unset_opt("rolling_upgrade");
                    $task=$rel->upgrade_menu();
                    if(EDR::getmsgkey($task,'back')){
                        delete $cpic->{task};
                        delete $cpic->{prod};
                        $rel->cli_installer_menu();
                    } elsif($task){
                        Cfg::set_opt('upgrade');
                        Cfg::set_opt($task);
                    }
                    if(!Cfg::opt("rolling_upgrade")){
                        return $vcs->default_systemnames;
                    }
                }
            }

            if (!Obj::webui()) {
                $msg=Msg::new("Would you like to perform a rolling upgrade on the other cluster?");
                $ayn=$msg->aynn;
                $edr->{savelog}=1;
                $cpic->edr_completion() if ($ayn eq 'N');

                do {
                    $msg=Msg::new("Enter any one system of another $prod->{abbr} cluster that you would like to perform rolling upgrade:");
                    $sysname=$msg->ask;
                    # chop extra systems, in case they enter more
                    $sysname=EDRu::despace($sysname);
                    $sysname=~s/\s.*$//m;
                } while ($edr->validate_systemnames($sysname));
            }
        }
        $failed=1;
        if (Obj::webui()) {
            $msg = Msg::new("Enter any one system of the cluster on which you would like to perform rolling upgrade");
            $cfg->{systems} = $web->web_script_form('selectCluster', $msg);
            $sysname=${$cfg->{systems}}[0];
            $web->web_script_form('precheck');
        }

        $edr->set_progress_steps(3);
        $sys=($Obj::pool{"Sys::$sysname"}) ?
            Obj::sys($sysname) : Sys->new($sysname);
        $msg=Msg::new("Checking cluster information $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $sys->set_value('stop_checks', 0);
        $namefailed=0;
        if ($edr->transport_sys($sys)) {
            $msg->right_done;
            $msg->display_right() if (Obj::webui());
        } else {
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                if(Obj::webui()){
                     $msg->addError($errmsg);
                }
                Msg::print($errmsg);
            }
            $namefailed=1;
            next;
        }
        $msg=Msg::new("Checking release compatibility on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        if ($edr->supported_padv_sys($sys)) {
            Msg::right_done();
            $msg->display_right() if (Obj::webui());
        } else {
            Msg::right_failed();
            for my $errmsg (@{$sys->{errors}}) {
                if(Obj::webui()){
                    $msg->addError($errmsg);
                }
                Msg::print($errmsg);
            }
            next;
        }

        $msg=Msg::new("Checking rolling upgrade prerequisites on $sys->{sys}");
        $msg->left;
        $msg->display_left($msg) if (Obj::webui());
        $cpic->installed_prod_sys($sys);
        $msg->right_done;
        $msg->display_right() if (Obj::webui());

        $cprod=CPIC::get('prod');
        if($cprod){
            $prod=$cpic->prod($cprod);
            $prodvers=$prod->version_sys($sys) if($prod);
        }
        unless($prod && $prodvers){
           $warning=Msg::new("Installer cannot find a product installed on the system.");
            if(Obj::webui()){
                $msg->addError($warning->{msg});
            }
            $warning->warning();
            next;
        }
        $ruvers=$rel->{ru_version};
        $cv=EDRu::compvers($prodvers,$ruvers,2);
        $prodlist=join(" ",@{$rel->{ru_prod}});
        $prodlist=~s/\d+//g;
        $had = $sys->proc_pids('bin/had');
        if($cv==2 || (!EDRu::inarr($cprod,@{$rel->{ru_prod}}))){
           $cprod=~s/\d+//g;
           $warning=Msg::new("The system is installed with $cprod($prodvers); but rolling upgrade is supported from the version of $ruvers for the products $prodlist.");
           if(Obj::webui()){
               $msg->addError($warning->{msg});
           }
           $warning->warning();
           next;
        }

        unless(scalar(@$had)>0){
           $warning=Msg::new("The cluster is not running on $sys->{sys}. The cluster must be running on all systems in order to perform rolling upgrade.");
           if(Obj::webui()){
               $msg->addError($warning->{msg});
           }
           $warning->warning();
           next;
        }

        $conf=$vcs->get_config_sys($sys);

        if ($conf) {
            if($conf->{offline_systems}){
                $warning=Msg::new("The system(s) $conf->{offline_systems} are not running on the cluster. It is recommended to online all the systems in the cluster and then perform rolling upgrade.");
                if(Obj::webui()){
                    $msg->addError($warning->{msg});
                }
                $warning->warning();
                next;
             }
            $clustername=$conf->{clustername};
            @systems=@{$conf->{systems}};
            $clusterid=$conf->{clusterid};
        } else {
            $warning=Msg::new("Cluster configuration information checking failed on $sys->{sys}. It is recommended to configure the cluster and then perform rolling upgrade.");
            if(Obj::webui()){
                $msg->addError($warning->{msg});
            }
            $warning->warning();
            next;
        }
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
        $webmsg =~ s/\n/\n\n/g;
        $webmsg =~ s/\t/&nbsp;&nbsp;/g;

        if (!Cfg::opt('responsefile')) {
            $msg=Msg::new("Would you like to perform rolling upgrade on the cluster?");
            $ayn=$msg->ayn('','','',$webmsg);
        } else {
            $ayn='Y';
        }
        unless ($ayn eq 'Y'){
            $namefailed=1;
            next;
        }

        $done=1;
        $msg = Msg::new("Checking");
        if (Obj::webui()){
            $web->{systemlist}=join(' ',@systems);
            $web->web_script_form('precheck',$msg);
        }
        $edr->set_progress_steps(2*scalar(@systems)-2);
        for my $sysname (@systems) {
            next if($sysname eq $sys->{sys});
            $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname)
                                                 : Sys->new($sysname);
            $msg=Msg::new("Checking cluster information on $sys->{sys}");
            $msg->left;
            $msg->display_left($msg) if (Obj::webui());
            $sys->set_value('stop_checks', 0);
            if ($edr->transport_sys($sys)) {
                $msg->right_done;
                $msg->display_right() if (Obj::webui());
            } else {
                $msg->right_failed;
                for my $errmsg (@{$sys->{errors}}) {
                    $msg->addError($errmsg);
                    Msg::print($errmsg);
                }
                $done=0;
                last;
            }

           $msg=Msg::new("Checking rolling upgrade prerequisites on $sys->{sys}");
           $msg->left;
            $msg->display_left($msg) if (Obj::webui());
            $cpic->installed_prod_sys($sys);
            $msg->right_done;
            $msg->display_right() if (Obj::webui());

            $cprod=CPIC::get('prod');
            $prod=$cpic->prod($cprod);
            $prodvers=$prod->version_sys($sys);

            $cv=EDRu::compvers($prodvers,$rel->{ru_version},2);
            $prodlist=join(" ",@{$rel->{ru_prod}});
            $prodlist=~s/\d+//g;
            $had = $sys->proc_pids('bin/had');
            if($cv==2 || (!EDRu::inarr($cprod,@{$rel->{ru_prod}}))){
               $warning=Msg::new("The system is installed with $cprod-$prodvers; but rolling upgrade is supported from the version of $rel->{ru_version} for the products $prodlist.");
                if(Obj::webui()){
                    $msg->addError($warning->{msg});
                }
                $warning->warning();
               $done=0;
            }
            unless(scalar(@$had)>0){
                $warning=Msg::new("Cluster is not running on $sys->{sys}. To perform rolling upgrade, cluster must be running on all systems.");
                if(Obj::webui()){
                     $msg->addError($warning->{msg});
                }
                $warning->warning();
                $done=0;
                last;
           }
        }

        next unless ($done);

        $rel=$cpic->rel;
        $rel->{cluster_systems}=\@systems;
        $rulist=$non_rulist="";
        for my $sysname (@systems) {
            $sys=($Obj::pool{"Sys::$sysname"}) ? Obj::sys($sysname) : Sys->new($sysname);
            if($rel->determine_rolling_upgrade_sys($sys)){
                $rulist.= " $sysname";
            } else {
                $non_rulist.=" $sysname";
            }
        }
        if($rulist){
            if($non_rulist){
                $msg=Msg::new("Rolling upgrade phase 1 is already performed on the system(s) $rulist. It is recommended to perform rolling upgrade phase 1 on the remain system(s) $non_rulist.");
                $msg->bold;
                $webmsg = $msg->{msg};
                $msg=Msg::new("Would you like to perform rolling upgrade phase 1 on the systems?");
                $ayn=$msg->ayny('','',$webmsg);
                if($ayn eq 'Y'){
                    $final_list=$non_rulist;
                } else {
                    $msg=Msg::new("Enter the system names separated by spaces on which you want to perform rolling upgrade phase 1:");
                    $helpmsg=Msg::new("Systems specified are required to have rsh or ssh configured for password free logins");
                    if (Obj::webui()) {
                        $msg->{msg} =~ s/\:+$//g;
                        my $systems = $web->web_script_form('selectCluster',$msg);
                        $final_list = join(' ', @$systems);
                    } else {
                        $final_list=$msg->ask('',$helpmsg);
                    }
                }
                $rutype=1;
            } else {
                $msg=Msg::new("Rolling upgrade phase 1 is already performed on all the cluster systems. It is recommended to perform rolling upgrade phase 2 on all the cluster systems.");
                $msg->bold;
                $webmsg = $msg->{msg};
                $msg=Msg::new("Would you like to perform rolling upgrade phase 2 on the cluster?");
                $ayn=$msg->ayny('','',$webmsg);
                if($ayn eq 'Y'){
                    $final_list=$rulist;
                }else{
                    $namefailed=1;
                    next;
                }
                $rutype=2;
            }
        } else {
            my (%apps,$n,@grs,$i,$msgtitle);
            $i=1;
            if($#{$conf->{groups}}>-1){
                for my $sysname (@systems) {
                    if($conf->{online_servicegroups}{$sysname}){
                        $msgtitle=Msg::new("\nThe following service groups are found online in the cluster:");
                    }
                }
                if($msgtitle){
                    $msgtitle->bold;
                    $webmsg = "$msgtitle->{msg}\n";
                }
            }
            for my $sysname (@systems) {
                $n=0;
                if($conf->{online_servicegroups}{$sysname}){
                    $msg=Msg::new("Service Groups Online on $sysname: $conf->{online_servicegroups}{$sysname}");
                    $msg->print;
                    $webmsg .= "$msg->{msg}\n";
                    @grs=split(/\s+/,$conf->{online_servicegroups}{$sysname});
                    $n=$#{grs}+1;
                }
                $apps{$sysname}=$n;
            }

            $sub=int(($#{systems})/2+1);
            foreach my $key (sort { $apps{$a} <=> $apps{$b}} keys %apps){
                if($i <= $sub){
                    $final_list.=" $key";
                    $i=$i+1;
                }
            }

            $msg=Msg::new("\nIt is recommended to perform rolling upgrade phase 1 on the system$final_list to get minimal downtime.");
            $msg->bold;
            $webmsg .= $msg->{msg};
            $webmsg =~ s/\n/\n\n/g;
            $msg=Msg::new("Would you like to perform rolling upgrade phase 1 on the systems?");
            $ayn=$msg->ayny('','',$webmsg);
            if($ayn eq 'Y'){

            } else {
                $msg=Msg::new("Enter the system names separated by spaces on which you want to perform rolling upgrade phase 1:");
                $helpmsg=Msg::new("Systems specified are required to have rsh or ssh configured for password free logins");
                if (Obj::webui()) {
                    my $systems = $web->web_script_form('selectCluster',$msg);
                    $final_list = join(' ', @$systems);
                } else {
                    $final_list=$msg->ask($def,$helpmsg);
                }
            }
            $rutype=1;
        }
        last;
    }
    if($rutype == 1){
        Cfg::set_opt("upgrade_kernelpkgs");
        Cfg::unset_opt("upgrade_nonkernelpkgs");
    } elsif($rutype == 2){
        Cfg::unset_opt("upgrade_kernelpkgs");
        Cfg::set_opt("upgrade_nonkernelpkgs");
    }
    $web->{systemlist} = $final_list;
    return $final_list;
}

sub determine_rolling_upgrade_sys{
    my ($rel,$sys)=@_;
    my ($llt,$vcs,$cur_ru,$lltver,$vcsver,$lltmpver,$vcsmpver,$lltpkgver,$vcspkgver,$do,$do1,$cv);
    $llt=$rel->pkg('VRTSllt60');
    $vcs=$rel->pkg('VRTSvcs60');
    $lltmpver=$llt->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
    $vcsmpver=$vcs->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
    $lltpkgver=$sys->padv->pkg_version_sys($sys,$llt);
    $vcspkgver=$sys->padv->pkg_version_sys($sys,$vcs);
    $lltver=$lltmpver || $lltpkgver;
    $vcsver=$vcsmpver || $vcspkgver;
    return '' unless($lltver && $vcsver);
    $do=$sys->cmd("_cmd_grep -v '^#' /etc/gabtab 2>/dev/null");
    $do1=$sys->cmd("_cmd_grep -v '^#' /etc/vxfenmode 2>/dev/null");
    #return 0 unless ($do=~/vxfen_protocol_version/);
    $cv=EDRu::compvers($vcsver,$lltver,4);
    Msg::log("Determine rolling upgrade on $sys->{sys}: llt version is $lltver,vcs version is $vcsver");
    if ($do=~/-V/m && $cv==2){
        $cur_ru=1;
    } else {
        $cur_ru=0;
    }
    $sys->set_value('rolling_upgrade',$cur_ru);
    return $cur_ru;
}

# check rolling upgrade on systems
# return -1 prod doesn't support
# return 0  nodes have not the same status
# return 1 rolling upgrade phase1
# return 2 rolling upgrade phase2
sub determine_rolling_upgrade {
    my ($rel,$prod) = @_;
    my ($cfg,$lltmpver,$vcspkgver,$sys,$cur_ru,$padv,$unkernelpkg,$unkernelpkgi,$vcs,$prodver,$prodobj,$lltver,$lltpkgver,$do1,$cv,$vcsmpver,$do_ru2,$diff,$syslist,$sys1_ru,$llt,$do,$vcsver);
    $syslist=CPIC::get('systems');
    $padv=CPIC::get('padv');
    $cfg=Obj::cfg();
    $prodobj=$rel->prod($prod);
    $sys1_ru=0;
    $cur_ru=0;
    return '' unless (Cfg::opt(qw(upgrade patchupgrade)));
    for my $sys (@$syslist) {
        $cur_ru=0;
        $llt=$rel->pkg('VRTSllt60');
        $vcs=$rel->pkg('VRTSvcs60');
        $lltmpver=$llt->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
        $vcsmpver=$vcs->mpversion_sys($sys,1) if ($sys->{padv} =~ /Sol/m);
        $lltpkgver=$sys->padv->pkg_version_sys($sys,$llt);
        $vcspkgver=$sys->padv->pkg_version_sys($sys,$vcs);
        $lltver=$lltmpver || $lltpkgver;
        $vcsver=$vcsmpver || $vcspkgver;
        return '' unless($lltver && $vcsver);
        $do=$sys->cmd("_cmd_grep -v '^#' /etc/gabtab 2>/dev/null");
        $do1=$sys->cmd("_cmd_grep -v '^#' /etc/vxfenmode 2>/dev/null");
        #return 0 unless ($do=~/vxfen_protocol_version/);
        $cv=EDRu::compvers($vcsver,$lltver,4);
        Msg::log("Determine rolling upgrade on $sys->{sys}: llt version is $lltver,vcs version is $vcsver");
        if ($do=~/-V/m && $cv==2){
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
        for my $unkernelpkgi (@{$rel->{ru_unkernelpkgs}}){
            $unkernelpkg=$rel->pkg($unkernelpkgi);
            $unkernelpkg->set_value('donotrmonupgrade',1);
        }
        return 1;
    }
    if(Cfg::opt('upgrade_nonkernelpkgs')){
        for my $unkernelpkgi (@{$rel->{ru_unkernelpkgs}}){
            $unkernelpkg=$rel->pkg($unkernelpkgi);
            $unkernelpkg->set_value('donotrmonupgrade',0);
        }
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
    if ((Cfg::opt('prodmode') eq 'SF Basic') && ($prod->{prod} ne 'SF') && $ivers && Cfg::opt(qw(upgrade patchupgrade))) {
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
    return '' if (Cfg::opt('responsefile') && (EDR::get('exitfile') eq ''));

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
            }
            last;
        }
        last if Cfg::opt('upgrade');

        if (!$cprod) {
            $mprod||=$rel->prod_menu($mtask,$mprod);
        } else {
            $mprod||=$cprod; # for exitfile
        }
        if (EDR::getmsgkey($mprod,'back')) {
            $cfg->{opt}{$mtask}=0;
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
        push(@ilprods,$prodi) if ($prod->{obsoleted} || ($prod->{proddir} &&
            (-d "$cpic->{mediapath}/$prod->{proddir}")));
    }

    $localsys=Obj::localsys();
    $rel->inst_lic_sys($localsys, @ilprods);

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
    $cpic->{menu}=["Full Upgrade","Rolling Upgrade"];
    @dopts=('','rolling_upgrade');

    $msg=Msg::new("Select the way by which you want to upgrade product:");
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
        if (-d "$cpic->{mediapath}/$prod->{proddir}") {
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
        next if (($option eq 'Veritas File Replicator') && ($prod->{prod} =~ /SVS/m));
        $soption='';
        $soption='vr' if ($option eq 'Veritas Volume Replicator');
        $soption='vfr' if ($option eq 'Veritas File Replicator');
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

sub cli_prod_option {
    my ($rel) = @_;
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
sub cli_license_option {
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
        Msg::title();
        $msg=Msg::new("To comply with the terms of Symantec's End User License Agreement, you have 60 days to either:\n\n * Enter a valid license key matching the functionality in use on the systems\n * Enable keyless licensing and manage the systems with a Management Server. For more details visit http://go.symantec.com/sfhakeyless. The product is fully functional during these 60 days.\n");
        $msg->print;

        $msg=Msg::new("How would you like to license the systems?");
        #$help=Msg::new("Proceed with:");
        $type=$msg->menu($lic_types, '2', $help, 0);
        Msg::n();
        Cfg::set_opt('vxkeyless', 1) if ($type eq '2');
        Cfg::set_opt('bypass_licensing', 1) if ($type eq '3');
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

    if ($cpic->{script} =~ /^installer/m){
        Msg::prtc();
    } else {
        $cpic->completion()
    }

    while (1) {
        Msg::title();
        $msg=Msg::new("Select a product to view its product requirements:");
        $menu = $rel->prod_menu("requirements");
        # back menu option
        if (EDR::getmsgkey($menu,'back')) {
            return '';
        }
        Msg::n();
        $prodname=$menu;
        $prod=$rel->prod($prodname);
        $prod->cli_print_requirements($rel);
        Msg::prtc();
    }
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
        $msg=Msg::new("\nCannot determine product install/license status on system $sys->{sys} as its platform is $sys->{padv}. Software included in this distribution is intended for systems of platform $padv.\n");
        $msg->print;
        return '';
    }

    # get the license info for all prods
    $rel->read_licenses_sys($sys);
    $sys->pkgs_patches();

    $format = '%-49s  %-19s  %-s';
    $pl=Msg::string_sprintf($format, Msg::get('menu_vendor_prod'),
                      Msg::get('menu_version_installed'),
                      Msg::get('menu_version_licensed'));

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
            if ($prod->{obsoleted}) {
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
    $msg->msg('menu_fullupgrade');
    $msg=Msg::new("Full Upgrade");
    $msg->msg('menu_rollingupgrade1');
    $msg=Msg::new("Rolling Upgrade Phase 1");
    $msg->msg('menu_rollingupgrade2');
    $msg=Msg::new("Rolling Upgrade Phase 2");

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
    $msg=Msg::new("Removes the selected product's $pdfrs, patches, files, and directories from the system provided they are not used by another Veritas product");
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
        $sfmh_pkg=$rel->pkg('VRTSsfmh41');
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

# Copyright: Copyright (c) 2010 Symantec Corporation.
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
    if ($rel->{type} eq 'RP') {
        $mod_rel =~ s/\d+//m;
        my @vars = split(/\D+/m,$rel->{basevers});
        my $suffix = $vars[0].$vars[1];
        if ($vars[2]) {
            my $sp = substr($vars[2],0,1);
            $suffix .= "SP$sp";
        }
        $mod_rel .= $suffix;
    }
    # figure out the list of pkg and patch for current UPI, or all those UPIs in the DVD

    #As EDR has not yet reached upto the level of seperate product install scripts
    $prods = ($cpic->{prod}) ? [ $cpic->{prod} ] : $rel->{prods};

    foreach my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        # Waiting for mode porting in CPIP
        # Only generate the finish scripts for product which are displayed in the menu
        if ($cpic->{script} =~ /"installer"/mx) {
            next if (! -d "$cpic->{mediapath}/$prod->{prod}}");
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

# this sub could generate a kickstart script and could be used to install VRTS pkgs
# during redhat kickstart automation installaion.
sub kickstart {
    my ($rel) = @_;
    my ($basename,$mod_rel,$msg,$pkg,$pkgi,@pkgs,$prod,$prods,$rpmlist,$savepath,$fd);

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
    if ($rel->{type} eq 'RP') {
        $mod_rel =~ s/\d+//m;
        my @vars = split(/\D+/m,$rel->{basevers});
        my $suffix = $vars[0].$vars[1];
        if ($vars[2]) {
            my $sp = substr($vars[2],0,1);
            $suffix .= "SP$sp";
        }
        $mod_rel .= $suffix;
    }
    $prods = ($cpic->{prod}) ? [ $cpic->{prod} ] : $rel->{prods};
    for my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        next if ($prod->{obsoleted});

        # figure out the list of pkg and patch for current UPI, or all those UPIs in the DVD
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            push(@pkgs,$pkg->{pkg});
        }
        $rpmlist = join(' ',@pkgs);
        @pkgs = ();

        $basename = 'kickstart_' . lc($prodi) . '.ks';
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
        $msg = Msg::new("The kickstart script for $prodi is generated at $basename");
        $msg->bold;

    }
    return;
}

sub yumgroupxml {
    my ($rel) = @_;
    my ($basename,$msg,$pkg,$pkgi,@pkgs,$prod,$prods,$savepath,$fd,$xml);

    my $edr = Obj::edr();
    my $cpic = Obj::cpic();

    unless(Cfg::opt('yumgroupxml') && $cpic->{padv} =~ /^RHEL/m) {
        $msg = Msg::new("-yumgroupxml option is only supported on Ret Hat Linux platform");
        $msg->warning();
        return '';
    }

    $savepath = Cfg::opt('yumgroupxml');

    if ($cpic->{prod}) {
        $prods = [ $cpic->{prod} ];
    } else {
        $prods = [ $rel->prod_menu('yumgroupxml','') ];
    }

    for my $prodi ( sort(@{$prods}) ) {
        $prod=$cpic->prod($prodi);
        next if ($prod->{obsoleted});

        # figure out the list of pkg and patch for current UPI, or all those UPIs in the DVD
        @pkgs = ();
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
            push(@pkgs,$pkg->{pkg});
        }

        $basename = 'comps_' . lc($prodi) . '.xml';
        $basename = "$savepath". '/' . "$basename";
        $msg = Msg::new("Cannot open $basename for generating the yum group XML file");
        open($fd, '>', $basename) or $msg->die;

        $xml = "<comps>\n";
        $xml.="\t<group>\n";
        $xml.="\t\t<id>".uc($prodi)."</id>\n";
        $xml.="\t\t<name>".uc($prodi)."</name>\n";
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
        $msg = Msg::new("The yum group XML for $prodi is generated at $basename");
        $msg->bold;
    }
    return;
}

# ignite
sub ignite {
    my ($rel)=@_;
    my ($rtn,$msg,$errmsg,$mprod,$prod,$def,$bundle_name,$bundle_dir,$ver,$pkg,$pkglist,$pkgspace_required);

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

    # step 3. check the space requirement on Ignite server for selected product
    # figure out the list of packages for current product
    for my $pkgi (@{$prod->allpkgs}) {
        $pkg=$cpic->pkg($pkgi);
        $pkglist .= "$pkg->{pkg} ";
        $pkgspace_required+=$pkg->{size};
    }
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

    # step 4. ask user for the bundle name (default value is <prodabbr_vers_bundle>, eg: SF60_bundle)
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
    my $pkgpath=$rel->pkgs_patches_dir('pkgpath');
    for my $pkgi (@{$prod->allpkgs}) {
        $pkg=$cpic->pkg($pkgi);
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
        # add post_load_cmd = "/opt/VRTS/install/bin/UXRT60/add_install_scripts" in core_media_cfg
        my $content=$localsys->cmd("_cmd_cat $bundle_data_dir/core_media_cfg 2>/dev/null");
        my @conts=split(/\n/,$content);
        my $filecont="";
        for my $line (@conts) {
            if ($line=~/sd_software_list/) {
                $filecont.="    ";
                $filecont.="post_load_cmd = \"/opt/VRTS/install/bin/UXRT60/add_install_scripts\"\n";
            }
            $filecont.=$line."\n";
        }
        EDRu::writefile($filecont,"$bundle_data_dir/core_media_cfg");
        $msg->display_status();
    }

    # step 8. add the cfg files into OS core media repository
    my $indexfile="/var/opt/ignite/data/INDEX";
    my @os_media_list;
    if ($localsys->exists($indexfile)) {
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
                        if ($cpic->{prod} =~ /DMP/) {
                            $msg=Msg::new("Ensure the following OS native bundles and packages are deselected before installing $bundle_name with HPUX OS.\n    OS bundles: Base-VxTools-50 Base-VxVM-50 B3929FB Base-VxVM\n    OS packages : AVXTOOL AVXVM\n");
                            $msg->nprint();
                        } else {
                            $msg=Msg::new("Ensure the following OS native bundles and packages are deselected before installing $bundle_name with HPUX OS.\n    OS bundles: Base-VxTools-50 Base-VxVM-50 B3929FB Base-VxFS-50 Base-VxVM\n    OS packages : AVXTOOL AVXVM AONLINEJFS OnlineJFS01 AVXFS\n");
                            $msg->nprint();
                        }
                    }
                }
            } else {
                if ($cpic->{prod} =~ /VCS/) {
                    $msg=Msg::new("If the installvcs and uninstallvcs scripts are not generated under the /opt/VRTS/install directory after VCS bundle installation, manually generate these scripts by running the command '/opt/VRTS/install/bin/UXRT60/add_install_scripts'.\n");
                    $msg->nprint();
                } elsif ($cpic->{prod} =~ /DMP/) {
                    $msg=Msg::new("Ensure the following OS native bundles and packages are removed before $bundle_name installation.\n    OS bundles: Base-VxTools-50 Base-VxVM-50 B3929FB Base-VxVM\n    OS packages : AVXTOOL AVXVM\n");
                    $msg->nprint();
                } else {
                    $msg=Msg::new("Ensure the following OS native bundles and packages are removed before $bundle_name installation.\n    OS bundles: Base-VxTools-50 Base-VxVM-50 B3929FB Base-VxFS-50 Base-VxVM\n    OS packages : AVXTOOL AVXVM AONLINEJFS OnlineJFS01 AVXFS\n");
                    $msg->nprint();
                }
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
    my ($ayn,$help,$msg,$mprod,$patch,$patchi,$pkg,$pkgi,$prod,$prodi,$rtn);
    my ($bff_dir,$bnd_file,$bnd_name,$lpp_source,$lpp_location,$lpplist,$master,$rp,$tmp_bnd_file,$updlist,$vx_nim_path);

    my $edr = Obj::edr();
    my $cpic = Obj::cpic();

    unless(Cfg::opt('nim') && $cpic->{padv} =~ /^AIX/m) {
        $msg = Msg::new("The -nim option is only supported on the AIX platform");
        $msg->warning();
        return '';
    }
    $rp = 1 if ($rel->{type} eq 'RP');

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
    $prodi=$cpic->{prod};

    # figure out the list of packages for current product
    for my $pkgi (@{$prod->allpkgs}) {
        $pkg=$cpic->pkg($pkgi);
        $lpplist .= "I:$pkg->{pkg}\n";
        for my $patchi (@{$pkg->patches_allvers()}) {
            $patch=$cpic->patch($patchi);
            $updlist .= "I:$patch->{patch}\n";
        }
    }

    unless ($rp) {
        $tmp_bnd_file = "/var/tmp/$prodi.bnd";
        EDRu::writefile($lpplist,$tmp_bnd_file);
        $msg = Msg::new("The installp_bundle configuration file $tmp_bnd_file generated for product $prodi\n");
        $msg->bold();
    }

    return 1 unless ($master);

    # check LPP_SOURCE for VRTS base lpp
    $lpp_source = Cfg::opt('nim');
    while (1) {
        unless ($lpp_source) {
            if ($rp) {
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
    unless ($rp) {
        Msg::n();
        $msg = Msg::new("Copy the following packages to $bff_dir for LPP_SOURCE $lpp_source\n");
        $msg->bold;
        for my $pkgi (@{$prod->allpkgs}) {
            $pkg=$cpic->pkg($pkgi);
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
            for my $patchi (@{$pkg->patches_allvers()}) {
                $patch=$cpic->patch($patchi);
                my $dest = EDRu::basename($patch->{file}).".$patch->{vers}";
                Msg::left("$patch->{patch}");
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
    }

    # update .toc for LPP_SOURCE directory
    EDR::cmd_local("_cmd_inutoc $bff_dir");

    if ($rp) {
        $msg = Msg::new("LPP_SOURCE $lpp_source updated for $prod->{abbr}$rel->{titlevers}");
        $msg->bold();
        return '';
    }

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
            $bnd_name = $answer;
            last;
        }
    }
    $vx_nim_path = '/opt/VRTS/nim';
    EDR::cmd_local("_cmd_mkdir -p $vx_nim_path");
    $tmp_bnd_file = "/var/tmp/$prodi.bnd";
    $bnd_file = "$vx_nim_path/$bnd_name.bundle";
    EDR::cmd_local("_cmd_cp -f $tmp_bnd_file $bnd_file");

    my $skip = 0;
    $rtn = EDR::cmd_local("_cmd_lsnim -l $bnd_name 2>/dev/null");
    if ($rtn) {
        $msg = Msg::new("installp_bundle $bnd_name is already defined in this NIM master");
        $msg->bold();
        $msg = Msg::new("Do you want to remove the existing installp_bundle and create a new one with the same name?");
        $help = Msg::new("Answering 'y' will remove the existing installp_bundle and create a new one with the same name. Answering 'n' will keep the current installp_bundle unchanged and no installp_bundle will be created.");
        $ayn = $msg->aynn($help);
        if ($ayn eq 'Y') {
            EDR::cmd_local("_cmd_nim -o remove $bnd_name");
        } else {
            $skip = 1;
        }
    }
    unless ($skip) {
        EDR::cmd_local("_cmd_nim -o define -t installp_bundle -a server=master -a location=$bnd_file $bnd_name");
        Msg::n();
        $msg = Msg::new("installp_bundle $bnd_name created for $prod->{abbr}");
        $msg->bold();
    }

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
    @settunables_products = qw /SVS60 SFRAC60 SFSYBASECE60 SFCFSHA60 SFHA60 SF60 VM60 FS60 DMP60 VCS60/;

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

package Rel::UXRT60::AIX;
@Rel::UXRT60::AIX::ISA = qw(Rel::UXRT60::Common);

sub init_plat {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(6.1 7.1) ];
    $rel->{platreqs}=[ 'AIX 6.1 TL5 or later',
                       'AIX 7.1 TL0 or later' ];
    $rel->{upgradevers}=[ qw(5.0.3 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFCFSRAC60 SVS60 SFSYBASECE60));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS60 SFSYBASECE60));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS60 SFSYBASECE60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS60 SFSYBASECE60));
    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50)];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:2560,7545,0,6
VRTSaslapm:0,806,0,789
VRTScavf:768,66,0,2
VRTScps:28791,0,0,2
VRTSdbac:3906,2974,0,515
VRTSdbed:29458,0,0,3
VRTSfssdk:3114,0,0,0
VRTSgab:631,3276,0,76
VRTSglm:32,394,0,16
VRTSgms:0,160,0,0
VRTSllt:1149,531,0,228
VRTSob:95388,0,0,297
VRTSodm:478,573,0,5
VRTSperl:145785,0,0,0
VRTSsfcpi60:4423,0,0,0
VRTSsfmh:126930,0,0,0
VRTSspt:24431,0,0,0
VRTSvbs:55662,0,0,3
VRTSvcs:427758,19804,0,229
VRTSvcsag:20559,0,0,45
VRTSvcsea:6781,0,0,56
VRTSveki:0,129,0,0
VRTSvlic:69,0,0,1378
VRTSvxfen:675,1641,0,1010
VRTSvxfs:28732,10942,0,2961
VRTSvxvm:7674,195392,0,34501
_PKGSPACE_

    $rel->{commands_need_be_checked}=[ qw(entstat genkex getconf hostid installp inutoc ldd lsattr lsdev lslpp lsps netstat nm nslookup odmget prtconf strload) ];

    return;
}

sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($msg,$iosl,@f,$cprodabbr,$ostl,$tl);
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
        if ($iosl && (2 == EDRu::compvers($iosl,$minvers))) {
            $msg=Msg::new("Cannot install $cprodabbr on system $sys->{sys} since its ioslevel is $ostl. Minimum VIOS ioslevel required is $minimum_vios_ioslevel.");
            $sys->push_error($msg);
            return '';
        }
    }

    #changed the oslevel option from -r to -s
    $ostl = $sys->cmd('/bin/oslevel -s');
    @f=split(/\W/m,$ostl);
    $tl=$f[1];
    if ($sys->{platvers} eq '6.1') {
        if ($tl < 5) {
            $msg=Msg::new("Cannot install $cprodabbr on system $sys->{sys} since its oslevel is 6.1 TL $tl. Upgrade the system to 6.1 TL5 or later to install $cprodabbr");
            $sys->push_error($msg);
            return '';
        }
    }
    # AIX 7.1 TL 0 or later - no check needed

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

package Rel::UXRT60::HPUX;
@Rel::UXRT60::HPUX::ISA = qw(Rel::UXRT60::Common);

sub init_plat {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(11.31) ];
    $rel->{platreqs}=[ 'HP-UX 11iv3, 1103 fusion or later(IA or PA)' ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFCFSRAC60 SVS60 SFSYBASECE60));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS60 SFSYBASECE60));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS60 SFSYBASECE60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS60 SFSYBASECE60));
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

    $rel->{commands_need_be_checked}=[ qw(getconf hostid ioscan kcmodule kctune lanadmin lanscan machinfo model netstat nm nslookup swagentd swapinfo swinstall swlist swmodify swreg swremove) ];
    #$rel->{commands_need_be_checked_for_install}=[ qw(gunzip) ];
    #$rel->{commands_need_be_checked_for_upgrade}=[ qw(gunzip) ];
    #$rel->{commands_need_be_checked_for_patchupgrade}=[ qw(gunzip) ];
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

package Rel::UXRT60::HPUX1131;
@Rel::UXRT60::HPUX1131::ISA = qw(Rel::UXRT60::HPUX);

sub init_padv {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(11.31) ];
    $rel->{upgradevers}=[ qw(3.5 4.1 5.0 5.0.1 5.1.100) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:333,1324,0,7
VRTSaslapm:0,3600,0,1018
VRTScavf:748,65,0,7
VRTScps:30603,0,0,2
VRTSdbac:3193,1735,0,476
VRTSdbed:66718,0,0,3
VRTSfsadv:11376,0,0,3
VRTSfssdk:8368,0,0,0
VRTSgab:176,2457,0,104
VRTSglm:1,765,0,116
VRTSgms:0,459,0,2
VRTSllt:655,1033,0,681
VRTSob:126929,0,0,201
VRTSodm:6950,801,0,4011
VRTSperl:185017,0,0,0
VRTSsfcpi60:4441,0,0,0
VRTSsfmh:136487,0,0,0
VRTSspt:26710,0,0,0
VRTSvbs:104329,0,0,3
VRTSvcs:184586,8638,0,230
VRTSvcsag:4800,0,0,57
VRTSvcsea:9146,0,0,51
VRTSvlic:114,3774,0,3889
VRTSvxfen:1029,1473,0,531
VRTSvxfs:8039,89465,0,59727
VRTSvxvm:35974,305099,0,300714
_PKGSPACE_
    return;
}

package Rel::UXRT60::Linux;
@Rel::UXRT60::Linux::ISA = qw(Rel::UXRT60::Common);

sub init_plat {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC60 SFSYBASECE60 SFCFSRAC60 SFCFSHA60 SFHA60
                                SF60 VCS60 VM60 DMP60 FS60) ];
    $rel->{platreqs} = [ 'RHEL5 U5 (2.6.18-194.el5) or later', 'RHEL6 U1 (2.6.32-131.el6)',
                         'SLES10 SP4 (2.6.16.60)', 'SLES11 SP1 (2.6.32.12)'];
    $rel->{upgradevers}=[ qw(5.0.30 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50 VRTSatClient50)];

    $rel->{commands_need_be_checked}=[ qw(arch dmidecode ethtool getconf hostid modprobe modunload netstat nm nslookup) ];

    return;
}

# Just status display message are commented because we are following KISS as different no. of status messages on
# different plats create unnecessary complexity for EDR
sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($patchlevel,$msg,$rpm_dir,$kret,$ksles,$padv,$kstring,$cpic,@f,$distro,@pkg_files,$pkg,$prod);
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

    if ($distro eq 'RHEL') {
        $padv->{cmd}{selinuxenabled}='/usr/sbin/selinuxenabled';
        if ($kstring =~ /el6/m) {
            if ($kret < 131) { # RHEL6u1 check
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.32-131.el6(RHEL6 U1) or higher is supported on RHEL6. Upgrade the OS to RHEL6 Update1 in order to install this product");
                $sys->push_error($msg);
                return '';
            }
        } elsif ($kstring =~ /el5/m) {
            if ($kret < 194) { # RHEL5u5 or above check
                $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.18-194.el5(RHEL5 U5) or higher is supported on RHEL5. Upgrade the OS to RHEL5 Update5 or higher in order to install this product");
                $sys->push_error($msg);
                return '';
            }
        }

    } elsif ($distro eq 'SLES') {
        $padv->{cmd}{selinuxenabled}='/usr/bin/selinuxenabld';

        #SLES 10 SP4 check
        #In 6.0, SLES 10 SP4 is supported,
        #SP3 kernel version is above 2.6.16.60-0.54.5
        #SP4 kernel version is above 2.6.16.60-0.85.1
        #For PATCHLEVEL is higher than SuSE 10 SP4 and SuSE11 SP1, maybe does not support

        $patchlevel=$sys->{patchlevel};

        if (($f[2]==16) && ($f[3] < 60)) {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.16.60-0.85(SLES10 SP4) or higher is supported on SuSE10. Upgrade the OS to SLES10 SP4 in order to install this product");
            $sys->push_error($msg);
            return '';
        }
        if (($f[2]==16) && ($f[3]==60) && ($f[5] < 85)) {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.16.60-0.85(SLES10 SP4) or higher is supported on SuSE10. Upgrade the OS to SLES10 SP4 in order to install this product");
            $sys->push_error($msg);
            return '';
        }

        #SLES 11 SP1 or above check
        if (($f[2]==27) || (($f[2]==32) && ($f[3] < 12))) {
            $msg=Msg::new("Kernel Release $kstring found on $sys->{sys} is not supported. Only Kernel Release 2.6.32.12(SLES11 SP1) or higher is supported on SuSE11. Upgrade the OS to SLES11 SP1 in order to install this product");
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

package Rel::UXRT60::RHEL5x8664;
@Rel::UXRT60::RHEL5x8664::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC60 SFCFSRAC60 SVS60 SFCFSHA60 SFHA60
                                SF60 VCS60 VM60 DMP60 FS60) ];
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFSYBASECE60));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, 'SFSYBASECE60');
    $rel->{platvers}=[ qw(2.6.18-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:3220,198,0,15
VRTSaslapm:0,0,0,1205
VRTScavf:686,80,0,0
VRTScps:21458,0,0,2
VRTSdbac:3323,69,0,396
VRTSdbed:50546,1,0,3
VRTSfsadv:11232,0,0,0
VRTSfssdk:1158,3,0,0
VRTSgab:3538,364,0,59
VRTSglm:61,0,0,310
VRTSgms:5,0,0,103
VRTSllt:2868,51,0,355
VRTSlvmconv:3,176,0,93
VRTSob:72932,0,0,206
VRTSodm:182,324,0,254
VRTSperl:116189,0,0,0
VRTSsfcpi60:4441,0,0,0
VRTSsfmh:89939,0,0,0
VRTSspt:25305,0,0,0
VRTSsvs:137303,0,0,0
VRTSvbs:47009,0,0,3
VRTSvcs:183121,8977,0,232
VRTSvcsag:2716,0,0,69
VRTSvcsdr:717,0,0,1
VRTSvcsea:12676,0,0,46
VRTSvlic:60,0,0,1208
VRTSvxfen:1085,41,0,677
VRTSvxfs:2991,17522,0,6191
VRTSvxvm:1600,55481,0,36795
_PKGSPACE_
    return;
}

package Rel::UXRT60::RHEL5ppc64;
@Rel::UXRT60::RHEL5ppc64::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SVS60 SFRAC60 SFSYBASECE60));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS60 SFRAC60 SFSYBASECE60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS60 SFRAC60 SFSYBASECE60));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS60 SFRAC60 SFSYBASECE60));
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
VRTSsfcpi60:3596,0,0,0
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

package Rel::UXRT60::RHEL6x8664;
@Rel::UXRT60::RHEL6x8664::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC60 SFCFSRAC60 SVS60 SFCFSHA60 SFHA60
                                SF60 VCS60 VM60 DMP60 FS60) ];
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
VRTSsfcpi60:4462,0,0,0
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

package Rel::UXRT60::SLES10x8664;
@Rel::UXRT60::SLES10x8664::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC60 SFSYBASECE60 SFCFSRAC60 SVS60 SFCFSHA60 SFHA60
                                SF60 VCS60 VM60 DMP60 FS60) ];

    $rel->{platvers}=[ qw(2.6.16-* 2.6.22-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:22455,199,0,15
VRTSaslapm:0,0,0,1110
VRTScavf:688,80,0,0
VRTScps:22305,0,0,2
VRTSdbac:8325,73,0,403
VRTSdbed:50623,1,0,3
VRTSfsadv:11212,0,0,0
VRTSfssdk:1206,3,0,0
VRTSgab:10893,361,0,67
VRTSglm:61,0,0,1021
VRTSgms:5,0,0,223
VRTSllt:6689,53,0,358
VRTSlvmconv:3,176,0,93
VRTSob:72932,0,0,206
VRTSodm:186,425,0,954
VRTSperl:116386,0,0,0
VRTSsfcpi60:4441,0,0,0
VRTSsfmh:89939,0,0,0
VRTSspt:25305,0,0,0
VRTSsvs:137303,0,0,0
VRTSvbs:47009,0,0,3
VRTSvcs:182279,8935,0,232
VRTSvcsag:2731,0,0,69
VRTSvcsdr:1762,0,0,1
VRTSvcsea:12480,0,0,46
VRTSvlic:62,0,0,1212
VRTSvxfen:11283,43,0,682
VRTSvxfs:3006,19868,0,17277
VRTSvxvm:1659,55090,0,45524
_PKGSPACE_
    return;
}

package Rel::UXRT60::SLES10ppc64;
@Rel::UXRT60::SLES10ppc64::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SVS60 SFRAC60));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS60 SFRAC60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS60 SFRAC60));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS60 SFRAC60));

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
VRTSsfcpi60:3596,0,0,0
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

package Rel::UXRT60::SLES11x8664;
@Rel::UXRT60::SLES11x8664::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;

    $rel->{upgradeprods} = [ qw(SFRAC60 SFCFSRAC60 SVS60 SFCFSHA60 SFHA60
                                SF60 VCS60 VM60 DMP60 FS60) ];

    $rel->{platvers}=[ qw(2.6.27-* 2.6.32-*) ];
    $rel->{pkgsspace}=<<"_PKGSPACE_";
VRTSamf:9518,202,0,15
VRTSaslapm:0,0,0,1275
VRTScavf:691,80,0,0
VRTScps:20977,0,0,2
VRTSdbac:7634,74,0,410
VRTSdbed:50623,1,0,3
VRTSfsadv:11212,0,0,0
VRTSfssdk:1303,3,0,0
VRTSgab:9211,378,0,80
VRTSglm:68,0,0,682
VRTSgms:8,0,0,136
VRTSllt:6435,53,0,362
VRTSlvmconv:3,176,0,93
VRTSob:72932,0,0,206
VRTSodm:197,455,0,555
VRTSperl:116961,0,0,0
VRTSsfcpi60:4441,0,0,0
VRTSsfmh:89939,0,0,0
VRTSspt:25305,0,0,0
VRTSsvs:137303,0,0,0
VRTSvbs:47009,0,0,3
VRTSvcs:162189,7104,0,232
VRTSvcsag:2854,0,0,69
VRTSvcsdr:1633,0,0,1
VRTSvcsea:10811,0,0,46
VRTSvlic:65,0,0,1191
VRTSvxfen:9104,44,0,687
VRTSvxfs:3021,20927,0,7455
VRTSvxvm:1678,50013,0,49351
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

package Rel::UXRT60::SLES11ppc64;
@Rel::UXRT60::SLES11ppc64::ISA = qw(Rel::UXRT60::Linux);

sub init_padv {
    my ($rel) = @_;
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SVS60 SFRAC60));
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SVS60 SFRAC60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, qw(SVS60 SFRAC60));
    $rel->{upgradeprods}=EDRu::arrdel($rel->{upgradeprods}, qw(SVS60 SFRAC60));

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
VRTSsfcpi60:3596,0,0,0
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


package Rel::UXRT60::SunOS;
@Rel::UXRT60::SunOS::ISA = qw(Rel::UXRT60::Common);

sub init_plat {
    my ($rel) = @_;

    $rel->{prods}=EDRu::arrdel($rel->{prods}, 'SFCFSRAC60');
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, 'VCS60') if ($rel->{oem});
    $rel->{upgradeprods} = [ qw(SFRAC60 SVS60 SFCFSHA60 SFHA60 SF60 VCS60 VM60 DMP60 FS60) ];

    $rel->{obsoleted_but_still_support_pkgs} = [qw(VRTSat50)];
    $rel->{'commands_need_be_checked'}=[ qw(adddrv fstyp getconf hostid isainfo kstat ldd mdb ndd netstat nm nohup nslookup pkgadd pkgchk pkginfo pkgrm prtconf prtdiag rmdrv route swap) ];
    $rel->{'commands_need_be_checked_for_5.9'}=[ qw(patchadd patchrm showrev) ];
    $rel->{'commands_need_be_checked_for_5.10'}=[ qw(bootadm patchadd patchrm showrev zoneadm) ];
    $rel->{'commands_need_be_checked_for_patchupgrade'}=[ qw(gunzip) ];
    $rel->{'commands_need_be_checked_for_patchupgrade_5.10'}=[ qw(patchadd) ];

    return;
}

sub platvers_sys {
    my ($rel,$sys) = @_;
    my ($script,$msg,$train_arch,$perm,$file,$web,$osupdatelevel,$perm_new,$cpic,$pkg_dir,$runlevel,$prod);

    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return '' if (Cfg::opt('ignorechecks'));

    # Check the Solaris Kernel.
    # For 6.0,
    # Solaris 10 32 bit is not supported
    if (($sys->{platvers} eq '5.10') && ($sys->{kerbit} == 32)) {
        $msg=Msg::new("$sys->{sys}: Solaris 10 32-bit is not supported. ");
        $sys->push_error($msg);
        $sys->set_value('stop_checks', 1);
        return '';
    }

    # Check the Solaris run-level.
    # Only run-level S, 2, 3 are supported.
    if (Cfg::opt(qw/install upgrade patchupgrade precheck uninstall/)) {
        $runlevel=$sys->padv->runlevel_sys($sys);
        if ($runlevel && $runlevel !~ /S|2|3/m) {
            $msg=Msg::new("$sys->{sys}: Current run-level $runlevel is not supported. Change the run-level to S, 2, or 3 and re-start the installation program");
            $sys->push_error($msg);
            $sys->set_value('stop_checks', 1);
            return '';
        }
    }

    # Check the Solaris Update version.
    # For 6.0,
    # Solaris 10 with Update 8 or later is supported(Revised for support 8, 9 and 10).
    if (Cfg::opt(qw/install upgrade patchupgrade precheck/)) {
        $osupdatelevel=$sys->{osupdatelevel};
        if ($sys->{platvers} eq '5.10') {
            if ($osupdatelevel && $osupdatelevel < 8) {
                $msg=Msg::new("Solaris 10 Update $osupdatelevel is installed on $sys->{sys}. It is strongly recommended to install Solaris 10 Update 8 or later");
                $sys->push_warning($msg);
            }
        }
    }

    #check permissions of /tmp directory.
    if (Cfg::opt(qw/install upgrade patchupgrade precheck/)) {
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
    if (!Cfg::opt('rootpath') && $sys->{zone} && Cfg::opt(qw(precheck install upgrade patchupgrade uninstall))) {
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
                # if precheck/install/upgrade/patchupgrade/uninstall, need halt the zones after jobs finished.
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
            $msg=Msg::new("Cannot install $cpic->{prod} on system $sys->{sys} as its architecture is $sys->{arch}. This release supports $train_arch.");
            $sys->push_error($msg);
            return '';
        }
    }
    return 1;
}

sub completion {
    my ($sys,$rootpath,$zone,$syslist);

    return unless (Cfg::opt(qw(precheck install upgrade patchupgrade uninstall)));

    $rootpath=Cfg::opt('rootpath');
    $rootpath=($rootpath) ? "-R $rootpath" : '';

    $syslist=CPIC::get('systems');
    for my $sys (@$syslist) {
        if (defined $sys->{cpi_booted_zones}) {
            for my $zone (@{$sys->{cpi_booted_zones}}) {
                $sys->cmd("_cmd_zoneadm -z $zone halt");
            }
        }

        $sys->cmd("_cmd_bootadm update-archive $rootpath 2>/dev/null") unless(Cfg::opt('precheck'));
    }
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

sub preinstall_sys {
    my ($rel,$rootpath,$sys);
    ($rel,$sys) = (@_);
    $rootpath=Cfg::opt('rootpath')||'';
    if (($rootpath) && ($sys->exists("$rootpath/tmp/AdDrEm.lck"))) {
        $sys->rm("$rootpath/tmp/AdDrEm.lck");
    }
    return;
}

package Rel::UXRT60::SolSparc;
@Rel::UXRT60::SolSparc::ISA = qw(Rel::UXRT60::SunOS);

sub init_padv {
    my ($rel) = @_;

    # Add LP
    my $mediapath=EDR::get('mediapath');
    if (-d "$mediapath/docs/ja") {
        $rel->{lp}=1;
        $rel->{verify_media}=0; # do not check release layout
        push(@{$rel->{prods}}, 'LP60');
    }

    $rel->{upgradeprods} = [ qw(SFRAC60 SVS60 SFSYBASECE60 SFCFSHA60 SFHA60 SF60 VCS60 VM60 DMP60 FS60) ];
    # List LP pkgs to uninstall
    $rel->{langpkgs}=[  qw(SYMCjalma SYMCzhlma VRTSatJA VRTSatZH VRTSjaap
                           VRTSjacav60 VRTSjacfd VRTSjacmc VRTSjacs60 VRTSjacsb
                           VRTSjacsd VRTSjacse60 VRTSjacsi VRTSjacsj VRTSjacsm
                           VRTSjacso VRTSjacsp VRTSjacss VRTSjacsu60 VRTSjacsw
                           VRTSjad2d VRTSjad2g VRTSjadb2 VRTSjadba60 VRTSjadbc
                           VRTSjadbd VRTSjadbe60 VRTSjadcm VRTSjafad VRTSjafag
                           VRTSjafas VRTSjafs60 VRTSjafsc VRTSjafsd VRTSjafsm
                           VRTSjagap VRTSjaico VRTSjamcm VRTSjampr VRTSjamsa
                           VRTSjaodm60 VRTSjaord VRTSjaorg VRTSjaorm VRTSjapbx
                           VRTSjasmf VRTSjaspq VRTSjasqd VRTSjasqm VRTSjavm60
                           VRTSjavmc VRTSjavmd VRTSjavmm VRTSjavrd VRTSjavvr
                           VRTSjaweb VRTSmualc VRTSmuap  VRTSmuc33 VRTSmucsd
                           VRTSmudcp VRTSmuddl VRTSmufp  VRTSmufsp VRTSmufsw
                           VRTSmulic32 VRTSmuob VRTSmuobg VRTSmuobw VRTSmusfm
                           VRTSmutep VRTSmuvmp VRTSmuvmw VRTSzhico VRTSzhpbx
                           VRTSzhsmf VRTSzhvm60 VRTSzhvmc VRTSzhvmd VRTSzhvmm) ];

    $rel->{platvers}=[ qw(5.10) ];
    $rel->{platreqs}=[ 'Solaris 10 Update 8, 9, 10 (64 bit only)' ];
    $rel->{upgradevers}=[ qw(5.0.3 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
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
VRTSob:92065,0,0,205
VRTSodm:1384,1,3,3
VRTSperl:106816,0,0,0
VRTSsfcpi60:7064,0,0,0
VRTSsfmh:95422,0,0,0
VRTSspt:21986,0,0,0
VRTSsvs:165709,0,0,0
VRTSvbs:54228,0,0,3
VRTSvcs:174185,7081,5,228
VRTSvcsag:4006,0,0,58
VRTSvcsea:18297,0,0,71
VRTSvlic:2852,0,0,2672
VRTSvxfen:320,177,3,2269
VRTSvxfs:40333,5366,4,5604
VRTSvxvm:6714,164020,20,28861
_PKGSPACE_
    return;
}

package Rel::UXRT60::Solx64;
@Rel::UXRT60::Solx64::ISA = qw(Rel::UXRT60::SunOS);

sub init_padv {
    my ($rel) = @_;
    $rel->{platvers}=[ qw(5.10) ];
    $rel->{platreqs}=[ 'Solaris 10 Update 8, 9, 10 (64 bit only)' ];
    $rel->{upgradevers}=[ qw(5.0.3 5.1) ];
    $rel->{latest_mp_name}{'5.0'}='5.0MP3';
    $rel->{prods}=EDRu::arrdel($rel->{prods}, qw(SFSYBASECE60));
    $rel->{menuprods}=EDRu::arrdel($rel->{menuprods}, 'SFSYBASECE60');
    $rel->{pkgsetprods}=EDRu::arrdel($rel->{pkgsetprods}, qw(SFSYBASECE60));
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
VRTSsfcpi60:4444,0,0,0
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
