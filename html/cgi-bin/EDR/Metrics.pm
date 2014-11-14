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
package Metrics;
@Metrics::ISA = qw(Obj);
use strict;
use JSON;

#
# Metrics object to record statistics for phases, tasks, or commands.
#

# $key should like 'category,item,subitem';
# @vars could be like the following formats:
# 1. <scalar value>
# 2. ('push', <list values>)   # this is to push values to an existing list variable.
# 3. ('list', <list values>)   # this is to assign a list to a variable.
sub add_metrics {
    my ($key,@vars)=@_;
    my $metrics=$Obj::pool{Metrics};
    return 0 unless (defined $metrics);

    return 0 if (Cfg::opt('nometrics'));
    Obj::set_value($metrics->{pool},$key,@vars);
    Thr::setq($metrics->{pool},$key,@vars) if (EDR::thread_support());
    return 1;
}

sub set_phase {
    my ($phase)=@_;
    my $metrics=$Obj::pool{Metrics};
    $metrics->{metrics_phase} = $phase;
    return 1;
}

sub add_phase_metrics {
    my ($phase,$key,@vars)=@_;
    my $metrics=$Obj::pool{Metrics};
    $phase||=$metrics->{metrics_phase} || 'initiation';
    add_metrics("Phases,$phase,$key",@vars);
    return 1;
}

sub add_phase_task_metrics {
    my ($phase,$task,$key,@vars)=@_;
    add_phase_metrics("$phase","Tasks,$task,$key",@vars);
    return 1;
}

sub add_phase_command_metrics {
    my ($phase,$sys,$cmd,$key,@vars)=@_;
    $cmd=Metrics::escape($cmd);
    add_phase_metrics("$phase","Commands,$sys,$cmd,$key",@vars);
    return 1;
}

sub add_phase_script_metrics {
    my ($phase,$sys,$script,$key,@vars)=@_;
    $script=Metrics::escape($script);
    add_phase_metrics("$phase","Scripts,$sys,$script,$key",@vars);
    return 1;
}

sub add_phase_question_metrics {
    my ($phase,$question,$key,@vars)=@_;
    $question=Metrics::escape($question);
    add_phase_metrics("$phase","Questions,$question,$key",@vars);
    return 1;
}

sub add_phase_summary_metrics {
    my ($phase,$key,@vars)=@_;
    add_phase_metrics("$phase","Summary,$key",@vars);
    return 1;
}

sub dump {
    my ($file,$pretty)=@_;
    my ($edr,$metrics,$json_txt);

    return 1 if (Cfg::opt('nometrics'));

    $edr=Obj::edr();
    $file||=$edr->{localsys}->path($edr->{metricsdumpfile})||'';
    return unless ($file);

    $metrics=$Obj::pool{Metrics};
    return unless ($metrics);

    $pretty=1 if (!defined $pretty);
    $metrics=summarize($metrics);
    $json_txt=to_json($metrics,{pretty=>$pretty});
    $json_txt=unescape($json_txt);
    EDRu::writefile($json_txt,$file);

    return 1;
}

sub summarize {
    my ($metrics)=@_;
    my ($total_num,$total_time,$num,$time,$num1,$time1,$hash);
    my ($num_machines,%total_num_per_machine,%total_time_per_machine);
    my ($num_attribute,$time_attribute,%phases_need_be_removed,$edr,$execute_time,$operations_time);

    $metrics=EDRu::duphash($metrics);

    delete $metrics->{pool};
    delete $metrics->{class};
    delete $metrics->{metrics_phase};

    %phases_need_be_removed=();

    # Get summary for commands
    $total_num=0;
    $total_time=0;

    %total_num_per_machine=();
    %total_time_per_machine=();

    $num_attribute='Commands';
    $time_attribute='Commands_Time';

    for my $phase (keys %{$metrics->{Phases}}) {
        $phases_need_be_removed{$phase}=1;

        $hash=$metrics->{Phases}{$phase}{Commands};
        if (defined $hash) {
            # $num, $time for phase information
            $num=0;
            $time=0;

            $num_machines=scalar keys %{$hash};
            for my $machine (keys %{$hash}) {
                # $num1, $time1 for machine information
                $num1=0;
                $time1=0;

                for my $command (keys %{$hash->{$machine}}) {
                    for my $time2 (@{$hash->{$machine}{$command}{time}}) {
                        $num1++;
                        $time1+=$time2;
                    }
                }
                if ($num_machines>1) {
                    $total_num_per_machine{$machine}+=$num1;
                    $total_time_per_machine{$machine}+=$time1;

                    $metrics->{Phases}{$phase}{Summary}{$machine}{$num_attribute}=$num1 if ($num1);
                    $metrics->{Phases}{$phase}{Summary}{$machine}{$time_attribute}=format_float_time($time1) if ($time1);
                }

                $num+=$num1;
                $time+=$time1;
            }

            $metrics->{Phases}{$phase}{Summary}{Total}{$num_attribute}=$num if ($num);
            #$metrics->{Phases}{$phase}{Summary}{Total}{$time_attribute}=format_float_time($time) if ($time);

            $total_num+=$num;
            $total_time+=$time;

            $phases_need_be_removed{$phase}=0 if ($num>0);
        }
    }
    if ($num_machines>1) {
        for my $machine (keys %total_num_per_machine) {
            $num1=$total_num_per_machine{$machine};
            $time1=$total_time_per_machine{$machine};
            $metrics->{Summary}{$machine}{$num_attribute}=$num1 if ($num1);
            $metrics->{Summary}{$machine}{$time_attribute}=format_float_time($time1) if ($time1);
        }
    }
    $metrics->{Summary}{Total}{$num_attribute}=$total_num if ($total_num);
    #$metrics->{Summary}{Total}{$time_attribute}=format_float_time($total_time) if ($total_time);

    # Get summary for scripts
    $total_num=0;
    $total_time=0;

    %total_num_per_machine=();
    %total_time_per_machine=();

    $num_attribute='Scripts';
    $time_attribute='Scripts_Time';

    for my $phase (keys %{$metrics->{Phases}}) {
        $hash=$metrics->{Phases}{$phase}{Scripts};
        if (defined $hash) {
            # $num, $time for phase information
            $num=0;
            $time=0;

            $num_machines=scalar keys %{$hash};
            for my $machine (keys %{$hash}) {
                # $num1, $time1 for machine information
                $num1=0;
                $time1=0;

                for my $script (keys %{$hash->{$machine}}) {
                    for my $time2 (@{$hash->{$machine}{$script}{time}}) {
                        $num1++;
                        $time1+=$time2;
                    }
                }
                if ($num_machines>1) {
                    $total_num_per_machine{$machine}+=$num1;
                    $total_time_per_machine{$machine}+=$time1;

                    $metrics->{Phases}{$phase}{Summary}{$machine}{$num_attribute}=$num1 if ($num1);
                    $metrics->{Phases}{$phase}{Summary}{$machine}{$time_attribute}=format_float_time($time1) if ($time1);
                }

                $num+=$num1;
                $time+=$time1;
            }

            $metrics->{Phases}{$phase}{Summary}{Total}{$num_attribute}=$num if ($num);
            #$metrics->{Phases}{$phase}{Summary}{Total}{$time_attribute}=format_float_time($time) if ($time);

            $total_num+=$num;
            $total_time+=$time;

            $phases_need_be_removed{$phase}=0 if ($num>0);
        }
    }
    if ($num_machines>1) {
        for my $machine (keys %total_num_per_machine) {
            $num1=$total_num_per_machine{$machine};
            $time1=$total_time_per_machine{$machine};
            $metrics->{Summary}{$machine}{$num_attribute}=$num1 if ($num1);
            $metrics->{Summary}{$machine}{$time_attribute}=format_float_time($time1) if ($time1);
        }
    }
    $metrics->{Summary}{Total}{$num_attribute}=$total_num if ($total_num);
    #$metrics->{Summary}{Total}{$time_attribute}=format_float_time($total_time) if ($total_time);

    # Get summary for questions
    $total_num=0;
    $total_time=0;

    $num_attribute='Questions';
    $time_attribute='Questions_Time';

    for my $phase (keys %{$metrics->{Phases}}) {
        $hash=$metrics->{Phases}{$phase}{Questions};
        if (defined $hash) {
            # $num, $time for phase information
            $num=0;
            $time=0;

            for my $question (keys %{$hash}) {
                # $num1, $time1 for question information
                $num1=0;
                $time1=0;
                for my $time2 (@{$hash->{$question}{time}}) {
                    $num1++;
                    $time1+=$time2;
                }
                $num+=$num1;
                $time+=$time1;
            }
            $metrics->{Phases}{$phase}{Summary}{Total}{$num_attribute}=$num if ($num);
            $metrics->{Phases}{$phase}{Summary}{Total}{$time_attribute}=format_float_time($time) if ($time);

            $total_num+=$num;
            $total_time+=$time;

            $phases_need_be_removed{$phase}=0 if ($num>0);
        }
    }
    $metrics->{Summary}{Total}{$num_attribute}=$total_num if ($total_num);
    $metrics->{Summary}{Total}{$time_attribute}=format_float_time($total_time) if ($total_time);

    $edr=Obj::edr();
    $execute_time=$edr->{main_timer}->elapsed();
    $metrics->{Summary}{Total}{Execute_Time}=$execute_time;
    $operations_time=$execute_time-$total_time;
    $metrics->{Summary}{Total}{Operations_Time}=format_float_time($operations_time);

    for my $phase (keys %phases_need_be_removed) {
        if ($phases_need_be_removed{$phase}) {
            delete $metrics->{Phases}{$phase};
        }
    }

    return $metrics;
}

sub escape {
    my $str = shift;
    $str =~ s/{/##1/g;
    $str =~ s/}/##2/g;
    $str =~ s/~/##3/g;
    $str =~ s/"/##4/g;
    $str =~ s/'/##5/g;
    $str =~ s/,/##6/g;
    $str =~ s/\\/##7/g;
    $str =~ s/\$/##8/g;
    $str =~ s/\@/##9/g;
    $str =~ s/\%/##a/g;
    $str =~ s/\n/##n/g;
    return $str;
}

sub unescape {
    my $str = shift;
    $str =~ s/##1/\{/g;
    $str =~ s/##2/\}/g;
    $str =~ s/##3/\~/g;
    $str =~ s/##4/\\\"/g;
    $str =~ s/##5/\'/g;
    $str =~ s/##6/\,/g;
    $str =~ s/##7/\\\\/g;
    $str =~ s/##8/\$/g;
    $str =~ s/##9/\@/g;
    $str =~ s/##a/\%/g;

    # JSON do not support return character(\n) in name field of "<name>: <value>"
    #$str =~ s/##n/\n/g;

    return $str;
}

sub format_float_time {
    my $time=shift;
    return sprintf("%.2f", $time);
}

1;
