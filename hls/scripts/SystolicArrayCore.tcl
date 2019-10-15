set blockname [file rootname [file tail [info script] ]]

source scripts/common.tcl

directive set -DESIGN_HIERARCHY { 
    {SystolicArrayCore<IDTYPE, ODTYPE, 1, 16, 16, 7, 7, 64>}  
    {conv}
    {InputSkewer<PackedStencil<16UL, 16UL, 1UL, 1UL, 1UL>>}
    {OutputSkewer<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, PackedStencil<32UL, 1UL, 16UL, 1UL, 1UL>, 16>}
    {ProcessingElement<IDTYPE, ODTYPE, 1>} 
    {SystolicArrayWrapper<IDTYPE, ODTYPE, 1, 16, 16, 7, 7, 64>} 
    {SystolicArrayLooper} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 1>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 2>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 3>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 4>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 5>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 6>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 7>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 8>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 9>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 10>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 11>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 12>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 13>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 14>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 15>} 
    {Fifo<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, 16>} 
    {Fifo<IDTYPE, 16>} 
    {Fifo<IDTYPE, 15>} 
    {Fifo<IDTYPE, 14>} 
    {Fifo<IDTYPE, 13>} 
    {Fifo<IDTYPE, 12>} 
    {Fifo<IDTYPE, 11>} 
    {Fifo<IDTYPE, 10>} 
    {Fifo<IDTYPE, 9>} 
    {Fifo<IDTYPE, 8>} 
    {Fifo<IDTYPE, 7>} 
    {Fifo<IDTYPE, 6>} 
    {Fifo<IDTYPE, 5>} 
    {Fifo<IDTYPE, 4>} 
    {Fifo<IDTYPE, 3>} 
    {Fifo<IDTYPE, 2>} 
    {Fifo<IDTYPE, 1>}  
    {DoubleBuffer<4096, 4096, 16, 1, 16>} 
    {WeightBank<4096, 1, 16>} 
    {WeightBankAddressGenerator<4096>} 
    {WeightBankReader<4096, 1, 16>} 
    {WeightBankWriter<4096, 1, 16>} 
    {InputBank<4096, 16>} 
    {InputBankAddressGenerator<4096>} 
    {InputBankReader<4096, 16>}
}

go compile

solution library add tcbn28hplbwphvttt1v25c_dc -- -rtlsyntool DesignCompiler -vendor TSMC -technology 28nm
solution library add ts6n28hpla2048x32m8swbs_tt1v25c
solution library add ts6n28hpla256x32m4swbs_tt1v25c
solution library add ts6n28hpla4096x16m16swbs_tt1v25c
solution library add custom4096X256
solution library add ts6n28hpla256x16m4swbs_tt1v25c

solution library add {[CCORE] InputSkewer<PackedStencil<16UL,16UL,1UL,1UL,1UL>>.v1}
solution library add {[CCORE] ProcessingElement<IDTYPE,ODTYPE,1>.v1}
solution library add {[CCORE] OutputSkewer<PackedStencil<32UL,1UL,1UL,1UL,1UL>,PackedStencil<32UL,1UL,16UL,1UL,1UL>,16>.v1}

go libraries
directive set -CLOCKS {clk {-CLOCK_PERIOD 5 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 2.5 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND sync -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/ProcessingElement<IDTYPE,ODTYPE,1> -MAP_TO_MODULE {[CCORE] ProcessingElement<IDTYPE,ODTYPE,1>.v1}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/InputSkewer<PackedStencil<16UL,16UL,1UL,1UL,1UL>> -MAP_TO_MODULE {[CCORE] InputSkewer<PackedStencil<16UL,16UL,1UL,1UL,1UL>>.v1}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/OutputSkewer<PackedStencil<32UL,1UL,1UL,1UL,1UL>,PackedStencil<32UL,1UL,16UL,1UL,1UL>,16> -MAP_TO_MODULE {[CCORE] OutputSkewer<PackedStencil<32UL,1UL,1UL,1UL,1UL>,PackedStencil<32UL,1UL,16UL,1UL,1UL>,16>.v1}
# directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/OutputSkewer<PackedStencil<32UL,1UL,1UL,1UL,1UL>,PackedStencil<32UL,1UL,16UL,1UL,1UL>,16> -REGISTER_OUTPUT true
# directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64> -OUTPUT_DELAY 4.95

go assembly
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run -DESIGN_GOAL Latency
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run -CLOCK_OVERHEAD 0.000000

directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tile:rsc -INTERLEAVE 16
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tile:rsc -BLOCK_SIZE 256
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tile:rsc -MAP_TO_MODULE ts6n28hpla256x32m4swbs_tt1v25c.TS6N28HPLA256X32M4SWBS
# directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/OutputSkewer<PackedStencil<32UL,1UL,1UL,1UL,1UL>,PackedStencil<32UL,1UL,16UL,1UL,1UL>,16> -REGISTER_OUTPUT true

directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/output:rsc -OUTPUT_DELAY 4.950000

# # Accumulation buffer
# for {set i 0}  {$i < 16} {incr i} {
#     directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tile_$i:rsc -MAP_TO_MODULE ts6n28hpla256x32m4swbs_tt1v25c.TS6N28HPLA256X32M4SWBS
# }

# set registers for arrays
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/in_tmp:rsc -MAP_TO_MODULE {[Register]}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tmp.value:rsc -MAP_TO_MODULE {[Register]}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/w_tile.value:rsc -MAP_TO_MODULE {[Register]}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/in_tmp2:rsc -MAP_TO_MODULE {[Register]}
directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tmp2.value:rsc -MAP_TO_MODULE {[Register]}
go architect

# directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/write_port(106,512) -REGISTER_OUTPUT true
# directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/ccs_ioport.ccs_out_wait(106,512) -REGISTER_OUTPUT true

ignore_memory_precedences -from *:write_mem(*)* -to *:read_mem(*)*
go allocate
go extract
