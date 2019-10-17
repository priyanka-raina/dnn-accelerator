set blockname [file rootname [file tail [info script] ]]

source scripts/common.tcl

directive set -DESIGN_HIERARCHY { 
    {conv}
    {SystolicArrayCore<IDTYPE, ODTYPE, 1, 16, 16, 7, 7, 64>}  
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

solution library add {[Block] DoubleBuffer<4096,4096,16,1,16>.v1}
solution library add {[Block] SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>.v1}

go libraries
directive set -CLOCKS {clk {-CLOCK_PERIOD 5 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 2.5 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND sync -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}
directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64> -MAP_TO_MODULE {[Block] SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>.v1}
directive set /conv/DoubleBuffer<4096,4096,16,1,16> -MAP_TO_MODULE {[Block] DoubleBuffer<4096,4096,16,1,16>.v1}

directive set /conv -FIFO_DEPTH 3
directive set /conv/systolicArray -FIFO_DEPTH 3

go assembly

directive set /conv/SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64> -FIFO_DEPTH 3

go architect

go allocate

go extract
