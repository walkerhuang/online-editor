#! /usr/bin/perl -w
use strict;
use CGI qw/:standard/;
use JSON qw/encode_json decode_json/;

my $currentID = 0;
my @arr;
 
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

my $cgi= new CGI;
print $cgi->header(-type => "application/json", -charset => "utf-8");
my $worksapce = "../workspace";

getfiles("/opt/coding/html/workspace",0);

print encode_json({'val'=>\@arr});



