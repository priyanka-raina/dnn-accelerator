create_clock [get_ports clk]  -period 5

set_clock_uncertainty 0.1  [get_clock]
set_clock_transition -fall 0.1 [get_clock]
set_clock_transition -rise 0.1 [get_clock]

set_max_transition -clock_path 0.1 [get_clock]
set_clock_uncertainty 0.05 [get_clock]

group_path -name "reg2reg" -critical_range 0.1 -from [ all_registers -clock_pins ] -to [ all_registers -data_pins ]
group_path -name "in2reg"  -from [remove_from_collection [all_inputs] clk] -to [ all_registers -data_pins ]
group_path -name "reg2out" -from [ all_registers -clock_pins ] -to [all_outputs]

set_timing_derate -early 0.9 -data
set_timing_derate -late 1.1 -clock

set_max_transition 2 [all_outputs]

set_output_delay 0 -clock clk [all_outputs]
set_input_delay 0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

# capacitance of I/O pad
set_load 1 [all_outputs]
