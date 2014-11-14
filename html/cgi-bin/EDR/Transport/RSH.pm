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
package Transport::RSH;
use strict;
@Transport::RSH::ISA = qw(Transport);

use constant RSH_PORT => 514;

# To support rsh
sub init_transport {
    my $trans=shift;
    my ($rshpath,$rcppath,$edr,$localpadv);

    $edr=Obj::edr();
    $localpadv=$edr->{localsys}{padv};
    $localpadv=Obj::padv($localpadv) if ($localpadv);
    if ($localpadv) {
        $rshpath=$localpadv->{cmd}{rsh};
        $rcppath=$localpadv->{cmd}{rcp};
    }

    Obj::reset_value($trans, 'rshpath', $rshpath);
    Obj::reset_value($trans, 'rcppath', $rcppath);
    return 1;
}

# Check rsh connection on system
sub check_sys {
    my ($trans,$sys,$user)=@_;
    my ($rshpath,$localsys,$cmd,$sysname,$banner1,$banner2,$rc,$error_no,$error_msg);

    # check rsh
    $rshpath=$trans->{rshpath};
    if (!$rshpath || ! -f $rshpath) {
        $error_no=Transport->EBINARYNOTAVAILABLE;
        if (!$rshpath) {
            $error_msg=Msg::new("rsh binary path is not defined on local system.");
        } else {
            $error_msg=Msg::new("rsh binary '$rshpath' do not exist on local system.");
        }
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    $user||='root';
    $sysname=$sys->{sys};

    # Check whether rshd ready on remote machine, rshd use 514 port.
    $rc=EDRu::is_port_connectable($sysname, Transport::RSH->RSH_PORT);
    if (!$rc) {
        $error_no=Transport->ESERVICENOTAVAILABLE;
        $error_msg=Msg::new("rsh service is not started on $sysname.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    $cmd = "LC_ALL=C LANG=C $rshpath $sysname -l $user echo 2>&1";

    $localsys=EDR::get('localsys');
    $banner1=$localsys->cmd($cmd);
    $rc=EDR::cmdexit();
    if ($rc) {
        # RSH connection is not configured
        if ($banner1=~/permission denied|permission is denied|Host name for your address unknown|login incorrect/mi) {
            $error_no=Transport->ECONNECTIONDENIED;
            $error_msg=Msg::new("rsh permission was denied on $sys->{sys}.");
        } else {
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("rsh exit with $rc on $sys->{sys}.");
        }
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    } else {
        # RSH connection is well
        # Sleep 1, run "echo" again to ensure banner doesn't change when time going along.
        sleep 1;
        $banner2=$localsys->cmd($cmd);

        if ($banner1 ne $banner2) {
            # rsh banner keep changing
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("rsh banner keeps changing on $sys->{sys}.");
            $trans->set_error_sys($sys, $error_no, $error_msg);
            return 0;
        } else {
            chomp $banner1;
            $sys->set_value('banner', $banner1);
            Msg::log("SSH banner on $sys->{sys} is '$banner1'") if ($banner1);
        }
    }

    return 1;
}

# Setup rsh connection between local system and the remote system
sub setup_sys {
    my ($trans,$sys,$user,$passwd,$timeout)=@_;
    my ($rshpath,@cmds,$cmd,$sysname,$prompt,$connected,$rc,$error_no,$error_msg,@fields);
    my ($exp,@exp_params,$remote_home,$remote_os,$host,$hostname,$aliasname,$localsys,@rsh_entries,$rsh_entries);

    # Check rsh binary
    $rshpath=$trans->{rshpath};
    if (!$rshpath || ! -f $rshpath) {
        $error_no=Transport->EBINARYNOTAVAILABLE;
        if (!$rshpath) {
            $error_msg=Msg::new("rsh binary path is not defined on local system.");
        } else {
            $error_msg=Msg::new("rsh binary '$rshpath' do not exist on local system.");
        }
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    # Begin to setup rsh with Expect
    $sysname=$sys->{sys};

    # Check whether rshd ready on remote machine, rshd use 514 port.
    $rc=EDRu::is_port_connectable($sysname, Transport::RSH->RSH_PORT);
    if (!$rc) {
        $error_no=Transport->ESERVICENOTAVAILABLE;
        $error_msg=Msg::new("rsh service is not started on $sysname.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    $user||='root';
    $passwd||='';
    $timeout||=10;

    # Setup Expect object with rsh
    $cmd = "LC_ALL=C LANG=C $rshpath $sysname -l $user 2>&1";

    # 0: means not connected
    # 1: means connected and password is inputed
    # 2: means connected and PS1 prompt is inputed
    # 3: means connected and PS1 prompt is confirmed
    $connected=0;
    $prompt=EDRu->EXPECT_SYMC_PROMPT;

    # RSH login
    @exp_params=(
        [ qr/password:/i         => sub { my $self=shift;
                                         $connected=1;
                                         $self->send("$passwd\r");
                                         $self->exp_continue; } ],
        [ qr/(ogin incorrect|invalid login name or password)/i
                                => sub { $connected=0 } ],
        [ qr/[\]\$\>\#]\s/      => sub { my $self=shift;
                                         $connected=2;
                                         $self->send("PS1='$prompt'\n");
                                         $self->exp_continue; } ],
        [ '-re', qr/$prompt$/   => sub { $connected=3 } ],
    );
    $exp = EDRu::setup_expect($sysname,$user,$passwd,$cmd,$timeout,@exp_params);
    if (!$exp || !$connected){
        $error_no=Transport->EINVALIDPASSWORD;
        $error_msg=Msg::new("Could not set up rsh connection with the Expect module.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    # For some machine, the PS1 is customized and do not has default characters: ], $, #
    if ($connected != 3) {
        $cmd="PS1='$prompt'";
        EDRu::exec_expect($exp,$cmd,$timeout,"^$prompt\$");
    }

    # Get home dir on remote system.
    $cmd="echo HOMEDIR:\$HOME";
    $remote_home=EDRu::exec_expect($exp,$cmd,$timeout,'^HOMEDIR:.*$');
    $remote_home=~s/HOMEDIR://;
    $remote_home=~s/\r+$//;
    if ($remote_home ne "/") {
        $remote_home=~s/\/+$//;
    }
    $sys->set_value('root_home',$remote_home);

    # Get OS type on remote system.
    $cmd="echo OS:\`uname -s\`";
    $remote_os=EDRu::exec_expect($exp,$cmd,$timeout,'^OS:.*$');
    $remote_os=~s/OS://;
    $remote_os=~s/\r+$//;

    # Get the hostname or ip address of local node recognied by remote system.
    if ($remote_os eq 'HP-UX') {
        $cmd="who -u am i";
    } else {
        $cmd="who am i";
    }
    $host=EDRu::exec_expect($exp,$cmd,$timeout,"^$user\\s.*\$");
    @fields=split /\s/, $host;
    $host=$fields[-1];
    chomp $host;
    if ($host =~ /\([^)]*\)/m) {
        $host=~s/\(([^)]*)\)/$1/mx;
    }

    # Add entry in /etc/hosts on remote system if needed.
    @cmds=();

    $aliasname = '';
    if (EDRu::isip($host)) {
        $localsys=EDR::get('localsys');
        $hostname = $localsys->{sys};
        $aliasname = $hostname;
        $aliasname =~ s/\..*//;
        if ($aliasname ne $hostname) {
            push @cmds, "echo \"$host $hostname $aliasname\" >> /etc/hosts";
        } else {
            push @cmds, "echo \"$host $hostname\" >> /etc/hosts";
        }
        $host=$hostname;
    }

    # Add entry in ~/.rhosts on remote system
    @rsh_entries=();
    push @rsh_entries, "$host $user";
    push @rsh_entries, "$aliasname $user" if ($aliasname && $aliasname ne $host);
    for my $rsh_entry (@rsh_entries) {
        push @cmds, "echo \"$rsh_entry\" >> $remote_home/.rhosts";
    }
    $rsh_entries=join "\n", @rsh_entries;
    $sys->set_value('transport_setup_rsh_entries', $rsh_entries);

    # Set permission mode on ~/.rhosts
    push @cmds, "chmod 0600 $remote_home/.rhosts";

    # Set ownership on ~/.rhosts
    push @cmds, "chown $user $remote_home/.rhosts";

    # Execute the commands with Expect
    for my $cmd (@cmds) {
        EDRu::exec_expect($exp,$cmd,$timeout);
    }

    EDRu::close_expect($exp);
    return 1;
}

sub unsetup_sys {
    my ($trans,$sys,$user,$force)=@_;
    my ($localsys,$host,$remote_home,$rhosts_file,$matched);
    my ($rsh_entries,@rsh_entries,$remote_rsh_entries,@remote_rsh_entries,@new_rsh_entries);

    $rsh_entries=$sys->{transport_setup_rsh_entries};
    return 1 unless ($force || $rsh_entries);

    if ($rsh_entries) {
        # previously rsh entries setuped with Expect
        @rsh_entries=split(/\n/, $rsh_entries);
    } else {
        # forcily remove the local host entries in ~/.rhosts file.
        $localsys=EDR::get('localsys');
        $host=$localsys->{sys};
        $user||='root';
        push @rsh_entries, $host.'\s+'.$user;
        push @rsh_entries, $host.'\..*\s+'.$user;
    }

    $remote_home=$sys->{root_home} || $sys->get_root_home();
    $rhosts_file="$remote_home/.rhosts";

    $remote_rsh_entries=$sys->readfile($rhosts_file);
    @remote_rsh_entries=split(/\n/, $remote_rsh_entries);

    # kick off those rsh entries for the local host in ~/.rhosts file.
    @new_rsh_entries=();
    for my $remote_rsh_entry (@remote_rsh_entries) {
        $matched=0;
        for my $rsh_entry (@rsh_entries) {
            if ($remote_rsh_entry =~ /^$rsh_entry$/m) {
                $matched=1;
                last;
            }
        }
        next if ($matched);
        push @new_rsh_entries, $remote_rsh_entry;
    }

    if (@new_rsh_entries) {
        # return 0 if no rsh entries are removed
        return 0 if (scalar @new_rsh_entries == scalar @remote_rsh_entries);

        $rsh_entries=join "\n", @new_rsh_entries;
        $rsh_entries.="\n";
        $sys->writefile($rsh_entries, $rhosts_file);
    } else {
        $sys->rm($rhosts_file);
    }
    return 1;
}

sub cmd_sys {
    my ($trans,$sys,$cmd)=@_;
    my ($rshpath,$rsh,$lang,$shell,$background,$multicmds);
    my ($stdout,$stderr,$exitcode,$echo_cmd_exit);

    $rshpath=$trans->{rshpath};

    $rsh = "$rshpath $sys->{sys}";

    $background=1 if ($cmd =~ /&\s*$/m);
    $multicmds=1 if ($cmd =~ /[\|;]/m);

    $cmd = Sys::escape_remote_command($cmd);

    # do not use "$cmd 2>&1", "LANG=C $cmd" and "$cmd; echo $?"
    # when the remote root shell is not determined,
    # since they do not work well with csh/tcsh.
    $shell=$sys->{shell};
    if ($shell) {
        # if the remote shell is determined, then append redirection,
        $cmd.=" 2>&1" if ($cmd!~/2>/);

        $lang='LC_ALL=C LANG=C';
        $lang='LC_ALL=C; LANG=C; export LC_ALL LANG;' if ($multicmds);
        $cmd="$lang $cmd";

        # if using rsh and not background command, then need use _CMD_EXIT_
        $cmd="$cmd; echo _CMD_EXIT_=\\\$?" if (!$background);
    }

    if ($shell && $shell=~/csh/m) {
        # if the remote root shell is tcsh/csh, then use padv specific sh.
        $shell='';
        $shell=$sys->padv->{cmd}{sh} if ($sys->{padv});
        $shell||='/bin/sh';

        $cmd = "echo \"$cmd\" | $rsh $shell 2>&1";
    } else {
        # the remote root shell is bash/ksh/sh
        # or in initial stage when the remote root shell is not determined.
        # Notes: make sure the initial commands be csh/sh redirection compatible.
        $cmd = "$rsh \"$cmd\" 2>&1";
    }

    # Execute the command on local system
    for my $counter (1..5) {
        ($stdout,$stderr,$exitcode,$cmd)=Sys::run_local_command($cmd);
        if ($exitcode &&
            (!$stdout ||
             $stdout =~ /rcmd: socket: Cannot assign requested address/m ||
             $stdout =~ /rcmd_af: primary connection shut down/m ||
             $stdout =~ /poll: protocol failure in circuit setup/m
            )) {
            # exceed upper limit of system concurrent TCP connections used by rsh (512/60s, ports lower than 1024)
            # wait 15 seconds for any TCP connection from time_wait to close
            # we detect this condition with the stdout: rcmd: socket: Cannot assign requested address
            # but sometime rsh just fail silently with exit_code 1 and no stdout, we consider this as well
            Msg::log("Local system exceed the upper limit of concurrent TCP connections used by rsh, sleep 15 seconds and retry: $counter");
            sleep 15;
        } else {
            last;
        }
    }

    # Get command exit code
    $echo_cmd_exit=1 if ($cmd=~/_CMD_EXIT_/m);
    if ($echo_cmd_exit && $stdout=~/^(.*)_CMD_EXIT_=\s*(-?\d+)/mxs) {
        $stdout="$1";
        $exitcode="$2";
        chomp $stdout;
    }

    # Remove Banner
    $stdout=Sys::remove_banner_sys($sys,$stdout);

    return ($stdout,$stderr,$exitcode,$cmd);
}

sub copy_to_sys {
    my ($trans,$sys_src,$file_src,$sys_dest,$file_dest) = @_;
    my ($rcppath,$locals,$host_src,$host_dest,$rtn,$retry,$retries,$msg,$cmd);

    $locals=0;
    $locals++ if ($sys_src->{islocal});
    $locals++ if ($sys_dest->{islocal});

    if ($locals != 1) {
        $msg=Msg::new("Transport::RSH::copy_to_sys() only supports copying files from the remote system to the local system, or from the local system to the remote system.");
        $msg->print;
        return 0;
    }

    $host_src=$sys_src->{sys};
    $host_src="[$host_src]" if (EDRu::ip_is_ipv6($host_src));
    $host_dest=$sys_dest->{sys};
    $host_dest="[$host_dest]" if (EDRu::ip_is_ipv6($host_dest));

    # Call rcp
    $rcppath=$trans->{rcppath};
    if ($sys_src->{islocal}) {
        $cmd="$rcppath -rp $file_src $host_dest:$file_dest";
    } elsif ($sys_dest->{islocal}) {
        $cmd="$rcppath -rp $host_src:$file_src $file_dest";
    }

    $retry = 0;
    $retries = 3;
    while ($retry<$retries) {
        $retry++;
        EDR::cmd_local("$cmd");
        $rtn=EDR::cmdexit();
        if ($rtn) {
            Msg::log("Failed to copy $file_src from $sys_src->{sys} to $file_dest on $sys_dest->{sys}, retry $retry");
        } else {
            last;
        }
    }

    return (!$rtn);
}

1;
