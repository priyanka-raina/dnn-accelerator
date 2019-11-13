#ifndef INPUT_SKEWER_H
#define INPUT_SKEWER_H

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

template<typename T>
class InputSkewer
{
public:
    InputSkewer(){}
    
// #pragma hls_design interface ccore
// #pragma hls_pipeline_init_interval 1
    void CCS_BLOCK(run)(T &input, T &output){
        
        #define INPUT_FIFO_BODY(z,i,unused) \
            IDTYPE BOOST_PP_CAT(input_fifo_output_, i); \
            IDTYPE BOOST_PP_CAT(input_fifo_input_, i) = input.read(i ,0,0); \
            BOOST_PP_CAT(input_fifo_, i).run( BOOST_PP_CAT(input_fifo_input_, i) , BOOST_PP_CAT(input_fifo_output_, i) ); \
            output.write(BOOST_PP_CAT(input_fifo_output_, i), i ,0,0,0);
        
        REPEAT(INPUT_FIFO_BODY)
    }

private:

#define INPUT_FIFOS_INIT(z, i, unused) \
    Fifo<IDTYPE, i + 1> BOOST_PP_CAT(input_fifo_, i);

REPEAT(INPUT_FIFOS_INIT)

};

#endif
