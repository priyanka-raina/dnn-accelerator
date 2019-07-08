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
