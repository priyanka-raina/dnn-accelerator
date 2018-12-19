// double buffer implementation for Catapult HLS
#include "ac_channel.h"
#include "Stencil_catapult.h"

#include <boost/preprocessor/repetition/repeat.hpp>
#include <boost/preprocessor/punctuation/comma_if.hpp>
#include <boost/preprocessor/cat.hpp>

#define ARRAY_DIMENSION 4
#define REPEAT(x) BOOST_PP_REPEAT(ARRAY_DIMENSION, x, 0)

template<typename T, int N>
struct chanStruct{
  T data[N];
 };


template<int ID,typename DTYPE,int NUM_REGS> 
void fifo(DTYPE din, DTYPE &dout) {
  static DTYPE regs[NUM_REGS];
  /*
  if (NUM_REGS==1) {
    dout = din;
  } else {
    dout = regs[NUM_REGS-2];
  }
  */
#pragma hls_unroll yes
SHIFT:for(int i=NUM_REGS-1; i>=0; i--) {
    if (i==0) {
      regs[i] = din;
    } else {
      regs[i] = regs[i-1];
    }
 }

  dout = regs[NUM_REGS-1];
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int K_TILE, int C_TILE, int WS, int KI>
void WRITE_BLOCK_OUTPUT(ac_channel<PackedStencil<DTYPE, KI, X_TILE,1,1> > &din,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI, X_TILE>,Y_TILE*K_TILE> > &dout) {

  chanStruct<PackedStencil<DTYPE, KI, X_TILE>,Y_TILE*K_TILE> tmp;    //temporary array inside struct
#pragma hls_pipeline_init_interval 1
   bool flag;
  for (int c_idx = 0; c_idx < C_TILE; c_idx++) {
  for (int ws_idx = 0; ws_idx < WS*WS; ws_idx++) {
  for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
    WRITE:for (int y_idx = 0; y_idx < 0 + Y_TILE; y_idx++)
    {
       
      PackedStencil<DTYPE, KI, X_TILE,1,1> output_row = din.read();
      if(c_idx == 0 && ws_idx == 0) flag = false;
      else 
        flag = true;
      tmp.data[k_idx*Y_TILE + y_idx].add(output_row, flag); 
      
    } // for y_idx
  } // for k_idx 
  } // for c_idx  
  } // for ws_idx  
  dout.write(tmp);//Memory channel write

}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int K_TILE, int KI>
void READ_BLOCK_OUTPUT(ac_channel<chanStruct<PackedStencil<DTYPE, KI, X_TILE>,Y_TILE*K_TILE> > &din,
                       ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout){

chanStruct<PackedStencil<DTYPE, KI, X_TILE>, Y_TILE*K_TILE> tmp;    //temporary array inside struct
tmp = din.read();                       // Single Memory channel read
#pragma hls_pipeline_init_interval 1
for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
 READ:
  for (int y_idx=0; y_idx < Y_TILE; y_idx++)
    {
      PackedStencil<DTYPE, KI, X_TILE> dout_struct;
      dout_struct = tmp.data[k_idx*Y_TILE + y_idx];
      dout.write(dout_struct);

    } // for y_idx
 } // for k_idx
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int X_TILE, int Y_TILE, int K_TILE, int C_TILE, int WS>
void double_buffer_output(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din, 
                          ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout) {

  static ac_channel<chanStruct<PackedStencil<DTYPE, KI, X_TILE,1,1>,Y_TILE*K_TILE> > shr_mem;//Static memory channel

    WRITE_BLOCK_OUTPUT<DTYPE, X_TILE, Y_TILE, K_TILE, C_TILE, WS, KI>(din, shr_mem);
    READ_BLOCK_OUTPUT<DTYPE, X_TILE, Y_TILE, K_TILE, KI>(shr_mem, dout);
}


#define WRITE_BLOCK_INPUT_PARAMS(z, i, data)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > BOOST_PP_CAT(&dout_,i)

#define WRITE_BLOCK_INPUT_INIT(z, i, data)\
  chanStruct<DTYPE, Y_TILE*C_TILE> BOOST_PP_CAT(tmp_,i);

#define WRITE_BLOCK_INPUT_TMP_WRITE(z, i, unused)\
  BOOST_PP_CAT(tmp_,i).data[c_idx*Y_TILE + y_idx] = column(i,0,0);

#define WRITE_BLOCK_INPUT_WRITE(z, i, data)\
  BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int Y_TILE, int C_TILE, int WS>
void WRITE_BLOCK_INPUT(ac_channel<PackedStencil<DTYPE,R_TILE> > &din,
                        REPEAT(WRITE_BLOCK_INPUT_PARAMS)
                      /*
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_0,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_1,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_2,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_3
                      */
                     ) {
  
  REPEAT(WRITE_BLOCK_INPUT_INIT)
  /*
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_0;    //temporary array inside struct
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_1;    //temporary array inside struct
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_2;    //temporary array inside struct
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_3;    //temporary array inside struct
 */
#pragma hls_pipeline_init_interval 1
for (int c_idx=0; c_idx < C_TILE; c_idx++) {
 WRITE:for (int y_idx = 0; y_idx < 0 + Y_TILE; y_idx++)
    {
      PackedStencil<DTYPE,R_TILE,1,1> column;
      column = din.read();
      REPEAT(WRITE_BLOCK_INPUT_TMP_WRITE)
      /*
      tmp_0.data[c_idx*Y_TILE + y_idx] = column(0,0,0);
      tmp_1.data[c_idx*Y_TILE + y_idx] = column(1,0,0);
      tmp_2.data[c_idx*Y_TILE + y_idx] = column(2,0,0);
      tmp_3.data[c_idx*Y_TILE + y_idx] = column(3,0,0);
      */
    } // for y_idx
  }
  REPEAT(WRITE_BLOCK_INPUT_WRITE)
  /*
  dout_0.write(tmp_0);//Memory channel write
  dout_1.write(tmp_1);//Memory channel write
  dout_2.write(tmp_2);//Memory channel write
  dout_3.write(tmp_3);//Memory channel write
  */
 //}
}

#define READ_BLOCK_INPUT_PARAMS(z, i, data)\
  ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &BOOST_PP_CAT(din_,i),

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int OROW, int OCOL, int R_TILE, int K_TILE, int C_TILE, int WS>
void READ_BLOCK_INPUT( 
                      REPEAT(READ_BLOCK_INPUT_PARAMS)
                      /*
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_0,
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_1,
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_2,
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_3,
                      */
                     ac_channel<PackedStencil<DTYPE, R_TILE,1,1> > &dout){
#define READ_BLOCK_INPUT_INIT(z, i, data)\
  chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> BOOST_PP_CAT(tmp_,i);

REPEAT(READ_BLOCK_INPUT_INIT)
/*
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_0;    //temporary array inside struct
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_1;    //temporary array inside struct
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_2;    //temporary array inside struct
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_3;    //temporary array inside struct
*/

#define READ_BLOCK_MEM_READ(z, i, data)\
  BOOST_PP_CAT(tmp_, i) = BOOST_PP_CAT(din_, i).read();

REPEAT(READ_BLOCK_MEM_READ)
/*
tmp_0 = din_0.read();                       // Single Memory channel read
tmp_1 = din_1.read();                       // Single Memory channel read
tmp_2 = din_2.read();                       // Single Memory channel read
tmp_3 = din_3.read();                       // Single Memory channel read
*/
#pragma hls_pipeline_init_interval 1
READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
  for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
  for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
  for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int x_idx=0; x_idx < OROW; x_idx++) {
  for (int y_idx=0; y_idx < OCOL; y_idx++)
    {

          PackedStencil<DTYPE, R_TILE,1,1> dout_struct;

          #define READ_BLOCK_DOUT_STRUCT(z, i, unused)\
            dout_struct( BOOST_PP_CAT(tmp_,i).data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], i, 0, 0, 0);  
          REPEAT(READ_BLOCK_DOUT_STRUCT)
          /*
          dout_struct(tmp_0.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 0, 0, 0, 0);
          dout_struct(tmp_1.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 1, 0, 0, 0);
          dout_struct(tmp_2.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 2, 0, 0, 0);
          dout_struct(tmp_3.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 3, 0, 0, 0);
          */
          dout.write(dout_struct);

     } // for y_idx
    } // for x_idx
    } // for k_idx
   } // for wy_idx
   } // for wx_idx
  }//for c_idx
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
  template <typename DTYPE, int X_TILE, int OROW, int OCOL, int R_TILE, int K_TILE, int C_TILE, int WS>
void double_buffer_input(//DTYPE din[X_TILE * Y_TILE],DTYPE dout[X_TILE * Y_TILE], 
                         ac_channel<PackedStencil<DTYPE,R_TILE> > &din, 
                         ac_channel<PackedStencil<DTYPE, R_TILE,1,1> > &dout) {

    //static ac_channel<chanStruct<PackedStencil<DTYPE,R_TILE,1,1>,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem;//Static memory channel
    
    #define DOUBLE_BUFFER_INPUT_INIT(z,i,data)\
      static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > BOOST_PP_CAT(shr_mem_,i);
    
    REPEAT(DOUBLE_BUFFER_INPUT_INIT)
    /*
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_0;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_1;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_2;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_3;//Static memory channel
    */
   #define WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,data)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
  WRITE_BLOCK_INPUT<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS>(din, REPEAT(WRITE_BLOCK_INPUT_CALL_PARAMS) );
  //WRITE_BLOCK_INPUT<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3);
  
  #define READ_BLOCK_INPUT_CALL_PARAMS(z,i,data)\
    BOOST_PP_CAT(shr_mem_, i),
  READ_BLOCK_INPUT<DTYPE, OROW, OCOL, R_TILE, K_TILE, C_TILE, WS>( REPEAT(READ_BLOCK_INPUT_CALL_PARAMS) dout);
  //READ_BLOCK_INPUT<DTYPE, OROW, OCOL, R_TILE, K_TILE, C_TILE, WS>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, dout);
}

#define WRITE_BLOCK_WEIGHT_PARAMS(z,i,data)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > BOOST_PP_CAT(&dout_,i)
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int X_TILE, int K_TILE, int C_TILE, int WS, int KI>
void WRITE_BLOCK_WEIGHTS(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din,
                          REPEAT(WRITE_BLOCK_WEIGHT_PARAMS)
                          /*
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_0,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_1,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_2,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_3
                         */
                        ) {
 
 #define WRITE_BLOCK_WEIGHTS_INIT(z,i,data)\
  chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> BOOST_PP_CAT(tmp_,i);
REPEAT(WRITE_BLOCK_WEIGHTS_INIT)
/*
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_0;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_1;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_2;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_3;    //temporary array inside struct
*/
#pragma hls_pipeline_init_interval 1
for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int c_idx = 0; c_idx < C_TILE; c_idx++) {
    for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {
 WRITE:for (int r_idx = 0; r_idx < 0 + R_TILE; r_idx++)
    {

      PackedStencil<DTYPE, KI, X_TILE> row;
      row     = din.read();

      #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
        BOOST_PP_CAT(tmp_, i).data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(i,0,0);
      REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
      /*
      tmp_0.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(0,0,0);
      tmp_1.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(1,0,0);
      tmp_2.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(2,0,0);
      tmp_3.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(3,0,0);
      */
    } // for r_idx
   } // for wx_idx
   } //for c_idx
  } // for k_idx

  #define WRITE_BLOCK_WEIGHTS_WRITE(z,i,data)\
    BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));

  REPEAT(WRITE_BLOCK_WEIGHTS_WRITE)
  /*
  dout_0.write(tmp_0);//Memory channel write
  dout_1.write(tmp_1);//Memory channel write
  dout_2.write(tmp_2);//Memory channel write
  dout_3.write(tmp_3);//Memory channel write
  */
}


#define READ_BLOCK_WEIGHTS_PARAMS(z,i,data)\
  ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &BOOST_PP_CAT(din_,i),
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS, int KI>
void READ_BLOCK_WEIGHTS( REPEAT(READ_BLOCK_WEIGHTS_PARAMS)
                        /*
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_0,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_1,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_2,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_3,
                        */
                        ac_channel<PackedStencil<DTYPE, KI, X_TILE,1,1> > &dout){

  #define READ_BLOCK_WEIGHTS_INIT(z,i,data)\
    chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> BOOST_PP_CAT(tmp_,i);
  REPEAT(READ_BLOCK_WEIGHTS_INIT)
  /*
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_0;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_1;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_2;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_3;    //temporary array inside struct
  */

  #define READ_BLOCK_WEIGHTS_MEM_READ(z,i,data)\
    BOOST_PP_CAT(tmp_,i) = BOOST_PP_CAT(din_,i).read();
  REPEAT(READ_BLOCK_WEIGHTS_MEM_READ)
  /*
  tmp_0 = din_0.read();                       // Single Memory channel read
  tmp_1 = din_1.read();                       // Single Memory channel read
  tmp_2 = din_2.read();                       // Single Memory channel read
  tmp_3 = din_3.read();                       // Single Memory channel read
  */
#pragma hls_pipeline_init_interval 1
 READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
   for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
    for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
    for (int r_idx = 0; r_idx < R_TILE; r_idx++)
      {
       
        PackedStencil<DTYPE, KI, X_TILE> dout_struct;
        
        #define READ_BLOCK_WEIGHTS_DOUT(z,i,unused)\
          dout_struct.set_dim(BOOST_PP_CAT(tmp_, i).data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], i, 0, 0);
        REPEAT(READ_BLOCK_WEIGHTS_DOUT)
        /*
        dout_struct.set_dim(tmp_0.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 0, 0, 0);
        dout_struct.set_dim(tmp_1.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 1, 0, 0);
        dout_struct.set_dim(tmp_2.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 2, 0, 0);
        dout_struct.set_dim(tmp_3.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 3, 0, 0);
        */
        
        dout.write(dout_struct);

      } // for r_idx
     } // for k_idx
    } // for wx_idx
   } // for c_idx
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
  template <typename DTYPE, int KI, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS>
  void double_buffer_weights(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din, 
                             ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout) {

    #define DOUBLE_BUFFER_WEIGHT_INIT(z,i,data)\
      static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > BOOST_PP_CAT(shr_mem_,i);
    REPEAT(DOUBLE_BUFFER_WEIGHT_INIT)
    /*  
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_0;//Static memory channel
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_1;//Static memory channel
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_2;//Static memory channel
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_3;//Static memory channel
    */
  #define WRITE_BLOCK_WEIGHTS_CALL_PARAMS(z,i,data)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
  WRITE_BLOCK_WEIGHTS<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI>(din, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
  //WRITE_BLOCK_WEIGHTS<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3);
  
  #define READ_BLOCK_WEIGHTS_CALL_PARAMS(z,i,data)\
    BOOST_PP_CAT(shr_mem_, i) ,
  READ_BLOCK_WEIGHTS<DTYPE, X_TILE, Y_TILE, R_TILE, K_TILE, C_TILE, WS, KI>( REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) dout);
  //READ_BLOCK_WEIGHTS<DTYPE, X_TILE, Y_TILE, R_TILE, K_TILE, C_TILE, WS, KI>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, dout);
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int Y_TILE, int C_TILE, int WS, int N>
void INPUT_WRITE_N(ac_channel<PackedStencil<DTYPE, R_TILE> > &din,
                   ac_channel< chanStruct< PackedStencil<DTYPE, R_TILE>, (Y_TILE*C_TILE)/N > > &dout){
  for(int i = 0; i < N; i++){
    chanStruct< PackedStencil<DTYPE, R_TILE>, (Y_TILE*C_TILE)/N > tmp;    //temporary array inside struct
#pragma hls_pipeline_init_interval 1
    for(int idx = 0; idx < (C_TILE * Y_TILE)/N; idx++){
      PackedStencil<DTYPE,R_TILE,1,1> column;
        column = din.read();
        tmp.data[idx] = column;
    }

    dout.write(tmp);
  }
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int Y_TILE, int C_TILE, int WS, int N>
void INPUT_READ_N(ac_channel< chanStruct< PackedStencil<DTYPE, R_TILE>, (Y_TILE*C_TILE)/N > > &din, 
                  ac_channel< PackedStencil<DTYPE, R_TILE> > &dout){
  for(int i = 0; i < N; i++){
    chanStruct< PackedStencil<DTYPE, R_TILE>, (Y_TILE*C_TILE)/N > tmp = din.read();
#pragma hls_pipeline_init_interval 1
    for(int idx = 0; idx < (C_TILE*Y_TILE)/N; idx++){
      dout.write(tmp.data[idx]);
    }
  }
}

/** Double buffer of relative size N for inputs **/
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int OROW, int OCOL, int R_TILE, int K_TILE, int C_TILE, int WS, int N>
void double_buffer_input_n(ac_channel<PackedStencil<DTYPE, R_TILE> > &din,
                           ac_channel<PackedStencil<DTYPE, R_TILE> > &dout){
  
  static ac_channel< chanStruct< PackedStencil<DTYPE, R_TILE>, ((OROW+WS-1)*(OCOL+WS-1)*C_TILE)/N > > shr_mem;//Static memory channel

  INPUT_WRITE_N<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS, N>(din, shr_mem);
  
  INPUT_READ_N<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS, N>(shr_mem, dout);
}

#define INPUT_WRITE_FINAL_PARAMS(z, i, data)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<DTYPE,Y_TILE> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int Y_TILE, int C_TILE, int WS>
void INPUT_WRITE_FINAL(ac_channel<PackedStencil<DTYPE,R_TILE> > &din,
                      REPEAT(INPUT_WRITE_FINAL_PARAMS)
                      /*
                       ac_channel<chanStruct<DTYPE,Y_TILE> > &dout_0,
                       ac_channel<chanStruct<DTYPE,Y_TILE> > &dout_1,
                       ac_channel<chanStruct<DTYPE,Y_TILE> > &dout_2,
                       ac_channel<chanStruct<DTYPE,Y_TILE> > &dout_3
                       */
                       ){
  for(int c_idx = 0; c_idx < C_TILE; c_idx++){

    #define INPUT_WRITE_FINAL_TMP_INIT(z, i, data)\
      chanStruct<DTYPE, Y_TILE> BOOST_PP_CAT(tmp_,i);
    REPEAT(INPUT_WRITE_FINAL_TMP_INIT)
    /*
    chanStruct<DTYPE, Y_TILE> tmp_0;
    chanStruct<DTYPE, Y_TILE> tmp_1;
    chanStruct<DTYPE, Y_TILE> tmp_2;
    chanStruct<DTYPE, Y_TILE> tmp_3;
    */

    for(int y_idx = 0; y_idx < Y_TILE; y_idx++){
      PackedStencil<DTYPE, R_TILE, 1, 1> column;
      column = din.read();
      #define INPUT_WRITE_FINAL_TMP_WRITE(z, i, unused)\
        BOOST_PP_CAT(tmp_,i).data[y_idx] = column(i,0,0);
      REPEAT(INPUT_WRITE_FINAL_TMP_WRITE)
      /*
      tmp_0.data[y_idx] = column(0,0,0);
      tmp_1.data[y_idx] = column(1,0,0);
      tmp_2.data[y_idx] = column(2,0,0);
      tmp_3.data[y_idx] = column(3,0,0);
      */
    }
    #define INPUT_WRITE_FINAL_WRITE(z, i, data)\
      BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
    REPEAT(INPUT_WRITE_FINAL_WRITE)
    
    /*
    dout_0.write(tmp_0);
    dout_1.write(tmp_1);
    dout_2.write(tmp_2);
    dout_3.write(tmp_3);
    */
  }
}

#define INPUT_READ_FINAL_PARAMS(z, i, data)\
  ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> > &BOOST_PP_CAT(din_,i),

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int OROW, int OCOL, int R_TILE, int K_TILE, int C_TILE, int WS>
void INPUT_READ_FINAL(
                      REPEAT(INPUT_READ_FINAL_PARAMS)
                      /*
                      ac_channel<chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> > &din_0,
                      ac_channel<chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> > &din_1,
                      ac_channel<chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> > &din_2,
                      ac_channel<chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> > &din_3,
                      */
                      ac_channel<PackedStencil<DTYPE, R_TILE> >&dout){
  #define INPUT_READ_FINAL_TMP_INIT(z, i, data)\
    chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> BOOST_PP_CAT(tmp_,i);
  REPEAT(INPUT_READ_FINAL_TMP_INIT)
  /*
  chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> tmp_0;
  chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> tmp_1;
  chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> tmp_2;
  chanStruct<DTYPE, (OROW+WS-1)*(OCOL+WS-1)> tmp_3;
  */

  for(int c_idx = 0; c_idx < C_TILE; c_idx++){
    #define INPUT_READ_FINAL_TMP_WRITE(z, i, data)\
      BOOST_PP_CAT(tmp_, i) = BOOST_PP_CAT(din_, i).read();
    REPEAT(INPUT_READ_FINAL_TMP_WRITE)
    /*
    tmp_0 = din_0.read();
    tmp_1 = din_1.read();
    tmp_2 = din_2.read();
    tmp_3 = din_3.read();
    */
    for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
    for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
    for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
    for (int x_idx=0; x_idx < OROW; x_idx++) {
    for (int y_idx=0; y_idx < OCOL; y_idx++){
        PackedStencil<DTYPE, R_TILE,1,1> dout_struct;
        

        #define INPUT_READ_FINAL_DOUT(z, i, unused)\
            dout_struct( BOOST_PP_CAT(tmp_,i).data[(x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], i, 0, 0, 0);  
        
        REPEAT(INPUT_READ_FINAL_DOUT)
        /*
        dout_struct(tmp_0.data[(x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 0, 0, 0, 0);
        dout_struct(tmp_1.data[(x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 1, 0, 0, 0);
        dout_struct(tmp_2.data[(x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 2, 0, 0, 0);
        dout_struct(tmp_3.data[(x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 3, 0, 0, 0);
        */
        dout.write(dout_struct);
       } // for y_idx
    } // for x_idx
    } // for k_idx
   } // for wy_idx
   } // for wx_idx
  }//for c_idx
}


/** Final double buffer before systolic array. Used to rearrange data **/
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int OROW, int OCOL, int R_TILE, int K_TILE, int C_TILE, int WS>
void double_buffer_input_final(ac_channel<PackedStencil<DTYPE,R_TILE> > &din,
                               ac_channel<PackedStencil<DTYPE,R_TILE> > &dout){

    #define DOUBLE_BUFFER_INPUT_FINAL_INIT(z,i,data)\
      static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> > BOOST_PP_CAT(shr_mem_,i);
    REPEAT(DOUBLE_BUFFER_INPUT_FINAL_INIT)
    /*
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> > shr_mem_0;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> > shr_mem_1;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> > shr_mem_2;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)> > shr_mem_3;//Static memory channel
    */
    #define INPUT_WRITE_FINAL_CALL_PARAMS(z,i,data)\
        BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
      INPUT_WRITE_FINAL<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS>(din, REPEAT(INPUT_WRITE_FINAL_CALL_PARAMS ) );
    // INPUT_WRITE_FINAL<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3);
    
    #define INPUT_READ_FINAL_CALL_PARAMS(z,i,data)\
        BOOST_PP_CAT(shr_mem_, i),
    INPUT_READ_FINAL<DTYPE, OROW, OCOL, R_TILE, K_TILE, C_TILE, WS>(REPEAT(INPUT_READ_FINAL_CALL_PARAMS) dout);
    // INPUT_READ_FINAL<DTYPE, OROW, OCOL, R_TILE, K_TILE, C_TILE, WS>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, dout);
}

#define WEIGHT_WRITE_TOP_PARAMS(z,i,data)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > BOOST_PP_CAT(&dout_,i)
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int X_TILE, int K_TILE, int C_TILE, int WS, int KI>
void WEIGHT_WRITE_TOP(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din, 
                      REPEAT(WEIGHT_WRITE_TOP_PARAMS)
                      /*
                      ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_0,
                      ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_1,
                      ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_2,
                      ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_3
                      */
                     ){
    #define WEIGHT_WRITE_TOP_TMP_INIT(z,i,data)\
      chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> BOOST_PP_CAT(tmp_,i);
    REPEAT(WEIGHT_WRITE_TOP_TMP_INIT)
    /*
    chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_0;
    chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_1;   
    chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_2;    
    chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_3;
    */
    #pragma hls_pipeline_init_interval 1
    for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int c_idx = 0; c_idx < C_TILE; c_idx++) {
    for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {
 WRITE:for (int r_idx = 0; r_idx < 0 + R_TILE; r_idx++)
    {
      PackedStencil<DTYPE, KI, X_TILE> row;
      row     = din.read();

      #define WEIGHT_WRITE_TOP_TMP_WRITE(z,i,unused)\
        BOOST_PP_CAT(tmp_, i).data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(i,0,0);
      REPEAT(WEIGHT_WRITE_TOP_TMP_WRITE)
      /*
      tmp_0.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(0,0,0);
      tmp_1.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(1,0,0);
      tmp_2.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(2,0,0);
      tmp_3.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(3,0,0);
      */
    } // for r_idx
   } // for wx_idx
   } //for c_idx
  } // for k_idx


  #define WEIGHT_WRITE_TOP_WRITE(z,i,data)\
    BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));

  REPEAT(WEIGHT_WRITE_TOP_WRITE)
  /*
  dout_0.write(tmp_0);//Memory channel write
  dout_1.write(tmp_1);//Memory channel write
  dout_2.write(tmp_2);//Memory channel write
  dout_3.write(tmp_3);//Memory channel write
  */
}

#define WEIGHT_READ_TOP_PARAMS(z,i,data)\
  ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &BOOST_PP_CAT(din_,i),


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS, int KI>
void WEIGHT_READ_TOP( REPEAT(WEIGHT_READ_TOP_PARAMS)
                        /*
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_0,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_1,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_2,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_3,
                        */
                        ac_channel<PackedStencil<DTYPE, KI, X_TILE,1,1> > &dout){
  
  #define WEIGHT_READ_TOP_INIT(z,i,data)\
    chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> BOOST_PP_CAT(tmp_,i);
  REPEAT(WEIGHT_READ_TOP_INIT)

  /*
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_0;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_1;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_2;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_3;    //temporary array inside struct
  */

  #define WEIGHT_READ_TOP_TMP_WRITE(z,i,data)\
    BOOST_PP_CAT(tmp_,i) = BOOST_PP_CAT(din_,i).read();
  REPEAT(WEIGHT_READ_TOP_TMP_WRITE)
  /*
  tmp_0 = din_0.read();                       // Single Memory channel read
  tmp_1 = din_1.read();                       // Single Memory channel read
  tmp_2 = din_2.read();                       // Single Memory channel read
  tmp_3 = din_3.read();                       // Single Memory channel read
  */

#pragma hls_pipeline_init_interval 1
 READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
   for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
    for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
    for (int r_idx = 0; r_idx < R_TILE; r_idx++)
      {
       
        PackedStencil<DTYPE, KI, X_TILE> dout_struct;
                
        #define WEIGHT_READ_TOP_DOUT(z,i,unused)\
          dout_struct.set_dim(BOOST_PP_CAT(tmp_, i).data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], i, 0, 0);
        REPEAT(WEIGHT_READ_TOP_DOUT)

        /*
        dout_struct.set_dim(tmp_0.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 0, 0, 0);
        dout_struct.set_dim(tmp_1.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 1, 0, 0);
        dout_struct.set_dim(tmp_2.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 2, 0, 0);
        dout_struct.set_dim(tmp_3.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 3, 0, 0);
        */

        dout.write(dout_struct);

      } // for r_idx
     } // for k_idx
    } // for wx_idx
   } // for c_idx
}

/** Top level buffer for rearranging weights **/
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS>
void double_buffer_weights_top(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din,
                               ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout){
  #define DOUBLE_BUFFER_WEIGHT_TOP_INIT(z,i,data)\
      static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > BOOST_PP_CAT(shr_mem_,i);
    REPEAT(DOUBLE_BUFFER_WEIGHT_TOP_INIT)
  /*  
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_0;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_1;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_2;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_3;//Static memory channel
  */

  #define DOUBLE_BUFFER_WEIGHT_TOP_WRITE_PARAMS(z,i,data)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
  WEIGHT_WRITE_TOP<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI>(din, REPEAT(DOUBLE_BUFFER_WEIGHT_TOP_WRITE_PARAMS));
  // WEIGHT_WRITE_TOP<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3);

  #define DOUBLE_BUFFER_WEIGHT_TOP_READ_PARAMS(z,i,data)\
    BOOST_PP_CAT(shr_mem_, i) ,
  WEIGHT_READ_TOP<DTYPE, X_TILE, Y_TILE, R_TILE, K_TILE, C_TILE, WS, KI>( REPEAT(DOUBLE_BUFFER_WEIGHT_TOP_READ_PARAMS) dout);
  // WEIGHT_READ_TOP<DTYPE, X_TILE, Y_TILE, R_TILE, K_TILE, C_TILE, WS, KI>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, dout);
}


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int X_TILE, int K_TILE, int C_TILE, int WS, int KI, int N>
void WEIGHT_WRITE_N(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din,
                    ac_channel< chanStruct<PackedStencil<DTYPE, KI, X_TILE>, (K_TILE*C_TILE*WS*WS*R_TILE)/N  > > &dout){

  #pragma hls_pipeline_init_interval 1
  for(int i = 0; i < N; i++){
    chanStruct<PackedStencil<DTYPE, KI, X_TILE>, (K_TILE*C_TILE*WS*WS*R_TILE)/N  > tmp;
    
    for(int idx = 0; idx < (K_TILE*C_TILE*WS*WS*R_TILE)/N; idx++){
      PackedStencil<DTYPE, KI, X_TILE> row;
        row     = din.read();
        tmp.data[idx] = row;
    }
    dout.write(tmp);
  }

}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int X_TILE, int K_TILE, int C_TILE, int WS, int KI, int N>
void WEIGHT_READ_N( ac_channel< chanStruct<PackedStencil<DTYPE, KI, X_TILE>, (K_TILE*C_TILE*WS*WS*R_TILE)/N  > > &din,
                    ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout){

    #pragma hls_pipeline_init_interval 1
  for(int i = 0; i < N; i++){
    chanStruct< PackedStencil<DTYPE, KI, X_TILE>, (K_TILE*C_TILE*WS*WS*R_TILE)/N > tmp = din.read();

    for(int idx = 0; idx < (K_TILE*C_TILE*WS*WS*R_TILE)/N; idx++){
      dout.write(tmp.data[idx]);
    }
  }
}

/** Double Buffer of size N **/
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS, int N>
void double_buffer_weights_n(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din,
                             ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout){
  static ac_channel< chanStruct<PackedStencil<DTYPE, KI, X_TILE>, (K_TILE*C_TILE*WS*WS*R_TILE)/N  > > shr_mem;

  WEIGHT_WRITE_N<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI, N>(din, shr_mem);
  WEIGHT_READ_N<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI, N>(shr_mem, dout);
}
