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
package Padv::HPUX;
use strict;
@Padv::HPUX::ISA = qw(Padv);

sub padvs { return [ qw(HPUX1111par  HPUX1123par  HPUX1131par
                        HPUX1111ia64 HPUX1123ia64 HPUX1131ia64) ]; }

sub init_plat {
    my ($padv) = @_;
    $padv->{plat}='HPUX';
    $padv->{pkgpath}='depot';
    $padv->{patchpath}='depot';

    # Define padvform specific commands
    $padv->{cmd}{adb}='/usr/bin/adb';
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
    $padv->{cmd}{dfk}='/usr/bin/bdf -l';
    $padv->{cmd}{diff}='/usr/bin/diff';
    $padv->{cmd}{dirname}='/usr/bin/dirname';
    $padv->{cmd}{du}='/usr/bin/du';
    $padv->{cmd}{echo}='/usr/bin/echo';
    $padv->{cmd}{egrep}='/usr/bin/egrep';
    $padv->{cmd}{find}='/usr/bin/find';
    $padv->{cmd}{grep}='/usr/bin/grep';
    $padv->{cmd}{groups}='/usr/bin/groups';
    $padv->{cmd}{groupadd}='/usr/sbin/groupadd';
    $padv->{cmd}{groupdel}='/usr/sbin/groupdel';
    $padv->{cmd}{groupmod}='/usr/sbin/groupmod';
    $padv->{cmd}{gunzip}='/usr/contrib/bin/gunzip';
    $padv->{cmd}{head}='/usr/bin/head';
    $padv->{cmd}{hostname}='/usr/bin/hostname';
    $padv->{cmd}{id}='/usr/bin/id';
    $padv->{cmd}{ifconfig}='/usr/sbin/ifconfig';
    $padv->{cmd}{kcmodule}='/usr/sbin/kcmodule';
    $padv->{cmd}{kctune}='/usr/sbin/kctune';
    $padv->{cmd}{kill}='/usr/bin/kill';
    $padv->{cmd}{lanadmin}='/usr/sbin/lanadmin';
    $padv->{cmd}{lanscan}='/usr/sbin/lanscan';
    $padv->{cmd}{ldd}='/usr/ccs/bin/ldd';
    $padv->{cmd}{ls}='/usr/bin/ls';
    $padv->{cmd}{ln}='/usr/bin/ln';
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
    $padv->{cmd}{pwd}='/usr/bin/pwd';
    $padv->{cmd}{rcp}='/usr/bin/rcp';
    $padv->{cmd}{rm}='/usr/bin/rm';
    $padv->{cmd}{rmr}='/usr/bin/rm -rf';
    $padv->{cmd}{rmdir}='/usr/bin/rm -rf';
    $padv->{cmd}{rsh}='/usr/bin/remsh';
    $padv->{cmd}{scp}='/usr/bin/scp';
    $padv->{cmd}{sed}='/usr/bin/sed';
    $padv->{cmd}{sh}='/usr/bin/sh';
    $padv->{cmd}{shutdown}='/usr/sbin/shutdown -r now';
    $padv->{cmd}{sleep}='/usr/bin/sleep';
    $padv->{cmd}{sort}='/usr/bin/sort';
    $padv->{cmd}{ssh}='/usr/bin/ssh';
    $padv->{cmd}{sshkeygen}='/usr/bin/ssh-keygen';
    $padv->{cmd}{sshkeyscan}='/usr/bin/ssh-keyscan';
    $padv->{cmd}{strings}='/usr/bin/strings';
    $padv->{cmd}{su}='/usr/bin/su';
    $padv->{cmd}{swapinfo}='/usr/sbin/swapinfo';
    $padv->{cmd}{swagentd}='/usr/sbin/swagentd';
    $padv->{cmd}{swinstall}='/usr/sbin/swinstall';
    $padv->{cmd}{swlist}='/usr/sbin/swlist';
    $padv->{cmd}{swmodify}='/usr/sbin/swmodify';
    $padv->{cmd}{swreg}='/usr/sbin/swreg';
    $padv->{cmd}{swremove}='/usr/sbin/swremove';
    $padv->{cmd}{swcopy}='/usr/sbin/swcopy';
    $padv->{cmd}{swverify}='/usr/sbin/swverify';
    $padv->{cmd}{swjob}='/usr/sbin/swjob';
    $padv->{cmd}{make_bundles}='/opt/ignite/bin/make_bundles';
    $padv->{cmd}{make_config}='/opt/ignite/bin/make_config';
    $padv->{cmd}{manage_index}='/opt/ignite/bin/manage_index';
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
    $padv->{cmd}{yes}='/usr/bin/yes';
    $padv->{cmd}{hostid}='/usr/bin/uname -i';
    $padv->{cmd}{model}='/usr/bin/model';
    $padv->{cmd}{getconf}='/usr/bin/getconf';
    $padv->{cmd}{ioscan}='/sbin/ioscan';
    $padv->{cmd}{cstm}='/usr/sbin/cstm';
    $padv->{cmd}{machinfo}='/usr/contrib/bin/machinfo';
    $padv->{cmd}{print_manifest}='/opt/ignite/bin/print_manifest';
    $padv->{cmd}{hpvminfo}='/opt/hpvm/bin/hpvminfo';
    $padv->{cmd}{cksum}='/usr/bin/cksum';
    return;
}

# this set of commands is executed during info_sys before the padv objects
# are created and therefore full command paths are required

sub arch_sys {
    my ($padv,$sys)= @_;
    my @uname=split(/\s+/m,$sys->{uname});
    return $uname[4];
}

sub platvers_sys {
    my ($padv,$sys,$vers)= @_;
    $vers=~s/^[A-Z]\.//m;
    return $vers;
}

sub combo_arch {
    my $edr=Obj::edr();
    for my $padv(@{$edr->{padvs}}) { return 1 if ($padv=~/^HPUX\d+$/m); }
    return;
}

sub distro_sys { return 'HPUX'; }

# UxRT creates combo packages for HP-UX that include IA and PA arches
# NBU will create unique packages for IA and PA
# A release cannot mix combo (no PA|IA) padvs with non combo (PA|IA)
sub padv_sys {
    my ($padv,$sys) = @_;
    my ($vers,$arch);
    $arch=$sys->{arch};
    $vers=$sys->{platvers};
    if (combo_arch()) {
        return 'HPUX1131' if (($vers eq '11.31') ||
                                ((EDRu::compvers('11.31',$vers)==2) &&
                                 (EDR::get2('padv_unbounded','HPUX1131'))));
        return 'HPUX1123' if ($vers eq '11.23');
        return 'HPUX1111' if ($vers eq '11.11');
        $arch='';
    } elsif ($arch eq '9000/800') {
        return 'HPUX1131par' if (($vers eq '11.31') ||
                                ((EDRu::compvers('11.31',$vers)==2) &&
                                 (EDR::get2('padv_unbounded','HPUX1131par'))));
        return 'HPUX1123par' if ($vers eq '11.23');
        return 'HPUX1111par' if ($vers eq '11.11');
        $arch='pa';
    } elsif ($arch eq 'ia64') {
        return 'HPUX1131ia64' if (($vers eq '11.31') ||
                                ((EDRu::compvers('11.31',$vers)==2) &&
                                 (EDR::get2('padv_unbounded','HPUX1131ia64'))));
        return 'HPUX1123ia64' if ($vers eq '11.23');
        return 'HPUX1111ia64' if ($vers eq '11.11');
    }
    # unsupported zone, this will eventually error
    $vers=~s/\.//mg;
    return "HPUX$vers$arch";
}

sub fqdn_ip_sys {
    my ($padv,$sys) = @_;
    my ($fqdn,$ip,$nslookup,$cmd);
    $cmd = ($padv->localpadv=~/^Sol/m) ? '/usr/sbin/nslookup' :
                                         '/usr/bin/nslookup';
    $nslookup=EDR::cmd_local("$cmd -timeout=2 -retry=1 $sys->{sys}");
    for my $line (split(/\n/,$nslookup)) {
        $fqdn = $line if ($line =~ s/Name:\W+//m);
        $ip = $line if ($fqdn && ($line =~ s/Address:\W+//mx));
        return ($fqdn,$ip) if ($fqdn && $ip);
    }
    return (undef, undef);
}

sub ipv4_sys {
    my ($padv,$sys) = @_;
    my $ipv4nics=$sys->cmd("_cmd_netstat -i -f inet 2>/dev/null | _cmd_awk '! /^Name|lo0/ {print \$1}'");
    if ($ipv4nics) {
        return 1;
    }
    return 0;
}

sub ipv6_sys {
    my ($padv,$sys) = @_;
    my $ipv6nics=$sys->cmd("_cmd_netstat -i -f inet6 2>/dev/null | _cmd_awk '! /^Name|lo0/ {print \$1}'");
    if ($ipv6nics) {
        # Added to handle the swlist with IPv6 issue on HPUX
        $sys->cmd('_cmd_swlist 2>/dev/null 1>/dev/null');
        return 1;
    }
    return 0;
}

# DONE with info_sys routines that require full command paths

# Returns a reference to an array holding the NICs connected to the default gateway/router
sub gatewaynics_sys {
    my ($padv,$sys) = @_;
    my (@values,@nics,@lines,$do);
    $do=$sys->cmd('_cmd_netstat -nr 2>/dev/null');
    @lines=split(/\n/,$do);
    for my $line (@lines) {
        @values = split(/\s+/m,$line);
        if ($values[2] eq 'UG') {
            push @nics,$values[4];
        }
    }
    return EDRu::arruniq(sort @nics);
}

# Prevent swagentd from rebooting
sub auto_reboot_disable_sys {
    my ($padv,$sys) = @_;
    my ($msg,$defaultsfile,$tmpfile,$tmpdir);
    $defaultsfile='/var/adm/sw/defaults';
    $tmpdir=EDR::tmpdir();
    $tmpfile="$tmpdir/sw.defaults.new.$sys->{sys}";
    $msg='swagent.reboot_cmd = /bin/true';
    if ($sys->exists($defaultsfile)) {
        $sys->cmd("_cmd_grep -v swagent.reboot_cmd $defaultsfile 2>/dev/null 1>$tmpfile");
    }
    $sys->appendfile($msg,$tmpfile);
    $sys->cmd("_cmd_mv $defaultsfile $defaultsfile.cpi 2>/dev/null");
    $sys->cmd("_cmd_mv $tmpfile $defaultsfile 2>/dev/null");
    $sys->cmd("_cmd_chmod 444 $defaultsfile 2>/dev/null");
    $sys->cmd('cd /;_cmd_swagentd -r 2>/dev/null');
    return '';
}

# Enable swagentd to reboot
sub auto_reboot_enable_sys {
    my ($padv,$sys) = @_;
    my $defaultsfile='/var/adm/sw/defaults';
    if ($sys->exists("$defaultsfile.cpi")) {
        $sys->cmd("_cmd_rmr $defaultsfile 2>/dev/null");
        $sys->cmd("_cmd_mv $defaultsfile.cpi $defaultsfile 2>/dev/null");
        $sys->cmd('cd /;_cmd_swagentd -r 2>/dev/null');
    }
    return '';
}

sub bundle_pkg_sys {
    my ($padv,$sys,$bundle_pkg)= @_;
    my $rc=$sys->cmd("_cmd_swlist -l product -a revision -x verbose=0 $bundle_pkg 2>/dev/null | _cmd_awk '/$bundle_pkg/ {print \$1}'");

    if ($rc) {
        if ($rc eq $bundle_pkg) {
            return 1;
        }else{
            return 0;
        }
    }
    return 0;
}

sub bundle_sys {
    my ($padv,$sys,$bundle)= @_;
    my $rc=$sys->cmd("_cmd_swlist -l bundle 2>/dev/null | _cmd_grep -w $bundle | _cmd_awk '{print \$1}'");

    # Another implementation
    #my $rc=$sys->cmd("_cmd_swlist -a fileset $bundle 2>/dev/null | _cmd_grep -v '^\#' | _cmd_grep -c '$bundle'");

    if ($rc) {
        if ($rc eq $bundle) {
            return 1;
        }else{
            return 0;
        }
    }
    return 0;
}

sub bundle_uninstall_sys {
    my ($padv,$sys,$bundle)= @_;
    $sys->cmd("_cmd_swmodify -u $bundle 2>/dev/null");
    return 1;
}

sub cpu_sys {
    my ($padv,$sys)= @_;
    my ($cpu_count, $cpu_type, $cpu_speed, @cpus);
    my ($cmd, $ret, $i);

    if ($sys->{arch} eq 'ia64') {
        $ret = $sys->cmd('_cmd_ioscan -fnkC processor 2>/dev/null');
        $cpu_count = grep {/^processor/m} split(/\n+/, $ret);

        if ($sys->{padv} =~ /HPUX1123/m) {
            $ret = $sys->cmd('_cmd_machinfo 2>/dev/null');
            foreach my $line (split(/\n+/, $ret)) {
                if ($line =~ /processor model\s*:\s*(.*)/m) {
                    $cpu_type = $1;
                    $cpu_type = $' if ($cpu_type =~ /(\d+)/m);
                    $cpu_type = EDRu::despace($cpu_type);
                }
                if ($line =~ /Clock speed/m) {
                    (undef, $cpu_speed) = split(/=/m, $line);
                    $cpu_speed = EDRu::despace($cpu_speed);
                }
            }

            for my $i (0..($cpu_count-1)) {
                my %cpu = ( NAME  => "$i",
                            TYPE  => $cpu_type,
                            SPEED => $cpu_speed,
                          );
                push(@cpus, \%cpu);
            }
        } else {
            # For HPUX1131
            $ret = $sys->cmd('_cmd_machinfo 2>/dev/null');
            my @lines = grep {/processor/m} split(/\n+/, $ret);
            if ($lines[0] =~ /\s+(\d)\s(.*)processors*\s+\((.*),/mxi) {
                $cpu_type = $2;
                $cpu_speed = $3;
            }

            for my $i (0..($cpu_count-1)) {
                my %cpu = ( NAME  => "cpu$i",
                            TYPE  => $cpu_type,
                            SPEED => $cpu_speed,
                          );
                push(@cpus, \%cpu);
            }
        }
    } else {
        # PA-RISC architecture
        $cmd = "echo 'selclass qualifier cpu;info;wait;infolog' | _cmd_cstm 2>/dev/null";
        $ret = $sys->cmd($cmd);
        foreach my $line (grep {/Processor Number:/m} split(/\n+/, $ret)) {
            $line = EDRu::despace($line);
            my @fields = split(/\s+/m, $line);
            my %cpu = ( NAME => $fields[2] );
            push(@cpus, \%cpu);
        }

        $i = 0;
        foreach my $cpu (@cpus) {
            my @type_lines = grep {/CPU Module/m} split(/\n+/, $ret);
            $cpu->{TYPE} = EDRu::despace($type_lines[$i]);

            my @speed_lines = grep {/Processor Speed:/m} split(/\n+/, $ret);
            if ($speed_lines[$i] =~ /Processor Speed:\s*(\d+)/m) {
                $cpu->{SPEED} = ($1 / 1000000) . 'MHz';
            }
        }
    }

    $cmd = "echo 'itick_per_usec/D' | _cmd_adb -o /stand/vmunix /dev/kmem | _cmd_tail -1 | _cmd_awk '{print \$2}'";
    $ret = $sys->cmd($cmd);
    my @av = split(/\n+/, $ret);
    if (@av) {
        foreach my $cpu(@cpus) {
            $cpu->{SPEED} = $av[0]. 'MHz';
        };
    }

    return \@cpus;
}

sub cpu_number_sys {
    my ($padv,$sys)= @_;
    my ($rtn, $cpu_count);

    $rtn = $sys->cmd('_cmd_ioscan -fnkC processor 2>/dev/null | _cmd_grep processor');

    $cpu_count=0;
    for my $line (split(/\n+/, $rtn)) {
        $cpu_count++ if ($line =~ /^processor/m);
    }

    return $cpu_count;
}

sub cpu_speed_sys {
    my ($padv,$sys) = @_;
    my ($ret,$cpu_type,$cpu_speed);

    $ret = $sys->cmd("_cmd_machinfo 2>/dev/null | _cmd_grep processor");
    if ($ret =~ /\s+(\d)\s(.*)processors*\s+\((.*),/mxi) {
        $cpu_type = $2;
        $cpu_speed = $3;
    }
    return $cpu_speed;
}

# Check to see whether a driver is loaded on a system
# Return module number if so
sub driver_sys {
    my ($padv,$sys,$dr) = @_;

    my $mn=$sys->cmd("_cmd_kcmodule -P state $dr 2>/dev/null | _cmd_awk '{print \$2}'");
    return '' if (($mn =~ /unused/m) || (!$mn));
    return "$mn";
}

# Determine the install path for 3 types of depots
#                             local                    remote
#  1. directory depot         dirname($pkg->{file})    EDR::tmpdir()
#  2. tape depot              $pkg->{file}             EDR::tmpdir()/basename($pkg->{file})
#
#  return the value used for '-d' option of swinstall command.
#
sub installpath_sys {
    my ($padv,$sys,$pkgpatch) = @_;
    my ($file,$basename,$tmpdir,$path);

    $file=$pkgpatch->{file};
    $basename=EDRu::basename($file);
    $tmpdir=EDR::tmpdir();

    if ($sys->{islocal}) {
        $path=EDRu::dirname($file);
        $path=$file if ($file=~/\.depot$/m);
    } else {
        $path=$tmpdir;
        $path="$tmpdir/$basename" if ($file=~/\.depot$/m);
    }
    return $path;
}

# Support both IPv4 and IPv6
sub ips_sys {
    my ($padv,$sys) = @_;
    my ($i,@i,@ips,$ip);

    $ip=$sys->cmd("_cmd_netstat -in 2>/dev/null | _cmd_awk '{print \$3}'");
    @i=split(/\s+/m,$ip);
    for my $i (@i) {
        if (EDRu::isip($i)) {
            if (EDRu::ip_is_ipv4($i)) {
                push(@ips,$i) if (($i ne '0.0.0.0') && ($i ne '127.0.0.1'));
            } elsif (EDRu::ip_is_ipv6($i)) {
                push(@ips,$i) if ((EDRu::iptype_ipv6($i) !~ m/UNSPEC/i) &&
                                  (EDRu::iptype_ipv6($i) !~ m/LOOPBACK/i));
            }
        }
    }
    return \@ips;
}

# Check if a package/patch require a reboot
sub is_pkg_require_reboot_sys {
    my ($padv,$sys,$pkg,$uninstall) = @_;
    my ($ppdir,$pp,$output);

    $pp = (ref($pkg)=~/^Pkg/m) ? $pkg->{pkg} : $pkg->{patch};
    if (!$uninstall) {
        return 0 unless ($pkg->{file});
        $ppdir=EDRu::dirname($pkg->{file});
        # do nothing if $ppdir is empty, ETrack #3135882
        return 0 unless ($ppdir);
        $output=($padv->localplat eq 'HPUX') ?
            EDR::cmd_local("_cmd_swlist -s $ppdir -a is_reboot -x verbose=0 $pp 2>/dev/null | _cmd_grep -v '^\#'") :
            EDR::cmd_local("_cmd_find $ppdir/catalog/$pp -name INDEX -exec _cmd_grep is_reboot \{\} \\; 2>/dev/null");
    } else {
        $output=$sys->cmd("_cmd_swlist -a is_reboot -x verbose=0 $pp 2>/dev/null | _cmd_grep -v '^\#'");
    }

    return 1 if ($output=~/true/m);
    return 0;
}

sub is_bonded_nic_sys {
    my ($padv,$sys,$nic) = @_;
    return 0;
}

sub islocal_sys {
    my ($padv,$sys) = @_;
    my ($ping,@nics,$nic,$ifc,$ip);
    $ping=EDR::cmd_local("/usr/sbin/ping $sys->{sys} -n 1 2>/dev/null | _cmd_grep bytes.from");
    (undef, $ip) = split(/from /m, $ping, 2);
    if ($ip=~m/(.*): icmp_seq/){
        $ip=$1;
        return 0 unless (EDRu::isip($ip));
        $nic=EDR::cmd_local('/usr/sbin/lanscan -i 2> /dev/null');
        @nics = split(/\s+/m, $nic);

        my $vir_nic=EDR::cmd_local('_cmd_netstat -in');
        my ($name,$mtu);
        for my $line(split(/\n/,$vir_nic)) {
            ($name,$mtu,undef,undef,undef,undef,undef,undef,undef)=split(/\s+/m,$line);
            if(EDRu::isnum($mtu) && !EDRu::inarr($name,@nics)){
                push(@nics,$name);
            }
        }

        for my $nic (@nics) {
            # Try IPv4 prior to IPv6
            $ifc=EDR::cmd_local("/usr/sbin/ifconfig $nic 2>/dev/null | _cmd_grep 'inet $ip '");
            $ifc=EDR::cmd_local("/usr/sbin/ifconfig $nic 2>/dev/null | _cmd_grep 'inet6 $ip '") if ($ifc eq '');
            return 1 if ($ifc);
        }
    }
    return 0;
}

sub load_driver_sys {
    my ($padv,$sys,$dr) = @_;
    $sys->cmd("_cmd_kcmodule $dr=loaded 2>/dev/null");
    return '';
}

# checks to see if a patch is in its correct location
# sets $patch->{file} to the filename if so
sub media_patch_file {
    my ($padv,$patch,$patchdir) = @_;
    if ($^O =~ /Win32/i) {
        for my $file ("$patchdir\\$patch->{patch}.depot",
                      "$patchdir\\$patch->{patch}") {
            return $file if (-e $file);
        }
    } else {
        for my $file ("$patchdir/$patch->{patch}.depot",
                      "$patchdir/$patch->{patch}") {
            return $file if (-e $file);
        }
    }
    $patch->{patch_vers}=$patch->{patch};
    return '';
}

sub media_patch_version {
    my ($padv,$patch,$patchdir) = @_;
    my ($vers,$rtn,$tmpdir,$index_file);
    $index_file="catalog/$patch->{patch}/pfiles/INDEX";
    if (-f "$patchdir/$index_file") {
        $vers=EDR::cmd_local("_cmd_grep '^revision ' $patchdir/$index_file 2>/dev/null");
    } elsif (-f "$patchdir/$patch->{patch}.depot") {
        if ($padv->localplat eq 'HPUX') {
            $rtn=EDR::cmd_local("_cmd_swlist -s $patchdir/$patch->{patch}.depot 2>/dev/null | _cmd_grep -v '^#' | _cmd_grep $patch->{patch} 2>/dev/null");
            for my $line (split(/\n+/, $rtn)) {
                if ($line=~/^\s*$patch->{patch}\s+(\S+)/mx) {
                    $vers=$1;
                    last;
                }
            }
        } else {
            $tmpdir=EDR::tmpdir();
            $vers=EDR::cmd_local("cd $tmpdir; _cmd_tar xf $patchdir/$patch->{patch}.depot $index_file; _cmd_grep '^revision ' $index_file 2>/dev/null");
        }
    }
    if (!$vers) {
        EDR::die("Cannot determine $patch->{patch} patch version on media");
    }
    # clean up
    $vers=~s/^revision\s*//mx;
    $vers=$padv->pkg_version_cleanup($vers);
    return $vers;
}

# checks to see if a package is in its correct location
# sets $pkg->{file} to the filename if so
sub media_pkg_file {
    my ($padv,$pkg,$pkgdir) = @_;
    return '' unless ($pkgdir);

    for my $file ("$pkgdir/$pkg->{pkg}.depot",
                  "$pkgdir/$pkg->{pkg}") {
        return $file if (-e $file);
    }

    my $file="$pkgdir/VRTSpkgs.depot";
    if (-e $file) {
        $pkg->{batchinstall}=1;
        return $file;
    }

    return '';
}

sub media_pkg_version {
    my ($padv,$pkg,$pkgdir) = @_;
    my ($vers,$pdfr,$rtn,$tmpdir,$index_file);
    $index_file="catalog/$pkg->{pkg}/pfiles/INDEX";
    if (-f "$pkgdir/$index_file") {
        $vers=EDR::cmd_local("_cmd_grep '^revision ' $pkgdir/$index_file 2>/dev/null");
    } elsif (-f "$pkgdir/$pkg->{pkg}/$index_file") {
        # To support single directory depot for NBU.
        $vers=EDR::cmd_local("_cmd_grep '^revision ' $pkgdir/$pkg->{pkg}/$index_file 2>/dev/null");
    } elsif (-f "$pkgdir/$pkg->{pkg}.depot") {
        if ($padv->localplat eq 'HPUX') {
            $rtn=EDR::cmd_local("_cmd_swlist -s $pkgdir/$pkg->{pkg}.depot 2>/dev/null | _cmd_grep -v '^#' | _cmd_grep $pkg->{pkg} 2>/dev/null");
            for my $line (split(/\n+/, $rtn)) {
                if ($line=~/^\s*$pkg->{pkg}\s+(\S+)/mx) {
                    $vers=$1;
                    last;
                }
            }
        } else {
            $tmpdir=EDR::tmpdir();
            $vers=EDR::cmd_local("cd $tmpdir; _cmd_tar xf $pkgdir/$pkg->{pkg}.depot $index_file; _cmd_grep '^revision ' $index_file 2>/dev/null");
        }
    }
    if (!$vers) {
        $pdfr=Msg::get('pdfr');
        EDR::die("Cannot determine $pkg->{pkg} $pdfr version on media");
    }
    # clean up
    $vers=~s/^revision\s*//mx;
    $vers=$padv->pkg_version_cleanup($vers);
    return $vers;
}

sub netmask_sys {
    my ($padv,$sys,$nic,$ipv,$ip) = @_;
    my ($alias,$nm);
    $ipv='4' unless ($ipv);
    if (($ipv eq '4') && ($sys->{ipv4})) {
        if ($ip) {
            $alias=$sys->cmd("_cmd_netstat -in 2>/dev/null | _cmd_awk '/$ip/ {print \$1}'");
            if ($alias) {
                $nm=$sys->cmd("_cmd_ifconfig $alias 2>/dev/null | _cmd_awk '/netmask/ {print \$4}'");
            } else {
                $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_awk '/netmask/ {print \$4}'");
            }
        } else {
            $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_awk '/netmask/ {print \$4}'");
        }
    } elsif (($ipv eq '6') && ($sys->{ipv6})) {
        if ($ip) {
            $alias=$sys->cmd("_cmd_netstat -in 2>/dev/null | _cmd_awk '/$ip/ {print \$1}'");
            if ($alias) {
                $nm=$sys->cmd("_cmd_ifconfig $alias 2>/dev/null | _cmd_awk '/inet6/ {print \$4}'");
            } else {
                $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_awk '/inet6/ {print \$4}'");
            }
        } else {
            $nm=$sys->cmd("_cmd_ifconfig $nic 2>/dev/null | _cmd_awk '/inet6/ {print \$4}'");
        }
    }
    return $nm;
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
    my ($padv,$sys,$nic) = @_;
    my (@aliases,@ips,@allips,$do,@ip_lines);
    $do=$sys->cmd("_cmd_netstat -in 2>/dev/null | _cmd_awk '/^${nic}[\t :]/ { print \$1 }'");
    @aliases=split(/\s+/m,$do);
    @allips=();
    for my $alias (@aliases) {
        $do=$sys->cmd("_cmd_ifconfig $alias 2>/dev/null | _cmd_awk '/inet / { print \$2 }'");
        @ips=split(/\s+/m,$do);
        $do=$sys->cmd("_cmd_ifconfig $alias 2>/dev/null | _cmd_awk '/inet6 / { print \$2}'");
        @ip_lines=split(/\s+/m,$do);
        for my $ip (@ip_lines) {
            if ( $ip =~/(.*)\//m ) {
                push (@ips,$1);
            } else {
                push (@ips,$ip);
            }
        }
        push (@allips,@ips);
    }
    return \@allips;
}

# Return speed of lan in bytes per second measure
sub nic_speed_sys {
    my ($padv,$sys,$nic) = @_;
    my ($speed,$ppa);
    $ppa=$nic;
    $ppa=~s/^lan//m;
    return 0 if ($ppa !~ m/^\d+$/);
    $speed=$sys->cmd("_cmd_lanadmin -s $ppa 2>/dev/null");
    chomp($speed);
    $speed=~s/^.*?(\d+)$/$1/m;
    if ( $speed && $speed > 1000000 ) {
        if ($speed > 1000000000) {
            $speed = $speed / 1000000000;
            $speed .= ' Gbps';
        } else {
            $speed = $speed / 1000000;
            $speed .= ' Mbps';
        }
    }
    return $speed;
}

# return 0 if patch is not installed or lower version is installed
# return 1 if equal or higher version is installed
sub ospatch_sys {
    my ($padv,$sys,$patchobj) = @_;
    my ($iv,$patch,$rv);
    # if the patch string in below formats:
    # "FSLibEnh r>=B.11.23.12"
    $patch=$patchobj->{patch_vers};
    if ($patch=~/^(\S+)\s+(\S.*)$/mx) {
        $patch=$1;
        $rv=$2;
        $iv=$sys->cmd("_cmd_swlist -l patch -a supersedes \'$patch,$rv\' 2> /dev/null | _cmd_grep $patch | _cmd_head -n1 2> /dev/null");
        return ($iv ? 1 : 0);
    }
    return 1 if (defined $sys->{patches} && EDRu::inarr($patch,@{$sys->{patches}}));

    $iv=$sys->cmd("_cmd_swlist -l patch -a supersedes -x verbose=0 2> /dev/null | _cmd_grep $patch | _cmd_head -n1 2> /dev/null");
    return ($iv ? 1 : 0);
}

sub installcommand_precheck_sys {
    my ($padv,$sys)= @_;
    my ($msg,$pids,$pidstr,$mnts,@fstab_mnts,@sys_mnts,@fstab_sys_mnts,@mounted_mnts,@umounted_mnts);

    $pids = $sys->proc_pids('/var/adm/sw/swagentd.log');
    if ($#$pids != -1) {
        # another swinstall instance is running which holds swagentd log file
        $pidstr=join(',',@$pids);
        $msg=Msg::new("Cannot lock / because another command holds a conflicting lock on $sys->{sys}. The process id of that command is $pidstr. Make sure only one instance of swinstall is running at any time on $sys->{sys}.");
        $sys->push_error($msg);
    }

    # Check if the system mount points defined in /etc/fstab are really mounted. if not, swinstall/swremove will not work correctly.
    $mnts=$sys->cmd("_cmd_grep -v '^#' /etc/fstab 2>/dev/null | _cmd_awk '{print \$2}'");
    @fstab_mnts=split(/\s+/m, $mnts);

    @sys_mnts=qw(/ /usr /var /opt /stand);
    @fstab_sys_mnts=();
    for my $mnt (@sys_mnts) {
        push(@fstab_sys_mnts, $mnt) if (EDRu::inarr($mnt, @fstab_mnts));
    }

    $mnts=$sys->cmd("_cmd_mount 2>/dev/null | _cmd_awk '{print \$1}'");
    @mounted_mnts=split(/\s+/m, $mnts);

    @umounted_mnts=();
    for my $mnt (@fstab_sys_mnts) {
        push(@umounted_mnts, $mnt) if (!EDRu::inarr($mnt, @mounted_mnts));
    }

    if (@umounted_mnts) {
        $mnts=join("', '",@umounted_mnts);
        $msg=Msg::new("The system mount points '$mnts' are not mounted on $sys->{sys}");
        $sys->push_error($msg);
    }

    return;
}

sub hostid_sys {
    my ($padv,$sys)= @_;
    my $value = $sys->cmd('_cmd_hostid 2>/dev/null');
    return sprintf('%lx', $value)
}

sub model_sys {
    my ($padv,$sys)= @_;
    return EDRu::despace($sys->cmd('_cmd_model 2>/dev/null'));
}

sub kerbit_sys {
    my ($padv,$sys)= @_;
    return $sys->cmd('/usr/bin/getconf KERNEL_BITS 2>/dev/null');
}

sub memory_size_sys {
    my ($padv,$sys)= @_;
    my ($memsize,$ret);

    $memsize=0;
    if ($sys->exists($padv->{cmd}{machinfo})) {
        # IA-64 architecture or 1131 PA
        $ret = $sys->cmd('_cmd_machinfo 2>/dev/null | _cmd_grep Memory');
        $memsize = $1 if ($ret =~ /Memory\s+=\s+(.*)\sMB\s(.*)/mx);
        $memsize = $1 if ($ret =~ /Memory:\s+(.*)\sMB\s(.*)/mx);
        $memsize = EDRu::despace($memsize) . 'MB';
    } else {
        # PA-RISC 1123 architecture
        if ($sys->exists($padv->{cmd}{print_manifest})) {
            $ret = $sys->cmd("_cmd_print_manifest 2>/dev/null | _cmd_grep 'Main Memory'");
            $memsize = $1 if ($ret =~ /Main Memory:\s+(.*)\sMB/m);
            $memsize = EDRu::despace($memsize) . 'MB';
        } elsif ($sys->exists($padv->{cmd}{cstm})) {
            $ret = $sys->cmd("echo 'selclass qualifier mem;info;wait;infolog' | _cmd_cstm 2>/dev/null | _cmd_grep  'System Total'");
            my @fields = split(/:/m, $ret);
            if (@fields > 1) {
                $memsize = EDRu::despace($fields[1]) . 'MB';
            }
        } else {
            # There is no cstm on HP 11.00
            $ret = $sys->cmd('dmesg 2>/dev/null');
            foreach my $line (split(/\n+/, $ret)) {
                if ($line =~ /Physical\s*:\s*(.*)/mx) {
                    $memsize = EDRu::despace($1);
                }
            }
        }
    }
    return $memsize;
}

sub minorversion_sys {
    my ($padv,$sys)=@_;
    my ($rtn,$plat,$fusionversion,$osversion);

    $fusionversion='';
    $rtn=$sys->cmd('_cmd_swlist -a software_spec -l bundle 2>/dev/null | _cmd_grep HPUX11i');
    if ($rtn=~/r=B\.(11\.\d+\.\d+)/mx){
        $fusionversion=$1;
    }

    if ($fusionversion) {
        $sys->set_value('fusionversion', $fusionversion);

        $plat = $sys->{plat};
        $osversion= "$plat B.$fusionversion";
        $sys->set_value('osversion', $osversion);
    }

    return 1;
}

sub patch_copy_sys {
    my ($padv,$sys,$patch) = @_;
    my ($patchdir,$tmpdir,$path,$localsys);
    $tmpdir=EDR::tmpdir();
    $path=$padv->installpath_sys($sys, $patch);
    $localsys=$padv->localsys;
    # copy the patch
    if ($path =~ /^$tmpdir/m) {
        unless ($sys->{depotregistered}) {
            $patchdir=EDRu::dirname($patch->{file});
            if (-d "$patchdir/catalog") {
                $localsys->copy_to_sys($sys,"$patchdir/catalog",$tmpdir);
                $sys->cmd("_cmd_swreg -l depot $path 2>/dev/null");
            }
            $sys->{depotregistered}=1;
        }

        $localsys->copy_to_sys($sys,$patch->{file},$tmpdir);
    }
    EDR::cmd_local('_cmd_touch '.$patch->copy_mark_sys($sys).' 2>/dev/null');
    return '';
}

sub patch_install_success_sys {
    my ($padv,$sys,$patch)= @_;
    my $io=EDRu::readfile(EDRu::outputfile('install', $sys->{sys}, "patch.$patch->{patch_vers}"));
    return 1 unless ($io=~/ERROR:/m);
    return 0;
}

sub patch_install_sys {
    my ($iof,$relocate,$padv,$patch,$pkg,$sys,$path,$opts);
    ($padv,$sys,$patch)=(@_);
    $path=$padv->installpath_sys($sys, $patch);
    $pkg=Obj::pkg($patch->{pkg},$patch->{padv});

    $opts =" -s $path -x autoreboot=true -x autoselect_patches=false -x mount_all_filesystems=false -x verbose=1";
    $opts.=' -x reinstall=true' if ((Cfg::opt('upgrade')) && ($pkg->{reinstall}));
    $opts.=' -x enforce_dependencies=false' if($patch->{nodeps});
    $opts.=" $patch->{iopt}" if ($patch->{iopt});
    $opts.=' -r '.Cfg::opt('rootpath') if (Cfg::opt('rootpath'));

    $relocate = ",l=$patch->{relocdir} " if ($patch->{relocdir});
    $iof=EDRu::outputfile('install', $sys->{sys}, "patch.$patch->{patch_vers}");
    $sys->cmd("_cmd_swinstall $opts $patch->{patch}$relocate 2>$iof 1>&2");
    return '';
}

# determine whether a patch is installed on a system
# each platform stores patch info a little differently
# assumes patch install status has been queried and stored in $sys
sub patch_installed_sys {
    my ($padv,$sys,$patch)= @_;
    return 1 if (defined $sys->{patches} && EDRu::inarr($patch->{patch_vers},@{$sys->{patches}}));
    return 0;
}

sub patch_remove_sys {
    my ($padv,$sys,$patch)= @_;
    my $tmpdir=EDR::tmpdir();
    my $path=$padv->installpath_sys($sys, $patch);
    if ($path =~ /^$tmpdir/m) {
        # if directory depot
        $path="$tmpdir/$patch->{patch}" if (-d $patch->{file});
        $sys->cmd("_cmd_rmr $path 2>/dev/null");
    }
    EDR::cmd_local('_cmd_rmr '.$patch->copy_mark_sys($sys).' 2>/dev/null');
    return '';
}

# Check if a patch is installed
# Return 1 if the patch is installed
sub patch_version_sys {
    my ($padv,$sys,$patch) = @_;
    my ($iv,$patchi);
    $patchi=$patch->{patch};
    $iv=$sys->cmd("_cmd_swlist -l product -a revision -x verbose=0 $patchi 2> /dev/null | _cmd_grep $patchi");
    if ($iv=~/\s*$patchi\s*(\S+)/) {
        $iv=$1;
    }
    return $iv;
}

sub pkg_has_rp_sys {
    my ($out,$padv,$pkgi,$sys,$pkg);
    ($padv,$sys,$pkg)=@_;
    $pkgi=$pkg->{pkg};
    $out=$sys->cmd("_cmd_swlist -l patch $pkgi 2> /dev/null | _cmd_grep -v '^#'");
    for my $p (split(/\n/,$out)) {
        return 1 if ($p=~/$pkgi/imx);
    }
    return 0;
}

sub patches_sys {
    my ($padv,$sys) = @_;
    my ($ospl,$testfile,$p,@patches);

    @patches=();
    unless ($sys->{patches}) {
        $testfile=$ENV{PATCHTESTFILE};
        $ospl=($testfile && -f $testfile) ? EDRu::readfile($testfile)
               : $sys->cmd("_cmd_swlist -l patch 2>/dev/null | _cmd_grep -v '^#'");
        for my $p (split(/\n/,$ospl)) {
            if ($p=~/^\s*([^\.]*)\..*/mx) {
                push(@patches,$1);
            }
        }
        $sys->set_value('patches','push',@patches) if (@patches);
    }
    return 0;
}

sub partially_installed_pkgs_sys {
    my ($padv,$sys)=@_;
    my $partial=$sys->cmd('_cmd_swlist -l fileset -a state 2>/dev/null | _cmd_grep -w corrupt | _cmd_cut -f 1 -d. | _cmd_sort | _cmd_uniq');
    for my $partial_pkg (split(/\n/,$partial)) {
        Msg::log("$partial_pkg is partially installed on $sys->{sys}");
        $sys->set_value("pkgpartial,$partial_pkg",1);
    }
    return '';
}

# ping a host, supports IPV4 and IPV6
# returns "" if successful, string if unsuccessful, opposite perl standard
# $sys can be a system name or IP and is scalar, not system object as ping_sys
sub ping {
    my ($padv,$sysip)= @_;
    my ($isip,$isipv4,$isipv6,$localsys);
    return '' if ($ENV{NOPING});
    $localsys=$padv->localsys;
    $isip=EDRu::isip($sysip);
    $isipv4=EDRu::ip_is_ipv4($sysip);
    $isipv6=EDRu::ip_is_ipv6($sysip);
    if (($localsys->{ipv4} && (!$isip)) || ($isipv4)) {
        EDR::cmd_local("_cmd_ping -f inet $sysip -n 3 2>/dev/null");
        return '' if (EDR::cmdexit() eq '0');
    }
    if (($localsys->{ipv6} && (!$isip)) || ($isipv6)) {
        EDR::cmd_local("_cmd_ping -f inet6 $sysip -n 3 2>/dev/null");
        return '' if (EDR::cmdexit() eq '0');
    }
    return 'noping';
}

# Get all instances for pkg
# For example, VRTSperl,r=5.8.8.4, VRTSperl,r=5.8.10.
sub pkg_allinstances_sys {
    my ($padv,$sys,$pkg)=@_;
    my ($pkgi,$pkgii,$pkgname,$allinstances,$versions);

    $pkgi=$pkg->{pkgi};
    $allinstances=$sys->{pkg_allinstances}{$pkgi};
    return $allinstances if (defined($allinstances));

    $allinstances=[];

    # check pkg's other instances, totally 10 instances
    $pkgname=$pkg->{pkg};
    $versions=$sys->{pkgverslist}{$pkgname};
    if (!defined $versions || $#$versions <= 0) {
        # only one package version installed
        push @{$allinstances}, $pkgi;
    } else {
        # multiple package versions installed
        for my $vers (reverse @$versions) {
            next unless $vers;
            $pkgii=$pkgname . ",r=" . $vers;
            push @{$allinstances}, $pkgii;
            $sys->set_value("pkgvers,'$pkgii'", $vers);
        }
    }

    $sys->set_value("pkg_allinstances,$pkgi", 'list', @{$allinstances});
    return $allinstances;
}

sub pkg_copy_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($pkgdir,$pkgi,$tmpdir,$path,$localsys,$catalog_path,$separator);
    $tmpdir=EDR::tmpdir();
    $path=$padv->installpath_sys($sys, $pkg);
    $localsys=$padv->localsys;
    # copy the package
    $separator=($^O =~ /Win32/i)?'\\':'/';
    if ($path =~ /^$tmpdir/m) {
        unless ($sys->{depotregistered}) {
            $pkgdir=EDRu::dirname($pkg->{file});
            $catalog_path=$pkgdir.$separator."catalog";
            if (-d "$catalog_path") {
                $localsys->copy_to_sys($sys,$catalog_path,$tmpdir);
                $sys->cmd("_cmd_swreg -l depot $path 2>/dev/null");
            }
            $sys->{depotregistered}=1;
        }

        if ($#{$pkg->{dependentpkgs}}>=0) {
            for my $pkgi (@{$pkg->{dependentpkgs}}) {
                $path="$tmpdir/".EDRu::basename($pkgi->{file});
                if (!$sys->exists("$path")) {
                    $localsys->copy_to_sys($sys,$pkgi->{file},$tmpdir)
                }
            }
        }
        $localsys->copy_to_sys($sys,$pkg->{file},$tmpdir);
    }

    if ($^O =~ /Win32/i){
        EDR::cmd_local('type nul>"'.$pkg->copy_mark_sys($sys).'" 2>nul');
    } else {
        EDR::cmd_local('_cmd_touch '.$pkg->copy_mark_sys($sys).' 2>/dev/null');
    }
    return '';
}

sub pkgs_install_sys {
    my ($padv,$sys,$archive,$pkgs)=@_;
    my ($rootpath,$iof,$opts);

    $opts='-x autoreboot=true -x autoselect_patches=false -x mount_all_filesystems=false -x verbose=1';
    $rootpath=Cfg::opt('rootpath');
    $opts.=" -r $rootpath" if ($rootpath);
    $iof=EDRu::outputfile('install', $sys->{sys}, 'pkgs');
    $sys->cmd("_cmd_swinstall -s $archive $opts $pkgs 2>$iof 1>&2");
    return 1;
}

sub pkgs_uninstall_sys {
    my ($padv,$sys,$pkgs) = @_;
    my ($opts,$uof);
    $opts='-x enforce_dependencies=false -x autoreboot=true -x mount_all_filesystems=false';
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, 'pkgs');
    $sys->cmd("_cmd_swremove $opts $pkgs 2>$uof 1>&2");
    return 1;
}

sub pkg_install_success_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($io,$iof,$logf,$iv,$rtn,$msg,$cmd);
    $iof=EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg});
    if ($pkg->{batchinstall}) {
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
        $logf=EDRu::outputfile('install', $sys->{sys}, 'pkgs');
        $io=EDRu::readfile($logf);
        EDRu::appendfile("Install logs\n$io\n$msg->{msg}", $iof);
    } else {
        $io=EDRu::readfile($iof);
        if ($io!~/ERROR/m && $io=~/Selection succeeded/m) {
            # successfully installed
            $rtn=1;
        } else {
            if ($io=~/command \"(swjob -a log .*)\"\./m) {
                $cmd='/usr/sbin/'.$1;
                $sys->cmd("echo '#######  Result of command: $cmd  #######' >> $iof; $cmd 2>>$iof 1>&2");
                $sys->copy_to_sys($padv->localsys,$iof) unless ($sys->{islocal});
                $io=EDRu::readfile($iof);
            }
            Msg::log("$pkg->{pkg} install failed on $sys->{sys}\n$io");
            $rtn=0;
        }
    }
    return $rtn;
}

sub pkg_install_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($relocate,$iof,$path,$opts);

    $path=$padv->installpath_sys($sys, $pkg);

    $opts =" -s $path -x autoreboot=true -x autoselect_patches=false -x mount_all_filesystems=false -x verbose=1";
    $opts.=' -x reinstall=true' if ((Cfg::opt('upgrade')) && ($pkg->{reinstall}));
    $opts.=' -x enforce_dependencies=false' if($pkg->{nodeps});
    $opts.=" $pkg->{iopt}" if($pkg->{iopt});
    $opts.=' -r '.Cfg::opt('rootpath') if (Cfg::opt('rootpath'));

    $relocate = ",l=$pkg->{relocdir} " if ($pkg->{relocdir});
    $iof=EDRu::outputfile('install', $sys->{sys}, $pkg->{pkg});
    $sys->cmd("_cmd_swinstall $opts $pkg->{pkg}$relocate 2>>$iof 1>&2");
    return '';
}

sub pkg_remove_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($pkgref,$flag,$tmpdir);
    my $path=$padv->installpath_sys($sys, $pkg);

    if ($^O =~ /Win32/i){
        my $localsys = EDR::get('localsys');
        my $localpadv = $localsys->padv();
        $localpadv->rm_sys($pkg->copy_mark_sys($sys));
    } else {
        EDR::cmd_local('_cmd_rmr '.$pkg->copy_mark_sys($sys).' 2>/dev/null');
    }
    # Not remove the temp pkg copy if it is a dependent pkg of other pkg
    # to save time for later use and important to keep co/prereq depot integrity
    $tmpdir=EDR::tmpdir();
    if ($path =~ /^$tmpdir/m) {
        $flag=1;
        for my $pkgi (@{$sys->{installpkgs}}) {
            $pkgref=$sys->pkg($pkgi);
            for my $pkgj (@{$pkgref->{dependentpkgs}}) {
                if ($pkg->{pkg} eq $pkgj->{pkg}) {
                    $flag=0;
                    last;
                }
            }
            last unless($flag);
        }
        $path="$tmpdir/$pkg->{pkg}" if (-d $pkg->{file});
        $sys->cmd("_cmd_rmr $path 2>/dev/null") if ($flag);
    }
    return '';
}

sub pkg_uninstall_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($opts,$uof);
    $opts='-x enforce_dependencies=false -x autoreboot=true -x mount_all_filesystems=false';
    $opts.=' -x enforce_scripts=false' if ($pkg->{force_uninstall});
    $opts.=" $pkg->{uopt}" if ($pkg->{uopt});
    $uof=EDRu::outputfile('uninstall', $sys->{sys}, $pkg->{pkg});
    $sys->cmd("_cmd_swremove $opts $pkg->{pkg} 2>$uof 1>&2");
    return '';
}

sub pkg_uninstall_success_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($iv,$uof,$uo,$logf,$rtn,$msg,$cmd);
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
    if (-f "$uof") {
        if ($iv) {
            $uo=EDRu::readfile($uof);
            if ($uo=~/command \"(swjob -a log .*)\"\./m) {
                $cmd=$1;
                $sys->cmd("echo '#######  Result of command: $cmd  #######' >> $uof; $cmd 2>>$uof 1>&2");
                $sys->copy_to_sys($padv->localsys,$uof) unless ($sys->{islocal});
            }
        }
    } elsif (-f "$logf") {
        $uo=EDRu::readfile($logf);
        EDRu::appendfile("Uninstall logs\n$uo", $uof);
    }
    EDRu::appendfile("\n$msg->{msg}", $uof);
    return $rtn;
}

sub patch_uninstall_sys {
    my ($padv,$sys,$patch)=(@_);
    my ($opts,$uof);
    $opts='-x enforce_dependencies=false -x autoreboot=true -x mount_all_filesystems=false';
    $opts.=' -x enforce_scripts=false' if ($patch->{force_uninstall});
    $opts.=" $patch->{uopt}" if ($patch->{uopt});
    $uof=EDRu::outputfile("uninstall", $sys->{sys}, "patch.$patch->{patch}");
    $sys->cmd("_cmd_swremove $opts $patch->{patch} 2>$uof 1>&2");
    return '';
}

sub patch_uninstall_success_sys {
    my ($padv,$sys,$patch)=(@_);
    my ($iv,$uof,$uo,$cmd);
    $iv=$padv->patch_version_sys($sys, $patch);
    $uof=EDRu::outputfile("uninstall", $sys->{sys}, "patch.$patch->{patch}");
    $uo=EDRu::readfile($uof);
    if ($iv) {
        if ($uo=~/command \"(swjob -a log .*)\"\./) {
            $cmd=$1;
            $sys->cmd("echo '#######  Result of command: $cmd  #######' >> $uof; $cmd 2>>$uof 1>&2");
            $sys->copy_to_sys($padv->localsys,$uof) unless ($sys->{islocal});
            $uo=EDRu::readfile($uof);
        }
        Msg::log("$patch->{patch} uninstall failed on $sys->{sys}\n$uo");
        return 0;
    }
    Msg::log("$patch->{patch} uninstall successfully on $sys->{sys}\n$uo");
    return 1;
}

sub pkg_description_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($str,$pkgi,$pkgname,$desc);
    $pkgi=$pkg->{pkg};
    $pkgname=$pkgi;
    $pkgname=~s/,.*$//;
    $str=$sys->cmd("_cmd_swlist -l product -a title -x verbose=0 $pkgi 2> /dev/null | _cmd_grep $pkgname");
    if ($str=~/\s*$pkgname\s*(.*)/mx) {
        $desc=$1;
        $desc=~s/^\"\s*//;
        $desc=~s/\s*\"\s*$//;
    }
    return $desc || '';
}

sub pkg_version_sys {
    my ($padv,$sys,$pkg,$prevpkgs_flag) = @_;
    my ($iv,$pkgname);
    # if $prevpkgs_flag=1, then do not check pkg's previous name.
    $prevpkgs_flag=1;
    for my $pkgi ($pkg->{pkg},@{$pkg->{previouspkgnames}}) {
        $pkgname=$pkgi;
        $pkgname=~s/,.*$//;
        $iv=$sys->cmd("_cmd_swlist -l product -a revision -x verbose=0 $pkgi 2> /dev/null | _cmd_grep $pkgname");
        if ($iv=~/\s*$pkgname\s*(\S+)/mx) {
            $iv=$1;
        }
        last if ($iv || $prevpkgs_flag);
    }
    return $padv->pkg_version_cleanup($iv);
}

sub pkg_installtime_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($str,$it);

    $it='';
    for my $pkgi ($pkg->{pkg},@{$pkg->{previouspkgnames}}) {
        $str=$sys->cmd("_cmd_grep install_date /var/adm/sw/products/$pkgi/pfiles/INDEX 2> /dev/null");
        if ($str =~ /install_date\s+(.*)/) {
            $it = $1;
            last;
        }
    }
    return $it;
}

sub pkg_version_cleanup {
    my ($padv,$vers)= @_;

    # clean up, CPIC 5.0 has way more, but...
    if ($vers) {
        $vers=~s/\.\D+.*$//m; # VRTSvxfs version is 5.1.1.0.%20091023
        $vers=~s/[a-zA-Z]//m; # VRTSddlpr version is b4.1, b5.0, Some pkg ver has 3.5m
        $vers=~s/^\.0//m;     # AVXTOOL version is B.05.00.01
    }
    return $vers;
}

sub pkg_requisite_deps_sys {
    my ($padv,$sys,$requisite,$opkg,$pkg) = @_;
    my ($deps,$ret,$pkgfile,$cmd,$depot,$npkg);

    $depot=$pkg->{file};
    $depot=~ s/\/$pkg->{pkg}$/\/catalog\/$pkg->{pkg}/mx;
    $ret=EDR::cmd_local("_cmd_find $depot -name INDEX -exec _cmd_grep $requisite \{\} \\; 2>/dev/null | _cmd_awk '{print \$2}' | _cmd_awk -F. '{print \$1}'");
    $ret=~s/^\s+//m;
    @{$deps}=split(/\n/,$ret);
    $deps=EDRu::arruniq(@{$deps});
    push(@{$opkg->{dependentpkgs}},$pkg) unless ($opkg->{pkg} eq $pkg->{pkg});

    for my $pkgi (@{$deps}) {
        # check the circular dependecy: 2-teer mutual dependecy
        next if (($pkg->{pkg} eq $pkgi) || ($opkg->{pkg} eq $pkgi));
        next unless ($pkgi =~ /^VRTS/m);
        # check the circular dependecy: tri-angular or more
        for my $pkgii (@{$opkg->{dependentpkgs}}) {
            return '' if ($pkgii->{pkg} eq $pkgi);
        }
        $npkg=Pkg::new_pkg('Pkg', $pkgi, $sys->{padv});
        $pkgfile=$pkg->{file};
        $pkgfile=~ s/\/$pkg->{pkg}$/\/$pkgi/mx;
        $npkg->{file}=$pkgfile;
        $padv->pkg_requisite_deps_sys($sys,'prerequisite',$opkg,$npkg);
        $padv->pkg_requisite_deps_sys($sys,'corequisite',$opkg,$npkg);
    }
    return;
}

sub pkg_deps_sys {
    my ($padv,$sys,@pkgs) = @_;
    my ($pkg);

    for my $pkgi (@pkgs) {
        $pkg=$sys->pkg($pkgi);
        @{$pkg->{dependentpkgs}}=();
        $padv->pkg_requisite_deps_sys($sys,'prerequisite',$pkg,$pkg);
        $padv->pkg_requisite_deps_sys($sys,'corequisite',$pkg,$pkg);
        $pkg->{dependentpkgs}=EDRu::arruniq(@{$pkg->{dependentpkgs}});
    }
    return;
}

sub process_args {
    if (Cfg::opt('patchpath')) {
        my $msg=Msg::new("-patchpath is the same as -pkgpath on HPUX.\nThis option is ignored.");
        $msg->print;
        Cfg::unset_opt('patchpath');
    }
    return;
}

# Determine the NICs on a system which has IP addresses configured
# Return a reference to an array holding the NICs
sub publicnics_sys {
    my ($padv,$sys) = @_;
    my (@pnics,$do);
    $do=$sys->cmd("_cmd_netstat -i 2>/dev/null | _cmd_grep '^lan' | _cmd_sed 's/:.*\$//' | _cmd_awk '{print \$1}' | _cmd_uniq");
    @pnics=split(/\s+/m,$do);
    return \@pnics;
}

sub swap_size_sys {
    my ($padv, $sys)= @_;

    my $ret = $sys->cmd('_cmd_swapinfo -t | _cmd_grep total 2>/dev/null');
    if ($ret =~ /total\s+\S+\s+\S+\s+(\S+)\s+/mx) {
        return "$1".'k';
    }
    return '';
}

sub bondednics_sys {
    my ($padv,$sys)=@_;
    my (@slavenics,@bondednics);
    return (\@bondednics,\@slavenics);
}


# Determine all NICs on a system
# Returns a reference to an array holding the NICs
sub systemnics_sys {
    my ($padv,$sys) = @_;
    my (@nics,$do);
    $do=$sys->cmd("_cmd_lanscan 2>/dev/null | _cmd_grep lan | _cmd_grep -v \' 0x000000000000 \' | _cmd_awk '{print \$5}' | _cmd_sort 2> /dev/null");
    @nics=split(/\s+/m,$do);
    return \@nics;
}

sub unload_driver_sys {
    my ($padv,$sys,$dr) = @_;
    $sys->cmd("_cmd_kcmodule $dr=unused 2>/dev/null");
    return 1;
}

sub detect_hpux_vpar_sys {
    my ($padv, $sys) = @_;

    #TODO: Do not have VPAR environment now
    return;
}

sub detect_hpux_ivm_sys {
    my ($padv, $sys) = @_;

    my $out = $sys->cmd("_cmd_hpvminfo 2>/dev/null");
    if($out =~/\S/){
        chomp($out);
        $sys->{virtual_detail} = $out;
        if ($out =~ /Running inside an HPVM guest/i) {
            $sys->{virtual_type} = $padv->VIRT_IVM;
        }
    }
    return 1;
}

# determine a systems virtualization status
sub virtualization_sys {
    my ($padv, $sys) = @_;

    $padv->detect_hpux_vpar_sys($sys);
    $padv->detect_hpux_ivm_sys($sys)if(!$sys->{virtual_type});
    $sys->set_value('virtual_type', $sys->{virtual_type}) if($sys->{virtual_type});
    $sys->set_value('virtual_detail', $sys->{virtual_detail}) if($sys->{virtual_detail});
    return 1;
}

sub vrtspkgversdeps_script {
    my $script=<<'VPVD';
#!/usr/bin/sh

/usr/sbin/swlist -arevision -aprerequisites -acorequisites 'VRTS*' 'SYMC*' 2>/dev/null | /usr/bin/awk '
    BEGIN {
        n = 0
    }
    /^# (VRTS|SYMC)/ {
        pkg = $2
        ver = $3
        n++
        PKG[n] = pkg
        VER[n] = ver
        DEP[n] = ""
        REQ[n] = ""
    }
    /^[ \t]+(VRTS|SYMC)/ {
        for ( i = 3; i <= NF; i++ ) {
            split( $i, a, "." )
            req = a[1]
            if ( req ~ /^(VRTS|SYMC)/ &&
                 pkg != req && ! match(REQ[n], req) ) {
                 REQ[n] = REQ[n] ":" req
            }
        }
    }
    END {
        for ( i = 1; i <= n; i++ ) {
            f = split(REQ[i], b, ":")
            for ( x = 2; x <= f; x++ ) {
                for ( y = 1; y <= n; y++ ) {
                    if ( b[x] == PKG[y] ) {
                        DEP[y] = DEP[y] "" PKG[i] " "
                    }
                }
            }
        }
        for ( i = 1; i <= n; i++ ) {
            printf "%s %s %s\n",PKG[i],VER[i],DEP[i]
        }
    }
    '
VPVD
    return $script;
}

# check whether $file on $sys was modified after the package who owns $file was installed
sub file_modified_sys {
    my ($padv,$sys,$file)=@_;
    my ($cmdout,@fields,$package,$jobid);
    $cmdout = '';
    $package = '';
    $jobid = '';
    if ($file) {
        $cmdout = $sys->cmd("_cmd_swlist -l file 2>/dev/null | _cmd_grep '$file'");
        for my $line (split(/\n/, $cmdout)) {
            $line =~ s/^\s*//mx;
            @fields = split(/\s/, $line);
            if ( $fields[1] eq $file) {
                $package = $fields[0];
                $package =~ s/:$//;
                last;
            }
        }
        if ($package) {
            $cmdout = $sys->cmd("_cmd_swverify -x check_volatile=true -x autoselect_dependencies=false -x check_contents=true -x check_contents_use_cksum=true $package 2>&1 | _cmd_grep '^[ \t]*(jobid='");
            if ($cmdout =~ /^\s*\(jobid=([^)]*)\)\s*$/mx) {
                $jobid = $1;
                if ($jobid) {
                    $cmdout = $sys->cmd("_cmd_swjob -a log $jobid \@ /");
                    if ( $cmdout =~ /"$file"\s+should\s+have\s+cksum\s+/mx || $cmdout =~ /"$file"\s+should\s+have\s+size\s+/mx ) {
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}

# return value: 0 - verify ok; 1 - otherwise
sub pkg_verify_sys {
    my ($padv,$sys,$pkgname)=@_;
    return 1 if (!$pkgname);
    my $rtn=$sys->cmd("_cmd_swverify -x check_volatile=false -x autoselect_dependencies=false -x check_contents=true -x check_contents_use_cksum=true -x mount_all_filesystems=false $pkgname");
    my $msg=Msg::new("'swverify $pkgname' on $sys->{sys} return:\n$rtn");
    $sys->set_value("pkg_verify,$pkgname", $msg->{msg});
    return EDR::cmdexit();
}

sub configure_static_ip_sys {
    my ($padv,$sys,$nic,$ip,$mask) = @_;
    my ($nicfile,$nicfilebk,$nic_ip_conf,$output,$nic_exist,$max_id,$nic_id,$nic_name);

    $nicfile = "/etc/rc.config.d/netconf";
    if ($sys->exists($nicfile)) {
        $nicfilebk = $nicfile . '.bak';
        Msg::log("Backing up $nicfile file as $nicfilebk");
        $sys->copyfile($nicfile, $nicfilebk);
    }
    $output=$sys->cmd("_cmd_grep '^ *INTERFACE_NAME' $nicfile 2>/dev/null");

    $nic_exist=undef;
    $max_id=-1;
    my $alias_id=0;
    my $max_alias_id=0;

    for my $line (split(/\n/,$output)) {
        if ($line=~/\[(\d+)\]\s*=\s*(['"])(\S+)\2/mx) {
            my $idx=$1;
            my $interface=$3;

            $max_id=$idx if ($idx > $max_id);
            $nic_exist=1 if ($interface =~ /$nic(\S*)/);
            if ($interface =~ /$nic:(\d+)/mx) {
                $alias_id = $1;
                $max_alias_id = $alias_id if ($alias_id>$max_alias_id);
            }
        }
    }

    if ($nic_exist) {
        # the $nic is defined in NIC config file,
        # add alias
        my $new_alias_id = $max_alias_id + 1;
        $nic_name="$nic:$new_alias_id";
    } else {
        # the $nic is not defined in NIC config file,
        # append new configuration
        $nic_name = $nic;
    }

    $nic_id=$max_id+1;
    $nic_ip_conf =<< "_NIC_IP_CONF_";
INTERFACE_NAME[$nic_id]="$nic_name"
IP_ADDRESS[$nic_id]="$ip"
SUBNET_MASK[$nic_id]="$mask"
BROADCAST_ADDRESS[$nic_id]=""
INTERFACE_STATE[$nic_id]="up"
DHCP_ENABLE[$nic_id]="0"
INTERFACE_MODULES[$nic_id]=""
_NIC_IP_CONF_

    $sys->cmd("_cmd_ifconfig $nic_name $ip netmask $mask up 2>/dev/null");
    return 0 if (EDR::cmdexit());

    $sys->appendfile($nic_ip_conf,$nicfile);

    return 1;
}

package Padv::HPUX1111par;
@Padv::HPUX1111par::ISA = qw(Padv::HPUX);

sub init_padv {
    my $padv=shift;
    $padv->{arch}='9000/800';
    $padv->{vers}='B.11.11';
    $padv->{name}='HP-UX 11.11';
    return;
}

package Padv::HPUX1123par;
@Padv::HPUX1123par::ISA = qw(Padv::HPUX);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='B.11.23';
    $padv->{name}='HP-UX 11.23';
    $padv->{arch}='9000/800';
    return;
}

package Padv::HPUX1131par;
@Padv::HPUX1131par::ISA = qw(Padv::HPUX);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='B.11.31';
    $padv->{name}='HP-UX 11.31';
    $padv->{arch}='9000/800';
    return;
}

package Padv::HPUX1131ia64;
@Padv::HPUX1131ia64::ISA = qw(Padv::HPUX);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='B.11.31';
    $padv->{name}='HP-UX 11.31';
    $padv->{arch}='ia64';
    return;
}

package Padv::HPUX1123ia64;
@Padv::HPUX1123ia64::ISA = qw(Padv::HPUX);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='B.11.23';
    $padv->{name}='HP-UX 11.23';
    $padv->{arch}='ia64';
    return;
}

package Padv::HPUX1111ia64;
@Padv::HPUX1111ia64::ISA = qw(Padv::HPUX);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='B.11.11';
    $padv->{name}='HP-UX 11.11';
    $padv->{arch}='ia64';
    return;
}

1;
