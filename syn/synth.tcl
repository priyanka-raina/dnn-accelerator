set design_name conv_rtl

set report_dir ./reports
sh mkdir -p $report_dir

source -echo -verbose ../../common/setup.tcl

saif_map -start

define_design_lib WORK -path ./WORK

read_file -top $design_name -autoread [glob -directory ../../rtl -type f *.v *.sv]
current_design $design_name

link

# Apply timing constraints
source ../../common/constraints.tcl

check_design > $report_dir/$design_name.chk1

read_saif -auto_map_names -instance "scverify_top/rtl" -input "../../hls/ncsim_backward.saif" -verbose

report_compile_options

compile_ultra -gate_clock              -scan -no_seq_output_inversion -no_autoungroup 
compile_ultra -gate_clock -incremental -scan -no_seq_output_inversion -no_autoungroup 

uniquify -force -dont_skip_empty_designs

check_design > $report_dir/$design_name.chk2

report_timing -in -net -transition_time  -capacitance  -significant_digits  4 -attributes  -nosplit -path full_clock -delay max -nworst 1 -max_paths 10 > $report_dir/$design_name.time

saif_map -create_map -input "../../hls/ncsim_backward.saif" -source_instance "scverify_top/rtl" -verbose
saif_map -type ptpx -write_map "post-synth.namemap"

# Write synthesized verilog
write -format verilog -hierarchy -output ./$design_name.sv
write_sdf ./$design_name.sdf

# write design reports (timing, area, power)
report_qor > $report_dir/$design_name.qor.rpt
report_power > $report_dir/$design_name.power.top.rpt
report_area -hierarchy > $report_dir/$design_name.area.rpt
report_power -hierarchy -levels 3 >  $report_dir/$design_name.power.rpt

#export design database
write -format ddc -hier -out ./$design_name.ddc;

quit
