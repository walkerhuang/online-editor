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
package Rel::UXRT601::Common;
use strict;

# main sub for product licensing
sub licensing {
    my ($rel,$back_from_key_menu) = @_;
    my ($cpic,$msg,$web,$edr,$licensed,$sys,$ayn,$rt,$license_status,$prod);

    $cpic=Obj::cpic();
    $cpic->completion() if (Cfg::opt('nolic'));

    $edr=Obj::edr();
    $prod = $cpic->prod;

    # doesn't use default value when licensing
    Cfg::unset_opt('silent');

    while(1) {
        return '' if (!$prod->licensed);
        return '' if (Cfg::opt('rootpath')||$prod->{nolic});

        $license_status=$rel->licensing_status(1);
        $rel->{license_status} = $license_status;
        # return if at least one system doesn't have VRTSvlic installed.
        return '' unless ($#{$license_status->{vlic_uninstalled}} < 0);
        $licensed = $license_status->{all_licensed} if (!Cfg::opt('makeresponsefile'));

        Cfg::unset_opt('vxkeyless') unless (!$back_from_key_menu);
        if (Cfg::opt(qw(upgrade patchupgrade license))) {
            $rel->restore_keyless_keys();
        }
        if (Cfg::opt(qw(install license upgrade)) || (!$licensed && Cfg::opt(qw(start patchupgrade configure)))) {
            if ($licensed) {
                last if (($prod->{prod} eq 'SF') && (Cfg::opt('prodmode') eq 'SF Basic'));
                if ((!$back_from_key_menu) && Cfg::opt('install')) {
                    return '' if ($rel->cli_ask_additional_license($prod) eq 'N');
                }
            }
            $rel->cli_license_option() unless (Cfg::opt('upgrade') || 
                                               (($prod->{prod} eq 'SF') && (Cfg::opt('prodmode') eq 'SF Basic')));
            $rt = '';
            $rt = $rel->license_products('', $licensed) if(!Cfg::opt('bypass_licensing'));
            if(Obj::webui()){
                $web = Obj::web();
                if($web->{invalid_license}){
                    delete $web->{invalid_license};
                    next;
                }
            }
            return '' if (Cfg::opt('makeresponsefile') && ($rt eq $edr->{msg}{back}));
            next if($rt eq $edr->{msg}{back});
        }
        last;
    }
    return '';
}

# checking already installed keys on all the systems
# won't call read_licenses_sys if $donotquery is not set to 1
sub licensing_status {
    my ($rel,$donotquery) = @_;
    my ($cpic,%license_status,$edr,$unlicensed_sys,$licensed,$sys,$key,$licensed_sys,$status,$pkg,$systems,$prod);

    $cpic=Obj::cpic();
    # Check VRTSvlic status first.
    # if one system doesn't have it installed,
    # return to the caller without check license key status
    for my $sys (@{$cpic->{systems}}) {
        $pkg=$sys->pkg(licensing_pkg());
        $key = ($pkg->version_sys($sys)) ? 'vlic_installed' : 'vlic_uninstalled';
        push @{$license_status{$key}}, $sys->{sys};
    }
    if ($#{$license_status{vlic_uninstalled}} >= 0) {
        $license_status{summary} ="$pkg->{pkg} is NOT installed on ";
        $license_status{summary}.=join ',', @{$license_status{vlic_uninstalled}};
        return \%license_status;
    }

    $edr=Obj::edr();
    $systems=0;
    $rel->{unlicensed_sys}='';
    for my $sys (@{$cpic->{systems}}) {
        $systems++;
        $rel->read_licenses_sys($sys) unless ($donotquery);
        $prod=$sys->prod($cpic->{prod});
        $licensed = $prod->licensed_sys($sys) if ($prod->licensed);
        $key = (!$licensed) ? 'unlicensed' : 'licensed';
        push @{$license_status{$key}}, $sys->{sys};
        $rel->{unlicensed_sys}||=$sys if ($key eq 'unlicensed');
    }

    if ($#{$license_status{licensed}} >= 0) {
        $licensed = 1;
        $licensed_sys = 'Licensed: ';
        $licensed_sys .= join ', ', @{$license_status{licensed}};
    }
    if ($#{$license_status{unlicensed}} >= 0) {
        $licensed = 0;
        $unlicensed_sys  = 'Unlicensed: ';
        $unlicensed_sys .= join ', ', @{$license_status{unlicensed}};
    }

    $status = ($systems > 1) ? 'The systems are ' : 'The system is ';
    if ($#{$license_status{licensed}} +1 == $systems) {
        $license_status{all_licensed} = 1;
        $license_status{all_unlicensed} = 0;
        $status .= 'all ' if ($systems > 1);
        $status .= 'licensed ';
    } elsif ($#{$license_status{unlicensed}} +1 == $systems) {
        $license_status{all_licensed} = 0;
        $license_status{all_unlicensed} = 1;
        $status .= 'all ' if ($systems > 1);
        $status .= "$edr->{tput}{bs}Unlicensed$edr->{tput}{be}";
    } else {
        #$status .= "not all " if ($systems > 1);
        #$status .= "licensed ";
        $status = "$licensed_sys $edr->{tput}{bs}$unlicensed_sys$edr->{tput}{be}";
    }
    $license_status{summary} = $status;

    return \%license_status;
}

# register product license(s) and make sure
# the $cpic->prod is licensed before exiting
sub license_products {
    my ($rel,$prod_level,$licensed) = @_;
    my ($cpic,$pkgdir,$msg,$sitelic,$cfg,$lictype,$web,$edr,$sys,$ayn,$padv,$key,$rt,$keytype,$nlsys,$prodname,$pkg,$lic_ver_update,$prod);
    $edr=Obj::edr();
    $web=Obj::web();
    $cpic=Obj::cpic();
    if (Obj::webui()) {
        $web->{licensed} = $licensed;
        $web->web_script_form('license');
    }

    #return "" if (Cfg::opt("bypass_licensing"));
    # return with vxkeyless version of cli_licensing if vxkeyless is preferred
    return $rel->license_products_vxkeyless($prod_level) if (Cfg::opt('vxkeyless'));

    $prod=$cpic->prod;
    # unlicensed product
    return '' unless ($prod->licensed || (!Cfg::opt('upgrade')));
    return '' if (Cfg::opt('rootpath')||$prod->{nolic});
    return '' if (Cfg::opt(qw(precheck uninstall stop)));
    $cfg=Obj::cfg();
    #Msg::title();
    # check licensing to determine uninstall pkgs for mode based products
    unless (Cfg::opt('makeresponsefile')) {
        $msg=Msg::new("Checking system licensing\n");
        $msg->bold();
        if (Cfg::opt(qw(precheck upgrade patchupgrade uninstall configure stop start))) {
            for my $sys (@{$cpic->{systems}}) {
                $rel->read_licenses_sys($sys);
                $prod=$sys->prod($cpic->{prod});
                $prod->licensed_sys($sys);
            }
        }

        if ($cpic->{fromdisk}) {
            for my $sys (@{$cpic->{systems}}) {
                $pkg=$sys->pkg(licensing_pkg());
                #$cv=$cpic->tsub("pkg_getinstvers_sys", $sys, $pkg);
                $nlsys.="$sys->{sys} " unless ($pkg->version_sys($sys));
            }
            if ($nlsys) {
                $msg=Msg::new("VRTSvlic is not installed on systems $nlsys");
                $msg->die();
            }
        } else {
            for my $sys (@{$cpic->{systems}}) {
                $prod=$sys->prod($cpic->{prod});
                $pkgdir=$rel->pkgs_patches_dir('pkgpath');;
                $pkg=$sys->pkg(licensing_pkg());
                $padv=$sys->padv;
                $pkg->{file}||=$padv->media_pkg_file($pkg, $pkgdir);
                $pkg->{vers}||=$padv->media_pkg_version($pkg, $pkgdir);
            }

            # install or upgrade the licensing packages, if necessary
            # install_vlic($cpic);
        }

        # ensure all products are licensed
        # FIX update this later to read all systems, then license all systems
        # FIX update this to properly deal with -unattended option
        if (Cfg::opt(qw(responsefile precheck))) {
            for my $sys (@{$cpic->{systems}}) {
                $prod=$sys->prod($cpic->{prod});
                $prodname=$prod->{abbr};
                for my $key (@{$cfg->{keys}{$sys->{sys}}}) {
                    $rel->register_key_sys($sys,$key);
                }
                $rel->read_licenses_sys($sys);
                next if (!$prod->licensed);
                $rt = $prod->licensed_sys($sys);
                $rt =~s/\s+//g; 
                if (!$rt) {
                    $msg=Msg::new("$prodname is not licensed on $sys->{sys}\n");
                    $msg->die;
                } elsif (($rt =~ /^\d+/) && (EDRu::compvers($rt,$rel->{license_ver}) == 2)) {
                    $msg=Msg::new("$prodname license version $rt is not updated to $rel->{license_ver} on $sys->{sys}. It's recommended to upgrade to a $rel->{license_ver} key.\n");
                    $msg->warning;
                }
           }
        } else {
           $lic_ver_update = 0;
           for my $sys (@{$cpic->{systems}}) {
               $prod=$sys->prod($cpic->{prod});
               $rt = $prod->licensed_sys($sys);
               $rt =~s/\s+//g; 
               if (!$sys->{special_lic}) {
                   # SF Basic license key support.
                   # If the .key file is present, read the key
                   # Reset the PABBR and PNAME to SF Basic
                   if (($prod->{prod} eq 'SF') && (Cfg::opt('prodmode') eq 'SF Basic')) {
                       $key=$rel->read_sfbasic_key();
                       if ($key && (!EDRu::inarr($key, @{$cpic->{allsyskeys}}))) {
                           push(@{$cpic->{allsyskeys}}, $key);
                       }
                   } elsif (!$rt) {
                       $msg=Msg::new("$prod->{abbr} is not licensed on $sys->{sys}\n");
                       $msg->print;
                   } elsif (($rt =~ /^\d+/) && (EDRu::compvers($rt,$rel->{license_ver}) == 2)) {
                       $msg=Msg::new("$prod->{abbr} license version $rt is not updated to $rel->{license_ver} on $sys->{sys}. It's recommended to upgrade to a $rel->{license_ver} key.\n");
                       $msg->warning;
                       $lic_ver_update = 1;
                   }
               }
           }
        }
    }
    $prod=$cpic->prod;
    $sys=$cpic->{systems}[0];
    $rt = $rel->add_license_key();
    return $rt if($rt eq $edr->{msg}{back});
    return '' if (($prod->{prod} eq 'SF') && (Cfg::opt('prodmode') eq 'SF Basic'));
    $rel->cli_add_additional_license_key($sys) if ((!Cfg::opt('upgrade')) || $lic_ver_update);
    $prod->update_prod();
    return;
}

# used for asking addtional key
# returns y/n
sub cli_ask_additional_license {
    my ($rel,$prod) = @_;
    my ($msg,$ayn,$prodname);

    $prodname=$prod->{abbr};
    $msg=Msg::new("$prodname is licensed on all systems. Do you wish to enter additional licenses?");
    if (Cfg::opt('makeresponsefile')) {
        $msg=Msg::new("Do you wish to enter additional licenses?");
    }
    $ayn=$msg->aynn(undef,0);
    Msg::n();
    return $ayn;
}

# return the vlic pkg name defined in CPIP
sub licensing_pkg {
    return 'VRTSvlic32';
}

# accept entry of additional licenses, such as feature licenses
sub cli_add_additional_license_key {
    my ($rel,$sys) = @_;
    my ($cpic,$keys,$prod,$msg,$edr,$ayn,$key);

    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $prod=$cpic->{prod};
    while ($ayn ne 'N') {
        $msg=Msg::new("Do you wish to enter additional licenses?");
        $ayn=$msg->aynn(undef,1);
        last if ($ayn eq $edr->{msg}{back});
        if ($ayn eq 'Y') {
            if (!Cfg::opt('vxkeyless')) {
                while (!$keys) {
                    $key=$rel->ask_license_key($sys);
                    if ($key eq $edr->{msg}{back}) {
                        $ayn=$edr->{msg}{back};
                        last;
                    }
                    $keys=$rel->valid_license_key($sys,$key);
                }
                $rel->add_license_key($key) unless (Cfg::opt('makeresponsefile'));
                $keys='';
            } else {
                return $rel->license_products_vxkeyless();
            }
        }
    }

    if ($ayn eq $edr->{msg}{back}) {
        $key=(Cfg::opt(qw(install configure license))) ? 1 : 0;
        $rel->licensing($key);
    } elsif ($#{$cpic->{systems}} > 0) {
        # $ayn should be "N" and there are >=2 systems in the cluster
        # register $sys's $prod keys onto other systems, just in case
        # any of them are not on those systems.
        #
        #$rel->register_keys_on_systems();
    }
    return;
}

sub web_license_key {
    my ($rel) = @_;
    my ($cpic,$web,$sys1,$msg,$key,$prod);
    $cpic=Obj::cpic();
    $web = Obj::web();
    $sys1=$cpic->{systems}[0];
    $prod=$sys1->prod($cpic->{prod});
    while(1){
        if (!$web->param('prod_key')) {
            $web->wait_for('submit');
            $web->{submit} = Web::json_to_obj($web->read_from('submit'));
            if ($web->param('license_mode') eq 'keyless') {
                Cfg::set_opt('vxkeyless'); # use keyless licesing
                $web->set_prod_mode();
                $web->set_prod_option();
                return $rel->license_products_vxkeyless();
            }
        } 
        if(!$web->{submit}{license_mode}){
            $web->purge('submit');
            last;
        };

        $key = $web->param('prod_key');
        delete $web->{submit}{license_mode};
        delete $web->{lic_result};
        delete $web->{submit}{prod_key};
        $web->purge('submit');
        
        if(!$rel->valid_license_key($sys1, $key)){
            $web->{invalid_license} = 1;
            $msg = Msg::new("$key is a invalid license key");
            $web->{lic_result}=$msg->{msg};
            $web->write_status();
            next;
        }
        for my $lsys (@{$cpic->{systems}}) {
            $rel->license_sys($lsys, $key);
            $rel->read_licenses_sys($lsys);
            if(!$prod->licensed_sys($lsys)){
                $web->{invalid_license} = 1;
                $web->{lic_result} = Msg::new("$web->{licensed_prodname} is licensed. ")->{msg} if ($web->{licensed_prodname});
                $msg = Msg::new(" $prod->{abbr} is not licensed ");
                $web->{lic_result}.=$msg->{msg};
                $web->write_status();
                delete $web->{licensed_prodname};
                last;
            }
            $web->{invalid_license} = 0;
        }
        next if($web->{invalid_license} == 1);
        $web->{lic_result}='valid';
        $web->write_status();
    }
}
# add a specific prod key to a system
# normally called by add_license_key
sub add_license_key_sys {
    my ($rel,$sys,$key) = @_;
    my ($cpic,$prod,$msg,$edr,$loop_trigger);
    return '' unless ($sys);
    $loop_trigger=1 if (Cfg::opt('makeresponsefile'));
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $prod=$sys->prod($cpic->{prod});
    return unless ($prod->licensed);
    if ($key && ($key ne $edr->{msg}{back}) && $rel->valid_license_key($sys, $key) && !Cfg::opt('makeresponsefile')) {
        $rel->license_sys($sys, $key);
        $rel->read_licenses_sys($sys);
    }

    while ($loop_trigger || !$prod->licensed_sys($sys)) {
        $key=$rel->ask_license_key($sys);
        if ($key eq $edr->{msg}{back}) {
            last;
        }
        if (!Cfg::opt('makeresponsefile') && $rel->valid_license_key($sys, $key)) {
            $rel->license_sys($sys, $key);
            $rel->read_licenses_sys($sys);
        }
        $loop_trigger=0 if (Cfg::opt('makeresponsefile')); # to get loop executed only once
        if (Obj::webui()) {
            last;
        }
    }
    return $key;
}

# add a specific prod key to all systems
# via calling add_license_key_sys
sub add_license_key {
    my ($rel,$key) = @_;
    my ($cpic,$msg,$edr,$prod,$sys,$lsys,$license_status,$prodname,$web);
    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $web = Obj::web();
    $sys=$rel->{unlicensed_sys};
    $sys||=$cpic->{systems}[0];
    $rel->{unlicensed_sys}=$sys if (Cfg::opt('makeresponsefile'));
    $prod=$cpic->prod;
    $prodname =$prod->{abbr};

    # update all systems with the licenses defined in @{$cpic->{allsyskeys}}
    for my $lsys (@{$cpic->{systems}}) {
        last if (Cfg::opt('makeresponsefile'));
        $rel->license_sys($lsys);
        $rel->read_licenses_sys($lsys);
    }

    $license_status=$rel->licensing_status();
    if (!Cfg::opt('makeresponsefile')) {
        if (!$license_status->{all_licensed}) {
            $sys=$rel->{unlicensed_sys};
        } elsif (!$key) {
            $msg=Msg::new("$prodname is licensed on the systems");
            $msg->print;
        }
    }
    if (Obj::webui()){
        if ($web->param('license_mode')){
            $rel->web_license_key($key);
        }
    } else {
        $key=$rel->add_license_key_sys($sys, $key);
        if($key eq $edr->{msg}{back}){
            return $key;
        }
        if ($key && (!Cfg::opt('makeresponsefile'))) {
            for my $lsys (@{$cpic->{systems}}) {
                next if ($lsys eq $sys);
                $rel->add_license_key_sys($lsys, $key);
            }
        }
    }

    return if ((Cfg::opt(qw(responsefile precheck))) || ($prod->{basic}));
    for my $lsys (@{$cpic->{systems}}) {
        $rel->license_special_key($lsys, $prod);
    }
    return;
}

# seperated from license_sys, only accept new license keys for $sys
sub cli_ask_license_key {
    my ($rel,$sys) = @_;
    my ($cpic,$msg,$cfg,$prod,$key,$license_status,$help,$prodname,$registered_keys);

    $cpic=Obj::cpic();
    $prod=$cpic->prod;
    $cfg=Obj::cfg();
    # If Mode is SF Basic, then do not ask for the license key
    if (!$prod->{basic}) {
         $prodname=$prod->{abbr};
         $help=Msg::new("At least one $prodname key should be entered if $prodname is not licensed on all systems.\nEnter 'b' to go back to the main license menu and enable keyless licensing.");

         while (1) {
             if (($prod->{prod} eq 'SF') && (Cfg::opt('prodmode') eq 'SF Basic')) {
                 $key=$rel->read_sfbasic_key();
                 $registered_keys=$rel->licensed_keys_sys($sys);

                 $key='' if (EDRu::inarr($key, @$registered_keys));
                 last if ($key && !(EDRu::inarr($key, @{$cfg->{keys}{$sys->{sys}}}) ||
                                    EDRu::inarr($key, @{$cpic->{allsyskeys}})));
                 $key='';
             }
             $license_status=$rel->licensing_status();
             if (!Cfg::opt('makeresponsefile')) {
                 if (!$license_status->{all_licensed}) {
                     $msg=Msg::new("$prodname is unlicensed on all systems");
                 } else {
                     $msg=Msg::new("$prodname is licensed on all systems");
                 }
                 $msg->printn;
             }
             $msg=Msg::new("Enter a $prodname license key:");
             $key=$msg->ask(undef,$help,1);
             if (Cfg::opt('makeresponsefile') && $key) {
                 for my $lsys (@{$cpic->{systems}}) {
                     push(@{$cfg->{keys}{$lsys->{sys}}}, $key) if (!EDRu::inarr($key, @{$cfg->{keys}{$lsys->{sys}}}));
                 }
                 last;
             }
             last if ($key && (!EDRu::inarr($key, @{$cfg->{keys}{$sys->{sys}}})));
             $msg=Msg::new("$key already registered");
             $msg->printn;
         }
     }
     return $key;
}

# accept input from either CLI or web for a license key
sub ask_license_key {
    my ($rel,$sys,$prod) = @_;
    my ($web,$key);
    $web=Obj::web();

    $key=$rel->cli_ask_license_key($sys);
    if (!$key && Obj::webui()) {
        $key=$rel->web_ask_license_key();
    }

    return $key;
}

# seperated from license_sys, validating a provided key on the provided $sys
sub license_special_key {
    my ($rel,$sys) = @_;
    my ($cpic,$msg,$sitelic,$cfg,$lictype,$keytype,$prodname,$licupi,$prod);

    return '' if (!$sys);
    $cpic=Obj::cpic();
    $prod=$cpic->prod;
    $prodname=$prod->{abbr};

    if (!$sys->{special_lic}) {
        # display key info
        $licupi=$prod->{licupi};
        $cfg=Obj::cfg();
        $licupi||=$cfg->{upi};
        $lictype=prod_feature_values_sys($cpic,$sys,$licupi,'License Type');
        $sitelic=prod_feature_values_sys($cpic,$sys,$licupi,'Site License');
        $keytype=keytype($cpic,$lictype,$sitelic);
        return '' if (!$keytype);
        $msg=Msg::new("$keytype $prodname license registered on $sys->{sys}");
        $msg->print;
    }
    return;
}

# register a provided key on a provided system after verifying its validity
# save it to @{$cpic->{allsyskeys}} if it is a DEMO or SITE key
# feed the web installer with the results
sub license_sys {
    my ($rel,$sys,$key) = @_;
    my ($cpic,$msg,$sitelic,$lictype,$web,$valid,$allsyskey,$prod);
    return '' if (Cfg::opt('makeresponsefile'));
    $web=Obj::web();
    $cpic=Obj::cpic();

    for my $allsyskey (@{$cpic->{allsyskeys}}) {
        $rel->register_key_sys($sys,$allsyskey);
    }
    $prod=$cpic->prod;
    return '' if (!$key);
    $valid=$rel->valid_license_key($sys, $key);
    if ($valid) {
       $rel->register_key_sys($sys,$key);
       # save key to register on all systems, if DEMO or SITE
       $lictype=$sys->cmd("_cmd_vxlicrep -k $key| _cmd_grep License.Type");
       $sitelic=$sys->cmd("_cmd_vxlicrep -k $key| _cmd_grep Site.License");
       push(@{$cpic->{allsyskeys}},$key) if
          ((($lictype=~/DEMO/m) || ($sitelic=~/YES/m)) &&
          (!EDRu::inarr($key,@{$cpic->{allsyskeys}})));

    } else {
       $msg=Msg::new("$key is not a valid license key");
       $msg->print;

       $web->{lic_result}=$msg->{msg};
    }

    return;
}

# register vxkeyless key for a specific product
# the $prod_level is for vxkeyless only, with a default value setting to the highest prod key
sub license_products_vxkeyless {
    my ($rel,$prod_level) = @_;
    my ($cpic,$msg,$edr,$sys,$mtask,$prodname,$prod);

    $edr=Obj::edr();
    $cpic=Obj::cpic();
    return '' unless ($cpic->prod->licensed);
    $msg=Msg::new("Checking system licensing");
    $msg->bold();
    $rel->restore_keyless_keys() if (Cfg::opt(qw(upgrade patchupgrade license)));
    $prod_level=~s/\s+//mg;
    $prod_level||=$rel->get_installed_prod_vxkeyless_highest_key();
    if (Cfg::opt(qw(install configure patchupgrade start license))) {
        $mtask=$rel->cli_licensing_vxkeyless_prod_menu();# if ((!$prod_level) || (Cfg::opt("license")));
        return $rel->licensing($mtask) if ($mtask eq $edr->{msg}{back});
        $prod=$cpic->prod;
        $prodname=$prod->{abbr};
        $msg=Msg::new("Registering $prodname license");
        $msg->nprint;

        for my $sys (@{$cpic->{systems}}) {
            last if (Cfg::opt('makeresponsefile'));
            $prod_level=$rel->get_vxkeyless_prod_level($sys, $prod) if (Cfg::opt(qw(license updatekeys)));
            $rel->vxkeyless_register_sys($sys,$prod_level,1);
            $rel->read_licenses_sys($sys);
            $prod->licensed_sys($sys);
        }
        Msg::n();
    }
    if (Obj::webui()) {
        my $web=Obj::web();
        $web->{lic_result} = 'valid';
        $web->write_status();
    }

    return '';
}

# seperated from cli_licensing_vxkeyless for Web installer
sub cli_licensing_vxkeyless_prod_menu {
    my ($rel) = @_;
    my ($cpic,$moptions,$edr,$mmode,$mtask,$mprod,$prod);

    $edr=Obj::edr();
    $cpic=Obj::cpic();
    $mtask='license';
    $mprod=$cpic->{prod};
    $mprod=$rel->prod_ha_menu($mtask,$cpic->{prod});
    $cpic->set_prod($mprod);
    $cpic->cli_set_title();
    #$mmode=Cfg::opt("prodmode");
    $mmode=$rel->prod_mode_menu($mtask,$mprod,$mmode);
    # go back to licensing sub if back button is chosen
    return $mmode if ($mmode eq $edr->{msg}{back});
    $prod=$cpic->prod;
    $prod->set_mode($mmode) if ($mmode && $prod->can('set_mode'));
    $moptions=$rel->prod_options_menu($mtask,$mprod,$mmode,$moptions);
    $prod->set_options($moptions) if (@{$moptions} && $prod->can('set_options'));
    return '';
}

# validate a provided $key on a provided $sys
sub valid_license_key {
    my ($rel,$sys,$key) = @_;
    my ($msg,$web,$valid,$edr,$keyless,$prod);
    return 1 if (Cfg::opt('makeresponsefile'));
    $web=Obj::web();

    $key||=$rel->ask_license_key($sys);
    $edr=Obj::edr();
    return $key if ($key eq $edr->{msg}{back});
    $valid=$sys->cmd("_cmd_vxlicrep -k $key | _cmd_grep Product.Name | _cmd_grep -v ERROR.V");
    $keyless=$sys->cmd("_cmd_vxlicrep -k $key | _cmd_grep VXKEYLESS | _cmd_grep -v ERROR.V");

    if (!$valid) {
        $msg=Msg::new("$key is an invalid key");
        $msg->print;
    } elsif ($keyless) {
        $prod=$sys->cmd("_cmd_vxlicrep -k $key | _cmd_grep Product.Name | _cmd_grep '='| _cmd_grep -v ERROR.V");
        $prod=(split /\n/, $prod)[0];
        $prod=(split /=/, $prod, 2)[1];
        $prod=~s/\s*VERITAS\s*//gi;
        $msg=Msg::new("This is a vxkeyless key for $prod. Ignoring it. If you prefer keyless licensing, you should choose the keyless licensing option from the Licensing main menu.");
        $msg->print;
        $valid=0;
    }
    return $valid;
}

# return 1 if a feature is ENABLED, Yes, or matches passed $val
sub feature_licensed_sys {
    my ($rel,$sys,$fm,$val) = @_;
    my ($feat,$fval,$lk,$version,$ver);
    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    $version = 0;
    for my $lk (sort { $a cmp $b } keys(%{$sys->{keys}})) {
        for my $feat (sort { $a cmp $b } keys(%{$sys->{keys}{$lk}})) {
            $ver = 0;
            $fval = $sys->{keys}{$lk}{$feat};
            next unless (($feat eq $fm) || (($fm eq "VVR") && ($feat =~ /^VVR\#\w*/)));
            if (($fval eq 'Enabled') || ($fval eq 'YES')) {
                $ver = ($sys->{keys}{$lk}{Version} !~ /^\d+/) ? 1 : $sys->{keys}{$lk}{Version};
            }
            $version = $ver if ($ver && ($version < $ver));
            $ver = $sys->{keys}{$lk}{Version} if (($val) && ($fval eq $val));
            $version = $ver if ($ver && ($version < $ver));
        }
    }
    return $version;

}

# return a list of feature values
# returns a list because multiple keys may provide multiple values
sub feature_values_sys {
    my ($rel,$sys,$fm) = @_;
    my ($feat,$fval,$rv,$val,$lk);
    $rv=[];
    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    for my $lk (sort { $a cmp $b } keys(%{$sys->{keys}})) {
        for my $feat (keys(%{$sys->{keys}{$lk}})) {
            $fval=$sys->{keys}{$lk}{$feat};
            push(@$rv,$fval) if ($feat eq $fm);
        }
    }
    return $rv;
}

# get all VRTSvlid defined vxkeyless keys on a provided $sys
sub get_all_valid_vxkeyless_keys {
    my ($rel,$sys) = @_;
    my ($keys,@all_keys,$key,$pkg);

    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    @all_keys=();
    $pkg=$sys->pkg(licensing_pkg());
    if ($pkg->version_sys($sys)) {
        $keys=$sys->cmd('_cmd_vxkeyless displayall 2>/dev/null');
        for my $key (split(/\n/, $keys)) {
            next if ($key =~ /^Product/mi);
            if ($key =~ /^(\S+)\s*/m) {
                push (@all_keys, $1);
            }
        }
    }
    $keys=join(',',@all_keys);
    $sys->set_value('vxkeyless_valid', $keys);
    return $keys;
}

# get the highest vxkeyless key already defined on
# the systems.
sub get_installed_prod_vxkeyless_highest_key {
    my ($rel)= @_;
    my($cpic,$prod,$cluster_nodes,$one_key_on_all_sys,%prod_keys,
       $key_stem,$key_highest,$key,$sys,$vr_option,$vfr_option,$gco_option,
       $eval_option,$std_or_ent,$nokeys);

    $cpic=Obj::cpic();
    $prod=$cpic->prod;

    # check the vxkeyless keys on all the systems.
    # if none of them have the same key for the prod, then
    # find out the highest product key and set it onto all systems
    $key_stem=$rel->get_vxkeyless_prod_level(${$cpic->{systems}}[0],$prod,1);
    $one_key_on_all_sys = 0;
    $vr_option = $vfr_option = $gco_option = $eval_option  = $std_or_ent = 0;
    $std_or_ent = ($key_stem=~/STD$/m) ? 'STD' :
                  ($key_stem=~/ENT$/m) ? 'ENT' : 0;
    $key_stem=~s/(STD|ENT)$//mg;

    # set %prod_keys to all the $prod related keys,
    # including <PROD>{,HA}{,STD,ENT}(_VR|_VFR)(_GCO)(_EVAL)
    for my $sys (@{$cpic->{systems}}) {
        for my $key (sort (split /,/m,$sys->{vxkeyless})) {
            next if ($key !~ /^$key_stem/m);
            $prod_keys{$key}++;
        }
    }

    # assuming $cpic->{systems} has no duplicated sys
    # otherwise we're in trouble here
    # what we do below is to set the highest key to
    # the longest key that's included on all systems
    # of course, the _EVAL has the least privilege, if _VR|_VFR|_GCO exists
    $cluster_nodes=$#{$cpic->{systems}}+1;
    $key_highest = '';
    $nokeys = 1;
    for my $key (sort keys %prod_keys) {
        $nokeys = 0;
        # found a key exists on all systems
        if ($prod_keys{$key} == $cluster_nodes) {
            $one_key_on_all_sys = 1;
            # set the highest key to $key if
            #     no highest key set yet or
            #     highest key set already and the current new key doesn't have _EVAL suffix  or
            #     highest key has no ENT suffix and the current ney key has STD set
            #     any other possiblity here?
            $key_highest = $key if ((!$key_highest)   ||
                                    ($key !~ /_EVAL$/m) || ($key !~ /_EVAL_\d+/m) || 
                                    (($key_highest !~ /ENT/m) && ($key =~ /STD/m)));
            next;
        }
        # the following are for $key isn't found on all sys
        if ($key =~ /ENT/m) {
            $std_or_ent = 'ENT';
        } elsif ($key =~ /STD/m) {
            $std_or_ent = 'STD' if ($std_or_ent !~ /ENT/m);;
        } else {
            $std_or_ent = '' if ($std_or_ent !~ /(STD|ENT)/m);;
        }
        if ($key =~ /_VR|_VVR/m) {
            $vr_option = 1;
            $eval_option = 0;
        }
        if ($key =~ /_VFR/m) {
            $vfr_option = 1;
            $eval_option = 0;
        }
        if ($key =~ /_GCO/m) {
            $gco_option = 1;
            $eval_option = 0;
        }
        $eval_option = 1 if (($key =~ /_EVAL/m) && ! ($vr_option || $vfr_option || $gco_option));
    }

    if ($nokeys) {
        $key_highest=$rel->get_vxkeyless_prod_level(${$cpic->{systems}}[0],$prod,0) if (Cfg::opt(qw(license)));
    } elsif (!$one_key_on_all_sys) {
        # if no common prod key found on all sys
        # then we conbine the _VR|_VFR|_GCO found on all sys to form the highest key
        # _EVAL won't be taken if one of VR|GCO exists
        $key_highest = $key_stem;
        $key_highest .= "$std_or_ent" if ($std_or_ent);
        $key_highest .= '_VR' if ($vr_option || Cfg::opt('vr') || Cfg::opt('vvr'));
        $key_highest .= '_VFR' if ($vfr_option || Cfg::opt('vfr'));
        $key_highest .= '_GCO' if ($gco_option || Cfg::opt('gco'));
        $key_highest .= '_EVAL' if ($eval_option || Cfg::opt('eval'));
        $key_highest=$rel->get_vxkeyless_prod_level(${$cpic->{systems}}[0],$prod,0) if (Cfg::opt(qw(license)));
    }

    return $key_highest;
}

# return the key type on a given set of @$sitelic
# or @$lictype
sub keytype {
    my ($rel,$lictype,$sitelic) = @_;
    my ($cpic,$hi,@kt,$lt,$type,$prod);
    $cpic=Obj::cpic();
    $prod=$cpic->prod;
    for my $lt (@$sitelic) {
        return Msg::get('site') if ($lt=~/YES/m);
    }
    @kt=qw(UNKNOWN DEMO EVAL PERMANENT SITE);
    $hi=0;
    for my $lt (@$lictype) {
        $type = ($lt=~/SITE/m) ? 4 : ($lt=~/PERMANENT/m) ? 3 :
                ($lt=~/EVAL/m) ? 2 : ($lt=~/DEMO/m) ? 1 : 0;
        $hi=$type if ($type>$hi);
    }
    return ($kt[$hi]=~/^PABBR$/m) ? $prod->{prod} : Msg::get("$kt[$hi]");
}

# return a list of feature values for a specific product
# returns a list because multiple keys may provide multiple values
sub prod_feature_values_sys {
    my ($rel,$sys,$prodname,$feat) = @_;
    my ($cpic,$pname,$fv,$lname,$temp_name,$rv,$lk,$prod);
    $cpic=Obj::cpic();
    $prod = ($prodname) ? $sys->prod($prodname) : $cpic->prod;
    $rv=[];
    for my $lk (sort { $a cmp $b } keys(%{$sys->{keys}})) {
        $pname=$sys->{keys}{$lk}{'Product Name'};
        $pname=~s/^VERITAS //mi;
        for my $lname ($prod->{name},@{$prod->{lic_names}}) {
            $temp_name = $lname;
            $temp_name=~s/^VERITAS //mi;
            if ($pname=~/$temp_name/m) {
               $fv=$sys->{keys}{$lk}{$feat};
               push(@$rv,$fv) if ($fv);
           }
       }
    }
    return $rv;
}

# return 1 if a product license key is on the system
# return the highest version of the registered product license key(s) on the system
sub prod_licensed_sys {
    my ($rel,$sys,$prodname,$skip_superset) = @_;
    my ($cpic,$msg,$pname,$lname,$temp_name,$ha_status,$vxkeyless,$vxk,$lk,$prod,@prods,$licensed,$vcs_lic,$sf_lic);
    return 1 if (Cfg::opt(qw(makeresponsefile)) && !Cfg::opt(qw(upgrade patchupgrade)));
    $cpic=Obj::cpic();
    $ha_status = 0;
    $skip_superset ||= 0;
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $prod = ($prodname) ? $sys->prod($prodname) : $cpic->prod;
    $prodname||=$prod->{abbr};
    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    if ((!$skip_superset) && $prod->{licsuperprods} && @{$prod->{licsuperprods}}) {
        push(@prods,@{$prod->{licsuperprods}});
        for my $superprod (@prods) {
            $licensed=$rel->prod_licensed_sys($sys,$superprod);
            return $licensed if ($licensed);
        }
    }
    if ($sys->{vxkeyless}) {
        $vxkeyless=$rel->get_vxkeyless_prod_level($sys, $prod);
        for my $vxk (split /,/m,$sys->{vxkeyless}) {
            return 'vxkeyless' if ($vxkeyless eq $vxk);
            return 'vxkeyless' if ($vxk =~ /^$vxkeyless(STD|STD_|ENT|ENT_|_|$)/mx);
        }
    }
    for my $lk (sort { $a cmp $b } keys(%{$sys->{keys}})) {
        $pname=$sys->{keys}{$lk}{'Product Name'};
        $pname=~s/^VERITAS //mi;
        for my $lname (@{$prod->{lic_names}}) {
            $temp_name = $lname;
            $temp_name=~s/^VERITAS //mi;
            if ($pname=~/$temp_name/m) {
                if($prodname =~ /APPLICATIONHA/mi){
                    return 1 if($sys->{keys}{$lk}{ApplicationHA} =~ /Enabled/mi);
                    next;
                }
                $licensed = $sys->{keys}{$lk}{Version} if (!$licensed || (EDRu::compvers($licensed,$sys->{keys}{$lk}{Version}) == 2));
                next unless ($prodname=~/SFHA/m);
                # the following line is really just for SFHA
                $ha_status = $rel->feature_licensed_sys($sys, 'Mode#VERITAS Cluster Server', 'VCS');
                $vcs_lic = $rel->prod_licensed_sys($sys,'VCS60');
                $sf_lic = $rel->prod_licensed_sys($sys,'SF60',1);
                $ha_status = $vcs_lic if (EDRu::compvers($ha_status,$vcs_lic) == 2);
                $ha_status = $sf_lic  if ($ha_status && EDRu::compvers($ha_status,$sf_lic)  == 2);
                $licensed = 0 if ($temp_name !~ /$pname/m);
                $licensed = $ha_status if ($ha_status && (EDRu::compvers($licensed,$ha_status) == 2));
            }
        }
    }

    return $licensed;
}

# check if the product has a permanent license (not keyless)
sub prod_permanent_licensed_sys {
    my ($rel,$sys,$prodname) = @_;
    my (@keyless_keys,@product_keys,$cpic,$exploded_keys,$lic,$lk,$lname,$pname,$prod,$temp_name);
    return 1 if (Cfg::opt(qw(makeresponsefile)) && !Cfg::opt(upgrade patchupgrade));
    $cpic=Obj::cpic();
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $prod = ($prodname) ? $sys->prod($prodname) : $cpic->prod;
    $prodname||=$prod->{abbr};
    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    for my $lk (sort { $a cmp $b } keys(%{$sys->{keys}})) {
        # record all the keyless keys.
        $lic = $sys->{keys}{$lk}{'License Key'};
        if ($sys->{keys}{$lk}{'VXKEYLESS'} eq 'Enabled') {
            # get the list of exploded key of the keyless key
            $exploded_keys = $sys->cmd("_cmd_vxlicrep -k $lic 2> /dev/null | _cmd_grep 'License Key'");
            for my $kk (split(/\n/, $exploded_keys)) {
                $kk =~ s/License Key\s+=//m;
                $kk = EDRu::despace($kk);
                push (@keyless_keys,$kk);
            }
        }
        $pname=$sys->{keys}{$lk}{'Product Name'};
        $pname=~s/^VERITAS //mi;
        for my $lname (@{$prod->{lic_names}}) {
            $temp_name = $lname;
            $temp_name=~s/^VERITAS //mi;
            if ($pname=~/$temp_name/m) {
                push (@product_keys,$lic);
            }
        }
    }
    @product_keys = @{EDRu::arrdel(\@product_keys, @keyless_keys)};
    return 1 if (@product_keys > 0);

    return 0;
}

# return the list of space-seperated $prod keys already registered on $sys
sub prod_licensed_sys_key {
    my ($rel,$sys,$prod,$vxkeyless) = @_;
    my ($cpic,$pname,$key,$lname,$temp_name,$prod_keys,$lk);

    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $cpic=Obj::cpic();
    $prod||=$cpic->prod;
    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    $vxkeyless||=0;
    $prod_keys='';
    for my $lk (sort { $a cmp $b } keys(%{$sys->{keys}})) {
        $pname=$sys->{keys}{$lk}{'Product Name'};
        $pname=~s/^VERITAS //mi;
        for my $lname (@{$prod->{lic_names}}) {
            $temp_name = $lname;
            $temp_name=~s/^VERITAS //mi;
            if ($pname=~/$temp_name/m) {
                if ($prod!~/SFHA/m) {
                    $prod_keys.="$sys->{keys}{$lk}{'License Key'} ";
                    # need to add a check to see whether it's keyless,
                    # depending on the '$vxkeyless' requirement
                    # once the new VRTSvlic pkg is available
                } elsif ($rel->feature_licensed_sys($sys, 'Mode#VERITAS Cluster Server', 'VCS')) {
                    # the following line is really just for SFHA
                    $prod_keys.="$sys->{keys}{$lk}{'License Key'} ";
                    # need to add a check to see whether it's keyless,
                    # depending on the '$vxkeyless' requirement
                    # once the new VRTSvlic pkg is available
                }
            }
        }
    }
    return $prod_keys;


}

# main thread, calls read_licenses_sys in a serial loop
sub read_licenses {
    my ($rel) = @_;
    my ($cpic,$msg,$cfg,$sys,$key,$prod);
    $cpic=Obj::cpic();
    $prod=$cpic->prod;
    # unlicensed product
    return '' if (Cfg::opt('rootpath')||$prod->{nolic});
    $cfg=Obj::cfg();
    #return $rel->tsub("read_licenses_sys", $sys) if ($sys);
    # check licensing to determine uninstall pkgs for mode based products
    for my $sys (@{$cpic->{systems}}) { $rel->read_licenses_sys($sys); }

    return '';
}

# store keys found on a given $sys into $sys->{keys}
# after reading all the registered ones on $sys via vxlicrep_sys call
sub read_licenses_sys {
    my ($rel,$sys) = @_;
    my ($lictype,$feat,@f,$line,$vxlicrep,$val,$lk);
    return if ($rel->{nolic});
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return if $sys->{donotquerykeys};
    delete $sys->{keys};
    $rel->vxlicrep_sys($sys);
    $vxlicrep=$sys->{vxlicrep}||'';
    @f=split(/\n+/,$vxlicrep);
    for my $line (@f) {
        next unless $line=~/=/m;
        next if $line=~/Features :=/m;
        $line=~s/^\s+//m;
        if ($line=~/License Key/m) {
           $lk++;
           # store license type in case of editions key
           # will reset if not
           $sys->set_value("keys,$lk,License Type", $lictype);
           #$sys->{keys}{$lk}{'License Type'}=$lictype;
        }
        next if (!$lk);
        ($feat,$val)=split(/\s+=\s+/m,$line,2);
        if ($feat eq 'License Type') {
           $sys->set_value("keys,$lk,$feat", $val);
           $lictype = $val;
           #$lictype=$sys->{keys}{$lk}{$feat}=$val;
        } else {
           $sys->set_value("keys,$lk,$feat", $val) if (!($sys->{keys}{$lk}{$feat}));
           #$sys->{keys}{$lk}{$feat}||=$val;
        }
    }
    $sys->set_value ('donotquerykeys', 1);
    return $vxlicrep;
}

# register a given $key on a provided $sys via vxlicinst command
# do nothing if the given $key is already available on the system;
# quietly delete the keyless keys if the $key successfully registered to avoid nagging
sub register_key_sys {
    my ($rel,$sys,$key) = @_;
    my ($cpic,$msg,$cfg,$rk);

    return '' unless ($key);
    return '' if EDRu::inarr($key, @{$sys->{fail_duplicate_lic_keys}});
    $cfg=Obj::cfg();
    $cpic=Obj::cpic();

    $rk=$rel->licensed_keys_sys($sys);
    if (($#$rk > -1) && (EDRu::inarr($key, @$rk))) {
        return '';
    }
    if (EDRu::inarr($key, @{$cfg->{keys}{$sys->{sys}}})) {
        return '' unless (Cfg::opt('responsefile'));
    }

    $rk=$sys->cmd("_cmd_vxlicinst -k $key");
    if ($rk=~/ successfully /m) {
        $rk=$sys->cmd("_cmd_vxlicrep -k $key | _cmd_grep Product.Name | _cmd_grep -v ERROR.V");
        $rk=(split /\n/, $rk)[0];
        $rk=(split /\s*=\s*/m, $rk)[1];
        $rk=~s/^VERITAS\s+//mx;
        if($cpic->{prod} =~ /applicationha/mi && $rk =~ /Cluster Server/mi){
            my $feature_bit=$sys->cmd("_cmd_vxlicrep -k $key | _cmd_grep ApplicationHA | _cmd_grep -v ERROR.V");
            if($feature_bit =~ /Enabled/mi){
                $rk = 'Symantec ApplicationHA';
            }
        }
        $msg=Msg::new("$rk successfully registered on $sys->{sys}");
        $msg->print;
        if(Obj::webui()){
            my $web = Obj::web();
            $web->{licensed_prodname} = $rk;
        }
        delete $sys->{donotquerykeys};
        push(@{$cfg->{keys}{$sys->{sys}}}, $key) unless (Cfg::opt('responsefile'));
        $rk=$sys->cmd('_cmd_vxkeyless -q set NONE') if (Cfg::opt('license'));
    } elsif ($rk =~ / Duplicate /m) {
        $msg=Msg::new("Duplicate License key $key detected on $sys->{sys}");
        $msg->print;
        $rk=$sys->cmd('_cmd_vxkeyless -q set NONE') if (Cfg::opt('license'));
        push(@{$sys->{fail_duplicate_lic_keys}},$key);
    } else {
        Msg::print($rk);
        $msg=Msg::new("license key $key did not successfully validate on $sys->{sys}");
        $msg->warning;
        push(@{$sys->{fail_duplicate_lic_keys}},$key);
    }

    return '';
}

# some licensing msg setup
sub set_licensing_msgs {
    my $msg=Msg::new("Permanent");
    $msg->msg('permanent');
    $msg=Msg::new("EVAL");
    $msg->msg('eval');
    $msg=Msg::new("Extension");
    $msg->msg('extension');
    $msg=Msg::new("Node Lock");
    $msg->msg('nodelock');
    $msg=Msg::new("Site License");
    $msg->msg('sitelic');
    return '';
}

# final step of install_systems_serial|threaded
# register a product key if necessary
sub vxkeyless_register_sys {
    my ($rel,$sys,$prod_level,$force_flag) = @_;
    my ($cpic,$encap_keyfile,$pdfr,$vxkeyless,$prodname,$pkg,$prod,$msg);
    return '' if (Cfg::opt('makeresponsefile'));
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');

    $cpic=Obj::cpic();
    # Remove encap key if installed through encap script (auto boot disk encap)
    $encap_keyfile='/etc/vx/licenses/lic/BZZ9-6CP6-XHIJ-TYW6-R6PC-P4PP-P6P3-PPP.vxlic';
    $sys->cmd("_cmd_rm $encap_keyfile") if ($sys->exists($encap_keyfile));

    $vxkeyless=$sys->cmd('_cmd_vxkeyless display 2>/dev/null');
    $vxkeyless=~s/no keys installed.//mgi;
    if (Cfg::opt(qw(upgrade patchupgrade)) && ($vxkeyless ne $sys->{vxkeyless})) {
        $vxkeyless.=',' . $sys->{vxkeyless};
        $vxkeyless=~s/(^,|,$)//mg;
    }
    delete $sys->{vxkeyless};
    $sys->set_value('vxkeyless', $vxkeyless);
    return if (!$cpic->{prod});

    # do nothing if upgrade
    if (Cfg::opt('upgrade')) {
        Msg::log('Skipping key setting for upgrading');
        return;
    }

    $force_flag||=0;
    $prod=$sys->prod($cpic->{prod});
    $prodname=$prod->{abbr};
    $pkg=$sys->pkg(licensing_pkg());
    if ($pkg->version_sys($sys)) {
        $rel->get_all_valid_vxkeyless_keys($sys);

        $prod_level||=$rel->get_vxkeyless_prod_level($sys,$prod);

        # do not register unless the $prod_level is defined or forced
        if ((!$prod_level) || (!$force_flag)) {
            Msg::log('Skipping key setting due to no key provided or no forcing required');
            return;
        }
        # do not register if the key is invalid
        if ($sys->{vxkeyless_valid} !~ /(^$prod_level$|^$prod_level,|,$prod_level,|,$prod_level$)/mx) {
            $msg=Msg::new("Invalid key: $prod_level");
            $msg->print;
            return;
        }

        # do not register if the key is already-registered
        if ($sys->{vxkeyless} =~ /(^$prod_level$|^$prod_level,|,$prod_level,|,$prod_level$)/mx) {
            $msg=Msg::new("Key $prod_level already exists on $sys->{sys}, skipping registration");
            $msg->print;
            return;
        }
        $sys->{vxkeyless}.=",$prod_level";
        $sys->{vxkeyless}=~s/(^,|,$)//mg;
        $vxkeyless=$sys->cmd("_cmd_vxkeyless -q set $sys->{vxkeyless} 2>/dev/null");
        if (EDR::cmdexit()) {
            # something went wrong when registering the prod mode+options
            $msg=Msg::new("$prodname vxkeyless key ($prod_level) failed to register on $sys->{sys}");
            $msg->print;
        } else {
            $msg=Msg::new("$prodname vxkeyless key ($prod_level) successfully registered on $sys->{sys}");
            $msg->print;
            delete $sys->{donotquerykeys};
        }

        $vxkeyless=$sys->cmd('_cmd_vxkeyless display 2>/dev/null');
        $vxkeyless=~s/no keys installed.//mgi;
        $sys->set_value('vxkeyless', $vxkeyless);
        return $sys->{vxkeyless};
    } elsif (!Cfg::opt(qw(install precheck postcheck))) {
        $pdfr=Msg::get('pdfr');
        $msg=Msg::new("$pkg->{pkg} $pdfr not installed on $sys->{sys}");
        $msg->print;
    }
    return;
}

# return the vxkeyless prod level registered on the $sys
sub get_vxkeyless_prod_level {
    my ($rel,$sys,$prod,$prod_only) = @_;
    my ($new_prod);
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    $prod=$sys->prod($prod) unless (ref($prod));

    if ($prod->{prod} eq 'SF') {
        $new_prod=(Cfg::opt('prodmode') eq 'SF Basic') ? 'SFBASIC' :
                  (Cfg::opt('prodmode') eq 'SF Standard') ? 'SFSTD' :
                  (Cfg::opt('prodmode') eq 'SF Enterprise') ? 'SFENT' : 'SFSTD';
    } elsif ( $prod->{prod} eq 'SFHA') {
        $new_prod=(Cfg::opt('prodmode') eq 'SF Standard HA') ? 'SFHASTD' :
                  (Cfg::opt('prodmode') eq 'SF Enterprise HA') ? 'SFHAENT' : 'SFHA';
    } elsif ($prod->{prod} =~ /^SF(CFS|CFSHA|CFSRAC|RAC)$/mx) {
        $new_prod=$prod->{prod} . 'ENT';
    } elsif($prod->{prod} =~ /^(FS|VM)$/m) {
        $new_prod='SFSTD';
    } else {
        $new_prod=$prod->{prod};
    }

    if (!$prod_only) {
        # _VR & _VFR don't apply to VCS
        if ($new_prod !~ /^VCS/) {
            $new_prod.='_VR' if (Cfg::opt('vr') || Cfg::opt('vvr'));
            # _VR includes _VFR, and they don't show up together
            $new_prod.='_VFR' if (Cfg::opt('vfr') && (!Cfg::opt('vr')) && ($new_prod !~ /^SVS/));
        }
        $new_prod.='_GCO' if (Cfg::opt('gco') && ($new_prod =~ /^(VCS|SFHAENT|SFCFSHAENT|SFRACENT|SVS|SFSYBASECE)/mx));
        $new_prod.='_EVAL' if (Cfg::opt('eval'));
    }

    return $new_prod;
}

# Threaded, checks for VRTSvlic package,
# if installed calls vxlicrep -i and sets $sys->{vxlicrep}
# using $sys->set_value("vxlicrep", $vxlicrep);
# this sub is no longer directly called  by CPIC::verify_systems
sub vxlicrep_sys {
    my ($rel,$sys) = @_;
    my ($cpic,$msg,$pdfr,$vxlicrep,$pkg);
    return 1 if (Cfg::opt('makeresponsefile') && Cfg::opt(qw(configure uninstall)));

    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    # hack for now
    #return "" if (!$sys->{prod} || !$sys->prod->licensed);
    $cpic=Obj::cpic();

    # Check licenses on rootpath directory if rootpath is set.
    my $rootpath = Cfg::opt('rootpath');
    if ($rootpath && ($rootpath ne '/')) {
        $pkg=$sys->pkg(licensing_pkg());
        my $vxlic_path = "$rootpath/etc/vx/licenses/lic/";
        # Check if license pkg is installed on PBE as we have to run vxlicrep cmd on PBE.
        if (($pkg->version_sys($sys,1,'',1)) && ($sys->is_dir($vxlic_path))){
            my $lics = $sys->cmd("cd $vxlic_path; _cmd_ls *.vxlic 2>/dev/null");
            $lics=~s/\.vxlic\s*/,/mgs;
            $lics=~s/,$//m;
            if($lics) {
                for my $lic (split (/,/m,$lics)) {
                    $vxlicrep.=$sys->cmd("_cmd_vxlicrep -k $lic 2>/dev/null");
                }
                $sys->set_value('vxlicrep', $vxlicrep);
            }
        }
        return 1;
    }

    # we still need to run vxlicrep -i even if no prod specified
    # used by installer at the initial stage for prods checking
    #return "" unless ($cpic->{prod});
    $rel->vxkeyless_register_sys($sys,undef,0);
    delete $sys->{vxlicrep};
    $pkg=$sys->pkg(licensing_pkg());
    if ($pkg->version_sys($sys)) {
        $vxlicrep=$sys->cmd('_cmd_vxlicrep -i');
        $sys->set_value('vxlicrep', $vxlicrep);
    } elsif ($cpic->{task} && (Cfg::opt('upgrade patchupgrade license'))) {
        $pdfr=Msg::get('pdfr');
        $msg=Msg::new("$pkg->{pkg} $pdfr not installed on $sys->{sys}");
        $sys->push_warning($msg);
        return '';
    }
    return 1;
}

# return ref of array of registered keys on a given $sys
sub licensed_keys_sys {
    my ($rel,$sys) = @_;
    my (@prod_keys,$lname,$lk);

    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    @prod_keys=();
    for my $lk (keys %{$sys->{keys}}) {
        push(@prod_keys,$sys->{keys}{$lk}{'License Key'});
    }

    return \@prod_keys;
}

# For SFBasic only
# return the content of .key file if found in the mediapath
sub read_sfbasic_key {
    my ($rel) = @_;
    my ($edr,$key);

    $edr=Obj::edr();
    $key=EDR::cmd_local("_cmd_find $edr->{mediapath} -type f -name .key 2>/dev/null");
    $key=~s/^\s+//mg;
    $key=(split /\n/, $key)[0];
    if ($key) {
        $key=EDRu::readfile($key);
        chomp $key;
    }

    return $key;
}

# due to vlic pkg /etc/vx/licenses/dat/licenses.dat changes between 5.1 and 5.1SP1
# we have to migrate the stale keys to valid ones
# UxRT-6.0 uses _VR instead of _VVR and we need to take care of this for upgrade
sub restore_keyless_keys {
    my ($rel) = @_;
    my ($cpic,$oldkey,$newkey,@keys,$old_ver,$edr,$sys,$msg,$ayn,$key);

    $cpic=Obj::cpic();
    $old_ver=0;
    for my $sys (@{$cpic->{systems}}) {
        $oldkey=$sys->{vxkeyless};
        if ($oldkey) {
            # assuming vxkeyless command is still valid
            $newkey=$sys->cmd('_cmd_vxkeyless display 2>/dev/null');
            $newkey=~s/no keys installed.//mgi;
            $old_ver=1 if ($newkey=~/_\d+/);
            $key="$newkey,$oldkey";
            @keys=(split /,/, $key);
            @keys=sort @{EDRu::arruniq(@keys)};
            for ($key=0;$key<=$#keys;$key++) {
                $keys[$key]=(split /_\d+/, $keys[$key])[0];
            }
            $newkey=join ",", @keys;
            $newkey=~s/_VVR/_VR/mgi;
        }
        $sys->{vxkeyless_new}=$newkey;
    }
    # if $old_ver is set, then we'll prompt the user the upgrade option of the keyless keys 
    if ($old_ver) {
        if (Cfg::opt('updatekeys')) {
            $msg=Msg::new("Found vxkeyless key(s) for previous release(s). They will be automatically updated to the current version.");
            $msg->print();
        } else {
            $msg=Msg::new("Found vxkeyless key(s) for previous release(s). It's recommended to update them to fully utilize the new features in current release. Do you wish to update them to the current version?");
            $ayn=$msg->ayny(undef,1);
            $ayn = 'N' if (Cfg::opt('responsefile') && !Cfg::opt('updatekeys'));
            if ($ayn eq 'Y') {
                Cfg::set_opt('updatekeys');
                if (!Cfg::opt('vxkeyless')) {
                    Cfg::set_opt('vxkeyless');
                    $key=1;
                }
            }
        }
        if (Cfg::opt('updatekeys')) {
            for my $sys (@{$cpic->{systems}}) {
                $oldkey=$sys->{vxkeyless};
                $newkey=$sys->{vxkeyless_new};
                if ($oldkey && $newkey && ($oldkey ne $newkey)) {
                    @keys=(split /,/, $newkey);
                    $newkey=EDRu::arruniq(@keys);
                    $newkey=join ",", @{$newkey};
                    $sys->cmd("_cmd_vxkeyless -q set $newkey 2>/dev/null");
                    delete $sys->{donotquerykeys};
                    $rel->read_licenses_sys($sys);
                }
            }
			Cfg::unset_opt('vxkeyless') if ($key);
        }
    }
    return '';
}

1;
