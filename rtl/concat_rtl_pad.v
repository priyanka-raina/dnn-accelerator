module gemm_pad (
  clk, rst, input_rsc_z, input_rsc_vz, input_rsc_lz, weight_rsc_z, weight_rsc_vz,
      weight_rsc_lz, output_rsc_z, output_rsc_vz, output_rsc_lz
);
  input clk;
  input rst;
  input [127:0] input_rsc_z;
  input input_rsc_vz;
  output input_rsc_lz;
  input [255:0] weight_rsc_z;
  input weight_rsc_vz;
  output weight_rsc_lz;
  output [255:0] output_rsc_z;
  input output_rsc_vz;
  output output_rsc_lz;
  
  pad_in#(.w(1  )) pad_wr_laplacian_tag_gcredit_1      (.PAD(wr_laplacian_tag_gcredit_1      ), .C(w_wr_laplacian_tag_gcredit_1));

  pad_out#(.w(1 )) pad_rd_params_pcredit               (.PAD(rd_params_pcredit               ), .I(w_rd_params_pcredit));

endmodule
