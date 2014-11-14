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
package MsgWeb;
use Msg;
use strict;

@MsgWeb::ISA = qw(Msg);

sub die {
    my ($msg,$exit) = @_;
    my ($edr,$webmsg);
    $exit||=1 if ($msg);
    $exit||=0;

    $edr=$Obj::pool{EDR};
    exit $exit unless (defined $edr);
    return $exit if ($edr->{die});
    $edr->{die}=1;

    $webmsg=Msg::umi_msg('CPI', 'ERROR', $msg);
    Msg::log($webmsg);
    EDRu::writefile($webmsg, "/tmp/$edr->{scriptid}-die.msg");

    my $web = Obj::web();
    $web->{form} = 'error';
    my $form = $web->error_asm($webmsg);
    $web->write_to('form', $form);
    $web->write_status();

    Msg::exit_summary($msg);

    $edr->exit_noexitfile($exit);
    return;
}

sub ayn {
    my ($msg,$def,$help,$backopt,$webmsg) = @_;
    my $web = Obj::web();
    my $edr = Obj::edr();

    return 'Y' if (($def eq $edr->{key}{yes}) && (Cfg::opt('responsefile')));
    return 'N' if (($def eq $edr->{key}{no}) && (Cfg::opt('responsefile')));
    return $web->web_script_form('confirm',$msg, $webmsg);
}

sub aynn { # msg, help, backopt
    my $msg=shift;
    my $edr=Obj::edr();
    return $msg->ayn($edr->{key}{no},@_);
}

sub ayny { # msg, help, backopt
    my $msg=shift;
    my $edr=Obj::edr();
    return $msg->ayn($edr->{key}{yes},@_);
}

sub set_progress {
    my ($elapsed, $edr, $pct);
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

    my $web = Obj::web();
    $web->{steps} = $edr->{steps};
    $web->{completed} = $edr->{completed};
    $web->{pct} = $edr->{pct};
    $web->{start} = $edr->{start};
    $web->{elapsed} = $edr->{elapsed};
    $web->{remaining} = $edr->{remaining};
    $web->{msglist} = $edr->{msglist};
    $web->write_status();
    return;
}

sub display_completion {
    my ($msg,$errors,$passmsg,$failmsg) = @_;
    my $web= Obj::web();
    Msg::n();

    if ($#$errors < 0) {
        Msg::display_bold($passmsg);
    } else {
        Msg::display_bold($failmsg);

        my @errmsgs;
        for my $errmsg (@$errors) {
            Msg::print($errmsg);
            if (ref($errmsg) =~ m/^Msg/) {
                push(@errmsgs, $errmsg->{msg}) if(index($web->{warnings},$errmsg->{msg})<0);
            } else {
                push(@errmsgs, $errmsg) if(index($web->{warnings},$errmsg)<0);
            }
        }
        Msg::n();

        $msg->addError(join('<br/>', @errmsgs)) if (@errmsgs > 0);
    }
    return '';
}

sub addError {
    my ($msg,$error) = @_;
    my $web= Obj::web();

    $web->{errors} .= $error . "\n\n";
    return;
}

# adds an warning message to web
sub addWarning {
    my ($msg,$warning) = @_;
    my $web= Obj::web();

    $web->{warnings} .= $warning . "\n\n";
    return;
}

# adds a note message to web
sub addNote {
    my ($msg,$note) = @_;
    my $web= Obj::web();
    $web->{notes} .= $note . "\n\n";
    return;
}
=web6.5
sub confirm_quit {
    my ($msg,$ayn);
    $msg = Msg::new("Are you sure you want to quit?");
    $ayn = $msg->ayny('',0,'');
    
    return ($ayn eq 'Y') ? 1 : 0;
}

sub ask { # msg, defanswer, help, backopt, nullok, noquit, nonasciiok
    my ($msg,$def,$help,$backopt,$nullok,$noquit,$nonasciiok) = @_;
    my ($ques,$edr,$warn,@opts,$back,$aks,$quit);

    $edr=Obj::edr();
    my $web= Obj::web();
    # pad the question with options
    $ques=$msg->{msg};
    $back=1 if ($backopt);
    if (Cfg::opt(qw(responsefile rwe silent))) {
        if (defined($def)) {
            return $def;
        } else {
            Msg::die("Answer for '$ques' is required with responsefile or silent mode");
        }
    }

    while (1) {
        $aks =$web->web_script_form('msg_ask',$msg,$def,$help,$backopt,$nullok,$noquit,$nonasciiok);
        
        # check answer
        if (($aks=~/^$edr->{key}{back}$/mxi) && ($back)) {
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

sub menu { # menu msgs, defanswer, help, backopt
    my ($msg,$menus,$def,$help,$backopt,$multisel,$paging,$multicolumn) = @_;
    my ($ques,$nmi,$valid,$edr,$ayn,$nl,$n,@sels,$opt,$back,$termy,$sel,$mi,$menu,$quit,$line,$max,$format,$width,$web);

    $edr=Obj::edr();
    $web = Obj::web();
    $back=1 if ($backopt);
    return $def if (($def) && (Cfg::opt(qw(responsefile rwe silent))));

    while(1) {
        $menu =$web->web_script_form('msg_menu',$msg,$menus,$def,$help,$backopt,$multisel,$paging,$multicolumn);
        if (($menu=~ /^$edr->{key}{back}$/mxi) && ($back)) {
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
            return \@sels if ($valid);
        } else {
            return "$menu" if ($menu=~/^\d+$/m && $menu>=1 && $menu<=$nmi);
        }
        $msg=Msg::new("Invalid input. Please retry.");
        $msg->print;
    }
    return;
}
=cut

1;
