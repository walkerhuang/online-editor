#!/opt/VRTSperl/bin/perl

use strict;

sub cmd {
    my ($cmd,$rtn);
    $cmd=shift;
    print "$cmd\n";
    $rtn=`$cmd`;
    chomp($rtn);
    return $rtn;
}

my $isis="/net/isis_server/space/nightly_mh";
my $vers="GA_2.0.85.0";

my %padv = (
   'aix' => 'AIX_m32',
   'hpux' => 'HP-PA_m32',
   'linux' => 'Linux_AS4_m32',
   'sol_sparc' => 'Solaris8_m32',
   'sol_x64' => 'Solaris-x86_m32'
);

cmd("/usr/bin/rm -rf ./$vers");
for my $padv(sort keys(%padv)) {
    cmd("/usr/bin/mkdir -p ./$vers/$padv");
    cmd("/usr/bin/cp -rp $isis/$vers/$padv{$padv}/stage/xprtl/* ./$vers/$padv");
}


