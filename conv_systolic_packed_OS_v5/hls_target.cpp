//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

#include "hls_target.h"  
#include "double_buffer.cpp"

template<typename T>
class pe_class{
  private:
    T x_reg;
    PackedStencil<DTYPE, KII, 1, 1> y_reg;
  public:
    void exec(T &x_in, PackedStencil<DTYPE, KII> &y, PackedStencil<DTYPE, KII, 1, 1> &w, T &x_out) {
          y_reg = y; 
          x_reg = x_in;  
          COMP: for(int i = 0; i < KII; i++) {     
            T tmp = x_reg * w(i, 0, 0) + y_reg(i, 0, 0);
            y_reg(tmp, i, 0, 0, 0);
            
          }
          x_out = x_reg;
          y = y_reg;          
    }
};


#pragma hls_design 
#pragma hls_pipeline_init_interval 1
void systolic_array(ac_channel<PackedStencil<DTYPE, OCOL> > &input, 
            ac_channel<PackedStencil<DTYPE, KII, 1, 1> > &weight, 
            ac_channel<PackedStencil<DTYPE, KII, OCOL> > &output) {


  static pe_class<DTYPE> pe[OCOL];
  DTYPE in_tmp[OCOL+1];
  PackedStencil<DTYPE, KII> out_tmp[OCOL];
  PackedStencil<DTYPE, KII> weight_buf[W_SIZE][W_SIZE];
  DTYPE tmp = 0;
  
#ifndef __SYNTHESIS__
  printf("in hardware\n"); 
#endif

  for (int ko = 0; ko < KO_NUM; ko++) {
  for (int row=0; row < OROW; row++) {
  #pragma hls_unroll yes
            for(int k = 0; k < OCOL; ++k) {
   #pragma hls_unroll yes         
              for (int q = 0; q < KII; q++) {
                out_tmp[k](tmp, q, 0, 0, 0);
              }
            }
 
    WY: for(int wy = 0; wy < W_SIZE; wy++) {
        WX: for (int wx = 0; wx < W_SIZE; wx++) {  
            PackedStencil<DTYPE, OCOL> input_stencil = input.read(); 
/* #ifndef __SYNTHESIS__              
  if(row == 0)
    printf("wy=%d, wx=%d, input=%d, %d, %d, %d\n", wy, wx, input_stencil(0), input_stencil(1), input_stencil(2), input_stencil(3));
 #endif  */             
            if(wx == 0) {
  #pragma hls_unroll yes         
                for(int col = 0; col < OCOL; col++) {
                    in_tmp[col+1] = input_stencil(col);
                }
            }else {
               in_tmp[OCOL] = input_stencil(0);
            }         
  
            if(row == 0) {
                weight_buf[wy][wx] = weight.read();
            } 
  #pragma hls_unroll yes
            COL : for (int i=0; i < OCOL; ++i ) {
                pe[i].exec(in_tmp[i+1], out_tmp[i], weight_buf[wy][wx], in_tmp[i]);
            
  /*#ifndef __SYNTHESIS__
    printf("iter=%d, input_tmp[%d]=%d\n", wx, i, in_tmp[i+1]);
    printf("iter=%d, output_tmp[%d]=%d\n", wx, i, out_tmp[i](0)); 
  #endif*/
          }
        } // for wx
    } // for wy 

    PackedStencil<DTYPE, KII, OCOL> out_stencil;
 // #pragma hls_unroll yes       
    for (int k = 0; k < OCOL; ++k) {
  //#pragma hls_unroll yes           
      for (int q = 0; q < KII; ++q) {
          DTYPE out_value = out_tmp[k](q);
        out_stencil(out_value, q, k, 0, 0);
      }
    }
    output.write(out_stencil);
  } //for row
  } //for ko
  
}

#pragma hls_design top
#pragma hls_pipeline_init_interval 1
void hls_target(ac_channel<DTYPE> &input, 
            ac_channel<PackedStencil<DTYPE, KII, 1, 1> > &weight, 
            ac_channel<PackedStencil<DTYPE, KII, OCOL> > &output) {

  static ac_channel<PackedStencil<DTYPE, OCOL> > input_copy;

  double_buffer_input<DTYPE, OROW, OCOL, KO_NUM, CO_NUM, W_SIZE>(input, input_copy);


  static ac_channel<PackedStencil<DTYPE, KII > > weight_copy;

  double_buffer_weights<DTYPE, KII, OCOL, KO_NUM, CO_NUM, W_SIZE>(weight, weight_copy);

  static ac_channel<PackedStencil<DTYPE, KII, OCOL> > output_copy;

  systolic_array(input_copy, weight_copy, output_copy);
  double_buffer_output<DTYPE, KII, OCOL, OROW, KO_NUM>(output_copy, output);
}
   
