##### add std cell filler and decap #####
insert_stdcell_filler -no_1x -cell_without_metal "FILL64BWPHVT FILL32BWPHVT FILL16BWPHVT FILL8BWPHVT FILL4BWPHVT FILL3BWPHVT FILL2BWPHVT" -cell_with_metal "OD18DCAP64BWP OD18DCAP32BWP OD18DCAP16BWP" -connect_to_power {VDD} -connect_to_ground {VSS} -respect_keepout -metal_filler_coverage_area 500000 -respect_overlap

route_opt -incremental -size_only

##### postroute redundant via insertion #####
source /tsmc28/pdk/2016.09.28/TN28CLPR002S1_1_5A/N28_PRTF_Syn_v1d5a/N28_PRTF_Syn_v1d5a/PR_tech/Synopsys/DFMViaSwapTcl/n28_ICC_DFMSWAP_4X2Y1Z_HVH.tcl

##### add std cell filler #####
insert_stdcell_filler -no_1x -cell_without_metal "FILL64BWPHVT FILL32BWPHVT FILL16BWPHVT FILL8BWPHVT FILL4BWPHVT FILL3BWPHVT FILL2BWPHVT" -connect_to_power {VDD} -connect_to_ground {VSS} -respect_keepout -respect_overlap

##### add well filler #####
insert_well_filler -layer NW -fill_gaps_smaller_than 15
insert_well_filler -layer NP -fill_gaps_smaller_than 15
insert_well_filler -layer PP -fill_gaps_smaller_than 15
insert_well_filler -layer VTH_N
insert_well_filler -layer VTH_P
insert_well_filler -layer VTL_N
insert_well_filler -layer VTL_P

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

##Final Route clean-up - if needed:
##Once we hit minor cleanup, best to turn off ZRoute timing options
##This avoids extraction/timing hits
set_route_zrt_global_options -timing_driven false -crosstalk_driven false
set_route_zrt_track_options -timing_driven false -crosstalk_driven false
set_route_zrt_detail_options -timing_driven false

route_zrt_eco               ;#catch any opens and try to re-route them, recheck DRC

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

remove_unconnected_ports -blast_buses [get_cells -all -hierarchical]
report_tie_nets

verify_lvs
