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

#define ARRAY_DIMENSION 4
#define REPEAT(x) BOOST_PP_REPEAT(ARRAY_DIMENSION, x, 0)

template<typename DTYPE, int KI>
class pe_class{
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

#pragma hls_design 
#pragma hls_pipeline_init_interval 1
template<typename DTYPE, int KI, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS>
void systolic_array(ac_channel<PackedStencil<DTYPE, R_TILE, 1, 1> > &input, 
                    ac_channel<PackedStencil<DTYPE, KI, X_TILE, 1> > &weight, 
                    ac_channel<PackedStencil<DTYPE, KI, X_TILE, 1> > &output) {

  #define OUT_TILE_INIT(z,i,data)\
    PackedStencil<DTYPE, KI, 1, 1> BOOST_PP_CAT(out_tile_,i)[Y_TILE*K_TILE];   
  REPEAT(OUT_TILE_INIT)
  /*
  PackedStencil<DTYPE, KI, 1, 1> out_tile_0[Y_TILE*K_TILE]; 
  PackedStencil<DTYPE, KI, 1, 1> out_tile_1[Y_TILE*K_TILE]; 
  PackedStencil<DTYPE, KI, 1, 1> out_tile_2[Y_TILE*K_TILE]; 
  PackedStencil<DTYPE, KI, 1, 1> out_tile_3[Y_TILE*K_TILE]; 
  */

  static pe_class<DTYPE, KI> pe[R_TILE+1][X_TILE+1];
  DTYPE in_tmp[R_TILE+1][X_TILE+1];
  PackedStencil<DTYPE, KI, 1, 1> out_tmp[R_TILE+1][X_TILE+1];

 
 Co: for (int c_idx=0; c_idx<C_TILE; ++c_idx) {

  winx: for (int wx_idx = 0; wx_idx < WS; ++wx_idx) {
  winy: for (int wy_idx = 0; wy_idx < WS; ++wy_idx) {

  Ko: for (int k_idx=0; k_idx<K_TILE; ++k_idx) {

  STEPS: for (int step=0; step<X_TILE+R_TILE+Y_TILE-1; ++step) {
      PackedStencil<DTYPE,KI, X_TILE> w_tile[R_TILE];

      if (step < R_TILE) {            
        PackedStencil<DTYPE,KI, X_TILE> w_row = weight.read();
        w_tile[step] = w_row;
/*#ifndef __SYNTHESIS__
        for (int col = 0; col<X_TILE; col++) {
          printf("row  %d, col %d\n", step, col);    
          printf("weight=%d on row  %d, col %d\n", w_row(0,col,0,0), step, col);
        }
#endif*/

      }

      // read input, add input to fifos, and read fifos into input buffer
      PackedStencil<DTYPE, R_TILE,1,1> in_col;
      if (step < Y_TILE) {        
        in_col = input.read();
/*#ifndef __SYNTHESIS__
        for (int row = 0; row<R_TILE; row++) {
          printf("input=%d on row  %d, col %d\n", in_col(row,0,0,0), step, row);
        }
#endif*/

      }

      PackedStencil<DTYPE, R_TILE,1,1> input_buf;

        #define INPUT_FIFO_BODY(z,i,data) \
        BOOST_PP_CAT(DTYPE input_fifo_, i); \
        fifo<60000+i,DTYPE,R_TILE-3+i>( in_col(i ,0,0), BOOST_PP_CAT(input_fifo_, i));\
        input_buf( BOOST_PP_CAT(input_fifo_, i), i ,0,0,0);\

      REPEAT(INPUT_FIFO_BODY)
      /*
      DTYPE input_fifo_0;
      fifo<60000,DTYPE,R_TILE-3>(in_col(0,0,0), input_fifo_0);
      input_buf(input_fifo_0, 0,0,0,0);
      DTYPE input_fifo_1;
      fifo<60001,DTYPE,R_TILE-2>(in_col(1,0,0), input_fifo_1);
      input_buf(input_fifo_1, 1,0,0,0);
      DTYPE input_fifo_2;
      fifo<60002,DTYPE,R_TILE-1>(in_col(2,0,0), input_fifo_2);
      input_buf(input_fifo_2, 2,0,0,0);
      DTYPE input_fifo_3;
      fifo<60003,DTYPE,R_TILE-0>(in_col(3,0,0), input_fifo_3);
      input_buf(input_fifo_3, 3,0,0,0);
        */

/*#ifndef __SYNTHESIS__
      printf("starting step %d - input %d %d %d %d\n", step, input_fifo_0,input_fifo_1,input_fifo_2,input_fifo_3);
#endif*/


    #define TMP_ROW_BODY(z,i,data) \
      PackedStencil<DTYPE, KI, 1, 1, 1> BOOST_PP_CAT(tmp_row_, i);

    REPEAT(TMP_ROW_BODY)
    /*
    PackedStencil<DTYPE, KI, 1,1,1> tmp_row_0;
    PackedStencil<DTYPE, KI, 1,1,1> tmp_row_1;
    PackedStencil<DTYPE, KI, 1,1,1> tmp_row_2;
    PackedStencil<DTYPE, KI, 1,1,1> tmp_row_3;
    */
    if (step < Y_TILE) {
      if(c_idx == 0 && wx_idx == 0 && wy_idx == 0) {
    #pragma hls_unroll yes           
            for (int sk = 0; sk < KI; sk++) {
              #define TMP_ROW_BODY_INIT(z,i,data) \
                BOOST_PP_CAT(tmp_row_, i)(0,sk,0,0,0);
              
              REPEAT(TMP_ROW_BODY_INIT)
              /*
              tmp_row_0(0, sk, 0, 0, 0);
              tmp_row_1(0, sk, 0, 0, 0);
              tmp_row_2(0, sk, 0, 0, 0);
              tmp_row_3(0, sk, 0, 0, 0);
              */
            }
      } else {
          #define TMP_ROW_OUT(z,i,data) \
          BOOST_PP_CAT(tmp_row_, i) = BOOST_PP_CAT(out_tile_, i)[k_idx*Y_TILE + step];
        REPEAT(TMP_ROW_OUT)
        /*
        tmp_row_0 = out_tile_0[k_idx*Y_TILE + step];
        tmp_row_1 = out_tile_1[k_idx*Y_TILE + step];
        tmp_row_2 = out_tile_2[k_idx*Y_TILE + step];
        tmp_row_3 = out_tile_3[k_idx*Y_TILE + step];
        */
      }
    }
    
/*#ifndef __SYNTHESIS__
      if(step == 0 && k_idx == 0)
        printf("inputting this row %d\n", tmp_row(0, 1, 0, 0));
#endif   */
      PackedStencil<DTYPE, KI, X_TILE,1> output_buf;
      
      #define TMP_FIFO_BODY(z,i,data) \
        PackedStencil<DTYPE, KI> BOOST_PP_CAT(tmp_fifo_,i);\
        fifo<90000+i,PackedStencil<DTYPE,KI>, X_TILE-3+i>( BOOST_PP_CAT(tmp_row_,i), BOOST_PP_CAT(tmp_fifo_,i) );\
        output_buf.set_dim( BOOST_PP_CAT(tmp_fifo_, i), i,0,0);
      
      REPEAT(TMP_FIFO_BODY)
      /*
      PackedStencil<DTYPE, KI> tmp_fifo_0;
      fifo<90000,PackedStencil<DTYPE,KI>, X_TILE-3>(tmp_row_0, tmp_fifo_0);
      output_buf.set_dim(tmp_fifo_0, 0,0,0);
      PackedStencil<DTYPE, KI> tmp_fifo_1;
      fifo<90001,PackedStencil<DTYPE,KI>, X_TILE-2>(tmp_row_1, tmp_fifo_1);
      output_buf.set_dim(tmp_fifo_1, 1,0,0);
      PackedStencil<DTYPE, KI> tmp_fifo_2;
      fifo<90002,PackedStencil<DTYPE,KI>, X_TILE-1>(tmp_row_2, tmp_fifo_2);
      output_buf.set_dim(tmp_fifo_2, 2,0,0);
      PackedStencil<DTYPE, KI> tmp_fifo_3;
      fifo<90003,PackedStencil<DTYPE,KI>, X_TILE-0>(tmp_row_3, tmp_fifo_3);
      output_buf.set_dim(tmp_fifo_3, 3,0,0);
      */
/*#ifndef __SYNTHESIS__
      printf("starting step %d - partial result %d %d %d %d\n", step, tmp_fifo_0,tmp_fifo_1,tmp_fifo_2,tmp_fifo_3);
#endif*/

#pragma hls_unroll yes
    INIT_IN: for(int i = 0; i < R_TILE; ++i) {
        in_tmp[i+1][0] = input_buf(i,0,0);
    }

#pragma hls_unroll yes
    INIT_OUT: for(int j = 0; j < X_TILE; ++j) {
        out_tmp[0][j+1] = output_buf.get_dim(j, 0, 0);
    }

    #pragma hls_unroll yes
    COL: for (int j=0; j < X_TILE; ++j) {
    #pragma hls_unroll yes
      ROW: for (int i=0; i < R_TILE; ++i) {
          PackedStencil<DTYPE, KI> weight_value = w_tile[i].get_dim(j,0,0);
          pe[i][j].exec(in_tmp[i+1][j], out_tmp[i][j+1], weight_value, in_tmp[i+1][j+1], out_tmp[i+1][j+1]);
        }
      } //COL

      //write to fifos
      PackedStencil<DTYPE, KI, X_TILE> output_row;
      #define FIFO_WRITE_BODY(z,i,data)\
        PackedStencil<DTYPE, KI> BOOST_PP_CAT(sys_array_out_,i) = out_tmp[R_TILE][i+1];\
        PackedStencil<DTYPE, KI> BOOST_PP_CAT(output_fifo_,i); \
        fifo<0+i,PackedStencil<DTYPE, KI>, X_TILE-i>( BOOST_PP_CAT(sys_array_out_,i), BOOST_PP_CAT(output_fifo_,i) );\
        output_row.set_dim( BOOST_PP_CAT(output_fifo_,i), i,0,0); 
      REPEAT(FIFO_WRITE_BODY)
      /*
      PackedStencil<DTYPE, KI> sys_array_out_0 = out_tmp[R_TILE][1];       
      PackedStencil<DTYPE, KI> output_fifo_0;
      fifo<0,PackedStencil<DTYPE, KI>, X_TILE-0>(sys_array_out_0, output_fifo_0);
      output_row.set_dim(output_fifo_0, 0,0,0);
      PackedStencil<DTYPE, KI> sys_array_out_1 = out_tmp[R_TILE][2];       
      PackedStencil<DTYPE, KI> output_fifo_1;
      fifo<1,PackedStencil<DTYPE, KI>, X_TILE-1>(sys_array_out_1, output_fifo_1);
      output_row.set_dim(output_fifo_1, 1,0,0);
      PackedStencil<DTYPE, KI> sys_array_out_2 = out_tmp[R_TILE][3];       
      PackedStencil<DTYPE, KI> output_fifo_2;
      fifo<2,PackedStencil<DTYPE, KI>, X_TILE-2>(sys_array_out_2, output_fifo_2);
      output_row.set_dim(output_fifo_2, 2,0,0);
      PackedStencil<DTYPE, KI> sys_array_out_3 = out_tmp[R_TILE][4];       
      PackedStencil<DTYPE, KI> output_fifo_3;
      fifo<3,PackedStencil<DTYPE, KI>, X_TILE-3>(sys_array_out_3, output_fifo_3);
      output_row.set_dim(output_fifo_3, 3,0,0);
      */
/*#ifndef __SYNTHESIS__
     /printf("ending step %d - output %d %d %d %d\n", step, output_fifo_0,output_fifo_1,output_fifo_2,output_fifo_3);
#endif*/

    // output row if one has completed
    if (step >= X_TILE+R_TILE-1) {
        #define OUTPUT_ROW_BODY(z,i,data)\
        BOOST_PP_CAT(out_tile_,i)[k_idx*Y_TILE+step-(X_TILE+R_TILE-1)] = BOOST_PP_CAT(output_fifo_,i);
      REPEAT(OUTPUT_ROW_BODY)
      /*
       out_tile_0[k_idx*Y_TILE+step-(X_TILE+R_TILE-1)] = output_fifo_0; 
       out_tile_1[k_idx*Y_TILE+step-(X_TILE+R_TILE-1)] = output_fifo_1; 
       out_tile_2[k_idx*Y_TILE+step-(X_TILE+R_TILE-1)] = output_fifo_2; 
       out_tile_3[k_idx*Y_TILE+step-(X_TILE+R_TILE-1)] = output_fifo_3; 
       */
      if (c_idx==C_TILE-1 && wx_idx == WS-1 && wy_idx == WS-1) {
        output.write(output_row);
      }
    }
    } //STEPS
    } //K_TILE
    } //WS
    } //WS
    } //C_TILE
}



#pragma hls_design top
#pragma hls_pipeline_init_interval 1
void gemm(ac_channel<PackedStencil<DTYPE,CI_NUM> > &input, 
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &weight, 
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &output) {

  static ac_channel<PackedStencil<DTYPE, CI_NUM,1,1> > input_copy;

  double_buffer_input<DTYPE, KI_NUM, OROW, OCOL, CI_NUM, KO_NUM, CO_NUM, W_SIZE>(input, input_copy);

  static ac_channel<PackedStencil<DTYPE, KII, KI_NUM,1> > weight_copy;

  double_buffer_weights<DTYPE, KII, KI_NUM, OROW*OCOL, CI_NUM, KO_NUM, CO_NUM, W_SIZE>(weight, weight_copy);

  static ac_channel<PackedStencil<DTYPE, KII, KI_NUM,1> > output_copy;

  systolic_array<DTYPE, KII, KI_NUM, OROW*OCOL, CI_NUM, KO_NUM, CO_NUM, W_SIZE>(input_copy, weight_copy, output);

}

