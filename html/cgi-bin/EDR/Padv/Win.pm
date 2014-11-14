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
package Padv::Win;
use strict;
use JSON;
#use if ( scalar( $^O =~ /MSWin/ ) ), "Win32";
#use if ( scalar( $^O =~ /MSWin/ ) ), "Win32::OLE";
#use if ( scalar( $^O =~ /MSWin/ ) ), "Win32::OLE::Const";
#use if ( scalar( $^O =~ /MSWin/ ) ), "Win32::OLE::Variant";

@Padv::Win::ISA = qw(Padv);

sub padvs {
    return [   qw( WinXPx86 WinXPx64
                   Win2003x86 Win2003x64 Win2003ia64
                   WinVistax86 WinVistax64
                   Win2008x86 Win2008x64  Win2008ia64
                   Win7x86 Win7x64
                   Win2012x64
                   Win8x86 Win8x64 )
           ];
}

sub init_plat {
#require Win32;
#require Win32::OLE;
#require Win32::OLE::Const;
#require Win32::OLE::Variant;

    my $padv = shift;
    $padv->{plat} = "Win";
    $padv->{name} = "Microsoft Windows";

    # no need to use cmdswap_sys defs unless a padv based conversion is reqd
    # Windows does not use full paths or translate directly to Unix commands
    # every command should already be properly translated to a $sys command
    # calling a $padv command with the cmd fully defined within $sys->cmd call
    #$padv->{cmd}{cp}         = "cmd.exe /c copy";
    #$padv->{cmd}{ls}         = "cmd.exe /c dir /B";
    #$padv->{cmd}{mkdirp}     = "cmd.exe /c mkdir";
    #$padv->{cmd}{mv}         = "cmd.exe /c move /Y";
    #$padv->{cmd}{rmr}        = "cmd.exe /c del /F /Q";
    #$padv->{cmd}{rmdir}      = "cmd.exe /c rd /S /Q";
    #$padv->{cmd}{ping}       = "ping";
    #$padv->{cmd}{nslookup}   = "nslookup";
    #$padv->{cmd}{systeminfo} = "systeminfo";

    Cfg::set_opt("serial");
    Cfg::set_opt("redirect");
    return;
}

# this set of commands is executed during info_sys before the padv objects
# are created and therefore full command paths are required

sub arch_sys {
    my ( $padv, $sys ) = @_;
    if ($sys->{wmi}) {
        # remote check
        my $arch=wmi_instances_of_sys($sys, 'Win32_Processor', 'Architecture');
        return ($arch==0) ? "x86" :
               ($arch==6) ? "ia64" :
               ($arch==9) ? "x64" :
               # unsupported arches
               ($arch==1) ? "MIPS" :
               ($arch==2) ? "Alpha" :
               ($arch==3) ? "PowerPC" : "?arch=$arch";
    }
    # local check
    # Suppress warnings from Win32 due to non-support of Win8/Win2012
    local $SIG{__WARN__} = sub { warn $_[0] unless (caller eq "Win32"); };

    # Win32::GetChipName() Returns the processor type: 386, 486 or 586 for x86
    # processors, 8664 for the x64 processor and 2200 for the Itanium. Since it
    # returns the native processor type it will return a 64-bit processor type
    # even when called from a 32-bit Perl running on 64-bit Windows.
    my $web=Obj::web();
    if($web->{run_type} eq "vom_addon"){
        require VRTS::OS;
        my $os = VRTS::OS->new();
        return $os->get_arch();
    }
    my $arch = Win32::GetChipName();
    # Try to match x64 or Itanium and default to x86
    return ( $arch == 8664 ) ? "x64"  :
           ( $arch == 2200 ) ? "ia64" : "x86";
}

sub distro_sys {
    # Current OS name list
    # WinWin32s
    # Win95
    # Win98
    # WinMe
    # WinNT3.51
    # WinNT4
    # Win2000
    # WinXP/.Net
    # Win2003
    # WinHomeSvr
    # WinVista
    # Win2008
    # Win7
    # Win2012
    # Win8
    my ( $padv, $sys ) = @_;
    if ($sys->{wmi}) {
        # remote check
        my $os_name=wmi_instances_of_sys($sys, 'Win32_OperatingSystem', 'Name');
        return ($os_name=~/2012/) ? "Win2012" :
               ($os_name=~/2008/) ? "Win2008" :
               ($os_name=~/2003/) ? "Win2003" :
               ($os_name=~/2000/) ? "Win2000" :
               EDR::die("Win::distro_sys - convert $os_name");
    }
    # local check

    # Suppress warnings from Win32 due to non-support of Win8/Win2012
    local $SIG{__WARN__} = sub { warn $_[0] unless (caller eq "Win32"); };
    my $web=Obj::web();
    if($web->{run_type} eq "vom_addon"){
        require VRTS::OS;
        my $os_name = VRTS::OS->get_ver();
        return ($os_name=~/2012/) ? "Win2012" :
               ($os_name=~/2008/) ? "Win2008" :
               ($os_name=~/2003/) ? "Win2003" :
               ($os_name=~/2000/) ? "Win2000" : "Windows";
    }
    my ( $os_name, undef ) = Win32::GetOSName();

    unless ( defined $os_name ) {
        my (
            $desc, $major, $minor,     $build, $id,
            undef, undef,  $suitemask, $producttype
        ) = Win32::GetOSVersion();
        if ( $id == 2 && $major == 6 && $minor == 2 ) {

            # Win8 or Win2012
            if ( $producttype == Win32::VER_NT_WORKSTATION() ) {
                $os_name = "Win8";
            }
            else {
                $os_name = "Win2012";
            }
        }
    }

    $os_name=~s/\.//g;
    $os_name=~s/\W.*$//;
    return $os_name;
}

# need to get the OS and Version out, from
# Microsoft Windows XP [Version 5.1.2600]
sub platvers_sys {
    my ( $padv, $sys ) = @_;
    if ($sys->{wmi}) {
        # remote check
        return wmi_instances_of_sys($sys, 'Win32_OperatingSystem', 'Version');
    }
    # local check
    my ($string,$major,$minor,$build,$id) = Win32::GetOSVersion();
    return "$major.$minor";
}

# here, assuming it is local and just setting to $^O
# version and arch could be integrated later
sub padv_sys {
    my ( $padv, $sys ) = @_;
    return $sys->{distro}.$sys->{arch};
}

sub fqdn_ip_sys {
    my ( $padv, $sys ) = @_;
    my ( $fqdn,$nslookup, $ip );

    $nslookup = EDR::cmd_local( "nslookup -timeout=10 -retry=2 $sys->{sys}" );

    # nslookup sample output
    # Single IP address return format:
    # Server:  server.example.com
    # Address:  10.10.10.10
    # Name:    system1.example.com
    # Address:  10.10.192.168

    # Multiple IP address return format:
    # Server:  server.example.com
    # Address:  10.10.10.10
    #
    # Name:    system1.example.com
    # Addresses:  fc44:53f9:cb30:50:1470:6409:f2c3:6bd6
    #           10.10.192.168

    # Look 'Addresses' in addition to 'Address', and retrieve the first IPV4
    # address that is found after that.
    ( $fqdn,$ip ) 
        = ( $nslookup =~ / ^ Name: \s+ ( \S+ ) \s+
                           ^ Address (?:es)? : .+? ( \d+ \. \d+ \. \d+ \. \d+ )
                         /xmis );

    return ( $fqdn, $ip );
}

sub ipv4_sys {
    my ( $padv, $sys ) = @_;
    my $output = $sys->cmd('ipconfig /all');
    return ($output =~ /^\s*IP(v4)? Address.*:\s*(\d+\.\d+\.\d+\.\d+).*$/mi ) ? 1 : 0;
}

sub ipv6_sys {
    my ( $padv, $sys ) = @_;
    my $output = $sys->cmd('ipconfig /all');
    return ($output =~ /^\s*IPv6 Address.*:\s*.*$/mi ) ?  1 : 0;
}

# DONE with info_sys routines that require full command paths

sub procs_sys {
    my ( $padv, $sys, $proc) = @_;
    EDR::die("Win procs_sys has not been implemented");
}

sub chown_root_sys {
    my ( $padv, $sys ) = @_;
    #EDR::die("Win chown_root_sys has not been implemented");
}

sub get_root_home_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win get_root_home_sys has not been implemented");
}

sub kill_pids_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win kill_pids_sys has not been implemented");
}

sub cpu_sys {
    my ( $padv, $sys ) = @_;

    my @cpus = ();

    my $systeminfo = $sys->cmd('cmd.exe /c systeminfo');

    my $processor_flag = 0 ;
    for my $line (split (/\n/, $systeminfo)) {
       if ($line =~ /^Processor\(s\):/i) {
           $processor_flag = 1;
           next;
       }
       if($processor_flag == 1) {
           if($line =~/^\s*\[\d+\]/){
             my ($model,$speed) = $line=~/\[\d+\]:\s*(.*)~(\d+)\s*Mhz/i;
             my $cpu = {};
             $model =~ s/\s*$//g;
             $cpu->{'NAME'}   = $model;
             $cpu->{'TYPE'}   = $model;
             $cpu->{'SPEED'}  = $speed;
             push (@cpus,$cpu);
           }
           else {
               last;
           }
       }
    }
    return \@cpus;
}

sub cpu_number_sys {
    my ( $padv, $sys ) = @_;
    return $ENV{'NUMBER_OF_PROCESSORS'};
}

sub cpu_speed_sys {
    my ( $padv, $sys ) = @_;
    my $cpus = $padv->cpu_sys($sys);
    my $cpu_speed = $cpus->[0]->{'SPEED'};
    return  $cpu_speed;
}

# Check if the driver is loaded
sub driver_sys {
    my ( $padv, $sys, $driver ) = @_;
    EDR::die("Win driver_sys has not been implemented");
}

# Returns a reference to an array holding the NICs connected to the default gateway/router
sub gatewaynics_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win gatewaynics_sys has not been implemented");
}

sub installpath_sys {
    my ( $padv, $sys, $pkgpatch ) = @_;
    EDR::die("Win installpath_sys has not been implemented");
}

# determine all IP's on $sys
sub ips_sys {
    my ( $padv, $sys ) = @_;
    my @ips = ();
    my $output = $sys->cmd('ipconfig /all');
    my @lines = split(/\n/,$output);
    for my $line (@lines) {
       if($line =~ /IP(v4|v6)? Address.*[.\s]+:\s*([^\s\(]+).*$/i)  {
           push (@ips, $2);
       }
    }
    return \@ips;
}

# Only local system is supported on Windows platform
sub islocal_sys {
    my ( $padv, $sys ) = @_;
    my $edr=Obj::edr();
    return 1 if (uc($sys->{sys}) eq uc($edr->{localsys}{sys}));
    return ''
}

sub is_bonded_nic_sys {
    my ( $padv, $sys, $nic ) = @_;
    EDR::die("Win is_bonded_nic_sys has not been implemented");
}

sub bondednics_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win bondednics_sys has not been implemented");
}

sub load_driver_sys {
    my ( $padv, $sys, $driver ) = @_;
    EDR::die("Win load_driver_sys has not been implemented");
}

sub media_patch_file {
    my ( $padv, $patch, $patchdir ) = @_;
    EDR::die("Win media_patch_file has not been implemented");
}

sub media_patch_version {
    my ( $padv, $patch ) = @_;
    EDR::die("Win media_patch_version has not been implemented");
}

sub media_pkg_file {
    my ( $padv, $pkg, $pkgdir ) = @_;
    EDR::die("Win media_pkg_file has not been implemented");
}

sub media_pkg_version {
    my ( $padv, $pkg ) = @_;
    EDR::die("Win media_pkg_version has not been implemented");
}

sub memory_size_sys {
    my ( $padv, $sys ) = @_;
    my $systeminfo = $sys->cmd('systeminfo');
    my ($physical_mem) = $systeminfo =~/^Total Physical Memory:\s+(.*)\s*$/mi;

    #remove comma
    $physical_mem =~ s/,//g;

    return $physical_mem;
}

# determine the netmask of the base IP configured on a NIC
sub netmask_sys {
    my ( $padv, $sys, $nic, $ipv, $ip ) = @_;
    EDR::die("Win netmask_sys has not been implemented");
}

sub niccheck_sys {
    my ( $padv, $sys, $nic ) = @_;
    EDR::die("Win niccheck_sys has not been implemented");
}

# determin ip on $nic
sub nic_ips_sys {
    my ( $padv, $sys, $nic ) = @_;
    EDR::die("Win nic_ips_sys has not been implemented");
}

# get the nic device name
sub nic_device_name {
    my ( $padv, $sys ) = @_;
    EDR::die("Win nic_device_name has not been implemented");
}

sub nic_speed_sys {
    my ( $padv, $sys, $nic ) = @_;
    EDR::die("Win nic_speed_sys has not been implemented");
}

# return 0 if patch is not installed or lower version is installed
# return 1 if equal or higher version is installed
sub ospatch_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win ospatch_sys has not been implemented");
}

sub osupdatelevel_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win osupdatelevel_sys has not been implemented");
}

sub hostid_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win hostid_sys has not been implemented");
}

sub model_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win model_sys has not been implemented");
}

sub kerbit_sys {
    my ( $padv, $sys ) = @_;
    my  $kerbit = ( $sys->{'arch'} eq 'x86') ?  32 : 64;
    return $kerbit;
}

sub partially_installed_pkgs_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win partially_installed_pkgs_sys has not been implemented");
}

sub patch_copy_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_copy_sys has not been implemented");
}

# check if patch is installed sucessfully
sub patch_install_success_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_install_success_sys has not been implemented");
}

sub patch_install_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_install_sys has not been implemented");
}

sub patch_installed_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_installed_sys has not been implemented");
}

sub patch_obsoleted_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_obsoleted_sys has not been implemented");
}

sub patch_remove_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_remove_sys has not been implemented");
}

# returns the version of a patch installed on $sys
# returns version 999 if the patch has been obsoleted
sub patch_version_sys {
    my ( $padv, $sys, $patch ) = @_;
    EDR::die("Win patch_version_sys has not been implemented");
}

# Get all the patches installed on the system
sub patches_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win patches_sys has not been implemented");
}

# ping a host, supports IPV4 and IPV6
# returns "" if successful, string if unsuccessful, opposite perl standard
# $sys can be a system name or IP and is scalar, not system object as ping_sys
sub ping {
    my ( $padv, $sysip ) = @_;
    return "" if ( $ENV{NOPING} );
    my $ping=EDR::cmd_local("ping -n 1 $sysip");
    return ($ping=~/Received = 1/);
}

sub pkgs_patches_sys {
    # does nothing now, but does not die either
}

sub pkg_copy_sys {
    my ( $padv, $sys, $pkg ) = @_;
    EDR::die("Win pkg_copy_sys has not been implemented");
}

sub pkg_install_success_sys {
    my ( $padv, $sys, $pkg ) = @_;
    EDR::die("Win pkg_install_success_sys has not been implemented");
}

sub pkg_install_sys {
    my ( $padv, $sys, $pkg ) = @_;
    EDR::die("Win pkg_install_sys has not been implemented");
}

sub pkg_remove_sys {
    my ( $padv, $sys, $pkg ) = @_;
    EDR::die("Win pkg_remove_sys has not been implemented");
}

sub pkg_uninstall_sys {
    my ( $padv, $sys, $pkg ) = @_;
    EDR::die("Win pkg_uninstall_sys has not been implemented");
}

sub pkg_uninstall_success_sys {
    my ( $padv, $sys, $pkg ) = @_;
    EDR::die("Win pkg_uninstall_success_sys has not been implemented");
}

sub pkg_version_sys {
    my ( $padv, $sys, $pkg, $prevpkgs_flag, $pbe_flag ) = @_;
    EDR::die("Win pkg_version_sys has not been implemented");
}

# determine the NICs on $sys which have IP addresses configured on them
# return a reference to an array holding the NICs
sub publicnics_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win publicnics_sys has not been implemented");
}

# get swap informations
sub swap_size_sys {
    my ( $padv, $sys ) = @_;
    EDR::die("Win swap_size_sys has not been implemented");
}

# determine all NICs on $sys
# return a reference to an array holding the NICs
sub systemnics_sys {
    my ( $padv, $sys, $bnics_flag ) = @_;
    EDR::die("Win systemnics_sys has not been implemented");
}

sub unload_driver_sys {
    my ( $padv, $sys, $driver, $pkg ) = @_;
    EDR::die("Win unload_driver_sys has not been implemented");
}

sub verify_root_user {
    # does nothing now, but does not die either
}

sub vrtspkgversdeps_script {
    EDR::die("Win vrtspkgversdeps_script has not been implemented");
}

# handling file and directory for Windows.
sub devnull { 'nul' }

sub rootdir { '\\' }

my $DRIVE_RX = '[a-zA-Z]:';
my $UNC_RX = '(?:\\\\\\\\|//)[^\\\\/]+[\\\\/][^\\\\/]+';
my $VOL_RX = "(?:$DRIVE_RX|$UNC_RX)";
sub filename_is_absolute {
    my ($padv,$file)=@_;
    if ($file =~ m{^($VOL_RX)}o) {
      my $vol = $1;
      return ($vol =~ m{^$UNC_RX}o ? 2
	      : $file =~ m{^$DRIVE_RX[\\/]}o ? 2
	      : 0);
    }
    return $file =~  m{^[\\/]} ? 1 : 0;
}

sub exists_sys {
    my ($padv,$sys,$file)=@_;
    return (-e $file);
}

sub is_dir_sys {
    my ($padv,$sys,$dir)=@_;
    return (-d $dir);
}

sub is_file_sys {
    my ($padv,$sys,$file)=@_;
    return (-f $file);
}

sub is_symlink_sys {
    my ($padv,$sys,$symlink)=@_;
    return 0;
}

sub is_executable_sys {
    my ($padv,$sys,$file)=@_;
    return 0;
}

sub catfile_sys {
    my ($padv,$sys,$file)=@_;
    return '' unless (-f $file);
    return $sys->cmd("cmd.exe /c type \"$file\"");
}

sub grepfile_sys {
    my ($padv,$sys,$word,$file)=@_;
    # need implement later
    my $rtn='';
    return $rtn;
}

sub lsfile_sys {
    my ($padv,$sys,$file)=@_;
    # need implement later
    my $rtn='';
    return $rtn;
}

sub readfile_sys {
    my ($padv,$sys,$file)=@_;
    EDR::die("Win readfile_sys has not been implemented");
    return;
}

sub writefile_sys {
    my ($padv,$sys,$write,$file)=@_;
    EDR::die("Win writefile_sys has not been implemented");
    return;
}

sub appendfile_sys {
    my ($padv,$sys,$write,$file)=@_;
    EDR::die("Win appendfile_sys has not been implemented");
    return;
}

sub createfile_sys {
    my ($padv,$sys,$file)=@_;
    # may need mkdir dirname($file)
    $sys->cmd("type nul>\"$file\" 2>nul");
    return !EDR::cmdexit();
}

sub copyfile_sys {
    my ($padv,$sys,$source_file,$target_file)=@_;
    return 0 unless ($source_file && $target_file);

    $sys->cmd("cmd.exe /c copy \"$source_file\" \"$target_file\" 2>nul");
    return !EDR::cmdexit();
}

sub movefile_sys {
    my ($padv,$sys,$source_file,$target_file)=@_;
    return 0 unless ($source_file && $target_file);

    $sys->cmd("cmd.exe /c move \"$source_file\" \"$target_file\" 2>nul");
    return !EDR::cmdexit();
}

sub filestat_sys {
    my ($padv,$sys,$file)=@_;
    EDR::die("Win filesize_sys has not been implemented");
    return;
}

sub change_filestat_sys {
    my ($padv,$sys,$file,$stat)=@_;
    EDR::die("Win change_filesize_sys has not been implemented");
    return;
}

sub filesize_sys {
    my ($padv,$sys,$file)=@_;

    #surround with double quotation if there is space in the file name
    my $cmd= "cmd.exe /c dir /S  \"$file\"";
    my $output = $sys->cmd($cmd);
    # example
    #
    # Total Files Listed:
    #        9750 File(s)  2,071,038,687 bytes
    #        2438 Dir(s)  15,432,228,864 bytes free
    my ($filesize) = $output =~ /Total Files Listed:\s*$^\s*.*File\(s\)\s+([\d\,]+)\s*.*$/m;
    return $filesize ;
}

sub chmod_sys { }

sub mkdir_sys {
    my ($padv,$sys,$dir)=@_;
    return unless $dir;
    return 1 if (-d $dir);
    # Win32::CreateDirectory($dir); does not make intermediate directories
    $sys->cmd("cmd.exe /c mkdir \"$dir\"");
    return !EDR::cmdexit();
}

sub rm_sys {
    my ($padv,$sys,$file) = @_;
    return unless $file;

    my $rm = (-d $file) ? "rd /S /Q" : "del /F /Q";
    $sys->cmd("cmd.exe /c $rm \"$file\"");
    return !EDR::cmdexit();
}

# new for remote handling
# sets $sys->{wmi} as the remote flag and $sys->{secd} as security descriptor
sub get_wmi_object_sys {
    my ( $padv, $sys ) = @_;
    my ($account,$accountSID,$domain,$err,$login,$msg,$trustee,$secd,$sid,$wmi,$wmiloc);

    $wmiloc=Win32::OLE->new('WbemScripting.SWbemLocator');
    if (!$wmiloc) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Cannot create locator object on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    $sys->{wmi}=$wmiloc->ConnectServer($sys->{sys}, 'root\\cimv2');
    if (!$sys->{wmi}) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Cannot create server object for $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    $secd=$sys->{wmi}->Get("Win32_SecurityDescriptor");
    if (!$secd) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Cannot create security descriptor for $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    # open local wmi instance
    $wmi=Win32::OLE->GetObject('WinMgmts:{impersonationlevel=impersonate}!root/cimv2');
    if (!$wmi) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Cannot create wmi instance for $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    # create instance of Win32_Account bound to user
    # doing this so we can get the user's SID
    $login=Win32::LoginName();
    $domain=Win32::DomainName();
    $account=$wmi->Get("Win32_Account.Domain='$domain',Name='$login'");
    if (!$account) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Win32 Account error on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    # create instance of Win32_SID populated using account instance from above
    # this lets us get SID in different formats
    $sid=$account->SID;
    $accountSID=Win32::OLE->GetObject("Winmgmts:{impersonationlevel=impersonate}!root/cimv2:Win32_SID.SID='$sid'");
    if (!$accountSID) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Win32 SID Instance error on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    # create instance of Win32_Trustee and populate
    # (note: uses Sid instance from above)
    $trustee=$wmi->Get("Win32_Trustee")->SpawnInstance_;
    if (!$trustee) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Win32 Trustee error on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }

    $trustee->{Domain}=$domain;
    $trustee->{Name}=$login;
    $trustee->{SID}=$accountSID->BinaryRepresentation;
    no strict 'subs';
    $secd->{ControlFlags}=Variant(VT_I4, 0x4);
    $secd->{Group}=$trustee;
    $secd->{Owner}=$trustee;
    $sys->{secd}=$secd;
    return 1;
}

# returns the first $member->{key} value found in @arr
# not a $padv based OO call as it is called be remote_hostname_sys
sub wmi_instances_of_sys {
    my ($sys,$iof,$key,$ddonr) = @_;
    my @caller=caller(1);
    EDR::die("$caller[3] called without sys->{wmi}") if (!$sys->{wmi});
    my @iof=Win32::OLE::in($sys->{wmi}->InstancesOf($iof));
    for my $prop(@iof) { return $prop->{$key} if ($prop->{$key}); }
    return '' if ($ddonr);
    EDR::die("$key not found in call to Win32::OLE::in(InstancesOf($iof)) from $caller[3]($sys)");
}

# first eight subs are internal-only
# the framework reads and writes to one fixed registry key-name but
# the other subs are written to handle any passed key-name combo
sub registry_hive { return 0x80000002 } # HKEY_LOCAL_MACHINE

sub registry_key {
    return "SOFTWARE\\VERITAS\\NetBackup\\CurrentVersion\\".EDR::get('uuid');
}

sub registry_name { return 'output' }

sub get_registry_object_sys {
    my ( $padv, $sys ) = @_;
    return $sys->{reg} if (defined($sys->{reg}));
    my $reg = Win32::OLE->GetObject("winmgmts:\\\\$sys->{sys}\\root\\default:StdRegProv");
    if (!$reg) {
        my $err=Win32::OLE->LastError();
        my $msg=Msg::new("Cannot create registry object on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    } else {
        Msg::log("Obtained registry object for system $sys->{sys}");
    }
    $sys->{reg}=$reg;
    return $reg;
}

sub create_registry_key_sys {
    my ($padv,$sys,$key) = @_;
    my $create=$sys->{reg}->CreateKey($padv->registry_hive,$key);
    if ($create) {
        my $msg=Msg::new("Cannot create registry key $key on $sys->{sys}");
        $sys->push_stop_checks_error($msg);
        return '';
    } else {
        Msg::log("Successfully created registry key $key on $sys->{sys}");
    }
    return 1;
}

sub write_registry_key_sys {
    my ($padv,$sys,$key,$name,$value) = @_;
    my $write = $sys->{reg}->SetExpandedStringValue($padv->registry_hive,$key,$name,$value);
    if ($write) {
        my $msg=Msg::new("Cannot write value $value to registry key $key name $name on $sys->{sys}");
        $sys->push_stop_checks_error($msg);
        return '';
    } else {
        Msg::log("Successfully wrote value $value to registry key $key name $name on $sys->{sys}");
    }
    return 1;
}

sub read_registry_key_sys {
    my ($padv,$sys,$key,$name) = @_;
    my $auth=$sys->{reg}->CheckAccess($padv->registry_hive,$key,3,'');
    if ($auth>0) {
        my $msg=Msg::new("Registry key does not exist on $sys->{sys}");
        $sys->push_error($msg);
        $sys->{noregkey}{$key}=1;
        return '';
    }
    no strict 'subs';
    my $value=Variant(VT_BYREF|VT_BSTR,"");
    my $rtn=$sys->{reg}->GetExpandedStringValue($padv->registry_hive,$key,$name,$value);
    if ($rtn>0) {
        my $msg=Msg::new("Registry read error on $sys->{sys}: $auth");
        $sys->push_error($msg);
        return '';
    }
    return $value;
}

sub delete_registry_key_sys {
    my ($padv,$sys,$key) = @_;
    return 1 if ($sys->{noregkey}{$key});
    my $delete=$sys->{reg}->DeleteKey($padv->registry_hive,$key);
    if ($delete) {
        my $msg=Msg::new("Cannot delete registry key $key on $sys->{sys}");
        $sys->push_stop_checks_error($msg);
        return '';
    } else {
        Msg::log("Successfully deleted registry key $key on $sys->{sys}");
    }
    return 1;
}

# externally only these to calls should be made
sub registry_read_sys {
    my ( $padv, $sys ) = @_;
    return $padv->read_registry_key_sys($sys,$padv->registry_key,$padv->registry_name);
}

sub registry_write_sys {
    my ( $padv, $sys, $value ) = @_;
    my ($fail,$read,$uuid);

    # sub calls make all $sys->push_stop_checks_error($msg); calls
    # everywhere except read==write verification

    $value.=int(rand()*1000) if ($value=~/^test/);

    # $sys->{reg} is typically defined during initial test, but write
    # to report EDR::die message may occur before systems phase
    # 1. Create and save the registry object
    Msg::log("Registry test on system $sys->{sys}:");
    return '' unless ($padv->get_registry_object_sys($sys));

    # 2. Create the registry key
    return '' unless ($padv->create_registry_key_sys($sys,$padv->registry_key));

    # 3.  Write the registry key
    if ($padv->write_registry_key_sys($sys,$padv->registry_key,$padv->registry_name,$value)) {

        # 4. Read the registry key to verify
        $read=$padv->read_registry_key_sys($sys,$padv->registry_key,$padv->registry_name);
        # strangeness, $read is a string but (!$read) returns true
        if (($read ne $value)) {
            my $msg=Msg::new("Registry write and read values do not match on $sys->{sys} (write=$value,read=$read)");
            $sys->push_stop_checks_error($msg);
            $fail=1;
        }
    }

    # 5. Delete the registry key
    $padv->delete_registry_key_sys($sys,$padv->registry_key)
        if ($value=~/^test\d+/);
    return !$fail;
}

# not a $padv based OO call
sub remote_hostname_sys {
    my $sys = shift;
    return wmi_instances_of_sys($sys, 'Win32_ComputerSystem', 'Name');
}

# windows remote commands do not return STDOUT, STDERR, or exit code
# they do return a basic command succeeded exit code
# not a $padv based OO call
sub remote_win_cmd_sys {
    # not a $padv based OO call
    my ( $sys, $cmd) = @_;
    my $process = $sys->{wmi}->Get("Win32_Process");
    Msg::log("remote_win_cmd $sys->{sys} $cmd");
    no strict 'subs';
    my $rtn = $process->Create( $cmd, undef, undef,
                                Variant( VT_I4 | VT_BYREF, 0 ) );
    my $msg = ($rtn==0) ? "Success" :
              ($rtn==2) ? "Access Denied" :
              ($rtn==3) ? "Insufficient Privilege" :
              ($rtn==8) ? "Unknown Failure" :
              ($rtn==9) ? "Path Not Found" :
              ($rtn==21) ? "Invalid Parameter" : "rtn=$rtn";
    Msg::log($msg);
    return $rtn;
}

sub share_exists_sys {
    my ($padv, $sys, $sharename) = @_;
    EDR::die("share_exists_sys called without sys->{wmi}") if (!$sys->{wmi});
    my @names=Win32::OLE::in($sys->{wmi}->InstancesOf('Win32_Share'));
    for my $share(@names) { return 1 if ($share->{Name} eq $sharename); }
    return '';
}

sub create_remote_exe_sys {
    my ( $padv, $sys ) = @_;
    my ($err,$msg,$rtn,$share,$sharename,$uuid,$wmireg);

    $uuid=EDR::get('uuid');
    $padv->{rwepath}="C:\\edr\\tmppath\\$uuid";
    $sharename="share$uuid";

    # 1. Create the directory
    $sys->cmd("cmd.exe /c md $padv->{rwepath}");
    sleep 5;

    # 2. Create the Share
    $share=$sys->{wmi}->Get("Win32_Share");
    if (!$share) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Unable to get a Win32_Share on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    $rtn=$share->Create($padv->{rwepath},$sharename,0,2,"tmp share",'',$sys->{secd});
    if ($rtn) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Creation of share $sharename ($padv->{rwepath}) on $sys->{sys} failed: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    sleep 10;
    # double-verify here. Required for later call to Delete
    if (!$padv->share_exists_sys($sys, $sharename)) {
        $msg=Msg::new("Creation of share $sharename ($padv->{rwepath}) on $sys->{sys} failed");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    Msg::log("Share $sharename created at $padv->{rwepath} on $sys->{sys}");

    # 3. Copy the file
    EDR::cmd_local("cmd.exe /c copy $0 \\\\$sys->{sys}\\$sharename\\");
    sleep 5;

    # 4. Delete the share
    $wmireg=Win32::OLE->GetObject("winmgmts:\\\\$sys->{sys}\\root\\cimv2:Win32_Share.Name=\'$sharename\'");
    if (!$wmireg) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Could not get $sharename share object on $sys->{sys}: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    $rtn=$wmireg->Delete();
    if ($rtn) {
        $err=Win32::OLE->LastError();
        $msg=Msg::new("Deletion of share $sharename ($padv->{rwepath}) on $sys->{sys} failed: $err");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    if ($padv->share_exists_sys($sys, $sharename)) {
        $msg=Msg::new("Deletion of share $sharename ($padv->{rwepath}) on $sys->{sys} failed");
        $sys->push_stop_checks_error($msg);
        return '';
    }
    Msg::log("Share $sharename deleted on $sys->{sys}");
    sleep 5;
    return 1;
}

sub execute_remote_exe_sys {
    my ($padv, $sys, $args) = @_;
    return 1 if ($sys->{noregkey}{$padv->registry_key});
    my $script=EDR::get("script");
    $sys->cmd("$padv->{rwepath}\\$script -rwe $args");
# remote host writes PID=$$ as its write test which remains until completion
    my ($sleep,$json);
    execute_remote_exe_initial_sleep();
    while ((!$sleep) || ($json=~/PID=\d/)) {
        $sleep+=10;
        sleep 10;
        $json=$padv->read_registry_key_sys($sys,$padv->registry_key,$padv->registry_name);
        Msg::log("registry read: $sys->{sys}=$json");
        # timeout here?
    }
    $padv->decode_rwe_systems_errors_warnings_sys($sys,$json);
# now that we have read it, clear it
    $padv->delete_registry_key_sys($sys,$padv->registry_key);
    return 1;
}

# used for timing things like expanding zip files
sub execute_remote_exe_initial_sleep { }

sub cleanup_remote_exe_sys {
    my ( $padv, $sys ) = @_;
    $padv->{rwepath}=~s/\//\/\//g;
    $sys->cmd("cmd.exe /c rmdir /S /Q $padv->{rwepath}");
    return 1;
}

# read the registry and convert errors, warnings, notes to $sys values
sub decode_rwe_systems_errors_warnings_sys {
    my ( $padv, $sys, $json) = @_;
    my ($err,$ewnp,$msg);
    if ($json eq '') {
        $msg=Msg::new("$sys->{sys} NULL registry read");
        $sys->push_error($msg);
        return;
    }
    eval { $ewnp=decode_json("$json"); };
    if ($@) {
        $err=$@;
        $msg=Msg::new("$sys->{sys} JSON read: $json");
        $sys->push_error($msg);
        $msg=Msg::new("$sys->{sys} registry read error - $err");
        $sys->push_error($msg);
        return;
    }
    return if ($$ewnp{pass});
    for my $ewnk(qw(errors warnings notes)) {
        next unless ($$ewnp{$ewnk});
        for my $ewn(@{$$ewnp{$ewnk}}) {
            push(@{$sys->{$ewnk}}, $ewn);
        }
    }
}

sub write_rwe_systems_errors_warnings_sys {
    my ( $padv, $sys ) = @_;
    my $ewn={ 'pass' => 1 };
    for my $ewnk(qw(errors warnings notes)) {
        $sys->{$ewnk}||=[];
        if (scalar(@{$sys->{$ewnk}})) {
            $$ewn{$ewnk}=[ @{$sys->{$ewnk}} ];
            delete($$ewn{pass});
        }
    }
    my $json=encode_json($ewn);
    Msg::log("Writing status to registry:\n$json");
    # write output to registry, this write should not fail if test write passed
    $padv->registry_write_sys($sys,$json);
    return 1;
}

sub get_env_value_sys {
    my ($padv, $sys, $env) = @_;
    EDR::die("Win get_env_value_sys has not been implemented");
}

# what padv rentiation do we need for:
# arch: chipset
# version: XP,vista,7,other

package Padv::WinXPx86;
@Padv::WinXPx86::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x86";
    $padv->{distro} = 'XP';
    $padv->{name}   = "Windows XP";
    return;
}

package Padv::WinXPx64;
@Padv::WinXPx64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = 'XP';
    $padv->{name}   = "Windows XP x64";
    return;
}

package Padv::Win2003x86;
@Padv::Win2003x86::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x86";
    $padv->{distro} = '2003';
    $padv->{name}   = "Windows Server 2003";
    return;
}

package Padv::Win2003x64;
@Padv::Win2003x64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = '2003';
    $padv->{name}   = "Windows Server 2003 x64";
    return;
}

package Padv::Win2003ia64;
@Padv::Win2003ia64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "ia64";
    $padv->{distro} = '2003';
    $padv->{name}   = "Windows Server ia64";
    return;
}

package Padv::WinVistax86;
@Padv::WinVistax86::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x86";
    $padv->{distro} = 'Vista';
    $padv->{name}   = "Windows Vista";
    return;
}

package Padv::WinVistax64;
@Padv::WinVistax64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = 'Vista';
    $padv->{name}   = "Windows Vista x64";
    return;
}

package Padv::Win2008x86;
@Padv::Win2008x86::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x86";
    $padv->{distro} = '2008';
    $padv->{name}   = "Windows Server 2008";
    return;
}

package Padv::Win2008x64;
@Padv::Win2008x64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = '2008';
    $padv->{name}   = "Windows Server 2008 x64";
    return;
}

package Padv::Win2008ia64;
@Padv::Win2008ia64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "ia64";
    $padv->{distro} = '2008';
    $padv->{name}   = "Windows Server 2008 ia64";
    return;
}

package Padv::Win7x86;
@Padv::Win7x86::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x86";
    $padv->{distro} = '7';
    $padv->{name}   = "Windows 7";
    return;
}

package Padv::Win7x64;
@Padv::Win7x64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = '7';
    $padv->{name}   = "Windows 7 x64";
    return;
}

package Padv::Win2012x64;
@Padv::Win2012x64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = '2012';
    $padv->{name}   = "Windows Server 2012 x64";
    return;
}

package Padv::Win8x86;
@Padv::Win8x86::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x86";
    $padv->{distro} = '8';
    $padv->{name}   = "Windows 8";
    return;
}

package Padv::Win8x64;
@Padv::Win8x64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = '8';
    $padv->{name}   = "Windows 8 x64";
    return;
}
package Padv::Windowsx64;
@Padv::Windowsx64::ISA = qw(Padv::Win);

sub init_padv {
    my $padv = shift;
    $padv->{arch}   = "x64";
    $padv->{distro} = '';
    $padv->{name}   = "Windows x64";
    return;
}
1;
