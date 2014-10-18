use strict;

package Rel;

# return the major version like 4.1, 5.0, 5.1 from the passed version string
# the version string could be 5.0MP3 or a regular version string like 5.0.30.00
sub get_major_vers {
    my ($rel, $vers) = @_;
    my @vfields = split(/\./m, $vers);
    $vfields[0] =~ s/\D.*$//m;
    $vfields[0] += 0;
    $vfields[1] =~ s/\D.*$//m;
    $vfields[1] += 0;
    return join('.', $vfields[0], $vfields[1]);
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

sub is_vr_licensed_sys {
    my ($rel, $sys) = @_;
    my ($output);
    if (grep {/Volume Replicator/} $rel->get_licensed_prods_sys($sys)) {
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
    if (grep {/File Replicator/} $rel->get_licensed_prods_sys($sys)) {
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
        'VCS'      => 'Veritas Cluster Server',
        'VVR'      => 'Veritas Volume Replicator',
        'VFR'      => 'Veritas File Replicator',
        'DMP'      => 'Veritas Dynamic Multipathing',
        'SVS'      => 'Symantec VirtualStore',
        'SF'       => 'Veritas Storage Foundation',
        'SFHA'     => 'Veritas Storage Foundation and High Availability',
        'SFORA'    => 'Veritas Storage Foundation for Oracle',
        'SFORAHA'  => 'Veritas Storage Foundation for Oracle/HA',
        'SFDB2'    => 'Veritas Storage Foundation for DB2',
        'SFDB2HA'  => 'Veritas Storage Foundation for DB2/HA',
        'SFCFS'    => 'Veritas Storage Foundation Cluster File System',
        'SFCFSHA'  => 'Veritas Storage Foundation Cluster File System/HA',
        'SFSYB'    => 'Veritas Storage Foundation for Sybase',
        'SFSYBHA'  => 'Veritas Storage Foundation for Sybase/HA',
        'SFRAC'    => 'Veritas Storage Foundation for Oracle RAC',
        'SFCFSRAC' => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
        'SFSYBASECE' => 'Veritas Storage Foundation for Sybase ASE CE',
        'AT'       => 'Symantec Product Authentication Services',
    );
    return (exists($vrtsprods{$ucprod})) ? $vrtsprods{$ucprod} : "$ucprod";
}

# E.g. get 5.1SP1 from 5.1.101.000
# For 5.1 and later releases only
sub get_new_mpvers{
    my ($rel, $pkgvers) = @_;
    my ($mpvers, @vfields, $sp, $pr);
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
    return $mpvers;
}

# E.g. get 5.1SP1RP1 from 5.1.101.000
# For 5.1 and later releases only
sub get_new_mprpvers{
    my ($rel, $pkgvers, $noP) = @_;
    my ($mprpvers, @vfields, $rp, $sp, $pr, $p);
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
        $mprpvers .= "PR$pr";
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
    return EDRu::arruniq(sort qw/VRTSat/);
}
sub get_at_required_pkgs{
    my ($rel, $mpvers) = @_;
    return EDRu::arruniq(sort qw/VRTSat/);
}
sub get_at_optional_pkgs{
    my ($rel, $mpvers) = @_;
    return EDRu::arruniq(sort qw//);
}

sub pkgvers_to_relvers_mapping {
    my ($rel, $pkgvers) = @_;
    return $pkgvers;
}

sub get_fallback_releases {
    my ($rel, $mpvers) = @_;
    my ($majorvers, $release, @releases, $rellvl, $relnum);
    $majorvers = $rel->get_major_vers($mpvers);

    @releases = ();
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
    my (@requiredpkgs, $release);
    if ( $prod eq "at" ) {
        return $rel->get_at_required_pkgs($mpvers);
    }
    if (exists($rel->{rel}{$mpvers})
        && exists($rel->{rel}{$mpvers}{prod})
        && exists($rel->{rel}{$mpvers}{prod}{$prod})) {
        @requiredpkgs = @{$rel->{rel}{$mpvers}{prod}{$prod}{rpkgs}};
    } else {
        for my $release ($rel->get_fallback_releases($mpvers)) {
            if (exists($rel->{rel}{$release})
                && exists($rel->{rel}{$release}{prod})
                && exists($rel->{rel}{$release}{prod}{$prod})) {
                @requiredpkgs = @{$rel->{rel}{$release}{prod}{$prod}{rpkgs}};
                last;
            }
        }
    }
    return EDRu::arruniq(sort @requiredpkgs);
}

sub get_prod_optional_pkgs {
    my ($rel, $prod, $mpvers) = @_;
    my (@optionalpkgs, $release);
    if ( $prod eq "at" ) {
        return $rel->get_at_optional_pkgs($mpvers);
    }
    if (exists($rel->{rel}{$mpvers})
        && exists($rel->{rel}{$mpvers}{prod})
            && exists($rel->{rel}{$mpvers}{prod}{$prod})) {
        @optionalpkgs = @{$rel->{rel}{$mpvers}{prod}{$prod}{opkgs}};
    } else {
        for my $release ($rel->get_fallback_releases($mpvers)) {
            if (exists($rel->{rel}{$release})
                && exists($rel->{rel}{$release}{prod})
                && exists($rel->{rel}{$release}{prod}{$prod})) {
                @optionalpkgs = @{$rel->{rel}{$release}{prod}{$prod}{opkgs}};
                last;
            }
        }
    }
    return EDRu::arruniq(sort @optionalpkgs);
}

sub get_prod_all_pkgs {
    my ($rel, $prod, $mpvers) = @_;
    my (@allpkgs, $release);
    if ( $prod eq "at" ) {
        return $rel->get_at_all_pkgs($mpvers);
    }
    if (exists($rel->{rel}{$mpvers})
        && exists($rel->{rel}{$mpvers}{prod})
        && exists($rel->{rel}{$mpvers}{prod}{$prod})) {
        push @allpkgs, @{$rel->{rel}{$mpvers}{prod}{$prod}{rpkgs}};
        push @allpkgs, @{$rel->{rel}{$mpvers}{prod}{$prod}{opkgs}};
    } else {
        for my $release ($rel->get_fallback_releases($mpvers)) {
            if (exists($rel->{rel}{$release})
                && exists($rel->{rel}{$release}{prod})
                && exists($rel->{rel}{$release}{prod}{$prod})) {
                push @allpkgs, @{$rel->{rel}{$release}{prod}{$prod}{rpkgs}};
                push @allpkgs, @{$rel->{rel}{$release}{prod}{$prod}{opkgs}};
                last;
            }
        }
    }
    return EDRu::arruniq(sort @allpkgs);
}

sub get_rel_pkgs_mapping_patches {
    my ($rel, $relvers, $pkgs, $osvers) = @_;
    my ($pkg, $patch, @patches, @supp_osvers);
    for my $patch (keys %{$rel->{rel}{$relvers}{patch}}) {
        if ($osvers) {
            # Solaris allows undefined {osvers} values which default to ALL (5.8 5.9 5.10)
            @supp_osvers = qw(5.8 5.9 5.10);
            if (exists($rel->{rel}{$relvers}{patch}{$patch}{osvers})) {
                @supp_osvers = @{$rel->{rel}{$relvers}{patch}{$patch}{osvers}};
            }
            next unless (EDRu::inarr($osvers, @supp_osvers));
        }
        for my $pkg (@{$rel->{rel}{$relvers}{patch}{$patch}{pkgs}}) {
            push @patches, $patch if (EDRu::inarr($pkg, @{$pkgs}));
        }
    }
    return EDRu::arruniq(sort @patches);
}

sub get_rel_pkgs_mapping_patches_sfsybasece {
    my ($rel, $relvers, $pkgs, $osvers) = @_;
    my ($pkg, $patch, @patches, @supp_osvers);
    for my $patch (keys %{$rel->{rel}{$relvers}{sfsybasece_patch}}) {
        if ($osvers) {
            # Solaris allows undefined {osvers} values which default to ALL (5.8 5.9 5.10)
            @supp_osvers = qw(5.8 5.9 5.10);
            if (exists($rel->{rel}{$relvers}{sfsybasece_patch}{$patch}{osvers})) {
                @supp_osvers = @{$rel->{rel}{$relvers}{sfsybasece_patch}{$patch}{osvers}};
            }
            next unless (EDRu::inarr($osvers, @supp_osvers));
        }
        for my $pkg (@{$rel->{rel}{$relvers}{sfsybasece_patch}{$patch}{pkgs}}) {
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
    my ($prod, $mainpkg, $majorvers, $mpvers, $mprpvers, $platvers);
    my (@releases, @reversed_releases, $idx, $pos1, $pos2, $relvers, $prodname);
    my ($allpkgs,$patch,$patches,$patchid,$patchvers,%count,$pkg,$obpatch);
    my (@mainpkgs,$tmp_majorvers, $tmp_mpvers, $tmp_mprpvers, $defined_vers, @relpatches, $patchdefs);

    @releases = @{$rel->{releases}};
    @reversed_releases = reverse @releases;
    $platvers = ($sys->sunos()) ? $sys->{platvers} : '';

    for my $prod (sort keys %{$sys->{iprod}}) {
        $majorvers = '';
        $mpvers = '';
        $mprpvers = '';
        @mainpkgs = split(/\s/m, $sys->{iprod}{$prod}{imainpkg});

        for my $mainpkg (@mainpkgs) {
            # check major version of installed prod
            $tmp_majorvers = $rel->get_major_vers($sys->{pkgvers}{$mainpkg});

            # check mp version of installed prod
            $tmp_mpvers = $rel->pkg_inst_mpvers_sys($sys, $mainpkg);

            # check mprp version of installed prod
            $tmp_mprpvers = $rel->pkg_inst_mprpvers_sys($sys, $mainpkg);

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
                    @relpatches = keys %{$rel->{rel}{$relvers}{sfsybasece_patch}};
                } else {
                    @relpatches = keys %{$rel->{rel}{$relvers}{patch}};
                }

                for my $patch (@relpatches) {
                    if (EDRu::inarr($patch, @{$sys->{patches}})){
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

        # check name of installed prod
        if (exists($rel->{rel}{$mpvers})
            && exists($rel->{rel}{$mpvers}{prod})
            && exists($rel->{rel}{$mpvers}{prod}{$prod})) {
            $prodname = $rel->{rel}{$mpvers}{prod}{$prod}{name};
        } elsif (exists($rel->{rel}{$majorvers})
            && exists($rel->{rel}{$majorvers}{prod})
            && exists($rel->{rel}{$majorvers}{prod}{$prod})) {
            $prodname = $rel->{rel}{$majorvers}{prod}{$prod}{name};
        } else {
            $prodname = $rel->get_common_prodname($prod);
        }

        # set name, major vers, mp vers, mprp vers of installed product
        $sys->{iprod}{$prod}{name} = $prodname;
        $sys->{iprod}{$prod}{mjvers} = $majorvers;
        $sys->{iprod}{$prod}{mpvers} = $mpvers;
        $sys->{iprod}{$prod}{mprpvers} = $mprpvers;

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
                $patchdefs = $rel->{rel}{$relvers}{sfsybasece_patch};
            } else {
                $patches = $rel->get_rel_pkgs_mapping_patches($relvers, $allpkgs, $platvers);
                $patchdefs = $rel->{rel}{$relvers}{patch};
            }
            for my $patch (@{$patches}) {
                next if ($count{$prod}{instpatch}{$patch});
                if ($sys->sunos()) {
                    ($patchid, $patchvers) = split(/-/m, $patch, 2);
                    next if ($count{$prod}{patchid}{$patchid}++);
                }
                if (exists($patchdefs->{$patch}{obsoletes})) {
                    for my $obpatch (@{$patchdefs->{$patch}{obsoletes}}) {
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
                    $sys->{iprod}{$prod}{ipatches}{$relvers}{$patch} = [@{$patchdefs->{$patch}{pkgs}}];
                } else {
                    next if ($count{$prod}{obpatch}{$patch});
                    $sys->{iprod}{$prod}{mpatches}{$relvers}{$patch} = [@{$patchdefs->{$patch}{pkgs}}];
                }
            }
        }
    }
    return '';
}

sub output_installed_pkgs_patches_for_version_history{
    my ($rel, $sys) = @_;
    my ($format,$pstamp,$rootpath);

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
        for my $release (sort keys %{$rel->{rel}}) {
            if ($rel->{rel}{$release}{patch}) {
                for my $patchid (sort keys %{$rel->{rel}{$release}{patch}}) {
                    if (EDRu::inarr($patchid, @{$sys->{patches}})) {
                        for my $pkg (sort @{$rel->{rel}{$release}{patch}{$patchid}{pkgs}}) {
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

package Rel::UXRT60SP1PR1::SunOS;

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($output, $line, $mjvers, $mpvers, $rootpath);
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

sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($output, $line, $mjvers, $mprpvers, $rootpath);
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

sub set_inst_vrtsprods_sys {
    my ($rel, $sys) = @_;
    my ($checksf, $checkvcs, $checkfs, $checkvm, $checkat);

    $checksf = $checkvcs = 1;
    $checkat = 1;

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
            if ($sys->{padv} eq 'Sol10sparc' && $sys->{pkgvers}{VRTSvcsea} && grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                $sys->{iprod}{sfsybasece}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
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
            if ($sys->{pkgvers}{VRTSvcs} && $sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{VRTSvxvm}) {
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
            }else{
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
    return '';
}

package Rel::UXRT60SP1PR1::SolSparc;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        4.1
        4.1MP1
        4.1MP2
        4.1MP2RP2
        4.1MP2RP3
        4.1MP2RP4
        4.1MP2RP5
        4.1MP2RP6
        5.0
        5.0MP1
        5.0MP1RP1
        5.0MP1RP2
        5.0MP1RP3
        5.0MP1RP4
        5.0MP1RP5
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0MP3RP4
        5.0MP3RP5
        5.1
        5.1P1
        5.1RP1
        5.1RP1P1
        5.1RP2
        5.1SP1
        5.1SP1RP1
        5.1SP1PR3
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

    $rel->{rel} = {
        '4.1' => {
            #_START_SolSparc_4.1_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfspro VRTSfssdk VRTSob VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvail VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScavf VRTScpi VRTSddlpr VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2gui VRTSdb2ed VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvail VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScpi VRTScscw VRTScutil VRTSd2gui VRTSdb2ed VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvail VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSvxfen)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSvxfen)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScsocw VRTSdbed VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSodm VRTSorgui VRTSperl VRTSvail VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScpi VRTScscw VRTScsocw VRTScutil VRTSdbed VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSodm VRTSorgui VRTSperl VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSvxfen)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSalloc VRTSap VRTSat VRTScavf VRTScpi VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbckp VRTSddlpr VRTSfsdoc VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSjre VRTSllt VRTSob VRTSobgui VRTSodm VRTSormap VRTSperl VRTStep VRTSvail VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSsybed VRTSvail VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfas VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSsybed VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfasag VRTSfasdc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSvxfen)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSat VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsw VRTSvlic VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn VRTSvxfen)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
            },
            #_END_SolSparc_4.1_PRODS_PKGS_DEF_
            #_START_SolSparc_4.1_PATCHES_DEF_
            'patch' => {
                '115209-16' => { 'pkgs' => [qw(VRTSob)] },
                '115210-16' => { 'pkgs' => [qw(VRTSobgui)] },
                '117499-02' => {
                    'pkgs'   => [qw(VRTSat)],
                    'osvers' => [qw(5.6 5.7 5.8 5.9)],
                },
            },
            #_END_SolSparc_4.1_PATCHES_DEF_
        },
        '4.1MP1' => {
            #_START_SolSparc_4.1MP1_PATCHES_DEF_
            'patch' => {
                '115209-23' => { 'pkgs' => [qw(VRTSob)] },
                '115210-23' => { 'pkgs' => [qw(VRTSobgui)] },
                '117080-04' => { 'pkgs' => [qw(VRTSvxvm)] },
                '119300-02' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '119301-02' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '119302-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '119303-01' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.8)],
                },
                '119304-01' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '119305-01' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '119306-01' => { 'pkgs' => [qw(VRTSfspro)] },
                '119735-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '119737-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.8)],
                },
                '119738-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '119739-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '119745-01' => { 'pkgs' => [qw(VRTSddlpr)] },
                '119746-02' => { 'pkgs' => [qw(VRTSalloc)] },
                '120114-03' => { 'pkgs' => [qw(VRTSdbed)] },
                '120115-01' => { 'pkgs' => [qw(VRTSorgui)] },
                '120116-01' => { 'pkgs' => [qw(VRTSdb2ed)] },
                '120117-01' => { 'pkgs' => [qw(VRTSd2gui)] },
                '120118-01' => { 'pkgs' => [qw(VRTSsybed)] },
                '120120-01' => { 'pkgs' => [qw(VRTSormap)] },
                '120143-01' => {
                    'pkgs'   => [qw(VRTSfas)],
                    'osvers' => [qw(5.7 5.8 5.9)],
                },
                '120144-01' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                },
                '120145-01' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '120146-01' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag VRTSvcsmg)],
                    'osvers' => [qw(5.10)],
                },
                '120147-01' => { 'pkgs' => [qw(VRTSvcsor)] },
                '120148-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                },
                '120149-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '120150-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '120151-01' => { 'pkgs' => [qw(VRTSvmpro)] },
                '120156-02' => {
                    'pkgs'   => [qw(VRTSvail)],
                    'osvers' => [qw(5.7 5.8 5.9)],
                },
                '120161-01' => { 'pkgs' => [qw(VRTSvcssy)] },
                '120871-01' => {
                    'pkgs'   => [qw(VRTScscm VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '121372-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_4.1MP1_PATCHES_DEF_
        },
        '4.1MP2' => {
            #_START_SolSparc_4.1MP2_PATCHES_DEF_
            'patch' => {
                '115209-26' => { 'pkgs' => [qw(VRTSob)] },
                '115210-26' => { 'pkgs' => [qw(VRTSobgui)] },
                '117080-07' => { 'pkgs' => [qw(VRTSvxvm)] },
                '119300-04' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '119301-04' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '119302-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '119303-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.8)],
                },
                '119304-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '119305-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '119735-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '119737-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.8)],
                },
                '119738-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '119739-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '119745-02' => { 'pkgs' => [qw(VRTSddlpr)] },
                '120144-02' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                },
                '120145-02' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '120146-02' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag VRTSvcsmg)],
                    'osvers' => [qw(5.10)],
                },
                '120147-02' => { 'pkgs' => [qw(VRTSvcsor)] },
                '120148-02' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                },
                '120149-02' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '120150-02' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '120151-03' => { 'pkgs' => [qw(VRTSvmpro)] },
                '120871-02' => {
                    'pkgs'   => [qw(VRTScscm VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '121372-02' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '124355-01' => { 'pkgs' => [qw(VRTSvmman)] },
            },
            #_END_SolSparc_4.1MP2_PATCHES_DEF_
        },
        '4.1MP2RP2' => {
            #_START_SolSparc_4.1MP2RP2_PATCHES_DEF_
            'patch' => {
                '123830-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '125757-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.8)],
                },
                '125758-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '125759-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '125769-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '125770-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '139364-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.8)],
                },
                '139374-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.9)],
                },
                '139376-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_4.1MP2RP2_PATCHES_DEF_
        },
        '4.1MP2RP3' => {
            #_START_SolSparc_4.1MP2RP3_PATCHES_DEF_
            'patch' => {
                '123830-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '125769-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '125770-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_4.1MP2RP3_PATCHES_DEF_
        },
        '4.1MP2RP4' => {
            #_START_SolSparc_4.1MP2RP4_PATCHES_DEF_
            'patch' => {
                '115209-28' => { 'pkgs' => [qw(VRTSob)] },
                '115210-28' => { 'pkgs' => [qw(VRTSobgui)] },
                '123827-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '123828-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '123829-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '124358-06' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(124354-02)],
                },
                '139365-01' => { 'pkgs' => [qw(VRTSap)] },
            },
            #_END_SolSparc_4.1MP2RP4_PATCHES_DEF_
        },
        '4.1MP2RP5' => {
            #_START_SolSparc_4.1MP2RP5_PATCHES_DEF_
            'patch' => {
                '123827-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '123828-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '123829-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '124358-07' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(124354-02)],
                },
            },
            #_END_SolSparc_4.1MP2RP5_PATCHES_DEF_
        },
        '4.1MP2RP6' => {
            #_START_SolSparc_4.1MP2RP6_PATCHES_DEF_
            'patch' => {
                '124358-08' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(124354-02)],
                },
            },
            #_END_SolSparc_4.1MP2RP6_PATCHES_DEF_
        },
        '5.0' => {
            #_START_SolSparc_5.0_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfasdc VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfasdc VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfasdc VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfasdc VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsdoc VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSsybed VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSsybed VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvmdoc VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSicsco VRTSpbx VRTSat VRTSobc33 VRTSob VRTSobgui VRTSccg VRTSmh VRTSaa VRTSspt VRTSvxfs VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSvcsag VRTSjre15 VRTScutil VRTScscw VRTSweb VRTSacclib VRTSvxvm VRTSdsa VRTSfspro VRTSvmpro VRTSdcli VRTSalloc VRTSvdid VRTSddlpr VRTSvrpro VRTSvcsvr VRTSvrw VRTSfssdk VRTSglm VRTScavf VRTSvxmsa VRTSvcssy)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
            },
            #_END_SolSparc_5.0_PRODS_PKGS_DEF_
            #_START_SolSparc_5.0_PATCHES_DEF_
            'patch' => {
                '121705-01' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '121706-01' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '121707-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '122058-01' => { 'pkgs' => [qw(VRTSvxvm)] },
            },
            #_START_SolSparc_5.0_SFSYBASECE_PATCHES_DEF_ 
            'sfsybasece_patch' => {
                '121714-03' => {
                    'pkgs' => [qw(VRTSfspro)],
                },
                '122058-11' => {
                    'pkgs' => [qw(VRTSvxvm)],
                },
                '122631-23' => {
                    'pkgs' => [qw(VRTSob)],
                },
                '122632-23' => {
                    'pkgs' => [qw(VRTSobc33)],
                },
                '122633-21' => {
                    'pkgs' => [qw(VRTSobgui)],
                },
                '123075-21' => {
                    'pkgs' => [qw(VRTSaa)],
                },
                '123076-21' => {
                    'pkgs' => [qw(VRTSccg)],
                },
                '123079-21' => {
                    'pkgs' => [qw(VRTSmh)],
                },
                '123085-04' => {
                    'pkgs' => [qw(VRTSglm)],
                    'osvers' => [qw(5.8)],
                },
                '123086-04' => {
                    'pkgs' => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '123087-04' => {
                    'pkgs' => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '123200-04' => {
                    'pkgs' => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '123201-04' => {
                    'pkgs' => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '123202-04' => {
                    'pkgs' => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '123207-03' => {
                    'pkgs' => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.8)],
                },
                '123208-03' => {
                    'pkgs' => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.9)],
                },
                '123209-03' => {
                    'pkgs' => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '123210-03' => {
                    'pkgs' => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '123211-03' => {
                    'pkgs' => [qw(VRTScssim)],
                    'osvers' => [qw(5.10)],
                },
                '123722-01' => {
                    'pkgs' => [qw(VRTSat)],
                },
                '123740-04' => {
                    'pkgs' => [qw(VRTSvmpro)],
                },
                '123742-05' => {
                    'pkgs' => [qw(VRTSdcli)],
                },
                '123743-03' => {
                    'pkgs' => [qw(VRTSvrpro)],
                },
                '123744-03' => {
                    'pkgs' => [qw(VRTSvrw)],
                },
                '123818-02' => {
                    'pkgs' => [qw(VRTSvmman)],
                },
                '123821-03' => {
                    'pkgs' => [qw(VRTSalloc)],
                },
                '123823-03' => {
                    'pkgs' => [qw(VRTSddlpr)],
                },
                '123983-01' => {
                    'pkgs' => [qw(VRTScmccc)],
                },
                '123984-01' => {
                    'pkgs' => [qw(VRTScmcs)],
                },
                '125150-07' => {
                    'pkgs' => [qw(VRTSjre15)],
                },
                '127317-02' => {
                    'pkgs' => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '127318-02' => {
                    'pkgs' => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '127319-02' => {
                    'pkgs' => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '128078-01' => {
                    'pkgs' => [qw(VRTSfsman)],
                },
                '137329-01' => {
                    'pkgs' => [qw(VRTSfssdk)],
                },
                '137338-01' => {
                    'pkgs' => [qw(VRTSpbx)],
                },
                '137385-01' => {
                    'pkgs' => [qw(VRTSvxmsa)],
                },
            },
            #_END_SolSparc_5.0_SFSYBASECE_PATCHES_DEF_
            #_END_SolSparc_5.0_PATCHES_DEF_
        },
        '5.0MP1' => {
            #_START_SolSparc_5.0MP1_PATCHES_DEF_
            'patch' => {
                '121708-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.8)],
                },
                '121709-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '121710-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '121711-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '121714-01' => { 'pkgs' => [qw(VRTSfspro)] },
                '121715-02' => { 'pkgs' => [qw(VRTSfsweb)] },
                '122058-09' => { 'pkgs' => [qw(VRTSvxvm)] },
                '122631-02' => { 'pkgs' => [qw(VRTSob)] },
                '122632-02' => { 'pkgs' => [qw(VRTSobc33)] },
                '122633-02' => { 'pkgs' => [qw(VRTSobgui)] },
                '122634-02' => { 'pkgs' => [qw(VRTSobweb)] },
                '123075-02' => { 'pkgs' => [qw(VRTSaa)] },
                '123076-02' => { 'pkgs' => [qw(VRTSccg)] },
                '123077-02' => { 'pkgs' => [qw(VRTScs)] },
                '123078-02' => { 'pkgs' => [qw(VRTScweb)] },
                '123079-02' => { 'pkgs' => [qw(VRTSmh)] },
                '123085-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.8)],
                },
                '123086-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '123087-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '123200-02' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '123201-02' => {
                    'pkgs'   => [qw(VRTSfsman VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '123202-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '123207-01' => {
                    'pkgs'   => [qw(VRTScscm VRTScssim VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                },
                '123208-01' => {
                    'pkgs'   => [qw(VRTScscm VRTScssim VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '123209-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '123210-01' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '123211-01' => {
                    'pkgs'   => [qw(VRTScscm VRTScssim)],
                    'osvers' => [qw(5.10)],
                },
                '123214-01' => { 'pkgs' => [qw(VRTSdbed)] },
                '123215-02' => { 'pkgs' => [qw(VRTSorgui)] },
                '123216-02' => { 'pkgs' => [qw(VRTSdbcom)] },
                '123217-02' => { 'pkgs' => [qw(VRTSd2gui)] },
                '123218-01' => { 'pkgs' => [qw(VRTSdb2ed)] },
                '123219-01' => { 'pkgs' => [qw(VRTSsybed)] },
                '123220-03' => { 'pkgs' => [qw(VRTSmapro)] },
                '123670-01' => { 'pkgs' => [qw(VRTScsocw VRTSvcsor)] },
                '123671-01' => { 'pkgs' => [qw(VRTSvcssy)] },
                '123672-01' => { 'pkgs' => [qw(VRTSvcsdb)] },
                '123673-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                },
                '123674-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '123675-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '123678-04' => {
                    'pkgs'   => [qw(VRTSat)],
                    'osvers' => [qw(5.6 5.7 5.8 5.9)],
                },
                '123738-02' => { 'pkgs' => [qw(VRTSvmweb)] },
                '123740-02' => { 'pkgs' => [qw(VRTSvmpro)] },
                '123742-02' => { 'pkgs' => [qw(VRTSdcli)] },
                '123743-02' => { 'pkgs' => [qw(VRTSvrpro)] },
                '123744-03' => { 'pkgs' => [qw(VRTSvrw)] },
                '123818-01' => { 'pkgs' => [qw(VRTSvmman)] },
                '123819-02' => { 'pkgs' => [qw(VRTScsdoc)] },
                '123821-02' => { 'pkgs' => [qw(VRTSalloc)] },
                '123823-01' => { 'pkgs' => [qw(VRTSddlpr)] },
                '123983-01' => {
                    'pkgs'   => [qw(VRTScmccc)],
                    'osvers' => [qw(5.8)],
                },
                '123984-01' => {
                    'pkgs'   => [qw(VRTScmcs)],
                    'osvers' => [qw(5.8)],
                },
                '123985-01' => {
                    'pkgs'   => [qw(VRTScmcm)],
                    'osvers' => [qw(5.8)],
                },
                '123995-05' => { 'pkgs' => [qw(SYMClma)] },
                '123996-06' => { 'pkgs' => [qw(VRTSsmf)] },
                '124002-02' => { 'pkgs' => [qw(VRTSvsvc)] },
                '124004-02' => { 'pkgs' => [qw(VRTSvail)] },
            },
            #_END_SolSparc_5.0MP1_PATCHES_DEF_
        },
        '5.0MP1RP1' => {
            #_START_SolSparc_5.0MP1RP1_PATCHES_DEF_
            'patch' => {
                '123742-04' => { 'pkgs' => [qw(VRTSdcli)] },
                '124361-01' => { 'pkgs' => [qw(VRTSvxvm)] },
                '125760-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '125761-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '125762-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP1RP1_PATCHES_DEF_
        },
        '5.0MP1RP2' => {
            #_START_SolSparc_5.0MP1RP2_PATCHES_DEF_
            'patch' => {
                '122631-08' => { 'pkgs' => [qw(VRTSob)] },
                '122632-08' => { 'pkgs' => [qw(VRTSobc33)] },
                '122633-08' => { 'pkgs' => [qw(VRTSobgui)] },
                '123075-06' => { 'pkgs' => [qw(VRTSaa)] },
                '123076-06' => { 'pkgs' => [qw(VRTSccg)] },
                '124361-03' => { 'pkgs' => [qw(VRTSvxvm)] },
                '125760-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '125761-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '125762-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP1RP2_PATCHES_DEF_
        },
        '5.0MP1RP3' => {
            #_START_SolSparc_5.0MP1RP3_PATCHES_DEF_
            'patch' => {
                '124361-04' => { 'pkgs' => [qw(VRTSvxvm)] },
                '125760-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '125761-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '125762-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP1RP3_PATCHES_DEF_
        },
        '5.0MP1RP4' => {
            #_START_SolSparc_5.0MP1RP4_PATCHES_DEF_
            'patch' => {
                '124361-05' => { 'pkgs' => [qw(VRTSvxvm)] },
                '125760-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '125761-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '125762-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '127344-01' => { 'pkgs' => [qw(VRTSvmpro)] },
            },
            #_END_SolSparc_5.0MP1RP4_PATCHES_DEF_
        },
        '5.0MP1RP5' => {
            #_START_SolSparc_5.0MP1RP5_PATCHES_DEF_
            'patch' => {
                '124361-06' => { 'pkgs' => [qw(VRTSvxvm)] },
            },
            #_END_SolSparc_5.0MP1RP5_PATCHES_DEF_
        },
        '5.0MP3' => {
            #_START_SolSparc_5.0MP3_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfas VRTSfasag VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSsybed VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSsybed VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
            },
            #_END_SolSparc_5.0MP3_PRODS_PKGS_DEF_
            #_START_SolSparc_5.0MP3_PATCHES_DEF_
            'patch' => {
                '121708-05' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(125848-02)],
                },
                '121709-05' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125849-02)],
                },
                '121710-05' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125850-02)],
                },
                '121714-03' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '121715-03' => {
                    'pkgs'   => [qw(VRTSfsweb)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '122058-11' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(124361-06)],
                },
                '122631-23' => { 'pkgs' => [qw(VRTSob)] },
                '122632-23' => { 'pkgs' => [qw(VRTSobc33)] },
                '122633-21' => { 'pkgs' => [qw(VRTSobgui)] },
                '123075-21' => { 'pkgs' => [qw(VRTSaa)] },
                '123076-21' => { 'pkgs' => [qw(VRTSccg)] },
                '123079-21' => { 'pkgs' => [qw(VRTSmh)] },
                '123085-04' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(125763-01)],
                },
                '123086-04' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125764-01)],
                },
                '123087-04' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125765-01)],
                },
                '123088-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(125766-02)],
                },
                '123089-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125767-02)],
                },
                '123090-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125768-02)],
                },
                '123200-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(125760-05)],
                },
                '123201-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125761-05)],
                },
                '123202-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125762-05)],
                },
                '123207-03' => {
                    'pkgs'   => [qw(VRTSacclib VRTScscm VRTScssim VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsmn VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(126342-01 126355-01 127328-03 137334-02 137368-01)],
                },
                '123208-03' => {
                    'pkgs'   => [qw(VRTSacclib VRTScscm VRTScssim VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsmn VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(126343-01 126870-01 127329-03 137335-02 137368-01)],
                },
                '123209-03' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(126344-01 126871-01 137336-02)],
                },
                '123210-03' => {
                    'pkgs'   => [qw(VRTSacclib VRTSvcs VRTSvcsag VRTSvcsmg)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(126337-01 127330-03 128054-01 128055-01 137368-01)],
                },
                '123211-03' => {
                    'pkgs'   => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                    'osvers' => [qw(5.10)],
                },
                '123214-02' => { 'pkgs' => [qw(VRTSdbed)] },
                '123215-03' => { 'pkgs' => [qw(VRTSorgui)] },
                '123216-04' => { 'pkgs' => [qw(VRTSdbcom)] },
                '123217-03' => { 'pkgs' => [qw(VRTSd2gui)] },
                '123218-02' => { 'pkgs' => [qw(VRTSdb2ed)] },
                '123220-04' => { 'pkgs' => [qw(VRTSmapro)] },
                '123670-03' => {
                    'pkgs'      => [qw(VRTScsocw VRTSvcsor)],
                    'obsoletes' => [qw(127353-01)],
                },
                '123671-03' => {
                    'pkgs'      => [qw(VRTSvcssy)],
                    'obsoletes' => [qw(125860-01 128057-01 128086-02)],
                },
                '123672-03' => {
                    'pkgs'      => [qw(VRTSvcsdb)],
                    'obsoletes' => [qw(137345-01)],
                },
                '123673-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(128061-01)],
                },
                '123674-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(128062-01 137332-01)],
                },
                '123675-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(128064-01 137333-01)],
                },
                '123722-01' => {
                    'pkgs'      => [qw(VRTSat)],
                    'obsoletes' => [qw(123678-04)],
                },
                '123740-04' => {
                    'pkgs'      => [qw(VRTSvmpro)],
                    'obsoletes' => [qw(127344-02)],
                },
                '123742-05' => { 'pkgs' => [qw(VRTSdcli)] },
                '123743-03' => { 'pkgs' => [qw(VRTSvrpro)] },
                '123818-02' => { 'pkgs' => [qw(VRTSvmman)] },
                '123821-03' => { 'pkgs' => [qw(VRTSalloc)] },
                '123823-03' => { 'pkgs' => [qw(VRTSddlpr)] },
                '125150-07' => { 'pkgs' => [qw(VRTSjre15)] },
                '127317-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(123831-01)],
                },
                '127318-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125771-01)],
                },
                '127319-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125772-01)],
                },
                '127333-01' => { 'pkgs' => [qw(VRTSvlic)] },
                '128078-01' => { 'pkgs' => [qw(VRTSfsman)] },
                '137329-01' => { 'pkgs' => [qw(VRTSfssdk)] },
                '137338-01' => { 'pkgs' => [qw(VRTSpbx)] },
                '137385-01' => { 'pkgs' => [qw(VRTSvxmsa)] },
            },
            #_END_SolSparc_5.0MP3_PATCHES_DEF_
        },
        '5.0MP3RP1' => {
            #_START_SolSparc_5.0MP3RP1_PATCHES_DEF_
            'patch' => {
                '123722-02' => {
                    'pkgs'      => [qw(VRTSat)],
                    'obsoletes' => [qw(123678-04)],
                },
                '139345-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                },
                '139346-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '139347-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '139352-02' => { 'pkgs' => [qw(VRTSvxvm)] },
                '139354-01' => { 'pkgs' => [qw(VRTSvmman)] },
                '139356-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139149-01 139148-01 139155-01 139151-01 139349-01 139380-01)],
                },
                '139357-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(139149-01 139148-01 139156-01 139152-01 139350-01 139380-01)],
                },
                '139358-01' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139146-01 139149-01 139148-01 139153-01 139351-01 139380-01)],
                },
                '139359-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139157-01)],
                },
                '139362-01' => { 'pkgs' => [qw(VRTSdbms3)] },
                '139366-01' => { 'pkgs' => [qw(VRTSdbcom)] },
                '139367-01' => { 'pkgs' => [qw(VRTSdbed)] },
                '139368-01' => { 'pkgs' => [qw(VRTSorgui)] },
                '139369-01' => { 'pkgs' => [qw(VRTSdb2ed)] },
                '139370-01' => { 'pkgs' => [qw(VRTSd2gui)] },
                '139737-01' => { 'pkgs' => [qw(VRTSdcli)] },
                '139739-01' => { 'pkgs' => [qw(VRTSvmpro)] },
                '139741-01' => { 'pkgs' => [qw(VRTSob)] },
                '139742-01' => { 'pkgs' => [qw(VRTSobc33)] },
                '139743-01' => { 'pkgs' => [qw(VRTSaa)] },
                '139744-01' => { 'pkgs' => [qw(VRTSccg)] },
                '139753-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '139754-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '139755-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP3RP1_PATCHES_DEF_
        },
        '5.0MP3RP2' => {
            #_START_SolSparc_5.0MP3RP2_PATCHES_DEF_
            'patch' => {
                '122058-12' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(139352-02 124361-06)],
                },
                '123088-03' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(125766-02)],
                },
                '123089-03' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125767-02)],
                },
                '123090-03' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125768-02)],
                },
                '123200-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139345-02 125760-05)],
                },
                '123201-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125761-05 139346-02)],
                },
                '123202-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125762-05 139347-02)],
                },
                '123823-05' => { 'pkgs' => [qw(VRTSddlpr)] },
                '139356-02' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139149-01 139148-01 139155-01 139151-01 139349-01 139380-02)],
                },
                '139357-02' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(139149-01 139148-01 139156-01 139152-01 139350-01 139380-02)],
                },
                '139358-02' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139146-01 139149-01 139148-01 139153-01 139351-01 139380-02 140653-02)],
                },
                '139359-02' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139157-01 141282-01)],
                },
                '139362-02' => { 'pkgs' => [qw(VRTSdbms3)] },
                '139366-03' => { 'pkgs' => [qw(VRTSdbcom)] },
                '139367-02' => { 'pkgs' => [qw(VRTSdbed)] },
                '139368-02' => { 'pkgs' => [qw(VRTSorgui)] },
                '139369-02' => { 'pkgs' => [qw(VRTSdb2ed)] },
                '139370-02' => { 'pkgs' => [qw(VRTSd2gui)] },
                '139741-02' => { 'pkgs' => [qw(VRTSob)] },
                '139742-02' => { 'pkgs' => [qw(VRTSobc33)] },
                '139753-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '139754-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '139755-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '140657-01' => { 'pkgs' => [qw(VRTSdsa)] },
                '140661-01' => { 'pkgs' => [qw(VRTSobgui)] },
                '141272-01' => { 'pkgs' => [qw(VRTSsybed)] },
                '141279-01' => { 'pkgs' => [qw(VRTSmapro)] },
                '141284-02' => {
                    'pkgs'      => [qw(VRTScsocw VRTSvcsor)],
                    'obsoletes' => [qw(140660-01)],
                },
                '141285-02' => { 'pkgs' => [qw(VRTSvcsdb)] },
                '141286-02' => { 'pkgs' => [qw(VRTSvcssy)] },
                '141745-01' => { 'pkgs' => [qw(VRTSvcsvr)] },
            },
            #_END_SolSparc_5.0MP3RP2_PATCHES_DEF_
        },
        '5.0MP3RP3' => {
            #_START_SolSparc_5.0MP3RP3_PATCHES_DEF_
            'patch' => {
                '121714-04' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '122058-13' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(139352-02 124361-06)],
                },
                '123085-05' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(125763-01)],
                },
                '123086-05' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125764-01)],
                },
                '123087-05' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125765-01)],
                },
                '123200-06' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139345-02 125760-05)],
                },
                '123201-06' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125761-05 139346-02)],
                },
                '123202-06' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125762-05 139347-02)],
                },
                '123740-06' => {
                    'pkgs'      => [qw(VRTSvmpro)],
                    'obsoletes' => [qw(139739-01 127344-02)],
                },
                '123821-05' => { 'pkgs' => [qw(VRTSalloc)] },
                '128078-02' => { 'pkgs' => [qw(VRTSfsman)] },
                '139356-03' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139149-01 139148-01 139155-01 139151-01 139349-01 139380-02 142612-01 142593-01 141762-01)],
                },
                '139357-03' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(139149-01 139148-01 139156-01 139152-01 139350-01 139380-02 142613-01 142594-01 141763-01)],
                },
                '139358-03' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139146-01 139149-01 139148-01 139153-01 139351-01 139380-02 140653-02 142614-01 142595-01 141764-01 141747-01 140651-01 140650-02 140652-01 140653-02)],
                },
                '139359-03' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139157-01 141282-01)],
                },
                '139362-03' => { 'pkgs' => [qw(VRTSdbms3)] },
                '139366-04' => { 'pkgs' => [qw(VRTSdbcom)] },
                '139367-03' => { 'pkgs' => [qw(VRTSdbed)] },
                '139368-03' => { 'pkgs' => [qw(VRTSorgui)] },
                '139369-03' => { 'pkgs' => [qw(VRTSdb2ed)] },
                '139737-02' => { 'pkgs' => [qw(VRTSdcli)] },
                '139753-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '139754-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '139755-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '141284-03' => {
                    'pkgs'      => [qw(VRTScsocw VRTSvcsor)],
                    'obsoletes' => [qw(140660-02)],
                },
                '141285-03' => { 'pkgs' => [qw(VRTSvcsdb)] },
                '141286-03' => { 'pkgs' => [qw(VRTSvcssy)] },
                '142607-03' => {
                    'pkgs'   => [qw(VRTScscm)],
                    'osvers' => [qw(5.10)],
                },
                '142615-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                },
                '142616-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '142617-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP3RP3_PATCHES_DEF_
        },
        '5.0MP3RP4' => {
            #_START_SolSparc_5.0MP3RP4_PATCHES_DEF_
            'patch' => {
                '121714-05' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '122058-14' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(139352-02 124361-06)],
                },
                '123200-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139345-02 125760-05)],
                },
                '123201-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125761-05 139346-02)],
                },
                '123202-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125762-05 139347-02)],
                },
                '123740-07' => {
                    'pkgs'      => [qw(VRTSvmpro)],
                    'obsoletes' => [qw(139739-01 127344-02)],
                },
                '123821-06' => { 'pkgs' => [qw(VRTSalloc)] },
                '123823-06' => { 'pkgs' => [qw(VRTSddlpr)] },
                '139356-04' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139149-01 139148-01 139155-01 139151-01 139349-01 139380-02 142612-01 142593-01 141762-01)],
                },
                '139357-04' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(139149-01 139148-01 139156-01 139152-01 139350-01 139380-02 142613-01 142594-01 141763-01)],
                },
                '139358-04' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139146-01 139149-01 139148-01 139153-01 139351-01 139380-02 140653-02 142614-01 142595-01 141764-01 141747-01 140651-01 140650-02 140652-01 140653-02)],
                },
                '139359-04' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139157-01 141282-01)],
                },
                '139741-03' => { 'pkgs' => [qw(VRTSob)] },
                '139742-03' => { 'pkgs' => [qw(VRTSobc33)] },
                '139753-04' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '139754-04' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '139755-04' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '141284-04' => {
                    'pkgs'      => [qw(VRTScsocw VRTSvcsor)],
                    'obsoletes' => [qw(140660-02)],
                },
                '141285-04' => { 'pkgs' => [qw(VRTSvcsdb)] },
                '141286-04' => { 'pkgs' => [qw(VRTSvcssy)] },
                '142607-04' => {
                    'pkgs'   => [qw(VRTScscm)],
                    'osvers' => [qw(5.10)],
                },
                '142615-04' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                },
                '142616-04' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '142617-04' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP3RP4_PATCHES_DEF_
        },
        '5.0MP3RP5' => {
            #_START_SolSparc_5.0MP3RP5_PATCHES_DEF_
            'patch' => {
                '122058-15' => {
                    'pkgs'      => [qw(VRTSvxvm)],
                    'obsoletes' => [qw(139352-02 124361-06)],
                },
                '123200-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139345-02 125760-05)],
                },
                '123201-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(125761-05 139346-02)],
                },
                '123202-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125762-05 139347-02)],
                },
                '139356-05' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.8)],
                    'obsoletes' => [qw(139149-01 139148-01 139155-01 139151-01 139349-01 139380-02 142612-01 142593-01 141762-01)],
                },
                '139357-05' => {
                    'pkgs'   => [qw(VRTScscm VRTSgab VRTSllt VRTSvcs VRTSvcsag VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                    'obsoletes' => [qw(139149-01 139148-01 139156-01 139152-01 139350-01 139380-02 142613-01 142594-01 141763-01)],
                },
                '139358-05' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139146-01 139149-01 139148-01 139153-01 139351-01 139380-02 140653-02 142614-01 142595-01 141764-01 141747-01 140651-01 140650-02 140652-01 140653-02)],
                },
                '139359-05' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139157-01 141282-01)],
                },
                '139366-05' => { 'pkgs' => [qw(VRTSdbcom)] },
                '139367-04' => { 'pkgs' => [qw(VRTSdbed)] },
                '139368-04' => { 'pkgs' => [qw(VRTSorgui)] },
                '139753-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.8)],
                },
                '139754-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '139755-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '141284-06' => {
                    'pkgs'      => [qw(VRTScsocw VRTSvcsor)],
                    'obsoletes' => [qw(140660-02)],
                },
                '141285-07' => { 'pkgs' => [qw(VRTSvcsdb)] },
                '141286-06' => { 'pkgs' => [qw(VRTSvcssy)] },
                '142607-05' => {
                    'pkgs'   => [qw(VRTScscm)],
                    'osvers' => [qw(5.10)],
                },
                '142615-05' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.8)],
                },
                '142616-05' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '142617-05' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.0MP3RP5_PATCHES_DEF_
        },
        '5.1' => {
            #_START_SolSparc_5.1_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SolSparc_5.1_PRODS_PKGS_DEF_
        },
        '5.1P1' => {
            #_START_SolSparc_5.1P1_PATCHES_DEF_
            'patch' => {
                '142629-01' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142633-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143260-01' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.9)],
                },
                '143261-01' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143262-01' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.9)],
                },
                '143263-01' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143264-01' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143265-01' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143270-01' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '143271-01' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143273-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '143274-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1P1_PATCHES_DEF_
        },
        '5.1RP1' => {
            #_START_SolSparc_5.1RP1_PATCHES_DEF_
            'patch' => {
                '141270-02' => { 'pkgs' => [qw(VRTSsfmh)] },
                '142629-02' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142631-02' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142633-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143260-02' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.9)],
                },
                '143261-02' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143262-02' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.9)],
                },
                '143263-02' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143264-02' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143265-02' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143270-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '143271-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143273-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '143274-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143276-02' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143279-02' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143687-01' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143696-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '143697-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '143706-02' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '143707-02' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1RP1_PATCHES_DEF_
        },
        '5.1RP1P1' => {
            #_START_SolSparc_5.1RP1P1_PATCHES_DEF_
            'patch' => {
                '143260-03' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.9)],
                },
                '143261-03' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1RP1P1_PATCHES_DEF_
        },
        '5.1RP2' => {
            #_START_SolSparc_5.1RP2_PATCHES_DEF_
            'patch' => {
                '142629-05' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142631-03' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142633-03' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-03' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143262-03' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.9)],
                },
                '143263-03' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143264-07' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143265-07' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143270-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '143271-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143276-04' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143279-03' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143706-03' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '143707-03' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1RP2_PATCHES_DEF_
        },
        '5.1SP1' => {
            #_START_SolSparc_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSspt VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SolSparc_5.1SP1_PRODS_PKGS_DEF_
            #_START_SolSparc_5.1SP1_PATCHES_DEF_
            'patch' => {
                '142629-06' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142631-04' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142633-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143270-05' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '143271-05' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143273-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '143274-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143281-01' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.9)],
                },
                '143282-01' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143283-01' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.9)],
                },
                '143284-01' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143287-01' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143288-01' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143289-01' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143290-01' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143677-01' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.9)],
                },
                '143678-01' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                },
                '143680-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '143681-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '143687-02' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '145450-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '145451-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '145454-01' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '145455-01' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1SP1_PATCHES_DEF_
        },
        '5.1SP1RP1' => {
            #_START_SolSparc_5.1SP1RP1_PATCHES_DEF_
            'patch' => {
                '142629-09' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142633-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143270-06' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '143271-06' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143273-06' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '143274-06' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143287-03' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143288-04' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143289-02' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143290-03' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143680-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '143681-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '144159-01' => {
                    'pkgs'   => [qw(VRTSsfmh)],
                    'osvers' => [qw(5.8 5.9 5.10)],
                },
                '145454-02' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '145455-02' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '145471-01' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.9)],
                },
                '145473-01' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1SP1RP1_PATCHES_DEF_
        },
        '5.1SP1PR3' => {
            #_START_SolSparc_5.1SP1PR3_PRODS_PKGS_DEF_
            'prod' => {
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSsfmh VRTSvxfs VRTSat VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf VRTSsvs)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSfssdk VRTScps VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
            },
            #_END_SolSparc_5.1SP1PR3_PRODS_PKGS_DEF_
            #_START_SolSparc_5.1SP1PR3_PATCHES_DEF_
            'patch' => {
                '142633-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1SP1PR3_PATCHES_DEF_
        },
        '5.1SP1RP2' => {
            #_START_SolSparc_5.1SP1RP2_PATCHES_DEF_
            'patch' => {
                '142629-12' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142631-05' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '142633-09' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.9)],
                },
                '142634-09' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143270-07' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.9)],
                },
                '143271-07' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143273-07' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.9)],
                },
                '143274-07' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143281-03' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.9)],
                },
                '143282-03' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143283-02' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.9)],
                },
                '143284-02' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143287-07' => {
                    'pkgs'      => [qw(VRTSvcs)],
                    'osvers'    => [qw(5.9 5.10)],
                    'obsoletes' => [qw(146896-01)],
                },
                '143288-12' => {
                    'pkgs'      => [qw(VRTSvcsag)],
                    'osvers'    => [qw(5.9 5.10)],
                    'obsoletes' => [qw(146898-01)],
                },
                '143289-03' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143290-04' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '143680-03' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.9)],
                },
                '143681-03' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '143687-03' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '145450-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.9)],
                },
                '145451-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '145454-03' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.9)],
                },
                '145455-03' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '145471-02' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.9)],
                },
                '145473-02' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_SolSparc_5.1SP1RP2_PATCHES_DEF_
        },
        '6.0' => {
            #_START_SolSparc_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SolSparc_6.0_PRODS_PKGS_DEF_
        },
        '6.0RP1' => {
            #_START_SolSparc_6.0RP1_PATCHES_DEF_
            'patch' => {
                '146917-01' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '146918-01' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '147852-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '147853-02' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '147883-01' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.10)],
                },
                '147887-01' => {
                    'pkgs'   => [qw(VRTSvbs)],
                    'osvers' => [qw(5.9 5.10)],
                },
                '147893-01' => {
                    'pkgs'   => [qw(VRTSsfcpi60)],
                    'osvers' => [qw(5.10)],
                },
                '148452-01' => {
                    'pkgs'   => [qw(VRTSfsadv)],
                    'osvers' => [qw(5.10)],
                },
                '148453-01' => {
                    'pkgs'   => [qw(VRTSsvs)],
                    'osvers' => [qw(5.10)],
                },
                '148457-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '148462-01' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.9 5.10)],
                },
            },
            #_END_SolSparc_6.0RP1_PATCHES_DEF_
        },
        '6.0SP1' => {
            #_START_SolSparc_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SolSparc_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::Sol11sparc;

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
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
    }else {
        $mpvers = $rel->get_new_mpvers($sys->{pkgvers}{$pkg});
    }
    return $rel->pkgvers_to_relvers_mapping($mpvers);
}

sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mprpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
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
    }else {
        $mprpvers = $rel->get_new_mprpvers($sys->{pkgvers}{$pkg});
    }
    return $rel->pkgvers_to_relvers_mapping($mprpvers);
}

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        6.0PR1
        6.0SP1
    )];

    $rel->{rel} = {
        '6.0PR1' => {
            #_START_Sol11Sparc_6.0PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSsfmh VRTSspt VRTSvbs)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
            },
            #_END_Sol11Sparc_6.0PR1_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_Sol11Sparc_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSsfmh VRTSspt VRTSvbs)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
            },
            #_END_Sol11Sparc_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}


package Rel::UXRT60SP1PR1::Solx64;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        4.1phase2
        5.0
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0MP3RP4
        5.0MP3RP5
        5.1
        5.1P1
        5.1RP1
        5.1RP1P1
        5.1RP2
        5.1SP1
        5.1SP1RP1
        5.1SP1PR3
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

    $rel->{rel} = {
        '4.1phase2' => {
            #_START_Solx64_4.1phase2_PRODS_PKGS_DEF_
            'prod' => {
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSperl VRTSob VRTSvxvm VRTSvmpro VRTSfspro VRTSalloc VRTSddlpr VRTSvxfs VRTSfssdk VRTSvrpro VRTSvcsvr VRTSjre VRTSjre15 VRTSweb VRTSvlic VRTScpi)],
                    'opkgs' => [qw(VRTSobgui VRTSvmman VRTSvmdoc VRTStep VRTSap VRTSfsman VRTSfsdoc VRTSfsmnd VRTSvrw VRTSvrdoc)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSperl VRTSob VRTSat VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSvcsag VRTSjre VRTSjre15 VRTScutil VRTScscw VRTSweb VRTSvcsw VRTSvxvm VRTSvmpro VRTSfspro VRTSalloc VRTSddlpr VRTSvrpro VRTSvcsvr VRTSvxfs VRTSfssdk VRTScavf VRTSglm VRTSvxmsa VRTSvlic VRTScpi)],
                    'opkgs' => [qw(VRTSobgui VRTSvcsmn VRTSvcsdc VRTScscm VRTScssim VRTSvmman VRTSvmdoc VRTSvrw VRTSvrdoc VRTSap VRTStep VRTSfsman VRTSfsdoc VRTSfsmnd)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSperl VRTSob VRTSvxvm VRTSvmpro VRTSfspro VRTSalloc VRTSddlpr VRTSvxfs VRTSfssdk VRTSdbed VRTSodm VRTSvxmsa VRTSorgui VRTScpi VRTSvlic)],
                    'opkgs' => [qw(VRTSobgui VRTSvmman VRTSvmdoc VRTStep VRTSap VRTSfsman VRTSfsdoc VRTSfsmnd VRTSdbdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSperl VRTSob VRTSobgui VRTSat VRTSvxvm VRTSvmman VRTSvmdoc VRTSvmpro VRTSfspro VRTSalloc VRTSddlpr VRTSvrpro VRTSvcsvr VRTSjre VRTSjre15 VRTSweb VRTSvrw VRTSvrdoc VRTSap VRTStep VRTSvxfs VRTSfsman VRTSfsdoc VRTSfssdk VRTSfsmnd VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSvcsag VRTSvcsmn VRTSvcsdc VRTScutil VRTScscw VRTSvcsw VRTScscm VRTScssim VRTScavf VRTSglm VRTSvxmsa VRTSgms VRTSodm VRTSdbac VRTSvcsor VRTScsocw VRTSdbckp VRTSormap VRTScpi VRTSvlic)],
                    'opkgs' => [qw()],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSperl VRTSob VRTSvxvm VRTSvmpro VRTSfspro VRTSalloc VRTSddlpr VRTSvxfs VRTSfssdk VRTSsybed VRTScpi VRTSvlic)],
                    'opkgs' => [qw(VRTSobgui VRTSvmman VRTSvmdoc VRTStep VRTSap VRTSfsman VRTSfsdoc VRTSfsmnd VRTSdbdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSperl VRTSat VRTSllt VRTSgab VRTSvcs VRTSvcsmg VRTSvcsag VRTSjre VRTSjre15 VRTScutil VRTScscw VRTSweb VRTSvcsw VRTScpi VRTSvlic)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn VRTSvxfen)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSperl VRTSob VRTSvxvm VRTSvmpro VRTSfspro VRTSalloc VRTSddlpr VRTSvrpro VRTSvcsvr VRTScpi VRTSvlic)],
                    'opkgs' => [qw(VRTSap VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
            },
            #_END_Solx64_4.1phase2_PRODS_PKGS_DEF_
            #_START_Solx64_4.1phase2_PATCHES_DEF_
            'patch' => {
                '119753-02' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.10)],
                },
                '120111-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '120112-02' => {
                    'pkgs'   => [qw(VRTSfsdoc VRTSfsman VRTSfsmnd)],
                    'osvers' => [qw(5.10)],
                },
                '120586-04' => {
                    'pkgs'   => [qw(VRTSvmdoc VRTSvmman VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '120853-03' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'osvers' => [qw(5.10)],
                },
                '120854-03' => {
                    'pkgs'   => [qw(VRTSddlpr)],
                    'osvers' => [qw(5.10)],
                },
                '121750-03' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'osvers' => [qw(5.10)],
                },
                '121760-01' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag VRTSvcsmg)],
                    'osvers' => [qw(5.10)],
                },
                '121761-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '121762-01' => {
                    'pkgs'   => [qw(VRTScssim VRTSvcsdc VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '121763-02' => { 'pkgs' => [qw(VRTSvlic)] },
            },
            #_END_Solx64_4.1phase2_PATCHES_DEF_
        },
        '5.0' => {
            #_START_Solx64_5.0_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsdoc VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSsybed VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSsybed VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvmdoc VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
            },
            #_END_Solx64_5.0_PRODS_PKGS_DEF_
        },
        '5.0MP3' => {
            #_START_Solx64_5.0MP3_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSsybed VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSsybed VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
            },
            #_END_Solx64_5.0MP3_PRODS_PKGS_DEF_
            #_START_Solx64_5.0MP3_PATCHES_DEF_
            'patch' => {
                '125861-23' => { 'pkgs' => [qw(VRTSob)] },
                '125862-23' => { 'pkgs' => [qw(VRTSobc33)] },
                '125863-21' => { 'pkgs' => [qw(VRTSobgui)] },
                '125864-21' => { 'pkgs' => [qw(VRTSaa)] },
                '125865-21' => { 'pkgs' => [qw(VRTSccg)] },
                '125866-21' => { 'pkgs' => [qw(VRTSmh)] },
                '127322-01' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '127323-01' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'osvers' => [qw(5.10)],
                },
                '127324-01' => { 'pkgs' => [qw(VRTSvrpro)] },
                '127336-02' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(128060-02)],
                },
                '127337-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125847-01)],
                },
                '127338-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125852-01)],
                },
                '127339-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '127340-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '127341-02' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125851-01)],
                },
                '127342-01' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.10)],
                },
                '127361-01' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'osvers' => [qw(5.10)],
                },
                '127362-01' => {
                    'pkgs'   => [qw(VRTSddlpr)],
                    'osvers' => [qw(5.10)],
                },
                '127363-01' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(127345-01)],
                },
                '128048-03' => {
                    'pkgs'   => [qw(VRTSacclib VRTSvcs VRTSvcsag VRTSvcsmg)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(127354-02 128058-01)],
                },
                '128049-03' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '128050-03' => {
                    'pkgs'   => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                    'osvers' => [qw(5.10)],
                },
                '128051-01' => {
                    'pkgs'   => [qw(VRTSdcli)],
                    'osvers' => [qw(5.10)],
                },
                '128059-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '128071-03' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'osvers' => [qw(5.10)],
                },
                '128072-03' => {
                    'pkgs'   => [qw(VRTSvcssy)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(137337-01 137344-01)],
                },
                '128073-03' => {
                    'pkgs'   => [qw(VRTSvcsdb)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(137346-01)],
                },
                '128079-01' => {
                    'pkgs'   => [qw(VRTSvmman)],
                    'osvers' => [qw(5.10)],
                },
                '128080-01' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'osvers' => [qw(5.10)],
                },
                '128091-01' => {
                    'pkgs'   => [qw(VRTSvcsvr)],
                    'osvers' => [qw(5.10)],
                },
                '137330-01' => {
                    'pkgs'   => [qw(VRTSfssdk)],
                    'osvers' => [qw(5.10)],
                },
                '137339-01' => { 'pkgs' => [qw(VRTSpbx)] },
                '137384-03' => {
                    'pkgs'   => [qw(VRTSjre15)],
                    'osvers' => [qw(5.10)],
                },
                '137386-01' => {
                    'pkgs'   => [qw(VRTSvxmsa)],
                    'osvers' => [qw(5.10)],
                },
                '137388-01' => {
                    'pkgs'   => [qw(VRTSvlic)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.0MP3_PATCHES_DEF_
        },
        '5.0MP3RP1' => {
            #_START_Solx64_5.0MP3RP1_PATCHES_DEF_
            'patch' => {
                '139348-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '139353-02' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '139355-01' => {
                    'pkgs'   => [qw(VRTSvmman)],
                    'osvers' => [qw(5.10)],
                },
                '139360-01' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '139361-01' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139147-01 139150-01 139154-01 139381-01)],
                },
                '139363-01' => {
                    'pkgs'   => [qw(VRTSdbms3)],
                    'osvers' => [qw(5.10)],
                },
                '139371-01' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'osvers' => [qw(5.10)],
                },
                '139372-01' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '139373-01' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'osvers' => [qw(5.10)],
                },
                '139738-01' => {
                    'pkgs'   => [qw(VRTSdcli)],
                    'osvers' => [qw(5.10)],
                },
                '139740-01' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'osvers' => [qw(5.10)],
                },
                '139745-01' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.10)],
                },
                '139746-01' => {
                    'pkgs'   => [qw(VRTSobc33)],
                    'osvers' => [qw(5.10)],
                },
                '139747-01' => {
                    'pkgs'   => [qw(VRTSaa)],
                    'osvers' => [qw(5.10)],
                },
                '139748-01' => {
                    'pkgs'   => [qw(VRTSccg)],
                    'osvers' => [qw(5.10)],
                },
                '139756-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.0MP3RP1_PATCHES_DEF_
        },
        '5.0MP3RP2' => {
            #_START_Solx64_5.0MP3RP2_PATCHES_DEF_
            'patch' => {
                '127336-03' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139353-02 128060-02)],
                },
                '127337-03' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125847-01 139348-02)],
                },
                '127341-03' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125851-01)],
                },
                '127362-03' => {
                    'pkgs'   => [qw(VRTSddlpr)],
                    'osvers' => [qw(5.10)],
                },
                '128091-02' => {
                    'pkgs'   => [qw(VRTSvcsvr)],
                    'osvers' => [qw(5.10)],
                },
                '139360-02' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '139361-02' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139147-01 139150-01 139154-01 139381-01)],
                },
                '139363-02' => {
                    'pkgs'   => [qw(VRTSdbms3)],
                    'osvers' => [qw(5.10)],
                },
                '139371-02' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'osvers' => [qw(5.10)],
                },
                '139372-02' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '139373-02' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'osvers' => [qw(5.10)],
                },
                '139745-02' => { 'pkgs' => [qw(VRTSob)] },
                '139746-02' => { 'pkgs' => [qw(VRTSobc33)] },
                '139756-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '140658-01' => {
                    'pkgs'   => [qw(VRTSdsa)],
                    'osvers' => [qw(5.10)],
                },
                '140662-01' => { 'pkgs' => [qw(VRTSobgui)] },
                '141280-01' => {
                    'pkgs'   => [qw(VRTSmapro)],
                    'osvers' => [qw(5.10)],
                },
                '141281-01' => {
                    'pkgs'   => [qw(VRTSsybed)],
                    'osvers' => [qw(5.10)],
                },
                '141287-02' => {
                    'pkgs'   => [qw(VRTSvcsdb)],
                    'osvers' => [qw(5.10)],
                },
                '141288-02' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'osvers' => [qw(5.10)],
                },
                '141289-02' => {
                    'pkgs'   => [qw(VRTSvcssy)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.0MP3RP2_PATCHES_DEF_
        },
        '5.0MP3RP3' => {
            #_START_Solx64_5.0MP3RP3_PATCHES_DEF_
            'patch' => {
                '127336-04' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139353-02 128060-02)],
                },
                '127337-04' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125847-01 139348-02)],
                },
                '127342-02' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.10)],
                },
                '127361-03' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'osvers' => [qw(5.10)],
                },
                '127363-04' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139740-01 127345-01)],
                },
                '128080-02' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'osvers' => [qw(5.10)],
                },
                '139360-03' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '139361-03' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139147-01 139150-01 139154-01 139381-01 142596-01 142589-01)],
                },
                '139363-03' => {
                    'pkgs'   => [qw(VRTSdbms3)],
                    'osvers' => [qw(5.10)],
                },
                '139371-03' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'osvers' => [qw(5.10)],
                },
                '139372-03' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '139373-03' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'osvers' => [qw(5.10)],
                },
                '139738-02' => {
                    'pkgs'   => [qw(VRTSdcli)],
                    'osvers' => [qw(5.10)],
                },
                '139756-03' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '141287-03' => {
                    'pkgs'   => [qw(VRTSvcsdb)],
                    'osvers' => [qw(5.10)],
                },
                '141288-03' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'osvers' => [qw(5.10)],
                },
                '141289-03' => {
                    'pkgs'   => [qw(VRTSvcssy)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(141291-01)],
                },
                '142608-03' => {
                    'pkgs'   => [qw(VRTScscm)],
                    'osvers' => [qw(5.10)],
                },
                '142622-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.0MP3RP3_PATCHES_DEF_
        },
        '5.0MP3RP4' => {
            #_START_Solx64_5.0MP3RP4_PATCHES_DEF_
            'patch' => {
                '127336-05' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139353-02 128060-02)],
                },
                '127337-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125847-01 139348-02)],
                },
                '127342-03' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'osvers' => [qw(5.10)],
                },
                '127361-04' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'osvers' => [qw(5.10)],
                },
                '127363-05' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139740-01 127345-01)],
                },
                '139360-04' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '139361-04' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139147-01 139150-01 139154-01 139381-01 142596-01 142589-01)],
                },
                '139745-03' => { 'pkgs' => [qw(VRTSob)] },
                '139746-03' => { 'pkgs' => [qw(VRTSobc33)] },
                '139756-04' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '141287-04' => {
                    'pkgs'   => [qw(VRTSvcsdb)],
                    'osvers' => [qw(5.10)],
                },
                '141288-04' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'osvers' => [qw(5.10)],
                },
                '141289-04' => {
                    'pkgs'   => [qw(VRTSvcssy)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(141291-01)],
                },
                '142608-04' => {
                    'pkgs'   => [qw(VRTScscm)],
                    'osvers' => [qw(5.10)],
                },
                '142622-04' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.0MP3RP4_PATCHES_DEF_
        },
        '5.0MP3RP5' => {
            #_START_Solx64_5.0MP3RP5_PATCHES_DEF_
            'patch' => {
                '127336-06' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139353-02 128060-02)],
                },
                '127337-06' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(125847-01 139348-02)],
                },
                '139360-05' => {
                    'pkgs'   => [qw(VRTSgab VRTSllt VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '139361-05' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                    'obsoletes' => [qw(139147-01 139150-01 139154-01 139381-01 142596-01 142589-01)],
                },
                '139371-04' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'osvers' => [qw(5.10)],
                },
                '139372-04' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '139373-04' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'osvers' => [qw(5.10)],
                },
                '139756-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '141287-06' => {
                    'pkgs'   => [qw(VRTSvcsdb)],
                    'osvers' => [qw(5.10)],
                },
                '141288-05' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'osvers' => [qw(5.10)],
                },
                '141289-05' => {
                    'pkgs'   => [qw(VRTSvcssy)],
                    'osvers' => [qw(5.10)],
                },
                '142608-05' => {
                    'pkgs'   => [qw(VRTScscm)],
                    'osvers' => [qw(5.10)],
                },
                '142622-05' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.0MP3RP5_PATCHES_DEF_
        },
        '5.1' => {
            #_START_Solx64_5.1_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_Solx64_5.1_PRODS_PKGS_DEF_
        },
        '5.1P1' => {
            #_START_Solx64_5.1P1_PATCHES_DEF_
            'patch' => {
                '142630-01' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '142635-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143266-01' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143267-01' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143268-01' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '143269-01' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '143272-01' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143275-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1P1_PATCHES_DEF_
        },
        '5.1RP1' => {
            #_START_Solx64_5.1RP1_PATCHES_DEF_
            'patch' => {
                '141752-02' => {
                    'pkgs'   => [qw(VRTSsfmh)],
                    'osvers' => [qw(5.10)],
                },
                '142630-02' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '142632-02' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '142635-02' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143266-02' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143267-02' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143268-02' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '143269-02' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '143272-02' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143275-02' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143277-02' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.10)],
                },
                '143280-02' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.10)],
                },
                '143693-01' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.10)],
                },
                '143698-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '143708-02' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1RP1_PATCHES_DEF_
        },
        '5.1RP1P1' => {
            #_START_Solx64_5.1RP1P1_PATCHES_DEF_
            'patch' => {
                '143266-03' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1RP1P1_PATCHES_DEF_
        },
        '5.1RP2' => {
            #_START_Solx64_5.1RP2_PATCHES_DEF_
            'patch' => {
                '142630-05' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '142632-03' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '142635-03' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143267-03' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143268-07' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '143269-07' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '143272-03' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143277-03' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.10)],
                },
                '143280-03' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.10)],
                },
                '143708-03' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1RP2_PATCHES_DEF_
        },
        '5.1SP1' => {
            #_START_Solx64_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSspt VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_Solx64_5.1SP1_PRODS_PKGS_DEF_
            #_START_Solx64_5.1SP1_PATCHES_DEF_
            'patch' => {
                '142630-06' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '142632-04' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '142635-05' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143272-05' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143275-05' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143291-01' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143292-01' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143294-01' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '143295-01' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '143296-01' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.10)],
                },
                '143297-01' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.10)],
                },
                '143679-01' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'osvers' => [qw(5.10)],
                },
                '143682-01' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '143693-02' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.10)],
                },
                '145452-01' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '145456-01' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1SP1_PATCHES_DEF_
        },
        '5.1SP1RP1' => {
            #_START_Solx64_5.1SP1RP1_PATCHES_DEF_
            'patch' => {
                '142630-09' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '142635-07' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143272-06' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143275-06' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143294-02' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '143295-04' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '143296-02' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.10)],
                },
                '143297-03' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.10)],
                },
                '143682-02' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '145456-02' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '145458-01' => {
                    'pkgs'   => [qw(VRTSsfmh)],
                    'osvers' => [qw(5.10)],
                },
                '145472-01' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1SP1RP1_PATCHES_DEF_
        },
        '5.1SP1PR3' => {
            #_START_Solx64_5.1SP1PR3_PRODS_PKGS_DEF_
            'prod' => {
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSsfmh VRTSvxfs VRTSat VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf VRTSsvs)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSfssdk VRTScps VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
            },
            #_END_Solx64_5.1SP1PR3_PRODS_PKGS_DEF_
            #_START_Solx64_5.1SP1PR3_PATCHES_DEF_
            'patch' => {
                '142635-08' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
            } 
            #_END_Solx64_5.1SP1PR3_PATCHES_DEF_
        },
        '5.1SP1RP2' => {
            #_START_Solx64_5.1SP1RP2_PATCHES_DEF_
            'patch' => {
                '142630-12' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '142632-05' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'osvers' => [qw(5.10)],
                },
                '142635-09' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '143272-07' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'osvers' => [qw(5.10)],
                },
                '143275-07' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '143291-03' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'osvers' => [qw(5.10)],
                },
                '143292-02' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'osvers' => [qw(5.10)],
                },
                '143294-06' => {
                    'pkgs'      => [qw(VRTSvcs)],
                    'osvers'    => [qw(5.10)],
                    'obsoletes' => [qw(146897-01)],
                },
                '143295-12' => {
                    'pkgs'      => [qw(VRTSvcsag)],
                    'osvers'    => [qw(5.10)],
                    'obsoletes' => [qw(146899-01)],
                },
                '143296-03' => {
                    'pkgs'   => [qw(VRTScps)],
                    'osvers' => [qw(5.10)],
                },
                '143297-04' => {
                    'pkgs'   => [qw(VRTSvcsea)],
                    'osvers' => [qw(5.10)],
                },
                '143682-03' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'osvers' => [qw(5.10)],
                },
                '143693-03' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.10)],
                },
                '145452-03' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'osvers' => [qw(5.10)],
                },
                '145456-03' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'osvers' => [qw(5.10)],
                },
                '145472-02' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_5.1SP1RP2_PATCHES_DEF_
        },
        '6.0' => {
            #_START_Solx64_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_Solx64_6.0_PRODS_PKGS_DEF_
        },
        '6.0RP1' => {
            #_START_Solx64_6.0RP1_PRODS_PKGS_DEF_
            'patch' => {
                '147849-01' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'osvers' => [qw(5.10)],
                },
                '147850-01' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'osvers' => [qw(5.10)],
                },
                '147854-02' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'osvers' => [qw(5.10)],
                },
                '147855-01' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'osvers' => [qw(5.10)],
                },
                '147886-01' => {
                    'pkgs'   => [qw(VRTSamf)],
                    'osvers' => [qw(5.10)],
                },
                '147888-01' => {
                    'pkgs'   => [qw(VRTSvbs)],
                    'osvers' => [qw(5.10)],
                },
                '148450-01' => {
                    'pkgs'   => [qw(VRTSsfcpi60)],
                    'osvers' => [qw(5.10)],
                },
                '148454-01' => {
                    'pkgs'   => [qw(VRTSsvs)],
                    'osvers' => [qw(5.10)],
                },
                '148458-01' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'osvers' => [qw(5.10)],
                },
                '148463-01' => {
                    'pkgs'   => [qw(VRTSob)],
                    'osvers' => [qw(5.10)],
                },
            },
            #_END_Solx64_6.0RP1_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_Solx64_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_Solx64_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}


package Rel::UXRT60SP1PR1::Sol11x64;

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
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
    }else {
        $mpvers = $rel->get_new_mpvers($sys->{pkgvers}{$pkg});
    }
    return $rel->pkgvers_to_relvers_mapping($mpvers);
}

sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mprpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
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
    }else {
        $mprpvers = $rel->get_new_mprpvers($sys->{pkgvers}{$pkg});
    }
    return $rel->pkgvers_to_relvers_mapping($mprpvers);
}

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        6.0PR1
        6.0SP1
    )];

    $rel->{rel} = {
        '6.0PR1' => {
            #_START_Sol11x64_6.0PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
            },
            #_END_Sol11x64_6.0PR1_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_Sol11x64_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSsfmh VRTSspt VRTSvbs)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSodm VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
            },
            #_END_Sol11x64_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::HPUX;

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    return $rel->pkgvers_to_relvers_mapping($rel->get_major_vers($sys->{pkgvers}{$pkg}));
}

sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    return $rel->pkgvers_to_relvers_mapping($rel->pkg_inst_mpvers_sys($sys, $pkg));
}

sub set_inst_vrtsprods_sys {
    my ($rel, $sys) = @_;
    my ($checksf, $checkvcs, $checkfs, $checkvm, $checkat);

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
                if ($sys->{padv} eq 'HPUX1131ia64' && $sys->{pkgvers}{VRTSvcsea} && grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                    $sys->{iprod}{sfsybasece}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs';
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
            if ( $rel->get_major_vers($sys->{pkgvers}{VRTSvxvm}) eq $rel->get_major_vers($sys->{pkgvers}{VRTSvxfs}) ){
                $checkvm = $checkfs = 0;
                if ($sys->{pkgvers}{VRTSvcs} && $sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{VRTSvxvm}) {
                    $checkvcs = 0;
                    $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                    $sys->{iprod}{sfha}{imainpkg} = 'VRTSvxvm VRTSvxfs VRTSvcs';
                } else {
                    $sys->{iprod}{sf}{imainpkg} = 'VRTSvxvm VRTSvxfs';
                }
            }else{
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
            }else{
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

    return '';
}

package Rel::UXRT60SP1PR1::HPUX1123;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        4.1
        4.1MP1
        4.1MP2
        4.1MP2RP1
        4.1MP2RP2
        4.1MP2RP3
        4.1MP2RP4
        4.1MP2RP5
        4.1MP2RP6
        4.1MP2RP7
        4.1MP2RP8
        4.1MP2RP9
        5.0
        5.0RP1
        5.0MP1
        5.0MP1RP1
        5.0MP1RP2
        5.0MP1RP3
        5.0MP1RP4
        5.0MP1RP5
        5.0MP1RP6
        5.0MP2
        5.0MP2RP1
        5.0MP2RP2
        5.0MP2RP3
        5.0MP3
    )];

    $rel->{rel} = {
        '4.1' => {
            #_START_HPUX1123_4.1_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfsman VRTSfspro VRTSob VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSdbed VRTSddlpr VRTSfsman VRTSfspro VRTSjre VRTSob VRTSorgui VRTSperl VRTSvail VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSobgui VRTSodm VRTStep VRTSvmdoc VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScavf VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSgab VRTSglm VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxfen VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvrdoc VRTSvrw)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvrdoc VRTSvrw VRTSvxfen)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScsocw VRTSdbed VRTSddlpr VRTSfsman VRTSfspro VRTSjre VRTSob VRTSorgui VRTSperl VRTSvail VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSobgui VRTSodm VRTStep VRTSvmdoc VRTSvrdoc VRTSvrw)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSalloc VRTSat VRTScpi VRTScscw VRTScsocw VRTScutil VRTSdbed VRTSddlpr VRTSfsman VRTSfspro VRTSgab VRTSjre VRTSllt VRTSob VRTSorgui VRTSperl VRTSvail VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSobgui VRTSodm VRTStep VRTSvcsmn VRTSvmdoc VRTSvrdoc VRTSvrw VRTSvxfen)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSalloc VRTSap VRTSat VRTScavf VRTScpi VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbckp VRTSddlpr VRTSfsdoc VRTSfsman VRTSfspro VRTSgab VRTSglm VRTSgms VRTSjre VRTSllt VRTSob VRTSobgui VRTSodm VRTSormap VRTSperl VRTStep VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsw VRTSvlic VRTSvmdoc VRTSvmpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSat VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsw VRTSvlic VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn VRTSvxfen)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSobgui VRTStep VRTSvmdoc VRTSvrdoc VRTSvrw VRTSweb)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrmcsg VRTSvrpro VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSobgui VRTStep VRTSvmdoc VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
            #_END_HPUX1123_4.1_PRODS_PKGS_DEF_
            #_START_HPUX1123_4.1_PATCHES_DEF_
            'patch' => {
                'PHCO_33078' => { 'pkgs' => [qw(VRTSob)] },
                'PHCO_33079' => { 'pkgs' => [qw(VRTSobgui)] },
            },
            #_END_HPUX1123_4.1_PATCHES_DEF_
        },
        '4.1MP1' => {
            #_START_HPUX1123_4.1MP1_PATCHES_DEF_
            'patch' => {
                'PVCO_03643' => { 'pkgs' => [qw(VRTSdbac)] },
                'PVCO_03646' => { 'pkgs' => [qw(VRTScsocw)] },
                'PVCO_03647' => { 'pkgs' => [qw(VRTSvcsor)] },
                'PVKL_03648' => { 'pkgs' => [qw(VRTSdbac)] },
            },
            #_END_HPUX1123_4.1MP1_PATCHES_DEF_
        },
        '4.1MP2' => {
            #_START_HPUX1123_4.1MP2_PATCHES_DEF_
            'patch' => {
                'PHCO_35892' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_33522)],
                },
                'PHCO_36027' => {
                    'pkgs'   => [qw(VRTSob)],
                    'supersedes' => [qw(PHCO_33078 PHCO_33080 PHCO_33082)],
                },
                'PHCO_36028' => {
                    'pkgs'   => [qw(VRTSobgui)],
                    'supersedes' => [qw(PHCO_33079 PHCO_33081)],
                },
                'PHCO_36111' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890)],
                },
                'PHCO_36113' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_33517 PHCO_34273 PHCO_35043 PHCO_35431 PHCO_35888)],
                },
                'PHCO_36517' => { 'pkgs' => [qw(VRTSdbed)] },
                'PHCO_36611' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_33691)],
                },
                'PHCO_36653' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_34038 PHCO_34810 PHCO_35465 PHCO_35518)],
                },
                'PHKL_36112' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891)],
                },
                'PHKL_36114' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889)],
                },
                'PHKL_36526' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'supersedes' => [qw(PHKL_33566)],
                },
                'PHKL_36527' => {
                    'pkgs'   => [qw(VRTSgms)],
                    'supersedes' => [qw(PHKL_33620)],
                },
                'PHKL_36528' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_33586 PHKL_34475 PHKL_35334)],
                },
                'PHNE_36531' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_33611 PHNE_34569 PHNE_35353)],
                },
                'PHNE_36532' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_33612 PHNE_34664)],
                },
                'PHSS_35962' => { 'pkgs' => [qw(VRTSjre)] },
                'PVCO_03740' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'supersedes' => [qw(PVCO_03659 PVCO_03702)],
                },
                'PVCO_03741' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03655 PVCO_03660 PVCO_03687 PVCO_03693)],
                },
                'PVCO_03742' => {
                    'pkgs'   => [qw(VRTSvcsor)],
                    'supersedes' => [qw(PVCO_03647 PVCO_03663)],
                },
                'PVCO_03745' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PVCO_03747' => {
                    'pkgs'   => [qw(VRTScsocw)],
                    'supersedes' => [qw(PVCO_03646)],
                },
                'PVCO_03748' => { 'pkgs' => [qw(VRTScscw)] },
                'PVCO_03749' => { 'pkgs' => [qw(VRTSvcsw)] },
                'PVCO_03750' => { 'pkgs' => [qw(VRTScssim)] },
                'PVCO_03751' => { 'pkgs' => [qw(VRTScscm)] },
                'PVCO_03752' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'supersedes' => [qw(PVCO_03699)],
                },
                'PVCO_03764' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVCO_03643 PVCO_03652 PVKL_03648)],
                },
                'PVCO_03770' => {
                    'pkgs'   => [qw(VRTSvcssy)],
                    'supersedes' => [qw(PVCO_03650 PVCO_03653 PVCO_03763)],
                },
                'PVKL_03746' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PVKL_03657)],
                },
                'PVKL_03765' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVKL_03648 PVKL_03658 PVKL_03661)],
                },
            },
            #_END_HPUX1123_4.1MP2_PATCHES_DEF_
        },
        '4.1MP2RP1' => {
            #_START_HPUX1123_4.1MP2RP1_PATCHES_DEF_
            'patch' => {
                'PHKL_38448' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_33586 PHKL_34475 PHKL_35334 PHKL_36528)],
                },
                'PVKL_03843' => { 'pkgs' => [qw(VRTSdbac)] },
            },
            #_END_HPUX1123_4.1MP2RP1_PATCHES_DEF_
        },
        '4.1MP2RP2' => {
            #_START_HPUX1123_4.1MP2RP2_PATCHES_DEF_
            'patch' => {
                'PHCO_37837' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_34038 PHCO_34810 PHCO_35465 PHCO_35518 PHCO_36653 PHCO_37390)],
                },
                'PHCO_37838' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391)],
                },
                'PHKL_37839' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392)],
                },
                'PHKL_39029' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_33586 PHKL_34475 PHKL_35334 PHKL_36528 PHKL_38448)],
                },
                'PVCO_03910' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'supersedes' => [qw(PVCO_03699 PVCO_03752 PVCO_03855)],
                },
            },
            #_END_HPUX1123_4.1MP2RP2_PATCHES_DEF_
        },
        '4.1MP2RP3' => {
            #_START_HPUX1123_4.1MP2RP3_PATCHES_DEF_
            'patch' => {
                'PHCO_38434' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_33517 PHCO_34273 PHCO_35043 PHCO_35431 PHCO_35888 PHCO_36113 PHCO_37841)],
                },
                'PHKL_38433' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889 PHKL_36114 PHKL_37393 PHKL_37840)],
                },
                'PHKL_40947' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_33586 PHKL_34475 PHKL_35334 PHKL_36528 PHKL_38448 PHKL_39029)],
                },
            },
            #_END_HPUX1123_4.1MP2RP3_PATCHES_DEF_
        },
        '4.1MP2RP4' => {
            #_START_HPUX1123_4.1MP2RP4_PATCHES_DEF_
            'patch' => {
                'PHCO_38463' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_34038 PHCO_34810 PHCO_35465 PHCO_35518 PHCO_36653 PHCO_37390 PHCO_37837)],
                },
                'PHCO_38464' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391 PHCO_37838)],
                },
                'PHCO_39027' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_33517 PHCO_34273 PHCO_35043 PHCO_35431 PHCO_35888 PHCO_36113 PHCO_37841 PHCO_38434)],
                },
                'PHCO_39081' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_33522 PHCO_35892)],
                },
                'PHKL_38428' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392 PHKL_37839)],
                },
                'PHKL_39026' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889 PHKL_36114 PHKL_37393 PHKL_37840 PHKL_38433)],
                },
            },
            #_END_HPUX1123_4.1MP2RP4_PATCHES_DEF_
        },
        '4.1MP2RP5' => {
            #_START_HPUX1123_4.1MP2RP5_PATCHES_DEF_
            'patch' => {
                'PHCO_38757' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391 PHCO_37838 PHCO_38464)],
                },
                'PHKL_38758' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392 PHKL_37839 PHKL_38428)],
                },
                'PHKL_39259' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889 PHKL_36114 PHKL_37393 PHKL_37840 PHKL_38433 PHKL_39026)],
                },
            },
            #_END_HPUX1123_4.1MP2RP5_PATCHES_DEF_
        },
        '4.1MP2RP6' => {
            #_START_HPUX1123_4.1MP2RP6_PATCHES_DEF_
            'patch' => {
                'PHCO_39220' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391 PHCO_37838 PHCO_38464 PHCO_38757)],
                },
                'PHCO_39756' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_33517 PHCO_34273 PHCO_35043 PHCO_35431 PHCO_35888 PHCO_36113 PHCO_37841 PHCO_38434 PHCO_39027)],
                },
                'PHKL_39221' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392 PHKL_37839 PHKL_38428 PHKL_38758)],
                },
                'PHKL_39755' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889 PHKL_36114 PHKL_37393 PHKL_37840 PHKL_38433 PHKL_39026 PHKL_39259)],
                },
            },
            #_END_HPUX1123_4.1MP2RP6_PATCHES_DEF_
        },
        '4.1MP2RP7' => {
            #_START_HPUX1123_4.1MP2RP7_PATCHES_DEF_
            'patch' => {
                'PHCO_39778' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_34038 PHCO_34810 PHCO_35465 PHCO_35518 PHCO_36653 PHCO_37390 PHCO_37837 PHCO_38463)],
                },
                'PHCO_39779' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391 PHCO_37838 PHCO_38464 PHCO_38757 PHCO_39220)],
                },
                'PHCO_40284' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_33517 PHCO_34273 PHCO_35043 PHCO_35431 PHCO_35888 PHCO_36113 PHCO_37841 PHCO_38434 PHCO_39027 PHCO_39756)],
                },
                'PHCO_40285' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_33691 PHCO_36611)],
                },
                'PHKL_39780' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392 PHKL_37839 PHKL_38428 PHKL_38758 PHKL_39221)],
                },
                'PHKL_40283' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889 PHKL_36114 PHKL_37393 PHKL_37840 PHKL_38433 PHKL_39026 PHKL_39259 PHKL_39755)],
                },
            },
            #_END_HPUX1123_4.1MP2RP7_PATCHES_DEF_
        },
        '4.1MP2RP8' => {
            #_START_HPUX1123_4.1MP2RP8_PATCHES_DEF_
            'patch' => {
                'PHCO_40492' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_34038 PHCO_34810 PHCO_35465 PHCO_35518 PHCO_36653 PHCO_37390 PHCO_37837 PHCO_38463 PHCO_39778)],
                },
                'PHCO_40493' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391 PHCO_37838 PHCO_38464 PHCO_38757 PHCO_39220 PHCO_39779)],
                },
                'PHCO_40949' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_33522 PHCO_35892 PHCO_39081)],
                },
                'PHKL_40494' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392 PHKL_37839 PHKL_38428 PHKL_38758 PHKL_39221 PHKL_39780)],
                },
                'PHKL_40948' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_33518 PHKL_34274 PHKL_35042 PHKL_35236 PHKL_35430 PHKL_35889 PHKL_36114 PHKL_37393 PHKL_37840 PHKL_38433 PHKL_39026 PHKL_39259 PHKL_39755 PHKL_40283)],
                },
            },
            #_END_HPUX1123_4.1MP2RP8_PATCHES_DEF_
        },
        '4.1MP2RP9' => {
            #_START_HPUX1123_4.1MP2RP9_PATCHES_DEF_
            'patch' => {
                'PHCO_41065' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_33509 PHCO_34811 PHCO_35476 PHCO_35738 PHCO_35890 PHCO_36111 PHCO_37391 PHCO_37838 PHCO_38464 PHCO_38757 PHCO_39220 PHCO_39779 PHCO_40493)],
                },
                'PHKL_41064' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_33510 PHKL_34812 PHKL_35477 PHKL_35739 PHKL_35891 PHKL_36112 PHKL_37392 PHKL_37839 PHKL_38428 PHKL_38758 PHKL_39221 PHKL_39780 PHKL_40494)],
                },
            },
            #_END_HPUX1123_4.1MP2RP9_PATCHES_DEF_
        },
        '5.0' => {
            #_START_HPUX1123_5.0_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
            },
            #_END_HPUX1123_5.0_PRODS_PKGS_DEF_
        },
        '5.0RP1' => {
            #_START_HPUX1123_5.0RP1_PATCHES_DEF_
            'patch' => {
                'PHCO_40518' => { 'pkgs' => [qw(VRTSweb)] },
                'PVCO_03902' => { 'pkgs' => [qw(VRTSweb)] },
            },
            #_END_HPUX1123_5.0RP1_PATCHES_DEF_
        },
        '5.0MP1' => {
            #_START_HPUX1123_5.0MP1_PATCHES_DEF_
            'patch' => {
                'PHCO_35124' => { 'pkgs' => [qw(VRTSvmpro)] },
                'PHCO_35125' => { 'pkgs' => [qw(VRTSddlpr)] },
                'PHCO_35126' => { 'pkgs' => [qw(VRTSalloc)] },
                'PHCO_35127' => { 'pkgs' => [qw(VRTSdcli)] },
                'PHCO_35179' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129)],
                },
                'PHCO_35180' => { 'pkgs' => [qw(VRTSfspro)] },
                'PHCO_35212' => { 'pkgs' => [qw(VRTSob)] },
                'PHCO_35213' => { 'pkgs' => [qw(VRTSobc33)] },
                'PHCO_35214' => { 'pkgs' => [qw(VRTSobgui)] },
                'PHCO_35215' => { 'pkgs' => [qw(VRTSaa)] },
                'PHCO_35216' => { 'pkgs' => [qw(VRTSccg)] },
                'PHCO_35217' => { 'pkgs' => [qw(VRTSmh)] },
                'PHCO_35301' => { 'pkgs' => [qw(VRTSat)] },
                'PHCO_35332' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_35304)],
                },
                'PHCO_35354' => { 'pkgs' => [qw(VRTSdbed)] },
                'PHCO_35355' => { 'pkgs' => [qw(VRTSdbcom)] },
                'PHCO_35356' => { 'pkgs' => [qw(VRTSorgui)] },
                'PHCO_35357' => { 'pkgs' => [qw(VRTSmapro)] },
                'PHCO_35375' => { 'pkgs' => [qw(VRTSfsman)] },
                'PHCO_35425' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHKL_35178' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130)],
                },
                'PHKL_35284' => { 'pkgs' => [qw(VRTSodm)] },
                'PHKL_35305' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088)],
                },
                'PHKL_35312' => { 'pkgs' => [qw(VRTSglm)] },
                'PHKL_35424' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHNE_35413' => { 'pkgs' => [qw(VRTSllt)] },
                'PHNE_35783' => { 'pkgs' => [qw(VRTSgab)] },
                'PVCO_03671' => { 'pkgs' => [qw(VRTSvrpro)] },
                'PVCO_03672' => { 'pkgs' => [qw(VRTSvrw)] },
                'PVCO_03676' => { 'pkgs' => [qw(VRTSvcs VRTSvcsag)] },
                'PVCO_03678' => { 'pkgs' => [qw(VRTScscm)] },
                'PVCO_03679' => { 'pkgs' => [qw(VRTScsocw VRTSvcsor)] },
                'PVCO_03680' => { 'pkgs' => [qw(VRTScssim)] },
                'PVCO_03686' => { 'pkgs' => [qw(VRTScmccc)] },
                'PVCO_03689' => { 'pkgs' => [qw(VRTScmcs)] },
                'PVCO_03690' => { 'pkgs' => [qw(VRTScscw)] },
                'PVCO_03694' => { 'pkgs' => [qw(VRTScavf)] },
                'PVCO_03696' => { 'pkgs' => [qw(VRTSvsvc)] },
                'PVCO_03697' => { 'pkgs' => [qw(SYMClma)] },
                'PVCO_03698' => { 'pkgs' => [qw(VRTSsmf)] },
                'PVKL_03688' => { 'pkgs' => [qw(VRTSdbac)] },
            },
            #_END_HPUX1123_5.0MP1_PATCHES_DEF_
        },
        '5.0MP1RP1' => {
            #_START_HPUX1123_5.0MP1RP1_PATCHES_DEF_
            'patch' => {
                'PHKL_36594' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178)],
                },
            },
            #_END_HPUX1123_5.0MP1RP1_PATCHES_DEF_
        },
        '5.0MP1RP2' => {
            #_START_HPUX1123_5.0MP1RP2_PATCHES_DEF_
            'patch' => {
                'PHCO_38740' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHCO_35425 PHCO_37380)],
                },
                'PHKL_38743' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHKL_35424)],
                },
                'PHNE_38738' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_35783)],
                },
                'PHNE_38739' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_35413 PHNE_36509)],
                },
                'PVCO_03797' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03676 PVCO_03743 PVCO_03767 PVCO_03768 PVCO_03786)],
                },
                'PVCO_03798' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'supersedes' => [qw(PVCO_03679)],
                },
                'PVCO_03799' => { 'pkgs' => [qw(VRTSvcssy)] },
                'PVKL_03814' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVKL_03769)],
                },
            },
            #_END_HPUX1123_5.0MP1RP2_PATCHES_DEF_
        },
        '5.0MP1RP3' => {
            #_START_HPUX1123_5.0MP1RP3_PATCHES_DEF_
            'patch' => {
                'PHCO_38187' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086)],
                },
                'PHKL_38186' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113)],
                },
                'PHKL_38188' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087)],
                },
            },
            #_END_HPUX1123_5.0MP1RP3_PATCHES_DEF_
        },
        '5.0MP1RP4' => {
            #_START_HPUX1123_5.0MP1RP4_PATCHES_DEF_
            'patch' => {
                'PHCO_38374' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187)],
                },
                'PHCO_39103' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_35304 PHCO_35332 PHCO_37114)],
                },
                'PHCO_39104' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_35375)],
                },
                'PHKL_38375' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188)],
                },
                'PHKL_38763' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113 PHKL_38186)],
                },
            },
            #_END_HPUX1123_5.0MP1RP4_PATCHES_DEF_
        },
        '5.0MP1RP5' => {
            #_START_HPUX1123_5.0MP1RP5_PATCHES_DEF_
            'patch' => {
                'PHCO_38569' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_35124 PHCO_37085)],
                },
                'PHCO_38570' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187 PHCO_38374)],
                },
                'PHKL_38571' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188 PHKL_38375)],
                },
            },
            #_END_HPUX1123_5.0MP1RP5_PATCHES_DEF_
        },
        '5.0MP1RP6' => {
            #_START_HPUX1123_5.0MP1RP6_PATCHES_DEF_
            'patch' => {
                'PHCO_38830' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187 PHCO_38374 PHCO_38570)],
                },
                'PHCO_38831' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_35124 PHCO_37085 PHCO_38569)],
                },
                'PHKL_38829' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188 PHKL_38375 PHKL_38571)],
                },
            },
            #_END_HPUX1123_5.0MP1RP6_PATCHES_DEF_
        },
        '5.0MP2' => {
            #_START_HPUX1123_5.0MP2_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui VRTSvrdoc)],
                },
            },
            #_END_HPUX1123_5.0MP2_PRODS_PKGS_DEF_
            #_START_HPUX1123_5.0MP2_PATCHES_DEF_
            'patch' => {
                'PHCO_36230' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'supersedes' => [qw(PHCO_35356)],
                },
                'PHCO_37077' => {
                    'pkgs'   => [qw(VRTSdcli)],
                    'supersedes' => [qw(PHCO_35127)],
                },
                'PHCO_38381' => {
                    'pkgs'   => [qw(VRTSob)],
                    'supersedes' => [qw(PHCO_35212 PHCO_36590)],
                },
                'PHCO_38383' => {
                    'pkgs'   => [qw(VRTSobgui)],
                    'supersedes' => [qw(PHCO_35214)],
                },
                'PHCO_38384' => {
                    'pkgs'   => [qw(VRTSaa)],
                    'supersedes' => [qw(PHCO_35215 PHCO_36591)],
                },
                'PHCO_38385' => {
                    'pkgs'   => [qw(VRTSccg)],
                    'supersedes' => [qw(PHCO_35216 PHCO_36592)],
                },
                'PHCO_38834' => {
                    'pkgs'   => [qw(VRTSddlpr)],
                    'supersedes' => [qw(PHCO_35125)],
                },
                'PHCO_38836' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_35375 PHCO_39104)],
                },
                'PHCO_38850' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_35304 PHCO_35332 PHCO_37114 PHCO_39103)],
                },
                'PHCO_38859' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_35180 PHCO_36593)],
                },
                'PHCO_38909' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'supersedes' => [qw(PHCO_35354)],
                },
                'PHCO_38910' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'supersedes' => [qw(PHCO_35355 PHCO_36226)],
                },
                'PHCO_38911' => {
                    'pkgs'   => [qw(VRTSmapro)],
                    'supersedes' => [qw(PHCO_35357)],
                },
                'PHCO_38981' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'supersedes' => [qw(PHCO_35126)],
                },
                'PHCO_38997' => {
                    'pkgs'   => [qw(VRTSobc33)],
                    'supersedes' => [qw(PHCO_35213 PHCO_38382)],
                },
                'PHKL_38794' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113 PHKL_38186 PHKL_38763)],
                },
                'PHKL_38795' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_35284)],
                },
                'PHKL_38796' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'supersedes' => [qw(PHKL_35312)],
                },
                'PHKL_38970' => { 'pkgs' => [qw(VRTSgms)] },
                'PHSS_35963' => { 'pkgs' => [qw(VRTSjre15)] },
                'PVCO_03850' => { 'pkgs' => [qw(VRTScavf)] },
                'PVKL_03852' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVKL_03688 PVKL_03769 PVKL_03814)],
                },
            },
            #_END_HPUX1123_5.0MP2_PATCHES_DEF_
        },
        '5.0MP2RP1' => {
            #_START_HPUX1123_5.0MP2RP1_PATCHES_DEF_
            'patch' => {
                'PHCO_39802' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187 PHCO_38374 PHCO_38570 PHCO_38830)],
                },
                'PHCO_40588' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_35304 PHCO_35332 PHCO_37114 PHCO_38850 PHCO_39103)],
                },
                'PHCO_40589' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_35375 PHCO_38836 PHCO_39104)],
                },
                'PHCO_40591' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_35180 PHCO_36593 PHCO_38859)],
                },
                'PHCO_40887' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'supersedes' => [qw(PHCO_35354 PHCO_38909)],
                },
                'PHKL_39803' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188 PHKL_38375 PHKL_38571 PHKL_38829)],
                },
                'PHKL_40586' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'supersedes' => [qw(PHKL_35312 PHKL_38796)],
                },
                'PHKL_40587' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113 PHKL_38186 PHKL_38763 PHKL_38794)],
                },
                'PVCO_03894' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03676 PVCO_03743 PVCO_03767 PVCO_03768 PVCO_03786 PVCO_03797)],
                },
            },
            #_END_HPUX1123_5.0MP2RP1_PATCHES_DEF_
        },
        '5.0MP2RP2' => {
            #_START_HPUX1123_5.0MP2RP2_PATCHES_DEF_
            'patch' => {
                'PHCO_40806' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187 PHCO_38374 PHCO_38570 PHCO_38830 PHCO_39802)],
                },
                'PHKL_40807' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188 PHKL_38375 PHKL_38571 PHKL_38829 PHKL_39803)],
                },
            },
            #_END_HPUX1123_5.0MP2RP2_PATCHES_DEF_
        },
        '5.0MP2RP3' => {
            #_START_HPUX1123_5.0MP2RP3_PATCHES_DEF_
            'patch' => {
                'PHCO_41450' => {
                    'pkgs'   => [ qw(VRTSdbed) ],
                    'supersedes' => [ qw(PHCO_35354 PHCO_38909 PHCO_40887) ],
                },
                'PHCO_41451' => {
                    'pkgs'   => [ qw(VRTSdbcom) ],
                    'supersedes' => [ qw(PHCO_35355 PHCO_36226 PHCO_38910) ],
                },
                'PHCO_41465' => {
                    'pkgs'   => [ qw(VRTSvxfen) ],
                    'supersedes' => [ qw(PHCO_35425 PHCO_37380 PHCO_38740) ],
                },
                'PHCO_41468' => {
                    'pkgs'   => [ qw(VRTSvxfs) ],
                    'supersedes' => [ qw(PHCO_35304 PHCO_35332 PHCO_37114 PHCO_38850 PHCO_39103 PHCO_40588) ],
                },
                'PHCO_41469' => {
                    'pkgs'   => [ qw(VRTSvxvm) ],
                    'supersedes' => [ qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187 PHCO_38374 PHCO_38570 PHCO_38830 PHCO_39802 PHCO_40806) ],
                },
                'PHCO_41477' => {
                    'pkgs'   => [ qw(VRTSdbms3) ],
                },
                'PHKL_41331' => {
                    'pkgs'   => [ qw(VRTSvxfs) ],
                    'supersedes' => [ qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113 PHKL_38186 PHKL_38763 PHKL_38794 PHKL_40587) ],
                },
                'PHKL_41466' => {
                    'pkgs'   => [ qw(VRTSvxfen) ],
                    'supersedes' => [ qw(PHKL_35424 PHKL_38743) ],
                },
                'PHKL_41470' => {
                    'pkgs'   => [ qw(VRTSvxvm) ],
                    'supersedes' => [ qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188 PHKL_38375 PHKL_38571 PHKL_38829 PHKL_39803 PHKL_40807) ],
                },
                'PHNE_41463' => {
                    'pkgs'   => [ qw(VRTSllt) ],
                    'supersedes' => [ qw(PHNE_35413 PHNE_36509 PHNE_38739) ],
                },
                'PHNE_41464' => {
                    'pkgs'   => [ qw(VRTSgab) ],
                    'supersedes' => [ qw(PHNE_35783 PHNE_38738) ],
                },
                'PVCO_03921' => {
                    'pkgs'   => [ qw(VRTSvcs VRTSvcsag) ],
                    'supersedes' => [ qw(PVCO_03676 PVCO_03743 PVCO_03767 PVCO_03768 PVCO_03786 PVCO_03797 PVCO_03894) ],
                },
                'PVCO_03922' => {
                    'pkgs'   => [ qw(VRTScsocw VRTSvcsor) ],
                    'supersedes' => [ qw(PVCO_03679 PVCO_03798) ],
                },
                'PVKL_03920' => {
                    'pkgs'   => [ qw(VRTSdbac) ],
                    'supersedes' => [ qw(PVKL_03688 PVKL_03769 PVKL_03814 PVKL_03852) ],
                },
            },
            #_END_HPUX1123_5.0MP2RP3_PATCHES_DEF_
        },
        '5.0MP3' => {
            #_START_HPUX1123_5.0MP3_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTSvrdoc)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui VRTSvrdoc)],
                },
            },
            #_END_HPUX1123_5.0MP3_PRODS_PKGS_DEF_
            #_START_HPUX1123_5.0MP3_PATCHES_DEF_
            'patch' => {
                'PHCO_36029' => { 'pkgs' => [qw(VRTSmh)] },
                'PHCO_36956' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'supersedes' => [qw(PHCO_35355)],
                },
                'PHCO_36957' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'supersedes' => [qw(PHCO_35354)],
                },
                'PHCO_36958' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'supersedes' => [qw(PHCO_35356)],
                },
                'PHCO_36959' => {
                    'pkgs'   => [qw(VRTSmapro)],
                    'supersedes' => [qw(PHCO_35357)],
                },
                'PHCO_36960' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_35180 PHCO_36593)],
                },
                'PHCO_36961' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'supersedes' => [qw(PHCO_35126)],
                },
                'PHCO_36962' => {
                    'pkgs'   => [qw(VRTSddlpr)],
                    'supersedes' => [qw(PHCO_35125)],
                },
                'PHCO_36963' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_35124 PHCO_37085)],
                },
                'PHCO_36964' => { 'pkgs' => [qw(VRTSdcli)] },
                'PHCO_36965' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086)],
                },
                'PHCO_36971' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_35304 PHCO_35332 PHCO_37114)],
                },
                'PHCO_36972' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_35375)],
                },
                'PHCO_37064' => { 'pkgs' => [qw(VRTSobc33)] },
                'PHCO_37065' => { 'pkgs' => [qw(VRTSob)] },
                'PHCO_37066' => { 'pkgs' => [qw(VRTSobgui)] },
                'PHCO_37067' => { 'pkgs' => [qw(VRTSaa)] },
                'PHCO_37068' => { 'pkgs' => [qw(VRTSccg)] },
                'PHCO_37210' => { 'pkgs' => [qw(VRTSat)] },
                'PHCO_38146' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHCO_35425 PHCO_37380)],
                },
                'PHKL_36966' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087)],
                },
                'PHKL_36967' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'supersedes' => [qw(PHKL_35312)],
                },
                'PHKL_36968' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_35284)],
                },
                'PHKL_36969' => { 'pkgs' => [qw(VRTSgms)] },
                'PHKL_36970' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113)],
                },
                'PHKL_37379' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHKL_35424)],
                },
                'PHNE_37377' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_35413 PHNE_36509)],
                },
                'PHNE_37378' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_35783)],
                },
                'PHSS_37916' => { 'pkgs' => [qw(VRTSpbx)] },
                'PHSS_38019' => { 'pkgs' => [qw(VRTSjre15)] },
                'PVCO_03780' => { 'pkgs' => [qw(VRTScavf)] },
                'PVCO_03782' => { 'pkgs' => [qw(VRTSvrpro)] },
                'PVCO_03783' => { 'pkgs' => [qw(VRTSvlic)] },
                'PVKL_03800' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVKL_03688 PVKL_03769)],
                },
            },
            #_END_HPUX1123_5.0MP3_PATCHES_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::HPUX1131;

sub get_major_vers {
    my ($rel, $vers) = @_;
    my @vfields = split(/\./m, $vers);
    if ($vers =~ /^5\.0\.31/m) {
        return ($vfields[3] == 5) ? '5.0.1' : '5.0';
    } elsif ($vers eq "5.0.1" || $vers =~ /^5\.0\.1[a-zA-Z]/m) {
        return '5.0.1';
    } elsif ($vers =~ /^5\.1/m) {
        return '5.1';
    } else {
        $vfields[0] =~ s/\D.*$//m;
        $vfields[1] =~ s/\D.*$//m;
        return join('.', $vfields[0], $vfields[1]);
    }
    return '';
}

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my $ivers = $sys->{pkgvers}{$pkg};
    my @vfields = split(/\./m, $ivers);
    my $mjvers = $rel->get_major_vers($ivers);
    my $mpvers = $mjvers;
    if ($ivers =~ /^5\.0\.31/m) {
        $mpvers = ($vfields[3] == 5) ? '5.0.1' : '5.0_11.31';
    } elsif ($mjvers >= 5.1) {
        $mpvers = $rel->get_new_mpvers($ivers);
    } else {
        $mpvers = $rel->get_major_vers($ivers);
    }
    return $rel->pkgvers_to_relvers_mapping($mpvers);
}

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        5.0
        5.0_11.31
        5.0RP1
        5.0RP2
        5.0RP3
        5.0RP4
        5.0RP5
        5.0RP6
        5.0RP7
        5.0RP8
        5.0MP1
        5.0MP2
        5.0.1
        5.0.1P1
        5.0.1RP1
        5.0.1RP1P1
        5.0.1RP2
        5.0.1RP3
        5.1SP1
        5.1SP1RP1
        6.0
        6.0RP1 
        6.0SP1
    )];

    $rel->{rel} = {
        '5.0' => {
            #_START_HPUX1131_5.0_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
            },
            #_END_HPUX1131_5.0_PRODS_PKGS_DEF_
        },
        '5.0RP1' => {
            #_START_HPUX1131_5.0RP1_PATCHES_DEF_
            'patch' => {
                'PHCO_38235' => { 'pkgs' => [qw(VRTSvxvm)] },
                'PHCO_40519' => { 'pkgs' => [qw(VRTSweb)] },
                'PHCO_40579' => { 'pkgs' => [qw(VRTSfspro)] },
                'PHCO_40991' => { 'pkgs' => [qw(VRTSdbcom)] },
                'PHKL_38236' => { 'pkgs' => [qw(VRTSvxvm)] },
                'PHKL_38241' => { 'pkgs' => [qw(VRTSodm)] },
                'PHKL_38260' => { 'pkgs' => [qw(VRTSvxfs)] },
                'PHKL_38935' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PVKL_03842' => { 'pkgs' => [qw(VRTSdbac)] },
            },
            #_END_HPUX1131_5.0RP1_PATCHES_DEF_
        },
        '5.0RP2' => {
            #_START_HPUX1131_5.0RP2_PATCHES_DEF_
            'patch' => {
                'PHCO_38412' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_38235)],
                },
                'PHCO_39120' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHKL_38413' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_38236)],
                },
                'PHKL_38574' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260)],
                },
                'PHKL_39119' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHKL_39130' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_38241)],
                },
                'PHNE_39146' => { 'pkgs' => [qw(VRTSllt)] },
                'PHNE_39147' => { 'pkgs' => [qw(VRTSgab)] },
                'PVCO_03865' => { 'pkgs' => [qw(VRTSvcs)] },
                'PVCO_03866' => { 'pkgs' => [qw(VRTSvcsmg)] },
                'PVCO_03867' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03849 PVCO_03853)],
                },
                'PVCO_03868' => { 'pkgs' => [qw(VRTSvcsor)] },
                'PVCO_03869' => { 'pkgs' => [qw(VRTSvcssy)] },
            },
            #_END_HPUX1131_5.0RP2_PATCHES_DEF_
        },
        '5.0RP3' => {
            #_START_HPUX1131_5.0RP3_PATCHES_DEF_
            'patch' => {
                'PHCO_38913' => { 'pkgs' => [qw(VRTSfsman)] },
                'PHCO_39132' => { 'pkgs' => [qw(VRTSvxfs)] },
                'PHCO_39458' => { 'pkgs' => [qw(VRTSvmpro)] },
                'PHCO_39721' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_38235 PHCO_38412 PHCO_39459)],
                },
                'PHKL_39131' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574)],
                },
                'PHKL_39471' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_38241 PHKL_39130)],
                },
                'PHKL_39722' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_38236 PHKL_38413 PHKL_39460)],
                },
                'PVCO_03895' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'supersedes' => [qw(PVCO_03865)],
                },
                'PVCO_03896' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03849 PVCO_03853 PVCO_03867)],
                },
            },
            #_END_HPUX1131_5.0RP3_PATCHES_DEF_
        },
        '5.0RP4' => {
            #_START_HPUX1131_5.0RP4_PATCHES_DEF_
            'patch' => {
                'PHCO_39474' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_39132)],
                },
                'PHKL_39472' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574 PHKL_39131)],
                },
            },
            #_END_HPUX1131_5.0RP4_PATCHES_DEF_
        },
        '5.0RP5' => {
            #_START_HPUX1131_5.0RP5_PATCHES_DEF_
            'patch' => {
                'PHCO_40294' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_38235 PHCO_38412 PHCO_39459 PHCO_39721 PHCO_40049)],
                },
                'PHCO_40305' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_39458)],
                },
                'PHKL_39773' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574 PHKL_39131 PHKL_39472)],
                },
                'PHKL_40295' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_38236 PHKL_38413 PHKL_39460 PHKL_39722)],
                },
            },
            #_END_HPUX1131_5.0RP5_PATCHES_DEF_
        },
        '5.0RP6' => {
            #_START_HPUX1131_5.0RP6_PATCHES_DEF_
            'patch' => {
                'PHCO_40061' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_39132 PHCO_39474)],
                },
                'PHCO_40290' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_38913)],
                },
                'PHCO_40574' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_38235 PHCO_38412 PHCO_39459 PHCO_39721 PHCO_40049 PHCO_40294)],
                },
                'PHKL_40059' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574 PHKL_39131 PHKL_39472 PHKL_39773)],
                },
                'PHKL_40575' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_38236 PHKL_38413 PHKL_39460 PHKL_39722 PHKL_40295)],
                },
            },
            #_END_HPUX1131_5.0RP6_PATCHES_DEF_
        },
        '5.0RP7' => {
            #_START_HPUX1131_5.0RP7_PATCHES_DEF_
            'patch' => {
                'PHCO_40639' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_38235 PHCO_38412 PHCO_39459 PHCO_39721 PHCO_40049 PHCO_40294 PHCO_40574)],
                },
                'PHKL_40650' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574 PHKL_39131 PHKL_39472 PHKL_39773 PHKL_40059)],
                },
            },
            #_END_HPUX1131_5.0RP7_PATCHES_DEF_
        },
        '5.0RP8' => {
            #_START_HPUX1131_5.0RP8_PATCHES_DEF_
            'patch' => {
                'PHCO_40890' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_39132 PHCO_39474 PHCO_40061)],
                },
                'PHKL_40683' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574 PHKL_39131 PHKL_39472 PHKL_39773 PHKL_40059 PHKL_40650)],
                },
            },
            #_END_HPUX1131_5.0RP8_PATCHES_DEF_
        },
        '5.0MP1' => {
            #_START_HPUX1131_5.0MP1_PATCHES_DEF_
            'patch' => {
                'PHCO_40961' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_38235 PHCO_38412 PHCO_39459 PHCO_39721 PHCO_40049 PHCO_40294 PHCO_40574 PHCO_40639)],
                },
                'PHCO_41046' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_39458 PHCO_40305)],
                },
                'PHCO_41062' => { 'pkgs' => [qw(VRTSdbed)] },
                'PHCO_41068' => { 'pkgs' => [qw(VRTSdbms3)] },
                'PHCO_41072' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_39132 PHCO_39474 PHCO_40061 PHCO_40890)],
                },
                'PHCO_41073' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'supersedes' => [qw(PHCO_40991 PHCO_41063)],
                },
                'PHCO_41078' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHCO_39120)],
                },
                'PHCO_41079' => {
                    'pkgs'   => [qw(VRTSob)],
                    'supersedes' => [qw(PHCO_39905)],
                },
                'PHCO_41080' => {
                    'pkgs'   => [qw(VRTSobc33)],
                    'supersedes' => [qw(PHCO_38999 PHCO_39906)],
                },
                'PHCO_41081' => {
                    'pkgs'   => [qw(VRTSobgui)],
                    'supersedes' => [qw(PHCO_37694 PHCO_39835)],
                },
                'PHCO_41082' => {
                    'pkgs'   => [qw(VRTSobgui)],
                    'supersedes' => [qw(PHCO_37694 PHCO_39835)],
                },
                'PHCO_41129' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_40579)],
                },
                'PHKL_40962' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_38236 PHKL_38413 PHKL_39460 PHKL_39722 PHKL_40295 PHKL_40575)],
                },
                'PHKL_41071' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_38260 PHKL_38574 PHKL_39131 PHKL_39472 PHKL_39773 PHKL_40059 PHKL_40650 PHKL_40683)],
                },
                'PHKL_41077' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHKL_39119)],
                },
                'PHNE_41075' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_39146)],
                },
                'PHNE_41076' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_39147)],
                },
                'PVCO_03911' => {
                    'pkgs'   => [qw(VRTSvcs)],
                    'supersedes' => [qw(PVCO_03865 PVCO_03895)],
                },
                'PVCO_03912' => {
                    'pkgs'   => [qw(VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03849 PVCO_03853 PVCO_03867 PVCO_03896)],
                },
                'PVCO_03913' => {
                    'pkgs'   => [qw(VRTSvcsor)],
                    'supersedes' => [qw(PVCO_03868)],
                },
                'PVCO_03915' => { 'pkgs' => [qw(VRTScavf)] },
                'PVKL_03914' => { 'pkgs' => [qw(VRTSdbac)] },
            },
            #_END_HPUX1131_5.0MP1_PATCHES_DEF_
        },
        '5.0.1' => {
            #_START_HPUX1131_5.0.1_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSob VRTSobc33 VRTSodm VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSob VRTSobc33 VRTSodm VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsmn)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
            #_END_HPUX1131_5.0.1_PRODS_PKGS_DEF_
        },
        '5.0.1P1' => {
            #_START_HPUX1131_5.0.1P1_PATCHES_DEF_
            'patch' => {
                'PHKL_40689' => { 'pkgs' => [qw(VRTSvxfs)] },
            },
            #_END_HPUX1131_5.0.1P1_PATCHES_DEF_
        },
        '5.0.1RP1' => {
            #_START_HPUX1131_5.0.1RP1_PATCHES_DEF_
            'patch' => {
                'PHCO_39783' => { 'pkgs' => [qw(VRTSsfmh)] },
                'PHCO_40520' => { 'pkgs' => [qw(VRTSweb)] },
                'PHCO_40656' => { 'pkgs' => [qw(VRTSvxvm)] },
                'PHCO_40671' => { 'pkgs' => [qw(VRTSvxfs)] },
                'PHCO_40672' => { 'pkgs' => [qw(VRTSdbms3)] },
                'PHCO_40673' => { 'pkgs' => [qw(VRTSvmpro)] },
                'PHCO_40674' => { 'pkgs' => [qw(VRTSddlpr)] },
                'PHCO_40676' => { 'pkgs' => [qw(VRTSdbcom)] },
                'PHCO_40690' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHCO_40770' => { 'pkgs' => [qw(VRTSfsman)] },
                'PHCO_40771' => { 'pkgs' => [qw(VRTSfspro)] },
                'PHCO_40782' => { 'pkgs' => [qw(VRTSperl)] },
                'PHKL_40443' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHKL_40657' => { 'pkgs' => [qw(VRTSvxvm)] },
                'PHKL_40670' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_40689)],
                },
                'PHKL_40772' => { 'pkgs' => [qw(VRTSglm)] },
                'PHNE_40668' => { 'pkgs' => [qw(VRTSllt)] },
                'PHNE_40669' => { 'pkgs' => [qw(VRTSgab)] },
                'PVCO_03905' => { 'pkgs' => [qw(VRTSvcs)] },
                'PVCO_03906' => { 'pkgs' => [qw(VRTSvcsag)] },
                'PVCO_03907' => { 'pkgs' => [qw(VRTSvcsor)] },
                'PVCO_03909' => { 'pkgs' => [qw(VRTScavf)] },
                'PVKL_03904' => { 'pkgs' => [qw(VRTSdbac)] },
            },
            #_END_HPUX1131_5.0.1RP1_PATCHES_DEF_
        },
        '5.0.1RP1P1' => {
            #_START_HPUX1131_5.0.1RP1P1_PATCHES_DEF_
            'patch' => {
                'PHCO_40936' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_40656)],
                },
            },
            #_END_HPUX1131_5.0.1RP1P1_PATCHES_DEF_
        },
        '5.0.1RP2' => {
            #_START_HPUX1131_5.0.1RP2_PATCHES_DEF_
            'patch' => {
                'PHCO_41221' => { 'pkgs' => [qw(VRTSdbed)] },
                'PHCO_41321' => {
                    'pkgs' => [qw(VRTSdbcom)],
                    'supersedes' => [qw(PHCO_40676)],
                },
                'PHCO_41192' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_40656 PHCO_40936)],
                },
                'PHCO_41194' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_40671)],
                },
                'PHKL_41074' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_40670 PHKL_40689)],
                },
                'PHKL_41193' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_40657)],
                },
                'PHNE_41196' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_40668)],
                },
                'PHNE_41197' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_40669)],
                },
                'PVCO_03916' => {
                    'pkgs'   => [qw(VRTScavf)],
                    'supersedes' => [qw(PVCO_03909)],
                },
            },
            #_END_HPUX1131_5.0.1RP2_PATCHES_DEF_
        },
        '5.0.1RP3' => {
            #_START_HPUX1131_5.0.1RP3_PATCHES_DEF_
            'patch' => {
                'PHCO_41808' => {
                    'pkgs' => [qw(VRTSdbcom)],
                    'supersedes' => [qw(PHCO_40676 PHCO_41321)],
                },
                'PHCO_41879' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_40770)],
                },
                'PHCO_41792' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_40656 PHCO_40936 PHCO_41192)],
                },
                'PHCO_41727' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_40671 PHCO_41194)],
                },
                'PHKL_41917' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_40670 PHKL_40689 PHKL_41074 PHKL_41594 PHKL_41728 PHKL_41864)],
                },
                'PHKL_41793' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_40657 PHKL_41193)],
                },
                'PHNE_41790' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_40668 PHNE_41196)],
                },
                'PHNE_41791' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_40669 PHNE_41197)],
                },
                'PVCO_03923' => { 'pkgs' => [qw(VRTSvcs)] },
                'PVCO_03924' => { 'pkgs' => [qw(VRTSvcssy)] },
                'PVCO_03925' => { 'pkgs' => [qw(VRTSvcsag)] },
                'PVKL_03927' => {
                    'pkgs' => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVKL_03904)],
                },
            },
            #_END_HPUX1131_5.0.1RP3_PATCHES_DEF_
        },
        '5.0MP2' => {
            #_START_HPUX1131_5.0MP2_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmpro VRTSvrpro VRTSvrw VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui VRTSvrdoc)],
                },
            },
            #_END_HPUX1131_5.0MP2_PRODS_PKGS_DEF_
            #_START_HPUX1131_5.0MP2_PATCHES_DEF_
            'patch' => {
                'PHCO_35217' => { 'pkgs' => [qw(VRTSmh)] },
                'PHCO_35301' => { 'pkgs' => [qw(VRTSat)] },
                'PHCO_36230' => {
                    'pkgs'   => [qw(VRTSorgui)],
                    'supersedes' => [qw(PHCO_35356)],
                },
                'PHCO_37077' => {
                    'pkgs'   => [qw(VRTSdcli)],
                    'supersedes' => [qw(PHCO_35127)],
                },
                'PHCO_38381' => {
                    'pkgs'   => [qw(VRTSob)],
                    'supersedes' => [qw(PHCO_35212 PHCO_36590)],
                },
                'PHCO_38383' => {
                    'pkgs'   => [qw(VRTSobgui)],
                    'supersedes' => [qw(PHCO_35214)],
                },
                'PHCO_38384' => {
                    'pkgs'   => [qw(VRTSaa)],
                    'supersedes' => [qw(PHCO_35215 PHCO_36591)],
                },
                'PHCO_38385' => {
                    'pkgs'   => [qw(VRTSccg)],
                    'supersedes' => [qw(PHCO_35216 PHCO_36592)],
                },
                'PHCO_38740' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHCO_35425 PHCO_37380)],
                },
                'PHCO_38830' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHCO_35129 PHCO_35179 PHCO_37086 PHCO_38187 PHCO_38374 PHCO_38570)],
                },
                'PHCO_38831' => {
                    'pkgs'   => [qw(VRTSvmpro)],
                    'supersedes' => [qw(PHCO_35124 PHCO_37085 PHCO_38569)],
                },
                'PHCO_38834' => {
                    'pkgs'   => [qw(VRTSddlpr)],
                    'supersedes' => [qw(PHCO_35125)],
                },
                'PHCO_38836' => {
                    'pkgs'   => [qw(VRTSfsman)],
                    'supersedes' => [qw(PHCO_35375 PHCO_39104)],
                },
                'PHCO_38850' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHCO_35304 PHCO_35332 PHCO_37114 PHCO_39103)],
                },
                'PHCO_38859' => {
                    'pkgs'   => [qw(VRTSfspro)],
                    'supersedes' => [qw(PHCO_35180 PHCO_36593)],
                },
                'PHCO_38909' => {
                    'pkgs'   => [qw(VRTSdbed)],
                    'supersedes' => [qw(PHCO_35354)],
                },
                'PHCO_38910' => {
                    'pkgs'   => [qw(VRTSdbcom)],
                    'supersedes' => [qw(PHCO_35355 PHCO_36226)],
                },
                'PHCO_38911' => {
                    'pkgs'   => [qw(VRTSmapro)],
                    'supersedes' => [qw(PHCO_35357)],
                },
                'PHCO_38981' => {
                    'pkgs'   => [qw(VRTSalloc)],
                    'supersedes' => [qw(PHCO_35126)],
                },
                'PHCO_38997' => {
                    'pkgs'   => [qw(VRTSobc33)],
                    'supersedes' => [qw(PHCO_35213 PHCO_38382)],
                },
                'PHKL_38743' => {
                    'pkgs'   => [qw(VRTSvxfen)],
                    'supersedes' => [qw(PHKL_35424)],
                },
                'PHKL_38794' => {
                    'pkgs'   => [qw(VRTSvxfs)],
                    'supersedes' => [qw(PHKL_35088 PHKL_35305 PHKL_36672 PHKL_37113 PHKL_38186 PHKL_38763)],
                },
                'PHKL_38795' => {
                    'pkgs'   => [qw(VRTSodm)],
                    'supersedes' => [qw(PHKL_35284)],
                },
                'PHKL_38796' => {
                    'pkgs'   => [qw(VRTSglm)],
                    'supersedes' => [qw(PHKL_35312)],
                },
                'PHKL_38829' => {
                    'pkgs'   => [qw(VRTSvxvm)],
                    'supersedes' => [qw(PHKL_35130 PHKL_35178 PHKL_36594 PHKL_37087 PHKL_38188 PHKL_38375 PHKL_38571)],
                },
                'PHKL_38970' => { 'pkgs' => [qw(VRTSgms)] },
                'PHNE_38738' => {
                    'pkgs'   => [qw(VRTSgab)],
                    'supersedes' => [qw(PHNE_35783)],
                },
                'PHNE_38739' => {
                    'pkgs'   => [qw(VRTSllt)],
                    'supersedes' => [qw(PHNE_35413 PHNE_36509)],
                },
                'PHSS_35962' => { 'pkgs' => [qw(VRTSjre)] },
                'PHSS_35963' => { 'pkgs' => [qw(VRTSjre15)] },
                'PVCO_03671' => { 'pkgs' => [qw(VRTSvrpro)] },
                'PVCO_03672' => { 'pkgs' => [qw(VRTSvrw)] },
                'PVCO_03678' => { 'pkgs' => [qw(VRTScscm)] },
                'PVCO_03680' => { 'pkgs' => [qw(VRTScssim)] },
                'PVCO_03686' => { 'pkgs' => [qw(VRTScmccc)] },
                'PVCO_03689' => { 'pkgs' => [qw(VRTScmcs)] },
                'PVCO_03690' => { 'pkgs' => [qw(VRTScscw)] },
                'PVCO_03697' => { 'pkgs' => [qw(SYMClma)] },
                'PVCO_03698' => { 'pkgs' => [qw(VRTSsmf)] },
                'PVCO_03797' => {
                    'pkgs'   => [qw(VRTSvcs VRTSvcsag)],
                    'supersedes' => [qw(PVCO_03676 PVCO_03743 PVCO_03767 PVCO_03768 PVCO_03786)],
                },
                'PVCO_03798' => {
                    'pkgs'   => [qw(VRTScsocw VRTSvcsor)],
                    'supersedes' => [qw(PVCO_03679)],
                },
                'PVCO_03799' => { 'pkgs' => [qw(VRTSvcssy)] },
                'PVCO_03850' => { 'pkgs' => [qw(VRTScavf)] },
                'PVKL_03852' => {
                    'pkgs'   => [qw(VRTSdbac)],
                    'supersedes' => [qw(PVKL_03688 PVKL_03769 PVKL_03814)],
                },
            },
            #_END_HPUX1131_5.0MP2_PATCHES_DEF_
        },
        '5.1SP1' => {
            #_START_HPUX1131_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_HPUX1131_5.1SP1_PRODS_PKGS_DEF_
        },
        '5.1SP1RP1' => {
             #_START_HPUX1131_5.1SP1RP1_PATCHES_DEF_
            'patch' => {
                'PHCO_42093' => { 'pkgs' => [qw(VRTSdbed)] },
                'PHCO_42182' => { 'pkgs' => [qw(VRTSob)] },
                'PHCO_42213' => { 'pkgs' => [qw(VRTSperl)] },
                'PHCO_42229' => { 'pkgs' => [qw(VRTSvxfs)] },
                'PHCO_42245' => { 'pkgs' => [qw(VRTSvxvm)] },
                'PHCO_42254' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHCO_42318' => { 'pkgs' => [qw(VRTSsfmh)] },
                'PHKL_42228' => { 'pkgs' => [qw(VRTSvxfs)] },
                'PHKL_42246' => { 'pkgs' => [qw(VRTSvxvm)] },
                'PHKL_42252' => { 'pkgs' => [qw(VRTSvxfen)] },
                'PHKL_42342' => { 'pkgs' => [qw(VRTSglm)] },
                'PVCO_03929' => { 'pkgs' => [qw(VRTSamf)] },
                'PVCO_03930' => { 'pkgs' => [qw(VRTScps)] },
                'PVCO_03931' => { 'pkgs' => [qw(VRTSvcs)] },
                'PVCO_03932' => { 'pkgs' => [qw(VRTScavf)] },
                'PVCO_03933' => { 'pkgs' => [qw(VRTSvcsag)] },
                'PVCO_03934' => { 'pkgs' => [qw(VRTSvcsea)] },
            },
            #_END_HPUX1131_5.1SP1RP1_PATCHES_DEF_
        },
        '6.0' => {
            #_START_HPUX1131_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_HPUX1131_6.0_PRODS_PKGS_DEF_
        },
        '6.0RP1' => {
            #_START_HPUX1131_6.0RP1_PATCHES_DEF_
            'patch' => {
                'PVCO_03937' => {
                    'pkgs'   => [ qw(VRTSvxvm) ],
                    'supersedes' => [ qw(PVCO_03935) ],
                },
                'PVCO_03944' => {
                    'pkgs'   => [ qw(VRTSvcs) ],
                },
                'PVCO_03948' => {
                    'pkgs'   => [ qw(VRTSvbs) ],
                },
                'PVCO_03950' => {
                    'pkgs'   => [ qw(VRTSfsadv) ],
                },
                'PVCO_03952' => {
                    'pkgs'   => [ qw(VRTSvxfs) ],
                },
                'PVCO_03953' => {
                    'pkgs'   => [ qw(VRTSsfcpi60) ],
                },
                'PVCO_03954' => {
                    'pkgs'   => [ qw(VRTScavf) ],
                },
                'PVCO_03955' => {
                    'pkgs'   => [ qw(VRTSob) ],
                },
                'PVKL_03938' => {
                    'pkgs'   => [ qw(VRTSvxvm) ],
                    'supersedes' => [ qw(PVKL_03936) ],
                },
                'PVKL_03942' => {
                    'pkgs'   => [ qw(VRTSamf) ],
                },
                'PVKL_03951' => {
                    'pkgs'   => [ qw(VRTSvxfs) ],
                },
            },
            #_END_HPUX1131_6.0RP1_PATCHES_DEF_
        },
        '6.0SP1' => {
            #_START_HPUX1131_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_HPUX1131_6.0SP1_PRODS_PKGS_DEF_
        },
 
    };
    return;
}

package Rel::UXRT60SP1PR1::AIX;

sub pkgvers_to_relvers_mapping {
    my ($rel, $pkgvers) = @_;
    if ( $pkgvers eq '5.1SP1PR1RP2' ) {
        $pkgvers = '5.1SP1RP2';
    }
    return $pkgvers;
}

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mpvers, @vfields);
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

sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my (@vfields, $majorvers, $mpvers, $mprpvers);
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

sub set_inst_vrtsprods_sys {
    my ($rel, $sys) = @_;
    my ($checksf, $checkvcs, $checkfs, $checkvm, $checkat);

    $checksf = $checkvcs = 1;
    $checkat = 1;

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
                if (($sys->{padv} eq 'AIX61' || $sys->{padv} eq 'AIX71') && $sys->{pkgvers}{VRTSvcsea} && grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                    $sys->{iprod}{sfsybasece}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxfs VRTSvcs VRTSvcs.rte';
                }else {
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
            if (($sys->{pkgvers}{VRTSvcs} && $sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{VRTSvxvm}) || ($sys->{pkgvers}{'VRTSvcs.rte'} && $sys->{pkgvers}{'VRTSvcs.rte'} eq $sys->{pkgvers}{VRTSvxvm})) {
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
            }else{
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

    return '';
}

sub init_releasematrix {
    my ($rel) = @_;

    $rel->{releases} = [qw(
        4.0
        4.0MP1
        4.0MP2
        4.0MP3
        4.0MP3RP5
        4.0MP4
        4.0MP4RP2
        4.0MP4RP3
        5.0
        5.0RP1
        5.0MP1
        5.0MP1RP2
        5.0MP1RP5
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0MP3RP4
        5.0MP3RP5
        5.1
        5.1P1
        5.1RP1
        5.1RP2
        5.1RP1P1
        5.1SP1
        5.1SP1PR1
        5.1SP1RP1
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

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

    $rel->{rel} = {
        '4.0' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfppm VRTSfspro VRTSob VRTSperl VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsman VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfppm VRTSfspro VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsman VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTScavf VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfppm VRTSfspro VRTSgab VRTSglm VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsw VRTSveki VRTSvlic VRTSvmpro VRTSvxfen VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScfsdc VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSobgui VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2gui VRTSdb2ed VRTSddlpr VRTSfppm VRTSfspro VRTSob VRTSperl VRTSvail VRTSveki VRTSvlic VRTSvmpro VRTSvxfs VRTSvxmsa VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSd2doc VRTSfsdoc VRTSfsman VRTSobgui VRTStep VRTSvmdoc VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTSalloc VRTScpi VRTScscw VRTScutil VRTSd2gui VRTSdb2ed VRTSddlpr VRTSddlpr VRTSfppm VRTSfppm VRTSfspro VRTSfspro VRTSgab VRTSjre VRTSllt VRTSob VRTSob VRTSperl VRTSperl VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsw VRTSveki VRTSveki VRTSvlic VRTSvmpro VRTSvmpro VRTSvxfs VRTSvxfs VRTSvxmsa VRTSvxvm VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSap VRTScscm VRTScssim VRTSd2doc VRTSfsdoc VRTSfsdoc VRTSfsman VRTSfsman VRTSobgui VRTSobgui VRTStep VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmdoc VRTSvmman VRTSvmman VRTSvxfen)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfppm VRTSfspro VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsw VRTSveki VRTSvlic VRTSvmpro VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsman VRTSobgui VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvxfen)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSdbed VRTSddlpr VRTSfppm VRTSfspro VRTSob VRTSodm VRTSorgui VRTSperl VRTSvail VRTSveki VRTSvlic VRTSvmpro VRTSvxfs VRTSvxmsa VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsman VRTSobgui VRTSordoc VRTStep VRTSvmdoc VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSalloc VRTSalloc VRTScpi VRTScscw VRTScutil VRTSdbed VRTSddlpr VRTSddlpr VRTSfppm VRTSfppm VRTSfspro VRTSfspro VRTSgab VRTSjre VRTSllt VRTSob VRTSob VRTSodm VRTSorgui VRTSperl VRTSperl VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsw VRTSveki VRTSveki VRTSvlic VRTSvmpro VRTSvmpro VRTSvxfs VRTSvxfs VRTSvxmsa VRTSvxvm VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsdoc VRTSfsman VRTSfsman VRTSobgui VRTSobgui VRTSordoc VRTStep VRTStep VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmdoc VRTSvmman VRTSvmman VRTSvxfen)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSalloc VRTSap VRTScavf VRTScpi VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbckp VRTSddlpr VRTSfppm VRTSfsdoc VRTSfsman VRTSfspro VRTSgab VRTSglm VRTSgms VRTSjre VRTSllt VRTSob VRTSobgui VRTSodm VRTSperl VRTStep VRTSvail VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvcsw VRTSveki VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsw VRTSveki VRTSvlic VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn VRTSvxfen)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSveki VRTSvlic VRTSvmpro VRTSvxvm)],
                    'opkgs' => [qw(VRTSobgui VRTSvmdoc VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTScpi VRTSob VRTSperl VRTSvcsvr VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvm)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
        },
        '5.0' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSat VRTSccg VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsmg VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsdoc VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsdc VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSveki VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvmdoc VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
            },
        },
        '5.0MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSat VRTSccg VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSd2gui VRTSdb2ed VRTSdbcom VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsmg VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmapro VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgapms VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTSccg VRTScscw VRTScutil VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSorgui VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSvcsmn VRTSvmman)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSat VRTScavf VRTSccg VRTScmccc VRTScmcs VRTScscm VRTScscw VRTScsocw VRTScssim VRTScutil VRTSdbac VRTSdbcom VRTSdbed VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfsmnd VRTSfspro VRTSfssdk VRTSgab VRTSgapms VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodm VRTSpbx VRTSperl VRTSspt VRTSvail VRTSvcs VRTSvcsag VRTSvcsmg VRTSvcsmn VRTSvcsor VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfs VRTSvxmsa VRTSvxvm VRTSweb)],
                    'opkgs' => [qw()],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSat VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsmg VRTSveki VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSat VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSveki VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvm VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
        },
        '5.1SP1' => {
            #_START_AIX_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_AIX_5.1SP1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR1' => {
            #_START_AIX_5.1SP1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSat VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSat VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSat VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_AIX_5.1SP1PR1_PRODS_PKGS_DEF_
        },
        '6.0' => {
            #_START_AIX_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSveki VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_AIX_6.0_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_AIX_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSveki VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSveki VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSveki VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSob VRTSsfmh VRTSspt VRTSvbs)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSveki VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSveki VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_AIX_6.0_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::Linux;

sub pkgvers_to_relvers_mapping {
    my ($rel, $pkgvers) = @_;
    if ( $pkgvers eq '5.1SP1PR3RP2' ) {
        $pkgvers = '5.1SP1RP2';
    }
    return $pkgvers;
}

sub get_at_all_pkgs{
    my ($rel, $mpvers) = @_;
    return EDRu::arruniq(sort qw/VRTSatClient VRTSatServer/);
}
sub get_at_required_pkgs{
    my ($rel, $mpvers) = @_;
    return EDRu::arruniq(sort qw/VRTSatClient/);
}
sub get_at_optional_pkgs{
    my ($rel, $mpvers) = @_;
    return EDRu::arruniq(sort qw/VRTSatServer/);
}

sub pkg_inst_mpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
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

# check installed package's mp and rp/pr version
sub pkg_inst_mprpvers_sys {
    my ($rel, $sys, $pkg) = @_;
    my ($majorvers, $mprpvers, @vfields, $mp, $rp, $ru, $sp, $pr,$p);
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

# For all Linux distros
sub set_inst_vrtsprods_sys {
    my ($rel, $sys) = @_;
    my ($prod,$checksf,$checkvcs,$checkfs,$checkvm,$checkat);

    $checksf = $checkvcs = 1;
    $checkat = 1;

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
                    && $sys->{pkgvers}{VRTSvcsea} && grep {/Sybase ASE CE/} $rel->get_licensed_prods_sys($sys)) {
                $sys->{iprod}{sfsybasece}{imainpkg} = 'VRTScavf VRTSvxvm VRTSvxvm-common VRTSvxvm-platform VRTSvxfs VRTSvxfs-common VRTSvxfs-platform VRTSvcs';
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
            if ($sys->{pkgvers}{VRTSvcs} && $sys->{pkgvers}{VRTSvcs} eq $sys->{pkgvers}{VRTSvxvm}) {
                $checkvcs = 0;
                $checkat = 0 if ($rel->get_major_vers($sys->{pkgvers}{VRTSvcs}) < 6.0);
                $sys->{iprod}{sfha}{imainpkg} = 'VRTSvxvm VRTSvxfs VRTSvcs';
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
                }else{
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
    return '';
}

sub init_releasematrix {
    my ($rel) = @_;

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

    return '';
}

package Rel::UXRT60SP1PR1::RHEL4x8664;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        4.1
        4.1MP2
        4.1MP3
        4.1MP4
        4.1MP4RP2
        4.1MP4RP3
        4.1MP4RP4
        5.0
        5.0MP1
        5.0MP2
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0MP4
    )];

    $rel->{rel} = {
        '4.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfsman VRTSfspro VRTSfssdk VRTSob VRTSperl VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTScavf VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsmg VRTSvlic VRTSvmpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsw VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsApache VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
        },
        '5.0' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvmdoc VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSvmdoc VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSicsco VRTSpbx VRTSatClient VRTSatServer VRTSobc33 VRTSob VRTSccg VRTSmh VRTSaa VRTSspt VRTSvxfscommon VRTSvxfsplatform VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSacclib VRTSvcsag VRTSvcsdr VRTSjre15 VRTScscw VRTSweb VRTScutil VRTSvxvmcommon VRTSvxvmplatform VRTSdsa VRTSfspro VRTSvmpro VRTSdcli VRTSalloc VRTSvdid VRTSddlpr VRTSvrpro VRTSvcsvr VRTSvrw VRTSfssdk VRTSglm VRTScavf VRTSvcssy)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
            },
        },
        '5.0MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::RHEL5x8664;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        4.1MP4
        4.1MP4RP2
        4.1MP4RP3
        4.1MP4RP4
        5.0
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0MP4
        5.1
        5.1P1
        5.1RP1
        5.1RP1P1
        5.1PR1
        5.1RP2
        5.1SP1
        5.1SP1PR1
        5.1SP1PR2
        5.1SP1RP1
        5.1SP1PR3
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

    $rel->{rel} = {
        '4.1MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfsman VRTSfspro VRTSfssdk VRTSob VRTSperl VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTScavf VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsmg VRTSvlic VRTSvmpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsw VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsApache VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
        },
        '5.0' => {
            'prod' => {
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSicsco VRTSpbx VRTSatClient VRTSatServer VRTSobc33 VRTSob VRTSccg VRTSmh VRTSaa VRTSspt VRTSvxfscommon VRTSvxfsplatform VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSacclib VRTSvcsag VRTSvcsdr VRTSjre15 VRTScscw VRTSweb VRTScutil VRTSvxvmcommon VRTSvxvmplatform VRTSdsa VRTSfspro VRTSvmpro VRTSdcli VRTSalloc VRTSvdid VRTSddlpr VRTSvrpro VRTSvcsvr VRTSvrw VRTSfssdk VRTSglm VRTScavf VRTSvcssy)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
            },
        },
        '5.0MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
        },
        '5.1PR1' => {
            #_START_RHEL5x8664_5.1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
            },
            #_END_RHEL5x8664_5.1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1' => {
            #_START_RHEL5x8664_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL5x8664_5.1SP1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR1' => {
            #_START_RHEL5x8664_5.1SP1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL5x8664_5.1SP1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR2' => {
            #_START_RHEL5x8664_5.1SP1PR2_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL5x8664_5.1SP1PR2_PRODS_PKGS_DEF_
        },
        '5.1SP1PR3' => {
            #_START_RHEL5x8664_5.1SP1PR3_PRODS_PKGS_DEF_
            'prod' => {
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
            },
            #_END_RHEL5x8664_5.1SP1PR3_PRODS_PKGS_DEF_
        },
        '6.0' => {
            #_START_RHEL5x8664_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL5x8664_6.0_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_RHEL5x8664_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL5x8664_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::RHEL5ppc64;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        5.0RU3
        5.0RU3RP1
        5.0MP4
        5.1SP1PR4
    )];

    $rel->{rel} = {
        '5.0RU3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1SP1PR4' => {
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm)],
                    'opkgs' => [qw(VRTSspt VRTSsfmh)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTSdbed VRTSodm VRTSatClient VRTSatServer)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSvcsea VRTSglm VRTScavf VRTSgms VRTSodm)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr)],
                },
                'sfcfsha' => {
                    'name'  => 'Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSodm)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag)],
                    'opkgs' => [qw(VRTSspt VRTScps VRTSvcsdr VRTSvcsea)],
                },
                'at' => {
                    'name'  => 'Symantec Product Authentication Services',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSatClient)],
                    'opkgs' => [qw(VRTSspt VRTSatServer)],
                },
            },
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::RHEL6x8664;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        4.1MP4
        4.1MP4RP2
        4.1MP4RP3
        4.1MP4RP4
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0MP4
        5.1
        5.1P1
        5.1RP1
        5.1RP1P1
        5.1PR1
        5.1RP2
        5.1SP1
        5.1SP1PR1
        5.1SP1PR2
        5.1SP1RP1
        5.1SP1PR3
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

    $rel->{rel} = {
        '4.1MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfsman VRTSfspro VRTSfssdk VRTSob VRTSperl VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTScavf VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsmg VRTSvlic VRTSvmpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsw VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsApache VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
        },
        '5.0MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
        },
        '5.1PR1' => {
            #_START_RHEL6x8664_5.1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
            },
            #_END_RHEL6x8664_5.1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1' => {
            #_START_RHEL6x8664_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL6x8664_5.1SP1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR1' => {
            #_START_RHEL6x8664_5.1SP1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL6x8664_5.1SP1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR2' => {
            #_START_RHEL6x8664_5.1SP1PR2_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL6x8664_5.1SP1PR2_PRODS_PKGS_DEF_
        },
        '5.1SP1PR3' => {
            #_START_RHEL6x8664_5.1SP1PR3_PRODS_PKGS_DEF_
            'prod' => {
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSsfmh VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf VRTSsvs)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
            },
            #_END_RHEL6x8664_5.1SP1PR3_PRODS_PKGS_DEF_
        },
        '6.0' => {
            #_START_RHEL6x8664_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL6x8664_6.0_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_RHEL6x8664_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_RHEL6x8664_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::RHEL6ppc64;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        5.1SP1PR4
    )];

    $rel->{rel} = {
        '5.1SP1PR4' => {
            'prod' => {
                'at' => {
                    'name'  => 'Symantec Product Authentication Services',
                    'rpkgs' => [qw(VRTSatClient VRTSperl VRTSvlic)],
                    'opkgs' => [qw(VRTSatServer VRTSspt)],
                },
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSvcsea VRTSglm VRTScavf VRTSgms VRTSodm)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr)],
                },
            },
        },
    };
    return;
}



package Rel::UXRT60SP1PR1::SLES9x8664;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        4.1
        4.1MP1
        4.1MP2
        4.1MP3
        4.1MP4
        4.1MP4RP2
        4.1MP4RP3
        4.1MP4RP4
        5.0
        5.0MP1
        5.0MP2
        5.0MP2RP1
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP2
        5.0MP4
    )];

    $rel->{rel} = {
        '4.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfsman VRTSfspro VRTSfssdk VRTSob VRTSperl VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTScavf VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsmg VRTSvlic VRTSvmpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsw VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsApache VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
        },
        '5.0' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvmdoc VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScsocw VRTScutil VRTSdbac VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScfsdc VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(SYMClma VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrdoc VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSvmdoc VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(SYMClma VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSsmf VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmdoc VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvsvc VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSvrdoc)],
                },
            },
        },
        '5.0MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::SLES10x8664;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        4.1MP3
        4.1MP4
        4.1MP4RP2
        4.1MP4RP3
        4.1MP4RP4
        4.1MP4RP5
        5.0
        5.0PR1
        5.0MP3
        5.0MP3RP1
        5.0MP3RP2
        5.0MP3RP3
        5.0RU4
        5.0MP4
        5.1
        5.1P1
        5.1P1RP1
        5.1RP1
        5.1RP2
        5.1SP1
        5.1PR1
        5.1SP1PR1
        5.1SP1PR2
        5.1SP1RP1
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

    $rel->{rel} = {
        '4.1MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTScpi VRTSfsman VRTSfspro VRTSfssdk VRTSob VRTSperl VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSobgui VRTStep)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSalloc VRTScavf VRTScpi VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsmg VRTSvlic VRTSvmpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsmn VRTSvmdoc VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSjre VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSdbdoc VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTScscw VRTScutil VRTSddlpr VRTSfsman VRTSfspro VRTSfssdk VRTSgab VRTSjre VRTSllt VRTSob VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvcsw VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSap VRTScscm VRTScssim VRTSfsdoc VRTSfsmnd VRTSlvmconv VRTSobgui VRTStep VRTSvcsApache VRTSvcsdc VRTSvcsmn VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTScpi VRTScscw VRTScutil VRTSgab VRTSjre VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsw VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsApache VRTSvcsdc VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTScpi VRTSddlpr VRTSfspro VRTSob VRTSperl VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSap VRTSjre VRTSlvmconv VRTSobgui VRTStep VRTSvmdoc VRTSvmman VRTSvrdoc VRTSvrw VRTSweb)],
                },
            },
        },
        '5.0' => {
            'prod' => {
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSicsco VRTSpbx VRTSatClient VRTSatServer VRTSobc33 VRTSob VRTSccg VRTSmh VRTSaa VRTSspt VRTSvxfscommon VRTSvxfsplatform VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSacclib VRTSvcsag VRTSvcsdr VRTSjre15 VRTScscw VRTSweb VRTScutil VRTSvxvmcommon VRTSvxvmplatform VRTSdsa VRTSfspro VRTSvmpro VRTSdcli VRTSalloc VRTSvdid VRTSddlpr VRTSvrpro VRTSvcsvr VRTSvrw VRTSfssdk VRTSglm VRTScavf VRTSvcssy)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
            },
        },
        '5.0PR1' => {
            'prod' => {
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSicsco VRTSpbx VRTSatClient VRTSatServer VRTSobc33 VRTSob VRTSccg VRTSmh VRTSaa VRTSspt VRTSvxfscommon VRTSvxfsplatform VRTSllt VRTSgab VRTSvxfen VRTSvcs VRTSvcsmg VRTSacclib VRTSvcsag VRTSvcsdr VRTSjre15 VRTScscw VRTSweb VRTScutil VRTSvxvmcommon VRTSvxvmplatform VRTSdsa VRTSfspro VRTSvmpro VRTSdcli VRTSalloc VRTSvdid VRTSddlpr VRTSvrpro VRTSvcsvr VRTSvrw VRTSfssdk VRTSglm VRTScavf VRTSvcssy)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
            },
        },
        '5.0MP3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmaprocommon VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSmh VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScmccc VRTScmcs VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSlvmconv VRTSmh VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvrw VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0RU4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
        },
        '5.1SP1' => {
            #_START_SLES10x8664_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES10x8664_5.1SP1_PRODS_PKGS_DEF_
        },
        '5.1PR1' => {
            #_START_SLES10x8664_5.1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
            },
            #_END_SLES10x8664_5.1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR1' => {
            #_START_SLES10x8664_5.1SP1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES10x8664_5.1SP1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR2' => {
            #_START_SLES10x8664_5.1SP1PR2_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES10x8664_5.1SP1PR2_PRODS_PKGS_DEF_
        },
        '6.0' => {
            #_START_SLES10x8664_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES10x8664_6.0_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_SLES10x8664_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES10x8664_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::SLES11x8664;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        5.0RU1
        5.0MP4
        5.1
        5.1P1
        5.1RP1
        5.1RP1P1
        5.1RP2
        5.1SP1
        5.1SP1PR1
        5.1SP1PR2
        5.1SP1RP1
        5.1SP1RP2
        6.0
        6.0RP1
        6.0SP1
    )];

    $rel->{rel} = {
        '5.0RU1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSaa VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSjre15 VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSjre15 VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaa VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTScscw VRTScutil VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSjre15 VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen VRTSweb)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSaa VRTSalloc VRTSatClient VRTSatServer VRTSccg VRTSdcli VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSjre15 VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform VRTSweb)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvdid VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTScutil VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
        },
        '5.1SP1' => {
            #_START_SLES11x8664_5.1SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES11x8664_5.1SP1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR1' => {
            #_START_SLES11x8664_5.1SP1PR1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES11x8664_5.1SP1PR1_PRODS_PKGS_DEF_
        },
        '5.1SP1PR2' => {
            #_START_SLES11x8664_5.1SP1PR2_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSperl VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSdbac VRTSdbed VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvcsdr)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES11x8664_5.1SP1PR2_PRODS_PKGS_DEF_
        },
        '6.0' => {
            #_START_SLES11x8664_6.0_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES11x8664_6.0_PRODS_PKGS_DEF_
        },
        '6.0SP1' => {
            #_START_SLES11x8664_6.0SP1_PRODS_PKGS_DEF_
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs)],
                    'opkgs' => [qw(VRTSfssdk VRTSob VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSfsadv VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSfsadv VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'sfrac' => {
                    'name'  => 'Veritas Storage Foundation for Oracle RAC',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSdbac VRTSdbed VRTSfsadv VRTSgab VRTSglm VRTSgms VRTSllt VRTSodm VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvcsea VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr)],
                },
                'sfsybasece' => {
                    'name'  => 'Veritas Storage Foundation for Sybase ASE CE',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSfssdk VRTSlvmconv VRTSob VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'svs' => {
                    'name'  => 'Symantec VirtualStore',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTScavf VRTSfsadv VRTSgab VRTSglm VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSsfmh VRTSsvs VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSgab VRTSllt VRTSperl VRTSsfcpi60SP1PR1 VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSsfmh VRTSspt VRTSvbs VRTSvcsdr VRTSvcsea)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSsfcpi60SP1PR1 VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSlvmconv VRTSob VRTSsfmh VRTSspt)],
                },
            },
            #_END_SLES11x8664_6.0SP1_PRODS_PKGS_DEF_
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::SLES10ppc64;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        5.0RU3
        5.0RU3RP1
        5.0RU4
        5.0MP4
        5.1SP1PR4
    )];

    $rel->{rel} = {
        '5.0RU3' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0RU4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfora' => {
                    'name'  => 'Veritas Storage Foundation for Oracle',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvmman)],
                },
                'sforaha' => {
                    'name'  => 'Veritas Storage Foundation for Oracle/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSdbcomcommon VRTSdbedcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSorguicommon VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsor VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfsyb' => {
                    'name'  => 'Veritas Storage Foundation for Sybase',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfsybha' => {
                    'name'  => 'Veritas Storage Foundation for Sybase/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSsybedcommon VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcssy VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1SP1PR4' => {
            'prod' => {
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm)],
                    'opkgs' => [qw(VRTSspt VRTSsfmh)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTSdbed VRTSodm VRTSatClient VRTSatServer)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSvcsea VRTSglm VRTScavf VRTSgms VRTSodm)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr)],
                },
                'sfcfsha' => {
                    'name'  => 'Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSglm VRTScavf)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSgms VRTSodm)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr VRTSvcsea VRTSdbed VRTSodm)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag)],
                    'opkgs' => [qw(VRTSspt VRTScps VRTSvcsdr VRTSvcsea)],
                },
                'at' => {
                    'name'  => 'Symantec Product Authentication Services',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSatClient)],
                    'opkgs' => [qw(VRTSspt VRTSatServer)],
                },
            },
        },
    };
    return;
}

package Rel::UXRT60SP1PR1::SLES11ppc64;

sub init_releasematrix {
    my ($rel) = @_;

    $rel->SUPER::init_releasematrix();

    $rel->{releases} = [qw(
        5.0RU4
        5.0MP4
        5.1SP1PR4
    )];

    $rel->{rel} = {
        '5.0RU4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.0MP4' => {
            'prod' => {
                'fs' => {
                    'name'  => 'Veritas File System',
                    'rpkgs' => [qw(VRTSatClient VRTSatServer VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvlic VRTSvxfscommon VRTSvxfsplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSobgui)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScavf VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSglm VRTSgms VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSobgui VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSvcsmn VRTSvmman)],
                },
                'sfdb2' => {
                    'name'  => 'Veritas Storage Foundation for DB2',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'sfdb2ha' => {
                    'name'  => 'Veritas Storage Foundation for DB2/HA',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSd2guicommon VRTSdb2edcommon VRTSdbcomcommon VRTSdbms3 VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdb VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSacclib VRTSalloc VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSddlpr VRTSdsa VRTSfspro VRTSfssdk VRTSgab VRTSicsco VRTSllt VRTSmaprocommon VRTSob VRTSobc33 VRTSodmcommon VRTSodmplatform VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxfen VRTSvxfscommon VRTSvxfsplatform VRTSvxmsa VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSfsman VRTSfsmnd VRTSlvmconv VRTSobgui VRTSvcsmn VRTSvmman)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSacclib VRTSatClient VRTSatServer VRTScscw VRTScutil VRTSgab VRTSicsco VRTSllt VRTSpbx VRTSperl VRTSspt VRTSvcs VRTSvcsag VRTSvcsdr VRTSvcsmg VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScscm VRTScssim VRTSvcsmn)],
                },
                'vm' => {
                    'name'  => 'Veritas Volume Manager',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSlvmconv VRTSobgui VRTSvmman)],
                },
                'vvr' => {
                    'name'  => 'Veritas Volume Replicator',
                    'rpkgs' => [qw(VRTSalloc VRTSatClient VRTSatServer VRTSddlpr VRTSdsa VRTSfspro VRTSicsco VRTSlvmconv VRTSob VRTSobc33 VRTSpbx VRTSperl VRTSsfmh VRTSspt VRTSvcsvr VRTSvlic VRTSvmman VRTSvmpro VRTSvrpro VRTSvxvmcommon VRTSvxvmplatform)],
                    'opkgs' => [qw(VRTSobgui)],
                },
            },
        },
        '5.1SP1PR4' => {
            'prod' => {
                'at' => {
                    'name'  => 'Symantec Product Authentication Services',
                    'rpkgs' => [qw(VRTSatClient VRTSperl VRTSvlic)],
                    'opkgs' => [qw(VRTSatServer VRTSspt)],
                },
                'dmp' => {
                    'name'  => 'Veritas Dynamic Multipathing',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxvm)],
                    'opkgs' => [qw(VRTSsfmh VRTSspt)],
                },
                'sf' => {
                    'name'  => 'Veritas Storage Foundation',
                    'rpkgs' => [qw(VRTSaslapm VRTSperl VRTSvlic VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTSatClient VRTSatServer VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt)],
                },
                'sfcfs' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsha' => {
                    'name'  => 'Veritas Storage Foundation for Cluster File System/HA',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTScavf VRTSgab VRTSglm VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSgms VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfha' => {
                    'name'  => 'Veritas Storage Foundation and High Availability',
                    'rpkgs' => [qw(VRTSamf VRTSaslapm VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen VRTSvxfs VRTSvxvm)],
                    'opkgs' => [qw(VRTScps VRTSdbed VRTSfssdk VRTSlvmconv VRTSob VRTSodm VRTSsfmh VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'vcs' => {
                    'name'  => 'Veritas Cluster Server',
                    'rpkgs' => [qw(VRTSamf VRTSatClient VRTSatServer VRTSgab VRTSllt VRTSperl VRTSvcs VRTSvcsag VRTSvlic VRTSvxfen)],
                    'opkgs' => [qw(VRTScps VRTSspt VRTSvcsdr VRTSvcsea)],
                },
                'sfcfsrac' => {
                    'name'  => 'Veritas Storage Foundation Cluster File System for Oracle RAC',
                    'rpkgs' => [qw(VRTSvlic VRTSperl VRTSvxvm VRTSaslapm VRTSvxfs VRTSatClient VRTSatServer VRTSllt VRTSgab VRTSvxfen VRTSamf VRTSvcs VRTSvcsag VRTSvcsea VRTSglm VRTScavf VRTSgms VRTSodm)],
                    'opkgs' => [qw(VRTSspt VRTSob VRTSlvmconv VRTSsfmh VRTSfssdk VRTScps VRTSvcsdr)],
                },
            },
        },
    };
    return;
}
1;
