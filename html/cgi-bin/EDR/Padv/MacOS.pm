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
package Padv::MacOS;
use strict;
@Padv::MacOS::ISA = qw(Padv);

sub padvs { return [ qw(MacOS105  MacOS106 ) ]; }

sub init_plat {
    my ($padv) = @_;

    Cfg::set_opt("serial");
    $padv->{plat}='Mac OS X';
    $padv->{name}='Mac OS X';
    $padv->{pkgpath}='pkgs';
    $padv->{patchpath}='patches';

    # Define common commands
    $padv->{cmd}{awk}='/usr/bin/awk';
    $padv->{cmd}{cat}='/bin/cat';
    $padv->{cmd}{chmod}='/bin/chmod';
    $padv->{cmd}{chown}='/usr/sbin/chown';
    $padv->{cmd}{chgrp}='/usr/bin/chgrp';
    $padv->{cmd}{cp}='/bin/cp';
    $padv->{cmd}{cut}='/usr/bin/cut';
    $padv->{cmd}{date}='/usr/bin/date';
    $padv->{cmd}{dd}='/bin/dd';
    $padv->{cmd}{dfk}='/bin/df -kt';
    $padv->{cmd}{diff}='/usr/bin/diff';
    $padv->{cmd}{dirname}='/usr/bin/dirname';
    $padv->{cmd}{du}='/usr/bin/du';
    $padv->{cmd}{echo}='/bin/echo';
    $padv->{cmd}{egrep}='/usr/bin/egrep';
    $padv->{cmd}{find}='/usr/bin/find';
    $padv->{cmd}{getconf}='/usr/bin/getconf';
    $padv->{cmd}{grep}='/usr/bin/grep';
    #$padv->{cmd}{groupadd}="/usr/bin/dscl -options?";
    #$padv->{cmd}{groupdel}="/usr/bin/dscl -options?";
    $padv->{cmd}{groups}='/usr/bin/groups';
    $padv->{cmd}{gunzip}='/usr/bin/gunzip';
    $padv->{cmd}{head}='/usr/bin/head';
    #$padv->{cmd}{hostid}="/usr/bin/hostid, not what is the equiv?";
    $padv->{cmd}{hostname}='/bin/hostname';
    $padv->{cmd}{id}='/usr/bin/id';
    $padv->{cmd}{ifconfig}='/sbin/ifconfig';
    $padv->{cmd}{kill}='/bin/kill';
    $padv->{cmd}{ln}='/bin/ln';
    $padv->{cmd}{ls}='/bin/ls';
    $padv->{cmd}{mkdir}='/bin/mkdir';
    $padv->{cmd}{mkdirp}='/bin/mkdir -p';
    $padv->{cmd}{mount}='/sbin/mount';
    $padv->{cmd}{mv}='/bin/mv';
    $padv->{cmd}{netstat}='/usr/sbin/netstat';
    #$padv->{cmd}{nm}="/usr/bin/nm, not what is the equiv?";
    $padv->{cmd}{nslookup}='/usr/bin/nslookup';
    $padv->{cmd}{ping}='/sbin/ping';
    $padv->{cmd}{ps}='/bin/ps';
    $padv->{cmd}{rcp}='/bin/rcp';
    $padv->{cmd}{rm}='/bin/rm';
    $padv->{cmd}{rmr}='/bin/rm -rf';
    $padv->{cmd}{rmdir}='/bin/rm -rf';
    $padv->{cmd}{rsh}='/usr/bin/rsh';
    $padv->{cmd}{scp}='/usr/bin/scp';
    $padv->{cmd}{sed}='/usr/bin/sed';
    $padv->{cmd}{sh}='/bin/sh';
    $padv->{cmd}{shutdown}='/sbin/shutdown -r';
    $padv->{cmd}{sleep}='/bin/sleep';
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
    #$padv->{cmd}{vxkeyless}="/opt/VRTSvlic/bin/vxkeyless";
    #$padv->{cmd}{vxlicrep}="/sbin/vxlicrep";
    #$padv->{cmd}{vxlicinst}="/sbin/vxlicinst";
    $padv->{cmd}{wc}='/usr/bin/wc';
    $padv->{cmd}{which}='/usr/bin/which';

    # Define Mac OS X specific commands
    $padv->{cmd}{installer}='/usr/sbin/installer';
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
    return $sys->cmd("/usr/sbin/system_profiler -detailLevel -2 | /usr/bin/grep System.Version: | /usr/bin/awk '{print \$7}'");
}

sub padv_sys {
    my($padv,$sys)=@_;
    my ($major,$minor,undef)=split(/\./m, $sys->{platvers}, 3);
    #return "MacOS$major$minor$sys->{arch}";
    return "MacOS$major$minor";
}

sub fqdn_ip_sys {
    my ($padv,$sys)=@_;
    my ($fqdn,$nslookup,$line,$ip);
    $nslookup=EDR::cmd_local("/usr/bin/nslookup $sys->{sys}");
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

# from SunOS.pm, still need to validate on MacOS
sub ipv6_sys {
    my ($padv,$sys)=@_;
    my $ifc6=$sys->cmd("/usr/sbin/ifconfig -a inet6 2>/dev/null | /usr/bin/grep -v 'inet6 ::' | /usr/bin/grep 'inet6 .*/'");
    return ($ifc6 =~ m/inet6 .*\/\d+/) ? 1 : 0;
}

# DONE with info_sys routines that require full command paths

# other subs here

sub kerbit_sys {
    my ( $padv, $sys ) = @_;
    # Will implement it later
    return '32';
}

sub media_pkg_file {
    my ($padv,$pkg,$pkgdir) = @_;
    return '' unless ($pkgdir);
    for my $file ("$pkgdir/$pkg->{pkg}.tar.gz") {
                  #"$pkgdir/$pkg->{pkg}.pkg",
                  #"$pkgdir/$pkg->{pkg}") {
        return $file if (-e $file);
    }
    return '';
}

sub pkgs_patches_sys {
    my ($padv,$sys) = @_;
    #EDR::die("MacOS pkgs_patches_sys for tarfiles has not been implemented");
    return;
}

sub pkg_copy_sys {
    my $padv=shift;
    $padv->tar_install_sys(@_);
    return;
}

# still to solve
sub memory_size_sys { return 1024; }
sub swap_size_sys { return 1024; }

# no native packages hack for now
# searches known version files
# does not report dependencies
# NetBackup specific too, how should this be made generic or overridden?
sub vrtspkgversdeps_script {
    my $script=<<"VPVD";
#!/bin/sh

if [ -f "/opt/VRTSpbx/build_version" ]; then
    PBX_VERS=`cat /opt/VRTSpbx/build_version | sed 's/^.*-//'`
    echo VRTSpbx \$PBX_VERS
    /bin/rm /tmp/VRTSpbx_version
fi
if [ -f "/usr/openv/netbackup/bin/version" ]; then
    NBC_VERS=`cat /usr/openv/netbackup/bin/version | awk '{print \$2}'`
    echo SYMCnbclt \$NBC_VERS
fi
# NetBackup Server check too
VPVD
    return $script;
}

# all MacOS padvs operate the same way
package Padv::MacOS105;
@Padv::MacOS105::ISA = qw(Padv::MacOS);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='10.5';
    return;
}

package Padv::MacOS106;
@Padv::MacOS106::ISA = qw(Padv::MacOS);

sub init_padv {
    my $padv=shift;
    $padv->{vers}='10.6';
    return;
}

1;
