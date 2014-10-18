use strict;

package Pkg::VRTSvxvm60::Common;
@Pkg::VRTSvxvm60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSvxvm';
    $pkg->{name}=Msg::new("Veritas Volume Manager Binaries")->{msg};
    $pkg->{vminstall}='/tmp/.cpivminstall';
    $pkg->{softdeps} = [ qw(VRTSdbed VRTSodm) ];
    return;
}

# touch this file to inform VM native scripts that it is a CPI installation
# VM native scripts will skip the checks for encapsulated and mirrored bootdisk
# if it is a CPI installation
sub preinstall_sys {
    my ($pkg,$sys)=@_;
    $sys->cmd("_cmd_rmr $pkg->{vminstall} 2>/dev/null");
    $sys->cmd("_cmd_touch $pkg->{vminstall} 2>/dev/null") if ($sys->{encap});
    return;
}

sub postinstall_sys {
    my ($pkg,$sys)=@_;
    $sys->cmd("_cmd_rmr $pkg->{vminstall} 2>/dev/null");
    return;
}

package Pkg::VRTSvxvm60::AIX;
@Pkg::VRTSvxvm60::AIX::ISA = qw(Pkg::VRTSvxvm60::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxconfigd60 vxesd60 vxrelocd60 vxcached60 vxconfigbackupd60 vxattachd60 vvr60) ];
    $pkg->{stopprocs}=[ qw(vvr60 vxconfigbackupd60 vxsited60 vxcached60
                           vxrelocd60 vxnotify60 vxattachd60 vxesd60 vxconfigd60) ];
    $pkg->{ospkgs}{'5.3'}=['xlC.aix50.rte 6.0.0.7', 'devices.fcp.disk.rte 5.2.0.41', 'devices.scsi.disk.rte 5.2.0.41', 'devices.common.IBM.fc.hba-api'];
    $pkg->{ospkgs}{'6.1'}=['xlC.aix61.rte 9.0.0.0', 'devices.common.IBM.fc.hba-api' ];
    $pkg->{ospkgs}{'7.1'}=['xlC.aix61.rte 11.1.0.1', 'devices.common.IBM.fc.hba-api' ];
    $pkg->{has_install_export_cmd} = 1;
    return;
}
sub donotuninstall_sys {
    my ($pkg,$sys)=@_;
    $pkg->{donotrmonupgrade}=1 if(Cfg::opt("upgrade_kernelpkgs") && $sys->{pkgvers}{VRTScavf});
    return;
}

package Pkg::VRTSvxvm60::HPUX;
@Pkg::VRTSvxvm60::HPUX::ISA = qw(Pkg::VRTSvxvm60::Common);

sub init_plat {
    my $pkg=shift;

    $pkg->{startprocs}=[ qw(vxconfigd60 vxesd60 vxrelocd60 vxcached60 vxconfigbackupd60 vxattachd60 vvr60) ];
    $pkg->{stopprocs}=[ qw(vvr60 vxconfigbackupd60 vxsited60 vxcached60
                           vxrelocd60 vxnotify60 vxattachd60 vxesd60 vxconfigd60) ];
    $pkg->{reinstall}=1;
    $pkg->{donotrmonupgrade}=1;
    return;
}

package Pkg::VRTSvxvm60::Linux;
@Pkg::VRTSvxvm60::Linux::ISA = qw(Pkg::VRTSvxvm60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{startprocs}=[ qw(vxdmp60 vxio60 vxspec60 vxconfigd60 vxesd60 vxrelocd60 vxcached60 vxconfigbackupd60 vxattachd60 vvr60) ];
    $pkg->{stopprocs}=[ qw(vvr60 vxconfigbackupd60 vxsited60 vxattachd60 vxcached60 vxrelocd60 vxnotify60 vxesd60 vxconfigd60 vxspec60 vxio60 vxdmp60) ];
    $pkg->{previouspkgnames} = [ qw(VRTSvxvm-platform VRTSvxvm-common) ];
    return;
}

package Pkg::VRTSvxvm60::RHEL5x8664;
@Pkg::VRTSvxvm60::RHEL5x8664::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "parted"  =>  "parted-1.8.1-27.el5.i386 parted-1.8.1-27.el5.x86_64",
        "policycoreutils"  =>  "policycoreutils-1.33.12-14.8.el5.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm60::RHEL6x8664;
@Pkg::VRTSvxvm60::RHEL6x8664::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "glibc"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
        "libgcc"  =>  "libgcc-4.4.5-6.el6.i686 libgcc-4.4.5-6.el6.x86_64",
        "libstdc++"  =>  "libstdc++-4.4.5-6.el6.i686 libstdc++-4.4.5-6.el6.x86_64",
        "nss-softokn-freebl(x86-32)"  =>  "nss-softokn-freebl-3.12.9-3.el6.i686",
        "parted"  =>  "parted-2.1-13.el6.x86_64",
        "policycoreutils"  =>  "policycoreutils-2.0.83-19.8.el6_0.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm60::SLES10x8664;
@Pkg::VRTSvxvm60::SLES10x8664::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "parted"  =>  "parted-1.6.25.1-15.35.15.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm60::SLES11x8664;
@Pkg::VRTSvxvm60::SLES11x8664::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "parted"  =>  "parted-1.8.8-102.21.8.x86_64",
    };
    return;
}

package Pkg::VRTSvxvm60::RHEL5ppc64;
@Pkg::VRTSvxvm60::RHEL5ppc64::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'parted'  =>  'parted-1.8.1-17.el5.ppc parted-1.8.1-17.el5.ppc64',
        'policycoreutils'  =>  'policycoreutils-1.33.12-14.el5.ppc',
    };
    return;
}

package Pkg::VRTSvxvm60::SLES10ppc64;
@Pkg::VRTSvxvm60::SLES10ppc64::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'parted'  =>  'parted-1.6.25.1-15.19.ppc',
    };
    return;
}

package Pkg::VRTSvxvm60::SLES11ppc64;
@Pkg::VRTSvxvm60::SLES11ppc64::ISA = qw(Pkg::VRTSvxvm60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'parted'  =>  'parted-1.8.8-102.4.ppc64',
    };
    return;
}

package Pkg::VRTSvxvm60::SunOS;
@Pkg::VRTSvxvm60::SunOS::ISA = qw(Pkg::VRTSvxvm60::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{responsefile}=' ';
    $pkg->{startprocs}=[qw(vxdmp60 vxio60 vxspec60 vxconfigd60 vxesd60
                           vxrelocd60 vxcached60 vxconfigbackupd60 vxattachd60 vvr60) ];
    $pkg->{stopprocs}=[ qw(vvr60 vxconfigbackupd60 vxsited60 vxattachd60 vxcached60
                           vxrelocd60 vxnotify60 vxesd60 vxconfigd60
                           vxspec60 vxio60 vxdmp60) ];
    $pkg->{ospkgs}{all}=[ 'SUNWcsu' ];
    return;
}

sub define_ospatches {
    my ($pkg,$padv,$sys) = @_;
    my ($sunwcfcl_pkg);

    # we need to check for 114477-04 only if SUNWcfcl present
    $sunwcfcl_pkg=Pkg::new_pkg('Pkg','SUNWcfcl',$sys->{padv});
    push(@{$pkg->{ospatches}{'5.9'}},'114477-04') if ($sunwcfcl_pkg->version_sys($sys));

    return;
}

package Pkg::VRTSvxvm60::Solx64;
@Pkg::VRTSvxvm60::Solx64::ISA = qw(Pkg::VRTSvxvm60::SunOS);
sub init_padv {
    my $pkg=shift;
    $pkg->{ospatches}{'5.10'}=['118844-26', '119131-09', '119375-03', '119043-02', '125732-02', '128307-05'];
    return;
}

package Pkg::VRTSvxvm60::SolSparc;
@Pkg::VRTSvxvm60::SolSparc::ISA = qw(Pkg::VRTSvxvm60::SunOS);
sub init_padv {
    my $pkg=shift;
    # $pkg->{sppatches}{all}=[ qw(142629) ];
    $pkg->{ospatches}{'5.10'}=['119254-06', '119042-02', '125731-02', '128306-05'];
    return;
}

package Pkg::VRTSvxvm60::Sol11sparc;
@Pkg::VRTSvxvm60::Sol11sparc::ISA = qw(Pkg::VRTSvxvm60::SunOS);
 
sub init_padv {
    my $pkg=shift;
    $pkg->{donotrmonupgrade}=0;
    $pkg->{softdeps} = [];
    $pkg->{ospkgs}{all}=[];
    return;
}
 
package Pkg::VRTSvxvm60::Sol11x64;
@Pkg::VRTSvxvm60::Sol11x64::ISA = qw(Pkg::VRTSvxvm60::Sol11sparc);

1;
