# Add files
solution file add ./conv_ref.cpp -exclude true
solution file add ./tb_gemm_systolic.cpp -exclude true
solution file add ./catapult_gemm_systolic.cpp

# Analyze the design
go analyze

# Set hierarchy
directive set -DESIGN_HIERARCHY {conv params_generator__FR25ac_channel__tm__8_6ParamsN21 {pe_template<DTYPE, 1>::exec} {systolic_array<DTYPE, 1, 16, 16, 7, 7, 64>} {READ_BLOCK_WEIGHTS<DTYPE, 4096, 1, 16>} params_duplicator {unified_double_buffer<DTYPE, 4096, 4096, 16, 1, 16>} {address_generator_inputs<4096, 16>} address_generator_weights<4096> {WRITE_BLOCK_INPUT<DTYPE, 4096, 16>} {READ_BLOCK_INPUT<DTYPE, 4096, 16>} {WRITE_BLOCK_WEIGHTS<DTYPE, 4096, 1, 16>}}
# Compile
go compile

# Add memory libraries
solution library add mgc_sample-090nm_beh_dc -- -rtlsyntool DesignCompiler -vendor Sample -technology 090nm
solution library add ts6n28hpla2048x32m8swbs_tt1v25c
solution library add ts6n28hpla4096x16m16swbs_tt1v25c
solution library add ts6n28hpla8192x16m16swbs_tt1v25c

go libraries

# set clock
directive set -CLOCKS {clk {-CLOCK_PERIOD 10 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 5 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND sync -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}
# map to CCORE
directive set /conv/pe_template<DTYPE,1>::exec -MAP_TO_MODULE {[CCORE]}

go assembly

# set registers for arrays
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/pe.x_reg:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/pe.x_reg:rsc -BLOCK_SIZE 1
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/pe.y_reg.value:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/pe.y_reg.value:rsc -BLOCK_SIZE 1
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/in_tmp:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/in_tmp:rsc -BLOCK_SIZE 1
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/out_tmp.value:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/out_tmp.value:rsc -BLOCK_SIZE 1
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/xy_i:w_tile.value:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/xy_i:w_tile.value:rsc -BLOCK_SIZE 1
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/xy_i:in_tmp2:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/xy_i:in_tmp2:rsc -BLOCK_SIZE 1
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/xy_i:out_tmp2.value:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/core/xy_i:out_tmp2.value:rsc -BLOCK_SIZE 1


go architect

source ignore_mem_dep.tcl

go extract