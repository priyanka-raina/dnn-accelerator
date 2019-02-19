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

// DO NOT CHANGE
#define KI_NUM      4  //tiled kernel number, the inner loop size of kernel dimension, also one of the PE array demension
#define CI_NUM      4  //tiled channel number, the inner loop size of channel dimension, also one of the PE array demension
#define KII         2  //the innermost loop size of kernel dimension, also the loop iteration inside the PE array 

// YOU CAN CHANGE BELOW
#define K_NUM       64  //kernel number, KI_NUM must be a factor of K_NUM
#define C_NUM       64  //channel number, CI_NUM must be a factor of C_NUM


#define KO_NUM      K_NUM / KI_NUM / KII   //the outer loop size of kernel dimension, kernel number = KO_NUM * KI_NUM
#define CO_NUM      C_NUM / CI_NUM         //the inner loop size of channel dimension, channle number = CO_NUM * CI_NUM

#define W_SIZE      3   //window width or height (assume they are the same)
#define OROW        28  //output image row
#define OCOL        28  //output image col
#define OROW_I      14  //tiled output image row, the inner loop size of row dimension, must be a factor of OROW  
#define OCOL_I      14  //tiled output image col, the inner loop size of col dimension, must be a factpr pf OCOL

#define OROW_O      OROW / OROW_I  //the outer loop size of row dimension
#define OCOL_O      OCOL / OCOL_I  //the outer loop size of col dimension

#define STRIDE      1
typedef ac_int<16> DTYPE;  //define precision

void conv(ac_channel<PackedStencil<DTYPE,CI_NUM> > &input,
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &weight, 
          ac_channel<PackedStencil<DTYPE, KII, KI_NUM> > &output);

void systolic_array(ac_channel<PackedStencil<DTYPE, CI_NUM,1,1> > &input, 
                    ac_channel<PackedStencil<DTYPE, KII, CI_NUM*KI_NUM,1,1> > &weight, 
                    ac_channel<PackedStencil<DTYPE, KII, KI_NUM,1,1> > &output);


#endif

