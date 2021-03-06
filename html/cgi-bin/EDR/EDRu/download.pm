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

# Preload the HTTP and URI modules to prevent errors happen when uninstall
# and try to upload uninstall logs while at that time VRTSperl was uninstalled.

# For 2696627, Preload IO::Select for HPUX
use IO::Select;
use IO::Socket;
use Socket;

sub lwp_codes_to_retry {
   my $codes=shift;

   # default HTTP status codes which require retrying
   my @codes_to_retry = (
      '408', # Request Timeout
      '500', # Internal Server Error
      '502', # Bad Gateway
      '503', # Service Unavailable
      '504', # Gateway Timeout
   );

   $codes=~s/\s+//g if (defined $codes);
   if ($codes && $codes=~/^\d+(,\d+)*$/) {
       @codes_to_retry = split(/,/, $codes);
   }
   return @codes_to_retry;
}

sub lwp_retry_timings {
   my $timings=shift;

   # default pause seconds when LWP get server timeout errors.
   my @retry_timings = ();

   $timings=~s/\s+//g if (defined $timings);
   if ($timings && $timings=~/^\d+(,\d+)*$/) {
       @retry_timings = split(/,/, $timings);
   }
   return (@retry_timings, undef);
}

# check if port of addr is available or not. (only TCP)
sub is_port_connectable {
    my ($addr,$port,$timeout,$check_proxy) = @_;
    my (@classes,$ipv6,$sock,$proxy);

    $timeout ||= 5;
    require IO::Socket::INET;
    $ipv6=1;
    eval { require IO::Socket::INET6 };
    $ipv6=0 if ($@);

    @classes=();
    if (EDRu::ip_is_ipv6($addr)) {
        push @classes, 'IO::Socket::INET6' if ($ipv6);
    } else {
        push @classes, 'IO::Socket::INET';
        push @classes, 'IO::Socket::INET6' if ($ipv6);
    }

    for my $class (@classes) {
        if ($sock = $class->new(
            PeerAddr => $addr,
            PeerPort => $port,
            Timeout  => $timeout,
            Proto    => 'tcp'))
        {
            close $sock;
            return 1;
        }
    }

    if ($check_proxy) {
        # if proxy environment, regard the address is connectable.
        $proxy=get_proxy();
        return 1 if ($proxy);
    }

    return 0;
}

# $retry_timing could be like '5,10,20'
sub download_page {
    my ($url, $retry_timings) = @_;
    require File::Temp;
    my ($fh, $filename) = File::Temp::tempfile();

    my $ret = download_file($url, $filename, 0, $retry_timings);
    if (!$ret) {
        # Error occurred
        unlink($filename);
        return '';
    }

    my $content = readfile($filename);
    unlink($filename);
    return $content;
}

# Return:
#   0:          FAIL and save the errors in $edr->{download_errors}
#   1:          SUCCESS
sub download_file {
    my ($url,$file,$show_progress,$retry_timings) = @_;
    my ($edr,$ua,$total_size,$total_size_mb,$completed,$resp,$title,$pct,$tm,$uri,$host,$port,$fd);
    my ($code,$status_line,@pauses,@codes_to_retry);

    return 0 unless ($url && $file);

    $edr=Obj::edr();

    # attempt to connect to web server in 5 seconds
    require URI;
    $uri = URI->new($url);
    $host = $uri->host();
    $port = $uri->port();
    if(!is_port_connectable($host,$port,0,1)) {
        $edr->{download_errors} = "Error, cannot connect to $host:$port.";
        return 0;
    }

    # According to Symantec security policy, need configure client to
    # use the TLS_RSA_WITH_AES_256_CBC_SHA(same name as AES256-SHA) cipher suite to
    # communicate with Symantec servers.
    $ENV{'CRYPT_SSLEAY_CIPHER'} = 'AES256-SHA';
    require LWP::UserAgent;
    $ua = LWP::UserAgent->new(
        agent => 'EDR utilities/1.2 ',
        keep_alive => 0,
        env_proxy  => 1,
        ssl_opts => {
            verify_hostname => 0,
            SSL_verify_mode => 0x00,
        },
    );
    $ua->timeout(20);

    # Get the total size of download file
    $completed = 0;
    $total_size = 0;

    @pauses = lwp_retry_timings($retry_timings);
    @codes_to_retry = lwp_codes_to_retry();

    for my $pause (@pauses) {
        $resp = $ua->head($url);
#        if ($resp->is_success) {
            $total_size = $resp->headers->content_length || 0;
            $total_size_mb = $total_size / (1024 * 1024);
            $total_size_mb = sprintf "%0.2f",$total_size_mb;
#        } else {
#            $code=$resp->code;
#            $status_line=$resp->status_line;
#            $edr->{download_errors} = $status_line;
#            if (EDRu::inarr($code, @codes_to_retry)) {
#                if ($pause) {
#                    Msg::log("Failed to get head for URL '$url': $status_line\nsleep $pause and retry");
#                    sleep $pause;
#                }
#                next;
#            } else {
#                return 0;
#            }
#        }

        local $| = 1; # Autoflush
        require HTTP::Request::Common;
        $resp = $ua->request(HTTP::Request->new(GET => "$url"),
            sub {
                unless ($fd && fileno($fd)) {
                    if(! open $fd, '>', $file) {
                        $edr->{download_errors} = "Error, can not open $file: $!";
                        return 0;
                    }
                }
                if ($file =~ /\.t[bg]z$/m || $file =~ /\.tar(\.(Z|gz|bz2?))?$/mx) {
                    binmode $fd;
                }
                print $fd $_[0];
                if ($show_progress && $total_size > 0) {
                    $completed += length($_[0]);
                    $pct=int(100*$completed/$total_size);
                    if ($total_size_mb > 0) {
                        $title=Msg::new("Downloading $completed bytes (Total $total_size bytes [$total_size_mb MB])");
                    } else {
                        $title=Msg::new("Downloading $completed bytes (Total $total_size bytes)");
                    }
                    $title->progress_bar($pct);
                }
            }
        );

        print "\n" if ($show_progress && $total_size > 0);

        if ($fd && fileno($fd)) {
            close $fd;

            if ($tm = $resp->last_modified) {
                utime time(), $tm, $file;
            }

            if ($resp->header('X-Died') || !$resp->is_success) {
                unlink($file);

                $code=$resp->code;
                $status_line=$resp->status_line;
                $edr->{download_errors} = $status_line;
                if (EDRu::inarr($code, @codes_to_retry)) {
                    if ($pause) {
                        Msg::log("Failed to download URL '$url': $status_line\nsleep $pause and retry");
                        sleep $pause;
                    }
                    next;
                } else {
                    return 0;
                }
            } else {
                return 1;
            }
        }
    }
    return 0;
}

sub download_file1 {
    my ($url,$file,$attribute)=@_;
    my ($edr,$ua,$uri,$host,$port,$fh,$bytes,$response,$status);

    $edr=Obj::edr();

    # attempt to connect to web server in 5 seconds
    require URI;
    $uri = URI->new($url);
    $host = $uri->host();
    $port = $uri->port();
    if(!is_port_connectable($host,$port,0,1)) {
        $edr->{download_errors} = "Error, cannot connect to $host:$port.";
        return 0;
    }

    # According to Symantec security policy, need configure client to
    # use the TLS_RSA_WITH_AES_256_CBC_SHA(same name as AES256-SHA) cipher suite to
    # communicate with Symantec servers.
    $ENV{'CRYPT_SSLEAY_CIPHER'} = 'AES256-SHA';

    require LWP::UserAgent;
    $ua = LWP::UserAgent->new(
        agent => 'EDR utilities/1.2 ',
        keep_alive => 0,
        env_proxy  => 1,
        ssl_opts => {
            verify_hostname => 0,
            SSL_verify_mode => 0x00,
        },
    );
    $ua->timeout(20);

    if ($attribute->{'resume'}) {
        $bytes = -s $file;
        open  $fh, '>>:raw', $file or die $!;
    } else {
        $bytes  = 0 ;
        open  $fh, '>:raw', $file or die $!;
    }

    if ($bytes) {
        $response = $ua->get(
            $url,
            'Range'       => "bytes=$bytes-",
            ':content_cb' => sub { my ($chunk) = @_; print $fh $chunk; }
        );
    } else {
        $response = $ua->get( $url,
            ':content_cb' => sub { my ($chunk) = @_; print $fh $chunk; } );
    }
    close $fh;

    $status = $response->status_line;
    unless ( $status =~ /^(200|206|416)/ ) {
        $edr->{download_errors} = "Error, Download $uri error. Status:$status";
        return 0;
    }
    return 1;
}

sub cksum {
    my ($file)=@_;
    return unless ($file && -f $file);
    return EDR::cmd_local("_cmd_cksum $file 2>/dev/null | _cmd_awk '{print \$1}'");
}

sub get_proxy {
    my $proxy= $ENV{http_proxy}  || $ENV{HTTP_PROXY} ||
               $ENV{https_proxy} || $ENV{HTTPS_PROXY} ||
               $ENV{ftp_proxy}   || $ENV{FTP_PROXY};
    return $proxy;
}

# Return:
#   0:          FAIL and save the errors in $edr->{upload_errors}
#   1:          SUCCESS
sub upload_file {
    my ($url,$file,$filetype,$retry_timings) = @_;
    my ($edr,$text,$line,$ua,$resp,$fd);
    my ($code,$status_line,@pauses,@codes_to_retry);

    return 0 unless ($url && $file);

    $edr=Obj::edr();
    $filetype||='text/xml';
    $text='';
    if (!open($fd, '<', $file)) {
        $edr->{upload_errors} = "Couldn't open $file";
        return 0;
    }
    binmode($fd) if ($filetype=~/(tar|gzip)/);
    while (read($fd, $line, 1024)) {
        $text .= $line;
    }
    close($fd);

    # According to Symantec security policy, need configure client to
    # use the TLS_RSA_WITH_AES_256_CBC_SHA(same name as AES256-SHA) cipher suite to
    # communicate with Symantec servers.
    $ENV{'CRYPT_SSLEAY_CIPHER'} = 'AES256-SHA';
    require LWP::UserAgent;

    $ua = LWP::UserAgent->new(
        keep_alive => 0,
        env_proxy  => 1,
        ssl_opts => {
            verify_hostname => 0,
            SSL_verify_mode => 0x00,
        },
    );
    $ua->timeout(300);

    @pauses = lwp_retry_timings($retry_timings);
    @codes_to_retry = lwp_codes_to_retry();

    for my $pause (@pauses) {
        $resp = $ua->post($url,
                          Content_Type => 'multipart/form-data',
                          Content => [ userfile => [ undef,
                                                     $file,
                                                     'Content_Type' => $filetype,
                                                     Content => $text ] ]
                          );

        if ($resp->is_success) {
            #$edr->{upload_response}=$resp->content;
            return 1;
        } else {
            $edr->{upload_errors} = $resp->content;

            $code=$resp->code;
            if (EDRu::inarr($code, @codes_to_retry)) {
                if ($pause) {
                    $status_line=$resp->status_line;
                    Msg::log("Failed to upload file to URL '$url': $status_line\nsleep $pause and retry");
                    sleep $pause;
                }
                next;
            } else {
                return 0;
            }
        }
    }
    return 0;
}


# Upload a file to ftp server
# Return:
#   0:          FAIL and save the errors in $edr->{upload_errors}
#   1:          SUCCESS
sub upload_file_by_ftp {
    my ($url,$file,$show_progress) = @_;
    my ($edr,$host,$path,$ftp,$completed,$total_size,$total_size_mb,$conn,$buf,$read_bytes,$pct,$title,$fd);

    return 0 unless ($url && $file);

    $edr=Obj::edr();

    $host = $url;
    $path = '';
    $url =~ s/ftp:\/\///m;
    if ($url =~ /(.*?)\/(.*)/mx) {
        $host = $1;
        $path = "/$2";
    }
    require Net::FTP;
    $ftp = Net::FTP->new($host);
    $ftp->binary;
    if (!$ftp) {
        $edr->{upload_errors} = "Can't connect: $@";
        return 0;
    }
    if (!$ftp->login('anonymous', '')) {
        $edr->{upload_errors} = "Couldn't login";
        return 0;
    }
    if (!$ftp->cwd($path)) {
        $edr->{upload_errors} = "Couldn't change directory";
        return 0;
    }
    $conn = $ftp->stor($file);
    if (!$conn) {
        $edr->{upload_errors} = "Couldn't upload $file";
        return 0;
    }
    $completed = 0;
    $total_size = -s $file;
    $total_size_mb = $total_size / (1024 * 1024);
    $total_size_mb = sprintf "%0.2f",$total_size_mb;
    if (!open($fd, '<', $file)) {
        $edr->{upload_errors} = "Couldn't open $file";
        return 0;
    }
    while(($read_bytes = read($fd, $buf, 1024)) > 0) {
        $conn->write($buf, $read_bytes);
        $completed += $read_bytes;
        if ($show_progress && $total_size > 0) {
            $pct=int(100*$completed/$total_size);
            if ($total_size_mb > 0) {
                $title=Msg::new("Finished $completed bytes (Total $total_size bytes [$total_size_mb MB])");
            } else {
                $title=Msg::new("Finished $completed bytes (Total $total_size bytes)");
            }
            $title->progress_bar($pct);
        }
    }
    close $fd;
    print "\n" if ($show_progress && $total_size > 0);
    $conn->close();
    return 1;
}

sub extract_upload_errors {
    my $resp=shift;

    for my $line (split(/\n/,$resp)) {
        if ($line=~/^<p>(The requested URL.*)<\/p>/m) {
            return $1;
        }
    }
    return $resp;
}

1;
