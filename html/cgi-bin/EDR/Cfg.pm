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
package Cfg;

use strict;

@Cfg::ISA = qw(Obj);

# to define default options when necessary
sub init {
    my $cfg=shift;
    # $cfg->{opt}{mpok}=1;
    return $cfg;
}

sub set_value {
    my $cfg=shift;
    Obj::set_value($cfg->{pool}, @_);
    Thr::setq($cfg->{pool}, @_) if (EDR::thread_support());
    return;
}

sub swap_passwords {
    my $cfg=shift;

    for my $key ((keys(%{$cfg}))) {
        if ($key=~/password/mi)    {
            if (ref($cfg->{$key}) eq 'HASH') {
                for my $keyi (keys(%{$cfg->{$key}})) {
                    $cfg->{$key}{$keyi}='password_removed';
                }
            } else {
                $cfg->{$key}='password_removed';
            }
        }
    }
    return;
}

sub opt {
    my $cfg=$Obj::pool{Cfg};
    return '' unless (defined $cfg);

    for my $opt (@_) {
        return $cfg->{opt}{$opt} if (defined($cfg->{opt}{$opt}));
    }
    return '';
}

sub set_opt {
    my ($opt,$value)= @_;
    my $cfg=Obj::cfg();
    $value||=1;
    $cfg->set_value("opt,$opt","$value");
    return;
}

sub unset_opt {
    my $opt=shift;
    my $cfg=Obj::cfg();
    delete $cfg->{opt}{$opt};
    return;
}

sub check_responsefile_passwords {
    my $cfg=shift;
    for my $key (sort (keys(%{$cfg}))) {
        if ($key=~/password/mi)  {
            return $key;
        }
    }
    return '';
}

sub create_responsefile {
    my $cfg=shift;
    my ($responsefile,$rf,$edr,$simflag,$tuns,$tf,$tunablesfile,$msg,$allsyssymbol);
    return if (Cfg::opt('responsefile'));
    $cfg->swap_passwords();
    $responsefile=shift;
    $edr=Obj::edr();
    if (Cfg::opt('makeresponsefile')){
        $simflag = 1;
        Cfg::unset_opt('makeresponsefile');
    }
    delete($cfg->{pool});
    delete($cfg->{medipath});
    delete($cfg->{opt}{require});
    delete($cfg->{last}{sub}) if ($responsefile !~ /exitfile/m);
    delete($cfg->{systemscfg}) if ($#{$cfg->{systems}}==$#{$cfg->{systemscfg}});

    $tuns = {};
    for my $tun (keys %{$cfg->{tunable}}) {
        $tuns->{$tun} = $cfg->{tunable}{$tun};
    }
    delete($cfg->{opt}{tunablesfile});
    delete($cfg->{tunable});

    $rf="#\n# Configuration Values:\n#\nour \%CFG;\n\n".EDRu::hash2def($cfg, 'CFG')."\n1;\n";

    EDR::responsefile_comments();
    for my $key (sort keys(%{$edr->{rfc}})) {
        $rf.=cfgkey($key, @{$edr->{rfc}{$key}});
    }
    # prod_sub("responsefile_comments");
    # for $key(sort keys(%{$edr->{prfc}})) {
    #     $rf.=cfgkey($key, @{$edr->{prfc}{$key}});
    # }

    $tf = $cfg->tunables_template_content($tuns);

    $rf .= "\n".$tf if (keys %$tuns);
    $responsefile = EDR::get('responsefile') unless ($responsefile);
    EDRu::writefile($rf, "$responsefile");
    #e3609863:$cfg->{pool} has been deleted, so makeresponsefile couldn't be set by set_value.
    $cfg->{opt}{makeresponsefile}=1 if ($simflag);

    $tunablesfile = EDR::get('tunablesfile');
    EDRu::writefile($tf, "$tunablesfile");
    EDR::register_save_logfiles($tunablesfile);

    return '';
}

# $key is first dimension of key, except for $cfg{install}{$key} variables
# $req=1 required, $req=0 optional
# $list=1 required, $list=0 scalar
# $d2 defined=second dimension id, undefined=1 dimesional variable
sub cfgkey {
    my ($key,$desc,$req,$list,$d2,$d2_desc) = @_;
    my ($msg,$comm);
    if ($d2) {
        $d2_desc ||='system' if ($d2 eq '1');
        $comm='CFG{'.$key."}{<$d2_desc>}";
    } else {
        $comm='CFG{'.$key.'}';
    }
    if ($key=~/__/m) {
        $comm=~s/__/}{/m;
        $d2=1;
    }
    # for translation, this is the cleanest way to do it
    if ((!$req) && (!$list) && (!$d2)) {
        $msg=Msg::new("$comm is an optional one dimensional scalar variable");
    } elsif (($req) && (!$list) && (!$d2)) {
        $msg=Msg::new("$comm is a required one dimensional scalar variable");
    } elsif ((!$req) && ($list) && (!$d2)) {
        $msg=Msg::new("$comm is an optional one dimensional list variable");
    } elsif (($req) && ($list) && (!$d2)) {
        $msg=Msg::new("$comm is a required one dimensional list variable");
    } elsif ((!$req) && (!$list) && ($d2)) {
        $msg=Msg::new("$comm is an optional two dimensional scalar variable");
    } elsif (($req) && (!$list) && ($d2)) {
        $msg=Msg::new("$comm is a required two dimensional scalar variable");
    } elsif ((!$req) && ($list) && ($d2)) {
        $msg=Msg::new("$comm is an optional two dimensional list variable");
    } elsif (($req) && ($list) && ($d2)) {
        $msg=Msg::new("$comm is a required two dimensional list variable");
    }
    $msg->{msg}.="\n$desc" if ($desc);
    $msg->{msg}.="\n";
    $msg->{msg}=~s/\n/\n# /g;
    return "# $msg->{msg}\n";
}

sub tunable_comment {
    my ($tunable_info) = @_;
    my ($tun_cmt,$defobjname,$msg);
    #my ($min,$max,$mul);
    # tunable name and description
    $msg = Msg::new("Tunable");
    $tun_cmt =Msg::string_sprintf("%-15s", $msg->{msg}.':') . "\$TUN{\"".$tunable_info->{name}."\"}{\"<system>\"|\"*\"}";
    $tun_cmt.="\n";
    $msg = Msg::new("Description");
    $tun_cmt.=Msg::string_sprintf("%-15s", $msg->{msg}.':') ."($tunable_info->{define_object}{name}) " .$tunable_info->{desc};

    # when to set and whether requires reboot
    $defobjname = $tunable_info->{define_object}{name};
    $msg=undef;
    if ($tunable_info->{when_to_set} == 0){
        if ($tunable_info->{reboot}){
            $msg=Msg::new("This tunable must be set before $defobjname is started and requires system reboot to take effect");
        } else {
            $msg=Msg::new("This tunable must be set before $defobjname is started");
        }
    } elsif ($tunable_info->{when_to_set} == 1) {
        if ($tunable_info->{reboot}){
            $msg=Msg::new("This tunable must be set after $defobjname is started and requires system reboot to take effect");
        } else {
            $msg=Msg::new("This tunable must be set after $defobjname is started");
        }
    } else {
        if($tunable_info->{reboot}) {
            $msg=Msg::new("This tunable requires system reboot to take effect");
        }
    }
    if ($msg) {
        $tun_cmt.="\n\t$msg->{msg}";
    }

    # # valid value range
    # if ($tunable_info->{type} eq "enum"){
    #     $msg=Msg::new("The value of this tunable must be set to one of the following values: ");
    #     $tun_cmt.="\n\t".$msg->{msg}. join(", ", @{$tunable_info->{values}});
    # } elsif ($tunable_info->{type} eq "range") {
    #     $min = $tunable_info->{values}[0];
    #     $max = $tunable_info->{values}[1];
    #     $mul = $tunable_info->{values}[2];
    #     $msg = undef;
    #     if ( $min ne undef && $max ne undef) {
    #         if ($mul) {
    #             $msg=Msg::new("The value of this tunable should be an integer between $min and $max inclusive and must be a multiple of $mul");
    #         } else {
    #             $msg=Msg::new("The value of this tunable should be an integer between $min and $max inclusive");
    #         }
    #     } elsif ($min ne undef) {
    #         if ($mul) {
    #             $msg=Msg::new("The value of this tunable should be an integer equal to or greater than $min and must be a multiple of $mul");
    #         } else {
    #             $msg=Msg::new("The value of this tunable should be an integer equal to or greater than $min");
    #         }
    #     } elsif ($max ne undef) {
    #         if ($mul) {
    #             $msg=Msg::new("The value of this tunable should be an integer equal to or less than $max and must be a multiple of $mul");
    #         } else {
    #             $msg=Msg::new("The value of this tunable should be an integer equal to or less than $max");
    #         }
    #     } else {
    #         if ($mul) {
    #             $msg=Msg::new("The value of this tunable must be a multiple of $mul");
    #         }
    #     }
    #     if ($msg) {
    #         $tun_cmt.="\n\t$msg->{msg}";
    #     }
    # }

    $tun_cmt.="\n";
    $tun_cmt=~s/\n/\n# /g;
    return "# $tun_cmt\n";
}

sub tunables_template_content {
    my ($cfg,$tuns) = @_;
    my ($msg,$tf,$allsyssymbol,$edr);

    $edr=Obj::edr();
    $msg = Msg::new("Define tunables here such as:");
    $allsyssymbol = '"*"';
    $tuns = {} if (!$tuns);

    $tf ="#\n# Tunable Parameter Values:\n#\nour \%TUN;\n\n# " . $msg->{msg} . "\n#\n# \$TUN{\"tunable1\"}{\"system_name\"}=value1;\n# \$TUN{\"tunable2\"}{\"*\"}=value2;\n#\n# " ;
    $msg = Msg::new("Here $allsyssymbol means this tunable should be set on all systems");
    $tf .= $msg->{msg} . "\n\n".EDRu::hash2def($tuns, 'TUN')."\n1;\n\n";

    for my $tun (sort keys %{$edr->{all_tunables}}) {
        $tf .= tunable_comment($edr->{all_tunables}{$tun});
    }

    return $tf;
}

1;

