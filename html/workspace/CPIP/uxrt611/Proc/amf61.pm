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

package Proc::amf61::Common;
@Proc::amf61::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='amf';
    $proc->{name}='amf name';
    $proc->{desc}='amf description';
    $proc->{start_period}=60;
    $proc->{stop_period}=10;
    $proc->{fatal}=1;
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
    $conf =~ s/AMF_START\s*=\s*0/AMF_START=1/mx;
    $conf =~ s/AMF_STOP\s*=\s*0/AMF_STOP=1/mx;
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
    $conf =~ s/AMF_START\s*=\s*1/AMF_START=0/mx;
    $conf =~ s/AMF_STOP\s*=\s*1/AMF_STOP=0/mx;
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

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my $rtn;
    if ($sys->exists($proc->{controlfile})) {
        $rtn=$sys->cmd("$proc->{controlfile} status 2>/dev/null");
        if ($rtn=~ /loaded and configured/m) {
            Msg::log("AMF configured on $sys->{sys}");
            return 1;
        } elsif ($rtn =~ /unloaded/m) {
            Msg::log("AMF not loaded on $sys->{sys}");
            return 0;
        } else {
            Msg::log("AMF loaded but not configured on $sys->{sys}");
            return 1 if ($state =~ /stop/m);
        }
    }
    return 0;
}

sub start_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} start");
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("$proc->{controlfile} stop");
    return 1;
}

sub stop_failed_sys {
    my ($proc,$sys)=@_;

    Msg::log("## ps -ef output for $proc->{proc}:\n\n");
    $sys->cmd('_cmd_ps -ef');
    return;
}

package Proc::amf61::AIX;
@Proc::amf61::AIX::ISA = qw(Proc::amf61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/amf.rc';
    $proc->{initconf}='/etc/default/amf';
    return;
}

# On AIX, '/etc/init.d/amf.rc stop' do not unload amf driver.
sub stop_sys {
    my ($proc,$sys)=@_;
    if ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    } else {
        $sys->cmd('_cmd_amfconfig -oU 2> /dev/null');
    }
    $sys->cmd('/etc/methods/amfext -stop');
    return 1;
}

package Proc::amf61::HPUX;
@Proc::amf61::HPUX::ISA = qw(Proc::amf61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/sbin/init.d/amf';
    $proc->{initconf}='/etc/rc.config.d/amf';
    return;
}

package Proc::amf61::Linux;
@Proc::amf61::Linux::ISA = qw(Proc::amf61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/amf';
    $proc->{initconf}='/etc/sysconfig/amf';
    return;
}

sub force_stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd("_cmd_rmmod amf");
    return 1;
}

package Proc::amf61::SunOS;
@Proc::amf61::SunOS::ISA = qw(Proc::amf61::Common);

sub init_plat {
    my $proc=shift;
    $proc->{controlfile}='/etc/init.d/amf';
    $proc->{smf_manifest}='/var/svc/manifest/system/amf.xml';
    $proc->{initconf}='/etc/default/amf';
    return;
}

sub start_sys {
    my ($proc,$sys)=@_;
    my $cmdoutput;
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/amf');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/amf');
        }
        $sys->cmd('_cmd_svcadm enable system/amf');
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} start");
    } else {
        $sys->padv->load_driver_sys($sys,$proc->{proc});
        $sys->cmd('_cmd_amfconfig -c 2> /dev/null');
    }
    return 1;
}

sub stop_sys {
    my ($proc,$sys)=@_;
    my ($cmdoutput);
    if($sys->exists($proc->{smf_manifest})) {
        $cmdoutput=$sys->cmd('_cmd_svcadm disable -st system/amf');
        if ($cmdoutput =~/maintenance/m) {
            $sys->cmd('_cmd_svcadm clear system/amf');
            $sys->cmd('_cmd_amfconfig -oU 2> /dev/null');
        }
    } elsif ($sys->exists($proc->{controlfile})) {
        $sys->cmd("$proc->{controlfile} stop");
    } else {
        $sys->cmd('_cmd_amfconfig -oU 2> /dev/null');
    }
    sleep 1;
    if ($sys->padv->driver_sys($sys,$proc->{proc})) {
        Msg::log('Unloading AMF driver');
        $sys->padv->unload_driver_sys($sys,$proc->{proc});
    }
    return 1;
}

sub check_sys {
    my ($proc,$sys,$state)=@_;
    my ($rtn,$mod);
    $mod=$sys->padv->driver_sys($sys,$proc->{proc});
    if ($mod eq '') {
        Msg::log("amf not loaded on sys $sys->{sys}");
        return 0;
    } else {
        Msg::log("amf loaded on sys $sys->{sys}");
    }
    $rtn=$sys->cmd("_cmd_amfconfig 2> /dev/null|_cmd_grep 'AMF is configured'");
    if ($rtn=~ /AMF is configured/m) {
        Msg::log("AMF configured on $sys->{sys}");
        return 1;
    } else {
        Msg::log("AMF loaded not configured on $sys->{sys}");
        # stopping, need to unload
        return 1 if ($state =~ /stop/m);
    }
    # starting, need to configure
    return 0;
}

1;
