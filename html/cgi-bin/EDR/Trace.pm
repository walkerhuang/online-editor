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
package Trace;
use strict;

our %TRACE;

sub allsubs {
    my (%matches, @search, %prune, $pkg, $e, $k, $v);
    %prune = map {$_ => 1} qw{ :: main:: CORE:: DB:: };
    no strict 'refs';
    @search = ('::');
    while ($pkg = shift @search) {
        while (($k, $v) = each %{$pkg}) {
            $v =~ s/^\*(main::|::)*//mx;
            $e = "$pkg$k";
            $e =~ s/^:://m;
            next if ($v ne $e);
            if (defined &{$v} && !defined prototype($v)) {
                $matches{$v} = 1;
            } elsif (!$prune{$v} && %{$v} && $v =~ /::$/m) {
                push(@search, $v);
            }
        }
    }
    return \%matches;
}

sub trace2file {
    my ($msg) = @_;
    my ($file, $tid,$fd);
    print "$msg";
    return if (!$Obj::pool{EDR} || !$Obj::pool{EDR}{logfile});
    $tid = ($Obj::pool{Thr}) ? $Obj::pool{Thr}{tid} : '0';
    $file = $Obj::pool{EDR}{logfile} . $tid;
    open($fd, '>>', $file) or return;
    print($fd $msg);
    close($fd);
    return;
}

sub isresumepoint {
    my $subname = shift;
    return 1 if ($TRACE{resume_re} && $subname =~ /$TRACE{resume_re}/mx);
    return (defined $TRACE{resume_subs_hash}{$subname});
}

sub hasprecheck {
    my ($subname, $allsubs) = @_;
    $subname =~ s/::/_/mg;
    return 0 if (!$TRACE{subcheckon});
    return 1 if ($allsubs->{"EXITSUB\::pre_$subname"});
    return 0;
}

sub haspostcheck {
    my ($subname, $allsubs) = @_;
    $subname =~ s/::/_/mg;
    return 0 if (!$TRACE{subcheckon});
    return 1 if ($allsubs->{"EXITSUB\::post_$subname"});
    return 0;
}

sub issyssub {return ($_[0] =~ /(Rel|Prod|Proc|Patch)::\S*_sys$/mx)}

sub iswebsub {return ($_[0] =~ /::web_\S+$/m);}

sub isclisub {return ($_[0] =~ /::cli_\S+$/m);}

sub istracepoint {
    my $subname = shift;
    my $module = (split(/::/m, $subname))[0];
    return 1
      if (   $TRACE{traceon}
          && !$TRACE{notrace_subs_hash}{$subname}
          && ($TRACE{trace_subs_hash}{$subname} || $TRACE{trace_modules_hash}{$module}));
    return 0;
}

sub init {
    my (@lines, $traceconf, $exitsub, $argstr, $fd, @newargs,$tmpstr);
    open($fd, '<', $0) or die("Open file [$0] failed.\n");
    @lines = <$fd>;
    close $fd;
    @newargs = @ARGV;
    for(my $i=0;$i<=$#newargs;$i++){
        $newargs[$i] =~ s/ /\~/g;
        $newargs[$i] =~ s/\t/\!/g;
    }
    $argstr = join(' ', @newargs);
    if ($argstr =~ /-trace\b/m) {
        $TRACE{traceon}= 1;
        $tmpstr = $` . $';
        if($argstr =~ /-responsefile\s+\S+/){
            $argstr = $tmpstr;
        }
    }
    if ($argstr =~ /-traceconf\s+(\S+)/mx) {
        $traceconf = $1;
        $argstr    = $` . $';
    } elsif ($ENV{TRACECONF}) {
        $traceconf = $ENV{TRACECONF};
    }
    if ($argstr =~ /-exitsub\s+(\S+)/mx) {
        $exitsub = $1;
        $argstr  = $` . $';
    } elsif ($ENV{EXITSUB}) {
        $exitsub = $ENV{EXITSUB};
    }
    if ($traceconf) {
        require($traceconf);
    }
    if ($exitsub) {
        require($exitsub);
        $TRACE{subcheckon} = 1;
    }
    @newargs = split(/ /m, $argstr);
    for(my $i=0;$i<=$#newargs;$i++){
        $newargs[$i] =~ s/\~/ /g;
        $newargs[$i] =~ s/\!/\t/g;
    }
    @ARGV = @newargs;
    for my $list (qw(trace_modules trace_subs notrace_subs resume_subs)) {
        %{$TRACE{$list . '_hash'}} = map {$_ => 1} @{$TRACE{$list}};
    }
    return;
}

sub vars2line {
    my @inputs = @_;
    my ($ref, $str, @vars);
    for my $var (@inputs) {
        $ref = ref($var);
        $str =
            ($ref eq '')      ? $var
          : ($ref eq 'ARRAY') ? "[@$var]"
          : ($ref eq 'Sys')   ? "Sys\::$var->{sys}"
          :                     $ref;
        $str ||='';
        push(@vars, $str);
    }
    return join(', ', @vars);
}

sub resume {
    my $subname = shift;
    my ($thr,$cfg);
    if ($Obj::pool{Cfg}) {
        $cfg = $Obj::pool{Cfg};
        if ($cfg->{opt}{responsefile} && ($cfg->{opt}{responsefile} =~ /exitfile/m)) {
            if (!$cfg->{last} || $cfg->{last}{sub} eq $subname) {
                unlink($cfg->{opt}{responsefile});
                delete $cfg->{opt}{responsefile};
                if ($Obj::pool{Thr} && $Obj::pool{Thr}{tid}) {
                    $thr = $Obj::pool{Thr};
                    my @undefresp : shared = ('Cfg', 'opt,responsefile', undef);
                    $thr->{setq}->enqueue(\@undefresp) if ($thr->{type} eq 'sq');
                    $thr->{$thr->{tid}}{setq}->enqueue(\@undefresp) if ($thr->{type} eq 'mq');
                }
            }
        } else {
            $cfg->{last}{sub} = $subname;
        }
    }
    return;
}

sub pretrace {
    my ($ind, $subname, $params) = @_;
    my ($indstr, $argl, $msg, $time, @lt, $tid, $file, $line, @ci, $i);
    $i = 0;
    while (1) {
        @ci = caller($i++);
        next if (@ci && $ci[0] eq 'Trace');
        last;
    }
    $file   = $ci[1];
    $line   = $ci[2];
    $indstr = ' ' x $ind;
    $argl   = vars2line(@$params);
    $tid    = ($Obj::pool{Thr}) ? $Obj::pool{Thr}{tid} : '0';
    @lt     = localtime;
    $time   = sprintf('%02d:%02d:%02d', $lt[2], $lt[1], $lt[0]);
    $file =~ s/\/+/\//mg;
    $file =~ s/.*\/(.*\/)/$1/m;
    $msg = sprintf("%d %s%s%s=>%s\n", $tid, $time, $indstr, $ind, "$subname($argl) $file:$line");
    trace2file($msg);
    return;
}

sub posttrace {
    my ($ind, $subname, $params, @rtn) = @_;
    my ($indstr, $argl, $rtnl, $msg, $time, @lt, $tid);
    $indstr = ' ' x $ind;
    $argl   = vars2line(@$params);
    $rtnl   = vars2line(@rtn);
    $tid    = ($Obj::pool{Thr}) ? $Obj::pool{Thr}{tid} : '0';
    @lt     = localtime;
    $time   = sprintf('%02d:%02d:%02d', $lt[2], $lt[1], $lt[0]);
    $msg    = sprintf("%d %s%s%s<=%s\n", $tid, $time, $indstr, $ind, "$subname($argl) $rtnl");
    trace2file($msg);
    return;
}

sub precheck {
    my ($subname, $params) = @_;
    $subname =~ s/::/_/mg;
    my $precheck = UNIVERSAL::can('EXITSUB', "pre_$subname");
    $precheck->($params) if ($precheck);
    return;
}

sub postcheck {
    my ($subname, $params, @rtn) = @_;
    $subname =~ s/::/_/mg;
    my $postcheck = UNIVERSAL::can('EXITSUB', "post_$subname");
    $postcheck->($params, @rtn) if ($postcheck);
    return;
}

sub syscheck {
    my ($subname, $params) = @_;
    my ($arg1, $arg2, undef) = @$params;
    if (   ($arg1 && (ref($arg1) eq 'Sys' || $Obj::pool{"Sys::$arg1"}))
        || ($arg2 && (ref($arg2) eq 'Sys' || $Obj::pool{"Sys::$arg2"}))) {
        return;
    }
    my $args = vars2line(@$params);
    die("ERROR: Sys object not passed as first or second arg to $subname($args)\n");
}

sub binding {
    my ($allsubs, $ind, $trace, $resumepoint, $tracepoint, $websub, $clisub, $syssub, $precheck, $postcheck);
    $trace = shift;
    %TRACE = %$trace;
    no strict 'refs';
    no warnings 'redefine';
    init();
    $allsubs = allsubs();
    $ind     = 1;
    for my $subname (keys %$allsubs) {
        $resumepoint = isresumepoint($subname);
        $tracepoint  = istracepoint($subname);
        $websub      = iswebsub($subname);
        $clisub      = isclisub($subname);
        $syssub      = issyssub($subname);
        $precheck    = hasprecheck($subname, $allsubs);
        $postcheck   = haspostcheck($subname, $allsubs);
        next unless (   $precheck
                     || $postcheck
                     || $resumepoint
                     || $tracepoint
                     || $websub
                     || $clisub
                     || $syssub);
        my $orig = *$subname{CODE};
        my $code = 'sub {my(@params,$wa,@rtn,$rtn);@params=@_;$wa=wantarray();';
        $code .= 'return if($Obj::pool{Web}&&$Obj::pool{Web}{browserid});'      if ($clisub);
        $code .= 'return if(!$Obj::pool{Web}||!$Obj::pool{Web}{browserid});'    if ($websub);
        $code .= 'resume("' . $subname . '");'                                  if ($resumepoint);
        $code .= 'pretrace($ind,"' . $subname . '",\@params);'                  if ($tracepoint);
        $code .= 'precheck("' . $subname . '",\@params);'                       if ($precheck);
        $code .= 'syscheck("' . $subname . '",\@params);'                       if ($syssub);
        $code .= '$ind++;if($wa){@rtn=$orig->(@params);}else{$rtn=$orig->(@params);}$ind--;';
        $code .= 'postcheck("' . $subname . '",\@params,($wa)?@rtn:$rtn);'      if ($postcheck);
        $code .= 'posttrace($ind,"' . $subname . '",\@params,($wa)?@rtn:$rtn);' if ($tracepoint);
        $code .= 'return(($wa)?@rtn:$rtn);};';
        *$subname = eval($code);
    }
    return;
}

1;
