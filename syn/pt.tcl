set design_name conv
set report_dir ./reports_pt

source ./dc_setup.tcl

read_verilog "./conv/conv.sv"
current_design conv
link_design

create_clock clk -name clock -period 5

complete_net_parasitics -complete_iwth wlm
set_propagated_clock [get_ports clk]
set power_enable_analysis true
set power_analysis_mode averaged
set power_clock_network_include_clock_gating_network true

source "./conv/post-synth.namemap"

read_saif "/sim/kprabhu7/dnn-accelerator/conv_systolic_packed_v13/ncsim_backward.saif" -strip_path "scverify_top/rtl"

update_power
report_power -nosplit -hierarchy

