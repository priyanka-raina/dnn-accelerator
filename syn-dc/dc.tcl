proc setup_ui {} {
    set_app_var sh_allow_tcl_with_set_app_var false
    set_app_var sh_continue_on_error false
    set_app_var sh_script_stop_severity E
    set_app_var sh_new_variable_message false
    set_app_var sh_new_variable_message_in_script false
}

proc setup_libraries {} {
    # you need to set synthetic_library, target_library and link_library
    # synthetic_library - contains implementations of adders, multipliers, etc.
    # target_library - contains standard cells
    # link_library - is a list of libraries that contain modules that are
    #   instantiated in verilog but don't have any synthesizable verilog implementation.
    #   this would include SRAMs, and also standard cells and DesignWare modules 
    #   that are directly instantiated

    # cache results of analysing the standard cell library for faster synthesis
    set_app_var alib_library_analysis_path ~
    set libbase /tsmc28/libs/2016.10.07
    
    add_library $libbase/tcbn28hplbwphvt_120b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hplbwphvt_120b/tcbn28hplbwphvt -target -link -max ss0p9v125c.db -min ff1p1v0c.db
    
    add_library $libbase/tphn28hplgv18_130a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn28hplgv18_130a/tphn28hplgv18 -link -max ssg0p9v1p62v125c.db -min ff1p1v1p98v0c.db

    add_library dw_foundation.sldb -synthetic -link
}

proc setup_design {} {
    set_app_var hdlin_auto_save_templates true
    set_app_var hdlin_ff_always_sync_set_reset true
    set_app_var hdlin_ff_always_async_set_reset false
    # set_app_var compile_seqmap_honor_sync_set_reset true
    # (* sync_set_reset = "rst" *)

    set VERILOG_SRC [list]
    set VERILOG_EXCLUDE [list]

    # design files
    lappend VERILOG_SRC ../rtl/concat_rtl.v
  
    set design gemm
    
    # TODO
    # paths to SRAMs
    #foreach sram [glob <path to srams>/db/*wc.db] {
        #add_library [string range $sram 0 [expr [string length $sram] - 6]] -link -max wc.db -min bc.db
    #}

    define_design_lib WORK -path work
    analyze $VERILOG_SRC -autoread -top $design -exclude $VERILOG_EXCLUDE
    elaborate $design -arch verilog
}

proc config_libraries {} {
    # How to estimate wire loads from area of design
    #set_app_var auto_wire_load_selection area_reselect
    #set_wire_load_mode enclosed
    #set_wire_load_selection_group WireAreaLowkCon

    # use operating conditions from the standard-cell library
    set_operating_conditions -max ss0p9v125c -min ff1p1v0c -max_library tcbn28hplbwphvtss0p9v125c -min_library tcbn28hplbwphvtff1p1v0c
    #set_operating_conditions -max WCCOM -min BCCOM -max_library tcbn40lpbwpwc -min_library tcbn40lpbwpbc
}

proc config_design {} {
    set clk_period 4.0

    set clk clk
    create_clock $clk -period $clk_period
    set_clock_uncertainty 0.2 $clk
    set_dont_touch_network $clk
    set_ideal_network $clk

    set inputs [remove_from_collection [all_inputs] [list $clk rst]]
    set_input_delay 2 -max -clock $clk $inputs
    set_input_delay 0 -min -clock $clk $inputs
    set_input_delay 0.2 -max -clock $clk [get_ports rst]
    set_input_delay 0 -min -clock $clk [get_ports rst]


    set ref_output [get_port input_rsc_lz]
    foreach_in_collection output [remove_from_collection [all_outputs] $ref_output] {
        set_data_check -from $ref_output -to $output -setup -1
        set_data_check -from $ref_output -to $output -hold [expr $clk_period - 1]
    }

    # load capacitance on the outputs can be set using input cells from IO library if they IO cells are not in the design
    # if synthesizing with IO, use PCB traces + FPGA capacitance
    #set_load 16.0 [all_outputs]

    # assume FPGA outputs driven by cell similar to what we have
	# TODO
    #set_driving_cell -max -library <library name> -lib_cell <cell name> [all_inputs]
    #set_driving_cell -min -library <library name> -lib_cell <cell name> [all_inputs]
    
    set_load [load_of tphn28hplgv18ssg0p9v1p62v125c/PRDW08DGZ_H_G/I] [all_outputs]
    set_driving_cell -max -lib_cell PRDW08DGZ_H_G -pin C -library tphn28hplgv18ssg0p9v1p62v125c [all_inputs]
    set_driving_cell -min -lib_cell PRDW08DGZ_H_G -pin C -library tphn28hplgv18ff1p1v1p98v0c [all_inputs]
    # optimize paths that are failing as well as paths within 1ns of the margin
    set_critical_range 1.0 [current_design]

    # switching activity from RTL simulation, to generate rtl <-> saif mapping for PrimeTime PX
    #read_saif -auto_map_names -input ../rtl.saif -instance mkTest/fpga/asic -verbose
    # uncomment the next line to enable power optimization based on the input saif file
    #set_dynamic_optimization true

    # don't remove io cells
    set_dont_touch [get_lib_cells tphn*/*]

    #source ./voltages.upf
}

proc run_compile {} {
    suppress_message {TIM-164 OPT-314 OPT-319 OPT-776 OPT-170 OPT-171}
    # OPT-170 OPT-171: changed wire model and minimum wire load model
    # TIM-164: different trip thresholds in libraries
    # OPT-314: disabling timing arc
    # OPT-319: inverting signal
    # OPT-776: ungrouping hierarchy
    link
    uniquify

    set_app_var compile_clock_gating_through_hierarchy true
    set_clock_gating_style -num_stages 5
    set_leakage_optimization true

    #compile_ultra -gate_clock -retime
    compile_ultra -gate_clock
    # optimize_netlist -area
    change_names -hierarchy -rules verilog

    define_name_rules asic_core_rules -allowed {a-zA-Z0-9_()[]} -max_length 255 -reserved_words [list "always" "and" "assign" "begin" "buf" "bufif0" "bufif1" "case" "casex" "casez" "cmos" "deassign" "default" "defparam" "disable" "edge" "else" "end" "endcase" "endfunction" "endmodule" "endprimitive" "endspecify" "endtable" "endtask" "event" "for" "force" "forever" "fork" "function" "highz0" "highz1" "if" "initial" "inout" "input" "integer" "join" "large" "macromodule" "medium" "module" "nand" "negedge" "nmos" "nor" "not" "notif0" "notif1" "or" "output" "pmos" "posedge" "primitive" "pull0" "pull1" "pulldown" "pullup" "rcmos" "reg" "release" "repeat" "rnmos" "rpmos" "rtran" "rtranif0" "rtranif1" "scalered" "small" "specify" "specparam" "strong0" "strong1" "supply0" "supply1" "table" "task" "time" "tran" "tranif0" "tranif1" "tri" "tri0" "tri1" "triand" "trior" "vectored" "wait" "wand" "weak0" "weak1" "while" "wire" "wor" "xnor" "xor" "abs" "access" "after" "alias" "all" "and" "architecture" "array" "assert" "attribute" "begin" "block" "body" "buffer" "bus" "case" "component" "configuration" "constant" "disconnect" "downto" "else" "elsif" "end" "entity" "exit" "file" "for" "function" "generate" "generic" "guarded" "if" "in" "inout" "is" "label" "library" "linkage" "loop" "map" "mod" "nand" "new" "next" "nor" "not" "null" "of" "on" "open" "or" "others" "out" "package" "port" "procedure" "process" "range" "record" "register" "rem" "report" "return" "select" "severity" "signal" "subtype" "then" "to" "transport" "type" "units" "until" "use" "variable" "wait" "when" "while" "with" "xor"] -case_insensitive -last_restricted "_" -first_restricted "_" -map {{{"*cell*","U"}, {"*-return","RET"}}}
    change_names -hierarchy -rules asic_core_rules
}

proc done {} {
    saif_map -write_map design/saif.map
    saif_map -write_map design/saif_map.tcl -type ptpx
    saif_map -end
    set_svf -off

    start_gui
}
