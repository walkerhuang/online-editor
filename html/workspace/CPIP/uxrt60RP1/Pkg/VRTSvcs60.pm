use strict;

package Pkg::VRTSvcs60::Common;
@Pkg::VRTSvcs60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvcs';
    $pkg->{name}=Msg::new("Veritas Cluster Server")->{msg};
    $pkg->{startprocs}=[ qw(had60 CmdServer60) ];
    $pkg->{stopprocs}=[ qw(had60 CmdServer60) ];
    $pkg->{autoremovedependentpkgs}=1;
    $pkg->{unkernelpkg}=1;
    return;
}

package Pkg::VRTSvcs60::AIX;
@Pkg::VRTSvcs60::AIX::ISA = qw(Pkg::VRTSvcs60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSvcs.rte) ];
    return;
}

package Pkg::VRTSvcs60::HPUX;
@Pkg::VRTSvcs60::HPUX::ISA = qw(Pkg::VRTSvcs60::Common);

package Pkg::VRTSvcs60::Linux;
@Pkg::VRTSvcs60::Linux::ISA = qw(Pkg::VRTSvcs60::Common);

package Pkg::VRTSvcs60::SunOS;
@Pkg::VRTSvcs60::SunOS::ISA = qw(Pkg::VRTSvcs60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{ospkgs}{all}=[ 'SUNWpool' ];
    $pkg->{smf}=['/var/svc/manifest/system/vcs.xml', '/lib/svc/method/vcs'];
    return;
}

# workaround of 1638382, remove the preremove script of obsolete pkg
sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($rootpath,$vers,$preremove_script);

    $vers=$sys->padv->pkg_version_sys($sys, $pkg);
    if (Cfg::opt('rootpath') && ($vers eq '5.0')) {
        $rootpath = Cfg::opt('rootpath');
        $preremove_script="$rootpath/var/sadm/pkg/VRTSvcs/install/preremove";
        $sys->cmd("_cmd_rm $preremove_script");
    }
    my $vcs = $pkg->prod('VCS60');
    $vcs->backup_smf_scripts_sys($sys,$pkg);
    return 1;
}

sub postremove_sys {
    my ($pkg, $sys) = (@_);
    my $vcs = $pkg->prod('VCS60');
    $vcs->restore_smf_scripts_sys($sys,$pkg);
    return;
}

1;
