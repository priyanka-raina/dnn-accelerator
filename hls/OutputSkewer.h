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
    void run(OT &input, OT &output){
        OT tmp_output;
        #define OUTPUT_FIFO_WRITE(z,i,unused) \
            IT BOOST_PP_CAT(output_fifo_output_, i); \
            IT BOOST_PP_CAT(output_fifo_input_, i); \
            BOOST_PP_CAT(output_fifo_input_, i).value = input.read(0,i,0,0); \
            BOOST_PP_CAT(output_fifo_, i).run( BOOST_PP_CAT(output_fifo_input_, i) , BOOST_PP_CAT(output_fifo_output_, i) );\
            tmp_output.set_dim(BOOST_PP_CAT(output_fifo_output_,i), i,0,0); 
            
        REPEAT(OUTPUT_FIFO_WRITE)

        output = tmp_output;
    }

private:

#define OUTPUT_FIFOS_INIT(z, i, unused) \
    Fifo<IT, K_I - i> BOOST_PP_CAT(output_fifo_, i);

REPEAT(OUTPUT_FIFOS_INIT)

};

#endif
