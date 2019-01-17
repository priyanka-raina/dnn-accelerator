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

#define DEBUG

CCS_MAIN(int argc, char *argv[]) 
{
  
  //DTYPE input[CI_NUM][(OROW+W_SIZE-1)*(OCOL+W_SIZE-1)]; // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
  //DTYPE weight[CI_NUM][KI_NUM*KO_NUM]; // R_TILE=CI_NUM, X_TILE=KI_NUM
  DTYPE input[(STRIDE*OROW+W_SIZE-1)][(STRIDE*OCOL+W_SIZE-1)][CI_NUM*CO_NUM]; // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
  DTYPE weight[W_SIZE][W_SIZE][CI_NUM*CO_NUM][KII*KI_NUM*KO_NUM]; // R_TILE=CI_NUM, X_TILE=KI_NUM
  DTYPE output_ref[OROW][OCOL][KII*KI_NUM*KO_NUM];

  //DTYPE output[BLOCKSIZE][BLOCKSIZE];
  //DTYPE output_ref[SIZE][LEN];
static ac_channel<PackedStencil<DTYPE, CI_NUM> > input_stream;
static ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > weight_stream;
static ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > output_stream;

//  static ac_channel<DTYPE> input_stream;
//  static ac_channel<DTYPE> weight_stream;
//  static ac_channel<DTYPE> output_stream;

  int errCnt = 0;
  printf("Input\n");

 for (int c=0; c<CO_NUM; c++) {
  for ( int p = 0; p < (STRIDE*OROW+W_SIZE-1); p++ ){
   for ( int j = 0; j < (STRIDE*OCOL+W_SIZE-1); j++ ){
    PackedStencil<DTYPE, CI_NUM> input_col;
    for ( int i = 0; i < CI_NUM; i++ ){
      //printf("inputting %d on index %d\n",j+1, i);
      input[p][j][c*CI_NUM+i] =  (DTYPE)rand(); //p*(OCOL+W_SIZE-1)+j+1;
      input_col(input[p][j][c*CI_NUM+i], i,0,0,0);
       //printf("%d\n", input[p][j][c*CI_NUM+i]);
      //input_stream.write(input[i][j]);
      }  
      input_stream.write(input_col);
    }
   }
 }

    printf("Weight\n");
    PackedStencil<DTYPE, KII, KI_NUM> weight_row;
    for (int k = 0; k < KO_NUM; k++) {
     for (int c = 0; c < CO_NUM; c++) {
      for (int wx = 0; wx <W_SIZE; wx++) {
      for (int wy = 0; wy <W_SIZE; wy++) {
      for ( int i = 0; i < CI_NUM; i++ ){
        for ( int j = 0; j < KI_NUM; j++ ){
         for (int jj=0; jj < KII; jj++) {
          weight[wx][wy][c*CI_NUM+i][k*KI_NUM*KII + j*KII + jj] = (DTYPE)rand(); //i*(k+1);  
          //weight_stream.write(weight[i][j]);
          //printf("weight=%d on index %d,%d\n",i, i, k*KI_NUM + j);
          weight_row(weight[wx][wy][c*CI_NUM+i][k*KI_NUM*KII + j*KII + jj], jj,j,0,0);
         }
        }
        weight_stream.write(weight_row);
       }
      }
      }
     }
    }
    //weight_stream.write(weight_tile);
    printf("finished weights\n");

    // Main function call
    //CCS_DESIGN(hls_target)(input, weight, output);        
    CCS_DESIGN(gemm)(input_stream,weight_stream,output_stream);
    conv_ref(input, weight, output_ref);          

    printf("\nOutput\n\n"); 
    for (int k = 0; k < KO_NUM; k++) {
      for (int p = 0; p < OROW; p++ ){   
      for (int i = 0; i < OCOL; i++ ){   
        PackedStencil<DTYPE, KII, KI_NUM> output_col = output_stream.read();
        for (int j = 0; j < KI_NUM; j++) {
          for (int jj = 0; jj < KII; jj++) {
           DTYPE out_value = output_col(jj, j);
           if((int)output_ref[p][i][k*KI_NUM*KII+j*KII+jj] != (int)out_value) {
               errCnt++;
               printf("output[%d][%d][%d] = %d, ref = %d\n",p, i, k*KI_NUM*KII+j*KII+jj, (int)output_col(jj, j), (int)output_ref[p][i][k*KI_NUM*KII+j*KII+jj]); 
           }
          } 
        }
      }
      }
    }
    //printf("output = %d\n", (int)output);
    printf("\nThere were %d errors\n",errCnt);
    CCS_RETURN(0);
}

