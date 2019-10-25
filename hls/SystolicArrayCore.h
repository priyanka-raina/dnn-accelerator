#ifndef SYSTOLIC_ARRAY_CORE_H
#define SYSTOLIC_ARRAY_CORE_H

#include "common.h"
#include "ProcessingElement.h"
#include "InputSkewer.h"
#include "OutputSkewer.h"
// #include "PEArray.h"

struct LoopParams{
    int C_O;
    int WS;
    int c_idx;
    int wx_idx;
    int wy_idx;
    int koi_idx;
    int X_I;
    int Y_I;
    int K_OO;
    int K_OI;
    // int step;
    // bool weight_read;
    // bool input_read;
    // bool clear_output_buffer;
    // bool add_to_output;
    // bool store_partial_sum;
    // bool completed_row;
};

#define MOD(x,y)\
    ( ( (x) % (y) + y ) % y )

template <typename IDTYPE, typename ODTYPE, int K_II, int K_I, int C_I>
class SystolicArrayCore
{
public:
    SystolicArrayCore() {}

#pragma hls_design interface
#pragma hls_pipeline_init_interval 1
    void run(
        ac_channel<PackedStencil<INPUT_PRECISION, C_I, 1, 1> > &input, 
        ac_channel<PackedStencil<INPUT_PRECISION, K_II, K_I, 1> > &weight, 
        ac_channel<PackedStencil<OUTPUT_PRECISION, K_II, K_I, 1> > &output,
        ac_channel<LoopParams> &paramsIn)
    {
        #ifndef __SYNTHESIS__
        while(paramsIn.available(1))
        #endif
        {
            params = paramsIn.read();

            #ifndef __SYNTHESIS__
            assert(params.X_I * params.Y_I * params.K_OO*params.K_OI < 256);
            #endif

        //  // TODO: set these hls_unroll pragmas to the TCL script
        // #pragma hls_unroll no
        // xy_o: for (int p = 0; p < params.X_O * params.Y_O; ++p) { //loop over image tiles        
        //     #pragma hls_unroll no
        //     k_oo: for(int koo_idx = 0; koo_idx < params.K_OO; ++koo_idx){ // loop over outer kernel tiles    
        //         #pragma hls_unroll no
        //         co: for (int c_idx = 0; c_idx < params.C_O; ++c_idx) { // loop over channel tile
        //             #pragma hls_unroll no
        //             winx: for (int wx_idx = 0; wx_idx < params.WS; ++wx_idx) { // loop over filter window x
        //                 #pragma hls_unroll no
        //                 winy: for (int wy_idx = 0; wy_idx < params.WS; ++wy_idx) { // loop over filter window y
        //                     #pragma hls_unroll no
        //                     k_oi: for (int koi_idx = 0; koi_idx < params.K_OI; ++koi_idx) { // loop over kernel tiles
                                #pragma hls_unroll no
                                #pragma hls_pipeline_init_interval 1
                                xy_i: for (int step = 0; step < K_I+C_I+(params.X_I*params.Y_I)-1; ++step) { // loop inside each image tile
                                    
                                    // filling phase for systolic array, put data into local registers 
                                    if (step < C_I) {      
                                    // if(params_old.weight_read){      
                                        PackedStencil<INPUT_PRECISION,K_II, K_I> w_row = weight.read();
                                        for(int j = 0; j < K_I; j++){
                                            w_tile[step][j] = w_row.get_dim(j,0,0);
                                        }
                                        // w_tile[step] = w_row;
                                        /*#ifndef __SYNTHESIS__
                                        for (int col = 0; col<K_I; col++) {
                                            printf("weight=%d on row  %d, col %d\n", w_row(0,col,0,0), step, col);
                                        }
                                        #endif*/
                                    }

                                    /* read input from the output stream of the double buffer,
                                    push input to fifos, and read input from fifos into local registers*/
                                    PackedStencil<INPUT_PRECISION, C_I,1,1> in_col;
                                    if (step < (params.X_I*params.Y_I)) {        
                                    // if (params_old.input_read) {        
                                    in_col = input.read();
                                    /*#ifndef __SYNTHESIS__
                                    for (int row = 0; row<C_I; row++) {
                                        printf("input=%d on row  %d, col %d\n", in_col(row,0,0,0), step, row);
                                    }
                                    #endif*/
                                    }
                            
                                    // The local registers serve data to the first column of PE array. 
                                    PackedStencil<INPUT_PRECISION, C_I,1,1> input_buf;

                                    /* A trianglar shape of FIFOs, used for skewing the array front,
                                    such that the right input data comes to the right PE at the right timing.*/
                                    // #define INPUT_FIFO_BODY(z,i,unused) \
                                    // IDTYPE BOOST_PP_CAT(input_fifo_output_, i); \
                                    // IDTYPE BOOST_PP_CAT(input_fifo_input_, i) = in_col.read(i ,0,0); \
                                    // BOOST_PP_CAT(input_fifo_, i).run( BOOST_PP_CAT(input_fifo_input_, i) , BOOST_PP_CAT(input_fifo_output_, i) ); \
                                    // input_buf.write(BOOST_PP_CAT(input_fifo_output_, i), i ,0,0,0);
                                    // REPEAT(INPUT_FIFO_BODY)
                                    inputSkewer.run(in_col, input_buf);
                            
                                    /*#ifndef __SYNTHESIS__
                                    printf("starting step %d - input %d %d %d %d\n", step, input_fifo_0,input_fifo_1,input_fifo_2,input_fifo_3);
                                    #endif*/

                                    
                                    PackedStencil<OUTPUT_PRECISION, K_II, K_I,1> output_buf;

                                    // initial partial output of 0
                                    if(params.c_idx == 0 && params.wx_idx == 0 && params.wy_idx == 0) {
                                    // if(params_old.clear_output_buffer) {
                                        output_buf.clear();
                                    }
                                    else{ // read partial output from accumulation buffer
                                        #pragma hls_unroll yes
                                        for(int i = 0; i < C_I; ++i){
                                            PackedStencil<OUTPUT_PRECISION, K_II> tmp_row;
                                            int address = MOD( (params.koi_idx*(params.X_I*params.Y_I) + step + K_I- i), 256);
                                            tmp_row.value = out_tile[address][i];
                                            output_buf.set_dim(tmp_row, i, 0, 0);
                                        }
                                    
                                    // #define TMP_ROW_OUT(z,i,unused) \
                                    //     PackedStencil<OUTPUT_PRECISION, K_II> BOOST_PP_CAT(tmp_row_, i); \
                                    //     BOOST_PP_CAT(tmp_row_, i).value = BOOST_PP_CAT(out_tile_, i)[ MOD( (params.koi_idx*(params.X_I*params.Y_I) + step + K_I- i), 256) ]; \
                                    //     output_buf.set_dim(BOOST_PP_CAT(tmp_row_, i), i, 0, 0);
                                    // REPEAT(TMP_ROW_OUT)
                                    }

                                    /*#ifndef __SYNTHESIS__
                                    printf("starting step %d - partial result %d %d %d %d\n", step, tmp_fifo_0,tmp_fifo_1,tmp_fifo_2,tmp_fifo_3);
                                    #endif*/
                            
                                    //initialize the input registers in the first column 
                                    #pragma hls_unroll yes
                                    LABEL(INIT_IN) for(int i = 0; i < C_I; ++i) {
                                        in_tmp[i+1][0] = input_buf.read(i,0,0);
                                    }
                                
                                    //initialize the output registers in the first row 
                                    #pragma hls_unroll yes
                                    LABEL(INIT_OUT) for(int j = 0; j < K_I; ++j) {
                                        out_tmp[0][j+1] = output_buf.get_dim(j, 0, 0);
                                    }
                                

                                    // perform the a matrix multiplication in a systolic fashion 
                                    #pragma hls_unroll yes
                                    LABEL(COL) for (int j=0; j < K_I; ++j) {
                                        #pragma hls_unroll yes
                                        LABEL(ROW) for (int i=0; i < C_I; ++i) {
                                        // PackedStencil<INPUT_PRECISION, K_II> weight_value = w_tile[i].get_dim(j,0,0);
                                        pe[i][j].run(in_tmp[i+1][j], out_tmp[i][j+1], w_tile[i][j], in_tmp2[i+1][j+1], out_tmp2[i+1][j+1]);
                                        } //ROW
                                    } //COL
                                    
                                    // PackedStencil<OUTPUT_PRECISION, K_II, K_I> unskewed_output;
                                    // peArray.run(
                                    //     input_buf,
                                    //     output_buf,
                                    //     unskewed_output,
                                    //     w_row,
                                    //     step
                                    // );
                                
                            
                                    /* A trianglar shape of FIFOs, used for skewing as well, 
                                    such that the right output data are collected at the right timing*/ 
                                    
                                
                                    // #define FIFO_WRITE_BODY(z,i,unused)\
                                    //     PackedStencil<OUTPUT_PRECISION, K_II> BOOST_PP_CAT(sys_array_out_,i) = out_tmp[C_I][i+1];
                                    // REPEAT(FIFO_WRITE_BODY)

                                    


                                    /*#ifndef __SYNTHESIS__
                                        printf("ending step %d - output %d %d %d %d\n", step, output_fifo_0,output_fifo_1,output_fifo_2,output_fifo_3);
                                    #endif*/
                                
                                    if (params.c_idx==params.C_O-1 && params.wx_idx == params.WS-1 && params.wy_idx == params.WS-1) {
                                    // if (params_old.add_to_output) {
                                        // #define FIFO_WRITE_BODY_NEW(z,i,unused)\
                                        //     PackedStencil<OUTPUT_PRECISION, K_II> BOOST_PP_CAT(output_fifo_output_, i); \
                                        //     BOOST_PP_CAT(output_fifo_, i).run( BOOST_PP_CAT(sys_array_out_, i) , BOOST_PP_CAT(output_fifo_output_, i) );\
                                        //     output_row.set_dim(BOOST_PP_CAT(output_fifo_output_,i), i,0,0); 
                                        // REPEAT(FIFO_WRITE_BODY_NEW)

                                        PackedStencil<OUTPUT_PRECISION, K_II, K_I> unskewed_output;
                                        PackedStencil<OUTPUT_PRECISION, K_II, K_I> output_row;
                                        #pragma hls_unroll yes
                                        for(int i = 0; i < C_I; i++){
                                            unskewed_output.write(out_tmp[C_I][i+1], 0, i, 0, 0);
                                        }

                                        outputSkewer.run(unskewed_output, output_row);

                                        if(step >= K_I+C_I-1){
                                            output.write(output_row);
                                        }
                                        // outputSkewer.run(output_row);    
                                    }
                                    else{

                                        if(step >= K_I){
                                        // if(params_old.store_partial_sum){
                                            // #define OUTPUT_ROW_BODY(z,i,unused)\
                                            //     BOOST_PP_CAT(out_tile_,i)[ MOD( (params.koi_idx*(params.X_I*params.Y_I)+step-(K_I)+K_I-i), 256) ] = BOOST_PP_CAT(sys_array_out_,i);
                                            // REPEAT(OUTPUT_ROW_BODY)

                                            #pragma hls_unroll yes
                                            for(int i = 0; i < C_I; i++){
                                                int address = MOD( (params.koi_idx*(params.X_I*params.Y_I)+step-(K_I)+K_I-i), 256);
                                                out_tile[address][i] = out_tmp[C_I][i+1];
                                                // out_tile[address][i] = unskewed_output.read(0, i, 0, 0);
                                            }
                                        }
                                    }


                                    // // output row if one has completed
                                    // if (step >= K_I+C_I-1) {
                                    // // if (completed_row) {
                                    //     if (params.c_idx==params.C_O-1 && params.wx_idx == params.WS-1 && params.wy_idx == params.WS-1) {
                                    //     // if (params_old.add_to_output) {
                                    //     output.write(output_row);
                                    //     }
                                    // }

                                    
                                    #pragma hls_unroll yes
                                    for(int j = 0; j < K_I; j++){
                                        #pragma hls_unroll yes
                                        for(int i = 0; i < C_I; i++){
                                        in_tmp[i+1][j+1] = in_tmp2[i+1][j+1];
                                        out_tmp[i+1][j+1] = out_tmp2[i+1][j+1];
                                        }
                                    }
                                    // params_old = params;
                                }
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }
    }
    }

private:
    // PEArray<IDTYPE, ODTYPE, K_II, K_I, C_I, X_I, Y_I, K> peArray;
    // C_I x K_I PE array
    ProcessingElement<IDTYPE, ODTYPE, K_II> pe[C_I][K_I];

// local buffers to store partial output
// #define OUT_TILE_INIT(z, i, unused) \
//     ac_int<OUTPUT_PRECISION * K_II, false> BOOST_PP_CAT(out_tile_, i)[256];
//     REPEAT(OUT_TILE_INIT)
    ac_int<OUTPUT_PRECISION * K_II, false> out_tile[256][C_I];

// #define INPUT_FIFOS_INIT(z, i, unused) \
//     Fifo<IDTYPE, i + 1> BOOST_PP_CAT(input_fifo_, i);
//     REPEAT(INPUT_FIFOS_INIT)
    InputSkewer<PackedStencil<INPUT_PRECISION, C_I> > inputSkewer;

// #define OUTPUT_FIFOS_INIT(z, i, unused) \
//     Fifo<PackedStencil<OUTPUT_PRECISION, K_II>, K_I - i> BOOST_PP_CAT(output_fifo_, i);
//     REPEAT(OUTPUT_FIFOS_INIT)
    OutputSkewer<PackedStencil<OUTPUT_PRECISION, K_II>, PackedStencil<OUTPUT_PRECISION, K_II, K_I>, K_I > outputSkewer;

    PackedStencil<INPUT_PRECISION,K_II> w_tile[C_I][K_I];

    /*
  the registers that used for relaying input and output in horizonal and vertical directions respectively.
  PE[i][j] fetch input data from register in_tmp[i+1][j], at next cycle forward the data to in_tmp[i+1][j+1]
  PE[i][j] fetch output data from register out_tmp[i][j+1], at next cycle forward the data to out_tmp[i+1][j+1]
  */
    IDTYPE in_tmp[C_I + 1][K_I + 1];
    PackedStencil<OUTPUT_PRECISION, K_II, 1, 1> out_tmp[C_I + 1][K_I + 1];
    IDTYPE in_tmp2[C_I+1][K_I+1];
    PackedStencil<OUTPUT_PRECISION, K_II, 1, 1> out_tmp2[C_I+1][K_I+1];

    LoopParams params;
    // Params params;
    LoopParams params_old;
};

#endif
