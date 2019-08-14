#ifndef SYSTOLIC_ARRAY_H
#define SYSTOLIC_ARRAY_H

#include "ProcessingElement.h"
#include "conv.h"
#include "array_dimensions.h"
#include "fifo.h"

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

#define MOD(x,y)\
    ( ( (x) % (y) + y ) % y )

template <typename DTYPE, int K_II, int K_I, int C_I, int X_I, int Y_I, int K>
class SystolicArray
{
public:
    SystolicArray() {}

#pragma hls_design interface
#pragma hls_pipeline_init_interval 1
    void CCS_BLOCK(run)(
        ac_channel<NewPackedStencil<PRECISION, C_I, 1, 1> > &input, 
        ac_channel<NewPackedStencil<PRECISION, K_II, K_I, 1> > &weight, 
        ac_channel<NewPackedStencil<PRECISION, K_II, K_I, 1> > &output,
        ac_channel<Params> &paramsIn)
    {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();

         // TODO: set these hls_unroll pragmas to the TCL script
        #pragma hls_unroll no
        xy_o: for (int p = 0; p < params.X_O * params.Y_O; ++p) { //loop over image tiles        
            #pragma hls_unroll no
            k_oo: for(int koo_idx = 0; koo_idx < params.K_OO; ++koo_idx){ // loop over outer kernel tiles    
                #pragma hls_unroll no
                co: for (int c_idx = 0; c_idx < params.C_O; ++c_idx) { // loop over channel tile
                    #pragma hls_unroll no
                    winx: for (int wx_idx = 0; wx_idx < params.WS; ++wx_idx) { // loop over filter window x
                        #pragma hls_unroll no
                        winy: for (int wy_idx = 0; wy_idx < params.WS; ++wy_idx) { // loop over filter window y
                            #pragma hls_unroll no
                            k_oi: for (int koi_idx = 0; koi_idx < params.K_OI; ++koi_idx) { // loop over kernel tiles
                                #pragma hls_unroll no
                                xy_i: for (int step = 0; step < K_I+C_I+(X_I*Y_I)-1; ++step) { // loop inside each image tile
                                    
                                    // filling phase for systolic array, put data into local registers 
                                    if (step < C_I) {            
                                        NewPackedStencil<PRECISION,K_II, K_I> w_row = weight.read();
                                        w_tile[step] = w_row;
                                        /*#ifndef __SYNTHESIS__
                                        for (int col = 0; col<K_I; col++) {
                                            printf("weight=%d on row  %d, col %d\n", w_row(0,col,0,0), step, col);
                                        }
                                        #endif*/
                                    }

                                    /* read input from the output stream of the double buffer,
                                    push input to fifos, and read input from fifos into local registers*/
                                    NewPackedStencil<PRECISION, C_I,1,1> in_col;
                                    if (step < (X_I*Y_I)) {        
                                    in_col = input.read();
                                    /*#ifndef __SYNTHESIS__
                                    for (int row = 0; row<C_I; row++) {
                                        printf("input=%d on row  %d, col %d\n", in_col(row,0,0,0), step, row);
                                    }
                                    #endif*/
                                    }
                            
                                    // The local registers serve data to the first column of PE array. 
                                    NewPackedStencil<PRECISION, C_I,1,1> input_buf;

                                    /* A trianglar shape of FIFOs, used for skewing the array front,
                                    such that the right input data comes to the right PE at the right timing.*/
                                    #define INPUT_FIFO_BODY(z,i,unused) \
                                    DTYPE BOOST_PP_CAT(input_fifo_output_, i); \
                                    DTYPE BOOST_PP_CAT(input_fifo_input_, i) = read<PRECISION, C_I,1,1>(in_col, i ,0,0); \
                                    BOOST_PP_CAT(input_fifo_, i).run( BOOST_PP_CAT(input_fifo_input_, i) , BOOST_PP_CAT(input_fifo_output_, i) ); \
                                    write<PRECISION, C_I,1,1>(input_buf, BOOST_PP_CAT(input_fifo_output_, i), i ,0,0,0);
                                    REPEAT(INPUT_FIFO_BODY)
                            
                                    /*#ifndef __SYNTHESIS__
                                    printf("starting step %d - input %d %d %d %d\n", step, input_fifo_0,input_fifo_1,input_fifo_2,input_fifo_3);
                                    #endif*/

                                    #define TMP_ROW_BODY(z,i,unused) \
                                    NewPackedStencil<PRECISION, K_II, 1, 1, 1> BOOST_PP_CAT(tmp_row_, i);
                                    REPEAT(TMP_ROW_BODY)

                                    NewPackedStencil<PRECISION, K_II, K_I,1> output_buf;
                                    // initial partial output of 0
                                    if(c_idx == 0 && wx_idx == 0 && wy_idx == 0) {
                                    #pragma hls_unroll yes           
                                    for (int sk = 0; sk < K_II; sk++) {
                                        #define TMP_ROW_BODY_INIT(z,i,unused) \
                                        write<PRECISION, K_II, 1, 1, 1>(BOOST_PP_CAT(tmp_row_, i), 0,sk,0,0,0);
                                        REPEAT(TMP_ROW_BODY_INIT)
                                    }
                                    }
                                    else{
                                    #define TMP_ROW_OUT(z,i,unused) \
                                        BOOST_PP_CAT(tmp_row_, i) = BOOST_PP_CAT(out_tile_, i)[ MOD( (koi_idx*(X_I*Y_I) + step + K_I- i), 256) ];
                                        REPEAT(TMP_ROW_OUT)
                                    }

                                    #define TMP_FIFO_BODY(z,i,unused) \
                                    set_dim<PRECISION, K_II, K_I,1>(output_buf, BOOST_PP_CAT(tmp_row_, i), i,0,0);
                                    REPEAT(TMP_FIFO_BODY)

                                    /*#ifndef __SYNTHESIS__
                                    printf("starting step %d - partial result %d %d %d %d\n", step, tmp_fifo_0,tmp_fifo_1,tmp_fifo_2,tmp_fifo_3);
                                    #endif*/
                            
                                    //initialize the input registers in the first column 
                                    #pragma hls_unroll yes
                                    INIT_IN: for(int i = 0; i < C_I; ++i) {
                                        in_tmp[i+1][0] = read<PRECISION, C_I,1,1>(input_buf, i,0,0);
                                    }
                                
                                    //initialize the output registers in the first row 
                                    #pragma hls_unroll yes
                                    INIT_OUT: for(int j = 0; j < K_I; ++j) {
                                        out_tmp[0][j+1] = get_dim<PRECISION, K_II, K_I,1>(output_buf, j, 0, 0);
                                    }
                                
                                    static DTYPE in_tmp2[C_I+1][K_I+1];
                                    static NewPackedStencil<PRECISION, K_II, 1, 1> out_tmp2[C_I+1][K_I+1];

                                    // perform the a matrix multiplication in a systolic fashion 
                                    #pragma hls_unroll yes
                                    COL: for (int j=0; j < K_I; ++j) {
                                        #pragma hls_unroll yes
                                        ROW: for (int i=0; i < C_I; ++i) {
                                        NewPackedStencil<PRECISION, K_II> weight_value = get_dim<PRECISION,K_II, K_I>(w_tile[i], j,0,0);
                                        pe[i][j].run(in_tmp[i+1][j], out_tmp[i][j+1], weight_value, in_tmp2[i+1][j+1], out_tmp2[i+1][j+1]);
                                        } //ROW
                                    } //COL

                                
                            
                                    /* A trianglar shape of FIFOs, used for skewing as well, 
                                    such that the right output data are collected at the right timing*/ 
                                    NewPackedStencil<PRECISION, K_II, K_I> output_row;
                                
                                    #define FIFO_WRITE_BODY(z,i,unused)\
                                        NewPackedStencil<PRECISION, K_II> BOOST_PP_CAT(sys_array_out_,i) = out_tmp[C_I][i+1];
                                    REPEAT(FIFO_WRITE_BODY)


                                    /*#ifndef __SYNTHESIS__
                                        printf("ending step %d - output %d %d %d %d\n", step, output_fifo_0,output_fifo_1,output_fifo_2,output_fifo_3);
                                    #endif*/
                                
                                    if (c_idx==params.C_O-1 && wx_idx == params.WS-1 && wy_idx == params.WS-1) {
                                        #define FIFO_WRITE_BODY_NEW(z,i,unused)\
                                            NewPackedStencil<PRECISION, K_II> BOOST_PP_CAT(output_fifo_output_, i); \
                                            BOOST_PP_CAT(output_fifo_, i).run( BOOST_PP_CAT(sys_array_out_, i) , BOOST_PP_CAT(output_fifo_output_, i) );\
                                            set_dim<PRECISION, K_II, K_I>(output_row, BOOST_PP_CAT(output_fifo_output_,i), i,0,0); 
                                        REPEAT(FIFO_WRITE_BODY_NEW)

                                        
                                        }

                                        if(step >= K_I){
                                        #define OUTPUT_ROW_BODY(z,i,unused)\
                                            BOOST_PP_CAT(out_tile_,i)[ MOD( (koi_idx*(X_I*Y_I)+step-(K_I)+K_I-i), 256) ] = BOOST_PP_CAT(sys_array_out_,i);
                                        REPEAT(OUTPUT_ROW_BODY)
                                        }

                                    // output row if one has completed
                                    if (step >= K_I+C_I-1) {
                                        if (c_idx==params.C_O-1 && wx_idx == params.WS-1 && wy_idx == params.WS-1) {
                                        output.write(output_row);
                                        }
                                    }

                                    
                                    #pragma hls_unroll yes
                                    for(int j = 0; j < K_I; j++){
                                        #pragma hls_unroll yes
                                        for(int i = 0; i < C_I; i++){
                                        in_tmp[i+1][j+1] = in_tmp2[i+1][j+1];
                                        out_tmp[i+1][j+1] = out_tmp2[i+1][j+1];
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }
        }
    }

private:
    // C_I x K_I PE array
    ProcessingElement<DTYPE, K_II> pe[C_I + 1][K_I + 1];

// local buffers to store partial output
#define OUT_TILE_INIT(z, i, unused) \
    ac_int<PRECISION * K_II, false> BOOST_PP_CAT(out_tile_, i)[256];
    REPEAT(OUT_TILE_INIT)

#define INPUT_FIFOS_INIT(z, i, unused) \
    Fifo<DTYPE, i + 1> BOOST_PP_CAT(input_fifo_, i);
    REPEAT(INPUT_FIFOS_INIT)

#define OUTPUT_FIFOS_INIT(z, i, unused) \
    Fifo<NewPackedStencil<PRECISION, K_II>, K_I - i> BOOST_PP_CAT(output_fifo_, i);
    REPEAT(OUTPUT_FIFOS_INIT)

    NewPackedStencil<PRECISION,K_II, K_I> w_tile[C_I];

    /*
  the registers that used for relaying input and output in horizonal and vertical directions respectively.
  PE[i][j] fetch input data from register in_tmp[i+1][j], at next cycle forward the data to in_tmp[i+1][j+1]
  PE[i][j] fetch output data from register out_tmp[i][j+1], at next cycle forward the data to out_tmp[i+1][j+1]
  */
    DTYPE in_tmp[C_I + 1][K_I + 1];
    NewPackedStencil<PRECISION, K_II, 1, 1> out_tmp[C_I + 1][K_I + 1];
};
#endif
