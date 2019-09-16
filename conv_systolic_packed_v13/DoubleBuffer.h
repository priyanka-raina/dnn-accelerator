#ifndef DOUBLE_BUFFER_H
#define DOUBLE_BUFFER_H

// #include "params.h"
// #include "Stencil_catapult.h"
// #include "conv.h"

// Include mc_scverify.h for CCS_* macros
// #include <mc_scverify.h>

// #define CCS_BLOCK(x) x

template<typename T, int N>
struct chanStruct{
  T data[N];
};

template <int size, int C_I>
class InputBankWriter{
public:
    InputBankWriter(){}

    #pragma hls_design interface
    void run(ac_channel<Params> &paramsIn,
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
    void run(ac_channel<Params> &paramsIn,
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
    void run(ac_channel<Params> &paramsIn,
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
  void run(ac_channel<PackedStencil<PRECISION, C_I> > &inputs_in, 
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
    void run(ac_channel<Params> &paramsIn,
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
    void run(ac_channel<Params> &paramsIn,
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
    void run(ac_channel<Params> &paramsIn,
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
  void run(ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_in, 
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
    void run(ac_channel<PackedStencil<PRECISION, C_I> > &inputs_in, 
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


#ifdef unified_buffer
class UnifiedBankWriter{
public:
    UnifiedBankWriter(){}

    #pragma hls_design interface
    void run(ac_channel<Params> &paramsIn,
            ac_channel<PackedStencil<PRECISION, C_I> > &inputs_in, 
            ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_in,
            ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > &bank_0,
            ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > &bank_1){
                int num_total_blocks = params.X_O * params.Y_O * params.C_O;

                int input_block_size = (params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
                int weight_block_size = params.K_OO*params.C_I*params.K_OI*params.WS*params.WS;

                while(num_total_blocks > 0){ // loop while we have blocks to fill
                    chanStruct<PackedStencil<PRECISION, KI, K_I>,size> mem[2];
                    int sub_block_num = 0;
                    
                    int space_left = size;
                    while(num_total_blocks > 0 && space_left >= (input_block_size+weight_block_size)){ // loop while we have space to fill
                        for(int bank_sel = 0; bank_sel < 2; bank_sel++){ // switch between banks
                            int current_input_offset;
                            int current_weight_offset;
                            if(bank_sel == 0){
                                current_input_offset = (input_block_size+weight_block_size)*(sub_block_num);
                                current_weight_offset = (input_block_size+weight_block_size)*(sub_block_num);
                            }
                            else{
                                current_input_offset = weight_block_size+(input_block_size+weight_block_size)*(sub_block_num);
                                current_weight_offset = input_block_size+(input_block_size+weight_block_size)*(sub_block_num);
                            }
                            
                            // Read inputs and weights into alternate banks
                            for(int i = 0; i < XY_I; i++){
                                mem[bank_sel].data[current_input_offset+i] = inputs_in.read();
                            }
                            for(int i = 0; i < K_I; i++){
                                mem[!bank_sel].data[current_weight_offset+i] = weights_in.read();
                            }
                        }
                        sub_block_num++;
                        space_left = space_left - (input_block_size+weight_block_size); // each bank has filled up XY_I inputs and K_I inputs
                        num_total_blocks = num_total_blocks - 2;
                        
                    }
                    
                    block_count.write(sub_block_num);

                    bank_0.write(mem[0]);
                    bank_1.write(mem[1]);
                }
            }
};

class UnifiedBankReader{
public:
    UnifiedBankReader(){}

    #pragma hls_design interface
    void run(ac_channel<Params> &paramsIn,
            ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > &bank_0,
            ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > &bank_1,
            ac_channel<int> &block_count,
            ac_channel<PackedStencil<PRECISION, C_I,1,1> > &inputs_out,
            ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_out){
                int num_total_blocks = params.X_O * params.Y_O;

                int input_block_size = params.C_O*(params.X_I+params.WS-1)*(params.Y_I+params.WS-1);
                int weight_block_size = params.C_O*params.K_OO*params.C_I*params.K_OI*params.WS*params.WS;
                
                while(num_total_blocks > 0){ // koop while reading blocks
                    chanStruct<PackedStencil<PRECISION, KI, K_I>,size> mem[2];
                    mem[0] = bank_0.read();
                    mem[1] = bank_1.read();
                    int num_sub_blocks = block_count.read();
                    num_total_blocks = num_total_blocks-num_sub_blocks;

                    /* Inputs */
                    for(int sub_block_count=0; sub_block_count < num_sub_blocks; sub_block_count++){
                        for(int koo_idx = 0; koo_idx < params.K_OO; koo_idx++){
                        for(int co_idx = 0; co_idx < params.C_O; co_idx++){
                        for (int wx_idx = 0; wx_idx < params.WS; wx_idx++) {
                            for (int wy_idx = 0; wy_idx < params.WS; wy_idx++) {
                            for (int koi_idx = 0; koi_idx < params.K_OI; koi_idx++) {
                                for (int x_idx=0; x_idx < params.Y_I; x_idx++) {
                                for (int y_idx=0; y_idx < params.X_I; y_idx++) {
                                    int address = (co_idx*(params.X_I+params.WS-1)*(params.Y_I+params.WS-1)) +
                                            (
                                                (x_idx+wx_idx)*(params.X_I+params.WS-1) +
                                                y_idx +
                                                wy_idx
                                            );
                                    int real_address = (sub_block_count/2*(input_block_size+weight_block_size))+
                                                        (address); 
                                    inputs_out.write(mem[sub_block_count%2].data[real_address]);
                                }
                                }
                            }
                            }
                        }
                        }
                        }
                    }
                
                    /* Weights */
                    for(int sub_block_count=0; sub_block_count < num_sub_blocks; sub_block_count++){
                        for (int wx_idx = 0; wx_idx < params.WS*params.WS; wx_idx++){
                        for (int koi_idx = 0; koi_idx < params.K_OI; koi_idx++) {
                        for (int r_idx = 0; r_idx < params.C_I; r_idx++){
                            int address = (
                                                (koi_idx*params.C_I*params.WS*params.WS) +
                                                (wx_idx*params.C_I) + 
                                                (r_idx) 
                                            );
                            int real_address = (sub_block_count/2*(input_block_size+weight_block_size))+
                                                        (address); 
                                                        
                            weights_out.write(mem[sub_block_count%2].data[real_address]);
                            }
                        }
                        }
                    }
                }


            }
};

class UnifiedDoubleBuffer{
public:
    UnifiedDoubleBuffer(){}

#pragma hls_design interface
    void run(ac_channel<PackedStencil<PRECISION, C_I> > &inputs_in, 
            ac_channel<PackedStencil<PRECISION, C_I> > &inputs_out,
            ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_in,
            ac_channel<PackedStencil<PRECISION, KI, K_I> > &weights_out,
            ac_channel<Params> &paramsIn){
                
                unifiedBankWriter.run(paramsIn, inputs_in, weights_in, bank_0, bank_1, bank_counts);
                unifiedBankReader.run(paramsIn, bank_0, bank_1, bank_counts, inputs_out, weights_out);

    }
private:
    ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > bank_0;
    ac_channel<chanStruct<PackedStencil<PRECISION, KI, K_I>,size> > bank_1;
    ac_channel<int> block_counts;

    UnifiedBankWriter unifiedBankWriter;
    UnifiedBankReader unifiedBankReader;
};
#endif


#endif
