##### set up routing #####
source $antenna_ratio_script

set_route_options -same_net_notch check_and_fix

set_route_zrt_detail_options    -diode_libcell_names ANTENNABWPHVT \
                                -insert_diodes_during_routing true \
                                -use_wide_wire_to_input_pin true \
                                -use_wide_wire_to_output_pin true \
                                -optimize_wire_via_effort_level high \
                                -drc_convergence_effort_level high \
                                -check_patchable_drc_from_fixed_shapes true \
                                -pin_taper_mode off \
                                -default_port_external_gate_size 0.0042 \
                                -repair_shorts_over_macros_effort_level high

set_route_zrt_common_options    -route_soft_rule_effort_level high \
                                -post_detail_route_fix_soft_violations true \
                                -enforce_voltage_area strict \
                                -post_detail_route_redundant_via_insertion high \
                                -concurrent_redundant_via_mode insert_at_high_cost \
                                -concurrent_redundant_via_effort_level high \
                                -eco_route_concurrent_redundant_via_mode reserve_space \
                                -eco_route_concurrent_redundant_via_effort_level high 

set_route_opt_strategy -search_repair_loops 40 -eco_route_search_repair_loops 20

set_ignored_layers -min_routing_layer "M2"
set_ignored_layers -max_routing_layer "M6"

##### do initial routing #####
route_opt -initial_route_only

## medium effort optimization ##
route_opt -skip_initial_route -effort high

##### perform postroute redundant via insertion #####
source $via_insertion_script

##### signal route verification #####
verify_zrt_route
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
verify_lvs

##### fix shorts #####
set_app_var routeopt_enable_aggressive_optimization true
route_opt -incremental

route_opt -incremental -only_hold_time

set_app_var routeopt_drc_over_timing true
route_opt -incremental -only_design_rule

##### perform postroute redundant via insertion #####
source $via_insertion_script

##### signal route verification #####
verify_zrt_route
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
verify_lvs

save_mw_cel -as ${design_name}_route.CEL
