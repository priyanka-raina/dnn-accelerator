#set_clock_tree_references -references [remove_from_collection [get_lib_cells {tcbn28hplbwplvttt1v25c/CKND* tcbn28hplbwplvttt1v25c/CKBD*}] tcbn28hplbwplvttt1v25c/CKND2D*]
#set_clock_tree_references -sizing_only -references [get_lib_cells {tcbn28hplbwplvttt1v25c/CKAN2D* tcbn28hplbwplvttt1v25c/CKLHQD* tcbn28hplbwplvttt1v25c/CKLNQD* tcbn28hplbwplvttt1v25c/CKMUX2D* tcbn28hplbwplvttt1v25c/CKND2D* tcbn28hplbwplvttt1v25c/CKXOR2D*}]

report_clock > clock_report.txt
report_clock -skew > clock_report_skew.txt
report_clock_tree -summary > clock_tree.txt
report_constraint -all > constrants.txt

set_fix_hold_options -effort high
set_fix_hold [all_clocks]

check_physical_design -stage pre_clock_opt

clock_opt -fix_hold_all_clocks
report_clock_tree > clock_tree2.txt
report_timing > timing.txt

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

save_mw_cel -as ${design_name}_cts.CEL

