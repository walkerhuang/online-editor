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
package Transport::VOM;
use strict;
#use VRTS::Paths;
use File::Spec;
@Transport::VOM::ISA = qw(Transport);

# To support VOM xprtlc transportation
sub init_transport {
    my ($trans,$mh_padv)=@_;
    require VRTS::Paths;
    $trans->{cms_installdir} = VRTS::Paths::get_path("InstallDir");
    $trans->{cms_appdir} = VRTS::Paths::get_path("AppDir");

    if ($^O =~ /Win32/i) {
        $trans->{cms_xprtlc} = '"'.File::Spec->catdir ($trans->{cms_installdir},"bin", "xprtlc.exe").'"';
        $trans->{cms_mh_driver} = '"'.File::Spec->catdir ($trans->{cms_installdir},"bin", "mh_driver.pl").'"';
        $trans->{cms_perl} = '"'.File::Spec->catdir ($trans->{cms_installdir},"bin", "perl.exe").'"';
    } else {
        $trans->{cms_xprtlc} = File::Spec->catdir ($trans->{cms_installdir},"bin", "xprtlc");
        $trans->{cms_mh_driver} = File::Spec->catdir ($trans->{cms_installdir},"bin", "mh_driver.pl");
        $trans->{cms_perl} = File::Spec->catdir ($trans->{cms_installdir},"bin", "perl");
    }

    my $whitename = "cpi_remote_cmd";
    $trans->{whitename} = $whitename;

    my $remote_cmd_src = $trans->{cms_installdir};
    $remote_cmd_src =~ s/VRTSsfmh/Install/;
    $remote_cmd_src = File::Spec->catdir ($remote_cmd_src, "cpi_addon","admin","addon","file","cpi_cmd.pl");
    $trans->{remote_cmd_src} = $remote_cmd_src;
    my $remote_cmd_desc;
    if ($^O =~ /Win32/i) {
        $remote_cmd_desc = ($mh_padv eq "Win")? '$VARDIR\\cpi_cmd.pl' : '/var/opt/VRTSsfmh/cpi_cmd.pl';
    } else {
        $remote_cmd_desc = ($mh_padv eq "Win")? '\$VARDIR\/cpi_cmd.pl' : '/var/opt/VRTSsfmh/cpi_cmd.pl';
    }

    $trans->{remote_cmd_desc} = $remote_cmd_desc;

    my $whitelist_cmd = "/admin/cgi-bin/whitelist.pl";
    $trans->{whitelist_cmd} = $whitelist_cmd;

    my $push_file = "/admin/cgi-bin/push_file.pl";
    $trans->{push_file} = $push_file;

    $trans->{version} = "v1.0";

    $trans->{cmd_background} = 0;

    return 1;
}

# Check xprtlc connection on system
sub check_sys {
    my ($trans,$sys,$timeout)=@_;
    my ($cms_xprtlc,$localsys,$sysname,$error_no,$error_msg,$remote_cmd_desc,$remote_cmd_src,$whitelist,$whitejson,$remote_padv);
    my ($stdout,$stderr,$exitcode,$cmd);

    # check VOM binary
    $cms_xprtlc=$trans->{cms_xprtlc};
    my $test_xprtlc = $cms_xprtlc;
    $test_xprtlc =~ s/\"//g;
    if (!$test_xprtlc || !-f $test_xprtlc) {
        print "VOM binary path is not defined on local system.";
        return 0;
    }
    $sysname=$sys->{sys};
    $cmd =$cms_xprtlc
          .' -l https://'
          .$sysname
          .'/'
          .$trans->{whitelist_cmd}
          .'/list -u vxss:///sfm_admin';
    $localsys=EDR::get('localsys');
    $whitelist=$localsys->cmd($cmd);
    $whitejson = Web::json_to_obj($whitelist);
    if ( ref($whitejson) ne "ARRAY" ) {
        return 0;
    }
    foreach my $whitename (@$whitejson) {
        if ( $whitename->{cmdname} eq $trans->{whitename} ){
            ($stdout,$stderr,$exitcode,$cmd) = $trans->cmd_sys($sys,"CPIADDONVERSION");
            if ($exitcode eq "0" && $stdout eq $trans->{version}) {
#                $trans->init_MH_Dir($sys);
                return 1;
            } else {
                if($trans->update_cmd($sys)){
#                    $trans->init_MH_Dir($sys);
                    return 1;
                } else {
                    return 0;
                }
            }
        }
    }
    return $trans->setup_sys($sys,$timeout);
    return 0;
}

sub update_cmd {

    my ($trans,$sys,$timeout)=@_;
    my ($cms_xprtlc,$cmd,$sysname,$error_no,$error_msg,$remote_cmd_desc,$remote_cmd_src,$whitelist,$whitejson,$remote_padv,$localsys);

    # check VOM binary
    $cms_xprtlc=$trans->{cms_xprtlc};
    my $test_xprtlc = $cms_xprtlc;
    $test_xprtlc =~ s/\"//g;
    if (!$test_xprtlc || !-f $test_xprtlc) {
        print "VOM binary path is not defined on local system.";
        return 0;
    }
    $sysname=$sys->{sys};

    $remote_cmd_src=$trans->{remote_cmd_src};
    $remote_cmd_desc=$trans->{remote_cmd_desc};
    $cmd =$cms_xprtlc
          .' -l https://'
          . $sysname
          .'/'
          . $trans->{push_file}
          .' -f data=@'
          .$remote_cmd_src
          .' -d destfile='
          . $remote_cmd_desc
          .' -d force=1 -u vxss:///sfm_admin';
    $localsys=EDR::get('localsys');
    my $rtn = $localsys->cmd($cmd);
    return 1 if ( $rtn =~ /SUCCESS/ );
    return 0;
}

# Setup VOM connection between local system and the remote system
sub setup_sys {

    my ($trans,$sys,$timeout)=@_;
    my ($cms_xprtlc,$cmd,$sysname,$error_no,$error_msg,$remote_cmd_desc,$remote_cmd_src,$whitelist,$whitejson,$remote_padv,$localsys);

    # check VOM binary
    $cms_xprtlc=$trans->{cms_xprtlc};
    my $test_xprtlc = $cms_xprtlc;
    $test_xprtlc =~ s/\"//g;
    if (!$test_xprtlc || !-f $test_xprtlc) {
        print "VOM binary path is not defined on local system.";
        return 0;
    }
    $sysname=$sys->{sys};

    if ($^O =~ /Win32/i) {
        $remote_cmd_src='"'.$trans->{remote_cmd_src}.'"';
    } else {
        $remote_cmd_src=$trans->{remote_cmd_src};
    }

    $remote_cmd_desc=$trans->{remote_cmd_desc};
    $cmd =$cms_xprtlc
          .' -l https://'
          . $sysname
          .'/'
          . $trans->{push_file}
          .' -f data=@'
          .$remote_cmd_src
          .' -d destfile='
          . $remote_cmd_desc
          .' -d force=1 -d permission=755 -u vxss:///sfm_admin -d whitename='
          . $trans->{whitename};
    $localsys=EDR::get('localsys');
    my $rtn = $localsys->cmd($cmd);
    if ( $rtn =~ /SUCCESS/ ){
#        $trans->init_MH_Dir($sys);
        return 1;
    }
    return 0;
}

sub unsetup_sys {

    my ($trans,$sys,$timeout)=@_;
    my ($cms_xprtlc,$cmd,$sysname,$error_no,$error_msg,$remote_cmd_desc,$remote_cmd_src,$whitelist,$whitejson,$remote_padv,$localsys);

    # Check if the connection is already ready
    $sysname=$sys->{sys};
    # check VOM binary
    $cms_xprtlc=$trans->{cms_xprtlc};
    my $test_xprtlc = $cms_xprtlc;
    $test_xprtlc =~ s/\"//g;
    if (!$test_xprtlc || !-f $test_xprtlc) {
        print "VOM binary path is not defined on local system.";
        return 0;
    }

    $remote_cmd_desc=$trans->{remote_cmd_desc};
    if ( $sys->{padv} eq "Win" ) {
        $trans->cmd_sys($sys,"del /Q $remote_cmd_desc");
    } else {
        $trans->cmd_sys($sys,"rm -rf $remote_cmd_desc");
    }
    $cmd = $cms_xprtlc
          .' -l https://'
          .$sysname
          .'/'
          .$trans->{whitelist_cmd}
          .'/delete -u vxss:///sfm_admin -d argv=\"'
          .$trans->{whitename}
          .'\"';
    $localsys=EDR::get('localsys');
    my $rtn = $localsys->cmd($cmd);
    return 1 if ( $rtn =~ /SUCCESS/ );
    return 0;
}

sub cmd_sys {
    my ($trans,$sys,$cmd)=@_;
    my ($cms_xprtlc,$sysname,$localsys);
    my ($stdout,$stderr,$exitcode);

    $cms_xprtlc=$trans->{cms_xprtlc};

    $sysname=$sys->{sys};

    my $vom_prefix = $cms_xprtlc
      .' -l https://'
      . $sysname
      .'/'
      . $trans->{whitelist_cmd}
      . '/run -u vxss:///sfm_admin -d argv=[\"'
      .$trans->{whitename}
      .'\",\"';

    my $vom_suffix = '\"]';
    $cmd =~ s/2\>\/dev\/null//g;
    $cmd =~ s/2\>\s+\/dev\/null//g;
    $cmd =~ s/2\s+\>\/dev\/null//g;
    $cmd =~ s/2\s+\>\s+\/dev\/null//g;
    $cmd =~ s/([^A-Za-z0-9])/sprintf("%%%02X",ord($1))/seg;

#/opt/VRTSsfmh/bin/xprtlc -l https://$sys/admin/cgi-bin/whitelist.pl/run -u vxss:///sfm_admin -d argv=[\"cpi_remote_cmd\",\"\/bin\/uname\ -p\;date\;hostname\;who\"]
    $cmd = $vom_prefix . $cmd . $vom_suffix;
    if ($trans->{cmd_background}){
        exec_bg($cmd);
        $stdout = 'success';
        $stderr = '';
        $exitcode = 0;
        $trans->{cmd_background} = 0;
    } else {
        $localsys=EDR::get('localsys');
        my $rtn_out = $localsys->cmd($cmd);
        my $rtn_json = Web::json_to_obj($rtn_out);
        chomp($rtn_json->{RESULT}->{RESULT}->{out});
        chomp($rtn_json->{RESULT}->{RESULT}->{err});
        $stdout = $rtn_json->{RESULT}->{RESULT}->{out};
        $stderr = $rtn_json->{RESULT}->{RESULT}->{err};
        $exitcode = $rtn_json->{RESULT}->{RETURNCODE};
        if ($exitcode && $stderr){
            unless ($stderr=~/No such file or directory/){
                my $stderr_json = Web::json_to_obj($stderr);
                $stderr = $stderr_json->{out};
                $stderr =~ s/\%([A-Fa-f0-9]{2})/pack('C',hex($1))/seg;
                $exitcode = $stderr_json->{code}/256;
            }
        }
        chomp $stdout;
        chomp $stderr;
    }
    chomp $cmd;
    return ($stdout,$stderr,$exitcode,$cmd);
}

sub copy_to_sys {
    my ($trans,$sys_src,$file_src,$sys_dest,$file_dest) = @_;
    my ($cms_xprtlc,@rtn,$cmd);
    my ($tmpname,$fname,$ext,$filename,$returnval,$mh_appdirtmp,$mh_installdirtmp,$localsys);
    my ($stdout,$stderr,$exitcode,$exitcmd);
    $exitcode = "0";

    $cms_xprtlc=$trans->{cms_xprtlc};
    $tmpname = EDRu::randomstr(10);
    ( $fname, undef, $ext ) = File::Basename::fileparse($file_src);
    $filename = $ext ? "$fname.$ext" : $fname;
    if ($sys_src->{islocal}){
        if ( $sys_dest->{padv} eq "Win" ) {#/var/opt/VRTSsfmh
            $trans->init_MH_Dir($sys_dest) unless ($trans->{mh_appdir}->{$sys_dest->{sys}});
            $mh_appdirtmp = $trans->{mh_appdir}->{$sys_dest->{sys}}."\\".$tmpname;
            @rtn = $trans->cmd_sys( $sys_dest, "mkdir ".'"'.$mh_appdirtmp.'"');
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");

            if ($^O =~ /Win32/i) {
                $cmd = $cms_xprtlc
                       .' -l https://'
                       .$sys_dest->{sys}
                       .'/'
                       .$trans->{push_file}
                       .' -f data=@'
                       . $file_src
                       . ' -d destfile=$VARDIR'
                       .$tmpname
                       .'\\'
                       .$filename
                       .' -d force=1 -u vxss:///sfm_admin';
            } else {
                $cmd = $cms_xprtlc
                       .' -l https://'
                       .$sys_dest->{sys}
                       .'/'
                       .$trans->{push_file}
                       .' -f data=@'
                       . $file_src
                       . ' -d destfile=\$VARDIR\/'
                       .$tmpname
                       .'/'
                       .$filename
                       .' -d force=1 -u vxss:///sfm_admin';
            }
            $localsys=EDR::get('localsys');
            $returnval = $localsys->cmd($cmd);
#            return ("",$returnval,1,$cmd) unless ( $returnval =~ /SUCCESS/ );
            return 0 unless ( $returnval =~ /SUCCESS/ );

            @rtn = $trans->cmd_sys( $sys_dest,"move ".'"'."$mh_appdirtmp\\$filename".'"'." ".'"'.$file_dest.'"' );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");

            @rtn = $trans->cmd_sys( $sys_dest, "rd /q /s ".'"'.$mh_appdirtmp.'"' );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");
        } else {
            $trans->init_MH_Dir($sys_dest) unless ($trans->{mh_appdir}->{$sys_dest->{sys}});
            $mh_appdirtmp = $trans->{mh_appdir}->{$sys_dest->{sys}}."/".$tmpname;
            @rtn = $trans->cmd_sys( $sys_dest, "mkdir $mh_appdirtmp" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");
            $cmd = $cms_xprtlc
                   .' -l https://'
                   .$sys_dest->{sys}
                   .'/'
                   .$trans->{push_file}
                   .' -f data=@'
                   . $file_src
                   . ' -d destfile='
                   .$mh_appdirtmp
                   .'/'
                   .$filename
                   .' -d force=1 -u vxss:///sfm_admin';
            $localsys=EDR::get('localsys');
            $returnval = $localsys->cmd($cmd);
#            return ("",$returnval,1,$cmd) unless ( $returnval =~ /SUCCESS/ );
            return 0 unless ( $returnval =~ /SUCCESS/ );

            @rtn = $trans->cmd_sys( $sys_dest,"mv $mh_appdirtmp/$filename $file_dest" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");
            @rtn = $trans->cmd_sys( $sys_dest, "rm -rf $mh_appdirtmp" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");
        }
    } elsif ($sys_dest->{islocal}){
        if ($sys_src->{padv} eq "Win") {
            $trans->init_MH_Dir($sys_src) unless ($trans->{mh_installdir}->{$sys_src->{sys}});
            $mh_installdirtmp = $trans->{mh_installdir}->{$sys_src->{sys}}."\\web\\agent\\$tmpname\\";
            @rtn = $trans->cmd_sys( $sys_src, "mkdir ".'"'.$mh_installdirtmp.'"' );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");

            @rtn = $trans->cmd_sys( $sys_src, "copy $file_src ".'"'."$mh_installdirtmp\\$filename".'"'." /y" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");

            $cmd = $cms_xprtlc
                .' -l https://'
                .$sys_src->{sys}
                .'/agent/'
                .$tmpname
                .'/'
                .$filename
                .' >'
                .$file_dest;
            $localsys=EDR::get('localsys');
            $localsys->cmd($cmd);
            @rtn = $trans->cmd_sys( $sys_src, "rd /q /s ".'"'."$mh_installdirtmp\\$filename".'"');
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");
        } else {
            $trans->init_MH_Dir($sys_src) unless ($trans->{mh_installdir}->{$sys_src->{sys}});
            $mh_installdirtmp = $trans->{mh_installdir}->{$sys_src->{sys}}."/web/agent/$tmpname/";
            @rtn = $trans->cmd_sys( $sys_src, "mkdir $mh_installdirtmp" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");

            @rtn = $trans->cmd_sys( $sys_src, "cp $file_src $mh_installdirtmp/$filename" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");

            $cmd = $cms_xprtlc
                .' -l https://'
                .$sys_src->{sys}
                .'/agent/'
                .$tmpname
                .'/'
                .$filename
                .' >'
                .$file_dest;
            $localsys=EDR::get('localsys');
            $localsys->cmd($cmd);
            @rtn = $trans->cmd_sys( $sys_src, "rm -rf $mh_installdirtmp" );
            ($stdout,$stderr,$exitcode,$exitcmd) = check_rtn($stdout,$stderr,$exitcode,$exitcmd,@rtn);
#            return ($stdout,$stderr,$exitcode,$exitcmd) if ($exitcode eq "1");
            return 0 if ($exitcode eq "1");
        }
    }

#    return ($stdout,$stderr,$exitcode,$exitcmd);
    return 1;
}

sub init_MH_Dir {
    my ($trans,$sys) = @_;
    $trans->{mh_installdir}->{$sys->{sys}} = $trans->get_MH_InstallDir($sys);
    $trans->{mh_appdir}->{$sys->{sys}} = $trans->get_MH_AppDir($sys);
    return;
}

sub get_MH_InstallDir {
    my ($trans,$sys) = @_;
    my ($stdout,$stderr,$exitcode,$exitcmd) = $trans->cmd_sys($sys,"MHINSTALLDIR");
    if ($exitcode eq "1") {
        return 0;
    } else {
        return $stdout;
    }
}

sub get_MH_AppDir {
    my ($trans,$sys) = @_;
    my ($stdout,$stderr,$exitcode,$exitcmd) = $trans->cmd_sys($sys,"MHAPPDIR");
    if ($exitcode eq "1") {
        return 0;
    } else {
        return $stdout;
    }
}

sub init_vomstatus {
    my $web = Obj::web();
    my $vomstatus = {};
    $vomstatus->{req_id} = $web->{scriptid};
    $vomstatus->{operation} = $web->{task};
    $vomstatus->{addon_id} = $web->{vom_patch_id};
    return $vomstatus;
}

sub register_request {
    my ($trans)=@_;
    my ($cms_xprtlc,$cmd,$req_file, $req,$addons,$req_data,$web,$cfg,$localsys);
    $cfg = Obj::cfg();
    $web = Obj::web();
    $req = {};
    $req->{"Add-ons"} = [];
    $req->{Hosts} = [];

    $addons = {};
    $addons->{Req} = $web->{scriptid};
    $addons->{Id} = $web->{vom_patch_id};
    $addons->{Operation} = "install";
#    $addons->{Operation} = $web->{task};
    $addons->{Type} = "SORTUpdate";

    push(@{$req->{"Add-ons"}},$addons);
    foreach my $host (@{$web->{vom_systemlist}}){
        push(@{$req->{Hosts}},$host->{HostId});
    }

    $req_file = File::Spec->catdir ($trans->{cms_appdir},"addon-".EDRu::randomstr(8).".req");
    $req_data = Web::obj_to_json($req);
    EDRu::writefile($req_data,$req_file);


    # check VOM binary
    $cms_xprtlc=$trans->{cms_xprtlc};
    my $test_xprtlc = $cms_xprtlc;
    $test_xprtlc =~ s/\"//g;
    if (!$test_xprtlc || !-f $test_xprtlc) {
        print "VOM binary path is not defined on local system.";
        return 0;
    }
    $cmd = $cms_xprtlc
            .' -l https://localhost/admin/cgi-bin/vxdeploy.pl/addon/deploy -f add-on=@"'
            .$req_file
            .'"'
            .' -d type='
            .$addons->{Type};
    $localsys=EDR::get('localsys');
    my $rtn = $localsys->cmd($cmd);
    if (defined $req_file && -f $req_file){
        unlink ($req_file);
    }
    $trans->{registered_request} = 1;
    return 1;
    my $rtn_json = Web::json_to_obj($rtn);
    return 1 if($rtn_json->{RESULT}->{RETURNCODE} eq "0");

    return 0;
}

sub remove_garbage {
    my $val = shift;
    $val->{op_output} =~ s/'//g;
    $val->{op_output} =~ s/\\/\\\\\\\\/g;
    $val->{op_output} =~ s/"/\\"/g;

    $val->{op_error} =~ s/'//g;
    $val->{op_error} =~ s/\\/\\\\\\\\/g;
    $val->{op_error} =~ s/"/\\"/g;
    return;
}

sub update_status{
    my ($trans,$vomstatus)=@_;
    my ($cms_xprtlc,$cmd,$event_file,$localsys);
    my %event;
    my $ret = 0;
    unless ($trans->{registered_request}){
        $trans->register_request();
    }
    $event{events}->[0]->{data} = {
        id => $vomstatus->{req_id},
#        operation => $vomstatus->{operation},
        operation => "install",
        addon_id => $vomstatus->{addon_id},
        host => $vomstatus->{host},
        phase => $vomstatus->{phase},
        rc => $vomstatus->{rc},
        op_output => $vomstatus->{op_output},
        op_error => $vomstatus->{op_error}
    };

    remove_garbage($event{events}->[0]->{data});

    $event{events}->[0]->{topic} = "event.vrts.deployment.vxhostdeploy.pinstller.$vomstatus->{req_id}.update";
    my $data = Web::obj_to_json(\%event);

    $event_file = File::Spec->catdir ($trans->{cms_appdir},"event-".EDRu::randomstr(8));
    EDRu::writefile($data,$event_file);

    $cms_xprtlc=$trans->{cms_xprtlc};
    my $test_xprtlc = $cms_xprtlc;
    $test_xprtlc =~ s/\"//g;
    if (!$test_xprtlc || !-f $test_xprtlc) {
        print "VOM binary path is not defined on local system.";
        return 0;
    }
    $cmd = $cms_xprtlc
            .' -l https://localhost/agent/cgi-bin/event.pl/send -f events=@"'
            .$event_file
            .'"';
    $localsys=EDR::get('localsys');
    my $rtn = $localsys->cmd($cmd);
    if (defined $event_file && -f $event_file){
        unlink ($event_file);
    }
    return 1 if ( $rtn =~ /200 OK/ );
    return 0;
}

sub refresh_host {
    my $trans = shift;
    my $cmd = $trans->{cms_perl}." ".$trans->{cms_mh_driver}." --hidden --family HOST";
    my $localsys=EDR::get('localsys');
    my $rtn = $localsys->cmd($cmd);
}

sub exec_bg {
    my $cmd = shift;
    $ENV{MODE} = 1;
    execute_background($cmd, "");
}
sub check_rtn {
    my ($stdout,$stderr,$exitcode,$exitcmd,@rtn) = @_;
    if ($rtn[2] eq "1"){
        return @rtn;
    } elsif ($rtn[2] eq "2"){
        $stdout .= $rtn[0]."\n";
        $stderr .= $rtn[1]."\n";
        $exitcode = $rtn[2];
        $exitcmd .= $rtn[3]."\n";
    } elsif ($rtn[2] eq "3"){
        $stdout .= $rtn[0]."\n";
        $stderr .= $rtn[1]."\n";
        $exitcode = $rtn[2] if ($rtn[2] ne "2");
        $exitcmd .= $rtn[3]."\n";
    }
    return ($stdout,$stderr,$exitcode,$exitcmd);
}

sub execute_background {
    my $cmd = shift;
    my $cmd_exe = shift;
    my $ret = -1;
    my $error;

    if ($^O =~ /Win32/i){
        # For Windows, use Win32::Process::Create to launch the command
        # asynchronously
        require Win32::Process;

        my $child_proc;
        # CARP does not like assignments that used only once.
        no warnings 'once';
        # Save the current stdout, stderr and stdin
        # Redirect them to NUL before firing the command and then restore
        # them to their present values

        $error = open(SAVESTDIN, "<&STDIN") ;
        $error = open(STDIN, "<NUL");
        $error = open(SAVESTDOUT, ">&STDOUT") ;
        $error = open(STDOUT, ">NUL");
        $error = open(SAVESTDERR, ">&STDERR") ;
        $error = open(STDERR, ">NUL");

        $ret = Win32::Process::Create($child_proc, $cmd_exe, $cmd, 0,
                &Win32::Process::CREATE_NO_WINDOW , ".");
        close(STDIN);
        close(STDOUT);
        close(STDERR);
        $error = open(STDIN, "<&SAVESTDIN");
        $error = open(STDOUT, ">&SAVESTDOUT");
        $error = open(STDERR, ">&SAVESTDERR");

        if (($ret == 0) || (!defined($child_proc))) {
            # Couldn't launch the process
            VRTS::Logger::log('error', "execute_cmd: Failed to launch ".
                    "asynchonous command: [$cmd]");
            $ret = -1;
        } else {
            # Launched the process successfully
            $ret = 0; # To indicate success
        }
    } else {
        # On Unix, launch the command in background after redirecting its
        # stdout and stderr to /dev/null

        $cmd .= " >/dev/null 2>&1 &";
        system($cmd);
        $ret = $?;
    }

    return $ret;
}

sub pre_update_status {
    my ($trans,$phase,$output,$sys) = @_;
    my $web = Obj::web();
    my $edr=Obj::edr();
    my $systems=$edr->{systems};
    my $vomstatus = $trans->init_vomstatus();
    $web->{vomstatus} = $vomstatus;
    $web->{trans} = $trans;
    $vomstatus->{phase} = $phase;
    $vomstatus->{op_output}=$output;
    if($sys){
        $vomstatus->{host} = $web->{vom_hostidlist}->{$sys->{sys}};
        $trans->update_status($vomstatus);
        $web->{current_sys} = $sys;
    } else {
        for my $persys(@{$systems}) {
            $vomstatus->{op_output}=~s/#{SYS}/$persys->{sys}/g;
            $vomstatus->{host} =  $web->{vom_hostidlist}->{$persys->{sys}};
            $trans->update_status($vomstatus);
        }
    }

}

sub post_update_status {
    my ($trans,$phase,$output) = @_;
    my $web = Obj::web();
    my $edr=Obj::edr();
    my $systems=$edr->{systems};
    my $vomstatus = $trans->init_vomstatus();
    $web->{vomstatus} = $vomstatus;
    $web->{trans} = $trans;
    $vomstatus->{phase} = $phase;
    $vomstatus->{op_output}=$output;
    if($web->{current_sys}){
        $vomstatus->{host} = $web->{vom_hostidlist}->{$web->{current_sys}->{sys}};
        $trans->update_status($vomstatus);
        delete $web->{current_sys};
    } else {
        for my $persys(@{$systems}) {
            $vomstatus->{host} =  $web->{vom_hostidlist}->{$persys->{sys}};
            $trans->update_status($vomstatus);
        }
    }
}

sub complete_update_status {
    my $trans = shift;
    my $web = Obj::web();
    my $cfg = Obj::cfg();
    my $edr = Obj::edr();
    my $output;
    my $script_id = "$web->{prefix}$web->{scriptid}";
    my $summary = $web->get_logfile("$edr->{tmppath}/${script_id}/${script_id}.summary");
    my $test_summary = $summary;
    $test_summary =~ s/\\nCPI WARNING.*?\\n/\\n/mg;
    if ($test_summary =~ 'fail' || $web->{complete_failed}) {
        $output="Install did not complete successfully, details at $edr->{tmppath}/${script_id}/${script_id}.log0";
    } else {
        $output="Install completed successfully, details at $edr->{tmppath}/${script_id}/${script_id}.log0";
        $trans->refresh_host();
    }
    my $vomstatus = $trans->init_vomstatus();
    $web->{vomstatus} = $vomstatus;
    $web->{trans} = $trans;
    for my $sys(@{$cfg->{systems}}){
        $vomstatus->{host} = $web->{vom_hostidlist}->{$sys};
        $vomstatus->{phase} = "complete";
        $vomstatus->{op_output}=$output;
        $trans->update_status($vomstatus);
    }
}
1;
