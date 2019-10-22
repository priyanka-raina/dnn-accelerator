# ##### library setup #####
source ../common/setup.tcl
# set search_path "$search_path   /tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hplbwphvt_120b \
#                                 /tsmc28/libs/2016.10.07/tcbn28hplbwplvt_120b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hplbwplvt_120b \
#                                 /tsmc28/libs/2016.10.07/tcbn28hplbwphvt_120b_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hplbwphvt_120b \
#                                 /tsmc28/libs/2016.10.07/tcbn28hplbwplvt_120b_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hplbwplvt_120b \
#                                 /tsmc28/libs/2016.10.07/tphn28hplgv18_130a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hplgv18_130a "

# set target_library "tcbn28hplbwphvttt1v25c.db tcbn28hplbwplvttt1v25c.db"
# set link_library "* tcbn28hplbwphvttt1v25c.db tcbn28hplbwplvttt1v25c.db tphn28hplgv18tt1v1p8v25c.db"

# set tluplus_path /home/dbankman/digital/tluplus_starrc2016
# set tech_file /tsmc28/pdk/2016.09.28/TN28CLPR002S1_1_5A/N28_PRTF_Syn_v1d5a/N28_PRTF_Syn_v1d5a/PR_tech/Synopsys/TechFile/HVH/tsmcn28_8lm4X2Y1ZUTRDL.tf
# set map_file /tsmc28/pdk/2016.09.28/TN28CRSP004W1_1_0_2P3A/CCI/CCI_decks/starrcxt_mapping
# set mw_reference_libraries  "/home/dbankman/digital/libraries/tcbn28hplbwphvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwphvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwphvt \
#                             /home/dbankman/digital/libraries/tcbn28hplbwplvt_120b_apt/TSMCHOME/digital/Back_End/milkyway/tcbn28hplbwplvt_120b/cell_frame_HVH_0d5_0/tcbn28hplbwplvt \
#                             /home/dbankman/digital/libraries/tphn28hplgv18_130a_aptu7lm/TSMCHOME/digital/Back_End/milkyway/tphn28hplgv18_130a/mt_2/7lm/cell_frame/tphn28hplgv18 \
#                             /home/dbankman/digital/libraries/tpbn28v_140a_aptcup8m4x2y1z/TSMCHOME/digital/Back_End/milkyway/tpbn28v_140a/cup/8m/8M_4X2Y1Z/cell_frame/tpbn28v"

# set mw_design_library $par_dir/${design_name}_mwlib

# file delete -force $mw_design_library

# create_mw_lib -technology $tech_file -mw_reference_library $mw_reference_libraries -bus_naming_style {[%d]} $mw_design_library

# open_mw_lib $mw_design_library

##### set LVT cells as don't use (overridden by set_clock_tree_references in CTS)#####
set_dont_use [get_lib_cells tcbn28hplbwplvttt1v25c/*]

# check_library

# set_tlu_plus_files -max_tluplus $tluplus_path/cln28hpl_1p08m+ut-alrdl_4x2y1z_typical.tluplus \
#         -tech2itf_map $map_file

# check_tlu_plus_files

##### import design #####
import_designs -format verilog -top $design_name ../syn/conv/conv_rtl.sv
uniquify_fp_mw_cel

set_fix_multiple_port_nets -outputs -exclude_clock_network

##### tie cell constraints #####
set_auto_disable_drc_nets -constant false
set_app_var physopt_new_fix_constants true
set tieoff_hierarchy_opt true
set tieoff_hierarchy_opt_keep_driver true
#set_attribute [get_lib_pins tcbn28hplbwphvttt1v25c/TIEHBWPHVT/Z] max_fanout 10 -type float
#set_attribute [get_lib_pins tcbn28hplbwphvttt1v25c/TIELBWPHVT/ZN] max_fanout 10 -type float
#set_attribute [get_lib_pins tcbn28hplbwphvttt1v25c/TIEHBWPHVT/Z] max_capacitance 0.2 -type float
#set_attribute [get_lib_pins tcbn28hplbwphvttt1v25c/TIELBWPHVT/ZN] max_capacitance 0.2 -type float

##### timing constraints #####
source -echo ../common/constraints.tcl
