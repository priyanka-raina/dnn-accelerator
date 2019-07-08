
set design_name $::env(DESIGN)
set report_dir ./reports
sh mkdir -p $report_dir

source -echo -verbose ../dc_setup.tcl

saif_map -start

define_design_lib WORK -path ./WORK

read_file -top $design_name -autoread [glob -directory ../../rtl -type f *.v *.sv]
current_design $design_name

link

# Apply timing constraints
source ../constraints.tcl


### END DESIGN CONSTRAINTS
check_design > $report_dir/$design_name.chk1

read_saif -auto_map_names -instance "scverify_top/rtl" -input "/sim/kprabhu7/dnn-accelerator/conv_systolic_packed_v13/ncsim_backward.saif" -verbose

report_compile_options

compile_ultra -gate_clock              -scan -no_seq_output_inversion -no_autoungroup 
compile_ultra -gate_clock -incremental -scan -no_seq_output_inversion -no_autoungroup 

uniquify -force -dont_skip_empty_designs

check_design > $report_dir/$design_name.chk2

report_timing -in -net -transition_time  -capacitance  -significant_digits  4 -attributes  -nosplit -path full_clock -delay max -nworst 1 -max_paths 10 > $report_dir/$design_name.time

report_saif -hier > conv.mapped.saif.rpt

saif_map -create_map -input "/sim/kprabhu7/dnn-accelerator/conv_systolic_packed_v13/ncsim_backward.saif" -source_instance "scverify_top/rtl" -verbose

saif_map -type ptpx -write_map "post-synth.namemap"

# Write synthesized verilog
write -format verilog -hierarchy -output ./$design_name.sv
write_sdf ./$design_name.sdf
# write_milkyway -overwrite -output $design_name
# write design reports (timing, area, power)
report_qor > $report_dir/$design_name.qor.rpt
report_power > $report_dir/$design_name.power.top.rpt
report_area -hierarchy > $report_dir/$design_name.area.rpt
report_power -hierarchy -levels 3 >  $report_dir/$design_name.power.rpt
#export design database
write -format ddc -hier -out ./$design_name.ddc;
#
quit


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
