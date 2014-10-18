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

# common
package Pkg::VRTSmulic32::Common;
@Pkg::VRTSmulic32::Common::ISA = qw(Pkg);

package Pkg::VRTSjacav60::Common;
@Pkg::VRTSjacav60::Common::ISA = qw(Pkg);

package Pkg::VRTSjacs60::Common;
@Pkg::VRTSjacs60::Common::ISA = qw(Pkg);

package Pkg::VRTSjacse60::Common;
@Pkg::VRTSjacse60::Common::ISA = qw(Pkg);

package Pkg::VRTSjacsu60::Common;
@Pkg::VRTSjacsu60::Common::ISA = qw(Pkg);

package Pkg::VRTSjadba60::Common;
@Pkg::VRTSjadba60::Common::ISA = qw(Pkg);

package Pkg::VRTSjafs60::Common;
@Pkg::VRTSjafs60::Common::ISA = qw(Pkg);

package Pkg::VRTSjavm60::Common;
@Pkg::VRTSjavm60::Common::ISA = qw(Pkg);

package Pkg::VRTSzhvm60::Common;
@Pkg::VRTSzhvm60::Common::ISA = qw(Pkg);

package Pkg::VRTSjadbe60::Common;
@Pkg::VRTSjadbe60::Common::ISA = qw(Pkg);

package Pkg::VRTSjaodm60::Common;
@Pkg::VRTSjaodm60::Common::ISA = qw(Pkg);

# SunOS
package Pkg::VRTSmulic32::SunOS;
@Pkg::VRTSmulic32::SunOS::ISA = qw(Pkg::VRTSmulic32::Common);

package Pkg::VRTSjacav60::SunOS;
@Pkg::VRTSjacav60::SunOS::ISA = qw(Pkg::VRTSjacav60::Common);

package Pkg::VRTSjacs60::SunOS;
@Pkg::VRTSjacs60::SunOS::ISA = qw(Pkg::VRTSjacs60::Common);

package Pkg::VRTSjacse60::SunOS;
@Pkg::VRTSjacse60::SunOS::ISA = qw(Pkg::VRTSjacse60::Common);

package Pkg::VRTSjacsu60::SunOS;
@Pkg::VRTSjacsu60::SunOS::ISA = qw(Pkg::VRTSjacsu60::Common);

package Pkg::VRTSjadba60::SunOS;
@Pkg::VRTSjadba60::SunOS::ISA = qw(Pkg::VRTSjadba60::Common);

package Pkg::VRTSjafs60::SunOS;
@Pkg::VRTSjafs60::SunOS::ISA = qw(Pkg::VRTSjafs60::Common);

package Pkg::VRTSjavm60::SunOS;
@Pkg::VRTSjavm60::SunOS::ISA = qw(Pkg::VRTSjavm60::Common);

package Pkg::VRTSzhvm60::SunOS;
@Pkg::VRTSzhvm60::SunOS::ISA = qw(Pkg::VRTSzhvm60::Common);

package Pkg::VRTSjadbe60::SunOS;
@Pkg::VRTSjadbe60::SunOS::ISA = qw(Pkg::VRTSjadbe60::Common);

package Pkg::VRTSjaodm60::SunOS;
@Pkg::VRTSjaodm60::SunOS::ISA = qw(Pkg::VRTSjaodm60::Common);

#
# SolSparc
#
# VRTSmulic32
package Pkg::VRTSmulic32::SolSparc;
@Pkg::VRTSmulic32::SolSparc::ISA = qw(Pkg::VRTSmulic32::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSmulic';
    $pkg->{basepkg}='VRTSvlic';
    $pkg->{name}=Msg::new("Multi Language Symantec License Utilities")->{msg};
    return;
}

# VRTSjacav60
package Pkg::VRTSjacav60::SolSparc;
@Pkg::VRTSjacav60::SolSparc::ISA = qw(Pkg::VRTSjacav60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjacav';
    $pkg->{basepkg}='VRTScavf';
    $pkg->{name}=Msg::new("Japanese VCS Agents for SFCFS Language Kit")->{msg};
    return;
}

# VRTSjacs60
package Pkg::VRTSjacs60::SolSparc;
@Pkg::VRTSjacs60::SolSparc::ISA = qw(Pkg::VRTSjacs60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjacs';
    $pkg->{basepkg}='VRTSvcs';
    $pkg->{name}=Msg::new("Japanese VCS Language Kit")->{msg};
    return;
}

# VRTSjacse60
package Pkg::VRTSjacse60::SolSparc;
@Pkg::VRTSjacse60::SolSparc::ISA = qw(Pkg::VRTSjacse60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjacse';
    $pkg->{basepkg}='VRTSvcsea';
    $pkg->{name}=Msg::new("Japanese VCS Enterprise Agents Language Kit")->{msg};
    return;
}

# VRTSjacsu60
package Pkg::VRTSjacsu60::SolSparc;
@Pkg::VRTSjacsu60::SolSparc::ISA = qw(Pkg::VRTSjacsu60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjacsu';
    $pkg->{basepkg}='VRTScutil';
    $pkg->{name}=Msg::new("Japanese VCS Utility Language Kit")->{msg};
    return;
}

# VRTSjadba60
package Pkg::VRTSjadba60::SolSparc;
@Pkg::VRTSjadba60::SolSparc::ISA = qw(Pkg::VRTSjadba60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjadba';
    $pkg->{basepkg}='VRTSdbac';
    $pkg->{name}=Msg::new("Japanese RAC support Language Kit")->{msg};
    return;
}

# VRTSjafs60
package Pkg::VRTSjafs60::SolSparc;
@Pkg::VRTSjafs60::SolSparc::ISA = qw(Pkg::VRTSjafs60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjafs';
    $pkg->{basepkg}='VRTSvxfs';
    $pkg->{name}=Msg::new("Japanese VERITAS File System Language Kit")->{msg};
    return;
}

# VRTSjavm60
package Pkg::VRTSjavm60::SolSparc;
@Pkg::VRTSjavm60::SolSparc::ISA = qw(Pkg::VRTSjavm60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjavm';
    $pkg->{basepkg}='VRTSvxvm';
    $pkg->{name}=Msg::new("Japanese VERITAS Volume Manager Language Kit")->{msg};
    return;
}

# VRTSzhvm60
package Pkg::VRTSzhvm60::SolSparc;
@Pkg::VRTSzhvm60::SolSparc::ISA = qw(Pkg::VRTSzhvm60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSzhvm';
    $pkg->{basepkg}='VRTSvxvm';
    $pkg->{name}=Msg::new("Chinese VERITAS Volume Manager Language Kit")->{msg};
    return;
}

# VRTSjadbe60
package Pkg::VRTSjadbe60::SolSparc;
@Pkg::VRTSjadbe60::SolSparc::ISA = qw(Pkg::VRTSjadbe60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjadbe';
    $pkg->{basepkg}='VRTSdbed';
    $pkg->{name}=Msg::new("Japanese SF for Oracle Language Kit")->{msg};
    return;
}

# VRTSjaodm60
package Pkg::VRTSjaodm60::SolSparc;
@Pkg::VRTSjaodm60::SolSparc::ISA = qw(Pkg::VRTSjaodm60::SunOS);

sub init_padv {
    my $pkg=shift;
    $pkg->{pkg}='VRTSjaodm';
    $pkg->{basepkg}='VRTSodm';
    $pkg->{name}=Msg::new("Japanese Oracle Disk Manager Language Kit")->{msg};
    return;
}

1;
