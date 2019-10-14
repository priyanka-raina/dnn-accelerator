//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

// #include "conv_ref.h"
template<typename IN_TYPE, typename OUT_TYPE, int OUTPUT_ROW, int OUTPUT_COL, int KERNEL_NUMBER, int CHANNEL_NUMBER, int WS, int STRIDE>
void conv_ref( IN_TYPE input[(OUTPUT_ROW*STRIDE+WS-1)][(OUTPUT_COL*STRIDE+WS-1)][CHANNEL_NUMBER], // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
               IN_TYPE weight[WS][WS][CHANNEL_NUMBER][KERNEL_NUMBER], // R_TILE=CI_NUM, X_TILE=KI_NUM
               OUT_TYPE output[OUTPUT_ROW][OUTPUT_COL][KERNEL_NUMBER]){

  
  ROW:for (int i=0; i < OUTPUT_ROW; ++i ) {
    COL:for (int j=0; j < OUTPUT_COL; ++j) {
      NK: for (int k=0; k < KERNEL_NUMBER; ++k) {
        OUT_TYPE tmp=0;
        ACC:for (int c=0; c < CHANNEL_NUMBER; ++c) { 
          WR: for (int fx=0; fx < WS; fx++) {
            WC: for (int fy=0; fy < WS; fy++) {
              tmp += (OUT_TYPE) input[STRIDE*i+fx][STRIDE*j+fy][c] * (OUT_TYPE) weight[fx][fy][c][k];
            }
          }
        }
        output[i][j][k]= tmp;
      }
    }
  }
}
