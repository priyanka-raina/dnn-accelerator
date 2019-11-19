#ifndef PROCESSING_ELEMENT_H
#define PROCESSING_ELEMENT_H

#include "common.h"

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

// #define CCS_BLOCK(x) x

template<typename IDTYPE, typename ODTYPE, int KI>
class ProcessingElement{
public:
    ProcessingElement(){}

#pragma hls_design interface ccore
    void CCS_BLOCK(run)(
        IDTYPE &input_in,
        InputPack<OUTPUT_PRECISION, KI> &psum_in,
        InputPack<INPUT_PRECISION, KI> &weight,
        IDTYPE &input_out,
        InputPack<OUTPUT_PRECISION, KI> &psum_out)
    {
        input_reg = input_in;
        weight_reg = weight;
        psum_reg = psum_in;

        #pragma hls_unroll no
        LABEL(MAC) for(int i = 0; i < KI; i++){
            ODTYPE tmp = input_reg * (IDTYPE)weight_reg.value[i] + psum_reg.value[i];
            psum_reg.value[i] = tmp;
        }
        
        input_out = input_reg;
        psum_out = psum_reg;
    }

private:
    IDTYPE input_reg;
    InputPack<INPUT_PRECISION, KI> weight_reg;
    InputPack<OUTPUT_PRECISION, KI> psum_reg;
};

#endif
