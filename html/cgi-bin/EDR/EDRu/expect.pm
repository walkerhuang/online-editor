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

use constant EXPECT_SYMC_PROMPT => 'SYMCPrompt>';

sub setup_expect {
    my ($sys,$user,$passwd,$cmd,$timeout,@exp_params) = @_;
    my ($exp,$debug,$pos,$error,$match,$before,$after);

    # Check arguments
    return unless ($cmd);
    return unless (@exp_params);

    # Check if Expect module is ready.
    eval { require Expect };
    return if ($@);

    # Creating the Expect object
    $exp = Expect->spawn($cmd);
    return if (!$exp);

    # Configuring the expect object
    $exp->log_stdout(0);

    # To print debug information, set $debug to 1
    $debug=Cfg::opt('trace') || 0;
    $exp->debug($debug);
    $exp->exp_internal($debug);

    # Execute the command with Expect
    ($pos,$error,$match,$before,$after)=$exp->expect($timeout, @exp_params);

    # If $error begin with 1, means TIMEOUT
    # If $error begin with 2, means EOF, the connection is aborted or scp command finished
    # If $error begin with 3, means the ssh or rsh process exit with error.
    # If $error begin with 4, means unknown error

    if (wantarray) {
        return ($exp,$pos,$error,$match,$before,$after);
    }
    return $exp;
}

# Execute command with the Expect object
sub exec_expect {
    my ($exp,$cmd,$timeout,$match_str) = @_;
    my ($begin,$stdout,$stderr,$exitcode);

    $exp->expect(1, EDRu->EXPECT_SYMC_PROMPT);
    if ($match_str) {
        $exp->send("$cmd\n");
        $exp->expect($timeout,'-re',"$match_str");
        $stdout=$exp->match() || '';
        chomp $stdout;
        $exitcode=0;
    } else {
        $exp->send("echo __BEGIN__; $cmd; echo __END__=\$?\n");
        $exp->expect($timeout,'-re', EDRu->EXPECT_SYMC_PROMPT);
        $match_str=$exp->before() || '';
        $begin=0;
        $stdout='';
        $exitcode='0';
        for my $line (split /\r?\n/, $match_str) {
            if ($line eq '__BEGIN__') {
                $begin=1;
                next;
            }
            next if (!$begin);

            if ($line =~ /^(.*)__END__=\s*(-?\d+)$/mxs) {
                $stdout.="$1";
                $exitcode="$2";
                last;
            }
            $stdout.="$line\n";
        }
        chomp $stdout;
        chomp $exitcode;
    }
    $stderr='';

    if (wantarray) {
        return ($stdout,$stderr,$exitcode);
    }
    return $stdout;
}

# Close the expect object
sub close_expect {
    my $exp = shift;
    $exp->hard_close();
    return 1;
}

1;
