report_clock
report_clock -skew

check_physical_constraints

check_physical_design -stage pre_place_opt

place_opt

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

save_mw_cel -as "${design_name}_place.CEL"
