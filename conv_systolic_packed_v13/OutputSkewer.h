#ifndef OUTPUT_SKEWER_H
#define OUTPUT_SKEWER_H

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

#include "fifo.h"
#include "conv.h"
#include "array_dimensions.h"
#include "Stencil_catapult.h"

#include <boost/preprocessor/repetition/repeat.hpp>
#include <boost/preprocessor/punctuation/comma_if.hpp>
#include <boost/preprocessor/cat.hpp>
#include <boost/preprocessor/arithmetic/inc.hpp>
#include <boost/preprocessor/comparison/not_equal.hpp>
#include <boost/preprocessor/repetition/for.hpp>
#include <boost/preprocessor/tuple/elem.hpp>
#include <boost/preprocessor/tuple/size.hpp>
#include <boost/preprocessor/control/if.hpp>
#include <boost/preprocessor/punctuation/comma.hpp>
#include <boost/preprocessor/arithmetic/dec.hpp>

template<typename IT, typename OT, int K_I>
class OutputSkewer
{
public:
    OutputSkewer(){}
    
#pragma hls_design interface ccore
    void run(IT input[K_I], OT &output){
        #define READ_REG(z,i,unused) \
            IT BOOST_PP_CAT(sys_array_out_,i) = input[i+1];
        REPEAT(READ_REG)
        
        #define OUTPUT_FIFO_WRITE(z,i,unused) \
            IT BOOST_PP_CAT(output_fifo_output_, i); \
            BOOST_PP_CAT(output_fifo_, i).run( BOOST_PP_CAT(sys_array_out_, i) , BOOST_PP_CAT(output_fifo_output_, i) );\
            output.set_dim(BOOST_PP_CAT(output_fifo_output_,i), i,0,0); 
            
        REPEAT(OUTPUT_FIFO_WRITE)
    }

private:

#define OUTPUT_FIFOS_INIT(z, i, unused) \
    Fifo<IT, K_I - i> BOOST_PP_CAT(output_fifo_, i);

REPEAT(OUTPUT_FIFOS_INIT)

};

#endif
