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
package Thr;
use strict;
use Obj;
use Msg;
use threads;
use threads::shared;
use Thread::Queue;
use Time::HiRes qw(usleep);

@Thr::ISA = qw(Obj);

sub init {
    my $thr=shift;
    # thread 0 is main, others are reset upon creation
    $thr->{tid}=0;
    # for basic tests that aren't calling EDR::create_edr_objects
    if (!$Obj::pool{Cfg}) {
        EDR->new();
        Cfg->new();
        Cfg::set_opt('trace') if (join(' ', @ARGV)=~/-trace/m);
    }
    return $thr;
}

sub tid {
    my $thr=shift;
    $thr=Obj::thr() unless (ref($thr) eq 'Thr');
    return $thr->{tid};
}

sub detach_threads {
    my $thr=shift;
    $thr=Obj::thr() unless (ref($thr) eq 'Thr');
    my $nthreads=$thr->{nthreads}||0;
    for my $tid (1..$nthreads) {
        my $thread=$thr->{$tid}{thr};
        next unless $thread;
        if (!$thread->is_detached() &&
            ($thread->is_joinable() || $thread->is_running())) {
            $thread->detach();
        }
    }
    return 1;
}

# sq (single-queue) thread values
# $thr->{type} = "sq";
# $thr->{nthreads} - total number of threads
# $thr->{tid} - thread ID
# $thr->{subs} - count of subs on $thr->{subq} - {JOBSCNT}
# $thr->{subq} - queue for main to thread messages, sub,args refs - {JOBS}
# $thr->{rtnq} - queue for thread to main messages, return values - {RESP}
# $thr->{setq} - queue for thread to main sets, sys,key,key=scalar | [ list ]
# $thr->{$tid}{thr} - thread object

# tests the single-queue procedure, args are $nthreads, $nsubs
# $nsubs is the number of subroutine calls to put on the main thread list
# $nsubs needs to be greater than nthreads if we are testing the throttle
sub sq_test {
    my ($nthreads,$nsubs) = @_;
    my $thr=Thr->new;
    $thr->sq_create_threads($nthreads);
    $thr->sq_test_add_subs($nsubs);
    $thr->sq_wait_for_completion();
    $thr->sq_join_threads();
    $thr->sq_test_read_rtns();
    return;
}

# makes nthreads, even if less are necessary
# could modify this, if necessary
sub sq_create_threads {
    my $thr=shift;
    $thr->{nthreads}=shift;
    $thr->{type}='sq';
    $thr->{subs}=0;
    $thr->{subq}=Thread::Queue->new();
    $thr->{rtnq}=Thread::Queue->new();
    $thr->{setq}=Thread::Queue->new();
    for my $tid(1..$thr->{nthreads}) {
        $thr->{$tid}{thr} = threads->new(\&sq_run_subs, $thr, $tid);
    }
    return '';
}

# adds $nsubs test subroutines on each thread subs list
# each sub is a call to sleep 3-9 seconds
sub sq_test_add_subs {
    my ($thr,$nsubs) = @_;
    # thread 0 is main
    $thr->{subs}=0;
    for my $nsub (1..$nsubs) {
        my $sleep=int(rand(7))+3; # buggy unless my is here?
        $thr->sq_enqueue_sub($nsub, '', 'Thr::sq_thr_test', $sleep, $nsub)
    }
    return '';
}

# Enqueue a sub
sub sq_enqueue_sub {
    my ($thr,@vars)=@_;
    EDR::die ('invalid arg to sq_enqueue_sub') if (!defined $vars[0]);
    my @sub_args :shared;
    @sub_args = @vars;
    $thr->{subq}->enqueue(\@sub_args);
    $thr->{subs}++ if ($sub_args[0] ne 'return');
    return '';
}

# main routine each thread is in
# sit waiting and run a subroutine passed on $thr->{subq}
sub sq_run_subs {
    my ($thr,$tid) = @_;
    my ($obj,$subno,$rtn,$subref,$pool,$sub);
    $thr->{tid}=$tid;
    while (1) {
        # blocks here until sub,args reference comes on the queue
        while ($subref = $thr->{subq}->dequeue) {
            $subno=shift(@$subref);
            return '' if ($subno eq 'return');
            $pool=shift(@$subref);
            $sub=shift(@$subref);
            no strict 'refs';
            if ($pool) {
                $obj=Obj::pool($pool) if ($pool);
                eval { $rtn=$obj->$sub(@$subref); };
            } else {
                EDR::die ("$sub not defined") unless (defined(&$sub));
                eval { $rtn=&$sub(@$subref); };
            }
            # TODO - fix
            EDR::die ("thread $tid threw error: $@") if ($@);
            $thr->{rtnq}->enqueue($subno, $rtn);
        }
    }
    return '';
}

sub sq_wait_for_completion {
    my $thr=shift;
    while($thr->{rtnq}->pending<$thr->{subs}*2){
        $thr->sq_read_setq();
        Msg::spin();
    }
    return '';
}

sub sq_read_setq {
    my $thr=shift;
    while ($thr->{setq}->pending) {
        my $item=$thr->{setq}->dequeue;
        Obj::set_value(@$item);
    }
    return '';
}

# exiting, get all threads to return and be joined to main thread
sub sq_join_threads {
    my $thr=shift;
    return unless ($thr->{type} eq 'sq');
    for my $tid(1..$thr->{nthreads}) { $thr->sq_enqueue_sub('return'); }
    for my $tid(1..$thr->{nthreads}) { $thr->{$tid}{thr}->join(); }
    delete $thr->{type};
    return '';
}

sub sq_test_read_rtns {
    my $thr=shift;
    my (@rtns,$rtn,$subno);
    for (1..$thr->{subs}) {
        $subno = $thr->{rtnq}->dequeue;
        $rtn = $thr->{rtnq}->dequeue;
        $rtns[$subno]=$rtn;
    }
    return \@rtns;
}

sub sq_thr_test {
    my($sleep,$nsub)= @_;
    print "sq_thr_test($sleep,$nsub) is sleeping $sleep seconds\n";
    sleep $sleep;
    print "sq_thr_test($sleep,$nsub) has slept $sleep seconds\n";
    return $sleep;
}

# mq (multi-queue) thread values
# $thr->{type} = "mq";
# $thr->{nthreads} - total number of threads
# $thr->{tid} - thread ID
# $thr->{$tid}{thr} - thread object
# $thr->{$tid}{subs} - list of sub,args references for each thread to run
# $thr->{$tid}{rtns} - list of return values from each sub
# $thr->{$tid}{subq} - queue for main to thread messages, sub,args refs
# $thr->{$tid}{rtnq} - queue for thread to main messages, return values
# $thr->{$tid}{setq} - queue for thread to main sets, key,key=scalar | [ list ]

# tests the multi-queue procedure
# nsubs is the number of subroutine calls to put on each thread list
# all subs are run before returns are queried
sub mq_test {
    my ($nthreads,$nsubs) = @_;
    my $thr=Thr->new;
    $thr->mq_create_threads($nthreads);
    $thr->mq_test_add_subs($nsubs);
    $thr->mq_wait_for_completion();
    $thr->mq_join_threads();
    $thr->mq_test_read_rtns();
    return;
}

# running a series of multi-queue subs in succession, reading the return
# values after each completes and only creating/joining the threads once
# args are $nthreads, $nloops.  $nsubs is always set to $nthreads
sub mq_test_series {
    my ($nthreads,$nsubs) = @_;
    my $thr=Thr->new;
    $thr->mq_create_threads($nthreads);
    for my $sub (1..$nsubs) {
        print "series $sub\n";
        $thr->mq_test_add_subs(1);
        $thr->mq_wait_for_completion();
        $thr->mq_test_read_series_rtns();
    }
    $thr->mq_join_threads();
    return;
}

# creates the threads
# one thread per system up to max of threadlimit
sub mq_create_threads {
    my ($thr,$nthr,$threadlimit)=@_;
    $threadlimit||=128; # who knows what the best default value is?
    if ($nthr>$threadlimit) {
        $thr->{nthreads}=$threadlimit;
        Msg::log("Only creating $threadlimit threads as $nthr exceeds thread limit");
    } else {
        $thr->{nthreads}=$nthr;
    }
    $thr->{type}='mq';
    for my $tid(1..$thr->{nthreads}) {
        $thr->{$tid}{subs}=[];
        $thr->{$tid}{subq}=Thread::Queue->new();
        $thr->{$tid}{rtnq}=Thread::Queue->new();
        $thr->{$tid}{rtns}=[];
        $thr->{$tid}{thr}=threads->new(\&mq_run_subs, $thr, $tid);
    }
    Thr::clean_setq();
    return '';
}

# adds $nsubs test subroutines on each thread subs list
# each sub is a call to sleep 3-9 seconds
sub mq_test_add_subs {
    my ($thr,$nsubs) = @_;
    # thread 0 is main
    for my $nsub (1..$nsubs) {
        for my $tid (1..$thr->{nthreads}) {
            my $sleep=int(rand(7))+3; # buggy unless my is here?
            $thr->mq_add_sub($tid, '', 'Thr::mq_thr_test', $tid, $sleep, $nsub)
        }
    }
    return '';
}

# push a sub,args references on to a sub queue
sub mq_add_sub {
    my ($thr,$tid,@vars) = @_;
    # in case systems exceeds thread limit
    my $ttid=(($tid-1)%$thr->{nthreads})+1;
    push(@{$thr->{$ttid}{subs}}, \@vars);
    return '';
}

sub mq_add_sub_allsys {
    my ($thr,$pool,$sub,@vars) = @_;
    my ($poolpadv,$tid);
    for my $sys(@{EDR::systems()}) {
        $tid++;
        next if ($sys->{stop_checks});
        next if ((EDRu::cpip_pool($pool)) && (!$sys->{padv})); # failed rsh_sys
        $poolpadv = (EDRu::cpip_pool($pool)) ? $pool.'::'.$sys->{padv} : $pool;
        $thr->mq_add_sub($tid, $poolpadv, $sub, $sys->{sys}, @vars);
    }
    return '';
}

# main routine each thread is in
# sit waiting and run a subroutine passed on $thr->{$tid}{subq}
sub mq_run_subs {
    my ($thr,$tid) = @_;
    my ($obj,$rtn,$subref,$pool,$sub);
    $thr->{tid}=$tid;
    while (1) {
        # blocks here until sub,args reference comes on the queue
        while ($subref = $thr->{$tid}{subq}->dequeue) {
            $pool=shift(@$subref);
            return '' if ($pool eq 'return');
            $sub=shift(@$subref);
            no strict 'refs';
            if ($pool) {
                $obj=Obj::pool($pool) if ($pool);
                eval { $rtn=$obj->$sub(@$subref); };
            } else {
                EDR::die ("$sub not defined") unless (defined(&$sub));
                eval { $rtn=&$sub(@$subref); };
            }
            # TODO - fix
            EDR::die ("thread $tid threw error: $@") if ($@);
            $thr->{$tid}{rtnq}->enqueue($rtn);
        }
    }
    return '';
}

# count the number of sub references in all the thread queues
sub mq_thread_sub_count {
    my ($thr,$nthr) = @_;
    my ($nsubs,$count);
    $nthr=$thr->{nthreads} if ((!$nthr) || ($nthr>$thr->{nthreads}));
    $count=0;
    for my $tid (1..$nthr) {
        $count++ if ($thr->{$tid}{insub});
        $nsubs=scalar(@{$thr->{$tid}{subs}});
        $count+=$nsubs;
        #Msg::log "count $tid $count $thr->{$tid}{insub} ".scalar(@{$thr->{$tid}{subs}});
    }
    return $count;
}

# pass subs from $thr->{$tid}{subs} list to $thr->{$tid}{subq} queue
# and store return values until all $thr->{$tid}{subq} queues are empty
# or $nthr $thr->{$tid}{subq} queues are empty for cases where subs like
# CPIC::copy_pkg_patch_subs are staying alive on threads above $nthr
# assumes that these subs will have properly completed and returned when it
# is time to join
sub mq_wait_for_completion {
    my ($thr,$nthr) = @_;
    my (@cmdfile,@stat,$rsa,$tsc,$dq,$cmd,$msg,$timeout);
    $timeout=EDR::get('timeout');
    $nthr=$thr->{nthreads} if ((!$nthr) || ($nthr>$thr->{nthreads}));
    $tsc=$thr->mq_thread_sub_count($nthr);
    while ($tsc) {
        for my $tid (1..$thr->{nthreads}) {
            $cmdfile[$tid]||=EDR::cmdfile($tid);
            if (!$thr->{$tid}{insub}) {
                if ($#{$thr->{$tid}{subs}}<0) { # empty sub queue
                } else { # run the first on the list
                    $rsa=shift(@{$thr->{$tid}{subs}});
                    $thr->{$tid}{insub}=join(',', @$rsa);
                    $thr->{$tid}{time}=0;
                    $thr->mq_enqueue_sub($tid, @$rsa);
                }
            } elsif ($thr->{$tid}{rtnq}->pending) { # sub has returned
                $dq=$thr->{$tid}{rtnq}->dequeue;
                push(@{$thr->{$tid}{rtns}}, $dq);
                delete($thr->{$tid}{insub});
                $tsc=$thr->mq_thread_sub_count($nthr);
            } else { # running, uncomment if it seems like a thread is hung
                if ((-f $cmdfile[$tid]) && ($timeout>0) && (time()%10==0)) {
                    @stat=stat($cmdfile[$tid]);
                    if (($stat[9]>0) && (time()-$stat[9]>$timeout)) {
                        $cmd=EDRu::readfile($cmdfile[$tid]);
                        $msg=Msg::new("timeout $timeout exceeded executing cmd:\n$cmd");
                        $msg->die;
                    }
                }
            }
        }
        Msg::spin();
    }

    # Sync for main thread and sub threads
    $thr->sync_setq($nthr);

    return '';
}

# TODO - make this handle $pool and $obj the same way
# reads return values off the thread queue
# $pfi=pass fail indicator
# 01  = 1=pass, 0=fail, ""=not run
# 01u = 1=pass, 0=fail, ""=not run
# msg = null=pass, non-null=fail (errmsg)
sub mq_read_rtns {
    my ($thr,$pfi,$passsub,$failsub,@vars) = @_;
    my (@rtns,$rtn,$tid,$ttid,$abortsub,$tmpsub);
    $pfi ||= '';
    $abortsub=shift @vars if ($pfi eq '01u');

    @rtns = (undef);    # thread 0 placeholder
    for my $sys (@{EDR::systems()}) {
        $tid++;
        $ttid = (($tid - 1) % $thr->{nthreads}) + 1;
        $rtn  = shift(@{$thr->{$ttid}{rtns}});
        push(@rtns, $rtn);

        if ($pfi eq '01' || $pfi eq '01u') {
            if ($rtn) {
                if ($passsub =~ /(\S+)::(\S+)/mx) {
                    $tmpsub = UNIVERSAL::can($1, $2);
                } else {
                    $tmpsub = UNIVERSAL::can('main', $passsub);
                }
                if ($tmpsub) {
                    $tmpsub->($sys, @vars);
                } else {
                    EDR::die("sub $passsub undefined");
                }
            } elsif (defined $rtn) {
                if ($failsub =~ /(\S+)::(\S+)/mx) {
                    $tmpsub = UNIVERSAL::can($1, $2);
                } else {
                    $tmpsub = UNIVERSAL::can('main', $failsub);
                }
                if ($tmpsub) {
                    $tmpsub->($sys, @vars);
                } else {
                    EDR::die("sub $failsub undefined");
                }
            } elsif ($pfi eq '01u') {
                if ($abortsub =~ /(\S+)::(\S+)/mx) {
                    $tmpsub = UNIVERSAL::can($1, $2);
                } else {
                    $tmpsub = UNIVERSAL::can('main', $failsub);
                }
                if ($tmpsub) {
                    $tmpsub->($sys, @vars);
                } else {
                    EDR::die("sub $failsub undefined");
                }
            }
        } elsif ($pfi eq 'msg') {
            if ($rtn) {
                if ($failsub =~ /(\S+)::(\S+)/mx) {
                    $tmpsub = UNIVERSAL::can($1, $2);
                } else {
                    $tmpsub = UNIVERSAL::can('main', $failsub);
                }
                if ($tmpsub) {
                    $tmpsub->($sys, @vars);
                } else {
                    EDR::die("sub $failsub undefined");
                }
            } elsif (defined $rtn) {
                if ($passsub =~ /(\S+)::(\S+)/mx) {
                    $tmpsub = UNIVERSAL::can($1, $2);
                } else {
                    $tmpsub = UNIVERSAL::can('main', $passsub);
                }
                if ($tmpsub) {
                    $tmpsub->($sys, @vars);
                } else {
                    EDR::die("sub $passsub undefined");
                }
            }
        }
    }
    return \@rtns;
}

# return 0 if one thread failed
# return 1 if all threads passed
sub mq_check_rtns {
    my ($thr,$rtns)=@_;

    for my $rtn (@{$rtns}) {
        next if (!defined $rtn || $rtn);
        return 0;
    }
    return 1;
}

# send a sub,args reference on to a $thr->{$tid}{subq} queue
sub mq_enqueue_sub {
    my ($thr,$tid,@vars) = @_;
    my @sub_args :shared;
    @sub_args = @vars;
    $thr->{$tid}{subq}->enqueue(\@sub_args);
    return '';
}

# exiting, get all threads to return and be joined to main thread
sub mq_join_threads {
    my $thr=shift;
    return unless ($thr->{type} eq 'mq');
    for my $tid(1..$thr->{nthreads}) {
        if ($thr->{$tid}{thr}) {
            $thr->mq_enqueue_sub($tid, 'return');
            $thr->{$tid}{thr}->join();
        }
    }
    delete $thr->{type};
    return '';
}

sub mq_thr_test {
    my($tid,$sleep,$nsub)= @_;
    print "mq_thr_test($tid,$sleep,$nsub) is sleeping $sleep seconds\n";
    sleep $sleep;
    print "mq_thr_test($tid,$sleep,$nsub) has slept $sleep seconds\n";
    return $sleep;
}

# assumes each thread has a list of returns to dequeue
sub mq_test_read_rtns {
    my $thr=shift;
    my (@rtns,$rtn);
    for my $tid (1..$thr->{nthreads}) {
        $rtn=$thr->mq_test_tid_read_rtns($tid);
        print "thread $tid returned [ ".join(', ', @$rtn)." ]\n";
    }
    return;
}

# dequeue all the returns from one thread
sub mq_test_tid_read_rtns {
    my ($thr,$tid) = @_;
    my (@rtns,$rtn);
    while(@{$thr->{$tid}{rtns}}) {
        $rtn=shift(@{$thr->{$tid}{rtns}});
        push(@rtns,$rtn);
    }
    return \@rtns;
}

# assumes each thread has only one return to dequeue
sub mq_test_read_series_rtns {
    my $thr=shift;
    my (@rtns,$rtn);
    for my $tid (1..$thr->{nthreads}) {
        $rtn=pop(@{$thr->{$tid}{rtns}});
        print "thread $tid returned $rtn\n";
    }
    return;
}

my @setq :shared = ();
# used for sq and mq, don't want developers to need to know which to use
# send a pool,key,value reference on to a $thr->{subq} queue
sub setq {
    my (@vars) = @_;
    return if(!EDR::thread_support());
    my $thr = (ref($vars[0]) eq 'Thr') ? shift : Obj::thr();
    $thr->push_setq(@vars);
    return '';
}

sub push_setq {
    my ($thr,@vars) = @_;

    unshift (@vars, $thr->{tid});
    lock @setq;

    # shared_clone do not work on VRTSperl 5.10, but on 5.12.
    #push @setq, shared_clone([ @vars ]);
    my @q :shared = @vars;
    push @setq, \@q;

    cond_signal (@setq);
    return 1;
}

sub clean_setq {
    lock @setq;
    @setq=();
    return 1;
}

sub setq_length {
    lock @setq;
    return scalar @setq;
}

# Sync setq for thread $tid
sub sync_setq_in_thread {
    my ($tid)=@_;
    my ($tid1,$obj,$pool,@vars);

    for my $item (@setq) {
        ($tid1,$pool,@vars)=@{$item};

        # do not need set the value which already done in current thread.
        next if ($tid1 == $tid);
        next unless ($pool && $Obj::pool{$pool});

        # Setting the attributes modified in other threads
        Obj::set_value($pool,@vars);
    }
    return 1;
}

sub sync_setq {
    my ($thr,$nthr) = @_;
    my ($finished,$length);

    # return directly if setq length is 0;
    $length=Thr::setq_length();
    return 1 unless $length;

    # Sync main thread. thread 0 is main
    Thr::sync_setq_in_thread(0);

    # Push Thr::sync_setq_in_thread() into subq for mq_run_subs() running.
    $nthr=$thr->{nthreads} if ((!$nthr) || ($nthr>$thr->{nthreads}));
    for my $tid (1..$nthr) {
        $thr->{$tid}{insub}=0;
        if ($thr->{$tid}{thr}) {
            $thr->mq_enqueue_sub($tid, '', 'Thr::sync_setq_in_thread', $tid);
            $thr->{$tid}{insub}=1;
        }
    }

    # Waiting for Thr::sync_setq_in_thread() complete on all threads
    do {
        $finished=1;
        for my $tid (1..$nthr) {
            if ($thr->{$tid}{rtnq}->pending) {
                # Thr::sync_setq_in_thread() sub has returned, discard the return value
                $thr->{$tid}{rtnq}->dequeue;
                $thr->{$tid}{insub}=0;
            }
            if ($thr->{$tid}{insub} || $thr->{$tid}{subq}->pending) {
                # Thr::sync_setq_in_thread() sub is still running or still not executed
                $finished=0;
            }
        }

        # sleep 50ms if Thr::sync_setq_in_thread() not completed on some threads.
        usleep 50 unless $finished;
    } until ($finished);

    # Clean @setq
    Thr::clean_setq();

    return 1;
}

1;
