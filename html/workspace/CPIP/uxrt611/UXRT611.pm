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
use strict;

package CPIC;

{   # Prevent 'Subroutine ... redefined' warning to pacify UnitTest report tool
    no warnings qw(redefine);
    sub maintenance_release {'6.1.1'}
    sub maintenance_version {'UXRT611'}
    sub base_requires {'6.1.0'}
}

package MR::UXRT611::Common;
@MR::UXRT611::Common::ISA = qw(MR);

sub init_common {
    my ($mr) = @_;
    my $rel = $mr->rel;

    $rel->{vers} = '6.1.1.000';
    $rel->{titlevers} = '6.1.1';
    $rel->{patches} = 1;
    $rel->{currentrelease}="UXRT611";      
}

sub init_realse {
    my ($mr) = @_;
    my $rel = $mr->rel;
}

sub define_patches {
}

package MR::UXRT611::AIX;
@MR::UXRT611::AIX::ISA = qw(MR::UXRT611::Common);
sub define_patches {
    my $mr=shift;
    $mr->define_mr_patches("VRTSvcsag61", "all", "UXRT611", "VRTSvcsag_6_1_1_0");
    $mr->define_mr_patches("VRTSvxfen61", "all", "UXRT611", "VRTSvxfen_6_1_1_0");
    $mr->define_mr_patches("VRTSvcsea61", "all", "UXRT611", "VRTSvcsea_6_1_1_0");
    $mr->define_mr_patches("VRTSvcs61", "all", "UXRT611", "VRTSvcs_6_1_1_0");
    $mr->define_mr_patches("VRTSllt61", "all", "UXRT611", "VRTSllt_6_1_1_0");
    $mr->define_mr_patches("VRTSamf61", "all", "UXRT611", "VRTSamf_6_1_1_0");
    $mr->define_mr_patches("VRTSvcsvmw61", "all", "UXRT611", "VRTSvcsvmw_6_1_1_0");
    $mr->define_mr_patches("VRTSdbac61", "all", "UXRT611", "VRTSdbac_6_1_1_0");
    $mr->define_mr_patches("VRTSdbed61", "all", "UXRT611", "VRTSdbed_6_1_1_0");
    $mr->define_mr_patches("VRTSvxfs61", "all", "UXRT611", "VRTSvxfs_6_1_1_0");
    $mr->define_mr_patches("VRTSvxvm61", "all", "UXRT611", "VRTSvxvm_6_1_1_0");
    $mr->define_mr_patches("VRTSsfcpi61", "all", "UXRT611", "VRTSsfcpi61_6_1_1_0");
    $mr->define_mr_patches("VRTScps61", "all", "UXRT611", "VRTScps_6_1_1_0");
}

package MR::UXRT611::Linux;
@MR::UXRT611::Linux::ISA = qw(MR::UXRT611::Common);
sub define_patches {
    my $mr=shift;
    $mr->define_mr_patches("VRTSvcsag61", "all", "UXRT611", "VRTSvcsag_6_1_1_0");
    $mr->define_mr_patches("VRTSvxfen61", "all", "UXRT611", "VRTSvxfen_6_1_1_0");
    $mr->define_mr_patches("VRTSvcsea61", "all", "UXRT611", "VRTSvcsea_6_1_1_0");
    $mr->define_mr_patches("VRTSvcs61", "all", "UXRT611", "VRTSvcs_6_1_1_0");
    $mr->define_mr_patches("VRTSllt61", "all", "UXRT611", "VRTSllt_6_1_1_0");
    $mr->define_mr_patches("VRTSamf61", "all", "UXRT611", "VRTSamf_6_1_1_0");
    $mr->define_mr_patches("VRTSvcsvmw61", "all", "UXRT611", "VRTSvcsvmw_6_1_1_0");
    $mr->define_mr_patches("VRTSvcswiz61", "all", "UXRT611", "VRTSvcswiz_6_1_1_0");
    $mr->define_mr_patches("VRTSdbac61", "all", "UXRT611", "VRTSdbac_6_1_1_0");
    $mr->define_mr_patches("VRTSdbed61", "all", "UXRT611", "VRTSdbed_6_1_1_0");
    $mr->define_mr_patches("VRTSvxfs61", "all", "UXRT611", "VRTSvxfs_6_1_1_0");
    $mr->define_mr_patches("VRTSodm61", "all", "UXRT611", "VRTSodm_6_1_1_0");
    $mr->define_mr_patches("VRTSvxvm61", "all", "UXRT611", "VRTSvxvm_6_1_1_0");
    $mr->define_mr_patches("VRTSsfcpi61", "all", "UXRT611", "VRTSsfcpi61_6_1_1_0");
    $mr->define_mr_patches("VRTScps61", "all", "UXRT611", "VRTScps_6_1_1_0");
    $mr->define_mr_patches("VRTSlvmconv61", "all", "UXRT611", "VRTSlvmconv_6_1_1_0");
    $mr->define_mr_patches("VRTSfsadv61", "all", "UXRT611", "VRTSfsadv_6_1_1_0");
    $mr->define_mr_patches("VRTScavf61", "all", "UXRT611", "VRTScavf_6_1_1_0");
}

package MR::UXRT611::Sol10sparc;
@MR::UXRT611::Sol10sparc::ISA = qw(MR::UXRT611::Common);

sub define_patches {
    my $mr=shift;
    $mr->define_mr_patches("VRTSvcsag61", "all", "UXRT611", "150728_01");
    $mr->define_mr_patches("VRTSvxfen61", "all", "UXRT611", "150732_01");
    $mr->define_mr_patches("VRTSvcsea61", "all", "UXRT611", "150733_01");
    $mr->define_mr_patches("VRTSvcs61", "all", "UXRT611", "150729_01");
    $mr->define_mr_patches("VRTSllt61", "all", "UXRT611", "150730_01");
    $mr->define_mr_patches("VRTSamf61", "all", "UXRT611", "150726_01");
    $mr->define_mr_patches("VRTSvcsvmw61", "all", "UXRT611", "150727_01");
    $mr->define_mr_patches("VRTSdbac61", "all", "UXRT611", "150734_01");
    $mr->define_mr_patches("VRTSdbed61", "all", "UXRT611", "150735_01");
    $mr->define_mr_patches("VRTSvxfs61", "all", "UXRT611", "150736_01");
    $mr->define_mr_patches("VRTSvxvm61", "all", "UXRT611", "150717_05");
    $mr->define_mr_patches("VRTSsfcpi61", "all", "UXRT611", "150731_01");
    $mr->define_mr_patches("VRTScps61", "all", "UXRT611", "150746_01");
}

package MR::UXRT611::Sol11sparc;
@MR::UXRT611::Sol11sparc::ISA = qw(MR::UXRT611::Common);
sub define_patches {
    my $mr=shift;
    $mr->define_mr_patches("VRTSvcsag61", "all", "UXRT611", "VRTSvcsag_6_1_1_0");
    $mr->define_mr_patches("VRTSvxfen61", "all", "UXRT611", "VRTSvxfen_6_1_1_0");
    $mr->define_mr_patches("VRTSvcsea61", "all", "UXRT611", "VRTSvcsea_6_1_1_0");
    $mr->define_mr_patches("VRTSvcs61", "all", "UXRT611", "VRTSvcs_6_1_1_0");
    $mr->define_mr_patches("VRTSllt61", "all", "UXRT611", "VRTSllt_6_1_1_0");
    $mr->define_mr_patches("VRTSamf61", "all", "UXRT611", "VRTSamf_6_1_1_0");
    $mr->define_mr_patches("VRTSdbac61", "all", "UXRT611", "VRTSdbac_6_1_1_0");
    $mr->define_mr_patches("VRTSdbed61", "all", "UXRT611", "VRTSdbed_6_1_1_0");
    $mr->define_mr_patches("VRTSvxfs61", "all", "UXRT611", "VRTSvxfs_6_1_1_0");
    $mr->define_mr_patches("VRTSvxvm61", "all", "UXRT611", "VRTSvxvm_6_1_1_0");
    $mr->define_mr_patches("VRTSsfcpi61", "all", "UXRT611", "VRTSsfcpi61_6_1_1_0");
    $mr->define_mr_patches("VRTSaslapm61", "all", "UXRT611", "VRTSaslapm_6_1_1_0");
    $mr->define_mr_patches("VRTScps61", "all", "UXRT611", "VRTScps_6_1_1_0");
    $mr->define_mr_patches("VRTSgab61", "all", "UXRT611", "VRTSgab_6_1_1_0");
    $mr->define_mr_patches("VRTSglm61", "all", "UXRT611", "VRTSglm_6_1_1_0");
    $mr->define_mr_patches("VRTSgms61", "all", "UXRT611", "VRTSgms_6_1_1_0");
}

package MR::UXRT611::HPUX;
@MR::UXRT611::HPUX::ISA = qw(MR::UXRT611::Common);

package MR::UXRT611::SunOS;
@MR::UXRT611::SunOS::ISA = qw(MR::UXRT611::Common);

1;
