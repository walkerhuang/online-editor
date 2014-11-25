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
package EDR;
use strict;
use Cwd qw(abs_path);

sub init_env {
    my $edr=shift;
    my ($lang,$require_file);

    # Set LANG and LC_ALL environment variables for local system.
    $lang=$ENV{LC_ALL} || $ENV{LANG} || 'C';

    # Currently, only support zh and ja on Solaris Sparc
    $lang='C' if ($lang!~/^(zh|ja)/m);
    $edr->{envlang}=$lang;

    # Set language environment to 'C'.
    $ENV{LC_ALL}='C';
    $ENV{LANG}='C';
    Cfg->new();
    # handle '-require' option in the beginning.
    for my $n(0..$#ARGV) {
        next if ($ARGV[$n] ne '-require');
        $require_file=$ARGV[$n+1];
        $edr->process_require_arg($require_file);
    }

    return 1;
}

sub create_edr_objects {
    my $edr=shift;

    # create Thr object
    Thr->new() if (thread_support());

    Metrics->new();

    # create Padv objects
    for my $padv (@{$edr->{padvs}}) { "Padv\::$padv"->new() if ($padv ne 'Common'); }

    return '';
}

sub set_interrupt {
    my $edr=shift;
    $SIG{INT} = $SIG{TERM} = $SIG{ABRT} = \&deal_with_sigterm;
    return;
}

my $terminating :shared = 0;
sub deal_with_sigterm {
    my ($edr,$msg,$web);

    {
        lock $terminating;
        return if ($terminating==1);
        $terminating=1;
    }

    if (Obj::webui()) {
        $web = Obj::web();
        $web->{interrupted}=1;
    }

    $edr=Obj::edr();
    $edr->{not_display_summary_file}=1;

    Msg::n();
    $msg=Msg::new("Interrupt Received--$edr->{script} terminated\n");
    $msg->warning;
    $msg->add_summary(1);

    $edr->exit_exitfile(10);
}

sub is_terminating {
    return $terminating;
}

sub set_localsys {
    my ($edr,$hostname) = @_;
    my ($sys,$localsys);

    $localsys = $hostname || EDRu::nofqdn(`hostname`);
    $sys=$edr->{localsys}=Sys->new($localsys);
    $sys->{islocal}=1;
    $sys->{cleanup}=1;
    $sys->{plat}=$^O;
    $edr->padv_ipv_sys($sys);
    return '';
}

sub set_mediapath {
    my $edr=shift;
    my ($lcarg,$index,$mediapath,$msg);
    $index=0;
    for my $arg (@ARGV) {
        $lcarg=lc($arg);
        if ($lcarg eq '-mediapath') {
            $mediapath=$ARGV[$index+1];
            if (!defined $mediapath) {
                $msg=Msg::new("$arg requires a trailing definition argument");
                $msg->die;
            }
        }
        $index++;
    }

    my $web=Obj::web();
    if($web->{run_type} eq "vom_addon"){
        return;
    }

    $mediapath||=$edr->{mediapath};
    if ($mediapath) {
        if ($mediapath!~/^\//m) {
            $edr->{mediapath}=abs_path($edr->{scriptdir}."/$mediapath");
        } else {
            $mediapath=~s/^\/+/\//;
            $edr->{mediapath}=$mediapath;
        }
    }
    return;
}

# do whatever is necessary so that all message objects defined
# from this point on can be translated using vxgettext, if necessary
sub init_L10N {
    my $edr=shift;
    my ($padv_dir,$localsys,$localpadv,$lang);

    $lang=$edr->{envlang};

    $edr->{vx_bmcmnem}='EDR';
    $edr->{vx_bmcorigid}='9';

    if (-f "$edr->{scriptdir}/.cpi5") {
        # file marker to most effectively determine from disk installs
        $edr->{fromdisk}=1;
        $edr->{vx_bmcdomaindir}="/opt/VRTSperl/lib/site_perl/$edr->{release}";
    } else {
        $edr->{vx_bmcdomaindir}=$edr->{mediapath}.'/scripts';
    }

    $localsys=$edr->{localsys};
    $localpadv=$localsys->{padv};

    if ($localsys->linux()) {
        $padv_dir = 'linux';
        if ($localpadv=~/ppc64/m) {
            $padv_dir = 'linux_ppc64';
        }
    } elsif ($localsys->sunos()) {
        if ($localpadv=~/sparc/mi) {
            $padv_dir = 'sol_sparc';
            if (($edr->{fromdisk}) && ($lang =~ /(ja|zh)/mi)) {
                $localsys->cmd("_cmd_touch $edr->{scriptdir}/.cpi_running_l10n");
            } else {
                $localsys->cmd("_cmd_rmr $edr->{scriptdir}/.cpi_running_l10n");
            }
        } elsif ($localpadv=~/x64/m) {
            $padv_dir = 'sol_x64';
        }
    } elsif ($localsys->aix()) {
        $padv_dir = 'aix';
    }
    $edr->{vxgettext}="$edr->{vx_bmcdomaindir}/bin/$padv_dir/vxgettext" if ($padv_dir);

    EDRu::init_locale_encoding($edr);
    return '';
}

# translate some frequently used words
sub set_msgs {
    my ($edr,$msg);
    $edr=shift;

    $edr->{key}{'yes'}='y';
    $edr->{key}{'no'}='n';
    $edr->{key}{'back'}='b';
    $edr->{key}{'quit'}='q';
    $edr->{key}{'help'}='?';

    $msg=Msg::new("ERROR");
    $msg->msg('error');
    $msg=Msg::new("WARNING");
    $msg->msg('warning');
    $msg=Msg::new("NOTE");
    $msg->msg('note');
    $msg=Msg::new("CHECK");
    $msg->msg('check');
    $msg=Msg::new("ACTION");
    $msg->msg('action');
    $msg=Msg::new("System");
    $msg->msg('system');
    $edr->set_pkg_msgs();
    $edr->set_task_msgs();
    $msg=Msg::new("patch");
    $msg->msg('patch');
    $msg=Msg::new("patches");
    $msg->msg('patches');
    $msg=Msg::new("Back to previous menu");
    $msg->msg('menuback');
    $msg=Msg::new("Press [Enter] to continue:");
    $msg->msg('prtc');

    $edr->{msg}{'back'}='__back__';
    $edr->{msg}{'indent'}='    ';

    return '';
}

sub set_padv_msgs {
    my ($edr,$msg);
    $edr=shift;

    # defined using SORT padv abbreviations, not CPI
    # double-define if and when that's ever required
    $msg=Msg::new('AIX 5.3');
    $msg->msg('aix53');
    $msg=Msg::new('AIX 6.1');
    $msg->msg('aix61');
    $msg=Msg::new('AIX 7.1');
    $msg->msg('aix71');

    $msg=Msg::new('HP-UX 11.23');
    $msg->msg('hpux1123');
    $msg=Msg::new('HP-UX 11.31');
    $msg->msg('hpux1131');
    $msg=Msg::new('HP-UX 11.23 PA-RISC');
    $msg->msg('hpux1123par');
    $msg=Msg::new('HP-UX 11.31 PA-RISC');
    $msg->msg('hpux1131par');
    $msg=Msg::new('HP-UX 11.23 ia64');
    $msg->msg('hpux1123ia64');
    $msg=Msg::new('HP-UX 11.31 ia64');
    $msg->msg('hpux1131ia64');

    $msg=Msg::new('RHEL4 x86_64');
    $msg->msg('rhel4_x86_64');
    $msg=Msg::new('RHEL5 x86_64');
    $msg->msg('rhel5_x86_64');
    $msg=Msg::new('RHEL6 x86_64');
    $msg->msg('rhel6_x86_64');
    $msg=Msg::new('RHEL7 x86_64');
    $msg->msg('rhel7_x86_64');
    $msg=Msg::new('OL5 x86_64');
    $msg->msg('ol5_x86_64');
    $msg=Msg::new('OL6 x86_64');
    $msg->msg('ol6_x86_64');
    $msg=Msg::new('OL7 x86_64');
    $msg->msg('ol7_x86_64');
    $msg=Msg::new('SLES9 x86_64');
    $msg->msg('sles9_x86_64');
    $msg=Msg::new('SLES10 x86_64');
    $msg->msg('sles10_x86_64');
    $msg=Msg::new('SLES11 x86_64');
    $msg->msg('sles11_x86_64');
    $msg=Msg::new('SLES12 x86_64');
    $msg->msg('sles12_x86_64');

    $msg=Msg::new('Solaris 8 Sparc');
    $msg->msg('sol8_sparc');
    $msg=Msg::new('Solaris 9 Sparc');
    $msg->msg('sol9_sparc');
    $msg=Msg::new('Solaris 10 Sparc');
    $msg->msg('sol10_sparc');
    $msg=Msg::new('Solaris 11 Sparc');
    $msg->msg('sol11_sparc');
    $msg=Msg::new('Solaris 10 x64');
    $msg->msg('sol10_x64');
    $msg=Msg::new('Solaris 11 x64');
    $msg->msg('sol11_x64');

    # define NB padvs and Win, if and when that's necessary
    return '';
}

sub set_pkg_msgs {
    # Calling plat_sub here will default to localos and not plat()
    # Will eventually need to make this 2d for a real multi-plat train
    my ($edr,$msg,$padv);
    $edr=shift;
    $msg=Msg::new("Press [Enter] to continue:");
    $msg->msg('prtc');
    $padv=${$edr->{padvs}}[0];
    if ($padv && (EDRu::plat($padv) eq 'AIX')) {
        $edr->{msg}{pdfren}='fileset';
        $msg=Msg::new("fileset");
        $msg->msg('pdfr');
        $msg=Msg::new("filesets");
        $msg->msg('pdfrs');
    } elsif ($padv && (EDRu::plat($padv) eq 'HPUX')) {
        $edr->{msg}{pdfren}='depot';
        $msg=Msg::new("depot");
        $msg->msg('pdfr');
        $msg=Msg::new("depots");
        $msg->msg('pdfrs');
    } elsif ($padv && (EDRu::plat($padv) eq 'Linux')) {
        $edr->{msg}{pdfren}='rpm';
        $msg=Msg::new("rpm");
        $msg->msg('pdfr');
        $msg=Msg::new("rpms");
        $msg->msg('pdfrs');
        $msg=Msg::new("Press [Enter] to continue:");
        $msg->msg('prtc');
    } else {
        $edr->{msg}{pdfren}='package';
        $msg=Msg::new("package");
        $msg->msg('pdfr');
        $msg=Msg::new("packages");
        $msg->msg('pdfrs');
    }
    return '';
}

sub set_task_msgs {
    my ($edr,$msg);
    $edr=shift;
    $msg=Msg::new("install");
    $msg->msg('task_install');
    $msg=Msg::new("uninstall");
    $msg->msg('task_uninstall');
    $msg=Msg::new("configure");
    $msg->msg('task_configure');
    $msg=Msg::new("upgrade");
    $msg->msg('task_upgrade');
    $msg=Msg::new("stop");
    $msg->msg('task_stop');
    return '';
}

sub set_tput {
    my $edr=shift;
    my $web=Obj::web();
    if($web->{run_type} && $web->{run_type} eq "vom_addon"){
        return;
    }
    if (Cfg::opt('redirect')) {
        $edr->{tput}{bs}='';
        $edr->{tput}{be}='';
        $edr->{tput}{cs}='';
        $edr->{tput}{ed}='';
        $edr->{tput}{ss}='';
        $edr->{tput}{se}='';
        $edr->{tput}{us}='';
        $edr->{tput}{ue}='';
        $edr->{tput}{cl}='';
        $edr->{tput}{sc}='';
        $edr->{tput}{rc}='';
        $edr->{tput}{cuu1}='';
        $edr->{tput}{termx}=80;
        $edr->{tput}{termy} = (local_windows()) ? 0 : 24;
    } else {
        $edr->{tput}{bs}=`tput bold`;         # Bold face Start
        $edr->{tput}{be}=`tput sgr 0`;        # Bold face End
        $edr->{tput}{cs}=`tput clear`;        # Clear the Screen
        $edr->{tput}{ed}=`tput ed`;           # Clear to the display
        $edr->{tput}{ss}=`tput smso`;         # Standout face Start
        $edr->{tput}{se}=`tput rmso`;         # Standout face End
        $edr->{tput}{us}=`tput smul`;         # Underline face Start
        $edr->{tput}{ue}=`tput rmul`;         # Underline face End
        $edr->{tput}{cl}=`tput cub1`;         # cursor left
        $edr->{tput}{sc}=`tput sc`;           # save cursor pos
        $edr->{tput}{rc}=`tput rc`;           # restore cursor pos
        $edr->{tput}{cuu1}=`tput cuu 1`;      # move cursor up by 1 line
        $edr->{tput}{termx}=`tput cols`;      # number of columns
        $edr->{tput}{termy}=`tput lines`;     # number of rows
        chomp($edr->{tput}{termx});
        chomp($edr->{tput}{termy});
        $edr->{tput}{termy}||=24;
    }
    return;
}

# clears the progress status
sub set_progress_steps {
    my ($edr, $steps) = @_;

    $edr->{start} = time();
    $edr->{completed} = 0;
    $edr->{msglist} = '';
    if ($steps) {
        $edr->{steps} = $steps;
    }
    return;
}

sub init_args {
    my $edr=shift;
    my ($pdfrs,$arguments,$arg_def);

    $pdfrs=Msg::get('pdfrs');

    $edr->{arguments} = $arguments = {
        'args_def' => [ qw(mediapath require responsefile logpath tmppath uuid tunablesfile timeout) ],

        'args_opt' => [ qw(serial rsh debug nocleanup nometrics trace redirect rwe) ],

        # Those arguments have no specific entry here are considered as undocumented arguments.
        # Those arguments have specific entry here but without 'description' attribute are considered as undocumented arguments.
        # Those arguments have specific entry here and with 'undocumented' attribute are considered as undocumented arguments.

        # EDR definition args
        'mediapath' => {
            'handler' => \&EDR::process_mediapath_arg,
        },
        'responsefile' => {
            'option_description' => Msg::new("<response_file>"),
            'description' => Msg::new("The -responsefile option is used to perform automated installations or uninstallations using information stored in a file rather than prompting for information. <response_file> is the full path of the file that contains configuration definitions."),
            'handler' => \&EDR::process_responsefile_arg,
        },
        'logpath' => {
            'option_description' => Msg::new("<log_path>"),
            'description' => Msg::new("The -logpath option is used to select a directory other than $edr->{logpath} as the location where $edr->{script} log files, summary file, and response file are saved"),
        },
        'tmppath' => {
            'option_description' => Msg::new("<tmp_path>"),
            'description' => Msg::new("The -tmppath option is used to select a directory other than $edr->{tmppath} as the working directory for $edr->{script}. This destination is where initial logging is performed and where $pdfrs are copied on remote systems before installation."),
        },
        'tunablesfile' => {
            'option_description' => Msg::new("<tunables_file>"),
            'description' => Msg::new("The -tunablesfile option is used to specify a tunables file including tunable parameters to be set."),
            'handler' => \&EDR::process_tunablesfile_arg,
        },
        'timeout' => {
            'option_description' => Msg::new("<timeout_value>"),
            'description' => Msg::new("The -timeout option is used to specify the number of seconds that the script should wait for each command to complete before timing out.  Setting the -timeout option overrides the default value of 1200 seconds. Setting the -timeout option to 0 will prevent the script from timing out.  The -timeout option does not work with the -serial option"),
            'handler' => \&EDR::process_timeout_arg,
        },

        # EDR option args
        'require' => {
            'option_description' => Msg::new("<installer_patch_file>"),
            'description' => Msg::new("The -require option is used to specify a installer patch file"),
        },
        'serial' => {
            'description' => Msg::new("The -serial option is used to perform install, uninstall, start, and stop operations, typically performed simultaneously on all systems, in serial fashion."),
        },
        'rsh' => {
            'description' => Msg::new("The -rsh option is used to have the script use rsh and rcp for communication between the systems.  System communication using rsh and rcp is auto-detected by the script, so the -rsh option is only required when ssh and scp (default communication method) is also configured between the systems."),
        },
        'redirect' => {
            'description' => Msg::new("The -redirect option is used to have the script display progress details without the use of advanced display functionality so that the output can be redirected to a file"),
        },
    };

    # The arguments with args_global could be specified together with other arguments
    $arguments->{args_global} = $arguments->{args_opt};

    for my $arg (keys %{$arguments}) {
        $arg_def=$arguments->{$arg};
        if (ref($arg_def) eq 'HASH' &&
            defined $arg_def->{handler} &&
            !defined $arg_def->{handler_args}) {
            $arg_def->{handler_args} = [ $edr ];
        }
    }
    return 1;
}

# To handle additional arguments in require file
sub init_args2 {}

sub process_args {
    my ($edr,$args_hash,$preexec)=@_;
    my ($cfg,@args,@valid_args,$args_array,$arg,$arg_def,$lcarg);
    my (@tasks,$tasks,@options,$msg,$help,$err,$handler,$handler_args);

    # initialization
    @tasks=();
    @options=();
    @valid_args=();
    for my $opt (qw(args_task args_def args_opt)) {
        $args_array=$args_hash->{$opt};
        next unless (defined $args_array);
        for my $arg (@{$args_array}) {
            push @valid_args, $arg if (!EDRu::inarr($arg,@valid_args));
        }
    }

    # analyse arguments
    $cfg=Obj::cfg();
    @args=@ARGV;
    while(@args) {
        $arg=shift(@args);
        $lcarg=lc($arg);
        if (substr($lcarg,0,1) eq '-') {
            $lcarg=substr($lcarg,1,length($lcarg));

            if ($lcarg && ($lcarg eq 'h' || $lcarg eq 'help' || $lcarg eq '?')) {
                $help=1 if (!$preexec);
                next;
            }

            # check if valid argument
            if (!$lcarg || !EDRu::inarr($lcarg, @valid_args)) {
                next if ($preexec);
                $msg=Msg::new("$arg is not a valid $edr->{script} argument");
                $msg->warning;
                $err++;
                next;
            }

            if (EDRu::inarr($lcarg, @{$args_hash->{args_def}})) {
                if ($#args<0) {
                    $msg=Msg::new("$arg requires a trailing definition argument");
                    $msg->warning;
                    $err++;
                } else {
                    $cfg->{opt}{$lcarg}=shift(@args);
                    Msg::debug("Setting cfg->{opt}{$lcarg}=$cfg->{opt}{$lcarg}");
                }
            } else {
                if (EDRu::inarr($lcarg, @{$args_hash->{args_task}})) {
                    push(@tasks, $lcarg);
                }
                $cfg->{opt}{$lcarg}=1;
                Msg::debug("Setting cfg->{opt}{$lcarg}=1");
                if (!EDRu::inarr($lcarg, @{$args_hash->{args_global}})) {
                    push (@options, $lcarg);
                }
            }
        } else {
            # other arguments are therefore system names
            push(@{$cfg->{systems}}, $arg);
            Msg::debug("Adding $arg to system list");
        }
    }

    if (@tasks>1) {
        $tasks=join(' ',@tasks);
        $msg=Msg::new("The task options ($tasks) cannot be used together");
        $msg->warning;
        $err++;
    }

    $args_hash->{tasks}=[ @tasks ] if (@tasks>1);
    $args_hash->{options}=[ @options ] if (@options>1);

    # First process those arguments with high priority, and then print help usage.
    for my $arg (@{$args_hash->{args_high_priority}}) {
        $arg_def=$args_hash->{$arg};
        next unless (defined $arg_def);
        $handler=$arg_def->{handler};
        next unless (defined $handler);
        $handler_args=$arg_def->{handler_args};
        if (defined $handler_args) {
            $err+=&$handler(@{$handler_args},$args_hash);
        } else {
            $err+=&$handler($args_hash);
        }
    }

    if ($help) {
        Msg::n() if ($err);
        $edr->usage($args_hash);
    }

    for my $arg (@valid_args) {
        # Skip those high priority args
        next if (EDRu::inarr($arg, @{$args_hash->{args_high_priority}}));

        $arg_def=$args_hash->{$arg};
        next unless (defined $arg_def);
        $handler=$arg_def->{handler};
        next unless (defined $handler);
        if (defined $cfg->{opt}{$arg}) {
            $handler_args=$arg_def->{handler_args};
            if (defined $handler_args) {
                $err+=&$handler(@{$handler_args},$args_hash);
            } else {
                $err+=&$handler($args_hash);
            }
        }
    }

    if ($err) {
        Msg::n();
        $edr->usage($args_hash);
    }

    return 1;
}

sub usage {
    my ($edr,$args_hash)=@_;
    my ($args,@tmp_args,$msg,$arg_def,$option_desc,$arg_desc,$ref_argarray);
    my ($exitcode);

    $exitcode = defined($edr->{exitcode})? $edr->{exitcode} : EDR->EXITUNDEFINEDISSUE unless(defined($exitcode));
    $msg=Msg::new("Usage: $edr->{script} [ <system1> <system2>... ]");
    if ($edr->{script} eq "deploy_sfha") {
        $msg=Msg::new("Usage: $edr->{script}");
    }
    $msg->print;

    exit $exitcode unless (defined $args_hash);

    # Show task args
    @tmp_args=();
    for my $arg (@{$args_hash->{args_task}}) {
        $arg_def=$args_hash->{$arg};
        next if (!defined $arg_def || $arg_def->{undocumented});
        push @tmp_args, $arg;
    }
    if ($#tmp_args>=0) {
        $args=join(' | -', @tmp_args);
        $msg=Msg::new("\t[ -$args ]");
        $msg->print;
    }

    # Show definition args
    for my $arg (@{$args_hash->{args_def}}) {
        $arg_def=$args_hash->{$arg};
        next if (!defined $arg_def || $arg_def->{undocumented});
        $arg_desc=$arg_def->{description};
        next if (!defined $arg_desc);

        $option_desc=$arg_def->{option_description};
        if ($option_desc) {
            $option_desc=$option_desc->{msg} if (ref($option_desc) =~ m/^Msg/);
            $msg=Msg::new("\t[ -$arg $option_desc ]");
        } else {
            $msg=Msg::new("\t[ -$arg ]");
        }
        $msg->print;
    }

    # Show option args
    @tmp_args=();
    for my $arg (@{$args_hash->{args_opt}}) {
        $arg_def=$args_hash->{$arg};
        next if (!defined $arg_def || $arg_def->{undocumented});
        $arg_desc=$arg_def->{description};
        next if (!defined $arg_desc);

        push @tmp_args, $arg;
    }
    if ($#tmp_args>=0) {
        $args=join(' | -', @tmp_args);
        $msg=Msg::new("\t[ -$args ]");
        $msg->printn;
    }

    # Show detail help description for each argument
    $ref_argarray=EDRu::arruniq(@{$args_hash->{args_task}},
                                @{$args_hash->{args_def}},
                                @{$args_hash->{args_opt}});
    for my $arg (@{$ref_argarray}) {
        $arg_def=$args_hash->{$arg};
        next if (!defined $arg_def || $arg_def->{undocumented});
        $arg_desc=$arg_def->{description};
        next if (!defined $arg_desc);

        $arg_desc=$arg_desc->{msg} if (ref($arg_desc) =~ m/^Msg/);
        Msg::printn($arg_desc);
    }
    exit $exitcode;
}

sub merge_args {
    my ($edr,$args_hash,$new_hash)=@_;

    for my $arg (keys %{$new_hash}) {
        if ($arg eq 'args_def') {
            push @{$args_hash->{args_def}}, @{$new_hash->{args_def}};
        } elsif ($arg eq 'args_opt') {
            push @{$args_hash->{args_opt}}, @{$new_hash->{args_opt}};
        } elsif ($arg eq 'args_task') {
            push @{$args_hash->{args_task}}, @{$new_hash->{args_task}};
        } elsif ($arg eq 'args_global') {
            push @{$args_hash->{args_global}}, @{$new_hash->{args_global}};
        } else {
            $args_hash->{$arg}=$new_hash->{$arg};
        }
    }
    return $args_hash;
}

sub process_require_arg {
    my ($edr,$require_file)=@_;
    my ($msg,$eval_err);

    $require_file||=Cfg::opt('require');
    if ($require_file) {
        if (-f $require_file) {
            eval { require($require_file) };
            $eval_err=$@;
            if ($eval_err) {
                $eval_err =~ s/\\/\\\\/g;
                $msg=Msg::new("require file: $require_file not in correct Perl format\n\n$eval_err");
                $msg->error;
                exit 1;
            }
        } else {
            $msg=Msg::new("require file: $require_file not found");
            $msg->error;
            exit 1;
        }
    }
    return 0;
}

sub process_mediapath_arg {
    my $edr=shift;
    my ($msg,$mediapath);

    $mediapath=Cfg::opt('mediapath');
    if (!-d $mediapath) {
        $msg=Msg::new("Specified media path $mediapath directory does not exist");
        $msg->die;
    }
    return 0;
}

sub process_responsefile_arg {
    my $edr=shift;
    my ($cfg,$msg,$eval_err,$nargs,$opts,$responsefile,$unsupportedargs,@unsupportedargs,$idx,$unsptarg_num);

    $nargs=scalar(@ARGV);
    $cfg=Obj::cfg();
    $responsefile=$cfg->{opt}{responsefile};
    if ($responsefile) {
        if (!-f $responsefile) {
            $msg=Msg::new("responsefile file: $responsefile not found");
            $msg->die;
        }
        # if -responsefile is used, all definitions should be in the file
        # no conflicting arguments should be allowed at the command line
        # -responsefile can be used together with -require, -tunablesfile, -noipc or -ssh
        @unsupportedargs = ();
        $idx = 0;
        while ($idx<$nargs) {
            if (EDRu::inarr($ARGV[$idx],qw/-require -tunablesfile -responsefile/)) {
                $idx+=2;
            } elsif (EDRu::inarr($ARGV[$idx],qw/-noipc -ssh/)) {
                $idx++;
            } else {
                push @unsupportedargs, $ARGV[$idx] if (!EDRu::inarr($ARGV[$idx], @unsupportedargs));
                $idx++;
            }
        }
        $unsptarg_num = scalar(@unsupportedargs);
        if ($unsptarg_num) {
            $unsupportedargs=join("\n\t",@unsupportedargs);
            if ($unsptarg_num > 1) {
                $msg=Msg::new("-responsefile <response_file> cannot be used with the following arguments: \n\t$unsupportedargs\nThese $edr->{script} options must be defined within the response file");
            } else {
                $msg=Msg::new("-responsefile <response_file> cannot be used with the following argument: \n\t$unsupportedargs\nThis $edr->{script} option must be defined within the response file");
            }
            $msg->die;
        } else {
            our %CFG;
            our %TUN;
            eval { require($responsefile) };
            $eval_err=$@;
            if ($eval_err) {
                $eval_err =~ s/\\/\\\\/g;
                $eval_err =~ s/Compilation failed in require at.*$//;
                $msg=Msg::new("responsefile file: $responsefile not in correct Perl format\n\n$eval_err");
                $msg->die;
            }
            $opts=$cfg->{opt};
            %$cfg = (%$cfg, %CFG);
            # merging the hashes with the line above doesn't merge $cfg{opt} correctly
            for my $opt (keys %$opts) { $cfg->{opt}{$opt}=$$opts{$opt}; }

            for my $tun (keys %TUN) {
                $cfg->{tunable}{$tun}=$TUN{$tun};
            }
        }
    }
    return 0;
}

sub process_tunablesfile_arg {
    my $edr=shift;
    my ($cfg,$msg,$eval_err,$tunablesfile);

    $cfg=Obj::cfg();
    $tunablesfile=$cfg->{opt}{tunablesfile};
    if ($tunablesfile) {
        if (!-f $tunablesfile) {
            $msg=Msg::new("tunablesfile file: $tunablesfile not found");
            $msg->die;
        } else {
            our %TUN;
            eval { require($tunablesfile) };
            $eval_err=$@;
            if ($eval_err) {
                $eval_err =~ s/\\/\\\\/g;
                $eval_err =~ s/Compilation failed in require at.*$//;
                $msg=Msg::new("tunablesfile file: $tunablesfile not in correct Perl format\n\n$eval_err");
                $msg->die;
            }
            for my $tun (keys %TUN) {
                $cfg->{tunable}{$tun}=$TUN{$tun};
            }
        }
    }
    return 0;
}

sub process_timeout_arg {
    my $edr=shift;
    my ($msg,$timeout,$serial);

    $timeout=Cfg::opt('timeout');
    $serial=Cfg::opt('serial');
    if (defined $timeout) {
        if ($timeout!~/^\d+$/) {
            $msg=Msg::new("-timeout value must be an integer");
            $msg->die;
        }
        if ($serial) {
            $msg=Msg::new("The -timeout option does not work with the -serial option");
            $msg->die;
        }
        $edr->{timeout}=$timeout;
    }
    return 0;
}

sub create_local_tempdir {
    my $edr=shift;
    my (@lt,$cfg,$msg);
    $cfg=Obj::cfg();

    # set vars
    $edr->{tmppath}=$cfg->{opt}{tmppath} if ($cfg->{opt}{tmppath});
    $edr->{logpath}=$cfg->{opt}{logpath} if ($cfg->{opt}{logpath});
    if ($edr->{tmppath} eq $edr->{logpath}) {
       $msg=Msg::new("The -logpath and -tmppath directories must be different");
       $msg->die;
    }
    @lt=localtime;
    $edr->{uuid}=$cfg->{opt}{uuid} if ($cfg->{opt}{uuid});
    $edr->{uuid}||=EDRu::basename($edr->{scriptdir}) if ($cfg->{opt}{rwe});
    $edr->{uuid}||=sprintf('%d%02d%02d%02d%02d%3s',
        $lt[5]+1900, $lt[4]+1, $lt[3], $lt[2], $lt[1], EDRu::randomstr(3));
    $edr->{scriptid}="$edr->{script}-$edr->{uuid}";
    $edr->{scriptid}=~s/\.exe-/-/;
    $edr->{tmpdir}=$edr->{localsys}->path("$edr->{tmppath}/$edr->{scriptid}");
    $edr->{logdir}=$edr->{localsys}->path("$edr->{logpath}/$edr->{scriptid}");

    # check local file system access by writing to $edr->log
    $edr->create_log_directory($edr->{logdir}, $edr->{tmpdir});
    $edr->create_log_file();
    return '';
}

sub register_save_logfiles {
    shift if (ref($_[0]) eq 'EDR');
    EDR::set_value('save_logfiles', 'push', @_);
    return;
}

sub create_and_check_directory {
    my ($edr,$dir) = @_;
    my ($m,$msg,$localsys);
    $localsys=$edr->{localsys};

    $m=$localsys->mkdir($dir);
    if (!$m || !-d $dir) {
        $msg=Msg::new("Cannot create $dir directory on $localsys->{sys}");
        $msg->die();
    }
    # block non-root to access the log file
    $localsys->chmod($dir, '700');
    return;
}

sub create_log_directory {
    my ($edr,$logdir,$tmpdir) = @_;
    my ($m,$msg,$log,$localsys);
    $localsys=$edr->{localsys};

    #e3436544:check and create the path.
    $edr->create_and_check_directory($logdir);
    $edr->create_and_check_directory($tmpdir);

    # $edr->{tmpdir} is last so those values are retained
    $edr->{logfile}=$localsys->path("$tmpdir/$edr->{scriptid}.log");
    $edr->{summary}=$localsys->path("$tmpdir/$edr->{scriptid}.summary");
    $edr->{responsefile}=$localsys->path("$tmpdir/$edr->{scriptid}.response");
    $edr->{tunablesfile}=$localsys->path("$tmpdir/$edr->{scriptid}.tunables");
    $edr->{askfile}=$localsys->path("$tmpdir/$edr->{scriptid}.askfile");
    $edr->{memorydumpfile}=$localsys->path("$tmpdir/$edr->{scriptid}.json");
    $edr->{metricsdumpfile}=$localsys->path("$tmpdir/$edr->{scriptid}.metrics");
    $log=$edr->{logfile}.'0'; # all logs appended with thread
    $localsys->createfile($log);
    unless (-f $log) {
        $msg=Msg::new("Cannot write to $log on $localsys->{sys}");
        $msg->die();
    }

    register_save_logfiles("$edr->{scriptid}.log*",
                           "$edr->{scriptid}.summary",
                           "$edr->{scriptid}.response",
                           "$edr->{scriptid}.askfile",
                           "$edr->{scriptid}.json",
                           "$edr->{scriptid}.metrics",
                          );
    return '';
}

sub create_log_file {
    no warnings 'uninitialized';
    my $edr=shift;
    Msg::log("$edr->{tolog}");
    $edr->{tolog} = '';
    Msg::log("$edr->{script} Log:");
    Msg::log("mediapath=$edr->{mediapath}");
    Msg::log("ENV{VX_BMCDOMAINDIR}=$edr->{vx_bmcdomaindir}");
    Msg::log('ARGS='.join(' ',@ARGV));
    Msg::log("localsys=$edr->{localsys}{sys}");
    Msg::log("envlang=$edr->{envlang}");
    return '';
}

sub cli_display_copyright {
    my ($edr,$year) = @_;
    my ($msg);
    Msg::title();
    $year='2013';
    $msg=Msg::new("Copyright (c) $year Symantec Corporation. All rights reserved.  Symantec, the Symantec Logo are trademarks or registered trademarks of Symantec Corporation or its affiliates in the U.S. and other countries. Other names may be trademarks of their respective owners.\n");
    $msg->print;

    $msg=Msg::new("The Licensed Software and Documentation are deemed to be _Q_commercial computer software_Q_ and _Q_commercial computer software documentation_Q_ as defined in FAR Sections 12.212 and DFARS Section 227.7202.\n");
    $msg->print;

    $msg=Msg::new("Logs are being written to $edr->{tmpdir} while $edr->{script} is in progress.\n");
    $msg->print;
    sleep 3 if (!Cfg::opt('responsefile'));
    return '';
}


sub init_edr_objs {
    my $edr = EDR->new('UXRT62', 'RHEL6x8664');
    $edr->create_edr_objects();
    $edr->set_localsys();
    $edr->{tmpdir} = "/tmp/tmpdir";
}

sub init_sys_objs {
    my ($system,$reload) = @_;
    my $sys = Sys->new($system);
    my $edr = Obj::edr();
    if ($reload) {
        my $tmpdir ||= "/tmp/serialized_obj";
        EDR::cmd_local("_cmd_rmr $tmpdir");
    }
    if (EDR::load_sys($system)) {
        return;
    }   
    $sys->{padv}=$edr->{localsys}{padv};
    $sys->{plat}=$^O;
    $sys->set_value('padv', $sys->{padv});
    $sys->set_value('plat', $sys->{plat});
    my $tmppadv = $sys->{padv};
    my $islocal="Padv\::$tmppadv"->islocal_sys($sys);
    if ($islocal) {
        $sys->set_value('islocal', $islocal);
    }   
    my $ret = ($sys->{islocal}) ? $edr->local_unix_transport_sys($sys) :
    $edr->remote_unix_transport_sys($sys);
}

sub store_sys {
    my $sysname = shift;
    my $tmpdir ||= "/tmp/serialized_obj";
    if (-d $tmpdir) {
        EDRu::rmdir_local_nosys($tmpdir);
    }   
    EDRu::mkdir_local_nosys($tmpdir);
    my $class = "Sys::$sysname";
    if (!Obj->store($Obj::pool{$class}, "$tmpdir/$class")){
        print "failed to store $class in $tmpdir/$class\n";
        return;
    }   
}

sub load_sys {
    my $sysname = shift;
    my $tmpdir ||= "/tmp/serialized_obj";
    if (!-d $tmpdir) {
        return 0;
    }   

    if (!-f "$tmpdir/Sys::$sysname") {
        return 0;
    }

    for my $file (glob("$tmpdir/*")) {
        my $basename = EDRu::basename($file);
        if ($basename eq "Sys::$sysname") {
            my $var = Obj->load($file);
            if (!$var) {
                return 0;
            }   
            $Obj::pool{$basename} = $var;
            return 1;
        }
    }
    return 0;
}

1;
