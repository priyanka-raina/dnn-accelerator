// double buffer implementation for Catapult HLS
#include "ac_channel.h"
#include "Stencil_catapult.h"

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

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int Y_TILE, int C_TILE, int WS>
void WRITE_BLOCK_INPUT(ac_channel<PackedStencil<DTYPE,R_TILE> > &din,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_0,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_1,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_2,
                      ac_channel<chanStruct<DTYPE,Y_TILE*C_TILE> > &dout_3) {

 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_0;    //temporary array inside struct
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_1;    //temporary array inside struct
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_2;    //temporary array inside struct
 chanStruct<DTYPE, Y_TILE*C_TILE> tmp_3;    //temporary array inside struct
#pragma hls_pipeline_init_interval 1
for (int c_idx=0; c_idx < C_TILE; c_idx++) {
 WRITE:for (int y_idx = 0; y_idx < 0 + Y_TILE; y_idx++)
    {
      PackedStencil<DTYPE,R_TILE,1,1> column;
      column = din.read();
      tmp_0.data[c_idx*Y_TILE + y_idx] = column(0,0,0);
      tmp_1.data[c_idx*Y_TILE + y_idx] = column(1,0,0);
      tmp_2.data[c_idx*Y_TILE + y_idx] = column(2,0,0);
      tmp_3.data[c_idx*Y_TILE + y_idx] = column(3,0,0);
    } // for y_idx
  }
  dout_0.write(tmp_0);//Memory channel write
  dout_1.write(tmp_1);//Memory channel write
  dout_2.write(tmp_2);//Memory channel write
  dout_3.write(tmp_3);//Memory channel write
 //}
}


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int OROW, int OCOL, int R_TILE, int K_TILE, int C_TILE, int WS>
void READ_BLOCK_INPUT(ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_0,
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_1,
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_2,
                      ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > &din_3,
                     ac_channel<PackedStencil<DTYPE, R_TILE,1,1> > &dout){

chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_0;    //temporary array inside struct
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_1;    //temporary array inside struct
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_2;    //temporary array inside struct
chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> tmp_3;    //temporary array inside struct
tmp_0 = din_0.read();                       // Single Memory channel read
tmp_1 = din_1.read();                       // Single Memory channel read
tmp_2 = din_2.read();                       // Single Memory channel read
tmp_3 = din_3.read();                       // Single Memory channel read
#pragma hls_pipeline_init_interval 1
READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
  for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
  for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
  for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int x_idx=0; x_idx < OROW; x_idx++) {
  for (int y_idx=0; y_idx < OCOL; y_idx++)
    {

          PackedStencil<DTYPE, R_TILE,1,1> dout_struct;
          dout_struct(tmp_0.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 0, 0, 0, 0);
          dout_struct(tmp_1.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 1, 0, 0, 0);
          dout_struct(tmp_2.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 2, 0, 0, 0);
          dout_struct(tmp_3.data[c_idx*(OROW+WS-1)*(OCOL+WS-1) + (x_idx+wx_idx)* (OCOL+WS-1) +  y_idx + wy_idx], 3, 0, 0, 0);
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
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_0;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_1;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_2;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(OROW+WS-1)*(OCOL+WS-1)*C_TILE> > shr_mem_3;//Static memory channel

  WRITE_BLOCK_INPUT<DTYPE, R_TILE, (OROW+WS-1)*(OCOL+WS-1), C_TILE, WS>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3);
  READ_BLOCK_INPUT<DTYPE, OROW, OCOL, R_TILE, K_TILE, C_TILE, WS>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, dout);
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int R_TILE, int X_TILE, int K_TILE, int C_TILE, int WS, int KI>
void WRITE_BLOCK_WEIGHTS(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_0,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_1,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_2,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> > &dout_3) {

chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_0;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_1;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_2;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI, 1>, R_TILE*K_TILE*C_TILE*WS*WS> tmp_3;    //temporary array inside struct
#pragma hls_pipeline_init_interval 1
for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int c_idx = 0; c_idx < C_TILE; c_idx++) {
    for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {
 WRITE:for (int r_idx = 0; r_idx < 0 + R_TILE; r_idx++)
    {

      PackedStencil<DTYPE, KI, X_TILE> row;
      row     = din.read();
      tmp_0.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(0,0,0);
      tmp_1.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(1,0,0);
      tmp_2.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(2,0,0);
      tmp_3.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE  + r_idx] = row.get_dim(3,0,0);
    } // for r_idx
   } // for wx_idx
   } //for c_idx
  } // for k_idx
  dout_0.write(tmp_0);//Memory channel write
  dout_1.write(tmp_1);//Memory channel write
  dout_2.write(tmp_2);//Memory channel write
  dout_3.write(tmp_3);//Memory channel write
}


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int R_TILE, int K_TILE, int C_TILE, int WS, int KI>
void READ_BLOCK_WEIGHTS(ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_0,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_1,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_2,
                        ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > &din_3,
                        ac_channel<PackedStencil<DTYPE, KI, X_TILE,1,1> > &dout){

  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_0;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_1;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_2;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI, 1>,R_TILE*K_TILE*C_TILE*WS*WS> tmp_3;    //temporary array inside struct

  tmp_0 = din_0.read();                       // Single Memory channel read
  tmp_1 = din_1.read();                       // Single Memory channel read
  tmp_2 = din_2.read();                       // Single Memory channel read
  tmp_3 = din_3.read();                       // Single Memory channel read
#pragma hls_pipeline_init_interval 1
 READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
   for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
    for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
    for (int r_idx = 0; r_idx < R_TILE; r_idx++)
      {
       
        PackedStencil<DTYPE, KI, X_TILE> dout_struct;
        dout_struct.set_dim(tmp_0.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 0, 0, 0);
        dout_struct.set_dim(tmp_1.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 1, 0, 0);
        dout_struct.set_dim(tmp_2.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 2, 0, 0);
        dout_struct.set_dim(tmp_3.data[k_idx*R_TILE*C_TILE*WS*WS + c_idx*R_TILE*WS*WS + wx_idx*R_TILE + r_idx], 3, 0, 0);
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

    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_0;//Static memory channel
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_1;//Static memory channel
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_2;//Static memory channel
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, R_TILE*K_TILE*C_TILE*WS*WS> > shr_mem_3;//Static memory channel

  WRITE_BLOCK_WEIGHTS<DTYPE, R_TILE, X_TILE, K_TILE, C_TILE, WS, KI>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3);
  READ_BLOCK_WEIGHTS<DTYPE, X_TILE, Y_TILE, R_TILE, K_TILE, C_TILE, WS, KI>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, dout);
}
