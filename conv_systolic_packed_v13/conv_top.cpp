#include "DoubleBuffer.h"
#include "SystolicArray.h"
#include "conv.h"

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

#pragma hls_design top

class conv{
public:
    conv(){}

#pragma hls_design interface
#pragma hls_pipeline_init_interval 1
    void CCS_BLOCK(run)(
        ac_channel<NewPackedStencil<PRECISION,CI_NUM> > &input, 
        ac_channel<NewPackedStencil<PRECISION, KII, KI_NUM> > &weight, 
        ac_channel<NewPackedStencil<PRECISION, KII, KI_NUM> > &output,
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

    ac_channel<NewPackedStencil<PRECISION,CI_NUM> > input_out;
    ac_channel<NewPackedStencil<PRECISION,KII, KI_NUM> > weight_out;

    SystolicArray<DTYPE, KII, KI_NUM, CI_NUM, OROW_I, OCOL_I, K_NUM> systolicArray;
    ac_channel<Params> systolicArrayParams;
};
