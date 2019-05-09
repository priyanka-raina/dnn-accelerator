// double buffer implementation for Catapult HLS
#include "ac_channel.h"
#include "Stencil_catapult.h"
#include "params.h"
#include "array_dimensions.h"

#include <boost/preprocessor/repetition/repeat.hpp>
#include <boost/preprocessor/punctuation/comma_if.hpp>
#include <boost/preprocessor/cat.hpp>

#define MIN(x, y) ((x) < (y) ? (x) : (y))

template<typename T, int N>
struct chanStruct{
  T data[N];
 };


//FIFO implemented as shift registers
#pragma hls_map_to_operator [CCORE]
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
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<DTYPE,size> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design block
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int C_I>
void WRITE_BLOCK_INPUT(ac_channel<Params> &param_stream,
                      ac_channel<PackedStencil<DTYPE,C_I> > &din,
                      REPEAT(WRITE_BLOCK_INPUT_PARAMS)
                      ) {

static Params params = param_stream.read();

int total_blocks = params.X_O*params.Y_O*params.C_O;
int block_size = (params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
int blocks_per_buffer = size / block_size;
int outer_blocking = total_blocks/blocks_per_buffer;

#pragma hls_pipeline_init_interval 1
  for(int o_block = 0; o_block < outer_blocking; o_block++){

      #define WRITE_BLOCK_INPUT_INIT(z, i, unused)\
        chanStruct<DTYPE, size> BOOST_PP_CAT(tmp_,i);
      REPEAT(WRITE_BLOCK_INPUT_INIT)

      for(int j = 0; j < blocks_per_buffer; j++){
        if(total_blocks > 0){
          
          for(int idx = 0; idx < block_size; idx++){
            PackedStencil<DTYPE,C_I,1,1> column;
            column = din.read();
            
            #define WRITE_BLOCK_INPUT_TMP_WRITE(z, i, unused)\
              BOOST_PP_CAT(tmp_,i).data[j*block_size+idx] = column(i,0,0);
            REPEAT(WRITE_BLOCK_INPUT_TMP_WRITE)
          }

          total_blocks--;
        }
        
      }
      
      #define WRITE_BLOCK_INPUT_WRITE(z, i, unused)\
        BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
      REPEAT(WRITE_BLOCK_INPUT_WRITE)

    }
}

#define READ_BLOCK_INPUT_PARAMS(z, i, unused)\
  ac_channel<chanStruct<DTYPE,size> > &BOOST_PP_CAT(din_,i),

#pragma hls_design block
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int C_I>
void READ_BLOCK_INPUT(ac_channel<Params> &param_stream, ac_channel<int> &addresses, ac_channel<int> &address_sizes,
                     REPEAT(READ_BLOCK_INPUT_PARAMS)
                     ac_channel<PackedStencil<DTYPE, C_I,1,1> > &dout){

static Params params = param_stream.read();

int total_blocks = params.X_O*params.Y_O*params.C_O;
int block_size = (params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
int blocks_per_buffer = size / block_size;
int outer_blocking = total_blocks/blocks_per_buffer;

/*reuse the input pixels in the double buffer when iterating through different kernels
and window locations*/
#pragma hls_pipeline_init_interval 1
  for(int o_block = 0; o_block < outer_blocking; o_block++){

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

  }
}

#pragma hls_design block
template<int size, int C_I>
void address_generator_inputs(ac_channel<Params> &params_stream,
                              ac_channel<int> &addresses, ac_channel<int> &address_sizes){
  static Params params = params_stream.read();

  int total_blocks = params.X_O*params.Y_O*params.C_O;
  int block_size = (params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
  int inner_blocking = size/block_size;
  int outer_blocking = total_blocks/inner_blocking;

  for(int outer_block = 0; outer_block < outer_blocking; outer_block++ ){
   int idx = 0;
   
   int chunk_address_size = MIN(inner_blocking, total_blocks) * params.K_OO*params.WS*params.WS*params.K_OI*params.Y_I*params.X_I;
   address_sizes.write(chunk_address_size);

    for (int inner_block = 0; inner_block < inner_blocking; inner_block++){
     if(total_blocks > 0){
       for(int koo_idx = 0; koo_idx < params.K_OO; koo_idx++){
        for (int wx_idx = 0; wx_idx < params.WS; wx_idx++) {
          for (int wy_idx = 0; wy_idx < params.WS; wy_idx++) {
            for (int koi_idx = 0; koi_idx < params.K_OI; koi_idx++) {
              for (int x_idx=0; x_idx < params.Y_I; x_idx++) {
                for (int y_idx=0; y_idx < params.X_I; y_idx++) {
                  int address = (inner_block*block_size
                                  // (
                                  //   (params.Y_I+params.WS)*(params.X_I+params.WS-1) +
                                  //   params.X_I + 
                                  //   params.WS
                                  // )
                                ) +
                                (
                                  (x_idx+wx_idx)*(params.X_I+params.WS-1) +
                                  y_idx +
                                  wy_idx
                                );
                  addresses.write(address);
                  idx++;
                }
              }
            }
         }
        }
       }
       total_blocks--;
      } 
    }
    // address_sizes.write(idx);
  }
}

#define WRITE_BLOCK_WEIGHT_PARAMS(z,i,unused)\
  BOOST_PP_COMMA_IF(i) ac_channel<chanStruct<PackedStencil<DTYPE, KI, 1>, size> > BOOST_PP_CAT(&dout_,i)

#pragma hls_design
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int size, int KI, int K_I>
void WRITE_BLOCK_WEIGHTS(ac_channel<Params> &params_stream,
                         ac_channel<PackedStencil<DTYPE, KI, K_I> > &din,
                         REPEAT(WRITE_BLOCK_WEIGHT_PARAMS)) {

static Params params = params_stream.read();

int total_blocks = params.X_O * params.Y_O * params.C_O * params.K_OO;
int block_size = params.C_I*params.K_OI*params.WS*params.WS;
int blocks_per_buffer = size / block_size;
int outer_blocking = total_blocks / blocks_per_buffer;

#pragma hls_pipeline_init_interval 1
for(int o_block = 0; o_block < outer_blocking; o_block++){

  #define WRITE_BLOCK_WEIGHTS_INIT(z,i,unused)\
    chanStruct<PackedStencil<DTYPE, KI, 1>, size> BOOST_PP_CAT(tmp_,i);
  REPEAT(WRITE_BLOCK_WEIGHTS_INIT)

  for(int j = 0; j < blocks_per_buffer; j++){
    if(total_blocks > 0){
      for(int idx = 0; idx < block_size; idx++){
        PackedStencil<DTYPE, KI, K_I> row;
        row = din.read();

        #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
          BOOST_PP_CAT(tmp_, i).data[j*block_size+idx] = row.get_dim(i,0,0);
          REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
      }

      total_blocks--;
    }
  }

  #define WRITE_BLOCK_WEIGHTS_WRITE(z,i,unused)\
        BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
      REPEAT(WRITE_BLOCK_WEIGHTS_WRITE)

}
                         }

//   WRITE: for(int p_idx = 0; p_idx < params.X_O*params.Y_O; p_idx++) {
//     for(int c_idx = 0; c_idx < params.C_O; c_idx++){
//       for(int koo_idx = 0; koo_idx < params.K_OO; koo_idx++){
    
//         #define WRITE_BLOCK_WEIGHTS_INIT(z,i,unused)\
//           chanStruct<PackedStencil<DTYPE, KI, 1>, size> BOOST_PP_CAT(tmp_,i);
//         REPEAT(WRITE_BLOCK_WEIGHTS_INIT)

//         for(int idx = 0; idx < block_size*blocks_per_buffer; idx++){
//           PackedStencil<DTYPE, KI, K_I> row;
//           row = din.read();

//           #define WRITE_BLOCK_WEIGHT_TEMP_WRITE(z,i,unused)\
//             BOOST_PP_CAT(tmp_, i).data[idx] = row.get_dim(i,0,0);
//             REPEAT(WRITE_BLOCK_WEIGHT_TEMP_WRITE)
//         }

//         #define WRITE_BLOCK_WEIGHTS_WRITE(z,i,unused)\
//           BOOST_PP_CAT(dout_,i).write(BOOST_PP_CAT(tmp_,i));
//         REPEAT(WRITE_BLOCK_WEIGHTS_WRITE)

//       }
//     }
//   } // for p_idx
// }


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

static Params params = param_stream.read();

int total_blocks = params.X_O * params.Y_O * params.C_O * params.K_OO;
int block_size = params.C_I*params.K_OI*params.WS*params.WS;
int blocks_per_buffer = size / block_size;
int outer_blocking = total_blocks / blocks_per_buffer;

//reuse the weights in the double buffer when looping through different image tiles.
#pragma hls_pipeline_init_interval 1
  for(int o_block = 0; o_block < outer_blocking; o_block++){
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
      
    
  } // for p_idx
}

#pragma hls_design block
template<int size>
void  address_generator_weights(ac_channel<Params> &params_stream,
                              ac_channel<int> &addresses, ac_channel<int> &address_sizes){
  static Params params = params_stream.read();

  int total_blocks = params.X_O * params.Y_O * params.C_O * params.K_OO;
  int block_size = params.C_I*params.K_OI*params.WS*params.WS;
  int inner_blocking = size / block_size;
  int outer_blocking = total_blocks / inner_blocking;

  for(int outer_block = 0; outer_block < outer_blocking; outer_block++ ){
   int idx = 0;

   int chunk_address_size = MIN(inner_blocking, total_blocks) * params.WS*params.WS*params.K_OI*params.C_I;
   address_sizes.write(chunk_address_size);

   for (int inner_block = 0; inner_block < inner_blocking; inner_block++){
     if(total_blocks > 0){
      for (int wx_idx = 0; wx_idx < params.WS*params.WS; wx_idx++){
       for (int koi_idx = 0; koi_idx < params.K_OI; koi_idx++) {
          for (int r_idx = 0; r_idx < params.C_I; r_idx++){
              int address = inner_block*block_size
                            + 
                              (
                                (koi_idx*params.C_I*params.WS*params.WS) +
                                (wx_idx*params.C_I) + 
                                (r_idx) 
                              );
              addresses.write(address);
              idx++;
            }
          }
        }
      total_blocks--;
     }
   }
  //  address_sizes.write(idx);
  }
}


#pragma hls_design block
void params_duplicator(ac_channel<Params> &params_stream, 
                      ac_channel<Params> &params_stream_address_generator_inputs, 
                      ac_channel<Params> &params_stream_address_generator_weights,
                      ac_channel<Params> &params_stream_write_input,
                      ac_channel<Params> &params_stream_read_input,
                      ac_channel<Params> &params_stream_write_weight,
                      ac_channel<Params> &params_stream_read_weight){
                        
                        #ifndef __SYNTHESIS__
                        while(params_stream.available(1))
                        #endif
                        {
                        Params p = params_stream.read();

                        params_stream_address_generator_inputs.write(p);
                        params_stream_address_generator_weights.write(p);
                        params_stream_write_input.write(p);
                        params_stream_read_input.write(p);
                        params_stream_write_weight.write(p);
                        params_stream_read_weight.write(p);
                        }

                      }

#pragma hls_design block
#pragma hls_pipeline_init_interval 1
template <typename DTYPE, int input_size, int weight_size, int C_I, int KI, int K_I>
void unified_double_buffer(ac_channel<PackedStencil<DTYPE, C_I> > &inputs_din, 
                      ac_channel<PackedStencil<DTYPE, C_I> > &inputs_out,
                      ac_channel<PackedStencil<DTYPE, KI, K_I> > &weights_in,
                      ac_channel<PackedStencil<DTYPE, KI, K_I> > &weights_out,
                      ac_channel<Params> &params_stream){
  // input banks
  #define DOUBLE_BUFFER_INPUT_INIT(z,i,unused)\
    static ac_channel<chanStruct<DTYPE,input_size> > BOOST_PP_CAT(inputs_shr_mem_,i);
  REPEAT(DOUBLE_BUFFER_INPUT_INIT)

  // weight banks
  #define DOUBLE_BUFFER_WEIGHT_INIT(z,i,unused)\
    static ac_channel<chanStruct<PackedStencil<DTYPE, KI>, weight_size> > BOOST_PP_CAT(weights_shr_mem_,i);
  REPEAT(DOUBLE_BUFFER_WEIGHT_INIT)

  static ac_channel<Params> params_stream_address_generator_inputs;
  static ac_channel<Params> params_stream_address_generator_weights;
  static ac_channel<Params> params_stream_write_input;
  static ac_channel<Params> params_stream_read_input;
  static ac_channel<Params> params_stream_write_weight;
  static ac_channel<Params> params_stream_read_weight;

  params_duplicator(params_stream, 
                    params_stream_address_generator_inputs, 
                    params_stream_address_generator_weights,
                    params_stream_write_input,
                    params_stream_read_input,
                    params_stream_write_weight,
                    params_stream_read_weight);

  // input address generator
  static ac_channel<int> inputs_addresses;
  static ac_channel<int> inputs_address_sizes;
  address_generator_inputs<input_size, C_I>(params_stream_address_generator_inputs, inputs_addresses, inputs_address_sizes);

  // weight address generator
  static ac_channel<int> weights_addresses;
  static ac_channel<int> weights_address_sizes;
  address_generator_weights<weight_size>(params_stream_address_generator_weights, weights_addresses, weights_address_sizes);

  // Inputs write + read
  #define WRITE_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(inputs_shr_mem_, i)
  WRITE_BLOCK_INPUT<DTYPE, input_size, C_I>(params_stream_write_input, inputs_din, REPEAT(WRITE_BLOCK_INPUT_CALL_PARAMS) );

  #define READ_BLOCK_INPUT_CALL_PARAMS(z,i,unused)\
    BOOST_PP_CAT(inputs_shr_mem_, i),
  READ_BLOCK_INPUT<DTYPE, input_size, C_I>(params_stream_read_input, inputs_addresses, inputs_address_sizes, REPEAT(READ_BLOCK_INPUT_CALL_PARAMS) inputs_out);

  // Weights write + read
  #define WRITE_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
    BOOST_PP_COMMA_IF(i) BOOST_PP_CAT(weights_shr_mem_, i)
  WRITE_BLOCK_WEIGHTS<DTYPE, weight_size, KI, K_I>(params_stream_write_weight, weights_in, REPEAT(WRITE_BLOCK_WEIGHTS_CALL_PARAMS) );
  
  #define READ_BLOCK_WEIGHTS_CALL_PARAMS(z,i,unused)\
    BOOST_PP_CAT(weights_shr_mem_, i) ,
  READ_BLOCK_WEIGHTS<DTYPE, weight_size, KI, K_I>(params_stream_read_weight, weights_addresses, weights_address_sizes, REPEAT(READ_BLOCK_WEIGHTS_CALL_PARAMS) weights_out);
}

template<typename DTYPE, int size>
void WRITE_HIERARCHICAL_BUFFER(ac_channel<DTYPE> &din, 
                          ac_channel<chanStruct<DTYPE, size> > &shr_mem,
                          ac_channel<int> &sizes){
  #ifndef __SYNTHESIS__
  while(din.available(1))
  #endif
  {
    chanStruct<DTYPE, size> tmp;
    int idx = 0;
    while(idx < size && din.available(1)){
      tmp.data[idx++] = din.read();
    }
    shr_mem.write(tmp);
    sizes.write(idx);
  }
}

template<typename DTYPE, int size>
void READ_HIERARCHICAL_BUFFER(ac_channel<chanStruct<DTYPE, size> > &shr_mem,
                         ac_channel<int> &sizes,
                         ac_channel<DTYPE> &dout){
  #ifndef __SYNTHESIS__
  while(sizes.available(1))
  #endif
  {
    int max_size = sizes.read();
    chanStruct<DTYPE, size> tmp = shr_mem.read();
    for(int i = 0; i < max_size; i++){
      dout.write(tmp.data[i]);
    }
  }
}

/** Hierarchical Buffer **/
template<typename DTYPE, int input_size, int weight_size, int C_I, int KI, int K_I>
void hierarchical_buffer( ac_channel<PackedStencil<DTYPE, C_I> > &inputs_in, 
                          ac_channel<PackedStencil<DTYPE, C_I> > &inputs_out,
                          ac_channel<PackedStencil<DTYPE, KI, K_I> > &weights_in,
                          ac_channel<PackedStencil<DTYPE, KI, K_I> > &weights_out,
                          ac_channel<Params> &params_stream){
  
  // Inputs
  static ac_channel<chanStruct<PackedStencil<DTYPE, C_I>, input_size> > inputs_shr_mem;
  static ac_channel<int> inputs_size;

  // Weights
  static ac_channel<chanStruct<PackedStencil<DTYPE, KI, K_I>, weight_size> > weights_shr_mem;
  static ac_channel<int> weights_size;

  static ac_channel<Params> params_stream_address_generator_inputs;
  static ac_channel<Params> params_stream_address_generator_weights;
  static ac_channel<Params> params_stream_write_input;
  static ac_channel<Params> params_stream_read_input;
  static ac_channel<Params> params_stream_write_weight;
  static ac_channel<Params> params_stream_read_weight;

  params_duplicator(params_stream, 
                    params_stream_address_generator_inputs, 
                    params_stream_address_generator_weights,
                    params_stream_write_input,
                    params_stream_read_input,
                    params_stream_write_weight,
                    params_stream_read_weight);

  WRITE_HIERARCHICAL_BUFFER<PackedStencil<DTYPE, C_I>, input_size>(inputs_in, inputs_shr_mem, inputs_size);
  READ_HIERARCHICAL_BUFFER<PackedStencil<DTYPE, C_I>, input_size>(inputs_shr_mem, inputs_size, inputs_out);

  WRITE_HIERARCHICAL_BUFFER<PackedStencil<DTYPE, KI, K_I>, weight_size>(weights_in, weights_shr_mem, weights_size);
  READ_HIERARCHICAL_BUFFER<PackedStencil<DTYPE, KI, K_I>, weight_size>(weights_shr_mem, weights_size, weights_out);
}
