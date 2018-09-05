//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

#include "conv_ref.h"

#pragma design top
void conv_ref( DTYPE input[(OROW+W_SIZE-1)][(OCOL+W_SIZE-1)][CI_NUM*CO_NUM], // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
               DTYPE weight[W_SIZE][W_SIZE][CI_NUM*CO_NUM][KI_NUM*KO_NUM*KII], // R_TILE=CI_NUM, X_TILE=KI_NUM
               DTYPE output[OROW][OCOL][KI_NUM*KO_NUM*KII]){

  
  ROW:for (int i=0; i < OROW; ++i ) {
    COL:for (int j=0; j < OCOL; ++j) {
      NK: for (int k=0; k < KO_NUM*KI_NUM*KII; ++k) {
        DTYPE tmp=0;
        ACC:for (int c=0; c < CO_NUM*CI_NUM; ++c) { 
          WR: for (int fx=0; fx < W_SIZE; fx++) {
            WC: for (int fy=0; fy < W_SIZE; fy++) {
              tmp += input[i+fx][j+fy][c] * weight[fx][fy][c][k];
            }
          }
        }
        output[i][j][k]= tmp;
      }
    }
  }
}
