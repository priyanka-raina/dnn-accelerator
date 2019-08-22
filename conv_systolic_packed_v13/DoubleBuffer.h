#ifndef DOUBLE_BUFFER_H
#define DOUBLE_BUFFER_H

#include "params.h"
#include "Stencil_catapult.h"
#include "conv.h"

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

template<typename T, int N>
struct chanStruct{
  T data[N];
};

template <int size, int C_I>
class InputBankWriter{
public:
    InputBankWriter(){}

    #pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<Params> &paramsIn,
                        ac_channel<PackedStencil<PRECISION,C_I> > &din,
                        ac_channel<chanStruct<PackedStencil<PRECISION,C_I>,size> > &dout){
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();

            int total_blocks = params.X_O*params.Y_O;
            int block_size = params.C_O*(params.X_I+params.WS-1)*(params.Y_I+params.WS-1);

             while(total_blocks > 0){
                chanStruct<PackedStencil<PRECISION,C_I>,size> tmp;

                int current_buffer_size = 0;
                int block_in_buffer = 0;
                while(total_blocks > 0 &&  (current_buffer_size+block_size <= size ) ){
                for(int idx = 0; idx < block_size; idx++){
                    PackedStencil<PRECISION,C_I,1,1> column;
                    column = din.read();
                    tmp.data[current_buffer_size+idx] = column;
                }

                total_blocks--;
                current_buffer_size += block_size;
                block_in_buffer++;
                }
                dout.write(tmp);
            }
        }
    }
};

template <int size, int C_I>
class InputBankReader{
public:
    InputBankReader(){}

    #pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<Params> &paramsIn,
                        ac_channel<chanStruct<PackedStencil<PRECISION, C_I>,size> > &din, 
                        ac_channel<int> &addresses, ac_channel<int> &address_sizes,
                        ac_channel<PackedStencil<PRECISION, C_I,1,1> > &dout)
    {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();
            int total_blocks = params.X_O*params.Y_O;
            int block_size = params.C_O*(params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
            int total_block_size = (total_blocks)*(block_size);

            #pragma hls_pipeline_init_interval 1
            while(total_block_size > 0){
                chanStruct<PackedStencil<PRECISION, C_I,1,1>, size> tmp = din.read();

                int address_size = address_sizes.read();
                for(int idx = 0; idx < address_size; idx++){
                    PackedStencil<PRECISION, C_I,1,1> dout_struct;

                    int address = addresses.read();

                    dout_struct = tmp.data[address];

                    dout.write(dout_struct);
                }
                total_block_size -= address_size;
            }
        }
    }
};

template <int size>
class InputBankAddressGenerator{
public:
    InputBankAddressGenerator(){}
    
    #pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<Params> &paramsIn,
                        ac_channel<int> &addresses, 
                        ac_channel<int> &address_sizes)
                              {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();

            int total_blocks = params.X_O*params.Y_O;
            int block_size = params.C_O*(params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
            int read_block_size = params.K_OO * params.C_O * params.WS * params.WS * params.K_OI * params.Y_I * params.X_I;

            while(total_blocks > 0){
                // first determine how many blocks will fit in the buffer
                int temp_total_blocks = total_blocks;
                int temp_current_buffer_size = 0;
                int temp_block_count = 0;
                while(temp_total_blocks > 0 && (temp_current_buffer_size+block_size <= size)){
                temp_block_count++;
                temp_total_blocks--;
                temp_current_buffer_size += block_size;
                }
                address_sizes.write(temp_block_count * read_block_size);

                int current_buffer_size = 0;
                int block_in_buffer = 0;
                int block_count = 0;
                while(total_blocks > 0 && (current_buffer_size+block_size <= size)){
                for(int koo_idx = 0; koo_idx < params.K_OO; koo_idx++){
                    for(int co_idx = 0; co_idx < params.C_O; co_idx++){
                    for (int wx_idx = 0; wx_idx < params.WS; wx_idx++) {
                        for (int wy_idx = 0; wy_idx < params.WS; wy_idx++) {
                        for (int koi_idx = 0; koi_idx < params.K_OI; koi_idx++) {
                            for (int x_idx=0; x_idx < params.Y_I; x_idx++) {
                            for (int y_idx=0; y_idx < params.X_I; y_idx++) {
                                int address = (block_count*block_size) +
                                            (co_idx*(params.X_I+params.WS-1)*(params.Y_I+params.WS-1)) +
                                            (
                                                (x_idx+wx_idx)*(params.X_I+params.WS-1) +
                                                y_idx +
                                                wy_idx
                                            );
                                addresses.write(address);
                            }
                            }
                        }
                        }
                    }
                    }
                }
                block_count++;
                total_blocks--;
                current_buffer_size += block_size;
                }
            }
        }
    }

};

template <int size, int C_I>
class InputBank{
public:
  InputBank(){}

  #pragma hls_design interface
  #pragma hls_pipeline_init_interval 1
  void CCS_BLOCK(run)(ac_channel<PackedStencil<PRECISION, C_I> > &inputs_in, 
                      ac_channel<PackedStencil<PRECISION, C_I> > &inputs_out,
                      ac_channel<Params> &paramsIn){
    #ifndef __SYNTHESIS__
    while(paramsIn.available(1))
    #endif
    {
        Params params = paramsIn.read();

        inputBankReaderParams.write(params);
        inputBankWriterParams.write(params);
        inputBankAddressGeneratorParams.write(params);

        inputBankAddressGenerator.run(inputBankAddressGeneratorParams, addresses, address_sizes);
        inputBankWriter.run(inputBankWriterParams, inputs_in, mem);
        inputBankReader.run(inputBankReaderParams, mem, addresses, address_sizes, inputs_out);
    }
  }

private:
    ac_channel<chanStruct<PackedStencil<PRECISION, C_I>,size> > mem;
    
    InputBankWriter<size, C_I> inputBankWriter;
    ac_channel<Params> inputBankWriterParams;
    
    InputBankReader<size, C_I> inputBankReader;
    ac_channel<Params> inputBankReaderParams;

    InputBankAddressGenerator<size> inputBankAddressGenerator;
    ac_channel<Params> inputBankAddressGeneratorParams;
    ac_channel<int> addresses;
    ac_channel<int> address_sizes;
};

template <int size, int KI, int K_I>
class WeightBankWriter{
public:
    WeightBankWriter(){}

    #pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<Params> &paramsIn,
                        ac_channel<PackedStencil<PRECISION, KI, K_I> > &din,
                        ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>, size> > &dout){
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();

            int total_blocks = params.X_O * params.Y_O * params.C_O * params.K_OO;
            int block_size = params.C_I*params.K_OI*params.WS*params.WS;

             while(total_blocks > 0){
                chanStruct<PackedStencil<PRECISION, KI, K_I>, size> tmp;

                int current_buffer_size = 0;
                int block_in_buffer = 0;
                while(total_blocks > 0 &&  (current_buffer_size+block_size <= size ) ){

                    for(int idx = 0; idx < block_size; idx++){
                        PackedStencil<PRECISION, KI, K_I> row;
                        row = din.read();
                        tmp.data[current_buffer_size+idx] = row;
                    }

                    total_blocks--;
                    current_buffer_size += block_size;
                    block_in_buffer++;
                }
                dout.write(tmp);
            }
        }
    }
};

template <int size, int KI, int K_I>
class WeightBankReader{
public:
    WeightBankReader(){}

    #pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<Params> &paramsIn,
                        ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > &din, 
                        ac_channel<int> &addresses, ac_channel<int> &address_sizes,
                        ac_channel<PackedStencil<PRECISION, KI, K_I> > &dout)
    {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();
            int total_blocks = params.X_O * params.Y_O * params.C_O * params.K_OO;
            int block_size = params.C_I*params.K_OI*params.WS*params.WS;
            int total_block_size = (total_blocks)*(block_size);

            #pragma hls_pipeline_init_interval 1
            while(total_block_size > 0){
                chanStruct<PackedStencil<PRECISION, KI, K_I>,size> tmp = din.read();

                int address_size = address_sizes.read();
                
                for(int idx = 0; idx < address_size; idx++){
                    PackedStencil<PRECISION, KI, K_I> dout_struct;

                    int address = addresses.read();

                    dout_struct = tmp.data[address];

                    dout.write(dout_struct);
                }
                total_block_size -= address_size;
            }
        }
    }
};

template <int size>
class WeightBankAddressGenerator{
public:
    WeightBankAddressGenerator(){}
    
    #pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<Params> &paramsIn,
                        ac_channel<int> &addresses, 
                        ac_channel<int> &address_sizes)
                              {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            Params params = paramsIn.read();

            int total_blocks = params.X_O * params.Y_O * params.C_O * params.K_OO;
            int block_size = params.C_I*params.K_OI*params.WS*params.WS;
            // int inner_blocking = size / block_size;
            // int outer_blocking = total_blocks / inner_blocking;

            while(total_blocks > 0){
                // int idx = 0;

                // first determine how many blocks will fit in the buffer
                int temp_total_blocks = total_blocks;
                int temp_current_buffer_size = 0;
                int temp_block_count = 0;
                while(temp_total_blocks > 0 && (temp_current_buffer_size+block_size <= size)){
                temp_block_count++;
                temp_total_blocks--;
                temp_current_buffer_size += block_size;
                }
                address_sizes.write(temp_block_count * block_size);

                int current_buffer_size = 0;
                int block_in_buffer = 0;
                int block_count = 0;
                while(total_blocks > 0 && (current_buffer_size+block_size <= size)){
                for (int wx_idx = 0; wx_idx < params.WS*params.WS; wx_idx++){
                for (int koi_idx = 0; koi_idx < params.K_OI; koi_idx++) {
                    for (int r_idx = 0; r_idx < params.C_I; r_idx++){
                        int address = block_count*block_size
                                        + 
                                        (
                                            (koi_idx*params.C_I*params.WS*params.WS) +
                                            (wx_idx*params.C_I) + 
                                            (r_idx) 
                                        );
                        addresses.write(address);
                        }
                    }
                    }
                block_count++;
                total_blocks--;
                current_buffer_size += block_size;
                }

            }
        }
    }
};

template <int size, int KI, int K_I>
class WeightBank{
public:
  WeightBank(){}

  #pragma hls_design interface
  #pragma hls_pipeline_init_interval 1
  void CCS_BLOCK(run)(ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_in, 
                      ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_out,
                      ac_channel<Params> &paramsIn){
    #ifndef __SYNTHESIS__
    while(paramsIn.available(1))
    #endif
    {
        Params params = paramsIn.read();

        weightBankReaderParams.write(params);
        weightBankWriterParams.write(params);
        weightBankAddressGeneratorParams.write(params);

        weightBankAddressGenerator.run(weightBankAddressGeneratorParams, addresses, address_sizes);
        weightBankWriter.run(weightBankWriterParams, weights_in, mem);
        weightBankReader.run(weightBankReaderParams, mem, addresses, address_sizes, weights_out);
    }
  }

private:
    ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > mem;
    
    WeightBankWriter<size, KI, K_I> weightBankWriter;
    ac_channel<Params> weightBankWriterParams;
    
    WeightBankReader<size, KI, K_I> weightBankReader;
    ac_channel<Params> weightBankReaderParams;

    WeightBankAddressGenerator<size> weightBankAddressGenerator;
    ac_channel<Params> weightBankAddressGeneratorParams;
    ac_channel<int> addresses;
    ac_channel<int> address_sizes;
};

template <int input_size, int weight_size, int C_I, int KI, int K_I>
class DoubleBuffer{
public:
    DoubleBuffer(){}

#pragma hls_design interface
    void CCS_BLOCK(run)(ac_channel<PackedStencil<PRECISION, C_I> > &inputs_in, 
                      ac_channel<PackedStencil<PRECISION, C_I> > &inputs_out,
                      ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_in,
                      ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_out,
                      ac_channel<Params> &paramsIn){
    
        #ifndef __SYNTHESIS__
    while(paramsIn.available(1))
    #endif
    {
        Params params = paramsIn.read();
        inputBankParams.write(params);
        weightBankParams.write(params);
        
        inputBank.run(inputs_in, inputs_out, inputBankParams);
        weightBank.run(weights_in, weights_out, weightBankParams);

    }      
        
    }
private:
  InputBank<input_size, C_I> inputBank;
  ac_channel<Params> inputBankParams;

  WeightBank<weight_size, KI, K_I> weightBank;
  ac_channel<Params> weightBankParams;
};

#endif
