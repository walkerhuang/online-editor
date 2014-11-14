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

# ssh or rsh is already OK, return 0,
# setup ssh or rsh, return 1,
# canceled by user, return -1.
sub ask_com_setup {
    my($edr,$systems)=@_;
    my(@denied_systems,$conf,$rtn);

    $systems ||= $edr->{systems};

    while (1) {
        # keep asking passwords until all systems have correct password,
        # or canceld by user by input 'q'

        # Get the systems which tranportation is denied.
        @denied_systems=();
        for my $sys (@{$systems}) {
            if ($sys->{sshrsh_failure}) {
                # Directly return -1 if any systems can not setup ssh/rsh
                # due to system configure reason.
                return -1;
            }

            if ($sys->{com_deny}) {
                push @denied_systems, $sys;
            }
        }

        # ssh or rsh is ready on all systems.
        return 0 unless (@denied_systems);

        # $conf return -1, means user cancel to answer the question.
        # $conf return 0,  means user request back to answer the question again.
        $conf=$edr->ask_setup_transport_questions(\@denied_systems);
        return -1 if ($conf==-1);
        next if ($conf==0);

        # $rtn return 1, means transport setup successfully for all systems
        # $rtn return 0, means transport setup not successfully for some systems, need retry to input passwords for those systems.
        $rtn=$edr->setup_transports(\@denied_systems,$conf);
        return 1 if ($rtn==1);
    }
    return 0;
}

# return -1, means user cancel setup the transportation
# return 0,  means back
# return a hash, means passwords inputted.
sub ask_setup_transport_questions {
    my($edr,$systems)=@_;
    my($system_names,$conf,$ayn,$msg,$help,$rtn,$passwd,$passwd0,$same_passwd,$web,$result,$sysi,@menu,$backopt);

    $system_names=join ' ', map { $_->{sys} } @{$systems};

    # Ask if want to setup transportation between systems
    if (Cfg::opt('rsh')) {
        $help=Msg::new("rsh needs to be set up between the local system and $system_names for communication");
        $help->printn;
        $msg=Msg::new("Would you like the installer to setup rsh communication automatically between the systems?\nSuperuser passwords for the systems will be asked.");
    } elsif (Cfg::opt('ssh')) {
        $help=Msg::new("ssh needs to be set up between the local system and $system_names for communication");
        $help->printn;
        $msg=Msg::new("Would you like the installer to setup ssh communication automatically between the systems?\nSuperuser passwords for the systems will be asked.");
    } else {
        $help=Msg::new("Either ssh or rsh needs to be set up between the local system and $system_names for communication");
        $help->printn;
        $msg=Msg::new("Would you like the installer to setup ssh or rsh communication automatically between the systems?\nSuperuser passwords for the systems will be asked.");
    }
    $ayn=$msg->ayny($help);
    Msg::n();
    return -1 if ($ayn eq 'N');

    # use seperate hash to store sys/passwd values so it's not recorded anywhere
    $conf={};

    # Ask root's password if want to setup transportation between systems
    if (Obj::webui()) {
        $web=Obj::web();
        $result=$web->web_script_form('systems_psw',@$systems);
        $rtn=delete $result->{selected_ssh_rsh_method};
        for my $sys (@{$systems}) {
            $sysi=$sys->{sys};
            $conf->{$sysi}{transport_setup_passwd}=$result->{$sysi};
        }
    } else {
        $same_passwd=0;
        # Ask password for each node separately because passwds may include space characters.
        for my $sys (@{$systems}) {
            $sysi=$sys->{sys};
            if (!$same_passwd) {
                $msg=Msg::new("Enter the superuser password for system $sysi: ");
                EDR::cmd_local('stty -echo');
                $msg->bold(1);
                chomp ($passwd = <STDIN>);
                EDR::cmd_local('stty echo');
                Msg::n();  # to end the password input
                Msg::n();
            } else {
                $passwd = $passwd0;
            }
            $conf->{$sysi}{transport_setup_passwd} = $passwd;

            if ($sys == $systems->[0] && $#$systems > 0) {
                $msg=Msg::new("Do you want to use the same password for all systems?");
                $help = Msg::new("Answer 'Y' if all systems have the same superuser password. Otherwise passwords need to be provided for each system.");
                $ayn=$msg->ayny($help);
                Msg::n();
                if ($ayn eq 'Y') {
                    $same_passwd = 1;
                    $passwd0 = $passwd;
                }
            }
        }

        # Ask transportation type, rsh or ssh
        if (Cfg::opt('rsh')) {
            $rtn = 2;
        } elsif (Cfg::opt('ssh')) {
            $rtn = 1;
        } else {
            $backopt=1;
            @menu=();
            $msg=Msg::new("Setup ssh between the systems");
            push @menu, $msg->{msg};
            $msg=Msg::new("Setup rsh between the systems");
            push @menu, $msg->{msg};
            $help = Msg::new("This is the communication method prompt");
            $msg=Msg::new("Select the communication method");
            $rtn=$msg->menu(\@menu,1,$help,$backopt);
            Msg::n();
        }
        return 0 if (EDR::getmsgkey($rtn,'back'));
    }
    $edr->{transport_setup_method} = ($rtn == 1) ? 'ssh':'rsh';

    return $conf;
}

# return 1, means transport setup successfully for all systems
# return 0, means transport setup not successfully for some systems, need retry to input passwords for those systems.
sub setup_transports {
    my($edr,$systems,$conf)=@_;
    my ($sysi,$method,$passwd,$timeout,$msg,$rtn,@invalid_password_systems,$system_names,$web,$webmsg,$localpadv);

    $timeout=20;

    $msg=Msg::new("Setting up communication between systems. Please wait.");
    $msg->print;

    for my $sys (@$systems) {
        $sysi=$sys->{sys};
        $method=$conf->{$sysi}{transport_setup_method} || $edr->{transport_setup_method};
        $passwd=$conf->{$sysi}{transport_setup_passwd} || '';

        $rtn=$sys->setup_connection($method,'root',$passwd,$timeout);
        if ($rtn) {
            # Setup transport successfully with the password
            push @{$edr->{transport_setup_systems}}, $sys;
            $sys->{com_deny}=0 if ($sys->{com_deny});
        } else {
            # Setup transport not successfully with the password
            push @invalid_password_systems, $sysi;
        }
    }

    if (scalar @invalid_password_systems == 0 ) {
        EDR::reset_errors_warnings();

        $msg=Msg::new("Re-verifying systems.");
        $msg->printn;
        sleep 2;
        return 1; # need verify again
    } else {
        # password invalid on one or more systems.
        Msg::n();

        @{$edr->{transport_failed_sys}} = @invalid_password_systems;
        $system_names = join ' ',@invalid_password_systems;
        $msg=Msg::new("Failed to set up $edr->{transport_setup_method} connection with remote system(s) $system_names.\nMake sure the password(s) are correct or superuser(root) can run $edr->{transport_setup_method} command correctly on the remote system(s) with the password(s).");
        $msg->printn;

        $webmsg = $msg->{msg}."\n";
        if ($edr->{transport_setup_method} eq 'rsh') {
            $localpadv=Obj::padv(Obj::localpadv());
            $msg=Msg::new("If you want to set up rsh on remote system(s), make sure rsh with command argument ('$localpadv->{cmd}{rsh} <host> <command>') is not denied by the remote system(s).");
            $msg->printn;
            $webmsg .= $msg->{msg}."\n";
        }
        $web = Obj::web();
        $web->web_script_form('alert',$webmsg) if (Obj::webui());
    }

    return 0;
}

# ssh or rsh is already cleanuped, return 0,
# cleanup ssh or rsh, return 1,
# canceled by user, return -1.
sub ask_com_cleanup {
    my ($edr,$systems) = @_;
    my ($transport,$sysi,$cleanup_systems,$system_names,$msg,$ayn,$rtn,$fail,$web,$webmsg);

    # do not ask if cleanup transportation if user type CTRL+C
    return 0 if (is_terminating());

    return 0 if (!$systems || $#$systems<0);

    # Get what systems need be unsetup transportation
    $webmsg='';
    $cleanup_systems=[];
    for my $sys (@{$systems}) {
        $sysi=$sys->{sys};
        $transport = lc($sys->{transport});
        if ($sys->{islocal}) {
            $msg = Msg::new("$sysi is the local system");
            $webmsg .= $msg->{msg}.'\\n';
            # the following changes are for 3558011 	
            # the $sys->{islocal} is set to 1 for Cfg::opt('makeresponsefile')
            # therefore we can't trust $sys->{islocal} here
            $rtn = EDR::get('localsys');
            if ($rtn->{sys} eq $sysi) {
                $msg->print;
            } elsif (!$sys->{stop_checks}) {
                # this if section is for Etrack 3573073
                # dealing with -makeresponsefile that has transport setup 
                push @{$cleanup_systems}, $sys;
                $sys->{islocal} = 0;
                $sys->set_value('islocal', $sys->{islocal});
            }
        } elsif ($transport) {
            $msg = Msg::new("$transport is configured in password-less mode on $sysi");
            $webmsg .= $msg->{msg}.'\\n';
            $msg->print;
            push @{$cleanup_systems}, $sys;
        }
    }
    # if any fail message
    Msg::n() if ($webmsg);

    return 0 unless (@{$cleanup_systems});

    if (!Cfg::opt(qw(comcleanup comsetup))) {
        $system_names=join ' ', map { $_->{sys} } @{$cleanup_systems};
        $msg=Msg::new("Do you want to cleanup the communication for the systems $system_names?");
        $ayn=$msg->aynn('','',$webmsg);
        Msg::n();
        if ($ayn eq 'N') {
            return -1;
        }
    }

    $fail=0;
    for my $sys (@{$cleanup_systems}) {
        $msg=Msg::new("Cleanup the communication for the system $sys->{sys}");
        $msg->left;

        # do edr cleanup on $sys now as we will not be able to do that after the ssh/rsh comm is unconfigured
        if ($edr->{tmpdir} && $edr->{tmpdir} =~ /\d+/mx ) {
            $sys->rm($edr->{tmpdir});
            $sys->{cleanup} = 0;
        }

        # unsetup_connection() parameters: $transport,$user,$force
        $rtn=$sys->unsetup_connection('','',1);
        if ($rtn) {
            Msg::right_done();
#            $msg->display_right() if (Obj::webui());
        } else {
            Msg::right_failed();
            $fail=1;
        }
    }
    Msg::n();

    return -1 if ($fail);
    return 1;
}

# ssh or rsh is already cleanuped, return 0,
# cleanup ssh or rsh, return 1,
# canceled by user, return -1.
sub cleanup_com_setup {
    my ($edr,$systems) = @_;

    # Do not cleanup transport if user is running with '-comsetup' option
    return 0 if (Cfg::opt(qw(comsetup)));

    # Get what systems need be unsetup transportation
    $systems ||= $edr->{transport_setup_systems};
    # remove $edr->{transport_setup_systems} in case it's used again
    undef $edr->{transport_setup_systems};
    return 0 if (!$systems || $#$systems<0);
    
    return $edr->ask_com_cleanup($systems);
}

# ssh or rsh is already OK, return 0,
# setup ssh or rsh, return 1,
# canceled by user, return -1.
sub check_and_setup_transport_sys {
    my ($edr, $sys) = @_;
    return $edr->check_and_setup_transport([$sys]);
}

# ssh or rsh is already OK, return 0,
# setup ssh or rsh, return 1,
# canceled by user, or ssh and rsh service not available on target machine, return -1.
sub check_and_setup_transport {
    my ($edr,$systems) = @_;
    my ($msg,$rtn,$fail,$setup_systems);
    my $web = Obj::web();
    $systems||=$edr->{systems};

    $rtn=0;
    while (1) {
        $fail=0;
        $setup_systems=[];
        for my $sys (@{$systems}) {
            $msg=Msg::new("Checking communication on $sys->{sys}");
            $msg->left();
            $msg->display_left($msg) if (Obj::webui());

            $sys->{stop_checks}=0;
            if ($edr->transport_sys($sys)) {
                # transport channel is ready
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
            } else {
                # transport channel is not ready, show errors
                Msg::right_failed();
                if ($sys->{com_deny}) {
                    push @{$setup_systems}, $sys;
                }
                $fail=1;
            }
        }

        if ($fail) {
            Msg::n();
            $web->{comm_err} = 1 if (Obj::webui());
            for my $sys (@{$systems}) {
                for my $errmsg (@{$sys->{errors}}) {
                    if(Obj::webui()){
                       $msg->addError($errmsg);
                    }
                    Msg::print("$errmsg\n");
                }
                undef $sys->{errors};
            }
            return -1 unless (@{$setup_systems});
        } else {
            undef $web->{comm_err} if (Obj::webui());
            return $rtn;
        }

        # If transport is just denied for some systems, try to setup transportation.
        if (!EDR::local_windows() &&
            !Cfg::opt("responsefile")) {
            $rtn=$edr->ask_com_setup($setup_systems);
            if ($rtn==-1) {
                # cancel by user to setup transport
                return -1;
            } elsif ($rtn==1) {
                # setup tranport successfully, re-verify
                next;
            }
        }
        last;
    }

    return 0;
}

# ssh or rsh is already cleanuped, return 0,
# cleanup ssh or rsh, return 1,
# canceled by user, return -1.
sub check_and_cleanup_transport {
    my ($edr,$systems) = @_;
    my ($msg,$rtn,$fail,$cleanup_systems);

    $systems||=$edr->{systems};

    $rtn=0;
    while (1) {
        $cleanup_systems=[];
        for my $sys (@{$systems}) {
            $msg=Msg::new("Checking communication on $sys->{sys}");
            $msg->left();
            $msg->display_left($msg) if (Obj::webui());

            $sys->{stop_checks}=0;
            undef $sys->{transport_obj};
            if ($edr->transport_sys($sys)) {
                # transport channel is ready
                Msg::right_done();
                $msg->display_right() if (Obj::webui());
                push @{$cleanup_systems}, $sys;
            } else {
                # transport channel is not ready, show errors
                Msg::right_failed();
            }
        }
        Msg::n();

        return $rtn unless (@{$cleanup_systems});

        $rtn=$edr->ask_com_cleanup($cleanup_systems);
        if ($rtn==-1) {
            return -1;
        } elsif ($rtn==1) {
            # cleanup tranport successfully, re-verify
            $msg=Msg::new("Re-verifying systems.");
            $msg->printn;
            next;
        }
        last;
    }

    return 0;
}

1;
