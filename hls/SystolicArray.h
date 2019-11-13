#ifndef SYSTOLIC_ARRAY_H
#define SYSTOLIC_ARRAY_H

#include "ProcessingElement.h"
#include "conv.h"
#include "array_dimensions.h"
#include "fifo.h"
#include "Stencil_catapult.h"
#include "InputSkewer.h"
#include "OutputSkewer.h"
#include "SystolicArrayCore.h"


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

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>
// #define CCS_BLOCK(x) x


class SystolicArrayLooper
{
public:
    SystolicArrayLooper() {}

#pragma hls_design interface
void run(
        ac_channel<Params> &paramsIn,
        ac_channel<LoopParams> &loopParamsChannel)
        {
            #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();
            // TODO: set these hls_unroll pragmas to the TCL script
            #pragma hls_unroll no
            LABEL(xy_o) for (int p = 0; p < params.X_O * params.Y_O; ++p) { //loop over image tiles        
                #pragma hls_unroll no
                LABEL(k_oo) for(int koo_idx = 0; koo_idx < params.K_OO; ++koo_idx){ // loop over outer kernel tiles    
                    #pragma hls_unroll no
                    LABEL(co) for (int c_idx = 0; c_idx < params.C_O; ++c_idx) { // loop over channel tile
                        #pragma hls_unroll no
                        LABEL(winx) for (int wx_idx = 0; wx_idx < params.WS; ++wx_idx) { // loop over filter window x
                            #pragma hls_unroll no
                            LABEL(winy) for (int wy_idx = 0; wy_idx < params.WS; ++wy_idx) { // loop over filter window y
                                #pragma hls_unroll no
                                LABEL(k_oi) for (int koi_idx = 0; koi_idx < params.K_OI; ++koi_idx) { // loop over kernel tiles
                                    // #pragma hls_unroll no
                                    // LABEL(xy_i) for (int step = 0; step < params.K_I+params.C_I+(params.X_I*params.Y_I)-1; ++step) { // loop inside each image tile
                                        LoopParams loopParams = {
                                            params.C_O,
                                            params.WS, 
                                            c_idx, 
                                            wx_idx, 
                                            wy_idx, 
                                            koi_idx,
                                            params.X_I,
                                            params.Y_I,
                                            params.K_OO,
                                            params.K_OI 
                                            
                                            
                                            // step < C_I, // read new row of weights
                                            // step < (X_I*Y_I), // read new column of inputs
                                            // c_idx == 0 && wx_idx == 0 && wy_idx == 0, // clear buffer of partial sums
                                            // c_idx == params.C_O-1 && wx_idx == params.WS-1 && wy_idx == params.WS-1, // finished accumulating
                                            // step >= K_I, // have good output to store 
                                            // step >= K_I+C_I-1 // have final output
                                            
                                        };
                                        loopParamsChannel.write(loopParams);
                                    // }
                                }
                            }
                        }
                    }
                }
            }
        }
        }

};

template <typename IDTYPE, typename ODTYPE, int K_II, int K_I, int C_I>
class SystolicArrayWrapper
{
public:
    SystolicArrayWrapper(){}
    
#pragma hls_design interface
#pragma hls_pipeline_init_interval 1
    void run(
        ac_channel<InputPack<INPUT_PRECISION, C_I> > &input, 
        ac_channel<WeightPack<INPUT_PRECISION, K_II, K_I> > &weight, 
        ac_channel<WeightPack<OUTPUT_PRECISION, K_II, K_I> > &output,
        ac_channel<Params> &paramsIn)
    {
        systolicArrayLooper.run(paramsIn, loopParamsChannel);
        systolicArrayCore.run(input, weight, output, loopParamsChannel);
        // systolicArrayCore.run(input, weight,output,paramsIn);
    }
private:
    SystolicArrayCore<IDTYPE, ODTYPE, K_II, K_I, C_I> systolicArrayCore;
    SystolicArrayLooper systolicArrayLooper;
    ac_channel<LoopParams> loopParamsChannel;
};

#endif
