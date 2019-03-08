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

 typedef struct {
   int Y_O;
   int X_O;
   int Y_I;
   int X_I;
   int K_I;
   int K_O;
   int C_I;
   int C_O;
   int WS;
 } Params;

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

// #define WRITE_BLOCK_INPUT_PARAMS(z, i, unused)\
//   BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<DTYPE,XY_I> > BOOST_PP_CAT(&dout_,i)

// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int C_I, int XY_I, int XY_O, int C_O, int WS>
// void WRITE_BLOCK_INPUT(ac_channel<PackedStencil<DTYPE,C_I> > &din,
//                       REPEAT(WRITE_BLOCK_INPUT_PARAMS)
//                       ) {

// #pragma hls_pipeline_init_interval 1
//   WRITE: for (int p_idx=0; p_idx < XY_O; p_idx++) {
//     for (int c_idx=0; c_idx < C_O; c_idx++) {

//       #define WRITE_BLOCK_INPUT_INIT(z, i, unused)\
//         chanStruct<DTYPE, XY_I> BOOST_PP_CAT(tmp_,i);
//       REPEAT(WRITE_BLOCK_INPUT_INIT)

//       for (int y_idx = 0; y_idx < 0 + XY_I; y_idx++)
//       {
//         PackedStencil<DTYPE,C_I,1,1> column;
//         column = din.read();
        
//         #define WRITE_BLOCK_INPUT_TMP_WRITE(z, i, unused)\
//           BOOST_PP_CAT(tmp_,i).data[y_idx] = column(i,0,0);
//         REPEAT(WRITE_BLOCK_INPUT_TMP_WRITE)
//       } // for y_idx
      
//       #define WRITE_BLOCK_INPUT_WRITE(z, i, unused)\
//         BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
//       REPEAT(WRITE_BLOCK_INPUT_WRITE)
//     } // for c_idx
//   } // for p_idx
// }

// #define READ_BLOCK_INPUT_PARAMS(z, i, unused)\
//   ac_channel<chanStruct<DTYPE,(Y_I+WS-1)*(X_I+WS-1)> > &BOOST_PP_CAT(din_,i),

// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int Y_I, int X_I, int Y_O, int X_O, int C_I, int K_O, int C_O, int WS>
// void READ_BLOCK_INPUT(REPEAT(READ_BLOCK_INPUT_PARAMS)
//                      ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout){

// /*reuse the input pixels in the double buffer when iterating through different kernels
// and window locations*/
// #pragma hls_pipeline_init_interval 1
//   READ: for(int ro_idx = 0; ro_idx < Y_O; ro_idx++) {
//     for (int co_idx=0; co_idx < X_O; co_idx++) {    
//       for (int c_idx = 0; c_idx <C_O; c_idx++) {
//         #define READ_BLOCK_INPUT_INIT(z, i, unused)\
//           chanStruct<DTYPE,(Y_I+WS-1)*(X_I+WS-1)> BOOST_PP_CAT(tmp_,i);
//         REPEAT(READ_BLOCK_INPUT_INIT)

//         #define READ_BLOCK_MEM_READ(z, i, unused)\
//           BOOST_PP_CAT(tmp_, i) = BOOST_PP_CAT(din_, i).read();
//         REPEAT(READ_BLOCK_MEM_READ)

//         for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
//         for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
//         for (int k_idx = 0; k_idx < K_O; k_idx++) {
//         for (int x_idx=0; x_idx < Y_I; x_idx++) {
//         for (int y_idx=0; y_idx < X_I; y_idx++)
//         {
//           PackedStencil<DTYPE, C_I,1,1> dout_struct;
          
//           #define READ_BLOCK_DOUT_STRUCT(z, i, unused)\
//             dout_struct( BOOST_PP_CAT(tmp_,i).data[(x_idx+wx_idx)* (X_I+WS-1) +  y_idx + wy_idx], i, 0, 0, 0);  
//           REPEAT(READ_BLOCK_DOUT_STRUCT)

//           dout.write(dout_struct);
        
//         } // for y_idx
//         } // for x_idx
//         } // for k_idx
//         } // for wy_idx
//         } // for wx_idx
//       } // for c_idx
//     } // for co_idx
//   } //for ro_idx
// }

// /*Input double buffer.
// Inputs are a stream of input pixels, outputs are a stream of PackedStencil of pixels.
// PackedStencil is a data struct that pack multiple elements into a long word to
// increase the port width and bandwidth.
// */
// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int Y_I, int X_I, int Y_O, int X_O, int C_I, int K_O, int C_O, int WS>
// void double_buffer_input( 
//                          ac_channel<PackedStencil<DTYPE,C_I> > &din, 
//                          ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout) {

//   // Four banks of memorie, since the PE array is 4 x 4.
//   #define DOUBLE_BUFFER_INPUT_INIT(z,i,unused)\
//     static ac_channel<chanStruct<DTYPE,(Y_I+WS-1)*(X_I+WS-1)> > BOOST_PP_CAT(shr_mem_,i);
//   REPEAT(DOUBLE_BUFFER_INPUT_INIT)

//   #define WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
//   WRITE_BLOCK_INPUT<DTYPE, C_I, (Y_I+WS-1)*(X_I+WS-1), Y_O*X_O, C_O, WS>(din, REPEAT(WRITE_BLOCK_INPUT_CALL_PARAMS) );
  
//   #define READ_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_CAT(shr_mem_, i),
//   READ_BLOCK_INPUT<DTYPE, Y_I, X_I, Y_O, X_O, C_I, K_O, C_O, WS>( REPEAT(READ_BLOCK_INPUT_CALL_PARAMS) dout);
// }


#define WRITE_BLOCK_INPUT_PARAMS(z, i, unused)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<DTYPE,size> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design block
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int C_I>
void ALT_WRITE_BLOCK_INPUT(ac_channel<Params> &param_stream,
                      ac_channel<PackedStencil<DTYPE,C_I> > &din,
                      REPEAT(WRITE_BLOCK_INPUT_PARAMS)
                      ) {

Params p = param_stream.read();
int block_size = (p.X_I+p.WS-1)*(p.Y_I+p.WS-1);
#pragma hls_pipeline_init_interval 1
  WRITE: for (int p_idx=0; p_idx < p.X_O*p.Y_O; p_idx++) {
    for (int c_idx=0; c_idx < p.C_O; c_idx++) {

      #define WRITE_BLOCK_INPUT_INIT(z, i, unused)\
        chanStruct<DTYPE, size> BOOST_PP_CAT(tmp_,i);
      REPEAT(WRITE_BLOCK_INPUT_INIT)

      for (int y_idx = 0; y_idx < block_size; y_idx++)
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
  ac_channel<chanStruct<DTYPE,size> > &BOOST_PP_CAT(din_,i),

#pragma hls_design block
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int C_I>
void ALT_READ_BLOCK_INPUT(ac_channel<Params> &param_stream, ac_channel<int> &addresses, ac_channel<int> &address_sizes,
                     REPEAT(READ_BLOCK_INPUT_PARAMS)
                     ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout){

Params p = param_stream.read();
/*reuse the input pixels in the double buffer when iterating through different kernels
and window locations*/
#pragma hls_pipeline_init_interval 1
  READ: for(int ro_idx = 0; ro_idx < p.Y_O; ro_idx++) {
    for (int co_idx=0; co_idx < p.X_O; co_idx++) {    
      for (int c_idx = 0; c_idx < p.C_O; c_idx++) {

        #define READ_BLOCK_INPUT_INIT(z, i, unused)\
          chanStruct<DTYPE,size> BOOST_PP_CAT(tmp_,i) = BOOST_PP_CAT(din_, i).read();
        REPEAT(READ_BLOCK_INPUT_INIT)

        int address_size = address_sizes.read();
        for(int idx = 0; idx < address_size; idx++){
          PackedStencil<DTYPE, C_I,1,1> dout_struct;

          int address = addresses.read();

          #define READ_BLOCK_DOUT_STRUCT(z, i, unused)\
            dout_struct( BOOST_PP_CAT(tmp_,i).data[address], i, 0, 0, 0);  
          REPEAT(READ_BLOCK_DOUT_STRUCT)

          dout.write(dout_struct);
        }

      } // for c_idx
    } // for co_idx
  } //for ro_idx
}

#pragma hls_design block
template<int size, int C_I>
void address_generator_inputs(ac_channel<Params> &params_stream,
                              ac_channel<int> &addresses, ac_channel<int> &address_sizes){
  Params params = params_stream.read();

  int total_blocks = params.X_O*params.Y_O*params.C_O;
  int block_size = (params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
  int inner_blocking = size/block_size; // how many blocks can fit in buffer
  int outer_blocking = total_blocks/inner_blocking;

  for(int outer_block = 0; outer_block < outer_blocking; outer_block++ ){
   int idx = 0;
    for (int inner_block = 0; inner_block < inner_blocking; inner_block++){
     if(total_blocks > 0){
        for (int wx_idx = 0; wx_idx < params.WS; wx_idx++) {
          for (int wy_idx = 0; wy_idx < params.WS; wy_idx++) {
            for (int k_idx = 0; k_idx < params.K_O; k_idx++) {
              for (int x_idx=0; x_idx < params.Y_I; x_idx++) {
                for (int y_idx=0; y_idx < params.X_I; y_idx++) {
                  int address = (inner_block*((params.Y_I+params.WS)*(params.X_I+params.WS-1) +  params.X_I + params.WS)) + ((x_idx+wx_idx)* (params.X_I+params.WS-1) +  y_idx + wy_idx);
                  addresses.write(address);
                  idx++;
                }
              }
            }
         }
        }
       total_blocks--;
      } 
    }
    address_sizes.write(idx);
  }
}

// #pragma hls_design block
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int size, int C_I>
// bool alt_double_buffer_input( 
//                          ac_channel<PackedStencil<DTYPE,C_I> > &din, 
//                          ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout,
//                          ac_channel<Params> &params_stream_1,
//                          ac_channel<Params> &params_stream_2,
//                          ac_channel<Params> &params_stream_3) {

//   // Four banks of memorie, since the PE array is 4 x 4.
//   #define DOUBLE_BUFFER_INPUT_INIT(z,i,unused)\
//     static ac_channel<chanStruct<DTYPE,size> > BOOST_PP_CAT(shr_mem_,i);
//   REPEAT(DOUBLE_BUFFER_INPUT_INIT)

//   static ac_channel<int> addresses;
//   static ac_channel<int> address_sizes;

//   address_generator_inputs<size, C_I>(params_stream_1, addresses, address_sizes);

//   #define WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
//   ALT_WRITE_BLOCK_INPUT<DTYPE, size, C_I>(params_stream_2, din, REPEAT(WRITE_BLOCK_INPUT_CALL_PARAMS) );
  
//   #define READ_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_CAT(shr_mem_, i),
//   ALT_READ_BLOCK_INPUT<DTYPE, size, C_I>( params_stream_3, addresses, address_sizes, REPEAT(READ_BLOCK_INPUT_CALL_PARAMS) dout);
  
//   return true;
// }

// #define ALT_WRITE_BLOCK_INPUT_PARAMS(z, i, unused)\
//   BOOST_PP_COMMA_IF(i) DTYPE BOOST_PP_CAT(dout_,i)[size]

// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template<typename DTYPE, int size, int C_I>
// void ALT_WRITE_BLOCK_INPUT(//int block_size, int total_blocks, int inner_blocking, bool &readyToRead, 
// ac_channel<PackedStencil<DTYPE,C_I> > &din, 
// REPEAT(ALT_WRITE_BLOCK_INPUT_PARAMS)){

// //    #ifndef __SYNTHESIS__
// //    if(readyToWrite.available(1)){
// //    #endif 
// // //      readyToWrite.read();  
// //       for(int inner_block = 0; inner_block < inner_blocking; inner_block++){
        
// // //        if(total_blocks > 0){
// //           for(int idx = 0; idx < block_size; idx++){
// //             PackedStencil<DTYPE,C_I> column;// = din.read();

// //             #define ALT_WRITE_BLOCK_INPUT_TMP_WRITE(z, i, unused)\
// //               BOOST_PP_CAT(dout_,i)[idx] = column(i,0,0);
// //             //REPEAT(ALT_WRITE_BLOCK_INPUT_TMP_WRITE)
// //           }

// //           //total_blocks--;  
// //   //      }
        
// //       }

// //       readyToRead = true;
// // #ifndef __SYNTHESIS__
// //   }
// //   #endif

// }

// #define ALT_READ_BLOCK_INPUT_PARAMS(z, i, unused)\
//   DTYPE BOOST_PP_CAT(channel_,i)[size],

// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template<typename DTYPE, int size, int C_I>
// void ALT_READ_BLOCK_INPUT(ac_channel<bool> &readyToWrite, bool &readyToRead, ac_channel<int> &addresses, ac_channel<int> &address_sizes,
//                            REPEAT(ALT_READ_BLOCK_INPUT_PARAMS)
//                            ac_channel<PackedStencil<DTYPE, C_I> > &dout  ){
  
//   if(addresses.size() > 0){
 
// //   if(readyToRead.size() > 0){ // memory has current block
// if(readyToRead){
//       readyToRead = false;
//       int address_size = address_sizes.read();
      

//       for(int idx = 0; idx < address_size; idx++){
//         PackedStencil<DTYPE, C_I,1,1> dout_struct;
//         int address = addresses.read();
//         #define ALT_READ_BLOCK_DOUT_STRUCT(z, i, unused)\
//             dout_struct( BOOST_PP_CAT(channel_,i)[address], i, 0, 0, 0);  
//         REPEAT(ALT_READ_BLOCK_DOUT_STRUCT)

//         dout.write(dout_struct);
//       }
      
//     }
//     else{ // no current block, set ready to write
//       readyToWrite.write(true);
//     }
    
//   }

// }



// inline void address_generator_helper(int inner_block, int x_idx, int wx_idx, int y_idx, int wy_idx, int Y_I, int X_I, int K_O, int WS, ac_channel<int> &addresses){
//           int address = (inner_block*((Y_I+WS)*(X_I+WS-1) +  X_I + WS)) + ((x_idx+wx_idx)* (X_I+WS-1) +  y_idx + wy_idx);
//           addresses.write(address);    
// }
    
    


// template<int size, int C_I>
// void address_generator_inputs(int Y_I, int X_I, int K_O, int WS,
//                               ac_channel<int> &addresses, ac_channel<int> &address_sizes,
//                               int outer_blocking, int inner_blocking, int total_blocks){
//   for(int outer_block = 0; outer_block < outer_blocking; outer_block++ ){
//   //  int idx = 0; // size goes at idx 0
//     for (int inner_block = 0; inner_block < inner_blocking; inner_block++){
// //      if(total_blocks > 0){
//         for (int wx_idx = 0; wx_idx < WS; wx_idx++) {
//           for (int wy_idx = 0; wy_idx < WS; wy_idx++) {
//             for (int k_idx = 0; k_idx < K_O; k_idx++) {
//               for (int x_idx=0; x_idx < Y_I; x_idx++) {
//                 for (int y_idx=0; y_idx < X_I; y_idx++) {
// //                    addresses.write(1);
//                   address_generator_helper(inner_block, x_idx, wx_idx, y_idx, wy_idx, Y_I,X_I,K_O,WS,addresses);
//                   //idx++;
                  
//                 }
//               }
//             }
//   //        }
//         }
// //        total_blocks--;
//       } 
      
//     }
//     //address_sizes.write(idx);
//   }
// }

// // #pragma hls_design
// // #pragma hls_pipeline_init_interval 1
// // template<typename DTYPE, int size, int C_I>
// // void alt_double_buffer_input(ac_channel<PackedStencil<DTYPE,C_I> > &din,
// //                              ac_channel<PackedStencil<DTYPE,C_I> > &dout,
// //                              int Y_I, int X_I, int Y_O, int X_O, int K_O, int C_O, int WS){
// //   #define INPUT_MEMORY(z,i,unused)\
// //     static DTYPE BOOST_PP_CAT(channel_,i)[size];
// //   REPEAT(INPUT_MEMORY)

// //   static ac_channel<int> addresses;
// //   static ac_channel<int> address_sizes;
  
// //   static ac_channel<bool> readyToWrite;
// //   //static ac_channel<bool> readyToRead;
  
// //   static bool readyToRead;

// //   int num_blocks = X_O*Y_O*C_O;
// //   int block_size = (X_I+WS-1)*(Y_I+WS-1);
// //   int inner_blocking = size/block_size; // how many blocks can fit in buffer
// //   int outer_blocking = num_blocks/inner_blocking; 

// //   address_generator_inputs<size, C_I>(Y_I, X_I, K_O, WS, addresses, address_sizes, outer_blocking, inner_blocking, num_blocks);

// //   #ifndef __SYNTHESIS__
// //   while(din.available(1)){
// //   #endif
// //   #define ALT_WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
// //     BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(channel_, i)
// //   ALT_WRITE_BLOCK_INPUT<DTYPE, size, C_I>(block_size, num_blocks, inner_blocking, readyToRead, din, REPEAT(ALT_WRITE_BLOCK_INPUT_CALL_PARAMS) );

// //   #define ALT_READ_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
// //     BOOST_PP_CAT(channel_, i),
// //   ALT_READ_BLOCK_INPUT<DTYPE, size, C_I>(readyToWrite, readyToRead, addresses, address_sizes, REPEAT(ALT_READ_BLOCK_INPUT_CALL_PARAMS) dout);
// //   #ifndef __SYNTHESIS__
// //   }
// //   #endif
// // }

#define WRITE_BLOCK_WEIGHT_PARAMS(z,i,unused)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, size> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int KI, int K_I>
void WRITE_BLOCK_WEIGHTS(ac_channel<Params> &params_stream,
                         ac_channel<PackedStencil<DTYPE, KI, K_I> > &din,
                         REPEAT(WRITE_BLOCK_WEIGHT_PARAMS)) {

Params params = params_stream.read();
int block_size = params.C_I*params.K_O*params.C_O*params.WS*params.WS;                             
#pragma hls_pipeline_init_interval 1
  WRITE: for(int p_idx = 0; p_idx < params.X_O*params.Y_O; p_idx++) {
    
    #define WRITE_BLOCK_WEIGHTS_INIT(z,i,unused)\
      chanStruct<PackedStencil<DTYPE, KI, 1>, size> BOOST_PP_CAT(tmp_,i);
    REPEAT(WRITE_BLOCK_WEIGHTS_INIT)

    for(int idx = 0; idx < block_size; idx++){
      PackedStencil<DTYPE, KI, K_I> row;
      row = din.read();

      #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
        BOOST_PP_CAT(tmp_, i).data[idx] = row.get_dim(i,0,0);
        REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
    }

    // for (int k_idx = 0; k_idx < K_O; k_idx++) {
    //   for (int c_idx = 0; c_idx < C_O; c_idx++) {
    //     for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {
    //       for (int r_idx = 0; r_idx < 0 + C_I; r_idx++)
    //       {
    //         PackedStencil<DTYPE, KI, K_I> row;
    //         row     = din.read();

    //         #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
    //           BOOST_PP_CAT(tmp_, i).data[k_idx*C_I*C_O*WS*WS + c_idx*C_I*WS*WS + wx_idx*C_I  + r_idx] = row.get_dim(i,0,0);
    //         REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
    //       } // for r_idx
    //     } // for wx_idx
    //   } //for c_idx
    // } // for k_idx

    #define WRITE_BLOCK_WEIGHTS_WRITE(z,i,unused)\
      BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
    REPEAT(WRITE_BLOCK_WEIGHTS_WRITE)

  } // for p_idx
}


#define READ_BLOCK_WEIGHTS_PARAMS(z,i,unused)\
  ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, size> > &BOOST_PP_CAT(din_,i),
  
#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int KI, int K_I>
void READ_BLOCK_WEIGHTS(ac_channel<Params> &param_stream, 
                        ac_channel<int> &addresses,
                        ac_channel<int> &address_sizes,
                        REPEAT(READ_BLOCK_WEIGHTS_PARAMS)
                        ac_channel<PackedStencil<DTYPE, KI, K_I,1,1> > &dout){

Params params = param_stream.read();
//reuse the weights in the double buffer when looping through different image tiles.
#pragma hls_pipeline_init_interval 1
  READ: for(int p_idx = 0; p_idx < params.X_O*params.Y_O; p_idx++) {
    #define READ_BLOCK_WEIGHTS_INIT(z,i,unused)\
      chanStruct<PackedStencil<DTYPE, KI, 1>,size> BOOST_PP_CAT(tmp_,i);\
      BOOST_PP_CAT(tmp_,i) = BOOST_PP_CAT(din_,i).read();
    REPEAT(READ_BLOCK_WEIGHTS_INIT)
    int address_size = address_sizes.read();
    for(int idx = 0; idx < address_size; idx++){
      PackedStencil<DTYPE, KI, K_I> dout_struct;

      int address = addresses.read();

      #define READ_BLOCK_WEIGHTS_DOUT(z,i,unused)\
        dout_struct.set_dim(BOOST_PP_CAT(tmp_, i).data[address], i, 0, 0);
      REPEAT(READ_BLOCK_WEIGHTS_DOUT)

      dout.write(dout_struct);
    }
    // for (int c_idx = 0; c_idx <C_O; c_idx++) {
    //   for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
    //     for (int k_idx = 0; k_idx < K_O; k_idx++) {
    //       for (int r_idx = 0; r_idx < C_I; r_idx++)
    //       {
    //         PackedStencil<DTYPE, KI, K_I> dout_struct;
            
    //         #define READ_BLOCK_WEIGHTS_DOUT(z,i,unused)\
    //           dout_struct.set_dim(BOOST_PP_CAT(tmp_, i).data[k_idx*C_I*C_O*WS*WS + c_idx*C_I*WS*WS + wx_idx*C_I + r_idx], i, 0, 0);
    //         REPEAT(READ_BLOCK_WEIGHTS_DOUT)

    //         dout.write(dout_struct);
    //       } // for r_idx
    //     } // for k_idx
    //   } // for wx_idx
    // } // for c_idx
  } // for p_idx
}

#pragma hls_design block
template<int size>
void  address_generator_weights(ac_channel<Params> &params_stream,
                              ac_channel<int> &addresses, ac_channel<int> &address_sizes){
  Params params = params_stream.read();

  int total_blocks = params.X_O * params.Y_O;
  int block_size = params.C_I*params.K_O*params.C_O*params.WS*params.WS;
  int inner_blocking = size / block_size;
  int outer_blocking = total_blocks / inner_blocking;

  for(int outer_block = 0; outer_block < outer_blocking; outer_block++ ){
   int idx = 0;
   for (int inner_block = 0; inner_block < inner_blocking; inner_block++){
     if(total_blocks > 0){
       for (int c_idx = 0; c_idx <params.C_O; c_idx++) {
        for (int wx_idx = 0; wx_idx < params.WS*params.WS; wx_idx++){
          for (int k_idx = 0; k_idx < params.K_O; k_idx++) {
            for (int r_idx = 0; r_idx < params.C_I; r_idx++){
              int address = inner_block*
                              ( 
                                (params.K_O*params.C_I*params.C_O*params.WS*params.WS) +
                                (params.C_O*params.C_I*params.WS*params.WS) + 
                                (params.WS*params.WS*params.C_I) +
                                (params.C_I) 
                              )
                            + 
                              (
                                (k_idx*params.C_I*params.C_O*params.WS*params.WS) +
                                (c_idx*params.C_I*params.WS*params.WS) + 
                                (wx_idx*params.C_I) + 
                                (r_idx) 
                              );
              addresses.write(address);
              idx++;
            }
          }
        }
       }
      total_blocks--;
     }
   }
   address_sizes.write(idx);
  }
}

/*Weight double buffer.
Inputs and outputs are a stream of PackedStencil of coefficients..
PackedStencil is a data struct that pack multiple elements into a long word to
increase the port width and bandwidth.
*/
// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int size, int KI, int K_I>
//   bool double_buffer_weights(ac_channel<PackedStencil<DTYPE, KI, K_I> > &din, 
//                              ac_channel<PackedStencil<DTYPE, KI, K_I> > &dout,
//                              ac_channel<Params> &params_stream_1,
//                              ac_channel<Params> &params_stream_2,
//                              ac_channel<Params> &params_stream_3) {

//   // Four banks of memorie, since the PE array is 4 x 4.
//   #define DOUBLE_BUFFER_WEIGHT_INIT(z,i,unused)\
//     static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, size> > BOOST_PP_CAT(shr_mem_,i);
//   REPEAT(DOUBLE_BUFFER_WEIGHT_INIT)

//   static ac_channel<int> addresses;
//   static ac_channel<int> address_sizes;

//   address_generator_weights<size>(params_stream_1, addresses, address_sizes);

//   #define WRITE_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
//   // WRITE_BLOCK_WEIGHTS<DTYPE, KI, C_I, K_I, XY_O, K_O, C_O, WS>(din, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
//   WRITE_BLOCK_WEIGHTS<DTYPE, size, KI, K_I>(params_stream_2, din, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
  
//   #define READ_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_CAT(shr_mem_, i) ,
//   // READ_BLOCK_WEIGHTS<DTYPE, KI, K_I, XY_I, XY_O, C_I, K_O, C_O, WS>( REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) dout);
//   READ_BLOCK_WEIGHTS<DTYPE, size, KI, K_I>(params_stream_3, addresses, address_sizes, REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) dout);
  
//   return true;
// }


// #define WRITE_BLOCK_WEIGHT_PARAMS(z,i,unused)\
//   BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, C_I*K_O*C_O*WS*WS> > BOOST_PP_CAT(&dout_,i)

// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int KI, int C_I, int K_I, int XY_O, int K_O, int C_O, int WS>
// void WRITE_BLOCK_WEIGHTS(ac_channel<PackedStencil<DTYPE, KI, K_I> > &din,
//                          REPEAT(WRITE_BLOCK_WEIGHT_PARAMS)
//                         ) {
                             
// #pragma hls_pipeline_init_interval 1
//   WRITE: for(int p_idx = 0; p_idx < XY_O; p_idx++) {
    
//     #define WRITE_BLOCK_WEIGHTS_INIT(z,i,unused)\
//       chanStruct<PackedStencil<DTYPE, KI, 1>, C_I*K_O*C_O*WS*WS> BOOST_PP_CAT(tmp_,i);
//     REPEAT(WRITE_BLOCK_WEIGHTS_INIT)

//     for (int k_idx = 0; k_idx < K_O; k_idx++) {
//       for (int c_idx = 0; c_idx < C_O; c_idx++) {
//         for (int wx_idx=0; wx_idx < WS*WS; wx_idx++) {
//           for (int r_idx = 0; r_idx < 0 + C_I; r_idx++)
//           {
//             PackedStencil<DTYPE, KI, K_I> row;
//             row     = din.read();

//             #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
//               BOOST_PP_CAT(tmp_, i).data[k_idx*C_I*C_O*WS*WS + c_idx*C_I*WS*WS + wx_idx*C_I  + r_idx] = row.get_dim(i,0,0);
//             REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
//           } // for r_idx
//         } // for wx_idx
//       } //for c_idx
//     } // for k_idx

//     #define WRITE_BLOCK_WEIGHTS_WRITE(z,i,unused)\
//       BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
//     REPEAT(WRITE_BLOCK_WEIGHTS_WRITE)

//   } // for p_idx
// }


// #define READ_BLOCK_WEIGHTS_PARAMS(z,i,unused)\
//   ac_channel<chanStruct<PackedStencil<DTYPE,KI,1,1,1>, C_I*K_O*C_O*WS*WS> > &BOOST_PP_CAT(din_,i),
  
// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int KI, int K_I, int XY_I, int XY_O, int C_I, int K_O, int C_O, int WS>
// void READ_BLOCK_WEIGHTS(REPEAT(READ_BLOCK_WEIGHTS_PARAMS)
//                         ac_channel<PackedStencil<DTYPE, KI, K_I,1,1> > &dout){


// //reuse the weights in the double buffer when looping through different image tiles.
// #pragma hls_pipeline_init_interval 1
//   READ: for(int p_idx = 0; p_idx < XY_O; p_idx++) {
//     #define READ_BLOCK_WEIGHTS_INIT(z,i,unused)\
//       chanStruct<PackedStencil<DTYPE, KI, 1>,C_I*K_O*C_O*WS*WS> BOOST_PP_CAT(tmp_,i);\
//       BOOST_PP_CAT(tmp_,i) = BOOST_PP_CAT(din_,i).read();
//     REPEAT(READ_BLOCK_WEIGHTS_INIT)

//     for (int c_idx = 0; c_idx <C_O; c_idx++) {
//       for (int wx_idx = 0; wx_idx < WS*WS; wx_idx++){
//         for (int k_idx = 0; k_idx < K_O; k_idx++) {
//           for (int r_idx = 0; r_idx < C_I; r_idx++)
//           {
//             PackedStencil<DTYPE, KI, K_I> dout_struct;
            
//             #define READ_BLOCK_WEIGHTS_DOUT(z,i,unused)\
//               dout_struct.set_dim(BOOST_PP_CAT(tmp_, i).data[k_idx*C_I*C_O*WS*WS + c_idx*C_I*WS*WS + wx_idx*C_I + r_idx], i, 0, 0);
//             REPEAT(READ_BLOCK_WEIGHTS_DOUT)

//             dout.write(dout_struct);
//           } // for r_idx
//         } // for k_idx
//       } // for wx_idx
//     } // for c_idx
//   } // for p_idx
// }


// /*Weight double buffer.
// Inputs and outputs are a stream of PackedStencil of coefficients..
// PackedStencil is a data struct that pack multiple elements into a long word to
// increase the port width and bandwidth.
// */
// #pragma hls_design
// #pragma hls_pipeline_init_interval 1
// template <typename DTYPE, int KI, int K_I, int XY_I, int XY_O, int C_I, int K_O, int C_O, int WS>
//   void double_buffer_weights(ac_channel<PackedStencil<DTYPE, KI, K_I> > &din, 
//                              ac_channel<PackedStencil<DTYPE, KI, K_I> > &dout) {

//   // Four banks of memorie, since the PE array is 4 x 4.
//   #define DOUBLE_BUFFER_WEIGHT_INIT(z,i,unused)\
//     static ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1,1,1>, C_I*K_O*C_O*WS*WS> > BOOST_PP_CAT(shr_mem_,i);
//   REPEAT(DOUBLE_BUFFER_WEIGHT_INIT)

//   #define WRITE_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(shr_mem_, i)
//   WRITE_BLOCK_WEIGHTS<DTYPE, KI, C_I, K_I, XY_O, K_O, C_O, WS>(din, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
  
//   #define READ_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
//     BOOST_PP_CAT(shr_mem_, i) ,
//   READ_BLOCK_WEIGHTS<DTYPE, KI, K_I, XY_I, XY_O, C_I, K_O, C_O, WS>( REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) dout);
// }

#pragma hls_design block
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int input_size, int weight_size, int C_I, int KI, int K_I>
void unified_double_buffer(ac_channel<PackedStencil<DTYPE, C_I> > &inputs_din, 
                      ac_channel<PackedStencil<DTYPE, C_I> > &inputs_out,
                      ac_channel<PackedStencil<DTYPE, KI, K_I> > &weights_in,
                      ac_channel<PackedStencil<DTYPE, KI, K_I> > &weights_out,
                      ac_channel<Params> &params_stream_1,
                      ac_channel<Params> &params_stream_2,
                      ac_channel<Params> &params_stream_3,
                      ac_channel<Params> &params_stream_4,
                      ac_channel<Params> &params_stream_5,
                      ac_channel<Params> &params_stream_6){
  // input banks
  #define DOUBLE_BUFFER_INPUT_INIT(z,i,unused)\
    static ac_channel<chanStruct<DTYPE,input_size> > BOOST_PP_CAT(inputs_shr_mem_,i);
  REPEAT(DOUBLE_BUFFER_INPUT_INIT)

  // weight banks
  #define DOUBLE_BUFFER_WEIGHT_INIT(z,i,unused)\
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI>, weight_size> > BOOST_PP_CAT(weights_shr_mem_,i);
  REPEAT(DOUBLE_BUFFER_WEIGHT_INIT)

  // input address generator
  static ac_channel<int> inputs_addresses;
  static ac_channel<int> inputs_address_sizes;
  address_generator_inputs<input_size, C_I>(params_stream_1, inputs_addresses, inputs_address_sizes);

  // weight address generator
  static ac_channel<int> weights_addresses;
  static ac_channel<int> weights_address_sizes;
  address_generator_weights<weight_size>(params_stream_2, weights_addresses, weights_address_sizes);

  // Inputs write + read
  #define WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(inputs_shr_mem_, i)
  ALT_WRITE_BLOCK_INPUT<DTYPE, input_size, C_I>(params_stream_3, inputs_din, REPEAT(WRITE_BLOCK_INPUT_CALL_PARAMS) );

  #define READ_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
    BOOST_PP_CAT(inputs_shr_mem_, i),
  ALT_READ_BLOCK_INPUT<DTYPE, input_size, C_I>( params_stream_4, inputs_addresses, inputs_address_sizes, REPEAT(READ_BLOCK_INPUT_CALL_PARAMS) inputs_out);

  // Weights write + read
  #define WRITE_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(weights_shr_mem_, i)
  WRITE_BLOCK_WEIGHTS<DTYPE, weight_size, KI, K_I>(params_stream_5, weights_in, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
  
  #define READ_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
    BOOST_PP_CAT(weights_shr_mem_, i) ,
  READ_BLOCK_WEIGHTS<DTYPE, weight_size, KI, K_I>(params_stream_6, weights_addresses, weights_address_sizes, REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) weights_out);
}
