set search_path "$search_path   /tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hplbwphvt_120b \
                                /tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hplbwphvt_120b \
                                /tsmc28/libs/2016.10.07/tphn28hplgv18_130a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hplgv18_130a "
set target_library "tcbn28hplbwphvttt1v25c.db"
set link_library "* tcbn28hplbwphvttt1v25c.db  tphn28hplgv18tt1v1p8v25c.db"

file mkdir $syn_dir/work
define_design_lib work -path $syn_dir/work
set alib_library_analysis_path $syn_dir

set tluplus_path /tsmc28/libs/2016.10.07/tluplus_starrc2016
set tech_file /tsmc28/pdk/2016.09.28/TN28CLPR002S1_1_5A/N28_PRTF_Syn_v1d5a/N28_PRTF_Syn_v1d5a/PR_tech/Synopsys/TechFile/HVH/tsmcn28_8lm4X2Y1ZUTRDL.tf
set map_file /tsmc28/pdk/2016.09.28/TN28CRSP004W1_1_0_2P3A/CCI/CCI_decks/starrcxt_mapping
set mw_reference_libraries  "/tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwphvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwphvt "
set mw_design_library $syn_dir/${design_name}_mwlib

file delete -force $mw_design_library

create_mw_lib -technology $tech_file -mw_reference_library $mw_reference_libraries -bus_naming_style {[%d]} $mw_design_library

open_mw_lib $mw_design_library

check_library

set_tlu_plus_files -max_tluplus $tluplus_path/cln28hpl_1p08m+ut-alrdl_4x2y1z_typical.tluplus \
        -tech2itf_map $map_file

check_tlu_plus_files
