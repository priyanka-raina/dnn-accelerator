set_host_options -max_cores 12

set design_name conv
set report_dir ./reports
sh mkdir -p $report_dir

# source ./pt_setup.tcl
source ../common/setup.tcl

read_verilog "../syn/conv/conv_rtl.sv"
current_design conv_rtl
link_design

# create_clock clk -name clock -period 5
source ../common/constraints.tcl

complete_net_parasitics -complete_with wlm
set_propagated_clock [get_ports clk]
set power_enable_analysis true
set power_analysis_mode averaged
set power_clock_network_include_clock_gating_network true

source "../syn/conv/post-synth.namemap"

read_saif "../hls/ncsim_backward.saif" -strip_path "conv" 

update_power
report_power -nosplit -hierarchy > $report_dir/power.rpt

quit
