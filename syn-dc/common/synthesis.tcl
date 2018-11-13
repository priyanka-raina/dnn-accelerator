# default procedures to compile and save results and reports. can be overridden in design.tcl
proc run_compile {} {
    link
    uniquify
    compile_ultra
    change_names -hierarchy -rules verilog
}

proc save_design {} {
    cd design
    set fname [current_design_name]

    set_app_var verilogout_no_tri true
    set_app_var verilogout_single_bit false
    set_app_var hdlout_internal_busses true

    write_file -hierarchy -output ${fname}.ddc
    write_file -format verilog -hierarchy -output ${fname}.v
    write_file -format verilog -pg -hierarchy -output ${fname}_pg.v
    write_sdc -nosplit ${fname}.sdc
    write_sdf -version 1.0 -context verilog ${fname}.sdf
    save_upf synth.upf
    cd ..
}

proc save_reports {} {
    cd reports

    check_design > dc_problems
    check_mv_design > dc_multivoltage_problems

    # Report QoR
    report_qor > dc_qor
    report_area -nosplit -hierarchy  > dc_area
    report_timing -nosplit > dc_timing

    # Power Analysis
    report_saif -hier -rtl_saif -missing > dc_saif
    report_power -nosplit > dc_power
    report_power -nosplit -verbose -hierarchy > dc_power_hier
    report_clock_gating -nosplit > dc_clk_gating

    report_cell > dc_cell
    report_constraint -all_violator -verbose > dc_constraint

    report_timing -path full -delay max -max_paths 300 -input_pins -nets -transition_time -capacitance > dc_full_path_timing
    cd ..
}

proc done {} {
    # exit when done
    saif_map -write_map design/saif.map
    saif_map -write_map design/saif_map.tcl -type ptpx
    saif_map -end
    set_svf -off

    exit
    # or, explore the synthesized design graphically
    # start_gui
}

file mkdir design reports

set_svf design/formality.svf
set_app_var link_library [list]
set_app_var target_library [list]
set_app_var synthetic_library [list]

# use upto 8 cores on the computer
set_host_options -max_cores [expr min([exec nproc], 16)]
saif_map -start

source -echo dc.tcl

setup_ui
setup_libraries
setup_design

config_libraries
config_design

run_compile

save_design
save_reports

done
