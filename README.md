# DNN Accelerator

## Designs in the paper
| Name  | Dataflow | Dimension | PE Number | RF Size | Mem Size
| --- | --- | --- | --- | --- | --- |
| OS4 | X | 1D | 4 | 32 B | 32 KB |
| OS8 | X | 1D | 8 | 64 B | 64 KB |
| WS16 | C K | 2D | 16 | 64 B | 32 KB |

## Description of the files
[`conv_systolic_packed_OS_v5`](conv_systolic_packed_OS_v5) - This folder has ?
* [`conv_systolic_packed_OS_v5/conv_ref.cpp`](conv_systolic_packed_OS_v5/conv_ref.cpp) - Gold model for convolution
* [`conv_systolic_packed_OS_v5/conv_ref.h`](conv_systolic_packed_OS_v5/conv_ref.h) - Header file for `conv_ref.cpp`
* [`conv_systolic_packed_OS_v5/Stencil_catapult.h`](conv_systolic_packed_OS_v5/Stencil_catapult.h) -
* [`conv_systolic_packed_OS_v5/double_buffer.cpp`](conv_systolic_packed_OS_v5/double_buffer.cpp) -
* [`conv_systolic_packed_OS_v5/hls_target.cpp`](conv_systolic_packed_OS_v5/hls_target.cpp) - Top level design file input to HLS
* [`conv_systolic_packed_OS_v5/hls_target.h`](conv_systolic_packed_OS_v5/hls_target.h) -
* [`conv_systolic_packed_OS_v5/tb_hls_target.cpp`](conv_systolic_packed_OS_v5/tb_hls_target.cpp) - Top level testbench - verifies if the design in `hls_target.cpp` is same as `conv_ref.cpp` for randomly generated test vectors
* [`conv_systolic_packed_OS_v5/setup.tcl`](conv_systolic_packed_OS_v5/setup.tcl) - HLS directives?
* [`conv_systolic_packed_OS_v5/concat_rtl.v`](conv_systolic_packed_OS_v5/concat_rtl.v) - Verilog generated by HLS

[`conv_systolic_packed_v13`](conv_systolic_packed_v13) - This folder has ?
* [`conv_systolic_packed_v13/Stencil_catapult.h`](conv_systolic_packed_v13/Stencil_catapult.h) - Same as the file above folder
* [`conv_systolic_packed_v13/conv.h`](conv_systolic_packed_v13/conv.h)
* [`conv_systolic_packed_v13/conv_ref.cpp`](conv_systolic_packed_v13/conv_ref.cpp) - Same as the file above folder
* [`conv_systolic_packed_v13/conv_ref.h`](conv_systolic_packed_v13/conv_ref.h)
* [`conv_systolic_packed_v13/double_buffer.cpp`](conv_systolic_packed_v13/double_buffer.cpp)
* [`conv_systolic_packed_v13/tb_gemm_systolic.cpp`](conv_systolic_packed_v13/tb_gemm_systolic.cpp)
* [`conv_systolic_packed_v13/catapult_gemm_systolic.cpp`](conv_systolic_packed_v13/catapult_gemm_systolic.cpp)
* [`conv_systolic_packed_v13/concat_rtl.v`](conv_systolic_packed_v13/concat_rtl.v)
## How to run catapult
