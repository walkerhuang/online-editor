use strict;

package Prod::VM60::Common;
@Prod::VM60::Common::ISA = qw(Prod);

sub init_common {
    my $prod = shift;
    $prod->{vers}='6.0.100.000';
    if ($prod->{class} =~ /DMP/m) {
        $prod->{prod}='DMP';
        $prod->{abbr}='DMP';
        $prod->{name}=Msg::new("Veritas Dynamic Multi-Pathing")->{msg};
        $prod->{proddir}='dynamic_multipathing';
        $prod->{eula}='EULA_DMP_Ux_6.0SP1.pdf';
        $prod->{lic_names}=['VERITAS Dynamic Multi-pathing', 'Veritas Volume Manager'];
    } else {
        $prod->{prod}='VM';
        $prod->{abbr}='VM';
        $prod->{name}=Msg::new("Veritas Volume Manager")->{msg};
        $prod->{proddir}='volume_manager';
        $prod->{eula}='EULA_SF_Ux_6.0SP1.pdf';
        $prod->{lic_names}=['Veritas Volume Manager'];
    }
    $prod->{mainpkg}='VRTSvxvm60';

    $prod->{dg_boot}='bootdg';
    $prod->{dg_default}='defaultdg';


    # Various paths
    $prod->{rdir}='/etc/vx/reconfig.d';
    $prod->{mkdbfile}='/etc/vx/reconfig.d/state.d/install-db';
    $prod->{volbootfile}='/etc/vx/volboot';
    $prod->{newnames_file}='/etc/vx/.newnames';
    $prod->{migrate_native_file}='/etc/vx/.cpi_migrate_native';
    $prod->{configfiles}=[ '/etc/vx/volboot', '/kernel/drv/vxio.conf', '/kernel/drv/vxdmp.conf', '/etc/vx/array.info', '/etc/vx/jbod.info', '/etc/vx/ddl.support', '/etc/vx/vxddl.exclude', '/etc/vx/vxvm.exclude', '/etc/vx/vxdmp.exclude', '/etc/vx/vvrports', '/etc/vx/disks.exclude', '/etc/vx/cntrls.exclude', '/etc/vx/enclr.exclude', '/etc/vx/vras/.rdg', '/etc/vx/vras/vras_env', '/etc/vx/darecs', '/etc/vx/guid.state', '/etc/vx/hacomm.conf', '/etc/vx/dmppolicy.info' ];
    $prod->{vxunroot}='/usr/lib/vxvm/bin/vxunroot';
    $prod->{vxvm_exclude_file}='/etc/vx/vxvm.exclude';
    $prod->{no_update_exclude_file}='/etc/vx/.no_update_vxvm.exclude';
    $prod->{cf_bkup_base_path}='/etc/vx/cbr';
    $prod->{cf_bkup_path}="$prod->{cf_bkup_base_path}/bk";

    $prod->{vvr_upgrade_finished} = 0;
    $prod->{responsefileupgradeok}=1;
    # need run 'vxrecover' with serial mode when poststart.
    $prod->{multisystemserialpoststart}=1;

    $prod->{obsoleted_but_still_support_pkgs}=[qw(VRTSdbms3)];

    # Define start and stop commands for processes and drivers
    # which are common across all four Unix platforms
    my $padv = $prod->padv();
    $padv->{cmd}{vvrport}='/usr/sbin/vrport';
    $padv->{cmd}{vvrstart}='/usr/sbin/vxstart_vvr';
    $padv->{cmd}{vvrstop}='/usr/sbin/vxstart_vvr stop';
    $padv->{cmd}{vxtune}='/usr/sbin/vxtune'; #vxtune is specific in Linux
    $padv->{cmd}{vras_script}='/etc/init.d/vras-vradmind.sh';
    $padv->{cmd}{vxrootadm}='/etc/vx/bin/vxrootadm';
    $padv->{cmd}{vxconfigbackup}='/etc/vx/bin/vxconfigbackup';

    # Common paths for scripts
    $prod->{vrasconf}='/etc/vx/vras/vras_env';
    $prod->{vras_str}='VRAS_LOG_MAXLEN=';
    $prod->{vras_stats_frequency_str}='VRAS_STATS_FREQUENCY=';
    $prod->{vras_stats_days_log_str}='VRAS_STATS_DAYS_LOG=';

    # Supported Tunables
    if ($prod->{class} =~ /DMP/m) {
        $prod->{tunables} = [
            {
                "name" => "dmp_cache_open",
                "desc" => Msg::new("Whether the first open on a device performed by an array support library (ASL) is cached")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_daemon_count",
                "desc" => Msg::new("The number of kernel threads for DMP administrative tasks")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1, 512, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_delayq_interval",
                "desc" => Msg::new("The time interval for which DMP delays the error processing if device is busy")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_restore_state",
                "desc" => Msg::new("Whether kernel thread for DMP path restoration is enabled")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "enabled", "disabled", "stopped" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_fast_recovery",
                "desc" => Msg::new("Whether DMP should attempt to obtain SCSI error information directly from HBA interface")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_health_time",
                "desc" => Msg::new("The time in seconds for which a path must stay healthy")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_log_level",
                "desc" => Msg::new("The level of detail to which DMP console messages are displayed")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ 1, 2, 3, 4 ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_low_impact_probe",
                "desc" => Msg::new("Whether the low impact path probing feature is enabled")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_lun_retry_timeout",
                "desc" => Msg::new("The retry period for handling transient errors")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_path_age",
                "desc" => Msg::new("The time for which an intermittently failing path needs to be monitored before DMP marks it as healthy")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_pathswitch_blks_shift",
                "desc" => Msg::new("The default number of contiguous I/O blocks sent along a DMP path to an array before switching to the next available path")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_probe_idle_lun",
                "desc" => Msg::new("Whether the path restoration kernel thread probes idle LUNs")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_probe_threshold",
                "desc" => Msg::new("The number of paths will be probed by the restore daemon")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_restore_cycles",
                "desc" => Msg::new("The number of cycles between running the check_all policy when the restore policy is check_periodic")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_restore_interval",
                "desc" => Msg::new("The time interval in seconds the restore daemon analyzes the condition of paths")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_restore_policy",
                "desc" => Msg::new("The policy used by DMP path restoration thread")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "check_disabled","check_periodic","check_alternate","check_all" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_retry_count",
                "desc" => Msg::new("The number of times a path reports a path busy error consecutively before DMP marks the path as failed")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_scsi_timeout",
                "desc" => Msg::new("The timeout value for any SCSI command sent via DMP")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_sfg_threshold",
                "desc" => Msg::new("The status of the subpaths failover group (SFG) feature")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_stat_interval",
                "desc" => Msg::new("The time interval between gathering DMP statistics")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 2147483647, undef ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_monitor_ownership",
                "desc" => Msg::new("Whether the dynamic change in LUN ownership is monitored")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_monitor_fabric",
                "desc" => Msg::new("Whether the Event Source daemon (vxesd) uses the Storage Networking Industry Association (SNIA) HBA API")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_monitor_osevent",
                "desc" => Msg::new("Whether the Event Source daemon (vxesd) monitors operating system events")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            {
                "name" => "dmp_native_support",
                "desc" => Msg::new("Whether DMP does multipathing for native devices")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
        ];
    } else {
        $prod->{tunables} = [
            {
                "name" => "vol_maxio",
                "desc" => Msg::new("Maximum size of logical VxVM I/O operations (kBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [512, 2147483647, undef], # min, max, divisor
                "when_to_set" => 2,
            },
            {
                "name" => "vol_checkpt_default",
                "desc" => Msg::new("Size of VxVM checkpoints (kBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 10240, 2147483647, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_cmpres_enabled",
                "desc" => Msg::new("Allow enabling compression for VERITAS Volume Replicator")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ 0, 1, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_cmpres_threads",
                "desc" => Msg::new("Maximum number of compression threads for VERITAS Volume Replicator")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1, 64, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_default_iodelay",
                "desc" => Msg::new("Time to pause between I/O requests from VxVM utilities (10ms units)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 50, 200, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_fmr_logsz",
                "desc" => Msg::new("Maximum size of bitmap Fast Mirror Resync uses to track changed blocks (KBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1, 8, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_max_adminio_poolsz",
                "desc" => Msg::new("Maximum amount of memory used by VxVM admin IO's (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 33554432, 134217728, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_max_nmpool_sz",
                "desc" => Msg::new("Maximum name pool size (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1048576, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_max_rdback_sz",
                "desc" => Msg::new("Storage Record readback pool maximum (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1048576, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_max_wrspool_sz",
                "desc" => Msg::new("Maximum memory used in clustered version of VERITAS Volume Replicator")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1048576, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_maxioctl",
                "desc" => Msg::new("Maximum size of data passed into the VxVM ioctl calls (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 16384, 1048576, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_maxparallelio",
                "desc" => Msg::new("Number of I/O operations vxconfigd can request at one time")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1, 512, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_maxspecialio",
                "desc" => Msg::new("Maximum size of a VxVM I/O operation issued by an ioctl call (kBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 512, 4096, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_min_lowmem_sz",
                "desc" => Msg::new("Low water mark for memory (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 532480, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_nm_hb_timeout",
                "desc" => Msg::new("VERITAS Volume Replicator timeout value (ticks)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 10, 60, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_rvio_maxpool_sz",
                "desc" => Msg::new("Maximum memory requested by VERITAS Volume Replicator (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 1048576, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_stats_enable",
                "desc" => Msg::new("Enable VM I/O stat collection")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ 0, 1, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_subdisk_num",
                "desc" => Msg::new("Maximum number of subdisks attached to a single VxVM plex")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1, 4096, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_max_drtregs",
                "desc" => Msg::new("Maximum number of dirty VxVM regions")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 2048, 16384, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_max_seq_dirty",
                "desc" => Msg::new("Maximum number of diry regions in sequential mode")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1, 16384, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_min_regionsz",
                "desc" => Msg::new("Minimum size of a VxVM Dirty Region Logging (DRL) region (kBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1024, 2097512, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_volumemax_drtregs",
                "desc" => Msg::new("Max per volume dirty regions in log-plex DRL")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 8, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_volumemax_drtregs_20",
                "desc" => Msg::new("Max per volume dirty regions in DCO version 20")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 8, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_dirty_regions",
                "desc" => Msg::new("Number of regions cached for DCO version 30")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 8, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliomem_chunk_size",
                "desc" => Msg::new("Size of VxVM memory allocation requests (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 16384, 524288, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliomem_maxpool_sz",
                "desc" => Msg::new("Maximum amount of memory used by VxVM (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1048576, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliot_errbuf_dflt",
                "desc" => Msg::new("Size of a VxVM error trace buffer (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 8192, 65536, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliot_iobuf_default",
                "desc" => Msg::new("Default size of a VxVM I/O trace buffer (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 8192, 524288, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliot_iobuf_limit",
                "desc" => Msg::new("Maximum total size of all VxVM I/O trace buffers (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 32768, 8388608, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliot_iobuf_max",
                "desc" => Msg::new("Maximum size of a VxVM I/O trace buffer (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 16384, 4194304, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliot_max_open",
                "desc" => Msg::new("Maximum number of VxVM trace channels available for vxtrace commands")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 16, 128, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "volpagemod_max_memsz",
                "desc" => Msg::new("Maximum paging module memory used by Instant Snapshots(Kbytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 0, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "volraid_rsrtransmax",
                "desc" => Msg::new("Maximum number of VxVM RAID-5 transient reconstruct operations in parallel")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 1, 5, undef ],
                "when_to_set" => 2,
            },
        ];
    }

    return;
}

sub version_sys {
    my ($prod,$sys,$force_flag) = @_;
    my ($pkgvers,$mpvers,$cpic,$rel,$pkg);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    $pkg=$sys->pkg($prod->{mainpkg});
    return '' unless ($prod->{mainpkg});
    $pkgvers=$pkg->version_sys($sys,$force_flag);
    $mpvers=$prod->{vers} if ($pkgvers && $prod->check_installed_patches_sys($sys,$pkgvers));
    $pkgvers= $prod->revert_base_version_sys($sys,$pkg,$pkgvers,$mpvers,$force_flag);
    if($prod->{class}!~/DMP/m){
        if((!$rel->prod_licensed_sys($sys,$prod->{prodi})) &&
            $rel->feature_licensed_sys($sys, 'DMP Native Support')){
            return '';
        }elsif($rel->prod_licensed_sys($sys,$prod->{prodi}) && !$rel->feature_licensed_sys($sys, 'VxVM')){
             return '';
        }else {
            return ($mpvers || $pkgvers);
        }
    } else {
        return ($mpvers || $pkgvers);
    }
    return '';
}

sub licensed_sys {
    my ($prod,$sys) = @_;
    my ($cpic,$rel);
    $cpic = Obj::cpic();
    $rel = $cpic->rel;
    $prod->vr_licensed_sys($sys);
    $prod->vfr_licensed_sys($sys);
    if ($prod->{class} =~ /DMP/m) {
        $rel->read_licenses_sys($sys);
        # don't accept SF Basic key
        return 0 if (($sys->{vxlicrep} =~ /Storage Foundation Basic/) && (!$rel->feature_licensed_sys($sys, 'DMP Native Support')));
    }
    return $rel->prod_licensed_sys($sys);
}

sub install_precheck_sys {
    my ($prod,$sys)= @_;
    $prod->obsoleted_thirdparty_pkgs_sys($sys);
    return;
}

sub check_config {
    return 1;
}

sub precheck_task {
    my $prod = shift;
    if (Cfg::opt(qw(patchupgrade upgrade))) {
        EDR::register_save_logfiles("vvr_upgrade");
    }
    return;
}

sub configure_precheck_sys {
    my ($prod,$sys) = @_;
    $prod->vom_ports_status_sys($sys);
    return;
}

sub configure_sys {
    my ($prod,$sys) = @_;
    # Needed to run "vxddladm addsupport all" on AIX
    $prod->vxddladm_addsupport_sys($sys);
    return;
}

sub description {
    my ($msg);
    my $prod = shift;
    if ($prod->{prod} =~ /DMP/m) {
        $msg=Msg::new("Veritas Dynamic Multi-Pathing, the industry leading software for managing multiported storage systems by various vendors. Veritas Dynamic Multi-Pathing provides high availability, reliability and performance by using path failover and load balancing.");
    } else {
        $msg=Msg::new("Veritas Volume Manager provides easy-to-use, online storage management tools, which reduce planned and unplanned downtime. Volume Manager removes the physical limitations of disk storage, so you can configure, share, manage and optimize storage I/O performance online without interrupting data availability.");
    }
    $msg->print;
    return;
}

#
# Function: open_volumes_sys()
# Purpose:
#       Determines if any VM volumes are open.
# Input Parameters:
#       References $sys
sub open_volumes_sys {
    my ($prod,$sys,$action) = @_;
    my ($voldmode,$msg,$cfg,@volumes,$vlist,$volume);
    return 0 if ($sys->{encap});

    $cfg=Obj::cfg();
    $cfg->{vm_no_open_vols} ||=0;

    $voldmode=$sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    if ( $voldmode !~ /mode: enabled/m ) {
        if ( $cfg->{vm_no_open_vols} ) {
            $msg=Msg::new("Cannot check for open volumes on $sys->{sys} because the vxconfigd process is not in enabled mode.  However, you set \$CFG{vm_no_open_vols} to be non-zero in the response file, which indicates that you are affirming there are no open volumes on system $sys->{sys}.");
        } else {
            $msg=Msg::new("Cannot check for open volumes on $sys->{sys} because the vxconfigd process is not in enabled mode. You must affirm that there are no open volumes if you want to continue.");
        }
        $sys->push_warning($msg);
        return 0;
    }

    Msg::log("Checking $sys->{sys} for open volumes");
    $vlist=$sys->cmd('_cmd_vxprint -QAqne v_open 2>/dev/null');
    for my $volume (split(/\n/,$vlist)) {
        # Filter out any WARNING message from an SF Basic installation
        next if ($volume=~/VxVM vxprint WARNING/m);
        push(@volumes,$volume);
    }

    if ($#volumes >= 0) {
        $vlist=join(' ', @volumes);
        Msg::log("open volumes: $vlist");
        $msg=Msg::new("Cannot proceed because the following open volumes exist on system $sys->{sys}:\n\t$vlist");
        $sys->push_error($msg);
    } else {
        Msg::log('None');
    }

    return 0;
}

sub obsoleted_thirdparty_pkgs_sys {
    my ($prod,$sys) = @_;
    my (@thirdparty_pkgs,$msg,$pkgs,$asl_pkgs,$apm_pkgs);

    # get obsoleted third party ASL/APM packages
    @thirdparty_pkgs=();
    if (defined $sys->{obsoleted_thirdparty_pkgs}) {
        push (@thirdparty_pkgs, @{$sys->{obsoleted_thirdparty_pkgs}});
    }
    if ($prod->can('obsoleted_asl_pkgs_sys')) {
        $asl_pkgs=$prod->obsoleted_asl_pkgs_sys($sys);
        push (@thirdparty_pkgs, @{$asl_pkgs});
        $pkgs=join("\n\t", @{$asl_pkgs});
        if ($pkgs) {
            $msg=Msg::new("The following obsolete ASL packages will be uninstalled on $sys->{sys}\n\t$pkgs");
            $sys->push_warning($msg);
        }
    }

    if ($prod->can('obsoleted_apm_pkgs_sys')) {
        $apm_pkgs=$prod->obsoleted_apm_pkgs_sys($sys);
        push (@thirdparty_pkgs, @{$apm_pkgs});
        $pkgs=join("\n\t", @{$apm_pkgs});
        if ($pkgs) {
            $msg=Msg::new("The following obsolete APM packages will be uninstalled on $sys->{sys}\n\t$pkgs");
            $sys->push_warning($msg);
        }
    }

    if (@thirdparty_pkgs) {
        $sys->set_value('obsoleted_thirdparty_pkgs','list',@thirdparty_pkgs);
    }
    return 1;
}

sub cli_preinstall_messages {
    # SunOS need special steps, othter plat just return 1
    return 1;
}

sub stop_precheck_sys {
    my ($prod,$sys)= @_;
    if ($prod->is_encapsulated_bootdisk_sys($sys)){
        $prod->set_flag_encap_stop_sys($sys);
    }
    $prod->open_volumes_sys($sys, 'stop');
    return;
}

sub pre_shutdown_question {
    my $prod=shift;
    my ($cfg,$mirror_syslist,$mirror_systems_str,$confirm,$split_mirror_syslist,$answer);
    my $web = Obj::web();
    return '' unless (Cfg::opt(qw/upgrade patchupgrade/));
    # get the system list which have mirrored boot disk
    for my $sys (@{CPIC::get('systems')}) {
        if ($sys->{mirror}) {
            push (@$mirror_syslist, $sys);
            $mirror_systems_str.=" $sys->{sys}";
        }
    }
    # return if there is no mirrorred systems
    return '' if ($#{$mirror_syslist}<0);
    if (Obj::webui()){
        $web->web_script_form('vxroot_adm',$mirror_syslist,$prod);
        return;
    }
    while (1) {
        Msg::title();
        # ask the mirrorred system list which need to be split
        $answer=$prod->ask_split_systems($mirror_syslist,$mirror_systems_str);
        next if (EDR::getmsgkey($answer,'back'));

        # return if there is no mirrored systems to be split
        $split_mirror_syslist=$prod->get_split_mirror_syslist($mirror_syslist);
        return '' if ($#{$split_mirror_syslist}<0);

        # ask the split dg name for each system
        $answer=$prod->ask_split_mirrordg_name($split_mirror_syslist);
        next if (EDR::getmsgkey($answer,'back'));

        # confirm the split operations on each system and execute
        $confirm=$prod->confirm_split_mirrordg_info($split_mirror_syslist);
        if ($confirm eq 'Y') {
            $prod->execute_split_mirror_operation($split_mirror_syslist);
            last;
        }
    }
    return;
}

sub ask_split_systems {
    my ($prod,$mirror_syslist,$mirror_systems_str)=@_;
    my ($ayn,$split_all,$msg,$cfg,$split_mirror_syslist,$backopt,$help,$nosplit_syslist);
    return if (Cfg::opt('responsefile'));

    $cfg=Obj::cfg();
    $cfg->{splitmirror}=undef;

    # ask the below question only when there are more than one mirrorred systems
    if ($#{$mirror_syslist}>0) {
        $msg=Msg::new("The following systems have mirrored and encapsulated bootdisk:$mirror_systems_str.\nDo you want to split the mirrors to create backups of the boot disks on all systems?");
        $help=Msg::new("It is highly recommended to split the mirrors to get a backup copy of your systems in case something goes wrong during upgrade. Answer 'y' if you want to split mirrors on all the systems. Answer 'n' if you prefer this question to be asked per system.");
        $split_all=$msg->ayny($help);
        if ($split_all eq 'Y') {
            for my $sys (@$mirror_syslist) {
                $cfg->{splitmirror}{$sys->{sys}}=1;
            }
        }
    }
    # ask the below questions when there is only one mirrorred system
    # or user choose not to split on all mirrorred systems
    $backopt=1 if ($#{$mirror_syslist}>0);
    $help=Msg::new("It is highly recommended to split the mirror to get a backup copy of your system in case something goes wrong during upgrade. Answer 'y' if you want to split mirror on this system. Otherwise, answer 'n'.");
    if ($#{$mirror_syslist}==0 || $split_all eq 'N') {
        for my $sys (@$mirror_syslist) {
            $msg=Msg::new("System $sys->{sys} has a boot disk that is mirrored and encapsulated.\nDo you want to split the mirror before upgrading the system?");
            $ayn=$msg->ayny($help,$backopt);
            return $ayn if (EDR::getmsgkey($ayn,'back'));
            $cfg->{splitmirror}{$sys->{sys}}=1 if ($ayn eq 'Y');
            if ($ayn eq 'N') {
                $nosplit_syslist.=" $sys->{sys}";
                $msg=Msg::new("System $sys->{sys} has a boot disk that is mirrored and encapsulated. To proceed without splitting the mirror will upgrade the bootdg as a whole. If any errors occur during upgrade phase, there is no way to revert the boot disk back.\n");
                $msg->warning();
            }
        }
    }
    # confirm if user choose not to split
    if ($nosplit_syslist) {
        $msg=Msg::new("Are you sure that you don't want to split the mirrors on$nosplit_syslist?");
        $ayn=$msg->ayny('',$backopt);
        if ($ayn eq 'Y') {
            return $ayn;
        } else {
            return EDR::get2('msg','back');
        }
    }
    return 1;
}

sub ask_split_mirrordg_name {
    my ($prod,$split_mirror_syslist)=@_;
    my ($cfg,$sys1,$msg,$ans,$ayn,$backopt,$help,$default_dg,$msg_dup_dgname,$dup_syslist);
    return if (Cfg::opt('responsefile'));

    $default_dg='backup_bootdg';
    $help=Msg::new("The mirrored disk will be split into a new disk group. Enter a name for the new disk group.");
    $backopt=1;
    $cfg=Obj::cfg();
    $cfg->{mirrordgname}=undef;

    $sys1=$$split_mirror_syslist[0];
    $msg=Msg::new("Input the target disk group name on $sys1->{sys}:");
    while(1) {
        $ans=$msg->ask($default_dg,$help,$backopt);
        return $ans if (EDR::getmsgkey($ans,'back'));
        if ($prod->verify_dgname_sys($sys1,$ans)) {
            last;
        } else {
            $msg_dup_dgname=Msg::new("The disk group name $ans is invalid. Input another name for split mirror disk group on $sys1->{sys}.\n");
            $msg_dup_dgname->print();
        }
    }
    $cfg->{mirrordgname}{$sys1->{sys}}="$ans";

    if ($#{$split_mirror_syslist}>0){
        $msg=Msg::new("Do you want to use $ans as the target disk group name on all the mirrored systems where you want to create backups?");
        DG_ALL : $ayn=$msg->ayny('',$backopt);
        return $ayn if (EDR::getmsgkey($ayn,'back'));
        if ($ayn eq 'Y') {
            $dup_syslist='';
            for my $sys (@$split_mirror_syslist) {
                $dup_syslist.="$sys->{sys} " if (!$prod->verify_dgname_sys($sys,$ans));
            }
            if ($dup_syslist) {
                $msg_dup_dgname=Msg::new("The disk group name $ans is invalid. Input another name for the target disk group on $dup_syslist.\n");
                $msg_dup_dgname->print();
                goto DG_ALL;
            }
            # set cfg value for each system with the same answer
            for my $sys (@$split_mirror_syslist) {
                $cfg->{mirrordgname}{$sys->{sys}}="$ans";
            }
        } else {
            for my $sys (@$split_mirror_syslist) {
                next if ($sys->{sys} eq $sys1->{sys}); # do not ask question for sys1 again
                $msg=Msg::new("Input the target disk group name on $sys->{sys}:");
                while (1) {
                    $ans=$msg->ask($default_dg,$help,$backopt);
                    return $ans if (EDR::getmsgkey($ans,'back'));
                    if ($prod->verify_dgname_sys($sys,$ans)) {
                        last;
                    } else {
                        $msg_dup_dgname=Msg::new("The disk group name $ans is invalid. Input another name for the target disk group on $sys->{sys}.\n");
                        $msg_dup_dgname->print();
                    }
                }
                $cfg->{mirrordgname}{$sys->{sys}}="$ans";
            }
        }
    }
    return 1;
}

sub verify_dgname_sys {
    my ($prod,$sys,$dgname)=@_;
    my ($output,@dgnames);

    $output=$sys->cmd("_cmd_vxdg list | _cmd_grep -v NAME | _cmd_awk {'print \$1'}");
    @dgnames=split(/\n/,$output);
    @dgnames=(@dgnames, qw/bootdg defaultdg nodg/);
    if ( EDRu::nonascii($dgname)|| EDRu::inarr($dgname,@dgnames) || length($dgname)>31 || $dgname=~/[!@#$%^&*]/) {
        return 0;
    }
    return 1;
}

sub get_split_mirror_syslist {
    my ($prod,$mirror_syslist)=@_;
    my ($cfg,$split_mirror_syslist);
    $cfg=Obj::cfg();
    for my $sys (@$mirror_syslist) {
        push (@$split_mirror_syslist, $sys) if ($cfg->{splitmirror}{$sys->{sys}});
    }
    return $split_mirror_syslist;
}

sub confirm_split_mirrordg_info {
    my ($prod,$split_mirror_syslist)=@_;
    my ($mirrordgname,$bootdgname,$msg,$ayn,$backopt);
    my ($format, $msg_sn, $msg_dgn,$msg_bgn,$msg_none,@sys_dgname_map,$sys_dgname_map);
    #return if (Cfg::opt("responsefile"));

    my $cfg=Obj::cfg();
    $format = '%-17s - %-15s - %-15s';
    $msg_sn = Msg::new("System Name")->{msg};
    $msg_bgn = Msg::new("Boot disk group name")->{msg};
    $msg_dgn = Msg::new("Target Boot disk group name")->{msg};
    $msg_none   = Msg::new("None")->{msg};
    push(@sys_dgname_map, Msg::string_sprintf($format, $msg_sn, $msg_bgn, $msg_dgn));
    for my $sys (@$split_mirror_syslist) {
        $bootdgname=$sys->cmd('_cmd_vxdg bootdg 2>/dev/null');
        $mirrordgname=$cfg->{mirrordgname}{$sys->{sys}} || $msg_none;
        push(@sys_dgname_map, Msg::string_sprintf($format, $sys->{sys}, $bootdgname, $mirrordgname));
    }
    $sys_dgname_map=join("\n", @sys_dgname_map);
    Msg::n();
    Msg::print($sys_dgname_map);
    $backopt=1;
    $msg=Msg::new("Note that the split operation can take some time to complete.");
    $msg->print();
    $msg=Msg::new("Do you want to split the mirrors?");
    $ayn=$msg->ayny('',$backopt);
    return $ayn;
}

sub execute_split_mirror_operation {
    my ($prod,$split_mirror_syslist)=@_;
    my ($cfg,$edr,$stage,$steps,$mirrordgname,$status,$failmsg,$web,$msg);

    return if (Cfg::opt('makeresponsefile'));
    $cfg=Obj::cfg();
    $edr=Obj::edr();
    $web=Obj::web();
    $msg = Msg::new("Splitting mirrors");
    $web->web_script_form('showstatus',$msg->{msg}) if(Obj::webui());
    $steps=scalar(@$split_mirror_syslist);
    $edr->set_progress_steps($steps);
    $stage=Msg::new("Splitting mirrors");

    # run vxrootadm split on each system
    for my $sys (@$split_mirror_syslist) {
        $mirrordgname=$cfg->{mirrordgname}{$sys->{sys}} || '';
        if ($mirrordgname) {
            $sys->cmd("_cmd_rmr /tmp/vxrootadm_$sys->{sys} 2>/dev/null");
            $sys->cmd("_cmd_vxrootadm -Y split $mirrordgname > /tmp/vxrootadm_$sys->{sys} 2>&1 &");
        } else {
            $msg=Msg::new("No mirror disk group name for $sys->{sys}");
            $msg->die();
        }
    }

    #check for result file of split systems
    $failmsg='';
    for my $sys (@$split_mirror_syslist) {
        $msg=Msg::new("Splitting the boot disk group on $sys->{sys}");
        $stage->display_left($msg);
        # sleep for 1 minutes if it is the first sytem to check
        sleep 60 if ($sys->{sys} eq $$split_mirror_syslist[0]->{sys});
        while (1) {
            if ($sys->exists("/tmp/vxrootadm_$sys->{sys}")) {
                my $pids=$sys->proc_pids('/etc/vx/bin/vxrootadm -Y split');
                if ($#$pids>=0) {
                    sleep 30; # sleep 30 seconds to wait for vxrootadm finishes
                } else {
                    my $output=$sys->cmd("_cmd_cat /tmp/vxrootadm_$sys->{sys} 2>/dev/null");
                    if ($output=~/Split\s+boot\s+disk\s+successfully/mxi) {
                        $status=Msg::new("Done");
                    } else {
                        $failmsg.=$output;
                        $status=Msg::new("Failed");
                    }
                    $sys->cmd("_cmd_rmr /tmp/vxrootadm_$sys->{sys} 2>/dev/null");
                    last;
                }
            } else {
                $msg=Msg::new("No /tmp/vxrootadm_$sys->{sys} file on $sys->{sys}.");
                $msg->die();
            }
        }
        $stage->display_right($status);
    }
    if ($failmsg) {
        $msg=Msg::new("\n $failmsg.\n Refer to Veritas Volume Manager Administrator's Guide to split the mirrored encapsulated boot disk manually.");
        $msg->die();
    } else {
        $msg=Msg::new("\n The boot disk group has been successfully split to the target boot disk group.\n");
        $msg->print();
    }
    return;
}

#
# Function: upgrade_precheck_sys()
# Purpose:
#    The following needs to be checked:
#    + For upgrade, is the bootdisk encapsulated or are there any open
#      volumes
sub upgrade_precheck_sys {
    my ($prod,$sys)= @_;
    my ($pkg,$cprod);

    #fix e1518138 : uninstall AT pkgs when upgrade VM/VVR
    $cprod=CPIC::get('prod');
    if (EDRu::inarr($cprod,qw/VM60 DMP60/)) {
        $prod->obsoleted_bundles_sys($sys);
        $prod->obsoleted_bundled_pkgs_sys($sys);
    }
    $prod->obsoleted_thirdparty_pkgs_sys($sys);
    # check if dg has latest backup before upgrade
    $prod->dg_conf_upgrade_precheck_sys($sys) unless (Cfg::opt('upgrade_nonkernelpkgs'));
    if ($prod->is_encapsulated_bootdisk_sys($sys)){
        return '' unless ($prod->encap_upgrade_precheck_sys($sys));
        # set donotstop and donotremove flag here.
        $prod->set_flag_encap_upgrade_sys($sys);
    }
    $prod->open_volumes_sys($sys, 'upgrade') unless (Cfg::opt(qw(upgrade_kernelpkgs upgrade_nonkernelpkgs)));
    $prod->vvr_upgrade_precheck_sys($sys) if ($prod->vr_licensed_sys($sys));
    return;
}

sub patchupgrade_precheck_sys {
    my ($prod,$sys)= @_;

    if ($prod->is_encapsulated_bootdisk_sys($sys)) {
        return '' unless ($prod->encap_upgrade_precheck_sys($sys));
        # set donotstop and donotremove flag here.
        $prod->set_flag_encap_upgrade_sys($sys);
    }
    $prod->open_volumes_sys($sys, 'upgrade') unless (Cfg::opt(qw(upgrade_kernelpkgs upgrade_nonkernelpkgs)));
    return;
}

sub encap_upgrade_precheck_sys {
    my ($prod,$sys)=@_;
    my ($msg,$rel,$vxvm,$vers,$support_vers,$bootdg,$minor_num,$plex_num,$mode,$dg_blk,$dg_raw,$vol_raw,$vol_blk,$vol,$volumes,$minor,$major,$output);
    return 0 if (Cfg::opt('upgrade_nonkernelpkgs')); #For rolling upgrade phase2, doesn't check encapsulated bootdisk
    return 0 if (Cfg::opt('rootpath'));
    # Step 1. check for encapsulate bootdisk upgrade path support
    #$vxvm=$sys->pkg($prod->{mainpkg});
    $rel=$sys->rel();
    $vers=$prod->version_sys($sys);
    $support_vers = ($sys->linux()) ? '5.1' :
                    ($sys->sunos()) ? '4.1' : '0';
    if (EDRu::compvers($vers,$support_vers,2)==2) {
        $msg=Msg::new("Cannot proceed with the upgrade because the system $sys->{sys} may have an encapsulated bootdisk. Run $prod->{vxunroot} to unencapsulate the bootdisk.");
        $sys->push_error($msg);
        return 0;
    }

    # Step 2. check for vxconfigd running
    $mode=$sys->cmd('_cmd_vxdctl mode 2>/dev/null');
    if ($mode!~/mode: enabled/m) {
        $msg=Msg::new("vxconfigd must be running to proceed with encapsualted bootdisk upgrade");
        $sys->push_error($msg);
        return 0;
    }

    # Step 3. check for mirror state
    $plex_num=$sys->cmd("_cmd_vxprint -ptg bootdg | _cmd_grep 'pl .* rootvol' | _cmd_wc -l 2>/dev/null");
    if ($plex_num >1) {
        # vxrootadm integration is supported from 5.1SP1 onwards.
        # No vxrootadm support on HPUX. Supported platfroms: Solaris sparc/opteron and Linux
        # e2303520: solaris opteron, upgrade path is from 5.1SP1RP1 onwards to 6.0. Upgrade from 5.1SP1 is not supported.
        if (EDRu::compvers($vers,'5.1.100.0',4) < 2 && EDRu::compvers($vers,'5.1.101.0',4) == 2 && $sys->{arch}=~/i386/m ) {
            $msg=Msg::new("System $sys->{sys} has a boot disk that is mirrored and encapsulated. If you want to split the mirror during upgrade process, upgrade from current version $vers to 5.1SP1RP1 first. Then you can split the mirror during upgrade from 5.1SP1RP1 to $rel->{gavers}.");
            $sys->push_warning($msg);
        } elsif (EDRu::compvers($vers,'5.1.100.0',4) < 2 && !($sys->hpux())) {
            $sys->{mirror}=1;
            $sys->set_value('mirror', 1);
            $msg=Msg::new("System $sys->{sys} has a boot disk that is mirrored and encapsulated. It is highly recommended to split the mirrored disk group to get a backup copy of your OS environment.");
            $sys->push_note($msg);
        } else {
            $msg=Msg::new("System $sys->{sys} has a boot disk that is mirrored and encapsulated. If you do not want to upgrade the mirrored disk, refer to the Volume Manager admininstration guide on how to split the mirrored disk.");
            $sys->push_warning($msg);
            Msg::log("System $sys->{sys} has a boot disk that is mirrored and encapsulated. But the current version of vxrootadm is $vers which means it can not split the bootdg mirrors automatically during upgrade.");
        }
    }

    # Step 4. Sun specific check for reminor issue
    # refer to e1765860
    if ($sys->sunos()) {
        $bootdg=$sys->cmd('_cmd_vxdg bootdg 2>/dev/null');
        if (EDR::cmdexit()!=0) {
            $msg=Msg::new("Failed to find bootdg on system $sys->{sys}");
            $sys->push_error($msg);
            return 0;
        }
        $minor_num=$sys->cmd("_cmd_vxprint -g $bootdg -F%base_minor $bootdg 2>/dev/null");
        # reminor if base_minor number is greater than 33000
        if ($minor_num>=33000) {
            $dg_blk="/dev/vx/dsk/$bootdg";
            $dg_raw="/dev/vx/rdsk/$bootdg";
            $sys->cmd("_cmd_vxdg -f -g $bootdg reminor 1000 2>/dev/null");
            if (EDR::cmdexit()!=0) {
                $msg=Msg::new("Failed to reminor the bootdg on system $sys->{sys}");
                $sys->push_error($msg);
                return 0;
            }

            # get the device major number
            $output=$sys->cmd("_cmd_ls -l $dg_blk/rootvol 2>/dev/null");
            if ($output=~/\s+(\d+),/m) {
                $major=$1;
            } else {
                $msg=Msg::new("Failed to get the bootdg device major number on system $sys->{sys}");
                $sys->push_error($msg);
                return 0;
            }

            $volumes=$sys->cmd("_cmd_ls $dg_blk");
            for my $vol (split(/\s+/m,$volumes)) {
                next if ($vol eq 'rootvol');
                $vol_blk="$dg_blk/$vol";
                $vol_raw="$dg_raw/$vol";
                # get the new base minor number
                $minor=$sys->cmd("_cmd_vxprint -g $bootdg -F%minor -v $vol 2>/dev/null");
                if (EDR::cmdexit()==0) {
                    # modify bootdg [r]dsk links with the new minor
                    $sys->cmd("_cmd_rm -f $vol_blk 2>/dev/null");
                    $sys->cmd("_cmd_rm -f $vol_raw 2>/dev/null");
                    $sys->cmd("_cmd_mknod $vol_blk b $major $minor 2>/dev/null");
                    $sys->cmd("_cmd_mknod $vol_raw c $major $minor 2>/dev/null");
                } else {
                    $msg=Msg::new("Failed to get the bootdg device minor number on system $sys->{sys}");
                    $sys->push_error($msg);
                    return 0;
                }
            }
        }
    }

    return 1;
}

sub set_flag_encap_stop_sys {
    my ($prod,$sys)=@_;
    my $proc;
    $sys->{encap}=1;
    $sys->set_value('encap', 1);
    for my $proc (qw/vxdmp60 vxio60 vxspec60 vxconfigd60/) {
        push (@{$sys->{donotstopprocs}},$proc);
        $sys->set_value('donotstopprocs','push',$proc);
    }
    return;
}

sub set_flag_encap_upgrade_sys {
    my ($prod,$sys)=@_;
    my ($pkg,$proc);

    $sys->{encap}=1;
    $sys->set_value('encap', 1);
    for my $proc (qw/vxdmp60 vxio60 vxspec60 vxconfigd60/) {
        push (@{$sys->{donotstopprocs}},$proc);
        $sys->set_value('donotstopprocs','push',$proc);
    }
    # set flag to not remove VRTSvxvm pkg on Linux
    # prior to 5.1, VRTSvxvm-platform and VRTSvxvm-common can not be in-place upgraded.
    # both Linux and Solaris needs to set donotrmonupgrade flag
    $pkg=$sys->pkg('VRTSvxvm60');
    $pkg->set_value('donotrmonupgrade',1);

    # set reboot flag to reload drivers
    $sys->{reboot}=1;
    $sys->set_value('reboot', 1);
    return;
}

sub uninstall_precheck_sys {
    my ($prod,$sys)= @_;
    my $msg;
    $prod->obsoleted_thirdparty_pkgs_sys($sys);
    if ($prod->is_encapsulated_bootdisk_sys($sys)){
        if ($sys->hpux()){
            $msg=Msg::new("Cannot proceed with the uninstallation because the root disk of system $sys->{sys} is under Veritas Volume Manager control.");
        } else {
            $msg=Msg::new("Cannot proceed with the uninstallation because the system $sys->{sys} may have an encapsulated bootdisk. Run $prod->{vxunroot} to unencapsulate the bootdisk firstly.");
        }
        $sys->push_error($msg);
        return 0;
    }
    $prod->open_volumes_sys($sys, 'uninstall');
    return;
}

sub configure_dmp_sys {
    my ($prod,$sys) = @_;
    # DMP native support solutions, steps are:
    # 1. Suppressing value add for MPxIO, only on AIX and SunOS
    $prod->suppress_mpio_sys($sys);
    # 2. Automatically turn on DMP native support in case of an upgrade
    # or configure DMP stanalone, cross platform
    $prod->enable_dmp_osn_sys($sys);
    # 3. Check if vio server, only on AIX.
    $prod->check_vios_sys($sys);
    # 4. Disabling VxVM in VIOS environment, only start vxvm drivers, vxconfigd and vxesd.
    # This step is done in sub verify_procs_list_sys
    return 1;
}

sub enable_dmp_osn_sys {
    my ($prod,$sys) = @_;
    my ($cprod,$msg,$osn_enabled,$out,$voldmode);
    $cprod = CPIC::get('prod');
    $osn_enabled = 1 if $sys->exists($prod->{migrate_native_file});
    if (($cprod =~ /DMP/m) || $osn_enabled) {
        if (Cfg::opt(qw(upgrade patchupgrade))) {
            if (!$osn_enabled) {
                Msg::log("dmp_native_support is not enabled before upgrade, do not turn it on after upgrade");
                return 1;
            }
        }
        $voldmode = $prod->vold_status_sys($sys);
        if ($voldmode !~ /enabled/m) {
            # If vold is down, attempt to start it
            $sys->cmd('_cmd_vxconfigd -k -r reset -x syslog 2> /dev/null');
            $voldmode = $prod->vold_status_sys($sys);
            if ($voldmode !~ /enabled/m ) {
                $msg=Msg::new("vxconfigd could not be started on $sys->{sys}. You need to run 'vxdmpadm settune dmp_native_support=on' manually after restarting vxconfigd to enable dmp native support if it is not enabled yet.");
                $sys->push_warning($msg);
                return 0;
            }
        }
        $out = $sys->cmd('_cmd_vxdmpadm gettune dmp_native_support 2> /dev/null');
        if ($out =~ /dmp_native_support\s+on/mx) {
            Msg::log("Tunnable dmp_native_support is already turned on on $sys->{sys} ...");
            return 1;
        }
        Msg::log('Enabling OS native stack support ...');
        $out = $sys->cmd('_cmd_vxdmpadm settune dmp_native_support=on');
        if (EDR::cmdexit()) {
            if ($out =~ /\brootvg\b/m) {
                # error for AIX LVM
                $msg = Msg::new("Failed to enable root support on $sys->{sys}. Refer to Dynamic Multi-Pathing Administrator's guide to determine the reason for the failure and take corrective action. Re-run bosboot manually.");
            } else {
                # other error
                $msg = Msg::new("Failed to turn on dmp_native_support tunable on $sys->{sys}. Refer to Dynamic Multi-Pathing Administrator's guide to determine the reason for the failure and take corrective action.");
            }
            $msg->{msg} .= "\n$out";
            $sys->push_warning($msg);
        } elsif ($out =~ /\breboot\b/im) {
            $msg = Msg::new("System $sys->{sys} needs reboot to enable dmp native support on $sys->{sys}");
            $sys->push_note($msg);
            $sys->set_value('reboot', 1);
        } else {
            $msg = Msg::new("Tunable dmp_native_support is ENABLED on $sys->{sys}");
            $sys->push_note($msg);
        }
        $sys->cmd("_cmd_rmr $prod->{migrate_native_file}");
    }
    return 1;
}

sub check_vios_sys {
    return 0;
}

sub suppress_mpio_sys {
    return 0;
}

sub vol_is_vm_disabled_sys {
    return 0;
}

sub dmp_osn_stop_sys {
    my ($prod,$sys,$task) = @_;
    my ($msg,$out,$voldmode);

    return 0 if (Cfg::opt('rootpath'));
    return 0 if ($sys->exists("$prod->{mkdbfile}"));

    $voldmode = $prod->vold_status_sys($sys);
    if ($voldmode !~ /enabled/m) {
        # If vold is down, attempt to start it
        $sys->cmd('_cmd_vxconfigd -k -r reset -x syslog 2> /dev/null');
        $voldmode = $prod->vold_status_sys($sys);
        if ($voldmode !~ /enabled/m ) {
            if (Cfg::opt('upgrade')) {
                $msg=Msg::new("vxconfigd could not be started on $sys->{sys}. You must make sure the tunable dmp_native_support is turned off on $sys->{sys} before upgrade. It is likely that vxdmp driver will fail to stop during upgrade if the tunable is on. If OS upgrade is involved during the upgrade process, you can ignore this warning.");
            } else {
                $msg=Msg::new("vxconfigd could not be started on $sys->{sys}. You must affirm that dmp_native_support tunable is turned off or run 'vxdmpadm settune dmp_native_support=off' manually after restarting vxconfigd if you want to continue.");
            }
            $sys->push_warning($msg);
            return 0;
        }
    }

    $out = $sys->cmd('_cmd_vxdmpadm gettune dmp_native_support 2> /dev/null');
    if ($out =~ /dmp_native_support\s+on/mx) {
        Msg::log("Detected OS native stack support is enabled on $sys->{sys} before $task, turn it off...");
        $out = $sys->cmd('_cmd_vxdmpadm settune dmp_native_support=off');
        if (EDR::cmdexit()) {
            if ($out =~ /\brootvg\b/m) {
                # error for AIX LVM
                $msg = Msg::new("Failed to turn off dmp_native_support tunable on $sys->{sys}. Refer to Dynamic Multi-Pathing Administrator's guide to determine the reason for the failure and take corrective action. Re-run bosboot manually.");
            } else {
                # other error
                $msg = Msg::new("Failed to turn off dmp_native_support tunable on $sys->{sys}. Refer to Dynamic Multi-Pathing Administrator's guide to determine the reason for the failure and take corrective action.");
            }
            $msg->{msg} .= "\n$out";
            $sys->push_error($msg);
        } else {
            if ($out =~ /\breboot\b/im) {
                if ($task eq 'upgrade') {
                    $msg = Msg::new("System $sys->{sys} needs reboot to disable dmp native support on $sys->{sys}. Re-run the upgrade task after reboot.");
                } elsif ($task eq 'uninstall') {
                    $msg = Msg::new("System $sys->{sys} needs reboot to disable dmp native support on $sys->{sys}. Re-run the uninstall task after reboot.");
                } elsif ($task eq 'stop') {
                    $msg = Msg::new("System $sys->{sys} needs reboot to disable dmp native support on $sys->{sys}. Re-run the stop task after reboot.");
                } elsif ($task eq 'rollback') {
                    $msg = Msg::new("System $sys->{sys} needs reboot to disable dmp native support on $sys->{sys}. Re-run the rollback task after reboot.");
                }
                $sys->push_warning($msg);
                $sys->set_value('reboot', 1);
                $sys->set_value('warning_exit', 1);
            }
        }
        # touch /etc/vx/.migrate_native to turn on dmp native support later
        $sys->cmd("_cmd_touch $prod->{migrate_native_file}") if (Cfg::opt(qw(upgrade patchupgrade stop)));
    }
    return 1;
}

# Function: upgrade_postinstall_sys()
# Purpose:
# Input Parameters:
#    $sys
# Output Parameters:
#    Touches /etc/vx/.cpi_rootdg for upgrade scenarios from VM 3.5
sub upgrade_postinstall_sys {
    my ($prod,$sys)= @_;
    my ($cf,$filename,$old,$rootpath,$tmpdir);
    $tmpdir=EDR::tmpdir();
    $rootpath = Cfg::opt('rootpath');
    # install-db will not be there for an upgrade
    $sys->cmd("_cmd_touch $rootpath/etc/vx/.cpi_rootdg")
        if ($prod->set_rootdg_sys($sys));
    # restore the config files
    for my $cf (@{$prod->{configfiles}}) {
        $filename = EDRu::basename($cf);
        $old = "$tmpdir/VXVM-CFG-BAK/$filename";
        $cf = $rootpath.$cf if ($rootpath);
        next unless ($sys->exists("$old"));
        $sys->cmd("_cmd_cp -pf $old $cf");
    }
    $sys->cmd("_cmd_rmr $rootpath/$prod->{mkdbfile}")
        if ($sys->exists("$rootpath/$prod->{volbootfile}"));
    $sys->cmd("_cmd_rmr $tmpdir/VXVM-CFG-BAK");
    return;
}

sub upgrade_preremove_sys {
    my ($prod,$sys)=@_;
    my ($cf,$mkdir,$msg,$rootpath,$tmpdir);
    if ($prod->can('backup_vxvm_tunables_preremove_sys')) {
        $prod->backup_vxvm_tunables_preremove_sys($sys);
    }
    $tmpdir=EDR::tmpdir();
    $rootpath = Cfg::opt('rootpath');
    $mkdir=$sys->cmd("_cmd_mkdir -p $tmpdir/VXVM-CFG-BAK");
    if ( $mkdir || EDR::cmdexit() ) {
        $msg=Msg::new("Cannot create $tmpdir on $sys->{sys}");
        $sys->push_error($msg);
        return '';
    }
    # block non-root to access the log file
    $mkdir=$sys->cmd("_cmd_chmod 700 $tmpdir/VXVM-CFG-BAK");
    #save the config files to tmpdir
    for my $cf (@{$prod->{configfiles}}) {
        $cf = $rootpath.$cf if ($rootpath);
        next unless ($sys->exists($cf));
        $sys->cmd("_cmd_cp -pf $cf $tmpdir/VXVM-CFG-BAK/");
    }
    return;
}

sub upgrade_postremove_sys {
    my ($prod,$sys)=@_;
    if ($prod->can('backup_vxvm_tunables_postremove_sys')) {
        $prod->backup_vxvm_tunables_postremove_sys($sys);
    }
    return;
}

sub poststart_sys {
    my ($prod,$sys)=@_;
    # DMP related changes
    $prod->configure_dmp_sys($sys);
    # update vxvm.exclude file if reboot on upgrade
    $prod->update_exclude_file_sys($sys) if (Cfg::opt('start'));

    $sys->cmd('_cmd_vxrecover -sn > /dev/null 2>&1');
    $prod->vvr_upgrade_poststart_sys($sys) if (Cfg::opt('vvr'));
    return '';
}

sub upgrade_poststart_sys {
    my ($prod,$sys) = @_;
    my $syslist=CPIC::get('systems');

    # DMP related changes
    $prod->configure_dmp_sys($sys);
    # update vxvm.exclude file if upgrade
    $prod->update_exclude_file_sys($sys) if (Cfg::opt('upgrade'));

    $sys->cmd('_cmd_vxrecover -sn > /dev/null 2>&1');
    if (Cfg::opt('vvr')) {
        if ($sys->system1) {
            for my $sysi (@$syslist) {
                $prod->vvr_upgrade_poststart_sys($sysi);
            }
            EDRu::create_flag('vvr_upgrade_poststart_done');
        } else {
            EDRu::wait_for_flag('vvr_upgrade_poststart_done');
        }
    }
    return '';
}

sub upgrade_prestop_sys {
    my ($prod,$sys) = @_;
    my $syslist=CPIC::get('systems');
    # e2135884: roll back the change for dbms start script name.
    # $prod->tsub("disable_vrtsdbms3_sys",$sys);
    if ((Cfg::opt('vvr')) && !Cfg::opt('rootpath')) {
        if ($sys->system1) {
            for my $sysi (@$syslist) {
                $prod->vvr_upgrade_prestop_sys($sysi);
            }
            EDRu::create_flag('vvr_upgrade_prestop_done');
        } else {
            EDRu::wait_for_flag('vvr_upgrade_prestop_done');
        }
    }

    # check contents of /etc/vx/vxvm.exclude before upgrade if previous version <6.0
    $prod->check_exclude_file_sys($sys);

    if (Cfg::opt('rollback')) {
        # turn off dmp_native_support before rollback
        $prod->dmp_osn_stop_sys($sys,'rollback');
    } else {
        # turn off dmp native support before upgrade
        $prod->dmp_osn_stop_sys($sys,'upgrade');
    }

    return '';
}

sub get_vxvm_exclude_sys {
    my ($prod,$sys) = @_;
    my (@dmpnodes,@paths,$dmpnode,$exclude_file,$out,$path,$rootpath);
    $rootpath = Cfg::opt('rootpath');
    $exclude_file = "$rootpath$prod->{vxvm_exclude_file}";
    return (\@paths,\@dmpnodes) unless $sys->exists($exclude_file);
    $out = $sys->cmd("_cmd_cat $exclude_file");
    for my $line(split(/\n/,$out)) {
        next if ($line =~ /(#|exclude_all|paths|controllers|product|pathgroups)/m);
        ($path,undef,$dmpnode) = split(/\s+/,$line);
        ($dmpnode) ? push(@dmpnodes,$dmpnode) : push(@paths,$path);
    }
    @dmpnodes = @{EDRu::arruniq(@dmpnodes)};
    return (\@paths,\@dmpnodes);
}

sub check_exclude_file_sys {
    my ($prod,$sys) = @_;
    my ($cmpvers,$dmpnodes_aref,$paths_aref,$vers);
    $vers = $prod->version_sys($sys,1);
    $cmpvers = ($sys->hpux()) ? '5.1' : '6.0';
    return unless (EDRu::compvers($vers,$cmpvers,2) == 2);
    ($paths_aref,$dmpnodes_aref) = $prod->get_vxvm_exclude_sys($sys);
    $sys->set_value('obsolete_vxvm_exclude_file', 1) if (@{$paths_aref} || @{$dmpnodes_aref});
    return;
}

sub update_exclude_file_sys {
    my ($prod,$sys) = @_;
    my ($dmpnodes_aref,$paths_aref);
    if ($sys->exists($prod->{no_update_exclude_file})) {
        $sys->cmd("_cmd_rmr $prod->{no_update_exclude_file}");
        return;
    }
    ($paths_aref,$dmpnodes_aref) = $prod->get_vxvm_exclude_sys($sys);
    for my $path(@{$paths_aref}) {
        $sys->cmd("_cmd_vxdmpadm include path=$path > /dev/null");
        $sys->cmd("_cmd_vxdmpadm exclude path=$path > /dev/null");
    }
    for my $disk(@{$dmpnodes_aref}) {
        $sys->cmd("_cmd_vxdmpadm include dmpnodename=$disk > /dev/null");
        $sys->cmd("_cmd_vxdmpadm exclude dmpnodename=$disk > /dev/null");
    }
    $sys->cmd('_cmd_vxdisk scandisks');
    return;
}

sub disable_vrtsdbms3_sys {
    my ($prod,$sys) = @_;
    my ($file,$newfile,$rtn);
    my $rootpath = Cfg::opt('rootpath');
    $rtn = $sys->cmd("_cmd_ls $rootpath/$prod->{vxdbms3scripts}");
    return 1 if (EDR::cmdexit());
    for my $file (split(/\s+/m,$rtn)) {
        if ($file =~ /\/S\d+/m) {
            $newfile = $file;
            $newfile =~ s/\/S/\/NO_S/m;
            $sys->cmd("_cmd_mv $file $newfile 2>/dev/null");
        }
    }
    return 1;
}

sub preinstall_errors {
    my ($prod,$cpic) = @_;
    my ($msg,$sys,$ayn,$errmsg);
    for my $sys (@{$cpic->{systems}}) {
        for my $errmsg ((@{$sys->{errors}})) {
            Msg::print($errmsg);
            if ($errmsg=~/test/m) {
                $msg=Msg::new("Do you want to continue?");
                $ayn=$msg->aynn;
            }
        }
    }
    return '';
}

sub prestop_sys {
    my ($prod,$sys) = @_;
    if (Cfg::opt('uninstall')) {
        $sys->cmd("_cmd_rmr $prod->{migrate_native_file}") if ($sys->exists($prod->{migrate_native_file}));
        # turn off dmp_native_support before uninstall
        $prod->dmp_osn_stop_sys($sys,'uninstall');
    } elsif (Cfg::opt('stop')) {
        # turn off dmp_native_support before stop
        $prod->dmp_osn_stop_sys($sys,'stop');
    }
    return;
}

sub require_start_after_reboot_sys {
    my ($prod, $sys)=@_;
    $sys->set_value('require_start_after_reboot', 1)
        if ($sys->exists($prod->{mkdbfile}) || ($sys->{obsolete_vxvm_exclude_file}) ||
            $sys->exists($prod->{migrate_native_file}));
    return;
}

sub responsefile_comments {
    # Each response file comment is a 4 item list
    # item 1 is the comment, previously translated in the prior line
    # item 2 a 0=optional, 1=required
    # item 3 is 0=scalar, 1=list
    # item 4 is 0=1d, 1=2d is SYSTEM, other=other second dimension
    my ($prod,$cmt,$edr);
    $prod=shift;
    $edr=Obj::edr();
    $cmt=Msg::new("This variable indicates that the user should not be asked if there are any open volumes when vxconfigd is not enabled. Such prompts are asked during uninstallations. (1: affirms there are no open volumes on the system)");
    $edr->{rfc}{vm_no_open_vols}=[$cmt->{msg},0,0,0];
    return;
}

#
# Function: set_rootdg_sys()
# Purpose:
#     Determines if we need to set the default DG to rootdg if
#     we're upgrading from a pre 4.0 VRTSvxvm.
# Input Parameters:
#     $sys
# Output Parameters:
#     1: true
#     0: false
# Called by:
#     pre_postinstall_sys()
sub set_rootdg_sys {
    my ($prod,$sys) = @_;
    my ($vers,$junk,$pkg,$ivers);

    $pkg=$sys->pkg($prod->{mainpkg});
    $ivers=$pkg->version_sys($sys);
    ($vers, $junk) = split(/\./m, $ivers);
    return 0 if ( $vers >= 4 );
    return 1;
}

sub startprocs_sys {
    my ($prod,$sys)=@_;
    my ($ref_procs);
    $ref_procs = Prod::startprocs_sys($prod, $sys);
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'start');
    return $ref_procs;
}

sub stopprocs {
    my $prod=shift;
    my $ref_procs;
    $ref_procs = Prod::stopprocs($prod);
    $ref_procs = $prod->verify_procs_list($ref_procs,'stop');
    return $ref_procs;
}

sub verify_procs_list {
    my ($prod,$procs,$state)=@_;
    if ((defined $state && $state eq 'stop') && (EDRu::inarr('vxsvc34', @{$procs}))) {
        $procs=EDRu::arrdel($procs, 'vxsvc34');
        unshift(@{$procs}, 'vxsvc34');
    }
    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure'))) {
        $procs = $prod->remove_procs_for_prod($procs);
    }
    return $procs;
}

sub stopprocs_sys {
    my ($prod,$sys)=@_;
    my ($ref_procs);
    $ref_procs = Prod::stopprocs_sys($prod, $sys);
    $ref_procs = $prod->verify_procs_list_sys($sys,$ref_procs,'stop');
    return $ref_procs;
}

sub verify_procs_list_sys {
    my ($prod,$sys,$procs,$state)=@_;
    my ($cpic,$rel);

    $cpic = Obj::cpic();
    $rel = $cpic->rel;

    # disabling VxVM in VIOS environment
    # only vxvm drivers and vxconfigd and vxesd should be started
    if ((defined $state && $state eq 'start') && $prod->vol_is_vm_disabled_sys($sys)) {
        $procs = EDRu::arrdel($procs, qw(vxrelocd60 vxcached60 vxconfigbackupd60 vxattachd60
                                        vvr60));
        return $procs;
    }

    $procs = EDRu::arrdel($procs, 'vvr60') unless ($prod->vr_licensed_sys($sys));
    if ((defined $state && $state eq 'start') && (!$rel->feature_licensed_sys($sys, 'VxVM'))) {
        $procs = EDRu::arrdel($procs, qw(vxrelocd60 vxconfigbackupd60));
    }
    unless ($rel->feature_licensed_sys($sys, 'FASTRESYNC') ||
            $rel->feature_licensed_sys($sys, 'FMR_DGSJ')) {
        $procs = EDRu::arrdel($procs, 'vxcached60');
        $procs = EDRu::arrdel($procs, 'vxattachd60');
    }
    # adjust vxsvc process
    $procs = $prod->adjust_vxsvc_for_procs_sys($sys,$procs,$state);
    # adjust sfmh-discovery process
    $procs = $prod->adjust_sfmh_for_procs_sys($sys,$procs,$state);

    if ((defined $state && $state eq 'stop') && (Cfg::opt('configure'))) {
        $procs = $prod->remove_procs_for_prod($procs);
    }

    return $procs;
}

sub adjust_vxsvc_for_procs_sys {
    my ($prod,$sys,$procs,$state)=@_;
    if (EDRu::inarr('vxsvc34', @{$procs})) {
        if (defined $state && $state eq 'stop') {
            # Stop logic:
            # - For upgrade 5.1 -> 5.1SP1 or 5.1SP1 up-sell, stop vxsvc;
            # - For upgrade 5.0MP3/5.0/All earlier versions -> 5.1SP1, stop for both vxsvc
            # and all vxpal instances;
            $procs=EDRu::arrdel($procs, 'vxsvc34');
            unshift(@{$procs}, 'vxsvc34');
        } elsif (defined $state && $state eq 'start') {
            # Start Logic:
            # - For upgrade 5.1 -> 5.1SP1 or 5.1SP1 up-sell, starts only when stopped before;
            # - For upgrade 5.0MP3/5.0/All earlier versions -> 5.1SP1, no start.
            my $vxsvc = $prod->proc('vxsvc34');
            $procs=EDRu::arrdel($procs, 'vxsvc34') unless ($vxsvc->{running}{$sys->{sys}} &&
                                                  (EDRu::compvers(${$sys->{prodvers}}[0],'5.1')<2));
        }
    }
    return $procs;
}

sub adjust_sfmh_for_procs_sys {
    my ($prod,$sys,$procs,$state)=@_;
    if (EDRu::inarr('sfmhdiscovery60', @{$procs})) {
        if (defined $state && $state eq 'start') {
            my $sfmhdiscovery = $prod->proc('sfmhdiscovery60');
            my $mhpkg = $prod->pkg('VRTSsfmh41');
            # 5.1SP1RP2 bits start sfmh-discovery.pl even managed host is not reporting to any domain 
            # 2724480: start sfmh-discovery.pl only if sfmh-discovery.pl was started
            # and managed host was reporting to a domain
            $procs=EDRu::arrdel($procs, 'sfmhdiscovery60') unless ($sfmhdiscovery->{running}{$sys->{sys}} &&
            ($mhpkg->check_if_managedhost_connected_to_central_server_sys($sys)));
        }
    }
    return $procs;
}

#
# Function: upgrading_vm_sys()
# Purpose:
#     Determines if VM is being upgraded to determine if reconfiguration
#    and startup should be permitted.  They won't be permitted if the
#    currently installed and the media packages are different and if
#    the install-db file is missing.
#
# Input Parameters:
#    $sys
# Output Parameters:
#    0 or 1
# Called by:
#    various functions
sub upgrading_vm_sys {
    my ($prod,$sys) = @_;
    my $plat=$sys->{plat};
    my $pkg=$sys->pkg($prod->{mainpkg});
    my $ivers=$pkg->version_sys($sys);

    return 0 if  Cfg::opt('configure');
    return 0 if  Cfg::opt('uninstall');
    return 0 if (! $ivers);

    # is upgrading if pkg media version > installed version
    if (2 == EDRu::compvers($ivers, $pkg->{vers})) {
        if (! $sys->exists($prod->{mkdbfile})) {
            return 1;
        }
    }
    return 0;
}

sub vold_status_sys {
    my ($prod,$sys) = @_;
    my ($mode);

    $mode = $sys->cmd('_cmd_vxdctl mode 2>/dev/null');
    chomp($mode);
    $mode =~ s/mode: //m;
    return $mode;
}

sub vxddladm_addsupport_sys {
    # aix need special steps here, other plat just return 1
    return 1;
}

sub vom_ports_status_sys {
    my ($prod,$sys) = @_;
    my ($msg,$ports,@ports_occupied,@ports);

    @ports=qw(14161 5634);

    for my $port (@ports) {
        if (EDRu::is_port_connectable($sys->{sys}, $port)) {
            push (@ports_occupied,$port);
        }
    }
    if (scalar(@ports_occupied) == scalar(@ports)) {
        # If the predefined ports are all not available, then show warning;
        $ports=join(' ', @ports_occupied);
        $msg=Msg::new("The ports $ports are not available on $sys->{sys}, it may impact the configuration for VOM server.");
        $sys->push_warning($msg);
    }
    return;
}

sub completion_messages {
    my ($prod,$msg,$padv,$sys,$tmppath,$rootpath,$web);
    $prod=shift;

    $padv=$prod->padv();
    $tmppath=EDR::get('tmppath');
    $rootpath = Cfg::opt('rootpath');
    $web=Obj::web();
    if (Cfg::opt(qw/upgrade patchupgrade install configure/) && !Cfg::opt(qw/upgrade_kernelpkgs/)) {
        $msg=Msg::new("The updates to VRTSaslapm package are released via the Symantec SORT web page: https://sort.symantec.com/asl. To make sure you have the latest version of VRTSaslapm (for up to date ASLs and APMs), download and install the latest package from the SORT web page.");
        $msg->printn();
        $web->web_script_form('alert',$msg) if (Obj::webui());
    }
    if (Cfg::opt('rootpath')) {
        for my $sys (@{CPIC::get('systems')}) {
            if ($sys->{rvg}) {
                $msg = Msg::new("\nInstaller has detected that VVR is configured on the systems. Follow the steps below to upgrade VVR:");
                $msg->print;
                $msg = Msg::new("    Step 1 - Execute vxlufinish on all the systems");
                $msg->print;
                $msg = Msg::new("    Step 2 - Execute vvr_upgrade_lu_start on all nodes. If it is a CVM-VVR environment, execute this script from the CVM master node");
                $msg->print;
                $msg = Msg::new("    Step 3 - Execute '$padv->{cmd}{shutdown}' to properly restart your systems");
                $msg->print;
                $msg = Msg::new("    Step 4 - Execute vvr_upgrade_lu_finish on all nodes. If it is a CVM-VVR environment, execute this script from the CVM master node\n");
                $msg->print;
                last;
            }
        }
    }
    return '' unless (Cfg::opt('upgrade') && CPIC::get('reboot'));

    for my $sys (@{CPIC::get('systems')}) {
        if ($sys->{rvg}) {
            $msg=Msg::new("WARNING: Run install script with start option after the machine boots up to finish the upgrade processing.\nDo not delete $tmppath/vvr_upgrade* directories which contain the scripts to do the post upgrade processing.\n");
            $msg->bold;
            last;
        } elsif ($sys->{obsolete_vxvm_exclude_file}) {
            my $exclude_file = "$rootpath$prod->{vxvm_exclude_file}";
            $msg=Msg::new("The content of the file $exclude_file is not updated. Run the install script with start option after the machine boots up to finish the upgrade process\n");
            $msg->bold;
            last;
        } elsif ($sys->exists($prod->{migrate_native_file})) {
            $msg=Msg::new("The dmp_native_support tunable is not enabled. Run the install script with start option after the machine boots up to enable it.\n");
            $msg->bold;
            last;
        }
    }

    return '';
}


#############Add VVR function here###############
sub vvr_upgrade_precheck_sys {
    my ($prod,$sys)= @_;
    my ($dg,@dgs,$msg,$rvg,$shared,$voldmode,$vvr);
    # check vxdctl mode
    # Follow upgrade procedure if VRTSvxvm is being upgraded
    # But just check whether the sys is being upgraded.
    return if ($sys->exists("$prod->{mkdbfile}"));
    $voldmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    if ($voldmode !~ /mode: enabled/m ) {
        # If vold is down, atempt to start it
        $sys->cmd('_cmd_vxconfigd -k -r reset -x syslog 2> /dev/null');
        $voldmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
        if ($voldmode !~ /mode: enabled/m ) {
            $msg=Msg::new("vxconfigd could not be started. Upgrading VRTSvxvm in this scenario can result in configuration errors, or data loss for Veritas Volume Manager objects. Continue if you are sure that there are no Veritas Volume Manager objects on the host.");
            $sys->push_warning($msg);
            return '';
        }
    }

    # check dg version
    # Iterate twice
    $dg=$sys->cmd("_cmd_vxdg -q list 2>/dev/null | _cmd_awk '{ print \$1 }'");
    @dgs=split(/\s+/m,$dg);
    for my $dg (@dgs) {
        $rvg = $sys->cmd("_cmd_vxprint -g $dg -qQVF%name 2>/dev/null");
        if ($rvg) {
            $vvr = 1;
            $sys->set_value('rvg','1');
            last;
        }
    }
    return unless ($vvr);
    for my $dg (@dgs) {
        $shared = $sys->cmd("_cmd_vxdg list $dg 2> /dev/null | _cmd_grep 'flags:' | _cmd_grep shared");
        next if ($shared);
        $prod->vvr_check_dg_version_sys($sys, $dg);
    }
    return;
}

sub vvr_upgrade_prestop_sys {
    my ($prod,$sys) = @_;
    my ($voldmode);

    return if ($sys->exists("$prod->{mkdbfile}") );
    $voldmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    if ($voldmode =~ /mode: enabled/m ) {
        $prod->vvr_upgrade_start_sys($sys);
    }
    return 1;
}

sub vvr_upgrade_start_sys {
    my ($prod,$sys) = @_;
    my (@vols,$dir_slave,$rlink,$msg,@files,$sys0,$uuid,$file,$tmppath,@rvgs,@rlinks,$vxdctl_mode,$shared,$private,@dgs,$rvols,$dir,$rlk_behind,$vvr,$vol,$ret,$dir_master,$status,$rvg,$dg,$master);

    $sys0 = $sys->{sys};
    $vvr = 0;
    return unless ($sys->{rvg});

    $dg=$sys->cmd("_cmd_vxdg -q list 2>/dev/null| _cmd_awk '{ print \$1 }'");
    @dgs=split(/\s+/m,$dg);

    $vxdctl_mode = $sys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'mode:'");

    #non-clustered node is master apart from master froma cluster
    $master = 1;
    $master = 0 if ($vxdctl_mode=~/SLAVE/m);
    $master = 2 if ($vxdctl_mode=~/MASTER/m);
    $tmppath=EDR::get('tmppath');
    $uuid=EDR::get('uuid');
    $dir = "$tmppath/vvr_upgrade_$sys0-$uuid";
    EDR::cmd_local("_cmd_mkdir -p $dir");
    if (EDR::cmdexit() != 0) {
       $msg = Msg::new("Upgrade directory, $dir, could not be created. Fix the problem and rerun the installation.\n");
       $msg->die;
    }

    # If cluster_master is already set, the objects have been changed by master
    # hence slave need to copy the logs and return
    # If slave comes here before master, tehy will build the log since
    # slaves donot change the object state
    if ($prod->{cluster_master}) {
        # copy the log and return
        $prod->{cluster_slave} = $sys0;
        $dir_slave = "$tmppath/vvr_upgrade_$sys0-$uuid";
        $dir_master= "$tmppath/vvr_upgrade_$prod->{cluster_master}-$uuid";
        EDR::cmd_local("_cmd_cp -r $dir_master/shared* $dir_slave");
        #return;
    }

    $prod->{cluster_master} = $sys0 if ($vxdctl_mode=~/MASTER/m);

    $prod->vvr_set_ug_paths_sys($sys, "$dir");

    @files=($prod->{location}{startrvg_file},
            $prod->{location}{attrlink_file},
            $prod->{location}{restoresrl_file},
            $prod->{location}{adddcm_file},
            $prod->{location}{srlprot_file},
            $prod->{location}{errlog_file},
           );
    push (@files, $prod->{location}{shared_startrvg_file},
                  $prod->{location}{shared_attrlink_file},
                  $prod->{location}{shared_restoresrl_file},
                  $prod->{location}{shared_adddcm_file},
                  $prod->{location}{shared_srlprot_file})
        unless ($master eq '1');
    for my $file (@files) {
        EDR::cmd_local("echo '#Do not delete or change this file because this file will be used while restoring the original configuration.' >> $file");
        EDR::cmd_local("echo '. \$\{VOLADM_LIB:-\/usr\/lib\/vxvm\/voladm.d\/lib}\/vxadm_lib.sh' >> $file");
    }

    $private = 0;

    for my $dg (@dgs) {
        #loop through all rvg's in the disk group
        $shared = $sys->cmd("_cmd_vxdg list $dg 2> /dev/null | _cmd_grep 'flags:' | _cmd_grep shared");
        next if ($shared && ($master eq '0') && $prod->{cluster_master});
        $rvg = $sys->cmd("_cmd_vxprint -g $dg -qQVF%name");
        @rvgs = split(/\s+/m,$rvg);
        for my $rvg (@rvgs) {
            $vol=$sys->cmd("_cmd_vxprint -g $dg -qQVF%datavols $rvg | _cmd_tr ',' ' '");
            @vols=split(/\s+/m,$vol);
            # stop the rvg
            $prod->vvr_stop_rvg_sys($sys, $dg, $rvg, $master, $shared);
            $rlink=$sys->cmd("_cmd_vxprint -g $dg -qQVF%rlinks $rvg | _cmd_tr ',' ' '");
            @rlinks=split(/\s+/m,$rlink);
            if (!(("$rlinks[0]" eq '-') && ($#rlinks == 0)))  {
                $status=0;
                #make sure all the rlinks are up-to-date before proceeding with the upgrade
                $rlk_behind='';
                for my $rlink (@rlinks) {
                    $ret = $prod->vvr_check_uptodate_rlink_sys($sys,$dg,$rvg,$rlink);
                    if ($ret == 1) {
                        $status = 1;
                        $rlk_behind.=" $rlink";
                    }
                }
                if ($status == 1 ) {
                    Msg::n();
                    $msg = Msg::new("The following rlinks are not up-to-date:\n$rlk_behind\n");
                    $msg->print;
                    $ret = "Cannot proceed with the upgrade until all the rlinks are up-to-date. Use:\n\tvxrlink -g dg status rlk_name\ncommand to make sure all the rlinks are up-to-date and then upgrade the systems.\n";
                    $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vxrlink -g $dg status $rlk_behind", $ret);
                }

                #loop through all the attached rlinks of the rvg to detach
                for my $rlink (@rlinks) {
                    $prod->vvr_detach_rlink_sys($sys, $dg, $rvg, $rlink, $master, $shared);
                }
            }

            #dis the SRL from the rvg
            $prod->vvr_dis_srl_sys($sys, $dg, $rvg, $master, $shared);
            #set srlport=override for all rlinks with srlprot=dcm
            if (!(("$rlinks[0]" eq '-') && ($#rlinks == 0)))  {
                for my $rlink (@rlinks) {
                    $prod->vvr_set_srlprot_sys($sys, $dg, $rlink, $master, $shared);
                }
            }
            #remove DCM's from all the stripe-mirror volumes
            if (!(("$vols[0]" eq '-') && ($#vols == 0)))  {
                $prod->vvr_remove_dcm_sys($sys,$dg, $master, $shared, @vols);
            }
            $rvols.=$rvg;
        }
    }

    if ($sys->exists("$prod->{location}{basedir}/etc/vx/vras/vras_env")) {
        $file='vras_env';
        $dir="$prod->{location}{basedir}/etc/vx/vras";
    } else {
        $file='vras-vradmind.sh vxrsyncd.sh';
        $dir="$prod->{location}{basedir}/etc/init.d";
    }

    @files=split(/\s+/m,$file);
    for my $file (@files) {
        if ($sys->exists("$dir/$file")) {
            $sys->copy_to_sys($prod->localsys,"$dir/$file","$prod->{location}{savedir}/$file");
        }
    }

    # Save the config file required for vrw
    if ($sys->exists("$prod->{location}{vrw_orig_conf}")) {
        $sys->copy_to_sys($prod->localsys,"$prod->{location}{vrw_orig_conf}","$prod->{location}{vrw_saved_conf}");
    }

    unless (Cfg::opt('responsefile')) {
        $msg = Msg::new("WARNING: VVR upgrade directory for $sys->{sys} is created at $prod->{location}{savedir}. It is strongly recommended to take backup of this directory.");
        $sys->push_warning($msg);
    }
    my $tmpdir = EDR::tmpdir();
    EDR::cmd_local("_cmd_mkdir -p $tmpdir/vvr_upgrade");
    EDR::cmd_local("_cmd_cp -r $prod->{location}{savedir} $tmpdir/vvr_upgrade");
    $sys->cmd('_cmd_mkdir -p /opt/VRTS/install');
    $sys->cmd("_cmd_touch /opt/VRTS/install/vvrug_$sys->{sys}");
    $prod->{vvr_upgrade_finished}=1;
    return;
}

sub vvr_check_dg_version_sys {
    my ($prod,$sys,$dg) = @_;
    my ($cprod,$msg,$dg_version);
    $cprod=CPIC::get('prod');
    $cprod=~s/\d+$//m;
    $dg_version=$sys->cmd("_cmd_vxprint -l $dg | _cmd_grep '^version' | _cmd_awk '{ print \$2;}'");
    if ($dg_version < 70) {
        $msg = Msg::new("Disk Group, $dg, is not at disk group version 70 or later. Make sure all the disk groups are at a version of 70 or above, and then upgrade the systems.");
        $sys->push_error($msg);
        return 0;
    } elsif ($dg_version < 110) {
        $msg = Msg::new("It is recommended to upgrade to disk group version 110 prior to upgrading $cprod for effective operation of VVR");
        $msg->log;
        $sys->push_warning($msg);
        return 0;
    }
}

sub vvr_check_uptodate_rlink_sys {
    my ($prod,$sys,$dg,$rvg,$rlink) = @_;
    my ($string,$tmp,$ret,$attached);

    $attached=$sys->cmd("_cmd_vxprint -g $dg -l $rlink | _cmd_grep '^flags' | _cmd_grep 'attached'");
    # for an attached primary RLINK make sure all the RLINKs are up-to-date
    if ($attached) {
        $string=$sys->cmd("_cmd_vxprint -g $dg -l $rvg | _cmd_grep '^flags' | _cmd_awk '{print \$3}'");
        if ($string eq 'primary') {
            $ret = $sys->cmd("_cmd_vxrlink -g $dg status $rlink ");
            $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vxrlink -g $dg status $rlink", $ret) if (EDR::cmdexit() != 0);
            $string="Rlink $rlink is up to date";
            $tmp = $sys->cmd("_cmd_vxrlink -g $dg status $rlink |  _cmd_grep '$string'");
            return 1 if (!($tmp));
        }
    }
    return 0;
}

sub vvr_detach_rlink_sys {
    my ($prod,$sys,$dg,$rvg,$rlink,$master,$shared) = @_;
    my ($vxrlink_det,$padv,$secondary_detached,$primary_paused,$rvg_role,$ret,$attrlink_file,$sec_host,$primary_detached,$stoprep,$attached);

    $padv = $sys->padv;
    my $attrlink_file_name = ($shared)? $prod->{location}{shared_attrlink_file} :
                                        $prod->{location}{attrlink_file};
    $attrlink_file = "$padv->{cmd}{vxrlink} -g $dg recover $rlink 2> $prod->{location}{rerr_file}\n";
    $attrlink_file .= "if \[ \$? -ne 0 \]; then\n";
    $attrlink_file .= "ewritemsg -M vxvmshm:1745 \"The command $padv->{cmd}{vxrlink} -g $dg recover $rlink failed with the following error:\"\n";
    $attrlink_file .= "$padv->{cmd}{cat} $prod->{location}{rerr_file}\n";
    $attrlink_file .= "fi\n";
    EDRu::appendfile($attrlink_file, $attrlink_file_name);

    $attached=$sys->cmd("_cmd_vxprint -g $dg -l $rlink | _cmd_grep '^flags' | _cmd_grep attached");
    if ($attached) {
        $rvg_role =$sys->cmd("_cmd_vxprint -g $dg -l $rvg | _cmd_grep '^flags' | _cmd_awk '{print \$3}'");
        if ($rvg_role eq 'primary') {
            $sec_host=$sys->cmd("_cmd_vxprint -g $dg -qQPF%remote_host $rlink");
        } else {
            $sec_host=$sys->cmd("_cmd_vxprint -g $dg -qQPF%local_host $rlink");
        }

        if (!$shared || ($master && $shared)) {
            $primary_paused = $prod->vvr_find_state($sys, $dg, $rvg, $sec_host, 'primary paused');
            $primary_detached = $prod->vvr_find_state($sys, $dg, $rvg, $sec_host, 'primary detached');
            $secondary_detached = $prod->vvr_find_state($sys, $dg, $rvg, $sec_host, 'secondary detached');

            if ($rvg_role eq 'secondary') {
                if ($primary_paused || $primary_detached) {
                    $ret = $sys->cmd("_cmd_vxrlink -g $dg -f det $rlink");
                    $vxrlink_det = 1;
                } else {
                    $ret = $sys->cmd("_cmd_vradmin -g $dg -s stoprep $rvg $sec_host");
                    $stoprep = 1;
                }
            } else {
                if ($secondary_detached) {
                    $ret = $sys->cmd("_cmd_vxrlink -g $dg -f det $rlink");
                    $vxrlink_det = 1;
                } else {
                    $ret = $sys->cmd("_cmd_vradmin -g $dg -s stoprep $rvg $sec_host");
                    $stoprep = 1;
                }
            }

            $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vradmin -g $dg -s stoprep $rvg $sec_host", $ret) if (EDR::cmdexit() != 0);
        }

        # Incase vradmind was started on primary before starting it
        # on the secondary hosts, the vradmind handshake may not have
        # completed. If the vradmin startrep command fails, wait for
        # 30 seconds and retry command before returning error.
        $attrlink_file = '';
        if ($stoprep == 1) {
            $attrlink_file .= "$padv->{cmd}{vradmin} -g $dg -f startrep $rvg $sec_host 2> $prod->{location}{rerr_file}\n";
        } elsif ($vxrlink_det == 1) {
            $attrlink_file .= "$padv->{cmd}{vxrlink} -g $dg -f att $rlink 2> $prod->{location}{rerr_file}\n";
        }
        $attrlink_file .= "if \[ \$? -ne 0 \]; then\n";
        $attrlink_file .= "sleep 30\n";
        if ($stoprep == 1) {
            $attrlink_file .= "$padv->{cmd}{vradmin} -g $dg -f startrep $rvg $sec_host 2> $prod->{location}{rerr_file}\n";
        } elsif ($vxrlink_det == 1) {
            $attrlink_file .= "$padv->{cmd}{vxrlink} -g $dg -f att $rlink 2> $prod->{location}{rerr_file}\n";
        }
        $attrlink_file .= "if \[ \$? -ne 0 \]; then\n";
        $attrlink_file .=  "ewritemsg -M vxvmshm:1743 \"The command $padv->{cmd}{vradmin} -g $dg -f startrep $rvg $sec_host failed with the following error:\"\n";
        $attrlink_file .= "$padv->{cmd}{cat} $prod->{location}{rerr_file}\n";
        $attrlink_file .= "fi\n";
        $attrlink_file .= "fi\n";
        EDRu::appendfile($attrlink_file,$attrlink_file_name);
    }
    return;
}

sub vvr_dis_srl_sys {
    my ($prod,$sys,$dg,$rvg,$master,$shared) = @_;
    my ($srl,$srl_length,$padv,$ret,$restoresrl_file);

    $padv = $sys->padv;
    $srl=$sys->cmd("_cmd_vxprint -g $dg -qQVF%srl $rvg | _cmd_tr ',' ' '");
    if ("$srl" ne  '-') {
        # confirm that the SRL is atleast 110MB
        $srl_length=$sys->cmd("_cmd_vxprint -g $dg -F%len $srl");
        if ((($sys->hpux()) &&  ($srl_length < ($prod->{min_srl_length}/2))) ||
            ((!$sys->hpux()) &&  ($srl_length < $prod->{min_srl_length}))) {
            $ret = "The length of SRL $srl is $srl_length blocks.\nSRL length must be atleast $prod->{min_srl_length} blocks.";
            $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, '', $ret);
        }
        if (!$shared || ($master && $shared)) {
            $ret = $sys->cmd("_cmd_vxvol -g $dg dis $srl ");
            if (EDR::cmdexit() != 0) {
                $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vxvol -g $dg dis $srl", $ret);
            }
        }
    }
    $sys->cmd("_cmd_dd  of=/dev/null if=/dev/vx/rdsk/$dg/$srl bs=256k count=1 >/dev/null 2>&1");
    $restoresrl_file = "$padv->{cmd}{vxvol} -g $dg aslog $rvg $srl 2> $prod->{location}{rerr_file}\n";
    $restoresrl_file .= " if \[ \$? -ne 0 \]; then\n";
    $restoresrl_file .= "ewritemsg -M vxvmshm:1749 \"The command $padv->{cmd}{vxvol} -g $dg aslog $rvg $srl failed with the following error:\"\n";
    $restoresrl_file .= "$padv->{cmd}{cat} $prod->{location}{rerr_file}\n";
    $restoresrl_file .= "fi\n";
    my $restoresrl_file_name = ($shared)? $prod->{location}{shared_restoresrl_file} :
                                          $prod->{location}{restoresrl_file};
    EDRu::appendfile($restoresrl_file,$restoresrl_file_name);
    return;
}

sub vvr_find_state {
    my ($prod,$sys,$dg,$rvg,$sec_host,$state) = @_;
    my ($found_host,$tmp_string,$tmp,$line,$expected_state,@lines);

    $tmp = $sys->cmd("_cmd_vradmin -g $dg repstatus $rvg");
    @lines = split(/\n/,$tmp);
    $found_host = 0;
    $expected_state = 0;

    for my $line (@lines) {
        if (!$found_host) {
            next if (!($line =~ /Host name/m));
            $tmp_string=EDR::cmd_local("echo $line | _cmd_grep -w $sec_host");
            next if (!$tmp_string);
            $found_host = 1;
            next;
        }
        last if (($line =~ /Host name/m));
        next if (!($line =~ /Replication status:/m));
        if ($line =~ /$state/m) {
            $expected_state = 1;
            last;
        }
    }
    return $expected_state;
}

sub vvr_remove_dcm_sys {
    my ($prod,$sys,$dg,$master,$shared,@vols) = @_;
    my (@strmirvols,$adddcm_file,$subvol,$padv,$dcm_log,$vol,$ret);

    $padv = $sys->padv;
    for my $vol (@vols) {
        $subvol=$sys->cmd("_cmd_vxprint -vh $vol | _cmd_awk '{ print \$1 }' | _cmd_grep '^sv\$'");
        push(@strmirvols,$vol) if ($subvol);
    }

    if (@strmirvols) {
        for my $vol (@strmirvols) {
            $dcm_log=$sys->cmd("_cmd_vxprint -r $vol | _cmd_awk '{ print \$6 }' | _cmd_grep '^LOG\$'");
            if ($dcm_log) {
                if (!$shared || ($master && $shared)) {
                    $ret = $sys->cmd("_cmd_vxassist -g $dg remove log $vol nlog=0 ");
                    if (EDR::cmdexit() != 0) {
                        $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vxassist -g $dg remove log $vol nlog=0 ", $ret);
                    }
                }

                $adddcm_file = " $padv->{cmd}{vxassist} -g $dg addlog $vol logtype=dcm 2> $prod->{location}{rerr_file}\n";
                $adddcm_file .= "if \[ \$? -ne 0 \]; then\n";
                $adddcm_file .= "The command $padv->{cmd}{vxassist} -g $dg addlog $vol logtype=dcm failed with the following error:\n";
                $adddcm_file .="$padv->{cmd}{cat} $prod->{location}{rerr_file}\n";
                $adddcm_file .= "fi\n";
                my $adddcm_file_name = ($shared)? $prod->{location}{shared_adddcm_file} :
                                                  $prod->{location}{adddcm_file};
                EDRu::appendfile($adddcm_file,$adddcm_file_name);
            }
        }
    }
    return;
}

sub vvr_set_srlprot_sys {
    my ($prod, $sys, $dg, $rlink, $master, $shared) = @_;
    my ($ret,$srlprot,$padv,$srlprot_file);

    $padv = $sys->padv;
    $srlprot=$sys->cmd("_cmd_vxprint -g $dg -qQPF%srlprot $rlink");
    if ($srlprot eq  'dcm') {
        if (!$shared || ($master && $shared)) {
            $ret = $sys->cmd("_cmd_vxedit -g $dg set srlprot=override $rlink");
            if (EDR::cmdexit() != 0) {
                $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vxedit -g $dg set  srlprot=override $rlink ", $ret);
            }
        }
        $srlprot_file = "$padv->{cmd}{vxedit} -g $dg set srlprot=dcm $rlink 2> $prod->{location}{rerr_file}\n";
        $srlprot_file .= "if \[ \$? -ne 0 \]; then\n";
        $srlprot_file .=  "ewritemsg -M vxvmshm:1741 \"The command $padv->{cmd}{vxedit} -g $dg set srlprot=dcm $rlink failed with the following error:\"\n";
        $srlprot_file .= "$padv->{cmd}{cat} $prod->{location}{rerr_file}\n";
        $srlprot_file .= "fi\n";
        my $srlprot_file_name = ($shared)? $prod->{location}{shared_srlprot_file} :
                                           $prod->{location}{srlprot_file};
        EDRu::appendfile($srlprot_file,$srlprot_file_name);
    }
    return;
}

sub vvr_set_ug_paths_sys {
    my ($prod, $sys, $base) = @_;
    $prod->{location}{basedir}='/';
    $prod->{location}{rerr_file}='/tmp/rerr_file';
    $prod->{location}{savedir}=$base;
    $prod->{location}{readme_file}="$prod->{location}{savedir}/VVR_UPGRADE.README";
    $prod->{location}{startrvg_file}="$prod->{location}{savedir}/start.rvg";
    $prod->{location}{shared_startrvg_file}="$prod->{location}{savedir}/shared_start.rvg";
    $prod->{location}{attrlink_file}="$prod->{location}{savedir}/attrlink";
    $prod->{location}{shared_attrlink_file}="$prod->{location}{savedir}/shared_attrlink";
    $prod->{location}{restoresrl_file}="$prod->{location}{savedir}/restoresrl";
    $prod->{location}{shared_restoresrl_file}="$prod->{location}{savedir}/shared_restoresrl";
    $prod->{location}{adddcm_file}="$prod->{location}{savedir}/adddcm";
    $prod->{location}{shared_adddcm_file}="$prod->{location}{savedir}/shared_adddcm";
    $prod->{location}{errlog_file}="$prod->{location}{savedir}/err.log";
    $prod->{location}{adddcmerr_file}="$prod->{location}{savedir}/adddcm.err";
    $prod->{location}{srlproterr_file}="$prod->{location}{savedir}/srlprot.err";
    $prod->{location}{restoresrlerr_file}="$prod->{location}{savedir}/restoresrl.err";
    $prod->{location}{attrlinkerr_file}="$prod->{location}{savedir}/attrlink.err";
    $prod->{location}{recovererr_file}="$prod->{location}{savedir}/recover.err";
    $prod->{location}{startrvgerr_file}="$prod->{location}{savedir}/startrvg.err";
    $prod->{location}{statuserr_file}="$prod->{location}{savedir}/status.err";
    $prod->{location}{status_file}="$prod->{location}{savedir}/status.rlink";
    $prod->{location}{srlprot_file}="$prod->{location}{savedir}/srlprot";
    $prod->{location}{shared_srlprot_file}="$prod->{location}{savedir}/shared_srlprot";
    $prod->{location}{errorfile}="$prod->{location}{savedir}/cmderr.file";
    $prod->{location}{recovererr_file}="$prod->{location}{savedir}/recovererr_file";
    $prod->{location}{errfile}="$prod->{location}{savedir}/err_file";
    $prod->{location}{rlkerr_file}="$prod->{location}{savedir}/rlkerrfile";
    $prod->{location}{hostinfod_file}="$prod->{location}{savedir}/hostinfod";
    $prod->{location}{vrw_orig_conf}="$prod->{location}{basedir}/opt/VRTSweb/VERITAS/vvr/WEB-INF/classes/vvrSystem.properties";
    $prod->{location}{vrw_saved_conf}="$prod->{location}{savedir}/vvrSystem.properties";
    $prod->{location}{vrw_temp_new_conf}="$prod->{location}{savedir}/vvrSystem.temp.properties";
    $prod->{location}{vrw_new_conf_as_is}="$prod->{location}{basedir}/opt/VRTSweb/VERITAS/vvr/WEB-INF/classes/vvrSystem.prev.properties";
    return;
}


sub vvr_stop_rvg_sys {
    my ($prod, $sys, $dg, $rvg, $master, $shared) = @_;
    my ($enabled_rvg,$ret,$padv,$startrvg_file);
    $padv = $sys->padv;

    $enabled_rvg=$sys->cmd("_cmd_vxprint -g $dg -l $rvg | _cmd_grep '^state' | _cmd_awk '{ print \$3;}'");
    if ($enabled_rvg =~ /ENABLED/m) {
        if (!$shared || ($master && $shared)) {
            $ret = $sys->cmd("_cmd_vxrvg -g $dg stop $rvg");
            if (EDR::cmdexit() != 0) {
                $prod->vvr_upgrade_rollback_die($sys, $prod->{location}{savedir}, "vxrvg -g $dg stop $rvg", $ret);
            }
        }
        $startrvg_file = "$padv->{cmd}{vxrvg} -g $dg start $rvg 2> $prod->{location}{rerr_file} \n";
        $startrvg_file .= "if \[ \$? -ne 0 \]; then \n";
        $startrvg_file .= "ewritemsg -M vxvmshm:1747 \"The command $padv->{cmd}{vxrvg} -g $dg start $rvg failed with the following error:\" \n";
        $startrvg_file .= "$padv->{cmd}{cat} $prod->{location}{rerr_file}\n";
        $startrvg_file .= "fi\n";
        my $startrvg_file_name = ($shared) ? $prod->{location}{shared_startrvg_file} :
                                             $prod->{location}{startrvg_file};
        EDRu::appendfile($startrvg_file,$startrvg_file_name);
    }
    return;
}

sub vvr_set_host_infod_sys{
    my ($prod,$sys) = @_;
    my ($pattern2,$pattern1);

    if ($sys->exists("$prod->{location}{basedir}/etc/vx/vvrports")) {
        if  ($sys->exists("$prod->{location}{basedir}/etc/rc2.d/S94vxnm-host_infod")) {
            $pattern1="\/usr\/sbin\/host_infod \&";
            $pattern2="#\/usr\/sbin\/host_infod \&";
            $sys->cmd("_cmd_cat $prod->{location}{basedir}/etc/rc2.d/S94vxnm-host_infod | _cmd_sed -e 's/$pattern1/$pattern2/' > $prod->{location}{hostinfod_file} 2>/dev/null");
            $sys->cmd("_cmd_cp $prod->{location}{hostinfod_file} $prod->{location}{basedir}/etc/rc2.d/S94vxnm-host_infod");
        }
        #Volume Replicator now uses IANA assigned port number 4145 instead of 1710 to exchange heartbeat messages.
        if ($sys->exists("$prod->{location}{hostinfod_file}")) {
            $sys->cmd("_cmd_rmr $prod->{location}{hostinfod_file}");
        }
    }
    return;
}

sub vvr_set_localhost_sys {
    my ($prod, $sys, $dg,$rlink) = @_;
    my ($local_host,$ret,$msg,$padv);

    $padv = $sys->padv;
    #only rvgs with associated rlinks have work to do
    if ($rlink ne '-') {
        $local_host=$sys->cmd("_cmd_vxprint -g $dg -qQPF%local_host $rlink");
        $ret = $sys->cmd("_cmd_vxedit -g $dg set local_host=$local_host $rlink ");
        if (EDR::cmdexit() != 0) {
            $msg = Msg::new("The command $padv->{cmd}{vxedit} -g $dg set local_host=$local_host $rlink failed with the following error:\n");
            $msg->print;
            $msg = Msg::new("$ret\nThe new IANA assigned port number could not be set for the RLINK $rlink.\n");
            $msg->die;
        }
    }
    return;
}

sub vvr_set_vras_env_sys {
    my ($prod,$sys)= @_;
    my ($envfile, $pattern, $name,%exported, %env_assigned, $etcvxvras,$vras_env_in,$vras_env_new,$vras_env_tmp,$localsys);

    $localsys = $prod->localsys;
    $envfile='vras_env';
    $etcvxvras = '/etc/vx/vras';

    if ($localsys->exists("$prod->{location}{savedir}/$envfile")) {
        $vras_env_in = EDRu::readfile("$prod->{location}{savedir}/$envfile");
        for my $pattern (split(/\n/,$vras_env_in)) {
            chomp($pattern);
            next if ($pattern=~/^#/m || $pattern!~/\w/m);
            $exported{$1}=1 if ($pattern=~/[\s]*export ([\w]*)/m);
            $env_assigned{$1}=$2 if ($pattern=~/([\w]*)[\s]*=[\s]*([\w]*)/mx);
        }

        $sys->copy_to_sys($localsys,"$prod->{location}{basedir}/$etcvxvras/$envfile","$prod->{location}{savedir}/${envfile}.new");

        $vras_env_new = EDRu::readfile("$prod->{location}{savedir}/${envfile}.new");
        $vras_env_tmp = '';
        for my $pattern (split(/\n/,$vras_env_new)) {
            chomp($pattern);
            # Found export
            if ($pattern =~ /[\s]*export[\s]*([\w]*)/mx) {
                $name=$1;
                if ($exported{$name}) {
                    $vras_env_tmp .= "export $name\n";
                    next;
                }
            }
            if ($pattern =~ /([\w]*)[\s]*=[\s]*([\d]*)/mx) {
                $name=$1;
                chomp $name;
                if  ($env_assigned{$name}) {
                    $vras_env_tmp .= "$name=$env_assigned{$name}\n";
                    next;
                }
            }
            $vras_env_tmp .= "\n";
        }
        EDRu::writefile($vras_env_tmp,"$prod->{location}{savedir}/${envfile}.tmp.$sys->{sys}");
        $localsys->copy_to_sys($sys,"$prod->{location}{savedir}/${envfile}.tmp.$sys->{sys}","$prod->{location}{basedir}/$etcvxvras/$envfile");
    }
    return;
}

sub vvr_upgrade_finish_sys {
    my ($prod,$sys) = @_;
    my ($rlink,$msg,@files,$sys0,$file,@rvgs,@rlinks,$vxdctl_mode,$shared,$localsys,@dgs,$dir,$ret,$rvg,$dg,$master,$disabled_objs);

    $localsys = $prod->localsys;
    $sys0=$sys->{sys};
    $vxdctl_mode = $sys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'mode:'");
    $master = 1;
    $master = 0 if ($vxdctl_mode=~/SLAVE/m);
    $master = 2 if ($vxdctl_mode=~/MASTER/m);

    $dir = $prod->vvr_last_upgrade_sys($sys);
    return if (!$dir);

    # If clustered and slave, quit cleaning the upgrade logs
    #if (not $master) {
    #    $prod->tsub("vvr_last_upgrade_sys",$sys,1);
    #    $sys->cmd("_cmd_vras_script stop 2> /dev/null");
    #    $sys->cmd("_cmd_vras_script start 2> /dev/null");
    #    $sys->cmd("_cmd_rmr  /opt/VRTS/install/vvrug_$sys0 > /dev/null 2>&1");
    #    $prod->{vvr_upgrade_finished}=2;
    #    return;
    #}
    $prod->vvr_set_ug_paths_sys($sys,"$dir");

    #see whether configuration has been recovered
    $dg=$sys->cmd("_cmd_vxdg -q list | _cmd_awk '{print \$1}'");
    @dgs=split(/\s+/m,$dg);
    for my $dg (@dgs) {
        $shared = '';
        $shared = $sys->cmd("_cmd_vxdg list $dg 2> /dev/null | _cmd_grep 'flags:' | _cmd_grep shared");
        next if ($shared && ($master eq '0'));
        $rvg=$sys->cmd("_cmd_vxprint -g $dg -qQVF%name");
        @rvgs=split(/\s+/m,$rvg);
        for my $rvg (@rvgs) {
            $ret = $sys->cmd("_cmd_vxprint -g $dg -l $rvg | _cmd_grep 'flags:' | _cmd_grep needs_recovery");
            if ($ret) {
                $msg = Msg::new("Rvg $rvg needs recovery. Run the command vxrecover -s to recover the configuration, and then run CPI installer with configure option.");
                $msg->die;
            }
        }
        $disabled_objs=$sys->cmd("_cmd_vxprint -g $dg | _cmd_awk '{print \$4;}' | _cmd_egrep -e 'DISABLED\|RECOVER'");
        $sys->cmd("_cmd_vxrecover -g $dg -sn > /dev/null 2>&1") if ($disabled_objs);
    }

    #loop through the whole list of disk groups
    for my $dg (@dgs) {
        $shared = '';
        $shared = $sys->cmd("_cmd_vxdg list $dg 2> /dev/null | _cmd_grep 'flags:' | _cmd_grep shared");
        next if ($shared && ($master eq '0'));
        $rvg=$sys->cmd("_cmd_vxprint -g $dg -qQVF%name");
        @rvgs=split(/\s+/m,$rvg);
        for my $rvg (@rvgs) {
            $rlink=$sys->cmd("_cmd_vxprint -g $dg -qQVF%rlinks $rvg | tr ',' ' '");
            @rlinks=split(/\s+/m,$rlink);
            for my $rlink (@rlinks) {
                $prod->vvr_set_localhost_sys($sys,$dg,$rlink);
            }
        }
    }

    #restore the original configuration which was saved during upgrade start
    @files=($prod->{location}{restoresrl_file},
            $prod->{location}{adddcm_file},
            $prod->{location}{srlprot_file},
            $prod->{location}{attrlink_file},
            $prod->{location}{startrvg_file},
           );
    push (@files, $prod->{location}{shared_restoresrl_file},
                  $prod->{location}{shared_adddcm_file},
                  $prod->{location}{shared_srlprot_file},
                  $prod->{location}{shared_attrlink_file},
                  $prod->{location}{shared_startrvg_file})
        if ($master eq '2');
    $sys->cmd('_cmd_mkdir -p /tmp');
    for my $file (@files) {
        if ($localsys->exists("$file")) {
            $localsys->copy_to_sys($sys,"$file",'/tmp/upgrade.sh');
            $sys->cmd('_cmd_sh /tmp/upgrade.sh');
        }
    }
    $prod->vvr_set_vras_env_sys($sys);

    #Copy the .rdg file to the new location for 3.5
    if ($sys->exists("$prod->{location}{basedir}/etc/VRTSvras/.rdg")) {
        $sys->cmd("_cmd_cp $prod->{location}{basedir}/etc/VRTSvras/.rdg $prod->{location}{basedir}/etc/vx/vras/.rdg");
    }

    # Info about port numbers
    $prod->vvr_set_host_infod_sys($sys);
    #clean the upgrade directory
    $prod->vvr_last_upgrade_sys($sys,1);
    $sys->cmd('_cmd_vras_script stop 2> /dev/null');
    $sys->cmd('_cmd_vras_script start 2> /dev/null');
    $sys->cmd("_cmd_rmr  /opt/VRTS/install/vvrug_$sys0 > /dev/null 2>&1");
    $prod->{vvr_upgrade_finished}=2;
    return;
}

sub vvr_upgrade_rollback_die {
    my ($prod, $sys, $dir, $cmd, $err_string) = @_;
    my ($file, @files, $localsys,$vxdctl_mode, $clustered, $master, $syslist, $msg, $sys0, $tmppath,$uuid);

    $syslist=CPIC::get('systems');
    $localsys = $prod->localsys;
    for my $sys (@$syslist) {
        $dir = $prod->vvr_last_upgrade_sys($sys);
        next if (!$dir);
        $prod->vvr_set_ug_paths_sys($sys,"$dir");
        $vxdctl_mode = $sys->cmd("_cmd_vxdctl -c mode | _cmd_grep 'mode:'");
        $master = 1;
        $master = 0 if ($vxdctl_mode=~/SLAVE/m);
        $master = 2 if ($vxdctl_mode=~/MASTER/m);
        $clustered = 1 if (($vxdctl_mode =~ /MASTER/m) || ($vxdctl_mode =~ /SLAVE/m));
        #restore the original configuration which was saved during upgrade start
        @files=($prod->{location}{restoresrl_file},
                $prod->{location}{adddcm_file},
                $prod->{location}{srlprot_file},
                $prod->{location}{attrlink_file},
                $prod->{location}{startrvg_file},
               );
        push (@files, $prod->{location}{shared_restoresrl_file},
                      $prod->{location}{shared_adddcm_file},
                      $prod->{location}{shared_srlprot_file},
                      $prod->{location}{shared_attrlink_file},
                      $prod->{location}{shared_startrvg_file})
            if ($master eq '2');

        # No need for master check because only master call call upgrade_callback
        $sys->cmd('_cmd_mkdir -p /tmp');
        for my $file (@files) {
            if ($localsys->exists("$file")) {
                $localsys->copy_to_sys($sys,"$file",'/tmp/upgrade.sh');
                $sys->cmd('_cmd_sh /tmp/upgrade.sh');
            }
        }

        # Delete the log
        $sys0 = $sys->{sys};
        $tmppath=EDR::get('tmppath');
        $uuid=EDR::get('uuid');
        $dir = "$tmppath/vvr_upgrade_$sys0-$uuid";
        EDR::cmd_local("_cmd_rmr $dir");
    }

    # Print the command, the error and die
    if ($cmd) {
        Msg::n();
        $msg = Msg::new("The following command failed with given error:\n");
        $msg->print;
        $msg = Msg::new("Command:  $cmd \n");
        $msg->print;
        $msg = Msg::new("Error:  $err_string \n\n");
        $msg->print;
    }
    EDR::exit_exitfile();
    return;
}

sub vvr_last_upgrade_sys{
    my ($prod,$sys,$clean) = @_;
    my ($dir,@dirs,$ug_dir,$tmppath);

    $tmppath = EDR::get('tmppath');
    $dir = EDR::cmd_local("_cmd_ls $tmppath | _cmd_egrep  '^vvr_upgrade_$sys->{sys}'");
    @dirs=split(/\s+/m,$dir);
    $ug_dir = '';
    for my $dir (@dirs) {
        $ug_dir = "$tmppath/$dir";
        EDR::cmd_local("_cmd_rmr $tmppath/$dir") if ($clean);
    }
    return unless ($sys->exists("/opt/VRTS/install/vvrug_$sys->{sys}"));
    return $ug_dir;
}

sub vr_licensed_sys{
    my ($prod,$sys) = @_;
    my $cpic = Obj::cpic();
    my $rel = $cpic->rel;
    my $cfg = Obj::cfg();

    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    if($rel->feature_licensed_sys($sys,'VVR')) {
        Cfg::set_opt('vr');
        return 1;
    }
    return '';
}

sub vfr_licensed_sys{
    my ($prod,$sys) = @_;
    my $cpic = Obj::cpic();
    my $rel = $cpic->rel;
    my $cfg = Obj::cfg();

    $rel->read_licenses_sys($sys) unless ($sys->{keys});
    # VFR can only be considered when VVR/VR is not available
    return '' if ($prod->vr_licensed_sys($sys));
    if($rel->feature_licensed_sys($sys,'VFR')) {
        Cfg::set_opt('vfr');
        return 1;
    }
    return '';
}

sub vvr_upgrade_poststart_sys{
    my ($prod,$sys)= @_;
    my ($cfg,$voldmode, $dir);

    $cfg = Obj::cfg();
    # Upgrade finish cannot be done during installation
    return if ($cfg->{vm_restore_cfg}{$sys->{sys}});
    # check if most recent installation was upgrade
    $dir = $prod->vvr_last_upgrade_sys($sys);
    return if (!$dir);
    $voldmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    return if (not $voldmode =~ /mode: enabled/m );
    Msg::log("\nPerforming VVR upgrade configuration on host $sys->{sys} ");
    $prod->vvr_upgrade_finish_sys($sys);
    Msg::log('Done');
    return;
}

sub postcheck_vm_sys {
    my ($prod,$sys) = @_;
    my ($cfg,$voldmode, $dir,$msg,$rel,$cpic,@m);
    $cpic=Obj::cpic();
    $rel=$cpic->rel;
    $voldmode = $sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    unless($voldmode=~/mode: enabled/m){
        $msg=Msg::new("Volume Manager is not runing");
        push(@m,$msg);
        if($sys->exists('/etc/vx/reconfig.d/state.d/install-db')){
            $msg=Msg::new("\n\tthe file /etc/vx/reconfig.d/state.d/install-db is found on $sys->{sys}. It is recommended to remove the file to start VM");
            push(@m,$msg);
        }

        unless($sys->exists('/etc/vx/volboot')){
            $msg=Msg::new("\n\tthe file /etc/vx/volboot is missing on $sys->{sys}. It is recommended to initialize the volboot file");
            push(@m,$msg);
        }

        unless($rel->prod_licensed_sys($sys,"VM60")){
            $msg=Msg::new("\n\tVM is not licensed on $sys->{sys}. It is recommended to check the license key.");
            push(@m,$msg);
        }

        $sys->push_warning(@m);
    }
    return "";
}

sub postcheck_vm_disabled_dg_sys{
    my ($prod,$sys) = @_;
    my ($dg,$state,$dgs,$msg,$disabledmsg);
    $dgs = $sys->cmd("_cmd_vxdg -q list 2>/dev/null | _cmd_awk '{print \$1,\$2}'");
    $disabledmsg = '';
    for my $line (split (/\n/,$dgs)) {
        ($dg,$state) = split(/\s/,$line);
        if ($state !~ /enabled/) {
            $disabledmsg .= "\n\t$dg";
        }
    }
    if ($disabledmsg) {
        $msg=Msg::new("The following diskgroups are not enabled on $sys->{sys}:$disabledmsg");
        $sys->push_warning($msg);
        return 0;
    } else {
        return 1;
    }
}

sub postcheck_vm_disabled_vol_sys{
    my ($prod,$sys) = @_;
    my ($dgs, $vols, $unstartablemsg, $disabledmsg, $notinfstabmsg,$msg,$vol,$state,$fs,$blockdevs);
    $unstartablemsg = '';
    $dgs = $sys->cmd("_cmd_vxdg -q list 2>/dev/null | _cmd_awk '{print \$1}'");
    $fs=$prod->prod("FS60");
    $blockdevs=$fs->fstab_all_blockdevice_sys($sys);
    for my $dg (split(/\n/,$dgs)) {
        $vols = $sys->cmd("_cmd_vxinfo -g $dg 2>/dev/null | _cmd_sed -n -e '/^.*[\\t ]Unstartable[\\t ]*\$/p' 2>/dev/null | _cmd_awk '{print \$1}'");
        if ($vols) {
            for my $vol (split(/\n/,$vols)) {
                $unstartablemsg .= sprintf("\n\t%-20s DiskGroup: %s",$vol,$dg);
            }
        }
        $vols = $sys->cmd("_cmd_vxprint -g $dg -q 2>/dev/null | _cmd_sed -n -e '/^v[\\t ]/p' 2>/dev/null | _cmd_awk '{print \$2,\$4}'");
        if ($vols) {
            for my $line (split(/\n/,$vols)) {
                ($vol,$state) = split(/\s/,$line);
                if ( $state ne 'ENABLED') {
                    $disabledmsg .= sprintf("\n\t%-20s KSTATE: %-10s DiskGroup: %s ",$vol,$state,$dg);
                }
                if (!EDRu::inarr("/dev/vx/dsk/$dg/$vol",@$blockdevs)) {
                    $notinfstabmsg .= sprintf("\n\t%-20s DiskGroup: %s",$vol,$dg);
                }
            }
        }
    }
    
    if ( $unstartablemsg ) {
        $msg=Msg::new("The following volumes are in Unstartable state on $sys->{sys}:$unstartablemsg");
        $sys->push_warning($msg);
    }

    if ( $disabledmsg ) {
        $msg=Msg::new("The following volumes are not in ENABLED state on $sys->{sys}:$disabledmsg");
        $sys->push_warning($msg);
    }

    if ( $notinfstabmsg ) {
        $msg=Msg::new("The following volumes are not configured in $fs->{fstab} on $sys->{sys}:$notinfstabmsg");
        $sys->push_warning($msg);
    }

    if ( $unstartablemsg || $disabledmsg || $notinfstabmsg) {
        return 0;
    } else {
        return 1;
    }
}

sub postcheck_vm_failed_disks_sys{
    my ($prod,$sys) = @_;
    my ($cmd_vxdisk,$foundmsg,$disk,$status,$msg);
    $foundmsg = '';
    $cmd_vxdisk = $sys->cmd("_cmd_vxdisk -q list 2>/dev/null ");
    for my $line(split(/\n/,$cmd_vxdisk)) {
        if ($line =~ /invalid/mx or $line !~ /online(\s+[^\s]+)?(\s+shared)?\s*$/mx) {
            if ($line !~ /LVM/mx){
                ($disk) = split(/\s/,$line);
                $status = $line;
                $status =~ s/^\s*[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+(.*)\s*$/$1/mx;
                $foundmsg .= sprintf("\n\t%-20s Status: %s",$disk,$status);
            }
        }
    }
    if ( $foundmsg ) {
        $msg=Msg::new("The following disks are not in online or online shared state on $sys->{sys}:$foundmsg");
        $sys->push_warning($msg);
        return 0;
    } else {
        return 1; 
    }
}

sub register_postchecks_per_system {
    my ($prod,$sequence_id,$name,$desc,$handler);
    $prod=shift;

    $sequence_id=401;
    $name='volume_manager';
    $desc=Msg::new("Volume Manager status");
    $handler=\&postcheck_vm_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=410;
    $name='volume_manager_failed_disks';
    $desc=Msg::new("Disk status");
    $handler=\&postcheck_vm_failed_disks_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=411;
    $name='volume_manager_disabled_dg';
    $desc=Msg::new("DiskGroup status");
    $handler=\&postcheck_vm_disabled_dg_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    $sequence_id=412;
    $name='volume_manager_disabled_vol';
    $desc=Msg::new("Volume status");
    $handler=\&postcheck_vm_disabled_vol_sys;
    $prod->register_postcheck_item_per_system($sequence_id,"$name",$desc,$handler);

    return;
}

sub get_supported_tunables{
    my ($prod) =@_;
    my ($tunables,$dmp);
    if ($prod->{class} =~ /DMP/m) {
        $tunables = $prod->get_tunables;
    } else {
        $tunables = [];
        push @$tunables, @{$prod->get_tunables};
        $dmp=$prod->prod('DMP60');
        push @$tunables, @{$dmp->get_tunables};
    }
    return $tunables;
}

sub get_tunable_value_sys{
    my ($prod,$sys,$tunable) =@_;
    my ($origval);
    if ($prod->{class} =~ /DMP/m) {
        $origval = $sys->cmd("_cmd_vxdmpadm gettune $tunable 2>/dev/null |_cmd_grep $tunable | _cmd_awk '{print \$2}'");
    } else {
        $origval = $sys->cmd("_cmd_vxtune $tunable 2>/dev/null |_cmd_grep $tunable | _cmd_awk '{print \$2}'");
    }
    return $origval;
}

sub set_tunable_value_sys{
    my ($prod,$sys,$tunable,$value) =@_;
    my ($out);
    if ($prod->{class} =~ /DMP/m) {
        $out = $sys->cmd("_cmd_vxdmpadm settune $tunable=$value");
    } else {
        $out = $sys->cmd("_cmd_vxtune $tunable $value");
    }
    return (EDR::cmdexit(),$out);
}

sub dg_conf_upgrade_precheck_sys {
    my ($prod,$sys) = @_;
    my ($cf_bkup_path,$cmd,$dg,$dgid,$dglist,$msg,$rootpath,$voldmode);
    return if ($sys->exists("$prod->{mkdbfile}"));
    return if ($prod->vol_is_vm_disabled_sys($sys));
    $voldmode = $prod->vold_status_sys($sys);
    if ($voldmode !~ /enabled/m ) {
        # If vold is down, atempt to start it
        # firstly try to start without '-r reset' since '-r reset' will increase dg seq no
        if ($voldmode =~ /not-running/m) {
            Msg::log("vxconfigd is not running on $sys->{sys}; restarting");
            $sys->cmd('_cmd_vxconfigd -k -x syslog 2> /dev/null');
        } else {
            # the mode could be disabled or booted
            Msg::log("vxconfigd is in $voldmode on $sys->{sys}; re-enabling");
            $sys->cmd('_cmd_vxdctl enable >/dev/null 2>&1');
        }
        $voldmode = $prod->vold_status_sys($sys);
        if ($voldmode !~ /enabled/m ) { 
            $sys->cmd('_cmd_vxconfigd -k -r reset -x syslog 2> /dev/null');
            $voldmode = $prod->vold_status_sys($sys);
            if ($voldmode !~ /enabled/m ) {
                $msg=Msg::new("vxconfigd could not be started on $sys->{sys}. Upgrading VRTSvxvm in this scenario can result in configuration errors, or data loss for Veritas Volume Manager objects. Continue if you are sure that there are no Veritas Volume Manager objects on the host.");
                $sys->push_warning($msg);
                return '';
            }
        }
    }
    $rootpath = Cfg::opt("rootpath");
    $cf_bkup_path = "$rootpath$prod->{cf_bkup_path}";
    $dglist = $sys->cmd("_cmd_vxdg -q list 2> /dev/null");
    for my $line(split(/\n/,$dglist)) {
        if ($line =~ /(\S+)\s+\S+\s+(\S+)/m) {
            $dg = $1;
            $dgid = $2;
        }
        if ($prod->is_dg_seqno_change_sys($sys,$dg,$dgid)) {
            $sys->set_value('dgs_need_backup','push',$dg);
        }
    }
    if ($sys->{dgs_need_backup}) {
        $dglist = join(" ", @{$sys->{dgs_need_backup}});
        $cmd = $prod->padv->{cmd}{vxconfigbackup};
        $msg = Msg::new("The following disk group(s) do not have the latest backup of configuration files in $cf_bkup_path on $sys->{sys} before upgrade:\n\t$dglist\nRun the command '$cmd -l [dir] [dgname|dgid]' to take the latest backup of them. The default backup directory $cf_bkup_path on $sys->{sys} may be removed during upgrade. Manually copy the directory to other places if you would like to keep the backup files.");
        $sys->push_warning($msg);
    } elsif ($dglist) {
        $msg = Msg::new("The default backup directory $cf_bkup_path on $sys->{sys} may be removed during upgrade. Manually copy the directory to other places if you would like to keep the backup of the configuration files for the disk groups before upgrade.");
        $sys->push_note($msg);
    }
    return;    
}

sub is_dg_seqno_change_sys {
    my ($prod,$sys,$dg,$dgid,$seqno) = @_;
    my ($cf_bkup_path,$dginfo,$newseqno,$oldseqno,$rootpath);
    $rootpath = Cfg::opt("rootpath");
    $cf_bkup_path = "$rootpath$prod->{cf_bkup_path}";
    if ($sys->exists("$cf_bkup_path/$dg.$dgid/$dgid.dginfo")) {
        # check if seqno is equal
        # If seqno is passed to function we'll use it, else
        # we need to get int by qurying vxconfigd.
        if (!defined($seqno)) {
            $dginfo = $sys->cmd("_cmd_vxdg list $dg 2>/dev/null"); 
            return 0 if (EDR::cmdexit());
            $newseqno = $1 if ($dginfo =~ /\nconfig:\s+seqno=(\S+)\s+/m);
        } else {
            $newseqno = $seqno;
        }
        $dginfo = $sys->cmd("_cmd_grep '^config:' $cf_bkup_path/$dg.$dgid/$dgid.dginfo");
        $oldseqno = $1 if ($dginfo =~ /^config:\s+seqno=(\S+)\s+/m);
        ($newseqno > $oldseqno) ?  return 1 : return 0;
    }
    $dginfo = $sys->cmd("_cmd_vxdg list $dg 2>/dev/null");
    if (EDR::cmdexit()) {
        Msg::log("Disk group $dg does not exist, no backup is necessary");
        return 0;
    }
    # seqno has changed
    return 1;
}

package Prod::VM60::AIX;
@Prod::VM60::AIX::ISA = qw(Prod::VM60::Common);

sub init_plat {
    my $prod=shift;
    my $padv=$prod->padv();
    if ($prod->{class} =~ /DMP/m) {
        $prod->{allpkgs}=[ qw(VRTSveki60 VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSveki60 VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSveki60 VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
    } else {
        $prod->{allpkgs}=[ qw(VRTSveki60 VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSveki60 VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSveki60 VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
    }
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0.3 5.1 6.0)];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvrdoc VRTSap VRTStep VRTSvrw VRTSweb.rte VRTSvcsvr
        VRTSvrpro VRTSddlpr VRTSvdid.rte VRTSalloc VRTSvsvc
        VRTSvmpro VRTSdcli VRTSvmdoc VRTSvmman VRTScpi.rte
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSat.server VRTSat.client VRTSsmf VRTSpbx
        VRTSicsco VRTSvxvm60 VRTSveki60 VRTSjre15.rte VRTSjre.rte
        VRTSsfcpi60SP1PR1 VRTSperl514 VRTSperl.rte VRTSvlic32
    ) ];

    $prod->{vxdbms3scripts}='/etc/rc.d/rc?.d/*vxdbms3*';
    $padv->{cmd}{vxdctl}='/usr/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxinfo}='/usr/sbin/vxinfo';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxattachd}='/usr/lib/vxvm/bin/vxattachd';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{vxrvg}='/usr/sbin/vxrvg';
    $padv->{cmd}{vxrlink}='/usr/sbin/vxrlink';
    $padv->{cmd}{vradmin}='/usr/sbin/vradmin';
    $padv->{cmd}{vxtune}='/usr/sbin/vxtune';
    $padv->{cmd}{vxrecover}='/usr/sbin/vxrecover';
    $padv->{cmd}{vras_script}='/etc/init.d/vras-vradmind.sh';
    $padv->{cmd}{vxclustadm}='/opt/VRTS/bin/vxclustadm';
    $padv->{cmd}{vxconfigd}='/sbin/vxconfigd';
    $padv->{cmd}{vxconfigbackupd}='/etc/vx/bin/vxconfigbackupd';
    $padv->{cmd}{vxgetrootdisk}='/etc/vx/bin/vxgetrootdisk';
    $padv->{cmd}{vxdisksetup}='/usr/lib/vxvm/bin/vxdisksetup';
    return;
}

sub cli_prestart_config_questions {
    my $sys;
    my $prod=shift;
    my $syslist=CPIC::get('systems');
    for my $sys (@$syslist){
        # Don't need to check when we upgrade
        next if ($prod->upgrading_vm_sys($sys));
        next if (! $sys->exists($prod->{mkdbfile}));
        $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    }
    return;
}

sub preinstall_tasks {
    my $prod = shift;
    my (@sysnames,@systems,$ayn,$cfg,$export_cmd,$help,$msg,$syslist);
    $cfg = Obj::cfg();
    $syslist = CPIC::get('systems');
    for my $sys (@$syslist){
        # Check if VRTSvxvm will be installed
        next unless ((EDRu::inarr('VRTSvxvm60',@{$sys->{installpkgs}})) ||
             (EDRu::inarr('VRTSvxvm60',@{$sys->{installpatches}})));
        # check if DMP support for vSCSI is disabled
        if ($prod->vm_is_dmp_vscsi_disabled_sys($sys)) {
            push (@systems,$sys);
            push (@sysnames,$sys->{sys});
        }
    }
    if (@systems) {
        my $str = join("\n\t\t",@sysnames);
        $msg = Msg::new("DMP support for vSCSI devices seems to be not enabled on the following system(s):\n\t\t$str");
        $msg->printn;
        $msg = Msg::new("Do you want Veritas Volume Manager to enable DMP support for vSCSI devices on these systems?");
        $help = Msg::new("Enabling DMP support for vSCSI devices will put vSCSI devices under DMP control instead of MPIO, which may need reboot");
        unless (Cfg::opt('responsefile')) {
            $ayn = $msg->ayny($help);
            $cfg->{vxvm_dmp_vscsi_enable} = 'no' if ($ayn eq 'N');
        }
        # export environment variable __VXVM_DMP_VSCSI_ENABLE to pkginstall/patch install process
        # to disable DMP support for vSCSI devices when install VRTSvxvm pkgs/patches
        if ($cfg->{vxvm_dmp_vscsi_enable} eq 'no') {
            $export_cmd = '__VXVM_DMP_VSCSI_ENABLE=no;export __VXVM_DMP_VSCSI_ENABLE;';
            for my $sysi(@systems) {
                $sysi->{install_export_cmd} = ($sysi->{install_export_cmd}) ? ($sysi->{install_export_cmd}.$export_cmd) : $export_cmd;
            }
            Msg::log('Set __VXVM_DMP_VSCSI_ENABLE=no to disable DMP support for vSCSI devices when install VRTSvxvm pkgs/patches');
        }
    }
    return;
}

# Function: postinstall_sys()
# Purpose:
#    Performs some tasks normally done by vxinstall.
# Input Parameters:
#    $sys
# Output Parameters:
#    None
# Called by:
#    postinstall()
sub postinstall_sys {
    my ($prod,$sys)= @_;
    my $cscript=CPIC::get('script');
    $sys->cmd("_cmd_vxscriptlog $cscript");
    return if (! Cfg::opt('responsefile'));
    return if (! $sys->exists($prod->{mkdbfile}));
    $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    return;
}


sub is_encapsulated_bootdisk_sys {
    return 0;
}

sub obsoleted_pkgs_sys {
    my ($prod,$sys,$dir) = @_;
    my ($pkgs,@obsoleted_pkgs,$pkg);

    @obsoleted_pkgs = ();
    $pkgs = $sys->cmd("_cmd_lslpp -w $dir 2>/dev/null | _cmd_awk '{print \$2}'");
    for my $pkg (split(/\n/, $pkgs)) {
        next if ($pkg=~/^\s*$/m);
        next if ($pkg=~/^(Fileset|VRTSvxvm|VRTSaslapm)$/mx);
        push (@obsoleted_pkgs, $pkg);
    }
    return \@obsoleted_pkgs;
}

sub obsoleted_asl_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, '/etc/vx/lib/discovery.d');
}

sub obsoleted_apm_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, '/etc/vx/apmkey.d');
}

sub check_vios_sys {
    my ($prod,$sys) = @_;
    $sys->cmd('_cmd_lslpp -l ios.cli.rte > /dev/null 2>&1');
    if (!EDR::cmdexit()) {
        Msg::log("$sys->{sys} is Virtual I/O Server ...");
    }
    return 1;
}

sub suppress_mpio_sys {
    my ($prod,$sys) = @_;
    $sys->cmd('_cmd_lsdev -Cc disk | _cmd_grep MPIO >/dev/null 2>&1');
    if (!EDR::cmdexit()) {
        $sys->cmd('_cmd_vxddladm assign names >/dev/null 2>&1');
    }
    return 1;
}

sub vm_is_dmp_vscsi_disabled_sys {
    my ($prod,$sys) = @_;
    my $out;
    $out = $sys->cmd("_cmd_odmget -q 'status != 0 AND PdDvLn LIKE disk/vscsi/*' CuDv");
    if ((!EDR::cmdexit()) && ($out =~ /vscsi/m)) {
        $out = $sys->cmd("_cmd_odmget -q 'uniquetype=disk/vscsi/dmpvdisk and attribute=model_map' PdAt");
        return 1 if ($out !~ /vscsi/m);
    }
    return 0;
}

sub vol_is_vm_disabled_sys {
    my ($prod,$sys) = @_;
    my $out;
    $out = $sys->cmd("_cmd_odmget -q 'name = vxio AND attribute = vol_disable_vm' CuAt | _cmd_grep -w value");
    return 1 if ($out =~ /value\s*=\s*\"1\"/mx);
    return 0;
}

sub vxddladm_addsupport_sys {
    my ($prod,$sys) = @_;
    $sys->cmd('_cmd_vxddladm addsupport all');
    return 1;
}

sub dmp_osn_stop_sys {
    my ($prod,$sys,$task) = @_;
    return 1 if (Cfg::opt(qw(patchupgrade stop)));
    return $prod->SUPER::dmp_osn_stop_sys($sys,$task);
}

# AIX specific
sub backup_vxvm_tunables_preremove_sys {
    my ($prod,$sys) = @_;
    my ($vxtune_file, $vxtune_file_content, $odmget_output, $var, $val);
    $vxtune_file = '/etc/vx/vxvmtunables.save';
    $vxtune_file_content = '';
    $sys->cmd("_cmd_rm -f $vxtune_file");
    $odmget_output = $sys->cmd("_cmd_odmget -q 'name=vxio' CuAt 2>&1");
    if (EDR::cmdexit() == 0) {
        $var = '';
        $val = '';
        for my $line( split(/\n/, $odmget_output)) {
            if ($line =~ /^CuAt:/mx ) {
                $var = '';
                $val = '';
            } elsif ( $line =~ /^\s*attribute\s*=\s*([^\s]+)\s*$/mx) {
                $var = $1;
                $var =~ s/^"//mx;
                $var =~ s/"$//mx;
            } elsif ( $line =~ /^\s*value\s*=\s*([^\s]+)\s*$/mx) {
                $val = $1;
                $val =~ s/^"//mx;
                $val =~ s/"$//mx;
                if ($var && $val) {
                    $vxtune_file_content .= "$var = $val\n";
                }
            }
        }
        $sys->writefile($vxtune_file_content, $vxtune_file);
        $sys->cmd("_cmd_cat $vxtune_file");
    }
    return;
}

package Prod::VM60::HPUX;
@Prod::VM60::HPUX::ISA = qw(Prod::VM60::Common);

sub init_plat {
    my $prod=shift;
    my $padv=$prod->padv();
    if ($prod->{class} =~ /DMP/m) {
        $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
        push @{$prod->{tunables}},
            {
                "name" => "dmp_evm_handling",
                "desc" => Msg::new("Whether EVM should be handled or not")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            ;
    } else {
        $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
        push (@{$prod->{obsoleted_but_still_support_pkgs}}, qw(VRTSpbx VRTSobc33 VRTSicsco));

        # Some tunables have different value range on HP-UX
        push @{$prod->{tunables}},
            {
                "name" => "vol_max_nmpool_sz",
                "desc" => Msg::new("Maximum name pool size (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 2097152, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_max_rdback_sz",
                "desc" => Msg::new("Storage Record readback pool maximum (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 2097152, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_max_wrspool_sz",
                "desc" => Msg::new("Maximum memory used in clustered version of VERITAS Volume Replicator")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 2097152, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_rvio_maxpool_sz",
                "desc" => Msg::new("Maximum memory requested by VERITAS Volume Replicator (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "range",
                "values" => [ 2097152, 4294967295, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "vol_maxspecialio",
                "desc" => Msg::new("Maximum size of a VxVM I/O operation issued by an ioctl call (kBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 512, 2048, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voldrl_min_regionsz",
                "desc" => Msg::new("Minimum size of a VxVM Dirty Region Logging (DRL) region (kBytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 512, 2097512, undef ],
                "when_to_set" => 2,
            },
            {
                "name" => "voliomem_chunk_size",
                "desc" => Msg::new("Size of VxVM memory allocation requests (bytes)")->{msg},
                "define_object" => $prod,
                "reboot" => 1,
                "type" => "range",
                "values" => [ 32768, 524288, undef ],
                "when_to_set" => 2,
            },
            ;
    }
    $prod->{upgradevers}=[qw(3.5 4.1 5.0 5.1 6.0)];
    $prod->{zru_releases}=[qw()];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvrmcsg VRTStep VRTSap VRTSvrdoc VRTSvrw VRTSweb
        VRTSvcsvr VRTSvrpro VRTSvxmsa VRTSvrdev VRTSddlpr VRTSvsvc VRTSvdid
        VRTSalloc VRTSdcli VRTSvmdoc VRTSvmpro VRTSvmman VRTScpi
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSsmf VRTSpbx VRTSicsco VRTSvxvm60 VRTSjre15
        VRTSjre VRTSsfcpi60SP1PR1 VRTSperl514 VRTSvlic32 VRTSwl
    ) ];
    $prod->{obsoleted_bundles}=[ qw(Base-VxTools-50 Base-VxVM-50 B3929FB Base-VxVM Base-VxTools-501 Base-VxVM-501) ];
    $prod->{obsoleted_bundled_pkgs}=[ qw(AVXTOOL AVXVM) ];

    $prod->{vxdbms3scripts}='/sbin/rc?.d/*vxdbms3';
    $padv->{cmd}{is_vxvmroot}='/sbin/is_vxvmroot';
    $padv->{cmd}{vxdctl}='/usr/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxinfo}='/usr/sbin/vxinfo';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxattachd}='/usr/lib/vxvm/bin/vxattachd';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{vxrvg}='/usr/sbin/vxrvg';
    $padv->{cmd}{vxrlink}='/usr/sbin/vxrlink';
    $padv->{cmd}{vradmin}='/usr/sbin/vradmin';
    $padv->{cmd}{vxtune}='/usr/sbin/vxtune';
    $padv->{cmd}{vxrecover}='/usr/sbin/vxrecover';
    $padv->{cmd}{vras_script}='/etc/init.d/vras-vradmind.sh';
    $padv->{cmd}{vxclustadm}='/opt/VRTS/bin/vxclustadm';
    $padv->{cmd}{vxconfigd}='/sbin/vxconfigd';
    $padv->{cmd}{vxconfigbackupd}='/etc/vx/bin/vxconfigbackupd';
    $padv->{cmd}{vxgetrootdisk}='/etc/vx/bin/vxgetrootdisk';
    $padv->{cmd}{vxdisksetup}='/usr/lib/vxvm/bin/vxdisksetup';
    return;
}

#
# Function: cli_prestart_config_questions()
# Purpose:
#    Performs some tasks normally done by vxinstall
# Input Parameters:
#    None
# Output Parameters:
#    None
# Called by:
#
sub cli_prestart_config_questions {
    my $sys;
    my $prod=shift;
    my $syslist=CPIC::get('systems');

    for my $sys (@$syslist) {
        # Don't need to check when we upgrade
        next if ($prod->upgrading_vm_sys($sys));
        next if (! $sys->exists($prod->{mkdbfile}));
        $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    }
    return;
}

sub install_precheck_sys {
    my ($prod,$sys)= @_;
    my $cprod=CPIC::get('prod');
    $prod->obsoleted_thirdparty_pkgs_sys($sys);
    if (EDRu::inarr($cprod,qw/VM60 DMP60/)) {
        $prod->obsoleted_bundles_sys($sys);
        $prod->obsoleted_bundled_pkgs_sys($sys);
    }
    return;
}

# Do not restore the VM configuration files for HPUX
sub upgrade_postinstall_sys {
    my ($prod,$sys)= @_;
    my ($rootpath);
    $rootpath = Cfg::opt('rootpath');
    # install-db will not be there for an upgrade
    $sys->cmd("_cmd_touch $rootpath/etc/vx/.cpi_rootdg")
        if ($prod->set_rootdg_sys($sys));
    $sys->cmd("_cmd_rmr $rootpath/$prod->{mkdbfile}")
        if ($sys->exists("$rootpath/$prod->{volbootfile}"));
    return;
}

# Do not backup the VM configuration files for HPUX
sub upgrade_preremove_sys { return ''; }

#
# Function: postinstall_sys()
# Purpose:
#    Performs some tasks normally done by vxinstall.
# Input Parameters:
#    $sys
# Output Parameters:
#    None
# Called by:
#    postinstall()
sub postinstall_sys {
    my ($prod,$sys)= @_;
    my $cscript=CPIC::get('script');
    $prod->pre_postinstall_sys($sys);
    # install-db will not be there for an upgrade
    # TODO: upsell?
    return if ($prod->upgrading_vm_sys($sys));
    $sys->cmd("_cmd_vxscriptlog $cscript");
    return if (! Cfg::opt('responsefile'));
    return if (! $sys->exists($prod->{mkdbfile}));
    $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    return;
}

# Function: pre_postinstall_sys()
# Purpose:
# Input Parameters:
#    $sys
# Output Parameters:
#    Touches /etc/vx/.cpi_rootdg for upgrade scenarios from VM 3.5.
# Called by:
#    postinstall_sys
sub pre_postinstall_sys {
    my ($prod,$sys) = @_;
    my ($rc);

    if ($prod->upgrading_vm_sys($sys)) {
        $sys->cmd('_cmd_touch /etc/vx/.cpi_rootdg') if ($prod->set_rootdg_sys($sys));
    }
    return;
}

sub is_encapsulated_bootdisk_sys {
    my ($prod,$sys) = @_;
    my ($mnttab,$encapsulated,$dir,$path);

    $mnttab = $sys->cmd("_cmd_mount | _cmd_grep ' \/dev\/vx\/dsk\/'");
    $encapsulated=0;
    if ($mnttab) {
        for my $path (split(/\n/, $mnttab)) {
            for my $dir (qw(/ /usr /var /opt)) {
                if ($path =~ /^$dir\s/m) {
                    $encapsulated=1;
                    return $encapsulated;
                }
            }
        }
    }
    return $encapsulated;
}

sub obsoleted_pkgs_sys {
    my ($prod,$sys,$filetype) = @_;
    my ($pkgs,@obsoleted_pkgs,$pkg);

    @obsoleted_pkgs = ();
    $pkgs = $sys->cmd("_cmd_swlist -l file *.$filetype 2> /dev/null | _cmd_grep '^#' | _cmd_grep $filetype | _cmd_awk '{print \$2}' | _cmd_awk -F. '{print \$1}'");
    for my $pkg (split(/\n/, $pkgs)) {
        next if ($pkg=~/^\s*$/m);
        next if ($pkg=~/^(VRTSvxvm|VRTSaslapm)$/mx);
        push (@obsoleted_pkgs, $pkg);
    }
    return \@obsoleted_pkgs;
}

sub obsoleted_asl_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, 'ASL_FILES');
}

sub obsoleted_apm_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, 'APM_FILES');
}

sub verify_responsefile {
    my ($cfg,$msg);
    $cfg=Obj::cfg();
    if (($cfg->{opt}{install}) && ($cfg->{opt}{configure})) {
       $msg=Msg::new("The variables 'install' and 'configure' cannot be both defined for the product that has VxVM depot on HP-UX");
       $msg->die();
    }
    return;
}

package Prod::VM60::Linux;
@Prod::VM60::Linux::ISA = qw(Prod::VM60::Common);

sub init_plat {
    my $prod=shift;
    my $padv=$prod->padv();
    if ($prod->{class} =~ /DMP/m) {
        $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
    } else {
        $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSlvmconv60 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
    }
    $prod->{upgradevers}=[qw(5.0.30 5.1 6.0)];
    $prod->{zru_releases}=[qw(4.1.40 5.0 5.1 6.0)];

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvrdoc VRTSap VRTStep VRTSvrw VRTSweb VRTSvcsvr
        VRTSvrpro VRTSalloc VRTSdcli VRTSvsvc VRTSvmpro VRTSddlpr
        VRTSvdid VRTSlvmconv60 VRTSvmdoc VRTSvmman VRTScpi
        SYMClma VRTSspt60 VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro
        VRTSdsa VRTSsfmh41 VRTSob34 VRTSobc33 VRTSaslapm60
        VRTSat50 VRTSatClient50 VRTSsmf VRTSpbx VRTSicsco VRTSvxvm60
        VRTSvxvm-platform VRTSvxvm-common VRTSjre15 VRTSjre
        VRTSsfcpi60SP1PR1 VRTSperl514 VRTSvlic32
    ) ];

    $prod->{vxdbms3scripts}='/etc/rc.d/rc?.d/*vxdbms3*';
    $padv->{cmd}{stat}='/usr/bin/stat';
    $padv->{cmd}{mknod}='/bin/mknod';
    $padv->{cmd}{vxdctl}='/sbin/vxdctl';
    $padv->{cmd}{vxdisk}='/sbin/vxdisk';
    $padv->{cmd}{vxinfo}='/usr/sbin/vxinfo';
    $padv->{cmd}{vxconfigd}='/sbin/vxconfigd';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxattachd}='/usr/lib/vxvm/bin/vxattachd';
    $padv->{cmd}{vxdg}='/usr/sbin/vxdg';
    $padv->{cmd}{vxprint}='/usr/sbin/vxprint';
    $padv->{cmd}{vxscriptlog}='/usr/sbin/vxscriptlog';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdmpinit}='/etc/vx/bin/vxdmpinit';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxedit}='/usr/sbin/vxedit';
    $padv->{cmd}{vxvol}='/usr/sbin/vxvol';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{vxrecover}='/usr/sbin/vxrecover';
    $padv->{cmd}{vxrvg}='/usr/sbin/vxrvg';
    $padv->{cmd}{vxrlink}='/usr/sbin/vxrlink';
    $padv->{cmd}{vradmin}='/usr/sbin/vradmin';
    $padv->{cmd}{vxtune}='/sbin/vxtune';
    $padv->{cmd}{vxrecover}='/usr/sbin/vxrecover';
    $padv->{cmd}{vras_script}='/etc/init.d/vras-vradmind.sh';
    $padv->{cmd}{vxclustadm}='/opt/VRTS/bin/vxclustadm';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxconfigbackupd}='/etc/vx/bin/vxconfigbackupd';
    $padv->{cmd}{vxgetrootdisk}='/etc/vx/bin/vxgetrootdisk';
    $padv->{cmd}{vxdisksetup}='/usr/lib/vxvm/bin/vxdisksetup';
    return;
}

#
# Function: cli_prestart_config_questions()
# Purpose:
#    Performs some tasks normally done by vxinstall, such as
#    enabling DMP and processing enclosure based naming...
#    Note that on Linux DMP must be enabled to use enclosure based naming.
# Input Parameters:
#    None
# Output Parameters:
#    None
# Called by:
#    configure()
sub cli_prestart_config_questions {
    my $sys;
    my $prod=shift;
    my $syslist=CPIC::get('systems');

    for my $sys (@$syslist) {
        # Don't need to check when we upgrade
        next if ($prod->upgrading_vm_sys($sys));
        next if (! $sys->exists($prod->{mkdbfile}));
        $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    }
    return;
}

#
# Function: encapsulated_bootdisk_sys()
# Purpose:
#    Determines if the bootdisk is encapsulated on Linux.
# Output Parameters:
#    1: true
#    0: false
# Called by:
#    prestop_sys
sub is_encapsulated_bootdisk_sys {
    my ($prod,$sys) = @_;
    my ($out);
    return 0 if (Cfg::opt('vxunroot'));
    Msg::log("Checking $sys->{sys} for encapsulated bootdisk");
    $out=$sys->cmd('_cmd_stat -c %d /');
    if ($out eq '50944') {
        Msg::log('Encapsulated');
        return 1;
    } else {
        Msg::log('Not encapsulated');
        return 0;
    }
}

sub obsoleted_pkgs_sys {
    my ($prod,$sys,$dir) = @_;
    my ($pkgs,$pkgname,@obsoleted_pkgs,$pkg);

    @obsoleted_pkgs = ();
    $pkgs = $sys->cmd("_cmd_rpm -qf $dir 2>/dev/null | _cmd_grep -v 'not owned'");
    for my $pkg (split(/\n/, $pkgs)) {
        next if ($pkg=~/^\s*$/m);
        next if ($pkg=~/^(VRTSvxvm|VRTSaslapm)/mx);
        $pkgname = $sys->cmd("_cmd_rpm -q -i $pkg | _cmd_grep Name | _cmd_awk '{print \$3}'");
        push (@obsoleted_pkgs, $pkgname) if ($pkgname);
    }
    return \@obsoleted_pkgs;
}

sub obsoleted_asl_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, '/etc/vx/lib/discovery.d');
}

sub obsoleted_apm_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, '/etc/vx/apmkey.d');
}

# Function: postinstall_sys()
# Purpose:
#    Performs some tasks normally done by vxinstall.
# Input Parameters:
#    $sys
# Output Parameters:
#    None
# Called by:
#
sub postinstall_sys {
    my ($prod,$sys) = @_;
    my ($out,$cscript);
    $cscript=CPIC::get('script');
    $sys->cmd("_cmd_vxscriptlog $cscript");
    # Check if DMP is enabled
    $out=$sys->cmd('_cmd_ls -l /dev/vx/dmpconfig');
    $sys->cmd('_cmd_mknod /dev/vx/dmpconfig b 201 1048575') if ($out !~ /^b/m);
    return if (! Cfg::opt('responsefile'));
    return if (! $sys->exists($prod->{mkdbfile}));
    $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    return;
}

# Linux specific
sub backup_vxvm_tunables_postremove_sys {
    my ($prod,$sys) = @_;
    if ($sys->exists('/etc/vx/vxvm_tunables.rpmsave')) {
        $sys->cmd("_cmd_rm -f /etc/vx/vxvm_tunables.cpiupgrade");
        #$sys->cmd("_cmd_cp /etc/vx/vxvm_tunables.rpmsave /etc/vx/vxvm_tunables");
        $sys->cmd("_cmd_cp /etc/vx/vxvm_tunables.rpmsave /etc/vx/vxvm_tunables.cpiupgrade");
    }
    return;
}

package Prod::VM60::SunOS;
@Prod::VM60::SunOS::ISA = qw(Prod::VM60::Common);

sub init_plat {
    my $prod=shift;
    my $padv=$prod->padv();
    $prod->{vxcfgstale}='/tmp/vxvmcfg.stale';
    $prod->{upgrade_file}='/VXVM5.0-UPGRADE/.start_runed';
    if ($prod->{class} =~ /DMP/m) {
        $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
        push @{$prod->{tunables}},
            {
                "name" => "dmp_native_multipathing",
                "desc" => Msg::new("Whether DMP will intercept the I/Os directly on the raw OS paths or not")->{msg},
                "define_object" => $prod,
                "reboot" => 0,
                "type" => "enum",
                "values" => [ "on", "off" ],
                "when_to_set" => 1,
            },
            ;
    } else {
        $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
        $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
        $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSob34 VRTSsfmh41) ];
    }

    $prod->{obsoleted_previous_releases_pkgs} = [ qw(
        VRTSvrdoc VRTSap VRTStep VRTSvrw VRTSweb VRTSvcsvr
        VRTSvrpro VRTSddlpr VRTSvdid VRTSvsvc VRTSvmpro VRTSalloc
        VRTSdcli VRTSvmdoc VRTSvmman VRTScpi SYMClma VRTSspt60
        VRTSaa VRTSmh VRTSccg VRTSobgui VRTSfspro VRTSdsa VRTSsfmh41
        VRTSob34 VRTSobc33 VRTSaslapm60 VRTSat50 VRTSsmf VRTSpbx
        VRTSicsco VRTSvxvm60 VRTSjre15 VRTSjre VRTSsfcpi60SP1PR1 VRTSperl514
        VRTSvlic32
    ) ];

    $prod->{vxdbms3scripts}='/etc/rc?.d/*vxdbms3*';
    $padv->{cmd}{a5kchk}='/usr/lib/vxvm/bin/vxa5kchk';
    $padv->{cmd}{nohup}='/usr/bin/nohup';
    $padv->{cmd}{vxdctl}='/opt/VRTS/bin/vxdctl';
    $padv->{cmd}{vxdisk}='/usr/sbin/vxdisk';
    $padv->{cmd}{vxinfo}='/usr/sbin/vxinfo';
    $padv->{cmd}{vxddladm}='/usr/sbin/vxddladm';
    $padv->{cmd}{vxrelocd}='/usr/lib/vxvm/bin/vxrelocd';
    $padv->{cmd}{vxcached}='/usr/lib/vxvm/bin/vxcached';
    $padv->{cmd}{vxattachd}='/usr/lib/vxvm/bin/vxattachd';
    $padv->{cmd}{vxdg}='/opt/VRTS/bin/vxdg';
    $padv->{cmd}{vxprint}='/opt/VRTS/bin/vxprint';
    $padv->{cmd}{vxscriptlog}='/opt/VRTS/bin/vxscriptlog';
    $padv->{cmd}{vxassist}='/usr/sbin/vxassist';
    $padv->{cmd}{vxdmpadm}='/sbin/vxdmpadm';
    $padv->{cmd}{vxrvg}='/usr/sbin/vxrvg';
    $padv->{cmd}{vxrecover}='/usr/sbin/vxrecover';
    $padv->{cmd}{vxtune}='/usr/sbin/vxtune';
    $padv->{cmd}{vxrlink}='/usr/sbin/vxrlink';
    $padv->{cmd}{vradmin}='/usr/sbin/vradmin';
    $padv->{cmd}{vras_script}='/etc/init.d/vras-vradmind.sh';
    $padv->{cmd}{vxclustadm}='/opt/VRTS/bin/vxclustadm';
    $padv->{cmd}{vxconfigd}='/sbin/vxconfigd';
    $padv->{cmd}{vxconfigbackupd}='/etc/vx/bin/vxconfigbackupd';
    $padv->{cmd}{mknod}='/usr/sbin/mknod';
    $padv->{cmd}{vxgetrootdisk}='/etc/vx/bin/vxgetrootdisk';
    $padv->{cmd}{vxdisksetup}='/usr/lib/vxvm/bin/vxdisksetup';
    return;
}

#
# Function: ask_upgrade_err_sys()
# Purpose:
#    This emulates a task of vxinstall.  It displays a warning message
#    and prompts the user to continue. It is called because upgrade_start
#    had been run, but upgrade_finish was not yet run.
#    Note: It is improbable that someone would have used upgrade_start
#          with CPI.
# Input Parameters:
#    $sys
# Output Parameters:
#    $sys->{vm_install}
# Called by:
#    cli_prestart_config_questions
#
sub ask_upgrade_err_sys {
    my ($prod,$sys) = @_;
    my ($msg,$ayn);
    $msg=Msg::new("A previous upgrade of $prod->{abbr} was not completed on system $sys->{sys}.\nContinuing or running any other $prod->{prod} utilities may severely damage the root file system, and its configuration. By answering no, Volume Manager will not be reinitialized, and vxconfigd will not be started automatically. You will need to start $prod->{prod} manually.\n");
    $msg->warning;
    $msg=Msg::new("\nDo you still want to continue?");
    $ayn=$msg->aynn;
    if ($ayn eq 'N') {
        $sys->{vm_install}='upgrade_start error';
        return;
    }
    $sys->{vm_install}='continue';
    return;
}

# ask configuration questions necessary following installation
#
# Function: cli_prestart_config_questions()
# Purpose:
#    Performs some tasks normally done by vxinstall.
# Input Parameters:
#    None
# Output Parameters:
#    None
# Called by:
#    configure()
sub cli_prestart_config_questions {
    my $sys;
    my $prod=shift;
    my $syslist=CPIC::get('systems');
    my $cfg=Obj::cfg();

    for my $sys (@$syslist) {
        # Don't need to check when we restore or upgrade...
        next if ($cfg->{vm_restore_cfg}{$sys->{sys}});
        next if ($prod->upgrading_vm_sys($sys));
        next if (! $sys->exists($prod->{mkdbfile}));
        # The following should not happen as one should not
        # run upgrade_start with CPI.
        $prod->ask_upgrade_err_sys($sys) if ($sys->exists($prod->{upgrade_file}));
        $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*") if($sys->{vm_install} !~ /error/m);
    }
    return;
}

#
# Function: encapsulated_bootdisk_sys()
# Purpose:
#    Determines if the bootdisk is encapsulated.
# Output Parameters:
#    1: true
#    0: false
sub is_encapsulated_bootdisk_sys {
    my ($prod,$sys) = @_;
    my ($rootpath,$mnttab,$encapsulated,$dir,$rdir,$path);
    return 0 if (Cfg::opt('vxunroot'));
    Msg::log("Checking $sys->{sys} for encapsulated bootdisk");

    # check alt root path
    if (Cfg::opt('rootpath')) {
        $rootpath = Cfg::opt('rootpath');
    } else {
        $rootpath = '/';
    }

    $mnttab = $sys->cmd("_cmd_mount | _cmd_grep ' \/dev\/vx\/dsk\/'");
    $encapsulated=0;
    if ($mnttab) {
        for my $path (split(/\n/, $mnttab)) {
            if($path =~ /^$rootpath\s/mx) {  #check root or alt root
                $encapsulated=1;
                last;
            } else {
                for my $dir (qw(usr var opt)) {
                    $rdir=$rootpath;
                    $rdir=~s/\/$//m;
                    $rdir.='/'.$dir;
                    if ($path =~ /^$rdir\s/m) {
                        $encapsulated=1;
                        last;
                    }
                }
            }
        }
    }

    if ($encapsulated) {
        Msg::log('Encapsulated');
    } else {
        Msg::log('Not encapsulated');
    }
    return $encapsulated;
}

#
# Function: open_volumes_sys()
# Purpose:
#       Determines if any VM volumes are open.
# Input Parameters:
#       References $sys
sub open_volumes_sys {
    my ($prod,$sys,$action) = @_;
    my ($voldmode,$msg,$cfg,@volumes,$vlist,$volume,$pkg,$fs,$rc);
    return 0 if ($sys->{encap});
    $cfg=Obj::cfg();

    # skip open volume check if alt root disk upgrade
    if (($cfg->{opt}{rootpath})) {
        Msg::log("Checking $sys->{sys} for open volumes is skipped for Solaris alternate root disk installation");
        return 0;
    }

    $cfg->{vm_no_open_vols} ||=0;

    $voldmode=$sys->cmd('_cmd_vxdctl mode 2> /dev/null');
    if ( $voldmode !~ /mode: enabled/m ) {
        if ( $cfg->{vm_no_open_vols} ) {
            $msg=Msg::new("Cannot check for open volumes on $sys->{sys} because the vxconfigd process is not in enabled mode.  However, you set \$CFG{vm_no_open_vols} to be non-zero in the response file, which indicates that you are affirming there are no open volumes on system $sys->{sys}.");
        } else {
            $msg=Msg::new("Cannot check for open volumes on $sys->{sys} because the vxconfigd process is not in enabled mode. You must affirm that there are no open volumes if you want to continue.");
        }
        $sys->push_warning($msg);
        return 0;
    }

    Msg::log("Checking $sys->{sys} for open volumes");
    $vlist=$sys->cmd('_cmd_vxprint -QAqne v_open 2>/dev/null');
    for my $volume (split(/\n/,$vlist)) {
        # Filter out any WARNING message from an SF Basic installation
        next if ($volume=~/VxVM vxprint WARNING/m);
        push(@volumes,$volume);
    }

    if ($#volumes >= 0) {
        $vlist=join(' ', @volumes);
        Msg::log("open volumes: $vlist");

        # if any open volumes, check whether any zones based on the open volumes.
        $fs=$sys->prod('FS60');
        $rc = $fs->vxfs_vxvm_zone_check_sys($sys);
        if (($rc == 2 || $rc == 3) && !$sys->{vxfs_vxvm_zone_check_done}) {
            # if zones' root path are based on vxfs file system.
            # do not stop processes for VM and FS, ask for reboot
            $pkg=$sys->pkg('VRTSvxvm60');
            $pkg->set_value('stopprocs',undef);
            $pkg->set_value('donotrmonupgrade',1);
            $pkg=$sys->pkg('VRTSvxfs60');
            $pkg->set_value('stopprocs',undef);
            $sys->set_value('reboot', 1);
            $fs->show_warning_zones_on_vxfs_sys($sys, $action) if ($rc==2);
            $fs->show_warning_zones_on_vxvm_sys($sys, $action) if ($rc==3);
        } elsif ($rc == 1 && !$sys->{vxfs_vxvm_zone_check_done}) {
            # exit if zones on CFS/CVM.
            $fs->show_error_zones_on_cfs_sys($sys, $action);
        } else {
            # exit if no zones on vxfs file system.
            $msg=Msg::new("Cannot proceed because the following open volumes exist on system $sys->{sys}:\n\t$vlist");
            $sys->push_error($msg);
        }
        $sys->set_value('vxfs_vxvm_zone_check_done',1);
        return 1;
    } else {
        Msg::log('None');
        return 0;
    }
}

sub obsoleted_pkgs_sys {
    my ($prod,$sys,$dir) = @_;
    my ($pkg1,$rootpath,$saved_pkg,$len,$pkgs,@obsoleted_pkgs,$base,$pkg,$saved_len,$last_pkg);

    @obsoleted_pkgs = ();
    $rootpath='-R '.Cfg::opt('rootpath') if (Cfg::opt('rootpath'));
    $pkgs = $sys->cmd("_cmd_pkgchk $rootpath -l -p '$dir' 2>/dev/null | _cmd_grep -v '^[ETCRP]'");
    for my $pkg (split(/\s+/m, $pkgs)) {
        next if ($pkg =~ /^\s*$/m);
        if (length($pkg) < 15) {
            push(@obsoleted_pkgs,$pkg) unless ($pkg=~/^(VRTSvxvm|VRTSaslapm)$/mx);
        } else {
            # should contain two or more package names in the string, seperate it.
            # For example:  VRTSHDS-DF600-aslVRTSHDS99xx should be seperated to 'VRTSHDS-DF600-asl' and 'VRTSHDS99xx'.
            $last_pkg=0;
            while (1) {
                $base=substr($pkg, 0, 8);
                $pkgs=$sys->cmd("_cmd_pkginfo | _cmd_grep $base | _cmd_awk '{print \$2}'");
                $saved_len=0;
                for my $pkg1 (split(/\n/,$pkgs)) {
                    next if ($pkg1 =~ /^\s*$/m);
                    if ($pkg eq $pkg1) {
                        $last_pkg=1;
                        $saved_pkg=$pkg1;
                        last;
                    }
                    if ($pkg=~/^$pkg1/m) {
                        $len=length($pkg1);
                        if ($len>$saved_len) {
                            $saved_len=$len;
                            $saved_pkg=$pkg1;
                        }
                    }
                }
                push(@obsoleted_pkgs,$saved_pkg) unless ($pkg=~/^(VRTSvxvm|VRTSaslapm)$/mx);
                last if ($last_pkg==1);
                $pkg=~s/^$saved_pkg//mx;
            }
        }
    }
    return \@obsoleted_pkgs;
}

sub obsoleted_asl_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, '/etc/vx/lib/discovery.d');
}

sub obsoleted_apm_pkgs_sys {
    my ($prod,$sys) = @_;
    return $prod->obsoleted_pkgs_sys($sys, '/etc/vx/apmkey.d');
}

# Function: postinstall_sys()
# Purpose:
#    Performs some tasks normally done by vxinstall.
# Input Parameters:
#    $sys
# Output Parameters:
#    None
# Called by:
#
sub postinstall_sys {
    my ($prod,$sys) = @_;
    my ($msg);
    my $cfg=Obj::cfg();
    my $cscript=CPIC::get('script');
    $sys->cmd("_cmd_vxscriptlog $cscript") if ($sys->exists($prod->{mkdbfile}));
    return if (! Cfg::opt('responsefile'));
    return if ($cfg->{vm_restore_cfg}{$sys->{sys}});
    return if (! $sys->exists($prod->{mkdbfile}));
    if ($sys->exists($prod->{upgrade_file})) {
        $msg=Msg::new("It appears upgrade_start was previously executed on system $sys->{sys} without completing the task by running upgrade_finish.\nAs this is an unattended installation, you cannot be prompted for instructions.  Therefore, $prod->{abbr} will not be reinitialized, and vxconfigd will not be brought up automatically.  You will need to bring up the system manually.");
        $msg->log;
        $sys->push_warning($msg);
        $sys->{vm_install}='upgrade_start error';
        return;
    }
    $sys->cmd("_cmd_rmr $prod->{rdir}/disks $prod->{rdir}/disk.d/*");
    return;
}

#sub web_preinstall_messages {
#    my ($msg,$restore_cnt,$sys,$vxvm,$prod,$cpic,$padv);
#    $prod = shift;
#
#    $padv = $prod->padv();
#    return if Cfg::opt("responsefile");
#
#    $vxvm = $prod->pkg($prod->{mainpkg},$prod->{padv});
#    $vxvm->{vm_conf_savedir} = $padv->media_pkginfovalue($vxvm,"CONF_SAVEDIR");
#    $vxvm->{vm_pkg_rm_hint} = $padv->media_pkginfovalue($vxvm,"PKG_RM_HINT");
#    $vxvm->{vm_pkg_rm_hint} = "$vxvm->{vm_conf_savedir}/$vxvm->{vm_pkg_rm_hint}";
#
#    for $sys(@{$cpic->{systems}}) {
#        if($sys->exists($vxvm->{vm_pkg_rm_hint})) {
#            $prod->tsub("web_restorecfg_sys", $sys);
#        }
#    }
#}
#
#sub cli_preinstall_messages {
#    my ($msg,$sys,$vxvm,$prod,$cpic,$padv);
#    $prod = shift;
#
#    $padv = $prod->padv();
#    return if Cfg::opt("responsefile");
#    $vxvm = $prod->pkg($prod->{mainpkg},$prod->{padv});
#    $vxvm->{vm_conf_savedir} = $padv->media_pkginfovalue($vxvm,"CONF_SAVEDIR");
#    $vxvm->{vm_pkg_rm_hint} = $padv->media_pkginfovalue($vxvm,"PKG_RM_HINT");
#    $vxvm->{vm_pkg_rm_hint} = "$vxvm->{vm_conf_savedir}/$vxvm->{vm_pkg_rm_hint}";
#
#    for $sys(@{$cpic->{systems}}) {
#        if($sys->exists($vxvm->{vm_pkg_rm_hint})) {
#            $prod->tsub("restorecfg_sys", $sys);
#        }
#    }
#}
sub preinstall_messages {
    my ($msg,$sys,$vxvm,$prod,$padv,$syslist);
    $prod = shift;
    $syslist=CPIC::get('systems');
    $padv = $prod->padv();
    return if Cfg::opt('responsefile');
    $vxvm = $prod->pkg($prod->{mainpkg});
    $vxvm->{vm_conf_savedir} = $padv->media_pkginfovalue($vxvm,'CONF_SAVEDIR');
    $vxvm->{vm_conf_savedir} ||= '/VXVM-CFG-BAK';

    $vxvm->{vm_pkg_rm_hint} = $padv->media_pkginfovalue($vxvm,'PKG_RM_HINT');
    $vxvm->{vm_pkg_rm_hint} = "$vxvm->{vm_conf_savedir}/$vxvm->{vm_pkg_rm_hint}";

    for my $sys (@$syslist) {
        if($sys->exists($vxvm->{vm_pkg_rm_hint})) {
            $prod->restorecfg_sys($sys);
        }
    }
    return;
}

#
# Function: preinstall_sys()
# Purpose:
#    Performs some VRTSvxvm pkgadd request script processing
#
# Input Parameters:
#    $sys
# Output Parameters:
#    NONE
# Called by:
#
sub preinstall_sys {
    my ($prod,$sys) = @_;
    my ($cfg);

    $cfg=Obj::cfg();

    if($cfg->{vm_restore_cfg}{$sys->{sys}}) {
        if($sys->exists($prod->{vxcfgstale})) {
            $sys->cmd("_cmd_rmr $prod->{vxcfgstale}");
        }
    } else {
        # Create /tmp/vxvmcfg.stale on required systems.
        $sys->cmd("_cmd_touch $prod->{vxcfgstale}");
        $sys->cmd("_cmd_chmod 0777 $prod->{vxcfgstale}");
    }
    return '';
}

#sub web_ask_restore_cfg {
#    my ($web);
#    $web=Obj::web();
#    my ($prod,$sys) = @_;
#    $web->tsub("web_script_form","ask_restore_cfg",$prod,$sys);
#    return $web->{restore_cfg};
#}
#
#sub web_restorecfg_sys {
#    my ($prod,$sys) = @_;
#    my ($ayn,$cfg,$help,$msg);
#
#    $cfg=Obj::cfg();
#
#    if($sys->exists($prod->{vxcfgstale})) {
#        $sys->cmd("_cmd_rmr $prod->{vxcfgstale}");
#    }
#
#    $ayn = $prod->tsub("web_ask_restore_cfg",$sys);
#    if($ayn) {
#        $cfg->{vm_restore_cfg}{$sys->{sys}}=1;
#    } else {
#        $cfg->{vm_restore_cfg}{$sys->{sys}}=0;
#        $sys->cmd("_cmd_touch $prod->{vxcfgstale}");
#        $sys->cmd("_cmd_chmod 0777 $prod->{vxcfgstale}");
#    }
#
#    return $cfg->{vm_restore_cfg}{$sys->{sys}};
#}

sub restorecfg_sys {
    my ($prod,$sys) = @_;
    my ($ayn,$cfg,$help,$msg);

    $cfg=Obj::cfg();

    if($sys->exists($prod->{vxcfgstale})) {
        $sys->cmd("_cmd_rmr $prod->{vxcfgstale}");
    }
    $msg = Msg::new("A copy of a previous $prod->{abbr} configuration is present on the system $sys->{sys}.\n");
    $msg->print;
    $help = Msg::new("If you are upgrading $prod->{abbr} and want to use the backup copy of the $prod->{prod} configuration, enter 'y'.  Otherwise, if this is a new installation, enter 'n'.");
    $msg = Msg::new("Do you want to restore and reuse the previous $prod->{abbr} configuration of system $sys->{sys}");
    while (1) {
        $ayn = $msg->ayny($help,0);
        if($ayn eq 'Y') {
            $cfg->{vm_restore_cfg}{$sys->{sys}}=1;
            last;
        } elsif($ayn eq 'N') {
            $cfg->{vm_restore_cfg}{$sys->{sys}}=0;
            $sys->cmd("_cmd_touch $prod->{vxcfgstale}");
            $sys->cmd("_cmd_chmod 0777 $prod->{vxcfgstale}");
            last;
        }
    }
    return $cfg->{vm_restore_cfg}{$sys->{sys}};
}

sub responsefile_comments {
    # Each response file comment is a 4 item list
    # item 1 is the comment, previously translated in the prior line
    # item 2 a 0=optional, 1=required
    # item 3 is 0=scalar, 1=list
    # item 4 is 0=1d, 1=2d is SYSTEM, other=other second dimension
    my ($prod,$cmt,$edr);
    $prod=shift;
    $edr=Obj::edr();
    $cmt=Msg::new("This variable indicates that the user should not be asked if there are any open volumes when vxconfigd is not enabled. Such prompts are asked during uninstallations. (1: affirms there are no open volumes on the system)");
    $edr->{rfc}{vm_no_open_vols}=[$cmt->{msg},0,0,0];
    $cmt=Msg::new("This variable indicates if a previous $prod->{abbr} configuration should be restored (0: don't restore; 1: do restore.) [Solaris only]");
    $edr->{rfc}{vm_restore_cfg}=[$cmt->{msg},1,0,1];
    return;
}

sub verify_responsefile {
    my ($cfg,$msg,$sys);
    $cfg=Obj::cfg();
    for my $sys (@{$cfg->{systems}}) {
        if (defined($cfg->{vm_restore_cfg}{$sys}) &&
            ($cfg->{vm_restore_cfg}{$sys} != 0) &&
            ($cfg->{vm_restore_cfg}{$sys} != 1)) {
                 $msg=Msg::new("vm_restore_cfg has invalid value");
                 $msg->die();
         }
    }
    return;
}

sub suppress_mpio_sys {
    my ($prod,$sys) = @_;
    $sys->cmd('_cmd_vxdmpadm getctlr all | _cmd_grep scsi_vhci >/dev/null 2>&1');
    if (!EDR::cmdexit()) {
        $sys->cmd('_cmd_vxddladm assign names >/dev/null 2>&1');
    }
    return 1;
}

package Prod::VM60::SolSparc;
@Prod::VM60::SolSparc::ISA = qw(Prod::VM60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(4.1.2 5.0 5.1 6.0)];
    return;
}

package Prod::VM60::Sol11sparc;
@Prod::VM60::Sol11sparc::ISA = qw(Prod::VM60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
    $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];

    return;
}

package Prod::VM60::Solx64;
@Prod::VM60::Solx64::ISA = qw(Prod::VM60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(5.0.3 5.1 6.0)];
    $prod->{zru_releases}=[qw(5.0 5.1 6.0)];
    return;
}

package Prod::VM60::Sol11x64;
@Prod::VM60::Sol11x64::ISA = qw(Prod::VM60::SunOS);

sub init_padv {
    my $prod=shift;
    $prod->{upgradevers}=[qw(6.0.10)];
    $prod->{zru_releases}=[qw(6.0.10)];
    $prod->{allpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
    $prod->{minpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60) ];
    $prod->{recpkgs}=[ qw(VRTSvxvm60 VRTSaslapm60 VRTSsfmh41) ];
    return;
}

1;
