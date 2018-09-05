// double buffer implementation for Catapult HLS
#include "ac_channel.h"
#include "Stencil_catapult.h"

template<typename T, int N>
struct chanStruct{
  T data[N];
 };


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int K_TILE, int KI>
void WRITE_BLOCK_OUTPUT(ac_channel<PackedStencil<DTYPE, KI, X_TILE,1,1> > &din,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_0,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_1,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_2,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_3,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_4,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_5,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_6,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_7,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_8,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_9,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_10,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_11,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_12,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_13,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_14,
                        ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &dout_15) {

  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_0;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_1;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_2;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_3;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_4;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_5;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_6;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_7;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_8;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_9;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_10;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_11;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_12;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_13;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_14;    //temporary array inside struct
  chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> tmp_15;    //temporary array inside struct
#pragma hls_pipeline_init_interval 1
  for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
    WRITE:for (int y_idx = 0; y_idx < 0 + Y_TILE; y_idx++)
    {
       
      PackedStencil<DTYPE, KI, X_TILE,1,1> output_row = din.read();
      tmp_0.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(0, 0, 0); 
      tmp_1.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(1, 0, 0); 
      tmp_2.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(2, 0, 0); 
      tmp_3.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(3, 0, 0); 
      tmp_4.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(4, 0, 0); 
      tmp_5.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(5, 0, 0); 
      tmp_6.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(6, 0, 0); 
      tmp_7.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(7, 0, 0); 
      tmp_8.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(8, 0, 0); 
      tmp_9.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(9, 0, 0); 
      tmp_10.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(10, 0, 0); 
      tmp_11.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(11, 0, 0); 
      tmp_12.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(12, 0, 0); 
      tmp_13.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(13, 0, 0); 
      tmp_14.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(14, 0, 0); 
      tmp_15.data[k_idx*Y_TILE + y_idx] = output_row.get_dim(15, 0, 0); 
      
    } // for y_idx
  } // for k_idx 
  dout_0.write(tmp_0);//Memory channel write
  dout_1.write(tmp_1);//Memory channel write
  dout_2.write(tmp_2);//Memory channel write
  dout_3.write(tmp_3);//Memory channel write
  dout_4.write(tmp_4);//Memory channel write
  dout_5.write(tmp_5);//Memory channel write
  dout_6.write(tmp_6);//Memory channel write
  dout_7.write(tmp_7);//Memory channel write
  dout_8.write(tmp_8);//Memory channel write
  dout_9.write(tmp_9);//Memory channel write
  dout_10.write(tmp_10);//Memory channel write
  dout_11.write(tmp_11);//Memory channel write
  dout_12.write(tmp_12);//Memory channel write
  dout_13.write(tmp_13);//Memory channel write
  dout_14.write(tmp_14);//Memory channel write
  dout_15.write(tmp_15);//Memory channel write

}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int K_TILE, int KI>
void READ_BLOCK_OUTPUT(ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_0,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_1,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_2,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_3,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_4,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_5,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_6,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_7,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_8,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_9,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_10,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_11,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_12,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_13,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_14,
                       ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > &din_15,
                       ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout){

chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_0;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_1;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_2;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_3;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_4;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_5;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_6;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_7;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_8;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_9;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_10;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_11;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_12;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_13;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_14;    //temporary array inside struct
chanStruct<PackedStencil<DTYPE, KI>, Y_TILE*K_TILE> tmp_15;    //temporary array inside struct
tmp_0 = din_0.read();                       // Single Memory channel read
tmp_1 = din_1.read();                       // Single Memory channel read
tmp_2 = din_2.read();                       // Single Memory channel read
tmp_3 = din_3.read();                       // Single Memory channel read
tmp_4 = din_4.read();                       // Single Memory channel read
tmp_5 = din_5.read();                       // Single Memory channel read
tmp_6 = din_6.read();                       // Single Memory channel read
tmp_7 = din_7.read();                       // Single Memory channel read
tmp_8 = din_8.read();                       // Single Memory channel read
tmp_9 = din_9.read();                       // Single Memory channel read
tmp_10 = din_10.read();                       // Single Memory channel read
tmp_11 = din_11.read();                       // Single Memory channel read
tmp_12 = din_12.read();                       // Single Memory channel read
tmp_13 = din_13.read();                       // Single Memory channel read
tmp_14 = din_14.read();                       // Single Memory channel read
tmp_15 = din_15.read();                       // Single Memory channel read
#pragma hls_pipeline_init_interval 1
for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
 READ:
  for (int y_idx=0; y_idx < Y_TILE; y_idx++)
    {
      PackedStencil<DTYPE, KI, X_TILE> dout_struct;
      dout_struct.set_dim(tmp_0.data[k_idx*Y_TILE + y_idx], 0, 0, 0);
      dout_struct.set_dim(tmp_1.data[k_idx*Y_TILE + y_idx], 1, 0, 0);
      dout_struct.set_dim(tmp_2.data[k_idx*Y_TILE + y_idx], 2, 0, 0);
      dout_struct.set_dim(tmp_3.data[k_idx*Y_TILE + y_idx], 3, 0, 0);
      dout_struct.set_dim(tmp_4.data[k_idx*Y_TILE + y_idx], 4, 0, 0);
      dout_struct.set_dim(tmp_5.data[k_idx*Y_TILE + y_idx], 5, 0, 0);
      dout_struct.set_dim(tmp_6.data[k_idx*Y_TILE + y_idx], 6, 0, 0);
      dout_struct.set_dim(tmp_7.data[k_idx*Y_TILE + y_idx], 7, 0, 0);
      dout_struct.set_dim(tmp_8.data[k_idx*Y_TILE + y_idx], 8, 0, 0);
      dout_struct.set_dim(tmp_9.data[k_idx*Y_TILE + y_idx], 9, 0, 0);
      dout_struct.set_dim(tmp_10.data[k_idx*Y_TILE + y_idx], 10, 0, 0);
      dout_struct.set_dim(tmp_11.data[k_idx*Y_TILE + y_idx], 11, 0, 0);
      dout_struct.set_dim(tmp_12.data[k_idx*Y_TILE + y_idx], 12, 0, 0);
      dout_struct.set_dim(tmp_13.data[k_idx*Y_TILE + y_idx], 13, 0, 0);
      dout_struct.set_dim(tmp_14.data[k_idx*Y_TILE + y_idx], 14, 0, 0);
      dout_struct.set_dim(tmp_15.data[k_idx*Y_TILE + y_idx], 15, 0, 0);
      dout.write(dout_struct);
    } // for y_idx
 } // for k_idx
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int X_TILE, int Y_TILE, int K_TILE>
void double_buffer_output(ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &din, 
                          ac_channel<PackedStencil<DTYPE, KI, X_TILE> > &dout) {

  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_0;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_1;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_2;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_3;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_4;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_5;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_6;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_7;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_8;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_9;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_10;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_11;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_12;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_13;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_14;//Static memory channel
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI>,Y_TILE*K_TILE> > shr_mem_15;//Static memory channel

    WRITE_BLOCK_OUTPUT<DTYPE, X_TILE, Y_TILE, K_TILE, KI>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3,
                                                 shr_mem_4, shr_mem_5, shr_mem_6, shr_mem_7,
                                                 shr_mem_8, shr_mem_9, shr_mem_10, shr_mem_11,
                                                 shr_mem_12, shr_mem_13, shr_mem_14, shr_mem_15);


    READ_BLOCK_OUTPUT<DTYPE, X_TILE, Y_TILE, K_TILE, KI>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, 
                                                   shr_mem_4, shr_mem_5, shr_mem_6, shr_mem_7, 
                                                   shr_mem_8, shr_mem_9, shr_mem_10, shr_mem_11, 
                                                   shr_mem_12, shr_mem_13, shr_mem_14, shr_mem_15, dout);
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int C_TILE, int WS>
void WRITE_BLOCK_INPUT(ac_channel<DTYPE> &din,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_0,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_1,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_2,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_3,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_4,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_5,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_6,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_7,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_8,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_9,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_10,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_11,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_12,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_13,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_14,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_15,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_16,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &dout_17) {

 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_0;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_1;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_2;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_3;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_4;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_5;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_6;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_7;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_8;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_9;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_10;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_11;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_12;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_13;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_14;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_15;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_16;    //temporary array inside struct
 chanStruct<DTYPE, (X_TILE+WS-1)*C_TILE> tmp_17;    //temporary array inside struct
  #pragma hls_pipeline_init_interval 1
  for (int c_idx=0; c_idx < C_TILE; c_idx++) {
   WRITE:for (int x_idx = 0; x_idx < 0 + X_TILE+WS-1; x_idx++){
   for (int y_idx = 0; y_idx < 0 + Y_TILE+WS-1; y_idx++) 
      {
        DTYPE column = din.read();
  #ifndef __SYNTHESIS__
  if(x_idx == 0)
    printf("y_idx=%d, input[%d]=%d\n", y_idx, y_idx, column);
  #endif        
        if(y_idx == 0)
          tmp_0.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 1)
          tmp_1.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 2)
          tmp_2.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 3)
          tmp_3.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 4)
          tmp_4.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 5)
          tmp_5.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 6)
          tmp_6.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 7)
          tmp_7.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 8)
          tmp_8.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 9)
          tmp_9.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 10)
          tmp_10.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 11)
          tmp_11.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 12)
          tmp_12.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 13)
          tmp_13.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 14)
          tmp_14.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 15)
          tmp_15.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 16)
          tmp_16.data[c_idx*(X_TILE+WS-1) + x_idx] = column;
        else if(y_idx == 17)
          tmp_17.data[c_idx*(X_TILE+WS-1) + x_idx] = column;


      } // for y_idx
    }
  }
    dout_0.write(tmp_0);//Memory channel write
    dout_1.write(tmp_1);//Memory channel write
    dout_2.write(tmp_2);//Memory channel write
    dout_3.write(tmp_3);//Memory channel write
    dout_4.write(tmp_4);//Memory channel write
    dout_5.write(tmp_5);//Memory channel write
    dout_6.write(tmp_6);//Memory channel write
    dout_7.write(tmp_7);//Memory channel write
    dout_8.write(tmp_8);//Memory channel write
    dout_9.write(tmp_9);//Memory channel write
    dout_10.write(tmp_10);//Memory channel write
    dout_11.write(tmp_11);//Memory channel write
    dout_12.write(tmp_12);//Memory channel write
    dout_13.write(tmp_13);//Memory channel write
    dout_14.write(tmp_14);//Memory channel write
    dout_15.write(tmp_15);//Memory channel write
    dout_16.write(tmp_16);//Memory channel write
    dout_17.write(tmp_17);//Memory channel write
}


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int X_TILE, int Y_TILE, int K_TILE, int C_TILE, int WS>
void READ_BLOCK_INPUT(ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_0,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_1,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_2,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_3,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_4,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_5,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_6,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_7,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_8,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_9,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_10,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_11,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_12,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_13,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_14,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_15,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_16,
                      ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > &din_17,
                     ac_channel<PackedStencil<DTYPE, Y_TILE,1,1> > &dout){

chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_0;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_1;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_2;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_3;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_4;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_5;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_6;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_7;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_8;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_9;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_10;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_11;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_12;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_13;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_14;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_15;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_16;    //temporary array inside struct
chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> tmp_17;    //temporary array inside struct
tmp_0 = din_0.read();                       // Single Memory channel read
tmp_1 = din_1.read();                       // Single Memory channel read
tmp_2 = din_2.read();                       // Single Memory channel read
tmp_3 = din_3.read();                       // Single Memory channel read
tmp_4 = din_4.read();                       // Single Memory channel read
tmp_5 = din_5.read();                       // Single Memory channel read
tmp_6 = din_6.read();                       // Single Memory channel read
tmp_7 = din_7.read();                       // Single Memory channel read
tmp_8 = din_8.read();                       // Single Memory channel read
tmp_9 = din_9.read();                       // Single Memory channel read
tmp_10 = din_10.read();                       // Single Memory channel read
tmp_11 = din_11.read();                       // Single Memory channel read
tmp_12 = din_12.read();                       // Single Memory channel read
tmp_13 = din_13.read();                       // Single Memory channel read
tmp_14 = din_14.read();                       // Single Memory channel read
tmp_15 = din_15.read();                       // Single Memory channel read
tmp_16 = din_16.read();                       // Single Memory channel read
tmp_17 = din_17.read();                       // Single Memory channel read
#pragma hls_pipeline_init_interval 1
READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
  for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int y_idx=0; y_idx < X_TILE; y_idx++) {
  for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
  for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
          PackedStencil<DTYPE, Y_TILE,1,1> dout_struct;
          if(wx_idx == 0) {
            dout_struct(tmp_0.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 0, 0, 0, 0);
            dout_struct(tmp_1.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 1, 0, 0, 0);
            dout_struct(tmp_2.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 2, 0, 0, 0);
            dout_struct(tmp_3.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 3, 0, 0, 0);
            dout_struct(tmp_4.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 4, 0, 0, 0);
            dout_struct(tmp_5.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 5, 0, 0, 0);
            dout_struct(tmp_6.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 6, 0, 0, 0);
            dout_struct(tmp_7.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 7, 0, 0, 0);
            dout_struct(tmp_8.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 8, 0, 0, 0);
            dout_struct(tmp_9.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 9, 0, 0, 0);
            dout_struct(tmp_10.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 10, 0, 0, 0);
            dout_struct(tmp_11.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 11, 0, 0, 0);
            dout_struct(tmp_12.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 12, 0, 0, 0);
            dout_struct(tmp_13.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 13, 0, 0, 0);
            dout_struct(tmp_14.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 14, 0, 0, 0);
            dout_struct(tmp_15.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 15, 0, 0, 0);
          } else if(wx_idx == 1) {
            dout_struct(tmp_16.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 0, 0, 0, 0);
            dout_struct(0, 1, 0, 0 ,0);
            dout_struct(0, 2, 0, 0 ,0);
            dout_struct(0, 3, 0, 0 ,0);
          } else if(wx_idx == 2) {
            dout_struct(tmp_17.data[c_idx*(X_TILE+WS-1) + (y_idx+wy_idx)], 0, 0, 0, 0);
            dout_struct(0, 1, 0, 0 ,0);
            dout_struct(0, 2, 0, 0 ,0);
            dout_struct(0, 3, 0, 0 ,0);
          }
 #ifndef __SYNTHESIS__          
  if(y_idx == 0)
    printf("wy=%d, wx=%d, input=%d, %d, %d, %d\n", wy_idx, wx_idx, dout_struct(0), dout_struct(1), dout_struct(2), dout_struct(3));
  #endif  
          dout.write(dout_struct);

    } // for x_idx
    } // for k_idx
   } // for wy_idx
   } // for wx_idx
  }//for c_idx
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
  template <typename DTYPE, int X_TILE, int Y_TILE, int K_TILE, int C_TILE, int WS>
void double_buffer_input(//DTYPE din[X_TILE * Y_TILE],DTYPE dout[X_TILE * Y_TILE], 
                         ac_channel<DTYPE> &din, 
                         ac_channel<PackedStencil<DTYPE, Y_TILE> > &dout) {

    //static ac_channel<chanStruct<PackedStencil<DTYPE,R_TILE,1,1>,(X_TILE+WS-1)*(Y_TILE+WS-1)*C_TILE> > shr_mem;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_0;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_1;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_2;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_3;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_4;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_5;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_6;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_7;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_8;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_9;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_10;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_11;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_12;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_13;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_14;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_15;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_16;//Static memory channel
    static ac_channel<chanStruct<DTYPE,(X_TILE+WS-1)*C_TILE> > shr_mem_17;//Static memory channel

  WRITE_BLOCK_INPUT<DTYPE, X_TILE, Y_TILE, C_TILE, WS>(din, shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, 
                                                 shr_mem_4, shr_mem_5, shr_mem_6, shr_mem_7,
                                                 shr_mem_8, shr_mem_9, shr_mem_10, shr_mem_11,
                                                 shr_mem_12, shr_mem_13, shr_mem_14, shr_mem_15,
                                                 shr_mem_16, shr_mem_17);



  READ_BLOCK_INPUT<DTYPE, X_TILE, Y_TILE, K_TILE, C_TILE, WS>(shr_mem_0, shr_mem_1, shr_mem_2, shr_mem_3, 
                                                 shr_mem_4, shr_mem_5, shr_mem_6, shr_mem_7,
                                                 shr_mem_8, shr_mem_9, shr_mem_10, shr_mem_11,
                                                 shr_mem_12, shr_mem_13, shr_mem_14, shr_mem_15,
                                                 shr_mem_16, shr_mem_17, dout);
}


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int K_TILE, int C_TILE, int WS, int KI>
void WRITE_BLOCK_WEIGHTS(ac_channel<PackedStencil<DTYPE, KI> > &din,
                         ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, K_TILE*C_TILE*WS*WS> > &dout) {

chanStruct<PackedStencil<DTYPE, KI, 1>, K_TILE*C_TILE*WS*WS> tmp;    //temporary array inside struct
#pragma hls_pipeline_init_interval 1
for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
  for (int c_idx = 0; c_idx < C_TILE; c_idx++) {
    for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {

      PackedStencil<DTYPE, KI> row;
      row     = din.read();
      tmp.data[k_idx*C_TILE*WS*WS + c_idx*WS*WS + wx_idx] = row;
   } // for wx_idx
   } //for c_idx
  } // for k_idx
  dout.write(tmp);//Memory channel write
}


#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int Y_TILE, int K_TILE, int C_TILE, int WS, int KI>
void READ_BLOCK_WEIGHTS(ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, K_TILE*C_TILE*WS*WS> > &din,
                        ac_channel<PackedStencil<DTYPE, KI, 1,1> > &dout){

  chanStruct<PackedStencil<DTYPE, KI, 1>, K_TILE*C_TILE*WS*WS> tmp;    //temporary array inside struct

  tmp = din.read();                       // Single Memory channel read
#pragma hls_pipeline_init_interval 1
 for (int k_idx = 0; k_idx < K_TILE; k_idx++) {
 READ: for (int c_idx = 0; c_idx <C_TILE; c_idx++) {
   for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
        PackedStencil<DTYPE, KI> dout_struct;
        dout_struct = tmp.data[k_idx*C_TILE*WS*WS + c_idx*WS*WS + wx_idx];
        dout.write(dout_struct);
     } // for wx_idx
   } // for c_idx
 } // for k_idx
}

#pragma hls_design
#pragma hls_pipeline_init_interval 1
  template <typename DTYPE, int KI, int Y_TILE, int K_TILE, int C_TILE, int WS>
  void double_buffer_weights(ac_channel<PackedStencil<DTYPE, KI> > &din, 
                             ac_channel<PackedStencil<DTYPE, KI> > &dout) {

    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, K_TILE*C_TILE*WS*WS> > shr_mem;//Static memory channel

  WRITE_BLOCK_WEIGHTS<DTYPE, K_TILE, C_TILE, WS, KI>(din, shr_mem);
  READ_BLOCK_WEIGHTS<DTYPE, Y_TILE, K_TILE, C_TILE, WS, KI>(shr_mem, dout);
}

