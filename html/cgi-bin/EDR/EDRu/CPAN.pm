package EDRu;

# This module host those subroutines copied from CPAN
# Should not include Symantec Copyright.

use strict;

# Copy from Text::ParseWords::parse_line
# To split string with delimiter, but ignore the delimiter in quoted words.
# For example:  "abc,'def,ghi',jkl", split with comma,
# the result should be:  'abc', 'def,ghi', 'jkl'
sub split_str {
    my($delimiter, $keep, $str) = @_;
    my($word, @fields);

    @fields = ();
    if (length($str)) {
        if ($str !~ /["']/) {
            return split (/$delimiter/, $str);
        }
    } else {
        return @fields;
    }

    no warnings 'uninitialized';      # we will be testing undef strings

    while (length($str)) {
        # This pattern is optimised to be stack conservative on older perls.
        # Do not refactor without being careful and testing it on very long strings.
        # See Perl bug #42980 for an example of a stack busting input.
        $str =~ s{^
                    (?:
                        # double quoted string
                        (")                             # $quote
                        ((?>[^\\"]*(?:\\.[^\\"]*)*))"   # $quoted
                    |   # --OR--
                        # singe quoted string
                        (')                             # $quote
                        ((?>[^\\']*(?:\\.[^\\']*)*))'   # $quoted
                    |   # --OR--
                        # unquoted string
                        (                               # $unquoted
                            (?:\\.|[^\\"'])*?
                        )
                        # followed by
                        (                               # $delim
                            \Z(?!\n)                    # EOL
                        |   # --OR--
                            (?-x:$delimiter)            # delimiter
                        |   # --OR--
                            (?!^)(?=["'])               # a quote
                        )
                    )
                 }
                 {}xs or return;   # extended layout
        my ($quote, $quoted, $unquoted, $delim) = (($1 ? ($1,$2) : ($3,$4)), $5, $6);

        return() unless( defined($quote) || length($unquoted) || length($delim));

        if ($keep) {
            $quoted = "$quote$quoted$quote";
        }
        else {
            $unquoted =~ s/\\(.)/$1/sg;
            if (defined $quote) {
                $quoted =~ s/\\(.)/$1/sg if ($quote eq '"');
                $quoted =~ s/\\([\\'])/$1/g if ($quote eq "'");
            }
        }
        $word .= substr($str, 0, 0);    # leave results tainted
        $word .= defined $quote ? $quoted : $unquoted;

        if (length($delim)) {
            push(@fields, $word);
            push(@fields, $delim) if ($keep eq 'delimiters');
            undef $word;
        }
        if (!length($str)) {
            push(@fields, $word);
        }
    }
    return(@fields);
}


# Copy from Net::IP version 1.25 for NBU platforms
# that do not include this module in /usr/bin/perl
# commented all #$ERROR and $ERRNO statements

sub is_hostname_resolvable {
    my $hostname=shift;
    my ($rname,$err,@res,%hints);

    use Socket qw( SOCK_STREAM );

    # The core Socket module bundled in Perl 5.14 directly support IPv6
    # And no need to use Socket::GetAddrInfo
    if (defined $Socket::VERSION && $Socket::VERSION >= 1.93) {
        %hints = ( socktype => SOCK_STREAM );
        ( $err, @res ) = Socket::getaddrinfo( $hostname, '', \%hints );

        # return 0 if getaddrinfo() cannot resolve hostname
        return 0 if ($err);
    } else {
        eval { require Socket::GetAddrInfo };
        if ($@) {
            # getaddrinfo() support IPv6, while gethostbyname() only support IPv4.
            # if could not use getaddrinfo(), then use gethostbyname()
            ($rname, undef)=gethostbyname($hostname);

            # return 0 if gethostbyname() cannot resolve hostname
            return 0 if (!$rname);
        } else {
            import Socket::GetAddrInfo qw( :newapi getaddrinfo );

            %hints = ( socktype => SOCK_STREAM );
            ( $err, @res ) = getaddrinfo( $hostname, '', \%hints );

            # return 0 if getaddrinfo() cannot resolve hostname
            return 0 if ($err);
        }
    }
    return 1;
}

# A wrapper of sub ip_iptype() provided by Net::IP
# For it cannot work correctly when IPv6 compact address,
# and cannot figure out the SITE-LOCAL IPv6 address,
# the wrapper version is coded to enhance such kind requirement.
sub iptype_ipv6 {
    my $ip6 = shift;

    my $type = 'NOIPV6';
    return $type if (!ip_is_ipv6($ip6));
    my $ip6exp = ip_expand_address($ip6, 6);
    $ip6exp = ip_iptobin($ip6exp, 6);
    $type = ip_iptype($ip6exp, 6);
    # FECx: ~ FEFx:
    $type = 'SITE-LOCAL' if ($ip6exp =~ m/^1111111011/);
    $type = 'LINK-LOCAL' if ($ip6exp =~ m/^1111111010/);
    return $type;
}

# New implementation of isip, which can check both IPv4 and IPv6
# return 1 when $ip is a valid IPv4/6 address, return 0 if not.
sub isip {
    my ($ip) = @_;
    return 1 if ((ip_is_ipv4($ip)) || (ip_is_ipv6($ip)));
    return 0;
}

# Definition of the Ranges for IPv4 IPs
my %IPv4ranges = (
    '00000000'                 => 'PRIVATE',     # 0/8
    '00001010'                 => 'PRIVATE',     # 10/8
    '01111111'                 => 'PRIVATE',     # 127.0/8
    '101011000001'             => 'PRIVATE',     # 172.16/12
    '1100000010101000'         => 'PRIVATE',     # 192.168/16
    '1010100111111110'         => 'RESERVED',    # 169.254/16
    '110000000000000000000010' => 'RESERVED',    # 192.0.2/24
    '1110'                     => 'RESERVED',    # 224/4
    '11110'                    => 'RESERVED',    # 240/5
    '11111'                    => 'RESERVED',    # 248/5
);

# Definition of the Ranges for Ipv6 IPs
my %IPv6ranges = (
    '00000000'   => 'RESERVED',                  # ::/8
    '00000001'   => 'RESERVED',                  # 0100::/8
    '0000001'    => 'RESERVED',                  # 0200::/7
    '000001'     => 'RESERVED',                  # 0400::/6
    '00001'      => 'RESERVED',                  # 0800::/5
    '0001'       => 'RESERVED',                  # 1000::/4
    '001'        => 'GLOBAL-UNICAST',            # 2000::/3
    '010'        => 'RESERVED',                  # 4000::/3
    '011'        => 'RESERVED',                  # 6000::/3
    '100'        => 'RESERVED',                  # 8000::/3
    '101'        => 'RESERVED',                  # A000::/3
    '110'        => 'RESERVED',                  # C000::/3
    '1110'       => 'RESERVED',                  # E000::/4
    '11110'      => 'RESERVED',                  # F000::/5
    '111110'     => 'RESERVED',                  # F800::/6
    '1111101'    => 'RESERVED',                  # FA00::/7
    '1111110'    => 'UNIQUE-LOCAL-UNICAST',      # FC00::/7
    '111111100'  => 'RESERVED',                  # FE00::/9
    '1111111010' => 'LINK-LOCAL-UNICAST',        # FE80::/10
    '1111111011' => 'RESERVED',                  # FEC0::/10
    '11111111'   => 'MULTICAST',                 # FF00::/8
    '00100000000000010000110110111000' => 'RESERVED',    # 2001:DB8::/32

    '0' x 96 => 'IPV4COMP',                              # ::/96
    ('0' x 80) . ('1' x 16) => 'IPV4MAP',                # ::FFFF:0:0/96

    '0' x 128         => 'UNSPECIFIED',                  # ::/128
    ('0' x 127) . '1' => 'LOOPBACK',                     # ::1/128

);

#------------------------------------------------------------------------------
# Subroutine ip_iplengths
# Purpose           : Get the length in bits of an IP from its version
# Params            : IP version
# Returns           : Number of bits

sub ip_iplengths {
    my ($version) = @_;

    if ($version == 4) {
        return (32);
    }
    elsif ($version == 6) {
        return (128);
    }
    else {
        return;
    }
}

#------------------------------------------------------------------------------
# Subroutine ip_iptobin
# Purpose           : Transform an IP address into a bit string
# Params            : IP address, IP version
# Returns           : bit string on success, undef otherwise
sub ip_iptobin {
    my ($ip, $ipversion) = @_;

    # v4 -> return 32-bit array
    if ($ipversion == 4) {
        return unpack('B32', pack('C4C4C4C4', split(/\./m, $ip)));
    }

    # Strip ':'
    $ip =~ s/://mg;

    # Check size
    unless (length($ip) == 32) {
        #$ERROR = "Bad IP address $ip";
        #$ERRNO = 102;
        return;
    }

    # v6 -> return 128-bit array
    return unpack('B128', pack('H32', $ip));
}

#------------------------------------------------------------------------------
# Subroutine ip_bintoip
# Purpose           : Transform a bit string into an IP address
# Params            : bit string, IP version
# Returns           : IP address on success, undef otherwise
sub ip_bintoip {
    my ($binip, $ip_version) = @_;

    # Define normal size for address
    my $len = ip_iplengths($ip_version);

    if ($len < length($binip)) {
        #$ERROR = "Invalid IP length for binary IP $binip\n";
        #$ERRNO = 189;
        return;
    }

    # Prepend 0s if address is less than normal size
    $binip = '0' x ($len - length($binip)) . $binip;

    # IPv4
    if ($ip_version == 4) {
        return join '.', unpack('C4C4C4C4', pack('B32', $binip));
    }

    # IPv6
    return join(':', unpack('H4H4H4H4H4H4H4H4', pack('B128', $binip)));
}

#------------------------------------------------------------------------------
# Subroutine ip_is_ipv4
# Purpose           : Check if an IP address is version 4
# Params            : IP address
# Returns           : 1 (yes) or 0 (no)
sub ip_is_ipv4 {
    my $ip = shift;

    # Check for invalid chars
    unless ($ip =~ m/^[\d\.]+$/) {
        #$ERROR = "Invalid chars in IP $ip";
        #$ERRNO = 107;
        return 0;
    }

    if ($ip =~ m/^\./) {
        #$ERROR = "Invalid IP $ip - starts with a dot";
        #$ERRNO = 103;
        return 0;
    }

    if ($ip =~ m/\.$/) {
        #$ERROR = "Invalid IP $ip - ends with a dot";
        #$ERRNO = 104;
        return 0;
    }

    # Single Numbers are considered to be IPv4
    # For EDR, we consider IPv4 must have 4 quads
    #if ($ip =~ m/^(\d+)$/ and $1 < 256) { return 1 }

    # Count quads
    my $n = ($ip =~ tr/\./\./);

    # IPv4 must have from 1 to 4 quads
    # For EDR, we consider IPv4 must have 4 quads
    #unless ($n >= 0 and $n < 4) {
    if ($n != 3) {
        #$ERROR = "Invalid IP address $ip";
        #$ERRNO = 105;
        return 0;
    }

    # Check for empty quads
    if ($ip =~ m/\.\./) {
        #$ERROR = "Empty quad in IP address $ip";
        #$ERRNO = 106;
        return 0;
    }

    foreach my $quad (split /\./m, $ip) {

        # Check for invalid quads
        if ($quad < 0 || $quad >= 256) {
            #$ERROR = "Invalid quad in IP address $ip - $quad";
            #$ERRNO = 107;
            return 0;
        }
    }
    return 1;
}

#------------------------------------------------------------------------------
# Subroutine ip_is_ipv6
# Purpose           : Check if an IP address is version 6
# Params            : IP address
# Returns           : 1 (yes) or 0 (no)
sub ip_is_ipv6 {
    my $ip = shift;

    # Count octets
    my $n = ($ip =~ tr/:/:/);
    return (0) if ($n <= 0 || $n >= 8);

    # $k is a counter
    my $k;

    foreach (split /:/m, $ip) {
        $k++;

        # Empty octet ?
        next if ($_ eq '');

        # Normal v6 octet ?
        next if (/^[a-f\d]{1,4}$/i);

        # Last octet - is it IPv4 ?
        if ($k == $n + 1) {
            next if (ip_is_ipv4($_));
        }

        #$ERROR = "Invalid IP address $ip";
        #$ERRNO = 108;
        return 0;
    }

    # Does the IP address start with : ?
    if ($ip =~ m/^:[^:]/) {
        #$ERROR = "Invalid address $ip (starts with :)";
        #$ERRNO = 109;
        return 0;
    }

    # Does the IP address finish with : ?
    if ($ip =~ m/[^:]:$/) {
        #$ERROR = "Invalid address $ip (ends with :)";
        #$ERRNO = 110;
        return 0;
    }

    # Does the IP address have more than one '::' pattern ?
    if ($ip =~ s/:(?=:)//mg > 1) {
        #$ERROR = "Invalid address $ip (More than one :: pattern)";
        #$ERRNO = 111;
        return 0;
    }

    return 1;
}

sub is_ip_valid {
    my ($ip, $is_mask) = @_;
    my ($is_ipv4, $ipv4_addr, $ipv6_addr, @octets, $ocnt);
    my (@ip_parts, $ip_uniq, $cnt, $bcnt, $tcnt);

    $is_ipv4 = ip_is_ipv4($ip);
    if ($is_ipv4) {
        @octets = split(/\./m, $ip);
        $ocnt = @octets;
        if ($ocnt == 4) {
            if ($is_mask) {
                return 0 if ($ip =~ /^0[0-9]*\.|\.0[0-9]+/m) ;
            }else{
                return 0 if ($ip =~ /^(255|0+)\.|\.0[0-9]+/m) ;
            }
            return 1;
        } else {
            return 0;
        }
    }

    if ($ip !~ /:/m) {
         return 0;
    }

    if ($ip =~ /\//m) {
        if (!($ip =~ /^.+\/\d+$/m)) {
            return 0;
        }

        @ip_parts = split(/\//m, $ip);
        $cnt = @ip_parts;
        if ($cnt > 2) {
            return 0;
        }

        $ip_uniq = $ip_parts[0];

        $bcnt = $ip_parts[1] + 0;
        if (!($bcnt <= 128)) {
            return 0;
        }

    } else {
        $ip_uniq = $ip;
    }

    if (!ip_is_ipv6($ip_uniq)) {
        return 0;
    }

    if ($ip_uniq =~ /\./m) {
        @ip_parts = split(/\:/m, $ip_uniq);
        $cnt = @ip_parts;
        $cnt--;
        $ipv4_addr = $ip_parts[$cnt];
        @octets = split(/\./m, $ipv4_addr);
        $ocnt = @octets;
        if ($ocnt != 4) {
            return 0;
        }

        $ipv6_addr = '';
        my $i =0;
        while ($i < $cnt) {
            $ipv6_addr = $ipv6_addr."$ip_parts[$i]:";
            $i++;
        }

        $tcnt = 6;
    } else {
        $ipv6_addr = $ip_uniq;
        $tcnt = 8;
    }

    if (!($ipv6_addr =~ /::/m)) {
        @ip_parts = split(/:/m, $ipv6_addr);
        $cnt = @ip_parts;
        if ($cnt == $tcnt) {
            return 1;
        } else {
            return 0;
        }
    }

    return 1;
}

#------------------------------------------------------------------------------
# Subroutine ip_expand_address
# Purpose           : Expand an address from compact notation
# Params            : IP address, IP version
# Returns           : expanded IP address or undef on failure
sub ip_expand_address {
    my ($ip, $ip_version) = @_;

    unless ($ip_version) {
        #$ERROR = "Cannot determine IP version for $ip";
        #$ERRNO = 101;
        return;
    }

    # v4 : add .0 for missing quads
    if ($ip_version == 4) {
        my @quads = split /\./m, $ip;

        my @clean_quads = (0, 0, 0, 0);

        foreach my $q (reverse @quads) {
            unshift(@clean_quads, $q + 1 - 1);
        }

        return (join '.', @clean_quads[ 0 .. 3 ]);
    }

    # Keep track of ::
    $ip =~ s/::/:!:/m;

    # IP as an array
    my @ip = split /:/m, $ip;

    # Number of octets
    my $num = scalar(@ip);

    foreach my $i (0 .. (scalar(@ip) - 1)) {

        # Embedded IPv4
        if ($ip[$i] =~ /\./m) {

            # Expand Ipv4 address
            # Convert into binary
            # Convert into hex
            # Keep the last two octets

            $ip[$i] =
              substr(
                ip_bintoip(ip_iptobin(ip_expand_address($ip[$i], 4), 4), 6),
                -9);

            # Has an error occured here ?
            return unless (defined($ip[$i]));

            # $num++ because we now have one more octet:
            # IPv4 address becomes two octets
            $num++;
            next;
        }

        # Add missing trailing 0s
        $ip[$i] = ('0' x (4 - length($ip[$i]))) . $ip[$i];
    }

    # Now deal with '::' ('000!')
    foreach my $i(0 .. (scalar(@ip) - 1)) {

        # Find the pattern
        next unless ($ip[$i] eq '000!');

        # @empty is the IP address 0
        my @empty = map {'0' x 4 } (0 .. 7);

        # Replace :: with $num '0000' octets
        $ip[$i] = join ':', @empty[ 0 .. 8 - $num ];
        last;
    }

    return (lc(join ':', @ip));
}

#------------------------------------------------------------------------------
# Subroutine ip_iptype
# Purpose           : Return the type of an IP (Public, Private, Reserved)
# Params            : IP to test, IP version
# Returns           : type or undef (invalid)
sub ip_iptype {
    my ($ip, $ip_version) = @_;

    # Find IP version

    if ($ip_version == 4) {
        for my $var(sort { length($b) <=> length($a) } keys %IPv4ranges) {
            return ($IPv4ranges{$var}) if ($ip =~ m/^$var/);
        }

        # IP is public
        return 'PUBLIC';
    }

    for my $var(sort { length($b) <=> length($a) } keys %IPv6ranges) {
        return ($IPv6ranges{$var}) if ($ip =~ m/^$var/);
    }

    #$ERROR = "Cannot determine type for $ip";
    #$ERRNO = 180;
    return;
}

sub netmask_base {
    my ($base, $bits, $ibase, $imask);
    ($base, $bits) = (@_);
    $ibase = quad2int($base || 0);
    $imask = imask($bits);
    $ibase &= $imask
        if (defined $ibase && defined $bits);

    return int2quad($ibase);
}

sub quad2int {
    my @bytes = split(/\./,$_[0]);
    return unless @bytes == 4 && ! grep {!(/\d+$/ && $_<256)} @bytes;
    return unpack("N",pack("C4",@bytes));
}

sub int2quad {
    return join('.',unpack('C4', pack("N", $_[0])));
}

sub imask {
    return (2**32 -(2** (32- $_[0])));
}

1;
