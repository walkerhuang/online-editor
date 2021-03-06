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
package Padv::SunOS;
use strict;
@Padv::SunOS::ISA = qw(Padv);

sub padvs { return [ qw(Sol8sparc Sol9sparc Sol10sparc Sol10x64 Sol11sparc Sol11x64) ]; }

sub init_plat {
    my ($padv)=@_;
    $padv->{plat}='SunOS';
    $padv->{pkgpath}='pkgs';
    $padv->{patchpath}='patches';

    # Define padvform specific commands
    $padv->{cmd}{adb}='/usr/bin/adb';
    $padv->{cmd}{adddrv}='/usr/sbin/add_drv';
    $padv->{cmd}{arch}='/usr/bin/arch';
    $padv->{cmd}{awk}='/usr/bin/awk';
    $padv->{cmd}{beadm}='/usr/sbin/beadm';
    $padv->{cmd}{bootadm}='/sbin/bootadm';
    $padv->{cmd}{cat}='/usr/bin/cat';
    $padv->{cmd}{chgrp}='/usr/bin/chgrp';
    $padv->{cmd}{chmod}='/usr/bin/chmod';
    $padv->{cmd}{chown}='/usr/bin/chown';
    $padv->{cmd}{chroot}='/usr/sbin/chroot';
    $padv->{cmd}{cp}='/usr/bin/cp';
    $padv->{cmd}{cpp}='/usr/bin/cp -P';
    $padv->{cmd}{cut}='/usr/bin/cut';
    $padv->{cmd}{dd}='/usr/bin/dd';
    $padv->{cmd}{dfk}='/usr/bin/df -kl';
    $padv->{cmd}{date}='/usr/bin/date';
    $padv->{cmd}{diff}='/usr/bin/diff';
    $padv->{cmd}{dirname}='/usr/bin/dirname';
    $padv->{cmd}{dladm}='/usr/sbin/dladm';
    $padv->{cmd}{du}='/usr/bin/du';
    $padv->{cmd}{echo}='/usr/bin/echo';
    $padv->{cmd}{egrep}='/usr/bin/egrep';
    $padv->{cmd}{find}='/usr/bin/find';
    $padv->{cmd}{fstyp}='/usr/sbin/fstyp';
    $padv->{cmd}{grep}='/usr/bin/grep';
    $padv->{cmd}{groups}='/usr/bin/groups';
    $padv->{cmd}{groupadd}='/usr/sbin/groupadd';
    $padv->{cmd}{groupdel}='/usr/sbin/groupdel';
    $padv->{cmd}{groupmod}='/usr/sbin/groupmod';
    $padv->{cmd}{gunzip}='/usr/bin/gunzip';
    $padv->{cmd}{head}='/usr/bin/head';
    $padv->{cmd}{hostname}='/usr/bin/hostname';
    $padv->{cmd}{id}='/usr/bin/id';
    $padv->{cmd}{ifconfig}='/usr/sbin/ifconfig';
    $padv->{cmd}{kill}='/usr/bin/kill';
    $padv->{cmd}{kstat}='/usr/bin/kstat';
    $padv->{cmd}{ldd}='/usr/bin/ldd';
    $padv->{cmd}{ln}='/usr/bin/ln';
    $padv->{cmd}{ls}='/usr/bin/ls';
    $padv->{cmd}{mdb}='/usr/bin/mdb';
    $padv->{cmd}{mkdir}='/usr/bin/mkdir';
    $padv->{cmd}{mkdirp}='/usr/bin/mkdir -p';
    $padv->{cmd}{modinfo}='/usr/sbin/modinfo';
    $padv->{cmd}{modunload}='/usr/sbin/modunload';
    $padv->{cmd}{modload}='/usr/sbin/modload';
    $padv->{cmd}{mount}='/usr/sbin/mount';
    $padv->{cmd}{mv}='/usr/bin/mv';
    $padv->{cmd}{ndd}='/usr/sbin/ndd';
    $padv->{cmd}{netstat}='/usr/bin/netstat';
    $padv->{cmd}{nm}='/usr/xpg4/bin/nm';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{nslookup}='/usr/sbin/nslookup';
    $padv->{cmd}{ntpdate}='/usr/sbin/ntpdate';
    $padv->{cmd}{openssl}='/usr/sfw/bin/openssl';
    $padv->{cmd}{patchadd}='/usr/sbin/patchadd';
    $padv->{cmd}{patchrm}='/usr/sbin/patchrm';
    $padv->{cmd}{pkgadd}='/usr/sbin/pkgadd';
    $padv->{cmd}{pkgchk}='/usr/sbin/pkgchk';
    $padv->{cmd}{pkgrm}='/usr/sbin/pkgrm';
    $padv->{cmd}{pkginfo}='/usr/bin/pkginfo';
    $padv->{cmd}{ping}='/usr/sbin/ping';
    $padv->{cmd}{ps}='/usr/bin/ps';
    $padv->{cmd}{rcp}='/usr/bin/rcp';
    $padv->{cmd}{rmdrv}='/usr/sbin/rem_drv';
    $padv->{cmd}{rm}='/usr/bin/rm';
    $padv->{cmd}{rmr}='/usr/bin/rm -rf';
    $padv->{cmd}{rmdir}='/usr/bin/rm -rf';
    $padv->{cmd}{route}='/usr/sbin/route';
    $padv->{cmd}{rsh}='/usr/bin/rsh';
    $padv->{cmd}{scp}='/usr/bin/scp';
    $padv->{cmd}{sh}='/usr/bin/sh';
    $padv->{cmd}{sleep}='/usr/bin/sleep';
    $padv->{cmd}{sed}='/usr/bin/sed';
    $padv->{cmd}{showrev}='/usr/bin/showrev';
    $padv->{cmd}{shutdown}='/usr/sbin/shutdown -y -i6 -g0';
    $padv->{cmd}{sort}='/usr/bin/sort';
    $padv->{cmd}{ssh}='/usr/bin/ssh';
    $padv->{cmd}{sshkeygen}='/usr/bin/ssh-keygen';
    $padv->{cmd}{sshkeyscan}='/usr/bin/ssh-keyscan';
    $padv->{cmd}{strings}='/usr/bin/strings';
    $padv->{cmd}{su}='/usr/bin/su';
    $padv->{cmd}{svcadm}='/usr/sbin/svcadm';
    $padv->{cmd}{svccfg}='/usr/sbin/svccfg';
    $padv->{cmd}{svcs}='/usr/bin/svcs';
    $padv->{cmd}{swap}='/usr/sbin/swap';
    $padv->{cmd}{tail}='/usr/bin/tail';
    $padv->{cmd}{tar}='/usr/bin/tar';
    $padv->{cmd}{tee}='/usr/bin/tee';
    $padv->{cmd}{touch}='/usr/bin/touch';
    $padv->{cmd}{tput}='/usr/bin/tput';
    $padv->{cmd}{tr}='/usr/bin/tr';
    $padv->{cmd}{uname}='/usr/bin/uname';
    $padv->{cmd}{uniq}='/usr/bin/uniq';
    $padv->{cmd}{useradd}='/usr/sbin/useradd';
    $padv->{cmd}{usermod}='/usr/sbin/usermod';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxkeyless}='/opt/VRTSvlic/bin/vxkeyless';
    $padv->{cmd}{vxlicrep}='/sbin/vxlicrep';
    $padv->{cmd}{vxlicinst}='/sbin/vxlicinst';
    $padv->{cmd}{vxtune}='/usr/sbin/vxtune';
    $padv->{cmd}{wc}='/usr/bin/wc';
    $padv->{cmd}{which}='/usr/bin/which';
    $padv->{cmd}{who}='/usr/bin/who';
    $padv->{cmd}{yes}='/usr/bin/yes';
    $padv->{cmd}{zoneadm}='/usr/sbin/zoneadm';
    $padv->{cmd}{hostid}='/usr/bin/hostid';
    $padv->{cmd}{prtconf}='/usr/sbin/prtconf';
    $padv->{cmd}{prtdiag}='/usr/sbin/prtdiag';
    $padv->{cmd}{isainfo}='/usr/bin/isainfo';
    $padv->{cmd}{nettr}='/etc/opt/SUNWconn/bin/nettr';
    $padv->{cmd}{getconf}='/usr/bin/getconf';
    $padv->{cmd}{zonename}='/usr/bin/zonename';
    $padv->{cmd}{smbios}='/usr/sbin/smbios';
    $padv->{cmd}{cksum}='/usr/bin/cksum';
    $padv->{cmd}{ipadm}='/usr/sbin/ipadm';
    return;
}

# this set of commands is executed during info_sys before the padv objects
# are created and therefore full command paths are required

sub arch_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('/usr/bin/uname -p');
}

sub platvers_sys {
    my ($padv,$sys,$vers)=@_;
    my ($rootpath,$msg,$platvers,$release,@f);
    $sys->set_value('local_platvers', $vers);
    return $vers unless Cfg::opt('rootpath');
    $rootpath=Cfg::opt('rootpath');
    if (!$sys->exists("$rootpath/etc/release")) {
        $msg=Msg::new("Cannot locate $rootpath/etc/release on $sys->{sys}. Ensure that $rootpath is an alternate root file system.");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    $release=$sys->cmd("_cmd_cat $rootpath/etc/release");
    if ($release =~ /Solaris\s+(\d+)/mx) {
        $platvers = $1;
    }
    return "5.$platvers";
}

sub padv_sys {
    my ($padv,$sys)=@_;
    my ($vers,$arch);
    $arch=$sys->{arch};
    $vers=$sys->{platvers};
    if ($arch=~/sparc/m) {
        if ((EDRu::compvers('5.11',$vers)==2) &&
            (EDR::get2('padv_unbounded','Sol11sparc'))) {
            $vers='5.11';
        }
        $arch='sparc';
    } elsif ($arch=~/i386/m) {
        if ((EDRu::compvers('5.11',$vers)==2) &&
            (EDR::get2('padv_unbounded','Sol11x64'))) {
            $vers='5.11';
        }
        $arch='x64';
    }
    # unsupported zone, this will eventually error
    $vers=~s/5\.//m;
    return "Sol$vers$arch";
}

sub fqdn_ip_sys {
    my ($padv,$sys)=@_;
    my ($fqdn,$nslookup,$ip,$cmd);
    $cmd = ($padv->localpadv=~/^Sol/m) ? '/usr/sbin/nslookup' :
                                         '/usr/bin/nslookup';
    $nslookup=EDR::cmd_local("$cmd -timeout=2 -retry=1 $sys->{sys}");
    for my $line (split(/\n/,$nslookup)) {
        $fqdn = $line if ($line =~ s/Name\W+//m);
        $ip = $line if ($fqdn && ($line =~ s/Address\W+//m));
        return ($fqdn,$ip) if ($fqdn && $ip);
    }
    return;
}

sub ipv4_sys {
    my ($padv,$sys)=@_;
    my $ifc4=$sys->cmd("/usr/sbin/ifconfig -a4 inet 2>/dev/null | /usr/bin/grep 'inet ' | /usr/bin/grep -v '127.0.0.1'");
    return ($ifc4 =~ m/inet \d+\.\d+\.\d+\.\d+/) ? 1 : 0;
}

sub ipv6_sys {
    my ($padv,$sys)=@_;
    my $ifc6=$sys->cmd("/usr/sbin/ifconfig -a6 inet6 2>/dev/null | /usr/bin/grep 'inet6 ' | /usr/bin/grep -v '::1'");
    return ($ifc6 && $ifc6 =~ m/inet6 /) ? 1 : 0;
}

sub create_adminfiles_sys {
    my ($padv,$sys,$nodeps)=@_;
    my $tmpdir=EDR::tmpdir();
    return if ($sys->{plat} ne 'SunOS');
    my $localsys=$padv->localsys;
    if ($nodeps) {
        if (!-f "$tmpdir/adminfile_nodeps") {
            EDRu::writefile("mail=\ninstance=overwrite\npartial=nocheck\nrunlevel=quit\nidepend=nocheck\nrdepend=nocheck\nspace=quit\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default\n","$tmpdir/adminfile_nodeps");
            EDRu::writefile("mail=\ninstance=unique\npartial=nocheck\nrunlevel=quit\nidepend=nocheck\nrdepend=nocheck\nspace=quit\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default\n","$tmpdir/adminfile_nodeps.unique");
        }
    } else {
        if (!-f "$tmpdir/adminfile_deps") {
            EDRu::writefile("mail=\ninstance=overwrite\npartial=nocheck\nrunlevel=quit\nidepend=quit\nrdepend=nocheck\nspace=quit\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default\n","$tmpdir/adminfile_deps");
            EDRu::writefile("mail=\ninstance=unique\npartial=nocheck\nrunlevel=quit\nidepend=quit\nrdepend=nocheck\nspace=quit\nsetuid=nocheck\nconflict=nocheck\naction=nocheck\nbasedir=default\n","$tmpdir/adminfile_deps.unique");
        }
    }
    if (!$sys->{islocal}) {
        if($nodeps){
            $localsys->copy_to_sys($sys,"$tmpdir/adminfile_nodeps","$tmpdir/adminfile");
            $localsys->copy_to_sys($sys,"$tmpdir/adminfile_nodeps.unique","$tmpdir/adminfile.unique");
        }else{
            $localsys->copy_to_sys($sys,"$tmpdir/adminfile_deps","$tmpdir/adminfile");
            $localsys->copy_to_sys($sys,"$tmpdir/adminfile_deps.unique","$tmpdir/adminfile.unique");
        }
    } else {
        if($nodeps){
            $sys->cmd("_cmd_cp -f $tmpdir/adminfile_nodeps $tmpdir/adminfile");
            $sys->cmd("_cmd_cp -f $tmpdir/adminfile_nodeps.unique $tmpdir/adminfile.unique");
        }else{
            $sys->cmd("_cmd_cp -f $tmpdir/adminfile_deps $tmpdir/adminfile");
            $sys->cmd("_cmd_cp -f $tmpdir/adminfile_deps.unique $tmpdir/adminfile.unique");
        }
    }
    return '';
}

sub cpu_sys {
    my ($padv,$sys)=@_;
    my (@cpus,$cpu,$id,$ret);

    @cpus = ();
    $cpu = {};
    $id = 0;

    $ret = $sys->cmd('/usr/sbin/psrinfo -v 2>/dev/null');
    for my $line (split(/\n+/,$ret)) {
        if ($line=~/^Status/) {
            if (defined $cpu->{STATUS}) {
                push(@cpus, $cpu);
                $cpu={};
            }
            $cpu->{NAME}=$id++;
        } elsif ($line =~ /^\s*([\w-]+) since \d+/mi) {
            $cpu->{STATUS} = $1;
        } elsif ($line =~ /the (\w+) processor.*at (\d+) mhz/mi) {
            $cpu->{TYPE} = $1;
            $cpu->{SPEED} = $2;
        }
    }
    push(@cpus, $cpu) if (defined $cpu->{STATUS});
    return \@cpus;
}

sub cpu_number_sys {
    my ($padv,$sys)=@_;

    my $ret = $sys->cmd('_cmd_uname -X 2>/dev/null | _cmd_grep NumCPU');
    $ret=~s/^NumCPU\s*=\s*//mx;
    $ret=~s/\s*$//m;

    return $ret;
}

sub cpu_speed_sys {
    my ($padv,$sys)=@_;
    my ($cpu_type,$ret,$cpu_speed);

    $ret = $sys->cmd('/usr/sbin/psrinfo -v 2>/dev/null');
    ($cpu_type, $cpu_speed) = ($ret =~ /the (\w+) processor.*at (\d+) mhz/mi);
    if ($cpu_speed) {
        $cpu_speed.=' MHz';
    }

    return $cpu_speed;
}

sub create_backup_snapshot_sys {
    my ($padv,$sys)=@_;
    my ($be_list,$active_be,$snapshot_name,$timestamp);

    $be_list=$sys->cmd("_cmd_beadm list -H 2>/dev/null");
    #"beadm list -H" lists all information of each BE and character N means active
    #vcs601;66706794-d280-6036-89e4-ad1487752798;N;/;2690618368;static;1352186763
    #vcs601-backup;3a8de86b-1daa-48d2-904f-9b36549afb0e;R;;9069321216;static;1352190444
    if($be_list=~/^([^;]*);[^;]*;N/m){
        $active_be=$1;
        if($active_be){
            $timestamp=EDRu::datetime();
            $snapshot_name=$active_be.'@SYMC-'.$timestamp;
            $sys->cmd("_cmd_beadm create $snapshot_name 2>/dev/null");
            return 1 if(EDR::cmdexit() eq "0");
            Msg::log("Cannot create backup snapshot $snapshot_name\n");
        }
    }
    return 0;
}

sub distro_sys { return 'SunOS'; }

# Check if the driver with specific version string is loaded
sub driver_sys {
    my ($padv,$sys,$driver,$version)=@_;
    my ($rtn,$loaded);
    if ($version) {
        $loaded=$sys->cmd("_cmd_modinfo | _cmd_grep -w $driver | _cmd_grep '$version'");
    } else {
        $loaded=$sys->cmd("_cmd_modinfo | _cmd_grep -w $driver");
    }

    return '' unless($loaded);

    $rtn='';
    for my $item (split(/\n/,$loaded)) {
        if ($item=~/^\s*(\d+) /m) {
            $rtn.="$1\n";
        }
    }
    chomp($rtn);
    return "$rtn";
}

# Returns a reference to an array holding the NICs connected to the default gateway/router
sub gatewaynics_sys {
    my ($padv,$sys)=@_;
    my (@nics,$mac1,@getmac_out,$systemnics,$do);
    $do=$sys->cmd("_cmd_route get default 2>/dev/null | _cmd_grep 'interface:' | _cmd_grep -v grep | _cmd_awk '{print \$2}' | _cmd_sort 2> /dev/null | _cmd_uniq 2> /dev/null");
    @nics=split(/\s+/m,$do);
    $systemnics=$padv->systemnics_sys($sys,1);
    for my $nic (@nics) {
        if ($nic =~ /vsw\d+/m) {
            # we have to find the physical NIC for this virtual NIC.
            if ($sys->{padv} =~ /^Sol11/m) {
                $do = $sys->cmd("/opt/VRTSllt/getmac /dev/net/$nic");
            } else {
                $do = $sys->cmd("/opt/VRTSllt/getmac /dev/$nic");
            }
            @getmac_out = split(/\s+/m,$do);
            $mac1 = $getmac_out[1];
            for my $nic2 (@$systemnics) {
                next if ($nic2 eq $nic);
                @getmac_out = ();
                if ($sys->{padv} =~ /^Sol11/m) {
                    $do = $sys->cmd("/opt/VRTSllt/getmac /dev/net/$nic2");
                } else {
                    $do = $sys->cmd("/opt/VRTSllt/getmac /dev/$nic2");
                }
                @getmac_out = split(/\s+/m,$do);
                if ($mac1 && ($mac1 eq $getmac_out[1])) {
                    push @nics, $nic2;
                }
            }
        }
    }
    return EDRu::arruniq(sort @nics);
}

# Determine the install path for 3 types of packages
#                                 local                    remote
#  1. directory pkg               dirname($pkg->{file})    EDR::tmpdir()
#  2. gzip directory pkg(.tar.gz) EDR::tmpdir()            EDR::tmpdir()
#  3. stream pkg(.pkg)            $pkg->{file}             EDR::tmpdir()/basename($pkg->{file})
#  4. IPS stream pkg(.p5p)        $pkg->{file}             EDR::tmpdir()/basename($pkg->{file})
#
# Determine the install path for 2 types of patches
#                                 local                    remote
#  1. directory patch             dirname($patch->{file})  EDR::tmpdir()
#  2. gzip dir patch(.tar.gz)     EDR::tmpdir()            EDR::tmpdir()
#
# Return the value used for patchadd and pkgadd
#
sub installpath_sys {
    my ($padv,$sys,$pkgpatch)=@_;
    my ($file,$basename,$tmpdir,$path);
    $file=$pkgpatch->{file};
    $basename=EDRu::basename($file);
    $tmpdir=EDR::tmpdir();
    if ($file=~/tar\.gz$/m) {
        return $tmpdir;
    }

    if ($sys->{islocal}) {
        $path=EDRu::dirname($file);
        $path=$file if ($file=~/\.(pkg|p5p)$/m);
    } else {
        $path=$tmpdir;
        $path="$tmpdir/$basename" if ($file=~/\.(pkg|p5p)$/m);
    }
    return $path;
}

# determine all IP's on $sys
sub ips_sys {
    my ($padv,$sys)=@_;
    my (@i,@ips,$ip);
    $ip=$sys->cmd("_cmd_ifconfig -a | _cmd_grep inet | _cmd_awk '{print \$2}'");
    @i=split(/\s+/m,$ip);
    for my $ip (@i) {
        push(@ips,$ip) if ((EDRu::isip($ip)) &&
            ($ip ne '0.0.0.0') && ($ip ne '127.0.0.1'));
    }
    return \@ips;
}

sub islocal_sys {
    my ($padv,$sys)=@_;
    my ($ifc4,$ip4,$ifc6,$localsys,$ping6,$ip6,$ping4);
    $localsys=$padv->localsys;
    if ($localsys->{ipv4}) {
        $ping4=EDR::cmd_local("_cmd_ping -a -A inet $sys->{sys} 3 2>&1 | _cmd_grep alive");
        (undef,$ip4,undef) = split(/[\(\)]/m,$ping4,3);
    }
    if ($localsys->{ipv6}) {
        $ping6=EDR::cmd_local("_cmd_ping -a -A inet6 $sys->{sys} 3 2>&1 | _cmd_grep alive");
        (undef,$ip6,undef) = split(/[\(\)]/m,$ping6,3);
    }
    $ifc4=EDR::cmd_local("_cmd_ifconfig -a4 | _cmd_grep 'inet $ip4 '")
        if (($ping4) && (EDRu::ip_is_ipv4($ip4)));
    $ifc6=EDR::cmd_local("_cmd_ifconfig -a6 | _cmd_grep 'inet6 $ip6/'")
        if (($ping6) && (EDRu::ip_is_ipv6($ip6)));

    return 1 if (($ifc4) or ($ifc6));
    return 0;
}

sub is_bonded_nic_sys {
    my ($padv,$sys,$nic) = @_;
    my ($bnics);
    if ($sys->{bondednics}){
        return EDRu::inarr($nic,@{$sys->{bondednics}});
    }
    ($bnics,undef)=$padv->bondednics_sys($sys);
    return EDRu::inarr($nic,@$bnics);
}

sub bondednics_sys {
    my ($padv,$sys)=@_;
    my (@snics,@keys,$nic,@bondednics,$do);

    if($sys->exists("$padv->{cmd}{dladm}")) {
        $do=$sys->cmd("_cmd_dladm show-aggr | _cmd_grep 'key:' | _cmd_awk '{print \$2}'");
        @keys=split(/\n/,$do);
        for my $aggr (@keys) {
            $nic="aggr$aggr";
            push(@bondednics,$nic);
        }
        $do=$sys->cmd("_cmd_dladm show-aggr | _cmd_grep -v 'address' | _cmd_awk '{print \$1}'");
        @snics=split(/\n/,$do);

    } elsif ($sys->exists("$padv->{cmd}{nettr}")){
            $do=$sys->cmd('_cmd_nettr -conf');
            #return 1 if($do=~/$nic/);
    }
    $sys->set_value('bondednics','push',@bondednics);
    return (\@bondednics,\@snics);
}

sub load_driver_sys {
    my ($padv,$sys,$driver)=@_;
    my $mn=$padv->driver_sys($sys, $driver);
    $sys->cmd("_cmd_modload -p drv/$driver") if ($mn eq '');
    return '';
}

sub installcommand_precheck_sys {
    my ($padv,$sys)=@_;
    my ($lockfile,$msg,$pids);

    $lockfile = '/var/sadm/patch/.patchaddLock';
    if ($sys->exists($lockfile)) {
        $pids = $sys->proc_pids('patchadd');
        if ($#$pids != -1) {
            # another patchadd instance is running
            $msg = Msg::new("File $lockfile is found on $sys->{sys}. Make sure only one instance of patchadd is running at any time on $sys->{sys}.");
            $sys->push_warning($msg);
        } else {
            # stale .patchaddLock file
            $msg = Msg::new("File $lockfile is found on $sys->{sys}. It may have been left on $sys->{sys} due to a previous patchadd failure. Resolve the issue and then remove $lockfile before proceeding. Make sure only one instance of patchadd is running at any time on $sys->{sys}.");
            $sys->push_error($msg);
        }
    }
    return;
}

sub media_patch_file {
    my ($padv,$patch,$patchdir)=@_;
    my $file=EDR::cmd_local("_cmd_ls $patchdir | _cmd_grep '^$patch->{patchname}'");
    return "$patchdir/$file" if ($file);
    return '';
}

sub media_patch_version {
    my ($padv,$patch)=@_;
    my (undef,$vers,undef)=split(/\D/m,EDRu::basename($patch->{file}),3);
    return $vers;
}

sub media_pkg_file {
    my ($padv,$pkg,$pkgdir)=@_;
    return '' unless ($pkgdir);
    for my $file ("$pkgdir/$pkg->{pkg}.tar.gz",
                  "$pkgdir/$pkg->{pkg}.pkg",
                  "$pkgdir/$pkg->{pkg}.p5p",
                  "$pkgdir/$pkg->{pkg}") {
        return $file if (-e $file);
    }
    return '';
}

sub media_pkg_version {
    my ($padv,$pkg)=@_;
    my $vers=$padv->media_pkginfovalue($pkg,'VERSION');
    return $padv->pkg_version_cleanup($vers);
}

# try to use $pkg->{vers} to determine version instead of this subroutine
# get information from the pkginfo file for $pkg
sub media_pkginfovalue {
    my ($padv,$pkg,$param)=@_;
    my ($pkgdir,$file,$av,$value);
    $param.='=';
    return '' if (!$pkg->{file});
    $pkgdir=EDRu::dirname($pkg->{file});
    $av='-a' if ($padv->localplat eq 'Linux');
    $value = (-f "$pkgdir/$pkg->{pkg}/pkginfo") ?
        EDR::cmd_local("_cmd_grep '^$param' $pkgdir/$pkg->{pkg}/pkginfo") :
        (-f "$pkgdir/info/$pkg->{pkg}") ?
        EDR::cmd_local("_cmd_grep '^$param' $pkgdir/info/$pkg->{pkg}") :
        (-f "$pkgdir/$pkg->{pkg}.pkg") ?
        EDR::cmd_local("_cmd_head -50 $pkgdir/$pkg->{pkg}.pkg | _cmd_grep $av '^$param'") : '';
    $value =~ s/\n.*$//s;
    $value =~ s/($param)//m;
    return "$value";
}

sub memory_size_sys {
    my ($padv, $sys)=@_;

    my $ret = $sys->cmd("_cmd_prtconf 2>/dev/null | _cmd_grep '^Memory size:'");
    $ret =~ s/^Memory size:\s*//m;
    $ret =~ s/\s*$//m;
    return $ret;
}

sub minorversion_sys {
    my ($padv,$sys)=@_;
    my ($osupdatelevel,@platvers,$arch,$osversion);

    $osupdatelevel=$padv->osupdatelevel_sys($sys);
    if ($osupdatelevel) {
        $sys->set_value('osupdatelevel', $osupdatelevel);

        @platvers = split(/\./, $sys->{platvers});
        $arch = $sys->{arch};

        $osversion="Solaris $platvers[1] Update $osupdatelevel $arch";
        $sys->set_value('osversion', $osversion);
    }

    return 1;
}

# determine the netmask of the base IP configured on a NIC
sub netmask_sys {
    my ($padv,$sys,$nic,$ipv,$ip)=@_;
    my ($alias,$nm,$na);

    $na=$sys->cmd("_cmd_ifconfig -a | _cmd_grep '^$nic'");
    return '' if (!$na);

    # first check if the nic is actually plumbed.  It better be for anything
    # using it to work, but a user could still enter a dead one for testing
    # When both version available, use IPv4 prior to IPv6
    $ipv= '4' if (!defined $ipv || $ipv eq '');

    if ($ipv eq '4' and $sys->{ipv4}) {
        if ($ip) {
            $alias=$sys->cmd("_cmd_netstat -i -I $nic -an -f inet 2>/dev/null | _cmd_grep $ip|_cmd_head -n 1| _cmd_awk '{print \$1}'");
            chomp $alias;
            if ($alias) {
                $nm=$sys->cmd("_cmd_ifconfig $alias 2>/dev/null | _cmd_grep netmask");
                if ($nm=~/netmask\s+(\S*)/mx) {
                    $nm=$1;
                }
            } else {
                $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep netmask");
                if ($nm=~/netmask\s+(\S*)/mx) {
                    $nm=$1;
                }
            }
        } else {
            $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep netmask");
            if ($nm=~/netmask\s+(\S*)/mx) {
                $nm=$1;
            }
        }
    } elsif ($ipv eq '6' and $sys->{ipv6}) {
        if ($ip) {
            $alias=$sys->cmd("_cmd_netstat -i -I $nic -an -f inet6 2>/dev/null | _cmd_grep $ip|_cmd_head -n 1| _cmd_awk '{print \$1}'");
            chomp $alias;
            if ($alias) {
                $nm=$sys->cmd("_cmd_ifconfig $alias inet6 2>/dev/null | _cmd_grep 'inet6'");
                if ($nm=~ m/inet6\s+[0-9a-zA-Z:]*\/(\d+)/) {
                    $nm=$1;
                }
            } else {
                $nm=$sys->cmd("_cmd_ifconfig $nic inet6 2>/dev/null | _cmd_grep 'inet6'");
                if ($nm=~ m/inet6\s+[0-9a-zA-Z:]*\/(\d+)/) {
                    $nm=$1;
                }
            }
        } else {
            $nm=$sys->cmd("_cmd_ifconfig $nic inet6 2>/dev/null | _cmd_grep 'inet6'");
            if ($nm=~ m/inet6\s+[0-9a-zA-Z:]*\/(\d+)/) {
                $nm=$1;
            }
        }
    }
    return ($nm || '');
}

sub niccheck_sys {
    my ($padv,$sys,$nic)=@_;
    my (@keys,$do);
    if($sys->exists("$padv->{cmd}{dladm}")) {
        $do=$sys->cmd("_cmd_dladm show-aggr | _cmd_awk '/key:/ {print \$2}'");
        @keys=split(/\n/,$do);
        for my $aggr (@keys) {
            return 1 if("aggr$aggr" eq $nic);
        }
    } elsif ($sys->exists("$padv->{cmd}{nettr}")){
            $do=$sys->cmd('_cmd_nettr -conf');
            return 1 if($do=~/$nic/m);
    }
    return 0;
}

# determin ip on $nic
sub nic_ips_sys {
    my ($padv,$sys,$nic)=@_;
    my (@fields,@ips,$do,@ip_lines);
    @ips=();
    $do=$sys->cmd('_cmd_netstat -ian 2>/dev/null');
    @ip_lines=split(/\n/,$do);
    for my $ip (@ip_lines) {
        if ( $ip =~/^${nic}[\s:]/mx){
            @fields =  split(/\s+/m,$ip);
            push @ips,$fields[3];
        }
    }
    return EDRu::arruniq(@ips);
}

# Get the broadcast address for a IP on one NIC,
# If IP is IPv6, then no bcast address
sub nic_bcast_sys {
    my ($padv,$sys,$nic,$ip)=@_;
    my ($out,$bcast);
    return if(EDRu::ip_is_ipv6($ip));
    $out=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep '$ip'");
    if($out=~/broadcast\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/){
       $bcast=$1;
    }
    return $bcast;
}

# get the nic device name
sub nic_device_name {
    my ($padv,$sys)=@_;
    my (@out,$do);
    $do=$sys->cmd('_cmd_ifconfig -a | _cmd_grep -v lo0 | _cmd_grep -v inet 2> /dev/null');
    @out=split(/:/m,$do);
    chomp($out[0]);
    return $out[0];
}

sub nic_speed_sys {
    my ($padv,$sys,$nic)=@_;
    my ($plumb,$speed,$n,$ret,$key,$speedmsg,$dev,@nics,$aggrspeed);

    @nics = ($nic);
    # get the real device name for VLAN NIC
    if ($sys->exists("$padv->{cmd}{dladm}")) {
        if ($sys->{padv} =~ /^Sol11/m) {
            $dev = $sys->cmd("_cmd_dladm show-link -p -o OVER $nic");
            chomp $dev;
            if ( $dev && $dev =~ /^\s*$/mx) {
                $dev = '';
            }
        } else {
            $dev = $sys->cmd("_cmd_dladm show-link $nic");
            if ($dev && $dev =~ /\s+device:\s+([^\s]+)\s*$/mx) {
                $dev  = $1;
            } else {
                $dev = '';
            }
        }
        if ($dev && $dev ne $nic) {
            # on sol11, the $dev might be net1 net2 if it is aggr
            if ($sys->{padv} =~ /^Sol11/m){
                @nics = split(/\s+/,$dev);
            } else {
                $nic = $dev;
            }
        }
    }
    # do not detect speed for vnet NIC in LDOMs
    if ( $nic =~ /^vnet/mx ) {
        $speedmsg = Msg::new("Not Applicable (Virtual Device)");
        return $speedmsg->{msg};
    }
    if ($sys->{padv} =~ /^Sol11/m) {
        $dev = $sys->cmd("_cmd_dladm show-phys -z global -p -o DEVICE $nic");
        if ( $dev =~ /^vnet/mx ) {
            $speedmsg = Msg::new("Not Applicable (Virtual Device)");
            return $speedmsg->{msg};
        }
    }
    $n = 0;
    $ret = $sys->cmd("_cmd_ifconfig -a |_cmd_grep $nic 2>/dev/null");
    while (!$ret) {
        last if ($n > 5);
        # $nic do not get plumbed, make it plumb to get link speed
        $sys->cmd("_cmd_ifconfig $nic plumb");
        $sys->cmd("_cmd_ifconfig $nic up");
        sleep 2;
        $n++;
        $ret = $sys->cmd("_cmd_ifconfig -a |_cmd_grep $nic 2>/dev/null");
        $plumb = 1 if ($ret);
    }
    $n = 0;
    $speed = '';
    if ($sys->exists("$padv->{cmd}{dladm}")) {
        if ($sys->{padv} =~ /^Sol11/m) {
            for my $nic (@nics){
                $speed = $sys->cmd("_cmd_dladm show-phys -p -o SPEED $nic");
                while ( $plumb == 1 && $speed == 0 && $n < 10) {
                    sleep 3;
                    $n++;
                    $speed = $sys->cmd("_cmd_dladm show-phys -p -o SPEED $nic");
                }
                $aggrspeed = $speed if($speed > $aggrspeed);
            }
            $speed = $aggrspeed;
        } elsif ($nic =~ /^aggr([0-9]+)$/m) {
            $key = $1;
            sleep 2;
            $speed = $sys->cmd("_cmd_dladm show-aggr -p $key | _cmd_grep '^dev' | _cmd_sed -n -e 's/^.* speed=\\([0-9]*\\) .*\$/\\1/p' | _cmd_sort -n | _cmd_tail -1");
        } else {
            $ret = $sys->cmd("_cmd_dladm show-dev $nic 2>/dev/null");
            while ($ret !~ /link:\s+up/m) {
                # wait for a while to the link: up
                last if ($n > 3);
                sleep 3;
                $n++;
                $ret = $sys->cmd("_cmd_dladm show-dev $nic 2>/dev/null");
            }
            $n=0;
            while (!$speed) {
                last if ($n > 3);
                if ($ret =~ /speed:\s+(\d*)\s+Mbps/mx) {
                    if ($1 eq '0') {
                        $speed = ''; # treat speed = 0 as can not get nic speed
                    } else {
                        $speed = $1;
                    }
                } elsif ($ret =~ /speed:\s+(\d*)\s+Gbps/mx) {
                    if ($1 eq '0') {
                        $speed = ''; # treat speed = 0 as can not get nic speed
                    } else {
                        $speed = $1;
                        $speed *= 1000;
                    }
                }
                last if ($speed);
                sleep 3;
                $n++;
                $ret = $sys->cmd("_cmd_dladm show-dev $nic 2>/dev/null");
            }
        }
    } else {
        # try kstat to get ifspeed info if dladm is not available.
        $n = 0;
        while ( !$speed ) {
            last if ($n > 3);
            $ret = $sys->cmd("_cmd_kstat -n $nic 2>/dev/null| _cmd_grep ifspeed");
            if ($ret =~ /^\s*ifspeed\s+(\d+)\s*$/mx) {
                $speed = $1;
                $speed /= 1000000; # get Mbps
            }
            last if ($speed);
            $n++;
            sleep 3;
        }
    }

    if ($plumb) {
        $sys->cmd("_cmd_ifconfig $nic down");
        #$sys->cmd("_cmd_ifconfig $nic unplumb");
    }
    if ( $speed eq '' ) {
        $speedmsg = Msg::new("Down");
    }
    elsif ( $speed > 1000 ) {
        $speed /= 1000;
        $speedmsg = Msg::new("$speed Gbps");
    } else {
        $speedmsg = Msg::new("$speed Mbps");
    }
    return $speedmsg->{msg};
}

# return 0 if patch is not installed or lower version is installed
# return 1 if equal or higher version is installed
sub ospatch_sys {
    my ($padv,$sys,$patch)=@_;
    my ($iv,$pn,$pv);
    ($pn,$pv)=split(/-/m,$patch->{patch_vers},2);
    $patch->{patchname}=$pn;
    $patch->{patchvers}=$pv;
    $iv=$padv->patch_version_sys($sys, $patch);
    return 0 if ((!$iv) || ($iv<$pv));
    return 1;
}

sub osupdatelevel_sys {
    my ($padv,$sys)=@_;
    my ($rootpath,$releasefile,$release,$osupdatelevel,$rtn);
    $rootpath=Cfg::opt('rootpath')||'';
    $releasefile="$rootpath/etc/release";
    if (!$sys->exists($releasefile)) {
        Msg::log("Cannot locate $releasefile on $sys->{sys}.");
        return '';
    }
    $release=$sys->cmd("_cmd_grep Solaris $releasefile 2>/dev/null");
    if ($release =~ /s\d+[sx]_u(\d+)wos/mx) {
        # on Solaris 10
        $osupdatelevel = $1;
    } elsif ($release =~ /Solaris\s+\d+\.(\d+)/mx) {
        # on Solaris 11
        $osupdatelevel = $1;
    }

    # Incident 2327723: /etc/release file will not be updated when the server is patched
    # We need to find out the OS update level through PatchIDs
    #  -- http://blogs.oracle.com/patch/entry/solaris_10_kernel_patchid_progression
    if ((!$rootpath || $rootpath eq '/') && $sys->{uname} =~ /Generic_(\S+)/) {
        $rtn=get_updatelevel_by_patchid($sys->{arch},$sys->{platvers},$1);
        $osupdatelevel = $rtn if ($rtn);
    }

    return $osupdatelevel;
}

sub get_updatelevel_by_patchid {
    my ($arch, $osver, $patchid) = @_;

    # Get the following kernel patchid and update level matrix from:
    #   http://blogs.oracle.com/patch/entry/solaris_10_kernel_patchid_progression

    my $patch_matrix = << 'EOF';
# arch    os_version   update  patchid                 description
# ---------------------------------------------------------------------------------------------------
sparc,    5.10,        11,     147147-26,              Solaris 10 Update 11 Kernel PatchID
sparc,    5.10,        10,     144500-19,              Solaris 10 Update 10 Kernel PatchID
sparc,    5.10,        9,      142909-17,              Solaris 10 9/10 (Update 9) Kernel PatchID
sparc,    5.10,        8,      141444-09,              Solaris 10 10/09 (Update 8) Kernel PatchID
sparc,    5.10,        7,      139555-08,              Solaris 10 5/09 (Update 7) Kernel PatchID
sparc,    5.10,        6,      137137-09,              Solaris 10 10/08 (Update 6) Kernel PatchID
sparc,    5.10,        5,      127127-11,              Solaris 10 5/08 (Update 5) Kernel PatchID
sparc,    5.10,        4,      120011-14,              Solaris 10 8/07 (Update 4) Kernel PatchID
sparc,    5.10,        3,      118833-33,              Solaris 10 11/06 (Update 3)
sparc,    5.10,        2,      118833-17,              Solaris 10 6/06 (Update 2)
sparc,    5.10,        1,      118822-25,              Solaris 10 1/06 (Update 1)

sparc,    5.10,        11,     150400-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 7/13 (Update 11)
sparc,    5.10,        11,     148888-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 1/13 (Update 11)
sparc,    5.10,        10,     147440-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 8/11 (Update 10)
sparc,    5.10,        9,      144488-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 9/10 (Update 9)
sparc,    5.10,        8,      142900-(0[1-9]|1[0-5]), Kernel Bug Fixes post Solaris 10 10/09 (Update 8)
sparc,    5.10,        7,      141414-(0[1-9]|10),     Kernel Bug Fixes post Solaris 10 5/09 (Update 7)
sparc,    5.10,        6,      138888-0[1-8],          Kernel Bug Fixes post Solaris 10 10/08 (Update 6)
sparc,    5.10,        5,      137111-0[1-8],          Kernel Bug Fixes post Solaris 10 5/08 (Update 5)
sparc,    5.10,        4,      127111-(0[1-9]|1[0-1]), Kernel Bug Fixes post Solaris 10 8/07 (Update 4)
sparc,    5.10,        3,      125100-(0[4-9]|10),     Kernel Bug Fixes post Solaris 10 8/07 (Update 4)

i386,     5.10,        11,     147148-26,              Solaris 10 Update 11 Kernel PatchID
i386,     5.10,        10,     144501-19,              Solaris 10 Update 10 Kernel PatchID
i386,     5.10,        9,      142910-17,              Solaris 10 9/10 (Update 9) Kernel PatchID
i386,     5.10,        8,      141445-09,              Solaris 10 10/09 (Update 8) Kernel PatchID
i386,     5.10,        7,      139556-08,              Solaris 10 5/09 (Update 7) Kernel PatchID
i386,     5.10,        6,      137138-09,              Solaris 10 10/08 (Update 6) Kernel PatchID
i386,     5.10,        5,      127128-11,              Solaris 10 5/08 (Update 5) Kernel PatchID
i386,     5.10,        4,      120012-14,              Solaris 10 8/07 (Update 4) Kernel PatchID
i386,     5.10,        3,      118855-33,              Solaris 10 11/06 (Update 3)
i386,     5.10,        2,      118855-14,              Solaris 10 6/06 (Update 2)
i386,     5.10,        1,      118844-26,              Solaris 10 1/06 (Update 1)

i386,     5.10,        11,     150401-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 7/13 (Update 11)
i386,     5.10,        11,     148889-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 1/13 (Update 11)
i386,     5.10,        10,     147441-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 8/11 (Update 10)
i386,     5.10,        9,      144489-[0-9][0-9],      Kernel Bug Fixes post Solaris 10 9/10 (Update 9)
i386,     5.10,        8,      142901-(0[1-9]|1[0-5]), Kernel Bug Fixes post Solaris 10 10/09 (Update 8)
i386,     5.10,        7,      141415-(0[1-9]|10),     Kernel Bug Fixes post Solaris 10 5/09 (Update 7)
i386,     5.10,        6,      138889-0[1-8],          Kernel Bug Fixes post Solaris 10 10/08 (Update 6)
i386,     5.10,        5,      137112-0[1-8],          Kernel Bug Fixes post Solaris 10 5/08 (Update 5)
i386,     5.10,        4,      127112-(0[1-9]|1[0-1]), Kernel Bug Fixes post Solaris 10 8/07 (Update 4)
i386,     5.10,        3,      125101-(0[1-9]|10),     Kernel Bug Fixes post Solaris 10 8/07 (Update 4)

EOF

    foreach my $line (split(/\n+/, $patch_matrix)) {
        next if ($line=~/^#/);
        my @fields = split(/,\s*/, $line);
        next if (@fields < 5);

        for my $i (0 .. $#fields) {
            $fields[$i] =~ s/^\s*//;
            $fields[$i] =~ s/\s*$//;
        }

        if ($arch eq $fields[0] && $osver eq $fields[1]) {
            if ($patchid =~ /^$fields[3]$/) {
                return $fields[2];
            }
        }
    }
    return "";
}

sub hostid_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('_cmd_hostid 2>/dev/null');
}

sub model_sys {
    my ($padv,$sys)=@_;
    my $ret = $sys->cmd('_cmd_uname -i');
    if ($ret =~ /i86pc/m) {
        $ret = $sys->cmd('_cmd_prtdiag 2>/dev/null');
        if (EDR::cmdexit() eq '0') {
            foreach (split(/\n+/, $ret)) {
                if (/System Configuration\s*:\s*(.*)/) {
                    my $arch = $1;
                    $arch =~ s/Sun Microsystems//mi;
                    return $arch;
                }
            }
        }
    }
    return $ret;
}

sub kerbit_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('/usr/bin/isainfo -b 2>/dev/null');
}

sub kernelparam_sys {
    my ($padv,$sys,$param)=@_;
    my ($v,$do);

    $v=0;
    $do=$sys->cmd("echo '$param/X' | _cmd_mdb -k 2>/dev/null");
    for my $var (split(/\n+/, $do)) {
        if ($var=~/$param:\s*(\S+)\s*$/mx) {
            $v=$1;
        }
    }
    return $v;
}

sub partially_installed_pkgs_sys {
    my ($padv,$sys)=@_;
    my ($rootpath,$partial,@f,@ppkgs);
    $rootpath=Cfg::opt('rootpath');
    $partial=$sys->cmd("_cmd_ls $rootpath/var/sadm/pkg/*/*-Lock* 2>/dev/null");
    @ppkgs=split(/\s+/m,$partial);
    for my $pkg (@ppkgs) {
        @f=split(/\//m,$pkg);
        $pkg=$f[-2];
        Msg::log("$pkg is partially installed on $sys->{sys}");
        $sys->set_value("pkgpartial,$pkg",1);
    }
    return '';
}

sub patch_copy_sys {
    my ($padv,$sys,$patch)=@_;
    my ($gunzip,$tmpdir,$path);
    $tmpdir=EDR::tmpdir();
    $path=$padv->installpath_sys($sys, $patch);
    # copy the patch
    if ($path =~ /^$tmpdir/m) {
        $padv->localsys->copy_to_sys($sys,$patch->{file},$tmpdir);
        # untar the patch file
        if ($patch->{file}=~/tar.gz$/m) {
            $gunzip=($sys->{gunzip}) || $padv->{cmd}{gunzip};
            $sys->cmd("$gunzip $tmpdir/$patch->{patchid}.tar.gz");
            $sys->cmd("cd $path; _cmd_tar -xvf $tmpdir/$patch->{patchid}.tar");
            $sys->cmd("_cmd_rmr $tmpdir/$patch->{patchid}.tar")
        }
    }
    EDR::cmd_local('_cmd_touch '.$patch->copy_mark_sys($sys));
    return '';
}

# check if patch is installed sucessfully
sub patch_install_success_sys {
    my ($padv,$sys,$patch)=(@_);
    my $io=EDRu::readfile(EDRu::outputfile("install", $sys->{sys}, "patch.$patch->{patch_vers}"));
    my $pkg=Obj::pkg($patch->{pkg},$patch->{padv});
    return 0 if (!$sys->padv->pkg_status_sys($sys,$pkg));
    return 0 if ($io!~/successfully installed/);
    return 1 if ($io!~/(failed|terminating|are not installed|do not update any packages)/);
    return 0;
}

sub pkg_status_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rootpath,$output);
    $rootpath = Cfg::opt('rootpath') ? Cfg::opt('rootpath') : '/';
    $output = $sys->cmd("_cmd_pkginfo -l -R $rootpath $pkg->{pkg} 2>/dev/null");
    return 0 if ($output!~/completely\s+installed/);
    return 1;
}

sub patch_install_sys {
    my($iof,$padv,$patch,$path,$pobj,$rootpath,$sys);
    ($padv,$sys,$patch)=(@_);
    # set the patchadd options if required
    $rootpath='-R '.Cfg::opt('rootpath') if (Cfg::opt('rootpath'));

    # intall the patch
    $iof=EDRu::outputfile("install", $sys->{sys}, "patch.$patch->{patch_vers}");
    $pobj = $patch->{patchid};
    $path=$padv->installpath_sys($sys, $patch);
    $sys->cmd("_cmd_chmod 755 ".EDR::tmpdir());
    $sys->cmd("_cmd_patchadd $rootpath $patch->{iopt} $path/$pobj 2>>$iof 1>&2");
    $sys->cmd("_cmd_chmod 700 ".EDR::tmpdir());
    return "";
}

# determine whether a patch is installed on a system
# each platform stores patch info a little differently
# assumes patches_sys has been called and patch info is in $sys
sub patch_installed_sys {
    my ($padv,$sys,$patch)=@_;
    my ($pv);
    if ($sys->{patchvers}{$patch->{patchname}} &&
        EDRu::inarr($patch->{patchvers},@{$sys->{patchvers}{$patch->{patchname}}})) {
        Msg::log("Patch $patch->{patchname} is installed on $sys->{sys}");
        return 1;
    }
    # do we need obsoleted check for VRTS patches?
    Msg::log("Patch $patch->{patch_vers} is not installed on $sys->{sys}");
    return '';
}

# check if the defined ospatch is obsolete
# also assumes patches_sys has been called and patch info is in $sys
sub patch_obsoleted_sys {
    my ($padv,$sys,$patch)=@_;
    for my $obs (sort keys(%{$sys->{patchobs}})) {
        return $obs
            if (EDRu::inarr($patch->{patch_vers},@{$sys->{patchobs}{$obs}}));
    }
    return '';
}

# check if the defined ospatch is required by others
# also assumes patches_sys has been called and patch info is in $sys
sub patch_required_sys {
    my ($padv,$sys,$patch)=@_;
    my $reqs="";
    for my $req (sort keys(%{$sys->{patchreqs}})) {
        next unless ($req eq $patch->{patch_vers});
        $reqs.=join ",", @{$sys->{patchreqs}{$req}};
    }
    $reqs=~s/,$//g;
    return $reqs;
}

sub patch_remove_sys {
    my ($padv,$sys,$patch)=@_;
    my $tmpdir=EDR::tmpdir();
    my $path=$padv->installpath_sys($sys, $patch);
    if ($path =~ /^$tmpdir/m) {
        $sys->cmd("_cmd_rmr $path/$patch->{patch_vers} 2>/dev/null");
    }
    EDR::cmd_local('_cmd_rmr '.$patch->copy_mark_sys($sys));
    return '';
}

# returns the version of a patch installed on $sys
# returns version 999 if the patch has been obsoleted
sub patch_version_sys {
    my ($padv,$sys,$patch,$force_flag)=(@_);
    my ($iv,$op,$pn,$pv,$cmd,$rp58,$rootpath,$obsolete_return,$patch_vers,$out);
    ($pn,$pv)=($patch->{patchname},$patch->{patchvers});
    $patch_vers=$pn.'-'.$pv;
    $op=$padv->patch_obsoleted_sys($sys, $patch) if ($pv);
    $obsolete_return=[qw(999)];
    return $obsolete_return if ($op);
    if ($force_flag || !$sys->{patchvers}) {
        $rootpath='-R '.Cfg::opt('rootpath') if (Cfg::opt('rootpath'));
        $rp58=1 if (($rootpath) && ($sys->{local_platvers} eq '5.8'));
        $cmd = ($rp58) ? '_cmd_patchadd' : '_cmd_showrev';
        $out = $sys->cmd("$cmd -p $rootpath | _cmd_grep $patch_vers");
        $out =~ /Patch:\s\d+-(\d+)/;
        $iv = $1;
    } else {
        # last version in installed patchvers array
        $iv=${$sys->{patchvers}{$pn}}[$#{$sys->{patchvers}{$pn}}] if ($sys->{patchvers}{$pn});
    }
    return $iv;
}

# Get all the patches installed on the system
sub patches_sys {
    my ($padv,$sys)=@_;
    my ($rp58,$rootpath,$opv,$vers,$testfile,$pkgs,$s,$ov,$pv,$patch,$obs,@av,@op,$cmd,$pkg,$op,$reqs);
    $rootpath=Cfg::opt('rootpath') || '';
    $rootpath="-R $rootpath" if ($rootpath);

    $rp58=1 if (($rootpath) && ($sys->{local_platvers} eq '5.8'));
    $cmd = ($rp58) ? '_cmd_patchadd' : '_cmd_showrev';
    $testfile=$ENV{PATCHTESTFILE};
    $s=($testfile && -f $testfile) ?
        EDRu::readfile($testfile) :
        $sys->cmd("$cmd -p $rootpath");
    @av=split(/^/m,$s);
    for my $c (@av) {
        (undef,$s,undef)=split(/\s/m,$c,3);
        ($patch,$vers)=split(/-/m,$s,2);
        next unless ($patch);
        push @{$sys->{patches}}, $s;

        # all patch keys are $patch{######}=##
        $sys->set_value("patchvers,$patch",'push',$vers);

        (undef,$obs)=split(/Obsoletes: /m,$c,2);
        ($obs,$reqs)=split(/Requires: /m,$obs,2);
        ($reqs,undef)=split(/Incompatibles/m,$reqs,2);
        @op=($rp58) ? split(/\s/m,$obs) : split(/, /m,$obs);
        for my $obs (@op) {
            ($op,$ov)=split(/-/m,$obs,2);
            # all obs patch keys are $patch{######-##}=######-##
            $ov||=0;
            for my $opv (1..$ov) {
                $opv=sprintf('%02d',$opv);
                $pv="$patch-$vers";
                $sys->set_value("patchobs,$pv",'push',"$op-$opv");
            }
        }
        # The following for loop is for fix of 3512210, part 1
        # For Solaris 10, we can get the dependency info from the 'Requires' field
        # in addition to the 'Obsoletes' field
        @op=($rp58) ? split(/\s/m,$reqs) : split(/, /m,$reqs);
        for $reqs (@op) {
            $reqs =~ s/\s+//g;
            next if (!$reqs);
            $sys->set_value("patchreqs,$reqs",'push',"$patch-$vers");
        }

        # all package references are $patch{$PKG} = [ ######, ###### ];
        chomp($c);
        (undef,$pkgs)=split(/ Packages: /m,$c,2);
        if ($pkgs=~/(VRTS|SYMC)/mx) {
            @op=($rp58) ? split(/\s/m,$pkgs) : split(/, /m,$pkgs);
            for my $pkg (@op) {
                # might not need this, but just in case...
                $sys->{patchpkgs}{$patch}||=[];
                $sys->{pkgpatches}{$pkg}||=[];
                unless (EDRu::inarr($pkg, @{$sys->{patchpkgs}{$patch}})) {
                    $sys->set_value("patchpkgs,$patch", 'push', $pkg);
                }
                unless (EDRu::inarr($patch, @{$sys->{pkgpatches}{$pkg}})) {
                    $sys->set_value("pkgpatches,$pkg", 'push', $patch);
                }
            }
        }
    }
    return '';
}

# ping a host, supports IPV4 and IPV6
# returns "" if successful, string if unsuccessful, opposite perl standard
# $sys can be a system name or IP and is scalar, not system object as ping_sys
sub ping {
    my ($padv,$sysip)=@_;
    my ($localsys);
    return '' if ($ENV{NOPING});
    $localsys=$padv->localsys;
    if ($localsys->{ipv4}) {
        EDR::cmd_local("/usr/sbin/ping -A inet $sysip 3 2>/dev/null");
        return '' if (EDR::cmdexit() eq '0');
    }
    if ($localsys->{ipv6}) {
        EDR::cmd_local("/usr/sbin/ping -A inet6 $sysip 3 2>/dev/null");
        return '' if (EDR::cmdexit() eq '0');
    }
    return 'noping';
}

sub pkg_copy_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($gunzip,$tmpdir,$path);
    $tmpdir=EDR::tmpdir();
    $path=$padv->installpath_sys($sys, $pkg);
    # copy the package
    if ($path =~ /^$tmpdir/m) {
        $padv->localsys->copy_to_sys($sys,$pkg->{file},$tmpdir);

        # gunzip and untar the file
        if ($pkg->{file}=~/tar.gz$/m) {
            # TODO copy_gunzip_sys needs to be added in misc routines
            # defines $sys->{gunzip}. When done, below condition can be removed
            # and $sys->{gunzip} can be used instead of $gunzip
            $gunzip=($sys->{gunzip}) ? $sys->{gunzip} :
                ($sys->exists('_cmd_gunzip')) ? '_cmd_gunzip' : '';
            $sys->cmd("$gunzip $path/$pkg->{pkg}.tar.gz");
            $sys->cmd("cd $path; _cmd_tar -xvf $pkg->{pkg}.tar");
            $sys->cmd("_cmd_rmr $path/$pkg->{pkg}.tar");
        }
    }

    if ($^O =~ /Win32/i){
        EDR::cmd_local('type nul>"'.$pkg->copy_mark_sys($sys).'" 2>nul');
    } else {
        EDR::cmd_local('_cmd_touch '.$pkg->copy_mark_sys($sys));
    }

    return '';
}

sub pkg_create_responsefile_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rf,$tmpdir);
    return '' unless $pkg->{responsefile};
    $tmpdir=EDR::tmpdir();
    $rf = "$tmpdir/pkgresp.$pkg->{pkg}.$sys->{sys}";
    EDRu::writefile("$pkg->{responsefile}", $rf) unless (-f $rf);
    $padv->localsys->copy_to_sys($sys,$rf,$tmpdir) unless ($sys->{islocal});
    return "-r $rf";
}

sub pkg_install_success_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($io,$iv);
    $iv=$padv->pkg_version_sys($sys, $pkg);
    $io=EDRu::readfile(EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg}));
    if (!$iv) {
        Msg::log("$pkg->{pkg} is not installed on $sys->{sys}\n$io");
        return 0;
    }
    if ($iv ne $pkg->{vers}) {
        Msg::log("$pkg->{pkg} version on $sys->{sys} is $iv but not $pkg->{vers}\n$io");
        return 0;
    }
    if ($io=~/Installation of <.*>.*successful/m) {
        return 1 if ($io!~/ERROR:/mi);
    }
    Msg::log("$pkg->{pkg} install output on $sys->{sys} does not confirm success\n$io");
    return 0;
}

sub pkg_install_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rootpath,$iof,$rtn,$admfile,$localzone,$tmpdir,$rfa,$path);
    $path=$padv->installpath_sys($sys, $pkg);
    $padv->create_adminfiles_sys($sys,$pkg->{nodeps});

    # check zones parameters
    $rtn=$padv->media_pkginfovalue($pkg,'SUNW_PKG_ALLZONES');
    $localzone = '-G' if (($sys->{zone}) && ($rtn ne 'true'));
    $rootpath='-R '.Cfg::opt('rootpath') if (Cfg::opt('rootpath'));
    $tmpdir=EDR::tmpdir();
    $admfile=($sys->{installno}{$pkg}) ? 'adminfile.unique' : 'adminfile';
    $rfa=$padv->pkg_create_responsefile_sys($sys, $pkg);
    $iof=EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg});

    $sys->cmd("_cmd_pkgadd $localzone $rootpath -a $tmpdir/$admfile -d $path $rfa $pkg->{pkg} 2>>$iof 1>&2");
    if ((EDR::cmdexit() eq '10') && (!EDRu::inarr($pkg->{pkg}, @{$sys->{requirerebootpkgs}}))) {
        $sys->set_value('requirerebootpkgs', 'push', $pkg->{pkg});
    }
    return '';
}

# Get all instances for pkg
# For example, VRTSfssdk, VRTSfssdk.2.
sub pkg_allinstances_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($pkgi,$pkgii,$id,$allinstances);

    $pkgi=$pkg->{pkgi};
    $allinstances=$sys->{pkg_allinstances}{$pkgi};
    return $allinstances if (defined($allinstances));

    $allinstances=[];

    # check pkg's other instances, totally 10 instances
    $id=10;
    while ($id > 1) {
        $pkgii=$pkg->{pkg} . ".$id";
        push @{$allinstances}, $pkgii if ($sys->{pkgvers}{$pkgii});
        $id--;
    }
    push @{$allinstances}, $pkgi;

    $sys->set_value("pkg_allinstances,$pkgi", 'list', @{$allinstances});
    return $allinstances;
}

sub pkg_remove_sys {
    my ($padv,$sys,$pkg)=@_;
    my $tmpdir=EDR::tmpdir();
    my $path=$padv->installpath_sys($sys, $pkg);

    if ($^O =~ /Win32/i){
        my $localsys = EDR::get('localsys');
        my $localpadv = $localsys->padv();
        $localpadv->rm_sys($pkg->copy_mark_sys($sys));
    } else {
        EDR::cmd_local('_cmd_rmr '.$pkg->copy_mark_sys($sys));
    }

    if ($path =~ /^$tmpdir/m) {
        $path="$tmpdir/$pkg->{pkg}" if ($pkg->{file} !~ /\.(pkg|p5p)$/m);
        $sys->cmd("_cmd_rmr $path 2>/dev/null");
    }
    return '';
}

sub pkg_uninstall_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rootpath,$uof,$ret,$tmpdir);
    $padv->create_adminfiles_sys($sys);
    $tmpdir=EDR::tmpdir();
    $pkg->{pkg}.=".$sys->{installno}{$pkg}" if ($sys->{installno}{$pkg});
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    $rootpath=Cfg::opt('rootpath')||'';
    if ($pkg->{nopreremove}||$pkg->{force_uninstall}) {
        $sys->rm("$rootpath/var/sadm/pkg/$pkg->{pkg}/install/preremove");
    }
    if ($pkg->{nopostremove}||$pkg->{force_uninstall}) {
        $sys->rm("$rootpath/var/sadm/pkg/$pkg->{pkg}/install/postremove");
    }
    $rootpath="-R $rootpath" if ($rootpath);
    $ret=$sys->cmd("_cmd_pkgrm -n -a $tmpdir/adminfile $rootpath $pkg->{pkg} 2>$uof 1>&2");
    return $ret;
}

sub pkg_uninstall_success_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($iv,$uof);
    $iv=$padv->pkg_version_sys($sys, $pkg, 1);
    $uof=EDRu::readfile(EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg}));
    if ($iv) {
        Msg::log("$pkg->{pkg} uninstall failed on $sys->{sys}\n$uof");
        return 0;
    }
    Msg::log("$pkg->{pkg} uninstall successfully on $sys->{sys}\n$uof");
    return 1;
}

sub pkg_description_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($desc,$rootpath);
    $rootpath=Cfg::opt('rootpath') || '';
    $desc=$sys->cmd("_cmd_grep '^DESC=' $rootpath/var/sadm/pkg/$pkg->{pkg}/pkginfo 2>/dev/null");
    $desc=~s/DESC=//m;
    $desc=~s/\.\s*$//m;
    return $desc;
}

sub patch_uninstall_sys {
    my ($padv,$sys,$patch)=(@_);
    my ($uof,$rootpath,$ret);
    $padv->create_adminfiles_sys($sys);
    #$patch->{patch}.=".$sys->{installno}{$patch}" if ($sys->{installno}{$patch});
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, "patch.$patch->{patch_vers}");
    $rootpath=Cfg::opt("rootpath")||"";
    #if ($patch->{force_uninstall}) {
    #    $sys->cmd("cd $rootpath/var/sadm/pkg/$pkg->{pkg}/install/; _cmd_rmr preremove postremove");
    #}
    $rootpath="-R $rootpath" if ($rootpath);
    $ret=$sys->cmd("_cmd_patchrm $rootpath $patch->{patchid} 2>>$uof 1>&2");
    return $ret;
}

sub patch_uninstall_success_sys {
    my ($padv,$sys,$patch)=(@_);
    my ($uof,$iv);
    $iv=$padv->patch_version_sys($sys, $patch, 1);
    $uof=EDRu::readfile(EDRu::outputfile('uninstall', $sys->{sys}, "patch.$patch->{patch_vers}"));
    if ($iv) {
        Msg::log("$patch->{patch_vers} uninstall failed on $sys->{sys}\n$uof");
        return 0;
    }
    Msg::log("$patch->{patch_vers} uninstall successfully on $sys->{sys}\n$uof");
    return 1;
}

sub pkg_version_sys {
    my ($padv,$sys,$pkg,$prevpkgs_flag,$pbe_flag)=@_;
    my ($i,$rootpath,$iv,$pkgi);
    # if $prevpkgs_flag=1, then do not check pkg's previous name.
    $rootpath=$pbe_flag ? '' : Cfg::opt('rootpath');
    for my $pkgi ($pkg->{pkg},@{$pkg->{previouspkgnames}}) {
        $iv||= $sys->cmd("_cmd_grep '^VERSION=' $rootpath/var/sadm/pkg/$pkgi/pkginfo 2>/dev/null");
        last if ($iv || $prevpkgs_flag);
    }
    $iv=~s/VERSION=//m;
    # Check for multiple instances
    if ($pkg->{otherinst}) {
        $i=2;
        while ($sys->exists("$rootpath/var/sadm/pkg/$pkg->{pkg}.$i/pkginfo")) {
            $i++;
        }
        if ($i>2) {
            $i--;
            $iv=$sys->cmd("_cmd_grep '^VERSION=' $rootpath/var/sadm/pkg/$pkg->{pkg}.$i/pkginfo 2>/dev/null");
            $iv=~s/VERSION=//m;
            $sys->{installno}{$pkg} = $i;
        }
    }
    return $padv->pkg_version_cleanup($iv);
}

sub pkg_installtime_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($str,$it);

    $it='';
    for my $pkgi ($pkg->{pkg},@{$pkg->{previouspkgnames}}) {
        $str=$sys->cmd("_cmd_grep INSTDATE /var/sadm/pkg/$pkgi/pkginfo 2>/dev/null");
        if ($str =~ /INSTDATE=\s*(.*)/) {
            $it = $1;
            last;
        }
    }
    return $it;
}

sub pkg_version_cleanup {
    my ($padv,$vers)=@_;

    return '' unless $vers;

    # clean up, CPIC 5.0 has way more, but...
    $vers=~ s/[,-].*$//m;
    $vers=~s/[a-z]\w*//mig;
    return $vers;
}

# get information from the pkginfo file for pkg
sub pkginfovalue_sys {
    my ($padv,$sys,$param,$pkg)=@_;
    my ($rootpath,$v);
    $rootpath=Cfg::opt('rootpath');
    return '' unless ($sys->exists("$rootpath/var/sadm/pkg/$pkg->{pkg}/pkginfo"));
    $param.='=';
    $v=$sys->cmd("_cmd_grep '^$param' $rootpath/var/sadm/pkg/$pkg->{pkg}/pkginfo");
    $v=~s/($param)//m;
    return "$v";
}

# determine the NICs on $sys which have IP addresses configured on them
# return a reference to an array holding the NICs
sub publicnics_sys {
    my ($padv,$sys)=@_;
    my (@pnics,$do);
    return ($sys->{publicnics}) if ($sys->{publicnics});
    $do=$sys->cmd("_cmd_ifconfig -a | _cmd_grep UP | _cmd_sed 's/:.*\$//' | _cmd_uniq | _cmd_grep -v lo");
    @pnics=split(/\s+/m,$do);
    $sys->{publicnics}=\@pnics;
    return \@pnics;
}

# get run-level
sub runlevel_sys {
    my ($padv,$sys)=@_;
    my ($rtn,$runlevel);

    $runlevel=undef;
    $rtn=$sys->cmd('_cmd_who -r 2> /dev/null');
    if ($rtn=~/\s*\S+\s+run\-level\s*(\S+)\s+/mx) {
        $runlevel=$1;
    }
    return $runlevel;
}

# get swap informations
sub swap_size_sys {
    my ($padv,$sys)=@_;

    my $do=$sys->cmd('_cmd_swap -s 2> /dev/null');
    if ($do=~/total:\s*(\S+)\s*bytes allocated\s*\+\s*(\S+)\s*reserved\s*=\s*(\S+)\s*used,\s*(\S+)\s*available/m) {
        return $4;
    }
    return 0;
}

# determine all NICs on $sys
# return a reference to an array holding the NICs
sub systemnics_sys {
    my ($padv,$sys,$bnics_flag)=@_;
    my ($name,@snics,$anics,$snics,$module,@nics,@p,@n,$bnics,@out,$devname,@tmp,$pti,$do,$dn);
    return ($sys->{systemnics}) if ($sys->{systemnics});

    if($sys->exists("$padv->{cmd}{dladm}")) {
        $do=$sys->cmd("_cmd_dladm show-dev 2>/dev/null| _cmd_awk '{print \$1}'");
        @out=split(/\n/,$do);
        for my $nic (@out) {
            push(@nics,$nic) if (!EDRu::inarr($nic,@nics));
        }
    }

    $devname=$padv->nic_device_name($sys);
    $do=$sys->cmd('_cmd_kstat -c net | _cmd_grep -v lo0 | _cmd_grep -v zero_copy 2> /dev/null');
    @out=split(/\n/,$do);
    for my $nic (@out) {
        $nic=~s/^\s+//mg if ($nic =~ /^\s+/m);
        next if (($nic =~ /^\n$/) || (!length($nic)));
        @tmp = split(/\s+/m, $nic);
        $module = $tmp[1] if ($tmp[0] eq 'module:');
        if ($tmp[0] eq 'name:') {
            $name = $tmp[1];
            push (@n, $name) if (($name =~ /$module\d/m) && ($devname =~ $module));
            $module = '';
       }
    }
    for my $dn (@n) { push(@nics,$dn) unless (EDRu::inarr($dn,@nics)); }
    # try the old-school way as well
    # this adds some false NICs in situations where people have moved
    # cards around, but sometimes kstat will not show NICs from cards
    # that haven't been used yet, so this is the only way to find them
    @snics=qw(hme qe qfe le nf eri ge ce afe bge e1000g bnx fjgi rtls vnet nge nxge aggr igb);
    $do=$sys->cmd("_cmd_modinfo | _cmd_grep Ether | _cmd_awk '{print \$6}'");
    @n=split(/\s+/m,$do);
    for my $nic (@n) { push(@snics,$nic) unless (EDRu::inarr($nic,@snics)); }
    $pti=$sys->cmd('_cmd_cat /etc/path_to_inst');
    @p=split(/\n/,$pti);
    for my $pti (@p) {
        for my $nic (@snics) {
             if ($pti=~/"$nic"/m) {
                 @n=split(/\s+/m,$pti);
                 push(@nics,"$nic$n[1]") unless (EDRu::inarr("$nic$n[1]",@nics));
             }
        }
    }
    $anics=\@nics;
    if($bnics_flag){
        ($bnics,$snics)=$padv->bondednics_sys($sys);
        push(@$anics,@{$bnics});
        $anics=EDRu::arrdel($anics,@{$snics});
        $anics=EDRu::arruniq(@$anics);
    }

    $sys->{systemnics}=$anics;
    return $anics;
}

sub unload_driver_sys {
    my ($padv,$sys,$driver,$pkg)=@_;
    my (@mns,$mod);
    $mod=$padv->driver_sys($sys, $driver);
    @mns=split(/\s+/m,$mod);
    for my $mod (@mns) { $sys->cmd("_cmd_modunload -i $mod"); }
    # TODO Add driver_force_unload_sys() call per pkg basis when needed?
    return 1;
}

sub detect_sunos_ldom_sys {
    my ($padv, $sys) = @_;

    my $out = $sys->cmd("_cmd_uname -m 2>/dev/null");

    if ($out =~ /sun4v/i) {
        $out = $sys->cmd("_cmd_cat /etc/path_to_inst 2>/dev/null");
        foreach (split(/\n+/, $out)) {
            if (/virtual-devices\@100\/channel-devices/i) {
                $sys->{virtual_type} = $padv->VIRT_LDOM;
                last;
            }
        }
    }
    return;
}

sub detect_sunos_zone_sys {
    my ($padv, $sys) = @_;

    my $out = $sys->cmd("_cmd_zonename 2>/dev/null");
    if ($out =~ /global/i) {
        $sys->{virtual_type} = $padv->VIRT_GLOBAL_ZONE;
    }else{
        $sys->{virtual_type} = $padv->VIRT_LOCAL_ZONE;
    }

    $out = $sys->cmd("_cmd_zoneadm list -civ 2>/dev/null");
    if($out=~/\S/){
        chomp($out);
        $sys->{virtual_detail} = $out;
    }
    return;
}

sub detect_sunos_vm_sys {
    my ($padv, $sys) = @_;

    my $out = $sys->cmd("_cmd_smbios 2>/dev/null");

    my $sysinfo_flag = 0;
    my @lines = split(/\n+/, $out);
    foreach (@lines) {
        if (/Product:\s*(.*)/i) {
            if ($1 =~ /VMware/i) {
                $sys->{virtual_type} = $padv->VIRT_VMWARE;
            }
        }
        if (/^\d/) {
            if (/SMB_TYPE_SYSTEM/) {
                $sysinfo_flag = 1;
            } else {
                $sysinfo_flag = 0;
            }
        }
        if ($sysinfo_flag && (/Product:/ || /Manufacturer:/ || /Version:/ || /Serial Number:/i)) {
            $sys->{virtual_detail} .= "$_\n";
        }
    }
    return;
}


# determine a systems virtualization status
sub virtualization_sys {
    my ($padv, $sys) = @_;

    $padv->detect_sunos_ldom_sys($sys);
    $padv->detect_sunos_vm_sys($sys) if(!$sys->{virtual_type});
    $padv->detect_sunos_zone_sys($sys) if(!$sys->{virtual_type});
    $sys->set_value('virtual_type', $sys->{virtual_type}) if($sys->{virtual_type});
    $sys->set_value('virtual_detail', $sys->{virtual_detail}) if($sys->{virtual_detail});

    return 1;
}

sub vrtspkgversdeps_script {
    my $rootpath=Cfg::opt('rootpath')||'';
    my $script=<<'VPVD';
#!/bin/sh

rootpath="__ROOTPATH__"

vrtspkgs=`/usr/bin/grep '^VERSION=' $rootpath/var/sadm/pkg/VRTS*/pkginfo $rootpath/var/sadm/pkg/SYMC*/pkginfo 2>/dev/null | /usr/bin/awk '
    {
        start=index($0, "/var/sadm/pkg");
        idx=index($0, "pkginfo:VERSION=");
        if (idx > 0) {
            pkg=substr($0, start+14, idx-start-15);
            vers=substr($0, idx+16);
            print pkg,vers;
        }
    }' | /usr/bin/sort`

[ -z "$vrtspkgs" ] && exit 0

reqlist=`/usr/bin/grep '^P[ |	]' $rootpath/var/sadm/pkg/VRTS*/install/depend $rootpath/var/sadm/pkg/SYMC*/install/depend 2>/dev/null | /usr/bin/awk '
    {
        start=index($0, "/var/sadm/pkg");
        idx=index($0, "depend:P");
        if (idx > 0) {
            pkg=substr($0, start+14, idx-start-23);
            dep=$2;
            print pkg,dep;
        }
    }'`

echo "$vrtspkgs" | while read pkg vers; do
    echo "$pkg $vers\c"
    echo "$reqlist" | /usr/bin/awk '$2 == "'"$pkg"'" { printf " %s",$1 }'
    echo
done
VPVD
    $script=~s/__ROOTPATH__/$rootpath/g;
    return $script;
}

sub zone_sys {
    my ($padv,$sys)=@_;
    my ($zone);
    if ($sys->exists('/usr/bin/zonename')) {
        $zone=$sys->cmd('/usr/bin/zonename');
    }
    return $zone;
}

# check whether $file on $sys was modified after the package who owns $file was installed
sub file_modified_sys {
    my ($padv,$sys,$file)=@_;
    my ($cmdout,$rootpath);
    $rootpath = Cfg::opt('rootpath')||'';
    $cmdout = '';
    if ($file) {
        if ($rootpath) {
            $cmdout = $sys->cmd("_cmd_pkgchk -R $rootpath -p $file 2>&1");
        } else {
            $cmdout = $sys->cmd("_cmd_pkgchk -p $file 2>&1");
        }
    }
    if ($cmdout =~ /file\s+cksum.*expected.*actual/mx) {
        return 1;
    }
    return 0;
}

# return value: 0 - verify ok; 1 - otherwise
sub pkg_verify_sys {
    my ($padv,$sys,$pkgname)=@_;
    return 1 if (!$pkgname);
    my $rtn=$sys->cmd("_cmd_pkgchk -n $pkgname");
    my $msg=Msg::new("'pkgchk -n $pkgname' on $sys->{sys} return:\n$rtn");
    $sys->set_value("pkg_verify,$pkgname", $msg->{msg});
    return EDR::cmdexit();
}

sub configure_static_ip_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    return $padv->configure_static_ipv6_sys($sys,$nic,$ip,$mask) if (EDRu::ip_is_ipv6($ip));
    return $padv->configure_static_ipv4_sys($sys,$nic,$ip,$mask);
}

sub configure_static_ipv4_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($nicfile,$nicfilebk,$output,$cnt,$max_cnt,$plumb,$temp);

    $output = $sys->cmd("_cmd_ifconfig $nic 2>/dev/null");
    if ($output =~ /inet\s+$ip\s+/mx){
       $plumb=$nic;
    }elsif($output=~/$nic/ && $output!~/inet 0/){
       $output = $sys->cmd("_cmd_ifconfig -a 2>/dev/null | _cmd_awk '/^$nic:[0-9]/ {print \$1}'");
       if ($output) {
          $max_cnt=0;
          for my $nic_entry (split(/\n/,$output)){
             if ($nic_entry=~/$nic:(\d+)/){
                $cnt=$1;
                $max_cnt=$cnt if ($max_cnt<$cnt);
                $temp=$sys->cmd("_cmd_ifconfig $nic:$cnt 2>/dev/null");
                if ($temp =~ /inet\s+$ip\s+/mx){
                   $plumb="$nic:$cnt";
                   last;
                }
             }
          }
       }
       if (!$plumb){
          $max_cnt++;
          $nic=$nic.':'.$max_cnt;
       }
    }

    if ($plumb) {
       $nic=$plumb;
       $sys->cmd("_cmd_ifconfig $nic up 2>/dev/null");
       return 0 if (EDR::cmdexit());
    }else{
       $sys->cmd("_cmd_ifconfig $nic plumb 2>/dev/null");
       $sys->cmd("_cmd_ifconfig $nic $ip netmask $mask up 2>/dev/null");
       return 0 if (EDR::cmdexit());
    }

    $nicfile = '/etc/hostname.' . $nic;
    if ($sys->exists($nicfile)) {
        $nicfilebk = $nicfile . ".bak";
        Msg::log("Backing up $nicfile file as $nicfilebk");
        $sys->copyfile($nicfile, $nicfilebk);
    }
    $sys->cmd("echo '$ip' > $nicfile 2>/dev/null");
    $padv->add_netmask_sys($sys,$ip,$mask);

    return 1;
}

sub configure_static_ipv6_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($nicfile,$nicfilebk,$output,$cnt,$max_cnt,$plumbed_nic,$new_nic,$pre_mask,$temp);

    $output = $sys->cmd("_cmd_ifconfig $nic inet6 2>/dev/null");
    if ($output =~ /inet6\s+$ip\/(\d+)/mx){
       $pre_mask=$1;
       $plumbed_nic=$nic;
    }elsif($output=~/$nic/ && $output!~/inet6 0/){
       $output = $sys->cmd("_cmd_ifconfig -a inet6 2>/dev/null | _cmd_awk '/^$nic:[0-9]/ {print \$1}'");
       if ($output) {
          $max_cnt=0;
          for my $nic_entry (split(/\n/,$output)){
             if ($nic_entry=~/$nic:(\d+)/){
                $cnt=$1;
                $max_cnt=$cnt if ($max_cnt<$cnt);
                $temp=$sys->cmd("_cmd_ifconfig $nic:$cnt inet6 2>/dev/null");
                if ($temp =~ /inet6\s+$ip\/(\d+)/mx){
                   $plumbed_nic="$nic:$cnt";
		   $pre_mask=$1;
                   last;
                }
             }
          }
       }
       if (!$plumbed_nic){
          $max_cnt++;
          $new_nic=$nic.':'.$max_cnt;
       }
    }

    if ($plumbed_nic) {
       if ($mask==$pre_mask){
           $sys->cmd("_cmd_ifconfig $plumbed_nic inet6 up 2>/dev/null");
       }else{
           $sys->cmd("_cmd_ifconfig $nic inet6 removeif $ip 2>/dev/null");
           $sys->cmd("_cmd_ifconfig $nic inet6 addif $ip/$mask up 2>/dev/null");
       }
    }else{
       if (!$new_nic) {
           $sys->cmd("_cmd_ifconfig $nic inet6 plumb 2>/dev/null");
           $new_nic="$nic:1";   #the fist ipv6 address
       }
       $sys->cmd("_cmd_ifconfig $nic inet6 addif $ip/$mask up 2>/dev/null");
    }
    return 0 if (EDR::cmdexit());

    $nicfile = '/etc/hostname6.' . $nic;
    $sys->cmd("echo '$ip/$mask' > $nicfile 2>/dev/null") if(!$sys->exists($nicfile));

    if ($new_nic||$plumbed_nic){
        $nicfile = '/etc/hostname6.' . $new_nic if ($new_nic);
        $nicfile = '/etc/hostname6.' . $plumbed_nic if($plumbed_nic);
        if ($sys->exists($nicfile)){
            $nicfilebk = $nicfile . ".bak";
            Msg::log("Backing up $nicfile file as $nicfilebk");
            $sys->copyfile($nicfile, $nicfilebk);
	}
        $sys->cmd("echo '$ip/$mask' > $nicfile 2>/dev/null");
    }
    return 1;
}

sub add_netmask_sys {
    my ($padv,$sys,$ip,$mask) = @_;
    my $file = '/etc/netmasks';
    my $output = $sys->cmd("_cmd_grep -v '^#' $file 2>/dev/null");
    return 0 if ($output && $output=~/^\s*$ip[\/\s]/mx);
    $sys->cmd("echo '$ip $mask' >> $file 2>/dev/null");
    return 1;
}


package Padv::Sol8sparc;
@Padv::Sol8sparc::ISA = qw(Padv::SunOS);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='5.8';
    $padv->{name}='Solaris 8 Sparc';
    return;
}

package Padv::Sol9sparc;
@Padv::Sol9sparc::ISA = qw(Padv::SunOS);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='5.9';
    $padv->{name}='Solaris 9 Sparc';
    return;
}

package Padv::Sol10sparc;
@Padv::Sol10sparc::ISA = qw(Padv::SunOS);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='5.10';
    $padv->{name}='Solaris 10 Sparc';
    return;
}

# keeping Sol10x64 one level until there's more than one version
package Padv::Sol10x64;
@Padv::Sol10x64::ISA = qw(Padv::SunOS);

sub init_padv {
    my $padv=shift;
    $padv->{arch}='i86pc';
    $padv->{name}='Solaris 10 x64';
    $padv->{vers}='5.10';
    return;
}

package Padv::Sol11sparc;
@Padv::Sol11sparc::ISA = qw(Padv::SunOS);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='5.11';
    $padv->{name}='Solaris 11 Sparc';
    $padv->{cmd}{pkg}='/usr/bin/pkg';
    $padv->{cmd}{sh}='/usr/sunos/bin/sh';
    $padv->{cmd}{openssl}='/usr/bin/openssl';
    return;
}

sub installcommand_precheck_sys {
    my ($padv,$sys)=@_;
    my ($rtn,$success,$msg,$rootpath,$reloc);

    $success=1;

    $rootpath=Cfg::opt('rootpath')||'';
    $reloc=$rootpath;
    $rootpath="-R $rootpath" if ($rootpath);

    # Check whether any other pkg client is running.
    $rtn=$sys->cmd("_cmd_awk 'NR==2 {print \$0}' $reloc/var/pkg/lock 2>/dev/null");
    if ($rtn) {
        # another package client is running.
        $msg = Msg::new("Another package client '$rtn' is running on $sys->{sys}. Make sure only one pkg instance is running at any time on $sys->{sys}.");
        $sys->push_error($msg);
        $success=0;
    }

    # Check whether pkg publishers are reachable or not,
    if (Cfg::opt(qw(install upgrade patchupgrade hotfixupgrade))) {
        $rtn=$sys->cmd("_cmd_pkg $rootpath publisher Symantec 2>/dev/null | _cmd_grep 'Origin URI:'");
        if ($rtn) {
            # 'Symantec' publisher is already set, need unset it
            $sys->cmd("_cmd_pkg $rootpath unset-publisher Symantec 2>/dev/null");
        }

        $rtn=$sys->cmd("_cmd_pkg $rootpath refresh 2>&1 1>/dev/null");
        if (EDR::cmdexit()) {
            # 'pkg refresh' fail which means some publishers have problems
            $msg = Msg::new("Unable to contact configured publishers on $sys->{sys}");
            $sys->push_error($msg);
            $success=0;
        }
    }
    return $success;
}

sub load_driver_sys {
    my ($padv,$sys,$driver,$donot_check)=@_;
    my ($mn);
    $mn=$padv->driver_sys($sys, $driver) if (!$donot_check);
    if (!$mn) {
        $sys->cmd("_cmd_adddrv $driver 2>/dev/null; _cmd_modload -p drv/$driver 2>/dev/null");
    }
    return '';
}

sub unload_driver_sys {
    my ($padv,$sys,$driver,$donot_rmdrv)=@_;
    my ($mod,$cmd);
    $mod=$padv->driver_sys($sys, $driver);
    if ($mod) {
        # To avoid Solaris 11 aggressive module auto load mechanism
        $cmd='';
        for my $mod_id (split(/\s+/m,$mod)) {
            $cmd.="_cmd_modunload -i $mod_id 2>/dev/null;";
        }
        $cmd.="_cmd_rmdrv $driver 2>/dev/null" if (!$donot_rmdrv);
        $sys->cmd("$cmd");
        return 0 if (EDR::cmdexit());
    }
    return 1;
}

sub rm_etc_system_entry_sys {
    my ($padv,$sys,$procs)=@_;
    my ($cmd,$sedstr);

    $sedstr = '';
    if (@{$procs}) {
        for my $proc (@{$procs}) {
            $sedstr .= "s/^forceload: drv\\/$proc/*&/;";
        }
        $cmd = "_cmd_cp -f /etc/system /etc/system.cpibak 2> /dev/null; _cmd_sed '$sedstr' /etc/system.cpibak > /etc/system 2> /dev/null";
        $sys->cmd($cmd);
    }
    return 1;
}

sub add_etc_system_entry_sys {
    my ($padv,$sys,$procs)=@_;
    my ($cmd,$sedstr);

    $sedstr = '';
    if (@{$procs}) {
        for my $proc (@{$procs}) {
            $sedstr .= "s/^* *\\(forceload: drv\\/$proc\\)/\\1/;";
        }
        $cmd = "_cmd_cp -f /etc/system /etc/system.cpibak 2> /dev/null; _cmd_sed '$sedstr' /etc/system.cpibak > /etc/system 2> /dev/null";
        $sys->cmd($cmd);
    }
    return 1;
}

sub media_pkg_file {
    my ($padv,$pkg,$pkgdir)=@_;
    return '' unless ($pkgdir);

    my $file="$pkgdir/$pkg->{pkg}.p5p";
    return $file if (-e $file);

    $file="$pkgdir/VRTSpkgs.p5p";
    if (-e $file) {
        if (-e "$pkgdir/info/$pkg->{pkg}") {
            $pkg->{batchinstall}=1;
            return $file;
        }
        return '';
    }
    return $pkgdir;
}

sub media_patch_file {
    my ($padv,$patch,$patchdir)=@_;
    return '' unless ($patchdir);
    my $separator = ($^O =~ /Win32/i)? '\\':'/';
    my $file="$patchdir".$separator."$patch->{patchname}.p5p";
    return $file if (-e $file);

    $file="$patchdir".$separator."VRTSpatches.p5p";
    if (-e $file) {
        $patch->{batchinstall}=1;
        return $file;
    }
    return $patchdir;
}

sub media_pkg_version {
    my ($padv,$pkg)=@_;
    my ($pkgdir,$vers);
    return '' if (!$pkg->{file});
    $vers='';
    $pkgdir=EDRu::dirname($pkg->{file});
    if (-f "$pkgdir/info/$pkg->{pkg}") {
        $vers = EDR::cmd_local("_cmd_grep 'Version:' $pkgdir/info/$pkg->{pkg} 2>/dev/null");
        $vers=~s/^\s*Version:\s*//;
        $vers=~s/\s*$//;
    } elsif ($padv->localpadv =~ /Sol11/) {
        $vers=EDR::cmd_local("_cmd_pkg info -g $pkg->{file} $pkg->{pkg} 2>/dev/null | _cmd_grep Version: | _cmd_awk '{print \$2}'");
    }
    $vers =~ s/\n.*$//s;
    return $padv->pkg_version_cleanup($vers);
}

sub media_patch_version {
    my ($padv,$patch)=@_;
    my ($patchdir,$vers);
    return '' if (!$patch->{file});
    $vers='';
    $patchdir=EDRu::dirname($patch->{file});
    if (-f "$patchdir/info/$patch->{patchname}") {
        $vers = EDR::cmd_local("_cmd_grep 'Version:' $patchdir/info/$patch->{patchname} 2>/dev/null");
        $vers=~s/^\s*Version:\s*//;
        $vers=~s/\s*$//;
    } elsif ($padv->localpadv =~ /Sol11/) {
        $vers=EDR::cmd_local("_cmd_pkg info -g $patch->{file} $patch->{patchname} 2>/dev/null | _cmd_grep Version: | _cmd_awk '{print \$2}'");
    }
    $vers =~ s/\n.*$//s;
    return $vers;
}

sub pkg_status_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($result);
    $result = $sys->cmd("_cmd_pkg info $pkg->{pkg} 2> /dev/null");
    return 1 if ($result=~/Version/);
    return 0;
}

sub patches_sys {
    # Do not support patch on Solaris 11
    return '';
}

sub partially_installed_pkgs_sys {}

sub pkg_installtime_sys {
    my ($padv,$sys,$pkg) = @_;

    # Implement it later.
    return '';
}

sub pkg_description_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($desc,$rootpath);
    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $desc=$sys->cmd("_cmd_pkg $rootpath info $pkg->{pkg} 2>/dev/null | _cmd_grep 'Summary:'");
    $desc=~s/^\s*Summary: //m;
    $desc=~s/\.\s*$//m;
    return $desc;
}

sub pkg_install_success_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($iof,$io,$iv,$rtn,$msg,$logf);

    $iv=$padv->pkg_version_sys($sys, $pkg);
    if (!$iv) {
        $msg=Msg::new("$pkg->{pkg} is not installed on $sys->{sys}");
        $rtn=0;
    } elsif ($iv ne $pkg->{vers}) {
        $msg=Msg::new("$pkg->{pkg} version on $sys->{sys} is $iv but not $pkg->{vers}");
        $rtn=0;
    } else {
        $msg=Msg::new("$pkg->{pkg} installed successfully on $sys->{sys}");
        $rtn=1;
    }

    $iof=EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg});
    if ($pkg->{batchinstall}) {
        $logf=EDRu::outputfile('install', $sys->{sys}, 'pkgs');
        $io=EDRu::readfile($logf);
        EDRu::appendfile("Install logs\n$io\n$msg->{msg}", $iof);
    } else {
        EDRu::appendfile("\n$msg->{msg}", $iof);
    }
    return $rtn;
}

sub patch_install_success_sys {
    my ($padv,$sys,$patch)=@_;
    my ($iof,$io,$iv,$rtn,$msg,$logf);

    $iv=$padv->patch_version_sys($sys, $patch, 1);
    if (!$iv) {
        $msg=Msg::new("$patch->{patchname} is not installed on $sys->{sys}");
        $rtn=0;
    } elsif ($iv ne $patch->{vers}) {
        $msg=Msg::new("$patch->{patchname} version on $sys->{sys} is $iv but not $patch->{vers}");
        $rtn=0;
    } else {
        $msg=Msg::new("$patch->{patchname} installed successfully on $sys->{sys}");
        $rtn=1;
    }

    $iof=EDRu::outputfile('install', $sys->{sys}, $patch->{patch});
    if ($patch->{batchinstall}) {
        $logf=EDRu::outputfile('install', $sys->{sys}, 'patches');
        $io=EDRu::readfile($logf);
        EDRu::appendfile("Install logs\n$io\n$msg->{msg}", $iof);
    } else {
        EDRu::appendfile("\n$msg->{msg}", $iof);
    }
    return $rtn;
}

sub pkgs_install_sys {
    my ($padv,$sys,$archive,$pkgs)=@_;
    my ($rootpath,$iof,$path,$stat);

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $iof=EDRu::outputfile('install', $sys->{sys}, 'pkgs');
    $path=EDRu::dirname($archive);
    $stat=$sys->filestat($path);
    $sys->cmd("_cmd_chmod a+x $path");

    #$sys->cmd("_cmd_pkg $rootpath install -g $archive $pkgs 2>$iof 1>&2");
    # 'pkg install -g VRTSpkgs.p5p <pkgs>' do not work well when some zones in running state
    # According to 2707052: call set-publisher first
    $sys->cmd("_cmd_pkg $rootpath set-publisher -p $archive Symantec 2>$iof 1>&2; _cmd_pkg $rootpath install --accept --no-backup-be $pkgs 2>>$iof 1>&2; _cmd_pkg $rootpath unset-publisher Symantec 2>>$iof 1>&2; _cmd_svcadm clear application/pkg/system-repository 2>/dev/null");
    $sys->change_filestat($path,$stat);
    return 1;
}

sub patches_install_sys {
    my ($padv,$sys,$archive,$patches)=@_;
    my ($rootpath,$iof,$path,$stat);

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $iof=EDRu::outputfile('install', $sys->{sys}, 'patches');
    $path=EDRu::dirname($archive);
    $stat=$sys->filestat($path);
    $sys->cmd("_cmd_chmod a+x $path");

    #$sys->cmd("_cmd_pkg $rootpath install -g $archive $patches 2>$iof 1>&2");
    # 'pkg install -g VRTSpatches.p5p <patches>' do not work well when some zones in running state
    # According to 2707052: call set-publisher first
    $sys->cmd("_cmd_pkg $rootpath set-publisher -p $archive Symantec 2>>$iof 1>&2; _cmd_pkg $rootpath install --accept --no-backup-be $patches 2>>$iof 1>&2; _cmd_pkg $rootpath unset-publisher Symantec 2>>$iof 1>&2; _cmd_svcadm clear application/pkg/system-repository 2>/dev/null");
    $sys->change_filestat($path,$stat);
    return 1;
}

sub patch_install_sys {
    my ($padv,$sys,$patch)=@_;
    my ($rootpath,$iof,$path,$stat,$patchfile);

    $patchfile = $padv->installpath_sys($sys, $patch);
    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $iof=EDRu::outputfile('install', $sys->{sys}, "patch.$patch->{patch_vers}");
    $path=EDRu::dirname($patchfile);
    $stat=$sys->filestat($path);
    $sys->cmd("_cmd_chmod a+x $path");

    #$sys->cmd("_cmd_pkg $rootpath install -g $archive $patches 2>$iof 1>&2");
    # 'pkg install -g VRTSpatches.p5p <patches>' do not work well when some zones in running state
    # According to 2707052: call set-publisher first
    $sys->cmd("_cmd_pkg $rootpath set-publisher -p $patchfile Symantec 2>>$iof 1>&2; _cmd_pkg $rootpath install --accept --no-backup-be $patch->{patchname} 2>>$iof 1>&2; _cmd_pkg $rootpath unset-publisher Symantec 2>>$iof 1>&2; _cmd_svcadm clear application/pkg/system-repository 2>/dev/null");
    $sys->change_filestat($path,$stat);
    return 1;
}


sub patches_uninstall_sys {
    my ($padv,$sys,$patches)=@_;
    my ($rootpath,$uof,$ret);

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, 'patches');
    $ret=$sys->cmd("_cmd_pkg $rootpath uninstall --no-backup-be $patches 2>>$uof 1>&2");
    return $ret;
}

sub pkgs_uninstall_sys {
    my ($padv,$sys,$pkgs)=@_;
    my ($rootpath,$uof,$ret);

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, 'pkgs');
    $ret=$sys->cmd("_cmd_pkg $rootpath uninstall --no-backup-be $pkgs 2>$uof 1>&2");
    return $ret;
}

sub pkg_uninstall_success_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($uof,$uo,$iv,$rtn,$msg,$logf);
    $iv=$padv->pkg_version_sys($sys, $pkg, 1);
    if ($iv) {
        $msg=Msg::new("$pkg->{pkg} uninstall failed on $sys->{sys}");
        $rtn=0;
    } else {
        $msg=Msg::new("$pkg->{pkg} uninstalled successfully on $sys->{sys}");
        $rtn=1;
    }

    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    $logf=EDRu::outputfile('uninstall', $sys->{sys}, 'pkgs');
    if (-f "$logf") {
        $uo=EDRu::readfile($logf);
        EDRu::appendfile("Uninstall logs\n$uo\n$msg->{msg}", $uof);
    } else {
        EDRu::appendfile("\n$msg->{msg}", $uof);
    }
    return $rtn;
}

sub patch_uninstall_success_sys {
    my ($padv,$sys,$patch)=@_;
    my ($uof,$uo,$iv,$rtn,$msg,$logf);
    $iv=$padv->patch_version_sys($sys, $patch, 1);
    if ($iv) {
        $msg=Msg::new("$patch->{patchname} uninstall failed on $sys->{sys}");
        $rtn=0;
    } else {
        $msg=Msg::new("$patch->{patchname} uninstalled successfully on $sys->{sys}");
        $rtn=1;
    }

    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $patch->{patch});
    $logf=EDRu::outputfile('uninstall', $sys->{sys}, 'patches');
    if (-f "$logf") {
        $uo=EDRu::readfile($logf);
        EDRu::appendfile("Uninstall logs\n$uo\n$msg->{msg}", $uof);
    } else {
        EDRu::appendfile("\n$msg->{msg}", $uof);
    }
    return $rtn;
}

sub pkg_install_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rootpath,$iof,$path);

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $iof=EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg});
    $path=$padv->installpath_sys($sys, $pkg);
    $sys->cmd("_cmd_pkg $rootpath install --accept -g $path $pkg->{pkg} 2>$iof 1>&2");
    return 1;
}

sub pkg_uninstall_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rootpath,$uof);

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    $sys->cmd("_cmd_pkg $rootpath uninstall $pkg->{pkg} 2>$uof 1>&2");
    return 1;
}

sub pkg_version_sys {
    my ($padv,$sys,$pkg,$prevpkgs_flag,$pbe_flag)=@_;
    my ($rootpath,$pkgname,$vers);

    $pkgname=$pkg->{pkg};

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $vers=$sys->cmd("_cmd_pkg $rootpath info $pkgname 2>/dev/null | _cmd_awk '/Version:/ {print \$2}'");
    return $padv->pkg_version_cleanup($vers);
}

sub patch_version_sys {
    my ($padv,$sys,$patch,$force_flag)=@_;
    my ($rootpath,$patchname,$vers);

    $patchname=$patch->{patchname};
    if ($force_flag || !$sys->{patchver}{$patchname}) {
        $rootpath=Cfg::opt('rootpath')||'';
        $rootpath="-R $rootpath" if ($rootpath);
        $vers=$sys->cmd("_cmd_pkg $rootpath info $patchname 2>/dev/null | _cmd_awk '/Version:/ {print \$2}'");
        $sys->set_value("patchver,$patchname",$vers);
    }
    return $sys->{patchver}{$patchname};
}

sub sru_version_sys {
    my ($padv,$sys)=@_;
    my ($rootpath,$vers,$sru_vers);

    # Todo: Oracle will use dot.dot version scheme.
    # - https://blogs.oracle.com/Solaris11Life/entry/solaris_11_process_enhancement_no

    $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    $vers=$sys->cmd("_cmd_pkg $rootpath info entire 2>/dev/null | _cmd_awk '/Branch:/ {print \$2}'");

    $sru_vers=0;
    if ($vers=~/0\.\d+\.\d+\.(\d+)/) {
        $sru_vers=$1;
    }
    return $sru_vers;
}

# get information for pkg
sub pkginfovalue_sys {
    my ($padv,$sys,$param,$pkg)=@_;

    # Solaris 11 packages do not support PSTAMP attribute.
    return if ($param eq 'PSTAMP');

    # need add codes if want to check other attributes.
    return;
}

sub vrtspkgversdeps_script {
    my $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    my $script=<<'VPVD';
#!/bin/sh

rootpath="__ROOTPATH__"

vrtspkgs=`/usr/bin/pkg $rootpath info -l 'VRTS*' 2>/dev/null | /usr/bin/awk '
    /Name:/ { pkg=$2 }
    /Version:/ {vers=$2; print pkg,vers}'`

[ -z "$vrtspkgs" ] && exit 0

reqlist=`/usr/bin/pkg $rootpath search -Hl 'depend::VRTS*' 2>/dev/null | /usr/bin/awk '
    { idx=index($3, "@");
      if (idx>0) {
          pkg=substr($3,1,idx-1);
      } else {
          pkg=$3;
      }
      idx=index($4, "@");
      dep=substr($4,6,idx-6);
      print pkg,dep;
    }'`

echo "$vrtspkgs" | while read pkg vers; do
    echo "$pkg $vers\c"
    echo "$reqlist" | /usr/bin/awk '$1 == "'"$pkg"'" { printf " %s",$2 }'
    echo
done
VPVD
    $script=~s/__ROOTPATH__/$rootpath/g;
    return $script;
}

# return value: 0 - verify ok; 1 - otherwise
sub pkg_verify_sys {
    my ($padv,$sys,$pkgname)=@_;
    return 1 if (!$pkgname);
    my $rootpath=Cfg::opt('rootpath')||'';
    $rootpath="-R $rootpath" if ($rootpath);
    my $rtn=$sys->cmd("_cmd_pkg $rootpath verify $pkgname");
    my $msg=Msg::new("'pkg $rootpath verify $pkgname' on $sys->{sys} return:\n$rtn");
    $sys->set_value("pkg_verify,$pkgname", $msg->{msg});
    return EDR::cmdexit();
}

# determine all NICs on $sys
# return a reference to an array holding the NICs
sub systemnics_sys {
    my ($padv,$sys,$bnics_flag,$brnics_flag)=@_;
    my (@nics,$do,$anics,$bnics,$snics);
    return ($sys->{systemnics}) if ($sys->{systemnics});

    $do=$sys->cmd("_cmd_dladm show-link -z global -p -o LINK 2>/dev/null | _cmd_sort -u");
    @nics=split(/\n/,$do);

    # remove nics which is part of an aggregated interface
    $anics=\@nics;
    if($bnics_flag) {
        ($bnics,$snics)=$padv->bondednics_sys($sys);
        push(@$anics,@{$bnics});
        $anics=EDRu::arrdel($anics,@{$snics});
        $anics=EDRu::arruniq(@$anics);
    }
    if ($brnics_flag) {
        ($bnics,$snics)=$padv->bridgednics_sys($sys);
        # the bridged NICs will be showed with commmand dladm show-link.
        # We don't push @{$bnics} into the $anics array because:
        # Command dladm show-bridge will show the bridge name as it is.
        # Command dladm show-link will show the bridge link name which has appended '0'
        $anics=EDRu::arrdel($anics,@{$snics});
        $anics=EDRu::arruniq(@$anics);
    }
    $sys->{systemnics}=$anics;
    return $anics;
}

sub bridgednics_sys {
    my ($padv,$sys)=@_;
    my (@bnics,@snics,@nics,$rtn);

    $rtn = $sys->cmd("_cmd_dladm show-bridge -p -o BRIDGE 2>/dev/null");
    @bnics = split(/\n+/,$rtn);
    for my $bridge (@bnics) {
        $rtn = $sys->cmd("_cmd_dladm show-bridge -l -p -o LINK $bridge 2>/dev/null");
        @nics=split(/\n+/,$rtn);
        push(@snics,@nics);
    }
    return (\@bnics,EDRu::arruniq(@snics));
}

sub bondednics_sys {
    my ($padv,$sys)=@_;
    my (@snics,@nics,@bondednics,$rtn);

    $rtn = $sys->cmd("_cmd_dladm show-aggr -p -o LINK");
    @bondednics = split(/\s+/,$rtn);
    for my $aggr (@bondednics) {
        $rtn = $sys->cmd("_cmd_dladm show-link -p -o OVER $aggr");
        @nics = split(/\s+/,$rtn);
        push(@snics,@nics);
    }

    $sys->set_value('bondednics','push',@bondednics);
    return (\@bondednics,EDRu::arruniq(@snics));
}

sub configure_static_ipv4_sys {
    my ($padv, $sys, $nic, $ip, $mask) = @_;
    my ($output, @fields, $persistent_flag);
    $output = $sys->cmd("_cmd_ipadm show-if -o all $nic 2>/dev/null|_cmd_grep $nic");
    if (EDR::cmdexit()) {
        # create-ip if the nic does not exist
        $sys->cmd("_cmd_ipadm create-ip $nic 2>/dev/null");
    } else {
        @fields = split(/\s+/m, $output);
        $persistent_flag = $fields[5];
        # delete-ip and create-ip for non-persistent nic
        if ($persistent_flag !~ /\d+/) {
            $sys->cmd("_cmd_ipadm delete-ip $nic 2>/dev/null");
            $sys->cmd("_cmd_ipadm create-ip $nic 2>/dev/null");
        }
    }
    # check if ip addr is already plumbed on this nic
    $output = $sys->cmd("_cmd_ipadm 2>/dev/null|_cmd_grep $nic|_cmd_grep $ip\/");
    return 1 if ($output =~ /static\s+ok\s+/mx);

    $sys->cmd("_cmd_ipadm create-addr -T static -a $ip $nic 2>/dev/null");
    return 0 if (EDR::cmdexit());
    $sys->cmd("echo '$ip $mask' >> /etc/netmasks 2>/dev/null");
    return 1;
}

sub configure_static_ipv6_sys {
    my ($padv, $sys, $nic, $ip, $mask) = @_;
    my ($output, @fields, $persistent_flag,$nic_pfix,$pre_mask);
    $output = $sys->cmd("_cmd_ipadm show-if -o all $nic 2>/dev/null|_cmd_grep $nic");
    if (EDR::cmdexit()) {
        # create-ip if the nic does not exist
        $sys->cmd("_cmd_ipadm create-ip $nic 2>/dev/null");
    } else {
        @fields = split(/\s+/m, $output);
        $persistent_flag = $fields[5];
        # delete-ip and create-ip for non-persistent nic
        if ($persistent_flag !~ /\d+/) {
            $sys->cmd("_cmd_ipadm delete-ip $nic 2>/dev/null");
            $sys->cmd("_cmd_ipadm create-ip $nic 2>/dev/null");
        }
    }
    # check if ip addr is already plumbed on this nic
    $output = $sys->cmd("_cmd_ipadm show-addr 2>/dev/null|_cmd_grep $nic");

    if ($output =~ /$nic\/(\S+)\s+static\s+ok\s+$ip\/(\d+)/mx){    # same ip exists
	$nic_pfix=$1;
        $pre_mask=$2;
        if ($pre_mask==$mask){
	    return 1;
        }else{
	    sys->cmd("_cmd_ipadm delete-addr $nic/$nic_pfix 2>/dev/null");
	}
    }elsif ($output !~/v6\s+addrconf\s+ok\s+/mx){
        $sys->cmd("_cmd_ipadm create-addr -T addrconf $nic 2>/dev/null");
    }

    $sys->cmd("_cmd_ipadm create-addr -T static -a $ip/$mask $nic 2>/dev/null");
    return 0 if (EDR::cmdexit());
    return 1;
}

package Padv::Sol11x64;
@Padv::Sol11x64::ISA = qw(Padv::Sol11sparc);

sub init_padv {
    my $padv=shift;
    $padv->{arch}='i86pc';
    $padv->{name}='Solaris 11 x64';
    $padv->{vers}='5.11';
    $padv->{cmd}{pkg}='/usr/bin/pkg';
    $padv->{cmd}{sh}='/usr/sunos/bin/sh';
    $padv->{cmd}{openssl}='/usr/bin/openssl';
    return;
}

1;

