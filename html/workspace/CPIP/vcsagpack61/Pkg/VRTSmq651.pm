use strict;

package Pkg::VRTSmq651::Common;
@Pkg::VRTSmq651::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTSmq6';
    $pkg->{name}=Msg::new("Veritas High Availability Agent 5.1 for WebSphereMQ and WebSphereMQFTE by Symantec")->{msg};
    my $rpm_path = "../../../generic/vcs/application/webspheremq_agent/5*/*/rpms/VRTSmq*.rpm";
    Obj::edr()->{localsys}->cmd("_cmd_ls $rpm_path");
    my $exitcode = EDR::cmdexit();
    # If mediapath is specified on command line, rpm will be located from mediapath specified.
    # If mediapath is not specified , $pkg->{file} specified below will be used to locate rpm.
    if ( !$exitcode && " @ARGV " !~ m/\s-mediapath\s/ ) {
           $pkg->{file}=$rpm_path;
    }

    my $rtn = "";
    if ( not defined $ENV{'SYMC_AGPACK_INSTALLER_ARCHIVE_IN_PROGRESS'} )
    {
	    $rtn = Obj::edr()->{localsys}->cmd("/opt/VRTSvcs/bin/haagent -display WebSphereMQ 2>&1");
	    # VCS WARNING V-16-1-13301 Attempt to access non-existent agent
	    if ( $rtn =~ m/V-16-1-13301/ ) {
	    	$rtn = Obj::edr()->{localsys}->cmd("/opt/VRTSvcs/bin/haagent -display WebSphereMQ6 2>&1");
	    }
	    if ( $rtn !~ m/V-16-1-13301/ ) {
		    $pkg->{startprocs}=[ qw(mq651Agent) ];
		    $pkg->{stopprocs}=[ qw(mq651Agent) ];
	    }
    }
    return;
}
package Pkg::VRTSmq651::AIX;
@Pkg::VRTSmq651::AIX::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::HPUX;
@Pkg::VRTSmq651::HPUX::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::Linux;
@Pkg::VRTSmq651::Linux::ISA = qw(Pkg::VRTSmq651::Common);

package Pkg::VRTSmq651::SunOS;
@Pkg::VRTSmq651::SunOS::ISA = qw(Pkg::VRTSmq651::Common);

1;
