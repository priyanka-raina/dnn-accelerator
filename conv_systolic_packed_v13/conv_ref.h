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
#define SC_INCLUDE_FX
#include "ac_int.h"

#include "conv.h"
void conv_ref( DTYPE input[(OROW+W_SIZE-1)][(OCOL+W_SIZE-1)][CI_NUM*CO_NUM], // R_TILE=CI_NUM, Y_TILE=BLOCKSIZE
               DTYPE weight[W_SIZE][W_SIZE][CI_NUM*CO_NUM][KI_NUM*KO_NUM*KII], // R_TILE=CI_NUM, X_TILE=KI_NUM
               DTYPE output[OROW][OCOL][KI_NUM*KO_NUM*KII]);

#endif

