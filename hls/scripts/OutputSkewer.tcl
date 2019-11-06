set blockname [file rootname [file tail [info script] ]]

source scripts/common.tcl

directive set -DESIGN_HIERARCHY { 
    {OutputSkewer<PackedStencil<32UL, 1UL, 1UL, 1UL, 1UL>, PackedStencil<32UL, 1UL, 16UL, 1UL, 1UL>, 16>}

}
if { 0 } {
    {conv}
    {InputSkewer<PackedStencil<16UL, 16UL, 1UL, 1UL, 1UL>>}
    {ProcessingElement<IDTYPE, ODTYPE, 1>} 
    {SystolicArrayCore<IDTYPE, ODTYPE, 1, 16, 16>}  
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
source scripts/set_libraries.tcl
go libraries
directive set -CLOCKS {clk {-CLOCK_PERIOD 5 -CLOCK_EDGE rising -CLOCK_HIGH_TIME 2.5 -CLOCK_OFFSET 0.000000 -CLOCK_UNCERTAINTY 0.0 -RESET_KIND sync -RESET_SYNC_NAME rst -RESET_SYNC_ACTIVE high -RESET_ASYNC_NAME arst_n -RESET_ASYNC_ACTIVE low -ENABLE_NAME {} -ENABLE_ACTIVE high}}
go assembly
# directive set /ProcessingElement<IDTYPE,ODTYPE,1>/run -DESIGN_GOAL Latency
# directive set /ProcessingElement<IDTYPE,ODTYPE,1>/run -CLOCK_OVERHEAD 0.000000
go extract
