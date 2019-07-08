set_host_options -max_cores 8

set user_name $::env(USER)
set design_name TopWithPHYAndCGRA

set rtl_dir ../rtl
set syn_dir ../syn
set par_dir .

# ##### library setup #####
source ./tsmc28_setup.tcl
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

set mw_design_library $par_dir/${design_name}_mwlib

file delete -force $mw_design_library

create_mw_lib -technology $tech_file -mw_reference_library $mw_reference_libraries -bus_naming_style {[%d]} $mw_design_library

open_mw_lib $mw_design_library

##### set LVT cells as don't use (overridden by set_clock_tree_references in CTS)#####
set_dont_use [get_lib_cells tcbn28hplbwplvttt1v25c/*]

check_library

set_tlu_plus_files -max_tluplus $tluplus_path/cln28hpl_1p08m+ut-alrdl_4x2y1z_typical.tluplus \
        -tech2itf_map $map_file

check_tlu_plus_files

##### import design #####
import_designs -format verilog -top $design_name ../syn/TopWithPHYAndCGRA.v
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
source -echo ./constraints.tcl
##### create I/O pads and set locations #####
# source ./design_data/insert_pads.tcl
# read_pin_pad_physical_constraints ./design_data/pad_constraints.tdf
# check_mv_design

##### floorplan and fp placement #####
source ./floorplan.tcl

##### manually specified PG connections #####
source ./upf.tcl

##### PG rings and straps #####
source ./powerplan.tcl

##### add end caps #####
# add_end_cap -mode bottom_left -lib_cell tcbn28hplbwphvt/BOUNDARY_LEFTBWP -respect_padding -respect_blockage -respect_keepout
# add_end_cap -mode upper_right -lib_cell tcbn28hplbwphvt/BOUNDARY_RIGHTBWP -respect_padding -respect_blockage -respect_keepout

##### add tap cells #####
# add_tap_cell_array -master_cell_name {TAPCELLBWP} -distance 20 -well_net_name {VDD} -substrate_net_name {VSS} -connect_power_name {VDD} -connect_ground_name {VSS} -respect_keepout -no_1x

##### fp place incr #####
create_fp_placement

# set all SRAM cells to fixed
set_undoable_attribute [get_flat_cells -filter {ref_name =~ *TS*}] is_fixed {1}

#derive_placement_blockages -thin_channel_width 10 -output_script blockages.tcl -apply
derive_placement_blockages -thin_channel_width 20 -output_script blockages.tcl -apply
# create_fp_placement -incremental all
derive_pg_connection -power_net {VDD} -power_pin {VDD} -ground_net {VSS} -ground_pin {VSS}
# derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS

##### preroute instances and std cells #####
preroute_instances -nets {VDD VSS} -ignore_macros -ignore_cover_cells -primary_routing_layer specified -specified_horizontal_layer M8 -specified_vertical_layer M7

insert_stdcell_filler -no_1x -cell_without_metal "SHFILL128_RVT SHFILL64_RVT SHFILL3_RVT SHFILL2_RVT SHFILL1_RVT" -connect_to_power {VDD} -connect_to_ground {VSS}
derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS

preroute_standard_cells -connect horizontal -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}

verify_pg_nets

remove_stdcell_filler -stdcell

verify_pg_nets

##### fp place incr #####
create_fp_placement

derive_pg_connection -power_net {VDD} -power_pin {VDD} -ground_net {VSS} -ground_pin {VSS}
# derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT
report_clock
report_clock -skew

check_physical_constraints

check_physical_design -stage pre_place_opt




place_opt

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

save_mw_cel -as "${design_name}_place.CEL"
