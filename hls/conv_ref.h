//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

#ifndef __CONV_REF__
#define __CONV_REF__
// #define SC_INCLUDE_FX
#include "ac_int.h"

#include "conv.h"
void conv_ref( IDTYPE input[(OROW*STRIDE+W_SIZE-1)][(OCOL*STRIDE+W_SIZE-1)][C_NUM], // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
               IDTYPE weight[W_SIZE][W_SIZE][C_NUM][K_NUM], // R_TILE=CI_NUM, X_TILE=KI_NUM
               ODTYPE output[OROW][OCOL][K_NUM]);

#endif

