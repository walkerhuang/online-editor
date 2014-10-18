package MYCPIC;
@MYCPIC::ISA = qw(CPIC);

sub main {
    my ($rel, $padv, $mediapath, $task, $prod) = @_;
    my (@subs, $cpic, @init);
    $cpic = MYCPIC->new();

    # initiation, systems must be run first to parse args and determine upgrade
    $cpic->initiation($rel, $padv, $mediapath, $task, $prod);
    @init = qw(install_useragreement options systems upgrade_useragreement);
    $cpic->run_subs(@init);
    @subs =
        (Cfg::opt('precheck'))  ? qw()
      : (Cfg::opt('postcheck')) ? qw(postcheck)
      : (Cfg::opt('install'))   ? qw(set_pkgs shutdown uninstall install licensing
      prestart_config shutdown startup poststart_config)
      : (Cfg::opt('patchupgrade')) ? qw(set_pkgs shutdown uninstall install licensing
      prestart_config startup poststart_config)
      : (Cfg::opt('upgrade'))
      ? qw(set_pkgs shutdown uninstall install licensing validate_tunables set_tunables_any set_tunables_prestart startup set_tunables_poststart)
      : (Cfg::opt('uninstall')) ? qw(set_pkgs shutdown uninstall)
      : (Cfg::opt('rollback'))  ? qw(set_pkgs shutdown rollback licensing prestart_config startup poststart_config)
      : (Cfg::opt('configure')) ? qw(licensing prestart_config shutdown startup
      poststart_config)
      : (Cfg::opt('license'))       ? qw(licensing)
      : (Cfg::opt("hotfix"))        ? qw(hotfix)
      : (Cfg::opt("restore"))       ? qw(restore_hotfix)
      : (Cfg::opt('start'))         ? qw(licensing startup)
      : (Cfg::opt('startstoptest')) ? qw(startstoptest)
      : (Cfg::opt('stop'))          ? qw(shutdown)
      :                               EDR::die('no task');
    $cpic->run_subs(@subs, 'completion');
    return;
}

sub prod_version_sys {
    my ($cpic, $sys) = @_;
    my ($prod, $prodname, $padv, $ivers, $msg, $opt, $cv, $installedprod, $rel, $noconfig_flag, $prior_rp_title);
    my ($basevers, $baseversi, $basevers_flag, $nums);

    # noconfig_flag is related with SF or VCS partial upgrade out of installed SFHA
    $sys           = Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $rel           = $sys->rel;
    $noconfig_flag = ($sys->{noconfig_sf} || $sys->{noconfig_vcs});
    return 1 if ($sys->{stop_checks});
    return 1 if ($rel->{lp});
    if ($cpic->{prod}) {
        $prod     = $sys->prod;
        $prodname = $prod->{abbr};
        $ivers    = $prod->version_sys($sys);
    } else {
        $prodname = 'Any product';
    }
    if ($rel->{type} eq "RP") {
        $nums     = @{$rel->{basevers}} - 1;
        $basevers = $rel->{basevers}[$nums];
    }
    $cv = EDRu::compvers($ivers, $prod->{vers}, 4) if ($ivers);

    # task        check whether product installed            check whether current version
    # install     X                                          X
    # upgrade     V                                          X
    # patchupgrade     V                                     X
    # uninstall   V                                          V
    # configure   V                                          V
    # start       V                                          V
    # stop        V                                          V
    # license     V                                          V
    # precheck    X                                          X
    if (Cfg::opt(qw(uninstall rollback configure start stop startstoptest postcheck license))) {
        if (!$ivers) {
            $msg = Msg::new("$prodname $prod->{vers} does not appear to be installed on $sys->{sys}");
            if (Cfg::opt(qw(uninstall license))) {
                $sys->push_warning($msg);
            } else {
                $sys->push_error($msg) unless (Cfg::opt('install') && Cfg::opt('configure'));
                return '';
            }
        } elsif ((${$sys->{upgradeprod}}[0] ne "") && (Cfg::opt("rollback")) && $cv) {

            # No warning message for RP as customers many times have only partial RP installed
            #$msg=Msg::new("$rel->{titlevers} does not appear to be installed on $sys->{sys}");
            #$sys->push_warning($msg);
        } elsif ((Cfg::opt("rollback")) && $sys->{prior_rp}) {
            $prior_rp_title = $rel->{prior_rp_title}{$sys->{prior_rp}};
            $msg            = Msg::new("$sys->{sys} will be rolled back to $prior_rp_title release");
            $sys->push_warning($msg);
        }

        # install/upgrade/patchupgrade/precheck below :
    } elsif (!$ivers) {

        # not installed
        if (Cfg::opt(qw(patchupgrade)) && (${$sys->{upgradeprod}}[0] eq '')) {
            return 1 if (Cfg::opt(qw(upgrade patchupgrade)) && $sys->{skip_versioncheck} && $cpic->{prod});
            $msg = Msg::new("$prodname does not appear to be installed on $sys->{sys}");
            $sys->push_stop_checks_error($msg);
            return '';
        } elsif (${$sys->{upgradeprod}}[0] ne '') {

            # cross stack upgrade/install
            $installedprod = $sys->prod(${$sys->{upgradeprod}}[0]);
            $ivers         = $installedprod->version_sys($sys);
            $cv            = EDRu::compvers($ivers, $installedprod->{vers}, 4);
            if ($cv == 2) {
                if (Cfg::opt('upgrade')) {
                    if (!$installedprod->upgradeable_version_sys($sys)) {
                        $msg = Msg::new(
"Upgrade from $installedprod->{abbr} $ivers to $prodname $prod->{vers} is not supported on $sys->{sys}");
                        $sys->push_error($msg);
                        return '';
                    }
                    if ($installedprod->zru_version_sys($sys)) {
                        $sys->set_value('zru_supported', 1);
                    } else {
                        $sys->set_value('zru_supported', 0);
                    }
                }
            } elsif ($cv == 1) {

                # more recent version is installed
                $msg = Msg::new(
                        "A more recent version of $installedprod->{abbr}, $ivers, is already installed on $sys->{sys}");
                $sys->push_warning($msg);
            }
        } elsif (Cfg::opt(qw(install))) {
            return 1;
        }
    } elsif ($cv == 0) {
        my $vcsagver = $sys->pkgvers('VRTSvcsag');
        my $upgrade_from_stratus = 0;
        if($vcsagver ne '6.0.200.000' && (Cfg::opt('installallpkgs') || Cfg::opt('installrecpkgs'))){
            $msg = Msg::new("$prodname version $ivers is already installed on $sys->{sys}.\nPlease press enter to continue and install the VMware enablement packages for Linux virtual machines.");
            $upgrade_from_stratus = 1;
        }else{
            $msg = Msg::new("$prodname version $ivers is already installed on $sys->{sys}");
        }

        # When product already installed and user is performing RU phase 2.
        # Now RU's precheck won't call $cpic->prod_version_sys
        # And the option 'upgrade_nonkernelpkgs' will be determined after user confirmed cluster info.
        if (Cfg::opt('upgrade_nonkernelpkgs')) {
            $sys->set_value('zru_supported', 1);
            return 1;
        }
        if (!$noconfig_flag) {
            if($upgrade_from_stratus){
                $sys->push_warning($msg);
            }else{
                if (Cfg::opt('upgrade')) {
                    $sys->push_error($msg);
                    return '';
                } else {
                    $sys->push_warning($msg);
                }
            }
        } else {
            if ($sys->{prod_to_upgrade} && $sys->{prod_to_upgrade}->zru_version_sys($sys)) {
                $sys->set_value('zru_supported', 1);
            } else {
                $sys->set_value('zru_supported', 0);
            }
        }
    } elsif (Cfg::opt("patchupgrade") && $rel->{nopkgs}) {

        # patchonly release version check
        # Match if basevers
        for $baseversi (@{$rel->{basevers}}) {
            if (!EDRu::compvers($ivers, $baseversi, 3)) {
                $basevers_flag = 1;
            }
        }
        unless ($basevers_flag) {
            $msg = Msg::new("$prodname $basevers does not appear to be installed on $sys->{sys}");
            $sys->push_stop_checks_error($msg);
        }
    } elsif ($cv == 1) {

        # more recent version is installed
        $msg = Msg::new("A more recent version of $prodname, $ivers, is already installed on $sys->{sys}");
        $sys->push_warning($msg);
    } elsif (   (Cfg::opt(qw(responsefile)))
             && (!$prod->{responsefileupgradeok})) {

        # prior version installed, can't upgrade w responsefile
        # questions being asked is almost inevitable
        # installonly may need to run start/stop/config routines to upgrade
        $opt = (Cfg::opt('responsefile')) ? '-responsefile' : '-install';
        $msg = Msg::new(
"$prodname version $ivers is installed on $sys->{sys}.  Upgrading $prodname is not supported using the $opt option");
        $sys->push_error($msg);
        return '';

        # Code to check if upgrade from current version is supported or not is yet to be added (UGVERS)
    } else {
        return '' if (!$sys->rel->upgradevers_sys($sys));
        if ($prod->zru_version_sys($sys)) {
            $sys->set_value('zru_supported', 1);
        } else {
            $sys->set_value('zru_supported', 0);
        }
    }
    return 1;
}

1;
