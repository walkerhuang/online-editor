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
package EDR;
use strict;
use Time::Local;

sub no_stop_checks { return !num_sys_keyset('stop_checks',@_) }
sub stop_checks { return num_sys_keyset('stop_checks',@_) }
sub continue_checks { return num_sys_keynotset('stop_checks',@_) }
sub com_deny_sys { return num_sys_keyset('com_deny',@_) }

sub verify_systems_serial {
    my $edr=shift;
    my ($failed,$msg,$stage);

    Msg::title();
    $stage = Msg::new("Verifying systems");
    $stage->display_bold() if (Cfg::opt(qw(redirect)));

    for my $sys (@{$edr->{systems}}) {
        $msg=Msg::new("Checking communication on $sys->{sys}");
        $stage->display_left($msg);
        $failed=$edr->transport_sys($sys) ? '' : 'failed';
        $stage->display_right($failed);

        next if ($sys->{stop_checks});
        $msg=Msg::new("Checking release compatibility on $sys->{sys}");
        $stage->display_left($msg);
        $failed=$edr->supported_padv_sys($sys) ? '' : 'failed';
        $stage->display_right($failed);
    }
    return '';
}

sub verify_systems_threaded {
    my ($edr,$threadlimit) = @_;
    my ($failmsg,$msg,$thr,$stage);

    Msg::title();
    $stage = Msg::new("Verifying systems");

    $msg=Msg::new("Checking system communication");
    $stage->display_left($msg);
    for my $sys (@{$edr->{systems}}) {
        $edr->transport_sys($sys);
    }
    $stage->display_right();

    $thr=Obj::thr();
    $thr->mq_create_threads($edr->nsystems, $threadlimit);

    if (continue_checks()) {
        $msg=Msg::new("Checking release compatibility");
        $stage->display_left($msg);
        $thr->mq_add_sub_allsys('EDR', 'supported_padv_sys');
        $thr->mq_wait_for_completion();
        $thr->mq_read_rtns();
        $stage->display_right();
    }

    $thr->mq_join_threads();
    return '';
}

sub reset_errors_warnings {
    my $edr=Obj::edr();
    for my $sys (@{$edr->{systems}}) {
        undef($sys->{errors});
        undef($sys->{warnings});
        undef($sys->{notes});
        undef($sys->{stop_checks});
    }
    return '';
}

sub reset_prodinfo_sys {
    my $edr=Obj::edr();
    for my $sys (@{$edr->{systems}}) {
        undef($sys->{upgradeprod});
        undef($sys->{prodvers});
        undef($sys->{upgradeprod_abbr});
        undef($sys->{prodintalltimes});
    }
    return '';
}

sub reset_pkginfo_sys {
    my $edr=Obj::edr();
    for my $sys (@{$edr->{systems}}) {
        undef($sys->{pkgvers});
        undef($sys->{pkgverslist});
        undef($sys->{pkgdeps});
    }
    return '';
}

sub padv_ipv_sys {
    my ($edr,$sys) = @_;
    my ($msg,$padvisa,$vers,$v2,$platclass,$padv,$padvclass,$hostname);
    return '' if ($sys->{stop_checks});

    if (local_windows() &&!Cfg::opt('vom')) {
        # must assume target systems are also Windows
        $sys->{plat}='Win';
    } else {
        # If unix, set uname
        $sys->{uname}=$sys->cmd("uname -a");
        chomp($sys->{uname});
        $sys->set_value("uname", $sys->{uname});

        # set padv details and padv
        ($sys->{plat},undef,$vers,$v2,undef)=split(/\s+/,$sys->{uname},5);
        $sys->{plat}=~s/Darwin/MacOS/;
        $sys->{plat}=~s/\W//g;
    }
    $platclass="Padv::".$sys->{plat};

    # It is possbile that hostname is not consistent with 'uname -a',
    #hostname shouldn't be fqdn
    $hostname = ($sys->{wmi}) ? Padv::Win::remote_hostname_sys($sys) :
                                $sys->cmd('hostname');
    # hostname shouldn't be fqdn
    ($sys->{hostname},undef)=split(/\./, $hostname, 2);
    $sys->{arch}=$platclass->arch_sys($sys);
    $sys->{distro}=$platclass->distro_sys($sys);
    $sys->{platvers}=$platclass->platvers_sys($sys, $vers, $v2);
    return 0 if (!$sys->{platvers} && $sys->{stop_checks});
    $sys->{padv}=$platclass->padv_sys($sys);
    Msg::log("$sys->{plat},$sys->{arch},$sys->{distro},$sys->{platvers}=$sys->{padv}");
    $sys->set_value('plat', $sys->{plat});
    $sys->set_value('hostname', $sys->{hostname});
    $sys->set_value('arch', $sys->{arch});
    $sys->set_value('distro', $sys->{distro});
    $sys->set_value('platvers', $sys->{platvers});
    $sys->set_value('padv', $sys->{padv});

    if (!EDRu::inarr($sys->{padv}, @{$edr->padvs})) {
        # unlikely to hit if perl is executing properly, but...
        $msg=Msg::new("$edr->{script} cannot be executed on a $sys->{padv} platform");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    $padv = $sys->{padv};
    $padvclass="Padv\::$padv"->new();
    $padvisa=$edr->{padvisa}{$sys->{padv}};
    "Padv\::$padvisa"->new() if (($padvisa) && ($padvisa ne $sys->{padv}));

    $sys->{kerbit}=$padvclass->kerbit_sys($sys);
    $sys->set_value('kerbit', $sys->{kerbit});

    # also set IP version and virtualization details
    $sys->{ip}||='';
    $sys->{ipv4}=$padvclass->ipv4_sys($sys);
    $sys->set_value('ip', $sys->{ip});
    $sys->set_value('ipv4', $sys->{ipv4});

    $padvclass->minorversion_sys($sys);

    # do not need check virtualization everytime call into this sub
    $padvclass->virtualization_sys($sys) if (!$sys->{virtualization_checked});
    $sys->set_value('virtualization_checked', 1);

    return 1;
}

sub ping_sys {
    my ($edr,$sys) = @_;
    my ($ping,$msg,$localsys,$rtn);
    return '' if ($sys->{stop_checks});
    if (!EDRu::isip($sys->{sys})) {
        # if not ipv4 and ipv6, then try resolve the system name.
        $rtn=EDRu::is_hostname_resolvable($sys->{sys});
        if (!$rtn) {
            $msg=Msg::new("Cannot resolve hostname $sys->{sys}");
            $sys->push_stop_checks_error($msg);
            return '';
        }
    }
    $localsys=$edr->{localsys};
    $ping=$localsys->padv->ping($sys->{sys});
    if ($ping =~ m/noping/) {
        $msg=Msg::new("cannot ping $sys->{sys}");
        $sys->push_stop_checks_error($msg);
        return '';
    } elsif ((EDRu::ip_is_ipv6($sys->{sys})) &&
             ($localsys->{plat} eq 'Linux') &&
             (EDRu::iptype_ipv6($sys->{sys}) =~ m/LINK-LOCAL/)) {
        $msg=Msg::new("Cannot use LINK-LOCAL IPv6 address on $sys->{sys}");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    return 1;
}

# the following subs are used by supported_padv_sys in conjunction with Padv subs
# in order to the list of platform, arches, distros, and versions

# return supported plats from a list of padvs, or @{$edr->{padvs}} by default
sub supported_plats {
    my ($edr,@padvs) = @_;
    my(%plat,@plats);
    @padvs = @{$edr->{padvs}} if(!@padvs);
    for my $padv (@padvs) { $plat{Padv::plat($padv)}=1; }
    @plats=sort keys(%plat);
    return \@plats;
}

# return supported distros from a list of padvs, or @{$edr->{padvs}} by default
sub supported_distros {
    my ($edr,@padvs) = @_;
    my(%distro,@distros,$distro);
    @padvs = @{$edr->{padvs}} if(!@padvs);
    for my $padv (@padvs) {
        $distro=Padv::distro($padv);
        $distro{$distro}=1 if ($distro);
    }
    @distros=sort keys(%distro);
    return \@distros;
}

# return supported architectures from a list of padvs for one plat or distro
sub supported_arches {
    my ($edr,$pd,@padvs) = @_;
    my(%arch,@arches,$arch,$plat);
    @padvs = @{$edr->{padvs}} if(!@padvs);
    for my $padv (@padvs) {
        $plat=Padv::plat($padv);
        next if (($plat ne 'Linux') && ($plat ne $pd));
        next if (($plat eq 'Linux') && (Padv::distro($padv) ne $pd));
        $arch=Padv::arch($padv);
        $arch{$arch}=1 if ($arch);
    }
    @arches=sort keys(%arch);
    return \@arches;
}

# return supported platform versions from a list of padvs for
# one plat or distro and one arch
sub supported_vers {
    my ($edr,$pd,$arch,@padvs) = @_;
    my(%vers,@vers,$plat);
    @padvs = @{$edr->{padvs}} if(!@padvs);
    for my $padv (@padvs) {
        $plat=Padv::plat($padv);
        next if (($plat ne 'Linux') && ($plat ne $pd));
        next if (($plat eq 'Linux') && (Padv::distro($padv) ne $pd));
        next if (($arch) && (Padv::arch($padv) ne $arch));
        for my $vers (split(/,/m, Padv::vers($padv))) {
            $vers.='+' if ($edr->{padv_unbounded}{$padv});
            $vers{$vers}=1;
        }
    }
    @vers=sort keys(%vers);
    return \@vers;
}

# should eventually display a detailed description of the failure
# incorrect platform, arch, distro, or version
# easy to isolate on single padv release, but difficult on multi padv
sub supported_padv_sys {
    my ($edr,$sys) = @_;
    my ($pd,$msg,$vers,$distros,$arches,$plats);
    # scalars must be passed to threaded call
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
    return '' if ($sys->{stop_checks});
    return 1 if (EDRu::inarr($sys->{padv}, @{$edr->{padvs}}));

    # OK, something doesn't match, first check the platform
    $plats=$edr->supported_plats;
    if (!EDRu::inarr($sys->{plat}, @$plats)) {
        $plats=EDRu::join_and(@$plats);
        $msg=Msg::new("This release is intended to operate on $plats operating systems but $sys->{sys} is a $sys->{plat} system");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    # now check the Linux distros
    if ($sys->linux()) {
        $distros=$edr->supported_distros;
        if (!EDRu::inarr($sys->{distro}, @$distros)) {
            $distros=EDRu::join_and(@$distros);
            $msg=Msg::new("This release is intended to operate on $distros Linux distributions but $sys->{sys} is a $sys->{distro} system");
            $sys->push_stop_checks_error($msg);
            return '';
        }
    }

    # now check the architectures
    # use distro instead of plat for Linux to properly separate arch
    $pd = ($sys->linux()) ? $sys->{distro} : $sys->{plat};
    if (!$sys->aix()) {
        $arches=$edr->supported_arches($pd);
        if (!EDRu::inarr($sys->{arch}, @$arches)) {
            $arches=EDRu::join_and(@$arches);
            $msg=Msg::new("This release is intended to operate on $pd $arches architectures but $sys->{sys} is running a $sys->{arch} architecture");
            $sys->push_stop_checks_error($msg);
            return '';
        }
    }

    # check the platform version
    # matching here could be really tricky especially with arch in the mix
    # and padv_unbounded however if we got here and padv didn't match,
    # we know the version is off, simply display
    # should we write a check and then have another die message at the bottom?

    if (($sys->aix) || (($sys->hpux) && (Padv::HPUX::combo_arch()))) {
        $vers=EDRu::join_and(@{$edr->supported_vers($pd)});
        $msg=Msg::new("This release is intended to operate on $pd version $vers but $sys->{sys} is running version $sys->{platvers}");
    } else {
        $vers=EDRu::join_and(@{$edr->supported_vers($pd,$sys->{arch})});
        $msg=Msg::new("This release is intended to operate on $pd $sys->{arch} version $vers but $sys->{sys} is running version $sys->{platvers}");
    }
    $sys->push_stop_checks_error($msg);
    return ''

    # platform version level is checked later using more complicated $rel
    # checks that do not get into the padv
}

sub rcp_sys {
    my ($edr,$sys) = @_;
    my ($msg,$file,$cat);
    return '' if ($sys->{stop_checks});
    $file="$edr->{tmpdir}/uuid";
    EDRu::writefile($edr->{uuid}, $file) unless (-e $file);
    $edr->localsys->copy_to_sys($sys,$file,$file,'noerr');
    if ($edr->{cmdexit}) {
        if (EDRu::ip_is_ipv6($sys->{sys})) {
            # Incident 2962518: rcp not work well with IPv6
            $msg=Msg::new("Failed to copy file from local to $sys->{sys} with IPv6 address. Use host name and restart installer");
        } else {
            # Incident 2580308:
            # scp do not work if there are some commands which print some messages, like echo, ntpdate, in .bashrc on remote machine
            $msg=Msg::new("Failed to copy file from local to $sys->{sys} due to shell environment issues on $sys->{sys}, resolve the issue and restart installer");
        }
        $sys->push_stop_checks_error($msg);
        return '';
    } else {
        $cat=$sys->cmd("_cmd_cat $file");
        chomp $cat;
        if ($cat ne $edr->{uuid}) {
            $msg=Msg::new("Failed to copy file from local to $sys->{sys} due to shell environment issues on $sys->{sys}, resolve the issue and restart installer");
            $sys->push_stop_checks_error($msg);
            return '';
        }
    }
    return 1;
}

# check communication with remote systems
sub transport_sys {
    my ($edr,$sys) = @_;
    my ($islocal,$tmppadv,$ret);
    # scalars must be passed to threaded call
    $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');

    # temporarily set the plat/padv for the system to localsys or the
    # first padv in $edr->{padvs}, shouldn't matter during transport_sys
    $sys->{padv}=$edr->{localsys}{padv};
    $sys->{plat}=$^O;
    $sys->set_value('padv', $sys->{padv});
    $sys->set_value('plat', $sys->{plat});

    # check if the system is the local system
    # For fix of 3538492, we need to recheck islocal for Cfg::opt("makeresponsefile")
    # for the 2nd round transport_sys check after rsh/ssh being setup.
    if (!$sys->{islocal} || Cfg::opt("makeresponsefile")) {
        $tmppadv = $sys->{padv};
        #e3604005:if $islocal is not equal as before, it should be reset in multithreading mode.
        $islocal="Padv\::$tmppadv"->islocal_sys($sys);
        if ($sys->{islocal} != $islocal) {
            $sys->set_value('islocal', $islocal);
        }
    }

    if ($sys->{stop_checks}){
        $ret = 0;
    } else {
        # breaking out four conditions for an easier override, if necessary
        if (local_windows()) {
            if(Cfg::opt('vom')){
                $ret = $edr->remote_unix_transport_sys($sys);
            } else {
                # remote systems must be Windows too if local is Windows
                $ret = ($sys->{islocal}) ? $edr->local_windows_transport_sys($sys) :
                                           $edr->remote_windows_transport_sys($sys);
            }
        } else {
            $ret = ($sys->{islocal}) ? $edr->local_unix_transport_sys($sys) :
                                       $edr->remote_unix_transport_sys($sys);
        }
    }

    # treat failed system as local if -makereponsefile is used
    if (Cfg::opt("makeresponsefile") && !$ret) {
        $sys->{islocal} = 1;
        $sys->set_value('islocal', $sys->{islocal});
        Msg::log("$sys->{sys} cannot be connected. $edr->{script} will collect required information from on local system instead to generate the response file");
    }
    return $ret;
}

sub local_windows_transport_sys {
    my ($edr,$sys) = @_;
    return 0 unless ($edr->padv_ipv_sys($sys));
    if (Cfg::opt('rwe')) {
        my $win=$edr->{localsys}->padv;
        return 0 unless ($win->registry_write_sys($sys,"PID=$$"));
    }
    return 1;
}

sub remote_windows_transport_sys {
    my ($edr,$sys) = @_;
    my $win=$edr->{localsys}->padv;
    return 0 unless ($edr->ping_sys($sys));
    return 0 unless ($win->get_wmi_object_sys($sys));
    return 0 unless ($edr->padv_ipv_sys($sys));
    return 0 unless ($win->registry_write_sys($sys,'test'));
    return 0 unless ($win->create_remote_exe_sys($sys));
    return 0 unless ($win->execute_remote_exe_sys($sys, $edr->initiation_arg));
    return 1;
}

sub initiation_arg { return '-initiation' }

sub local_unix_transport_sys {
    my ($edr,$sys) = @_;
    return $edr->padv_ipv_sys($sys);
}

sub remote_unix_transport_sys {
    my ($edr,$sys) = @_;
    return 0 unless ($edr->ping_sys($sys));
    return 0 unless ($edr->rsh_sys($sys));
    return 0 unless ($edr->shell_sys($sys));
    return 0 unless ($edr->padv_ipv_sys($sys));
    return 1;
}

sub shell_sys {
    my ($edr,$sys) = @_;
    my ($sh,@pwd,$pwd);
    $pwd=$sys->cmd("grep '^root:' /etc/passwd");
    @pwd=split(/\W/m,$pwd);
    $sh=$pwd[-1];
    EDR::die("Cannot determine shell of system $sys->{sys}") unless ($sh);
    $sys->set_value('shell', $sh);
    return 1;
}

sub verify_systems_errors {
    my $edr=shift;
    my ($errors,$warnings,$msg);
    if (Cfg::opt('makeresponsefile') && !Cfg::opt(qw(upgrade patchupgrade hotfixupgrade))) {
        # ignore errors/warnings for -makeresponsefile unless upgrade
        reset_errors_warnings();
        return 1;
    }

    # count errors and warnings
    for my $sys (@{$edr->{systems}}) {
        if ($sys->{errors}) {
            $errors+=scalar(@{$sys->{errors}});
        } else {
            push(@{$edr->{passed_obj}}, $sys);
            push(@{$edr->{passed_sys}}, $sys->{sys});
        }
        $warnings+=scalar(@{$sys->{warnings}}) if ($sys->{warnings});
    }
    $edr->set_exitcode(1) if($errors && !$edr->{exitcode});
    $edr->display_errors_warnings();

    # reset errors and warnings after shown
    reset_errors_warnings() if (!Cfg::opt('rwe'));

    # responsefile+errors is automatic die
    if (($errors) && (Cfg::opt('responsefile'))) {
        if ($edr->{exitfile}) {
            $msg=Msg::new("Cannot resume the process as systems specified earlier fail prerequisite checks");
        } else {
            $msg=Msg::new("Cannot use responsefile as systems specified in response file fail prerequisite checks");
        }
        $msg->die;
    }

    # cli errors are probably too, but this sub can be overridden
    return $edr->cli_handle_errors() if ($errors);
    $edr->cli_handle_warnings() if ($warnings);
    return 1;
}

# override to get this functionality in
sub offer_passed_systems { }

sub cli_handle_errors {
    my ($edr) = @_;
    # set $edr->{offer_passed_systems}=1; in CPIP to enable this functionality
    if ($edr->offer_passed_systems) {
        return 1 if ($edr->cli_offer_passed_systems());
    }
    my $cfg=Obj::cfg();
    undef $cfg->{systems};
    Cfg::unset_opt('hostfile');
    return '';
}

sub cli_offer_passed_systems {
    my ($edr) = @_;
    if (defined($edr->{passed_sys})) {
        my $psys=join("\n\t", @{$edr->{passed_sys}});
        my $msg=Msg::new("System verification was successful with the following systems:\n\n\t$psys\n");
        $msg->print;
        $msg=Msg::new("Would you like to continue using these systems only?");
        my $ayn=$msg->ayny;
        if ($ayn eq 'Y') {
            my $cfg=Obj::cfg();
            $edr->{systems}=$edr->{passed_obj};
            $cfg->{systems}=$edr->{passed_sys};
            return 1;
        }
    }
    return '';
}

# handles warnings
sub cli_handle_warnings {
    my ($edr) = @_;
    my ($msg,$ayn);
    $msg=Msg::new("Do you want to continue?");
    $ayn=$msg->ayny;
    Msg::n();
    exit_exitfile() if ($ayn eq 'N');
    return 1;
}

sub display_notes {
    my ($edr) = @_;
    my ($notes,$msg);

    for my $sys (@{$edr->{systems}}) {
        $notes+=scalar(@{$sys->{notes}}) if ($sys->{notes});
    }

    if ($notes) {
        $msg=Msg::new("The following notes were discovered on the systems:");
        $msg->bold;
        $msg->add_summary(1);
        Msg::n();
        for my $sys (@{$edr->{systems}}) {
            for my $errmsg ((@{$sys->{notes}})) {
                Msg::print("$errmsg\n");
                Msg::add_summary($errmsg);
                $msg->addNote($errmsg);
            }
        }
    }
    return;
}

# Define @systems to only display errors and warnings for specified systems.
sub display_errors_warnings {
    my ($edr,$msg,$failmsg,@systems) = @_;
    my ($systems,$warnings,$errors,$notes,$check_action_notes,$conclude);

    $systems=$edr->{systems};
    $systems=\@systems if (@systems);

    # count errors and warnings
    $errors=0;
    $warnings=0;
    $notes=0;
    $check_action_notes=0;
    for my $sys (@{$systems}) {
        $errors+=scalar(@{$sys->{errors}}) if ($sys->{errors});
        $warnings+=scalar(@{$sys->{warnings}}) if ($sys->{warnings});
        $notes+=scalar(@{$sys->{notes}}) if ($sys->{notes});
        $check_action_notes+=scalar(@{$sys->{check_action_notes}}) if ($sys->{check_action_notes});
    }

    # if the parameter $msg is equal to ' ', don't diplay this message
    if (! defined $msg || ref($msg)=~m/^Msg/) {
        Msg::n();
        $msg||=Msg::new("System verification checks completed successfully");
        $failmsg||=Msg::new("System verification checks completed");
        $conclude = ($errors||$warnings||$edr->{time_async}) ? $failmsg : $msg;
        $conclude->display_bold();
        $conclude->add_summary(1);
    }

    # print notes firstly
    if ($notes && (Cfg::opt('precheck') || !$errors)) {
        $msg=Msg::new("The following notes were discovered on the systems:");
        $msg->bold;
        $msg->add_summary(1);
        Msg::n();
        for my $sys (@{$systems}) {
            for my $errmsg ((@{$sys->{notes}})) {
                Msg::print("$errmsg\n");
                Msg::add_summary($errmsg);
                $msg->addNote($errmsg);
            }
        }
    }

    # print errors and warnings
    if ($errors) {
        $msg=Msg::new("The following errors were discovered on the systems:");
        $msg->bold;
        $msg->add_summary(1);
        Msg::n();
        for my $sys (@{$systems}) {
            for my $errmsg ((@{$sys->{errors}})) {
                Msg::print("$errmsg\n");
                Msg::add_summary($errmsg);
                $msg->addError($errmsg);
            }
        }
    }

    if ($warnings) {
        $msg=Msg::new("The following warnings were discovered on the systems:");
        $msg->bold;
        $msg->add_summary(1);
        Msg::n();
        for my $sys (@{$systems}) {
            for my $errmsg ((@{$sys->{warnings}})) {
                Msg::print("$errmsg\n");
                Msg::add_summary($errmsg);
                $msg->addWarning($errmsg);
            }
        }
    }

    if ($check_action_notes) {
        $msg=Msg::new("The following checks and actions were performed on the systems:");
        $msg->add_summary(1);
        for my $sys (@{$systems}) {
            for my $errmsg ((@{$sys->{check_action_notes}})) {
                Msg::add_summary($errmsg);
            }
            undef $sys->{check_action_notes};
        }
    }

    return;
}

sub update_check_action_summary {
    my ($edr,$titlemsg) = @_;
    my ($notes);

    for my $sys (@{$edr->{systems}}) {
        if ($sys->{check_action_notes}) {
            $notes+=scalar(@{$sys->{check_action_notes}});
        }
    }

    if ($notes) {
        $titlemsg||=Msg::new("The following checks and actions were performed on the systems:");
        $titlemsg->add_summary(1);
        for my $sys (@{$edr->{systems}}) {
            for my $notemsg ((@{$sys->{check_action_notes}})) {
                Msg::add_summary($notemsg);
            }
            undef ($sys->{check_action_notes});
        }
    }
    return;
}

sub rsh_sys {
    my ($edr,$sys) = @_;
    my ($msg,$transport,$rsh_deny,$ssh_deny,$rsh_failure,$ssh_failure,$error_no);
    return '' if ($sys->{stop_checks});
    return 1 if ($sys->{transport_obj});

    $sys->set_value('com_deny', 0);
    $sys->set_value('sshrsh_failure', 0);

    if (Cfg::opt('vom')) {
        $transport='vom';
        # check ssh connection
        if ($sys->check_connection($transport)) {
            $sys->set_value('vom', $transport);
            return 1;
        } else {
            ($error_no,$ssh_failure)=$sys->get_connection_error($transport);
            $ssh_deny=1 if ($error_no == Transport->ECONNECTIONDENIED);
            return '';
        }
    }

    if (! Cfg::opt('rsh')) {
        $transport='ssh';
        # check ssh connection
        if ($sys->check_connection($transport)) {
            $sys->set_value('rsh', $transport);
            return 1;
        } else {
            ($error_no,$ssh_failure)=$sys->get_connection_error($transport);
            $ssh_deny=1 if ($error_no == Transport->ECONNECTIONDENIED);
        }
    }

    # check rsh connection
    $transport='rsh';
    if ($sys->check_connection($transport)) {
        $sys->set_value('rsh', $transport);
        return 1;
    } else {
        ($error_no,$rsh_failure)=$sys->get_connection_error($transport);
        $rsh_deny=1 if ($error_no == Transport->ECONNECTIONDENIED);
    }

    if ($rsh_failure) {
        if (Cfg::opt('rsh')) {
            $msg=Msg::new("${rsh_failure} rsh is required to be set up and ensure that it is working properly between the local node and $sys->{sys} for communication");
        } else {
            $msg=Msg::new("${ssh_failure} ${rsh_failure} Either ssh or rsh is required to be set up and ensure that it is working properly between the local node and $sys->{sys} for communication");
        }
        if ($rsh_deny || $ssh_deny) {
            $sys->set_value('com_deny', 1);
        } else {
            $sys->set_value('sshrsh_failure', 1);
        }
        $sys->push_stop_checks_error($msg);
        return '';
    }
    return 1;
}

sub cli_select_systems {
    my ($edr,$def) = @_;
    my ($msg,$cfg,$helpmsg,$padv,@systems,$systems);
    $cfg=Obj::cfg();
    # remote windows executable forces local only
    if (Cfg::opt('rwe')) {
        $cfg->{systems}=[ $edr->localsys->{sys} ];
        return $cfg->{systems};
    }
    unless (defined $cfg->{systems}) {
        if ($cfg->{opt}{hostfile})    {
            $systems = EDRu::readfile($cfg->{opt}{hostfile});
            $systems =~ s/^\s+//;
            $systems =~ s/\s+$//;
        } else {
            if ($#{$edr->{padvs}}) {
                $msg=Msg::new("Enter the system names separated by spaces:");
            } else {
                $padv=Obj::padv($edr->{padvs}[0]);
                $msg=Msg::new("Enter the $padv->{name} system names separated by spaces:");
            }
            $helpmsg=Msg::new("Systems specified are required to have rsh or ssh configured for password free logins");
            $systems=$msg->ask($def,$helpmsg);
        }
        @systems=split(/\s+/m,$systems);
        $cfg->{systems}=\@systems;
    }
    if ($edr->validate_systemnames(@{$cfg->{systems}})) {
        if (Cfg::opt('responsefile')) {
            $msg=Msg::new("\$CFG{systems} in responsefile has invalid values");
            $msg->die;
        }
        undef($cfg->{systems});
        if (Cfg::opt('hostfile')) {
            $msg=Msg::new("Invalid host file: $cfg->{opt}{hostfile}");
            $msg->warning;
            Cfg::unset_opt('hostfile');
        }
        $edr->cli_select_systems();
    } else {
        return \@{$cfg->{systems}};
    }
    return;
}

sub validate_systemnames {
    my ($edr,@sysl) = @_;
    my ($length,$msg,$fc,$sname);
    return '1' if ($#sysl<0);
    for my $n (0..$#sysl) {
        $sname = sprintf('%s',$sysl[$n]);
        $length = length($sname);
        if ($length >255) {
            $msg=Msg::new("$sysl[$n] is too long for system name");
            $msg->warning;
            return '1';
        }
        # handle the UNSPEC IPv4/IPv6 address
        if ($sname eq '0.0.0.0' || $sname eq '::' || EDRu::iptype_ipv6($sname) =~ m/UNSPEC/i) {
            $msg=Msg::new("$sysl[$n] cannot be used as system name");
            $msg->warning;
            return '1';
        }
        $fc=substr($sysl[$n],0,1);
        $sname=~s/[A-Za-z0-9_-]//mxg;
        if (($sname) && ($sname ne '..') && ($sname ne '...') && ($sname ne '....') && ($sname !~ m/^(:{1,})$/)) {
            $msg=Msg::new("$sysl[$n] is not a valid system name");
            $msg->warning;
            return '1';
        }
        if (EDRu::arrpos($sysl[$n],@sysl)!=$n) {
            $msg=Msg::new("System $sysl[$n] is entered more than once");
            $msg->warning;
            return '1';
        }
        if ($sysl[$n] =~ /^-/m) {
            $msg=Msg::new("System name may not start with a -");
            $msg->warning;
            return '1';
        }
        if ($sysl[$n] =~ /^localhost$/mxi) {
            $msg=Msg::new("'localhost' cannot be used as a system name");
            $msg->warning;
            return '1';
        }
        if ($sysl[$n] =~ /^127\.0\.0\.1$/mx || EDRu::iptype_ipv6($sysl[$n]) =~ m/LOOPBACK/i) {
            $msg=Msg::new("'127.0.0.1' cannot be used as a system name");
            $msg->warning;
            return '1';
        }
    }
    return '';
}

sub init_sys_objects {
    my $edr=shift;
    my(@systems,$cfg,$sysobj,$systems);
    $cfg=Obj::cfg();
    for my $sys (@{$cfg->{systems}}) {
        $sysobj=Sys->new($sys);
        push(@systems, $sysobj);
    }
    $edr->{systems}=\@systems;
    $systems=join(' ', @{$cfg->{systems}});
    Msg::log("Systems Entered : $systems");
    return \@systems;
}

sub create_tempdir_sys {
    my ($edr,$sys) = @_;
    my ($mkdir,$msg);
    # detect if $edr->{tmpdir} there, if so we ran it once, it succeeded
    return 1 if $sys->is_dir("$edr->{tmpdir}");

    $mkdir=$sys->mkdir($edr->{tmpdir});
    if (!$mkdir) {
        $msg=Msg::new("Cannot create $edr->{tmpdir} on $sys->{sys}");
        $sys->push_error($msg);
        $sys->set_value('stop_checks', 1);
        return 0;
    }
    # block non-root to access the log file
    $sys->chmod($edr->{tmpdir}, '700');
    $sys->set_value('cleanup', 1);
    return 1;
}

sub check_timesync {
    my ($edr,$systems,$max_async_secs) = @_;
    my ($localtime,$systime,$sec,$min,$hour,$mday,$mon,$year);
    my ($timediff,$timediff_min,$timediff_max,$msg);

    $systems ||= $edr->{systems};
    if (!$systems) {
        Msg::log("No systems are specified to check time synchronziation.");
        return 1;
    }

    $timediff_min = undef;
    $timediff_max = undef;
    $max_async_secs ||= 5;

    for my $sys (@{$systems}) {
        $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');

        $systime = $sys->cmd('_cmd_date -u +%S:%M:%H:%d:%m:%Y');
        $localtime = EDR::cmd_local('_cmd_date -u +%S:%M:%H:%d:%m:%Y');

        $msg=Msg::new("System time on $sys->{sys} is '$systime'");
        $sys->push_check_note($msg);

        ($sec,$min,$hour,$mday,$mon,$year) = split(/:/m,$systime);
        $systime = Time::Local::timegm ($sec, $min, $hour, $mday, $mon - 1, $year);

        ($sec,$min,$hour,$mday,$mon,$year) = split(/:/m,$localtime);
        $localtime = Time::Local::timegm ($sec, $min, $hour, $mday, $mon - 1, $year);

        $timediff = $systime - $localtime;

        if (!defined($timediff_min) || ($timediff < $timediff_min)) {
            $timediff_min = $timediff;
        }
        if (!defined($timediff_max) || ($timediff > $timediff_max)) {
            $timediff_max = $timediff;
        }
    }

    if ( $timediff_max - $timediff_min > $max_async_secs) {
        return 0;
    }
    return 1;
}

sub ask_timesync {
    my ($edr,$systems,$max_async_secs) = @_;
    my ($msg,$ans,$retry,$servers,@servers,$failed_systems,@failed_systems,$ret,$rtn,$web,$title);

    $systems ||= $edr->{systems};
    if (!$systems) {
        Msg::log("No systems are specified to check time synchronziation.");
        return 1;
    }

    if (Cfg::opt(qw/responsefile makeresponsefile silent/)) {
        # changing system time needs user confirmation.
        # so we don't provide this option with responsefile or in silent mode.
        return 0;
    }

    $max_async_secs||=5;
    if (!Obj::webui()) {
        $msg = Msg::new("Systems have difference in clock by more than $max_async_secs seconds");
        $msg->bold;
        Msg::n();
        $msg = Msg::new("System clocks can be synchronized using one or more Network Time Protocol (NTP) servers");
        $msg->print;
        Msg::n();
    }

    $web = Obj::web();
    $ret = 0;
    while (1) {
        if (Obj::webui()) {
            $msg = Msg::new("Systems have difference in clock by more than $max_async_secs seconds.\nSystem clocks can be synchronized using one or more Network Time Protocol (NTP) servers.\nDo you want to synchronize system clocks with NTP server(s)?");
        } else {
            $msg = Msg::new("Do you want to synchronize system clocks with NTP server(s)?");
        }

        $ans = $msg->ayny();
        Msg::n();
        last if ($ans eq 'N');

        $retry=1;
        while ($retry) {
            $retry = 0;
            $msg = Msg::new("Enter the NTP server names separated by spaces:");
            if (Obj::webui()) {
                $msg->{msg} =~ s/\:+$//g;
                # remember old systemlist and restore them later
                my $systemlist = $web->{systemlist};
                $servers = $web->web_script_form('selectNTPServer', $msg);
                last if (Cfg::opt('back'));
                @servers = @$servers;
                $web->{systemlist} = $systemlist;
                $title = Msg::new("Synchronizing system clock");
                 $web->web_script_form('showstatus', $title);
            } else {
                $servers = $msg->ask(undef,undef,1);
                Msg::n();
                last if (EDR::getmsgkey($servers,'back'));
                @servers = split(/\s/, $servers);
            }

            @failed_systems = ();
            for my $sys (@{$systems}) {
                $sys=Obj::sys($sys) unless (ref($sys) eq 'Sys');
                $msg=Msg::new("Synchronizing system clock on $sys->{sys}");
                if (Obj::webui()) {
                    $title->display_left($msg);
                } else {
                    $msg->left();
                }
                $servers = join(" ",@servers);
                $rtn=$sys->timesync($servers);
                if ($rtn) {
                    $msg=Msg::new("Successfully synchronized time with server '$servers' for $sys->{sys}");
                    $sys->push_action_note($msg);
                    if (Obj::webui()) {
                        $title->display_right();
                    } else {
                        Msg::right_done();
                    }
                } else {
                    $msg=Msg::new("Failed to synchronize time with server '$servers' for $sys->{sys}");
                    $sys->push_action_note($msg);
                    if (Obj::webui()) {
                        $title->display_right('failed');
                    } else {
                        Msg::right_failed();
                    }
                    push @failed_systems , $sys->{sys};
                }
            }
            Msg::n();

            if (@failed_systems) {
                $failed_systems = join(' ', @failed_systems);
                $msg=Msg::new("Failed to synchronize system clock on $failed_systems");
                if (Obj::webui()) {
                    $title->addError($msg->{msg});
                }
                $msg->bold;
                Msg::n();
                $msg=Msg::new("Do you want to retry with other NTP server(s)?");
                $ans=$msg->ayny;
                Msg::n();
                if ($ans eq 'Y') {
                    $retry = 1;
                }
            }
        }

        next if (EDR::getmsgkey($servers,'back'));
        if (Cfg::opt('back')) {
            Cfg::unset_opt('back');
            next;
        }

        # re-check time sync
        $ret = $edr->check_timesync($systems,$max_async_secs);
        if ($ret) {
            $msg = Msg::new("System clock is synchronized on systems");
            $msg->bold;
            Msg::n();
        }
        last;
    }
    return $ret;
}

sub check_and_setup_timesync {
    my ($edr,$systems,$max_async_secs)=@_;
    my ($rtn,$msg);

    $systems ||= $edr->{systems};
    if (!$systems) {
        Msg::log("No systems are specified to check time synchronziation.");
        return 1;
    }

    $max_async_secs||=5;
    $rtn=$edr->check_timesync($systems,$max_async_secs);
    if (!$rtn) {
        $rtn=$edr->ask_timesync($systems,$max_async_secs);
    }
    return $rtn;
}

1;
