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
package Phase;
use strict;
@Phase::ISA = qw(Obj);

# For each phase, it will perform 3 sub phases:
# 1.  execute the tasks one by one.
# 2.  show summaries about what tasks failed.
# 3.  call error handling to show solutions or give guidances about how to recover the failures.
#
# Phase object has the following attributes:
# 1. name:                  indicate the phase identifier
# 2. description:           indicate the phase description
# 3. fatal_error_key:       indicate whether to stop the phase's tasks if the key is set
# 3. skip_summary:          indicate whether to skip showing the summary
# 3. skip_error_handlers:   indicate whether to skip running error handlers

sub init {
    my ($phase,$pname,%params)=@_;
    my ($task,$task_name);

    $phase->{name}=$pname || '';

    return $phase unless (keys %params);

    set_description($phase,$params{description});
    set_fatal_error_key($phase,$params{fatal_error_key});
    set_skip_summary($phase,$params{skip_summary});
    set_skip_error_handlers($phase,$params{skip_error_handlers});

    set_summary_handler($phase, $params{summary_handler},
                      $params{summary_handler_object_arg},
                      $params{summary_handler_args});

    for my $task_params (@{$params{tasks}}) {
        $task_name=$task_params->{name};
        next unless ($task_name);
        $task = Task->new($task_name, %{$task_params});
        add_task($phase, $task);
    }

    return $phase;
}

# Set phase description.
sub set_description {
    my ($phase,$desc)=@_;
    return Obj::reset_value($phase, 'description', $desc);
}

# Initialize tasks
sub initialize_tasks {
    my $phase=shift;
    $phase->{tasks}=[];
    return 1;
}

# Set phase fatal_error_key.
sub set_fatal_error_key {
    my ($phase,$key)=@_;
    return Obj::reset_value($phase, 'fatal_error_key', $key);
}

# Set whether skip to show phase summary
sub set_skip_summary {
    my ($phase,$state)=@_;
    return Obj::reset_value($phase, 'skip_summary', $state);
}

# Set whether skip to call error handler for all tasks
sub set_skip_error_handlers {
    my ($phase,$state)=@_;
    return Obj::reset_value($phase, 'skip_error_handlers', $state);
}

# Set handler parameters for summary handler
sub set_summary_handler {
    my ($phase,$handler,$obj_arg,$args)=@_;
    Obj::reset_value($phase, 'summary_handler', $handler);
    Obj::reset_value($phase, 'summary_handler_object_arg', $obj_arg);
    Obj::reset_value($phase, 'summary_handler_args', $args);
    return 1;
}

# Set phase fatal_error_key.
sub initialize_fatal_error_keys {
    my ($phase)=@_;
    my ($edr,$key);

    $key=$phase->{fatal_error_key} || 'stop_tasks';

    $edr=Obj::edr();
    delete $edr->{$key};
    for my $sys (@{$edr->{systems}}) {
        delete $sys->{$key};
    }
    return 1;
}

# Add a task into the phase
sub add_task {
    my $phase=shift;
    my $task=$_[0];
    return unless (defined $task);

    if (ref($task) eq 'Task') {
        push (@{$phase->{tasks}}, $task);
    } else {
        my %task_params=(@_);
        my $task_name=$task_params{name};
        return unless ($task_name);
        $task = Task->new($task_name, %task_params);
        push (@{$phase->{tasks}}, $task);
    }
    return $task;
}

# Calculate the steps of tasks
sub tasks_steps {
    my ($phase,$tasks)=@_;
    my ($num,$systems);

    $num=0;
    $systems=EDR::systems();

    $tasks||=$phase->{tasks};
    for my $task (@$tasks) {
        next if ($task->{skip} || $task->is_silent());
        if ($task->{if_per_system} && Cfg::opt('serial')) {
            for my $sys (@{$systems}) {
                next if ($task->{skip_sys}{$sys->{sys}});
                $num++;
            }
        } else {
            $num++;
        }
    }

    return $num;
}

# Call summary handler
sub execute_summary_handler {
    my ($phase) = @_;
    my ($handler,$handler_object_arg,$handler_args,@args);

    $handler=$phase->{summary_handler};
    return 1 unless (defined $handler);

    @args=();
    $handler_object_arg=$phase->{summary_handler_object_arg};
    push(@args, $handler_object_arg) if (defined $handler_object_arg);
    $handler_args=$phase->{summary_handler_args};
    push(@args, @{$handler_args}) if (defined $handler_args);
    return &$handler(@args);
}

# Perform error handlering for the tasks one by one
sub execute_error_handlers {
    my ($phase,$tasks)=@_;

    $tasks||=$phase->{tasks};
    return 1 unless (defined $tasks && (scalar @{$tasks}));

    for my $task (@$tasks) {
        next if ($task->{skip});
        $task->execute_error_handler();
    }

    return 1;
}

# Execute the tasks with serial or thread mode
sub execute_tasks {
    my ($phase,$tasks)=@_;
    my ($edr,$steps,@sorted_tasks,@error_tasks,$fatal_error_key,$phase_desc,$thread_mode);
    my ($timer,$elapsed,$exitcode,$taskname);

    $tasks||=$phase->{tasks};
    return 1 unless (defined $tasks && (scalar @{$tasks}));

    # Sort the tasks first with 'sequence_id' attribute
    @sorted_tasks= sort { $a->{sequence_id} <=> $b->{sequence_id} } @{$tasks};
    $tasks = \@sorted_tasks;

    # Calculate the steps for all tasks
    $steps=$phase->tasks_steps($tasks);
    return 1 unless ($steps);

    # Begin to show progress
    Msg::title();
    $edr=Obj::edr();
    $edr->set_progress_steps($steps);
    $phase->initialize_fatal_error_keys();

    $thread_mode=1 if (!Cfg::opt('serial'));

    $timer=Timer->new("phase::time");
    $timer->start();

    # Create threads if in thread mode
    EDR::create_threads() if ($thread_mode);

    # Execute the tasks one by one
    $fatal_error_key=$phase->{fatal_error_key};
    $phase_desc=$phase->{description};

    # @error_tasks: record which tasks are executed and perform error handling for these tasks later.
    @error_tasks=();

    for my $task (@$tasks) {
        # Skip the remaining tasks if $fatal_error_key is set in EDR level or
        #  the key is set for all systems in system level.
        if ($edr->{$fatal_error_key} || !EDR::num_sys_keynotset($fatal_error_key)){
            $exitcode = ($taskname =~ /start|stop/)? EDR->EXITPROCESSFAILURE :
                (($taskname =~ /install\_|uninstall\_/) ? EDR->EXITPACKAGEFAILURE : EDR->EXITUNDEFINEDISSUE);
            $edr->set_exitcode($exitcode);
            last;
        }
        $task->execute($fatal_error_key,$phase_desc);
        push @error_tasks, $task;

        if (defined $task->{execute_time}) {
            Metrics::add_phase_task_metrics('', $task->{name}, 'time', $task->{execute_time});
        } elsif (defined $task->{execute_time_sys}) {
            for my $sys (keys %{$task->{execute_time_sys}}) {
                Metrics::add_phase_task_metrics('', $task->{name}, "time,$sys", $task->{execute_time_sys}{$sys});
            }
        }
    }

    # Join threads if in thread mode
    EDR::join_threads() if ($thread_mode);

    # Show summaries
    $phase->execute_summary_handler() if (!$phase->{skip_summary});

    # Perform error handling for those executed tasks
    $phase->execute_error_handlers(\@error_tasks) if (!$phase->{skip_error_handlers});

    # Record the execute time for the phase
    $elapsed=$timer->stop();
    $phase->{execute_time}=$elapsed;
    #Msg::log("Phase '$phase->{name}' took $elapsed");

    return 1;
}

1;
