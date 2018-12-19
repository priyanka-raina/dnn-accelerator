//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

#ifndef _GLOBAL_SIMPLE_H
#define _GLOBAL_SIMPLE_H
#define SC_INCLUDE_FX
#include "ac_int.h"
#include "ac_fixed.h"
#include <ac_channel.h>
#include "Stencil_catapult.h"

#define KI_NUM     4 //4
#define KO_NUM      2   //kernel number = KO_NUM * KI_NUM
#define CI_NUM      4 //4   
#define CO_NUM      2   //channle number = CO_NUM * CI_NUM
//window width and height
#define W_SIZE     3  
 //output image row
#define OROW        4  //4
//output image col
#define OCOL        4 //4  
#define KII         2

#define INPUT_BUFFER_LEVELS 3
#define INPUT_BUFFER_SIZES (1,2,4)
#define WEIGHT_BUFFER_LEVELS 3
#define WEIGHT_BUFFER_SIZES (1,2,4)

typedef ac_int<16> DTYPE;

void gemm(ac_channel<PackedStencil<DTYPE,CI_NUM> > &input,
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &weight, 
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &output);

void systolic_array(ac_channel<PackedStencil<DTYPE, CI_NUM,1,1> > &input, 
                    ac_channel<PackedStencil<DTYPE, KII, CI_NUM*KI_NUM,1,1> > &weight, 
                    ac_channel<PackedStencil<DTYPE, KII, KI_NUM,1,1> > &output);


#endif

