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

package Pkg::VRTSvcsea61::Common;
@Pkg::VRTSvcsea61::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcsea';
    $pkg->{name}=Msg::new("Cluster Server Enterprise Agents")->{msg};
    $pkg->{extra_types} = ['/etc/VRTSagents/ha/conf/Oracle/OracleTypes.cf',
                    '/etc/VRTSagents/ha/conf/OracleASM/OracleASMTypes.cf',
                    '/etc/VRTSagents/ha/conf/Db2udb/Db2udbTypes.cf',
                    '/etc/VRTSagents/ha/conf/Sybase/SybaseTypes.cf'
                    ];
    #$pkg->{stopprocs}=[ qw(vcsmm61 lmx61) ];
    #$pkg->{startprocs}=[ qw(vcsmm61 lmx61) ];
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcsea61::AIX;
@Pkg::VRTSvcsea61::AIX::ISA = qw(Pkg::VRTSvcsea61::Common);

package Pkg::VRTSvcsea61::HPUX;
@Pkg::VRTSvcsea61::HPUX::ISA = qw(Pkg::VRTSvcsea61::Common);

package Pkg::VRTSvcsea61::Linux;
@Pkg::VRTSvcsea61::Linux::ISA = qw(Pkg::VRTSvcsea61::Common);

package Pkg::VRTSvcsea61::SunOS;
@Pkg::VRTSvcsea61::SunOS::ISA = qw(Pkg::VRTSvcsea61::Common);

sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($rootpath,$vers);

    $rootpath=Cfg::opt('rootpath')||'';
    $vers = $pkg->version_sys($sys);
    # Remove VRTSvcsea preremove scripts on ABE during Live Upgrade.
    if (Cfg::opt('upgrade') && $rootpath
        && (EDRu::compvers($vers,'6.0')==2)) {
        $sys->rm("$rootpath/var/sadm/pkg/$pkg->{pkg}/install/preremove");
    }
    return;
}

1;
