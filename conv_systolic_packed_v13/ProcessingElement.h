#ifndef PROCESSING_ELEMENT_H
#define PROCESSING_ELEMENT_H

// Include mc_scverify.h for CCS_* macros
// #include <mc_scverify.h>

// #define CCS_BLOCK(x) x

template<typename IDTYPE, typename ODTYPE, int KI>
class ProcessingElement{
public:
    ProcessingElement(){}

#pragma hls_design interface ccore
    void run(
        IDTYPE &input_in,
        PackedStencil<OUTPUT_PRECISION, KI, 1, 1> &psum_in,
        PackedStencil<INPUT_PRECISION, KI, 1, 1> &weight,
        IDTYPE &input_out,
        PackedStencil<OUTPUT_PRECISION, KI, 1, 1> &psum_out)
    {
        input_reg = input_in;
        weight_reg = weight;
        psum_reg = psum_in;

        LABEL(MAC) for(int i = 0; i < KI; i++){
            ODTYPE tmp = input_reg * (IDTYPE)weight_reg.read(i, 0, 0) + psum_reg.read(i, 0, 0);
            psum_reg.write(tmp, i, 0, 0, 0);
        }
        
        input_out = input_reg;
        psum_out = psum_reg;
    }

private:
    IDTYPE input_reg;
    PackedStencil<INPUT_PRECISION, KI, 1, 1> weight_reg;
    PackedStencil<OUTPUT_PRECISION, KI, 1, 1> psum_reg;
};

#endif
