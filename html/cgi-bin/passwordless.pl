#! /usr/bin/perl -w

use strict;
use Expect;

use CGI qw/:standard/;
use JSON qw/encode_json decode_json/;

sub cmd {
    my $cmd = shift;
    my $out = `$cmd 2>&1`;
    return $out;
}

sub get_root_home {
    my ($str_passwd,@array_passwd,$root_home);
    $str_passwd = cmd("grep '^root:' /etc/passwd 2>/dev/null");
    @array_passwd=grep {/^root:/m} split(/\n/,$str_passwd);
    $str_passwd=$array_passwd[0];
    if ($str_passwd) {
        @array_passwd=split(/:/m,$str_passwd);
        $root_home = $array_passwd[5];
    }   
    return $root_home;
}

sub ssh_setup {
    my ($system,$password) = @_;
    my ($connected, $password_validate, $local_home, $remote_home, $debug, @array_passwd);
    $local_home = get_root_home();

    my $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system echo symc_validate_string";
    my $timeout = 20;
    my $exp = Expect->spawn($cmd) or die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $connected = 1;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $connected = 1;
                $exp->send("yes\n");
                exp_continue; } ],
        [ 'symc_validate_string' => sub { $exp = shift;
                $connected = 1;
                $password_validate=1;
                exp_continue; } ],
    );  
    $exp->hard_close();

    if (!$password_validate) {
        print "wrong password\n";
        return 1;
    }
    if (-f "$local_home/.ssh/id_rsa.pub" && -f "$local_home/.ssh/id_rsa") {
        cmd("rm -rf $local_home/.ssh/symc_auto.pub ; cp $local_home/.ssh/id_rsa.pub $local_home/.ssh/symc_auto.pub");
    } else {
        cmd("rm -rf $local_home/.ssh/symc_auto $local_home/.ssh/symc_auto.pub ; mkdir -p $local_home/.ssh ; chmod 0700 $local_home/.ssh ; chown root $local_home/.ssh ; sshkeygen -t rsa -N \'\' -f $local_home/.ssh/symc_auto ; cp -p $local_home/.ssh/symc_auto $local_home/.ssh/id_rsa ; cp -p $local_home/.ssh/symc_auto.pub $local_home/.ssh/id_rsa.pub");
    }

    #get the value of $HOME on remote system
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system grep '^root:' /etc/passwd";
    $exp = Expect->spawn($cmd) or die("Cannot spawn command: $!\n");
    $exp->exp_internal($debug);
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ],
        [ qr/root.*/ => sub { $exp = shift;
                @array_passwd=split(/:/m,$exp->match());
                $remote_home=$array_passwd[5];
                exp_continue; } ],
    );
    $exp->hard_close();

    # Transfer key file with scp
    $cmd = "LANG=C LC_ALL=C scp -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $local_home/.ssh/symc_auto.pub root\@$system:/var/tmp";
    $exp = Expect->spawn($cmd) or die("Cannot spawn command: $!\n");
    $exp->exp_internal($debug);
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ],
    );
    $exp->hard_close();
    # chmod / to 0755
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system chmod 0755 /";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();

    # chown / to root
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system chown root /";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
    # chmod $remote_home to 0750 if it is not /
    if ($remote_home ne '/') {
        $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system chmod 0750 $remote_home ";
        $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
        $exp->expect($timeout,
            [ qr/Password:/i => sub { $exp = shift;
                    $exp->send("$password\n");
                    exp_continue; } ],
            [ 'yes/no' => sub { $exp = shift;
                    $exp->send("yes\n");
                    exp_continue; } ]);
        $exp->hard_close();


        #chown $remote_home to root
        $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system chown root $remote_home ";
        $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
        $exp->expect($timeout,
            [ qr/Password:/i => sub { $exp = shift;
                    $exp->send("$password\n");
                    exp_continue; } ],
            [ 'yes/no' => sub { $exp = shift;
                    $exp->send("yes\n");
                    exp_continue; } ]);
        $exp->hard_close();
    }

    # mkdir $remotehome/.ssh
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system mkdir -p $remote_home/.ssh";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
    # chmod $remotehome/.ssh
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system chmod 700 $remote_home/.ssh";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
    # Add key file as authorized key
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system cat /var/tmp/symc_auto.pub \\>\\> $remote_home/.ssh/authorized_keys";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
    # Delete temp symc_auto.pub on remote system
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system rm -f /var/tmp/symc_auto.pub";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
    # chmod $remotehome/.ssh/authorized_keys
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system chmod 600 $remote_home/.ssh/authorized_keys";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
    #  # restore SELinux context of $remotehome/.ssh/authorized_keys
    $cmd = "LANG=C LC_ALL=C ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' $system /sbin/restorecon -v $remote_home/.ssh/authorized_keys";
    $exp = Expect->spawn($cmd) or EDR::die("Cannot spawn command: $!\n");
    $exp->exp_internal($debug);
    $exp->expect($timeout,
        [ qr/Password:/i => sub { $exp = shift;
                $exp->send("$password\n");
                exp_continue; } ],
        [ 'yes/no' => sub { $exp = shift;
                $exp->send("yes\n");
                exp_continue; } ]);
    $exp->hard_close();
}

ssh_setup("redhat92201","walker");

my $cgi= new CGI;
print $cgi->header(-type => "application/json", -charset => "utf-8");
print encode_json({'val'=>'1'});
