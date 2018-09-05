//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

#include "Stencil_catapult.h"
#include "hls_target.h"
#include "conv_ref.h"

#include <mc_scverify.h>

CCS_MAIN(int argc, char *argv[]) 
{
  //DTYPE input[OCOL+W_SIZE-1][OROW+W_SIZE-1];
  //PackedStencil<DTYPE, KII, 1, 1> weight[W_SIZE*W_SIZE];

  DTYPE input[(OROW+W_SIZE-1)][(OCOL+W_SIZE-1)][CI_NUM*CO_NUM]; // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
  DTYPE weight_ref[W_SIZE][W_SIZE][CI_NUM*CO_NUM][KII*KI_NUM*KO_NUM]; // R_TILE=CI_NUM, X_TILE=KI_NUM
  //PackedStencil<DTYPE, KII> weight[W_SIZE][W_SIZE][CI_NUM*CO_NUM][KI_NUM*KO_NUM]; // R_TILE=CI_NUM, X_TILE=KI_NUM
  DTYPE output[OROW][OCOL][KII*KI_NUM*KO_NUM];
  DTYPE output_ref[OROW][OCOL][KII*KI_NUM*KO_NUM];

  //DTYPE output[BLOCKSIZE][BLOCKSIZE];
  //DTYPE output_ref[SIZE][LEN];
//static ac_channel<PackedStencil<DTYPE, OCOL> > input_stream;
static ac_channel<DTYPE> input_stream;
static ac_channel<PackedStencil<DTYPE, KII> > weight_stream;
static ac_channel<PackedStencil<DTYPE, KII, OCOL> > output_stream;

  //DTYPE output[SIZE*KII][OROW];
  //DTYPE output_ref[SIZE][LEN];

   int errCnt = 0;
    printf("Input\n");
    for ( int c = 0; c < CI_NUM*CO_NUM; c++ ){
    for ( int j = 0; j < OROW+W_SIZE-1; j++ ){
      for ( int i = 0; i < OCOL+W_SIZE-1; i++ ){
        input[j][i][c] = rand()%10;//j*(OCOL+W_SIZE-1)+(i+1);
        input_stream.write(input[j][i][c]);
      }  
    }
    }
    //printf("\n");
    
    for ( int ko = 0; ko < KI_NUM*KO_NUM; ko++ ){
    for ( int c = 0; c < CI_NUM*CO_NUM; c++ ){
    for ( int i = 0; i < W_SIZE; i++ ){
      for ( int j = 0; j < W_SIZE; j++ ){
        PackedStencil<DTYPE, KII, 1, 1> weight_stencil;
        for (int k = 0; k < KII; k++) {
            weight_ref[i][j][c][ko*KII+k] = rand()%10; //DTYPE(i*W_SIZE+j);
            weight_stencil(weight_ref[i][j][c][ko*KII+k], k, 0, 0, 0);
            
        }
        weight_stream.write(weight_stencil);  
      }
    }
    }
    }
    // Main function call
    CCS_DESIGN(hls_target)(input_stream, weight_stream, output_stream);        
    conv_ref(input, weight_ref, output_ref);          

    printf("\nOutput\n\n");
    for (int k = 0; k < KI_NUM*KO_NUM; k++) { 
    for (int j = 0; j < OROW; j++) {
      PackedStencil<DTYPE, KII, OCOL> out_stencil = output_stream.read();
      for (int ki = 0; ki <KII; ki++) { 
      for (int i = 0; i < OCOL; i++ ){
          if((int)output_ref[j][i][k*KII+ki] != (int)out_stencil(ki, i)) {
            errCnt++;
            //printf("output[%d][%d][%d] = %d, out_ref=%d\n", j, i, k, (int)out_stencil(ki, i), (int)output_ref[j][i][k]); 
          }
      }
      }
    }
    }
    //printf("output = %d\n", (int)output);
    printf("\nThere were %d errors\n",errCnt);
    CCS_RETURN(0);
}

