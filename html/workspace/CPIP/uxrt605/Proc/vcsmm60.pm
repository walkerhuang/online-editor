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

package Proc::vcsmm60::Common;
@Proc::vcsmm60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='vcsmm';
    $proc->{name}='VCSMM';
    $proc->{desc}='vcsmm description';
    $proc->{fatal}=1;
    $proc->{start_period}=10;
    $proc->{stop_period}=10;
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
    $conf =~ s/VCSMM_START\s*=\s*0/VCSMM_START=1/mx;
    $conf =~ s/VCSMM_STOP\s*=\s*0/VCSMM_STOP=1/mx;
    $conf .= "\n";
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    return 1;
}

sub prestop_sys {
    my ($proc,$sys) = @_;
    my ($version,$output,$cmd);
    return 1 unless (Cfg::opt('upgrade_kernelpkgs'));
    $output=$sys->cmd("_cmd_vcsmmconfig -W | _cmd_grep 'Current Protocol Version'");
    $version= $1 if ($output =~/Current Protocol Version\s+:\s+(\d+)/m);
    $output=$sys->cmd('_cmd_cat /etc/vcsmmtab');
    return '' unless (EDRu::isint($version));
    #backup /etc/vxfenmode
    if ($output=~/vcsmm_protocol_version/m){
        $output=~s/vcsmm_protocol_version(.*)//mxg;
        $sys->writefile($output,'/etc/vcsmmtab.rubak');
    } else {
        $cmd="\nvcsmm_protocol_version=$version";
        $sys->cmd('_cmd_cp -rf /etc/vcsmmtab /etc/vcsmmtab.rubak');
        $sys->appendfile($cmd,'/etc/vcsmmtab');
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
    $conf =~ s/VCSMM_START\s*=\s*1/VCSMM_START=0/mx;
    $conf =~ s/VCSMM_STOP\s*=\s*1/VCSMM_STOP=0/mx;
    $conf .= "\n";
    $stat=$sys->filestat($file);
    $sys->movefile($file,"$file.prev");
    $sys->writefile($conf,$file);
    if ($sys->exists("$file")) {
        $sys->change_filestat($file,$stat);
        $sys->rm("$file.prev");
    }
    return 1;
}

package Proc::vcsmm60::AIX;
@Proc::vcsmm60::AIX::ISA = qw(Proc::vcsmm60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S98vcsmm';
    $proc->{kernelfile}='/etc/methods/vcsmmext';
    $proc->{initconf}='/etc/default/vcsmm';
    return;
}


sub start_sys {
    my ($proc,$sys)=@_;
    my $modid = $sys->cmd("$proc->{kernelfile} -status");
    if ($modid ne 'vcsmm: loaded') {
        $sys->cmd("$proc->{kernelfile} -start");
    }
    $sys->cmd("$proc->{controlfile} start");

    return 1 if (!EDR::cmdexit());
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($modid, $rtn);
    $sys->cmd("$proc->{controlfile} stop");

    $rtn = EDR::cmdexit();
    if (!$rtn) {
        $modid = $sys->cmd("$proc->{kernelfile} -status");
        if ($modid eq 'vcsmm: loaded') {
            Msg::log("Unloading VCSMM - $modid");
            $sys->cmd("$proc->{kernelfile} -stop");
        }
    }
    return 1 if (!EDR::cmdexit());
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $vcsmmconf = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o'");
    my $retry = 3;
    my $sleep = 10;
    while ( $retry > 0 && !$vcsmmconf) {
        $retry--;
        sleep $sleep;
        $vcsmmconf = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o'");
    }
    if ($vcsmmconf && !EDR::cmdexit()) {
        return 1;
    }
    return 0;
}

package Proc::vcsmm60::HPUX;
@Proc::vcsmm60::HPUX::ISA = qw(Proc::vcsmm60::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/vcsmm';
    $proc->{initconf}='/etc/rc.config.d/vcsmmconf';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1 if (!EDR::cmdexit());
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/vcsmmconfig -U');
    if ($sys->padv->driver_sys($sys, $proc->{proc})) {
        Msg::log('Unloading VCSMM driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }

    return 1 if (!EDR::cmdexit());
}

sub check_sys {
    my ($proc, $sys, $state) = @_;
    my ($pids, $mod, $retry, $sleep);

    $sleep = 10;
    $retry = 3;
    $mod = $sys->padv->driver_sys($sys, $proc->{proc});
    while ( $retry > 0 && $mod eq '') {
        $retry--;
        sleep $sleep;
        $mod = $sys->padv->driver_sys($sys, $proc->{proc});
    }
    if ($mod eq '') {
        Msg::log("VCSMM not loaded $sys->{sys}");

        return 0;
    }
    Msg::log("VCSMM loaded $sys->{sys}");

    if ($state =~ /start/m) {
        $pids = $sys->proc_pids('vcsmmd');
        $retry = 3;
        while ( $retry > 0 && $#$pids == -1 ) {
            $retry--;
            sleep $sleep;
            $pids = $sys->proc_pids('vcsmmd');
        }
        if ($#$pids == -1) {
            Msg::log("vcsmmd not running on $sys->{sys}");
            return 0;
        }
    }
    return 1;
}

package Proc::vcsmm60::Linux;
@Proc::vcsmm60::Linux::ISA = qw(Proc::vcsmm60::Common);
sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/vcsmm';
    $proc->{initconf}='/etc/sysconfig/vcsmm';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1 if (!EDR::cmdexit());
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($rtn);

    $sys->cmd("$proc->{controlfile} stop");
    $rtn = EDR::cmdexit();
    if (!$rtn) {
        if ($sys->padv->driver_sys($sys, $proc->{proc})) {
            Msg::log('Unloading VCSMM');
            $sys->padv->unload_driver_sys($sys, $proc->{proc});
        } else {
            Msg::log('VCSMM already unloaded');
        }
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($vcsmmconf, $modid, $retry, $sleep);

    $retry = 3;
    $sleep = 10;
    if ($state =~ /start/m) {
        $vcsmmconf = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o'");
        while ( $retry > 0 && !$vcsmmconf) {
            $retry --;
            sleep $sleep;
            $vcsmmconf = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o'");
        }
        return 1 if ($vcsmmconf && !EDR::cmdexit());
    } elsif ($state =~ /stop/m) {
        $modid = $sys->cmd("_cmd_lsmod | _cmd_grep 'vcsmm'");
        while ( $retry > 0 && $modid) {
            $retry--;
            sleep $sleep;
            $modid = $sys->cmd("_cmd_lsmod | _cmd_grep 'vcsmm'");
        }
        return 1 if ($modid && !EDR::cmdexit());
    }
    return 0;
}

package Proc::vcsmm60::SunOS;
@Proc::vcsmm60::SunOS::ISA = qw(Proc::vcsmm60::Common);

sub init_plat {
    my $proc = shift;
    $proc->{controlfile}='/etc/init.d/vcsmm';
    $proc->{smf_manifest}='/var/svc/manifest/system/dbac/vcsmm.xml';
    $proc->{initconf}='/etc/default/vcsmm';

    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    if($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm enable system/vcsmm');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} start");
    } else {
        return 0;
    }
    return 1 if (!EDR::cmdexit());
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($cmdoutput_unload);
    if($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/vcsmm');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    } else {
        return 0;
    }
    return 0 if (EDR::cmdexit());
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($vcsmm, $retry, $sleep, $node_num, $rtn);

    $retry = 3;
    $sleep = 10;
    if ($state =~ /start/m) {
        $vcsmm = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o'");
        while ( $retry > 0 && !$vcsmm) {
            $retry--;
            sleep $sleep;
            $vcsmm = $sys->cmd("_cmd_gabconfig -a 2>/dev/null | _cmd_grep 'Port o'");
        }
        return 1 if ($vcsmm && !EDR::cmdexit());
    } elsif ($state =~ /stop/m) {
        $node_num = $sys->cmd("/sbin/lltstat -N 2>/dev/null");
        $rtn = $sys->cmd("/sbin/vcsmmconfig -V 2>/dev/null| _cmd_grep '$node_num:'") unless (EDR::cmdexit());
        if ($rtn && !EDR::cmdexit()) {
            Msg::log("VCSMM configured on $sys->{sys}");
            return 1;
        } else {
            Msg::log("VCSMM loaded not configured on $sys->{sys}");
        }
    }
    return 0;
}

1;
