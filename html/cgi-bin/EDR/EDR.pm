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

use Cfg;
use Msg;
use MsgWeb;
use Obj;
use Padv;
use Sys;
use if scalar($^O=~/(solaris|linux|aix|hpux|MSWin)/mx), 'Thr';
use EDRu;
use Timer;
use Task;
use Phase;
use Transport;
use Metrics;
use Trace;

use EDR::initiation;
use EDR::completion;
use EDR::systems;
use if scalar($^O!~/MSWin/), "EDR::comsetup";

@EDR::ISA = qw(Obj);

sub local_windows { return 1 if ($^O=~/MSWin/); return 0;}
sub thread_support { return 1 if ($^O=~/(solaris|linux|aix|hpux|MSWin)/mx); return 0;}
sub download_support { return 1 if ($^O=~/(solaris|linux|aix|hpux|darwin|MSWin)/mx); return 0;}

sub padvs {
    return [ @{Padv::AIX::padvs()},
             @{Padv::FreeBSD::padvs()},
             @{Padv::HPUX::padvs()},
             @{Padv::Linux::padvs()},
             @{Padv::MacOS::padvs()},
             @{Padv::Win::padvs()},
             @{Padv::SunOS::padvs()} ];
}

sub init {
    my ($edr,$release,$padvs,$mediapath)=@_;
    my ($padv,@padvs,$plus);
    $padvs||='';
    $mediapath||='.';

    # set padv specific info from Padv subs setting unbounded using +
    # this info was previously in in Padv and $rel objects
    @padvs=split(/\s+/m,$padvs);
    for my $padv (@padvs) {
        $plus = ($padv=~/\+$/m) ? '+' : '';
        $padv=~s/\+//m;
        $edr->{padv_plat}{$padv}=Padv::plat($padv);
        $edr->{padv_distro}{$padv}=Padv::distro($padv);
        $edr->{padv_distro2p}{$padv}=Padv::distro2p($padv);
        $edr->{padv_arch}{$padv}=Padv::arch($padv);
        $edr->{padv_vers}{$padv}=Padv::vers($padv);
        $edr->{padv_unbounded}{$padv}=1 if ($plus);
        #printf "%-14s %-5s %-4s %-7s %-6s %-18s %s\n", "$padv$plus",
        #    $edr->{padv_plat}{$padv}, $edr->{padv_distro}{$padv},
        #    $edr->{padv_distro2p}{$padv}, $edr->{padv_arch}{$padv},
        #    $edr->{padv_vers}{$padv}, $edr->{padv_unbounded}{$padv};
        $edr->{padvisa}{$padv}=$padvs[0];
    }

    # drive the rest of the way with no reference to the + in the padv settings
    $edr->{release}=$release;
    $padvs=~s/\+//mg;
    @padvs=split(/\s+/m,$padvs);
    $edr->{padvs}=\@padvs;
    #$edr->{padv} = ($#padvs>0) ? "Common" : $padvs[0];
    $edr->{padv} = $padvs[0];

    $|=1;
    $edr->{script}=EDRu::basename($0);
    $edr->{scriptdir}=EDRu::app_path();
    $edr->{mediapath} = $mediapath;

    if (local_windows()) {
        # so this can be overridden, per-release for now
        $edr->define_default_windows_paths();
    } else {
        $edr->define_default_unix_paths();
    }

    # If install on 4+ nodes, require at least 2048 MB.
    $edr->{large_cluster_memory}=2048;

    # If install on 4+ nodes and memory less that 1280 MB, set threadlimit to 4 as small cluster installation.
    $edr->{small_cluster_memory}=1280;

    $edr->{main_timer}=Timer->new('edr_main_timer');

    # TODO: default value, should we define this elsewhere or at a padv level?
    $edr->{timeout}=0;

    # User may use 'screen' command to start a terminal, and ssh/telnet to a remote machine,
    # then 'TERM=screen' on remote machine which may not be supported.
    $ENV{TERM} = 'vt100' if (!$ENV{TERM} || $ENV{TERM} eq 'screen' || $ENV{TERM} eq 'SCREEN');

    return $edr;
}

sub define_default_windows_paths {
    my $edr=shift;
    $edr->{tmppath}="C:\\ProgramData\\Symantec\\VRTSsfmh\\logs";
    $edr->{logpath}="C:\\ProgramData\\Symantec\\VRTSsfmh\\logs";
    $edr->{installpath}="/opt/VRTS/install";
    $edr->{perlpath}="/opt/VRTSperl";
    #EDR::die("EDR::define_default_windows_paths not defined");
    return;
}

sub define_default_unix_paths {
    my $edr=shift;
    $edr->{tmppath}="/var/tmp";
    $edr->{logpath}="/opt/VRTS/install/logs";
    $edr->{installpath}="/opt/VRTS/install";
    $edr->{perlpath}="/opt/VRTSperl";
    return;
}

sub cmd_local {
    my $localsys=EDR::get('localsys');
    return $localsys->cmd(@_);
}

sub cmdfile {
    my ($tid) = (@_);
    return '' unless (($tid>0) && (EDR::get('timeout')>0));
    my $tmpdir=EDR::get('tmpdir');
    my $localsys=EDR::get('localsys');
    return $localsys->path("$tmpdir/cmd.$tid");
}

sub caller_trace {
    my $i=1; # skip the current sub.
    my $rtn='';
    while(1){
        my ($package,$file,$line,$subr)=caller($i++);
        last unless($subr);
        $rtn.="$subr at " if($subr !~ /__ANON__/m);
        $rtn.="$file line $line\n" if($file !~ /^\(/m);
    }
    return $rtn;
}

# EDR::assert() for parameter validation, and die for fatal coding errors. it could be disabled when GA.
# $assert:  expecting behaviour.
# $name:    message about expecting behaviour.
sub assert {
    my ($assert,$name,$exitcode) = @_;

    return if ($ENV{NOCPIASSERT});

    unless ($assert) {
        my $msg = 'Assert failed';
        $msg .= " - '$name'" if defined $name;
        $msg .= "!\n" . caller_trace();
        $msg = Msg::new_obj($msg);
        $msg->die($exitcode);
    }
    return;
}

# EDR::die() to die for fatal framework logic errors.
sub die {
    my ($msg,$exitcode) = @_;
    my ($edr,$sys,$tid);

    # if Obj not initialized, then directly call CORE::die()
    CORE::die($msg) if (!defined $Obj::pool{EDR});

    $edr = Obj::edr();
    $tid = Obj::tid();
    $msg = "\n\n$tid $msg\n";
    if (Cfg::opt('rwe')) {
        # EDR::die calls passed as a system error with rwe option
        $sys=$edr->{localsys};
        $sys->push_error($msg);
        $sys->padv->write_rwe_systems_errors_warnings_sys($sys);
    }
    if (Cfg::opt('trace')) {
        $msg .= caller_trace();
        $msg .= "\n\n$edr->{tmpdir}\n\n";
    }
    $msg = Msg::new_obj($msg);
    $msg->die($exitcode);
    return;
}

sub get {
    my $edr=Obj::edr();
    return $edr->{$_[0]};
}

sub get2 {
    my $edr=Obj::edr();
    return $edr->{$_[0]}{$_[1]};
}

sub getmsgkey {
    my ($edr,$input,$key);
    # OO call may be made from EDR layer or not from CPIC/CPIP layer
    $edr=shift if (ref($_[0]) eq 'EDR');
    $edr||=Obj::edr();
    ($input,$key)=@_;
    return ($input=~/^$edr->{msg}{$key}$/mxi);
}

# define frequently accessed gets
sub cmdexit {
    my $edr=Obj::edr();
    return $edr->{cmdexit};
}

sub systems {
    my $edr=Obj::edr();
    return $edr->{systems};
}

sub nsystems {
    my $edr=shift;
    $edr||=Obj::edr();
    return scalar(@{$edr->{systems}});
}

sub num_sys_keyset {
    my $key=shift;
    my $systems=shift || systems();
    my $num=0;
    for my $sys (@{$systems}) { $num++ if $sys->{$key}; }
    return $num;
}

sub num_sys_keynotset {
    my $key=shift;
    my $systems=shift || systems();
    my $num=0;
    for my $sys (@{$systems}) { $num++ unless $sys->{$key}; }
    return $num;
}

sub tmpdir {
    my $edr=Obj::edr();
    return $edr->{tmpdir};
}

sub force_require {
    my $lib=shift;
    return unless ($lib);
    delete $INC{$lib};
    require $lib;
    return;
}

sub set_value {
    my $edr=Obj::edr();
    Obj::set_value($edr->{pool}, @_);
    Thr::setq($edr->{pool}, @_) if (EDR::thread_support());
    return;
}

sub create_threads {
    my $edr=Obj::edr();
    my ($nsystems,$threadlimit,$thr);

    $nsystems=$edr->nsystems();
    $threadlimit=$edr->{threadlimit};
    $thr=Obj::thr();
    $thr->mq_create_threads($nsystems, $threadlimit);
    return 1;
}

sub join_threads {
    my $thr=Obj::thr();
    $thr->mq_join_threads();
    return 1;
}

sub enable_log {
    return EDR::set_value('savelog', 1);
}

sub disable_log {
    return EDR::set_value('savelog', 0);
}

1;
