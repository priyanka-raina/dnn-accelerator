analyze -format sverilog -lib work {
../rtl/concat_rtl.v
}
elaborate gemm
link

# Apply timing constraints
source ./constraints.tcl

set_fix_multiple_port_nets -outputs -exclude_clock_network

compile_ultra -no_autoungroup -no_seq_output_inversion -gate_clock

remove_unconnected_ports -blast_buses [get_cells -all -hierarchical]

##
## Generate reports
##
reset_timing_derate
file mkdir ./reports
report_timing -delay_type max -significant_digits 4 > ./reports/timing_report_max
report_timing -delay_type min -significant_digits 4 > ./reports/timing_report_min
report_area > ./reports/area_report
report_power > ./reports/power_report
report_design > ./reports/design_report
report_constraints -all -significant_digits 4 > ./reports/constraints_report
check_design > ./reports/design_check
check_error > ./reports/error_check

##
## Write out retimed netlist
##
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell 
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}                        
change_names -hierarchy -rules name_rule
uniquify
write -format verilog -hierarchy -output ./top.v
write_sdf ./top.sdf
