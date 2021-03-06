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
// #define SC_INCLUDE_FX
#include "ac_int.h"
// #include "ac_fixed.h"
#include <ac_channel.h>
#include "Stencil_catapult.h"
#include "params.h"
#include "array_dimensions.h"

// DO NOT CHANGE
#define KI_NUM      ARRAY_DIMENSION  //tiled kernel number, the inner loop size of kernel dimension, also one of the PE array demension
#define CI_NUM      ARRAY_DIMENSION  //tiled channel number, the inner loop size of channel dimension, also one of the PE array demension
#define KII         1  //the innermost loop size of kernel dimension, also the loop iteration inside the PE array 

// YOU CAN CHANGE BELOW
#define K_NUM       64  //kernel number, KI_NUM must be a factor of K_NUM
#define C_NUM       64 //channel number, CI_NUM must be a factor of C_NUM

#define KO_NUM 1 //the outer loop of the outer kernel dimension

#define KOO_NUM      K_NUM / KO_NUM / KI_NUM / KII   //the outer loop size of kernel dimension, kernel number = KO_NUM * KOO_NUM * KI_NUM
#define CO_NUM      C_NUM / CI_NUM         //the inner loop size of channel dimension, channle number = CO_NUM * CI_NUM

#define W_SIZE      3   //window width or height (assume they are the same)
#define OROW        14  //output image row
#define OCOL        14  //output image col
#define OROW_I      7  //tiled output image row, the inner loop size of row dimension, must be a factor of OROW  
#define OCOL_I      7  //tiled output image col, the inner loop size of col dimension, must be a factpr pf OCOL

#define OROW_O      OROW / OROW_I  //the outer loop size of row dimension
#define OCOL_O      OCOL / OCOL_I  //the outer loop size of col dimension

#define STRIDE_LEN      1

#define INPUT_SIZE  128/2*1024/CI_NUM
#define WEIGHT_SIZE 128/2*1024/CI_NUM

// Memory Hierarchy
#define BUFFER_LEVELS 1
#define BUFFER_SIZES (1, 2) // Ordered from first level to last level

typedef ac_int<INPUT_PRECISION,true> IDTYPE; 
typedef ac_int<OUTPUT_PRECISION,true> ODTYPE; 

// void conv(ac_channel<PackedStencil<PRECISION,CI_NUM> > &input,
//           ac_channel<PackedStencil<PRECISION, KII, KI_NUM> > &weight, 
//           ac_channel<PackedStencil<PRECISION, KII, KI_NUM> > &output,
//           ac_channel<Params> &params_stream);

// void systolic_array(ac_channel<PackedStencil<PRECISION, CI_NUM,1,1> > &input, 
//                     ac_channel<PackedStencil<PRECISION, KII, CI_NUM*KI_NUM,1,1> > &weight, 
//                     ac_channel<PackedStencil<PRECISION, KII, KI_NUM,1,1> > &output);


#endif

