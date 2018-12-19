create_clock [get_ports clk]  -period 50  -waveform {0 25} -name clk

set_clock_uncertainty 0.1  [get_clocks clk]
set_clock_transition -fall 0.1 [get_clocks clk]
set_clock_transition -rise 0.1 [get_clocks clk]

set_max_transition -clock_path 0.1 [get_clocks clk]

group_path -name "reg2reg" -critical_range 0.1 -from [ all_registers -clock_pins ] -to [ all_registers -data_pins ]
group_path -name "in2reg"  -from [remove_from_collection [all_inputs] clk] -to [ all_registers -data_pins ]
group_path -name "reg2out" -from [ all_registers -clock_pins ] -to [all_outputs]

set_timing_derate -early 0.9 -data
set_timing_derate -late 1.1 -clock

set_max_transition 2 [all_outputs]

set_output_delay 5 -clock clk [all_outputs]
set_input_delay 5 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

# Synthesis: load of pad
set_load [load_of tphn28hplgv18tt1v1p8v25c/PDDW08DGZ_V_G/I] [all_outputs]
# Synthesis: drive of pad
set_driving_cell -lib_cell PDDW08DGZ_V_G -pin C -library tphn28hplgv18tt1v1p8v25c [all_inputs]
