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
package EDRu;

use strict;

sub basename {
    my $fullname=shift;
    return $fullname ? File::Basename::basename($fullname) : '';
}

sub clocktime {
    my ($ns,$round) = @_;
    my ($sec,$ctime,$min,$hr);
    $sec = $ns%60;
    if ($round && ($sec > $round)) {
        $sec = int($sec/$round) * $round;
    }
    $min = int($ns/60)%60;
    $hr = int($ns/3600);
    $ctime = ($hr) ? sprintf('%d:%02d:%02d',$hr,$min,$sec) :
        sprintf('%d:%02d',$min,$sec);
    return $ctime;
}

# compare versions
# returns 0 if versions are the same
# returns 1 if version $v1 is higher
# returns 2 if version $v2 is higher
# only checks $dim dimensions if $dim is defined
sub compvers {
    my ($v1,$v2,$dim) = @_;
    my ($f,$n1,$n,@a2,$n2,@a1,$rtn);
    @a1=split(m/[\.|-|\s]/,$v1);
    @a2=split(m/[\.|-|\s]/,$v2);
    $n = ($#a1>$#a2) ? $#a1 : $#a2;
    for my $f (0..$n) {
        return 0 if ((defined $dim) && ($dim==$f));
        $n1 = $v1 = $a1[$f];
        $n2 = $v2 = $a2[$f];
        $n1=~s/\D//mg if (defined $n1);
        $n2=~s/\D//mg if (defined $n2);
        $n1||=0;
        $n2||=0;
        return 1 if ($n1>$n2);
        return 2 if ($n2>$n1);
        # Assumes letters always trail numbers
        $v1=~s/\d//mg if (defined $v1);
        $v2=~s/\d//mg if (defined $v2);
        $v1||=0;
        $v2||=0;
        $rtn=($v1 cmp $v2);
        return 1 if ($rtn>0);
        return 2 if ($rtn<0);
    }
    return 0;
}

sub cpip_pool {
    return 1 if ($_[0]=~/^(Rel|Prod|Pkg|Proc|Patch)::/mx);
    return '';
}

sub datetime {
    my @lt=localtime;
    return sprintf('%d_%02d_%02d-%02d_%02d_%02d',
                $lt[5]+1900, $lt[4]+1, $lt[3], $lt[2], $lt[1], $lt[0]);
}

# remove spaces from begginning and end of line
sub despace {
    my $str=shift;
    # to replace all invisible characters including spaces(\x20), tabs(\x09),
    # control characters, null characters, and delete character (\x7F), etc.
    $str=~s/^[\x00-\x20\x7F]+//mx;
    $str=~s/[\x00-\x20\x7F]+$//mx;
    return $str;
}

sub dirname {
    my $fullname=shift;
    return $fullname ? File::Basename::dirname($fullname) : '.';
}

# return 1 if undef or ''
# return 0 if 0, '0', or other.
sub isempty {
    my $s=shift;
    return 1 if (! defined $s || $s eq '');
    return 0;
}

sub isint {
    my ($s) = @_;
    return 1 if ($s =~ /^-?\d+$/m);
    return 0;
}

sub isnum {
    my ($s) = @_;
    return 1 if ($s =~ /^-?\d+\.?\d*$/mx);
    return 0;
}

sub isverror {
    return 1 if ($_[0]=~/V-\d+-\d+\d+/mx);
    # other products can add what they need for pre 4.0 Error id's
    return 1 if ($_[0]=~/^VCS:\d\d\d/mx);
    return 0;
}

# verify an entered NIC is in lettersnumbers format
sub isnic {
    my ($nic) = @_;
    # e3465678, change the judgement condition of entered NIC format
    return 1 if ($nic=~/^\w+[\w\.:-]*$/mx);
    return 0;
}

sub isurl {
    my $url=shift;
    $url=~s/^\s*//;
    $url=~s/\s*$//;
    return 0 if ($url=~/\s/);
    return 0 if ($url!~/^http:\/\//);
    return 1;
}

sub nofqdn {
    my $sys=shift;
    chomp($sys);
    $sys=~s/\..*$//m unless (isip($sys));
    return $sys;
}

# Return true if string has non pure and non valid ASCII characters
sub nonascii {
    return ($_[0]=~/\P{IsASCII}/mx) ? 1 : 0;
}

# dont pass objects, hence no _sys, ppp=pkg/patch/proc
sub outputfile {
    my($task,$sys,$ppp)= @_;
    return sprintf '%s/%s.%s.%s', EDR::get('tmpdir'), $task, $ppp, $sys;
}

sub plat { return Padv::plat(@_); }

sub join_and {
    return if ($#_<0);
    return $_[0] if ($#_==0);
    # needs L10N for and
    return "$_[0] and $_[1]" if ($#_==1);
    my $last_item=pop;
    return join(', ', @_).", and $last_item";
}

# create a random string of A-Z,a-z chars
sub randomstr {
    my $n=shift;
    my ($c,$r,$uid);
    for my $x (1..$n) {
        $r=int(rand(52));
        $c = ($r<26) ? chr($r+65) : chr($r+71);
        $uid.=$c;
    }
    return $uid;
}

sub reverse_str { return join(' ', reverse(split(/\s+/m,$_[0]))); }

sub current_time {
    my @lt=localtime;
    return sprintf('%d:%02d:%02d', $lt[2], $lt[1], $lt[0]);
}

sub tidtime {
    my @lt=localtime;
    return sprintf('%d %02d:%02d:%02d', Obj::tid(), $lt[2], $lt[1], $lt[0]);
}

sub escape {
    my $str = shift;
    $str =~ s/\\/\\\\/g;
    $str =~ s/\n/\\n/g;
    $str =~ s/%/\\%/mg;
    $str =~ s/\$/\\\$/mg;
    $str =~ s/@/\\@/mg;
    $str =~ s/"/\\"/mg;
    return $str;
}

sub fixed_length_str {
    my ($str,$length,$align) = @_;
    my ($i,$len);
    $len = length($str);
    if ($len < $length) {
        for ($i=0; $i<$length-$len;$i++){
            if (uc($align) eq 'L'){
                $str .= ' ';
            } else {
                $str = ' '.$str;
            }
        }
    } else {
        for ($i=0; $i<$len-$length;$i++){
            if (uc($align) eq 'L') {
                chop $str;
            } else {
                $str = substr($str,1);
            }
        }
    }
    return $str;
}

# Check whether the string contains VRTS or SYMC keyword
sub vrts_symc { return ($_[0]=~/VRTS|SYMC/m) }

# reset mpvers by mprpvers
sub mp_sp_ru {
    my $mpvers = shift;
    if ($mpvers =~ /^.*(MP|SP|RU)\d+/mx) {
        $mpvers = $&;
    }
    return $mpvers;
}

sub hex2dec {
    my ($hex) = @_;
    return hex($hex);
}

sub dec2hex {
    my ($dec) = @_;
    my $hex = sprintf("%x",$dec);
    return $hex;
}

sub ipv6toarr {
    my ($ipv6) = @_;
    my (@temp,@arr,$srclen,$zerolen,$i,$j,$k);
    @temp = ();
    @arr = ();
    @temp = split(/\:/,$ipv6);
    $srclen = @temp;
    $zerolen = 9 - $srclen;
    $i = 0;
    $j = 0;
    for ($i = 0 ; $i < 8; $i++) {
        if ($temp[$j] ne ''){
            $arr[$i] = $temp[$j];
        } else {
            for ($k = 0; $k < $zerolen; $k++){
                $arr[$i] = 0;
                $i++;
            }
            $i--;
        }
        $j++;
    }
    return \@arr;
}

sub ipv6bit {
    my ($ipv6,$prefix)=@_;
    my (@ipv6arr,$field,$bit,$base);
    $field = ($prefix-1)/16;
    $bit = ($prefix-1)%16;
    $base = 1<<(15-$bit);
    @ipv6arr = @{EDRu::ipv6toarr($ipv6)};
    return (($ipv6arr[int($field)] & $base)>>(15-$bit));
}

sub mask2cidr {
    my ($netmask) = @_;
    my (@element,$output,%maskhash);
    $output = 0;
    @element = split (/\./,$netmask);
    %maskhash = ();
    $maskhash{"255"} = 8;
    $maskhash{"254"} = 7;
    $maskhash{"252"} = 6;
    $maskhash{"248"} = 5;
    $maskhash{"240"} = 4;
    $maskhash{"224"} = 3;
    $maskhash{"192"} = 2;
    $maskhash{"128"} = 1;
    $maskhash{"0"} = 0;
    for my $e (@element) {
        $output += $maskhash{$e} if(defined $maskhash{$e}) ;
    }
    return $output;
}

sub get_network {
    my ($ip,$netmask) = @_;
    my @iparr = split (/\./,$ip);
    my @netmaskarr = split (/\./,$netmask);
    my @result = ();
    for my $index (0..3) {
        my $res = int($iparr[$index]) & int($netmaskarr[$index]);
        push(@result,$res);
    }
    return join('.',@result);
}

1;
