// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

// feedback path too long
#include "double_buffer.cpp"
#include "conv.h"

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


#define ARRAY_DIMENSION 4
#define REPEAT(x) BOOST_PP_REPEAT(ARRAY_DIMENSION, x, 0)

template<typename DTYPE, int KI>
class pe_template{
  private:
    DTYPE x_reg;
    PackedStencil<DTYPE, KI, 1, 1> y_reg;
  public:
    void exec(DTYPE &x_in, PackedStencil<DTYPE, KI, 1, 1> &y_in, PackedStencil<DTYPE, KI, 1, 1> &w, DTYPE &x_out, PackedStencil<DTYPE, KI, 1, 1> &y_out) {
        x_out = x_reg;
        y_out = y_reg;
        x_reg = x_in;
        y_reg = y_in; 
        COMP: for (int i = 0; i < KI; i++) {
            DTYPE tmp = x_reg * w(i, 0, 0) + y_reg(i, 0, 0);
            y_reg(tmp, i, 0, 0, 0);
        }
    }
};

/*
The systolic array is 4 X 4. unrolling C_I (=4) channels amd K_I (=4) kernels.
The input and output of systolic array are streams of input, weight and output.
*/
#pragma hls_design 
#pragma hls_pipeline_init_interval 1
template<typename DTYPE, int K_II, int K_I, int Y_I, int X_I, int Y_O, int X_O, int C_I, int K_O, int C_O, int WS>
bool systolic_array(ac_channel<PackedStencil<DTYPE, C_I, 1, 1> > &input, 
                    ac_channel<PackedStencil<DTYPE, K_II, K_I, 1> > &weight, 
                    ac_channel<PackedStencil<DTYPE, K_II, K_I, 1> > &output) {

  const int XY_I = X_I * Y_I;
  const int XY_O = X_O * Y_O;

  // C_I x K_I PE array
  static pe_template<DTYPE, K_II> pe[C_I+1][K_I+1];

  // local buffers to store partial output 
  // There are four of them because K_I = 4 
  #define OUT_TILE_INIT(z,i,unused)\
    PackedStencil<DTYPE, K_II, 1, 1> BOOST_PP_CAT(out_tile_,i)[XY_I*K_O];   
  REPEAT(OUT_TILE_INIT)

  /*
  the registers that used for relaying input and output in horizonal and vertical directions respectively.
  PE[i][j] fetch input data from register in_tmp[i+1][j], at next cycle forward the data to in_tmp[i+1][j+1]
  PE[i][j] fetch output data from register out_tmp[i][j+1], at next cycle forward the data to out_tmp[i+1][j+1]
  */
  DTYPE in_tmp[C_I+1][K_I+1];
  PackedStencil<DTYPE, K_II, 1, 1> out_tmp[C_I+1][K_I+1];
  // loop over image tiles
  xy_o: for (int p = 0; p < XY_O; ++p) {
  // loop over channel tile
  co: for (int c_idx = 0; c_idx < C_O; ++c_idx) {
  // loop over filter window
  winx: for (int wx_idx = 0; wx_idx < WS; ++wx_idx) {
  winy: for (int wy_idx = 0; wy_idx < WS; ++wy_idx) {
  // loop over kernel tiles
  ko: for (int k_idx = 0; k_idx < K_O; ++k_idx) {
  // loop inside each image tile
  xy_i: for (int step = 0; step < K_I+C_I+XY_I-1; ++step) {
        static PackedStencil<DTYPE,K_II, K_I> w_tile[C_I];
  
        // filling phase for systolic array, put data into local registers 
        if (step < C_I) {            
          PackedStencil<DTYPE,K_II, K_I> w_row = weight.read();
          w_tile[step] = w_row;
          /*#ifndef __SYNTHESIS__
          for (int col = 0; col<K_I; col++) {
            printf("weight=%d on row  %d, col %d\n", w_row(0,col,0,0), step, col);
          }
          #endif*/
  
        }
  
        /* read input from the output stream of the double buffer,
        push input to fifos, and read input from fifos into local registers*/
        PackedStencil<DTYPE, C_I,1,1> in_col;
        if (step < XY_I) {        
          in_col = input.read();
          /*#ifndef __SYNTHESIS__
          for (int row = 0; row<C_I; row++) {
            printf("input=%d on row  %d, col %d\n", in_col(row,0,0,0), step, row);
          }
          #endif*/
  
        }
 
        // The local registers serve data to the first column of PE array. 
        PackedStencil<DTYPE, C_I,1,1> input_buf;

        /* A trianglar shape of FIFOs, used for skewing the array front,
        such that the right input data comes to the right PE at the right timing.*/
        #define INPUT_FIFO_BODY(z,i,unused) \
          BOOST_PP_CAT(DTYPE input_fifo_, i); \
          fifo<60000+i,DTYPE,i+1>( in_col(i ,0,0), BOOST_PP_CAT(input_fifo_, i));\
          input_buf( BOOST_PP_CAT(input_fifo_, i), i ,0,0,0);
        REPEAT(INPUT_FIFO_BODY)
  
        /*#ifndef __SYNTHESIS__
        printf("starting step %d - input %d %d %d %d\n", step, input_fifo_0,input_fifo_1,input_fifo_2,input_fifo_3);
        #endif*/
  

        // local registers to store partial output
        #define TMP_ROW_BODY(z,i,unused) \
          PackedStencil<DTYPE, K_II, 1, 1, 1> BOOST_PP_CAT(tmp_row_, i);
        REPEAT(TMP_ROW_BODY)

        if (step < XY_I) {
          if(c_idx == 0 && wx_idx == 0 && wy_idx == 0) {
                #pragma hls_unroll yes           
                for (int sk = 0; sk < K_II; sk++) {
                  #define TMP_ROW_BODY_INIT(z,i,unused) \
                    BOOST_PP_CAT(tmp_row_, i)(0,sk,0,0,0);
                  REPEAT(TMP_ROW_BODY_INIT)

                }
          } else {
            #define TMP_ROW_OUT(z,i,unused) \
              BOOST_PP_CAT(tmp_row_, i) = BOOST_PP_CAT(out_tile_, i)[k_idx*XY_I + step];
            REPEAT(TMP_ROW_OUT)

          }
        }
       
        /* A trianglar shape of FIFOs, used for skewing the array front, 
        such that the right partial output data come to the right PE at the right timing*/ 
        PackedStencil<DTYPE, K_II, K_I,1> output_buf;
          
        #define TMP_FIFO_BODY(z,i,unused) \
          PackedStencil<DTYPE, K_II> BOOST_PP_CAT(tmp_fifo_,i);\
          fifo<90000+i,PackedStencil<DTYPE,K_II>, i+1>( BOOST_PP_CAT(tmp_row_,i), BOOST_PP_CAT(tmp_fifo_,i) );\
          output_buf.set_dim( BOOST_PP_CAT(tmp_fifo_, i), i,0,0);
        REPEAT(TMP_FIFO_BODY)
      
          /*#ifndef __SYNTHESIS__
          printf("starting step %d - partial result %d %d %d %d\n", step, tmp_fifo_0,tmp_fifo_1,tmp_fifo_2,tmp_fifo_3);
          #endif*/
   
          //initialize the input registers in the first column 
          #pragma hls_unroll yes
          INIT_IN: for(int i = 0; i < C_I; ++i) {
            in_tmp[i+1][0] = input_buf(i,0,0);
          }
    
          //initialize the output registers in the first row 
          #pragma hls_unroll yes
          INIT_OUT: for(int j = 0; j < K_I; ++j) {
            out_tmp[0][j+1] = output_buf.get_dim(j, 0, 0);
          }
    
          // perform the a matrix multiplication in a systolic fashion 
          #pragma hls_unroll yes
          COL: for (int j=0; j < K_I; ++j) {
            #pragma hls_unroll yes
            ROW: for (int i=0; i < C_I; ++i) {
              PackedStencil<DTYPE, K_II> weight_value = w_tile[i].get_dim(j,0,0);
              pe[i][j].exec(in_tmp[i+1][j], out_tmp[i][j+1], weight_value, in_tmp[i+1][j+1], out_tmp[i+1][j+1]);
            } //ROW
          } //COL
  
          /* A trianglar shape of FIFOs, used for skewing as well, 
          such that the right output data are collected at the right timing*/ 
          PackedStencil<DTYPE, K_II, K_I> output_row;
    
          #define FIFO_WRITE_BODY(z,i,unused)\
            PackedStencil<DTYPE, K_II> BOOST_PP_CAT(sys_array_out_,i) = out_tmp[C_I][i+1];\
            PackedStencil<DTYPE, K_II> BOOST_PP_CAT(output_fifo_,i); \
            fifo<0+i,PackedStencil<DTYPE, K_II>, K_I-i>( BOOST_PP_CAT(sys_array_out_,i), BOOST_PP_CAT(output_fifo_,i) );\
            output_row.set_dim( BOOST_PP_CAT(output_fifo_,i), i,0,0); 
          REPEAT(FIFO_WRITE_BODY)

          /*#ifndef __SYNTHESIS__
            printf("ending step %d - output %d %d %d %d\n", step, output_fifo_0,output_fifo_1,output_fifo_2,output_fifo_3);
          #endif*/
    
          // output row if one has completed
          if (step >= K_I+C_I-1) {
            #define OUTPUT_ROW_BODY(z,i,unused)\
              BOOST_PP_CAT(out_tile_,i)[k_idx*XY_I+step-(K_I+C_I-1)] = BOOST_PP_CAT(output_fifo_,i);
            REPEAT(OUTPUT_ROW_BODY)

            if (c_idx==C_O-1 && wx_idx == WS-1 && wy_idx == WS-1) {
              output.write(output_row);
            }
          }
    } //STEPS
    } //K_O
    } //WS
    } //WS
    } //C_O
    } //XY_O
    return true;
}


  // Macros used for for-loop 
  #define PRED(r, state) \
    BOOST_PP_NOT_EQUAL( \
      BOOST_PP_TUPLE_ELEM(2, 0, state), \
      BOOST_PP_TUPLE_ELEM(2, 1, state) \
    ) \

  #define OP(r, state) \
  ( \
      BOOST_PP_INC(BOOST_PP_TUPLE_ELEM(2, 0, state)), \
      BOOST_PP_TUPLE_ELEM(2, 1, state) \
  ) \

#define PARAMS_STREAM_GENERATOR(r,state)\
  BOOST_PP_COMMA_IF( BOOST_PP_TUPLE_ELEM(2,0,state) ) ac_channel<Params> &BOOST_PP_CAT(params_level_, BOOST_PP_TUPLE_ELEM(2,0,state))

// Read in main stream and split into two for each buffer
#pragma hls_design block
void params_generator(ac_channel<Params> &main_params_stream,
          BOOST_PP_FOR( (0, BUFFER_LEVELS), PRED, OP, PARAMS_STREAM_GENERATOR) ){
            #define READ_WRITE_PARAMS(r,state)\
              BOOST_PP_CAT(params_level_, BOOST_PP_TUPLE_ELEM(2,0,state)).write(main_params_stream.read());
            BOOST_PP_FOR( (0,BUFFER_LEVELS), PRED, OP, READ_WRITE_PARAMS)
          }

/*
The top level design.
Inputs are streams of input, weight.
Outputs is a stream of output.
This design consists a input double buffer, a weight double buffer, and a systolic array.
Input and weight data are reused inside double buffers, and streamed to systolic array.
Output data are accumulated inside systolic array, and streamed out.
*/

#pragma hls_design top
#pragma hls_pipeline_init_interval 1
void conv(ac_channel<PackedStencil<DTYPE,CI_NUM> > &input0, 
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &weight0, 
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &output,
          ac_channel<Params> &params_stream) {


  /** Macros for generating memory hierarchy and additional params **/
  #define MACRO_INPUT_INIT(r, state)\
    static ac_channel<PackedStencil<DTYPE, CI_NUM> > BOOST_PP_CAT(input, BOOST_PP_INC(BOOST_PP_TUPLE_ELEM(2,0,state))); \
    static ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > BOOST_PP_CAT(weight, BOOST_PP_INC(BOOST_PP_TUPLE_ELEM(2,0,state))); \
    static ac_channel<Params> BOOST_PP_CAT(params_stream_level_, BOOST_PP_INC(BOOST_PP_TUPLE_ELEM(2,0,state)));

  BOOST_PP_FOR((0, BUFFER_LEVELS), PRED, OP, MACRO_INPUT_INIT)

  #define PARAMS_INIT(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(params_stream_level_, BOOST_PP_INC(i) )

  params_generator(params_stream, BOOST_PP_REPEAT(BUFFER_LEVELS, PARAMS_INIT, 0));

  #define MACRO_BUFFER(r,state)\
    hierarchical_buffer<DTYPE,\
                        BOOST_PP_TUPLE_ELEM(BUFFER_LEVELS, BOOST_PP_TUPLE_ELEM(2,0,state), BUFFER_SIZES),\
                        BOOST_PP_TUPLE_ELEM(BUFFER_LEVELS, BOOST_PP_TUPLE_ELEM(2,0,state), BUFFER_SIZES),\
                        CI_NUM, KII, KI_NUM >\
                        ( BOOST_PP_CAT(input, BOOST_PP_DEC(BOOST_PP_TUPLE_ELEM(2,0,state))),\
                          BOOST_PP_CAT(input, BOOST_PP_TUPLE_ELEM(2,0,state)),\
                          BOOST_PP_CAT(weight, BOOST_PP_DEC(BOOST_PP_TUPLE_ELEM(2,0,state))),\
                          BOOST_PP_CAT(weight, BOOST_PP_TUPLE_ELEM(2,0,state)),\
                          BOOST_PP_CAT(params_stream_level_, BOOST_PP_TUPLE_ELEM(2,0,state) ) );
  BOOST_PP_FOR((1, BUFFER_LEVELS), PRED, OP, MACRO_BUFFER)

  unified_double_buffer<DTYPE, 
                        (OROW_I+W_SIZE-1)*(OCOL_I+W_SIZE-1), 
                        (CI_NUM*KO_NUM*CO_NUM*W_SIZE*W_SIZE),
                        CI_NUM, KII, KI_NUM>
                        ( BOOST_PP_CAT(input, BOOST_PP_DEC(BUFFER_LEVELS)),
                          BOOST_PP_CAT(input, BUFFER_LEVELS),
                          BOOST_PP_CAT(weight, BOOST_PP_DEC(BUFFER_LEVELS)),
                          BOOST_PP_CAT(weight, BUFFER_LEVELS),
                          BOOST_PP_CAT(params_stream_level_, BUFFER_LEVELS) );

  systolic_array<DTYPE, KII, KI_NUM, OROW_I, OCOL_I, OROW_O, OCOL_O, CI_NUM, KO_NUM, CO_NUM, W_SIZE>
                ( BOOST_PP_CAT(input, BUFFER_LEVELS),
                  BOOST_PP_CAT(weight, BUFFER_LEVELS),
                  output);
}
