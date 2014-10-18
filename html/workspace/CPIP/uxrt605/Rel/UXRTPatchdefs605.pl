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

package Rel::UXRT601::AIX;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT603", "VRTSperl_5_14_2_8");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT603", "VRTSamf_6_0_300_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT603", "VRTScavf_6_0_300_0");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT603", "VRTSsfcpi601_6_0_300_0");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT603", "VRTSdbed_6_0_300_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT603", "VRTSvcs_6_0_300_0");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT603", "VRTSvcsag_6_0_300_0");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT603", "VRTSvcsea_6_0_300_0");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT603", "VRTSvxfen_6_0_300_0");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT603", "VRTSvxfs_6_0_300_0");
    $rel->define_rp_patches("VRTSvxvm60",   "all", "UXRT603", "VRTSvxvm_6_0_300_0");

    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "VRTSamf_6_0_500_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT605", "VRTScavf_6_0_500_0");
    $rel->define_rp_patches("VRTSdbac60", "all", "UXRT605", "VRTSdbac_6_0_500_0");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT605", "VRTSdbed_6_0_500_0");
    $rel->define_rp_patches("VRTSgab60", "all", "UXRT605", "VRTSgab_6_0_500_0");
    $rel->define_rp_patches("VRTSglm60", "all", "UXRT605", "VRTSglm_6_0_500_0");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "VRTSllt_6_0_500_0");
    $rel->define_rp_patches("VRTSodm60", "all", "UXRT605", "VRTSodm_6_0_500_0");
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "VRTSperl_5_14_2_20");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "VRTSsfcpi601_6_0_500_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT605", "VRTSvcs_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "VRTSvcsag_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT605", "VRTSvcsea_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT605", "VRTSvxfen_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "VRTSvxfs_6_0_500_0");
    $rel->define_rp_patches("VRTSvxvm60",   "all", "UXRT605", "VRTSvxvm_6_0_500_0");
    $rel->define_rp_patches("VRTSfsadv60",   "all", "UXRT605", "VRTSfsadv_6_0_500_0");
}

package Rel::UXRT601::HPUX;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT603", "PVCO_03982");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT603", "PVKL_03971", "PVCO_03972");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT603", "PVCO_03974" ,"PVKL_03975");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT603", "PVCO_03976");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT603", "PVCO_03977");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT603", "PVCO_03978");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT603", "PVKL_03980");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT603", "PVKL_03979");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT603", "PVCO_03973");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT603", "PVCO_03981");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT603", "PVCO_03970");

    $rel->define_rp_patches("VRTScavf60", "all", "UXRT605", "PVCO_04032");
    $rel->define_rp_patches("VRTSodm60", "all", "UXRT605", "PVKL_04031");
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "PVCO_03982");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "PVKL_04003", "PVCO_04004");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT605", "PVCO_04005", "PVKL_04006");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT605",  "PVCO_04007");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "PVCO_04008");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT605", "PVCO_04009");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT605", "PVCO_04023");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "PVCO_04024");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT605", "PVNE_04016");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "PVNE_04017");
    $rel->define_rp_patches("VRTSgab60", "all", "UXRT605", "PVNE_04021");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "PVNE_04022");
    $rel->define_rp_patches("VRTSdbac60", "all", "UXRT605", "PVCO_04020");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT605", "PVCO_04033");
}

package Rel::UXRT601::Linux;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "VRTSamf_6_0_500_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT605", "VRTScavf_6_0_500_0");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT605", "VRTSfsadv_6_0_500_0");
    $rel->define_rp_patches("VRTSglm60", "all", "UXRT605", "VRTSglm_6_0_500_0");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "VRTSllt_6_0_500_0");
    $rel->define_rp_patches("VRTSlvmconv60", "all", "UXRT605", "VRTSlvmconv_6_0_500_0");
    $rel->define_rp_patches("VRTSodm60", "all", "UXRT605", "VRTSodm_6_0_500_0");
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "VRTSperl_5_14_2_20");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "VRTSsfcpi601_6_0_500_0");
    $rel->define_rp_patches("VRTSspt60", "all", "UXRT605", "VRTSspt_6_0_500_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT605", "VRTSvcs_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "VRTSvcsag_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT605", "VRTSvcsea_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsvmw60", "all", "UXRT605", "VRTSvcsvmw_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT605", "VRTSvxfen_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "VRTSvxfs_6_0_500_0");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT605", "VRTSvxvm_6_0_500_0");
    $rel->define_rp_patches("VRTSdbac60", "all", "UXRT605", "VRTSdbac_6_0_500_0");
    $rel->define_rp_patches("VRTSgab60","all","UXRT605","VRTSgab_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsdr60","all","UXRT605","VRTSvcsdr_6_0_500_0");
    $rel->define_rp_patches("VRTSdbed60","all","UXRT605","VRTSdbed_6_0_500_0");
}

package Rel::UXRT601::SLES11x8664;

sub define_patches {
    my $rel=shift;
    Rel::UXRT601::Linux::define_patches($rel);
    $rel->define_rp_patches("VRTSgms60","all","UXRT605","VRTSgms_6_0_400_100");
}

package Rel::UXRT601::Sol11sparc;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSvlic32", "all", "UXRT605", "VRTSvlic_3_02_61_005");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "VRTSamf_6_0_500_0");
    $rel->define_rp_patches("VRTSaslapm60", "all", "UXRT605", "VRTSaslapm_6_0_500_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT605", "VRTScavf_6_0_500_0");
    $rel->define_rp_patches("VRTSdbac60", "all", "UXRT605", "VRTSdbac_6_0_500_0");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT605", "VRTSdbed_6_0_500_0");
    $rel->define_rp_patches("VRTSgab60", "all", "UXRT605", "VRTSgab_6_0_500_0");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "VRTSllt_6_0_500_0");
    $rel->define_rp_patches("VRTSodm60", "all", "UXRT605", "VRTSodm_6_0_500_0");

    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "VRTSperl_5_14_2_20");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "VRTSsfcpi601_6_0_500_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT605", "VRTSvcs_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "VRTSvcsag_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT605", "VRTSvcsea_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT605", "VRTSvxfen_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "VRTSvxfs_6_0_500_0");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT605", "VRTSvxvm_6_0_500_0");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT605", "VRTSfsadv_6_0_500_0");
}

package Rel::UXRT601::Sol11x64;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSvlic32", "all", "UXRT605", "VRTSvlic_3_02_61_005");
    $rel->define_rp_patches("VRTSaslapm60", "all", "UXRT605", "VRTSaslapm_6_0_500_0");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "VRTSamf_6_0_500_0");
    $rel->define_rp_patches("VRTScavf60", "all", "UXRT605", "VRTScavf_6_0_500_0");
    $rel->define_rp_patches("VRTSdbac60", "all", "UXRT605", "VRTSdbac_6_0_500_0");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT605", "VRTSdbed_6_0_500_0");
    $rel->define_rp_patches("VRTSgab60", "all", "UXRT605", "VRTSgab_6_0_500_0");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "VRTSllt_6_0_500_0");
    $rel->define_rp_patches("VRTSodm60", "all", "UXRT605", "VRTSodm_6_0_500_0");

    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "VRTSperl_5_14_2_20");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "VRTSsfcpi601_6_0_500_0");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT605", "VRTSvcs_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "VRTSvcsag_6_0_500_0");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT605", "VRTSvcsea_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT605", "VRTSvxfen_6_0_500_0");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "VRTSvxfs_6_0_500_0");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT605", "VRTSvxvm_6_0_500_0");
}

package Rel::UXRT601::SolSparc;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT603", "149699_01");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT603", "148481_02");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT603", "148490_02");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT603", "148492_01");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT603", "148496_01");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT603", "148497_01");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT603", "148498_01");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT603", "149695_01");
    $rel->define_rp_patches("VRTScavf60", "5.10", "UXRT603", "149691_01");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT603", "149696_01");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT603", "149702_01");

    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "148481_03");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT605", "148490_07");
    $rel->define_rp_patches("VRTSvcs60", "all",  "UXRT605", "148492_02");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "148496_02");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT605", "148497_02");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "148498_02");
    $rel->define_rp_patches("VRTScavf60", "5.10", "UXRT605", "149691_02");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT605", "149695_02");
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "149699_02");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "149702_02");
    $rel->define_rp_patches("VRTSodm60", "all",  "UXRT605", "149816_02");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "150710_01");
    $rel->define_rp_patches("VRTSgab60", "all", "UXRT605", "150706_01");
    $rel->define_rp_patches("VRTSdbac60", "all", "UXRT605", "150720_01");
    $rel->define_rp_patches("VRTSdbed60", "all", "UXRT605", "149696_02");
    $rel->define_rp_patches("VRTSfsadv60", "all", "UXRT605", "150716_01");
}

package Rel::UXRT601::Solx64;

sub define_patches {
    my $rel=shift;
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT603", "149698_01");
    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT603", "148482_02");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT603", "148491_02");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT603", "148494_01");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT603", "148493_01");
    $rel->define_rp_patches("VRTSvcsea60", "all", "UXRT603", "149693_01");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT603", "148495_01");
    $rel->define_rp_patches("VRTSvxfen60", "all", "UXRT603", "149694_01");
    $rel->define_rp_patches("VRTScavf60", "5.10", "UXRT603", "149692_01");
    $rel->define_rp_patches("VRTSdbed60", "5.10", "UXRT603", "149697_01");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT603", "149703_01");

    $rel->define_rp_patches("VRTSvxfs60", "all", "UXRT605", "148482_03");
    $rel->define_rp_patches("VRTSvxvm60", "all", "UXRT605", "148491_07");
    $rel->define_rp_patches("VRTSvcsag60", "all", "UXRT605", "148493_02");
    $rel->define_rp_patches("VRTSvcs60", "all", "UXRT605", "148494_02");
    $rel->define_rp_patches("VRTSamf60", "all", "UXRT605", "148495_02");
    $rel->define_rp_patches("VRTScavf60", "5.10", "UXRT605", "149692_02");
    $rel->define_rp_patches("VRTSvcsea60", "5.10", "UXRT605", "149693_02");
    $rel->define_rp_patches("VRTSvxfen60", "5.10", "UXRT605", "149694_02");
    $rel->define_rp_patches("VRTSperl514", "all", "UXRT605", "149698_02");
    $rel->define_rp_patches("VRTSsfcpi601", "all", "UXRT605", "149703_02");
    $rel->define_rp_patches("VRTSodm60", "all",  "UXRT605", "149817_02");
    $rel->define_rp_patches("VRTSllt60", "all", "UXRT605", "150718_01");
    $rel->define_rp_patches("VRTSgab60", "all", "UXRT605", "150707_01");
    $rel->define_rp_patches("VRTSdbac60", "5.10", "UXRT605", "150721_01");
    $rel->define_rp_patches("VRTSdbed60", "5.10", "UXRT605", "149697_02");
}

1;

