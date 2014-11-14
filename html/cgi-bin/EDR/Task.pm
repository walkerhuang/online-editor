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
package Task;
use strict;
@Task::ISA = qw(Obj);

# Task object has the following attributes:
# 1. name:              indicate the task identifier
# 2. description:       indicate the task description
# 3. description_sys:   indicate the task description for specified system. replace #{SYS}
# 4. if_per_system:     indicate the task whether need run the task on each system.
# 5. pre_handler:       indicate the pre task handler subroutine.
# 6. handler:           indicate the task handler subroutine.
# 7. post_handler:      indicate the post task handler subroutine.
# 8. rc_handler:        indicate the task handler subroutine which to check return code further.
# 9. error_handler:     indicate the error handler subroutine which to recover the failures further.

sub init {
    my ($task,$tname,%params)=@_;

    $task->{name}=$tname;

    return $task unless (keys %params);

    set_description($task, $params{description}, $params{description_sys});
    set_sequence_id($task, $params{sequence_id});
    set_skip($task, $params{skip});
    set_serial($task, $params{serial});
    set_silent($task, $params{silent});
    set_if_per_system($task, $params{if_per_system});
    set_recreate_threads($task, $params{need_recreate_threads});
    set_recreate_threads_after_action($task, $params{need_recreate_threads_after_action});
    set_pre_action($task, $params{pre_handler},
                      $params{pre_handler_object_arg},
                      $params{pre_handler_args});
    set_action($task, $params{handler},
                      $params{handler_object_arg},
                      $params{handler_args});
    set_post_action($task, $params{post_handler},
                      $params{post_handler_object_arg},
                      $params{post_handler_args});
    set_rc_handler($task, $params{rc_handler},
                      $params{rc_handler_object_arg},
                      $params{rc_handler_args});
    set_error_handler($task, $params{error_handler},
                      $params{error_handler_object_arg},
                      $params{error_handler_args});
    return $task;
}

# Set task description.
# if the task is per systems, then need another argument for 'description_sys' attribute.
sub set_description {
    my ($task,$desc,$desc_sys)=@_;
    Obj::reset_value($task, 'description', $desc);
    Obj::reset_value($task, 'description_sys', $desc_sys);
    return 1;
}

# Set whether the task's sequence id.
sub set_sequence_id {
    my ($task,$sequence_id)=@_;

    $sequence_id||=0;
    $task->{sequence_id}=$sequence_id;
    return 1;
}

# Set whether the task's sequence id.
sub set_if_per_system {
    my ($task,$if_per_system)=@_;
    return Obj::reset_value($task, 'if_per_system', $if_per_system);
}

# Set whether skip the task on specified system.
sub set_skip_sys {
    my ($task,$sys,$state)=@_;
    return Obj::reset_value($task, "skip_sys,$sys->{sys}", $state);
}

# Set whether skip the task.
sub set_skip {
    my ($task,$state)=@_;
    return Obj::reset_value($task, 'skip', $state);
}

# Set whether execute the task serially.
sub set_serial {
    my ($task,$state)=@_;
    return Obj::reset_value($task, 'serial', $state);
}

# Set whether do not show progress on screen.
sub set_silent {
    my ($task,$state)=@_;
    return Obj::reset_value($task, 'silent', $state);
}

# Check whether the task is silent.
sub is_silent {
    my $task=shift;
    return 1 if ($task->{silent} || !$task->{description});
    return 0;
}

# Set whether need re-create the threads to executed the task.
sub set_recreate_threads {
    my ($task,$state)=@_;
    return Obj::reset_value($task, 'need_recreate_threads', $state);
}

# Set whether need re-create the threads after executed the task.
sub set_recreate_threads_after_action {
    my ($task,$state)=@_;
    return Obj::reset_value($task, 'need_recreate_threads_after_action', $state);
}

sub set_value {
    my $task=shift;
    Obj::set_value($task->{pool}, @_);
    Thr::setq($task->{pool}, @_) if (EDR::thread_support());
    return;
}

sub set_pre_action {
    my ($task,$handler,$obj_arg,$args)=@_;

    Obj::reset_value($task, 'pre_handler', $handler);
    Obj::reset_value($task, 'pre_handler_object_arg', $obj_arg);
    Obj::reset_value($task, 'pre_handler_args', $args);
    return 1;
}

sub set_action {
    my ($task,$handler,$obj_arg,$args)=@_;

    Obj::reset_value($task, 'handler', $handler);
    Obj::reset_value($task, 'handler_object_arg', $obj_arg);
    Obj::reset_value($task, 'handler_args', $args);
    return 1;
}

sub set_post_action {
    my ($task,$handler,$obj_arg,$args)=@_;

    Obj::reset_value($task, 'post_handler', $handler);
    Obj::reset_value($task, 'post_handler_object_arg', $obj_arg);
    Obj::reset_value($task, 'post_handler_args', $args);
    return 1;
}

sub set_rc_handler {
    my ($task,$handler,$obj_arg,$args)=@_;

    Obj::reset_value($task, 'rc_handler', $handler);
    Obj::reset_value($task, 'rc_handler_object_arg', $obj_arg);
    Obj::reset_value($task, 'rc_handler_args', $args);
    return 1;
}

sub set_error_handler {
    my ($task,$handler,$obj_arg,$args)=@_;

    Obj::reset_value($task, 'error_handler', $handler);
    Obj::reset_value($task, 'error_handler_object_arg', $obj_arg);
    Obj::reset_value($task, 'error_handler_args', $args);
    return 1;
}

# To call task's pre action
# if pre_handler return undef, means this task need be skipped.
sub execute_pre_action {
    my ($task) = @_;
    my ($handler,$handler_object_arg,$handler_args,@args);

    $handler=$task->{pre_handler};
    return 1 unless (defined $handler);

    @args=();
    $handler_object_arg=$task->{pre_handler_object_arg};
    push(@args, $handler_object_arg) if (defined $handler_object_arg);
    $handler_args=$task->{pre_handler_args};
    push(@args, @{$handler_args}) if (defined $handler_args);
    return &$handler(@args);
}

# To call task's handler, may run in thread mode.
sub execute_action {
    my ($task,$arg,$fatal_error_key) = @_;
    my ($handler,$handler_object_arg,$handler_args,@args,$rc,$sys,$desc);
    my ($timer,$elapsed);

    # This sub usually called with the following ways:
    # 1. If the task is for cluster level, then $task->execute_action() is called, $arg is undef.
    # 2. If the task is for systems level and in serial mode, then $task->execute_action($sys,$fatal_error_key) is called, $arg is $sys;
    # 3. If the task is for systems level and in thread mode, Then Task::execute_action($sys_name,$task_name,$fatal_error_key) is called, $arg is $task_name.
    if (ref($task) ne 'Task') {
        # This is the 3rd case which this sub is called for system level and in thread mode.
        # need revert $sys,$task.
        $sys=$task;
        $task=$arg;

        # Create objects
        $sys=Obj::sys($sys);
        $task=Obj::task($task);
    } else {
        $sys=$arg;
    }

    if (defined $sys) {
        $fatal_error_key ||= 'stop_tasks';

        # skip the task on system if fatal error.
        return if ($task->{skip_sys}{$sys->{sys}} ||
                   $sys->{$fatal_error_key});
    }

    $timer=Timer->new("task::time");
    $timer->start();

    # Call task action
    $handler=$task->{handler};
    if (defined $handler) {
        @args=();
        $handler_object_arg=$task->{handler_object_arg};
        push(@args, $handler_object_arg) if (defined $handler_object_arg);
        push(@args, $sys) if (defined $sys);
        $handler_args=$task->{handler_args};
        push(@args, @{$handler_args}) if (defined $handler_args);
        $rc=&$handler(@args);
    }

    # Record the task execute time
    $elapsed=$timer->stop();
    if (defined $sys) {
        $task->set_value("return_code_sys,$sys->{sys}",$rc);
        $task->set_value("execute_time_sys,$sys->{sys}",$elapsed);
    } else {
        $task->set_value("return_code",$rc);
        $task->set_value("execute_time",$elapsed);
    }

    $desc=$task->{description};
    if (defined $desc) {
        if (defined $sys) {
            $desc=$task->{description_sys} || $desc;
            $desc=$desc->{msg} if (ref($desc) =~ m/^Msg/);
            $desc=~s/#{SYS}/$sys->{sys}/g;
        } else {
            $desc=$desc->{msg} if (ref($desc) =~ m/^Msg/);
        }
        $elapsed=$timer->hms('short_hires');
        Msg::log("$desc took $elapsed");
    }

    return $rc;
}

# To call task's post action
sub execute_post_action {
    my ($task) = @_;
    my ($handler,$handler_object_arg,$handler_args,@args);

    $handler=$task->{post_handler};
    return 1 unless (defined $handler);

    @args=();
    $handler_object_arg=$task->{post_handler_object_arg};
    push(@args, $handler_object_arg) if (defined $handler_object_arg);
    $handler_args=$task->{post_handler_args};
    push(@args, @{$handler_args}) if (defined $handler_args);
    return &$handler(@args);
}

# To get the task's overall status on all systems.
# It is only called when in thread mode.
# There are the following overall return codes by default:
# undef:  means the task is skipped on all systems.
# 0:      means the task is failed on all systems.
# 1:      means the task is successfully completed on all systems.
# 10:     means the task is successfully completed on some systems, but failed on all other systems.
# 13:     means the task is successfully completed on some systems, but skipped on all other systems.
sub get_rc_total_status {
    my ($task,@rcs)=@_;
    my ($rc,$rc_undef,$rc_0,$rc_1,$rcs_num);

    # To get how many systems the task return undef, 0, 1 respectively.
    $rc_undef=0;
    $rc_0=0;
    $rc_1=0;
    for my $rc (@rcs) {
        if (!defined $rc) {
            $rc_undef++;
        } elsif ($rc) {
            $rc_1++;
        } else {
            $rc_0++;
        }
    }

    $rcs_num=scalar @rcs;
    if ($rc_undef == $rcs_num) {
        # task is skipped on all systems
        $rc=undef;
    } elsif ($rc_0 == $rcs_num) {
        # task is failed on all systems
        $rc=0;
    } elsif ($rc_1 == $rcs_num) {
        # task is successfully completed on all systems
        $rc=1;
    } elsif ($rc_1 > 0) {
        if ($rc_0 > 0) {
            # task is successfully completed on some systems, and failed on other systems
            $rc=10;
        } else {
            # task is successfully completed on some systems, and skipped on all other systems
            $rc=13;
        }
    } else {
        # task is failed on some systems
        $rc=0;
    }

    return $rc;
}

# To call task's rc_handler according to the return code
sub execute_rc_handler {
    my ($task,$rc) = @_;
    my ($handler,$handler_object_arg,$handler_args,@args,@sys_args,@rcs,$systems);

    $handler=$task->{rc_handler};
    @args=();
    $handler_object_arg=$task->{rc_handler_object_arg};
    push(@args, $handler_object_arg) if (defined $handler_object_arg);
    $handler_args=$task->{rc_handler_args};

    if ($task->{if_per_system}) {
        @rcs=();

        # Execute rc_handler on each system with &handler($obj,$sys,$args,$rc);
        $systems=EDR::systems();
        for my $sys (@{$systems}) {
            $rc=$task->{return_code_sys}{$sys->{sys}};
            if (defined $handler) {
                @sys_args=();
                push(@sys_args, $sys);
                push(@sys_args, @{$handler_args}) if (defined $handler_args);
                push(@sys_args, $rc);
                $rc=&$handler(@args,@sys_args);
            }
            push (@rcs, $rc);
        }

        $rc=$task->get_rc_total_status(@rcs);
    } else {
        # Execute rc_handler on cluster level with &handler($obj,$args,$rc);
        $rc||=$task->{return_code};
        if (defined $handler) {
            push(@args, @{$handler_args}) if (defined $handler_args);
            push(@args, $rc);
            $rc=&$handler(@args);
        }
        $rc=1 if ($rc);
    }

    return $rc;
}

# To call task's error_handler for errors/warnings handling
sub execute_error_handler {
    my ($task) = @_;
    my ($handler,$handler_object_arg,$handler_args,@args);

    $handler=$task->{error_handler};
    return 1 unless (defined $handler);

    @args=();
    $handler_object_arg=$task->{error_handler_object_arg};
    push(@args, $handler_object_arg) if (defined $handler_object_arg);
    $handler_args=$task->{error_handler_args};
    push(@args, @{$handler_args}) if (defined $handler_args);
    return &$handler(@args);
}

sub show_desc_left {
    my ($task,$phase_desc,$sys) = @_;

    my $msg=$task->{description};
    if (defined $sys) {
        $msg=$task->{description_sys} || $msg;
        $msg=$msg->{msg} if (ref($msg) =~ m/^Msg/);
        $msg=~s/#{SYS}/$sys->{sys}/g;
    }

    if (defined $phase_desc && ref($phase_desc) =~ m/^Msg/) {
        $phase_desc->display_left($msg);
    } else {
        Msg::left($msg);
    }

    if (Cfg::opt('vom')) {
        my $web = Obj::web();
        my $trans;
        if ($web->{trans}) {
            $trans = $web->{trans};
        } else {
            $trans='Transport::VOM'->new();
        }
        if (defined $sys) {
            $trans->pre_update_status("in-progress",$msg,$sys);
        } else {
            $msg=$task->{description_sys} || $msg;
            $msg=$msg->{msg} if (ref($msg) =~ m/^Msg/);
            $trans->pre_update_status("in-progress",$msg);
        }

#        $trans->pre_update_status("in-progress",$msg->{msg},$sys);
    }

    return;
}

# To show the task status message on the right of the step.
# By default:
# If task return undef, then show 'Skipped'
# If task return 0,     then show 'Failed'
# If task return 1,     then show 'Done'
# If task return 10,    then show 'Partially Done'
# If task return 13,    then show 'Done'
sub show_result_right {
    my ($task,$phase_desc,$rc) = @_;
    $rc='undef' if (!defined $rc);

    my $msg=$task->{status_msgs}{$rc};
    if (!defined $msg) {
        if ($rc eq 'undef') {
            $msg=Msg::new("Skipped");
        } elsif ($rc == 0) {
            $msg=Msg::new("Failed");
        } elsif ($rc == 1) {
            $msg=Msg::new("Done");
        } elsif ($rc == 10) {
            $msg=Msg::new("Partially Done");
        } elsif ($rc == 13) {
            $msg=Msg::new("Done");
        } else {
            $msg=Msg::new("Done");
        }
    }

    if (defined $phase_desc && ref($phase_desc) =~ m/^Msg/) {
        $phase_desc->display_right($msg);
    } else {
        Msg::right($msg);
    }

    if (Cfg::opt('vom')) {
        my $web = Obj::web();
        my $trans;
        if ($web->{trans}) {
            $trans = $web->{trans};
        } else {
            $trans='Transport::VOM'->new();
        }
        $trans->post_update_status("in-porgress",$msg->{msg});
    }
    return;
}

# To execute the task
sub execute {
    my ($task,$fatal_error_key,$phase_desc) = @_;
    my ($edr,$systems,$thr,$logfileid,$rc,$silent);

    return if ($task->{skip});

    $rc=$task->execute_pre_action();

    # if pre_action return undef, then skip the whole task actions.
    return unless (defined $rc);

    $silent=$task->is_silent();

    if ($task->{if_per_system}) {
        $edr=Obj::edr();
        $systems=$edr->{systems};

        if (Cfg::opt('serial')) {
            # Run task with serial mode
            for my $sys (@{$systems}) {
                next if ($task->{skip_sys}{$sys->{sys}});

                # To call task action handler
                $task->show_desc_left($phase_desc,$sys) if (!$silent);
                $rc=$task->execute_action($sys, $fatal_error_key);
                $task->show_result_right($phase_desc,$rc) if (!$silent);
            }
            $task->execute_rc_handler();
        } else {
            # Run task with thread mode
            $task->show_desc_left($phase_desc) if (!$silent);
            $thr=Obj::thr();
            if ($task->{serial}) {
                $logfileid=0;
                for my $sys (@{$systems}) {
                    $edr->{logfileid}=($logfileid % $thr->{nthreads}) + 1;
                    $task->execute_action($sys,$fatal_error_key);
                    $edr->{logfileid}=0;
                    $logfileid++;
                }
            } else {
                # if run the task with standalone mode, instead of in phase context,
                # then need set 'need_recreate_threads' attribute to 1, to create threads
                # for task execution in thread mode.
                if ($task->{need_recreate_threads}) {
                    EDR::create_threads();
                } else {
                    # Synchronize the setq from main thread to all sub threads.
                    $thr->sync_setq();
                }

                $thr->mq_add_sub_allsys('', 'Task::execute_action', $task->{name}, $fatal_error_key);
                $thr->mq_wait_for_completion();
                $thr->mq_read_rtns();

                # For some cluster level tasks, if they created some new objects,
                # 'need_recreate_threads_after_action' attribute need be set to 1,
                # to propagate the new objects to the sub threads.
                if ($task->{need_recreate_threads_after_action}) {
                    EDR::join_threads();
                    EDR::create_threads();
                } elsif ($task->{need_recreate_threads}) {
                    EDR::join_threads();
                } else {
                    # Synchronize the setq from sub threads to main threads.
                    $thr->sync_setq();
                }
            }
            $rc=$task->execute_rc_handler();
            $task->show_result_right($phase_desc,$rc) if (!$silent);
        }
    } else {
        # To call task action handler
        $task->show_desc_left($phase_desc) if (!$silent);
        $rc=$task->execute_action();
        $rc=$task->execute_rc_handler($rc);
        $task->show_result_right($phase_desc,$rc) if (!$silent);
    }

    $task->execute_post_action();
    return 1;
}

1;
