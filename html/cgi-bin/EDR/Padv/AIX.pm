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
package Padv::AIX;
use strict;
@Padv::AIX::ISA = qw(Padv);

sub padvs { return [ qw(AIX51 AIX52 AIX53 AIX61 AIX71) ]; }

sub init_plat {
    my ($padv)=@_;
    $padv->{arch}='powerpc';
    $padv->{plat}='AIX';
    $padv->{name}='AIX';
    $padv->{pkgpath}='pkgs';
    $padv->{patchpath}='patches';

    # Define platform specific commands
    $padv->{cmd}{awk}='/usr/bin/awk';
    $padv->{cmd}{cat}='/usr/bin/cat';
    $padv->{cmd}{chgrp}='/usr/bin/chgrp';
    $padv->{cmd}{chmod}='/usr/bin/chmod';
    $padv->{cmd}{chown}='/usr/bin/chown';
    $padv->{cmd}{cp}='/usr/bin/cp';
    $padv->{cmd}{cpp}='/usr/bin/cp -P';
    $padv->{cmd}{cut}='/usr/bin/cut';
    $padv->{cmd}{date}='/usr/bin/date';
    $padv->{cmd}{dd}='/usr/bin/dd';
    $padv->{cmd}{dfk}='/usr/bin/df -kt';
    $padv->{cmd}{diff}='/usr/bin/diff';
    $padv->{cmd}{dirname}='/usr/bin/dirname';
    $padv->{cmd}{du}='/usr/bin/du';
    $padv->{cmd}{echo}='/usr/bin/echo';
    $padv->{cmd}{egrep}='/usr/bin/egrep';
    $padv->{cmd}{find}='/usr/bin/find';
    $padv->{cmd}{getconf}='/usr/bin/getconf';
    $padv->{cmd}{grep}='/usr/bin/grep';
    $padv->{cmd}{groupadd}='/usr/bin/mkgroup';
    $padv->{cmd}{groupdel}='/usr/sbin/rmgroup';
    $padv->{cmd}{groups}='/usr/bin/groups';
    $padv->{cmd}{gunzip}='/usr/bin/gunzip';
    $padv->{cmd}{head}='/usr/bin/head';
    $padv->{cmd}{hostname}='/usr/bin/hostname';
    $padv->{cmd}{id}='/usr/bin/id';
    $padv->{cmd}{ifconfig}='/usr/sbin/ifconfig';
    $padv->{cmd}{kill}='/usr/bin/kill';
    $padv->{cmd}{ln}='/usr/bin/ln';
    $padv->{cmd}{ls}='/usr/bin/ls';
    $padv->{cmd}{mkdir}='/usr/bin/mkdir';
    $padv->{cmd}{mkdirp}='/usr/bin/mkdir -p';
    $padv->{cmd}{mount}='/usr/sbin/mount';
    $padv->{cmd}{umount}='/usr/sbin/umount';
    $padv->{cmd}{mv}='/usr/bin/mv';
    $padv->{cmd}{netstat}='/usr/bin/netstat';
    $padv->{cmd}{nm}='/usr/bin/nm';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{nslookup}='/usr/bin/nslookup';
    $padv->{cmd}{ntpdate}='/usr/sbin/ntpdate';
    $padv->{cmd}{openssl}='/usr/bin/openssl';
    $padv->{cmd}{ping}='/usr/sbin/ping';
    $padv->{cmd}{ps}='/usr/bin/ps';
    $padv->{cmd}{rcp}='/usr/bin/rcp';
    $padv->{cmd}{rm}='/usr/bin/rm';
    $padv->{cmd}{rmr}='/usr/bin/rm -rf';
    $padv->{cmd}{rmdir}='/usr/bin/rm -rf';
    $padv->{cmd}{rsh}='/usr/bin/rsh';
    $padv->{cmd}{scp}='/usr/bin/scp';
    $padv->{cmd}{sed}='/usr/bin/sed';
    $padv->{cmd}{sh}='/usr/bin/sh';
    $padv->{cmd}{shutdown}='/usr/sbin/shutdown -r';
    $padv->{cmd}{sleep}='/usr/bin/sleep';
    $padv->{cmd}{sort}='/usr/bin/sort';
    $padv->{cmd}{ssh}='/usr/bin/ssh';
    $padv->{cmd}{strings}='/usr/bin/strings';
    $padv->{cmd}{su}='/usr/bin/su';
    $padv->{cmd}{tail}='/usr/bin/tail';
    $padv->{cmd}{tar}='/usr/bin/tar';
    $padv->{cmd}{tee}='/usr/bin/tee';
    $padv->{cmd}{touch}='/usr/bin/touch';
    $padv->{cmd}{tput}='/usr/bin/tput';
    $padv->{cmd}{tr}='/usr/bin/tr';
    $padv->{cmd}{uname}='/usr/bin/uname';
    $padv->{cmd}{uniq}='/usr/bin/uniq';
    $padv->{cmd}{vmo}='/usr/sbin/vmo';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxkeyless}='/opt/VRTSvlic/bin/vxkeyless';
    $padv->{cmd}{vxlicrep}='/sbin/vxlicrep';
    $padv->{cmd}{vxlicinst}='/sbin/vxlicinst';
    $padv->{cmd}{vxtune}='/usr/sbin/vxtune';
    $padv->{cmd}{wc}='/usr/bin/wc';
    $padv->{cmd}{which}='/usr/bin/which';
    $padv->{cmd}{yes}='/usr/bin/yes';
    $padv->{cmd}{cksum}='/usr/bin/cksum';

    # Define AIX specific commands
    $padv->{cmd}{entstat}='/usr/bin/entstat';
    $padv->{cmd}{genkex}='/usr/bin/genkex';
    $padv->{cmd}{hostid}='/usr/sbin/hostid';
    $padv->{cmd}{installp}='/usr/sbin/installp';
    $padv->{cmd}{inutoc}='/usr/sbin/inutoc';
    $padv->{cmd}{ldd}='/usr/bin/ldd';
    $padv->{cmd}{lppchk}='/usr/bin/lppchk';
    $padv->{cmd}{lsattr}='/usr/sbin/lsattr';
    $padv->{cmd}{lsdev}='/usr/sbin/lsdev';
    $padv->{cmd}{lslpp}='/usr/bin/lslpp';
    $padv->{cmd}{lsnim}='/usr/sbin/lsnim';
    $padv->{cmd}{lsps}='/usr/sbin/lsps';
    $padv->{cmd}{model}='/usr/bin/uname -M';
    $padv->{cmd}{nim}='/usr/sbin/nim';
    $padv->{cmd}{oslevel}='/usr/bin/oslevel';
    $padv->{cmd}{odmget}='/usr/bin/odmget';
    $padv->{cmd}{prtconf}='/usr/sbin/prtconf';
    $padv->{cmd}{strload}='/usr/sbin/strload';
    $padv->{cmd}{useradd}='/usr/sbin/useradd';
    $padv->{cmd}{usermod}='/usr/sbin/usermod';
    $padv->{cmd}{sshkeygen}='/usr/bin/ssh-keygen';
    $padv->{cmd}{sshkeyscan}='/usr/bin/ssh-keyscan';
    $padv->{cmd}{lparstat}='/usr/bin/lparstat';
    $padv->{cmd}{chdev}='/usr/sbin/chdev';
    $padv->{cmd}{swvpdmgr}='/usr/sbin/swvpdmgr';
    return;
}

# this set of commands is executed during info_sys before the padv objects
# are created and therefore full command paths are required

sub arch_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('/usr/bin/uname -p');
}

sub platvers_sys {
    my ($padv,$sys)=@_;
    my ($uname,$vers,$plat,$v2);
    $uname=$sys->cmd('/usr/bin/uname -a');
    ($plat,undef,$vers,$v2)=split(/\s+/m,$uname,5);
    return "$v2.$vers";
}

sub padv_sys {
    my($padv,$sys)=@_;
    my $vers=$sys->{platvers};
    return 'AIX61' if ((EDRu::compvers('6.1',$vers)==2) &&
                       (EDR::get2('padv_unbounded','AIX61')));
    $vers=~s/\.//mg;
    return "AIX$vers";
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
    my $ifc4=$sys->cmd("/usr/sbin/ifconfig -a inet 2>/dev/null | /usr/bin/grep 'inet.*netmask' | /usr/bin/grep -v '127.0.0.1'");
    return ($ifc4 =~ /inet \d+\.\d+\.\d+\.\d+/m) ? 1 : 0;
}

sub ipv6_sys {
    my ($padv,$sys)=@_;
    my $ifc6=$sys->cmd("/usr/sbin/ifconfig -a inet6 2>/dev/null | /usr/bin/grep -v 'inet6 ::' | /usr/bin/grep 'inet6 .*/'");
    return ($ifc6 =~ m/inet6 .*\/\d+/) ? 1 : 0;
}

# DONE with info_sys routines that require full command paths

sub completion_messages {
    my ($script,$msg);
    $script=EDR::get('script');
    if(Cfg::opt(qw(install upgrade patchupgrade hotfixupgrade))) {
        $msg=Msg::new("When $script installs software, some software may be applied rather than committed. It is the responsibility of the system administrator to commit the software, which can be performed later with the -c option of the installp command.\n");
        $msg->bold;
    }
    return;
}

sub chown_root_sys {
    my ($padv,$sys,$file)=@_;
    # chown root:system on AIX.
    return $sys->cmd("_cmd_chown -R root:system $file 2>/dev/null");
}

sub cpu_sys {
    my ($padv,$sys)=@_;
    my $ret=$sys->cmd('_cmd_prtconf 2>/dev/null');
    my ($cpu_count,$cpu_type,$cpu_speed,@cpus);

    foreach my $line (split(/\n+/, $ret)) {
        if ($line =~ /Number Of Processors\s*:\s*(.*)/m) {
            $cpu_count = EDRu::despace($1);
        }
        if ($line =~ /Processor Clock Speed\s*:\s*(.*)/m) {
            $cpu_speed = EDRu::despace($1);
        }
        if ($line =~ /Processor Type\s*:\s*(.*)/m) {
            $cpu_type = EDRu::despace($1);
        }
    }

    foreach my $line (grep {/proc/m} split(/\n+/, $ret)) {
        my @fields = split(/\s+/m, $line);
        my %cpu = ( NAME => EDRu::despace($fields[1]),
                    TYPE => $cpu_type,
                    SPEED => $cpu_speed,
                  );
        push(@cpus, \%cpu);
    }
    return \@cpus;
}

sub cpu_number_sys {
    my ($padv,$sys)=@_;
    my $ret = $sys->cmd("_cmd_prtconf 2>/dev/null | _cmd_grep '^Number Of Processors'");
    $ret =~ s/^Number Of Processors\s*:\s*//m;
    $ret =~ s/\s*$//m;
    return $ret;
}

sub cpu_speed_sys {
    my ($padv, $sys)=@_;
    my $ret = $sys->cmd("_cmd_prtconf 2>/dev/null | _cmd_grep '^Processor Clock Speed'");
    $ret =~ s/^Processor Clock Speed\s*:\s*//m;
    $ret =~ s/\s*$//m;
    return $ret;
}

sub distro_sys { return 'AIX'; }

# Check if the driver is loaded
sub driver_sys {
    my ($padv,$sys,$driver)=@_;
    my $loaded=$sys->cmd("_cmd_strload -q -d $driver");
    chomp($loaded);
    return '' if (($loaded=~/no$/m) || (!$loaded));
    return "$loaded";
}

sub device_attribute_value_sys {
    my ($padv,$sys,$device,$attribute)=@_;
    my ($value);

    $value = $sys->cmd("_cmd_lsattr -El $device -a $attribute -F value 2>/dev/null");
    return $value;
}

sub fileset_sys {
    my ($padv,$sys,$pkg,$nogz)=@_;
    my ($fileset,$type,$separator);

    $separator = ($^O =~ /Win32/i)? '\\':'/';

    $type='pkg';
    $type='patch' if (ref($pkg)=~/^Patch/m);
    $fileset = ((($sys->{islocal}) || (Cfg::opt('pkgpath'))) &&
                ($pkg->{file}!~/gz$/m)) ? $pkg->{file} :
                EDR::tmpdir().$separator.$type.'_'.EDRu::basename($pkg->{file});
    $fileset=~s/\.gz$//m if ($nogz);
    return $fileset;
}

# Returns a reference to an array holding the NICs connected to the default gateway/router
sub gatewaynics_sys {
    my ($padv,$sys)=@_;
    my (@values,@nics,@lines,$do);
    $do=$sys->cmd('_cmd_netstat -nr 2>/dev/null');
    @lines=split(/\n/,$do);
    for my $line (@lines) {
        @values = split(/\s+/m,$line);
        if ($values[2] eq 'UG') {
            push @nics,$values[5];
        }
    }
    return EDRu::arruniq(sort @nics);
}

# determine all IP's on $sys
sub ips_sys {
    my ($padv,$sys)=@_;
    my (@i,@ips,$ip);
    $ip=$sys->cmd("_cmd_ifconfig -a | _cmd_grep netmask | _cmd_awk '{print \$2}'");
    @i=split(/\s+/m,$ip);
    for my $ip (@i) {
        push(@ips,$ip) if ((EDRu::isip($ip)==1) &&
            ($ip ne '0.0.0.0') && ($ip ne '127.0.0.1'));
    }
    return \@ips;
}

sub islocal_sys {
    my ($padv,$sys)=@_;
    my ($ping,$ifc4,$ifc6,$ip);
    $ping=EDR::cmd_local("/usr/sbin/ping -c 1 $sys->{sys} 2>/dev/null | _cmd_grep '^PING' 2>/dev/null");
    (undef,$ip,undef) = split(/[\(\)]/m, $ping, 3);
    $ifc4=EDR::cmd_local("/usr/sbin/ifconfig -a inet | _cmd_grep 'inet $ip '")
        if (EDRu::ip_is_ipv4($ip));
    $ifc6=EDR::cmd_local("/usr/sbin/ifconfig -a inet6 | _cmd_grep 'inet6 $ip/'")
        if (EDRu::ip_is_ipv6($ip));
    return 1 if (($ifc4) || ($ifc6));
    return 0;
}

sub kerbit_sys {
    my ($padv,$sys)=@_;
    my $kernelbit=$sys->cmd('/usr/bin/getconf KERNEL_BITMODE');
    return $kernelbit;
}

sub memory_size_sys {
    my ($padv, $sys)=@_;
    my $ret = $sys->cmd("/usr/bin/getconf REAL_MEMORY 2>/dev/null");
    return "$ret KB";
}

# load a driver on $sys
sub load_driver_sys {
    my ($padv,$sys,$driver)=@_;
    $sys->cmd("_cmd_strload -d $driver");
    return;
}

sub media_filesetvers {
    my ($padv,$pkgpatch,$dir)=@_;
    my ($vers,$bi,$ns,$patch,$ds,@f,$line,$pobj);
    if (-f "$dir/.toc") {
        $bi=($pkgpatch->{file}=~/image/m) ? 'image' : 'bff';
        $pobj = (ref($pkgpatch)=~/^Patch/m) ? ($pkgpatch->{patchname}) :
            ($pkgpatch->{pkgname}) ? $pkgpatch->{pkgname} : $pkgpatch->{pkg};
        EDR::die ("$pobj not defined") if (!$pobj);
        $ds='[. ]'; # needed or $pobj looks like an array, didn't want \[ chaos
        $ns='[0-9]'; # more of the above
        $line=EDR::cmd_local("_cmd_grep '^$pobj$ds' $dir/.toc | _cmd_grep -v $pobj.$bi | _cmd_grep $ns | _cmd_grep -v { 2>/dev/null" );
        return '' if (!$line);
        @f = split(/\s+/m, $line);
        $vers = sprintf('%d.%d.%d.%d', split (/\./m, $f[1]));
    } elsif (($padv->localplat eq 'AIX') && ($pkgpatch->{file}!~/\.gz$/m)) {
        # hack for broken VRTSpbx
        $line=EDR::cmd_local("_cmd_installp -L -d $pkgpatch->{file} | _cmd_grep ::");
        @f = split(/:/m, $line);
        $vers = sprintf('%d.%d.%d.%d', split (/\./m, $f[2]));
    }
    return $vers;
}

sub media_patch_file {
    my ($padv,$patch,$patchdir)=@_;
    my $pobj = $patch->{patchname};

    if ($^O =~ /Win32/i) {
        for my $file ("$patchdir\\$pobj.bff.gz",
                      "$patchdir\\$pobj.bff",
                      "$patchdir\\$pobj.image.gz",
                      "$patchdir\\$pobj.image") {
            return $file if (-e $file);
        }
    } else {
        for my $file ("$patchdir/$pobj.bff.gz",
                      "$patchdir/$pobj.bff",
                      "$patchdir/$pobj.image.gz",
                      "$patchdir/$pobj.image") {
            return $file if (-e $file);
        }
    }
    return '';
}

sub media_patch_version { return media_filesetvers(@_); }

sub media_pkg_file {
    my ($padv,$pkg,$pkgdir)=@_;
    return '' unless ($pkgdir);
    for my $file ("$pkgdir/$pkg->{pkg}.bff.gz", "$pkgdir/$pkg->{pkg}.bff",
                  "$pkgdir/$pkg->{pkg}.image.gz", "$pkgdir/$pkg->{pkg}.image") {
        return $file if (-e $file);
    }
    return '';
}

sub patches_sys {
    my ($padv,$sys)=(@_);
    my($out,$pkgname,$vers);
    $out=$sys->cmd("_cmd_lslpp -Lcq 'VRTS*' 2>/dev/null");
    for my $line (split(/\n/,$out)) {
        (undef,$pkgname,$vers,undef) = split(/:/,EDRu::despace($line),4);
        $sys->set_value("patchvers,$pkgname",'push',$vers) unless (EDRu::inarr($vers,@{$sys->{patchvers}{$pkgname}}));
    }
    return '';
}

sub media_pkg_version { return media_filesetvers(@_); }

# determine the netmask of the base IP configured on a NIC
sub netmask_sys {
    my ($padv,$sys,$nic,$ipv,$ip)=@_;
    my ($nm);
    $ipv= '4' if (!defined $ipv || $ipv eq '');

    if ($ipv eq '4' and $sys->{ipv4}) {
        if ($ip) {
            $nm=$sys->cmd("_cmd_ifconfig $nic inet 2>/dev/null | _cmd_grep 'inet $ip'");
            if ($nm=~/netmask\s+(0x)?(\S*)/mx) {
                $nm=$2;
            } else {
                $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep netmask");
                if ($nm=~/netmask\s+(0x)?(\S*)/mx) {
                    $nm=$2;
                }
            }
        } else {
            $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep netmask");
            if ($nm=~/netmask\s+(0x)?(\S*)/mx) {
                $nm=$2;
            }
        }
    } elsif ($ipv eq '6' and $sys->{ipv6}) {
        if ($ip) {
            $nm=$sys->cmd("_cmd_ifconfig $nic inet6 2>/dev/null | _cmd_grep 'inet6 $ip'");
            if ($nm=~ m/inet6 .*\/(\d+)/) {
                $nm=$1;
            } else {
                $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep 'inet6'");
                if ($nm=~ m/inet6 .*\/(\d+)/) {
                    $nm=$1;
                }
            }
        } else {
            $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep 'inet6'");
            if ($nm=~ m/inet6 .*\/(\d+)/) {
                $nm=$1;
            }
        }
    }
    return ($nm || '');
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


# determin ip on $nic
sub nic_ips_sys {
    my ($padv,$sys,$nic)=@_;
    my ($ipv6,@ips,$do,@ip_lines);
    $do=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep 'inet ' | _cmd_awk '{ print \$2 }'");
    @ips=split(/\s+/m,$do);
    $do=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_grep 'inet6 ' | _cmd_awk '{ print \$2}'");
    @ip_lines=split(/\s+/m,$do);
    for my $ip (@ip_lines) {
        if ($ip =~/(.*)\//m) {
            $ipv6 = $1;
            if ($ipv6 =~ /(.*)%/m) {
                push (@ips,$1);
            } else {
                push (@ips,$ipv6);
            }
        }
    }
    return \@ips;
}

sub nic_speed_sys {
    my ($padv,$sys,$nic)=@_;
    my ($media_speed,$output,$need_detach,$adapter);
    # return "Not Applicable (Virtual Device)" if the specified NIC is an virtual NIC
    if (EDRu::inarr($nic ,@{$sys->padv->virtualnics_sys($sys)})) {
        return Msg::new("Not Applicable (Virtual Device)")->{msg};
    }
    if ($padv->is_bonded_nic_sys($sys,$nic)) {
        return Msg::new("Not Applicable (Link Aggregation)")->{msg};
    }

    if ($nic=~/(\d+)/m) {
        $adapter = "ent$1";
        $output = $sys->cmd("_cmd_lsdev -C -c adapter -t eth -s vlan -l $adapter 2>/dev/null");
        if ($output =~ /VLAN/m) {
            $output = $sys->cmd("_cmd_lsattr -E -l $adapter -a base_adapter 2>/dev/null | _cmd_grep '^base_adapter' | _cmd_awk '{print \$2}'");
            chomp $output;
            if ($output =~ /^ent(\d+)$/m) {
                $nic = "en$1";
            }
        }
    }

    # attach the specified NIC to get its speed.
    $need_detach=0;
    $output=$sys->cmd('_cmd_ifconfig -l 2>/dev/null');
    if ($output !~ /\b$nic\b/) {
        # the NIC is not in the list, need attach the NIC to check speed 
        $sys->cmd("_cmd_ifconfig $nic 2>/dev/null");
        sleep 3;
        $need_detach=1;
    }

    $media_speed='';
    $output=$sys->cmd("_cmd_entstat -d $nic 2>/dev/null | _cmd_grep -i speed");
    if ($output=~/^Media Speed Selected:\s*(.*)/m) {
        $media_speed=$1;
        if ($media_speed=~/Auto ?negotiation/m) {
            if ($output=~/^Media Speed Running:\s*(.*)/m) {
                $media_speed=$1;
            }
        }
    } elsif ($output=~/^Physical Port Speed:\s*(.*)/m) {
        $media_speed=$1;
    }

    if ($need_detach) {
        $sys->cmd("_cmd_ifconfig $nic detach 2>/dev/null");
    }
    return $media_speed;
}

# return 0 if patch is not installed or lower version is installed
# return 1 if equal or higher version is installed
sub ospatch_sys {
    my ($padv,$sys,$patch)=@_;
    my($iv,$pn,$pv);
    ($pn,$pv)=split(/-/m,$patch->{patch_vers},2);
    $iv=$padv->patch_version_sys($sys, $patch);
    return 1 if (EDRu::compvers($iv,$pv)==1);
    return 0;
}

sub hostid_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('_cmd_hostid 2>/dev/null');
}

sub model_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('_cmd_model 2>/dev/null');
}

sub partially_installed_pkgs_sys {
    my ($padv,$sys)=@_;
    my ($partial,@f,$pkg);

    $partial=$sys->cmd("_cmd_lslpp -l 2>/dev/null | _cmd_grep 'APPLYING'");
    for my $partial_pkg (split(/\n/,$partial)) {
        @f=split(/\s+/m,$partial_pkg);
        $pkg=$f[0];
        Msg::log("$pkg is partially installed on $sys->{sys}");
        $sys->set_value("pkgpartial,$pkg",1);
    }
    return '';
}

sub patch_copy_sys { return pkg_copy_sys(@_); }

sub patch_install_success_sys { return pkg_install_success_sys(@_); }

sub patch_install_sys { return pkg_install_sys(@_); }

sub patch_installed_sys {
    my ($padv,$sys,$patch)=@_;
    my ($pv);
    if ($sys->{patchvers}{$patch->{patchname}} &&
           EDRu::inarr($patch->{patchvers},@{$sys->{patchvers}{$patch->{patchname}}})) {
        Msg::log("Patch $patch->{patchname} is installed on $sys->{sys}");
        return 1;
    }
    Msg::log("Patch $patch->{patchname} is not installed on $sys->{sys}");
    return '';
}

sub patch_uninstall_success_sys {
    my ($padv,$sys,$patch)=(@_);
    my ($uof,$iv,$vers);
    $iv=$padv->patch_version_sys($sys, $patch, 1);
    $uof=EDRu::readfile(EDRu::outputfile('uninstall', $sys->{sys}, "patch.$patch->{patch_vers}"));
    if ((EDRu::compvers($iv,$patch->{patchvers}) == 0)) {
        Msg::log("$patch->{patchname} uninstall failed on $sys->{sys}\n$uof");
        return 0;
    }
    Msg::log("$patch->{patchname} uninstall successfully on $sys->{sys}\n$uof");
    return 1;
}

sub patch_uninstall_sys {
    my ($padv,$sys,$patch)=(@_);
    my ($pkgname,$uof);
    $sys->cmd('_cmd_installp -C');
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, "patch.$patch->{patch_vers}");
    $sys->cmd("_cmd_installp -r $patch->{patchname} $patch->{patchvers} 2>>$uof 1>&2");
    return '';
}

sub patch_remove_sys { return pkg_remove_sys(@_); }

sub patch_version_sys {
    my ($padv,$sys,$patch,$force_flag)=(@_);
    my ($iv,$pobj);
    $pobj = $patch->{patchname};
    if ($force_flag || !$sys->{patchvers}) {
        $iv=$sys->cmd("_cmd_lslpp -Lcq $pobj 2>/dev/null");
        (undef,undef,$iv,undef)=split(/:/,EDRu::despace($iv),4) if ($iv);
        return $iv;
    }
    # last version in installed patchvers array
    $iv=${$sys->{patchvers}{$pobj}}[$#{$sys->{patchvers}{$pobj}}] if ($sys->{patchvers}{$pobj});
    return $iv;
}

# ping a host, supports IPV4 and IPV6
# returns "" if successful, string if unsuccessful, opposite perl standard
# $sys can be a system name or IP and is scalar, not system object as ping_sys
sub ping {
    my ($padv,$sysip)=@_;
    my($ip,$ret);
    return '' if ($ENV{NOPING});
    $ret=EDR::cmd_local("_cmd_ping -c 1 $sysip 2>/dev/null");
    if (EDR::cmdexit() eq '0') {
        (undef, $ip, undef) = split(/[\(\)]/m, $ret, 3);
        return '' if (EDRu::isip($ip));
    }

    return 'noping';
}

sub pkg_copy_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($fileset,$tmpdir);
    $tmpdir=EDR::tmpdir();
    $fileset=$padv->fileset_sys($sys,$pkg);
    $padv->localsys->copy_to_sys($sys,$pkg->{file},$fileset)
        if ($fileset ne $pkg->{file});

    $sys->cmd("_cmd_gunzip $fileset") if ($pkg->{file}=~/gz$/m);
    if ($^O =~ /Win32/i){
        EDR::cmd_local('type nul>"'.$pkg->copy_mark_sys($sys).'" 2>nul');
    } else {
        EDR::cmd_local('_cmd_touch '.$pkg->copy_mark_sys($sys));
    }
    return '';
}

sub pkg_install_success_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($summary,$io,$success,$line,$pobj,$pp);
    # code to case where one of USR/ROOT is SUCCESS and the other is FAIL
    # May be more than one SUCCESS but, should be none "FAILED" or "CANCELED".
    $summary=$success=0;
    $pp = (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : "patch.$pkg->{patch_vers}";
    $io=EDRu::readfile(EDRu::outputfile('install', $sys->{sys}, $pp));
    for my $line (split(/\n/, $io)) {
        if ($line =~ /^Installation Summary/m) {
            $summary=1;
            next;
        }
        next if ($summary==0);
        return 0 if ($line =~ /(FAILED|CANCELED|CANCELLED)\s*$/mx);
        if ($line =~ /^(\S+)\s+(.*)\s+SUCCESS\s*$/mx) {
            $pobj=$1;
            $success=1;
            return 0 if
               ($sys->cmd("_cmd_lslpp -l $pobj 2>/dev/null | _cmd_grep 'BROKEN'"));
        }
    }

    if ($success && !$pkg->{donotcheckinstalllog} && $io =~ /\breboot\b/mi) {
        if ((ref($pkg)=~/^Pkg/m) && !EDRu::inarr($pkg->{pkg}, @{$sys->{requirerebootpkgs}})) {
            $sys->set_value('requirerebootpkgs', 'push', $pkg->{pkg});
        } elsif ((ref($pkg)=~/^Patch/m) && !EDRu::inarr($pkg->{patchname}, @{$sys->{requirerebootpatches}})) {
            $sys->set_value('requirerebootpatches', 'push', $pkg->{patchname});
        }
    }
    return $success;
}

# can also be passed a patch
sub pkg_install_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($export_cmd,$pps,$iof,$fileset,$pp);

    if (ref($pkg)=~/^Pkg/m) {
        $pps = $pp = $pkg->{pkg};
    } else {
        $pp = $pkg->{patch_vers};
        $pps = "patch.$pp";
    }
    $iof=EDRu::outputfile('install', $sys->{sys}, $pps);
    $fileset=$padv->fileset_sys($sys,$pkg,1);

    if ($pkg->{has_install_export_cmd}) {
       # export environment variable for some pkg/patch install scripts
       $export_cmd = $sys->{install_export_cmd} if ($sys->{install_export_cmd});
    }

    # run cleanup in case of failed prior install
    $sys->cmd("_cmd_installp -C 2>>$iof 1>&2");
    $sys->cmd("$export_cmd _cmd_installp -aXd $fileset $pp 2>>$iof 1>&2");
    return '';
}

sub pkg_remove_sys {
    my ($padv,$sys,$pkg)=@_;
    my $fileset=$padv->fileset_sys($sys,$pkg,1);
    if ($^O =~ /Win32/i){
        my $localsys = EDR::get('localsys');
        my $localpadv = $localsys->padv();
        $localpadv->rm_sys($pkg->copy_mark_sys($sys));
    } else {
        EDR::cmd_local('_cmd_rmr '. $pkg->copy_mark_sys($sys));
    }
    $sys->cmd("_cmd_rmr $fileset") if ($fileset ne $pkg->{file});
    return '';
}

sub pkg_uninstall_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($uof,$pkgname);
    $sys->cmd('_cmd_installp -C');
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    $pkgname = ($pkg->{pkgname}) ? $pkg->{pkgname} : $pkg->{pkg};
    if ($pkg->{force_uninstall}) {
        $sys->cmd("cd /lpp/$pkgname/deinstl/$pkgname/; _cmd_rmr */$pkgname.unconfig_u");
    }
    $sys->cmd("_cmd_installp -u $pkgname 2>$uof 1>&2");
    return '';
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
    my $desc=$sys->cmd("_cmd_lslpp -Lcq $pkg->{pkg} 2>/dev/null");

    # Do not use split(/:/) since the package description may have ':'
    $desc=~s/^([^:]*:){7}//m;
    $desc=~s/(:[^:]*){10}$//m;
    return $desc;
}

sub pkg_version_sys {
    my ($padv,$sys,$pkg,$prevpkgs_flag)=@_;
    my ($iv,$pobj);
    # if $prevpkgs_flag=1, then do not check pkg's previous name.
    $pobj = (ref($pkg)=~/^Patch/m) ? ($pkg->{patchname}) :
        ($pkg->{pkgname}) ? $pkg->{pkgname} : $pkg->{pkg};
    $iv=$sys->cmd("_cmd_lslpp -Lcq $pobj 2>/dev/null");
    if (!$iv && !$prevpkgs_flag){
        for my $pkgi (@{$pkg->{previouspkgnames}}) {
            $iv =$sys->cmd("_cmd_lslpp -Lcq $pkgi 2>/dev/null");
            last if($iv);
        }
    }
    (undef,undef,$iv,undef)=split(/:/m,EDRu::despace($iv),4) if ($iv);
    return $iv;
}

sub pkg_installtime_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($str,$it,$pobj);
    $pobj=(ref($pkg)=~/^Patch/m) ? ($pkg->{patchname}) :
        (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : $pkg;

    $it='';
    for my $pkgi ($pobj,@{$pkg->{previouspkgnames}}) {
        $str=$sys->cmd("_cmd_lslpp -ch $pkgi 2> /dev/null");
        if ($str =~ /COMPLETE:(.*):/) {
            $it = $1;
            last;
        }
    }
    return $it;
}

# determine the NICs on $sys which have IP addresses configured on them
# return a reference to an array holding the NICs
sub publicnics_sys {
    my ($padv,$sys)=@_;
    my (@pnics,$j,@nics,$netstat,$ifconfig,$line);
    $netstat=$sys->cmd('_cmd_netstat -i');
    @nics=split(/\n/,$netstat);
    for my $nic (@nics) {
        ($nic,$j)=split(/\s+/m,$nic,2);
        if (($nic=~/en/m) && (!EDRu::inarr($nic,@pnics))){
            $ifconfig=$sys->cmd("_cmd_ifconfig $nic");
            for my $line (split(/\n+/, $ifconfig)) {
                if ( $line =~ /^\s*inet\s/ || $line =~ /^\s*inet6\s/) {
                    push(@pnics,$nic);
                    last;
                }
            }
        }
    }
    return \@pnics;
}

sub swap_size_sys {
    my ($padv,$sys)=@_;

    my $ret = $sys->cmd("_cmd_lsps -s 2>/dev/null | _cmd_grep -v 'Total'");
    if ($ret =~ /\s+([\d\.]+)(\S+)\s+([\d\.]+)\%/mx) {
        my $freeswap = int($1 * (100 - $3) / 100);
        return "$freeswap" . "$2";
    }
    return '';
}

# load a driver on $sys
# determine all NICs on $sys
# return a reference to an array holding the NICs
sub systemnics_sys {
    my ($padv,$sys,$bnics_flag)=@_;
    my (@nics2,$anics,$snics,@nics1,$bnics);
    my $do=$sys->cmd("_cmd_lsdev -C -t en | _cmd_awk '{print \$1}' | _cmd_sort");
    my @nics=split(/\s+/m,$do);

    # To check if a network interface is available
    $do=$sys->cmd("_cmd_lsdev -Cc adapter | _cmd_grep 'ent' | _cmd_awk '{print \$1}' | _cmd_sort");
    @nics1=split(/\s+/m,$do);
    for my $nic (@nics) {
       if ($nic=~/(\d+)/m) {
            push(@nics2,$nic) if(!EDRu::inarr("ent$1",@nics1));
       }
    }

    $anics=EDRu::arrdel(\@nics,@nics2);
    if($bnics_flag){
        ($bnics,$snics)=$padv->bondednics_sys($sys);
        push(@$anics,@{$bnics});
        $anics=EDRu::arrdel($anics,@{$snics});
        $anics=EDRu::arruniq(@$anics);
    }

    $sys->{systemnics}=@{$anics};
    return $anics;
}

sub is_bonded_nic_sys {
    my ($padv,$sys,$nic)=@_;
    my ($bnics);
    if ($sys->{bondednics}){
        return EDRu::inarr($nic,@{$sys->{bondednics}});
    }
    ($bnics,undef)=$padv->bondednics_sys($sys);
    return EDRu::inarr($nic,@$bnics);
}

sub bondednics_sys {
    my ($padv,$sys)=@_;
    my (@slavenics,$aggr1,$do1,@bondednics,$aggr,$do,$nicprefix);
    $nicprefix=$sys->cmd("_cmd_lsdev -C -t en | _cmd_awk '{print \$1}' | _cmd_sort | _cmd_sed -n '1p'");
    $nicprefix=~s/\d+//mg;
    $do=$sys->cmd("_cmd_lsdev -Cc adapter -s pseudo | _cmd_grep 'EtherChannel' | _cmd_awk '{print \$1}' | _cmd_sort");
    for my $nic (split(/\n+/, $do)) {
        if($nic=~/(\d+)$/m){
            $aggr="$nicprefix"."$1";
            push(@bondednics,$aggr);
            $do1=$sys->cmd("_cmd_lsattr -El $nic | _cmd_grep 'adapter_names' | _cmd_awk '{print \$2}'");
            for my $subnic (split(/,/m,$do1)) {
               if($subnic=~/(\d+)$/m) {
                  $aggr1="$nicprefix"."$1";
                  push(@slavenics,$aggr1);
               }
            }
        }
    }
    $sys->set_value('bondednics','push',@bondednics);
    return (\@bondednics,\@slavenics);
}

# unload a driver on $sys
sub unload_driver_sys {
    my ($padv,$sys,$driver)=@_;
    $sys->cmd("_cmd_strload -u -d $driver");
    return 1;
}

# determine all Virtual I/O NICs on $sys with micro partition
# return a reference to an array holding the NICs
sub virtualnics_sys {
    my ($padv,$sys)=@_;
    my ($output,@vionics);

    $output=$sys->cmd("_cmd_lsdev -Cc adapter | _cmd_grep 'Virtual.*I/O' | _cmd_awk '{print \$1}' | _cmd_sort");
    $output=~s/ent/en/mg;
    @vionics=split(/\s+/m,$output);
    return \@vionics;
}

sub detect_aix_lpar_sys {
    my ($padv, $sys) = @_;

    my $out = $sys->cmd("_cmd_uname -L 2>/dev/null");

    if ($out =~ /(.*?)\s(.*)/) {
        if ($1 != -1) {
            $sys->{virtual_detail} = "LPAR number: $1";
            $sys->{virtual_detail} .= "\nLPAR name: $2";

            $out = $sys->cmd("_cmd_lparstat -i 2>/dev/null");
            if ($out =~ /\S/) {
                $sys->{virtual_detail} .= "\n$out";
                foreach (split(/\n+/, $out)) {
                    if (/Type\s*:\s*(.*)/) {
                        if ($1 =~ /share/i) {
                            $sys->{virtual_type} = $padv->VIRT_LPAR_SHARED;
                        } else {
                            $sys->{virtual_type} = $padv->VIRT_LPAR_DEDICATED;
                        }
                        last;
                    }
                }
            }
        }
    }
    return;
}

# determine a systems virtualization status
sub virtualization_sys {
    my ($padv, $sys) = @_;

    $padv->detect_aix_lpar_sys($sys);
    $sys->set_value('virtual_type', $sys->{virtual_type}) if($sys->{virtual_type});
    $sys->set_value('virtual_detail', $sys->{virtual_detail}) if($sys->{virtual_detail});
    return 1;
}

# to get the minorversion
sub minorversion_sys {
    my ($padv,$sys)=@_;
    my ($ostl,$tl,@f,$plat,$platvers,$osversion,$iosl);

    $ostl = $sys->cmd('_cmd_oslevel -s');
    @f=split(/\W/m,$ostl);
    $tl=$f[1];

    $sys->set_value('ostechlevel', $tl);

    $plat=$sys->{plat};
    $platvers=$sys->{platvers};
    $osversion="$plat $platvers TL $tl";
    $sys->set_value('osversion', $osversion);

    # get and set ioslevel if VIOS
    if ($sys->exists('/usr/ios/cli/ioscli')) {
        $iosl = $sys->cmd('/usr/ios/cli/ioscli ioslevel 2> /dev/null');
        if ($iosl) {
            $sys->set_value('ioslevel',$iosl);
        }
    }
    return 1;
}

sub vrtspkgversdeps_script {
    my $script=<<'VPVD';
#!/bin/sh

/usr/sbin/installp -C 2>/dev/null

vrtspkgs=`/usr/bin/lslpp -Lqc 'VRTS*' 'SYMC*' 2>/dev/null | /usr/bin/awk -F: '{print $2,$3}'`
[ -z "$vrtspkgs" ] && exit 0;

reqlist=`/usr/bin/lslpp -dqc 'VRTS*' 'SYMC*' 2>/dev/null | /usr/bin/awk -F: '
    {
        if ($3 != "NONE") {
            split( $2, a, " " );
            split( $3, b, " " );
            pkg=a[1];
            dep=b[1];
            if (pkg !="" && dep !="") {
                print pkg,dep;
            }
        }
    }' | /usr/bin/sort | /usr/bin/uniq`

echo "$vrtspkgs" | while read pkg vers; do
    print -n "$pkg $vers"
    echo "$reqlist" | /usr/bin/awk '$1 == "'"$pkg"'" { printf " %s",$2 }'
    print -n "\n"
done
VPVD
    return $script;
}

sub iprod_vrtsat_client_server_sys {
    my ($padv,$sys,$prod,$pkg)=@_;
    if ($pkg eq 'VRTSat') {
        if ($sys->{pkgvers}{'VRTSat.client'}
            && $sys->{pkgvers}{'VRTSat.server'}) {
            push @{$sys->{iprod}{$prod}{irpkgs}}, $pkg;
        } else {
            push @{$sys->{iprod}{$prod}{mrpkgs}}, $pkg;
        }
        return 1;
    }
    return 0;
}

# check whether $file on $sys was modified after the package who owns $file was installed
sub file_modified_sys {
    my ($padv,$sys,$file)=@_;
    my $cmdout = '';
    if ($file) {
        $cmdout = $sys->cmd("_cmd_lppchk -c '*' $file 2>&1");
    }
    if ($cmdout =~ /expected\s+value/mx) {
        return 1;
    }
    return 0;
}

# return value: 0 - verify ok; 1 - otherwise
sub pkg_verify_sys {
    my ($padv,$sys,$pkgname)=@_;
    return 1 if (!$pkgname);
    my $rtn=$sys->cmd("_cmd_lppchk -c $pkgname");
    my $msg=Msg::new("'lppchk -c $pkgname' on $sys->{sys} return:\n$rtn");
    $sys->set_value("pkg_verify,$pkgname", $msg->{msg});
    return EDR::cmdexit();
}

sub configure_static_ip_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    return $padv->configure_static_ipv6_sys($sys,$nic,$ip,$mask) if (EDRu::ip_is_ipv6($ip));
    return $padv->configure_static_ipv4_sys($sys,$nic,$ip,$mask);
}

sub configure_static_ipv4_sys {
    my ($padv, $sys, $nic, $ip, $mask) = @_;
    my $output0 = $sys->cmd("_cmd_lsdev -l $nic 2>/dev/null|_cmd_awk '{print \$2}'");
    my $output1 = $sys->cmd("_cmd_ifconfig $nic 2>/dev/null|_cmd_grep 'inet'");
    my $netaddr ="netaddr=$ip -a netmask=$mask";
    $netaddr="alias4=$ip,$mask" if($output0 =~ /Available/i && $output1 =~ /inet/i);
    $sys->cmd("_cmd_chdev -l $nic -a $netaddr -a state=up 2>/dev/null");
    return 0 if (EDR::cmdexit());
    return 1;
}

sub configure_static_ipv6_sys {
    my ($padv, $sys, $nic, $ip, $prefixlen) = @_;
    my $output0 = $sys->cmd("_cmd_lsdev -l $nic 2>/dev/null|_cmd_grep '$nic *Available'");
    my $output1 = $sys->cmd("_cmd_ifconfig $nic 2>/dev/null|_cmd_grep 'inet6 '");
    my $netaddr ="netaddr6=$ip -a prefixlen=$prefixlen";
    # if ipv6 address exists, create alias ip instead to avoid overwrite the existing one
    # should filter the addr beginning with fe80 which is the link-local address
    $netaddr="alias6=$ip/$prefixlen" if($output0 =~ /Available/ && $output1 =~ /inet6 fe80::/);
    $sys->cmd("_cmd_chdev -l $nic -a $netaddr -a state=up 2>/dev/null");
    return 0 if (EDR::cmdexit());
    return 1;
}

# all AIX padvs operate the same way
package Padv::AIX51;
@Padv::AIX51::ISA = qw(Padv::AIX);

package Padv::AIX52;
@Padv::AIX52::ISA = qw(Padv::AIX);

package Padv::AIX53;
@Padv::AIX53::ISA = qw(Padv::AIX);

package Padv::AIX61;
@Padv::AIX61::ISA = qw(Padv::AIX);

package Padv::AIX71;
@Padv::AIX71::ISA = qw(Padv::AIX);

1;
