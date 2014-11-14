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
package Transport::SSH;
use strict;
@Transport::SSH::ISA = qw(Transport);

# To support ssh
sub init_transport {
    my $trans=shift;
    my ($sshpath,$sshoptions,$sshoptions_pwd,$scppath,$scpoptions,$scpoptions_pwd,$keyfile,$edr,$localpadv);

    $edr=Obj::edr();
    $localpadv=$edr->{localsys}{padv};
    $localpadv=Obj::padv($localpadv) if ($localpadv);

    $keyfile=Cfg::opt('keyfile');
    $sshpath=Cfg::opt('sshpath') || $ENV{SSHPATH};
    if ($sshpath) {
        $sshoptions=$ENV{SSHOPTIONS}||'';
        $sshoptions_pwd=$ENV{SSHOPTIONS_PWD}||$sshoptions;
    } else {
        $sshpath=$localpadv->{cmd}{ssh} if ($localpadv);
        if ($sshpath) {
            # in cps_transport_sys, set the timout as 10 seconds to check if the input ip is up
            if (defined $edr->{ssh_time_out}) {
                $sshoptions="-x -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no -o ConnectTimeout=$edr->{ssh_time_out}";
            } else {
                $sshoptions='-x -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no';
            }
            $sshoptions.=' -o GSSAPIAuthentication=no' if ($edr->{no_gssapi});
            $sshoptions.=" -i $keyfile" if ($keyfile);
            $sshoptions_pwd="-o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'";
            $sshoptions_pwd.=' -o GSSAPIAuthentication=no' if ($edr->{no_gssapi});
            $sshoptions_pwd.=" -i $keyfile" if ($keyfile);
        }
    }

    $scppath=Cfg::opt('scppath') || $ENV{SCPPATH};
    if ($scppath) {
        $scpoptions=$ENV{SCPOPTIONS} || $ENV{SSHOPTIONS} || '' ;
        $scpoptions_pwd=$ENV{SCPOPTIONS_PWD} || $scpoptions ;
    } else {
        $scppath=$localpadv->{cmd}{scp} if ($localpadv);
        if ($scppath) {
            $scpoptions="-o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'";
            $scpoptions.=' -o GSSAPIAuthentication=no' if ($edr->{no_gssapi});
            $scpoptions.=" -i $keyfile" if ($keyfile);
            $scpoptions_pwd=$scpoptions;
        }
    }

    Obj::reset_value($trans, 'sshpath', $sshpath);
    Obj::reset_value($trans, 'sshoptions', $sshoptions);
    Obj::reset_value($trans, 'sshoptions_pwd', $sshoptions_pwd);
    Obj::reset_value($trans, 'scppath', $scppath);
    Obj::reset_value($trans, 'scpoptions', $scpoptions);
    Obj::reset_value($trans, 'scpoptions_pwd', $scpoptions_pwd);

    return 1;
}

# Check ssh connection on system
sub check_sys {
    my ($trans,$sys,$user)=@_;
    my ($sshpath,$sshoptions,$sshbinary,$localsys,$cmd,$sysname,$banner1,$banner2,$rc,$error_no,$error_msg);

    # check ssh
    $sshpath=$trans->{sshpath};
    $sshbinary=$sshpath;
    $sshbinary=~s/\s.*$//;
    if (!$sshpath || ! -f $sshbinary) {
        $error_no=Transport->EBINARYNOTAVAILABLE;
        if (!$sshpath) {
            $error_msg=Msg::new("ssh binary path is not defined on the local system.");
        } else {
            $error_msg=Msg::new("ssh binary '$sshpath' does not exist on the local system.");
        }
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    $user||='root';
    $sysname=$sys->{sys};

    $sshoptions=$trans->{sshoptions};
    $cmd = "LC_ALL=C LANG=C $sshpath $sshoptions $user\@$sysname echo";

    $localsys=EDR::get('localsys');
    $banner1=$localsys->cmd("$cmd 2>&1");
    $rc=EDR::cmdexit();
    if ($rc) {
        # SSH connection is not configured
        if ($banner1=~/Connection refused/mi) {
            $error_no=Transport->ESERVICENOTAVAILABLE;
            $error_msg=Msg::new("ssh service is not started on $sys->{sys}.");
        } elsif ($banner1=~/Permission denied/mi) {
            $error_no=Transport->ECONNECTIONDENIED;
            $error_msg=Msg::new("ssh permission was denied on $sys->{sys}.");
        } else {
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("ssh exit with $rc on $sys->{sys}.");
        }
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    } else {
        # SSH connection is well
        # Run "echo" again to ensure banner doesn't include extra words
        $banner1=$localsys->cmd("$cmd 2>/dev/null");

        # Sleep 1, run "echo" again to ensure banner doesn't change when time going along.
        sleep 1;
        $banner2=$localsys->cmd("$cmd 2>/dev/null");

        if ($banner1 ne $banner2) {
            # ssh banner keep changing
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("ssh banner keeps changing on $sys->{sys}.");
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

# Setup ssh connection between local system and the remote system
sub setup_sys {
    my ($trans,$sys,$user,$passwd,$timeout)=@_;
    my ($sshpath,$sshoptions,$sshoptions_pwd,$sshbinary,$scppath,$scpoptions);
    my ($cmd,$sysname,$error,$error_no,$error_msg);
    my (@keyfiles,$keyfile,$keyfile_public,$keyfile_tmp,$sshkey);
    my ($exp,@exp_params,$prompt,$connected,@cmds);
    my ($localsys,$local_home,$remote_home,$ssh_dir,$authorized_keys_file);

    # Check ssh binary
    $sshpath=$trans->{sshpath};
    $sshbinary=$sshpath;
    $sshbinary=~s/\s.*$//;
    if (!$sshpath || ! -f $sshbinary) {
        $error_no=Transport->EBINARYNOTAVAILABLE;
        if (!$sshpath) {
            $error_msg=Msg::new("ssh binary path is not defined on the local system.");
        } else {
            $error_msg=Msg::new("ssh binary '$sshpath' does not exist on the local system.");
        }
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    $localsys=EDR::get('localsys');
    $local_home = $localsys->get_root_home();

    # Create ssh-key file if no key/pub exist already, specified by "-keyfile" or default.
    @keyfiles=();
    $keyfile = Cfg::opt('keyfile');
    push(@keyfiles, $keyfile) if ($keyfile);
    push(@keyfiles, "$local_home/.ssh/id_rsa");
    push(@keyfiles, "$local_home/.ssh/id_dsa");

    $keyfile='';
    $keyfile_public='';
    for my $file (@keyfiles) {
        if (-f "$file" && -f "$file".'.pub') {
            $keyfile=$file;
            $keyfile_public="$file".'.pub';
            last;
        }
    }
    if (!$keyfile) {
        $keyfile="$local_home/.ssh/id_rsa";
        $keyfile_public=$keyfile.'.pub';
        EDR::cmd_local("_cmd_sshkeygen -q -t rsa -N \'\' -f $keyfile 2>/dev/null");
    }

    if (-f "$keyfile") {
        $sys->set_value('transport_setup_keyfile', $keyfile_public);
    } else {
        $error_no=Transport->EUNKNOWNERROR;
        $error_msg=Msg::new("Could not generate ssh key file on the local system.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    # Begin to setup ssh with Expect
    $sysname=$sys->{sys};
    $user||='root';
    $passwd||='';
    $timeout||=5;

    # Copy ssh public key file to remote
    $connected=1;
    $keyfile_tmp='/var/tmp/symc_auto_keyfile.' . $localsys->{sys};
    $scppath=$trans->{scppath};
    $scpoptions=$trans->{scpoptions_pwd};
    $cmd = "LC_ALL=C LANG=C $scppath $scpoptions $keyfile_public $user\@[$sysname]:$keyfile_tmp 2>&1";
    @exp_params = (
        [ qr/\(yes\/no\)\?\s*$/ => sub { my $self=shift;
                                         $self->send("yes\n");
                                         $self->exp_continue; } ],
        #[ '-re', qr/ermission denied/mi => sub { $connected=0 } ],
        [ qr/(ermission denied|many authentication failures)/i
                                => sub { $connected=0 } ],
        [ qr/assword:\s*$/      => sub { my $self=shift;
                                         $self->send("$passwd\n");
                                         $self->exp_continue;  } ],
    );

    ($exp,undef,$error) = EDRu::setup_expect($sysname,$user,$passwd,$cmd,$timeout,@exp_params);
    if (!$exp){
        $error_no=Transport->EUNKNOWNERROR;
        $error_msg=Msg::new("Could not set up scp connection with the Expect module.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }
    EDRu::close_expect($exp);

    if (!$connected) {
        $error_no=Transport->EINVALIDPASSWORD;
        $error_msg=Msg::new("Could not scp key file onto $sysname with the password.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    # if $error begin with 1: timeout.
    # if $error begin with 4: unknown error.
    # if $error begin with 3 and not end with 'status 0': scp command finished with some errors
    # if $error begin with 3 and end with 'status 0': scp command finished successfully
    # if $error begin with 2: scp command finished successfully
    if ($error) {
        if ($error=~/^1/m) {
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("Could not scp key file onto $sysname due to timeout.");
            $trans->set_error_sys($sys, $error_no, $error_msg);
            return 0;
        } elsif ($error=~/^4/m) {
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("Could not scp key file onto $sysname due to unknown issues.");
            $trans->set_error_sys($sys, $error_no, $error_msg);
            return 0;
        } elsif ($error=~/^3/m && $error!~/status 0$/mi) {
            $error_no=Transport->EUNKNOWNERROR;
            $error_msg=Msg::new("Could not scp key file onto $sysname due to scp command failed.");
            $trans->set_error_sys($sys, $error_no, $error_msg);
            return 0;
        }
    }

    # Setup Expect object with ssh
    $sshoptions_pwd=$trans->{sshoptions_pwd};
    $cmd="LC_ALL=C LANG=C $sshpath $sshoptions_pwd $user\@$sysname 2>&1";

    # 0: means not connected
    # 1: means connected and password is inputed
    # 2: means connected and PS1 prompt is inputed
    # 3: means connected and PS1 prompt is confirmed
    $connected=0;
    $prompt=EDRu->EXPECT_SYMC_PROMPT;

    # SSH login
    @exp_params=(
        [ qr/\(yes\/no\)\?\s*$/ => sub { my $self=shift;
                                         $connected=1;
                                         $self->send("yes\n");
                                         $self->exp_continue; } ],
        [ qr/ogin:\s*$/         => sub { my $self=shift;
                                         $connected=1;
                                         $self->send("$user\n");
                                         $self->exp_continue; } ],
        [ qr/ermission denied/i => sub { $connected=0 } ],
        [ qr/assword.*?:/       => sub { my $self=shift;
                                         $connected=1;
                                         $self->send("$passwd\n");
                                         $self->exp_continue; } ],
        [ qr/[\]\$\>\#]\s/      => sub { my $self=shift;
                                         $connected=2;
                                         $self->send("PS1='$prompt'\n");
                                         $self->exp_continue; } ],
        [ '-re', qr/$prompt$/   => sub { $connected=3 } ],
    );
    $exp = EDRu::setup_expect($sysname,$user,$passwd,$cmd,$timeout,@exp_params);
    if (!$exp || !$connected){
        $error_no=Transport->EINVALIDPASSWORD;
        $error_msg=Msg::new("Could not setup ssh connection with $sysname.");
        $trans->set_error_sys($sys, $error_no, $error_msg);
        return 0;
    }

    # For some machine, the PS1 is customized and do not has default characters: ], $, #
    if ($connected != 3) {
        $cmd="PS1='$prompt'";
        EDRu::exec_expect($exp,$cmd,$timeout,"^$prompt\$");
    }

    # get home dir on remote system.
    $cmd="echo HOMEDIR:\$HOME";
    $remote_home=EDRu::exec_expect($exp,$cmd,$timeout,'^HOMEDIR:.*$');
    $remote_home=~s/HOMEDIR://;
    $remote_home=~s/\r+$//;
    if ( $remote_home ne "/") {
        $remote_home=~s/\/+$//;
    }
    $sys->set_value('root_home',$remote_home);

    # mkdir $remotehome/.ssh, set its ownership/mode, and add pub key file as authorized key
    $ssh_dir="$remote_home/.ssh";
    $authorized_keys_file="$ssh_dir/authorized_keys";

    @cmds=(
        "mkdir -p $ssh_dir",
        "chmod 0700 $ssh_dir",
        "chown $user $ssh_dir",
        "cat $keyfile_tmp >> $authorized_keys_file",
        "chmod 0600 $authorized_keys_file",
        "chown $user $authorized_keys_file",
        "rm -rf $keyfile_tmp",
        "/sbin/restorecon -v $authorized_keys_file",
    );

    for my $cmd (@cmds) {
        EDRu::exec_expect($exp,$cmd,$timeout);
    }

    EDRu::close_expect($exp);
    return 1;
}

sub unsetup_sys {
    my ($trans,$sys,$user,$force)=@_;
    my ($localsys,$remote_home,$sshkey,$keyfile,$authorized_keys_file,@cmds,$cmd);

    $keyfile=$sys->{transport_setup_keyfile};
    return 1 unless ($force || $keyfile);

    $user||='root';
    $localsys=EDR::get('localsys');
    $sshkey=$user.'@'.$localsys->{sys};

    $remote_home=$sys->{root_home} || $sys->get_root_home();
    $authorized_keys_file="$remote_home/.ssh/authorized_keys";
    if ($sys->exists($authorized_keys_file)) {
        @cmds=(
            "_cmd_cp -f $authorized_keys_file $authorized_keys_file.bak 2>/dev/null",
            "_cmd_grep -v '$sshkey' $authorized_keys_file.bak > $authorized_keys_file 2>/dev/null",
            "_cmd_chmod 0600 $authorized_keys_file 2>/dev/null",
        );
        $cmd=join(';',@cmds);
        $sys->cmd($cmd);
    }
    return 1;
}

sub cmd_sys {
    my ($trans,$sys,$cmd)=@_;
    my ($sshpath,$sshoptions,$ssh,$lang,$shell,$multicmds);
    my ($stdout,$stderr,$exitcode);

    $sshpath=$trans->{sshpath};
    $sshoptions=$trans->{sshoptions};

    $ssh = "$sshpath $sshoptions $sys->{sys}";
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
    }

    if ($shell && $shell=~/csh/m) {
        # if the remote root shell is tcsh/csh, then use padv specific sh.
        $shell='';
        $shell=$sys->padv->{cmd}{sh} if ($sys->{padv});
        $shell||='/bin/sh';

        $cmd = "echo \"$cmd\" | $ssh $shell 2>/dev/null";
    } else {
        # the remote root shell is bash/ksh/sh
        # or in initial stage when the remote root shell is not determined.
        # Notes: make sure the initial commands be csh/sh redirection compatible.
        $cmd = "$ssh \"$cmd\" 2>/dev/null";
    }

    # Execute the command on local system
    for my $counter (1..2) {
        ($stdout,$stderr,$exitcode,$cmd)=Sys::run_local_command($cmd);
        if ($exitcode == 255) { 
            # ssh exits with the exit status of the remote command
            # or ssh exits with 255 if an error occurred.
            # retry one more time if ssh exits with 255
            Msg::log("SSH exits with 255, sleep 1 second and retry: $counter");
            sleep 1;
        } else {
            last;
        }
    }

    # Remove Banner
    $stdout=Sys::remove_banner_sys($sys,$stdout);

    return ($stdout,$stderr,$exitcode,$cmd);
}

sub copy_to_sys {
    my ($trans,$sys_src,$file_src,$sys_dest,$file_dest) = @_;
    my ($scppath,$scpoptions,$locals,$host_src,$host_dest,$rtn,$retry,$retries,$msg,$cmd);

    $locals=0;
    $locals++ if ($sys_src->{islocal});
    $locals++ if ($sys_dest->{islocal});

    if ($locals != 1) {
        $msg=Msg::new("Transport::SSH::copy_to_sys() only supports copying files from the remote system to the local system, or from the local system to the remote system.");
        $msg->print;
        return 0;
    }

    $host_src=$sys_src->{sys};
    $host_src="[$host_src]" if (EDRu::ip_is_ipv6($host_src));
    $host_dest=$sys_dest->{sys};
    $host_dest="[$host_dest]" if (EDRu::ip_is_ipv6($host_dest));

    $scppath=$trans->{scppath};
    $scpoptions=$trans->{scpoptions};
    if ($sys_src->{islocal}) {
        $cmd="$scppath $scpoptions -rp $file_src $host_dest:$file_dest";
    } elsif ($sys_dest->{islocal}) {
        $cmd="$scppath $scpoptions -rp $host_src:$file_src $file_dest";
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
