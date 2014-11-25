#! /usr/bin/perl -w
use lib './EDR';
use EDR;
use CGI qw/:standard/;
use JSON qw/encode_json decode_json/;

my $cgi= new CGI;
my $id = param("id");
my $system = param("ip");
my $path = param("path");
my $content;
my $currentID = 0;
my @arr;

sub readfile {
    my ($file,$lock) = @_; 
    my $sys = Sys->new($system);
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
 
print $cgi->header(-type => "application/json", -charset => "utf-8");
my $worksapce = "../workspace";

EDR::init_edr_objs();

my $sys = Sys->new($system);
EDR::init_sys_objs($system);
$sys = Sys->new($system);

for my $files (keys %{$sys->{tree}}) {
    if ($sys->{tree}{$files}{'id'} eq $id) {
        $content = $sys->readfile($files);
        last;
    }
}

#getfiles($system, $path,0);

print encode_json({'val'=>$content});



