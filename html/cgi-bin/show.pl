#! /usr/bin/perl -w
use CGI qw/:standard/;
use JSON qw/encode_json decode_json/;

my $cgi= new CGI;
my $id = param("id");
my $content;
my $currentID = 0;
my @arr;

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
 
sub getfiles {
    my ($dir,$parentID) = @_;
    my $subpath;
    my $handle;
   opendir($handle, $dir);
    while ($subpath = readdir($handle)) {
        if (!($subpath =~ m/^\.$/) and !($subpath =~ m/^(\.\.)$/)) {
            my $fullpath = "$dir/$subpath";
            my %hash;
            $currentID += 1;
            if ($currentID == $id) {
                $content = readfile($fullpath);
                return $content;

            }
            $hash{"id"} = $currentID;
            $hash{"pId"} = $parentID;
            $hash{"name"} = $subpath;
            if (!-d $fullpath) {
            } else {
                $hash{"isParent"} = "true";
                getfiles($fullpath,$currentID);
            }
            push(@arr,\%hash);
        }
    }
    return;
}

print $cgi->header(-type => "application/json", -charset => "utf-8");
my $worksapce = "../workspace";

getfiles("/opt/coding/html/workspace",0);

print encode_json({'val'=>$content});



