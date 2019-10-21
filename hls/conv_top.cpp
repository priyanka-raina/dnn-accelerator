#ifndef CONV_TOP_CPP
#define CONV_TOP_CPP


#ifdef __SYNTHESIS__
    #define LABEL(x) x:
#else
    #define LABEL(x) {}
#endif


// #ifndef CCS_BLOCK
// #define CCS_BLOCK(x) x
// #endif

#include "Stencil_catapult.h"
#include "conv.h"
#include <mc_scverify.h>

#include "DoubleBuffer.h"
#include "SystolicArray.h"

// Include mc_scverify.h for CCS_* macros
// #undef CCS_SCVERIFY
// #include <mc_scverify.h>
// #define CCS_VERIFY
// #define CCS_BLOCK(x) x


#pragma hls_design top
class conv{
public:
    conv(){}

#pragma hls_design interface
#pragma hls_pipeline_init_interval 1
    void CCS_BLOCK(run)(
        ac_channel<PackedStencil<INPUT_PRECISION,CI_NUM> > &input, 
        ac_channel<PackedStencil<INPUT_PRECISION, KII, KI_NUM> > &weight, 
        ac_channel<PackedStencil<OUTPUT_PRECISION, KII, KI_NUM> > &output,
        ac_channel<Params> &paramsIn
    )
    {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();
            doubleBufferParams.write(params);
            systolicArrayParams.write(params);

            doubleBuffer.run(input, input_out, weight, weight_out, doubleBufferParams);
            systolicArray.run(input_out, weight_out, output, systolicArrayParams);
        }

    }

private:
    DoubleBuffer<INPUT_SIZE, WEIGHT_SIZE, CI_NUM, KII, KI_NUM> doubleBuffer;
    ac_channel<Params> doubleBufferParams;

    ac_channel<PackedStencil<INPUT_PRECISION,CI_NUM> > input_out;
    ac_channel<PackedStencil<INPUT_PRECISION,KII, KI_NUM> > weight_out;

    SystolicArrayWrapper<IDTYPE, ODTYPE, KII, KI_NUM, CI_NUM> systolicArray;
    ac_channel<Params> systolicArrayParams;
};

#endif
