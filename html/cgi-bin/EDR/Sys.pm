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
package Sys;
use strict;
@Sys::ISA = qw(Obj);

sub init {
    my $sys=shift;
    $sys->{sys}=shift;
    return;
}

sub aix { return 1 if ($_[0]->{plat} eq 'AIX'); return 0; }
sub aix_vios {return 1 if (($_[0]->{plat} eq 'AIX') && ($_[0]->{ioslevel})); return 0; }

sub hpux { return 1 if ($_[0]->{plat} eq 'HPUX'); return 0; }
sub linux { return 1 if ($_[0]->{plat} eq 'Linux'); return 0; }
sub sunos { return 1 if ($_[0]->{plat} eq 'SunOS'); return 0; }
sub sunos_sol11 {return 1 if (($_[0]->{plat} eq 'SunOS') && ($_[0]->{platvers} eq '5.11')); return 0; }
sub freebsd { return 1 if ($_[0]->{plat} eq 'FreeBSD'); return 0; }
sub macos { return 1 if ($_[0]->{plat} eq 'MacOS'); return 0; }
# modify if padvs change
sub windows { return 1 if ($_[0]->{plat}=~/Win/mx); return 0; }

sub padv {
    my $sys=shift;
    my $pool="Padv::$sys->{padv}";
    EDR::die("No padv object defined for padv $sys->{padv} for system $sys->{sys}")
        unless (Obj::created($pool));
    return Obj::pool($pool);
}

sub padvisa {
    my ($padvisa,$pool,$sys,$tmppadv);
    $sys=shift;
    $padvisa=EDR::get2('padvisa', $sys->{padv});
    # padvisa is not defined for alternate plat localsys in a2m scenario
    $padvisa||=$sys->{padv};
    $pool="Padv::$padvisa";
    # don't die, just create it
    $tmppadv = $sys->{padv};
    return "Padv\::$tmppadv"->new() unless (Obj::created($pool));
    #EDR::die("No padv object defined for padvisa $padvisa for system $sys->{sys}")
    #    unless (Obj::created($pool));
    return Obj::pool($pool);
}

sub obj {
    my ($type,$sys,$obj,$donotdie) = @_;
    my ($padv,$pool);
    # for Single platform releases, return objects initialized to $cpic->{padv}
    # which is the only object were using for CPIP even if $cpic->{padvs} has >1
    # for Any to Many releases, return the object initialized to $cpic->{padvisa}{$sys->{padv}}
    # under the assumption the object has been created by create_system_objects
    $padv=EDR::get('padv');
    $padv=CPIC::get2('padvisa', $sys->{padv}) if ($padv eq 'Common');
    if(!$padv){
        return if($donotdie);
        EDR::die("obj($sys,$obj,$type) cpic->{padvisa}{$sys->{padv}} is not defined");
    }
    $pool=join('::', $type, $obj, $padv);
    if(!Obj::created($pool)){
        return if($donotdie);
        EDR::die("No $type object defined for $type $obj and padv $padv for system $sys->{sys}");
    }
    return Obj::pool($pool);
}

sub rel { return obj('Rel',$_[0], CPIC::get('release')); }

sub prod {
    my($sys,$prod)=@_;
    $prod||=CPIC::get('prod');
    return obj('Prod',$sys, $prod);
}

sub pkg { return obj('Pkg', @_); }
sub proc { return obj('Proc', @_); }
sub patch { return obj('Patch', @_); }
sub eeb { return obj('EEB', @_); }

# return the package description.
sub pkgdesc {
    my ($sys,$pkg)= @_;
    return $sys->padv->pkg_description_sys($sys, $pkg) || '';
}

# returns the version of a package installed on a system
# could use $sys->{pkgvers}{$pkg->{pkg}}, but it is a bit of a char saver
# and a place to hack around things like VRTSvail.VRTSvail
sub pkgvers {
    my ($sys,$pkg)= @_;
    if (ref($pkg)) {
        return $sys->{pkgvers}{$pkg->{pkgname}} if ($pkg->{pkgname});
        return $sys->{pkgvers}{$pkg->{pkg}};
    }
    return $sys->{pkgvers}{$pkg};
}

# doing the same with pkgdeps
sub pkgdeps {
    my ($sys,$pkg)= @_;
    my $pkgdeps=(ref($pkg)) ? $sys->{pkgdeps}{$pkg->{pkg}} : $sys->{pkgdeps}{$pkg};
    return $pkgdeps || '';
}

# returns the patch index
sub patchindex {
    my ($sys,$arch);
    $sys=shift;

    if (($sys->hpux()) && ($sys->{platvers}>=11.31)) {
        $arch=($sys->{arch} eq 'ia64') ? 'IA' : 'PA';
        return "$sys->{platvers}$arch";
    }
    return "$sys->{platvers}";
}

# check if sys is the first system
sub system1 {
    my ($sys,$edr,$sys0);
    $sys = shift;
    $edr=Obj::edr();
    $sys0 = ${$edr->{systems}}[0];
    return 1 if ($sys->{sys} eq $sys0->{sys});
    return 0;
}

sub cmd_bin {
    my ($sys,$key) = @_;
    my ($padv,$cmd);
    for my $padv ($sys->padv, $sys->padvisa) {
        $cmd=$padv->{cmd}{$key};
        return $cmd if ($cmd);
    }
    return '';
}

sub cmdswap {
    my ($sys,$cmd) = @_;
    my ($msg,$padv,$key,$rtn,$swap);
    return $cmd if ($cmd!~/_cmd_/m);
    EDR::die("Cannot execute $cmd on $sys->{sys} with undefined sys->{padv}") if (!$sys->{padv});
    EDR::die("Cannot execute $cmd on $sys->{sys} with uninitialized padv $sys->{padv}")
        unless (Obj::created("Padv::$sys->{padv}"));
    # commands defined within CPIP inits may be defined to lower $sys->padvisa level
    for my $padv ($sys->padv, $sys->padvisa) {
        for my $key (sort keys(%{$padv->{cmd}})) {
            next unless ($cmd=~/_cmd_$key/m);
            $swap=$padv->{cmd}{$key};
            $cmd=~s/_cmd_$key\b/$swap/mxg;
            return $cmd if ($cmd!~/_cmd_/m);
        }
    }
    EDR::die("undefined cmd substitution:\n$cmd\nsys=$sys->{sys}\npadv=$sys->{padv}\npadvisa=".$sys->padvisa);
    return;
}

sub cmd {
    my ($sys,$cmd,$env) = @_;
    my ($edr,$trans,$transport,$stdout,$stderr,$exitcode,$timer,$elapsed,$original_cmd);

    EDR::die("Sys object not passed as first arg to cmd(@_)") if (ref($sys) ne 'Sys');

    # Get command
    $cmd=$sys->cmdswap($cmd) if ($cmd=~/_cmd_/m);
    $cmd=~s/\/dev\/null/nul/g if ($sys->windows);

    $cmd=$env . " $cmd" if ($env);
    $cmd=$sys->{env} . " $cmd" if ($sys->{env});

    # set timer
    $timer=Timer->new('Sys::command');
    $timer->start();
    $original_cmd=$cmd;

    # Execute the command
    if ($sys->{islocal}) {
        $cmd.=" 2>&1" unless ($cmd=~/2>/);
        ($stdout,$stderr,$exitcode,$cmd)=run_local_command($cmd);
    } else {
        $trans=$sys->{transport_obj};
        if (!$trans && $sys->{transport}) {
            $transport=$sys->{transport};
            $trans="Transport\::$transport"->new();
            $sys->{transport_obj}=$trans;
        }
        ($stdout,$stderr,$exitcode,$cmd)=$trans->cmd_sys($sys,$cmd) if ($trans);
    }

    # Save command results in EDR object
    $edr=Obj::edr();
    Obj::reset_value($edr, 'cmdstdout', $stdout);
    Obj::reset_value($edr, 'cmdstderr', $stderr);
    $exitcode||=0;
    Obj::reset_value($edr, 'cmdexit',   $exitcode);

    # Log the command information, run_local_command() will log the command before running
    #Msg::log("cmd $cmd");
    Msg::log("cmd stdout=\n$stdout") if ($stdout && ($cmd!~/tar -xvf/m));
    Msg::log("cmd stderr=\n$stderr") if ($stderr);
    $elapsed=$timer->stop();
    Msg::log("cmd exit=$exitcode (duration: $elapsed seconds)");

    Metrics::add_phase_command_metrics('',$sys->{sys},"$original_cmd",'time','push',$elapsed);

    return $stdout;
}

sub escape_remote_command {
    my $cmd=shift;

    $cmd =~ s/\\/\\\\/g;
    $cmd =~ s/\`/\\\`/mg;
    $cmd =~ s/\"/\\\"/mg;
    $cmd =~ s/\$/\\\$/mg;

    return $cmd;
}

sub run_local_command {
    my $cmd=shift;
    my ($stdout,$stderr,$exitcode);

    # Log the command before running
    Msg::log("cmd $cmd");

    # Get stdout
    $stdout=`$cmd`;
    chomp $stdout;

    # Get exit code
    $exitcode=$?;
    $exitcode >>= 8 if ($exitcode > 0);

    return ($stdout,$stderr,$exitcode,$cmd);
}

# Remove banner
sub remove_banner_sys {
    my ($sys,$rtn)= @_;
    return "$rtn" unless ($sys->{banner});
    return '' if ($rtn eq $sys->{banner});
    $rtn=~s/\Q$sys->{banner}\E\n?//xg;
    return $rtn;
}

sub cmd_bg {
    my ($sys,$cmd)= @_;
    return $sys->cmd("_cmd_nohup $cmd </dev/null >/dev/null 2>&1 &");
}

sub cmd_script {
    my ($sys,$script,$filename,$shell,$cmdbackground) = @_;
    my ($file,$edr,$rtn,$tmpdir,$cmd,$timer,$elapsed);

    # set timer
    $timer=Timer->new('Sys::script');
    $timer->start();

    $filename||='script_' . EDRu::randomstr(5);
    $edr=Obj::edr();
    $tmpdir=$edr->{tmpdir};
    $file="$tmpdir/$filename.$sys->{sys}";
    EDRu::writefile($script, $file);
    $edr->localsys->copy_to_sys($sys,$file,$tmpdir) unless ($sys->{islocal});
    if ($shell && $shell eq 'sh') {
        $cmd="_cmd_sh $file";
    } else {
        $sys->cmd("_cmd_chmod +x $file");
        $cmd="$file";
    }

    if ($cmdbackground) {
        $rtn=$sys->cmd_bg("$cmd");
    } else {
        $rtn=$sys->cmd("$cmd");
    }

    # For e1789748 and e2377076:
    # Sometimes, the script run into 'text busy' on local machine on AIX and Linux, re-run it again.
    if ($sys->{islocal} && ($sys->aix() || $sys->linux()) && ($rtn=~/(text busy|Text file busy)/m)) {
        Msg::log('Run into text busy, re-run again');
        sleep 1;

        if ($cmdbackground) {
            $rtn=$sys->cmd_bg("$cmd");
        } else {
            $rtn=$sys->cmd("$cmd");
        }
    }

    $elapsed=$timer->stop();
    Metrics::add_phase_script_metrics('',$sys->{sys},"$filename",'time','push',$elapsed);

    return $rtn;
}

# Execute several commands in one script together
sub cmds {
    my ($sys,$cmds,$env)=@_;
    my ($rtn,@lines,$results,$started,$script,$stdout,$exitcode);

    return if (!$cmds || !@{$cmds});

    $script ='LANG=C;   export LANG;';
    $script.='LC_ALL=C; export LC_ALL;';
    $script.="$env;" if ($env);
    for my $cmd (@$cmds) {
        $script.='echo "__CMDSTDOUT__"; ';
        $script.=$cmd;
        $script.='; echo "__CMDEXITCODE__=$?";';
    }

    $rtn=$sys->cmd_script($script);

    $results=[];

    $stdout='';
    $exitcode=0;
    $started=0;

    @lines = split /\n/, $rtn;
    for my $line (@lines) {
        if ($line=~/__CMDSTDOUT__/mx) {
            if ($started) {
                push @$results, [$stdout,$exitcode];
            }
            $stdout='';
            $exitcode=0;
            $started=1;
        } elsif ($line=~/^(.*)__CMDEXITCODE__=(.*)$/sx) {
            $stdout.="$1"; 
            $exitcode="$2";
        } elsif ($started) {
            $stdout.="$line\n";
        }
    }
    if ($started) {
        push @$results, [$stdout,$exitcode];
    }

    return $results;
}

# Execute sereval commands together and get the command results seperately
# $cmds = [
#    { name=>'<name1>', desc=>'<description1>', cmd=>'<command1>' },
#    { name=>'<name2>', desc=>'<description2>', cmd=>'<command2>' }
# ]
sub tagged_cmds {
    my ($sys,$tagged_cmds,$env)=@_;
    my ($results,$cmd,$i,@cmds);

    return if (!$tagged_cmds || !@{$tagged_cmds});

    @cmds=();
    for my $tagged_cmd (@{$tagged_cmds}) {
        $cmd=$tagged_cmd->{cmd} || '';
        push @cmds, $cmd;
    }

    $results=$sys->cmds(\@cmds,$env);

    $i=0;
    for my $result (@{$results}) {
        $tagged_cmds->[$i]->{stdout}=$result->[0];
        $tagged_cmds->[$i]->{exitcode}=$result->[1];
        $i++;
    }
    return;
}

sub set_value {
    my $sys=shift;
    Obj::set_value($sys->{pool}, @_);
    Thr::setq($sys->{pool}, @_) if (EDR::thread_support());
    return;
}

sub push_fatal_stop_proc {
    my ($sys,$proc)=@_;
    $sys->set_value('fatalstopfailprocs', 'push', $proc->{proc}) if ($proc->{fatal});
    return;
}

sub push_stop_checks_error {
    my ($sys,$msg)=@_;
    $sys->push_error($msg);
#print "push_stop_checks_error($sys->{sys},\n$msg->{msg})\n";
    Msg::log("stop_checks error on $sys->{sys}:\n$msg->{msg})");
    $sys->set_value('stop_checks', 1);
    return;
}

sub push_error {
    my ($sys,@msgs)=@_;

    my $umi_msg=Msg::umi_msg('CPI', 'ERROR', @msgs);
    return unless ($umi_msg);

    Msg::log($umi_msg);
    $sys->set_value('errors', 'push', $umi_msg);
    return;
}

sub push_warning {
    my ($sys,@msgs)=@_;

    my $umi_msg=Msg::umi_msg('CPI', 'WARNING', @msgs);
    return unless ($umi_msg);

    Msg::log($umi_msg);
    $sys->set_value('warnings', 'push', $umi_msg);
    return;
}

sub push_note {
    my ($sys,@msgs)=@_;

    my $umi_msg=Msg::umi_msg('CPI', 'NOTE', @msgs);
    return unless ($umi_msg);

    Msg::log($umi_msg);
    $sys->set_value('notes', 'push', $umi_msg);
    return;
}

sub push_check_note {
    my ($sys,@msgs)=@_;

    my $umi_msg=Msg::umi_msg('CPI', 'CHECK', @msgs);
    return unless ($umi_msg);

    Msg::log($umi_msg);
    $sys->set_value('check_action_notes', 'push', $umi_msg);
    return;
}

sub push_action_note {
    my ($sys,@msgs)=@_;

    my $umi_msg=Msg::umi_msg('CPI', 'ACTION', @msgs);
    return unless ($umi_msg);

    Msg::log($umi_msg);
    $sys->set_value('check_action_notes', 'push', $umi_msg);
    return;
}

sub print {
    my $sys=shift;
    print $sys->{sys}.":\n".EDRu::hash2def($sys, 'sys')."\n";
    return;
}

sub chown_root {
    my ($sys,$file) = @_;
    return $sys->padv->chown_root_sys($sys,$file);
}

sub get_root_home {
    my $sys = shift;
    return $sys->padv->get_root_home_sys($sys);
}

# get the netmask currently configured on the base IP of a NIC
sub defaultnetmask {
    my ($sys,$ip,$nic) = @_;
    my ($nm,$n,$hnm,@f,$ipv,$h);
    $ipv = '4' if (EDRu::ip_is_ipv4($ip));
    $ipv = '6' if (EDRu::ip_is_ipv6($ip));
    $hnm=$sys->padv->netmask_sys($sys, $nic, $ipv) if ($nic);
    if ($hnm) {
        if (($ipv==4) && ($sys->{ipv4})) {
            @f=split(/\./m,$hnm);
            return "$hnm" if ($#f==3);
                $hnm=~s/^0x//m;
            for my $n (0..3) {
                $h = hex(substr($hnm,$n*2,2));
                $nm .= $h;
                $nm .= '.' if ($n<3);
            }
        } elsif (($ipv==6) && ($sys->{ipv6})) {
            # When coming here, the prefix length is available,
            # figure out the netmask by the prefix
            $nm = $hnm;
            # When the requirement for IPv6 netmask isn't prefix,
            # uncomment the 3 lines below
            #$nm = ip_get_mask($nm, 6);
            #$nm = ip_bintoip($nm,6);
            #$nm = ip_compress_address($nm, 6);
        } else {
            $nm = '';
        }
    } else {
        # No mask/prefix detected by netmask_sys,
        # we need to figure out one by ourselves
        if (($ipv==4) && ($sys->{ipv4})) {
            $ip =~ s/\..*$//m;
            $nm = ($ip<128) ? '255.0.0.0' :
                  ($ip<192) ? '255.255.0.0' : '255.255.255.0';
        } elsif (($ipv==6) && ($sys->{ipv6})) {
            $nm = '';
            # Hardcode the netmask when $ip is not LINK-LOCAL or UNSPECIFIED
            # or LOOPBACK for it can work correctly with SITE-LOCAL and GLOBAL
            # IPv6 address.
            my $type = EDRu::iptype_ipv6($ip);
            # uncomment line below to return IPv6-address-formated netmask
            #$nm = "ffff:ffff:ffff:ffff::" if ($type =~ m/SITE-LOCAL|GLOBAL/i);
            $nm = '64' if ($type =~ m/SITE-LOCAL|GLOBAL/i);
        } else {
            $nm = '';
        }
    }
    return "$nm";
}

sub pkgs_patches {
    my $sys = shift;
    return $sys->padv->pkgs_patches_sys($sys);
}

sub install_pkgs {
    my ($sys,$archive,$pkgs) = @_;
    return $sys->padv->pkgs_install_sys($sys,$archive,$pkgs);
}

sub uninstall_pkgs {
    my ($sys,$pkgs) = @_;
    return $sys->padv->pkgs_uninstall_sys($sys,$pkgs);
}

sub install_patches {
    my ($sys,$archive,$patches) = @_;
    return $sys->padv->patches_install_sys($sys,$archive,$patches);
}

sub uninstall_patches {
    my ($sys,$patches) = @_;
    return $sys->padv->patches_uninstall_sys($sys,$patches);
}

sub nslookup {
    my ($sys,$hostname)=@_;
    return $sys->padv->nslookup_sys($sys,$hostname);
}

sub proc_pids {
    my ($sys,$proc) = @_;
    my (@pids,$padv,$rsh,$ssh,$procs);
    $padv=$sys->padv;
    $procs=$padv->procs_sys($sys,$proc);
    for my $proc (split(/\n/,$procs)) {
        if ($sys->{islocal}) {
            $rsh=$padv->{cmd}{rsh};
            $ssh=$padv->{cmd}{ssh};
            next if ($rsh && $ssh && $proc=~/$rsh|$ssh/m);
        }
        if ($proc=~/^\s*\S+\s*(\d+)/mx) {
            push(@pids, $1);
        }
    }
    return \@pids;
}

# kill a list of processes
# return a list of unkilled pids if kill failed
sub kill_pids {
    my ($sys, @pids) = @_;
    return $sys->padv->kill_pids_sys($sys,@pids);
}

sub find_children_of_pid {
    my ($sys,$pid) = @_;
    return $sys->padv->find_children_of_pid_sys($sys,$pid);
}

# verify an entered NIC is present on the system
sub is_nic {
    my ($sys,$nic) = @_;
    return $sys->padv->is_nic_sys($sys, $nic);
}

# verify an entered NIC is RDMA capable on the system
sub is_nic_rdma_capable {
    my ($sys,$nic) = @_;
    return 0 unless $nic;
    return $sys->padv->is_nic_rdma_capable_sys($sys, $nic);
}

# handle file and directory specific actions for Windows and Unix
sub filename_is_absolute {
    my ($sys,$file)=@_;

    return unless ($file);
    return $sys->padv->filename_is_absolute($file);
}

sub exists {
    my ($sys,$file)=@_;

    return unless ($file);
    return $sys->padv->exists_sys($sys,$file);
}

sub is_dir {
    my ($sys,$dir)=@_;
    my ($rtn);

    return unless ($dir);

    if ($sys->{islocal}) {
        $rtn = (-d $dir) ? 1 : 0;
    } else {
        $rtn=$sys->padv->is_dir_sys($sys,$dir);
    }
    return $rtn;
}

sub is_file {
    my ($sys,$file)=@_;
    my ($rtn);

    return unless ($file);

    if ($sys->{islocal}) {
        $rtn = (-f $file) ? 1 : 0;
    } else {
        $rtn=$sys->padv->is_file_sys($sys,$file);
    }
    return $rtn;
}

sub is_symlink {
    my ($sys,$symlink)=@_;
    my ($rtn);

    return unless ($symlink);

    if ($sys->{islocal}) {
        $rtn = (-l $symlink) ? 1 : 0;
    } else {
        $rtn=$sys->padv->is_symlink_sys($sys,$symlink);
    }
    return $rtn;
}

sub is_executable {
    my ($sys,$file)=@_;
    my ($rtn);

    return unless ($file);

    if ($sys->{islocal}) {
        $rtn = (-X $file) ? 1 : 0;
    } else {
        $rtn=$sys->padv->is_executable_sys($sys,$file);
    }
    return $rtn;
}

sub catfile {
    my ($sys,$file)=@_;
    return $sys->padv->catfile_sys($sys,$file);
}

sub grepfile {
    my ($sys,$word,$file)=@_;
    return $sys->padv->grepfile_sys($sys,$word,$file);
}

sub lsfile {
    my ($sys,$file)=@_;
    return $sys->padv->lsfile_sys($sys,$file);
}

sub readfile {
    my ($sys,$file,$logflag)=@_;
    my ($rtn);

    return unless ($file && $sys->is_file($file));

    if ($sys->{islocal}) {
        $rtn = EDRu::readfile($file);
    } else {
        $rtn = $sys->padv->readfile_sys($sys,$file);
    }
    Msg::log("File contents of file '$file':\n$rtn") if ($logflag);
    return $rtn;
}

sub writefile {
    my ($sys,$msg,$file)=@_;
    my ($rtn);

    return unless ($msg && $file);

    if ($sys->{islocal}) {
        $rtn = EDRu::writefile($msg,$file);
    } else {
        $rtn = $sys->padv->writefile_sys($sys,$msg,$file);
    }
    return $rtn;
}

sub appendfile {
    my ($sys,$msg,$file)=@_;
    my ($rtn);

    return unless ($msg && $file);
    if ($sys->{islocal}) {
        $rtn = EDRu::appendfile($msg,$file);
    } else {
        $rtn = $sys->padv->appendfile_sys($sys,$msg,$file);
    }
    return $rtn;
}

sub createfile {
    my ($sys,$file,$size)=@_;

    return unless ($file);
    return $sys->padv->createfile_sys($sys,$file,$size);
}

sub copyfile {
    my ($sys,$file_src,$file_dest)=@_;

    return 0 unless ($file_src && $file_dest);
    return $sys->padv->copyfile_sys($sys,$file_src,$file_dest);
}

sub copy_to_sys {
    my ($sys_src,$sys_dest,$file_src,$file_dest,$ddoe)=@_;
    my ($filename,$stat,$rtn,$tmpdir);

    EDR::assert((defined $file_src), 'file_src arg should be defined');

    $file_dest||=$file_src;

    # keep the file stat same as before, if the target file is not in the EDR::tmpdir
    $tmpdir=EDR::tmpdir();
    $filename = $file_dest;
    unless ($file_dest =~ /$tmpdir/) {
        if ($sys_dest->is_dir($file_dest)) {
            $filename = "$file_dest/" . EDRu::basename($file_src);
        }
        $stat=$sys_dest->filestat($filename) unless ($sys_dest->{padv} =~ /Win/i);
    }

    $rtn = EDRu::copy($sys_src,$file_src,$sys_dest,$file_dest,$ddoe);
    $sys_dest->change_filestat($filename,$stat) if ($stat && !($sys_dest->{padv} =~ /Win/i));
    return $rtn;
}

sub movefile {
    my ($sys,$file_src,$file_dest)=@_;

    return unless ($file_src && $file_dest);
    return $sys->padv->movefile_sys($sys,$file_src,$file_dest);
}

sub filestat {
    my ($sys,$file,$filestat)=@_;

    return unless ($file);
    return $sys->padv->filestat_sys($sys,$file,$filestat);
}

sub change_filestat {
    my ($sys,$file,$filestat)=@_;

    return unless ($file);
    return $sys->padv->change_filestat_sys($sys,$file,$filestat);
}

sub filesize {
    my ($sys,$file)=@_;

    return unless ($file);
    return $sys->padv->filesize_sys($sys,$file);
}

sub chmod {
    my ($sys,$file,$mode)=@_;

    return unless ($file && $mode);
    return $sys->padv->chmod_sys($sys,$file,$mode);
}

sub mkdir {
    my ($sys,$dir)=@_;

    return unless ($dir);
    return $sys->padv->mkdir_sys($sys,$dir);
}

sub rm {
    my ($sys,$fileordir)=@_;

    return unless ($fileordir);
    return $sys->padv->rm_sys($sys,$fileordir);
}

sub timesync {
    my ($sys,$ntpserver)=@_;

    return unless ($ntpserver);
    return $sys->padv->timesync_sys($sys,$ntpserver);
}

sub check_connection {
    my $sys=shift;
    my $transport=shift;
    my $trans=Transport::check_connection_sys($sys,$transport,@_);
    return 0 unless ($trans);
    $sys->{transport_obj}=$trans;
    $sys->set_value('transport', $trans->{transport});
    return 1;
}

sub setup_connection {
    my $sys=shift;
    my $transport=shift;
    my $trans=Transport::setup_connection_sys($sys,$transport,@_);
    return 0 unless ($trans);
    $sys->{transport_obj}=$trans;
    $sys->set_value('transport', $trans->{transport});
    return 1;
}

sub unsetup_connection {
    my $sys=shift;
    my $transport=shift;
    my ($trans,$rtn);
    if (!$transport) {
        $trans=$sys->{transport_obj};
        $transport=$trans->{transport} if ($trans);
    }
    return 1 if (!$transport);
    $rtn=Transport::unsetup_connection_sys($sys,$transport,@_);
    delete $sys->{transport_obj};
    delete $sys->{transport};
    return $rtn;
}

sub get_connection_error {
    my $sys=shift;
    my $transport=shift;
    return Transport::get_connection_error_sys($sys,$transport,@_);
}

sub configure_static_ip {
    my ($sys, $nic, $ip, $mask)=@_;
    return $sys->padv->configure_static_ip_sys($sys, $nic, $ip, $mask);
}

sub get_env_value {
    my ($sys, $env) = @_;
    return $sys->padv->get_env_value_sys($sys, $env);
}

1;
