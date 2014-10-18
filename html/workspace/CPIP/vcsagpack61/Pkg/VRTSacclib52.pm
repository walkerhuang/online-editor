use strict;

package Pkg::VRTSacclib52::Common;
@Pkg::VRTSacclib52::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSacclib';
    $pkg->{name}=Msg::new("Veritas Cluster Server ACC Library by Symantec")->{msg};
    my $rpm_path = "../../../generic/vcs/application/acc_library/5.2.4.0_library/rpms/VRTSacclib-5.2.4.0-GA_GENERIC.noarch.rpm";

    Obj::edr()->{localsys}->cmd("_cmd_ls $rpm_path");
    my $exitcode = EDR::cmdexit();
    # If mediapath is specified on command line, rpm will be located from mediapath specified.
    # If mediapath is not specified , $pkg->{file} specified below will be used to locate rpm.
    if ( !$exitcode && " @ARGV " !~ m/\s-mediapath\s/ ) {
	    $pkg->{file}=$rpm_path;
    }
	    return;
}

package Pkg::VRTSacclib52::AIX;
@Pkg::VRTSacclib52::AIX::ISA = qw(Pkg::VRTSacclib52::Common);

sub init_plat {
    my $pkg=shift;
    $pkg->{previouspkgnames}=[ qw(VRTSacclib.rte) ];
    return;
}

package Pkg::VRTSacclib52::HPUX;
@Pkg::VRTSacclib52::HPUX::ISA = qw(Pkg::VRTSacclib52::Common);

package Pkg::VRTSacclib52::Linux;
@Pkg::VRTSacclib52::Linux::ISA = qw(Pkg::VRTSacclib52::Common);

package Pkg::VRTSacclib52::SunOS;
@Pkg::VRTSacclib52::SunOS::ISA = qw(Pkg::VRTSacclib52::Common);

1;
