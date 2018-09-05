//
// Copyright 2003-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
// MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
// 

#ifndef _GLOBAL_HLS_TARGET_H
#define _GLOBAL_HLS_TARGET_H
#define SC_INCLUDE_FX
#include "ac_int.h"
#include "ac_fixed.h"
#include <ac_channel.h>
//#include "defs.h"
#include "Stencil_catapult.h"


#define OCOL       16
#define OROW        64
#define W_SIZE     3
#define KI_NUM     1 

#define KO_NUM     4
#define CO_NUM     1
#define CI_NUM     1

#define KII 2



typedef ac_int<16> DTYPE;

void hls_target(ac_channel<DTYPE> &input, ac_channel<PackedStencil<DTYPE, KII, 1, 1> > &weight, ac_channel<PackedStencil<DTYPE, KII, OCOL> > &output);

#endif

