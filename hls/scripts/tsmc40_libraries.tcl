solution options set ComponentLibs/SearchPath {{$MGC_HOME/pkgs/siflibs} {$MGC_HOME/shared/include/calypto_mem} {$MGC_HOME/pkgs/siflibs/designcompiler} {$MGC_HOME/pkgs/siflibs/rtlcompiler} {$MGC_HOME/pkgs/siflibs/oasysrtl} {$MGC_HOME/pkgs/siflibs/nangate} {$MGC_HOME/pkgs/ccs_altera} {$MGC_HOME/pkgs/ccs_xilinx} {$MGC_HOME/pkgs/siflibs/synplifypro} {$MGC_HOME/pkgs/siflibs/origami} {$MGC_HOME/pkgs/siflibs/microsemi} {$MGC_HOME/pkgs/ccs_libs/interfaces/amba} /home/kprabhu7/characterization/tcbn40lpbwptc_dc.char /home/kprabhu7/catapult_memory/outputs}

solution library remove *
solution library add tcbn40lpbwptc_dc -- -rtlsyntool DesignCompiler -vendor TSMC -technology 40nm
solution library add tsdn40lpa256x16m16f_tt1p1v25c
solution library add tsdn40lpa256x32m8f_tt1p1v25c
solution library add custom4096x256


set accum_buffer_module tsdn40lpa256x32m8f_tt1p1v25c.TSDN40LPA256X32M8F