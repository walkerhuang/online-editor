use strict;

package Pkg::VRTSdbed60::Common;
@Pkg::VRTSdbed60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbed';
    $pkg->{name}=Msg::new("Veritas Storage Foundation Databases")->{msg};
    $pkg->{startprocs}=[ qw(vxdbd60) ];
    $pkg->{stopprocs}=[ qw(vxdbd60) ];
    return;
}

package Pkg::VRTSdbed60::AIX;
@Pkg::VRTSdbed60::AIX::ISA = qw(Pkg::VRTSdbed60::Common);

package Pkg::VRTSdbed60::HPUX;
@Pkg::VRTSdbed60::HPUX::ISA = qw(Pkg::VRTSdbed60::Common);

sub preremove_sys {
    my ($pkg,$sys) = @_;
    my $vxdba_dir_bak = '/var/vx/vxdba_old.cpisave';
    my $vxdba_dir = '/var/vx/vxdba';
    # backup /var/vx/vxdba/ during upgrade
    # since pkg uninstall will delete it on HP-UX
    if (Cfg::opt('upgrade')) {
        $sys->cmd("_cmd_rmr $vxdba_dir_bak");
        $sys->cmd("_cmd_mv -f $vxdba_dir $vxdba_dir_bak");
        if (EDR::cmdexit()) {
            Msg::log("Failed to backup $vxdba_dir on $sys->{sys}");
        }
    }
    return;
}

sub postinstall_sys {
    my ($pkg,$sys) = @_;
    my $vxdba_dir_bak = '/var/vx/vxdba_old.cpisave';
    my $vxdba_dir = '/var/vx/vxdba';
    # restore /var/vx/vxdba/ after upgrade
    if (Cfg::opt('upgrade') && ($sys->exists($vxdba_dir_bak))) {
        $sys->cmd("_cmd_cp -rf $vxdba_dir_bak/* $vxdba_dir/");
        if (EDR::cmdexit()) {
            Msg::log("Failed to restore $vxdba_dir on $sys->{sys}");
        } else {
            $sys->cmd("_cmd_rmr $vxdba_dir_bak");
        }
    }
    return;
}

package Pkg::VRTSdbed60::Linux;
@Pkg::VRTSdbed60::Linux::ISA = qw(Pkg::VRTSdbed60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{pkg}='VRTSdbed';
    $pkg->{previouspkgnames} = [ qw(VRTSdbed-common) ];
    return;
}

package Pkg::VRTSdbed60::SLES11x8664;
@Pkg::VRTSdbed60::SLES11x8664::ISA = qw(Pkg::VRTSdbed60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{installonpatchupgrade}=1;
    return;
}

package Pkg::VRTSdbed60::SunOS;
@Pkg::VRTSdbed60::SunOS::ISA = qw(Pkg::VRTSdbed60::Common);

1;
