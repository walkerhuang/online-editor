use strict;

package Pkg::VRTSsapwebas7151::Common;
@Pkg::VRTSsapwebas7151::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSsapwebas71';
    $pkg->{name}=Msg::new("Veritas High Availability Agent for SAP WebAS by Symantec")->{msg};
    my $rpm_path = "../../../generic/vcs/application/sap_agent/5*/*/rpms/VRTSsapwebas*.rpm";
    Obj::edr()->{localsys}->cmd("_cmd_ls $rpm_path"); 
    my $exitcode = EDR::cmdexit();
    # If mediapath is specified on command line, rpm will be located from mediapath specified.
    # If mediapath is not specified , $pkg->{file} specified below will be used to locate rpm.
    if ( !$exitcode && " @ARGV " !~ m/\s-mediapath\s/ ) {
	    $pkg->{file}=$rpm_path;
    }
    return;
}
package Pkg::VRTSsapwebas7151::AIX;
@Pkg::VRTSsapwebas7151::AIX::ISA = qw(Pkg::VRTSsapwebas7151::Common);

package Pkg::VRTSsapwebas7151::HPUX;
@Pkg::VRTSsapwebas7151::HPUX::ISA = qw(Pkg::VRTSsapwebas7151::Common);

package Pkg::VRTSsapwebas7151::Linux;
@Pkg::VRTSsapwebas7151::Linux::ISA = qw(Pkg::VRTSsapwebas7151::Common);

package Pkg::VRTSsapwebas7151::SunOS;
@Pkg::VRTSsapwebas7151::SunOS::ISA = qw(Pkg::VRTSsapwebas7151::Common);

1;
