#!/usr/bin/perl
use lib './EDR';
use EDR;
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

my $cgi= new CGI;
my $hash;
print $cgi->header(-type => "application/json", -charset => "utf-8");
my $code = $cgi->param("code");
my $id = $cgi->param("id");
my $system = $cgi->param("system");

EDR::init_edr_objs();
my $sys = Sys->new($system);
EDR::init_sys_objs($system);
$sys = Sys->new($system);

for my $file (keys %{$sys->{tree}}) {
    if ($sys->{tree}{$file}{'id'} eq $id) {
        $sys->writefile($code, $file);
        my $basename = EDRu::basename($file);
        print encode_json({'success'=>1, 'file'=>$basename});
        exit;
    }
}

print encode_json({'success'=>0});



