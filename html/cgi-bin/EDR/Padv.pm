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
use Padv::AIX;
use Padv::FreeBSD;
use Padv::HPUX;
use Padv::Linux;
use Padv::MacOS;
use Padv::Win;
use Padv::SunOS;

package Padv;
use strict;
use Obj;
@Padv::ISA = qw(Obj);

# Naming strategy is <plat><vers><arch> except for Linux where distro
# replaces plat and version mapping is required and Win where the
# version name becomes distro since #.# versions are insignificant
#
# current padv list
# CPI padv      SORT padv      plat    distro vers              arch
# AIX51         aix51          AIX     .      5.1               .
# AIX52         aix52          AIX     .      5.2               .
# AIX53         aix53          AIX     .      5.3               .
# AIX61         aix61          AIX     .      6.1               .
# AIX71         aix71          AIX     .      7.1               .
# FreeBSD60     -              FreeBSD .      6.0               .
# HPUX1123ia64  hpux1123       HPUX    .      11.23             ia64
# HPUX1131ia64  hpux1131       HPUX    .      11.31             ia64
# HPUX1111par   hpux1111       HPUX    .      11.11             9000/800
# HPUX1123par   hpux1123       HPUX    .      11.23             9000/800
# HPUX1131par   hpux1131       HPUX    .      11.31             9000/800
# MacOS105      -              MacOS   .      10.5              .
# MacOS106      -              MacOS   .      10.6              .
# Debian26      -              Linux   Debian 2.6.?             .
# ESX30i686     esx30_i686     Linux   ESX    3.0               i686
# ESX35i686     esx35_i686     Linux   ESX    3.5               i686
# RHEL4i686     rhel4_i686     Linux   RHEL   2.6.9             i686
# RHEL5i686     rhel5_i686     Linux   RHEL   2.6.18            i686
# RHEL6i686     rhel6_i686     Linux   RHEL   2.6.32            i686
# RHEL4x8664    rhel4_x86_64   Linux   RHEL   2.6.9             x86_64
# RHEL5x8664    rhel5_x86_64   Linux   RHEL   2.6.18            x86_64
# RHEL6x8664    rhel6_x86_64   Linux   RHEL   2.6.32            x86_64
# RHEL7x8664    rhel7_x86_64   Linux   RHEL   3.10.0            x86_64
# RHEL4ia64     rhel4_ia64     Linux   RHEL   2.6.9             ia64
# RHEL5ia64     rhel5_ia64     Linux   RHEL   2.6.18            ia64
# RHEL6ia64     -              Linux   RHEL   2.6.32            ia64
# RHEL4ppc64    rhel4_ppc64    Linux   RHEL   2.6.9             ppc64
# RHEL5ppc64    rhel5_ppc64    Linux   RHEL   2.6.18            ppc64
# RHEL6ppc64    -              Linux   RHEL   2.6.32            ppc64
# RHEL4s390x    -              Linux   RHEL   2.6.9             s390x
# RHEL5s390x    -              Linux   RHEL   2.6.18            s390x
# RHEL6s390x    -              Linux   RHEL   2.6.32            s390x
# CentOS5x8664  -              Linux   RHEL   2.6.18            x86_64
# CentOS6x8664  -              Linux   RHEL   2.6.32            x86_64
# OL5x8664      ol5_x86_64     Linux   OL     2.6.18            x86_64
# OL6x8664      ol6_x86_64     Linux   OL     2.6.32            x86_64
# OL7x8664      ol7_x86_64     Linux   OL     3.10.0            x86_64
# SLES9i686     sles9_i586     Linux   SLES   2.6.5             i686
# SLES10i686    sles10_i586    Linux   SLES   2.6.16,2.6.22     i686
# SLES11i686    sles11_i686    Linux   SLES   2.6.27            i686
# SLES12i686    sles12_i686    Linux   SLES   3.12.22           i686
# SLES9x8664    sles9_x86_64   Linux   SLES   2.6.5             x86_64
# SLES10x8664   sles10_x86_64  Linux   SLES   2.6.16,2.6.22     x86_64
# SLES11x8664   sles11_x86_64  Linux   SLES   2.6.27            x86_64
# SLES12x8664   sles12_x86_64  Linux   SLES   3.12.22           x86_64
# SLES9ia64     sles9_ia64     Linux   SLES   2.6.5             ia64
# SLES10ia64    sles10_ia64    Linux   SLES   2.6.16,2.6.22     ia64
# SLES11ia64    -              Linux   SLES   2.6.27            ia64
# SLES12ia64    sles12_ia64    Linux   SLES   3.12.22           ia64
# SLES9ppc64    sles9_ppc64    Linux   SLES   2.6.5             ppc64
# SLES10ppc64   sles10_ppc64   Linux   SLES   2.6.16,2.6.22     ppc64
# SLES11ppc64   sles11_ppc64   Linux   SLES   2.6.27            ppc64
# SLES12ppc64   sles12_ppc64   Linux   SLES   3.12.22           ppc64
# SLES9s390x    -              Linux   SLES   2.6.5             s390x
# SLES10s390x   -              Linux   SLES   2.6.16,2.6.22     s390x
# SLES11s390x   -              Linux   SLES   2.6.27            s390x
# SLES12s390x   sles12_s390x   Linux   SLES   3.12.22           s390x
# Sol8sparc     sol8_sparc     SunOS   .      5.8               sparc
# Sol9sparc     sol9_sparc     SunOS   .      5.9               sparc
# Sol10sparc    sol10_sparc    SunOS   .      5.10              sparc
# Sol10x64      sol10_x64      SunOS   .      5.10              i386
# Sol11sparc    sol11_sparc    SunOS   .      5.11              sparc
# Sol11x64      sol11_x64      SunOS   .      5.11              i386
# sort_padv does not map tightly for Windows padvs
# WinXPx86      -              Win     XP?    5.1               x86
# WinXPx64      -              Win     XP?    5.1               x64
# Win2003x86    -              Win     2003?  5.2               x86
# Win2003x64    -              Win     2003?  5.2               x64
# Win2003ia64   -              Win     2003?  5.2               ia64
# WinVistax86   -              Win     Vista? 6.0               x86
# WinVistax64   -              Win     Vista? 6.0               x64
# Win2008x86    -              Win     2008?  ?                 x86
# Win2008x64    -              Win     2008?  ?                 x64
# Win2008ia64   -              Win     2008?  ?                 ia64
# Win7x86       -              Win     7?     ?                 x86
# Win7x64       -              Win     7?     ?                 x64
# Win2012x64    -              Win     2012   6.2               x64
# Win8x86       -              Win     8      6.2               x86
# Win8x64       -              Win     8      6.2               x64

use constant {
    # Linux
    VIRT_KVM       => 'Linux KVM',
    VIRT_QEMU      => 'Qemu',
    VIRT_VIRTUALPC => 'Microsoft Virtual PC',
    VIRT_VMWARE    => 'VMware',
    VIRT_XEN       => 'Xen',
    # SunOS
    VIRT_LDOM      => 'Solaris LDoms',
    VIRT_GLOBAL_ZONE => 'Solaris global zone',
    VIRT_LOCAL_ZONE => 'Solaris local zone',
    # AIX
    VIRT_LPAR_DEDICATED => 'IBM Dedicated LPAR',
    VIRT_LPAR_SHARED => 'IBM LPAR with Shared Pool',
    # HPUX
    VIRT_VPAR      => 'HP-UX vPar',
    VIRT_IVM       => 'HP-UX IVM',
};

# called by EDR during EDR::init on $padvs arg
# called by CPIC and EDR objects during CPIC::discover_prod_padv
# after available padvs for selected prod have been correctly filtered
sub set_padv {
    my ($self,$padv,$padvisa)=@_;
    my $plus = ($padv=~/\+$/m) ? '+' : '';
    $padv=~s/\+//m;
    $padvisa=~s/\+//m;
    $self->{padv}||=$padv;
    push(@{$self->{padvs}}, $padv);
    $padvisa||=$padv;
    $self->{padvisa}{$padv}=$padvisa;
    $self->{padv_plat}{$padv}=EDRu::plat($padv);
    $self->{padv_distro}{$padv}=distro($padv);
    $self->{padv_distro2p}{$padv}=distro2p($padv);
    $self->{padv_arch}{$padv}=arch($padv);
    $self->{padv_vers}{$padv}=vers($padv);
    $self->{padv_unbounded}{$padv}=1 if ($plus);
    #printf "%s: plat=%s distro=%s distro2p=%s arch=%s vers=%s unbounded=%s\n",
    #    "$padv$plus", $self->{padv_plat}{$padv}, $self->{padv_distro}{$padv},
    #    $self->{padv_distro2p}{$padv}, $self->{padv_arch}{$padv},
    #    $self->{padv_vers}{$padv}, $self->{padv_unbounded}{$padv};
    return;
}

sub inherit_uplevel {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    return ($padv=~/Common/m) ?                   'Common' :
           ($padv=~/^AIX/m) ?                     'AIX' :
           ($padv=~/^FreeBSD/m) ?                 'FreeBSD' :
           ($padv=~/^HPUX(\d+)/m) ?               "HPUX$1" :
           ($padv=~/^(Debian|ESX|CentOS|OL|RHEL|SLES)/mx) ? 'Linux' :
           ($padv=~/^MacOS/m) ?                   'MacOS' :
           ($padv=~/^Sol\d+sparc/mx) ?            'SolSparc' :
           ($padv=~/^Sol\d+x64/m) ?               'Solx64' :
           ($padv=~/^SunOS/m) ?                   'SunOS' :
           ($padv=~/^Win/m) ?                     'Win' : '';
}

# only accepts a string now, add accepting a Padv object
# only accepts the current UxRT padvs now, expand to support all Unix/Linux
# there is a much bigger gap between Win padvs and sort_padvs to address if that's ever necessary
sub cpi_to_sort_padv {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    $padv=~s/Padv:://;
    my $sort_padv = $padv;
    if ( $padv =~ /^(RHEL|OL)([0-9]+)x8664/) {
        $sort_padv = "RHEL".$2."_x86_64";
    } elsif ( $padv =~ /^(RHEL[0-9]+)ppc64/) {
        $sort_padv = $1."_ppc64";
    } elsif ( $padv =~ /^(SLES[0-9]+)x8664/) {
        $sort_padv = $1."_x86_64";
    } elsif ( $padv =~ /^(SLES[0-9]+)ppc64/) {
        $sort_padv = $1."_ppc64";
    } elsif ( $padv =~ /^AIX(\d*)/) {
        $sort_padv = "AIX$1";
    } elsif ( $padv =~ /^Sol([0-9]*)sparc/) {
        $sort_padv = "sol$1_sparc";
    } elsif ( $padv =~ /^Sol([0-9]*)x64/) {
        $sort_padv = "sol$1_x64";
    } elsif ( $padv =~ /^HPUX1131/) {
        $sort_padv = "hpux1131";
    } elsif ($padv =~ /^HPUX1123/) {
        $sort_padv = "hpux1123";
    }

    return lc "$sort_padv";
}

sub sort_to_cpi_padv {
    my $sort_padv = shift;
    my $cpi_padv = $sort_padv;

    if ( $sort_padv =~ /^(rhel[0-9]+)_x86_64/) {
        $cpi_padv = uc($1)."x8664";
    } elsif ( $sort_padv =~ /^(rhel[0-9]+)_ppc64/) {
        $cpi_padv = uc($1)."ppc64";
    } elsif ( $sort_padv =~ /^(sles[0-9]+)_x86_64/) {
        $cpi_padv = uc($1)."x8664";
    } elsif ( $sort_padv =~ /^(sles[0-9]+)_ppc64/) {
        $cpi_padv = uc($1)."ppc64";
    } elsif ( $sort_padv =~ /^aix(\d*)/) {
        $cpi_padv = "AIX$1";
    } elsif ( $sort_padv =~ /^sol([0-9]*)_sparc/) {
        $cpi_padv = "Sol".$1."sparc";
    } elsif ( $sort_padv =~ /^sol([0-9]*)_x64/) {
        $cpi_padv = "Sol".$1."x64";
    } elsif ( $sort_padv =~ /^hpux/) {
        $cpi_padv = uc($sort_padv);
    }

    return $cpi_padv;
}

# we could map the above values into a 2d hash but this sub method
sub plat {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    return ($padv=~/Common/m) ?                   'Common' :
           ($padv=~/^AIX/m) ?                     'AIX' :
           ($padv=~/^FreeBSD/m) ?                 'FreeBSD' :
           ($padv=~/^HPUX/m) ?                    'HPUX' :
           ($padv=~/^(Debian|ESX|CentOS|OL|RHEL|SLES)/mx) ? 'Linux' :
           ($padv=~/^MacOS/m) ?                   'MacOS' :
           ($padv=~/^(Sol|SunOS)/mx) ?            'SunOS' :
           ($padv=~/^Win/m) ?                     'Win' :
           die("Cannot determine platform of padv $padv");
}

# need to convert distro strings on both sides to not display RHEL,SLES,ESX
sub distro {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    return ($padv=~/(Common|AIX|FreeBSD|HPUX|MacOS|Sol|SunOS)/mx) ? '' :
           ($padv=~/^RHEL/m)     ? 'RHEL' :
           ($padv=~/^SLES/m)     ? 'SLES' :
           ($padv=~/^Debian/m)   ? 'Debian' :
           ($padv=~/^CentOS/m)   ? 'CentOS' :
           ($padv=~/^OL/m)       ? 'OL' :
           ($padv=~/^ESX/m)      ? 'ESX' :
           ($padv=~/^WinXP/m)    ? 'XP' :
           ($padv=~/^Win2003/m)  ? '2003' :
           ($padv=~/^WinVista/m) ? 'Vista' :
           ($padv=~/^Win2008/m)  ? '2008' :
           ($padv=~/^Win7/m)     ? '7' :
           ($padv=~/^Win2012/m)  ? '2012' :
           ($padv=~/^Win8/m)     ? '8' :
               die("Cannot determine distro of padv $padv");
}

# for printing
sub distro2p {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    return ($padv=~/(Common|AIX|FreeBSD|HPUX|MacOS|Sol|SunOS)/mx) ? '' :
           ($padv=~/^RHEL/m) ?     'Red Hat' :
           ($padv=~/^SLES/m) ?     'SUSE' :
           ($padv=~/^Debian/m) ?   'Debian' :
           ($padv=~/^CentOS/m) ?   'CentOS' :
           ($padv=~/^OL/m) ?       'Oracle Linux' :
           ($padv=~/^ESX/m) ?      'VMware ESXi' :
           ($padv=~/^WinXP/m) ?    'Windows XP' :
           ($padv=~/^Win2003/m) ?  'Windows 2003' :
           ($padv=~/^WinVista/m) ? 'Windows Vista' :
           ($padv=~/^Win2008/m) ?  'Windows 2008' :
           ($padv=~/^Win7/m) ?     'Windows 7' :
           ($padv=~/^Win2012/m)  ? 'Windows 2012' :
           ($padv=~/^Win8/m)     ? 'Windows 8' :
           die("Cannot determine distro of padv $padv");
}

sub arch {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    return ($padv=~/(Common|AIX|Debian|FreeBSD|MacOS)/mx) ? '' :
           ($padv=~/^Win.*x86$/mx) ? 'x86' :
           ($padv=~/^Win.*x64$/mx) ? 'x86_64' :
           ($padv=~/par$/m) ?        '9000/800' :
           ($padv=~/ia64$/m) ?       'ia64' :
           ($padv=~/sparc$/m) ?      'sparc' :
           ($padv=~/x64$/m) ?        'i386' :
           ($padv=~/i386$/m) ?       'i386' :
           ($padv=~/i586$/m) ?       'i586' :
           ($padv=~/i686$/m) ?       'i686' :
           ($padv=~/x8664$/m) ?      'x86_64' :
           ($padv=~/ppc$/m) ?        'ppc' :
           ($padv=~/ppc64$/m) ?      'ppc64' :
           ($padv=~/390$/m) ?        '390' :
           ($padv=~/390x$/m) ?       '390x' :
               die("Cannot determine architecture of padv $padv");
}

sub vers {
    my $padv=shift;
    $padv=ref($padv) if (ref($padv));
    return ($padv=~/Common/m) ?     '' :
           ($padv eq 'AIX51') ?     '5.1' :
           ($padv eq 'AIX52') ?     '5.2' :
           ($padv eq 'AIX53') ?     '5.3' :
           ($padv eq 'AIX61') ?     '6.1' :
           ($padv eq 'AIX71') ?     '7.1' :
           ($padv eq 'Debian26') ?  '2.6' :
           ($padv=~/^ESX30/m) ?     '3.0' :
           ($padv=~/^ESX35/m) ?     '3.5' :
           ($padv eq 'FreeBSD60') ? '6.0' :
           ($padv=~/^HPUX1111/m) ?  '11.11' :
           ($padv=~/^HPUX1123/m) ?  '11.23' :
           ($padv=~/^HPUX1131/m) ?  '11.31' :
           ($padv=~/^MacOS105/m) ?  '10.5' :
           ($padv=~/^MacOS106/m) ?  '10.6' :
           ($padv=~/^RHEL4/m) ?     '2.6.9' :
           ($padv=~/^RHEL5/m) ?     '2.6.18' :
           ($padv=~/^RHEL6/m) ?     '2.6.32' :
           ($padv=~/^RHEL7/m) ?     '3.10.0' :
           ($padv=~/^CentOS5/m) ?   '2.6.18' :
           ($padv=~/^CentOS6/m) ?   '2.6.32' :
           ($padv=~/^OL5/m) ?       '2.6.18' :
           ($padv=~/^OL6/m) ?       '2.6.32' :
           ($padv=~/^OL7/m) ?       '3.10.0' :
           ($padv=~/^SLES9/m) ?     '2.6.5' :
           ($padv=~/^SLES10/m) ?    '2.6.16,2.6.22' :
           ($padv=~/^SLES11/m) ?    '2.6.27' :
           ($padv=~/^SLES12/m) ?    '3.12.22' :
           ($padv=~/^Sol8/m) ?      '5.8' :
           ($padv=~/^Sol9/m) ?      '5.9' :
           ($padv=~/^Sol10/m) ?     '5.10' :
           ($padv=~/^Sol11/m) ?     '5.11' :
           ($padv=~/^WinXP/m) ?     '5.1' :
           ($padv=~/^Win2003/m) ?   '5.2' :
           ($padv=~/^WinVista/m) ?  '6.0' :
           ($padv=~/^Win2008/m) ?   '6.0' :
           ($padv=~/^Win7/m) ?      '?' :
           ($padv=~/^Win2012/m) ?   '6.2' :
           ($padv=~/^Win8/m) ?      '6.2' :
               die("Cannot determine supported version of padv $padv");
}

sub init {
    my $self=shift;
    $self->init_plat;
    $self->init_padv;
    return;
}

sub init_plat { }
sub init_padv { }

# the following subs are used by rel_padv_sys in conjunction with Padv subs
# in order to the list of platform, arches, distros, and versions

# for Padv optional subroutine stubs
sub completion_messages { }
sub distro_sys { }
sub partially_installed_pkgs_sys { }
sub patches_sys { }
sub process_args { }
sub minorversion_sys { }
sub virtualization_sys { }
sub pkg_status_sys { return 1; }

sub cpu_number_sys { }
sub cpu_speed_sys { }
sub memory_size_sys { }
sub swap_size_sys { }

sub installcommand_precheck_sys { }

sub pkg_description_sys { }

sub pkg_version_cleanup {
    my ($padv,$vers)= @_;
    return $vers;
}

sub pkg_installtime_sys { }

# default routines for platforms using tar files
# the real work must be defined moving files from tmpdir to
# their correct location in $pkg->postinstall_sys if $pkg->{target} is not defined
sub tar_install_sys {
    my ($padv,$sys,$pkg) = @_;
    my ($target,$cmd,$tmpdir);
    $tmpdir=EDR::tmpdir();
    $target=$pkg->{target};
    $target||=EDR::tmpdir();
    # do we need to make the directory?

    # copy the package
    $padv->localsys->copy_to_sys($sys,$pkg->{file},$tmpdir);

    # gunzip and untar the file
    $sys->cmd("_cmd_gunzip $tmpdir/$pkg->{pkg}.tar.gz") if ($pkg->{file}=~/tar.gz$/m);
    $cmd = (($sys->{islocal}) && ($sys->{plat} eq 'FreeBSD')) ?
        "/bin/sh -c '_cmd_tar -xvf $tmpdir/$pkg->{pkg}.tar -C $target 2>/dev/null 1>/dev/null'" :
        "_cmd_tar -xvf $tmpdir/$pkg->{pkg}.tar -C $target";
    $sys->cmd($cmd);
    $sys->cmd("_cmd_rmr $tmpdir/$pkg->{pkg}.tar");
    EDR::cmd_local('_cmd_touch '.$pkg->copy_mark_sys($sys));
    return '';
}

sub media_tar_file {
    my ($padv,$pkg,$pkgdir)= @_;
    return '' unless ($pkgdir);
    for my $file("$pkgdir/$pkg->{pkg}.tar.gz",
                 "$pkgdir/$pkg->{pkg}.tgz") {
        return $file if (-e $file);
    }
    return '';
}

# To install/uninstall several packages batchly
sub pkgs_install_sys {}
sub pkgs_uninstall_sys {}

# for tar installations, leaving untar to pkg_copy_sys,
# install will be a sub and work moving the tar file pieces
# into the right place will be done in $pkg->postinstall_sys
sub pkg_install_sys { }

# anything that's not moved from the tarfile to its install location
# will be left behind, but eventually deleted in cleanup
sub pkg_remove_sys { }

# default passes for platforms using tar files
sub patch_install_success_sys { return 1; }
sub pkg_install_success_sys { return 1; }
sub pkg_uninstall_success_sys { return 1; }

sub is_pkg_require_reboot_sys { return 0; }

# verify an entered NIC is present on the system
sub is_nic_sys {
    my ($padv,$sys,$nic) = @_;
    return EDRu::isnic($nic);
}

# check if the NIC is RDMA capable
sub is_nic_rdma_capable_sys { return 0; }

sub nic_bcast_sys {}

sub procs_sys {
    my ($padv,$sys,$proc)= @_;
    my ($cmd);
    if ($proc) {
        $cmd="_cmd_ps -ef | _cmd_grep '$proc' | _cmd_grep -v grep | _cmd_grep -v defunct";
    } else {
        $cmd="_cmd_ps -ef";
    }
    return $sys->cmd($cmd);
}

sub pkg_allinstances_sys {
    my ($padv,$sys,$pkg)=@_;
    return [ $pkg->{pkgi} ];
}

# overrides in place for FreeBSD, MacOS for tarfiles, Win does nothing atm
sub pkgs_patches_sys {
    my ($padv,$sys) = @_;
    my ($script,$iv,$vpvd,$deps);
    $script=$padv->vrtspkgversdeps_script;
    if ($script) {
        Msg::log("vpvd.$sys->{plat} script:\n$script");
        $vpvd=$sys->cmd_script($script, "vpvd.$sys->{plat}", 'sh');
    }

    $sys->set_value('pkgverslist', undef);
    for my $pkg (split(/\n/,$vpvd)) {
        ($pkg,$iv,$deps)=split(/\s+/m,$pkg,3);
        $iv=$padv->pkg_version_cleanup($iv);
        if ($iv) {
            $sys->set_value("pkgvers,$pkg", $iv);
            $sys->set_value("pkgverslist,$pkg", 'push', $iv);
        }
        if ($deps) {
            $deps=join(' ', reverse(split(/\s+/m,$deps)))
                if ($sys->hpux());
            $sys->set_value("pkgdeps,$pkg", $deps);
        }
    }
    $sys->padv->partially_installed_pkgs_sys($sys);
    $sys->set_value('packages', 1);
    $sys->padv->patches_sys($sys);
    return '';
}

sub chown_root_sys {
    my ($padv,$sys,$file)=@_;
    # chown root:root on Solaris/HPUX/Linux
    return $sys->cmd("_cmd_chown -R root:root $file 2>/dev/null");
}

sub get_root_home_sys {
    my ($padv,$sys)=@_;
    my ($str_passwd,@array_passwd,$root_home);

    $str_passwd=$sys->cmd("_cmd_grep '^root:' /etc/passwd 2>/dev/null");
    # Filter out warning messages printed by ssh/rsh command.
    @array_passwd=grep {/^root:/m} split(/\n/,$str_passwd);
    if (! @array_passwd ) {
        Msg::log("No entry for root user found in /etc/passwd on $sys->{sys}");
    } else {
        if (scalar @array_passwd > 1 ) {
            Msg::log("More than one entries for root user found in /etc/passwd on $sys->{sys}");
        }
        $str_passwd=$array_passwd[0];
        if ($str_passwd) {
            @array_passwd=split(/:/m,$str_passwd);
            $root_home = $array_passwd[5];
        }
    }
    return $root_home;
}

sub verify_root_user {
    my $id=EDR::cmd_local('_cmd_id');
    if ($id !~ /^uid=0\(\w+\)/mx) {
        my $script=EDR::get('script');
        my $msg=Msg::new("$script must be run by a user with root ID");
        $msg->die;
    }
    # set umask 0022 for unified file permission
    umask 0022;
    return;
}

# kill a list of processes
# return a list of unkilled pids if kill failed
sub kill_pids_sys {
    my ($padv,$sys,@pids)=@_;
    my (@ukp,$pid,$ps,$pids);
    return [] unless (@pids);
    $pids=join(' ', @pids);
    $sys->cmd("_cmd_kill -9 $pids");
    sleep 1;
    for my $pid (@pids) {
        $ps=$sys->cmd("_cmd_ps -p $pid | _cmd_grep -v PID | _cmd_grep -v defunct");
        push(@ukp, $ps) if ($ps);
    }
    return \@ukp;
}

# find the child processes of the given pid
sub find_children_of_pid_sys {
    my ($padv,$sys,$pid) = (@_);
    my (@pids,$out);

    return [] if (!EDRu::isnum($pid));

    $out = $sys->cmd("_cmd_ps -ef | _cmd_awk '{if (\$3 == $pid) {print \$2}}'");
    for my $pid(split(/\n/, $out)) {
        push (@pids, @{find_children_of_pid_sys($padv,$sys,$pid)});
        push (@pids, $pid);
    }
    return \@pids;
}

# handling file and directory for Unix by default.
sub devnull { return '/dev/null'; }

sub rootdir { return '/'; }

sub filename_is_absolute {
    my ($padv,$file)=@_;
    return scalar($file=~ m{^/}s);
}

sub exists_sys {
    my ($padv,$sys,$file)=@_;
    my $ls=$sys->cmd("_cmd_ls -d $file 2>/dev/null");
    return ($ls) ? 1 : 0;
}

sub is_dir_sys {
    my ($padv,$sys,$dir)=@_;
    my $ls=$sys->cmd("_cmd_ls -ldL $dir 2>/dev/null");
    return (!EDR::cmdexit() && $ls =~ /^d/m) ? 1 : 0;
}

sub is_file_sys {
    my ($padv,$sys,$file)=@_;
    my $ls=$sys->cmd("_cmd_ls -ldL $file 2>/dev/null");
    return (!EDR::cmdexit() && $ls =~ /^-/m) ? 1 : 0;
}

sub is_symlink_sys {
    my ($padv,$sys,$symlink)=@_;
    my $ls=$sys->cmd("_cmd_ls -ld $symlink 2>/dev/null");
    return (!EDR::cmdexit() && $ls =~ /^l/m) ? 1 : 0;
}

sub is_executable_sys {
    my ($padv,$sys,$file)=@_;
    my $ls=$sys->cmd("_cmd_ls -ldL $file 2>/dev/null");
    return (!EDR::cmdexit() && $ls =~ /^-.{2}x/) ? 1 : 0;
}

sub catfile_sys {
    my ($padv,$sys,$file)=@_;
    my $rtn=$sys->cmd("_cmd_cat $file 2>/dev/null");
    return $rtn;
}

sub grepfile_sys {
    my ($padv,$sys,$word,$file)=@_;
    my $rtn=$sys->cmd("_cmd_grep $word $file 2>/dev/null");
    return $rtn;
}

sub lsfile_sys {
    my ($padv,$sys,$file)=@_;
    my $rtn=$sys->cmd("_cmd_ls $file 2>/dev/null");
    return $rtn;
}

sub readfile_sys {
    my ($padv,$sys,$file)=@_;
    my ($read,$base,$tmpdir,$tid,$localfile);
    $base=EDRu::basename($file);
    $tmpdir=EDR::get('tmpdir');
    $tid=Obj::tid() || 0;
    if ($^O =~ /Win32/i){
        $localfile="$tmpdir\\$base.$sys->{sys}.$tid";
    } else {
        $localfile="$tmpdir/$base.$sys->{sys}.$tid";
    }
    $sys->copy_to_sys($padv->localsys,$file,$localfile);
    $read=EDRu::readfile($localfile);
    unlink($localfile);
    return $read;
}

sub writefile_sys {
    my ($padv,$sys,$write,$file)=@_;
    my ($msg,$base,$tmpdir,$tid,$localfile);
    $base=EDRu::basename($file);
    $tmpdir=EDR::get('tmpdir');
    $tid=Obj::tid() || 0;
    $localfile="$tmpdir/$base.$sys->{sys}.$tid";
    EDRu::writefile($write,$localfile);
    $padv->localsys->copy_to_sys($sys,$localfile,$file);
    unlink($localfile);
    return;
}

sub appendfile_sys {
    my ($padv,$sys,$write,$file)=@_;
    my ($msg,$base,$tmpdir,$tid,$tmpfile);
    $base=EDRu::basename($file);
    $tmpdir=EDR::get('tmpdir');
    $tid=Obj::tid() || 0;
    $tmpfile="$tmpdir/$base.$tid.append";
    # e3566526 in case tmp dir is not created on $sys
    $padv->mkdir_sys($sys,$tmpdir);
    $padv->writefile_sys($sys,"$write\n",$tmpfile);
    $sys->cmd("_cmd_cat $file $tmpfile > $file.bak; _cmd_mv $file.bak $file");
    return;
}

sub createfile_sys {
    my ($padv,$sys,$file)=@_;
    $sys->cmd("_cmd_touch $file 2>/dev/null");
    return !EDR::cmdexit();
}

sub copyfile_sys {
    my ($padv,$sys,$source_file,$target_file)=@_;
    return 0 unless ($source_file && $target_file);

    $sys->cmd("_cmd_cp -rp $source_file $target_file 2>/dev/null");
    return !EDR::cmdexit();
}

sub movefile_sys {
    my ($padv,$sys,$source_file,$target_file)=@_;
    return 0 unless ($source_file && $target_file);

    $sys->cmd("_cmd_mv $source_file $target_file 2>/dev/null");
    return !EDR::cmdexit();
}

sub filestat_sys {
    my ($padv,$sys,$file)=@_;
    my ($ls,$mode,$owner,$group);
    my (%p0,%p1,%p2,%p3,%p4,%p5,%p6,%p7,%p8,@perms,$perm,$i,$c);

    $ls=$sys->cmd("_cmd_ls -ldL $file 2>/dev/null");
    return if (EDR::cmdexit());
    ($mode,undef,$owner,$group)=split(/\s+/m,$ls);

    # convert mode string, like -rwxr-xr-x-, to octal number string
    @p0{'-','r'} = ( 0, 400 );
    @p1{'-','w'} = ( 0, 200 );
    @p2{'-','x','s','S'} = ( 0, 100, 4100, 4000 );
    @p3{'-','r'} = ( 0, 40 );
    @p4{'-','w'} = ( 0, 20 );
    @p5{'-','x','s','l'} = ( 0, 10, 2010, 2000 );
    @p6{'-','r'} = ( 0, 4 );
    @p7{'-','w'} = ( 0, 2 );
    @p8{'-','x','t','T'} = ( 0, 1, 1001, 1000 );
    @perms = (\%p0,\%p1,\%p2,\%p3,\%p4,\%p5,\%p6,\%p7,\%p8);
    $perm = 0;
    $i = 0;
    while ($i <= 8) {
        $c = substr($mode, $i+1, 1 );
        $perm = $perm + $perms[$i]{$c};
        $i++;
    }

    return ["$perm","$owner","$group"];
}

sub change_filestat_sys {
    my ($padv,$sys,$file,$stat)=@_;
    my ($perm,$owner,$group)=@$stat;
    return 0 unless ($file && $perm && $owner && $group);

    $sys->cmd("_cmd_chmod $perm $file 2>/dev/null; _cmd_chown $owner:$group $file 2>/dev/null");
    return 1;
}

sub filesize_sys {
    my ($padv,$sys,$file)=@_;
    my $ls=$sys->cmd("_cmd_ls -ldL $file 2>/dev/null");
    my ($mode,undef,$owner,$group,$size)=split(/\s+/m,$ls);
    return $size;
}

sub chmod_sys {
    my ($padv,$sys,$file,$mode)=@_;
    return unless ($file && $mode);

    $sys->cmd("_cmd_chmod $mode $file 2>/dev/null");
    return !EDR::cmdexit();
}

sub mkdir_sys {
    my ($padv,$sys,$dir)=@_;
    return unless $dir;

    $sys->cmd("_cmd_mkdir -p $dir 2>/dev/null");
    return !EDR::cmdexit();
}

sub rm_sys {
    my ($padv,$sys,$file) = @_;
    return unless $file;

    $sys->cmd("_cmd_rmr $file 2>/dev/null");
    return !EDR::cmdexit();
}

sub timesync_sys {
    my ($padv,$sys,$ntpserver) = @_;

    $sys->cmd("/usr/sbin/ntpdate -u $ntpserver 2>&1");
    return !EDR::cmdexit();
}

sub nslookup_sys {
    my ($padv,$sys,$hostname)=@_;
    my ($nslookup,$fqdn,$ip);

    $hostname||=$sys->{sys};
    return unless $hostname;

    $nslookup=$sys->cmd("_cmd_nslookup -timeout=2 -retry=1 $hostname 2>/dev/null");
    for my $line (split(/\n+/,$nslookup)) {
        if ($line=~/name\s*=\s*(\S+)\.\s*$/mg) {
            $fqdn=$1;
            $ip=$hostname;
            return ($fqdn,$ip);
        } elsif ($line=~/Name:\s*(\S+)/mg) {
            $fqdn=$1;
        } elsif ($line=~/Address:\s*(\S+)/mg) {
            $ip=$1;
            return ($fqdn,$ip) if ($fqdn);
        }
    }
    return;
}

sub nb_padv {
    my $edr_padv=shift;
    my %nb_padv=(
            'Win2008x64' => 'AMD64',
            'Win2012x64' => 'AMD64',
            'WinXPx64' => 'AMD64',
            'Win2003x64' => 'AMD64',
            'WinVistax64' => 'AMD64',
            'Win7x64' => 'AMD64',
            'Win8x64' => 'AMD64',

            'WinXPx86' => 'x86',
            'Win2003x86' => 'x86',
            'WinVistax86' => 'x86',
            'Win2008x86' => 'x86',
            'Win7x86' => 'x86',
            'Win8x86' => 'x86',

            'AIX53' => 'rs6000',
            'AIX61' => 'rs6000',

            'FreeBSD53' => 'freebsd5.3',
            'FreeBSD60' => 'freebsd6.0',

            'HPUX1111par' => 'hp_ux',
            'HPUX1123par' => 'hp_ux',
            'HPUX1131par' => 'hp_ux',
            'HPUX1123ia64' => 'hpia64',
            'HPUX1131ia64' => 'hpia64',

            'MacOS105' => 'macosx10_5',
            'MacOS106' => 'macosx10_6',

            'RHEL4x8664' => 'linuxR_x86',
            'RHEL5x8664' => 'linuxR_x86',
            'RHEL6x8664' => 'linuxR_x86',
            'RHEL7x8664' => 'linuxR_x86',
            'RHEL5ia64' => 'linuxR_ia64',
            'RHEL6ia64' => 'linuxR_ia64',
            'RHEL4ppc64' => 'plinuxR_2.6',
            'RHEL5ppc64' => 'plinuxR_2.6',
            'RHEL6ppc64' => 'plinuxR_2.6',
            'RHEL4s390x' => 'zlinuxR',
            'RHEL5s390x' => 'zlinuxR',
            'RHEL6s390x' => 'zlinuxR',

            'SLES9x8664' => 'linuxS_x86',
            'SLES10x8664' => 'linuxS_x86',
            'SLES11x8664' => 'linuxS_x86',
            'SLES12x8664' => 'linuxS_x86',
            'SLES9ia64' => 'linuxS_ia64',
            'SLES10ia64' => 'linuxS_ia64',
            'SLES11ia64' => 'linuxS_ia64',
            'SLES12ia64' => 'linuxS_ia64',
            'SLES9ppc64' => 'plinuxS_2.6',
            'SLES10ppc64' => 'plinuxS_2.6',
            'SLES11ppc64' => 'plinuxS_2.6',
            'SLES12ppc64' => 'plinuxS_2.6',
            'SLES9s390x' => 'zlinuxS',
            'SLES10s390x' => 'zlinuxS',
            'SLES11s390x' => 'zlinuxS',
            'SLES12s390x' => 'zlinuxS',
            'Sol10sparc' => 'solaris',
            'Sol11sparc' => 'solaris',
            'Sol10x64' => 'solaris_x86',
            'Sol11x64' => 'solaris_x86',
    );

    return $nb_padv{$edr_padv} if (defined($nb_padv{$edr_padv}));
    EDR::die("No reciprocal NetBackup padv defined for edr padv $edr_padv");
}

sub file_modified_sys { return 1; }
sub pkg_verify_sys { return 1; }
sub media_allpkgs { }
sub configure_static_ip_sys { return 1; }

sub get_env_value_sys {
    my ($padv, $sys, $env) = @_;
    my $value = $sys->cmd("echo env | _cmd_su - | _cmd_grep '^$env=' 2>/dev/null");
    $value =~ s/$env=//m;
    return $value;
}

1;
