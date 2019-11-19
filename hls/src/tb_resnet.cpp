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

typedef struct {
  int OROW;
  int OCOL;
  int C_NUM;
  int K_NUM;
  Params params;
} TestbenchParams;

void generate_params(int output_row, int input_col, int channel_number, int kernel_number, int window_size, int output_row_tile, int output_col_tile){
  TestbenchParams tbParams;
  tbParams.OROW = output_row;
  tbParams.OCOL = output_col;
  tbParams.C_NUM = channel_number;
  tbParams.K_NUM = kernel_number;
  tbParams.W_SIZE = window_size;
  
  tbParams.params.Y_I = output_row_tile;
  tbParams.params.Y_O = output_row / output_row_tile;
  
  tbParams.params.X_I = output_col_tile;
  tbParams.params.X_O = output_col / output_col_tile;

  tbParams.params.K_I = KI_NUM;
  tbParams.params.K_OO = kernel_number / KI_NUM / KII;
  tbParams.params.K_OI = 1;
  tbParams.params.C_I = CI_NUM;
  tbParams.params.C_O = channel_number / CI_NUM;
  tbParams.params.WS = window_size;

  return tbParams;
}

void run_layer(TestbenchParams tbParams){
    DTYPE input[(tbParams.OROW+tbParams.W_SIZE-1)][(tbParams.OCOL+tbParams.W_SIZE-1)][tbParams.C_NUM]; 
    DTYPE weight[tbParams.W_SIZE][tbParams.W_SIZE][tbParams.C_NUM][tbParams.K_NUM]; 
    DTYPE output_ref[tbParams.OROW][tbParams.OCOL]tbParams.[K_NUM];
  
    static ac_channel<NewPackedStencil<PRECISION, CI_NUM> > input_stream;
    static ac_channel<NewPackedStencil<PRECISION, KII, KI_NUM> > weight_stream;
    static ac_channel<NewPackedStencil<PRECISION, KII, KI_NUM> > output_stream;
  
  
    int errCnt = 0;
    printf("Generating Input\n");

    // initialize input image  
    for (int row = 0; row < tbParams.OROW + tbParams.W_SIZE -1; row++) {
      for (int col = 0; col < tbParams.OCOL + tbParams.W_SIZE -1; col++) {
        for (int c = 0; c < tbParams.C_NUM; c++) {
          input[row][col][c] = (DTYPE)rand(); 
        }
      }
    }
  
    // streaming input to the interface
    for (int ro = 0; ro < tbParams.OROW_O; ro++) {
      for (int co = 0; co < tbParams.OCOL_O; co++) {
        for (int c=0; c<tbParams.CO_NUM; c++) {
          for (int p = 0; p < tbParams.OROW_I +tbParams.W_SIZE - 1; p++ ){
            for (int j = 0; j < tbParams.OCOL_I + tbParams.W_SIZE - 1; j++ ){
              NewPackedStencil<PRECISION, CI_NUM> input_col;
              for (int i = 0; i < CI_NUM; i++ ){
                write<PRECISION, CI_NUM> (input_col, input[ro*tbParams.OROW_I+p][co*tbParams.OCOL_I+j][c*tbParams.CI_NUM+i], i,0,0,0);
              }  // for i
              input_stream.write(input_col);
            }  // for j 
          }  // for p
        }  // for c
      }  // for co
    }  // for ro
 

    printf("Generating Weight\n");

    // initialize weights
    for (int wy = 0; wy < tbParams.W_SIZE; wy++) {  
      for (int wx = 0; wx < tbParams.W_SIZE; wx++) {  
        for (int c = 0; c < tbParams.C_NUM; c++) {
          for (int k = 0; k < tbParams.K_NUM; k++) {
            weight[wy][wx][c][k] = (DTYPE)rand();  
          }
        }  
      }
    }
    
    // streaming weight to the interface
    NewPackedStencil<PRECISION, KII, KI_NUM> weight_row;
    for (int ro = 0; ro < tbParams.OROW_O; ro++) {
      for (int co = 0; co < tbParams.OCOL_O; co++) {     
        for(int koo = 0; koo < tbParams.KOO_NUM; koo++){
          for (int c = 0; c < tbParams.CO_NUM; c++) {
            for (int k = 0; k < tbParams.KO_NUM; k++) {
              for (int wy = 0; wy < tbParams.W_SIZE; wy++) {
                for (int wx = 0; wx < tbParams.W_SIZE; wx++) {
                  for ( int i = 0; i < CI_NUM; i++ ){
                    for ( int j = 0; j < KI_NUM; j++ ){
                      for (int jj=0; jj < KII; jj++) {
                        write<PRECISION, KII, KI_NUM>(weight_row, weight[wy][wx][c*CI_NUM+i][(koo*tbParams.KO_NUM+k)*KI_NUM*KII + j*KII + jj], jj,j,0,0);
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
    params_stream.write(tbParams.params);

    // Main function call
    // launch hardware design
    CCS_DESIGN(conv)(input_stream,weight_stream,output_stream, params_stream);
    // run reference model
    conv_ref(input, weight, output_ref);

    printf("\nOutput\n\n"); 
    // compare the hardware results with the reference model
    for (int ro = 0; ro < tbParams.OROW_O; ro++) {
      for (int co = 0; co < tbParams.OCOL_O; co++) {
        for(int koo = 0; koo < tbParams.KOO_NUM; koo++){
          for (int k = 0; k < tbParams.KO_NUM; k++) {
            for (int p = 0; p < tbParams.OROW_I; p++ ){
              for (int i = 0; i < tbParams.OCOL_I; i++ ){
                NewPackedStencil<PRECISION, KII, KI_NUM> output_col = output_stream.read();
                for (int j = 0; j < KI_NUM; j++) {
                  for (int jj = 0; jj < KII; jj++) {
                    DTYPE out_value = read<PRECISION, KII, KI_NUM>(output_col, jj, j);
                    if((int)output_ref[ro*tbParams.OROW_I+p][co*tbParams.OCOL_I+i][(koo*tbParams.KO_NUM+k)*KI_NUM*KII+j*KII+jj] != (int)out_value) {
                      printf("***ERROR***\n");
                      CCS_RETURN(0);
                      errCnt++;
                      printf("output[%d][%d][%d] = %d, ref = %d\n",ro*tbParams.OROW_I+p, co*tbParams.OCOL_I+i, (koo*tbParams.KO_NUM+k)*KI_NUM*KII+j*KII+jj, (int)out_value, (int)output_ref[ro*tbParams.OROW_I+p][co*tbParams.OCOL_I+i][(koo*tbParams.KO_NUM+k)*KI_NUM*KII+j*KII+jj]);
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
}

CCS_MAIN(int argc, char *argv[]) 
{
    // conv1
    run_layer(generate_params(112, 112, 3, 64, 7, 8, 8));
    
    // conv2_x
    run_layer(generate_params(56, 56, 64, 64, 3, 8, 8));
    run_layer(generate_params(56, 56, 64, 64, 3, 8, 8));

    run_layer(generate_params(56, 56, 64, 64, 3, 8, 8));
    run_layer(generate_params(56, 56, 64, 64, 3, 8, 8));

    // conv3_x
    run_layer(generate_params(28, 28, 64, 128, 3, 7, 7));
    run_layer(generate_params(28, 28, 128, 128, 3, 7, 7));

    run_layer(generate_params(28, 28, 128, 128, 3, 7, 7));
    run_layer(generate_params(28, 28, 128, 128, 3, 7, 7));

    // conv4_x
    run_layer(generate_params(14, 14, 128, 256, 3, 7, 7));
    run_layer(generate_params(14, 14, 256, 256, 3, 7, 7));
    
    run_layer(generate_params(14, 14, 256, 256, 3, 7, 7));
    run_layer(generate_params(14, 14, 256, 256, 3, 7, 7));

    // conv5_x
    run_layer(generate_params(7, 7, 256, 512, 3, 7, 7));
    run_layer(generate_params(7, 7, 512, 512, 3, 7, 7));
    
    run_layer(generate_params(7, 7, 512, 512, 3, 7, 7));
    run_layer(generate_params(7, 7, 512, 512, 3, 7, 7));

    CCS_RETURN(0);
}

