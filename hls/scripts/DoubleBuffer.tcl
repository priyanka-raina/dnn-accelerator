set blockname [file rootname [file tail [info script] ]]

source scripts/common.tcl

directive set -DESIGN_HIERARCHY { 
    {DoubleBuffer<4096, 4096, 16, 16, 1>} 
}
if { 0 } {
    {conv}
    {SystolicArrayCore<IDTYPE, ODTYPE, 1, 16, 16>}  
    {InputSkewer<PackedStencil<16UL, 16UL, 1UL, 1UL, 1UL>>}
    {OutputSkewer<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, PackedStencil<32UL, 1UL, 16UL, 1UL, 1UL>, 16>}
    {ProcessingElement<IDTYPE, ODTYPE, 1>} 
    {SystolicArrayWrapper<IDTYPE, ODTYPE, 1, 16, 16>} 
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
    {WeightBank<4096, 1, 16>} 
    {WeightBankAddressGenerator<4096>} 
    {WeightBankReader<4096, 1, 16>} 
    {WeightBankWriter<4096, 1, 16>} 
    {InputBank<4096, 16>} 
    {InputBankAddressGenerator<4096>} 
    {InputBankReader<4096, 16>}
}

go compile

source scripts/set_libraries.tcl

go libraries
directive set -CLOCKS {clk {-CLOCK_PERIOD 5 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 2.5 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND sync -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}

# directive set /DoubleBuffer -OUTPUT_DELAY 4.95

go assembly

directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/din -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/din/WORD_WIDTH 256
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/dout:rsc -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/dout:rsc/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/dout -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/dout/WORD_WIDTH 256
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBank<4096,16>/mem:cns -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/InputBank<4096,16>/mem:cns/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBank<4096,16>/mem:cns -STAGE_REPLICATION 2
# /DoubleBuffer<4096,4096,16,16,1>/InputBank<4096,16>/mem:cns/STAGE_REPLICATION 2
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBank<4096,16>/mem -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/InputBank<4096,16>/mem/WORD_WIDTH 256
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/din:rsc -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/din:rsc/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/din -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/din/WORD_WIDTH 256
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/dout:rsc -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/dout:rsc/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/dout -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/dout/WORD_WIDTH 256
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBank<4096,16,1>/mem:cns -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/WeightBank<4096,16,1>/mem:cns/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBank<4096,16,1>/mem:cns -STAGE_REPLICATION 2
# /DoubleBuffer<4096,4096,16,16,1>/WeightBank<4096,16,1>/mem:cns/STAGE_REPLICATION 2
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBank<4096,16,1>/mem -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/WeightBank<4096,16,1>/mem/WORD_WIDTH 256

# directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/run/while:tmp.data.value:rsc -GEN_EXTERNAL_ENABLE true
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/run/while:tmp.data.value:rsc -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/run/while:tmp.data.value:rsc/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/run/while:tmp.data.value -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/InputBankReader<4096,16>/run/while:tmp.data.value/WORD_WIDTH 256
# directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/run/while:tmp.data.value:rsc -GEN_EXTERNAL_ENABLE true
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/run/while:tmp.data.value:rsc/GEN_EXTERNAL_ENABLE true
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/run/while:tmp.data.value:rsc -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/run/while:tmp.data.value:rsc/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/run/while:tmp.data.value -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankWriter<4096,16,1>/run/while:tmp.data.value/WORD_WIDTH 256
# directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/run/while:tmp.data.value:rsc -GEN_EXTERNAL_ENABLE true
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/run/while:tmp.data.value:rsc/GEN_EXTERNAL_ENABLE true
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/run/while:tmp.data.value:rsc -MAP_TO_MODULE $double_buffer_module
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/run/while:tmp.data.value:rsc/MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/run/while:tmp.data.value -WORD_WIDTH 256
# /DoubleBuffer<4096,4096,16,16,1>/WeightBankReader<4096,16,1>/run/while:tmp.data.value/WORD_WIDTH 256
# directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/run/while:tmp.data.value:rsc -GEN_EXTERNAL_ENABLE true
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/run/while:tmp.data.value:rsc -MAP_TO_MODULE $double_buffer_module
directive set /DoubleBuffer<4096,4096,16,16,1>/InputBankWriter<4096,16>/run/while:tmp.data.value -WORD_WIDTH 256

# # Accumulation buffer
# for {set i 0}  {$i < 16} {incr i} {
#     directive set /SystolicArrayCore<IDTYPE,ODTYPE,1,16,16,7,7,64>/run/out_tile_$i:rsc -MAP_TO_MODULE ts6n28hpla256x32m4swbs_tt1v25c.TS6N28HPLA256X32M4SWBS
# }

# set registers for arrays

go architect

go allocate
go extract
