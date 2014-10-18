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
package Rel;

use strict;

# update the matrix data using sort webservice
sub update_matrix_data {
    my ($rel, $pseudo_hotfix, $noipc) = @_;
    my ($url, $response, $ret, $matrix_path_update, $matrix_path_in_installpath, $filename, $padv, $localsys);

    if ($noipc || ($rel->{sort_ready_for_vc} == 0)){
        return 1;
    }

    $padv = $rel->{padv_managed_host_for_vc};
    $matrix_path_update = $rel->{vc_matrix_path_update};
    $matrix_path_in_installpath = $rel->{matrix_path_in_installpath};
    $localsys=EDR::get('localsys');
    $localsys->mkdir($matrix_path_update);
    if ($matrix_path_in_installpath ne "") {
        $localsys->mkdir($matrix_path_in_installpath);
    }

#    EDRu::mkdir_local_nosys($matrix_path_update);

    foreach my $level (qw(ga patch hotfix)) {
        $url = CPIP::get_hotfix_sort_url();
        $url .= "?padv=$padv&level=$level";
        $url .= "&pseudo=1" if ($pseudo_hotfix);
        $response = EDRu::download_page($url);
        $response =~ s/[\n\r\t\f]+//mg;
        $response =~ s/^.*<pre>//mg;
        $response =~ s/<\/pre>.*$//mg;
        $response =~ s/(.*)}.*$/$1}/mg;

        return 1 if (!$response);
        $filename = "$matrix_path_update"."$padv-$level.json";
        EDRu::writefile("$response\n","$filename");
        $ret = 1 if (!-f $filename);

        if ($rel->{repos_set_for_vc}==1 && $matrix_path_in_installpath ne "") {
            $filename = "$matrix_path_in_installpath"."$padv-$level.json";
            EDRu::writefile("$response\n","$filename");
            $ret = 1 if (!-f $filename);
        }

    }
    return $ret;
}

# checking the version for all prods more than the prod
# checking more than it needs to, for instance, 5.1 does not need to check 5.1SP1 but nbd
sub check_native_hotfixes {
    my ($rel, $sys)=@_;
    my (%checked, $padv, $hotfix_type);
    return if ($#{$sys->{patches}}<0);

    $padv = $rel->{padv_managed_host_for_vc};

    for my $prod (sort keys %{$sys->{iprod}}) {
        my $prod_version = $sys->{iprod}{$prod}{mprpvers};
        my @ihotfixes;
        for my $hotfixid ( keys(%{$rel->{vc_hotfix_matrix_data}{$padv}})) {
            $hotfix_type = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{release_type};
            next if ($hotfix_type ne "pHF" && $hotfix_type ne "P" && $hotfix_type ne "HF");
            my @products = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{products});
            next if (!EDRu::inarr($prod,@products));
            next if ($checked{$hotfixid});
            $checked{$hotfixid}=1;
            my @patches=keys(%{$rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{patch}});
            next if ($#patches<0);
            my $inst=1;
            for my $patch(@patches) {
                if (!EDRu::inarr($patch, @{$sys->{patches}})){
                    $inst=0;
                    last;
                }
            }
            if ($inst) {
                push @ihotfixes, $hotfixid;
            }
        }
        $sys->{iprod}{$prod}{ihotfixes} = \@ihotfixes;
    }
    return;
}

sub check_pkg_hotfixes {
    my ($rel, $sys)=(@_);
    my (%checked, $padv, $hotfix_type);
    my (@items, $temp_ver, $i);

    $padv = $rel->{padv_managed_host_for_vc};

    for my $prod(keys(%{$sys->{iprod}})) {
        my $prod_version = $sys->{iprod}{$prod}{mprpvers};
        my @ihotfixes;
        for my $hotfixid ( keys(%{$rel->{vc_hotfix_matrix_data}{$padv}})) {
            $hotfix_type = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{release_type};
            next if ($hotfix_type ne "pHF" && $hotfix_type ne "P" && $hotfix_type ne "HF");
            my @products = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{products});
            next if (!EDRu::inarr($prod,@products));
            next if ($checked{$hotfixid});
            $checked{$hotfixid}=1;
            my @patches=keys(%{$rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{patch}});
            next if ($#patches<0);
            my $inst=1;
            for my $patch (@patches) {
                my ($patch_pkg, $patch_pkg_ver);
                $patch_pkg = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{patch}{$patch}{pkgs}[0];
                if (!$sys->{pkgvers}{$patch_pkg}){
                    $inst = 0;
                    last;
                }
                $patch_pkg_ver = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfixid}{patch}{$patch}{version};
                if ($padv=~/aix/){
                    @items = split (/\./, $patch_pkg_ver);
                    $temp_ver = "";
                    for ($i=0;$i<=$#items;$i++){
                        $items[$i] =~ s/^0+//;
                        $items[$i] = 0 unless ($items[$i]);
                        $temp_ver = $temp_ver.".".$items[$i];
                    }
                    $temp_ver =~ s/^\.//;
                    $patch_pkg_ver = $temp_ver;
                }
                if ($sys->{pkgvers}{$patch_pkg} ne $patch_pkg_ver) {
                    $inst = 0;
                    last;
                }
            }
            if ($inst) {
                push @ihotfixes, $hotfixid;
            }
        }
        $sys->{iprod}{$prod}{ihotfixes} = \@ihotfixes;
    }
    return;
}

sub check_installed_P_hotfix_sys {
    my ($rel, $sys)=@_;
    my ($padv, $native_patch_padvs);

    $padv = $rel->{padv_managed_host_for_vc};
    $native_patch_padvs = [ qw(hpux1123 hpux1131 sol8_sparc sol9_sparc sol10_sparc sol10_x64) ];

    if (EDRu::inarr($padv, @$native_patch_padvs)) {
        $rel->check_native_hotfixes($sys);
    } else {
        $rel->check_pkg_hotfixes($sys);
    }
    return;
}


# do we die on any unsupported or undetectable (Linux arch/vers) element?
# move out

sub get_padv_for_vc {
    my ($rel,$sys)=(@_);
    my ($padv,$sort_padv);

    $padv = $sys->{padv};
    if ( $padv =~ /^(RHEL[0-9]+)x8664/) {
        $sort_padv = $1."_x86_64";
    } elsif ( $padv =~ /^(SLES[0-9]+)x8664/) {
        $sort_padv = $1."_x86_64";
    } elsif ( $padv =~ /^AIX(\d*)/) {
        $sort_padv = "AIX$1";
    } elsif ( $padv =~ /^Sol([0-9]*)sparc/) {
        $sort_padv = "sol$1_sparc";
    } elsif ( $padv =~ /^Sol([0-9]*)x64/) {
        $sort_padv = "sol$1_x64";
    } elsif ( $padv =~ /^HPUX/) {
        $sort_padv = "hpux1131";
    }
    return lc "$sort_padv";
}

sub get_padv {
    my ($rel,$sys)=(@_);
    my $padv;
    my $arch=$sys->{arch};
    my $plat=$sys->{plat};
    my $vers=$sys->{platvers};
    if ($plat eq 'AIX') {
        # AIX does not recognize arch, always powerpc
        $vers=~s/\W//g;
        $padv = "aix$vers";
    } elsif ($plat eq 'HP-UX' or $plat eq 'HPUX') {
        # HP-UX padv currrently does not recognize arch, ia64 or pa
        my ($v1,$v2,undef)=split(/\./,$vers,3);
        $padv = "hpux$v1$v2";
    } elsif ($plat eq 'Linux') {
        # i586, i686, ia64, ppc64, and s390x arches are not supported
        my @v=split(/[.-]/, $vers);
        my $distro = ($v[2]==9)  ? 'rhel4' :
                     ($v[2]==18) ? 'rhel5' :
                     ($v[2]==32) ? 'rhel6' :
                     ($v[2]==5)  ? 'sles9' :
                     (($v[2]==16) || ($v[2]==22)) ? 'sles10' :
                     ($v[2]==27)  ? 'sles11' : "linux_2.6.$v[2]";
        $padv = $distro."_$arch";
    } elsif ($plat eq 'SunOS') {
        my (undef,$v,undef)=split(/\./,$vers,3);
        $v=10 if ($v==1);
        $arch='x64' if ($arch eq 'i386');
        $padv = "sol$v"."_$arch";
    } elsif ($plat eq 'Windows') {
        # do not know how to compute Windows
        $padv = 'Windows';
    }
    if ($padv) {
        return  $padv;
    } else {
        # _die("guid_padv: invalid plat $plat");
    }
    return;
}

sub init_releasematrix_vc{
    my ($rel)=@_;
    my ($matrix_path, $filename, $padv, @releases, $relname, $hotfixname);
    my ($ga_filename, $patch_filename, $hotfix_filename);

    $padv = $rel->{padv_managed_host_for_vc};
    if ($rel->{sort_ready_for_vc} == 0){
        $matrix_path = $rel->{matrix_path};
        if ($matrix_path) {
            $ga_filename = "$matrix_path"."$padv-ga.json";
            $patch_filename = "$matrix_path"."$padv-patch.json";
            $hotfix_filename = "$matrix_path"."$padv-hotfix.json";
            if ((-f $ga_filename) && (-f $patch_filename) && (-f $hotfix_filename)) {
                $rel->init_releasematrix($matrix_path,$padv);
            } else {
                if ($rel->{matrix_path_in_installpath}) {
                    $matrix_path = $rel->{matrix_path_in_installpath};
                    $ga_filename = "$matrix_path"."$padv-ga.json";
                    $patch_filename = "$matrix_path"."$padv-patch.json";
                    $hotfix_filename = "$matrix_path"."$padv-hotfix.json";
                    if ((-f $ga_filename) && (-f $patch_filename) && (-f $hotfix_filename)) {
                        $rel->init_releasematrix($matrix_path,$padv);
                    } else {
                        if ($rel->{matrix_path_in_prod}) {
                            $matrix_path = $rel->{matrix_path_in_prod};
                            $rel->init_releasematrix($matrix_path,$padv);
                        }
                    }
                }
            }
        } else {
            if ($rel->{matrix_path_in_installpath}) {
                $matrix_path = $rel->{matrix_path_in_installpath};
                $ga_filename = "$matrix_path"."$padv-ga.json";
                $patch_filename = "$matrix_path"."$padv-patch.json";
                $hotfix_filename = "$matrix_path"."$padv-hotfix.json";
                if ((-f $ga_filename) && (-f $patch_filename) && (-f $hotfix_filename)) {
                    $rel->init_releasematrix($matrix_path,$padv);
                } else {
                    if ($rel->{matrix_path_in_prod}) {
                        $matrix_path = $rel->{matrix_path_in_prod};
                        $rel->init_releasematrix($matrix_path,$padv);
                    }
                }
            }
        }
    } else {
        $matrix_path = $rel->{vc_matrix_path_update};
        $rel->init_releasematrix($matrix_path,$padv);
    }

    foreach my $rel_id (keys %{$rel->{vc_release_matrix_data}{$padv}}){
        $relname = $rel->{vc_release_matrix_data}{$padv}{$rel_id}{release_version};
        $rel->{relname_to_vers_level}{$relname}{vers_level} = $rel->{vc_release_matrix_data}{$padv}{$rel_id}{vers_level};
        $rel->{relid_to_relname}{$rel_id}{relname} = $relname;
        $rel->{relname_to_relid}{$relname}{relid} = $rel_id;
    }
    foreach my $rel_id (keys %{$rel->{vc_patch_matrix_data}{$padv}}){
        $relname = $rel->{vc_patch_matrix_data}{$padv}{$rel_id}{release_version};
        $rel->{relname_to_vers_level}{$relname}{vers_level} = $rel->{vc_patch_matrix_data}{$padv}{$rel_id}{vers_level};
        $rel->{relid_to_relname}{$rel_id}{relname} = $relname;
        $rel->{relname_to_relid}{$relname}{relid} = $rel_id;
    }
    foreach my $hotfix_id (keys %{$rel->{vc_hotfix_matrix_data}{$padv}}){
        $hotfixname = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfix_id}{release_version};
        $rel->{hotfixname_to_vers_level}{$hotfixname}{vers_level} = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfix_id}{vers_level};
        $rel->{hotfixid_to_hotfixname}{$hotfix_id}{hotfixname} = $hotfixname;
        $rel->{hotfixname_to_hotfixid}{$hotfixname}{hotfixlid} = $hotfix_id;
    }

    @releases = sort { $rel->{relname_to_vers_level}{$a}{vers_level} cmp $rel->{relname_to_vers_level}{$b}{vers_level} } keys(%{$rel->{relname_to_vers_level}});
    $rel->{releases} = \@releases;

#    $rel_keys = $rel->{vc_patch_matrix_data}{$padv};
#    @releases = sort keys $rel_keys;
#    $rel->{releases} = \@releases;
#AIX
    if ($padv =~ /aix/) {
        $rel->{pkgtopobj}{VRTScpi}    = 'VRTScpi.rte';
        $rel->{pkgtopobj}{VRTSvcsw}   = 'VRTSvcsw.rte';
        $rel->{pkgtopobj}{VRTSvrw}    = 'VRTSvrw.rte';
        $rel->{pkgtopobj}{VRTSjre}    = 'VRTSjre.rte';
        $rel->{pkgtopobj}{VRTSacclib} = 'VRTSacclib.rte';
        $rel->{pkgtopobj}{VRTScmccc}  = 'VRTScmccc.rte';
        $rel->{pkgtopobj}{VRTScmcs}   = 'VRTScmcs.rte';
        $rel->{pkgtopobj}{VRTScscm}   = 'VRTScscm.rte';
        $rel->{pkgtopobj}{VRTScscw}   = 'VRTScscw.rte';
        $rel->{pkgtopobj}{VRTScsocw}  = 'VRTScsocw.rte';
        $rel->{pkgtopobj}{VRTScssim}  = 'VRTScssim.rte';
        $rel->{pkgtopobj}{VRTScutil}  = 'VRTScutil.rte';
        $rel->{pkgtopobj}{VRTSdbac}   = 'VRTSdbac.rte';
        $rel->{pkgtopobj}{VRTSgab}    = 'VRTSgab.rte';
        $rel->{pkgtopobj}{VRTSgapms}  = 'VRTSgapms.VRTSgapms';
        $rel->{pkgtopobj}{VRTSjre15}  = 'VRTSjre15.rte';
        $rel->{pkgtopobj}{VRTSllt}    = 'VRTSllt.rte';
        $rel->{pkgtopobj}{VRTSperl}   = 'VRTSperl.rte';
        $rel->{pkgtopobj}{VRTSvail}   = 'VRTSvail.VRTSvail';
        $rel->{pkgtopobj}{VRTSvcsag}  = 'VRTSvcsag.rte';
        $rel->{pkgtopobj}{VRTSvcsdb}  = 'VRTSvcsdb.rte';
        $rel->{pkgtopobj}{VRTSvcsdc}  = 'VRTSvcs.doc';
        $rel->{pkgtopobj}{VRTSvcsmg}  = 'VRTSvcs.msg.en_US';
        $rel->{pkgtopobj}{VRTSvcsmn}  = 'VRTSvcs.man';
        $rel->{pkgtopobj}{VRTSvcsor}  = 'VRTSvcsor.rte';
        $rel->{pkgtopobj}{VRTSvcs}    = 'VRTSvcs.rte';
        $rel->{pkgtopobj}{VRTSvdid}   = 'VRTSvdid.rte';
        $rel->{pkgtopobj}{VRTSvxfen}  = 'VRTSvxfen.rte';
        $rel->{pkgtopobj}{VRTSweb}    = 'VRTSweb.rte';
    }
#Linux
    if ($padv =~ /rhel|sles/) {
        $rel->{pkgtopobj}{VRTSd2guicommon}  = 'VRTSd2gui-common';
        $rel->{pkgtopobj}{VRTSd2webcommon}  = 'VRTSd2web-common';
        $rel->{pkgtopobj}{VRTSdb2edcommon}  = 'VRTSdb2ed-common';
        $rel->{pkgtopobj}{VRTSdbcomcommon}  = 'VRTSdbcom-common';
        $rel->{pkgtopobj}{VRTSdbedcommon}   = 'VRTSdbed-common';
        $rel->{pkgtopobj}{VRTSmaprocommon}  = 'VRTSmapro-common';
        $rel->{pkgtopobj}{VRTSodmcommon}    = 'VRTSodm-common';
        $rel->{pkgtopobj}{VRTSodmplatform}  = 'VRTSodm-platform';
        $rel->{pkgtopobj}{VRTSorguicommon}  = 'VRTSorgui-common';
        $rel->{pkgtopobj}{VRTSorwebcommon}  = 'VRTSorweb-common';
        $rel->{pkgtopobj}{VRTSsybedcommon}  = 'VRTSsybed-common';
        $rel->{pkgtopobj}{VRTSvxfscommon}   = 'VRTSvxfs-common';
        $rel->{pkgtopobj}{VRTSvxfsplatform} = 'VRTSvxfs-platform';
        $rel->{pkgtopobj}{VRTSvxvmcommon}   = 'VRTSvxvm-common';
        $rel->{pkgtopobj}{VRTSvxvmplatform} = 'VRTSvxvm-platform';
    }
    return;
}

sub get_fallback_releases {
    my ($rel, $mpvers) = @_;
    my ($majorvers, $release, @releases, $rellvl, $relnum);

    $majorvers = $rel->get_major_vers($mpvers);

    @releases = ();

# this is temporary workaround
    if ($mpvers eq "6.0.3") {
        my $temp_release = "6.0.1";
        push @releases, $temp_release;
    }

    if ($mpvers eq "6.0.2") {
        my $temp_release = "6.0.1";
        push @releases, $temp_release;
    }
    
    if ($mpvers eq "6.1.1") {
        my $temp_release = "6.1";
        push @releases, $temp_release;
    }


    $release = $mpvers;
    while ($release && $release !~ /^\d+\.\d*$/mx && $release !~ /^\d+$/mx && $release ne $majorvers) {
        if ( $release =~ /_/mx) {
            $release =~ s/_.*$//mx;
        } elsif ($release =~ /[^\d]+$/ ) {
            $release =~ s/[^\d]+$//mx;
        } else {
            $rellvl = $release;
            $relnum = $release;
            $rellvl =~ s/\d+$//mx;
            $relnum =~ s/^.*[a-zA-Z](\d+)$/$1/mx;
            if ( ! $relnum || $relnum == 0 ) {
                $release = $rellvl;
                $release =~ s/[a-zA-Z]+$//mx;
            } else {
                $relnum--;
                $release = "$rellvl"."$relnum";
            }
        }
        push @releases, $release;
        last if (scalar @releases > 32);
    }
    return @releases;
}

sub get_prod_required_pkgs {
    my ($rel, $prod, $mpvers) = @_;
    my (@requiredpkgs, $release, $padv, $rel_id);

    $padv = $rel->{padv_managed_host_for_vc};

    if ( $prod eq "at" ) {
        return $rel->get_at_required_pkgs($mpvers,$padv);
    }
    $rel_id = $rel->{relname_to_relid}{$mpvers}{relid};
    if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id})
        && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod})
        && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
        @requiredpkgs = @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
    } elsif (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id})
        && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod})
        && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
        @requiredpkgs = @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
    } else {
        for my $release ($rel->get_fallback_releases($mpvers)) {
            $rel_id = $rel->{relname_to_relid}{$release}{relid};
            if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id})
                && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod})
                && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
                @requiredpkgs = @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
                last;
            }
            if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id})
                && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod})
                && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
                @requiredpkgs = @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
                last;
            }
        }
    }
    return EDRu::arruniq(sort @requiredpkgs);
}

sub get_prod_optional_pkgs {
    my ($rel, $prod, $mpvers) = @_;
    my (@optionalpkgs, $release, $padv, $rel_id);

    $padv = $rel->{padv_managed_host_for_vc};
    @optionalpkgs = ();
    if ( $prod eq "at" ) {
        return $rel->get_at_optional_pkgs($mpvers,$padv);
    }
    $rel_id = $rel->{relname_to_relid}{$mpvers}{relid};
    if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id})
        && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod})
        && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
        @optionalpkgs = @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
    } elsif (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id})
        && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod})
        && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
        @optionalpkgs = @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
    } else {
        for my $release ($rel->get_fallback_releases($mpvers)) {
            $rel_id = $rel->{relname_to_relid}{$release}{relid};
            if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id})
                && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod})
                && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
                @optionalpkgs = @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
                last;
            }
            if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id})
                && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod})
                && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
                @optionalpkgs = @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
                last;
            }
        }
    }
    return EDRu::arruniq(sort @optionalpkgs);
}

sub get_prod_all_pkgs {
    my ($rel, $prod, $mpvers) = @_;
    my (@allpkgs, $release, $padv, $rel_id);

    $padv = $rel->{padv_managed_host_for_vc};

    if ( $prod eq "at" ) {
        return $rel->get_at_all_pkgs($mpvers,$padv);
    }
    $rel_id = $rel->{relname_to_relid}{$mpvers}{relid};
    if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id})
        && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod})
        && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
        push @allpkgs, @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
        push @allpkgs, @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
    } elsif (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id})
        && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod})
        && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
        push @allpkgs, @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
        push @allpkgs, @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
    } else {
        for my $release ($rel->get_fallback_releases($mpvers)) {
            $rel_id = $rel->{relname_to_relid}{$release}{relid};
            if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id})
                && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod})
                && exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
                push @allpkgs, @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
                push @allpkgs, @{$rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
                last;
            }
            if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id})
                && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod})
                && exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod})) {
                push @allpkgs, @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{rpkgs}};
                push @allpkgs, @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}} if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{prod}{$prod}{opkgs}));
                last;
            }
        }
    }
    return EDRu::arruniq(sort @allpkgs);
}

sub get_rel_pkgs_mapping_patches {
    my ($rel, $relvers, $pkgs, $osvers) = @_;
    my ($pkg, $patch, $padv, @patches, @supp_osvers, $rel_id);

    $padv = $rel->{padv_managed_host_for_vc};
    $rel_id = $rel->{relname_to_relid}{$relvers}{relid};
    for my $patch (keys %{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{patch}}) {
        if ($osvers) {
            # Solaris allows undefined {osvers} values which default to ALL (5.8 5.9 5.10)
            @supp_osvers = qw(5.8 5.9 5.10);
            if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{patch}{$patch}{osvers})) {
                @supp_osvers = @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{patch}{$patch}{osvers}};
            }
            next unless (EDRu::inarr($osvers, @supp_osvers));
        }
        for my $pkg (@{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{patch}{$patch}{pkgs}}) {
            push @patches, $patch if (EDRu::inarr($pkg, @{$pkgs}));
        }
    }
    return EDRu::arruniq(sort @patches);
}

sub get_rel_pkgs_mapping_patches_sfsybasece {
    my ($rel, $relvers, $pkgs, $osvers) = @_;
    my ($pkg, $patch, $padv, @patches, @supp_osvers, $rel_id);

    $padv = $rel->{padv_managed_host_for_vc};
    $rel_id = $rel->{relname_to_relid}{$relvers}{relid};
    for my $patch (keys %{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{sfsybasece_patch}}) {
        if ($osvers) {
            # Solaris allows undefined {osvers} values which default to ALL (5.8 5.9 5.10)
            @supp_osvers = qw(5.8 5.9 5.10);
            if (exists($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{sfsybasece_patch}{$patch}{osvers})) {
                @supp_osvers = @{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{sfsybasece_patch}{$patch}{osvers}};
            }
            next unless (EDRu::inarr($osvers, @supp_osvers));
        }
        for my $pkg (@{$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{sfsybasece_patch}{$patch}{pkgs}}) {
            push @patches, $patch if (EDRu::inarr($pkg, @{$pkgs}));
        }
    }
    return EDRu::arruniq(sort @patches);
}

sub mp_sp_ru {
    my ($rel,$mpvers) = @_;
    if ($mpvers =~ /^.*(MP|SP|RU)\d+/mx) {
        $mpvers = $&;
    }
    return $mpvers;
}

sub check_prods_install_status_sys {
    my ($rel, $sys) = @_;
    my ($prod, $mainpkg, $majorvers, $mpvers, $mprpvers, $platvers,$prod_lic);
    my (@releases, @reversed_releases, $idx, $pos1, $pos2, $relvers, $prodname);
    my ($allpkgs,$patch,$patches,$patchid,$patchvers,%count,$pkg,$obpatch,$oldpatch);
    my (@mainpkgs,$tmp_majorvers, $tmp_mpvers, $tmp_mprpvers, $defined_vers, @relpatches, $patchdefs);
    my ($padv, $hotfix_t, $current_version, $ihotfixes, @items, $alreadyin, $cksum, $uploadfilename, $type);

    $padv = $rel->{padv_managed_host_for_vc};

    @releases = @{$rel->{releases}};
    @reversed_releases = reverse @releases;
    $platvers = ($sys->sunos()) ? $sys->{platvers} : '';

    for my $prod (sort keys %{$sys->{iprod}}) {
        $majorvers = '';
        $mpvers = '';
        $mprpvers = '';
        @mainpkgs = split(/\s/m, $sys->{iprod}{$prod}{imainpkg});

        for my $mainpkg (@mainpkgs) {

            #use version of VRTSvcsvmx as prod version for appha
            next if ($prod eq 'appha' && $mainpkg ne 'VRTSvcsvmw');

            # check major version of installed prod
            $tmp_majorvers = $rel->get_major_vers($sys->{pkgvers}{$mainpkg});

            # check mp version of installed prod
            $tmp_mpvers = $rel->pkg_inst_mpvers_sys($sys, $mainpkg);

            # check mprp version of installed prod
            $tmp_mprpvers = $rel->pkg_inst_mprpvers_sys($sys, $mainpkg);

            #PR3 release is only for svs
            if ($tmp_mprpvers eq '5.1SP1PR3RP3' && $prod ne 'svs') {
                $tmp_mprpvers = '5.1SP1RP3';
            }

            # always use the latest version of all mainpkgs.
            if ( $majorvers eq '' || $majorvers < $tmp_majorvers ) {
                $majorvers = $tmp_majorvers;
                $mpvers = $tmp_mpvers;
                $mprpvers = $tmp_mprpvers;
            } elsif (($majorvers eq $tmp_majorvers) && ($mpvers eq '' || EDRu::arrpos($mpvers, @releases) < EDRu::arrpos($tmp_mpvers, @releases) || (EDRu::arrpos($mpvers, @releases) == EDRu::arrpos($tmp_mpvers, @releases)&& $mpvers lt $tmp_mpvers))) {
                $mpvers = $tmp_mpvers;
                $mprpvers = $tmp_mprpvers;
            } elsif (($majorvers eq $tmp_majorvers && $mpvers eq $tmp_mpvers) && ($mprpvers eq '' || EDRu::arrpos($mprpvers, @releases) < EDRu::arrpos($tmp_mprpvers, @releases) || (EDRu::arrpos($mprpvers, @releases) == EDRu::arrpos($tmp_mprpvers, @releases) && $mprpvers lt $tmp_mprpvers ))) {
                $mprpvers = $tmp_mprpvers;
            }
        }

        # check mprp version from installed patches for SunOS/HP-UX
        if ( ($sys->sunos() && $sys->{padv} !~ /Sol11/) || $sys->hpux() ) {
            $tmp_mprpvers = undef;
            for my $relvers (@reversed_releases) {
                next unless ($relvers =~ /^$majorvers/);
                if ($prod eq 'sfsybasece' && $majorvers eq '5.0' ) {
                    @relpatches = keys %{$rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$relvers}{relid}}{sfsybasece_patch}};
                } else {
                    @relpatches = keys %{$rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$relvers}{relid}}{patch}};
                }

                for my $patch (@relpatches) {
                    if (EDRu::inarr($patch, @{$sys->{patches}})){
                        # Check if this patch is also used in previous release
                        for (my $idx=EDRu::arrpos($relvers, @reversed_releases)+1;$idx<=$#reversed_releases;$idx++) {
                            if($rel->{rel}{$reversed_releases[$idx]}{patch}{$patch}) {
                                $oldpatch=1;
                                last;
                            }
                        }
                        if ($oldpatch) {
                            undef $oldpatch;
                            next;
                        }
                        $tmp_mprpvers = $relvers;
                        last;
                    }
                }

                if ($tmp_mprpvers) {
                    last;
                }
            }

            if ( $mprpvers eq '' || EDRu::arrpos($mprpvers, @releases) < EDRu::arrpos($tmp_mprpvers, @releases) || (EDRu::arrpos($mprpvers, @releases) == EDRu::arrpos($tmp_mprpvers, @releases) && $mprpvers lt $tmp_mprpvers )) {
                $mprpvers = $tmp_mprpvers;
            }
        }

        # reset mpvers by mprpvers
        $mpvers=$rel->mp_sp_ru($mprpvers);

        $prod_lic = $rel->prod_licensed_sys($sys,uc($prod) ."61");
        if (($prod eq "sf") && ($prod_lic =~ /SFBasic/i)) {
            $prod_lic=join "_", (split /\s+/, $prod_lic);
        }

        # check name of installed prod
        if (exists($rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}})
            && exists($rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}}{prod})
            && exists($rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}}{prod}{$prod})) {
            $prodname = $rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}}{prod}{$prod}{name};
        } elsif (exists($rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}})
            && exists($rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}}{prod})
            && exists($rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}}{prod}{$prod})) {
            $prodname = $rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$mpvers}{relid}}{prod}{$prod}{name};
        } elsif (exists($rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$majorvers}{relid}})
            && exists($rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$majorvers}{relid}}{prod})
            && exists($rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$majorvers}{relid}}{prod}{$prod})) {
            $prodname = $rel->{vc_release_matrix_data}{$padv}{$rel->{relname_to_relid}{$majorvers}{relid}}{prod}{$prod}{name};
        } else {
            $prodname = $rel->get_common_prodname($prod);
        }

        # set name, major vers, mp vers, mprp vers of installed product
        $sys->{iprod}{$prod}{name} = $prodname;
        $sys->{iprod}{$prod}{mjvers} = $majorvers;
        $sys->{iprod}{$prod}{mpvers} = $mpvers;
        $sys->{iprod}{$prod}{mprpvers} = $mprpvers;
        $sys->{iprod}{$prod}{license} = $prod_lic;

        # check if the packages is defined for product with mpvers/majorvers
        $defined_vers=$mprpvers;
        if (!@{$rel->get_prod_all_pkgs($prod, $defined_vers)}) {
            $defined_vers=$mpvers;
            if ( !@{$rel->get_prod_all_pkgs($prod, $defined_vers)}) {
                $sys->{iprod}{$prod}{unsupport} = 1;
                next;
            }
        }

        $sys->{iprod}{$prod}{defined_vers} = $defined_vers;

        # check installed/missing required packages of prod
        for my $pkg (sort @{$rel->get_prod_required_pkgs($prod, $defined_vers)}) {
            if ($sys->aix()) {
                if ($pkg eq "VRTSat") {
                    if ($sys->{pkgvers}{'VRTSat.client'} && $sys->{pkgvers}{'VRTSat.server'}) {
                        push @{$sys->{iprod}{$prod}{irpkgs}}, $pkg;
                    } else {
                        push @{$sys->{iprod}{$prod}{mrpkgs}}, $pkg;
                    }
                    next;
                }
                if ($rel->{pkgtopobj}{$pkg}
                    && $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}}) {
                    push @{$sys->{iprod}{$prod}{irpkgs}}, $pkg;
                    next;
                }
            }
            if ($sys->linux()) {
                if (exists($rel->{pkgtopobj}{$pkg})
                    && $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}}) {
                    push @{$sys->{iprod}{$prod}{irpkgs}}, $pkg;
                    next;
                }
            }
            if ($sys->hpux() && ($sys->{padv} eq 'HPUX1131par') && $sys->{iprod}{$prod}{mjvers} =~ /6\./m) {
                if ($pkg eq "VRTSfsadv"){
                    next;
                }
            }
            $sys->{pkgvers}{$pkg} ? push @{$sys->{iprod}{$prod}{irpkgs}}, $pkg :
                                    push @{$sys->{iprod}{$prod}{mrpkgs}}, $pkg;
        }

        # check installed/missing optional packages of prod
        for my $pkg (sort @{$rel->get_prod_optional_pkgs($prod, $defined_vers)}) {
            if ($sys->aix()) {
                if ($pkg eq "VRTSat") {
                    if ($sys->{pkgvers}{'VRTSat.client'} && $sys->{pkgvers}{'VRTSat.server'}) {
                        push @{$sys->{iprod}{$prod}{irpkgs}}, $pkg;
                    } else {
                        push @{$sys->{iprod}{$prod}{mrpkgs}}, $pkg;
                    }
                    next;
                }
                if ($rel->{pkgtopobj}{$pkg}
                    && $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}}) {
                    push @{$sys->{iprod}{$prod}{iopkgs}}, $pkg;
                    next;
                }
            }
            if ($sys->linux()) {
                if (exists($rel->{pkgtopobj}{$pkg})
                    && $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}}) {
                    push @{$sys->{iprod}{$prod}{iopkgs}}, $pkg;
                    next;
                }
            }
            if ($sys->hpux() && ($sys->{padv} eq 'HPUX1131par') && $sys->{iprod}{$prod}{mjvers} =~ /6\./m) {
                if ($pkg eq "VRTSfsadv"){
                    next;
                }
            }
            $sys->{pkgvers}{$pkg} ? push @{$sys->{iprod}{$prod}{iopkgs}}, $pkg :
                                    push @{$sys->{iprod}{$prod}{mopkgs}}, $pkg;
        }

        next if ($sys->aix() || $sys->linux());

        # check installed/missing patches of prod for each release
        $count{$prod} = {};
        $allpkgs = $rel->get_prod_all_pkgs($prod, $defined_vers);
        $pos1 = EDRu::arrpos($mprpvers, @reversed_releases);
        $pos2 = EDRu::arrpos($mpvers, @reversed_releases);
        for my $idx ($pos1 .. $pos2) {
            $relvers = $reversed_releases[$idx];
            if ($prod eq 'sfsybasece' && $majorvers eq '5.0' ) {
                $patches = $rel->get_rel_pkgs_mapping_patches_sfsybasece($relvers, $allpkgs, $platvers);
                $patchdefs = $rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$relvers}{relid}}{sfsybasece_patch};
            } else {
                $patches = $rel->get_rel_pkgs_mapping_patches($relvers, $allpkgs, $platvers);
                $patchdefs = $rel->{vc_patch_matrix_data}{$padv}{$rel->{relname_to_relid}{$relvers}{relid}}{patch};
            }
            for my $patch (@{$patches}) {
                next if ($count{$prod}{instpatch}{$patch});
                if ($sys->sunos()) {
                    ($patchid, $patchvers) = split(/-/m, $patch, 2);
                    next if ($count{$prod}{patchid}{$patchid});
                }
                if (exists($patchdefs->{$patch}{pc_obsoletes})) {
                    for my $obpatch (@{$patchdefs->{$patch}{pc_obsoletes}}) {
                        $count{$prod}{obpatch}{$obpatch}++;
                    }
                }
                if (exists($patchdefs->{$patch}{supersedes})) {
                    for my $obpatch (@{$patchdefs->{$patch}{supersedes}}) {
                        $count{$prod}{obpatch}{$obpatch}++;
                    }
                }
                if ($sys->hpux() && ($sys->{padv} eq 'HPUX1131par') && $sys->{iprod}{$prod}{mjvers} =~ /6\./m) {
                    if (EDRu::inarr("VRTSfsadv", @{$patchdefs->{$patch}{pkgs}})){
                        next;
                    }
                }
                if (EDRu::inarr($patch, @{$sys->{patches}})) {
                    $count{$prod}{instpatch}{$patch}++;
                    $count{$prod}{patchid}{$patchid}++;
                    $sys->{iprod}{$prod}{ipatches}{$relvers}{$patch} = [@{$patchdefs->{$patch}{pkgs}}];
                } else {
                    next if ($count{$prod}{obpatch}{$patch});
                    $sys->{iprod}{$prod}{mpatches}{$relvers}{$patch} = [@{$patchdefs->{$patch}{pkgs}}];
                }
            }
        }
    }

    $rel->check_installed_P_hotfix_sys($sys);

    return '';
}

sub check_available_update_status_sys {
    my ($rel, $sys)= @_;
    my ($padv, $hotfix_t, $current_version, $ihotfixes, @items, $alreadyin, $cksum, $uploadfilename, $type);

    $padv = $rel->{padv_managed_host_for_vc};

    for my $prod (sort keys %{$sys->{iprod}}) {
        next if ($sys->{iprod}{$prod}{unsupport});
        $current_version = $sys->{iprod}{$prod}{mprpvers};
        $ihotfixes = $sys->{iprod}{$prod}{ihotfixes};
        $sys->{iprod}{$prod}{available_ga_update} = $rel->get_available_ga_update($prod, $padv, $current_version);
        $sys->{iprod}{$prod}{available_patch_update} = $rel->get_available_patch_update($prod, $padv, $current_version, $ihotfixes);
        $sys->{iprod}{$prod}{available_hotfix_update} = $rel->get_available_hotfix_update($prod, $padv, $current_version, $ihotfixes);
        push @{$rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_set}}, @{$sys->{iprod}{$prod}{available_ga_update}};
        push @{$rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_set}}, @{$sys->{iprod}{$prod}{available_patch_update}};
        push @{$rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_set}}, @{$sys->{iprod}{$prod}{available_hotfix_update}};

        push @{$rel->{vc_update_status}{$sys->{sys}}{available_update}{id_set}}, @{$sys->{iprod}{$prod}{available_ga_update}};
        push @{$rel->{vc_update_status}{$sys->{sys}}{available_update}{id_set}}, @{$sys->{iprod}{$prod}{available_patch_update}};
        push @{$rel->{vc_update_status}{$sys->{sys}}{available_update}{id_set}}, @{$sys->{iprod}{$prod}{available_hotfix_update}};
    }

    for my $id (@{$rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_set}}) {
        if ($rel->{vc_release_matrix_data}{$padv}{$id}{obsoleted_by}){
            $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{obsoleted} = 1;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{obsoleted} = 1;
        } else {
            $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{obsoleted} = 0;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{obsoleted} = 0;
        }
        if ($rel->{vc_release_matrix_data}{$padv}{$id}{install_patch}){
            $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{automated} = 1;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{automated} = 1;
        } else {
            $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{automated} = 0;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{automated} = 0;
        }

        if ($rel->{repos_set_for_vc} == 1){
            if ($rel->{vc_release_matrix_data}{$padv}{$id}{upload_location}){
                @items = split(/\//, $rel->{vc_release_matrix_data}{$padv}{$id}{upload_location});
                $uploadfilename = $items[-1];
                $type = "ga";
                $cksum = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_cksum};
                $alreadyin = $rel->is_in_repository($rel->{repository_path_for_vc},$type,$uploadfilename,$cksum);
                $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{in_repository} = $alreadyin;
                $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{in_repository} = $alreadyin;
            } else {
                $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{in_repository} = 2;
                $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{in_repository} = 2;
            }
        }

        $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{release_name} = $rel->{vc_release_matrix_data}{$padv}{$id}{release_name};
        $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{upload_location} = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_location};
        $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{upload_size} = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_size};
        $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{upload_cksum} = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_cksum};
        $rel->{vc_update_status}{$sys->{sys}}{available_ga_update}{id_detail}{$id}{update_type} = "ga";

        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{release_name} = $rel->{vc_release_matrix_data}{$padv}{$id}{release_name};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_location} = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_location};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_size} = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_size};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_cksum} = $rel->{vc_release_matrix_data}{$padv}{$id}{upload_cksum};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{update_type} = "ga";
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{vers_level} = $rel->{vc_patch_matrix_data}{$padv}{$id}{vers_level};
    }

    for my $id (@{$rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_set}}) {
        if ($rel->{vc_patch_matrix_data}{$padv}{$id}{obsoleted_by}){
            $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{obsoleted} = 1;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{obsoleted} = 1;
        } else {
            $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{obsoleted} = 0;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{obsoleted} = 0;
        }
        if ($rel->{vc_patch_matrix_data}{$padv}{$id}{install_patch}){
            $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{automated} = 1;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{automated} = 1;
        } else {
            $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{automated} = 0;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{automated} = 0;
        }

        if ($rel->{repos_set_for_vc} == 1){
            if ($rel->{vc_patch_matrix_data}{$padv}{$id}{upload_location}){
                @items = split(/\//, $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_location});
                $uploadfilename = $items[-1];
                $type = "patch";
                $cksum = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_cksum};
                $alreadyin = $rel->is_in_repository($rel->{repository_path_for_vc},$type,$uploadfilename,$cksum);
                $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{in_repository} = $alreadyin;
                $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{in_repository} = $alreadyin;
            } else {
                $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{in_repository} = 2;
                $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{in_repository} = 2;
            }
        }

        $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{release_name} = $rel->{vc_patch_matrix_data}{$padv}{$id}{release_name};
        $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{upload_location} = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_location};
        $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{upload_size} = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_size};
        $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{upload_cksum} = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_cksum};
        $rel->{vc_update_status}{$sys->{sys}}{available_patch_update}{id_detail}{$id}{update_type} = "patch";

        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{release_name} = $rel->{vc_patch_matrix_data}{$padv}{$id}{release_name};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_location} = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_location};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_size} = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_size};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_cksum} = $rel->{vc_patch_matrix_data}{$padv}{$id}{upload_cksum};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{update_type} = "patch";
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{vers_level} = $rel->{vc_patch_matrix_data}{$padv}{$id}{vers_level};
    }

    for my $id (@{$rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_set}}) {
        if ($rel->{vc_hotfix_matrix_data}{$padv}{$id}{obsoleted_by}){
            $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{obsoleted} = 1;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{obsoleted} = 1;
        } else {
            $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{obsoleted} = 0;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{obsoleted} = 0;
        }
        if ($rel->{vc_hotfix_matrix_data}{$padv}{$id}{install_patch}){
            $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{automated} = 1;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{automated} = 1;
        } else {
            $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{automated} = 0;
            $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{automated} = 0;
        }

        if ($rel->{repos_set_for_vc} == 1){
            if ($rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_location}){
                @items = split(/\//, $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_location});
                $uploadfilename = $items[-1];
                $type = "hotfix";
                $cksum = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_cksum};
                $alreadyin = $rel->is_in_repository($rel->{repository_path_for_vc},$type,$uploadfilename,$cksum);
                $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{in_repository} = $alreadyin;
                $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{in_repository} = $alreadyin;
            } else {
                $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{in_repository} = 2;
                $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{in_repository} = 2;
            }
        }
        $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{release_name} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{release_name};
        $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{upload_location} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_location};
        $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{upload_size} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_size};
        $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{upload_cksum} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_cksum};
        $rel->{vc_update_status}{$sys->{sys}}{available_hotfix_update}{id_detail}{$id}{update_type} = "hotfix";

        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{release_name} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{release_name};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_location} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_location};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_size} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_size};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{upload_cksum} = $rel->{vc_hotfix_matrix_data}{$padv}{$id}{upload_cksum};
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{update_type} = "hotfix";
        $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$id}{vers_level} = $rel->{vc_patch_matrix_data}{$padv}{$id}{vers_level};
    }
    return;
}

sub is_in_repository {
    my ($rel,$repository_path,$releasetype,$uploadfilename,$cksum) = @_;
    my ($target_dir, $filename, $msg, $result, $localsys, @items, $cksum_result, $right_cksum);

    $localsys=EDR::get('localsys');

    return 3 unless ($repository_path);

    $target_dir = "$repository_path/"."$releasetype/"."targz/";
    $filename = "$target_dir"."$uploadfilename";

    if (! -d $target_dir) {
        $msg=Msg::new("Checking whether available update is already in the repository: $target_dir cannot be found in the driver node.\n");
        $msg->log;
        return 0;
    }

    if (-f $filename) {
        $result = $localsys->cmd("_cmd_cksum $filename");
        @items = split(/\s+/, $result);
        $cksum_result = $items[0];
        $right_cksum = $cksum;
        if ($cksum_result ne $right_cksum) {
            $msg=Msg::new("Checking whether available update is already in the repository: checksum is different.\n");
            $msg->log;
            return 0;
        } else {
            $msg=Msg::new("Checking whether available update is already in the repository: $filename is already in the repository.\n");
            $msg->log;
            return 1;
        }
     } else {
        $msg=Msg::new("Checking whether available update is already in the repository: $filename cannot be found under $target_dir\n");
        $msg->log;
     }
     return 0;
}

sub get_available_ga_update {
    my ($rel, $prod, $padv, $ver)=@_;
    my (@available_ga_update, $vlevel);

    #for the name update by some old product.
    my %updateroute = (
        'sfora' => 'sf',
        'sforaha' => 'sfha',
        'sfcfs' => 'sfcfsha',
        'sfsyb' => 'sf',
        'sfsybha' => 'sfha',
        'sfdb2' => 'sf',
        'sfdb2ha' => 'sfha',
    );

    $vlevel = $rel->{relname_to_vers_level}{$ver}{vers_level};
    foreach my $rel_id (keys %{$rel->{vc_release_matrix_data}{$padv}}) {
         next if (defined $rel->{vc_release_matrix_data}{$padv}{$rel_id}{in_development});
         if (!defined $rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$prod}) {
             if (!$updateroute{$prod} || (!defined $rel->{vc_release_matrix_data}{$padv}{$rel_id}{prod}{$updateroute{$prod}})) {
                 next;
             }
         }
         next if (!($rel->{vc_release_matrix_data}{$padv}{$rel_id}{vers_level} gt $vlevel));
         push @available_ga_update, $rel_id;
    }
    return \@available_ga_update;
}

sub get_available_patch_update {
    my ($rel, $prod, $padv, $ver, $ihotfixes)=@_;
    my (@available_patch_update, $id, $vlevel, @items, @items_a, @items_b, @obs_hotfixes, $obsoleted_hotfixes);

    foreach my $ihotfix (@$ihotfixes) {
         @items = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$ihotfix}{obsoletes});
         push @obs_hotfixes, @items;
         push @obs_hotfixes, $ihotfix;
    }
    $obsoleted_hotfixes = EDRu::arruniq(@obs_hotfixes);

    $id = $rel->{relname_to_relid}{$ver}{relid};
    $vlevel = $rel->{relname_to_vers_level}{$ver}{vers_level};
    foreach my $rel_id (keys %{$rel->{vc_patch_matrix_data}{$padv}}){
#         my @ids = split (/,/,$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{installed_over});
#         next if (!EDRu::inarr($id,@ids));
         next if (defined $rel->{vc_patch_matrix_data}{$padv}{$rel_id}{in_development});
         next if ($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{release_type} ne "RP" && $rel->{vc_patch_matrix_data}{$padv}{$rel_id}{release_type} ne "MR");
         @items_a = split (/-/,$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{vers_level});
         @items_b = split (/-/,$vlevel);
         next if ($items_b[0] le '600' && $items_a[0] ne $items_b[0]);
         next if ($items_b[0] gt '600' && $items_a[0] lt $items_b[0]);
         next if (! ($rel->{vc_patch_matrix_data}{$padv}{$rel_id}{vers_level} gt $vlevel));
         my @products = split (/,/,$rel->{vc_patch_matrix_data}{$padv}{$rel_id}{products});
         next if (!EDRu::inarr($prod,@products));
         next if (EDRu::inarr($rel_id, @{$obsoleted_hotfixes}));
         push @available_patch_update, $rel_id;
    }

    return \@available_patch_update;
}

sub get_available_hotfix_update {
    my ($rel, $prod, $padv, $ver, $ihotfixes)=@_;
    my (@available_hotfix_update_with_obs_each_other, @available_hotfix_update_with_conflicts_each_other, $allobs_ids_in_available_set, $id, @items, @obs_hotfixes, $obsoleted_hotfixes, @allobs_ids, $possible_conflict, @available_hotfix_update_final);

    foreach my $ihotfix (@$ihotfixes) {
         @items = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$ihotfix}{obsoletes});
         push @obs_hotfixes, @items;
         push @obs_hotfixes, $ihotfix;
    }
    $obsoleted_hotfixes = EDRu::arruniq(@obs_hotfixes);

    $id = $rel->{relname_to_relid}{$ver}{relid};
    foreach my $rel_id (keys %{$rel->{vc_hotfix_matrix_data}{$padv}}){
         next if (defined $rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{in_development});
         next if ($rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{release_type} ne "P" && $rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{release_type} ne "pHF");
         my @ids = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{installed_over});
         next if (!EDRu::inarr($id,@ids));
         my @products = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{products});
         next if (!EDRu::inarr($prod,@products));
         next if (EDRu::inarr($rel_id,@{$obsoleted_hotfixes}));
         push @available_hotfix_update_with_conflicts_each_other, $rel_id;
    }

    foreach my $rel_id (@available_hotfix_update_with_conflicts_each_other) {
         $possible_conflict = 0;
         foreach my $ihotfix (@$ihotfixes) {
             if($rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{hotfix_prod} eq $rel->{vc_hotfix_matrix_data}{$padv}{$ihotfix}{hotfix_prod}){
                 my @a = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{obsoletes});
                 if (!EDRu::inarr($ihotfix,@a)) {
                     $possible_conflict = 1;
                 }
             }
         }
         if ($possible_conflict == 0){
             push @available_hotfix_update_with_obs_each_other, $rel_id;
         }
    }

    foreach my $rel_id (@available_hotfix_update_with_obs_each_other){
         my @obs_ids = split (/,/,$rel->{vc_hotfix_matrix_data}{$padv}{$rel_id}{obsoletes});
         push @allobs_ids, @obs_ids;
    }

    $allobs_ids_in_available_set = EDRu::arruniq(@allobs_ids);
    foreach my $rel_id (@available_hotfix_update_with_obs_each_other) {
         if (!EDRu::inarr($rel_id, @{$allobs_ids_in_available_set})) {
             push @available_hotfix_update_final, $rel_id;
         }
    }

    return \@available_hotfix_update_final;
}

sub output_installed_pkgs_patches_for_version_history{
    my ($rel, $sys) = @_;
    my ($format,$pstamp,$rootpath,$padv);

    $padv = $rel->{padv_managed_host_for_vc};

    # packages: ($time) $pkgname PACKAGE $vers ($pstamp)
    $rootpath = Cfg::opt('rootpath')?Cfg::opt('rootpath'):'/';
    $format = '%-16s PACKAGE     %-16s %s'."\n";
    if ($ENV{VH_TIME}) {
        $format = $ENV{VH_TIME}.' '.$format;
    }
    for my $pkg (sort keys %{$sys->{pkgvers}}) {
        $pstamp = '';
        if ( $sys->{plat} eq 'SunOS' ) {
            $pstamp = $sys->cmd("_cmd_pkginfo -l -R $rootpath $pkg | _cmd_grep '^[ \t]*PSTAMP:'");
            $pstamp =~ s/^\s*PSTAMP:\s*//mx;
        }
        printf($format,$pkg,$sys->{pkgvers}{$pkg},$pstamp);
    }

    if ($sys->{plat} eq 'SunOS' || $sys->{plat} eq 'HPUX' ) {
        # patches: ($time) $pkgname PATCH $release $patchid)
        $format = '%-16s PATCH       %-16s %s'."\n";
        if ($ENV{VH_TIME}) {
            $format = $ENV{VH_TIME}.' '.$format;
        }
        for my $release (sort keys %{$rel->{vc_patch_matrix_data}{$padv}}) {
            if ($rel->{vc_patch_matrix_data}{$padv}{$release}{patch}) {
                for my $patchid (sort keys %{$rel->{vc_patch_matrix_data}{$padv}{$release}{patch}}) {
                    if (EDRu::inarr($patchid, @{$sys->{patches}})) {
                        for my $pkg (sort @{$rel->{vc_patch_matrix_data}{$padv}{$release}{patch}{$patchid}{pkgs}}) {
                            if ($sys->{pkgvers}{$pkg}) {
                                printf($format,$pkg,$release,$patchid);
                            }
                        }
                    }
                }
            }
        }
    }
    return;
}

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($output, $line, $mjvers, $mpvers, $rootpath);
    my ($majorvers, @vfields, $ivers, $mp, $rp, $ru, $sp, $pr,$p);
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};

    if ($padv=~/sol11/){
        @vfields = split(/\./m, $sys->{pkgvers}{$pkg});
        $mpvers = $majorvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        if ($pkg =~ /^VRTSat/m ) {
        # Do not parse MP/SP info for AT product, just major version, such as "5.0" or "6.1" etc.
        } elsif ( $vfields[2] == 0 && $vfields[3] == 0) {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.30.01') {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.410.000') {
            $mpvers .= 'PR1';
        } elsif ($majorvers < 5.1) {
            # x.y.mm.nn (x is 4 or x.y is 5.0)
            #     -- -
            #     || |
            #     || --- RP #
            #     |----- RU #
            #     ------ MP #
            $mp = $vfields[2];
            $mp =~ s/^.*([0-9])[0-9]$/$1/m;

            $ru = $vfields[2];
            $ru =~ s/^.*([0-9])$/$1/m;

            if ($ru) {
                $mpvers .= "RU$ru";
            } elsif ($mp) {
                $mpvers .= "MP$mp";
            }
        } elsif ($sys->{pkgvers}{$pkg} eq '6.0.10.0') {
            $mpvers .= 'PR1';
        } else {
            $mpvers = $rel->get_new_mpvers($sys->{pkgvers}{$pkg});
        }
        return $rel->pkgvers_to_relvers_mapping($mpvers);
    }
    if ($padv=~/sol/){
        $mjvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        $mpvers = $mjvers;
        $rootpath = Cfg::opt('rootpath')?Cfg::opt('rootpath'):'/';
        $output = $sys->cmd("_cmd_pkginfo -l -R $rootpath $pkg");
        for my $line (split(/\n/, $output)) {
            if ($line =~ /^\s*PSTAMP/) {
                if ($mjvers >= 5.1 && $line =~ /^\s*PSTAMP:\s*([1-9]\.[0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]).*$/mx){
                    $mpvers = $1;
                    $mpvers = $rel->get_new_mpvers($mpvers);
                } elsif ($line =~ /PSTAMP.*?((MP|SP)\d+)/mx) {
                    $mpvers = $1;
                    $mpvers = $mjvers. $mpvers;
                }
                last;
            }
        }
        return $rel->pkgvers_to_relvers_mapping($mpvers);
    }
    if($padv=~/hpux1131/) {
        $ivers = $sys->{pkgvers}{$pkg};
        @vfields = split(/\./m, $ivers);
        $mjvers = $rel->get_major_vers($ivers);
        $mpvers = $mjvers;
        if ($ivers =~ /^5\.0\.31/m) {
            $mpvers = ($vfields[3] == 5) ? '5.0.1' : '5.0_11.31';
        } elsif ($mjvers >= 5.1) {
            $mpvers = $rel->get_new_mpvers($ivers);
        } else {
            $mpvers = $rel->get_major_vers($ivers);
        }
        return $rel->pkgvers_to_relvers_mapping($mpvers);
    }
    if ($padv=~/hpux/){
        return $rel->pkgvers_to_relvers_mapping($rel->get_major_vers($sys->{pkgvers}{$pkg}));
    }
    if ($padv=~/aix/){
        @vfields = split(/\./m, $sys->{pkgvers}{$pkg});
        $majorvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        $majorvers = '4.1' if ($pkg eq 'VRTScavf' && $majorvers eq '1.0');
        $mpvers = $majorvers;
        if ($majorvers eq '4.1' || $majorvers eq '5.0') {
            $vfields[2] =~ s/[^1-9]//mg;
            $mpvers .= "MP$vfields[2]" if ($vfields[2]);
        } elsif ($majorvers >= 5.1) {
            $mpvers = $rel->get_new_mpvers($sys->{pkgvers}{$pkg});
        }
        return $rel->pkgvers_to_relvers_mapping($mpvers);
    }
    if($padv=~/sles|rhel/) {
        @vfields = split(/\./m, $sys->{pkgvers}{$pkg});
        $mpvers = $majorvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        if ($pkg =~ /^VRTSat/m ) {
            # Do not parse MP/SP info for AT product, just major version, such as "5.0" or "6.1" etc.
        } elsif ( $vfields[2] == 0 && $vfields[3] == 0) {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.30.01') {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.410.000') {
            $mpvers .= 'PR1';
        } elsif ($majorvers < 5.1) {
            # x.y.mm.nn (x is 4 or x.y is 5.0)
            #     -- -
            #     || |
            #     || --- RP #
            #     |----- RU #
            #     ------ MP #
            $mp = $vfields[2];
            $mp =~ s/^.*([0-9])[0-9]$/$1/m;

            $ru = $vfields[2];
            $ru =~ s/^.*([0-9])$/$1/m;

            if ($ru) {
                $mpvers .= "RU$ru";
            } elsif ($mp) {
                $mpvers .= "MP$mp";
            }
        } else {
            $mpvers = $rel->get_new_mpvers($sys->{pkgvers}{$pkg});
        }
        return $rel->pkgvers_to_relvers_mapping($mpvers);
    }
}

sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($output, $line, $mjvers, $rootpath);
    my ($majorvers, $mpvers, $mprpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};

    if ($padv=~/sol11/){
        @vfields = split(/\./m, $sys->{pkgvers}{$pkg});
        $mprpvers = $majorvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        if ($pkg =~ /^VRTSat/m) {
            # Do not parse MP/SP info for AT product, just major version, such as "5.0" or "6.1" etc.
        } elsif ( $vfields[2] == 0 && $vfields[3] == 0) {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.30.01') {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.410.000') {
            $mprpvers .= 'PR1';
        } elsif ($majorvers < 5.1) {
            # x.y.mm.nn (x is 4 or x.y is 5.0)
            #     -- -
            #     || |
            #     || --- RP #
            #     |----- RU #
            #     ------ MP #
            $mp = $vfields[2];
            $mp =~ s/^.*([0-9])[0-9]$/$1/m;

            $rp = $vfields[3];
            $rp =~ s/^.*([0-9])[0-9]$/$1/m;

            $ru = $vfields[2];
            $ru =~ s/^.*([0-9])$/$1/m;

            if ($ru) {
                $mprpvers .= "RU$ru";
            } elsif ($mp) {
                $mprpvers .= "MP$mp";
            }
            if ($rp) {
                $mprpvers .= "RP$rp";
            }
        } elsif ($sys->{pkgvers}{$pkg} eq '6.0.10.0') {
            $mprpvers .= 'PR1';
        } else {
            $mprpvers = $rel->get_new_mprpvers($sys->{pkgvers}{$pkg});
        }
        return $rel->pkgvers_to_relvers_mapping($mprpvers);
    }
    if($padv=~/sol/){
        $mjvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        $mprpvers = $mjvers;
        $rootpath = Cfg::opt('rootpath')?Cfg::opt('rootpath'):'/';
        $output = $sys->cmd("_cmd_pkginfo -l -R $rootpath $pkg");
        for my $line (split(/\n/, $output)) {
            if ($line =~ /^\s*PSTAMP/) {
                if ($mjvers >= 5.1 && $line =~ /^\s*PSTAMP:\s*([1-9]\.[0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]).*$/mx){
                    $mprpvers = $1;
                    $mprpvers = $rel->get_new_mprpvers($mprpvers);
                } else {
                    if ( $line =~ /PSTAMP.*?(MP\d+)/mx ) {
                        $mprpvers .= $1;
                    }
                    if ( $line =~ /PSTAMP.*?(SP\d+)/mx ) {
                        $mprpvers .= $1;
                    }
                    if ( $line =~ /PSTAMP.*?(PR\d+)/mx ) {
                        $mprpvers .= $1;
                    }
                    if ( $line =~ /PSTAMP.*?(RP\d+)/mx ) {
                        $mprpvers .= $1;
                    }
                }
                last;
            }
        }
        return $rel->pkgvers_to_relvers_mapping($mprpvers);
    }
    if($padv=~/hpux/){
        return $rel->pkgvers_to_relvers_mapping($rel->pkg_inst_mpvers_sys($sys, $pkg));
    }
    if($padv=~/aix/){
        @vfields = split(/\./m, $sys->{pkgvers}{$pkg});
        $majorvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        $majorvers = '4.1' if ($pkg eq 'VRTScavf' && $majorvers eq '1.0');
        $mprpvers = $majorvers;
        if ($majorvers eq '4.1' || $majorvers eq '5.0') {
            $vfields[2] =~ s/[^1-9]//mg;
            $mprpvers .= "MP$vfields[2]" if ($vfields[2]);
            $vfields[3] =~ s/[^1-9]//mg;
            $mprpvers .= "RP$vfields[3]" if ($vfields[3]);
        } elsif ($majorvers >= 5.1) {
            $mprpvers = $rel->get_new_mprpvers($sys->{pkgvers}{$pkg});
        }
        return $rel->pkgvers_to_relvers_mapping($mprpvers);
    }
    if ($padv=~/sles|rhel/){
        @vfields = split(/\./m, $sys->{pkgvers}{$pkg});
        $mprpvers = $majorvers = $rel->get_major_vers($sys->{pkgvers}{$pkg});
        if ($pkg =~ /^VRTSat/m) {
            # Do not parse MP/SP info for AT product, just major version, such as "5.0" or "6.1" etc.
        } elsif ( $vfields[2] == 0 && $vfields[3] == 0) {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.30.01') {

        } elsif ($pkg eq 'VRTSvcssy' && $sys->{pkgvers}{$pkg} eq '5.0.410.000') {
            $mprpvers .= 'PR1';
        } elsif ($majorvers < 5.1) {
            # x.y.mm.nn (x is 4 or x.y is 5.0)
            #     -- -
            #     || |
            #     || --- RP #
            #     |----- RU #
            #     ------ MP #
            $mp = $vfields[2];
            $mp =~ s/^.*([0-9])[0-9]$/$1/m;

            $rp = $vfields[3];
            $rp =~ s/^.*([0-9])[0-9]$/$1/m;

            $ru = $vfields[2];
            $ru =~ s/^.*([0-9])$/$1/m;

            if ($ru) {
                $mprpvers .= "RU$ru";
            } elsif ($mp) {
                $mprpvers .= "MP$mp";
            }
            if ($rp) {
                $mprpvers .= "RP$rp";
            }
        } else {
            $mprpvers = $rel->get_new_mprpvers($sys->{pkgvers}{$pkg});
        }
        return $rel->pkgvers_to_relvers_mapping($mprpvers);
    }
}

sub set_inst_vrtsprods_sys {
    my ($rel, $sys) = @_;
    my ($prod, $checksf, $checkvcs, $checkfs, $checkvm, $checkat);
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};

    if ($padv=~/sol/){

        $checksf = $checkvcs = 1;
        $checkat = 1;

        if ($rel->appha_installed($sys)) {
            $checkvcs = 0;
            $sys->{iprod}{appha}{imainpkg} = 'VRTSvcs VRTSvcsvmw';
        }

        if ($sys->{pkgvers}{VRTSdbac}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSdbac}) < 6.0);
            $sys->{iprod}{sfrac}{imainpkg} = 'VRTSdbac VRTSvxvm VRTSvxfs VRTSvcs';
        }

        if ($sys->{pkgvers}{VRTSsvs}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSsvs}) < 6.0);
            $sys->{iprod}{svs}{imainpkg} = 'VRTSsvs VRTSvxvm VRTSvxfs VRTSvcs';
        }

        if ($sys->{pkgvers}{VRTScavf}
            && (! exists($sys->{iprod}{svs}))
            && (! exists($sys->{iprod}{sfrac}))) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) < 6.0);

            if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 6.0) {
                 if (grep {/Cluster File System/} $rel->get_licensed_prods_sys($sys)) {
                         $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                         } elsif ($sys->{padv} eq 'Sol10sparc' &&  grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                    $sys->{iprod}{sfsybce}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                } else {
                    $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                }
            } else {
                if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 5.1 && grep ({/Cluster File System/} $rel->get_licensed_prods_sys($sys)) && EDRu::inarr("VCS", $rel->get_licensed_vcs_modes_sys($sys))) {
                    $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                } else {
                    if ($sys->{pkgvers}{VRTSvcssy} eq '5.0.1') {
                        $sys->{iprod}{sfsybasece}{imainpkg} = 'VRTSvcssy';
                    } else {
                        $sys->{iprod}{sfcfs}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                    }
                }
            }
        }
        if ($sys->{pkgvers}{VRTSdbed}
            && (! exists($sys->{iprod}{sfrac}))
            && $rel->get_major_vers($sys->{pkgvers}{VRTSdbed}) !~ /^5\.[1-9]/m
            && $rel->get_major_vers($sys->{pkgvers}{VRTSdbed}) !~ /^6\./m
            ) {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sforaha}{imainpkg} = 'VRTSdbed VRTSvxvm VRTSvxfs VRTSvcs';
            } else {
                $sys->{iprod}{sfora}{imainpkg} = 'VRTSdbed VRTSvxvm VRTSvxfs';
            }
        }

        if ($sys->{pkgvers}{VRTSsybed}) {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sfsybha}{imainpkg} = 'VRTSsybed VRTSvxvm VRTSvxfs VRTSvcs';
            } else {
                $sys->{iprod}{sfsyb}{imainpkg} = 'VRTSsybed VRTSvxvm VRTSvxfs';
            }
        }

        if ($sys->{pkgvers}{VRTSdb2ed} && $sys->{arch} eq 'sparc') {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sfdb2ha}{imainpkg} = 'VRTSdb2ed VRTSvxvm VRTSvxfs VRTSvcs';
            } else {
                $sys->{iprod}{sfdb2}{imainpkg} = 'VRTSdb2ed VRTSvxvm VRTSvxfs';
            }
        }

        if ($checksf && $sys->{pkgvers}{VRTSvcsvr} && ! $sys->{pkgvers}{VRTSvcs} && $rel->is_vr_licensed_sys($sys)) {
            $checksf = 0;
            $sys->{iprod}{vvr}{imainpkg} = 'VRTSvcsvr VRTSvxvm VRTSvxfs';
        }

        if ($checksf) {
            $checkvm = $checkfs = 1;
            if ($sys->{pkgvers}{VRTSvxvm} && $sys->{pkgvers}{VRTSvxfs}) {
                $checkvm = $checkfs = 0;
                if ($rel->vcs_installed($sys) && !EDRu::compvers($sys->{pkgvers}{VRTSvcs}, $sys->{pkgvers}{VRTSvxvm}, 3)) {
                    $checkvcs = 0;
                    $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                    $sys->{iprod}{sfha}{imainpkg} = 'VRTSvxvm VRTSvxfs VRTSvcs';
                } else {
                    $sys->{iprod}{sf}{imainpkg} = 'VRTSvxvm VRTSvxfs';
                }
            }
        } else {
            $checkvm = $checkfs = 0;
        }

        if ($checkvm && $sys->{pkgvers}{VRTSvxvm}) {
            if ($rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^5\.1SP/m || $rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^6\./m ) {
                if (grep ({/Dynamic Multi-pathing/} $rel->get_licensed_prods_sys($sys))) {
                    $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                }
                if (grep ({/Volume Manager/} $rel->get_licensed_prods_sys($sys)) && $rel->vxvm_enabled_sys($sys)) {
                    $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
                } else {
                    $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                }
            } else {
                $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
            }
        }

        if ($checkfs && $sys->{pkgvers}{VRTSvxfs}) {
            $sys->{iprod}{fs}{imainpkg} = 'VRTSvxfs';
        }

        if ($checkvcs && $sys->{pkgvers}{VRTSvcs}) {
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
            $sys->{iprod}{vcs}{imainpkg} = 'VRTSvcs VRTSllt VRTSgab VRTSvxfen VRTSvcsag';
        }
        if ($checkat && $sys->{pkgvers}{VRTSat}) {
            $sys->{iprod}{at}{imainpkg} = 'VRTSat';
        }
    }

    if($padv=~/hpux/){
        $checksf = $checkvcs = 1;
        $checkat = 1;

        if ($sys->{pkgvers}{VRTSdbac}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSdbac}) < 6.0);
            $sys->{iprod}{sfrac}{imainpkg} = 'VRTSdbac VRTSvxvm VRTSvxfs VRTSvcs';
        } else {
            if ($sys->{pkgvers}{VRTScavf}) {
                $checksf = $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) < 6.0);
                if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 6.0) {
                    if ($sys->{padv} eq 'HPUX1131ia64' &&  grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                        $sys->{iprod}{sfsybce}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                    } else {
                        $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                    }
                } else {
                    if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 5.1 && grep ({/Cluster File System/} $rel->get_licensed_prods_sys($sys)) && EDRu::inarr("VCS", $rel->get_licensed_vcs_modes_sys($sys))) {
                        $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                    } else {
                        $sys->{iprod}{sfcfs}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
                    }
                }
            }

            if ($sys->{pkgvers}{VRTSdbed}
                && $rel->get_major_vers($sys->{pkgvers}{VRTSdbed}) !~ /^5\.[1-9]/m
                && $rel->get_major_vers($sys->{pkgvers}{VRTSdbed}) !~ /^6\./m
                ) {
                $checksf = 0;
                if ($sys->{pkgvers}{VRTSvcs}) {
                    $checkvcs = 0;
                    $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                    $sys->{iprod}{sforaha}{imainpkg} = 'VRTSdbed VRTSvxvm VRTSvxfs VRTSvcs';
                } else {
                    $sys->{iprod}{sfora}{imainpkg} = 'VRTSdbed VRTSvxvm VRTSvxfs';
                }
            }
        }

        if ($checksf && $sys->{pkgvers}{VRTSvcsvr} && ! $sys->{pkgvers}{VRTSvcs} && $rel->is_vr_licensed_sys($sys)) {
            $checksf = 0;
            $sys->{iprod}{vvr}{imainpkg} = 'VRTSvcsvr VRTSvxvm VRTSvxfs';
        }

        if ($checksf) {
            $checkvm = $checkfs = 1;
            if ($sys->{pkgvers}{VRTSvxvm} && $sys->{pkgvers}{VRTSvxfs}) {
                if ($rel->get_major_vers($sys->{pkgvers}{VRTSvxvm}) eq $rel->get_major_vers($sys->{pkgvers}{VRTSvxfs}) ){
                    $checkvm = $checkfs = 0;
                    if ($sys->{pkgvers}{VRTSvcs} && !EDRu::compvers($sys->{pkgvers}{VRTSvcs}, $sys->{pkgvers}{VRTSvxvm}, 3)) {
                        $checkvcs = 0;
                        $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                        $sys->{iprod}{sfha}{imainpkg} = 'VRTSvxvm VRTSvxfs VRTSvcs';
                    } else {
                        $sys->{iprod}{sf}{imainpkg} = 'VRTSvxvm VRTSvxfs';
                    }
                } else {
                    ####
                }
            }
        } else {
            $checkvm = $checkfs = 0;
        }

        if ($checkvm && $sys->{pkgvers}{VRTSvxvm}) {
            if ($rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^5\.1SP/m || $rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^6\./m) {
                if (grep ({/Dynamic Multi-pathing/} $rel->get_licensed_prods_sys($sys))) {
                    $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                }
                if (grep ({/Volume Manager/} $rel->get_licensed_prods_sys($sys)) && $rel->vxvm_enabled_sys($sys)) {
                    $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
                } else {
                    $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                }
            } else {
                $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
            }
        }

        if ($checkfs && $sys->{pkgvers}{VRTSvxfs}) {
            $sys->{iprod}{fs}{imainpkg} = 'VRTSvxfs';
        }

        if ($checkvcs && $sys->{pkgvers}{VRTSvcs}) {
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
            $sys->{iprod}{vcs}{imainpkg} = 'VRTSvcs VRTSllt VRTSgab VRTSvxfen VRTSvcsag';
        }

        if ($checkat && $sys->{pkgvers}{VRTSat}) {
            $sys->{iprod}{at}{imainpkg} = 'VRTSat';
        }
    }
    if ($padv=~/aix/){

        $checksf = $checkvcs = 1;
        $checkat = 1;

        if ($rel->appha_installed($sys)) {
            $checkvcs = 0;
            $sys->{iprod}{appha}{imainpkg} = 'VRTSvcs VRTSvcsvmw';
        }

        if ($sys->{pkgvers}{VRTSdbac}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSdbac}) < 6.0);
            $sys->{iprod}{sfrac}{imainpkg} = 'VRTSdbac VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
        } elsif ($sys->{pkgvers}{'VRTSdbac.rte'}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{'VRTSdbac.rte'}) < 6.0);
            $sys->{iprod}{sfrac}{imainpkg} = 'VRTSdbac.rte VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
        } else {
            if ($sys->{pkgvers}{VRTScavf}) {
                $checksf = $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) < 6.0);
                if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 6.0) {
                    if (($sys->{padv} eq 'AIX61' || $sys->{padv} eq 'AIX71') && grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                        $sys->{iprod}{sfsybce}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                    } else {
                        $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                    }
                } else {
                    if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 5.1 && grep ({/Cluster File System/} $rel->get_licensed_prods_sys($sys)) && EDRu::inarr("VCS", $rel->get_licensed_vcs_modes_sys($sys))) {
                        $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                    } else {
                        $sys->{iprod}{sfcfs}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                    }
                }
            }

            if ($sys->{pkgvers}{VRTSdbed}
                && $rel->get_major_vers($sys->{pkgvers}{VRTSdbed}) !~ /^5\.[1-9]/m
                && $rel->get_major_vers($sys->{pkgvers}{VRTSdbed}) !~ /^6\./m
                ) {
                $checksf = 0;
                if ($sys->{pkgvers}{VRTSvcs} || $sys->{pkgvers}{'VRTSvcs.rte'}) {
                    $checkvcs = 0;
                    $checkat = 0 if (($sys->{pkgvers}{VRTSvcs} && $rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0)||($sys->{pkgvers}{'VRTSvcs.rte'} && $rel->get_major_vers($sys->{pkgvers}{'VRTSvcs.rte'}) < 6.0));
                    $sys->{iprod}{sforaha}{imainpkg} = 'VRTSdbed VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                } else {
                    $sys->{iprod}{sfora}{imainpkg} = 'VRTSdbed VRTSvxvm VRTSvxfs';
                }
            }
        }

        if ($sys->{pkgvers}{VRTSdb2ed}) {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs} || $sys->{pkgvers}{'VRTSvcs.rte'}) {
                $checkvcs = 0;
                $checkat = 0 if (($sys->{pkgvers}{VRTSvcs} && $rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0)||($sys->{pkgvers}{'VRTSvcs.rte'} && $rel->get_major_vers($sys->{pkgvers}{'VRTSvcs.rte'}) < 6.0));
                $sys->{iprod}{sfdb2ha}{imainpkg} = 'VRTSdb2ed VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
            } else {
                $sys->{iprod}{sfdb2}{imainpkg} = 'VRTSdb2ed VRTSvxvm VRTSvxfs';
            }
        }

        if ($checksf && $sys->{pkgvers}{VRTSvcsvr} && ! $sys->{pkgvers}{VRTSvcs} && $rel->is_vr_licensed_sys($sys)) {
            $checksf = 0;
            $sys->{iprod}{vvr}{imainpkg} = 'VRTSvcsvr VRTSvxvm VRTSvxfs';
        }

        if ($checksf) {
            $checkfs = $checkvm = 1;
            if ($sys->{pkgvers}{VRTSvxvm} && $sys->{pkgvers}{VRTSvxfs}) {
                $checkfs = $checkvm = 0;
                if (($rel->vcs_installed($sys) && $sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{VRTSvxvm}) || ($sys->{pkgvers}{'VRTSvcs.rte'} && $sys->{pkgvers}{'VRTSvcs.rte'} eq $sys->{pkgvers}{VRTSvxvm})) {
                    $checkvcs = 0;
                    $checkat = 0 if (($sys->{pkgvers}{VRTSvcs} && $rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0)||($sys->{pkgvers}{'VRTSvcs.rte'} && $rel->get_major_vers($sys->{pkgvers}{'VRTSvcs.rte'}) < 6.0));
                    $sys->{iprod}{sfha}{imainpkg} = 'VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                } else {
                    $sys->{iprod}{sf}{imainpkg} = 'VRTSvxvm VRTSvxfs';
                }
            }
        } else {
            $checkfs = $checkvm = 0;
        }

        if ($checkvm && $sys->{pkgvers}{VRTSvxvm}) {
            if ($rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^5\.1SP/m || $rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^6\./m) {
                if (grep ({/Dynamic Multi-pathing/} $rel->get_licensed_prods_sys($sys))) {
                    $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                }
                if (grep ({/Volume Manager/} $rel->get_licensed_prods_sys($sys)) && $rel->vxvm_enabled_sys($sys)) {
                    $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
                } else {
                    $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                }
            } else {
                $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
            }
        }

        if ($checkfs && $sys->{pkgvers}{VRTSvxfs}) {
            $sys->{iprod}{fs}{imainpkg} = 'VRTSvxfs';
        }

        if ($checkvcs) {
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{vcs}{imainpkg} = 'VRTSvcs VRTSvcs.rte VRTSllt VRTSllt.rte VRTSgab VRTSgab.rte VRTSvxfen VRTSvxfen.rte VRTSvcsag VRTSvcsag.rte';
            } elsif ($sys->{pkgvers}{'VRTSvcs.rte'}) {
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{'VRTSvcs.rte'}) < 6.0);
                $sys->{iprod}{vcs}{imainpkg} = 'VRTSvcs VRTSvcs.rte VRTSllt VRTSllt.rte VRTSgab VRTSgab.rte VRTSvxfen VRTSvxfen.rte VRTSvcsag VRTSvcsag.rte';
            }
        }

        if ($checkat && $sys->{pkgvers}{VRTSat}) {
            $sys->{iprod}{at}{imainpkg} = 'VRTSat';
        }
    }

    if($padv=~/sles|rhel/){

        $checksf = $checkvcs = 1;
        $checkat = 1;

        if ($rel->appha_installed($sys)) {
            $checkvcs = 0;
            $sys->{iprod}{appha}{imainpkg} = 'VRTSvcs VRTSvcsvmw';
        }

        if ($sys->{pkgvers}{VRTSdbac}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSdbac}) < 6.0);
            $sys->{iprod}{sfrac}{imainpkg} = 'VRTSdbac VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
        }

        if ($sys->{pkgvers}{VRTSsvs}) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSsvs}) < 6.0);
            $sys->{iprod}{svs}{imainpkg} = 'VRTSsvs VRTSvxvm VRTSvxfs VRTSvcs';
        }

        if ($sys->{pkgvers}{VRTScavf}
            && (! exists($sys->{iprod}{svs}))
            && (! exists($sys->{iprod}{sfrac}))) {
            $checksf = $checkvcs = 0;
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) < 6.0);

            if ($rel->get_major_vers($sys->{pkgvers}{VRTScavf})>= 6.0) {
                if (($sys->{padv} eq 'RHEL6x8664'||$sys->{padv} eq 'SLES10x8664'||$sys->{padv} eq 'SLES11x8664')
                    && grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                    $sys->{iprod}{sfsybce}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
                } else {
                    $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
                }
            } else {
                if ($sys->{pkgvers}{VRTSvcssy} eq '5.0.30.01' || $sys->{pkgvers}{VRTSvcssy} eq '5.0.410.000') {
                    $sys->{iprod}{sfsybasece}{imainpkg} = 'VRTSvcssy';
                } elsif ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 5.0
                    && grep {/Cluster File System for Oracle RAC/} $rel->get_licensed_prods_sys($sys)) {
                    $sys->{iprod}{sfcfsrac}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
                } elsif ($rel->get_major_vers($sys->{pkgvers}{VRTScavf}) >= 5.1 && grep ({/Cluster File System/} $rel->get_licensed_prods_sys($sys)) && EDRu::inarr("VCS", $rel->get_licensed_vcs_modes_sys($sys))) {
                    $sys->{iprod}{sfcfsha}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
                } else {
                    $sys->{iprod}{sfcfs}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
                }
            }
        }

        if ($sys->{pkgvers}{'VRTSdbed-common'}
            && (! exists($sys->{iprod}{sfrac}))) {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sforaha}{imainpkg} = 'VRTSdbed-common VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
            } else {
                $sys->{iprod}{sfora}{imainpkg} = 'VRTSdbed-common VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform';
            }
        }

        if ($sys->{pkgvers}{'VRTSdb2ed-common'}) {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sfdb2ha}{imainpkg} = 'VRTSdb2ed-common VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
            } else {
                $sys->{iprod}{sfdb2}{imainpkg} = 'VRTSdb2ed-common VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform';
            }
        }

        if ($sys->{pkgvers}{'VRTSsybed-common'}) {
            $checksf = 0;
            if ($sys->{pkgvers}{VRTSvcs}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sfsybha}{imainpkg} = 'VRTSsybed-common VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
            } else {
                $sys->{iprod}{sfsyb}{imainpkg} = 'VRTSsybed-common VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform';
            }
        }

        if ($checksf && $sys->{pkgvers}{VRTSvcsvr} && ! $sys->{pkgvers}{VRTSvcs} && $rel->is_vr_licensed_sys($sys)) {
            $checksf = 0;
            $sys->{iprod}{vvr}{imainpkg} = 'VRTSvcsvr VRTSvxvm-common VRTSvxvm-platform VRTSvxfs-common VRTSvxfs-platform';
        }

        $checkvm = $checkfs = 0;
        if ($checksf) {
            $checkvm = $checkfs = 1;

            if ($sys->{pkgvers}{VRTSvxvm} && $sys->{pkgvers}{VRTSvxfs}) {
                $checkfs = $checkvm = 0;
                if ($rel->vcs_installed($sys) && !EDRu::compvers($sys->{pkgvers}{VRTSvcs}, $sys->{pkgvers}{VRTSvxvm}, 3)) {
                    $checkvcs = 0;
                    $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                    $sys->{iprod}{sfha}{imainpkg} = 'VRTSvxvm VRTSvxfs VRTSvcs VRTSvcsag';
                } else {
                    $sys->{iprod}{sf}{imainpkg} = 'VRTSvxvm VRTSvxfs';
                }
            }

            if (($sys->{pkgvers}{'VRTSvxvm-common'} || $sys->{pkgvers}{'VRTSvxvm-platform'})
                && ($sys->{pkgvers}{'VRTSvxfs-common'} || $sys->{pkgvers}{'VRTSvxfs-platform'})) {
                $checkfs = $checkvm = 0;
                if ($sys->{pkgvers}{VRTSvcs} && ($sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{'VRTSvxvm-common'}||$sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{'VRTSvxvm-platform'})) {
                    $prod = 'sfha';
                    $checkvcs = 0;
                    $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                    $sys->{iprod}{$prod}{imainpkg} = 'VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
                } else {
                    $prod = 'sf';
                    $sys->{iprod}{$prod}{imainpkg} = 'VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform';
                }
            }
        }

        if ($checkvm) {
            if ($sys->{pkgvers}{VRTSvxvm}) {
                if ($rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^5\.1SP/m || $rel->pkg_inst_mpvers_sys($sys, 'VRTSvxvm') =~ /^6\./m) {
                    if (grep ({/Dynamic Multi-pathing/} $rel->get_licensed_prods_sys($sys))) {
                        $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                    }
                    if (grep ({/Volume Manager/} $rel->get_licensed_prods_sys($sys)) && $rel->vxvm_enabled_sys($sys)) {
                        $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
                    } else {
                        $sys->{iprod}{dmp}{imainpkg} = 'VRTSvxvm';
                    }
                } else {
                    $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm';
                }
            } elsif ($sys->{pkgvers}{'VRTSvxvm-common'} || $sys->{pkgvers}{'VRTSvxvm-platform'}) {
                $sys->{iprod}{vm}{imainpkg} = 'VRTSvxvm-common VRTSvxvm-platform';
            }
        }

        if ($checkfs) {
            if ($sys->{pkgvers}{VRTSvxfs}) {
                $sys->{iprod}{fs}{imainpkg} = 'VRTSvxfs';
            } elsif ($sys->{pkgvers}{'VRTSvxfs-common'} || $sys->{pkgvers}{'VRTSvxfs-platform'}) {
                $sys->{iprod}{fs}{imainpkg} = 'VRTSvxfs-common VRTSvxfs-platform';
            }
        }

        if ($checkvcs && $sys->{pkgvers}{VRTSvcs}) {
            $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
            $sys->{iprod}{vcs}{imainpkg} = 'VRTSvcs VRTSllt VRTSgab VRTSvxfen VRTSvcsag';
        }

        if ($checkat && $sys->{pkgvers}{VRTSatClient}) {
            $sys->{iprod}{at}{imainpkg} = 'VRTSatClient';
        }
    }
    return '';
}

sub refresh_download_table {
    my ($rel, $sys, $padv, $level, @rel_ids)=@_;
    my ($matrix,$titles,$contents);
    my ($part1,$part2,$part3,$part4);
    @$contents = ();

    for my $rel_id (@rel_ids) {
        $matrix=$rel->get_release_matrix($padv,$level)->{$rel_id};
        $matrix->{in_repository} = $rel->{vc_update_status}{$sys->{sys}}{available_update}{id_detail}{$rel_id}{in_repository};
        push @$contents, $matrix;
    }

    @$contents = sort {$a->{vers_level} cmp $b->{vers_level}} @$contents;

    for my $content (@$contents) {
        if ($content->{obsoleted_by}) {
            $content->{obsoleted__repo}='Y';
        }
        if ($content->{in_repository} == 1) {
            $content->{downloaded} = "Y";
        }
        if ($content->{install_path}){
            $content->{auto_install} = "Y";
        }
        $content->{upload_size_kb}=sprintf("%d",$content->{upload_size} / 1024) if($content->{upload_size});
    }

    $part1 = ['release_version',[qw(release_name SORT_release_name)]];
    $part2 = [[qw(downloaded DL)]];
    $part3 = [[qw(obsoleted__repo OBS)],[qw(auto__install AI)]];
    $part4 = [[qw(release_date rel_date)],[qw(upload_size_kb size_KB)]];

    if ($level eq 'ga') {
        $titles = [@$part1,@$part2,@$part4];
    } else {
        $titles = [@$part1,@$part2,@$part3,@$part4]
    }

    return ($contents,$titles);
}

sub reorganize_systems {
    my ($rel) = @_;
    my ($prodname, $relvers, $padv, $key, $sys);
    for my $sysname (@{$rel->{vc_sys}}) {
        $key = '';
        $sys = undef;
        $sys = Sys->new($sysname);
        $padv = $rel->get_padv_for_vc($sys);
        $key = $padv . '-';
        for my $prod (sort keys %{$sys->{iprod}}) {
            $relvers = $sys->{iprod}{$prod}{mprpvers};
            $key .= "$prod-";
            $key .= "$relvers-";
        }
        push(@{$rel->{prodsys}{$key}}, $sysname);
    }
}

sub output_upgrade_options_sys {
    my ($rel,$sys) = @_;
    my ($contents, $titles, $msg, $prodname, $relvers, $padv, $msgnone);

    $msgnone = Msg::new("None");
    $padv=$rel->get_padv_for_vc($sys);
    for my $prod (sort keys %{$sys->{iprod}}) {
        $prodname = $sys->{iprod}{$prod}{name};
        $relvers = $sys->{iprod}{$prod}{mprpvers};
        Msg::n();
        $msg = Msg::new("Available Base Releases for $prodname $relvers:");
        $msg->bold();
        if ($sys->{iprod}{$prod}{available_ga_update} && @{$sys->{iprod}{$prod}{available_ga_update}}) {
            ($contents, $titles) = $rel->refresh_download_table($sys, $padv, "ga", @{$sys->{iprod}{$prod}{available_ga_update}});
            Msg::n();
            Msg::table($contents,$titles);
        } else {
            $msg = Msg::string_sprintf("\t%s", $msgnone->{msg});
            Msg::print($msg);
        }

        Msg::n();
        $msg = Msg::new("Available Maintenance Releases for $prodname $relvers:");
        $msg->bold();

        if ($sys->{iprod}{$prod}{available_patch_update} && @{$sys->{iprod}{$prod}{available_patch_update}}) {
            my ($contents, $titles);
            ($contents, $titles) = $rel->refresh_download_table($sys, $padv, "patch", @{$sys->{iprod}{$prod}{available_patch_update}});
            Msg::n();
            Msg::table($contents,$titles);
        } else {
            $msg = Msg::string_sprintf("\t%s", $msgnone->{msg});
            Msg::print($msg);
        }

        Msg::n();
        $msg = Msg::new("Available Public Hot Fixes for $prodname $relvers:");
        $msg->bold();

        if ($sys->{iprod}{$prod}{available_hotfix_update} && @{$sys->{iprod}{$prod}{available_hotfix_update}}) {
            ($contents, $titles) = $rel->refresh_download_table($sys, $padv, "hotfix", @{$sys->{iprod}{$prod}{available_hotfix_update}});
            Msg::n();
            Msg::table($contents,$titles);
        } else {
            $msg = Msg::string_sprintf("\t%s", $msgnone->{msg});
            Msg::print($msg);
        }
    }
    return '';

}

sub output_prods_install_status_sys {
    my ($rel,$sys) = @_;
    my ($padv,$script,$msg,%count,$pkgs,$relvers,$pkg,$pstamp,$rootpath,$pkgvers,$prodname,$prodvers,$installednum,$totalnum,$msgnone,$msginstaller,$hotfix_name);

    $padv = $rel->{padv_managed_host_for_vc};

    unless (keys %{$sys->{iprod}}) {
        $msg = Msg::new("No products installed on $sys->{sys}");
        $msg->print();
        return '';
    }

    Msg::n();
    $msg = Msg::new("Installed product(s) on $sys->{sys}:");
    $msg->bold();
    for my $prod (sort keys %{$sys->{iprod}}) {
        $count{unsupport_prods}++ if ($sys->{iprod}{$prod}{unsupport});
        $msg = Msg::new("\t$sys->{iprod}{$prod}{name} - $sys->{iprod}{$prod}{mprpvers} - license $sys->{iprod}{$prod}{license}");
        $msg->print();
    }
    Msg::n();

    if ($count{unsupport_prods}) {
        $script = EDRu::basename($0);
        for my $prod (sort keys %{$sys->{iprod}}) {
            if ($sys->{iprod}{$prod}{unsupport}) {
                if ($sys->aix()||$sys->linux()) {
                    $msg = Msg::new("$script cannot check the installed and missing packages of $sys->{iprod}{$prod}{name} $sys->{iprod}{$prod}{mprpvers}");
                } else {
                    $msg = Msg::new("$script cannot check the installed and missing packages and patches of $sys->{iprod}{$prod}{name} $sys->{iprod}{$prod}{mprpvers}");
                }
                $msg->warning();
            }
        }
        Msg::n() unless ($count{unsupport_prods} == scalar(keys %{$sys->{iprod}}));
    }

    for my $prod (sort keys %{$sys->{iprod}}) {
        next if ($sys->{iprod}{$prod}{unsupport});
        Msg::n() if ($count{instprods}++);
        # Product report
        $msg = Msg::new("Product:");
        $msg->bold();
        $msg = Msg::new("\t$sys->{iprod}{$prod}{name} - $sys->{iprod}{$prod}{mprpvers} - license $sys->{iprod}{$prod}{license}");
        $msg->print();
        Msg::n();

        # Packages report
        $msg = Msg::new("Packages:");
        $msg->bold();

        $msg = Msg::new("\tInstalled Required packages for $sys->{iprod}{$prod}{name} $sys->{iprod}{$prod}{mprpvers}:");
        $msg->print();
        if ( $sys->sunos() && $sys->{padv} !~ /Sol11/) {
            $msg = Msg::new("\t  #PACKAGE     #VERSION     #PSTAMP");
        } else {
            $msg = Msg::new("\t  #PACKAGE     #VERSION");
        }
        $msg->print();
        for my $pkg (@{$sys->{iprod}{$prod}{irpkgs}}) {
            if ($sys->sunos() && $sys->{padv} !~ /Sol11/) {
                $rootpath = Cfg::opt('rootpath')?Cfg::opt('rootpath'):'/';
                $pstamp = $sys->cmd("_cmd_pkginfo -l -R $rootpath $pkg | _cmd_grep '^[ \t]*PSTAMP:'");
                $pstamp =~ s/^\s*PSTAMP:\s*//mx;
                $pkgvers = $sys->{pkgvers}{$pkg} || $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}};
                $msg = Msg::string_sprintf("\t  %-12s %-12s (%s)", $pkg, $pkgvers, $pstamp);
            } elsif($sys->aix() && $pkg eq 'VRTSat') {
                $pkgvers = $sys->{pkgvers}{'VRTSat.client'};
                $msg = Msg::string_sprintf("\t  %-12s %s", $pkg, $pkgvers);
            } else {
                $pkgvers = $sys->{pkgvers}{$pkg} || $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}};
                $msg = Msg::string_sprintf("\t  %-12s %s", $pkg, $pkgvers);
            }
            Msg::print($msg);
            $count{$prod}{pkgs}{arpkgs}++;
            $count{$prod}{pkgs}{irpkgs}++;
        }
        Msg::n();

        if (exists($sys->{iprod}{$prod}{mrpkgs})
            && @{$sys->{iprod}{$prod}{mrpkgs}}) {
            $msg = Msg::new("\tMissing Required packages for $sys->{iprod}{$prod}{name} $sys->{iprod}{$prod}{mprpvers}:");
            $msg->print();
            $msg = Msg::new("\t  #PACKAGE");
            $msg->print();
            for my $pkg (@{$sys->{iprod}{$prod}{mrpkgs}}) {
                $msg = Msg::new("\t  $pkg");
                $msg->print();
                $count{$prod}{pkgs}{arpkgs}++;
            }
            Msg::n();
        }

        if (exists($sys->{iprod}{$prod}{iopkgs})
            && @{$sys->{iprod}{$prod}{iopkgs}}) {
            $msg = Msg::new("\tInstalled optional packages for $sys->{iprod}{$prod}{name} $sys->{iprod}{$prod}{mprpvers}:");
            $msg->print();
            if ( $sys->sunos() && $sys->{padv} !~ /Sol11/) {
                $msg = Msg::new("\t  #PACKAGE     #VERSION     #PSTAMP");
            } else {
                $msg = Msg::new("\t  #PACKAGE     #VERSION");
            }
            $msg->print();
            for my $pkg (@{$sys->{iprod}{$prod}{iopkgs}}) {
                if ($sys->sunos() && $sys->{padv} !~ /Sol11/) {
                    $rootpath = Cfg::opt('rootpath')?Cfg::opt('rootpath'):'/';
                    $pstamp = $sys->cmd("_cmd_pkginfo -l -R $rootpath $pkg | _cmd_grep '^[ \t]*PSTAMP:'");
                    $pstamp =~ s/^\s*PSTAMP:\s*//mx;
                    $pkgvers = $sys->{pkgvers}{$pkg} || $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}};
                    $msg = Msg::string_sprintf("\t  %-12s %-12s (%s)", $pkg, $pkgvers, $pstamp);
                } elsif($sys->aix() && $pkg eq 'VRTSat') {
                    $pkgvers = $sys->{pkgvers}{'VRTSat.client'};
                    $msg = Msg::string_sprintf("\t  %-12s %s", $pkg, $pkgvers);
                } else {
                    $pkgvers = $sys->{pkgvers}{$pkg} || $sys->{pkgvers}{$rel->{pkgtopobj}{$pkg}};
                    $msg = Msg::string_sprintf("\t  %-12s %s", $pkg, $pkgvers);
            }
                Msg::print($msg);
                $count{$prod}{pkgs}{aopkgs}++;
                $count{$prod}{pkgs}{iopkgs}++;
            }
            Msg::n();
        }

        if (exists($sys->{iprod}{$prod}{mopkgs})
            && @{$sys->{iprod}{$prod}{mopkgs}}) {
            $msg = Msg::new("\tMissing optional packages for $sys->{iprod}{$prod}{name} $sys->{iprod}{$prod}{mprpvers}:");
            $msg->print();
            $msg = Msg::new("\t  #PACKAGE");
            $msg->print();
            for my $pkg (@{$sys->{iprod}{$prod}{mopkgs}}) {
                $msg = Msg::new("\t  $pkg");
                $msg->print();
                $count{$prod}{pkgs}{aopkgs}++;
            }
            Msg::n();
        }

        # Patches report
        if (exists($sys->{iprod}{$prod}{ipatches}) || exists($sys->{iprod}{$prod}{mpatches})) {
            $msg = Msg::new("Patches:");
            $msg->bold();

            for my $relvers (reverse @{$rel->{releases}}) {
                if (exists($sys->{iprod}{$prod}{ipatches}{$relvers})) {
                    $msg = Msg::new("\tInstalled patches for $sys->{iprod}{$prod}{name} $relvers:");
                    $msg->print();
                    $msg = Msg::new("\t  #PATCH          #PACKAGE");
                    $msg->print();
                    for my $patch (sort keys %{$sys->{iprod}{$prod}{ipatches}{$relvers}}) {
                        $pkgs = join(' ', @{$sys->{iprod}{$prod}{ipatches}{$relvers}{$patch}});
                        $msg = Msg::string_sprintf("\t  %-16s%s", $patch, $pkgs);
                        Msg::print($msg);
                        $count{$prod}{patch}{$relvers}{all}++;
                        $count{$prod}{patch}{$relvers}{inst}++;
                    }
                    Msg::n();
                }
                if (exists($sys->{iprod}{$prod}{mpatches}{$relvers})) {
                    $msg = Msg::new("\tMissing patches for $sys->{iprod}{$prod}{name} $relvers:");
                    $msg->print();
                    $msg = Msg::new("\t  #PATCH          #PACKAGE");
                    $msg->print();
                    for my $patch (sort keys %{$sys->{iprod}{$prod}{mpatches}{$relvers}}) {
                        $pkgs = join(' ', @{$sys->{iprod}{$prod}{mpatches}{$relvers}{$patch}});
                        $msg = Msg::string_sprintf("\t  %-16s%s", $patch, $pkgs);
                        Msg::print($msg);
                        $count{$prod}{patch}{$relvers}{all}++;
                    }
                    Msg::n();
                }
            }
        }

        # Summary
        $msg = Msg::new("Summary:");
        $msg->bold();
        Msg::n();

        # Installed packages summary
        $msg = Msg::new("Packages:");
        $msg->bold();

        # Installed required packages statistics
        $prodname = $sys->{iprod}{$prod}{name};
        $prodvers = $sys->{iprod}{$prod}{mprpvers};
        $installednum = Msg::string_sprintf("%-2s", $count{$prod}{pkgs}{irpkgs});
        $totalnum = Msg::string_sprintf("%-2s", $count{$prod}{pkgs}{arpkgs});

        $msg = Msg::new("\t$installednum of $totalnum required $prodname $prodvers packages installed");
        Msg::print($msg);

        # Installed optional packages statistics
        if (exists($count{$prod}{pkgs}{aopkgs}) && $count{$prod}{pkgs}{aopkgs} > 0) {
            $count{$prod}{pkgs}{iopkgs} ||= 0;

            $installednum = Msg::string_sprintf("%-2s", $count{$prod}{pkgs}{iopkgs});
            $totalnum = Msg::string_sprintf("%-2s", $count{$prod}{pkgs}{aopkgs});

            $msg = Msg::new("\t$installednum of $totalnum optional $prodname $prodvers packages installed");
            Msg::print($msg);
        }

        # Installed patches summary
        if (exists($sys->{iprod}{$prod}{ipatches}) || exists($sys->{iprod}{$prod}{mpatches})) {
            $msg = Msg::new("Patches:");
            $msg->bold();

            for my $relvers (reverse @{$rel->{releases}}) {
                if (exists($count{$prod}{patch}{$relvers}{all}) && $count{$prod}{patch}{$relvers}{all} > 0) {
                    $count{$prod}{patch}{$relvers}{inst} ||= 0;

                    $installednum = Msg::string_sprintf("%-2s", $count{$prod}{patch}{$relvers}{inst});
                    $totalnum = Msg::string_sprintf("%-2s", $count{$prod}{patch}{$relvers}{all});

                    $msg = Msg::new("\t$installednum of $totalnum $prodname $relvers patches installed");
                    Msg::print($msg);
                }
            }
        }
        # Installed/available P/PP/HF
        $msgnone = Msg::new("None");
        $msginstaller = Msg::new("Installer");

        $prodname = $sys->{iprod}{$prod}{name};
        $relvers = $sys->{iprod}{$prod}{mprpvers};
        Msg::n();
        $msg = Msg::new("Installed Public and Private Hot Fixes for $prodname $relvers:");
        $msg->bold();

        if ($sys->{iprod}{$prod}{ihotfixes} && @{$sys->{iprod}{$prod}{ihotfixes}}) {
            for my $hotfix (@{$sys->{iprod}{$prod}{ihotfixes}}) {
                $hotfix_name = $rel->{vc_hotfix_matrix_data}{$padv}{$hotfix}{release_name};
                $msg = Msg::string_sprintf("\t%-20s", $hotfix_name);
                Msg::print($msg);
            }

        } else {
            $msg = Msg::string_sprintf("\t%s", $msgnone->{msg});
            Msg::print($msg);
        }
    }
    return '';
}

sub select_releases {
    my ($rel, $sysname, $iden_systems, $level,$selected_ids, @release_ids) = @_;
    my ($msg, @menu, $menuopt, $choice, $all_non, $all_releases, $ret);

    $all_non = Msg::new("All non-obsoleted releases");
    $all_releases = Msg::new("All releases");

    foreach my $id (@release_ids) {
        push @menu, $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{release_name};
    }
    push @menu, $all_non->{msg};
    push @menu, $all_releases->{msg};

    $msg=Msg::new("Select the $level release to download, '$all_non->{msg}' to download all non-obsoleted releases, or '$all_releases->{msg}' to download all releases");
    $ret=$msg->menu(\@menu,scalar(@menu)==1,'','back');
    return 0 if (EDR::getmsgkey($ret,'back'));
    if ($menu[$ret - 1] eq $all_releases->{msg}) {
        @$selected_ids = @release_ids;
    } elsif ($menu[$ret - 1] eq $all_non->{msg}) {
        @$selected_ids = grep {$rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$_}{obsoleted}==0} @release_ids;
        if (!@$selected_ids) {
            $msg = Msg::new("For $iden_systems, there are no available non-obsoleted $level releases to be downloaded.");
            $msg->print;
            Msg::n();
        }
    } else {
        @$selected_ids = $release_ids[$ret - 1];
    }
    return 1;
}

sub get_download_releases {
    my ($rel, $sysname, $ident_systems, $ref_patch, $ref_hotfix) = @_;
    my (@items, $uploadfilename, $type, $cksum, $alreadyin, $download_go, $msg, @arr);
    $download_go = 0;
    @$ref_patch = ();
    @$ref_hotfix = ();

    my @arr;
    foreach my $id (keys %{$rel->{vc_update_status}{$sysname}{available_update}{id_detail}}) {
        push @arr,[$id,$rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{vers_level}];
    }
    @arr = sort {$$a[1] cmp $$b[1]} @arr;

    foreach my $index (@arr) {
        my $id = $$index[0];
        next if ($rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{update_type} eq "ga");
        next if ($rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_location} =~ /fileconnect/);

        if ($rel->{repos_set_for_vc} == 1) {
            @items = split(/\//, $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_location});
            $uploadfilename = $items[-1];
            $type = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{update_type};
            $cksum = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_cksum};
            $alreadyin = $rel->is_in_repository($rel->{repository_path_for_vc},$type,$uploadfilename,$cksum);
            if ($type eq "hotfix") {
                $rel->{vc_update_status}{$sysname}{available_hotfix_update}{id_detail}{$id}{in_repository} = $alreadyin;
            }
            if ($type eq "patch") {
                $rel->{vc_update_status}{$sysname}{available_patch_update}{id_detail}{$id}{in_repository} = $alreadyin;
            }
            $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{in_repository} = $alreadyin;
        }

        if($rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{in_repository}==0) {
            $type = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{update_type};
            $download_go = 1;
            if ($type eq "hotfix") {
                push @$ref_hotfix, $id;
            } elsif ($type eq "patch") {
                push @$ref_patch, $id;
            }
        }
    }
    if ($download_go == 0) {
        $msg = Msg::new("For $ident_systems, there are no available Public Hot Fixes and Maintenance releases to be downloaded.");
        $msg->print;
        Msg::n();
    }
    return $download_go;
}


sub vc_download_patches {
    my ($rel) = @_;
    my ($cpic, $msg, $ayn, $padv, $sysname, $download_path, $menuopt, $choice, $backopt);
    my ($fix, $relname, @items, $filename, $target_dir, $localsys);
    my ($flag, $download_errors, $errmsg);
    my (@available_patch, @available_hotfix);
    my ($no_release, $ident_systems);

    if ($rel->{sort_ready_for_vc} == 0) {
        $msg = Msg::new("Version checker cannot download updates now since the SORT website is not available.");
        $msg->print;
        return '';
    }

    $flag = 0;
    for my $sysname (@{$rel->{vc_sys}}) {
        if (@{$rel->{vc_update_status}{$sysname}{available_patch_update}{id_set}} != 0 or @{$rel->{vc_update_status}{$sysname}{available_hotfix_update}{id_set}} != 0) {
            $flag = 1;
        }
    }
    if ($flag == 0) {
        $msg = Msg::new("No available Maintenance or Public Hot Fix releases to be downloaded.");
        $msg->print;
        return '';
    }

    $cpic = Obj::cpic();
    $backopt = 0;
    Msg::n();
    $msg = Msg::new("Would you like to download the available Maintenance or Public Hot Fix releases that cannot be found in the repository?");
    $ayn = $msg->aynn();
    Msg::n();
    if ($ayn eq 'Y') {
        if ($rel->{repos_set_for_vc} == 1){
            $rel->{vc_download_path} = $rel->{repository_path_for_vc};
        } else {
            $msg = Msg::new("\nInstaller detects that the repository directory is not set\n");
            $msg->print;
            if ($rel->repository_set_home()) {
                $rel->{repository_path_for_vc} = $cpic->{preference}{Repository}{value};
                $rel->{vc_download_path} = $rel->{repository_path_for_vc};
                $rel->{repos_set_for_vc} = 1;
            }
        }

        Msg::n();
        $msg = Msg::new("Base releases must be manually downloaded from FileConnect and loaded using the R - Manage Repository Images option.");
        $msg->print;
        Msg::n();
        $msg = Msg::new("Public Maintenance and Hot Fix releases will be downloaded into $rel->{vc_download_path} on the local system");
        $msg->print;

        $localsys=EDR::get('localsys');

        $download_path = $rel->{vc_download_path};
        chomp($download_path);
        $localsys->mkdir($download_path);

        for my $prodinfo (keys %{$rel->{prodsys}}) {
            my $sysname = $rel->{prodsys}{$prodinfo}[0];
            $ident_systems= join(' ', @{$rel->{prodsys}{$prodinfo}});
            while(1) {
                last if (!$rel->get_download_releases($sysname, $ident_systems, \@available_patch, \@available_hotfix));

                my (@download_ids, $skip, $url);
                my ($msg_option_maintenance, $msg_option_hotfix, $msg_skip, @available_updates_for_menu, $required_size, $successful_msg, $expand_file,$release_name_in_dir, $expand_file_without_gz, $release_dir, $cksum_correctmsg, $cksum_errmsg, $right_cksum, $dir, $releasetype, $uploadfilename, $result, $cksum_result);
                $skip = 0;
                $padv = $rel->{vc_host_padv}{$sysname};
                $no_release = 0;

                $msg = Msg::new("For $ident_systems, please select the level of release you want to download:");
                $msg_option_maintenance = Msg::new("Maintenance");
                $msg_option_hotfix = Msg::new("Hot Fix");
                $msg_skip = Msg::new("Skip this step");

                push @available_updates_for_menu, $msg_option_maintenance->{msg};
                push @available_updates_for_menu, $msg_option_hotfix->{msg};
                push @available_updates_for_menu, $msg_skip->{msg};
                $menuopt = EDRu::arruniq(@available_updates_for_menu);
                $choice = $msg->menu($menuopt, '', '', $backopt, 0);
                Msg::n();
                $fix = $available_updates_for_menu[$choice-1];
                if ($fix eq "Maintenance") {
                    if (@available_patch) {
                        if (!$rel->select_releases($sysname, $ident_systems, 'patch', \@download_ids, @available_patch)) {
                            next;
                        }
                    } else {
                        $msg = Msg::new("For $ident_systems, there are no available Maintenance releases to be downloaded.");
                        $msg->print;
                        Msg::n();
                        $no_release = 1;
                    }
                }
                if ($fix eq "Hot Fix") {
                    if (@available_hotfix) {
                        if (!$rel->select_releases($sysname, $ident_systems, 'hotfix', \@download_ids, @available_hotfix)) {
                            next;
                        }
                    } else {
                        $msg = Msg::new("For $ident_systems, there are no available Hot Fix releases to be downloaded.");
                        $msg->print;
                        Msg::n();
                        $no_release = 1;
                    }
                }

                if ($fix eq "Skip this step") {
                    $skip = 1;
                    last;
                }

                if ($no_release== 1 || !@download_ids) {
                    $msg = Msg::new("Would you like to download another available update release for $ident_systems?");
                    $ayn = $msg->aynn();
                    Msg::n();
                    if ($ayn eq 'Y') {
                        next;
                    } else {
                        last;
                    }
                }

                $required_size = 0;
                for my $id (@download_ids) {
                    $required_size += $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_size};
                }
                $required_size = $required_size / 1024;
                $required_size = int($required_size)+1;
                my $dfk=$localsys->cmd("_cmd_dfk $download_path 2>/dev/null");
                my @dfk=split(/\n/,$dfk);
                $dfk=pop @dfk;
                @dfk=split(/\s+/m,$dfk);
                if ( $dfk[3] < $required_size ) {
                    $msg=Msg::new("$required_size KB is required for your selections in the $download_path directory and only $dfk[3] KB is available on the local system");
                    $msg->error();
                    return 1;
                }
                Msg::n();

                $dir = "$download_path/"."patch/"."targz/";
                $localsys->mkdir($dir);
                $dir = "$download_path/"."hotfix/"."targz/";
                $localsys->mkdir($dir);

                foreach my $id (@download_ids) {
                    $relname = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{release_name};
                    $url = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_location};
                    $releasetype = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{update_type};

                    $target_dir = "$download_path/"."$releasetype/"."targz/";

                    @items = split(/\//, $url);
                    $uploadfilename = $items[-1];

                    $filename = "$target_dir"."$uploadfilename";
                    if (-f $filename) {
                        $result = $localsys->cmd("_cmd_cksum $filename");
                        @items = split(/\s+/, $result);
                        $cksum_result = $items[0];
                        $right_cksum = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_cksum};
                        if ($cksum_result ne $right_cksum) {
                            $cksum_errmsg=Msg::new("Download the existing file $filename again since the ckeck sum is different\n");
                            $cksum_errmsg->log;
                            $cksum_errmsg->print;
                        } else {
                            $cksum_correctmsg=Msg::new("$relname is already under $target_dir\n");
                            $cksum_correctmsg->log;
                            $cksum_correctmsg->print;
                            $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{in_repository} = 1;
                            next
                        }
                    }

                    $release_name_in_dir = $uploadfilename;
                    $release_name_in_dir =~ s/\.tar\.gz$//g;

                    $msg=Msg::new("$relname:");
                    $msg->print;
                    my $ret = EDRu::download_file($url, $filename, 1, 20);
                    if (!$ret) {
                        #Error occurred
                        $download_errors=EDR::get('download_errors');
                        $errmsg=Msg::new("Could not download $relname!\n$download_errors\n");
                        $errmsg->log;
                        $errmsg->print;
                    }
                    $result = $localsys->cmd("_cmd_cksum $filename");

                    @items = split(/\s+/, $result);
                    $cksum_result = $items[0];
                    $right_cksum = $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{upload_cksum};
                    if ($cksum_result ne $right_cksum) {
                        $cksum_errmsg=Msg::new("Download $relname unsuccessfully!\nCheck sum is different\n");
                        $cksum_errmsg->log;
                        $cksum_errmsg->print;
                    } else {
                        $release_dir = "$download_path/"."$releasetype/"."images/"."$release_name_in_dir/";
                        $localsys->mkdir($release_dir);
                        $localsys->copyfile($filename, $release_dir);
                        $expand_file = "$release_dir"."$uploadfilename";
                        $localsys->cmd("_cmd_gunzip $expand_file") if(-f $expand_file);
                        $expand_file_without_gz = $expand_file;
                        $expand_file_without_gz =~ s/\.gz$//g;
                        $localsys->cmd("cd $release_dir; _cmd_tar -xvf $expand_file_without_gz");
                        $localsys->cmd("_cmd_rmr $expand_file_without_gz");

                        $successful_msg = "Download $relname successfully!\n  Location: $target_dir\n  Expanded files Location: $release_dir";
                        $cksum_correctmsg=Msg::new("$successful_msg\n");
                        $cksum_correctmsg->log;
                        $cksum_correctmsg->print;
                        $rel->{vc_update_status}{$sysname}{available_update}{id_detail}{$id}{in_repository} = 1;
                    }
                    Msg::n();
                }
                $msg = Msg::new("Would you like to download another available Maintenance or Hot Fix release for $ident_systems?");
                $ayn = $msg->aynn();
                Msg::n();
                if ($ayn eq 'Y') {
                    next;
                } else {
                    last;
                }
            }
        }
    }
    return '';
}

# return the major version like 4.1, 5.0, 5.1 from the passed version string
# the version string could be 5.0MP3 or a regular version string like 5.0.30.00
sub get_major_vers {
    my ($rel, $vers) = @_;
    my @vfields = split(/\./m, $vers);
    my ($majorver, $padv);

    $padv = $rel->{padv_managed_host_for_vc};

    if($padv eq 'hpux1131'){
        if ($vers =~ /^5\.0\.31/m) {
            $majorver = ($vfields[3] == 5) ? '5.0.1' : '5.0';
        } elsif ($vers eq "5.0.1" || $vers =~ /^5\.0\.1[a-zA-Z]/m) {
            $majorver = '5.0.1';
        } elsif ($vers =~ /^5\.1/m) {
            $majorver = '5.1';
        } else {
            $vfields[0] =~ s/\D.*$//m;
            $vfields[1] =~ s/\D.*$//m;
            $majorver = join('.', $vfields[0], $vfields[1]);
        }
    } else {
        $vfields[0] =~ s/\D.*$//m;
        $vfields[0] += 0;
        $vfields[1] =~ s/\D.*$//m;
        $vfields[1] += 0;
        $majorver = join('.', $vfields[0], $vfields[1]);
    }
    return $majorver;
}

sub get_licensed_prods_sys {
    my ($rel, $sys) = @_;
    my (@licensed_prods,$output, $line);
    if (! exists $sys->{licensed_prods}) {
        @licensed_prods = ();
        $output = $sys->cmd("_cmd_vxlicrep 2>/dev/null | _cmd_grep 'Product Name'");
        for my $line (split(/\n/, $output)) {
            $line =~ s/^\s*Product Name\s*=\s*(.*)$/$1/mx;
            push @licensed_prods, $line;
        }
        $sys->{licensed_prods} = \@licensed_prods;
    }
    return @{$sys->{licensed_prods}};
}

sub vxvm_enabled_sys {
    my ($rel, $sys) = @_;
    my ($output);
    $output = $sys->cmd("_cmd_vxlicrep 2>/dev/null | _cmd_grep 'VxVM' | _cmd_grep -c 'Enabled'");
    chomp $output;
    return $output;
}

sub get_licensed_vcs_modes_sys {
    my ($rel, $sys) = @_;
    my ($output, $line, $prod);
    if (! exists $sys->{licensed_vcs_modes}) {
        $prod = undef;
        @{$sys->{licensed_vcs_modes}} = ();
        $output = $sys->cmd("_cmd_vxlicrep 2>/dev/null");
        for my $line (split(/\n/, $output)) {
            if ( $line =~ /^\s*Product Name\s*=\s*(.*)\s*$/) {
                $prod=$1;
                next;
            }
            if ( $line =~ /^\s*Mode#VERITAS Cluster Server\s*=\s*(.*)\s*$/) {
                if (!EDRu::inarr($1, @{$sys->{licensed_vcs_modes}})){
                    push @{$sys->{licensed_vcs_modes}}, $1;
                }
                next;
            }
            if ( $prod =~ /VERITAS Cluster Server/ && $line =~ /^\s*Mode\s*=\s*(.*)\s*$/) {
                if (!EDRu::inarr($1, @{$sys->{licensed_vcs_modes}})){
                    push @{$sys->{licensed_vcs_modes}}, $1;
                }
                next;
            }
        }
    }
    return @{$sys->{licensed_vcs_modes}};
}

sub appha_installed {
    my ($rel, $sys) = @_;
    my $vcsvmw_ver;
    if ($sys->{pkgvers}{VRTSvcs} && $sys->{pkgvers}{VRTSvcsvmw}) {
        $vcsvmw_ver = $sys->{pkgvers}{VRTSvcsvmw};
        # if VRTSvcsvmw version begin with 6.0 and >= 6.0.200, it should be TerraNova
        if (EDRu::compvers($vcsvmw_ver, '6.0', 2) == 0 && (EDRu::compvers($vcsvmw_ver, '6.0.200', 3) != 2)) {
            return 0;
        }
        return 1;
    }
    return 0;
}

sub vcs_installed {
    my ($rel, $sys) = @_;
    if ($sys->{pkgvers}{VRTSvcs} && !$rel->appha_installed($sys)) {
        return 1;
    }
    return 0;
}

sub is_vr_licensed_sys {
    my ($rel, $sys) = @_;
    my ($output);
    if (grep {/Symantec Volume Replicator/} $rel->get_licensed_prods_sys($sys)) {
        return 1;
    } else {
        $output = $sys->cmd("_cmd_vxlicrep 2>/dev/null");
        if ( $output =~ /^\s*VVR\s*=\s*Enabled\s*$/mx ) {
            return 1;
        }
    }
    return 0;
}

sub is_vfr_licensed_sys {
    my ($rel, $sys) = @_;
    my ($output);
    if (grep {/Symantec File Replicator Option/} $rel->get_licensed_prods_sys($sys)) {
        return 1;
    } else {
        $output = $sys->cmd("_cmd_vxlicrep 2>/dev/null");
        if ( $output =~ /^\s*VFR\s*=\s*Enabled\s*$/mx ) {
            return 1;
        }
    }
    return 0;
}


# get common product name
sub get_common_prodname {
    my ($rel, $prod) = @_;
    my ($ucprod, %vrtsprods);
    $ucprod = uc($prod);
    %vrtsprods = (
        'VM'       => 'Veritas Volume Manager',
        'FS'       => 'Veritas File System',
        'VCS'      => 'Symantec Cluster Server',
        'VVR'      => 'Volume Replicator',
        'VFR'      => 'File Replicator',
        'DMP'      => 'Symantec Dynamic Multipathing',
        'SVS'      => 'Symantec VirtualStore',
        'SF'       => 'Symantec Storage Foundation',
        'SFHA'     => 'Symantec Storage Foundation and High Availability',
        'SFORA'    => 'Symantec Storage Foundation for Oracle',
        'SFORAHA'  => 'Symantec Storage Foundation for Oracle/HA',
        'SFDB2'    => 'Symantec Storage Foundation for DB2',
        'SFDB2HA'  => 'Symantec Storage Foundation for DB2/HA',
        'SFCFS'    => 'Symantec Storage Foundation Cluster File System',
        'SFCFSHA'  => 'Symantec Storage Foundation Cluster File System/HA',
        'SFSYB'    => 'Symantec Storage Foundation for Sybase',
        'SFSYBHA'  => 'Symantec Storage Foundation for Sybase/HA',
        'SFRAC'    => 'Symantec Storage Foundation for Oracle RAC',
        'SFCFSRAC' => 'Symantec Storage Foundation Cluster File System for Oracle RAC',
        'SFSYBASECE' => 'Symantec Storage Foundation for Sybase ASE CE',
        'APPHA'    => 'Symantec ApplicationHA',
        'AT'       => 'Symantec Product Authentication Services',
    );
    return (exists($vrtsprods{$ucprod})) ? $vrtsprods{$ucprod} : "$ucprod";
}

# E.g. get 5.1SP1 from 5.1.101.000
# For 5.1 and later releases only
sub get_new_mpvers{
    my ($rel, $pkgvers) = @_;
    my ($mpvers, @vfields, $sp, $pr, $rp);
    @vfields = split(/\./m, $pkgvers);
    $mpvers = $rel->get_major_vers($pkgvers);
    if ( $mpvers < 5.1 ) {
        return $mpvers;
    }

    if ( $vfields[2] == 0 && $vfields[3] == 0) {
        return $mpvers;
    }

    # x.y.mmm.nnn (x.y is 5.1 or 6.0 or later)
    #     --- -
    #     ||| |
    #     ||| ----- P  #
    #     ||------- RP #
    #     |-------- PR #
    #     --------- SP #
    $sp = $vfields[2];
    if ($sp =~/[0-9][0-9][0-9]$/) {
        $sp =~ s/^.*([0-9])[0-9][0-9]$/$1/m;
        if ($sp) {
            $mpvers .= "SP$sp";
            return $mpvers;
        }
    }

    $pr = $vfields[2];
    if ($pr =~/[0-9][0-9]$/) {
        $pr =~ s/^.*([0-9])[0-9]$/$1/m;
        if ($pr) {
            $mpvers .= "PR$pr";
            return $mpvers;
        }
    }
    $rp = $vfields[2];
    if ($rp =~ /[0-9]$/) {
        $rp =~ s/^.*([0-9])$/$1/m;
        if($rp) {
            $mpvers .= "RP$pr";
            return $mpvers;
        }
    }
    return $mpvers;
}

# E.g. get 5.1SP1RP1 from 5.1.101.000
# For 5.1 and later releases only
sub get_new_mprpvers{
    my ($rel, $pkgvers, $noP) = @_;
    my ($mprpvers, @vfields, $rp, $sp, $pr, $p, $padv);
    $padv = $rel->{padv_managed_host_for_vc};
    @vfields = split(/\./m, $pkgvers);
    $mprpvers = $rel->get_major_vers($pkgvers);
    if ( $mprpvers < 5.1 ) {
        return $mprpvers;
    }

    if ( $vfields[2] == 0 && $vfields[3] == 0) {
        return $mprpvers;
    }

    # x.y.mmm.nnn (x.y is 5.1 or 6.0 or later)
    #     --- -
    #     ||| |
    #     ||| ----- P  #
    #     ||------- RP #
    #     |-------- PR #
    #     --------- SP #
    $sp = $vfields[2];
    if ($sp =~/[0-9][0-9][0-9]$/) {
        $sp =~ s/^.*([0-9])[0-9][0-9]$/$1/m;
    } else {
        $sp = "";
    }

    $pr = $vfields[2];
    if ($pr =~ /[0-9][0-9]$/) {
        $pr =~ s/^.*([0-9])[0-9]$/$1/m;
    } else {
        $pr = "";
    }

    $rp = $vfields[2];
    if ($rp =~ /[0-9]$/) {
        $rp =~ s/^.*([0-9])$/$1/m;
    } else {
        $rp = "";
    }

    $p = $vfields[3];
    if ($p =~ /[0-9]$/) {
        $p =~ s/^.*([0-9])$/$1/m;
    } else {
        $p = "";
    }

    if ($sp) {
        $mprpvers .= "SP$sp";
    }
    if ($pr) {
        unless (($padv =~ /aix/ && $mprpvers eq "5.1SP1" && $pr eq "1")) {
            $mprpvers .= "PR$pr";
        }
    }
    if ($rp) {
        $mprpvers .= "RP$rp";
    }
    if ($p && ! $noP) {
        $mprpvers .= "P$p";
    }
    return $mprpvers;
}

sub get_at_all_pkgs{
    my ($rel, $mpvers) = @_;
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};
    if ($padv=~/sles|rhel/){
        return EDRu::arruniq(sort qw/VRTSatClient VRTSatServer/);
    }
    return EDRu::arruniq(sort qw/VRTSat/);
}

sub get_at_required_pkgs{
    my ($rel) = @_;
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};
    if ($padv=~/sles|rhel/){
        return EDRu::arruniq(sort qw/VRTSatClient/);
    }
    return EDRu::arruniq(sort qw/VRTSat/);
}

sub get_at_optional_pkgs{
    my ($rel) = @_;
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};
    if ($padv=~/sles|rhel/){
        return EDRu::arruniq(sort qw/VRTSatServer/);
    }
    return EDRu::arruniq(sort qw//);
}


sub pkgvers_to_relvers_mapping {
    my ($rel, $pkgvers) = @_;
    my ($padv);

    $padv = $rel->{padv_managed_host_for_vc};

    if ( $pkgvers eq '6.0SP1' ) {
        $pkgvers = '6.0.1';
    }
    if ( $pkgvers eq '6.0SP2' ) {
        $pkgvers = '6.0.2';
    }
    if ( $pkgvers eq '6.0SP3' ) {
        $pkgvers = '6.0.3';
    }
    if ( $pkgvers eq '6.0SP4' ) {
        $pkgvers = '6.0.4';
    }
    if ( $pkgvers eq '6.1RP1' ) {
        $pkgvers = '6.1.1';
    }
    if ($padv=~/sles|rhel/ && $pkgvers eq '5.1SP1PR3RP2'){
        $pkgvers = '5.1SP1RP2';
    }
    if ($padv=~/aix/ && $pkgvers eq '5.1SP1PR1RP2'){
        $pkgvers = '5.1SP1RP2';
    }
    if ($pkgvers eq '5.1SP1PR3RP4') {
        $pkgvers = '5.1SP1RP4';
    }
    return $pkgvers;
}

1;

