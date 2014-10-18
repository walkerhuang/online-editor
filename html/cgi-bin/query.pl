#!/usr/bin/perl
use CGI qw/:standard/;
use JSON qw/encode_json decode_json/;

sub cmd {
    my $cmd = shift;

    my $out = `$cmd 2>&1`;
    return $out;
}

sub readfile {
    my ($file,$lock) = @_; 
    my ($line,$msg,$rf,$fd);
    if(!open($fd, '<', $file)) {
        print("\nreadfile cannot open $file");
        return 0;
    }   
    if($lock){
        if(!flock($fd, LOCK_SH)){
            print("\ncannot lock $file");
            return 1;
        }
    }
    $rf ='';
    while ($line=<$fd>) { $rf.=$line; }
    close($fd);
    return $rf;
}

# write a string to a file
sub writefile {
    my($write,$file)= @_;
    open(WF, '>', $file);
    print WF $write;
    close(WF);
    return 1;
}

sub getfiles {
    my $parent = shift;

}

my $cgi= new CGI;
my $hash;
print $cgi->header(-type => "application/json", -charset => "utf-8");
my $worksapce = "../workspace";


print encode_json({'val'=>$output});


