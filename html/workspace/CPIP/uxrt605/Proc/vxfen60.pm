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
use strict;

package Proc::vxfen60::Common;
@Proc::vxfen60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vxfen';
    $proc->{name}='Veritas I/O Fencing';
    $proc->{desc}='Veritas I/O Fencing';
    # increase this time from 180 to 300, refer to e2806636
    $proc->{start_period}=300;
    $proc->{stop_period}=10;
    $proc->{fatal}=1;
    return;
}

sub prestop_sys {
    my ($proc,$sys) = @_;
    my ($vxfenversion,$output,$vxfencmd);
    return 1 unless (Cfg::opt('upgrade_kernelpkgs'));
    return '' unless ($proc->check_sys($sys,'start'));
    $output=$sys->cmd("_cmd_vxfenconfig -W 2>/dev/null | _cmd_grep 'Current Protocol Version'");
    $vxfenversion= $1 if ($output =~/Current Protocol Version\s+:\s+(\d+)/m);
    return '' unless (EDRu::isint($vxfenversion));
    #backup /etc/vxfenmode
    $output=$sys->cmd('_cmd_cat /etc/vxfenmode');
    if($output=~/vxfen_protocol_version/m){
        $output=~s/vxfen_protocol_version(.*)//mxg;
        $sys->writefile($output,'/etc/vxfenmode.rubak');
    } else {
        $sys->cmd('_cmd_cp -rf  /etc/vxfenmode /etc/vxfenmode.rubak');
        $vxfencmd="vxfen_protocol_version=$vxfenversion";
        $sys->appendfile($vxfencmd,'/etc/vxfenmode');
    }
    return 1;
}


sub parse_vxfenadm_output {
    my ($proc,$sys) = @_;
    my (%vxfen_configuration,$flag,@cmlist,$cm,@silist,$si,$nothing);

    my $vxfenadm_d=$sys->cmd('_cmd_vxfenadm -d 2>&1');
    if (EDR::cmdexit()) {
        $vxfen_configuration{cluster_member}{self_node_state}='error in using vxfenadm';
        return %vxfen_configuration;
    }
    $vxfenadm_d =~ m/Fencing Protocol Version: ([^\r\n]+)[\r\n]/;
    $vxfen_configuration{protocol_version}=$1;
    $vxfenadm_d =~ m/Fencing Mode: ([^\r\n]+)[\r\n]/;
    $vxfen_configuration{fencing_mode}=$1;
    if ($vxfenadm_d =~ m/Fencing .*? Disk Policy: ([^\r\n]+)[\r\n]/) {
        $vxfen_configuration{disk_policy}=$1;
    }
    if ($vxfenadm_d =~ m/Fencing Mechanism:\s*(\S+)\s*/) {
        $vxfen_configuration{mechanism}=$1;
    }
    ($nothing, $cm)=split(/Cluster Members:/m, $vxfenadm_d);
    ($cm, $nothing)=split(/RFSM/m, $cm);
    $cm=~s/^[\r\n]*//;  # remove newline chars from beginning
    $cm=~s/[\r\n]*$//;  # remove newline chars from end
    @cmlist=split(/[\r\n]+/, $cm);   # get entries
    $flag=0;    # track the '*' in Cluster Member list (* indicates the self node)
    for my $cm (@cmlist) {
        $flag=1 if $cm =~ m/\*/;
        if ($cm=~m/^[ \t\*]*(\d+) (\(.*\))[ \t]*/) {
            $vxfen_configuration{cluster_member}{node_name}{"$1"}=$2;
            if ($flag) {
                $vxfen_configuration{cluster_member}{self_node_id}=$1;
                $vxfen_configuration{cluster_member}{self_node_name}=$2;
                last;
            }
        }
    }
    ($nothing, $si)= split(/RFSM State Information:/m,$vxfenadm_d);
    $si=~s/^[\r\n]*//;  # remove newline chars from beginning
    $si=~s/[\r\n]*$//;  # remove newline chars from end
    @silist=split(/[\r\n]+/, $si);   # get entries
    for my $si (@silist) {
        if ($si=~m/^[ \t]*node\s+(\d+)\s+in\s+state\s+\d+\s+\((.*)\)[ \t]*/) {
            $vxfen_configuration{cluster_member}{node_state}{"$1"}=$2;
            $vxfen_configuration{cluster_member}{self_node_state}=$2 if ($vxfen_configuration{cluster_member}{self_node_id}==$1);
        }
    }
    return %vxfen_configuration;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $mod;
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("vxfen not loaded on sys $sys->{sys}");
        return 0;
    }
    my %vxfen_configs=$proc->parse_vxfenadm_output($sys);
    if ($state =~ /start/m) {
        # start phase
        if ( $vxfen_configs{cluster_member}{self_node_state} =~ /running/m ) {
            return 1;
        } else {
            return 0;
        }
    } else {
        # stop phase, vxfen is loaded
        return 1;
    }
}

sub dump_vxfen_parameters_sys {
    my ($proc,$sys,$msg)=@_;
    my ($loglines,$logmsg,$vxfen_logs);
    $loglines = 100;

    $vxfen_logs=$sys->cmd("_cmd_vxfendebug -p 2>/dev/null | _cmd_tail -$loglines");
    $vxfen_logs = "\n$vxfen_logs";
    $vxfen_logs =~ s/\n/\n\t(sys: $sys->{sys}) /g;
    $logmsg="VxFEN $msg on system $sys->{sys}, dumping debug information:\n";
    $logmsg.="(sys: $sys->{sys}) VxFEN Logs (last $loglines lines):\nBEGIN VxFEN LOG {\n$vxfen_logs\nEND VxFEN LOG }\n";
    Msg::log($logmsg);
    return;
}

sub enable_sys {
    my ($proc,$sys) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    return 1 if (($conf =~ /\nVXFEN_START\s*=\s*1/x) && ($conf =~ /\nVXFEN_STOP\s*=\s*1/x));
    $conf =~ s/VXFEN_START\s*=\s*0/VXFEN_START=1/mx;
    $conf =~ s/VXFEN_STOP\s*=\s*0/VXFEN_STOP=1/mx;
    $conf .= "\n" if ($conf !~ /\n$/);
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    return 1;
}

sub disable_sys {
    my ($proc,$sys) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    return 1 if (($conf =~ /\nVXFEN_START\s*=\s*0/x) && ($conf =~ /\nVXFEN_STOP\s*=\s*0/x));
    $conf =~ s/VXFEN_START\s*=\s*1/VXFEN_START=0/mx;
    $conf =~ s/VXFEN_STOP\s*=\s*1/VXFEN_STOP=0/mx;
    $conf .= "\n" if ($conf !~ /\n$/);
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    return 1;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} stop");
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

sub start_failed_sys {
    my ($proc,$sys)=@_;
    return $proc->dump_vxfen_parameters_sys($sys,'start failed');
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;
    return $proc->dump_vxfen_parameters_sys($sys,'stop failed');
}

sub check_service_sys {
    my ($proc,$sys)=@_;
    my ($conf);
    $conf = $sys->cmd("unset VXFEN_START VXFEN_STOP; . $proc->{initconf} 2>/dev/null ; set |_cmd_grep '^VXFEN_ST'|_cmd_grep -v BASH_EXECUTION_STRING");
    return 0 unless ($conf);
    if (($conf =~ /VXFEN_START=1/mx) && ($conf =~ /VXFEN_STOP=1/mx)){
        return 1;
    } else {
        return 0;
    }
}

package Proc::vxfen60::AIX;
@Proc::vxfen60::AIX::ISA = qw(Proc::vxfen60::Common);
sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S97vxfen';
    $proc->{driverfile}='/usr/lib/drivers/vxfen';
    $proc->{initconf}='/etc/default/vxfen';
    $proc->{kernelfile}='/etc/methods/vxfenext';
    return;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $mod;
    $mod=$sys->cmd("$proc->{kernelfile} -status");
    if ($mod !~ /vxfen: loaded/m) {
        Msg::log("vxfen not loaded on sys $sys->{sys}");
        return 0;
    }
    my %vxfen_configs=$proc->parse_vxfenadm_output($sys);
    if ($state =~ /start/m) {
        # start phase
        if ( $vxfen_configs{cluster_member}{self_node_state} =~ /running/m ) {
            return 1;
        } else {
            return 0;
        }
    } else {
        # stop phase, vxfen is loaded
        return 1;
    }
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{kernelfile} -start");
    $sys->cmd("$proc->{kernelfile} -start dvxfend");
    if ($sys->{rsh} eq 'rsh') {
        $sys->cmd("$proc->{controlfile} start 1>/dev/null");
    } else {
        $sys->cmd("$proc->{controlfile} start");
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} stop");
    $sys->cmd("$proc->{kernelfile} -stop");
    return 1;
}

package Proc::vxfen60::HPUX;
@Proc::vxfen60::HPUX::ISA = qw(Proc::vxfen60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/vxfen';
    $proc->{initconf}='/etc/rc.config.d/vxfenconf';
    return;
}

package Proc::vxfen60::Linux;
@Proc::vxfen60::Linux::ISA = qw(Proc::vxfen60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/vxfen';
    $proc->{initconf}='/etc/sysconfig/vxfen';
    return;
}

package Proc::vxfen60::SunOS;
@Proc::vxfen60::SunOS::ISA = qw(Proc::vxfen60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/vxfen';
    $proc->{smf_manifest}='/var/svc/manifest/system/vxfen.xml';
    $proc->{initconf}='/etc/default/vxfen';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vxfen');
        $sys->cmd('_cmd_svcadm enable system/vxfen');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} start");
    } else {
        return 0;
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vxfen');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    }
    sleep 5;
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

sub check_service_sys {
    my ($proc,$sys)=@_;
    my ($svcinfo_vxfen,$conf);
    if ($sys->exists($proc->{smf_manifest})) { # Solaris 10
        $svcinfo_vxfen = $sys->cmd("_cmd_svcs -l system/vxfen | _cmd_grep '^enabled' ");
        if ($svcinfo_vxfen =~ /true/m) {
            if ( $svcinfo_vxfen =~ /temporary/m) {
                return 0;
            } else {
                return 1;
            }
        } elsif ($svcinfo_vxfen =~ /false/m ) {
            if ( $svcinfo_vxfen =~ /temporary/m) {
                return 1;
            } else {
                return 0;
            }
        }
    } else { # Solaris 9
        $conf = $sys->cmd("unset VXFEN_START VXFEN_STOP; . $proc->{initconf} 2>/dev/null ; set |_cmd_grep '^VXFEN_ST'|_cmd_grep -v BASH_EXECUTION_STRING");
        return 0 unless ($conf);
        if (($conf =~ /VXFEN_START=1/mx) && ($conf =~ /VXFEN_STOP=1/mx)){
            return 1;
        } else {
            return 0;
        }
    }
}

sub disable_service_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable system/vxfen');
    }
    return 1;
}

package Proc::vxfen60::Sol11sparc;
@Proc::vxfen60::Sol11sparc::ISA = qw(Proc::vxfen60::SunOS);

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->cmd("/lib/svc/method/vxfen status 2>/dev/null|_cmd_grep 'running'");
    return 1 if ($rtn);
    return 0;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vxfen');
    } elsif ($sys->exsits($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    }
    return 0 if (EDR::cmdexit());
    return 1;
}

package Proc::vxfen60::Sol11x64;
@Proc::vxfen60::Sol11x64::ISA = qw(Proc::vxfen60::SunOS);

sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn = $sys->cmd("/lib/svc/method/vxfen status 2>/dev/null|_cmd_grep 'running'");
    return 1 if ($rtn);
    return 0;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vxfen');
    } elsif ($sys->exsits($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    }
    return 0 if (EDR::cmdexit());
    return 1;
}

1;
