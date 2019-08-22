#ifndef PROCESSING_ELEMENT_H
#define PROCESSING_ELEMENT_H

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

template<typename DTYPE, int KI>
class ProcessingElement{
public:
    ProcessingElement(){}

#pragma hls_design interface ccore
    void CCS_BLOCK(run)(
        DTYPE &input_in,
        PackedStencil<PRECISION, KI, 1, 1> &psum_in,
        PackedStencil<PRECISION, KI, 1, 1> &weight,
        DTYPE &input_out,
        PackedStencil<PRECISION, KI, 1, 1> &psum_out)
    {
        input_reg = input_in;
        weight_reg = weight;
        psum_reg = psum_in;

        MAC: for(int i = 0; i < KI; i++){
            DTYPE tmp = input_reg * weight_reg.read(i, 0, 0) + psum_reg.read(i, 0, 0);
            psum_reg.write(tmp, i, 0, 0, 0);
        }
        
        input_out = input_reg;
        psum_out = psum_reg;
    }

private:
    DTYPE input_reg;
    PackedStencil<PRECISION, KI, 1, 1> weight_reg;
    PackedStencil<PRECISION, KI, 1, 1> psum_reg;
};

#endif
