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
package Obj;
use strict;
use Storable qw(lock_store lock_retrieve);

our %pool;

sub new {
    my (@vars) = @_;
    my $self = (ref($vars[0])=~/hash/mi) ? shift @vars : {};
    $self->{class}=shift @vars;
    $self->{pool} = ($self->{class} eq 'Sys') ? "Sys::$vars[0]" :
        ($self->{class} eq 'Task') ? "Task::$vars[0]" :
        ($self->{class} eq 'Phase') ? "Phase::$vars[0]" :
        ($self->{class} eq 'Timer') ? "Timer::$vars[0]" :
        ($self->{class} eq 'MYCPIC') ? "CPIC" : $self->{class};
    return $Obj::pool{$self->{pool}} if (defined($Obj::pool{$self->{pool}}));
    bless($self, $self->{class});
    $Obj::pool{$self->{pool}}=$self;
    $self->init(@vars);
    return $self;
}

sub init { }

sub pool {
    my $pool=shift;
    EDR::die("$pool object not defined") unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

#sub pool_keys { for my $key(sort keys(%Obj::pool)) { print "$key\n"; } }

sub cfg {
    EDR::die('Cfg object not defined') unless (defined($Obj::pool{Cfg}));
    return $Obj::pool{Cfg};
}

sub cpic {
    EDR::die('CPIC object not defined') unless (defined($Obj::pool{CPIC}));
    return $Obj::pool{CPIC};
}

sub edr {
    EDR::die ('EDR object not defined') unless (defined($Obj::pool{EDR}));
    return $Obj::pool{EDR};
}

sub deploy {
    EDR::die ('Deploy object not defined') unless (defined($Obj::pool{Deploy}));
    return $Obj::pool{Deploy};
}

sub thr {
    EDR::die('Thr object not defined') unless (defined($Obj::pool{Thr}));
    return $Obj::pool{Thr};
}

sub web {
    if (defined($Obj::pool{Web})) {
        return $Obj::pool{Web};
    }
    return Obj->new();
}

sub webui {
    if (defined($Obj::pool{Web})){
        return $Obj::pool{Web}{browserid};
    }
    return 0;
}

sub padv {
    my $padv=shift;
    $padv||=EDR::get('padv');
    $padv="Padv::$padv";
    EDR::die("No $padv padv object defined") unless ($Obj::pool{$padv});
    return $Obj::pool{$padv};
}

sub created {
    my $pool=join('::', @_);
    return ($Obj::pool{$pool}) ? 1 : '';
}

sub rel {
    my ($padv,$donotdie)= @_;
    $padv||=EDR::get('padv');
    my $rel=EDR::get('release');
    my $pool=join('::', 'Rel', $rel, $padv);
    EDR::die("No rel object defined for release $rel and padv $padv")
        unless ($donotdie || $Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub prod {
    my ($prod,$padv,$donotdie)= @_;
    $padv||=EDR::get('padv');
    EDR::die('Null prod passed to Obj::prod') if (!$prod);
    my $pool=join('::', 'Prod', $prod, $padv);
    EDR::die("No prod object defined for prod $prod and padv $padv")
        unless ($donotdie || $Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub pkg {
    my ($pkg,$padv,$donotdie)= @_;
    $padv||=EDR::get('padv');
    EDR::die('Null pkg passed to Obj::pkg') if (!$pkg);
    my $pool=join('::', 'Pkg', $pkg, $padv);
    EDR::die("No pkg object defined for pkg $pkg and padv $padv")
        unless($donotdie || $Obj::pool{$pool});
    return $Obj::pool{$pool};
}

# get all created package objects in pool
sub pkgs {
    my $padv = shift;
    $padv||=EDR::get('padv');
    my %pkgs=();
    for my $key(keys %Obj::pool){
        my $padvstr = $padv->{class};
        $padvstr =~ s/Padv:://;
        if($key =~ /^Pkg::\S+::$padvstr$/){
            $pkgs{$Obj::pool{$key}{pkg}} = $Obj::pool{$key};
        }
    }
    return \%pkgs;
}

sub patch {
    my ($patch,$padv,$donotdie)= @_;
    $padv||=EDR::get('padv');
    EDR::die('Null patch passed to Obj::patch') if (!$patch);
    my $pool=join('::', 'Patch', $patch, $padv);
    EDR::die("No patch object defined for patch $patch and padv $padv")
        unless ($donotdie || $Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub proc {
    my ($proc,$padv)= @_;
    $padv||=EDR::get('padv');
    EDR::die('Null proc passed to Obj::proc') if (!$proc);
    my $pool=join('::', 'Proc', $proc, $padv);
    EDR::die("No proc object defined for proc $proc and padv $padv")
        unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub mr {
    my ($mr,$padv,$donotdie)= @_;
    $padv||=EDR::get('padv');
    EDR::die('Null mr passed to Obj::mr') if (!$mr);
    my $pool=join('::', 'MR', $mr, $padv);
    EDR::die("No mr object defined for mr $mr and padv $padv")
        unless ($donotdie || $Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub hotfix {
    my ($hotfix,$padv,$donotdie)= @_;
    $padv||=EDR::get('padv');
    EDR::die('Null patch passed to Obj::hotfix') if (!$hotfix);
    my $pool=join('::', 'Hotfix', $hotfix, $padv);
    EDR::die("No patch object defined for patch $hotfix and padv $padv")
        unless ($donotdie || $Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub eeb {
    my ($eeb,$padv)=@_;
    $padv||=EDR::get("padv");
    EDR::die("Null eeb passed to Obj::eeb") if (!$eeb);
    my $pool=join("::", "EEB", $eeb, $padv);
    EDR::die("No eeb object defined for eeb $eeb and padv $padv")
        unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub sys {
    my $sys=shift;
    EDR::die('Null sys passed to Obj::sys') if (EDRu::isempty($sys));
    my $pool="Sys::$sys";
    EDR::die("No sys object defined for system $sys") unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub localsys {
    my $edr=$Obj::pool{EDR};
    EDR::die('localsys not defined') unless (defined($edr->{localsys}));
    return $edr->{localsys};
}

sub localsysname {
    my $edr=$Obj::pool{EDR};
    EDR::die('localsys not defined') unless (defined($edr->{localsys}));
    return $edr->{localsys}{sys};
}

sub localplat {
    my $edr=$Obj::pool{EDR};
    EDR::die('localsys not defined') unless (defined($edr->{localsys}));
    return $edr->{localsys}{plat};
}

sub localpadv {
    my $edr=$Obj::pool{EDR};
    EDR::die('localsys not defined') unless (defined($edr->{localsys}));
    return $edr->{localsys}{padv};
}

sub task {
    my $tname=shift;
    EDR::die('Null task name passed to Obj::task') if (!$tname);
    my $pool="Task::$tname";
    EDR::die("No Task object defined for task $tname") unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub phase {
    my $phname=shift;
    EDR::die('Null phase name passed to Obj::phase') if (!$phname);
    my $pool="Phase::$phname";
    EDR::die("No Phase object defined for phase $phname") unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub timer {
    my $tname=shift;
    EDR::die('Null timer name passed to Obj::timer') if (!$tname);
    my $pool="Timer::$tname";
    EDR::die("No Timer object defined for timer $tname") unless ($Obj::pool{$pool});
    return $Obj::pool{$pool};
}

sub browserid {
    return $Obj::pool{EDR}{cgi}{browserid} if (defined($Obj::pool{EDR}));
    return;
}

sub tid {
    my $tid = (defined($Obj::pool{Thr})) ? $Obj::pool{Thr}{tid} : '0';
    $tid='0' if ($tid eq '');
    return $tid;
}

sub common { return 1 if ($_[0]->{padv} eq 'Common'); return 0; }

sub path {
    my ($obj,$path)=@_;
    $path=~s/\/{2,}/\//g;
    $path=~s/\//\\/g if ($obj->{padv}=~/Win/);
    return $path;
}

# also used for sq and mq
# args are:
# ($pool,$key,$value) to set $obj->{key}=$value (scalar)
# ($pool,$key,"list",$a,$b,$c) to set $obj->{key}=[ $a,$b,$c ] (list)
# ($pool,$key,"push",$a) to push $a on @{$obj->{key}}
# $obj is $Obj::pool{$pool}, always set by passing $obj->{pool} in set_main_obj
# $key can be comma separated to set 2d, 3d, and 4d hashes
# or ("die", $msg) for instruction from thread to main to die
# push and list are keywords so scalar cannot be set to list/push as per current code
sub set_value {
    my ($pool,$key,@vars) = @_;
    my(@k,$action,$obj,$attrs,$value,$error);
    EDR::die("no $pool object") unless ($Obj::pool{$pool});
    $obj=$Obj::pool{$pool};
    if ($vars[0] && (($vars[0] eq 'push') || ($vars[0] eq 'list'))) {
        $action=shift @vars;
        $value=\@vars;
    } else {
        $value=shift @vars;
        #return if ($value eq "");
    }
    @k=EDRu::split_str(',', 0, $key);
    $attrs='{"' . join('"}{"', @k) . '"}';
    if ($action && $action eq 'push') {
        eval 'push(@{$obj->' . $attrs . '}, @$value)';
    } else {
        eval '$obj->' . $attrs . ' = $value';
    }
    $error=$@;
    EDR::die("Failed to call set_value for $obj $attrs: $error") if $error;
    return '';
}

sub reset_value {
    my ($obj,$key,$value)=@_;
    my (@k,$attrs);

    @k=EDRu::split_str(',', 0, $key);
    $attrs='{"' . join('"}{"', @k) . '"}';
    if (defined $value) {
        eval '$obj->' . $attrs . ' = $value';
    } else {
        eval 'delete $obj->' . $attrs;
    }
    return 1;
}

sub class_str {
    my $class=shift;
    if ($class) {
        $class=ref($class) if (ref($class));
        return $class.'::';
    }
    return '';
}

sub print_objects {
    my $tidtime=EDRu::tidtime();
    for my $key(sort keys (%Obj::pool)) {
        next unless (ref($Obj::pool{$key}));
        print "$tidtime Obj::pool{$key} $Obj::pool{$key}\n";
    }
    return;
}

# currently used by EDR or CPIC
# assumes a fail message is passed on each $sys->{$index} list
sub failures {
    my $obj=shift;
    my @fail;
    for my $index(@_) {
        for my $sys(@{$obj->{systems}}) {
            push(@fail, @{$sys->{$index}}) if ($sys->{$index});
        }
    }
    return \@fail;
}

sub print_padv {
    my $padv=shift;
    print "$padv->{class}\n".EDRu::hash2def($padv, 'padv')."\n";
    return;
}

sub print_padvs {
    my $edr=$Obj::pool{EDR};
    for my $padvs(@{$edr->{padvs}}) {
        my $padv=Obj::padv($padvs);
        $padv->print_padv;
    }
    return;
}

sub print_systems {
    my $edr=$Obj::pool{EDR};
    for my $sys($edr->{localsys}, @{$edr->{systems}}) { $sys->print; }
    return;
}

sub read_default_values {
    my ($obj,$file)=(@_);
    my ($key,$value);
    return unless (-f "$file");
    for my $line(split(/\n/,EDRu::readfile($file))) {
        next if ($line=~/^\s*#/ || $line!~/^\s*\S+\s*=\s*\S+/);
        $line=~s/["'\s]//g;
        ($key,$value)=split(/=/,$line,2);
        $obj->{default}->{"$key"}=$value;
    }
    return;
}

sub set_default_values {
    my ($obj,$file,@kvs)=(@_);
    while (@kvs) {
        my $key=shift(@kvs);
        my $value=shift(@kvs);
        $obj->{default}->{"$key"}=$value;
    }
    $obj->write_default_values($file);
    return;
}

sub write_default_values {
    my ($obj,$file)=(@_);
    my ($content);
    $content='';
    for my $key(keys%{$obj->{default}}) {
        $content.="$key=$obj->{default}->{\"$key\"}\n";
    }
    EDRu::writefile($content,$file) if ($content);
    return;
}

sub store {
    my ($obj, $ref_argv, $file) = @_;
    local $Storable::Deparse = 1;
    local $DB::deep = 500; #increase the debug stack depth when store objs

    if($ref_argv) {
        eval {Storable::lock_store $ref_argv, $file};
        if ($@) {
            return '';
        }
        return 1;
    }
    return '';
}

sub load {
    my ($obj, $file) = @_;
    my $argv;
    local $Storable::Eval = 1;

    eval {$argv = Storable::lock_retrieve $file};
    if ($@) {
        return '';
    }

    return $argv;
}

1;
