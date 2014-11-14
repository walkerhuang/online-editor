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
use Encode;

sub get_encoding_from_locale {
    my $locale=shift;
    my ($language,$encoding,$locale_encoding_map);

    # Currently VRTSperl do not support Chinese GB18030 charset
    # To support GB18030, need include Encode::HanExtra from CPAN.
    # Temporarily, use 'gbk' encoding for zh_CN.GB18030 locale.

    # Directly hash frequently used locale names on Solaris
    $locale_encoding_map = {
        'zh'               => 'euc-cn',
        'zh_CN.EUC'        => 'euc-cn',
        'zh.GBK'           => 'gbk',
        'zh_CN.GBK'        => 'gbk',
        'zh_CN.GB18030'    => 'gbk',
        'ja'               => 'euc-jp',
        'ja_JP.eucJP'      => 'euc-jp',
        'ja_JP.PCK'        => 'shiftjis',
        'ko'               => 'euc-kr',
        'ko_KR.EUC'        => 'euc-kr',
        'zh_TW'            => 'euc-tw',
        'zh_TW.EUC'        => 'euc-tw',
    };

    # locale name could be 'zh_CN.UTF-8@radical', remove @.*
    $locale=~s/\@.*$//m;
    $encoding=$locale_encoding_map->{$locale};
    return $encoding if ($encoding);

    # For UTF-8 locales
    return 'utf8' if ($locale =~ /\butf-?8\b/mi);

    # Otherwise return the tailing encoding part.
    if ($locale =~ /^([^.]+)\.([^.]+)$/mx) {
        ( $language, $encoding ) = ( $1, $2 );

        if (lc($encoding)=~/euc/mx) {
            if ( $language =~ /^ja_JP|japan(?:ese)?$/mxi ) {
                $encoding = 'euc-jp';
            } elsif ( $language =~ /^ko_KR|korean?$/mxi ) {
                $encoding = 'euc-kr';
            } elsif ( $language =~ /^zh_CN|chin(?:a|ese)$/mxi ) {
                $encoding = 'euc-cn';
            } elsif ( $language =~ /^zh_TW|taiwan(?:ese)?$/mxi ) {
                $encoding = 'euc-tw';
            }
        }
    }

    return $encoding;
}

sub init_locale_encoding {
    my $edr=shift;
    my ($locale,$encoding,$encoding_obj);

    $locale=$edr->{envlang} || $ENV{LC_ALL} || $ENV{LANG} || 'C';
    $encoding=get_encoding_from_locale($locale);

    if ($encoding) {
        $encoding_obj=find_encoding($encoding);
        if ($encoding_obj) {
            $edr->{locale_encoding}=$encoding_obj;
            Msg::log("Local encoding: '$encoding', " . $encoding_obj->name());
        }
    }

    return 1;
}

sub decode_to_utf8 {
    my ($edr,$msg) = @_;
    my ($encoding,$utf8);

    return '' unless(defined $msg);

    $utf8=$msg;

    $encoding=$edr->{locale_encoding};
    if (defined $encoding) {
        $utf8=$encoding->decode($msg);

        # remove UTF-8 flag for the string since CPI always using raw bytes.
        $utf8=Encode::encode_utf8($utf8);
    }
    return $utf8;
}

sub encode_from_utf8 {
    my ($edr,$utf8) = @_;
    my ($msg,$encoding);

    return '' unless(defined $utf8);

    $msg=$utf8;

    $encoding=$edr->{locale_encoding};
    if (defined $encoding) {
        # Add UTF-8 flag for the string, otherwise encode() do not work well.
        $msg=Encode::decode_utf8($msg);

        $msg=$encoding->encode($msg);
    }
    return $msg;
}


# Returns 1 for Chinese/Japanese/Korean characters.  This means that
# these characters allow line wrapping after this character even
# without whitespaces because these languages don't use whitespaces
# between words.
#
# Character must be given in UCS-4 codepoint value.
sub utf8_isCJK {
    my $c=shift;
    my ($l,$u);

    $l=length($c);
    if ($l == 3) {
        # U+0800 - U+FFFF
        $u = (ord(substr($c,0,1))&0x0f) * 0x1000
            + (ord(substr($c,1,1))&0x3f) * 0x40
            + (ord(substr($c,2,1))&0x3f);
    } elsif ($l == 4) {
        # U+10000 - U+10FFFF
        $u = (ord(substr($c,0,1))&7) * 0x40000
            + (ord(substr($c,1,1))&0x3f) * 0x1000
            + (ord(substr($c,2,1))&0x3f) * 0x40
            + (ord(substr($c,3,1))&0x3f);
    } else {
        return 0;
    }

    # more informations about Unicode for CJK:
    #    http://blog.oasisfeng.com/2006/10/19/full-cjk-unicode-range/
    #    http://cpansearch.perl.org/src/KUBOTA/Text-WrapI18N-0.06/WrapI18N.pm
    #
    if ($u >= 0x2000 && $u <= 0x9fff) {
        # Hiragana, Katakana and Kanaji
        return 1;
    } elsif ($u >= 0xac00 && $u <= 0xd7ff) {
        # Hangul
        return 1;
    } elsif ($u >= 0xf900 && $u <= 0xffff) {
        # Hiragana, Katakana and Kanaji
        return 1;
    } elsif ($u >= 0x20000 && $u <= 0x2ffff) {
        # Han Ideogram
        return 1;
    }

    return 0;
}

# return value: (character, rest string, width, line breakable)
#   character: a character.  This may consist from multiple bytes.
#   rest string: given string without the extracted character.
#   width: number of columns which the character occupies on screen.
#   line breakable: true if the character allows line break after it.
sub utf8_extract {
    my $string=shift;
    my ($l,$c,$r,$w,$bv);
    my ($edr,$escape_seq,$escape_seq_quote);

    if (length($string) == 0) {
        return ('', '', 0, 0);
    }

    $c = $r = '';
    $w = 1;
    $bv = 0;

    $l = utf8_mblen($string);
    if ($l <= 0) {
        # Control characters
        $c = '?';
        $r = substr($string,1);
    } elsif ($l == 1) {
        # ASCII or Escape sequence characters
        $c = substr($string, 0, 1);
        $r = substr($string, 1);
        if ($c eq "\t") {
            # if tab character, set width as 8.
            $w = 8;
        } elsif ($c eq "\e") {
            # if escape sequences, set width as 0.
            $edr = $Obj::pool{EDR};
            if (defined $edr && defined $edr->{tput}) {
                for my $escape_type (qw(bs be ss se us ue)) {
                    $escape_seq = $edr->{tput}{$escape_type};
                    next unless ($escape_seq);

                    $escape_seq_quote = quotemeta($escape_seq);
                    if ($string =~ /^$escape_seq_quote/m) {
                        $l = length($escape_seq);
                        $c = $escape_seq;
                        $r = substr($string, $l);
                        $w = 0;
                        last;
                    }
                }
            }
        }
    } else {
        # if CJK characters, set character screen width as 2.
        $c = substr($string, 0, $l);
        $r = substr($string, $l);
        $bv = utf8_isCJK($c);
        $w = 2 if ($bv);
    }
    return ($c, $r, $w, $bv);
}

# $initial_tab to define the indentation of the first line
# $subsequent_tab to define the indentation for all subsequent lines
# $columns to define the screen width
sub utf8_wrap_text {
    my ($initial_tab,$subsequent_tab,$columns,$text) = @_;
    my ($bv,$word,$out,$w,$c,$len,$wlen,$separator);

    $separator="\n";

    $text = $initial_tab . $text;

    # $out     already-formatted text for output including current line
    # $len     visible width of the current line without the current word
    # $word    the current word which might be sent to the next line
    # $wlen    visible width of the current word
    # $c       the current character
    # $bv      whether to allow line-breaking after the current character
    # $w       visible width of the current character

    $out = '';
    $len = 0;
    $word = '';
    $wlen = 0;

    $text =~ s/\n+$/\n/;
    while (1) {
        if (length($text) == 0) {
            return $out . $word;
        }
        ($c, $text, $w, $bv) = utf8_extract($text);
        if ($c eq "\n") {
            $out .= $word . $separator;
            if (length($text) == 0) {return $out;}
            $len = 0;
            $text = $subsequent_tab . $text;
            $word = '' ; $wlen = 0;
            next;
        } elsif ($w == -1) {
            # all control characters other than LF are ignored
            next;
        }

        # when the current line have enough room for the current character
        if ($len + $wlen + $w <= $columns) {
            if ($c eq ' ' || $bv) {
                $out .= $word . $c;
                $len += $wlen + $w;
                $word = ''; $wlen = 0;
            } else {
                $word .= $c; $wlen += $w;
            }
            next;
        }

        # when the current line overflows with the current character
        if ($c eq ' ') {
            # the line ends by space
            $out .= $word . $separator;
            $len = 0;
            $text = $subsequent_tab . $text;
            $word = ''; $wlen = 0;
        } elsif ($wlen + $w <= $columns) {
            # the current word is sent to next line
            $out .= $separator;
            $len = 0;
            $text = $subsequent_tab . $word . $c . $text;
            $word = ''; $wlen = 0;
        } else {
            # the current word is too long to fit a line
            $out .= $word . $separator;
            $len = 0;
            $text = $subsequent_tab . $c . $text;
            $word = ''; $wlen = 0;
        }
    }
    return;
}

sub utf8_string_width {
    my $str=shift;
    my ($width,$c,$w,$bv);

    return 0 unless(defined $str);

    $width=0;
    while (1) {
        last if (length($str) == 0);
        ($c, $str, $w, $bv) = utf8_extract($str);
        $width+=$w;
    }
    return $width;
}

sub utf8_sprintf {
    my ($format,@args) = @_;
    my ($f,$ns,$n,$av,$ss,$arg,$str,$fs);

    $str='';
    while($format=~/^([^%]*)(%(-?)(\d*)([sdf]))(.*)$/mxg) {
        $str.=$1;
        $fs=$2;
        $av=$3;
        $n=$4;
        $f=$5;
        $format=$6;
        $arg=shift @args;
        if ($f eq 's') {
            $ns=$n-utf8_string_width("$arg");
            $ns=0 if ($ns<0);
            $ss=' ' x $ns;
            if ($av eq '-') {
                $str.="$arg$ss";
            } else {
                $str.="$ss$arg";
            }
        } else {
            $str.=sprintf("$fs", $arg);
        }
    }
    $str.=$format;
    return $str;
}

sub utf8_mblen {
    my $str=shift;
    my (@bytes,$byte,$num_bytes);

    @bytes = unpack 'C1', $str;
    $byte = shift @bytes;
    if ($byte < 0x80) {
        # ASCII
        $num_bytes = 1;
    } elsif ($byte < 0xc0 || $byte > 0xfd) {
        # invalid char
        $num_bytes = -1;
    } else {
        if ($byte < 0xe0) {
            $num_bytes = 2;
        } elsif ($byte < 0xf0) {
            $num_bytes = 3;
        } elsif ($byte < 0xf8) {
            $num_bytes = 4;
        } elsif ($byte < 0xfc) {
            $num_bytes = 5;
        } else {
            $num_bytes = 6;
        }
    }

    return $num_bytes;
}

1;
