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
package Msg;

use strict;

sub new {
    my ($msg,$catid,$msgid,@vars) = @_;
    my ($self,$class);
    $self=new_obj($msg);
    # number of args is either going to be 1 (uncatalogged) or 3+args
    if ($catid) {
        $self->{catid}=$catid;
        $self->{msgid}=$msgid;
        $self->{en}=$msg; # untranslated, unbroken msg for logging
        $self->{msg}=translate($msg, $catid, $msgid, @vars);
    }
    $self->{msg}=~s/_Q_/"/mg;
    $self->{msg}=~s/_N_/\n/g;
    return $self;
}

# Create Msg object for those messages need not traslation.
sub new_obj {
    my ($msg) = @_;
    my ($self,$class);
    $self={};
    $class = (Obj::webui()) ? 'MsgWeb':'Msg';
    $self->{catid}=0;
    $self->{msgid}=0;
    $self->{msg}=$msg;
    bless($self, "$class");
    return $self;
}

# sets a frequently used msg to the $edr->{msg} hash
sub msg {
    my($msg,$key)= @_;
    my $edr=Obj::edr();
    $edr->{msg}{$key}=$msg->{msg};
    return;
}

sub key_msg {
    my($key,$msg)= @_;
    my $edr=Obj::edr();
    $msg = $msg->{msg} if (ref($msg) =~ m/^Msg/);
    $edr->{msg}{$key}=$msg;
    return;
}

# sets a frequently used msg to the $edr->{msg} hash
sub get {
    my $key=shift;
    my $edr=Obj::edr();
    return $edr->{msg}{$key};
}

# sets an input key to the $edr->{msg} hash
sub key {
    my($msg,$key)= @_;
    my $edr=Obj::edr();
    $edr->{key}{$key}=$msg->{msg};
    return;
}

# get UMI string
sub umi {
    my $msg=shift;
    my ($edr,$bmcorigid);

    $edr=$Obj::pool{EDR};
    $bmcorigid=$edr->{vx_bmcorigid} if (defined $edr);
    $bmcorigid||=9;

    return "V-$bmcorigid-$msg->{catid}-$msg->{msgid}";
}

sub umi_msg {
    my ($category,$type,@msgs)=@_;
    my (@lmsgs,$lmsg,$umi,$edr);

    $umi='';
    @lmsgs=();
    for my $msg (@msgs) {
        next unless $msg;
        if(ref($msg) =~ m/^Msg/){
            push @lmsgs, $msg->{msg};
            $umi||=$msg->umi();
        } else {
            push @lmsgs, $msg;
        }
    }

    $lmsg=join ' ', @lmsgs;
    return unless ($lmsg);

    $edr=$Obj::pool{EDR};
    if (defined $edr) {
        $type=$edr->{msg}{lc($type)} || $type;
    }

    if ($umi) {
        $lmsg="$category $type $umi " . $lmsg;
    } else {
        $lmsg="$category $type " . $lmsg;
    }

    return $lmsg;
}

sub confirm_quit {
    my ($edr,$msg,$ques,$def,$ayn);
    $edr=Obj::edr();

    $msg=Msg::new("Are you sure you want to quit?");
    $ques=$msg->{msg};
    $ques.=" [$edr->{key}{yes},$edr->{key}{no}]";
    $def=$edr->{key}{yes};
    $ques.=" ($def)";
    $ques=linebreak($ques);

    while (1) {
        log_question($ques);
        print "$edr->{tput}{bs}$ques$edr->{tput}{be} ";
        $ayn = <STDIN>;
        $ayn = EDRu::despace($ayn);
        log_answer($ayn);
        # check answer
        $ayn = $def if ($ayn eq '');
        return 1 if ($ayn =~ /^$edr->{key}{yes}$/mxi);
        return 0 if ($ayn =~ /^$edr->{key}{no}$/mxi);
    }
    return;
}

sub ask { # msg, defanswer, help, backopt, nullok, noquit, nonasciiok
    my ($msg,$def,$help,$backopt,$nullok,$noquit,$nonasciiok) = @_;
    my ($ques,$edr,$warn,@opts,$back,$aks,$quit,$umi,$original_ques,$timer,$elapsed);

    $edr=Obj::edr();

    # pad the question with options
    $ques=$msg->{msg};
    $umi=$msg->umi;
    $back=1 if ($backopt);
    if (Cfg::opt(qw(responsefile rwe silent))) {
        if (defined($def)) {
            return $def;
        } else {
            Msg::die("Answer for '$ques' is required with responsefile or silent mode");
        }
    }
    if ($back || $help) {
        push(@opts,"$edr->{key}{back}") if ($back);
        push(@opts,"$edr->{key}{quit}") if ($help && !$noquit);
        push(@opts,"$edr->{key}{help}") if ($help);
        $ques.=' ['. join(',',@opts). ']';
    }
    if (defined($def) && ($def ne '') && ($def ne $edr->{msg}{back})) {
        $ques.=" ($def)";
    }
    while (1) {
        $timer=Timer->new('Msg::ask');
        $timer->start();

        $original_ques=$ques;
        Msg::log($ques);
        $ques=linebreak($ques);
        print "$edr->{tput}{bs}$ques$edr->{tput}{be} ";
        log_question($ques);
        $aks = <STDIN>;
        $aks = EDRu::despace($aks);
        Msg::log($aks);
        log_answer($aks);

        $elapsed=$timer->stop();
        Metrics::add_phase_question_metrics('',"$original_ques",'umi',$umi);
        Metrics::add_phase_question_metrics('',"$original_ques",'time','push',$elapsed);

        # check answer
        if ((!$noquit) && ($aks=~/^$edr->{key}{quit}$/mxi)) {
            $quit=confirm_quit();
            if ($quit) {
                Msg::log("User entered $aks: exiting");
                Msg::n();
                Msg::exit_summary($ques);
                # What if user encountered package installation failure,
                # when he is asked to continue, he choose quit?
                EDR::exit_exitfile(EDR->EXITSUCCESS); 
            }
        } elsif (($aks=~/^$edr->{key}{back}$/mxi) && ($back)) {
            return $edr->{msg}{back};
        } elsif (($help) && ($aks eq $edr->{key}{help})) {
            my $helpmsg=linebreak($help->{msg});
            print "\n$helpmsg\n\n";
        } elsif (!$nonasciiok && $aks=~/\P{IsASCII}/mx) {
            $warn = Msg::new("Only ASCII characters may be entered");
            $warn->print;
        } else {
            $aks=$def if (defined($def) && ($def ne '') && ($aks eq ''));
            return "$aks" if (($aks ne '') || ($nullok));
        }
    }
    return;
}

sub ayn { # msg, defanswer, help, backopt
    my ($msg,$def,$help,$backopt) = @_;
    my ($ques,$edr,$warn,$ayn,$key,$hk,$bk,$back,$quit,$umi,$original_ques,$timer,$elapsed);

    $edr=Obj::edr();

    return 'Y' if (($def eq $edr->{key}{yes}) && (Cfg::opt(qw(responsefile rwe silent))));
    return 'N' if (($def eq $edr->{key}{no}) && (Cfg::opt(qw(responsefile rwe silent))));

    # pad the question with options
    $back=1 if ($backopt);
    $bk=",$edr->{key}{back}" if ($back);
    $hk=",$edr->{key}{help}" if ($help);
    $ques=$msg->{msg};
    $umi=$msg->umi();
    $ques.=" [$edr->{key}{yes},$edr->{key}{no},$edr->{key}{quit}$bk$hk]";
    if ($def && $def ne $edr->{msg}{back}) {
        $ques.=" ($def)";
    }
    while (1) {
        $timer=Timer->new('Msg::ask');
        $timer->start();

        $original_ques=$ques;
        Msg::log($ques);
        $ques=linebreak($ques);
        log_question($ques);
        print "$edr->{tput}{bs}$ques$edr->{tput}{be} ";
        $key = '';
        $ayn = '';
        while($key ne "\n") {
            $key = getc(STDIN);
            if (!defined $key) {
                $ayn=$def if ($ayn eq '');
                last;
            }
            $ayn .= $key;
        }
        chomp($ayn);
        Msg::log($ayn);
        log_answer($ayn);

        $elapsed=$timer->stop();
        Metrics::add_phase_question_metrics('',"$original_ques",'umi',$umi);
        Metrics::add_phase_question_metrics('',"$original_ques",'time','push',$elapsed);

        # check answer
        $ayn = EDRu::despace($ayn);
        $ayn = $def if (($def) && ($ayn eq ''));
        if (($help) && ($ayn eq $edr->{key}{help})) {
            my $helpmsg=linebreak($help->{msg});
            print "\n$helpmsg\n\n";
        }
        return 'Y' if ($ayn =~ /^$edr->{key}{yes}$/mxi);
        return 'N' if ($ayn =~ /^$edr->{key}{no}$/mxi);
        if (($ayn=~ /^$edr->{key}{back}$/mxi) && ($back)) {
            return $edr->{msg}{back};
        }
        if ($ayn=~/^$edr->{key}{quit}$/mxi) {
            $quit=confirm_quit();
            if ($quit) {
                Msg::log("User entered $ayn: exiting");
                Msg::n();
                Msg::exit_summary($ques);
                EDR::exit_exitfile(EDR->EXITSUCCESS);
                return 'Y' if ($def eq $edr->{key}{yes});
                return 'N' if ($def eq $edr->{key}{no});
            }
        } elsif (((!($help)) && (!($ayn =~ /^[ynq]$/mi))) ||
                   (($help) && (!($ayn =~ /^[ynq\?]$/mi)))) {
            $warn=Msg::new("Invalid selection. Please re-enter\n");
            $warn->print;
        }
    }
    return;
}

sub aynn { # msg, help, backopt
    my ($msg,$help,$backopt)= @_;
    my $edr=Obj::edr();
    return $msg->ayn($edr->{key}{no},$help,$backopt);
}

sub ayny { # msg, help, backopt
    my ($msg,$help,$backopt)= @_;
    my $edr=Obj::edr();
    return $msg->ayn($edr->{key}{yes},$help,$backopt);
}

sub menu { # menu msgs, defanswer, help, backopt
    my ($msg,$menus,$def,$help,$backopt,$multisel,$paging,$multicolumn) = @_;
    my ($ques,$nmi,$valid,$edr,$ayn,$nl,$n,@sels,$opt,$back,$termy,$sel,$mi,$menu,$quit,$line,$max,$format,$width);

    $edr=Obj::edr();

    $back=1 if ($backopt);
    return $def if (($def) && (Cfg::opt(qw(responsefile rwe silent))));

    $nl=$#{$menus}+1;
    $opt="[1-$nl";
    $opt.=",$edr->{key}{back}" if ($back);
    $opt.=",$edr->{key}{quit}";
    $opt.=",$edr->{key}{help}" if ($help);
    $opt.=']';
    $ques = "$msg->{msg}";
    $nl = (string_width($ques)+string_width($opt)+string_width($def)>$edr->{tput}{termx}-string_width($edr->{msg}{indent})) ? "\n" : ' ';
    $ques .= "$nl$opt";
    $ques .= " ($def)" if (($def) && ($def ne ' '));
    $nmi = 0;
    $termy = $edr->{tput}{termy}-7;
    $termy = 20 if ($termy<2);
    $n = 0;
    $max = string_width("$edr->{tput}{bs}$edr->{msg}{indent} b$edr->{tput}{be})  $edr->{msg}{menuback}") if ($back);
    for my $mi (@{$menus}) {
        $mi=~s/\n/ /g;
        $nmi=sprintf('%2d',$nmi+1);
        $menu=linebreak("$edr->{tput}{bs}$edr->{msg}{indent}$nmi$edr->{tput}{be})  $mi");
        $width=string_width($menu);
        $max = $max > $width? $max : $width;
    }
    $nmi = 0;
    $format="%-${max}s";
    # if the longest menu item * columns we need to show is longer than the screen width, we'll treat it as single column.
    $multicolumn||=0;
    if ($max * $multicolumn > $edr->{tput}{termx}) {
       $multicolumn = 0;
    }
    for my $mi (@{$menus}) {
        $mi=~s/\n/ /g;
        $nmi=sprintf('%2d',$nmi+1);
        $menu=linebreak("$edr->{tput}{bs}$edr->{msg}{indent}$nmi$edr->{tput}{be})  $mi");
        if ($multicolumn && $nmi % $multicolumn) {
            $line .= string_sprintf($format, $menu);
        } else {
            $line .= "$menu\n";
            print $line;
            $line = '';
        }
        Msg::log("$edr->{msg}{indent}$nmi$edr->{msg}{indent}$mi");
        if ($paging) {
            $n++;
            Msg::prtc() if (($n!=($#$menus+1)) && ($n%($termy-1)==0));
        }
    }
    if ($back) {
        $menu=linebreak("$edr->{tput}{bs}$edr->{msg}{indent} b$edr->{tput}{be})  $edr->{msg}{menuback}");
        print "$line"."$menu\n";
        Msg::log("$edr->{msg}{indent} b)  $edr->{msg}{menuback}");
    }
    print "\n";
    while(1) {
        Msg::log($ques);
        $ques=linebreak($ques);
        log_question($ques);
        print "$edr->{tput}{bs}$ques$edr->{tput}{be} ";
        $menu = <STDIN>;
        $menu=EDRu::despace($menu);
        Msg::log("$menu");
        log_answer($menu);
        if ($menu=~/^$edr->{key}{quit}$/mxi) {
            $quit=confirm_quit();
            if ($quit) {
                Msg::log("User entered $menu: exiting");
                Msg::n();
                Msg::exit_summary($ques);
                EDR::exit_exitfile(EDR->EXITSUCCESS);
            } else {
                next;
            }
        } elsif (($menu=~ /^$edr->{key}{back}$/mxi) && ($back)) {
            return $edr->{msg}{back};
        }

        if (($help) && ($menu eq $edr->{key}{help})) {
            my $helpmsg=linebreak($help->{msg});
            print "\n$helpmsg\n\n";
            next;
        }
        $menu=$def if (($def) && ($menu eq ''));
        next if ($menu eq '');
        if ($multisel) {
            $menu=~s/,/ /mg;
            @sels=split(/\s+/m, $menu);
            $valid=1;
            for my $sel (@sels) {
                $valid=0 unless ($sel=~/^\d+$/m && $sel>=1 && $sel<=$nmi);
            }
            if ($valid) {
                if (wantarray) {
                    return @sels;
                } else {
                    return \@sels;
                }
            }
        } else {
            return "$menu" if ($menu=~/^\d+$/m && $menu>=1 && $menu<=$nmi);
        }
        $msg=Msg::new("Invalid input. Please retry.");
        $msg->print;
    }
    return;
}

# should we check that $msg is always a translated HASH ref or let
# programmers be lazy and pass strings
sub print {
    my $msg=shift;
    my $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    Msg::log($logmsg);
    $logmsg=linebreak($logmsg);
    print "$logmsg\n";
    return;
}

# print msg + newline
sub printn {
    my $msg=shift;
    my $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    Msg::log($logmsg);
    $logmsg=linebreak($logmsg);
    print "$logmsg\n\n";
    return;
}

# print newline + msg
sub nprint {
    my $msg=shift;
    my $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    Msg::log($logmsg);
    $logmsg=linebreak($logmsg);
    print "\n$logmsg\n";
    return;
}

# print messages such as:
#    "This is a <b>bold</b> text"
#    "This is a <u>underline</u> text"
sub print_rich_text {
    my $msg=shift;
    my ($logmsg,$edr);
    $edr=Obj::edr();
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    Msg::log($logmsg);
    $logmsg=~ s/<b>/$edr->{tput}{bs}/mg;
    $logmsg=~ s/<\/b>/$edr->{tput}{be}/mg;
    $logmsg=~ s/<u>/$edr->{tput}{us}/mg;
    $logmsg=~ s/<\/u>/$edr->{tput}{ue}/mg;
    print "$logmsg\n";
    return;
}

sub n { print "\n"; return;}

sub equal_bar {
    print '=' x 75 . "\n";
    return;
}

sub bold {
    my ($msg,$nonewline) = @_;
    my ($edr,$logmsg,$nl);
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    $edr=Obj::edr();
    Msg::log($logmsg);
    $logmsg=linebreak($logmsg);
    $nl="\n" unless ($nonewline);
    print "$edr->{tput}{bs}$logmsg$edr->{tput}{be}$nl";
    return;
}

sub bullet {
    my ($msg, $indent) = @_;
    my (@chars,$char,$logmsg,$str);
    @chars=qw(* o . . . . . . . . . . .);
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    $char=$chars[$indent];
    $str="    "x($indent+1)." $char $logmsg";
    $str=linebreak($str);
    print "$str\n";
}

sub bold_bullet {
    my ($msg, $msg2, $indent) = @_;
    my (@chars,$char,$edr,$logmsg,$logmsg2,$str);
    $edr=Obj::edr();
    @chars=qw(* o . . . . . . . . . . .);
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    $logmsg2 = (ref($msg2) =~ m/^Msg/) ? $msg2->{msg} : $msg2;
    $logmsg2 = '' unless (defined $msg2);
    $char=$chars[$indent];
    $str="    "x($indent+1)." $char $edr->{tput}{bs}$logmsg$edr->{tput}{be} - $logmsg2";
    $str=linebreak($str);
    print "$str\n";
}

sub die {
    my ($msg,$exit) = @_;
    Msg::error($msg);
    Msg::n();
    my $edr=$Obj::pool{EDR};
    if (!defined($edr)) {
        $exit=1 if(!defined($exit));
        exit $exit;
    }
    $exit=$edr->{exitcode} if(!defined($exit) && defined($edr->{exitcode}));
    return $exit if ($edr->{die});
    $edr->{die}=1;

    Msg::exit_summary($msg);

    # if Msg::die called, exit value should at least be 1(non-zero)
    $exit=EDR->EXITUNDEFINEDISSUE unless defined($exit);

    if (ref($msg) =~ m/^Msg/) {
        $edr->exit_noexitfile($exit);
    } else {
        $edr->exit_exitfile($exit);
    }
    return;
}

# print ERROR V-##-##-## $msg
sub error {
    my $msg=shift;
    my $emsg=umi_msg('CPI', 'ERROR', $msg);
    my $edr=Obj::edr();
    Msg::log($emsg);
    $emsg=linebreak($emsg);
    print "$emsg\n";
    $edr->set_exitcode(EDR->EXITUNDEFINEDISSUE);
    return;
}

# print WARNING V-##-##-## $msg
sub warning {
    my $msg=shift;
    my $wmsg=umi_msg('CPI', 'WARNING', $msg);
    Msg::log($wmsg);
    $wmsg=linebreak($wmsg);
    print "$wmsg\n";
    return;
}

sub left {
    my $msg=shift;
    my ($logmsg,$edr);
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    $edr=Obj::edr();
    $logmsg="$edr->{msg}{indent}$logmsg ";
    print "$logmsg";
    Msg::log($logmsg);
    $edr->{msg}{pblr}=$logmsg;
    return;
}

sub right {
    my $msg=shift;
    my($logmsg,$edr,$p1,$p2,$sp);
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $logmsg = '' unless (defined $msg);
    $edr=Obj::edr();
    $p1=string_width($edr->{msg}{pblr});
    $p2=string_width($logmsg);
    $sp=$edr->{tput}{termx}-string_width($edr->{msg}{indent})-$p1-$p2-1;
    $logmsg=('.' x $sp) . " $logmsg";;
    print "$logmsg\n";
    Msg::log($logmsg);
    return;
}

sub right_done {
    my $msg=Msg::new("Done");
    $msg->right;
    return;
}

sub right_failed {
    my $msg=Msg::new("Failed");
    $msg->right;
    return;
}

sub right_ok {
    my $msg=Msg::new("OK");
    $msg->right;
    return;
}

sub right_running {
    my $msg=Msg::new("Running");
    $msg->right;
    return;
}

sub right_not_running {
    my $msg=Msg::new("Not running");
    $msg->right;
    return;
}

# ($msg, $file1, $file2); # default is $edr->{logfile}
# expects scalar $msg to be passed instead of \%msg
sub log {
    my ($msg,@vars) = @_;
    my(@files,$edr,$file,$logmsg,$tid,$tidtime);
    Msg::debug($msg) if ($Obj::pool{EDR}); # circular loop without this
    $edr=Obj::edr();
    return '' if ($edr->{donotlog});

    push (@files, $edr->{logfile2}) if ($edr->{logfile2});

    if (@vars) {
        push (@files, @vars);
    } elsif ($edr->{logfileid}) {
        push (@files,"$edr->{logfile}"."$edr->{logfileid}");
    } elsif ($edr->{logfile}) {
        $tid=Obj::tid();
        $tid||=0;
        push (@files,"$edr->{logfile}"."$tid");
    }
#    return '' unless (@files);

    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $tidtime=EDRu::tidtime();
    unless (@files){
        $edr->{tolog} .= "\n$tidtime $logmsg";
        return 0;
    }
    for my $file (@files) {
        EDRu::appendfile("$tidtime $logmsg", $file) if ($file && (-d EDRu::dirname($file)));
    }
    return '';
}

sub add_summary {
    my ($msg,$newline)=@_;
    my $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    return unless $logmsg;
    $logmsg = "\n$logmsg" if $newline;
    EDR::set_value('custom_summary', 'push', $logmsg);
    return;
}

sub exit_summary {
    my ($msg)=@_;
    my ($summary,$edr);

    $edr=Obj::edr();
    $msg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    return if $msg =~ /^\s*$/;
    $summary = Msg::new("$edr->{script} was terminated at:\n$msg");
    $summary->add_summary(1);
    return;
}

sub debug {
    my $msg=shift;
    my $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    printf "%s %s\n", EDRu::tidtime(), $logmsg, if (Cfg::opt(qw(trace debug)));
    return;
}

sub prtc {
    my ($msg,$edr,$prtc,$quit);
    if (Cfg::opt(qw(responsefile rwe silent)))  {
        sleep 3;
        return;
    }
    $edr=Obj::edr();
    print "\n$edr->{tput}{bs}$edr->{msg}{prtc}$edr->{tput}{be} ";
    log_question($edr->{msg}{prtc});
    $prtc = <STDIN>;
    chomp($prtc);
    log_answer($prtc);
    if ($prtc=~/^$edr->{key}{quit}$/mxi) {
        $quit=confirm_quit();
        if ($quit) {
            Msg::log("User entered $prtc: exiting");
            Msg::n();
            EDR::exit_exitfile(EDR->EXITSUCCESS);
        }
    }
    return;
}

sub progress {
    my $stage = shift;
    my($edr,$msg,$space,$progress_highlight,$progress_width,$percent);
    my($i,$n,$task_count,$screen_height,@tasks,$task,$left,$right);
    return if Cfg::opt(qw(trace debug));
    $edr = Obj::edr();
    return unless ($edr->{steps});
    if ($edr->{completed}==0) {
        $msg=Msg::new("Logs are being written to $edr->{tmpdir} while $edr->{script} is in progress\n");
        $msg->print;
        print "$edr->{tput}{sc}";
    } else {
        print "$edr->{tput}{rc}";
    }

    # show progress bar
    $percent=int(100*$edr->{completed}/$edr->{steps});
    $stage->progress_bar($percent);
    print "\n\n";
    Msg::log("progress($stage->{msg}: $percent $edr->{completed}-$edr->{steps})");

    # show estimated remaining time line
    $edr->{remaining}||='';
    $edr->{remaining}=~s/Unknown/       /m;
    $left=Msg::new("Estimated time remaining: (mm:ss) $edr->{remaining}");
    $right=Msg::new("$edr->{completed} of $edr->{steps}");
    $n=$edr->{tput}{termx}-string_width($edr->{msg}{indent})*2-string_width($left->{msg})-string_width($right->{msg});
    $msg="$edr->{msg}{indent}$left->{msg}";
    $msg.=(' ' x $n);
    $msg.="$right->{msg}";
    print "$msg\n\n";

    # show detail steps informations
    $edr->{msglist}||='';
    @tasks=split(/@@@/m, $edr->{msglist});
    $task_count=scalar @tasks;
    $screen_height=$edr->{tput}{termy} - 12;
    print "$edr->{tput}{ed}" if ($task_count>$screen_height);
    $i=0;
    for my $task (@tasks) {
        $i++;
        next if ($task_count>$screen_height && $i<$task_count-$screen_height);
        ($left,$right)=split(/!!!/m, $task);
        print "$edr->{msg}{indent}$left ";
        if ($right) {
            $n=$edr->{tput}{termx}-string_width($edr->{msg}{indent})*2-string_width($left)-string_width($right)-2;
            $msg=('.' x $n);
            $msg.=" $right";
            print "$msg\n";
        }
    }
    return;
}

sub progress_bar {
    my ($msg,$percentage,$full_width) = @_;
    my ($title,$edr,$space,$progress_highlight,$progress_width);
    $title = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;
    $title = '' unless (defined $msg);

    $percentage=100 if ($percentage>100);
    $percentage=0 if ($percentage<0);

    $edr = Obj::edr();
    $msg='';
    unless ($full_width) {
        $full_width=$edr->{tput}{termx} - string_width($edr->{msg}{indent})*2;
        $msg="$edr->{msg}{indent}";
    }
    $progress_width=$full_width-string_width($title)-7;
    $progress_highlight=int($progress_width*$percentage/100);

    $space=($percentage<10) ? '   ' : ($percentage<100) ? '  ' : ' ';
    $msg.="$title: $percentage" . '%' . "$space";
    $msg.=$edr->{tput}{ss};
    $msg.=(' ' x $progress_highlight);
    $msg.="$edr->{tput}{se}";
    $msg.=('_' x ($progress_width - $progress_highlight));
    print "$msg \r";
    return;
}

sub spin {
    my($edr,@spin);
    if (!Cfg::opt(qw(trace debug redirect))) {
        @spin=qw(/ - \ |);
        $edr=Obj::edr();
        $edr->{spincount}++;
        $edr->{spincount}=0 if ($edr->{spincount} >= 4);
        print "$spin[$edr->{spincount}%4]$edr->{tput}{cl}";
    }
    sleep 1;
    return;
}

sub title {
    my $msg=shift;
    my($edr,$logmsg,$sysmsg,$es,$es_sys,$ns,$ns_sys,$ss,$ss_sys);
    my($title,$termx,$termy);

    $edr=Obj::edr();

    $title=$edr->{msg}{title}||'';
    $termx=$edr->{tput}{termx};
    $termy=$edr->{tput}{termy};

    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $title;
    $ns=int(($termx-string_width($logmsg))/2);
    $ss=(' ' x $ns);
    $ns=$termx-$ns-string_width($logmsg);
    $es=(' ' x $ns);

    # print newlines anyway so you can scroll back after a clear
    print "\n" x $termy;
    print "$edr->{tput}{cs}$edr->{tput}{ss}$ss$logmsg$es$edr->{tput}{se}\n";

    $sysmsg = ($logmsg eq $title) ? $edr->{msg}{systems} : '';
    if ($sysmsg) {
        $ns_sys=int(($termx-string_width($sysmsg))/2);
        $ss_sys=(' ' x $ns_sys);
        $ns_sys=$termx-$ns_sys-string_width($sysmsg);
        $es_sys=(' ' x $ns_sys);
        print "$edr->{tput}{ss}$ss_sys$sysmsg$es_sys$edr->{tput}{se}\n";
    }
    print "\n";
    return;
}

sub translate {
    my ($msg, $catid, $msgid,@args) = @_;
    my ($edr,$lang,$vxgettext,$vxa,$arg,$env,$tmsg,$utf8);
    # translate here
    $edr=Obj::edr();
    $lang=$edr->{envlang};

    return $msg if (!$lang || $lang eq 'C');

    $vxgettext=$edr->{vxgettext};
    $catid ||= $msg->{catid};
    $msgid ||= $msg->{msgid};

    # translate the message
    $tmsg = $msg;
    if ((EDRu::isint($catid) && ($catid>0)) && (EDRu::isint($msgid) &&($msgid>0)) && (defined $vxgettext && -x "$vxgettext")) {
        #           MSG            ARG
        #  =============================
        #  %        %%              %
        #  \        \\\\            \\
        #  $        \$              \$
        #  `        \`              \`

        $utf8=EDRu::decode_to_utf8($edr,$msg);
        $utf8=~s/\\/\\\\\\\\/g;
        $utf8=~s/\%/\%\%/mg;
        $msg=$utf8;

        for my $arg (@args){
            $utf8=EDRu::decode_to_utf8($edr,$arg);
            $utf8=~s/\\/\\\\/g;
            $arg=$utf8;
        }

        for my $arg ("$msg", $catid, $msgid, @args) {
            $arg=~s/\$/\\\$/mg;
            $arg=~s/`/\\`/mg;
            $arg=~s/"/\\"/mg;
            $vxa.=" \"$arg\"";
        }
        $vxa=EDRu::encode_from_utf8($edr,$vxa);
        $env="LANG=$edr->{envlang}; export LANG; LC_ALL=$edr->{envlang}; export LC_ALL; VX_BMCMNEM=$edr->{vx_bmcmnem}; export VX_BMCMNEM; VX_BMCORIGID=$edr->{vx_bmcorigid}; export VX_BMCORIGID; VX_BMCDOMAINDIR=$edr->{vx_bmcdomaindir}; export VX_BMCDOMAINDIR;";
        #Msg::debug("$env $edr->{vxgettext} $vxa");
        $tmsg=`$env $vxgettext $vxa 2>/dev/null`;
        chomp($tmsg);
        #Msg::debug($tmsg);
    }

    return $tmsg;
}

sub linebreak {
    my $msg=shift;
    my ($edr,$wrapmsg,$utf8,$initial_tab,$subsequent_tab,$columns);

    $edr=Obj::edr();
    $columns=$edr->{tput}{termx};
    return $msg unless ($columns);

    $initial_tab='';
    $subsequent_tab=$edr->{spacelinebreak}||'';
    $utf8=EDRu::decode_to_utf8($edr,$msg);
    $wrapmsg=EDRu::utf8_wrap_text($initial_tab,$subsequent_tab,$columns,$utf8);
    return EDRu::encode_from_utf8($edr,$wrapmsg);
}

sub string_width {
    my $msg=shift;
    my ($edr,$encoding,$utf8);

    return 0 unless(defined $msg);

    $edr=Obj::edr();
    $encoding=$edr->{locale_encoding};
    if (defined $encoding) {
        $utf8=EDRu::decode_to_utf8($edr,$msg);
        return EDRu::utf8_string_width($utf8);
    }
    return length($msg);
}

sub string_sprintf {
    my ($format,@args) = @_;
    my ($edr,$encoding,@args1,$arg,$utf8);

    $edr=Obj::edr();
    $encoding=$edr->{locale_encoding};
    if (defined $encoding) {
        $format=EDRu::decode_to_utf8($edr,$format);
        @args1=();
        for my $arg (@args) {
            push(@args1, EDRu::decode_to_utf8($edr,$arg));
        }
        $utf8=EDRu::utf8_sprintf($format,@args1);
        return EDRu::encode_from_utf8($edr,$utf8);
    }
    return sprintf($format,@args);
}

# this sub is to print a table
# INPUT1 values is a array ref including all the information, eg. $array->[0]{'attribute'}
# INPUT2 titles is a array ref that which key-value should be printed out
sub table {
    my ($values,$titles) = @_;
    my (@max,$i,$length,$format,@items,$break,@keys,@headers,$type,$header,$key);

    my $edr=Obj::edr();
    @max = ();
    for my $value (@$values){
        $i = 0;
        for my $title (@$titles) {
            $type = ref($title);#this should be '' or HASH
            if($type) {
                Msg::die("The titles param is not right!") unless $type eq "ARRAY"
                                                           && defined $title->[0] && $title->[0] && defined $title->[1];
                $key = $title->[0];
                $header = $title->[1];

            } else {
                $key = $header = $title;
            }
            push(@keys,$key);
            push(@headers,$header);
            $max[$i] ||= length($header) + 1;
            $length = 0;
            $length = length($value->{$key}) + 1 if defined $value->{$key};
            $max[$i] = ($length > $max[$i]) ? $length : $max[$i];
            $i++;
        }
    }

    $format = "";
    $break = '';
    for my $i (@max) {
        $format .= "\%-$i".'s';
        $break .= '=' x $i;
    }

    unless ($break) {
        Msg::bold("None");
        return;
    }

    Msg::bold(string_sprintf($format,@headers));
    Msg::print($break);
    for my $value (@$values){
        @items = ();
        for my $key (@keys) {
            my $temp =  defined $value->{$key} ?
                                (ref($value->{$key}) ? 'Ref' : $value->{$key})
                                : '-';
            push(@items,$temp);
        }
        Msg::print(string_sprintf($format,@items));
    }

    return;
}

sub page_reset {
    my $edr=Obj::edr();
    $edr->{page_line_no}=0;
    return;
}

sub page_set_line_no {
    my $line_no=shift;
    my $edr=Obj::edr();
    $edr->{page_line_no}=$line_no;
    return;
}

sub page_print {
    my ($msg,$noprtc,$bold) = @_;
    my ($edr,$first_str,$width,$str,$line_no,$termy,$logmsg);

    $edr=Obj::edr();
    $logmsg = (ref($msg) =~ m/^Msg/) ? $msg->{msg} : $msg;

    $termy=$edr->{tput}{termy};
    $line_no=$edr->{page_line_no} || 1;
    $first_str=1;
    for my $str (split(/\n/,$logmsg,-1)) {
        $str=~s/\t/        /mg;
        $width=Msg::string_width($str);
        if ($width>0) {
            $line_no+=int(($width-1)/$edr->{tput}{termx});
            #$line_no++ if ($width%$edr->{tput}{termx}!=0);
        }
        if ($first_str) {
            $first_str=0;
        } else {
            print "\n";
            $line_no++;
        }
        $str=linebreak($str);
        $str="$edr->{tput}{bs}$str$edr->{tput}{be}" if ($bold);
        print "$str";
        if ($line_no%($termy-1)==0) {
            Msg::prtc() unless ($noprtc);
            $line_no=0;
        }
    }
    print "\n";
    $line_no++;
    $edr->{page_line_no}=$line_no;
    return;
}

sub page_bold {
    my ($msg,$noprtc)= @_;
    page_print($msg,$noprtc,1);
    return;
}

sub log_question {
    my $msg = shift;
    my ($edr,$file,$head);
    return unless (Cfg::opt('askfile'));

    $edr=Obj::edr();
    $file=$edr->{askfile};
    return unless ($file);

    $head = '';
    if (!-f "$file") {
        $head = "//PATH=$ENV{PWD}\n";
        $head .= "//CMD=$0\n";
        $head .= "//ARGV=@ARGV\n";
        $head .= "//COLS=$edr->{tput}{termx}\n\n";
    }
    $msg =~ s/^\s+//m;
    $msg =~ s/\s+$//m;
    $msg = $head.'>>'.$msg;
    EDRu::appendfile("$msg", $file);
    return;
}

sub log_answer {
    my $msg = shift;
    my ($edr,$file);
    return unless (Cfg::opt('askfile'));

    $edr=Obj::edr();
    $file=$edr->{askfile};
    return unless ($file);

    $msg =~ s/^\s+//m;
    $msg =~ s/\s+$//m;
    EDRu::appendfile("<<$msg\n\n", $file);
    return;
}

sub set_progress {
    my ($elapsed,$edr,$pct);
    $edr=Obj::edr();

    if ($edr->{steps}) {
        $edr->{completed}=($edr->{completed}>$edr->{steps})?$edr->{steps}:$edr->{completed};
        $pct = $edr->{completed} / $edr->{steps};
        $edr->{pct} = int($pct*100);
    } else {
        $pct = 0;
        $edr->{pct} = 0;
    }

    if ($edr->{completed} && $pct != 0) {
        $elapsed = time() - $edr->{start};
        $edr->{elapsed} = EDRu::clocktime($elapsed,5);
        $edr->{remaining} = EDRu::clocktime($elapsed / $pct * (1 - $pct), 5);
    } else {
        $edr->{elapsed} = '';
        $edr->{remaining} = '';
    }
    return;
}

sub display_left {
    my ($stage,$msg) = @_;
    $msg=new_obj($msg) unless (ref($msg) =~ m/^Msg/);
    my $edr = Obj::edr();
    if (!$edr->{msglist}) {
        $edr->{msglist} = $msg->{msg};
    } else {
        $edr->{msglist} .= "@@@" . $msg->{msg};
    }

    $msg->set_progress();
    (Cfg::opt('redirect')) ? $msg->left: $stage->progress($msg);
    return;
}

sub display_right {
    my ($stage,$msg) = @_;
    my $edr = Obj::edr();
    $edr->{completed} ++;
    $edr->{completed}=($edr->{completed}>$edr->{steps})?$edr->{steps}:$edr->{completed};
    if (defined $msg && $msg eq 'failed') {
        $msg = Msg::new("Failed");
    } else {
        $msg ||= Msg::new("Done");
    }
    $msg=new_obj($msg) unless (ref($msg) =~ m/^Msg/);

    $edr->{msglist} .= '!!!' . $msg->{msg};
    $msg->set_progress();
    (Cfg::opt('redirect')) ? $msg->right : $stage->progress($msg);
    return;
}

sub display_bold {
    my $msg = shift;
    $msg=new_obj($msg) unless (ref($msg) =~ m/^Msg/);
    $msg->bold();
    Msg::n();
    $msg->set_progress();
    return;
}

# not sure exaclty how $web->{errors} will be used, but its a start
sub display_completion {
    my ($msg,$errors,$passmsg,$failmsg) = @_;
    my $edr=Obj::edr();
    Msg::n();

    if ($#$errors < 0) {
        Msg::display_bold($passmsg);
        Msg::add_summary($passmsg,1);
    } else {
        Msg::display_bold($failmsg);
        Msg::add_summary($failmsg,1);

        for my $errmsg (@$errors) {
            Msg::print($errmsg);
            Msg::add_summary($errmsg);
        }
        Msg::n();
        $edr->set_exitcode(EDR->EXITUNDEFINEDISSUE) unless ($edr->{exitcode});
    }
    return '';
}

sub display_status {
    my ($msg,$status) = @_;
    $msg=new_obj($msg) unless (ref($msg) =~ m/^Msg/);
    my $edr = Obj::edr();
    if (!$edr->{msglist}) {
        $edr->{msglist} = $msg->{msg};
    } else {
        $edr->{msglist} .= "@@@" . $msg->{msg};
    }
    $msg->left();

    if (!$status) {
        $status = Msg::new("Done");
    } elsif ($status eq 'failed') {
        $status = Msg::new("Failed");
    }
    $edr->{msglist} .= '!!!' . $status->{msg};
    $status->right();

    $msg->set_progress();
    return;
}

sub addError {
}

# adds an warning message to web
sub addWarning {
}

# adds a note message to web
sub addNote {
}

1;
