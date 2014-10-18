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

package Proc::lmx61::Common;
@Proc::lmx61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='lmx';
    $proc->{name}='LMX';
    $proc->{desc}='Low Latency Transport Multiplexor';
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
    $conf =~ s/LMX_START\s*=\s*0/LMX_START=1/mx;
    $conf =~ s/LMX_STOP\s*=\s*0/LMX_STOP=1/mx;
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

sub disable_sys {
    my ($proc,$sys) = @_;
    my ($cfg,$file,$conf,$rootpath,$stat);
    $cfg = Obj::cfg();
    $rootpath = Cfg::opt('rootpath') || '';
    $file= $rootpath . $proc->{initconf};
    $conf=$sys->catfile($file);
    return 0 unless ($conf);
    $conf =~ s/LMX_START\s*=\s*1/LMX_START=0/mx;
    $conf =~ s/LMX_STOP\s*=\s*1/LMX_STOP=0/mx;
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

package Proc::lmx61::AIX;
@Proc::lmx61::AIX::ISA = qw(Proc::lmx61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/rc.d/rc2.d/S71lmx';
    $proc->{kernelfile}='/etc/methods/lmxext';
    $proc->{initconf}='/etc/default/lmx';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    my ($modid);
    $modid = $sys->cmd("$proc->{kernelfile} -status");
    if ($modid ne 'lmx: loaded') {
        $sys->cmd("$proc->{kernelfile} -start");
    }
    $sys->cmd("$proc->{controlfile} start");

    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($rtn, $modid);
    $sys->cmd("$proc->{controlfile} stop");

    $rtn = EDR::cmdexit();
    if (!$rtn) {
        $modid = $sys->cmd("$proc->{kernelfile} -status");
    if ($modid eq 'lmx: loaded') {
            Msg::log("Unloading lmx - $modid");
            $sys->cmd("$proc->{kernelfile} -stop");
    }
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $lmxconf = $sys->cmd("$proc->{kernelfile} -status");
    if ($lmxconf eq 'lmx: loaded') {
        return 1;
    }
    return 0;
}

package Proc::lmx61::HPUX;
@Proc::lmx61::HPUX::ISA = qw(Proc::lmx61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/lmx';
    $proc->{initconf}='/etc/rc.config.d/lmxconf';
    $proc->{devicefile}='/dev/lmx';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_kcmodule -b yes lmx=loaded");
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('/sbin/lmxconfig -U');
    $sys->cmd('_cmd_kcmodule lmx=unused');
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;

    my $lmxstate = $sys->cmd("_cmd_kcmodule -P state lmx | _cmd_awk  \'\{ print \$2\}\'");
    if ($lmxstate =~ 'loaded') {
        if ($state =~ /stop/m || $sys->exists($proc->{devicefile})) {
            return 1;
        }
    }
    return 0;
}

package Proc::lmx61::Linux;
@Proc::lmx61::Linux::ISA = qw(Proc::lmx61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/lmx';
    $proc->{initconf}='/etc/sysconfig/lmx';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($rtn,$modstr);

    $sys->cmd("$proc->{controlfile} stop");
    $rtn = EDR::cmdexit();
    if (!$rtn) {
        $modstr = $sys->cmd("_cmd_lsmod | _cmd_grep 'lmx'");
        if ($modstr =~ /lmx/m) {
            Msg::log('Unloading LMX');
            $sys->cmd('_cmd_rmmod lmx');
        } else {
            Msg::log('LMX already unloaded');
        }
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $lmxconf = $sys->cmd("_cmd_lsmod | _cmd_grep 'lmx'");
    if ($lmxconf) {
        return 1;
    }
    return 0;
}

package Proc::lmx61::SunOS;
@Proc::lmx61::SunOS::ISA = qw(Proc::lmx61::Common);

sub init_plat {
    my $proc = shift;
    $proc->{controlfile}='/etc/init.d/lmx';
    $proc->{smf_manifest}='/var/svc/manifest/system/dbac/lmx.xml';
    $proc->{initconf}='/etc/default/lmx';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    if($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm enable system/lmx');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} start");
    } else {
        return 0;
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($rtn, $modstr);

    if($sys->exists($proc->{smf_manifest})) {
        $sys->cmd('_cmd_svcadm disable -st system/lmx');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    } else {
        return 0;
    }

    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

1;
