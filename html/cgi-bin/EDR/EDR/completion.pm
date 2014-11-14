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
use JSON;

use constant {
    EXITSUCCESS => 0,
    EXITUNDEFINEDISSUE=>1,
    EXITNEEDREBOOT =>2,
    EXITPACKAGEFAILURE=>4,
    EXITPROCESSFAILURE=>8,
};

sub responsefile_comments {
    my $edr=Obj::edr();
    my $cmt=Msg::new("This variable defines the location of an ssh keyfile used to communicate with all remote systems");
    $edr->{rfc}{opt__keyfile}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable defines the location where log files are copied to following an install.  The default location is $edr->{logpath}");
    $edr->{rfc}{opt__logpath}=[$cmt->{msg},0,0,0];
    return;
}

sub create_summaryfile {
    my $edr=shift;
    my ($msg,$summary,$summary_with_content);

    $edr = Obj::edr();
    $summary_with_content = 0;
    $msg = Msg::new("$edr->{script} Summary");
    $summary = "$msg->{msg}\n";
    if (defined $edr->{custom_summary} && scalar @{$edr->{custom_summary}}) {
        $summary .= join("\n",@{$edr->{custom_summary}},"\n");
        $summary_with_content = 1;
    }

    EDRu::writefile($summary, $edr->{summary}) if $edr->{summary};
    return $summary_with_content;
}

sub save_and_display_logfiles {
    my $edr=shift;
    my ($logdir,$tmpdir,$localsys,$msg);

    $logdir=get('logdir');
    return unless (($edr->{savelog}) && ($logdir) && (@{$edr->{save_logfiles}}));

    $localsys=get('localsys');
    $localsys->mkdir($logdir);
    $tmpdir=get('tmpdir');
    for my $file (@{$edr->{save_logfiles}}) {
        next unless ($file);
        $file="$tmpdir/".$file if ($file!~m{^\/});
        $file=$localsys->path("$file");
        $localsys->copyfile($file, $logdir);
    }
    $localsys->chmod($logdir, '-R 700');

    if ($localsys->exists("$logdir/*.response")) {
        $msg=Msg::new("$edr->{script} log files, summary file, and response file are saved at:\n\n\t$logdir\n");
    } else {
        $msg=Msg::new("$edr->{script} log files and summary file are saved at:\n\n\t$logdir\n");
    }
    $msg->print;

    return;
}

sub cli_view_summary_file {
    my $edr=shift;
    my ($ayn,$file,$msg,$n,$output,$termy,$localsys);
    $localsys=$edr->{localsys};
    $file=$localsys->path("$edr->{logdir}/$edr->{scriptid}.summary");
    return '' unless ($localsys->exists($file));
    return '' if (-f '/tmp/nosummary');
    # exit if the summary file only contain on title
    $output=$localsys->catfile($file);
    $termy = (local_windows()) ? 100000 : $edr->{tput}{termy}-7;
    $termy=20 if ($termy<2);
    $msg=Msg::new("Would you like to view the summary file?");
    $ayn=$msg->aynn;
    Msg::n();
    if($ayn eq "Y") {
        $n=1;
        $output=$localsys->catfile($file);
        foreach my $line (split(/\n/,$output)){
            Msg::prtc() if ($n%$termy == 0);
            Msg::print("$line");
            $n=$n+1;
        }
    }
    return '';
}

sub register_cleanup_task {
    my($edr,$sub,@args)=@_;
    my $task={'sub'=>$sub,'args'=>\@args};
    push(@{$edr->{cleanup_extra_tasks}},$task);
    return;
}

sub execute_cleanup_tasks {
    my $edr=shift;
    foreach my $task (@{$edr->{cleanup_extra_tasks}}){
        my $handler=$task->{sub};
        my $args=$task->{args};
        &$handler(@{$args});
    }
    return;
}

sub cleanup {
    my (@vars) = @_;
    my $edr = (ref($vars[0]) eq 'EDR') ? shift @vars: Obj::edr();
    my $exit=shift @vars;
    my $exitfile_flag=shift @vars;

    # In case this sub is called multiple times during EDR::die().
    return if ($edr->{cleanup});
    $edr->{cleanup}=1;

    # mark script execution timing
    my $elapsed=$edr->{main_timer}->hms('short_hires');;
    Msg::log("$edr->{script} took $elapsed");

    # create summary file
    my $summary_with_content = $edr->create_summaryfile();

    # perform extra cleanup tasks
    $edr->execute_cleanup_tasks();

    # Do com cleanup here
    $edr->cleanup_com_setup();

    Thr::detach_threads() if (thread_support());

    exit $exit if ((Cfg::opt(qw(nocleanup debug)) || (!$edr->{logdir})));

    $edr->create_exitfile($exitfile_flag);
    $edr->save_and_display_logfiles();
    $edr->cli_view_summary_file() if ($summary_with_content && !$edr->{not_display_summary_file});
    $edr->rm_tmpdir();
    exit $exit;
}

sub set_exitcode {
    my (@vars)=@_;
    my $edr = (ref($vars[0]) eq 'EDR') ? shift @vars: Obj::edr();
    $edr->{exitcode}|=shift @vars;
    return;
}

sub unset_exitcode {
    my $edr=Obj::edr();
    undef($edr->{exitcode});
    return;
}

sub create_exitfile {
    my($edr,$exitfile_flag)=@_;
    my $localsys=$edr->{localsys};
    $localsys->mkdir($edr->{logpath});
    my $exitfile=$localsys->path("$edr->{logpath}/exitfile-*");
    $localsys->rm($exitfile);
    return if ((!$exitfile_flag) || ($edr->{exitfile} eq 'noexitfile') ||
               ($ENV{NOEXITFILE}) || (Cfg::opt('makeresponsefile')));
    my $cfg=Obj::cfg();
    $exitfile=$edr->{logpath}."/exitfile-".$edr->{release}."-".$edr->{uuid};
    $exitfile=$localsys->path($exitfile);
    $cfg->create_responsefile($exitfile);
    EDR::register_save_logfiles($exitfile);
    return;
}

sub rm_tmpdir {
    my $edr=shift;
    my ($dir,$file,$localsys);

    $edr->{donotlog}=1;
    for my $sys ($edr->{localsys}, @{$edr->{systems}}) {
        next if ((!$sys->{cleanup}) || (Cfg::opt('bait') && $sys->{islocal}));
        $sys->rm($edr->{tmpdir});
    }
    $localsys = $edr->{localsys};
    $file = "$edr->{scriptdir}/.cpi_running_l10n";
    $localsys->rm($file);

    # remove obsolete messages catalog and vxgettext utility
    if ($edr->{release}) {
        $dir = "$edr->{perlpath}/lib/site_perl/$edr->{release}";
        unless ($localsys->exists("$dir/EDR") || $localsys->exists("$dir/CPIC")) {
            for my $tmpdir("$dir/messages", "$dir/bin") {
                $localsys->rm($tmpdir);
            }
            $localsys->rm($dir);
        }
    }
    return;
}

sub exit_exitfile {
    my (@vars) = @_;
    my $edr = (ref($vars[0]) eq 'EDR') ? shift @vars: Obj::edr();
    my $exitcode = shift @vars;
    $exitcode = defined($edr->{exitcode})? $edr->{exitcode} : EDR->EXITUNDEFINEDISSUE unless(defined($exitcode));
    $edr->cleanup($exitcode, EDR->EXITUNDEFINEDISSUE);
    #e3440775:avoid installer couldn't exit for endless loop
    exit $exitcode;
}

sub exit_noexitfile {
    my (@vars) = @_;
    my $edr = (ref($vars[0]) eq 'EDR') ? shift @vars: Obj::edr();
    my $exitcode = shift @vars;
    $exitcode = defined($edr->{exitcode})? $edr->{exitcode} : EDR->EXITSUCCESS  unless(defined($exitcode));
    $edr->cleanup($exitcode);
    #e3440775:avoid installer couldn't exit for endless loop
    exit $exitcode;
}

sub dumpmemory {
    my $edr=Obj::edr();
    my ($msg,$file,$vars,$path,$json_txt,@lines,$pretty);
    $file=$edr->{localsys}->path($edr->{memorydumpfile});
    return unless ($file);
    $path = EDRu::dirname($file);
    exit EDR->EXITUNDEFINEDISSUE unless (-d $path);
    $vars ={};
    if (Cfg::opt('trace')) {
        $msg = EDRu::var2def(\%Obj::pool,'$pool',$vars);
        EDRu::writefile($msg,'/var/tmp/trace.dump');
    }else{
        $msg = EDRu::var2def(\%Obj::pool,'$pool',$vars,
            qr/^\$pool$|^\$pool{CPIC}|^\$pool{Cfg}|^\$pool{EDR}|^\$pool{"Sys::|^\$pool{"Rel::/,
            qr/{tunables}|{arguments}|^\$pool{EDR}{msg}|^\$pool{EDR}{rel}|^\$pool{EDR}{rfc}|^\$pool{EDR}{tput}|^\$pool{EDR}{key}|{keys}|{nodes}|{vxlicrep}|{menu}|{LS_COLORS}|{cmdstdout}|{msglist}/
        );
    }
    $vars ={};
    $msg .= EDRu::var2def(\%ENV,'$pool{env}',$vars);

    $vars ={};
    $msg .= EDRu::var2def(\@ARGV,'$pool{argv}',$vars);
    my %pool;
    @lines = split /\n/,$msg;
    for my $line(@lines){
        eval $line;
    }
    $pretty=0;
    $pretty=1 if (Cfg::opt(qw(nocleanup debug)));
    $json_txt = to_json(\%pool,{pretty=>$pretty});
    EDRu::writefile($json_txt,$file);

    return;
}

sub dumpmetrics {
    Metrics::dump();
    return 1;
}

1;
