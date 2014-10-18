
package Rel::UXRT60::AIX;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT60RP1", "VRTSamf_6_0_001_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT60RP1", "VRTSvcs_6_0_001_0");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT60RP1", "VRTSvxfs_6_0_001_0");
    $rel->define_rp_patches("VRTSvxvm60",   "all", "UXRT60RP1", "VRTSvxvm_6_0_001_0");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT60RP1", "VRTSfsadv_6_0_001_0");
    $rel->define_rp_patches("VRTSob34", "all", "UXRT60RP1", "VRTSob_3_4_526_2");
    $rel->define_rp_patches("VRTSvbs60", "all", "UXRT60RP1", "VRTSvbs_6_0_001_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT60RP1", "VRTScavf_6_0_001_0");
    $rel->define_rp_patches("VRTSsfcpi60", "all", "UXRT60RP1", "VRTSsfcpi60_6_0_001_0");
}

package Rel::UXRT60::HPUX;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT60RP1", "PVKL_03951","PVCO_03952");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT60RP1", "PVCO_03937","PVKL_03938");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT60RP1", "PVCO_03944");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT60RP1", "PVKL_03942");
    $rel->define_rp_patches("VRTSob34", "all", "UXRT60RP1", "PVCO_03955");
    $rel->define_rp_patches("VRTSvbs60", "all", "UXRT60RP1", "PVCO_03948");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT60RP1", "PVCO_03950");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT60RP1", "PVCO_03954");
    $rel->define_rp_patches("VRTSsfcpi60", "all", "UXRT60RP1", "PVCO_03953");
}

package Rel::UXRT60::Linux;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT60RP1", "VRTSamf_6_0_001_0");
    $rel->define_rp_patches("VRTSfssdk60", "all", "UXRT60RP1", "VRTSfssdk_6_0_001_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT60RP1", "VRTSvcs_6_0_001_0");   
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT60RP1", "VRTSvxfs_6_0_001_0");
    $rel->define_rp_patches("VRTSvxvm60",   "all", "UXRT60RP1", "VRTSvxvm_6_0_001_0");
    $rel->define_rp_patches("VRTSlvmconv60", "all", "UXRT60RP1", "VRTSlvmconv_6_0_001_0");
    $rel->define_rp_patches("VRTSob34", "all", "UXRT60RP1", "VRTSob_3_4_528_0");
    $rel->define_rp_patches("VRTSvbs60", "all", "UXRT60RP1", "VRTSvbs_6_0_001_0");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT60RP1", "VRTSfsadv_6_0_001_0");
    $rel->define_rp_patches("VRTSsvs60", "all", "UXRT60RP1", "VRTSsvs_6_0_001_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT60RP1", "VRTScavf_6_0_001_0");
    $rel->define_rp_patches("VRTSsfcpi60", "all", "UXRT60RP1", "VRTSsfcpi60_6_0_001_0");
}

package Rel::UXRT60::SolSparc;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSvxfs60", "5.10", "UXRT60RP1", "147852_01");
    $rel->define_rp_patches("VRTSfsadv60", "5.10", "UXRT60RP1", "148452_01");
    $rel->define_rp_patches("VRTSob34", "5.10", "UXRT60RP1", "148462_01");
    $rel->define_rp_patches("VRTSvxvm60", "5.10", "UXRT60RP1", "147853_02");
    $rel->define_rp_patches("VRTSvcs60", "5.10", "UXRT60RP1", "146917_01");
    $rel->define_rp_patches("VRTSvcsag60", "5.10", "UXRT60RP1", "146918_01");
    $rel->define_rp_patches("VRTSamf60", "5.10", "UXRT60RP1", "147883_01");
    $rel->define_rp_patches("VRTSvbs60", "5.10", "UXRT60RP1", "147887_01");
    $rel->define_rp_patches("VRTSsvs60", "5.10", "UXRT60RP1", "148453_01");
    $rel->define_rp_patches("VRTScavf60", "5.10", "UXRT60RP1", "148457_01");
    $rel->define_rp_patches("VRTSsfcpi60", "5.10", "UXRT60RP1", "147893_01");   
}

package Rel::UXRT60::Solx64;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSvxfs60", "5.10", "UXRT60RP1", "147855_01");
    $rel->define_rp_patches("VRTSvxvm60", "5.10", "UXRT60RP1", "147854_02");
    $rel->define_rp_patches("VRTSob34", "5.10", "UXRT60RP1", "148463_01");
    $rel->define_rp_patches("VRTSvcs60", "5.10", "UXRT60RP1", "147849_01");
    $rel->define_rp_patches("VRTSvcsag60", "5.10", "UXRT60RP1", "147850_01");
    $rel->define_rp_patches("VRTSamf60", "5.10", "UXRT60RP1", "147886_01");
    $rel->define_rp_patches("VRTSvbs60", "5.10", "UXRT60RP1", "147888_01");
    $rel->define_rp_patches("VRTSsvs60", "5.10", "UXRT60RP1", "148454_01");
    $rel->define_rp_patches("VRTScavf60", "5.10", "UXRT60RP1", "148458_01");
    $rel->define_rp_patches("VRTSsfcpi60", "5.10", "UXRT60RP1", "148450_01");   
}

1;

