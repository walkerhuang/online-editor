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
package Timer;
use strict;
use Obj;
use Time::HiRes qw(gettimeofday tv_interval setitimer ITIMER_REAL);
@Timer::ISA = qw(Obj);

# To get how long a task executed.
# set a timer to execute one task repeatly.

sub init {
    my ($timer,$timer_name,$after,$interval,$callback) = @_;
    $timer->{name} = $timer_name;
    $timer->{started} = $timer->time;

    # settimer arguments
    $timer->{after}=$after if (defined $after);
    $timer->{interval}=$interval if (defined $interval);
    $timer->{callback}=$callback if (defined $callback);

    return 1;
}

sub time {
    return [ gettimeofday() ];
}

sub name {
    my ($timer) = @_;
    return $timer->{name};
}

sub start {
    my ($timer) = @_;

    # don't use an old stopped time if we're restarting
    delete $timer->{stopped};

    $timer->{started} = $timer->time;

    # set timer signal
    if (defined $timer->{interval} &&
        defined $timer->{callback}) {
        # if $timer->{after} not defined, then tigger the timer after 1 second
        $timer->{after}||=1;
        $SIG{ALRM} = $timer->{callback};
        setitimer(ITIMER_REAL, $timer->{after}, $timer->{interval});
    }
    return 1;
}

sub stop {
    my ($timer) = @_;

    $timer->{stopped} ||= $timer->time;

    if (defined $timer->{interval} &&
        defined $timer->{callback}) {
        setitimer(ITIMER_REAL, 0, 0);
    }
    return $timer->elapsed if (defined wantarray);
    return;
}

sub elapsed {
    my ($timer) = @_;

    my $elapsed = $timer->{stopped} || $timer->time;
    return sprintf("%.2f",tv_interval($timer->{started},$elapsed));
}


sub separate_hms {
    my ($s)  = @_;

    # find the number of whole hours, then subtract them
    my $h  = int($s / 3600);
       $s -=     $h * 3600;
    # find the number of whole minutes, then subtract them
    my $m  = int($s / 60);
       $s -=     $m * 60;

    return ($h, $m, $s);
}

sub hms {
    my ($timer, $format) = @_;
    my ($seconds,$h,$m,$s,$string);

    $seconds = $timer->elapsed;
    ($h, $m, $s) = separate_hms($seconds);

    return ($h, $m, $s) if (wantarray);

    $string='';
    $format||='short';
    if ($format eq 'short') {
        $string = sprintf('%d seconds (%d:%02d:%02d)', $seconds, $h, $m, $s);
    } elsif ($format eq 'short_hires') {
        $string = sprintf('%s seconds (%d:%02d:%02d)', $seconds, $h, $m, $s);
    } elsif ($format eq 'human') {
        if ($h) {
            $string = sprintf('%d seconds (%d hours %d minutes %d seconds)', $seconds, $h, $m, $s);
        } else {
            $string = sprintf('%d seconds (%d minutes %d seconds)', $seconds, $m, $s);
        }
    } else {
        $string=sprintf($format, $seconds, $h, $m, $s);
    }
    return $string;
}

1;
