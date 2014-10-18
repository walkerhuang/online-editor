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

package Pkg::SYMCsnas60::Common;
@Pkg::SYMCsnas60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='SYMCsnas';
    $pkg->{name}=Msg::new("Symantec Storage: NAS")->{msg};
    $pkg->{unkernelpkg}=1;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::SYMCsnas60::AIX;
@Pkg::SYMCsnas60::AIX::ISA = qw(Pkg::SYMCsnas60::Common);

package Pkg::SYMCsnas60::HPUX;
@Pkg::SYMCsnas60::HPUX::ISA = qw(Pkg::SYMCsnas60::Common);

package Pkg::SYMCsnas60::Linux;
@Pkg::SYMCsnas60::Linux::ISA = qw(Pkg::SYMCsnas60::Common);

sub init_plat {
    my $pkg = shift;
    $pkg->{thirdpartypkgs}{all}=['ctdb 2.5.3', 'perl-Template-Toolkit 2.20', 'perl-Template-Extract 0.41','perl-AppConfig 1.66', 'perl-File-HomeDir 0.66', 'perl-JSON 2.51', 'samba-client 3.6.24', 'samba-common 3.6.24', 'samba-winbind 3.6.24', 'samba 3.6.24', 'samba-winbind-clients 3.6.24', 'samba-winbind-krb5-locator 3.6.24','libsmbclient 3.6.24', 'libnet 1.1.6','kernel-debuginfo 2.6.32', 'kernel-debuginfo-common-x86_64 2.6.32', 'initscripts 9.03.40-2.el6_5.4'];
    $pkg->{ospkgs}{all}=['perl 5.10.0', 'perl-Net-Telnet 3.03', 'nc 1.84', 'net-snmp 5.5', 'net-snmp-utils 5.5', 'net-snmp-libs 5.5', 'samba4-libs 4.0.0', 'tdb-tools 1.2.10', 'openldap 2.4.23', 'openldap-clients 2.4.23', 'nss-pam-ldapd 0.7.5', 'rrdtool 1.3.8', 'parted 2.1', 'wireshark 1.8.10', 'vsftpd 2.2.2', 'openssl 1.0.1e', 'iscsi-initiator-utils 6.2.0.873', 'lsscsi 0.23', 'libpcap 1.4.0'];
}

package Pkg::SYMCsnas60::SunOS;
@Pkg::SYMCsnas60::SunOS::ISA = qw(Pkg::SYMCsnas60::Common);

1;
