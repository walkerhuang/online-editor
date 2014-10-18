use strict;

package Pkg::VRTScps60::Common;
@Pkg::VRTScps60::Common::ISA = qw(Pkg);

sub init_common {
    my $pkg=shift;
    $pkg->{pkg}='VRTScps';
    $pkg->{name}=Msg::new("Veritas Cluster Server - Coordinated Point Server")->{msg};
    $pkg->{stopprocs}=[ qw(vxcpserv60) ];
    $pkg->{cpsadm} = '/opt/VRTScps/bin/cpsadm';
    $pkg->{cpsat} = '/opt/VRTScps/bin/cpsat';
    $pkg->{defport} = '14250';
    return;
}

# Using preremove_sys to clean up CPS DB before an uninstallation
# See e1794040 for details
sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($vcs,$vxfenconf);

    return 1 unless (Cfg::opt('uninstall'));

    $vcs = $sys->prod('VCS60');
    $vxfenconf = $vcs->get_vxfen_config_sys($sys);
    $pkg->cps_cleanup_sys($sys,$vxfenconf,0);
    return '';
}

sub cps_cleanup_sys {
    my ($pkg,$sys,$vxfenconf,$verbose) = @_;
    my ($cpsname,$cpssys,$msg);
    my ($vcs,$vxfenpkg);
    $vcs = $sys->prod('VCS60');
    $vxfenpkg = $sys->pkg('VRTSvxfen60');

    return 1 unless ($vxfenconf->{vxfen_mechanism} =~ /cps/m);

    # Only perform cps cleaning up from the first node in each client cluster.
    return 1 unless ($sys->{system1});

    # Getting UUID to list users corresponding to the cluster
    unless ($vxfenconf->{uuid}) {
        $msg = Msg::new("UUID was not found on $sys->{sys}. Cannot complete Coordination Point Server clean up for the cluster that $sys->{sys} is in. Refer to the documentation for the steps of manual clean up.");
        $sys->push_warning($msg);
        $verbose ? $msg->warning : $msg->log;
        return 1;
    }

    for my $cpsname (@{$vxfenconf->{cps}}) {
        # Assign a Sys object to this CPS
        $cpssys = $vxfenpkg->create_cps_sys($cpsname);
        # Check if we can communicate with cps
        if (!$vxfenpkg->cps_transport_sys($cpssys)) {
            $msg=Msg::new("Cannot communicate with system $cpssys->{sys} which was found to be a Coordination Point server. Cannot complete Coordination Point Server clean up on $cpssys->{sys}. Refer to the documentation for the steps of manual clean up.");
            $sys->push_warning($msg);
            $verbose ? $msg->warning : $msg->log;
            next;
        }
        if ($verbose) {
            $msg = Msg::new("Cleaning up on Coordination Point server $cpsname");
            $msg->left;
            Msg::right_done();
        }
        $pkg->cleanup_from_cps_sys($sys,$cpssys,$vxfenconf,$verbose);
    }
    return '';
}

sub cleanup_from_cps_sys {
    my ($pkg,$sys,$cpssys,$vxfenconf,$verbose) = @_;
    my ($out,$msg,$uuid,$cpsuser,$entry,$cpsadm,@out,@cpsusers,$cpport);

    $uuid = $vxfenconf->{uuid};
    $cpsadm = $pkg->{cpsadm};
    $cpport = $vxfenconf->{cpport}{"$cpssys->{sys}"};

    # Get CPS users for this cluster
    $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_users -p $cpport | _cmd_grep '$uuid'");
    if (EDR::cmdexit() || $out eq '') {
        $msg = Msg::new("Cannot invoke 'cpsadm' to find the Coordination Point Server users registered from $sys->{sys}.");
        $sys->push_warning($msg);
        $verbose ? $msg->warning : $msg->log;
    }
    for my $cpsuser (split (/\n/, $out)) {
        push (@cpsusers, (split(/\//m, $cpsuser))[0]);
    }

    # Ready to clean up!
    # Using UUID instead of cluster name for the former's uniqueness
    # 1. Unregister all the client nodes from CP Server
    for (my $i = 0; $i < scalar @{$sys->{cluster_systems}}; $i++) {
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a unreg_node -u $uuid -n $i");
    }

    # 2. Remove the client cluster from the CP Server
    $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_clus -u $uuid");
    if (EDR::cmdexit()) {
        $msg = Msg::new("Cannot invoke 'cpsadm' to remove the client cluster with UUID $uuid from Coordination Point server $cpssys->{sys}. Cannot complete Coordination Point Server clean up. Refer to the documentation for the steps of manual clean up.");
        $sys->push_warning($msg);
        $verbose ? $msg->warning : $msg->log;
        return 1;
    }

    # 3. Remove all the CPClient users for communicating to CP Server
    # Remove only if the user is not part of any cluster. (Denoted by a '-' in the 'list_users' output)
    for my $cpsuser (@cpsusers) {
        $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -a list_users -p $cpport | _cmd_grep '$cpsuser/'");
        @out = split (/\n/, $out);
        for my $entry (@out) {
            # The cluster name
            $out = (split (/\s+/m, $entry))[1];
            $out = EDRu::despace($out);
            next if ($out ne '-');
            $out = $cpssys->cmd("$cpsadm -s $cpssys->{sys} -p $cpport -a rm_user -e $cpsuser -g vx");
            if (EDR::cmdexit()) {
                $msg = Msg::new("Cannot invoke 'cpsadm' to remove the Coordination Point client user $cpsuser from Coordination Point server $cpssys->{sys}. Cannot complete Coordination Point Server clean up. Refer to the documentation for the steps of manual clean up.");
                $sys->push_warning($msg);
                $verbose ? $msg->warning : $msg->log;
                last;
            }
        }
    }
    $msg = Msg::new("Successfully done clean up from the Coordination Point Server DB on Coordination Point server $cpssys->{sys} for the cluster (UUID: $uuid).");
    $msg->log;
    return '';
}

package Pkg::VRTScps60::AIX;
@Pkg::VRTScps60::AIX::ISA = qw(Pkg::VRTScps60::Common);

package Pkg::VRTScps60::HPUX;
@Pkg::VRTScps60::HPUX::ISA = qw(Pkg::VRTScps60::Common);

package Pkg::VRTScps60::Linux;
@Pkg::VRTScps60::Linux::ISA = qw(Pkg::VRTScps60::Common);

package Pkg::VRTScps60::RHEL5x8664;
@Pkg::VRTScps60::RHEL5x8664::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libcrypt.so.1"  =>  "glibc-2.5-58.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2-50.el5.i386",
        "libm.so.6"  =>  "glibc-2.5-58.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libnsl.so.1"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.5-58.i686",
        "libresolv.so.2"  =>  "glibc-2.5-58.i686",
        "librt.so.1"  =>  "glibc-2.5-58.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.5-58.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2-50.el5.i386",
        "rtld(GNU_HASH)"  =>  "glibc-2.5-58.i686 glibc-2.5-58.x86_64",
    };
    return;
}

package Pkg::VRTScps60::RHEL6x8664;
@Pkg::VRTScps60::RHEL6x8664::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libcrypt.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libgcc_s.so.1"  =>  "libgcc-4.4.5-6.el6.i686",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.4.5-6.el6.i686",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.4.5-6.el6.i686",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.4.5-6.el6.i686",
        "libm.so.6"  =>  "glibc-2.12-1.25.el6.i686",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libnsl.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libresolv.so.2"  =>  "glibc-2.12-1.25.el6.i686",
        "librt.so.1"  =>  "glibc-2.12-1.25.el6.i686",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-2.12-1.25.el6.i686",
        "libstdc++.so.6"  =>  "libstdc++-4.4.5-6.el6.i686",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.4.5-6.el6.i686",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.4.5-6.el6.i686",
        "rtld(GNU_HASH)"  =>  "glibc-2.12-1.25.el6.i686 glibc-2.12-1.25.el6.x86_64",
    };
    return;
}

package Pkg::VRTScps60::SLES10x8664;
@Pkg::VRTScps60::SLES10x8664::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libgcc_s.so.1"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GCC_4.2.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc-4.1.2_20070115-0.32.53.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.4-31.81.11.x86_64",
        "libstdc++.so.6"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++-4.1.2_20070115-0.32.53.x86_64",
    };
    return;
}

package Pkg::VRTScps60::SLES11x8664;
@Pkg::VRTScps60::SLES11x8664::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        "libc.so.6"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.1.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.3)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libc.so.6(GLIBC_2.4)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libcrypt.so.1(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libdl.so.2(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libgcc_s.so.1"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libgcc_s.so.1(GCC_3.0)"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libgcc_s.so.1(GCC_3.3)"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libgcc_s.so.1(GCC_4.2.0)"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libgcc_s.so.1(GLIBC_2.0)"  =>  "libgcc43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libm.so.6"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libm.so.6(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libnsl.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.0)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.1)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libpthread.so.0(GLIBC_2.3.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libresolv.so.2"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "librt.so.1"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "librt.so.1(GLIBC_2.2)"  =>  "glibc-32bit-2.11.1-0.17.4.x86_64",
        "libstdc++.so.6"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(CXXABI_1.3)"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
        "libstdc++.so.6(GLIBCXX_3.4)"  =>  "libstdc++43-32bit-4.3.4_20091019-0.7.35.x86_64",
    };
    return;
}

package Pkg::VRTScps60::RHEL5ppc64;
@Pkg::VRTScps60::RHEL5ppc64::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libcrypt.so.1'  =>  'glibc-2.5-24.ppc',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_3.3)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GCC_4.1.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc-4.1.2-42.el5.ppc',
        'libm.so.6'  =>  'glibc-2.5-24.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libnsl.so.1'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.5-24.ppc',
        'libresolv.so.2'  =>  'glibc-2.5-24.ppc',
        'libresolv.so.2(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'librt.so.1'  =>  'glibc-2.5-24.ppc',
        'librt.so.1(GLIBC_2.2)'  =>  'glibc-2.5-24.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2-42.el5.ppc',
        'rtld(GNU_HASH)'  =>  'glibc-2.5-24.ppc glibc-2.5-24.ppc64',
    };
    return;
}

package Pkg::VRTScps60::SLES10ppc64;
@Pkg::VRTScps60::SLES10ppc64::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libgcc_s.so.1'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GCC_4.1.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc-4.1.2_20070115-0.21.ppc',
        'libm.so.6'  =>  'glibc-2.4-31.54.ppc',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libnsl.so.1'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-2.4-31.54.ppc',
        'libresolv.so.2'  =>  'glibc-2.4-31.54.ppc',
        'librt.so.1'  =>  'glibc-2.4-31.54.ppc',
        'librt.so.1(GLIBC_2.2)'  =>  'glibc-2.4-31.54.ppc',
        'libstdc++.so.6'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++-4.1.2_20070115-0.21.ppc',
    };
    return;
}

package Pkg::VRTScps60::SLES11ppc64;
@Pkg::VRTScps60::SLES11ppc64::ISA = qw(Pkg::VRTScps60::Linux);

sub init_padv {
    my $pkg=shift;
    $pkg->{oslibs}{all}={
        'libc.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.1.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libc.so.6(GLIBC_2.4)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libcrypt.so.1(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libdl.so.2(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libgcc_s.so.1'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_3.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GCC_4.1.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libgcc_s.so.1(GLIBC_2.0)'  =>  'libgcc43-32bit-4.3.3_20081022-11.18.ppc64',
        'libm.so.6'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libm.so.6(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libnsl.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.0)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.1)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.3.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libpthread.so.0(GLIBC_2.6)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libresolv.so.2'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'librt.so.1'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'librt.so.1(GLIBC_2.2)'  =>  'glibc-32bit-2.9-13.2.ppc64',
        'libstdc++.so.6'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(CXXABI_1.3)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
        'libstdc++.so.6(GLIBCXX_3.4)'  =>  'libstdc++43-32bit-4.3.3_20081022-11.18.ppc64',
    };
    return;
}

package Pkg::VRTScps60::SunOS;
@Pkg::VRTScps60::SunOS::ISA = qw(Pkg::VRTScps60::Common);

sub preremove_sys {
    my ($pkg,$sys) = @_;
    my ($rootpath,$vers);

    $rootpath=Cfg::opt('rootpath')||'';
    $vers = $pkg->version_sys($sys);
    # Remove VRTScps preremove scripts on ABE during Live Upgrade.
    if (Cfg::opt('upgrade') && $rootpath
        && (EDRu::compvers($vers,'6.0')==2)) {
        $sys->rm("$rootpath/var/sadm/pkg/$pkg->{pkg}/install/preremove");
    }
    return;
}

1;
