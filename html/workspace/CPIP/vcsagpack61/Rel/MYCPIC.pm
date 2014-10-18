package MYCPIC;
@MYCPIC::ISA = qw(CPIC);

sub main {
    my ($rel,$padv,$mediapath,$task,$prod) = @_;
    my (@subs,$cpic,@init);
    $cpic=MYCPIC->new();
    $cpic->initiation($rel, $padv, $mediapath, $task, $prod);
    @init=qw(install_useragreement options systems upgrade_useragreement);
    $cpic->run_subs(@init);
    @subs = (Cfg::opt('precheck')) ? qw() : 
       #(Cfg::opt('install')) ? qw(set_pkgs shutdown uninstall install licensing prestart_config shutdown startup poststart_config) :
       (Cfg::opt('install')) ? qw(set_pkgs shutdown uninstall install prestart_config startup ) :
       (Cfg::opt('upgrade')) ? qw(set_pkgs shutdown uninstall install prestart_config startup ) :
       (Cfg::opt('uninstall')) ? qw(set_pkgs shutdown uninstall) :
       (Cfg::opt('configure')) ? qw(prestart_config shutdown prestart_config) :
       #(Cfg::opt('license')) ? qw(licensing) :
       (Cfg::opt("hotfix")) ?  qw(hotfix) : EDR::die ('no task');
    $cpic->run_subs(@subs,'completion');
    return;
}

sub prod_version_sys {
    my ($cpic,$sys)=@_;
    my ($prod,$prodname,$padv,$ivers,$msg,$opt,$cv,$rel,$noconfig_flag);
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $rel=$sys->rel;
    if ($cpic->{prod}) {
        $prod=$sys->prod;
        $prodname=$prod->{abbr};
        $ivers=$prod->version_sys($sys);
    } else {
        $prodname = 'Any product';
    }
    if (!$ivers) { #not installed
        if (Cfg::opt(qw(license upgrade configure  uninstall ))) {
            $msg=Msg::new("$prodname $prod->{vers} does not appear to be installed on $sys->{sys}");
            $sys->push_error($msg) unless (Cfg::opt('install') && Cfg::opt('configure'));
            return 0;
        }
    }else{
        $cv=EDRu::compvers($ivers,$prod->{vers},4);
        if ($cv==2) { #old version
            if (Cfg::opt('upgrade')) {
                if (!$prod->upgradeable($ivers)) {
                    $msg=Msg::new("Upgrade from $prod->{abbr} $ivers to $prodname $prod->{vers} is not supported on $sys->{sys}");
                    $sys->push_error($msg);
                    return 0;
                }
            } elsif (Cfg::opt('install')) {
	            $msg=Msg::new("Install from $prod->{abbr} $ivers to $prodname $prod->{vers} is not supported, please choose upgrade instead.");
	            $sys->push_error($msg);
	            return 0;
	    }
        } elsif ($cv==1) {
            # more recent version is installed
            $msg=Msg::new("A more recent version of $prod->{abbr}, $ivers, is already installed on $sys->{sys}");
            $sys->push_error($msg);
            return 0;
        } elsif ($cv==0) {
            if (Cfg::opt('upgrade')) {
                $msg=Msg::new("$prodname version $ivers is already installed on $sys->{sys}");
                $sys->push_error($msg);
                return 0;
            }
        } 
    }
    return 1;
}

sub systems_need_reboot{
    return [];
}

# Display pkg name and description
sub cli_display_instpkgs {
    my $cpic=shift;
    my (@rebootsys,$sys0,$string_rebootsys,$ref_allsystem_pkgs,$ref_allsystem_patches,$ref_remaining,$sys,$cfg,$prod,$prodname,$pdfrs,$msg,$pkg,$pkgi,$patchi,$patch,$n,$rel);
    $prod=$cpic->prod;
    $rel=$cpic->rel;
    $n=0;
    $cfg=Obj::cfg();
    $sys0=$cpic->{systems}->[0];
    $pdfrs=Msg::get('pdfrs');
    $prodname=$prod->{name};
    for my $pkgi (@{$cpic->{installpkgs}}) {
        push(@{$ref_allsystem_pkgs},$pkgi);
        for my $sys (@{$cpic->{systems}}) {
            $ref_allsystem_pkgs=EDRu::arrdel($ref_allsystem_pkgs,$pkgi)
                  unless (EDRu::inarr($pkgi,@{$sys->{installpkgs}}));
        }
    }
    for my $patchi (@{$cpic->{installpatches}}) {
        push(@{$ref_allsystem_patches},$patchi);
        for my $sys (@{$cpic->{systems}}) {
            $ref_allsystem_patches=EDRu::arrdel($ref_allsystem_patches,$patchi)
                unless (EDRu::inarr($patchi,@{$sys->{installpatches}}));
        }
    }
    Msg::title();
    unless ($#$ref_allsystem_pkgs < 0) {
        if (Cfg::opt('upgrade')) {
             $msg=Msg::new("The following $prodname $pdfrs will be installed or upgraded on all systems:");
        } else {
             $msg=Msg::new("The following $prodname $pdfrs will be installed on all systems:");
        }
        $msg->printn;
        $n=$cpic->list_packages($sys0,$n,$ref_allsystem_pkgs);
    }

    unless ($#$ref_allsystem_patches < 0) {
        Msg::n();
        $msg=Msg::new("The following $prodname patches will be installed on all systems:\n");
        $msg->print;
        $n=$cpic->list_patches($sys0,$n,$ref_allsystem_patches);
    }
    
    my $nopkg2install = 1;
    for my $sys (@{$cpic->{systems}}) {
        if($#{$sys->{installpkgs}} >=0){
            $nopkg2install = 0;
            last;
        }
    }
    if ($nopkg2install){
        $msg=Msg::new("No $pdfrs or patches will be installed on all systems\n");
        $msg->print;
        # product is already installed, do not continue if not resumed from previous installer process.
        if (Cfg::opt("responsefile") !~ /exitfile/ && !Cfg::opt("makeresponsefile")) {
            $cpic->completion();
        }
    }

    for my $sys (@{$cpic->{systems}}) {
        $ref_remaining=EDRu::arrdel($sys->{installpkgs},@{$ref_allsystem_pkgs});
        if($#$ref_remaining >= 0) {
            Msg::n();
            if (Cfg::opt('upgrade')) {
                $msg=Msg::new("The following $prodname $pdfrs will be installed or upgraded on $sys->{sys}:");
            } else {
                $msg=Msg::new("The following $prodname $pdfrs will be installed on $sys->{sys}:");
            }
            $msg->printn;
            $n=$cpic->list_packages($sys,$n,$ref_remaining) if (@{$ref_remaining});
        }
        $ref_remaining=EDRu::arrdel($sys->{installpatches},@{$ref_allsystem_patches});
        if($#$ref_remaining >= 0) {
            Msg::n();
            if (Cfg::opt('upgrade')) {
                $msg=Msg::new("The following $prodname patches will be installed or upgraded on $sys->{sys}:");
            } else {
                $msg=Msg::new("The following $prodname patches will be installed on $sys->{sys}:");
            }
            $msg->printn;
            $n=$cpic->list_patches($sys,$n,$ref_remaining) if (@{$ref_remaining});
        }
        if (defined $sys->{requirerebootpkgspatches}) {
            push(@rebootsys,$sys->{sys});
        }
    }
    if(@rebootsys) {
        $string_rebootsys=join(' ',@rebootsys);
        Msg::n();
        if (!EDRu::inarr('configure',@{$rel->{args_task}}) || Cfg::opt('upgrade')) {
             $msg=Msg::new("At least one package will require a reboot on systems $string_rebootsys after installation. Reboot after $cpic->{script} has completed.");
        } else {
             $msg=Msg::new("At least one package will require a reboot on systems $string_rebootsys prior to configuration. Reboot and run '$cpic->{script} -configure' after $cpic->{script} has completed.");
        }
        $msg->print;
    }
    Msg::prtc();
    Msg::n();
    return '';
}
1;
