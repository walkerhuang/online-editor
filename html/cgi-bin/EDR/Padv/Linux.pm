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
package Padv::Linux;
use strict;
@Padv::Linux::ISA = qw(Padv);

sub padvs { return [ qw(Debian26 ESX30i686 ESX35i686
                 CentOS5x8664 CentOS6x8664 
                 OL5x8664   OL6x8664    OL7x8664
                 RHEL4i686  RHEL4x8664  RHEL4ia64  RHEL4ppc64  RHEL4s390x
                 RHEL5i686  RHEL5x8664  RHEL5ia64  RHEL5ppc64  RHEL5s390x
                 RHEL6i686  RHEL6x8664  RHEL6ia64  RHEL6ppc64  RHEL6s390x
                 RHEL7i686  RHEL7x8664  RHEL7ia64  RHEL7ppc64  RHEL7s390x
                 SLES9i686  SLES9x8664  SLES9ia64  SLES9ppc64  SLES9s390x
                 SLES10i686 SLES10x8664 SLES10ia64 SLES10ppc64 SLES10s390x
                 SLES11i686 SLES11x8664 SLES11ia64 SLES11ppc64 SLES11s390x
                 SLES12i686 SLES12x8664 SLES12ia64 SLES12ppc64 SLES12s390x) ]; }


sub init_plat {
    my ($padv)=@_;
    my ($class,$distro,$version,$arch);

    $padv->{plat}='Linux';
    $padv->{pkgpath}='rpms';
    $padv->{patchpath}='rpms';

    # Define padvform specific commands
    $padv->{cmd}{awk}='/bin/awk';
    $padv->{cmd}{arch}='/bin/arch';
    $padv->{cmd}{cat}='/bin/cat';
    $padv->{cmd}{chgrp}='/bin/chgrp';
    $padv->{cmd}{chmod}='/bin/chmod';
    $padv->{cmd}{chown}='/bin/chown';
    $padv->{cmd}{cp}='/bin/cp -L';
    $padv->{cmd}{cpp}='/bin/cp -P';
    $padv->{cmd}{cut}='/bin/cut';
    $padv->{cmd}{date}='/bin/date';
    $padv->{cmd}{dd}='/bin/dd';
    $padv->{cmd}{dfk}='/bin/df -klP';
    $padv->{cmd}{diff}='/usr/bin/diff';
    $padv->{cmd}{dirname}='/usr/bin/dirname';
    $padv->{cmd}{du}='/usr/bin/du';
    $padv->{cmd}{echo}='/bin/echo';
    $padv->{cmd}{egrep}='/bin/egrep';
    $padv->{cmd}{ethtool}='/sbin/ethtool';
    $padv->{cmd}{ibstatus}='/usr/sbin/ibstatus';
    $padv->{cmd}{find}='/usr/bin/find';
    $padv->{cmd}{grep}='/bin/grep';
    $padv->{cmd}{groups}='/usr/bin/groups';
    $padv->{cmd}{groupadd}='/usr/sbin/groupadd';
    $padv->{cmd}{groupdel}='/usr/sbin/groupdel';
    $padv->{cmd}{groupmod}='/usr/sbin/groupmod';
    $padv->{cmd}{gunzip}='/bin/gunzip';
    $padv->{cmd}{head}='/usr/bin/head';
    $padv->{cmd}{hostname}='/bin/hostname';
    $padv->{cmd}{id}='/usr/bin/id';
    $padv->{cmd}{ip}='/sbin/ip';
    $padv->{cmd}{ipcalc}='/bin/ipcalc';
    $padv->{cmd}{ifconfig}='/sbin/ifconfig';
    $padv->{cmd}{kill}='/bin/kill';
    $padv->{cmd}{ln}='/bin/ln';
    $padv->{cmd}{ls}='/bin/ls';
    $padv->{cmd}{lsmod}='/sbin/lsmod';
    $padv->{cmd}{mkdir}='/bin/mkdir';
    $padv->{cmd}{mkdirp}='/bin/mkdir -p';
    $padv->{cmd}{modinfo}='/sbin/lsmod';
    $padv->{cmd}{modunload}='/sbin/modprobe -r';
    $padv->{cmd}{modprobe}='/sbin/modprobe';
    $padv->{cmd}{mount}='/bin/mount';
    $padv->{cmd}{mv}='/bin/mv';
    $padv->{cmd}{netstat}='/bin/netstat';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{nslookup}='/usr/bin/nslookup';
    $padv->{cmd}{ntpdate}='/usr/sbin/ntpdate';
    $padv->{cmd}{openssl}='/usr/bin/openssl';
    $padv->{cmd}{ping}='/bin/ping';
    $padv->{cmd}{ping6}='/bin/ping6';
    $padv->{cmd}{ps}='/bin/ps -w';
    $padv->{cmd}{rcp}='/usr/bin/rcp';
    $padv->{cmd}{readlink}='/bin/readlink';
    $padv->{cmd}{rm}='/bin/rm';
    $padv->{cmd}{rmr}='/bin/rm -rf';
    $padv->{cmd}{rmdir}='/bin/rm -rf';
    $padv->{cmd}{rmmod}='/sbin/rmmod';
    $padv->{cmd}{rpm}='/bin/rpm';
    $padv->{cmd}{rsh}='/usr/bin/rsh';
    $padv->{cmd}{scp}='/usr/bin/scp';
    $padv->{cmd}{sed}='/bin/sed';
    $padv->{cmd}{sh}='/bin/sh';
    $padv->{cmd}{shutdown}='/sbin/shutdown -r now';
    $padv->{cmd}{sleep}='/bin/sleep';
    $padv->{cmd}{sort}='/bin/sort';
    $padv->{cmd}{ssh}='/usr/bin/ssh';
    $padv->{cmd}{sshkeygen}='/usr/bin/ssh-keygen';
    $padv->{cmd}{sshkeyscan}='/usr/bin/ssh-keyscan';
    $padv->{cmd}{strings}='/usr/bin/strings';
    $padv->{cmd}{su}='/bin/su';
    $padv->{cmd}{tail}='/usr/bin/tail';
    $padv->{cmd}{tar}='/bin/tar';
    $padv->{cmd}{tee}='/usr/bin/tee';
    $padv->{cmd}{touch}='/bin/touch';
    $padv->{cmd}{tput}='/usr/bin/tput';
    $padv->{cmd}{tr}='/usr/bin/tr';
    $padv->{cmd}{uname}='/bin/uname';
    $padv->{cmd}{uniq}='/usr/bin/uniq';
    $padv->{cmd}{useradd}='/usr/sbin/useradd';
    $padv->{cmd}{userdel}='/usr/sbin/userdel';
    $padv->{cmd}{usermod}='/usr/sbin/usermod';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxkeyless}='/opt/VRTSvlic/bin/vxkeyless';
    $padv->{cmd}{vxlicrep}='/sbin/vxlicrep';
    $padv->{cmd}{vxlicinst}='/sbin/vxlicinst';
    $padv->{cmd}{vxtune}='/sbin/vxtune';
    $padv->{cmd}{wc}='/usr/bin/wc';
    $padv->{cmd}{which}='/usr/bin/which';
    $padv->{cmd}{yes}='/usr/bin/yes';
    $padv->{cmd}{hostid}='/usr/bin/hostid';
    $padv->{cmd}{nm}='/usr/bin/nm';
    $padv->{cmd}{getconf}='/usr/bin/getconf';
    $padv->{cmd}{dmesg}='/bin/dmesg';
    $padv->{cmd}{dmidecode}='/usr/sbin/dmidecode';
    $padv->{cmd}{cksum}='/usr/bin/cksum';
    $padv->{cmd}{service}='/sbin/service';
    $padv->{cmd}{lspci}='/sbin/lspci -v';
    $padv->{cmd}{udevadm}='/sbin/udevadm';
    $padv->{cmd}{route}='/sbin/route';
    $padv->{cmd}{lshal}='/usr/bin/lshal';
    $padv->{cmd}{crontab}='/usr/bin/crontab';


    $class=$padv->{class};
    if ($class=~/^Padv\::(RHEL|SLES|Debian|CentOS|OL|ESX)(\d+)(.*)/m) {
        $distro=$1;
        $version=$2;
        $arch=$3;
        $padv->{distro}=$distro;
        $padv->{vers}=$version;
        $padv->{arch}=$arch;

        $arch='64 bit' if ($arch eq 'x8664');
        $padv->{name}="$arch $distro$version";

        if ($distro eq 'RHEL' || $distro eq 'OL' || $distro eq 'CentOS') {
            $padv->{native_install_tool} = 'yum';
            $padv->{native_install_cmd} = '/usr/bin/yum -y install';
            $padv->{native_install_handler} = \&Padv::Linux::yum_install_rpms_sys;
            $padv->{package_install_cmd} = '/usr/bin/rpm -Uvh';
        } elsif ($distro eq 'SLES') {
            $padv->{native_install_tool} = 'zypper';
            $padv->{native_install_cmd} = '/usr/bin/zypper --non-interactive install';
            $padv->{native_install_handler} = \&Padv::Linux::zypper_install_rpms_sys;
            $padv->{package_install_cmd} = '/usr/bin/rpm -Uvh';

            $padv->{cmd}{basename}='/usr/bin/basename';
            $padv->{cmd}{cut}='/usr/bin/cut';
            $padv->{cmd}{gunzip}='/usr/bin/gunzip';

            # On SLES11 and above, ethtool path is '/sbin/ethtool'.
            $padv->{cmd}{ethtool}='/usr/sbin/ethtool' if ($version < 11);
        }
    }

    return;
}

# this set of commands is executed during info_sys before the padv objects
# are created and therefore full command paths are required

sub arch_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('arch');
}

sub distro_sys {
    my ($padv,$sys)=@_;
    return 'OL' if ($sys->cmd('/bin/ls /etc/oracle-release 2>/dev/null'));
    return 'CentOS' if ($sys->cmd('/bin/grep CentOS /etc/redhat-release 2>/dev/null'));
    return 'RHEL' if ($sys->cmd('/bin/ls /etc/redhat-release 2>/dev/null'));
    return 'SLES' if ($sys->cmd('/bin/ls /etc/SuSE-release 2>/dev/null'));
    return 'ESX' if ($sys->cmd('/bin/ls /usr/bin/vmware 2>/dev/null'));
    return 'Debian' if ($sys->cmd('/bin/ls /etc/debian_version 2>/dev/null'));
    # need unsupported distro message
    return '';
}

sub platvers_sys {
   my ($padv,$sys,$vers)=@_;
   #return "2.6.99.0"; # uncomment to test RHEL5arch+ and SLES11arch+ padvs
   return $vers;
}

sub padv_sys {
    my ($padv,$sys)=@_;
    my ($vers,$arch,$distro,@vers);
    $arch=$sys->{arch};
    $arch=~s/_//m; # only modification is x86_64 to x8664
    $distro=$sys->{distro};
    @vers=split(/\./m, $sys->{platvers});
    if ($distro eq 'RHEL') {
        if ($sys->{platvers}=~/\.el(\d+)/m) {
            $vers=$1;
        } else {
            if ($vers[0] == 2) {
                # RHEL 3,4,5,6
                $vers[2]=~s/-\d+$//m;
                $vers = ($vers[2]<9) ? 3 :
                        ($vers[2]==9) ? 4 :
                        ($vers[2]>18) ? 6 : 5;
            } elsif ($vers[0] == 3) {
                # RHEL 7
                $vers = 7;
            }
        }
        $vers=7 if ($vers>7);
        return "RHEL7$arch" if (($vers>7) &&
                                (EDR::get2('padv_unbounded',"RHEL7$arch")));
    } elsif ($distro eq 'SLES') {
        if ($vers[0] == 2) {
            # SLES10 SP4 (2.6.16.60)
            # SLES11 SP0 (2.6.27.19)
            # SLES11 SP1 (2.6.32.12)
            $vers = ($vers[2]<5) ? 8 :
                    ($vers[2]==5) ? 9 :
                    ($vers[2]<27) ? 10 : 11;
        } elsif ($vers[0] == 3) {
            # SLES11 SP2 (3.0.13)
            # SLES11 SP3 (3.0.76)
            # SLES12 SP0 (3.12.22)
            $vers = ($vers[1]<12) ? 11 : 12;
        }
        return "SLES12$arch" if (($vers>12) &&
                                 (EDR::get2('padv_unbounded',"SLES12$arch")));
    } elsif ($distro eq 'OL') {
        # need to check how Oracle Linux version is registered to set
        if ($sys->{platvers}=~/\.el(\d+)/m) {
            $vers=$1;
        }
        $vers||=7;
        return "OL7$arch" if (($vers>7) &&
                              (EDR::get2('padv_unbounded',"OL7$arch")));
    } elsif ($distro eq 'ESX') {
        # need to check how ESX version is registered to set
        $vers=35;
        return "ESX35$arch" if (($vers>35) &&
                                (EDR::get2('padv_unbounded',"ESX35$arch")));
    } elsif ($distro eq 'CentOS') {
        $vers[2]=~s/-\d+$//m;
        $vers = ($vers[2]<9) ? 3 :
                ($vers[2]==9) ? 4 :
                ($vers[2]>18) ? 6 : 5;
        return "CentOS5$arch" if (($vers>5) &&
                                (EDR::get2('padv_unbounded',"CentOS5$arch")));
    } elsif ($distro eq 'Debian') {
        $vers = $vers[0] * 10 + $vers[1];
        return "$distro$vers";
    }
    # bad versions will return error
    return "$distro$vers$arch";
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

# Returns a reference to an array holding the NICs connected to the default gateway/router
sub gatewaynics_sys {
    my ($padv,$sys)=@_;
    my (@values,@nics,@lines,$do);
    $do=$sys->cmd('_cmd_netstat -nr 2>/dev/null');
    @lines=split(/\n/,$do);
    for my $line (@lines) {
        @values = split(/\s+/m,$line);
        if ($values[3] eq 'UG') {
            push @nics,$values[7];
        }
    }
    return EDRu::arruniq(sort @nics);
}

sub ipv4_sys {
    my ($padv,$sys)=@_;
    my $ifc4=$sys->cmd("/sbin/ip -o addr show 2>/dev/null | /bin/grep 'inet ' | /bin/grep -v '127.0.0.1'");
    return $ifc4 ? 1 : 0;
}

sub ipv6_sys {
    my ($padv,$sys)=@_;
    my $ifc6=$sys->cmd("/sbin/ip -o addr show 2>/dev/null | /bin/grep 'inet6 ' | /bin/grep -v 'inet6 ::1/'");
    return $ifc6 ? 1 : 0;
}

# DONE with info_sys routines that require full command paths

# Check if the driver is loaded
sub driver_sys {
    my ($padv,$sys,$driver)=@_;
    my $output=$sys->cmd("_cmd_modinfo | _cmd_grep '^$driver '");
    return $output;
}

# Args: none
# Returns: list of beta packages
# Expects: beta packages to be named *beta*
sub for_beta_sys {
    my ($padv,$sys)=@_;
    my $betalist = $sys->cmd("_cmd_rpm -qa | _cmd_grep '^(VRTS\|SYMC)' | _cmd_grep -i beta");
    return $betalist;
}

# determine and return all the IP's on $sys, including IPv4 and IPv6
sub ips_sys {
    my ($padv,$sys)=@_;
    my (@i,$ipv6_type,@ips,$ip);

    @ips=();
    if ($sys->{ipv4}) {
        $ip=$sys->cmd("_cmd_ip -o addr show 2>/dev/null | _cmd_awk '/inet / { print \$4 }'");
        @i=split(/\s+/m,$ip);
        for my $ip (@i) {
            $ip=~s/\/\d+//m;
            push(@ips,$ip) if ((EDRu::isip($ip)==1) &&
                               ($ip ne '0.0.0.0') && ($ip ne '127.0.0.1'));
        }
    }
    if ($sys->{ipv6}) {
        $ip=$sys->cmd("_cmd_ip -o addr show 2>/dev/null | _cmd_awk '/inet6 / { print \$4 }'");
        @i=split(/\s+/m,$ip);
        for my $ip (@i) {
            $ip=~s/\/\d+//m;
            $ipv6_type = EDRu::iptype_ipv6($ip);
            push(@ips,$ip) if ($ipv6_type !~ m/(LOOPBACK|UNSPEC)/i);
        }
    }
    return \@ips;
}

sub is_virtual_nic_sys {
    my ($padv,$sys,$nic)=@_;
    my $output=$sys->cmd("_cmd_ethtool -i $nic 2>/dev/null | _cmd_grep driver");
    return 1 if ($output =~ "virtio_net");
    return 0;
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

sub bridgednics_sys {
    my ($padv,$sys)=@_;
    my (@bnics,@snics,$brctlshow,@brctlshow,@nics);
    return [] unless ($sys->exists("/usr/sbin/brctl"));
    $brctlshow=$sys->cmd("/usr/sbin/brctl show 2>/dev/null ");
    @brctlshow=split(/\n/,$brctlshow);
    shift(@brctlshow);
    for my $line (@brctlshow) {
        $line=~s/^\s+|\s+$//mgx;
        @nics=split(/\s+/,$line);
        if (scalar(@nics)==1) {
            push (@snics, $nics[0]);
        } elsif (scalar(@nics)==4) {
            push (@bnics, $nics[0]);
            push (@snics, $nics[3]);
        } else {
            Msg::log("unreconized line $line");
        }
    }
    return (\@bnics,\@snics);
}

sub bondednics_sys {
    my ($padv,$sys)=@_;
    my ($files,@snics,$file_pattern,@slavenics,$nic,$slave,@bondednics);
    #$file_pattern="/etc/sysconfig/network-script/ifcfg-bond*";
    $file_pattern='/proc/net/bonding/';
    $files=$sys->cmd("_cmd_ls $file_pattern 2>/dev/null");
    for my $file (split(/\n/, $files)){
        $slave=$sys->cmd("_cmd_grep 'Slave Interface' $file_pattern$file 2>/dev/null | _cmd_awk '{print \$3}'");
        @snics=split(/\n/,$slave);
        push(@slavenics,@snics) if($#snics>=0);
        (undef,undef,undef,undef,$nic)=split(/\//m,$file);
        push(@bondednics,$file);
    }
    $sys->set_value('bondednics','push',@bondednics);
    return (\@bondednics,\@slavenics);
}

sub is_slave_of_bonded_nic_sys {
    my ($padv,$sys,$slavenic)=@_;
    my (@snics,$file_pattern,@slavenics,$nic,$slave);
    $file_pattern='/proc/net/bonding/*'; 
    $slave=$sys->cmd("_cmd_grep 'Slave Interface' $file_pattern 2>/dev/null | _cmd_awk '{print \$3}' | _cmd_grep $slavenic");
    @snics=split(/\n/,$slave);
    return EDRu::inarr($slavenic,@snics); 
}


sub islocal_sys {
    my ($padv,$sys)=@_;
    my ($ifc4,$ip4,$ifc6,$localsys,$nics,$ping6,$ip6,$ping4);
    $localsys=$padv->localsys;
    # Since the target node may be IPv4 only, or IPv6 only, or dual stacks.
    # And the ping command have 2 versions for the 2 IP version.
    # So, probing below is necessary
    if ($localsys->{ipv4}) {
        $ping4=EDR::cmd_local("_cmd_ping -c 1 $sys->{sys} 2>&1 | _cmd_grep PING");
        (undef,$ip4,undef) = split(/[\(\)]/m,$ping4,3);
        return 1 if ($ip4 =~ /127\.0\.0/m);
    }
    if ($localsys->{ipv6}) {
        $nics=EDR::cmd_local("_cmd_ip -o link show 2>/dev/null | _cmd_awk '{print \$2}'");
        for my $nic (split(/\n/, $nics)) {
            next if ($nic eq '');
            chomp $nic;
            $nic =~ s/://m;
            $ping6=EDR::cmd_local("_cmd_ping6 -I '$nic' $sys->{sys} -c 3 -n 2>&1 | _cmd_grep PING");
            (undef,$ip6,undef) = split(/[\(\)]/m,$ping6,3);
            last if(defined($ip6));
        }
    }
    $ifc4=EDR::cmd_local("_cmd_ip -o addr show 2>/dev/null | _cmd_grep 'inet $ip4/'")
        if ($ping4 && (EDRu::ip_is_ipv4($ip4)));
    $ifc6=EDR::cmd_local("_cmd_ip -o addr show 2>/dev/null | _cmd_grep 'inet6 $ip6/'")
        if ($ping6 && (EDRu::ip_is_ipv6($ip6)));

    return 1 if ($ifc4 || $ifc6);
    return 0;
}

# load a driver on $sys
# returns: 1 on success, -1 on failure
# expects: linux to return 0 on success and 1 on failure
# FIXME: should prolly add handling for driver failing to load from dependancies
sub load_driver_sys {
    my ($padv,$sys,$driver)=@_;
    my $output=$sys->cmd("_cmd_modprobe $driver");
    return  ($output=~/OK/mi) ? 1 : '-1';
}

sub media_patch_file {
    my ($padv,$patch,$patchdir)=@_;
    my $file;
    if ($^O =~ /Win32/i) {
        $file=EDR::cmd_local("dir /B $patchdir | find \"$patch->{patchname}-\"");
    } else {
        $file=EDR::cmd_local("_cmd_ls $patchdir | _cmd_grep '$patch->{patchname}-'");

    }
    EDR::die ("Multiple $patch->{patchname} rpms found in $patchdir") if ($file=~/\n/);
    if ($file){
        if ($^O =~ /Win32/i) {
            return "$patchdir\\$file";
        } else {
            return "$patchdir/$file";
        }
    }
    return '';
}

sub media_patch_version {
    my ($padv,$patch,$patchdir)=@_;
    my ($rpm,$vers);
    $rpm=EDRu::basename($patch->{file});
    if ($rpm =~/-(\d+\.\d+\.\d+\.\d+)/mx) {
        return $1;
    }
    if ($padv->localplat eq 'Linux') {
        $vers=EDR::cmd_local("_cmd_rpm -qp --queryformat '%{VERSION}' $patch->{file}");
    } elsif (-f "$patchdir/info/$rpm") {
        $vers=EDR::cmd_local("_cmd_grep '^VERSION' $patchdir/info/$rpm");
        $vers=~s/(VERSION=)//m;
    }
    EDR::die ("Cannot determine version of $padv $patch->{patchname}") if (!$vers);
    return $vers;
}

# checks to see if a package is in its correct location
# sets $pkg->{file} to the filename if so
sub media_pkg_file {
    my ($padv,$pkg,$pkgdir)=@_;
    my ($vers,$file);
    return '' unless ($pkgdir);
    return $padv->media_tar_file($pkg,$pkgdir) if ($pkg->tar); # for Debian
    $file=EDR::cmd_local("_cmd_ls $pkgdir | _cmd_grep $pkg->{pkg}-[v0-9]");
    EDR::die ("Multiple $pkg->{pkg} rpms found in $pkgdir") if ($file=~/\n/);
    return ("$pkgdir/$file") if ($file);
    # NetBackup rpms are currently unversioned
    $file=EDR::cmd_local("_cmd_ls $pkgdir | _cmd_grep $pkg->{pkg}.rpm");
    return ("$pkgdir/$file") if ($file);
    # NetBackup rpms are currently unversioned
    return ''
}

sub media_pkg_version {
    my ($padv,$pkg,$pkgdir)=@_;
    my ($rpm,$vers);
    $rpm=EDRu::basename($pkg->{file});
    if ($rpm =~/-(\d+\.\d+\.\d+\.\d+)/mx) {
        return $1;
    }
    if ($padv->localplat eq 'Linux') {
        $vers=EDR::cmd_local("_cmd_rpm -qp --queryformat '%{VERSION}' $pkg->{file}");
    } elsif (-f "$pkgdir/info/$rpm") {
        $vers=EDR::cmd_local("_cmd_grep '^VERSION' $pkgdir/info/$rpm");
        $vers=~s/(VERSION=)//m;
    }
    EDR::die ("Cannot determine version of $pkg->{padv} $pkg->{pkg}") if (!$vers);
    return $vers;
}

sub media_pkg_arch {
    my ($padv,$pkg,$pkgdir)=@_;
    my ($vers);
    if ($padv->localplat ne 'Linux') {
        $vers=EDR::cmd_local("_cmd_grep '^ARCH' $pkgdir/info/$pkg->{pkg}");
        $vers=~s/(ARCH=)//m;
    } else {
        $vers=EDR::cmd_local("_cmd_rpm -qp --qf '%{ARCH}' $pkg->{file}");
    }
    return "$vers";
}


# Args:     if no argument is given, return netmask of default device
#            if an arg is given, assume it's a nic and return its NM
#            $ipv is used to specify the IP stack version, 4 as the default
# Returns:     string containing netmask of default ip address of the nic,
#            undefined if it can't find one
#
# Expects:     linux's ifconfig has a different format for ocalsys than
#             for real nics. this is shortcut by always returning 255.255.255.0
#            to a request for lo's mask.
#            FIXME: the above might be a bug
#            format of the line containing netmask should be:
#            inet addr:10.180.152.237  Bcast:10.180.159.255  Mask:255.255.248.0
sub netmask_sys {
    my ($padv,$sys,$nic,$ipv,$ip)=@_;
    my ($nm,$ips);

    # When both version available, use IPv4 prior to IPv6
    $ipv ||= '4';

    if ($ipv eq '4' and $sys->{ipv4}) {
        $ips=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null | _cmd_awk '/inet / { print \$4 }'");
        if ($ip && $ips=~ /$ip\/(\d+)/mx) {
            $nm=$1;
        } elsif ($ips=~ /\/(\d+)/mx) {
            $nm=$1;
        }
        $nm=join('.',unpack('C4', pack('N', 2**32-2**(32-$nm)))) if ($nm);
    } elsif ($ipv eq '6' and $sys->{ipv6}) {
        $ips=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null | _cmd_awk '/inet6 / { print \$4 }'");
        if ($ip && $ips=~ /$ip\/(\d+)/mx) {
            $nm=$1;
        } elsif ($ips=~ /\/(\d+)/mx) {
            $nm=$1;
        }
    }
    return ($nm || '');
}

# determin ip on $nic
sub nic_ips_sys {
    my ($padv,$sys,$nic)=@_;
    my (@ips,$do,@ip_lines);
    @ips=();
    $do=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null");
    @ip_lines=split(/\n/,$do);
    for my $ip (@ip_lines) {
        if ( $ip =~/inet6?\s+([0-9a-fA-F.:]+)\//mx ){
            push (@ips,$1);
        }
    }
    return \@ips;
}

sub nic_speed_sys {
    my ($padv,$sys,$nic)=@_;
    my ($output,$msg,$nicname,$plumbed,$retry,$sleep);

    return '' if ($nic =~ /:/m );

    if ($sys->exists("/proc/net/vlan/$nic")) {
        $nicname = $sys->cmd("_cmd_grep '^Device:' /proc/net/vlan/$nic 2>/dev/null | _cmd_awk '{print \$2}'");
        chomp $nicname;
        if ($nicname) {
            $nic = $nicname;
        }
    }

    if ($padv->is_virtual_nic_sys($sys,$nic)) {
         $msg = Msg::new("Not Applicable (Virtual Device)");
         return $msg->{msg};
    } elsif ($padv->is_bonded_nic_sys($sys,$nic)) {
         $msg = Msg::new("Not Applicable (Bonding NIC)");
         return $msg->{msg};
    }

    #rdma nic
    if ($padv->is_nic_rdma_capable_sys($sys, $nic)) {
        $output = $padv->ib_nic_speed_sys($sys, $nic);
        return $output;
    }

    $plumbed = 0;
    $retry = 0;
    $sleep = 5;

    while ($retry<6) {
        $output=$sys->cmd("_cmd_ethtool $nic 2>/dev/null | _cmd_awk '/Speed:/ { print \$2 }'");
        last if (!$output || $output =~ /^\d/);

        # Speed: Unknown!
        # The NIC maybe not plumbed, try plumb it
        if (!$plumbed) {
            $sys->cmd("_cmd_ip link set $nic up 2>/dev/null");
            $plumbed = 1;
        }

        $retry ++;
        sleep $sleep;
    }

    if ( $plumbed ) {
        $sys->cmd("_cmd_ip link set $nic down 2>/dev/null");
    }

    return $output;
}

sub ib_nic_speed_sys {
    my ($padv, $sys, $nic) = @_;
    my ($output, $retry, $devname, $devid);

    $devname = $sys->cmd("_cmd_ls /sys/class/net/$nic/device/infiniband 2>/dev/null");
    return '' if (!$devname);

    $devid = $sys->cmd("_cmd_cat /sys/class/net/$nic/dev_id 2>/dev/null");
    $devid ||= 0;
    $devid = hex($devid) + 1;

    $output = $sys->cmd("_cmd_ibstatus $devname:$devid 2>/dev/null | _cmd_awk '/rate:/ {print \$2 \$3}'");

    return $output;
}

# check if the NIC is RDMA capable
sub is_nic_rdma_capable_sys {
    my ($padv,$sys,$nic) = @_;
    my $drv=$sys->cmd("_cmd_ethtool -i $nic 2>/dev/null | _cmd_awk '/^driver:/ { print \$2 }'");
    return 1 if ($drv=~/ipoib|^mlx/);
    return 0;
}

# verify an entered NIC is present on the system
sub is_nic_sys {
    my ($padv,$sys,$nic)=@_;
    $sys->cmd("_cmd_ip -o link show $nic 2>/dev/null");
    return EDR::cmdexit() ? 0 : 1;
}

# Get the broadcast address for a IP on one NIC,
# If IP is IPv6, then no bcast address
sub nic_bcast_sys {
    my ($padv,$sys,$nic,$ip)=@_;
    my ($out,$bcast);
    return if(EDRu::ip_is_ipv6($ip));
    $out=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null | _cmd_grep '$ip'");
    if($out=~/brd (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/){
       $bcast=$1;
    }
    return $bcast;
}

sub hostid_sys {
    my ($padv,$sys)=@_;
    return $sys->cmd('_cmd_hostid 2>/dev/null');
}

sub model_sys {
    my ($padv, $sys)=@_;

    # Get 'System Information' section
    my $ret = $sys->cmd("_cmd_dmidecode 2>/dev/null | _cmd_awk '/^[A-Z]+/ { needed=0 } /^System Information/ { needed=1 } { if (needed==1) print }'");
    my ($flag, $vendor, $prodname) = ('','','');
    foreach (split(/\n+/, $ret)) {
        $flag = 1 if (/System Information/);
        if ($flag) {
            $vendor = $1 if (/Manufacturer:\s*(.*)/);
            $vendor = EDRu::despace($vendor);
            $prodname = $1 if (/Product Name:\s*(.*)/);
            $prodname = EDRu::despace($prodname);
            last if($vendor && $prodname);
        }
    }
    return EDRu::despace("$vendor $prodname");
}

sub kerbit_sys {
    my ($padv,$sys)=@_;
    my $kernelbit=$sys->cmd('/usr/bin/getconf LONG_BIT');
    return $kernelbit;
}

sub cpu_sys {
    my ($padv,$sys)=@_;
    my (@cpus,%cpu,$new_cpu,$model,$vendor);

    my $ret = $sys->cmd('_cmd_cat /proc/cpuinfo 2>/dev/null');
    if ($sys->{padv}=~/s390/) {
        foreach my $line (split(/\n/, $ret)) {
            if ($line =~ /vendor_id\s*:\s*(.*)/mx) {
                $vendor = $1;
                next;
            }
            if ($line =~ /processor\s+\d+:\s*(.*)/mx) {
                $cpu{TYPE} = $1;
                $cpu{NAME} = $vendor if $vendor;
                push(@cpus, {%cpu});
                next;
            }
        }
    } else {
        foreach my $line (split(/\n/, $ret)) {
            if ($line =~ /processor\s*:\s*(.*)/mx) {
                $cpu{NAME} = $1;
                $new_cpu=1;
                next;
            }
            if ($line =~ /model name\s*:\s*(.*)/m) {
                $model = $1;
                $model =~ s/@/ /m;
                if ($model =~ /(.*)\s+(.*)/mx) {
                    $cpu{TYPE} = EDRu::despace($1);
                    $cpu{SPEED} = EDRu::despace($2);
                }
                next;
            }
            if ($line =~ /^$/m) {
                push(@cpus, {%cpu});
                $new_cpu=0;
            }
        }

        if ($new_cpu) {
            # The last CPU
            push(@cpus, {%cpu});
        }
    }

    return \@cpus;
}

sub cpu_number_sys {
    my ($padv,$sys)=@_;
    my ($rtn,$cpu_count);

    $cpu_count=0;
    $rtn = $sys->cmd('_cmd_grep processor /proc/cpuinfo 2>/dev/null');
    for my $line (split(/\n+/, $rtn)) {
        $cpu_count++ if ($line =~ /^processor\s*:/mx);
    }
    return $cpu_count;
}

sub cpu_speed_sys {
    my ($padv,$sys)=@_;
    my ($rtn,$cpu_speed);

    $rtn = $sys->cmd("_cmd_grep 'cpu MHz' /proc/cpuinfo 2>/dev/null");
    for my $line (split(/\n+/, $rtn)) {
        if ($line =~ /^cpu MHz\s*:\s*(.*)\s*$/m) {
            $cpu_speed=$1;
            $cpu_speed=~s/\..*//m;
            $cpu_speed.=' MHz';
            last;
        }
    }
    return $cpu_speed;
}

sub memory_size_sys {
    my ($padv,$sys)=@_;

    my $rtn = $sys->cmd('_cmd_grep MemTotal /proc/meminfo 2>/dev/null');
    $rtn=~s/MemTotal:\s*//mx;
    $rtn=~s/\s*$//m;
    return $rtn;
}

sub minorversion_sys {
    my ($padv,$sys)=@_;
    my ($rtn,$plat,$distro,$arch,$version,$patchlevel,$updatelevel,$osversion);

    $plat = $sys->{plat};
    $distro = $sys->{distro};
    $arch = $sys->{arch};

    if ($sys->{padv}=~/SLES/) {
        # to get the SLES version
        $version='';
        $rtn=$sys->cmd("_cmd_grep VERSION /etc/SuSE-release 2>/dev/null");
        if ($rtn=~/VERSION\s*=\s*(\d+)/) {
            $version=$1;
        }

        $patchlevel='';
        $rtn=$sys->cmd("_cmd_grep PATCHLEVEL /etc/SuSE-release 2>/dev/null");
        if ($rtn=~/PATCHLEVEL\s*=\s*(\d+)/) {
            $patchlevel=$1;
        }

        if ($version && $patchlevel) {
            $sys->set_value('patchlevel', "$patchlevel");
            $sys->set_value('minorvers',  'SLES'.$version.'SP'.$patchlevel);

            $osversion="$plat $distro$version SP$patchlevel $arch";
            $sys->set_value('osversion', $osversion);
        }
    } elsif ($sys->{padv}=~/RHEL|OL|CentOS/) {
        $updatelevel='';
        $rtn = $sys->cmd("_cmd_cat /etc/redhat-release 2>/dev/null");
        if ($rtn=~/(\d+\.\d+)/s) {
            $updatelevel=$1;
        }

        if ($updatelevel) {
            $sys->set_value('updatelevel', "$updatelevel");
            $sys->set_value('minorvers', "$distro$updatelevel");

            $osversion="$plat $distro $updatelevel $arch";
            $sys->set_value('osversion', $osversion);
        }
    }

    return 1;
}

sub ospatch_sys { return 1; }

sub oslibraries_sys {
    my ($padv,$sys,@libs)=@_;
    my (@rtns,$rtns,$libs);

    @rtns=();

    $libs=join("\' \'", @libs);
    $rtns=$sys->cmd("_cmd_rpm -q --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\\n' --whatprovides '$libs' 2>&1 | _cmd_sort | _cmd_uniq");
    if ($rtns!~/(no package provides|not owned by any package|No such file)/ms) {
        for my $lib (@libs) {
            push (@rtns, 1);
        }
    } else {
        for my $lib (@libs) {
            $sys->cmd("_cmd_rpm -q --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\\n' --whatprovides '$lib' 2>&1");
            if (EDR::cmdexit()) {
                push (@rtns, 0);
            } else {
                push (@rtns, 1);
            }
        }
    }
    return \@rtns;
}

sub oslibrary_sys {
    my ($padv,$sys,$lib)=@_;

    $sys->cmd("_cmd_rpm -q --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\\n' --whatprovides '$lib' 2>&1");
    return EDR::cmdexit() ? 0 : 1;
}

sub installcommand_precheck_sys {
    my ($padv,$sys)=@_;
    my ($msg,$rtn);

    $rtn=$sys->cmd('_cmd_rpm -qa 2>&1 1>/dev/null');
    if ($rtn=~/error:/mgi) {
        $msg=Msg::new("There are some errors when running rpm utility on $sys->{sys}, make sure rpm command could work correctly");
        $sys->push_error($msg);
        return 0;
    }
    return 1;
}

sub patch_copy_sys { return pkg_copy_sys(@_); }

sub patch_remove_sys { return pkg_remove_sys(@_); }

sub patch_install_success_sys {
    return pkg_install_success_sys(@_);
}

sub patch_install_sys { return pkg_install_sys(@_); }

sub patch_installed_sys { return 0; }

sub patch_version_sys {
    my ($padv,$sys,$patch)=@_;
    return $padv->pkg_version_sys($sys, $patch);
}

# ping a host, supports IPV4 and IPV6
# returns "" if successful, string if unsuccessful, opposite perl standard
# $sys can be a system name or IP and is scalar, not system object as ping_sys
sub ping {
    my ($padv,$sysip)=@_;
    return '' if ($ENV{NOPING});
    my($localsys,$nic,$nics,$ping,$isip,$isipv4,$isipv6);
    $localsys=$padv->localsys;
    #if sysip is hostname,using ping according to sys->{ipv4},if sysip is ip using ping/ping6 according to ip type
    $isip=EDRu::isip($sysip);
    $isipv4=EDRu::ip_is_ipv4($sysip);
    $isipv6=EDRu::ip_is_ipv6($sysip);
    if (($localsys->{ipv4} && (!$isip)) || ($isipv4)) {
        $ping=EDR::cmd_local("/bin/ping $sysip -c 1 2>/dev/null");
        return '' if (EDR::cmdexit() eq '0');
    }
    if (($localsys->{ipv6} && (!$isip)) || ($isipv6)) {
        if (EDRu::iptype_ipv6($sysip) =~ m/LINK-LOCAL/) {
            $nics=$padv->publicnics_sys($localsys);
            $nic=@{$nics}[0] if($nics);
            $ping=EDR::cmd_local("/bin/ping6 -I $nic $sysip -c 3 2>/dev/null") if ($nic);
        } else {
            $ping=EDR::cmd_local("/bin/ping6 $sysip -c 3 2>/dev/null");
        }
        return '' if (EDR::cmdexit() eq '0');
        # code here in CPI that referenced $CPI::SYS{$sys}{IPV4} or $sys->{ipv4}
        # removed because $sys->{ipv4} gets set after ping, add back if necc.
    }

    return 'noping';
}

sub pkg_copy_sys {
    my ($padv,$sys,$pkg)=@_;
    $padv->localsys->copy_to_sys($sys,$pkg->{file},EDR::tmpdir()) if (!$sys->{islocal});
    if ($^O =~ /Win32/i){
        EDR::cmd_local('type nul>"'.$pkg->copy_mark_sys($sys).'" 2>nul');
    } else {
        EDR::cmd_local('_cmd_touch '.$pkg->copy_mark_sys($sys));
    }

    return '';
}

sub pkg_description_sys {
    my ($padv,$sys,$pkg)=@_;
    my $desc=$sys->cmd("_cmd_rpm -q --queryformat '%{SUMMARY}' $pkg->{pkg} 2> /dev/null");
    $desc=~s/^\"\s*//;
    $desc=~s/\s*\"\s*$//;
    return $desc;
}

# determine whether an RPM installation has succeeded
# return string signifying success if passed, null if error
sub pkg_install_success_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($iof,$iv,$pf,$pobj);
    # can't see anything yet, verbose isn't verbose, exit code is rsh?
    $pobj=(ref($pkg)=~/^Patch/m) ? "$pkg->{patchname}" :
          (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : $pkg;
    $pf=(ref($pkg)=~/^Patch/m) ? "patch.$pkg->{patch_vers}" : $pobj;
    $iof=EDRu::readfile(EDRu::outputfile('install', $sys->{sys}, $pf));
    $iv=$padv->pkg_version_sys($sys, $pkg);
    if (!$iv) {
        Msg::log("$pobj is not installed on $sys->{sys}\n$iof");
        return 0;
    }
    if ($iv ne $pkg->{vers}) {
        Msg::log("$pobj version on $sys->{sys} is $iv but not $pkg->{vers}\n$iof");
        return 0;
    }

    #Don't check error message if ignore_log_error set on $pkg.
    if ($pkg->{ignore_log_error}) {
        Msg::log("Skip error message checking for $pobj package installation on $sys->{sys}");
        return 1;
    }

    return 0 if ($iof=~/error:/mi);
    # check if reboot is required
    if(!$pkg->{donotcheckinstalllog} && $iof =~ /\breboot\b/mi && !EDRu::inarr($pkg->{pkg}, @{$sys->{requirerebootpkgs}})) {
        $sys->set_value('requirerebootpkgs', 'push', $pkg->{pkg});
    }
    return 1;
}

sub pkg_install_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($rpm,$rootpath,$iopts,$iof,$pobj,$tmpdir);

    $iopts='';

    $rootpath=Cfg::opt('rootpath');
    $iopts.=" -r $rootpath" if ($rootpath);
    $iopts.=' --nodeps'     if ($pkg->{nodeps});
    $iopts.=' --nopostun'   if ($pkg->{nopostun});
    $iopts.=' --nopreun'    if ($pkg->{nopreun});
    $iopts.=' --force'    if ($pkg->{forceinstall});
    $iopts.=" $pkg->{iopt}" if ($pkg->{iopt});

    $tmpdir=EDR::tmpdir();
    $rpm = ($sys->{islocal}) ? $pkg->{file} : "$tmpdir/". EDRu::basename($pkg->{file});
    $pobj=(ref($pkg)=~/^Patch/m) ? "patch.$pkg->{patch_vers}" :
          (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : $pkg;
    $iof=EDRu::outputfile('install', $sys->{sys}, $pobj);
    $sys->cmd("_cmd_rpm -U -v $iopts $rpm 2>>$iof 1>&2");
    return '';
}

sub pkg_remove_sys {
    my ($padv,$sys,$pkg)=@_;
    my $tmpdir=EDR::tmpdir();
    my $pkgfile;
    if ($^O =~ /Win32/i){
        $pkgfile="$tmpdir\\".EDRu::basename($pkg->{file});
        EDR::cmd_local('rm '.$pkg->copy_mark_sys($sys));
    } else {
        $pkgfile="$tmpdir/".EDRu::basename($pkg->{file});
        EDR::cmd_local('_cmd_rmr '.$pkg->copy_mark_sys($sys));
    }

    $sys->cmd("_cmd_rmr $pkgfile") if (!$sys->{islocal});
    return '';
}

sub pkg_uninstall_sys {
    my ($padv,$sys,$pkg)=@_;
    my $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    my $uopts='--allmatches --nodeps';
    $uopts.=' --noscripts' if ($pkg->{force_uninstall} || $pkg->{noscripts});
    $uopts.=' --nopreun'   if ($pkg->{nopreun});
    $sys->cmd("_cmd_rpm -e -v $uopts $pkg->{pkg} 2>>$uof 1>&2");
    return;
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

sub pkg_version_sys {
    my ($padv,$sys,$pkg,$prevpkgs_flag,$pbe_flag,$minorvers_flag)=@_;
    my ($iv,$pkgi);
    # can pass a string argument $pkg
    # if $prevpkgs_flag=1, then do not check pkg's previous name.
    $pkgi=(ref($pkg)=~/^Patch/m) ? ($pkg->{patchname}) : (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : $pkg;
    # $pbe_flag is not used on Linux
    # if $minorver_flag=1, check the minor version of the pkg, eg:2.12-1.132.el6 
    if ($minorvers_flag) {
        $iv=$sys->cmd("_cmd_rpm -q --queryformat '%{VERSION}-%{RELEASE}' $pkgi 2> /dev/null");
    } else {
        $iv=$sys->cmd("_cmd_rpm -q --queryformat '%{VERSION}' $pkgi 2> /dev/null");
    }
    $iv = '' if ($iv =~ /not installed/m);
    if (!$iv && !$prevpkgs_flag){
        for my $pkgi (@{$pkg->{previouspkgnames}}) {
            $iv=$sys->cmd("_cmd_rpm -q --queryformat '%{VERSION}' $pkgi 2> /dev/null");
            $iv = '' if ($iv =~ /not installed/m);
            last if($iv);
        }
    }
    return $iv;
}

sub pkg_installtime_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($str,$it,$pobj);
    $pobj=(ref($pkg)=~/^Patch/m) ? ($pkg->{patchname}) :
        (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : $pkg;

    $it='';
    for my $pkgi ($pobj,@{$pkg->{previouspkgnames}}) {
        $str=$sys->cmd("_cmd_rpm -q --queryformat '%{installtime}' $pkgi 2> /dev/null");
        if ($str =~ /^\s*(\d+)\s*$/) {
            $it = $1;
            last;
        }
    }
    return $it;
}

sub pkg_version_cleanup {
    my ($padv,$vers)=@_;
    return $vers;
}

sub process_args {
    if (Cfg::opt('patchpath')) {
        my $msg=Msg::new("-patchpath is the same as -pkgpath on Linux.\nThis option is ignored.");
        $msg->print;
        Cfg::unset_opt('patchpath');
    }
    return;
}

# Returns: reference to an array containing all interfaces
sub publicnics_sys {
    my ($padv,$sys)=@_;
    my ($rtn,@all_interface_lines,@all_interfaces);
    $rtn=$sys->cmd("_cmd_ip -o addr show | _cmd_awk '/inet/ {print \$2}' | _cmd_sort | _cmd_uniq");
    @all_interface_lines = split(/\n/, $rtn);
    for my $nic (@all_interface_lines) {
        if ($nic ne '') {
            $nic=~s/://m;
            if ( ($nic ne 'lo')  && ($nic !~ /:\d+$/m) && (! grep {/vmnic/mi} $nic)) {
                push( @all_interfaces, $nic );
            }
        }
    }
    return \@all_interfaces;
}

sub swap_size_sys {
    my ($padv,$sys)=@_;

    my $rtn = $sys->cmd('_cmd_grep SwapFree /proc/meminfo 2>/dev/null');
    $rtn=~s/SwapFree:\s*//mx;
    $rtn=~s/\s*$//m;
    return $rtn;
}

# Returns: reference to an array containing all interfaces
sub systemnics_sys {
    my ($padv,$sys,$bnics_flag,$brnics_flag)=@_;
    my ($rtn,$anics,$snics,@all_interface_lines,$bnics,@all_interfaces);
    $rtn=$sys->cmd("_cmd_ip -o link show 2>/dev/null | _cmd_awk '{print \$2}'| _cmd_sort | _cmd_uniq");
    @all_interface_lines = split(/\n/, $rtn);
    for my $nic (@all_interface_lines) {
        if ($nic ne '') {
            $nic=~s/://m;
            $nic=~s/\@.*$//;
            if ( ($nic ne 'lo')  && ($nic !~ /:\d+$/m) && ($nic !~ /^sit\d+$/m)) {
                push( @all_interfaces, $nic );
            }
        }
    }
    $anics=\@all_interfaces;
    if ($bnics_flag) {
        ($bnics,$snics)=$padv->bondednics_sys($sys);
        push(@$anics,@{$bnics});
        $anics=EDRu::arrdel($anics,@{$snics});
        $anics=EDRu::arruniq(@$anics);
    }
    if ($brnics_flag) {
        ($bnics,$snics)=$padv->bridgednics_sys($sys);
        push(@$anics,@{$bnics});
        $anics=EDRu::arrdel($anics,@{$snics});
        $anics=EDRu::arruniq(@$anics);
    }
    return $anics;
}

sub timesync_sys {
    my ($padv,$sys,$ntpserver) = @_;

    if ($sys->{padv} =~/^SLES/) {
        $sys->cmd("/usr/sbin/sntp -P no -r $ntpserver 2>&1");
    } else {
        $sys->cmd("/usr/sbin/ntpdate -u $ntpserver 2>&1");
    }
    return !EDR::cmdexit();
}

# unload a driver on $sys
# returns: 1 on success, 0 on failure
sub unload_driver_sys {
    my ($padv,$sys,$driver)=@_;
    my $output=$sys->cmd("_cmd_modunload $driver 2>&1");
    return 1 if ($output eq '' || $output =~ /\$loaded/mi);
    return 0;
}

sub detect_linux_by_dmesg_sys {
    my ($padv, $sys) = @_;

    my $out = $sys->cmd("_cmd_dmesg 2>/dev/null | _cmd_grep -i 'virtual'");

    foreach (split(/\n+/, $out)) {
        if (/vmxnet virtual NIC/i || /vmware virtual ide cdrom/i) {
            $sys->{virtual_type} = $padv->VIRT_VMWARE;
            last;
        }
        if (/qemu virtual cpu/i) {
            $sys->{virtual_type} = $padv->VIRT_KVM . " or " . $padv->VIRT_QEMU;
        }
        if (/Virtual HD, ATA DISK drive/i || /Virtual CD, ATAPI CD/i) {
            $sys->{virtual_type} = $padv->VIRT_VIRTUALPC;
            last;
        }
        if (/booting paravirtualized kernel on vmi/i) {
            $sys->{virtual_type} = $padv->VIRT_VMWARE;
            last;
        }
        if (/booting paravirtualized kernel on kvm/i) {
            $sys->{virtual_type} = $padv->VIRT_KVM;
            last;
        }
        if (/Xen virtual console/ || /booting paravirtualized kernel on xen/i) {
            $sys->{virtual_type} = $padv->VIRT_XEN;
            last;
        }
    }
    return;
}

sub detect_linux_by_dmidecode_sys {
    my ($padv, $sys) = @_;

    # Get 'BIOS Information' and 'System Information' section
    my $out = $sys->cmd("_cmd_dmidecode 2>/dev/null | _cmd_awk '/^[A-Z]+/ { needed=0 } /^BIOS Information|System Information/ { needed=1 } { if (needed==1) print }'");

    my ($flag, $bios_vendor, $mfgr, $product) = ("", "", "", "");
    foreach (split(/\n+/, $out)) {
        if (/^\S/) {
            if (/^BIOS Information/) {
                $flag = "bios_info";
            } elsif (/^System Information/) {
                $flag = "system_info";
            } else {
                $flag = "other";
            }
            next;
        }

        if ($flag eq "bios_info") {
            $bios_vendor = $1 if (/Vendor:\s*(.*)/i);
        }
        if ($flag eq "system_info") {
            $mfgr = $1 if (/Manufacturer:\s*(.*)/i);
            $product = $1 if (/Product Name:\s*(.*)/i);
        }
    }

    $sys->{virtual_type} = $padv->VIRT_VMWARE if ($mfgr =~ /VMWare/i);
    $sys->{virtual_type} = $padv->VIRT_KVM . " or " . $padv->VIRT_QEMU if ($bios_vendor =~ /QEMU/i);
    $sys->{virtual_type} = $padv->VIRT_VIRTUALPC if ($mfgr =~ /microsoft/i && $product =~ /virtual machine/i);
    return;
}

# determine a systems virtualization status
sub virtualization_sys {
    my ($padv, $sys) = @_;

    $padv->detect_linux_by_dmesg_sys($sys);
    if (!$sys->{virtual_type} || $sys->{virtual_type} =~ / or /) {
        $padv->detect_linux_by_dmidecode_sys($sys);
    }
    $sys->set_value('virtual_type', $sys->{virtual_type}) if($sys->{virtual_type});
    $sys->set_value('virtual_detail', $sys->{virtual_detail}) if($sys->{virtual_detail});
    return 1;
}

sub vrtspkgversdeps_script {
    my $script=<<'VPVD';
#!/bin/sh

vrtspkgs=`/bin/rpm -qa --queryformat '%{NAME} %{VERSION}\n' '(VRTS|SYMC)*' 2>/dev/null`
[ -z "$vrtspkgs" ] && exit 0;

echo "$vrtspkgs" | while read pkg vers; do
    deplist=`/bin/rpm -q --whatrequires --queryformat ' %{NAME}' $pkg 2>/dev/null | /bin/grep -v 'no package'`
    echo $pkg $vers$deplist
done
VPVD
   return $script;
}

# check whether $file on $sys was modified after the package who owns $file was installed
sub file_modified_sys {
    my ($padv,$sys,$file)=@_;
    my $cmdout = '';
    if ($file) {
        $cmdout = $sys->cmd("_cmd_rpm -V -f $file 2>/dev/null | _cmd_grep '${file}[ \\t]*\$' 2>/dev/null | _cmd_cut -c 3");
        chomp $cmdout;
    }
    if ($cmdout eq '5') {
        return 1;
    }
    return 0;
}

# return value: 0 - verify ok; 1 - otherwise
sub pkg_verify_sys {
    my ($padv,$sys,$pkgname)=@_;
    return 1 if (!$pkgname);
    my $rtn=$sys->cmd("_cmd_rpm -V $pkgname");
    my $msg=Msg::new("'rpm -V $pkgname' on $sys->{sys} return:\n$rtn");
    $sys->set_value("pkg_verify,$pkgname", $msg->{msg});

    # Skip configuration files
    my $errors=0;
    for my $line (split(/\n/,$rtn)) {
        next if ($line=~/^\S+\s+c\s+/);
        $errors++;
    }
    return $errors ? 1 : 0;
}

# get all rpm packages on the media
sub media_allpkgs {
    my ($padv,$pkgdir) = @_;
    return if(!$pkgdir);
    my $lines=EDR::cmd_local("_cmd_ls $pkgdir");
    my %allpkgs = ();
    for my $line (split /\n/,$lines) {
        if ($line =~ /\.rpm$/){
            my $rpminfos=EDR::cmd_local("_cmd_rpm -qpRi $pkgdir/$line");
            my %pkginfo;
            for my $info (split /\n/,$rpminfos) {
                if ($info =~ /^Name\s*:\s*(\S+)/) {
                    $pkginfo{name} = $1;
                } elsif ($info =~ /^Version\s*:\s*(\S+)/) {
                    $pkginfo{version} = $1;
                } elsif ($info =~ /^Size\s*:\s*(\S+)/) {
                    $pkginfo{size} = $1/1024;
                } elsif ($info =~ /Summary\s*:\s*(.*?)\s*$/) {
                    $pkginfo{summary} = $1;
                } elsif ($info =~ /^(VRTS\S+)$/) {
                    push @{$pkginfo{deps}},$1;
                }
            }
            if ($pkginfo{name}) {
                $pkginfo{file} = "$pkgdir/$line";
                $allpkgs{$pkginfo{name}} = \%pkginfo;
            }
        }
    }
    return \%allpkgs;
}

#for RHEL6 only
sub get_nicname_by_pciid_sys {
    my ($padv,$sys,$pciid) = @_;
    my ($output,@fieldarr,$index,$i);
    $output = $sys->cmd("_cmd_lshal | _cmd_grep 'linux.sysfs_path =.*/net/.*' | _cmd_grep -v 'virtual' |_cmd_awk -F \\' '{print \$2}'| _cmd_grep -iw $pciid"); 
    @fieldarr = split(/\//,$output);
    $index = @fieldarr;
    for ($i = $index -1; $i >= 0; $i--) {
        if($fieldarr[$i] eq "net"){
            return $fieldarr[$i+1];
        }    
    } 
    return '';
}

#for RHEL6 only
sub get_pciid_by_nicname_sys {
    my ($padv,$sys,$nicname) = @_;
    my ($output,@fieldarr,$index,$i);
    $output = $sys->cmd("_cmd_lshal | _cmd_grep 'linux.sysfs_path =.*/net/.*' | _cmd_grep -v 'virtual' |_cmd_awk -F \\' '{print \$2}'| _cmd_grep -iw $nicname"); 
    @fieldarr = split(/\//,$output);
    $index = @fieldarr;
    for ($i = $index -1; $i >= 0; $i--) {
        if($fieldarr[$i] eq "net"){
            return $fieldarr[$i-1];
        }    
    } 
    return '';
}

#for RHEL6 only
sub get_mac_by_nic_sys {
    my ($padv,$sys,$nic) = @_;
    my $output = $sys->cmd("_cmd_ip link show $nic 2>/dev/null | _cmd_awk '/^ *link/ { print \$2 }'");
    return $output;
}

#for RHEL6 only
sub get_all_nic_sys {
    my ($padv,$sys)=@_;
    my ($rtn,@all_interface_lines,@all_interfaces);
    $rtn=$sys->cmd("_cmd_ip -o link show 2>/dev/null | _cmd_awk '{print \$2}'| _cmd_sort | _cmd_uniq");
    @all_interface_lines = split(/\n/, $rtn);
    for my $nic (@all_interface_lines) {
        if ($nic ne '') {
            $nic=~s/://m;
            if ( ($nic ne 'lo')  && ($nic !~ /:\d+$/m) && (! grep {/vir/mi} $nic)) {
                push( @all_interfaces, $nic );
            }
        }
    }
    return \@all_interfaces;
}

#for RHEL6 only
sub get_dns_sys {
    my ($padv,$sys) = @_;
    my ($output,@nameserver);
    $output = $sys->cmd("_cmd_grep '^nameserver' /etc/resolv.conf 2>/dev/null");
    return '' if ($output eq '');
    $output =~ s/nameserver//m;
    @nameserver = split(/\n/,$output);
    $output = EDRu::despace($nameserver[0]);
    return $output if (EDRu::isip($output));
    return '';
}

#for RHEL6 only
sub get_domain_sys {
    my ($padv,$sys) = @_;
    my ($output,@domain);
    $output = $sys->cmd("_cmd_grep '^domain'  /etc/resolv.conf 2>/dev/null | _cmd_awk '{print \$2}'");
    if ($output eq '') {
        $output = $sys->cmd("_cmd_grep '^search'  /etc/resolv.conf 2>/dev/null | _cmd_awk '{print \$2}'");
    }
    return '' if ($output eq '');
    @domain = split(/\n/,$output);
    $output = EDRu::despace($domain[0]);
    return $output;
}

#for RHEL6 only
sub get_gateway_sys {
    my ($padv,$sys,$netproto) = @_;
    my ($output,@gateway);
    if ($netproto eq "ipv4") {
        $output = $sys->cmd("_cmd_grep '^GATEWAY=' /etc/sysconfig/network 2>/dev/null");
        $output =~s/GATEWAY=//m;
    } else {
        $output = $sys->cmd("_cmd_grep '^IPV6_DEFAULTGW=' /etc/sysconfig/network 2>/dev/null");
        $output =~s/IPV6_DEFAULTGW=//m;
    }
    return '' if ($output eq '');
    @gateway = split(/\n/,$output);
    $output = EDRu::despace($gateway[0]);
    return $output if (EDRu::isip($output));
    return '';
}

#for RHEL6 only
sub configure_nicname_sys {
    my ($padv,$sys,$name,$newname) = @_;
    $name =~ s/\s//g;
    $newname =~ s/\s//g;
    my $udevconfile="/etc/udev/rules.d/70-persistent-net.rules";
    my $udevconfilebk="/etc/udev/rules.d/70-persistent-net.rules.bakup";
    my $ifcfgfile = "/etc/sysconfig/network-scripts/ifcfg-".$name;
    my $ifcfgfilebk = "/etc/sysconfig/network-scripts/ifcfg-".$name.".bak";
    if ($sys->exists($udevconfile) && !$sys->exists($udevconfilebk)) {
         $sys->copyfile($udevconfile, $udevconfilebk);
    }
    return $padv->configure_nicname_common_sys($sys,$name,$newname);
}

#for RHEL6 only
sub configure_nicname_common_sys {
    my ($padv,$sys,$name,$newname) = @_;
    my ($locprefix,$namepath,$newnamepath,$newnamepath_tmp,$udevpath,$udevconfile,$udevconfile_tmp,$mac,$macpath,$output,$udevconfilebk,$str,$content);
    $locprefix="/etc/sysconfig/network-scripts/ifcfg-";
    $udevconfile="/etc/udev/rules.d/70-persistent-net.rules";
    $udevconfile_tmp="/etc/udev/rules.d/70-persistent-net.rules_tmp";
    $udevpath = "/etc/udev/rules.d/";
    $namepath=$locprefix.$name;
    $newnamepath=$locprefix.$newname;
    $newnamepath_tmp=$locprefix.$newname."_tmp";
    $mac = $sys->cmd("_cmd_ip link show $name 2>/dev/null | _cmd_tail -1 | _cmd_awk '{print \$2}'");
    $mac =~ s/\s//g;
    $macpath=$locprefix.$mac;

    if($sys->exists($namepath)){
        $output = $sys->copyfile($namepath,$newnamepath);
        $sys->cmd("_cmd_sed 's/$name/$newname/g' $newnamepath 2>/dev/null > $newnamepath_tmp"); 
        $sys->movefile($newnamepath_tmp,$newnamepath);
        $sys->rm($newnamepath_tmp);
    } else {
        $sys->cmd("_cmd_touch $newnamepath");
    }

    $str = $sys->readfile($udevconfile);
    $content = '';
    for my $line(split(/\n/,$str)) {
        if ($line =~ /$mac/m) {
            $line =~ s/NAME=.*/NAME=\"$newname\"/m;
        }
        $content .= "$line\n";
    }

    $sys->writefile($content,$udevconfile_tmp);
    $udevconfilebk = $udevconfile.".bak";
    $sys->copyfile($udevconfile_tmp,$udevconfile);
    return 1;
}

#for RHEL6 only
sub configure_hostname_sys {
    my ($padv,$sys,$hostname) = @_;
    return $padv->configure_hostname_common_sys($sys,$hostname);
}

#for RHEL6 only
sub configure_hostname_common_sys {
    my ($padv,$sys,$hostname) = @_;
    my ($output,$srchostname,$hostfile,$hostfile_tmp,$hostfile_bk);
    $output = $sys->cmd("_cmd_hostname 2>/dev/null");
    if ($output eq ""){
        Msg::log("hostname is null!");
    }
    if ($sys->{padv} =~ /^(RHEL|OL|CentOS)/){
        $hostfile = "/etc/sysconfig/network";
        $hostfile_tmp = '/etc/sysconfig/network_tmp';
    }
    
    $srchostname = $sys->cmd("_cmd_grep '^HOSTNAME=' $hostfile 2>/dev/null | _cmd_sed 's/HOSTNAME=//g'");
    Msg::log("srchostname is $srchostname");
    if ($srchostname eq "") {
        $output = $sys->cmd("_cmd_sed 's/HOSTNAME=/HOSTNAME=$hostname/g' $hostfile 2>/dev/null > $hostfile_tmp");
    } else {
        $output = $sys->cmd("_cmd_sed 's/$srchostname/$hostname/g' $hostfile 2>/dev/null > $hostfile_tmp");
    }

   if ($sys->exists($hostfile)) {
       $hostfile_bk = $hostfile . '.bak';
       Msg::log("Backing up $hostfile file as $hostfile_bk");
       $sys->copyfile($hostfile, $hostfile_bk);
       $sys->movefile($hostfile_tmp, $hostfile);
   }

   $sys->cmd("_cmd_hostname $hostname 2>/dev/null");
   return 1;
}

#for RHEL6 only
sub configure_ip_sys {
    my ($padv,$sys,$nic,$nicnew,$ip,$mask,$netproto) = @_;
    return $padv->configure_ip_common_sys($sys,$nic,$nicnew,$ip,$mask,$netproto);
}

#for RHEL6 only
sub configure_ip_common_sys {
   my ($padv,$sys,$nic,$nicnew,$ip,$mask,$netproto) = @_;
   my ($nicfile,$nicfilebk,$mode,$nic_ip_conf,$mac,$output,$max_cnt,$ipinfo);

   if ($sys->{padv}=~ /^(RHEL|OL|CentOS)/){
      $nicfile = "/etc/sysconfig/network-scripts/ifcfg-" . $nicnew;
      $mode = "ONBOOT=yes";
   } elsif ($sys->{padv}=~ /^SLES/){
      $nicfile = "/etc/sysconfig/network/ifcfg-" . $nicnew;
      $mode = "STARTMODE=auto";
   }

   $mac = $sys->cmd("_cmd_ip link show $nic 2>/dev/null | _cmd_awk '/^ *link/ { print \$2 }'");
    if($netproto eq "ipv4") {
        if ($ip eq '' || $mask eq '') {
            $ipinfo='';
        } else {
            $ipinfo = "IPADDR=$ip\n";
            $ipinfo .= "NETMASK=$mask\n";
        }

   $nic_ip_conf =<< "_NIC_IP_CONF_";
DEVICE=$nicnew
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
HWADDR=$mac
$mode
$ipinfo
_NIC_IP_CONF_

    } else {
        if ($ip eq '' || $mask eq '') {
            $ipinfo='';
        } else {
            $ipinfo = "IPV6ADDR=$ip\/$mask\n";
        }

   $nic_ip_conf =<< "_NIC_IP_CONF_";
DEVICE=$nicnew
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
IPV6INIT=yes
HWADDR=$mac
$mode
$ipinfo
_NIC_IP_CONF_
}

   if ($sys->exists($nicfile)) {
      $nicfilebk = $nicfile . '.bak';
      Msg::log("Backing up $nicfile file as $nicfilebk");
   }

   $sys->writefile($nic_ip_conf,$nicfile);
   return 1;
}

#for RHEL6 only
sub configure_dns_sys {
    my ($padv, $sys, $nameserver, $domain)=@_;
    my ($dns_conf,$conffile,$conffilebak,$conffilesave,$srcfile);
    $conffile = "/etc/resolv.conf";
    $conffilebak = "/etc/resolv.conf.cpisave";
    #conffilesave is generated by OS
    $conffilesave = "/etc/resolv.conf.save";
    $srcfile = '';

    $dns_conf = << "_DNS_CONF_";
$srcfile
nameserver    $nameserver
domain    $domain
_DNS_CONF_

    $sys->copyfile($conffile, $conffilebak);
    $sys->writefile($dns_conf,$conffile);
    $sys->writefile($dns_conf,$conffilesave);
    return 1;
}

#for RHEL6 only
sub configure_gateway_sys {
    my ($padv, $sys, $gateway)=@_;
    my ($gateway_conf,$conffile,$conffilebak,$srcfile);
    $srcfile = '';

    $conffile = "/etc/sysconfig/network";
    $conffilebak = "/etc/sysconfig/network.cpisave";

    if($sys->exists($conffile)){
        $sys->copyfile($conffile, $conffilebak);
        $srcfile = $sys->cmd("_cmd_cat $conffile 2>/dev/null");
        $srcfile =~ s/^\s*GATEWAY.*$//mg;
        $srcfile =~ s/^\s*NOZEROCONF.*$//mg;
        $srcfile =~ s/^\s*NETWORKING_IPV6.*$//mg;
        $srcfile =~ s/^\s*IPV6_DEFAULTGW.*$//mg;
    }

    if (!EDRu::ip_is_ipv6($gateway)) {

     $gateway_conf = << "_GATEWAY_CONF_";
$srcfile
GATEWAY=$gateway
NOZEROCONF=yes
_GATEWAY_CONF_
   
      $sys->cmd("_cmd_route add default gw $gateway");
    } else {

    $gateway_conf = << "_GATEWAY_CONF_";
$srcfile
NETWORKING_IPV6=yes
IPV6_DEFAULTGW=$gateway
NOZEROCONF=yes
_GATEWAY_CONF_


        $sys->cmd("_cmd_route -A inet6 add default gw $gateway");
    }

    $sys->writefile($gateway_conf,$conffile);

    return 1;
}

#for RHEL6 only
sub configure_bond_ip_common {
    my ($padv,$sys,$bond_nic,$mode,$ip,$mask,$netproto) = @_;
    my ($ipinfo,$bond_nic_cfg,$bond_nic_ip_conf,$bond_nic_cfg_bak);

    $bond_nic_cfg="/etc/sysconfig/network-scripts/ifcfg-$bond_nic";


    if($netproto eq "ipv4") {
        if ($ip eq '' || $mask eq '') {    
            $ipinfo='';  
        } else {
            $ipinfo = "IPADDR=$ip\n";      
            $ipinfo .= "NETMASK=$mask";
        }
    } else {
        if ($ip eq '' || $mask eq '') {    
            $ipinfo='';  
        } else {
            $ipinfo = "IPV6ADDR=$ip\/$mask\n";
            $ipinfo .= "IPV6INIT=yes";
        }
    }
    
     $bond_nic_ip_conf =<< "_BOND_NIC_IP_CONF_";
DEVICE=$bond_nic
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
NM_CONTROLLED=no
BONDING_OPTS="mode=$mode miimon=100"
$ipinfo
_BOND_NIC_IP_CONF_

    if ($sys->exists($bond_nic_cfg)) {
        $bond_nic_cfg_bak = "$bond_nic_cfg.bak";
        Msg::log("Backing up $bond_nic_cfg file as $bond_nic_cfg_bak ");
        $sys->copyfile($bond_nic_cfg , $bond_nic_cfg_bak );
    }

    $sys->writefile($bond_nic_ip_conf ,$bond_nic_cfg);

    return 1;
}

#for RHEL6 only
sub configure_bondnic_sys {
    my ($padv,$sys,$bond_nic,$nic,$nicnew) = @_;
    return $padv->configure_bondnic_common_sys($sys,$bond_nic,$nic,$nicnew);
}

#for RHEL6 only
sub configure_bondnic_common_sys {
   my ($padv,$sys,$bond_nic,$nic,$nicnew) = @_;
   my ($nicfile,$nicfilebk,$mode,$nic_ip_conf,$mac,$output,$max_cnt,$ipinfo);

   $nicfile = "/etc/sysconfig/network-scripts/ifcfg-$nicnew";
   $mac = $sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_awk '/HWaddr/ {print \$5}'");
   $mode = "ONBOOT=yes";

   $nic_ip_conf =<< "_NIC_IP_CONF_";
DEVICE=$nicnew
BOOTPROTO=none
MASTER=$bond_nic
SLAVE=yes
USERCTL=no
TYPE=Ethernet
NM_CONTROLLED=no
HWADDR=$mac
$mode
_NIC_IP_CONF_

   $sys->writefile($nic_ip_conf,$nicfile);
   return 1;
}

sub disable_network_manager {
   my ($padv,$sys) = @_;
   my ($cmd,$flag,$output,$retry,$i);

    $cmd = "/sbin/service NetworkManager status 2>/dev/null";
    $output=$sys->cmd($cmd);   # NetworkManager (pid  6908) is running...
    return 1 if ($output!~/pid/);

    $flag = 0;
    $sys->cmd("/sbin/chkconfig --level 0123456 NetworkManager off >/dev/null 2>&1; /sbin/service NetworkManager stop >/dev/null 2>&1");
    $retry = 15;
    $i = 0;

    while ($i < $retry) {
        $i++;
        sleep 1;
        $output=$sys->cmd($cmd);
        if ($output=~/pid/) {
            Msg::log("Stopping NetworkManager, try $i times");
            $flag = 1;
            next;
        } else {
            $flag = 0;
            last;
        }
    }

    if ($flag) {
        Msg::log("Stopping NetworkManager on $sys->{sys} failed.");
        return 0;
    }
    return 1;
}

# support ipv4 & ipv6 mixed model for one single nic
# support multiple ipv4 & ipv6 addresses on one single nic
sub configure_static_ip_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($cmd,$output);

    if ($sys->{padv}=~ /^SLES10/) {
        return $padv->configure_static_ip_sles10_sys($sys,$nic,$ip,$mask);
    }elsif ($sys->{padv}=~ /^(RHEL|OL|CentOS)/){
	$padv->disable_network_manager($sys);
    }

    if (EDRu::ip_is_ipv6($ip)){
        return $padv->configure_static_ipv6_sles_sys($sys,$nic,$ip,$mask) if ($sys->{padv}=~ /^SLES/);
        return $padv->configure_static_ipv6_common_sys($sys,$nic,$ip,$mask);
    }else{
        return $padv->configure_static_ipv4_sles_sys($sys,$nic,$ip,$mask) if ($sys->{padv}=~ /^SLES/);
        return $padv->configure_static_ipv4_common_sys($sys,$nic,$ip,$mask);
    }
}

sub configure_static_ipv4_sles_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($plumb,$pre_mask,$nicfile,$nicfilebk,$mode,$nic_ip_conf,$output);
    my ($readfile,@lt,$timestamp);

    $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null|_cmd_grep 'inet *$ip/'");
    if ($output=~/inet /){ # record the ip plumb state and the existing mask of the ip
        $plumb=1;
        $pre_mask=$1 if ($output=~ /$ip\/(\d+)/);
    }
    if ($sys->{padv}=~ /^(RHEL|OL|CentOS)/){
        $nicfile = "/etc/sysconfig/network-scripts/ifcfg-" . $nic;
        $mode = "ONBOOT=yes";
    } elsif ($sys->{padv}=~ /^SLES/){
        $nicfile = "/etc/sysconfig/network/ifcfg-" . $nic;
        $mode = "STARTMODE=auto";
    }

    $readfile=$sys->readfile($nicfile);
    # append the ip info to the network configuration file if the $ip/$mask pair not existing
    if ($readfile!~ /IPADDR.*=\D*$ip\D+/ || $readfile=~ / *# *IPADDR.*=\D*$ip\D+/
	    ||($readfile=~ /IPADDR(.*)=\D*$ip\D+/ && $readfile !~ /NETMASK$1=\D*$mask\D+/)){
	@lt=localtime;
        $timestamp= sprintf('%d%02d%02d_%02d%02d%02d',
		                       $lt[5]+1900, $lt[4]+1, $lt[3], $lt[2], $lt[1], $lt[0]);
        $mode = '' if ($readfile=~ /[^#]\s*(STARTMODE|ONBOOT)/);
        $nic_ip_conf =<< "_NIC_IP_CONF_";
IPADDR_$timestamp=$ip
NETMASK_$timestamp=$mask
$mode
_NIC_IP_CONF_
    }

    $sys->cmd("_cmd_ip addr del $ip/$pre_mask dev $nic 2>/dev/null") if ($plumb);
    $sys->cmd("_cmd_ip addr add $ip/$mask dev $nic 2>/dev/null");
    return 0 if (EDR::cmdexit());
    $sys->cmd("_cmd_ip link set $nic up 2>/dev/null");

    if ($sys->exists($nicfile)) {
        $nicfilebk = $nicfile . '.bak';
        Msg::log("Backing up $nicfile file as $nicfilebk");
        $sys->copyfile($nicfile, $nicfilebk);
    }

    $sys->appendfile($nic_ip_conf,$nicfile) if ($nic_ip_conf);
    return 1;
}


sub configure_static_ipv4_common_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($nicfile,$nicfilebk,$mode,$nic_ip_conf,$mac,$output,$max_cnt);
    my ($plumbed_nic,$pre_mask,$prefix,$pre_bcast,$bcast,$new_nic,$str_nic);

    # judge if the ip was plumbed on the nic already
    $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null|_cmd_grep 'inet *$ip/'");
    if ($output=~ /($nic(:\d+)?$)/){
	$plumbed_nic=$1;
	if ($output=~/$ip\/(\d+) (?:brd (\S*) scope)?/) {
	    $pre_mask=$1;
            $pre_bcast=$2;
	}
    }else{
        $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null |_cmd_awk '/inet6? / { print \$4 }'");
        if ($output) {
	    $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null|_cmd_awk '/$nic(:[0-9]+)?\$/ {print \$NF}'");
            $max_cnt=0;
            for my $nic_entry (split(/\n/,$output)) {
               if ($nic_entry=~/$nic:(\d+)/) {
                   $max_cnt=$1 if ($max_cnt<$1);
               }
            }
            $max_cnt++;
            $new_nic=$nic.':'.$max_cnt;
       }
    }

    if ($plumbed_nic){
	$str_nic=$plumbed_nic;
    }elsif ($new_nic){
	$str_nic=$new_nic;
    }else{
	$str_nic=$nic;
    }

    if ($sys->{padv}=~ /^(RHEL|OL|CentOS)/){
        $nicfile = "/etc/sysconfig/network-scripts/ifcfg-" . $str_nic;
        $mode = "ONBOOT=yes";
    } elsif ($sys->{padv}=~ /^SLES/){
        $nicfile = "/etc/sysconfig/network/ifcfg-" . $str_nic;
        $mode = "STARTMODE=auto";
    }

    $mac = $sys->cmd("_cmd_ip link show $nic 2>/dev/null | _cmd_awk '/^ *link/ { print \$2 }'");
    $nic_ip_conf =<< "_NIC_IP_CONF_";
DEVICE=$str_nic
BOOTPROTO=static
IPADDR=$ip
HWADDR=$mac
NETMASK=$mask
$mode
_NIC_IP_CONF_
    
    $output=$sys->cmd("_cmd_ipcalc -bp $ip $mask 2>/dev/null");
    $prefix=$1  if($output=~ /PREFIX=(\d+)/);
    $bcast=$1  if($output=~ /BROADCAST=(.*)$/);
    if (!($plumbed_nic && $pre_mask && $pre_bcast && $pre_mask==$prefix)){
       $sys->cmd("_cmd_ip addr del $ip/$pre_mask dev $plumbed_nic 2>/dev/null") if ($plumbed_nic && $pre_mask);
       $sys->cmd("_cmd_ip addr add $ip/$mask broadcast $bcast dev $str_nic 2>/dev/null");
       return 0 if (EDR::cmdexit());
       $sys->cmd("_cmd_ip link set $str_nic up 2>/dev/null");
    }

    if ($sys->exists($nicfile)) {
        $nicfilebk = $nicfile . '.bak';
        Msg::log("Backing up $nicfile file as $nicfilebk");
        $sys->copyfile($nicfile, $nicfilebk);
    }

    $sys->writefile($nic_ip_conf,$nicfile);
    return 1;
}

sub configure_static_ipv6_sles_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($plumb,$prefixlen,$nicfile,$nicfilebk,$mode,$nic_ip_conf,$output);
    my ($readfile,@lt,$timestamp);

    $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null|_cmd_grep 'inet6 *$ip/'");
    if ($output=~/inet6 /){ # record the ip plumb state and the prefixlen
        $plumb=1;
        $prefixlen=$1 if ($output=~ /$ip\/(\d+)/);
    }
    if ($sys->{padv}=~ /^(RHEL|OL|CentOS)/){
        $nicfile = "/etc/sysconfig/network-scripts/ifcfg-" . $nic;
        $mode = "ONBOOT=yes";
    } elsif ($sys->{padv}=~ /^SLES/){
        $nicfile = "/etc/sysconfig/network/ifcfg-" . $nic;
        $mode = "STARTMODE=auto";
    }

    $readfile=$sys->readfile($nicfile);
    # append the ipv6 info to the network configuration file if the $ip/$mask pair not existing
    if ($readfile!~ /IPADDR.*=\D*$ip\D+/ || $readfile=~ / *# *IPADDR.*=\D*$ip\D+/
	    ||($readfile=~ /IPADDR(.*)=\D*$ip\D+/ && $readfile !~ /PREFIXLEN$1=\D*$mask\D+/)){
	@lt=localtime;
        $timestamp= sprintf('%d%02d%02d_%02d%02d%02d',
		                       $lt[5]+1900, $lt[4]+1, $lt[3], $lt[2], $lt[1], $lt[0]);
        $mode = '' if ($readfile=~ /[^#]\s*(STARTMODE|ONBOOT)/);
        $nic_ip_conf =<< "_NIC_IP_CONF_";
IPADDR_$timestamp=$ip
PREFIXLEN_$timestamp=$mask
$mode
_NIC_IP_CONF_
    }

    if (!$plumb){
        $sys->cmd("_cmd_ip -6 addr add $ip/$mask dev $nic 2>/dev/null");
    }elsif ($plumb && $mask!=$prefixlen){ # ip plumbed with different prefixlen
        $sys->cmd("_cmd_ip -6 addr del $ip/$prefixlen dev $nic 2>/dev/null");
        $sys->cmd("_cmd_ip -6 addr add $ip/$mask dev $nic 2>/dev/null");
    }
    return 0 if (EDR::cmdexit());
    $sys->cmd("_cmd_ip link set $nic up 2>/dev/null");

    if ($sys->exists($nicfile)) {
        $nicfilebk = $nicfile . '.bak';
        Msg::log("Backing up $nicfile file as $nicfilebk");
        $sys->copyfile($nicfile, $nicfilebk);
    }

    $sys->appendfile($nic_ip_conf,$nicfile) if ($nic_ip_conf);
    return 1;
}

sub configure_static_ipv6_common_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($plumb,$prefixlen,$nicfile,$nicfilebk,$mode,$nic_ip_conf,$output,$mac);
    my ($readfile,$line_secd,$new_nicfile,$line_new);

    $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null|_cmd_grep 'inet6 *$ip/'");
    if ($output=~/inet6 /){ # record the ip plumb state and the prefixlen
        $plumb=1;
        $prefixlen=$1 if ($output=~ /$ip\/(\d+)/);
    }

    if (!$plumb){
        $sys->cmd("_cmd_ip -6 addr add $ip/$mask dev $nic 2>/dev/null");
    }elsif ($plumb && $mask!=$prefixlen){ # ip plumbed with different prefixlen
        $sys->cmd("_cmd_ip -6 addr del $ip/$prefixlen dev $nic 2>/dev/null");
        $sys->cmd("_cmd_ip -6 addr add $ip/$mask dev $nic 2>/dev/null");
    }
    return 0 if (EDR::cmdexit());
    $sys->cmd("_cmd_ip link set $nic up 2>/dev/null");

    if ($sys->{padv}=~ /^(RHEL|OL|CentOS)/){
        $nicfile = "/etc/sysconfig/network-scripts/ifcfg-" . $nic;
        $mode = "ONBOOT=yes";
    } elsif ($sys->{padv}=~ /^SLES/){
        $nicfile = "/etc/sysconfig/network/ifcfg-" . $nic;
        $mode = "STARTMODE=auto";
    }

    if ($sys->exists($nicfile)) {
        $nicfilebk = $nicfile . '.bak';
        Msg::log("Backing up $nicfile file as $nicfilebk");
        $sys->copyfile($nicfile, $nicfilebk);
    }

    $readfile=$sys->readfile($nicfile);
    $mac = $sys->cmd("_cmd_ip link show $nic 2>/dev/null | _cmd_awk '/^ *link/ { print \$2 }'");
    $sys->appendfile("HWADDR=$mac",$nicfile) if ($readfile!~ /HWADDR=/);
    $sys->appendfile("IPV6INIT=yes",$nicfile) if ($readfile!~ /IPV6INIT=yes/);

    if ($readfile!~ /IPV6ADDR.*=\D*$ip\//){
        if ($readfile=~/IPV6ADDR_SECONDARIES/){
	   # append to IPV6ADDR_SECONDARIES="100::300/128 10::400/128 10::500/64"
	   $line_secd = $sys->grepfile("IPV6ADDR_SECONDARIES",$nicfile);
	   $new_nicfile=$nicfile."_tmp";
	   $line_new="IPV6ADDR_SECONDARIES=\"$ip/$mask $1\"" if ($line_secd=~/IPV6ADDR_SECONDARIES *= *(.*)$/);
	   # using ';' as the separater instead of '/' which may conflict with the variable value
           $sys->cmd("_cmd_sed 's;$line_secd;$line_new;g' $nicfile 2>/dev/null >$new_nicfile");
	   $sys->movefile($new_nicfile,$nicfile);
	   $sys->rm($new_nicfile);
	}elsif ($readfile=~/IPV6ADDR=/){
	   $sys->appendfile("IPV6ADDR_SECONDARIES=$ip/$mask",$nicfile);
	}else{
	   $sys->appendfile("IPV6ADDR=$ip/$mask",$nicfile);
	}
    }

    $sys->appendfile($mode,$nicfile) if ($readfile!~ /ONBOOT|STARTMODE/);
    return 1;
}

sub configure_static_ip_sles10_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($nicfile,$nicfilebk,$mode,$nic_ip_conf,$mac,$output,$content);

    # step1: Get mac addr
    my $hw_addr = $sys->cmd("_cmd_ip link show $nic 2>/dev/null | _cmd_awk '/^ *link/ { print \$2 }'");
    return 0 if (!$hw_addr || $hw_addr eq '');

    # Step2: Get max_cnt
    my $nic_name=$nic;
    my $max_cnt;
    $output=$sys->cmd("_cmd_ip -o addr show dev $nic 2>/dev/null | _cmd_awk '/inet / { print \$4 }'");
    if ($output) {
        $output = $sys->cmd("_cmd_ifconfig -a 2>/dev/null|_cmd_awk '/^$nic:/ {print \$1}'");
        $max_cnt=0;
        for my $nic_entry (split(/\n/,$output)){
            if ($nic_entry=~/$nic:(\d+)/){
                $max_cnt=$1 if ($max_cnt<$1);
            }
        }
        $max_cnt++;
        $nic_name=$nic.':'.$max_cnt;
    }

    # Step3: Check mac and eth config file
    my $mac_file_uc= '/etc/sysconfig/network/ifcfg-eth-id-'.uc($hw_addr);
    my $mac_file_lc= '/etc/sysconfig/network/ifcfg-eth-id-'.lc($hw_addr);
    my $mac_file = $mac_file_uc;
    my $eth_file = '/etc/sysconfig/network/ifcfg-'.$nic;

    my $mac_file_exist = 1;
    my $eth_file_exist = $sys->exists($eth_file);
    if ($sys->exists($mac_file_uc)) {
        # Upcase file' priority is higher
        $mac_file = $mac_file_uc;
    } elsif ($sys->exists($mac_file_lc)) {
        $mac_file = $mac_file_lc;
    } else {
        $mac_file_exist = 0;
    }

    # Step4: Create mac config file if need
    if (!$mac_file_exist && !$eth_file_exist) {
        $content = << "_NIC_IP_CONF_";
DEVICE=$nic
BOOTPROTO=static
IPADDR=$ip
HWADDR=$hw_addr
NETMASK=$mask
STARTMODE=auto
_NIC_IP_CONF_
        $sys->writefile($content, $mac_file);
    } else {
       $sys->copyfile($eth_file, $mac_file) if (!$mac_file_exist);
       $sys->copyfile($mac_file, $mac_file.'.bak');

       # Step5: Get max label_id & max alias_id
       my $max_label = 0;
       my $max_alias = 0;
       $output = $sys->cmd("_cmd_grep '^ *LABEL_' $mac_file  2>/dev/null");
       if ($output && $output ne '') {
           #get the max_id and max_alias
           for my $line (split(/\n/,$output)) {
               if($line=~/LABEL_(\d+)\s*=\s*['"]?(\d+)/mx) {
                  my $label_id = $1;
                  my $alias_id = $2;
                  $max_label = $label_id if ($label_id>$max_label);
                  $max_alias = $alias_id if ($alias_id>$max_alias)
               }
           }
       }
       $max_label++;
       $max_alias++;
       $content = << "_NIC_IP_CONF_";
IPADDR_$max_label='$ip'
NETMASK_$max_label='$mask'
LABEL_$max_label='$max_alias'
_NIC_IP_CONF_
       $sys->appendfile($content, $mac_file);
    }

    # Step6: ifconfig up
    $sys->cmd("_cmd_ifconfig $nic_name $ip netmask $mask up 2>/dev/null");
    return 0 if (EDR::cmdexit());

    return 1;
}

sub yum_install_rpms_sys {
    my ($padv,$sys,$missing_ospkgs)=@_;
    my (@not_available_pkgs,$pkgs,$msg);

    # Check if the packages are available in yum repositories
    @not_available_pkgs=();
    for my $pkg (@{$missing_ospkgs}) {
        $sys->cmd("/usr/bin/yum list available $pkg 2>&1");
        if (EDR::cmdexit()) {
            push @not_available_pkgs, $pkg;
        }
    }

    if (@not_available_pkgs) {
        $pkgs=join ' ', @not_available_pkgs;
        $msg=Msg::new("No matching packages for $pkgs in yum repositories on $sys->{sys}, make sure the yum repository is set up correctly for $sys->{minorvers} on $sys->{sys}");
        $sys->{native_install_fail_message}=$msg;
        return 0;
    }

    # Check if the packages are installed successfully or not with yum
    $pkgs=join ' ', @$missing_ospkgs;
    $sys->cmd("/usr/bin/yum -y install $pkgs 2>&1");
    if (EDR::cmdexit()) {
        $msg=Msg::new("yum failed to install $pkgs on $sys->{sys}");
        $sys->{native_install_fail_message}=$msg;
        return 0;
    }
    return 1;
}

sub zypper_install_rpms_sys {
    my ($padv,$sys,$missing_ospkgs)=@_;
    my ($pkgs,$msg,$rtn,$exitcode);

    # Check if the packages are installed successfully or not with yum
    $pkgs=join ' ', @$missing_ospkgs;
    $rtn=$sys->cmd("/usr/bin/zypper --non-interactive install $pkgs 2>&1");
    $exitcode=EDR::cmdexit();
    if ($exitcode) {
        # 'zypper install' exit with non-zero
        # zypper exit codes in 'man zypper' 
        # 0 - ZYPPER_EXIT_OK
        # 1 - ZYPPER_EXIT_ERR_BUG
        # 2 - ZYPPER_EXIT_ERR_SYNTAX
        # 3 - ZYPPER_EXIT_ERR_INVALID_ARGS
        # 4 - ZYPPER_EXIT_ERR_ZYPP
        # 5 - ZYPPER_EXIT_ERR_PRIVILEGES
        # 100 - ZYPPER_EXIT_INF_UPDATE_NEEDED
        # 101 - ZYPPER_EXIT_INF_SEC_UPDATE_NEEDED
        # 102 - ZYPPER_EXIT_INF_REBOOT_NEEDED
        # 103 - ZYPPER_EXIT_INF_RESTART_NEEDED
        # 104 - ZYPPER_EXIT_INF_CAP_NOT_FOUND
        # 105 - ZYPPER_EXIT_ON_SIGNAL
        if ($exitcode == 104) {
            $msg=Msg::new("No matching packages for $pkgs in zypper repositories on $sys->{sys}, make sure the zypper repository is set up correctly for $sys->{minorvers} on $sys->{sys}");
        } else {
            $msg=Msg::new("zypper failed to install $pkgs on $sys->{sys}");
        }
        $sys->{native_install_fail_message}=$msg;
        return 0;
    } else {
        # 'zypper install' exit with 0
        # Incident 3313117: 'zypper install' may return 'Unexpected exception'
        if ($rtn=~/Unexpected exception/mx) {
            $msg=Msg::new("zypper ran into unexpected exception and failed to install $pkgs on $sys->{sys}");
            $sys->{native_install_fail_message}=$msg;
            return 0;
        }
    }
    return 1;
}

package Padv::Debian26;
@Padv::Debian26::ISA = qw(Padv::Linux);

sub pkg_copy_sys {
    my $padv=shift;
    $padv->tar_install_sys(@_);
    return;
}

sub pkg_install_sys { }

sub pkg_remove_sys { }

# default passes for platforms using tar files
sub patch_install_success_sys { return 1; }
sub pkg_install_success_sys { return 1; }
sub pkg_uninstall_success_sys { return 1; }

package Padv::ESX30i686;
@Padv::ESX30i686::ISA = qw(Padv::Linux);

package Padv::ESX35i686;
@Padv::ESX35i686::ISA = qw(Padv::Linux);

package Padv::RHEL4i686;
@Padv::RHEL4i686::ISA = qw(Padv::Linux);

package Padv::RHEL4x8664;
@Padv::RHEL4x8664::ISA = qw(Padv::Linux);

package Padv::RHEL4ppc64;
@Padv::RHEL4ppc64::ISA = qw(Padv::Linux);

package Padv::RHEL4s390x;
@Padv::RHEL4s390x::ISA = qw(Padv::Linux);

package Padv::RHEL4ia64;
@Padv::RHEL4ia64::ISA = qw(Padv::Linux);

package Padv::RHEL5i686;
@Padv::RHEL5i686::ISA = qw(Padv::Linux);

package Padv::RHEL5x8664;
@Padv::RHEL5x8664::ISA = qw(Padv::Linux);

package Padv::RHEL5ppc64;
@Padv::RHEL5ppc64::ISA = qw(Padv::Linux);

package Padv::RHEL5s390x;
@Padv::RHEL5s390x::ISA = qw(Padv::Linux);

package Padv::RHEL5ia64;
@Padv::RHEL5ia64::ISA = qw(Padv::Linux);

package Padv::RHEL6i686;
@Padv::RHEL6i686::ISA = qw(Padv::Linux);

package Padv::RHEL6x8664;
@Padv::RHEL6x8664::ISA = qw(Padv::Linux);

package Padv::RHEL6ia64;
@Padv::RHEL6ia64::ISA = qw(Padv::Linux);

package Padv::RHEL6ppc64;
@Padv::RHEL6ppc64::ISA = qw(Padv::Linux);

package Padv::RHEL6s390x;
@Padv::RHEL6s390x::ISA = qw(Padv::Linux);

package Padv::RHEL7i686;
@Padv::RHEL7i686::ISA = qw(Padv::Linux);

package Padv::RHEL7x8664;
@Padv::RHEL7x8664::ISA = qw(Padv::Linux);

package Padv::RHEL7ia64;
@Padv::RHEL7ia64::ISA = qw(Padv::Linux);

package Padv::RHEL7ppc64;
@Padv::RHEL7ppc64::ISA = qw(Padv::Linux);

package Padv::RHEL7s390x;
@Padv::RHEL7s390x::ISA = qw(Padv::Linux);

package Padv::CentOS5x8664;
@Padv::CentOS5x8664::ISA = qw(Padv::Linux);

package Padv::CentOS6x8664;
@Padv::CentOS6x8664::ISA = qw(Padv::Linux);

package Padv::OL5x8664;
@Padv::OL5x8664::ISA = qw(Padv::Linux);

package Padv::OL6x8664;
@Padv::OL6x8664::ISA = qw(Padv::Linux);

package Padv::OL7x8664;
@Padv::OL7x8664::ISA = qw(Padv::Linux);

package Padv::SLES9i686;
@Padv::SLES9i686::ISA = qw(Padv::Linux);

package Padv::SLES9x8664;
@Padv::SLES9x8664::ISA = qw(Padv::Linux);

package Padv::SLES9i586;
@Padv::SLES9i586::ISA = qw(Padv::Linux);

package Padv::SLES9ppc64;
@Padv::SLES9ppc64::ISA = qw(Padv::Linux);

package Padv::SLES9s390x;
@Padv::SLES9s390x::ISA = qw(Padv::Linux);

package Padv::SLES9ia64;
@Padv::SLES9ia64::ISA = qw(Padv::Linux);

package Padv::SLES10i686;
@Padv::SLES10i686::ISA = qw(Padv::Linux);

package Padv::SLES10x8664;
@Padv::SLES10x8664::ISA = qw(Padv::Linux);

package Padv::SLES10ppc64;
@Padv::SLES10ppc64::ISA = qw(Padv::Linux);

package Padv::SLES10s390x;
@Padv::SLES10s390x::ISA = qw(Padv::Linux);

package Padv::SLES10ia64;
@Padv::SLES10ia64::ISA = qw(Padv::Linux);

package Padv::SLES10i586;
@Padv::SLES10i586::ISA = qw(Padv::Linux);

package Padv::SLES11i686;
@Padv::SLES11i686::ISA = qw(Padv::Linux);

package Padv::SLES11x8664;
@Padv::SLES11x8664::ISA = qw(Padv::Linux);

package Padv::SLES11ppc64;
@Padv::SLES11ppc64::ISA = qw(Padv::Linux);

package Padv::SLES11s390x;
@Padv::SLES11s390x::ISA = qw(Padv::Linux);

package Padv::SLES11i586;
@Padv::SLES11i586::ISA = qw(Padv::Linux);

package Padv::SLES11ia64;
@Padv::SLES11ia64::ISA = qw(Padv::Linux);

package Padv::SLES12i686;
@Padv::SLES12i686::ISA = qw(Padv::Linux);

package Padv::SLES12x8664;
@Padv::SLES12x8664::ISA = qw(Padv::Linux);

package Padv::SLES12ppc64;
@Padv::SLES12ppc64::ISA = qw(Padv::Linux);

package Padv::SLES12s390x;
@Padv::SLES12s390x::ISA = qw(Padv::Linux);

package Padv::SLES12i586;
@Padv::SLES12i586::ISA = qw(Padv::Linux);

package Padv::SLES12ia64;
@Padv::SLES12ia64::ISA = qw(Padv::Linux);

1;
