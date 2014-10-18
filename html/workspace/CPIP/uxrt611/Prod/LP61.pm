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

package Prod::LP61::Common;
@Prod::LP61::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{prod}='LP';
    $prod->{abbr}=Msg::new("LP")->{msg};
    $prod->{vers}='6.1.1.000';
    $prod->{name}=Msg::new("Symantec Language Pack")->{msg};
    $prod->{nolic}=1;
    $prod->{nocpionsys}=1;
    $prod->{lp}=1;
    return;
}

sub description {
    my ($msg);

    $msg=Msg::new("Symantec Language Pack Installer adds language packages for the installed Symantec Products");
    $msg->print;
    return;
}

sub licensed_sys {
    return 1;
}

package Prod::LP61::SunOS;
@Prod::LP61::SunOS::ISA = qw(Prod::LP61::Common);

package Prod::LP61::SolSparc;
@Prod::LP61::SolSparc::ISA = qw(Prod::LP61::SunOS);

sub init_padv {
    my $prod=shift;

    # detecting Japanese locale
    my $envlang=EDR::get('envlang');
    if ($envlang=~/ja/m) {
        $prod->{lang}='ja';
    # detecting Chinese (zh, zh.*, zh_CN.*)
    } elsif ($envlang=~/zh/m) {
        # detecting Other Chinese locale and delete them (zh_HK*, zh_TW*)
        if ($envlang=~/(^zh$|zh\.|zh_CN)/mx) {
            $prod->{lang}='zh';
        } else {
            $prod->{lang}='';
        }
    } else {
        $prod->{lang}='';
    }

    # list all language pkgs to initialize
    $prod->{allpkgs} = [ qw(VRTSmulic32 VRTSjacav60 VRTSjacs60 VRTSjacse60 VRTSjacsu60 VRTSjadba60 VRTSjafs60 VRTSjavm60 VRTSjadbe60 VRTSjaodm61 VRTSzhvm60) ];

    $prod->{obsoleted_previous_releases_pkgs}=[ qw(
        SYMCjalma SYMCzhlma VRTSatJA VRTSatZH VRTSjaap
        VRTSjacav60 VRTSjacfd VRTSjacmc VRTSjacs60 VRTSjacsb
        VRTSjacsd VRTSjacse60 VRTSjacsi VRTSjacsj VRTSjacsm
        VRTSjacso VRTSjacsp VRTSjacss VRTSjacsu60 VRTSjacsw
        VRTSjad2d VRTSjad2g VRTSjadb2 VRTSjadba60 VRTSjadbc
        VRTSjadbd VRTSjadbe60 VRTSjadcm VRTSjafad VRTSjafag
        VRTSjafas VRTSjafs60 VRTSjafsc VRTSjafsd VRTSjafsm
        VRTSjagap VRTSjaico VRTSjamcm VRTSjampr VRTSjamsa
        VRTSjaodm61 VRTSjaord VRTSjaorg VRTSjaorm VRTSjapbx
        VRTSjasmf VRTSjaspq VRTSjasqd VRTSjasqm VRTSjavm60
        VRTSjavmc VRTSjavmd VRTSjavmm VRTSjavrd VRTSjavvr
        VRTSjaweb VRTSmualc VRTSmuap VRTSmuc33 VRTSmucsd
        VRTSmudcp VRTSmuddl VRTSmufp VRTSmufsp VRTSmufsw
        VRTSmulic32 VRTSmuob VRTSmuobg VRTSmuobw VRTSmusfm
        VRTSmutep VRTSmuvmp VRTSmuvmw VRTSzhico VRTSzhpbx
        VRTSzhsmf VRTSzhvm60 VRTSzhvmc VRTSzhvmd VRTSzhvmm
    ) ];
    return;
}

sub getlangpkg {
    my $prod=shift;

    # assign language pkgs
    if ($prod->{lang} eq 'ja') {
        $prod->{allpkgs} = [ qw(VRTSmulic32 VRTSjacav60 VRTSjacs60 VRTSjacse60 VRTSjacsu60 VRTSjadba60 VRTSjafs60 VRTSjavm60 VRTSjadbe60 VRTSjaodm61) ];
    } elsif ($prod->{lang} eq 'zh') {
        $prod->{allpkgs} = [ qw(VRTSmulic32 VRTSzhvm60) ];
    } else {
        $prod->{allpkgs} = [ qw(VRTSmulic32) ];
    }

    return [ @{$prod->{allpkgs}} ];
}

1;
