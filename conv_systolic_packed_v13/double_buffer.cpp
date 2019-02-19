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

//FIFO implemented as shift registers
template<int ID,typename DTYPE,int NUM_REGS> 
void fifo(DTYPE din, DTYPE &dout) {
  static DTYPE regs[NUM_REGS];

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

#define WRITE_BLOCK_INPUT_PARAMS(z, i, unused)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<DTYPE,XY_I> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int C_I, int XY_I, int XY_O, int C_O, int WS>
void WRITE_BLOCK_INPUT(ac_channel<PackedStencil<DTYPE,C_I> > &din,
                      REPEAT(WRITE_BLOCK_INPUT_PARAMS)
                      ) {

#pragma hls_pipeline_init_interval 1
  WRITE: for (int p_idx=0; p_idx < XY_O; p_idx++) {
    for (int c_idx=0; c_idx < C_O; c_idx++) {

      #define WRITE_BLOCK_INPUT_INIT(z, i, unused)\
        chanStruct<DTYPE, XY_I> BOOST_PP_CAT(tmp_,i);
      REPEAT(WRITE_BLOCK_INPUT_INIT)

      for (int y_idx = 0; y_idx < 0 + XY_I; y_idx++)
      {
        PackedStencil<DTYPE,C_I,1,1> column;
        column = din.read();
        
        #define WRITE_BLOCK_INPUT_TMP_WRITE(z, i, unused)\
          BOOST_PP_CAT(tmp_,i).data[y_idx] = column(i,0,0);
        REPEAT(WRITE_BLOCK_INPUT_TMP_WRITE)
      } // for y_idx
      
      #define WRITE_BLOCK_INPUT_WRITE(z, i, unused)\
        BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
      REPEAT(WRITE_BLOCK_INPUT_WRITE)
    } // for c_idx
  } // for p_idx
}

#define READ_BLOCK_INPUT_PARAMS(z, i, unused)\
  ac_channel<chanStruct<DTYPE,(Y_I+WS-1)*(X_I+WS-1)> > &BOOST_PP_CAT(din_,i),

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int Y_I, int X_I, int Y_O, int X_O, int C_I, int K_O, int C_O, int WS>
void READ_BLOCK_INPUT(REPEAT(READ_BLOCK_INPUT_PARAMS)
                     ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout){

/*reuse the input pixels in the double buffer when iterating through different kernels
and window locations*/
#pragma hls_pipeline_init_interval 1
  READ: for(int ro_idx = 0; ro_idx < Y_O; ro_idx++) {
    for (int co_idx=0; co_idx < X_O; co_idx++) {    
      for (int c_idx = 0; c_idx <C_O; c_idx++) {
        #define READ_BLOCK_INPUT_INIT(z, i, unused)\
          chanStruct<DTYPE,(Y_I+WS-1)*(X_I+WS-1)> BOOST_PP_CAT(tmp_,i);
        REPEAT(READ_BLOCK_INPUT_INIT)

        #define READ_BLOCK_MEM_READ(z, i, unused)\
          BOOST_PP_CAT(tmp_, i) = BOOST_PP_CAT(din_, i).read();
        REPEAT(READ_BLOCK_MEM_READ)

        for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
        for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
        for (int k_idx = 0; k_idx < K_O; k_idx++) {
        for (int x_idx=0; x_idx < Y_I; x_idx++) {
        for (int y_idx=0; y_idx < X_I; y_idx++)
        {
          PackedStencil<DTYPE, C_I,1,1> dout_struct;
          
          #define READ_BLOCK_DOUT_STRUCT(z, i, unused)\
            dout_struct( BOOST_PP_CAT(tmp_,i).data[(x_idx+wx_idx)* (X_I+WS-1) +  y_idx + wy_idx], i, 0, 0, 0);  
          REPEAT(READ_BLOCK_DOUT_STRUCT)

          dout.write(dout_struct);
        
        } // for y_idx
        } // for x_idx
        } // for k_idx
        } // for wy_idx
        } // for wx_idx
      } // for c_idx
    } // for co_idx
  } //for ro_idx
}

/*Input double buffer.
Inputs are a stream of input pixels, outputs are a stream of PackedStencil of pixels.
PackedStencil is a data struct that pack multiple elements into a long word to
increase the port width and bandwidth.
*/
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int Y_I, int X_I, int Y_O, int X_O, int C_I, int K_O, int C_O, int WS>
void double_buffer_input( 
                         ac_channel<PackedStencil<DTYPE,C_I> > &din, 
                         ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout) {

  // Four banks of memorie, since the PE array is 4 x 4.
  #define DOUBLE_BUFFER_INPUT_INIT(z,i,unused)\
    static ac_channel<chanStruct<DTYPE,(Y_I+WS-1)*(X_I+WS-1)> > BOOST_PP_CAT(shr_mem_,i);
  REPEAT(DOUBLE_BUFFER_INPUT_INIT)

  #define WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
  WRITE_BLOCK_INPUT<DTYPE, C_I, (Y_I+WS-1)*(X_I+WS-1), Y_O*X_O, C_O, WS>(din, REPEAT(WRITE_BLOCK_INPUT_CALL_PARAMS) );
  
  #define READ_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
    BOOST_PP_CAT(shr_mem_, i),
  READ_BLOCK_INPUT<DTYPE, Y_I, X_I, Y_O, X_O, C_I, K_O, C_O, WS>( REPEAT(READ_BLOCK_INPUT_CALL_PARAMS) dout);
}

#define WRITE_BLOCK_WEIGHT_PARAMS(z,i,unused)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, C_I*K_O*C_O*WS*WS> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int C_I, int K_I, int XY_O, int K_O, int C_O, int WS>
void WRITE_BLOCK_WEIGHTS(ac_channel<PackedStencil<DTYPE, KI, K_I> > &din,
                         REPEAT(WRITE_BLOCK_WEIGHT_PARAMS)
                        ) {
                             
#pragma hls_pipeline_init_interval 1
  WRITE: for(int p_idx = 0; p_idx < XY_O; p_idx++) {
    
    #define WRITE_BLOCK_WEIGHTS_INIT(z,i,unused)\
      chanStruct<PackedStencil<DTYPE, KI, 1>, C_I*K_O*C_O*WS*WS> BOOST_PP_CAT(tmp_,i);
    REPEAT(WRITE_BLOCK_WEIGHTS_INIT)

    for (int k_idx = 0; k_idx < K_O; k_idx++) {
      for (int c_idx = 0; c_idx < C_O; c_idx++) {
        for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {
          for (int r_idx = 0; r_idx < 0 + C_I; r_idx++)
          {
            PackedStencil<DTYPE, KI, K_I> row;
            row     = din.read();

            #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
              BOOST_PP_CAT(tmp_, i).data[k_idx*C_I*C_O*WS*WS + c_idx*C_I*WS*WS + wx_idx*C_I  + r_idx] = row.get_dim(i,0,0);
            REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
          } // for r_idx
        } // for wx_idx
      } //for c_idx
    } // for k_idx

    #define WRITE_BLOCK_WEIGHTS_WRITE(z,i,unused)\
      BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
    REPEAT(WRITE_BLOCK_WEIGHTS_WRITE)

  } // for p_idx
}


#define READ_BLOCK_WEIGHTS_PARAMS(z,i,unused)\
  ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, C_I*K_O*C_O*WS*WS> > &BOOST_PP_CAT(din_,i),
  
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int K_I, int XY_I, int XY_O, int C_I, int K_O, int C_O, int WS>
void READ_BLOCK_WEIGHTS(REPEAT(READ_BLOCK_WEIGHTS_PARAMS)
                        ac_channel<PackedStencil<DTYPE, KI, K_I,1,1> > &dout){


//reuse the weights in the double buffer when looping through different image tiles.
#pragma hls_pipeline_init_interval 1
  READ: for(int p_idx = 0; p_idx < XY_O; p_idx++) {
    #define READ_BLOCK_WEIGHTS_INIT(z,i,unused)\
      chanStruct<PackedStencil<DTYPE, KI, 1>,C_I*K_O*C_O*WS*WS> BOOST_PP_CAT(tmp_,i);\
      BOOST_PP_CAT(tmp_,i) = BOOST_PP_CAT(din_,i).read();
    REPEAT(READ_BLOCK_WEIGHTS_INIT)

    for (int c_idx = 0; c_idx <C_O; c_idx++) {
      for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
        for (int k_idx = 0; k_idx < K_O; k_idx++) {
          for (int r_idx = 0; r_idx < C_I; r_idx++)
          {
            PackedStencil<DTYPE, KI, K_I> dout_struct;
            
            #define READ_BLOCK_WEIGHTS_DOUT(z,i,unused)\
              dout_struct.set_dim(BOOST_PP_CAT(tmp_, i).data[k_idx*C_I*C_O*WS*WS + c_idx*C_I*WS*WS + wx_idx*C_I + r_idx], i, 0, 0);
            REPEAT(READ_BLOCK_WEIGHTS_DOUT)

            dout.write(dout_struct);
          } // for r_idx
        } // for k_idx
      } // for wx_idx
    } // for c_idx
  } // for p_idx
}


/*Weight double buffer.
Inputs and outputs are a stream of PackedStencil of coefficients..
PackedStencil is a data struct that pack multiple elements into a long word to
increase the port width and bandwidth.
*/
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int KI, int K_I, int XY_I, int XY_O, int C_I, int K_O, int C_O, int WS>
  void double_buffer_weights(ac_channel<PackedStencil<DTYPE, KI, K_I> > &din, 
                             ac_channel<PackedStencil<DTYPE, KI, K_I> > &dout) {

  // Four banks of memorie, since the PE array is 4 x 4.
  #define DOUBLE_BUFFER_WEIGHT_INIT(z,i,unused)\
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, C_I*K_O*C_O*WS*WS> > BOOST_PP_CAT(shr_mem_,i);
  REPEAT(DOUBLE_BUFFER_WEIGHT_INIT)

  #define WRITE_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
  WRITE_BLOCK_WEIGHTS<DTYPE, KI, C_I, K_I, XY_O, K_O, C_O, WS>(din, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
  
  #define READ_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
    BOOST_PP_CAT(shr_mem_, i) ,
  READ_BLOCK_WEIGHTS<DTYPE, KI, K_I, XY_I, XY_O, C_I, K_O, C_O, WS>( REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) dout);
}
