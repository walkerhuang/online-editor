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

# check whether a string is a member of an array.
# Return the member number, or -1 if it is not
sub arrpos {
    my ($match,@arr) = @_;
    #@arr=split(/\s+/,$arr[0]) if (!$#arr);
    for my $n (0..$#arr) {
        return "$n" if ($arr[$n] eq $match);
    }
    return '-1';
}

# check whether a regular expression is found within a member of an array.
# Return the member number, or -1 if it is not
sub arrpos_re {
    my ($match,@arr) = @_;
    @arr=split(/\s+/m,$arr[0]) if (!$#arr);
    for my $n (0..$#arr) {
        return "$n" if ($match =~ /$arr[$n]/m);
    }
    return '-1';
}

# as arrpos, but supporting * as a wildcard in @arr
# Return the member number, or -1 if it is not
sub arrpos_wc {
    my ($match,@arr) = @_;
    @arr=split(/\s+/m,$arr[0]) if (!$#arr);
    for my $n (0..$#arr) {
        if  ($arr[$n] =~ "\\*")  {
            return $n if $match =~ m/$arr[$n]/;
        } else {
            return "$n" if ($arr[$n] eq $match);
        }
    }
    return '-1';
}

# filter all duplicate entries from a list
sub arruniq {
    my (@vars) = @_;
    my @a=();
    for my $v (@vars) {
        push(@a,$v) if(! inarr($v,@a));
    }
    return \@a;
}

# return 1 if strings in an array are unique, else return 0
sub arr_isuniq {
    my @av=@_;
    my %seen=();
    for my $item (@av) {
        return 0 if ($seen{$item}++);
    }
    return 1;
}

# remove entries from a list
sub arrdel {
    my ($arr,@ar)=@_;
    my @a=();
    for my $v (@{$arr}) { push(@a,$v) unless (inarr($v, @ar)); }
    return \@a;
}

# duplicate an array to properly load the reference into a list
sub duparr {
    my @a=@_;
    return \@a;
}

# duplicate a hash to properly load the reference into a list
sub duphash {
    my $rh=shift;
    my %h=%$rh;
    return \%h;
}

# recursive function used by create_requestfile
sub hash2def {
    my ($hashref,$var) = @_;
    my ($q,$hash,$kq,$ref);
    $hash='';
    for my $key (sort keys(%$hashref)) {
        $ref=ref($$hashref{$key});
        next if (($key=~/^(class|pool|tput)$/mx) || ($ref eq 'EDR'));
        $kq = ($key=~/\W|^\d/m) ? '"' : '';
        if (!$ref) {
            next if ($$hashref{$key} eq '');
            $q = (isint($$hashref{$key}) && $$hashref{$key}!~/^0/ ) ? '' : '"';
            $$hashref{$key}=~s/@/\\@/mg;
            $hash.="\$$var\{$kq$key$kq}=$q$$hashref{$key}$q;\n";
        } elsif ($ref eq 'ARRAY') {
            # Don't print empty array (etrack 3120744)
            next if ($#{$$hashref{$key}}<0);
            $hash.="\$$var\{$kq$key$kq}=[ qw(@{$$hashref{$key}}) ];\n";
        } elsif ($ref eq 'CODE') {
            # DO NOT dereference a coderef, EVER
            $hash.="\$$var\{$kq$key$kq}=&$ref;\n";
        } elsif ($ref eq 'GLOB') {
            $hash.="\$$var\{$kq$key$kq}=*$ref;\n";
        } elsif ($ref eq 'HASH') {
            $hash.=hash2def($$hashref{$key},"$var\{$kq$key$kq}");
        } elsif ($ref eq 'LVALUE') {
            $hash.="\$$var\{$kq$key$kq}=LVALUE($ref);\n";
        } elsif ($ref eq 'REF') {
            $hash.="\$$var\{$kq$key$kq}=\\{" . hash2def(${$$hashref{$key}}, '') . "};\n";
        } elsif ($ref eq 'SCALAR') {
            $q = (isint($$hashref{$key}) && $$hashref{$key}!~/^0/ ) ? '' : '"';
            $$hashref{$key}=~s/@/\\@/mg;
            $hash.="\$$var\{$kq$key$kq}=\\$q${$$hashref{$key}}$q;\n";
        } else {
            $hash.="# \$$var\{$kq$key$kq}: $ref is not a supported reference\n";
        }
    }
    return "$hash";
}

# return 1 if all elements of a hash array are the same
sub hashvaleq {
    my ($rh) = @_;
    my ($i,$v);
    for my $k (keys(%$rh)) {
        return '' if (($i) && ($v ne $$rh{$k}));
        $v=$$rh{$k};
        $i=1;
    }
    return 1;
}

# returns 0 false if a string is not in the subseqent list, $arrpos=-1
sub inarr {
    my $arrpos=arrpos(@_);
    return 1 if ($arrpos>=0);
    return 0;
}

# returns 1 true if a regular expression is found the subseqent list
# returns 0 false if a regular expression is found in the subseqent list
sub inarr_re {
    my $arrpos=arrpos_re(@_);
    return 1 if ($arrpos>=0);
    return 0;
}

# returns 1 true if a string is in the subseqent list, $arrpos>=0
# returns 0 false if a string is not in the subseqent list, $arrpos=-1
sub inarr_wc {
    my $arrpos=arrpos_wc(@_);
    return 1 if ($arrpos>=0);
    return 0;
}

sub var2def {
    my ($var, $varname, $vars, $including, $excluding) = @_;
    my ($oneline, $ret, $ref, $v, $r, $i, @keys);
    $ret = '';
    if ($including && $varname !~ $including) {
        return '';
    }
    if ($excluding && $varname =~ $excluding) {
        return '';
    }
    $ref = ref($var);
    if (!$ref) {    #$var is a scalar variable
        $v = $var;
        if (!defined $v) {
            $ret = "$varname = undef;\n";
        } elsif ($v eq '') {
            $ret = "$varname = '';\n";
        } else {
            $v   = escape($v);
            $ret = "$varname = \"$v\";\n";
        }
    } else {
        if (UNIVERSAL::isa($var, 'SCALAR')) {
            $v = $$var;
            if (!defined $v) {
                $ret = "$varname = undef;\n";
            } elsif ($v eq '') {
                $ret = "$varname = '';\n";
            } else {
                $v   = escape($v);
                $ret = "$varname = \"$v\";\n";
            }
        } elsif (defined $vars->{$var}) {
            #refer to the same object, comment it out.
            $ret = "#$varname = $vars->{$var};\n";
        } elsif (UNIVERSAL::isa($var, 'ARRAY')) {
            $oneline = 1;
            for my $v (@$var) {
                $r = ref($v);
                if ($r && $r !~ /SCALAR/i) {
                    $oneline = 0;
                    last;
                }
            }
            if ($oneline == 0) {
                for ($i = 0 ; $i < $#{$var} + 1 ; $i++) {
                    $vars->{$var} = "$varname";
                    $ret .= var2def($var->[$i], "$varname" . "[$i]", $vars, $including, $excluding);
                }
            } else {    #iterm of @$var are all scalar or ref of scalar, user one line.
                $ret .= "$varname = [";
                for ($i = 0 ; $i < $#{$var} + 1 ; $i++) {
                    $v = $var->[$i];
                    $r = ref($v);
                    if ($r) {    #$v is a ref of scalar
                        $v = $$v;
                        if (!defined $v) {
                            $ret .= 'undef';
                        } elsif ($v eq '') {
                            $ret .= "''";
                        } else {
                            $v = escape($v);
                            $ret .= "\"$v\"";
                        }
                    } else {     #$v is a scalar
                        if (!defined $v) {
                            $ret .= "undef";
                        } elsif ($v eq '') {
                            $ret .= "''";
                        } else {
                            $v = escape($v);
                            $ret .= "\"$v\"";
                        }
                    }
                    $ret .= ',' if ($i < $#{$var});
                }
                $ret .= "];\n";
            }
        } elsif (UNIVERSAL::isa($var, 'HASH')) {
            @keys = keys %$var;
            if ($#keys < 0) {
                $ret .= "$varname = {};\n";
            } else {
                @keys = sort @keys;
                for my $key (sort keys(%$var)) {
                    $vars->{$var} = "$varname";
                    if ($key =~ /\W|^\d/) {
                        $ret .= var2def($var->{$key}, "$varname" . "{\"$key\"}", $vars, $including, $excluding);
                    } else {
                        $ret .= var2def($var->{$key}, "$varname" . "{$key}", $vars, $including, $excluding);
                    }
                }
            }
        }
    }
    return $ret;
}

1;
