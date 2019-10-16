set search_path "$search_path   /tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hplbwphvt_120b \
                                /tsmc28/libs/2016.10.07/tcbn28hplbwplvt_120b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hplbwplvt_120b \
				/tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hplbwphvt_120b \
				/tsmc28/libs/2016.10.07/tcbn28hplbwplvt_120b_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hplbwplvt_120b \
                                /tsmc28/libs/2016.10.07/tphn28hplgv18_130a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hplgv18_130a \
                                /home/kprabhu7/mc2/MC2_2012.02.00.c/ts6n28hpla256x16m4swbs_120b/NLDM \
                                /home/kprabhu7/mc2/MC2_2012.02.00.c/ts6n28hpla256x32m4swbs_120b/NLDM \
                                /home/kprabhu7/mc2/MC2_2012.02.00.c/ts1n28hplb4096x112m4s_130a/NLDM \
				/home/kprabhu7/mc2/MC2_2012.02.00.c/ts1n28hplb4096x144m4s_130a/NLDM"

set srams "ts1n28hplb4096x112m4s_130a_ff1p1v0c.db \
ts1n28hplb4096x112m4s_130a_ff1p1v125c.db \
ts1n28hplb4096x112m4s_130a_ff1p1vm40c.db \
ts1n28hplb4096x112m4s_130a_ss0p9v0c.db \
ts1n28hplb4096x112m4s_130a_ss0p9v125c.db \
ts1n28hplb4096x112m4s_130a_ss0p9vm40c.db \
ts1n28hplb4096x112m4s_130a_tt1v25c.db \
ts1n28hplb4096x112m4s_130a_tt1v85c.db \
ts1n28hplb4096x144m4s_130a_ff1p1v0c.db \
ts1n28hplb4096x144m4s_130a_ff1p1v125c.db \
ts1n28hplb4096x144m4s_130a_ff1p1vm40c.db \
ts1n28hplb4096x144m4s_130a_ss0p9v0c.db \
ts1n28hplb4096x144m4s_130a_ss0p9v125c.db \
ts1n28hplb4096x144m4s_130a_ss0p9vm40c.db \
ts1n28hplb4096x144m4s_130a_tt1v25c.db \
ts1n28hplb4096x144m4s_130a_tt1v85c.db \
ts6n28hpla256x16m4swbs_120b_ff1p1v0c.db \
ts6n28hpla256x16m4swbs_120b_ff1p1v125c.db \
ts6n28hpla256x16m4swbs_120b_ff1p1vm40c.db \
ts6n28hpla256x16m4swbs_120b_ff1p1v125c.db \
ts6n28hpla256x16m4swbs_120b_ss0p9v0c.db \
ts6n28hpla256x16m4swbs_120b_ss0p9v125c.db \
ts6n28hpla256x16m4swbs_120b_ss0p9vm40c.db \
ts6n28hpla256x16m4swbs_120b_tt1v25c.db \
ts6n28hpla256x16m4swbs_120b_tt1v85c.db \
ts6n28hpla256x32m4swbs_120b_ff1p1v0c.db \
ts6n28hpla256x32m4swbs_120b_ff1p1v125c.db \
ts6n28hpla256x32m4swbs_120b_ff1p1vm40c.db \
ts6n28hpla256x32m4swbs_120b_ff1p1v125c.db \
ts6n28hpla256x32m4swbs_120b_ss0p9v0c.db \
ts6n28hpla256x32m4swbs_120b_ss0p9v125c.db \
ts6n28hpla256x32m4swbs_120b_ss0p9vm40c.db \
ts6n28hpla256x32m4swbs_120b_tt1v25c.db \
ts6n28hpla256x32m4swbs_120b_tt1v85c.db"


set target_library "tcbn28hplbwphvttt1v25c.db $srams"
set link_library "* tcbn28hplbwphvttt1v25c.db  tphn28hplgv18tt1v1p8v25c.db $srams"

set mw_reference_libraries  "/tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwphvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwphvt \
                            /tsmc28/libs/2016.10.07/tcbn28hplbwplvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwplvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwplvt \
                            /tsmc28/libs/2016.10.07/tphn28hplgv18_130a_aptu7lm/TSMCHOME/digital/Back_End/milkyway/tphn28hplgv18_130a/mt_2/7lm/cell_frame/tphn28hplgv18 \
                            /tsmc28/libs/2016.10.07/tpbn28v_140a_aptcup8m4x2y1z/TSMCHOME/digital/Back_End/milkyway/tpbn28v_140a/cup/8m/8M_4X2Y1Z/cell_frame/tpbn28v \
"
#							/home/kprabhu7/riscv-soc/tsmc28-pipecleaner/srams/milkyway/ts1n28hplb512x112m4swbaso_130a \
#							/home/kprabhu7/riscv-soc/tsmc28-pipecleaner/srams/milkyway/ts1n28hplb512x128m4swbaso_130a \
#							/home/kprabhu7/riscv-soc/tsmc28-pipecleaner/srams/milkyway/ts1n28hplb512x144m4swbaso_130a \
#							/home/kprabhu7/riscv-soc/tsmc28-pipecleaner/srams/milkyway/ts1n28hplb64x84m4swbaso_130a \
#							/home/kprabhu7/riscv-soc/tsmc28-pipecleaner/srams/milkyway/ts1n28hplb64x88m4swbaso_130a \
#"

set tluplus_path /tsmc28/libs/2016.10.07/tluplus_starrc2016
set map_file /tsmc28/pdk/2016.09.28/TN28CRSP004W1_1_0_2P3A/CCI/CCI_decks/starrcxt_mapping
set tech_file /tsmc28/pdk/2016.09.28/TN28CLPR002S1_1_5A/N28_PRTF_Syn_v1d5a/N28_PRTF_Syn_v1d5a/PR_tech/Synopsys/TechFile/HVH/tsmcn28_8lm4X2Y1ZUTRDL.tf
set map_file /tsmc28/pdk/2016.09.28/TN28CRSP004W1_1_0_2P3A/CCI/CCI_decks/starrcxt_mapping


#file mkdir $syn_dir/work
#define_design_lib work -path $syn_dir/work
#set alib_library_analysis_path $syn_dir

#set tluplus_path /home/dbankman/digital/tluplus_starrc2016
#set tech_file /tsmc28/pdk/2016.09.28/TN28CLPR002S1_1_5A/N28_PRTF_Syn_v1d5a/N28_PRTF_Syn_v1d5a/PR_tech/Synopsys/TechFile/HVH/tsmcn28_8lm4X2Y1ZUTRDL.tf
#set map_file /tsmc28/pdk/2016.09.28/TN28CRSP004W1_1_0_2P3A/CCI/CCI_decks/starrcxt_mapping
#set mw_reference_libraries  "/home/dbankman/digital/libraries/tcbn28hplbwphvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwphvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwphvt "
#set mw_reference_libraries  "/tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwphvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwphvt "
set mw_design_library ${design_name}_mwlib

file delete -force $mw_design_library

create_mw_lib -technology $tech_file -mw_reference_library $mw_reference_libraries -bus_naming_style {[%d]} $mw_design_library

open_mw_lib $mw_design_library

check_library

set_tlu_plus_files -max_tluplus $tluplus_path/cln28hpl_1p08m+ut-alrdl_4x2y1z_typical.tluplus \
        -tech2itf_map $map_file

check_tlu_plus_files
