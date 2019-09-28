solution options set /Input/CppStandard c++11

flow package require /SCVerify
flow package option set /SCVerify/USE_CCS_BLOCK true
flow package option set /SCVerify/USE_NCSIM true
flow package option set /SCVerify/USE_VCS true

flow package require /NCSim

solution options set Flows/NCSim/NCSIM_DOFILE dump_saif.do
solution options set Flows/NCSim/NC_ROOT /cad/cadence/INCISIVE15.20.022/

# Add files
# solution file add ./catapult_gemm_systolic.cpp
# solution file add ./tb_gemm_systolic.cpp -exclude true
# solution file add ./conv_ref.h -exclude true
# solution file add ./double_buffer.cpp -exclude true
# solution file add ./conv.h -exclude true
# solution file add ./params.h -exclude true
# solution file add ./conv_ref.cpp -exclude true
# solution file add ./Stencil_catapult.h -exclude true
# solution file add ./array_dimensions.h -exclude true

solution file add ./conv_top.cpp
# solution file add ./DoubleBuffer.h -exclude true
# solution file add ./SystolicArray.h -exclude true
# solution file add ./ProcessingElement.h -exclude true
# solution file add ./conv.h -exclude true
# solution file add ./params.h -exclude true
# solution file add ./conv_ref.cpp -exclude true
# solution file add ./Stencil_catapult.h -exclude true
# solution file add ./array_dimensions.h -exclude true
# solution file add ./fifo.h -exclude true
solution file add ./tb_gemm_systolic.cpp -exclude true

# Analyze the design
go analyze

# Set hierarchy
# directive set -DESIGN_HIERARCHY {conv params_generator__FR25ac_channel__tm__8_6ParamsN21 {pe_template<DTYPE, 1>::exec} {systolic_array<DTYPE, 1, 16, 16, 7, 7, 64>} {READ_BLOCK_WEIGHTS<DTYPE, 4096, 1, 16>} params_duplicator {unified_double_buffer<DTYPE, 4096, 4096, 16, 1, 16>} {address_generator_inputs<4096, 16>} address_generator_weights<4096> {WRITE_BLOCK_INPUT<DTYPE, 4096, 16>} {READ_BLOCK_INPUT<DTYPE, 4096, 16>} {WRITE_BLOCK_WEIGHTS<DTYPE, 4096, 1, 16>}}
# Compile
go compile

# Add memory libraries
solution library add tcbn28hplbwphvttt1v25c_dc -- -rtlsyntool DesignCompiler -vendor TSMC -technology 28nm
solution library add ts6n28hpla2048x32m8swbs_tt1v25c
solution library add ts6n28hpla256x32m4swbs_tt1v25c
solution library add ts6n28hpla4096x16m16swbs_tt1v25c
solution library add custom4096X256
solution library add ts6n28hpla256x16m4swbs_tt1v25c

go libraries

# set clock
directive set -CLOCKS {clk {-CLOCK_PERIOD 5 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 2.5 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND sync -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}
directive set /conv -OUTPUT_DELAY 4.95 

# map to CCORE
# directive set /conv/pe_template<DTYPE,1>::exec -MAP_TO_MODULE {[CCORE]}
go assembly

# Reduce sharing overhead from default of 20% in order to meet clock constraint
# TODO: find the optimal value between 0 and 20
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run -CLOCK_OVERHEAD 0.000000

# set memory for accumulation buffer
for {set i 0}  {$i < 16} {incr i} {
    directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tile_$i:rsc -MAP_TO_MODULE ts6n28hpla256x32m4swbs_tt1v25c.TS6N28HPLA256X32M4SWBS
}

# set registers for arrays

# directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/run/pe.x_reg:rsc -MAP_TO_MODULE {[Register]}
# directive set /conv/systolic_array<DTYPE,1,16,16,7,7,64>/run/pe.y_reg:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/in_tmp:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tmp.value:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/w_tile.value:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/in_tmp2:rsc -MAP_TO_MODULE {[Register]}
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tmp2.value:rsc -MAP_TO_MODULE {[Register]}

#directive set /conv -REGISTER_OUTPUT true

go architect

# ignore read/write memory dependencies for out_tile
# the write_mem and read_mem addresses are always different so there isn't a real dependency
for {set i 0}  {$i < 16} {incr i} {
    ignore_memory_precedences -from if#4:write_mem(out_tile_$i:rsc.@) -to else#2:read_mem(out_tile_$i:rsc.@)
}

go extract

project save

# copy generated RTL to rtl folder
file copy -force [solution get /SOLUTION_DIR]/concat_rtl.v ../rtl/concat_rtl.v

# run simulation in NCSim and create saif dump
# flow run /SCVerify/launch_make [solution get /SOLUTION_DIR]/scverify/Verify_concat_rtl_v_msim.mk {} SIMTOOL=msim sim
