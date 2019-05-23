//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 


#include "Stencil_catapult.h"
#include "conv_ref.h"

#include <mc_scverify.h>
#include "conv.h"

#include "params.h"

#define DEBUG

CCS_MAIN(int argc, char *argv[]) 
{
  
    DTYPE input[(OROW+W_SIZE-1)][(OCOL+W_SIZE-1)][C_NUM]; 
    DTYPE weight[W_SIZE][W_SIZE][C_NUM][K_NUM]; 
    DTYPE output_ref[OROW][OCOL][K_NUM];
  
    static ac_channel<PackedStencil<DTYPE, CI_NUM> > input_stream;
    static ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > weight_stream;
    static ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > output_stream;
  
  
    int errCnt = 0;
    printf("Generating Input\n");

    // initialize input image  
    for (int row = 0; row < OROW + W_SIZE -1; row++) {
      for (int col = 0; col < OCOL + W_SIZE -1; col++) {
        for (int c = 0; c < C_NUM; c++) {
          input[row][col][c] = (DTYPE)rand(); 
        }
      }
    }
  
    // streaming input to the interface
    for (int ro = 0; ro < OROW_O; ro++) {
      for (int co = 0; co < OCOL_O; co++) {
        for (int c=0; c<CO_NUM; c++) {
          for (int p = 0; p < OROW_I + W_SIZE - 1; p++ ){
            for (int j = 0; j < OCOL_I + W_SIZE - 1; j++ ){
              PackedStencil<DTYPE, CI_NUM> input_col;
              for (int i = 0; i < CI_NUM; i++ ){
                input_col(input[ro*OROW_I+p][co*OCOL_I+j][c*CI_NUM+i], i,0,0,0);
              }  // for i
              input_stream.write(input_col);
            }  // for j 
          }  // for p
        }  // for c
      }  // for co
    }  // for ro
 

    printf("Generating Weight\n");

    // initialize weights
    for (int wy = 0; wy < W_SIZE; wy++) {  
      for (int wx = 0; wx < W_SIZE; wx++) {  
        for (int c = 0; c < C_NUM; c++) {
          for (int k = 0; k < K_NUM; k++) {
            weight[wy][wx][c][k] = (DTYPE)rand();  
          }
        }  
      }
    }
    
    // streaming weight to the interface
    PackedStencil<DTYPE, KII, KI_NUM> weight_row;
    for (int ro = 0; ro < OROW_O; ro++) {
      for (int co = 0; co < OCOL_O; co++) {     
        for(int koo = 0; koo < KOO_NUM; koo++){
          for (int c = 0; c < CO_NUM; c++) {
            for (int k = 0; k < KO_NUM; k++) {
              for (int wy = 0; wy <W_SIZE; wy++) {
                for (int wx = 0; wx <W_SIZE; wx++) {
                  for ( int i = 0; i < CI_NUM; i++ ){
                    for ( int j = 0; j < KI_NUM; j++ ){
                      for (int jj=0; jj < KII; jj++) {
                        weight_row(weight[wy][wx][c*CI_NUM+i][(koo*KO_NUM+k)*KI_NUM*KII + j*KII + jj], jj,j,0,0);
                      } // for jj
                    }  // for j
                    weight_stream.write(weight_row);
                  }  // for i
                }  // for wy
              }  // for wx
            }  // for c
          }  // for k
        } // for koo
      }  // for co
    }  // for ko 

    printf("finished weights\n");

    ac_channel<Params> params_stream;
    Params params = {OROW_O, OCOL_O, OROW_I, OCOL_I, KI_NUM, KOO_NUM, KO_NUM, CI_NUM, CO_NUM, W_SIZE};
    params_stream.write(params);

    // Main function call
    // launch hardware design
    CCS_DESIGN(conv)(input_stream,weight_stream,output_stream, params_stream);
    // run reference model
    conv_ref(input, weight, output_ref);          

    printf("\nOutput\n\n"); 
    // compare the hardware results with the reference model
    for (int ro = 0; ro < OROW_O; ro++) {
      for (int co = 0; co < OCOL_O; co++) {
        for(int koo = 0; koo < KOO_NUM; koo++){
          for (int k = 0; k < KO_NUM; k++) {
            for (int p = 0; p < OROW_I; p++ ){
              for (int i = 0; i < OCOL_I; i++ ){
                PackedStencil<DTYPE, KII, KI_NUM> output_col = output_stream.read();
                for (int j = 0; j < KI_NUM; j++) {
                  for (int jj = 0; jj < KII; jj++) {
                    DTYPE out_value = output_col(jj, j);
                    if((int)output_ref[ro*OROW_I+p][co*OCOL_I+i][(koo*KO_NUM+k)*KI_NUM*KII+j*KII+jj] != (int)out_value) {
                      printf("***ERROR***\n");
                      CCS_RETURN(0);
                      errCnt++;
                      printf("output[%d][%d][%d] = %d, ref = %d\n",ro*OROW_I+p, co*OCOL_I+i, (koo*KO_NUM+k)*KI_NUM*KII+j*KII+jj, (int)output_col(jj, j), (int)output_ref[ro*OROW_I+p][co*OCOL_I+i][(koo*KO_NUM+k)*KI_NUM*KII+j*KII+jj]);
                    }
                  }  // for jj
                }  // for j
              }  // for i
            }  // for p
          }  // for k
        } // for koo
      }  // for co
    }  // for ko
    
    printf("\nThere were %d errors\n",errCnt);
    CCS_RETURN(0);
}

